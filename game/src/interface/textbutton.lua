local menuButton = require "src.interface.menubutton"
local textButton = class({name = "Text Button", extends = menuButton})

function textButton:new(text, font, restX, restY, selectedX, selectedY, execute, centerText)
    self:super(restX, restY, selectedX, selectedY, execute)

    centerText = centerText or false

    self.font = game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("fonts"):get(font)
    self.text = text
    self.centerText = centerText
end

function textButton:draw()
    love.graphics.setColor(self.drawColour)
    love.graphics.setFont(self.font)

    if self.centerText then
        love.graphics.printf(self.text, self.position.x, self.position.y, game.arenaValues.screenWidth, "center")
    else
        love.graphics.print(self.text, self.position.x, self.position.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return textButton