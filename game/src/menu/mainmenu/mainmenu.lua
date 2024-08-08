local menu = require "src.menu.menu"
local textButton = require "src.interface.textbutton"
local spriteButton = require "src.interface.spritebutton"
local text = require "src.interface.text"
local toggleButton = require "src.interface.togglebutton"
local slider = require "src.interface.slider"
local sprite = require "src.interface.sprite"
local logo = require "src.menu.mainmenu.logo"
local rectangle = require "src.interface.rect"

local level1 = require "src.levels.level1"
local boss1 = require "src.levels.boss1"
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

    self.paletteImage = game.resourceManager:getAsset("Palettes"):get("mainPalette")

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
            },

            toolTips =
            {
                "",
                "",
            },
            
            backgroundSlideAmount = 0,
        },

        ["main"] =
        {
            displayMenuName = false,
            
            elements =
            {
                textButton("start", "fontBigUI", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("achievements", "fontBigUI", 10, 25, 15, 25, function(self)
                end),

                textButton("help", "fontBigUI", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("help")
                        self.owner:setBackgroundSlideAmount(0.7)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("options", "fontBigUI", 10, 55, 15, 55, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.35)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("credits", "fontBigUI", 10, 70, 15, 70, function(self)
                    if self.owner then
                        self.owner:switchMenu("credits")
                        self.owner:setBackgroundSlideAmount(0.7)
                        self.owner.selectSound:play()
                    end
                end),

                textButton("about", "fontBigUI", 10, 85, 15, 85, function(self)
                end),

                textButton("quit", "fontBigUI", 10, 110, 15, 110, function()
                    love.event.quit()
                end),

                text("demo v0.4", "fontUI", "left", 10, 250, 500, 0, 1, 1, false, {0.4, 0.4, 0.4, 1})
            },
            
            toolTips =
            {
                "Choose a gamemode and play!",
                "View achievements",
                "View a quick guide on how to play",
                "Change the options",
                "View the credits",
                "About Switchblade, version etc",
                "Quit Switchblade",
            },
            
            backgroundSlideAmount = 0.35,
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
            },
            
            toolTips =
            {
                "Change screen and background options",
                "Change audio volume and mute",
                "Change gameplay options",
                "Change accessibility options",
                "",
            },
            
            backgroundSlideAmount = 0.35,
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
            },
            
            toolTips =
            {
                "",
                "Scale of the health ring surrounding the player",
                "Show a number for the player's health",
                "Center the camera on the player",
                "Show the current FPS",
                "Disable on-screen alerts for the timer",
                "",
            },
            
            backgroundSlideAmount = 1,
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
            },
            
            toolTips =
            {
                "",
                "Enable debug mode to show colliders and info",
                "Adds a cooldown between palette swaps",
                "Turns off screen shake",
                "Sets the intensity of the screen shake",
                "Disables angle changes for the screenshake",
                "Set the base camera zoom scale",
                ""
            },
            
            backgroundSlideAmount = 1,
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
            },
            
            toolTips =
            {
                "",
                "Toggle fullscreen",
                "Toggle the background",
                "Add a grey overlay on top of the background",
                "Slow down the background",
                "",
            },
            
            backgroundSlideAmount = 1,
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
            },
            
            toolTips =
            {
                "",
                "Change the volume of all audio",
                "Change the volume of the music",
                "Change the volume of the sound effects",
                "Mute all audio",
                "",
            },
            
            backgroundSlideAmount = 1,
        },

        ["credits"] =
        {
            displayMenuName = false,

            elements =
            {
                text([[
                    "Programming art and sound effects:
                    Noba
                    
                    Music:
                    SuperSMZ on Twitter
                    
                    Libraries - GitHub:
                    Ripple and Baton by Tesselode
                    Batteries by 1bardesign
                    Bump and Gamera by Kikito
                    
                    Special thanks:
                    Gimblll, Nextop, JShip, Josh, Shadow, 
                    String, the LOVE2D Discord server and
                    whoever else I'm forgetting for their 
                    helpful feedback
                    Centuri for keeping me motivated and for putting up with
                    my hyperfixations
                    All my friends and family for supporting me throughout
                    development of this project
                    This game wouldn't be here without you all.
                    Thank you so much!"]], "fontMain", "left", -70, 10, 1000),

                textButton("back", "fontBigUI", 10, 230, 10, 230, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                end),
            },

            toolTips =
            {
                "",
                "",
            },
            
            backgroundSlideAmount = 1,
        },

        ["help"] =
        {
            displayMenuName = false,

            elements =
            {
                text([[
                    "Welcome to Switchblade!
                    
                    I dunno what the story of this game is
                    but I'm sure it's really cool.
                    
                    Standard asteroid controls, steer left and right
                    and thrust. You can boost too, and fire bullets.
                    
                    Ramming into enemies with your boost gives you ammo back.
                    
                    Boosting adds heat to your heat gauge. If you
                    overheat you instantly die, don't do that.
                        
                    The aim of the game is to be fast. Never stop moving.

                    Ramming enemies increases your multiplier, and
                    shooting them applies that multiplier to score.

                    Controls - Keyboard:
                    A/D - Steer, W - Thrust, 
                    Space - Fire, Shift - Boost

                    Controls - Gamepad:
                    Left Thumbstick - Steer, A - Thrust, 
                    Left Bumper - Boost, Right Bumper - Fire
                    
                    Have fun!"]], "fontMain", "left", -70, 10, 1000),

                textButton("back", "fontBigUI", 10, 230, 10, 230, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                end),
            },

            toolTips =
            {
                "",
                "",
            },
            
            backgroundSlideAmount = 1,
        },

        ["gamemodeselect"] =
        {
            displayMenuName = false,
            
            elements =
            {
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("endless"), 32, 16, 32, 16,
                function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("endless")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("rush"), 192, 16, 192, 16,
                function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("timed")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),
                
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("denial"), 352, 16, 352, 16,
                function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("denial")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),
                
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("crowd"), 32, 120, 32, 120,
                function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("crowd")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),
                
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("chaos"), 192, 120, 192, 120,
                function(self)
                
                end),
                
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("challenge"), 352, 120, 352, 120,
                function(self)
                    if self.owner then
                        self.owner:switchMenu("levelselect")
                        self.owner:setBackgroundSlideAmount(0.5)
                        self.owner.selectSound:play()
                        game.manager:setCurrentGamemode("gauntlet")
                    end
                end),

                textButton("back", "fontBigUI", 10, 230, 10, 230, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                        self.owner.backSound:play()
                    end
                end)
            },
            
            toolTips =
            {
                "Get a high score against a barrage of enemies!",
                "Try to beat your high score within the time limit!",
                "You're invincible but areas will make you overheat.\nGet a high score within the time limit!",
                "Lots of enemies spawn - Nearby enemies make you overheat!\nGet a high score within the time limit!",
                "To Do",
                "Conquer a set of difficult challenges and bosses!",
                "",
            },
            
            backgroundSlideAmount = 1,
        },

        ["levelselect"] =
        {
            displayMenuName = false,
            
            elements =
            {
                textButton("...", "fontBigUI", 10, 10, 15, 10, function(self)
                end),

                textButton("boss 1", "fontBigUI", 10, 25, 15, 25, function(self)
                    game.manager:changePlayerDefinition("default definition")
                    game.manager.runSetup.level = boss1
                    game.transitionManager:doTransition("gameLevelState")
                    self.owner.selectSound:play()
                end),

                textButton("...", "fontBigUI", 10, 40, 15, 40, function(self)
                end),

                textButton("...", "fontBigUI", 10, 55, 15, 55, function(self)
                end),

                textButton("...", "fontBigUI", 10, 70, 15, 70, function(self)
                end),

                textButton("back", "fontBigUI", 10, 95, 15, 95, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end)
            },

            toolTips =
            {
                "Do something cool",
                "Defeat the boss within the time limit!",
                "Touch your toes",
                "Do a cool flip",
                "Do something fancy",
                "",
            },
                
            backgroundSlideAmount = 1,
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

        self.menuBackgroundShader:send("paletteTexture", self.paletteImage)
        self.menuBackgroundShader:send("paletteIndex", game.manager.currentPaletteIndex)
        self.menuBackgroundShader:send("paletteResolution", {self.paletteImage:getWidth(), self.paletteImage:getHeight()})
        self.menuBackgroundShader:send("resolution", resolution)
        self.menuBackgroundShader:send("time", self.shaderTime)

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

function mainMenu:setBackgroundSlideAmount()
    local percentage = self.currentMenu.backgroundSlideAmount or 0
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