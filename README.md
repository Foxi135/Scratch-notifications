# Scratch-notifications
This every (by default) 3 minutes checks for messages with python and notifies you if it finds unread messages

## Build
(note: for now the only supported OS is Windows)
### 1st part
1. move all files to .zip archive except for utf8.lua and settings.lua, (these two need to be outside the archive), settings.lua can be empty), 
make sure that these files are in the root of the archive
2. rename .zip extension to [.love](https://fileinfo.com/extension/love)

### 2nd part
0. download love2d (either zip or installer)
1. [from love2d folder copy these files](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable):
 - SDL2.dll
 - OpenAL32.dll (note: this file is different in the 64 bit download despite still being called 'OpenAL32.dll')
 - love.exe
 - license.txt
 - love.dll
 - lua51.dll
 - mpg123.dll
 - msvcp120.dll
 - msvcr120.dll
2. open cmd and change directory to directory with .love file you created
3. in cmd type in "copy /b love.exe+[name].love SN.exe"
4. delete love.exe and .love file from directory
Optional: change icon with [Resource hacker](http://www.angusj.com/resourcehacker/), [(instructions here)](https://gamedev.stackexchange.com/questions/27341/how-do-i-change-a-l%c3%96ve2d-game-executables-icon/121947#121947)
The source code of created exe can be checked and edited with [7zip](https://www.7-zip.org/)
