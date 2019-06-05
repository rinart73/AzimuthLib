if onServer() then
    local entity = Entity()
    if entity.isShip and entity.playerOwned then
        entity:addScriptOnce("entity/azimuthlibexample.lua")
    end
end