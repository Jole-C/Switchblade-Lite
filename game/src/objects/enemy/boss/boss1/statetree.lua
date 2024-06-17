local bossIntro = require "src.objects.enemy.boss.boss1.states.bossintro"

local shieldIntro = require "src.objects.enemy.boss.boss1.states.shieldintro"
local shieldMovement = require "src.objects.enemy.boss.boss1.states.shieldmovement"
local shieldOutro = require "src.objects.enemy.boss.boss1.states.shieldoutro"

local unshieldIntro = require "src.objects.enemy.boss.boss1.states.unshieldintro"
local unshieldMovement = require "src.objects.enemy.boss.boss1.states.unshieldmovement"

local death = require "src.objects.enemy.boss.boss1.states.death"

local circularChargerFire = require "src.objects.enemy.boss.boss1.states.circularchargerfire"
local directedFire = require "src.objects.enemy.boss.boss1.states.directedfire"
local randomFire = require "src.objects.enemy.boss.boss1.states.randomfire"
local rotationFire = require "src.objects.enemy.boss.boss1.states.rotationfire"
local laserFire = require "src.objects.enemy.boss.boss1.states.laserfire"

local states =
{
    intro = bossIntro(
    {
        phase = "phase1",
        returnState = "intro"
    }),

    phase1 = 
    {
        shielded = 
        {
            intro = shieldIntro(
            {
                orbsToSummon = 3,
                returnState = "movement"
            }),
    
            movement = shieldMovement(
            {
                attacks = 
                {
                    circularChargerFire(
                    {
                        numberOfEnemies = 3,
                        timesToRepeat = 3,
                        returnState = "movement"
                    })
                },
                
                returnState = "outro"
            }),

            outro = shieldOutro(
            {
                numberOfExplosions = 7,
                timeBetweenExplosions = 0.25,
                maxExplosionDistanceOffset = 50,
                returnState = "intro"
            })
        },

        unshielded =
        {
            intro = unshieldIntro(
            {
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    directedFire(
                    {
                        enemiesToFire = 5,
                        returnState = "movement"
                    }),
                    randomFire(
                    {
                        enemiesToFire = 7,
                        maxAngle = 45,
                        returnState = "movement"
                    }),
                    rotationFire(
                    {
                        angleTurnSpeed = 3,
                        maxFireCooldown = 0.25,
                        returnState = "movement"
                    }),
                },

                returnState = 
                {
                    phase = "phase2",
                    state = "intro"
                }
            })
        }
    },

    phase2 = 
    {
        shielded = 
        {
            intro = shieldIntro(
            {
                orbsToSummon = 4,
                returnState = "movement"
            }),
    
            movement = shieldMovement(
            {
                attacks = 
                {
                    circularChargerFire(
                    {
                        numberOfEnemies = 6,
                        timesToRepeat = 3,
                        returnState = "movement"
                    })
                },
                
                returnState = "outro"
            }),

            outro = shieldOutro(
            {
                numberOfExplosions = 12,
                timeBetweenExplosions = 0.1,
                maxExplosionDistanceOffset = 50,
                returnState = "intro"
            })
        },

        unshielded =
        {
            intro = unshieldIntro(
            {
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    directedFire(
                    {
                        enemiesToFire = 10,
                        maxFireCooldown = 0.25,
                        returnState = "movement"
                    }),
                    randomFire(
                    {
                        enemiesToFire = 12,
                        maxAngle = 30,
                        returnState = "movement"
                    }),
                    rotationFire(
                    {
                        angleTurnSpeed = 2,
                        maxFireCooldown = 0.2,
                        returnState = "movement"
                    }),
                    laserFire(
                    {
                        angleTurnRate = 0.025,
                        laserWindupTime = 0.025,
                        returnState = "movement"
                    }),
                },

                returnState = 
                {
                    phase = "phase3",
                    state = "intro"
                }
            })
        }
    },

    phase3 = 
    {
        shielded = 
        {
            intro = shieldIntro(
            {
                orbsToSummon = 5,
                returnState = "movement"
            }),
    
            movement = shieldMovement(
            {
                attacks = 
                {
                    circularChargerFire(
                    {
                        numberOfEnemies = 9,
                        timesToRepeat = 2,
                        returnState = "movement"
                    })
                },
                
                returnState = "outro"
            }),

            outro = shieldOutro(
            {
                numberOfExplosions = 16,
                timeBetweenExplosions = 0.1,
                maxExplosionDistanceOffset = 50,
                returnState = "intro"
            })
        },

        unshielded =
        {
            intro = unshieldIntro(
            {
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    directedFire(
                    {
                        enemiesToFire = 15,
                        maxFireCooldown = 0.35,
                        returnState = "movement"
                    }),
                    randomFire(
                    {
                        enemiesToFire = 15,
                        maxAngle = 45,
                        returnState = "movement"
                    }),
                    rotationFire(
                    {
                        angleTurnSpeed = 3,
                        maxFireCooldown = 0.15,
                        returnState = "movement"
                    }),
                },
            }),

            death = death()
        }
    },
}

return states