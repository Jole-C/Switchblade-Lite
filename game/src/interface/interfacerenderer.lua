local interfaceRenderer = class({name = "Interface Renderer"})

function interfaceRenderer:new()
    self.hudElements = {}
end

function interfaceRenderer:addHudElement(element)
    if not self.hudElements then
        return
    end

    table.insert(self.hudElements, element)
end

function interfaceRenderer:removeHudElement(elementToRemove)
    if not self.hudElements then
        return
    end

    for i = 1, #self.hudElements do
        local element = self.hudElements[i]

        if element and element == elementToRemove then
            table.remove(self.hudElements, i)
            return
        end
    end
end

function interfaceRenderer:hasHudElement(element)
    return table.contains(self.hudElements, element)
end

function interfaceRenderer:clearElements()
    self.hudElements = {}
end

function interfaceRenderer:draw()
    if not self.hudElements or #self.hudElements == 0 then
        return
    end

    for i = 1, #self.hudElements do
        local element = self.hudElements[i]

        if element and element.draw then
            element:draw()
        end
    end
end

return interfaceRenderer