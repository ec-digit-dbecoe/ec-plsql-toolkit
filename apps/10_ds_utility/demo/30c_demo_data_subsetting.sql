REM 
REM Data Set Utility Demo - Data Subsetting
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM Script for:
REM - Configuration based on DEGPL language
REM - Tool installed in a dedicated/central schema
REM - Data model in another schema of the same db
REM 

PROMPT Configure data set?
CLEAR SCREEN
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   ds_utility_krn.set_source_schema('APP_DBCC_D');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_SUB', p_set_type=>'SUB');
   ds_utility_ext.include_path(p_set_id=>l_set_id,p_path=>q'£
   demo*;demo_dual/x;sto/f;cnt/n;cct/n;oet/n;per/b[where="per_id<=10"]=<3*;per~>[percent=50]ord;!*^>-0*;
   £');
   ds_utility_krn.count_table_records(p_set_id=>l_set_id);
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