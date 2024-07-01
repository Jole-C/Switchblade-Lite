local exploder = require "src.objects.enemy.exploder"
local denialArea = require "src.objects.enemy.enemydenialarea"

local denier = class({name = "Denier", extends = exploder})

function denier:new(x, y)
    self:super(x, y)

    self.areaLifetime = 6
end

function denier:explosion()
    local arena = gameHelper:getArena()

    if arena then
        local segment = arena:getSegmentPointIsWithin(self.position)

        if segment then
            gameHelper:addGameObject(denialArea(segment.position.x, segment.position.y, segment.radius, self.areaLifetime))
        end
    end
end

return denier