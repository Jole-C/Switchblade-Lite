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

function gameHelper:addCollider(collider, x, y, width, height)
    local world = self:getWorld()

    if world then
        world:add(collider, x, y, width, height)
    end
end

function gameHelper:screenShake(amount)
    local currentGamestate = self:getCurrentState()
    currentGamestate.cameraManager:screenShake(amount * game.manager:getOption("screenshakeIntensity")/100)
end

return gameHelper