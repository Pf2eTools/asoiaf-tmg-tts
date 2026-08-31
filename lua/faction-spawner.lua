local Utils = require("lua.utils")
local TableUtils = require("lua.utils-table")
local db = require("lua.data-lookup")

local FACTION_CATEGORIES = {
    ["cmon"] = "CMON - Official",
    ["brew"] = "Homebrew"
}

FactionSpawner = {}
FactionSpawner.__index = FactionSpawner
FactionSpawner.__className = "FactionSpawner"

setmetatable(FactionSpawner, {
    __index = Spawner,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        opts.__className = cls.__className
        local this = setmetatable(Spawner(gameObj, opts), FactionSpawner)
        this.selectedColor = "Orange"
        this.onClick_spawnThrottled = Utils.throttle(this.onClick_spawn, 7)
        this.gridOrigins = opts.gridOrigins
        this.category = FACTION_CATEGORIES.cmon
        return this
    end
})

function FactionSpawner:init()
    self:initUiEventListeners()
    local customAssets = self:getCustomAssets()
    self.gameObj.UI.setCustomAssets(customAssets)
    self:createXmlUi()
    self:initSpawnGrids()
end
function FactionSpawner:initUiEventListeners()
    self:register({"onClick_spawnThrottled", "onClick_clear", "onClick_cat"})
end
function FactionSpawner:createXmlUi()
    local getButton = function(factionMeta)
        return {
            tag = "Button",
            attributes = {
                id = "btn_spawn_"..factionMeta.name,
                iconWidth = 28,
                color = "#FFFFFF00",
                icon = factionMeta.name,
                onclick = "onClick_spawnThrottled(" .. factionMeta.name .. ")",
            },
        }
    end
    local factionsToSpawn = TableUtils.filter(self.factions, function(m) return m.category == self.category end)
    local spawnButtons = TableUtils.map(factionsToSpawn, getButton)
    local grid = {
        {
            tag = "GridLayout",
            attributes = {
                position = "0 0 -30",
                rotation = "0 0 180",
                width = 150,
                cellSize = "30 30",
                padding = "15 15 15 15",
                height = 150,
            },
            children = spawnButtons
        },
        {
            tag = "Button",
            attributes = {
                id = "btn_cat",
                onclick = "onClick_cat",
                position = "0 60 -30",
                rotation = "0 0 180",
                width = 130,
                height = 20,
                text = self.category,
                colors="#000000|rgba(0.3,0.3,0.3,1)|rgba(0.3, 0.3, 0.3, 1.0)|#000000",
                textColor="#FFFFFF"
            }
        },
        {
            tag = "Button",
            attributes = {
                id = "btn_clear",
                onclick = "onClick_clear",
                position = "0 80 -30",
                rotation = "0 0 180",
                width = 130,
                height = 20,
                text = "Clear Area",
                colors="#000000|rgba(0.3,0.3,0.3,1)|rgba(0.3, 0.3, 0.3, 1.0)|#000000",
                textColor="#FFFFFF"
            }
        }
    }
    self.gameObj.UI.setXmlTable(grid)
end
function FactionSpawner:onClick_cat()
    if self.category == FACTION_CATEGORIES.cmon then
        self.category = FACTION_CATEGORIES.brew
    else
        self.category = FACTION_CATEGORIES.cmon
    end

    self:createXmlUi()
end

function FactionSpawner:getCustomAssets()
    local assets = {}

    for _, faction in ipairs(self.factions) do
        table.insert(assets, {name = faction.name, url = faction.image})
    end

    return assets
end

-- This only gets called with throttle
-- params = {player, faction, alt_click}
function FactionSpawner:onClick_spawn(params)
    local player, faction, altClick = unpack(params)
    local found = TableUtils.find(self.factions, function(f) return f.name == faction end)
    if found then
        self.selectedColor = found.color
    end
    self:doClear()
    broadcastToColor("Spawning " .. faction.. "...", player.color)
    local factionUnits = self:getFactionUnits(faction)
    self:initSpawnGrids()
    local co = coroutine.create(function()
        self:doSpawn(factionUnits)
        self:spawnTactics(faction)
        self:spawnSpecials(factionUnits)
    end)
    coroutine.resume(co)
    local ix = 0
    local lagFactor = 3 -- increasing this will make the game lag less but for longer
    Wait.condition(
        function()
            broadcastToColor("Spawned " .. faction.. "!", player.color)
        end,
        function()
            if ix % lagFactor == 0 and coroutine.status(co) == "suspended" then
                coroutine.resume(co)
            end
            ix = ix + 1
            return coroutine.status(co) == "dead"
        end
    )
end
-- call this as a coroutine
function FactionSpawner:doSpawn(factionUnits)
    for _, key in ipairs({"unit", "commander", "attachment", "enemy", "ncu"}) do
        if factionUnits[key] == nil then
            factionUnits[key] = {}
        end
    end

    for _, unit in ipairs(factionUnits.unit) do
        local name = unit.fullName
        if not pcall(function()
            local pos = self.grid_combatUnits:getNextPos()
            local defs = self:combatUnitFromLookup(unit)
            local tray = self:doSpawnCombatUnit({
                position = pos,
                rotation = self.rotUp + Vector(0, 180, 0),
                trayClass = defs.trayClass,
                objectData = defs.objectData,
                spawnOptions = defs.spawnOptions,
            })
            for _, card in pairs(defs.cards) do
                self:doSpawnCardAndTokens({card = card, position = pos + self.vectUp * -4.6, rotation = self.rotUp})
            end
        end) then
            broadcastToAll("Error while spawning " .. name, "Red")
        end
        coroutine.yield()
    end

    for _, cmdr in ipairs(factionUnits.commander) do
        local name = cmdr.fullName
        if not pcall(function()
            local pos = self.grid_commanders:getNextPos()
            local trayClass = self:getTrayClass(cmdr.tray)
            local defs
            if cmdr.type == "ncu" then
                pos = pos + self.vectUp
                defs = self:figureFromLookup(cmdr, {
                    assetScale = {2.6, 2.6, 2.6},
                    figureScale = {1.75, 1.75, 1.75},
                })
            else
                defs = self:figureFromLookup(cmdr, {
                    assetScale = {1, 1, 1},
                    figureScale = {trayClass.figureScale, trayClass.figureScale, trayClass.figureScale},
                })
            end
            defs.objectData.position = pos
            defs.objectData.rotation = self.rotUp
            local fig = self:doSpawnFigure({
                name = defs.name,
                description = defs.description,
                objectData = defs.objectData,
                custom = defs.custom,
                color = self.colorLookup[self.selectedColor]
            })
            if cmdr.type == "ncu" then
                fig.addTag("NCU")
                pos = pos - self.vectUp
            else
                fig.addTag(trayClass.unitModelTag)
                fig.addTag(GenericUnitTray.unitModelTag)
            end
            local cardPos = pos + self.vectUp * -2.6

            local cmdr_tactics
            -- FIXME/TODO: Clear up this garbage
            if name == "Areo Hotah - Captain of The Guard" then
                cmdr_tactics = db.get("30901").tacticsCards
            else
                cmdr_tactics = cmdr.tacticsCards
            end
            local tactics = {}
            for _, card in pairs(cmdr_tactics) do
                table.insert(tactics, card)
                table.insert(tactics, card)
            end
            -- TODO: set flag in data instead of hardcoding it here
            local commanderIsSoloUnit = cmdr.name == "Mag the Mighty" or cmdr.name == "Varamyr Sixskins"
            -- Spawn the unit card first: its size gets shrunk to the size of the cards above
            if commanderIsSoloUnit then
                for ix, card in pairs(defs.cards) do
                    self:doSpawnCardAndTokens({card = card, position = cardPos + Vector(0, 0.05 * ix, 0), rotation = self.rotUp})
                end
                self:spawnDeckOfCards({
                    cards = tactics,
                    back = tacticsCardBack,
                    position = cardPos + Vector(0, 0.1, 0),
                    rotation = self.rotUp,
                    tags = {"TacticsCard"},
                })
            -- normally we want the attachment card ontop
            else
                self:spawnDeckOfCards({
                    cards = tactics,
                    back = tacticsCardBack,
                    position = cardPos,
                    rotation = self.rotUp,
                    tags = {"TacticsCard"},
                })
                for ix, card in pairs(defs.cards) do
                    self:doSpawnCardAndTokens({card = card, position = cardPos + Vector(0, 0.5 + 0.05 * ix, 0), rotation = self.rotUp})
                end
            end
        end) then
            broadcastToAll("Error while spawning " .. name, "Red")
        end
        coroutine.yield()
    end

    for _, attachmentType in ipairs({"attachment", "enemy"}) do
        for _, attch in ipairs(factionUnits[attachmentType]) do
            local name = attch.fullName
            if not pcall(function()
                local pos = self.grid_attachments:getNextPos()
                local trayClass = self:getTrayClass(attch.tray)
                local defs = self:figureFromLookup(attch, {
                    assetScale = {1, 1, 1},
                    figureScale = {trayClass.figureScale, trayClass.figureScale, trayClass.figureScale},
                })
                defs.objectData.position = pos
                defs.objectData.rotation = self.rotUp
                local fig = self:doSpawnFigure({
                    name = defs.name,
                    description = defs.description,
                    objectData = defs.objectData,
                    custom = defs.custom,
                    color = self.colorLookup[self.selectedColor]
                })
                fig.addTag(trayClass.unitModelTag)
                fig.addTag(GenericUnitTray.unitModelTag)
                local cardPos = pos + self.vectUp * -2.6
                for ix, card in pairs(defs.cards) do
                    self:doSpawnCardAndTokens({card = card, position = cardPos + Vector(0, 0.05, 0) * ix, rotation = self.rotUp})
                end
            end) then
                broadcastToAll("Error while spawning " .. name, "Red")
            end
        end
        coroutine.yield()
    end

    for _, ncu in ipairs(factionUnits.ncu) do
        local name = ncu.fullName
        if not pcall(function()
            local pos = self.grid_ncus:getNextPos()
            local defs = self:figureFromLookup(ncu, {
                assetScale = {2.6, 2.6, 2.6},
                figureScale = {1.75, 1.75, 1.75},
            })

            defs.objectData.position = pos
            defs.objectData.rotation = self.rotUp
            local fig = self:doSpawnFigure({
                name = defs.name,
                id = defs.id,
                description = defs.description,
                objectData = defs.objectData,
                custom = defs.custom,
                color = self.colorLookup[self.selectedColor]
            })
            fig.addTag("NCU")

            local cardPos = pos + self.vectUp * -3.6
            if defs.specialTactics then
                local tacticsBoard = self:doSpawnCard({
                    card = defs.specialTactics,
                    position = cardPos,
                    rotation = self.rotUp,
                })
                if(tacticsBoard) then
                    tacticsBoard.setSnapPoints({{
                        position = {0, 0, -0.85},
                        rotation = {0, 0, 0},
                        rotation_snap = true
                    }})
                end
            end
            local lastSpawned = nil
            for ix, card in pairs(defs.cards) do
                lastSpawned = self:doSpawnCardAndTokens({card = card, position = cardPos + Vector(0, 0.05, 0) * ix, rotation = self.rotUp})
            end
            lastSpawned.addTag("NCUcard")
        end) then
            broadcastToAll("Error while spawning " .. name, "Red")
        end

        coroutine.yield()
    end
end
function FactionSpawner:spawnTactics(faction)
    local baseCards = db.get_baseDeck(faction)
    local cards = {}
    for _, card in pairs(baseCards) do
        table.insert(cards, card)
        table.insert(cards, card)
    end
    local deck = self:spawnDeckOfCards({
        cards = cards,
        back = tacticsCardBack,
        position = self.grid_commanders:getNextPos() + self.vectUp * -2.6,
        rotation = self.rotUp,
        tags = {"TacticsCard"},
    })
end
function FactionSpawner:spawnSpecials(factionUnits)
    local cards = factionUnits.special or {}
    local spawned = self:spawnDeckOfCards({
        cards = TableUtils.map(cards, function(c) return {name = c.name, face = c.cardFace, back = c.cardBack} end),
        position = self.grid_commanders:getNextPos() + self.vectUp * -2.6,
        rotation = self.rotUp,
    })
end

function FactionSpawner:combatUnitFromLookup(lookup)
    local figures = {}
    local unitFigure = {}
    local trayClass = self:getTrayClass(lookup.tray)
    local name = lookup.fullName

    local specialFigures = self:getSpecialRuleFromType(lookup, "banners")
    for idx = 1, (trayClass.rows * trayClass.columns), 1 do
        if specialFigures ~= nil and idx > 8 then
            unitFigure = self:getUnitFigureData(specialFigures)
            table.insert(figures, unitFigure)
        else
            unitFigure = self:getUnitFigureData(lookup)
            table.insert(figures, unitFigure)
        end
    end

    for idx, figure in ipairs(figures) do
        figure.Transform.posX = figure.Transform.posX + trayClass.snapPoints[idx].Position.x
        figure.Transform.posY = figure.Transform.posY + trayClass.snapPoints[idx].Position.y
        figure.Transform.posZ = figure.Transform.posZ + trayClass.snapPoints[idx].Position.z
        figure.Memo = idx
    end

    local cards = self:getUnitCards(lookup)

    local objectData = trayClass:getObjectData({
        ChildObjects = figures,
        Nickname = name,
        color = self.colorLookup[self.selectedColor]
    })

    local spawnOptions = self:getCombatUnitSpawnOptions(lookup, nil)

    return {
        objectData = objectData,
        spawnOptions = spawnOptions,
        cards = cards,
        trayClass = trayClass
    }
end

function FactionSpawner:getFactionUnits(faction)
    local factionLookup = db.get_faction(faction)
    local factionUnits = {}
    for _, item in pairs(factionLookup) do
        local type = item.type
        if item.enemy then
            type = "enemy"
        end
        if item.cmdr then
            type = "commander"
        end
        if type ~= nil then
            type = type:lower()
            if factionUnits[type] == nil then
                factionUnits[type] = {}
            end
            table.insert(factionUnits[type], item)
        end
    end
    return factionUnits
end

function FactionSpawner:onClick_clear()
    self:doClear()
end

function FactionSpawner:doClear()
    self.grid_combatUnits:clear()
    self.grid_commanders:clear()
    self.grid_attachments:clear()
    self.grid_ncus:clear()
end


function FactionSpawner.initSpawners()
    local blueSpawner = getObjectFromGUID(GUIDS["faction_spawner"]["Blue"])
    local redSpawner = getObjectFromGUID(GUIDS["faction_spawner"]["Red"])
    local blueObj = FactionSpawner(blueSpawner, {
        vectUp = Vector(0, 0, 1),
        vectRight = Vector(1, 0, 0),
        rotUp = Vector(0, 180, 0),
        gridOrigins = {
            ncus = Vector(-137, 2.5, -50),
            combatUnits = Vector(-136, 2.5, -5),
            commanders = Vector(-137, 2.5, -43),
            attachments = Vector(-137, 2.5, -32),
        }
    })
    blueObj:init()
    local redObj = FactionSpawner(redSpawner, {
        vectUp = Vector(0, 0, -1),
        vectRight = Vector(-1, 0, 0),
        rotUp = Vector(0, 0, 0),
        gridOrigins = {
            ncus = Vector(-137, 2.5, 50),
            combatUnits = Vector(-136, 2.5, 5),
            commanders = Vector(-137, 2.5, 43),
            attachments = Vector(-137, 2.5, 32),
        }
    })
    redObj:init()
end

function FactionSpawner:initSpawnGrids()
    self.grid_ncus = Grid({
        origin = self.gridOrigins.ncus,
        rowOffset = self.vectUp * -8,
        columnOffset = Vector(1, 0, 0) * 3.6,
        columns = 12,
        rows = 2,
    })
    self.grid_combatUnits = Grid({
        origin = self.gridOrigins.combatUnits,
        rowOffset = self.vectUp * -9,
        columnOffset = Vector(1, 0, 0) * 5.7,
        columns = 10,
        rows = 3,
    })
    self.grid_commanders = Grid({
        origin = self.gridOrigins.commanders,
        rowOffset = self.vectUp * -6,
        columnOffset = Vector(1, 0, 0) * 2.7,
        columns = 18,
        rows = 1,
    })
    self.grid_attachments = Grid({
        origin = self.gridOrigins.attachments,
        rowOffset = self.vectUp * -6,
        columnOffset = Vector(1, 0, 0) * 2.7,
        columns = 20,
        rows = 2,
    })
end

FactionSpawner.factions = {{
    name = "Baratheon",
    color = "Yellow",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258792619/3698BCD212EB474C7A472F3F4ECF5004DD265051/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Free Folk",
    color = "Moss",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258792766/8DFF483EA4FCA1D4414AF1CC47BF12C4C4FA6662/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Greyjoy",
    color = "Teal",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258793056/CFEF90BC5685E295F8B80FB712EC7EAB61AAE5A3/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Lannister",
    color = "Red",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258793201/BC3040E0DF34BFC7D2DF5F0496A3E4569907D258/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Martell",
    color = "Orange",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/assets/warcouncil/martell/crest-shadow.png",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Bolton",
    color = "Flesh",
    image = "http://cloud-3.steamusercontent.com/ugc/2056508073735152948/DE662737BECC946F75A7158461940AD235CB2DDD/",
    category = FACTION_CATEGORIES.cmon
},{
    -- Ok, but only because I'm feeling nice
    -- you do not like neutral brown? ;-)
    name = "Neutral",
    color = "Brown",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258793607/BF146AF2F7239EF778B2FB727417BDE1939332DC/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Night's Watch",
    color = "Black",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258793854/8ED3B43E977369528F475F4FBCA47118CADAED63/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Stark",
    color = "Petrol",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258794007/20908BB8308BA30A66CFFF7D9FD832702251C482/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Targaryen",
    color = "Wine",
    image = "http://cloud-3.steamusercontent.com/ugc/1937136685258794245/F589638EAAA1AE6FA8797E452BB2D84627239C25/",
    category = FACTION_CATEGORIES.cmon
}, {
    name = "Brotherhood",
    color = "Green",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/assets/warcouncil/brotherhood/crest-shadow.png",
    category = FACTION_CATEGORIES.cmon
},
-- CUSTOM FACTIONS BELOW
{
    name = "Tully",
    color = "Blue",
    author = "Kullvox",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/kullvox-tully/tully/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Tyrell",
    color = "Green",
    author = "Kullvox",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/kullvox-tyrell/tyrell/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Blackfyre",
    color = "Black",
    author = "HotShot",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/hotshot-blackfyre/blackfyre/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Others",
    color = "White",
    author = "BoardManGaming",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/boardmangaming-others/others/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Arryn",
    color = "Blue",
    author = "BoardManGaming",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/boardmangaming-arryn/arryn/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Hotshot-Targaryen",
    color = "Wine",
    author = "HotShot",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/hotshot-targaryen/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
}, {
    name = "Hotshot-Baratheon",
    color = "Yellow",
    author = "HotShot",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/refs/heads/master/custom/assets/hotshot-baratheon/crest-shadow.png",
    category = FACTION_CATEGORIES.brew
},
{
    name = "hnctatteredprince",
    color = "Brown",
    author = "HitsAndCrits",
    image = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/ba3a594928c6933b05ef170e332169799c412865/custom/portraits/hnc-tattered-prince/round/tatterd_prince_ncu.png",
    category = FACTION_CATEGORIES.brew
},
}