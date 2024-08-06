local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = enemyDefinitions.wanderer,
        ["shielder"] = enemyDefinitions.shielder,
        ["sticker"] = enemyDefinitions.sticker,
        ["charger"] = enemyDefinitions.charger,
        ["drone"] = enemyDefinitions.drone,

        ["heater"] = enemyDefinitions.heater,
        ["exploder"] = enemyDefinitions.exploder,
        ["crisscross"] = enemyDefinitions.crisscross,
        ["ram"] = enemyDefinitions.wanderer,
        ["snake"] = enemyDefinitions.snake,
        ["boss"] = enemyDefinitions.boss2
    },
    
    arenaSegmentDefinitions =
    {
        {
            name = "mainCircle",
            position = {x = 0, y = 0},
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

    startingWave = 23,

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
                },
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
                        radius = 100,
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
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
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 100,
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "sticker",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
            }
        },
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
                        numberOfPoints = 8,
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "sticker",
                        spawnCount = 12,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 12,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "upperCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerLeftCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
                },
                {
                    changeType = "size",
                    arenaSegment = "lowerRightCircle",
                    newRadius = 200,
                    lerpSpeed = 0.015
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
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = 
                        {
                            {x = 0, y = -200},
                            {x = 0, y = -100}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                            {x = 0, y = 200},
                            {x = 0, y = 100}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                            {x = -200, y = 0},
                            {x = -100, y = 0}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                            {x = 200, y = 0},
                            {x = 100, y = 0}
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            },
        },
        {
            spawnDefinitions = {
                {
                    spawnType = "alongShapePerimeter",

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
                            {x = -100, y = -200},
                            {x = -100, y = 200}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

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
                            {x = 100, y = -200},
                            {x = 100, y = 200}
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = -150
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 150
                        }
                    }
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
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = -150, y = 0
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
                        origin = "mainCircle",
                        points = {
                            x = 150, y = 0
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 12,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 12,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 12,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 12,
                        radius = 200,
                        origin = "mainCircle"
                    }
                },
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 12,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 200,
                        origin = "mainCircle"
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
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 12,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 12,
                        radius = 100,
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
                            x = 150, y = 0
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
                        origin = "mainCircle",
                        points = {
                            x = -150, y = 0
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
                        origin = "mainCircle",
                        points = {
                            x = 0, y = 0
                        }
                    }
                },
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 4,
                        radius = 100,
                        origin = "mainCircle"
                    }
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
                        origin = "mainCircle",
                        points = {
                            x = -200, y = 0
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
                        origin = "mainCircle",
                        points = {
                            x = 200, y = 0
                        }
                    }
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
                        enemyID = "exploder",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = -100, y = 0
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
                        origin = "mainCircle",
                        points = {
                            x = 100, y = 0
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
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
            },

            segmentChanges =
            {
                {
                    changeType = "position",
                    arenaSegment = "upperCircle",
                    newPosition = vec2(0, 0),
                    lerpSpeed = 0.005,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerLeftCircle",
                    newPosition = vec2(90, 0),
                    lerpSpeed = 0.005,
                },
                {
                    changeType = "position",
                    arenaSegment = "lowerRightCircle",
                    newPosition = vec2(-90, 0),
                    lerpSpeed = 0.005,
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
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 100,
                        origin = "lowerLeftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 100,
                        origin = "lowerRightCircle"
                    }
                },
            },
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        origin = "lowerRightCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        origin = "lowerLeftCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
                        }
                    }
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
                        enemyID = "drone",
                        spawnCount = 1,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            x = -200, y = 0
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 100,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = 150, y = 150},
                            {x = -150, y = 150}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = 150, y = -150},
                            {x = -150, y = -150}
                        }
                    }
                },
            },
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 170,
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
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "drone",
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
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 170,
                        origin = "mainCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 170,
                        origin = "lowerLeftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 8,
                        radius = 170,
                        origin = "lowerRightCircle"
                    }
                },
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
                spawnType = "predefined",

                enemyDef =
                {
                    enemyID = "drone",
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
        {
            spawnDefinitions =
            {
                {
                    spawnType = "predefined",

                    enemyDef =
                    {
                        enemyID = "snake",
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
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 170,
                        origin = "lowerLeftCircle"
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "heater",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 170,
                        origin = "lowerRightCircle"
                    }
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
                        enemyID = "snake",
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
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        origin = "lowerRightCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        origin = "lowerLeftCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
                        }
                    }
                },
            }
        },
        {
            spawnDefinitions =
            {
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        origin = "lowerRightCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
                        }
                    }
                },
                {
                    spawnType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "crisscross",
                        spawnCount = 8,
                    },

                    shapeDef =
                    {
                        origin = "lowerLeftCircle",
                        points =
                        {
                            {x = 0, y = -150},
                            {x = 0, y = 150}
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
                            x = 100, y = 0
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
                            x = 100, y = 0
                        }
                    }
                },
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
    }
}

return levelDefinition