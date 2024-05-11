local gameOverState = gamestate.new()
gameOverState.objects = {}

function gameOverState:enter()

end

function gameOverState:update(dt)
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:update(dt)
        end
    end
end

function gameOverState:draw()
end

function gameOverState:addObject(object)
    table.insert(self.objects, object)
end

function gameOverState:removeObject(index)
    table.remove(self.objects, index)
end

function gameOverState:leave()
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:destroy()
            self:removeObject(index)
        end
    end
end

return gameOverState