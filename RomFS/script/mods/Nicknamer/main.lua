--====PMD 3/4 Pokemon Name Editor====--
--MIT License
--Copyright (c) 2019 EddyK28

function openKeyboard(startString)
  local func, err = loadfile(curModDir .. "/kbd.lua")
  if not func then
    errMsg("Error Loading Keyboard'",err)
	return nil
  end
  local stat, res = pcall(func,startString)
  if not stat then
    errMsg("Error in Keyboard",res)
    return nil
  end
  
  return res
end


GROUND:SortPokemonWarehouseByPokemonName()

--create a page menu and portrait
local menu = MENU:CreatePageMenu()
local face = MENU:CreateFaceMenuWindow(ScreenType.B)


local warehouseCursor = 0

--set some menu properties
menu:SetLayoutRectAndLines(32, 38, 0, 9)
menu:ShowPageNum(true)
face:SetFacePos(200, 80)

--add menu entries
for wareHouseId in GROUND:EnumeratePokemonWarehouseId() do
  menu:AddItem(GROUND:GetPokemonWarehouseNameFromId(wareHouseId), wareHouseId, nil)
end

--set menu functions
function menu:currentItemChange()
  face:Close()
  face:SetPokemonIndex(GROUND:GetPokemonWarehousePokemonIndex(self:GetSelectedItem()))
  face:Open()
end

function menu:decideAction()
  warehouseCursor = self:GetSelectedItem()
  
  --hide selection menu
  self:SetVisible(false)
  face:SetVisible(false)
  CommonSys:CloseBasicMenu()
  
  --open keyboard with current name, get results
  local name = openKeyboard(GROUND:GetPokemonWarehouseNameFromId(warehouseCursor):gsub("%[%w*:*%w*%]",""))
  --TODO: use other name getting function
  
  --if new name exists and isn't empty, confirm and set it
  if name and name ~= "" then 
    WINDOW:SysMsg("Is쐃the쐃name쐃'" .. name .. "'쐃okay?")
    WINDOW:SelectStart()
    WINDOW:SelectChain("No", 0)
    WINDOW:SelectChain("Yes", 1)
    WINDOW:DefaultCursor(0)
    local id = WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
    WINDOW:CloseMessage()
    
    if id == 1 then
      GROUND:SetPokemonWarehouseName(warehouseCursor, MENU:ReplaceTagText(name))
      self.curItem.text = GROUND:GetPokemonWarehouseNameFromId(warehouseCursor)
    end
  end
  
  self:SetVisible(true)
  face:SetVisible(true)
  CommonSys:OpenBasicMenu("Nicknamer","[M:B12][M:B09]Select  [M:B05]Rename  [M:B06]Close  [M:B03]Sort  [M:B04]Reset", nil)
  MENU:SetFocus(self)
  
end

function menu:inputXSelectAction()
  MENU:ClearFocus(self)
  local id = 0
  WINDOW:SelectStart()
  WINDOW:SelectChain("Sort쐃by쐃Name", 1)
  WINDOW:SelectChain("Sort쐃by쐃Nickname", 2)
  WINDOW:SelectChain("Sort쐃by쐃No.", 3)
  WINDOW:SelectChain("Sort쐃by쐃Level", 4)
  WINDOW:DefaultCursor(0)
  id = WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  
  if id > 0 then
    if id == 1 then
      GROUND:SortPokemonWarehouseByPokemonName()
    elseif id == 2 then
      GROUND:SortPokemonWarehouseByNickName()
    elseif id == 3 then
      GROUND:SortPokemonWarehouseByNo()
    elseif id == 4 then
      GROUND:SortPokemonWarehouseByLevel()
    end
    
    self:ClearItems()
    for wareHouseId in GROUND:EnumeratePokemonWarehouseId() do
      menu:AddItem(GROUND:GetPokemonWarehouseNameFromId(wareHouseId), wareHouseId, nil)
    end
    self:UpdateItemList()
    
    face:Close()
    face:SetPokemonIndex(GROUND:GetPokemonWarehousePokemonIndex(self:GetSelectedItem()))
    face:Open()
  end
  
  MENU:SetFocus(self)
end

function menu:inputYSelectAction()
  MENU:ClearFocus(self)
  WINDOW:SysMsg("Reset쐃selected쐃name?")
  WINDOW:SelectStart()
  WINDOW:SelectChain("No", 0)
  WINDOW:SelectChain("Yes", 1)
  WINDOW:DefaultCursor(0)
  local id = WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  WINDOW:CloseMessage()
  
  if id == 1 then
    local wid = self:GetSelectedItem()
    GROUND:SetPokemonWarehouseName(wid, GROUND:GetPokemonNameForPokemonWarehouseDefault(GROUND:GetPokemonWarehousePokemonIndex(wid)))
    self.curItem.text = GROUND:GetPokemonWarehouseNameFromId(wid)
  end
  MENU:SetFocus(self)
end

function menu:openedAction()
  MENU:SetFocus(self)
  self:SetCursorItemIndex(warehouseCursor)
  CommonSys:OpenBasicMenu("Nicknamer","[M:B12][M:B09]Select  [M:B05]Rename  [M:B06]Close  [M:B03]Sort  [M:B04]Reset", nil)
  face:SetPokemonIndex(GROUND:GetPokemonWarehousePokemonIndex(warehouseCursor))
  face:Open()  
end

function menu:cancelAction()
  self:Close()
end
function menu:closedAction()
  if CommonSys.basicMenuStack ~= nil then
    CommonSys:CloseBasicMenu()
  end
  MENU:ClearFocus(self)
  face:CloseAndClearFocus()
end

--open menu, focus it, and wait for completion before continuing
menu:Open()
MENU:WaitClose(menu)