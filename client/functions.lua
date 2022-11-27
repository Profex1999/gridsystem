local logInfo = false
RegisterCommand("grid_log", function()
    logInfo = not logInfo
end, true)
LogError = function (invoker, text)
    if invoker then
        print("^1[FATAL ERROR] [" .. invoker .. "] " .. text)
    else
        print("^1[FATAL ERROR] " .. text)
    end
end

LogWarning = function (invoker, text)
    print(string.format("^3[WARNING] [%s] %s", invoker, text))
end

LogSuccess = function (text)
    if not logInfo then return end
    print("^2 " .. text)
end

LogInfo = function (text)
    if not logInfo then return end
    print("^5 " .. text)
end

LogMissingField = function (invoker, field, name)
    LogWarning(invoker, string.format("Filed in marker ^1%s ^3in script ^1%s ^3was not specified.\n^3A default value has been applied, please check your script", field, name))
end

LogBadFormat = function (invoker, field, name)
    LogWarning(invoker, string.format("Bad field format ^1%s ^3in marker ^1%s ^3.\n^3A default value has been applied, please check your script", field, name)) 
end

IsMarkerAlreadyRegistered = function (markerName)
    for k,v in pairs(RegisteredMarkers) do
        if type(v) == "table" then
            for i,j in pairs(v) do
                if j.name == markerName then
                    return true, k, i
                end
            end
        end
    end
    return false
end

RegisterTempMarkers = function()
    for i = 1, #TempMarkerWithJob do
        TriggerEvent('gridsystem:registerMarker', TempMarkerWithJob[i])
        Wait(100) --Give some time to register marker
    end
    TempMarkerWithJob = {}
end

DrawText3D = function (x, y, z, text)
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 68)
    ClearDrawOrigin()
end

CheckMarkerJob = function (marker)
    if not marker.permission then return end
    marker.jobGrade = tonumber(marker.jobGrade)  
    if marker.jobGrade == nil then marker.jobGrade = 0 end 
    if type(MarkerWithJob[marker.permission]) == "table" then
        for i = 1, #MarkerWithJob[marker.permission] do
            if MarkerWithJob[marker.permission][i].name == marker.name then
                MarkerWithJob[marker.permission][i] = marker
                return
            end
        end
    else 
        MarkerWithJob[marker.permission] = {}
    end
    table.insert(MarkerWithJob[marker.permission], marker)
end

HasJob = function (jobName, jobGrade)
    if Config.Framework == "none" then return true end
    if not jobName then return true end
    while CurrentJob == nil do Wait(100) end
    return (CurrentJob.name == jobName and CurrentJob.grade >= jobGrade)
end

RemoveAllJobMarkers = function ()
    for _,v in pairs(MarkerWithJob) do
        for i = 1, #v do
            local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(v[i].name)
            if isRegistered then
                LogInfo("Removing Job Marker: " .. v[i].name)
                if RegisteredMarkers[chunkId][index].blip then
                    RemoveBlip(RegisteredMarkers[chunkId][index].blip)
                end
                RegisteredMarkers[chunkId][index] = nil
            end
        end
    end
end

AddJobMarkers = function ()
    if MarkerWithJob[CurrentJob.name] then
        for i = 1, #MarkerWithJob[CurrentJob.name] do
            if HasJob(MarkerWithJob[CurrentJob.name][i].permission, MarkerWithJob[CurrentJob.name][i].jobGrade) then
                InsertMarkerIntoGrid(MarkerWithJob[CurrentJob.name][i])
            end
        end
    end
end

InsertMarkerIntoGrid = function (marker)
    local markerChunk = GetCurrentChunk(marker.pos)
    if type(RegisteredMarkers[markerChunk]) ~= "table" then
        RegisteredMarkers[markerChunk] = {}
    end
    table.insert(RegisteredMarkers[markerChunk], marker)
    return markerChunk
end

GetMarkersFromResource = function (resource)
    local temp = {}
    for k,v in pairs(RegisteredMarkers) do
        if type(v) == "table" then
            for i,j in pairs(v) do
                if j.resource == resource then
                    temp[#temp + 1] = j
                end
            end
        end
    end
    return temp
end

GetBlipsFromResource = function(resource)
    local temp = {}
    for k,v in pairs(RegisteredBlips) do
        if v.resource == resource then
            temp[#temp + 1] = v
        end
    end
    return temp
end

RefreshBlips = function()
    for k,v in pairs(RegisteredBlips) do
        if v.permission then
            if HasJob(v.permission, v.jobGrade) then
                if not RegisteredBlips[k].handle then
                    RegisteredBlips[k] = ParseBlip(RegisteredBlips[k])
                end
            else
                if RegisteredBlips[k].handle then
                    RemoveBlip(RegisteredBlips[k].handle)
                    RegisteredBlips[k].handle = nil
                end
            end
        end
    end
end

RegisterBlip = function(blip, invoker)
    if RegisteredBlips[blip.name] then
        if not HasJob(RegisteredBlips[blip.name].permission, RegisteredBlips[blip.name].jobGrade) then
            RemoveBlip(RegisteredBlips[blip.name].handle)
            RegisteredBlips[blip.name].handle = nil
        end
    else
        if HasJob(blip.permission, blip.jobGrade) then
            RegisteredBlips[blip.name] = ParseBlip(blip, invoker)
        end
    end
end