local renderCanvas = class({name = "Render Canvas"})

function renderCanvas:new(name, width, height)
    self.dimensions = vec2(width, height)
    self.name = name
    self.enabled = true

    self.canvas = love.graphics.newCanvas(self.dimensions.x, self.dimensions.y)
end

local renderer = class({name = "Renderer"})

function renderer:new()
    self.renderCanvases = {}
end

function renderer:addRenderCanvas(canvasName, width, height)
    local newCanvas = renderCanvas(canvasName, width, height)
    table.insert(self.renderCanvases, newCanvas)
    return newCanvas
end

function renderer:removeRenderCanvas(canvasName)
    local index = nil

    for i = 1, #self.renderCanvases do
        local canvas = self.renderCanvases[i]
        
        if canvas.name == canvasName then
            index = i
            break
        end
    end

    assert(index, "Canvas does not exist")

    table.remove(self.renderCanvases, index)
end

function renderer:getRenderCanvas(canvasName)
    for i = 1, #self.renderCanvases do
        local canvas = self.renderCanvases[i]
        
        if canvas.name == canvasName then
            return canvas
        end
    end

    assert(false, "Canvas does not exist")
end

function renderer:drawCanvases()
    for i = 1, #self.renderCanvases do
        local canvas = self.renderCanvases[i]

        if canvas and canvas.enabled then
            local renderCanvas = canvas.canvas
            local width = canvas.dimensions.x
            local height = canvas.dimensions.y

            local maxScaleX = love.graphics.getWidth() / renderCanvas:getWidth()
            local maxScaleY = love.graphics.getHeight() / renderCanvas:getHeight()
            local scale = math.min(maxScaleX, maxScaleY)

            love.graphics.draw(renderCanvas, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, scale, scale, width / 2, height / 2)
        end
    end
end

return renderer