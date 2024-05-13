local gameobject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetime"

local stageDirector = class{
    __includes = gameobject,

    maxMinutes = 3,
    maxSeconds = 0,
    timeBetweenWaves = 3,
    maxSpawnTime = 3,
    spriteScaleFrequencyChange = 5,
    spriteScaleAmplitude = 1,
    maxWarningAngleRandomiseCooldown = 0.25,

    aliveEnemies = {},
    levelDefinition = {},
    waveDefinitions = {},
    enemyDefinitions = {},
    enemySpawnList = {},
    currentWaveIndex = 0,
    spawnTime,
    maxWave = 0,
    timeMinutes = 3,
    timeSeconds = 0,
    inWaveTransition = false,
    spriteScaleFrequency = 0,
    spriteScale = 1,
    angleWarningRandomiseCooldown = 0,


    hud,

    init = function(self, levelDefinition, x, y)
        gameobject.init(self, x, y)
        
        -- Unpack the level table
        self.levelDefinition = levelDefinition
        self.waveDefinitions = self.levelDefinition.level
        self.maxWave = #self.levelDefinition.level
        self.enemyDefinitions = self.levelDefinition.enemyDefinitions

        self.spawnTime = self.maxSpawnTime
        self.angleWarningRandomiseCooldown = self.maxWarningAngleRandomiseCooldown

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

        -- Handle sprite scaling
        self.spriteScale = (math.sin(self.spriteScaleFrequency) * self.spriteScaleAmplitude) * 0.5 + 1
        self.spriteScaleFrequency = self.spriteScaleFrequency + self.spriteScaleFrequencyChange * dt

        -- Handle enemy spawns and wave changing
        if self.currentWaveIndex <= self.maxWave then
            local aliveEnemyCount = 0

            for i = 1, #self.aliveEnemies do
                local enemy = self.aliveEnemies[i]

                if enemy ~= nil and enemy.markedForDelete == false then
                    aliveEnemyCount = aliveEnemyCount + 1
                end
            end

            -- If no enemies are alive, switch to the next wave
            if aliveEnemyCount <= 0 and self.inWaveTransition == false then
                self.aliveEnemies = {}
                self.currentWaveIndex = self.currentWaveIndex + 1
                self.enemySpawnList = {}
                self:startWave()
                self.spawnTime = self.maxSpawnTime
                self.inWaveTransition = true
            end
            
            -- Randomise the angle of the warning sprites
            self.angleWarningRandomiseCooldown = self.angleWarningRandomiseCooldown - 1 * dt

            if self.angleWarningRandomiseCooldown <= 0 then
                for i = 1, #self.enemySpawnList do
                    local nextSpawn = self.enemySpawnList[i]
                    nextSpawn.angle = math.random(0, 2 * math.pi)
                end

                self.angleWarningRandomiseCooldown = self.maxWarningAngleRandomiseCooldown
            end

            -- Spawn the enemies in a wave
            self.spawnTime = self.spawnTime - 1 * dt

            if self.spawnTime <= 0 and self.inWaveTransition == true then
                for i = 1, #self.enemySpawnList do
                    local nextSpawn = self.enemySpawnList[i]
                    local newEnemy = nextSpawn.enemyClass(nextSpawn.spawnPosition.x, nextSpawn.spawnPosition.y)
                    table.insert(self.aliveEnemies, newEnemy)
                    gamestate.current():addObject(newEnemy)
                end

                self.inWaveTransition = false
                self.enemySpawnList = {}
            end
        end
    end,

    draw = function(self)
        -- Draw the warning sprites
        for i = 1, #self.enemySpawnList do
            local nextSpawn = self.enemySpawnList[i]

            local sprite = resourceManager:getResource(nextSpawn.spriteName)
            local xOffset, yOffset = sprite:getDimensions()
            xOffset = xOffset/2
            yOffset = yOffset/2
    
            love.graphics.setColor(gameManager.currentPalette.enemySpawnColour)
            love.graphics.draw(sprite, nextSpawn.spawnPosition.x, nextSpawn.spawnPosition.y, nextSpawn.angle, self.spriteScale, self.spriteScale, xOffset, yOffset)
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.print("current wave:" ..self.currentWaveIndex.."\n enemies to spawn: "..#self.enemySpawnList, 50, 10)
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

                    table.insert(self.enemySpawnList, {
                        enemyClass = self.enemyDefinitions[currentDef.enemyID],
                        spawnPosition = position,
                        spriteName = self.enemyDefinitions[currentDef.enemyID].spriteName,
                        angle = math.random(0, 2*math.pi)
                    })
                end
            end
        elseif waveType == "predefined" then
            local enemyDefs = wave.enemyDefs

            for i = 1, #enemyDefs do
                local currentDef = enemyDefs[i]

                for j = 1, currentDef.spawnCount do
                    local position = vector.new()
                    position.x = currentDef.x
                    position.y = currentDef.y

                    table.insert(self.enemySpawnList, {
                        enemyClass = self.enemyDefinitions[currentDef.enemyID],
                        spawnPosition = position,
                        spriteName = self.enemyDefinitions[currentDef.enemyID].spriteName,
                        angle = math.random(0, 2*math.pi)
                    })
                end
            end
        end
    end,
}

return stageDirector