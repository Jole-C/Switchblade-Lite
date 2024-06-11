local resourceManager = class({name = "Resource Manager"})

function resourceManager:new()
    self.resources = {}
end

function resourceManager:addResource(resource, identifier)
    self.resources[identifier] = resource
    
    if resource.setFilter and resource:type() ~= "Source" then
        resource:setFilter("nearest", "nearest")
    end
end

function resourceManager:removeResource(identifier)
    self.resources[identifier] = nil
end

function resourceManager:getResource(identifier)
    local resource = self.resources[identifier]
    assert(resource ~= nil, "Resource does not exist!")
    
    return resource
end

function resourceManager:updateResource(newResource, identifier)
    self.resources[identifier] = newResource
end

return resourceManager