
renderer = class{

    update = function(self)
    end,

    draw = function(self)
        local currentGamestate = gamestate.current()

        if currentGamestate.objects then
            for key,object in ipairs(currentGamestate.objects) do
                object:draw()
            end
        end
    end
}