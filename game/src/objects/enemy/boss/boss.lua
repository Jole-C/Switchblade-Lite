local enemyBase = require "src.objects.enemy.enemybase"
local text = require "src.interface.text"
local collider = require "src.collision.collider"
local bossHealthBar = require "src.objects.enemy.boss.bosshealthbar"

local boss = class({name = "Boss", extends = enemyBase})

function boss:new(x, y)
    self:super(x, y)

    self.contactDamage = 1
    self.shieldHealth = 100
    self.phaseHealth = 50
    self.maxShieldHealth = 100
    self.maxPhaseHealth = 50

    self.isInvulnerable = false
    self.invulnerableTime = 0
    self.maxInvulnerableTime = 0.05

    self.colliders = {}
    self.colliderIndices = {}

    self.phaseIndex = ""
    self.phase = nil
    self.shieldState = {}
    self.states = nil

    self.debugText = text("", "font main", "left", 380, 200, 100)
    game.interfaceRenderer:addHudElement(self.debugText)

    self.explosionSounds = {}

    for i = 1, 4 do
        table.insert(self.explosionSounds, ripple.newSound(game.resourceManager:getResource("boss explosion "..i)))
        self.explosionSounds[i]:tag(game.tags.sfx)
    end

    self.explosionSoundEnd = ripple.newSound(game.resourceManager:getResource("boss explosion end"))
    self.explosionSoundEnd:tag(game.tags.sfx)

    self.healthElement = bossHealthBar(self, self.bossName, self.bossSubtitle)
    game.interfaceRenderer:addHudElement(self.healthElement)

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
        self.debugText.text = "Current Phase: "..self.phaseIndex.."\n".."Current State: "..self.currentState:type().."\n".."Health: "..self.phaseHealth.."\n".."Shield: "..self.shieldHealth
    end

    self.healthElement.shieldHealth = self.shieldHealth
    self.healthElement.phaseHealth = self.phaseHealth
    self.healthElement.maxShieldHealth = self.maxShieldHealth
    self.healthElement.maxPhaseHealth = self.maxPhaseHealth
    self.healthElement:update(dt)
end

function boss:setShielded(isShielded)
    self.isShielded = isShielded or false

    local shieldIndex = "shielded"

    if self.isShielded == false then
        shieldIndex = "unshielded"
    end

    assert(type(self.phase) == "table", "No phase table specified! Did you setPhase?")

    self.shieldState = self.phase[shieldIndex]

    if self.isShielded then
        self.shieldHealth = 100
    end

    self.phaseHealth = 50
end

function boss:setPhase(phase)
    if phase == nil then
        self.phaseIndex = "none"
        self.phase = nil
    else
        self.phase = self.states[phase]
        assert(self.phase ~= nil, "Current Phase is nil! Does it exist in the States?")
        self.phaseIndex = phase
        
        self.healthElement:setPhase(phase)
    end
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
    assert(attacksTable ~= nil, "Attacks table is nil! Did you specify an attacks table in the state parameters?")

    local index = math.random(1, #attacksTable)
    local state = attacksTable[index]

    self.currentState:exit(self)
    self.currentState = state
    
    self.currentState:enter(self)
end

function boss:playExplosionSound()
    local soundIndex = math.random(1, #self.explosionSounds)
    local sound = self.explosionSounds[soundIndex]

    if sound then
        sound:play({pitch = math.random(1, 3)})
    end
end

function boss:switchState(newState)
    if self.currentState ~= nil then
        self.currentState:exit(self)
    end

    local state
    
    if type(self.phase) ~= "table" then
        state = self.states[newState]
        assert(state ~= nil, "Current State is nil (No phase specified)! Does it exist on the States table?")
    else
        assert(self.shieldState ~= nil or type(self.shieldState) ~= "table", "Current Shield state is not set! Did you set isShielded or set the current phase to none?")
        state = self.shieldState[newState]
    end

    assert(state ~= nil, "State does not exist!")

    self.currentState = state
    self.currentState:enter(self)
end

function boss:cleanup()
    self.explosionSoundEnd:play()

    local world = gameHelper:getWorld()

    for _, colliderParameter in pairs(self.colliders) do
        if world:hasItem(colliderParameter.colliderReference) then
            world:remove(colliderParameter.colliderReference)
        end
    end

    game.interfaceRenderer:removeHudElement(self.healthElement)
end

return boss