local interactableHudElement = require "src.interface.interactablehudelement"
local list = class({name = "List", extends = interactableHudElement})

function list:new(options, x, y, optionSelectX, dividerAmount, font)
    self:super()

    self.options = options
    self.dividerAmount = dividerAmount
    self.optionSelectX = optionSelectX
    self.optionLerpRate = 0.1

    for index, option in ipairs(self.options) do
        option.position = vec2(x, y + self.dividerAmount * index)
        option.selected = false
    end

    self.selectionIndex = 1

    self.position = vec2(x, y)
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get(font)
end

function list:onSelectionEnter(inputName, direction)
    if direction == -1 then
        self.selectionIndex = #self.options
    elseif direction == 1 then
        self.selectionIndex = 1
    end
end

function list:onSelectionExit(inputName, direction)
    self.selectionIndex = self.selectionIndex + (1 * direction)

    if self.selectionIndex > #self.options or self.selectionIndex < 1 then
        return false
    end

    return true
end

function list:execute()
    local selectedElement = self.options[self.selectionIndex]

    if selectedElement.execute then
        selectedElement:execute(self.owner, self)
    end
end

function list:update(dt)
    interactableHudElement.update(self, dt)

    for index, option in ipairs(self.options) do
        option.selected = self.selectionIndex == index

        if option.selected and self.isSelected then
            option.position.x = math.lerpDT(option.position.x, self.optionSelectX, self.optionLerpRate, dt)
        else
            option.position.x = math.lerpDT(self.position.x, self.optionSelectX, self.optionLerpRate, dt)
        end
    end
end

function list:draw()
    love.graphics.setFont(self.font)

    for index, option in ipairs(self.options) do
        local colour = game.manager.currentPalette.uiColour
        
        if option.selected and self.isSelected then
            colour = game.manager.currentPalette.playerColour
        end

        love.graphics.setColor(colour)
        love.graphics.print(tostring(index)..". "..option.text, option.position.x, option.position.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return list