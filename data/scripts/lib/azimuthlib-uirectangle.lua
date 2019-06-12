-- UIRectangle(UIContainer parent, Rect rect [, Color color [, int thickness]])
--[[ Has UIContainer properties + additional:
* topLine - Line : UIElement if thickness wasn't defined, Picture : UIElement otherwise
* leftLine - Line : UIElement if thickness wasn't defined, Picture : UIElement otherwise
* rightLine - Line : UIElement if thickness wasn't defined, Picture : UIElement otherwise
* bottomLine - Line : UIElement if thickness wasn't defined, Picture : UIElement otherwise
* thickness (int) - Can be changed only if it was defined during rectangle creation
Example:
  local window = ScriptUI():createWindow(Rect(400, 400, 800, 800))
  local uiRect = UIRectangle(window, Rect(0, 0, 20, 20), ColorARGB(0.8, 1, 0, 0), 2)
  uiRect.thickness = 3 -- will work
Example:
  local uiRect2 = UIRectangle(window, Rect(0, 0, 20, 20), ColorARGB(0.8, 1, 0, 0))
  uiRect2.thickness = 3 -- will not work, because thickness wasn't defined on creation
]]
function UIRectangle(parent, rect, color, thickness)
    local c = parent:createContainer(rect)
    local e = { _container = c }
    if not thickness then
        e.thickness = 1
        e.topLine = c:createLine(vec2(0, 0), vec2(rect.width, 0))
        e.leftLine = c:createLine(vec2(0, 1), vec2(0, rect.width - 1))
        e.rightLine = c:createLine(vec2(rect.width - 1, 1), vec2(rect.width - 1, rect.height - 1))
        e.bottomLine = c:createLine(vec2(0, rect.height - 1), vec2(rect.width, rect.height - 1))
    else
        e._thickness = thickness
        e.topLine = c:createPicture(Rect(0, 0, rect.width, thickness), "data/textures/ui/azimuthlib/fill.png")
        e.leftLine = c:createPicture(Rect(0, thickness, thickness, rect.width - thickness), "data/textures/ui/azimuthlib/fill.png")
        e.rightLine = c:createPicture(Rect(rect.width - thickness, thickness, rect.width, rect.height - thickness), "data/textures/ui/azimuthlib/fill.png")
        e.bottomLine = c:createPicture(Rect(0, rect.height - thickness, rect.width, rect.height), "data/textures/ui/azimuthlib/fill.png")
    end
    if color then
        e.topLine.color = color
        e.leftLine.color = color
        e.rightLine.color = color
        e.bottomLine.color = color
    end
    local properties = { visible = true, position = true, size = true, lower = true, upper = true, center = true, tooltip = true, rect = true, width = true, height = true }
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
              if key ~= "visible" and key ~= "position" and key ~= "tooltip" then -- adjust size
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