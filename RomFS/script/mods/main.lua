--MIT License
--Copyright (c) 2018 EddyK28


--<==\/============(General Utility Functions)============\/==>--

--TODO: make in groups of two lines and only split on spaces
--split text into chunks for printing with  WINDOW:SysMsg()
local function splitByChunk(text, chunkSize, nLines)
  local s = {}
  for i=1, #text, chunkSize do
    s[#s+1] = text:sub(i,i+chunkSize - 1)
  end
  return s
end

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

--Print an error message to the screen  --TODO: rename? can be used for more than just errors
local function errMsg(title, text)
  if title then
    WINDOW:SysMsg(title:gsub(" ","쐃"))
    if text == nil then 
      WINDOW:CloseMessage()
      return
    end
  end
  local err = splitByChunk(text,48)
  for i,v in ipairs(err) do
    WINDOW:SysMsg(v:gsub(" ","쐃"))
  end
  WINDOW:CloseMessage()
end

--load a mod from the given mod data
function loadMod(mod)
  local func, er = loadfile(modDir .. mod.ID .. "/main.lua")
  if not func then
    errMsg("Error Loading Mod '".. mod.name .."'",er)
	return false
  end

  local stat, err = pcall(func)
  if not stat then
    errMsg("Error in Mod '".. mod.name .."'",err)
    return false
  end
  
  return true
end

--Clear global variables
local function clearGlob()
  modDir = nil
  bIsGates = nil
  bIsDungeon = nil
end

--<==\/============(Gates Compatibility Fixes)============\/==>--
--TODO: add workarounds for other Gates issues

local function GatesCompat()
  
  --replace broken string.gsub()    --WARNING: does not have full gsub functionality
  string.gsub = function (str, patt, new, n)
    local strOut = ""
    local st, en
    local f = 1
    
    while true do
      st, en = str:find (patt,f)
      if st then
        strOut = strOut .. str:sub(f,st-1) .. new
        f = en+1
      else
        strOut = strOut .. str:sub(f,str:len())
        break
      end
    end
    
    return strOut
  end

  --(Re)define missing or broken vector functions
  getmetatable(Vector).__add = function(s,v)
    return Vector(s.x+v.x,s.y+v.y,s.z+v.z)
  end
  getmetatable(Vector).__sub = function(s,v)
    return Vector(s.x-v.x,s.y-v.y,s.z-v.z)
  end
  Vector.Normalize = function(s)
    local sz = s:Size()
    s.x, s.y, s.z = s.x/sz, s.y/sz, s.z/sz
    return s
  end
  

  --Redefine broken menu function
  function PageMenu.GetSelectedItem(self)
    return self:GetItem(self:GetCursorItemIndex())
  end
end


--<==\/============(Main)============\/==>--

--Set up some global values
modDir = "script/mods/"
bIsGates = (GROUND.GetWorldContinentName == nil)
bIsDungeon = SYSTEM:IsDungeon()


--load mod list from main config file
local cfg, err = loadConfig("config.lua")

--warn and return if config loading error
if not cfg then
  errMsg("Error Loading Config File",err)
  clearGlob()
  return
end


local modData = {}

--create a page menu for mod selection
local menu = MENU:CreatePageMenu()
menu:SetLayoutRectAndLines(32, 38, 256, 8)
menu:ShowPageNum(true)


--for each mod list entry,
for i,modID in ipairs(cfg) do

  --attempt to read the mod's config file     --TODO: warn on cfg load error?
  local mod, err = loadConfig(modID .. "/config.lua")
  
  if mod then
    --if mod is for current game,
    if mod.game == nil or mod.game == "" or (mod.game == "gates" and bIsGates) or (mod.game == "super" and not bIsGates) then
      --add mod data to mod table and add menu entry
      mod.name = mod.name or modID
      modData[#modData+1] = {ID=modID, name=mod.name, desc=mod.description or ""}
      menu:AddItem(mod.name, #modData, nil)
    end
  end
  
end

--If game is Gates, set up some compatibility fixes
if bIsGates then
  GatesCompat()
end

if #modData == 0 then 
  --warn and return if no mod functions were loaded
  errMsg("Error: No Mods Detected")
elseif #modData == 1 then 
  --run directly if only one mod loaded
  loadMod(modData[1])
else
  --set menu functions
  function menu:openedAction()
    MENU:SetFocus(self)
    CommonSys:OpenBasicMenu("PMD Mod Loader","[M:B12][M:B09]Select  [M:B05]Load Mod  [M:B06]Cancel", modData[1].desc)
    self:SetCursorItemIndex(0)
  end
  function menu:closedAction()
    if CommonSys.basicMenuStack ~= nil then
      CommonSys:CloseBasicMenu()
    end
    MENU:ClearFocus(self)
  end
  function menu:cancelAction()
    self:Close()
  end
  function menu:currentItemChange()
    local selectID = self:GetSelectedItem()
    if selectID and CommonSys.basicMenuStack ~= nil then
      CommonSys:UpdateBasicMenu_LineHelp(modData[selectID].desc)
    end
  end
  function menu:decideAction()
    local selectID = self:GetSelectedItem()
    --hide menu
    self:SetVisible(false)
    CommonSys:CloseBasicMenu()
    
    --load mod
    if bIsDungeon then  --calling loadfile() from a menu function while in a dungeon crashes the game, so load the mod in a task.
      TASK:Regist(loadMod,{modData[selectID]})
      TASK:WaitTask()
    else
      loadMod(modData[selectID])
    end
    
    --reshow menu
    self:SetVisible(true)
    CommonSys:OpenBasicMenu("PMD Mod Loader","[M:B12][M:B09]Select  [M:B05]Load Mod  [M:B06]Cancel", modData[selectID].desc)
    MENU:SetFocus(self)
  end
  
  --open menu and wait for completion before continuing
  menu:Open()
  MENU:WaitClose(menu)
end

--clear global vars
clearGlob()