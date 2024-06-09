local bossIntro = require "src.objects.enemy.boss.boss1.states.bossintro"

local phase1shieldedintro = require "src.objects.enemy.boss.boss1.states.phase1shieldedintro"
local phase1shieldedmovement = require "src.objects.enemy.boss.boss1.states.phase1shieldedmovement"

local phase1unshieldedintro = require "src.objects.enemy.boss.boss1.states.phase1unshieldedintro"
local phase1unshieldedmovement = require "src.objects.enemy.boss.boss1.states.phase1unshieldedmovement"
local phase1unshieldedchargerfirerandom = require "src.objects.enemy.boss.boss1.states.phase1unshieldedchargerfirerandom"
local phase1unshieldedchargerfirerotation = require "src.objects.enemy.boss.boss1.states.phase1unshieldedchargerfirerotation"
local phase1unshieldedchargerfiredirected = require "src.objects.enemy.boss.boss1.states.phase1unshieldedchargerfiredirected"

local phase2shieldedintro = require "src.objects.enemy.boss.boss1.states.phase2shieldedintro"
local phase2shieldedmovement = require "src.objects.enemy.boss.boss1.states.phase2shieldedmovement"
local phase2unshieldedintro = require "src.objects.enemy.boss.boss1.states.phase2unshieldedintro"
local phase2unshieldedmovement = require "src.objects.enemy.boss.boss1.states.phase2unshieldedmovement"
local phase2unshieldedchargerfiredirected = require "src.objects.enemy.boss.boss1.states.phase2unshieldedchargerfiredirected"

local phase3shieldedintro = require "src.objects.enemy.boss.boss1.states.phase3shieldedintro"
local phase3shieldedmovement = require "src.objects.enemy.boss.boss1.states.phase3shieldedmovement"
local phase3unshieldedintro = require "src.objects.enemy.boss.boss1.states.phase3unshieldedintro"
local phase3unshieldedmovement = require "src.objects.enemy.boss.boss1.states.phase3unshieldedmovement"
local phase3unshieldedchargerfiredirected = require "src.objects.enemy.boss.boss1.states.phase3unshieldedchargerfiredirected"

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
                phase1unshieldedchargerfirerandom(),
                phase1unshieldedchargerfirerotation(),
                phase1unshieldedchargerfiredirected(),
            }
        },
    },

    phase2 =
    {
        shielded =
        {
            intro = phase2shieldedintro(),

            movement = phase2shieldedmovement(),
        },
        unshielded =
        {
            intro = phase2unshieldedintro(),

            movement = phase2unshieldedmovement(),

            attacks =
            {
                phase2unshieldedchargerfiredirected(),
            }
        },
    },

    phase3 =
    {
        shielded =
        {
            intro = phase3shieldedintro(),

            movement = phase3shieldedmovement(),
        },
        unshielded =
        {
            intro = phase3unshieldedintro(),

            movement = phase3unshieldedmovement(),

            attacks =
            {
                phase3unshieldedchargerfiredirected(),
            }
        },
    },

}

return states