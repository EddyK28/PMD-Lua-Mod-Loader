--Basic Sample Mod Code

text = "Hi there!\n I'm a sample mod!"

--many functions that take strings strip spaces. Replace spaces with equivalent text directive
WINDOW:SysMsg(text:gsub(" ","[LE]"))
WINDOW:CloseMessage()