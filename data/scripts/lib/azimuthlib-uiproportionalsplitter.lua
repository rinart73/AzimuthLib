--[[
UIVerticalProportionalSplitter(Rect rect, int paddingInside, int margin, table proportions)
UIVerticalProportionalSplitter(Rect rect, int paddingInside, table margin, table proportions)
* rect - The rect to split
* paddingInside - Distance between elements
* margin - Each side of passed rect will be shrinked by 'margin'.
* proportions - Table with partitions proportions:
  * {0.7, 0.3} - 70% and 30%
  * {0.75, 0.5} - 60% and 40%
  * {30, 0.4, 0.6} - Values >= 1 will be treated as pixels => 30pixels and the rest is divided in 40% and 60%
Returns: Table
* int paddingLeft
* int paddingRight
* int paddingTop
* int paddingBottom
* int marginLeft
* int marginRight
* int marginTop
* int marginBottom
* int paddingInside
* int padding (write-only)
* int margin (write-only)
* Rect inner (read-only)
* Rect rect
* table proportions
* table[Rect] partitions
* function setPadding(int left, int right, int top, int bottom)
* function setMargin(int left, int right, int top, int bottom)

Examples:
local splitter = UIVerticalProportionalSplitter(Rect(0, 0, 600, 30), 10, 0, {0.5, 0.3, 0.45})
print(splitter.partitions[1]) -- Rect(0, 0, 232, 30)
print(splitter.partitions[2]) -- Rect(242, 0, 381.2, 30)
print(splitter.partitions[3]) -- Rect(391.2, 0, 600, 0)
local splitter = UIVerticalProportionalSplitter(Rect(0, 0, 700, 30), 10, 5, {0.4, 20, 40, 0.6}) - values > 1 treated as pixels:
print(splitter[1]) -- Rect(5, 5, 245, 25)
print(splitter[2]) -- Rect(255, 5, 275, 25)
print(splitter[3]) -- Rect(285, 5, 325, 25)
print(splitter[4]) -- Rect(335, 5, 695, 25)
]]
function UIVerticalProportionalSplitter(rect, paddingInside, margin, proportions)
    if type(margin) ~= "table" then
        margin = {margin, margin, margin, margin}
    end
    local e = {
        __ = {
          paddingLeft = 0,
          paddingRight = 0,
          paddingTop = 0,
          paddingBottom = 0,
          marginLeft = margin[1],
          marginRight = margin[2],
          marginTop = margin[3],
          marginBottom = margin[4],
          paddingInside = paddingInside,
          proportions = proportions,
          rect = rect,
        },
        __refresh = function(self)
            self.inner = Rect(self.__.rect.lower.x + self.__.marginLeft, self.__.rect.lower.y + self.__.marginTop, self.__.rect.upper.x - self.__.marginRight, self.__.rect.upper.y - self.__.marginBottom)
            local count = #self.__.proportions
            local width = self.inner.width - (count - 1) * self.__.paddingInside
            local totalWeight = 0
            local totalAbsolute = 0
            local weight
            for i = 1, count do
                weight = self.__.proportions[i]
                if weight < 1 then
                    totalWeight = totalWeight + weight
                else
                    totalAbsolute = totalAbsolute + weight
                end
            end
            width = width - totalAbsolute
            local part = width / totalWeight
            local result = {}
            local x = self.inner.lower.x
            local startY = self.inner.lower.y + self.__.paddingTop
            local endY = self.inner.upper.y - self.__.paddingBottom
            for i = 1, count do
                weight = self.__.proportions[i]
                if weight < 1 then
                    result[#result+1] = Rect(x + self.__.paddingLeft, startY, x + part * weight - self.__.paddingRight, endY)
                    x = x + part * weight
                else
                    result[#result+1] = Rect(x + self.__.paddingLeft, startY, x + weight - self.__.paddingRight, endY)
                    x = x + weight
                end
                x = x + self.__.paddingInside
            end
            self.partitions = result
        end,
        setPadding = function(self, left, right, top, bottom)
            self.__.paddingLeft = left
            self.__.paddingRight = right
            self.__.paddingTop = top
            self.__.paddingBottom = bottom
            self:__refresh()
        end,
        setMargin = function(self, left, right, top, bottom)
            self.__.marginLeft = left
            self.__.marginRight = right
            self.__.marginTop = top
            self.__.marginBottom = bottom
            self:__refresh()
        end
    }

    e:__refresh()

    return setmetatable(e, {
      __index = function(self, key)
          if type(key) == "number" then
              return self.partitions[key]
          end
          return self.__[key]
      end,
      __newindex = function(self, key, value)
          if key == "padding" then
              self.__.paddingLeft = value
              self.__.paddingRight = value
              self.__.paddingTop = value
              self.__.paddingBottom = value
          elseif key == "margin" then
              self.__.marginLeft = value
              self.__.marginRight = value
              self.__.marginTop = value
              self.__.marginBottom = value
          else
              self.__[key] = value
          end
          self:__refresh()
      end
    })
end

function UIHorizontalProportionalSplitter(rect, paddingInside, margin, proportions)
    if type(margin) ~= "table" then
        margin = {margin, margin, margin, margin}
    end
    local e = {
        __ = {
          paddingLeft = 0,
          paddingRight = 0,
          paddingTop = 0,
          paddingBottom = 0,
          marginLeft = margin[1],
          marginRight = margin[2],
          marginTop = margin[3],
          marginBottom = margin[4],
          paddingInside = paddingInside,
          proportions = proportions,
          rect = rect,
        },
        __refresh = function(self)
            self.inner = Rect(self.__.rect.lower.x + self.__.marginLeft, self.__.rect.lower.y + self.__.marginTop, self.__.rect.upper.x - self.__.marginRight, self.__.rect.upper.y - self.__.marginBottom)
            local count = #self.__.proportions
            local height = self.inner.height - (count - 1) * self.__.paddingInside
            local totalWeight = 0
            local totalAbsolute = 0
            local weight
            for i = 1, count do
                weight = self.__.proportions[i]
                if weight < 1 then
                    totalWeight = totalWeight + weight
                else
                    totalAbsolute = totalAbsolute + weight
                end
            end
            height = height - totalAbsolute
            local part = height / totalWeight
            local result = {}
            local y = self.inner.lower.y
            local startX = self.inner.lower.x + self.__.paddingLeft
            local endX = self.inner.upper.x - self.__.paddingRight
            for i = 1, count do
                weight = self.__.proportions[i]
                if weight < 1 then
                    result[#result+1] = Rect(startX, y + self.__.paddingTop, endX, y + part * weight - self.__.paddingBottom)
                    y = y + part * weight
                else
                    result[#result+1] = Rect(startX, y + self.__.paddingTop, endX, y + weight - self.__.paddingBottom)
                    y = y + weight
                end
                y = y + self.__.paddingInside
            end
            self.partitions = result
        end,
        setPadding = function(self, left, right, top, bottom)
            self.__.paddingLeft = left
            self.__.paddingRight = right
            self.__.paddingTop = top
            self.__.paddingBottom = bottom
            self:__refresh()
        end,
        setMargin = function(self, left, right, top, bottom)
            self.__.marginLeft = left
            self.__.marginRight = right
            self.__.marginTop = top
            self.__.marginBottom = bottom
            self:__refresh()
        end
    }

    e:__refresh()

    return setmetatable(e, {
      __index = function(self, key)
          if type(key) == "number" then
              return self.partitions[key]
          end
          return self.__[key]
      end,
      __newindex = function(self, key, value)
          if key == "padding" then
              self.__.paddingLeft = value
              self.__.paddingRight = value
              self.__.paddingTop = value
              self.__.paddingBottom = value
          elseif key == "margin" then
              self.__.marginLeft = value
              self.__.marginRight = value
              self.__.marginTop = value
              self.__.marginBottom = value
          else
              self.__[key] = value
          end
          self:__refresh()
      end
    })
end