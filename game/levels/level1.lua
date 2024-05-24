local wanderer = require "game.objects.enemy.arena1.wanderer"
local charger = require "game.objects.enemy.arena1.charger"
local drone = require "game.objects.enemy.arena1.drone"
local utility = require "game.objects.enemy.arena1.charger"
local specialist = require "game.objects.enemy.arena1.charger"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer sprite"},
        ["charger"] = {enemyClass = charger, spriteName = "charger sprite"},
        ["drone"] = {enemyClass = drone, spriteName = "drone sprite"},
        ["utility"] = utility,
        ["specialist"] = specialist,
    },
    
    arenaSegmentDefinitions =
    {
        ["mainCircle"] = {
            position = {
                x = 0, 
                y = 0
            },

            radius = 150
        },
        ["leftCircle"] = {
            position = {
                x = -150, 
                y = 0
            },

            radius = 100
        },
        ["rightCircle"] = {
            position = {
                x = 150, 
                y = 0
            },

            radius = 100
        },
    },

    playerStartSegment = "mainCircle",

    level =
    {
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = -100, y = 0},
                            {x = 100, y = 0}
                        }
                    }
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 64,
                        origin = "mainCircle"
                    }
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 64,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 64,
                        origin = "rightCircle"
                    }
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 40,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 40,
                        origin = "rightCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 80,
                        origin = "mainCircle"
                    }
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "drone",
                        spawnCount = 2,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = -100, y = 0},
                            {x = 100, y = 0}
                        }
                    }
                }
            },
            minimumEnemiesForNextWave = 0,
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    waveType = "randomWithinShape",
    
                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 6,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 30,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "randomWithinShape",
    
                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 6,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 30,
                        origin = "rightCircle"
                    }
                }
            },
        },
    }
}

return levelDefinition