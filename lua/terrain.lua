local EventUtils = require("lua.utils-events")

local aoeScaleX = 4.54
local aoeScaleZ = 4.54
local hoveredObjects = {}
local terrainAoeImages = {
  ["Weirwood Tree"] = "https://steamusercontent-a.akamaihd.net/ugc/2527165944742958879/5C431B81FBCCF1A670F98B932DCD7331FD8B2ED6/",
  ["Corpse Pile"] = "https://steamusercontent-a.akamaihd.net/ugc/2527165944779800819/F593DD104551F683657E59024479C2FEAABDD0C0/"
}

local function spawnAOE(object)
  local aoeImage = terrainAoeImages[object.getName()]

  if aoeImage == nil then
      return
  end

  local aoe = spawnObject({
    type = "Custom_Token",
    position = {object.getPosition().x, 1.6, object.getPosition().z},
    rotation = object.getRotation(),
    scale = {aoeScaleX, 1, aoeScaleZ},
    sound = false
  })
  aoe.setCustomObject(
    {
      image = aoeImage,
      thickness = 0.1,
      merge_distance = 15,
      stackable = false
    }
  )

  aoe.setColorTint({1,1,1,0})
  aoe.locked = true
  aoe.interactable = false
  object.setVar("aoe", aoe)

  Wait.frames(function() aoe.highlightOn(SETTINGS.rulerColorTint) end, 3)
end

local function clearAOE(object)
  if object == nil then
      return
  end

  hoveredObjects[object.getGUID()] = false

  local aoe = object.getVar("aoe")

  if aoe then
    aoe.destruct()
    object.setVar("aoe", nil)
  end
end

local function checkMouseLeave(object)
  for _, player in ipairs(Player.getPlayers()) do
    local holdingObjects = player.getHoldingObjects()
    local hoveredObject = player.getHoverObject()
    if holdingObjects == nil then
      holdingObjects = {}
    end
    if hoveredObject ~= nil then
      table.insert(holdingObjects, hoveredObject)
    end

    for __, heldObject in ipairs(holdingObjects) do
      if heldObject ~= nil and heldObject.getGUID() == object.getGUID() then
        local aoe = object.getVar("aoe")

        if aoe then
          aoe.setPosition({object.getPosition().x, 1.6, object.getPosition().z})
          aoe.setRotation(object.getRotation())
        end

        Wait.frames(function() checkMouseLeave(object) end, 2)

        return
      end
    end
  end

  clearAOE(object)
  object.highlightOff()
  hoveredObjects[object.getGUID()] = false
end


local onObjectDestroy = function(params)
  local object = unpack(params)
  if object and hoveredObjects and hoveredObjects[object.getGUID()] then
    clearAOE(object)
  end
end
EventUtils.register("onObjectDestroy", onObjectDestroy)

local onObjectHover = function(params)
  local player_color, object = unpack(params)
  if object == nil or not object.hasTag("Terrain") then
    return
  end

  local guid = object.getGUID()

  if not hoveredObjects[guid] then
      hoveredObjects[guid] = true
      spawnAOE(object)
      Wait.frames(function() checkMouseLeave(object) end, 2)
  end

end
EventUtils.register("onObjectHover", onObjectHover)
