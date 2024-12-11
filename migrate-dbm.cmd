@echo off
if "%~1"=="-help" (
    echo Usage: migrate-dbm [version]
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

set DBM_SRC_VER_CODE=%2

for /f %%i in ('powershell -ExecutionPolicy Bypass -Command "& { Get-Date -Format 'yyyyMMddHHmmss' }"') do set "DATETIME=%%i"
:again
del %DBM_TMP_DIR%\~*.sql 1>nul 2>nul
@echo off
rem sqlplus -L %DBM_CONNECT% @sql\migrate-dbm %*
powershell -Command "& { $output = sqlplus -L '%DBM_CONNECT%' @sql/migrate-dbm %1 %DBM_SRC_VER_CODE% 2>&1; $exitcode = $LASTEXITCODE; $output | Tee-Object -FilePath \"$env:DBM_LOGS_DIR\$env:DATETIME-migrate-dbm_utility.log\" -Append; if ($exitcode -eq 0 -and $output -match 'glogin\.sql') { $exitcode = 1 }; exit $exitcode; }"
set DBM_ERROR=%ERRORLEVEL%
set DBM_SRC_VER_CODE=
echo ERRORLEVEL=%DBM_ERROR%
if "%DBM_ERROR%" == "20735" exit /b 0
if not "%DBM_ERROR%" == "0" exit /b %DBM_ERROR%
goto again
