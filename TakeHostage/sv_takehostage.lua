-----------------------------------------------------------------
--TakeHostage Server Script, modified for config integration
------------------------------------------------------------------

local Config = require 'config'

local takingHostage = {}
local takenHostage = {}

RegisterServerEvent("TakeHostage:sync")
AddEventHandler("TakeHostage:sync", function(targetSrc)
    local source = source

    if not targetSrc or not DoesPlayerExist(targetSrc) then
        return
    end

    if takingHostage[source] or takenHostage[source] or takingHostage[targetSrc] or takenHostage[targetSrc] then
        return
    end

    TriggerClientEvent("TakeHostage:syncTarget", targetSrc, source)
    takingHostage[source] = targetSrc
    takenHostage[targetSrc] = source
end)

RegisterServerEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function(targetSrc)
    local source = source
    
    if takenHostage[targetSrc] and takenHostage[targetSrc] == source then 
        TriggerClientEvent("TakeHostage:releaseHostage", targetSrc, source)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    end
end)

RegisterServerEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function(targetSrc)
    local source = source
    
    if takenHostage[targetSrc] and takenHostage[targetSrc] == source then 
        TriggerClientEvent("TakeHostage:killHostage", targetSrc, source)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    end
end)

RegisterServerEvent("TakeHostage:stop")
AddEventHandler("TakeHostage:stop", function(targetSrc)
    local source = source

    if takingHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takingHostage[source])
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    elseif takenHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takenHostage[source])
        takenHostage[source] = nil
        takingHostage[targetSrc] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if takingHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takingHostage[source])
        takenHostage[takingHostage[source]] = nil
        takingHostage[source] = nil
    end

    if takenHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takenHostage[source])
        takingHostage[takenHostage[source]] = nil
        takenHostage[source] = nil
    end
end)

function DoesPlayerExist(playerId)
    if playerId and playerId > 0 and GetPlayerPing(playerId) > 0 then
        return true
    end
    return false
end
