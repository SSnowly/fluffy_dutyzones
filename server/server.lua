local Config = require 'config'
local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:ToggleDuty', function()
    local src = source
    local job = QBCore.Functions.GetPlayer(src).PlayerData.job
    local dutyState = not job.onduty
    local count = exports.qbx_core:GetDutyCountJob(job.name)
    if dutyState then
        count = count + 1
    else
        count = count - 1
    end
    print(job.name, count, dutyState)
    if dutyState then
        TriggerClientEvent('fluffy-dutyzones:client:AddDutyToJob', -1, job.name, count)
    elseif not dutyState then
        TriggerClientEvent('fluffy-dutyzones:client:RemoveDutyFromJob', -1, job.name, count)
    end
end)
