@echo off
rem Usage: find-files %1 %2
rem %1 is directory
rem %2 is cmd_id

setlocal EnableDelayedExpansion

set "dir=%1"

rem Resolve the directory path if it's relative
pushd "%dir%" || (
    echo Invalid directory path: %directory%
    exit /b
)
set "dir=%CD%"
popd

echo BEGIN

rem Loop through files recursively
for /r "%dir%" %%f in (*) do (
       set "filePath=%%f"
rem       set "relativePath=!filePath:%CD%\=!"
       set "relativePath=!filePath:%dir%\=!"
       echo    dbm_utility_krn.output_line(p_cmd_id=^>%2, p_type=^>'OUT', p_text=^>'!relativePath!'^);
)

echo    dbm_utility_krn.parse_files(p_cmd_id=^>%2^);
echo END;
echo /

endlocal
