--====PMD 3/4 Mod Loader====--
--MIT License
--Copyright (c) 2019 EddyK28

--<==\/============(Injector Function Replacement Tables)============\/==>--
--TODO: put these tables in a separate file?

--Functions to use as injector entry points
injectorPoints = {
  {
    CAMERA, 
    {
      "SetSisaRateVolume",
      "SetSisaAzimuthDifferenceVolume"
    }
  },
  {
    SCREEN_A, 
    {
      "FadeIn",
      "FadeInAll"
    }
  },
  {
    SYSTEM,
    {
      "SetProhibitStereoGram"
    }
  }
}

--Functions to use as injector exit points (for stopping injector task)
injectorExits = {
  --Not really needed?
}

--Functions to skip while the injector is running
injectorSkips = {
  {
    CAMERA, 
    {
      "SetEye",
      "SetEyeR",
      "SetTgt",
      "SetTgtR",
      "Move",
      "MoveEye",
      "MoveEyeR",
      "MoveTgt",
      "MoveTgtR",
      "MoveFollow",
      "MoveFollowR",
      "MoveFollow2",
      "MoveFollow2R",
      "MoveFollowZoom",
      "MoveFollowZoomR",
      "Zoom",
      "SetTgtAndFreeMoveEye"
      --TODO: add WaitMove?
    }
  },
  {
    SCREEN_A,
    {
      "FadeOut",
      "FadeOutAll"
    }
  },
  {
    WINDOW,
    {
      "SetWaitMode"
    }
  }
}

--Functions to break at while the injector is running
injectorBreaks = {
  {
    CHARA_OBJ, 
    {
      "WalkTo",
      "RunTo",
      "MoveTo",
      "DirTo",
      "SetVisible"
    }
  },
  {
    WINDOW,
    {
      "DrawFace",
      "Talk",
      "Monologue",
      "Narration"
    }
  }
}



--<==\/============(General Utility Functions)============\/==>--

--TODO: make in groups of two lines and only split on spaces
--[GLOBAL] Split text into chunks for printing with WINDOW:SysMsg()
function splitByChunk(text, chunkSize, nLines)
  local s = {}
  for i=1, #text, chunkSize do
    s[#s+1] = text:sub(i,i+chunkSize - 1)
  end
  return s
end

--[GLOBAL] Print a message to the screen using WINDOW:SysMsg
function printMsg(title, text)
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

--[GLOBAL] Show some text using a full screen.  Can be scrolled with D-pad.
function showText(text, screen)

  if not text then return end

  screen = screen or ScreenType.B
  local textBox = MENU:CreateBoardMenuWindow(screen)
  textBox:SetLayoutRect(Rectangle(0, 0, 400, 240))
  textBox:SetText(text)
  textBox:SetTextOffset(6, 6)
  textBox:Open()
  MENU:SetFocus(textBox)
  
  local ofsX, ofsY = 6,6
    
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    if PAD:Data("START|B") then   --close
      break
      
    elseif PAD:Data("(RIGHT|LEFT|UP|DOWN)") then
      if PAD:Edge("RIGHT") then
        ofsX = ofsX - 15
      elseif PAD:Edge("LEFT") then
        ofsX = ofsX + 15
      end
      
      if PAD:Edge("UP") then
        ofsY = ofsY + 15
      elseif PAD:Edge("DOWN") then
        ofsY = ofsY - 15
      end

      if ofsX > 6 then ofsX = 6 end
      if ofsY > 6 then ofsY = 6 end
      
      textBox:SetTextOffset(ofsX, ofsY)
      
      while PAD:Data("(RIGHT|LEFT|UP|DOWN)") do
        TASK:Sleep(TimeSec(0.01))
      end
    end
  end

  textBox:Close()
end

--run an external lua file with error handling
local function runExtern(file,...)
  local func, err = loadfile(file)
  if not func then
	printMsg("Error loading file",err)
    return
  end
  
  local stat, err = pcall(func,...)
  if not stat then
	printMsg("Error executing file",err)
  end
end

--load the specified menu table file with error checking
local function loadMenuTable(menuTable)
  --load menu table file and catch any load errors
  local func, err = loadfile("script/menu/" .. menuTable)
  if not func then  --this will probably never happen (damnit Chunsoft)
	return nil, nil, err
  end
  
  --execute menu table file and catch any {runtime} errors
  local stat, res, res2 = pcall(func)
  if not stat then
    return nil, nil, res
  end
  
  --catch empty results (file missing or empty)
  if not res or next(res) == nil then
    return nil, nil, "Menu table file " .. menuTable .. " missing or empty"
  end
  
  --catch empty second result (the non-resident table)
  if not res2 or next(res2) == nil then
    return nil, nil, "Menu table file " .. menuTable .. " is incomplete"
  end
  
  return res, res2, "Success"
end

--Replace Others menu with loader entry point
local function menuEntryInit()
  dungeonMenuOthersOrig = dungeonMenuOthers
  function dungeonMenuOthers()
    if PAD:Data("L|X") then
      runExtern("script/mods/main.lua")
      if SYSTEM:IsDungeonMenu() then
        FlowSys.Stat.nextFunc = "dungeonMenuMain"
      else
        FlowSys.Stat.nextFunc = "groundMenuOpen"
      end
      FlowSys:Next(FlowSys.Stat.nextFunc)
      return
    end
    dungeonMenuOthersOrig()
  end
end

--<==\/============(Injector Utility Functions)============\/==>--

function taskInjector() --TODO: local?
  local injectorStartNow = false
  
  function TaskL.Start()
    if injectorRunning then
      injectorRunning = false
    end
    injectorStartNow = injectorAutoStart 
  end
  
  function TaskL.Loop()
    --test for buttons
    if PAD:Data("START&(L|X)") or injectorStartNow then
      injectorRunning = true
      injectorStartNow = false
      
      --Break if auto-break is enabled
      if injectorBreakAuto then injectorBreak = 0 end
      
      --Pause any running 'CUT' cutscenes
      CUT:Pause()  --TODO: improve 'CUT' handling
      
      --fade in screens
      SCREEN_B:FadeInAll(TimeSec(0), true)
      SCREEN_A:FadeInAllOr(TimeSec(0), true)
      SCREEN_A:FadeInOr(TimeSec(0), true)
      
      --Gates just loves to break things, so attempt to un-break them
      local envfix = nil
      if bIsGates then
        envfix = {_G,setfenv}
      end
      
      --call loader (pass 'injectorRunning' and Gates env table fix)
      runExtern("script/mods/main.lua",true,envfix)
      
      --clean environment
      injectorBreak = 2
      injectorRunning = false
      CUT:Play()
    end
    TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME), TASK_EXIT.QUICK)
  end
  
  function TaskL.Finish()
    if injectorRunning then
      injectorRunning = false
    end
    return  --TODO: why explicit return?  Did it fix some magical brokenness?
  end
end

--Initialize the injector system
local function injectorInit()
  
  --replace injector entry functions
  for i,entry in ipairs(injectorPoints) do
    local obj = entry[1]
    for j,func in ipairs(entry[2]) do
    
      obj[func.."Or"] = obj[func]

      obj[func] = function(...)
        --if enabled and not currently running, start injector listener task
        if injectorEnabled then
          if TASK:IsEndTasks(Group("injector")) then
            TASK:Regist(Group("injector"), taskInjector, {} )
          end
          
          --if auto-start, delay normal execution to give injector some startup time
          if injectorAutoStart then
            TASK:Sleep(TimeSec(5, TIME_TYPE.FRAME))
          end
          
        elseif injectorRunning then
          --TODO: injector running but not enabled, need to handle this somehow (also check if task running)
        end
        
        --Call original function
        return obj[func.."Or"](...)
      end
      
    end
  end
   
  --TODO: replace injector exit functions? (needed to safely kill task?)
  
end

--[GLOBAL] Enable the cutscene injector
function injectorEnable()
  if injectorEnabled then return end
  injectorEnabled = true
  
  --TODO: condense some of this stuff
    
  --overwrite "skip" functions
  for i,entry in ipairs(injectorSkips) do
    local obj = entry[1]
    for j,func in ipairs(entry[2]) do
    
      obj[func.."Or"] = obj[func]
      
      obj[func] = function(...)
        --Return pre-call if injector running and skip enabled
        if injectorRunning and injectorSkip then
          return
        end
        
        --Call original function
        return obj[func.."Or"](...)
      end
      
    end
  end
  
  --overwrite "break" functions
  for i,entry in ipairs(injectorBreaks) do
    local obj = entry[1]
    for j,func in ipairs(entry[2]) do
    
      obj[func.."Or"] = obj[func]
      
      obj[func] = function(...)
        --get stuck in a loop if injector running and break enabled
        if injectorRunning and injectorBreak == 0 then
          --get some info on this function
          injectorBreakData = debug.getinfo(1, "n")
          if injectorBreakAdv then
            injectorBreakData.trace = debug.traceback()
          end
          
          --wait-loop
          while injectorBreak == 0 do
            TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME))
          end
          
          --re-enable break if just taking one step
          if injectorBreak == 1 then
            injectorBreak = 0
          end
          
          --clear function data
          injectorBreakData =  nil
        end
        
        --Call original function
        return obj[func.."Or"](...)
      end
      
    end
  end
  
  --'WaitTask' when called with no group waits for all tasks (breaks injector task)
  --Replace task resister and wait to put all un-grouped tasks in a group
  TASK.RegistOr = TASK.Regist
  TASK.Regist = function(...)
    local temp = {...}
    if type(temp[2]) ~= "userdata" then     --TODO: add "or (temp[2]~=nil and temp[2].new_local ~= Group.new_local)"
      return TASK.RegistOr(temp[1],Group("injGlob"),temp[2],temp[3])
    end
    return TASK.RegistOr(...)
  end
  
  TASK.WaitTaskOr = TASK.WaitTask
  TASK.WaitTask = function(...)
    local temp = {...}
    if type(temp[2]) ~= "userdata" then
      return TASK.WaitTaskOr(temp[1],Group("injGlob"))
    end
    return TASK.WaitTaskOr(...)
  end
  
end

--[GLOBAL] Enable the cutscene injector
function injectorDisable()
  if not injectorEnabled then return end
  injectorEnabled = false
  
  --TODO: make sure this works properly
  local revert = {injectorSkips, injectorBreaks}
  
  --revert modified functions
  for k,group in ipairs(revert) do
    for i,entry in ipairs(group) do
      local obj = entry[1]
      for j,func in ipairs(entry[2]) do
        obj[func] = obj[func.."Or"]
        obj[func.."Or"] = nil
      end
    end
  end
  
  TASK.Regist = TASK.RegistOr
  TASK.RegistOr = nil
  
  TASK.WaitTask = TASK.WaitTaskOr
  TASK.WaitTaskOr = nil
  
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
  
  --Gates can't redefine character functions
  table.remove(injectorBreaks,1)
end

--<==\/============(Main)============\/==>--

--get is Gates (global to be used by mods)
bIsGates = (GROUND.GetWorldContinentName == nil)

--determine appropriate menu table (and Gates run compatibility fixes if needed)
local menuTable
if bIsGates then
  menuTable = "MenuTable_Gates.lua"
  GatesCompat()
else
  menuTable = "MenuTable_Super.lua"
end

--Load menu tables from file
local ResidentMenuTable, NonResidentMenuTable, err = loadMenuTable(menuTable)
menuTable = nil

--Handle menu table load error
if not ResidentMenuTable then
  printMsg("Error Loading Menu Table File",err)
  --TODO: make the game crash here
  return
end

--load resident menu files
for k, v in ipairs(ResidentMenuTable) do
  dofile(v.src)
end

--Initialize Menu Entry Point
menuEntryInit()

--Initialize Injector based Entry Point
injectorEnabled   = false
injectorRunning   = false
injectorAutoStart = false
injectorSkip      = true
injectorBreak     = 0   --0 = break, 1 = step, 2 = run
injectorBreakData = nil
injectorBreakAuto = true
injectorBreakAdv  = false
injectorInit()

--run autoexec script
runExtern("script/mods/autoexec.lua")

--load non-resident menu files
for k, v in ipairs(NonResidentMenuTable) do
  do
    local function  makeVariableArgs(args)
      local argNum = #args
      if argNum == 0 then
        return
      elseif argNum == 1 then
        return args[1]
      elseif argNum == 2 then
        return args[1], args[2]
      elseif argNum == 3 then
        return args[1], args[2], args[3]
      elseif argNum == 4 then
        return args[1], args[2], args[3], args[4]
      elseif argNum == 5 then
        return args[1], args[2], args[3], args[4], args[5]
      elseif argNum == 6 then
        return args[1], args[2], args[3], args[4], args[5], args[6]
      elseif argNum == 7 then
        return args[1], args[2], args[3], args[4], args[5], args[6], args[7]
      elseif argNum == 8 then
        return args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]
      elseif argNum == 9 then
        return args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]
      else
        assert(nil, "Invalid Arg Count")
      end
    end
    local function f(...)
      local args = {...}
      local ret
      MENU:CallLuaFunctionWithLuaGlobalEnvGuard(function()
        local srcTbl
        if type(v.src) == "table" then
          srcTbl = v.src
        else
          srcTbl = {
            v.src
          }
        end
        local loadedTbl = {}
        for i, src in ipairs(srcTbl) do
          dofile(src)
        end
        if f ~= getfenv(1)[v.func] then
          ret = getfenv(1)[v.func](makeVariableArgs(args))
        else
          SYSTEM:DebugPrint(string.format("%s \227\129\171 %s \227\129\140\227\129\191\227\129\164\227\129\139\227\130\137\227\129\170\227\129\132\227\130\136\227\129\134\227\129\167\227\129\153", srcTbl[1], v.func))
        end
      end)
      if v.withFullGc then
        collectgarbage("collect")
      end
      return ret
    end
    _G[v.func] = f
    getfenv(0)[v.func] = f
  end
end


--<==\/============(Menu Helper Functions)============\/==>--

function MenuScriptReloadFunc()
  for k, v in ipairs(ResidentMenuTable) do
    if v.isReload then
      MENU:DebugReloadMenuScript(v.src)
    end
  end
  
  menuEntryInit()
  --TODO: make sure this doesn't happen if already initialized
end

function MenuAction_AddPost(menu, actionName, actionFunc)
  if menu[actionName] ~= nil then
    do
      local actionFuncPre = menu[actionName]
      menu[actionName] = function(self)
        actionFuncPre(self)
        actionFunc(self)
      end
    end
  else
    menu[actionName] = actionFunc
  end
end

function NestMenu_SetupDefaultAction(menu, parentNestMenu, hideFlag)
  local decideAction = function(self)
  end
  local cancelAction = function(self)
    self:Close()
  end
  local abortFocusAction = function(self)
    self:NotifyForceClose()
  end
  local function closedAction(self)
    if self:IsForceClosed() then
      if parentNestMenu ~= nil and not parentNestMenu:IsFocus() then
        parentNestMenu:NotifyForceClose()
      end
    elseif parentNestMenu ~= nil then
      MENU:SetFocus(parentNestMenu)
      if hideFlag then
        parentNestMenu:SetVisible(true)
      end
      if menu.LuaExt_ParentClose then
        parentNestMenu.LuaExt_ParentClose = true
        parentNestMenu:Close()
      end
    end
  end
  MenuAction_AddPost(menu, "decideAction", decideAction)
  MenuAction_AddPost(menu, "cancelAction", cancelAction)
  MenuAction_AddPost(menu, "abortFocusAction", abortFocusAction)
  MenuAction_AddPost(menu, "closedAction", closedAction)
  if hideFlag then
    parentNestMenu:SetVisible(false)
  end
end

function NestMenu_OpenAndCloseWait(menu)
  menu:Open()
  MENU:SetFocus(menu)
  MENU:WaitClose(menu)
end

function NestMenu_CloseWait(menu)
  MENU:SetFocus(menu)
  MENU:WaitClose(menu)
end

function NestMenu_CloseAllNest(menu)
  menu.LuaExt_ParentClose = true
  menu:Close()
end

function BasicMenu_OpenAndCloseWait(menu)
  menu:Open()
  MENU:SetFocus(menu)
  MENU:WaitClose(menu)
end
