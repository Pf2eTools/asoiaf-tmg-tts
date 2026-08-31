local Setup = require("lua.setup")
local EventUtils = require("lua.utils-events")
local TableUtils = require("lua.utils-table")
local Utils = require("lua.utils")

local GameModeUtil = {
    waitHandle = nil,
    currentGameMode = "No Gamemode"
}

local objectiveLuaScript = [[
function onCollisionEnter(a)
  local collObj = a.collision_object
  if collObj.hasTag("ObjectiveCard") then
    self.setName(collObj.getName())
    self.setDescription(collObj.getDescription())
  end
end
]]

EventUtils.register("onPlayerAction", function(params)
    local player, action, targets = unpack(params)
    if action ~= Player.Action.FlipOver then
        return
    end
    for _, obj in ipairs(targets) do
        if obj.hasTag("Objective") then
            local objColor = obj.getColorTint()
            local playerColor = player.color
            local otherPlayerColor = playerColor == "Red" and "Blue" or "Red"
            if objColor == Color.White then
                obj.setColorTint(playerColor)
            elseif objColor == Color[playerColor] then
                obj.setColorTint(otherPlayerColor)
            elseif objColor == Color[otherPlayerColor] then
                obj.setColorTint("White")
            end
        end
    end
end)

local WOW = {
    zones = {
        Red = nil,
        Blue = nil,
    },
}
local DWDW = {
    zones = {
        Active1 = nil,
        Active2 = nil,
        Reserve1 = nil,
        Reserve2 = nil,
    },
}

local zoneBaseUrl = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/5f2ee1eeae2f1a6220ca990d3c2f899aa4620aa8/custom/generated/brew-zones/"
local shortToZoneName = {
    c = "Crown",
    w = "Wealth",
    t = "Tactics",
    s = "Combat",
    h = "Maneuver",
}
local customZoneDecks = TableUtils.values(TableUtils.map(shortToZoneName, function(zoneName, zoneKey)
    local idx = TableUtils.getIdx(TableUtils.keys(shortToZoneName), zoneKey)
    return {
        type = "custom",
        cards = TableUtils.map({ 0, 1, 2, 3 }, function(ix)
            return {
                face = zoneBaseUrl .. zoneKey .. ix .. ".jpg",
                back = zoneBaseUrl .. zoneKey .. ix .. "b.jpg",
                name = zoneName,
                scale = { x = 4, y = 1, z = 4 }
            }
        end),
        position = { 8 * (idx - 3), 5, 0 },
        rotation = { 0, 180, 0 },
    }
end))

GameModeUtil.gameModeLookUp = {
    ["A Feast For Crows"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = -2.1,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    takeCards = "now",
                    position = { -17.3, 2.05, 0 },
                },
                {
                    takeCards = "now",
                    position = { 17.3, 2.05, 0 },
                },
                {
                    zOffset = -4.25,
                },
                {
                    zOffset = -4.25,
                }
            }
        },
        terrain = {
            {
                takeFrom = "CorpsePile",
                position = { -17.3, 1.95, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "CorpsePile",
                position = { 17.3, 1.95, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "CorpsePile",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "CorpsePile",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
        },
    },
    ["Winds Of Winter"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "mission",
                zOffset = 2.5,
                rotation = { 0, 90, 180 },
            },
            {
                type = "mission",
                zOffset = -2.5,
                rotation = { 0, 90, 180 },
            }
        },
        objectives = {
            type = "5",
            snap = true,
        },
        customAssets = {
            {
                image = "http://cloud-3.steamusercontent.com/ugc/2072258090093445189/CC4B317AF33299E75E9847A6EE6CC2F66A7C878E/",
                position = { 27.7, 0.76, 0 },
                scale = { 3.71, 1, 3.71 },
                rotation = { 0, 270, 0 },
                thickness = 0.2,
                lock = true,
                snapPoints = {
                    {
                        Position = { x = 0.29, y = 0.2, z = -0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = -0.29, y = 0.2, z = -0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = 0.29, y = 0.2, z = 0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = -0.29, y = 0.2, z = 0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    }
                }
            }
        },
        callback = function()
            UI.setAttribute("DWDW_Panel", "active", false)
            UI.setAttribute("WOW_Panel", "active", true)
            WOW.createZones()
        end
    },
    ["Here We Stand"] = {
        horizontalLines = { 18, -18, 0 },
        verticalLines = { 0 },
    },
    ["Honed & Ready"] = {
        horizontalLines = { 10, -10 },
        terrain = {
            {
                takeFrom = "CastleWall",
                position = { -23.125, 1.95, 0 },
                rotation = { 0, 90, 0 },
            },
            {
                takeFrom = "CastleWall",
                position = { 23.125, 1.95, 0 },
                rotation = { 0, 90, 0 },
            },
        },
        objectives = {
            type = "5",
            snap = true,
        }
    },
    ["Fire & Blood"] = {
        horizontalLines = { 18, -18 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 0 },
                filter = { 1, 2, 3, 4, 5 },
            }
        }
    },
    ["Dark Wings, Dark Words"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "mission",
                filter = { 10, 11, 12 },
                position = { 27.7, 1.1, 3.82 },
                rotation = { 0, 270, 180 },
                randomize = true,
            }
        },
        objectives = {
            type = "3",
            snap = true,
        },
        customAssets = {
            { image = "http://cloud-3.steamusercontent.com/ugc/2058742120734771885/BE599EBFF7EA7183BAD4D1E807798B616F414863/",
              position = { 27.7, 0.76, 0 },
              scale = { 3.71, 1, 3.71 },
              rotation = { 0, 270, 0 },
              thickness = 0.2,
              lock = true,
              snapPoints = {
                  {
                      Position = { x = 1.03, y = 0.2, z = 0 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  },
                  {
                      Position = { x = 0.29, y = 0.2, z = -0.43 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  },
                  {
                      Position = { x = -0.29, y = 0.2, z = -0.43 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  },
                  {
                      Position = { x = 0.29, y = 0.2, z = 0.43 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  },
                  {
                      Position = { x = -0.29, y = 0.2, z = 0.43 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  },
                  {
                      Position = { x = -1.03, y = 0.2, z = 0 },
                      Rotation = { x = 0, y = 0, z = 0 }
                  }
              }
            }
        },
        callback = function()
            UI.setAttribute("WOW_Panel", "active", false)
            UI.setAttribute("DWDW_Panel", "active", true)
            DWDW.createZones()
        end
    },
    ["A Game Of Thrones"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            takeCards = "later",
            snap = true,
            type = "5"
        },
    },
    ["A Clash Of Kings"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 0 },
                filter = { 1, 2, 3, 4, 5 },
            }
        },
        objectives = {
            type = "3",
            snap = true,
        }
    },
    ["A Dance With Dragons"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            takeCards = "later",
            snap = true,
            type = "3"
        },
    },
    ["Banners & Butchery"] = {
        -- This line is drawn twice, but the tray deploy feature requires this
        horizontalLines = { 24, -24 },
        objectives = {
            custom = {
                {
                    position = { -11.3, 2.05, 11.3 },
                },
                {
                    position = { 11.3, 2.05, 11.3 },
                },
                {
                    position = { 11.3, 2.05, -11.3 },
                },
                {
                    position = { -11.3, 2.05, -11.3 },
                },
            }
        },
    },

    -- Custom Gamemodes
    ["Spoils of War"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = 2.5,
                rotation = { 0, 90, 180 },
                randomize = false,
            },
            {
                type = "objective",
                zOffset = -2.5,
                rotation = { 0, 90, 180 },
                randomize = false,
            }
        },
        objectives = {
            snap = true,
            type = "3"
        },
    },
    ["The Spider and the Mockingbird"] = {
        horizontalLines = { 10, -10 },
        decks = customZoneDecks,
        objectives = {
            snap = true,
            type = "5"
        },
    },
    ["Intrigue and Subterfuge"] = {
        horizontalLines = { 10, -10 },
        customAssets = {
            {
                image = "http://cloud-3.steamusercontent.com/ugc/1747932530847508809/ED6B43F0C498BE1DD2462A4D517D0B1691E3BD65/",
                type = "Custom_Token",
                position = Vector(Setup.objectivePositions["4x4"]["5"][4]) + Vector(2, 0, 0),
                rotation = { 0, 180, 0 },
                scale = { 0.5, 0.5, 0.5 },
                tags = { "Objective" }
            },
            {
                image = "http://cloud-3.steamusercontent.com/ugc/1747932530847509087/641B0A85D1CE62E3E37520496CA9086FF73E9C32/",
                type = "Custom_Token",
                position = Vector(Setup.objectivePositions["4x4"]["5"][2]) + Vector(2, 0, 0),
                rotation = { 0, 180, 0 },
                scale = { 0.5, 0.5, 0.5 },
                tags = { "Objective" }
            },
            {
                image = "http://cloud-3.steamusercontent.com/ugc/1747932530847508995/E57D5CCAD5D70BC9A0C85897292B074087AA450C/",
                type = "Custom_Token",
                position = Vector(Setup.objectivePositions["4x4"]["5"][3]) + Vector(2, 0, 0),
                rotation = { 0, 180, 0 },
                scale = { 0.5, 0.5, 0.5 },
                tags = { "Objective" }
            },
            {
                image = "http://cloud-3.steamusercontent.com/ugc/1747932530847509176/D9A2FED034575BBC0A03048C28B1769C6E0E04EC/",
                type = "Custom_Token",
                position = Vector(Setup.objectivePositions["4x4"]["5"][1]) + Vector(2, 0, 0),
                rotation = { 0, 180, 0 },
                scale = { 0.5, 0.5, 0.5 },
                tags = { "Objective" }
            },
            {
                image = "http://cloud-3.steamusercontent.com/ugc/1747932530847508902/985180B6DFC8E507EFFA1F15549FC2E6F5C3FAD5/",
                type = "Custom_Token",
                position = Vector(Setup.objectivePositions["4x4"]["5"][5]) + Vector(2, 0, 0),
                rotation = { 0, 180, 0 },
                scale = { 0.5, 0.5, 0.5 },
                tags = { "Objective" }
            },
        },
        objectives = {
            snap = true,
            type = "5"
        },
    },
    ["Heart of the Realm"] = {
        horizontalLines = { 10, -10 },
        objectives = {
            custom = {
                {
                    position = { -17.3, 2.05, 0 },
                },
                {
                    position = { 0, 2.05, 0 },
                },
                {
                    position = { 17.3, 2.05, 0 },
                },
                {
                    position = { 0, 2.05, -13.3 },
                },
                {
                    position = { 0, 2.05, 13.3 },
                },
                -- Used for ownership indication
                {
                    name = "Flip to indicate Ownership",
                    position = { -15.3, 2.05, 0 },
                    scale = { 0.2, 0.2, 0.2 },
                    tags = { "SkipReady" }
                },
                {
                    name = "Flip to indicate Ownership",
                    position = { 15.3, 2.05, 0 },
                    scale = { 0.2, 0.2, 0.2 },
                    tags = { "SkipReady" }
                },
                {
                    name = "Flip to indicate Ownership",
                    position = { 0, 2.05, -11.3 },
                    scale = { 0.2, 0.2, 0.2 },
                    tags = { "SkipReady" }
                },
                {
                    name = "Flip to indicate Ownership",
                    position = { 0, 2.05, 11.3 },
                    scale = { 0.2, 0.2, 0.2 },
                    tags = { "SkipReady" }
                },
            }
        },
    },

    ["Banner's Peace"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                filter = { 1, 5 },
                zOffset = 0,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    takeCards = "now",
                    position = { 0, 2.05, 0 },
                },
                {
                    takeCards = "now",
                    position = { -17.3, 2.05, 5.5 },
                },
                {
                    takeCards = "now",
                    position = { 17.3, 2.05, -5.5 },
                },
            }
        },
        terrain = {
            {
                takeFrom = "Weirwood",
                position = { 15.25, 1.95, 6 },
            },
            {
                takeFrom = "Weirwood",
                position = { -15.25, 1.95, -6 }
            },
        },
    },
    ["Blood and Honor"] = {
        horizontalLines = { 10, -10 },
        objectives = {
            custom = {
                {
                    position = { 0, 2.05, 0 },
                },
                {
                    position = { -17.3, 2.05, 5.5 },
                },
                {
                    position = { 17.3, 2.05, -5.5 },
                },
            }
        }
    },
    ["Fortuitous Battle"] = {
        horizontalLines = { 18, -18 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    takeCards = "now",
                    position = { 0, 2.05, 0 },
                },
                {
                    zOffset = -4.25,
                },
                {
                    zOffset = -4.25,
                }
            }
        },
        terrain = {
            {
                takeFrom = "CorpsePile",
                position = { 0, 1.95, 0, },
            },
        },
    },
    ["Heart of Battle"] = {
        horizontalLines = { 18, -18 },
        decks = {
            {
                type = "objective",
                filter = { 1, 2, 3, 4, 5 },
                zOffset = 0,
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    position = { 0, 2.05, 0 },
                },
            }
        },
    },
    ["Storm's Wrath"] = {
        horizontalLines = { 18, -18, 0 },
        verticalLines = { 0 },
        objectives = {
            custom = {
                {
                    position = { -12, 2.05, -12 },
                },
                {
                    position = { 12, 2.05, -12 },
                },
                {
                    position = { -12, 2.05, 12 },
                },
                {
                    position = { 12, 2.05, 12 },
                },
            }
        },
    },
    ["Politics is Nothing, Only Weapons Count"] = {
        horizontalLines = { 18, -18 },
    },
    ["The Last Hearth"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = -2.2,
                filter = { 1 },
                rotation = { 0, 90, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    position = { 0, 2.05, 0 },
                },
                {
                    zOffset = -4.6,
                },
                {
                    zOffset = -4.6,
                },
                {
                    zOffset = -4.6,
                },
                {
                    zOffset = -4.6,
                }
            }
        },
        terrain = {
            {
                takeFrom = "Weirwood",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "Weirwood",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "Weirwood",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
            {
                takeFrom = "Weirwood",
                zOffset = 2,
                rotation = { 0, 90, 0 },
                snapPoints = {
                    { position = { 0, 0.1, 0 }, tags = { "Objective" } }
                },
            },
        },
    },
    ["Vox Populi"] = {
        horizontalLines = { 10, -10 },
        objectives = {
            custom = {
                {
                    position = { -17.3, 2.05, 5.5 },
                },
                {
                    position = { 17.3, 2.05, -5.5 },
                },
                {
                    position = { -17.3, 2.05, -5.5 },
                },
                {
                    position = { 17.3, 2.05, 5.5 },
                }
            }
        },
    },
    ["Triumph Without Glory"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "objective",
                zOffset = 0,
                rotation = { 0, 90, 0 },
                filter = { 1, 5 },
            }
        },
        objectives = {
            custom = {
                {
                    takeCards = "now",
                    position = { -13.3, 2.05, 5.5 },
                },
                {
                    takeCards = "now",
                    position = { 13.3, 2.05, -5.5 },
                },
                {
                    takeCards = "now",
                    position = { -13.3, 2.05, -5.5 },
                },
                {
                    takeCards = "now",
                    position = { 13.3, 2.05, 5.5 },
                }
            }
        },
    },
    ["May the Light Shine Our Choices"] = {
        horizontalLines = { 10, -10 },
        decks = {
            {
                type = "mission",
                filter = { 10, 11, 12 },
                position = { 27.7, 1.1, 4.8 },
                rotation = { 0, 270, 180 },
                randomize = true,
            }
        },
        objectives = {
            custom = {
                {
                    position = { 0, 2.05, 0 },
                },
                {
                    position = { -17.3, 2.05, 5.5 },
                },
                {
                    position = { 17.3, 2.05, -5.5 },
                },
            }
        },
        customAssets = {
            {
                image = "http://cloud-3.steamusercontent.com/ugc/2072258090093445189/CC4B317AF33299E75E9847A6EE6CC2F66A7C878E/",
                position = { 27.7, 0.76, 0 },
                scale = { 3.71, 1, 3.71 },
                rotation = { 0, 270, 0 },
                thickness = 0.2,
                lock = true,
                snapPoints = {
                    {
                        Position = { x = 0.29, y = 0.2, z = -0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = -0.29, y = 0.2, z = -0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = 0.29, y = 0.2, z = 0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    },
                    {
                        Position = { x = -0.29, y = 0.2, z = 0.43 },
                        Rotation = { x = 0, y = 0, z = 0 }
                    }
                }
            }
        },
        callback = function()
            UI.setAttribute("DWDW_Panel", "active", false)
            UI.setAttribute("WOW_Panel", "active", true)
            WOW.createZones()
        end
    },
}
local spawnedGameModeObjects = {}

EventUtils.register("onObjectSpawn", function(params)
    local obj = unpack(params)
    if obj.hasTag("Objective") then
        obj.setLuaScript(objectiveLuaScript)
    end
end)

local onObjectEnterZone = function(params)
    local zone, obj = unpack(params)

    if not obj.hasTag("GamemodeCard") or zone.guid ~= GUIDS["place_gamemode_zone"] then
        return
    end
    if not GameModeUtil.waitHandle == nil then
        return
    end
    if obj.getLock() then
        return
    end

    GameModeUtil.waitHandle = Wait.condition(function()
        GameModeUtil.spawnGameMode(obj)
    end, function()
        return obj.resting
    end)
end
EventUtils.register("onObjectEnterZone", onObjectEnterZone)

local onObjectLeaveZone = function(params)
    local zone, obj = unpack(params)

    if not obj.hasTag("GamemodeCard") or zone.guid ~= GUIDS["place_gamemode_zone"] then
        return
    end

    Wait.time(function()
        GameModeUtil:cleanUp(obj)
    end, 0.1)
end
EventUtils.register("onObjectLeaveZone", onObjectLeaveZone)

function GameModeUtil.getCard(guid)
    for _, obj in pairs(getObjectFromGUID(GUIDS["place_gamemode_zone"]).getObjects()) do
        if obj.hasTag("GamemodeCard") and (guid == nil or guid == obj.guid) then
            return obj
        end
    end

    return nil
end

function GameModeUtil.spawnGameMode(card)
    if GameModeUtil.waitHandle == nil or not string.find(card.getDescription(), "Game Mode") then
        return
    end

    Wait.stop(GameModeUtil.waitHandle)
    Wait.time(function()
        GameModeUtil.waitHandle = nil
    end, 0.5)

    if GameModeUtil.getCard(card.guid) == nil then
        return
    end

    local gameModeId = string.sub(card.getDescription(), 11)
    local gameMode = GameModeUtil.gameModeLookUp[gameModeId]
    GameModeUtil.currentGameMode = gameModeId
    SettingsUtil.updateGamemodeDisplay()

    if gameMode == nil then
        print("Game Mode: " .. gameModeId .. " not found.")
        return
    end

    card.setPosition({ Setup.gamemodeZone_X[SETTINGS.boardsize] - 0.9, 0.76, 0 })
    card.setScale({ 6.2, 1, 6.2 })
    card.setRotation({ 0, 90, 0 })

    local vectorLines = {}
    if gameMode.horizontalLines then
        for _, y in pairs(gameMode.horizontalLines) do
            local w = Setup.width[SETTINGS.boardsize]
            local h = Setup.height[SETTINGS.boardsize]
            local z = 0
            if y > 0 then
                z = -h / 2 + y
            elseif y == 0 then
                z = 0
            else
                z = h / 2 + y
            end
            local line = { points = { { -w / 2, 1.9, z }, { w / 2, 1.9, z } }, color = SETTINGS.rulerColorTint }
            table.insert(vectorLines, line)
        end
    end
    if gameMode.verticalLines then
        for _, x in pairs(gameMode.verticalLines) do
            local h = Setup.height[SETTINGS.boardsize]
            local line = { points = { { x, 1.9, h / 2 }, { x, 1.9, -h / 2 } }, color = SETTINGS.rulerColorTint }
            table.insert(vectorLines, line)
        end
    end
    Global.setVectorLines(vectorLines)

    local spawnedObjects = {}

    if gameMode.terrain then
        for ix, terrainInfo in ipairs(gameMode.terrain) do
            local pos = terrainInfo.position or Vector({ Setup.gamemodeZone_X[SETTINGS.boardsize] + 11, 0.9 + ix / 10, terrainInfo.zOffset })
            local bag = getObjectFromGUID(GUIDS["terrain"][terrainInfo.takeFrom])
            local obj = bag.takeObject({
                position = pos,
                rotation = terrainInfo.rotation,
                smooth = false,
            })
            if terrainInfo.lua then
                obj.setLuaScript(terrainInfo.lua)
            end
            if terrainInfo.snapPoints then
                obj.setSnapPoints(terrainInfo.snapPoints)
            end
            table.insert(spawnedObjects, obj)
        end
    end

    if gameMode.customAssets then
        for i, item in ipairs(gameMode.customAssets) do
            local object = nil
            if item.json then
                object = spawnObjectJSON({
                    json = item.json,
                    position = item.position,
                    rotation = item.rotation or { 0, 0, 0 },
                    scale = item.scale or { 1, 1, 1 },
                    sound = false
                })
            elseif item.image then
                object = spawnObjectData({
                    data = {
                        Name = item.type or "Custom_Tile",
                        Locked = item.lock,
                        Snap = false,
                        AttachedSnapPoints = item.snapPoints,
                        Transform = {
                            posX = 0,
                            posY = 0,
                            posZ = 0,
                            rotX = 0,
                            rotY = 0,
                            rotZ = 0,
                            scaleX = 1,
                            scaleY = 1,
                            scaleZ = 1
                        },
                        CustomImage = {
                            ImageURL = item.image
                        },
                        LuaScript = item.luaScript,
                        Tags = item.tags or {},
                    },
                    position = item.position,
                    rotation = item.rotation or { 0, 0, 0 },
                    scale = item.scale or { 1, 1, 1 },
                    sound = false
                })
            end

            object.setName(item.name or "")
            object.setDescription(item.description or "")

            table.insert(spawnedObjects, #spawnedObjects + 1, object)
        end
    end

    -- objective cards are taken from last spawned deck
    local spawnedDeck = nil
    if gameMode.decks then
        for i, deckInfo in ipairs(gameMode.decks) do
            local position = deckInfo.position or Vector({ Setup.gamemodeZone_X[SETTINGS.boardsize] + 11, 1, deckInfo.zOffset })
            local spawnFunc = function()
                return nil
            end
            if deckInfo.type == "objective" then
                spawnFunc = Spawner.spawnObjectiveDeck
            elseif deckInfo.type == "mission" then
                spawnFunc = Spawner.spawnMissionDeck
            elseif deckInfo.type == "custom" then
                spawnFunc = function(cls, params)
                    return Spawner:spawnDeckOfCards({
                        cards = deckInfo.cards,
                        back = deckInfo.back,
                        gm_notes = deckInfo.gm_notes,
                        tags = deckInfo.tags,
                        position = params.position,
                        rotation = params.rotation,
                        callback = params.callback,
                    })
                end
            else
                log("ERR: invalid deck info")
            end
            spawnedDeck = spawnFunc(Spawner, {
                filter = function(v, k)
                    return not TableUtils.hasValue(deckInfo.filter or {}, tonumber(k))
                end,
                position = position,
                rotation = deckInfo.rotation,
                callback = function(c)
                    table.insert(spawnedObjects, c)
                end
            })
            table.insert(spawnedObjects, spawnedDeck)
            if deckInfo.randomize then
                spawnedDeck.randomize()
            end
        end
    end

    if gameMode.objectives then
        local objectivesInfo = {}
        if gameMode.objectives.type then
            local positions = Setup.objectivePositions[SETTINGS.boardsize][gameMode.objectives.type]
            objectivesInfo = TableUtils.map(positions, function(pos)
                local objInfo = Utils.copy(gameMode.objectives)
                objInfo.position = pos
                return objInfo
            end)
        else
            objectivesInfo = gameMode.objectives.custom
        end

        local objectiveBag = getObjectFromGUID(GUIDS["bag_objective"])
        local battleMat = getObjectFromGUID(GUIDS["battleMat"])
        local battleMatSnapPoints = battleMat.getSnapPoints()

        takeCardFunctions = {}
        for ix, info in ipairs(objectivesInfo) do
            local pos = info.position or Vector({ Setup.gamemodeZone_X[SETTINGS.boardsize] + 11, 0.9 + ix / 10, info.zOffset })
            local obj = objectiveBag.takeObject({
                position = pos,
                smooth = false,
            })
            table.insert(spawnedObjects, obj)
            if info.snap then
                table.insert(battleMatSnapPoints, { position = battleMat.positionToLocal(pos), tags = { "Objective" } })
            end
            if info.tags then
                for _, tag in ipairs(info.tags) do
                    obj.addTag(tag)
                end
            end
            if info.scale then
                obj.setScale(info.scale)
            end
            if info.name then
                obj.setName(info.name)
            end
            if info.takeCards ~= nil then
                local execute = function()
                    if spawnedDeck == nil then
                        return
                    end
                    local objCard = spawnedDeck.takeObject({
                        index = 1,
                        position = Vector(pos) + Vector({ 0, 2, -1.5 }),
                        rotation = { 0, 180, 0 },
                        flip = true,
                        smooth = false,
                    })
                    table.insert(spawnedObjects, objCard)
                end
                if info.takeCards == "now" then
                    execute()
                elseif info.takeCards == "later" then
                    table.insert(takeCardFunctions, execute)
                end
            end
        end

        if TableUtils.len(takeCardFunctions) > 0 then
            table.insert(takeCardFunctions, function()
                card.clearButtons()
            end)
            card.clearButtons()
            card.createButton({
                click_function = "onClickSpawnObjectiveCards",
                label = "Place",
                tooltip = "Place Objective Cards",
                position = { 0, 2.5, 1.9 },
                width = 350,
                font_size = 60,
            })
        end

        battleMat.setSnapPoints(battleMatSnapPoints)
    end

    spawnedGameModeObjects[gameModeId] = spawnedObjects

    if gameMode.callback then
        gameMode.callback()
    end
end

function GameModeUtil:cleanUp(card)
    if GameModeUtil.getCard(card.guid) ~= nil then
        return
    end

    if GameModeUtil.waitHandle then
        Wait.stop(GameModeUtil.waitHandle)
        GameModeUtil.waitHandle = nil
    end

    GameModeUtil.currentGameMode = "No Gamemode"
    SettingsUtil.updateGamemodeDisplay()
    UI.setAttribute("WOW_Panel", "active", false)
    UI.setAttribute("DWDW_Panel", "active", false)

    card.clearButtons()
    card.setScale({ 1.65, 1, 1.65 })
    card.UI.setXml("")
    GameModeUtil:removeGameModeObjects(string.sub(card.getDescription(), 11))
end

function GameModeUtil:removeGameModeObjects(gameModeId)
    local spawnedObjects = spawnedGameModeObjects[gameModeId]
    spawnedGameModeObjects[gameModeId] = nil

    if spawnedObjects == nil then
        return
    end

    for i, obj in ipairs(spawnedObjects) do
        if obj ~= nil then
            obj.destruct()
            spawnedObjects[i] = nil
        end
    end

    Global.setVectorLines({})
end

function GameModeUtil.updateMissionUi(zones, idPrefix)
    for id, zone in pairs(zones) do
        local card = GameModeUtil.getTopMissionCard(zone)
        local missionID = "Back"
        if card ~= nil then
            missionID = string.match(card.getName and card.getName() or card.name, "%d+")
        end

        UI.setAttribute(idPrefix .. id, "image", "Mission" .. missionID)
    end
end

-- if there are more than just one card/deck go with the last one
function GameModeUtil.getTopMissionCard(container)
    local objects = container.getObjects()
    for _, obj in TableUtils.reversePairs(objects) do
        if obj.hasTag("MissionCard") then
            if obj.type == "Card" then
                return obj
            end
            if obj.type == "Deck" then
                return TableUtils.last(obj.getObjects())
            end
        end
    end

    return nil
end

function GameModeUtil.getDeploymentPositions()
    if GameModeUtil.currentGameMode == "No Gamemode" then
        return { -10, 10 }
    end

    local gameMode = GameModeUtil.gameModeLookUp[GameModeUtil.currentGameMode]
    if gameMode == nil or gameMode.horizontalLines == nil then
        return { -10, 10 }
    end

    return gameMode.horizontalLines
end

function WOW.createZones()
    local pos1 = { 26, 1, 1 }
    local pos2 = { 26, 1, -1 }
    local scale = { 0.9, 0.5, 1.4 }
    local rotation = { 0, 90, 0 }
    WOW.zones.Red = spawnObject({
        type = "ScriptingTrigger",
        position = pos1,
        scale = scale,
        rotation = rotation,
    })
    WOW.zones.Blue = spawnObject({
        type = "ScriptingTrigger",
        position = pos2,
        scale = scale,
        rotation = rotation,
    })

    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], WOW.zones.Red)
    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], WOW.zones.Blue)

    local guidRed = WOW.zones.Red.guid
    local guidBlue = WOW.zones.Blue.guid

    local listener = function(params)
        local zone, obj = unpack(params)
        if not obj.hasTag("MissionCard") then
            return
        end
        if zone.guid ~= guidRed and zone.guid ~= guidBlue then
            return
        end
        GameModeUtil.updateMissionUi(WOW.zones, "WOW__")
    end

    local debounced = Utils.debounce(listener, 1)

    EventUtils.register("onObjectEnterZone", debounced)
    EventUtils.register("onObjectLeaveZone", debounced)
end

function DWDW.createZones()
    local pos1 = { 26, 1, 1 }
    local pos2 = { 26, 1, -1 }
    local posR1 = { 29.25, 1, 1 }
    local posR2 = { 29.25, 1, -1 }
    local scale = { 0.9, 0.5, 1.4 }
    local rotation = { 0, 90, 0 }
    DWDW.zones.Active1 = spawnObject({
        type = "ScriptingTrigger",
        position = pos1,
        scale = scale,
        rotation = rotation,
    })
    DWDW.zones.Active2 = spawnObject({
        type = "ScriptingTrigger",
        position = pos2,
        scale = scale,
        rotation = rotation,
    })
    DWDW.zones.Reserve1 = spawnObject({
        type = "ScriptingTrigger",
        position = posR1,
        scale = scale,
        rotation = rotation,
    })
    DWDW.zones.Reserve2 = spawnObject({
        type = "ScriptingTrigger",
        position = posR2,
        scale = scale,
        rotation = rotation,
    })
    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], DWDW.zones.Active1)
    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], DWDW.zones.Active2)
    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], DWDW.zones.Reserve1)
    table.insert(spawnedGameModeObjects[GameModeUtil.currentGameMode], DWDW.zones.Reserve2)

    local guidA1 = DWDW.zones.Active1.guid
    local guidA2 = DWDW.zones.Active2.guid
    local guidR1 = DWDW.zones.Reserve1.guid
    local guidR2 = DWDW.zones.Reserve2.guid

    local listener = function(params)
        local zone, obj = unpack(params)
        if not obj.hasTag("MissionCard") then
            return
        end
        if zone.guid ~= guidA1 and zone.guid ~= guidA2 and zone.guid ~= guidR1 and zone.guid ~= guidR2 then
            return
        end
        GameModeUtil.updateMissionUi(DWDW.zones, "DWDW__")
    end

    local debounced = Utils.debounce(listener, 1)

    EventUtils.register("onObjectEnterZone", debounced)
    EventUtils.register("onObjectLeaveZone", debounced)
end

return GameModeUtil