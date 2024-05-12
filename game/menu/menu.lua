local menu = class{
    elements = {},
    selectionIndex = 1,

    init = function(self, elements)
        self.elements = elements
    end,

    update = function(self)
        if not self.elements then
            return
        end

        if input:pressed("menuUp") then
            self.selectionIndex = self.selectionIndex - 1
        end

        if input:pressed("menuDown") then
            self.selectionIndex = self.selectionIndex + 1
        end

        if self.selectionIndex < 1 then
            self.selectionIndex = #self.elements
        elseif self.selectionIndex > #self.elements then
            self.selectionIndex = 1
        end

        if input:pressed("select") then
            self.elements[self.selectionIndex]:execute()
        end
    end,

    draw = function(self)
        if not self.elements then
            return
        end
        
        love.graphics.setFont(resourceManager:getResource("font main"))
        
        for i = 1, #self.elements do
            local currentElement = self.elements[i]
            local position = currentElement.position

            if i == self.selectionIndex then
                love.graphics.print(currentElement.name, currentElement.position.x + 10, currentElement.position.y)
            else
                love.graphics.print(currentElement.name, currentElement.position.x, currentElement.position.y)
            end

        end

        love.graphics.setFont(resourceManager:getResource("font debug"))
    end
}

return menu