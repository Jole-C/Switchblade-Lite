local grunt = require "game.objects.enemy.arena1.grunt"
local soldier = require "game.objects.enemy.arena1.soldier"
local utility = require "game.objects.enemy.arena1.grunt"
local specialist = require "game.objects.enemy.arena1.grunt"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["grunt"] = grunt,
        ["soldier"] = soldier,
        ["utility"] = utility,
        ["specialist"] = specialist,
    }, 
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
                        enemyID = "grunt",
                        spawnCount = 3,
                    },

                    -- The definition for the shape to use
                    -- A definition can be either the below values to easily construct a shape, 
                    -- or specific points to use
                    shapeDef =
                    {
                        numberOfPoints = 3,
                        radius = 64,
                        origin = {x = gameWidth/2, y = gameHeight/2}
                    }
                },
            }
        },
        {
            spawnDefinitions = 
            {
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "grunt",
                        spawnCount = 6,
                    },

                    shapeDef =
                    {
                        numberOfPoints = 4,
                        radius = 64,
                        origin = {x = gameWidth/2, y = gameHeight/2}
                    }
                },
                
                {
                    waveType = "alongShapePerimeter",

                    enemyDef =
                    {
                        enemyID = "grunt",
                        spawnCount = 3,
                    },

                    shapeDef =
                    {
                        {x = gameWidth/2 - 80, y = gameHeight/2},
                        {x = gameWidth/2 + 80, y = gameHeight/2}
                    }
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 3,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 7,
                }
            }
        },
        
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 3,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 1,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 2,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 3,
                },
            }
        },
    }
}

return levelDefinition