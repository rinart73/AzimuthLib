--- Currently TabbedWindows inside PlayerWindow, ShipWindow or Hud are bugged (they don't work); CustomTabbedWindow was created as a workaround.
-- @usage local CustomTabbedWindow = include("azimuthlib-customtabbedwindow")
-- @module CustomTabbedWindow

include("azimuthlib-uiproportionalsplitter")
include("azimuthlib-uirectangle")

local elements = {}

local tab_properties = { center = 1, height = 1, layer = 1, localCenter = 1, localPosition = 1, localRect = 1, lower = 1, mouseOver = 1, position = 1, rect = 1, size = 1, tooltip = 1, upper = 1, visible = 1, width = 1 }
local tab_methods = { clear = 1, createAllianceEmblem = 1, createArrowLine = 1, createButton = 1, createCheckBox = 1, createComboBox = 1, createContainer = 1, createCraftPortrait = 1, createFrame = 1, createInputWindow = 1, createInventorySelection = 1, createLabel = 1, createLine = 1, createListBox = 1, createListBoxEx = 1, createMapArrowLine = 1, createMapIcon = 1, createMultiLineTextBox = 1, createNumbersBar = 1, createPicture = 1, createPlanDisplayer = 1, createProgressBar = 1, createRect = 1, createRoundButton = 1, createSavedDesignsSelection = 1, createScrollFrame = 1, createSelection = 1, createSlider = 1, createStatisticsBar = 1, createTabbedWindow = 1, createTextBox = 1, createTextField = 1, createTree = 1, createValueComboBox = 1, createWindow = 1 }

local window_rectProperties = { center = 1, height = 1, lower = 1, rect = 1, size = 1, upper = 1, width = 1 }
local window_properties = { layer = 1, localCenter = 1, localPosition = 1, localRect = 1, mouseOver = 1, position = 1, tooltip = 1, visible = 1, hide = 1, show = 1 }


local CustomTab = {}

--- A tooltip that is displayed when player hovers tab button
-- @within CustomTab: Properties
-- @tparam string description

--- Tab button icon
-- @within CustomTab: Properties
-- @tparam string icon

--- Indicates if this tab is selected
-- @within CustomTab: Properties
-- @tparam[readonly] bool isActiveTab

--- Tab unique name
-- @within CustomTab: Properties
-- @tparam[readonly] string name

--- A callback that will fires when this tab is being selected
-- @within CustomTab: Properties
-- @tparam string onSelectedFunction

---
-- @within CustomTab: Properties
-- @tparam vec2 center

--- 
-- @within CustomTab: Properties
-- @tparam float height

--- 
-- @within CustomTab: Properties
-- @tparam int layer

--- 
-- @within CustomTab: Properties
-- @tparam[readonly] vec2 localCenter

--- 
-- @within CustomTab: Properties
-- @tparam[readonly] vec2 localPosition

--- 
-- @within CustomTab: Properties
-- @tparam[readonly] Rect localRect

--- 
-- @within CustomTab: Properties
-- @tparam vec2 lower

--- 
-- @within CustomTab: Properties
-- @tparam[readonly] bool mouseOver

--- 
-- @within CustomTab: Properties
-- @tparam vec2 position

--- 
-- @within CustomTab: Properties
-- @tparam Rect rect

--- 
-- @within CustomTab: Properties
-- @tparam vec2 size

--- 
-- @within CustomTab: Properties
-- @tparam nil/string tooltip

--- 
-- @within CustomTab: Properties
-- @tparam vec2 upper

--- 
-- @within CustomTab: Properties
-- @tparam bool visible

--- 
-- @within CustomTab: Properties
-- @tparam float width

---
function CustomTab.__index(self, key)
    if tab_properties[key] then
        return self._container[key]
    end
    if key == "description" then
        return self._btn.tooltip
    end
    if key == "icon" then
        return self._icon.picture
    end
    return CustomTab[key]
end

function CustomTab.__newindex(self, key, value)
    if tab_properties[key] then
        self._container[key] = value
    elseif key == "description" then
        self._btn.tooltip = value
    elseif key == "icon" then
        self._icon.picture = value
    else
        rawset(self, key, value)
    end
end

for method, _ in pairs(tab_methods) do
    CustomTab[method] = function(self, ...)
        return self._container[method](self._container, ...)
    end
end

--- Removes tab contents
-- @within CustomTab: Methods
-- @function clear

---
-- @within CustomTab: Methods
-- @function createAllianceEmblem
-- @tparam Rect rect
-- @tparam int allianceIndex
-- @treturn Picture

---
-- @within CustomTab: Methods
-- @function createArrowLine
-- @treturn ArrowLine

---
-- @within CustomTab: Methods
-- @function createButton
-- @tparam Rect rect
-- @tparam string caption
-- @tparam string onBtnPressedFunction
-- @treturn Button

---
-- @within CustomTab: Methods
-- @function createCheckBox
-- @tparam Rect rect
-- @tparam string caption
-- @tparam string onCheckedFunction
-- @treturn CheckBox

---
-- @within CustomTab: Methods
-- @function createComboBox
-- @tparam Rect rect
-- @tparam string onSelectedFunction
-- @treturn ComboBox

---
-- @within CustomTab: Methods
-- @function createContainer
-- @tparam Rect rect
-- @treturn UIContainer

---
-- @within CustomTab: Methods
-- @function createCraftPortrait
-- @tparam Rect rect
-- @tparam string function
-- @treturn CraftPortrait

---
-- @within CustomTab: Methods
-- @function createFrame
-- @tparam Rect rect
-- @treturn Frame

---
-- @within CustomTab: Methods
-- @function createInputWindow
-- @treturn InputWindow

---
-- @within CustomTab: Methods
-- @function createInventorySelection
-- @tparam Rect rect
-- @tparam int width
-- @treturn InventorySelection

---
-- @within CustomTab: Methods
-- @function createLabel
-- @tparam Rect/vec2 position
-- @tparam string caption
-- @tparam int fontSize
-- @treturn Label

---
-- @within CustomTab: Methods
-- @function createLine
-- @tparam vec2 from
-- @tparam vec2 to
-- @treturn Line

---
-- @within CustomTab: Methods
-- @function createListBox
-- @tparam Rect rect
-- @treturn ListBox

---
-- @within CustomTab: Methods
-- @function createListBoxEx
-- @tparam Rect rect
-- @treturn ListBoxEx

---
-- @within CustomTab: Methods
-- @function createMapArrowLine
-- @treturn MapArrowLine

---
-- @within CustomTab: Methods
-- @function createMapIcon
-- @tparam string texture
-- @tparam ivec2 coordinates
-- @tparam[opt] Color color
-- @treturn MapIcon

---
-- @within CustomTab: Methods
-- @function createMultiLineTextBox
-- @tparam Rect rect
-- @treturn MultiLineTextBox

---
-- @within CustomTab: Methods
-- @function createNumbersBar
-- @tparam Rect rect
-- @treturn NumbersBar

---
-- @within CustomTab: Methods
-- @function createPicture
-- @tparam Rect rect
-- @tparam string path
-- @treturn Picture

---
-- @within CustomTab: Methods
-- @function createPlanDisplayer
-- @tparam Rect rect
-- @treturn PlanDisplayer

---
-- @within CustomTab: Methods
-- @function createProgressBar
-- @tparam Rect rect
-- @tparam Color color
-- @treturn ProgressBar

---
-- @within CustomTab: Methods
-- @function createRect
-- @tparam Rect rect
-- @tparam Color color
-- @treturn UIRect

---
-- @within CustomTab: Methods
-- @function createRoundButton
-- @tparam Rect rect
-- @tparam string icon
-- @tparam string onBtnPressedFunction
-- @treturn RoundButton

---
-- @within CustomTab: Methods
-- @function createSavedDesignsSelection
-- @tparam Rect rect
-- @tparam int width
-- @treturn SavedDesignsSelection

---
-- @within CustomTab: Methods
-- @function createScrollFrame
-- @tparam Rect rect
-- @treturn ScrollFrame

---
-- @within CustomTab: Methods
-- @function createSelection
-- @tparam Rect rect
-- @tparam int width
-- @treturn Selection

---
-- @within CustomTab: Methods
-- @function createSlider
-- @tparam Rect rect
-- @tparam int min
-- @tparam int max
-- @tparam int steps
-- @tparam string caption
-- @tparam string onValueChangedFunction
-- @treturn Slider

---
-- @within CustomTab: Methods
-- @function createStatisticsBar
-- @tparam Rect rect
-- @tparam Color color
-- @treturn StatisticsBar

---
-- @within CustomTab: Methods
-- @function createTabbedWindow
-- @tparam Rect rect
-- @treturn TabbedWindow

---
-- @within CustomTab: Methods
-- @function createTextBox
-- @tparam Rect rect
-- @tparam string onTextChangedFunction
-- @treturn TextBox

---
-- @within CustomTab: Methods
-- @function createTextField
-- @tparam Rect rect
-- @tparam string text
-- @treturn TextField

---
-- @within CustomTab: Methods
-- @function createTree
-- @tparam Rect rect
-- @treturn Tree

---
-- @within CustomTab: Methods
-- @function createValueComboBox
-- @tparam Rect rect
-- @tparam string onSelectedFunction
-- @treturn ValueComboBox

---
-- @within CustomTab: Methods
-- @function createWindow
-- @tparam Rect rect
-- @treturn Window


local CustomTabbedWindow = {}

--- A callback that will fires when tab is being selected
-- @within CustomTabbedWindow: Properties
-- @tparam string onSelectedFunction

---
-- @within CustomTabbedWindow: Properties
-- @tparam vec2 center

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam float height

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam int layer

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam[readonly] vec2 localCenter

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam[readonly] vec2 localPosition

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam[readonly] Rect localRect

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam vec2 lower

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam[readonly] bool mouseOver

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam vec2 position

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam Rect rect

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam vec2 size

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam nil/string tooltip

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam vec2 upper

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam bool visible

--- 
-- @within CustomTabbedWindow: Properties
-- @tparam float width

---
local function onTabBtnPressed(btn)
    for _, element in ipairs(elements) do
        local tab = element._tabByBtn[btn.index]
        if tab and not tab.isActiveTab then
            element:selectTab(tab)
            return
        end
    end
end

function CustomTabbedWindow.__index(self, key)
    if window_rectProperties[key] then
        return self._contentRect[key]
    end
    if window_properties[key] then
        return self._container[key]
    end
    return CustomTabbedWindow[key]
end

function CustomTabbedWindow.__newindex(self, key, value)
    if window_properties[key] then
        self._container[key] = value
    else
        rawset(self, key, value)
    end
end

function CustomTabbedWindow:_rearrangeTabButtons()
    self._btnLister = UIHorizontalLister(self._btnRect, 9, 0)
    local firstActiveTab
    for _, tab in ipairs(self._tabs) do
        if tab._btnContainer.visible then
            if not firstActiveTab then
                firstActiveTab = tab
            end
            local rect = self._btnLister:placeCenter(vec2(45, 41))
            tab._btnContainer.rect = Rect(self._container.rect.topLeft + rect.topLeft, self._container.rect.topLeft + rect.bottomRight)
        end
    end
    return firstActiveTab
end

---
-- @within CustomTabbedWindow: Methods
function CustomTabbedWindow:activateAllTabs()
    for _, v in ipairs(self._tabs) do
        v._btnContainer.visible = true
    end
    self:_rearrangeTabButtons()
end

---
-- @within CustomTabbedWindow: Methods
-- @tparam CustomTab tab
function CustomTabbedWindow:activateTab(tab)
    tab._btnContainer.visible = true
    self:_rearrangeTabButtons()
end

--- Creates new tab and it's elements
-- @within CustomTabbedWindow: Methods
-- @tparam string name — Unique name
-- @tparam string icon — Tab icon
-- @tparam string description — Text that will be displayed upon hovering tab icon
-- @treturn CustomTab
function CustomTabbedWindow:createTab(name, icon, description)
    local o = setmetatable({
      _parent = self,
      name = name,
      isActiveTab = false
    }, CustomTab)

    local rect = self._btnLister:placeCenter(vec2(45, 41))
    o._btnContainer = self._container:createContainer(rect)
    o._border = UIRectangle(o._btnContainer, Rect(rect.size))
    o._border.bottomLine.color = ColorInt(0xff303030)
    o._border.bottomLine.visible = false
    o._border.layer = 1
    o._btn = o._btnContainer:createButton(Rect(vec2(1, 1), rect.size - vec2(1, 1)), "", "azimuthLib_simpleTabs_onTabBtnPressed")
    o._btn.tooltip = description
    o._icon = o._btnContainer:createPicture(Rect(7, 5, 37, 35), icon)
    o._icon.layer = 1
    o._icon.isIcon = true
    o._icon.color = ColorInt(0xffCCCCCC)
    o._container = self._container:createContainer(self._contentRect)
    o._container.visible = false

    o._pos = #self._tabs + 1
    self._tabs[o._pos] = o
    self._tabByBtn[o._btn.index] = o

    if o._pos == 1 then
        self:selectTab(o)
    end

    return o
end

---
-- @within CustomTabbedWindow: Methods
-- @tparam CustomTab tab
function CustomTabbedWindow:deactivateTab(tab)
    tab._btnContainer.visible = false
    local firstActiveTab = self:_rearrangeTabButtons()
    if tab.isActiveTab then -- select another tab
        tab.isActiveTab = false
        tab._container.visible = false
        tab._parent.activeTab = nil
        if firstActiveTab then
            self:selectTab(firstActiveTab)
        end
    end
end

--- Returns selected tab
-- @within CustomTabbedWindow: Methods
-- @treturn CustomTab
function CustomTabbedWindow:getActiveTab()
    return self.activeTab
end

--- Finds tab by name
-- @within CustomTabbedWindow: Methods
-- @tparam string name
-- @treturn CustomTab
function CustomTabbedWindow:getTab(name)
    for _, v in ipairs(self._tabs) do
        if v.name == name then
            return v
        end
    end
end

---
-- @within CustomTabbedWindow: Methods
-- @tparam CustomTab tab
-- @tparam int pos
function CustomTabbedWindow:moveTabToPosition(tab, pos)
    local newPos = math.min(#self._tabs, pos)
    if tab._pos ~= newPos then
        table.remove(self._tabs, tab._pos)
        table.insert(self._tabs, newPos - 1, tab)
        for k, v in ipairs(self._tabs) do
            v._pos = k
        end
        self:_rearrangeTabButtons()
    end
end

---
-- @within CustomTabbedWindow: Methods
-- @tparam CustomTab tab
function CustomTabbedWindow:moveTabToTheRight(tab)
    if tab._pos + 1 <= #self._tabs then
        local otherTab = self._tabs[tab._pos + 1]
        self._tabs[tab._pos + 1] = tab
        self._tabs[tab._pos] = otherTab
        otherTab._pos = tab._pos
        tab._pos = tab._pos + 1
        self:_rearrangeTabButtons()
    end
end

---
-- @within CustomTabbedWindow: Methods
-- @tparam CustomTab tab
function CustomTabbedWindow:selectTab(tab)
    for _, v in ipairs(self._tabs) do
        if v ~= tab then
            v._icon.color = ColorInt(0xffCCCCCC)
            v._border.bottomLine.visible = false
            v._container.visible = false
            v.isActiveTab = false
        end
    end
    tab._icon.color = ColorInt(0xffffffff)
    tab._border.bottomLine.visible = true
    tab._container.visible = true
    tab.isActiveTab = true
    self.activeTab = tab
    if self.onSelectedFunction and self.onSelectedFunction ~= "" then
        self._namespace[self.onSelectedFunction](tab)
    end
    if tab.onSelectedFunction and tab.onSelectedFunction ~= "" then
        self._namespace[tab.onSelectedFunction](tab)
    end
end

--- Deletes all tabs
-- @within CustomTabbedWindow: Methods
function CustomTabbedWindow:clear()
    self._tabs = {}
    self._tabByBtn = {}
    self.activeTab = nil
    self._container:clear()
end

--- Creates new CustomTabbedWindow with its elements
-- @within Constructors
-- @function CustomTabbedWindow
-- @tparam table namespace — Your mod namespace
-- @tparam ScriptUI/GalaxyMap/UIContainer parent — Parent element
-- @tparam Rect rect — Rect area
-- @treturn CustomTabbedWindow
-- @usage function MyModNamespace.initUI()
--     local tabbedWindow = CustomTabbedWindow(MyModNamespace, window, Rect(vec2(10, 10), size - 10))
-- end
local function new(namespace, parent, rect)
    local o = setmetatable({
      _namespace = namespace,
      _tabs = {},
      _tabByBtn = {},
      _container = parent:createContainer(rect)
    }, CustomTabbedWindow)

    local hsplit = UIHorizontalProportionalSplitter(Rect(rect.size), 9, 0, {41, 0.5})
    o._line = o._container:createLine(hsplit[1].bottomLeft - vec2(0, 1), hsplit[1].bottomRight - vec2(0, 1))
    o._btnRect = hsplit[1]
    o._btnLister = UIHorizontalLister(hsplit[1], 9, 0)
    o._contentRect = hsplit[2]

    if not namespace.azimuthLib_simpleTabs_onTabBtnPressed then
        namespace.azimuthLib_simpleTabs_onTabBtnPressed = onTabBtnPressed
    end

    elements[#elements+1] = o
    return o
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})