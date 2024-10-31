CREATE OR REPLACE PACKAGE ds_utility_ext AS
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_utility_ext','public','   ;')
--#if 0
   ---
   -- Get the graph of a data set (in Graphviz's dot language)
   -- Usage: SELECT * FROM TABLE(ds_utility_krn.data_set_graph(...));
   -- Display: any online GraphViz editor (e.g., https:/ /dreampuf.github.io/GraphvizOnline)
   ---
   FUNCTION graph_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_table_name IN VARCHAR2 := NULL
    , p_full_schema IN VARCHAR2 := 'N'
    , p_aliases IN VARCHAR2 :=  'N'
    , p_legend IN VARCHAR2 := 'Y'
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Set data extraction/generation path
   ---
   PROCEDURE include_path (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_path IN VARCHAR2
   )
   ;
--#endif 0
END ds_utility_ext;
/
