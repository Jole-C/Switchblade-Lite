local gameobject = require "game.objects.gameobject"

local menu = class{
    __includes = gameobject,

    menus = {},
    elements = {},
    selectionIndex = 1,
    inputDelay = 0.5,

    init = function(self)
    end,

    update = function(self, dt)
        self.inputDelay = self.inputDelay - 1 * dt

        if not self.elements or self.inputDelay > 0 then
            return
        end

        -- Update all buttons
        for i = 1, #self.elements do
            local element = self.elements[i]
            
            if element and element.update then
                element.isSelected = i == self.selectionIndex
                element:update()
            end
        end

        -- Change the selected element
        local direction = 1
        if input:pressed("menuUp") then
            self.selectionIndex = self.selectionIndex - 1
            direction = -1
        end

        if input:pressed("menuDown") then
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
        if input:pressed("select") then
            selectedElement:execute()
        end
    end,

    wrapSelectionIndex = function(self)
        if self.selectionIndex < 1 then
            self.selectionIndex = #self.elements
        elseif self.selectionIndex > #self.elements then
            self.selectionIndex = 1
        end
    end,

    clearMenuSubElements = function(self)
        for i = 1, #self.elements do
            local element = self.elements[i]
            
            if element then
                interfaceRenderer:removeHudElement(element)

                -- Make sure to reset the hud element back to its default state
                if element.reset then
                    element:reset()
                end
            end
        end

        self.elements = {}
    end,

    updateInterfaceRenderer = function(self)
        for i = 1, #self.elements do
            local element = self.elements[i]
            
            if element then
                element.owner = self
                interfaceRenderer:addHudElement(element)
            end
        end
    end,

    getMenuSubElements = function(self, menuName)
        self:clearMenuSubElements()
        self.elements = self.menus[menuName].elements
        self:updateInterfaceRenderer()
    end,

    switchMenu = function(self, menuName)
        self.selectionIndex = 1
        self:getMenuSubElements(menuName)
    end,

    cleanup = function(self)
        self:clearMenuSubElements()
    end,

    checkForSelectableElement = function(self, direction)
        local selectedElement = self.elements[self.selectionIndex]

        if selectedElement.execute == nil then
            self.selectionIndex = self.selectionIndex + (1 * direction)
            return
        else
            return selectedElement
        end
    end
}

return menu