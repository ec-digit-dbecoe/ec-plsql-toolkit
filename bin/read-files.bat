@echo off
rem Usage: read-files %1 %2 %3 %4
rem %1 is directory
rem %2 is pattern
rem %3 is cmd_id
rem %4 is tmp_dir

setlocal EnableDelayedExpansion

rem Set the directory to the given subdir of the current working directory or to an absolute path
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
for /r "%dir%" %%f in (%2) do (
       set "filePath=%%f"
rem    set "relativePath=!filePath:%CD%\=!"
       set "relativePath=!filePath:%dir%\=!"
       IF EXIST "!filePath!" (
          certutil -f -encode !filePath! %4\~encode64.txt >nul
          echo    dbm_utility_krn.output_line^(p_cmd_id=^>%3, p_type=^>'OUT', p_base64=^>FALSE, p_text=^>
          <nul set/p = "'#^!"
          echo !relativePath!
          echo  ^'^);
          echo    dbm_utility_krn.output_line^(p_cmd_id=^>%3, p_type=^>'OUT', p_base64=^>TRUE, p_text=^>
          echo '
          type %4\~encode64.txt | findstr /V /C:"-"
          echo  ^'^);
          del %4\~encode64.txt
       )
)

echo    COMMIT;
echo END;
echo /

endlocal