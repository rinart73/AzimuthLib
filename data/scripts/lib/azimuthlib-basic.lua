-- Provides an easy way of saving and loading config files. Also adds other useful functions.

local format = string.format

local AzimuthBasic = {}

-- logs(modname, consoleLogLevel [, logLevel])
--[[ Initializes logs.
* modname - Mod name.
* consoleLogLevel - Console log level.
* logLevel - File log level. If not specified, consoleLogLevel will be used instead.
Example: local Log = AzimuthBasic.logs("MyMod", 2)
Example: local Log = AzimuthBasic.logs("MyMod", config.consoleLogLevel, config.logLevel)
Log.Info("Some info, player name: %s", player.name) ]]
function AzimuthBasic.logs(modname, consoleLogLevel, logLevel)
    local log = {
      modname = modname,
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
            eprint(format("[ERROR][%s]: "..msg, log.modname, ...))
        elseif 1 <= log.logLevel then
            printlog(format("[ERROR][%s]: "..msg, log.modname, ...))
        end
    end
    log.Warn = function(msg, ...)
        if 2 <= log.consoleLogLevel then
            print(format("[WARN][%s]: "..msg, log.modname, ...))
        elseif 2 <= log.logLevel then
            printlog(format("[WARN][%s]: "..msg, log.modname, ...))
        end
    end
    log.Info = function(msg, ...)
        if 3 <= log.consoleLogLevel then
            print(format("[INFO][%s]: "..msg, log.modname, ...))
        elseif 3 <= log.logLevel then
            printlog(format("[INFO][%s]: "..msg, log.modname, ...))
        end
    end
    log.Debug = function(msg, ...)
        if 4 <= log.consoleLogLevel then
            print(format("[DEBUG][%s]: "..msg, log.modname, ...))
        elseif 4 <= log.logLevel then
            printlog(format("[DEBUG][%s]: "..msg, log.modname, ...))
        end
    end
    return log
end

-- for k, v in orderedPairs(myTable) do
--[[ Allows to iterate table by key in alphabetical order. ]]
function AzimuthBasic.orderedPairs(t, f)
    local a = {}
    for n in pairs(t) do
        a[#a+1] = n
    end
    table.sort(a, f)

    local i = 0 -- iterator variable
    local iter = function () -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end

    return iter
end

-- serialize(o [, options [, prefix [, addCarriageReturn ]]])
--[[ Serializes variable as readable multiline text.
* o - Table for serialization.
* options - Optional argument. Since this function was initially meant to aid in saving config files, you can add default value and commentary to each variable.
* prefix - Default: "". Line prefix, used by the function itself.
* addCarriageReturn - If true, function uses "\r\n" as new line instead of "\n". False by default because it messes up Avorion file logs.
Example: serialize(myTable)
Example: serialize({ myVar = 30 }, { myVar = { default = 20, comment = "This variable does stuff" } }) ]]
function AzimuthBasic.serialize(o, options, prefix, addCarriageReturn)
    if not options then options = {} end
    if not prefix then prefix = "" end

    if type(o) == 'table' then
        local s = addCarriageReturn and "{\r\n" or "{\n"
        local newprefix = prefix .. "  "
        -- check if it's a list
        local isList = true
        local minKey = math.huge
        local maxKey = 0
        local numVars = 0
        for k,_ in pairs(o) do
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
                s = s .. newprefix .. AzimuthBasic.serialize(o[k], options, newprefix, addCarriageReturn) .. (addCarriageReturn and ",\r\n" or ",\n")
            end
        else -- write as usual table
            local ov
            for k,v in AzimuthBasic.orderedPairs(o) do
                ov = options[k]
                if ov then
                    if ov.default ~= nil and type(ov.default) ~= "table" then
                        s = s .. newprefix .. "-- Default: " .. tostring(ov.default) .. (ov.comment and ". " .. ov.comment or "") .. (addCarriageReturn and "\r\n" or "\n")
                    elseif ov.comment then
                        s = s .. newprefix .. "-- " .. ov.comment .. (addCarriageReturn and "\r\n" or "\n")
                    end
                end
                if type(k) ~= 'number' then
                    k = '"' .. k .. '"'
                end
                s = s .. newprefix .. '[' .. k .. '] = ' .. AzimuthBasic.serialize(v, options, newprefix, addCarriageReturn) .. (addCarriageReturn and ",\r\n" or ",\n")
            end
        end
        s = s .. prefix .. "}"
        return s
    else
        return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
    end
end

-- loadConfig(modname, options [, isSeedDependant])
--[[ Loads mod config from file.
* modname - String with modname.
* options - Config options with default values and comments. Default values are required.
* isSeedDependant - true if config is specific for this server. false otherwise (useful only on client side).
* inModFolder - if true, then config will be loaded from "moddata/ModName/ModName.lua".
Returns:
1. Config table.
2. Error/status. Can be one of the following:
  * String, it's an error message.
  * Number, 1 - means that file wasn't found.
  * Number, 0 - config was successfully loaded, but was modified by `options`. You'll probably want to resave it.
  * Nil, config was successfully loaded, no modifications were made.
Example: loadConfig("MyMod", { WindowWidth = { default = 300 } })
Example: loadConfig("MyMod", { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600, format = "ceil" } }, true) ]]
function AzimuthBasic.loadConfig(modname, options, isSeedDependant, inModFolder)
    local defaultValues = {}
    for k, v in pairs(options) do
        defaultValues[k] = v.default
    end

    local dir = "moddata"
    if onServer() then
        dir = Server().folder .. "/" .. dir
    end
    if inModFolder then
        dir = dir .. "/" .. modname
        createDirectory(dir)
    end
    local filename = dir .. "/" .. modname .. (isSeedDependant and '_' .. GameSettings().seed or "") .. ".lua"
    local file, err = io.open(filename, "rb")
    if err then
        if not err:find("No such file or directory", 1, true) then
            eprint("[ERROR]["..modname.."]: Failed to load config file '"..filename.."': " .. err)
            return defaultValues, err
        else
            return defaultValues, 1 -- file wasn't found
        end
    end
    local fileContents = file:read("*all") or ""
    local result, err = loadstring("return " .. fileContents)
    file:close()
    if not result then
        eprint("[ERROR]["..modname.."]: Failed to load config file '"..filename.."': " .. err .. "; File contents: "..fileContents)
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

-- saveConfig(modname, config [, options [, isSeedDependant,]])
--[[ Saves mod config to file.
* modname - String with modname.
* config - Config table.
* options - Config options with default values and comments.
* isSeedDependant - true if config is specific for this server. false otherwise.
* inModFolder - if true, then config will be saved to "moddata/ModName/ModName.lua".
Example: saveConfig("MyMod", { WindowWidth = 300 })
Example: saveConfig("MyMod", { WindowWidth = 300 }, { default = 300, comment = "UI window width", min = 100, max = 600 }, true) ]]
function AzimuthBasic.saveConfig(modname, config, options, isSeedDependant, inModFolder)
    local dir = "moddata"
    if onServer() then
        dir = Server().folder .. "/" .. dir
    end
    if inModFolder then
        dir = dir .. "/" .. modname
        createDirectory(dir)
    end
    local filename = dir .. "/" .. modname .. (isSeedDependant and '_' .. GameSettings().seed or "") .. ".lua"
    local file, err = io.open(filename, "wb")
    if err then
        eprint("[ERROR]["..modname.."]: Failed to save config file '"..filename.."': " .. err)
        return false, err
    end
    file:write(AzimuthBasic.serialize(config, options, "", true))
    file:close()
    return true
end

return AzimuthBasic