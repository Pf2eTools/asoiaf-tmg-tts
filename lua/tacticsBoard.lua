local TableUtils = require("lua.utils-table")
local Utils = require("lua.utils")
local EventUtils = require("lua.utils-events")
local UiUtil = require("lua.utils-ui")

local TacticsBoard = {
    specialTactics = {
        Blue = nil,
        Red = nil
    }
}
local TacticsUi = {}

function TacticsBoard.placeNCU(obj, zone)
  local zoneName = TableUtils.getKeyByVal(GUIDS["tactics_zones"], zone.guid)
  if zoneName ~= nil then
      zoneName = Utils:firstToUpper(zoneName)
  end

  if Utils.containerContainsObject(zone, obj) then
      local portrait = obj.getGMNotes()
      local color = obj.getVar("owner")
      TacticsUi.placeNCU(zoneName, portrait, color)
  end
end

function TacticsBoard.removeNCU(obj, zone)
  local zoneName = TableUtils.getKeyByVal(GUIDS["tactics_zones"], zone.guid)

  if zoneName then
      zoneName = Utils:firstToUpper(zoneName)
  end

  if TableUtils.some(zone.getObjects(), function(o) return o.hasTag("NCU") end) then
      return
  end

  TacticsUi.removeNCU(zoneName)
end


local onEnter_TacticsZone = function(params)
    local zone, obj = unpack(params)
    if not obj.hasTag("NCU") then
        return
    end
    if not TableUtils.hasValue(GUIDS["tactics_zones"], zone.guid) then
        return
    end
    Wait.condition(function() TacticsBoard.placeNCU(obj, zone) end, function() return obj.resting end)
end
EventUtils.register("onObjectEnterZone", onEnter_TacticsZone)

local onLeave_TacticsZone = function(params)
    local zone, obj = unpack(params)
    if not TableUtils.hasValue(GUIDS["tactics_zones"], zone.guid) then
      return
    end
    Wait.condition(function() TacticsBoard.removeNCU(obj, zone) end, function() return obj.resting end)
end
EventUtils.register("onObjectLeaveZone", onLeave_TacticsZone)


local switchFirstPlayerMarker = function()
  local firstPlayer = getObjectFromGUID(GUIDS["first_player_throne"]) or getObjectFromGUID(GUIDS["first_player_standee"])
  if firstPlayer then
    local oldPosition = firstPlayer.getPosition()
    firstPlayer.setPositionSmooth({oldPosition.x, oldPosition.y, oldPosition.z*-1}, false, true)
    firstPlayer.rotate({0, 180, 0})
  end
end

local function endRound(round)
  for _, obj in pairs(gameObjects) do
      if obj.onEndRound ~= nil then
        obj:onEndRound()
      end
  end

  for guid, location in pairs(ncuPositions) do
    if location ~= nil then
      local ncu = getObjectFromGUID(guid)

      if ncu ~= nil then
        ncu.setPositionSmooth(location.position, false, true)
        if ncu.tag == "Card" then --don't flip cards back over
          local z = ncu.getRotation().z

          if z-180 < -1 or z-180 > 1 then
            z = location.rotation.z
          end

          ncu.setRotation({location.rotation.x, location.rotation.y, z})
        else
          ncu.setRotation(location.rotation)
        end
      end
    end
  end

  for _, guid in pairs(TableUtils.values(GUIDS["ncu_zone_resting"])) do
    for _, obj in ipairs(getObjectFromGUID(guid).getObjects()) do
      if obj.type == "Tile" then
        obj.setPositionSmooth(obj.getPosition() + Vector({0, 0.3, 0}))
      end
    end
  end

  switchFirstPlayerMarker()
  broadcastToAll("Round " .. round)
  currentRound = round
  TacticsUi.updateRound()
end

local onEnter_RoundZone = function(params)
    local zone, obj = unpack(params)
    if not TableUtils.hasValue(GUIDS["tactics_round"], zone.guid) then
        return
    end
    if obj.getName() ~= "Round" then
        return
    end
    local roundNumber = TableUtils.getIdx(GUIDS["tactics_round"], zone.guid)

    Wait.condition(function()
      endRound(roundNumber)
    end, function()
        return obj.resting
    end)
end
EventUtils.register("onObjectEnterZone", onEnter_RoundZone)


local onEnter_NCURestingZone = function(params)
    local zone, obj = unpack(params)
    if not TableUtils.hasValue(GUIDS["ncu_zone_resting"], zone.guid) then
        return
    end
    if not obj.hasTag("NCU") and not obj.hasTag("NCUcard") then
        return
    end

    Wait.condition(function()
        if ncuPositions[obj.guid] == nil then
            ncuPositions[obj.guid] = {
                position = obj.getPosition(),
                rotation = obj.getRotation()
            }
        end
    end, function()
        return obj.resting
    end)
end
EventUtils.register("onObjectEnterZone", onEnter_NCURestingZone)


local onEnter_FirstPlayerZone = function(params)
    local zone, obj = unpack(params)
    if not TableUtils.hasValue(GUIDS["tactics_first_player"], zone.guid) then
        return
    end
    if obj.getName() ~= "First Player" then
        return
    end
    local zoneColor = TableUtils.getKeyByVal(GUIDS["tactics_first_player"], zone.guid)
    if firstPlayerColor == zoneColor then
      return
    end
    Wait.condition(function()
        if not Utils.containerContainsObject(zone, obj) then
            return
        end
        firstPlayerColor = zoneColor
        local playerID = UiUtil.getPlayerName(zoneColor)
        broadcastToAll(playerID .. " is now first player", zoneColor)
        TacticsUi.updateFirstPlayer()
    end, function ()
        return obj.resting
    end)
end
EventUtils.register("onObjectEnterZone", onEnter_FirstPlayerZone)


function TacticsUi.updateFirstPlayer()
  UI.setAttribute("tacticsPanelBottom__RoundOverlay", "image", firstPlayerColor .. "Zone")
  UI.setAttribute("tacticsPanelSide__RoundOverlay", "image", firstPlayerColor .. "Zone")
end

function TacticsUi.updateRound()
  UI.setAttribute("tacticsPanelBottom__Round", "image", "Round" .. currentRound)
  UI.setAttribute("tacticsPanelSide__Round", "image", "Round" .. currentRound)
end

function TacticsUi.placeNCU(zone, portrait, color)
  if zone == nil then
    return
  end

  if portrait then
    UI.setAttribute("tacticsPanelBottom__".. zone, "image", string.upper(portrait))
    UI.setAttribute("tacticsPanelSide__".. zone, "image", string.upper(portrait))
  end

  if color then
    UI.setAttribute("tacticsPanelBottom__" .. zone .. "Overlay", "image", color .. "Zone")
    UI.setAttribute("tacticsPanelSide__" .. zone .. "Overlay", "image", color .. "Zone")
  end
end

function TacticsUi.removeNCU(zone)
    UI.setAttribute("tacticsPanelBottom__".. zone, "image", TacticsBoard.specialTactics[zone] or zone)
    UI.setAttribute("tacticsPanelSide__".. zone, "image", TacticsBoard.specialTactics[zone] or zone)

    UI.setAttribute("tacticsPanelBottom__" .. zone .. "Overlay", "image", "BlankZone")
    UI.setAttribute("tacticsPanelSide__" .. zone .. "Overlay", "image", "BlankZone")
end

function TacticsUi.setSpecialTacticsZone(color, zone)
  local imageSize = 85
  local paddingSize = 5
  local numZones = 7 + TableUtils.len(TacticsBoard.specialTactics)

  UI.setAttribute("tacticsPanelBottom__wrp" .. color, "active", true)
  UI.setAttribute("tacticsPanelSide__wrp" .. color, "active", true)

  UI.setAttribute("tacticsPanelBottom__wrp" .. color .. "Overlay", "active", true)
  UI.setAttribute("tacticsPanelSide__wrp" .. color .. "Overlay", "active", true)

  UI.setAttribute("tacticsPanelBottom", "width", numZones * imageSize + (numZones - 1) * paddingSize)
  UI.setAttribute("tacticsPanelSide", "height", numZones * imageSize + (numZones - 1) * paddingSize)

  UI.setAttribute("tacticsPanelBottom__" .. color, "image", zone)
  UI.setAttribute("tacticsPanelSide__" .. color, "image", zone)

  UI.setAttribute("tacticsPanelBottom__" .. color .. "Overlay", "image", zone)
  UI.setAttribute("tacticsPanelSide__" .. color .. "Overlay", "image", zone)
end

return {TacticsBoard, TacticsUi}