@echo off
:loop
sqlplus -L -S %DBM_CONNECT% %1 %2 %3 %4 %5 %6 %7 %8 %9
set DBM_ERROR=%ERRORLEVEL%
if not "%DBM_ERROR%"=="0" goto end
goto loop
:end