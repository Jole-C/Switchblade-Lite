local gameObject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetimedisplay"
local text = require "game.interface.text"
local stageDirector = class({name = "Stage Director", extends = gameObject})

function stageDirector:new(levelDefinition)
    self:super(0, 0)

    self.maxMinutes = 3
    self.maxSeconds = 0
    self.timeBetweenWaves = 3
    self.maxSpawnTime = 2
    self.spriteScaleFrequencyChange = 8
    self.spriteScaleAmplitude = 1
    self.maxWarningAngleRandomiseCooldown = 0.25
    self.minimumEnemyCount = 3

    self.introCounts = 3
    self.introLerpSpeed = 0.1
    self.secondsBetweenIntroLerps = 0.25

    self.currentWaveIndex = 0
    self.maxWave = 0
    self.timeMinutes = 3
    self.timeSeconds = 0
    self.inWaveTransition = false
    self.spriteScaleFrequency = 0
    self.spriteScale = 1
    self.angleWarningRandomiseCooldown = 0

    self.inIntro = true

    -- Unpack the level table
    self.levelDefinition = levelDefinition
    self.waveDefinitions = self.levelDefinition.level
    self.maxWave = #self.levelDefinition.level
    self.enemyDefinitions = self.levelDefinition.enemyDefinitions
    self.playerStartSegment = self.levelDefinition.arenaSegmentDefinitions[self.levelDefinition.playerStartSegment]
    self.enemySpawnList = {}
    self.arenaSegments = {}

    for name, segment in pairs(self.levelDefinition.arenaSegmentDefinitions) do
        if segment then
            self.arenaSegments[name] = {
                position = vec2(segment.position.x, segment.position.y),
                radius = segment.radius
            }

            local currentGamestate = gamestate.current()
            
            if currentGamestate.arena and self.arenaSegments[name] then
                currentGamestate.arena:addArenaSegment(self.arenaSegments[name])
            end
        end
    end

    -- Initialise variables
    self.spawnTime = self.maxSpawnTime
    self.angleWarningRandomiseCooldown = self.maxWarningAngleRandomiseCooldown
    self.currentIntroCount = self.introCounts
    self.introLerpCooldown = self.secondsBetweenIntroLerps

    -- Set up the hud
    self.hud = stageTimeHud()
    interfaceRenderer:addHudElement(self.hud)
    self.alertElement = text(self.currentIntroCount, "font alert", true, -200, 0)
    interfaceRenderer:addHudElement(self.alertElement)
end

function stageDirector:update(dt)
    -- Update the hud
    self.hud.timeSeconds = self.timeSeconds
    self.hud.timeMinutes = self.timeMinutes

    -- Quit early if the intro is in progress
    if self.inIntro == true then
        self.introLerpCooldown = self.introLerpCooldown - 1 * dt

        -- If the cooldown is less than 0 and the alert is across the screen, reset it
        if self.introLerpCooldown <= 0 and self.alertElement.position.x > screenWidth then
            self.introLerpCooldown = self.secondsBetweenIntroLerps

            self.currentIntroCount = self.currentIntroCount - 1

            self.alertElement.text = self.currentIntroCount
            self.alertElement.position.x = -200

            -- If all resets have happened, start the run
            if self.currentIntroCount <= 0 then
                local arena = gamestate.current().arena

                if arena then
                    arena:enableIntro()
                end

                self.inIntro = false
            end
        end

        -- Lerp the element position to the right side of the screen
        self.alertElement.position.x = math.lerp(self.alertElement.position.x, screenWidth + 200, self.introLerpSpeed)

        return
    end

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
    local currentGamestate = gamestate.current()

    if self.currentWaveIndex <= self.maxWave and currentGamestate.enemyManager then
        -- If no enemies are alive, switch to the next wave
        
        if #currentGamestate.enemyManager.enemies < self.minimumEnemyCount and self.inWaveTransition == false then
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
                gamestate.current():addObject(newEnemy)
            end

            self.inWaveTransition = false
        end
    end
end

function stageDirector:draw()
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
end

function stageDirector:startWave()
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
        local generatedShape = {
            points = {},
            origin = {},
        }

        -- Calculate the vertices
        if currentDefinition.shapeDef.numberOfPoints and currentDefinition.shapeDef.radius then
            local numberOfPoints = currentDefinition.shapeDef.numberOfPoints
            local radius = currentDefinition.shapeDef.radius
            local origin = self.arenaSegments[currentDefinition.shapeDef.origin].position
            local angle = 2 * math.pi / numberOfPoints
            local offset = math.pi / 2

            for i = 1, numberOfPoints do
                local pointX = origin.x + math.cos(i * angle - offset) * radius
                local pointY = origin.y + math.sin(i * angle - offset) * radius

                table.insert(generatedShape.points, {x = pointX, y = pointY})
            end

            generatedShape.origin = currentDefinition.shapeDef.origin
        else
            generatedShape.points = currentDefinition.shapeDef.points
            generatedShape.origin = currentDefinition.shapeDef.origin
        end

        local arenaPosition = self.arenaSegments[generatedShape.origin].position
        local arenaRadius = self.arenaSegments[generatedShape.origin].radius

        if waveType == "randomWithinShape" then
            assert(#generatedShape.points > 1, "Number of points in shape must be greater than 1.")

            for i = 1, enemyDef.spawnCount do
                local pointX = math.random(0, screenWidth)
                local pointY = math.random(0, screenHeight)

                -- Inefficient, must change later
                while PointWithinShape(generatedShape, pointX, pointY) == false do
                    pointX = math.random(arenaPosition.x - arenaRadius, arenaPosition.x + arenaRadius)
                    pointY = math.random(arenaPosition.y - arenaRadius, arenaPosition.y + arenaRadius)
                end

                table.insert(self.enemySpawnList, {
                    enemyClass = self.enemyDefinitions[enemyDef.enemyID].enemyClass,
                    spawnPosition = vec2(pointX, pointY),
                    spriteName = self.enemyDefinitions[enemyDef.enemyID].spriteName,
                    angle = math.random(0, 2*math.pi)
                })
            end
        elseif waveType == "alongShapePerimeter" then
            local enemiesPerLine = math.ceil(enemyDef.spawnCount/#generatedShape.points)

            if #generatedShape.points == 2 then
                enemiesPerLine = enemyDef.spawnCount
            end
            
            assert(#generatedShape.points > 1, "Number of points in shape must be greater than 1.")

            for i = 1, #generatedShape.points do
                local point1 = vec2(generatedShape.points[i].x, generatedShape.points[i].y)
                local point2 = nil

                if #generatedShape.points > 2 then
                    if i == #generatedShape.points then
                        point2 = vec2(generatedShape.points[1].x, generatedShape.points[1].y)
                    else
                        point2 = vec2(generatedShape.points[i + 1].x, generatedShape.points[i + 1].y)
                    end
                else
                    if i == #generatedShape.points then
                        return
                    end

                    point2 = vec2(generatedShape.points[2].x, generatedShape.points[2].y)
                end

                local pointSpacing = (point2 - point1):length()/enemiesPerLine
                
                for i = 1, enemiesPerLine do
                    local vectorBetweenPoints = (point2 - point1):normalise()
                    local enemyPosition = point1 + (vectorBetweenPoints * ((i * pointSpacing) - pointSpacing/2))

                    table.insert(self.enemySpawnList, {
                        enemyClass = self.enemyDefinitions[enemyDef.enemyID].enemyClass,
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
                    local position = vec2()
                    position.x = currentDef.x
                    position.y = currentDef.y

                    table.insert(self.enemySpawnList, {
                        enemyClass = self.enemyDefinitions[currentDef.enemyID].enemyClass,
                        spawnPosition = position,
                        spriteName = self.enemyDefinitions[currentDef.enemyID].spriteName,
                        angle = math.random(0, 2*math.pi)
                    })
                end
            end
        end
    end
end

function stageDirector:cleanup()
    self.alertElement = nil
    self.arenaSegments = nil
end

return stageDirector