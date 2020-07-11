--- Unlike vanilla *UIRect*, UIRectangle creates **outlined** border instead of a filled rectangle
-- @usage include("azimuthlib-uirectangle")
-- @module UIRectangle

local properties = { visible = true, position = true, size = true, lower = true, upper = true, center = true, tooltip = true, rect = true, width = true, height = true, layer = true, localCenter = true, localPosition = true, localRect = true }

--- Creates new UIRectangle
-- @within Constructors
-- @function UIRectangle
-- @tparam UIContainer parent — Parent element
-- @tparam Rect rect — Element rect
-- @tparam[opt] Color color — Element color
-- @tparam[opt=1] int thickness — Border width
-- @treturn table — UIRectangle instance
-- @usage local uiRect = UIRectangle(window, Rect(0, 0, 20, 20), ColorARGB(0.8, 1, 0, 0), 2)
--uiRect.thickness = 3 -- will work
-- @usage local uiRect2 = UIRectangle(window, Rect(0, 0, 20, 20), ColorARGB(0.8, 1, 0, 0))
--uiRect2.thickness = 3 -- will not work, because thickness wasn't defined on creation
function UIRectangle(parent, rect, color, thickness)
    local c = parent:createContainer(rect)
    local e = { _container = c }
    if not thickness then
        e.thickness = 1
        e.topLine = c:createLine(vec2(0, 0), vec2(rect.width, 0))
        e.leftLine = c:createLine(vec2(0, 1), vec2(0, rect.height - 1))
        e.rightLine = c:createLine(vec2(rect.width - 1, 1), vec2(rect.width - 1, rect.height - 1))
        e.bottomLine = c:createLine(vec2(0, rect.height - 1), vec2(rect.width, rect.height - 1))
    else
        e._thickness = thickness
        e.topLine = c:createPicture(Rect(0, 0, rect.width, thickness), "data/textures/ui/azimuthlib/fill.png")
        e.leftLine = c:createPicture(Rect(0, thickness, thickness, rect.height - thickness), "data/textures/ui/azimuthlib/fill.png")
        e.rightLine = c:createPicture(Rect(rect.width - thickness, thickness, rect.width, rect.height - thickness), "data/textures/ui/azimuthlib/fill.png")
        e.bottomLine = c:createPicture(Rect(0, rect.height - thickness, rect.width, rect.height), "data/textures/ui/azimuthlib/fill.png")
    end
    if color then
        e.topLine.color = color
        e.leftLine.color = color
        e.rightLine.color = color
        e.bottomLine.color = color
    end
    return setmetatable(e, {
      __index = function(self, key)
          if key == "thickness" then
              return rawget(self, "_thickness")
          elseif properties[key] then
              return self._container[key]
          end
          return rawget(self, key)
      end,
      __newindex = function(self, key, value)
          if key == "thickness" then
              if rawget(self, "_thickness") then
                  rawset(self, "_thickness", value)
                  local lower = self._container.lower
                  local upper = self._container.upper
                  self.topLine.height = value
                  self.leftLine.rect = Rect(lower.x, lower.y + value, lower.x + value, upper.y - value)
                  self.rightLine.rect = Rect(upper.x - value, lower.y + value, upper.x, upper.y - value)
                  self.bottomLine.rect = Rect(lower.x, upper.y - value, upper.x, upper.y)
              end
          elseif properties[key] then
              self._container[key] = value
              if key ~= "visible" and key ~= "position" and key ~= "tooltip" and key ~= "layer" then -- adjust size
                  local size = self._container.size
                  local lower = self._container.lower
                  local upper = self._container.upper
                  local thickness = rawget(self, "_thickness") or 1
                  self.topLine.width = size.x
                  self.leftLine.height = size.y - thickness * 2
                  self.bottomLine.width = size.x
                  self.rightLine.height = size.y - thickness * 2
                  self.bottomLine.position = vec2(lower.x, upper.y - thickness)
                  self.rightLine.position = vec2(upper.x - thickness, lower.y + thickness)
              end
          else
              rawset(self, key, value)
          end
      end
    })
end

--- It's 'Line' if element was created without defining thickness, 'Picture' otherwise
-- @within UIRectangle: Properties
-- @tparam[readonly] UIElement topLine

--- It's 'Line' if element was created without defining thickness, 'Picture' otherwise
-- @within UIRectangle: Properties
-- @tparam[readonly] UIElement leftLine

--- It's 'Line' if element was created without defining thickness, 'Picture' otherwise
-- @within UIRectangle: Properties
-- @tparam[readonly] UIElement rightLine

--- It's 'Line' if element was created without defining thickness, 'Picture' otherwise
-- @within UIRectangle: Properties
-- @tparam[readonly] UIElement bottomLine

--- Can't be changed if it wasn't defined on element creation
-- @within UIRectangle: Properties
-- @tparam int thickness

--- 
-- @within UIRectangle: Properties
-- @tparam vec2 center

--- 
-- @within UIRectangle: Properties
-- @tparam float height

--- 
-- @within UIRectangle: Properties
-- @tparam int layer

--- 
-- @within UIRectangle: Properties
-- @tparam[readonly] vec2 localCenter

--- 
-- @within UIRectangle: Properties
-- @tparam[readonly] vec2 localPosition

--- 
-- @within UIRectangle: Properties
-- @tparam[readonly] vec2 localRect

--- 
-- @within UIRectangle: Properties
-- @tparam vec2 lower

--- 
-- @within UIRectangle: Properties
-- @tparam[readonly] bool mouseOver

--- 
-- @within UIRectangle: Properties
-- @tparam vec2 position

--- 
-- @within UIRectangle: Properties
-- @tparam Rect rect

--- 
-- @within UIRectangle: Properties
-- @tparam vec2 size

--- 
-- @within UIRectangle: Properties
-- @tparam nil/string tooltip

--- 
-- @within UIRectangle: Properties
-- @tparam vec2 upper

--- 
-- @within UIRectangle: Properties
-- @tparam bool visible

--- 
-- @within UIRectangle: Properties
-- @tparam float width