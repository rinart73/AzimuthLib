--- Basic module
---
--- * Saving & loading config files
--- * Logging functions with separate console and file log levels
--- * Ordered 'pairs' function
--- * 'serialize' function for debugging tables and serializing data
--- * Validation functions for int, float and table values
-- @usage local Azimuth = include("azimuthlib-basic")
-- @module Azimuth

include("utility")

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
    if 1 <= self.consoleLogLevel then
        eprint("[ERROR][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    elseif 1 <= self.logLevel then
        printlog("[ERROR][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
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
    if 2 <= self.consoleLogLevel then
        print("[WARN][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    elseif 2 <= self.logLevel then
        printlog("[WARN][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    end
end

--- Logs an info message if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Info
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
function Log:Info(msg, ...)
    if 3 <= self.consoleLogLevel then
        print("[INFO][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    elseif 3 <= self.logLevel then
        printlog("[INFO][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    end
end

--- Logs a debug message if specified consoleLogLevel & logLevel allow that
-- @within Log: Methods
-- @function Debug
-- @tparam string msg — Log message. May include %s, %d and other parameters similarly to the string.format
-- @tparam var.. ... — Various arguments
function Log:Debug(msg, ...)
    if 4 <= self.consoleLogLevel then
        print("[DEBUG][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
    elseif 4 <= self.logLevel then
        printlog("[DEBUG][%s]: "..msg, self.modName, unpack(self:_transformArgs(...)))
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
    return newLog
end


--- Allows to iterate a table by key in alphabetical or custom order
-- @tparam table tbl — Table
-- @tparam[opt] function sort — Sorting function for keys
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
-- @usage print(Azimuth.serialize({myVar = 30}, {myVar = {default = 20, comment = "This variable does stuff"}}))
-- @usage print(Azimuth.serialize({myVar = 30}, {["myVar"] = {20, comment = "This variable does stuff" }}))
function Azimuth.serialize(o, options, prefix, addCarriageReturn, minify, recursive)
    if type(o) ~= "table" then
        return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
    end

    if minify then options = nil end
    if options then
        options = Azimuth._prepareOptions(options)
    end
    if not prefix or minify then prefix = "" end
    if recursive == true or not recursive then
        recursive = { isDebug = recursive == true, tables = {} }
    end
    local endL = ""
    if not minify then
        endL = addCarriageReturn and "\r\n" or "\n"
    end

    local function _serialize(o, options, endL, prefix, minify, recursive)
        if type(o) ~= "table" then
            return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
        end
        local address = tostring(o)
        if recursive.tables[address] then -- recursion
            return '{["__recursion"]="'..address..'"}' or '{["__recursion"] = "'..address..'"}'
        end
        if options and options._ then
            options = options._
        end
        local s = "{"
        local newPrefix = minify and "" or prefix.."  "
        local hasTableChild = false
        local isList, length = Azimuth.isList(o)
        if isList then
            for k = 1, length do
                local v = o[k]
                if not hasTableChild and type(v) == "table" then
                    recursive.tables[address] = true
                    hasTableChild = true
                end
                local fieldOptions
                if options then
                    fieldOptions = options["*"]
                    if not fieldOptions then fieldOptions = options[k] end
                end
                s = s..(k == 1 and endL or ","..endL)..newPrefix.._serialize(v, fieldOptions, endL, newPrefix, minify, recursive)
            end
        else -- normal table
            local i = 0
            local ref = {} -- stores table length
            for k, v in Azimuth.orderedPairs(o, nil, ref) do
                i = i + 1
                if i == 1 and not minify then
                    s = s..endL
                end
                local fieldOptions
                if options then
                    fieldOptions = options["*"]
                    if not fieldOptions then fieldOptions = options[k] end
                end
                if fieldOptions then
                    -- multiline comments
                    local commentStart, commentEnd = "-- ", ""
                    local comment
                    if fieldOptions.comment then
                        local count
                        comment, count = fieldOptions.comment:gsub("([\r\n]%s*)", endL..newPrefix)
                        if count > 0 then
                            commentStart, commentEnd = "--[=[", "]=]"
                        end
                    end
                    local default = fieldOptions[1] and fieldOptions[1] or fieldOptions.default
                    if fieldOptions.comment ~= false and default ~= nil and type(default) ~= "table" then
                        s = s..newPrefix..commentStart.."Default: "..tostring(default)..(comment and ". "..comment or "")..commentEnd..endL
                    elseif comment then
                        s = s..newPrefix..commentStart..comment..commentEnd..endL
                    end
                end
                if type(k) ~= 'number' then
                    k = '"'..tostring(k):gsub("([\"\\])", "\\%1")..'"'
                end
                if not hasTableChild and type(v) == "table" then
                    recursive.tables[address] = true
                    hasTableChild = true
                end
                if minify then
                    s = s..(i == 1 and "[" or ",[")..k.."]=".._serialize(v, fieldOptions, endL, newPrefix, minify, recursive)
                else
                    s = s..newPrefix.."["..k.."] = ".._serialize(v, fieldOptions, endL, newPrefix, minify, recursive)
                    if i < ref.len then
                        s = s..","..endL
                    end
                end
            end
        end
        -- write table address
        if recursive.isDebug and not (isList and length == 0) then
            s = s..","..endL..newPrefix..(minify and '["__address"]="' or '["__address"] = "')..address..'"'
        end
        if isList and length == 0 then -- empty
            s = s.."}"
        else
            s = s..endL..prefix.."}"
        end
        return s
    end

    return _serialize(o, options, endL, prefix, minify, recursive)
end

--- Loads mod config from file
-- @tparam string modName — Mod name (file name)
-- @tparam table options — Config options with default values (key [1] or ["default"]) and other optional properties. More about config options: @{config-options.lua}
-- @tparam[opt=false] bool isSeedDependant — Set to true if config is specific for this server (it's useful only on client side)
-- @tparam[opt=false] bool/string modFolder — If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name
-- @treturn table modConfig — Loaded mod config table
-- @treturn var status — Error/status. Can be one of the followingː
--
-- * string — It's an error message.
-- * number, 1 — File wasn't found. It's a hint that you should re-save the config.
-- * number, 0 — Config was successfully loaded, but was modified by `options` (maybe some variable didn't fit in the boundaries). It's a hint that you should re-save the config.
-- * nil — Config was successfully loaded, no modifications were made.
-- @usage local tbl = Azimuth.loadConfig("MyMod", { WindowWidth = {300} })
-- @usage local configOptions = {
--   WindowWidth = {300, round = 1, min = 100, max = 600, comment = "UI window width"}
-- }
-- local modConfig, isModified = Azimuth.loadConfig("MainConfigFile", configOptions, true, "MyMod")
-- if isModified then
--     Azimuth.saveConfig("MainConfigFile", modConfig, configOptions, true, "MyMod")
-- end
function Azimuth.loadConfig(modName, options, isSeedDependant, modFolder)
    local newFormat
    for k, v in pairs(options) do
        if k ~= "__prepared" then
            newFormat = v.default == nil
            break
        end
    end
    local getDefaultConfig
    if newFormat then
        getDefaultConfig = function() return Azimuth.validate(nil, options) end
    else
        getDefaultConfig = function()
            local r = {}
            for k, v in pairs(options) do
                r[k] = v.default
            end
            return r
        end
    end

    local dir = "moddata"
    if onServer() then
        dir = Server().folder.."/"..dir
    end
    if modFolder then
        if modFolder == true then
            modFolder = modName
        end
        dir = dir.."/"..modFolder
    end
    local filename = dir.."/"..modName..(isSeedDependant and "_"..GameSettings().seed or "")..".lua"

    local file, err = io.open(filename, "rb")
    if err then
        if not err:find("No such file or directory", 1, true) then
            eprint("[ERROR][%s]: Failed to load config file '%s': %s", modName, filename, err)
            return getDefaultConfig(), err
        else
            return getDefaultConfig(), 1 -- file wasn't found
        end
    end
    local fileContents = file:read("*all") or ""
    local data, err = loadstring("return "..fileContents)
    file:close()
    if not data then
        eprint("[ERROR][%s]: Failed to load config file '%s': %s; File contents: %s", modName, filename, err, fileContents)
        return getDefaultConfig(), err
    end
    data = data()
    if type(data) ~= "table" then -- empty file
        return getDefaultConfig(), 0
    end

    local isModified = false -- if modified is false, there is no need to rewrite config file
    if newFormat then
        data, isModified = Azimuth.validate(data, options)
    else -- old
        -- check if config variables are present and correct
        local rv
        for k, v in pairs(options) do
            rv = data[k]
            if rv == nil or type(rv) ~= type(v.default) then
                data[k] = v.default
                isModified = true
            else
                if v.format then
                    if v.format == "ceil" then
                        value = math.ceil(data[k])
                        isModified = isModified or (data[k] ~= value)
                        data[k] = value
                    elseif v.format == "round" then
                        if data[k] >= 0 then
                            value = math.floor(data[k] + 0.5)
                            isModified = isModified or (data[k] ~= value)
                            data[k] = value
                        else
                            value = math.ceil(data[k] - 0.5)
                            isModified = isModified or (data[k] ~= value)
                            data[k] = value
                        end
                    elseif v.format == "floor" then
                        value = math.floor(data[k])
                        isModified = isModified or (data[k] ~= value)
                        data[k] = value
                    end
                end
                if v.min and rv < v.min then
                    data[k] = v.min
                    isModified = true
                elseif v.max and rv > v.max then
                    data[k] = v.max
                    isModified = true
                end
            end
        end
    end

    isModified = isModified and 0 or nil
    return data, isModified
end

--- Saves mod config to file
-- @tparam string modName — Mod name (file name)
-- @tparam table config — Mod config table
-- @tparam[opt] table options — Config options with default values and comments. Each element of the table can have following propertiesː
--
-- * var [1] *(optional)* — Default value of a variable (new format). Will be added to a commentary unless it's a table
-- * var default *(optional)* — Default value of a variable (old format). Will be added to a commentary unless it's a table
-- * string comment *(optional)* — Variable description 
-- @tparam[opt=false] bool isSeedDependant — Set to true if config is specific for this server (it's useful only on client side)
-- @tparam[opt=false] bool/string modFolder — If true, then config will be loaded from "moddata/ModName/ModName.lua". Or you can specify different folder name
-- @tparam[opt=false] bool minify — If true, strips saved config of all spaces and new lines
-- @treturn bool success
-- @treturn string/nil error — Explains what went wrong
-- @usage local configOptions = {
--   WindowWidth = {300, min = 100, max = 600, round = -1, comment = "UI window width"}
-- }
-- Azimuth.saveConfig("MainConfigFile", modConfig, configOptions, false, "MyMod")
function Azimuth.saveConfig(modName, config, options, isSeedDependant, modFolder, minify)
    local dir = "moddata"
    if onServer() then
        dir = Server().folder.."/"..dir
    end
    if modFolder then
        if modFolder == true then
            modFolder = modName
        end
        dir = dir.."/"..modFolder
        createDirectory(dir)
    end
    local filename = dir.."/"..modName..(isSeedDependant and "_"..GameSettings().seed or "")..".lua"
    local file, err = io.open(filename, "wb")
    if err then
        eprint("[ERROR][%s]: Failed to save config file '%s': %s", modName, filename, err)
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

--- Validation function that checks if a table is a proper list (numerical keys only, no gaps). Can transform table into list if required
-- @tparam table o — Input table
-- @tparam[opt=false] bool fix — If true, function will return 'fixed' list
-- @treturn bool isValidList
-- @treturn int listLength
-- @treturn table fixedList
function Azimuth.isList(o, fix)
    local isList = true
    local minKey = math.huge
    local maxKey = 0
    local i = 0
    local list = fix and {} or nil
    for k, v in pairs(o) do
        if type(k) ~= 'number' then
            isList = false
            if not fix then return false, i end
        else
            if k < minKey then minKey = k end
            if k > maxKey then maxKey = k end
        end
        i = i + 1
        if fix then
            list[i] = v
        end
    end
    isList = isList and minKey == 1 and maxKey == i
    return isList, i, list
end

local function getDefault(options)
    if options.optional then return end
    if type(options[1]) ~= "table" then return options[1] end
    return table.deepcopy(options[1])
end

function Azimuth._prepareOptions(options)
    if options.__prepared then return options end

    for k, v in Azimuth.orderedPairs(options) do
        local parts = k:split(".")
        local length = #parts
        if length > 1 then
            local path = parts[1]
            if not options[parts[1]] then
                options[parts[1]] = {{}, _ = {}}
            end
            local obj = options[parts[1]]
            if not obj._ then
                obj._ = {}
            end
            obj = obj._
            for i = 2, length - 1 do
                local part = parts[i]
                if not obj[part] then
                    obj[part] = {{}, _ = {}}
                end
                if not obj[part]._ then
                    obj[part]._ = {}
                end
                obj = obj[part]._
            end
            if not obj[parts[length]] then
                obj[parts[length]] = table.deepcopy(v)
            end
            options[k] = nil
        end
    end

    options.__prepared = true
    return options
end

function Azimuth._validateVar(value, options)
    if value == nil and options.optional then return end

    local isModified = false

    local dtype = type(options[1])
    if type(value) ~= dtype then
        if value ~= nil and dtype == "string" then
            value = tostring(value)
            isModified = true
        elseif dtype == "number" then
            value = tonumber(value)
            isModified = true
            if value == nil then
                return getDefault(options), true
            end
        elseif dtype == "table" and options._ then -- continue to check table fields
            value = getDefault(options)
            isModified = true
        else
            return getDefault(options), true
        end
    end

    if dtype == "string" then
        if options.len then -- TODO: Use UTF8 when asked to
            local length = value:len()
            if length < options.len[1] then
                return getDefault(options), true
            elseif length > options.len[2] then
                value = value:sub(1, options.len[2])
                isModified = true
            end
        end
        if options.upper then
            local newValue = value:upper()
            if value ~= newValue then isModified = true end
            value = newValue
        elseif options.lower then
            local newValue = value:lower()
            if value ~= newValue then isModified = true end
            value = newValue
        end
        if options.pattern and not value.find(options.pattern) then
            return getDefault(options), true
        end
    elseif dtype == "number" then
        if options.round then
            if options.round == -1 then
                local newValue = math.floor(value)
                if value ~= newValue then isModified = true end
                value = newValue
            elseif options.round == 0 then
                local newValue = round(value)
                if value ~= newValue then isModified = true end
                value = newValue
            else -- 1
                local newValue = math.ceil(value)
                if value ~= newValue then isModified = true end
                value = newValue
            end
        end
        if options.min and value < options.min then
            value = options.min
            isModified = true
        elseif options.max and value > options.max then
            value = options.max
            isModified = true
        end
    end

    if options.enum then
        local found = false
        for k, v in ipairs(options.enum) do
            if v == value then
                found = true
                break
            end
        end
        if not found then
            return getDefault(options), true
        end
    end

    if options._ then -- table with fields
        local varModified, isValid
        value, varModified, isValid = Azimuth._validateFields(value, options._, options.list)
        if not isValid and options.required then
            return nil, true
        end
        isModified = isModified or varModified
    end

    return value, isModified, true
end

function Azimuth._validateFields(data, options, listExpected)
    local isModified = false
    local varModified, isValid
    for k, v in pairs(options) do
        if k ~= "*" and k ~= "__prepared" then
            if listExpected then
                k = tonumber(k)
            end
            if k then
                data[k], varModified, isValid = Azimuth._validateVar(data[k], v)
                if not isValid and v.required then -- important field is invalid, remove the whole category
                    return nil, true
                end
                isModified = isModified or varModified
            end
        end
    end
    if options["*"] then
        for k, v in pairs(data) do
            data[k], varModified = Azimuth._validateVar(v, options["*"])
            isModified = isModified or varModified
        end
    end
    if listExpected then
        varModified, _, data = Azimuth.isList(data, true)
        isModified = isModified or varModified
    end
    return data, isModified, true
end

--- Validation function that allows to check and fix input data with the use of a config options table. Works **ONLY** for the **NEW** config options format
-- @tparam table data
-- @tparam table options
-- @treturn table fixedData
-- @treturn bool isModified
-- @treturn bool _
function Azimuth.validate(data, options)
    options = Azimuth._prepareOptions(options)
    return Azimuth._validateFields(data or {}, options)
end

return Azimuth