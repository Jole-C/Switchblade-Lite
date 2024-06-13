local effect = class({name = "Effect"})

function effect:new(systems, canvasToRender, overrideDrawing)
    self.systems = systems
    self.canvasToRender = canvasToRender
    self.overrideDrawing = overrideDrawing
    self.updateRate = 1
    self.enabled = true
end

function effect:update(dt)
    for _, system in ipairs(self.systems) do
        system:update(dt * self.updateRate)
    end
end

function effect:draw()
    for _, system in ipairs(self.systems) do
        love.graphics.draw(system)
    end
end

function effect:setUpdateRate(updateRate)
    self.updateRate = updateRate
end

function effect:setEnabled(isEnabled)
    self.enabled = isEnabled
end

function effect:emit(amount, position)
    for _, system in ipairs(self.systems) do
        system:setPosition(position.x, position.y)
        system:emit(amount)
    end
end

local particleManager = class({name = "Particle Manager"})

function particleManager:new()
    self.effects = {}
end

function particleManager:update(dt)
    for _, e in pairs(self.effects) do
        if e and e.enabled then
            e:update(dt)
        end
    end
end

function particleManager:draw()
    for _, effect in pairs(self.effects) do
        if effect and effect.overrideDrawing == false and effect.enabled then
            love.graphics.setCanvas(effect.canvasToRender)
            effect:draw()
        end
    end

    love.graphics.setCanvas()
end

function particleManager:newEffect(systems, canvasToRender, overrideDrawing)
    return effect(systems, canvasToRender, overrideDrawing)
end

function particleManager:addEffect(effectToAdd, effectName)
    assert(effect:type() == "Effect", "Object added is not an effect!")
    self.effects[effectName] = effectToAdd
end

function particleManager:removeEffect(effectName)
    self:getEffect(effectName)
    self.effects[effectName] = nil
end

function particleManager:getEffect(effectName)
    local effect = self.effects[effectName]
    assert(effect ~= nil, "Effect does not exist!")

    return self.effects[effectName]
end

function particleManager:burstEffect(systemName, numberToBurst, location)
    local effect = self:getEffect(systemName)
    effect:emit(numberToBurst, location)
end

return particleManager