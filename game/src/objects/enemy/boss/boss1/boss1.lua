local boss = require "src.objects.enemy.boss.boss"
local states = require "src.objects.enemy.boss.boss1.statetree"
local bossOrb = require "src.objects.enemy.boss.boss1.boss1orb"

local boss1 = class({name = "Boss 1", extends = boss})

function boss1:new(x, y)
    self.orbs = {}
    self.numberOfOrbs = 0
    self.angle = 0
    
    self.states = states
    self:super(x, y)
end

function boss1:summonOrbs(numberOfOrbs)
    self.numberOfOrbs = numberOfOrbs

    local angleIncrement = 2 * math.pi / numberOfOrbs

    for i = 1, numberOfOrbs do
        local angle = angleIncrement * i
        local newEnemy = bossOrb(0, 0, self, angle)

        gameHelper:addGameObject(newEnemy)
        table.insert(self.orbs, newEnemy)
    end
end

function boss1:handleDamage(damage)
    if damage.type == "bullet" then
        if self.isShielded == false then
            self.phaseHealth = self.phaseHealth - damage.amount
        end
    end
end

function boss1:update(dt)
    boss.update(self, dt)

    for index, orb in ipairs(self.orbs) do
        if orb.markedForDelete then
            table.remove(self.orbs, index)
        end
    end
end

function boss1:damageShieldHealth()
    self.shieldHealth = self.shieldHealth - (100/self.numberOfOrbs)
end

function boss1:draw()
    local radius = 30

    if self.isShielded == false then
        radius = 15
    end

    love.graphics.circle("fill", self.position.x, self.position.y, radius)
end

return boss1