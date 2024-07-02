local gamestate = require "src.gamestates.gamestate"
local mainMenu = require "src.menu.mainmenu.mainmenu"

local menuState = class({name = "Menu State", extends = gamestate})

function menuState:enter()
    game.musicManager:pauseAllTracks()
    game.musicManager:getTrack("levelMusic"):play(1)

    game.camera:reset()
    game.manager:swapPaletteGroup("main")
    game.manager:swapPalette()
    
    self.menu = mainMenu()
end

function menuState:exit()
    self.menu:destroy()
    self.menu = nil
end

function menuState:update(dt)
    self.menu:update(dt)
end

function menuState:draw()
    self.menu:draw()
end

return menuState