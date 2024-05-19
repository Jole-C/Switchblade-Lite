local gameobject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetimedisplay"

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
                self.enemySpawnList = {}
                self.currentWaveIndex = self.currentWaveIndex + 1
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
            end
        end
    end,

    draw = function(self)
        -- Draw the warning sprites
        if self.inWaveTransition == true then
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
        end
    end,

    startWave = function(self)
        if self.currentWaveIndex > self.maxWave then
            return
        end

        -- Unpack the current wave
        local wave = self.waveDefinitions[self.currentWaveIndex]
        local spawnDefinitions = wave.spawnDefinitions

        if spawnDefinitions == nil then
            return
        end

        -- For each spawn definition
        for i = 1, #spawnDefinitions do
            local currentDefinition = spawnDefinitions[i]

            -- Grab the values from the current definition
            -- and set up a table for the generated shape, if applicable
            local waveType = currentDefinition.waveType
            local enemyDef = currentDefinition.enemyDef
            local generatedShape = {}

            -- Calculate the vertices
            if currentDefinition.shapeDef.numberOfPoints and currentDefinition.shapeDef.radius then
                local numberOfPoints = currentDefinition.shapeDef.numberOfPoints
                local radius = currentDefinition.shapeDef.radius
                local origin = currentDefinition.shapeDef.origin
                local angle = 2 * math.pi / numberOfPoints
                local offset = math.pi / 2
                local radius = radius

                for i = 1, numberOfPoints do
                    local pointX = origin.x + math.cos(i * angle - offset) * radius
                    local pointY = origin.y + math.sin(i * angle - offset) * radius

                    table.insert(generatedShape, {x = pointX, y = pointY})
                end
            else
                generatedShape = currentDefinition.shapeDef
            end

            if waveType == "randomWithinShape" then
                assert(#generatedShape > 1, "Number of points in shape must be greater than 1.")

                for i = 1, enemyDef.spawnCount do
                    local pointX = math.random(0, gameWidth)
                    local pointY = math.random(0, gameHeight)
    
                    -- Inefficient, must change later
                    while PointWithinShape(generatedShape, pointX, pointY) == false do
                        pointX = math.random(0, gameWidth)
                        pointY = math.random(0, gameHeight)
                    end

                    table.insert(self.enemySpawnList, {
                        enemyClass = self.enemyDefinitions[enemyDef.enemyID],
                        spawnPosition = vector.new(pointX, pointY),
                        spriteName = self.enemyDefinitions[enemyDef.enemyID].spriteName,
                        angle = math.random(0, 2*math.pi)
                    })
                end
            elseif waveType == "alongShapePerimeter" then
                local enemiesPerLine = math.ceil(enemyDef.spawnCount/#generatedShape)

                if #generatedShape == 2 then
                    enemiesPerLine = enemyDef.spawnCount
                end
                
                assert(#generatedShape > 1, "Number of points in shape must be greater than 1.")

                for i = 1, #generatedShape do
                    local point1 = vector.new(generatedShape[i].x, generatedShape[i].y)
                    local point2

                    if #generatedShape > 2 then
                        if i == #generatedShape then
                            point2 = vector.new(generatedShape[1].x, generatedShape[1].y)
                        else
                            point2 = vector.new(generatedShape[i + 1].x, generatedShape[i + 1].y)
                        end
                    else
                        if i == #generatedShape then
                            return
                        end

                        point2 = vector.new(generatedShape[2].x, generatedShape[2].y)
                    end

                    local pointSpacing = (point2 - point1):len()/enemiesPerLine
                    
                    for i = 1, enemiesPerLine do
                        local vectorBetweenPoints = (point2 - point1):normalized()
                        local enemyPosition = point1 + (vectorBetweenPoints * (i * pointSpacing))

                        table.insert(self.enemySpawnList, {
                            enemyClass = self.enemyDefinitions[enemyDef.enemyID],
                            spawnPosition = enemyPosition,
                            spriteName = self.enemyDefinitions[enemyDef.enemyID].spriteName,
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
        end
    end,
}

return stageDirector