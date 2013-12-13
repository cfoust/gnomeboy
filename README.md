Gnome Boy
===============

Game Boy (Color) emulator in World of Warcraft

Much of the gameboy backend relies on the code from https://code.google.com/p/garryboy/

It had to be heavily adapted to adhere to the WoW Lua API. Saving was added, too, so that users can save data across sessions for games like Pokemon.

Usage
===============
Click on the minimap button to show/hide the emulator. Click on the gear icon provided on each skin to lock the emulator in place and load it. Bindings may be set for all of the keys on the game boy, which are necessary to use the Cinema and Screen themes.

Adding ROMS
===============
Installing ROMs requires Python to be installed.

Add all roms to the /roms folder and then run convert.bat or convert.sh in order to install them into the addon. Alternatively, just run convert.py; that's all that either of those scripts does. They'll then be available in game to be played.