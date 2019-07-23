--====PMD Mod Loader Injector Control====--
--MIT License
--Copyright (c) 2019 EddyK28

--fade in/out screen?
--Optional fade-out skip control?
--Autorun injector?


--for Gates compatibility (long story)
local chkO = MENU:ReplaceTagText("[M:Q05]")
local chkX = MENU:ReplaceTagText("[M:Q00]")
local btnRun, btnBrk, btnStp
if bIsGates then
  btnRun = "Run ->"
  btnBrk = "Break ||"
  btnStp = "Step [VS:5][M:CUD]"
else
  btnRun = "Run ꀮꀯꀰ[HS:236][M:EPLAY]"
  btnBrk = "Break ꀮꀯꀰ[HS:236][M:EPAUSE]"
  btnStp = "Step ꀩ"
end

local function setCheckText(menuItem, checked)
  if checked then
    menuItem.text = menuItem.text:sub(1,-4)..chkX
  else
    menuItem.text = menuItem.text:sub(1,-4)..chkO
  end
end

local function getTouchBox(touchPt, x1, x2, y1, y2)
  return touchPt.x > x1 and touchPt.x < x2 and touchPt.y > y1 and touchPt.y < y2
end


--If injector is currently running, show run control menu
if injectorRunning then

  injectorBreakAdv = true
  if FC_textAdv == nil then FC_textAdv = true end
  
  --create menu and title/button hints
  local menu = MENU:CreatePageMenu()
  local guard = false --in case button and touch happen at once
  CommonSys:OpenBasicMenu("Injector Control","[M:B05]Select  [M:B06]Close", nil)
  menu:SetLayoutRectAndLines(32, 38, 256, 10)
  
  --Create break function info box and touch listener
  local infoInj = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoInj:SetLayoutRect(Rectangle(0, 0, 0, 0))
  infoInj:SetText("  ")
  infoInj:SetTextOffset(140, 70)
  infoInj:Open()
  local function taskInfoUpd()
    local tchPt, bTch = nil, false
    function TaskL.Loop()
      --function name update
      if injectorBreak < 2 then
        if injectorBreakData then
          infoInj:SetText(injectorBreakData.name)
        else
          infoInj:SetText("......")
        end
      else
        infoInj:SetText("")
      end
      
      --get touch input
      tchPt = PAD:TouchPointData()
      if tchPt.x > 36 and tchPt.x < 289 and tchPt.y > 37 and tchPt.y < 182 then
        if not bTch then
          bTch = true
          tchPt.y = math.floor((tchPt.y-38)/16)
          
          --activate entry if already selected
          tchPt.x = menu:GetCursorItemIndex()
          if tchPt.x == tchPt.y then
            if tchPt.y == 8 then
              menu:NotifyForceClose() --just Close() crashes the game
            else
              menu:decideAction()
            end
          
          --or select it if not
          else
            menu:SetCurrentModifyItem(tchPt.y)
            if menu.curItem.grayed then
              menu:SetCurrentModifyItem(tchPt.x)
            else
              menu:SetCursorItemIndex(tchPt.y)
            end
          end
          
        end
      else
        bTch = false
      end
      
      TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME))
    end
  end
  
  TASK:Regist(Group("InfoUpd"), taskInfoUpd)
  
  --add menu items
  if injectorBreak < 2 then
    menu:AddItem(btnRun, 1, nil)
  else
    menu:AddItem(btnBrk, 1, nil)
  end
  
  menu:AddItem(btnStp, 2, nil)
  menu:AddItem("Current function: ", 3, nil)
  menu:AddItem("[LINE:0:15]", 0, nil)
  menu:AddItem("Clear Screen", 4, nil)
  
  if FC_textAdv then
    menu:AddItem("Auto-Advance Text "..chkX, 5, nil)
    WINDOW:SetWaitModeOr(TimeSec(1.5),TimeSec(0.5))
  else
    menu:AddItem("Auto-Advance Text "..chkO, 5, nil)
    WINDOW:SetWaitModeOr(TimeSec(-1),TimeSec(-1))
  end
  
  menu:AddItem("Enable Function Skip "..chkX, 6, nil)
  menu:AddItem("Auto-Break on Injector Start "..chkX, 7, nil)
  menu:AddItem("Auto-Start Injector "..chkX, 8, nil)
  menu:AddItem("Exit", nil, {decideAction = function(self) self:Close() end})
  
  --disable spacer item
  menu:SetCurrentModifyItem(3)
  menu.curItem.grayed = true
  
  --disable step and info if not break
  if injectorBreak == 2 then
    menu:SetCurrentModifyItem(1)
    menu.curItem.grayed = true
    menu:SetCurrentModifyItem(2)
    menu.curItem.grayed = true
  end
  
  --(un)check skip/auto-break based on current setting
  menu:SetCurrentModifyItem(6)
  setCheckText(menu.curItem, injectorSkip)
  menu:SetCurrentModifyItem(7)
  setCheckText(menu.curItem, injectorBreakAuto)
  menu:SetCurrentModifyItem(8)
  setCheckText(menu.curItem, injectorAutoStart)
  menu:SetCurrentModifyItem(0)
  
  --set menu functions
  function menu:openedAction()
    MENU:SetFocus(self)
  end
  
  function menu:currentItemChange()
    --skip buttons that are grayed out
    if self.curItem.grayed then
      local diff = 1
      if PAD:Data("UP") then
        diff = -1
      end
      self:SetCurrentModifyItem(self.curItem.index+diff)
      while self.curItem.grayed do
        self:SetCurrentModifyItem(self.curItem.index+diff)
      end
      self:SetCursorItemIndex(self.curItem.index)
    end
  end
    
  function menu:decideAction()
    if not guard and type(self.curItem.obj) == "number" then
      guard = true
      
      --run/break
      if self.curItem.obj == 1 then
        if injectorBreak < 2 then
          injectorBreak = 2
          self.curItem.text = btnBrk
        else
          injectorBreak = 0
          self.curItem.text = btnRun
        end
        self:SetCurrentModifyItem(1)
        self.curItem.grayed = (injectorBreak == 2)
        self:SetCurrentModifyItem(2)
        self.curItem.grayed = (injectorBreak == 2)
        self:SetCurrentModifyItem(0)
        
      --step
      elseif self.curItem.obj == 2 then
        if injectorBreakData then
          injectorBreak = 1 
        else
          injectorBreak = 2
          TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME))
          injectorBreak = 0
        end
        
      --function info
      elseif self.curItem.obj == 3 and injectorBreakData then
        self:SetVisible(false)
        infoInj:SetVisible(false)
        CommonSys:CloseBasicMenu()
        showText(injectorBreakData.trace)
        self:SetVisible(true)
        infoInj:SetVisible(true)
        CommonSys:OpenBasicMenu("Injector Control","[M:B05]Select  [M:B06]Close", nil)
        MENU:SetFocus(self)
        
      --clear screen
      elseif self.curItem.obj == 4 then
        WINDOW:CloseMessage()
        WINDOW:RemoveFace()
        SCREEN_A:FadeInAllOr(TimeSec(0), true)
        SCREEN_A:FadeInOr(TimeSec(0), true)
  
      --toggle text advance
      elseif self.curItem.obj == 5 then
        if FC_textAdv then
          self.curItem.text = self.curItem.text:sub(1,-4)..chkO
          WINDOW:SetWaitModeOr(TimeSec(-1),TimeSec(-1))
        else
          self.curItem.text = self.curItem.text:sub(1,-4)..chkX
          WINDOW:SetWaitModeOr(TimeSec(1.5),TimeSec(0.5))
        end
        FC_textAdv = not FC_textAdv
        
      --toggle function skip
      elseif self.curItem.obj == 6 then
        injectorSkip = not injectorSkip
        setCheckText(self.curItem, injectorSkip)
        
      --toggle auto-break on injector run
      elseif self.curItem.obj == 7 then
        injectorBreakAuto = not injectorBreakAuto
        setCheckText(self.curItem, injectorBreakAuto)
      
      --toggle injector auto-start
      elseif self.curItem.obj == 8 then
        injectorAutoStart = not injectorAutoStart
        setCheckText(self.curItem, injectorAutoStart)
      end
    end
    
    guard = false
  end
  
  function menu:cancelAction()
    self:Close()
  end
  
  function menu:closedAction()
    if CommonSys.basicMenuStack ~= nil then
      CommonSys:CloseBasicMenu()
    end
    MENU:ClearFocus(self)
  end
  
  menu:Open()
  MENU:WaitClose(menu)
  
  TASK:ExitNotifyTasks(Group("InfoUpd"))
  infoInj:Close()
  
  if FC_textAdv then
    WINDOW:SetWaitModeOr(TimeSec(-1),TimeSec(-1))
  end
  
  injectorBreakAdv = false
  
--If injector is not running, show activation menu (fancy PSMD version)
elseif not bIsGates then

  --Create menus
  CommonSys:OpenBasicMenu("Injector Control","[CN][M:B05]Toggle  [M:B06]Close", nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(110, 190, 100, 16))
  infoBox:SetText("[CN]Injector Enabled")
  infoBox:SetTextOffset(0, 0)

  --create sprite set containing needed sprites
  SPRITE:CreatePatternSetFromTable("injCtrlSprts", { 
    {
      name = "icon",
      img = "GAME_HOME_ICON",
      u = 168,  --mapping offsets
      v = 168,
      w = 84,   --pattern size (clips image)
      h = 84,
      cx = 42,  --center point (offset from top left)
      cy = 42
    },
    {
      name = "iconBG",
      img = "GAME_TOP_ICON",
      u = 420,  --mapping offsets
      v = 84,
      w = 84,   --pattern size (clips image)
      h = 84,
      cx = 42,  --center point (offset from top left)
      cy = 42
    },
    {
      name = "ring",
      img = "POKEMON_FRAME_00",
      u = 0,      --mapping offsets
      v = 0,
      w = 128,    --pattern size (clips image)
      h = 128,
      cx = 64,    --center point (offset from top left)
      cy = 64
    }
  })
  
  --Create Icon background sprite
  local sprtIconBG = SPRITE:CreateSprite("sprtIconBG")
  sprtIconBG:SetPattern({
    setName = "injCtrlSprts",
    ptnName = "iconBG",
    ofsX = 0,
    ofsY = 0,
    ofsPrio = 5
  })
  sprtIconBG:SetOption({screen = ScreenType.B})
  sprtIconBG:SetPosition(Vector2(160, 120))
  
  --Create Icon sprite
  local sprtIcon = SPRITE:CreateSprite("sprtIcon")
  sprtIcon:SetPattern({
    setName = "injCtrlSprts",
    ptnName = "icon",
    ofsX = 0,
    ofsY = 0,
    ofsPrio = 3
  })
  sprtIcon:SetOption({screen = ScreenType.B})
  sprtIcon:SetPosition(Vector2(160, 120))
  
  --Create Icon ring sprite
  local sprtRing = SPRITE:CreateSprite("sprtRing")
  sprtRing:SetPattern({
    setName = "injCtrlSprts",
    ptnName = "ring",
    ofsX = 0,
    ofsY = 0,
    ofsPrio = 0
  })
  sprtRing:SetOption({scale = Scale(1.2),screen = ScreenType.B})
  sprtRing:SetPosition(Vector2(160, 120))

  --Create glowing ring, pt1
  SAJI:CreateSajiPlayer("injGlow", "ORB_CURSOR_FACE")
  local injGlow = SJ("injGlow")
  injGlow:SetPosition(Vector2(160, 120))
  injGlow:SetDrawPriority(100)
  injGlow:SetScreenType(ScreenType.B) 
  injGlow:Play(LOOP.ON)

  --Create glowing ring, pt2
  SAJI:CreateSajiPlayer("injGlow2", "ORB_CURSOR_FACE")
  local injGlow2 = SJ("injGlow2")
  injGlow2:SetPosition(Vector2(160, 120))
  injGlow2:SetDrawPriority(100)
  injGlow2:SetScreenType(ScreenType.B)
  injGlow2:SetRotate(Degree(90))
  injGlow2:Play(LOOP.ON)  

  infoBox:Open()
  SCREEN_B:LoadWallpaper("WALLPAPER_SUB_ORGANIZE_01")
  
  if not injectorEnabled then
    sprtIcon:ChangeAlpha(0.3, TimeSec(0))
    injGlow:ChangeAlpha(0, TimeSec(0))
    injGlow2:ChangeAlpha(0, TimeSec(0))
    infoBox:SetText("[CN]Injector Disabled")
  end
  
  local rotation = 0
  local bTch = true
  
  while true do     --wait for button/screen presses
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    
    --Exit
    if PAD:Data("START|B") then
      break
    
    --Enable/Disable if touched/pressed
    elseif PAD:Data("A") or getTouchBox(PAD:TouchPointData(),118,202,78,162) then
      if not bTch then
        bTch = true
        
        if injectorEnabled then
          sprtIcon:ChangeAlpha(0.3, TimeSec(0.5))
          injGlow:ChangeAlpha(0, TimeSec(0.5))
          injGlow2:ChangeAlpha(0, TimeSec(0.5))
          injectorDisable()
          infoBox:SetText("[CN]Injector Disabled")
        else
          sprtIcon:ChangeAlpha(1, TimeSec(0.5))
          injGlow:ChangeAlpha(1, TimeSec(0.5))
          injGlow2:ChangeAlpha(1, TimeSec(0.5))
          injectorEnable()
          infoBox:SetText("[CN]Injector Enabled")
        end
      end
    elseif bTch then
      bTch = false;
    end

    --Make glow and ring spin when enabled (because it looks cool)
    if injectorEnabled then
      rotation = rotation + 1
      if rotation >= 360 then rotation = 0 end
      sprtRing:SetRotate(Degree(rotation))
      injGlow:SetRotate(Degree(rotation))
      injGlow2:SetRotate(Degree(rotation+90))
    end
  
  end
  
  --remove glow ring
  SAJI:DestroySajiPlayer("injGlow")
  SAJI:DestroySajiPlayer("injGlow2")
  
  --remove sprites
  SPRITE:DestroySprite("sprtIconBG")
  SPRITE:DestroySprite("sprtIcon")
  SPRITE:DestroySprite("sprtRing")
  SPRITE:DestroyPatternSet("injCtrlSprts")
  
  --remove menus
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end

  --reset wallpaper
  LOWER_SCREEN:ChangeLastWallpaper()
  
--If injector is not running, show activation menu (boring GTI version)
else

    --Create menus
  CommonSys:OpenBasicMenu("Injector Control","[CN][M:B05]Toggle  [M:B06]Close", nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(110, 110, 100, 20))
  infoBox:SetText("[CN]Injector Enabled")
  infoBox:SetTextOffset(0, 1)
  infoBox:Open()
  
  if not injectorEnabled then
    infoBox:SetText("[CN]Injector Disabled")
  end
  
  local bTch = true
  
  while true do     --wait for button/screen presses
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    
    --Exit
    if PAD:Data("START|B") then
      break
    
    --Enable/Disable if touched/pressed
    elseif PAD:Data("A") or getTouchBox(PAD:TouchPointData(),100,220,100,138) then
      if not bTch then
        bTch = true
        
        if injectorEnabled then
          injectorDisable()
          infoBox:SetText("[CN]Injector Disabled")
        else
          injectorEnable()
          infoBox:SetText("[CN]Injector Enabled")
        end
      end
    elseif bTch then
      bTch = false;
    end
  end
  
  --remove menus
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
end