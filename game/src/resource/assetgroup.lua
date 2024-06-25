local assetGroup = class({name = "Asset Group"})

function assetGroup:new(assets)
    self.assets = {}

    for assetName, asset in pairs(assets) do
        self.assets[assetName] = self:parseAsset(asset)
    end
end

function assetGroup:parseAsset(asset)
    assert(asset.type ~= nil, "Asset type is nil!")

    if type(asset.type) == "function" and asset:type() == "Asset Group" then
        return asset
    end
    
    self:validatePath(asset)
    local assetType = asset.type

    if assetType == "Source" then
        return ripple.newSound(love.audio.newSource(asset.path, asset.parameters.type or "static"))
    elseif assetType == "Image" then
        return love.graphics.newImage(asset.path)
    elseif assetType == "Font" then
        return love.graphics.newFont(asset.path)
    elseif assetType == "table" then
        local assets = {}

        for assetName, assetToParse in pairs(asset) do
            assets[assetName] = self:parseAsset(assetToParse)
        end

        return assets
    else
        error("Asset is not parseable!")
    end
end

function assetGroup:add(asset, name)
    self.assets[name] = self:parseAsset(asset)
end

function assetGroup:remove(name)
    self:get(name)
    self.assets[name] = nil
end

function assetGroup:get(name)
    local asset = self.assets[name]
    assert(asset ~= nil, "Asset does not exist!")

    return asset
end

function assetGroup:validatePath(asset)
    assert(asset.path ~= nil, "Asset path is nil!")
    assert(type(asset.path) == "string", "Asset path is not a string!")
end

return assetGroup