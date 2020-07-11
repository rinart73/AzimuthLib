--- Improved vanilla UICollection
-- @usage local UICollection = include("azimuthlib-uicollection")
-- @usage -- You can access UICollection metatable to alter the class
-- UICollection.meta.show = function()
--     for _, element in pairs(self) do
--         if someCondition(element) then
--             element.visible = true
--         end
--     end
-- end
-- @module UICollection
local UICollection = {}
UICollection.__index = UICollection

--- Creates new instance of the UICollection class. You can already add elements to collection here
-- @within Constructors
-- @function UICollection
-- @tparam[opt] UIElement.. ... — Starting elements
-- @usage local collection = UICollection(labelOne, button1, labelTwo)
-- -- They will be accessible as 'UIElement class name' + 'number'
-- collection.Label1.caption = "Label one"
-- collection.Label2.caption = "Label two"
-- collection.Button1.onPressedFunction = "onButton1PressedFunction"
local function new(...)
    local collection = setmetatable({}, UICollection)
    local elements = {...}
    if #elements > 0 then
        collection:insert(...)
    end
    return collection
end

--- Adds elements to collection
-- @within UICollection: Methods
-- @tparam UIElement.. ... — Various elements
-- @usage -- You can add multiple elements at once
-- collection:insert(textField1, textField2)
-- -- And access them
-- collection.TextField1.text = "meh!"
-- collection.TextField2.text = "meh?"
-- @usage -- Or you can assign elements directly to collection
-- collection.cancelButton = window:createButton(rect, "Cancel"%_t, "onCancelButtonPressed")
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

--- Shows collection elements
-- @within UICollection: Methods
function UICollection:show()
    for _, element in pairs(self) do
        element.visible = true
    end
end

--- Hides collection elements
-- @within UICollection: Methods
function UICollection:hide()
    for _, element in pairs(self) do
        element.visible = false
    end
end

return setmetatable({new = new, meta = UICollection}, {__call = function(_, ...) return new(...) end})