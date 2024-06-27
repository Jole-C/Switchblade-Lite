local musicTrack = require "src.music.musictrack"
local musicManager = class({name = "Music Manager"})

function musicManager:new()
    self.tracks = {}
end

function musicManager:addTrack(trackElements, trackName)
    self.tracks[trackName] = musicTrack(trackElements)
end

function musicManager:update(dt)
    for _, track in pairs(self.tracks) do
        track:update(dt)
    end
end

function musicManager:getTrack(trackName)
    local track = self.tracks[trackName]
    assert(track ~= nil, "Track does not exist!")
    
    return track
end

return musicManager