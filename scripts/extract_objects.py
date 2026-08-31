import os
import re
import shutil
import json
from scripts.save import get_tts_base_save_path


def extract_object(obj_state, basepath):
    guid = obj_state["GUID"]
    nickname = obj_state.get("Nickname", "")
    name = obj_state.get("Name", "")
    key = re.sub(r"[/\\?%*:|\"<>\x7F\x00-\x1F]", "", f"{nickname}.{name}.{guid}")
    path = f"{basepath}/{key}"
    os.mkdir(path)

    try:
        lua = obj_state.pop("LuaScript").strip()
    except KeyError:
        lua = None
    if lua:
        with open(f"{path}/script.lua", "w", encoding="utf-8") as lf:
            lf.write(lua.replace("\r\n", "\n"))

    try:
        xml = obj_state.pop("XmlUI").strip()
    except KeyError:
        xml = None
    if xml:
        with open(f"{path}/ui.xml", "w", encoding="utf-8") as xf:
            xf.write(xml.replace("\r\n", "\n"))

    if obj_state.get("ContainedObjects") is not None:
        contained = obj_state.pop("ContainedObjects")
        os.mkdir(f"{path}/ContainedObjects")
        for contained_obj in contained:
            extract_object(contained_obj, f"{path}/ContainedObjects")

    with open(f"{path}/object.json", "w", encoding="utf-8") as of:
        json.dump(obj_state, of, indent=4, ensure_ascii=False)


def parse_float(n):
    n = round(float(n), 3)
    if n == 0:
        return 0.0
    else:
        return n


def extract(do_wipe=True):
    if do_wipe:
        shutil.rmtree(OBJCETS_DIR)
        os.mkdir(OBJCETS_DIR)

    with open(f"{get_tts_base_save_path()}/save.json", "r", encoding="utf-8") as save_file:
        save_data = json.load(save_file, parse_float=parse_float)
    states = save_data["ObjectStates"]

    for obj_state in states:
        extract_object(obj_state, OBJCETS_DIR)


def build_object(path):
    with open(f"{path}/object.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    if os.path.exists(f"{path}/ui.xml"):
        with open(f"{path}/ui.xml", "r", encoding="utf-8") as f:
            xml = f.read()
        data["XmlUI"] = xml

    if os.path.exists(f"{path}/script.lua"):
        with open(f"{path}/script.lua", "r", encoding="utf-8") as f:
            lua = f.read()
        data["LuaScript"] = lua

    if os.path.isdir(f"{path}/ContainedObjects"):
        contained = []
        for contained_obj in os.listdir(f"{path}/ContainedObjects"):
            contained_path = os.path.join(f"{path}/ContainedObjects", contained_obj)
            contained.append(build_object(contained_path))
        data["ContainedObjects"] = contained

    return data


def build_object_states():
    states = []
    for path in os.listdir(OBJCETS_DIR):
        full_path = os.path.join(OBJCETS_DIR, path)
        states.append(build_object(full_path))

    return states


def main():
    extract()


OBJCETS_DIR = f"./save/objects"

if __name__ == "__main__":
    main()
