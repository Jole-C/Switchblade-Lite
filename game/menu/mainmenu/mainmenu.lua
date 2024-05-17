local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"
local slider = require "game.interface.slider"
local background = require "game.menu.mainmenu.menubackground"
local backgroundMeshColour = 0.1

local mainMenu = class{
    __includes = menu,

    -- Variables holding the background object and the background circle objects
    menuBackground = {},
    circleSpawnCooldown = 0,
    maxCircleSpawnCooldown = 1,
    shader,
    shaderCanvas,
    shaderTime = 0,
    shaderDirection = 1,

    -- Vertices for the background mesh
    backgroundVertices = {
        {0, 0, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {130, 0, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {95, gameHeight, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {0, gameHeight, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1}
    },

    targetVertexPositions = {},

    goalVertexPositions = {
        {0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {130 + gameWidth, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {95 + gameWidth, gameHeight, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {0, gameHeight, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1}
    },

    startingVertexPositions = {
        {0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {130, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {95, gameHeight, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
        {0, gameHeight}
    },

    init = function(self)
        -- Initialise menu elements
        self.menus =
        {
            ["main"] = 
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("start", "font ui", 10, 10, 15, 10, function(self)
                        if self.owner then
                            self.owner:switchMenu("gamemodeselect")
                        end
                    end),
    
                    textButton("options", "font ui", 10, 25, 15, 25, function(self)
                        if self.owner then
                            self.owner:switchMenu("options")
                            self.owner:setBackgroundSlideAmount(1)
                        end
                    end),
    
                    textButton("quit", "font ui", 10, 50, 15, 50, function()
                        love.event.quit()
                    end)
                }
            },

            ["options"] = 
            {
                displayMenuName = false,

                elements =
                {
                    text("visual", "font ui", false, 10, 10),

                    toggleButton("toggle bg.", "font ui", 10, 25, 20, 25, gameManager.options.enableBackground, {table = gameManager.options, value = "enableBackground"}),

                    slider("bg. fading", "font ui", gameManager.options.fadingPercentage, 0, 100, 10, 40, {table = gameManager.options, value = "fadingPercentage"}),

                    slider("bg. speed", "font ui", gameManager.options.speedPercentage, 0, 100, 10, 55, {table = gameManager.options, value = "speedPercentage"}),

                    text("audio", "font ui", false, 10, 80),

                    slider("music vol.", "font ui", gameManager.options.musicVolPercentage, 0, 100, 10, 95, {table = gameManager.options, value = "musicVolPercentage"}),

                    slider("sfx vol.", "font ui", gameManager.options.sfxVolPercentage, 0, 100, 10, 110, {table = gameManager.options, value = "sfxVolPercentage"}),

                    textButton("back", "font ui", 10, 135, 15, 135, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                            self.owner:setBackgroundSlideAmount(0)
                        end
                        
                        gameManager:saveOptions()
                    end),
                }
            },

            ["gamemodeselect"] =
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("arena", "font ui", 10, 10, 15, 10, function(self)
                        if self.owner then
                            self.owner:switchMenu("levelselect")
                        end
                    end),
    
                    textButton("endless", "font ui", 10, 25, 15, 25, function()
                    end),
    
                    textButton("back", "font ui", 10, 50, 15, 50, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                        end
                    end)
                }
            },

            ["levelselect"] =
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("level 1", "font ui", 10, 10, 15, 10, function()
                        gameManager:changePlayerDefinition("default definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("level 2", "font ui", 10, 25, 15, 25, function()
                        gameManager:changePlayerDefinition("light definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("level 3", "font ui", 10, 40, 15, 40, function()
                        gameManager:changePlayerDefinition("heavy definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("back", "font ui", 10, 65, 15, 65, function(self)
                        if self.owner then
                            self.owner:switchMenu("gamemodeselect")
                        end
                    end)
                }
            },
        }

        -- Initialise background rendering
        self.menuBackground = background()
        menuBackgroundCanvas.enabled = true

        self.shader = love.graphics.newShader[[
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
                
                float c = mix(uv.x, uv.y, angle) * tiling;
                c = mod(c, 1.0);
                c = step(c, 0.5);

                vec3 col1 = vec3(0.1, 0.1, 0.1);
                vec3 col2 = vec3(0.15, 0.15, 0.15);
                
                float val = floor(fract(pos.x) + 0.5);
                vec4 fragColour = vec4(mix(col1, col2, val), 1);

                return fragColour;
            }
        ]]

        self.shaderCanvas = love.graphics.newCanvas(gameWidth, gameHeight)

        -- Set the menu background slide amount to the default amount
        self:setBackgroundSlideAmount(0)

        -- Switch to the main menu
        self:switchMenu("main")
    end,

    update = function(self, dt)
        menu.update(self, dt)

        -- Update the shader parameters
        if self.shader then
            self.shaderTime = self.shaderTime + (self.shaderDirection * 0.05) * dt

            if self.shaderTime >= 0.3 then
                self.shaderDirection = -1
            end

            if self.shaderTime <= -0.3 then
                self.shaderDirection = 1
            end

            local angle = 0.4;
            local warpScale = 0.1 + math.clamp(math.sin(self.shaderTime), -1.0, 1.0);
            local warpTiling = 0.3 + math.clamp(math.sin((self.shaderTime) + 1.0), -0.7, 0.7);
            local tiling = 3.0;

            self.shader:send("angle", angle)
            self.shader:send("warpScale", warpScale)
            self.shader:send("warpTiling", warpTiling)
            self.shader:send("tiling", tiling)
            self.shader:send("resolution", {gameWidth, gameHeight})
            self.shader:send("position", {0, 0})
        end

        -- If the background sprite is successfully set, lerp the background vertex positions to the target positions, set by the slide function
        if self.menuBackground.sprite then
            local mesh = self.menuBackground.sprite
            local vertexCount = mesh:getVertexCount()

            for i = 1, vertexCount do
                local vertexX, vertexY = self.backgroundVertices[i]

                self.backgroundVertices[i][1] = math.lerp(self.backgroundVertices[i][1], self.targetVertexPositions[i][1], 0.2)
                self.backgroundVertices[i][2] = math.lerp(self.backgroundVertices[i][2], self.targetVertexPositions[i][2], 0.2)
            end

            mesh:setVertices(self.backgroundVertices)
        end
    end,

    setBackgroundSlideAmount = function(self, percentage)
        -- Set the target vertex positions to a percentage between the starting position (left) and goal position (far right)
        for i = 1, #self.backgroundVertices do
            self.targetVertexPositions[i] = {
                math.lerp(self.startingVertexPositions[i][1], self.goalVertexPositions[i][1], percentage),
                math.lerp(self.startingVertexPositions[i][2], self.goalVertexPositions[i][2], percentage),
                0,
                0,
                backgroundMeshColour,
                backgroundMeshColour,
                backgroundMeshColour,
                1,
            }
        end
    end,

    draw = function(self)
        -- Draw the shader

        love.graphics.setCanvas({menuBackgroundCanvas.canvas, stencil = true})
        love.graphics.setDefaultFilter("nearest", "nearest")
        love.graphics.clear()

        if self.menuBackground then
            -- Use the menu background as a stencil
            love.graphics.stencil(function()
                self.menuBackground:draw()
            end, "replace", 1, false)

            love.graphics.setStencilTest("greater", 0)
            
            love.graphics.setShader(self.shader)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
            love.graphics.setShader()
        end

        -- Reset the canvas and stencil
        love.graphics.setCanvas()
        love.graphics.setStencilTest()
    end,

    cleanup = function(self)
        menuBackgroundCanvas.enabled = false
    end
}

return mainMenu