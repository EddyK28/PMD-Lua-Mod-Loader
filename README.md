# PMD Lua-Mod Loader

A loader for Lua based mods for Gates to Infinity and Super Mystery Dungeon.  Includes Free-Cam and other sample mods.
There are limitations to what can be done from Lua scripts, but there are still many interesting things to do.  
&nbsp;  
  
### Installation:
 
#### Luma3DS LayeredFS
Make sure to [enable game patching](https://github.com/AuroraWright/Luma3DS/wiki/Optional-features).
place the "RomFS" folder in the "luma/titles/0004000000174600" folder on your 3DS SD card for Super or "luma/titles/00040000000BA800" for Gates (you may have to create one of more these folders).  
  
#### Citra Packed ROM
Unpack your game ROM using your desired tool/kit (eg .Net 3DS Toolkit).  Merge the mod loader's "RomFS" folder with that extracted from the ROM, overwriting files when prompted.  Repack ROM and load with Citra.  
&nbsp;  
  
### Use:
Hold the 'L' or 'X' button while opening the "Others" menu to open the mod loader menu.  Select the desired entry from the list, and press 'A' to run.  If only one mod is available, it will be loaded directly.  (Note: 'L' or 'X' has to be held until the loader menu appears)   
  
#### Cutscene Injector
The Cutscene Injector is used to open the mod loader during cutscenes.  Before use it must be enabled either by using the Injector Control mod (see below) or executing `injectorEnable()` in a Lua script.  The injector is opened by holding the 'Start' button and pressing 'L' or 'X' during a cutscene.  The injector can be controlled and configured using the Injector Control mod.  While the injector is running, execution of the cutscene will stop at dialog and character movements.  The camera won't move unless you move it, or disable "Enable Function Skip" in the injector controls.  (Note: Special consideration is needed when creating injector compatible mods.  See Free-Cam as an example.)

#### Auto-Exec Script
The script `RomFS/script/mods/autoexec.lua` is run at game startup.  Can be used for any code that needs to be executed at each game start.  Useful for enabling injector at startup.  
&nbsp;  

  
### Included Mods:

#### Free-Cam (RomFS/script/mods/Free-Cam)
Take control over the camera and move it anywhere you want. Multiple camera modes. Works in both towns and dungeons. Contains cutscene injector controls.
    
#### PokeMorph (RomFS/script/mods/PKIDset) (PSMD only)
Change your hero & partner Pokemon into anything, anything at all.  Warning: this should not be used for regular gameplay.  It no longer messes up stats, but is still potentially unsafe. 
    
#### Nicknamer (RomFS/script/mods/Nicknamer)
Lets you give nicknames to the Pokemon you've recruited.  
   
#### Itemizer (RomFS/script/mods/Itemizer)
Easily give yourself any item in the game, including one's you're not supposed to have, even traps and special tiles (yep, they're items).
   
#### Injector Control (RomFS/script/mods/InjectorControl)
A basic control panel for the cutscene injector.  Enables/disables the injector outside of cutscenes, provides execution controls and injector options inside cutscenes.
   
#### Example Mod (RomFS/script/mods/Example)
It's an example for how to make a mod for this mod loader.  What else can I say.  (Note: this loader is only capable of running script based mods, and cannot alter models, textures, or other game resources)  
&nbsp;  
&nbsp;  
  
More/better information coming Soon&trade;