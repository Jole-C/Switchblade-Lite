require "src.misc.mathhelpers"
require "src.misc.tablehelpers"
local gameRenderer = require "src.render.renderer"
local resourceManager = require "src.resource.resourcemanager"
local interfaceRenderer = require "src.interface.interfacerenderer"
local gameManager = require "src.gamemanager"
local playerManager = require "src.objects.player.playermanager"
local particleManager = require "src.particlemanager"
local transitionManager = require "src.transition.transitionmanager"
local musicManager = require "src.music.musicmanager"

local gauntlet = require "src.gamemode.gauntlet"
local endless = require "src.gamemode.endless.endless"

colliderDefinitions = require "src.collision.colliderdefinitions"
scoreDefinitions = require "src.objects.score.scoredefinitions"

local game = class({name = "Game"})

function game:new()
    math.randomseed(os.time())

    -- Set up the arena values
    self.arenaValues =
    {
        screenWidth = 480,
        screenHeight = 270,
        worldX = -600,
        worldY = -600,
        worldWidth = 1200,
        worldHeight = 1200,
    }

    -- Load all services
    self.manager = gameManager()
    self.manager:setupPalettes(
    {
        main = love.image.newImageData("assets/sprites/mainpalettes.png"),
        boss = love.image.newImageData("assets/sprites/bosspalettes.png")
    })
    
    self.manager:swapPaletteGroup("main")
    self.manager:swapPalette()
    
    self.gameRenderer = gameRenderer()
    self.interfaceRenderer = interfaceRenderer()
    self.particleManager = particleManager()
    self.resourceManager = resourceManager()
    self.transitionManager = transitionManager()
    self.musicManager = musicManager()

    -- Set up resources
    self.tags = 
    {
        music = ripple.newTag(),
        sfx = ripple.newTag()
    }

    self:setupResources()

    self.musicManager:addTrack(
    {
        {sound = self.resourceManager:getAsset("Music"):get("level"):get("intro"), loopCount = 1},
        {sound = self.resourceManager:getAsset("Music"):get("level"):get("main"), loopCount = 1, loopPermanent = true},
    }, "levelMusic")

    self.musicManager:addTrack(
    {
        {sound = self.resourceManager:getAsset("Music"):get("boss"):get("intro"), loopCount = 1, loopPermanent = false},
        {sound = self.resourceManager:getAsset("Music"):get("boss"):get("main"), loopCount = 1, loopPermanent = true},
    }, "bossMusic")

    self.musicManager:addTrack(
    {
        {sound = self.resourceManager:getAsset("Music"):get("gameover"):get("main"), loopCount = 1, loopPermanent = true},
    }, "gameoverMusic")

    self.musicManager:addTrack(
    {
        {sound = self.resourceManager:getAsset("Music"):get("victory"):get("main"), loopCount = 1, loopPermanent = true},
    }, "victoryMusic")


    self.musicManager:getTrack("levelMusic"):start({fadeDuration = 0.5})

    -- Set up camera
    self.camera = gamera.new(0, 0, self.arenaValues.screenWidth, self.arenaValues.screenHeight)
    self.camera:setWindow(0, 0, self.arenaValues.screenWidth, self.arenaValues.screenHeight)

    self.playerManager = playerManager()

    -- Set up input
    self.input = baton.new{
        controls = {
            thrust = {'key:w', 'key:up', 'button:a'},
            reverseThrust = {'key:s', 'key:down', 'button:b'},
            steerLeft = {'key:a', 'key:left', 'axis:leftx-'},
            steerRight = {'key:d', 'key:right', 'axis:leftx+'},
            boost = {'key:lshift', 'key:rshift', 'button:leftshoulder'},
            shoot = {'key:space', 'button:rightshoulder'},
            menuUp = {'key:w', 'key:up', 'button:dpup'},
            menuDown = {'key:s', 'key:down', 'button:dpdown'},
            menuLeft = {'key:a', 'key:left', 'button:dpleft'},
            menuRight = {'key:d', 'key:right', 'button:dpright'},
            select = {'key:return', 'key:space', 'button:a'},
            pause = {'key:escape', 'button:start'},
        },
        joystick = love.joystick.getJoysticks()[1]
    }
    
    -- Set rendering
    self.fullscreenMode = self.manager:getOption("enableFullscreen")

    if self.manager:getOption("enableFullscreen") == true then
        local width, height = love.window.getDesktopDimensions()
        self.gameRenderer:setMode(width, height, {fullscreen = true})
    else
        local width, height = love.window.getDesktopDimensions()
        width = width * 0.7
        height = height * 0.7
        self.gameRenderer:setMode(width, height, {fullscreen = false})
    end

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    self.canvases = {
        backgroundCanvas = self.gameRenderer:addRenderCanvas("backgroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        backgroundShadowCanvas = self.gameRenderer:addRenderCanvas("backgroundShadowCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        foregroundShadowCanvas = self.gameRenderer:addRenderCanvas("foregroundShadowCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        lowerForegroundCanvas = self.gameRenderer:addRenderCanvas("lowerForegroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        foregroundCanvas = self.gameRenderer:addRenderCanvas("foregroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        upperForegroundCanvas = self.gameRenderer:addRenderCanvas("upperForegroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        menuBackgroundCanvas = self.gameRenderer:addRenderCanvas("menuBackgroundCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        interfaceCanvas = self.gameRenderer:addRenderCanvas("interfaceCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
        transitionCanvas = self.gameRenderer:addRenderCanvas("transitionCanvas", self.arenaValues.screenWidth, self.arenaValues.screenHeight),
    }

    self:setupParticles()

    -- Temporary particle system
    local bgCol = self.manager.currentPalette.backgroundColour
    self.ps = love.graphics.newParticleSystem(self.resourceManager:getAsset("Temp Assets"):get("particleSprite"), 10000)
    
    local ps = self.ps
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
    ps:setEmissionArea("uniform", 480, 270, 0, false)
    ps:setEmissionRate(1000)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(0, 0, 0, 0)
    ps:setLinearDamping(0, 0)
    ps:setParticleLifetime(1.7999999523163, 2.2000000476837)
    ps:setRadialAcceleration(0, 0)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 0)
    ps:setSizes(0, 2)
    ps:setSizeVariation(1)
    ps:setSpeed(1, 3)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.11967971920967)
    ps:setTangentialAcceleration(379.81402587891, 405.12814331055)
    ps:setParticleLifetime(1, 10)
    
    ps:start()  

    local system = self.particleManager:newEffect({ps}, nil, true)
    self.particleManager:addEffect(system, "Temp Background")

    self.manager:setupGamemodes(
    {
        ["gauntlet"] = gauntlet,
        ["endless"] = endless,
        ["defence"] = nil,
    })
end

function game:start()
    self.gameStateMachine = require "src.gamestates.gamestatemachine"
end

function game:update(dt)
    self.input:update()

    self.manager:update(dt)
    self.transitionManager:update(dt)
    self.musicManager:update(dt)

    if self.manager.isPaused or self.manager.gameFrozen then
        return
    end

    self.gameStateMachine:update(dt)
    self.playerManager:update(dt)

    local backgroundSystem = self.particleManager:getEffect("Temp Background")
    backgroundSystem.systems[1]:setColors(self.manager.currentPalette.backgroundColour[1], self.manager.currentPalette.backgroundColour[2], self.manager.currentPalette.backgroundColour[3], self.manager.currentPalette.backgroundColour[4])
    backgroundSystem:setUpdateRate(0.14 * self.manager:getOption("speedPercentage") / 100)

    if self.manager:getOption("muteAudio") == false then
        local masterVol = self.manager:getOption("masterVolPercentage") / 100
        self.tags.music.volume = 1 * (self.manager:getOption("musicVolPercentage") / 100) * masterVol
        self.tags.sfx.volume = 1 * (self.manager:getOption("sfxVolPercentage") / 100) * masterVol
    else
        self.tags.music.volume = 0
        self.tags.sfx.volume = 0
    end
    
    local fullscreenSetting = self.manager:getOption("enableFullscreen")

    if self.fullscreenMode ~= fullscreenSetting then
        if fullscreenSetting == true then
            local width, height = love.window.getDesktopDimensions()
            self.gameRenderer:setMode(width, height, {fullscreen = true})
        else
            local width, height = love.window.getDesktopDimensions()
            width = width * 0.7
            height = height * 0.7
            self.gameRenderer:setMode(width, height, {fullscreen = false})
        end

        self.fullscreenMode = fullscreenSetting
    end
    
    self.particleManager:update(dt)
end

function game:draw()
    self:drawBackground()
    self:drawForeground()
    self:drawInterface()
    self:drawTransition()

    self.gameRenderer:drawCanvases()
end

function game:drawBackground()
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the background
    love.graphics.setCanvas({self.canvases.backgroundCanvas.canvas, stencil = true})
    love.graphics.setBackgroundColor(self.manager.currentPalette.backgroundColour[5])
    love.graphics.setBlendMode("alpha")
    
    if self.manager:getOption("enableBackground") == true then
        self.particleManager:getEffect("Temp Background"):draw()
    else
        love.graphics.clear()
    end

    love.graphics.setStencilTest()
    love.graphics.setCanvas()

    -- Draw the background overlay
    love.graphics.setCanvas(self.canvases.backgroundShadowCanvas.canvas)
    love.graphics.clear()

    local alpha = self.manager:getOption("fadingPercentage") / 100
    love.graphics.setColor(0.1, 0.1, 0.1, alpha)
    love.graphics.rectangle("fill", -100, -100, self.arenaValues.screenWidth + 100, self.arenaValues.screenHeight + 100)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function game:drawForeground()
    -- Draw the shadows
    love.graphics.setCanvas(self.canvases.foregroundShadowCanvas.canvas)
    love.graphics.clear()
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.draw(self.canvases.foregroundCanvas.canvas, 2, 2)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)

    self.camera:draw(function()
        -- Draw the foreground
        love.graphics.setCanvas({self.canvases.foregroundCanvas.canvas, stencil = true})
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")

        self.gameStateMachine:draw()
        
        local currentGamestate = self.gameStateMachine:current_state()
        
        if currentGamestate.objects then
            for key, object in ipairs(currentGamestate.objects) do
                object:draw()
            end
        end

        if currentGamestate.world and self.manager:getOption("enableDebugMode") then
            local items = currentGamestate.world:getItems()

            for i = 1, #items do
                local item = items[i]

                if item then
                    local x, y, w, h = currentGamestate.world:getRect(item)

                    love.graphics.rectangle("line", x, y, w, h)
                end
            end
        end

        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1, 1)

        self:drawParticles()
        love.graphics.setStencilTest()
    end)
end

function game:drawInterface()
    -- Draw the interface
    love.graphics.setCanvas(self.canvases.interfaceCanvas.canvas)
    love.graphics.clear()
    self.interfaceRenderer:draw()

    love.graphics.setFont(self.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain"))
    
    if self.manager:getOption("enableDebugMode") or self.manager:getOption("showFPS") then
        love.graphics.print(tostring(love.timer.getFPS()), 10, 250)
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
end

function game:drawTransition()
    love.graphics.setCanvas(self.canvases.transitionCanvas.canvas)
    love.graphics.clear()
    self.transitionManager:draw()
    love.graphics.setCanvas()
end

function game:drawParticles()
    self.particleManager:draw()
end

function game:setupResources()
    local assetGroup = require "src.resource.assetgroup"
    local randomAssetGroup = require "src.resource.randomassetgroup"
    local resourceManager = self.resourceManager

    resourceManager:addAsset(assetGroup(
    {
        level = assetGroup(
        {
            intro = {path = "assets/audio/music/songintro.wav", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
            main = {path = "assets/audio/music/songloop.wav", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
        }),

        boss = assetGroup(
        {
            intro = {path = "assets/audio/music/bossintro.mp3", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
            main = {path = "assets/audio/music/bossloop.mp3", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
            dead = {path = "assets/audio/music/bossend.mp3", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
        }),

        gameover = assetGroup(
        {
            main = {path = "assets/audio/music/gameover.mp3", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
        }),

        victory = assetGroup(
        {
            main = {path = "assets/audio/music/victory.mp3", type = "Source", parameters = {type = "stream", tag = self.tags.music}},
        })
    }), "Music")

    resourceManager:addAsset(assetGroup(
    {
        sprites = assetGroup(
        {
            playerSprite = {path = "assets/sprites/player/player.png", type = "Image"}
        }),

        sounds = assetGroup(
        {
            boost = {path = "assets/audio/sfx/defaultboost.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            boostFail = {path = "assets/audio/sfx/boostfail.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            fire = {path = "assets/audio/sfx/defaultfire.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            shipHurt = {path = "assets/audio/sfx/shiphurt.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            overheatWarning = {path = "assets/audio/sfx/overheatwarning.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            shipOverheat = {path = "assets/audio/sfx/overheat.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            boostHit = {path = "assets/audio/sfx/boosthit.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            deathExplosion = {path = "assets/audio/sfx/playerdeath.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            deathTrigger = {path = "assets/audio/sfx/playerdeathtrigger.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            wallHit = {path = "assets/audio/sfx/wallhit.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            oneUp = {path = "assets/audio/sfx/oneup.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        })
    }), "Player Assets")

    resourceManager:addAsset(assetGroup(
    {
        wanderer = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/wanderer.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/wanderertail.png", type = "Image"}
        }),

        charger = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/charger.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/chargertail.png", type = "Image"}
        }),

        drone = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/drone.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/wanderertail.png", type = "Image"}
        }),

        shielder = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/shieldereye.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/shieldertail.png", type = "Image"},
            segmentSprite = {path = "assets/sprites/enemy/shieldersegment.png", type = "Image"},
            warningSprite = {path = "assets/sprites/enemy/shielderwarning.png", type = "Image"},
        }),

        orbiter = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/orbiter.png", type = "Image"},
            laserSprite = {path = "assets/sprites/player/playerlaser.png", type = "Image"}
        }),

        sticker = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/sticker.png", type = "Image"},
        }),

        crisscross = assetGroup(
        {
            bodySprite = {path = "assets/sprites/enemy/crisscross.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/crisscrosstail.png", type = "Image"},
            chargeSound = {path = "assets/audio/sfx/crisscrosscharge.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        }),

        snake = assetGroup(
        {
            warningSprite = {path = "assets/sprites/enemy/snakehead.png", type = "Image"},
            headSprite = {path = "assets/sprites/enemy/snakehead.png", type = "Image"},
            bodySprite = {path = "assets/sprites/enemy/snakesegment.png", type = "Image"},
            bodySpriteNoEye = {path = "assets/sprites/enemy/snakesegmentnoeye.png", type = "Image"},
            tailSprite = {path = "assets/sprites/enemy/snaketail.png", type = "Image"},
            spawnSound = {path = "assets/audio/sfx/snakespawn.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            hurtSound = {path = "assets/audio/sfx/snakehurt.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            deathSound = {path = "assets/audio/sfx/snakedeath.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        }),

        boss1 = assetGroup(
        {
            sprites = assetGroup(
            {
                orb = {path = "assets/sprites/enemy/boss1/orb.png", type = "Image"},
                core = {path = "assets/sprites/enemy/boss1/core.png", type = "Image"},
                mandible = {path = "assets/sprites/enemy/boss1/mandible.png", type = "Image"},
                tail1 = {path = "assets/sprites/enemy/boss1/tail1.png", type = "Image"},
                tail2 = {path = "assets/sprites/enemy/boss1/tail2.png", type = "Image"},
                spike = {path = "assets/sprites/enemy/boss1/spike.png", type = "Image"},
                laserOuter = {path = "assets/sprites/enemy/boss1/laserouter.png", type = "Image"},
                laserInner = {path = "assets/sprites/enemy/boss1/laserinner.png", type = "Image"},
            }),

            sounds = assetGroup(
            {
                spawn = {path = "assets/audio/sfx/boss1spawn.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                hurt = {path = "assets/audio/sfx/boss1hurt.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                fire = {path = "assets/audio/sfx/heavyfire.wav", type = "Source", parameters = {tag = self.tags.sfx}},

                laserCharge = {path = "assets/audio/sfx/boss1lasercharge.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                laserFire = {path = "assets/audio/sfx/boss1laser.wav", type = "Source", parameters = {tag = self.tags.sfx}},

                randomSounds = randomAssetGroup(
                {
                    sound1 = {path = "assets/audio/sfx/boss1sound1.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                    sound2 = {path = "assets/audio/sfx/boss1sound1.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                    sound3 = {path = "assets/audio/sfx/boss1sound1.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                })
            })
        }),

        boss2 = assetGroup(
        {
            sprites = assetGroup(
            {
               metaball = {path = "assets/sprites/enemy/boss2/ball.png", type = "Image"},
            }),

            shaders = assetGroup(
            {
                metaballThreshold = love.graphics.newShader("assets/shaders/metaballthreshold.glsl"),
                metaballBlend = love.graphics.newShader("assets/shaders/metaballblend.glsl"),
            })
        }),

        deathSounds = randomAssetGroup(
        {
            enemyHit1 = {path = "assets/audio/sfx/enemyhit1.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            enemyHit2 = {path = "assets/audio/sfx/enemyhit2.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            enemyHit3 = {path = "assets/audio/sfx/enemyhit3.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            enemyHit4 = {path = "assets/audio/sfx/enemyhit4.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            enemyHit5 = {path = "assets/audio/sfx/enemyhit5.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        }),

        spawnSounds = assetGroup(
        {
            spawn = {path = "assets/audio/sfx/enemyspawn.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            warning = {path = "assets/audio/sfx/spawnwarning.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        }),

        damageSound = {path = "assets/audio/sfx/enemydamage.wav", type = "Source", parameters = {tag = self.tags.sfx}},

        bossExplosionSounds = assetGroup(
        {
            endExplosion = {path = "assets/audio/sfx/bossexplosionend.wav", type = "Source", parameters = {tag = self.tags.sfx}},

            midExplosion = randomAssetGroup(
            {
                explosion1 = {path = "assets/audio/sfx/bossexplosion1.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                explosion2 = {path = "assets/audio/sfx/bossexplosion2.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                explosion3 = {path = "assets/audio/sfx/bossexplosion3.wav", type = "Source", parameters = {tag = self.tags.sfx}},
                explosion4 = {path = "assets/audio/sfx/bossexplosion4.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            })
        }),

        enemyOutlineShader = love.graphics.newShader("assets/shaders/outline.glsl")
    }), "Enemy Assets")

    resourceManager:addAsset(assetGroup(
    {
        particleSprite = {path = "assets/sprites/particlesprite.png", type = "Image"}
    }), "Temp Assets")

    resourceManager:addAsset(assetGroup(
    {
        fonts = assetGroup(
        {
            fontMain = {path = "assets/fonts/font.png", type = "Image Font", parameters = {glyphs = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:,;()!?-/+", spacing = 1}},
            fontUI = {path = "assets/fonts/fontui.png", type = "Image Font", parameters = {glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,/%!?:0123456789 ", spacing = 2}},
            fontBigUI = {path = "assets/fonts/fontuibig.png", type = "Image Font", parameters = {glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,/%!?:0123456789 ", spacing = 2}},
            fontAlert = {path = "assets/fonts/kenneyrocketsquare.ttf", type = "Font", parameters = {size = 48}},
            fontTime = {path = "assets/fonts/timefont.png", type = "Image Font", parameters = {glyphs = "0123456789:x", spacing = 2}},
            fontScore = {path = "assets/fonts/scorefont.png", type = "Image Font", parameters = {glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+*?! ", spacing = 1}}
        }),

        sprites = assetGroup(
        {
            selectedBox = {path = "assets/sprites/interface/selectedbox.png", type = "Image"},
            unselectedBox = {path = "assets/sprites/interface/unselectedbox.png", type = "Image"},
            logoTextSwitch = {path = "assets/sprites/interface/logotext_switch.png", type = "Image"},
            logoTextBlade = {path = "assets/sprites/interface/logotext_blade.png", type = "Image"},
            logoShip = {path = "assets/sprites/interface/logoship.png", type = "Image"},
            warning = {path = "assets/sprites/interface/warning/warning.png", type = "Image"},
            cautionStrip = {path = "assets/sprites/interface/warning/cautionstrip.png", type = "Image", parameters = {wrapX = "repeat", wrapY = "repeat"}},
            bossHealth = {path = "assets/sprites/interface/bosshealth.png", type = "Image"},
            bossHealthOutline = {path = "assets/sprites/interface/bosshealthoutline.png", type = "Image"},
            bossEyeOutline = {path = "assets/sprites/interface/bosseyeoutline.png", type = "Image"},
            gameover = {path = "assets/sprites/interface/gameover.png", type = "Image"},
            gameoverOutline = {path = "assets/sprites/interface/gameoveroutline.png", type = "Image"},
            victory = {path = "assets/sprites/interface/victory.png", type = "Image"},
            victoryOutline = {path = "assets/sprites/interface/victoryoutline.png", type = "Image"},
            clock = {path = "assets/sprites/interface/clock.png", type = "Image"},
            skull = {path = "assets/sprites/interface/skull.png", type = "Image"},
        }),

        sounds = assetGroup(
        {
            bossWarningBoom = {path = "assets/audio/sfx/bosswarningboom.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            bossWarningSiren = {path = "assets/audio/sfx/bosswarningsiren.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            timeSiren = {path = "assets/audio/sfx/timewarning.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            menuUp = {path = "assets/audio/sfx/menuup.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            menuDown = {path = "assets/audio/sfx/menudown.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            menuSelect = {path = "assets/audio/sfx/menuselect.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            menuBack = {path = "assets/audio/sfx/menuback.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            gameStart = {path = "assets/audio/sfx/gamestart.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            gameoverBlam = {path = "assets/audio/sfx/gameoverblam.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            scoreBlast = {path = "assets/audio/sfx/scoreblast.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            scoreBlastEnd = {path = "assets/audio/sfx/scoreblastend.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            victoryIntro = {path = "assets/audio/sfx/victoryintro.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            multiplierReset = {path = "assets/audio/sfx/multiplierreset.wav", type = "Source", parameters = {tag = self.tags.sfx}},
            timeAdded = {path = "assets/audio/sfx/timeadded.wav", type = "Source", parameters = {tag = self.tags.sfx}},
        }),

        shaders = assetGroup(
        {
            maskShader = love.graphics.newShader("assets/shaders/mask.glsl"),

            menuBoxShader = love.graphics.newShader("assets/shaders/psychedelicstripes.glsl"),

            menuBackgroundShader = love.graphics.newShader("assets/shaders/rainbowstripes.glsl")
        })
    }), "Interface Assets")

    -- Set up the mesh with given parameters
    local numberOfVertices = 10
    local baseVertexX = 100
    local mesh = love.graphics.newMesh(2 + numberOfVertices + 1, "fan")

    -- Create a table to hold the vertices, and insert the top left vertex
    local vertices = {
        {-self.arenaValues.screenWidth, 0, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1},
    }
    
    -- Generate the zigzag vertex pattern
    local generateInnerVertex = false

    for i = 0, numberOfVertices do
        generateInnerVertex = not generateInnerVertex

        local vertexXoffset = 0
        
        if generateInnerVertex == false then
            vertexXoffset = 27
        end

        local vertexX = baseVertexX + vertexXoffset
        local vertexY = (self.arenaValues.screenHeight / numberOfVertices) * i
        
        table.insert(vertices, {vertexX, vertexY, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})
    end

    -- Insert a vertex at the bottom left position
    table.insert(vertices, {-self.arenaValues.screenWidth, self.arenaValues.screenHeight, 0, 0, backgroundMeshColour, backgroundMeshColour, backgroundMeshColour, 1})

    -- Set the vertices and register the resource with the resource manager
    mesh:setVertices(vertices)
    resourceManager:getAsset("Interface Assets"):add(mesh, "menuBackgroundMesh")
end

function game:setupParticles()
    local circleFill = love.graphics.newCanvas(16, 16)
    love.graphics.setCanvas(circleFill)
    love.graphics.circle("fill", 8, 8, 8)
    love.graphics.setCanvas()

    local circleLine = love.graphics.newCanvas(16, 16)
    love.graphics.setCanvas(circleLine)
    love.graphics.circle("line", 8, 8, 8)
    love.graphics.setCanvas()
    
    local explosionDust = love.graphics.newParticleSystem(circleFill, 500)
    explosionDust:setColors(1, 1, 1, 1)
    explosionDust:setDirection(-1.5707963705063)
    explosionDust:setEmissionArea("none", 0, 0, 0, false)
    explosionDust:setEmitterLifetime(-1)
    explosionDust:setInsertMode("top")
    explosionDust:setParticleLifetime(0.3, 0.6)
    explosionDust:setSizes(2, 0)
    explosionDust:setSpeed(50, 200)
    explosionDust:setSpread(6.2831854820251)
    
    local explosionBoom = love.graphics.newParticleSystem(circleFill, 100)
    explosionBoom:setColors(1, 1, 1, 1)
    explosionBoom:setDirection(-1.5707963705063)
    explosionBoom:setEmissionArea("none", 0, 0, 0, false)
    explosionBoom:setEmitterLifetime(-1)
    explosionBoom:setInsertMode("top")
    explosionBoom:setParticleLifetime(0.2)
    explosionBoom:setSizes(5, 0)
    explosionBoom:setSpin(0, 0.012826885096729)
    explosionBoom:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({explosionDust, explosionBoom}, self.canvases.foregroundCanvas.canvas, false), "Explosion")
    self.particleManager:addEffect(self.particleManager:newEffect({explosionDust}, self.canvases.foregroundCanvas.canvas, false), "Enemy Hit")

    local bossIntroBurst = love.graphics.newParticleSystem(circleFill, 1000)
    bossIntroBurst:setColors(1, 1, 1, 1)
    bossIntroBurst:setDirection(-1.5707963705063)
    bossIntroBurst:setEmissionArea("none", 0, 0, 0, false)
    bossIntroBurst:setEmitterLifetime(-1)
    bossIntroBurst:setInsertMode("top")
    bossIntroBurst:setParticleLifetime(0.25)
    bossIntroBurst:setSizes(3, 0)
    bossIntroBurst:setSpeed(269.98336791992, 891.73107910156)
    bossIntroBurst:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({bossIntroBurst}, self.canvases.foregroundCanvas.canvas, true), "Boss Intro Burst")

    local bossDeath = love.graphics.newParticleSystem(circleFill, 1000)
    bossDeath:setColors(1, 1, 1, 1)
    bossDeath:setDirection(-1.5707963705063)
    bossDeath:setEmissionArea("none", 0, 0, 0, false)
    bossDeath:setEmitterLifetime(-1)
    bossDeath:setInsertMode("top")
    bossDeath:setParticleLifetime(0.5, 1)
    bossDeath:setSizes(6, 0)
    bossDeath:setSpeed(100.98336791992, 800.73107910156)
    bossDeath:setRadialAcceleration(-200, -100)
    bossDeath:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({bossDeath}, self.canvases.foregroundCanvas.canvas, false), "Boss Death")

    local explosionBurst = love.graphics.newParticleSystem(circleFill, 1000)
    explosionBurst:setColors(1, 1, 1, 1)
    explosionBurst:setDirection(-1.5707963705063)
    explosionBurst:setEmissionArea("none", 0, 0, 0, false)
    explosionBurst:setEmitterLifetime(-1)
    explosionBurst:setInsertMode("top")
    explosionBurst:setParticleLifetime(0.1, 0.25)
    explosionBurst:setSizes(2, 0)
    explosionBurst:setSpeed(269.98336791992, 891.73107910156)
    explosionBurst:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({explosionBurst}, self.canvases.foregroundCanvas.canvas, false), "Explosion Burst")

    local playerSmoke = love.graphics.newParticleSystem(circleFill, 5)
    playerSmoke:setColors(1, 1, 1, 1)
    playerSmoke:setDirection(-1.5707963705063)
    playerSmoke:setEmissionArea("none", 0, 0, 0, false)
    playerSmoke:setEmitterLifetime(-1)
    playerSmoke:setInsertMode("top")
    playerSmoke:setParticleLifetime(0.25, 0.5)
    playerSmoke:setSizes(1.5, 0)
    playerSmoke:setSpeed(50, 100)
    playerSmoke:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({playerSmoke}, self.canvases.foregroundCanvas.canvas, false), "Player Smoke")
    
    local playerDeath = love.graphics.newParticleSystem(circleFill, 1000)
    playerDeath:setColors(1, 1, 1, 1)
    playerDeath:setDirection(-1.5707963705063)
    playerDeath:setEmissionArea("none", 0, 0, 0, false)
    playerDeath:setEmitterLifetime(-1)
    playerDeath:setInsertMode("top")
    playerDeath:setParticleLifetime(0.25)
    playerDeath:setSizes(3, 0)
    playerDeath:setSpeed(269.98336791992, 891.73107910156)
    playerDeath:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({playerDeath}, self.canvases.foregroundCanvas.canvas, false), "Player Death")

    local stream = love.graphics.newParticleSystem(circleFill, 1000)
    stream:setColors(1, 1, 1, 1)
    stream:setDirection(-1.5707963705063)
    stream:setEmissionArea("none", 0, 0, 0, false)
    stream:setEmitterLifetime(-1)
    stream:setInsertMode("top")
    stream:setParticleLifetime(0.05, 0.15)
    stream:setSizes(2, 0)
    stream:setSpeed(269.98336791992, 891.73107910156)
    stream:setSpread(6.2831854820251)
    
    self.particleManager:addEffect(self.particleManager:newEffect({stream}, self.canvases.foregroundCanvas.canvas, false), "Stream")
end

return game