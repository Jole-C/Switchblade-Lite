local menu = require "src.menu.menu"
local textButton = require "src.interface.textbutton"
local text = require "src.interface.text"
local toggleButton = require "src.interface.togglebutton"
local slider = require "src.interface.slider"
local sprite = require "src.interface.sprite"
local logo = require "src.menu.mainmenu.logo"
local rectangle = require "src.interface.rect"

local level1 = require "src.levels.level1"
local level2 = require "src.levels.level2"

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

    self.eyePositionOffset = vec2(-30, -30)
    self.targetEyePositionOffset = vec2(0, 0)
    self.maxEyeOffset = 100
    self.minEyeOffset = 50
    self.maxEyePositionChangeCooldown = 5
    self.minEyePositionChangeCooldown = 2
    self.eyePositionChangeCooldown = self.maxEyePositionChangeCooldown
    self.eyePositionLerpRate = 0.05
    self.eyeAlpha = 0.1
    self.targetEyeOrigin = vec2(420, 200)
    self.eyeOrigin = vec2(500, 400)
    self.eyeOriginLerpRate = 0.1
    self.showEye = false
    self.pupilRadius = 30
    self.maxPupilRadius = 50
    self.minPupilRadius = 15
    self.targetPupilRadius = self.pupilRadius
    self.pupilRadiusLerpRate = 0.1

    -- Initialise background rendering
    self.menuBackgroundSprite = game.resourceManager:getAsset("Interface Assets"):get("menuBackgroundMesh")
    game.canvases.menuBackgroundCanvas.enabled = true

    -- Initialise the box shader
    self.menuBoxShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBoxShader")

    -- Initialise the box offset
    self.menuBoxOffset = self.minMenuBoxOffset

    -- Initialise the background shader
    self.menuBackgroundShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBackgroundShader")

    -- Menu Sounds
    self.selectSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("menuSelect")
    self.backSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("menuBack")
    self.startSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("gameStart")

    -- Initialise menu elements
    self.menus =
    {
        ["start"] =
        {
            displayMenuName = false,
            elements =
            {
                logo(),
                
                textButton("press space", "fontBigUI", 10, game.arenaValues.screenHeight - 20, 10, game.arenaValues.screenHeight - 20, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.startSound:play()
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
                text([[
                    "READ ME:
                    Welcome to Switchblade!
                    Things are unfinished. This is a temporary readme.
                    Only one level is done for now with a boss at the end.


                    Controls - Keyboard:
                    W - thrust, A/D - steer, SPACE - fire, LSHIFT - boost
                    S - flip direction

                    Controls - Gamepad:
                    A - thrust, LBUMPER - boost, RBUMPER - fire
                    LSTICK - steer, B - flip direction


                    USEFUL TO KNOW:
                    Boosting into enemies restores ammo.
                    Boosting for too long makes you overheat.
                    Boosting or overheating disables health recharge.
                    Some enemies can only be killed by boosting - 
                    - they have a white outline.
                    You die if you run out of time.
                    Defeating waves and other actions drop pickups - 
                    - touch them to add time.
                    
                    
                    Have fun!"]], "fontMain", "left", 40, 18, 1000),

                textButton("start", "fontBigUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("options", "fontBigUI", 10, 25, 15, 25, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.35)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("credits", "fontBigUI", 10, 40, 15, 40, function(self)
                end),

                textButton("about", "fontBigUI", 10, 55, 15, 55, function(self)
                end),

                textButton("quit", "fontBigUI", 10, 80, 15, 80, function()
                    love.event.quit()
                end),

                text("demo v0.4", "fontUI", "left", 10, 250, 500, 0, 1, 1, false, {0.4, 0.4, 0.4, 1})
            }
        },

        ["optionsSelect"] =
        {
            elements =
            {
                textButton("Visual", "fontBigUI", 10, 10, 15, 10, function(self)
                    self.owner:switchMenu("optionsVisual")
                    self.owner:setBackgroundSlideAmount(0.7)
                    self.owner.selectSound:play()
                end),

                textButton("Audio", "fontBigUI", 10, 25, 15, 25, function(self)
                    self.owner:switchMenu("optionsAudio")
                    self.owner:setBackgroundSlideAmount(0.7)
                    self.owner.selectSound:play()
                end),

                textButton("Gameplay", "fontBigUI", 10, 40, 15, 40, function(self)
                    self.owner:switchMenu("optionsGameplay")
                    self.owner:setBackgroundSlideAmount(0.7)
                    self.owner.selectSound:play()
                end),

                textButton("Accessibility", "fontBigUI", 10, 55, 15, 55, function(self)
                    self.owner:switchMenu("optionsAccessibility")
                    self.owner:setBackgroundSlideAmount(0.8)
                    self.owner.selectSound:play()
                end),

                textButton("back", "fontBigUI", 10, 80, 15, 80, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                end)
            }
        },

        ["optionsGameplay"] =
        {
            elements = 
            {
                text("Gameplay", "fontBigUI", "left", 10, 10, 1000),

                slider("Health Ring Scale", "fontBigUI",  50, 150, 10, 25, "playerHealthRingSizePercentage", 260),
    
                toggleButton("Show Player Health", "fontBigUI", 10, 40, 20, 40, "showPlayerHealth", 260),

                toggleButton("Show Ring Helpers", "fontBigUI", 10, 55, 20, 55, "showHealthRingHelpers", 260),
    
                toggleButton("Center Camera", "fontBigUI", 10, 70, 20, 70, "centerCamera", 260),

                toggleButton("Show FPS", "fontBigUI", 10, 85, 20, 85, "showFPS", 260),
                
                textButton("back", "fontBigUI", 10, 110, 15, 110, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["optionsAccessibility"] =
        {
            elements =
            {
                text("Accessibility", "fontBigUI", "left", 10, 10, 1000),

                toggleButton("Enable Debug Mode", "fontBigUI", 10, 25, 20, 25, "enableDebugMode", 260),

                toggleButton("Limit Palette Swaps", "fontBigUI", 10, 40, 20, 40, "limitPaletteSwaps", 260),

                toggleButton("Disable Screenshake", "fontBigUI", 10, 55, 20, 55, "disableScreenshake", 260),

                slider("Shake Intensity", "fontBigUI",  50, 9999, 10, 70, "screenshakeIntensity", 260),

                toggleButton("Disable Angle Shake", "fontBigUI", 10, 85, 20, 85, "disableAngleshake", 260),

                slider("Zoom Scale", "fontBigUI",  50, 150, 10, 100, "cameraZoomScale", 260),

                textButton("back", "fontBigUI", 10, 125, 15, 125, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                    
                    game.manager:saveOptions()
                end),
            }
        },

        ["optionsVisual"] =
        {
            elements =
            {
                text("visual", "fontBigUI", "left", 10, 10, 1000),

                toggleButton("fullscreen.", "fontBigUI", 10, 25, 20, 25, "enableFullscreen"),

                toggleButton("toggle bg.", "fontBigUI", 10, 40, 20, 40, "enableBackground"),

                slider("bg. fading", "fontBigUI", 0, 100, 10, 55, "fadingPercentage"),

                slider("bg. speed", "fontBigUI", 0, 100, 10, 70, "speedPercentage"),
                
                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
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
                text("audio", "fontBigUI", "left", 10, 10, 1000),

                slider("master vol.", "fontBigUI",  0, 100, 10, 25, "masterVolPercentage"),

                slider("music vol.", "fontBigUI",  0, 100, 10, 40, "musicVolPercentage"),

                slider("sfx vol.", "fontBigUI",  0, 100, 10, 55, "sfxVolPercentage"),

                toggleButton("mute", "fontBigUI", 10, 70, 20, 70, "muteAudio"),

                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
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
                textButton("arena", "fontBigUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("levelselect")
                        self.owner:setBackgroundSlideAmount(0.5)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("gamemodes", "fontBigUI", 10, 25, 15, 25, function()
                end),

                textButton("unlocks", "fontBigUI", 10, 40, 15, 40, function()
                end),

                textButton("achievements", "fontBigUI", 10, 55, 15, 55, function()
                end),

                textButton("back", "fontBigUI", 10, 80, 15, 80, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                end)
            }
        },

        ["levelselect"] =
        {
            displayMenuName = false,
            
            elements =
            {
                textButton("arena 1", "fontBigUI", 10, 10, 15, 10, function(self)
                    game.manager:changePlayerDefinition("default definition")
                    game.manager.runSetup.level = level1
                    game.transitionManager:doTransition("gameLevelState")
                    self.owner.selectSound:play()
                end),

                textButton("arena 2", "fontBigUI", 10, 25, 15, 25, function(self)
                    --game.manager:changePlayerDefinition("default definition")
                    --game.manager.runSetup.level = level2
                    --game.transitionManager:doTransition("gameLevelState")
                end),

                textButton("WIPPITY WIP", "fontBigUI", 10, 40, 15, 40, function(self)
                end),

                textButton("wippy wippy wip", "fontBigUI", 10, 55, 15, 55, function(self)
                end),

                textButton("not done lol", "fontBigUI", 10, 70, 15, 70, function(self)
                end),

                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end)
            }
        },
    }

    self.tooltips =
    {
        ["start"] =
        {
            elements =
            {
                "",
                "",
            }
        },

        ["main"] =
        {
            elements =
            {
                "Choose a gamemode and play!",
                "Change the options",
                "View the credits",
                "View about the game and help",
                "Quit Switchblade",
            }
        },

        ["optionsSelect"] =
        {
            elements =
            {
                "Change screen and background options",
                "Change audio volume and mute",
                "Change gameplay options",
                "Change accessibility options",
            }
        },

        ["optionsGameplay"] =
        {
            elements = 
            {
                "Scale of the health ring surrounding the player",
                "Show a number for the player's health",
                "Center the camera on the player",
                "Show the current FPS",
                "Disable on-screen alerts for the timer"
            }
        },

        ["optionsAccessibility"] =
        {
            elements =
            {
                "Enable debug mode to show colliders and info",
                "Adds a cooldown between palette swaps",
                "Turns off screen shake",
                "Sets the intensity of the screen shake",
                "Disables angle changes for the screenshake",
                "Set the base camera zoom scale"
            }
        },

        ["optionsVisual"] =
        {
            elements =
            {
                text("visual", "fontBigUI", "left", 10, 10, 1000),

                toggleButton("fullscreen.", "fontBigUI", 10, 25, 20, 25, "enableFullscreen"),

                toggleButton("toggle bg.", "fontBigUI", 10, 40, 20, 40, "enableBackground"),

                slider("bg. fading", "fontBigUI", 0, 100, 10, 55, "fadingPercentage"),

                slider("bg. speed", "fontBigUI", 0, 100, 10, 70, "speedPercentage"),
                
                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
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
                text("audio", "fontBigUI", "left", 10, 10, 1000),

                slider("master vol.", "fontBigUI",  0, 100, 10, 25, "masterVolPercentage"),

                slider("music vol.", "fontBigUI",  0, 100, 10, 40, "musicVolPercentage"),

                slider("sfx vol.", "fontBigUI",  0, 100, 10, 55, "sfxVolPercentage"),

                toggleButton("mute", "fontBigUI", 10, 70, 20, 70, "muteAudio"),

                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
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
                textButton("arena", "fontBigUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("levelselect")
                        self.owner:setBackgroundSlideAmount(0.5)
                    end
                end),

                textButton("gamemodes", "fontBigUI", 10, 25, 15, 25, function()
                end),

                textButton("unlocks", "fontBigUI", 10, 40, 15, 40, function()
                end),

                textButton("achievements", "fontBigUI", 10, 55, 15, 55, function()
                end),

                textButton("back", "fontBigUI", 10, 80, 15, 80, function(self)
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
                textButton("arena 1", "fontBigUI", 10, 10, 15, 10, function()
                    game.manager:changePlayerDefinition("default definition")
                    game.manager.runSetup.level = level1
                    game.transitionManager:doTransition("gameLevelState")
                    self.owner.startSound:play()
                end),

                textButton("arena 2", "fontBigUI", 10, 25, 15, 25, function()
                    game.manager:changePlayerDefinition("default definition")
                    game.manager.runSetup.level = level2
                    game.transitionManager:doTransition("gameLevelState")
                    self.owner.startSound:play()
                end),

                textButton("WIPPITY WIP", "fontBigUI", 10, 40, 15, 40, function()
                end),

                textButton("wippy wippy wip", "fontBigUI", 10, 55, 15, 55, function()
                end),

                textButton("not done lol", "fontBigUI", 10, 70, 15, 70, function()
                end),

                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                        self.owner.backSound:play()
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

    self.eyePositionChangeCooldown = self.eyePositionChangeCooldown - (1 * dt)

    if self.eyePositionChangeCooldown <= 0 then
        self.eyePositionChangeCooldown = math.random(self.minEyePositionChangeCooldown, self.maxEyePositionChangeCooldown)
        self.targetEyePositionOffset = vec2:polar(math.random(self.minEyeOffset, self.maxEyeOffset), math.rad(math.random(0, 360)))
        self.targetPupilRadius = math.random(self.minPupilRadius, self.maxPupilRadius)
    end

    self.pupilRadius = math.lerpDT(self.pupilRadius, self.targetPupilRadius, self.pupilRadiusLerpRate, dt)

    self.eyePositionOffset.x = math.lerpDT(self.eyePositionOffset.x, self.targetEyePositionOffset.x, self.eyePositionLerpRate, dt)
    self.eyePositionOffset.y = math.lerpDT(self.eyePositionOffset.y, self.targetEyePositionOffset.y, self.eyePositionLerpRate, dt)

    if self.showEye then
        self.eyeOrigin.x = math.lerpDT(self.eyeOrigin.x, self.targetEyeOrigin.x, self.eyeOriginLerpRate, dt)
        self.eyeOrigin.y = math.lerpDT(self.eyeOrigin.y, self.targetEyeOrigin.y, self.eyeOriginLerpRate, dt)
    end
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

        if self.showEye then
            local x = self.eyeOrigin.x
            local y = self.eyeOrigin.y

            love.graphics.setColor(0, 0, 0, self.eyeAlpha)
            love.graphics.setLineWidth(50)
            love.graphics.circle("line", x, y, 150)

            love.graphics.stencil(function()
                local angle = ((self.eyeOrigin + self.eyePositionOffset) - self.eyeOrigin):angle()
                local normal = vec2(math.cos(angle), math.sin(angle))
                local pupilMask = self.eyeOrigin + self.eyePositionOffset + (normal * self.pupilRadius/2)

                love.graphics.circle("fill", pupilMask.x, pupilMask.y, self.pupilRadius/1.5)
            end, "replace", 1)

            love.graphics.setStencilTest("equal", 0)

            love.graphics.circle("fill", x + self.eyePositionOffset.x, y + self.eyePositionOffset.y, self.pupilRadius)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(1)
        end

        love.graphics.setStencilTest()
        self:drawOverlay()

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, self.backgroundScrollY)
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, self.backgroundScrollY - game.arenaValues.screenHeight)

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