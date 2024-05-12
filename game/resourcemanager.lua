local resourceManager = class{
    resources = {},

    addResource = function(self, resource, identifier)
        self.resources[identifier] = resource
        resource:setFilter("nearest", "nearest")
    end,

    removeResource = function(self, identifier)
        self.resources[identifier] = nil
    end,

    getResource = function(self, identifier)
        return self.resources[identifier]
    end,

    updateResource = function(self, newResource, identifier)
        self.resources[identifier] = newResource
    end
}

return resourceManager