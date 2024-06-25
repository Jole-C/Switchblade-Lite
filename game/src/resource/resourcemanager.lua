local resourceManager = class({name = "Resource Manager"})

function resourceManager:new()
    self.assets = {}
end

function resourceManager:addAsset(asset, name)
    --to do: figure out if you can get the base class with batteries
    --assert...
    self.assets[name] = asset
end

function resourceManager:removeAsset(name)
    local assetToRemove = self:getAsset(name)
    self.assets[name] = nil
end

function resourceManager:getAsset(name)
    local asset = self.assets[name]
    assert(asset ~= nil, "Asset does not exist!")

    return asset
end

return resourceManager