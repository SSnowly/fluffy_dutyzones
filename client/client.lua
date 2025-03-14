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
local state = false
CreateThread(function()
    for _, zone in pairs(Config.Zones) do
        zones[zone.job] = {}
        zones[zone.job].zone = lib.zones.poly({
            points = zone.zone.points,
            thickness = zone.zone.thickness,
            debug = Config.Debug,
            onExit = function() ExitJobZone(zone.job) end
        })
        local point = lib.points.new({
            coords = zone.duty.coords,
            distance = zone.duty.distance,
        })
        function point:nearby()
            DrawMarker(zone.duty.marker.type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, zone.duty.marker.red, zone.duty.marker.green, zone.duty.marker.blue, zone.duty.marker.opacity, false, true, 2, false, nil, nil, false)
            if self.currentDistance < 1.5 then
                if not lib.isTextUIOpen() then
                    lib.showTextUI('[E] Toggle Duty')
                end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('QBCore:ToggleDuty')
                end
            end
            if self.currentDistance > 1.5 then
                lib.hideTextUI()
            end
        end
        zones[zone.job].duty = point
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, zone in pairs(zones) do
            zone.zone:remove()
            zone.duty:remove()
        end
    end
end)
