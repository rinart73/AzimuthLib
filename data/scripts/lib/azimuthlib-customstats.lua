-- Allows to turn certain script variables into stats that can be boosted.
-- result = (baseValue * (1 + sum(baseMultiplier)) + sum(multiplyableBias)) * (1 * multiplier1 * multiplier2 ...) + sum(absoluteBias)
--[[ Example - altering Factory `timeToProduce` variable:
local CustomStats = include("azimuthlib-customstats.lua")
CustomStats.addCustomStats(Factory)
Factory.setCustomStat("timeToProduce")
Factory.addBaseMultiplier("timeToProduce", "MyBuff", -0.1) -- will make factory produce things 10% faster.
print(Factory.timeToProduce) -- print boosted value
print(Factory.getBaseValue("timeToProduce")) -- print stat base value
Factory.timeToProduce = 25 -- change base value
Factory.removeBaseMultiplier("timeToProduce", "MyBuff") -- remove buff
]]

local CustomStats = {}

function CustomStats.addCustomStats(tbl)
    if tbl._customStats then return end -- already added
    tbl._customStats = {}

    -- transform variable into stat that can be boosted
    tbl.setCustomStat = function(key)
        if not tbl._customStats[key] then
            tbl._customStats[key] = {
              baseValue = tbl[key],
              baseMultiplier = {},
              multiplyableBias = {},
              multiplier = {},
              absoluteBias = {}
            }
            tbl[key] = nil
        end
    end
    -- restore vanilla behavior for a variable
    tbl.unsetCustomStat = function(key)
        if tbl._customStats[key] then
            tbl[key] = tbl._customStats[key].baseValue
            tbl._customStats[key] = nil
        end
    end

    -- Adds a multiplier for stat of type 'name'. This is to increase a stat, so a factor of 0.3 will become 1.3.
    tbl.addBaseMultiplier = function(key, name, value)
        if tbl._customStats[key] then
            tbl._customStats[key].baseMultiplier[name] = value
        end
    end
    -- Adds a bias for stat of type type. This bias will be added to stat before multipliers are considered.
    tbl.addMultiplyableBias = function(key, name, value)
        if tbl._customStats[key] then
            tbl._customStats[key].multiplyableBias[name] = value
        end
    end
    -- Adds a multiplier for stat of type type. The factor will be used unchanged.
    tbl.addMultiplier = function(key, name, value)
        if tbl._customStats[key] then
            tbl._customStats[key].multiplier[name] = value
        end
    end
    -- Adds a flat bias for stat of type type. This bias will be added to stat after multipliers are considered.
    tbl.addAbsoluteBias = function(key, name, value)
        if tbl._customStats[key] then
            tbl._customStats[key].absoluteBias[name] = value
        end
    end

    -- Removes specified bonus
    tbl.removeBaseMultiplier = function(key, name)
        if tbl._customStats[key] then
            tbl._customStats[key].baseMultiplier[name] = nil
        end
    end
    tbl.removeMultiplyableBias = function(key, name)
        if tbl._customStats[key] then
            tbl._customStats[key].multiplyableBias[name] = nil
        end
    end
    tbl.removeKeyedMultiplier = function(key, name)
        if tbl._customStats[key] then
            tbl._customStats[key].multiplier[name] = nil
        end
    end
    tbl.removeAbsoluteBias = function(key, name)
        if tbl._customStats[key] then
            tbl._customStats[key].absoluteBias[name] = nil
        end
    end

    -- Get stat base value
    tbl.getBaseValue = function(key)
        if tbl._customStats[key] then
            return tbl._customStats[key].baseValue
        else
            return tbl[key]
        end
    end
    -- Get stat boosted value. If `value` is nil, stst base value will be used instead.
    tbl.getBoostedValue = function(key, value)
        if not tbl._customStats[key] then return value end
        local baseValue = value or tbl._customStats[key].baseValue
        local baseMultiplier = 1
        for _, v in pairs(tbl._customStats[key].baseMultiplier) do
            baseMultiplier = baseMultiplier + v
        end
        local multiplyableBias = 0
        for _, v in pairs(tbl._customStats[key].multiplyableBias) do
            multiplyableBias = multiplyableBias + v
        end
        local multiplier = 1
        for _, v in pairs(tbl._customStats[key].multiplier) do
            multiplier = multiplier * v
        end
        local absoluteBias = 0
        for _, v in pairs(tbl._customStats[key].absoluteBias) do
            absoluteBias = absoluteBias + v
        end
        return (baseValue * math.max(0, baseMultiplier) + multiplyableBias) * math.max(0, multiplier) + absoluteBias
    end
    
    tbl.customStats_secure = tbl.secure
    tbl.secure = function()
        local data = {}
        if tbl.customStats_secure then
            data = tbl.customStats_secure()
        end
        data._customStats = tbl._customStats
        return data
    end
    
    tbl.customStats_restore = tbl.restore
    tbl.restore = function(data)
        if data then
            tbl._customStats = data._customStats or {}
            data._customStats = nil
        end
        if tbl.customStats_restore then
            tbl.customStats_restore(data)
        end
    end

    local mt = {}
    mt.__index = function(self, key)
        if self._customStats[key] then
            local baseMultiplier = 1
            for _, v in pairs(self._customStats[key].baseMultiplier) do
                baseMultiplier = baseMultiplier + v
            end
            local multiplyableBias = 0
            for _, v in pairs(self._customStats[key].multiplyableBias) do
                multiplyableBias = multiplyableBias + v
            end
            local multiplier = 1
            for _, v in pairs(self._customStats[key].multiplier) do
                multiplier = multiplier * v
            end
            local absoluteBias = 0
            for _, v in pairs(self._customStats[key].absoluteBias) do
                absoluteBias = absoluteBias + v
            end
            return (self._customStats[key].baseValue * math.max(0, baseMultiplier) + multiplyableBias) * math.max(0, multiplier) + absoluteBias
        else
            return rawget(self, index)
        end
    end
    mt.__newindex = function(self, key, value)
        if key ~= "_customStats" and self._customStats[key] then
            self._customStats[key].baseValue = value
        else
            rawset(self, key, value)
        end
    end
    setmetatable(tbl, mt)
end

return CustomStats