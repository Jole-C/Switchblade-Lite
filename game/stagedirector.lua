local gameobject = require "game.objects.gameobject"

local stageDirector = class{
    __includes = gameobject,
    timeMinutes = 3,
    timeSeconds = 0,

    update = function(self, dt)
        dt = dt or 0

        -- Handle gameover state switching
        local player = playerManager.playerReference

        if playerManager and playerManager:doesPlayerExist() == false then
            gamestate.switch(gameoverState)
        end

        -- Handle level timer
        if self.timeSeconds <= 0 then
            self.timeSeconds = 59
            self.timeMinutes = self.timeMinutes - 1
        end

        self.timeSeconds = self.timeSeconds - 1 * dt

        if self.timeSeconds <= 0 and self.timeMinutes <= 0 then
            player:onHit(3)
        end
    end,

    draw = function(self)
        local font = resourceManager:getResource("font main")
        local timeString = string.format("%02.0f:%02.0f",self.timeMinutes,self.timeSeconds)
        local textWidth = font:getWidth(timeString)
        love.graphics.setFont(font)
        love.graphics.print(timeString, gameWidth/2 - textWidth/2, 0)
    end
}

return stageDirector