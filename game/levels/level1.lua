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

            radius = 200
        },
        ["leftCircle"] = {
            position = {
                x = -200, 
                y = 0
            },

            radius = 150
        },
        ["rightCircle"] = {
            position = {
                x = 200, 
                y = 0
            },

            radius = 150
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
            },

            --[[
            segmentChanges =
            {
                {
                    changeType = "size", --size, position, reset
                    arenaSegment = "mainCircle",
                    newValue = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "position", --size, position, reset
                    arenaSegment = "leftCircle",
                    newValue = vec2(0, 0),
                    lerpSpeed = 0.015
                },
            }]]

            minimumKillsForNextWave = 3
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
            },

            minimumKillsForNextWave = 4
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
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newValue = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newValue = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newValue = 100,
                    lerpSpeed = 0.015
                },
            },

            minimumKillsForNextWave = 3
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
            },
            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newValue = 70,
                    lerpSpeed = 0.
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newValue = 70,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newValue = 150,
                    lerpSpeed = 0.015
                },

                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newValue = vec2(400, 0),
                    lerpSpeed = 0.05
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newValue = vec2(-400, 0),
                    lerpSpeed = 0.05
                }
            },

            minimumKillsForNextWave = 3
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

            segmentChanges = {
                {
                    changeType = "reset",
                    arenaSegment = "rightCircle",
                    newValue = 0,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "leftCircle",
                    newValue = 0,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "mainCircle",
                    newValue = 0,
                    lerpSpeed = 0.015
                },
            },

            minimumKillsForNextWave = 2,
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

            minimumKillsForNextWave = 4,
        },
    }
}

return levelDefinition