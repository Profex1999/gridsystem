ESX = nil

MyPed = nil
MyCoords = vector3(0,0,0)
CurrentZone = nil

local CurrentChunk = nil
local CurrentChunks = {}
local MarkersToCheck = {}
RegisteredMarkers = {}
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
                if zone.show3D then --Classico 3dtext
                    DrawText3D(zone.pos.x, zone.pos.y, zone.pos.z+0.5, zone.msg) --  il +0.5 e modificabile a piacimento 
                    
                elseif zone.show3Dme then --3d text sul giocatore
                    DrawText3D(MyCoords.x, MyCoords.y, MyCoords.z+0.5, zone.msg) --  il +0.5 e modificabile a piacimento  
                else
                    if zone.type ~= -1 then -- Nuovo marcher modificabile con orientation2 oer i primi 3 valori di rotazione e orientation per i secondi 3  alpha (trasparenza del blip),salta permette al blip di saltare sul psoto ,segue lo suardo , p19 (flag per la rotazione o per il seguire Controlare Documentazione nativa sul DrawMarker) 
                        DrawMarker(zone.type, zone.pos,zone.orientation2.x, zone.orientation2.y, zone.orientation2.z,  zone.orientation.x, zone.orientation.y, zone.orientation.z, zone.scale.x, zone.scale.y, zone.scale.z, zone.color.r, zone.color.g, zone.color.b, zone.alpha, zone.salta, zone.segue, zone.p19, zone.rotation, false, false, false)
                    end
                end
                
                if #(MyCoords.xy - zone.pos.xy) < #(zone.interact.xy/2) and abs(MyCoords.z - zone.pos.z) < zone.interactZ then
                    isInMarker, _currentZone = true, zone
                    
                end
            end
        end

		if isInMarker and not HasAlreadyEnteredMarker then
            CurrentZone = _currentZone
			HasAlreadyEnteredMarker = true
			TriggerEvent("gridsystem:hasEnteredMarker", _currentZone)
		end
		if HasAlreadyEnteredMarker and ( not isInMarker or _currentZone ~= CurrentZone) then
			HasAlreadyEnteredMarker = false
			TriggerEvent("gridsystem:hasExitedMarker")
		end
        Wait(3)
		if LetSleep then
			Citizen.Wait(700)
		end
    end
end)

CreateThread(function ()
    while true do
        if CurrentZone then
            local _zone = CurrentZone
            if _zone and not _zone.mustExit then
                if not _zone.show3D then
                    DisplayHelpTextThisFrame(_zone.name, false)
                end

                if IsControlJustReleased(0, _zone.control) then 
                    if _zone.action then
                        local status, err = pcall(_zone.action)
                        if not status then
                            LogError(string.format("Error executing action for marker %s. Error: %s", _zone.name, err))
                        end
                    end

                    if _zone.forceExit then
                        CurrentZone.mustExit = true
                    end
                end
            end
        end
        Wait(0)
        if LetSleep then
            Wait(700)
        end
    end
end)