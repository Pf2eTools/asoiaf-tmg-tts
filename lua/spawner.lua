local TableUtils = require("lua.utils-table")
local db = require("lua.data-lookup")

local Spawner = {
    _ix = 100000
}
Spawner.__index = Spawner
Spawner.__className = "Spawner"

setmetatable(Spawner, {
    __index = GameObjectClass,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        local this
        if gameObj ~= nil then
            this = setmetatable(GameObjectClass(gameObj, opts.__className), Spawner)
        else
            this = setmetatable({}, Spawner)
        end
        this.vectUp = opts.vectUp
        this.vectRight = opts.vectRight
        this.rotUp = opts.rotUp
        return this
    end
})

function Spawner:shouldSpawnSpecialCard(specialType)
    if specialType == "commander" then
        return false
    elseif specialType == "zone" then
        return false
    end

    return true
end
function Spawner:getSpecialRulesToSpawn(lookup)
    local cardsToSpawn = {}
    if lookup.specialRules == nil then
        return cardsToSpawn
    end

    for _, rulesId in ipairs(lookup.specialRules) do
        local specialRules = db.get(rulesId)
        if self:shouldSpawnSpecialCard(specialRules.specialType) then
            table.insert(cardsToSpawn, {
                name = specialRules.name,
                face = specialRules.cardFace,
                back = specialRules.cardBack
            })
        end
    end

    return cardsToSpawn
end
function Spawner:getSpecialRuleFromType(lookup, type)
    if lookup.specialRules == nil then
        return nil
    end
    for _, rulesId in ipairs(lookup.specialRules) do
        local specialRules = db.get(rulesId)
        if specialRules.specialType == type then
            return specialRules
        end
    end
    return nil
end

-- params = {position, rotation, card}
function Spawner:doSpawnCardAndTokens(params)
    local card = self:doSpawnCard(params)
    if params.card.tokens then
        Wait.frames(function()
            local tokenPos = params.position + self.vectRight + self.vectUp * 1.1
            self:doSpawnTokens({
                count = params.card.tokens,
                position = tokenPos,
                rotation = params.rotation,
                name = params.card.tokenName,
            })
        end, 1)
    end
    return card
end
-- params = {position, rotation, card.face, card.back}
function Spawner:doSpawnCard(params)
    local cardParams = {
        type = "CardCustom",
        position = params.position,
        rotation = params.rotation,
        sound = false
    }
    local newCard = spawnObject(cardParams)
    newCard.setCustomObject({
        face = params.card.face,
        back = params.card.back
    })
    newCard.setName(params.name or params.card.name or "")

    return newCard
end

-- params = {position, rotation, face, width, height, number}
function Spawner:doSpawnDeck(opts)
    opts = opts or {}
    local deckParams = {
        type = "DeckCustom",
        position = opts.position,
        rotation = opts.rotation,
        sound = false
    }
    local newDeck = spawnObject(deckParams)
    newDeck.setCustomObject({
        face = opts.face,
        back = tacticsCardBack,
        width = opts.width or 8,
        height = opts.height or 2,
        number = opts.number or 14
    })
    return newDeck
end

local TOKEN_NAME_TO_URL = {
    ["To the Last!"] = "http://cloud-3.steamusercontent.com/ugc/1002555926636270951/F0956B41C418BCA9036368309D3A2920206D6E61/",
    ["Faith"] = "http://cloud-3.steamusercontent.com/ugc/1007058799833904835/653B9CD9FF67D9BED3BBF4C724616310F24E5E2A/",
    ["Pillage"] = "http://cloud-3.steamusercontent.com/ugc/1646594133298627967/C8EC44EB1280B7FD2E1EA5F7EB70AA74256E6C41/",
    ["Order"] = "http://cloud-3.steamusercontent.com/ugc/1002555774721935452/03148FB43A1F1A8A1D37BE0FF58038DC23F51F0A/",
    ["Wound"] = "http://cloud-3.steamusercontent.com/ugc/1002555926636270951/F0956B41C418BCA9036368309D3A2920206D6E61/",
    ["Panicked"] = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934412348/662E4E1B8F53B40FD30BAD488D39F10C36E77275/",
    ["Vulnerable"] = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934416341/FE20F5A621616D8A89AE739E73723B59FC01D106/",
    ["Weakened"] = "https://steamusercontent-a.akamaihd.net/ugc/1001431421934417557/ACA41623B5DDB7ED7923E92FE7A2E2BB06159B9B/",
}
-- params = {count, position, rotation, image, name}
function Spawner:doSpawnTokens(params)
    for i = 1, params.count do
        local tokenParameters = {
            type = "Custom_Token",
            position = params.position + Vector(0, i * 0.11, 0),
            sound = false,
            scale = {0.5, 1, 0.5},
            rotation = params.rotation
        }

        local customParameters = {
            thickness = "0.1",
            image = params.image or TOKEN_NAME_TO_URL[params.name] or
                "http://cloud-3.steamusercontent.com/ugc/1002555774721935452/03148FB43A1F1A8A1D37BE0FF58038DC23F51F0A/",
            stackable = true
        }

        local token = spawnObject(tokenParameters)
        token.addTag("Token")
        token.setCustomObject(customParameters)
        token.setName(params.name or "Order")
    end
end
-- params = {trayClass, objectData, position, rotation, spawnOptions}
function Spawner:doSpawnCombatUnit(params)
    local unit = params.trayClass:spawn(params.objectData, {
        position = params.position,
        rotation = params.rotation,
        sound = false,
        spawnOptions = params.spawnOptions
    })

    return unit
end
-- params = {objectData, name, color, custom}
function Spawner:doSpawnFigure(params)
    local newFigure = spawnObject(params.objectData)
    newFigure.setName(params.name)
    newFigure.setDescription(params.description)
    newFigure.setGMNotes(params.id)
    newFigure.setColorTint(params.color)
    newFigure.setCustomObject(params.custom)

    return newFigure
end

function Spawner:figureFromLookup(lookup, opts)
    local objectData = {}
    local custom = {}
    local specialTactics
    local description = ""

    if lookup.assetBundle and SETTINGS.use3DMiniatures then
        objectData.type = "Custom_Assetbundle"
        objectData.scale = opts.assetScale -- NCU: {2.6, 2.6, 2.6}
        if lookup.painter then
            description = lookup.name .. " painted by: " .. lookup.painter
        else
            description = lookup.name .. " painted by: unknown"
        end
        custom = {
            assetbundle = lookup.assetBundle,
            type = 1,
            material = 0
        }
    else
        objectData.type = "Figurine_Custom"
        objectData.scale = opts.figureScale -- NCU: {1.75, 1.75, 1.75}
        custom = {
            image = lookup.image
        }
    end

    objectData.name = lookup.fullName

    local specialZone = self:getSpecialRuleFromType(lookup, "zone")
    if specialZone ~= nil then
        specialTactics = {
            name = specialZone.name,
            face = specialZone.cardFace,
            back = specialZone.cardBack
        }
    end

    local cards = self:getUnitCards(lookup)

    return {
        name = lookup.fullName,
        id = lookup.id,
        description = description,
        objectData = objectData,
        custom = custom,
        cards = cards,
        specialTactics = specialTactics
    }
end

function Spawner:getUnitFigureData(lookup)
    local trayClass = self:getTrayClass(lookup.tray)
    local figureData = trayClass:getFigureObjectData(lookup)
    figureData.ColorDiffuse = self.colorLookup[self.selectedColor]
    figureData.Nickname = lookup.fullName
    if figureData.Name == "Custom_Assetbundle" then
        if lookup.painter then
            figureData.Description = lookup.name .. " painted by: " .. lookup.painter
        else
            figureData.Description = lookup.name .. " painted by: unknown"
        end
    else
        figureData.Description = lookup.fullName
    end
    return figureData
end
function Spawner:getCombatUnitSpawnOptions(unitLookup, attachmentLookups)
    local spawnOptions = {
        cost = unitLookup.cost or 0
    }
    -- This is probably not accurate but whatever
    if attachmentLookups then
        for _, attachment in ipairs(attachmentLookups) do
            local cost = attachment.cost or 0
            spawnOptions.cost = spawnOptions.cost + cost
        end
    end

    if unitLookup.maxWounds then
        spawnOptions.woundsPerModel = tonumber(unitLookup.maxWounds)
    end
    if self:getSpecialRuleFromType(unitLookup, "banners") ~= nil then
        spawnOptions.indicesSpecialFigures = { 9, 10, 11, 12 }
    end
    spawnOptions.lookup = unitLookup
    spawnOptions.attachmentLookups = attachmentLookups
    return spawnOptions
end

function Spawner:getTrayClass(type)
    if type == "cavalry" then
        return CavalryTray
    elseif type == "infantry" then
        return InfantryTray
    elseif type == "solo" then
        return SoloTray
    elseif type == "warmachine" then
        return WarmachineTray
    else
        return nil
    end
end

function Spawner:getUnitCards(lookup)
    local cards = self:getSpecialRulesToSpawn(lookup)

    table.insert(cards, {
        name = lookup.fullName,
        face = lookup.cardFace,
        back = lookup.cardBack,
        tokens = lookup.tokens,
        tokenName = lookup.tokenName
    })

    return cards
end

function Spawner:spawnDeckOfCards(params)
    local deck = nil
    for ix, cardInfo in ipairs(params.cards) do
        Spawner._ix = Spawner._ix + 1
        local scale = cardInfo.scale or { x = 1, y = 1, z = 1 }
        local spawned = spawnObjectData({
            data = {
                Transform = {
                    posX = 0,
                    posY = 0,
                    posZ = 0,
                    rotX = 0,
                    rotY = 0,
                    rotZ = 0,
                    scaleX = scale.x,
                    scaleY = scale.y,
                    scaleZ = scale.z
                },
                Name = "Card",
                Nickname = cardInfo.name,
                Description = cardInfo.description,
                GMNotes = params.gm_notes,
                CardID = Spawner._ix * 100,
                Tags = params.tags or {},
                CustomDeck = {
                    [Spawner._ix] = {
                        FaceURL = cardInfo.face,
                        BackURL = cardInfo.back or params.back or cardInfo.face,
                        NumWidth = 1,
                        NumHeight = 1,
                        Type = 0,
                        BackIsHidden = true,
                        UniqueBack = false
                    }
                }
            },
            position = Vector(params.position) + Vector(0, ix * 0.1, 0),
            rotation = params.rotation,
            callback_function = params.callback,
        })
        if deck == nil then
            deck = spawned
        else
            deck = deck.putObject(spawned)
        end
    end
    return deck
end

function Spawner:spawnObjectiveDeck(params)
    return self:spawnDeckOfCards({
        cards = TableUtils.filter(objectiveCards, params.filter),
        back = objectiveCardsBack,
        tags = {"ObjectiveCard"},
        position = params.position,
        rotation = params.rotation,
        callback = params.callback,
    })
end

function Spawner:spawnMissionDeck(params)
    return self:spawnDeckOfCards({
        cards = TableUtils.filter(missionCards, params.filter),
        back = missionCardsBack,
        tags = {"MissionCard"},
        position = params.position,
        rotation = params.rotation,
        callback = params.callback,
    })
end

Spawner.colorLookup = {
    Black = {
        r = 0 / 255,
        g = 0 / 255,
        b = 0 / 255
    },
    Petrol = {
        r = 30 / 255,
        g = 102 / 255,
        b = 112 / 255
    },
    Blue = {
        r = 74 / 255,
        g = 163 / 255,
        b = 165 / 255
    },
    Teal = {
        r = 30 / 255,
        g = 176 / 255,
        b = 153 / 255
    },
    Moss = {
        r = 130 / 255,
        g = 165 / 255,
        b = 153 / 255
    },
    Green = {
        r = 2 / 255,
        g = 125 / 255,
        b = 18 / 255
    },
    Brown = {
        r = 107 / 255,
        g = 56 / 255,
        b = 22 / 255
    },
    Flesh = {
        r = 139 / 255,
        g = 90 / 255,
        b = 90 / 255
    },
    Pink = {
        r = 255 / 255,
        g = 0 / 255,
        b = 110 / 255
    },
    Purple = {
        r = 74 / 255,
        g = 7 / 255,
        b = 132 / 255
    },
    Wine = {
        r = 110 / 255,
        g = 21 / 255,
        b = 57 / 255
    },
    Red = {
        r = 219 / 255,
        g = 22 / 255,
        b = 22 / 255
    },
    Orange = {
        r = 200 / 255,
        g = 92 / 255,
        b = 38 / 255
    },
    Yellow = {
        r = 230 / 255,
        g = 226 / 255,
        b = 43 / 255
    },
    White = {
        r = 255 / 255,
        g = 255 / 255,
        b = 255 / 255
    },
    Eggshell = {
        r = 240 / 255,
        g = 234 / 255,
        b = 214 / 255
    }
}

return Spawner