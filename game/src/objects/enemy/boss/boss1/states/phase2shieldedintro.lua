local bossState = require "src.objects.enemy.boss.bossstate"
local drone = require "src.objects.enemy.arena1.drone"

local phase2ShieldedIntro = class({name = "Boss 1 Phase 2 Shield Intro", extends = bossState})

function phase2ShieldedIntro:enter(bossInstance)
    gameHelper:getCurrentState().enemyManager:destroyAllEnemies()
    
    self.lerpSpeed = 0.05
    self.lerpRadius = 5
end

function phase2ShieldedIntro:update(dt, bossInstance)
    bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.lerpSpeed, dt)
    bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.lerpSpeed, dt)

    if (bossInstance.position - vec2:zero()):length() < self.lerpRadius then
        bossInstance:setShielded(true)
        bossInstance:summonOrbs(5)
        bossInstance:switchState(bossInstance.states.phase2.shielded.movement) 

        for i = 1, 3 do
            local newEnemy = drone(0, 0)
            gameHelper:addGameObject(newEnemy)
        end
    end
end

return phase2ShieldedIntro