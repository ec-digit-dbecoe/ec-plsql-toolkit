set termout on
set define on
set scan on
set feedback off
set verify off
PROMPT Resetting configuration...
TRUNCATE TABLE qc_run_stats;
TRUNCATE TABLE qc_run_msgs;
TRUNCATE TABLE qc_runs;
TRUNCATE TABLE qc_dictionary_entries;
TRUNCATE TABLE qc_patterns;
TRUNCATE TABLE qc_apps;
TRUNCATE TABLE qc_checks;
@@qc_data
PROMPT Configuration reset successfuly!
