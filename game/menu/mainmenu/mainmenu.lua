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
    menuBackgroundCircles = {},
    circleSpawnCooldown = 0,
    maxCircleSpawnCooldown = 1,

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
        self.menuBackgroundCircles = {}
        
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

                    toggleButton("toggle bg.", "font ui", 10, 25, 20, 25),

                    slider("bg. fading", "font ui", 25, 0, 100, 10, 40),

                    slider("bg. speed", "font ui", 25, 0, 100, 10, 55),

                    text("audio", "font ui", false, 10, 80),

                    slider("music vol.", "font ui", 25, 0, 100, 10, 95),

                    slider("sfx vol.", "font ui", 25, 0, 100, 10, 110),

                    textButton("back", "font ui", 10, 135, 15, 135, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                            self.owner:setBackgroundSlideAmount(0)
                        end
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

        -- Set the menu background slide amount to the default amount
        self:setBackgroundSlideAmount(0)

        -- Switch to the main menu
        self:switchMenu("main")
    end,

    update = function(self, dt)
        menu.update(self, dt)

        -- Update and add circles
        self.circleSpawnCooldown = self.circleSpawnCooldown - 1 * dt

        if self.circleSpawnCooldown <= 0 then
            self.circleSpawnCooldown = self.maxCircleSpawnCooldown
            table.insert(self.menuBackgroundCircles, {
                size = 10,
                colour = 0.1,
                maxSize = gameWidth * 1.3,
            })
        end

        for i = 1, #self.menuBackgroundCircles do
            local circle = self.menuBackgroundCircles[i]
            
            if circle then
                circle.size = circle.size + 40 * dt
                circle.colour = circle.colour + 0.01 * dt
                
                if circle.size > circle.maxSize then
                    table.remove(self.menuBackgroundCircles, i)
                    break
                end
            end
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
        love.graphics.setCanvas({menuBackgroundCanvas.canvas, stencil = true})
        love.graphics.setDefaultFilter("nearest", "nearest")
        love.graphics.clear()

        if self.menuBackground then
            -- Use the menu background as a stencil
            love.graphics.stencil(function()
                self.menuBackground:draw()
            end, "replace", 1, false)

            love.graphics.setStencilTest("greater", 0)

            -- Draw the menu background
            love.graphics.setColor(backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)

            for i = 1, #self.menuBackgroundCircles do
                local currentCircle = self.menuBackgroundCircles[i]

                love.graphics.setColor(currentCircle.colour, currentCircle.colour, currentCircle.colour, 1)
                love.graphics.circle("fill", 0, 0, currentCircle.size)
            end

            love.graphics.setColor(1, 1, 1, 1)
        end

        -- Reset the canvas and stencil
        love.graphics.setCanvas()
        love.graphics.setStencilTest()
    end,

    cleanup = function(self)
        self.menus = {}
        menuBackgroundCanvas.enabled = false
    end
}

return mainMenu