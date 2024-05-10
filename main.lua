gamestate = require "lib.hump.gamestate"
class = require "lib.hump.class"
vector = require "lib.hump.vector"
timer = require "lib.hump.timer"
push = require "lib.push.push"
bump = require "lib.bump.bump"

require "game.misc.mathhelpers"
local renderer = require "game.render.renderer"
colliderdefinitions = require "game.collision.colliderdefinitions"

local menu = require "game.gamestates.menustate"

function love.load()
    -- Set up the gamestate
    gamestate.registerEvents()
    gamestate.switch(menu)

    -- Create a new renderer
    gamerenderer = renderer()
    
    --Set up push
    gameWidth = 320
    gameHeight = 180
    windowWidth, windowHeight = love.window.getDesktopDimensions();
    windowWidth = windowWidth * 0.7
    windowHeight = windowHeight * 0.7
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, pixelperfect = true})
end

function love.update(dt)
    gamerenderer:update(dt)
    timer.update(dt)
end

function love.draw()
    push:start()
    gamerenderer:draw()
    push:finish()
end