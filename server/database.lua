VehicleDatabase = {}
VehicleDatabase.Data = {}
VehicleDatabase.Cache = {}
VehicleDatabase.LastSave = 0
VehicleDatabase.IsLoading = false

function VehicleDatabase.Initialize()
    if VehicleDatabase.IsLoading then
        Logger.Warn('Database is already loading, skipping...')
        return
    end

    VehicleDatabase.IsLoading = true
    Logger.Info('Initializing database system...')

    if Config.StorageType == 'json' then
        VehicleDatabase.LoadFromJSON()
    elseif Config.StorageType == 'mysql' then
        VehicleDatabase.LoadFromMySQL()
    end

    if Config.AutoSave then
        VehicleDatabase.StartAutoSave()
    end

    VehicleDatabase.IsLoading = false
    Logger.Info('Database initialized with ' .. VehicleDatabase.GetCount() .. ' vehicles')
end

function VehicleDatabase.LoadFromJSON()

    local content = LoadResourceFile(GetCurrentResourceName(), Config.JsonPath)

    if not content then
        Logger.Warn('JSON file not found, creating new one...')
        VehicleDatabase.Data = {pictures = {}}
        VehicleDatabase.SaveToJSON()
        return
    end

    local success, decoded = pcall(json.decode, content)

    if success and decoded and decoded.pictures then
        VehicleDatabase.Data = decoded
        Logger.Info('Loaded ' .. #decoded.pictures .. ' vehicles from JSON')
    else
        Logger.Error('Error decoding JSON file!', {error = decoded})
        VehicleDatabase.Data = {pictures = {}}
    end
end

function VehicleDatabase.SaveToJSON()
    CreateThread(function()
        local resourcePath = GetResourcePath(GetCurrentResourceName())
        local filePath = resourcePath .. '/' .. Config.JsonPath

        local file = io.open(filePath, 'w+')

        if not file then
            Logger.Error('Error opening JSON file for writing!')
            return false
        end

        local success, encoded = pcall(json.encode, VehicleDatabase.Data, {indent = true})

        if not success then
            Logger.Error('Error encoding JSON data!', {error = encoded})
            file:close()
            return false
        end

        file:write(encoded)
        file:close()

        VehicleDatabase.LastSave = os.time()
        Logger.Debug('Saved ' .. #VehicleDatabase.Data.pictures .. ' vehicles to JSON')

        return true
    end)
end

function VehicleDatabase.StartAutoSave()
    CreateThread(function()
        while true do
            Wait(Config.SaveInterval)
            if Config.StorageType == 'json' then
                VehicleDatabase.SaveToJSON()
            end
        end
    end)
end

function VehicleDatabase.LoadFromMySQL()
    Logger.Warn('MySQL support not implemented yet!')
    VehicleDatabase.Data = {pictures = {}}
end

function VehicleDatabase.SaveToMySQL()
    Logger.Warn('MySQL support not implemented yet!')
    return false
end

function VehicleDatabase.GetAll()
    return VehicleDatabase.Data.pictures or {}
end

function VehicleDatabase.GetByModel(model)
    if not model then return nil end
    model = string.lower(model)

    for _, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if vehicleModel == model then
            return vehicle
        end
    end

    return nil
end

function VehicleDatabase.GetByCategory(category)
    local results = {}

    for _, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        if vehicle.category and vehicle.category == category then
            table.insert(results, vehicle)
        end
    end

    return results
end

function VehicleDatabase.Add(data)
    if not data or not data.name or not data.url then
        return false, 'invalid_data'
    end

    local model = string.lower(data.name:gsub('.png', ''))

    if VehicleDatabase.GetByModel(model) then
        return false, 'exists'
    end

    if not VehicleDatabase.ValidateURL(data.url) then
        return false, 'invalid_url'
    end

    if not VehicleDatabase.ValidateModel(data.name) then
        return false, 'invalid_model'
    end

    local vehicle = {
        name = data.name,
        url = data.url,
        category = data.category or 'other',
        custom = data.custom or false,
        addedBy = data.addedBy or 'system',
        addedAt = os.time()
    }

    table.insert(VehicleDatabase.Data.pictures, vehicle)

    if Config.AutoSave and Config.StorageType == 'json' then
        VehicleDatabase.SaveToJSON()
    end

    VehicleDatabase.ClearCache()

    return true, vehicle
end

function VehicleDatabase.Update(model, data)
    if not model or not data then
        return false, 'invalid_data'
    end

    model = string.lower(model:gsub('.png', ''))

    if data.url and not VehicleDatabase.ValidateURL(data.url) then
        return false, 'invalid_url'
    end

    for i, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if vehicleModel == model then
            if data.url then vehicle.url = data.url end
            if data.category then vehicle.category = data.category end
            if data.custom ~= nil then vehicle.custom = data.custom end

            vehicle.editedBy = data.editedBy or 'system'
            vehicle.editedAt = os.time()

            VehicleDatabase.Data.pictures[i] = vehicle

            if Config.AutoSave and Config.StorageType == 'json' then
                VehicleDatabase.SaveToJSON()
            end

            VehicleDatabase.ClearCache()

            return true, vehicle
        end
    end

    return false, 'not_found'
end

function VehicleDatabase.Delete(model)
    if not model then
        return false, 'invalid_data'
    end

    model = string.lower(model:gsub('.png', ''))

    for i, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if vehicleModel == model then
            table.remove(VehicleDatabase.Data.pictures, i)

            if Config.AutoSave and Config.StorageType == 'json' then
                VehicleDatabase.SaveToJSON()
            end

            VehicleDatabase.ClearCache()

            return true
        end
    end

    return false, 'not_found'
end

function VehicleDatabase.GetCount()
    return #(VehicleDatabase.Data.pictures or {})
end

function VehicleDatabase.Search(query)
    if not query or query == '' then
        return VehicleDatabase.GetAll()
    end

    query = string.lower(query)
    local results = {}

    for _, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if string.find(vehicleModel, query, 1, true) then
            table.insert(results, vehicle)
        end
    end

    return results
end

function VehicleDatabase.Import(data, overwrite)
    if not data or not data.pictures then
        return false, 'invalid_data'
    end

    if #data.pictures > Config.ImportExport.maxImportSize then
        return false, 'too_large'
    end

    if Config.ImportExport.validateBeforeImport then
        for _, vehicle in ipairs(data.pictures) do
            if not vehicle.name or not vehicle.url then
                return false, 'invalid_vehicle_data'
            end
            if not VehicleDatabase.ValidateURL(vehicle.url) then
                return false, 'invalid_url'
            end
            if not VehicleDatabase.ValidateModel(vehicle.name) then
                return false, 'invalid_model'
            end
        end
    end

    if Config.ImportExport.backupBeforeImport then
        VehicleDatabase.CreateBackup()
    end

    if overwrite then
        VehicleDatabase.Data = data
    else
        for _, vehicle in ipairs(data.pictures) do
            local model = string.lower(vehicle.name:gsub('.png', ''))
            if not VehicleDatabase.GetByModel(model) then
                table.insert(VehicleDatabase.Data.pictures, vehicle)
            end
        end
    end

    if Config.StorageType == 'json' then
        VehicleDatabase.SaveToJSON()
    end

    VehicleDatabase.ClearCache()

    return true, #data.pictures
end

function VehicleDatabase.Export()
    return VehicleDatabase.Data
end

function VehicleDatabase.CreateBackup()
    local timestamp = os.date('%Y%m%d_%H%M%S')
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local backupPath = resourcePath .. '/data/backup_' .. timestamp .. '.json'
    local file = io.open(backupPath, 'w+')

    if file then
        local encoded = json.encode(VehicleDatabase.Data, {indent = true})
        file:write(encoded)
        file:close()

        Logger.Info('Backup created: backup_' .. timestamp .. '.json')
        return true
    end

    Logger.Error('Failed to create backup!')
    return false
end

function VehicleDatabase.GetFromCache(key)
    if not Config.Cache.enabled then return nil end

    local cached = VehicleDatabase.Cache[key]
    if cached and cached.expires > os.time() then
        return cached.data
    end

    return nil
end

function VehicleDatabase.SetCache(key, data)
    if not Config.Cache.enabled then return end

    VehicleDatabase.Cache[key] = {
        data = data,
        expires = os.time() + Config.Cache.serverTTL
    }
end

function VehicleDatabase.ClearCache()
    VehicleDatabase.Cache = {}
    TriggerClientEvent('vehicleimages:clearCache', -1)
    Logger.Debug('Server cache cleared')
end

CreateThread(function()
    while true do
        Wait(Config.Cache.cleanupInterval * 1000)

        if not Config.Cache.enabled then
            goto continue
        end

        local now = os.time()
        local cleaned = 0

        for key, cached in pairs(VehicleDatabase.Cache) do
            if cached.expires < now then
                VehicleDatabase.Cache[key] = nil
                cleaned = cleaned + 1
            end
        end

        if cleaned > 0 then
            Logger.Debug('Cleaned ' .. cleaned .. ' expired cache entries')
        end

        ::continue::
    end
end)

function VehicleDatabase.ValidateURL(url)
    if not url or type(url) ~= 'string' then
        return false
    end

    if #url > Config.Images.maxUrlLength then
        return false
    end

    if not string.match(url, '^https?://') then
        return false
    end

    if Config.Images.validateUrls and #Config.Images.allowedDomains > 0 then
        local isAllowed = false
        for _, domain in ipairs(Config.Images.allowedDomains) do
            if string.find(url, domain, 1, true) then
                isAllowed = true
                break
            end
        end
        if not isAllowed then
            return false
        end
    end

    if string.find(url:lower(), '<script') or string.find(url:lower(), 'javascript:') then
        return false
    end

    return true
end

function VehicleDatabase.ValidateModel(model)
    if not model or type(model) ~= 'string' then
        return false
    end

    if #model < 1 or #model > 50 then
        return false
    end

    if not string.match(model, '^[a-zA-Z0-9_-]+%.?p?n?g?$') then
        return false
    end

    return true
end

function VehicleDatabase.SanitizeString(str)
    if not str then return '' end

    str = string.gsub(str, '[<>"\']', '')
    str = string.gsub(str, '%s+', ' ')
    str = string.gsub(str, '^%s+', '')
    str = string.gsub(str, '%s+$', '')

    return str
end

function VehicleDatabase.GetStats()
    local stats = {
        total = VehicleDatabase.GetCount(),
        custom = 0,
        categories = {},
        lastSave = VehicleDatabase.LastSave,
        cacheSize = 0
    }

    for _, vehicle in ipairs(VehicleDatabase.Data.pictures or {}) do
        if vehicle.custom then
            stats.custom = stats.custom + 1
        end

        local cat = vehicle.category or 'other'
        stats.categories[cat] = (stats.categories[cat] or 0) + 1
    end

    for _ in pairs(VehicleDatabase.Cache) do
        stats.cacheSize = stats.cacheSize + 1
    end

    return stats
end

CreateThread(function()
    VehicleDatabase.Initialize()
end)
