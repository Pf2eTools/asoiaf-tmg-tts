local EventUtils = require("lua.utils-events")
local Utils = require("lua.utils")

local onLoad = function()
    -- Check for the date?
    if Utils.isCleanLoad() then
        UI.setAttribute("modal__greetings", "active", true)
    end
end

--EventUtils.register("onload", onLoad)