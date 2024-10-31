set define off
set define on
PROMPT Creating database objects...
@@mail_objects
set define off
PROMPT Creating package specifications...
@@MAIL_UTILITY_VAR.pks
@@MAIL_UTILITY_KRN.pks
@@MAIL_UTILITY_LIC.pks
PROMPT Creating package bodies...
@@MAIL_UTILITY_KRN.pkb
set define on
set define off
