local Utils = require("lua.utils")
local TableUtils = require("lua.utils-table")
local GameModeUtil = require("lua.utils-gamemode")
local ChangelogUtils = require("lua.utils-changelog")
local UiUtil = require("lua.utils-ui")
local DB = require("lua.data-lookup")


SETTINGS = {
    useClock = false,
    useSpectatorBlue = false,
    useSpectatorRed = false,
    clockInitialTime = 60, -- in minutes
    clockIncrement = 0, -- in minutes
    use3DMiniatures = true,
    background = "Open Ruin",
    battleMat = "Field of Battle",
    rulerColorTint = "White",
    playerCount = "1 vs 1",
    boardsize = "4x4",
    language = "en",
    patch = "CMON: S07.2",
}

local SettingsUtil = {
    _idSettingsModal = "modal__settings",
    _idSettingsWrapper = "modal__settings_wrp",

    _idPrefixIpt = "setting_ipt__",

    availableBackgrounds = TableUtils.keys(backgroundLookUp),
    getAvailableBattleMats = function() return TableUtils.keys(battleMatLookUp[SETTINGS.boardsize]) end,
    availableColors = TableUtils.keys(colorsLookUp)
}

SettingsUtil._settingsMeta = {
    ["Visual"] = {{
        type = "bool",
        settingName = "use3DMiniatures",
        name = "Use 3D Miniature",
        tooltip = "Use 3D models for figures. If disabled, use standees.",
        callback = function()
            -- do something?
        end
    }, {
        type = "dropdown",
        settingName = "language",
        name = "Language",
        tooltip = "Change the language of newly spawned cards.",
        options = { "en", "de", "fr" },
    }, {
        type = "dropdown",
        settingName = "patch",
        name = "Patch",
        tooltip = "Change the game version of newly spawned cards.",
        options = { "CMON: S07.2", "Custom Balance" },
        callback = function(_, value)
            if value == "CMON: S07.2" then
                DB.reset()
            elseif value == "Custom Balance" then
                DB.patch("cba")
            end
        end
    }, {
        type = "dropdown",
        settingName = "background",
        name = "Background",
        options = SettingsUtil.availableBackgrounds,
        callback = function()
            SettingsUtil.doSetBackground()
        end
    }, {
        type = "dropdown",
        settingName = "battleMat",
        name = "Battle Mat",
        options = SettingsUtil.getAvailableBattleMats,
        callback = function(_, value)
            SettingsUtil.doSetBattleMat(value)
        end
    }, {
        type = "button",
        btnName = "btnUnlockBattleMat",
        name = "Unlock Battle Mat",
        tooltip = "Toggle the interactable state of the battle mat",
        buttonText = "Toggle Lock",
        callback = function()
            local battleMat = getObjectFromGUID(GUIDS["battleMat"])
            battleMat.interactable = not battleMat.interactable
        end
    }, {
        type = "dropdown",
        settingName = "rulerColorTint",
        name = "Overwrite Ruler Color",
        options = SettingsUtil.availableColors
    }, {
        type = "button",
        tooltip = "Create a small splotch of paint on tactics cards, in their owners color",
        btnName = "btnMarkCards",
        name = "Mark Tactics Cards",
        buttonText = "Mark Cards",
        callback = function()
            for color, guid_zone in pairs(GUIDS["draw_discard_piles"]) do
                local zone = getObjectFromGUID(guid_zone)
                if zone == nil then
                    return
                end
                for _, obj in pairs(zone.getObjects()) do
                    SettingsUtil.markCardsInDeck(obj, color)
                end
            end
        end
    }, {
        type = "button",
        tooltip = "Render some UI elements to enhance spectator experience",
        btnName = "btnStreamingMode",
        name = "Streaming Mode",
        buttonText = "Toggle",
        callback = function(player)
            local doShow
            if player.color == "Blue" then
                SETTINGS.useSpectatorBlue = not SETTINGS.useSpectatorBlue
                doShow = SETTINGS.useSpectatorBlue
            elseif player.color == "Red" then
                SETTINGS.useSpectatorRed = not SETTINGS.useSpectatorRed
                doShow = SETTINGS.useSpectatorRed
            else
                return
            end
            SettingsUtil.updateGamemodeDisplay()
            if doShow then
                UiUtil.show("tacticsPanelSide", player.color)
                UiUtil.show("WOW_Panel", player.color)
                UiUtil.show("DWDW_Panel", player.color)
            else
                UiUtil.hide("tacticsPanelSide", player.color)
                UiUtil.hide("WOW_Panel", player.color)
                UiUtil.hide("DWDW_Panel", player.color)
            end
            UiUtil.hide("tacticsPanelBottom", player.color)
        end
    }},

    ["Game"] = {{
        type = "dropdown",
        settingName = "tacticsboard",
        name = "Tactics Board",
        tooltip = "Change the image for the tactics board",
        options = {"S07.2", "Playtest (November)", "Playtest (v0.1)", "Playtest (January v1.0)", "Playtest (February)"},
        callback = function(player, value)
            local tile = getObjectFromGUID(GUIDS["tactics_tile"])
            local url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/37c9687cc785d28da3d7ffe8afe589ab0978a32f/generated/en/game/default-tactics-board.jpg"
            if value == "S07.2" then
                url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/37c9687cc785d28da3d7ffe8afe589ab0978a32f/generated/en/game/default-tactics-board.jpg"
            elseif value == "Playtest (November)" then
                url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/37c9687cc785d28da3d7ffe8afe589ab0978a32f/generated/en/game/scaling-tactics-board.jpg"
            elseif value == "Playtest (v0.1)" then
                url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/37c9687cc785d28da3d7ffe8afe589ab0978a32f/generated/en/game/faction-tactics-board.jpg"
            elseif value == "Playtest (January v1.0)" then
                url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/generated/en/game/escalating-tactics-board.jpg"
            elseif value == "Playtest (February)" then
                url = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/generated/en/game/escalating-tactics-board-v2.jpg"
            end
            tile.setCustomObject({image = url})
            tile.reload()
        end
    }, {
        type = "dropdown",
        settingName = "playerCount",
        name = "Player Count",
        options = { "1 vs 1", "2 vs 2" },
        callback = function(_player, value)
            if value == "1 vs 1" then
                SettingsUtil.set1vs1()
            elseif value == "2 vs 2" then
                SettingsUtil.set2vs2()
            end
        end
    }, {
        type = "dropdown",
        settingName = "boardsize",
        name = "Boardsize",
        tooltip = "Change the size of the battlefield",
        options = {"4x4", "5x4", "6x4"},
        callback = function(_player, value)
            Setup.doSetup(value)
            SettingsUtil.redraw()
            Wait.frames(function()
                SettingsUtil.setSetting("battleMat", SettingsUtil.getAvailableBattleMats()[1])
            end, 10)
        end
    }},

    ["Time Control"] = {{
        type = "bool",
        settingName = "useClock",
        name = "Enable Time Control",
        tooltip = "Functions like a chess clock",
        callback = function()
            Clock:init()
        end
    }, {
        type = "button",
        btnName = "btnResetClock",
        name = "Reset Clock",
        buttonText = "Reset Clock",
        callback = function()
            Clock:reset()
        end
    }, {
        type = "int",
        settingName = "clockInitialTime",
        name = "Initial time",
        default = 60,
        suffix = "minutes"
    }, {
        type = "int",
        settingName = "clockIncrement",
        name = "Time increment",
        tooltip = "At the start of each player's turn, add this amount of additional time to their clock.",
        default = 0,
        suffix = "minutes"
    }},

    ["Debug"] = {{
        type = "button",
        tooltip = "Provide this when making bug reports to help the devs!",
        btnName = "btnWhatsNew",
        name = "Version Number",
        buttonText = "What's New?",
        suffix = "Version " .. VERSION_NUMBER,
        callback = function(player)
            ChangelogUtils.init()
            Wait.frames(function() ChangelogUtils.show(player.color) end, 10)
        end
    }, {
        type = "button",
        btnName = "btnResetUi",
        name = "Reset Ui",
        buttonText = "Reset Ui",
        callback = Utils.throttle(function()
            broadcastToAll("Resetting Ui...")
            UiUtil.redraw()
            for guid, obj in pairs(gameObjects) do
                if obj.redrawUi then
                    obj:redrawUi()
                end
            end
        end, 3)
    }}
}
function SettingsUtil.getSettingMeta(setting)
    for _, settingMetas in pairs(SettingsUtil._settingsMeta) do
        local found = TableUtils.find(settingMetas, function(it)
            return it.settingName == setting
        end)
        if found ~= nil then
            return found
        end
    end

    return nil
end

function SettingsUtil.getOptions(tableOrFunction)
    if type(tableOrFunction) == "function" then
        return tableOrFunction()
    end
    return tableOrFunction
end

function SettingsUtil.setSetting(setting, valueToSet)
    SETTINGS[setting] = valueToSet

    local meta = SettingsUtil.getSettingMeta(setting)
    if meta.type == "bool" then
        SettingsUtil._setSetting_bool(setting, valueToSet)
    elseif meta.type == "int" then
        SettingsUtil._setSetting_int(setting, valueToSet)
    elseif meta.type == "dropdown" then
        local options = SettingsUtil.getOptions(meta.options)
        local ixValue = TableUtils.getIdx(options, valueToSet)
        SettingsUtil._setSetting_dropdown(setting, ixValue)
    end

    if meta.callback then
        -- player, value, id
        meta.callback(nil, valueToSet, nil)
    end
end
function SettingsUtil._setSetting_bool(setting, valueToSet)
    local id = SettingsUtil._idPrefixIpt .. setting
    UI.setAttribute(id, "isOn", valueToSet)
end
function SettingsUtil._setSetting_int(setting, valueToSet)
    local id = SettingsUtil._idPrefixIpt .. setting
    UI.setAttribute(id, "text", valueToSet)
end
function SettingsUtil._setSetting_dropdown(setting, ixValue)
    local id = SettingsUtil._idPrefixIpt .. setting
    UI.setAttribute(id, "value", ixValue - 1)
end

-- only makes sense for dropdown settings
function SettingsUtil.doRandomizeSetting(setting)
    local meta = SettingsUtil.getSettingMeta(setting)
    if meta.type == "dropdown" then
        math.randomseed(Time.time) -- require messes with randomseeds?
        local options = SettingsUtil.getOptions(meta.options)
        local ixRandom = math.random(1, #options)
        SettingsUtil.setSetting(setting, options[ixRandom])
    end
end

function SettingsUtil.loadSavedSettings(decodedData)
    if decodedData.useClock ~= nil then
        SETTINGS.useClock = decodedData.useClock
    end
    if decodedData.clockInitialTime ~= nil then
        SETTINGS.clockInitialTime = decodedData.clockInitialTime
    end
    if decodedData.clockIncrement ~= nil then
        SETTINGS.clockIncrement = decodedData.clockIncrement
    end
    if decodedData.use3DMiniatures ~= nil then
        SETTINGS.use3DMiniatures = decodedData.use3DMiniatures
    end
    if decodedData.background ~= nil then
        SETTINGS.background = decodedData.background
    end
    if decodedData.battleMat ~= nil then
        SETTINGS.battleMat = decodedData.battleMat
    end
end

function SettingsUtil.init()
    SettingsUtil.render()
end

function SettingsUtil.render()
    local renderedSettings = {}
    for catName, catSettings in pairs(SettingsUtil._settingsMeta) do
        table.insert(renderedSettings, SettingsUtil.getRenderedHeaderRow(catName))
        for _, settingMeta in ipairs(catSettings) do
            table.insert(renderedSettings, SettingsUtil.getRenderedSettingRow(settingMeta))
        end
    end
    local rendered = table.concat(renderedSettings, "")
    -- DISGUSTING! UI.setValue can't set the value as parsed Xml, only as string!
    UI.setValue(SettingsUtil._idSettingsWrapper, rendered)
    Wait.frames(function()
        UiUtil.redraw()
    end, 5)
end
-- This function is evil
function SettingsUtil.redraw()
    local xml = UI.getXmlTable()
    local wrp = UiUtil.getElementById(xml, SettingsUtil._idSettingsWrapper)
    wrp.children = nil
    UI.setXmlTable(xml)
    Wait.frames(function() SettingsUtil.render() end, 10)
end

function SettingsUtil.getRenderedHeaderRow(heading)
    return string.format(
        [[<Row preferredHeight="50"><Cell columnSpan="4"><HorizontalLayout><Text class="settingsText" fontStyle="Bold">%s</Text></HorizontalLayout></Cell></Row><Row preferredHeight="2"><Cell dontUseTableCellBackground="true" color="#CDCDCD" columnSpan="4"></Cell></Row>]],
        heading)
end
function SettingsUtil.getRenderedSettingRow(params)
    local nameCell = SettingsUtil.getNameCell(params)
    local helpCell = SettingsUtil.getHelpCell(params)
    local inputCell = ""
    if params.type == "bool" then
        inputCell = SettingsUtil.getInputCellBool(params)
    elseif params.type == "int" then
        inputCell = SettingsUtil.getInputCellInt(params)
    elseif params.type == "dropdown" then
        inputCell = SettingsUtil.getInputCellDropdown(params)
    elseif params.type == "button" then
        inputCell = SettingsUtil.getInputCellButton(params)
    elseif params.type == "no_ipt_text" then
        inputCell = SettingsUtil.getTextCell(params)
    end

    local rowHeight = params.height or 40
    return string.format(
        [[<Row preferredHeight="%d"><Cell><Text color="#CDCDCD" fontSize="18" fontStyle="Bold">-</Text></Cell>%s%s%s</Row>]],
        rowHeight, nameCell, helpCell, inputCell)
end

function SettingsUtil.getNameCell(params)
    return string.format([[<Cell><Text class="settingsText" fontStyle="Bold">%s</Text></Cell>]], params.name)
end
function SettingsUtil.getHelpCell(params)
    if params.tooltip == nil then
        return "<Cell></Cell>"
    end
    return string.format([[<Cell><Text class="settingsText" alignment="MiddleCenter" tooltip="%s">?</Text></Cell>]],
        params.tooltip)
end
function SettingsUtil.getInputCellBool(params)
    local func = function(player, value)
        SETTINGS[params.settingName] = value == "True"
        if params.callback ~= nil then
            params.callback(player, value)
        end
    end
    local funcName = "onValueChanged_setting__" .. params.settingName
    _G[funcName] = Utils.debounce(func, 1)
    local id = SettingsUtil._idPrefixIpt .. params.settingName
    local isOn = tostring(SETTINGS[params.settingName])
    local input = string.format(
        [[<Toggle id="%s" alignment="MiddleLeft" color="#282828" textColor="#FFFFFF" isOn="%s" onValueChanged="%s"></Toggle>]],
        id, isOn, funcName)
    local suffix = string.format([[<Text preferredWidth="576" class="settingsText">%s</Text>]], params.suffix or "")
    return string.format([[<Cell>%s%s</Cell>]], input, suffix)
end
function SettingsUtil.getInputCellInt(params)
    local func = function(player, value, id)
        SETTINGS[params.settingName] = value or params.default
        if params.callback ~= nil then
            params.callback(player, value, id)
        end
    end
    local funcName = "onValueChanged_setting__" .. params.settingName
    _G[funcName] = Utils.debounce(func, 1)
    local id = SettingsUtil._idPrefixIpt .. params.settingName
    local default = SETTINGS[params.settingName]
    -- these widths man... where the fuck are the remaining 150 units???
    local input = string.format(
        [[<Panel preferredHeight="20" preferredWidth="100"><InputField id="%s" characterValidation="Integer" onValueChanged="%s">%d</InputField></Panel>]],
        id, funcName, default)
    local suffix = string.format([[<Text preferredWidth="376" class="settingsText">%s</Text>]], params.suffix or "")
    return string.format([[<Cell>%s%s</Cell>]], input, suffix)
end
function SettingsUtil.getInputCellDropdown(params)
    local func = function(player, value, id)
        SETTINGS[params.settingName] = value
        if params.callback ~= nil then
            params.callback(player, value, id)
        end
    end
    local funcName = "onValueChanged_setting__" .. params.settingName
    _G[funcName] = Utils.debounce(func, 1)
    local id = SettingsUtil._idPrefixIpt .. params.settingName
    local options = SettingsUtil.getOptions(params.options)
    local renderedOptions = table.concat(TableUtils.map(options, function(o)
        local optId = id .. "_" .. o:gsub("%s+", "")
        local isSelected = tostring(SETTINGS[params.settingName] == o)
        return string.format([[<Option id="%s" selected="%s">%s</Option>]], optId, isSelected, o)
    end), "")
    local input = string.format(
        [[<Panel preferredWidth="100"><Dropdown id="%s" scrollSensitivity="50" onValueChanged="%s">%s</Dropdown></Panel>]],
        id, funcName, renderedOptions)
    local suffix = string.format([[<Text preferredWidth="376" class="settingsText">%s</Text>]], params.suffix or "")
    return string.format([[<Cell>%s%s</Cell>]], input, suffix)
end
function SettingsUtil.getInputCellButton(params)
    local funcName = "onClick_setting__" .. params.btnName
    _G[funcName] = Utils.throttle(params.callback, 1)
    local id = SettingsUtil._idPrefixIpt .. params.btnName
    local input = string.format(
        [[<Panel preferredWidth="100"><Button height="30" width="160" id="%s" onClick="%s">%s</Button></Panel>]], id,
        funcName, params.buttonText)
    local suffix = string.format([[<Text preferredWidth="376" class="settingsText">%s</Text>]], params.suffix or "")
    return string.format([[<Cell>%s%s</Cell>]], input, suffix)
end
function SettingsUtil.getTextCell(params)
    local text = string.format([[<Text class="settingsText" %s>%s</Text>]], params.style, params.text)
    return string.format([[<Cell>%s</Cell>]], text)
end

function SettingsUtil.showSettings(color)
    UiUtil.show(SettingsUtil._idSettingsModal, color)
end
function SettingsUtil.hideSettings(color)
    UiUtil.hide(SettingsUtil._idSettingsModal, color)
end

function onClick_settings(player)
    SettingsUtil.showSettings(player.color)
end
function onClick_closeSettings(player)
    SettingsUtil.hideSettings(player.color)
end

function SettingsUtil.doSetBattleMat(valueSet)
    local battleMatAttributes = battleMatLookUp[SETTINGS.boardsize][valueSet]

    -- This shouldn't be necessary
    if battleMatAttributes == nil then
        return
    end

    local objects = {}

    for guid, object in pairs(getAllObjects()) do
        if object ~= nil then
            objects[guid] = {
                obj = object,
                isLocked = object.getLock()
            }
            object.lock()
        end
    end

    local battleMat = getObjectFromGUID(GUIDS["battleMat"])
    local terrains = battleMat.getVar("terrains")
    local battleMatCustom = battleMat.getCustomObject()
    battleMatCustom.image = battleMatAttributes.image
    battleMat.setCustomObject(battleMatCustom)
    battleMat.reload()

    Wait.frames(function()
        SettingsUtil.setSetting("rulerColorTint", battleMatAttributes.rulerTint)
        local battleMat = getObjectFromGUID(GUIDS["battleMat"])
        battleMat.setTable("terrains", terrains)
        for guid, object in pairs(objects) do
            if object ~= nil then
                object.obj.setLock(object.isLocked)
            end
        end
    end, 15)
end
function SettingsUtil.doSetBackground()
    local backgroundAttributes = backgroundLookUp[SETTINGS.background]

    if backgroundAttributes == nil then
        return
    end

    local background = getObjectFromGUID(GUIDS["background"])
    local backgroundCustom = background.getCustomObject()
    backgroundCustom.diffuse = backgroundAttributes.diffuse
    background.setCustomObject(backgroundCustom)
    background.setRotation(backgroundAttributes.rotation)
    background.reload()
end

function SettingsUtil.set2vs2()
    local blueZone = getObjectFromGUID(GUIDS["hand_zones"]["Blue"])
    local bluePos = blueZone.getPosition()
    blueZone.setPosition({-12, bluePos.y, bluePos.z})
    local tealZone = spawnObject({
        type = "HandTrigger",
        position = {12, bluePos.y, bluePos.z},
        scale = blueZone.getScale(),
    })
    tealZone.setValue("Teal")
    GUIDS["hand_zones"]["Teal"] = tealZone.guid
    local blueTile = getObjectFromGUID(GUIDS["deck_tiles"]["Blue"])
    local blueTilePos = blueTile.getPosition()
    local tealTile = blueTile.clone({position = {27.5, blueTilePos.y, blueTilePos.z}})
    tealTile.setPosition({27.5, blueTilePos.y, blueTilePos.z})
    GUIDS["deck_tiles"]["Teal"] = tealTile.guid

    local redZone = getObjectFromGUID(GUIDS["hand_zones"]["Red"])
    local redPos = redZone.getPosition()
    redZone.setPosition({-12, redPos.y, redPos.z})
    local orangeZone = spawnObject({
        type = "HandTrigger",
        position = {12, redPos.y, redPos.z},
        scale = redZone.getScale(),
    })
    orangeZone.setValue("Orange")
    GUIDS["hand_zones"]["Orange"] = orangeZone.guid
    local redTile = getObjectFromGUID(GUIDS["deck_tiles"]["Red"])
    local redTilePos = redTile.getPosition()
    local orangeTile = redTile.clone({position = {27.5, redTilePos.y, redTilePos.z}})
    orangeTile.setPosition({27.5, redTilePos.y, redTilePos.z})
    GUIDS["deck_tiles"]["Orange"] = orangeTile.guid
end
function SettingsUtil.set1vs1()
    local blueZone = getObjectFromGUID(GUIDS["hand_zones"]["Blue"])
    local tealZone = getObjectFromGUID(GUIDS["hand_zones"]["Teal"])
    local redZone = getObjectFromGUID(GUIDS["hand_zones"]["Red"])
    local orangeZone = getObjectFromGUID(GUIDS["hand_zones"]["Orange"])

    tealZone.destruct()
    orangeZone.destruct()
    GUIDS["hand_zones"]["Teal"] = nil
    GUIDS["hand_zones"]["Orange"] = nil

    local bluePos = blueZone.getPosition()
    local redPos = redZone.getPosition()
    blueZone.setPosition({0, bluePos.y, bluePos.z})
    redZone.setPosition({0, redPos.y, redPos.z})

    local orangeTile = getObjectFromGUID(GUIDS["deck_tiles"]["Orange"])
    local tealTile = getObjectFromGUID(GUIDS["deck_tiles"]["Teal"])
    if orangeTile ~= nil then
        orangeTile.destruct()
        GUIDS["deck_tiles"]["Orange"] = nil
    end
    if tealTile ~= nil then
        tealTile.destruct()
        GUIDS["deck_tiles"]["Teal"] = nil
    end
end


function SettingsUtil.markCardsInDeck(deck, color)
    -- actually, it's a single card
    if deck.type == "Card" then
        deck.setVectorLines({{
            points = {{-0.9, 0.36, 1.34}, {-0.9, 0.36, 1.35}},
            color = color,
            thickness = 0.2
        }})
    elseif deck.type == "Deck" then
        local cards = deck.getObjects()
        for k, v in ipairs(cards) do
            local obj
            if k ~= #cards then
                obj = deck.takeObject({
                    guid = v.guid,
                    position = {0, 1, 0}
                })
            else
                obj = deck
            end
            obj.setVectorLines({{
                points = {{-0.9, 0.36, 1.34}, {-0.9, 0.36, 1.35}},
                color = color,
                thickness = 0.2
            }})
            if deck.remainder ~= nil then
                deck = deck.remainder
            end
            if k ~= #cards then
                Wait.frames(function()
                    deck = deck.putObject(obj)
                end, 1)
            end
        end
    end
end

function SettingsUtil.setVpPanelHeight()
    local height = 50
    if SETTINGS.useClock then
        height = height + 27
    end
    if SETTINGS.useSpectatorBlue or SETTINGS.useSpectatorRed or GameModeUtil.currentGameMode ~= "No Gamemode" then
        height = height + 25
    end
    UI.setAttribute("vpPanel", "height", height)
end

function SettingsUtil.updateGamemodeDisplay()
    UI.setAttribute("tableRow__spectator", "active", SETTINGS.useSpectatorRed or SETTINGS.useSpectatorBlue or GameModeUtil.currentGameMode ~= "No Gamemode")
    UI.setAttribute("spectator_gamemode", "text", GameModeUtil.currentGameMode)
    SettingsUtil.setVpPanelHeight()
end

return SettingsUtil