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
rem @@qc_objects.sql
set define off
@@QC_UTILITY_LIC.pks
@@QC_UTILITY_VAR.pks
@@QC_UTILITY_STAT.pks
@@QC_UTILITY_ORA_04068.pks
@@QC_UTILITY_MSG.pks
@@QC_UTILITY_KRN.pks
@@QC_UTILITY_STAT.pkb
@@QC_UTILITY_ORA_04068.pkb
@@QC_UTILITY_MSG.pkb
@@QC_UTILITY_KRN.pkb
rem @@qc_post_upgrade.sql