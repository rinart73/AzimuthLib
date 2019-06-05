--[[
Can be used to:
* Store mod server settings on client so client will request them only once.
* Store data between sectors.
]]
if onServer() then return end

-- namespace AzimuthClientData
AzimuthClientData = {}

local data = {}

-- API --
-- setValue(key, value)
--[[ Set variable.
Example: Player():invokeFunction("azimuthlib-clientdata.lua", "setValue", "MyMod", { myModSettingsVar = 5 })
]]
function AzimuthClientData.setValue(key, value)
    data[key] = value
end

-- getValue(key)
--[[ Get single variable.
Example: local _, value = Player():invokeFunction("azimuthlib-clientdata.lua", "getValue", "MyMod")
]]
function AzimuthClientData.getValue(key)
    return data[key]
end

-- getValuem(key1, key2, ..)
--[[ Allows to get multiple variable values at once.
Example: local _, val1, val2, val3 = Player():invokeFunction("azimuthlib-clientdata.lua", "getValuem", "Var1", "Var2", "Var3")
]]
function AzimuthClientData.getValuem(...)
    local result = {}
    for _, key in pairs({...}) do
        result[#result+1] = data[key]
    end
    return unpack(result)
end

-- Get all saved values as table.
function AzimuthClientData.getValues()
    return data
end