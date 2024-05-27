local gameObject = require "game.objects.gameobject"
local stageTimeHud = require "game.stagetimedisplay"
local text = require "game.interface.text"
local enemyWarning = require "game.objects.enemy.enemywarning"

local stageDirector = class({name = "Stage Director", extends = gameObject})

function stageDirector:new(levelDefinition)
    self:super(0, 0)

    self.maxMinutes = 3
    self.maxSeconds = 0
    self.minimumEnemyCount = 3

    self.introText = {"Ready?", "Steady?", "GO!"}
    self.secondsBetweenTextChange = 0.25
    self.currentText = 1

    self.currentWaveIndex = 0
    self.maxWave = 0
    self.waveTransitionTime = 3
    self.elapsedWaveTime = 0
    self.defaultTimeForNextWave = 15

    self.timeMinutes = 3
    self.timeSeconds = 0

    self.arenaSegments = {}
    self.segmentChangeList = {}

    self.enemyKills = 0
    self.minimumEnemyKills = 0
    self.waveTimer = 0
    self.nextWaveConditions = {
        {
            conditionType = "timer",
            timeUntilNextWave = 0
        }
    }

    self.inIntro = true

    -- Unpack the level table
    self.levelDefinition = levelDefinition
    self.waveDefinitions = self.levelDefinition.level
    self.maxWave = #self.levelDefinition.level
    self.enemyDefinitions = self.levelDefinition.enemyDefinitions
    self.playerStartSegment = self.levelDefinition.arenaSegmentDefinitions[self.levelDefinition.playerStartSegment]

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
    self.textChangeCooldown = self.secondsBetweenTextChange

    -- Set up the hud
    self.hud = stageTimeHud()
    game.interfaceRenderer:addHudElement(self.hud)
    self.alertElement = text(self.introText[1], "font alert", "center", 0, game.arenaValues.screenHeight/2 - 20, game.arenaValues.screenWidth)
    game.interfaceRenderer:addHudElement(self.alertElement)
    self.debugText = text("", "font main", "left", 360, 10, game.arenaValues.screenWidth)
    game.interfaceRenderer:addHudElement(self.debugText)
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

    -- Once this timer hits zero, kills can be registered with the stage director and will count towards starting the next wave
    self.waveTransitionTime = self.waveTransitionTime - (1 * dt)

    -- This timer is the elapsed time into a wave, and is used for both the wave defined override, but also for a default override
    self.elapsedWaveTime = self.elapsedWaveTime + (1 * dt)

    -- Go over the conditions and use them to decide when the next wave will start
    if self.waveTransitionTime <= 0 then
        local useDefaultOverride = true

        for i = 1, #self.nextWaveConditions do
            local condition = self.nextWaveConditions[i]

            if condition then
                if condition.conditionType == "minimumKills" then
                    local minimumKills = condition.minimumKills or 1

                    if self.enemyKills >= minimumKills then
                        self:startWave()
                    end
                elseif condition.conditionType == "timer" then
                    local time = condition.timeUntilNextWave or 3

                    if self.elapsedWaveTime > time then
                        self:startWave()
                    end
                    
                    useDefaultOverride = false
                end
            end
        end

        -- Handle the default timer override
        if useDefaultOverride == true and self.elapsedWaveTime > self.defaultTimeForNextWave then
            self:startWave()
        end
    end
end

function stageDirector:spawnEnemy(x, y, originSegment, spawnClass)
    local newWarning = enemyWarning(x, y, originSegment, spawnClass)
    gameHelper:addGameObject(newWarning)
end

function stageDirector:startWave()
    self.currentWaveIndex = self.currentWaveIndex + 1

    if self.currentWaveIndex > self.maxWave then
        return
    end

    -- Unpack the current wave
    local wave = self.waveDefinitions[self.currentWaveIndex]
    local spawnDefinitions = wave.spawnDefinitions
    local segmentChanges = wave.segmentChanges
    local nextWaveConditions = wave.nextWaveConditions

    -- Reset the number of kills and other values
    self.segmentChangeList = {}
    self.enemyKills = 0
    self.minimumEnemyKills = (wave.minimumKillsForNextWave or 1)
    self.waveTransitionTime = 3
    self.elapsedWaveTime = 0

    -- For each segment change
    if segmentChanges then
        for i = 1, #segmentChanges do
            table.insert(self.segmentChangeList, segmentChanges[i])
        end
    end
    
    -- For each next wave override
    self.nextWaveConditions = {}
    if nextWaveConditions then
        for i = 1, #nextWaveConditions do
            table.insert(self.nextWaveConditions, nextWaveConditions[i])
        end
    else
        table.insert(self.nextWaveConditions, {
            conditionType = "timer",
            timeUntilNextWave = 10
        })
    end

    -- For each spawn definition
    if not spawnDefinitions then
        return
    end

    for i = 1, #spawnDefinitions do
        local currentDefinition = spawnDefinitions[i]

        -- Grab the values from the current definition
        -- and set up a table for the generated shape, if applicable
        local waveType = currentDefinition.waveType
        local enemyDef = currentDefinition.enemyDef
        local originSegment = self.arenaSegments[currentDefinition.shapeDef.origin]
        local generatedShape = {
            points = {},
            origin = {},
        }

        -- Calculate the vertices of the shape, or set them to the predefined values
        if currentDefinition.shapeDef.numberOfPoints and currentDefinition.shapeDef.radius then
            local numberOfPoints = currentDefinition.shapeDef.numberOfPoints
            local radius = currentDefinition.shapeDef.radius
            local angle = 2 * math.pi / numberOfPoints
            local offset = math.pi / 2

            for i = 1, numberOfPoints do
                local pointX = math.cos(i * angle - offset) * radius
                local pointY = math.sin(i * angle - offset) * radius

                table.insert(generatedShape.points, {x = pointX, y = pointY})
            end

            generatedShape.origin = originSegment
        else
            generatedShape.points = currentDefinition.shapeDef.points
            generatedShape.origin = originSegment
        end

        -- Grab the position and radius of the origin segment for this wave
        local arenaPosition = generatedShape.origin.position
        local arenaRadius = generatedShape.origin.radius

        -- Depending on the wave type, spawn enemies differently
        -- Enemies are spawned offset from 0, 0, and then the segment to offset from is
        -- passed to the enemy warning.
        -- This is so enemy warnings can move if their segment moves
        if waveType == "randomWithinShape" then
            assert(#generatedShape.points > 1, "Number of points in shape must be greater than 1.")
            
            local enemyDefinition = self.enemyDefinitions[enemyDef.enemyID]

            for i = 1, enemyDef.spawnCount do
                local pointX = math.random(-arenaRadius, arenaRadius)
                local pointY = math.random(-arenaRadius, arenaRadius)

                -- Inefficient, must change later
                while PointWithinShape(generatedShape.points, pointX, pointY) == false do
                    pointX = math.random(-arenaRadius, arenaRadius)
                    pointY = math.random(-arenaRadius, arenaRadius)
                end

                self:spawnEnemy(pointX, pointY, generatedShape.origin, enemyDefinition)
            end
        elseif waveType == "alongShapePerimeter" then
            local enemiesPerLine = math.ceil(enemyDef.spawnCount/#generatedShape.points)

            if #generatedShape.points == 2 then
                enemiesPerLine = enemyDef.spawnCount
            end
            
            assert(#generatedShape.points > 1, "Number of points in shape must be greater than 1.")
            
            local enemyDefinition = self.enemyDefinitions[enemyDef.enemyID]

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
                    
                    self:spawnEnemy(enemyPosition.x, enemyPosition.y, generatedShape.origin, enemyDefinition)
                end
            end
        elseif waveType == "predefined" then
            local enemyDefinition = self.enemyDefinitions[enemyDef.enemyID]
            self:spawnEnemy(generatedShape.points.x, generatedShape.points.y, generatedShape.origin, enemyDefinition)
        end
    end
end

function stageDirector:registerEnemyKill()
    if self.waveTransitionTime <= 0 then
        self.enemyKills = self.enemyKills + 1
    end
end

function stageDirector:draw()
    local debugText = ""

    for i = 1, #self.nextWaveConditions do
        local condition = self.nextWaveConditions[i]

        if condition then
            if condition.conditionType == "minimumKills" then
                local minimumKills = condition.minimumKills or 1
                debugText = debugText.."Kills: "..self.enemyKills.."\n/"..minimumKills.."\n"

                if self.enemyKills >= minimumKills then
                    self:startWave()
                end
            elseif condition.conditionType == "timer" then
                local time = condition.timeUntilNextWave or 3
                debugText = debugText.."Max time: "..self.elapsedWaveTime.."\n/"..time.."\n"

                if self.elapsedWaveTime > time then
                    self:startWave()
                end
                
                useDefaultOverride = false
            end
        end
    end
    
    if self.debugText then
        self.debugText.text = debugText
    end
end

function stageDirector:cleanup()
    game.interfaceRenderer:removeHudElement(self.alertElement)
    self.alertElement = nil
    self.arenaSegments = nil
end

return stageDirector