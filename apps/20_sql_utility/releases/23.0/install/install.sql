set define off
set define on
PROMPT Creating database objects...
@@sql_objects
set define off
PROMPT Creating package specifications...
@@SQL_UTILITY.pks
@@SQL_UTILITY_LIC.pks
PROMPT Creating package bodies...
@@SQL_UTILITY.pkb
