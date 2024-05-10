local wall = require "game.objects.wall"
local chargerEnemy = require "game.objects.enemy.chargerenemy"
local director = require "game.director"

local gamelevelstate = gamestate.new()
gamelevelstate.objects = {}
gamelevelstate.world = {}

function gamelevelstate:enter()
    self.world = bump.newWorld()

    local upperWall = wall(0, -20, gameWidth, 20)
    local lowerWall = wall(0, gameHeight, gameWidth, 20)
    local leftWall = wall(-20, 0, 20, gameHeight)
    local rightWall = wall(gameWidth, 0, 20, gameHeight)

    self:addObject(upperWall)
    self:addObject(lowerWall)
    self:addObject(leftWall)
    self:addObject(rightWall)

    local testEnemy = chargerEnemy(100, 100)
    self:addObject(testEnemy)

    local newPlayer = playerManager:spawnPlayer()
    self:addObject(newPlayer)

    local director = director(0, 0)
    self:addObject(director)
end

function gamelevelstate:update(dt)
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:update(dt)
        end
    end
end

function gamelevelstate:draw()
end

function gamelevelstate:addObject(object)
    table.insert(self.objects, object)
end

function gamelevelstate:removeObject(index)
    table.remove(self.objects, index)
end

function gamelevelstate:cleanup()
    for index,object in ipairs(self.objects) do
        object:destroy()
        self:removeObject(index)
    end
end

return gamelevelstate