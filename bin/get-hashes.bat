@echo off

powershell -ExecutionPolicy Bypass -File "%~dp0get-hashes.ps1" -dir "%1" -cmd_id "%2" -op "%3" -apps_dir "%4"

endlocal