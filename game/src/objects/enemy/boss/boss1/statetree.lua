local bossIntro = require "src.objects.enemy.boss.boss1.states.bossintro"

local shieldIntro = require "src.objects.enemy.boss.boss1.states.shieldintro"
local shieldMovement = require "src.objects.enemy.boss.boss1.states.shieldmovement"
local shieldOutro = require "src.objects.enemy.boss.boss1.states.shieldoutro"

local unshieldIntro = require "src.objects.enemy.boss.boss1.states.unshieldintro"
local unshieldMovement = require "src.objects.enemy.boss.boss1.states.unshieldmovement"

local death = require "src.objects.enemy.boss.boss1.states.death"

local circleFire = require "src.objects.enemy.boss.boss1.states.circlefire"
local directedFire = require "src.objects.enemy.boss.boss1.states.directedfire"
local randomFire = require "src.objects.enemy.boss.boss1.states.randomfire"
local rotationFire = require "src.objects.enemy.boss.boss1.states.rotationfire"
local laserFire = require "src.objects.enemy.boss.boss1.states.laserfire"

local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"
local bullet = require "src.objects.enemy.enemybullet"
local enemyIndicator = require "src.objects.enemy.enemyindicator"

local spawnCharger = function(angle, x, y)
    local enemy = charger(x, y)
    enemy.angle = angle
    enemy.targetPlayer = false

    local indicator = enemyIndicator(x, y, enemy)
    gameHelper:addGameObject(indicator)
    
    return enemy
end

local spawnSticker = function(angle, x, y)
    local enemy = sticker(x, y)
    enemy.angle = angle
    enemy.startingSpeed = math.random(150, 300)
    enemy.restoreAmmo = false

    if math.random(0, 100) < 15 then
        enemy.restoreAmmo = true

        local indicator = enemyIndicator(x, y, enemy)
        gameHelper:addGameObject(indicator)
    end
    
    return enemy
end

local spawnBulletAndCharger = function(angle, x, y)
    local enemy = nil

    if math.random(0, 100) > 10 then
        enemy = bullet(x, y, 150, angle, 1, colliderDefinitions.enemybullet, 16, 16)
    else 
        enemy = spawnCharger(angle, x, y)
    end

    return enemy
end

local spawnBulletOnly = function(angle, x, y)
    local enemy = bullet(x, y, 150, angle, 1, colliderDefinitions.enemybullet, 16, 16)
    return enemy
end

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
                    attackList =
                    {
                        circleFire(
                        {
                            isBulletAttack = true,
                            numberOfEnemiesInCircle = 8,
                            timesToRepeat = 5,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            isBulletAttack = true,
                            angleTurnSpeed = 6,
                            maxFireCooldown = 0.05,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        1,
                        1
                    }
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
                fearLevel = 1,
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    attackList =
                    {
                        randomFire(
                        {
                            enemiesToFire = 8,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnCharger,
                            },
                            returnState = "movement"
                        }),
                        directedFire(
                        {
                            isBulletAttack = true,
                            enemiesToFire = 25,
                            maxFireCooldown = 0.1,
                            enemyFunctions =
                            {
                                spawnBulletAndCharger,
                            },
                            returnState = "movement"
                        }),
                        randomFire(
                        {
                            enemiesToFire = 15,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            isBulletAttack = true,
                            angleTurnSpeed = 3,
                            maxFireCooldown = 0.07,
                            enemyFunctions =
                            {
                                spawnBulletAndCharger,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        3,
                        4,
                        3,
                        2,
                    }
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
                    attackList =
                    {

                        circleFire(
                        {
                            isBulletAttack = true,
                            numberOfEnemiesInCircle = 12,
                            timesToRepeat = 3,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            isBulletAttack = true,
                            angleTurnSpeed = 5,
                            maxFireCooldown = 0.05,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        1,
                        1
                    }
                },
                
                returnState = "outro"
            }),

            outro = shieldOutro(
            {
                numberOfExplosions = 12,
                timeBetweenExplosions = 0.17,
                maxExplosionDistanceOffset = 50,
                returnState = "intro"
            })
        },

        unshielded =
        {
            intro = unshieldIntro(
            {
                fearLevel = 2,
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    attackList =
                    {
                        randomFire(
                        {
                            enemiesToFire = 8,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnCharger,
                            },
                            returnState = "movement"
                        }),
                        laserFire(
                        {
                            angleTurnRate = 0.025,
                            laserWindupTime = 0.025,
                            returnState = "movement"
                        }),
                        directedFire(
                        {
                            enemiesToFire = 15,
                            maxFireCooldown = 0.15,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        circleFire(
                        {
                            isBulletAttack = true,
                            numberOfEnemiesInCircle = 12,
                            timesToRepeat = 5,
                            enemyFunctions =
                            {
                                spawnBulletAndCharger,
                            },
                            returnState = "movement"
                        }),
                        circleFire(
                        {
                            numberOfEnemiesInCircle = 8,
                            timesToRepeat = 3,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        randomFire(
                        {
                            isBulletAttack = true,
                            enemiesToFire = 15,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnBulletAndCharger,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            angleTurnSpeed = 2,
                            maxFireCooldown = 0.1,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        4,
                        4,
                        4,
                        3,
                        3,
                        2,
                        2,
                    }
                },

                attackCooldown = 2,

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
                    attackList =
                    {

                        circleFire(
                        {
                            isBulletAttack = true,
                            numberOfEnemiesInCircle = 16,
                            timesToRepeat = 3,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            isBulletAttack = true,
                            angleTurnSpeed = 3,
                            maxFireCooldown = 0.05,
                            enemyFunctions =
                            {
                                spawnBulletOnly,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        1,
                        1
                    }
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
                fearLevel = 3,
                returnState = "movement"
            }),

            movement = unshieldMovement(
            {
                attacks =
                {
                    attackList =
                    {
                        randomFire(
                        {
                            enemiesToFire = 8,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnCharger,
                            },
                            returnState = "movement"
                        }),
                        laserFire(
                        {
                            angleTurnRate = 0.025,
                            laserWindupTime = 0.025,
                            returnState = "movement"
                        }),
                        circleFire(
                        {
                            isBulletAttack = true,
                            numberOfEnemiesInCircle = 12,
                            timesToRepeat = 5,
                            enemyFunctions =
                            {
                                spawnBulletAndCharger,
                            },
                            returnState = "movement"
                        }),
                        circleFire(
                        {
                            numberOfEnemiesInCircle = 12,
                            timesToRepeat = 5,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        directedFire(
                        {
                            enemiesToFire = 35,
                            maxFireCooldown = 0.15,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        randomFire(
                        {
                            enemiesToFire = 15,
                            maxAngle = 55,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                        rotationFire(
                        {
                            angleTurnSpeed = 2,
                            maxFireCooldown = 0.1,
                            enemyFunctions =
                            {
                                spawnSticker,
                            },
                            returnState = "movement"
                        }),
                    },
                    attackWeights =
                    {
                        4,
                        4,
                        4,
                        3,
                        3,
                        2,
                        1,
                    }
                },
            }),

            attackCooldown = 1.4,

            death = death()
        }
    },
}

return states