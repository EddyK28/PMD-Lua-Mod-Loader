--====PMD 4 Pokemon Modifier====--
--MIT License
--Copyright (c) 2019 EddyK28

local function getCount(caption)
  local count = 0
  
  local menu = MENU:CreateNumericMenuWindow(ScreenType.A) --create a numeric entry window
  menu:SetLayoutRect(Rectangle(72, 95, 256, 66))          --set window position/size
  menu:SetPlace(3)                                        --
  menu:SetDigit(3)                                        --
  menu:SetStartNum(1)                                     --set initial value
  menu:SetType(NUM_MENU_TYPE.TYPE_DIGIT_ON)
  menu:SetTextOffset(92, 12)                              --position menu text
  
  function menu:decideAction()                            --menu accept function
    count = self:GetSettingData()                         --get & store selection value
    self:Close() 
  end 
  function menu:cancelAction()                            --menu cancel function
    count = 0
    self:Close()                                            --close menu
  end
  
  menu:Open()                                             --open menu
  menu:SetCaption(caption)                                --set menu caption
  MENU:SetFocus(menu)                                     --focus menu 
  MENU:WaitClose(menu)                                    --wait for it to close
  
  return count
end

local function getOption(caption, options)
  WINDOW:CloseMessage()
  WINDOW:SysMsg(caption)
  local id = 0
  
  WINDOW:SelectStart()
  for i,opt in ipairs(options) do
    WINDOW:SelectChain(opt, i)
  end
  WINDOW:DefaultCursor(0)
  
  id = WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  return id
end

--open menu title/button hints
CommonSys:OpenBasicMenu("Pokemorph","[M:B05]Select  [M:B06]Close  [M:B03]Jump To", nil)

--create a page menu for item selection
local menu = MENU:CreatePageMenu()
menu:SetLayoutRectAndLines(32, 38, 256, 9)
menu:ShowPageNum(true)

--create face display menu
faceMenu = MENU:CreateFaceMenuWindow(ScreenType.B)
faceMenu:SetFacePos(220, 100)
faceMenu:SetFaceType(FACE_TYPE.NORMAL)
faceMenu:SetPokemonIndex(0)

GROUND:SortPokemonWarehouseByNo()
for i = 0, 980 do
  menu:AddItem(""..i..": "..FUNC_COMMON:GetPokemonName(i), i, nil) --GetPokemonName
end

function menu:decideAction()
  MENU:ClearFocus(self)
  local id = self:GetCursorItemIndex()
  local sel = getOption("Set쐃as:",{"Cancel","Hero","Partner","New쐃Teammate"})
  
  --set as Hero
  if sel == 2 then
    GROUND_DEBUG:SetWareHouse_HERO(id)
    CHARA:ReloadHeroPartner() 
    
  --set as Partner
  elseif sel == 3 then
    GROUND_DEBUG:SetWareHouse_PARTENER(id)
    CHARA:ReloadHeroPartner()
    
  --add as a teammate (but only if there's already an actor with that PkID)
  --NOTES:
  --    Pokemon ID: species number, the PSMD dex number. Includes megas and alt forms
  --      Actor ID: index of Pokemon in fixed list of Pokemon actors.  Appears to be list stored in RAM starting at 0x0894C540
  --  Warehouse ID: index of Pokemon in "Warehouse". Not the same as Actor ID (different order at least)
  elseif sel == 4 then
    --search for actor with selected PkID
    local found = false
    for aid = 3, 923 do
      if GROUND:GetActorIndexToPokemonIndex(aid) == id then
      
        --if matching actor found, check if Pokemon already in warehouse (duplicates get messed up)
        for wid in GROUND:EnumeratePokemonWarehouseId() do
          if GROUND:GetPokemonWarehousePokemonIndex(wid) == id then
            found = true
            break
          end
        end
        
        if found then
          WINDOW:SysMsg("ERROR:쐃"..FUNC_COMMON:GetPokemonName(id).."쐃is쐃already쐃a쐃teammate.")
          WINDOW:CloseMessage()
        else
          GROUND:AddPokemonWarehouse(aid, 30)  --can only add to warehouse by actor ID in PSMD
        end
        
        found = true
        break
      end
    end
    if not found then
      --warn if not found
      WINDOW:SysMsg("ERROR:쐃Cannot쐃add쐃"..FUNC_COMMON:GetPokemonName(id).."쐃as쐃teammate.")
      WINDOW:CloseMessage()
    end
  end
  MENU:SetFocus(self)
end

function menu:currentItemChange()
  faceMenu:Close()
  faceMenu:SetPokemonIndex(self:GetCursorItemIndex())
  faceMenu:Open()
end

function menu:cancelAction()
  self:Close()
end

function menu:inputXSelectAction()
  MENU:ClearFocus(self)
  local id = getCount("[CN]Enter ID:")
  if id > 0 then
    if id > 980 then id = 980 end
    self:SetCursorItemIndex(id)
  end
  MENU:SetFocus(self)
end

menu:Open()
faceMenu:Open()
MENU:SetFocus(menu)
MENU:WaitClose(menu)
faceMenu:Close()

--close menu title/button hints
if CommonSys.basicMenuStack ~= nil then
  CommonSys:CloseBasicMenu()
end