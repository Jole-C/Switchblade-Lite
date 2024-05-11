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

    backgroundCanvas = love.graphics.newCanvas(gameWidth, gameHeight)
    foregroundCanvas = love.graphics.newCanvas(gameWidth, gameHeight)
end

function love.update(dt)
    gameRenderer:update(dt)
    playerManager:update(dt)
    timer.update(dt)
    input:update()
end

function love.draw()
    love.graphics.setCanvas(backgroundCanvas)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.setCanvas(foregroundCanvas)
    love.graphics.clear()
    gameRenderer:draw()
    love.graphics.print(collectgarbage('count'), 0, gameHeight - 20)

    love.graphics.setCanvas()

    local maxScaleX = love.graphics.getWidth() / backgroundCanvas:getWidth()
    local maxScaleY = love.graphics.getHeight() / backgroundCanvas:getHeight()
    local scale = math.min(maxScaleX, maxScaleY)

    love.graphics.draw(backgroundCanvas, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, scale, scale, backgroundCanvas:getWidth() / 2, backgroundCanvas:getHeight() / 2)
    love.graphics.draw(foregroundCanvas, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, scale, scale, foregroundCanvas:getWidth() / 2, foregroundCanvas:getHeight() / 2)
    
end