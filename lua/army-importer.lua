local TableUtils = require("lua.utils-table")
local db = require("lua.data-lookup")
local Utils = require("lua.utils")
local TacticsBoard, TacticsUi = unpack(require("lua.tacticsBoard"))


ArmyImporter = {}
ArmyImporter.__index = ArmyImporter
ArmyImporter.__className = "ArmyImporter"

setmetatable(ArmyImporter, {
    __index = Spawner,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        opts.__className = cls.__className
        local this = setmetatable(Spawner(gameObj, opts), ArmyImporter)

        this.armyBuilderUrls = {}
        this.armyListId = nil
        this.armyJson = nil
        this.data = nil
        this.specialTacticsPos = opts.specialTacticsPos

        this.images = opts.images
        this.playerColor = opts.color
        this.source = "asoiaf-stats.com"
        this.selectedColor = opts.color
        this.gridOrigins = opts.gridOrigins
        this.isGridsInitialized = false

        this.deckLocation = {
            pos = Vector(-29.81, 3, 0) + this.vectUp * -27.82,
            rot = this.rotUp + Vector(0, 0, 180),
        }

        return this
    end
})

function ArmyImporter:init()
    self:register({"armyInput_onEndEdit", "chooseColor_onValueChanged", "spawnArmy_onClick", "chooseSource_onValueChanged"})
    self:initializeSourceLookUp()
    self:initXmlUi()
end

-- FIXME/TODO: Only sensible results while inside the grid.
function ArmyImporter:initSpawnGrids()
    self.grid_ncus = Grid({
        origin = self.gridOrigins.ncus,
        rowOffset = self.vectUp * -5.5,
        columnOffset = Vector({1,0,0}) * -3.5,
        columns = 6,
        rows = 1,
    })
    self.grid_combatUnits = Grid({
        origin = self.gridOrigins.combatUnits,
        rowOffset = self.vectUp * 5.5,
        columnOffset = self.vectRight * 5.5,
        columns = 8,
        rows = 1,
    })

    self.grid_enemy = Grid({
        origin = self.gridOrigins.enemy,
        rowOffset = self.vectUp * -2.6,
        columnOffset = self.vectRight * 2.6,
        columns = 3,
        rows = 2,
    })
    self.grid_cards = Grid({
        origin = self.gridOrigins.cards,
        rowOffset = self.vectUp * -6.2,
        columnOffset = self.vectRight * 5.5,
        columns = 8,
        rows = 2,
    })

    self.grid_extra = Grid({
        origin = self.gridOrigins.unitsFromTactics,
        rowOffset = self.vectUp * -9,
        columnOffset = Vector(1, 0, 0) * 5.7,
        columns = 5,
        rows = 1,
    })

    self.isGridsInitialized = true
end

function ArmyImporter:initializeSourceLookUp()
    self.armyBuilderUrls["asoiaf-stats.com"] = {
        url = "https://51jadhwyqc.execute-api.eu-west-2.amazonaws.com/prod/tts-list-2?listId=",
        image = self.images.stats
    }

    self.armyBuilderUrls["asoiaf.fr"] = {
        url = "https://builder.asoiaf.fr",
        image = self.images.ASOIAFfr
    }
    -- TODO: MAYBE
    --self.armyBuilderUrls["Army Text"] = {
    --    image = self.images.raw
    --}
    self.armyBuilderUrls["ID String"] = {
        image = self.images.raw
    }
    --self.armyBuilderUrls["ASoIaF-Stats.com (Legacy)"] = {
    --    url = "https://51jadhwyqc.execute-api.eu-west-2.amazonaws.com/prod/tts-list?listId=",
    --    image = self.images.stats
    --}
end
function ArmyImporter:initXmlUi()
    local sourceOptions = {}
    for srcName, src in pairs(self.armyBuilderUrls) do
        local opt = {
            tag = "Option",
            value = srcName
        }
        if srcName == self.source then
            opt.attributes = {
                selected = true
            }
        end
        table.insert(sourceOptions, opt)
    end

    local colorOptions = {}
    for color, _ in pairs(self.colorLookup) do
        local opt = {
            tag = "Option",
            value = color
        }
        if color == self.playerColor then
            opt.attributes = {
                selected = true
            }
        end
        table.insert(colorOptions, opt)
    end

    local input = {
        tag = "InputField",
        attributes = {
            id = "armyInput",
            onEndEdit = self._guid .. "/armyInput_onEndEdit",
            colors = "#FFFFFF|#C0C0C0|#FFFFFF|A0A0A0",
            textColor = "#000000",
            position = "0 -25 -21",
            rotation = "0 0 180 ",
            width = "240",
            height = "41",
            fontSize = "20",
            fontStyle = "Bold",
            placeholder = self.source ==  "Text" and "Paste army text here" or "Paste army ID here",
            lineType = self.source ==  "Text" and "MultiLineNewLine" or "SingleLine"
        }
    }

    local xmlUiTable = {
        input,
        {
            tag = "Panel",
            attributes = {
                width = "240",
                height = "80",
                rotation = "0 0 180",
                position = "0 50 -21"
            },
            children = {{
            tag = "TableLayout",
            attributes = {
                cellSpacing = "10",
                cellBackgroundColor = "clear",
                columnWidths = "120 120"
            },
            children = {{
                tag = "Row",
                children = {{
                    tag = "Cell",
                    children = {{
                        tag = "Dropdown",
                        attributes = {
                            id = "chooseColorOption",
                            onValueChanged = self._guid .. "/chooseColor_onValueChanged",
                            colors = "#FFFFFF|#C0C0C0|#FFFFFF|A0A0A0",
                            width = "120",
                            height = "34",
                            fontSize = "17",
                            fontStyle = "Bold",
                            itemHeight = "34",
                            scrollSensitivity = "50"
                        },
                        children = colorOptions
                    }}
                }, {
                    tag = "Cell",
                    children = {{
                        tag = "Button",
                        attributes = {
                            id = "spawnArmyButton",
                            onclick = self._guid .. "/spawnArmy_onClick",
                            colors = "#FFFFFF|#C0C0C0|#FFFFFF|A0A0A0",
                            width = "120",
                            height = "34",
                            fontSize = "17",
                            fontStyle = "Bold",
                            text = "Spawn Army"
                        }
                    }}
                }}
            }, {
                tag = "Row",
                children = {{
                    tag = "Cell",
                    attributes = {
                        columnSpan = "2"
                    },
                    children = {{
                        tag = "ProgressBar",
                        attributes = {
                            id = "importProgressBar",
                            active = "false",
                            width = "240",
                            height = "34",
                            showPercentageText = "false",
                            color = "#FFFFFF",
                            fillImageColor = "#0094FF"
                        }
                    }, {
                        tag = "Dropdown",
                        attributes = {
                            id = "chooseSourceOption",
                            onValueChanged = self._guid .. "/chooseSource_onValueChanged",
                            colors = "#FFFFFF|#C0C0C0|#FFFFFF|A0A0A0",
                            width = "240",
                            height = "34",
                            fontSize = "17",
                            fontStyle = "Bold",
                            itemHeight = "34"
                        },
                        children = sourceOptions
                    }}
                }}
            }}
        }}
    }}
    self.gameObj.UI.setXmlTable(xmlUiTable)
end

-- params = {player, value, id}
function ArmyImporter:armyInput_onEndEdit(params)
    local player, value, id = unpack(params)
    self.armyListId = value
end
-- params = {player, value, id}
function ArmyImporter:chooseColor_onValueChanged(params)
    local player, value, id = unpack(params)
    self.selectedColor = value
end
-- params = {player, value, id}
function ArmyImporter:chooseSource_onValueChanged(params)
    local player, value, id = unpack(params)
    if self.source == value then
        return
    end
    self.gameObj.setDescription("Import an Army from " .. value)
    self.data = nil

    self.source = value
    local custom = self.gameObj.getCustomObject()
    custom.image = self.armyBuilderUrls[self.source].image
    self.gameObj.setCustomObject(custom)
    self.gameObj.reload() -- this kills the crab (gameObj)
    self.gameObj = getObjectFromGUID(self._guid)
    self:initXmlUi()
end

function ArmyImporter:error(message)
    if Player[self.playerColor].seated then
        broadcastToColor(message, self.playerColor, self.playerColor)
    else
        broadcastToAll(message, self.playerColor)
    end

end
function ArmyImporter:cleanUp()
    self.gameObj.UI.setAttribute("armyInput", "value", "")
    self.gameObj.UI.setAttribute("armyInput", "text", "")
    self.armyListId = nil
end

function ArmyImporter:spawnArmy_onClick()
    if self.armyListId == nil then
        return
    end

    if self.source == "Text" then
        self:parseRawText(self.armyListId)
        self:spawnArmy()
        self:cleanUp()
    elseif self.source == "ID String" then
        self:parseIdString()
        self:spawnArmy()
        self:cleanUp()
    else
        local success, errorMsg = pcall(function()
            WebRequest.get(self.armyBuilderUrls[self.source].url .. self.armyListId, function(webReturn)
                local jsonData = self:getArmyJSON(webReturn)
                self:parseJsonData(jsonData)
                self:spawnArmy()
                self:cleanUp()
            end)
        end)

        if not success then
            self:error("The following error occurred while loading the army from " .. self.source .. ":\n" .. errorMsg)
        end
    end
end

function ArmyImporter:initData()
    self.data = {
        faction = "",
        commander = nil,
        ncu = {},
        unit = {},
        enemy = {}
    }

end
function ArmyImporter:parseLookupArray(lookupArray)
    local lastUnit
    for _, lookup in pairs(lookupArray) do
        -- asoiaf-stats likes to give some ids as their commander
        if lookup.cmdr and self.data.commander == nil then
            self.data.commander = lookup
        end

        if lookup.enemy then
            table.insert(self.data.enemy, lookup)
        elseif lookup.type == "ncu" then
            table.insert(self.data.ncu, lookup)
        elseif lookup.type == "unit" then
            if lastUnit ~= nil then
                table.insert(self.data.unit, lastUnit)
                lastUnit = {unit = lookup, attachments = {}}
            else
                lastUnit = {unit = lookup, attachments = {}}
            end
        elseif lookup.type == "attachment" then
            if lastUnit ~= nil then
                table.insert(lastUnit.attachments, lookup)
            else
                log("ERROR: Tried to add attachment before unit.", "red")
            end
        end
    end

    if lastUnit ~= nil then
        table.insert(self.data.unit, lastUnit)
    end
end

function ArmyImporter:parseIdString()
    self:initData()
    local faction, rest = unpack(Utils.split(self.armyListId, ";"))
    self.data.faction = string.lower(faction):gsub("%W", "")
    local ids = Utils.split(rest, ",")
    local idArray = {}
    for _, id in pairs(ids) do
        local trimmed = Utils.trim(id)
        local lookup = db.get(trimmed)
        if lookup ~= nil then
            table.insert(idArray, lookup)
        end
    end
    self:parseLookupArray(idArray)
end

function ArmyImporter:getArmyJSON(webReturn)
    local jsonData

    if webReturn.is_done then
        if webReturn.is_error == true then
            self:error("The following error occurred while loading the army from " .. self.source .. ":\n" .. webReturn.error)
        elseif webReturn.text == nil or webReturn.text == "" then
            self:error("Could not load army from " .. self.source .. ". An unknown error occured.")
        else
            jsonData = JSON.decode(webReturn.text)
        end
    end

    return jsonData
end
function ArmyImporter:parseJsonData(jsonData)
    self:initData()
    if self.source == "asoiaf-stats.com" then
        self:parseStatsJsonData(jsonData)
    elseif self.source == "asoiaf.fr" then
        self:parseFrenchJsonData(jsonData)
    else
        log("ERROR: The Source '" .. self.source .. "' has no implemented json parser.")
    end
end

function db.get_stats(idstring)
    if idstring == "10230" then
        return db.get("10220")
    end

    return db.get(idstring)
end
function ArmyImporter:parseStatsJsonData(jsonData)
    self.data.faction = string.lower(jsonData.faction.name):gsub("%W", "")
    if self.data.faction == "brotherhoodwithoutbanners" then
        self.data.faction = "brotherhood"
    end
    self:parseLookupArray(TableUtils.map(jsonData.idArray, function(id) return db.get_stats(tostring(id)) end))
end
-- TODO: DELETE THIS GARBAGE
function db.get_french(obj)
    if obj == nil then
        return nil
    end
    local lookup = db.get(obj.name)
    if lookup == nil then
        local filtered = db.get_filter(function(lu)
            return getFullName(obj):lower() == lu.fullName:lower()
        end)
        -- This is total garbage but this importer doesn't deserver better
        lookup = filtered[1]
    end
    return lookup
end
function ArmyImporter:parseFrenchJsonData(jsonData)
    self.data.faction = string.lower(jsonData.faction):gsub("%W", "")
    if self.data.faction == "brotherhoodwithoutbanners" then
        self.data.faction = "brotherhood"
    end

    for ix, obj in ipairs(jsonData.list) do
        local lookup = db.get_french(obj)
        if obj == nil then
            broadcastToAll("ERROR: Unexpected nil value in data. Do NOT contact mod authors for this issue.", {r=1, g=0, b=0})
        elseif lookup == nil then
            broadcastToAll("ERROR: Couldn't import '" .. getFullName(obj) .. "'. This importer is no longer supported. Do NOT contact mod authors for this issue.", {r=1, g=0, b=0})
        elseif ix == 1 then
            self.data.commander = lookup
        elseif obj.type:upper() == "NCU" then
            table.insert(self.data.ncu, lookup)
        elseif obj.type:upper() == "ENEMY" then
            table.insert(self.data.enemy, lookup)
        else -- Combat Unit
            local cu = {unit = lookup, attachments = {}}
            local last_a = obj.attachment
            while last_a ~= nil do
                local attach_lookup = db.get_french(last_a)
                if attach_lookup ~= nil then
                    table.insert(cu.attachments, attach_lookup)
                end
                last_a = last_a.attachment
            end
            table.insert(self.data.unit, cu)
        end
    end
end

-- RIP / Re-enable soon?
function ArmyImporter:parseRawText(str)
    self.data = {
        faction = "",
        commander = "",
        unit = {},
        ncu = {},
        enemy = {},
    }
    local lines = Utils.split(Utils.trim(str), "\n")
    local sections = {}
    local section = ""
    for _, line in ipairs(lines) do
        if Utils.trim(line) == "" then
            table.insert(sections, section)
            section = ""
        else
            section = section .. line .. "\n"
        end
    end
    table.insert(sections, section)

    for ix, section in ipairs(sections) do
        section = Utils.trim(section) .. "\n"
        if ix == 1 then
            self.data.faction = Utils.trim(section:match("Faction: (.-)\n"):upper())
            local commanderName = section:match("Commander: (.-)\n")
            local commanderLookup = self:getLookup({name = Utils.trim(commanderName), commander = true})
            self.data.commander = commanderLookup
        else
            -- ASOIAF.stats copy list doesn't generate NCUs with the subname, so we will need to find it
            local parsed = self:parseRawText_Section(section)
            if section:match("Non Combat Units") then
                local allNCUs = db.get_filter(function (it) return it.type == "ncu" end)
                self.data.ncu = TableUtils.map(parsed, function (u)
                    -- TODO: Just take the first? Consider the cost of the unit once we have that data
                    local foundNCU = TableUtils.find(allNCUs, function (n) return n.name:find(u.name) ~= nil end)
                    if foundNCU ~= nil then
                        return self:createNCUDefinitions(foundNCU)
                    end
                    return self:createNCUDefinitions(u)
                end)
            elseif section:match("Combat Units") then
                self.data.unit = TableUtils.map(parsed, function (u) return self:createCombatUnitDefinitions(u) end)
            elseif section:match("Enemy Attachments") then
                self.data.enemy = TableUtils.map(parsed, function (u) return self:createEnemyAttachmentDefinitions(u) end)
            elseif section:match("Built on") or section:match("Find list at") then
                -- no op
            else
                self:error("ERR: Unexpected section")
                return
            end
        end
    end
end
function ArmyImporter:parseRawText_Section(section)
    local units = {}
    local unit = nil
    for line in section:gsub("^.-\n", ""):gmatch(".-\n") do
        if line:match("•") then
            if unit ~= nil then
                table.insert(units, unit)
            end
            unit = {name = Utils.trim(line:gsub("•", ""):gsub("%(%s*%d%s*%)", ""))}
        else
            unit.attachments = unit.attachments or {}
            table.insert(unit.attachments, {name = Utils.trim(line:gsub("%(%s*%d%s*%)", ""))})
        end
    end
    if unit ~= nil then
        table.insert(units, unit)
    end
    return units
end

function ArmyImporter:injectPets()
    local injectVaramyrEagle = false
    local injectSkinchanger = false
    for _, unit in ipairs(self.data.unit) do
        if unit.unit.id == "10317" or unit.unit.id == "10318" then
            injectVaramyrEagle = true
        end
        for _, attachment in ipairs(unit.attachments) do
            if attachment.id == "20307" then
                injectSkinchanger = true
            end
        end
    end

    for _, ncu in ipairs(self.data.ncu) do
        if ncu.id == "30512" then
            local defs = self:createCombatUnitDefinitions({unit = db.get("10509"), attachments = {}})
            defs.attachmentCards = self:getUnitCards(ncu)
            table.insert(self.extraUnits, defs)
        end
    end

    if injectVaramyrEagle then
        table.insert(self.data.enemy, db.get("20330")) -- Varamyr's Eagle
    end
    if injectSkinchanger then
        table.insert(self.data.unit, {unit = db.get("10310"), attachments = {}}) -- Bear
        table.insert(self.data.enemy, db.get("20308")) -- Eagle
        table.insert(self.data.enemy, db.get("20309")) -- Wolf
    end
end
function ArmyImporter:spawnArmy()
    if not self.isGridsInitialized or SETTINGS["playerCount"] == "1 vs 1" then
        self:initSpawnGrids()
    end
    self.extraUnits = {}

    self:injectPets()

    -- TODO/FIXME: If too many units/ncus/enemyAttachments we will spawn them inside each other
    for _, unit in ipairs(self.data.unit) do
        local defs = self:createCombatUnitDefinitions(unit)
        self:spawnCombatUnit(defs)
    end

    for _, ncu in ipairs(self.data.ncu) do
        local defs = self:createNCUDefinitions(ncu)
        self:spawnNCU(defs)
    end

    for _, enemy in ipairs(self.data.enemy) do
        local defs = self:createEnemyAttachmentDefinitions(enemy)
        self:spawnEnemyAttachment(defs)
    end

    self:spawnTacticsDeck()
    self:spawnFactionRules()
    self:spawnExtraUnits()
end

function ArmyImporter:createNCUDefinitions(ncu)
    local definitions = self:figureFromLookup(ncu, {
        assetScale = {2.6, 2.6, 2.6},
        figureScale = {1.75, 1.75, 1.75},
    })
    definitions.cost = ncu.cost or 0
    return definitions
end
function ArmyImporter:createEnemyAttachmentDefinitions(enemy)
    local defs = self:figureFromLookup(enemy, {
        assetScale = {1, 1, 1},
        figureScale = {0.7, 0.7, 0.7},
    })
    defs.cost = enemy.cost or 0
    return defs
end

function ArmyImporter:existsSpecialTactics(name)
    for color, pos in pairs(specialTacticsLocations) do
        local cast = Physics.cast({
            origin = pos + Vector(0, -1, 0),
            type = 2, --sphere
            size = {2, 2, 2},
            direction = {0, 1, 0},
            max_distance = 2,
            -- debug = true,
        })
        for _, obj in pairs(cast) do
            if obj.hit_object.hasTag(tagSpecialTactics) and obj.hit_object.getName() == name then
                return true
            end
        end
    end
    return false
end
function ArmyImporter:spawnEnemyAttachment(definitions)
    definitions.objectData.position = self.grid_enemy:getNextPos()
    definitions.objectData.rotation = self.rotUp
    local figure = self:_spawnFigure(definitions)
    figure.setVar("cost", definitions.cost)
    figure.setVar("enemyCost", definitions.cost)
    figure.addTag(InfantryTray.unitModelTag)

    local cardPosition = definitions.objectData.position + Vector(0, 0.3, 0) + self.vectUp * -3
    for k, card in pairs(definitions.cards) do
        self:doSpawnCardAndTokens({card = card, position = cardPosition, rotation = self.rotUp})
    end
end
function ArmyImporter:spawnNCU(ncuDefinitions)
    ncuDefinitions.objectData.position = self.grid_ncus:getNextPos()
    ncuDefinitions.objectData.rotation = self.rotUp
    local ncuFigure = self:_spawnFigure(ncuDefinitions)
    ncuFigure.addTag("NCU")
    ncuFigure.setVar("cost", ncuDefinitions.cost)
    ncuFigure.setVar("owner", self.playerColor)

    if ncuDefinitions.specialTactics ~= nil then
        if not self:existsSpecialTactics(ncuDefinitions.specialTactics.name) then
            local specialTactics = self:doSpawnCard({
                card = ncuDefinitions.specialTactics,
                position = self.specialTacticsPos,
                rotation = {0, 0, 0}
            })
            specialTactics.setName(ncuDefinitions.specialTactics.name)
            specialTactics.addTag(tagSpecialTactics)
            specialTactics.setScale({5, 1.0, 5})
            specialTactics.setRotation({0, 270, 0})
            specialTactics.lock()
            specialTactics.setSnapPoints({{
                position = {0, 0, -0.85},
                rotation = {0, 0, 0},
                rotation_snap = true
            }})
            local specialTacticsZone = spawnObject({
                type = "ScriptingTrigger",
                position = specialTactics.positionToWorld({0, 0, -0.85}),
                scale = {1, 1, 1},
            })
            GUIDS["tactics_zones"][self.playerColor] = specialTacticsZone.guid
            local zoneName = string.gsub(ncuDefinitions.specialTactics.name, "%s+", "")
            TacticsBoard.specialTactics[self.playerColor] = zoneName
            TacticsUi.setSpecialTacticsZone(self.playerColor, zoneName)
        end
    end

    local cardPosition = ncuDefinitions.objectData.position + self.vectUp * -4
    local spawnedCard = nil
    for k, card in pairs(ncuDefinitions.cards) do
        spawnedCard = self:doSpawnCardAndTokens({card = card, position = cardPosition + Vector(0, k*0.1, 0), rotation = self.rotUp})
    end
    spawnedCard.addTag("NCUcard")
end
function ArmyImporter:_spawnFigure(figureDefinitions)
    local newFigure = spawnObject(figureDefinitions.objectData)
    newFigure.setName(figureDefinitions.name)
    newFigure.setDescription(figureDefinitions.description)
    newFigure.setGMNotes(figureDefinitions.id)
    newFigure.setColorTint(self.colorLookup[self.selectedColor])
    newFigure.setCustomObject(figureDefinitions.custom)

    return newFigure
end

function ArmyImporter:createCombatUnitDefinitions(data)
    local cards = {}
    local attachmentCards = {}
    local unit = data.unit
    local trayClass = self:getTrayClass(unit.tray)
    local shouldSpawnAttachments = trayClass == InfantryTray or trayClass == CavalryTray

    local figures = {}
    for _, attachment in ipairs(data.attachments) do
        -- only add attachments to infantry and cavalry units
        if shouldSpawnAttachments then
            local attachmentFigure = self:getUnitFigureData(attachment)
            table.insert(figures, attachmentFigure)
        end

        attachmentCards[attachment.fullName] = {
            name = attachment.fullName,
            face = attachment.cardFace,
            back = attachment.cardBack,
            tokens = attachment.tokens,
            tokenName = attachment.tokenName
        }

        local specialRulesCards = self:getSpecialRulesToSpawn(attachment)
        for _, specialRulesCard in ipairs(specialRulesCards) do
            attachmentCards[specialRulesCard.name] = specialRulesCard
        end
    end

    local loopBounds = 1
    if shouldSpawnAttachments then
        loopBounds = #data.attachments + 1
    end

    local unitFigure = {}
    local specialFigures = self:getSpecialRuleFromType(unit, "banners")
    for idx = loopBounds, (trayClass.rows * trayClass.columns), 1 do
        if specialFigures ~= nil and idx > 8 then
            unitFigure = self:getUnitFigureData(specialFigures)
            table.insert(figures, unitFigure)
        else
            unitFigure = self:getUnitFigureData(unit)
            table.insert(figures, unitFigure)
        end
    end

    for idx, figure in ipairs(figures) do
        figure.Transform.posX = figure.Transform.posX + trayClass.snapPoints[idx].Position.x
        figure.Transform.posY = figure.Transform.posY + trayClass.snapPoints[idx].Position.y
        figure.Transform.posZ = figure.Transform.posZ + trayClass.snapPoints[idx].Position.z
        figure.Memo = idx
    end

    cards[unit.fullName] = {
        name = unit.fullName,
        face = unit.cardFace,
        back = unit.cardBack,
        tokens = unit.tokens,
        tokenName = unit.tokenName
    }

    local specialRulesCards = self:getSpecialRulesToSpawn(unit)
    for _, specialRulesCard in ipairs(specialRulesCards) do
        attachmentCards[specialRulesCard.name] = specialRulesCard
    end

    local objectData = trayClass:getObjectData({
        ChildObjects = figures,
        Nickname = unitFullName,
        color = self.colorLookup[self.selectedColor]
    })

    local spawnOptions = self:getCombatUnitSpawnOptions(unit, data.attachments)

    return {
        objectData = objectData,
        spawnOptions = spawnOptions,
        cards = cards,
        attachmentCards = attachmentCards,
        trayClass = trayClass
    }
end
function ArmyImporter:spawnCombatUnit(unitDefinitions)
    self:_spawnCombatUnit(unitDefinitions, self.grid_combatUnits, self.grid_cards)
end
function ArmyImporter:_spawnCombatUnit(unitDefinitions, grid_unit, grid_cards)
    local tokenSpawned = {}
    local position = grid_unit:getNextPos()
    local rotation = self.rotUp + Vector(0, 180, 0)

    self:doSpawnCombatUnit({
        trayClass = unitDefinitions.trayClass,
        objectData = unitDefinitions.objectData,
        spawnOptions = unitDefinitions.spawnOptions,
        position = position,
        rotation = rotation,
    })

    local cardPosition = grid_cards:getNextPos()
    for _, card in pairs(unitDefinitions.cards) do
        self:doSpawnCard({card = card, position = cardPosition, rotation = self.rotUp})

        local enemyCardPos = Vector.new(cardPosition):rotateOver("y", 180) + Vector(-54, 0, 0)
        self:doSpawnCard({card = card, position = enemyCardPos, rotation = self.rotUp + Vector(0, 180, 0)})

        local tokenName = self:getTokenNameOrDefault(card.tokenName)

        if card.tokens and tokenSpawned[tokenName] == nil then
            Wait.frames(function()
                local tokenPos = cardPosition + self.vectUp * 1.1 + self.vectRight
                local tokenRot = self.rotUp
                self:doSpawnTokens({
                    count = card.tokens,
                    position = tokenPos,
                    rotation = tokenRot,
                    name = tokenName,
                })
            end, 1)
            tokenSpawned[tokenName] = tokenName
        end
    end
    local ix = 0
    for _, card in pairs(unitDefinitions.attachmentCards) do
        local attachCardPosition = cardPosition + self.vectUp * -3.1 + self.vectRight * (0.7 * math.min(3, ix) - 1.5)
        self:doSpawnCard({card = card, position = attachCardPosition, rotation = self.rotUp})

        local enemyAttachCardPos = Vector.new(attachCardPosition):rotateOver("y", 180) + Vector(-54, 0, 0)
        self:doSpawnCard({card = card, position = enemyAttachCardPos, rotation = self.rotUp + Vector(0, 180, 0)})

        local tokenName = self:getTokenNameOrDefault(card.tokenName)

        if card.tokens and tokenSpawned[tokenName] == nil then
            Wait.frames(function()
                local tokenPos = cardPosition + self.vectUp * 1.1 + self.vectRight
                local tokenRot = self.rotUp
                self:doSpawnTokens({
                    count = card.tokens,
                    position = tokenPos,
                    rotation = tokenRot,
                    name = tokenName,
                })
            end, 1)
            tokenSpawned[tokenName] = tokenName
        end

        ix = ix + 1
    end
end

function ArmyImporter:spawnTacticsDeck()
    local commander = self.data.commander or {}
    local baseCards = {}
    -- Mag the mighty, this is terrible
    if commander.id ~= "10313" then
        baseCards = db.get_baseDeck(self.data.faction)
    end
    local commanderCards = commander.tacticsCards or {}
    local cards = {}
    local filterFromBase = TableUtils.map(commander.cardsToRemove or {}, string.upper)
    if not TableUtils.hasValue(filterFromBase, "ALL") then
        for _, card in pairs(baseCards) do
            if not TableUtils.hasValue(filterFromBase, string.upper(card.name)) then
                table.insert(cards, card)
                table.insert(cards, card)
            end
        end
    end
    for _, card in pairs(commanderCards) do
        table.insert(cards, card)
        table.insert(cards, card)
    end
    self:injectUnitFromTacticscards(cards)
    local positionToSpawn = self.deckLocation.pos
    if SETTINGS["playerCount"] == "2 vs 2" then
        local deckZone = getObjectFromGUID(GUIDS["draw_discard_piles"][self.playerColor])
        if TableUtils.len(TableUtils.filter(deckZone.getObjects(), function(o) return o.type == "Deck" or o.type == "Card" end)) > 0 then
            positionToSpawn = positionToSpawn + Vector({55.7, 0, 0})
        end
    end
    local deck = self:spawnDeckOfCards({
        cards = cards,
        back = tacticsCardBack,
        position = positionToSpawn,
        rotation = self.deckLocation.rot,
        tags = {"TacticsCard"},
    })
    Wait.frames(function() deck.randomize() end, 3)
end


local FACTION_TO_RULES = {
    ["GREYJOY"] = "50801",
}
function ArmyImporter:spawnFactionRules()
    local faction_rules = FACTION_TO_RULES[self.data.faction:upper()]
    if faction_rules ~= nil then
        local data = db.get(faction_rules)
        self:doSpawnCard({
            name = data.name,
            card = {face = data.cardFace, back = data.cardBack or data.cardFace},
            position = self.grid_ncus:getNextPos() + self.vectUp * -4,
            rotation = self.rotUp,
        })
    end
end

ArmyImporter.tacticsToSpawnedUnitIDs = {
    ["THE ENDLESS HORDE"] = {
        unit = "10303",
        attachments = {
            "20304",
        }
    },
    ["DEVOTEES OF THE DRAGON"] = {
        unit = "10714",
        attachments = {},
    },
}
function ArmyImporter:injectUnitFromTacticscards(cards)
    local toSpawn = {}
    local unique = {}
    for _, card in ipairs(cards) do
        local unitIDs = self.tacticsToSpawnedUnitIDs[card.name:upper()]
        if unitIDs ~= nil and unique[card.name] == nil then
            local unit = {
                unit = db.get(unitIDs.unit),
                attachments = TableUtils.map(unitIDs.attachments, function(id) return db.get(id) end)
            }
            local unitDefs = self:createCombatUnitDefinitions(unit)
            local copy = Utils.copy(card)
            copy.back = tacticsCardBack
            unitDefs.attachmentCards[card.name] = copy
            table.insert(self.extraUnits, unitDefs)
            unique[card.name] = true
        end
    end
end

function ArmyImporter:spawnExtraUnits()
    if #self.extraUnits == 0 then
        return
    end
    self.grid_cards:getNextPos()
    for _, unit in ipairs(self.extraUnits) do
        self:_spawnCombatUnit(unit, self.grid_extra, self.grid_cards)
    end
end

function ArmyImporter.initImporters()
    local blueImporter = getObjectFromGUID(GUIDS["army_import"]["Blue"])
    local redImporter = getObjectFromGUID(GUIDS["army_import"]["Red"])
    local imagesBlue = {
        ASOIAFfr = "http://cloud-3.steamusercontent.com/ugc/1753559193956372536/7990491DD0824B06311328AFBB17FE6A0D9F3D30/",
        stats = "http://cloud-3.steamusercontent.com/ugc/1662353234454190393/69E336C641B00F84D81BAFF55D50C4C1CC3E4EA0/",
        builder = "http://cloud-3.steamusercontent.com/ugc/1662353234454212923/B323B9968D5B5A9AEA75B4C7B7E98418A889F98C/",
        raw = "http://cloud-3.steamusercontent.com/ugc/2062136939651616035/32B4167772384DC621405731BF4BA4D8077410FD/"
    }
    -- stats and builder are the same as the blue ones?
    local imagesRed = {
        ASOIAFfr = "http://cloud-3.steamusercontent.com/ugc/1753559193956371988/1ECA11A5653745916ED29EBEAE73A3290A44910D/",
        stats = "http://cloud-3.steamusercontent.com/ugc/1662353234454190393/69E336C641B00F84D81BAFF55D50C4C1CC3E4EA0/",
        builder = "http://cloud-3.steamusercontent.com/ugc/1662353234454212923/B323B9968D5B5A9AEA75B4C7B7E98418A889F98C/",
        raw = "http://cloud-3.steamusercontent.com/ugc/2062136939651615804/56150367A9DC5F09AEFE576D795CD31A065D9424/"
    }
    local armyImporterBlue = ArmyImporter(blueImporter, {
        images = imagesBlue,
        color = "Blue",
        vectUp = Vector(0, 0, 1),
        vectRight = Vector(1, 0, 0),
        rotUp = Vector(0, 180, 0),
        specialTacticsPos = specialTacticsLocations["Blue"],
        gridOrigins = {
            ncus = Vector(46, 2, -25.6),
            combatUnits = Vector(-20, 2.02, -27.80),
            enemy = Vector(25.3, 0.87, -16.1),
            cards = Vector(-20.5, -0.9, -34),
            unitsFromTactics = Vector(34, -0.9, -44.75),
        }
    })

    local armyImporterRed = ArmyImporter(redImporter, {
        images = imagesRed,
        color = "Red",
        vectUp = Vector(0, 0, -1),
        vectRight = Vector(-1, 0, 0),
        rotUp = Vector(0, 0, 0),
        specialTacticsPos = specialTacticsLocations["Red"],
        gridOrigins = {
            ncus = Vector(46, 2, 25.6),
            combatUnits = Vector(20, 2.02, 27.8),
            enemy = Vector(30.5, 0.87, 16.1),
            cards = Vector(20.5, -0.9, 34),
            unitsFromTactics = Vector(34, -0.9, 44.75),
        }
    })
    armyImporterBlue:init()
    armyImporterRed:init()
end

function ArmyImporter:getTokenNameOrDefault(tokenName)
    return tokenName or "Order"
end