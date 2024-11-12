@echo off
setlocal
set "FilePath=%1"
set "CmdId=%2"
set "TmpDir=%3"

powershell -ExecutionPolicy Bypass -File "%~dp0read-file.ps1" -FilePath "%FilePath%" -CmdId "%CmdId%" -TmpDir "%TmpDir%"

endlocal
