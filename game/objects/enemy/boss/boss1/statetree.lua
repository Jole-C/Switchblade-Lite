local bossIntro = require "game.objects.enemy.boss.boss1.states.bossintro"
local phase1shieldedintro = require "game.objects.enemy.boss.boss1.states.phase1shieldedintro"
local phase1shieldedmovement = require "game.objects.enemy.boss.boss1.states.phase1shieldedmovement"

local phase1unshieldedintro = require "game.objects.enemy.boss.boss1.states.phase1unshieldedintro"
local phase1unshieldedmovement = require "game.objects.enemy.boss.boss1.states.phase1unshieldedmovement"
local phase1unshieldedchargerfire = require "game.objects.enemy.boss.boss1.states.phase1unshieldedchargerfire"

local states =
{
    bossIntro = bossIntro(),

    phase1 =
    {
        shielded =
        {
            intro = phase1shieldedintro(),

            movement = phase1shieldedmovement(),
        },
        unshielded =
        {
            intro = phase1unshieldedintro(),

            movement = phase1unshieldedmovement(),

            attacks =
            {
                phase1unshieldedchargerfire()
            }
        },
    },

    phase2 =
    {

    },

    phase3 =
    {

    }
}

return states