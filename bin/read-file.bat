@echo off
rem Usage: read-file %1 %2 %3
rem %1 is file path
rem %2 is cmd_id
rem %3 is tmp_dir
setlocal EnableDelayedExpansion
certutil -f -encode %1 %3\~encode64.txt >nul
echo BEGIN
echo    dbm_utility_krn.output_line^(p_cmd_id=^>%2, p_type=^>'OUT', p_base64=^>FALSE, p_text=^>
<nul set/p = "'#^!"
echo %1
echo  ^'^);
echo    dbm_utility_krn.output_line^(p_cmd_id=^>%2, p_type=^>'OUT', p_base64=^>TRUE, p_text=^>
echo '
type %3\~encode64.txt | findstr /V /C:"-"
echo  ^'^);
echo    COMMIT;
echo END;
echo /
del %3\~encode64.txt
endlocal