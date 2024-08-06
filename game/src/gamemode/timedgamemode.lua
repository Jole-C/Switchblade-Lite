local gamemode = require "src.gamemode.gamemode"
local timer = require "src.objects.stagedirector.stagetimer"
local timePickup = require "src.objects.stagedirector.timepickup"

local timedGamemode = class({name = "Timed Gamemode", extends = gamemode})

function timedGamemode:new(maxMinutes, maxSeconds)
    self:super()
    
    self.maxMinutes = maxMinutes
    self.maxSeconds = maxSeconds
    self.timer = timer(self.maxMinutes, self.maxSeconds)

    gameHelper:addGameObject(self.timer)
    self:setTimerPaused(true)
end

function timedGamemode:setTime(minutes, seconds)
    self.timer:setTime(minutes or 1, seconds or 59)
end

function timedGamemode:addTime(minutes, seconds)
    self.timer:addTime(minutes or 0, seconds or 0)
end

function timedGamemode:getAbsoluteTime(minutes, seconds)
    return self.timer:getAbsoluteTime(minutes or 0, seconds or 0)
end

function timedGamemode:setTimerPaused(isPaused)
    self.timer:setTimerPaused(isPaused)
end

function timedGamemode:addTimePickup(secondsToAdd)
    local position = gameHelper:getArena():getRandomPosition(0.7)
    gameHelper:addGameObject(timePickup(position.x, position.y, secondsToAdd or 0))
end

function timedGamemode:cleanup()
    gamemode.cleanup(self)

    game.manager.runInfo.time.minutes = self.timer.totalMinutes
    game.manager.runInfo.time.seconds = self.timer.totalSeconds
end

return timedGamemode