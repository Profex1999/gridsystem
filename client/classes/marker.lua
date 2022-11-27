function ParseMarker(m, invoker)
    if not m.name then LogError("Marker creation failed: name not provided", invoker); return nil; end
    if not m.pos then LogError("Marker creation failed: position not provided", invoker); return nil; end
    if type(m.pos) ~= "vector3" then LogError("Marker creation failed: position is not vector3", invoker); return nil end
    if type(m.dir) ~= "vector3" then m.dir = Config.DefaultMarkerProperties.dir; end
    if type(m.rot) ~= "vector3" then m.rot = Config.DefaultMarkerProperties.rot; end
    if type(m.faceCamera) ~= "boolean" then m.faceCamera = Config.DefaultMarkerProperties.faceCamera; end
    if type(m.bump) ~= "boolean" then m.bump = Config.DefaultMarkerProperties.bump; end
    if type(m.rotate) ~= "boolean" then m.rotate = Config.DefaultMarkerProperties.rotate; end 
    if not m.scale or type(m.scale) ~= 'vector3' then
        m.scale = Config.DefaultMarkerProperties.scale
    end
    m.scaleZ = m.scale.z --save for later use
    if type(m.drawDistance) ~= "number" then m.drawDistance = Config.DefaultMarkerProperties.drawDistance; end

    if not m.control or type(m.control) ~= "number" then m.control = Config.DefaultMarkerProperties.control;
    elseif type(m.control) == "string" then
        m.control = m.control or Config.DefaultMarkerProperties.control
    end

    if type(m.forceExit) ~= "boolean" and type(m.forceExit) ~="nil" then
        LogBadFormat("forceExit", m.name, invoker)
    end

    if type(m.msg) ~= 'string' then
        m.msg = "NO TEXT PROVIDED"
        LogBadFormat("msg", m.name, invoker)
    end

    if m.show3D then
        m.drawDistance = 5.0
    else
        if not m.type then m.type = 20 end
        if m.type == 1 or m.type == 23 or m.type > 24 and m.type < 28 or m.type == 44 then
            m.pos = m.pos - vector3(0, 0, 0.97)
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
    if not m.action then LogMissingField("action", m.name, invoker); m.action = function () end; end
    m.resource = invoker
    if m.job then m.permission = m.job end
    return m
end
