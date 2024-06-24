local gameObject = require "src.objects.gameobject"
local stageTimeHud = require "src.stagetimedisplay"
local text = require "src.interface.text"
local enemyWarning = require "src.objects.enemy.enemywarning"
local bossWarning = require "src.objects.enemy.boss.bosswarning"

local stageDirector = class({name = "Stage Director", extends = gameObject})

function stageDirector:new(levelDefinition)
    self:super(0, 0)

    self.maxMinutes = 3
    self.maxSeconds = 0
    self.maxWaveTransitionTime = 1
    self.secondsBetweenTextChange = 0.25
    self.enemySpawnTime = 2
    self.defaultTimeForNextWave = 15
    self.outroTime = 3

    self.introText = {"Ready?", "Steady?", "GO!"}
    self.textChangeCooldown = self.secondsBetweenTextChange
    self.currentText = 1

    self.currentWaveIndex = 0
    self.currentWaveType = "enemy"
    self.waveTransitionTime = self.maxWaveTransitionTime
    self.inWaveTransition = false
    self.elapsedWaveTime = 0

    self.timeMinutes = self.maxMinutes
    self.timeSeconds = self.maxSeconds

    self.enemyKills = 0
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

    if game.playerManager:doesPlayerExist() == false then
        game.gameStateMachine:set_state("gameOverState")
    end

    if self.timeSeconds <= 0 then
        self.timeSeconds = 59
        self.timeMinutes = self.timeMinutes - 1
    end

    self.timeSeconds = self.timeSeconds - 1 * dt
    if self.timeSeconds <= 0 and self.timeMinutes <= 0 then
        player:destroy()
        game.playerManager:setPlayerDeathReason("You ran out of time!")
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

        -- This timer is the elapsed time into a wave, and is used for both the wave defined override, but also for a default override
        self.elapsedWaveTime = self.elapsedWaveTime + (1 * dt)

        -- Go over the conditions and use them to decide when the next wave will start
        local useDefaultOverride = true

        for i = 1, #self.nextWaveConditions do
            local condition = self.nextWaveConditions[i]

            if condition then
                if condition.conditionType == "minimumKills" then
                    local minimumKills = condition.minimumKills or 1

                    if self.enemyKills >= minimumKills and self.inWaveTransition == false then
                        self.inWaveTransition = true
                    end
                elseif condition.conditionType == "timer" then
                    local time = condition.timeUntilNextWave or 3

                    if self.elapsedWaveTime > time and self.inWaveTransition == false then
                        self.inWaveTransition = true
                    end
                    
                    useDefaultOverride = false
                end
            end

            -- Handle the default timer override
            if useDefaultOverride == true and self.elapsedWaveTime > self.defaultTimeForNextWave then
                self.inWaveTransition = true
            end
        end
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
                    game.playerManager:setPlayerDeathReason("You won! (Though this is gameover screen)")
                    game.gameStateMachine:set_state("gameOverState")
                end
            end
        end
    end
end

function stageDirector:setTime(minutes, seconds)
    self.timeMinutes = minutes or 1
    self.timeSeconds = seconds or 59
end

function stageDirector:registerBoss(boss)
    self.bossReference = boss
end

function stageDirector:spawnEnemy(x, y, originSegment, spawnClass)
    local newWarning = enemyWarning(x, y, originSegment, spawnClass, self.enemySpawnTime)
    gameHelper:addGameObject(newWarning)
end

function stageDirector:startWave()
    self.currentWaveIndex = self.currentWaveIndex + 1

    if self.currentWaveIndex > self.maxWave then
        return
    end

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
    local nextWaveConditions = wave.nextWaveConditions
    self.currentWaveType = wave.waveType or "enemyWave"

    -- Reset the number of kills and other values
    self.enemyKills = 0
    self.minimumEnemyKills = (wave.minimumKillsForNextWave or 1)
    self.waveTransitionTime = 3
    self.elapsedWaveTime = 0

    -- For each segment change
    if segmentChanges then
        for i = 1, #segmentChanges do
            local segment = currentGamestate.arena:getArenaSegment(segmentChanges[i].arenaSegment)
            segment:addChange(segmentChanges[i])
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
    if self.currentWaveType == "bossWave" then
        local newBossWarning = bossWarning(0, 0, self.enemyDefinitions[wave.bossID])
        gameHelper:addGameObject(newBossWarning)
    end

    if not spawnDefinitions then
        return
    end

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
                end
            end
        elseif spawnType == "predefined" then
            local enemyDefinition = self.enemyDefinitions[enemyDef.enemyID]
            self:spawnEnemy(generatedShape.points.x, generatedShape.points.y, generatedShape.origin, enemyDefinition)
        end
    end
end

function stageDirector:registerEnemyKill()
    self.enemyKills = self.enemyKills + 1
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
    game.interfaceRenderer:removeHudElement(self.alertElement)
    self.alertElement = nil
end

return stageDirector