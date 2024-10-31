CREATE OR REPLACE PACKAGE ds_utility_ext AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
-- To generate the package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE ds_utility_ext', '-f');
--
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_utility_ext','public','   ;')
--#if 0
   ---
   -- Get the graph of a data set (in Graphviz's dot language)
   -- Usage: SELECT * FROM TABLE(ds_utility_krn.data_set_graph(...));
   -- Display: any online GraphViz editor (e.g., https:/ /dreampuf.github.io/GraphvizOnline)
   ---
   FUNCTION graph_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE   -- data set unique identifier, NULL means display only masked tables
    , p_table_name IN VARCHAR2 := NULL       -- name of tables (wildcards and regexp allowed), NULL means all
    , p_full_schema IN VARCHAR2 := 'N'       -- include all schema tables and constraints? Yes by default
    , p_show_aliases IN VARCHAR2 :=  'N'     -- show table aliases? No by default
    , p_show_legend IN VARCHAR2 := 'Y'       -- show legend? Yes by default
    , p_show_conf_columns IN VARCHAR2 := 'N' -- show configured columns (i.e., masked or generated)? No by default
    , p_show_cons_columns IN VARCHAR2 := 'N' -- show constrainted columns, No by default
    , p_show_ind_columns IN VARCHAR2 := 'N'  -- show indexed columns? No by default
    , p_show_all_columns IN VARCHAR2 := 'N'  -- show all columns? No by default
    , p_hide_dis_columns IN VARCHAR2 := 'N'  -- hide disabled or deleted masked columns? No by default
    , p_column_name IN VARCHAR2 := NULL      -- name of columns to include (wildcards and regexp allowed), NULL means all
    , p_show_column_keys IN VARCHAR2 := 'N'  -- show column keys (Primary, Unique, Foreign, Index)?
    , p_show_column_types IN VARCHAR2 := 'N' -- show column data types? No by default
    , p_show_stats IN VARCHAR2 := 'Y'        -- show statistics (number of generated/extracted rows), Yes by default
    , p_show_config IN VARCHAR2 := 'N'       -- show configuration data (only what can fit on the diagram), No by default
    , p_show_constraints IN VARCHAR2 := 'N'  -- show table constraints? No by default
    , p_show_indexes IN VARCHAR2 := 'N'      -- show table indexes? No by default
    , p_show_triggers IN VARCHAR2 := 'N'     -- show table triggers? No by default
    , p_show_all_props IN VARCHAR2 := 'N'    -- show all properties in tooltips? By default, only those not shown on diagram
    , p_show_prop_regexp IN VARCHAR2 := ''   -- show properties matching given regexp in tooltip, NULL means show all
    , p_hide_prop_regexp IN VARCHAR2 := ''   -- hide properties matching given regexp in tooltip, NULL means hide none
    , p_graph_att IN VARCHAR2 := ''          -- graph attributes e.g., splines=ortho
    , p_node_att IN VARCHAR2 := ''           -- node attributes
    , p_edge_att IN VARCHAR2 := ''           -- edge attributes
    , p_main_att IN VARCHAR2 := ''           -- main subgraph attributes e.g., label="My graph"
    , p_legend_att IN VARCHAR2 := ''    -- legend subgraph attributes e.g., label=""
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Parse and execute DEGPL code
   ---
   PROCEDURE execute_degpl (
      p_code IN VARCHAR2 -- DEGPL path to include
    , p_table_name IN VARCHAR2 := NULL -- Table filter (only used when searching for table aliases using naming conventions)
    , p_commit IN BOOLEAN := FALSE
   )
   ;
   ---
   -- Set data extraction/generation path (DEPRECATED, replaced with execute_degpl())
   ---
   PROCEDURE include_path (
      p_set_id IN ds_data_sets.set_id%TYPE -- Data set id
    , p_path IN VARCHAR2 -- DEGPL path to include
    , p_table_name IN VARCHAR2 := NULL -- Table filter (only used when searching for table aliases using naming conventions)
    , p_commit IN BOOLEAN := FALSE
   )
   ;
--#endif 0
END ds_utility_ext;
/
