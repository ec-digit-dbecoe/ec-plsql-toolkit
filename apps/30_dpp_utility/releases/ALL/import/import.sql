PROMPT Importing DPP configuration data using sql script "&&file_path..sql"...
@&&file_path..sql
COMMIT;

PROMPT Re-synchronizing DPP sequences...
BEGIN
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DPP_JRN_SEQ', p_table_name=>'DPP_JOB_RUNS', p_column_name=>'JRN_ID');
END;
/
