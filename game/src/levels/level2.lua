local wanderer = require "src.objects.enemy.wanderer"
local drone = require "src.objects.enemy.drone"
local shielder = require "src.objects.enemy.shielder"
local exploder = require "src.objects.enemy.exploder"
local hider = require "src.objects.enemy.hider"
local orbiter = require "src.objects.enemy.orbiter"
local boss = require "src.objects.enemy.boss.boss1.boss1"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer"},
        ["drone"] = {enemyClass = drone, spriteName = "drone"},
        ["shielder"] = {enemyClass = shielder, overrideSprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("warningSprite")},
        ["exploder"] = {enemyClass = exploder, spriteName = "wanderer"},
        ["hider"] = {enemyClass = hider, spriteName = "wanderer"},
        ["orbiter"] = {enemyClass = orbiter, spriteName = "wanderer"},
        ["boss"] = {enemyClass = boss}
    },
    
    arenaSegmentDefinitions =
    {
        {
            name = "mainCircle",
            position = {
                x = 0, 
                y = 0
            },
            radius = 50
        },
        {
            name = "upperCircle",
            position = vec2:polar(62, math.rad(90)),
            radius = 175
        },
        {
            name = "lowerLeftCircle",
            position = vec2:polar(62, math.rad(225)),
            radius = 175
        },
        {
            name = "lowerRightCircle",
            position = vec2:polar(62, math.rad(315)),
            radius = 175
        },
    },

    playerStartSegment = "mainCircle",

    level = 
    {
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "mainCircle"
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 5
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 10
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 70,
                        origin = "mainCircle"
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 10
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 15
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 80,
                        origin = "upperCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 80,
                        origin = "lowerLeftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 80,
                        origin = "lowerRightCircle"
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 9
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },

            segmentChanges = {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "position",
                    arenaSegment = "upperCircle",
                    newPosition = vec2:polar(170, math.rad(90)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerLeftCircle",
                    newPosition = vec2:polar(170, math.rad(225)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerRightCircle",
                    newPosition = vec2:polar(170, math.rad(315)),
                    lerpSpeed = 0.05,
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 12
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 15
                }
            },

            segmentChanges = {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "position",
                    arenaSegment = "upperCircle",
                    newPosition = vec2:polar(250, math.rad(90)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerLeftCircle",
                    newPosition = vec2:polar(250, math.rad(225)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerRightCircle",
                    newPosition = vec2:polar(250, math.rad(315)),
                    lerpSpeed = 0.05,
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "upperCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "lowerLeftCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "lowerRightCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 9
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "upperCircle"
                    }
                },
                
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "lowerLeftCircle"
                    }
                },
                
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "lowerRightCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                        spawnCount = 2,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 2,
                        radius = 70,
                        origin = "mainCircle"
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 14
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "upperCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerLeftCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerRightCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },
            }
        },

        {
            spawnDefinitions = 
            {

                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "upperCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },

                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "lowerLeftCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },

                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "lowerRightCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "shielder",
                        spawnCount = 2,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 2,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 5
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },

            segmentChanges =
            {
                {
                    changeType = "position",
                    arenaSegment = "upperCircle",
                    newPosition = vec2:polar(140, math.rad(90)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerLeftCircle",
                    newPosition = vec2:polar(140, math.rad(225)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerRightCircle",
                    newPosition = vec2:polar(140, math.rad(315)),
                    lerpSpeed = 0.05,
                }
            }
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "upperCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "lowerLeftCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "lowerRightCircle"
                    }
                },

                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 16
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 150,
                        origin = "upperCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "lowerLeftCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "lowerRightCircle"
                    }
                },

                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },

                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "hider",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 6
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },

            segmentChanges =
            {
                {
                    changeType = "position",
                    arenaSegment = "upperCircle",
                    newPosition = vec2:polar(370, math.rad(90)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerLeftCircle",
                    newPosition = vec2:polar(370, math.rad(225)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerRightCircle",
                    newPosition = vec2:polar(370, math.rad(315)),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "size",
                    arenaSegment = "upperCircle",
                    newRadius = 140,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerLeftCircle",
                    newRadius = 140,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerRightCircle",
                    newRadius = 140,
                    lerpSpeed = 0.05
                },
            },
        },

        {
            spawnDefinitions = 
            {
                {
                    spawnType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "hider",
                        spawnCount = 1,
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },
    
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 18
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            },
    
            segmentChanges =
            {
                {
                    changeType = "reset",
                    arenaSegment = "upperCircle",
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "reset",
                    arenaSegment = "lowerLeftCircle",
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "reset",
                    arenaSegment = "lowerRightCircle",
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "reset",
                    arenaSegment = "mainCircle",
                    lerpSpeed = 0.05,
                },
            }
        }
    }
}

return levelDefinition