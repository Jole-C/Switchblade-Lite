-- Library requirements
require "lib.batteries":export()
bump = require "lib.bump.bump"
baton = require "lib.input.baton"
gamera = require "lib.camera.gamera"
ripple = require "lib.audio.ripple"

-- System requirements
local gameClass = require "src.game"
gameHelper = require "src.misc.gamehelper"

function love.load()
    game = gameClass()
    game:start()
end

function love.update(dt)
    if game then
        game:update(dt)
    end
end

function love.draw()
    if game then
        game:draw()
    end
end