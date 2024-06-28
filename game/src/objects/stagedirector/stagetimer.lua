local gameObject = require "src.objects.gameobject"
local stageTimeHud = require "src.objects.stagedirector.stagetimedisplay"
local alertObject = require "src.objects.stagedirector.alertobject"

local stageTimer = class({name = "Stage Director", extends = gameObject})

function stageTimer:new(minutes, seconds, intervalTexts)
    self:super(0, 0)

    self.maxMinutes = minutes
    self.maxSeconds = seconds
    self.timeAlertText = intervalTexts
    self.maxLowTimeWarningCooldown = 1
    self.alertDisplayTime = 0.3
    self.alertDisplaySpeed = 0.2

    self.timeMinutes = self.maxMinutes
    self.timeSeconds = self.maxSeconds
    self.paused = false

    self.lowTimeWarningCooldown = 0
    self.lowTimeSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("timeSiren")

    self.hud = stageTimeHud()
    game.interfaceRenderer:addHudElement(self.hud)
end

function stageTimer:update(dt)
    self.timeSeconds = math.clamp(self.timeSeconds, 0, 60)
    self.timeMinutes = math.clamp(self.timeMinutes, 0, math.huge)

    self.hud.timeSeconds = self.timeSeconds
    self.hud.timeMinutes = self.timeMinutes
    
    if self.paused then
        return
    end

    if self.paused == false then
        if self.timeSeconds <= 0 then
            self.timeSeconds = 59
            self.timeMinutes = self.timeMinutes - 1
        end

        self.timeSeconds = self.timeSeconds - (1 * dt)

        if self.timeMinutes <= 0 and self.timeSeconds <= 10 then
            self.lowTimeWarningCooldown = self.lowTimeWarningCooldown - (1 * dt)

            if self.lowTimeWarningCooldown <= 0 then
                self.lowTimeWarningCooldown = self.maxLowTimeWarningCooldown
                self.lowTimeSound:play()
            end
        end
    end    
    
    for _, timeAlert in pairs(self.timeAlertText) do
        local minutes = self.timeMinutes
        local seconds = math.floor(self.timeSeconds)

        if self:getAbsoluteTime(minutes, seconds) > self:getAbsoluteTime(timeAlert.time.minutes, timeAlert.time.seconds) then
            timeAlert.displayed = false
        end
        
        if minutes == timeAlert.time.minutes and seconds == timeAlert.time.seconds and timeAlert.displayed == false then
            timeAlert.displayed = true
            
            local text = alertObject(timeAlert.text, self.alertDisplayTime, self.alertDisplaySpeed)
            gameHelper:addGameObject(text)
            gameHelper:screenShake(0.1)
        end
    end
end

function stageTimer:setTime(minutes, seconds)
    self.timeMinutes = minutes or 1
    self.timeSeconds = seconds or 59 
    
    for _, timeAlert in pairs(self.timeAlertText) do
        timeAlert.displayed = false
    end
end

function stageTimer:getAbsoluteTime(minutes, seconds)
    return (minutes * 60) + math.floor(seconds)
end

function stageTimer:setTimerPaused(isPaused)
    self.paused = isPaused
end

function stageTimer:cleanup()
    game.interfaceRenderer:removeHudElement(self.hud)
end

return stageTimer