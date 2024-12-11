PROMPT Extracting QC configuration data using DS utility...
DECLARE
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   ds_utility_krn.set_message_filter('&&message_filter');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'QC_EXPORT', p_set_type=>'SUB', p_system_flag=>'Y');
   ds_utility_ext.include_path(p_set_id=>l_set_id,p_path=>q'£
qc_apps/f[tab_seq=1];qc_dictionary_entries/f[tab_seq=2];qc_patterns/f[tab_seq=3];
£');
   ds_utility_krn.count_table_records(p_set_id=>l_set_id);
   ds_utility_krn.extract_data_set_rowids(p_set_id=>l_set_id);
   ds_utility_krn.mask_data_set(p_set_id=>l_set_id,p_commit=>TRUE);
   execute immediate 'TRUNCATE TABLE ds_output';
   ds_utility_krn.handle_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('QC_EXPORT'),p_oper=>'PREPARE-SCRIPT',p_output=>'DS_OUTPUT');
END;
/

PROMPT Creating Graphviz dot script "&&file_path..dot" to visualize graph of extracted data...
set termout off
spool &&file_path..dot replace
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('QC_EXPORT'), p_table_name=>'QC_%', p_full_schema=>'Y', p_show_aliases=>'Y', p_show_conf_columns=>'Y', p_show_column_types=>'Y'));
spool &&spool
set termout on

PROMPT Creating sql script "&&file_path..sql" to import QC configuration data...
set termout off
spool &&file_path..sql replace
select 'DELETE '||LOWER(table_name)||CHR(10)||';'||CHR(10)
  from user_tables
 where table_name in ('QC_APPS','QC_DICTIONARY_ENTRIES','QC_PATTERNS')
 order by table_name desc;
select text from ds_output order by line;
spool &&spool append
set termout on

PROMPT WARNING: Remind to save import sql script "&&file_path..sql" to a safe place!
