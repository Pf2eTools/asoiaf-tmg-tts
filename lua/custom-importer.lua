local EventUtils = require("lua.utils-events")
local TableUtils = require("lua.utils-table")
local Utils = require("lua.utils")

local CUSTOM_INDEX_URL = "https://raw.githubusercontent.com/Pf2eTools/mcl-documents/refs/heads/master/lua/index.lua"

local _temp = {}
function CUSTOM_SET_VAR(params)
    for k, v in pairs(params) do
        _temp[k] = nil
        _temp[k] = v
    end
end
function runWithLuaFromWeb(url, isReplaceReturn, vars, callback)
    WebRequest.get(url, function(request)
        local dummyObj = spawnObject({
            type = "BlockSquare",
        })
        local luaString = request.text
        if isReplaceReturn then
            luaString = luaString:gsub("return", "local " .. vars[1] .. " =")
        end
        local varString = table.concat(TableUtils.map(vars, function(v)
            return string.format("%s = %s", v, v)
        end), ", ")
        local funcString = "\nfunction func() Global.call('CUSTOM_SET_VAR', {" .. varString .. "}) end"

        dummyObj.setLuaScript(luaString .. funcString)
        Wait.frames(function()
            dummyObj.call("func")
            dummyObj.destruct()
            local params = TableUtils.map(vars, function(v)
                return _temp[v]
            end)
            callback(params)
        end, 5)
    end)
end

local function spawnCustomDecks(decks)
    local pos = Vector({ 0, 2, 0 })
    local grid = Grid({
        origin = Vector({20, 2, 20}),
        columns = 8,
        rows = 8,
        rowOffset = Vector({0, 0, -5}),
        columnOffset = Vector({-5, 0, 0})
    })
    for ix, deck in pairs(decks) do
        Spawner:spawnDeckOfCards({
            cards = deck,
            position = grid:getNextPos(),
        })
    end
end

local CustomSpawner = {}
local function initUI(params)
    local index, commitHash = unpack(params)
    CustomSpawner.index = index
    CustomSpawner.commitHash = commitHash
    CustomSpawner.dropdownValue = TableUtils.len(index)
    CustomSpawner.customURL = ""

    local spawnerTile = getObjectFromGUID(GUIDS["CUSTOM_SPAWNER"])

    local onDropdownValueChanged = "onDropdownValueChanged_customSpawner"
    _G[onDropdownValueChanged] = function(p)
        local _, val = unpack(p)
        CustomSpawner.dropdownValue = tonumber(val) + 1
    end

    local spawnDropDownName = "onClickSpawn_customSpawner__dropdown"
    _G[spawnDropDownName] = Utils.throttle(function()
        local infoToSpawn = CustomSpawner.index[CustomSpawner.dropdownValue]
        local repoURL = string.format("https://raw.githubusercontent.com/Pf2eTools/mcl-documents/%s/lua/%s", CustomSpawner.commitHash, infoToSpawn.path)
        runWithLuaFromWeb(repoURL, true, {"decks"}, function(d) spawnCustomDecks(unpack(d)) end)
    end, 1)

    local onInputValueChanged = "onInputValueChanged_customSpawner"
    _G[onInputValueChanged] = function(p)
        local _, val = unpack(p)
        CustomSpawner.customURL = val
    end

    local spawnInputName = "onClickSpawn_customSpawner__input"
    _G[spawnInputName] = Utils.throttle(function()
        runWithLuaFromWeb(CustomSpawner.customURL, true, {"decks"}, function(d) spawnCustomDecks(unpack(d)) end)
    end, 1)

    local luaString = string.format([[function %s(...) Global.call('%s', {...}) end]], spawnDropDownName, spawnDropDownName)
            .. "\n"
            .. string.format([[function %s(...) Global.call('%s', {...}) end]], spawnInputName, spawnInputName)
            .. "\n"
            .. string.format([[function %s(...) Global.call('%s', {...}) end]], onDropdownValueChanged, onDropdownValueChanged)
            .. "\n"
            .. string.format([[function %s(...) Global.call('%s', {...}) end]], onInputValueChanged, onInputValueChanged)
    spawnerTile.setLuaScript(luaString)

    local options = TableUtils.map(index, function(v, k)
        return {
            tag = "Option",
            attributes = {
                selected = k == TableUtils.len(index),
            },
            value = v.name,
        }
    end)
    local layout = {
        {
            tag = "VerticalLayout",
            attributes = {
                position = "0 12 -22",
                rotation = "0 0 180",
                width = 350,
                padding = "0 0 5 5",
                spacing = 5,
                height = 170,
                childForceExpandWidth = false,
                childForceExpandHeight = false,
            },
            children = {
                {
                    tag = "HorizontalLayout",
                    attributes = {
                        height = 50,
                        childForceExpandWidth = true,
                        childForceExpandHeight = false,
                    },
                    children = {
                        {
                            tag = "Text",
                            attributes = {
                                width = 40,
                                text = "Select content from our repository",
                                alignment = "MiddleLeft",
                                color = "white",
                                fontSize = 12,
                            }
                        }
                    }
                },
                {
                    tag = "HorizontalLayout",
                    attributes = {
                        childForceExpandWidth = true,
                        childForceExpandHeight = false,
                    },
                    children = {
                        {
                            tag = "Dropdown",
                            attributes = {
                                id = "dropdown",
                                onValueChanged = onDropdownValueChanged .. "(selectedIndex)",
                                height = 30,
                                minHeight = 30,
                                width = 250,
                                minWidth = 250,
                                fontSize = 12,
                            },
                            children = options,
                        },
                        {
                            tag = "Button",
                            attributes = {
                                minHeight = 30,
                                height = 30,
                                onclick = spawnDropDownName,
                                text = "Spawn!",
                            }
                        }
                    }
                },

                {
                    tag = "HorizontalLayout",
                    attributes = {
                        height = 50,
                        childForceExpandWidth = true,
                        childForceExpandHeight = false,
                    },
                    children = {
                        {
                            tag = "Text",
                            attributes = {
                                width = 40,
                                text = "Enter a custom url:",
                                alignment = "MiddleLeft",
                                color = "white",
                                fontSize = 12,
                            }
                        }
                    }
                },
                {
                    tag = "HorizontalLayout",
                    attributes = {
                        childForceExpandWidth = true,
                        childForceExpandHeight = false,
                    },
                    children = {
                        {
                            tag = "InputField",
                            attributes = {
                                id = "input",
                                onValueChanged = onInputValueChanged,
                                height = 30,
                                minHeight = 30,
                                width = 250,
                                minWidth = 250,
                                fontSize = 12,
                            },
                        },
                        {
                            tag = "Button",
                            attributes = {
                                minHeight = 30,
                                height = 30,
                                onclick = spawnInputName,
                                text = "Spawn!",
                            }
                        }
                    }
                }
            }
        }
    }
    spawnerTile.UI.setXmlTable(layout)
end

local function onLoad()
    -- lord have mercy, im bouta bust the cache
    local requestUrl = CUSTOM_INDEX_URL .. "?" .. tostring(os.time() * 100000)
    runWithLuaFromWeb(requestUrl, false, { "index", "commitHash" }, initUI)
end

EventUtils.register("onload", onLoad)