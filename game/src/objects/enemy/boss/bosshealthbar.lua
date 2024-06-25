local hudElement = require "src.interface.hudelement"
local eye = require "src.objects.enemy.enemyeye"

local bossHealthBar = class({name = "Boss Health Bar", extends = hudElement})

function bossHealthBar:new(bossInstance, name, subtitle)
    self.bossName = name or "NAME"
    self.bossSubtitle = subtitle or "Subtitle"

    self.barSprite = game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("sprites"):get("bossHealth")
    self.barOutlineSprite = game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("sprites"):get("bossHealthOutline")
    self.eyeOutlineSprite = game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("interface"):get("bossEyeOutline")

    self.scissorStates =
    {
        phase1 =
        {
            maxWidth = 222,
            minWidth = 152,
            height = 15,
            maxEyeAngleChangeCooldown = 2,
            eyeAngleLerpSpeed = 0.1,
        },

        phase2 =
        {
            maxWidth = 149,
            minWidth = 74,
            height = 15,
            maxEyeAngleChangeCooldown = 1,
            eyeAngleLerpSpeed = 0.05,
        },

        phase3 =
        {
            maxWidth = 71,
            minWidth = 2,
            height = 15,
            maxEyeAngleChangeCooldown = 0.2,
            eyeAngleLerpSpeed = 0.005,
        },
    }

    self.bossInstance = bossInstance

    self.shieldHealth = 0
    self.maxShieldHealth = 0
    self.phaseHealth = 0
    self.maxPhaseHealth = 0

    self.inIntro = false
    self.positionYoffset = 60
    self.targetPositionYoffset = 10
    self.bossTitleScissorWidth = 0
    self.targetBossTitleScissorWidth = 100

    self.eyeAngleChangeCooldown = 0
    self.eyeAngle = math.rad(math.random(0, 360))
    self.targetEyeAngle = self.eyeAngle

    self.eye = eye(240, 240, 2, 6, false)

    self:setPhase("phase1")
end

function bossHealthBar:update(dt)
    self.eyeAngleChangeCooldown = self.eyeAngleChangeCooldown - (1 * dt)

    if self.eyeAngleChangeCooldown <= 0 then
        self.eyeAngleChangeCooldown = self.scissorState.maxEyeAngleChangeCooldown
        self.targetEyeAngle = math.rad(math.random(0, 360))
    end

    self.eyeAngle = math.lerpAngle(self.eyeAngle, self.targetEyeAngle, self.scissorState.eyeAngleLerpSpeed, dt)

    if self.eye then
        self.eye:update()
        
        self.eye.eyeRadius = 5

        if self.bossInstance.isInvulnerable then
            self.eye.eyeRadius = 7
        end

        self.eye.eyeAngle = self.eyeAngle

        self.eye.eyeBasePosition.y = 240 + self.positionYoffset
    end

    if self.inIntro then
        self.positionYoffset = math.lerpDT(self.positionYoffset, self.targetPositionYoffset, 0.05, dt)

        if math.abs(self.targetPositionYoffset - self.positionYoffset) < 5 then
            self.bossTitleScissorWidth = math.lerpDT(self.bossTitleScissorWidth, self.targetBossTitleScissorWidth, 0.05, dt)
        end
    end
end

function bossHealthBar:doIntro()
    self.inIntro = true
end

function bossHealthBar:setPhase(phase)
    local phase = self.scissorStates[phase]

    assert(phase ~= nil, "Phase name is invalid!")
    self.scissorState = phase
end

function bossHealthBar:draw()
    self.phaseHealth = math.clamp(self.phaseHealth, 0, self.maxPhaseHealth)
    self.shieldHealth = math.clamp(self.shieldHealth, 0, self.maxShieldHealth)

    local xOffset = 0
    local yOffset = 0

    if self.bossInstance and self.bossInstance.isInvulnerable then
        xOffset = math.random(-2, 2)
        yOffset = math.random(-2, 2)
    end

    local width = math.lerp(222, 0, 1 - self.shieldHealth / self.maxShieldHealth)
    love.graphics.setScissor(129 + xOffset, 224 + yOffset + self.positionYoffset, width, self.scissorState.height + 1)
    love.graphics.draw(self.barSprite, 129 + xOffset, 224 + yOffset + self.positionYoffset)

    width = math.lerp(self.scissorState.maxWidth, self.scissorState.minWidth, 1 - self.phaseHealth / self.maxPhaseHealth)
    love.graphics.setScissor(129 + xOffset, 243 + yOffset + self.positionYoffset, width, self.scissorState.height)
    love.graphics.draw(self.barSprite, 129 + xOffset, 224 + yOffset + self.positionYoffset)
    love.graphics.setScissor()

    if self.eye then
        self.eye:draw()
    end

    love.graphics.setFont(game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("fonts"):get("fontMain"))

    love.graphics.setScissor(240 - self.bossTitleScissorWidth, 0, self.bossTitleScissorWidth * 2, 270)
    love.graphics.printf(self.bossName, 240 - 300/2 + xOffset, 220 + self.positionYoffset + yOffset, 300, "center")
    love.graphics.setScissor()

    love.graphics.draw(self.eyeOutlineSprite, 129 + xOffset, 224 + yOffset + self.positionYoffset)
    love.graphics.draw(self.barOutlineSprite, 128 + xOffset, 223 + yOffset + self.positionYoffset)
end

return bossHealthBar