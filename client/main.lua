--[[ ===================================================== ]]--
--[[          CLIENT MAIN LOGIC (FIXED & OPTIMIZED)       ]]--
--[[ ===================================================== ]]--

local isMenuOpen = false
local vehicleData = {}
local playerCache = {}
local isAdmin = false
local nuiFocusActive = false
local controlThread = nil

--[[ ===================================================== ]]--
--[[              CACHE SYSTEM (OTIMIZADO)                 ]]--
--[[ ===================================================== ]]--

function GetFromCache(key)
    if not Config.Cache.enabled then return nil end
    
    local cached = playerCache[key]
    if cached and cached.expires > GetGameTimer() then
        return cached.data
    end
    
    return nil
end

function SetCache(key, data)
    if not Config.Cache.enabled then return end
    
    playerCache[key] = {
        data = data,
        expires = GetGameTimer() + (Config.Cache.clientTTL * 1000)
    }
end

function ClearCache()
    playerCache = {}
end

-- Cache Cleanup Thread (otimização FASE 2)
CreateThread(function()
    while true do
        Wait(Config.Cache.cleanupInterval * 1000)
        
        if not Config.Cache.enabled then
            goto continue
        end
        
        local now = GetGameTimer()
        local cleaned = 0
        
        for key, cached in pairs(playerCache) do
            if cached.expires < now then
                playerCache[key] = nil
                cleaned = cleaned + 1
            end
        end
        
        if Config.Debug and cleaned > 0 then
            print('^3[VehicleImages]^7 Client cleaned ' .. cleaned .. ' expired cache entries')
        end
        
        ::continue::
    end
end)

--[[ ===================================================== ]]--
--[[                  NUI CALLBACKS                         ]]--
--[[ ===================================================== ]]--

RegisterNUICallback('close', function(data, cb)
    if nuiFocusActive then
        SetNuiFocus(false, false)
        nuiFocusActive = false
    end
    isMenuOpen = false
    SendNUIMessage({
        action = 'hide'
    })
    cb({status = 'ok'})
end)

RegisterNUICallback('getVehicles', function(data, cb)
    TriggerServerEvent('vehicleimages:requestData')
    cb({status = 'ok'})
end)

RegisterNUICallback('addVehicle', function(data, cb)
    if not isAdmin then
        ShowNotification('error', Config.Translate('error_permission'))
        cb({status = 'error'})
        return
    end
    
    TriggerServerEvent('vehicleimages:addVehicle', {
        name = data.model,
        url = data.url,
        category = data.category or 'other',
        custom = data.custom or false
    })
    
    cb({status = 'ok'})
end)

RegisterNUICallback('updateVehicle', function(data, cb)
    if not isAdmin then
        ShowNotification('error', Config.Translate('error_permission'))
        cb({status = 'error'})
        return
    end
    
    TriggerServerEvent('vehicleimages:updateVehicle', data.model, {
        url = data.url,
        category = data.category,
        custom = data.custom
    })
    
    cb({status = 'ok'})
end)

RegisterNUICallback('deleteVehicle', function(data, cb)
    if not isAdmin then
        ShowNotification('error', Config.Translate('error_permission'))
        cb({status = 'error'})
        return
    end
    
    TriggerServerEvent('vehicleimages:deleteVehicle', data.model)
    
    cb({status = 'ok'})
end)

RegisterNUICallback('searchVehicles', function(data, cb)
    TriggerServerEvent('vehicleimages:searchVehicles', data.query)
    cb({status = 'ok'})
end)

RegisterNUICallback('getByCategory', function(data, cb)
    TriggerServerEvent('vehicleimages:getByCategory', data.category)
    cb({status = 'ok'})
end)

RegisterNUICallback('importData', function(data, cb)
    if not isAdmin then
        ShowNotification('error', Config.Translate('error_permission'))
        cb({status = 'error'})
        return
    end
    
    TriggerServerEvent('vehicleimages:importData', data.data, data.overwrite)
    
    cb({status = 'ok'})
end)

RegisterNUICallback('exportData', function(data, cb)
    if not isAdmin then
        ShowNotification('error', Config.Translate('error_permission'))
        cb({status = 'error'})
        return
    end
    
    TriggerServerEvent('vehicleimages:exportData')
    
    cb({status = 'ok'})
end)

RegisterNUICallback('playSound', function(data, cb)
    PlaySoundFrontend(-1, data.sound or 'SELECT', data.soundSet or 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    cb({status = 'ok'})
end)

--[[ ===================================================== ]]--
--[[                  EVENTOS DO SERVIDOR                   ]]--
--[[ ===================================================== ]]--

RegisterNetEvent('vehicleimages:receiveData', function(data)
    vehicleData = data.vehicles or {}
    isAdmin = data.isAdmin or false
    
    SendNUIMessage({
        action = 'loadData',
        data = {
            vehicles = vehicleData,
            stats = data.stats,
            isAdmin = isAdmin,
            config = data.config
        }
    })
    
    -- Atualizar estado global (CORREÇÃO FASE 1.5)
    _G.VehicleImagesState = {
        vehicleData = vehicleData,
        playerCache = playerCache,
        isAdmin = isAdmin,
        isMenuOpen = isMenuOpen
    }
end)

RegisterNetEvent('vehicleimages:receiveImage', function(model, url)
    local cacheKey = 'image_' .. string.lower(model)
    SetCache(cacheKey, url)
    
    SendNUIMessage({
        action = 'receiveImage',
        model = model,
        url = url
    })
end)

RegisterNetEvent('vehicleimages:vehicleAdded', function(vehicle)
    SendNUIMessage({
        action = 'vehicleAdded',
        vehicle = vehicle
    })
end)

RegisterNetEvent('vehicleimages:vehicleUpdated', function(model, vehicle)
    SendNUIMessage({
        action = 'vehicleUpdated',
        model = model,
        vehicle = vehicle
    })
    
    local cacheKey = 'image_' .. string.lower(model)
    playerCache[cacheKey] = nil
end)

RegisterNetEvent('vehicleimages:vehicleDeleted', function(model)
    SendNUIMessage({
        action = 'vehicleDeleted',
        model = model
    })
    
    local cacheKey = 'image_' .. string.lower(model)
    playerCache[cacheKey] = nil
end)

RegisterNetEvent('vehicleimages:receiveSearchResults', function(results)
    SendNUIMessage({
        action = 'searchResults',
        results = results
    })
end)

RegisterNetEvent('vehicleimages:receiveCategoryResults', function(results)
    SendNUIMessage({
        action = 'categoryResults',
        results = results
    })
end)

RegisterNetEvent('vehicleimages:receiveExport', function(data)
    SendNUIMessage({
        action = 'exportData',
        data = data
    })
end)

RegisterNetEvent('vehicleimages:dataImported', function()
    TriggerServerEvent('vehicleimages:requestData')
end)

RegisterNetEvent('vehicleimages:dataReloaded', function()
    TriggerServerEvent('vehicleimages:requestData')
    ShowNotification('success', 'Database reloaded!')
end)

RegisterNetEvent('vehicleimages:clearCache', function()
    ClearCache()
end)

RegisterNetEvent('vehicleimages:showNotification', function(data)
    ShowNotification(data.type, data.message)
end)

RegisterNetEvent('vehicleimages:openMenu', function()
    OpenMenu()
end)

RegisterNetEvent('vehicleimages:showPreview', function(vehicle)
    SendNUIMessage({
        action = 'showPreview',
        vehicle = vehicle
    })
end)

RegisterNetEvent('vehicleimages:openImport', function()
    OpenMenu()
    SendNUIMessage({
        action = 'openImport'
    })
end)

--[[ ===================================================== ]]--
--[[                  FUNÇÕES AUXILIARES                    ]]--
--[[ ===================================================== ]]--

function OpenMenu()
    if isMenuOpen then return end
    
    isMenuOpen = true
    nuiFocusActive = true
    SetNuiFocus(true, true)
    
    TriggerServerEvent('vehicleimages:requestData')
    
    SendNUIMessage({
        action = 'show'
    })
    
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    
    -- Iniciar thread de controles (CORREÇÃO FASE 1.2)
    if not controlThread then
        controlThread = CreateThread(function()
            while isMenuOpen do
                Wait(0)
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 18, true)
                DisableControlAction(0, 322, true)
                DisableControlAction(0, 106, true)
            end
            controlThread = nil
        end)
    end
end

function CloseMenu()
    if not isMenuOpen then return end
    
    isMenuOpen = false
    nuiFocusActive = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'hide'
    })
    
    PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

function ShowNotification(type, message)
    if Framework and Framework.Type == 'esx' then
        Framework.ShowNotification(nil, message, type)
    elseif Config.Notifications.enabled then
        SendNUIMessage({
            action = 'notification',
            type = type,
            message = message,
            duration = Config.Notifications.duration,
            position = Config.Notifications.position
        })
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

--[[ ===================================================== ]]--
--[[                  EVENTOS DE TECLAS                     ]]--
--[[ ===================================================== ]]--

CreateThread(function()
    while true do
        Wait(0)
        
        if IsControlJustPressed(0, 322) and isMenuOpen then
            CloseMenu()
        end
    end
end)

--[[ ===================================================== ]]--
--[[                  INICIALIZAÇÃO                        ]]--
--[[ ===================================================== ]]--

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        TriggerServerEvent('vehicleimages:requestData')
        
        if Config.Debug then
            print('^2[VehicleImages]^7 Client started successfully!')
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isMenuOpen then
            CloseMenu()
        end
        
        ClearCache()
        
        if Config.Debug then
            print('^3[VehicleImages]^7 Client stopped.')
        end
    end
end)

--[[ ===================================================== ]]--
--[[                  DEBUGGING                             ]]--
--[[ ===================================================== ]]--

if Config.Debug then
    RegisterCommand('vehtest', function(source, args)
        if args[1] then
            local model = args[1]
            TriggerServerEvent('vehicleimages:getImage', model)
        else
            print('Usage: /vehtest [model]')
        end
    end, false)
    
    RegisterCommand('vehcache', function()
        print('=== CACHE STATUS ===')
        local count = 0
        for k, v in pairs(playerCache) do
            count = count + 1
            print(string.format('%s: expires in %d ms', k, v.expires - GetGameTimer()))
        end
        print(string.format('Total cached items: %d', count))
    end, false)
    
    RegisterCommand('vehclear', function()
        ClearCache()
        print('Cache cleared!')
    end, false)
end