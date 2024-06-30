local bossState = require "src.objects.enemy.boss.bossstate"
local unshieldIntro = class({name = "Unshield Intro", extends = bossState})

function unshieldIntro:enter(bossInstance)
    bossInstance:setFearLevel(self.parameters.fearLevel or 1)
    bossInstance:switchState(self.parameters.returnState)

    local enemyManager = gameHelper:getCurrentState().enemyManager

    if enemyManager then
        enemyManager:destroyAllEnemies({bossInstance})
    end
    
    bossInstance:playSound()
    gameHelper:getCurrentState().stageDirector:setTimerPaused(false)
    game.playerManager:setMultiplierPaused(false)
end

return unshieldIntro