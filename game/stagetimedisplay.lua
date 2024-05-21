local hudElement = require "game.interface.hudelement"

local stageTimeHud = class{
    __includes = hudElement,

    timeSeconds = 0,
    timeMinutes = 0,

    init = function(self)
    end,

    update = function(self)
    end,

    draw = function(self)
        local font = resourceManager:getResource("font main")
        local timeString = string.format("%02.0f:%02.0f",self.timeMinutes,self.timeSeconds)
        local textWidth = font:getWidth(timeString)
        love.graphics.setFont(font)
        love.graphics.print(timeString, screenWidth/2 - textWidth/2, 0)
    end
}

return stageTimeHud