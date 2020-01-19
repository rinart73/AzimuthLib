local UICollection = {}
UICollection.__index = UICollection

--[[ You can pass elements on collection creation - example: local collection = UICollection(label1, button1, label2)
They will be accessible as 'collection.Label1', 'collection.Button1', 'collection.Label2' ]]
local function new(...)
    local collection = setmetatable({}, UICollection)
    local elements = {...}
    if #elements > 0 then
        collection:insert(...)
    end
    return collection
end

-- collection:insert(label) -> collection.Label1
-- collection:insert(label1, label2) -> collection.Label1, collection.Label2
-- Also you can just directly assign stuff: collection.myComboBox = comboBox1
function UICollection:insert(...)
    for _, element in pairs({...}) do
        local vartype = element.__avoriontype
        if vartype then
            local i = 1
            while true do
                if self[vartype..i] == nil then
                    self[vartype..i] = element
                    break
                end
                i = i + 1
            end
        else
            self[#self+1] = element
        end
    end
end

function UICollection:show()
    for _, element in pairs(self) do
        element.visible = true
    end
end

function UICollection:hide()
    for _, element in pairs(self) do
        element.visible = false
    end
end

return setmetatable({new = new, meta = UICollection}, {__call = function(_, ...) return new(...) end})