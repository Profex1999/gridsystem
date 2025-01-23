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

function ParseMarker(m, invoker)
    if not m.name then LogError(invoker, "Marker creation failed: name not provided"); return nil; end
    if not m.pos and not m.coords then LogError(invoker, "Marker creation failed: position not provided"); return nil; end
    if m.coords then m.pos = vector3(m.coords.x, m.coords.y, m.coords.z); LogWarning(invoker, "coords field is deprecated, please use pos instead"); end
    if type(m.pos) ~= "vector3" then LogError(invoker, "Marker creation failed: position is not vector3"); return nil end
    if type(m.dir) ~= "vector3" then m.dir = Config.DefaultMarkerProperties.dir; end
    if type(m.rot) ~= "vector3" then m.rot = Config.DefaultMarkerProperties.rot; end
    if type(m.faceCamera) ~= "boolean" then m.faceCamera = Config.DefaultMarkerProperties.faceCamera; end
    if type(m.bump) ~= "boolean" then m.bump = Config.DefaultMarkerProperties.bump; end
    if type(m.rotate) ~= "boolean" then m.rotate = Config.DefaultMarkerProperties.rotate; end 
    if not m.scale or type(m.scale) ~= 'vector3' then
        LogWarning(invoker, "Scale not provided or invalid, using default scale")
        m.scale = Config.DefaultMarkerProperties.scale
    end
    m.scaleZ = m.scale.z --save for later use
    if type(m.drawDistance) ~= "number" then m.drawDistance = Config.DefaultMarkerProperties.drawDistance; end

    if not m.control then
        LogMissingField(invoker, "control", m.name)
        m.control = Config.DefaultMarkerProperties.control
    end
    if type(m.control) == "string" then
        if Keys[m.control] then
            m.control = Keys[m.control]
        else
            LogBadFormat(invoker, "control", m.name)
            m.control = Config.DefaultMarkerProperties.control
        end
    end

    if type(m.forceExit) ~= "boolean" and type(m.forceExit) ~="nil" then
        LogBadFormat(invoker,"forceExit", m.name)
    end

    if type(m.msg) ~= 'string' then
        m.msg = "NO TEXT PROVIDED"
        LogBadFormat(invoker, "msg", m.name)
    end

    if m.show3D then
        m.drawDistance = 5.0
    else
        if not m.type then m.type = 20 end
        if m.type == 1 or m.type == 23 or m.type > 24 and (m.type < 28 or m.type == 44) and m.type ~= 27 then
            -- m.pos = m.pos - vector3(0, 0, 0.97)
            m.scaleZ = m.scaleZ + 1
        end
        AddTextEntry(m.name, m.msg)
        
        if not m.color then m.color = Config.DefaultMarkerProperties.color; end
        if type(m.color) ~= "table" or not (m.color.r and m.color.g and m.color.b) then
            LogBadFormat("color", m.name)
            m.color = Config.DefaultMarkerProperties.color
        end
        if not m.color.a then m.color.a = Config.DefaultMarkerProperties.color.a end
    end
    if not m.action then LogMissingField(invoker, "action", m.name); m.action = function () end; end
    m.resource = invoker
    if m.job then m.permission = m.job end
    return m
end
