local gamestate = require "src.gamestates.gamestate"
local victoryMenu = require "src.menu.victory.victorymenu"

local victoryGameState = class({name = "Victory State", extends = gamestate})

function victoryGameState:enter()
    game.camera:setWorld(0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
    game.camera:setPosition(game.arenaValues.screenWidth/2, game.arenaValues.screenHeight/2)
    game.camera:setScale(1)
    game.manager:swapPaletteGroup("main")
    self.menu = victoryMenu()
end

function victoryGameState:exit()
    self.menu:destroy()
end

function victoryGameState:update(dt)
    self.menu:update(dt)
end

function victoryGameState:draw()
    self.menu:draw()
end

function victoryGameState:addObject(object)
    table.insert(self.objects, object)
end

function victoryGameState:removeObject(index)
    table.remove(self.objects, index)
end

return victoryGameState