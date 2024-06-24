local hudElement = require "src.interface.hudelement"
local logoParticle = require "src.menu.mainmenu.logoparticle"

local logo = class({name = "logo", extends = hudElement})

function logo:new()
    self.logoSpriteSwitch = game.resourceManager:getResource("logo text switch")
    self.logoSpriteBlade = game.resourceManager:getResource("logo text blade")
    self.shipSprite = game.resourceManager:getResource("logo ship")

    self.inShipIntro = true

    self.startingShipX = -80
    self.shipX = self.startingShipX

    self.maxParticleCooldown = 0.3
    self.particleCooldown = self.maxParticleCooldown

    self.aboveParticles = {}
    self.belowParticles = {}
end

function logo:update(dt)
    if self.inShipIntro then
        self.shipX = math.lerpDT(self.shipX, 530, 0.05, dt)

        if 530 - self.shipX <= 3 then
            self.inShipIntro = false
            self.shipX = self.startingShipX
        end

        if self.shipX < 480 then
            self:addParticles(self.aboveParticles)
        end
    else
        self.shipX = math.lerpDT(self.shipX, 350, 0.05, dt)
        self:addParticles(self.belowParticles)
    end

    self:updateParticles(self.aboveParticles, dt)
    self:updateParticles(self.belowParticles, dt)
end

function logo:draw()
    self:drawParticles(self.belowParticles)

    love.graphics.setColor(1, 1, 1, 1)

    if self.inShipIntro then
        love.graphics.setScissor(0, 0, math.abs(self.shipX), 270)
    else
        love.graphics.setColor(game.manager.currentPalette.playerColour)
        love.graphics.draw(self.shipSprite, self.shipX, 116)
    end

    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.draw(self.logoSpriteSwitch, 99, 117)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.logoSpriteBlade, 99, 117)
    love.graphics.setScissor()

    if self.inShipIntro then
        love.graphics.setColor(game.manager.currentPalette.playerColour)
        love.graphics.draw(self.shipSprite, self.shipX, 116)
    end

    self:drawParticles(self.aboveParticles)
end

function logo:addParticles(particleTable)
    table.insert(particleTable, logoParticle(self.shipX + 30, 135, math.rad(math.random(170, 190)), math.random(230, 300), math.random(5, 15)))
    table.insert(particleTable, logoParticle(self.shipX + 30, 135, math.rad(math.random(170, 190)), math.random(230, 300), math.random(5, 15)))
end

function logo:updateParticles(particlesTable, dt)
    for i = #particlesTable, 1, -1 do
        local particle = particlesTable[i]

        if particle then
            particle:update(dt)

            if particle.markedForDelete then
                table.remove(particlesTable, i)
            end
        end
    end
end

function logo:drawParticles(particlesTable)
    for _, particle in pairs(particlesTable) do
        if particle then
            particle:draw()
        end
    end
end

return logo