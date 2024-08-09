local menu = require "src.menu.menu"
local textButton = require "src.interface.textbutton"
local spriteButton = require "src.interface.spritebutton"
local text = require "src.interface.text"
local toggleButton = require "src.interface.togglebutton"
local slider = require "src.interface.slider"
local gamemodeText = require "src.interface.gamemodetext"
local logo = require "src.menu.mainmenu.logo"
local list = require "src.interface.list"

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
    self.backgroundScrollX = 0
    self.backgroundScrollSpeed = 20

    -- Offset for the menu box sliding
    self.maxSideMenuBoxOffset = game.arenaValues.screenWidth
    self.minSideMenuBoxOffset = -150
    self.targetSideMenuBoxOffset = 0

    self.maxBottomMenuBoxOffset = -30
    self.minBottomMenuBoxOffset = 280
    self.targetBottomMenuBoxOffset = 280

    -- Initialise background rendering
    self.menuBackgroundSprite = game.resourceManager:getAsset("Interface Assets"):get("menuBackgroundMesh")
    self.menuBackgroundSpriteBottom = game.resourceManager:getAsset("Interface Assets"):get("menuBackgroundMeshBottom")
    game.canvases.menuBackgroundCanvas.enabled = true

    -- Initialise the box shader
    self.menuBoxShader = game.resourceManager:getAsset("Interface Assets"):get("shaders"):get("menuBoxShader")

    -- Initialise the box offset
    self.menuBoxOffset = self.minMenuBoxOffset
    self.sideMenuBoxOffset = self.minSideMenuBoxOffset
    self.bottomMenuBoxOffset = self.minBottomMenuBoxOffset

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
                        self.owner.startSound:play()
                    end
                end, true)
            },

            toolTips =
            {
                "",
                "",
            },

            boxSlideParams =
            {
                {boxName = "side", percentage = 0},
                {boxName = "bottom", percentage = 0},
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
                        self.owner.selectSound:play()
                    end
                end),

                textButton("achievements", "fontBigUI", 10, 25, 15, 25, function(self)
                end),

                textButton("help", "fontBigUI", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("help")
                        self.owner.selectSound:play()
                    end
                end),

                textButton("options", "fontBigUI", 10, 55, 15, 55, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner.selectSound:play()
                    end
                end),

                textButton("credits", "fontBigUI", 10, 70, 15, 70, function(self)
                    if self.owner then
                        self.owner:switchMenu("credits")
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 0.35},
                {boxName = "bottom", percentage = 0},
            },
        },

        ["optionsSelect"] =
        {
            elements =
            {
                textButton("Visual", "fontBigUI", 10, 10, 15, 10, function(self)
                    self.owner:switchMenu("optionsVisual")
                    self.owner.selectSound:play()
                end),

                textButton("Audio", "fontBigUI", 10, 25, 15, 25, function(self)
                    self.owner:switchMenu("optionsAudio")
                    self.owner.selectSound:play()
                end),

                textButton("Gameplay", "fontBigUI", 10, 40, 15, 40, function(self)
                    self.owner:switchMenu("optionsGameplay")
                    self.owner.selectSound:play()
                end),

                textButton("Accessibility", "fontBigUI", 10, 55, 15, 55, function(self)
                    self.owner:switchMenu("optionsAccessibility")
                    self.owner.selectSound:play()
                end),

                textButton("back", "fontBigUI", 10, 80, 15, 80, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 0.35},
                {boxName = "bottom", percentage = 0},
            },
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
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
                        self.owner.backSound:play()
                    end
                end),
            },

            toolTips =
            {
                "",
                "",
            },

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
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
                        self.owner.backSound:play()
                    end
                end),
            },

            toolTips =
            {
                "",
                "",
            },

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
        },

        ["gamemodeselect"] =
        {
            displayMenuName = false,

            menuDirection = "right",
            
            elements =
            {
                gamemodeText(self, {
                    {name = "", description = ""},
                    {name = "", description = ""},
                    {name = "Endless", description = "Defeat an endless barrage of enemies!"},
                    {name = "Rush", description = "Beat your high score within the time limit!"},
                    {name = "Denial", description = "Dodge the heatspots with your\ninvulnerable Switchblade as you\nblast your way to victory!"},
                    {name = "Chaos", description = "TO DO"},
                    {name = "Crowd", description = "Enemies in proximity to your\nSwitchblade heat it up!"},
                    {name = "Challenge", description = "Conquer a set of challenges\nand difficult bosses!"},
                }),
                
                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("back"), 5, 225, 5, 225, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner.backSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("endless"), 125, 225, 125, 225, function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("endless")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("rush"), 164, 225, 164, 225, function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("timed")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("denial"), 203, 225, 203, 225, function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("denial")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("chaos"), 242, 225, 242, 225, function(self)
                
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("crowd"), 281, 225, 281, 225, function(self)
                    if self.owner then
                        game.manager:changePlayerDefinition("default definition")
                        game.manager:setCurrentGamemode("crowd")
                        game.transitionManager:doTransition("gameLevelState")
                        self.owner.selectSound:play()
                    end
                end),

                spriteButton(game.resourceManager:getAsset("Interface Assets"):get("sprites"):get("gamemodes"):get("challenge"), 320, 225, 320, 225, function(self)
                    self.owner:switchMenu("levelselect")
                    self.owner.selectSound:play()
                    game.manager:setCurrentGamemode("gauntlet")
                end),
            },

            toolTips =
            {
                "",
                "",
                "",
                "",
                "",
                "",
            },

            boxSlideParams =
            {
                {boxName = "side", percentage = 0},
                {boxName = "bottom", percentage = 0.3},
            },

            onElementChange = function(menuObject)
                game.manager:swapPalette()
                menuObject.currentMenu.elements[1]:shake()
            end
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

            boxSlideParams =
            {
                {boxName = "side", percentage = 1},
                {boxName = "bottom", percentage = 0},
            },
        },
    }

    -- Switch to the main menu
    self:switchMenu("start")
    self:setBackgroundSlideAmount()
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
        self.backgroundScrollX = self.backgroundScrollX + self.backgroundScrollSpeed * dt

        if self.backgroundScrollY > game.arenaValues.screenHeight then
            self.backgroundScrollY = 0
        end

        if self.backgroundScrollX > game.arenaValues.screenWidth then
            self.backgroundScrollX = 0
        end
    end

    self.sideMenuBoxOffset = math.lerpDT(self.sideMenuBoxOffset, self.targetSideMenuBoxOffset, 0.2, dt)
    self.bottomMenuBoxOffset = math.lerpDT(self.bottomMenuBoxOffset, self.targetBottomMenuBoxOffset, 0.2, dt)
end

function mainMenu:setBackgroundSlideAmount()
    local boxSlideParams = self.currentMenu.boxSlideParams
    assert(boxSlideParams ~= nil, "Params for background box are nil!")

    for _, param in ipairs(boxSlideParams) do
        local boxName = param.boxName
        assert(boxName ~= "side" or boxName ~= "bottom", "Not a valid background box!")

        if boxName == "side" then
            local percentage = param.percentage or 0
            self.targetSideMenuBoxOffset = math.lerp(self.minSideMenuBoxOffset, self.maxSideMenuBoxOffset, percentage)
        elseif boxName == "bottom" then
            local percentage = param.percentage
            self.targetBottomMenuBoxOffset = math.lerp(self.minBottomMenuBoxOffset, self.maxBottomMenuBoxOffset, percentage)
        end
    end
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
        love.graphics.draw(self.menuBackgroundSprite, self.sideMenuBoxOffset + 5, self.backgroundScrollY)
        love.graphics.draw(self.menuBackgroundSprite, self.sideMenuBoxOffset + 5, self.backgroundScrollY - game.arenaValues.screenHeight)
        love.graphics.draw(self.menuBackgroundSpriteBottom, self.backgroundScrollX, self.bottomMenuBoxOffset - 5)
        love.graphics.draw(self.menuBackgroundSpriteBottom, self.backgroundScrollX - game.arenaValues.screenWidth, self.bottomMenuBoxOffset - 5)

        love.graphics.stencil(function()
            love.graphics.draw(self.menuBackgroundSprite, self.sideMenuBoxOffset, self.backgroundScrollY)
            love.graphics.draw(self.menuBackgroundSprite, self.sideMenuBoxOffset, self.backgroundScrollY - game.arenaValues.screenHeight)
            love.graphics.draw(self.menuBackgroundSpriteBottom, self.backgroundScrollX, self.bottomMenuBoxOffset)
            love.graphics.draw(self.menuBackgroundSpriteBottom, self.backgroundScrollX - game.arenaValues.screenWidth, self.bottomMenuBoxOffset)
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

function mainMenu:getMenuSubElements(menuName)
    menu.getMenuSubElements(self, menuName)
    self:setBackgroundSlideAmount()
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