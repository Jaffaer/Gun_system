if not JF.Jamming["Enabled"] then return end

local utils = require 'utils'
local jammed = GetGameTimer()
local currentWeapon

local jamAnim = JF.Jamming["Animation"]
local isJammed = false
local waitingForInput = false
local fixNotification = nil
local isDoingSkillcheck = false
LocalPlayer.state:set('JammedState', false, false)

local function showFixNotification()
    if fixNotification then
        lib.notify.dismiss(fixNotification)
    end
    
    fixNotification = lib.notify({
        title = "Vapnet Jammat!",
        description = "Tryck [E] för att fixa vapnet",
        type = "error",
        icon = "fa-solid fa-triangle-exclamation",
        duration = false
    })
    waitingForInput = true
end

AddEventHandler('ox_inventory:currentWeapon', function(data)
    -- Om vapnet byts/läggs undan, ta bort notisen
    if not data and fixNotification then
        lib.notify.dismiss(fixNotification)
        fixNotification = nil
        waitingForInput = false
    end
    
    currentWeapon = data
    
    -- Om samma jammade vapen tas upp igen, visa notisen
    if currentWeapon and isJammed and not isDoingSkillcheck then
        showFixNotification()
    end
end)

local function skillCheck()
    if isDoingSkillcheck then return end
    
    isDoingSkillcheck = true
    waitingForInput = false
    
    -- Ta bort fix-notisen
    if fixNotification then
        lib.notify.dismiss(fixNotification)
        fixNotification = nil
    end
    
    Wait(1000)
    local success

    repeat
        success = lib.skillCheck(
            { 'easy', 'easy', { areaSize = 50, speedMultiplier = 1 }, 'easy' }, 
            { '1', '2', '3', '4' }
        )
        Wait(success and 100 or 800)
    until success

    isDoingSkillcheck = false

    if success then
        isJammed = false
        LocalPlayer.state:set('JammedState', false, false)
        JF.Notification(JF.Labels["has_unjammed"])
    end
end

local function disableFiring()
    while isJammed do
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 25, true)
        Wait(5)
    end
end

local function jammedAnim()
    lib.requestAnimDict(jamAnim["Dict"])
    
    while isDoingSkillcheck do
        TaskPlayAnim(cache.ped, jamAnim["Dict"], jamAnim["Anim"], 1.0, 1.0, -1, 49, 0.0, false, false, false)
        Wait(3000) -- Vänta 3 sekunder innan animationen loopas igen (justera efter behov)
    end
    
    ClearPedTasks(cache.ped)
    RemoveAnimDict(jamAnim["Dict"])
end

local function waitForInput()
    showFixNotification()
    
    CreateThread(function()
        while waitingForInput and isJammed do
            if IsControlJustPressed(0, 38) then -- E-knappen (38 = E)
                waitingForInput = false
                
                -- Starta skillcheck
                Citizen.CreateThread(function()
                    skillCheck()
                end)
                
                -- Starta animation
                Citizen.CreateThread(function()
                    jammedAnim()
                end)
                break
            end
            Wait(0)
        end
    end)
end

AddStateBagChangeHandler('JammedState', nil, function(bagName, key, value)
    if value == nil or not type(value) == "boolean" then return end
    local oldJammed = isJammed
    isJammed = value
    utils.jfDebugger("isJammed har blivit satt till ", isJammed)
    
    if isJammed and not oldJammed then
        JF.Notification(JF.Labels["has_jammed"])
        
        -- Starta disable firing (vapnet går inte att skjuta med)
        Citizen.CreateThread(function()
            disableFiring()
        end)
        
        -- Vänta på E-input
        Citizen.CreateThread(function()
            waitForInput()
        end)
    end
end)

AddEventHandler("CEventGunShotWhizzedBy", function(entities, eventEntity, args)
    if currentWeapon then
        if not isJammed then
            utils.jfDebugger("currentWeapon.metadata.durability ", currentWeapon.metadata.durability)
            
            if utils.getJammingChance(currentWeapon.metadata.durability) and 
               (GetGameTimer() - jammed) > (JF.Jamming["Cooldown"] * 1000) then
                jammed = GetGameTimer()
                LocalPlayer.state:set('JammedState', true, false)
            end
        end
    end
end)