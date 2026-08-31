local SaveGameUtils = {}
local TableUtils = require("lua.utils-table")
local EventUtils = require("lua.utils-events")
local VPtracker = require("lua.vp-trackers")

function SaveGameUtils.getSaveState()
    local objectStates = TableUtils.map(gameObjects, function (obj, guid)
        return obj:getSaveState()
    end)
    local save_state = JSON.encode({
        rulerColorTint = rulerColorTint,
        ncuPositions = ncuPositions,
        firstPlayerColor = firstPlayerColor,
        currentRound = currentRound,
        destroyedUnits = destroyedUnits,
        settings = SETTINGS,
        victory = VPtracker.state,
        objectStates = objectStates,
    })

      return save_state
end

function SaveGameUtils.restoreSaveState(save_state)
    if save_state == "" then
        return
    end
    local save_data = JSON.decode(save_state)
    if save_data == nil then
        return
    end

    if save_data.rulerColorTint then
        rulerColorTint = save_data.rulerColorTint
    end

    if save_data.ncuPositions then
        ncuPositions = save_data.ncuPositions
    end

    if save_data.firstPlayerColor then
        firstPlayerColor = save_data.firstPlayerColor
    end

    if save_data.currentRound then
        currentRound = save_data.currentRound
    end

    if save_data.destroyedUnits then
        destroyedUnits = save_data.destroyedUnits
    end

    if save_data.settings then
        SettingsUtil.loadSavedSettings(save_data.settings)
    end

    if save_data.victory then
        VPtracker:restoreSave(save_data.victory)
    end

    if save_data.objectStates then
        for guid, state in pairs(save_data.objectStates) do
            local obj = getObjectFromGUID(guid)
            local existingGameObj = gameObjects[guid]
            if existingGameObj ~= nil then
                existingGameObj:restoreSaveState(state)
            elseif obj ~= nil then
                local restoredObj = _G[state.class](obj)
                restoredObj:restoreSaveState(state)
            else
                -- The object might be insinde a container
                local function listener (params)
                    local container, object = unpack(params)
                    if object.guid == guid then
                        Wait.condition(function()
                            local restoredObj = _G[state.class](getObjectFromGUID(guid))
                            restoredObj:restoreSaveState(state)
                            EventUtils.unregister("onObjectLeaveContainer", listener)
                        end, function()
                            return object.resting
                        end)
                    end
                end
                EventUtils.register("onObjectLeaveContainer", listener)
            end
        end
    end
end

return SaveGameUtils