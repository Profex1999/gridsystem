Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

AddEventHandler("gridsystem:registerMarker", function (marker)

    marker = ParseMarker(marker, GetInvokingResource())
    if not marker then return end
    if marker.permission and CurrentJob == nil then
        table.insert(TempMarkerWithJob, marker)
        return
    end

    CheckMarkerJob(marker)
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(marker.name)
    if isRegistered then
        if HasJob(marker) then
            LogInfo("Updating Marker: " .. marker.name .. " Please WAIT!")
            RegisteredMarkers[chunkId][index] = marker
            CurrentZone = nil
            HasAlreadyEnteredMarker = false
        else
            LogInfo("Removing Marker Because job changed: " .. marker.name)
            RegisteredMarkers[chunkId][index] = nil
        end
    else
        if HasJob(marker) then
            local chunk = InsertMarkerIntoGrid(marker)
            LogSuccess("Registering Marker: " .. marker.name .. " in chunk: " .. chunk)
        end
    end
end)


AddEventHandler("gridsystem:hasEnteredMarker", function (zone)
    if #(MyCoords.xy - zone.pos.xy) < #(zone.scale.xy/2) and math.abs(MyCoords.z - zone.pos.z) < zone.scaleZ then
        if zone.onEnter then
            local status, err = pcall(zone.onEnter)
            if not status then
                LogError(string.format("Error executing action for marker %s. Error: %s", zone.name, err))
            end
        end
    else
        LogError("Error: enter event triggered but player is outside of marker", GetInvokingResource())
    end
end)

AddEventHandler("gridsystem:hasExitedMarker", function ()
    if CurrentZone then
        if CurrentZone.mustExit then
            CurrentZone.mustExit = nil
        end
        if CurrentZone.onExit then
            local status, err = pcall(CurrentZone.onExit)
            if not status then
                LogError(string.format("Error executing action for marker %s. Error: %s", CurrentZone.name, err))
            end
        end
        CurrentZone = nil
        ClearHelp(true)
    else
        LogError("Error: exit event triggered but marker never entered", GetInvokingResource())
    end
end)

AddEventHandler("gridsystem:unregisterMarker", function(markerName)
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(markerName)
    if isRegistered then
        LogInfo("Removing Marker: " .. markerName)
        RegisteredMarkers[chunkId][index] = nil
    end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function (job)
    CurrentJob = job
    RemoveAllJobMarkers()
    AddJobMarkers()
end)


AddEventHandler("onResourceStop", function (resource)
    local markers = GetMarkersFromResource(resource)
    if #markers > 0 then
        for _, m in pairs(markers) do
            local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(m.name)
            if isRegistered then
                LogInfo(string.format("Removing Marker For Stopping of Resource %s: %s", resource, m.name))
                RegisteredMarkers[chunkId][index] = nil
            end
        end
    end
end)