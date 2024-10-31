REM 
REM Data Set Utility Demo - Data Set Backup
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

PAUSE Configure data set definition
CLEAR SCREEN
declare
l_set_id ds_data_sets.set_id%TYPE;
begin
ds_utility_krn.set_encrypt_tokenized_values(FALSE); -- disable encryption of tokens
ds_utility_krn.set_message_filter('EWI');
l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DATA_SET_BACKUP', p_set_type=>'SUB');
dbms_output.put_line('set_id='||l_set_id);
ds_utility_ext.include_path(p_set_id=>l_set_id,p_path=>q'£
ds_masks/b[where="table_name NOT LIKE 'DS%'", export=UI, tab_seq=1]+<1*/n; /* all non-DS masks with no child tables, refresh mode */
ds_data_sets ds/b[where="set_id=&&set_id", tab_seq=2]=<3*; /* specified data set with its child tables (3 levels) */
rec/n; /* exclude records table */
!*^>-0*; /* add recursively missing fks for referential integrity */
column[msk_type=SEQUENCE, options="differ_masking=true", locked=Y]; /* default column properties*/
ds.set_id[params=DS_SET_SEQ]; /* relocate data set ids using specified sequence */
tab.table_id[params=DS_TAB_SEQ]; /* relocate table_ids using specified sequence */
con.con_id[params=DS_CON_SEQ]; /* relocate constraint ids using specified sequence */
£');
ds_utility_krn.count_table_records(p_set_id=>l_set_id);
ds_utility_krn.extract_data_set_rowids(p_set_id=>l_set_id);
ds_utility_krn.mask_data_set(p_set_id=>l_set_id,p_commit=>TRUE);
end;
/

PAUSE Generate views to check extracted data
CLEAR SCREEN
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'), p_view_suffix=>'_V');
select * from ds_data_sets_v;
select * from ds_tables_v;
select * from ds_constraints_v;

PAUSE Drop views
CLEAR SCREEN
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'), p_view_suffix=>'_V');

PAUSE Generate graph
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'), p_table_name=>'DS_%', p_full_schema=>'Y', p_show_aliases=>'Y'));

PAUSE Generate script (for manual execution in target schema)
CLEAR SCREEN
truncate table ds_output;
exec ds_utility_krn.handle_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'),p_oper=>'PREPARE-SCRIPT',p_output=>'DS_OUTPUT');

PAUSE Extract script
CLEAR SCREEN
select text from ds_output order by line;

PAUSE Execute script in target schema
CLEAR SCREEN
exec null;
