local gameObject = require "src.objects.gameobject"
local text = require "src.interface.text"
local enemyWarning = require "src.objects.enemy.enemywarning"
local bossWarning = require "src.objects.enemy.boss.bosswarning"
local timer = require "src.objects.stagedirector.stagetimer"
local alertObject = require "src.objects.stagedirector.alertobject"
local worldAlertObject = require "src.objects.stagedirector.worldalertobject"
local soundObject = require "src.objects.stagedirector.spawnsound"
local killDisplay = require "src.objects.stagedirector.killprogressdisplay"
local timePickup = require "src.objects.stagedirector.timepickup"

local stageDirector = class({name = "Stage Director", extends = gameObject})

function stageDirector:new(levelDefinition)
    self:super(0, 0)

    self.maxMinutes = 0
    self.maxSeconds = 30
    self.waveTime = 15
    self.bossMinutes = 0
    self.bossSeconds = 0
    self.enemyKillPercentage = 0.7

    self.maxWaveTransitionTime = 0.3
    self.secondsBetweenTextChange = 0.5
    self.enemySpawnTime = 2
    self.outroTime = 3

    self.introText = {"Ready?", "Steady?", "GO!"}
    self.textChangeCooldown = self.secondsBetweenTextChange
    self.currentText = 0

    self.timer = timer(self.maxMinutes, self.maxSeconds)

    gameHelper:addGameObject(self.timer)
    self:setTimerPaused(true)

    self.currentWaveIndex = 0
    self.currentWaveType = "enemy"
    self.waveTransitionTime = self.maxWaveTransitionTime
    self.inWaveTransition = false
    self.elapsedWaveTime = 0
    self.enemySpawnTimer = self.enemySpawnTime

    self.enemyKills = 0
    self.totalKills = 0
    self.bossReference = nil
    self.minimumEnemyKills = 0
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
    self.playerStartSegment = nil
    self.currentWaveIndex = self.levelDefinition.startingWave or self.currentWaveIndex

    -- Initialise the segments and add them to the arena
    for i = 1, #self.levelDefinition.arenaSegmentDefinitions do
        local segment = self.levelDefinition.arenaSegmentDefinitions[i]

        if segment then
            local currentGamestate = gameHelper:getCurrentState()
            local newSegment = currentGamestate.arena:addArenaSegment(segment.position.x, segment.position.y, segment.radius, segment.name)

            if segment.name == self.levelDefinition.playerStartSegment then
                self.playerStartSegment = newSegment
            end
        end
    end

    if self.playerStartSegment == nil then
        assert(false, "No player segment specified!")
    end

    self.debugText = text("", "fontMain", "left", 10, 200, game.arenaValues.screenWidth)
    game.interfaceRenderer:addHudElement(self.debugText)

    self.killDisplay = killDisplay()
    game.interfaceRenderer:addHudElement(self.killDisplay)
end

function stageDirector:update(dt)
    -- Quit early if the intro is in progress
    if self.inIntro == true then
        self:setTimerPaused(true)

        self.textChangeCooldown = self.textChangeCooldown - 1 * dt

        if self.textChangeCooldown <= 0 then
            if self.currentText >= #self.introText then
                local arena = gameHelper:getCurrentState().arena

                if arena then
                    arena:enableIntro()
                end

                self.inIntro = false
                return
            end

            self.textChangeCooldown = self.secondsBetweenTextChange
            self.currentText = self.currentText + 1
            
            local text = alertObject(self.introText[self.currentText], 0.05, 0.3)
            gameHelper:addGameObject(text)
            gameHelper:screenShake(0.1)
        end

        return
    end

    if game.playerManager:doesPlayerExist() == false then
        return
    end

    if self.currentWaveType ~= "bossWave" then
        -- Transition to the next wave
        if self.inWaveTransition == true then
            self.waveTransitionTime = self.waveTransitionTime - (1 * dt)

            if self.waveTransitionTime <= 0 then
                self:startWave()
                self.inWaveTransition = false
                self.waveTransitionTime = self.maxWaveTransitionTime
            end
        end

        if self.inWaveTransition == false then
            self.enemySpawnTimer = self.enemySpawnTimer - (1 * dt)

            if self.enemySpawnTimer <= 0 then
                self.elapsedWaveTime = self.elapsedWaveTime + (1 * dt)
            end
        end

        if self.enemyKills >= self.minimumEnemyKills then
            self.inWaveTransition = true
        end

        self.killDisplay.kills = self.enemyKills
        self.killDisplay.totalKills = self.minimumEnemyKills

        self.killDisplay.time = self.elapsedWaveTime
        self.killDisplay.totalTime = self.waveTime
    else
        if self.bossReference and self.bossReference.markedForDelete then
            self.outroTime = self.outroTime - 1 * dt

            if self.outroTime <= 0 then
                local playerManager = game.playerManager
                local playerReference = playerManager.playerReference

                if playerReference then
                    playerReference:setInvulnerable()
                end

                local arena = gameHelper:getArena()
                arena:enableOutro()

                if arena.outroComplete == true then
                    game.transitionManager:doTransition("victoryState")
                    game.manager.runInfo.bossTime.minutes = self.bossMinutes
                    game.manager.runInfo.bossTime.seconds = self.bossSeconds
                end
            end
        else
            self.bossSeconds = self.bossSeconds + (1 * dt)

            if self.bossSeconds > 59 then
                self.bossMinutes = self.bossMinutes + 1
                self.bossSeconds = 0
            end

            local player = game.playerManager.playerReference
        
            if self.timer.timeSeconds <= 0 and self.timer.timeMinutes <= 0 then
                player:destroy()
                game.manager.runInfo.deathReason = "You ran out of time!"
        
                self:setTimerPaused(true)
            end
        end
    end
end

function stageDirector:setTime(minutes, seconds)
    self.timer:setTime(minutes or 1, seconds or 59)
end

function stageDirector:addTime(minutes, seconds)
    self.timer:addTime(minutes or 0, seconds or 0)
end

function stageDirector:getAbsoluteTime(minutes, seconds)
    return self.timer:getAbsoluteTime(minutes or 0, seconds or 0)
end

function stageDirector:registerBoss(boss)
    self.bossReference = boss
end

function stageDirector:setTimerPaused(isPaused)
    self.timer:setTimerPaused(isPaused)
end

function stageDirector:spawnEnemy(x, y, originSegment, spawnClass)
    local newWarning = enemyWarning(x, y, originSegment, spawnClass, self.enemySpawnTime)
    gameHelper:addGameObject(newWarning)
end

function stageDirector:startWave()
    if self.currentWaveIndex > self.maxWave then
        return
    end
    
    -- Increment the wave index
    self.currentWaveIndex = self.currentWaveIndex + 1
    
    -- Apply the score and wave bonus
    if self.currentWaveIndex > 1 then
        if self.elapsedWaveTime < self.waveTime then
            gameHelper:getScoreManager():applyBonus("waveBonus")
        end

        gameHelper:getScoreManager():applyWaveScore()
    end

    gameHelper:getScoreManager():beginNewWaveScore()

    gameHelper:addGameObject(soundObject(self.enemySpawnTime))

    -- Get a reference to the gamestate and arena
    local currentGamestate = gameHelper:getCurrentState()
    local arena = currentGamestate.arena

    if not arena then
        return
    end

    -- Unpack the current wave
    local wave = self.waveDefinitions[self.currentWaveIndex]
    local spawnDefinitions = wave.spawnDefinitions
    local segmentChanges = wave.segmentChanges
    self.currentWaveType = wave.waveType or "enemyWave"

    -- Reset the number of kills and other values
    self.enemyKills = 0
    self.minimumEnemyKills = 0
    self.waveTransitionTime = 3
    self.elapsedWaveTime = 0
    self.enemySpawnTimer = self.enemySpawnTime

    -- For each segment change
    if segmentChanges then
        for i = 1, #segmentChanges do
            local segment = currentGamestate.arena:getArenaSegment(segmentChanges[i].arenaSegment)
            segment:addChange(segmentChanges[i])
        end
    end

    -- For each spawn definition
    if self.currentWaveType == "bossWave" then
        local newBossWarning = bossWarning(0, 0, self.enemyDefinitions[wave.bossID])
        gameHelper:addGameObject(newBossWarning)
        game.interfaceRenderer:removeHudElement(self.killDisplay)
    end

    if not spawnDefinitions then
        return
    end

    local totalEnemies = 0

    for i = 1, #spawnDefinitions do
        local currentDefinition = spawnDefinitions[i]

        -- Grab the values from the current definition
        -- and set up a table for the generated shape, if applicable
        local spawnType = currentDefinition.spawnType
        local enemyDef = currentDefinition.enemyDef
        local originSegment = arena:getArenaSegment(currentDefinition.shapeDef.origin)
        local generatedShape = {
            points = {},
            origin = {},
        }

        -- Calculate the vertices of the shape, or set them to the predefined values
        if currentDefinition.shapeDef.numberOfPoints and currentDefinition.shapeDef.radius then
            local numberOfPoints = currentDefinition.shapeDef.numberOfPoints
            local radius = currentDefinition.shapeDef.radius
            local angle = 2 * math.pi / numberOfPoints
            local angleOffset = math.pi / 2

            local pointOffset = vec2(0, 0)

            if currentDefinition.shapeDef.offset then
                pointOffset = currentDefinition.shapeDef.offset
            end

            for i = 1, numberOfPoints do
                local pointX = pointOffset.x + math.cos(i * angle - angleOffset) * radius
                local pointY = pointOffset.y + math.sin(i * angle - angleOffset) * radius

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
        if spawnType == "randomWithinShape" then
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
                totalEnemies = totalEnemies + 1
            end
        elseif spawnType == "alongShapePerimeter" then
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
                        break
                    end

                    point2 = vec2(generatedShape.points[2].x, generatedShape.points[2].y)
                end

                local pointSpacing = (point2 - point1):length()/enemiesPerLine
                
                for i = 1, enemiesPerLine do
                    local vectorBetweenPoints = (point2 - point1):normalise()
                    local enemyPosition = point1 + (vectorBetweenPoints * ((i * pointSpacing) - pointSpacing/2))
                    
                    self:spawnEnemy(enemyPosition.x, enemyPosition.y, generatedShape.origin, enemyDefinition)
                    totalEnemies = totalEnemies + 1
                end
            end
        elseif spawnType == "predefined" then
            local enemyDefinition = self.enemyDefinitions[enemyDef.enemyID]
            self:spawnEnemy(generatedShape.points.x, generatedShape.points.y, generatedShape.origin, enemyDefinition)
            totalEnemies = totalEnemies + 1
        end
    end

    self.minimumEnemyKills = math.ceil(totalEnemies * self.enemyKillPercentage)
end

function stageDirector:registerEnemyKill()
    self.enemyKills = self.enemyKills + 1
    self.totalKills = self.totalKills + 1
end

function stageDirector:addTimePickup(secondsToAdd)
    local position = gameHelper:getArena():getRandomPosition(0.7)
    gameHelper:addGameObject(timePickup(position.x, position.y, secondsToAdd or 0))
end

function stageDirector:draw()
    local debugText = ""

    for i = 1, #self.nextWaveConditions do
        local condition = self.nextWaveConditions[i]

        if condition then
            if condition.conditionType == "minimumKills" then
                local minimumKills = condition.minimumKills or 1
                debugText = debugText.."Kills: "..self.enemyKills.."\n/"..minimumKills.."\n"
            elseif condition.conditionType == "timer" then
                local time = condition.timeUntilNextWave or 3
                debugText = debugText.."Max time: "..self.elapsedWaveTime.."\n/"..time.."\n"
            end
        end
    end

    debugText = debugText.."Wave: "..self.currentWaveIndex
    
    if game.manager:getOption("enableDebugMode") == true and self.debugText then
        self.debugText.text = debugText
    end
end

function stageDirector:cleanup()
    game.interfaceRenderer:removeHudElement(self.debugText)
    game.interfaceRenderer:removeHudElement(self.killDisplay)
    gameHelper:getScoreManager():applyWaveScore()

    game.manager.runInfo.time.minutes = self.timer.totalMinutes
    game.manager.runInfo.time.seconds = self.timer.totalSeconds
    game.manager.runInfo.kills = self.totalKills
end

return stageDirector