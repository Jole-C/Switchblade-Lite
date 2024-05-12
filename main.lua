gamestate = require "lib.hump.gamestate"
class = require "lib.hump.class"
vector = require "lib.hump.vector"
timer = require "lib.hump.timer"
bump = require "lib.bump.bump"
baton = require "lib.input.baton"
love.math.pi = 3.14159265

require "game.misc.mathhelpers"
local renderer = require "game.render.renderer"
local resource = require "game.resourcemanager"
local playerHandler = require "game.objects.player.playermanager"
local gameDirector = require "game.gamemanager"
colliderDefinitions = require "game.collision.colliderdefinitions"

input = baton.new{
    controls = {
        thrust = {'key:w', 'key:up'},
        steerLeft = {'key:a', 'key:left'},
        steerRight = {'key:d', 'key:right'},
        boost = {'key:lshift', 'key:rshift'},
        shoot = {'key:space'},
        menuUp = {'key:w', 'key:up'},
        menuDown = {'key:d', 'key:down'},
        select = {'key:return', 'key:space'},
        pause = {'key:escape'},
    }
}

menu = require "game.gamestates.menustate"
gameLevel = require "game.gamestates.gamelevelstate"
gameover = require "game.gamestates.gameoverstate"

function SetupResources()
    -- In game resources
    local playerSprite = love.graphics.newImage("game/assets/sprites/player/player.png")
    resourceManager:addResource(playerSprite, "player sprite")

    local chargerEnemy = love.graphics.newImage("game/assets/sprites/enemy/chargerenemy.png")
    resourceManager:addResource(chargerEnemy, "charger enemy sprite")

    local droneEnemy = love.graphics.newImage("game/assets/sprites/enemy/droneenemy.png")
    resourceManager:addResource(droneEnemy, "drone enemy sprite")
end

function love.load()
    -- Create a new game manager
    gameManager = gameDirector()

    -- Create a new renderer
    gameRenderer = renderer()

    -- Create the resource manager
    resourceManager = resource()
    SetupResources()

    -- Create the player manager
    playerManager = playerHandler()
    
    -- Set up the gamestate
    gamestate.registerEvents()
    gamestate.switch(menu)
    
    --Set up push
    gameWidth = 320
    gameHeight = 180
    windowWidth, windowHeight = love.window.getDesktopDimensions();
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    backgroundCanvas = gameRenderer:addRenderCanvas("backgroundCanvas", gameWidth, gameHeight)
    foregroundShadowCanvas = gameRenderer:addRenderCanvas("foregroundShadowCanvas", gameWidth, gameHeight)
    foregroundCanvas = gameRenderer:addRenderCanvas("foregroundCanvas", gameWidth, gameHeight)
    
    ps = love.graphics.newParticleSystem(resourceManager:getResource("drone enemy sprite"), 1632)
    ps:setColors(0.0078125, 0, 1, 1, 0, 0.9296875, 1, 1, 0.359375, 0, 1, 1, 1, 0, 0.9609375, 1, 1, 1, 1, 1)
    ps:setDirection(-1.5707963705063)
    ps:setEmissionArea("uniform", gameWidth/2, gameHeight/2, 0, false)
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
    ps:setSizeVariation(0.5)
    ps:setSpeed(255.74447631836, 481.64227294922)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.31415927410126)
    ps:setTangentialAcceleration(0, 0)

    ps:start()  

    local dt = 0.1
    for i = 0, 4, dt do
        ps:update(dt)
    end  
end

function love.update(dt)
    gameRenderer:update(dt)
    playerManager:update(dt)
    timer.update(dt)
    input:update()
    ps:update(dt)
end

function love.draw()
    -- Draw the background
    love.graphics.setCanvas(backgroundCanvas.canvas)
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(ps, gameWidth/2, gameHeight/2)
    
    -- Draw the foreground
    love.graphics.setCanvas(foregroundCanvas.canvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")

    local currentGamestate = gamestate.current()

    if currentGamestate.objects then
        for key,object in ipairs(currentGamestate.objects) do
            object:draw()
        end
    end

    -- Draw the shadows
    love.graphics.setCanvas(foregroundShadowCanvas.canvas)
    love.graphics.clear()
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.draw(foregroundCanvas.canvas, 3, 3)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)

    -- Render the canvases
    gameRenderer:drawCanvases()
end