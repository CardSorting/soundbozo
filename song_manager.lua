local storage = require('storage')

local songManager = {}
local songs = {}
-- Dynamic cache size based on system memory
local function getMaxCacheSize()
    local mem = collectgarbage("count") / 1024 -- Get memory usage in MB
    local totalMem = love.system.getTotalMemory() / (1024 * 1024) -- Total memory in MB
    
    -- Calculate cache size based on available memory
    local baseCache = 5 -- Minimum cache size
    local maxCache = 10 -- Maximum cache size
    local availableMem = totalMem - mem
    
    -- Scale cache size based on available memory
    if availableMem > 500 then
        return maxCache
    elseif availableMem > 200 then
        return math.floor(baseCache + (maxCache - baseCache) * ((availableMem - 200) / 300))
    else
        return baseCache
    end
end

local MAX_CACHE_SIZE = getMaxCacheSize() -- Dynamic maximum number of songs to keep loaded
local loadedSongs = {} -- Track loaded songs for cache management

function songManager.init()
    loadedSongs = {} -- Reset cache on init
    -- Load built-in song patterns
    local builtInSongs = {
        require("songs/song1/pattern"),
        require("songs/song2/pattern"),
        require("songs/song3/pattern"),
        require("songs/song4/pattern"),
        require("songs/song5/pattern"),
        require("songs/song6/pattern"),
        require("songs/song7/pattern")
    }
    
    -- Store song metadata without loading audio
    for _, song in ipairs(builtInSongs) do
        song.music = nil -- Clear audio reference
        table.insert(songs, song)
    end
    
    -- Load custom songs from save directory
    local customSongs = storage.loadCustomSongs()
    for _, song in ipairs(customSongs) do
        if song.music then
            -- Custom song already has music loaded by storage module
            table.insert(songs, song)
        end
    end
end

function songManager.getSongs()
    -- Return copy of songs with metadata only
    local songCopies = {}
    for _, song in ipairs(songs) do
        local songCopy = {
            name = song.name,
            audio = song.audio,
            pattern = song.pattern,
            metadata = song.metadata
        }
        table.insert(songCopies, songCopy)
    end
    return songCopies
end

-- Manage cache by unloading least recently used songs
local function manageCache(newSong)
    -- Add new song to cache
    table.insert(loadedSongs, 1, newSong)
    
    -- Remove oldest songs if cache is full
    while #loadedSongs > MAX_CACHE_SIZE do
        local oldest = loadedSongs[#loadedSongs]
        if oldest.music then
            oldest.music:stop()
            oldest.music = nil
        end
        table.remove(loadedSongs)
    end
end

-- Preload adjacent songs in the song list
function songManager.preloadAdjacentSongs(currentIndex)
    local preloadRange = 1 -- Number of songs to preload on each side
    local startIndex = math.max(1, currentIndex - preloadRange)
    local endIndex = math.min(#songs, currentIndex + preloadRange)
    
    for i = startIndex, endIndex do
        if i ~= currentIndex and not songs[i].music then
            songManager.loadSongAudio(songs[i].name)
        end
    end
end

-- Load audio for a specific song with cache management
function songManager.loadSongAudio(songName)
    for _, song in ipairs(songs) do
        if song.name == songName then
            if not song.music then
                local success, source = pcall(love.audio.newSource, song.audio, "stream")
                if success then
                    song.music = source
                    manageCache(song)
                    print("Lazy loaded audio for song: " .. song.name)
                    return true
                else
                    print("Failed to load audio for song: " .. song.name)
                    print("Audio path: " .. song.audio)
                    return false
                end
            else
                -- Move song to front of cache if already loaded
                for i, loaded in ipairs(loadedSongs) do
                    if loaded == song then
                        table.remove(loadedSongs, i)
                        table.insert(loadedSongs, 1, song)
                        break
                    end
                end
                return true
            end
        end
    end
    return false
end

-- Get audio source for a specific song with automatic loading and fallback
function songManager.getSongAudio(songName)
    for i, song in ipairs(songs) do
        if song.name == songName then
            if not song.music then
                -- Try to load the song if not already loaded
                if not songManager.loadSongAudio(songName) then
                    -- Fallback to next available song if loading fails
                    local nextIndex = i + 1 <= #songs and i + 1 or 1
                    local nextSong = songs[nextIndex]
                    if nextSong then
                        print("Falling back to next song: " .. nextSong.name)
                        return songManager.getSongAudio(nextSong.name)
                    end
                end
            end
            
            -- Preload adjacent songs
            songManager.preloadAdjacentSongs(i)
            
            return song.music
        end
    end
    return nil
end

function songManager.addSong(song)
    -- Only add song if it has valid music
    if song.music then
        table.insert(songs, song)
        return true
    end
    return false
end

function songManager.loadAudioFromData(data)
    local success, sourceOrError = pcall(function()
        return love.audio.newSource(love.sound.newSoundData(data), "stream")
    end)
    
    if success then
        print("Successfully loaded audio source")
        return sourceOrError
    else
        print("Failed to load audio source: " .. tostring(sourceOrError))
        return nil
    end
end

function songManager.stopCurrentSong(currentMusic)
    if currentMusic then
        currentMusic:stop()
    end
end

-- Clean up any invalid songs
function songManager.cleanup()
    local validSongs = {}
    for _, song in ipairs(songs) do
        if song.music then
            -- Test if the music source is still valid
            local success = pcall(function() 
                song.music:getDuration()
            end)
            if success then
                table.insert(validSongs, song)
            else
                print("Removing invalid song: " .. song.name)
            end
        end
    end
    songs = validSongs
end

-- Remove a specific song
function songManager.removeSong(songName)
    for i = #songs, 1, -1 do
        if songs[i].name == songName then
            if songs[i].music then
                songs[i].music:stop()
            end
            table.remove(songs, i)
            print("Removed song: " .. songName)
            return true
        end
    end
    return false
end

return songManager
