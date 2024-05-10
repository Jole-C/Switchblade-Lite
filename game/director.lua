local gameobject = require "game.objects.gameobject"

local director = class{
    __includes = gameobject,

    update = function(self)
        local player = playerManager.playerReference

        if playerManager:doesPlayerExist() == false then
            gamestate.switch(menu)
        end
    end
}

return director