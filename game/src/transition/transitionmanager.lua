local transitionManager = class({name = "Transition Manager"})

function transitionManager:new()
    self.inTransition = false
    self.midTransition = false
    self.transitionState = nil
    self.transitionFunction = nil
    
    self.alphaLerpRate = 0.2
    self.rectAlpha = 0
end

function transitionManager:update(dt)
    if self.inTransition == true then
        if self.midTransition == false then
            self.rectAlpha = math.lerpDT(self.rectAlpha, 1, self.alphaLerpRate, dt)

            if self.rectAlpha > 0.95 then
                self.midTransition = true

                if self.transitionFunction then
                    self.transitionFunction()
                end
                
                if self.transitionState then
                    game.gameStateMachine:set_state(self.transitionState)
                    print("transition start complete")
                end
            end
        else
            self.rectAlpha = math.lerpDT(self.rectAlpha, 0, self.alphaLerpRate, dt)

            if self.rectAlpha <= 0.01 then
                self.inTransition = false
                self.midTransition = false
                print("transition end complete")
            end
        end
    end
end

function transitionManager:draw()
    love.graphics.setColor(0, 0, 0, self.rectAlpha)
    love.graphics.rectangle("fill", 0, 0, 480, 270)
    love.graphics.setColor(1, 1, 1, 1)
end

function transitionManager:doTransition(transitionState, transitionFunction)
    self.inTransition = true
    self.transitionState = transitionState
    self.transitionFunction = transitionFunction
end

return transitionManager