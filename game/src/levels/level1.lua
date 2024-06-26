local wanderer = require "src.objects.enemy.wanderer"
local charger = require "src.objects.enemy.charger"
local drone = require "src.objects.enemy.drone"
local shielder = require "src.objects.enemy.shielder"
local orbiter = require "src.objects.enemy.orbiter"
local boss = require "src.objects.enemy.boss.boss1.boss1"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer"},
        ["charger"] = {enemyClass = charger, spriteName = "charger"},
        ["drone"] = {enemyClass = drone, spriteName = "drone"},
        ["shielder"] = {enemyClass = shielder, spriteName = "wanderer"},
        ["orbiter"] = {enemyClass = orbiter, spriteName = "orbiter"},
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
            radius = 225
        },
        {
            name = "leftCircle",
            position = {
                x = -200, 
                y = 0
            },
            radius = 175
        },
        {
            name = "rightCircle",
            position = {
                x = 200, 
                y = 0
            },
            radius = 175
        },
    },

    playerStartSegment = "mainCircle",

    level = 
    {
        -- line of wanderers (introduction)
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

        -- circle of wanderers
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
                    minimumKills = 10
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 5
                }
            }
        },

        -- three circles of wanderers, left and right circles are smaller, the left and right segments become bigger
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
                        radius = 30,
                        origin = "leftCircle"
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
                        radius = 30,
                        origin = "rightCircle"
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
                        radius = 150,
                        origin = "mainCircle"
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
            }
        },

        --three circles of wanderers
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
                        numberOfPoints = 10,
                        radius = 150,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                    spawnType = "alongShapePerimeter",

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
                    newRadius = 250,
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
                    minimumKills = 13
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            }
        },

        -- a line of chargers (introduction) and two small circles of wanderers
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
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
                        origin = "rightCircle",
                        numberOfPoints = 5,
                        radius = 120
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
                        origin = "leftCircle",
                        numberOfPoints = 5,
                        radius = 120
                    }
                }
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
            }
        },

        -- an x cross of chargers, the arena resets
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = 100, y = -100},
                            {x = -100, y = 100}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = -100, y = -100},
                            {x = 100, y = 100}
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
                    minimumKills = 9
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 15
                }
            }
        },

        --a triangle of chargers. two circles of wanderers to either side
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = -100},
                            {x = 100, y = 100},
                            {x = -100, y = 100}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                    spawnType = "alongShapePerimeter",

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
                    minimumKills = 16
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            }
        },

        -- two large circles of wanderers and a small circle of chargers
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 9,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "leftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 9,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 150,
                        origin = "rightCircle"
                    }
                },
                {
                    spawnType = "mainCircle",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 100,
                        origin = "rightCircle"
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
                    timeUntilNextWave = 30
                }
            }
        },

        -- a circle of chargers
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

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

        -- 3 small circles of wanderers and a drone (introduction), the arena segments arrange into a sort of triangle formation
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "alongShapePerimeter",

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
                    spawnType = "alongShapePerimeter",

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
                },
                {
                    spawnType = "alongShapePerimeter",

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
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 120
                        }
                    }
                },    
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "rightCircle",
                    newRadius = 225,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "leftCircle",
                    newRadius = 225,
                    lerpSpeed = 0.05
                },
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 225,
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
                    minimumKills = 8
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },

        -- two drones and a circle of wanderers
        {
            spawnDefinitions = 
            {            
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 150,
                        origin = "mainCircle",
                        offset = {x = 0, y = 112}
                    }
                },       
                {
                    spawnType = "predefined",

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
                    spawnType = "predefined",

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
                    minimumKills = 10
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            }
        },

        -- 3 circles of wanderers
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 112
                        }
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
                        radius = 120,
                        origin = "leftCircle"
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
                        radius = 120,
                        origin = "rightCircle"
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

        -- two drones and a vertical line of chargers        
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = 0, y = -200},
                            {x = 0, y = 200}
                        }
                    }
                }
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
                    minimumKills = 8
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 30
                }
            }
        },

        -- a shielder (introduction) and two circles of chargers
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "predefined",

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
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 5,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 5,
                        radius = 30,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                    spawnType = "alongShapePerimeter",

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
                    minimumKills = 12
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },

        -- a shielder and a drone
        {
            spawnDefinitions = 
            {
                {
                    spawnType = "predefined",

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
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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

        --randomly spawned enemies and two shielders
        {
            spawnDefinitions =
            {
                {
                    spawnType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 15,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 30,
                        origin = "leftCircle"
                    }
                },
                {
                    spawnType = "randomWithinShape",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 30,
                        origin = "rightCircle"
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
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
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
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                        origin = "rightCircle",
                        points = {
                            {x = 0, y = 0}
                        }
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
                        origin = "leftCircle",
                        points = {
                            {x = 0, y = 0}
                        }
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
                            {x = 0, y = 0}
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
                    timeUntilNextWave = 40
                }
            }
        },

        -- two drones a shielder and random wanderers
        {
            spawnDefinitions =
            {
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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
                    spawnType = "predefined",

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
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "shielder",
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
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 10,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
            },
            
            nextWaveConditions = 
            {
                {
                    conditionType = "minimumKills",
                    minimumKills = 10
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },

        -- an orbiter two circles of chargers and a drone
        {
            spawnDefinitions =
            {
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 100}
                        }
                    }
                },
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = -100}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 120,
                        origin = "leftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
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

        -- an orbiter, a circle of chargers and two shielders
        {
            spawnDefinitions =
            {
                {
                    spawnType = "predefined",
    
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
                    spawnType = "alongShapePerimeter",
    
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
                    spawnType = "predefined",
    
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
                    spawnType = "predefined",
    
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
                    minimumKills = 7
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },

        -- the arena becomes a single circle. an orbiter, a drone, and a large circle of chargers
        {
            spawnDefinitions =
            {
                {
                    spawnType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = -50}
                        }
                    }
                },
                {
                    spawnType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "orbiter",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 0, y = 50}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",
    
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
                },
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 350,
                    lerpSpeed = 0.05,
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

        -- a large circle of chargers, two circles of wanderers and an orbiter
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 8,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 120,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 15,
                        origin = "leftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 7,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 7,
                        radius = 15,
                        origin = "rightCircle"
                    }
                },
                {
                    spawnType = "predefined",
    
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

        -- a huge circle of wanderers, two shielders and an orbiter
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",
    
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 15,
                    },
    
                    shapeDef =
                    {
                        numberOfPoints = 20,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "predefined",
    
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
                    spawnType = "predefined",
    
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
                {
                    spawnType = "predefined",
    
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
                    minimumKills = 17
                },
                {
                    conditionType = "timer",
                    timeUntilNextWave = 40
                }
            }
        },

        -- the circle becomes bigger, a large circle of chargers, two drones and an orbiter
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",
    
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
                    spawnType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "drone",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = -100, y = 0}
                        }
                    }
                },
                {
                    spawnType = "predefined",
    
                    enemyDef =
                    {
                        enemyID = "drone",
                    },
    
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 100, y = 0}
                        }
                    }
                },
                {
                    spawnType = "predefined",
    
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
            
            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 400,
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

        -- 3 drones and a large circle of wanderers
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",
    
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
                    spawnType = "alongShapePerimeter",
    
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
        },
        {
            waveType = "bossWave",
            bossID = "boss",
            
            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 350,
                    lerpSpeed = 0.05,
                }
            }
        }
    },
}

return levelDefinition