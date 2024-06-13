local bossState = class({name = "Boss State"})

function bossState:new(parameters)
    self.parameters = parameters
    self.drawAbove = true
end

function bossState:enter(bossInstance)

end

function bossState:exit(bossInstance)

end

function bossState:update(dt, bossInstance)

end

function bossState:draw(bossInstance)

end

return bossState