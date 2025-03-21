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
| `rot` | The rotation for the marker | vector3 | ❌ | `vector3(0.0, 0.0, 0.0)` |
| `dir` | The direction vector for the marker | vector3 | ❌ | `vector3(0.0, 0.0, 0.0)` |
| `faceCamera` | If the marker should always face the camera | boolean | ❌ | **true** |
| `bump` | Whether or not the marker should slowly animate up/down | boolean | ❌ | **false** |
| `bump` | Whether or not the marker should slowly rotate its heading | boolean | ❌ | **false** |
| `msg` | Message on the top left when inside the marker | string | ❌ | `NO TEXT PROVIDED` |
| `drawDistance` | Distance when the marker start rendering | number | ❌ | 15.0 |
| `control` | Key to press to perform action | string or number | ❌ | `E` |
| `forceExit` | If set to true, once you press the control key inside the marker, you must exit and enter again to be able to press the control key again. | boolean | ❌ | **false** |
| `show3D` | Draw a 3D text in the world instead of top left notification.<br/> If set to true overrides drawDistance (if it was specified before) and fields `color`, `type`, `scale` are ignored. | boolean | ❌ | **false** |
| `type` | Marker type.<br/> Full list [Here](https://docs.fivem.net/docs/game-references/markers/) | number | ❌ | 20 |
| `color` | Color of the marker in the format `{r = num , g = num, b = num }` | table | ❌ | `{ r = 255, g = 0, b = 0 }` |
| `textureDict` | - | string | ❌ | |
| `textureName` | - | string | ❌ | |
| `action` | Callback function called when control key is pressed | function | ❌ | Empty function |
| `onEnter` | Callback function called when entering the marker | function | ❌ | |
| `onExit` | Callback function called when exiting the marker | function | ❌ | |
| `blip` | Blip object in case you want to create a blip, along side of the marker.<br/> Defining the blip here, **does not** require the `blip.name` | table | ❌ | |

The default behaviour of all these customizations can be changed in the `config.lua` file.

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

# Contributors

| Owner | <a href="https://github.com/Profex1999">Profex1999</a> | <img src="https://avatars.githubusercontent.com/u/51895814?v=4" width="50" alt="Profex1999" style="border-radius:50%" /> |
|--------------|--------------|--------------|
| Repo maintainer | <a href="https://github.com/zThundy">zThundy</a> | <img src="https://avatars.githubusercontent.com/u/25564154?v=4" width="50" alt="zThundy" style="border-radius:50%" /> |
| Contributor | <a href="https://github.com/Mycroft-Studios">Mycroft-Studios</a> | <img src="https://avatars.githubusercontent.com/u/22378232?v=4" width="50" alt="Mycroft-Studios" style="border-radius:50%" /> |