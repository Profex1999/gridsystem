ESX = nil

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

CreateThread(function ()
    while not ESX do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(10)
    end

    while not ESX.IsPlayerLoaded() do
        Wait(10)
    end

    CurrentJob = ESX.GetPlayerData().job
    RegisterTempMarkers()
end)

CreateThread(function ()
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
                for _, zone in pairs(RegisteredMarkers[CurrentChunks[i]]) do
                    table.insert(MarkersToCheck, zone)
                end
            end
        end
        Wait(1000)
    end
end)

CreateThread(function ()
    while true do
        local isInMarker, _currentZone = false, nil
        LetSleep = true
        for i = 1, #MarkersToCheck do
            local zone = MarkersToCheck[i]
            local distance = #(MyCoords - zone.pos)
            if distance < zone.drawDistance then
                LetSleep = false
                if zone.show3D then
                    DrawText3D(zone.pos.x, zone.pos.y, zone.pos.z, zone.msg)
                else
                    if zone.type ~= -1 then
                        DrawMarker(zone.type, zone.pos, zone.dir, zone.rot, zone.scale, zone.color.r, zone.color.g, zone.color.b, zone.color.a, zone.bump, zone.faceCamera, 2, zone.rotate, zone.textureDict, zone.textureName, false)
                    end
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
        Wait(3)
		if LetSleep then
			Citizen.Wait(700)
		end
    end
end)