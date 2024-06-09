local gamestate = require "src.gamestates.gamestate"
local stageDirector = require "src.objects.stagedirector"
local enemyManager = require "src.objects.enemy.enemymanager"
local cameraManager = require "src.objects.cameramanager"
local level = require "src.levels.level1"
local arena = require "src.objects.arena"
local boss1 = require "src.objects.enemy.boss.boss1.boss1"

local gameLevelState = class({name = "Game Level State", extends = gamestate})

function gameLevelState:enter()
    game.camera:setWorld(game.arenaValues.worldX, game.arenaValues.worldY, game.arenaValues.worldWidth * 2, game.arenaValues.worldHeight * 2)
    game.interfaceRenderer:clearElements()

    self.objects = {}
    
    self.world = bump.newWorld()

    self.arena = arena()
    self:addObject(self.arena)

    self.cameraManager = cameraManager()
    self:addObject(self.cameraManager)
    self.cameraManager:addTarget({position = vec2(0, 0), weight = 3})

    self.stageDirector = stageDirector(level, 0, 0)
    self:addObject(self.stageDirector)

    local newPlayer = game.playerManager:spawnPlayer(self.stageDirector.playerStartSegment.position.x, self.stageDirector.playerStartSegment.position.y)
    self:addObject(newPlayer)

    self.enemyManager = enemyManager()
    self:addObject(self.enemyManager)

    self:addObject(boss1(0, 0))
end

function gameLevelState:update(dt)
    if game.input:pressed("pause") and game.manager.isPaused == false then
        game.manager:togglePausing()
    end

    for i = #self.objects, 1, -1 do
        local object = self.objects[i]

        if object then
            if object.markedForDelete == true then
                table.remove(self.objects, i)
            else
                object:update(dt)
            end
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
    self.cameraManager = nil

    game.interfaceRenderer:clearElements()
end

return gameLevelState