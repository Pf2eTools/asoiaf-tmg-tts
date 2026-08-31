GUIDS = {}
GUIDS["tactics_tile"] = "dd67e3"
GUIDS["tactics_zones"] = {}
GUIDS["tactics_zones"]["crown"] = "571d62"
GUIDS["tactics_zones"]["moneyBag"] = "47f62a"
GUIDS["tactics_zones"]["letter"] = "923508"
GUIDS["tactics_zones"]["swords"] = "d08654"
GUIDS["tactics_zones"]["horse"] = "a94fde"
GUIDS["tactics_zones"]["Blue"] = nil
GUIDS["tactics_zones"]["Red"] = nil

GUIDS["tactics_round"] = {}
GUIDS["tactics_round"][1] = "c54ddd"
GUIDS["tactics_round"][2] = "54a335"
GUIDS["tactics_round"][3] = "c572b8"
GUIDS["tactics_round"][4] = "c353ba"
GUIDS["tactics_round"][5] = "44ccaf"
GUIDS["tactics_round"][6] = "2752da"

GUIDS["tactics_first_player"] = {}
GUIDS["tactics_first_player"]["Blue"] = "57ce4d"
GUIDS["tactics_first_player"]["Red"] = "820988"
GUIDS["first_player_throne"] = "60f2a3"
GUIDS["first_player_standee"] = "911ed9"

GUIDS["ncu_zone_resting"] = {}
GUIDS["ncu_zone_resting"]["Blue"] = "64db7d"
GUIDS["ncu_zone_resting"]["Red"] = "c3e2d1"

GUIDS["vp_counter"] = {}
GUIDS["vp_counter"]["Blue"] = "dff01a"
GUIDS["vp_counter"]["Red"] = "beef90"

GUIDS["maester"] = "23eb11"
GUIDS["round_marker"] = "9e5a3d"
-- {38, 1.1, 0}

GUIDS["place_gamemode_zone"] = "24ffcd"
GUIDS["place_gamemode_tile"] = "f31926"

GUIDS["army_import"] = {}
GUIDS["army_import"]["Blue"] = "de68a4"
GUIDS["army_import"]["Red"] = "5cbcbe"

GUIDS["faction_spawner"] = {}
GUIDS["faction_spawner"]["Blue"] = "d769cd"
GUIDS["faction_spawner"]["Red"] = "515fe8"

GUIDS["dice_tray"] = {}
GUIDS["dice_tray"]["Blue"] = "4f5443"
GUIDS["dice_tray"]["Red"] = "916e27"
GUIDS["dice_tray_zone"] = {}
GUIDS["dice_tray_zone"]["Blue"] = "15ecbd"
GUIDS["dice_tray_zone"]["Red"] = "0b9c6e"

GUIDS["draw_discard_piles"] = {}
GUIDS["draw_discard_piles"]["Blue"] = "bc5507"
GUIDS["draw_discard_piles"]["Red"] = "8745ce"
GUIDS["draw_discard_piles"]["Orange"] = nil
GUIDS["draw_discard_piles"]["Teal"] = nil

GUIDS["hand_zones"] = {}
GUIDS["hand_zones"]["Blue"] = "29988f"
GUIDS["hand_zones"]["Red"] = "940924"
GUIDS["hand_zones"]["Orange"] = nil
GUIDS["hand_zones"]["Teal"] = nil

GUIDS["deck_tiles"] = {}
GUIDS["deck_tiles"]["Blue"] = "f60af8"
GUIDS["deck_tiles"]["Red"] = "581f12"
GUIDS["deck_tiles"]["Orange"] = nil
GUIDS["deck_tiles"]["Teal"] = nil


GUIDS["dead_units"] = {}
GUIDS["dead_units"]["Blue"] = "c32e4e"
GUIDS["dead_units"]["Red"] = "45cbe9"

GUIDS["battleMat"] = "e4987b"
GUIDS["background"] = "56381b"

GUIDS["bags_terrain"] = {
    "4a6ff3", "6df675", "fed4b4", "3feebf", "811a2b", "326287", "8d7bc0", "b81853", "3bc68a",
    "18eb29", "671c66", "ea9e4c", "443d45", "f2ee5f"
}
GUIDS["bag_objective"] = "18eb29"

GUIDS["terrain"] = {
    ["Weirwood"] = "3bc68a",
    ["CorpsePile"] = "6df675",
    ["CastleWall"] = "443d45",
}

GUIDS["bags_tokens"] = {
    "df37de", "469e26", "112636", "534ac9", "8e5aff", "9a794c", "9fe498", "1eb7a5",
    "9dcc74", "27cc14", "fc8227", "440187", "ab22d6", "62c7ab", "dd67de", "a765d6"
}

GUIDS["CUSTOM_SPAWNER"] = "baf00e"

specialTacticsLocations = {}
specialTacticsLocations["Blue"] = Vector(39.7, 0.76, -19.60)
specialTacticsLocations["Red"] = Vector(39.7, 0.76, 19.60)
tagSpecialTactics = "SpecialTactics"

battleMatLookUp = {
    ["4x4"] = {},
    ["5x4"] = {},
    ["6x4"] = {}
}
battleMatLookUp["4x4"]["Field of Battle"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825386132/55A04202B47867FF44E36A6CE8CEF3CFADE1185D/", rulerTint="White"}
battleMatLookUp["4x4"]["Blackwater Bay"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825385859/978BC01BA29A9573AC2EBEDD9E3A4E5F76206EDC/", rulerTint="Red"}
battleMatLookUp["4x4"]["Mummers Ford"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825386474/F247895BFE554937FC9BD0A27D6B8780834F849A/", rulerTint="White"}
battleMatLookUp["4x4"]["The Wall"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825387058/A70B245F6FE1D9A2567E871D01E26E0A0BCB1D77/", rulerTint="Black"}
battleMatLookUp["4x4"]["At the Wall"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825385331/5125F49F2CC94EF9C611B4F1C8D6931A41D7B2A0/", rulerTint="Brown"}
battleMatLookUp["4x4"]["The Shore"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058742755825386763/23E31F2834D2691CA0D40FEA6252DE701D67B656/", rulerTint="Red"}
battleMatLookUp["4x4"]["Bloody Dawn"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2422446158431490573/C201EF6BBB92F670D4C6971AE2410356670332BC/", rulerTint="White"}
battleMatLookUp["4x4"]["War of the North"] = {image="https://steamusercontent-a.akamaihd.net/ugc/46828747827207895/7E92D11B5AFF55F370838DCFA9700A6FB0D3D662/", rulerTint="Orange"}
battleMatLookUp["5x4"]["Field of Battle 5x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386937593/43B488E394D09B47F5B72DC7A1F5326B36C4543F/", rulerTint="White"}
battleMatLookUp["5x4"]["At the Wall 5x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386937247/93236346597D110A3F305CAC4824FB2AE7DFA436/", rulerTint="Brown"}
battleMatLookUp["5x4"]["The Shore 5x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386937884/D0474DEBEB8C4FC89874C3B0DA75BD630286877A/", rulerTint="Red"}
battleMatLookUp["6x4"]["Field of Battle 6x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386887908/DC063D7411BC53D55A831D4EAB87B80A42FD0B05/", rulerTint="White"}
battleMatLookUp["6x4"]["At the Wall 6x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386887664/0BB8F79D86D27BF9162A6C5B93B6D5F138880D67/", rulerTint="Brown"}
battleMatLookUp["6x4"]["The Shore 6x4"] = {image="https://steamusercontent-a.akamaihd.net/ugc/2058745927386888130/D65613A214DCA65D742B724275E9287CF80CBC3F/", rulerTint="Red"}


colorsLookUp = {}
colorsLookUp["White"] = "White" --consider using hex codes to increase number of available colors
colorsLookUp["Brown"] = "Brown"
colorsLookUp["Red"] = "Red"
colorsLookUp["Orange"] = "Orange"
colorsLookUp["Yellow"] = "Yellow"
colorsLookUp["Green"] = "Green"
colorsLookUp["Teal"] = "Teal"
colorsLookUp["Blue"] = "Blue"
colorsLookUp["Purple"] = "Purple"
colorsLookUp["Pink"] = "Pink"
colorsLookUp["Grey"] = "Grey"
colorsLookUp["Black"] = "Black"

backgroundLookUp = {}
backgroundLookUp["Open Ruin"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881101297/C7A58E17F4B28F1FB667E354BCA3806BECFF7A9F/", rotation={0, 270, 0}}
backgroundLookUp["Mountain Top"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881086403/D1CBC840503CE4C1DCD0018E4F35C32CAAB9A055/", rotation={0, 270, 0}}
backgroundLookUp["Misty Mountain"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881099175/485A3B1B74DE125454A0D477B084D7CB97C0F713/", rotation={0, 165, 0}}
backgroundLookUp["Cloister"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881096518/064D4B6404E1CC2ACFB6F309C420E480FABAE325/", rotation={0, 270, 0}}
backgroundLookUp["Bridge"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881398404/D7B4BFF439496ECDD0F860A07B6AD42AFEDEBAB7/", rotation={12, 270, 0}}
backgroundLookUp["Village Square"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881400192/A4989743B63E4D7727B83080EAB399451C3D482B/", rotation={0, 90, 0}}
backgroundLookUp["Balkony"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881396933/5BBEF364A8167830228DCF2372374196D2D3781B/", rotation={0, 270, 0}}
backgroundLookUp["Ship"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881106832/89E340A31C8EEC0B2A4E2C30F00D2713D939D00A/", rotation={0, 270, 0}}
backgroundLookUp["Cosy Room"] = {diffuse="https://steamusercontent-a.akamaihd.net/ugc/1645461720881104500/0867862B50B1E0B46BA934B857E4685492D034DE/", rotation={0, 270, 0}}


battleMatNames = {"Field of Battle", "Blackwater Bay", "Mummers Ford", "The Wall", "At the Wall", "The Shore"}
backgroundNames = {"Background: Open Ruin", "Background: Mountain Top", "Background: Misty Mountain",
                   "Background: Cloister", "Background: Bridge", "Background: Village Square", "Background: Balkony",
                   "Background: Ship", "Background: Cosy Room"}
diceLookUp = {}
trayLookUp = {}
ncuPositions = {}
doneLoading = false
firstPlayerColor = "Red"
currentRound = 1


unitUiAssets = {{
    name = "ActivationOverlay",
    url = "https://steamusercontent-a.akamaihd.net/ugc/1798600612419690176/2592C0F4441B01742F06742C480F6F2ED53CD822/"
}, {
    name = "PanickedOverlay",
    url = "https://steamusercontent-a.akamaihd.net/ugc/1798600612419690281/B4980433845B85C475AD403DCCC313A19205D05F/"
}, {
    name = "VulnerableOverlay",
    url = "https://steamusercontent-a.akamaihd.net/ugc/1798600612419690376/D9411C24BC4838C66F9BF2A98E6C8E08CA3F8EA8/"
}, {
    name = "WeakenedOverlay",
    url = "https://steamusercontent-a.akamaihd.net/ugc/1798600612419690504/8E80D72E1DD72A067FCCD953E6E51BD582087B30/"
}, {
    name = "BlankOverlay",
    url = "https://steamusercontent-a.akamaihd.net/ugc/1747932661540934637/818D1E591FA2799909338E12296782347F692CA1/"
}}


missionCards = {
    ["1"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323879708/269E04871C5A4627B31A253845D39CD59D4568B1/",
        name = "M1: Center Objective",
        description = ""
    },
    ["2"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323879772/A4E9636DD7AE25DB657C9DB68D5E33A4DD5B17B3/",
        name = "M2: Swords/Horse",
        description = "",
    },
    ["3"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323879837/E186E433A196DF0C6735782FE6888BF6D0D2B814/",
        name = "M3: Swords/Letters",
        description = "",
    },
    ["4"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323879908/D04AD82BAB7E1ACA61F452C83902BA984D574B50/",
        name = "M4: Tactics Board",
        description = "",
    },
    ["5"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323879984/E1E5911B8872D5392B04E2A5A89BC73C575F868F/",
        name = "M5: Kill Commander",
        description = "",
    },
    ["6"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880047/F03E4FEBF35A56EBB9BB4435106B00A9764666E3/",
        name = "M6: Enemy Deployment",
        description = "",
    },
    ["7"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880125/D66BD56B5DA5644DAB4C701BFA7471C9A2BBA2F5/",
        name = "M7: Engaged Ranks",
        description = "",
    },
    ["8"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880197/B512CC7244F59C638559E73C34F15B06049F9406/",
        name = "M8: Condition Tokens",
        description = "",
    },
    ["9"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880274/5548E90104898687AB28DFD800FBCD0A5199CB80/",
        name = "M9: Revenge",
        description = "",
    },
    ["10"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880356/2DD46978295B5DAED42BFD780C4CD5E3FFF7FD25/",
        name = "M10: Opponent Objectives",
        description = "",
    },
    ["11"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880434/FDA769F6EC1CA89589EF74315EE9490D1AE63A15/",
        name = "M11: Steal First",
        description = "",
    },
    ["12"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880501/60273B745B7265454858055BE8D6C8752BE1A4AF/",
        name = "M12: All Objectives",
        description = "",
    },
}
missionCardsBack = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323880564/6ADE1B6016FECD5A746F476865A58F0CA2CFC3F3/"

objectiveCards = {
    ["1"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890028/8D0AA7B7F61DC07259AD0880FB38A72FD1F663A2/",
        name = "Objective - Heal When Scoring",
        description = "When you score points from this Objective, 1 friendly unit in Long Range of the unit Controlling this Objective restores 1 Wound, +1 Wound for each of itsdestroyed ranks.",
    },
    ["2"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890104/30F552DC4AD72E47D60AEA36302FFEE5301452CB/",
        name = "Objective - Shift When Scoring",
        description = "When you score points from this Objective, 1 friendly unit in Long Range of the unit Controlling this Objective may shift 3\".",
    },
    ["3"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890184/EE595223BCDD334F5F8B9596B4910E72CDF1C5D0/",
        name = "Objective - Panick When Scoring",
        description = "When you score points from this Objective, 1 enemy in Long Range of the unit Controlling this Objective becomes Panicked.",
    },
    ["4"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890251/20352325F457935767DC3340CFC35B0D544D7443/",
        name = "Objective - Vulnerable When Scoring",
        description = "When you score points from this Objective, 1 enemy in Long Range of the unit Controlling this Objective becomes Vulnerable.",
    },
    ["5"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890315/54B67B9C714FFA050EB00DD44CCC1EE25B604D46/",
        name = "Objective - +1 Card While Controlling",
        description = "While you Control this Objective, you gain +1 Tactics Hand size, and draw +1 card when refilling your hand.",
    },
    ["6"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890376/94C1631C989FCB17B943C62A95E55C77A640CFB9/",
        name = "Objective - Sundering While Controlling",
        description = "While Controlling this Objective, this unit's Melee Attacks gain Sundering.",
    },
    ["7"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890437/9D4DFC191AC4E4F4E6D7BB80BBA62E7230B255EF/",
        name = "Objective - Vicious While Controlling",
        description = "While Controlling this Objective, this unit's Melee Attacks gain Vicious.",
    },
    ["8"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890504/00A693943535BE6DE6F1240F5FB23ACE432A98CF/",
        name = "Objective - Precision While Controlling",
        description = "While Controlling this Objective, this unit's Melee Attacks gain Precision.",
    },
    ["9"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890587/9003DD4D843E786BC932E4459DC69F8929CCA101/",
        name = "Objective - Weakened While Controlling",
        description = "While Controlling this Objective, when this unit is performing a Melee Attack, before resolving that Attack, the Defender becomes Weakened.",
    },
    ["10"] = {
        face = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890733/0EABDA866897E08EF5BCC5765B56DFF668647358/",
        name = "Objective - Max Dice While Controlling",
        description = "While Controlling this Objective, this unit always rolls its highest Attack Die Value.",
    },
}
objectiveCardsBack = "https://steamusercontent-a.akamaihd.net/ugc/2072257990323890796/219F7F1E123C42DFF58A1BF1B8756D9489B423C5/"

tacticsCardBack = "https://steamusercontent-a.akamaihd.net/ugc/786378723752096342/8B70BD5C3F78C9C5C124F529E4447CC8C1621686/"