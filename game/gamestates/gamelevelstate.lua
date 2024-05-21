local stageDirector = require "game.objects.stagedirector"
local enemyManager = require "game.objects.enemy.enemymanager"
local level = require "game.levels.level1"
local arena = require "game.objects.arena"

local gameLevelState = gamestate.new()

function gameLevelState:init()
    self.objects = {}
    self.expiredObjects = {}
    self.world = nil
    self.enemymanager = nil
    self.stageDirector = nil
    self.arena = nil
    self.name = "game level"
end

function gameLevelState:enter()
    camera:setWorld(worldX, worldY, worldWidth * 2, worldHeight * 2)
    interfaceRenderer:clearElements()

    self.world = bump.newWorld()

    self.arena = arena()
    self:addObject(self.arena)

    local newPlayer = playerManager:spawnPlayer(arenaPosition.x, arenaPosition.y)
    self:addObject(newPlayer)

    self.stageDirector = stageDirector(level, 0, 0)
    self:addObject(self.stageDirector)

    self.enemyManager = enemyManager()
    self:addObject(self.enemyManager)
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
    for i = 1, #self.objects do
        local object = self.objects[i]

        if object.markedForDelete == false then
            object:destroy()
        end
    end

    self.objects = {}
    self.expiredObjects = {}
    
    self.world = nil
    self.enemyManager = nil
    self.arena = nil
    self.stageDirector = nil

    interfaceRenderer:clearElements()
end

return gameLevelState