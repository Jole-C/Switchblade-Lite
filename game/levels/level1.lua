local wanderer = require "game.objects.enemy.arena1.wanderer"
local charger = require "game.objects.enemy.arena1.charger"
local drone = require "game.objects.enemy.arena1.drone"
local shielder = require "game.objects.enemy.arena1.shielder"
local orbiter = require "game.objects.enemy.arena1.orbiter"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer sprite"},
        ["charger"] = {enemyClass = charger, spriteName = "charger sprite"},
        ["drone"] = {enemyClass = drone, spriteName = "drone sprite"},
        ["shielder"] = {enemyClass = shielder, spriteName = "wanderer sprite"},
        ["orbiter"] = {enemyClass = orbiter, spriteName = "wanderer sprite"},
    },
    
    arenaSegmentDefinitions =
    {
        {
            name = "mainCircle",
            position = {
                x = 0, 
                y = 0
            },
            radius = 250
        },
        {
            name = "leftCircle",
            position = {
                x = -200, 
                y = 0
            },
            radius = 200
        },
        {
            name = "rightCircle",
            position = {
                x = 200, 
                y = 0
            },
            radius = 200
        },
    },

    playerStartSegment = "mainCircle",

    startingWave = 0,

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
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = -200, y = 0},
                            {x = 200, y = 0}
                        }
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 3
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
                    waveType = "alongShapePerimeter",

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
                    minimumKills = 10
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 5
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
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 130,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 130,
                        origin = "rightCircle"
                    }
                }
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newRadius = 250,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 250,
                    lerpSpeed = 0.015
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 13
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 100,
                        origin = "rightCircle"
                    }
                }
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newRadius = 200,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 200,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 300,
                    lerpSpeed = 0.015
                },

                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-250, 0),
                    lerpSpeed = 0.05,
                },
                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(250, 0),
                    lerpSpeed = 0.05,
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 8
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "rightCircle"
                    }
                }
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 4,
                        radius = 150,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 4,
                        radius = 150,
                        origin = "rightCircle"
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 12
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        origin = "rightCircle",
                        numberOfPoints = 10,
                        radius = 120
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        origin = "leftCircle",
                        numberOfPoints = 10,
                        radius = 120
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 15
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
                }
            },

            segmentChanges =
            {
                {
                    changeType = "reset",
                    arenaSegment = "leftCircle",
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "rightCircle",
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "mainCircle",
                    lerpSpeed = 0.05
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 9
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 150,
                        origin = "mainCircle"
                    }
                }
            },
            {
                waveType = "predefined",

                enemyDef =
                {
                    enemyID = "drone",
                },

                shapeDef =
                {
                    origin = "leftCircle",
                    points = {
                        x = 0, y = 0
                    }
                }
            },
            {
                waveType = "predefined",

                enemyDef =
                {
                    enemyID = "drone",
                },

                shapeDef =
                {
                    origin = "rightCircle",
                    points = {
                        x = 0, y = 0
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 12
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 20
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
                        numberOfPoints = 7,
                        radius = 150,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 150,
                        origin = "rightCircle"
                    }
                },
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
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 250,
                    lerpSpeed = 0.05
                },

                {
                    changeType = "position",
                    arenaSegment = "mainCircle",
                    newPosition = vec2(0, -200),
                    lerpSpeed = 0.05
                },
                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(200, 0),
                    lerpSpeed = 0.05
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-200, 0),
                    lerpSpeed = 0.05
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 15
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
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
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "rightCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },          
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "leftCircle",
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
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
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
                        radius = 120,
                        origin = "rightCircle"
                    }
                },
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
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "position",
                    arenaSegment = "mainCircle",
                    newPosition = vec2(0, -120),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(120, 0),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-120, 0),
                    lerpSpeed = 0.01
                }
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 13
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            x = 0, y = 0
                        }
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
                        numberOfPoints = 4,
                        radius = 120,
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
                        numberOfPoints = 4,
                        radius = 120,
                        origin = "rightCircle"
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
                        numberOfPoints = 4,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "position",
                    arenaSegment = "mainCircle",
                    newPosition = vec2(0, 0),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(120, 0),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-120, 0),
                    lerpSpeed = 0.01
                }
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 11
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
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                    },

                    shapeDef =
                    {
                        origin = "rightCircle",
                        points =
                        {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                    },

                    shapeDef =
                    {
                        origin = "leftCircle",
                        points =
                        {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 120,
                        origin = "rightCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 120,
                        origin = "mainCircle"
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
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            x = 0, y = 0
                        }
                    }
                }
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 4
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 15,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "rightCircle"
                    }
                },
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        origin = "rightCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
            },
            
            segmentChanges =
            {
                {
                    changeType = "reset",
                    arenaSegment = "leftCircle",
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "rightCircle",
                    lerpSpeed = 0.05
                },
                {
                    changeType = "reset",
                    arenaSegment = "mainCircle",
                    lerpSpeed = 0.05
                }
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 18
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 1
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },

                    shapeDef =
                    {
                        origin = "rightCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },

                    shapeDef =
                    {
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 1
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "predefined",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 120,
                        origin = "rightCircle"
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
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "shielder",
                    },
    
                    shapeDef =
                    {
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "shielder",
                    },
    
                    shapeDef =
                    {
                        origin = "rightCircle",
                        points = {
                            {x = 0, y = 0}
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
                    timeUntilNextWave = 40
                }
            }
        },
        {
            spawnDefinitions =
            {
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "drone",
                    },
    
                    shapeDef =
                    {
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 15,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "radius",
                    arenaSegment = "mainCircle",
                    newRadius = 350,
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-30, 0),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(30, 0),
                    lerpSpeed = 0.01
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 20
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
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
                        enemyID = "charger",
                        spawnCount = 15,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 120,
                        origin = "rightCircle"
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 20
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
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
                        spawnCount = 20,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 20,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "shielder",
                    },
    
                    shapeDef =
                    {
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
                {
                    waveType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "shielder",
                    },
    
                    shapeDef =
                    {
                        origin = "rightCircle",
                        points = {
                            {x = 0, y = 0}
                        }
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 20
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
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
                        enemyID = "charger",
                        spawnCount = 20,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 20,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
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
                            {x = 0, y = 0}
                        }
                    }
                },
            },
            
            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 500,
                    lerpSpeed = 0.05
                }
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 20
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
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
                        spawnCount = 20,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 20,
                        radius = 300,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "drone",
                        spawnCount = 3,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 22
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        }
    }
}

return levelDefinition