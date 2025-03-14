local Config = require 'config'
local QBCore = exports['qb-core']:GetCoreObject()
local zones = {}
local function isJob(job)
    return QBCore.Functions.GetPlayerData().job.name == job
end

local function IsOnDuty(job)
    return QBCore.Functions.GetPlayerData().job.name == job and QBCore.Functions.GetPlayerData().job.onduty
end

function ExitJobZone(job)
    if not isJob(job) then return end
    local onDuty = IsOnDuty(job)
    if not onDuty then return end
    TriggerServerEvent('QBCore:ToggleDuty')
end

CreateThread(function()
    for _, zone in pairs(Config.Zones) do
        zones[zone.job] = lib.zones.poly({
            points = zone.zone.points,
            thickness = zone.zone.thickness,
            debug = Config.Debug,
            onExit = function() ExitJobZone(zone.job) end,
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, zone in pairs(zones) do
            zone:remove()
        end
    end
end)
