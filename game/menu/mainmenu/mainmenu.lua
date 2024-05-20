local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"
local slider = require "game.interface.slider"
local sprite = require "game.interface.sprite"

local mainMenu = class{
    __includes = menu,

    -- Variables holding the background object and shader values
    menuBackgroundSprite,

    menuBoxShader,
    menuBackgroundShader,
    shaderCanvas,
    shaderTime = 0,
    shaderDirection = 1,
    shaderAngle = 0.25,

    backgroundScrollY = 0,
    backgroundScrollSpeed = 10,

    -- Offset for the menu background
    menuBoxOffset = 0,
    maxMenuBoxOffset = gameWidth,
    minMenuBoxOffset = -150,
    targetMenuBoxOffset = 0,

    init = function(self)
        -- Initialise menu elements
        self.menus =
        {
            ["start"] =
            {
                displayMenuName = false,
                elements =
                {
                    sprite("logo sprite", gameWidth/2, gameHeight/2 - 8, 0, 1, 1, 0, 0, true, gameManager.currentPalette.playerColour),

                    textButton("press space", "font ui", 10, gameHeight - 20, 10, gameHeight - 20, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                            self.owner:setBackgroundSlideAmount(0.32)
                        end
                    end, true)
                }
            },

            ["main"] = 
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("start", "font ui", 10, 10, 15, 10, function(self)
                        if self.owner then
                            self.owner:switchMenu("gamemodeselect")
                            self.owner:setBackgroundSlideAmount(0.35)
                        end
                    end),
    
                    textButton("options", "font ui", 10, 25, 15, 25, function(self)
                        if self.owner then
                            self.owner:switchMenu("options")
                            self.owner:setBackgroundSlideAmount(0.7)
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
                            self.owner:setBackgroundSlideAmount(0.32)
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
                            self.owner:setBackgroundSlideAmount(0.5)
                        end
                    end),
    
                    textButton("endless", "font ui", 10, 25, 15, 25, function()
                    end),
    
                    textButton("back", "font ui", 10, 50, 15, 50, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                            self.owner:setBackgroundSlideAmount(0.32)
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
                            self.owner:setBackgroundSlideAmount(0.35)
                        end
                    end)
                }
            },
        }

        -- Initialise background rendering
        self.menuBackgroundSprite = resourceManager:getResource("menu background mesh")
        menuBackgroundCanvas.enabled = true

        -- Initialise the box shader
        self.menuBoxShader = resourceManager:getResource("menu box shader")

        self.menuBoxOffset = self.minMenuBoxOffset

        -- Initialise the background shader
        self.menuBackgroundShader = resourceManager:getResource("menu background shader")


        -- Switch to the main menu
        self:switchMenu("start")
        self:setBackgroundSlideAmount(0)
    end,

    update = function(self, dt)
        menu.update(self, dt)

        -- Update the shader parameters
        if self.menuBoxShader and self.menuBackgroundShader then
            local shaderSpeed = gameManager.options.speedPercentage / 100
            self.shaderTime = self.shaderTime + (0.1 * shaderSpeed) * dt

            local angle = 0.4
            local warpScale = 0.1 + math.sin(self.shaderTime) * 0.3
            local warpTiling = 0.3 + math.sin(self.shaderTime) * 0.5
            local tiling = 3.0

            local resolution = {gameWidth, gameHeight}

            self.menuBoxShader:send("angle", angle)
            self.menuBoxShader:send("warpScale", warpScale)
            self.menuBoxShader:send("warpTiling", warpTiling)
            self.menuBoxShader:send("tiling", tiling)
            self.menuBoxShader:send("resolution", resolution)
            self.menuBoxShader:send("position", {0, 0})
            
            self.menuBackgroundShader:send("resolution", resolution)
            self.menuBackgroundShader:send("time", self.shaderTime)

            local bgColour = gameManager.currentPalette.backgroundColour[1]
            self.menuBackgroundShader:send("colour", {bgColour[1], bgColour[2], bgColour[3]})

            self.backgroundScrollY = self.backgroundScrollY + self.backgroundScrollSpeed * dt

            if self.backgroundScrollY > gameHeight - 20 then
                self.backgroundScrollY = 0
            end
        end

        self.menuBoxOffset = math.lerp(self.menuBoxOffset, self.targetMenuBoxOffset, 0.2)
    end,

    setBackgroundSlideAmount = function(self, percentage)
        self.targetMenuBoxOffset = math.lerp(self.minMenuBoxOffset, self.maxMenuBoxOffset, percentage)
    end,

    draw = function(self)
        love.graphics.setCanvas({menuBackgroundCanvas.canvas, stencil = true})
        love.graphics.setDefaultFilter("nearest", "nearest")
        love.graphics.clear()

        if self.menuBackgroundSprite then
            local enableBackground = gameManager.options.enableBackground

            if enableBackground == 1 then
                love.graphics.setShader(self.menuBackgroundShader)
                love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
                love.graphics.setShader()
            end

            self:drawOverlay()

            -- Use the menu background as a stencil
            love.graphics.stencil(function()
                love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY))
                love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY - gameHeight + 20))
            end, "replace", 1, false)

            love.graphics.setStencilTest("greater", 0)

            if enableBackground == 1 then
                love.graphics.setShader(self.menuBoxShader)
                love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
                love.graphics.setShader()
            else
                love.graphics.setColor(0.1, 0.1, 0.1, 1)
                love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
                love.graphics.setColor(1, 1, 1, 1)
            end

            self:drawOverlay()
        end

        -- Reset the canvas and stencil
        love.graphics.setCanvas()
        love.graphics.setStencilTest()
    end,

    drawOverlay = function(self)
        -- Draw an overlay for the background fade
        local alpha = gameManager.options.fadingPercentage / 100
        love.graphics.setColor(0.1, 0.1, 0.1, alpha)
        love.graphics.rectangle("fill", -100, -100, gameWidth + 100, gameHeight + 100)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    cleanup = function(self)
        menuBackgroundCanvas.enabled = false
    end
}

return mainMenu