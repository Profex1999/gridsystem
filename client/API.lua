GridSystem = {}

exports("GetObject", function()
    return GridSystem
end)

function GridSystem.registerMarker(marker, blip)
    marker = ParseMarker(marker, GetInvokingResource())
    
    if not marker then return end
    if Config.Framework ~= "none" and marker.permission and CurrentJob == nil then
        TempMarkerWithJob[#TempMarkerWithJob +1] = marker
        return
    end

    if Config.Framework ~= "none" then CheckMarkerJob(marker) end
    if blip then
        blip.pos = marker.pos
        blip.name = marker.name
        if marker.permission then
            blip.permission = Config.Framework ~= "none" and marker.permission or nil
            blip.jobGrade =  Config.Framework ~= "none" and marker.jobGrade or 0
        end
        RegisterBlip(blip, GetInvokingResource())
    end

    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(marker.name)
    if isRegistered then
        if HasJob(marker.permission, marker.jobGrade) then
            LogInfo(GetInvokingResource(), "Updating Marker: " .. marker.name .. " Please WAIT!")
            RegisteredMarkers[chunkId][index] = marker
            CurrentZone = nil
            HasAlreadyEnteredMarker = false
        else
            LogInfo(GetInvokingResource(), "Removing Marker Because job changed: " .. marker.name)
            RegisteredMarkers[chunkId][index] = nil
        end
    else
        if HasJob(marker.permission, marker.jobGrade)  then
            local chunk = InsertMarkerIntoGrid(marker)
            LogSuccess(GetInvokingResource(), "Registering Marker: " .. marker.name .. " in chunk: " .. chunk)
        end
    end
end

exports("RegisterMarker", GridSystem.registerMarker)

function GridSystem.registerBlip(blip)
    RegisterBlip(blip, GetInvokingResource())
end

exports("RegisterBlip", GridSystem.registerBlip)

function GridSystem.removeBlip(name)
    if RegisterBlip[name] then
        RemoveBlip(RegisterBlip[name].handle)
        RegisterBlip[name] = nil
    else
        LogError(GetInvokingResource(), "Blip not found: " .. name)
    end
end

exports("RemoveBlip", GridSystem.removeBlip)

function GridSystem.unregisterMarker(markerName)
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(markerName)
    if isRegistered then
        LogInfo(GetInvokingResource(), "Removing Marker: " .. markerName)
        RegisteredMarkers[chunkId][index] = nil
    end
end

exports("UnregisterMarker", GridSystem.unregisterMarker)