Config = {}

-- Debug mode
Config.Debug = false

-- Frameworks: ESX, qb-core, standalone
Config.Framework = "none"  -- ESX/qb-core/none
-- If the script should try to automatically detect the framework
Config.AutoCalculateFramework = true

-- These are the default properties for markers
--  If one of these properties is not provided during the registration process of markers,
--  the default value defined here will be used.
Config.DefaultMarkerProperties = {
    color = { r = 255, g = 0, b = 0, a = 50 },
    scale = vector3(1.0, 1.0, 1.0),
    drawDistance = 15.0,
    control = 38, -- E (https://docs.fivem.net/docs/game-references/controls/)
    dir = vector3(0.0, 0.0, 0.0),
    rot = vector3(0.0, 0.0, 0.0),
    faceCamera = true,
    bump = false,
    rotate = false,
}

Config.DefaultBlipProperties = {
    sprite  = 60,
    display = 4,
    scale   = 1.0,
    color  = 29,
    shortRange = true,
    label = "DEFAULT_BLIP_LABEL",
}

Config.UseCustomNotifications = false
Config.CustomNotificationFunctionEnter = function (message)
    --Here you can trigger a custom event/call export function to display a notification
    --message is the msg param you passed to the marker
    --Example: TriggerEvent('my_custom_event', message)
    --Example: exports['my_custom_export']:my_custom_export_function(message)
    -- for ESX Useage:
        -- exports["esx_textui"]:TextUI(message, "info")
    -- for Qb-core Useage:
        -- exports['qb-core']:DrawText(message,'right')
end

Config.CustomUseNotificationFunctionExit = function()
    --Here you can trigger a custom event/call export function to hide a notification set by Config.CustomNotificationFunctionEnter
    --https://github.com/dsheedes/cd_drawtextui Example: TriggerEvent('cd_drawtextui:HideUI')
    --Be aware that this function is only called when you exit the marker, not every tick.
    --Code inside this will work only if Config.UseCustomNotifications is set to true
    -- for ESX Useage:
        -- exports["esx_textui"]:HideUI()
    -- for Qb-core Useage:
        -- exports['qb-core']:HideText()
end