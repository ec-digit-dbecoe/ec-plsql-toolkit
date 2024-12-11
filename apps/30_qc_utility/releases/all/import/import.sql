PROMPT Importing QC configuration data using sql script "&&file_path..sql"...
@&&file_path..sql
COMMIT;

PROMPT Re-synchronizing QC sequences...
BEGIN
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'QC_MSG_SEQ', p_table_name=>'QC_RUN_MSGS', p_column_name=>'MSG_IVID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'QC_RUN_SEQ', p_table_name=>'QC_RUNS', p_column_name=>'RUN_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'QC_STAT_SEQ', p_table_name=>'QC_RUN_STATS', p_column_name=>'STAT_IVID');
END;
/
