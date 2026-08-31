import os
import json


def dump(data, path):
    with open(path, "w", encoding="utf-8") as file:
        print(f'Saving to "{path}"...')
        json.dump(data, file, indent=2)


def get_documents_path():
    path = os.path.expanduser(f'~/Documents')
    if os.path.exists(path):
        return path
    raise NotADirectoryError(path)


def get_tts_base_save_path():
    path = f"{get_documents_path()}/My Games/Tabletop Simulator/Saves/ASOIAF-DEV"
    if not os.path.exists(path):
        os.mkdir(path)
    return path


# FIXME
TTS_REPO_URL = "https://raw.githubusercontent.com/Pf2eTools/asoiaf-tmg-tts"
LOCAL_SAVE_PATH = "./save/save.json"
