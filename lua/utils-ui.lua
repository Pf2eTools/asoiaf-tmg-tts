local TableUtils = require("lua.utils-table")
local Utils = require("lua.utils")

local UiUtil = {}

function UiUtil.updatePlayerName(color)
  local name = UiUtil.getPlayerName(color)
  if name == color then
    name = name .. " Player"
  end
  UI.setValue(string.lower(color).."Player", UiUtil.getSafeName(name))
end

function UiUtil.toggleVisibilityStr(visibility, color)
    local split = Utils.split(visibility, "|")
    if TableUtils.hasValue(split, color) then
        local filtered = TableUtils.filter(split,
          function(e)
            return e ~= color
          end)
        return table.concat(filtered, "|")
    else
        table.insert(split, color)
        return table.concat(split, "|")
    end
end

function UiUtil.toggleVisibility(id, color)
    local visibilityString = self.UI.getAttribute(id, "visibility")
    self.UI.setAttribute(id, "visibility", UiUtil.toggleVisibilityStr(visibilityString, color))
end

function UiUtil.hide(id, color)
  if color == nil then
    self.UI.setAttribute(id, "visibility", "Hidden")
    return
  end

  local visibilityString = self.UI.getAttribute(id, "visibility")
  local split = Utils.split(visibilityString, "|")
  local filtered = TableUtils.filter(split, function(e) return e ~= color end)
  self.UI.setAttribute(id, "visibility", table.concat(filtered, "|"))
end

function UiUtil.show(id, color)
  if color == nil then
    self.UI.setAttribute(id, "visibility", "")
    return
  end

  local visibilityString = self.UI.getAttribute(id, "visibility")
  local split = Utils.split(visibilityString, "|")
  if not TableUtils.hasValue(split, color) then table.insert(split, color) end
  self.UI.setAttribute(id, "visibility", table.concat(split, "|"))
end

function UiUtil.getElementById(xmlTable, eleId)
  local found = nil
  for ix, ele in ipairs(xmlTable) do
    if ele.attributes ~= nil and ele.attributes.id == eleId then
      found = ele
      break
    end
    if ele.children then
      found = UiUtil.getElementById(ele.children, eleId)
    end
    if found ~= nil then
      break
    end
  end
  return found
end

function UiUtil.getSafeName(name)
  return name:gsub("\"", "'"):gsub("<", ""):gsub(">", "")
end

function UiUtil.getPlayerName(color)
  local out = color
  local player = Player[color]
  if player.steam_name ~= nil and player.steam_name ~= "" then
      out = player.steam_name
  end
  return UiUtil.getSafeName(out)
end

function UiUtil.redraw()
  log("Redrawing UI...")
  UI.setXml(UI.getXml())
end

return UiUtil