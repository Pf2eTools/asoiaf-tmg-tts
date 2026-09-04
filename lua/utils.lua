local TableUtils = require("lua.utils-table")

local Utils = {}

function Utils.round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function Utils:firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function Utils.trim(str)
    return str:gsub("^%s*", ""):gsub("%s*$", "")
 end

function Utils.copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[Utils.copy(k)] = Utils.copy(v) end
    return res
end

-- SEPERATOR IS NOT REGEX ESCAPED
function Utils.split(s, sep)
    local tokens = {}

    local seperator = sep or " "
    local pattern = string.format("([^%s]+)", seperator)
    string.gsub(s, pattern, function(t) table.insert(tokens, t) end)

    return tokens
end

-- Throttle func to not run more than once each delay. delay in seconds
function Utils.throttle(func, delay)
    local lastInvokeTime = 0

    return function (...)
        local timeNow = Time.time
        if timeNow - lastInvokeTime < delay then
            return
        end
        lastInvokeTime = timeNow
        return func(...)
    end
end

-- Debounce func to run only once after repeated calls within delay. delay in seconds
function Utils.debounce(func, delay)
    local waitHandle = nil
    return function (...)
        if waitHandle ~= nil then
            Wait.stop(waitHandle)
        end
        local args = {...}
        waitHandle = Wait.time(function() func(unpack(args)) end, delay)
    end
end

function Utils.containerContainsObject(container, objToFind)
    if objToFind == nil or container == nil then
      return false
    end

    for _, obj in pairs(container.getObjects()) do
      if obj.getGUID() == objToFind.getGUID() then
        return true
      end
    end

    return false
end

function Utils.getObjectsWithTagsOnBoard(tags)
    return TableUtils.filter(getObjectsWithAnyTags(tags), function(obj)
        local pos = obj.getPosition()
        local w = Setup.width[SETTINGS.boardsize]
        local h = Setup.height[SETTINGS.boardsize]
        return math.abs(pos.x) <= w /2 and math.abs(pos.z) <= h /2
      end)
end

function Utils.isCleanLoad()
  for _, obj in pairs(getObjectFromGUID(GUIDS["place_gamemode_zone"]).getObjects()) do
    if obj.hasTag("GamemodeCard") and obj.getLock() then
      return false
    end
  end
  return true
end


return Utils