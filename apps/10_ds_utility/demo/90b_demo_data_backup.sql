REM 
REM Data Set Utility Demo - Data Set Backup
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM This scripts remap msk_id using tokens
REM 

select * from ds_tokens where value!=token;
select * from ds_masks;
select * from ds_tokens where msk_id in (select msk_id from ds_masks where table_name not like 'DS%');

PAUSE Configure data set definition
CLEAR SCREEN
declare
l_set_id ds_data_sets.set_id%TYPE;
begin
ds_utility_krn.set_message_filter('EWI');
l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DATA_SET_BACKUP', p_set_type=>'SUB');
dbms_output.put_line('set_id='||l_set_id);
ds_utility_ext.include_path(p_set_id=>l_set_id,p_path=>q'£
ds_masks/b[where="table_name NOT LIKE 'DS%'", export=UI, tab_seq=1]+<1*/n; /* all non-DS masks with no child tables, refresh mode */
ds_data_sets ds/b[where="set_id=&&set_id", tab_seq=2]=<3*; /* specified data set with its child tables (3 levels) */
rec/n; /* exclude records table */
!*^>-0*; /* add recursively missing fks for referential integrity */
msk.msk_id[msk_type=TOKENIZE, options="encrypt_tokenized_values=false"]; /*map mask ids with those of the target schema*/
column[msk_type=SEQUENCE, options="differ_masking=true", locked=Y]; /* default column properties*/
ds.set_id[params=DS_SET_SEQ]; /* relocate data set ids using specified sequence */
tab.table_id[params=DS_TAB_SEQ]; /* relocate table_ids using specified sequence */
con.con_id[params=DS_CON_SEQ]; /* relocate constraint ids using specified sequence */
£');
end;
/

PAUSE Check configuration
CLEAR SCREEN

REM Create tokens to map local msk_id with remote ones
DECLARE
   CURSOR c_tok IS
      SELECT loc.table_name, loc.column_name
           , loc.msk_id loc_msk_id, rem.msk_id rem_msk_id
        FROM ds_masks loc
        LEFT OUTER JOIN ds_masks@DBCC_DIGIT_01_T.CC.CEC.EU.INT rem
          ON rem.table_name = loc.table_name
         AND rem.column_name = loc.column_name
       WHERE loc.table_name NOT LIKE 'DS%'
      ;
BEGIN
   DELETE ds_tokens
    WHERE msk_id IN (
             SELECT msk_id
               FROM ds_masks
              WHERE table_name LIKE 'DS%'
          )
   ;
   FOR r_tok IN c_tok LOOP
      ds_utility_krn.set_token_for_value(
         p_table_name=>'DS_MASKS'
        ,p_column_name=>'MSK_ID'
        ,p_value=>r_tok.loc_msk_id
        ,p_token=>NVL(r_tok.rem_msk_id,r_tok.loc_msk_id)
      );
   END LOOP;
   COMMIT;
END;
/

PAUSE Check tokens
CLEAR SCREEN
select * from ds_tokens where msk_id in (select msk_id from ds_masks where table_name='DS_MASKS' and column_name='MSK_ID');

PAUSE Extract and mask data
CLEAR SCREEN
declare
l_set_id ds_data_sets.set_id%TYPE;
begin
ds_utility_krn.set_message_filter('EWI');
l_set_id := ds_utility_krn.get_data_set_def_by_name(p_set_name=>'DATA_SET_BACKUP');
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
select * from ds_masks_v;

PAUSE Drop views
CLEAR SCREEN
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'), p_view_suffix=>'_V');

PAUSE Generate graph
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DATA_SET_BACKUP'), p_table_name=>'DS_%', p_full_schema=>'Y', p_show_aliases=>'Y', p_show_conf_columns=>'Y', p_show_column_types=>'Y'));

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
