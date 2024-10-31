-- 
-- Description:
--   Apply upgrade scripts of a release
--
-- Note:
--   Do not invoke this script directly.  
--
set define off
set define on
PROMPT Upgrading database objects...
@@ds_objects.sql
rem @@DS_UTILITY_VAR.pks
rem @@DS_UTILITY.pks
@@DS_UTILITY.pkb
