gamestate = require "lib.hump.gamestate"
class = require "lib.hump.class"
vector = require "lib.hump.vector"
push = require "lib.push.push"

require "game.misc.mathhelpers"
require "game.render.renderer"

require "game.objects.player"

local test = gamestate.new()
local newplayer = player(10, 10)

test.objects = {}
table.insert(test.objects, newplayer)

function test:load()
    
end

function test:update()
    for index,object in ipairs(self.objects) do
        object:update()
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    gamestate.registerEvents()
    gamestate.switch(test)
    gamerenderer = renderer()
    
    gameWidth = 320
    gameHeight = 180
    windowWidth, windowHeight = love.window.getDesktopDimensions();
    windowWidth = windowWidth * 0.7
    windowHeight = windowHeight * 0.7

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, pixelperfect = true})
end

function love.update()
    gamerenderer:update()
    test:update()
end

function love.draw()
    push:start()
    gamerenderer:draw()
    push:finish()
end