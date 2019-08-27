--[[ Provides an easy way of saving and loading config files. Also adds other useful functions, such as logging functions.
To use it you'll need to include it first: local Azimuth = include("azimuthlib-basic")
]]

local Azimuth = {}

local format = string.format

local moddata = "moddata"
if onServer() then
    moddata = Server().folder .. "/" .. moddata
end

-- API --
-- logs(modName, consoleLogLevel [, logLevel])
--[[ Initializes logs.
* modName (string) - The name of your mod.
* consoleLogLevel (number) - Console log level.
* logLevel (number) - File log level. If not specified, consoleLogLevel will be used instead.
Example: local Log = Azimuth.logs("MyMod", 2)
Example: local Log = Azimuth.logs("MyMod", config.consoleLogLevel, config.logLevel)
  Log.Info("Some info, player name: %s", Player().name) -- Will result in: [INFO][MyMod]: player name: Jeff
]]
function Azimuth.logs(modName, consoleLogLevel, logLevel)
    local log = {
      modName = modName,
      consoleLogLevel = consoleLogLevel,
      logLevel = consoleLogLevel or logLevel
    }
    local logMax = math.max(log.consoleLogLevel, log.logLevel)
    log.isError = logMax >= 1
    log.isWarning = logMax >= 2
    log.isInfo = logMax >= 3
    log.isDebug = logMax >= 4
    -- Code duplication because I don't want 30% function call overhead in log functions (especially debug one)
    log.Error = function(msg, ...)
        if 1 <= log.consoleLogLevel then
            eprint(format("[ERROR][%s]: "..msg, log.modName, ...))
        elseif 1 <= log.logLevel then
            printlog(format("[ERROR][%s]: "..msg, log.modName, ...))
        end
    end
    log.Warn = function(msg, ...)
        if 2 <= log.consoleLogLevel then
            print(format("[WARN][%s]: "..msg, log.modName, ...))
        elseif 2 <= log.logLevel then
            printlog(format("[WARN][%s]: "..msg, log.modName, ...))
        end
    end
    log.Info = function(msg, ...)
        if 3 <= log.consoleLogLevel then
            print(format("[INFO][%s]: "..msg, log.modName, ...))
        elseif 3 <= log.logLevel then
            printlog(format("[INFO][%s]: "..msg, log.modName, ...))
        end
    end
    log.Debug = function(msg, ...)
        if 4 <= log.consoleLogLevel then
            print(format("[DEBUG][%s]: "..msg, log.modName, ...))
        elseif 4 <= log.logLevel then
            printlog(format("[DEBUG][%s]: "..msg, log.modName, ...))
        end
    end
    return log
end

-- orderedPairs(tbl [, sort])
--[[ Allows to iterate table by key in alphabetical order.
* tbl (table) - Table.
* sort (function) - Sorting function for keys.
Example: for k, v in Azimuth.orderedPairs(myTable, function(tbl, firstKey, secondKey) return tbl[firstKey] < tbl[secondKey] end) do
]]
function Azimuth.orderedPairs(tbl, sort)
    local a = {}
    for n in pairs(tbl) do
        a[#a+1] = n
    end
    if sort then
        table.sort(a, function(a, b) return sort(tbl, a, b) end)
    else
        table.sort(a)
    end
    local i = 0 -- iterator variable
    local iter = function () -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], tbl[a[i]]
        end
    end
    return iter
end

-- serialize(o [, options [, prefix [, addCarriageReturn ]]])
--[[ Serializes table as readable multi-line text.
* o (table) - Table for serialization.
* options (table) - Optional argument. Since this function was initially meant to aid in saving config files, you can add default value and commentary to each variable.
* prefix (string) - Default: "". Line prefix, used by the function itself.
* addCarriageReturn (boolean) - If true, function uses "\r\n" as new line instead of "\n". False by default because "\r\n" messes up Avorion file logs.
Example: print(Azimuth.serialize(myTable))
Example: print(Azimuth.serialize({ myVar = 30 }, { myVar = { default = 20, comment = "This variable does stuff" } }))
]]
function Azimuth.serialize(o, options, prefix, addCarriageReturn)
    if type(o) == 'table' then
        if not options then options = {} end
        if not prefix then prefix = "" end
        local newLine = addCarriageReturn and "\r\n" or "\n"
        local s = "{" .. newLine
        local newprefix = prefix .. "  "
        -- check if it's a list
        local isList = true
        local minKey = math.huge
        local maxKey = 0
        local numVars = 0
        for k, _ in pairs(o) do
            if type(k) ~= 'number' then
                isList = false
                break
            end
            if k < minKey then minKey = k end
            if k > maxKey then maxKey = k end
            numVars = numVars + 1
        end
        if isList and minKey == 1 and maxKey == numVars then -- write as list
            for k = 1, numVars do
                s = s .. newprefix .. Azimuth.serialize(o[k], nil, newprefix, addCarriageReturn) .. "," .. newLine
            end
        else -- write as usual table
            local ov
            for k,v in Azimuth.orderedPairs(o) do
                ov = options[k]
                if ov then
                    if ov.default ~= nil and type(ov.default) ~= "table" then
                        s = s .. newprefix .. "-- Default: " .. tostring(ov.default) .. (ov.comment and ". " .. ov.comment or "") .. newLine
                    elseif ov.comment then
                        s = s .. newprefix .. "-- " .. ov.comment .. newLine
                    end
                end
                if type(k) ~= 'number' then
                    k = '"' .. k .. '"'
                end
                s = s .. newprefix .. '[' .. k .. '] = ' .. Azimuth.serialize(v, nil, newprefix, addCarriageReturn) .. "," .. newLine
            end
        end
        s = s .. prefix .. "}"
        return s
    else
        return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
    end
end

-- loadConfig(modName, options [, isSeedDependant [, inModFolder]])
--[[ Loads mod config from file.
* modName (string) - Mod name.
* options (table) - Config options with default values and comments. Each element of the table can have following properties:
  default - Required. Default value of a variable.
  min/max (number) - Optional. Minimum and maximum value of a variable, if it's a number.
  format (string) - Optional. Can be 'floor', 'round' or 'ceil', selected way of rounding will be applied for loaded variable.
* isSeedDependant (boolean) - True if config is specific for this server. false otherwise (useful only on client side).
* modFolder (boolean/string) - If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name.
Returns:
1. Config table.
2. Error/status. Can be one of the following:
  * String, it's an error message.
  * Number, 1 - means that file wasn't found. Hint: re-save the config.
  * Number, 0 - config was successfully loaded, but was modified by `options`. Hint: re-save the config.
  * Nil, config was successfully loaded, no modifications were made.
Example: local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = { default = 300 } })
Example: local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600, format = "ceil" } }, true)
]]
function Azimuth.loadConfig(modName, options, isSeedDependant, modFolder)
    local defaultValues = {}
    for k, v in pairs(options) do
        defaultValues[k] = v.default
    end
    local dir = moddata
    if modFolder then
        if modFolder == true then
            modFolder = modName
        end
        dir = dir .. "/" .. modFolder
    end
    local filename = dir .. "/" .. modName .. (isSeedDependant and '_' .. GameSettings().seed or "") .. ".lua"
    local file, err = io.open(filename, "rb")
    if err then
        if not err:find("No such file or directory", 1, true) then
            eprint("[ERROR]["..modName.."]: Failed to load config file '"..filename.."': " .. err)
            return defaultValues, err
        else
            return defaultValues, 1 -- file wasn't found
        end
    end
    local fileContents = file:read("*all") or ""
    local result, err = loadstring("return " .. fileContents)
    file:close()
    if not result then
        eprint("[ERROR]["..modName.."]: Failed to load config file '"..filename.."': " .. err .. "; File contents: "..fileContents)
        return defaultValues, err
    end
    result = result()
    local isModified = false -- if modified is false, there is no need to rewrite config file
    local value
    -- if file is empty, just use default
    if type(result) ~= "table" then
        result = defaultValues
        isModified = true
    else
        -- now check if config variables are present and correct
        local rv
        for k, v in pairs(options) do
            rv = result[k]
            if rv == nil or type(rv) ~= type(v.default) then
                result[k] = v.default
                isModified = true
            else
                if v.format then
                    if v.format == "ceil" then
                        value = math.ceil(result[k])
                        isModified = isModified or (result[k] ~= value)
                        result[k] = value
                    elseif v.format == "round" then
                        if result[k] >= 0 then
                            value = math.floor(result[k] + 0.5)
                            isModified = isModified or (result[k] ~= value)
                            result[k] = value
                        else
                            value = math.ceil(result[k] - 0.5)
                            isModified = isModified or (result[k] ~= value)
                            result[k] = value
                        end
                    elseif v.format == "floor" then
                        value = math.floor(result[k])
                        isModified = isModified or (result[k] ~= value)
                        result[k] = value
                    end
                end
                if v.min and rv < v.min then
                    result[k] = v.min
                    isModified = true
                elseif v.max and rv > v.max then
                    result[k] = v.max
                    isModified = true
                end
            end
        end
    end
    isModified = isModified and 0 or nil
    return result, isModified
end

-- saveConfig(modName, config [, options [, isSeedDependant [, inModFolder]]])
--[[ Saves mod config to file.
* modName (string) - String with modname.
* config (table) - Config table.
* options(table) - Config options with default values and comments. Each element of the table can have following properties:
  default - Default value of a variable. Will be added to a commentary unless it's a table.
  comment (string) - Variable commentary.
* isSeedDependant (boolean) - True if config is specific for this server, false otherwise.
* modFolder(boolean/string) - If true, then config will be saved to "moddata/ModName/ModName.lua". Or you can specify different folder name.
Example: Azimuth.saveConfig("MyMod", { WindowWidth = 300 })
Example: Azimuth.saveConfig("MyMod", { WindowWidth = 300 }, { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600 }}, true)
]]
function Azimuth.saveConfig(modName, config, options, isSeedDependant, modFolder)
    local dir = moddata
    if modFolder then
        if modFolder == true then
            modFolder = modName
        end
        dir = dir .. "/" .. modFolder
        if onClient() then
            --createDirectory(modFolder)
            createDirectory(dir)
        else
            createDirectory(dir)
        end
    end
    local filename = dir .. "/" .. modName .. (isSeedDependant and '_' .. GameSettings().seed or "") .. ".lua"
    local file, err = io.open(filename, "wb")
    if err then
        eprint("[ERROR]["..modName.."]: Failed to save config file '"..filename.."': " .. err)
        return false, err
    end
    file:write(Azimuth.serialize(config, options, "", true))
    file:close()
    return true
end


return Azimuth