PROMPT Importing DS configuration data using sql script "&&file_path..sql"...
@&&file_path..sql
COMMIT;

PROMPT Re-snchronizing DS sequences...
BEGIN
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_CON_SEQ', p_table_name=>'DS_CONSTRAINTS', p_column_name=>'CON_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_MSK_SEQ', p_table_name=>'DS_MASKS', p_column_name=>'MSK_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_PAT_SEQ', p_table_name=>'DS_PATTERNS', p_column_name=>'PAT_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_REC_SEQ', p_table_name=>'DS_RECORDS', p_column_name=>'REC_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_SET_SEQ', p_table_name=>'DS_DATA_SETS', p_column_name=>'SET_ID');
   ddl_utility.sync_sequence_with_table(p_sequence_name=>'DS_TAB_SEQ', p_table_name=>'DS_TABLES', p_column_name=>'TABLE_ID');
END;
/
