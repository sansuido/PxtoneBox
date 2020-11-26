PowerShell Compress-Archive -Path source\cocos,source\PxtoneBox,source\conf.lua,source\main.lua -DestinationPath source.zip -Force
if not exist build mkdir build
del build\*.*
copy source\*.txt build
copy "C:\Program Files\LOVE\*.dll" build
copy "C:\Program Files\LOVE\*.txt" build
copy "C:\Program Files\LOVE\love.exe" build\PxtoneBox.exe
rcedit-x64.exe build\PxtoneBox.exe --set-icon source\PxtoneBox\res\favicon.ico
copy /b build\PxtoneBox.exe+source.zip build\PxtoneBox.exe
if not exist dist mkdir dist
PowerShell Compress-Archive -Path build\* -DestinationPath dist\PxtoneBox033.zip -Force



