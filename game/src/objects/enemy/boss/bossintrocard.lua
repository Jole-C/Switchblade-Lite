local hudElement = require "src.interface.hudelement"
local bossIntroCard = class({name = "Boss Intro Card", extends = hudElement})

function bossIntroCard:new(name, subtitle)
    self:super()
    
    self.name = name
    self.subtitle = subtitle
    self.textLerpSpeed = 0.1
    self.textTargetY = 230

    self.inIntro = false
    self.inOutro = false

    self.textY = 270
end

function bossIntroCard:update(dt)
    if self.inIntro == true then
        self.textY = math.lerpDT(self.textY, self.textTargetY, self.textLerpSpeed, dt)

        if math.abs(self.textY - self.textTargetY) < 2 then
            self.inIntro = false
        end
    end

    if self.inOutro == true then
        self.textY = math.lerpDT(self.textY, 270, self.textLerpSpeed, dt)
    end
end

function bossIntroCard:setInIntro()
    self.inIntro = true
    self.inOutro = false
end

function bossIntroCard:setInOutro()
    self.inIntro = false
    self.inOutro = true
end

function bossIntroCard:draw()
    love.graphics.setColor(game.manager.currentPalette.uiColour)
    love.graphics.printf(self.name.."\n"..self.subtitle, 240 - 300/2, self.textY, 300, "center")
end

return bossIntroCard