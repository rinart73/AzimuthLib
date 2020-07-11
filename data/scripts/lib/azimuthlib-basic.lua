--- Basic module
---
--- * Saving & loading config files
--- * Logging functions with separate console and file log levels
--- * Ordered 'pairs' function
--- * 'serialize' function for debugging tables and serializing data
--- * Validation functions for int & float values
-- @usage local Azimuth = include("azimuthlib-basic")
-- @module Azimuth
local Azimuth = {}


local Log = {}
Log.__index = Log

--- Mod name
-- @within Log: Properties
-- @tparam string modName

--- When auto-serializing tables, should they be minified (one string without spaces)?
-- @within Log: Properties
-- @tparam bool minifyTables

--- When auto-serializing tables should tables display their address?
-- @within Log: Properties
-- @tparam bool showTableAddress

--- Log level for console output
--- Use Log:setLevel for changing log level
-- @within Log: Properties
-- @tparam[readonly] int consoleLogLevel
-- @see setLevel

--- Log level for file output
--- Use Log:setLevel for changing log level
-- @within Log: Properties
-- @tparam[readonly] int logLevel
-- @see setLevel

--- Used to understand if any of the log levels are big enough to write an error message in console/file
-- @within Log: Properties
-- @tparam[readonly] bool isError

--- If true, using :Warn will definetely print data in console or file
-- @within Log: Properties
-- @tparam[readonly] bool isWarning

--- If true, using :Info will definetely print data in console or file
-- @within Log: Properties
-- @tparam[readonly] bool isInfo

--- If true, using :Debug will definetely print data in console or file
-- @within Log: Properties
-- @tparam[readonly] bool isDebug

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

--- Logs an error if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Error
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
-- @usage logs:Error("Something went wrong")
-- @usage mylogs:Error("Ship '%s' got error code '%i' at coordinates: %s", Entity().name, errorCode, {x = 15, y = 28})
function Log:Error(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        --[[if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath())
        end]]
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
        eprint("[ERROR][%s]: "..msg, self.modName, unpack(args))
    else
        printlog("[ERROR][%s]: "..msg, self.modName, unpack(args))
    end
end

--- Logs a warning if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Warn
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
-- @usage logs:Warn("Warning message")
-- @usage mylogs:Warn("A deprecated method '%s' was used", methodName)
function Log:Warn(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        --[[if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath())
        end]]
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
        print("[WARN][%s]: "..msg, self.modName, unpack(args))
    else
        printlog("[WARN][%s]: "..msg, self.modName, unpack(args))
    end
end

--- Logs an info message if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Info
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
function Log:Info(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        --[[if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath())
        end]]
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
        print("[INFO][%s]: "..msg, self.modName, unpack(args))
    else
        printlog("[INFO][%s]: "..msg, self.modName, unpack(args))
    end
end

--- Logs a debug message if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Debug
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
function Log:Debug(msg, ...)
    -- temporary backwards compatibility
    local oldMsg
    if type(self) ~= 'table' then
        --[[if not Azimuth._logWarning then
            Azimuth._logWarning = true
            print("[WARN][AzimuthLib]: One of the mods in the file '%s' uses the old way to calling log functions via dot (eg '.Debug'). Use colons now (eg ':Debug'). Right now it will still work but can result in log mix-ups, but in the future versions backwards compatibility will be removed and this will result in an error instead.", getScriptPath())
        end]]
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
        print("[DEBUG][%s]: "..msg, self.modName, unpack(args))
    else
        printlog("[DEBUG][%s]: "..msg, self.modName, unpack(args))
    end
end

--- Changes log level
-- @within Log: Methods
-- @function setLevel
-- @tparam int consoleLogLevel — Determines which level messages will be displayed in a console. 1 - Errors, 2 - Errors & Warnings, 3 - E & W & Info, 4 - E & W & I & Debug
-- @tparam[opt=consoleLogLevel] int logLevel — Same as consoleLogLevel, but messages will be written only in log file, not console
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

--- Creates a new instance of the Log object
-- @tparam string modName — Your mod name
-- @tparam int consoleLogLevel — Determines which level messages will be displayed in a console:
--
-- * 1 - Errors
-- * 2 - Errors & Warnings
-- * 3 - Errors & Warnings & Info
-- * 4 - Errors & Warnings & Info & Debug
-- @tparam[opt=consoleLogLevel] int logLevel — Same as consoleLogLevel, but messages will be written only in log file, not console
-- @treturn Log log — an instance of the Log class
-- @usage local Logs = Azimuth.logs("MyModName", 2)
-- @usage local Logs = Azimuth.logs("MyModName", 2, 4)
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

--- Allows to iterate a table by key in alphabetical order
-- @tparam table tbl — Table
-- @tparam[opt] function sort  — Sorting function for keys
-- @tparam[opt] table ref — A reference table, orderedPairs will add the 'len' attrute to it
-- @treturn function iterator
-- @usage for k, v in Azimuth.orderedPairs(myTable, function(tbl, firstKey, secondKey) return tbl[firstKey] < tbl[secondKey] end) do
--     print(k, v)
-- end
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

--- Serializes table as readable multi-line text
-- @tparam table o — Table for serialization
-- @tparam[opt] table options — Since this function was initially meant to aid in saving config files, you can add default value and commentary to the each top-level variable
-- @tparam[opt=""] string prefix — Line prefix, used by the function itself (default: "")
-- @tparam[opt=false] bool addCarriageReturn — If true, function will use "\r\n" as new line instead of "\n". False by default because "\r\n" messes up Avorion file logs
-- @tparam[opt=false] bool minify — If true, the resulting string won't have spaces and line breaks. Disables 'prefix' and 'options'
-- @tparam[opt=false] bool recursive — If true, the resulting table dump will have "__address" field for each non-empty table, containing its address
-- @treturn string result — Serialized table
-- @usage print(Azimuth.serialize(myTable))
-- @usage print(Azimuth.serialize({ myVar = 30 }, { myVar = { default = 20, comment = "This variable does stuff" } }))
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

--- Loads mod config from file
-- @tparam string modName — Mod name (file name)
-- @tparam table options — Config options with default values and comments. Each element of the table can have following propertiesː
--
-- * var default — Default value of a variable
-- * number min/max *(optional)* — Minimum and maximum values of a variable (if it's a number)
-- * string format *(optional)* — Selected way of rounding will be applied for loaded numeric variable (can be 'floor', 'round' or 'ceil')
-- @tparam[opt=false] bool isSeedDependant — Set to true if config is specific for this server (it's useful only on client side)
-- @tparam[opt=false] bool/string modFolder — If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name
-- @treturn table modConfig — Loaded mod config table
-- @treturn var status — Error/status Can be one of the followingː
--
-- * string — It's an error message.
-- * number, 1 — File wasn't found. It's a hint that you should re-save the config.
-- * number, 0 — Config was successfully loaded, but was modified by `options` (maybe some variable didn't fit in the boundaries). It's a hint that you should re-save the config.
-- * nil — Config was successfully loaded, no modifications were made.
-- @usage local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = { default = 300 } })
-- @usage local configOptions = {
--   WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600, format = "ceil" }
-- }
-- local modConfig, isModified = Azimuth.loadConfig("MainConfigFile", configOptions, true, "MyMod")
-- if isModified then
--     Azimuth.saveConfig("MainConfigFile", modConfig, configOptions, true, "MyMod")
-- end
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

--- Saves mod config to file
-- @tparam string modName — Mod name (file name)
-- @tparam table config — Mod config table
-- @tparam[opt] table options — Config options with default values and comments. Each element of the table can have following propertiesː
--
-- * var default *(optional)* — Default value of a variable. Will be added to a commentary unless it's a table
-- * string comment *(optional)* — Variable description 
-- @tparam[opt=false] bool isSeedDependant — Set to true if config is specific for this server (it's useful only on client side)
-- @tparam[opt=false] bool/string modFolder — If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name
-- @tparam[opt=false] bool minify — If true, strips saved config of all spaces and new lines
-- @treturn bool success
-- @treturn string/nil error — Explains what went wrong
-- @usage local configOptions = {
--   WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600, format = "ceil" }
-- }
-- Azimuth.saveConfig("MainConfigFile", modConfig, configOptions, false, "MyMod")
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

--- Validation function that checks if a value is not empty, correct type and within borders
-- @tparam var value — Any variable for checking
-- @tparam table bounds — 2-element table with lower and upper bounds. If isBoundsEnum is true however, it will be considered a table that contains all allowed values
-- @tparam[opt] number default — If nil, incorrect value with result in nil. If number, incorrect value will return specified default value
-- @tparam[opt=false] number isBoundsEnum — Signals that bounds is a enum of allowed values
-- @treturn nil/float result
-- @treturn bool isModified — If true, value was incorrect in some way
-- @usage -- if incorrect returns nil. if outside of bounds returns closes bound
--local result = Azimuth.getFloat(value, {4.4, 15})
-- @usage -- if incorrect returns default value (5.3). if outside of bounds, returns closest bound
--local result = Azimuth.getFloat(value, {4.4, 15}, 5.3)
-- @usage -- bounds are treated like enum instead. if incorrect/doesn't match enum, returns default (5.3)
-- local result, isModified = Azimuth.getFloat(value, {4.4, 5.3, 9.9}, 5.3, true)
-- if isModified then
--     print("passed value was originally invalid")
-- end
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

--- Validation function that checks if a value is not empty, correct type and within borders
-- @tparam var value — Any variable for checking
-- @tparam table bounds — 2-element table with lower and upper bounds. If isBoundsEnum is true however, it will be considered a table that contains all allowed values
-- @tparam[opt] number default — If nil, incorrect value with result in nil. If number, incorrect value will return specified default value
-- @tparam[opt=false] number isBoundsEnum — Signals that bounds is a enum of allowed values
-- @treturn nil/int result
-- @treturn bool isModified — If true, value was incorrect in some way
-- @usage -- if incorrect returns nil. if outside of bounds returns closes bound
--local result = Azimuth.getInt(value, {4, 15})
-- @usage -- if incorrect returns default value (5). if outside of bounds, returns closest bound
--local result = Azimuth.getInt(value, {4, 15}, 5)
-- @usage -- bounds are treated like enum instead. if incorrect/doesn't match enum, returns default (5)
--local result, isModified = Azimuth.getInt(value, {4, 5, 9}, 5, true)
function Azimuth.getInt(value, bounds, default, isBoundsEnum)
    value = tonumber(value)
    if not value then return default, true end
    return Azimuth.getFloat(math.floor(value), bounds, default, isBoundsEnum)
end

return Azimuth