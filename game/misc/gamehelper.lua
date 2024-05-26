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

return gameHelper