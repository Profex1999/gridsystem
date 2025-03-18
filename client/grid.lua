local deltas = {
    vector2(-1, -1),
    vector2(-1, 0),
    vector2(-1, 1),
    vector2(0, -1),
	vector2(0, 0),
    vector2(1, -1),
    vector2(1, 0),
    vector2(1, 1),
    vector2(0, 1),
}
local bitShift = 32
local zoneRadius = 64

function GetGridChunk(x)
    return math.floor(x / zoneRadius)
end

function GetGridBase(x)
    return (x * zoneRadius)
end

function GetChunkId(v)
	return (v.x << bitShift) | (v.y & 0xFFFFFFFF)
end

function GetMaxChunkId()
    return zoneRadius << bitShift
end

function GetCurrentChunk(pos)
    local chunk = vector2(GetGridChunk(pos.x), GetGridChunk(pos.y))
    local chunkId = GetChunkId(chunk)

    return chunkId
end

function GetNearbyChunks(pos)
    local nearbyChunksList = {}
    local nearbyChunks = {}
    
    for i = 1, #deltas do 
        local chunkSize = pos.xy + (deltas[i] * zoneRadius)
        local chunk = vector2(GetGridChunk(chunkSize.x), GetGridChunk(chunkSize.y))
        local chunkId = GetChunkId(chunk) 

        if not nearbyChunksList[chunkId] then        
            nearbyChunks[#nearbyChunks + 1] = chunkId
            nearbyChunksList[chunkId] = true
        end
    end

    return nearbyChunks
end