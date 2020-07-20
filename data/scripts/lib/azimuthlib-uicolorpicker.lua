--- A color picker
-- @usage include("azimuthlib-uicolorpicker")
-- @module UIColorPicker

include("utility")
include("azimuthlib-uiproportionalsplitter")
include("azimuthlib-uirectangle")

local elements = {}
local ColorMode = { HS = 1, HSA = 2, HSV = 3, HSVA = 4, HV = 5, HVA = 6, HVS = 7, HVSA = 8 }

local properties = {moveable = true, index = true, mouseOver = true, visible = true, caption = true, position = true, size = true, lower = true, upper = true, center = true, tooltip = true, rect = true, width = true, height = true, localPosition = true, localCenter = true, localRect = true}

local function renderBorder(renderer, lower, upper, color, layer)
    renderer:renderLine(lower, vec2(upper.x, lower.y), color, layer)
    renderer:renderLine(vec2(lower.x, lower.y + 1), vec2(lower.x, upper.y - 1), color, layer)
    renderer:renderLine(vec2(upper.x - 1, lower.y + 1), vec2(upper.x - 1, upper.y - 1), color, layer)
    renderer:renderLine(vec2(lower.x, upper.y - 1), vec2(upper.x, upper.y - 1), color, layer)
end

local function updateColor(self)
    local isSecondSaturation = self.mode <= 4
    local hasValueSlider = self.mode == 3 or self.mode == 4 or self.mode == 7 or self.mode == 8
    local hasAlpha = self.mode % 2 == 0

    if hasValueSlider then
        self.valueGradient.color = isSecondSaturation and ColorHSV(self.hue, self.saturation, 1) or ColorHSV(self.hue, 1, self.value)
    end
    local color = ColorHSV(self.hue, self.saturation, self.value)
    if hasAlpha then
        self.alphaGradient.color = color
    end
    color.a = self.alpha
    self.colorDisplay.color = color
    -- update textbox
    if self.mode % 2 == 0 then -- alpha
        self.colorTextBox.text = string.upper(string.format('%02x%02x%02x%02x', round(color.a * 255), round(color.r * 255), round(color.g * 255), round(color.b * 255)))
    else
        self.colorTextBox.text = string.upper(string.format('%02x%02x%02x', round(color.r * 255), round(color.g * 255), round(color.b * 255)))
    end
end


--- Creates new UIColorPicker with its elements
-- @within Constructors
-- @function UIColorPicker
-- @tparam table namespace — Your mod namespace
-- @tparam ScriptUI/GalaxyMap/UIContainer parent — Parent element
--
-- **(!)** If you're planning to use color picker on Galaxy Map, pass GalaxyMap() as parent, **NOT** its child elements
-- @treturn table — UIColorPicker instance
-- @usage local uiColorPicker
-- function MyModNamespace.initUI()
--     uiColorPicker = UIColorPicker(MyModNamespace, ScriptUI())
-- end
function UIColorPicker(namespace, parent)
    local window = parent:createWindow(Rect(0, 0, 400, 300))
    window.showCloseButton = 0
    window.moveable = 1
    window.visible = false

    local colorsPaletteBackground = window:createPicture(Rect(), "data/textures/ui/azimuthlib/fill.png")
    local colorsPalette = window:createPicture(Rect(), "data/textures/ui/azimuthlib/palette.png")
    colorsPalette.flipped = true
    colorsPalette.layer = 1
    local colorsOuterBorder = UIRectangle(window, Rect(), ColorRGB(0.6, 0.6, 0.6))
    local colorsInnerBorder = UIRectangle(window, Rect(), ColorRGB(0, 0, 0))
    local colorsPosition = window:createContainer(Rect(0, 0, 11, 11))
    colorsPosition.layer = 2
    UIRectangle(colorsPosition, Rect(0, 0, 11, 11), ColorRGB(1, 1, 1))
    UIRectangle(colorsPosition, Rect(1, 1, 10, 10), ColorRGB(0, 0, 0))

    local valueGradientBackground = window:createPicture(Rect(), "data/textures/ui/azimuthlib/fill.png")
    local valueGradient = window:createPicture(Rect(), "data/textures/ui/azimuthlib/gradient.png")
    valueGradient.flipped = true
    valueGradient.layer = 1
    local valueOuterBorder = UIRectangle(window, Rect(), ColorRGB(0.6, 0.6, 0.6))
    local valueInnerBorder = UIRectangle(window, Rect(), ColorRGB(0, 0, 0))
    local valuePosition = window:createContainer(Rect(0, 0, 30, 7))
    valuePosition.layer = 2
    UIRectangle(valuePosition, Rect(0, 0, 30, 7), ColorRGB(1, 1, 1))
    UIRectangle(valuePosition, Rect(1, 1, 29, 6), ColorRGB(0, 0, 0))

    local alphaGradientBackground = window:createPicture(Rect(), "data/textures/ui/azimuthlib/transparent-h240.png")
    alphaGradientBackground.isIcon = true
    local alphaGradient = window:createPicture(Rect(), "data/textures/ui/azimuthlib/gradient.png")
    alphaGradient.flipped = true
    alphaGradient.layer = 1
    local alphaOuterBorder = UIRectangle(window, Rect(), ColorRGB(0.6, 0.6, 0.6))
    local alphaInnerBorder = UIRectangle(window, Rect(), ColorRGB(0, 0, 0))
    local alphaPosition = window:createContainer(Rect(0, 0, 30, 7))
    alphaPosition.layer = 2
    UIRectangle(alphaPosition, Rect(0, 0, 30, 7), ColorRGB(1, 1, 1))
    UIRectangle(alphaPosition, Rect(1, 1, 29, 6), ColorRGB(0, 0, 0))

    local colorDisplay = window:createPicture(Rect(), "data/textures/ui/azimuthlib/fill.png")
    local colorOuterBorder = UIRectangle(window, Rect(), ColorRGB(0.6, 0.6, 0.6))
    local colorInnerBorder = UIRectangle(window, Rect(), ColorRGB(0, 0, 0))
    local colorTextBox = window:createTextBox(Rect(), "azimuthLib_uiColorPicker_onTextBoxChanged")
    colorTextBox.allowedCharacters = "0123456789abcdefABCDEF"
    local applyButton = window:createButton(Rect(), "Apply"%_t, "azimuthLib_uiColorPicker_onApplyBtnPressed")
    applyButton.textSize = 14
    local cancelButton = window:createButton(Rect(), "Cancel"%_t, "azimuthLib_uiColorPicker_onCancelBtnPressed")
    cancelButton.textSize = 14

    local e = {
      namespace = namespace,
      isGalaxyMap = parent.__avoriontype == "GalaxyMap",
      mode = 1,
      noActionsTimer = 0,
      window = window,
      valueSliderMin = 0,
      valueSliderMax = 1,
      alphaSliderMin = 0,
      alphaSliderMax = 1,
      colorsPaletteBackground = colorsPaletteBackground,
      colorsPalette = colorsPalette,
      colorsOuterBorder = colorsOuterBorder,
      colorsInnerBorder = colorsInnerBorder,
      colorsPosition = colorsPosition,
      valueGradientBackground = valueGradientBackground,
      valueGradient = valueGradient,
      valueOuterBorder = valueOuterBorder,
      valueInnerBorder = valueInnerBorder,
      valuePosition = valuePosition,
      alphaGradientBackground = alphaGradientBackground,
      alphaGradient = alphaGradient,
      alphaOuterBorder = alphaOuterBorder,
      alphaInnerBorder = alphaInnerBorder,
      alphaPosition = alphaPosition,
      colorDisplay = colorDisplay,
      colorOuterBorder = colorOuterBorder,
      colorInnerBorder = colorInnerBorder,
      colorTextBox = colorTextBox,
      applyButton = applyButton,
      cancelButton = cancelButton,
      show = function(self, size, title, mode, defaultColor, onApplyCallback, onCancelCallback, valueSliderMin, valueSliderMax, alphaSliderMin, alphaSliderMax)
          if not size then size = vec2(400, 300) end
          if not mode then mode = "HSVA" end
          if not defaultColor then defaultColor = ColorRGB(1, 0, 0) end
          mode = ColorMode[mode] or ColorMode.HSVA
          self.mode = mode
          self.onApplyCallback = onApplyCallback
          self.onCancelCallback = onCancelCallback
          self.valueSliderMin = valueSliderMin or 0
          self.valueSliderMax = valueSliderMax or 1
          self.alphaSliderMin = alphaSliderMin or 0
          self.alphaSliderMax = alphaSliderMax or 1
          
          local isSecondSaturation = self.mode <= 4
          local hasValueSlider = self.mode == 3 or self.mode == 4 or self.mode == 7 or self.mode == 8
          local hasAlpha = self.mode % 2 == 0

          local res = getResolution()
          self.window.rect = Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5)
          self.window.caption = title or "Pick a color"%_t

          local hPartitions = UIHorizontalProportionalSplitter(self.window.rect, 15, 10, {0.5, 24})
          local vPartitions
          local valueIndex, alphaIndex
          if hasAlpha and hasValueSlider then -- pallete + value + alpha
              valueIndex = 2
              alphaIndex = 3
              vPartitions = UIVerticalProportionalSplitter(hPartitions[1], 15, 0, {0.5, 20, 20})
          elseif hasAlpha or hasValueSlider then -- pallete + value/alpha
              if hasValueSlider then
                  valueIndex = 2
              else
                  alphaIndex = 2
              end
              vPartitions = UIVerticalProportionalSplitter(hPartitions[1], 15, 0, {0.5, 20})
          else -- pallete only
              vPartitions = { hPartitions[1] }
          end
          local partition = vPartitions[1]
          self.colorsPalette.rect = Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2))
          self.colorsPaletteBackground.rect = self.colorsPalette.rect
          self.colorsPaletteBackground.color = isSecondSaturation and ColorRGB(1, 1, 1) or ColorRGB(0, 0, 0)
          self.colorsOuterBorder.rect = partition
          self.colorsInnerBorder.rect = Rect(partition.lower + vec2(1, 1), partition.upper - vec2(1, 1))
          self.colorsPosition.position = self.colorsPalette.lower - vec2(5, 5)

          if hasValueSlider then
              partition = vPartitions[valueIndex]
              self.valueGradient.rect = Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2))
              self.valueGradientBackground.rect = self.valueGradient.rect
              self.valueGradientBackground.color = isSecondSaturation and ColorRGB(0, 0, 0) or ColorRGB(1, 1, 1)
              self.valueOuterBorder.rect = partition
              self.valueInnerBorder.rect = Rect(partition.lower + vec2(1, 1), partition.upper - vec2(1, 1))
              self.valuePosition.position = partition.lower - vec2(5, 1)
          end
          self.valueGradientBackground.visible = hasValueSlider
          self.valueGradient.visible = hasValueSlider
          self.valueOuterBorder.visible = hasValueSlider
          self.valueInnerBorder.visible = hasValueSlider
          self.valuePosition.visible = hasValueSlider
          
          if hasAlpha then
              partition = vPartitions[alphaIndex]
              self.alphaGradient.rect = Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2))
              self.alphaGradientBackground.rect = self.alphaGradient.rect
              self.alphaOuterBorder.rect = partition
              self.alphaInnerBorder.rect = Rect(partition.lower + vec2(1, 1), partition.upper - vec2(1, 1))
              self.alphaPosition.position = partition.lower - vec2(5, 1)
          end
          self.alphaGradientBackground.visible = hasAlpha
          self.alphaGradient.visible = hasAlpha
          self.alphaOuterBorder.visible = hasAlpha
          self.alphaInnerBorder.visible = hasAlpha
          self.alphaPosition.visible = hasAlpha

          vPartitions = UIVerticalProportionalSplitter(hPartitions[2], 10, 0, {24, 100, 0.5, 0.5})
          partition = vPartitions[1]
          self.colorDisplay.rect = Rect(partition.lower + vec2(2, 2), partition.upper - vec2(2, 2))
          self.colorOuterBorder.rect = partition
          self.colorInnerBorder.rect = Rect(partition.lower + vec2(1, 1), partition.upper - vec2(1, 1))

          self.colorTextBox.rect = vPartitions[2]
          self.applyButton.rect = vPartitions[3]
          self.cancelButton.rect = vPartitions[4]

          if hasValueSlider then
              self:setValue(defaultColor.value)
              self:setSaturation(defaultColor.saturation)
          else
              if isSecondSaturation then
                  self.value = 1
                  self:setSaturation(defaultColor.saturation)
              else
                  self.saturation = 1
                  self:setValue(defaultColor.value)
              end
          end
          if hasAlpha then
              self:setAlpha(defaultColor.a)
          else
              self.alpha = 1
          end
          self:setHue(defaultColor.hue)

          -- reset stats
          self.isMouseDownPalette = false
          self.isMouseDownValue = false
          self.isMouseDownAlpha = false
          self.noActionsTimer = 0
          self.plannedTextBoxUpdate = false

          self.window.visible = true
      end,
      hide = function(self)
          self.window.visible = false
      end,
      update = function(self, timeStep)
          if not self.window.visible then return end
          if self.noActionsTimer > 0 then
              self.noActionsTimer = math.max(0, self.noActionsTimer - timeStep)
          end
          local hasValueSlider = self.mode == 3 or self.mode == 4 or self.mode == 7 or self.mode == 8
          local hasAlpha = self.mode % 2 == 0
          local mouse = Mouse()
          if mouse:mouseUp(MouseButton.Left) then
              self.isMouseDownPalette = false
              self.isMouseDownValue = false
              self.isMouseDownAlpha = false
          end
          local isMouseDown = mouse:mouseDown(MouseButton.Left)
          if self.plannedTextBoxUpdate and isMouseDown then
              if not self.colorTextBox.mouseOver then -- update color from textbox
                  local isSecondSaturation = self.mode <= 4
                  local text = self.colorTextBox.text
                  if not hasAlpha then
                      text = "FF"..text
                  end
                  local color = ColorInt(tonumber(text, 16) or 0)
                  if hasValueSlider then
                      self:setValue(color.value)
                      self:setSaturation(color.saturation)
                  else
                      if isSecondSaturation then
                          color.value = 1
                          self:setSaturation(color.saturation)
                      else
                          color.saturation = 1
                          self:setValue(color.value)
                      end
                  end
                  if hasAlpha then
                      self:setAlpha(color.a)
                  else
                      self.alpha = 1
                  end
                  self:setHue(color.hue)
                  self.plannedTextBoxUpdate = false
                  self.noActionsTimer = 0.4
              end
          elseif self.noActionsTimer == 0 then
              local isMousePressed = mouse:mousePressed(MouseButton.Left)
              if (isMousePressed and self.isMouseDownPalette)
                or (not self.isMouseDownValue and not self.isMouseDownAlpha and isMouseDown
                and mouse.position.x >= self.colorsPalette.lower.x and mouse.position.x <= self.colorsPalette.upper.x -- palette
                and mouse.position.y >= self.colorsPalette.lower.y and mouse.position.y <= self.colorsPalette.upper.y) then
                  local hue = math.max(0, math.min(360, (mouse.position.x - self.colorsPalette.lower.x) / self.colorsPalette.width * 360))
                  local saturation = 1 - math.max(0, math.min(1, (mouse.position.y - self.colorsPalette.lower.y) / self.colorsPalette.height))
                  self.colorsPosition.position = vec2(
                    self.colorsPalette.lower.x + hue / 360 * self.colorsPalette.width - 5,
                    self.colorsPalette.upper.y - saturation * self.colorsPalette.height - 5
                  )
                  self.hue = hue
                  if self.mode <= 4 then
                      self.saturation = saturation
                  else
                      self.value = saturation
                  end
                  updateColor(self)
                  self.isMouseDownPalette = true
              elseif (hasValueSlider and isMousePressed and self.isMouseDownValue)
                or (hasValueSlider and not self.isMouseDownPalette and not self.isMouseDownAlpha and isMouseDown -- value slider
                and mouse.position.x >= self.valueGradient.lower.x and mouse.position.x <= self.valueGradient.upper.x
                and mouse.position.y >= self.valueGradient.lower.y and mouse.position.y <= self.valueGradient.upper.y) then
                  local value = 1 - math.max(0, math.min(1, ((mouse.position.y - self.valueGradient.lower.y) / self.valueGradient.height)))
                  value = math.max(self.valueSliderMin, math.min(self.valueSliderMax, value))
                  self.valuePosition.position = vec2(self.valuePosition.position.x, self.valueGradient.upper.y - self.valueGradient.height * value - 3)
                  if self.mode <= 4 then
                      self.value = value
                  else
                      self.saturation = value
                  end
                  updateColor(self)
                  self.isMouseDownValue = true
              elseif (hasAlpha and isMousePressed and self.isMouseDownAlpha)
                or (hasAlpha and not self.isMouseDownPalette and not self.isMouseDownValue and isMouseDown -- alpha
                and mouse.position.x >= self.alphaGradient.lower.x and mouse.position.x <= self.alphaGradient.upper.x
                and mouse.position.y >= self.alphaGradient.lower.y and mouse.position.y <= self.alphaGradient.upper.y) then
                  local alpha = 1 - math.max(0, math.min(1, ((mouse.position.y - self.alphaGradient.lower.y) / self.alphaGradient.height)))
                  alpha = math.max(self.alphaSliderMin, math.min(self.alphaSliderMax, alpha))
                  self.alphaPosition.position = vec2(self.alphaPosition.position.x, self.alphaGradient.upper.y - self.alphaGradient.height * alpha - 3)
                  self.alpha = alpha
                  updateColor(self)
                  self.isMouseDownAlpha = true
              end
          end
      end,
      setHue = function(self, value) -- 0 to 360
          -- set position
          self.colorsPosition.position = vec2(self.colorsPalette.lower.x + value / 360 * self.colorsPalette.width - 5, self.colorsPosition.position.y)
          -- change color
          self.hue = value
          updateColor(self)
      end,
      setSaturation = function(self, value) -- 0 to 1
          -- set position
          if self.mode <= 4 then -- HSxx
              self.colorsPosition.position = vec2(self.colorsPosition.position.x, self.colorsPalette.upper.y - value * self.colorsPalette.height - 5)
          elseif self.mode == 7 or self.mode == 8 then -- it's HVSx
              value = math.max(self.valueSliderMin, math.min(self.valueSliderMax, value))
              self.valuePosition.position = vec2(self.valuePosition.position.x, self.valueGradient.upper.y - self.valueGradient.height * value - 3)
          else -- no value slider
              return
          end
          -- change color
          self.saturation = value
          updateColor(self)
      end,
      setValue = function(self, value) -- 0 to 1
          if self.mode >= 5 then -- HVxx
              self.colorsPosition.position = vec2(self.colorsPosition.position.x, self.colorsPalette.upper.y - value * self.colorsPalette.height - 5)
          elseif self.mode == 3 or self.mode == 4 then -- it's HSVx
              value = math.max(self.valueSliderMin, math.min(self.valueSliderMax, value))
              self.valuePosition.position = vec2(self.valuePosition.position.x, self.valueGradient.upper.y - self.valueGradient.height * value - 3)
          else -- no value slider
              return
          end
          -- change color
          self.value = value
          updateColor(self)
      end,
      setAlpha = function(self, value) -- 0 to 1
          if self.mode % 2 == 0 then
              value = math.max(self.alphaSliderMin, math.min(self.alphaSliderMax, value))
              self.alphaPosition.position = vec2(self.alphaPosition.position.x, self.alphaGradient.upper.y - self.alphaGradient.height * value - 3)
              self.alpha = value
              updateColor(self)
          end
      end
    }
    elements[#elements+1] = e

    -- namespace functions
    if e.isGalaxyMap then
        if not namespace.azimuthLib_uiColorPicker_onHideGalaxyMap then
            namespace.azimuthLib_uiColorPicker_onHideGalaxyMap = function()
                for _, e in ipairs(elements) do
                    if e.isGalaxyMap then
                        e:hide()
                    end
                end
            end
        end
    end
    if not namespace.azimuthLib_uiColorPicker_onTextBoxChanged then
        namespace.azimuthLib_uiColorPicker_onTextBoxChanged = function(textBox)
            for _, e in ipairs(elements) do
                if e.colorTextBox.index == textBox.index then
                    local length = string.len(e.colorTextBox.text)
                    local maxLen = 6
                    if e.mode % 2 == 0 then
                        maxLen = 8
                    end
                    if length > maxLen then
                        e.colorTextBox.text = string.sub(e.colorTextBox.text, 1, maxLen)
                    end
                    e.plannedTextBoxUpdate = true
                    return
                end
            end
            eprint("[ERROR][AzimuthLib]: Can't get color picker from text box")
        end
    end
    if not namespace.azimuthLib_uiColorPicker_onApplyBtnPressed then
        namespace.azimuthLib_uiColorPicker_onApplyBtnPressed = function(btn)
            for _, e in ipairs(elements) do
                if e.applyButton.index == btn.index then
                    if e.plannedTextBoxUpdate or e.noActionsTimer > 0 then return end
                    local shouldClose
                    if e.onApplyCallback then
                        local callback = e.namespace[e.onApplyCallback]
                        if callback then
                            local color = ColorHSV(e.hue, e.saturation, e.value)
                            color.a = e.alpha
                            shouldClose = callback(color, e)
                        end
                    end
                    if shouldClose ~= false then
                        e:hide()
                    end
                    return
                end
            end
            eprint("[ERROR][AzimuthLib]: Can't get color picker from 'Apply' button")
        end
    end
    if not namespace.azimuthLib_uiColorPicker_onCancelBtnPressed then
        namespace.azimuthLib_uiColorPicker_onCancelBtnPressed = function(btn)
            for _, e in ipairs(elements) do
                if e.cancelButton.index == btn.index then
                    local shouldClose
                    if e.onCancelCallback then
                        local callback = e.namespace[e.onCancelCallback]
                        if callback then
                            shouldClose = callback(e)
                        end
                    end
                    if shouldClose ~= false then
                        e:hide()
                    end
                    return
                end
            end
            eprint("[ERROR][AzimuthLib]: Can't get color picker from 'Cancel' button")
        end
    end
    if e.isGalaxyMap then
        Player():registerCallback("onHideGalaxyMap", "azimuthLib_uiColorPicker_onHideGalaxyMap")
    end

    return setmetatable(e, {
      __index = function(self, key)
          if properties[key] then
              return self.window[key]
          end
          return rawget(self, key)
      end,
      __newindex = function(self, key, value)
          if properties[key] then
              if key == "visible" then
                  if value then
                      self:show()
                  else
                      self:hide()
                  end
              else
                  self.window[key] = value
              end
          else
              rawset(self, key, value)
          end
      end
    })
end

--- Shows color picker window, adjusted to desired mode and size
-- @within UIColorPicker: Methods
-- @function show
-- @tparam[opt=vec2(400，300)] vec2 size — Window size
-- @tparam[opt="Pick a color"%_t] string title — Window caption
-- @tparam[opt="HSVA"] string mode — Color mode. Can be: HS, HSA, HSV, HSVA, HV, HVA, HVS, HVSA
-- @tparam[opt=ColorRGB(1，0，0)] Color defaultColor — Color that will be set in color picker
-- @tparam[opt] string onApplyCallback — Callback that will fire when user will press 'Apply' button
-- @tparam[opt] string onCancelCallback — Callback that will fire when user will press 'Cancel' button
-- @tparam[opt=0] float valueSliderMin — Minimal possible color value slider value
-- @tparam[opt=1] float valueSliderMax — Maximal possible color value slider value
-- @tparam[opt=0] float alphaSliderMin — Minimal possible alpha slider value
-- @tparam[opt=1] float alphaSliderMax — Maximal possible alpha slider value
-- @see UIColorPicker:onApplyCallback
-- @see UIColorPicker:onCancelCallback
-- @usage function MyModNamespace.onShowColorPickerBtnPressed()
--     uiColorPicker:show(vec2(400, 300), "Pick a color"%_t, "HSVA", ColorRGB(1, 0, 0), "onColorPickerApply", "onColorPickerCancel", 0.5, 1)
-- end

--- Hides color picker
-- @within UIColorPicker: Methods
-- @function hide

--- Updates color picker (checks for mouse position and clicks). This function should run every tick
-- @within UIColorPicker: Methods
-- @function update
-- @tparam float timeStep — Time step variable from `update` or `updateClient` function
-- @usage function MyModNamespace.getUpdateInterval()
--     if colorPicker and colorPicker.visible then return 0 end -- every tick
--     return 0.5
-- end
-- function MyModNamespace.updateClient(timeStep)
--     colorPicker:update(timeStep)
-- end

--- Sets color picker hue
-- @within UIColorPicker: Methods
-- @function setHue
-- @tparam float value — Hue value from 0 to 360

--- Sets saturation. If selected mode doesn't have saturation, this function will do nothing
-- @within UIColorPicker: Methods
-- @function setSaturation
-- @tparam float value — Saturation value from 0 to 1

--- Sets color value. If selected mode doesn't have value, this function will do nothing
-- @within UIColorPicker: Methods
-- @function setValue
-- @tparam float value — Color value from 0 to 1

--- Sets alpha value. If selected mode doesn't have alpha, this function will do nothing
-- @within UIColorPicker: Methods
-- @function setAlpha
-- @tparam float value — Alpha value from 0 to 1

--- Fires when user presses 'Apply' button if it was specified in the 'show' call
---
--- If function will return 'false', the color picker window won't close
-- @within UIColorPicker: Callbacks
-- @function onApplyCallback
-- @tparam Color color — Color that user selected
-- @tparam UIColorPicker element — This color picker
-- @usage function MyModNamespace.onColorPickerApply(color, element)
--     if someCheckPassed(color) then
--         -- do stuff
--     else -- check failed, don't hide the window
--         return false
--     end
-- end

--- Fires when user presses 'Cancel' button if it was specified in the 'show' call
---
--- If function will return 'false', the color picker window won't close
-- @within UIColorPicker: Callbacks
-- @function onCancelCallback
-- @tparam UIColorPicker element — This color picker

--- Your mod namespace
-- @within UIColorPicker: Properties
-- @tparam[readonly] table namespace

--- Indicates if this color picker belong to the GalaxyMap
-- @within UIColorPicker: Properties
-- @tparam[readonly] bool isGalaxyMap

--- Color mode
-- @within UIColorPicker: Properties
-- @tparam[readonly] int mode

--- Used to prevent sliders and buttons from working for a short period of time after user entered color hexcode and clicked away
-- @within UIColorPicker: Properties
-- @tparam[readonly] float noActionsTimer

--- Color picker window
-- @within UIColorPicker: Properties
-- @tparam[readonly] Window window

--- Color palette background (white or black)
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture colorsPaletteBackground

--- Color palette picture
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture colorsPalette

--- Outer border for color palette
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle colorsOuterBorder

--- Inner border for color palette
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle colorsInnerBorder

--- Container with two rects, used to display palette color position
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIContainer colorsPosition

--- Value/Saturation background (black or white)
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture valueGradientBackground

--- 'value' gradient picture (used to adjust value in HSxx mode or saturation in HVxx mode)
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture valueGradient

--- Outer border for value gradient
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle valueOuterBorder

--- Inner border for value gradient
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle valueInnerBorder

--- Container with two rects, used to display 'value' position
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIContainer valuePosition

--- Alpha gradient background
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture alphaGradientBackground

--- Alpha gradient picture
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture alphaGradient

--- Outer border for alpha gradient
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle alphaOuterBorder

--- Inner border for alpha gradient
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle alphaInnerBorder

--- Container with two rects, used to display alpha position
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIContainer alphaPosition

--- Displays resulting color
-- @within UIColorPicker: Properties
-- @tparam[readonly] Picture colorDisplay

--- Outer border for color display
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle colorOuterBorder

--- Inner border for color display
-- @within UIColorPicker: Properties
-- @tparam[readonly] UIRectangle colorInnerBorder

--- Displays resulting color as HEX sequence and allows to change it
-- @within UIColorPicker: Properties
-- @tparam[readonly] TextBox colorTextBox

--- 'Apply' button
-- @within UIColorPicker: Properties
-- @tparam[readonly] Button applyButton

--- 'Cancel' button
-- @within UIColorPicker: Properties
-- @tparam[readonly] Button cancelButton

--- 
-- @within UIColorPicker: Properties
-- @tparam string caption

--- 
-- @within UIColorPicker: Properties
-- @tparam bool consumeAllEvents

--- 
-- @within UIColorPicker: Properties
-- @tparam bool moveable

--- 
-- @within UIColorPicker: Properties
-- @tparam float transparency

--- 
-- @within UIColorPicker: Properties
-- @tparam vec2 center

--- 
-- @within UIColorPicker: Properties
-- @tparam float height

--- 
-- @within UIColorPicker: Properties
-- @tparam[readonly] vec2 localCenter

--- 
-- @within UIColorPicker: Properties
-- @tparam[readonly] vec2 localPosition

--- 
-- @within UIColorPicker: Properties
-- @tparam[readonly] Rect localRect

--- 
-- @within UIColorPicker: Properties
-- @tparam vec2 lower

--- 
-- @within UIColorPicker: Properties
-- @tparam[readonly] bool mouseOver

--- 
-- @within UIColorPicker: Properties
-- @tparam vec2 position

--- 
-- @within UIColorPicker: Properties
-- @tparam Rect rect

--- 
-- @within UIColorPicker: Properties
-- @tparam vec2 size

--- 
-- @within UIColorPicker: Properties
-- @tparam nil/string tooltip

--- 
-- @within UIColorPicker: Properties
-- @tparam vec2 upper

--- 
-- @within UIColorPicker: Properties
-- @tparam bool visible

--- 
-- @within UIColorPicker: Properties
-- @tparam float width