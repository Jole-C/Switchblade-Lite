local exploder = require "src.objects.enemy.exploder"
local denialArea = require "src.objects.enemy.enemydenialarea"

local denier = class({name = "Denier", extends = exploder})

function denier:new(x, y)
    self:super(x, y, "denier")

    self.areaLifetime = 6
    self.fuseRadiusLineWidth = 5
    self.areaRadius = 100
end

function denier:explosion()
    gameHelper:addGameObject(denialArea(self.position.x, self.position.y, self.areaRadius, self.areaLifetime))
end

return denier