local worldIndicator = require "src.objects.stagedirector.worldalertobject"
local scoreIndicator = class({name = "Score Indicator", extends = worldIndicator})

function scoreIndicator:new(x, y, score)
    local scoreAdded = gameHelper:addScore(score or 0)
    self:super(x, y, "+"..tostring(scoreAdded), "fontMain")
end

return scoreIndicator