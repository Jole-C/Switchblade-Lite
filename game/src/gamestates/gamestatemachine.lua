local gameLevelState = require "src.gamestates.gamelevelstate"
local menuState = require "src.gamestates.menustate"
local gameOverState = require "src.gamestates.gameoverstate"

local gameLevel = gameLevelState()
local menuLevel = menuState()
local gameOverLevel = gameOverState()

local gameStateMachine = state_machine(
{
    menuState = {
        enter = menuLevel.enter,
        exit = menuLevel.exit,
        update = menuLevel.update,
        draw = menuLevel.draw
    },

    gameLevelState = {
        enter = gameLevel.enter,
        exit = gameLevel.exit,
        update = gameLevel.update,
        draw = gameLevel.draw,
        addObject = gameLevel.addObject,
        removeObject = gameLevel.removeObject
    },

    gameOverState = {
        enter = gameOverLevel.enter,
        exit = gameOverLevel.exit,
        update = gameOverLevel.update,
        draw = gameOverLevel.draw,
        addObject = gameOverLevel.addObject,
        removeObject = gameOverLevel.removeObject
    },
}, "menuState")

return gameStateMachine