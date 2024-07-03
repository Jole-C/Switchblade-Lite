local gamestate = require "src.gamestates.gamestate"
local stageDirector = require "src.objects.stagedirector.stagedirector"
local scoreManager = require "src.objects.score.scoremanager"
local enemyManager = require "src.objects.enemy.enemymanager"
local cameraManager = require "src.objects.camera.cameramanager"
local cameraTarget = require "src.objects.camera.cameratarget"
local level = require "src.levels.level1"
local arena = require "src.objects.arena"

local gameLevelState = class({name = "Game Level State", extends = gamestate})

function gameLevelState:enter()
    game.musicManager:pauseAllTracks(1)
    game.musicManager:getTrack("levelMusic"):play(1)
    game.gameManager:resetRunInfo()
    gameHelper:resetMultiplier(false)
    
    game.camera:setWorld(game.arenaValues.worldX, game.arenaValues.worldY, game.arenaValues.worldWidth * 2, game.arenaValues.worldHeight * 2)

    self.objects = {}
    
    self.world = bump.newWorld()

    self.arena = arena()
    self:addObject(self.arena)

    self.cameraManager = cameraManager()
    self:addObject(self.cameraManager)

    if game.manager:getOption("centerCamera") == false then
        self.cameraManager:addTarget(cameraTarget(vec2(0, 0), 3))
    end

    self.stageDirector = stageDirector(level, 0, 0)
    self:addObject(self.stageDirector)

    self.scoreManager = scoreManager(0, 0)
    self:addObject(self.scoreManager)

    local newPlayer = game.playerManager:spawnPlayer(self.stageDirector.playerStartSegment.position.x, self.stageDirector.playerStartSegment.position.y)
    self:addObject(newPlayer)

    self.enemyManager = enemyManager()
    self:addObject(self.enemyManager)
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

function gameLevelState:exit()
    for _, object in pairs(self.objects) do
        if object.markedForDelete == false then
            object:destroy("autoDestruction")
        end
    end

    self.objects = {}
    self.expiredObjects = {}
    
    self.world = nil
    self.enemyManager = nil
    self.arena = nil
    self.stageDirector = nil
    self.cameraManager = nil
    self.scoreManager = nil
end

return gameLevelState