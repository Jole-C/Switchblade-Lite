local gameObject = require "src.objects.gameobject"
local text = require "src.interface.text"

local menu = class({name = "Menu", extends = gameObject})

function menu:new()
    self:super(0, 0)

    self.menus = {}
    self.elements = {}
    self.toolTips = {}
    self.currentMenu = {}
    self.selectionIndex = 1
    self.inputDelay = 0.5
    self.menuDirection = "down"
    self.currentElement = nil
    
    self.menuUpSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("menuUp")
    self.menuDownSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("menuDown")

    self.toolTipText = text("", "fontMain", "right", 0, 250, 470)
    game.interfaceRenderer:addHudElement(self.toolTipText)
end

function menu:update(dt)
    self.inputDelay = self.inputDelay - 1 * dt

    if not self.elements or self.inputDelay > 0 then
        return
    end

    -- Update all buttons
    for i = 1, #self.elements do
        local element = self.elements[i]
        
        if element and element.update then
            element.isSelected = i == self.selectionIndex
            element:update(dt)
        end
    end

    -- Change the selected element
    local menuForward = "menuDown"
    local menuBackward = "menuUp"

    if self.menuDirection == "right" then
        menuForward = "menuRight"
        menuBackward = "menuLeft"
    end

    local direction = 1
    local inputPressed = ""

    if game.input:pressed(menuBackward) then
        self.menuUpSound:play()

        direction = -1
        inputPressed = menuBackward

        if self:wasInputConsumed(inputPressed, direction) then
            return
        end
        
        self.selectionIndex = self.selectionIndex - 1


        if self.currentMenu.onElementChange then
            self.currentMenu.onElementChange(self)
        end
    end

    if game.input:pressed(menuForward) then
        self.menuDownSound:play()

        direction = 1
        inputPressed = menuForward
        
        if self:wasInputConsumed(menuForward, direction) then
            return
        end

        self.selectionIndex = self.selectionIndex + 1

        if self.currentMenu.onElementChange then
            self.currentMenu.onElementChange(self)
        end
    end

    -- Wrap the selection to prevent overflow
    self:wrapSelectionIndex()

    -- If the element cannot be highlighted, skip it
    local selectedElement = self:getNextSelectableElement(direction)

    if selectedElement == nil then
        return
    end

    if self.currentElement ~= selectedElement then
        self.currentElement = selectedElement
        selectedElement:onSelectionEnter(inputPressed, direction)
    end

    -- Execute the selected button when pressed
    if game.input:pressed("select") and selectedElement.enabled then
        selectedElement:execute()
    end

    if self.toolTips then
        self.toolTipText.text = self.toolTips[self.selectionIndex] or ""
    end

    self.currentElement = selectedElement
end

function menu:draw()

end

function menu:wasInputConsumed(menuInput, menuDirection)
    if self.currentElement == nil or self.currentElement.execute == nil then
        return false
    end

    local inputConsumed = self.currentElement:onSelectionExit(menuInput, menuDirection)

    return inputConsumed
end

function menu:setElementsEnabled(enabled)
    for i = 1, #self.elements do
        local element = self.elements[i]
        
        if element then
            element.enabled = enabled
        end
    end
end

function menu:wrapSelectionIndex()
    if self.selectionIndex < 1 then
        self.selectionIndex = #self.elements
    elseif self.selectionIndex > #self.elements then
        self.selectionIndex = 1
    end
end

function menu:clearMenuSubElements()
    for i = 1, #self.elements do
        local element = self.elements[i]
        
        if element then
            game.interfaceRenderer:removeHudElement(element)

            -- Make sure to reset the hud element back to its default state
            if element.reset then
                element:reset()
            end
        end
    end

    self.elements = {}
end

function menu:updateInterfaceRenderer()
    for i = 1, #self.elements do
        local element = self.elements[i]
        
        if element then
            element.owner = self
            game.interfaceRenderer:addHudElement(element)
        end
    end
end

function menu:getMenuSubElements(menuName)
    if self.elements.onMenuLeave then
        self.elements.onMenuLeave(self)
    end

    self:clearMenuSubElements()
    self.elements = self.menus[menuName].elements
    
    self.menuDirection = self.menus[menuName].menuDirection or "down"

    if self.elements.onMenuEnter then
        self.elements.onMenuEnter(self)
    end
    
    self.toolTips = self.menus[menuName].toolTips
    self.currentMenu = self.menus[menuName]
    self:updateInterfaceRenderer()
end

function menu:switchMenu(menuName)
    self.selectionIndex = 1
    self:getMenuSubElements(menuName)
end

function menu:cleanup()
    self:clearMenuSubElements()
    game.interfaceRenderer:removeHudElement(self.toolTipText)
end
 
function menu:getNextSelectableElement(direction)
    local selectedElement = self.elements[self.selectionIndex]

    if selectedElement == nil then
        return
    end

    while selectedElement.execute == nil do
        self.selectionIndex = self.selectionIndex + (1 * direction)
        self:wrapSelectionIndex()

        selectedElement = self.elements[self.selectionIndex]
    end

    return selectedElement
end

return menu