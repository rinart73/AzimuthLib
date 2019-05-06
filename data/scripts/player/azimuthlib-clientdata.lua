--[[
Can be used to:
* Store mod server settings on client so client will request them only once.
* Store data between sectors.
Может быть использован для:
* Хранения серверных настроек мода на стороне клиента, чтобы не запрашивать их каждый раз.
* Хранения данных между секторами.
]]

if onServer() then return end

local data = {}

-- namespace AzimuthClientData
AzimuthClientData = {}

-- Example: Player():invokeFunction("azimuthlib-clientdata.lua", "setValue", "MyMod", { myModSettingsVar = 5 })
function AzimuthClientData.setValue(key, value)
    data[key] = value
end

-- Example: local _, value = Player():invokeFunction("azimuthlib-clientdata.lua", "getValue", "MyMod")
function AzimuthClientData.getValue(key)
    return data[key]
end

-- Allows to get multiple variable values at once (Позволяет получить значения нескольких переменных одновременно).
-- Example: local _, val1, val2, val3 = Player():invokeFunction("azimuthlib-clientdata.lua", "getValuem", "Var1", "Var2", "Var3")
function AzimuthClientData.getValuem(...)
    local result = {}
    for _, key in pairs({...}) do
        result[#result+1] = data[key]
    end
    return unpack(result)
end

-- Get all saved values as table (Получает все сохраненные значения как таблицу).
function AzimuthClientData.getValues()
    return data
end