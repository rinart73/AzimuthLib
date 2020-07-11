--- Proportional UI splitters that allow to mix absolute pixel values with relative weights
-- @usage include("azimuthlib-uiproportionalsplitter")
-- @module UIProportionalSplitter

--- Creates new UIVerticalProportionalSplitter
-- @within Constructors
-- @function UIVerticalProportionalSplitter
-- @tparam Rect rect — The rect to split
-- @tparam int paddingInside — Padding between partitions
-- @tparam int/table margin — Splitter margin:
-- 
-- * int — One margin for all sides
-- * table — Margin for left, right, top and bottom sides
-- @tparam table proportions — Proportions, each values can be:
--
-- * a number >= 1 — will be treated as an absolute pixel value
-- * a number < 1 — will be treated as a relative weight
-- @treturn table — UIVerticalProportionalSplitter instance
-- @usage local splitter = UIVerticalProportionalSplitter(Rect(0, 0, 600, 30), 10, 0, {0.5, 0.3, 0.45})
-- print(splitter.partitions[1]) -- Rect(0, 0, 232, 30)
-- print(splitter.partitions[2]) -- Rect(242, 0, 381.2, 30)
-- print(splitter.partitions[3]) -- Rect(391.2, 0, 600, 0)
-- @usage local splitter = UIVerticalProportionalSplitter(Rect(0, 0, 700, 30), 10, 5, {0.4, 20, 40, 0.6}) -- values > 1 treated as pixels:
-- print(splitter[1]) -- Rect(5, 5, 245, 25)
-- print(splitter[2]) -- Rect(255, 5, 275, 25)
-- print(splitter[3]) -- Rect(285, 5, 325, 25)
-- print(splitter[4]) -- Rect(335, 5, 695, 25)
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

--- Sets partitions paddings (**not** paddingInside)
-- @within UIVerticalProportionalSplitter: Methods
-- @function UIVerticalProportionalSplitter:setPadding
-- @tparam int left
-- @tparam int right
-- @tparam int top
-- @tparam int bottom
-- @usage splitter:setPadding(10, 5, 10, 10)
-- @usage -- You can also use direct assignment
--splitter.padding = 5

--- Sets global splitter margins
-- @within UIVerticalProportionalSplitter: Methods
-- @function UIVerticalProportionalSplitter:setMargin
-- @tparam int left
-- @tparam int right
-- @tparam int top
-- @tparam int bottom
-- @usage splitter:setMargin(10, 5, 10, 10)
-- @usage -- You can also use direct assignment
--splitter.margin = 5

--- Set padding for all partitions
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam[writeonly] int padding
-- @see UIVerticalProportionalSplitter:setPadding

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int paddingLeft
-- @see UIVerticalProportionalSplitter:setPadding

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int paddingRight
-- @see UIVerticalProportionalSplitter:setPadding

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int paddingTop
-- @see UIVerticalProportionalSplitter:setPadding

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int paddingBottom
-- @see UIVerticalProportionalSplitter:setPadding

--- Set splitter margin for all sides
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam[writeonly] int margin
-- @see UIVerticalProportionalSplitter:setMargin

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int marginLeft
-- @see UIVerticalProportionalSplitter:setMargin

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int marginRight
-- @see UIVerticalProportionalSplitter:setMargin

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int marginTop
-- @see UIVerticalProportionalSplitter:setMargin

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int marginBottom
-- @see UIVerticalProportionalSplitter:setMargin

--- Padding between partitions
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam int paddingInside

--- Returns input rect after applying margin
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam[readonly] Rect inner

--- 
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam Rect rect

--- Table of proportions that can either be absolute pixels or relative weights
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam table[number] proportions

--- Calculated partitions
-- @within UIVerticalProportionalSplitter: Properties
-- @tparam[readonly] table[Rect] partitions


--- Creates new UIHorizontalProportionalSplitter
-- @within Constructors
-- @function UIHorizontalProportionalSplitter
-- @tparam Rect rect — The rect to split
-- @tparam int paddingInside — Padding between partitions
-- @tparam int/table margin — Splitter margin:
-- 
-- * int — One margin for all sides
-- * table — Margin for left, right, top and bottom sides
-- @tparam table proportions — Proportions, each values can be:
--
-- * a number >= 1 — will be treated as an absolute pixel value
-- * a number < 1 — will be treated as a relative weight
-- @treturn table — UIHorizontalProportionalSplitter instance
-- @usage local splitter = UIHorizontalProportionalSplitter(Rect(0, 0, 30, 600), 10, 0, {0.5, 0.3, 0.45})
-- print(splitter.partitions[1]) -- Rect(0, 0, 30, 232)
-- print(splitter.partitions[2]) -- Rect(0, 242, 30, 381.2)
-- print(splitter.partitions[3]) -- Rect(0, 391.2, 0, 600)
-- @usage local splitter = UIHorizontalProportionalSplitter(Rect(0, 0, 700, 30), 10, 5, {0.4, 20, 40, 0.6}) -- values > 1 treated as pixels:
-- print(splitter[1]) -- Rect(5, 5, 25, 245)
-- print(splitter[2]) -- Rect(5, 255, 25, 275)
-- print(splitter[3]) -- Rect(5, 285, 25, 325)
-- print(splitter[4]) -- Rect(5, 335, 25, 695)
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

--- Sets partitions paddings (**not** paddingInside)
-- @within UIHorizontalProportionalSplitter: Methods
-- @function UIHorizontalProportionalSplitter:setPadding
-- @tparam int left
-- @tparam int right
-- @tparam int top
-- @tparam int bottom
-- @usage splitter:setPadding(10, 5, 10, 10)
-- @usage -- You can also use direct assignment
--splitter.padding = 5

--- Sets global splitter margins
-- @within UIHorizontalProportionalSplitter: Methods
-- @function UIHorizontalProportionalSplitter:setMargin
-- @tparam int left
-- @tparam int right
-- @tparam int top
-- @tparam int bottom
-- @usage splitter:setMargin(10, 5, 10, 10)
-- @usage -- You can also use direct assignment
--splitter.margin = 5

--- Set padding for all partitions
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam[writeonly] int padding
-- @see UIHorizontalProportionalSplitter:setPadding

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int paddingLeft
-- @see UIHorizontalProportionalSplitter:setPadding

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int paddingRight
-- @see UIHorizontalProportionalSplitter:setPadding

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int paddingTop
-- @see UIHorizontalProportionalSplitter:setPadding

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int paddingBottom
-- @see UIHorizontalProportionalSplitter:setPadding

--- Set splitter margin for all sides
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam[writeonly] int margin
-- @see UIHorizontalProportionalSplitter:setMargin

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int marginLeft
-- @see UIHorizontalProportionalSplitter:setMargin

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int marginRight
-- @see UIHorizontalProportionalSplitter:setMargin

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int marginTop
-- @see UIHorizontalProportionalSplitter:setMargin

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int marginBottom
-- @see UIHorizontalProportionalSplitter:setMargin

--- Padding between partitions
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam int paddingInside

--- Returns input rect after applying margin
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam[readonly] Rect inner

--- 
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam Rect rect

--- Table of proportions that can either be absolute pixels or relative weights
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam table[number] proportions

--- Calculated partitions
-- @within UIHorizontalProportionalSplitter: Properties
-- @tparam[readonly] table[Rect] partitions