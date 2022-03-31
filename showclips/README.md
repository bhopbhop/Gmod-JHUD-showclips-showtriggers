# ShowClips

Module for Garry's mod Bunnyhop gamemode that shows invisible player clips brushes.
You can select solid or wireframe texture for brushes and change color.

Tested on FLOW gamemodes: [v8.42 (by czarchasm)](https://czarchasm.club/bhop.html), [v8.50 (pG)](https://github.com/GMSpeedruns/GM-BunnyHop) and [v7.26](https://github.com/GMSpeedruns/Flow-Release/tree/master/Gamemodes/Flow%20Network%20-%20All%20gamemodes/Flow%20Network%20-%20Bunny%20Hop/Gamemode)

## Installation

1. Place folder with this README file into Garry's mod addons folder
2. Restart the server (if it was running)

## Usage

Console variables can be changed from settings menu.

### Chat commands

Toggle player clips: `!showclips`, `!clips`, `!toggleclips`
Open settings window: `!clipsmenu`, `!clipsconfig`

Chat commands can be changed in `lua/showclips/sv_init.lua` file.

### Console commands and variables

* `showclips_menu` - Open settings window
* `showclips 0/1` - Toggle showclips
* `showclips_solid 0/1` - Use solid or wireframe texture
* `showclips_solid "R G B A"` - Color and alpha of brushes

## Internationalization support

You can change language strings at the bottom of the `lua/showclips/cl_init.lua` file.

## Credits

Made by [CLazStudio](https://steamcommunity.com/id/CLazStudio/) and sponsored by [rq](https://steamcommunity.com/id/relrq/).

This addon uses [luabsp-gmod](https://github.com/h3xcat/gmod-luabsp) library by h3xcat licensed under GPL-3.0 License wthout modifications (to parse bsp file and get information about clip brushes)
