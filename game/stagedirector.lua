local gameobject = require "game.objects.gameobject"

local stageDirector = class{
    __includes = gameobject,

    update = function(self)
        local player = playerManager.playerReference

        if playerManager:doesPlayerExist() == false then
            gamestate.switch(gameoverState)
        end
    end
}

return stageDirector