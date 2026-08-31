local TableUtils = require("lua.utils-table")
local UiUtil = require("lua.utils-ui")
local SettingsUtil = require("lua.settings")


local Clock = {
    _idPausedPanel = "layout__gamePaused",
    _idTimeRanOut = "layout__timeRanOut",
    _idClockRow = "tableRow__clock",
    _idDivider = "tableRow__divider",
    _idTime = {
        Blue = "bluePlayerTime",
        Red = "redPlayerTime",
    },
    _idPrefixSpentBar = "clock__barSpent_",
    _idPrefixRemainingBar = "clock__barRemaining_",
    panelWidth = 128,

    warning = 300,
    criticalWarning = 60,

    playerColors = {"Blue", "Red"},
    waitHandle = nil,
    state = {}
}

function Clock:init()
    if SETTINGS.useClock then
        Clock:enable()
    else
        Clock:disable()
    end
end
function Clock:reset()
    self.state.initalTime = SETTINGS.clockInitialTime * 60
    self.state.Red = self.state.initalTime
    self.state.Blue = self.state.initalTime
    self.state.paused = true
    self.state.ended = false

    if not SETTINGS.useClock then
        return
    end

    Wait.frames(function()
        for _, color in ipairs(self.playerColors) do
            self:updateScoreUi(color)
            self:updateScoreBar(color, self.panelWidth)
        end
        self:pause()
    end, 10)
end

function Clock:enable()
    Turns.enable = true
    Turns.order = self.playerColors
    self.state.paused = true
    self.state.initalTime = SETTINGS.clockInitialTime * 60
    if self.state.Red == nil or self.state.ended then
        self.state.Red = self.state.initalTime
    end
    if self.state.Blue == nil or self.state.ended then
        self.state.Blue = self.state.initalTime
    end
    self.state.ended = false
    self:showScoreUi()
    Wait.frames(function()
        for _, color in ipairs(self.playerColors) do
            self:updateScoreUi(color)
        end
        self:pause()
    end, 10)
end
function Clock:disable()
    Turns.enable = false
    self:stop()
    self:hidePauseUi()
    self:hideScoreUi()
    self:hideTimeRanOutUi()
end

function Clock:showScoreUi()
    SettingsUtil.setVpPanelHeight()
    Wait.frames(function()
        UI.setAttribute(self._idClockRow, "active", true)
        UI.setAttribute(self._idDivider, "active", true)
    end, 5)
end
function Clock:hideScoreUi()
    SettingsUtil.setVpPanelHeight()
    Wait.frames(function()
        UI.setAttribute(self._idClockRow, "active", false)
        UI.setAttribute(self._idDivider, "active", false)
    end, 5)
end

function Clock:showPauseUi()
    UI.setAttribute(self._idPausedPanel, "active", true)
end
function Clock:hidePauseUi()
    UI.setAttribute(self._idPausedPanel, "active", false)
end
function Clock:showTimeRanOutUi()
    UI.setAttribute(self._idTimeRanOut, "active", true)
end
function Clock:hideTimeRanOutUi()
    UI.setAttribute(self._idTimeRanOut, "active", false)
end
function Clock:updateTimeRanOutUi(playerColor)
    local id = self._idTimeRanOut .. "_text"
    local playerName = UiUtil.getPlayerName(playerColor)
    UI.setAttribute(id, "color", playerColor)
    UI.setValue(id, playerName.." ran out of time!")
end

function Clock:stop()
    if self.waitHandle ~= nil then
        Wait.stop(self.waitHandle)
    end
end
function Clock:start()
    if self.state.ended then
        return
    end
    self.waitHandle = Wait.time(function()
        self:update()
    end, 1, -1)
end

function Clock:pause()
    self.state.paused = true
    self:stop()

    if self.state.ended then
        return
    end

    self:showPauseUi()
end
function Clock:resume()
    self.state.paused = false
    self:resetWaitHandle()
    self:hidePauseUi()
end

function Clock:resetWaitHandle()
    self:stop()

    if self.state.paused then
        return
    end
    self:start()
end
function Clock:update()
    local playerColor = Turns.turn_color
    if not TableUtils.hasValue(self.playerColors, playerColor) then
        return
    end

    self.state[playerColor] = self.state[playerColor] - 1
    if self.state[playerColor] == 0 then
        self.state.ended = true
        self:stop()
        self:updateTimeRanOutUi(playerColor)
        self:showTimeRanOutUi()
    elseif self.state[playerColor] == self.warning then
        --TODO: This could be a bit more spicy, maybe add sound as well?
        broadcastToColor("You are almost out of time!", playerColor, "White")
    elseif self.state[playerColor] == self.criticalWarning then
        broadcastToColor("YOU ARE ALMOST OUT OF TIME!", playerColor, "Red")
    end
    local percent = (self.state[playerColor] * self.panelWidth) / self.state.initalTime
    if percent % 1 then
        self:updateScoreBar(playerColor, percent)
    end

    self:updateScoreUi(playerColor)
end
function Clock:updateScoreUi(playerColor)
    local idToUpdate = self._idTime[playerColor]
    local rendered = self:renderTime(self.state[playerColor])
    UI.setValue(idToUpdate, rendered)
end
function Clock:updateScoreBar(playerColor, percent)
    local idSpent = self._idPrefixSpentBar .. playerColor
    local idRemaining = self._idPrefixRemainingBar .. playerColor
    local pixels = math.min(self.panelWidth, percent)
    UI.setAttribute(idRemaining, "preferredWidth", pixels)
    UI.setAttribute(idSpent, "preferredWidth", self.panelWidth - pixels)
end

function Clock:getTimeUnits(time)
    local seconds = time
    local hours = math.floor(seconds / 3600)
    seconds = seconds - hours * 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds - minutes * 60
    return {hours = hours, minutes = minutes, seconds = seconds}
end
function Clock:renderTime(time)
    local units = Clock:getTimeUnits(time)
    return string.format([[%02d:%02d:%02d]], units.hours, units.minutes, units.seconds)
end

function Clock:onPlayerTurnStart(player)
    if self.state.paused or self.state.ended then
        return
    end
    local color = player.color
    if self.state[color] ~= nil then
        self.state[color] = self.state[color] + SETTINGS.clockIncrement * 60
    end
    self:resetWaitHandle()
end
function Clock:onPlayerTurnEnd(player)
    local playerColor = player.color
    local percent = (self.state[playerColor] * self.panelWidth) / self.state.initalTime
    self:updateScoreBar(playerColor, percent)
end

function onClick_resumeClock()
    Clock:resume()
end

function onClick_timeRanOutOK()
    Clock:hideTimeRanOutUi()
end

function onClick_clockPauseSymbol()
    if Clock.state.paused then
        Clock:resume()
    else
        Clock:pause()
    end
end

function onClick_setTime(player, color)
    local h = UI.getAttribute("ipt_setTime__" .. color .. "_H", "text") or 0
    local m = UI.getAttribute("ipt_setTime__" .. color .. "_M", "text") or 0
    local s = UI.getAttribute("ipt_setTime__" .. color .. "_S", "text") or 0
    local hours = tonumber(h)
    local minutes = tonumber(m)
    local seconds = tonumber(s)
    Clock.state[color] = hours * 3600 + minutes * 60 + seconds
    Clock:updateScoreUi(color)
end
function onClick_addTime(player, color)
    local h = UI.getAttribute("ipt_addTime__" .. color .. "_H", "text") or 0
    local m = UI.getAttribute("ipt_addTime__" .. color .. "_M", "text") or 0
    local s = UI.getAttribute("ipt_addTime__" .. color .. "_S", "text") or 0
    local hours = tonumber(h)
    local minutes = tonumber(m)
    local seconds = tonumber(s)
    Clock.state[color] = Clock.state[color] + hours * 3600 + minutes * 60 + seconds
    Clock:updateScoreUi(color)
end
function onClick_subTime(player, color)
    local h = UI.getAttribute("ipt_subTime__" .. color .. "_H", "text") or 0
    local m = UI.getAttribute("ipt_subTime__" .. color .. "_M", "text") or 0
    local s = UI.getAttribute("ipt_subTime__" .. color .. "_S", "text") or 0
    local hours = tonumber(h)
    local minutes = tonumber(m)
    local seconds = tonumber(s)
    Clock.state[color] = math.max(Clock.state[color] - hours * 3600 + minutes * 60 + seconds, 1)
    Clock:updateScoreUi(color)
end

-- What a disgusting hack
function onEndEdit_genericInput(player, val , id)
    UI.setAttribute(id, "text", val)
end

function onClick_addSetTime_close(player, color)
    UiUtil.hide("modal__addSetTime_" .. color, player.color)
end
function onClick_addSetTime_show(player, color)
    UiUtil.show("modal__addSetTime_" .. color, player.color)
end

return Clock