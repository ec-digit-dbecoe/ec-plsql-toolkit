-- 
-- Description:
--   Apply upgrade scripts of a release
--
-- Note:
--   Do not invoke this script directly.  
--
set define off
set define on
rem PROMPT Upgrading database objects...
rem @@gen_objects.sql
PROMPT Upgrading packages...
@@GEN_UTILITY.pks
@@GEN_UTILITY_LIC.pks
@@GEN_UTILITY.pkb
