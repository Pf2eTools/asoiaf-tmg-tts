local TableUtils = require("lua.utils-table")

local EventUtils = {
    listeners = {}
}

-- guid of the object for listeners attached to an object, nil for global
function EventUtils.register(event, listener, guid)
    if EventUtils.listeners[event] == nil then
        EventUtils.listeners[event] = {}
    end
    table.insert(EventUtils.listeners[event], {listener = listener, guid = guid})

    -- what if the event already exists due to bad code?
    -- we should transition legacy code to use this system
    if _G[event] == nil then
        _G[event] = function(...)
            for ix, obj in ipairs(EventUtils.getListeners(event)) do
                obj.listener({...})
            end
        end
    end
end

-- TODO: Use this when deleting objects
function EventUtils.unregister(event, listener)
    local listeners = EventUtils.listeners[event]
    local idx = TableUtils.findIndex(listeners, function(v) return v.listener == listener end)
    if idx ~= nil then
        table.remove(listeners, idx)
    else
        log("Tried to unregister event listener for event '" .. event .. "', but the listener was not found.")
    end
end
function EventUtils.unregisterByGuid(event, guid)
    local listeners = EventUtils.listeners[event]
    local idx = TableUtils.findIndex(listeners, function(v) return v.guid == guid end)
    if idx ~= nil then
        table.remove(listeners, idx)
    else
        log("Tried to unregister event listeners for event '" .. event .. "' on object '" .. guid .."', but no listeners were not found.")
    end
end


function EventUtils.getListeners(event)
    return EventUtils.listeners[event]
end

return EventUtils