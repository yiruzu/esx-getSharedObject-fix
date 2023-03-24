ESX = {}
ESX.Players = {}
ESX.Jobs = {}
ESX.Items = {}
Core = {}
Core.UsableItemsCallbacks = {}
Core.ServerCallbacks = {}
Core.ClientCallbacks = {}
Core.CurrentRequestId = 0
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0
Core.PlayerFunctionOverrides = {}

Core.playersByIdentifier = {}

AddEventHandler("esx:getSharedObject", function(cb)
    cb(ESX) 
end)

exports('getSharedObject', function()
  return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
  Config.OxInventory = true
  Config.PlayerFunctionOverride = 'OxInventory'
  SetConvarReplicated('inventory:framework', 'esx')
  SetConvarReplicated('inventory:weight', Config.MaxWeight * 1000)
end

local function StartDBSync()
  CreateThread(function()
    while true do
      Wait(10 * 60 * 1000)
      Core.SavePlayers()
    end
  end)
end

MySQL.ready(function()
  if not Config.OxInventory then
    local items = MySQL.query.await('SELECT * FROM items')
    for k, v in ipairs(items) do
      ESX.Items[v.name] = {label = v.label, weight = v.weight, rare = v.rare, canRemove = v.can_remove}
    end
  else
    TriggerEvent('__cfx_export_ox_inventory_Items', function(ref)
      if ref then
        ESX.Items = ref()
      end
    end)

    AddEventHandler('ox_inventory:itemList', function(items)
      ESX.Items = items
    end)

    while not next(ESX.Items) do
      Wait(0)
    end
  end

  local Jobs = {}
  local jobs = MySQL.query.await('SELECT * FROM jobs')

  for _, v in ipairs(jobs) do
    Jobs[v.name] = v
    Jobs[v.name].grades = {}
  end

  local jobGrades = MySQL.query.await('SELECT * FROM job_grades')

  for _, v in ipairs(jobGrades) do
    if Jobs[v.job_name] then
      Jobs[v.job_name].grades[tostring(v.grade)] = v
    else
      print(('[^3WARNING^7] ESX ^5Legacy^0 job %s does not exist'):format(v.job_name))
    end
  end

  ESX.Jobs = Jobs
  ESX.RefreshJobs()

  print(('[^2INFO^7] ESX ^5Legacy %s^0 initialized!'):format(GetResourceMetadata(GetCurrentResourceName(), "version", 0)))
    
  StartDBSync()
  if Config.EnablePaycheck then
		StartPayCheck()
	end
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
  if Config.EnableDebug then
    print(('[^2TRACE^7] %s^7'):format(msg))
  end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId,Invoke, ...)
  local source = source

  ESX.TriggerServerCallback(name, requestId, source,Invoke, function(...)
    TriggerClientEvent('esx:serverCallback', source, requestId,Invoke, ...)
  end, ...)
end)

RegisterNetEvent("esx:ReturnVehicleType", function(Type, Request)
  if Core.ClientCallbacks[Request] then
    Core.ClientCallbacks[Request](Type)
    Core.ClientCallbacks[Request] = nil
  end
end)