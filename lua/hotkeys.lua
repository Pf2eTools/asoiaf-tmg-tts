local function getHotkeyDiceColor(playerColor)
  local colorToRoll = playerColor
  if playerColor == "Orange" and SETTINGS["playerCount"] == "2 vs 2" then
    colorToRoll = "Red"
  elseif playerColor == "Teal" and SETTINGS["playerCount"] == "2 vs 2" then
    colorToRoll = "Blue"
  end
  if colorToRoll ~= "Blue" and colorToRoll ~= "Red" then
    return nil
  else
    return colorToRoll
  end
end

local function onPressedDiceHotkey(num, playerColor, hov, ptrPos, isKeyUp)
    local colorToRoll = getHotkeyDiceColor(playerColor)
    if colorToRoll == nil then
      return
    end
    if hov and (hov.type == "Deck" or hov.type == "Card") then
      return
    end
    local tray = gameObjects[GUIDS["dice_tray"][colorToRoll]]
    tray:setAmount(num)
    Wait.frames(function() tray:onRollDice_Click() end, 5)
end

local function onPressedChangeTargetHotkey(num, playerColor, hov, ptrPos, isKeyUp)
  local colorToRoll = getHotkeyDiceColor(playerColor)
  if colorToRoll == nil then
    return
  end
  local tray = gameObjects[GUIDS["dice_tray"][colorToRoll]]
  if num == 1 then
    tray:onIncreaseTarget_Click()
  else
    tray:onDecreaseTarget_Click()
  end
end

local function onPressedReRollHotkey(successOrFail, playerColor, hov, ptrPos, isKeyUp)
  local colorToRoll = getHotkeyDiceColor(playerColor)
  if colorToRoll == nil then
    return
  end
  local tray = gameObjects[GUIDS["dice_tray"][colorToRoll]]
  if successOrFail == "Success" then
    tray:onRollHits_Click()
  else
    tray:onRollMisses_Click()
  end
end

local function addDiceHotkeys()
    for i = 1, 10 do
        local cb = function(playerColor, hov, ptrPos, isKeyUp)
            onPressedDiceHotkey(i, playerColor, hov, ptrPos, isKeyUp)
        end
        local dieOrDice = " dice."
        if i == 1 then dieOrDice = " die." end
        addHotkey("Roll " .. i .. dieOrDice, cb)
    end

    addHotkey("Increase dice tray target", function(playerColor, hov, ptrPos, isKeyUp)
      onPressedChangeTargetHotkey(1, playerColor, hov, ptrPos, isKeyUp)
    end)
    addHotkey("Decrease dice tray target", function(playerColor, hov, ptrPos, isKeyUp)
      onPressedChangeTargetHotkey(-1, playerColor, hov, ptrPos, isKeyUp)
    end)

    addHotkey("Re-roll Failures", function(playerColor, hov, ptrPos, isKeyUp)
      onPressedReRollHotkey("Fail", playerColor, hov, ptrPos, isKeyUp)
    end)
    addHotkey("Re-roll Successes", function(playerColor, hov, ptrPos, isKeyUp)
      onPressedReRollHotkey("Success", playerColor, hov, ptrPos, isKeyUp)
    end)
end

return {
    addDiceHotkeys = addDiceHotkeys,
}