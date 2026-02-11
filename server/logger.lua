Logger = {}
Logger.Levels = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4
}

function Logger.Log(level, message, data)
    if not Config.Debug and level == Logger.Levels.DEBUG then
        return
    end

    if not Config.Logs.enabled and level ~= Logger.Levels.ERROR then
        return
    end

    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local prefix = ({
        [Logger.Levels.ERROR] = '^1[ERROR]^7',
        [Logger.Levels.WARN] = '^3[WARN]^7',
        [Logger.Levels.INFO] = '^2[INFO]^7',
        [Logger.Levels.DEBUG] = '^5[DEBUG]^7'
    })[level] or '^7[LOG]^7'

    local logMessage = string.format('%s [VehicleImages] %s: %s', prefix, timestamp, message)
    print(logMessage)

    if data and Config.Debug then
        print(json.encode(data, {indent = true}))
    end
end

function Logger.Error(message, data)
    Logger.Log(Logger.Levels.ERROR, message, data)
end

function Logger.Warn(message, data)
    Logger.Log(Logger.Levels.WARN, message, data)
end

function Logger.Info(message, data)
    Logger.Log(Logger.Levels.INFO, message, data)
end

function Logger.Debug(message, data)
    Logger.Log(Logger.Levels.DEBUG, message, data)
end

function Logger.LogPlayerAction(source, action, data)
    if not Config.Logs.enabled then
        return
    end

    if not table.contains(Config.Logs.logActions, action) then
        return
    end

    local playerName = Framework.GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source, 0) or 'unknown'

    Logger.Info(string.format('Player %s (%s) performed action: %s', playerName, identifier, action), data)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
