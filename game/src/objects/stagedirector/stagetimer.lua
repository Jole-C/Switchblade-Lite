local gameObject = require "src.objects.gameobject"
local stageTimeHud = require "src.objects.stagedirector.stagetimedisplay"
local alertObject = require "src.objects.stagedirector.alertobject"

local stageTimer = class({name = "Stage Director", extends = gameObject})

function stageTimer:new(minutes, seconds)
    self:super(0, 0)

    self.maxMinutes = minutes
    self.maxSeconds = seconds
    self.maxLowTimeWarningCooldown = 1
    self.alertDisplayTime = 0.3
    self.alertDisplaySpeed = 0.2

    self.maxWaveCompleteDisplayTime = 2
    self.waveCompleteDisplayTime = 0
    self.maxWaveCompleteScale = 1.25
    self.waveCompleteScale = 1
    self.timerScaleRate = 0.1

    self.timeMinutes = self.maxMinutes
    self.timeSeconds = self.maxSeconds
    self.totalMinutes = 0
    self.totalSeconds = 0
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
            self.timeSeconds = 60
            self.timeMinutes = self.timeMinutes - 1
        end

        self.timeSeconds = self.timeSeconds - (1 * dt)
        self.totalSeconds = self.totalSeconds + (1 * dt)

        if self.totalSeconds > 59 then
            self.totalSeconds = 0
            self.totalMinutes = self.totalMinutes + 1
        end

        if self.timeMinutes <= 0 and self.timeSeconds <= 10 then
            self.lowTimeWarningCooldown = self.lowTimeWarningCooldown - (1 * dt)

            if self.lowTimeWarningCooldown <= 0 then
                self.lowTimeWarningCooldown = self.maxLowTimeWarningCooldown
                self.lowTimeSound:play()
            end
        end
    end

    self.waveCompleteDisplayTime = self.waveCompleteDisplayTime - (1 * dt)

    if self.waveCompleteDisplayTime >= 0 then
        self.hud.timerScale = math.lerpDT(self.hud.timerScale, self.maxWaveCompleteScale, self.timerScaleRate, dt)
    else
        self.hud.timerScale = math.lerpDT(self.hud.timerScale, 1, self.timerScaleRate, dt)
    end
end

function stageTimer:setTime(minutes, seconds)
    self.timeMinutes = minutes or 1
    self.timeSeconds = seconds or 59 
    
    for _, timeAlert in pairs(self.timeAlertText) do
        timeAlert.displayed = false
    end
end

function stageTimer:addTime(minutes, seconds)
    minutes = minutes or 0
    seconds = seconds or 0

    self.timeMinutes = self.timeMinutes + minutes
    self.timeMinutes = self.timeMinutes + math.floor(seconds / 60)
    
    self.timeSeconds = self.timeSeconds + seconds % 60

    self.waveCompleteDisplayTime = self.maxWaveCompleteDisplayTime
end

function stageTimer:getAbsoluteTime(minutes, seconds)
    return (minutes * 60) + math.floor(seconds)
end

function stageTimer:getRelativeTime(seconds)
    local parsedMinutes = (seconds % 3600) / 60
    local parsedSeconds = seconds % 60

    return parsedSeconds, parsedMinutes
end

function stageTimer:setTimerPaused(isPaused)
    self.paused = isPaused
end

function stageTimer:cleanup()
    game.interfaceRenderer:removeHudElement(self.hud)
end

return stageTimer