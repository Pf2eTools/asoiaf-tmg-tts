local TableUtils = require("lua.utils-table")
local Utils = require("lua.utils")


local Setup = {}

Setup.tacticsPosition = {
    ["4x4"] = Vector({39.75, 0.555, 0}),
    ["5x4"] = Vector({45.75, 0.555, 0}),
    ["6x4"] = Vector({51.75, 0.555, 0}),
}

Setup.deadUnitsBluePosition = {
    ["4x4"] = Vector({53, 0.57, -18.5}),
    ["5x4"] = Vector({59, 0.57, -18.5}),
    ["6x4"] = Vector({65, 0.57, -18.5}),
}

Setup.deadUnitsRedPosition = {
    ["4x4"] = Vector({53, 0.57, 18.5}),
    ["5x4"] = Vector({59, 0.57, 18.5}),
    ["6x4"] = Vector({65, 0.57, 18.5}),
}

Setup.bagsTerrain_X = {
    ["4x4"] = -53.5,
    ["5x4"] = -59.5,
    ["6x4"] = -65.5,
}

Setup.bagsTokens_X = {
    ["4x4"] = -50.5,
    ["5x4"] = -56.5,
    ["6x4"] = -62.5,
}

Setup.diceTrayBluePosition = {
    ["4x4"] = Vector({-36, 2, -14.5}),
    ["5x4"] = Vector({-42, 2, -14.5}),
    ["6x4"] = Vector({-48, 2, -14.5}),
}

Setup.diceTrayRedPosition = {
    ["4x4"] = Vector({-36, 2, 14.5}),
    ["5x4"] = Vector({-42, 2, 14.5}),
    ["6x4"] = Vector({-48, 2, 14.5}),
}

Setup.gamemodeZone_X = {
    ["4x4"] = -37.5,
    ["5x4"] = -43.5,
    ["6x4"] = -49.5,
}

Setup.width = {
    ["4x4"] = 48,
    ["5x4"] = 60,
    ["6x4"] = 72,
}
Setup.height = {
    ["4x4"] = 48,
    ["5x4"] = 48,
    ["6x4"] = 48,
}

-- TODO: Change 5x4 and 6x4 positions?
Setup.objectivePositions = {
    ["4x4"] = {
        ["3"] = {{-17.3, 2.05, 0}, {0, 2.05, 0}, {17.3, 2.05, 0}},
        ["5"] = {{-17.3, 2.05, 5.5}, {-17.3, 2.05, -5.5}, {0, 2.05, 0}, {17.3, 2.05, 5.5}, {17.3, 2.05, -5.5}},
    },
    ["5x4"] = {
        ["3"] = {{-17.3, 2.05, 0}, {0, 2.05, 0}, {17.3, 2.05, 0}},
        ["5"] = {{-17.3, 2.05, 5.5}, {-17.3, 2.05, -5.5}, {0, 2.05, 0}, {17.3, 2.05, 5.5}, {17.3, 2.05, -5.5}},
    },
    ["6x4"] = {
        ["3"] = {{-17.3, 2.05, 0}, {0, 2.05, 0}, {17.3, 2.05, 0}},
        ["5"] = {{-17.3, 2.05, 5.5}, {-17.3, 2.05, -5.5}, {0, 2.05, 0}, {17.3, 2.05, 5.5}, {17.3, 2.05, -5.5}},
    },
}

function Setup.moveTriggerZones()
    local tacticsTile = getObjectFromGUID(GUIDS["tactics_tile"])
    local tacticsPosWorld = tacticsTile.getPosition()

    local crownPos = tacticsTile.positionToWorld({1.4, 2.75, -0.52})
    local bagPos = tacticsTile.positionToWorld({0.7, 2.75, -0.52})
    local letterPos = tacticsTile.positionToWorld({0, 2.75, -0.52})
    local swordsPos = tacticsTile.positionToWorld({-0.7, 2.75, -0.52})
    local horsePos = tacticsTile.positionToWorld({-1.4, 2.75, -0.52})

    getObjectFromGUID(GUIDS["tactics_zones"]["crown"]).setPosition(crownPos)
    getObjectFromGUID(GUIDS["tactics_zones"]["moneyBag"]).setPosition(bagPos)
    getObjectFromGUID(GUIDS["tactics_zones"]["letter"]).setPosition(letterPos)
    getObjectFromGUID(GUIDS["tactics_zones"]["swords"]).setPosition(swordsPos)
    getObjectFromGUID(GUIDS["tactics_zones"]["horse"]).setPosition(horsePos)

    local round1Pos = tacticsTile.positionToWorld({1, 0.65, 0.75})
    local round2Pos = tacticsTile.positionToWorld({0.6, 0.65, 0.75})
    local round3Pos = tacticsTile.positionToWorld({0.2, 0.65, 0.75})
    local round4Pos = tacticsTile.positionToWorld({-0.2, 0.65, 0.75})
    local round5Pos = tacticsTile.positionToWorld({-0.6, 0.65, 0.75})
    local round6Pos = tacticsTile.positionToWorld({-1, 0.65, 0.75})

    local firstBluePos = tacticsTile.positionToWorld({-1.4, 0.65, 0.75})
    local firstRedPos = tacticsTile.positionToWorld({1.4, 0.65, 0.75})

    getObjectFromGUID(GUIDS["tactics_round"][1]).setPosition(round1Pos)
    getObjectFromGUID(GUIDS["tactics_round"][2]).setPosition(round2Pos)
    getObjectFromGUID(GUIDS["tactics_round"][3]).setPosition(round3Pos)
    getObjectFromGUID(GUIDS["tactics_round"][4]).setPosition(round4Pos)
    getObjectFromGUID(GUIDS["tactics_round"][5]).setPosition(round5Pos)
    getObjectFromGUID(GUIDS["tactics_round"][6]).setPosition(round6Pos)

    getObjectFromGUID(GUIDS["tactics_first_player"]["Blue"]).setPosition(firstBluePos)
    getObjectFromGUID(GUIDS["tactics_first_player"]["Red"]).setPosition(firstRedPos)

    getObjectFromGUID(GUIDS["ncu_zone_resting"]["Blue"]).setPosition(tacticsPosWorld + Vector({0, 1.25, -23.35}))
    getObjectFromGUID(GUIDS["ncu_zone_resting"]["Red"]).setPosition(tacticsPosWorld + Vector({0, 1.25, 23.35}))
end

function Setup.moveTacticsBoard(ixPosition)
    local toSetPosition = Setup.tacticsPosition[ixPosition]

    local tacticsTile = getObjectFromGUID(GUIDS["tactics_tile"])
    local vpCounterBlue = getObjectFromGUID(GUIDS["vp_counter"]["Blue"])
    local vpCounterRed = getObjectFromGUID(GUIDS["vp_counter"]["Red"])
    local throne = getObjectFromGUID(GUIDS["first_player_throne"])
    local roundMarker = getObjectFromGUID(GUIDS["round_marker"])
    local maester = getObjectFromGUID(GUIDS["maester"])

    -- not very clean
    local offsetVPBlue = vpCounterBlue.getPosition() - tacticsTile.getPosition()
    local offsetVPRed = vpCounterRed.getPosition() - tacticsTile.getPosition()
    local offsetThrone = throne.getPosition() - tacticsTile.getPosition()
    local offsetRoundMarker = roundMarker.getPosition() - tacticsTile.getPosition()
    local offsetMaester = maester.getPosition() - tacticsTile.getPosition()

    tacticsTile.setPosition(toSetPosition)
    vpCounterBlue.setPosition(toSetPosition + offsetVPBlue)
    vpCounterRed.setPosition(toSetPosition + offsetVPRed)
    throne.setPosition(toSetPosition + offsetThrone)
    roundMarker.setPosition(toSetPosition + offsetRoundMarker)
    maester.setPosition(toSetPosition + offsetMaester)

    Setup.moveTriggerZones()
end

function Setup.moveDeadUnits(ixPosition)
    local deadUnitsBlue = getObjectFromGUID(GUIDS["dead_units"]["Blue"])
    local deadUnitsRed = getObjectFromGUID(GUIDS["dead_units"]["Red"])

    local toSetPositionBlue = Setup.deadUnitsBluePosition[ixPosition]
    local toSetPositionRed = Setup.deadUnitsRedPosition[ixPosition]

    deadUnitsBlue.setPosition(toSetPositionBlue)
    deadUnitsRed.setPosition(toSetPositionRed)
end

function Setup.moveBagsTerrain(ixPosition)
    local xToSet = Setup.bagsTerrain_X[ixPosition]
    for _, guid in pairs(GUIDS["bags_terrain"]) do
        local obj = getObjectFromGUID(guid)
        local pos = obj.getPosition()
        obj.setPosition({xToSet, pos.y, pos.z})
    end
end
function Setup.moveBagsTokens(ixPosition)
    local xToSet = Setup.bagsTokens_X[ixPosition]
    for _, guid in pairs(GUIDS["bags_tokens"]) do
        local obj = getObjectFromGUID(guid)
        local pos = obj.getPosition()
        obj.setPosition({xToSet, pos.y, pos.z})
    end
end

function Setup.moveDiceTrays(ixPosition)
    local trayBlue = getObjectFromGUID(GUIDS["dice_tray"]["Blue"])
    local trayRed = getObjectFromGUID(GUIDS["dice_tray"]["Red"])

    local toSetPositionBlue = Setup.diceTrayBluePosition[ixPosition]
    local toSetPositionRed = Setup.diceTrayRedPosition[ixPosition]

    trayBlue.setPosition(toSetPositionBlue)
    trayRed.setPosition(toSetPositionRed)
    gameObjects[GUIDS["dice_tray"]["Blue"]]:setZonePosition()
    gameObjects[GUIDS["dice_tray"]["Red"]]:setZonePosition()
end

function Setup.moveGamemodeZone(ixPosition)
    local zone = getObjectFromGUID(GUIDS["place_gamemode_zone"])
    local tile = getObjectFromGUID(GUIDS["place_gamemode_tile"])
    local toSet_X = Setup.gamemodeZone_X[ixPosition]

    zone.setPosition({toSet_X, 0, 0})
    tile.setPosition({toSet_X, 0.65 ,0})
end

function Setup.doSetup(ixPosition)
    Setup.moveTacticsBoard(ixPosition)
    Setup.moveDeadUnits(ixPosition)
    Setup.moveBagsTerrain(ixPosition)
    Setup.moveBagsTokens(ixPosition)
    Setup.moveDiceTrays(ixPosition)
    Setup.moveGamemodeZone(ixPosition)
end

function Setup.readyTerrain()
    local terrainTiles = Utils.getObjectsWithTagsOnBoard({"Terrain"})
    for _, terrain in ipairs(terrainTiles) do
        terrain.lock()
        local pos = terrain.getPosition()
        local rot = terrain.getRotation()
        terrain.setPosition({pos.x, 1.848, pos.z})
        terrain.setRotation({0, rot.y, 0})
    end
end

function Setup.readyObjectives()
    local objectiveTiles = Utils.getObjectsWithTagsOnBoard({"Objective"})
    objectiveTiles = TableUtils.filter(objectiveTiles, function(ot) return not ot.hasTag("SkipReady") end)
    for _, objective in ipairs(objectiveTiles) do
        objective.lock()
        local pos = objective.getPosition()
        local rot = objective.getRotation()
        objective.setPosition({pos.x, 1.849, pos.z})
        objective.setRotation({0, rot.y, 0})
    end
end

function Setup.lockGameMode()
    local gameModeZone = getObjectFromGUID(GUIDS["place_gamemode_zone"])
    if gameModeZone == nil then
      return
    end

    for i, obj in ipairs(gameModeZone.getObjects()) do
      if obj.tag == "Card" and string.find(obj.getDescription(), "Game Mode") then
        obj.lock()
      end
    end
end

return Setup