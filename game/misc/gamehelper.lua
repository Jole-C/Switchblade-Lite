local gameHelper = {}

function gameHelper:addGameObject(object)
    local currentGamestate = self:getCurrentState()

    assert(object ~= nil, "Object is nil!")

    currentGamestate:addObject(object)
end

function gameHelper:getCurrentState()
    local currentGamestate = game.gameStateMachine:current_state()

    assert(currentGamestate ~= nil, "Gamestate is nil!")

    return currentGamestate
end

function gameHelper:getWorld()
    local currentGamestate = self:getCurrentState()
    
    assert(currentGamestate.world ~= nil, "Gamestate's world is nil!")

    return currentGamestate.world
end

function gameHelper:getArena()
    local currentGamestate = self:getCurrentState()
    
    assert(currentGamestate.arena ~= nil, "Gamestate's arena is nil!")

    return currentGamestate.arena
end

function gameHelper:screenShake(amount)
    local currentGamestate = self:getCurrentState()

    assert(currentGamestate.cameraManager ~= nil, "Gamestate's camera manager is nil!")

    currentGamestate.cameraManager:screenShake(amount)
end

return gameHelper