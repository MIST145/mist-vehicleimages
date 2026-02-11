local cooldowns = {}

local function CheckCooldown(source, action, seconds)
    if not Config.RateLimits.enabled then
        return true
    end

    local key = source .. '_' .. action
    local now = os.time()

    if cooldowns[key] and (now - cooldowns[key]) < seconds then
        return false, (seconds - (now - cooldowns[key]))
    end

    cooldowns[key] = now
    return true
end

RegisterNetEvent('vehicleimages:requestData', function()
    local source = source
    local canView = Config.AllowPublicView or Framework.IsAdmin(source)

    if not canView then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local data = VehicleDatabase.GetAll()
    local stats = VehicleDatabase.GetStats()
    local isAdmin = Framework.IsAdmin(source)

    TriggerClientEvent('vehicleimages:receiveData', source, {
        vehicles = data,
        stats = stats,
        isAdmin = isAdmin,
        config = {
            categories = Config.Categories,
            ui = Config.UI,
            placeholder = Config.Images.placeholder,
            translations = Config.Translations[Config.Language]
        }
    })
end)

RegisterNetEvent('vehicleimages:getImage', function(model)
    local source = source

    if not model then
        return
    end

    local cacheKey = 'image_' .. string.lower(model)
    local cached = VehicleDatabase.GetFromCache(cacheKey)

    if cached then
        TriggerClientEvent('vehicleimages:receiveImage', source, model, cached)
        return
    end

    local vehicle = VehicleDatabase.GetByModel(model)
    local imageUrl = vehicle and vehicle.url or Config.Images.placeholder

    VehicleDatabase.SetCache(cacheKey, imageUrl)

    TriggerClientEvent('vehicleimages:receiveImage', source, model, imageUrl)
end)

RegisterNetEvent('vehicleimages:addVehicle', function(data)
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local canProceed, remaining = CheckCooldown(source, 'addVehicle', Config.RateLimits.addVehicle)
    if not canProceed then
        Framework.ShowNotification(source, Config.Translate('error_ratelimit', remaining), 'warning')
        return
    end

    data.name = VehicleDatabase.SanitizeString(data.name)
    data.url = VehicleDatabase.SanitizeString(data.url)

    data.addedBy = Framework.GetPlayerName(source)

    local success, result = VehicleDatabase.Add(data)

    if success then
        Logger.LogPlayerAction(source, 'add', result)

        Framework.ShowNotification(source, Config.Translate('success_add'), 'success')

        TriggerClientEvent('vehicleimages:vehicleAdded', -1, result)
        TriggerClientEvent('vehicleimages:requestData', source)
    else
        local errorMsg = result == 'exists' and Config.Translate('error_exists') or Config.Translate('error_load')
        Framework.ShowNotification(source, errorMsg, 'error')
    end
end)

RegisterNetEvent('vehicleimages:updateVehicle', function(model, data)
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local canProceed, remaining = CheckCooldown(source, 'editVehicle', Config.RateLimits.editVehicle)
    if not canProceed then
        Framework.ShowNotification(source, Config.Translate('error_ratelimit', remaining), 'warning')
        return
    end

    if data.url then
        data.url = VehicleDatabase.SanitizeString(data.url)
    end

    data.editedBy = Framework.GetPlayerName(source)

    local success, result = VehicleDatabase.Update(model, data)

    if success then
        Logger.LogPlayerAction(source, 'edit', result)

        Framework.ShowNotification(source, Config.Translate('success_edit'), 'success')

        TriggerClientEvent('vehicleimages:vehicleUpdated', -1, model, result)
        TriggerClientEvent('vehicleimages:requestData', source)
    else
        Framework.ShowNotification(source, Config.Translate('error_load'), 'error')
    end
end)

RegisterNetEvent('vehicleimages:deleteVehicle', function(model)
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local canProceed, remaining = CheckCooldown(source, 'deleteVehicle', Config.RateLimits.deleteVehicle)
    if not canProceed then
        Framework.ShowNotification(source, Config.Translate('error_ratelimit', remaining), 'warning')
        return
    end

    local success = VehicleDatabase.Delete(model)

    if success then
        Logger.LogPlayerAction(source, 'delete', {model = model})

        Framework.ShowNotification(source, Config.Translate('success_delete'), 'success')

        TriggerClientEvent('vehicleimages:vehicleDeleted', -1, model)
        TriggerClientEvent('vehicleimages:requestData', source)
    else
        Framework.ShowNotification(source, Config.Translate('error_load'), 'error')
    end
end)

RegisterNetEvent('vehicleimages:importData', function(data, overwrite)
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local success, count = VehicleDatabase.Import(data, overwrite)

    if success then
        Logger.LogPlayerAction(source, 'import', {count = count, overwrite = overwrite})

        Framework.ShowNotification(source, Config.Translate('success_import'), 'success')

        TriggerClientEvent('vehicleimages:dataImported', -1)
        TriggerClientEvent('vehicleimages:requestData', source)
    else
        Framework.ShowNotification(source, Config.Translate('error_load'), 'error')
    end
end)

RegisterNetEvent('vehicleimages:exportData', function()
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local data = VehicleDatabase.Export()

    Logger.LogPlayerAction(source, 'export', {count = #data.pictures})

    TriggerClientEvent('vehicleimages:receiveExport', source, data)

    Framework.ShowNotification(source, Config.Translate('success_export'), 'success')
end)

RegisterNetEvent('vehicleimages:searchVehicles', function(query)
    local source = source

    local results = VehicleDatabase.Search(query)

    TriggerClientEvent('vehicleimages:receiveSearchResults', source, results)
end)

RegisterNetEvent('vehicleimages:getByCategory', function(category)
    local source = source

    local results = VehicleDatabase.GetByCategory(category)

    TriggerClientEvent('vehicleimages:receiveCategoryResults', source, results)
end)

RegisterNetEvent('vehicleimages:reloadDatabase', function()
    local source = source

    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    VehicleDatabase.Initialize()

    Logger.LogPlayerAction(source, 'reload', {})

    Framework.ShowNotification(source, 'Database reloaded successfully!', 'success')

    TriggerClientEvent('vehicleimages:dataReloaded', -1)
end)

RegisterCommand(Config.Commands.openMenu, function(source, args, rawCommand)
    local canView = Config.AllowPublicView or Framework.IsAdmin(source)

    if not canView then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local canProceed, remaining = CheckCooldown(source, 'openMenu', Config.RateLimits.openMenu)
    if not canProceed then
        Framework.ShowNotification(source, Config.Translate('error_ratelimit', remaining), 'warning')
        return
    end

    TriggerClientEvent('vehicleimages:openMenu', source)
end, false)

RegisterCommand(Config.Commands.preview, function(source, args, rawCommand)
    if not Config.AllowPublicPreview and not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    local canProceed, remaining = CheckCooldown(source, 'preview', Config.RateLimits.preview)
    if not canProceed then
        Framework.ShowNotification(source, Config.Translate('error_ratelimit', remaining), 'warning')
        return
    end

    if not args[1] then
        Framework.ShowNotification(source, 'Usage: /' .. Config.Commands.preview .. ' [model]', 'error')
        return
    end

    local model = args[1]
    local vehicle = VehicleDatabase.GetByModel(model)

    if vehicle then
        TriggerClientEvent('vehicleimages:showPreview', source, vehicle)
    else
        Framework.ShowNotification(source, 'Vehicle model not found: ' .. model, 'error')
    end
end, false)

RegisterCommand(Config.Commands.import, function(source, args, rawCommand)
    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    TriggerClientEvent('vehicleimages:openImport', source)
end, false)

RegisterCommand(Config.Commands.export, function(source, args, rawCommand)
    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    TriggerServerEvent('vehicleimages:exportData')
end, false)

RegisterCommand(Config.Commands.reload, function(source, args, rawCommand)
    if not Framework.IsAdmin(source) then
        Framework.ShowNotification(source, Config.Translate('error_permission'), 'error')
        return
    end

    TriggerServerEvent('vehicleimages:reloadDatabase')
end, false)

exports('GetVehicleImage', function(model)
    local vehicle = VehicleDatabase.GetByModel(model)
    return vehicle and vehicle.url or Config.Images.placeholder
end)

exports('GetAllVehicles', function()
    return VehicleDatabase.GetAll()
end)

exports('GetVehiclesByCategory', function(category)
    return VehicleDatabase.GetByCategory(category)
end)

exports('AddVehicle', function(data)
    return VehicleDatabase.Add(data)
end)

exports('UpdateVehicle', function(model, data)
    return VehicleDatabase.Update(model, data)
end)

exports('DeleteVehicle', function(model)
    return VehicleDatabase.Delete(model)
end)

exports('GetStats', function()
    return VehicleDatabase.GetStats()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Logger.Info('Server started successfully!')
        Logger.Info('Total vehicles: ' .. VehicleDatabase.GetCount())

        if GetConvar('onesync', 'off') == 'off' then
            Logger.Warn('OneSync is recommended for better performance')
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if Config.StorageType == 'json' then
            VehicleDatabase.SaveToJSON()
        end

        Logger.Info('Server stopped. Data saved.')
    end
end)
