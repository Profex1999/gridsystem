FrameworkObject = {}

MyPed = nil
MyCoords = vector3(0,0,0)
CurrentZone = nil

local CurrentChunk = nil
local CurrentChunks = {}
local MarkersToCheck = {}
RegisteredMarkers = {}
RegisteredBlips = {}
MarkerWithJob = {}
TempMarkerWithJob = {}
CurrentJob = nil

LetSleep = true
local abs = math.abs

CreateThread(function()
    if Config.AutoCalculateFramework then CheckForFramework() end
    if Config.Framework == "ESX" then 
        FrameworkObject = exports["es_extended"]:getSharedObject()
        CurrentJob = ESX.GetPlayerData().job
    elseif Config.Framework == "qb-core" then 
        FrameworkObject = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayerData()
        CurrentJob = Player.job.name
    end
    RegisterTempMarkers()
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
	FrameworkObject = exports['qb-core']:GetCoreObject()
    local Player = QBCore.Functions.GetPlayerData()
    CurrentJob = Player.job
    RefreshBlips()
    RemoveAllJobMarkers()
    AddJobMarkers()
end)

RegisterNetEvent('esx:setJob', function(job)
    CurrentJob = job
    RefreshBlips()
    RemoveAllJobMarkers()
    AddJobMarkers()
end)

CreateThread(function()
    while true do
        MyPed = PlayerPedId()
        MyCoords = GetEntityCoords(MyPed)
        Wait(200)
    end
end)

CreateThread(function()
    while true do
        local chunk = GetCurrentChunk(MyCoords)
        if chunk ~= CurrentChunk then
            CurrentChunks = GetNearbyChunks(MyCoords)
        end
        MarkersToCheck = {}
        for i = 1, #CurrentChunks do
            if RegisteredMarkers[CurrentChunks[i]] then
                for zone = 1, #(RegisteredMarkers[CurrentChunks[i]]) do
                    MarkersToCheck[#MarkersToCheck + 1] = RegisteredMarkers[CurrentChunks[i]][zone]
                end
            end
        end
        Wait(1000)
    end
end)

AddEventHandler("gridsystem:hasEnteredMarker", function(zone)
    LogInfo(GetInvokingResource(), "Entered Marker: " .. zone.name)
    CreateThread(function()
        while CurrentZone do
            if zone and not zone.mustExit then
                if #(MyCoords.xy - zone.pos.xy) < #(zone.activationSize.xy/2) and math.abs(MyCoords.z - zone.pos.z) < zone.activationSize.z then
                    if not zone.show3D and not Config.UseCustomNotifications then
                        DisplayHelpTextThisFrame(zone.name, false)
                    end

                    -- check if the user is in the activation zone and if the control is pressed (e.g. zone.activationSize = vector3(1.0, 1.0, 1.0) and zone.control = 38)
                    if zone.control and IsControlJustReleased(0, zone.control) then
                        if zone.action then
                            local status, err = pcall(zone.action)
                            if not status then
                                LogErrorSkipConfig(GetInvokingResource(), string.format("Error executing action for marker %s. Error: %s", zone.name, err))
                            end
                        end

                        if zone.forceExit then
                            zone.mustExit = true
                        end
                    end
                end
            end
            Wait(0)
        end
    end)
    if #(MyCoords.xy - zone.pos.xy) < #(zone.scale.xy/2) and math.abs(MyCoords.z - zone.pos.z) < zone.scaleZ then
        if zone.onEnter then
            local status, err = pcall(zone.onEnter)
            if not status then
                LogErrorSkipConfig(GetInvokingResource(), string.format("Error executing action for marker %s. Error: %s", zone.name, err))
            end
        end
    else
        LogError(GetInvokingResource(), "Enter event triggered but player is outside of marker")
    end
end)

AddEventHandler("gridsystem:hasExitedMarker", function()
    if CurrentZone then
        LogInfo(GetInvokingResource(), "Exited Marker " .. CurrentZone.name)
        if CurrentZone.mustExit then
            CurrentZone.mustExit = nil
        end
        if CurrentZone.onExit then
            local status, err = pcall(CurrentZone.onExit)
            if not status then
                LogErrorSkipConfig(GetInvokingResource(), string.format("Error executing action for marker %s. Error: %s", CurrentZone.name, err))
            end
        end
        CurrentZone = nil
        ClearHelp(true)
    else
        LogError(GetInvokingResource(), "Error: exit event triggered but marker never entered")
    end
end)

CreateThread(function()
    local Sleep = 900
    local function _markerThread()
        local isInMarker, _currentZone = false, nil
        for i = 1, #MarkersToCheck do
            local zone = MarkersToCheck[i]
            local distance = #(MyCoords - zone.pos)
            if distance < zone.drawDistance then
                Sleep = 0
                if zone.show3D then
                    DrawText3D(zone.pos.x, zone.pos.y, zone.pos.z, zone.msg)
                elseif zone.type ~= -1 then
                    DrawMarker(zone.type, zone.pos, zone.dir, zone.rot, zone.scale, zone.color.r, zone.color.g, zone.color.b, zone.color.a, zone.bump, zone.faceCamera, 2, zone.rotate, zone.textureDict, zone.textureName, false)
                end
                if #(MyCoords.xy - zone.pos.xy) < #(zone.scale.xy/2) and abs(MyCoords.z - zone.pos.z) < zone.scaleZ then
                    isInMarker, _currentZone = true, zone
                end
            end
        end

		if isInMarker and not HasAlreadyEnteredMarker then
            CurrentZone = _currentZone
			HasAlreadyEnteredMarker = true
            if Config.UseCustomNotifications then
                Config.CustomNotificationFunctionEnter(_currentZone.msg)
            end
			TriggerEvent("gridsystem:hasEnteredMarker", _currentZone)
		end
		if HasAlreadyEnteredMarker and ( not isInMarker or _currentZone ~= CurrentZone) then
			HasAlreadyEnteredMarker = false
            if Config.UseCustomNotifications then
                Config.CustomNotificationFunctionExit()
            end
			TriggerEvent("gridsystem:hasExitedMarker")
		end
    end

    while true do
        local r, _e = pcall(_markerThread)
        if not r then
            LogErrorSkipConfig(GetInvokingResource(), "Error in marker compute:", _e)
        end
        Wait(Sleep)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    local markers = GetMarkersFromResource(resource)
    local blips = GetBlipsFromResource(resource)
    if #markers > 0 then
        for _, m in pairs(markers) do
            local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(m.name)
            if isRegistered then
                LogInfo(GetInvokingResource(), string.format("Removing Marker For Stopping of Resource %s: %s", resource, m.name))
                RegisteredMarkers[chunkId][index] = nil
            end
        end
    end
    if #blips > 0 then
        for i = 1, #blips do
            RemoveBlip(blips[i].handle)
            RegisteredBlips[blips[i].name] = nil
        end
    end
end)