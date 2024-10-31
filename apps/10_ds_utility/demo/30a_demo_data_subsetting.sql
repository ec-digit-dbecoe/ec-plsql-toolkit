REM 
REM Data Set Utility Demo - Data Subsetting
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

PAUSE Configure data subsetting?
CLEAR SCREEN
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_SUB', p_set_type=>'SUB');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_PERSONS',p_extract_type => 'B',p_where_clause=>'per_id<=10',p_recursive_level=>3);
   -- Exclude reference data
   ds_utility_krn.include_tables(l_set_id, p_table_name=>'DEMO_COUNTRIES', p_extract_type=>'N');
   ds_utility_krn.include_tables(l_set_id, p_table_name=>'DEMO_CREDIT_CARD_TYPES', p_extract_type=>'N');
   ds_utility_krn.include_tables(l_set_id, p_table_name=>'DEMO_ORG_ENTITY_TYPES', p_extract_type=>'N');
   ds_utility_krn.include_tables(l_set_id, p_table_name=>'DEMO_STORES', p_extract_type=>'F');
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id,p_constraint_name=>'DEMO_ORD_PER_FK',p_percentage=>50);
   -- Include referential constraints
   ds_utility_krn.include_referential_cons(p_set_id=>l_set_id);
   -- Count records in source table
   ds_utility_krn.count_table_records(p_set_id=>l_set_id);
   -- Extract rowids of records
   ds_utility_krn.extract_data_set(l_set_id,p_final_commit=>TRUE);
end;
/

PAUSE Generate views?
CLEAR SCREEN
REM Create views to pre-view data set
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_V');
exec dbms_output.put_line('ok');

PAUSE Drop views?
CLEAR SCREEN
REM Drop views to pre-view data set
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_V');

PAUSE Generate graph and copy/paste result to https://dreampuf.github.io/GraphvizOnline/
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_table_name=>'DEMO%', p_full_schema=>'Y', p_show_legend=>'Y', p_show_aliases=>'Y', p_show_conf_columns=>'Y', p_show_stats=>'Y', p_show_config=>'Y'));
