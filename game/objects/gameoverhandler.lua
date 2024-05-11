local gameobject = require "game.objects.gameobject"

local gameoverHandler = class{
    __includes = gameobject,

    init = function(self)

    end,

    update = function(self)
        if love.keyboard.isDown("space") then
            gamestate.switch(menu)
        end
    end,

    draw = function(self)
        love.graphics.print("press button to go back to menu")
    end
}

return gameoverHandler