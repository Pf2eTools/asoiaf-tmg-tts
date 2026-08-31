-- credit for the original mod and code goes to Z Games: https://steamcommunity.com/sharedfiles/filedetails/?id=1473990576

--current change note number or work shop item
VERSION_NUMBER = "233.0"

--require("vscode.console")
require("lua.const")

local Utils = require("lua.utils")
local UiUtil = require("lua.utils-ui")
local SettingsUtil = require("lua.settings")
local SaveGameUtils = require("lua.utils-savegame")
local EventUtils = require("lua.utils-events")
local UtilsDeadUnits = require("lua.utils-destroyed-units")
local Hotkeys = require("lua.hotkeys")


Clock = require("lua.clock")
-- global classes
require("lua.class")
require("lua.trays")
require("lua.grid")
require("lua.spawner")
require("lua.army-importer")
require("lua.faction-spawner")
require("lua.dicetray")

require("lua.custom-importer")
require("lua.ui-events")
require("lua.tacticsBoard")
require("lua.terrain")
require("lua.greetings")


local seedRandomNumbers = function()
  local seedModifier = Time.time

  if(Player.Blue.steam_id) then
    seedModifier = (seedModifier * Player.Blue.steam_id) / 2
  end

  if(Player.Red.steam_id) then
    seedModifier = seedModifier + (seedModifier * Player.Red.steam_id) / 2
  end

  math.randomseed(math.floor(seedModifier))
  startLuaCoroutine(Global, "popRandomNumbers")
end

function popRandomNumbers()
  for i=1, 12 do
    coroutine.yield(0)
    math.random()
  end

  return 1
end

local onLoad = function(params)
  local save_state = unpack(params)
  seedRandomNumbers()

  ArmyImporter.initImporters()
  FactionSpawner.initSpawners()
  DiceTray.initDiceTrays()

  SaveGameUtils.restoreSaveState(save_state)

  if Utils.isCleanLoad() then --let's mix things up a little
    log("Loading a fresh game...")
    SettingsUtil.doRandomizeSetting("background")
    SettingsUtil.doRandomizeSetting("battleMat")
  end

  Wait.frames(function()
    Clock:init()
    SettingsUtil.init()
    Hotkeys.addDiceHotkeys()
    UtilsDeadUnits.updateXml()
  end, 5)
  Wait.frames(function() Player["White"].changeColor("Blue") end, 20)
  Wait.time(function() doneLoading = true end, 6)
end
EventUtils.register("onload", onLoad)

function onSave()
  local save_state = SaveGameUtils.getSaveState()
  self.script_state = save_state
  return save_state
end

local onPlayerChangedColor = function (values)
  local color = unpack(values)
  if color == "White" then
    Player["White"].changeColor("Blue")
  end

  if color ~= "Grey" then
    if Player[color].admin == false then
      Player[color].promote()
    end
  end

  if color == "Blue" or color == "Red" then
    seedRandomNumbers()
  end

  UiUtil.updatePlayerName("Red")
  UiUtil.updatePlayerName("Blue")
end
EventUtils.register("onPlayerChangedColor", onPlayerChangedColor)

local onObjectEnterContainer = function(params)
  local container, obj = unpack(params)
  local containerGuid = container.guid

  if containerGuid == GUIDS["dead_units"]["Red"] then
    UtilsDeadUnits.executeOnContainerEnter(obj, "Blue")
  elseif containerGuid == GUIDS["dead_units"]["Blue"] then
    UtilsDeadUnits.executeOnContainerEnter(obj, "Red")
  end
end
EventUtils.register("onObjectEnterContainer", onObjectEnterContainer)

local onObjectSearchStart = function (obj, player_color)
  if obj.tag == "Deck" then
    broadcastToAll(Player[player_color].steam_name.." searches a deck", player_color)
    obj.highlightOn(player_color, 60)
  end
end
EventUtils.register("onObjectSearchStart", onObjectSearchStart)

local onObjectSearchEnd = function(obj, player_color)
  if obj.tag == "Deck" then
    obj.highlightOn(player_color, 8)
  end
end
EventUtils.register("onObjectSearchEnd", onObjectSearchEnd)

local onObjectPeek = function(obj, player_color)
  if obj.tag == "Deck" then
    broadcastToAll(Player[player_color].steam_name.." peeked under a deck", player_color)
    obj.highlightOn(player_color, 8)
  end
end
EventUtils.register("onObjectPeek", onObjectPeek)

local onPlayerTurn = function(player, previous)
  if SETTINGS.useClock then
    if player then
      Clock:onPlayerTurnStart(player)
    end
    if previous then
      Clock:onPlayerTurnEnd(previous)
    end
  end
end
EventUtils.register("onPlayerTurn", onPlayerTurn)

local onPlayerConnect = function(player)
  Wait.time(function()
    UiUtil.redraw()
    for guid, obj in pairs(gameObjects) do
      if obj.redrawUi then
        obj:redrawUi()
      end
    end
  end, 5)
end
EventUtils.register("onPlayerConnect", onPlayerConnect)

-- This needs to be global
function castDie(die)
  if die then
    local position = die.getPosition()

    if position.y < 12 then
        local velocity = die.getVelocity()
        die.setVelocity({0, velocity.y + math.random(4, 8), 0})
    end
    local angular = die.getAngularVelocity()
    local torqueX = angular.x < 0 and math.random(-10, -5) or math.random(5, 10)
    local torqueY = angular.y < 0 and math.random(-10, -5) or math.random(5, 10)
    local torqueZ = angular.z < 0 and math.random(-10, -5) or math.random(5, 10)
    die.addTorque(Vector(torqueX, torqueY, torqueZ), 3)
  end
end
local onObjectRandomize = function(obj, color)
    if obj.tag == "Dice" then
      local rotation = obj.getRotation()
      obj.setRotation({rotation.x + math.random(0, 180), rotation.y + math.random(0, 180), rotation.z + math.random(0, 180)})
      Wait.frames(function() castDie(obj) end, 1)
    end
end
EventUtils.register("onObjectRandomize", onObjectRandomize)


takeCardFunctions = {}
function onClickSpawnObjectiveCards()
  for _, func in pairs(takeCardFunctions) do
    func()
  end
end

function getFullName(obj)
  if obj == nil or obj.name == nil then
      return nil
  end
  local result = obj.name

  if obj.subname then
      result = result .. " - " .. obj.subname
  end

  return result
end