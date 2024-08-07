local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["boss"] = enemyDefinitions.boss1
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
    },

    playerStartSegment = "mainCircle",

    level =
    {
        {
            waveType = "bossWave",
            bossID = "boss",
            
            segmentChanges =
            {
                {
                    changeType = "size",
                    arenaSegment = "mainCircle",
                    newRadius = 300,
                    lerpSpeed = 0.05,
                }
            }
        }
    }
}

return levelDefinition