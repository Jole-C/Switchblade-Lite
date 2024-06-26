local musicTrack = class({name = "Music Track"})

function musicTrack:new(trackElements)
    for i = 1, #trackElements do
        local element = trackElements[i]

        assert(element.sound ~= nil, "Element "..tostring(i).." has no Sound!")
        assert(element.loopCount ~= nil, "Element "..tostring(i).." loop count is nil!")

        element.loopPermanent = element.loopPermanent or false
    end

    self.started = false
    self.trackElements = trackElements
    self.currentElementIndex = 1
    self.currentElement = nil
    self.currentSoundInstance = nil
    self.loopCount = 0
end

function musicTrack:update(dt)
    if self.started == false then
        return
    end

    if self.currentElement == nil or self.currentSoundInstance == nil then
        self.started = false
        return
    end

    if self.currentElement.loopPermanent == false then
        if self.currentElementIndex >= #self.trackElements and self.loopCount >= self.currentElement.loopCount then
            self:stop()
            return
        end
        
        if self.currentSoundInstance:isStopped() and self.loopCount >= self.currentElement.loopCount then
            self:startNextElement()
            return
        end
    end

    if self.currentSoundInstance:isStopped() then
        self.currentSoundInstance = self.currentElement.sound:play()
        self.loopCount = self.loopCount + 1
    end
end

function musicTrack:start()
    self:stop()

    self.currentElementIndex = 0
    self.started = true
    self:startNextElement()
end

function musicTrack:startNextElement()
    self.currentElementIndex = self.currentElementIndex + 1
    self.currentElement = self.trackElements[self.currentElementIndex]
    self.currentSoundInstance = self.currentElement.sound:play()
    self.loopCount = 1
end

function musicTrack:stop()
    self.started = false
    self.currentElementIndex = 0

    if self.currentElement and self.currentSoundInstance then
        self.currentSoundInstance:stop()
    end
end

function musicTrack:pause()
    if self.currentElement and self.currentSoundInstance then
        self.currentSoundInstance:pause()
        self.started = false
    end
end

function musicTrack:play()
    if self.started == false and self.currentElement and self.currentSoundInstance then
        self.currentSoundInstance:resume()
        self.started = true
    end
end

return musicTrack