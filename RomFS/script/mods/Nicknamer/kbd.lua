--====PMD 3/4 Keyboard Menu====--
--MIT License
--Copyright (c) 2019 EddyK28

local function getKeys(bShift)
  if bShift then
    return "[VO:110][S:12]~[S:16]![S:16]@[S:13]#[S:16]$[S:16]%[S:15]^[S:16]&[S:15]*[S:16]([S:20])[S:16]_[S:17]+[S:15]←\n"..
    "[VS:3][S:8]Tab[S:14]Q[S:12]W[S:14]E[S:15]R[S:15]T[S:16]Y[S:14]U[S:17]I[S:17]O[S:13]P[S:16]{[S:20]}\n"..
    "[VS:4][S:6]Caps[S:18]A[S:15]S[S:15]D[S:16]F[S:15]G[S:14]H[S:15]J[S:17]K[S:15]L[S:18]:[S:19]\"[S:15][VS:4]←[VS:252][S:253]|\n"..
    "[VS:4][S:10]Shift[S:20]Z[S:14]X[S:14]C[S:14]V[S:16]B[S:15]N[S:14]M[S:15]<[S:15]>[S:17]?[S:16]Shift\n"..
    "[VS:4][S:8]Del[S:127][S:127][S:10]END\n"
  else
    return "[VO:110][S:12]`[S:16]1[S:16]2[S:16]3[S:16]4[S:16]5[S:16]6[S:16]7[S:16]8[S:16]9[S:16]0[S:17]-[S:16]=[S:15]←\n"..
    "[VS:3][S:8]Tab[S:16]q[S:16]w[S:16]e[S:19]r[S:17]t[S:18]y[S:17]u[S:18]i[S:17]o[S:18]p[S:15][[S:18]]\n"..
    "[VS:4][S:6]Caps[S:18]a[S:18]s[S:17]d[S:17]f[S:18]g[S:16]h[S:18]j[S:18]k[S:18]l[S:19];[S:19]'[S:16][VS:4]←[VS:252][S:253]|\n"..
    "[VS:4][S:10]Shift[S:20]z[S:18]x[S:17]c[S:16]v[S:17]b[S:16]n[S:18]m[S:15],[S:19].[S:20]/[S:16]Shift\n"..
    "[VS:4][S:8]Del[S:127][S:127][S:10]END\n"
  end
end

--key outlines (Warning: Size of keys is hard-coded)
local board = 
    "[VO:101][LINE:0:20]\n"..
    
    "[VO:106][S:24]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:114][S:24]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:121][LINE:0:20]\n"..
    
    "[VO:126][S:34]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:134][S:34]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:141][LINE:0:20]\n"..
    
    "[VO:146][S:40]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:154][S:40]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:161][LINE:0:20]\n"..
    
    "[VO:166][S:47]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:174][S:47]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|[S:19]|\n"..
    "[VO:181][LINE:0:20]\n"..
    
    "[VO:186][S:34]|[S:19]|[S:19]|[S:127][S:26]|[S:19]|[S:19]|\n"..
    "[VO:194][S:34]|[S:19]|[S:19]|[S:127][S:26]|[S:19]|[S:19]|\n"..
    "[VO:201][LINE:0:20]\n"



local a1,a2,a3 = ...

local maxLines = a2 or 4

local accept = false

local tchPt
local bTch = false
local key = nil
local tstr = a1 or ""
local iShift = 0
local iLine = 1

local keyBox
local textBox 

--define key functions
local function del()
  --tstr = tstr:sub(1, -2)
  if tstr:sub(-1,-1) == "\n" then
    iLine = iLine - 1
  end
  tstr = tstr:gsub("[%z\1-\127\194-\244][\128-\191]*$", "")
end

local function shft()
  
  if iShift > 0 then
    iShift = 0
    keyBox:SetText(getKeys(false)..board)
  else
    iShift = 1
    keyBox:SetText(getKeys(true)..board)
  end
end

local function caps()
  if iShift > 1 then
    iShift = 0
    keyBox:SetText(getKeys(false)..board)
  else
    iShift = 2
    keyBox:SetText(getKeys(true)..board)
  end
end

local function sbmt()
  return true
end

local function ntr()
  if iLine < maxLines then
    iLine = iLine + 1
    tstr = tstr .. "\n"
  end
end

--define keyboard keys
local row1  = {"`","`","1","2","3","4","5","6","7","8","9","0","-","=",del}
local row2  = {"  ","  ","q","w","e","r","t","y","u","i","o","p","[","]","\\"}
local row3  = {caps,caps,"a","s","d","f","g","h","j","k","l",";","'",ntr}
local row4  = {shft,shft,shft,"z","x","c","v","b","n","m",",",".","/",shft,shft}
local row5  = {nil,nil,"\\",""," ","","",sbmt,sbmt}

local row1s = {"~","~","!","@","#","$","%","^","&","*","(",")","_","+",del}
local row2s = {"  ","  ","Q","W","E","R","T","Y","U","I","O","P","{","}","|"}
local row3s = {caps,caps,"A","S","D","F","G","H","J","K","L",":","\"",ntr}
local row4s = {shft,shft,shft,"Z","X","C","V","B","N","M","<",">","?",shft,shft}
local row5s = {nil,nil,"|",""," ","","",sbmt,sbmt}


--create keyboard menu
keyBox = MENU:CreateBoardMenuWindow(ScreenType.B)
keyBox:SetLayoutRect(Rectangle(0, 0, 320, 240))
keyBox:SetText(getKeys(false)..board)
keyBox:SetTextOffset(1, 1)
keyBox:Open()
MENU:SetFocus(keyBox)

--create text box menu
local textBox = MENU:CreateBoardMenuWindow(ScreenType.B)
textBox:SetLayoutRect(Rectangle(15, 15, 290, 75))
textBox:SetTextOffset(1, 0)
textBox:SetText(tstr.."_")
textBox:Open()
MENU:SetFocus(textBox)
  

  
  while true do     --wait for button presses
  
    TASK:Sleep(TimeSec(1,TIME_TYPE.FRAME))
    if PAD:Data("START|B") then   --open menu
      break
    elseif PAD:Data("X") then
      accept = true
      break
    end
    
    tchPt = PAD:TouchPointData()
    --textBox:SetText(string.format("  %d,%d\n  %f",tchPt.x,tchPt.y,math.floor((tchPt.x-26)/23)))
    if tchPt.x > -1 then
      if not bTch then
        bTch = true
        key = nil
        if tchPt.y < 109 then
        
        elseif tchPt.y < 129 then
          --(tchPt.x-3)/23
          if iShift > 0 then
            key = row1s[math.floor((tchPt.x-3)/23)+2]
          else
            key = row1[math.floor((tchPt.x-3)/23)+2]
          end
        elseif tchPt.y < 149 then
          --(tchPt.x-13)/23
          if iShift > 0 then
            key = row2s[math.floor((tchPt.x-13)/23)+2]
          else
            key = row2[math.floor((tchPt.x-13)/23)+2]
          end
        elseif tchPt.y < 169 then
          --(tchPt.x-20)/23
          if iShift > 0 then
            key = row3s[math.floor((tchPt.x-20)/23)+2]
          else
            key = row3[math.floor((tchPt.x-20)/23)+2]
          end
        elseif tchPt.y < 189 then
          --(tchPt.x-26)/23
          if iShift > 0 then
            key = row4s[math.floor((tchPt.x-26)/23)+3]
          else
            key = row4[math.floor((tchPt.x-26)/23)+3]
          end
        elseif tchPt.y < 209 then
          textBox:SetText(string.format("  %d,%d\n  %f",tchPt.x,tchPt.y,math.floor((tchPt.x-239)/23)))
          if tchPt.x < 81 then
            key = row5[math.floor((tchPt.x-13)/23)+2]
          elseif tchPt.x < 239 then
            key = row5[5]
          else
            key = nil
            key = row5[math.floor((tchPt.x-239)/23)+6]
          end
        end
        
        if key then
          if type(key) == "string" then
            tstr = tstr .. key
            textBox:SetText(tstr.."_")
            if iShift == 1 then
              shft()
            end
          elseif type(key) == "function" then
            if key() then 
              accept = true
              break
            end
            textBox:SetText(tstr.."_")
          end
        end
        
      end
    else
      bTch = false
    end
  end
  
  keyBox:Close()
  textBox:Close()
  
  if accept then return tstr
  else return nil end