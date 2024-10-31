set define off
set define on
PROMPT Creating database objects...
@@ds_objects
set define off
PROMPT Creating package specifications...
@@DS_UTILITY_VAR.pks
show error
@@DS_UTILITY.pks
show error
PROMPT Creating package bodies...
@@DS_UTILITY.pkb
show error
