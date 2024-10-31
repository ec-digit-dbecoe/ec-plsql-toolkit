CREATE OR REPLACE PACKAGE sql_utility
AUTHID DEFINER
AS
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
-- along with this program.  If not, see <https:
--
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','sql_utility','public','   ;')
--#if 0
   ---
   -- Set language
   ---
   PROCEDURE set_language (
      p_language IN VARCHAR2
   )
   ;
   ---
   -- Set maximum descriptor length
   ---
   PROCEDURE set_descr_max_len (
      p_max_descr_len IN INTEGER
   )
   ;
   ---
   -- Open and parse cursor
   ---
   FUNCTION open_and_parse_cursor (
      p_statement IN VARCHAR2
   )
   RETURN INTEGER
   ;
   ---
   -- Describe columns
   ---
   PROCEDURE describe_columns (
      p_cursor IN INTEGER
   )
   ;
   ---
   -- Define columns
   ---
   PROCEDURE define_columns (
      p_cursor IN INTEGER
   )
   ;
   ---
   -- Close cursor
   ---
   PROCEDURE close_cursor (
      p_cursor IN INTEGER
   )
   ;
   ---
   -- Format columns list
   ---
   FUNCTION format_columns_list (
      p_columns_list IN VARCHAR2
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
   ;
   ---
   -- Normalise columns list i.e. handle optional BUT keyword
   -- (extended syntax is: SELECT * BUT <columns_list> FROM <table>)
   -- wildcards in exclusion list columns are allowed
   ---
   FUNCTION normalise_columns_list (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Refresh internal cache
   ---
   PROCEDURE refresh_internal_cache (
      p_owner all_objects.owner%TYPE := NULL
     ,p_force IN BOOLEAN := FALSE -- force refresh
   )
   ;
   ---
   -- Show cache
   ---
   PROCEDURE show_cache
   ;
   ---
   -- Set select statement to be used for a given constraint
   ---
   PROCEDURE set_descr_select (
      p_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
    , p_descr_select IN VARCHAR2
   )
   ;
   ---
   -- Set descriptor column of a table
   ---
   PROCEDURE set_descr_column (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   ;
   ---
   -- Get column descriptor
   ---
   FUNCTION get_column_descr (
      p_cursor IN INTEGER -- context
    , p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
    , p_check_only IN VARCHAR2 := 'N' -- only check the existence of a descriptor i.e. no fetch
   )
   RETURN VARCHAR2
   ;
   ---
   -- Execute a SQL statement
   ---
   PROCEDURE execute (
      p_select IN VARCHAR2
    , p_tab_mode IN VARCHAR2 := NULL -- tabular mode (Y/N)?, default=Y
    , p_sep_char IN VARCHAR2 := NULL -- columns separator, default=tab
   )
   ;
   ---
   -- Test
   ---
   PROCEDURE test
   ;
   ---
   -- Load table descriptors
   ---
   PROCEDURE load_table_descriptors (
      p_owner IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Load constraint descriptors
   ---
   PROCEDURE load_constraint_descriptors (
      p_owner IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Load constraint descriptors
   ---
   PROCEDURE load_object_comments (
      p_owner IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Get object comment from cache in given language
   ---
   FUNCTION get_object_comment (
      p_object_type IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_language_code IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   --- Populate a ODCIVarchar2List with a string
   ---
   FUNCTION get_str_array (
      p_str IN VARCHAR2
     ,p_sep IN VARCHAR2 := ','
   )
   RETURN sys.odcivarchar2list
   ;
   ---
   --- Instanciate the package (run package initialisation code)
   ---
   PROCEDURE instanciate
   ;
--#endif 0
END;
/
