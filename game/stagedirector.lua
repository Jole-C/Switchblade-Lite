local gameobject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetime"

local stageDirector = class{
    __includes = gameobject,
    timeMinutes = 3,
    timeSeconds = 0,
    hud,

    init = function(self)
        self.hud = stageTimeHud()
        interfaceRenderer:addHudElement(self.hud)
    end,

    update = function(self, dt)
        -- Update the hud
        self.hud.timeSeconds = self.timeSeconds
        self.hud.timeMinutes = self.timeMinutes

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
    end
}

return stageDirector