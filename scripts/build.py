import os
import json
import time
import datetime
from scripts.save import dump, get_tts_base_save_path, LOCAL_SAVE_PATH
from scripts.extract_objects import build_object_states
from scripts.generate_lua import generate_lua, get_bundled_lua
from scripts.generate_changelog import gen_changelog_lua
from scripts.assets import get_assets


def build():
    with open(LOCAL_SAVE_PATH, "r", encoding="utf-8") as save_file:
        save_data = json.load(save_file)

    # wipe the save state - we want to load defaults
    save_data["LuaScriptState"] = ""
    save_data["LuaScript"] = ""

    # Maybe build the xmlUi from scratch too?
    # save_data["XmlUI"] = <...>

    save_data["ObjectStates"] = build_object_states()

    gen_changelog_lua()
    generate_lua()
    bundle = get_bundled_lua()
    save_data["LuaScript"] = str(bundle, encoding="utf-8")
    with open("./save/bundle.lua", "wb") as lua_file:
        lua_file.write(bundle)

    # Remember to commit assets before building
    save_data["CustomUIAssets"] = get_assets()

    t = time.time()
    save_data["EpochTime"] = int(t)
    # the hash characters strip leading 0s, but are windows only (use '-' elsewise)
    save_data["Date"] = datetime.datetime.fromtimestamp(t).strftime("%#m/%#d/%Y %I:%M:%S %p")

    dump(save_data, LOCAL_SAVE_PATH)
    dump(save_data, f"{get_tts_base_save_path()}/save.json")


if __name__ == "__main__":
    build()
