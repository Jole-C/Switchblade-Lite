local renderCanvas = class{
    name = "",
    dimensions,
    canvas,
    enabled = true,

    init = function(self, name, width, height)
        self.dimensions = vector.new(width, height)
        self.name = name

        self.canvas = love.graphics.newCanvas(self.dimensions.x, self.dimensions.y)
    end
}

local renderer = class{
    renderCanvases = {},

    addRenderCanvas = function(self, canvasName, width, height)
        local newCanvas = renderCanvas(canvasName, width, height)
        table.insert(self.renderCanvases, newCanvas)

        return newCanvas
    end,

    removeRenderCanvas = function(self, canvasName)
        local element = self.renderCanvases[canvasName]
        assert(element ~= nil, "Canvas does not exist")

        table.remove(self.renderCanvases, canvasName)
    end,

    getRenderCanvas = function(self, canvasName)
        local canvas = nil

        for i = 1, #self.renderCanvases do
            if self.renderCanvases[i].name == canvasName then
                return canvas
            end
        end

        assert(canvas ~= nil, "Canvas does not exist")

        return canvas
    end,
    
    update = function(self)

    end,

    drawCanvases = function(self)
        for i = 1, #self.renderCanvases do
            local canvas = self.renderCanvases[i]

            if canvas and canvas.enabled == true then
                local renderCanvas = canvas.canvas
                local width = canvas.dimensions.x
                local height = canvas.dimensions.y

                local maxScaleX = love.graphics.getWidth() / renderCanvas:getWidth()
                local maxScaleY = love.graphics.getHeight() / renderCanvas:getHeight()
                local scale = math.min(maxScaleX, maxScaleY)
                
                love.graphics.draw(renderCanvas, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, scale, scale, width / 2, height / 2)
            end
        end
    end,
}

return renderer