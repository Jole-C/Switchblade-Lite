local gameobject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetime"

local stageDirector = class{
    __includes = gameobject,

    maxMinutes = 3,
    maxSeconds = 0,
    maxWave = 0,
    timeBetweenWaves = 3,

    aliveEnemies = {},
    enemyReferences = {},
    levelDefinition = {},
    waveDefinitions = {},
    enemyDefinitions = {},
    currentWaveIndex = 0,
    timeMinutes = 3,
    timeSeconds = 0,
    inWaveTransition = false,
    hud,

    init = function(self, levelDefinition, x, y)
        gameobject.init(self, x, y)
        
        -- Unpack the level table
        self.levelDefinition = levelDefinition
        self.waveDefinitions = self.levelDefinition.level
        self.maxWave = #self.levelDefinition.level
        self.enemyDefinitions = self.levelDefinition.enemyDefinitions

        -- Set up the hud
        self.hud = stageTimeHud()
        interfaceRenderer:addHudElement(self.hud)
    end,

    update = function(self, dt)
        -- Update the hud
        self.hud.timeSeconds = self.timeSeconds
        self.hud.timeMinutes = self.timeMinutes

        -- Handle gameover state switching
        local player = playerManager.playerReference

        if playerManager and playerManager:doesPlayerExist() == false then
            gamestate.switch(gameoverState)
        end

        -- Handle level timer
        if self.timeSeconds <= 0 then
            self.timeSeconds = 59
            self.timeMinutes = self.timeMinutes - 1
        end

        self.timeSeconds = self.timeSeconds - 1 * dt

        -- Kill the player when time runs out
        if self.timeSeconds <= 0 and self.timeMinutes <= 0 then
            player:onHit(3)
        end

        if self.currentWaveIndex <= self.maxWave then
            local aliveEnemyCount = 0

            for i = 1, #self.aliveEnemies do
                local enemy = self.aliveEnemies[i]

                if enemy ~= nil and enemy.markedForDelete == false then
                    aliveEnemyCount = aliveEnemyCount + 1
                end
            end

            -- If no enemies are alive, switch to the next wave
            if aliveEnemyCount <= 0 then
                self.aliveEnemies = {}
                self.currentWaveIndex = self.currentWaveIndex + 1
                self:startWave()
            end
        end
    end,

    startWave = function(self)
        if self.currentWaveIndex > self.maxWave then
            return
        end

        -- Unpack the current wave
        local wave = self.waveDefinitions[self.currentWaveIndex]
        local waveType = wave.waveType

        if waveType == "random" then
            local enemyDefs = wave.enemyDefs

            for i = 1, #enemyDefs do
                local currentDef = enemyDefs[i]
                for j = 1, currentDef.spawnCount do
                    local position = vector.new()
                    position.x = love.math.random(10, gameWidth - 10)
                    position.y = love.math.random(10, gameHeight - 10)

                    local newEnemy = self.enemyDefinitions[currentDef.enemyID](position.x, position.y)
                    table.insert(self.aliveEnemies, newEnemy)
                    gamestate.current():addObject(newEnemy)
                end
            end
        elseif waveType == "predefined" then
            local currentDef = enemyDefs[i]
            for i = 1, #enemyDefs do
                local currentDef = enemyDefs[i]
                for j = 1, currentDef.spawnCount do
                    local position = vector.new()
                    position.x = currentDef.x
                    position.y = currentDef.y

                    local newEnemy = self.enemyDefinitions[currentDef.enemyID](position.x, position.y)
                    table.insert(self.aliveEnemies, newEnemy)
                    gamestate.current():addObject(newEnemy)
                end
            end
        end
    end,
}

return stageDirector