  local setlvl = 0
  repeat
    WINDOW:CloseMessage()
    WINDOW:SysMsg("Select쐃Pokemon:")
    WINDOW:SelectStart()                                            --create selection menu
    WINDOW:SelectChain("Exit", 0)                                   --add entry (text, id)
    WINDOW:SelectChain("Hero", 1)
    WINDOW:SelectChain("Partner", 2)
    WINDOW:SelectChain("Force쐃Level", 3)
    WINDOW:DefaultCursor(0)                                         --set default entry
    local id = WINDOW:SelectEnd(MENU_SELECT_MODE.DISABLE_CANCEL)    --wait for and get window selection, store as "id"
 
    if id == 1 then
      local oldpkid = SymAct("HERO"):GetIndex()                     --get "hero" and "get index"? (gives current PKID)
      local newpkid
      local menu = MENU:CreateNumericMenuWindow(ScreenType.A)       --create a numeric entry window
      menu:SetLayoutRect(Rectangle(96, 80, 132, 84))                --set window position/size
      menu:SetPlace(3)                                              --
      menu:SetDigit(3)                                              --
      menu:SetStartNum(oldpkid)                                     --set initial value
      menu:SetType(NUM_MENU_TYPE.TYPE_DIGIT_ON)                     --set some flags for the menu?
      menu:SetTextOffset(24, 40)                                    --position menu text?
      function menu:decideAction()                                  --set menu accept <callback?> function
        newpkid = self:GetSettingData()                                --get & store selection value
        GROUND:SetHero(newpkid, setlvl)                                --set our character
        CHARA:ReloadHeroPartner()                                      --Refresh characters somehow?
        self:Close()                                                  --close menu
      end
      function menu:cancelAction()                                  --set menu cancel <callback?> function
        self:Close()                                                  --close menu
      end
      menu:Open()                                                   --open menu
      menu:SetCaption("Hero Pokemon ID")                            --set menu caption
      MENU:SetFocus(menu)
      MENU:WaitClose(menu)
      
    elseif id == 2 then
      local oldpkid = SymAct("PARTNER"):GetIndex()                  --get "partner" and "get index"? (gives current PKID)
      local newpkid
      local menu      = MENU:CreateNumericMenuWindow(ScreenType.A)  --create a numeric entry window
      menu:SetLayoutRect(Rectangle(96, 80, 132, 84))                --set window position/size
      menu:SetPlace(3)                                              --
      menu:SetDigit(3)                                              --
      menu:SetStartNum(oldpkid)                                     --set initial value
      menu:SetType(NUM_MENU_TYPE.TYPE_DIGIT_ON)                     --set some flags for the menu?
      menu:SetTextOffset(24, 40)                                    --position menu text?
      function menu:decideAction()                                  --set menu accept <callback?> function
        newpkid = self:GetSettingData()                               --get & store selection value
        GROUND:SetPartner(newpkid, setlvl)                            --set partner character
        CHARA:ReloadHeroPartner()                                     --Refresh characters somehow? <----
        self:Close()                                                  --close menu
      end
      function menu:cancelAction()                                  --set menu cancel <callback?> function
        self:Close()                                                  --close menu
      end
      menu:Open()                                                   --open menu
      menu:SetCaption("Partner Pokemon ID")                         --set menu caption
      MENU:SetFocus(menu)
      MENU:WaitClose(menu)

    elseif id == 3 then
      local menu      = MENU:CreateNumericMenuWindow(ScreenType.A)  --create a numeric entry window
      menu:SetLayoutRect(Rectangle(96, 80, 132, 84))                --set window position/size
      menu:SetPlace(3)                                              --
      menu:SetDigit(3)                                              --
      menu:SetStartNum(setlvl)                                      --set initial value
      menu:SetType(NUM_MENU_TYPE.TYPE_DIGIT_ON)
      menu:SetTextOffset(24, 40)
      function menu:decideAction()                                  --set menu <callback?> functions
        setlvl = self:GetSettingData()
        self:Close()
      end
      function menu:cancelAction()
        self:Close()
      end
      menu:Open()
      menu:SetCaption("Forced Level")
      MENU:SetFocus(menu)
      MENU:WaitClose(menu)
    end
  until id == 0