require "game.misc.mathhelpers"
local gameRenderer = require "game.render.renderer"
local resourceManager = require "game.resourcemanager"
local interfaceRenderer = require "game.interface.interfacerenderer"
local gameManager = require "game.gamemanager"
local playerManager = require "game.objects.player.playermanager"
colliderDefinitions = require "game.collision.colliderdefinitions"

local game = class({name = "Game"})

function game:new()
    -- Set up the arena values
    self.arenaValues =
    {
        screenWidth = 480,
        screenHeight = 270,
        worldX = -600,
        worldY = -600,
        worldWidth = 600,
        worldHeight = 600,
    }

    -- Load all services
    self.manager = gameManager()
    self.manager:setupPalettes()
    
    self.gameRenderer = gameRenderer()
    self.interfaceRenderer = interfaceRenderer()
    self.resourceManager = resourceManager()
    self:setupResources()

    self.camera = gamera.new(0, 0, self.arenaValues.screenWidth, self.arenaValues.screenHeight)
    self.camera:setWindow(0, 0, self.arenaValues.screenWidth, self.arenaValues.screenHeight)

    self.playerManager = playerManager()

    self.input = baton.new{
        controls = {
            thrust = {'key:w', 'key:up', 'button:a'},
            reverseThrust = {'key:s', 'key:down', 'button:x'},
            steerLeft = {'key:a', 'key:left', 'axis:leftx-'},
            steerRight = {'key:d', 'key:right', 'axis:leftx+'},
            boost = {'key:lshift', 'key:rshift', 'button:leftshoulder'},
            shoot = {'key:space', 'button:rightshoulder'},
            menuUp = {'key:w', 'key:up', 'button:dpup'},
            menuDown = {'key:s', 'key:down', 'button:dpdown'},
            menuLeft = {'key:a', 'key:left', 'button:dpleft'},
            menuRight = {'key:d', 'key:right', 'button:dpright'},
            select = {'key:return', 'key:space', 'button:a'},
            pause = {'key:escape', 'button:start'},
        },
        joystick = love.joystick.getJoysticks()[1]
    }
    
    local windowWidth, windowHeight = love.window.getDesktopDimensions();
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    self.canvases = {
        backgroundCanvas = self.gameRenderer:addRenderCanvas("backgroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        backgroundShadowCanvas = self.gameRenderer:addRenderCanvas("backgroundShadowCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        foregroundShadowCanvas = self.gameRenderer:addRenderCanvas("foregroundShadowCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        foregroundCanvas = self.gameRenderer:addRenderCanvas("foregroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        menuBackgroundCanvas = self.gameRenderer:addRenderCanvas("menuBackgroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        interfaceCanvas = self.gameRenderer:addRenderCanvas("interfaceCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        transitionCanvas = self.gameRenderer:addRenderCanvas("transitionCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
    }

    local song = love.audio.newSource("game/assets/audio/music/song.mp3", "stream")
    song:play()
    song:setLooping(true)
end

function game:start()
    self.gameStateMachine = require "game.gamestates.gamestatemachine"
end

function game:update(dt)
    self.input:update()

    self.manager:update(dt)

    if self.manager.isPaused or self.manager.gameFrozen then
        return
    end

    self.gameStateMachine:update(dt)
    self.playerManager:update(dt)

    ps:setColors(self.manager.currentPalette.backgroundColour[1], self.manager.currentPalette.backgroundColour[2], self.manager.currentPalette.backgroundColour[3], self.manager.currentPalette.backgroundColour[4])
    ps:update(dt/7 * self.manager.options.speedPercentage/100)
end

function game:draw()
    self:drawBackground()
    self:drawForeground()
    self:drawInterface()

    self.gameRenderer:drawCanvases()
end

function game:drawBackground()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the background
    love.graphics.setCanvas({self.canvases.backgroundCanvas.canvas, stencil = true})
    love.graphics.setBackgroundColor(self.manager.currentPalette.backgroundColour[5])
    love.graphics.setBlendMode("alpha")
    
    if self.manager.options.enableBackground == 1 then
        love.graphics.draw(ps)
    else
        love.graphics.clear()
    end

    love.graphics.setStencilTest()
    love.graphics.setCanvas()

    -- Draw the background overlay
    love.graphics.setCanvas(self.canvases.backgroundShadowCanvas.canvas)
    love.graphics.clear()

    local alpha = self.manager.options.fadingPercentage / 100
    love.graphics.setColor(0.1, 0.1, 0.1, alpha)
    love.graphics.rectangle("fill", -100, -100, self.arenaValues.screenWidth + 100, self.arenaValues.screenHeight + 100)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function game:drawForeground()
    -- Draw the shadows
    love.graphics.setCanvas(self.canvases.foregroundShadowCanvas.canvas)
    love.graphics.clear()
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.draw(self.canvases.foregroundCanvas.canvas, 2, 2)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)

    self.camera:draw(function()
        -- Draw the foreground
        love.graphics.setCanvas({self.canvases.foregroundCanvas.canvas, stencil = true})
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")

        self.gameStateMachine:draw(dt)
        
        local currentGamestate = self.gameStateMachine:current_state()
        
        if currentGamestate.objects then
            for key,object in ipairs(currentGamestate.objects) do
                object:draw()
            end
        end

        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setStencilTest()
    end)
end

function game:drawInterface()
    -- Draw the interface
    love.graphics.setCanvas(self.canvases.interfaceCanvas.canvas)
    love.graphics.clear()
    self.manager:draw()
    self.interfaceRenderer:draw()
    love.graphics.setFont(self.resourceManager:getResource("font main"))
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function game:setupResources()
    local resourceManager = self.resourceManager

    -- In game resources
    local playerSprite = love.graphics.newImage("game/assets/sprites/player/player.png")
    resourceManager:addResource(playerSprite, "player default")

    local playerSpriteHeavy = love.graphics.newImage("game/assets/sprites/player/player2.png")
    resourceManager:addResource(playerSpriteHeavy, "player heavy")

    local playerSpriteLight = love.graphics.newImage("game/assets/sprites/player/player3.png")
    resourceManager:addResource(playerSpriteLight, "player light")

    local playerLaserSprite = love.graphics.newImage("game/assets/sprites/player/playerlaser.png")
    resourceManager:addResource(playerLaserSprite, "player laser sprite")

    local chargerEnemy = love.graphics.newImage("game/assets/sprites/enemy/charger.png")
    resourceManager:addResource(chargerEnemy, "charger sprite")

    local chargerTail = love.graphics.newImage("game/assets/sprites/enemy/chargertail.png")
    resourceManager:addResource(chargerTail, "charger tail sprite")

    local droneEnemy = love.graphics.newImage("game/assets/sprites/enemy/drone.png")
    resourceManager:addResource(droneEnemy, "drone sprite")

    local wandererEnemy = love.graphics.newImage("game/assets/sprites/enemy/wanderer.png")
    resourceManager:addResource(wandererEnemy, "wanderer sprite")

    local wandererTail = love.graphics.newImage("game/assets/sprites/enemy/wanderertail.png")
    resourceManager:addResource(wandererTail, "wanderer tail sprite")

    -- Global resources
    local particle = love.graphics.newImage("game/assets/sprites/particlesprite.png")
    resourceManager:addResource(particle, "particle sprite")

    local font = love.graphics.newFont("game/assets/fonts/kenneyrocketsquare.ttf", 8)
    font:setFilter("nearest", "nearest", 0)
    resourceManager:addResource(font, "font main")

    local font = love.graphics.newFont("game/assets/fonts/kenneyfuture.ttf", 16)
    font:setFilter("nearest", "nearest", 0)
    resourceManager:addResource(font, "font ui")

    local font = love.graphics.newFont("game/assets/fonts/kenneyrocketsquare.ttf", 32)
    font:setFilter("nearest", "nearest", 0)
    resourceManager:addResource(font, "font alert")

    -- Interface resources
    local selectedBox = love.graphics.newImage("game/assets/sprites/interface/selectedbox.png")
    resourceManager:addResource(selectedBox, "selected box")

    local unselectedBox = love.graphics.newImage("game/assets/sprites/interface/unselectedbox.png")
    resourceManager:addResource(unselectedBox, "unselected box")

    local logo = love.graphics.newImage("game/assets/sprites/interface/logo.png")
    resourceManager:addResource(logo, "logo sprite")

    -- Set up the mesh with given parameters
    local numberOfVertices = 9
    local baseVertexX = 100
    local mesh = love.graphics.newMesh(2 + numberOfVertices + 1, "fan")

    -- Create a table to hold the vertices, and insert the top left vertex
    local vertices = {
        {-self.arenaValues.screenWidth, 0, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
    }
    
    -- Generate the zigzag vertex pattern
    local generateInnerVertex = false

    for i = 0, numberOfVertices do
        generateInnerVertex = not generateInnerVertex

        local vertexXoffset = 0
        
        if generateInnerVertex == false then
            vertexXoffset = 30
        end

        local vertexX = baseVertexX + vertexXoffset
        local vertexY = (self.arenaValues.screenHeight / numberOfVertices) * i
        
        table.insert(vertices, {vertexX, vertexY, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})
    end

    -- Insert a vertex at the bottom left position
    table.insert(vertices, {-self.arenaValues.screenWidth, self.arenaValues.screenHeight, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})

    -- Set the vertices and register the resource with the resource manager
    mesh:setVertices(vertices)
    resourceManager:addResource(mesh, "menu background mesh")

    -- Shader resources
    local menuBackgroundShader = love.graphics.newShader([[
        extern vec2 resolution;
        extern float time;
        extern vec3 colour;
        vec4 effect(vec4 screenColour, Image texture, vec2 texCoord, vec2 screenCoord)
        {
            vec2 center = vec2(resolution.x, resolution.y) / 2.0;
            vec2 pos = screenCoord / center;
            
            float radius = length(pos);
            float angle = atan(pos.y, pos.x);
            
            vec2 uv = vec2(radius, angle);
            vec3 col = 0.5 + 0.5*cos(time+uv.xyy+vec3(0,2,4));
            
            float intensity = dot(col.xyz, vec3(0.3, 0.3, 0.3));
            float levels = 32.0;
            float quantized = floor(intensity * levels) / levels;
            
            col = col * quantized * 5.0;
            
            float gray = dot(col, vec3(0.3, 0.3, 0.3)) * 1.5;
            
            return vec4(colour * gray, 1.0);
        }
    ]])
    resourceManager:addResource(menuBackgroundShader, "menu background shader")

    local menuBoxShader = love.graphics.newShader([[
        extern number angle;
        extern number warpScale;
        extern number warpTiling;
        extern number tiling;
        extern vec2 position;
        extern vec2 resolution;

        vec4 effect(vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
        {
            const float PI = 3.14159;
            
            vec2 uv = (screenCoords - position) / resolution;
            
            vec2 pos = vec2(0, 0);
            pos.x = mix(uv.x, uv.y, angle);
            pos.y = mix(uv.y, 1.0 - uv.x, angle);
            pos.x += sin(pos.y * warpTiling * PI * 2.0) * warpScale;
            pos.x *= tiling;

            vec3 col1 = vec3(0.1, 0.1, 0.1);
            vec3 col2 = vec3(0.13, 0.13, 0.13);
            
            float val = floor(fract(pos.x) + 0.5);
            vec4 fragColour = vec4(mix(col1, col2, val), 1);

            return fragColour;
        }
    ]])
    resourceManager:addResource(menuBoxShader, "menu box shader")
end

return game