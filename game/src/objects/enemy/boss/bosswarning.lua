local gameObject = require "src.objects.gameobject"
local quad = require "src.interface.quad"
local rect = require "src.interface.rect"
local bossWarning = class({name = "Boss Warning", extends = gameObject})

function bossWarning:new(x, y, bossClass)
    self:super(x, y)

    self.bossClass = bossClass

    -- Create a sprite to hold the caution strip
    self.cautionSprites = {}

    for i = 1, 20 do
        local y = 15 * (i - 1)

        local newQuad = love.graphics.newQuad(0, 0, 480, 15, 480, 15)
        
        local direction = 1

        if i % 2 == 0 then
            direction = -1
        end

        table.insert(self.cautionSprites, {
            sprite = quad("caution strip", newQuad, 0, y, 0, 0, 0, 0, 0, false),
            x = 0,
            direction = direction,
            quad = newQuad
        })
    end

    for i = 1, 20 do
        game.interfaceRenderer:addHudElement(self.cautionSprites[i].sprite)
    end

    -- Create the background rectangle
    self.warningBackground = rect(0, 135, 480, 0, "fill", game.manager.currentPalette.enemySpawnColour, "darken", "premultiplied")
    self.backgroundY = 135
    self.backgroundMaxY = 60
    self.backgroundHeight = 0
    self.backgroundMaxHeight = 165
    self.backgroundLerpSpeed = 0.2

    game.interfaceRenderer:addHudElement(self.warningBackground)

    -- Create quads to hold the warning text
    self.warningQuads = {}
    self.warningSprite = game.resourceManager:getResource("boss warning")
    local warningLength = #"warning"
    local spriteWidth, spriteHeight = self.warningSprite:getDimensions()
    
    for i = 0, warningLength - 1 do
        -- Area of the sprite to draw for the quad
        local x = 67 * i
        local y = 0
        local width = 67
        local height = 270

        -- Centered coordinates for the sprite
        local spriteX = (width * (i + 1)) - width/2
        local spriteY = 135

        local newQuad = love.graphics.newQuad(x, y, width, height, spriteWidth, spriteHeight)

        table.insert(self.warningQuads,
        {
            quad = newQuad,
            scale = 0,
            x = spriteX,
            y = spriteY,
            sprite = quad("boss warning", newQuad, spriteX, spriteY, 0, 0, 0, 67/2, 270/2, false)
        })
    end

    for i = 1, warningLength do
        game.interfaceRenderer:addHudElement(self.warningQuads[i].sprite)
    end

    -- Sin value used for cycling the colour of each letter
    self.warningColourSine = 0
    self.warningColourFrequency = 0.05

    -- Variable used to scale each letter of the WARNING text over time
    self.spriteScaleSpeed = 0.15
    self.currentScaledSprite = 1

    -- After all letters appear they shake by this value
    self.maxShakeIntensity = 6
    self.shakeIntensity = 0
    self.shakeFadeRate = 0.05

    -- The rectangle to display as the warning flash before the full warning appears
    self.warningFlash = rect(0, 0, 480, 270, "fill", {1, 1, 1, 0})
    game.interfaceRenderer:addHudElement(self.warningFlash)

    -- Cooldown for the warning siren
    self.maxWarningSirenCooldown = 2
    self.warningSirenCooldown = 0

    -- The screen will flash white when the whole warning appears
    self.screenFlashAlpha = 1

    -- Stop the warning after this many seconds with a second flash
    self.stopWarning = false
    self.warningTime = 5

    -- Load the sounds
    self.warningBoom = ripple.newSound(game.resourceManager:getResource("boss warning boom"))
    self.warningBoom:tag(game.tags.sfx)
    self.warningSiren = ripple.newSound(game.resourceManager:getResource("boss warning siren"))
    self.warningSiren:tag(game.tags.sfx)

    if game.manager:getOption("enableDebugMode") == true then
        self:spawnBoss()
    end
end

function bossWarning:update(dt)
    local player = game.playerManager.playerReference

    if player then
        player:setInvulnerable()
    end

    if self.currentScaledSprite <= #self.warningQuads and self.stopWarning == false then
        local quad = self.warningQuads[self.currentScaledSprite]
        local sprite = quad.sprite
        quad.scale = math.lerpDT(quad.scale, 1, self.spriteScaleSpeed, dt)
        sprite.scale.x = quad.scale
        sprite.scale.y = quad.scale

        -- If the current letter is scaled to an acceptable amount, then move on to the next letter
        if math.abs(1 - quad.scale) < 0.1 then
            self.currentScaledSprite = self.currentScaledSprite + 1
            sprite.scale.x = 1
            sprite.scale.y = 1
            
            self.warningBoom:play()
            gameHelper:screenShake(0.2)

            if self.currentScaledSprite >= #self.warningQuads then
                self.warningFlash.colour = {1, 1, 1, 1}
            end
        end

    elseif self.stopWarning == false then
        -- Animate the background rectangle
        self.warningBackground.position.y = math.lerp(self.warningBackground.position.y, self.backgroundMaxY, self.backgroundLerpSpeed)
        self.warningBackground.dimensions.y = math.lerp(self.warningBackground.dimensions.y, self.backgroundMaxHeight, self.backgroundLerpSpeed)
    
        -- Animate the caution strips
        for i = 1, #self.cautionSprites do
            local cautionSprite = self.cautionSprites[i]
            local quad = cautionSprite.quad
            local sprite = cautionSprite.sprite
            sprite.scale.x = 1
            sprite.scale.y = 1
            local x, y, w, h = quad:getViewport()
            quad:setViewport(x + 100 * cautionSprite.direction * dt, y, w, h)
        end

        -- Play the warning sound
        self.warningSirenCooldown = self.warningSirenCooldown - (1 * dt)

        if self.warningSirenCooldown <= 0 then
            self.warningSirenCooldown = self.maxWarningSirenCooldown

            self.warningSiren:play()
            gameHelper:screenShake(0.2)

            self.shakeIntensity = self.maxShakeIntensity
        end

        self.shakeIntensity = math.lerpDT(self.shakeIntensity, 0, self.shakeFadeRate, dt)

        -- Fade out the background flash
        self.warningFlash.colour = {1, 1, 1, self.screenFlashAlpha}
        self.screenFlashAlpha = math.lerp(self.screenFlashAlpha, 0, 0.02)

        -- Pulse the letter colours
        self.warningColourSine = self.warningColourSine + self.warningColourFrequency
        
        for i = 1, #self.warningQuads do
            local quad = self.warningQuads[i]
            local sprite = quad.sprite

            local sin = (math.sin(self.warningColourSine + (0.2 * i)) + 1) / 2
            local overrideDrawColour = {}

            overrideDrawColour[1] = math.lerp(1, game.manager.currentPalette.enemyColour[1], sin)
            overrideDrawColour[2] = math.lerp(1, game.manager.currentPalette.enemyColour[2], sin)
            overrideDrawColour[3] = math.lerp(1, game.manager.currentPalette.enemyColour[3], sin)
            overrideDrawColour[4] = 1
    
            sprite.overrideDrawColour = overrideDrawColour

            sprite.position.x = quad.x + math.random(-self.shakeIntensity, self.shakeIntensity)
            sprite.position.y = quad.y + math.random(-self.shakeIntensity, self.shakeIntensity)
        end

        -- After an amount of time, stop the warning, do a second flash and destroy the object
        self.warningTime = self.warningTime - (1 * dt)

        if self.warningTime <= 0 then
            self.stopWarning = true

            self.screenFlashAlpha = 1
            for i = 1, #self.warningQuads do
                self.warningQuads[i].quad:release()
                game.interfaceRenderer:removeHudElement(self.warningQuads[i].sprite)
            end
        
            for i = 1, #self.cautionSprites do
                self.cautionSprites[i].quad:release()
                game.interfaceRenderer:removeHudElement(self.cautionSprites[i].sprite)
            end

            game.interfaceRenderer:removeHudElement(self.warningBackground)
        end
    end

    if self.stopWarning == true then
        self.warningFlash.colour = {1, 1, 1, self.screenFlashAlpha}
        self.screenFlashAlpha = math.lerp(self.screenFlashAlpha, 0, 0.02)

        if self.screenFlashAlpha <= 0.1 then
            self:spawnBoss()
        end
    end
end

function bossWarning:spawnBoss()
    self:destroy()
    game.manager:swapPaletteGroup("boss")
    game.manager:swapPalette()
    gameHelper:addGameObject(self.bossClass.enemyClass(0, 0))
end

function bossWarning:cleanup()
    game.interfaceRenderer:removeHudElement(self.warningFlash)
end

return bossWarning