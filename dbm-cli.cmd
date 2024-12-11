@echo off
if "%~1"=="-help" (
    echo Data Base Migration Utility
    echo Usage: dbm-cli [options] [commands]
    echo .
    echo Main commands ^(use help command to get the full list^)
    echo    migrate ^<app^>      migrate an application
    echo    rollback ^<app^>     rollback a failed migration
    echo    uninstall ^<app^>    uninstall an application
    echo    validate ^<app^>     validate a migration
    echo    help               display all dbm-cli commands
    echo When more than one command, separate them with a /
    echo .
    echo Options ^(format: -option or "-parameter=value"^)
    echo    apps_dir=^<path^>    applications directory
    echo    conf_path=^<file^>   configuration file path
    echo    help               this help
    echo    noexit             do not exit after executing command
    echo    silent             run silently
    echo.
    exit /b
)

REM Check if DBM_USERNAME is not set, then prompt user
if "%DBM_USERNAME%"=="" (
    set /p "DBM_USERNAME=Enter username: "
)

REM Check if DBM_PASSWORD is not set, then prompt user
if "%DBM_PASSWORD%"=="" (
rem   set /p "DBM_PASSWORD=Enter password: "
   for /f "delims=" %%a in ('powershell -command "$p = read-host 'Enter password' -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "DBM_PASSWORD=%%a"
)

REM Check if DBM_DATABASE is not set, then prompt user
if "%DBM_DATABASE%"=="" (
    set /p "DBM_DATABASE=Enter database: "
)

set DBM_CONNECT="%DBM_USERNAME%/%DBM_PASSWORD%@%DBM_DATABASE%"
set DBA_CONNECT="%DBA_USERNAME%/%DBA_PASSWORD%@%DBA_DATABASE%"
set DBM_ERROR=

set NLS_LANG=.UTF8

REM Set DBM_CONF_PATH if not set
if "%DBM_CONF_PATH%"=="" (
    set DBM_CONF_PATH=conf\dbm_utility.conf
)

REM Set DBM_APPS_DIR if not set
if "%DBM_APPS_DIR%"=="" (
    set DBM_APPS_DIR=apps
)

REM Set DBM_TMP_DIR if not set
if "%DBM_TMP_DIR%"=="" (
    set DBM_TMP_DIR=tmp
)

REM Set DBM_LOGS_DIR if not set
if "%DBM_LOGS_DIR%"=="" (
    set DBM_LOGS_DIR=logs
)

REM Install/Upgrade upon first launch after unzip
if not exist "~set-os.sql" (
   echo INSTALLING/UPGRADING DBM TOOL...
   goto migrate
)

:again
del %DBM_TMP_DIR%\~*.sql 1>nul 2>nul
sqlplus -L %DBM_CONNECT% @sql\dbm-startup.sql %*
set DBM_ERROR=%ERRORLEVEL%
echo ERRORLEVEL=%DBM_ERROR%
:check_error1D
if not "%DBM_ERROR%" == "20735" goto check_error2
echo !!! DBM UTILITY NEEDS TO BE INSTALLED !!!!
:migrate
call migrate-dbm
set DBM_ERROR=%ERRORLEVEL%
echo ERRORLEVEL=%DBM_ERROR%
if "%DBM_ERROR%" == "0" goto again
echo !!! FATAL ERROR WHILE INSTALLING/UPGRADING DBM TOOL !!!!
exit /b %DBM_ERROR%
:check_error2
if not "%DBM_ERROR%" == "20736" exit /b %DBM_ERROR%
echo !!! FATAL ERROR, DBM UTILITY IS NOT INSTALLED PROPERLY !!!!
