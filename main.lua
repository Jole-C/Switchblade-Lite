-- Library requirements
require "lib.batteries":export()
bump = require "lib.bump.bump"
baton = require "lib.input.baton"
gamera = require "lib.camera.gamera"

-- Set up the arena
screenWidth = 320
screenHeight = 180
worldX = -600
worldY = -600
worldWidth = 600
worldHeight = 600

-- System requirements
local gameClass = require "game.game"

function SetupResources()
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

    local font = love.graphics.newFont("game/assets/fonts/kenneyrocketsquare.ttf", 64)
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
        {-screenWidth, 0, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
    }
    
    -- Generate the zigzag vertex pattern
    local generateInnerVertex = false

    for i = 0, numberOfVertices do
        generateInnerVertex = not generateInnerVertex

        local vertexXoffset = 0
        
        if generateInnerVertex == false then
            vertexXoffset = 20
        end

        local vertexX = baseVertexX + vertexXoffset
        local vertexY = (screenHeight / numberOfVertices) * i
        
        table.insert(vertices, {vertexX, vertexY, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})
    end

    -- Insert a vertex at the bottom left position
    table.insert(vertices, {-screenWidth, screenHeight, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})

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

function love.load()
    game = gameClass()
    game:start()

    -- Temporary particle system
    local bgCol = gameManager.currentPalette.backgroundColour
    ps = love.graphics.newParticleSystem(resourceManager:getResource("particle sprite"), 1632)
    
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