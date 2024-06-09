local bossIntro = require "src.objects.enemy.boss.boss1.states.bossintro"
local phase1shieldedintro = require "src.objects.enemy.boss.boss1.states.phase1shieldedintro"
local phase1shieldedmovement = require "src.objects.enemy.boss.boss1.states.phase1shieldedmovement"

local phase1unshieldedintro = require "src.objects.enemy.boss.boss1.states.phase1unshieldedintro"
local phase1unshieldedmovement = require "src.objects.enemy.boss.boss1.states.phase1unshieldedmovement"
local phase1unshieldedchargerfire = require "src.objects.enemy.boss.boss1.states.phase1unshieldedchargerfire"

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