local menu = require "src.menu.menu"
local rect = require "src.interface.rect"
local textButton = require "src.interface.textbutton"

local gameoverMenu = class({name = "Gameover Menu", extends = menu})

function gameoverMenu:new()
    self:super()

    game.canvases.menuBackgroundCanvas.enabled = true

    self.initialCooldown = 0.25

    self.gameoverSprite = game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gameover")
    self.gameoverOutlineSprite = game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gameoverOutline")
    self.maskShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("maskShader")
    self.backgroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBackgroundShader")
    self.foregroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBoxShader")
    self.spriteQuad = love.graphics.newQuad(0, 0, 0, self.gameoverSprite:getHeight(), self.gameoverSprite:getWidth(), self.gameoverSprite:getHeight())
    self.letterSound = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sounds"):get("fire")
    self.finalSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("gameoverBlam")
    self.infoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontUI")
    self.tipFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
    self.gameoverSong = game.musicManager:getTrack("gameoverMusic")
    
    self.quadIncrementAmount = 60
    self.quadIncrements = 0
    self.maxQuadIncrements = 8
    self.maxQuadIncrementCooldown = 0.15
    self.quadIncrementCooldown = self.maxQuadIncrementCooldown

    self.letterShake = vec2(0, 0)
    self.maxLetterShakeAmount = 5
    self.letterShakeAmount = 0
    self.letterShakeFade = 0.1

    self.flashAlpha = 0
    self.flashRect = rect(0, 0, 480, 270, "fill", {1, 1, 1, self.flashAlpha})
    self.flashFadeRate = 0.05

    self.textAlpha = 0
    self.textFadeRate = 0.1

    self.shaderTime = 0
    self.backgroundShaderTime = 0

    self.tips = 
    {
        "Boosting makes you completely invulnerable to all damage!",
        "Boosting builds your temperature, boost for too long and you'll overheat!",
        "Boosting into consecutive enemies creates an explosion damaging all\nenemies inside!",
        "Boosting into consecutive enemies reduces temperature for each enemy!",
        "Your health won't recharge while boosting or overheating, manage it well!",
        "Bosses only take damage from bullets!",
        "Only some enemies spawned by bosses drop ammo! They have a visual indicator."
    }

    self.tip = self.tips[math.random(1, #self.tips)]

    self.menus =
    {
        ["main"] = {
            displayMenuName = false,
            elements =
                {
                textButton("retry", "fontUI", 0, 200, 0, 200, function()
                    game.transitionManager:doTransition("gameLevelState")
                end, true),

                textButton("quit to menu", "fontUI", 0, 215, 0, 215, function()
                    game.transitionManager:doTransition("menuState")
                end, true),
            }
        }
    }

    self:switchMenu("main")

    game.interfaceRenderer:addHudElement(self.flashRect)
end

function gameoverMenu:update(dt)
    self.initialCooldown = self.initialCooldown - (1 * dt)

    if self.initialCooldown > 0 then
        return
    end

    if game.input:pressed("select") and self.quadIncrements < 8 then
        self.quadIncrements = 9
        self:updateQuad()
    end

    local shaderSpeed = game.manager:getOption("speedPercentage") / 100
    self.shaderTime = self.shaderTime + (0.1 * shaderSpeed) * dt
    self.backgroundShaderTime = self.backgroundShaderTime + (0.5 * shaderSpeed) * dt

    local angle = 2
    local warpScale = 0.1 + math.sin(self.shaderTime) * 0.3
    local warpTiling = 0.3 + math.sin(self.shaderTime) * 0.5
    local tiling = 2.0

    local resolution = {game.arenaValues.screenWidth, game.arenaValues.screenHeight}

    self.foregroundShader:send("angle", angle)
    self.foregroundShader:send("warpScale", warpScale)
    self.foregroundShader:send("warpTiling", warpTiling)
    self.foregroundShader:send("tiling", tiling)
    self.foregroundShader:send("resolution", resolution)
    self.foregroundShader:send("position", {0, 0})
    
    self.backgroundShader:send("resolution", resolution)
    self.backgroundShader:send("time", self.backgroundShaderTime)

    local bgColour = game.manager.currentPalette.backgroundColour[1]
    self.backgroundShader:send("colour", {bgColour[1], bgColour[2], bgColour[3]})

    self.letterShakeAmount = math.lerpDT(self.letterShakeAmount, 0, self.letterShakeFade, dt)
    self.letterShake.x = math.random(-self.letterShakeAmount, self.letterShakeAmount)
    self.letterShake.y = math.random(-self.letterShakeAmount, self.letterShakeAmount)

    self.flashRect.colour[4] = self.flashAlpha
    self.flashAlpha = math.lerpDT(self.flashAlpha, 0, self.flashFadeRate, dt)

    if self.quadIncrements >= 8 then
        self.textAlpha = math.lerpDT(self.textAlpha, 1, self.textFadeRate, dt)
        menu.update(self, dt)

        return
    end

    self.quadIncrementCooldown = self.quadIncrementCooldown - (1 * dt)

    if self.quadIncrementCooldown <= 0 then
        self.quadIncrementCooldown = self.maxQuadIncrementCooldown
        self.letterShakeAmount = self.maxLetterShakeAmount

        self.quadIncrements = self.quadIncrements + 1

        self:updateQuad()

        if self.quadIncrements < 8 then
            self.letterSound:play()
        end
    end
end

function gameoverMenu:draw()
    love.graphics.setCanvas({game.canvases.menuBackgroundCanvas.canvas, stencil = true})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.clear()

    if self.quadIncrements >= 8 then
        love.graphics.setShader(self.backgroundShader)
        love.graphics.rectangle("fill", 0, 0, 480, 270)
        love.graphics.setShader()
    else
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, 480, 270)
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.stencil(function()
        love.graphics.setShader(self.maskShader)
        love.graphics.draw(self.gameoverSprite, self.spriteQuad, 0 + self.letterShake.x, 32 + self.letterShake.y)
        love.graphics.setShader()
    end, "replace", 1)

    love.graphics.draw(self.gameoverOutlineSprite, self.spriteQuad, 0 + self.letterShake.x, 32 + self.letterShake.y)

    love.graphics.setStencilTest("equal", 0)

    if self.quadIncrements >= 8 then
        love.graphics.setShader(self.foregroundShader)
        love.graphics.rectangle("fill", 0, 0, 480, 270)
        love.graphics.setShader()
    else
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, 480, 270)
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setStencilTest()

    if self.quadIncrements >= 8 then
        local timeValues = game.manager.runInfo.time
        local time = string.format("%02.0f:%02.0f",math.abs(timeValues.minutes),math.abs(math.floor(timeValues.seconds)))
        local string = ""
        
        string = string..game.manager.runInfo.deathReason.."\n"
        string = string.."time: "..time.."\n"
        string = string.."score: "..game.manager.runInfo.score.."\n"
        string = string.."kills: "..game.manager.runInfo.kills.."\n"
        
        local colour = game.manager.currentPalette.uiColour
        love.graphics.setColor(colour[1], colour[2], colour[3], self.textAlpha)
        love.graphics.setFont(self.infoFont)
        love.graphics.printf(string, 0, 120, 480, "center")

        love.graphics.setFont(self.tipFont)
        love.graphics.printf(self.tip, 0, 250, 480, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setCanvas()
end

function gameoverMenu:updateQuad()        
    local x, y, w, h = self.spriteQuad:getViewport()
    self.spriteQuad:setViewport(x, y, self.quadIncrementAmount * self.quadIncrements, h)

    if self.quadIncrements >= 8 then
        self.flashAlpha = 1
        self.finalSound:play()
        self.gameoverSong:start()
    end
end

function gameoverMenu:cleanup()
    menu.cleanup(self)

    self.spriteQuad:release()
    game.canvases.menuBackgroundCanvas.enabled = false

    game.interfaceRenderer:removeHudElement(self.flashRect)
end

return gameoverMenu