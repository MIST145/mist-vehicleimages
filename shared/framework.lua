--[[ ===================================================== ]]--
--[[          FRAMEWORK INTEGRATION (ESX OPTIONAL)        ]]--
--[[ ===================================================== ]]--

Framework = {}
Framework.Type = 'standalone'
Framework.ESX = nil

--[[ Detectar Framework ]]--
if GetResourceState('es_extended') == 'started' then
    Framework.Type = 'esx'
    
    if IsDuplicityVersion() then
        -- Server-side
        Framework.ESX = exports['es_extended']:getSharedObject()
    else
        -- Client-side
        CreateThread(function()
            while Framework.ESX == nil do
                Framework.ESX = exports['es_extended']:getSharedObject()
                Wait(100)
            end
        end)
    end
end

--[[ Verificar Admin ]]--
function Framework.IsAdmin(source)
    if Framework.Type == 'esx' and Framework.ESX then
        if IsDuplicityVersion() then
            local xPlayer = Framework.ESX.GetPlayerFromId(source)
            if xPlayer then
                local group = xPlayer.getGroup()
                return group == 'admin' or group == 'superadmin'
            end
        end
        return false
    else
        -- Sistema ACE standalone
        if not Config.UsePermissions then
            return true
        end
        
        for _, group in ipairs(Config.AdminGroups) do
            if IsPlayerAceAllowed(source, 'group.' .. group) then
                return true
            end
        end
        
        return false
    end
end

--[[ Mostrar Notificação ]]--
function Framework.ShowNotification(source, message, type)
    if not IsDuplicityVersion() then
        -- Client-side
        if Framework.Type == 'esx' and Framework.ESX then
            Framework.ESX.ShowNotification(message)
        else
            -- Sistema NUI standalone
            SendNUIMessage({
                action = 'notification',
                type = type or 'info',
                message = message,
                duration = Config.Notifications.duration,
                position = Config.Notifications.position
            })
        end
    else
        -- Server-side
        if Framework.Type == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        else
            TriggerClientEvent('vehicleimages:showNotification', source, {
                type = type or 'info',
                message = message
            })
        end
    end
end

--[[ Obter Nome do Jogador ]]--
function Framework.GetPlayerName(source)
    if Framework.Type == 'esx' and Framework.ESX and IsDuplicityVersion() then
        local xPlayer = Framework.ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getName()
        end
    end
    
    local name = GetPlayerName(source)
    return name and name ~= '' and name or 'Unknown'
end