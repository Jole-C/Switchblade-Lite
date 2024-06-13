local bossState = class({name = "Boss State"})

function bossState:new(parameters)
    self.parameters = parameters
end

function bossState:enter(bossInstance)

end

function bossState:exit(bossInstance)

end

function bossState:update(dt, bossInstance)

end

return bossState