-- UIColorPicker(table namespace, UIContainer parent)
--[[ Initiates UIColorPicker with it's elements.
* namespace (table) - Your mod namespace.
* parent (UIContainer/ScriptUI/GalaxyMap) - If you're planning to use color picker on Galaxy Map, use GalaxyMap() as it's parent, NOT it's child elements.

Properties:
* Has all of 'Window' properties, except for 'showCloseButton', 'clickThrough' and 'closeableWithEscape'
* namespace (table) - Your mod namespace
* isGalaxyMap (bool) - Does this color picker belong to the GalaxyMap
* mode (int) - Color mode
* noActionsTimer (float) - Used to prevent sliders and buttons from working for a short period of time after user entered color hexcode and clicked away
* window (Window) - Color picker window
* colorsPaletteBackground (Picture) - Color palette background (white or black)
* colorsPalette (Picture) - Color palette picture
* colorsOuterBorder (UIRectangle) - Outer border for color palette
* colorsInnerBorder (UIRectangle) - Inner border for color palette
* colorsPosition (UIContainer) - Container with two rects, used to display palette color position
* valueGradientBackground (Picture) - Value/Saturation background (black or white)
* valueGradient (Picture) - 'value' gradient picture (used to adjust value in HSxx mode or saturation in HVxx mode)
* valueOuterBorder (UIRectangle) - Outer border for value gradient
* valueInnerBorder (UIRectangle) - Inner border for value gradient
* valuePosition (UIContainer) - Container with two rects, used to display 'value' position
* alphaGradientBackground (Picture) - Alpha gradient background
* alphaGradient (Picture) - Alpha gradient picture
* alphaOuterBorder (UIRectangle) - Outer border for alpha gradient
* alphaInnerBorder (UIRectangle) - Inner border for alpha gradient
* alphaPosition (UIContainer) - Container with two rects, used to display alpha position
* colorDisplay (Picture) - Displays resulting color
* colorOuterBorder (UIRectangle) - Outer border for color display
* colorInnerBorder (UIRectangle) - Inner border for color display
* colorTextBox (TextBox) - Displays resulting color as HEX sequence and allows to change it
* applyButton (Button) - 'Apply' button
* cancelButton (Button) - 'Cancel' button

Methods: ]]
-- show([vec2 size [, string title [, string mode [, Color defaultColor [, string onApplyCallback [, string onCancelCallback]]]]]])
--[[ Shows color picker window, adjusted to desired mode.
* size (vec2) - Window size. Default: vec2(400, 300)
* title (string) - Window caption. Default: "Pick a color"%_t
* mode (string) - Can be: HS, HSA, HSV, HSVA, HV, HVA, HVS, HVSA. Default: HSVA
* defaultColor (color) - Color that will be set in color picker. Default: ColorRGB(1, 0, 0)
* onApplyCallback (string) - Callback that will fire when user will press 'Apply' button:
  Passed arguments:
  * Color color - Color that user selected.
  * UIColorPicker element - This color picker.
  If callback will return 'false', window will not close.
* onCancelCallback (string) - Callback that will fire when user will press 'Cancel' button:
  Passed arguments:
  * UIColorPicker element - This color picker.
  If callback will return 'false', window will not close.
]]
-- hide()
--[[ Hides color picker ]]
-- update(float timeStep)
--[[ Updates color picker (checks for mouse position and clicks). This function should run every tick.
* timeStep (float) - Time step variable from `update` or `updateClient` function
]]
-- setHue(float value)
--[[ Set color picker hue.
* value (float) - From 0 to 360.
]]
-- setSaturation(float value)
--[[ Set saturation. If selected mode doesn't have saturation, this function will do nothing.
* value (float) - From 0 to 1.
]]
-- setValue(float value)
--[[ Set value. If selected mode doesn't have value, this function will do nothing.
* value (float) - From 0 to 1.
]]
-- setAlpha(float value)
--[[ Set alpha. If selected mode doesn't have alpha, this function will do nothing.
* value (float) - From 0 to 1.
]]
--[[ Example:
local uiColorPicker

function MyModNamespace.initUI()
    uiColorPicker = UIColorPicker(MyModNamespace, ScriptUI())
end

function MyModNamespace.onShowColorPickerBtnPressed()
    uiColorPicker:show(vec2(400, 300), "Pick a color"%_t, "HSVA", ColorRGB(1, 0, 0), "onColorPickerApply", "onColorPickerCancel")
end
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
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