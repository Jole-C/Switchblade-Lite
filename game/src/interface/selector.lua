local interactableHudElement = require "src.interface.interactablehudelement"
local selector = class({name = "Selector", extends = interactableHudElement})

function selector:new(options, x, y, font, lastOptionIndex)
    self:super()

    lastOptionIndex = lastOptionIndex or 1

    self.options = options
    self.position = vec2(x, y)

    self.maxSelectionCooldown = 0.5
    self.selectionCooldown = 0
    self.selectionIndex = lastOptionIndex
    self.lastOption = self.options[lastOptionIndex]

    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get(font)
end

function selector:updateHudElement(dt)
    self.selectionCooldown = self.selectionCooldown - (1 * dt)
end

function selector:checkForInteractions()
    if game.input:pressed("menuLeft") and self.selectionCooldown <= 0 then
        self.selectionIndex = self.selectionIndex - 1
        self.selectionCooldown = self.maxSelectionCooldown
        self:swapElement()
    end

    if game.input:down("menuRight") and self.selectionCooldown <= 0 then
        self.selectionIndex = self.selectionIndex + 1
        self.selectionCooldown = self.maxSelectionCooldown
        self:swapElement()
    end

end

function selector:wrapSelectionIndex()
    if self.selectionIndex < 1 then
        self.selectionIndex = #self.options
    elseif self.selectionIndex > #self.options then
        self.selectionIndex = 1
    end
end

function selector:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.drawColour)

    if self.lastOption then
        local offsetX = self.font:getWidth(self.lastOption.name) / 2
        love.graphics.print(self.lastOption.name, self.position.x - offsetX, self.position.y)
    end
end

function selector:swapElement()
    self:wrapSelectionIndex()

    local option = self.options[self.selectionIndex]

    if self.lastOption ~= option then
        self.lastOption = option
        option:onEnter()
    end
end

return selector