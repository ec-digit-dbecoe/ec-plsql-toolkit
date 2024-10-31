set termout on
set define on
set scan on
set feedback off
set verify off
PROMPT Registering schema '&&schema' for application '&&app_alias'...
exec qc_utility_krn.insert_dictionary_entry('&&app_alias','APP SCHEMA',UPPER(NVL('&&schema',USER)),UPPER(NVL('&&schema',USER)));
COMMIT;
PROMPT Schema '&&schema' registered for application '&&app_alias'!
