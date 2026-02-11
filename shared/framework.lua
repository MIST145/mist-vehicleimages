Framework = {}
Framework.Type = 'standalone'
Framework.ESX = nil

if GetResourceState('es_extended') == 'started' then
    Framework.Type = 'esx'

    if IsDuplicityVersion() then

        Framework.ESX = exports['es_extended']:getSharedObject()
    else

        CreateThread(function()
            while Framework.ESX == nil do
                Framework.ESX = exports['es_extended']:getSharedObject()
                Wait(100)
            end
        end)
    end
end

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

function Framework.ShowNotification(source, message, type)
    if not IsDuplicityVersion() then

        if Framework.Type == 'esx' and Framework.ESX then
            Framework.ESX.ShowNotification(message)
        else

            SendNUIMessage({
                action = 'notification',
                type = type or 'info',
                message = message,
                duration = Config.Notifications.duration,
                position = Config.Notifications.position
            })
        end
    else

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
