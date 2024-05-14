-- Library requirements
gamestate = require "lib.hump.gamestate"
class = require "lib.hump.class"
vector = require "lib.hump.vector"
timer = require "lib.hump.timer"
bump = require "lib.bump.bump"
baton = require "lib.input.baton"
math.pi = 3.14159265

-- System requirements
require "game.misc.mathhelpers"
local renderer = require "game.render.renderer"
local resource = require "game.resourcemanager"
local interface = require "game.interface.interfacerenderer"
local gameDirector = require "game.gamemanager"
local playerHandler = require "game.objects.player.playermanager"
colliderDefinitions = require "game.collision.colliderdefinitions"

input = baton.new{
    controls = {
        thrust = {'key:w', 'key:up'},
        steerLeft = {'key:a', 'key:left'},
        steerRight = {'key:d', 'key:right'},
        boost = {'key:lshift', 'key:rshift'},
        shoot = {'key:space'},
        menuUp = {'key:w', 'key:up'},
        menuDown = {'key:s', 'key:down'},
        menuLeft = {'key:a', 'key:left'},
        menuRight = {'key:d', 'key:right'},
        select = {'key:return', 'key:space'},
        pause = {'key:escape'},
    }
}

menuState = require "game.gamestates.menustate"
gameLevelState = require "game.gamestates.gamelevelstate"
gameoverState = require "game.gamestates.gameoverstate"

function SetupResources()
    -- In game resources
    local playerSprite = love.graphics.newImage("game/assets/sprites/player/player.png")
    resourceManager:addResource(playerSprite, "player sprite")

    local chargerEnemy = love.graphics.newImage("game/assets/sprites/enemy/chargerenemy.png")
    resourceManager:addResource(chargerEnemy, "charger enemy sprite")

    local droneEnemy = love.graphics.newImage("game/assets/sprites/enemy/droneenemy.png")
    resourceManager:addResource(droneEnemy, "drone enemy sprite")

    -- Global resources
    local particle = love.graphics.newImage("game/assets/sprites/particlesprite.png")
    resourceManager:addResource(particle, "particle sprite")

    local font = love.graphics.newFont("game/assets/fonts/kenneyrocketsquare.ttf", 8)
    font:setFilter("nearest", "nearest", 0)
    resourceManager:addResource(font, "font main")

    local font = love.graphics.newFont("game/assets/fonts/kenneyrocketsquare.ttf", 16)
    font:setFilter("nearest", "nearest", 0)
    resourceManager:addResource(font, "font large")

    -- Interface resources
    local selectedBox = love.graphics.newImage("game/assets/sprites/interface/selectedbox.png")
    resourceManager:addResource(selectedBox, "selected box")

    local unselectedBox = love.graphics.newImage("game/assets/sprites/interface/unselectedbox.png")
    resourceManager:addResource(unselectedBox, "unselected box")
end

function love.load()
    -- Create a new game manager
    gameManager = gameDirector()

    -- Create a new renderer
    gameRenderer = renderer()

    -- Create a new interface renderer
    interfaceRenderer = interface()

    -- Create the resource manager
    resourceManager = resource()
    SetupResources()

    -- Create the player manager
    playerManager = playerHandler()

    -- Set up palettes
    local paletteImage = love.image.newImageData("game/assets/sprites/palettes.png")

    local width,height = paletteImage:getDimensions()

    for y = 0, height - 1 do
        local grabbedColours = {}

        for x = 0, width - 1 do
            local r, g, b, a = paletteImage:getPixel(x, y)
            table.insert(grabbedColours, {r, g, b, a})
        end
        
        gameManager:addPalette(
            {
                playerColour = grabbedColours[1],
                enemyColour = grabbedColours[2],
                backgroundColour = {
                    grabbedColours[3],
                    grabbedColours[4],
                    grabbedColours[5],
                    grabbedColours[6],
                    grabbedColours[7],
                },
                uiColour = grabbedColours[8],
                enemySpawnColour = grabbedColours[9]
            }
        )
    end
    
    -- Swap to a random palette
    gameManager:swapPalette()
    
    -- Set up the rendering
    gameWidth = 320
    gameHeight = 180
    windowWidth, windowHeight = love.window.getDesktopDimensions();
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    backgroundCanvas = gameRenderer:addRenderCanvas("backgroundCanvas", gameWidth, gameHeight)
    backgroundShadowCanvas = gameRenderer:addRenderCanvas("backgroundShadowCanvas", gameWidth, gameHeight)
    foregroundShadowCanvas = gameRenderer:addRenderCanvas("foregroundShadowCanvas", gameWidth, gameHeight)
    foregroundCanvas = gameRenderer:addRenderCanvas("foregroundCanvas", gameWidth, gameHeight)
    interfaceCanvas = gameRenderer:addRenderCanvas("interfaceCanvas", gameWidth, gameHeight)
    transitionCanvas = gameRenderer:addRenderCanvas("transitionCanvas", gameWidth, gameHeight)
    
    -- Temporary particle system
    local bgCol = gameManager.currentPalette.backgroundColour
    ps = love.graphics.newParticleSystem(resourceManager:getResource("particle sprite"), 1632)
    --[[
    ps:setColors(bgCol[1], bgCol[2], bgCol[3], bgCol[4])
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
    ps:setSizeVariation(1)
    ps:setSpeed(255.74447631836, 481.64227294922)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.31415927410126)
    ps:setTangentialAcceleration(0, 0)
]]
-------
    ps:setColors(bgCol[1], bgCol[2], bgCol[3], bgCol[4])
    ps:setDirection(0.045423280447721)
    ps:setEmissionArea("uniform", 339.4328918457, 224.59356689453, 0, false)
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
    
    -- Set up the gamestate
    gamestate.switch(menuState)
end

function love.update(dt)
    input:update()
    gameManager:update(dt)

    if gameManager.isPaused then
        return
    end
    
    gamestate.update(dt)
    playerManager:update(dt)
    timer.update(dt)
    ps:setColors(gameManager.currentPalette.backgroundColour[1], gameManager.currentPalette.backgroundColour[2], gameManager.currentPalette.backgroundColour[3], gameManager.currentPalette.backgroundColour[4])
    ps:update(dt/3)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the background
    love.graphics.setCanvas(backgroundCanvas.canvas)
    love.graphics.setBackgroundColor(gameManager.currentPalette.backgroundColour[5])
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(ps, gameWidth/2, gameHeight/2)

    -- Draw the background overlay
    love.graphics.setCanvas(backgroundShadowCanvas.canvas)
    love.graphics.clear()
    love.graphics.setColor(0.1, 0.1, 0.1, 0)
    love.graphics.rectangle("fill", -100, -100, gameWidth + 100, gameHeight + 100)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the foreground
    love.graphics.setCanvas(foregroundCanvas.canvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")

    gamestate.draw()

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
    love.graphics.draw(foregroundCanvas.canvas, 2, 2)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the interface
    love.graphics.setCanvas(interfaceCanvas.canvas)
    love.graphics.clear()
    gameManager:draw()
    interfaceRenderer:draw()
    love.graphics.setCanvas()

    -- Render the canvases
    gameRenderer:drawCanvases()
end