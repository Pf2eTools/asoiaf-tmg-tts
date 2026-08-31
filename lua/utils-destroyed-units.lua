destroyedUnits = {Blue = 0, Red = 0}

local UtilsDeadUnits = {}
function UtilsDeadUnits.executeOnContainerEnter(obj, color, cost)
    local objGuid = obj.guid
    local gameObj = gameObjects[objGuid]
    local totalCost = 0

    if gameObj ~= nil then
        totalCost = gameObj:getTotalCost()
    else
        totalCost = obj.getVar("cost") or 0
    end

    destroyedUnits[color] = destroyedUnits[color] + totalCost
    Wait.frames(function()
        UtilsDeadUnits.updateXml()
    end, 1)
end

function UtilsDeadUnits.updateXml()
    for color, val in pairs(destroyedUnits) do
        Global.UI.setAttribute(string.lower(color) .. "PlayerUD", "Text", val .. " UD")
    end
end

return UtilsDeadUnits
