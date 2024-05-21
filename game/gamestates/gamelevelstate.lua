local director = require "game.objects.stagedirector"
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
    self.arena = arena()

    self:addObject(upperWall)
    local newPlayer = playerManager:spawnPlayer(arenaPosition.x, arenaPosition.y)
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