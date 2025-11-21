local playerCooldowns = {}

lib.callback.register("jf_weaponclutch:canClutch", function(source)
    if not JF.Clutch.EnableCooldown then
        return true
    end
    
    local currentTime = GetGameTimer()
    local cooldownDuration = JF.Clutch.CooldownTime or 3000
    local lastClutchTime = playerCooldowns[source]
    
    if lastClutchTime then
        local timeSinceLastClutch = currentTime - lastClutchTime
        if cooldownDuration > timeSinceLastClutch then
            return false
        end
    end
    
    return true
end)

RegisterNetEvent("jf_weaponclutch:setCooldown", function()
    if not JF.Clutch.EnableCooldown then
        return
    end
    
    local playerId = source
    playerCooldowns[playerId] = GetGameTimer()
end)

lib.callback.register("jf_weaponclutch:getClutchingState", function(source, targetServerId)
    local targetPed = GetPlayerPed(targetServerId)
    
    if not targetPed or targetPed == 0 then
        return false
    end
    
    local currentWeapon = GetSelectedPedWeapon(targetPed)
    local unarmedHash = -1569615261
    
    return currentWeapon and currentWeapon ~= unarmedHash
end)

AddEventHandler("playerDropped", function()
    local playerId = source
    playerCooldowns[playerId] = nil
end)