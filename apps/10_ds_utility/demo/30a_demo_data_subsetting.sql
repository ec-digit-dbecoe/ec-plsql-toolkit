REM 
REM Data Set Utility Demo - Data Subsetting
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM 

REM Used APIs
REM . create_or_replace_data_set_def()
REM . include_tables()
REM . update_constraint_properties()
REM . include_referential_cons()
REM . count_table_records()
REM . extract_data_set()
REM . create_views()
REM . drop_views()
REM . graph_data_set()

PAUSE Configure data subsetting?
CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode

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
   ds_utility_krn.extract_data_set(p_set_id=>l_set_id,p_final_commit=>TRUE);
end;
/

PAUSE Generate views?
CLEAR SCREEN
REM Create views to pre-view data set
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_V');

@@18_demo_views_stats.sql

PAUSE Drop views?
CLEAR SCREEN
REM Drop views to pre-view data set
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_V');

PAUSE Generate graph and copy/paste result to https://dreampuf.github.io/GraphvizOnline/
CLEAR SCREEN

select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB') -- data set id
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'N' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'Y' -- show configuration?
  , p_show_stats=>'Y' -- show statistics?
  , p_show_conf_columns=>'Y' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'N' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'N' -- show column types?
  , p_show_constraints=>'N' -- show contraints and their columns?
  , p_show_indexes=>'N' -- show indexes and their columns?
  , p_show_triggers=>'N' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
  , p_show_prop_regexp=>'' -- show properties matching given regexp in tooltip, NULL=show all
  , p_hide_prop_regexp=>'' -- hide properties matching given regexp in tooltip, NULL=hide none
  , p_graph_att=>'' -- graph attributes e.g., splines=ortho
  , p_node_att=>'' -- node attributes e.g., style=filled
  , p_edge_att=>'' -- edge attributes e.g., arrowsize=2
  , p_main_att=>'' -- main subgraph attributes e.g., label=""
  , p_legend_att=>'' -- legend subgraph attributes e.g., label=""
));