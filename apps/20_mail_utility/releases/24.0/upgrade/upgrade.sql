-- 
-- Description:
--   Apply upgrade scripts of a release
--
-- Note:
--   Do not invoke this script directly.  
--
set define off
set define on
PROMPT Creating database objects...
rem @@mail_objects
set define off
PROMPT Re-Creating package specifications...
@@MAIL_UTILITY_VAR.pks
@@MAIL_UTILITY_KRN.pks
@@MAIL_UTILITY_KRN.pkb
set define on
set define off
