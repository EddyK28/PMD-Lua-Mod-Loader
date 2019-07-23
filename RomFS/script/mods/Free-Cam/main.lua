--====PMD 3/4 Free-Cam Mod====--
--MIT License
--Copyright (c) 2019 EddyK28


--for Gates compatibility (long story)
local chkO = MENU:ReplaceTagText("[M:Q05]")
local chkX = MENU:ReplaceTagText("[M:Q00]")

--Camera functions (for injector compatibility)
local cam = {}
local camFunctions = {
  "MoveFollowZoom",
  "MoveFollowZoomR",
  "SetEyeR",
  "MoveEye",
  "MoveTgt"
}
local SetWindowWaitMode

--Set local camera functions based on injector status
local function setCamFunctions()
  for i,func in ipairs(camFunctions) do
    if injectorRunning then
      cam[func] = CAMERA[func.."Or"]
    else
      cam[func] = CAMERA[func]
    end
  end
  if injectorRunning then
    SetWindowWaitMode = WINDOW.SetWaitModeOr
  else
    SetWindowWaitMode = WINDOW.SetWaitMode
  end
end

--Basic 3D vector scale function
local function scale(v,n)
  return Vector(v.x*n,v.y*n,v.z*n)
end


local function orbitChar()
  --Create info box on lower screen
  CommonSys:OpenBasicMenu("PMD Free-Cam (Char Orbit)",nil, nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(32, 38, 256, 192))
  infoBox:SetText("[M:B10] Move up/down\n[M:B11] Move in/out\n\n[M:B12]+\n  [M:B05] Orbit\n  [M:B03] Move Character\n  [M:B06] Rotate Character / Zoom\n\n[M:B08] Slow Movement Modifier\n[M:B04] Switch Hero/Partner\n[M:B07] Move character to cam height\n[M:B02] Menu")
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  
  --move camera to target
  cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
  --TODO: set FOV too
  
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    if PAD:Data("START") then   --open menu
      break
    
    elseif PAD:Data("Y") then   --toggle cam target
      if FC_orbChar == "HERO" then
        FC_orbChar = "PARTNER"
      else
        FC_orbChar = "HERO"
      end
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
      while PAD:Data("Y") do
        TASK:Sleep(TimeSec(0.01))
      end
      
    elseif PAD:Data("A&L") then --orbit target slow
      cam.SetEyeR(CAMERA,Degree(-PAD:StickY()), Degree(PAD:StickX()))
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
      
    elseif PAD:Data("A") then   --orbit target 
      cam.SetEyeR(CAMERA,Degree(PAD:StickY()*-3), Degree(PAD:StickX()*3))
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
    
    elseif PAD:Data("B&L") then  --char rotate slow
      CH(FC_orbChar):DirTo(RotateOffs(PAD:StickX()*3), Speed(1800))
      if PAD:Data("(UP|DOWN)") then
        if PAD:Edge("UP") then
          FC_FOV = FC_FOV - 1

        elseif PAD:Edge("DOWN") then
          FC_FOV = FC_FOV + 1
        end
        
        CAMERA:SetFovy(Degree(FC_FOV))
        
        while PAD:Data("(UP|DOWN)") do
          TASK:Sleep(TimeSec(0.01))
        end
      end
    
    elseif PAD:Data("B") then   --char rotate?
      CH(FC_orbChar):DirTo(RotateOffs(PAD:StickX()*6), Speed(1800))
      if PAD:Data("(UP|DOWN)") then
        if PAD:Edge("UP") then
          FC_FOV = FC_FOV - 10

        elseif PAD:Edge("DOWN") then
          FC_FOV = FC_FOV + 10
        end
        
        CAMERA:SetFovy(Degree(FC_FOV))
        
        while PAD:Data("(UP|DOWN)") do
          TASK:Sleep(TimeSec(0.01))
        end
      end
     
    elseif PAD:Data("X&L") then --move character slow
      CH(FC_orbChar):MoveTo(PosOffs(PAD:StickX()/6, -PAD:StickY()/6), Speed(4))
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
     
    elseif PAD:Data("X") then   --move character
      CH(FC_orbChar):MoveTo(PosOffs(PAD:StickX(), -PAD:StickY()), Speed(4))
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
      
    elseif PAD:Data("R") then   --move target to cam height
      CH(FC_orbChar):MoveHeightTo(Height(FC_orbheight/10), Speed(5))
      CH(FC_orbChar):WaitMoveHeight()
      
    elseif PAD:Data("(RIGHT|LEFT|UP|DOWN)") then
      if PAD:Edge("RIGHT") then
        if PAD:Data("L") then
          FC_orbdist = FC_orbdist + 1
        else
          FC_orbdist = FC_orbdist + 5
        end

      elseif PAD:Edge("LEFT") then
        if PAD:Data("L") then
          FC_orbdist = FC_orbdist - 1
        else
          FC_orbdist = FC_orbdist - 5
        end

      elseif PAD:Edge("UP") then
        if PAD:Data("L") then
          FC_orbheight = FC_orbheight + 0.1
        else
          FC_orbheight = FC_orbheight + 1
        end

      elseif PAD:Edge("DOWN") then
        if PAD:Data("L") then
          FC_orbheight = FC_orbheight - 0.1
        else
          FC_orbheight = FC_orbheight - 1
        end
      end
      
      cam.MoveFollowZoom(CAMERA,CH(FC_orbChar), Height(FC_orbheight/10), Distance(FC_orbdist/10), Speed(10))
      
      while PAD:Data("(RIGHT|LEFT|UP|DOWN)") do
        TASK:Sleep(TimeSec(0.01))
      end

    else
      
    end
  end
  
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
end

local function tgtEye()
  local campos = CAMERA:GetEye()
  local camtgt = CAMERA:GetTgt()
  local camofs = Vector(0, 0, 0)
  local mult = 1
  
  local posStr = string.format("%.1f, %.1f, %.1f", campos.x, campos.y, campos.z)
  local tgtStr = string.format("%.1f, %.1f, %.1f", camtgt.x, camtgt.y, camtgt.z)
  
  --Create info box on lower screen
  CommonSys:OpenBasicMenu("PMD Free-Cam (Cam Target)",nil, nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(32, 38, 256, 192))
  infoBox:SetText("D-Pad:\n  Default: Move Target\n  A: Move Camera\n  L: Slow Movement Modifier\n  R: Vertical Movement Modifier\n\nX: Move Char to Target\nY: Reset Camera\nStart: Menu\n\nCamera: " .. posStr .. "\nTarget: " .. tgtStr)
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    if PAD:Data("X") and not injectorRunning then
      if PAD:Data("R") then
        --CH("PARTNER"):MoveTo(Vector2(camtgt.x, camtgt.z),Speed(350))
        CH("PARTNER"):SetPosition(camtgt)
      else
        --CH("HERO"):MoveTo(Vector2(camtgt.x, camtgt.z),Speed(350))
        CH("HERO"):SetPosition(camtgt)
      end
    end
    
    if PAD:Data("START") then   --open menu
      break
    --else
    elseif PAD:Data("Y") then
      cam.MoveEye(CAMERA,Vector(0, 5, 5), Speed(5))
      cam.MoveTgt(CAMERA,Vector(0, 0, 0), Speed(5))
      CAMERA:WaitMove()
      campos = CAMERA:GetEye()
      camtgt = CAMERA:GetTgt()
      posStr = string.format("%.1f, %.1f, %.1f", campos.x, campos.y, campos.z)
      tgtStr = string.format("%.1f, %.1f, %.1f", camtgt.x, camtgt.y, camtgt.z)
      infoBox:SetText("D-Pad:\n  Default: Move Target\n  A: Move Camera\n  L: Slow Movement Modifier\n  R: Vertical Movement Modifier\n\nX: Move Char to Target\nY: Reset Camera\nStart: Menu\n\nCamera: " .. posStr .. "\nTarget: " .. tgtStr)
    elseif PAD:Data("(RIGHT|LEFT|UP|DOWN)") then
      if PAD:Data("L") then
        mult = 0.1
      else
        mult = 1
      end
    
      if PAD:Edge("RIGHT") then
        camofs = Vector(mult, 0, 0)
      elseif PAD:Edge("LEFT") then
        camofs = Vector(-mult, 0, 0)
      elseif PAD:Edge("UP") then
        camofs = Vector(0, 0, -mult)
      elseif PAD:Edge("DOWN") then
        camofs = Vector(0, 0, mult)
      end
      
      if PAD:Data("R") then
        camofs = Vector(0, -camofs.z, 0)
      end
      
      if PAD:Data("A") then
        campos = campos + camofs
        cam.MoveEye(CAMERA,campos, Speed(5))
      else
        camtgt = camtgt + camofs
        cam.MoveTgt(CAMERA,camtgt, Speed(5))
      end
      
      posStr = string.format("%.1f, %.1f, %.1f", campos.x, campos.y, campos.z)
      tgtStr = string.format("%.1f, %.1f, %.1f", camtgt.x, camtgt.y, camtgt.z)
      infoBox:SetText("D-Pad:\n  Default: Move Target\n  A: Move Camera\n  L: Slow Movement Modifier\n  R: Vertical Movement Modifier\n\nX: Mover Char to Target\nY: Reset Camera\nStart: Menu\n\nCamera: " .. posStr .. "\nTarget: " .. tgtStr)
      
      while PAD:Data("(RIGHT|LEFT|UP|DOWN)") do
        TASK:Sleep(TimeSec(0.01))
      end

    end
  end
  
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
end

local function flyCam()
  
  --Camera Position/Rotation vectors (and initialization)
  local campos = CAMERA:GetEye()
  local m = (CAMERA:GetTgt() - campos):Normalize()
  local left = Vector(m.z,0,-m.x):Normalize()

  --touch/stick var
  local tchPt
  local pX,pY
  
  --configurable properties
  local tgtDist = 5
  
  --flags and things
  local mv = false
  local bTch = false
  local tmp
  
  --menu text
  local txtLbl = "[HO:26]Look[HO:114]Move[HO:205][VO:8]FOV[VO:00]\n[HO:24]Speed[HO:112]Speed[VS:5]\n"
  local txtArU = "[CN][M:OP02][M:OP02][M:OP02][S:40][M:OP02][M:OP02][M:OP02][S:40][M:OP02][M:OP02][M:OP02][VS:5]\n"
  local txtArD = "[VS:5][CN][M:OP03][M:OP03][M:OP03][S:40][M:OP03][M:OP03][M:OP03][S:40][M:OP03][M:OP03][M:OP03]\n"
  local txtBtn = "[VO:174][CN][M:B12] Look  [M:B05][M:B06][M:B03][M:B04][M:B08][M:B07] Move   [M:B02] Menu"
  local txtVal = "[HO:30]%03d[HO:117]%03d[HO:206]%03d\n"
  local txtTgt = "\n[HO:18]Target Dist  [M:OP00]  %03d  [M:OP01][VS:5]\n"
  local txtIDA = "[HO:13]Inc/Dec Amt  [M:OP00]  %03d  [M:OP01]\n"
  local txtVlk = "[HO:197][VO:115]V-Lock\n[HO:209][VO:130]"
  local txtBox = "[M:Q05]"
  local txtInj = ""
  if FC_vLock then
    txtBox = "[M:Q00]"
  end
  
  --Initialize Camera
  cam.MoveTgt(CAMERA,campos+m, Speed(350))
  CAMERA:SetFovy(Degree(FC_FOV))
  
  --Initialize injector controls if running
  local injBtn, btnRun, btnBrk = "", "", ""
  if injectorRunning then
    if bIsGates then
      txtInj = "\n[VS:8][HO:61]샰샱샱샱샱샱샱샲[HS:3]샰샱샱샱샱샱샱샲[HO:13][VS:1]Injector:[HS:12][CS:7]%s[CR]"
      btnRun = "[HS:5]Run ->[HS:26]Step [VS:5][M:CUD]"
      btnBrk = "[HS:2]Break ||[HS:26]-------"
    else
      txtInj = "\n[VS:9][HO:61]ꀮꀯꀯꀯꀯꀯꀯꀰ[HS:3]ꀮꀯꀯꀯꀯꀯꀯꀰ[HO:13][VS:255]Injector:[HS:12][CS:7]%s[CR]"
      btnRun = " Run [M:EPLAY][HS:26]Step ꀩ"
      btnBrk = "Break [M:EPAUSE][HS:20]-------"
    end
    if injectorBreak < 2 then
      injBtn = btnRun
    else
      injBtn = btnBrk
    end
  end
  
  --Create info box on lower screen
  CommonSys:OpenBasicMenu("PMD Free-Cam (Fly Cam)",nil, nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(32, 38, 256, 192))
  infoBox:SetText(txtLbl .. txtArU ..
    txtVal:format(FC_lkSpeed*1000, FC_mvSpeed*100, FC_FOV) .. txtArD ..
    txtTgt:format(tgtDist) .. txtIDA:format(FC_IDA) .. txtVlk .. txtBox .. txtInj:format(injBtn) .. txtBtn)
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  
  --Create injector info box if running from injector
  local infoInj
  if injectorRunning then
    infoInj = MENU:CreateBoardMenuWindow(ScreenType.B)
    infoInj:SetLayoutRect(Rectangle(0, 0, 0, 0))
    infoInj:SetText("  ")
    infoInj:SetTextOffset(226, 193)
    infoInj:Open()
    local function taskInfoUpd()
      function TaskL.Loop()
        if injectorBreak < 2 then
          if injectorBreakData then
            infoInj:SetText(injectorBreakData.name)
          else
            infoInj:SetText("     ......")
          end
        else
          infoInj:SetText("(Running)")
        end
        TASK:Sleep(TimeSec(5, TIME_TYPE.FRAME))
      end
    end
    TASK:Regist(Group("InfoUpd"), taskInfoUpd)
  end
  
  while true do     --wait for button/screen presses
    mv = false
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
    
    --get touch coords and process touches
    tchPt = PAD:TouchPointData()
    if tchPt.x > -1 then
      if not bTch then
        bTch = true
        
        if tchPt.y < 136 then   --Top Row Buttons
        
          --Look speed buttons
          if tchPt.x > 50 and tchPt.x < 93 then
            if tchPt.y > 76 and tchPt.y < 89 and FC_lkSpeed < 1-0.001*FC_IDA then
              FC_lkSpeed = FC_lkSpeed + 0.001*FC_IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and FC_lkSpeed > 0.001*FC_IDA then
              FC_lkSpeed = FC_lkSpeed - 0.001*FC_IDA
            end  

          --Move speed buttons
          elseif tchPt.x > 138 and tchPt.x < 181  then
            if tchPt.y > 76 and tchPt.y < 89 and FC_mvSpeed < 10-0.01*FC_IDA then
              FC_mvSpeed = FC_mvSpeed + 0.01*FC_IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and FC_mvSpeed > 0.01*FC_IDA then
              FC_mvSpeed = FC_mvSpeed - 0.01*FC_IDA
            end
            
          --FOV buttons
          elseif tchPt.x > 226 and tchPt.x < 270 then
            if tchPt.y > 76 and tchPt.y < 89 and FC_FOV < 180-FC_IDA then
              FC_FOV = FC_FOV + FC_IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and FC_FOV > FC_IDA then
              FC_FOV = FC_FOV - FC_IDA
            end
            CAMERA:SetFovy(Degree(FC_FOV))
          end
          
        else    --Remaining Buttons
          if tchPt.y > 151 and tchPt.y < 163 then
            if tchPt.x > 122 and tchPt.x < 133 and tgtDist > FC_IDA then
              tgtDist = tgtDist - FC_IDA
              mv = true
            elseif tchPt.x > 178 and tchPt.x < 190 and tgtDist < 1000 then
              tgtDist = tgtDist + FC_IDA
              mv = true
            end
          elseif tchPt.y > 170 and tchPt.y < 184 then
            if tchPt.x > 122 and tchPt.x < 133 and FC_IDA > 1 then
              FC_IDA = FC_IDA - 1
              mv = true
            elseif tchPt.x > 178 and tchPt.x < 190 and FC_IDA < 1000 then
              FC_IDA = FC_IDA + 1
              mv = true
            elseif tchPt.x > 242 and tchPt.x < 259 then
              FC_vLock = not FC_vLock
              if FC_vLock then
                txtBox = "[M:Q00]"
              else
                txtBox = "[M:Q05]"
              end
            end
          elseif tchPt.y > 194 and tchPt.y < 208 and injectorRunning then
            if tchPt.x > 97 and tchPt.x < 154 then
              if injectorBreak < 2 then
                injectorBreak = 2
                injBtn = btnBrk
              else
                injectorBreak = 0
                injBtn = btnRun
              end            
            elseif tchPt.x > 164 and tchPt.x < 221 and injectorBreak < 2 then
              if injectorBreakData then
                injectorBreak = 1 
              else
                injectorBreak = 2
                TASK:Sleep(TimeSec(2, TIME_TYPE.FRAME))
                injectorBreak = 0
              end
            end 
          elseif tchPt.y > 214 and tchPt.y < 227 then
            if tchPt.x > 228 and tchPt.x < 289 then
              break
            end
          end
          
        end
        
        infoBox:SetText(txtLbl .. txtArU ..
          txtVal:format(FC_lkSpeed*1000, FC_mvSpeed*100, FC_FOV) .. txtArD .. txtTgt:format(tgtDist) ..
          txtIDA:format(FC_IDA) .. txtVlk .. txtBox .. txtInj:format(injBtn) .. txtBtn) 
      end
    else
      bTch = false
    end

  
    --get stick coords
    pX = PAD:StickX()
    pY = PAD:StickY()
    
    --if left or right stick, rotate m around 'up' axis
    if pX > 0.005 or pX < -0.005 then
      local x1,y1 = m.x, m.z
      m.x=x1*math.cos(pX*FC_lkSpeed)-y1*math.sin(pX*FC_lkSpeed)
      m.z=x1*math.sin(pX*FC_lkSpeed)+y1*math.cos(pX*FC_lkSpeed)
      left = Vector(m.z,0,-m.x):Normalize()
      mv = true
    end
    
    --if up or down stick, 
    if pY > 0.005 or pY < -0.005 then
      m.y = m.y+pY*FC_lkSpeed/1.5
      m:Normalize()
      mv = true
    end
    
    
    --Process buttons
    if PAD:Data("START") then   --open menu
      break
      
    elseif PAD:Data("(A|B|X|Y|L|R)") then    
      if PAD:Data("X") then
        tmp = Vector(m)
        if FC_vLock then
          tmp.y = 0
          tmp:Normalize()
        end
        campos = campos+scale(tmp,FC_mvSpeed)
      elseif PAD:Data("B") then
        tmp = Vector(m)
        if FC_vLock then
          tmp.y = 0
          tmp:Normalize()
        end
        campos = campos-scale(tmp,FC_mvSpeed)
      end

      if PAD:Data("Y") then
        campos = campos+scale(left,FC_mvSpeed)
      end
      if PAD:Data("A") then
        campos = campos-scale(left,FC_mvSpeed)
      end

      if PAD:Data("L") then
        campos = campos-Vector(0,FC_mvSpeed/1.5,0)
      end
      if PAD:Data("R") then
        campos = campos+Vector(0,FC_mvSpeed/1.5,0)
      end

      mv = true
    end
    
    if mv then
      cam.MoveEye(CAMERA,campos, Speed(350))
      cam.MoveTgt(CAMERA,campos+scale(m,tgtDist), Speed(350))
    end
  end
  
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
  if injectorRunning then
    TASK:ExitNotifyTasks(Group("InfoUpd"))
    infoInj:Close()
  end
end

local function runMode(menu,mode)
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
  menu:SetVisible(false)
  mode()
  menu:SetVisible(true)
  MENU:SetFocus(menu)
  CommonSys:OpenBasicMenu("PMD Free-Cam","[M:B12][M:B09]Select  [M:B05]Confirm  [M:B06]Back", nil)
  menu:SetCursorItemIndex(0)
end

--MAIN--  
   
  --clear upper screen --TODO: don't do this if injector is running?
  CommonSys:EndLowerMenuNavi(true)
  
  --initialize camera functions (for injector compatibility)
  setCamFunctions()
  
  --Initialize global settings vars
  FC_mvSpeed = FC_mvSpeed or 0.15
  FC_lkSpeed = FC_lkSpeed or 0.04
  FC_tgtDist = FC_tgtDist or 5
  FC_IDA = FC_IDA or 1
  FC_vLock = FC_vLock or false
  FC_FOV = FC_FOV or 20
  
  FC_orbdist = FC_orbdist or 40
  FC_orbheight = FC_orbheight or 10
  FC_orbChar = FC_orbChar or "HERO"
  
  if FC_textAdv == nil then FC_textAdv = true end
  
  --create a page menu
  local menu = MENU:CreatePageMenu()
  local activeIdx = 2  --start on Fly Cam
  
  --set some settings based on injector status
  if injectorRunning then
    menu:SetLayoutRectAndLines(32, 38, 256, 7)
  else
    menu:SetLayoutRectAndLines(32, 38, 256, 6)
  end
  
  
  --add menu items and unique functions
  menu:AddItem("Exit", nil, {decideAction = function(self) self:Close() end})
  menu:AddItem("[CS:5]Mode:", 0, nil)
  menu:AddItem("  Fly Cam [M:CUL]     ", {flyCam}, nil)
  if not injectorRunning then
    menu:AddItem("  Char Orbit", {orbitChar}, nil)  --Char Orbit not compatible with injector
  end
  menu:AddItem("  Cam Target", {tgtEye}, nil)
  menu:AddItem("Get Cam Position", 1, nil)
  
  if injectorRunning then
    menu:AddItem("Clear Screen", 2, nil)
    if FC_textAdv then
      menu:AddItem("Auto-Advance Text "..chkX, 3, nil)
      SetWindowWaitMode(WINDOW,TimeSec(1.5),TimeSec(0.5))
    else
      menu:AddItem("Auto-Advance Text "..chkO, 3, nil)
      SetWindowWaitMode(WINDOW,TimeSec(-1),TimeSec(-1))
    end
  end
  
  --set menu functions
  function menu:openedAction()
    --disable Mode and flyCam buttons
    self:SetCurrentModifyItem(1)
    self.curItem.grayed = true
    self:SetCurrentModifyItem(2)
    self.curItem.grayed = true
    
    runMode(self,flyCam)
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
    if type(self.curItem.obj) == "table" then
      --gray out and mark the selected mode
      self.curItem.grayed = true
      self.curItem.text = self.curItem.text .. " [M:CUL]"
      
      --hold onto the old active idx and set the new one
      local oldIdx = activeIdx
      activeIdx = self.curItem.index
      
      --ungray and unmark the old mode
      self:SetCurrentModifyItem(oldIdx)
      self.curItem.grayed = false
      self.curItem.text = self.curItem.text:sub(1,-9)

    elseif type(self.curItem.obj) == "number" then
      --get camera position
      if self.curItem.obj == 1 then
        local campos = CAMERA:GetEye()
        local camtgt = CAMERA:GetTgt()
        local str = string.format("Camera:[S:3]%.2f,[S:3]%.2f,[S:3]%.2f\n", campos.x, campos.y, campos.z)
        str = str .. string.format("Target:[S:3]%.2f,[S:3]%.2f,[S:3]%.2f\n", camtgt.x, camtgt.y, camtgt.z)
        if injectorRunning and FC_textAdv then SetWindowWaitMode(WINDOW,TimeSec(-1),TimeSec(-1)) end
        WINDOW:SysMsg(str)
        WINDOW:CloseMessage()
        if injectorRunning and FC_textAdv then SetWindowWaitMode(WINDOW,TimeSec(1.5),TimeSec(0.5)) end
        
      --clear screen
      elseif self.curItem.obj == 2 then
        WINDOW:CloseMessage()
        WINDOW:RemoveFace()
        SCREEN_A:FadeInAllOr(TimeSec(0), true)

      --toggle text advance
      elseif self.curItem.obj == 3 then
        if FC_textAdv then
          self.curItem.text = self.curItem.text:sub(1,-4)..chkO
          SetWindowWaitMode(WINDOW,TimeSec(-1),TimeSec(-1))
        else
          self.curItem.text = self.curItem.text:sub(1,-4)..chkX
          SetWindowWaitMode(WINDOW,TimeSec(1.5),TimeSec(0.5))
        end
        FC_textAdv = not FC_textAdv
      end
    end
  end
  
  function menu:cancelAction()
    self:SetCurrentModifyItem(activeIdx)
    runMode(self,self.curItem.obj[1])
  end
  
  function menu:closedAction()
    if CommonSys.basicMenuStack ~= nil then
      CommonSys:CloseBasicMenu()
    end
    MENU:ClearFocus(self)
  end
  
  menu:Open()
  MENU:WaitClose(menu)
  
  
  --reopen upper screen info.  can hold L or X to keep top screen clear
  if not (bIsGates or injectorRunning or PAD:Data("L|X")) then
    CommonSys:BeginLowerMenuNavi_GroundItem(GROUND:GetWorldContinentName(), GROUND:GetWorldPlaceName(), true, true)
  end
  
  if injectorRunning and FC_textAdv then
    SetWindowWaitMode(WINDOW,TimeSec(-1),TimeSec(-1))
  end
  
  WINDOW:CloseMessage()