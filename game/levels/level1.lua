local wanderer = require "game.objects.enemy.arena1.wanderer"
local charger = require "game.objects.enemy.arena1.charger"
local drone = require "game.objects.enemy.arena1.drone"
local utility = require "game.objects.enemy.arena1.charger"
local specialist = require "game.objects.enemy.arena1.charger"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["wanderer"] = wanderer,
        ["charger"] = charger,
        ["drone"] = drone,
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

            radius = 100
        },
        ["leftCircle"] = {
            position = {
                x = -100, 
                y = 0
            },

            radius = 80
        },
        ["rightCircle"] = {
            position = {
                x = 100, 
                y = 0
            },

            radius = 80
        },
    },

    playerStartSegment = "mainCircle",

    level =
    {
        -- A wave of enemies
        {
            -- The definitions for how to spawn enemies
            spawnDefinitions = 
            {
                -- A spawn definition
                {
                    -- The type of wave this is
                    waveType = "alongShapePerimeter",

                    -- The enemy to spawn within this wave
                    enemyDef =
                    {
                        enemyID = "wanderer",
                        spawnCount = 4,
                    },

                    -- The definition for the shape to use
                    -- Can either use values to dynamically construct a shape, or predefined coordinates
                    shapeDef =
                    {
                        origin = "mainCircle",
                        points =
                        {
                            {x = -80, y = 0},
                            {x = 80, y = 0}
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
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 4,
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
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 6,
                        radius = 64,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = -120, y = 0},
                            {x = 120, y = 0}
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
                        spawnCount = 4,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 40,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 10,
                        radius = 80,
                        origin = "mainCircle"
                    }
                },
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "charger",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        origin = "mainCircle",
                        points = {
                            {x = 120, y = 0},
                            {x = 120, y = 0}
                        }
                    }
                }
            }
        },
    }
}

return levelDefinition