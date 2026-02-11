--[[ ===================================================== ]]--
--[[                  CONFIGURAÇÕES V2.1                  ]]--
--[[ ===================================================== ]]--

Config = {}

--[[ Configurações Gerais ]]--
Config.Debug = false -- Ativar mensagens de debug (DESLIGAR EM PRODUÇÃO!)
Config.Language = 'en' -- Idioma do sistema (pt, en, es, fr)
Config.Framework = 'standalone' -- 'standalone' ou 'esx' (detecta automaticamente)

--[[ Sistema de Armazenamento ]]--
Config.StorageType = 'json' -- Tipo de armazenamento: 'json' ou 'mysql' (futuro)
Config.JsonPath = 'data/vehicles.json' -- Caminho do ficheiro JSON
Config.AutoSave = true -- Guardar automaticamente após alterações
Config.SaveInterval = 300000 -- Intervalo de auto-save em ms (5 minutos)

--[[ Permissões ]]--
Config.UsePermissions = false -- Ativar sistema de permissões ACE
Config.AdminGroups = {
    'admin',
    'mod',
    'superadmin'
} -- Grupos com permissão para editar (ACE ou ESX)

Config.AllowPublicView = true -- Permitir todos verem a interface (apenas leitura)
Config.AllowPublicPreview = true -- Permitir comando de preview público

--[[ Rate Limiting ]]--
Config.RateLimits = {
    enabled = true,
    openMenu = 2, -- Segundos entre aberturas de menu
    preview = 1, -- Segundos entre previews
    addVehicle = 5, -- Segundos entre adições
    editVehicle = 3, -- Segundos entre edições
    deleteVehicle = 5 -- Segundos entre eliminações
}

--[[ Comandos ]]--
Config.Commands = {
    openMenu = 'vehicleimages', -- Comando para abrir menu de gestão
    preview = 'vehimg', -- Comando para preview rápido
    import = 'vehimport', -- Comando para importar JSON
    export = 'vehexport', -- Comando para exportar JSON
    reload = 'vehreload' -- Comando para recarregar base de dados
}

--[[ Interface (NUI) ]]--
Config.UI = {
    theme = 'dark', -- Tema da interface: 'dark' ou 'light'
    accentColor = '#007bff', -- Cor de destaque (azul por padrão)
    maxItemsPerPage = 50, -- Máximo de itens por página
    showCategories = true, -- Mostrar categorias
    showSearch = true, -- Mostrar barra de pesquisa
    showStats = true, -- Mostrar estatísticas
    animationSpeed = 300 -- Velocidade de animações em ms
}

--[[ Cache ]]--
Config.Cache = {
    enabled = true, -- Ativar sistema de cache
    clientTTL = 3600, -- Tempo de vida do cache client (segundos)
    serverTTL = 7200, -- Tempo de vida do cache server (segundos)
    preloadAll = false, -- Pré-carregar todas as imagens ao iniciar
    cleanupInterval = 300 -- Limpar cache expirado a cada X segundos
}

--[[ Imagens ]]--
Config.Images = {
    placeholder = 'https://via.placeholder.com/400x300/1f2937/ffffff?text=Sem+Imagem', -- Imagem padrão
    fallbackOnError = true, -- Usar placeholder se URL falhar
    allowedDomains = { -- Domínios permitidos (deixar vazio para permitir todos)
        'raw.githubusercontent.com',
        'i.imgur.com',
        'r2.fivemanage.com',
        'cdn.discordapp.com',
        'res.cloudinary.com',
        'image.noelshack.com'
    },
    maxUrlLength = 500, -- Comprimento máximo de URL
    validateUrls = true, -- Validar URLs antes de guardar
    allowedContentTypes = { -- Content-Types permitidos (segurança XSS)
        'image/png',
        'image/jpeg',
        'image/jpg',
        'image/webp'
    }
}

--[[ Categorias de Veículos ]]--
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

--[[ Logs ]]--
Config.Logs = {
    enabled = false, -- Ativar sistema de logs
    saveToFile = false, -- Guardar logs em ficheiro (não implementado)
    logActions = { -- Ações a registar
        'add',
        'edit',
        'delete',
        'import',
        'export',
        'reload'
    }
}

--[[ Exportação/Importação ]]--
Config.ImportExport = {
    maxImportSize = 10000, -- Máximo de veículos em importação única
    validateBeforeImport = true, -- Validar dados antes de importar
    backupBeforeImport = true, -- Criar backup antes de importar
    allowOverwrite = true, -- Permitir sobrescrever entradas existentes
    exportFormat = 'json' -- Formato de exportação: 'json'
}

--[[ Notificações ]]--
Config.Notifications = {
    enabled = true,
    position = 'top-right', -- Posição: 'top-right', 'top-left', 'bottom-right', 'bottom-left'
    duration = 3000, -- Duração em ms
    types = {
        success = {color = '#10b981', icon = '✓'},
        error = {color = '#ef4444', icon = '✗'},
        warning = {color = '#f59e0b', icon = '⚠'},
        info = {color = '#3b82f6', icon = 'ℹ'}
    }
}

--[[ Traduções ]]--
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

--[[ Função Helper para obter tradução ]]--
function Config.Translate(key, ...)
    local lang = Config.Language
    local translation = Config.Translations[lang] and Config.Translations[lang][key] or key
    
    if ... then
        return string.format(translation, ...)
    end
    
    return translation
end