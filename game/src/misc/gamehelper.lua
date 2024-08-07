local gameHelper = {}

function gameHelper:addGameObject(object)
    local currentGamestate = self:getCurrentState()
    currentGamestate:addObject(object)
end

function gameHelper:getCurrentState()
    local currentGamestate = game.gameStateMachine:current_state()
    return currentGamestate
end

function gameHelper:getWorld()
    local currentGamestate = self:getCurrentState()
    return currentGamestate.world
end

function gameHelper:getArena()
    local currentGamestate = self:getCurrentState()
    return currentGamestate.arena
end

function gameHelper:getEnemyManager()
    local currentGamestate = self:getCurrentState()
    return currentGamestate.enemyManager
end

function gameHelper:getScoreManager()
    local currentGamestate = self:getCurrentState()
    return currentGamestate.scoreManager
end

function gameHelper:getStageDirector()
    local currentGamestate = self:getCurrentState()
    return currentGamestate.stageDirector
end

function gameHelper:getGamemode()
    local stageDirector = self:getStageDirector()
    return stageDirector.gamemode
end

function gameHelper:addScore(score)
    local scoreManager = self:getScoreManager()
    local scoreAdded = 0

    if scoreManager then
        scoreAdded = scoreManager:addScore(score)
    end

    return scoreAdded
end

function gameHelper:resetMultiplier(playSound)
    local scoreManager = self:getScoreManager()

    if scoreManager then
        scoreManager:resetMultiplier(playSound)
    end
end

function gameHelper:incrementMultiplier()
    local scoreManager = self:getScoreManager()

    if scoreManager then
        scoreManager:incrementMultiplier()
    end
end

function gameHelper:setMultiplierPaused(multiplierPaused)
    local scoreManager = self:getScoreManager()

    if scoreManager then
        scoreManager:setMultiplierPaused(multiplierPaused)
    end
end

function gameHelper:addCollider(collider, x, y, width, height)
    local world = self:getWorld()

    if world then
        world:add(collider, x, y, width, height)
    end
end

function gameHelper:screenShake(amount)
    local currentGamestate = self:getCurrentState()

    if currentGamestate.cameraManager then
        currentGamestate.cameraManager:screenShake(amount * game.manager:getOption("screenshakeIntensity")/100)
    end
end

return gameHelper