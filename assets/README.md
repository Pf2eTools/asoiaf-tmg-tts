Several assets (such as terrain, mission/objective cards, tacticsboards) in addition to all rules cards are hosted
at https://github.com/Pf2eTools/asoiaf-tmg-data/

## 3d scans

- obtain assetbundles by following this [3-step guide*](https://www.dicefromhell.de/how-to-scan-a-tabletop-miniature-part-1)
- `assets/3d/scans/assetbundles.json` serves as an index. The key describes the path to the bundle, without file extension
- the script `steam/cloud_uploader.py` uploads the bundle to the steam cloud and fills the url field
- `assets/3d/scans/units.json` maps unit ids from the data repo to assetbundles from the index



*\*each step includes multiple steps*