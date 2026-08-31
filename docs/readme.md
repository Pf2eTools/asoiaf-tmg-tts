# asoiaf-tmg-tts

Development files for the [Tabletop Simulator Mod for the A Song of Ice and Fire: The Miniature Game](https://steamcommunity.com/sharedfiles/filedetails/?id=2077621477)

## Setting up a dev environment

You will need to clone the data repository at https://github.com/Pf2eTools/asoiaf-tmg-data/ and configure python imports for the build scripts.

- Install [VSCode](https://code.visualstudio.com/download)
- Install the [Tabletop Simulator](https://marketplace.visualstudio.com/items?itemName=rolandostar.tabletopsimulator-lua) and [LuaHelper](https://github.com/Tencent/LuaHelper) extensions
- In the extension settings `TTSLua.includeOtherFilesPaths`, add the root folder of this repository
- Install luabundler: `npm install -g luabundler`
- Open a local save of this mod
- Use the `TTSLua: Get Lua Scripts` command
- Edit files in the lua or xml directory
- Use the `TTSLua: Save and Play` command

Alternatively, build with `scripts/build.py`, then reload the save

If you want to add new objects into the mod, load a save, add the object, overwrite the save, then run `scripts/extract_objects.py`. Otherwise, the new objects won't be added on the next build.

I've never set this up, but it might be something to consider: https://github.com/tts-community/moonsharp-tts-debug

## Writing the Changelog

- Use Markdown formatting with these style guidelines:
    - Use double hashtags for version headers
    - The next line should start with 4 hashtags, and be the release date
    - List changes with Markdown lists by starting lines with hyphen space (`- Text`). Each change should be its own list item
    - You can use text styling like **bold**, *italic*, ~~strikethrough~~, or `code`
- Discord supports this format

## Before Pushing to Production

- Write the changelog
- Update `VERSION_NUMBER` in `lua/global.lua`
- Run `scripts/build.py`
