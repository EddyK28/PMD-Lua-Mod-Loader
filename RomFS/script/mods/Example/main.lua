--Basic Sample Mod Code

text = "Hi there!\n I'm a sample mod!"

--many functions that take strings strip spaces. Replace spaces with equivalent _________
text:gsub(" ","[LE]") 

WINDOW:SysMsg(text)
WINDOW:CloseMessage()