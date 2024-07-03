local menu = require "src.menu.menu"
local rect = require "src.interface.rect"
local textButton = require "src.interface.textbutton"

local victoryMenu = class({name = "Victory Menu", extends = menu})

function victoryMenu:new()
    self:super()
    
    game.canvases.menuBackgroundCanvas.enabled = true

    self.initialCooldown = 0.25

    self.victorySprite = game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("victory")
    self.victoryOutlineSprite = game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("victoryOutline")
    self.maskShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("maskShader")
    self.backgroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBackgroundShader")
    self.foregroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBoxShader")
    self.infoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontUI")
    self.alertFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontAlert")
    self.scoreBlast = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("scoreBlast")
    self.scoreBlastEnd = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("scoreBlastEnd")
    self.victoryIntro = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("victoryIntro")

    self.scoreBlastEffect = game.particleManager:getEffect("Boss Intro Burst")

    self.victoryScale = 0
    self.victoryScaleRate = 0.03
    self.stencilCircleRadius = 0
    self.maxStencilCircleRadius = 280
    self.stencilCircleRadiusScaleRate = 0.1

    self.victoryShake = vec2(0, 0)
    self.victoryShakeAmount = 5
    self.victoryShakeFade = 0.95

    self.scoreAlpha = 0
    self.infoAlpha = 0

    self.shaderTime = 0
    self.backgroundShaderTime = 0

    self.playerScore = game.manager.runInfo.score
    self.displayScore = 0
    self.displayScoreLerpRate = 0.05

    self.flashAlpha = 0
    self.flashRect = rect(0, 0, 480, 270, "fill", {1, 1, 1, self.flashAlpha})
    self.flashFadeRate = 0.05

    self.maxScoreBlastSoundCooldown = 0.1
    self.scoreBlastSoundCooldown = 0
    self.scoreBlastFinished = false

    self.scoreShake = vec2(0, 0)
    self.scoreDisplayShakeAmount = 5
    self.maxScoreDisplayShakeAmount = 5
    self.scoreShakeFade = 0.95

    self.menus =
    {
        ["main"] = {
            displayMenuName = false,
            elements =
                {
                textButton("retry", "fontUI", 0, 200, 0, 200, function(self)
                    game.transitionManager:doTransition("gameLevelState")
                end, true),

                textButton("quit to menu", "fontUI", 0, 215, 0, 215, function()
                    game.transitionManager:doTransition("menuState")
                end, true),
            }
        }
    }

    self:switchMenu("main")
    self:setElementsEnabled(false)

    game.interfaceRenderer:addHudElement(self.flashRect)

    self.victoryIntro:play()
end

function victoryMenu:update(dt)
    self.initialCooldown = self.initialCooldown - (1 * dt)

    if self.initialCooldown > 0 then
        return
    end

    if game.input:pressed("select") and self.victoryScale < 1 then
        self.victoryScale = 1
        self.stencilCircleRadius = self.maxStencilCircleRadius
    end

    self.victoryScale = math.lerpDT(self.victoryScale, 1, self.victoryScaleRate, dt)
    self.victoryShake.x = math.random(-self.victoryShakeAmount, self.victoryShakeAmount)
    self.victoryShake.y = math.random(-self.victoryShakeAmount, self.victoryShakeAmount)

    if math.abs(self.victoryScale - 1) < 0.2 then
        self.stencilCircleRadius = math.lerpDT(self.stencilCircleRadius, self.maxStencilCircleRadius, self.stencilCircleRadiusScaleRate, dt)
    end

    if math.abs(self.maxStencilCircleRadius - self.stencilCircleRadius) < 5 then
        menu.update(self, dt)
        self.scoreAlpha = math.lerpDT(self.scoreAlpha, 1, 0.1, dt)
        self.displayScore = math.lerpDT(self.displayScore, self.playerScore, self.displayScoreLerpRate, dt)

        if math.abs(self.playerScore - self.displayScore) < 100 then
            self.displayScore = self.playerScore
            self.scoreDisplayShakeAmount = self.scoreDisplayShakeAmount * self.scoreShakeFade
            self.infoAlpha = math.lerpDT(self.infoAlpha, 1, 0.1, dt)
            self:setElementsEnabled(true)

            self.flashRect.colour[4] = self.flashAlpha
            self.flashAlpha = math.lerpDT(self.flashAlpha, 0, self.flashFadeRate, dt)

            if self.scoreBlastFinished == false then
                self.scoreBlastEnd:play()
                self.scoreBlastFinished = true
                self.scoreDisplayShakeAmount = self.maxScoreDisplayShakeAmount * 3
                self.flashAlpha = 1
            end
        else
            self.scoreDisplayShakeAmount = self.maxScoreDisplayShakeAmount

            game.particleManager:burstEffect("Boss Intro Burst", 20, vec2(240 + math.random(-100, 100), math.random(30, 50)))
            self.scoreBlastEffect.systems[1]:setColors(game.manager.currentPalette.uiColour)

            self.scoreBlastSoundCooldown = self.scoreBlastSoundCooldown - (1 * dt)
            
            if self.scoreBlastSoundCooldown <= 0 then
                self.scoreBlastSoundCooldown = self.maxScoreBlastSoundCooldown
                self.scoreBlast:play()
            end
        end

        self.scoreShake.x = math.random(-self.scoreDisplayShakeAmount, self.scoreDisplayShakeAmount)
        self.scoreShake.y = math.random(-self.scoreDisplayShakeAmount, self.scoreDisplayShakeAmount)
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
    self.backgroundShader:send("colour", {bgColour[1] * 0.5, bgColour[2] * 0.5, bgColour[3] * 0.5})
end

function victoryMenu:draw()
    love.graphics.setCanvas({game.canvases.menuBackgroundCanvas.canvas, stencil = true})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.clear()

    love.graphics.setShader(self.backgroundShader)
    love.graphics.rectangle("fill", 0, 0, 480, 270)
    love.graphics.setShader()

    local offsetX, offsetY = self.victorySprite:getDimensions()
    offsetX = offsetX/2
    offsetY = offsetY/2

    local circleX = game.arenaValues.screenWidth/2
    local circleY = game.arenaValues.screenHeight/2
    local victoryX = game.arenaValues.screenWidth/2 + self.victoryShake.x
    local victoryY = game.arenaValues.screenHeight/2 + self.victoryShake.y

    love.graphics.stencil(function()
        love.graphics.setShader(self.maskShader)
        love.graphics.draw(self.victorySprite, victoryX, victoryY, 0, self.victoryScale, self.victoryScale, offsetX, offsetY)
        love.graphics.setShader()

        if self.victoryScale > 0.8 then
            love.graphics.circle("fill", circleX, circleY, self.stencilCircleRadius)
        end
    end, "replace", 1)

    love.graphics.setStencilTest("equal", 0)

    love.graphics.setColor(game.manager.currentPalette.uiColour)
    love.graphics.rectangle("fill", 0, 0, 480, 270)  
    
    if self.victoryScale > 0.8 then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.circle("fill", circleX, circleY, self.stencilCircleRadius + 5)
    end
      
    love.graphics.draw(self.victoryOutlineSprite, victoryX, victoryY, 0, self.victoryScale, self.victoryScale, offsetX, offsetY)

    love.graphics.setStencilTest()

    if math.abs(self.maxStencilCircleRadius - self.stencilCircleRadius) < 10 then
        local timeValues = game.manager.runInfo.time
        local bossTimeValues = game.manager.runInfo.bossTime
        local time = string.format("%02.0f:%02.0f",math.abs(timeValues.minutes),math.abs(math.floor(timeValues.seconds)))
        local bossTime = string.format("%02.0f:%02.0f",math.abs(bossTimeValues.minutes),math.abs(math.floor(bossTimeValues.seconds)))
        local string = ""
        
        string = string.."time: "..time.."\n"
        string = string.."boss time: "..bossTime.."\n"
        string = string.."kills: "..game.manager.runInfo.kills.."\n"
        
        local colour = game.manager.currentPalette.uiColour
        love.graphics.setColor(colour[1], colour[2], colour[3], self.infoAlpha)
        love.graphics.setFont(self.infoFont)
        love.graphics.printf(string, 0, 130, 480, "center")

        love.graphics.setColor(colour[1], colour[2], colour[3], self.scoreAlpha)
        love.graphics.setFont(self.alertFont)
        love.graphics.printf("score:", 0 + self.scoreShake.x, 30 + self.scoreShake.y, 480, "center")
        love.graphics.printf(tostring(math.floor(self.displayScore)), 0 + self.scoreShake.x, 68 + self.scoreShake.y, 480, "center")

        self.scoreBlastEffect:draw()
    end

    love.graphics.setCanvas()
end

function victoryMenu:cleanup()
    menu.cleanup(self)
    game.interfaceRenderer:removeHudElement(self.flashRect)
    game.canvases.menuBackgroundCanvas.enabled = false
end

return victoryMenu