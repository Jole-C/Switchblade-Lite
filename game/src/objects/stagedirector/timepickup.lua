local gameObject = require "src.objects.gameobject"
local collider = require "src.collision.collider"
local timePickup = class({name = "Time Pickup", extends = gameObject})

function timePickup:new(x, y, secondsToAdd)
    self:super(x, y)
    self.secondsToAdd = secondsToAdd

    self.maxLifetime = 5
    self.lifetime = self.maxLifetime

    self.innerCircleRadius = 15
    self.outerCircleRadius = 20
    self.arcRadius = 25
    self.innerLineWidth = 3
    self.outerLineWidth = 2

    self.timeAddedSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("timeAdded")
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
    self.effect = game.particleManager:getEffect("Timer Stream")

    self.collider = collider(colliderDefinitions.none, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, self.innerCircleRadius * 2, self.innerCircleRadius * 2)
end

function timePickup:update(dt)
    self.lifetime = self.lifetime - (1 * dt)

    if self.lifetime <= 0 then
        self:destroy()
    end
    
    game.particleManager:burstEffect("Timer Stream", 5, self.position)
    self.effect.systems[1]:setColors(game.manager.currentPalette.playerColour)

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end        
    
    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY = world:getRect(self.collider)
        local x, y, cols, len = world:check(self.collider, colliderPositionX, colliderPositionY)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if not collidedObject or not colliderDefinition then
                goto continue
            end

            if colliderDefinition == colliderDefinitions.player then
                self:onPickup()
            end

            ::continue::
        end
    end
end

function timePickup:draw()
    self.effect:draw()

    love.graphics.setLineWidth(self.innerLineWidth)
    love.graphics.circle("line", self.position.x, self.position.y, self.innerCircleRadius)

    love.graphics.setLineWidth(self.outerLineWidth)
    love.graphics.circle("line", self.position.x, self.position.y, self.outerCircleRadius)

    local arcAngle = (2 * math.pi) - math.lerp(2 * math.pi, 0, self.lifetime / self.maxLifetime)
    local offset = math.pi / 2

    love.graphics.arc("line", "open", self.position.x, self.position.y, self.arcRadius, 0 + offset, arcAngle + offset)

    love.graphics.setLineWidth(1)

    local string = tostring(self.secondsToAdd)
    local width = self.font:getWidth(string)
    local height = self.font:getHeight(string)

    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.printf(string, self.position.x - width/2, self.position.y - height/2, width, "center")
end

function timePickup:onPickup()
    gameHelper:getCurrentState().stageDirector:addTime(0, self.secondsToAdd)
    gameHelper:screenShake(0.2)
    self.timeAddedSound:play()

    self:destroy()
    
    local explosionBurst = game.particleManager:getEffect("Explosion Burst")
    explosionBurst.systems[1]:setColors(game.manager.currentPalette.playerColour[1], game.manager.currentPalette.playerColour[2], game.manager.currentPalette.playerColour[3], 1)
    game.particleManager:burstEffect("Explosion Burst", 50, self.position)
end

function timePickup:cleanup()
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return timePickup