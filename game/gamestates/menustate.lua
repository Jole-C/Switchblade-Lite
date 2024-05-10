local menustate = gamestate.new()

function menustate:init()
end

function menustate:update()
    if love.keyboard.isDown("space") then
        gamestate.switch(gameLevel)
    end
end

function menustate:draw()
    love.graphics.print("main menu", 10, 10)
end

return menustate