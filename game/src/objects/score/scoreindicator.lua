local worldIndicator = require "src.objects.stagedirector.worldalertobject"
local scoreIndicator = class({name = "Score Indicator", extends = worldIndicator})

function scoreIndicator:new(x, y, score, multiplier)
    self:super(x, y, tostring(score or 0).."*"..tostring(multiplier or 0))
    gameHelper:addScore(score, multiplier)
end

return scoreIndicator