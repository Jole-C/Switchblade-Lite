-- Library requirements
require "lib.batteries":export()
bump = require "lib.bump.bump"
baton = require "lib.input.baton"
gamera = require "lib.camera.gamera"

-- System requirements
local gameClass = require "game.game"
gameHelper = require "game.misc.gamehelper"

function love.load()
    game = gameClass()
    game:start()

    -- Temporary particle system
    local bgCol = game.manager.currentPalette.backgroundColour
    ps = love.graphics.newParticleSystem(game.resourceManager:getResource("particle sprite"), 1632)
    
    --[[ps:setColors(bgCol[1], bgCol[2], bgCol[3], bgCol[4])
    ps:setDirection(-1.5707963705063)
    ps:setEmissionArea("uniform", screenWidth/2, screenHeight/2, 0, false)
    ps:setEmissionRate(225.32614135742)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(158.52745056152, 671.95892333984, 7004.2802734375, 2611.5888671875)
    ps:setLinearDamping(0, 0)
    ps:setOffset(0, 0)
    ps:setParticleLifetime(7.3186434747186e-005, 6.8977484703064)
    ps:setRadialAcceleration(4082.21875, -799.76824951172)
    ps:setRelativeRotation(false)
    ps:setRotation(0, -0.1798534989357)
    ps:setSizes(0.59753084182739)
    ps:setSizeVariation(1)
    ps:setSpeed(255.74447631836, 481.64227294922)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.31415927410126)
    ps:setTangentialAcceleration(0, 0)]]

-------
    ps:setColors(bgCol[1], bgCol[2], bgCol[3], bgCol[4])
    ps:setDirection(0.045423280447721)
    ps:setEmissionArea("uniform", 480, 270, 0, false)
    ps:setEmissionRate(512)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(0, 0, 0, 0)
    ps:setLinearDamping(0, 0)
    ps:setOffset(50, 50)
    ps:setParticleLifetime(1.7999999523163, 2.2000000476837)
    ps:setRadialAcceleration(0, 0)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 0)
    ps:setSizes(0.095902815461159, 0.53716236352921)
    ps:setSizeVariation(0.99361020326614)
    ps:setSpeed(0.51036554574966, 0.51036554574966)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.11967971920967)
    ps:setTangentialAcceleration(379.81402587891, 405.12814331055)
    
    ps:start()  

    local dt = 0.1
    for i = 0, 4, dt do
        ps:update(dt)
    end
end

function love.update(dt)
    if game then
        game:update(dt)
    end
end

function love.draw()
    if game then
        game:draw(dt)
    end
end