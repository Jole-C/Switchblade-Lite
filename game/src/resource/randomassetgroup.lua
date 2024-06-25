local assetGroup = require "src.resource.assetgroup"
local randomAssetGroup = class({name = "Random Asset Group", extends = assetGroup})

function randomAssetGroup:new(assets)
    self:super(assets)
end

function randomAssetGroup:get()
    local assets = {}

    for _, asset in pairs(self.assets) do
        table.insert(assets, asset)
    end

    local index = math.random(1, #assets)
    return assets[index]
end

return randomAssetGroup