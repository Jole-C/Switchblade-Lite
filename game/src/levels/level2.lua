local wanderer = require "src.objects.enemy.wanderer"
local shielder = require "src.objects.enemy.shielder"
local sticker = require "src.objects.enemy.sticker"
local charger = require "src.objects.enemy.charger"

local heater = require "src.objects.enemy.heater"
local crisscross = require "src.objects.enemy.crisscross"
local ram = require "src.objects.enemy.crisscross"
local exploder = require "src.objects.enemy.exploder"
local snake = require "src.objects.enemy.snake"


local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer"},
        ["shielder"] = {enemyClass = shielder, overrideSprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("warningSprite")},
        ["sticker"] = {enemyClass = sticker, spriteName = "wanderer"},
        ["charger"] = {enemyClass = charger, spriteName = "charger"},

        ["heater"] = {enemyClass = heater, spriteName = "wanderer"},
        ["exploder"] = {enemyClass = exploder, spriteName = "wanderer"},
        ["crisscross"] = {enemyClass = crisscross, spriteName = "crisscross"},
        ["ram"] = {enemyClass = wanderer, spriteName = "wanderer"},
        ["snake"] = {enemyClass = snake, spriteName = "snake"},
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
        }
    }
}

return levelDefinition