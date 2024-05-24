local pauseMenu = require "game.menu.pause.pausemenu"
local rect = require "game.interface.rect"
local pauseManager = class({name = "Pause Manager"})

function pauseManager:new()
    self.background = rect(-100, -100, game.arenaValues.screenWidth + 100, game.arenaValues.screenHeight + 100, "fill", {0.1, 0.1, 0.1, 0.9})
    game.interfaceRenderer:addHudElement(self.background)

    self.menu = pauseMenu()
end

function pauseManager:update(dt)
    self.menu:update(dt)
end

function pauseManager:destroy()
    game.interfaceRenderer:removeHudElement(self.background)
    self.menu:destroy()
end

return pauseManager