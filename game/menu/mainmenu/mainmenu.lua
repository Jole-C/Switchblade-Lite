local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"
local slider = require "game.interface.slider"
local sprite = require "game.interface.sprite"
local rectangle = require "game.interface.rect"
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
                sprite("logo sprite", game.arenaValues.screenWidth/2, game.arenaValues.screenHeight/2 - 8, 0, 1, 1, 0, 0, true, game.manager.currentPalette.playerColour),

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
                rectangle(100, 10, 480, 230, "fill", {0.1, 0.1, 0.1, 0.8}),
                text("READ ME:\nWelcome to Switchblade!\nThings are rough and unfinished.\nOnly one level is done for now (and it has no\nwin condition).\nThe other levels are just level 1 with\nthe other ships.\n\nControls - Keyboard:\nW - thrust, A/D - steer, SPACE - fire, LSHIFT - boost\n\nControls - Gamepad:\nA - thrust, LBUMPER - boost, RBUMPER - fire\nLSTICK - steer\n\nBoosting into enemies restores ammo.\nBoosting for too long makes you overheat.\nSome enemies can only be killed by boosting.\nThere is no visual indicator for this yet.\n2/5 of the 5 enemies in the game are using\ndev art, but they have other visual differences.\nHave fun!", "font main", "left", 130, 10, 1000),

                textButton("start", "font ui", 10, 10, 15, 10, function(self)
                    if self.owner then
                        self.owner:switchMenu("gamemodeselect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end),

                textButton("options", "font ui", 10, 25, 15, 25, function(self)
                    if self.owner then
                        self.owner:switchMenu("optionsSelect")
                        self.owner:setBackgroundSlideAmount(0.35)
                    end
                end),

                textButton("quit", "font ui", 10, 50, 15, 50, function()
                    love.event.quit()
                end)
            }
        },

        ["optionsSelect"] =
        {
            elements =
            {
                textButton("Visual", "font ui", 10, 10, 15, 10, function(self)
                    self.owner:switchMenu("optionsVisual")
                    self.owner:setBackgroundSlideAmount(0.7)
                end),

                textButton("Audio", "font ui", 10, 25, 15, 25, function(self)
                    self.owner:switchMenu("optionsAudio")
                    self.owner:setBackgroundSlideAmount(0.7)
                end),

                textButton("Accessibility", "font ui", 10, 40, 15, 40, function(self)
                    
                end),

                textButton("back", "font ui", 10, 65, 15, 65, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                        self.owner:setBackgroundSlideAmount(0.32)
                    end
                end)
            }
        },

        ["optionsVisual"] =
        {
            elements =
            {
                text("visual", "font ui", "left", 10, 10, 1000),

                toggleButton("fullscreen.", "font ui", 10, 25, 20, 25, game.manager.options.enableFullscreen, {table = game.manager.options, value = "enableFullscreen"}),

                toggleButton("toggle bg.", "font ui", 10, 40, 20, 40, game.manager.options.enableBackground, {table = game.manager.options, value = "enableBackground"}),

                slider("bg. fading", "font ui", game.manager.options.fadingPercentage, 0, 100, 10, 55, {table = game.manager.options, value = "fadingPercentage"}),

                slider("bg. speed", "font ui", game.manager.options.speedPercentage, 0, 100, 10, 70, {table = game.manager.options, value = "speedPercentage"}),
                
                textButton("back", "font ui", 10, 95, 15, 95, function(self)
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
                text("audio", "font ui", "left", 10, 10, 1000),

                slider("music vol.", "font ui", game.manager.options.musicVolPercentage, 0, 100, 10, 25, {table = game.manager.options, value = "musicVolPercentage"}),

                slider("sfx vol.", "font ui", game.manager.options.sfxVolPercentage, 0, 100, 10, 40, {table = game.manager.options, value = "sfxVolPercentage"}),

                textButton("back", "font ui", 10, 65, 15, 65, function(self)
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
                    game.manager:changePlayerDefinition("default definition")
                    game.gameStateMachine:set_state("gameLevelState")
                end),

                textButton("level 2", "font ui", 10, 25, 15, 25, function()
                    game.manager:changePlayerDefinition("light definition")
                    game.gameStateMachine:set_state("gameLevelState")
                end),

                textButton("level 3", "font ui", 10, 40, 15, 40, function()
                    game.manager:changePlayerDefinition("heavy definition")
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
        local shaderSpeed = game.manager.options.speedPercentage / 100
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

        if self.backgroundScrollY > game.arenaValues.screenHeight - 20 then
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
        local enableBackground = game.manager.options.enableBackground

        if enableBackground == 1 then
            love.graphics.setShader(self.menuBackgroundShader)
            love.graphics.rectangle("fill", 0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
            love.graphics.setShader()
        end

        self:drawOverlay()

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, math.floor(self.backgroundScrollY))
        love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset + 5, math.floor(self.backgroundScrollY - game.arenaValues.screenHeight))

        -- Use the menu background as a stencil
        love.graphics.stencil(function()
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY))
            love.graphics.draw(self.menuBackgroundSprite, self.menuBoxOffset, math.floor(self.backgroundScrollY - game.arenaValues.screenHeight))
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
    local alpha = game.manager.options.fadingPercentage / 100
    love.graphics.setColor(0.1, 0.1, 0.1, alpha)
    love.graphics.rectangle("fill", -100, -100, game.arenaValues.screenWidth + 100, game.arenaValues.screenHeight + 100)
    love.graphics.setColor(1, 1, 1, 1)
end

function mainMenu:cleanup()
    game.canvases.menuBackgroundCanvas.enabled = false
end

return mainMenu