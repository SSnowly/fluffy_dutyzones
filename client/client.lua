local Config = require 'config'
local QBCore = exports['qb-core']:GetCoreObject()
local zones = {}

local function isJob(job)
    return QBCore.Functions.GetPlayerData().job.name == job
end

local function isOnDuty(job)
    return QBCore.Functions.GetPlayerData().job.name == job and QBCore.Functions.GetPlayerData().job.onduty
end

local function exitJobZone(job)
    if not isJob(job) then return end
    local onDuty = isOnDuty(job)
    if not onDuty then return end
    TriggerServerEvent('QBCore:ToggleDuty')
end

local function createJobBlip(job)
    local zone = Config.Zones[job]
    if not zone.blip.enabled then return end
    local blip = AddBlipForCoord(zone.blip.coords.x, zone.blip.coords.y, zone.blip.coords.z)
    SetBlipSprite(blip, zone.blip.sprite)
    SetBlipDisplay(blip, zone.blip.display)
    SetBlipScale(blip, zone.blip.scale)
    SetBlipColour(blip, zone.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(zone.blip.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

CreateThread(function()
    for job, zone in pairs(Config.Zones) do
        zones[job] = {}
        zones[job].zone = lib.zones.poly({
            points = zone.zone.points,
            thickness = zone.zone.thickness,
            debug = Config.Debug,
            onExit = function() exitJobZone(job) end
        })
        if not zone.duty then return end
        if zone.duty.useTarget then
            local id = exports.ox_target:addSphereZone({
                coords = zone.duty.coords,
                radius = zone.duty.distance,
                options = {
                    {
                        label = 'Toggle Duty',
                        onSelect = function()
                            TriggerServerEvent('QBCore:ToggleDuty')
                        end
                    }
                }
            })
            zones[job].duty = id
        else
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
            zones[job].duty = point
        end
        if not zone.blip.DutyRequired then
            zones[job].blip = createJobBlip(job)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local zone = zones[JobInfo.name]
    if zone then
        if zone.blip then
            RemoveBlip(zone.blip)
            zone.blip = nil
        end
        local zoneConfig = Config.Zones[JobInfo.name]
        if zoneConfig and zoneConfig.blip.enabled and zoneConfig.blip.DutyRequired and JobInfo.onduty then
            zone.blip = createJobBlip(JobInfo.name)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job then
        local zone = Config.Zones[PlayerData.job.name]
        if zone then
            if zone.blip.enabled and zone.blip.DutyRequired and PlayerData.job.onduty then
                zones[PlayerData.job.name].blip = createJobBlip(PlayerData.job.name)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, zone in pairs(zones) do
            zone.zone:remove()
            if zone.blip then
                RemoveBlip(zone.blip)
            end
            if type(zone.duty) == 'number' then
                exports.ox_target:removeZone(zone.duty)
            else
                zone.duty:remove()
            end
        end
    end
end)


RegisterNetEvent('fluffy-dutyzones:client:AddDutyToJob', function(job, count)
    if count < 1 or not zones[job] then return end
    zones[job].blip = createJobBlip(job)
end)

RegisterNetEvent('fluffy-dutyzones:client:RemoveDutyFromJob', function(job, count)
    if count > 0 or not zones[job] then return end
    RemoveBlip(zones[job].blip)
    zones[job].blip = nil
end)
