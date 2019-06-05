package.path = package.path .. ";data/scripts/lib/?.lua"
include("callable")
local Azimuth = include("azimuthlib-basic")

-- namespace AzimuthLibExample
AzimuthLibExample = {}

local configOptions
if onClient() then
    configOptions = {
      _version = { default = "1.0", comment = "Config version. Don't touch." }, -- this will help you in the future to make changed in config when you'll update the mod
      -- AzimuthLib will make basic checks (type, min/max value, floor/round/ceil) and fix config if needed
      LogLevel = {default = 2, min = 0, max = 4, format = "floor", comment = "0 - Disable, 1 - Errors, 2 - Warnings, 3 - Info, 4 - Debug."},
      WindowWidth = { default = 300, min = 200, max = 600, format = "floor", comment = "UI window width" },
      WindowHeight = { default = 400, min = 300, max = 700, format = "floor", comment = "UI window height" },
      -- But in case of tables it will check only the type. The rest you'll have to do yourself
      SomeTable = {
        default = {
          Zucchini = 1,
          Apple = 1,
          Potato = 1,
          Tomato = 2
        },
        comment = "Complex table"
      }
    }
else -- onServer
    configOptions = {
      _version = { default = "1.0", comment = "Config version. Don't touch." }, -- this will help you in the future to make changed in config when you'll update the mod
      LogLevel = {default = 2, min = 0, max = 4, format = "floor", comment = "0 - Disable, 1 - Errors, 2 - Warnings, 3 - Info, 4 - Debug."},
      GreetPlayer = { default = true, comment = "Should we greet player on player ship init?" },
      SyncedMessage = { default = "It works!", comment = "This variable should be synced with client" }
    }
end
local config, isModified = Azimuth.loadConfig("AzimuthLibExample", configOptions)
-- Here you'll need to check if variables-tables have correct properties
-- In this case, we'll just check if value is a number:
if onClient() then
    for name, value in pairs(config.SomeTable) do
        if type(value) ~= "number" then
            config.SomeTable[name] = nil -- remove invalid element
            isModified = true -- mark config for rewriting
        end
    end
end
if isModified then -- rewrite config if it's needed (had errors or didn't exist at all)
    Azimuth.saveConfig("AzimuthLibExample", config, configOptions)
end
configOptions = nil -- no need to keep it
-- Init logs
local Log = Azimuth.logs("AzimuthLibExample", config.LogLevel)


local serverConfig, label

function AzimuthLibExample.interactionPossible(playerIndex)
    return true
end

function AzimuthLibExample.initialize()
    if onClient() then
        Log.Debug("Ask server to greet player")
        invokeServerFunction("sendConfig")
        invokeServerFunction("greetPlayer")
    end
end

function AzimuthLibExample.initUI()
    local res = getResolution()
    local size = vec2(config.WindowWidth, config.WindowHeight)
    local menu = ScriptUI()
    window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    menu:registerWindow(window, "AzimuthLibExample"%_t)
    window.caption = "AzimuthLibExample"%_t
    window.showCloseButton = 1
    window.moveable = 1
    
    label = window:createLabel(vec2(15, 15), "", 15)
    local listBox = window:createListBox(Rect(15, 45, size.x - 15, size.y - 15))
    -- Add sorted SomeTable keys in the ListBox (just because I need to demonstrate how 'orderedPairs' works)
    -- This will result in following order: Apple, Potato, Zucchini, Tomato. So we sort by value and then by alphabet
    for name, _ in Azimuth.orderedPairs(config.SomeTable, function(tbl, a, b) return tbl[a] < tbl[b] and true or (a < b) end) do
        listBox:addEntry(name)
    end
end

function AzimuthLibExample.onShowWindow()
    if not serverConfig then
        Log.Error("onShowWindow - serverConfig wasn't synced")
        return
    end
    Log.Debug("serverConfig: %s", Log.isDebug and Azimuth.serialize(serverConfig) or "") -- serialize is an expensive function, so let's not use it if log level is below 'Debug'
    label.caption = serverConfig.SyncedMessage
end

function AzimuthLibExample.sendConfig()
    invokeClientFunction(Player(callingPlayer), "receiveConfig", {
      SyncedMessage = config.SyncedMessage
    })
end
callable(AzimuthLibExample, "sendConfig")

function AzimuthLibExample.receiveConfig(server_config)
    serverConfig = server_config
end

function AzimuthLibExample.greetPlayer()
    if config.GreetPlayer then
        local player = Player(callingPlayer)
        Log.Debug("Greet player '%s'", player.name)
        player:sendChatMessage("Server", 0, "Greetings")
    end
end
callable(AzimuthLibExample, "greetPlayer")