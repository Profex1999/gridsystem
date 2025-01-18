# Gridsystem

Marker handling resource for FiveM

This resource make it easy to handle markers in one single resource. Markers are registered within "chunks" and all the maths is done based on the chunk the player is in.

## How to register a marker or a blip

First you create a table with the following params
> Note: You can still use the event to register markers; **keep in mind that it is legacy and will most likely be deprecated!**

| Field Name | Description | Type | Required | Default Value |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------|------------------------------|
| `name` | Unique name of the marker | string | ✅ | |
| `pos` | Position of the marker | vector3 | ✅ | |
| `scale` | Scale of the marker | vector3 | ❌ | `vector3(1.5, 1.5, 1.5)` |
| `msg` | Message on the top left when inside the marker | string | ❌ | `NO TEXT PROVIDED` |
| `drawDistance` | Distance when the marker start rendering | number | ❌ | 15.0 |
| `control` | Key to press to perform action | string or number | ❌ | 'E' |
| `forceExit` | If set to true, once you press the control key inside the marker, you must exit and enter again to be able to press the control key again. | boolean | ❌ | false |
| `show3D` | Draw a 3D text in the world instead of top left notification.<br/> If set to true overrides drawDistance (if it was specified before) and fields `color`, `type`, `scale` are ignored. | boolean | ❌ | false |
| `type` | Marker type. Full list [Here](https://docs.fivem.net/docs/game-references/markers/) | number | ❌ | 20 |
| `color` | Color of the marker in the format `{r = num , g = num, b = num }` | table | ❌ | `{ r = 255, g = 0, b = 0 }` |
| `activationSize` | Size of the action range. | vector3 | ❌ | If not defined, the `scale` will be used |
| `action` | Callback function called when control key is pressed | function | ❌ | Empty function |
| `onEnter` | Callback function called when entering the marker | function | ❌ | |
| `onExit` | Callback function called when exiting the marker | function | ❌ | |
| `blip` | Blip object in case you want to create a blip, along side of the marker.<br/> Defining the blip here, **does not** require the `blip.name` | object | ❌ | |

Example for marker:

```lua
local Grids = exports["gridsystem"]:GetObject()
Grids.registerMarker({
  name = 'a_unique_name_for_this_marker',
  pos = vector3(0.0, 0.0, 0.0),
  scale = vector3(1.5, 1.5, 1.5),
  msg = 'Press ~INPUT_CONTEXT~ to do something',
  control = 38,
  type = 20,
  color = { r = 130, g = 120, b = 110 },
  action = function()
    print('This is executed when you press E in the marker')
  end,
  onEnter = function()
    print('This is executed when you enter a marker')
  end,
  onExit = function()
    print('This is executed when you eixit a marker')
  end
})
```

Example for blip:

```lua
local Grids = exports["gridsystem"]:GetObject()
Grids.registerBlip({
  name = "a_unique_name_for_this_blip",
  pos = vector3(0.0, 0.0, 0.0),
  scale = 1.0,
  sprite = 1,
  display = 1,
  color = 1,
  shortRange = false,
  label = "Showcase Blip"
})
```

You can remove a marker by doing

```lua
Grids.unregisterMarker("name_of_the_marker")
```

You can remove a blip by doing

```lua
Grids.removeBlip("name_of_the_blip")
```

## Supported exports

Following here there is the list of supported exports you can use if you don't want to import the entire GridSystem API

```lua

-- Where:
--    @marker is the marker object explained at the top
--    @blip (optional) is the blip that will be created and assigned to the marker
exports["gridsystem"]:RegisterMarker(marker, blip)

-- Where:
--    @blip is the blip object that will be used and parsed to create the blip on the map
exports["gridsystem"]:RegisterBlip(blip)

-- Where:
--    @blipName is the name provided in the blip object when it was registered
exports["gridsystem"]:RemoveBlip(blipName)

-- Where:
--    @markerName is the name provided in the marker object when it was registered
exports["gridsystem"]:UnregisterMarker(markerName)

```

## How to register a marker with job

### Supported frameworks
- QB-Core
- ES Extended (ESX)
- Standalone

For creating a marker or a blip, only visible and accessible to a specific job in your framework, add these two (optional) fields in the marker/blip object when registering it<br/>
Same thing applies for blip object configuration.

| Field Name | Description | Type | Required | Default Value |
|--------------|-------------------------------------------------|--------|----------|------------------------------|
| `permission` | Job name | string | ❌ | |
| `jobGrade` | Job grade required if not set, 0 will be used. | number | ❌ | |

# License

### AGPL-3.0 license