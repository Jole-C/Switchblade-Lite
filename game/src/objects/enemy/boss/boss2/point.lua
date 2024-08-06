local gameObject = require "src.objects.gameobject"
local point = class({name = "Metaball Attraction Point", extends = gameObject})
local eye = require "src.objects.enemy.enemyeye"


function point:new(x, y)
    self:super(x, y)

    self.eyeDistance = 7
    self.eyeRadius = 15

    self.averagePosition = vec2(0, 0)
    self.attractedMetaballs = {}

    self.maxInvulnerableTime = 0.05
    self.invulnerableTime = 0

    self.eye = eye(self.position.x, self.position.y, self.eyeDistance, self.eyeRadius, true)
end

function point:update(dt)
    for _, metaball in ipairs(self.attractedMetaballs) do
        self.averagePosition.x = self.averagePosition.x + metaball.position.x
        self.averagePosition.y = self.averagePosition.y + metaball.position.y
    end

    local numberOfMetaballsAttracted = #self.attractedMetaballs
    self.averagePosition.x = self.averagePosition.x / numberOfMetaballsAttracted
    self.averagePosition.y = self.averagePosition.y / numberOfMetaballsAttracted

    if self.eye then
        self.eye.eyeBasePosition.x = self.averagePosition.x
        self.eye.eyeBasePosition.y = self.averagePosition.y
        self.eye:update()
    end

    self.invulnerableTime = self.invulnerableTime - (1 * dt)

    if self.invulnerableTime <= 0 then
        self.drawColour = game.manager.currentPalette.enemyColour
    end
end

function point:draw()
    if self.eye then
        self.eye:draw()
    end
end

function point:registerAttractedMetaball(metaball)
    table.insert(self.attractedMetaballs, metaball)
end

function point:unregisterAttractedMetaball(metaball)
    tablex.remove_value(self.attractedMetaballs, metaball)
end

function point:onHitFlash()
    self.drawColour = {1, 1, 1, 1}
    self.invulnerableTime = self.maxInvulnerableTime

    for _, metaball in ipairs(self.attractedMetaballs) do
        game.particleManager:burstEffect("Enemy Hit", 3, metaball.position)
    end
end