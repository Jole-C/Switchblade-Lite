require "game.objects.player"

gamelevelstate = gamestate.new()
gamelevelstate.objects = {}

function gamelevelstate:init()
    local newPlayer = player(0, 0)
    table.insert(self.objects, newPlayer)
end

function gamelevelstate:update()
    for index,object in ipairs(self.objects) do
        object:update()
    end
end

function gamelevelstate:draw()
    love.graphics.print("current gamestate: game")
end
