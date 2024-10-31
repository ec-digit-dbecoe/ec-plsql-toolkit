REM 
REM Data Set Utility Demo - Data Set Graph Visualisation
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

REM Diagram for Synthetic Data Generation
REM Only generated columns are displayed.
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') -- data set id
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

REM Diagram for Data Subsetting (with masking if any)
REM Only masked columns are displayed.
PAUSE
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

REM Diagram for Sensitive Data Discovery (with masks if any)
REM Only sensitive or masked columns are displayed.
PAUSE
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

REM Diagram for Change Data Capture
PAUSE
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP') -- data set id
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'Y' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'Y' -- show configuration?
  , p_show_stats=>'Y' -- show statistics?
  , p_show_conf_columns=>'N' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'N' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'N' -- show column types?
  , p_show_constraints=>'N' -- show contraints and their columns?
  , p_show_indexes=>'N' -- show indexes and their columns?
  , p_show_triggers=>'Y' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
  , p_show_prop_regexp=>'' -- show properties matching given regexp in tooltip, NULL=show all
  , p_hide_prop_regexp=>'' -- hide properties matching given regexp in tooltip, NULL=hide none
  , p_graph_att=>'' -- graph attributes e.g., splines=ortho
  , p_node_att=>'' -- node attributes e.g., style=filled
  , p_edge_att=>'' -- edge attributes e.g., arrowsize=2
  , p_main_att=>'' -- main subgraph attributes e.g., label=""
  , p_legend_att=>'' -- legend subgraph attributes e.g., label=""
));

REM Data Structure Diagram of DEMO tables (not related to any data set)
REM All table columns, constraints and indexes are displayed.
PAUSE
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>NULL
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'Y' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'N' -- show configuration?
  , p_show_stats=>'N' -- show statistics?
  , p_show_conf_columns=>'N' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'Y' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'Y' -- show column types?
  , p_show_constraints=>'Y' -- show contraints and their columns?
  , p_show_indexes=>'Y' -- show indexes and their columns?
  , p_show_triggers=>'Y' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
  , p_show_prop_regexp=>'' -- show properties matching given regexp in tooltip, NULL=show all
  , p_hide_prop_regexp=>'.*' -- hide properties matching given regexp in tooltip, NULL=hide none
  , p_graph_att=>'' -- graph attributes e.g., splines=ortho
  , p_node_att=>'style="box, filled"' -- node attributes e.g., style=filled
  , p_edge_att=>'' -- edge attributes e.g., arrowsize=2
  , p_main_att=>'' -- main subgraph attributes e.g., label=""
  , p_legend_att=>'' -- legend subgraph attributes e.g., label=""
));
