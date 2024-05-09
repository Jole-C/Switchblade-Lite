require "game.gamestates.gamelevelstate"

menustate = gamestate.new()

function menustate:init()
end

function menustate:update()
    gamestate.switch(gamelevelstate)
end

function menustate:draw()
    love.graphics.print("current gamestate: menu")
end
