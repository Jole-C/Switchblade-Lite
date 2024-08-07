local gameObject = require "src.objects.gameobject"
local alertObject = require "src.objects.stagedirector.alertobject"

local stageDirector = class({name = "Stage Director", extends = gameObject})

function stageDirector:new()
    self:super(0, 0)

    self.gamemode = game.manager:spawnGamemode()

    self.introText = {"Ready?", "Steady?", "GO!"}
    self.secondsBetweenTextChange = 0.5
    
    self.textChangeCooldown = self.secondsBetweenTextChange
    self.currentText = 0

    self.inIntro = true
end

function stageDirector:update(dt)
    if self.inIntro == true then
        self:setTimerPaused(true)

        self.textChangeCooldown = self.textChangeCooldown - 1 * dt

        if self.textChangeCooldown <= 0 then
            if self.currentText >= #self.introText then
                local arena = gameHelper:getArena()

                if arena then
                    arena:enableIntro()
                end

                self.inIntro = false
                self.gamemode:start()
                
                return
            end

            self.textChangeCooldown = self.secondsBetweenTextChange
            self.currentText = self.currentText + 1
            
            local text = alertObject(self.introText[self.currentText], 0.05, 0.3)
            gameHelper:addGameObject(text)
            gameHelper:screenShake(0.1)
        end

        return
    end

    if game.playerManager:doesPlayerExist() == false then
        return
    end

    if self.gamemode then
        self.gamemode:update(dt)
    end
end

function stageDirector:draw()
    if self.gamemode then
        self.gamemode:draw()
    end
end

function stageDirector:setTime(minutes, seconds)
    if self.gamemode and self.gamemode.timer then
        self.gamemode.timer:setTime(minutes or 1, seconds or 59)
    end
end

function stageDirector:addTime(minutes, seconds)
    if self.gamemode and self.gamemode.timer then
        self.gamemode.timer:addTime(minutes or 0, seconds or 0)
    end
end

function stageDirector:getAbsoluteTime(minutes, seconds)
    if self.gamemode and self.gamemode.timer then
        self.gamemode.timer:getAbsoluteTime(minutes or 0, seconds or 0)
    end
end

function stageDirector:setTimerPaused(isPaused)
    if self.gamemode and self.gamemode.timer then
        self.gamemode.timer:setTimerPaused(isPaused)
    end
end

function stageDirector:registerEnemyKill()
    if self.gamemode then
        self.gamemode:registerEnemyKill()
    end
end

function stageDirector:cleanup()
    if self.gamemode then
        self.gamemode:cleanup()
    end
end

return stageDirector