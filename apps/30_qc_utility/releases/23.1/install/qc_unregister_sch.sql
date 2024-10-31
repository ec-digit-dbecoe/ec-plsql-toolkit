set termout on
set define on
set scan on
set feedback off
set verify off
PROMPT Unregistering schema '&&schema' for application'&&app_alias'...
DELETE qc_run_stats WHERE app_alias = '&&app_alias'AND object_owner='&&schema';
DELETE qc_run_msgs WHERE app_alias = '&&app_alias' AND object_owner='&&schema';
DELETE qc_dictionary_entries WHERE app_alias = '&&app_alias' AND dict_name = 'APP SCHEMA' AND dict_key = '&&schema';
COMMIT;
PROMPT Schema '&&schema' of application '&&app_alias' unregistered!
