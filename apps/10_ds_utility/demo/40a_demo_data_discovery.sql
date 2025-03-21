REM 
REM Data Set Utility Demo - Sensitive Data Discovery
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM 

REM Used APIs
REM . discover_sensitive_data()
REM . graph_data_set()

CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode

PAUSE Discover sensitive data?
exec ds_utility_krn.set_message_filter('EWI');
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
exec ds_utility_krn.discover_sensitive_data(p_rows_sample_size=>200, p_full_schema=>TRUE, p_table_name=>'DEMO%', p_commit=>TRUE);

PAUSE Check results?
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>NULL -- show only 
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'Y' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'Y' -- show configuration?
  , p_show_stats=>'Y' -- show statistics?
  , p_show_conf_columns=>'Y' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'Y' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'Y' -- show column types?
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