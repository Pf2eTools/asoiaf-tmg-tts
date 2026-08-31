import re
import subprocess
from scripts.save import get_documents_path
from song_data import *


def escape(string):
    return re.sub(r"\"", "\\\"", string)


def get_repo_url(path):
    return f"{DATA_REPO_BASE_URL}{COMMIT_HASH}/{path}"


DATA_KEYS = [
    "tactics",
    "attachment",
    "unit",
    "ncu",
    "special"
]
CORE_FACTIONS = [f for f in FACTIONS]
ALL_FACTIONS = [f for f in FACTIONS]


def get_tray_ix(tray):
    match tray:
        case "infantry" | "none":
            return 1
        case "cavalry":
            return 2
        case "warmachine" | "siegeengine":
            return 3
        case "solo":
            return 4
    raise "Unknown tray"


def gen_lookup(data: SongDataCollection, is_custom_patch=False, ref_cards=None):
    is_custom = data.meta.id not in FACTIONS
    is_custom_of_base_faction = is_custom and not data.factions and not is_custom_patch
    id_prefix = "" if not is_custom else f"{data.meta.pre or data.meta.id}-"
    if is_custom_patch:
        is_custom = True
        id_prefix = ""
    lang = data.meta.language or "en"

    out_str = ""
    with open("./assets/3d/scans/units.json") as uj:
        map_3d = json.load(uj)
    with open("./assets/3d/scans/assetbundles.json") as ab:
        asset_bundles = json.load(ab)

    basedecks = {}
    for ent in data.tactics:
        faction = ent.faction if not is_custom_of_base_faction else re.sub(r"\W", "", data.meta.id)
        if ent.commander is None:
            basedecks[faction] = basedecks.get(faction, [])
            basedecks[faction].append(f'"{id_prefix}{ent.id}"')
        out_str += f'\t_i("{lang}", 0, {{\n'
        out_str += f'\t\tid = "{id_prefix}{ent.id}",\n'
        out_str += f'\t\tname = "{escape(ent.name)}",\n'
        if lang == "en":
            # FIXME
            out_str += f'\t\t_a = {ALL_FACTIONS.index(faction) + 1},\n'
        out_str += f'\t\t_y = {DATA_KEYS.index("tactics") + 1},\n'
        if is_custom:
            out_str += f'\t\tface = "{get_repo_url(f"custom/generated/{data.meta.id}/{ent.id}.jpg")}"\n'

        out_str += "\t})\n"
    if lang == "en" and not is_custom_patch:
        for basedeck_faction, basedeck in basedecks.items():
            out_str += f'\t_b["{basedeck_faction.upper()}"] = {{{", ".join(basedeck)}}}\n'

    def parse(entities, key):
        parsed = ""
        entity: SongDataUnit
        for entity in entities:
            # The high senechal
            if entity.id == "30404":
                continue

            parsed += f'\t_i("{lang}", 1, {{\n'
            parsed += f'\t\tid = "{id_prefix}{entity.id}",\n'
            parsed += f'\t\tname = "{escape(entity.name)}",\n'
            if entity.title:
                parsed += f'\t\tsubname = "{escape(entity.title)}",\n'

            parsed += f'\t\tcost = {entity.cost or 0},\n'

            if is_custom:
                parsed += f'\t\tcardFace = "{get_repo_url(f"custom/generated/{data.meta.id}/{entity.id}.jpg")}",\n'
                parsed += f'\t\tcardBack = "{get_repo_url(f"custom/generated/{data.meta.id}/{entity.id}b.jpg")}",\n'

            if os.path.isfile(f"{LOCAL_DATA_REPO_PATH}/custom/portraits/{data.meta.id}/standees/{entity.id}.jpg"):
                parsed += f'\t\timage = "{get_repo_url(f"custom/portraits/{data.meta.id}/standees/{entity.id}.jpg")}",\n'
                parsed += f'\t\tportrait = "{get_repo_url(f"custom/portraits/{data.meta.id}/round/{entity.id}.png")}",\n'

            if lang != "en":
                parsed += "\t})\n"
                continue

            fac = entity.faction if not is_custom_of_base_faction else re.sub(r"\W", "", data.meta.id)
            parsed += f'\t\t_a = {ALL_FACTIONS.index(fac) + 1},\n'
            parsed += f'\t\t_y = {DATA_KEYS.index(key) + 1},\n'
            if key != "ncu":
                tray_ix = get_tray_ix(entity.tray)
                parsed += f'\t\t_r = {tray_ix},\n'

            if entity.commander:
                parsed += f'\t\tcmdr = true,\n'
            if isinstance(entity, SongDataAttachment) and entity.enemy:
                parsed += f'\t\tenemy = true,\n'

            if map_3d.get(entity.id):
                asset_info = asset_bundles.get(map_3d[entity.id])
                if asset_info is None:
                    raise Exception(f"Object {entity.id} has missing assetbunlde info")
                if asset_info["painter"] is None:
                    raise Exception(f"Object {entity.id} has missing painter info")
                parsed += f'\t\tassetBundle = "{asset_info["url"]}",\n'
                parsed += f'\t\tpainter = "{asset_info["painter"]}",\n'

            if entity.tokens:
                number = entity.tokens.number
                tokenName = "To the Last!" if entity.tokens.name == "wound" else entity.tokens.name.capitalize()
                if entity.tokens.number:
                    parsed += f'\t\ttokens = {number},\n'
                if tokenName and tokenName != "Order":
                    parsed += f'\t\ttokenName = "{tokenName}",\n'
            if entity.tactics:
                cards_str = ", ".join([f'"{id_prefix}{t}"' for t in entity.tactics])
                parsed += f'\t\t_t = {{{cards_str}}},\n'
                # FIXME: This is pretty awful
                cards_to_remove = []
                for t in entity.tactics:
                    tactics_search = data.tactics + (ref_cards or [])
                    tactics = next((tc for tc in tactics_search if tc.id == t), None)
                    if tactics is None or tactics.remove is None:
                        continue
                    to_remove = next((tc for tc in tactics_search if tc.id == tactics.remove), None)
                    if to_remove is not None:
                        cards_to_remove.append(to_remove.name)

                if cards_to_remove:
                    cards_to_remove_str = ", ".join([f'"{escape(card)}"' for card in cards_to_remove])
                    parsed += f'\t\tcardsToRemove = {{{cards_to_remove_str}}},\n'

            if entity.rules:
                rules = ", ".join([f'"{id_prefix}{r}"' for r in entity.rules])
                parsed += f'\t\tspecialRules = {{{rules}}},\n'

            if isinstance(entity, SongDataUnit) and entity.wounds:
                parsed += f'\t\tmaxWounds = {entity.wounds},\n'
            parsed += "\t})\n"

        return parsed

    out_str += parse(data.unit, "unit")
    out_str += parse(data.attachment, "attachment")
    out_str += parse(data.ncu, "ncu")

    for ent in data.special:
        out_str += f'\t_i("{lang}", 2, {{\n'
        out_str += f'\t\tid = "{id_prefix}{ent.id}",\n'
        out_str += f'\t\tname = "{escape(ent.name)}",\n'
        out_str += f'\t\tspecialType = "{ent.category}",\n'
        if ent.category == "banners":
            out_str += f'\t\t_r = {get_tray_ix("infantry")},\n'
        faction = ent.faction if not is_custom_of_base_faction else re.sub(r"\W", "", data.meta.id)
        out_str += f'\t\t_a = {ALL_FACTIONS.index(faction) + 1},\n'

        if ent.id == "50101" or ent.id == "50601":
            out_str += f'\t\timage = "https://steamusercontent-a.akamaihd.net/ugc/782978561533028979/1C62BA0C36C43652873BA5753487408B085AC99E/",\n'
            out_str += f'\t\tassetBundle = "https://steamusercontent-a.akamaihd.net/ugc/1661232658848706858/097D469797AE070DE8DB5E8DD553ACB211DB9574/",\n'

        if is_custom:
            out_str += f'\t\tcardFace = "{get_repo_url(f"custom/generated/{data.meta.id}/{ent.id}.jpg")}",\n'
            out_str += f'\t\tcardBack = "{get_repo_url(f"custom/generated/{data.meta.id}/{ent.id}b.jpg")}"\n'

        out_str += "\t})\n"

    return out_str


def indent(text):
    return "\t" + "\n\t".join(text.split("\n"))


def generate_lua():
    CUSTOM_LUA = f"\t-- REGION CUSTOM_CONTENT\n"
    for custom_id in CUSTOM_CONTENT:
        patch_data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/custom/data/{custom_id}.json")
        if patch_data.factions:
            for custom_faction in patch_data.factions.keys():
                ALL_FACTIONS.append(custom_faction)
        else:
            ALL_FACTIONS.append(re.sub(r"\W", "", custom_id))
        print(f"Generating LUA for {custom_id}")
        CUSTOM_LUA += gen_lookup(patch_data)
    CUSTOM_LUA += f"\t-- ENDREGION CUSTOM_CONTENT\n"

    with open(f"{OUTPATH}/data-lookup.lua", "r+", encoding="utf-8") as unit_lookup:
        lookup_lua = unit_lookup.read()
        unit_lookup.seek(0)
        unit_lookup.truncate()
        LUA = f"-- REGION GENERATED\n"
        LUA += f"-- GENERATED BY scripts/generate_lua.py\n"
        LUA += f"-- MANUAL CHANGES WILL BE LOST THE NEXT TIME THIS FILE IS GENERATED!\n"
        LUA += f'local gitHubBaseURL = "{DATA_REPO_BASE_URL}"\n'
        LUA += f'local commitHash = "{COMMIT_HASH}"\n'
        factions_str = [f'"{f}"' for f in ALL_FACTIONS]
        LUA += f'local factionsIndex = {{{", ".join(factions_str)}}}\n'
        item_type = [f'"{t.rstrip("s")}"' if t != "tactics" else '"tactics"' for t in DATA_KEYS]
        LUA += f'local itemTypes = {{{", ".join(item_type)}}}\n'
        LUA += 'local trays = {"infantry", "cavalry", "warmachine", "solo"}\n'
        LUA += f"-- ENDREGION"
        lookup_lua = re.sub(r"-- REGION GENERATED.+-- ENDREGION", LUA, lookup_lua, flags=re.DOTALL)
        unit_lookup.write(lookup_lua)

    LUA = f"-- THIS FILE WAS GENERATED BY scripts/generate_lua.py\n"
    LUA += f"-- ALL MANUAL CHANGES WILL BE LOST THE NEXT TIME THIS FILE IS GENERATED!\n"
    LUA += f"local function initializeLookup(_i, _b)\n"
    for faction in CORE_FACTIONS:
        print(f"Generating LUA for {faction}")
        LUA += f"\t-- REGION {faction.upper()}\n"
        for lang in ["en", "de", "fr"]:
            data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/data/{lang}/{faction}.json")
            LUA += gen_lookup(data)
        LUA += f"\t-- ENDREGION {faction.upper()}\n"

    pre_data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/custom/data/cmon-prerelease.json")
    LUA += f"\t-- REGION PRERELEASE\n"
    LUA += gen_lookup(pre_data)
    LUA += f"\t-- ENDREGION PRERELEASE\n"

    LUA += CUSTOM_LUA

    LUA += f"end\n"
    LUA += f"return initializeLookup"

    with open(f"{OUTPATH}/data-lookup-init.lua", "w", encoding="utf-8") as luafile:
        luafile.write(LUA)

    PATCH_LUA_HEAD = f"-- THIS FILE WAS GENERATED BY scripts/generate_lua.py\n"
    PATCH_LUA_HEAD += f"-- ALL MANUAL CHANGES WILL BE LOST THE NEXT TIME THIS FILE IS GENERATED!\n"
    PATCH_LUA = ""
    patch_ids = {}

    for custom_id in CUSTOM_PATCHES:
        patch_data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/custom/data/{custom_id}.json")
        patch_ids[custom_id] = [it.id for it in patch_data.all_entities]
        ref_data = [DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/{p}") for p in patch_data.meta.ref or []]
        combined = DataLoader.combine([patch_data] + ref_data)
        print(f"Generating LUA for PATCH: {custom_id}")
        PATCH_LUA += f'\tif id == "{custom_id}" then\n'
        PATCH_LUA += indent(gen_lookup(patch_data, is_custom_patch=True, ref_cards=combined.tactics))
        PATCH_LUA += f"\tend\n"

    PATCH_LUA_HEAD += f"local patchToIds = {{\n"
    for k, v in patch_ids.items():
        ids = [f'"{iid}"' for iid in v]
        PATCH_LUA_HEAD += f'\t["{k}"] = {{ {", ".join(ids)} }},\n'
    PATCH_LUA_HEAD += f"}}\n"
    PATCH_LUA_HEAD += f"local function patchLookup(_i, _b, _p, id)\n"
    PATCH_LUA_HEAD += f"\tfor _, itId in ipairs(patchToIds[id]) do\n"
    PATCH_LUA_HEAD += f'\t\t_p("en", itId)\n'
    PATCH_LUA_HEAD += f'\tend\n'

    PATCH_LUA += f"end\n"
    PATCH_LUA += f"return patchLookup"

    with open(f"{OUTPATH}/data-lookup-patch.lua", "w", encoding="utf-8") as luafile:
        luafile.write(PATCH_LUA_HEAD + PATCH_LUA)


def get_bundled_lua():
    path_documents = get_documents_path()
    bundle_cmd = f'luabundler bundle ./lua/Global.-1.lua -p "./?.lua" -p "{path_documents}/Tabletop Simulator/?.lua"'
    return subprocess.check_output(bundle_cmd, shell=True)


def main():
    generate_lua()


# CONFIG ###################################################################################################################################
OUTPATH = f"./lua"
LOCAL_DATA_REPO_PATH = r"../asoiaf-tmg-data"
DATA_REPO_BASE_URL = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-data/"
revlist_proc = subprocess.run(["git", "rev-list", "-1", "origin"], capture_output=True, cwd=f"{LOCAL_DATA_REPO_PATH}")
COMMIT_HASH = revlist_proc.stdout.strip().decode("ascii")

CUSTOM_CONTENT = [
    "kullvox-tyrell",
    "kullvox-tully",
    "hotshot-blackfyre",
    "hotshot-baratheon",
    "hotshot-targaryen",
    "boardmangaming-others",
    "boardmangaming-arryn",
    "hnc-tattered-prince",
]
CUSTOM_PATCHES = [
    "cba"
]
############################################################################################################################################


if __name__ == '__main__':
    main()
