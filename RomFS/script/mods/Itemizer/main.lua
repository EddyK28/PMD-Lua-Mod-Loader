--====PMD 3/4 Item Generator====--
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

--open menu title/button hints
CommonSys:OpenBasicMenu("Itemizer","[M:B05]Select  [M:B06]Close  [M:B03]Menu", nil)

--create a page menu for item selection
local menu = MENU:CreatePageMenu()
menu:SetLayoutRectAndLines(32, 38, 256, 9)
menu:ShowPageNum(true)

local bDestChecst

--get maximum ID by game
local maxId
if bIsGates then 
  maxId = 738
else
  maxId = 893
end

for i = 1, maxId do
  menu:AddItem(""..i..": [item:"..i.."]", i, nil)
end

function menu:decideAction()
  --warn if bag full
  if FUNC_COMMON:GetBagItemCount() >= FUNC_COMMON:GetBagItemMaxCount() then
    WINDOW:SysMsg("Bag쐃is쐃full.쐃쐃Cannot쐃add쐃item.")
    WINDOW:CloseMessage()
    return
  end
  
  local id = self:GetCursorItemIndex()+1
  
  --create item in bag to get full name (could use "[item:"..id.."]", but it leaves in some junk)
  GROUND_DEBUG:BagItemAdd(id, 1)
  local item = FUNC_COMMON:GetBagItem(FUNC_COMMON:GetBagItemCount()-1)
  local name = item:GetItemText_forShopTalk():gsub(" ","쐃")
  
  --show count menu
  local count = getCount("[CN][VS:254]How many "..name.."?")
  MENU:SetFocus(self)
  
  --add count-1 item, or remove item if cancel
  if count == 0 then
    GROUND:DiscardBagItems({item})
  elseif bDestChecst then
    GROUND_DEBUG:ItemWarehouseItemAdd(id, count)
    GROUND:DiscardBagItems({item})
  elseif count > 1 then
    GROUND_DEBUG:BagItemAdd(id, count-1)
  end
end

function menu:cancelAction()    --menu cancel function
  self:Close()                    --close menu
end

function menu:inputXSelectAction()
  MENU:ClearFocus(self)
  self:SetTextAlpha(30)
  local menuSm = MENU:CreatePageMenu()
  menuSm:SetLayoutRectAndLines(160, 100, 112, 3)
  
  menuSm:AddItem("Back", 0, { decideAction = function(self) self:Close() end })
  menuSm:AddItem("Go to ID", 1, nil)
  if bDestChecst then
    menuSm:AddItem("Destination: Chest", 2, nil)
  else
    menuSm:AddItem("Destination: Bag", 2, nil)
  end
  
  function menuSm:cancelAction()
    self:Close()
  end
  
  function menuSm:decideAction()
    local selectID = self:GetCursorItemIndex()
    if selectID == 1 then
      local id = getCount("[CN]Enter ID:")-1
      if id > maxId then id = maxId end
      menu:SetCursorItemIndex(id)
      MENU:SetFocus(self)
    elseif selectID == 2 then
      self:SetCurrentModifyItem(2)
      bDestChecst = not bDestChecst
      if bDestChecst then
        self.curItem.text = "Destination: Chest"
      else
        self.curItem.text = "Destination: Bag"
      end
    end   
  end
  
  menuSm:Open()
  MENU:SetFocus(menuSm)
  MENU:WaitClose(menuSm)
  MENU:SetFocus(self)
  self:SetTextAlpha(255)
end

menu:Open()
MENU:SetFocus(menu)
MENU:WaitClose(menu)

--close menu title/button hints
if CommonSys.basicMenuStack ~= nil then
  CommonSys:CloseBasicMenu()
end