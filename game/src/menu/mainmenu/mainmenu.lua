local menu = require "src.menu.menu"
local textButton = require "src.interface.textbutton"
local text = require "src.interface.text"
local toggleButton = require "src.interface.togglebutton"
local slider = require "src.interface.slider"
local sprite = require "src.interface.sprite"
local logo = require "src.menu.mainmenu.logo"
local rectangle = require "src.interface.rect"
local mainMenu = class({name = "Main Menu", extends = menu})

function mainMenu:new()
    self:super()

    -- Shader values
    self.shaderTime = 0
    self.shaderDirection = 1
    self.shaderAngle = 0.25

    -- Menu box scroll
    self.backgroundScrollY = 0
    self.backgroundScrollSpeed = 20

    -- Offset for the menu box sliding
    self.maxMenuBoxOffset = game.arenaValues.screenWidth
    self.minMenuBoxOffset = -150
    self.targetMenuBoxOffset = 0

    -- Initialise background rendering
    self.menuBackgroundSprite = game.resourceManager:getAsset("Interface Assets"):get("menuBackgroundMesh")
    game.canvases.menuBackgroundCanvas.enabled = true

    -- Initialise the box shader
    self.menuBoxShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBoxShader")

    -- Initialise the box offset
    self.menuBoxOffset = self.minMenuBoxOffset

    -- Initialise the background shader
    self.menuBackgroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBackgroundShader")

    -- Initialise menu elements
    self.menus =
    {
        ["start"] =
        {
            displayMenuName = false,
            elements =
            {
                logo(),
                
                textButton("press space", "fontUI", 10, game.arenaValues.screenHeight - 20, 10, game.arenaValues.screenHeight - 20, function(self)
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
                rectangle(100, 10, 480, 230, "fill", {0.1, 0.1, 0.1, 0.8}),
                text("READ ME:\nWelcome to Switchblade!\nThings are rough and unfinished.\nOnly one level is done for now with a boss at the end.\n\nControls - Keyboard:\nW - thrust, A/D - steer, SPACE - fire, LSHIFT - boost\nS - flip direction\n\nControls - Gamepad:\nA - thrust, LBUMPER - boost, RBUMPER - fire\nLSTICK - steer, B - flip direction\n\nUSEFUL TO KNOW:\nBoosting into enemies restores ammo.\nBoosting for too long makes you overheat.\nBoosting or overheating disables health\nregeneration.\nSome enemies can only be killed by boosting.\nThere is a visual indicator for this.\nOne of the enemies is currently using dev art,\nbut has other visual differences.\nYou die if you run out of time.\nHave fun!", "fontMain", "left", 110, 18, 1000),

                textButton("start", "fontUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end),

                textButton("options", "fontUI", 10, 25, 15, 25, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end),

                textButton("quit", "fontUI", 10, 50, 15, 50, function()
                    love.event.quit()
                end)
            }
        },

        ["optionsSelect"] =
        {
            elements =
            {
                textButton("Visual", "fontUI", 10, 10, 15, 10, function(self)
                    self.owner:switchMenu("optionsVisual")
                    self.owner:setBackgroundSlideAmount(0.7)
                end),

                textButton("Audio", "fontUI", 10, 25, 15, 25, function(self)
                    self.owner:switchMenu("optionsAudio")
                    self.owner:setBackgroundSlideAmount(0.7)
                end),

                textButton("Gameplay", "fontUI", 10, 40, 15, 40, function(self)
                    self.owner:switchMenu("optionsGameplay")
                    self.owner:setBackgroundSlideAmount(0.7)
                end),

                textButton("Accessibility", "fontUI", 10, 55, 15, 55, function(self)
                    self.owner:switchMenu("optionsAccessibility")
                    self.owner:setBackgroundSlideAmount(0.8)
                end),

                textButton("back", "fontUI", 10, 80, 15, 80, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                end)
            }
        },

        ["optionsGameplay"] =
        {
            elements = 
            {
                text("Gameplay", "fontUI", "left", 10, 10, 1000),

                slider("Health Ring Scale", "fontUI",  50, 150, 10, 25, "playerHealthRingSizePercentage"),
    
                toggleButton("Show Player Health", "fontUI", 10, 40, 20, 40, "showPlayerHealth", 260),

                toggleButton("Show Ring Helpers", "fontUI", 10, 55, 20, 55, "showHealthRingHelpers", 260),
    
                toggleButton("Center Camera", "fontUI", 10, 70, 20, 70, "centerCamera", 260),

                toggleButton("Show FPS", "fontUI", 10, 85, 20, 85, "showFPS", 260),

                toggleButton("Disable time alert", "fontUI", 10, 100, 20, 100, "disableTimeAlerts", 260),
    
                textButton("back", "fontUI", 10, 125, 15, 125, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["optionsAccessibility"] =
        {
            elements =
            {
                text("Accessibility", "fontUI", "left", 10, 10, 1000),

                toggleButton("Enable Debug Mode", "fontUI", 10, 25, 20, 25, "enableDebugMode", 260),

                toggleButton("Limit Palette Swaps", "fontUI", 10, 40, 20, 40, "limitPaletteSwaps", 260),

                toggleButton("Disable Screenshake", "fontUI", 10, 55, 20, 55, "disableScreenshake", 260),

                slider("Shake Intensity", "fontUI",  50, 9999, 10, 70, "screenshakeIntensity"),

                toggleButton("Disable Angle Shake", "fontUI", 10, 85, 20, 85, "disableAngleshake", 260),

                textButton("back", "fontUI", 10, 110, 15, 110, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["optionsVisual"] =
        {
            elements =
            {
                text("visual", "fontUI", "left", 10, 10, 1000),

                toggleButton("fullscreen.", "fontUI", 10, 25, 20, 25, "enableFullscreen"),

                toggleButton("toggle bg.", "fontUI", 10, 40, 20, 40, "enableBackground"),

                slider("bg. fading", "fontUI", 0, 100, 10, 55, "fadingPercentage"),

                slider("bg. speed", "fontUI", 0, 100, 10, 70, "speedPercentage"),
                
                textButton("back", "fontUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["optionsAudio"] = 
        {
            displayMenuName = false,

            elements =
            {
                text("audio", "fontUI", "left", 10, 10, 1000),

                slider("master vol.", "fontUI",  0, 100, 10, 25, "masterVolPercentage"),

                slider("music vol.", "fontUI",  0, 100, 10, 40, "musicVolPercentage"),

                slider("sfx vol.", "fontUI",  0, 100, 10, 55, "sfxVolPercentage"),

                toggleButton("mute", "fontUI", 10, 70, 20, 70, "muteAudio"),

                textButton("back", "fontUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["gamemodeselect"] =
        {
            displayMenuName = false,
            
            elements =
            {
                textButton("arena", "fontUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("levelselect")
                        self.owner:setBackgroundSlideAmount(0.5)
                    end
                end),

                textButton("endless", "fontUI", 10, 25, 15, 25, function()
                end),

                textButton("back", "fontUI", 10, 50, 15, 50, function(self)
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
                textButton("arena 1", "fontUI", 10, 10, 15, 10, function()
                    game.manager:changePlayerDefinition("default definition")
                    game.transitionManager:doTransition("gameLevelState")
                end),

                textButton("WIP", "fontUI", 10, 25, 15, 25, function()
                end),

                textButton("WIPPITY WIP", "fontUI", 10, 40, 15, 40, function()
                end),

                textButton("back", "fontUI", 10, 65, 15, 65, function(self)
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
        local shaderSpeed = game.manager:getOption("speedPercentage") / 100
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

        local bgColour = game.manager.currentPalette.backgroundColour[1]
        self.menuBackgroundShader:send("colour", {bgColour[1], bgColour[2], bgColour[3]})

        self.backgroundScrollY = self.backgroundScrollY + self.backgroundScrollSpeed * dt

        if self.backgroundScrollY > game.arenaValues.screenHeight then
            self.backgroundScrollY = 0
        end
    end

    self.menuBoxOffset = math.lerpDT(self.menuBoxOffset, self.targetMenuBoxOffset, 0.2, dt)
end

function mainMenu:setBackgroundSlideAmount(percentage)
    self.targetMenuBoxOffset = math.lerp(self.minMenuBoxOffset, self.maxMenuBoxOffset, percentage)
end

function mainMenu:draw()
    love.graphics.setCanvas({game.canvases.menuBackgroundCanvas.canvas, stencil = true})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.clear()

    if self.menuBackgroundSprite then
        if game.manager:getOption("enableBackground") == true then
            love.graphics.setShader(self.menuBackgroundShader)
            love.graphics.rectangle("fill", 0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
            love.graphics.setShader()
        end

        self:drawOverlay()

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, self.backgroundScrollY)
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, self.backgroundScrollY - game.arenaValues.screenHeight)

        -- Use the menu background as a stencil
        love.graphics.stencil(function()
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, self.backgroundScrollY)
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, self.backgroundScrollY - game.arenaValues.screenHeight)
        end, "replace", 1, false)

        love.graphics.setStencilTest("greater", 0)

        if game.manager:getOption("enableBackground") then
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
    local alpha = game.manager:getOption("fadingPercentage") / 100
    love.graphics.setColor(0.1, 0.1, 0.1, alpha)
    love.graphics.rectangle("fill", -100, -100, game.arenaValues.screenWidth + 100, game.arenaValues.screenHeight + 100)
    love.graphics.setColor(1, 1, 1, 1)
end

function mainMenu:cleanup()
    menu.cleanup(self)
    game.canvases.menuBackgroundCanvas.enabled = false
end

return mainMenu