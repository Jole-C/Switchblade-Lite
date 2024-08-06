local timedGamemode = require "src.gamemode.timedgamemode"
local killDisplay = require "src.objects.stagedirector.killprogressdisplay"
local soundObject = require "src.objects.stagedirector.spawnsound"
local bossWarning = require "src.objects.enemy.boss.bosswarning"
local enemyWarning = require "src.objects.enemy.enemywarning"

local gauntlet = class({name = "Gauntlet", extends = timedGamemode})

function gauntlet:new()
    self:super(3, 0)
    
    self.hasTimer = true

    self.waveTime = 15
    self.bossMinutes = 0
    self.bossSeconds = 0
    self.enemyKillPercentage = 0.6

    self.maxWaveTransitionTime = 0.3
    self.enemySpawnTime = 2
    self.outroTime = 3

    self.currentWaveIndex = 0
    self.currentWaveType = "enemy"
    self.waveTransitionTime = self.maxWaveTransitionTime
    self.inWaveTransition = false
    self.elapsedWaveTime = 0
    self.enemySpawnTimer = self.enemySpawnTime

    self.enemyKills = 0
    self.bossReference = nil
    self.minimumEnemyKills = 0
    self.nextWaveConditions = {
        {
            conditionType = "timer",
            timeUntilNextWave = 0
        }
    }

    self.levelDefinition = game.manager.runSetup.level
    assert(self.levelDefinition ~= nil, "Current level definition is nil!")
    
    self.waveDefinitions = self.levelDefinition.level
    self.maxWave = #self.levelDefinition.level
    self.enemyDefinitions = self.levelDefinition.enemyDefinitions
    self.playerStartSegment = nil
    self.currentWaveIndex = self.levelDefinition.startingWave or self.currentWaveIndex

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

    self.playerSpawnPosition = self.playerStartSegment.position

    self.killDisplay = killDisplay()
    game.interfaceRenderer:addHudElement(self.killDisplay)
end

function gauntlet:update(dt)
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
    
                    game.manager:addRunInfoText("Boss Time", {self.bossMinutes, self.bossSeconds})
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
        
                self:setTimerPaused(true)
            end
        end
    end
end

function gauntlet:draw()
    timedGamemode.draw(self)
end

function gauntlet:setupDebugText(inputText)
    local debugText = timedGamemode.setupDebugText(inputText)

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

    return debugText.."Wave: "..self.currentWaveIndex
end

function gauntlet:startWave()
    -- Increment the wave index
    self.currentWaveIndex = self.currentWaveIndex + 1

    if self.currentWaveIndex > self.maxWave then
        return
    end
    
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

    local enemies = #gameHelper:getEnemyManager().enemies
    totalEnemies = totalEnemies + enemies

    self.minimumEnemyKills = math.ceil(totalEnemies * self.enemyKillPercentage)
end

function gauntlet:registerEnemyKill()
    self.enemyKills = self.enemyKills + 1
    self.totalKills = self.totalKills + 1
end

function gauntlet:registerBoss(boss)
    self.bossReference = boss
end

function gauntlet:spawnEnemy(x, y, originSegment, spawnClass)
    local newWarning = enemyWarning(x, y, originSegment, spawnClass, self.enemySpawnTime)
    gameHelper:addGameObject(newWarning)
end

function gauntlet:cleanup()
    timedGamemode.cleanup(self)

    game.interfaceRenderer:removeHudElement(self.killDisplay)
end

return gauntlet