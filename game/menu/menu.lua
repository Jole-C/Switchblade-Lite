local gameobject = require "game.objects.gameobject"

local menu = class{
    __includes = gameobject,

    elements = {},
    selectionIndex = 1,
    inputDelay = 0.5,

    init = function(self)
        for i = 1, #self.elements do
            interfaceRenderer:addHudElement(self.elements[i])
        end
    end,

    update = function(self, dt)
        self.inputDelay = self.inputDelay - 1 * dt

        if not self.elements or self.inputDelay > 0 then
            return
        end

        -- Update all buttons
        for i = 1, #self.elements do
            local element = self.elements[i]
            
            if element then
                element.isSelected = i == self.selectionIndex
                element:update()
            end
        end

        -- Change the selected element
        if input:pressed("menuUp") then
            self.selectionIndex = self.selectionIndex - 1
        end

        if input:pressed("menuDown") then
            self.selectionIndex = self.selectionIndex + 1
        end

        -- Wrap the selection to prevent overflow
        if self.selectionIndex < 1 then
            self.selectionIndex = #self.elements
        elseif self.selectionIndex > #self.elements then
            self.selectionIndex = 1
        end

        -- Execute the selected button when pressed
        if input:pressed("select") then
            self.elements[self.selectionIndex]:execute()
        end
    end,

    draw = function(self)
    end,

    cleanup = function(self)
        for i = 1, #self.elements do
            local element = self.elements[i]
            
            if element then
                interfaceRenderer:removeHudElement(element)
            end
        end
    end
}

return menu