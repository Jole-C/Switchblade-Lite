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

    self.introText = {"Ready?", "Steady?", "GO!"}
    self.secondsBetweenTextChange = 0.25
    self.currentText = 1

    self.currentWaveIndex = 0
    self.maxWave = 0
    self.timeMinutes = 3
    self.timeSeconds = 0
    self.inWaveTransition = false
    self.spriteScaleFrequency = 0
    self.spriteScale = 1
    self.angleWarningRandomiseCooldown = 0
    self.minimumKillsForNextWave = 0

    self.inIntro = true

    -- Unpack the level table
    self.levelDefinition = levelDefinition
    self.waveDefinitions = self.levelDefinition.level
    self.maxWave = #self.levelDefinition.level
    self.enemyDefinitions = self.levelDefinition.enemyDefinitions
    self.playerStartSegment = self.levelDefinition.arenaSegmentDefinitions[self.levelDefinition.playerStartSegment]
    self.enemySpawnList = {}
    self.segmentChangeList = {}
    self.arenaSegments = {}

    -- Initialise the segments and add them to the arena
    for name, segment in pairs(self.levelDefinition.arenaSegmentDefinitions) do
        if segment then
            self.arenaSegments[name] = {
                position = vec2(segment.position.x, segment.position.y),
                defaultPosition = vec2(segment.position.x, segment.position.y),
                radius = segment.radius,
                defaultRadius = segment.radius,
            }

            local currentGamestate = gameHelper:getCurrentState()
            
            if currentGamestate.arena and self.arenaSegments[name] then
                currentGamestate.arena:addArenaSegment(self.arenaSegments[name])
            end
        end
    end

    -- Initialise variables
    self.spawnTime = self.maxSpawnTime
    self.angleWarningRandomiseCooldown = self.maxWarningAngleRandomiseCooldown
    self.textChangeCooldown = self.secondsBetweenTextChange

    -- Set up the hud
    self.hud = stageTimeHud()
    game.interfaceRenderer:addHudElement(self.hud)
    self.alertElement = text(self.introText[1], "font alert", "center", 0, game.arenaValues.screenHeight/2 - 20, game.arenaValues.screenWidth)
    game.interfaceRenderer:addHudElement(self.alertElement)
end

function stageDirector:update(dt)
    -- Update the hud
    self.hud.timeSeconds = self.timeSeconds
    self.hud.timeMinutes = self.timeMinutes

    -- Quit early if the intro is in progress
    if self.inIntro == true then
        
        self.textChangeCooldown = self.textChangeCooldown - 1 * dt

        if self.textChangeCooldown <= 0 then
            self.textChangeCooldown = self.secondsBetweenTextChange
            self.currentText = self.currentText + 1

            if self.currentText > #self.introText then
                local arena = gameHelper:getCurrentState().arena

                if arena then
                    arena:enableIntro()
                end

                self.inIntro = false
            else
                self.alertElement.text = self.introText[self.currentText]
            end
        end

        return
    else
        self.alertElement.text = ""
    end

    -- Handle gameover state switching
    local player = game.playerManager.playerReference

    if game.playerManager and game.playerManager:doesPlayerExist() == false then
        game.gameStateMachine:set_state("gameOverState")
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

    -- Go through the list of segment changes and perform them
    for i = #self.segmentChangeList, 1, -1 do
        local currentChange = self.segmentChangeList[i]
        local segment = self.arenaSegments[currentChange.arenaSegment]
        local completeThreshold = 10

        if type(currentChange.newValue) == "number" then
            completeThreshold = currentChange.completeThreshold or currentChange.newValue/10
        end

        -- Depending on the type of change, apply it to the correct values
        if currentChange.changeType == "size" then
            segment.radius = math.lerp(segment.radius, currentChange.newValue, currentChange.lerpSpeed)

            if currentChange.newValue - segment.radius < completeThreshold then
                table.remove(self.segmentChangeList, i)
            end
        elseif currentChange.changeType == "position" then
            segment.position.x = math.lerp(segment.position.x, currentChange.newValue.x, currentChange.lerpSpeed)
            segment.position.y = math.lerp(segment.position.y, currentChange.newValue.y, currentChange.lerpSpeed)

            if (currentChange.newValue - segment.position):length() < 10 then
                table.remove(self.segmentChangeList, i)
            end
        elseif currentChange.changeType == "reset" then
            segment.position.x = math.lerp(segment.position.x, segment.defaultPosition.x, currentChange.lerpSpeed)
            segment.position.y = math.lerp(segment.position.y, segment.defaultPosition.y, currentChange.lerpSpeed)
            segment.radius = math.lerp(segment.radius, segment.defaultRadius, currentChange.lerpSpeed)

            if segment.defaultRadius - segment.radius < completeThreshold and (segment.defaultPosition - segment.position):length() < 10 then
                table.remove(self.segmentChangeList, i)
            end
        end
    end

    -- Handle enemy spawns and wave changing
    local currentGamestate = gameHelper:getCurrentState()

    if self.currentWaveIndex <= self.maxWave and currentGamestate.enemyManager then
        -- Start the new wave if the minimum amount of enemies are present
        if #currentGamestate.enemyManager.enemies <= self.minimumEnemyCount and self.inWaveTransition == false then
            self.enemySpawnList = {}
            self.segmentChangeList = {}
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
                gameHelper:addGameObject(newEnemy)
            end

            self.inWaveTransition = false

            -- Set the minimum enemies for the next wave to start
            local currentGamestate = gameHelper:getCurrentState()
            
            if currentGamestate.enemyManager then
                self.minimumEnemyCount = #currentGamestate.enemyManager.enemies - (self.minimumKillsForNextWave or 1)
            end        
        end
    end
end

function stageDirector:draw()
    -- Draw the warning sprites
    if self.inWaveTransition == true then
        for i = 1, #self.enemySpawnList do
            local nextSpawn = self.enemySpawnList[i]

            local sprite = game.resourceManager:getResource(nextSpawn.spriteName)
            local xOffset, yOffset = sprite:getDimensions()
            xOffset = xOffset/2
            yOffset = yOffset/2
    
            love.graphics.setColor(game.manager.currentPalette.enemySpawnColour)
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
    local segmentChanges = wave.segmentChanges

    if spawnDefinitions == nil then
        return
    end

    -- Set the amount of kills required for the next wave
    self.minimumKillsForNextWave = (wave.minimumKillsForNextWave or 1)

    -- For each segment change
    if segmentChanges then
        for i = 1, #segmentChanges do
            table.insert(self.segmentChangeList, segmentChanges[i])
        end
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

        -- Calculate the vertices of the shape, or set them to the predefined values
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

        -- Grab the position and radius of the origin segment for this wave
        local arenaPosition = self.arenaSegments[generatedShape.origin].position
        local arenaRadius = self.arenaSegments[generatedShape.origin].radius

        -- Depending on the wave type, spawn enemies differently
        if waveType == "randomWithinShape" then
            assert(#generatedShape.points > 1, "Number of points in shape must be greater than 1.")

            for i = 1, enemyDef.spawnCount do
                local pointX = math.random(arenaPosition.x - arenaRadius, arenaPosition.x + arenaRadius)
                local pointY = math.random(arenaPosition.y - arenaRadius, arenaPosition.y + arenaRadius)

                -- Inefficient, must change later
                while PointWithinShape(generatedShape.points, pointX, pointY) == false do
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
            table.insert(self.enemySpawnList, {
                enemyClass = self.enemyDefinitions[enemyDef.enemyID].enemyClass,
                spawnPosition = {x = arenaPosition.x + generatedShape.points.x, y = arenaPosition.y + generatedShape.points.y},
                spriteName = self.enemyDefinitions[enemyDef.enemyID].spriteName,
                angle = math.random(0, 2*math.pi)
            })
        end
    end
end

function stageDirector:cleanup()
    game.interfaceRenderer:removeHudElement(self.alertElement)
    self.alertElement = nil
    self.arenaSegments = nil
end

return stageDirector