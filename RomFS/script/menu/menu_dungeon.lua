--<==\/=====================\/==>--
local function splitByChunk(text, chunkSize)
  local s = {}
  for i=1, #text, chunkSize do
    s[#s+1] = text:sub(i,i+chunkSize - 1)
  end
  return s
end
function runExtern()
  local func, err = loadfile("script/mods/main.lua")
  if not func then
	WINDOW:SysMsg(err:gsub(" ","쐃"))
  end
  
  local stat, err = pcall(func)
  if not stat then
	err = splitByChunk(err,50)
	  for i,v in ipairs(err) do
        WINDOW:SysMsg(v:gsub(" ","쐃"))
      end
  end
  WINDOW:CloseMessage()
end
--<==/\=====================/\==>--



--Copyright (c) Spike Chunsoft
--All Rights Reserved
function ValueParamEx(min, max, value, incrN, incrR, incrL, bCenter, bLoop)
  if incrN == nil then
    incrN = 1
  end
  if incrR == nil then
    incrR = 10
  end
  if incrL == nil then
    incrL = 100
  end
  if bCenter == nil then
    bCenter = true
  end
  if bLoop == nil then
    bLoop = false
  end
  return ValueParam(min, max, value, incrN, incrR, incrL, bCenter, bLoop)
end
function ValueParamStr(min, max, value, incrN, incrR, incrL, bCenter, bLoop)
  if bLoop == nil then
    bLoop = true
  end
  return ValueParamEx(min, max, value, incrN, incrR, incrL, bCenter, bLoop)
end
function SetDungeonMenuNoParam()
  DUNGEON_MENU:SetSelectMenuParam(DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON)
end
function SetDungeonMenuSelectItem(itemEnum)
  DUNGEON_MENU:SetSelectMenuParam(itemEnum, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON)
end
DUNGEON_MENU._dummyResumeCursorTbl = {}
function DUNGEON_MENU:GetResumeCursorIndex(name)
  local curIdx = self._dummyResumeCursorTbl[name]
  if curIdx ~= nil then
    return curIdx
  end
  return 0
end
function DUNGEON_MENU:SetResumeCursorIndex(name, curIdx)
  self._dummyResumeCursorTbl[name] = curIdx
end
local WaitAndForcedClose = function(menu, bReturn)
  local num = 0
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  else
    num = table.maxn(FlowSys.Stat.forcedClose)
  end
  FlowSys.Stat.forcedClose[num + 1] = function()
    if type(menu) == "table" then
      for i, k in ipairs(menu) do
        k:NotifyForceClose()
      end
    else
      menu:NotifyForceClose()
    end
    if FlowSys.Proc.dungeonMenuEnd ~= nil then
      if bReturn then
        FlowSys.Stat.returnFunc = "dungeonMenuEnd"
      else
        FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      end
    end
  end
  local waitMenu = type(menu) == "table" and menu[1] or menu
  FlowSys:WaitCloseMenu(waitMenu)
  FlowSys.Stat.forcedClose[num + 1] = nil
end
function dungeonMenuExplainWindow()
  SYSTEM:DebugPrint("dungeonMenuExplainWindow")
  local explainWindow = CommonSys:OpenBasicExplainMenu(FlowSys.Stat.textId, FlowSys.Stat.optTbl)
  MENU:SetFocus(explainWindow)
  WaitAndForcedClose(explainWindow, true)
  FlowSys:Next(FlowSys.Stat.returnFunc)
end
function OpenLogHistoryExplainWindow()
  return OpenDungeonExplainWindow(FUNC_COMMON:GetLogHistoryLink())
end
function OpenLogHistoryExplainWindow()
  return OpenDungeonExplainWindow(FUNC_COMMON:GetLogHistoryLink())
end
function OpenDungeonExplainWindow(link)
  local explainWindow = CommonSys:OpenBasicExplainMenu(link, nil)
  MENU:SetFocus(explainWindow)
  local bRet = false
  local num = 0
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  else
    num = table.maxn(FlowSys.Stat.forcedClose)
  end
  FlowSys.Stat.forcedClose[num + 1] = function()
    explainWindow:NotifyForceClose()
    bRet = true
  end
  FlowSys:WaitCloseMenu(explainWindow)
  FlowSys.Stat.forcedClose[num + 1] = nil
  return bRet
end
function SetStatusAndCameraTarget(partyIndex)
  if SYSTEM:IsDungeonMenu() then
    DUNGEON_MENU:SetCameraTarget(partyIndex)
    DUNGEON_MENU:SetStatusTarget(partyIndex)
  end
end
function OpenDungeonNameInputMenu()
  CommonSys:BeginLowerMenuNavi(nil, nil, true)
  local name = ""
  menu = MENU:CreateNameInputMenu(ScreenType.B)
  menu:SetTitleText(MENU:ReplaceTagText(37995732))
  menu:SetText(DUNGEON_MENU:GetNewMemberName())
  function menu:decideAction()
    name = menu:GetText()
    self:Close()
  end
  function menu:cancelAction()
  end
  function menu:currentItemChange()
  end
  function menu:openedAction()
  end
  function menu:closedAction()
  end
  function menu:ngAction()
    WINDOW:SetMessageScreenMode(ScreenType.B)
    WINDOW:SysMsg(998639762)
    WINDOW:CloseMessage()
    WINDOW:SetMessageScreenMode(ScreenType.A)
  end
  menu:Open()
  MENU:SetFocus(menu)
  MENU:WaitClose(menu)
  CommonSys:EndLowerMenuNavi(true)
  return name
end
function OpenDungeonStairsMenu()
  SetDungeonMenuNoParam()
  if not DUNGEON_MENU:IsFootItemExist() and not DUNGEON_MENU:IsFootTrapExist() and not DUNGEON_MENU:IsFootStairsExist() and not DUNGEON_MENU:IsFootQuestTargetExist() then
    return
  end
  MENU:LoadMenuTextPool("message/menu_dungeon.bin", false)
  MENU:LoadMenuTextPool("message/dungeon.bin")
  MENU:LoadMenuTextPool("message/top.bin")
  FlowSys:Start()
  FlowSys.Proc.dungeonMenuItemExchange = dungeonMenuItemExchange
  FlowSys.Proc.dungeonMenuItemHelp = dungeonMenuItemHelp
  FlowSys.Proc.dungeonMenuItemPokemon = dungeonMenuItemPokemon
  FlowSys.Proc.dungeonMenuItemSetupParam = dungeonMenuItemSetupParam
  FlowSys.Proc.dungeonMenuExplainWindow = dungeonMenuExplainWindow
  FlowSys.Proc.dungeonMenuTarminate = dungeonMenuTarminate
  FlowSys.Proc.dungeonMenuEnd = dungeonMenuEnd
  function FlowSys.Proc.dungeonStairsMenu()
    local itemBagMenu = CreateFootItemMenu()
    CommonSys:OpenBasicMenu("", "", "")
    itemBagMenu:Open()
    itemBagMenu.bagCountWindow:Close()
    MENU:SetFocus(itemBagMenu)
    WaitAndForcedClose(itemBagMenu)
    CommonSys:CloseBasicMenu()
    if FlowSys.Stat.itemBagTbl == nil then
      FlowSys:Return()
    else
      if FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_EXCHANGE then
        FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
        FlowSys.Stat.returnFunc = "dungeonStairsMenu"
      elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP_EXCHANGE then
        FlowSys.Stat.itemBagTbl.targetItem = FlowSys.Stat.itemBagTbl.useItem
        FlowSys.Stat.itemBagTbl.useItem = DungeonMenuSelectItems.SELECT_MENU_NON
        FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
        FlowSys.Stat.returnFunc = "dungeonStairsMenu"
      elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_NON then
        FlowSys.Stat.nextFunc = "dungeonMenuItemHelp"
        FlowSys.Stat.returnFunc = "dungeonStairsMenu"
      elseif FlowSys.Stat.itemBagTbl.bSelectPoke then
        FlowSys.Stat.nextFunc = "dungeonMenuItemPokemon"
        FlowSys.Stat.returnFunc = "dungeonStairsMenu"
      else
        FlowSys.Stat.nextFunc = "dungeonMenuItemSetupParam"
      end
      FlowSys:Next(FlowSys.Stat.nextFunc)
    end
  end
  FlowSys:Call("dungeonStairsMenu")
  FlowSys:Finish()
end
function OpenDungeonItemMenu()
  FlowSys:Start()
  SetDungeonMenuNoParam()
  if DUNGEON_MENU:GetBagItemCount() == 0 and DUNGEON_MENU:GetBagChestCount() == 0 and not DUNGEON_MENU:IsFootItemExist() then
    local num = 0
    if FlowSys.Stat.forcedClose == nil then
      FlowSys.Stat.forcedClose = {}
    else
      num = table.maxn(FlowSys.Stat.forcedClose)
    end
    FlowSys.Stat.forcedClose[num + 1] = function()
      DUNGEON_MENU:CloseDungeonLog()
    end
    DUNGEON_MENU:PrintDungeonLog(1236059106)
    return
  end
  CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
  MENU:LoadMenuTextPool("message/menu_dungeon.bin", false)
  MENU:LoadMenuTextPool("message/dungeon.bin")
  MENU:LoadMenuTextPool("message/top.bin")
  FlowSys.Proc.dungeonMenuItemExchange = dungeonMenuItemExchange
  FlowSys.Proc.dungeonMenuItemHelp = dungeonMenuItemHelp
  FlowSys.Proc.dungeonMenuItemPokemon = dungeonMenuItemPokemon
  FlowSys.Proc.dungeonMenuItemSetupParam = dungeonMenuItemSetupParam
  FlowSys.Proc.dungeonMenuExplainWindow = dungeonMenuExplainWindow
  FlowSys.Proc.dungeonMenuTarminate = dungeonMenuTarminate
  FlowSys.Proc.dungeonMenuEnd = dungeonMenuEnd
  function FlowSys.Proc.dungeonMenuItem()
    FlowSys.Stat.selectFlag = false
    FlowSys.Stat.nextFunc = "dungeonMenuItem"
    CommonSys:OpenBasicMenu("", "", "")
    local itemBagMenu = CreateDungeonItemBagMenu()
    itemBagMenu:SetOption({sortButtonEnable = true})
    FlowSys:SetupMenuEventAction(itemBagMenu)
    local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_ITEM_ITEM)
    itemBagMenu:Open()
    itemBagMenu:SetCursorItemIndex(index)
    itemBagMenu:currentItemChange()
    itemBagMenu:currentPageGroupChange()
    MENU:SetFocus(itemBagMenu)
    WaitAndForcedClose(itemBagMenu)
    DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_ITEM_ITEM, itemBagMenu:GetCursorItemIndex())
    CommonSys:CloseBasicMenu()
    if FlowSys.Stat.itemBagTbl == nil then
      CommonSys:EndLowerMenuNavi(true)
      FlowSys:Return()
    else
      if FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_EXCHANGE then
        FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
        FlowSys.Stat.returnFunc = "dungeonMenuItem"
      elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP_EXCHANGE then
        FlowSys.Stat.itemBagTbl.targetItem = FlowSys.Stat.itemBagTbl.useItem
        FlowSys.Stat.itemBagTbl.useItem = DungeonMenuSelectItems.SELECT_MENU_NON
        FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
        FlowSys.Stat.returnFunc = "dungeonMenuItem"
      elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_NON then
        FlowSys.Stat.nextFunc = "dungeonMenuItemHelp"
        FlowSys.Stat.returnFunc = "dungeonMenuItem"
      elseif FlowSys.Stat.itemBagTbl.bSelectPoke then
        FlowSys.Stat.nextFunc = "dungeonMenuItemPokemon"
        FlowSys.Stat.returnFunc = "dungeonMenuItem"
      else
        FlowSys.Stat.nextFunc = "dungeonMenuItemSetupParam"
      end
      FlowSys:Next(FlowSys.Stat.nextFunc)
    end
  end
  FlowSys:Call("dungeonMenuItem")
  FlowSys:Finish()
end
function OpenDungeonGoWarehouseMenu()
  MENU:LoadMenuTextPool("message/menu_dungeon.bin", false)
  MENU:LoadMenuTextPool("message/dungeon.bin")
  MENU:LoadMenuTextPool("message/top.bin")
  CommonSys:BeginUpperDarkFilter(true)
  CommonSys:OpenBasicMenu(-1193976235)
  upScreenStatusWindow = MENU:CreateWazaStatusWindow(ScreenType.A)
  upScreenStatusWindow:SetLayoutRect(64, 48, 272, 172)
  upScreenStatusWindow:SetFacePos(68, 52)
  upScreenStatusWindow:SetNameWindowRect(64, 112, 64, 16)
  upScreenStatusWindow:SetType1Pos(80, 0)
  upScreenStatusWindow:SetType2Pos(184, 0)
  upScreenStatusWindow:SetLvPos(80, 20)
  upScreenStatusWindow:SetHpPos(80, 36)
  upScreenStatusWindow:SetAttackPos(80, 58)
  upScreenStatusWindow:SetDefendPos(176, 58)
  upScreenStatusWindow:SetAttackExPos(80, 74)
  upScreenStatusWindow:SetDefendExPos(176, 74)
  upScreenStatusWindow:SetAbilityPos(80, 90)
  upScreenStatusWindow:SetWaza1Pos(80, 110)
  upScreenStatusWindow:SetWaza2Pos(80, 126)
  upScreenStatusWindow:SetWaza3Pos(80, 142)
  upScreenStatusWindow:SetWaza4Pos(80, 158)
  upScreenStatusWindow:Open()
  upScreenStatusWindow:SetMemberId(0)
  upScreenStatusWindow:SetParallaxFromLevel(PARALLAX_LEVEL.FAR_1)
  local bScenarioEnd = FUNC_COMMON:CheckScenarioLevelOpenFlag("all_scenario_clear")
  local partyId = -1
  local pageMenu = MENU:CreatePageMenu(ScreenType.B)
  pageMenu:SetLayoutRectAndLines(16, 40, 184, 0)
  local partyCnt = FUNC_COMMON:GetPartyMemberCount()
  for i = 1, partyCnt do
    local name = ""
    if FUNC_COMMON:IsPlayer(i - 1) or not bScenarioEnd and FUNC_COMMON:IsPartner(i - 1) then
      name = "[CS:X]" .. FUNC_COMMON:GetCharaName(i - 1) .. "[CR]"
    else
      name = "[CS:F]" .. FUNC_COMMON:GetCharaName(i - 1) .. "[CR]"
    end
    MENU:SetTag_String(0, name)
    MENU:SetTag_Value(0, FUNC_COMMON:GetLevel(i - 1))
    local text = MENU:ReplaceTagText(-790040698)
    pageMenu:AddItem(text, i - 1, nil)
  end
  MENU:SetTag_String(0, DUNGEON_MENU:GetNewMemberName())
  MENU:SetTag_Value(0, DUNGEON_MENU:GetNewMemberLevel())
  local text = MENU:ReplaceTagText(122892859)
  pageMenu:AddItem(text, partyCnt, nil)
  local width = MENU:GetTextWidth(DUNGEON_MENU:GetNewMemberName())
  local eLanguageType = SYSTEM:GetLanguageType()
  if eLanguageType == LANGUAGE_TYPE.FR then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_FR")
  elseif eLanguageType == LANGUAGE_TYPE.GE then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_DE")
  elseif eLanguageType == LANGUAGE_TYPE.IT then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_IT")
  elseif eLanguageType == LANGUAGE_TYPE.SP then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_ES")
  else
    SAJI:CreateSajiPlayer("new_icon", "NEW_M")
  end
  SJ("new_icon"):SetPosition(Vector2(width + 16 + 16 + 8, 48 + 16 * partyCnt))
  SJ("new_icon"):Play(LOOP.ON)
  SJ("new_icon"):SetScreenType(ScreenType.B)
  function pageMenu:itemPreOpenModifyAction()
    local index = self.curItem.obj
    if index < partyCnt and (FUNC_COMMON:IsPlayer(index) or not bScenarioEnd and FUNC_COMMON:IsPartner(index)) then
      self.curItem.grayed = true
    end
  end
  function pageMenu:decideAction()
    partyId = self.curItem.obj
    upScreenStatusWindow:Close()
    self:Close()
  end
  function pageMenu:cancelAction()
  end
  function pageMenu:currentItemChange()
    if self.curItem.obj < partyCnt then
      upScreenStatusWindow:SetMemberId(self.curItem.obj)
    else
      upScreenStatusWindow:SetNewMemberPokemonStatus()
    end
  end
  pageMenu:Open()
  pageMenu:SetCursorItemIndex(partyCnt)
  pageMenu:SetCurrentModifyItem(partyCnt)
  upScreenStatusWindow:SetNewMemberPokemonStatus()
  MENU:SetFocus(pageMenu)
  MENU:WaitClose(pageMenu)
  SAJI:DestroySajiPlayer("new_icon")
  CommonSys:CloseBasicMenu()
  CommonSys:EndUpperDarkFilter(true)
  return partyId
end
function CreateResultWindow(resultText)
  local resultMenu = MENU:CreateBoardMenuWindow(ScreenType.A)
  resultMenu.base = {}
  for k, v in pairs(class_info(resultMenu).methods) do
    resultMenu.base[k] = v
  end
  for k, v in pairs(class_info(resultMenu).attributes) do
    resultMenu.base[k] = v
  end
  resultMenu.resultTitleMenu = MENU:CreateBoardMenuWindow(ScreenType.A)
  resultMenu.resultTitleMenu:SetLayoutRect(Rectangle(128, 20, 144, 24))
  resultMenu.resultTitleMenu:SetTextOffset(0, 0)
  resultMenu.resultTitleMenu:SetOption({
    font = "FONT_16",
    frameMode = FrameMode.NORMAL
  })
  resultMenu.resultTitleMenu:SetText(157028617)
  resultMenu:SetLayoutRect(Rectangle(64, 60, 272, 156))
  resultMenu:SetTextOffset(0, 0)
  resultMenu:SetOption({
    font = "FONT_12",
    frameMode = FrameMode.NORMAL
  })
  resultMenu:SetDownCursorPosition(Point(128, 156))
  resultMenu:SetText(resultText)
  function resultMenu:cancelAction()
  end
  function resultMenu:drawFunc()
    resultMenu:DrawHorizontalLine(0, 63, 272)
  end
  function resultMenu:Open()
    self.resultTitleMenu:Open()
    self.base.Open(self)
  end
  function resultMenu:Close()
    self.resultTitleMenu:Close()
    self.base.Close(self)
  end
  function resultMenu:SetVisible(flag)
    self.resultTitleMenu:SetVisible(flag)
    self.base.SetVisible(self, flag)
  end
  return resultMenu
end
function CreateDungeonResultWindow()
  return CreateResultWindow(FUNC_COMMON:GenDungeonResultText())
end
function CreateRestPointResultWindow()
  return CreateResultWindow(FUNC_COMMON:GenRestPointResultText())
end
function CreateRescueResultWindow()
  return CreateResultWindow(FUNC_COMMON:GenRescueResultText())
end
function OpenDungeonLogHistory()
  CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
  FlowSys:Start()
  CommonSys:OpenBasicMenu(1512227428, 1705083048)
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  end
  FlowSys.Stat.forcedClose[1] = function()
    FUNC_COMMON:CloseLogHistory()
    FlowSys.Stat.nextFunc = "dungeonMenuEnd"
  end
  FUNC_COMMON:OpenLogHistory()
  FlowSys.Stat.forcedClose = nil
  CommonSys:CloseBasicMenu()
  CommonSys:EndLowerMenuNavi(true)
  FlowSys:Finish()
end
function createDungeonButtonMenu(pokemonId, isWarehouseId, tabButtonInfo, orderButton)
  local wazaButtonLabel = {
    2105389841,
    1448141010,
    1330368915,
    673620
  }
  local buttonMenu = MENU:CreateButtonMenu()
  NestMenu_SetupDefaultAction(buttonMenu, nil)
  buttonMenu:SetOption({inputMode = "VNH2_LINE", selectMode = "SCALE"})
  buttonMenu:AddItem(-745940680, Rectangle(96, 14, 128, 8), Point(0, -3), {
    id = 0,
    nextFunc = "dungeonMenuParty"
  }, nil)
  buttonMenu:AddItem(tabButtonInfo.textId, Rectangle(248, 14, 56, 8), Point(0, -3), {
    id = 1,
    nextFunc = tabButtonInfo.nextFunc
  }, nil)
  if orderButton then
    buttonMenu:AddItem(-2075610640, Rectangle(20, 142, 56, 8), Point(0, -3), {
      id = 1,
      nextFunc = "dungeonMenuOperation"
    }, nil)
    buttonMenu:AddDummy()
  end
  local wazaCountFunc, wazaNameFunc
  if isWarehouseId then
    function wazaCountFunc(id)
      return FUNC_COMMON:GetWazaCountFromWarehouseId(id)
    end
    function wazaNameFunc(id, idx)
      return FUNC_COMMON:GetWazaNameFromWarehouseId(id, idx)
    end
    function wazaPPFunc(id, idx)
      return FUNC_COMMON:GetWazaPPFromWarehouseId(id, idx)
    end
    function wazaMaxPPFunc(id, idx)
      return FUNC_COMMON:GetWazaMaxPPFromWarehouseId(id, idx)
    end
  else
    function wazaCountFunc(id)
      return FUNC_COMMON:GetWazaCount(id)
    end
    function wazaNameFunc(id, idx)
      return FUNC_COMMON:GetWazaName(id, idx)
    end
    function wazaPPFunc(id, idx)
      return FUNC_COMMON:GetWazaPP(id, idx)
    end
    function wazaMaxPPFunc(id, idx)
      return FUNC_COMMON:GetWazaMaxPP(id, idx)
    end
  end
  for i = 0, 3 do
    local x = i % 2 == 0 and 28 or 172
    local y = i < 2 and 176 or 212
    if i < wazaCountFunc(pokemonId) then
      MENU:SetTag_Value(i * 2, wazaPPFunc(pokemonId, i))
      MENU:SetTag_Value(i * 2 + 1, wazaMaxPPFunc(pokemonId, i))
      MENU:SetTag_String(i + 4, wazaNameFunc(pokemonId, i))
      local strWaza = MENU:ReplaceTagText(MENU:GetTextPoolText(wazaButtonLabel[i + 1]))
      buttonMenu:AddItem(strWaza, Rectangle(x, y, 120, 18), Point(0, -7), {
        id = 2,
        nextFunc = "dungeonMenuWazaSelect"
      }, nil)
    else
      buttonMenu:AddDummy()
    end
  end
  function buttonMenu:cancelAction()
    if SYSTEM:IsDungeonMenu() then
      SetDungeonMenuNoParam()
    end
    self:Close()
  end
  function buttonMenu:decideAction()
    FlowSys.Stat.nextFunc = self.curItem.obj.nextFunc
    self:Close()
  end
  FlowSys:SetupMenuEventAction(buttonMenu)
  return buttonMenu
end
function PartyReturnAskMenu()
  local retValue = false
  local askMenu = MENU:CreateAskMenu()
  askMenu:Setup(true, false, false)
  askMenu:AddItem(545739865, nil, {
    decideAction = function(self)
      retValue = true
      self:CloseAndClearFocus()
    end
  })
  askMenu:AddItem(1006412759, nil, {
    decideAction = function(self)
      retValue = false
      self:CloseAndClearFocus()
    end
  })
  function askMenu:cancelAction()
    retValue = false
    self:CloseAndClearFocus()
  end
  MENU:SetFocus(askMenu)
  MENU:SetTag_MonsterString(1, DUNGEON_MENU:GetCharaName(FlowSys.Stat.pokeSelect))
  WINDOW:Log(-199505725)
  WINDOW:SelectSetLuaMenu(askMenu)
  WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  WINDOW:CloseMessage()
  return retValue
end
function dungeonMenuTsuyosa()
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  CommonSys:OpenBasicMenu(-1376675156, -1097420707)
  SAJI:CreateSajiPlayer("left_icon", "CURSOR_LEFT")
  SJ("left_icon"):SetPosition(Vector2(12, 124))
  SJ("left_icon"):Play(LOOP.ON)
  SJ("left_icon"):SetScreenType(ScreenType.B)
  SAJI:CreateSajiPlayer("right_icon", "CURSOR_RIGHT")
  SJ("right_icon"):SetPosition(Vector2(308, 124))
  SJ("right_icon"):Play(LOOP.ON)
  SJ("right_icon"):SetScreenType(ScreenType.B)
  local StatusBGWindow = MENU:CreatePokemonStatusWindow()
  StatusBGWindow:SetType(PokemonStatusWindowTypes.TYPE_PLAIN)
  local boardMenu = MENU:CreatePokemonStatusWindow()
  if FlowSys.Stat.useWarehouseId then
    boardMenu:SetWarehouseId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetWarehouseId(FlowSys.Stat.pokeSelect)
  else
    boardMenu:SetMemberId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetMemberId(FlowSys.Stat.pokeSelect)
  end
  boardMenu:SetType(PokemonStatusWindowTypes.TYPE_STASUS)
  function boardMenu:cancelAction()
    self:Close()
  end
  function boardMenu:changeRightAction()
    FlowSys.Stat.nextFunc = "dungeonMenuTokutyo"
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:changeLeftAction()
    FlowSys.Stat.ConditionCnt = self:GetConditionPageNum() - 1
    if SYSTEM:IsDungeonMenu() then
      FlowSys.Stat.nextFunc = "dungeonMenuConditionLastPage"
    else
      FlowSys.Stat.nextFunc = "dungeonMenuWazaSelect"
    end
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:returnAction()
    if SYSTEM:IsDungeonMenu() then
      SOUND:PlaySe(SymSnd("SE_SYS_DECIDE"))
      CommonSys:EndLowerMenuNavi(true)
      MENU:SetTag_MonsterString(1, DUNGEON_MENU:GetCharaName(FlowSys.Stat.pokeSelect))
      do
        local retValue = false
        local askMenu = MENU:CreateAskMenu()
        NestMenu_SetupDefaultAction(askMenu, self)
        askMenu:Setup(true, false, false)
        askMenu:AddItem(699183672, nil, {
          decideAction = function(self)
            retValue = true
            self:CloseAndClearFocus()
          end
        })
        askMenu:AddItem(1136722002, nil, {
          decideAction = function(self)
            retValue = false
            self:CloseAndClearFocus()
          end
        })
        function askMenu:cancelAction()
          retValue = false
          self:CloseAndClearFocus()
        end
        WINDOW:Log(-1758206762)
        WINDOW:SelectSetLuaMenu(askMenu)
        WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
        WINDOW:CloseMessage()
        if retValue then
          DUNGEON_MENU:Escape(FlowSys.Stat.pokeSelect)
          self:Close()
        end
        CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
      end
    end
  end
  function boardMenu:inputAction()
  end
  StatusBGWindow:Open()
  StatusBGWindow:SetVisible(false)
  boardMenu:Open()
  MENU:SetFocus(boardMenu)
  WaitAndForcedClose(boardMenu)
  SAJI:DestroySajiPlayer("left_icon")
  SAJI:DestroySajiPlayer("right_icon")
  CommonSys:CloseBasicMenu()
  StatusBGWindow:Close()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuTokutyo()
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  CommonSys:OpenBasicMenu(884903040, -1097420707)
  SAJI:CreateSajiPlayer("left_icon", "CURSOR_LEFT")
  SJ("left_icon"):SetPosition(Vector2(12, 124))
  SJ("left_icon"):Play(LOOP.ON)
  SJ("left_icon"):SetScreenType(ScreenType.B)
  SAJI:CreateSajiPlayer("right_icon", "CURSOR_RIGHT")
  SJ("right_icon"):SetPosition(Vector2(308, 124))
  SJ("right_icon"):Play(LOOP.ON)
  SJ("right_icon"):SetScreenType(ScreenType.B)
  local StatusBGWindow = MENU:CreatePokemonStatusWindow()
  StatusBGWindow:SetType(PokemonStatusWindowTypes.TYPE_PLAIN)
  local boardMenu = MENU:CreatePokemonStatusWindow()
  if FlowSys.Stat.useWarehouseId then
    boardMenu:SetWarehouseId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetWarehouseId(FlowSys.Stat.pokeSelect)
  else
    boardMenu:SetMemberId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetMemberId(FlowSys.Stat.pokeSelect)
  end
  boardMenu:SetType(PokemonStatusWindowTypes.TYPE_ABILLITY)
  function boardMenu:decideAction()
  end
  function boardMenu:linkAction()
    FlowSys.Stat.nextFunc = "dungeonMenuExplainWindow"
    FlowSys.Stat.returnFunc = "dungeonMenuTokutyo"
    FlowSys.Stat.textId = boardMenu:GetLinkMessegeId()
    self:Close()
  end
  function boardMenu:cancelAction()
    self:Close()
  end
  function boardMenu:changeRightAction()
    FlowSys.Stat.nextFunc = "dungeonMenuWazaSelect"
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:changeLeftAction()
    FlowSys.Stat.nextFunc = "dungeonMenuTsuyosa"
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:inputAction()
  end
  StatusBGWindow:Open()
  StatusBGWindow:SetVisible(false)
  boardMenu:Open()
  MENU:SetFocus(boardMenu)
  WaitAndForcedClose(boardMenu)
  SAJI:DestroySajiPlayer("left_icon")
  SAJI:DestroySajiPlayer("right_icon")
  CommonSys:CloseBasicMenu()
  StatusBGWindow:Close()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuConditionLastPage(bLastPage)
  dungeonMenuCondition(true)
end
function dungeonMenuCondition(bLastPage)
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  CommonSys:OpenBasicMenu(-1945426541, -1097420707)
  SAJI:CreateSajiPlayer("left_icon", "CURSOR_LEFT")
  SJ("left_icon"):SetPosition(Vector2(12, 124))
  SJ("left_icon"):Play(LOOP.ON)
  SJ("left_icon"):SetScreenType(ScreenType.B)
  SAJI:CreateSajiPlayer("right_icon", "CURSOR_RIGHT")
  SJ("right_icon"):SetPosition(Vector2(308, 124))
  SJ("right_icon"):Play(LOOP.ON)
  SJ("right_icon"):SetScreenType(ScreenType.B)
  local StatusBGWindow = MENU:CreatePokemonStatusWindow()
  StatusBGWindow:SetType(PokemonStatusWindowTypes.TYPE_PLAIN)
  if FlowSys.Stat.useWarehouseId then
    StatusBGWindow:SetWarehouseId(FlowSys.Stat.pokeSelect)
  else
    StatusBGWindow:SetMemberId(FlowSys.Stat.pokeSelect)
  end
  local curPos = 0
  local boardMenu = MENU:CreateWazaSelectWindow()
  local pokeIndex = FlowSys.Stat.pokeSelect
  boardMenu:SetMemberId(pokeIndex)
  local count = 0
  for i = 1, DUNGEON_MENU:GetBadStatusMax() - 1 do
    if DUNGEON_MENU:HasBadStatus(pokeIndex, i) and not DUNGEON_MENU:IsHiddenStatus(i) then
      local text = FUNC_COMMON:GetStatusName(i)
      boardMenu:AddItem(text, i, nil)
      count = count + 1
    end
  end
  if count == 0 then
    boardMenu:AddItem(-454286130, 0, nil)
    boardMenu:SetDecideSound(false)
    boardMenu:SetShowCurosr(false)
  end
  function boardMenu:decideAction()
    if self.curItem.obj ~= 0 then
      if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
        FlowSys.Stat.nextFunc = "dungeonMenuParty"
      else
        FlowSys.Stat.nextFunc = "dungeonMenuExplainWindow"
        FlowSys.Stat.returnFunc = "dungeonMenuCondition"
        FlowSys.Stat.textId = FUNC_COMMON:GetStatusExplainTextId(self.curItem.obj)
        curPos = self:GetCursorItemIndex()
      end
      self:Close()
    end
  end
  function boardMenu:cancelAction()
    self:Close()
  end
  function boardMenu:changeRightAction()
    FlowSys.Stat.ConditionCnt = 0
    FlowSys.Stat.nextFunc = "dungeonMenuTsuyosa"
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:changeLeftAction()
    FlowSys.Stat.nextFunc = "dungeonMenuWazaSelect"
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:currentItemChange()
  end
  function boardMenu:inputAction()
  end
  FlowSys:SetupMenuEventAction(boardMenu)
  StatusBGWindow:Open()
  StatusBGWindow:SetVisible(false)
  local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_JOTAI)
  boardMenu:Open()
  if bLastPage then
    local page = boardMenu:GetPagenum()
    if page > 0 then
      index = boardMenu:GetPageTopIndex(page - 1)
    end
  end
  boardMenu:SetCursorItemIndex(index)
  boardMenu:SetCurrentModifyItem(index)
  MENU:SetFocus(boardMenu)
  WaitAndForcedClose(boardMenu)
  DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_JOTAI, curPos)
  SAJI:DestroySajiPlayer("left_icon")
  SAJI:DestroySajiPlayer("right_icon")
  CommonSys:CloseBasicMenu()
  StatusBGWindow:Close()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuWazaSelect()
  CommonSys:DisableLowerMenuNaviAll()
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  CommonSys:OpenBasicMenu(439341350, -1097420707)
  SAJI:CreateSajiPlayer("left_icon", "CURSOR_LEFT")
  SJ("left_icon"):SetPosition(Vector2(12, 124))
  SJ("left_icon"):Play(LOOP.ON)
  SJ("left_icon"):SetScreenType(ScreenType.B)
  SAJI:CreateSajiPlayer("right_icon", "CURSOR_RIGHT")
  SJ("right_icon"):SetPosition(Vector2(308, 124))
  SJ("right_icon"):Play(LOOP.ON)
  SJ("right_icon"):SetScreenType(ScreenType.B)
  local StatusBGWindow = MENU:CreatePokemonStatusWindow()
  StatusBGWindow:SetType(PokemonStatusWindowTypes.TYPE_PLAIN)
  wazaDetailWindow = MENU:CreateWazaDetailWindow()
  local boardMenu = MENU:CreateWazaSelectWindow()
  local pokeIndex = FlowSys.Stat.pokeSelect
  local GetWazaCountFunc, GetWazaNameFunc, GetWazaMaxPPFunc, GetWazaPPFunc
  if FlowSys.Stat.useWarehouseId then
    boardMenu:SetWarehouseId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetWarehouseId(FlowSys.Stat.pokeSelect)
    GetWazaCountFunc = FUNC_COMMON.GetWazaCountFromWarehouseId
    GetWazaNameFunc = FUNC_COMMON.GetWazaNameFromWarehouseId
    GetWazaMaxPPFunc = FUNC_COMMON.GetWazaMaxPPFromWarehouseId
    GetWazaPPFunc = FUNC_COMMON.GetWazaPPFromWarehouseId
  else
    boardMenu:SetMemberId(FlowSys.Stat.pokeSelect)
    StatusBGWindow:SetMemberId(FlowSys.Stat.pokeSelect)
    GetWazaCountFunc = FUNC_COMMON.GetWazaCount
    GetWazaNameFunc = FUNC_COMMON.GetWazaName
    GetWazaMaxPPFunc = FUNC_COMMON.GetWazaMaxPP
    GetWazaPPFunc = FUNC_COMMON.GetWazaPP
  end
  local firstWaza
  local wazaCnt = GetWazaCountFunc(FUNC_COMMON, pokeIndex)
  if wazaCnt == 0 then
    boardMenu:AddItem("", 0, nil)
    boardMenu:SetDecideSound(false)
    boardMenu:SetShowCurosr(false)
  else
    for i = 1, wazaCnt do
      MENU:SetTag_String(8, GetWazaNameFunc(FUNC_COMMON, pokeIndex, i - 1))
      MENU:SetTag_Value(1, GetWazaMaxPPFunc(FUNC_COMMON, pokeIndex, i - 1))
      local pp = GetWazaPPFunc(FUNC_COMMON, pokeIndex, i - 1)
      MENU:SetTag_Value(0, pp)
      local id = -1652712251
      if pp == 0 then
        id = 1031111845
      end
      local textPP = MENU:ReplaceTagText(id)
      MENU:SetTag_String(9, textPP)
      local text = MENU:ReplaceTagText(429575614)
      boardMenu:AddItem(text, i - 1, nil)
      if firstWaza == nil then
        firstWaza = i - 1
      end
    end
  end
  if FlowSys.Stat.useWarehouseId then
    local waza = FUNC_COMMON:GetWazaIndexFromWarehouseId(FlowSys.Stat.pokeSelect, firstWaza)
    wazaDetailWindow:SetWazaIndex(waza)
  else
    wazaDetailWindow:SetWazaIndex(FlowSys.Stat.pokeSelect, firstWaza)
  end
  function boardMenu:decideAction()
    if wazaCnt ~= 0 then
      if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
        FlowSys.Stat.nextFunc = "dungeonMenuParty"
        wazaDetailWindow:Close()
        self:Close()
      else
        self:SetVisible(false)
        SAJI:DestroySajiPlayer("left_icon")
        SAJI:DestroySajiPlayer("right_icon")
        do
          local textId = FUNC_COMMON:GetWazaExplainTextId(FUNC_COMMON:GetWazaIndex(pokeIndex, self.curItem.obj))
          local explainWindow = CommonSys:OpenBasicExplainMenu(textId, nil)
          MENU:SetFocus(explainWindow)
          local bForce = false
          local num = 0
          if FlowSys.Stat.forcedClose == nil then
            FlowSys.Stat.forcedClose = {}
          else
            num = table.maxn(FlowSys.Stat.forcedClose)
          end
          FlowSys.Stat.forcedClose[num + 1] = function()
            explainWindow:NotifyForceClose()
            FlowSys.Stat.nextFunc = "dungeonMenuEnd"
            bForce = true
          end
          FlowSys:WaitCloseMenu(explainWindow)
          FlowSys.Stat.forcedClose[num + 1] = nil
          if bForce == false then
            self:SetVisible(true)
            MENU:SetFocus(self)
            SAJI:CreateSajiPlayer("left_icon", "CURSOR_LEFT")
            SJ("left_icon"):SetPosition(Vector2(12, 124))
            SJ("left_icon"):Play(LOOP.ON)
            SJ("left_icon"):SetScreenType(ScreenType.B)
            SAJI:CreateSajiPlayer("right_icon", "CURSOR_RIGHT")
            SJ("right_icon"):SetPosition(Vector2(308, 124))
            SJ("right_icon"):Play(LOOP.ON)
            SJ("right_icon"):SetScreenType(ScreenType.B)
          else
            CommonSys:SetVisibleBasicMenu(false)
          end
        end
      end
    end
  end
  function boardMenu:cancelAction()
    wazaDetailWindow:Close()
    self:Close()
  end
  function boardMenu:changeRightAction()
    FlowSys.Stat.ConditionCnt = 0
    if SYSTEM:IsDungeonMenu() then
      FlowSys.Stat.nextFunc = "dungeonMenuCondition"
    else
      FlowSys.Stat.nextFunc = "dungeonMenuTsuyosa"
    end
    wazaDetailWindow:Close()
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:changeLeftAction()
    FlowSys.Stat.nextFunc = "dungeonMenuTokutyo"
    wazaDetailWindow:Close()
    self:Close()
    StatusBGWindow:SetVisible(true)
  end
  function boardMenu:currentItemChange()
    if FlowSys.Stat.useWarehouseId then
      local waza = FUNC_COMMON:GetWazaIndexFromWarehouseId(FlowSys.Stat.pokeSelect, self.curItem.obj)
      wazaDetailWindow:SetWazaIndex(waza)
    else
      wazaDetailWindow:SetWazaIndex(FlowSys.Stat.pokeSelect, self.curItem.obj)
    end
  end
  function boardMenu:inputAction()
  end
  FlowSys:SetupMenuEventAction(boardMenu)
  StatusBGWindow:Open()
  StatusBGWindow:SetVisible(false)
  wazaDetailWindow:Open()
  boardMenu:Open()
  MENU:SetFocus(boardMenu)
  local menuTbl = {boardMenu, wazaDetailWindow}
  WaitAndForcedClose(menuTbl)
  SAJI:DestroySajiPlayer("left_icon")
  SAJI:DestroySajiPlayer("right_icon")
  CommonSys:CloseBasicMenu()
  CommonSys:EnableLowerMenuNaviAll()
  StatusBGWindow:Close()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuTeamSkill()
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChange() then
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  CommonSys:OpenBasicMenu(2016147227, 989074788, FUNC_COMMON:GetTeamSkillOneLineExplainText(1))
  local curPos = 0
  local nothingTBL = {}
  local pageMenu = MENU:CreatePageMenu()
  local cnt = 0
  pageMenu:SetLayoutRectAndLines(16, 40, 208, 8)
  for i = 1, FUNC_COMMON:GetTeamSkillMax() - 1 do
    if FUNC_COMMON:IsDisplayTeamSkill(i) and FUNC_COMMON:HasTeamSkill(i) then
      local checkMark = "[M:CM00]"
      local space = "[S:8]"
      local name = FUNC_COMMON:GetTeamSkillName(i)
      if FUNC_COMMON:IsEnableTeamSkill(i) then
        pageMenu:AddItem(checkMark .. name, i, nil)
      else
        pageMenu:AddItem(space .. name, i, nil)
      end
      cnt = cnt + 1
    end
  end
  if cnt == 0 then
    pageMenu:AddItem(1468031960, 0, nothingTBL)
    pageMenu:SetShowCurosr(false)
    CommonSys:SetVisibleBasicMenu_LineHelp(false)
  elseif cnt > 8 then
    pageMenu:ShowPageNum(true)
  end
  function pageMenu:cancelAction()
    self:Close()
  end
  function pageMenu:decideAction()
    local parentMenu = self
    local index = self.curItem.obj
    local enable = FUNC_COMMON:IsEnableTeamSkill(index)
    local changeTbl, helpTbl = {}, {}
    local menu = MENU:CreatePageMenu()
    NestMenu_SetupDefaultAction(menu, self)
    menu:SetLayoutRectAndLines(self:GetRight() + 16, self:GetTop(), 64, 0)
    menu:AddItem(-98709763, {id = "switch", flag = false}, changeTbl)
    menu:AddItem(-288334206, {id = "help", flag = true}, helpTbl)
    menu:SetCurrentModifyItem(0)
    function changeTbl:decideAction()
      FUNC_COMMON:SetEnableTeamSkill(index, not enable)
      local checkMark = "[M:CM00]"
      local space = "[S:8]"
      local name = FUNC_COMMON:GetTeamSkillName(index)
      if FUNC_COMMON:IsEnableTeamSkill(index) then
        parentMenu.curItem.text = checkMark .. name
      else
        parentMenu.curItem.text = space .. name
      end
      self:Close()
    end
    function helpTbl:decideAction()
      FlowSys.Stat.nextFunc = "dungeonMenuExplainWindow"
      FlowSys.Stat.returnFunc = "dungeonMenuTeamSkill"
      FlowSys.Stat.textId = FUNC_COMMON:GetTeamSkillExplainTextId(index)
      curPos = parentMenu:GetCursorItemIndex()
      self:Close()
    end
    function menu:itemPreOpenModifyAction()
      if SYSTEM:IsMultiPlayMode() and self.curItem.obj.id == "switch" then
        self.curItem.grayed = true
      end
    end
    menu:Open()
    MENU:SetFocus(menu)
    MENU:WaitClose(menu)
    if menu.curItem.obj.flag then
      self:Close()
    end
  end
  function pageMenu:currentItemChange()
    CommonSys:UpdateBasicMenu_LineHelp(FUNC_COMMON:GetTeamSkillOneLineExplainText(self.curItem.obj))
  end
  function nothingTBL:decideAction()
  end
  FlowSys:SetupMenuEventAction(pageMenu)
  local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_TEAM_SKILL)
  pageMenu:Open()
  pageMenu:SetCursorItemIndex(index)
  pageMenu:SetCurrentModifyItem(index)
  CommonSys:UpdateBasicMenu_LineHelp(FUNC_COMMON:GetTeamSkillOneLineExplainText(pageMenu.curItem.obj))
  MENU:SetFocus(pageMenu)
  WaitAndForcedClose(pageMenu)
  DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_TEAM_SKILL, curPos)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuOperation()
  FlowSys.Stat.nextFunc = "dungeonMenuParty"
  local lineHelp = 2041489363
  if SYSTEM:IsDungeonMenu() and DUNGEON_MENU:CanSelectChangeLeader() then
    lineHelp = 1384379408
  end
  CommonSys:OpenBasicMenu(1108175045, -1264739534, lineHelp)
  local partySelectMenu = MENU:CreatePageMenu()
  partySelectMenu:SetLayoutRectAndLines(16, 40, 208, 0)
  partySelectMenu:SetDecideSound(false)
  local playerIndex = 0
  local playerTbl, partyTbl = {}, {}
  for i = 1, FUNC_COMMON:GetPartyMemberCount() do
    if FUNC_COMMON:IsPlayer(i - 1) then
      playerIndex = i - 1
      MENU:SetTag_String(0, FUNC_COMMON:GetCharaName(i - 1))
      local text = MENU:ReplaceTagText(567278446)
      partySelectMenu:AddItem(text, i - 1, playerTbl)
    else
      MENU:SetTag_String(0, FUNC_COMMON:GetCharaName(i - 1))
      MENU:SetTag_String(1, FUNC_COMMON:GetPartyOrderName(i - 1))
      local text = MENU:ReplaceTagText(-630901071)
      partySelectMenu:AddItem(text, i - 1, partyTbl)
    end
  end
  if 1 < FUNC_COMMON:GetPartyMemberCount() then
    partySelectMenu:AddItem("[HO:8]" .. MENU:GetTextPoolText(-659092339), "all", partyTbl)
  end
  function partySelectMenu:currentItemChange()
    if SYSTEM:IsDungeonMenu() then
      if self.curItem.obj == "all" then
        SetStatusAndCameraTarget(playerIndex)
      else
        SetStatusAndCameraTarget(self.curItem.obj)
      end
    end
  end
  function partySelectMenu:inputYSelectAction()
    if SYSTEM:IsDungeonMenu() and DUNGEON_MENU:CanSelectChangeLeader() and self.curItem.obj ~= "all" and not FUNC_COMMON:IsPlayer(self.curItem.obj) then
      SOUND:PlaySe(SymSnd("SE_SYS_MARK"))
      CommonSys:EndLowerMenuNavi(true)
      CommonSys:SetVisibleBasicMenu(false)
      self:SetVisible(false)
      do
        local retValue = false
        local param = DUNGEON_MENU:CanChangeLeader(self.curItem.obj)
        if param ~= ChangeLeaderParameter.CHANGE_OK then
          if param == ChangeLeaderParameter.CHANGE_NG_SHOPPING then
            DUNGEON_MENU:PrintDungeonLog(-1120366300)
          elseif param == ChangeLeaderParameter.CHANGE_NG_DOROBOU then
            DUNGEON_MENU:PrintDungeonLog(-338448649)
          elseif param == ChangeLeaderParameter.CHANGE_NG_STATUS then
            DUNGEON_MENU:PrintDungeonLog(-1907980739)
          elseif param == ChangeLeaderParameter.CHANGE_NG_OTHER then
            DUNGEON_MENU:PrintDungeonLog(-338448649)
          end
        else
          local askMenu = MENU:CreateAskMenu()
          askMenu:Setup(true, false, false)
          askMenu:AddItem(1671044141, nil, {
            decideAction = function(self)
              retValue = true
              self:CloseAndClearFocus()
            end
          })
          askMenu:AddItem(724586836, nil, {
            decideAction = function(self)
              retValue = false
              self:CloseAndClearFocus()
            end
          })
          function askMenu:cancelAction()
            retValue = false
            self:CloseAndClearFocus()
          end
          MENU:SetFocus(askMenu)
          MENU:SetTag_MonsterString(1, DUNGEON_MENU:GetCharaName(self.curItem.obj))
          WINDOW:Log(-48726571)
          WINDOW:SelectSetLuaMenu(askMenu)
          WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
          WINDOW:CloseMessage()
          MENU:SetFocus(self)
          if retValue then
            playerIndex = self.curItem.obj
            DUNGEON_MENU:ChangeLeader(self.curItem.obj)
            SetDungeonMenuNoParam()
            FlowSys.Stat.nextFunc = "dungeonMenuEnd"
            self:Close()
          end
        end
        if not retValue then
          CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
          CommonSys:SetVisibleBasicMenu(true)
          self:SetVisible(true)
        end
      end
    end
  end
  function playerTbl:decideAction()
  end
  function partyTbl:decideAction()
    SOUND:PlaySe(SymSnd("SE_SYS_DECIDE"))
    local pokeIndex = self.curItem.obj
    local orderMenu = MENU:CreatePageMenu()
    NestMenu_SetupDefaultAction(orderMenu, self)
    self:SetVisible(false)
    orderMenu.parentMenu = self
    orderMenu:SetLayoutRectAndLines(16, 40, 136, 0)
    local caption
    local bAll = false
    if self.curItem.obj == "all" then
      caption = MENU:GetTextPoolText(-659092339)
      bAll = true
    else
      caption = "[CS:F]" .. FUNC_COMMON:GetCharaName(pokeIndex) .. "[CR]"
    end
    orderMenu:SetCaption(caption)
    for i = 1, FUNC_COMMON:GetOrderMax() - 1 do
      orderMenu:AddItem(FUNC_COMMON:GetOrderName(i), i, nil)
    end
    function orderMenu:cancelAction()
      self:Close()
    end
    function orderMenu:decideAction()
      local parentMenu = self
      local orderId = self.curItem.obj
      local changeTbl, helpTbl = {}, {}
      local menu = MENU:CreatePageMenu()
      NestMenu_SetupDefaultAction(menu, self)
      menu:SetLayoutRectAndLines(self:GetRight() + 16, self:GetTop(), 64, 0)
      menu:AddItem(-98709763, false, changeTbl)
      menu:AddItem(-288334206, true, helpTbl)
      menu:SetCurrentModifyItem(0)
      function changeTbl:decideAction()
        if bAll then
          for i = 1, FUNC_COMMON:GetPartyMemberCount() do
            if not FUNC_COMMON:IsPlayer(i - 1) then
              FUNC_COMMON:SetOrderIndex(i - 1, orderId)
            end
          end
        else
          FUNC_COMMON:SetOrderIndex(pokeIndex, orderId)
        end
        self:Close()
      end
      function helpTbl:decideAction()
        self:SetVisible(false)
        parentMenu:SetVisible(false)
        local textId = FUNC_COMMON:GetOrderExplainTextId(orderId)
        local explainWindow = CommonSys:OpenBasicExplainMenu(textId, nil)
        MENU:SetFocus(explainWindow)
        local bForce = false
        local num = 0
        if FlowSys.Stat.forcedClose == nil then
          FlowSys.Stat.forcedClose = {}
        else
          num = table.maxn(FlowSys.Stat.forcedClose)
        end
        FlowSys.Stat.forcedClose[num + 1] = function()
          explainWindow:NotifyForceClose()
          FlowSys.Stat.nextFunc = "dungeonMenuEnd"
          bForce = true
        end
        FlowSys:WaitCloseMenu(explainWindow)
        FlowSys.Stat.forcedClose[num + 1] = nil
        if bForce == false then
          self:SetVisible(true)
          parentMenu:SetVisible(true)
          MENU:SetFocus(self)
        else
          CommonSys:SetVisibleBasicMenu(false)
        end
      end
      menu:Open()
      MENU:SetFocus(menu)
      WaitAndForcedClose(menu)
      if bAll then
        for i = 1, FUNC_COMMON:GetPartyMemberCount() do
          if not FUNC_COMMON:IsPlayer(i - 1) then
            MENU:SetTag_String(0, FUNC_COMMON:GetCharaName(i - 1))
            MENU:SetTag_String(1, FUNC_COMMON:GetPartyOrderName(i - 1))
            self.parentMenu:SetCurrentModifyItem(i - 1)
            self.parentMenu.curItem.text = MENU:ReplaceTagText(-630901071)
          end
        end
        local curIndex = FUNC_COMMON:GetPartyMemberCount()
        self.parentMenu:SetCurrentModifyItem(curIndex)
      else
        MENU:SetTag_String(0, FUNC_COMMON:GetCharaName(pokeIndex))
        MENU:SetTag_String(1, FUNC_COMMON:GetPartyOrderName(pokeIndex))
        self.parentMenu.curItem.text = MENU:ReplaceTagText(-630901071)
      end
      if menu:IsResult() then
        self:Close()
      end
    end
    function orderMenu:currentItemChange()
      CommonSys:UpdateBasicMenu_LineHelp(FUNC_COMMON:GetOrderOneLineExplainText(self.curItem.obj))
    end
    orderMenu:SetCursorItemIndex(0)
    orderMenu:SetCurrentModifyItem(0)
    CommonSys:UpdateBasicMenu_LineHelp(FUNC_COMMON:GetOrderOneLineExplainText(orderMenu.curItem.obj))
    orderMenu:Open()
    MENU:SetFocus(orderMenu)
    WaitAndForcedClose(orderMenu)
    CommonSys:UpdateBasicMenu_LineHelp(lineHelp)
    if FlowSys.Stat.nextFunc == "dungeonMenuExplainWindow" then
      self:Close()
    else
      self:SetVisible(true)
    end
  end
  function partySelectMenu:cancelAction()
    self:Close()
  end
  FlowSys:SetupMenuEventAction(partySelectMenu)
  partySelectMenu:Open()
  MENU:SetFocus(partySelectMenu)
  partySelectMenu:SetCursorItemIndex(playerIndex)
  partySelectMenu:SetCurrentModifyItem(playerIndex)
  WaitAndForcedClose(partySelectMenu)
  if SYSTEM:IsDungeonMenu() then
    SetStatusAndCameraTarget(playerIndex)
  end
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuPartyProc()
  if SYSTEM:IsDungeonMenu() then
    DUNGEON_MENU:CloseDungeonLog()
  end
  local titleText = ""
  if FUNC_COMMON:IsTeamOpen() and not SYSTEM:IsSimpleDungeonMode() then
    titleText = FUNC_COMMON:GetTeamName()
  else
    titleText = MENU:GetTextPoolText(-1544121339)
  end
  CommonSys:OpenBasicMenu(titleText)
  local buttonMenu = MENU:CreatePartyMenu()
  local partyNum = FUNC_COMMON:GetPartyMemberCount()
  local playerIndex = 0
  if SYSTEM:IsMultiPlayMode() then
    FUNC_COMMON:ResetMultiMemberChange()
  end
  NestMenu_SetupDefaultAction(buttonMenu, nil)
  for i = 0, 3 do
    local x = i % 2 == 0 and 17 or 169
    local y = i < 2 and 40 or 128
    if i < partyNum then
      buttonMenu:AddPartyWindow(i, Rectangle(x, y, 0, 0), {
        id = i,
        nextFunc = "dungeonMenuTsuyosa"
      }, nil)
      if FUNC_COMMON:IsPlayer(i) then
        playerIndex = i
      end
    else
      buttonMenu:AddDummy()
    end
  end
  local teamSkillButton = MENU:CreateButtonMenuWindow()
  teamSkillButton:SetRectangle(Rectangle(25, 216, 118, 14))
  teamSkillButton:SetText(-79434350)
  buttonMenu:AddButtonMenuWindowItem(teamSkillButton, {
    id = nil,
    nextFunc = "dungeonMenuTeamSkill"
  }, nil)
  local orderButton = MENU:CreateButtonMenuWindow()
  orderButton:SetRectangle(Rectangle(177, 216, 118, 14))
  orderButton:SetText(-2075610640)
  buttonMenu:AddButtonMenuWindowItem(orderButton, {
    id = nil,
    nextFunc = "dungeonMenuOperation"
  }, nil)
  if not FUNC_COMMON:IsTeamOpen() then
    buttonMenu:SetCurrentModifyItem(4)
    buttonMenu.curItem.grayed = true
    buttonMenu:SetCurrentModifyItem(0)
  end
  if not FUNC_COMMON:IsOrderOpen() then
    buttonMenu:SetCurrentModifyItem(5)
    buttonMenu.curItem.grayed = true
    buttonMenu:SetCurrentModifyItem(0)
  end
  buttonMenu:SetOption({
    inputMode = "VNH2_LINE",
    selectMode = "NORMAL",
    iconCursor = "TEAM"
  })
  function buttonMenu:cancelAction()
    SetStatusAndCameraTarget(playerIndex)
    self:Close()
  end
  function buttonMenu:decideAction()
    FlowSys.Stat.nextFunc = self.curItem.obj.nextFunc
    FlowSys.Stat.pokeSelect = self.curItem.obj.id
    FlowSys.Stat.useWarehouseId = false
    self:Close()
  end
  function buttonMenu:currentItemChange()
    if self.curItem.obj.nextFunc == "dungeonMenuTsuyosa" then
      self:SetVisibleIconCursor(true)
      self:SetVisibleNormalCursor(false)
    else
      self:SetVisibleIconCursor(false)
      self:SetVisibleNormalCursor(true)
    end
    if SYSTEM:IsDungeonMenu() then
      local partyIndex = self.curItem.obj.id
      if partyIndex == nil then
        partyIndex = playerIndex
      end
      SetStatusAndCameraTarget(partyIndex)
    end
  end
  FlowSys:SetupMenuEventAction(buttonMenu)
  local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_MAIN)
  if index >= 0 and index <= 3 and partyNum <= index then
    index = partyNum - 1
  end
  buttonMenu:Open()
  buttonMenu:SetCursorItemIndex(index)
  buttonMenu:SetCurrentModifyItem(index)
  if index < 4 then
    buttonMenu:SetVisibleIconCursor(true)
    buttonMenu:SetVisibleNormalCursor(false)
    SetStatusAndCameraTarget(index)
  else
    buttonMenu:SetVisibleIconCursor(false)
    buttonMenu:SetVisibleNormalCursor(true)
    SetStatusAndCameraTarget(playerIndex)
  end
  MENU:SetFocus(buttonMenu)
  teamSkillButton:SetOption({
    frameMode = FrameMode.BUTTON
  })
  orderButton:SetOption({
    frameMode = FrameMode.BUTTON
  })
  WaitAndForcedClose(buttonMenu)
  DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_PARTY_MAIN, buttonMenu:GetCursorItemIndex())
  CommonSys:CloseBasicMenu()
end
function dungeonMenuParty()
  FlowSys.Stat.nextFunc = "dungeonMenuMain"
  dungeonMenuPartyProc()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuOption()
  local bChange = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  }
  local changeCnt = 0
  local getValue = {}
  getValue[1] = FUNC_COMMON:GetMessageSpeed()
  getValue[2] = FUNC_COMMON:GetWindowType()
  getValue[3] = FUNC_COMMON:GetBGMVolume()
  getValue[4] = FUNC_COMMON:GetSEVolume()
  getValue[5] = FUNC_COMMON:IsEnableGrid()
  getValue[6] = FUNC_COMMON:GetWalkType()
  getValue[7] = FUNC_COMMON:GetFarPartyWatchType()
  getValue[8] = FUNC_COMMON:IsDamageTurnAround()
  getValue[9] = FUNC_COMMON:IsVisibleFloorMap()
  getValue[10] = FUNC_COMMON:IsWazaSkip()
  local SetFuncTbl = {
    FUNC_COMMON.SetMessageSpeed,
    FUNC_COMMON.SetWindowType,
    FUNC_COMMON.SetBGMVolume,
    FUNC_COMMON.SetSEVolume,
    FUNC_COMMON.SetEnableGrid,
    FUNC_COMMON.SetWalkType,
    FUNC_COMMON.SetFarPartyWatchType,
    FUNC_COMMON.SetDamageTurnAround,
    FUNC_COMMON.SetVisibleFloorMap,
    FUNC_COMMON.SetWazaSkip
  }
  local ExplainTbl = {
    -586448810,
    -2136308537,
    174418530,
    -873695230,
    -1141302813,
    -230247424,
    -1146822716,
    692004743,
    1191142360,
    886579050
  }
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  FlowSys.Stat.selectFlag = false
  CommonSys:OpenBasicMenu(-520671056, -1234842592, ExplainTbl[2])
  local menu = MENU:CreateParameterMenu()
  local messageTbl, windowTbl, BGMTbl, SETbl, gridTbl, walkTbl, watchTbl, turnTbl, floorMapTbl, wazaSkipTbl = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
  menu:SetLayoutRectAndLines(16, 40, 288, 0)
  menu:AddItemS(751263837, 2, windowTbl)
  menu:AddSelectString(-1525431502, 0)
  menu:AddSelectString(-1908502287, 1)
  menu:AddSelectString(-1759141456, 2)
  menu:AddSelectString(-664520841, 3)
  menu:AddSelectString(-1048639946, 4)
  local bEnableDLC = true
  if bEnableDLC then
    menu:AddSelectString(-363702795, 5)
  end
  menu:SetSelectStringIndexObj(getValue[2])
  menu:AddItemS(-1233757917, ValueParamEx(0, 0, 0, 1, 1, 1), 3, BGMTbl)
  menu:AddSelectString(-1633692014, 0)
  menu:AddSelectString(-2021333037, 1)
  menu:AddSelectString(-1398164464, 2)
  menu:AddSelectString(-1246591663, 3)
  menu:AddSelectString(-84733034, 4)
  menu:AddSelectString(-471325993, 5)
  menu:SetSelectStringIndexObj(getValue[3])
  menu:AddItemS(286545344, ValueParamEx(0, 0, 0, 1, 1, 1), 4, SETbl)
  menu:AddSelectString(-1633692014, 0)
  menu:AddSelectString(-2021333037, 1)
  menu:AddSelectString(-1398164464, 2)
  menu:AddSelectString(-1246591663, 3)
  menu:AddSelectString(-84733034, 4)
  menu:AddSelectString(-471325993, 5)
  menu:SetSelectStringIndexObj(getValue[4])
  menu:AddItemS(-313804126, 5, gridTbl)
  menu:AddSelectString(954652071, false)
  menu:AddSelectString(-325467047, true)
  menu:SetSelectStringIndexObj(getValue[5])
  menu:AddItemS(-1527507135, 6, walkTbl)
  menu:AddSelectString(-561297773, 0)
  menu:AddSelectString(-166710809, 1)
  menu:SetSelectStringIndexObj(getValue[6])
  menu:AddItemS(-1021116380, 7, watchTbl)
  menu:AddSelectString(1513899653, 0)
  menu:AddSelectString(-85936536, 1)
  menu:SetSelectStringIndexObj(getValue[7])
  if not SYSTEM:IsMultiPlayMode() then
    menu:AddItemS(2139980998, 8, turnTbl)
    menu:AddSelectString(-1166292960, false)
    menu:AddSelectString(-1164636015, true)
    menu:SetSelectStringIndexObj(getValue[8])
  end
  menu:AddItemS(-1658333130, 9, floorMapTbl)
  menu:AddSelectString(1465659016, false)
  menu:AddSelectString(304359298, true)
  menu:SetSelectStringIndexObj(getValue[9])
  menu:AddItemS(1281343626, 10, wazaSkipTbl)
  menu:AddSelectString(-1945791937, false)
  menu:AddSelectString(-1377694946, true)
  menu:SetSelectStringIndexObj(getValue[10])
  function menu:currentItemValueChange()
    local index = self.curItem.obj
    if getValue[index] ~= self.curItem.value then
      if not bChange[index] then
        changeCnt = changeCnt + 1
        bChange[index] = true
      end
    elseif bChange[index] then
      changeCnt = changeCnt - 1
      bChange[index] = false
    end
    SetFuncTbl[index](FUNC_COMMON, self.curItem.selectValueObj)
  end
  function menu:currentItemChange()
    local index = self.curItem.obj
    CommonSys:UpdateBasicMenu_LineHelp(ExplainTbl[index])
  end
  function menu:decideAction()
    if changeCnt > 0 then
      CommonSys:EndLowerMenuNavi(true)
      do
        local retValue = false
        local askMenu = MENU:CreateAskMenu()
        askMenu:SetLayoutRectAndLines(336, 120, 48, 0)
        NestMenu_SetupDefaultAction(askMenu, self)
        askMenu:Setup(true, false, false)
        askMenu:AddItem(988391103, nil, {
          decideAction = function(self)
            retValue = true
            self:CloseAndClearFocus()
          end
        })
        askMenu:AddItem(383352875, nil, {
          decideAction = function(self)
            retValue = false
            self:CloseAndClearFocus()
          end
        })
        function askMenu:cancelAction()
          retValue = false
          self:CloseAndClearFocus()
        end
        askMenu:SetDefaultCursorDispIndex(1)
        WINDOW:Log(271716539)
        WINDOW:SelectSetLuaMenu(askMenu)
        WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
        WINDOW:CloseMessage()
        if retValue then
          FUNC_COMMON:DecisionOptionSetting()
          self:Close()
        end
        local caption
        if SYSTEM:IsDungeonMenu() then
          caption = DUNGEON_MENU:GetDungeonName()
        end
        CommonSys:BeginLowerMenuNavi(caption, true, true)
      end
    else
      FUNC_COMMON:DecisionOptionSetting()
      self:Close()
    end
  end
  function menu:cancelAction()
    FUNC_COMMON:CancelOptionSetting()
    self:Close()
  end
  menu:Open()
  menu:SetPageIconPos(136, 256)
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuQuest()
  local PrintLogNoQuest = function()
    CommonSys:EndLowerMenuNavi(true)
    local num = 0
    local bForce = false
    if FlowSys.Stat.forcedClose == nil then
      FlowSys.Stat.forcedClose = {}
    else
      num = table.maxn(FlowSys.Stat.forcedClose)
    end
    FlowSys.Stat.forcedClose[num + 1] = function()
      DUNGEON_MENU:CloseDungeonLog()
      FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      bForce = true
    end
    DUNGEON_MENU:PrintDungeonLog(1537963293)
    if bForce == false then
      CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
    end
  end
  FlowSys.Stat.nextFunc = "dungeonMenuMain"
  if not QUEST:IsCurrentQuestInfo() then
    PrintLogNoQuest()
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  FUNC_COMMON:SetUsedMenuLog(UsedMenuKind.USED_MENU_KIND_QUEST_MEMO)
  CommonSys:OpenBasicMenu(-1698638781, -1446619135)
  local menu = MENU:CreateExplainMenuWindow(ScreenType.B)
  menu:SetLayoutRect(Rectangle(16, 40, 288, 168))
  menu:SetFontType(FontType.TYPE_12)
  menu:SetText(GetCurrentQuestDetailText())
  function menu:drawFunc()
    menu:DrawHorizontalLine(0, 18, 288)
    menu:DrawHorizontalLine(0, 70, 288)
    menu:DrawHorizontalLine(0, 138, 288)
  end
  function menu:decideAction()
    self:Close()
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuARQuest()
  local PrintLogNoQuest = function()
    CommonSys:EndLowerMenuNavi(true)
    local num = 0
    local bForce = false
    if FlowSys.Stat.forcedClose == nil then
      FlowSys.Stat.forcedClose = {}
    else
      num = table.maxn(FlowSys.Stat.forcedClose)
    end
    FlowSys.Stat.forcedClose[num + 1] = function()
      DUNGEON_MENU:CloseDungeonLog()
      FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      bForce = true
    end
    DUNGEON_MENU:PrintDungeonLog(1537963293)
    if bForce == false then
      CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
    end
  end
  FlowSys.Stat.nextFunc = "dungeonMenuMain"
  if not QUEST:IsCurrentQuestInfo() then
    PrintLogNoQuest()
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  FUNC_COMMON:SetUsedMenuLog(UsedMenuKind.USED_MENU_KIND_QUEST_MEMO)
  CommonSys:OpenBasicMenu(1302355609, -1446619135)
  local menu = MENU:CreateExplainMenuWindow(ScreenType.B)
  menu:SetLayoutRect(Rectangle(16, 40, 288, 168))
  menu:SetFontType(FontType.TYPE_12)
  menu:SetText(GetCurrentQuestDetailText())
  function menu:drawFunc()
    menu:DrawHorizontalLine(0, 24, 288)
    menu:DrawHorizontalLine(0, 76, 288)
  end
  function menu:decideAction()
    self:Close()
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuSearch()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  local explain
  if SYSTEM:IsSimpleDungeonMode() then
    explain = 1067865875
  else
    explain = 161074885
  end
  if FUNC_COMMON:CheckScenarioLevelOpenFlag("wonder_power_open") then
    if DUNGEON_MENU:IsJoiningDungeon() then
      CommonSys:OpenBasicMenu(-847202024, -89165365, explain)
    else
      CommonSys:OpenBasicMenu(-1847204301, -89165365, explain)
    end
  else
    CommonSys:OpenBasicMenu(1772359496, -89165365, explain)
  end
  local pageMenu = MENU:CreatePageMenu()
  pageMenu:SetLayoutRectAndLines(16, 40, 288, 7, 18)
  pageMenu:ShowPageNum(true)
  pageMenu:SetShowCurosr(false)
  local cnt = DUNGEON_MENU:GetPokemonSearchLineNum()
  for i = 0, cnt - 1 do
    local text = DUNGEON_MENU:GetPokemonSearchString(i)
    pageMenu:AddItem(MENU:ReplaceTagText(text), nil, nil)
  end
  function pageMenu:decideAction()
  end
  function pageMenu:cancelAction()
    self:Close()
  end
  pageMenu:Open()
  MENU:SetFocus(pageMenu)
  WaitAndForcedClose(pageMenu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuVWave()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  CommonSys:OpenBasicMenu(745863168, -1446619135)
  local menu = MENU:CreateExplainMenuWindow(ScreenType.B)
  menu:SetLayoutRect(Rectangle(16, 40, 288, 160))
  menu:SetTextOffset(0, 0)
  menu:SetOption({
    frameMode = FrameMode.NORMAL
  })
  MENU:SetTag_String(0, FUNC_COMMON:GetTypeName(FUNC_COMMON:GetVWaveType()))
  MENU:SetTag_String(6, FUNC_COMMON:GetTypeIconTag(FUNC_COMMON:GetVWaveType()))
  MENU:SetTag_String(1, FUNC_COMMON:GetBenefitName(FUNC_COMMON:GetBaseBenefit(0)))
  MENU:SetTag_String(2, FUNC_COMMON:GetBenefitName(FUNC_COMMON:GetBaseBenefit(1)))
  MENU:SetTag_String(3, FUNC_COMMON:GetBenefitName(FUNC_COMMON:GetBaseBenefit(2)))
  MENU:SetTag_String(4, FUNC_COMMON:GetBenefitName(FUNC_COMMON:GetChoiceBenefit(0)))
  MENU:SetTag_String(5, FUNC_COMMON:GetBenefitName(FUNC_COMMON:GetChoiceBenefit(1)))
  menu:SetText(1873069373)
  function menu:drawFunc()
    menu:DrawHorizontalLine(0, 34, 288)
  end
  function menu:decideAction()
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuMessage()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  CommonSys:OpenBasicMenu(1512227428, 1705083048)
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  end
  FlowSys.Stat.forcedClose[1] = function()
    FUNC_COMMON:CloseLogHistory()
    FlowSys.Stat.nextFunc = "dungeonMenuEnd"
  end
  FUNC_COMMON:OpenLogHistory()
  FlowSys.Stat.forcedClose = nil
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuWorldMap()
  FlowSys:Next("dungeonMenuOthers")
end
function dungeonMenuDungeonState()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  CommonSys:OpenBasicMenu(1911937417, 2075629064)
  local count = 0
  local menu = MENU:CreatePageMenu()
  NestMenu_SetupDefaultAction(menu, nil)
  menu:SetLayoutRectAndLines(16, 40, 144, 8)
  for index = 1, DUNGEON_MENU:GetDungeonStatusIndexMax() - 1 do
    if DUNGEON_MENU:HasDungeonStatus(index) then
      local name = FUNC_COMMON:GetDungeonStatusName(index)
      menu:AddItem(name, index, nil)
      count = count + 1
    end
  end
  if count == 0 then
    menu:AddItem("", nil, nil)
  end
  function menu:decideAction()
    if self.curItem.obj == nil then
      return
    end
    FlowSys.Stat.nextFunc = "dungeonMenuExplainWindow"
    FlowSys.Stat.returnFunc = "dungeonMenuDungeonState"
    FlowSys.Stat.textId = FUNC_COMMON:GetDungeonStatusExplainTextId(self.curItem.obj)
    self:Close()
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuDungeonHint()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  local CheckScenario = function(label)
    return FUNC_COMMON:CheckScenarioLevelOpenFlag(label)
  end
  local CheckHint = function(label)
    return FUNC_COMMON:CheckHaveEverExcutedHint(label)
  end
  local ItemTBL = {
    {
      item = 341062157,
      condition = nil,
      caption = nil,
      explain = -890877955
    },
    {
      item = 223281996,
      condition = nil,
      caption = nil,
      explain = -738363716
    },
    {
      item = 1108252043,
      condition = nil,
      caption = nil,
      explain = -1665343365
    },
    {
      item = 1528145098,
      condition = nil,
      caption = nil,
      explain = -2052599494
    },
    {
      item = 1882781449,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_team",
        flag = true
      },
      caption = nil,
      explain = -1366654215
    },
    {
      item = 1763952200,
      condition = nil,
      caption = nil,
      explain = -1215188040
    },
    {
      item = -289678713,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_quest",
        flag = true
      },
      caption = nil,
      explain = 805941111
    },
    {
      item = -246173573,
      condition = nil,
      caption = nil,
      explain = -981464377
    },
    {
      item = -397901510,
      condition = nil,
      caption = nil,
      explain = -593806458
    },
    {
      item = -1016737031,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_scinario_end",
        flag = false
      },
      caption = nil,
      explain = -139040699
    },
    {
      item = -629218376,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_scinario_end",
        flag = true
      },
      caption = nil,
      explain = -290629372
    },
    {
      item = -1791003265,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_enemy_evolution",
        flag = true
      },
      caption = nil,
      explain = -1578315837
    },
    {
      item = -1943780290,
      condition = {
        func = CheckHint,
        label = "OPEN_HUSHIGIDO_GUIDE_1",
        flag = true
      },
      caption = nil,
      explain = -1191707006
    }
  }
  local AddHintItem = function(menu, tbl)
    if tbl.condition ~= nil and tbl.condition.func(tbl.condition.label) ~= tbl.condition.flag then
      return
    end
    menu:AddItem(tbl.item, {
      caption = tbl.caption,
      explain = tbl.explain
    }, nil)
  end
  CommonSys:OpenBasicMenu(256994955, 2075629064)
  local menu = MENU:CreatePageMenu()
  NestMenu_SetupDefaultAction(menu, nil)
  menu:SetLayoutRectAndLines(16, 40, 160, 8)
  menu:ShowPageNum(true)
  for i, k in ipairs(ItemTBL) do
    AddHintItem(menu, k)
  end
  function menu:decideAction()
    local explain = MENU:CreateExplainMenuWindow(ScreenType.B)
    explain:SetLayoutRect(Rectangle(16, 40, 288, 144))
    explain:SetTextOffset(8, 8)
    explain:SetFontType(FontType.TYPE_12)
    explain:SetOption({
      frameMode = FrameMode.NORMAL
    })
    explain:SetText(self.curItem.obj.explain)
    CommonSys:UpdateBasicMenu_PadHelp(-1446619135)
    NestMenu_SetupDefaultAction(explain, self, true)
    explain:Open()
    MENU:SetFocus(explain)
    WaitAndForcedClose(explain)
    CommonSys:UpdateBasicMenu_PadHelp(2075629064)
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuGameHint()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  local CheckScenario = function(label)
    return FUNC_COMMON:CheckScenarioLevelOpenFlag(label)
  end
  local CheckHint = function(label)
    return FUNC_COMMON:CheckHaveEverExcutedHint(label)
  end
  local CheckSaveMode = function(label)
    return SYSTEM:GetSaveStatus() ~= SAVE_STATUS.START
  end
  local ItemTBL = {
    {
      item = 1064919502,
      condition = nil,
      caption = nil,
      explain = -506784706
    },
    {
      item = -140448826,
      condition = nil,
      caption = nil,
      explain = 689086006
    },
    {
      item = -315060711,
      condition = {
        func = CheckScenario,
        label = "free_start",
        flag = true
      },
      caption = nil,
      explain = -1723440157
    },
    {
      item = -552670053,
      condition = {
        func = CheckScenario,
        label = "free_start",
        flag = true
      },
      caption = nil,
      explain = -1418722975
    },
    {
      item = -1873839524,
      condition = {
        func = CheckScenario,
        label = "free_start",
        flag = true
      },
      caption = nil,
      explain = -466511962
    },
    {
      item = -1990964451,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_quest",
        flag = true
      },
      caption = nil,
      explain = -47536409
    },
    {
      item = -883566034,
      condition = {
        func = CheckScenario,
        label = "parapoint_open",
        flag = true
      },
      caption = nil,
      explain = 1700826691
    },
    {
      item = -1569122082,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_team",
        flag = true
      },
      caption = nil,
      explain = -704121564
    },
    {
      item = 1304537216,
      condition = {
        func = CheckScenario,
        label = "parapoint_open",
        flag = true
      },
      caption = nil,
      explain = -470483731
    },
    {
      item = -1151194721,
      condition = {
        func = CheckScenario,
        label = "shop_giftshop_open",
        flag = true
      },
      caption = nil,
      explain = -820198299
    },
    {
      item = 1023030608,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_team",
        flag = true
      },
      caption = nil,
      explain = 1216665770
    },
    {
      item = 635503633,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_v_wave",
        flag = true
      },
      caption = nil,
      explain = 1369434603
    },
    {
      item = 262131211,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_v_wave",
        flag = true
      },
      caption = nil,
      explain = 1064775047
    },
    {
      item = 377814858,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_paradise_mode",
        flag = true
      },
      caption = nil,
      explain = 644619462
    },
    {
      item = 1034529929,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_paradise_mode",
        flag = true
      },
      caption = nil,
      explain = 222383877
    },
    {
      item = 615685576,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_paradise_mode",
        flag = true
      },
      caption = nil,
      explain = 341474884
    },
    {
      item = 1811090191,
      condition = {
        func = CheckScenario,
        label = "gamemenu_hint_paradise_mode",
        flag = true
      },
      caption = nil,
      explain = 1528555651
    }
  }
  local AddHintItem = function(menu, tbl)
    if tbl.condition ~= nil and tbl.condition.func(tbl.condition.label) ~= tbl.condition.flag then
      return
    end
    menu:AddItem(tbl.item, {
      caption = tbl.caption,
      explain = tbl.explain
    }, nil)
  end
  CommonSys:OpenBasicMenu(1174413269, 2075629064)
  local menu = MENU:CreatePageMenu()
  NestMenu_SetupDefaultAction(menu, nil)
  menu:SetLayoutRectAndLines(16, 40, 224, 8)
  menu:ShowPageNum(true)
  for i, k in ipairs(ItemTBL) do
    AddHintItem(menu, k)
  end
  function menu:decideAction()
    local explain = MENU:CreateExplainMenuWindow(ScreenType.B)
    explain:SetLayoutRect(Rectangle(16, 40, 288, 144))
    explain:SetTextOffset(8, 8)
    explain:SetFontType(FontType.TYPE_12)
    explain:SetOption({
      frameMode = FrameMode.NORMAL
    })
    explain:SetText(self.curItem.obj.explain)
    CommonSys:UpdateBasicMenu_PadHelp(-1446619135)
    NestMenu_SetupDefaultAction(explain, self, true)
    explain:Open()
    MENU:SetFocus(explain)
    WaitAndForcedClose(explain)
    CommonSys:UpdateBasicMenu_PadHelp(2075629064)
  end
  function menu:cancelAction()
    self:Close()
  end
  menu:Open()
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function bossAccess()
  FlowSys.Stat.nextFunc = "dungeonMenuOthers"
  CommonSys:EndLowerMenuNavi()
  CommonSys:OpenBasicMenu(nil, 2124762465, "")
  SYSTEM:SetBossAccess()
  CommonSys:CloseBasicMenu()
  if SYSTEM:IsDungeonMenu() then
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
  else
    CommonSys:BeginLowerMenuNavi(nil, true)
  end
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuOthers()

  --<==\/=====================\/==>--
  if PAD:Data("L|X") then
    runExtern()
    if SYSTEM:IsDungeonMenu() then
      FlowSys.Stat.nextFunc = "dungeonMenuMain"
    else
      FlowSys.Stat.nextFunc = "groundMenuOpen"
    end
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  --<==/\=====================/\==>--

  CommonSys:OpenBasicMenu(-808412880, 2124762465)
  if SYSTEM:IsDungeonMenu() then
    FlowSys.Stat.nextFunc = "dungeonMenuMain"
  else
    FlowSys.Stat.nextFunc = "groundMenuOpen"
  end
  local giveupTbl = {}
  local menu = MENU:CreatePageMenu()
  NestMenu_SetupDefaultAction(menu, nil)
  menu:SetLayoutRectAndLines(16, 40, 160, 0)
  if SYSTEM:IsDungeonMenu() then
    menu:AddItem(-520671056, "dungeonMenuOption", nil)
    if SYSTEM:IsTrialDemo() == false and SYSTEM:IsMultiPlayMode() == false then
      menu:AddItem(-1754533763, "bossAccess", nil)
    end
    menu:AddItem(1772359496, "dungeonMenuSearch", nil)
    if FUNC_COMMON:IsVWaveOpen() then
      menu:AddItem(745863168, "dungeonMenuVWave", nil)
    end
    menu:AddItem(1512227428, "dungeonMenuMessage", nil)
    menu:AddItem(1911937417, "dungeonMenuDungeonState", nil)
    menu:AddItem(256994955, "dungeonMenuDungeonHint", nil)
    menu:AddItem(1174413269, "dungeonMenuGameHint", nil)
    if SYSTEM:IsDungeon() then
      menu:AddItem(1275260772, nil, giveupTbl)
    end
  else
    menu:AddItem(-520671056, "dungeonMenuOption", nil)
    if SYSTEM:IsTrialDemo() == false and SYSTEM:IsMultiPlayMode() == false then
      menu:AddItem(-1754533763, "bossAccess", nil)
    end
    if FUNC_COMMON:IsVWaveOpen() then
      menu:AddItem(745863168, "dungeonMenuVWave", nil)
    end
    menu:AddItem(1512227428, "dungeonMenuMessage", nil)
    menu:AddItem(256994955, "dungeonMenuDungeonHint", nil)
    menu:AddItem(1174413269, "dungeonMenuGameHint", nil)
    if SYSTEM:IsDungeon() then
      menu:AddItem(1275260772, nil, giveupTbl)
    end
    if SYSTEM:IsDungeon() == false and SYSTEM:IsMultiPlayMode() == false then
      menu:AddItem(-222118978, "groundMenuGotoStart", nil)
    end
  end
  function menu:cancelAction()
    if SYSTEM:IsDungeonMenu() then
      SetDungeonMenuNoParam()
    end
    self:Close()
  end
  function menu:decideAction()
    if self.curItem.obj ~= nil then
      FlowSys.Stat.selectFlag = true
      FlowSys.Stat.nextFunc = self.curItem.obj
      self:Close()
    end
  end
  function giveupTbl:decideAction()
    CommonSys:EndLowerMenuNavi(true)
    CommonSys:SetVisibleBasicMenu(false)
    self:SetVisible(false)
    if Dungeon_Giveup() then
      SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_REST_GIVEUP)
      self:Close()
      if SYSTEM:IsDungeonMenu() then
        FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      else
        FlowSys.Stat.nextFunc = "groundMenuExit"
      end
    else
      CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
      CommonSys:SetVisibleBasicMenu(true)
      self:SetVisible(true)
      MENU:SetFocus(self)
    end
  end
  function menu:itemPreOpenModifyAction()
    if SYSTEM:IsDungeonMenu() and self.curItem.obj == "dungeonMenuSearch" and (DUNGEON_MENU:GetPokemonSearchLineNum() == 0 or SYSTEM:IsSimpleDungeonMode()) then
      self.curItem.grayed = true
    end
  end
  FlowSys:SetupMenuEventAction(menu)
  local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_OTHER_MAIN)
  menu:Open()
  menu:SetCursorItemIndex(index)
  menu:SetCurrentModifyItem(index)
  MENU:SetFocus(menu)
  WaitAndForcedClose(menu)
  DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_OTHER_MAIN, menu:GetCursorItemIndex())
  CommonSys:CloseBasicMenu()
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function CreateDungeonWazaMenu()
  local GenWazaMenuItemWaza = function(poke, waza)
    local buttonTagTbl = {
      "[M:B03]",
      "[M:B05]",
      "[M:B04]",
      "[M:B06]"
    }
    local checkMark = "[HS:8]"
    if FUNC_COMMON:IsPlayer(poke) then
      checkMark = buttonTagTbl[waza + 1]
    elseif DUNGEON_MENU:IsEnableWaza(poke, waza) then
      checkMark = "[HS:8][M:CM00]"
    end
    return checkMark .. DUNGEON_MENU:GetWazaText(poke, waza)
  end
  local WazaMenu = MENU:CreateButtonMenu()
  WazaMenu.base = {}
  for k, v in pairs(class_info(WazaMenu).methods) do
    WazaMenu.base[k] = v
  end
  for k, v in pairs(class_info(WazaMenu).attributes) do
    WazaMenu.base[k] = v
  end
  WazaMenu.wazaDetailWindow = MENU:CreateWazaDetailWindow()
  WazaMenu.partyWazaWindow = MENU:CreatePartyWazaWindow()
  WazaMenu.nameBoard = {}
  WazaMenu.base.SetEnableXButtonDecide(WazaMenu, true)
  local charaTbl, wazaTbl = {}, {}
  local partyCnt = FUNC_COMMON:GetPartyMemberCount()
  local playerIndex = 0
  for i = 1, partyCnt do
    WazaMenu:AddFacePatternItem(24 + 72 * (i - 1), 40, FUNC_COMMON:GetPokemonIndex(i - 1), FACE_TYPE.NORMAL, FACE_FRAME.ENABLE, i - 1, nil)
    local nex = i ~= partyCnt and i or 0
    local prv = i ~= 1 and i - 2 or partyCnt - 1
    WazaMenu:SetItemLink4(i - 1, prv, nex, i - 1, i - 1)
    WazaMenu.nameBoard[i] = MENU:CreateBoardMenuWindow(ScreenType.B)
    WazaMenu.nameBoard[i]:SetLayoutRect(Rectangle(24 + 72 * (i - 1), 100, 56, 16))
    local text = "[CN][CS:F]"
    if FUNC_COMMON:IsPlayer(i - 1) then
      text = "[CN][CS:Y]"
    end
    WazaMenu.nameBoard[i]:SetText(text .. FUNC_COMMON:GetCharaName(i - 1))
    WazaMenu.nameBoard[i]:SetTextOffset(8, 0)
    if FUNC_COMMON:IsPlayer(i - 1) then
      playerIndex = i - 1
    end
  end
  WazaMenu:SetOption({
    inputMode = "LINK",
    selectMode = "NORMAL",
    iconCursor = "WAZA"
  })
  function WazaMenu:cancelAction()
    FlowSys.Stat.selectFlag = false
    self:Close()
  end
  function WazaMenu:decideAction()
    if FUNC_COMMON:GetWazaCount(self.curItem.obj) ~= 0 then
      CommonSys:UpdateBasicMenu_PadHelp(-314954409)
      self.wazaDetailWindow:SetVisible(true)
      self.wazaDetailWindow:SetWazaIndex(self.curItem.obj, self.wazaMenu.curItem.obj)
      self.partyWazaWindow:SetVisible(false)
      MENU:WaitSync()
      MENU:SetFocus(WazaMenu.wazaMenu)
    end
  end
  function WazaMenu:currentItemChange()
    local index = self.curItem.obj + 1
    self.wazaMenu:SetCurrentPageGroup(self.curItem.obj)
    SetStatusAndCameraTarget(self.curItem.obj)
  end
  WazaMenu.wazaMenu = MENU:CreatePageGroupMenu()
  WazaMenu.wazaMenu:SetLayoutRectAndLines(16, 132, 192, 4)
  WazaMenu.wazaMenu:SetCurrentModifyItem(0)
  WazaMenu.wazaMenu:SetEnableXButtonDecide(true)
  WazaMenu.wazaMenu.parentMenu = WazaMenu
  for j = 1, FUNC_COMMON:GetPartyMemberCount() do
    if j > 1 then
      WazaMenu.wazaMenu:AddPageGroup()
    end
    local wazaCnt = FUNC_COMMON:GetWazaCount(j - 1)
    local isPlayer = FUNC_COMMON:IsPlayer(j - 1)
    if wazaCnt == 0 then
      WazaMenu.wazaMenu:AddItem(j - 1, "", 0, nil)
    else
      for i = 1, wazaCnt do
        WazaMenu.wazaMenu:AddItem(j - 1, GenWazaMenuItemWaza(j - 1, i - 1), i - 1, nil)
      end
    end
  end
  function WazaMenu.wazaMenu:cancelAction()
    CommonSys:UpdateBasicMenu_PadHelp(2124762465)
    WazaMenu.wazaDetailWindow:SetVisible(false)
    WazaMenu.partyWazaWindow:SetVisible(true)
    self:SetCurrentPageGroup(self:GetCurrentPageGroupNum(), 0)
    self:SetCurrentModifyItem(self:GetCurrentPageGroupNum(), 0)
    MENU:WaitSync()
    MENU:SetFocus(WazaMenu)
  end
  function WazaMenu.wazaMenu:decideAction()
    FlowSys.Stat.selectFlag = false
    local menu = MENU:CreatePageMenu()
    menu.parentMenu = self
    local wazaSubMenuTbl, wazaChangeTbl, wazaShiftTbl, wazaUpTbl = {}, {}, {}, {}
    local wazaDownTbl, wazaHelpTbl = {}, {}
    local wazaIndex = self.curItem.obj
    local pokeIndex = self.parentMenu.curItem.obj
    NestMenu_SetupDefaultAction(menu, self)
    menu:SetLayoutRectAndLines(self:GetRight() + 16, self:GetTop(), 80, 0)
    menu:SetEnableXButtonDecide(true)
    if FUNC_COMMON:IsPlayer(pokeIndex) then
      menu:AddItem(-166954215, DungeonMenuSelectItems.SELECT_MENU_WAZA_USE, wazaSubMenuTbl)
      menu:SetCurrentModifyItem(0)
      menu.curItem.grayed = not DUNGEON_MENU:IsUseWaza(wazaIndex)
    else
      menu:AddItem(-432529451, nil, wazaChangeTbl)
      menu:SetCurrentModifyItem(0)
      menu.curItem.grayed = SYSTEM:IsMultiPlayMode()
    end
    menu:AddItem(-1666239447, "up", wazaShiftTbl)
    menu:SetCurrentModifyItem(1)
    menu.curItem.grayed = wazaIndex == 0 or not FUNC_COMMON:IsPlayer(pokeIndex) and SYSTEM:IsMultiPlayMode()
    menu:AddItem(1972099526, "down", wazaShiftTbl)
    menu:SetCurrentModifyItem(2)
    menu.curItem.grayed = wazaIndex == FUNC_COMMON:GetWazaCount(pokeIndex) - 1 or not FUNC_COMMON:IsPlayer(pokeIndex) and SYSTEM:IsMultiPlayMode()
    menu:AddItem(-393465091, nil, wazaHelpTbl)
    menu:SetCurrentModifyItem(0)
    function menu:cancelAction()
      SetDungeonMenuNoParam()
      self:Close()
    end
    function wazaSubMenuTbl:decideAction()
      DUNGEON_MENU:SetSelectMenuParam(self.curItem.obj, pokeIndex, DungeonMenuSelectItems.SELECT_MENU_NON, DungeonMenuSelectItems.SELECT_MENU_NON, wazaIndex)
      FlowSys.Stat.selectFlag = true
      self:Close()
    end
    function wazaChangeTbl:decideAction()
      local bEnable = DUNGEON_MENU:IsEnableWaza(pokeIndex, wazaIndex)
      DUNGEON_MENU:SetEnableWaza(pokeIndex, wazaIndex, not bEnable)
      WazaMenu.wazaMenu.curItem.text = GenWazaMenuItemWaza(pokeIndex, wazaIndex)
      self:Close()
    end
    function wazaShiftTbl:decideAction()
      local moveIndex = wazaIndex
      local curIndex = 1
      local checkMark1 = ""
      local checkMark2 = ""
      if self.curItem.obj == "up" then
        moveIndex = moveIndex - 1
        curIndex = 1
        DUNGEON_MENU:WazaShiftUp(pokeIndex, wazaIndex)
      else
        moveIndex = moveIndex + 1
        curIndex = 2
        DUNGEON_MENU:WazaShiftDown(pokeIndex, wazaIndex)
      end
      WazaMenu.wazaMenu:SetCurrentPageGroup(pokeIndex, wazaIndex)
      WazaMenu.wazaMenu.curItem.text = GenWazaMenuItemWaza(pokeIndex, wazaIndex)
      WazaMenu.wazaMenu:SetCurrentPageGroup(pokeIndex, moveIndex)
      WazaMenu.wazaMenu.curItem.text = GenWazaMenuItemWaza(pokeIndex, moveIndex)
      wazaIndex = moveIndex
      WazaMenu.wazaDetailWindow:SetWazaIndex(pokeIndex, wazaIndex)
      self:SetCurrentModifyItem(1)
      self.curItem.grayed = moveIndex == 0
      self:SetCurrentModifyItem(2)
      self.curItem.grayed = moveIndex == FUNC_COMMON:GetWazaCount(pokeIndex) - 1
      self:SetCurrentModifyItem(curIndex)
    end
    function wazaHelpTbl:decideAction()
      WazaMenu:SetVisible(false)
      WazaMenu:SetVisibleIconCursor(false)
      WazaMenu.wazaDetailWindow:SetVisible(true)
      self:SetVisible(false)
      local textId = FUNC_COMMON:GetWazaExplainTextId(DUNGEON_MENU:GetWazaIndex(pokeIndex, wazaIndex))
      local explainWindow = CommonSys:OpenBasicExplainMenu(textId, nil)
      MENU:SetFocus(explainWindow)
      local bForce = false
      local num = 0
      if FlowSys.Stat.forcedClose == nil then
        FlowSys.Stat.forcedClose = {}
      else
        num = table.maxn(FlowSys.Stat.forcedClose)
      end
      FlowSys.Stat.forcedClose[num + 1] = function()
        explainWindow:NotifyForceClose()
        FlowSys.Stat.nextFunc = "dungeonMenuEnd"
        bForce = true
      end
      FlowSys:WaitCloseMenu(explainWindow)
      FlowSys.Stat.forcedClose[num + 1] = nil
      if bForce == false then
        WazaMenu:SetVisible(true)
        WazaMenu:SetVisibleIconCursor(true)
        WazaMenu.partyWazaWindow:SetVisible(false)
        MENU:SetFocus(self)
      else
        CommonSys:SetVisibleBasicMenu(false)
      end
      self:Close()
    end
    menu:Open()
    MENU:SetFocus(menu)
    WaitAndForcedClose(menu)
    if FlowSys.Stat.selectFlag and menu.curItem.obj ~= nil then
      WazaMenu:Close()
    end
  end
  function WazaMenu.wazaMenu:startSelectedAction()
    local pokeIndex = self.parentMenu.curItem.obj
    if not FUNC_COMMON:IsPlayer(pokeIndex) and not SYSTEM:IsMultiPlayMode() then
      SOUND:PlaySe(SymSnd("SE_SYS_MARK"))
      local wazaIndex = self.curItem.obj
      local bEnable = DUNGEON_MENU:IsEnableWaza(pokeIndex, wazaIndex)
      DUNGEON_MENU:SetEnableWaza(pokeIndex, wazaIndex, not bEnable)
      WazaMenu.wazaMenu.curItem.text = GenWazaMenuItemWaza(pokeIndex, wazaIndex)
    end
  end
  WazaMenu.wazaMenu.inputYSelectAction = WazaMenu.wazaMenu.startSelectedAction
  function WazaMenu.wazaMenu:currentItemChange()
    WazaMenu.wazaDetailWindow:SetWazaIndex(WazaMenu.curItem.obj, self.curItem.obj)
  end
  function WazaMenu.wazaMenu:currentPageGroupChange()
    WazaMenu:SetCursorItemIndex(self:GetCurrentPageGroupNum())
    WazaMenu.wazaDetailWindow:SetWazaIndex(WazaMenu.curItem.obj, self.curItem.obj)
    SetStatusAndCameraTarget(self:GetCurrentPageGroupNum())
  end
  function WazaMenu:Open()
    local id = 0
    self.wazaDetailWindow:Open()
    self.wazaDetailWindow:SetVisible(false)
    self.partyWazaWindow:Open()
    self.wazaMenu:Open()
    SetStatusAndCameraTarget(0)
    for i, v in pairs(self.nameBoard) do
      v:Open()
      v:SetFrameAlpha(0)
    end
    self.base.Open(self)
  end
  function WazaMenu:Close()
    self.wazaDetailWindow:Close()
    self.partyWazaWindow:Close()
    self.wazaMenu:Close()
    for i, v in pairs(self.nameBoard) do
      v:Close()
    end
    SetStatusAndCameraTarget(playerIndex)
    self.base.Close(self)
  end
  function WazaMenu:SetVisible(flag)
    self.wazaDetailWindow:SetVisible(flag)
    self.partyWazaWindow:SetVisible(flag)
    self.wazaMenu:SetVisible(flag)
    for i, v in pairs(self.nameBoard) do
      v:SetVisible(flag)
    end
    self.base.SetVisible(self, flag)
  end
  local num = 0
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  else
    num = table.maxn(FlowSys.Stat.forcedClose)
  end
  FlowSys.Stat.forcedClose[num + 1] = function()
    WazaMenu:NotifyForceClose()
    WazaMenu.wazaDetailWindow:NotifyForceClose()
    WazaMenu.partyWazaWindow:NotifyForceClose()
    WazaMenu.wazaMenu:NotifyForceClose()
    for i, v in pairs(WazaMenu.nameBoard) do
      v:NotifyForceClose()
    end
    FlowSys.Stat.nextFunc = "dungeonMenuEnd"
  end
  return WazaMenu
end
function dungeonMenuWaza()
  CommonSys:EndLowerMenuNavi(true)
  CommonSys:BeginUpperDarkFilter(true)
  FlowSys.Stat.nextFunc = "dungeonMenuMain"
  FlowSys.Stat.selectFlag = false
  CommonSys:OpenBasicMenu(-1948318247, 2124762465, nil)
  local wazaMenu = CreateDungeonWazaMenu()
  wazaMenu:Open()
  MENU:SetFocus(wazaMenu)
  FlowSys:WaitCloseMenu(wazaMenu)
  FlowSys.Stat.forcedClose = nil
  CommonSys:CloseBasicMenu()
  if FlowSys.Stat.selectFlag then
    ReturnDungeonMenu()
    CommonSys:EndUpperDarkFilter(true)
  else
    FlowSys:Next(FlowSys.Stat.nextFunc)
    CommonSys:EndUpperDarkFilter(true)
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
  end
end
function OpenWazaSelectMenu(partyMemberId, newWazaIndex, bLevelUp)
  CommonSys:BeginUpperDarkFilter(true)
  CommonSys:OpenBasicMenu(1647862997, bLevelUp and 799921802 or 2124762465, nil)
  local charaTbl, wazaTbl = {}, {}
  local wazaIndex = -1
  local memId = -1
  if partyMemberId ~= nil then
    memId = partyMemberId
  else
    memId = DUNGEON_MENU:GetWazaSelectMemberId()
  end
  if memId < 0 then
    return wazaIndex
  end
  local wazaDetailWindow = MENU:CreateWazaDetailWindow()
  wazaDetailWindow:SetWazaIndex(memId, 0)
  wazaDetailWindow:Open()
  local wazaMenu = MENU:CreatePageMenu(ScreenType.B)
  NestMenu_SetupDefaultAction(wazaMenu, nil)
  wazaMenu:SetLayoutRectAndLines(16, 40, 208, 5)
  wazaMenu:SetCaption(FUNC_COMMON:GetCharaName(memId))
  local wazaCnt = FUNC_COMMON:GetWazaCount(memId)
  for i = 1, wazaCnt do
    local buttonTagTbl = {
      "[M:B03]",
      "[M:B05]",
      "[M:B04]",
      "[M:B06]"
    }
    local text = buttonTagTbl[i] .. FUNC_COMMON:GetWazaName(memId, i - 1)
    MENU:SetTag_String(0, text)
    local pp = FUNC_COMMON:GetWazaPP(memId, i - 1)
    MENU:SetTag_Value(0, pp)
    if pp == 0 then
      text = MENU:ReplaceTagText(-477366732)
    else
      text = MENU:ReplaceTagText(614503898)
    end
    MENU:SetTag_String(1, text)
    MENU:SetTag_Value(1, FUNC_COMMON:GetWazaMaxPP(memId, i - 1))
    text = MENU:ReplaceTagText(-819357571)
    wazaMenu:AddItem(text, i - 1, nil)
  end
  local text = ""
  local pp = 0
  if bLevelUp then
    text = DUNGEON_MENU:GetWazaSelectNewName()
    pp = DUNGEON_MENU:GetNewWazaMaxPP()
  else
    text = FUNC_COMMON:GetWazaNameFromWazaIndex(newWazaIndex)
    pp = FUNC_COMMON:GetWazaMaxPPFromWazaIndex(newWazaIndex)
  end
  text = "[HS:16]" .. text
  local width = MENU:GetTextWidth(text)
  local eLanguageType = SYSTEM:GetLanguageType()
  if eLanguageType == LANGUAGE_TYPE.FR then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_FR")
  elseif eLanguageType == LANGUAGE_TYPE.GE then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_DE")
  elseif eLanguageType == LANGUAGE_TYPE.IT then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_IT")
  elseif eLanguageType == LANGUAGE_TYPE.SP then
    SAJI:CreateSajiPlayer("new_icon", "NEW_M_ES")
  else
    SAJI:CreateSajiPlayer("new_icon", "NEW_M")
  end
  SJ("new_icon"):SetPosition(Vector2(width + 16 + 16 + 8, 128))
  SJ("new_icon"):Play(LOOP.ON)
  SJ("new_icon"):SetScreenType(ScreenType.B)
  MENU:SetTag_String(0, text)
  MENU:SetTag_Value(0, pp)
  text = MENU:ReplaceTagText(614503898)
  MENU:SetTag_String(1, text)
  MENU:SetTag_Value(1, pp)
  text = MENU:ReplaceTagText(-819357571)
  wazaMenu:AddItem(text, wazaCnt, nil)
  function wazaMenu:decideAction()
    if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
      wazaIndex = -1
      self:Close()
    else
      do
        local parentMenu = self
        wazaIndex = self.curItem.obj
        local menu = MENU:CreatePageMenu()
        local forgetTbl, helpTbl = {}, {}
        local ret = false
        NestMenu_SetupDefaultAction(menu, self)
        menu:SetLayoutRectAndLines(240, 40, 64, 0)
        menu:AddItem(-1712656228, true, forgetTbl)
        menu:AddItem(-1392290266, nil, helpTbl)
        function forgetTbl:decideAction()
          if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
            wazaIndex = -1
            self:Close()
          else
            self:Close()
          end
        end
        function helpTbl:decideAction()
          if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
            wazaIndex = -1
            self:Close()
          else
            local index
            if wazaIndex == wazaCnt then
              if bLevelUp then
                index = DUNGEON_MENU:GetNewWazaIndex()
              else
                index = newWazaIndex
              end
            else
              index = FUNC_COMMON:GetWazaIndex(memId, wazaIndex)
            end
            local explainTextId = FUNC_COMMON:GetWazaExplainTextId(index)
            local optTbl
            local explainWindow = CommonSys:OpenBasicExplainMenu(explainTextId, optTbl)
            SJ("new_icon"):SetVisible(false)
            self:SetVisible(false)
            parentMenu:SetVisible(false)
            MENU:SetFocus(explainWindow)
            MENU:WaitClose(explainWindow)
            MENU:SetFocus(self)
            SJ("new_icon"):SetVisible(true)
            self:SetVisible(true)
            parentMenu:SetVisible(true)
          end
        end
        CommonSys:UpdateBasicMenu_PadHelp(2124762465)
        NestMenu_OpenAndCloseWait(menu)
        if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
          wazaIndex = -1
          self:Close()
        elseif menu:IsResult() and menu.curItem.obj ~= nil then
          self:Close()
        elseif bLevelUp then
          CommonSys:UpdateBasicMenu_PadHelp(799921802)
        end
      end
    end
  end
  function wazaMenu:cancelAction()
    if not bLevelUp then
      wazaIndex = -1
      self:Close()
    else
      wazaIndex = 4
      self:Close()
    end
  end
  function wazaMenu:currentItemChange()
    if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
      wazaIndex = -1
      self:Close()
    elseif self.curItem.obj < 4 then
      wazaDetailWindow:SetWazaIndex(memId, self.curItem.obj)
    elseif bLevelUp then
      wazaDetailWindow:SetWazaIndex(DUNGEON_MENU:GetNewWazaIndex())
    else
      wazaDetailWindow:SetWazaIndex(newWazaIndex)
    end
  end
  wazaMenu:Open()
  MENU:SetFocus(wazaMenu)
  MENU:WaitClose(wazaMenu)
  wazaDetailWindow:Close()
  SAJI:DestroySajiPlayer("new_icon")
  CommonSys:CloseBasicMenu()
  CommonSys:EndUpperDarkFilter(true)
  return wazaIndex
end
function OpenForgetAskMenu(isNewSkill)
  local confirm, confirmYes, confirmNo
  if isNewSkill then
    confirm = -881646394
    confirmYes = 1806775358
    confirmNo = 1471178235
  else
    confirm = 559477061
    confirmYes = 1089581166
    confirmNo = 1573359341
  end
  local retValue = WazaSelectMenuAskReturnValue.ANSWER_NO
  local askMenu = MENU:CreateAskMenu()
  askMenu:Setup(true, false, false)
  askMenu:SetLayoutRectAndLines(336, 120, 48, 0)
  askMenu:AddItem(confirmYes, nil, {
    decideAction = function(self)
      retValue = WazaSelectMenuAskReturnValue.ANSWER_YES
      self:CloseAndClearFocus()
    end
  })
  askMenu:AddItem(confirmNo, nil, {
    decideAction = function(self)
      retValue = WazaSelectMenuAskReturnValue.ANSWER_NO
      self:CloseAndClearFocus()
    end
  })
  function askMenu:cancelAction()
    retValue = WazaSelectMenuAskReturnValue.ANSWER_CANCEL
    self:CloseAndClearFocus()
  end
  askMenu:SetDefaultCursorDispIndex(1)
  WINDOW:Log(confirm)
  WINDOW:SelectSetLuaMenu(askMenu)
  WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  WINDOW:CloseMessage()
  return retValue
end
function WazaSelectMenuForWazaCountOver(pokeIndex, newWazaIndex)
  local index = -1
  local ret = WazaSelectMenuAskReturnValue.ANSWER_NO
  local bLevelUp = pokeIndex == nil
  if pokeIndex == nil then
    pokeIndex = DUNGEON_MENU:GetWazaSelectMemberId()
  end
  if newWazaIndex == nil then
    newWazaIndex = DUNGEON_MENU:GetNewWazaIndex()
  end
  local isWazaggu = true
  if SYSTEM:IsDungeonMenu() then
    if not isWazaggu then
      DUNGEON_MENU:PrintDungeonLog(-596662995)
    else
      DUNGEON_MENU:PrintDungeonLog(1402398510)
    end
  elseif not isWazaggu then
    WINDOW:SysMsg(-596662995)
    WINDOW:CloseMessage()
  else
    WINDOW:SysMsg(1402398510)
    WINDOW:CloseMessage()
  end
  if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
    return -1
  end
  local flag = false
  repeat
    index = OpenWazaSelectMenu(pokeIndex, newWazaIndex, bLevelUp)
    if index < 0 then
      ret = WazaSelectMenuAskReturnValue.ANSWER_YES
    else
      local isNewSkill = index == 4
      if SYSTEM:IsDungeonMenu() then
        local wazaIndex = isNewSkill and newWazaIndex or DUNGEON_MENU:GetWazaIndex(pokeIndex, index)
        DUNGEON_MENU:LogSetWazaName(0, wazaIndex, true)
      else
        local wazaName = isNewSkill and FUNC_COMMON:GetWazaNameFromWazaIndex(newWazaIndex) or FUNC_COMMON:GetWazaName(pokeIndex, index)
        MENU:SetTag_String(0, wazaName)
      end
      ret = OpenForgetAskMenu(isNewSkill)
      if SYSTEM:IsMultiPlayMode() and not SYSTEM:IsDungeon() and FUNC_COMMON:GetMultiMemberChangeNotEquip() then
        index = -1
        ret = WazaSelectMenuAskReturnValue.ANSWER_YES
      end
    end
    if pokeIndex ~= nil then
      flag = ret == WazaSelectMenuAskReturnValue.ANSWER_YES
    else
      flag = index >= 0 and ret == WazaSelectMenuAskReturnValue.ANSWER_YES
    end
  until flag
  return index
end
function dungeonMenuRest()
  CommonSys:EndLowerMenuNavi(true)
  if SYSTEM:IsTrialDemo() then
    WINDOW:SysMsg(TRIAL_VER__MENU_DUNGEON_SAVE)
    WINDOW:CloseMessage()
    FlowSys.Stat.nextFunc = "dungeonMenuEnd"
    FlowSys:Next(FlowSys.Stat.nextFunc)
    return
  end
  if Dungeon_Save("dungeon", "return_top", true) then
    SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_REST_REST)
    FlowSys.Stat.nextFunc = "dungeonMenuEnd"
  else
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
    FlowSys.Stat.nextFunc = "dungeonMenuMain"
  end
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuGiveUp()
  CommonSys:EndLowerMenuNavi(true)
  if Dungeon_Giveup() then
    SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_REST_GIVEUP)
    if SYSTEM:IsDungeonMenu() then
      FlowSys.Stat.nextFunc = "dungeonMenuEnd"
    else
      FlowSys.Stat.nextFunc = "groundMenuExit"
    end
  else
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
    FlowSys.Stat.nextFunc = "dungeonMenuMain"
  end
  FlowSys:Next(FlowSys.Stat.nextFunc)
end
function dungeonMenuItemExchange()
  FlowSys.Stat.selectFlag = true
  local selectItem = FlowSys.Stat.itemBagTbl.selectItem
  local pokemonId = FlowSys.Stat.itemBagTbl.pokemonId
  local useItem = FlowSys.Stat.itemBagTbl.useItem
  local itemIns = FlowSys.Stat.itemBagTbl.itemIns
  local targetItem = FlowSys.Stat.itemBagTbl.targetItem
  if selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP_EXCHANGE then
    useItem = dungeonMenuItemSelect(false, true)
    if useItem < 0 then
      FlowSys.Stat.selectFlag = false
    else
      FlowSys.Stat.selectFlag = true
    end
  elseif useItem ~= DungeonMenuSelectItems.SELECT_MENU_NON then
    targetItem = useItem
    useItem = DungeonMenuSelectItems.SELECT_MENU_NON
  else
    targetItem = dungeonMenuItemSelect(false, true)
    if targetItem < 0 then
      FlowSys.Stat.selectFlag = false
    else
      FlowSys.Stat.selectFlag = true
    end
  end
  if SYSTEM:IsDungeonMenu() then
    if FlowSys.Stat.selectFlag then
      DUNGEON_MENU:SetSelectMenuParam(selectItem, pokemonId, useItem, targetItem, DungeonMenuSelectItems.SELECT_MENU_NON)
    else
      SetDungeonMenuNoParam()
    end
  end
  if FlowSys.Stat.selectFlag then
    ReturnDungeonMenu()
  else
    FlowSys:Next(FlowSys.Stat.returnFunc)
  end
end
function dungeonMenuItemHelp()
  local textId = FUNC_COMMON:GetItemExplainTextId(FlowSys.Stat.itemBagTbl.itemIns:GetIndex())
  local explainWindow = CommonSys:OpenBasicExplainMenu(textId, nil)
  MENU:SetFocus(explainWindow)
  WaitAndForcedClose(explainWindow, true)
  FlowSys:Next(FlowSys.Stat.returnFunc)
end
function dungeonMenuItemPokemon()
  FlowSys.Stat.selectFlag = false
  CommonSys:OpenBasicMenu("", "")
  local selectItem = FlowSys.Stat.itemBagTbl.selectItem
  local pokemonId = FlowSys.Stat.itemBagTbl.pokemonId
  local useItem = FlowSys.Stat.itemBagTbl.useItem
  local itemIns = FlowSys.Stat.itemBagTbl.itemIns
  local targetItem = FlowSys.Stat.itemBagTbl.targetItem
  local upScreenStatusWindow
  if selectItem ~= DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP then
    CommonSys:DisableLowerMenuNaviAll()
    upScreenStatusWindow = MENU:CreateWazaStatusWindow(ScreenType.A)
    upScreenStatusWindow:SetLayoutRect(64, 48, 272, 172)
    upScreenStatusWindow:SetFacePos(68, 52)
    upScreenStatusWindow:SetNameWindowRect(64, 112, 64, 16)
    upScreenStatusWindow:SetType1Pos(80, 0)
    upScreenStatusWindow:SetType2Pos(184, 0)
    upScreenStatusWindow:SetLvPos(80, 20)
    upScreenStatusWindow:SetHpPos(80, 36)
    upScreenStatusWindow:SetAttackPos(80, 58)
    upScreenStatusWindow:SetDefendPos(176, 58)
    upScreenStatusWindow:SetAttackExPos(80, 74)
    upScreenStatusWindow:SetDefendExPos(176, 74)
    upScreenStatusWindow:SetAbilityPos(80, 90)
    upScreenStatusWindow:SetWaza1Pos(80, 110)
    upScreenStatusWindow:SetWaza2Pos(80, 126)
    upScreenStatusWindow:SetWaza3Pos(80, 142)
    upScreenStatusWindow:SetWaza4Pos(80, 158)
    upScreenStatusWindow:Open()
    upScreenStatusWindow:SetMemberId(0)
    upScreenStatusWindow:SetParallaxFromLevel(PARALLAX_LEVEL.FAR_1)
  end
  local charaMenu = CreatePokeItemWindow(itemIns, selectItem ~= DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP)
  function charaMenu:cancelAction()
    self:Close()
    FlowSys.Stat.itemBagTbl = nil
    FlowSys.Stat.selectFlag = false
    if upScreenStatusWindow ~= nil then
      upScreenStatusWindow:Close()
      CommonSys:EnableLowerMenuNaviAll()
    end
  end
  function charaMenu:decideAction()
    pokemonId = self.curItem.obj
    self:Close()
    FlowSys.Stat.selectFlag = true
    if upScreenStatusWindow ~= nil then
      upScreenStatusWindow:Close()
      if not itemIns:IsWazaMachine() or FUNC_COMMON:GetWazaCount(pokemonId) < 4 then
        CommonSys:EnableLowerMenuNaviAll()
      end
    end
  end
  function charaMenu:currentItemChange()
    if self.equipMenu ~= nil then
      self.equipMenu:SetCurrentPageGroup(self.curItem.obj)
    end
    self.partyWindow:SetMemberId(self.curItem.obj)
    SetStatusAndCameraTarget(self.curItem.obj)
    if upScreenStatusWindow ~= nil then
      upScreenStatusWindow:SetMemberId(self.curItem.obj)
    end
  end
  charaMenu:Open()
  MENU:SetFocus(charaMenu)
  local menuTbl = {
    charaMenu,
    charaMenu.partyWindow
  }
  if charaMenu.equipMenu ~= nil then
    table.insert(menuTbl, charaMenu.equipMenu)
  end
  if upScreenStatusWindow ~= nil then
    table.insert(menuTbl, upScreenStatusWindow)
  end
  local num = 0
  if FlowSys.Stat.forcedClose == nil then
    FlowSys.Stat.forcedClose = {}
  else
    num = table.maxn(FlowSys.Stat.forcedClose)
  end
  FlowSys.Stat.forcedClose[num + 1] = function()
    for i, k in ipairs(menuTbl) do
      k:NotifyForceClose()
    end
    CommonSys:CloseBasicMenu()
    if FlowSys.Proc.dungeonMenuEnd ~= nil then
      FlowSys.Stat.returnFunc = "dungeonMenuEnd"
    end
  end
  FlowSys:WaitCloseMenu(charaMenu)
  FlowSys.Stat.forcedClose[num + 1] = nil
  if FlowSys.Stat.selectFlag then
    if SYSTEM:IsDungeonMenu() then
      DUNGEON_MENU:SetSelectMenuParam(selectItem, pokemonId, useItem, targetItem, DungeonMenuSelectItems.SELECT_MENU_NON)
    end
    if (selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EAT or selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_DRINK or selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_EAT or selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_DRINK) and not DUNGEON_MENU:CanEatItemFood(pokemonId, useItem) then
      if FlowSys.Stat.returnFunc == "dungeonStairsMenu" then
        SIMPLE_STATUS:WindowClose()
      else
        CommonSys:EndLowerMenuNavi(true)
      end
      DUNGEON_MENU:PrintDungeonLog(1749252215)
      FlowSys.Stat.selectFlag = false
      if FlowSys.Stat.returnFunc == "dungeonStairsMenu" then
        SIMPLE_STATUS:WindowOpen()
      else
        CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
      end
      SetDungeonMenuNoParam()
    end
    if (selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_OTHER_USE or selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_OTHER_USE) and itemIns:IsWazaMachine() then
      if SYSTEM:IsDungeonMenu() then
        DUNGEON_MENU:PlayWazamachineEffect(pokemonId)
      end
      if FUNC_COMMON:GetWazaCount(pokemonId) >= 4 then
        if FlowSys.Stat.returnFunc == "dungeonStairsMenu" then
          SIMPLE_STATUS:WindowClose()
        else
          CommonSys:EndLowerMenuNavi(true)
        end
        local wazaIndex = FUNC_COMMON:GetWazaIndexFromWazamachine(itemIns:GetIndex())
        local index = WazaSelectMenuForWazaCountOver(pokemonId, wazaIndex)
        if SYSTEM:IsDungeonMenu() then
          MENU:SetTag_MonsterString(1, DUNGEON_MENU:GetCharaName(pokemonId))
        else
          MENU:SetTag_MonsterString(1, FUNC_COMMON:GetCharaName(pokemonId))
        end
        if index < 0 then
          FlowSys.Stat.itemBagTbl = nil
          FlowSys.Stat.selectFlag = false
          SetDungeonMenuNoParam()
        elseif SYSTEM:IsDungeonMenu() then
          MENU:SetTag_String(0, FUNC_COMMON:GetWazaName(pokemonId, index))
          MENU:SetTag_String(1, FUNC_COMMON:GetWazaNameFromWazaIndex(wazaIndex))
          DUNGEON_MENU:SetSelectMenuParam(selectItem, pokemonId, useItem, targetItem, index)
        end
        if FlowSys.Stat.returnFunc == "dungeonStairsMenu" then
          SIMPLE_STATUS:WindowOpen()
        else
          CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true, true)
        end
      end
    end
  end
  SetStatusAndCameraTarget(charaMenu.playerIndex)
  CommonSys:CloseBasicMenu()
  if FlowSys.Stat.selectFlag then
    ReturnDungeonMenu()
  else
    FlowSys:Next(FlowSys.Stat.returnFunc)
  end
end
function dungeonMenuItemSetupParam()
  SYSTEM:DebugPrint("dungeonMenuItemSetupParam")
  if SYSTEM:IsDungeonMenu() then
    DUNGEON_MENU:SetSelectMenuParam(FlowSys.Stat.itemBagTbl.selectItem, FlowSys.Stat.itemBagTbl.pokemonId, FlowSys.Stat.itemBagTbl.useItem, FlowSys.Stat.itemBagTbl.targetItem, DungeonMenuSelectItems.SELECT_MENU_NON)
  end
  ReturnDungeonMenu()
end
function dungeonMenuChangeLeader()
  CommonSys:EndLowerMenuNavi(true)
  local param = DUNGEON_MENU:CanChangeLeaderNextPokemon()
  local bChange = false
  if param ~= ChangeLeaderParameter.CHANGE_OK then
    if param == ChangeLeaderParameter.CHANGE_NG_SHOPPING then
      DUNGEON_MENU:PrintDungeonLog(-1120366300)
    elseif param == ChangeLeaderParameter.CHANGE_NG_DOROBOU then
      DUNGEON_MENU:PrintDungeonLog(-338448649)
    elseif param == ChangeLeaderParameter.CHANGE_NG_STATUS then
      DUNGEON_MENU:PrintDungeonLog(-1907980739)
    elseif param == ChangeLeaderParameter.CHANGE_NG_OTHER then
      DUNGEON_MENU:PrintDungeonLog(-338448649)
    end
  else
    local playerIndex = DUNGEON_MENU:ChangeLeaderNextPokemon()
    if playerIndex >= 0 then
      SetStatusAndCameraTarget(playerIndex)
      MENU:SetTag_MonsterString(1, DUNGEON_MENU:GetCharaName(playerIndex))
      DUNGEON_MENU:PrintDungeonLog(2003717200)
      bChange = true
    else
      DUNGEON_MENU:PrintDungeonLog(-338448649)
    end
  end
  if bChange then
    SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_LEADER_CHANGE)
    FlowSys:Return()
  else
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
    FlowSys:Next("dungeonMenuMain")
  end
end
gDungeonMenuParameter = {}
local _CreateInfomation = function()
  local x_step = 108
  local y_step = 64
  local x_base = 8
  local y_base = 8
  gDungeonMenuParameter.aPlacedTbl = {
    [0] = {
      pos = {
        x = x_base + x_step * 0,
        y = y_base + y_step * 0
      },
      link = {
        l = 2,
        r = 1,
        u = 6,
        d = 3
      }
    },
    [1] = {
      pos = {
        x = x_base + x_step * 1,
        y = y_base + y_step * 0
      },
      link = {
        l = 0,
        r = 2,
        u = 7,
        d = 4
      }
    },
    [2] = {
      pos = {
        x = x_base + x_step * 2,
        y = y_base + y_step * 0
      },
      link = {
        l = 1,
        r = 0,
        u = 8,
        d = 5
      }
    },
    [3] = {
      pos = {
        x = x_base + x_step * 0,
        y = y_base + y_step * 1
      },
      link = {
        l = 5,
        r = 4,
        u = 0,
        d = 6
      }
    },
    [4] = {
      pos = {
        x = x_base + x_step * 1,
        y = y_base + y_step * 1
      },
      link = {
        l = 3,
        r = 5,
        u = 1,
        d = 7
      }
    },
    [5] = {
      pos = {
        x = x_base + x_step * 2,
        y = y_base + y_step * 1
      },
      link = {
        l = 4,
        r = 3,
        u = 2,
        d = 8
      }
    },
    [6] = {
      pos = {
        x = x_base + x_step * 0,
        y = y_base + y_step * 2
      },
      link = {
        l = 8,
        r = 7,
        u = 3,
        d = 0
      }
    },
    [7] = {
      pos = {
        x = x_base + x_step * 1,
        y = y_base + y_step * 2
      },
      link = {
        l = 6,
        r = 8,
        u = 4,
        d = 1
      }
    },
    [8] = {
      pos = {
        x = x_base + x_step * 2,
        y = y_base + y_step * 2
      },
      link = {
        l = 7,
        r = 6,
        u = 5,
        d = 2
      }
    }
  }
  gDungeonMenuParameter.iconX = 0
  gDungeonMenuParameter.iconY = 0
  gDungeonMenuParameter.iconCount = 0
  gDungeonMenuParameter.iconLinkL = 0
  gDungeonMenuParameter.iconLinkR = 0
  gDungeonMenuParameter.iconLinkU = 0
  gDungeonMenuParameter.iconLinkD = 0
  function gDungeonMenuParameter:iconStepFunc(_buttonMenu)
    _buttonMenu:SetItemLink4(self.iconCount, self.iconLinkL, self.iconLinkR, self.iconLinkU, self.iconLinkD)
    self.iconCount = self.iconCount + 1
    if self.iconCount > 8 then
      self.iconCount = 0
    end
    self.iconX = self.aPlacedTbl[self.iconCount].pos.x
    self.iconY = self.aPlacedTbl[self.iconCount].pos.y
    self.iconLinkL = self.aPlacedTbl[self.iconCount].link.l
    self.iconLinkR = self.aPlacedTbl[self.iconCount].link.r
    self.iconLinkU = self.aPlacedTbl[self.iconCount].link.u
    self.iconLinkD = self.aPlacedTbl[self.iconCount].link.d
  end
  function gDungeonMenuParameter:iconResetFunc()
    self.iconCount = 0
    self.iconX = self.aPlacedTbl[self.iconCount].pos.x
    self.iconY = self.aPlacedTbl[self.iconCount].pos.y
    self.iconLinkL = self.aPlacedTbl[self.iconCount].link.l
    self.iconLinkR = self.aPlacedTbl[self.iconCount].link.r
    self.iconLinkU = self.aPlacedTbl[self.iconCount].link.u
    self.iconLinkD = self.aPlacedTbl[self.iconCount].link.d
  end
  gDungeonMenuParameter.mode = "top"
end
local _DeleteInfomation = function()
end
function ReturnDungeonMenu()
  CommonSys:EndLowerMenuNavi()
  FlowSys:Return()
end
function ForcedTarminateDungeonMenu()
  for i = 1, table.maxn(FlowSys.Stat.forcedClose) do
    FlowSys.Stat.forcedClose[i]()
  end
end
function dungeonMenuTarminate()
  for i = 1, table.maxn(FlowSys.Stat.forcedClose) do
    FlowSys.Stat.forcedClose[i]()
  end
end
function dungeonMenuEnd()
  ReturnDungeonMenu()
end
function OpenDungeonMenu()
  MENU:LoadMenuTextPool("message/top.bin", false)
  FlowSys:Start()
  FlowSys.Proc.dungeonMenuTsuyosa = dungeonMenuTsuyosa
  FlowSys.Proc.dungeonMenuTokutyo = dungeonMenuTokutyo
  FlowSys.Proc.dungeonMenuWazaSelect = dungeonMenuWazaSelect
  FlowSys.Proc.dungeonMenuCondition = dungeonMenuCondition
  FlowSys.Proc.dungeonMenuConditionLastPage = dungeonMenuConditionLastPage
  FlowSys.Proc.dungeonMenuTeamSkill = dungeonMenuTeamSkill
  FlowSys.Proc.dungeonMenuOperation = dungeonMenuOperation
  FlowSys.Proc.dungeonMenuParty = dungeonMenuParty
  FlowSys.Proc.dungeonMenuOption = dungeonMenuOption
  FlowSys.Proc.dungeonMenuQuest = dungeonMenuQuest
  FlowSys.Proc.dungeonMenuARQuest = dungeonMenuARQuest
  FlowSys.Proc.dungeonMenuSearch = dungeonMenuSearch
  FlowSys.Proc.dungeonMenuVWave = dungeonMenuVWave
  FlowSys.Proc.dungeonMenuMessage = dungeonMenuMessage
  FlowSys.Proc.dungeonMenuWorldMap = dungeonMenuWorldMap
  FlowSys.Proc.dungeonMenuDungeonState = dungeonMenuDungeonState
  FlowSys.Proc.dungeonMenuDungeonHint = dungeonMenuDungeonHint
  FlowSys.Proc.dungeonMenuGameHint = dungeonMenuGameHint
  FlowSys.Proc.dungeonMenuWaza = dungeonMenuWaza
  FlowSys.Proc.dungeonMenuRest = dungeonMenuRest
  FlowSys.Proc.dungeonMenuGiveUp = dungeonMenuGiveUp
  FlowSys.Proc.dungeonMenuItemExchange = dungeonMenuItemExchange
  FlowSys.Proc.dungeonMenuItemHelp = dungeonMenuItemHelp
  FlowSys.Proc.dungeonMenuItemPokemon = dungeonMenuItemPokemon
  FlowSys.Proc.dungeonMenuItemSetupParam = dungeonMenuItemSetupParam
  FlowSys.Proc.dungeonMenuOthers = dungeonMenuOthers
  FlowSys.Proc.dungeonMenuExplainWindow = dungeonMenuExplainWindow
  FlowSys.Proc.dungeonMenuTarminate = dungeonMenuTarminate
  FlowSys.Proc.bossAccess = bossAccess
  FlowSys.Proc.dungeonMenuChangeLeader = dungeonMenuChangeLeader
  FlowSys.Proc.dungeonMenuEnd = dungeonMenuEnd
  DUNGEON_MENU:CloseDungeonLog()
  CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
  function FlowSys.Proc.dungeonMenuMain()
    FlowSys.Stat.selectFlag = false
    FlowSys.Stat.nextFunc = nil
    local buttonMenu = MENU:CreateButtonMenu()
    local itemIndex = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_MAIN)
    local partyCnt = FUNC_COMMON:GetPartyMemberCount()
    local bObie = false
    for i = 1, partyCnt do
      if FUNC_COMMON:IsPlayer(i - 1) then
        bObie = DUNGEON_MENU:HasBadStatus(i - 1, StatusIndex.INDEX_OBIE)
        break
      end
    end
    local stGrayedFoot = "OFF"
    local stGrayedAround = "OFF"
    local stGrayedLeader = "OFF"
    if SYSTEM:IsEncountGroundMode() then
      stGrayedFoot = "ON"
      stGrayedAround = "ON"
    elseif DUNGEON_MENU:IsEncountCamera() then
      stGrayedAround = "ON"
      stGrayedFoot = bObie and "ON" or "OFF"
    else
      stGrayedFoot = bObie and "ON" or "OFF"
    end
    if not DUNGEON_MENU:CanSelectChangeLeader() or FUNC_COMMON:GetPartyMemberCount() <= 1 or SYSTEM:IsMultiPlayMode() then
      stGrayedLeader = "ON"
    end
    local restTbl = {}
    local giveupTbl = {}
    _CreateInfomation()
    gDungeonMenuParameter:iconResetFunc()
    buttonMenu:AddFixedPatternItem(78100339, 0, 26, ButtonFixedPattern.ITEM, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = 78100339,
      explanationText = 486927398,
      nextFunc = "dungeonMenuItem",
      grayed = bObie and "ON" or "OFF"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:AddFixedPatternItem(-1483390204, 0, 26, ButtonFixedPattern.PARTY, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = -1483390204,
      explanationText = -1663009845,
      nextFunc = "dungeonMenuParty",
      grayed = bObie and "ON" or "OFF"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    if SYSTEM:IsSimpleDungeonMode() then
      buttonMenu:AddFixedPatternItem(1189499329, 0, 20, ButtonFixedPattern.REQUEST, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = -2046008516,
        explanationText = 1138119736,
        nextFunc = "dungeonMenuARQuest",
        new = stMenuQuestNew
      }, nil)
    elseif FUNC_COMMON:CheckScenarioLevelOpenFlag("menu_irai_open") then
      local stMenuQuestNew = "OFF"
      if FUNC_COMMON:IsUsedMenuLog(UsedMenuKind.USED_MENU_KIND_QUEST_MEMO) == false then
        stMenuQuestNew = "ON"
      end
      buttonMenu:AddFixedPatternItem(-2046008516, 0, 26, ButtonFixedPattern.REQUEST, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = -2046008516,
        explanationText = -1116120077,
        nextFunc = "dungeonMenuQuest",
        new = stMenuQuestNew
      }, nil)
    else
      buttonMenu:AddFixedPatternItem(-1364134628, 0, 26, ButtonFixedPattern.DISABLE, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = -2046008516,
        explanationText = 1379131362,
        grayed = "ON"
      }, nil)
    end
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:AddFixedPatternItem(-1706946681, 0, 26, ButtonFixedPattern.WAZA, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = -1706946681,
      explanationText = -2082450222,
      nextFunc = "dungeonMenuWaza",
      grayed = bObie and "ON" or "OFF"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    if FUNC_COMMON:CheckScenarioLevelOpenFlag("all_scenario_clear") then
      buttonMenu:AddFixedPatternItem(-1455848479, 0, 20, ButtonFixedPattern.PARADISE, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = -1455848479,
        explanationText = -849753205,
        nextFunc = "dungeonMenuChangeLeader",
        grayed = stGrayedLeader
      }, nil)
    else
      buttonMenu:AddFixedPatternItem(-1364134628, 0, 26, ButtonFixedPattern.DISABLE, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = -1455848479,
        explanationText = 1379131362,
        grayed = "ON"
      }, nil)
    end
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:AddFixedPatternItem(-573351343, 0, 26, ButtonFixedPattern.LOOK_AROUND, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = -573351343,
      explanationText = -783374406,
      grayed = stGrayedAround,
      nextFunc = "dungeonMenuLookAround"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:AddFixedPatternItem(1076567803, 0, 26, ButtonFixedPattern.FOOT, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = 1076567803,
      explanationText = 1502168494,
      grayed = stGrayedFoot,
      nextFunc = "dungeonMenuFoot"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    if SYSTEM:IsParadiseMode() or SYSTEM:IsSimpleDungeonMode() then
      buttonMenu:AddFixedPatternItem(496638443, 0, 26, ButtonFixedPattern.REST, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = 496638443,
        explanationText = 2046448001,
        nextFunc = "dungeonMenuGiveUp"
      }, nil)
    else
      buttonMenu:AddFixedPatternItem(59697771, 0, 26, ButtonFixedPattern.REST, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
        id = 59697771,
        explanationText = 439136574,
        nextFunc = "dungeonMenuRest"
      }, nil)
    end
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:AddFixedPatternItem(166867985, 0, 26, ButtonFixedPattern.ETC, gDungeonMenuParameter.iconX, gDungeonMenuParameter.iconY, {
      id = 166867985,
      explanationText = 87178598,
      nextFunc = "dungeonMenuOthers"
    }, nil)
    gDungeonMenuParameter:iconStepFunc(buttonMenu)
    buttonMenu:SetOption({
      inputMode = "LINK",
      selectMode = "SCALE",
      iconCursor = "DUNGEON"
    })
    function buttonMenu:cancelAction()
      DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_MAIN, buttonMenu:GetCursorItemIndex())
      SetDungeonMenuNoParam()
      self:Close()
    end
    function buttonMenu:currentItemChange()
      if self.curItem.obj.explanationText ~= nil then
        CommonSys:UpdateBasicMenu_LineHelp(self.curItem.obj.explanationText)
      end
    end
    local function SetMenuVisible(visible)
      buttonMenu:SetVisible(visible)
      CommonSys:SetVisibleBasicMenu(visible)
    end
    function buttonMenu:decideAction()
      if self.curItem.obj.nextFunc ~= nil then
        FlowSys.Stat.selectFlag = true
        FlowSys.Stat.id = self.curItem.obj.id
        FlowSys.Stat.nextFunc = self.curItem.obj.nextFunc
        DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_MAIN, buttonMenu:GetCursorItemIndex())
        self:Close()
      end
    end
    function buttonMenu:searchAction()
      if bObie then
        SOUND:PlaySe(SymSnd("SE_SYS_NO_SELECT"))
      else
        FlowSys.Stat.selectFlag = true
        FlowSys.Stat.id = -1706946681
        FlowSys.Stat.nextFunc = "dungeonMenuWaza"
        DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_MAIN, buttonMenu:GetCursorItemIndex())
        SOUND:PlaySe(SymSnd("SE_SYS_DECIDE"))
        self:Close()
      end
    end
    FlowSys:SetupMenuEventAction(buttonMenu)
    buttonMenu:Open()
    if buttonMenu:IsDummy(itemIndex) then
      itemIndex = 0
    end
    buttonMenu:SetCursorItemIndex(itemIndex)
    buttonMenu:SetCurrentModifyItem(itemIndex)
    local text = buttonMenu.curItem.obj.explanationText
    if buttonMenu.curItem.obj == nil then
      text = nil
    end
    CommonSys:OpenBasicMenu(nil, 1366269513, text)
    MENU:SetFocus(buttonMenu)
    WaitAndForcedClose(buttonMenu)
    _DeleteInfomation()
    CommonSys:CloseBasicMenu()
    if FlowSys.Stat.nextFunc ~= nil then
      FlowSys:Next(FlowSys.Stat.nextFunc)
    else
      FlowSys:Next("dungeonMenuEnd")
    end
  end
  function FlowSys.Proc.dungeonMenuItem()
    local PrintLogNoItem = function()
      CommonSys:EndLowerMenuNavi(true)
      local num = 0
      local bForce = false
      if FlowSys.Stat.forcedClose == nil then
        FlowSys.Stat.forcedClose = {}
      else
        num = table.maxn(FlowSys.Stat.forcedClose)
      end
      FlowSys.Stat.forcedClose[num + 1] = function()
        DUNGEON_MENU:CloseDungeonLog()
        FlowSys.Stat.nextFunc = "dungeonMenuEnd"
        bForce = true
      end
      DUNGEON_MENU:PrintDungeonLog(1236059106)
      if bForce == false then
        CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
      end
    end
    FlowSys.Stat.nextFunc = "dungeonMenuMain"
    if FUNC_COMMON:GetBagItemCount() == 0 and not FUNC_COMMON:IsFootItemExist() then
      PrintLogNoItem()
      FlowSys:Next(FlowSys.Stat.nextFunc)
      return
    end
    FlowSys.Stat.selectFlag = false
    CommonSys:OpenBasicMenu("", "", "")
    local itemBagMenu = CreateDungeonItemBagMenu()
    itemBagMenu:SetOption({sortButtonEnable = true})
    FlowSys:SetupMenuEventAction(itemBagMenu)
    local index = DUNGEON_MENU:GetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_ITEM_ITEM)
    itemBagMenu:Open()
    itemBagMenu:SetCursorItemIndex(index)
    itemBagMenu:currentItemChange()
    itemBagMenu:currentPageGroupChange()
    MENU:SetFocus(itemBagMenu)
    local bForce = false
    local num = 0
    if FlowSys.Stat.forcedClose == nil then
      FlowSys.Stat.forcedClose = {}
    else
      num = table.maxn(FlowSys.Stat.forcedClose)
    end
    FlowSys.Stat.forcedClose[num + 1] = function()
      itemBagMenu:NotifyForceClose()
      FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      bForce = true
    end
    FlowSys:WaitCloseMenu(itemBagMenu)
    FlowSys.Stat.forcedClose[num + 1] = nil
    CommonSys:CloseBasicMenu()
    DUNGEON_MENU:SetResumeCursorIndex(DungeonMenuMenuCursor.MENU_CURSOR_ITEM_ITEM, itemBagMenu:GetCursorItemIndex())
    if FlowSys.Stat.itemBagTbl == nil then
      if bForce == false then
        if FUNC_COMMON:GetBagItemCount() == 0 and not FUNC_COMMON:IsFootItemExist() then
          PrintLogNoItem()
        end
        FlowSys.Stat.nextFunc = "dungeonMenuMain"
      end
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_EXCHANGE then
      FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
      FlowSys.Stat.returnFunc = "dungeonMenuItem"
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP_EXCHANGE then
      FlowSys.Stat.itemBagTbl.targetItem = FlowSys.Stat.itemBagTbl.useItem
      FlowSys.Stat.itemBagTbl.useItem = DungeonMenuSelectItems.SELECT_MENU_NON
      FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
      FlowSys.Stat.returnFunc = "dungeonMenuItem"
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_NON then
      FlowSys.Stat.nextFunc = "dungeonMenuItemHelp"
      FlowSys.Stat.returnFunc = "dungeonMenuItem"
    elseif FlowSys.Stat.itemBagTbl.bSelectPoke then
      FlowSys.Stat.nextFunc = "dungeonMenuItemPokemon"
      FlowSys.Stat.returnFunc = "dungeonMenuItem"
    else
      FlowSys.Stat.nextFunc = "dungeonMenuItemSetupParam"
    end
    FlowSys:Next(FlowSys.Stat.nextFunc)
  end
  function FlowSys.Proc.dungeonMenuFoot()
    FlowSys.Stat.nextFunc = "dungeonMenuMain"
    if not DUNGEON_MENU:IsFootItemExist() and not DUNGEON_MENU:IsFootTrapExist() and not DUNGEON_MENU:IsFootStairsExist() and not DUNGEON_MENU:IsFootQuestTargetExist() then
      do
        local num = 0
        local bForce = false
        if FlowSys.Stat.forcedClose == nil then
          FlowSys.Stat.forcedClose = {}
        else
          num = table.maxn(FlowSys.Stat.forcedClose)
        end
        FlowSys.Stat.forcedClose[num + 1] = function()
          DUNGEON_MENU:CloseDungeonLog()
          FlowSys.Stat.nextFunc = "dungeonMenuEnd"
          bForce = true
        end
        CommonSys:EndLowerMenuNavi(true)
        MENU:SetTag_MonsterString(0, DUNGEON_MENU:GetMyName())
        DUNGEON_MENU:PrintDungeonLog(-1434657039)
        FlowSys:Next(FlowSys.Stat.nextFunc)
        if bForce == false then
          CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
        end
        return
      end
    end
    FlowSys.Stat.selectFlag = false
    local itemBagMenu = CreateFootItemMenu()
    FlowSys:SetupMenuEventAction(itemBagMenu)
    local bForce = false
    local num = 0
    if FlowSys.Stat.forcedClose == nil then
      FlowSys.Stat.forcedClose = {}
    else
      num = table.maxn(FlowSys.Stat.forcedClose)
    end
    FlowSys.Stat.forcedClose[num + 1] = function()
      itemBagMenu:NotifyForceClose()
      FlowSys.Stat.nextFunc = "dungeonMenuEnd"
      bForce = true
    end
    CommonSys:OpenBasicMenu("", "", "")
    itemBagMenu:Open()
    FlowSys.Stat.forcedClose[num + 1] = nil
    CommonSys:CloseBasicMenu()
    if FlowSys.Stat.itemBagTbl == nil then
      if bForce == false then
        FlowSys.Stat.nextFunc = "dungeonMenuMain"
      end
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_FOOT_EXCHANGE then
      FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
      FlowSys.Stat.returnFunc = "dungeonMenuFoot"
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_ITEM_EQUIP_EXCHANGE then
      FlowSys.Stat.itemBagTbl.targetItem = FlowSys.Stat.itemBagTbl.useItem
      FlowSys.Stat.itemBagTbl.useItem = DungeonMenuSelectItems.SELECT_MENU_NON
      FlowSys.Stat.nextFunc = "dungeonMenuItemExchange"
      FlowSys.Stat.returnFunc = "dungeonMenuFoot"
    elseif FlowSys.Stat.itemBagTbl.selectItem == DungeonMenuSelectItems.SELECT_MENU_NON then
      FlowSys.Stat.nextFunc = "dungeonMenuItemHelp"
      FlowSys.Stat.returnFunc = "dungeonMenuFoot"
    elseif FlowSys.Stat.itemBagTbl.bSelectPoke then
      FlowSys.Stat.nextFunc = "dungeonMenuItemPokemon"
      FlowSys.Stat.returnFunc = "dungeonMenuFoot"
    else
      FlowSys.Stat.nextFunc = "dungeonMenuItemSetupParam"
    end
    FlowSys:Next(FlowSys.Stat.nextFunc)
  end
  function FlowSys.Proc.dungeonMenuParadise()
    CommonSys:EndLowerMenuNavi(true)
    FlowSys.Stat.selectFlag = false
    if DungeonToParadiseMenu() then
      FlowSys.Stat.selectFlag = true
    end
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
    if FlowSys.Stat.selectFlag then
      SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_PARADISE)
      FlowSys:Next("dungeonMenuEnd")
    else
      FlowSys:Next("dungeonMenuMain")
    end
  end
  function FlowSys.Proc.dungeonMenuNormalMode()
    CommonSys:EndLowerMenuNavi(true)
    FlowSys.Stat.selectFlag = false
    if DungeonToParadiseMenu() then
      FlowSys.Stat.selectFlag = true
    end
    CommonSys:BeginLowerMenuNavi(DUNGEON_MENU:GetDungeonName(), true)
    if FlowSys.Stat.selectFlag then
      SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_PARADISE)
      FlowSys:Next("dungeonMenuEnd")
    else
      FlowSys:Next("dungeonMenuMain")
    end
  end
  function FlowSys.Proc.dungeonMenuLookAround()
    SetDungeonMenuSelectItem(DungeonMenuSelectItems.SELECT_MENU_LOOK_AROUND)
    FlowSys:Next("dungeonMenuEnd")
  end
  function FlowSys.Proc.dungeonMenuDebug()
    SetDungeonMenuNoParam()
    if OpenDungeonDebugMenu() then
      FlowSys:Next("dungeonMenuEnd")
    else
      FlowSys:Next("dungeonMenuMain")
    end
  end
  FlowSys:Call("dungeonMenuMain")
  FlowSys:Finish()
end
function CallFlow_PokemonWarehouseStatusMenu(warehouseId)
  MENU:LoadMenuTextPool("message/menu_dungeon.bin")
  local suspendTable = FlowSys:Suspend()
  FlowSys:Start()
  FlowSys.Stat.pokeSelect = warehouseId
  FlowSys.Stat.useWarehouseId = true
  function FlowSys.Proc:startStatusMenu()
    FlowSys:Next("dungeonMenuTsuyosa")
  end
  function FlowSys.Proc:dungeonMenuParty()
    FlowSys:Return()
  end
  FlowSys.Proc.dungeonMenuTsuyosa = dungeonMenuTsuyosa
  FlowSys.Proc.dungeonMenuTokutyo = dungeonMenuTokutyo
  FlowSys.Proc.dungeonMenuWazaSelect = dungeonMenuWazaSelect
  FlowSys.Proc.dungeonMenuExplainWindow = dungeonMenuExplainWindow
  FlowSys:Call("startStatusMenu")
  FlowSys:Finish()
  FlowSys:Resume(suspendTable)
end
function CreateDungeonItemBagMenu()
  FlowSys.Stat.itemBagTbl = nil
  local itemBagMenu = MENU:CreateItemBagMenu()
  itemBagMenu:SetOption({sortButtonEnable = true})
  itemBagMenu.bagCountWindow = MENU:CreateBoardMenuWindow(ScreenType.B)
  itemBagMenu.bagCountWindow:SetFontType(FontType.TYPE_12)
  itemBagMenu.bagCountWindow:SetTextOffset(0, 0)
  itemBagMenu.bagCountWindow:SetLayoutRect(Rectangle(240, 168, 64, 16))
  local nowCount = FUNC_COMMON:GetBagItemCount()
  local maxCount = FUNC_COMMON:GetBagItemMaxCount()
  if nowCount >= maxCount then
    MENU:SetTag_Value(0, maxCount)
    MENU:SetTag_Value(1, maxCount)
    itemBagMenu.bagCountWindow:SetText(-534034656)
  else
    MENU:SetTag_Value(0, nowCount)
    MENU:SetTag_Value(1, maxCount)
    itemBagMenu.bagCountWindow:SetText(-1807035551)
  end
  local function updateLineHelp(itemIns)
    if itemBagMenu.luaExt_GenItemLineHelpTextFunc then
      CommonSys:SetVisibleBasicMenu_LineHelp(true)
      CommonSys:UpdateBasicMenu_LineHelp(itemBagMenu.luaExt_GenItemLineHelpTextFunc(itemIns))
    else
      CommonSys:SetVisibleBasicMenu_LineHelp(false)
    end
  end
  local function createList(self)
    local id = 0
    self:ClearItems()
    if self.luaExt_itemEnumFunc then
      local flag = false
      for item in self.luaExt_itemEnumFunc() do
        local isFilter = false
        if self.luaExt_itemEnumFilterFunc and self.luaExt_itemEnumFilterFunc(item) then
          isFilter = true
        end
        if isFilter == false then
          self:AddItem("", item, nil)
          flag = true
        end
      end
      if flag then
        id = id + 1
        itemBagMenu.titleTbl[id] = -293629216
      end
    end
    if SYSTEM:IsDungeon() and FUNC_COMMON:IsFootItemExist() then
      if id >= 1 then
        self.base.AddPageGroup(self)
      end
      if self.luaExt_footEnumFunc then
        for item in self.luaExt_footEnumFunc() do
          self:AddItem(id, "", item, nil)
        end
      end
      self:SetWindowSize(id, 0, 16)
      id = id + 1
      itemBagMenu.titleTbl[id] = 1902623495
    end
  end
  function itemBagMenu:Open()
    createList(self)
    self.bagCountWindow:Open()
    self.base.Open(self)
  end
  function itemBagMenu:openedAction()
    if self.curItem.obj then
      updateLineHelp(self.curItem.obj)
    end
    CommonSys:UpdateBasicMenu_PadHelp(itemBagMenu.luaExt_padHelpMainText)
  end
  function itemBagMenu:closedAction()
    self.bagCountWindow:Close()
    self.base.Close(self)
  end
  if SYSTEM:IsDungeonMenu() == false then
    itemBagMenu:SetOption({multiSelectable = true})
    function itemBagMenu:changeAllSelectAction()
      local bNewSelect = false
      local bNoSelect = false
      local function checkAddFunc(work, item)
        if item:IsNowEquipped() then
          bNoSelect = true
          return false
        end
        return true
      end
      itemBagMenu:AllMultiSelectFromLua({}, function()
      end, checkAddFunc, function()
        bNewSelect = true
      end, function()
      end)
      if bNewSelect == false then
        itemBagMenu:ResetSelecting()
        SOUND:PlaySe(SymSnd("SE_SYS_MARK"))
      elseif bNoSelect then
        SOUND:PlaySe(SymSnd("SE_SYS_NO_SELECT"))
      else
        SOUND:PlaySe(SymSnd("SE_SYS_MARK"))
      end
    end
  end
  function itemBagMenu:cancelAction()
    FlowSys.Stat.selectFlag = false
    MENU:ClearFocus(itemBagMenu)
    self:Close()
  end
  itemBagMenu:SetItemEnumFunc(function()
    return DUNGEON_MENU:EnumlateBagItems()
  end)
  if SYSTEM:IsDungeonMenu() then
    itemBagMenu:SetFootEnumFunc(function()
      return DUNGEON_MENU:EnumlateFootItems()
    end)
  end
  itemBagMenu:SetGenerateItemLineHelpTextFunc(function(itemIns)
    return itemIns:GetItemOneLineExplainText()
  end)
  itemBagMenu:SetChestEnumFunc(function()
    return DUNGEON_MENU:EnumlateBagChests()
  end)
  local genItemTextFunc = function(itemIns)
    return itemIns:GetItemText_forDungeonBag()
  end
  itemBagMenu:SetGenerateItemTextFunc(genItemTextFunc)
  if SYSTEM:IsDungeonMenu() then
    SetDungeonActions(itemBagMenu)
  else
    SetGroundActions(itemBagMenu)
  end
  function itemBagMenu:SetOption(tbl)
    if tbl.onePageLayout then
      self:ShowPageNum(false)
      itemBagMenu:SetLayoutRectAndLines(16, 40, 208, BAG_ITEM_ONE_PAGE_LINE_NUM)
    end
    if tbl.sortButtonEnable then
      GROUND:SetBagAfterOpenSortFlag()
      function self:sortAction()
        SOUND:PlaySe(SymSnd("SE_SYS_SORT"))
        if self:IsMultiSelect() then
          self:ResetSelecting()
        end
        GROUND:SortAndReduceBagItem()
        createList(self)
        self:UpdateItemList()
        if FUNC_COMMON:GetBagItemCount() == 0 and not FUNC_COMMON:IsFootItemExist() then
          self:Close()
        end
        if self.curItem.obj then
          self:updateLineHelp(self.curItem.obj)
        end
        if self:GetPageGroupCount() ~= 0 then
          local id = self:GetCurrentPageGroupNum() + 1
          self:SetTitle(self.titleTbl[id])
        end
        local nowCount = FUNC_COMMON:GetBagItemCount()
        local maxCount = FUNC_COMMON:GetBagItemMaxCount()
        if nowCount >= maxCount then
          MENU:SetTag_Value(0, maxCount)
          MENU:SetTag_Value(1, maxCount)
          self.bagCountWindow:SetText(-534034656)
        else
          MENU:SetTag_Value(0, nowCount)
          MENU:SetTag_Value(1, maxCount)
          self.bagCountWindow:SetText(-1807035551)
        end
      end
    end
    self.base.SetOption(self, tbl)
  end
  function itemBagMenu:decideAction()
    local actionMenu = MENU:CreateActionMenu(self.curItem.obj, self)
    self.itemActMenu = actionMenu
    if self.actionMenuSetupAction then
      self.actionMenuSetupAction(self.itemActMenu)
    end
    actionMenu:SetLayoutRectAndLines(240, 40, 64, 0)
    local parentBagMenu = self
    for k, actionInfo in ipairs(self.luaExt_actionTbl) do
      do
        local closeFlag = false
        local function decideActionFunc(self)
          if parentBagMenu.decideSelectedItemsAction then
            local selectedItems = {}
            for item in parentBagMenu:EnumerateSelectedItems() do
              table.insert(selectedItems, item)
            end
            parentBagMenu.decideSelectedItemsAction(selectedItems)
          end
          if actionInfo.optionTbl.commandId and parentBagMenu.commandIdAction then
            closeFlag = parentBagMenu.commandIdAction(actionInfo.optionTbl.commandId) or closeFlag
          end
          if actionInfo.optionTbl.action then
            closeFlag = actionInfo.optionTbl.action(itemBagMenu) or closeFlag
          end
          if actionInfo.optionTbl.actMenuNoCloseFlg == nil then
            if actionInfo.optionTbl.bagCloseFlg or closeFlag then
              MENU:ClearFocus(self)
              self:Close()
              parentBagMenu:Close()
            elseif not actionInfo.optionTbl.notActionCloseFlg then
              MENU:SetFocus(parentBagMenu)
              self:Close()
            else
              MENU:SetFocus(self)
            end
          end
        end
        actionMenu:AddActionItem(actionInfo.text, actionInfo.disableFilters, actionInfo.grayoutFilters, decideActionFunc)
      end
    end
    function actionMenu:cancelAction()
      MENU:SetFocus(parentBagMenu)
      self:Close()
    end
    function actionMenu:abortFocusAction()
      self:NotifyForceClose()
    end
    if self.luaExt_padHelpSubText then
      CommonSys:UpdateBasicMenu_PadHelp(self.luaExt_padHelpSubText)
    end
    actionMenu:Open()
    MENU:SetFocus(actionMenu)
    WaitAndForcedClose(actionMenu)
    if self.luaExt_padHelpMainText and self:IsOpened() then
      CommonSys:UpdateBasicMenu_PadHelp(self.luaExt_padHelpMainText)
    end
    self.itemActMenu = nil
  end
  function itemBagMenu.commandIdAction(commandId)
    SYSTEM:DebugPrint("itemBagMenu.commandIdAction")
    FlowSys.Stat.itemBagTbl = {}
    FlowSys.Stat.itemBagTbl.selectItem = commandId.id
    FlowSys.Stat.itemBagTbl.useItem = itemBagMenu.curItem.obj:GetBagIndex()
    FlowSys.Stat.itemBagTbl.bSelectPoke = commandId.flag
    FlowSys.Stat.itemBagTbl.targetItem = DungeonMenuSelectItems.SELECT_MENU_NON
    FlowSys.Stat.itemBagTbl.pokemonId = DungeonMenuSelectItems.SELECT_MENU_NON
    FlowSys.Stat.itemBagTbl.itemIns = itemBagMenu.curItem.obj
    if itemBagMenu:IsMultiSelect() then
      FlowSys.Stat.itemBagTbl.isMultiSelect = true
      FlowSys.Stat.itemBagTbl.itemInsTbl = {}
      for item in itemBagMenu:EnumerateSelectedItems() do
        table.insert(FlowSys.Stat.itemBagTbl.itemInsTbl, item)
      end
    end
    SYSTEM:DebugPrint(" commandId.id:" .. commandId.id)
    return true
  end
  return itemBagMenu
end
function OpenDungeonItemSelectMenu()
  FlowSys:Start()
  local targetItem = dungeonMenuItemSelect()
  FlowSys:Finish()
  return targetItem
end
function OpenDungeonItemSelectMenuWithFoot()
  FlowSys:Start()
  local targetItem = dungeonMenuItemSelect(true)
  FlowSys:Finish()
  return targetItem
end
function dungeonMenuItemSelect(bFoot, bEquipGrayed)
  local targetItem = -1
  local selectMenu = MENU:CreatePageGroupMenu()
  selectMenu:SetLayoutRectAndLines(16, 40, 208, 8)
  selectMenu:ShowPageNum(true)
  CommonSys:OpenBasicMenu(1053841057, 2124762465, "")
  local bagCountWindow = MENU:CreateBoardMenuWindow(ScreenType.B)
  bagCountWindow:SetFontType(FontType.TYPE_12)
  bagCountWindow:SetTextOffset(0, 0)
  bagCountWindow:SetLayoutRect(Rectangle(240, 168, 64, 16))
  local nowCount = FUNC_COMMON:GetBagItemCount()
  local maxCount = FUNC_COMMON:GetBagItemMaxCount()
  if nowCount >= maxCount then
    MENU:SetTag_Value(0, maxCount)
    MENU:SetTag_Value(1, maxCount)
    bagCountWindow:SetText(-534034656)
  else
    MENU:SetTag_Value(0, nowCount)
    MENU:SetTag_Value(1, maxCount)
    bagCountWindow:SetText(-1807035551)
  end
  for item in DUNGEON_MENU:EnumlateBagItems() do
    selectMenu:AddItem("", item, nil)
  end
  if bFoot and FUNC_COMMON:IsFootItemExist() then
    selectMenu:AddPageGroup()
    for item in DUNGEON_MENU:EnumlateFootItems() do
      selectMenu:AddItem(1, "", item, nil)
    end
    selectMenu:SetWindowSize(1, 0, 16)
  end
  local genItemTextFunc = function(itemIns)
    return itemIns:GetItemText_forDungeonBag()
  end
  function selectMenu:itemPreOpenModifyAction()
    self.curItem.text = genItemTextFunc(self.curItem.obj)
    local uniqueId = self.curItem.obj:GetUniqueId()
    local grayedItemTbl = DUNGEON_MENU:GetGrayedItemsForItemSelectMenu()
    for id in grayedItemTbl.uniqueID, nil, nil do
      if id == uniqueId then
        self.curItem.grayed = true
      end
    end
    if bEquipGrayed and self.curItem.obj:IsNowEquipped() then
      self.curItem.grayed = true
    end
  end
  function selectMenu:decideAction()
    targetItem = self.curItem.obj:GetBagIndex()
    if targetItem == -1 then
      targetItem = maxCount
    end
    bagCountWindow:Close()
    self:Close()
  end
  function selectMenu:cancelAction()
    bagCountWindow:Close()
    self:Close()
  end
  function selectMenu:currentItemChange()
    if self.curItem.obj then
      CommonSys:UpdateBasicMenu_LineHelp(self.curItem.obj:GetItemOneLineExplainText())
    end
  end
  bagCountWindow:Open()
  selectMenu:Open()
  selectMenu:currentItemChange()
  MENU:SetFocus(selectMenu)
  local menuTbl = {selectMenu, bagCountWindow}
  WaitAndForcedClose(menuTbl, true)
  CommonSys:CloseBasicMenu()
  return targetItem
end
function CreateFootItemMenu()
  local itemBagMenu = CreateDungeonItemBagMenu()
  itemBagMenu:SetLayoutRectAndLines(16, 40, 208, 1)
  itemBagMenu:ShowPageNum(false)
  itemBagMenu:SetGenerateItemLineHelpTextFunc(function(itemIns)
    return itemIns:GetItemOneLineExplainText()
  end)
  function itemBagMenu:Open()
    local id = 0
    CommonSys:SetVisibleBasicMenu(true)
    CommonSys:SetVisibleBasicMenu_PadHelp(true)
    CommonSys:UpdateBasicMenu_Title(1902623495)
    if DUNGEON_MENU:IsFootItemExist() then
      if self.luaExt_footEnumFunc then
        for item in self.luaExt_footEnumFunc() do
          self:AddItem(id, "", item, nil)
        end
      end
    elseif DUNGEON_MENU:IsFootTrapExist() then
      if self.luaExt_footEnumFunc then
        for item in self.luaExt_footEnumFunc() do
          self:AddItem(id, "", item, nil)
        end
      end
    elseif DUNGEON_MENU:IsFootStairsExist() then
      if self.luaExt_footEnumFunc then
        for item in self.luaExt_footEnumFunc() do
          self:AddItem(id, "", item, nil)
        end
      end
    elseif DUNGEON_MENU:IsFootQuestTargetExist() and self.luaExt_footEnumFunc then
      for item in self.luaExt_footEnumFunc() do
        self:AddItem(id, "", item, nil)
      end
    end
    self.base.Open(self)
    self.base.SetCursorItemIndex(self, 0)
    self.base.SetCurrentModifyItem(self, 0)
    self:decideAction()
    self:Close()
  end
  function itemBagMenu:closedAction()
    MENU:DestroyMenu(self.bagCountWindow)
    self.base.Close(self)
  end
  function itemBagMenu:SetVisible(flag)
    CommonSys:SetVisibleBasicMenu_Title(flag)
    CommonSys:SetVisibleBasicMenu_LineHelp(flag)
    if self.itemActMenu then
      self.itemActMenu:SetVisible(flag)
    end
    self.base.SetVisible(self, flag)
  end
  return itemBagMenu
end
function Dungeon_Giveup()
  local bRet = false
  local askMenu = MENU:CreateAskMenu()
  local GiveupYesText = -462101434
  local GiveupNoText = 332775707
  local GiveupAskText = -57084758
  if SYSTEM:IsMultiPlayMode() then
    GiveupYesText = -1625514095
    GiveupNoText = -1778984974
    GiveupAskText = 407828060
  end
  askMenu:Setup(true, false, false)
  askMenu:SetLayoutRectAndLines(336, 120, 48, 0)
  askMenu:AddItem(GiveupYesText, nil, {
    decideAction = function(self)
      bRet = true
      self:CloseAndClearFocus()
    end
  })
  askMenu:AddItem(GiveupNoText, nil, {
    decideAction = function(self)
      bRet = false
      self:CloseAndClearFocus()
    end
  })
  function askMenu:cancelAction()
    bRet = false
    self:CloseAndClearFocus()
  end
  askMenu:SetDefaultCursorDispIndex(1)
  MENU:SetFocus(askMenu)
  WINDOW:Log(GiveupAskText)
  WINDOW:SelectSetLuaMenu(askMenu)
  WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  WINDOW:CloseMessage()
  if bRet then
    SYSTEM:GiveupDungeon()
    if SYSTEM:IsEncountGroundMode() then
      SYSTEM:GroundEncountGiveup()
    end
    return true
  end
  return false
end
function Dungeon_Save(save_type, message, bGameRestMessage)
  local bRet = false
  local bResult = false
  local askMenu = MENU:CreateAskMenu()
  askMenu:Setup(true, false, false)
  askMenu:SetLayoutRectAndLines(336, 120, 48, 0)
  askMenu:AddItem(758286750, nil, {
    decideAction = function(self)
      bRet = true
      self:CloseAndClearFocus()
    end
  })
  askMenu:AddItem(-2127629441, nil, {
    decideAction = function(self)
      bRet = false
      self:CloseAndClearFocus()
    end
  })
  function askMenu:cancelAction()
    bRet = false
    self:CloseAndClearFocus()
  end
  askMenu:SetDefaultCursorDispIndex(1)
  MENU:SetFocus(askMenu)
  WINDOW:Log(903780722)
  WINDOW:SelectSetLuaMenu(askMenu)
  WINDOW:SelectEnd(MENU_SELECT_MODE.ENABLE_CANCEL)
  WINDOW:CloseMessage()
  if bRet then
    WINDOW:Log(-124596352)
    if save_type == "dungeon" then
      bResult = SYSTEM:SaveDungeon(false)
    elseif save_type == "dungeon_to_paradise" then
      bResult = SYSTEM:SaveDungeon(true)
    end
    WINDOW:ForceCloseMessage()
    if bResult then
      if message_type == "return_top" then
        WINDOW:Log(-1209879105)
        if bGameRestMessage then
          SYSTEM:CheckGameRestMessage()
        end
      else
        WINDOW:Log(-1617239266)
        if bGameRestMessage then
          SYSTEM:CheckGameRestMessage()
        end
      end
    else
      WINDOW:Log(1697017689)
    end
    WINDOW:CloseMessage()
  end
  if bResult and SYSTEM:IsEncountGroundMode() then
    SYSTEM:GroundEncountSuspend()
  end
  return bResult
end
