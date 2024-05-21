local wall = require "game.objects.wall"
local director = require "game.objects.stagedirector"
local enemymanager = require "game.objects.enemymanager"
local level = require "game.levels.level1"

local gameLevelState = gamestate.new()

function gameLevelState:init()
    self.objects = {}
    self.expiredObjects = {}
    self.world = nil
    self.enemymanager = nil
    self.name = "game level"
end

function gameLevelState:enter()
    camera:setWorld(worldX, worldY, worldWidth * 2, worldHeight * 2)
    interfaceRenderer:clearElements()

    self.world = bump.newWorld()

    local upperWall = wall(0, -20, gameWidth, 20, vector.new(0, 1))
    local lowerWall = wall(0, gameHeight, gameWidth, 20, vector.new(0, -1))
    local leftWall = wall(-20, 0, 20, gameHeight, vector.new(1, 0))
    local rightWall = wall(gameWidth, 0, 20, gameHeight, vector.new(-1, 0))

    self:addObject(upperWall)
    self:addObject(lowerWall)
    self:addObject(leftWall)
    self:addObject(rightWall)

    local newPlayer = playerManager:spawnPlayer(gameWidth/2, gameHeight/2)
    self:addObject(newPlayer)

    local stageDirector = director(level, 0, 0)
    self:addObject(stageDirector)

    self.enemyManager = enemymanager()
end

function gameLevelState:update(dt)
    if input:pressed("pause") and gameManager.isPaused == false then
        gameManager:togglePausing()
    end

    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            table.insert(self.expiredObjects, object)
            object.gamestateIndex = index
        else
            object:update(dt)
        end
    end

    for i = 1, #self.expiredObjects do
        self:removeObject(self.expiredObjects[i].gamestateIndex)
    end

    self.expiredObjects = {}

    if self.enemyManager then
        self.enemyManager:update()
    end
end

function gameLevelState:draw()
    love.graphics.print(#self.objects, 0, windowHeight - windowHeight/3.5, 0, 10)
end

function gameLevelState:addObject(object)
    table.insert(self.objects, object)
end

function gameLevelState:removeObject(index)
    table.remove(self.objects, index)
end

function gameLevelState:leave()
    self.objects = {}
    self.expiredObjects = {}
    self.world = nil
    self.enemyManager:destroy()
    self.enemyManager = nil
    interfaceRenderer:clearElements()
end

return gameLevelState