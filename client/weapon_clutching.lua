local isClutchActive = false

local clutchAnimations = {
    front = {
        dict = "cxsht_clutching_front@animation",
        clip = "cxsht_clutching_front_clip"
    },
    back = {
        dict = "cxsht_clutching_back@animation",
        clip = "cxsht_clutching_back_clip"
    },
    arm = {
        dict = "cxsht_clutching_arm@animation",
        clip = "cxsht_clutching_arm_clip"
    },
    backpack = {
        dict = "cxsht_bp_clutching@animation",
        clip = "cxsht_bp_clutching_clip"
    }
}

local clutchDescriptions = {
    front = "Du sträcker in i ditt främre midjeband...",
    back = "Du sträcker dig bakom din midja...",
    arm = "Du sträcker dig under din arm...",
    backpack = "Du sträcker dig ner i din ryggsäck..."
}

local clutchStyles = {
    front = {icon = "fa-solid fa-gun", color = "crimson"},
    back = {icon = "fa-solid fa-gun", color = "dodgerblue"},
    arm = {icon = "fa-solid fa-gun", color = "darkorange"},
    backpack = {icon = "fa-solid fa-gun", color = "mediumseagreen"}
}

function IsPlayerClutching()
    if not selectedClutchStyle then
        return false
    end
    
    local anim = clutchAnimations[selectedClutchStyle]
    return IsEntityPlayingAnim(PlayerPedId(), anim.dict, anim.clip, 3)
end

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local success
        
        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success
        
        EndFindPed(handle)
    end)
end

function GetPlayerJob()
    local jobName = "unemployed"
    
    if JF.Framework == "qb" then
        local QBCore = exports["qb-core"]:GetCoreObject()
        local playerData = QBCore.Functions.GetPlayerData()
        jobName = playerData?.job?.name or "unemployed"
    elseif JF.Framework == "esx" then
        local ESX = exports.es_extended:getSharedObject()
        local playerData = ESX.GetPlayerData()
        jobName = playerData?.job?.name or "unemployed"
    end
    
    return jobName
end

function IsJobBlocked()
    local jobName = GetPlayerJob()
    return JF.Clutch.BlockedJobs[jobName] == true
end

function ShowClutchMenu()
    if IsJobBlocked() then
        lib.notify({
            title = "Åtkomst nekad",
            description = "Ditt jobb har inte behörighet att använda detta kommando.",
            type = "error"
        })
        return
    end
    
    lib.registerContext({
        id = "clutch_menu",
        title = "Vapendragning",
        options = {
            {
                title = "Främre midja",
                icon = "fa-solid fa-gun",
                iconColor = "crimson",
                description = "Dra vapen från **främre midjan**.",
                metadata = {{label = "Aktivering", value = "Tryck J för att dra vapen"}},
                onSelect = function()
                    selectedClutchStyle = "front"
                    lib.notify({
                        title = "Stil vald",
                        description = "Främre midja vald.",
                        type = "success"
                    })
                end
            },
            {
                title = "Ryggsäck",
                icon = "fa-solid fa-gun",
                iconColor = "mediumseagreen",
                description = "Dra vapen från **ryggsäck**.",
                metadata = {{label = "Aktivering", value = "Tryck J för att dra vapen"}},
                onSelect = function()
                    selectedClutchStyle = "backpack"
                    lib.notify({
                        title = "Stil vald",
                        description = "Ryggsäck vald.",
                        type = "success"
                    })
                end
            },
            {
                title = "Bakre midja",
                icon = "fa-solid fa-gun",
                iconColor = "dodgerblue",
                description = "Dra vapen från **bakre midjan**.",
                metadata = {{label = "Aktivering", value = "Tryck J för att dra vapen"}},
                onSelect = function()
                    selectedClutchStyle = "back"
                    lib.notify({
                        title = "Stil vald",
                        description = "Bakre midja vald.",
                        type = "success"
                    })
                end
            },
            {
                title = "Under armen",
                icon = "fa-solid fa-gun",
                iconColor = "darkorange",
                description = "Dra vapen från **under armen**.",
                metadata = {{label = "Aktivering", value = "Tryck J för att dra vapen"}},
                onSelect = function()
                    selectedClutchStyle = "arm"
                    lib.notify({
                        title = "Stil vald",
                        description = "Under armen vald.",
                        type = "success"
                    })
                end
            }
        }
    })
    
    lib.showContext("clutch_menu")
end

function PerformClutchAnimation()
    if not selectedClutchStyle then
        lib.notify({
            title = "Vapendragning",
            description = "Välj en dragstil först med /clutch.",
            type = "error"
        })
        return
    end
    
    if IsJobBlocked() then
        lib.notify({
            title = "Åtkomst nekad",
            description = "Ditt jobb har inte behörighet att göra detta.",
            type = "error"
        })
        return
    end
    
    local playerPed = PlayerPedId()
    local anim = clutchAnimations[selectedClutchStyle]
    local animDict = anim.dict
    local animClip = anim.clip
    
    if isClutchActive then
        ClearPedTasks(playerPed)
        isClutchActive = false
        
        if JF.Clutch.EnableCooldown then
            TriggerServerEvent("jf_weaponclutch:setCooldown")
        end
    else
        local canClutch = true
        
        if JF.Clutch.EnableCooldown then
            canClutch = lib.callback.await("jf_weaponclutch:canClutch", false)
        end
        
        if not canClutch then
            lib.notify({
                title = "Nedkylning",
                description = "Du drar vapen för snabbt. Vänta en stund.",
                type = "error"
            })
            return
        end
        
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
        
        TaskPlayAnim(playerPed, animDict, animClip, 8.0, -8.0, -1, 49, 0.0, false, false, false)
        isClutchActive = true
        
        local description = clutchDescriptions[selectedClutchStyle]
        local style = clutchStyles[selectedClutchStyle]
        
        if description and style then
            lib.notify({
                title = "Vapendragning",
                description = description,
                type = "inform",
                duration = 4000,
                position = "top",
                icon = style.icon,
                iconColor = style.color,
                style = {
                    fontSize = 18,
                    fontFamily = "monospace",
                    color = style.color
                }
            })
        end
        
        local completed = lib.progressBar({
            duration = JF.Clutch.ClutchDuration,
            label = "Drar vapen...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = false,
                combat = true
            }
        })
        
        if not completed then
            ClearPedTasks(playerPed)
            isClutchActive = false
        end
    end
end

function InspectPlayerClutch(data)
    local targetServerId = nil
    
    for _, playerId in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed == data.entity then
            targetServerId = GetPlayerServerId(playerId)
            break
        end
    end
    
    if not targetServerId then
        return
    end
    
    lib.callback("jf_weaponclutch:getClutchingState", false, function(hasWeapon)
        if hasWeapon then
            lib.notify({
                title = "Inspektera vapendragning",
                description = "Det verkar som att de håller ett riktigt vapen.",
                type = "warning",
                icon = "fa-solid fa-gun",
                iconColor = "crimson",
                position = "top",
                duration = 4000
            })
        else
            lib.notify({
                title = "Inspektera vapendragning",
                description = "Det ser ut som att de fejkar...",
                type = "info",
                icon = "fa-solid fa-gun",
                iconColor = "gray",
                position = "top",
                duration = 4000
            })
        end
    end, targetServerId)
end

function ProcessNearbyPedReactions()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    for ped in EnumeratePeds() do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) and not IsPedInAnyVehicle(ped, false) then
            local pedPos = GetEntityCoords(ped)
            local distance = #(pedPos - playerPos)
            
            if distance <= 2.0 and not IsPedFleeing(ped) then
                local reactionChance = math.random(1, 100)
                
                if reactionChance <= 40 then
                    TaskSmartFleePed(ped, playerPed, 50.0, -1, false, false)
                elseif reactionChance <= 70 then
                    TaskCower(ped, 5000)
                else
                    RequestAnimDict("random@arrests")
                    while not HasAnimDictLoaded("random@arrests") do
                        Wait(0)
                    end
                    TaskPlayAnim(ped, "random@arrests", "idle_2_hands_up", 8.0, -8.0, 5000, 49, 0, false, false, false)
                end
                
                local fearVoiceLines = {
                    "GENERIC_FRIGHTENED_HIGH",
                    "GENERIC_CURSE_HIGH",
                    "GENERIC_SHOCKED_HIGH",
                    "GENERIC_FRIGHTENED_MED",
                    "GENERIC_SHOCKED_MED",
                    "GENERIC_WHATEVER"
                }
                
                PlayAmbientSpeech1(ped, fearVoiceLines[math.random(#fearVoiceLines)], "SPEECH_PARAjf_FORCE")
            end
        end
    end
end

RegisterCommand("vapendragning", ShowClutchMenu)

RegisterKeyMapping("toggleClutchAnim", "Växla vapendragning", "keyboard", "J")

RegisterCommand("toggleClutchAnim", PerformClutchAnimation, false)

exports.ox_target:addGlobalPlayer({
    label = "Inspektera vapendragning",
    icon = "fa-solid fa-gun",
    iconColor = "goldenrod",
    onSelect = InspectPlayerClutch
})

CreateThread(function()
    while true do
        Wait(750)
        
        local playerPed = PlayerPedId()
        
        if not IsPedOnFoot(playerPed) or IsPedDeadOrDying(playerPed) then
            Wait(2000)
            goto continue
        end
        
        if not IsPlayerClutching() then
            Wait(1000)
        else
            ProcessNearbyPedReactions()
        end
        
        ::continue::
    end
end)