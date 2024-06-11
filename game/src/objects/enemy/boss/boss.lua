local enemyBase = require "src.objects.enemy.enemybase"
local text = require "src.interface.text"
local collider = require "src.collision.collider"

local boss = class({name = "Boss", extends = enemyBase})

function boss:new(x, y)
    self:super(x, y)

    self.contactDamage = 1
    self.shieldHealth = 100
    self.phaseHealth = 30
    self.isInvulnerable = false
    self.invulnerableTime = 0
    self.maxInvulnerableTime = 0.05
    self.colliders = {}
    self.colliderIndices = {}

    self:setShielded(true)
    self:switchState(self.states.bossIntro)

    self.debugText = text("", "font main", "left", 380, 200, 100)
    game.interfaceRenderer:addHudElement(self.debugText)

    gameHelper:getCurrentState().stageDirector:registerBoss(self)
end

function boss:update(dt)
    enemyBase.update(self, dt)

    local world = gameHelper:getWorld()

    for _, colliderParameter in pairs(self.colliders) do
        if world:hasItem(colliderParameter.colliderReference) then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(colliderParameter.colliderReference)
            colliderPositionX = colliderParameter.position.x - colliderWidth/2
            colliderPositionY = colliderParameter.position.y - colliderHeight/2
            
            world:update(colliderParameter.colliderReference, colliderPositionX, colliderPositionY)
        end
    end

    self:checkColliders(self.colliderIndices)

    if self.currentState and self.currentState.update then
        self.currentState:update(dt, self)
    end

    if self.debugText and game.manager:getOption("enableDebugMode") == true then
        self.debugText.text = "Current State: "..self.currentState:type().."\n".."Health: "..self.phaseHealth.."\n".."Shield: "..self.shieldHealth
    end
end

function boss:draw()

end

function boss:setShielded(isShielded)
    self.isShielded = isShielded or false
    self.phaseHealth = 30
    self.shieldHealth = 100
end

function boss:initialiseColliders(colliderParameters)
    local world = gameHelper:getWorld()

    for colliderName, colliderParameter in pairs(colliderParameters) do
        local newCollider = collider(colliderDefinitions.enemy, self)

        self.colliders[colliderName] = {
            colliderReference = newCollider,
            position = self.position:copy(),
            width = colliderParameter.width
        }

        world:add(newCollider, self.position.x, self.position.y, colliderParameter.width, colliderParameter.width)
        table.insert(self.colliderIndices, newCollider)
    end
end

function boss:updateColliderPosition(colliderName, x, y)
    local collider = self.colliders[colliderName]

    assert(collider ~= nil, "Collider does not exist!")

    collider.position.x = x
    collider.position.y = y
end

function boss:handleDamage(damageType, amount)
    if damageType == "bullet" then
        if self.isShielded == true then
            self.shieldHealth = self.shieldHealth - amount
        else
            self.phaseHealth = self.phaseHealth - amount
        end
        
        return true
    end
end

function boss:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
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