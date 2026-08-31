local TableUtils = require("lua.utils-table")
local EventUtils = require("lua.utils-events")
local UiUtil = require("lua.utils-ui")
local Utils = require("lua.utils")
local GameModeUtil = require("lua.utils-gamemode")
local db = require("lua.data-lookup")

-- Note: do not create instances of GenericUnitTray
GenericUnitTray = {}
GenericUnitTray.__index = GenericUnitTray
GenericUnitTray.__className = "GenericUnitTray"
setmetatable(GenericUnitTray, {
    __index = GameObjectClass,
    __call = function(cls, gameObj, opts)
        opts = opts or {}

        local this = setmetatable(GameObjectClass(gameObj, opts.__className), GenericUnitTray)

        this.version = 3
        this.statNames = {
            Weakened = false,
            Order = false,
            Panicked = false,
            Activation = false,
            Vulnerable = false
        }
        if opts.statNames ~= nil then
            for k, v in pairs(opts.statNames) do
                this.statNames[k] = v
            end
        end
        this.unitFigure = opts.lookup
        this.attachmentFigures = opts.attachmentLookups or {}
        local dispName = getFullName(this.unitFigure)
        if dispName ~= nil then
            this.displayName = dispName
        else
            this.displayName = ""
        end
        this.portraits = {}
        this.indicesSpecialFigures = opts.indicesSpecialFigures or {}
        this.cost = opts.cost or 0
        this.woundsPerModel = opts.woundsPerModel or 1
        this.wounds = opts.wounds or 0
        this.undos = {}
        this.lastStoredLocation = opts.lastStoredLocation
        this.alignTarget = nil
        this.chargingUnit = nil
        this.alignmentFactor = 0.5
        this.ruler = {name = nil, obj = nil}

        this._isInitialized = false
        this._state = "initializing"
        -- initializing
        -- setup ready
        -- charging collided aligning | target_align
        -- pivoting moving
        -- containered destroyed

        return this
    end
})
GenericUnitTray.width = 0
GenericUnitTray.length = 0
GenericUnitTray.columns = 0
GenericUnitTray.rows = 0
GenericUnitTray.figureScale = 1
GenericUnitTray.unitTrayTag = "UnitTray"
GenericUnitTray.unitModelTag = "UnitModel"

GenericUnitTray.defaultCustomUIAssets = {{
    Name = "InactivePanicked",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555774721985235/A5EE530E2F76CBCF85FDE80740561C1A602ED4AC/"
}, {
    Name = "InactiveWeakened",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555774721989558/54EDCDFAA89586409C19966D7F927568799BBC2A/"
}, {
    Name = "InactiveVulnerable",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555774721986966/4736E2067712C923FF0545F62A677FFBBFED735D/"
}, {
    Name = "InactiveOrder",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555774721983223/1286EAAC77FE5436808F482FBA827B71DCCAA3E4/"
}, {
    Name = "InactiveActivation",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555774721971647/D765F17BBF23A97E64EF62C31BD7D091C6C54717/"
}, {
    Name = "Activation",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934410500/DA50881354D448E13FEBC913BA6938EA516ADE9C/"
}, {
    Name = "Order",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934411387/F7F2E08E479BA6571D099DE0BFE7FA8FF0420D94/"
}, {
    Name = "Panicked",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934412348/662E4E1B8F53B40FD30BAD488D39F10C36E77275/"
}, {
    Name = "Vulnerable",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934416341/FE20F5A621616D8A89AE739E73723B59FC01D106/"
}, {
    Name = "Weakened",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934417557/ACA41623B5DDB7ED7923E92FE7A2E2BB06159B9B/"
}, {
    Name = "Heart",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002556022161104789/6EB9380FE4D35148114B0BE7220CF63605970D0A/"
}, {
    Name = "InactiveWound",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555926636269937/2FA954D7C1E76FFB3F3D0FC784FCC3768E5A021E/"
}, {
    Name = "Wound",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1002555926636270951/F0956B41C418BCA9036368309D3A2920206D6E61/"
}, {
    Name = "AddWound",
    URL = "https://steamusercontent-a.akamaihd.net/ugc/1844811929133233927/E4184045ADABAC6CFACBEDBF2D8DA8CABD1276AE/"
}}

GenericUnitTray.defaultsXML = [[
  <Defaults>
    <Button onClick="onConditionClick" fontSize="40" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
    <Text fontSize="40" fontStyle="Bold" color="#FFFFFF"/>
    <InputField fontSize="70" color="#000000F0" textColor="#FFFFFF" characterValidation="Integer"/>
  </Defaults>
]]

function GenericUnitTray:getSaveState(opts)
    opts = opts or {}
    local state = {
        class = self.__className,
        cost = self.cost,
        woundsPerModel = self.woundsPerModel,
        wounds = self.wounds,
        statNames = self.statNames,
        lastStoredLocation = self.lastStoredLocation,
        unitFigure = self.unitFigure,
        displayName = self.displayName,
        indicesSpecialFigures = self.indicesSpecialFigures,
        ruler = {name = self.ruler.name},
        state = self._state,
    }
    if self.ruler.obj ~= nil then
        state.ruler.guid = self.ruler.obj.guid
    end

    if TableUtils.hasValue({"initializing", "setup", "ready"}, self._state) then
        state.state = self._state
    else
        state.state = "ready"
    end

    if opts.isCreatingCopy then
        state.ruler = {name = nil, obj = nil}
        state.state = "initializing"
    end

    return state
end
function GenericUnitTray:restoreSaveState(savedData)
    self.cost = savedData.cost
    self.woundsPerModel = savedData.woundsPerModel
    self.wounds = savedData.wounds
    self.statNames = {}
    for k, v in pairs(savedData.statNames) do
        self.statNames[k] = v
    end
    self.lastStoredLocation = savedData.lastStoredLocation
    self.unitFigure = savedData.unitFigure
    self.displayName = savedData.displayName
    self.indicesSpecialFigures = savedData.indicesSpecialFigures
    self.ruler = {name = savedData.ruler.name}
    self._state = savedData.state
    if savedData.ruler.guid then
        self.ruler.obj = getObjectFromGUID(savedData.ruler.guid)
    end

    if self._isInitialized ~= true then
        self:init()
    end
end

function GenericUnitTray:setState(state)
    self._state = state
    if state == "setup" then
        self.gameObj.unlock()
    elseif state == "ready" then
        self:updateButtons()
        self.gameObj.lock()
    end
end
function GenericUnitTray:onPlayerAction(params)
    local player, action, targets = unpack(params)

    if action == Player.Action.Copy then
    -- TTS doesn't support finer rotating than default at the moment
    -- elseif action == Player.Action.RotateIncrementalLeft then
        -- self.gameObj.setRotation(self.gameObj.getRotation() + Vector(0, -5, 0))
    -- elseif action == Player.Action.RotateIncrementalRight then
        -- self.gameObj.setRotation(self.gameObj.getRotation() + Vector(0, 5, 0))
    end
end
function GenericUnitTray:onHighlightUnactivated()
    if self._state ~= "containered" and self.gameObj ~= nil and not self.statNames.Activation then
        self.gameObj.highlightOn(SETTINGS.rulerColorTint, 7)
    end
end
function GenericUnitTray:onDestroy()
    self:endAllActions()

    local alignUnit = gameObjects[self.alignUnitGuid]
    if alignUnit ~= nil then
        alignUnit:endAllActions()
        alignUnit:setState("ready")
    end
    if self._state == "containered" then
        return
    end
    if getObjectFromGUID(self._guid) == nil then
        gameObjects[self._guid] = nil
    end
end
function GenericUnitTray:onEnterContainer()
    self:setState("containered")
end

function GenericUnitTray:init()
    self:initContextMenu()
    self:setDisplayName()
    self:setDescription()
    self:updatePortraits()
    self:initUiEventListeners()
    self:createXmlUi()

    self:registerEventListeners()
    self.gameObj.unlock()

    -- lets give some good time to set the ui. but why is the object refrence not defined if we do it NOW?
    Wait.frames(function()
        self._isInitialized = true
        if self._state == "initializing" or self._state == "setup" or self._state == "containered" then
            self:setState("setup")
            self:updateButtons()
        else
            self:setState("ready")
        end
    end, 20)
end

function GenericUnitTray:registerEventListeners()
    self:register({"onCollisionEnter"})
    -- For some reason registering collisions this way doesnt work
    -- local onCollisionEnter = function(params)
    --     local object, info = unpack(params)
    --     if object.guid == self._guid then
    --         self:onCollisionEnter(info)
    --     end
    -- end
    -- EventUtils.register("onObjectCollisionEnter", onCollisionEnter)
    -- self.gameObj.registerCollisions()
end
function GenericUnitTray:initContextMenu()
    self.gameObj.addContextMenuItem("Store Location", function()
        self:storeLocation()
    end, false)
    self.gameObj.addContextMenuItem("Recall Location", function()
        self:recallLocation()
    end, false)
    local onReload = function(player_color)
        self:reload(player_color)
    end
    self.gameObj.addContextMenuItem("Reload", Utils.throttle(onReload, 3) , true)
end
function GenericUnitTray:storeLocation()
    self.lastStoredLocation = {
        position = self.gameObj.getPosition(),
        rotation = self.gameObj.getRotation()
    }
end
function GenericUnitTray:recallLocation()
    if self.lastStoredLocation == nil then
        return
    end

    self:endAllActions()

    local alignUnit = gameObjects[self.alignUnitGuid]
    if alignUnit ~= nil then
        alignUnit:endAllActions()
        if alignUnit.gameObj ~= nil then
            alignUnit:setState("ready")
        end
    end

    self:setState("ready")
    self.gameObj.setPosition(self.lastStoredLocation.position)
    self.gameObj.setRotation(self.lastStoredLocation.rotation)
    self:setXmlRotation(self.lastStoredLocation.rotation)
end
function GenericUnitTray:reload(player_color)
    broadcastToColor("Reloading " .. self._guid .. ": " .. self.displayName, player_color)
    self:endAllActions()
    self:setState("ready")
    self.gameObj = self.gameObj.reload()
    self:init()
end

function GenericUnitTray:initUiEventListeners()
    -- self._preventActionsDefaultBehavior = {Player.Action.RotateIncrementalLeft, Player.Action.RotateIncrementalRight}

    self:register({"onConditionClick", "onWoundClick", "onHeartClick"})
    self:register({"onClickFill", "onClickDetach", "buttonClick_Destroy", "buttonClick_ReturnToTray"})
    self:register({"buttonClick_Pivot", "buttonClick_Move", "buttonClick_Charge", "buttonClick_Ruler",
                   "buttonClick_Ready", "buttonClick_Deploy", "buttonClick_Highlight", "buttonClick_RulerOff"})
    self:register({"buttonClick_MoveDone", "buttonClick_MoveUndo"})
    self:register({"buttonClick_PivotDone", "buttonClick_PivotUndo", "rulerSet", "buttonClick_PivotMode", "setFinePivot", "setNormalPivot"})
    self:register({"buttonClick_alignCancel", "buttonClick_alignHelp", "buttonClick_alignDone", "buttonClick_alignChangeTarget"})
    self:register({"buttonClick_alignFront", "buttonClick_alignFrontLeft", "buttonClick_alignFrontRight"})
    self:register({"buttonClick_alignRear", "buttonClick_alignRearLeft", "buttonClick_alignRearRight"})
    self:register({"buttonClick_alignLeft", "buttonClick_alignLeftLeft", "buttonClick_alignLeftRight"})
    self:register({"buttonClick_alignRight", "buttonClick_alignRightLeft", "buttonClick_alignRightRight"})
end
function GenericUnitTray:createXmlUi()
    self:setCustomAssets()
    Wait.frames(function()
        local fillDetachXml = self:createFillAndDetachXml()
        local stateXml = self:createStateXml()
        local nameXml = self:createNameXml()
        local overlayXml = self:createOverlayXml()
        local xmlUi = self.defaultsXML .. stateXml .. nameXml .. overlayXml .. fillDetachXml
        self.gameObj.UI.setXml(xmlUi)
    end, 10)
end
function GenericUnitTray:setCustomAssets()
    local newAssets = {}
    for i, asset in ipairs(self.gameObj.UI.getCustomAssets()) do
        newAssets[i] = asset
    end

    for i, portrait in ipairs(self.portraits) do
        -- FIXME: THIS DOESNT ACTUALLY DO WHAT ITS SUPPOSED TO DO
        if not TableUtils.tableContains(newAssets, portrait) then
            table.insert(newAssets, portrait)
        end
    end

    if unitUiAssets then
        for i, asset in ipairs(unitUiAssets) do
            if not TableUtils.tableContains(newAssets, asset) then
                table.insert(newAssets, asset)
            end
        end
    end

    self.gameObj.UI.setCustomAssets(newAssets)
end
function GenericUnitTray:createStateXml()
    local renderStat = function(stat, prefix, clickFunc)
        local icon = stat
        local onClick = ""
        if clickFunc ~= nil then onClick = string.format([[onClick="%s"]], clickFunc) end
        if not self.statNames[stat] then icon = "Inactive"..icon end
        local id = prefix .. stat
        return string.format([[<Cell><Button id="%s" color="#FFFFFF00" active="true" icon="%s" %s></Button></Cell>]], id, icon, onClick)
    end
    local getRenderStatWithPrefix = function(prefix)
        return function (stat)
            return renderStat(stat, prefix)
        end
    end
    local renderHearts = function(num, str)
        local out = {}
        for row = 1, (num + 1) / 5, 1 do
            local cells = {}
            if row == 1 then
                table.insert(cells, renderStat("Wound", "", "onWoundClick"))
            else
                table.insert(out, "</Row><Row>")
            end
            local min = math.max((row - 1) * 5, 1)
            local max = row * 5 - 1
            for ix = min, max, 1 do
                local isActive = tostring(ix <= self.wounds)
                ix = tostring(ix)
                local rd = string.format([[<Cell><Button id="%sHeart%s" color="#FFFFFF00" active="%s" icon="Heart" onClick="onHeartClick"></Button></Cell>]], str, ix, isActive)
                table.insert(cells, rd)
            end
            if str == "Ally" then
                for i = #cells, 1, -1 do
                    table.insert(out, cells[i])
                end
            else
                for i = 1, #cells do
                    table.insert(out, cells[i])
                end
            end
        end
        return table.concat(out, "")
    end
    -- this is hacky to get the right offset...
    local maxHearts = self.woundsPerModel + 4 - self.woundsPerModel % 5
    local opponentPanel = [[<Panel id="statePanelOpponent" height="200" width="500" position="0 0 -700" rotation="90 0 180">]]
        .. [[<TableLayout cellSpacing="2" cellBackgroundColor="clear"><Row>]]
        .. table.concat(TableUtils.map({"Weakened", "Vulnerable", "Panicked", "Order", "Activation"}, getRenderStatWithPrefix("Opponent")), "")
        .. [[</Row><Row>]]
        .. renderHearts(maxHearts, "Enemy")
        .. [[</Row></TableLayout></Panel>]]

    local allyPanel = [[<Panel id="statePanelMe" height="200" width="500" position="0 -1 -700" rotation="270 0 0">]]
        .. [[<TableLayout cellSpacing="2" cellBackgroundColor="clear"><Row>]]
        .. table.concat(TableUtils.map({"Activation", "Order", "Panicked", "Vulnerable", "Weakened"}, getRenderStatWithPrefix("Ally")), "")
        .. [[</Row><Row>]]
        .. renderHearts(maxHearts, "Ally")
        .. [[</Row></TableLayout></Panel>]]

    return opponentPanel .. allyPanel
end
function GenericUnitTray:createNameXml()
    local namePanelOpponent = [[<Panel id="namePanelOpponent" height="110" width="138" position="-70 1 -345" rotation="90 0 180">]]
        .. [[<VerticalLayout><HorizontalLayout spacing="5">]]
        .. string.format([[<Text id="unitNameOpponent" resizeTextForBestFit="true" alignment="UpperLeft" color="#000000">%s</Text>]], self.displayName)
        .. [[</HorizontalLayout></VerticalLayout></Panel>]]
    local namePanelAlly = [[<Panel id="namePanelMe" height="110" width="138" position="-70 0 -345" rotation="270 0 0">]]
        .. [[<VerticalLayout><HorizontalLayout spacing="5">]]
        .. string.format([[<Text id="unitNameOpponent" resizeTextForBestFit="true" alignment="UpperRight" color="#000000">%s</Text>]], self.displayName)
        .. [[</HorizontalLayout></VerticalLayout></Panel>]]
    return namePanelAlly .. namePanelOpponent
end
function GenericUnitTray:createFillAndDetachXml()
    local buttons = {}

    for row = 0, self.rows - 1 do
        for column = 0, self.columns - 1 do
            local buttonPosition = self:getFillDetachBtnPosition(column, row)

            local ixFigure = row * self.columns + column + 1
            local fig = self:getNthAttachment(ixFigure)

            local fillBtn = self:createFillButton(buttonPosition, ixFigure, fig == nil)
            table.insert(buttons, fillBtn)
            local detachtBtn = self:createDetachButton(buttonPosition, ixFigure, fig ~= nil)
            table.insert(buttons, detachtBtn)
        end
    end

    return string.format([[<Panel id="panelFillDetach">%s</Panel>]], table.concat(buttons, ""))
end
function GenericUnitTray:createDetachButton(buttonPosition, ixFigure, isActive)
    local id = "btnDetach_" .. ixFigure
    local active = tostring(not not isActive)
    local onClick = self._guid .. string.format("/onClickDetach(%d)", ixFigure)
    local position = string.format("%d %d %d", buttonPosition.x, buttonPosition.z, buttonPosition.y + 10)
    local buttonText = string.format(
        [[<Button id="%s" active="%s" onclick="%s" position="%s" width="50" height="50" color="Red">-</Button>]], id,
        active, onClick, position)
    return buttonText
end
function GenericUnitTray:createFillButton(buttonPosition, ixFigure, isActive)
    local id = "btnFill_" .. ixFigure
    local active = tostring(not not isActive)
    local onClick = self._guid .. string.format("/onClickFill(%d)", ixFigure)
    local position = string.format("%d %d %d", buttonPosition.x, buttonPosition.z, buttonPosition.y)
    local buttonText = string.format(
        [[<Button id="%s" active="%s" onclick="%s" position="%s" icon="AddWound" width="50" height="50" color="rgba(0, 0, 0, 0)"></Button>]],
        id, active, onClick, position)
    return buttonText
end
function GenericUnitTray:createOverlayXml()
    local numPortraits = #self.portraits
    local overlayWidth = tostring(numPortraits * 217)
    local renderOverlay = function(name)
        local images = {}
        for ix = 1, numPortraits do
            local isActive = tostring(self.statNames[name])
            local image = string.format([[<Image id="%sOverlay%d" image="BlankOverlay" active="%s"></Image>]], name, ix, isActive)
            table.insert(images, image)
        end
        return string.format([[<GridLayout id="%sOverlayPanel" height="217" width="%s" cellSize="215 215" padding="1 1 1 1" color="#00000000">%s</GridLayout>]], name, overlayWidth, table.concat(images, ""))
    end
    local stateOverlays = [[]]
        .. table.concat(TableUtils.map({"Activation", "Panicked", "Vulnerable", "Weakened"}, renderOverlay))
        .. [[]]

    local portraitImages = {}
    for ix = 1, numPortraits do
        local portrait = self.portraits[ix]
        local name = portrait.name
        local image = string.format([[<Image id="Portrait%d" image="%s"></Image>]], ix, name)
        table.insert(portraitImages, image)
    end
    local portraitPanel = string.format([[<GridLayout id="unitTypePanel" cellSize="215 215" height="217" width="%s" padding="1 1 1 1" color="#000000EF">]], overlayWidth)
        .. table.concat(portraitImages, "")
        .. [[</GridLayout>]]

    local woundsPanel = [[<GridLayout id="woundsPanel" cellSize="107 107" height="217" width="109" padding="1 1 1 1" color="#000000EF">]]
    .. [[<Image image="Wound"></Image>]]
    .. string.format([[<Panel><Text id="woundsOverlayText" fontSize="60">%s</Text></Panel>]], tostring(self.woundsPerModel * #self.gameObj.getAttachments() - self.wounds))
    .. [[</GridLayout>]]

    return string.format([[<TableLayout id="spectatorOverlayWrapper" visibility="Grey|Black|Brown" cellBackgroundColor="clear" position="0 0 -3500" rotation="0 0 0" height="217" width="%s" columnWidths="%s 109"><Row>]], tostring(overlayWidth + 109), overlayWidth)
        .. "<Cell><Panel>" .. portraitPanel .. stateOverlays .. "</Panel></Cell>" .. "<Cell>" .. woundsPanel.. "</Cell>"
        .. [[</Row></TableLayout>]]
end
function GenericUnitTray:setXmlRotation(rot)
    self.gameObj.UI.setAttribute("spectatorOverlayWrapper", "rotation", "0 0 " .. (rot[2]))
end

function GenericUnitTray:updateFillAndDetachButtons()
    for idx = 1, #self.snapPoints do
        local fig = self:getNthAttachment(idx)
        if fig ~= nil then
            self.gameObj.UI.setAttribute("btnFill_" .. idx, "active", false)
            self.gameObj.UI.setAttribute("btnDetach_" .. idx, "active", true)
        else
            self.gameObj.UI.setAttribute("btnFill_" .. idx, "active", true)
            self.gameObj.UI.setAttribute("btnDetach_" .. idx, "active", false)
        end
    end
end
function GenericUnitTray:updateStates()
    for id, v in pairs(self.statNames) do
        if v == true then
            self.gameObj.UI.setAttribute("Ally" .. id, "icon", id)
            self.gameObj.UI.setAttribute("Enemy" ..id, "icon", id)
        else
            self.gameObj.UI.setAttribute("Ally" ..id, "icon", "Inactive"..id)
            self.gameObj.UI.setAttribute("Enemy" ..id, "icon", "Inactive"..id)
        end
    end
end

function GenericUnitTray:updateUnit(forceUpdate)
    if not forceUpdate and self._state ~= "setup" then
        return
    end

    self:setDisplayName()
    self:setDescription()
    self:updatePortraits()
    self:createXmlUi()
    Wait.frames(function() self:updateSpectatorPanel() end, 10)
end
function GenericUnitTray:updatePortraits()
    if self.unitFigure == nil then
        return
    end

    local unitName = getFullName(self.unitFigure)
    self.portraits[1] = {
        name = UiUtil.getSafeName(unitName),
        url = self.unitFigure.portrait
    }
    for ix = 1, 2 do
        local attachmentLookUp = self.attachmentFigures[ix]
        if attachmentLookUp then
            if attachmentLookUp then
                self.portraits[ix + 1] = {
                    name = string.upper(UiUtil.getSafeName(attachmentLookUp.fullName)),
                    url = attachmentLookUp.portrait
                }
            end
        else
            break
        end
    end
end
function GenericUnitTray:setDisplayName()
    if self.unitFigure == nil then
        -- TODO: If we don't know what unit this is, perhaps find out?
        return
    end
    local unitName = getFullName(self.unitFigure)

    local attachment = self:getNthAttachment(1)
    if attachment ~= nil and unitName ~= attachment.name then
        self.displayName = unitName .. " (" .. attachment.name .. ")"
    end

    self.gameObj.setName(self.displayName)
end
function GenericUnitTray:setDescription()
    local painters = {}
    for _, attachment in ipairs(self.gameObj.getAttachments()) do
        local attachmentName = attachment.description:match("(.+) painted by")
        local painterName = attachment.description:match("painted by: (.+)")
        if attachmentName and painterName then
            painters[attachmentName] = painterName
        end
    end
    local description = table.concat(TableUtils.values(TableUtils.map(painters, function(p, un) return un.." painted by: "..p  end)), "\n")
    self.gameObj.setDescription(description)
end

function GenericUnitTray:updateSpectatorPanel()
    if self.portraits then
        local portraitCount = 0
        for i = 1, 3 do
            local portrait = self.portraits[i]

            if portrait and portrait.name then
                portraitCount = portraitCount + 1
                self.gameObj.UI.setAttribute("Portrait" .. i, "active", "true")
                self.gameObj.UI.setAttribute("Portrait" .. i, "image", portrait.name)

                for _, state in ipairs({"Activation", "Panicked", "Vulnerable", "Weakened"}) do
                    self.gameObj.UI.setAttribute(state .. "Overlay" .. i, "active", "true")
                end
            else
                self.gameObj.UI.setAttribute("Portrait" .. i, "active", "false")

                for _, state in ipairs({"Activation", "Panicked", "Vulnerable", "Weakened"}) do
                    self.gameObj.UI.setAttribute(state .. "Overlay" .. i, "active", "false")
                end
            end
        end

        local rotation = self.gameObj.getRotation()
        self.gameObj.UI.setAttribute("unitTypePanel", "visibility", "Grey|Black|Brown")
        self:setXmlRotation(rotation)
        self.gameObj.UI.setAttribute("unitTypePanel", "width", tostring(portraitCount * 217))

        if portraitCount > 0 then
            for _, state in ipairs({"Activation", "Panicked", "Vulnerable", "Weakened"}) do
                local isActive = self.statNames[state]

                if isActive then
                    self.gameObj.UI.setAttribute(state .. "Overlay1", "image", state .. "Overlay")
                else
                    self.gameObj.UI.setAttribute(state .. "Overlay1", "image", "BlankOverlay")
                end
                self.gameObj.UI.setAttribute(state .. "OverlayPanel", "width", tostring(portraitCount * 217))
            end
        end
    end
end

function GenericUnitTray:updateButtons()
    self.gameObj.clearButtons()
    self:updateFillAndDetachButtons()
    if self._state == "ready" then
        self.gameObj.createButton({
            label = "Pivot",
            tooltip = "Pivot",
            click_function = "buttonClick_Pivot",
            function_owner = self.gameObj,
            position = self:getBtnPos_Pivot(),
            rotation = self:getBtnRot_Pivot(),
            height = 220,
            width = 520,
            font_size = 150,
            color = {0, 0, 0},
            font_color = {1, 1, 1}
        })
        self.gameObj.createButton({
            label = "Move",
            tooltip = "Move",
            click_function = "buttonClick_Move",
            function_owner = self.gameObj,
            position = self:getBtnPos_Move(),
            rotation = {0, 180, 0},
            height = 220,
            width = 520,
            font_size = 150,
            color = {0, 0, 0},
            font_color = {1, 1, 1}
        })
        self.gameObj.createButton({
            label = "Charge",
            tooltip = "Charge",
            click_function = "buttonClick_Charge",
            function_owner = self.gameObj,
            position = self:getBtnPos_Charge(),
            rotation = self:getBtnRot_Charge(),
            height = 220,
            width = 520,
            font_size = 150,
            color = {0, 0, 0},
            font_color = {1, 1, 1}
        })
        self:createRulerBtnsCycle()
    elseif self._state == "setup" or self._state == "deploying" then
        self.gameObj.createButton({
            label = "Battle Ready",
            tooltip = "Battle Ready",
            click_function = "buttonClick_Ready",
            function_owner = self.gameObj,
            position = self:getBtnPos_Undo(),
            rotation = {0, 180, 0},
            height = 220,
            width = 980,
            font_size = 150,
            color = {0, 0, 0},
            font_color = {1, 1, 1}
        })
        local deploy_color = "Black"
        if self._state == "deploying" then
            deploy_color = "Red"
        end
        self.gameObj.createButton({
            label = "Deploy",
            tooltip = "Deploy",
            click_function = "buttonClick_Deploy",
            function_owner = self.gameObj,
            position = self:getBtnPos_Done(),
            rotation = {0, 180, 0},
            height = 220,
            width = 600,
            font_size = 150,
            color = deploy_color,
            font_color = {1, 1, 1}
        })
    end
end
function GenericUnitTray:createRulerBtnsCycle()
    local rulerBtnColor = "Black"
    if self.ruler.name ~= nil then
        rulerBtnColor = "Green"
        self:createRulerHighlightButton()
        self:createRulerOffButton()
    end
    self.gameObj.createButton({
        label = "Rulers",
        tooltip = "Cycle Rulers. Right click to turn off",
        click_function = "buttonClick_Ruler",
        function_owner = self.gameObj,
        position = self:getBtnPos_FrontCenter(),
        rotation = {0, 180, 0},
        height = 220,
        width = 450 * self.btnScale,
        font_size = 150 * self.btnScale,
        color = rulerBtnColor,
        font_color = {1, 1, 1}
    })
end
function GenericUnitTray:createRulerHighlightButton()
    local label = self.handleHighlightFlank == nil and "Highlight" or "HL: Flank"
    local color = label == "Highlight" and "Black" or "Red"
    self.gameObj.createButton({
        label = label,
        tooltip = "Highlight Trays in a flank Arc",
        click_function = "buttonClick_Highlight",
        function_owner = self.gameObj,
        position = self:getBtnPos_FrontRight(),
        rotation = {0, 180, 0},
        height = 220,
        width = 660 * self.btnScale,
        font_size = 150 * self.btnScale,
        color = color,
        font_color = {1, 1, 1}
    })
end
function GenericUnitTray:createRulerOffButton()
    self.gameObj.createButton({
        label = "Off",
        tooltip = "Turn off Ruler",
        click_function = "buttonClick_RulerOff",
        function_owner = self.gameObj,
        position = self:getBtnPos_FrontLeft(),
        rotation = {0, 180, 0},
        height = 220,
        width = 450 * self.btnScale,
        font_size = 150 * self.btnScale,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
end

function GenericUnitTray:returnAllFiguresToTray()
    for idx, snapPoint in ipairs(self.snapPoints) do
        local worldPos = self.gameObj.positionToWorld(snapPoint.Position)
        local found = self:getFiguresAtPosition(worldPos)
        if TableUtils.any(found) and found[1].getVar("identifier") == self._guid then
            self:buttonClick_ReturnToTray({found[1]})
        end
    end
end

-- attachment as in the api, not the asoiaf tt game
function GenericUnitTray:getNthAttachment(pointIdx)
    pointIdx = tostring(pointIdx)
    for _, attachment in ipairs(self.gameObj.getAttachments()) do
        if attachment.memo == pointIdx then
            return attachment
        end
    end
    return nil
end
function GenericUnitTray:getPositionIdxByGuid(guid)
    for ix, snapPoint in ipairs(self.snapPoints) do
        local worldPos = self.gameObj.positionToWorld(snapPoint.Position)
        local found = self:getFiguresAtPosition(worldPos, guid)
        for _, fig in ipairs(found) do
            if fig.getGUID() == guid then
                return ix
            end
        end
    end
    return nil
end
function GenericUnitTray:getFiguresAtPosition(pos)
    local foundItems = {}
    local objList = Physics.cast({
        origin = pos,
        direction = {0, 1, 0},
        type = 2, -- sphere
        size = {0.1, 0.1, 0.1},
        max_distance = 1
        -- debug=true
    })

    for _, obj in ipairs(objList) do
        if obj.hit_object.hasTag(self.unitModelTag) then
            table.insert(foundItems, obj.hit_object)
        end
    end

    return foundItems
end

-- this gets called every frame!
function GenericUnitTray:onUpdate()
    if self.gameObj == nil then
        -- return
    end
    if self._state == "moving" then
        self.gameObj.setRotation(self.rotFix)
        self:setProjectedPosition()
    elseif self._state == "aligning" then
        self.gameObj.setRotation(self.chargeAlign.rotation)
        self:projectChargeMovement()
    elseif self._state == "deploying" then
        self:projectToDeployment()
    end

    if self.ruler.obj then
        local pos = self.gameObj.getPosition()
        local rot = self.gameObj.getRotation()
        self.ruler.obj.setPosition({pos.x, 1.7, pos.z})
        self.ruler.obj.setRotation({0, rot.y, 0})
    end
end
function GenericUnitTray:setProjectedPosition()
    local initialPos = self.gameObj.getPosition()
    local diff = initialPos - self.undos.position
    local tranformForward = self.gameObj.getTransformForward()
    local transformRight = self.gameObj.getTransformRight()
    local projectForward = diff:copy():project(tranformForward) + self.undos.position
    local projectRight = diff:copy():project(transformRight) + self.undos.position

    if (Vector.dot(initialPos - projectForward, initialPos - projectForward) >
        Vector.dot(initialPos - projectRight, initialPos - projectRight)) then
        self.gameObj.setPosition({projectRight.x, initialPos.y, projectRight.z})
    else
        self.gameObj.setPosition({projectForward.x, initialPos.y, projectForward.z})
    end
end
function GenericUnitTray:projectChargeMovement()
    local initialPos = self.gameObj.getPosition()
    local diff = initialPos - self.chargeAlign.position
    local transformRight = self.gameObj.getTransformRight()
    local projectRight = diff:copy():project(transformRight) + self.chargeAlign.position
    self.gameObj.setPosition({projectRight.x, initialPos.y, projectRight.z})
end
function GenericUnitTray:projectToDeployment()
    local initialPos = self.gameObj.getPosition()
    if math.abs(initialPos.x) > 24 or math.abs(initialPos.z) > 24 then
        return
    end
    local bounds = self.gameObj.getBounds()["size"]
    -- TODO: These could potentially be filtered depending on current gamemode
    local potentialDeployPositions = {
        -- 12" for various abilities like endless horde
        Vector({initialPos.x, initialPos.y, -12 - bounds.z / 2}),
        Vector({initialPos.x, initialPos.y, 12 + bounds.z / 2}),
        -- 6" from the side for abilities like outflank
        Vector({18 + bounds.x / 2, initialPos.y, initialPos.z}),
        Vector({-18 - bounds.x / 2, initialPos.y, initialPos.z}),
    }
    local gameModeDeployPositions = GameModeUtil.getDeploymentPositions()
    for _, z_deploy in ipairs(gameModeDeployPositions) do
        if z_deploy < 0 then
            table.insert(potentialDeployPositions, Vector({initialPos.x, initialPos.y, -24 - z_deploy - bounds.z / 2}))
        elseif z_deploy > 0 then
            table.insert(potentialDeployPositions, Vector({initialPos.x, initialPos.y, 24 - z_deploy + bounds.z / 2}))
        end
    end
    local distances = TableUtils.map(potentialDeployPositions, function(v) return Vector.dot(initialPos - v, initialPos - v) end)
    local ix = TableUtils.findIndex(distances, function(d)
        return TableUtils.all(distances, function(d2) return d <= d2 end)
    end)
    self.gameObj.setPosition(potentialDeployPositions[ix])
end

-- params = {player, value, id}
function GenericUnitTray:onConditionClick(params)
    local player, value, id = unpack(params)
    local statName = id:gsub("Ally", ""):gsub("Opponent", "")
    if self.statNames[statName] == false then
        self.gameObj.UI.setAttribute("Ally" .. statName, "icon", statName)
        self.gameObj.UI.setAttribute("Opponent" .. statName, "icon", statName)
        self.statNames[statName] = true
        broadcastToColor(statName .. " set", player.color, {1, 1, 1})
    else
        self.gameObj.UI.setAttribute("Ally" .. statName, "icon", "Inactive" .. statName)
        self.gameObj.UI.setAttribute("Opponent" .. statName, "icon", "Inactive" .. statName)
        self.statNames[statName] = false
        broadcastToColor(statName .. " unset", player.color, {1, 1, 1})
    end

    self:updateSpectatorPanel()
end

-- params = {player, ixFigure, btnId}
function GenericUnitTray:onClickFill(params)
    local player, ixFigure, btnId = unpack(params)
    ixFigure = tonumber(ixFigure)
    self:fillTrayToIdx(ixFigure)
end
function GenericUnitTray:fillTrayToIdx(idxFillTo)
    for idx = 1, idxFillTo do
        local attachment = self:getNthAttachment(idx)
        if attachment == nil and not TableUtils.hasValue(self.indicesSpecialFigures, idx) then
            self:spawnFigureAtIdx(idx)
        end
    end
    self:updateSpectatorWoundsUi()
end
function GenericUnitTray:spawnFigureAtIdx(positionIdx)
    local snapPoint = self.snapPoints[positionIdx]
    local worldPos = self.gameObj.positionToWorld(snapPoint.Position)
    local existing = self:getFiguresAtPosition(worldPos)

    for _, obj in ipairs(existing) do
        if obj.getVar("identifier") == self._guid then
            self:buttonClick_ReturnToTray({obj})
            return
        end
    end

    if self.unitFigure == nil then
        -- Print an error?
        return
    end
    local figData = self:getFigureObjectData(self.unitFigure)
    local rot = self.gameObj.getRotation()
    figData.Transform.posX = figData.Transform.posX + worldPos.x
    figData.Transform.posY = figData.Transform.posY + worldPos.y
    figData.Transform.posZ = figData.Transform.posZ + worldPos.z
    figData.Transform.rotX = rot.x
    figData.Transform.rotY = rot.y
    figData.Transform.rotZ = rot.z
    figData.ColorDiffuse = self.gameObj.getData().ColorDiffuse
    figData.Memo = tostring(positionIdx)
    figData.Nickname = getFullName(self.unitFigure)

    local newFigure = spawnObjectData({
        data = figData
    })
    newFigure.setName(getFullName(self.unitFigure))
    self.gameObj.addAttachment(newFigure)
    self.gameObj.UI.setAttribute("btnDetach_" .. positionIdx, "active", true)
    self.gameObj.UI.setAttribute("btnFill_" .. positionIdx, "active", false)
end
-- params = {player, ixFigure, btnId}
function GenericUnitTray:onClickDetach(params)
    local player, ixFigure, btnId = unpack(params)

    self.gameObj.UI.setAttribute("btnDetach_" .. ixFigure, "active", false)
    self.gameObj.UI.setAttribute("btnFill_" .. ixFigure, "active", true)
    broadcastToColor("Figure Detached", player.color, {1, 1, 1})
    local attachment = self:getNthAttachment(ixFigure)
    local figure = self.gameObj.removeAttachment(attachment.index)
    figure.setVar("identifier", self._guid)
    figure.createButton({
        label = "!",
        click_function = "buttonClick_Destroy",
        function_owner = self.gameObj,
        position = {-0.5, 2, 0},
        rotation = {90, 0, 0},
        height = 300,
        width = 150,
        textAlignment = MiddleCenter,
        font_size = 75,
        color = "Red",
        font_color = {1, 1, 1},
        tooltip = "Remove"
    })
    figure.createButton({
        label = "!",
        click_function = "buttonClick_Destroy",
        function_owner = self.gameObj,
        position = {-0.5, 2, 0},
        rotation = {270, 0, 0},
        height = 300,
        width = 150,
        textAlignment = MiddleCenter,
        font_size = 75,
        color = "Red",
        font_color = {1, 1, 1},
        tooltip = "Remove"
    })
    figure.createButton({
        label = "+",
        click_function = "buttonClick_ReturnToTray",
        function_owner = self.gameObj,
        position = {0.5, 2, 0},
        rotation = {90, 0, 0},
        height = 300,
        width = 150,
        textAlignment = MiddleCenter,
        font_size = 75,
        color = "Green",
        font_color = {1, 1, 1},
        tooltip = "Return to tray"
    })
    figure.createButton({
        label = "+",
        click_function = "buttonClick_ReturnToTray",
        function_owner = self.gameObj,
        position = {0.5, 2, 0},
        rotation = {270, 0, 0},
        height = 300,
        width = 150,
        textAlignment = MiddleCenter,
        font_size = 75,
        color = "Green",
        font_color = {1, 1, 1},
        tooltip = "Return to tray"
    })
    figure.setPositionSmooth(figure.getPosition() + Vector(0, 1, 0), false, true)
    self:updateSpectatorWoundsUi()
end
-- params = {obj, player_clicker_color, alt_click}
function GenericUnitTray:buttonClick_Destroy(params)
    local obj, player_clicker_color, alt_click = unpack(params)
    obj.destruct()
end
-- params = {obj, player_clicker_color, alt_click}
function GenericUnitTray:buttonClick_ReturnToTray(params)
    local obj, player_clicker_color, alt_click = unpack(params)
    obj.setVar("identifier", nil)
    local success = self:tryAttachFigure(obj)
    if not success then
        obj.setVar("identifier", self._guid)
    else
        self.gameObj.UI.setAttribute("btnDetach_" .. obj.memo, "active", true)
        self.gameObj.UI.setAttribute("btnFill_" .. obj.memo, "active", false)
    end
end
function GenericUnitTray:tryAttachFigure(figure)
    if figure.getVar("identifier") == self._guid then
        return nil
    end
    local figGuid = figure.getGUID()
    local posIdx = self:getPositionIdxByGuid(figGuid)
    if posIdx == nil then
        -- print("Failed to attach figure.")
        return nil
    end
    figure.setRotation(self.gameObj.getRotation())
    local genericFigData = self:getFigureObjectData({}, {
        type = figure.type
    })
    local setToPos = Utils.copy(self.snapPoints[posIdx].Position)
    setToPos.x = setToPos.x + genericFigData.Transform.posX
    setToPos.y = setToPos.y + genericFigData.Transform.posY
    setToPos.z = setToPos.z + genericFigData.Transform.posZ
    local worldPos = self.gameObj.positionToWorld(setToPos)
    figure.setPosition(worldPos)
    figure.memo = tostring(posIdx)
    self.gameObj.addAttachment(figure)
    self.gameObj.UI.setAttribute("btnDetach_" .. posIdx, "active", true)
    self.gameObj.UI.setAttribute("btnFill_" .. posIdx, "active", false)

    self:updateSpectatorWoundsUi()
    return true
end
function GenericUnitTray:onWoundClick()
    self.wounds = (self.wounds + 1) % self.woundsPerModel

    if self.wounds == 0 then
        local ixToDestroy = self.rows * self.columns
        local toDestroy = nil
        for ix = self.rows * self.columns, 1, -1 do
            ixToDestroy = ix
            if not TableUtils.hasValue(self.indicesSpecialFigures, ix) then
                toDestroy = self:getNthAttachment(ixToDestroy)
            end
            if toDestroy ~= nil then
                break
            end
        end
        if toDestroy ~= nil then
            self.gameObj.destroyAttachment(toDestroy.index)
            self.gameObj.UI.setAttribute("btnDetach_" .. ixToDestroy, "active", false)
            self.gameObj.UI.setAttribute("btnFill_" .. ixToDestroy, "active", true)
        end

        if TableUtils.any(self.gameObj.getAttachments()) == false then
            self.gameObj.unlock()
        end
    end

    self:updateWoundsUi()
end
function GenericUnitTray:onHeartClick()
    self.wounds = (self.wounds - 1) % self.woundsPerModel
    self:updateWoundsUi()
end
function GenericUnitTray:updateWoundsUi()
    for i = 1, self.woundsPerModel do
        local isActive = self.wounds >= i
        self.gameObj.UI.setAttribute("EnemyHeart" .. i, "active", isActive)
        self.gameObj.UI.setAttribute("AllyHeart" .. i, "active", isActive)
    end
    self:updateSpectatorWoundsUi()
end
function GenericUnitTray:updateSpectatorWoundsUi()
    self.gameObj.UI.setValue("woundsOverlayText", self.woundsPerModel * #self.gameObj.getAttachments() - self.wounds)
end

function GenericUnitTray:buttonClick_Ready()
    self:updateUnit()
    self:setState("ready")
    self:storeLocation()
end
function GenericUnitTray:buttonClick_Deploy()
    local btns = self.gameObj.getButtons()
    local deployBtn = TableUtils.find(btns, function(it) return it.label == "Deploy" end)
    if self._state == "deploying" then
        self:setState("setup")
        self.gameObj.editButton({index = deployBtn.index, color = "Black"})
    else
        self:setState("deploying")
        self.gameObj.editButton({index = deployBtn.index, color = "Red"})
    end
end
function GenericUnitTray:buttonClick_Move()
    self:returnAllFiguresToTray()
    local position = self.gameObj.getPosition()
    local rotation = self.gameObj.getRotation()
    rotation.x = 0
    rotation.z = 0
    self.gameObj.setRotation(rotation)
    self.rotFix = rotation
    self.undos.position = position
    self.undos.rotation = rotation
    self.gameObj.clearButtons()
    self.gameObj.createButton({
        label = "Done",
        tooltip = "Done",
        click_function = "buttonClick_MoveDone",
        function_owner = self.gameObj,
        position = self:getBtnPos_Done(),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = "Green",
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "Undo",
        tooltip = "Undo",
        click_function = "buttonClick_MoveUndo",
        function_owner = self.gameObj,
        position = self:getBtnPos_Undo(),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = "Red",
        font_color = {1, 1, 1}
    })

    local moveColor = Color.fromString(SETTINGS.rulerColorTint)
    if self.ruler.name == "Move" then
        self:removeRuler()
    elseif self.ruler.name ~= nil then
        moveColor.a = 0.28
    end
    self.ruler.move = self:spawnRuler("Move", moveColor)
    self.gameObj.unlock()
    self:setState("moving")
end
function GenericUnitTray:buttonClick_MoveDone()
    self:setState("ready")
    local pos = self.gameObj.getPosition()
    local rot = self.gameObj.getRotation()
    self.gameObj.setRotation({
        x = 0,
        y = rot.y,
        z = 0
    })
    self.gameObj.setPosition({
        x = pos.x,
        y = 2.05,
        z = pos.z
    })
    if self.ruler.move ~= nil then
        self.ruler.move.destruct()
        self.ruler.move = nil
    end
end
function GenericUnitTray:buttonClick_MoveUndo()
    local old_pos = self.undos.position
    local old_rot = self.undos.rotation

    if old_pos ~= nil then
        self.gameObj.setPosition(old_pos)
        self.gameObj.setRotation(old_rot)
    end
end

TrayPivotUi = {}
-- params = {gameObj, color, _}
function GenericUnitTray:buttonClick_Pivot(params)
    local gameObj, color, _ = unpack(params)

    self:returnAllFiguresToTray()
    self.undos.position = self.gameObj.getPosition()
    self.undos.rotation = self.gameObj.getRotation()

    if TrayPivotUi[self._guid] == nil then
        self:createPivotUi()
    end

    Wait.frames(function()
        self:showPivotUi(color)
    end, 2)
    self.ruler.cached = self.ruler.name
    if self.ruler.name == nil then
        self:setNewRuler("Move")
    end
    self:setState("pivoting")
end
-- TODO: Maybe dont create a ui per tray
function GenericUnitTray:createPivotUi()
    local xmlTable = UI.getXmlTable()
    local rulerButtons = TableUtils.map(TableUtils.keys(self.rulers), function (rulerName, ix)
        local len = TableUtils.len(self.rulers)
        local x = -45 * (len + 1) + ix * 90
        return {
            tag = "Button",
            attributes = {
                id = string.format("ruler%s_%s", string.lower(rulerName), self._guid),
                onClick = string.format("%s/rulerSet(%s)", self._guid, rulerName),
                width = "90",
                height = "30",
                position =  x .. ",300,0"
            },
            value = rulerName .. " ruler"
        }
    end)
    local pivotUi = {
        tag = "Panel",
        attributes = {
            id = "pivot-ui__" .. self._guid,
            active = "false"
        },
        children = {{
            tag = "Slider",
            attributes = {
                id = "finepivotslider_" .. self._guid,
                active = "false",
                onValueChanged = self._guid .. "/setFinePivot()",
                position = "0,400,0",
                width = "1000",
                minValue = "-100",
                maxValue = "100",
                value = "0",
                backGroundColor = "Blue",
                fillColor = "Red",
                handleColor = "Green"
            }
        }, {
            tag = "Slider",
            attributes = {
                id = "normalpivotslider_" .. self._guid,
                onValueChanged = self._guid .. "/setNormalPivot()",
                position = "0,400,0",
                width = "1000",
                minValue = "-180",
                maxValue = "180",
                value = "0",
                backGroundColor = "Green",
                fillColor = "Red",
                handleColor = "Blue"
            }
        }, {
            tag = "Button",
            attributes = {
                id = "pivotmode_" .. self._guid,
                onClick = self._guid .. "/buttonClick_PivotMode()",
                width = "90",
                height = "30",
                position = "0,360,0"
            },
            value = "Fine Pivot"
        }, {
            tag = "Button",
            attributes = {
                id = "pivotundo_" .. self._guid,
                onClick = self._guid .. "/buttonClick_PivotUndo()",
                width = "90",
                height = "30",
                position = "-45,330,0"
            },
            value = "Undo Pivot"
        }, {
            tag = "Button",
            attributes = {
                id = "pivotdone_" .. self._guid,
                onClick = self._guid .. "/buttonClick_PivotDone()",
                width = "90",
                height = "30",
                position = "45,330,0"
            },
            value = "Pivot Done"
        },
        {
            tag = "Button",
            attributes = {
                id = "highlight_" .. self._guid,
                onClick = self._guid .. "/buttonClick_Highlight(true)",
                width = "150",
                height = "30",
                position = "0,270,0"
            },
            value = "Toggle Highlight Flank"
        },
        unpack(rulerButtons),
        }
    }
    table.insert(xmlTable, pivotUi)
    UI.setXmlTable(xmlTable)
end
function GenericUnitTray:showPivotUi(color)
    TrayPivotUi[self._guid] = color
    UI.setAttribute("pivot-ui__" .. self._guid, "active", true)
    UI.setAttribute("pivot-ui__" .. self._guid, "visibility", color)
    self:createEndPivotButtons()
end
function GenericUnitTray:hidePivotUi()
    TrayPivotUi[self._guid] = "Hidden"
    UI.setAttribute("pivot-ui__" .. self._guid, "active", false)
    UI.setAttribute("finepivotslider_" .. self._guid, "value", 0)
    UI.setAttribute("normalpivotslider_" .. self._guid, "value", 0)
end
function GenericUnitTray:buttonClick_PivotMode()
    local mode = UI.getValue("pivotmode_" .. self._guid)
    if mode == "Fine Pivot" then
        UI.setValue("pivotmode_" .. self._guid, "Pivot")
        UI.setAttribute("pivotmode_" .. self._guid, "Text", "Pivot")
        UI.setAttribute("finepivotslider_" .. self._guid, "active", true)
        UI.setAttribute("normalpivotslider_" .. self._guid, "active", false)
    else
        UI.setValue("pivotmode_" .. self._guid, "Fine Pivot")
        UI.setAttribute("pivotmode_" .. self._guid, "Text", "Fine Pivot")
        UI.setAttribute("finepivotslider_" .. self._guid, "active", false)
        local fineValue = UI.getAttribute("finepivotslider_" .. self._guid, "value")
        local normalValue = UI.getAttribute("normalpivotslider_" .. self._guid, "value")
        UI.setAttribute("finepivotslider_" .. self._guid, "value", 0)
        UI.setAttribute("normalpivotslider_" .. self._guid, "value", (fineValue / 10 + normalValue + 180) % 360 -180)
        UI.setAttribute("normalpivotslider_" .. self._guid, "active", true)
        self:setPivot()
    end
end
-- params = {player, value, id}
function GenericUnitTray:setFinePivot(params)
    local player, value, id = unpack(params)
    UI.setAttribute("finepivotslider_" .. self._guid, "value", value)
    self:setPivot()
end
function GenericUnitTray:setNormalPivot(params)
    local player, value, id = unpack(params)
    UI.setAttribute("normalpivotslider_" .. self._guid, "value", value)
    self:setPivot()
end
function GenericUnitTray:setPivot()
    local fineValue = UI.getAttribute("finepivotslider_" .. self._guid, "value")
    local normalValue = UI.getAttribute("normalpivotslider_" .. self._guid, "value")
    local newRotation = self.undos.rotation + Vector(0, fineValue / 10 + normalValue, 0)
    self.gameObj.setRotation(newRotation, false, false)
    self:setXmlRotation(newRotation)
end
-- params = {player, rulerId, id}
function GenericUnitTray:rulerSet(params)
    local player, rulerId, id = unpack(params)
    self:removeRuler()
    self:setNewRuler(rulerId)
end

function GenericUnitTray:createEndPivotButtons()
    self.gameObj.clearButtons()
    self.gameObj.createButton({
        label = "Done",
        tooltip = "Done",
        click_function = "buttonClick_PivotDone",
        function_owner = self.gameObj,
        position = self:getBtnPos_Done(),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = "Green",
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "Undo",
        tooltip = "Undo",
        click_function = "buttonClick_PivotUndo",
        function_owner = self.gameObj,
        position = self:getBtnPos_Undo(),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = "Red",
        font_color = {1, 1, 1}
    })
end
function GenericUnitTray:buttonClick_PivotDone()
    self:removeRuler()
    if self.ruler.cached then
        self:setNewRuler(self.ruler.cached)
    end
    self:hidePivotUi()
    self:setState("ready")

    if self.handleHighlightFlank ~= nil then
        self:buttonClick_Highlight()
    end
end
function GenericUnitTray:buttonClick_PivotUndo()
    local old_pos = self.undos.position
    local old_rot = self.undos.rotation

    if old_pos ~= nil then
        self.gameObj.setPosition(old_pos)
        self.gameObj.setRotation(old_rot)
    end

    if self.ruler.obj ~= nil then
        self.ruler.obj.setRotation(old_rot)
    end
    UI.setAttribute("finepivotslider_" .. self._guid, "value", 0)
    UI.setAttribute("normalpivotslider_" .. self._guid, "value", 0)
    self:setXmlRotation(old_rot)
end

function GenericUnitTray:createChargeButtons(createDoneBtn)
    self.gameObj.clearButtons()
    if createDoneBtn then
        self.gameObj.createButton({
            label = "Done",
            tooltip = "Done",
            click_function = "buttonClick_alignDone",
            function_owner = self.gameObj,
            position = self:getBtnPos_Done(),
            rotation = {0, 180, 0},
            height = 220,
            width = 480,
            font_size = 150,
            color = "Green",
            font_color = {1, 1, 1}
        })
    else
        self.gameObj.createButton({
            label = "Collide with Target",
            click_function = "buttonClick_alignHelp",
            function_owner = self.gameObj,
            position = self:getBtnPos_Collide(),
            rotation = {0, 180, 0},
            height = 220,
            width = 1400,
            font_size = 150,
            color = "Black",
            font_color = {1, 1, 1}
        })
    end
    self.gameObj.createButton({
        label = "Cancel",
        tooltip = "Cancel",
        click_function = "buttonClick_alignCancel",
        function_owner = self.gameObj,
        position = self:getBtnPos_Undo(),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = "Red",
        font_color = {1, 1, 1}
    })
end
function GenericUnitTray:buttonClick_Charge()
    self.gameObj.unlock()
    self:returnAllFiguresToTray()
    self.undos.position = self.gameObj.getPosition()
    self.undos.rotation = self.gameObj.getRotation()
    self:createChargeButtons()
    self:setState("charging")
end
function GenericUnitTray:buttonClick_alignCancel()
    self:endAllActions()
    self:setState("ready")

    local alignUnit = gameObjects[self.alignUnitGuid]
    if alignUnit ~= nil then
        alignUnit.chargingUnitGuid = nil
        alignUnit:endAllActions()
        alignUnit:setState("ready")
    end
    self.alignUnitGuid = nil

    local old_pos = self.undos.position
    local old_rot = self.undos.rotation

    if old_pos ~= nil then
        self.gameObj.setPosition(old_pos)
        self.gameObj.setRotation(old_rot)
    end
end
function GenericUnitTray:buttonClick_alignChangeTarget()
    local alignUnit = gameObjects[self.alignUnitGuid]
    if alignUnit ~= nil then
        alignUnit.chargingUnitGuid = nil
        alignUnit:endAllActions()
        alignUnit:setState("ready")
    end

    self:createChargeButtons()
    self:setState("charging")
    self.alignUnitGuid = nil
end
function GenericUnitTray:buttonClick_alignHelp()
    broadcastToAll(
        "You have not collide with the target yet. Please move the unit tray so that it collides with the target of the charge.",
        {1, 1, 1})
end
function GenericUnitTray:onCollisionEnter(info)
    if info == nil then
        return
    end
    info = info[1]

    if info.collision_object.hasTag(self.unitModelTag) then
        Wait.condition(function()
            self:tryAttachFigure(info.collision_object)
        end, function()
            return self.gameObj.resting == true and not info.collision_object.held_by_color
        end)
    end

    if self._state ~= "charging" then
        return
    end

    if info.collision_object.hasTag(GenericUnitTray.unitTrayTag) then
        self:setState("collided")
        self.gameObj.clearButtons()
        self.gameObj.createButton({
            label = "Cancel",
            click_function = "buttonClick_alignCancel",
            function_owner = self.gameObj,
            position = self:getBtnPos_Undo(),
            rotation = {0, 180, 0},
            height = 220,
            width = 480,
            font_size = 150,
            color = "Red",
            font_color = {1, 1, 1}
        })
        self.gameObj.createButton({
            label = "Change Target",
            click_function = "buttonClick_alignChangeTarget",
            function_owner = self.gameObj,
            position = self:getBtnPos_Collide(),
            rotation = {0, 180, 0},
            height = 220,
            width = 1200,
            font_size = 150,
            color = "Orange",
            font_color = {1, 1, 1}
        })
        self.alignUnitGuid = info.collision_object.getGUID()
        local alignObj = gameObjects[self.alignUnitGuid]
        -- If alignTarget has any ruler on, remove it.
        alignObj:endAllActions()
        alignObj:setState("target_align")
        alignObj.chargingUnitGuid = self._guid
        alignObj:setNewRuler("Align")
        alignObj:createAlignButtons()
    end
end
function GenericUnitTray:createAlignButtons()
    self.gameObj.clearButtons()
    self.gameObj.createButton({
        label = "Front",
        click_function = "buttonClick_alignFront",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(0, 1),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = ">",
        click_function = "buttonClick_alignFrontLeft",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(-1, 1),
        rotation = {0, 180, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "<",
        click_function = "buttonClick_alignFrontRight",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(1, 1),
        rotation = {0, 180, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })

    self.gameObj.createButton({
        label = "Left",
        click_function = "buttonClick_alignLeft",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(1, 0),
        rotation = {0, 90, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "<",
        click_function = "buttonClick_alignLeftRight",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(1, -1),
        rotation = {0, 90, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = ">",
        click_function = "buttonClick_alignLeftLeft",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(1, 1),
        rotation = {0, 90, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })

    self.gameObj.createButton({
        label = "Right",
        click_function = "buttonClick_alignRight",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(-1, 0),
        rotation = {0, 270, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = ">",
        click_function = "buttonClick_alignRightLeft",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(-1, -1),
        rotation = {0, 270, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "<",
        click_function = "buttonClick_alignRightRight",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignLeftRight(-1, 1),
        rotation = {0, 270, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })

    self.gameObj.createButton({
        label = "Rear",
        click_function = "buttonClick_alignRear",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(0, -1),
        rotation = {0, 180, 0},
        height = 220,
        width = 480,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = ">",
        click_function = "buttonClick_alignRearRight",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(-1, -1),
        rotation = {0, 180, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
    self.gameObj.createButton({
        label = "<",
        click_function = "buttonClick_alignRearLeft",
        function_owner = self.gameObj,
        position = self:getBtnPos_AlignFrontRear(1, -1),
        rotation = {0, 180, 0},
        height = 220,
        width = 360 * self.btnScale,
        font_size = 150,
        color = {0, 0, 0},
        font_color = {1, 1, 1}
    })
end
function GenericUnitTray:buttonClick_alignFront()
    self:doAlign("Front", 0)
end
function GenericUnitTray:buttonClick_alignFrontLeft()
    self:doAlign("Front", -1)
end
function GenericUnitTray:buttonClick_alignFrontRight()
    self:doAlign("Front", 1)
end
function GenericUnitTray:buttonClick_alignRear()
    self:doAlign("Rear", 0)
end
function GenericUnitTray:buttonClick_alignRearLeft()
    self:doAlign("Rear", -1)
end
function GenericUnitTray:buttonClick_alignRearRight()
    self:doAlign("Rear", 1)
end
function GenericUnitTray:buttonClick_alignLeft()
    self:doAlign("Left", 0)
end
function GenericUnitTray:buttonClick_alignLeftLeft()
    self:doAlign("Left", -1)
end
function GenericUnitTray:buttonClick_alignLeftRight()
    self:doAlign("Left", 1)
end
function GenericUnitTray:buttonClick_alignRight()
    self:doAlign("Right", 0)
end
function GenericUnitTray:buttonClick_alignRightLeft()
    self:doAlign("Right", -1)
end
function GenericUnitTray:buttonClick_alignRightRight()
    self:doAlign("Right", 1)
end
function GenericUnitTray:doAlign(face, offset)
    local chargingUnit = gameObjects[self.chargingUnitGuid]
    if chargingUnit == nil then
        self:endAllActions()
        self:setState("ready")
        return
    end
    chargingUnit:setState("aligning")

    local pos = self.gameObj.getPosition()
    local rot = self.gameObj.getRotation()
    if face == "Front" then
        local tForward = self.gameObj.getTransformForward()
        pos = pos + tForward:normalize():scale(0.5 * (self.length + chargingUnit.length))
        rot = rot + Vector(0, 180, 0)
    elseif face == "Rear" then
        local tForward = self.gameObj.getTransformForward()
        pos = pos + tForward:normalize():scale(-0.5 * (self.length + chargingUnit.length))
    elseif face == "Left" then
        local tRight = self.gameObj.getTransformRight()
        pos = pos + tRight:normalize():scale(-0.5 * (self.width + chargingUnit.length))
        rot = rot + Vector(0, 90, 0)
    elseif face == "Right" then
        local tRight = self.gameObj.getTransformRight()
        pos = pos + tRight:normalize():scale(0.5 * (self.width + chargingUnit.length))
        rot = rot + Vector(0, -90, 0)
    end
    chargingUnit.gameObj.setRotation(rot)
    if offset ~= 0 then
        local tOffset = chargingUnit.gameObj.getTransformRight()
        pos = pos + tOffset:normalize():scale(self.alignmentFactor * chargingUnit.width * offset)
    end
    chargingUnit.chargeAlign = {}
    chargingUnit.chargeAlign.position = pos
    chargingUnit.chargeAlign.rotation = rot
    chargingUnit.gameObj.setPosition(pos)
    chargingUnit:createChargeButtons(true)
end
function GenericUnitTray:buttonClick_alignDone()
    self:endAllActions()
    self:setState("ready")
    local alignUnit = gameObjects[self.alignUnitGuid]
    if alignUnit ~= nil then
        alignUnit.chargingUnitGuid = nil
        alignUnit:endAllActions()
        alignUnit:setState("ready")
    end
    self.alignUnitGuid = nil
end

-- params = {tray, playerColor, altClick}
function GenericUnitTray:buttonClick_Ruler(params)
    local tray, playerColor, altClick = unpack(params)
    local keys = TableUtils.keys(self.rulers)
    local idx = TableUtils.getIdx(keys, self.ruler.name)
    local rulerToSet = keys[idx + 1]
    self:removeRuler()
    local btns = self.gameObj.getButtons()
    local rulerBtn = TableUtils.find(btns, function(it) return it.label == "Rulers" end)
    local highlightBtn = TableUtils.find(btns, function(it) return TableUtils.hasValue(GenericUnitTray.HIGHLIGHT_MODES, it.label) end)
    local offBtn = TableUtils.find(btns, function(it) return it.label == "Off" end)
    if rulerToSet ~= nil and not altClick then
        self:setNewRuler(rulerToSet)
        self.gameObj.editButton({index = rulerBtn.index, color = "Green"})
        if highlightBtn == nil then
            self:createRulerHighlightButton()
            self:createRulerOffButton()
        end
    else
        self:highlightFlankOff()
        self.gameObj.editButton({index = rulerBtn.index, color = "Black"})
        if highlightBtn ~= nil then
            self.gameObj.removeButton(highlightBtn.index)
        end
        if offBtn ~= nil then
            self.gameObj.removeButton(offBtn.index)
        end
    end
end
function GenericUnitTray:buttonClick_RulerOff()
    self:removeRuler()
    self:highlightFlankOff()
    local btns = self.gameObj.getButtons()
    local rulerBtn = TableUtils.find(btns, function(it) return it.label == "Rulers" end)
    local highlightBtn = TableUtils.find(btns, function(it) return TableUtils.hasValue(GenericUnitTray.HIGHLIGHT_MODES, it.label) end)
    local offBtn = TableUtils.find(btns, function(it) return it.label == "Off" end)
    self.gameObj.editButton({index = rulerBtn.index, color = "Black"})
    if highlightBtn ~= nil then
        self.gameObj.removeButton(highlightBtn.index)
    end
    if offBtn ~= nil then
        self.gameObj.removeButton(offBtn.index)
    end
end
function GenericUnitTray:spawnRuler(rulerid, color)
    local world = self.gameObj.getPosition()
    local rot = self.gameObj.getRotation()
    local obj_parameters = {
        type = 'Custom_Model',
        position = {world.x, 1.75, world.z},
        rotation = {0, rot.y, 0}
    }
    local custom = {
        mesh = self.rulers[rulerid],
        collider = 'https://steamusercontent-a.akamaihd.net/ugc/958593001519976588/E46B0118C9DDC770C8A39C27FD6DECFEDFB899DD/',
        material = 3,
        specular_color = color,
        freshnel_strength = 0,
        specular_intensity = 0
    }
    local newruler = spawnObject(obj_parameters)
    newruler.setCustomObject(custom)
    newruler.lock()
    newruler.setDescription(rulerid)
    newruler.setColorTint(color)

    return newruler
end
function GenericUnitTray:setNewRuler(rulerid)
    local newruler = self:spawnRuler(rulerid, Color.fromString(SETTINGS.rulerColorTint))
    self.ruler.name = rulerid
    self.ruler.obj = newruler
    local rot = self.gameObj.getRotation()
    newruler.setRotation({0, rot.y, 180})

    Wait.frames(function()
        if not newruler then
            return
        end
        self.gameObj.setRotationSmooth(rot, false, true)
        newruler.setRotation({0, rot.y, 0})
        newruler.getComponent("Rigidbody").set("mass", 0)
    end, 3)
end
function GenericUnitTray:removeRuler()
    self.ruler.name = nil
    if self.ruler.obj then
        self.ruler.obj.destruct()
        self.ruler.obj = nil
    end
end

GenericUnitTray.HIGHLIGHT_MODES = {
    "Highlight",
    "HL: Flank"
}
function GenericUnitTray:buttonClick_Highlight(params)
    if self.handleHighlightFlank ~= nil then
        self:highlightFlankOff()
    else
        self:highlightFlankOn()
    end
    
    self:updateHighlightButton()
end
function GenericUnitTray:highlightFlankOn()
    for _, obj in pairs(gameObjects) do
        if obj._guid ~= self._guid and obj.handleHighlightFlank ~= nil then
            obj.highlightFlankOff()
            obj:updateHighlightButton()
        end
    end

    local filter = function(obj) return self:isFlank(obj.getPosition()) end
    self:doHighlightOthers(filter)
    self.handleHighlightFlank = Wait.time(function() self:doHighlightOthers(filter) end, 0.25, -1)
end
function GenericUnitTray:highlightFlankOff()
    if self.handleHighlightFlank == nil then
        return
    end
    Wait.stop(self.handleHighlightFlank)
    self:doHighlightOthers(function() return false end)
    self.handleHighlightFlank = nil
end
function GenericUnitTray:updateHighlightButton()
    if TrayPivotUi[self._guid] ~= nil then
        local btnColor
        if self.handleHighlightFlank == nil then
            btnColor = "#FFFFFF|#FFFFFF|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"
        else
            btnColor = "#CCCCCC|#FFFFFF|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"
        end
        UI.setAttribute("highlight_" .. self._guid, "color", btnColor)
    end

    local btns = self.gameObj.getButtons()
    local hlBtn = TableUtils.find(btns, function(it) return TableUtils.hasValue(GenericUnitTray.HIGHLIGHT_MODES, it.label) end)
    if hlBtn == nil then
        return
    end

    local btnIdx = hlBtn.index
    local labelToSet = self.handleHighlightFlank == nil and "Highlight" or "HL: Flank"
    local color = labelToSet == "Highlight" and "Black" or "Red"
    self.gameObj.editButton({index = btnIdx, label = labelToSet, color = color})
end
function GenericUnitTray:doHighlightOthers(filter)
    for _, obj in pairs(gameObjects) do
        if obj.doHighlightOthers and obj._guid ~= self._guid and obj.gameObj ~= nil and filter(obj.gameObj) then
            local tint = obj.gameObj.getColorTint()
            local hlColor = (tint.r >= 0.75 and tint.g <= 0.5 and tint.b <= 0.5) and "Yellow" or "Red"
            obj.gameObj.highlightOn(hlColor)
        elseif obj.gameObj ~= nil then
            obj.gameObj.highlightOff()
        end
    end
end
function GenericUnitTray:isFlank(coord)
    local pos = self.gameObj.getPosition()
    local trRight = self.gameObj.getTransformRight()
    local trLeft = Vector(-trRight.x, trRight.y, -trRight.z)
    local crossLeft = pos + 0.5 * trLeft * (self.width - self.length)
    local crossRight = pos + 0.5 * trRight * (self.width - self.length)

    local isLeftFlank = (coord - crossLeft):angle(trLeft) <= 45
    local isRightFlank = (coord - crossRight):angle(trRight) <= 45

    return isLeftFlank or isRightFlank
end

-- I've given this function less responsibilities (mostly doing cleanup). It's still a bit confusing when and why it's called
function GenericUnitTray:endAllActions()
    self:removeRuler()

    if self.chargingUnitGuid ~= nil then
        local chargingUnit = gameObjects[self.chargingUnitGuid]
        if chargingUnit ~= nil then
            self.chargingUnitGuid = nil
            chargingUnit:buttonClick_alignChangeTarget()
        end
    end

    if TrayPivotUi[self._guid] ~= nil then
        self:hidePivotUi()
    end

    if self.ruler.move ~= nil then
        self.ruler.move.destruct()
    end

    self.chargeAlign = nil

    self:highlightFlankOff()

    if self._state == "containered" then
        return
    end
    self:setXmlRotation(self.gameObj.getRotation())
    self:returnAllFiguresToTray()
end

-- TODO: ENEMY ATTACHMENTS
function GenericUnitTray:getTotalCost()
    return self.cost
end

function GenericUnitTray:onEndRound()
    if self._state == "containered" then
        return
    end
    if self.gameObj == nil then
        log("onEndRound: the tray was deleted")
        return
    end
    self.statNames.Activation = false
    self.statNames.Order = false
    self:storeLocation()
    self:updateStates()
    self:updateSpectatorPanel()
end

function GenericUnitTray:getObjectData(opts)
    opts = opts or {}
    opts.color = opts.color or {
        r = 0,
        g = 0,
        b = 0
    }
    local customMesh = self.CustomMesh
    customMesh.CustomShader.SpecularColor = TableUtils.map(opts.color, function(n) return 0.5 + 0.5 * n end)
    return {
        Name = "Custom_Model",
        Nickname = opts.Nickname,
        Transform = {
            posX = 0,
            posY = 3,
            posZ = 0,
            rotX = 0,
            rotY = 0,
            rotZ = 0,
            scaleX = 1,
            scaleY = 1,
            scaleZ = 1
        },
        Tags = {GenericUnitTray.unitTrayTag, self.__className},
        ColorDiffuse = opts.color,
        Snap = false,
        Grid = false,
        CustomMesh = customMesh,
        CustomUIAssets = self.defaultCustomUIAssets,
        AttachedSnapPoints = self.snapPoints,
        ChildObjects = opts.ChildObjects,
    }
end
function GenericUnitTray:getFigureObjectData(unitFigure, opts)
    opts = opts or {}
    local figureData = {
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 0,
            rotZ = 0,
            scaleX = 1.05,
            scaleY = 1.05,
            scaleZ = 1.05
        },
        Tags = {self.unitModelTag, GenericUnitTray.unitModelTag},
        Snap = true,
        Grid = true,
        Autoraise = false
    }
    if opts.type == "Figurine" or (unitFigure.assetBundle and SETTINGS.use3DMiniatures) then
        figureData.Name = "Custom_Assetbundle"
        figureData.Transform.posY = -0.12
        figureData.CustomAssetbundle = {
            AssetbundleURL = unitFigure.assetBundle,
            AssetbundleSecondaryURL = "",
            MaterialIndex = 0,
            TypeIndex = 1,
            LoopingEffectIndex = 0
        }
    else
        figureData.Name = "Figurine_Custom"
        figureData.Transform.posY = 0.08
        figureData.Transform.scaleX = self.figureScale
        figureData.Transform.scaleY = self.figureScale
        figureData.Transform.scaleZ = self.figureScale
        figureData.CustomImage = {
            ImageURL = unitFigure.image,
            ImageSecondaryURL = unitFigure.image,
            ImageScalar = unitFigure.scale or "1.0"
        }
    end
    return figureData
end
function GenericUnitTray:spawn(objectData, opts)
    opts = opts or {}
    local gameObj = spawnObjectData({
        data = objectData,
        position = opts.position, -- This overrides Transform from objectData
        rotation = opts.rotation,
        sound = opts.sound,
        callback_function = opts.callback
    })
    local tray = self(gameObj, opts.spawnOptions)
    tray:init()
    return tray
end
function GenericUnitTray:spawnGeneric(opts)
    local objData = self:getObjectData(opts.data)
    return self:spawn(objData, opts.spawn)
end

InfantryTray = {}
InfantryTray.__index = InfantryTray
InfantryTray.__className = "InfantryTray"
setmetatable(InfantryTray, {
    __index = GenericUnitTray,
    __call = function(cls, gameObj, opts)
        opts = Utils.copy(opts or {})
        opts.__className = cls.__className
        local this = setmetatable(GenericUnitTray(gameObj, opts), InfantryTray)
        return this
    end
})

InfantryTray.width = 5.5
InfantryTray.length = 4.8
InfantryTray.columns = 4
InfantryTray.rows = 3
InfantryTray.figureScale = 0.64
InfantryTray.unitModelTag = "InfantryModel"
InfantryTray.snapPoints = {{
    Position = {
        x = -1.91,
        y = 0.16,
        z = 1.43
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = -0.61,
        y = 0.16,
        z = 1.43
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 0.66,
        y = 0.16,
        z = 1.43
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 1.95,
        y = 0.16,
        z = 1.43
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = -1.91,
        y = 0.16,
        z = 0
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = -0.61,
        y = 0.16,
        z = 0
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 0.66,
        y = 0.16,
        z = 0
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 1.95,
        y = 0.16,
        z = 0
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = -1.91,
        y = 0.16,
        z = -1.40
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = -0.61,
        y = 0.16,
        z = -1.40
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 0.66,
        y = 0.16,
        z = -1.40
    },
    Tags = {InfantryTray.unitModelTag}
}, {
    Position = {
        x = 1.95,
        y = 0.16,
        z = -1.40
    },
    Tags = {InfantryTray.unitModelTag}
}}
function InfantryTray:getFillDetachBtnPosition(column, row)
    return {
        x = -192 + column * 128,
        y = -23,
        z = 141 - row * 141
    }
end
InfantryTray.CustomMesh = {
    MeshURL = "https://steamusercontent-a.akamaihd.net/ugc/999141806436561486/BE2A07C03F61289C391DE8F075AC54408AF6CBA6/",
    ColliderURL = "https://steamusercontent-a.akamaihd.net/ugc/958593270446643845/B59CBCB03AF3EDB319D9033A8A93D03FA7B45087/",
    Convex = true,
    MaterialIndex = 0,
    TypeIndex = 0,
    CustomShader = {
        SpecularColor = {
            r = 1,
            g = 1,
            b = 1,
            a = 1
        },
        SpecularIntensity = 0.2,
        SpecularSharpness = 7,
        FresnelStrength = 0.4
    },
}
InfantryTray.rulers = {
    Attack = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191411034/0D183B3CE11218F8060EFF94032BF44C231F7666/",
    Range = "https://steamusercontent-a.akamaihd.net/ugc/2058741574604895309/89ADF70C72B24777D8ABDAC87C9D843C3A579A62/",
    Align = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191410680/408B72CBFFEF45F5FFE227426875B46E7B665759/",
    Move = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191411942/5FE006AFEC1A1038C542E3CD2553FF9D5D4EADFD/",
}
function InfantryTray:isFlank(coord)
    local pos = self.gameObj.getPosition()
    local trRight = self.gameObj.getTransformRight()
    local trLeft = Vector(-trRight.x, trRight.y, -trRight.z)

    local angle = math.atan(4.8 / 5.5) * 180 / math.pi
    local isLeftFlank = (coord - pos):angle(trLeft) <= angle
    local isRightFlank = (coord - pos):angle(trRight) <= angle

    return isLeftFlank or isRightFlank
end

CavalryTray = {}
CavalryTray.__index = CavalryTray
CavalryTray.__className = "CavalryTray"
setmetatable(CavalryTray, {
    __index = GenericUnitTray,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        opts.__className = cls.__className
        opts.woundsPerModel = opts.woundsPerModel or 3
        local this = setmetatable(GenericUnitTray(gameObj, opts), CavalryTray)
        return this
    end
})

CavalryTray.width = 5.5
CavalryTray.length = 5
CavalryTray.columns = 2
CavalryTray.rows = 2
CavalryTray.figureScale = 1.05
CavalryTray.unitModelTag = "CavalryModel"
CavalryTray.snapPoints = {{
    Position = {
        x = -1.24,
        y = 0.16,
        z = 1.10
    },
    Tags = {CavalryTray.unitModelTag}
}, {
    Position = {
        x = 1.32,
        y = 0.16,
        z = 1.10
    },
    Tags = {CavalryTray.unitModelTag}
}, {
    Position = {
        x = -1.24,
        y = 0.16,
        z = -1.09
    },
    Tags = {CavalryTray.unitModelTag}
}, {
    Position = {
        x = 1.32,
        y = 0.16,
        z = -1.09
    },
    Tags = {CavalryTray.unitModelTag}
}}
function CavalryTray:getFillDetachBtnPosition(column, row)
    return {
        x = -128 + column * 254,
        y = -23,
        z = 114 - row * 220
    }
end

CavalryTray.CustomMesh = {
    MeshURL = "https://steamusercontent-a.akamaihd.net/ugc/955216017926529138/50B776029E5A2221D74F4B8E1E61020302874CB9/",
    ColliderURL = "https://steamusercontent-a.akamaihd.net/ugc/958593270446666807/DC2945B71E06D9281492AF2670F564AA719DE472/",
    Convex = true,
    MaterialIndex = 0,
    TypeIndex = 0,
    CustomShader = {
        SpecularColor = {
            r = 1,
            g = 1,
            b = 1,
            a = 1
        },
        SpecularIntensity = 0.2,
        SpecularSharpness = 7,
        FresnelStrength = 0.4
    },
}
CavalryTray.rulers = {
    Attack = "https://steamusercontent-a.akamaihd.net/ugc/2058741574604894037/E4C82476B48C5013D47131B936640FDFE6E98CB9/",
    Range = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191412530/65A719031854F118B3D80B672C6C49529AE05CE8/",
    Align = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191410680/408B72CBFFEF45F5FFE227426875B46E7B665759/",
    Move = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191411626/C5870A8EF0FB345F0D13040E4CAFF36A2BEA2C58/",
}

SoloTray = {}
SoloTray.__index = SoloTray
SoloTray.__className = "SoloTray"
setmetatable(SoloTray, {
    __index = GenericUnitTray,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        opts.__className = cls.__className
        local this = setmetatable(GenericUnitTray(gameObj, opts), SoloTray)
        return this
    end
})

SoloTray.width = 2.76
SoloTray.length = 2.76
SoloTray.columns = 1
SoloTray.rows = 1
SoloTray.figureScale = 1.05
SoloTray.btnScale = 0.6
SoloTray.unitModelTag = "CavalryModel" -- same size, should be able to attach to cavalry trays?
SoloTray.snapPoints = {{
    Position = {
        x = 0,
        y = 0.157000154,
        z = 0
    },
    Tags = {SoloTray.unitModelTag}
}}
function SoloTray:getFillDetachBtnPosition(column, row)
    return {
        x = 0,
        y = -23,
        z = 0
    }
end
SoloTray.CustomMesh = {
    MeshURL = "https://steamusercontent-a.akamaihd.net/ugc/1461933130017705580/D8B6E8FCFBC9AEDB19E0FA3E42D2E5D2BEBCF9F7/",
    ColliderURL = "https://steamusercontent-a.akamaihd.net/ugc/1461933130017707267/89416429B3C500946E993FD159B41A2EF951223F/",
    Convex = true,
    MaterialIndex = 0,
    TypeIndex = 0,
    CustomShader = {
        SpecularColor = {
            r = 1,
            g = 1,
            b = 1,
            a = 1
        },
        SpecularIntensity = 0.2,
        SpecularSharpness = 7,
        FresnelStrength = 0.4
    },
}
SoloTray.rulers = {
    Attack = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191411175/07C48AF2BC97E42890B8F68EAD8D6C07B2A97576/",
    Range = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191412949/DC788BD1F26D88B23D9523004C72F8985E3576AD/",
    Align = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191410680/408B72CBFFEF45F5FFE227426875B46E7B665759/",
    Move = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191412095/8CAB3D8D97957150195F88FE20515C731F567730/",
}

WarmachineTray = {}
WarmachineTray.__index = WarmachineTray
WarmachineTray.__className = "WarmachineTray"
setmetatable(WarmachineTray, {
    __index = GenericUnitTray,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        opts.__className = cls.__className
        local this = setmetatable(GenericUnitTray(gameObj, opts), WarmachineTray)
        return this
    end
})

WarmachineTray.width = 2.76
WarmachineTray.length = 5.55
WarmachineTray.columns = 1
WarmachineTray.rows = 1
WarmachineTray.figureScale = 1.05
WarmachineTray.unitModelTag = "CavalryModel" -- same size, should be able to attach to cavalry trays?
WarmachineTray.snapPoints = {{
    Position = {
        x = 0,
        y = 0.157000154,
        z = 0
    },
    Tags = {WarmachineTray.unitModelTag}
}}
function WarmachineTray:getFillDetachBtnPosition(column, row)
    return {
        x = 0,
        y = -23,
        z = 0
    }
end
WarmachineTray.CustomMesh = {
    MeshURL = "https://steamusercontent-a.akamaihd.net/ugc/1461933130017691269/5B5E8FDA7812D2417EB5CCCC72CFB1B13793401E/",
    ColliderURL = "https://steamusercontent-a.akamaihd.net/ugc/1461933130017692332/D503C4B988FC0138DBB95AD01AF60A4338DA95E1/",
    Convex = true,
    MaterialIndex = 0,
    TypeIndex = 0,
    CustomShader = {
        SpecularColor = {
            r = 1,
            g = 1,
            b = 1,
            a = 1
        },
        SpecularIntensity = 0.2,
        SpecularSharpness = 7,
        FresnelStrength = 0.4
    },
}
WarmachineTray.rulers = {
    Attack = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191411487/53B163AA2E63BD58395FB4F613DD60CBB3A5BFA1/",
    Range = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191413216/D002B1ADBAFC4E021A80F605714080B19ADBA443/",
    Align = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191410680/408B72CBFFEF45F5FFE227426875B46E7B665759/",
    Move = "https://steamusercontent-a.akamaihd.net/ugc/2031716132191412368/C1ADAC47D72365F28F0A5E2AA5EA026A84745E08/"
}

function GenericUnitTray:getBtnPos_Done()
    return {self.width * 0.5 * 0.6, 0.22, 0.3 - self.length * 0.5}
end
function GenericUnitTray:getBtnPos_Undo()
    return {self.width * -0.5 * 0.6, 0.22, 0.3 - self.length * 0.5}
end

function GenericUnitTray:getBtnPos_Collide()
    return {self.width * 0.5 * 0.3, 0.22, 0.3 - self.length * 0.5}
end
-- TODO: This looks bad imo
function SoloTray:getBtnPos_Collide()
    return {0, 0.22, -self.length * 0.5 - 0.3}
end
function WarmachineTray:getBtnPos_Collide()
    return {0, 0.22, -self.length * 0.5 - 0.3}
end

function GenericUnitTray:getBtnPos_AlignFrontRear(x, y)
    return {x * self.width * 0.5 * 0.6, 0.22, (self.length * 0.5 - 0.3) * y}
end
function GenericUnitTray:getBtnPos_AlignLeftRight(x, y)
    return {x * (self.width * 0.5 - 0.2), 0.22, self.length * 0.5 * 0.6 * y}
end

function GenericUnitTray:getBtnPos_FrontCenter()
    return {0, 0.22, self.length * 0.5 - 0.3}
end
function GenericUnitTray:getBtnPos_FrontLeft()
    return {self.width * 0.5 * 0.6, 0.22, self.length * 0.5 - 0.3}
end
function GenericUnitTray:getBtnPos_FrontRight()
    return {self.width * -0.5 * 0.6, 0.22, self.length * 0.5 - 0.3}
end

function GenericUnitTray:getBtnPos_Move()
    return {0, 0.22, 0.3 - self.length * 0.5}
end
function GenericUnitTray:getBtnPos_Pivot()
    return {self.width * 0.5 * 0.6, 0.22, 0.3 - self.length * 0.5}
end
function GenericUnitTray:getBtnPos_Charge()
    return {self.width * -0.5 * 0.6, 0.22, 0.3 - self.length * 0.5}
end
function SoloTray:getBtnPos_Pivot()
    return {self.width * 0.5 - 0.3, 0.22, 0}
end
function SoloTray:getBtnPos_Charge()
    return {0.3 - self.width * 0.5, 0.22, 0}
end
function WarmachineTray:getBtnPos_Pivot()
    return {self.width * 0.5 - 0.3, 0.22, 0}
end
function WarmachineTray:getBtnPos_Charge()
    return {0.3 - self.width * 0.5, 0.22, 0}
end

function GenericUnitTray:getBtnRot_Pivot()
    return {0, 180, 0}
end
function GenericUnitTray:getBtnRot_Charge()
    return {0, 180, 0}
end
function SoloTray:getBtnRot_Pivot()
    return {0, 90, 0}
end
function SoloTray:getBtnRot_Charge()
    return {0, 270, 0}
end
function WarmachineTray:getBtnRot_Pivot()
    return {0, 90, 0}
end
function WarmachineTray:getBtnRot_Charge()
    return {0, 270, 0}
end

GenericUnitTray.btnScale = 1
SoloTray.btnScale = 0.75
WarmachineTray.btnScale = 0.75


-- USE THIS TO INJECT THE TRAY CODE ONTO EXISTING OBJECTS
-- function onLoad() Wait.condition(function() Global.call('injectTrayCode', {class = 'InfantryTray', guid = self.getGUID()}) end, function() return self.resting end) end
function injectTrayCode(params)
    local infTray = getObjectFromGUID(params.guid)
    local pos = infTray.getPosition()
    local rot = infTray.getRotation()
    local color = infTray.getColorTint()
    infTray.destruct()
    local trayClass = _G[params.class]
    local obj = trayClass:spawnGeneric({data = {color = color}, spawn = {position  = pos, rotation = rot}})
end