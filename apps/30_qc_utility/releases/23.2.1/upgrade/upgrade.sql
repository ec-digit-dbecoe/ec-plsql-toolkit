-- 
-- Description:
--   Apply upgrade scripts of a release
--
-- Note:
--   Do not invoke this script directly.  
--
set define off
set define on
REM PROMPT Upgrading database objects...
REM @@qc_objects.sql
set define off
PROMPT Upgrading package body QC_UTILITY_KRN...
@@QC_UTILITY_KRN.pkb
show error
PROMPT Upgrading package body QC_UTILITY_MSG...
@@QC_UTILITY_MSG.pkb
show error
rem @@qc_post_upgrade.sql