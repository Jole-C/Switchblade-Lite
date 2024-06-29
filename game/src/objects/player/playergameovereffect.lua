local gameObject = require "src.objects.gameobject"
local playerGameover = class({name = "Player Gameover", extends = gameObject})

function playerGameover:new(x, y, angle)
    self:super(x, y)

    self.angle = angle
    self.playerSprite = game.resourceManager:getAsset("Player Assets"):get("sprites"):get("playerSprite")

    self.circleRadiusIncreaseRate = 700
    self.circleRadius = 0
    self.timeUntilGameover = 3

    self.playerExploded = false

    game.resourceManager:getAsset("Player Assets"):get("sounds"):get("deathTrigger"):play()

    gameHelper:getCurrentState().stageDirector:setTimerPaused(true)
end

function playerGameover:update(dt)
    self.circleRadius = self.circleRadius + (self.circleRadiusIncreaseRate * dt)

    if self.circleRadius > 900 then
        if self.playerExploded == false then
            self.playerExploded = true
            game.particleManager:burstEffect("Player Death", 20, self.position)
            gameHelper:screenShake(0.5)
            game.manager:setFreezeFrames(7)
            game.resourceManager:getAsset("Player Assets"):get("sounds"):get("deathExplosion"):play()
        else
            self.timeUntilGameover = self.timeUntilGameover - (1 * dt)
    
            if self.timeUntilGameover <= 0 then
                game.transitionManager:doTransition("gameOverState")
            end
        end
    end
end

function playerGameover:draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.circleRadius)

    love.graphics.setColor(1, 1, 1, 1)
    if self.playerExploded == false then
        local xOffset, yOffset = self.playerSprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.playerSprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return playerGameover