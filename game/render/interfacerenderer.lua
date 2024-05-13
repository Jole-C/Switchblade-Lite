local interfaceRenderer = class{
    hudElements = {},

    init = function(self)

    end,

    addHudElement = function(self, element)
        if not self.hudElements or #self.hudElements == 0 then
            return
        end

        table.insert(self.hudElements, element)
    end,

    removeHudElement = function(self, elementToRemove)
        if not self.hudElements or #self.hudElements == 0 then
            return
        end

        for i = 1, #self.hudElements do
            local element = self.hudElements[i]

            if element and element == elementToRemove then
                table.remove(self.hudElements, i)
                return
            end
        end
    end,

    clearElements = function(self)
        hudElements = {}
    end,

    draw = function(self)
        if not self.hudElements or #self.hudElements == 0 then
            return
        end

        for i = 1, #self.hudElements do
            local element = self.hudElements[i]

            if element then
                elemet:draw()
            end
        end
    end
}

return interfaceRenderer