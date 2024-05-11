local gameManager = class{
    timeDilation = 1,

    init = function(self)

    end,

    setTimeDilation = function(self, percentage)
        self.timeDilation = percentage
    end
}

return gameManager