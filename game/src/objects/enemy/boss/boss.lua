local enemyBase = require "src.objects.enemy.enemybase"
local text = require "src.interface.text"
local bossHealthBar = require "src.objects.enemy.boss.bosshealthbar"
local bossIntroCard = require "src.objects.enemy.boss.bossintrocard"

local boss = class({name = "Boss", extends = enemyBase})

function boss:new(x, y)
    self:super(x, y)

    self.contactDamage = 1
    self.shieldHealth = 100
    self.phaseHealth = 50
    self.maxShieldHealth = 100
    self.maxPhaseHealth = 50
    self.bossHitScore = 10

    self.isInvulnerable = false
    self.invulnerableTime = 0
    self.maxInvulnerableTime = 0.05

    self.phaseIndex = ""
    self.phase = nil
    self.shieldState = {}
    self.states = nil
    self.lastAttack = nil

    self.debugText = text("", "fontMain", "left", 380, 200, 100)
    game.interfaceRenderer:addHudElement(self.debugText)

    self.explosionSounds = game.resourceManager:getAsset("Enemy Assets"):get("bossExplosionSounds"):get("midExplosion")
    self.explosionSoundEnd = game.resourceManager:getAsset("Enemy Assets"):get("bossExplosionSounds"):get("endExplosion")
    self.deathSound = game.resourceManager:getAsset("Music"):get("boss"):get("dead")

    self.healthElement = bossHealthBar(self, self.bossName, self.bossSubtitle)
    game.interfaceRenderer:addHudElement(self.healthElement)

    self.introCard = bossIntroCard(self.bossName, self.bossSubtitle)
    game.interfaceRenderer:addHudElement(self.introCard)

    gameHelper:getGamemode():registerBoss(self)
end

function boss:update(dt)
    enemyBase.update(self, dt)

    if self.currentState and self.currentState.update then
        self.currentState:update(dt, self)
    end

    if self.debugText and game.manager:getOption("enableDebugMode") == true then
        if self.currentState == nil then
            return
        end

        self.debugText.text = "Current Phase: "..self.phaseIndex.."\n".."Current State: "..self.currentState:type().."\n".."Health: "..self.phaseHealth.."\n".."Shield: "..self.shieldHealth
    end

    self.healthElement.shieldHealth = self.shieldHealth
    self.healthElement.phaseHealth = self.phaseHealth
    self.healthElement.maxShieldHealth = self.maxShieldHealth
    self.healthElement.maxPhaseHealth = self.maxPhaseHealth
    self.healthElement:update(dt)

    self.introCard:update(dt)
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

function boss:setPhaseTime()
    gameHelper:getCurrentState().stageDirector:setTime(1, 0)
end

function boss:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
end

function boss:switchAttack(attacksTable)
    assert(attacksTable ~= nil, "Attacks table is nil! Did you specify an attacks table in the state parameters?")

    local numberOfEnemies = #gameHelper:getCurrentState().enemyManager.enemies
    local tableToUse = attacksTable
    local bulletAttacks = {
        attackList = {},
        attackWeights = {}
    }

    if numberOfEnemies > 30 then
        for i = 1, #attacksTable.attackList do
            local attack = attacksTable.attackList[i]
            local weight = attacksTable.attackWeights[i]

            if attack.isBulletAttack then
                table.insert(bulletAttacks.attackList, attack)
                table.insert(bulletAttacks.attackWeights, weight)
            end
        end
        
        tableToUse = bulletAttacks
    end

    local state = tablex.pick_weighted_random(tableToUse.attackList, tableToUse.attackWeights)

    if #tableToUse.attackList > 1 then
        while state == self.lastAttack do
            state = tablex.pick_weighted_random(tableToUse.attackList, tableToUse.attackWeights)
        end

        self.lastAttack = state
    end

    self.currentState:exit(self)
    self.currentState = state
    
    self.currentState:enter(self)
end

function boss:playExplosionSound()
    local sound = self.explosionSounds:get()
    sound:play()
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

function boss:cleanup(destroyReason)
    if destroyReason ~= "autoDestruction" then
        self.explosionSoundEnd:play()
        game.particleManager:burstEffect("Boss Death", 100, self.position)
        gameHelper:screenShake(1)
        
        game.musicManager:pauseAllTracks()
        game.musicManager:getTrack("levelMusic"):play(1)
    end

    game.manager:swapPaletteGroup("main")

    game.interfaceRenderer:removeHudElement(self.healthElement)
    game.interfaceRenderer:removeHudElement(self.debugText)
    game.interfaceRenderer:removeHudElement(self.introCard)
end

return boss