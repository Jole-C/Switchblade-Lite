local gameObject = require "game.objects.gameobject"
local menu = class({name = "Menu", extends = gameObject})

function menu:new()
    self:super(0, 0)

    self.menus = {}
    self.elements = {}
    self.selectionIndex = 1
    self.inputDelay = 0.5
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
    local direction = 1
    if game.input:pressed("menuUp") then
        self.selectionIndex = self.selectionIndex - 1
        direction = -1
    end

    if game.input:pressed("menuDown") then
        self.selectionIndex = self.selectionIndex + 1
        direction = 1
    end

    -- Wrap the selection to prevent overflow
    self:wrapSelectionIndex()

    -- If the element cannot be highlighted, skip it
    local selectedElement = self:checkForSelectableElement(direction)

    if selectedElement == nil then
        return
    end

    -- Execute the selected button when pressed
    if game.input:pressed("select") then
        selectedElement:execute()
    end
end

function menu:draw()

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
    self:clearMenuSubElements()
    self.elements = self.menus[menuName].elements
    self:updateInterfaceRenderer()
end

function menu:switchMenu(menuName)
    self.selectionIndex = 1
    self:getMenuSubElements(menuName)
end

function menu:cleanup()
    self:clearMenuSubElements()
end

function menu:checkForSelectableElement(direction)
    local selectedElement = self.elements[self.selectionIndex]

    if selectedElement.execute == nil then
        self.selectionIndex = self.selectionIndex + (1 * direction)
        return
    else
        return selectedElement
    end
end

return menu