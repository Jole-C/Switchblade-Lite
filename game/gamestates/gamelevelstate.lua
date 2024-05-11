local wall = require "game.objects.wall"
local chargerEnemy = require "game.objects.enemy.chargerenemy"
local droneEnemy = require "game.objects.enemy.droneenemy"
local director = require "game.stagedirector"

local gameLevelState = gamestate.new()
gameLevelState.objects = {}
gameLevelState.world = nil

function gameLevelState:enter()
    if not self.world then
        self.world = bump.newWorld()
    end

    local upperWall = wall(0, -20, gameWidth, 20)
    local lowerWall = wall(0, gameHeight, gameWidth, 20)
    local leftWall = wall(-20, 0, 20, gameHeight)
    local rightWall = wall(gameWidth, 0, 20, gameHeight)

    self:addObject(upperWall)
    self:addObject(lowerWall)
    self:addObject(leftWall)
    self:addObject(rightWall)

    for i = 1, 10 do
        local testEnemy = chargerEnemy(100, 100)
        self:addObject(testEnemy)
    end

    local newDroneEnemy = droneEnemy(100, 100)
    self:addObject(newDroneEnemy)

    local newPlayer = playerManager:spawnPlayer()
    self:addObject(newPlayer)

    local stageDirector = director(0, 0)
    self:addObject(stageDirector)
end

function gameLevelState:update(dt)
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:update(dt)
        end
    end
end

function gameLevelState:draw()
end

function gameLevelState:addObject(object)
    table.insert(self.objects, object)
end

function gameLevelState:removeObject(index)
    table.remove(self.objects, index)
end

function gameLevelState:leave()
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:destroy()
            self:removeObject(index)
        end
    end
end

return gameLevelState