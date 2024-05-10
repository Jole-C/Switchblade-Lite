gamestate = require "lib.hump.gamestate"
class = require "lib.hump.class"
vector = require "lib.hump.vector"
timer = require "lib.hump.timer"
push = require "lib.push.push"
bump = require "lib.bump.bump"
love.math.pi = 3.14159265

require "game.misc.mathhelpers"
local renderer = require "game.render.renderer"
local resource = require "game.resourcemanager"
local playerHandler = require "game.objects.player.playermanager"
colliderDefinitions = require "game.collision.colliderdefinitions"

local menu = require "game.gamestates.menustate"

function SetupResources()
    -- In game resources
    local playerSprite = love.graphics.newImage("game/assets/sprites/player/player.png")
    resourceManager:addResource(playerSprite, "player sprite")

    local chargerEnemy = love.graphics.newImage("game/assets/sprites/enemy/chargerenemy.png")
    resourceManager:addResource(chargerEnemy, "charger enemy sprite")
end

function love.load()
    -- Set up the gamestate
    gamestate.registerEvents()
    gamestate.switch(menu)

    -- Create a new renderer
    gameRenderer = renderer()

    -- Create the resource manager
    resourceManager = resource()
    SetupResources()

    -- Create the player manager
    playerManager = playerHandler()
    
    --Set up push
    gameWidth = 320
    gameHeight = 180
    windowWidth, windowHeight = love.window.getDesktopDimensions();
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, pixelperfect = true})
end

function love.update(dt)
    gameRenderer:update(dt)
    timer.update(dt)
end

function love.draw()
    push:start()
    gameRenderer:draw()
    love.graphics.print(collectgarbage('count'), 0, gameHeight - 20)
    push:finish()
end