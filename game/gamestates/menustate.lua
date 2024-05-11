local menustate = gamestate.new()

function menustate:init()
end

function menustate:update()
    if input:pressed("select") then
        gamestate.switch(gameLevel)
    end
end

function menustate:draw()
    love.graphics.print("main menu", 10, 10)
end

return menustate