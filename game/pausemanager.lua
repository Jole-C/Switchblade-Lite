local pauseMenu = require "game.menu.pause.pausemenu"
local rect = require "game.menu.rect"

local pauseManager = class{
    menu = {},
    background,

    init = function(self)
        self.background = rect(-100, -100, gameWidth + 100, gameHeight + 100, "fill", {0.1, 0.1, 0.1, 0.9})
        interfaceRenderer:addHudElement(self.background)

        self.menu = pauseMenu()
    end,

    update = function(self, dt)
        self.menu:update(dt)
    end,

    destroy = function(self)
        interfaceRenderer:removeHudElement(self.background)
        self.menu:destroy()
    end
}

return pauseManager