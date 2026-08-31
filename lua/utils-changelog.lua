local CHANGELOG = require("lua.changelog")
local TableUtils = require("lua.utils-table")
local UiUtil = require("lua.utils-ui")

local ChangelogUtils = {
    _idModal = "modal__changelog",
    _idWrapper = "modal__changelog_wrp",
    _isInitialized = false,
}

function ChangelogUtils.show(color)
    UiUtil.show(ChangelogUtils._idModal, color)
end
function ChangelogUtils.hide(color)
    UiUtil.hide(ChangelogUtils._idModal, color)
end

function ChangelogUtils.init()
    if ChangelogUtils._isInitialized then
        return
    end
    ChangelogUtils._isInitialized = true
    ChangelogUtils.render()
end

function ChangelogUtils.render()
    local renderedChangelog = {}
    for versionNumber, version in TableUtils.reversePairs(CHANGELOG) do
        table.insert(renderedChangelog, ChangelogUtils.getRenderedHeaderRow(versionNumber, version.subname, version.date))
        for _, change in ipairs(version.changes) do
            table.insert(renderedChangelog, ChangelogUtils.getRenderedChangeRow(change))
        end
    end
    table.insert(renderedChangelog, [[<HorizontalLayout flexibleHeight="1"></HorizontalLayout>]])
    local rendered = table.concat(renderedChangelog, "")
    UI.setValue(ChangelogUtils._idWrapper, rendered)
    Wait.frames(function()
        UiUtil.redraw()
    end, 5)
end
function ChangelogUtils.getRenderedHeaderRow(versionNumber, subname, releaseDate)
    local str = versionNumber
    if subname ~= nil then
        str = str .. string.format([[ <textcolor color="#BBBBBB">%s</textcolor>]], subname)
    end
    if releaseDate ~= nil then
        str = str .. string.format([[</Text><Text class="settingsText" preferredWidth="200" alignment="MiddleRight" color="#BBBBBB" fontStyle="Italic">Released %s]], releaseDate)
    end
    return string.format(
        [[<HorizontalLayout flexibleHeight="0"><Text class="settingsText" fontStyle="Bold">%s</Text></HorizontalLayout>
        <HorizontalLayout><Panel height="2" ignoreLayout="true" color="#CDCDCD"></Panel></HorizontalLayout>]],
        str)
end
function ChangelogUtils.getRenderedChangeRow(change)
    return string.format(
        [[<HorizontalLayout flexibleHeight="0"><Text preferredWidth="40" color="#CDCDCD" fontSize="18" fontStyle="Bold">-</Text>
        <Text preferredWidth="1006" class="settingsText">%s</Text></HorizontalLayout>]],
        change)
end


function onClick_closeChangelog(player)
    ChangelogUtils.hide(player.color)
end

return ChangelogUtils