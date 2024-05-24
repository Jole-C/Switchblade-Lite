local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"
local slider = require "game.interface.slider"
local sprite = require "game.interface.sprite"
local mainMenu = class({name = "Main Menu", extends = menu})

function mainMenu:new()
    self:super()

    -- Shader values
    self.shaderTime = 0
    self.shaderDirection = 1
    self.shaderAngle = 0.25

    -- Menu box scroll
    self.backgroundScrollY = 0
    self.backgroundScrollSpeed = 10

    -- Offset for the menu box sliding
    self.maxMenuBoxOffset = game.arenaValues.screenWidth
    self.minMenuBoxOffset = -150
    self.targetMenuBoxOffset = 0

    -- Initialise background rendering
    self.menuBackgroundSprite = game.resourceManager:getResource("menu background mesh")
    game.canvases.menuBackgroundCanvas.enabled = true

    -- Initialise the box shader
    self.menuBoxShader = game.resourceManager:getResource("menu box shader")

    -- Initialise the box offset
    self.menuBoxOffset = self.minMenuBoxOffset

    -- Initialise the background shader
    self.menuBackgroundShader = game.resourceManager:getResource("menu background shader")

    -- Initialise menu elements
    self.menus =
    {
        ["start"] =
        {
            displayMenuName = false,
            elements =
            {
                sprite("logo sprite", game.arenaValues.screenWidth/2, game.arenaValues.screenHeight/2 - 8, 0, 1, 1, 0, 0, true, game.gameManager.currentPalette.playerColour),

                textButton("press space", "font ui", 10, game.arenaValues.screenHeight - 20, 10, game.arenaValues.screenHeight - 20, function(self)
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

                toggleButton("toggle bg.", "font ui", 10, 25, 20, 25, game.gameManager.options.enableBackground, {table = game.gameManager.options, value = "enableBackground"}),

                slider("bg. fading", "font ui", game.gameManager.options.fadingPercentage, 0, 100, 10, 40, {table = game.gameManager.options, value = "fadingPercentage"}),

                slider("bg. speed", "font ui", game.gameManager.options.speedPercentage, 0, 100, 10, 55, {table = game.gameManager.options, value = "speedPercentage"}),

                text("audio", "font ui", false, 10, 80),

                slider("music vol.", "font ui", game.gameManager.options.musicVolPercentage, 0, 100, 10, 95, {table = game.gameManager.options, value = "musicVolPercentage"}),

                slider("sfx vol.", "font ui", game.gameManager.options.sfxVolPercentage, 0, 100, 10, 110, {table = game.gameManager.options, value = "sfxVolPercentage"}),

                textButton("back", "font ui", 10, 135, 15, 135, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                    
                    game.gameManager:saveOptions()
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
                    game.gameManager:changePlayerDefinition("default definition")
                    game.gameStateMachine:set_state("gameLevelState")
                end),

                textButton("level 2", "font ui", 10, 25, 15, 25, function()
                    game.gameManager:changePlayerDefinition("light definition")
                    game.gameStateMachine:set_state("gameLevelState")
                end),

                textButton("level 3", "font ui", 10, 40, 15, 40, function()
                    game.gameManager:changePlayerDefinition("heavy definition")
                    game.gameStateMachine:set_state("gameLevelState")
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
    
    -- Switch to the main menu
    self:switchMenu("start")
    self:setBackgroundSlideAmount(0)
end

function mainMenu:update(dt)
    menu.update(self, dt)
    
    -- Update the shader parameters
    if self.menuBoxShader and self.menuBackgroundShader then
        local shaderSpeed = game.gameManager.options.speedPercentage / 100
        self.shaderTime = self.shaderTime + (0.1 * shaderSpeed) * dt

        local angle = 0.4
        local warpScale = 0.1 + math.sin(self.shaderTime) * 0.3
        local warpTiling = 0.3 + math.sin(self.shaderTime) * 0.5
        local tiling = 3.0

        local resolution = {game.arenaValues.screenWidth, game.arenaValues.screenHeight}

        self.menuBoxShader:send("angle", angle)
        self.menuBoxShader:send("warpScale", warpScale)
        self.menuBoxShader:send("warpTiling", warpTiling)
        self.menuBoxShader:send("tiling", tiling)
        self.menuBoxShader:send("resolution", resolution)
        self.menuBoxShader:send("position", {0, 0})
        
        self.menuBackgroundShader:send("resolution", resolution)
        self.menuBackgroundShader:send("time", self.shaderTime)

        local bgColour = game.gameManager.currentPalette.backgroundColour[1]
        self.menuBackgroundShader:send("colour", {bgColour[1], bgColour[2], bgColour[3]})

        self.backgroundScrollY = self.backgroundScrollY + self.backgroundScrollSpeed * dt

        if self.backgroundScrollY > game.arenaValues.screenHeight - 20 then
            self.backgroundScrollY = 0
        end
    end

    self.menuBoxOffset = math.lerp(self.menuBoxOffset, self.targetMenuBoxOffset, 0.2)
end

function mainMenu:setBackgroundSlideAmount(percentage)
    self.targetMenuBoxOffset = math.lerp(self.minMenuBoxOffset, self.maxMenuBoxOffset, percentage)
end

function mainMenu:draw()
    love.graphics.setCanvas({game.canvases.menuBackgroundCanvas.canvas, stencil = true})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.clear()

    if self.menuBackgroundSprite then
        local enableBackground = game.gameManager.options.enableBackground

        if enableBackground == 1 then
            love.graphics.setShader(self.menuBackgroundShader)
            love.graphics.rectangle("fill", 0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
            love.graphics.setShader()
        end

        self:drawOverlay()

        -- Use the menu background as a stencil
        love.graphics.stencil(function()
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY))
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY - game.arenaValues.screenHeight + 20))
        end, "replace", 1, false)

        love.graphics.setStencilTest("greater", 0)

        if enableBackground == 1 then
            love.graphics.setShader(self.menuBoxShader)
            love.graphics.rectangle("fill", 0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
            love.graphics.setShader()
        else
            love.graphics.setColor(0.1, 0.1, 0.1, 1)
            love.graphics.rectangle("fill", 0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
            love.graphics.setColor(1, 1, 1, 1)
        end

        self:drawOverlay()
    end

    -- Reset the canvas and stencil
    love.graphics.setCanvas()
    love.graphics.setStencilTest()
end

function mainMenu:drawOverlay()
    -- Draw an overlay for the background fade
    local alpha = game.gameManager.options.fadingPercentage / 100
    love.graphics.setColor(0.1, 0.1, 0.1, alpha)
    love.graphics.rectangle("fill", -100, -100, game.arenaValues.screenWidth + 100, game.arenaValues.screenHeight + 100)
    love.graphics.setColor(1, 1, 1, 1)
end

function mainMenu:cleanup()
    game.canvases.menuBackgroundCanvas.enabled = false
end

return mainMenu