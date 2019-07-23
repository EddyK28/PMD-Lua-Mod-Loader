return {
  name="Example Mod",  --The name of this mod, displayed on the list in game
  description="A simple example of how to make a mod for this mod loader.",  --A short description of this mod, displayed on the list in game
  game="",  --What game this mod is compatible with.  Can be either "gates" or "super". Excluding this entry or leaving it blank means the mod will be loaded for any game.
  allowDungeon="yes",  --whether or not to allow this mod in dungeons. Can be excluded, blank or "yes" to allow dungeon use, "no" to disallow dungeon use, or "only" to only allow use in dungeons.
  allowInjector="no"  --as above, but excluded or blank defaults to "no"
}