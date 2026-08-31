local TableUtils = require("lua.utils-table")
local EventUtils = require("lua.utils-events")

function invoke(params)
    local object = gameObjects[params.guid]
    if params.func == "onLoad" and object == nil then
        local gameObj = getObjectFromGUID(params.guid)
        object = _G[params.class](gameObj)
    elseif object == nil then
        log("Tried invoking "..params.func.." on "..params.guid..", but the object did not exist.")
        return
    end

    local func = object[params.func]
    if func ~= nil then
        func(object, params.params)
    end
end

gameObjects = {}
GameObjectClass = {}
GameObjectClass.__index = GameObjectClass
GameObjectClass.__className = "GameObjectClass"
setmetatable(GameObjectClass, {
    -- constructor
    __call = function (cls, gameObj, className)
        local this = setmetatable({}, GameObjectClass)
        this.gameObj = gameObj
        this._guid = gameObj.getGUID()
        this._listeners = {}
        this._preventActionsDefaultBehavior = {}

        local script_identifier = string.format([[local _identifier = "%s"]], this._guid)
        local script_call_func = string.format([[function call(func, params) Global.call("invoke", {class = "%s", guid = self.getGUID(), func = func, params = params}) end]], className)
        local script = script_identifier .. "\n" .. script_call_func
        gameObj.setLuaScript(script)
        gameObjects[this._guid] = this

        return this
    end
})

function GameObjectClass:init()
end

function GameObjectClass:register(listeners)
    local luaScript = self.gameObj.getLuaScript()
    for ix, listener in ipairs(listeners) do
        if not TableUtils.hasValue(self._listeners, listener) then
            table.insert(self._listeners, listener)
            local funcText = string.format("function %s(...) call('%s', {...}) end", listener, listener)
            if listener == "onPlayerAction" then
                local preventActs = table.concat(self._preventActionsDefaultBehavior, ", ")
                funcText = string.format([[function onPlayerAction(...) call('onPlayerAction', {...}) local p,a,t=unpack({...}) for _,v in pairs({%s}) do if v==a then return false end end return true end]], preventActs)
            end
            luaScript = luaScript .. "\n" .. funcText
        end
    end
    self.gameObj.setLuaScript(luaScript)
end

function GameObjectClass:redrawUi()
    if self.gameObj and self.gameObj.UI then
        self.gameObj.UI.setXml(self.gameObj.UI.getXml())
    end
end

-- to be overridden
function GameObjectClass:getSaveState()
    return nil
end
function GameObjectClass:restoreSaveState(state)
    -- no op
end

local onDestroy = function(params)
    local object = unpack(params)
    local guid = object.guid
    local gameObj = gameObjects[guid]

    if gameObj == nil then
        return
    end

    if gameObj.onDestroy then
        gameObj:onDestroy()
    end
end
EventUtils.register("onObjectDestroy", onDestroy)

local onObjectEnterContainer = function(params)
    local container, object = unpack(params)
    local guid = object.guid
    local instance = gameObjects[guid]

    if instance == nil then
        return
    end

    if instance.onEnterContainer then
        instance:onEnterContainer()
    end
end
EventUtils.register("onObjectEnterContainer", onObjectEnterContainer)

local onObjectLeaveContainer = function(params)
    local container, object = unpack(params)
    local guid = object.guid
    local instance = gameObjects[guid]

    if instance == nil then
        return
    end

    instance.gameObj = object
    -- Objects count as resting for the first few frames after being pulled from the bag
    Wait.frames(function ()
        Wait.condition(function() instance:init() end, function() return object.resting end)
    end, 3)
end
EventUtils.register("onObjectLeaveContainer", onObjectLeaveContainer)

local onPlayerAction_Paste = function(params)
    local player, action, targets = unpack(params)
    if action ~= Player.Action.Paste then
        return
    end

    for _, target in pairs(targets) do
        -- log(target.getVar("_identifier"))
        -- Hack! target.getVar("_identifier") doesnt work for some reason
        local matchedGuid = string.match(target.getLuaScript(), [[local _identifier = "(%w%w%w%w%w%w)"]])
        local copyFrom = gameObjects[matchedGuid]
        if copyFrom then
            Wait.condition(function()
                local stateToCopy = copyFrom:getSaveState({isCreatingCopy = true})
                local copiedObj = _G[copyFrom.__className](target)
                copiedObj:restoreSaveState(stateToCopy)
            end, function()
                return target.resting
            end)
        end
    end
end
EventUtils.register("onPlayerAction", onPlayerAction_Paste)

local onUpdate = function()
    for _, obj in pairs(gameObjects) do
        if obj.onUpdate then
            obj:onUpdate()
        end
    end
end
EventUtils.register("onUpdate", onUpdate)
