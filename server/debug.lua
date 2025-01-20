RegisterCommand("grid_dump", function(source)
    if not Config.Debug then return end
    TriggerClientEvent("gridsystem:requestMarkersData", source)
end, true)

RegisterServerEvent("gridsystem:sendMarkersData", function(markers)
    local fileName = "marker_dump.json"
    if not LoadResourceFile(GetCurrentResourceName(), fileName) then
        SaveResourceFile(GetCurrentResourceName(), fileName, "", -1)
    else
        SaveResourceFile(GetCurrentResourceName(), fileName, "", 0)
    end
    local file = LoadResourceFile(GetCurrentResourceName(), fileName)
    SaveResourceFile(GetCurrentResourceName(), fileName, file .. json.encode(markers, { indent = true }) .. "\n", -1)
end)