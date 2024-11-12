@echo off
setlocal
set DirectoryPath=%1
set Pattern=%2
set CmdId=%3
set TmpDir=%4

powershell -ExecutionPolicy Bypass -File "%~dp0read-files.ps1" -DirectoryPath "%DirectoryPath%" -Pattern "%Pattern%" -CmdId "%CmdId%" -TmpDir "%TmpDir%"

endlocal
