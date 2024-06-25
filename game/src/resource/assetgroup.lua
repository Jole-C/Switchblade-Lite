local assetGroup = class({name = "Asset Group"})

function assetGroup:new(assets)
    self.assets = {}

    for assetName, asset in pairs(assets) do
        self.assets[assetName] = self:parseAsset(asset)
    end
end

function assetGroup:parseAsset(asset)
    assert(asset.type ~= nil, "Asset type is nil!")

    if type(asset.type) == "function" then
        return asset
    end
    
    self:validatePath(asset)
    local assetType = asset.type

    if assetType == "Source" then
        if asset.parameters then
            local type = asset.parameters.type or "static"
            local sound = ripple.newSound(love.audio.newSource(asset.path, type))

            if asset.parameters.tag then
                sound:tag(asset.parameters.tag)
            end

            return sound
        else
            return ripple.newSound(love.audio.newSource(asset.path, "static"))
        end
    elseif assetType == "Image" then
        local image = love.graphics.newImage(asset.path)
        image:setFilter("nearest", "nearest", 0)

        if asset.parameters then
            if asset.parameters.wrapX or asset.parameters.wrapY then
                image:setWrap(asset.parameters.wrapX or "clampzero", asset.parameters.wrapY or "clampzero")
            end
        end

        return image
    elseif assetType == "Font" then
        assert(asset.parameters ~= nil, "Image font needs parameters set for font size!")

        local font = love.graphics.newFont(asset.path, asset.parameters.size)
        font:setFilter("nearest", "nearest", 0)

        return font
    elseif assetType ==  "Image Font" then
        assert(asset.parameters ~= nil, "Image font needs parameters set for glyphs!")
        
        local font = love.graphics.newImageFont(asset.path, asset.parameters.glyphs, asset.parameters.spacing)
        font:setFilter("nearest", "nearest", 0)

        return font
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