local gameObject = require "game.objects.gameObject"
local text = require "game.interface.text"
local collider = require "game.collision.collider"

local boss = class({name = "Boss", extends = gameObject})

function boss:new(x, y)
    self:super(x, y)

    self.contactDamage = 1
    self.shieldHealth = 100
    self.phaseHealth = 50
    self.isInvulnerable = false
    self.invulnerableTime = 0
    self.maxInvulnerableTime = 0.05

    self:setShielded(true)
    self:switchState(self.states.bossIntro)

    self.debugText = text("", "font main", "left", 380, 200, 100)
    game.interfaceRenderer:addHudElement(self.debugText)

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, x, y, 32, 32)
end

function boss:update(dt)
    -- Handle invulnerable switching
    self.invulnerableTime = self.invulnerableTime - 1 * dt

    if self.invulnerableTime <= 0 then
        self.isInvulnerable = false
    end

    if self.isInvulnerable == true then
        self.enemyColour = {1, 1, 1, 1}
    else
        self.enemyColour = game.manager.currentPalette.enemyColour
    end

    -- Update the current state
    if self.currentState and self.currentState.update then
        self.currentState:update(dt, self)
    end

    -- Update the debug text
    if self.debugText and game.manager:getOption("enableDebugMode") == true then
        self.debugText.text = "Current State: "..self.currentState:type().."\n".."Health: "..self.phaseHealth.."\n".."Shield: "..self.shieldHealth
    end

    -- Move enemy collider
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end
end

function boss:draw()

end

function boss:setShielded(isShielded)
    self.isShielded = isShielded or false
    self.phaseHealth = 50
    self.shieldHealth = 100
end

function boss:handleDamage(damage)
    if damage.type == "bullet" then
        if self.isShielded == true then
            self.shieldHealth = self.shieldHealth - damage.amount
        else
            self.phaseHealth = self.phaseHealth - damage.amount
        end
    end
end

function boss:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
end

function boss:onHit(damage)
    if self.isInvulnerable == true then
        return
    end

    if type(damage) ~= "table" then
        damage = {type = "bullet", amount = 1}
    end

    self:handleDamage(damage)

    self:setInvulnerable()

    if game.manager then
        game.manager:setFreezeFrames(3)
    end
end

function boss:switchAttack(attacksTable)
    assert(attacksTable ~= nil, "Attacks table is nil!")

    local index = math.random(1, #attacksTable)
    local state = attacksTable[index]

    self.currentState:exit(self)
    self.currentState = state
    
    self.currentState:enter(self)
end

function boss:switchState(newState)
    if self.currentState ~= nil then
        self.currentState:exit(self)
    end

    local state = newState
    assert(state ~= nil, "State does not exist!")

    self.currentState = state
    self.currentState:enter(self)
end

return boss