create or replace PACKAGE doc_utility AS
---
-- Copyright (C) 2023 European Commission
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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
--
   ---
   -- Check assertion and return error message in user's language if false
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_msg_fra IN VARCHAR2
     ,p_err_msg_eng IN VARCHAR2 := NULL
     ,p_where IN VARCHAR2 := NULL
     ,p_p1 IN VARCHAR2 := NULL
     ,p_p2 IN VARCHAR2 := NULL
     ,p_p3 IN VARCHAR2 := NULL
     ,p_p4 IN VARCHAR2 := NULL
     ,p_p5 IN VARCHAR2 := NULL
     ,p_p6 IN VARCHAR2 := NULL
     ,p_p7 IN VARCHAR2 := NULL
     ,p_p8 IN VARCHAR2 := NULL
     ,p_p9 IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Set debug level
   ---
   PROCEDURE set_debug_level (
      p_level IN VARCHAR2
   )
   ;
   ---
   -- Exists table column?
   ---
   FUNCTION exists_table_column (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   RETURN BOOLEAN
   ;
   ---
   -- Check whether a fk exists between 2 tables
   ---
   FUNCTION exists_fk_between (
      p_src_table_name IN VARCHAR2
     ,p_tgt_table_name IN VARCHAR2
   )
   RETURN BOOLEAN
   ;
   ---
   -- Check if a column is already present in a condition or in output
   ---
   FUNCTION is_column_referenced (
      p_column IN VARCHAR2
    , p_condition IN VARCHAR2
    , pio_out IN sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   ;
   ---
   -- Add a comment if enabled
   ---
   FUNCTION add_comment (
      p_comment IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Set default
   ---
   PROCEDURE set_default (
      p_def_name IN VARCHAR2
    , p_def_value IN VARCHAR2
    , p_def_type IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Reset all defaults
   ---
   PROCEDURE reset_defaults
   ;
   ---
   -- Set variable
   ---
   PROCEDURE set_variable (
      p_var_name IN VARCHAR2
    , p_var_value IN VARCHAR2
    , p_var_type IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Reset all variables
   ---
   PROCEDURE reset_variables
   ;
   ---
   -- Get variable value
   ---
   FUNCTION get_variable (
      p_var_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Format a string
   ---
   FUNCTION format_string (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Merge text template with data
   ---
   PROCEDURE text_merge (
      p_in IN sys.dbms_sql.varchar2a
   )
   ;
   ---
   -- Merge text template with data
   -- Result is returned pipelined
   ---
   FUNCTION text_merge_pipelined (
      p_str IN VARCHAR2
   )
   RETURN sys.ODCIVarchar2List PIPELINED
   ;
   ---
   -- Merge docx template with data
   -- Template is provided as a BLOB
   -- Generated document is returned as a BLOB
   ---
   FUNCTION docx_merge (
      p_body IN BLOB
    , p_hdfo IN BLOB := NULL
   )
   RETURN BLOB
   ;
   ---
   -- Determine shortest path between 2 tables
   ---
   PROCEDURE do_dijkstra (
      p_source IN VARCHAR2
    , p_target IN VARCHAR2
    , p_dir IN VARCHAR2 := '-->'
   )
   ;
   ---
   -- Set edge weight for dijkstra search
   ---
   PROCEDURE set_edge_distance (
      p_fk_name IN VARCHAR2
    , p_distance IN BINARY_DOUBLE
    , p_dir IN VARCHAR2 := NULL -- '>-' or '-<'
   );
   ---
   -- Set preferred path
   ---
   PROCEDURE set_preferred_path (
      p_path IN VARCHAR2
    , p_distance IN BINARY_DOUBLE := 1 -- NULL to reset it to its default value
   )
   ;
   ---
   -- Reset preferred path
   ---
   PROCEDURE reset_preferred_paths
   ;
   ---
   -- Cleary cache containing queries
   ---
   PROCEDURE clear_query_cache;
END;
/
