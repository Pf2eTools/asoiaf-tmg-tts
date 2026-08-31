local Setup = require("lua.setup")
local UiUtil = require("lua.utils-ui")
local Utils = require("lua.utils")


function onShowTerrainOptions_Click(player)
    UiUtil.hide("showTerrainOptionsButton", player.color)
    UiUtil.show("hideTerrainOptionsButton", player.color)
    UiUtil.show("terrainPanel", player.color)
end

function onHideTerrainOptions_Click(player)
    UiUtil.show("showTerrainOptionsButton", player.color)
    UiUtil.hide("hideTerrainOptionsButton", player.color)
    UiUtil.hide("terrainPanel", player.color)
    UiUtil.hide("confirmButton", player.color)
    UiUtil.hide("cancelButton", player.color)
end

function onReadyTerrain_Click()
  Setup.readyTerrain()
  Setup.lockGameMode()
end

function onReadyTerrainAndObjectives_Click()
  Setup.readyTerrain()
  Setup.readyObjectives()
  Setup.lockGameMode()
end

function onClearTerrain_Click(player)
    broadcastToColor("Do you really want to clear all terrain pieces?", player.color, "Red")
    UiUtil.show("confirmButton", player.color)
    UiUtil.show("cancelButton", player.color)
end

function onConfirm_Click(player)
  for i, obj in pairs(Utils.getObjectsWithTagsOnBoard({"Terrain", "Objective", "ObjectiveCard"})) do
    obj.destruct()
  end

  UiUtil.hide("confirmButton", player.color)
  UiUtil.hide("cancelButton", player.color)
end

function onCancel_Click(player)
  UiUtil.hide("confirmButton", player.color)
  UiUtil.hide("cancelButton", player.color)
end

function onSwapSides_Click()
  for _, obj in ipairs(Utils.getObjectsWithTagsOnBoard({"Terrain", "Objective", "ObjectiveCard"})) do
    local pos = obj.getPosition()
    local rot = obj.getRotation()
    obj.setRotation(rot + Vector({0, 180, 0}))
    obj.setPosition(pos:rotateOver("y", 180))
  end

  local battleMat = getObjectFromGUID(GUIDS["battleMat"])
  battleMat.setRotation(battleMat.getRotation() + Vector({0, 180, 0}))
end

function onGreyCameraClick(player, value, id)
  player.lookAt({
  position = {x=-9,y=0,z=0},
  pitch    = -90,
  yaw      = 0,
  distance = 48
  })
  player.setCameraMode("TopDown")
end

function onBlueCameraClick(player, value, id)
  player.lookAt({
  position = {x=-10.5,y=0,z=-5.25},
  pitch    = 45,
  yaw      = 0,
  distance = 48
  })
end

function onRedCameraClick(player, value, id)
  player.lookAt({
  position = {x=-10.5,y=0,z=5.25},
  pitch    = 45,
  yaw      = 180,
  distance = 48
  })
end

function onRedAndBlueCameraClick(player, value, id)
  player.lookAt({
  position = {x=-20,y=0,z=0},
  pitch    = 40,
  yaw      = 90,
  distance = 50
  })
end

function onHighlightObjectives_Click(player, value, id)
  for _, obj in ipairs(Utils.getObjectsWithTagsOnBoard({"Objective"})) do
    obj.highlightOn(SETTINGS.rulerColorTint, 7)
  end
end

function onHighlightUnactivatedUnits_Click(player, value, id)
  for _, obj in pairs(gameObjects) do
    if obj.onHighlightUnactivated ~= nil then
      obj:onHighlightUnactivated()
    end
  end
end

function onToggleTacticsBoardUI_Click(player)
  UiUtil.toggleVisibility("tacticsPanelSide", player.color)
  UiUtil.toggleVisibility("tacticsPanelBottom", player.color)
end

function onGreetingsClick(player)
  UiUtil.toggleVisibility("modal__greetings", player.color)
end
