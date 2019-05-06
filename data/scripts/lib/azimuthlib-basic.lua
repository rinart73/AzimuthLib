--[[Provides an easy way to saving and loading config files in AppData. Also adds few useful functions.
Предоставляет возможности по сохранению и загрузке файлов конфигурации в AppData. Также добавляет несколько полезных ф-ий.
]]

local AzimuthBasic = {}

function AzimuthBasic.orderedPairs(t, f)
    local a = {}    
    for n in pairs(t) do
        a[#a+1] = n
    end    
    table.sort(a, f)
 
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
 
    return iter
end

-- serialize(o)
--[[ Serializes variable as readable multiline text.
Сериализует переменную в мультистрочный текст. ]]
function AzimuthBasic.serialize(o, options, prefix)
    if not options then options = {} end
    if not prefix then prefix = "" end

    if type(o) == 'table' then
        local s = "{\r\n"
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
                s = s .. newprefix .. AzimuthBasic.serialize(o[k], options, newprefix) .. ",\r\n"
            end
        else -- write as usual table
            local ov
            for k,v in AzimuthBasic.orderedPairs(o) do
                ov = options[k]
                if ov then
                    if ov.default ~= nil and type(ov.default) ~= "table" then
                        s = s .. newprefix .. "-- Default: " .. tostring(ov.default) .. (ov.comment and ". " .. ov.comment or "") .. "\r\n"
                    elseif ov.comment then
                        s = s .. newprefix .. "-- " .. ov.comment .. "\r\n"
                    end
                end
                if type(k) ~= 'number' then
                    k = '"' .. k .. '"'
                end
                s = s .. newprefix .. '[' .. k .. '] = ' .. AzimuthBasic.serialize(v, options, newprefix) .. ",\r\n"
            end
        end
        s = s .. prefix .. "}"
        return s
    else
        return type(o) == "string" and '"'..o:gsub("([\"\\])", "\\%1")..'"' or tostring(o)
    end
end

-- loadConfig(modname [, default [, isSeedDependant]])
--[[ Loads mod config from file.
Загружает конфигурацию мода из файла.
* modname - String with modname (Строка с названием мода).
* options - Config options with default values and comments. (Опции конфига с дефолтными значениями и комментариями).
* isSeedDependant - true if config is specific for this server. false otherwise (true если конфиг предназначен для конкретно этого сервера. Иначе false).
Example: loadConfig("MyMod", { WindowWidth = { default = 300, comment = "UI window width", min = 100, max = 600 } }, true) ]]
function AzimuthBasic.loadConfig(modname, options, isSeedDependant)
    local filename = modname .. "Config" .. (isSeedDependant and '_' .. GameSettings().seed or "")
    if onServer() then
        filename = Server().folder .. "/" .. filename
    end
    local defaultValues = {}
    for k, v in pairs(options) do
        defaultValues[k] = v.default
    end
    local file, err = io.open(filename .. ".lua", "r")
    if err then
        if not err:find("No such file or directory", 1, true) then
            eprint("[ERROR]["..modname.."]: Failed to load config file '"..filename.."': " .. err)
            return defaultValues, err
        else
            return defaultValues, 1
        end
    end
    local result, err = loadstring("return " .. file:read("*a"))
    file:close()
    if not result then
        eprint("[ERROR]["..modname.."]: Failed to load config file '"..filename.."': " .. err)
        return defaultValues, err
    end
    result = result()
    -- if file is empty, just use default
    if not result then
        result = defaultValues
    else
        -- now check if config variables are present and correct
        local rv
        for k, v in pairs(options) do
            rv = result[k]
            if rv == nil or type(rv) ~= type(v.default) then
                result[k] = v.default
            else
                if v.min and rv < v.min then
                    result[k] = v.min
                elseif v.max and rv > v.max then
                    result[k] = v.max
                end
            end
        end
    end
    return result
end

-- saveConfig(modname, config [, options [, isSeedDependant,]])
--[[ Saves mod config to file.
Сохраняет конфигурацию мода в файл.
* modname - String with modname (Строка с названием мода).
* config - Config table (Таблица с конфигурацией мода).
* options - Config options with default values and comments. (Опции конфига с дефолтными значениями и комментариями).
* isSeedDependant - true if config is specific for this server. false otherwise (true если конфиг предназначен для конкретно этого сервера. Иначе false).
Example: saveConfig("MyMod", { WindowWidth = 300 }, { default = 300, comment = "UI window width", min = 100, max = 600 }, true) ]]
function AzimuthBasic.saveConfig(modname, config, options, isSeedDependant)
    local filename = modname .. "Config" .. (isSeedDependant and '_' .. GameSettings().seed or "")
    if onServer() then
        filename = Server().folder .. "/" .. filename
    end
    local file, err = io.open(filename .. ".lua", "wb")
    if err then
        eprint("[ERROR]["..modname.."]: Failed to save config file '"..filename.."': " .. err)
        return false, err
    end
    file:write(AzimuthBasic.serialize(config, options))
    file:close()
    return true
end

return AzimuthBasic