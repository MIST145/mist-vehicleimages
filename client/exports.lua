--[[ ===================================================== ]]--
--[[          CLIENT EXPORTS (FIXED & IMPROVED)           ]]--
--[[ ===================================================== ]]--

--[[ ===================================================== ]]--
--[[                  EXPORT PRINCIPAL                      ]]--
--[[ ===================================================== ]]--

function GetVehicleImage(model)
    if not model then
        return Config.Images.placeholder
    end
    
    -- Remover .png se existir
    model = string.lower(model:gsub('.png', ''))
    
    -- Verificar cache primeiro
    local cacheKey = 'image_' .. model
    local cached = GetFromCache(cacheKey)
    
    if cached then
        return cached
    end
    
    -- Buscar diretamente nos dados carregados
    local state = _G.VehicleImagesState
    if state and state.vehicleData then
        for _, vehicle in ipairs(state.vehicleData) do
            local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
            if vehicleModel == model then
                SetCache(cacheKey, vehicle.url)
                return vehicle.url
            end
        end
    end
    
    return Config.Images.placeholder
end

exports('GetVehicleImage', GetVehicleImage)
exports('GetImage', GetVehicleImage)

--[[ ===================================================== ]]--
--[[                  VERIFICAÇÃO DE IMAGEM                 ]]--
--[[ ===================================================== ]]--

function HasVehicleImage(model)
    if not model then
        return false
    end
    
    model = string.lower(model)
    
    local state = _G.VehicleImagesState
    if not state or not state.vehicleData then
        return false
    end
    
    for _, vehicle in ipairs(state.vehicleData) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if vehicleModel == model then
            return true
        end
    end
    
    return false
end

exports('HasVehicleImage', HasVehicleImage)
exports('HasImage', HasVehicleImage)

--[[ ===================================================== ]]--
--[[                  OBTER TODOS OS VEÍCULOS               ]]--
--[[ ===================================================== ]]--

function GetAllVehicles()
    local state = _G.VehicleImagesState
    return state and state.vehicleData or {}
end

exports('GetAllVehicles', GetAllVehicles)

--[[ ===================================================== ]]--
--[[                  OBTER POR CATEGORIA                   ]]--
--[[ ===================================================== ]]--

function GetVehiclesByCategory(category)
    if not category then
        return {}
    end
    
    local state = _G.VehicleImagesState
    if not state or not state.vehicleData then
        return {}
    end
    
    local results = {}
    
    for _, vehicle in ipairs(state.vehicleData) do
        if vehicle.category and vehicle.category == category then
            table.insert(results, vehicle)
        end
    end
    
    return results
end

exports('GetVehiclesByCategory', GetVehiclesByCategory)
exports('GetByCategory', GetVehiclesByCategory)

--[[ ===================================================== ]]--
--[[                  PESQUISAR VEÍCULOS                    ]]--
--[[ ===================================================== ]]--

function SearchVehicles(query)
    if not query or query == '' then
        return GetAllVehicles()
    end
    
    local state = _G.VehicleImagesState
    if not state or not state.vehicleData then
        return {}
    end
    
    query = string.lower(query)
    local results = {}
    
    for _, vehicle in ipairs(state.vehicleData) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if string.find(vehicleModel, query, 1, true) then
            table.insert(results, vehicle)
        end
    end
    
    return results
end

exports('SearchVehicles', SearchVehicles)
exports('Search', SearchVehicles)

--[[ ===================================================== ]]--
--[[                  OBTER MODELO ESPECÍFICO               ]]--
--[[ ===================================================== ]]--

function GetVehicle(model)
    if not model then
        return nil
    end
    
    model = string.lower(model)
    
    local state = _G.VehicleImagesState
    if not state or not state.vehicleData then
        return nil
    end
    
    for _, vehicle in ipairs(state.vehicleData) do
        local vehicleModel = string.lower(vehicle.name:gsub('.png', ''))
        if vehicleModel == model then
            return vehicle
        end
    end
    
    return nil
end

exports('GetVehicle', GetVehicle)

--[[ ===================================================== ]]--
--[[                  OBTER INFORMAÇÃO COMPLETA             ]]--
--[[ ===================================================== ]]--

function GetVehicleInfo(model)
    local vehicle = GetVehicle(model)
    
    if not vehicle then
        return {
            exists = false,
            model = model,
            url = Config.Images.placeholder,
            category = 'unknown',
            custom = false
        }
    end
    
    return {
        exists = true,
        model = vehicle.name:gsub('.png', ''),
        url = vehicle.url,
        category = vehicle.category or 'other',
        custom = vehicle.custom or false,
        addedBy = vehicle.addedBy,
        addedAt = vehicle.addedAt,
        editedBy = vehicle.editedBy,
        editedAt = vehicle.editedAt
    }
end

exports('GetVehicleInfo', GetVehicleInfo)
exports('GetInfo', GetVehicleInfo)

--[[ ===================================================== ]]--
--[[                  CONTROLE DO MENU                      ]]--
--[[ ===================================================== ]]--

function OpenVehicleMenu()
    OpenMenu()
end

exports('OpenMenu', OpenVehicleMenu)
exports('Open', OpenVehicleMenu)

function CloseVehicleMenu()
    CloseMenu()
end

exports('CloseMenu', CloseVehicleMenu)
exports('Close', CloseVehicleMenu)

function ToggleVehicleMenu()
    local state = _G.VehicleImagesState
    if state and state.isMenuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end

exports('ToggleMenu', ToggleVehicleMenu)
exports('Toggle', ToggleVehicleMenu)

function IsMenuOpenExport()
    local state = _G.VehicleImagesState
    return state and state.isMenuOpen or false
end

exports('IsMenuOpen', IsMenuOpenExport)

--[[ ===================================================== ]]--
--[[                  CACHE MANAGEMENT                      ]]--
--[[ ===================================================== ]]--

function ClearVehicleCache()
    ClearCache()
    return true
end

exports('ClearCache', ClearVehicleCache)

function GetCacheSize()
    local state = _G.VehicleImagesState
    if not state or not state.playerCache then
        return 0
    end
    
    local count = 0
    for _ in pairs(state.playerCache) do
        count = count + 1
    end
    return count
end

exports('GetCacheSize', GetCacheSize)

--[[ ===================================================== ]]--
--[[                  UTILITÁRIOS                           ]]--
--[[ ===================================================== ]]--

function GetTotalVehicles()
    local state = _G.VehicleImagesState
    return state and state.vehicleData and #state.vehicleData or 0
end

exports('GetTotalVehicles', GetTotalVehicles)
exports('GetCount', GetTotalVehicles)

function GetCategories()
    return Config.Categories
end

exports('GetCategories', GetCategories)

function IsCustomVehicle(model)
    local vehicle = GetVehicle(model)
    return vehicle and vehicle.custom or false
end

exports('IsCustomVehicle', IsCustomVehicle)
exports('IsCustom', IsCustomVehicle)