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

function AzimuthClientData.setValue(key, value)
    data[key] = value
end

function AzimuthClientData.getValue(key)
    return data[key]
end

function AzimuthClientData.getValuem(...)
    local result = {}
    for _, key in pairs({...}) do
        result[#result+1] = data[key]
    end
    return unpack(result)
end

function AzimuthClientData.getValues()
    return data
end