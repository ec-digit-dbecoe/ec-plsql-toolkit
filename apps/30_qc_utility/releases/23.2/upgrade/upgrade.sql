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
@@qc_register_pat.sql
set define off
@@QC_UTILITY_KRN.pkb
rem @@qc_post_upgrade.sql