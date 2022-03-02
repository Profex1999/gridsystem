function ParseBlip(b, invoker)
    if type(b.pos) ~= "vector3" then LogMissingField("Blip creation failed: position is not vector3 or missing",b.name, invoker); return nil; end
    if not b.scale or type(b.scale) ~= "number" then b.scale = Config.DefaultBlipProperties.scale; end
    if not b.sprite or type(b.sprite) ~= "number" then b.sprite = Config.DefaultBlipProperties.sprite; end
    if not b.display or type(b.display) ~= "number" then b.display = Config.DefaultBlipProperties.display; end
    if not b.color or type(b.color) ~= "number" then b.color = Config.DefaultBlipProperties.color; end
    if not b.shortRange or type(b.shortRange) ~= "boolean" then b.shortRange = Config.DefaultBlipProperties.shortRange; end
    if not b.label or type(b.label) ~= "string" then b.label = Config.DefaultBlipProperties.label; end
    if not b.resource then
        b.resource = invoker
    end
    b.handle = AddBlipForCoord(b.pos)
    SetBlipSprite (b.handle, b.sprite)
    SetBlipDisplay(b.handle, b.display)
    SetBlipScale  (b.handle, b.scale)
    SetBlipColour (b.handle, b.color)
    SetBlipAsShortRange(b.handle, b.shortRange)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(b.label)
    EndTextCommandSetBlipName(b.handle)
    return b
end