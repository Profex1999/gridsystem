

AddEventHandler("gridsystem:registerMarker", function (marker, blip)
    -- print that the event is a legacy functionality
    LogWarningSkipConfig(GetInvokingResource(), "gridsystem:registerMarker is a legacy functionality, please use RegisterMarker instead")
    GridSystem.registerMarker(marker, blip)
end)

AddEventHandler('gridsystem:registerBlip', function (blip)
    LogWarningSkipConfig(GetInvokingResource(), "gridsystem:registerBlip is a legacy functionality, please use RegisterBlip instead")
    RegisterBlip(blip, GetInvokingResource())
end)

AddEventHandler('gridsystem:removeBlip', function (name)
    LogWarningSkipConfig(GetInvokingResource(), "gridsystem:removeBlip is a legacy functionality, please use RemoveBlip instead")
    if RegisterBlip[name] then
        RemoveBlip(RegisterBlip[name].handle)
        RegisterBlip[name] = nil
    else
        LogError(GetInvokingResource(), "Blip not found: " .. name)
    end
end)

AddEventHandler("gridsystem:unregisterMarker", function(markerName)
    LogWarningSkipConfig(GetInvokingResource(), "gridsystem:unregisterMarker is a legacy functionality, please use unregisterMarker instead")
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(markerName)
    if isRegistered then
        LogInfo(GetInvokingResource(), "Removing Marker: " .. markerName)
        RegisteredMarkers[chunkId][index] = nil
    end
end)