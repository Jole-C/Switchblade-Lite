local gameObject = require "src.objects.gameobject"
local playerGameover = class({name = "Player Gameover", extends = gameObject})

function playerGameover:new(x, y, angle)
    self:super(x, y)

    self.angle = angle
    self.playerSprite = game.resourceManager:getAsset("Player Assets"):get("sprites"):get("playerSprite")

    self.circleRadiusIncreaseRate = 300
    self.circleRadius = 0
    self.timeUntilGameover = 3
end

function playerGameover:update(dt)
    self.circleRadius = self.circleRadius + (self.circleRadiusIncreaseRate * dt)

    if self.circleRadius > 300 then
        self.timeUntilGameover = self.timeUntilGameover - (1 * dt)

        if self.timeUntilGameover <= 0 then
            game.gameStateMachine:set_state("gameOverState")
        end
    end
end

function playerGameover:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.circleRadius)
    love.graphics.setColor(0, 0, 0, 1)
    
    local xOffset, yOffset = self.playerSprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.playerSprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
end

return playerGameover