local boss = require "src.objects.enemy.boss.boss"
local states = require "src.objects.enemy.boss.boss2.statetree"

local boss2 = class({name = "Boss 2", extends = boss})

function boss2:new(x, y)
    self.bossName = "boss 2 name"
    self.bossSubtitle = "some subtitle"
    
    self:super(x, y)
    self.states = states

    self.canvasValues =
    {
        x = game.arenaValues.worldX,
        y = game.arenaValues.worldY,
        width = game.arenaValues.worldWidth,
        height = game.arenaValues.worldHeight,
    }

    self.metaballCanvas = love.graphics.newCanvas(self.canvasValues.width, self.canvasValues.height)

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("boss2")
    self.thresholdShader = assets:get("shaders"):get("metaballThreshold")
    self.blendShader = assets:get("shaders"):get("metaballBlend")
    self.metaballSprite = assets:get("sprites"):get("metaball")

    self.st = 0
    self.s = 0
    self.sa = 100
    self.sf = 1
end

function boss2:update(dt)
	self.st = self.st + self.sf * dt

	self.s = math.sin(self.st) * self.sa

    boss.update(self, dt)
end

function boss2:draw()
    love.graphics.setScissor()
    love.graphics.setCanvas(self.metaballCanvas)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setShader(self.blendShader)
    love.graphics.clear()

    local offsetX = self.metaballSprite:getWidth() / 2
    local offsetY = self.metaballSprite:getHeight() / 2
    love.graphics.draw(self.metaballSprite, 600 + self.s - offsetX, 600 - offsetY)
    love.graphics.draw(self.metaballSprite, 600 - self.s - offsetX, 600 - offsetY)

    love.graphics.pop()

    love.graphics.setCanvas({game.canvases.foregroundCanvas.canvas, stencil = true})
    gameHelper:getArena():setArenaStencil()
    gameHelper:getArena():setArenaStencilTest()

    love.graphics.setShader(self.thresholdShader)
    love.graphics.draw(self.metaballCanvas, self.canvasValues.x, self.canvasValues.y)
    love.graphics.setShader()
end

function boss2:cleanup(destroyReason)
    self.thresholdCanvas:release()
    self.blendCanvas:release()
end

function boss2:toCanvasSpace(position)
    return vec2(position.x + self.canvasValues.width / 2, position.y + self.canvasValues.height / 2)
end

return boss2