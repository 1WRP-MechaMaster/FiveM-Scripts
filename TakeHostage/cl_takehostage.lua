-----------------------------------------------------------------
--TakeHostage by Robbster, modified for ox_target integration
------------------------------------------------------------------

local Config = require 'config'
local takeHostage = {
    InProgress = false,
    type = "",
    targetSrc = -1,
    lastHostageTime = 0,
    agressor = {
        animDict = "anim@gangops@hostage@",
        anim = "perp_idle",
        flag = 49,
    },
    hostage = {
        animDict = "anim@gangops@hostage@",
        anim = "victim_idle",
        attachX = -0.24,
        attachY = 0.11,
        attachZ = 0.0,
        flag = 49,
    }
}

local function showNotification(text)
    if Config.NotificationType == "help" then
        SetTextComponentFormat("STRING")
        AddTextComponentString(text)
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
    elseif Config.NotificationType == "notification" then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    elseif Config.NotificationType == "chat" then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Take Hostage", text}
        })
    elseif Config.NotificationType == "custom" then
        -- You can add your custom notification system here
        -- Example (Mythic): exports['mythic_notify']:SendAlert('inform', text)
        -- Example (ESX): ESX.ShowNotification(text)
        -- Example (QBCore): TriggerEvent('QBCore:Notify', text, 'primary')
    end
end


local function drawNativeText(str)
    SetTextEntry_2("STRING")
    AddTextComponentString(str)
    EndTextCommandPrint(1000, 1)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

local function canTakeHostage()
    if GetGameTimer() - takeHostage.lastHostageTime < Config.Cooldown then
        local timeLeft = math.ceil((Config.Cooldown - (GetGameTimer() - takeHostage.lastHostageTime)) / 1000)
        showNotification("You need to wait " .. timeLeft .. " seconds before taking another hostage.")
        return false
    end

    local hasValidWeapon = false
    local foundWeapon
    
    for i = 1, #Config.AllowedWeapons do
        if HasPedGotWeapon(PlayerPedId(), Config.AllowedWeapons[i], false) then
            if GetAmmoInPedWeapon(PlayerPedId(), Config.AllowedWeapons[i]) > 0 then
                hasValidWeapon = true 
                foundWeapon = Config.AllowedWeapons[i]
                break
            end                     
        end
    end

    if not hasValidWeapon then 
        showNotification("You need a pistol with ammo to take a hostage at gunpoint!")
        return false
    end
    
    return true, foundWeapon
end

local function initiateHostageTaking(targetId)
    if takeHostage.InProgress then 
        return
    end
    
    local canTake, foundWeapon = canTakeHostage()
    if not canTake then
        return
    end
    
    local targetSrc = GetPlayerServerId(targetId)
    if targetSrc ~= -1 then
        SetCurrentPedWeapon(PlayerPedId(), foundWeapon, true)
        takeHostage.InProgress = true
        takeHostage.targetSrc = targetSrc
        takeHostage.lastHostageTime = GetGameTimer()
        TriggerServerEvent("TakeHostage:sync", targetSrc)
        ensureAnimDict(takeHostage.agressor.animDict)
        takeHostage.type = "agressor"
    else
        showNotification("~r~No one nearby to take as hostage!")
    end
end

if Config.UseCommands then
    RegisterCommand(Config.Commands.TakeHostage, function()
        if takeHostage.InProgress then return end
        
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        
        local closestPlayer = GetClosestPlayer(Config.InteractionDistance)
        if closestPlayer then
            initiateHostageTaking(closestPlayer)
        else
            showNotification("~r~No one nearby to take as hostage!")
        end
    end)

    RegisterCommand(Config.Commands.TakeHostageShort, function()
        ExecuteCommand(Config.Commands.TakeHostage)
    end)
end

if Config.UseOxTarget and GetResourceState('ox_target') == 'started' then
    exports.ox_target:addGlobalPlayer({
        {
            name = 'take_hostage',
            icon = Config.OxTarget.Icon,
            label = Config.OxTarget.Label,
            distance = Config.OxTarget.Distance,
            canInteract = function(entity, distance, coords, name)
                if takeHostage.InProgress then return false end
                if IsPedDeadOrDying(entity, true) then return false end
                
                local canTake, _ = canTakeHostage()
                return canTake
            end,
            onSelect = function(data)
                ClearPedSecondaryTask(PlayerPedId())
                DetachEntity(PlayerPedId(), true, false)
                
                local targetId = GetPlayerIdFromPed(data.entity)
                if targetId then
                    initiateHostageTaking(targetId)
                else
                    showNotification("~r~Cannot take this person as hostage!")
                end
            end
        }
    })
end

function GetPlayerIdFromPed(ped)
    for _, id in ipairs(GetActivePlayers()) do
        if GetPlayerPed(id) == ped then
            return id
        end
    end
    return nil
end

RegisterNetEvent("TakeHostage:syncTarget")
AddEventHandler("TakeHostage:syncTarget", function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    takeHostage.InProgress = true
    ensureAnimDict(takeHostage.hostage.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
    takeHostage.type = "hostage" 
end)

RegisterNetEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function()
    takeHostage.InProgress = false 
    takeHostage.type = ""
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("reaction@shove")
    TaskPlayAnim(PlayerPedId(), "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(250)
    ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function()
    takeHostage.InProgress = false 
    takeHostage.type = ""
    SetEntityHealth(PlayerPedId(), 0)
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("anim@gangops@hostage@")
    TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("TakeHostage:cl_stop")
AddEventHandler("TakeHostage:cl_stop", function()
    takeHostage.InProgress = false
    takeHostage.type = "" 
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
    while true do
        if takeHostage.type == "agressor" then
            if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
                TaskPlayAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
            end
        elseif takeHostage.type == "hostage" then
            if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
                TaskPlayAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do 
        if takeHostage.type == "agressor" then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisableControlAction(0, 21, true)
            DisablePlayerFiring(PlayerPedId(), true)
            
            local releaseText = Config.EnableReleaseOption and "[G] to release" or ""
            local killText = Config.EnableKillOption and "[H] to kill" or ""
            local separator = (Config.EnableReleaseOption and Config.EnableKillOption) and ", " or ""
            
            drawNativeText("Press " .. releaseText .. separator .. killText)

            if IsEntityDead(PlayerPedId()) then    
                takeHostage.type = ""
                takeHostage.InProgress = false
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
            end 

            if Config.EnableReleaseOption and IsDisabledControlJustPressed(0, Config.ReleaseKey) then
                takeHostage.type = ""
                takeHostage.InProgress = false 
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
            elseif Config.EnableKillOption and IsDisabledControlJustPressed(0, Config.KillKey) then
                takeHostage.type = ""
                takeHostage.InProgress = false         
                ensureAnimDict("anim@gangops@hostage@")
                TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:killHostage", takeHostage.targetSrc)
                TriggerServerEvent("TakeHostage:stop", takeHostage.targetSrc)
                Wait(100)
                SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0)
            end
        elseif takeHostage.type == "hostage" then 
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(27, 75, true)  
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 268, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 269, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 270, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 271, true)
        end
        Wait(0)
    end
end)
