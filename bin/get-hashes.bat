@echo off

rem Usage: get-hsh %1 %2 %3
rem %1 is directory
rem %2 is cmd_id
rem %3 is op (set-hashes or chk-hashes)
rem %4 is apps dir

setlocal enabledelayedexpansion

set "dir=%1"

rem Resolve the directory path if it's relative
pushd "%dir%" || (
    echo Invalid directory path: %directory%
    exit /b
)
set "dir=%CD%"
popd

echo BEGIN
echo    NULL;

for %%f in ("%dir%\*") do (
    if not "%%~xF"=="" (
        set "filePath=%%f"
        set "relativePath=!filePath:%dir%\=!"
        for /f "tokens=*" %%a in ('certutil -hashfile "%%f" MD5 ^| findstr /V /C:":" /C:"- "') do (
            echo    dbm_utility_krn.output_line(p_cmd_id=^>%2, p_type=^>'OUT', p_text=^>'%%a %1\!relativePath!'^);
        )
    )
)

echo    dbm_utility_krn.parse_hashes(p_cmd_id=^>%2^, p_op=^>'%3', p_apps_dir=^>'%4');
echo END;
echo /

endlocal