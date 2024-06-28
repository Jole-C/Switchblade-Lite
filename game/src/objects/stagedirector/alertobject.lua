local gameObject = require "src.objects.gameobject"
local textElement = require "src.interface.text"
local alertObject = class({name = "Alert Object", extends = gameObject})

function alertObject:new(text, displayTime, lerpTime)
    self:super(0, 0)

    self.text = text
    self.startingAngle = math.pi
    self.angleLerpRate = lerpTime or 0.1
    self.scaleLerpRate = lerpTime or 0.1

    self.displayTime = displayTime or 2

    self.textElement = textElement(text, "fontAlert", "center", 240, 135, 480, self.startingAngle, 0, 0, true)
    game.interfaceRenderer:addHudElement(self.textElement)
end

function alertObject:update(dt)
    if self.textElement == nil then
        return
    end

    if self.displayTime > 0 then
        self.textElement.angle = math.lerpAngle(self.textElement.angle, 0, self.angleLerpRate, dt)
        self.textElement.scale.x = math.lerpDT(self.textElement.scale.x, 1, self.scaleLerpRate, dt)
        self.textElement.scale.y = math.lerpDT(self.textElement.scale.y, 1, self.scaleLerpRate, dt)

        if math.abs(self.textElement.angle) < 0.001 then
            self.displayTime = self.displayTime - (1 * dt)
        end
    else
        self.textElement.angle = math.lerpAngle(self.textElement.angle, math.pi - 0.001, self.angleLerpRate, dt)
        self.textElement.scale.x = math.lerpDT(self.textElement.scale.x, 0, self.scaleLerpRate, dt)
        self.textElement.scale.y = math.lerpDT(self.textElement.scale.y, 0, self.scaleLerpRate, dt)

        if self.textElement.scale.x < 0.001 and self.textElement.scale.y < 0.001 then
            self:destroy()
        end
    end
end

function alertObject:cleanup()
    game.interfaceRenderer:removeHudElement(self.textElement)
end

return alertObject