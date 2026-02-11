Config = {}

Config.Debug = false 
Config.Language = 'en' 
Config.Framework = 'standalone' 

Config.StorageType = 'json' 
Config.JsonPath = 'data/vehicles.json' 
Config.AutoSave = true 
Config.SaveInterval = 300000 

Config.UsePermissions = false 
Config.AdminGroups = {
    'admin',
    'mod',
    'superadmin'
} 

Config.AllowPublicView = true 
Config.AllowPublicPreview = true 

Config.RateLimits = {
    enabled = true,
    openMenu = 2, 
    preview = 1, 
    addVehicle = 5, 
    editVehicle = 3, 
    deleteVehicle = 5 
}

Config.Commands = {
    openMenu = 'vehicleimages', 
    preview = 'vehimg', 
    import = 'vehimport', 
    export = 'vehexport', 
    reload = 'vehreload' 
}

Config.UI = {
    theme = 'dark', 
    accentColor = '#007bff', 
    maxItemsPerPage = 50, 
    showCategories = true, 
    showSearch = true, 
    showStats = true, 
    animationSpeed = 300 
}

Config.Cache = {
    enabled = true, 
    clientTTL = 3600, 
    serverTTL = 7200, 
    preloadAll = false, 
    cleanupInterval = 300 
}

Config.Images = {
    placeholder = 'https://via.placeholder.com/400x300/1f2937/ffffff?text=Sem+Imagem', 
    fallbackOnError = true, 
    allowedDomains = { 
        'raw.githubusercontent.com',
        'i.imgur.com',
        'r2.fivemanage.com',
        'cdn.discordapp.com',
        'res.cloudinary.com',
        'image.noelshack.com'
    },
    maxUrlLength = 500, 
    validateUrls = true, 
    allowedContentTypes = { 
        'image/png',
        'image/jpeg',
        'image/jpg',
        'image/webp'
    }
}

Config.Categories = {
    {id = 'super', label = 'Super', icon = '🏎️'},
    {id = 'sports', label = 'Desportivos', icon = '🚗'},
    {id = 'sportsclassics', label = 'Clássicos Desportivos', icon = '🚙'},
    {id = 'sedans', label = 'Sedans', icon = '🚘'},
    {id = 'coupes', label = 'Coupés', icon = '🚗'},
    {id = 'muscle', label = 'Muscle', icon = '💪'},
    {id = 'offroad', label = 'Todo-o-Terreno', icon = '🚙'},
    {id = 'suvs', label = 'SUVs', icon = '🚙'},
    {id = 'vans', label = 'Carrinhas', icon = '🚐'},
    {id = 'motorcycles', label = 'Motas', icon = '🏍️'},
    {id = 'planes', label = 'Aviões', icon = '✈️'},
    {id = 'helicopters', label = 'Helicópteros', icon = '🚁'},
    {id = 'boats', label = 'Barcos', icon = '🚤'},
    {id = 'industrial', label = 'Industrial', icon = '🚜'},
    {id = 'utility', label = 'Utilitários', icon = '🚛'},
    {id = 'emergency', label = 'Emergência', icon = '🚑'},
    {id = 'military', label = 'Militar', icon = '🪖'},
    {id = 'commercial', label = 'Comercial', icon = '🚚'},
    {id = 'custom', label = 'Custom', icon = '⭐'},
    {id = 'other', label = 'Outros', icon = '❓'}
}

Config.Logs = {
    enabled = false, 
    saveToFile = false, 
    logActions = { 
        'add',
        'edit',
        'delete',
        'import',
        'export',
        'reload'
    }
}

Config.ImportExport = {
    maxImportSize = 10000, 
    validateBeforeImport = true, 
    backupBeforeImport = true, 
    allowOverwrite = true, 
    exportFormat = 'json' 
}

Config.Notifications = {
    enabled = true,
    position = 'top-right', 
    duration = 3000, 
    types = {
        success = {color = '#10b981', icon = '✓'},
        error = {color = '#ef4444', icon = '✗'},
        warning = {color = '#f59e0b', icon = '⚠'},
        info = {color = '#3b82f6', icon = 'ℹ'}
    }
}

Config.Translations = {
    pt = {
        menu_title = 'Gestão de Imagens de Veículos',
        search_placeholder = 'Pesquisar modelo...',
        add_vehicle = 'Adicionar Veículo',
        edit_vehicle = 'Editar Veículo',
        delete_vehicle = 'Eliminar Veículo',
        preview_vehicle = 'Preview',
        import_data = 'Importar Dados',
        export_data = 'Exportar Dados',
        save_changes = 'Guardar Alterações',
        cancel = 'Cancelar',
        confirm = 'Confirmar',
        model_name = 'Nome do Modelo',
        image_url = 'URL da Imagem',
        category = 'Categoria',
        custom_vehicle = 'Veículo Custom',
        total_vehicles = 'Total de Veículos',
        no_results = 'Nenhum resultado encontrado',
        loading = 'A carregar...',
        success_add = 'Veículo adicionado com sucesso!',
        success_edit = 'Veículo editado com sucesso!',
        success_delete = 'Veículo eliminado com sucesso!',
        success_import = 'Dados importados com sucesso!',
        success_export = 'Dados exportados com sucesso!',
        error_permission = 'Não tens permissão para esta ação!',
        error_exists = 'Este modelo já existe!',
        error_invalid_url = 'URL inválida!',
        error_invalid_model = 'Nome de modelo inválido!',
        error_load = 'Erro ao carregar dados!',
        error_ratelimit = 'Aguarda %s segundos antes de tentar novamente!',
        confirm_delete = 'Tens a certeza que queres eliminar este veículo?',
        confirm_import = 'Importar dados irá sobrescrever a base de dados atual. Continuar?'
    },
    en = {
        menu_title = 'Vehicle Image Management',
        search_placeholder = 'Search model...',
        add_vehicle = 'Add Vehicle',
        edit_vehicle = 'Edit Vehicle',
        delete_vehicle = 'Delete Vehicle',
        preview_vehicle = 'Preview',
        import_data = 'Import Data',
        export_data = 'Export Data',
        save_changes = 'Save Changes',
        cancel = 'Cancel',
        confirm = 'Confirm',
        model_name = 'Model Name',
        image_url = 'Image URL',
        category = 'Category',
        custom_vehicle = 'Custom Vehicle',
        total_vehicles = 'Total Vehicles',
        no_results = 'No results found',
        loading = 'Loading...',
        success_add = 'Vehicle added successfully!',
        success_edit = 'Vehicle edited successfully!',
        success_delete = 'Vehicle deleted successfully!',
        success_import = 'Data imported successfully!',
        success_export = 'Data exported successfully!',
        error_permission = 'You do not have permission for this action!',
        error_exists = 'This model already exists!',
        error_invalid_url = 'Invalid URL!',
        error_invalid_model = 'Invalid model name!',
        error_load = 'Error loading data!',
        error_ratelimit = 'Wait %s seconds before trying again!',
        confirm_delete = 'Are you sure you want to delete this vehicle?',
        confirm_import = 'Importing data will overwrite the current database. Continue?'
    }
}

function Config.Translate(key, ...)
    local lang = Config.Language
    local translation = Config.Translations[lang] and Config.Translations[lang][key] or key

    if ... then
        return string.format(translation, ...)
    end

    return translation
end
