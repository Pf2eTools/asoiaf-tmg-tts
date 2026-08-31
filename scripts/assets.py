import os
from song_data import DataLoader, SongDataCollection, FACTIONS
from scripts.save import TTS_REPO_URL
from scripts.generate_lua import get_repo_url, CUSTOM_CONTENT, LOCAL_DATA_REPO_PATH


def inject_ncu_assets(assets, data: SongDataCollection, is_custom=False):
    for ncu in data.ncu:
        path = f"{'custom/' if is_custom else ''}portraits/{data.meta.id + '/' if is_custom else ''}round/{ncu.id}.png"
        url = get_repo_url(path)

        id_prefix = "" if not is_custom else f"{data.meta.pre or data.meta.id}-"
        tts_id = f"{id_prefix}{ncu.id}"

        dupes = [x["Name"] for x in assets if x["URL"] == url]
        if len(dupes):
            dupes.append(tts_id)
            raise Exception(f"ERROR: Duplicate assets with url '{url}': {dupes}")
        ix_existing = [ix for ix, x in enumerate(assets) if x["Name"] == tts_id]
        if len(ix_existing) > 1:
            raise Exception(f"ERROR: Duplicate asset with name '{tts_id}'.")
        elif len(ix_existing) == 1:
            if url:
                assets[ix_existing[0]]["URL"] = url
        else:
            assets.append({"Type": 0, "Name": tts_id, "URL": url})

    return assets


def get_assets():
    assets = []

    for asset_path in os.listdir(f"./assets/ui/global"):
        if not asset_path.endswith(".png") and not asset_path.endswith(".jpg"):
            continue
        name = asset_path.replace(".png", "").replace(".jpg", "")
        url = f"{TTS_REPO_URL}/refs/heads/master/assets/ui/global/{asset_path}"
        assets.append({"Type": 0, "Name": name, "URL": url})

    for faction in FACTIONS:
        data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/data/en/{faction}.json")
        inject_ncu_assets(assets, data)

    # TODO: cmon-prerelease?, but only if there is an ncu prerelease
    for custom_id in CUSTOM_CONTENT:
        custom_data = DataLoader.load_structured(f"{LOCAL_DATA_REPO_PATH}/custom/data/{custom_id}.json")
        inject_ncu_assets(assets, custom_data, is_custom=True)

    return assets
