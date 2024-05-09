local gamelevel = require "game.gamestates.gamelevelstate"

local menustate = gamestate.new()

function menustate:init()
end

function menustate:update()
    gamestate.switch(gamelevel)
end

function menustate:draw()
end

return menustate