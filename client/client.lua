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

local function CreateJobBlip(job)
    local zone = nil
    print(zone, job)
    for _, zoneData in pairs(Config.Zones) do
        print(zoneData.job, job)
        if zoneData.job == job then
            zone = zoneData
            break
        end
    end
    print(zone, job)
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
    for _, zone in pairs(Config.Zones) do
        zones[zone.job] = {}
        zones[zone.job].zone = lib.zones.poly({
            points = zone.zone.points,
            thickness = zone.zone.thickness,
            debug = Config.Debug,
            onExit = function() ExitJobZone(zone.job) end
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
            zones[zone.job].duty = id
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
            zones[zone.job].duty = point
        end
        if not zone.blip.DutyRequired then
            zones[zone.job].blip = CreateJobBlip(zone.job)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    for job, data in pairs(zones) do
        if JobInfo.name == job then
            if data.blip then
                RemoveBlip(data.blip)
                data.blip = nil
            end
            local zoneConfig = nil
            for _, zone in pairs(Config.Zones) do
                if zone.job == job then
                    zoneConfig = zone
                    break
                end
            end
            if zoneConfig and zoneConfig.blip.enabled and zoneConfig.blip.DutyRequired and JobInfo.onduty then
                data.blip = CreateJobBlip(zoneConfig)
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job then
        for _, zone in pairs(Config.Zones) do
            if zone.job == PlayerData.job.name and zone.blip.enabled and zone.blip.DutyRequired and PlayerData.job.onduty then
                zones[zone.job].blip = CreateJobBlip(zone)
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
    zones[job].blip = CreateJobBlip(job)
end)

RegisterNetEvent('fluffy-dutyzones:client:RemoveDutyFromJob', function(job, count)
    if count > 0 or not zones[job] then return end
    RemoveBlip(zones[job].blip)
    zones[job].blip = nil
end)
