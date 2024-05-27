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
        {
            name = "mainCircle",
            position = {
                x = 0, 
                y = 0
            },
            radius = 200
        },
        {
            name = "leftCircle",
            position = {
                x = -200, 
                y = 0
            },
            radius = 150
        },
        {
            name = "rightCircle",
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
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 100,
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
                        radius = 80,
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
                        radius = 80,
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
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 100,
                    lerpSpeed = 0.015
                },
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 8
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
                        radius = 100,
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
                        radius = 100,
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
                    newRadius = 70,
                    lerpSpeed = 0.
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 70,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 150,
                    lerpSpeed = 0.015
                },

                {
                    changeType = "position",
                    arenaSegment = "rightCircle",
                    newPosition = vec2(450, 0),
                    lerpSpeed = 0.01
                },
                {
                    changeType = "position",
                    arenaSegment = "leftCircle",
                    newPosition = vec2(-450, 0),
                    lerpSpeed = 0.01
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
                    timeUntilNextWave = 5
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
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 100,
                        origin = "leftCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 100,
                        origin = "rightCircle"
                    }
                }
            },

            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 1
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
                        radius = 100,
                        origin = "mainCircle"
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
                        radius = 100,
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
                        radius = 100,
                        origin = "rightCircle"
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
                    timeUntilNextWave = 15
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
                        radius = 100,
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
                        radius = 70
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
                        radius = 70
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
                    timeUntilNextWave = 15
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
                    lerpSpeed = 0.01
                },
                {
                    changeType = "reset",
                    arenaSegment = "rightCircle",
                    lerpSpeed = 0.01
                },
                {
                    changeType = "reset",
                    arenaSegment = "mainCircle",
                    lerpSpeed = 0.01
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
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 100,
                        origin = "mainCircle"
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
                        spawnCount = 7,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 100,
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
                        radius = 100,
                        origin = "rightCircle"
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
                        radius = 50,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newRadius = 150,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 150,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 150,
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
                    timeUntilNextWave = 20
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
                    timeUntilNextWave = 20
                }
            }
        }
    }
}

return levelDefinition