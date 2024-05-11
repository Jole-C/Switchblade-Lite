local gameobject = require "game.objects.gameobject"

local stageDirector = class{
    __includes = gameobject,

    update = function(self)
        local player = playerManager.playerReference

        if playerManager:doesPlayerExist() == false then
            gamestate.switch(gameover)
        end
    end
}

return stageDirector