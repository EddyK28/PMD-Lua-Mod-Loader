--MIT License
--Copyright (c) 2018 EddyK28

local dist = 40
local height = 10
local orbChar = "HERO"
local spdist = 1
local FOV = 20

local function scale(v,n)
  return Vector(v.x*n,v.y*n,v.z*n)
end


local function menuOption(tid)

  --create a page menu
  local menu = MENU:CreatePageMenu()
  local selectID = 0
  
  --set some properties
  menu:SetLayoutRectAndLines(32, 38, 256, 8)
  
  --add menu items
  menu:AddItem("Exit", 0, nil)
  if tid ~= 1 then 
    menu:AddItem("Switch to Fly Cam", 1, nil)
  end
  if tid ~= 2 then 
    menu:AddItem("Switch to Spot Orbit", 2, nil)
  end
  if tid ~= 3 and not bIsDungeon then 
    menu:AddItem("Switch to Char Orbit", 3, nil)
  end
  if tid ~= 4 then 
    menu:AddItem("Switch to Cam Target", 4, nil)
  end
  menu:AddItem("Get Height", 5, nil)

  --set menu functions
  function menu:openedAction()
    MENU:SetFocus(self)
    CommonSys:OpenBasicMenu("PMD Free-Cam","[M:B12][M:B09]Select  [M:B05]Confirm  [M:B06]Cancel", nil)
    self:SetCursorItemIndex(0)
  end
  function menu:closedAction()
    if CommonSys.basicMenuStack ~= nil then
      CommonSys:CloseBasicMenu()
    end
    MENU:ClearFocus(self)
  end
  function menu:cancelAction()
    selectID = tid
    self:Close()
  end
  
  function menu:decideAction()
    selectID = self:GetSelectedItem()
  
    if selectID < 5 then
      self:Close()
    elseif selectID == 5 then  --TODO: get Cam/Tgt instead
      WINDOW:SysMsg("Height: "..height)
      WINDOW:CloseMessage()
    end
    
  end
  
  menu:Open()
  MENU:WaitClose(menu)
  return selectID
 
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
  CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
  
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(0.01))
    if PAD:Data("START") then   --open menu
      break
    
    elseif PAD:Data("Y") then   --toggle cam target
      if orbChar == "HERO" then
        orbChar = "PARTNER"
      else
        orbChar = "HERO"
      end
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
      while PAD:Data("Y") do
        TASK:Sleep(TimeSec(0.01))
      end
      
    elseif PAD:Data("A&L") then --orbit target slow
      CAMERA:SetEyeR(Degree(-PAD:StickY()), Degree(PAD:StickX()))
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
      
    elseif PAD:Data("A") then   --orbit target 
      CAMERA:SetEyeR(Degree(PAD:StickY()*-3), Degree(PAD:StickX()*3))
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
    
    elseif PAD:Data("B&L") then  --char rotate slow
      CH(orbChar):DirTo(RotateOffs(PAD:StickX()*3), Speed(1800))
      if PAD:Data("(UP|DOWN)") then
        if PAD:Edge("UP") then
          FOV = FOV - 1

        elseif PAD:Edge("DOWN") then
          FOV = FOV + 1
        end
        
        CAMERA:SetFovy(Degree(FOV))
        
        while PAD:Data("(UP|DOWN)") do
          TASK:Sleep(TimeSec(0.01))
        end
      end
    
    elseif PAD:Data("B") then   --char rotate?
      CH(orbChar):DirTo(RotateOffs(PAD:StickX()*6), Speed(1800))
      if PAD:Data("(UP|DOWN)") then
        if PAD:Edge("UP") then
          FOV = FOV - 10

        elseif PAD:Edge("DOWN") then
          FOV = FOV + 10
        end
        
        CAMERA:SetFovy(Degree(FOV))
        
        while PAD:Data("(UP|DOWN)") do
          TASK:Sleep(TimeSec(0.01))
        end
      end
     
    elseif PAD:Data("X&L") then --move character slow
      CH(orbChar):MoveTo(PosOffs(PAD:StickX()/6, -PAD:StickY()/6), Speed(4))
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
     
    elseif PAD:Data("X") then   --move character
      CH(orbChar):MoveTo(PosOffs(PAD:StickX(), -PAD:StickY()), Speed(4))
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
      
    elseif PAD:Data("R") then   --move target to cam height
      CH(orbChar):MoveHeightTo(Height(height/10), Speed(5))
      CH(orbChar):WaitMoveHeight()
      
    elseif PAD:Data("(RIGHT|LEFT|UP|DOWN)") then
      if PAD:Edge("RIGHT") then
        if PAD:Data("L") then
          dist = dist + 1
        else
          dist = dist + 5
        end

      elseif PAD:Edge("LEFT") then
        if PAD:Data("L") then
          dist = dist - 1
        else
          dist = dist - 5
        end

      elseif PAD:Edge("UP") then
        if PAD:Data("L") then
          height = height + 0.1
        else
          height = height + 1
        end

      elseif PAD:Edge("DOWN") then
        if PAD:Data("L") then
          height = height - 0.1
        else
          height = height - 1
        end
      end
      
      CAMERA:MoveFollowZoom(CH(orbChar), Height(height/10), Distance(dist/10), Speed(10))
      
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

local function orbitSpot()
  
  --Create info box on lower screen
  CommonSys:OpenBasicMenu("PMD Free-Cam (Spot Orbit)",nil, nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(32, 38, 256, 192))
  infoBox:SetText("[M:B10] Move up/down\n[M:B11] Move in/out\n\n[M:B12]+\n  [M:B05] Look\n  [M:B03] Move Camera\n  [M:B06] Zoom\n\n[M:B08] Slow Movement Modifier\n[M:B02] Menu")
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  
  
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(0.01))
    if PAD:Data("START") then   --open menu
      break
      
    elseif PAD:Data("B") then
      
      if PAD:Data("(UP|DOWN)") then
        if PAD:Edge("UP") then
          if PAD:Data("L") then
            FOV = FOV - 1
          else
            FOV = FOV - 10
          end
        
        elseif PAD:Edge("DOWN") then
          if PAD:Data("L") then
            FOV = FOV + 1
          else
            FOV = FOV + 10
          end
        end
        
        CAMERA:SetFovy(Degree(FOV))
        
        while PAD:Data("(UP|DOWN)") do
          TASK:Sleep(TimeSec(0.01))
        end
      end
      
    elseif PAD:Data("A&L") then --orbit target slow
      CAMERA:SetEyeR(Degree(PAD:StickY()), Degree(-PAD:StickX()))
      CAMERA:MoveFollowZoomR(Vector(0, 0, 0), Distance(spdist/10), Speed(10))
      
    elseif PAD:Data("A") then   --orbit target 
      CAMERA:SetEyeR(Degree(PAD:StickY()*3), Degree(PAD:StickX()*-3))
      CAMERA:MoveFollowZoomR(Vector(0, 0, 0), Distance(spdist/10), Speed(10))
    
    elseif PAD:Data("X&L") then   --camera move slow
      CAMERA:MoveFollowZoomR(Vector(PAD:StickX()/6, 0, -PAD:StickY()/6), Distance(spdist/10), Speed(10))
    
    elseif PAD:Data("X") then   --camera move
      CAMERA:MoveFollowZoomR(Vector(PAD:StickX()/3, 0, -PAD:StickY()/3), Distance(spdist/10), Speed(10))
      
    elseif PAD:Data("(RIGHT|LEFT|UP|DOWN)") then
      if PAD:Edge("RIGHT") then
        if PAD:Data("L") then
          spdist = spdist + 1
        else
          spdist = spdist + 5
        end
        CAMERA:MoveFollowZoomR(Vector(0, 0, 0), Distance(spdist/10), Speed(10))

      elseif PAD:Edge("LEFT") then
        if PAD:Data("L") then
          spdist = spdist - 1
        else
          spdist = spdist - 5
        end
        CAMERA:MoveFollowZoomR(Vector(0, 0, 0), Distance(spdist/10), Speed(10))

      elseif PAD:Edge("UP") then
        if PAD:Data("L") then
          CAMERA:MoveFollowZoomR(Vector(0, 0.1, 0), Distance(spdist/10), Speed(10))
        else
          CAMERA:MoveFollowZoomR(Vector(0, 1, 0), Distance(spdist/10), Speed(10))
        end

      elseif PAD:Edge("DOWN") then
        if PAD:Data("L") then
          CAMERA:MoveFollowZoomR(Vector(0, -0.1, 0), Distance(spdist/10), Speed(10))
        else
          CAMERA:MoveFollowZoomR(Vector(0, -1, 0), Distance(spdist/10), Speed(10))
        end
      end
      
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
  infoBox:SetText("D-Pad:\n  Default: Move Target\n  A: Move Camera\n  L: Slow Movement Modifier\n  R: Vertical Movement Modifier\n\nX: Mover Char to Target\nY: Reset Camera\nStart: Menu\n\nCamera: " .. posStr .. "\nTarget: " .. tgtStr)
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  
  while true do     --wait for button presses
    TASK:Sleep(TimeSec(0.01))
    if PAD:Data("START") then   --open menu
      break
    elseif PAD:Data("X") then
      if PAD:Data("R") then
        CH("PARTNER"):MoveTo(Vector2(camtgt.x, camtgt.z),Speed(350))
      else
        CH("HERO"):MoveTo(Vector2(camtgt.x, camtgt.z),Speed(350))
      end
    elseif PAD:Data("Y") then
      CAMERA:MoveEye(Vector(0, 5, 5), Speed(5))
      CAMERA:MoveTgt(Vector(0, 0, 0), Speed(5))
      CAMERA:WaitMove()
      campos = CAMERA:GetEye()
      camtgt = CAMERA:GetTgt()
      posStr = string.format("%.1f, %.1f, %.1f", campos.x, campos.y, campos.z)
      tgtStr = string.format("%.1f, %.1f, %.1f", camtgt.x, camtgt.y, camtgt.z)
      infoBox:SetText("D-Pad:\n  Default: Move Target\n  A: Move Camera\n  L: Slow Movement Modifier\n  R: Vertical Movement Modifier\n\nX: Mover Char to Target\nY: Reset Camera\nStart: Menu\n\nCamera: " .. posStr .. "\nTarget: " .. tgtStr)
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
        CAMERA:MoveEye(campos, Speed(5))
      else
        camtgt = camtgt + camofs
        CAMERA:MoveTgt(camtgt, Speed(5))
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
  
  --Camera Position/Rotation vectors
  local campos = CAMERA:GetEye()
  local m = (CAMERA:GetTgt() - campos):Normalize()
  local left = Vector(m.z,0,-m.x):Normalize()

  --touch/stick var
  local tchPt
  local pX,pY
  
  --configurable properties
  local mvSpeed = 0.15
  local lkSpeed = 0.04
  local tgtDist = 5
  local IDA = 1
  local vLock = false
  
  --flag and things
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
  
  CAMERA:MoveTgt(campos+m, Speed(350))
  
  --Create info box on lower screen
  CommonSys:OpenBasicMenu("PMD Free-Cam (Fly Cam)",nil, nil)
  local infoBox = MENU:CreateBoardMenuWindow(ScreenType.B)
  infoBox:SetLayoutRect(Rectangle(32, 38, 256, 192))
  infoBox:SetText(txtLbl .. txtArU ..
    txtVal:format(lkSpeed*1000, mvSpeed*100, FOV) .. txtArD ..
    txtTgt:format(tgtDist) .. txtIDA:format(IDA) .. txtVlk .. txtBox .. txtBtn)
  infoBox:SetTextOffset(1, 1)
  infoBox:Open()
  

  
  while true do     --wait for button presses
    mv = false
    TASK:Sleep(TimeSec(0.01))
    
    --get touch coords and process touches
    tchPt = PAD:TouchPointData()
    if tchPt.x > -1 then
      if not bTch then
        bTch = true
        if tchPt.y < 136 then
          if tchPt.x > 50 and tchPt.x < 93 then
            if tchPt.y > 76 and tchPt.y < 89 and lkSpeed < 1 then
              lkSpeed = lkSpeed + 0.001*IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and lkSpeed > 0.001 then
              lkSpeed = lkSpeed - 0.001*IDA
            end        
          elseif tchPt.x > 138 and tchPt.x < 181 and mvSpeed < 10 then
            if tchPt.y > 76 and tchPt.y < 89 then
              mvSpeed = mvSpeed + 0.01*IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and mvSpeed > 0.01 then
              mvSpeed = mvSpeed - 0.01*IDA
            end
          elseif tchPt.x > 226 and tchPt.x < 270 then
            if tchPt.y > 76 and tchPt.y < 89 and FOV < 1000 then
              FOV = FOV + 1*IDA
            elseif tchPt.y > 121 and tchPt.y < 132 and FOV > 1 then
              FOV = FOV - 1*IDA
            end
            CAMERA:SetFovy(Degree(FOV))
          end
        else
          if tchPt.y > 151 and tchPt.y < 163 then
            if tchPt.x > 122 and tchPt.x < 133 and tgtDist > 1 then
              tgtDist = tgtDist - 1*IDA
              mv = true
            elseif tchPt.x > 178 and tchPt.x < 190 and tgtDist < 1000 then
              tgtDist = tgtDist + 1*IDA
              mv = true
            end
          elseif tchPt.y > 170 and tchPt.y < 184 then
            if tchPt.x > 122 and tchPt.x < 133 and IDA > 1 then
              IDA = IDA - 1
              mv = true
            elseif tchPt.x > 178 and tchPt.x < 190 and IDA < 1000 then
              IDA = IDA + 1
              mv = true
            elseif tchPt.x > 242 and tchPt.x < 259 then
              vLock = not vLock
              if vLock then
                txtBox = "[M:Q00]"
              else
                txtBox = "[M:Q05]"
              end
            end
          end
          
        end
        infoBox:SetText(txtLbl .. txtArU ..
          txtVal:format(lkSpeed*1000, mvSpeed*100, FOV) .. txtArD ..
          txtTgt:format(tgtDist) .. txtIDA:format(IDA) .. txtVlk .. txtBox .. txtBtn)
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
      m.x=x1*math.cos(pX*lkSpeed)-y1*math.sin(pX*lkSpeed)
      m.z=x1*math.sin(pX*lkSpeed)+y1*math.cos(pX*lkSpeed)
      left = Vector(m.z,0,-m.x):Normalize()
      mv = true
    end
    
    --if up or down stick, 
    if pY > 0.005 or pY < -0.005 then
      m.y = m.y+pY*lkSpeed/1.5
      m:Normalize()
      mv = true
    end
    
    
    --Process buttons
    if PAD:Data("START") then   --open menu
      break
      
    elseif PAD:Data("(A|B|X|Y|L|R)") then    
      if PAD:Data("X") then
        tmp = Vector(m)
        if vLock then
          tmp.y = 0
          tmp:Normalize()
        end
        campos = campos+scale(tmp,mvSpeed)
      elseif PAD:Data("B") then
        tmp = Vector(m)
        if vLock then
          tmp.y = 0
          tmp:Normalize()
        end
        campos = campos-scale(tmp,mvSpeed)
      end

      if PAD:Data("Y") then
        campos = campos+scale(left,mvSpeed)
      end
      if PAD:Data("A") then
        campos = campos-scale(left,mvSpeed)
      end

      if PAD:Data("L") then
        campos = campos-Vector(0,mvSpeed/1.5,0)
      end
      if PAD:Data("R") then
        campos = campos+Vector(0,mvSpeed/1.5,0)
      end

      mv = true
    end
    
    if mv then
      CAMERA:MoveEye(campos, Speed(350))
      CAMERA:MoveTgt(campos+scale(m,tgtDist), Speed(350))
    end
  end
  
  infoBox:Close()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
end

--MAIN--  
   
  --clear upper screen
  CommonSys:EndLowerMenuNavi(true)
  
  --start on Fly Cam
  local id = 1
  
  repeat
    if id == 1 then
      flyCam()
    elseif id == 2 then
      orbitSpot()
    elseif id == 3 then
      orbitChar()
    elseif id == 4 then
      tgtEye()
    end
    id = menuOption(id)
  until id == 0
  
  --reopen upper screen info 
  if not bIsGates then
    CommonSys:BeginLowerMenuNavi_GroundItem(GROUND:GetWorldContinentName(), GROUND:GetWorldPlaceName(), true, true)
  end
  
  WINDOW:CloseMessage()
