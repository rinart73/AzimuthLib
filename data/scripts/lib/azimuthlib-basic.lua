--[[ This file provides:
* Saving & loading config files
* Logging functions with separate console and file log levels
* Ordered 'pairs' function
* 'serialize' function for debugging tables and serializing data
* Validation functions for int & float values

To use it you'll need to include it first: local Azimuth = include("azimuthlib-basic")
]]

local Azimuth = {}

local format = string.format

local Log = {}
Log.__index = Log

-- Logs use this function to serialize tables, boolean and nil values
function Log:_transformArgs(...)
    local argType
    local arg = table.pack(...)
    for i = 1, arg.n do
        argType = type(arg[i])
        if argType == "table" then
            arg[i] = Azimuth.serialize(arg[i], nil, nil, nil, self.minifyTables, self.showTableAddress)
        elseif argType == "boolean" or argType == "nil" then
            arg[i] = tostring(arg[i])
        end
    end
    return arg
end

-- API --

-- Error(string msg, var ...)
--[[ Examples:
logs:Error("Something went wrong")
logs:Error("Function returned error code: %i", errorCode)
logs:Error("Ship '%s' got error code '%i' at coordinates: %s", Entity().name, errorCode, {x = 15, y = 28})
]]
function Log:Error(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print(format("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath()))
        end
        oldMsg = msg
        msg = self
        self = Azimuth._log
    end
    if 1 > self.consoleLogLevel and 1 > self.logLevel then return end
    local args
    if oldMsg then -- old .
        args = self:_transformArgs(oldMsg, ...)
    else -- new :
        args = self:_transformArgs(...)
    end
    if 1 <= self.consoleLogLevel then
        eprint(format("[ERROR][%s]: "..msg, self.modName, unpack(args)))
    else
        printlog(format("[ERROR][%s]: "..msg, self.modName, unpack(args)))
    end
end

-- Warn(string msg, var ...)
--[[ Examples:
logs:Warn("Warning message")
logs:Warn("A deprecated method '%s' was used", methodName)
logs:Warn("Ship '%s' got unusal function result '%s' at coordinates: (%i:%i)", Entity().name, tblResult, sx, sy)
]]
function Log:Warn(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print(format("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath()))
        end
        oldMsg = msg
        msg = self
        self = Azimuth._log
    end
    if 2 > self.consoleLogLevel and 2 > self.logLevel then return end
    local args
    if oldMsg then -- old .
        args = self:_transformArgs(oldMsg, ...)
    else -- new :
        args = self:_transformArgs(...)
    end
    if 2 <= self.consoleLogLevel then
        print(format("[WARN][%s]: "..msg, self.modName, unpack(args)))
    else
        printlog(format("[WARN][%s]: "..msg, self.modName, unpack(args)))
    end
end

-- Info(string msg, var ...)
--[[ Examples:
logs:Info("That stuff happened")
logs:Info("Ship name is '%s'", Entity().name)
]]
function Log:Info(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print(format("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath()))
        end
        oldMsg = msg
        msg = self
        self = Azimuth._log
    end
    if 3 > self.consoleLogLevel and 3 > self.logLevel then return end
    local args
    if oldMsg then -- old .
        args = self:_transformArgs(oldMsg, ...)
    else -- new :
        args = self:_transformArgs(...)
    end
    if 3 <= self.consoleLogLevel then
        print(format("[INFO][%s]: "..msg, self.modName, unpack(args)))
    else
        printlog(format("[INFO][%s]: "..msg, self.modName, unpack(args)))
    end
end

-- Debug(string msg, var ...)
--[[ Examples:
logs:Debug("Step 5")
logs:Debug("Function '%s', passed arguments: %i, %s", 'myFunctionName', rarity.value, {...})
]]
function Log:Debug(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print(format("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath()))
        end
        oldMsg = msg
        msg = self
        self = Azimuth._log
    end
    if 4 > self.consoleLogLevel and 4 > self.logLevel then return end
    local args
    if oldMsg then -- old .
        args = self:_transformArgs(oldMsg, ...)
    else -- new :
        args = self:_transformArgs(...)
    end
    if 4 <= self.consoleLogLevel then
        print(format("[DEBUG][%s]: "..msg, self.modName, unpack(args)))
    else
        printlog(format("[DEBUG][%s]: "..msg, self.modName, unpack(args)))
    end
end

-- setLevel(int consoleLogLevel, int logLevel)
-- Changes log level
function Log:setLevel(consoleLogLevel, logLevel)
    logLevel = logLevel or consoleLogLevel
    local logMax = math.max(consoleLogLevel, logLevel)
    self.consoleLogLevel = consoleLogLevel
    self.logLevel = logLevel
    self.isError = logMax >= 1
    self.isWarning = logMax >= 2
    self.isInfo = logMax >= 3
    self.isDebug = logMax >= 4
end

-- Log logs(string modName, int consoleLogLevel [, int logLevel])
-- Creates a new instance of Log object
--[[ Arguments:
* string modName - Your mod name
* int consoleLogLevel - Log level that determines which data will be displayed in console. 1 - Errors, 2 - Errors & Warnings, 3 - E & W & Info, 4 - E & W & I & Debug
* int logLevel - (optional) Same as consoleLogLevel, but stuff will be written only in log file, not console
]]
--[[ Object properties:
* string modName - mod name
* bool minifyTables - when auto-serializing tables should they be minified (one string without spaces)?
* bool showTableAddress - when auto-serializing tables should tables display their address?
* int consoleLogLevel - log level for console output
* int logLevel - log level for file output
* bool isError - (read-only) used to understand if any of the log levels are big enough to write error in console/file
* bool isWarning - (read-only) if true, using :Warn will definetely print data in console or file
* bool isInfo - (read-only) if true, using :Info will definetely print data in console or file
* bool isDebug - (read-only) if true, using :Debug will definetely print data in console or file
]]
--[[ Object methods:
:Error(var msg, var ...) - Print error message
:Warn(var msg, var ...) - Print warning message
:Info(var msg, var ...) - Print info message
:Debug(var msg, var ...) - Print debug message
]]
--[[ Example:
local Logs = Azimuth.logs("MyModName", 2)
local Logs = Azimuth.logs("MyModName", 2, 4)
]]
function Azimuth.logs(modName, consoleLogLevel, logLevel)
    local newLog = setmetatable({
      modName = modName,
      minifyTables = false,
      showTableAddress = false
    }, Log)
    newLog:setLevel(consoleLogLevel, logLevel)

    -- temporary backwards compatibility
    Azimuth._log = newLog

    return newLog
end


-- orderedPairs(table tbl [, function sort [, table ref]])
-- Allows to iterate table by key in alphabetical order.
--[[ Args:
* table tbl - Table.
* function sort - Optional sorting function for keys.
* table ref - Optional table. orderedPairs will add the 'len' attrute to it
]]
--[[ Example:
for k, v in Azimuth.orderedPairs(myTable, function(tbl, firstKey, secondKey)
  return tbl[firstKey] < tbl[secondKey]
end) do
    print(k, v)
end
]]
function Azimuth.orderedPairs(tbl, sort, ref)
    local a = {}
    for n in pairs(tbl) do
        a[#a+1] = n
    end
    if ref then
        ref.len = #a
    end
    if sort then
        table.sort(a, function(a, b) return sort(tbl, a, b) end)
    else
        table.sort(a, function(a, b)
            if type(a) == type(b) then
                return a < b
            end
            return tostring(a) < tostring(b)
        end)
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

-- serialize(table o [, table options [, string prefix [, bool addCarriageReturn [, bool minify [, bool recursive]]]]])
-- Serializes table as readable multi-line text.
--[[ Args:
* table o - Table for serialization.
* table options - Optional argument. Since this function was initially meant to aid in saving config files, you can add default value and commentary to each variable.
* string prefix - Default: "". Line prefix, used by the function itself.
* bool addCarriageReturn - If true, function uses "\r\n" as new line instead of "\n". False by default because "\r\n" messes up Avorion file logs.
* bool minify - If true, the resulting string won't have spaces and line breaks. Disables 'prefix' and 'options'.
* bool recursive - If true, the resulting table dump will have "__address" field for each non-empty table, containing its address.
]]
--[[ Examples:
print(Azimuth.serialize(myTable))
print(Azimuth.serialize({ myVar = 30 }, { myVar = { default = 20, comment = "This variable does stuff" } }))
]]
function Azimuth.serialize(o, options, prefix, addCarriageReturn, minify, recursive)
    if type(o) == 'table' then
        if minify then options = nil end
        if not prefix or minify then prefix = "" end
        local newLine = ""
        if not minify then
            newLine = addCarriageReturn and "\r\n" or "\n"
        end
        if recursive == true or not recursive then
            recursive = { isDebug = recursive == true, tables = {} }
        end
        local tblString = tostring(o)
        if recursive.tables[tblString] then -- recursion
            return minify and '{["__recursion"]="'..tblString..'"}' or '{["__recursion"] = "'..tblString..'"}'
        end
        local s = "{"
        local newprefix = minify and "" or prefix .. "  "
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
        local hasTableAsChild = false
        if isList and minKey == 1 and maxKey == numVars then -- write as list
            for k = 1, numVars do
                local v = o[k]
                if not hasTableAsChild and type(v) == "table" then
                    recursive.tables[tblString] = true
                    hasTableAsChild = true
                end
                s = s .. (k == 1 and newLine or "," .. newLine) .. newprefix .. Azimuth.serialize(v, nil, newprefix, addCarriageReturn, minify, recursive)
            end
        else -- write as usual table
            local ov
            local i = 0
            local ref = {} -- table length
            for k, v in Azimuth.orderedPairs(o, nil, ref) do
                i = i + 1
                if i == 1 and not minify then
                    s = s .. newLine
                end
                ov = options and options[k]
                if ov then
                    if ov.default ~= nil and type(ov.default) ~= "table" then
                        s = s .. newprefix .. "-- Default: " .. tostring(ov.default) .. (ov.comment and ". " .. ov.comment or "") .. newLine
                    elseif ov.comment then
                        s = s .. newprefix .. "-- " .. ov.comment .. newLine
                    end
                end
                if type(k) ~= 'number' then
                    k = '"' .. tostring(k):gsub("([\"\\])", "\\%1") .. '"'
                end
                if not hasTableAsChild and type(v) == "table" then
                    recursive.tables[tblString] = true
                    hasTableAsChild = true
                end
                if minify then
                    s = s .. (i == 1 and '[' or ',[') .. k .. ']=' .. Azimuth.serialize(v, nil, newprefix, addCarriageReturn, minify, recursive)
                else
                    s = s .. newprefix .. '[' .. k .. '] = ' .. Azimuth.serialize(v, nil, newprefix, addCarriageReturn, minify, recursive)
                    if i < ref.len then
                        s = s .. "," .. newLine
                    end
                end
            end
        end
        -- write table address
        if recursive.isDebug and not (isList and numVars == 0) then
            s = s .. ',' .. newLine .. newprefix .. (minify and '["__address"]="' or '["__address"] = "')..tblString..'"'
        end
        if isList and numVars == 0 then -- empty
            s = s .. "}"
        else
            s = s .. newLine .. prefix .. "}"
        end
        return s
    else
        return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
    end
end

-- table, var loadConfig(string modName, table options [, bool isSeedDependant [, var inModFolder]])
-- Loads mod config from file
--[[ Args:
* string modName - Mod name.
* table options - Config options with default values and comments. Each element of the table can have following properties:
  default - Required. Default value of a variable.
  min/max (number) - Optional. Minimum and maximum value of a variable, if it's a number.
  format (string) - Optional. Can be 'floor', 'round' or 'ceil', selected way of rounding will be applied for loaded variable.
* bool isSeedDependant - True if config is specific for this server. false otherwise (useful only on client side).
* bool/string modFolder - If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name.
]]
--[[ Returns:
1. Config table.
2. Error/status. Can be one of the following:
  * String, it's an error message.
  * Number, 1 - means that file wasn't found. Hint: re-save the config.
  * Number, 0 - config was successfully loaded, but was modified by `options`. Hint: re-save the config.
  * Nil, config was successfully loaded, no modifications were made.
]]
--[[ Examples:
local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = { default = 300 } })
local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600, format = "ceil" } }, true)
]]
function Azimuth.loadConfig(modName, options, isSeedDependant, modFolder)
    local defaultValues = {}
    for k, v in pairs(options) do
        defaultValues[k] = v.default
    end
    local dir = "moddata"
    if onServer() then
        dir = Server().folder .. "/" .. dir
    end
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

-- bool, var saveConfig(string modName, table config [, table options [, bool isSeedDependant [, var inModFolder [, bool minify]]]])
--[[ Saves mod config to file.
* modName - Modname
* table config - Config table
* table options - Config options with default values and comments. Each element of the table can have following properties:
  default - Default value of a variable. Will be added to a commentary unless it's a table.
  comment (string) - Variable commentary.
* bool isSeedDependant - True if config is specific for this server, false otherwise.
* boolean/string modFolder - If true, then config will be saved to "moddata/ModName/ModName.lua". Or you can specify different folder name.
* bool minify - If true, strips saved config of all spaces and new lines
]]
--[[ Returns:
1. true/false - Success or not
2. string error - String that explains what went wrong
]]
--[[ Examples:
Azimuth.saveConfig("MyMod", { WindowWidth = 300 })
Azimuth.saveConfig("MyMod", { WindowWidth = 300 }, { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600 }}, true)
]]
function Azimuth.saveConfig(modName, config, options, isSeedDependant, modFolder, minify)
    local dir = "moddata"
    if onServer() then
        dir = Server().folder .. "/" .. dir
    end
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
    file:write(Azimuth.serialize(config, options, "", true, minify))
    file:close()
    return true
end

-- validation functions that check if value is empty, correct type and within borders
-- var, bool getFloat(value, table bounds [, var default [, bool isBoundsEnum]])
--[[ Returns:
var/float result
bool isModified - if true, value was incorrect in some way
]]
--[[ Peforms checks for float and returns it.
* value - Any variable for checking.
* table bounds - 2-element table with lower and upper bounds. If isBoundsEnum is true however, it will be considered a table that contains all allowed values.
* (optional) number default - If nil, incorrect value with result in nil. If number, incorrect value will return specified default value.
* (optional) bool isBoundsEnum - Signals that bounds is a enum of allowed values.
Examples:
* getFloat(value, {4.4, 15}) - if incorrect returns nil. if outside of bounds returns closes bound
* getFloat(value, {4.4, 15}, 5.3) -- if incorrect returns default (5.3). if outside of bounds, returns closes bound
* getFloat(value, {4.4, 5.3, 9.9}, 5.3, true) -- bounds are treated like enum instead. if incorrect/doesn't match enum, returns default (5.3)
]]
function Azimuth.getFloat(value, bounds, default, isBoundsEnum)
    value = tonumber(value)
    if not value then return default, true end
    if isBoundsEnum then
        local found = false
        for _, v in ipairs(bounds) do
            if v == value then
                found = true
                break
            end
        end
        if found then
            return value, false
        end
        return default, true
    else
        if value < bounds[1] then
            return bounds[1], true
        elseif value > bounds[2] then
            return bounds[2], true
        end
        return value, false
    end
end

-- int, bool getInt(value, table bounds [, var default [, bool isBoundsEnum]])
function Azimuth.getInt(value, bounds, default, isBoundsEnum)
    value = tonumber(value)
    if not value then return default, true end
    return Azimuth.getFloat(math.floor(value), bounds, default, isBoundsEnum)
end

return Azimuth