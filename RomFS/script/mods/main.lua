--====PMD 3/4 Mod Loader====--
--MIT License
--Copyright (c) 2019 EddyK28


--Running this loader from the injector has some weird quirks, so fix those here:
--  In Super, 'injectorRunning' is always false, but loaded mods have the right value (go figure), and the function env IS global (more go figure)
--  so just pass 'injectorRunning' as an arg when running from the injector (defaults to false)
--  In Gates, the function environment is destroyed (blank table), so pass in global env and setenv function as well

do
local a,b = ...                 --get first 2 varargs
injectorRunning = a or false    --set 'injectorRunning' to arg1 if present
if b then                       --if arg2 present, use it to set function env
  b[2](1, b[1])
end
end

--<==\/============(General Utility Functions)============\/==>--

--load the specified config file (by path) with error checking
local function loadConfig(cfgDir)
  --load config file and catch any load errors
  local func, err = loadfile(modDir .. cfgDir)
  if not func then  --this will probably never happen (damnit Chunsoft)
	return nil, err
  end
  
  --execute config file and catch any {runtime} errors
  local stat, res = pcall(func)
  if not stat then
    return nil, res
  end
  
  --catch empty results (file missing or empty)
  if not res or next(res) == nil then
    return nil, "Config file " .. modDir .. cfgDir .. " missing or empty"
  end
  
  return res, "Success"
end

--load a mod from the given mod data
local function loadMod(mod,...)
  local func, er = loadfile(modDir .. mod.ID .. "/main.lua")
  if not func then
    printMsg("Error Loading Mod '".. mod.name .."'",er)
	return false
  end

  local stat, err = pcall(func,...)
  if not stat then
    printMsg("Error in Mod '".. mod.name .."'",err)
    return false
  end
  return true
end

local function injectionLoad(mod)
  loadMod(mod)
  injectionLoadWait = nil
end

--return true if game matches the current game, or is empty/nil
local function gameCheck(game)
  return game == nil or game == "" or (game == "gates" and bIsGates) or (game == "super" and not bIsGates)
end

--return true if bIsDungeon status is correct
local function dungeonCheck(dungeon)
  return dungeon == nil or dungeon == "" or dungeon == "yes" or (dungeon == "only" and bIsDungeon) or (dungeon == "no" and not bIsDungeon)
end

--return true if injectorRunning status is correct
local function injectorCheck(bInjector)
  if bInjector == "yes" then 
    return true 
  end
  
  if bInjector == "only" then 
    return injectorRunning
  end 

  return not injectorRunning
end

local function getFailingCheck(mod)
  if not gameCheck(mod.game) then
    return "Not compatible with current game"
  end
  if not dungeonCheck(mod.allowDungeon) then
    if bIsDungeon then
      return "Not usable in dungeon"
    else
      return "Not usable out of dungeon"
    end
  end 
  if not injectorCheck(mod.allowInjector) then
    if injectorRunning then
      return "Not usable with Injector"
    else
      return "Not usable without Injector"
    end
  end 
  return "Something weird happened"
end

--Clear global variables
local function clearGlob()
  modDir = nil
  curModDir = nil
  bIsDungeon = nil
end


--<==\/============(Main)============\/==>--

--Set up some global values
modDir = "script/mods/"
bIsDungeon = SYSTEM:IsDungeon()
curModDir = nil


--load mod list from main config file
local cfg, err = loadConfig("config.lua")

--warn and return if config loading error
if not cfg then
  printMsg("Error Loading Config File",err)
  clearGlob()
  return
end


local modData = {}
local modErrors = {}

--create a page menu for mod selection
local ldMenu = MENU:CreatePageMenu()
ldMenu:SetLayoutRectAndLines(32, 38, 256, 8)
ldMenu:ShowPageNum(true)


--for each mod list entry,
for i,modID in ipairs(cfg) do

  --attempt to read the mod's config file
  local mod, err = loadConfig(modID .. "/config.lua")
  
  if mod then
    --if mod is for current game,
    if gameCheck(mod.game) and dungeonCheck(mod.allowDungeon) and injectorCheck(mod.allowInjector) then
      --add mod data to mod table and add menu entry
      mod.name = mod.name or modID
      modData[#modData+1] = {ID=modID, name=mod.name, desc=mod.description or ""}
      ldMenu:AddItem(mod.name, #modData, nil)
    else
      --otherwise add to list of non-loaded mods
      modErrors[#modErrors+1] = (mod.name or modID) .. " not loaded: " .. getFailingCheck(mod)
    end
  else
    --add to list of errors if unable to load mod config
    modErrors[#modErrors+1] = err
  end
  
end

if #modData == 0 then 
  --warn and return if no mod functions were loaded
  printMsg("Error: No Valid Mods Detected")
elseif #modData == 1 then 
  --run directly if only one mod loaded
  loadMod(modData[1])
else
  --otherwise setup and show menu
  function ldMenu:openedAction()
    MENU:SetFocus(self)
    CommonSys:OpenBasicMenu("PMD Mod Loader ","[M:B12][M:B09]Select  [M:B05]Load Mod  [M:B06]Cancel  [M:B03]Menu", modData[1].desc)
    self:SetCursorItemIndex(0)
  end
  function ldMenu:closedAction()
    if CommonSys.basicMenuStack ~= nil then
      CommonSys:CloseBasicMenu()
    end
    MENU:ClearFocus(self)
  end
  function ldMenu:cancelAction()
    self:Close()
  end
  function ldMenu:currentItemChange()
    local selectID = self:GetSelectedItem()
    if selectID and CommonSys.basicMenuStack ~= nil then
      CommonSys:UpdateBasicMenu_LineHelp(modData[selectID].desc)
    end
  end
  function ldMenu:decideAction()
    local selectID = self:GetSelectedItem()
    --hide menu
    self:SetVisible(false)
    CommonSys:CloseBasicMenu()
    
    --==load mod==--
    curModDir = modDir .. modData[selectID].ID
    
    --running things from the injector is really strange, so do some wacky hacks
    if injectorRunning then     
      injectionLoadWait = true
      TASK:Regist(Group("injectionLoad"), injectionLoad,{modData[selectID]})
      while injectionLoadWait do
        TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME), TASK_EXIT.QUICK)
      end
      TASK:ExitNotifyTasks(Group("injectionLoad"))
      
      if not TASK:IsEndTasks(Group("injectionLoad")) then
        printMsg("Warning: Injection task still running",nil)
      end
    
    --calling loadfile() from a menu function while in a dungeon crashes the game, so load the mod in a task.
    elseif bIsDungeon then      
      TASK:Regist(loadMod,{modData[selectID]})
      TASK:WaitTask()
      
    else
      loadMod(modData[selectID])
    end
    curModDir = nil
    
    --reshow menu
    self:SetVisible(true)
    CommonSys:OpenBasicMenu("PMD Mod Loader","[M:B12][M:B09]Select  [M:B05]Load Mod  [M:B06]Cancel  [M:B03]Menu", modData[selectID].desc)
    MENU:SetFocus(self)
  end
  function ldMenu:inputXSelectAction()
    --TODO: add options menu (just shows non-loaded mods for now)
    for i,v in ipairs(modErrors) do
      printMsg(nil,v)
    end
    WINDOW:CloseMessage()
  end
  
  
  --open menu and wait for completion before continuing
  ldMenu:Open()
  MENU:WaitClose(ldMenu)
end

--clear global vars
clearGlob()