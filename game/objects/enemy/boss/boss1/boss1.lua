local boss = require "game.objects.enemy.boss.boss"
local states = require "game.objects.enemy.boss.boss1.statetree"
local bossOrb = require "game.objects.enemy.boss.boss1.boss1orb"

local boss1 = class({name = "Boss 1", extends = boss})

function boss1:new(x, y)
    self.orbs = {}
    
    self.states = states
    self:super(x, y)
end

function boss1:summonOrbs(numberOfOrbs)
    local angleIncrement = 2 * math.pi / numberOfOrbs

    for i = 1, numberOfOrbs do
        local angle = angleIncrement * i
        local newEnemy = bossOrb(0, 0, self, angle)

        gameHelper:addGameObject(newEnemy)
        table.insert(self.orbs, newEnemy)
    end
end

function boss1:update(dt)
    boss.update(self, dt)

    -- Remove the orbs from the table if destroyed. Used by shielded states to know when to transition to unshielded
    for i = #self.orbs, 1, -1 do
        local orb = self.orbs[i]

        if orb.markedForDelete then
            table.remove(self.orbs, i)
        end
    end
end

function boss1:draw()
    local radius = 30

    if self.isShielded == false then
        radius = 15
    end

    love.graphics.circle("fill", self.position.x, self.position.y, radius)
end

return boss1