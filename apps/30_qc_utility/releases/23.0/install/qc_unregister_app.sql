set termout on
set define on
set scan on
set feedback off
set verify off
PROMPT Unregistering application '&&app_alias'...
DELETE qc_run_stats WHERE app_alias = '&&app_alias';
DELETE qc_run_msgs WHERE app_alias = '&&app_alias';
DELETE qc_dictionary_entries WHERE app_alias = '&&app_alias';
DELETE qc_patterns WHERE app_alias = '&&app_alias';
DELETE qc_apps WHERE app_alias = '&&app_alias';
COMMIT;
PROMPT Application '&&app_alias' unregistered!
