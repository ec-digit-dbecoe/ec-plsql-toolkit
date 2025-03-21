CREATE OR REPLACE PACKAGE ds_utility_krn
AUTHID CURRENT_USER
AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License as published by
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
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE ds_utility_krn', '-f');
   ---
   -- Read data from a CLOB stored in a CSV data set
   -- Usage: SELECT * FROM TABLE(ds_read_csv_clob(:set_id));
   ---
   FUNCTION read_csv_clob (
      p_set_id        IN NUMBER                 -- CSV data set id
   )
   RETURN anydataset pipelined
   USING ds_read_csv_clob
   ;
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_utility_krn','public','   ;')
--#if 0
   ---
   -- Similar to Oracle REPLACE but case insensitive and exact words
   ---
   FUNCTION replace_i (
      p_string IN VARCHAR2
    , p_search IN VARCHAR2
    , p_with IN VARCHAR2 := ''
   )
   RETURN VARCHAR2
   ;
   ---
   -- Set message filter
   ---
   PROCEDURE set_message_filter (
      p_msg_mask IN VARCHAR2
   )
   ;
   ---
   -- Set log filter
   ---
   PROCEDURE set_log_filter (
      p_log_mask IN VARCHAR2
   )
   ;
/**
* Define name of schema containing data to extract. This allows the data
* set utility to be installed in a separate schema whilst being able
* to access objects of another schema.
* @param p_owner object owner
*/
   PROCEDURE set_source_schema (
      p_owner IN sys.all_objects.owner%TYPE
   )
   ;
   FUNCTION set_source_schema (
      p_owner IN sys.all_objects.owner%TYPE
   )
   RETURN VARCHAR2
   ;
/**
* Turn test mode on/off. In test mode, DDL are displayed instead of being executed.
* @param p_test_mode test mode (TRUE/FALSE, NULL to reset to default/FALSE)
*/
   PROCEDURE set_test_mode (
      p_test_mode IN BOOLEAN := FALSE
   )
   ;
/**
* Enable/disable data masking.
* @param p_mask_data (TRUE/FALSE, NULL to reset to default/TRUE)
*/
   PROCEDURE set_masking_mode (
      p_mask_data IN BOOLEAN := TRUE -- perform data masking?
   )
   ;
/**
* Enable/disable encryption of tokenized values (DS_TOKENS.VALUE)
* @param p_encrypt_tokenized_values (TRUE/FALSE, NULL to reset to default/TRUE)
*/
   PROCEDURE set_encrypt_tokenized_values (
      p_encrypt_tokenized_values IN BOOLEAN := TRUE -- perform data masking?
   )
   ;
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_like_pattern (
      p_alias_regexp_like_pattern IN VARCHAR2
   )
   ;
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_replace_pattern (
      p_alias_regexp_replace_pattern IN VARCHAR2
   )
   ;
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_constraint_type (
      p_alias_constraint_type IN VARCHAR2
   )
   ;
/**
* Turn time display on/off. Time is displayed in debug messages only.
* @param p_show_time show time (TRUE/FALSE, default is FALSE)
* @param p_time_mask format mask used to display time (default is DD/MM/YYYY HH24:MI:SS)
*/
   PROCEDURE show_time (
      p_show_time IN BOOLEAN
     ,p_time_mask IN VARCHAR2 := NULL
   )
   ;
/**
* Delete output of data set utility
*/
   PROCEDURE delete_output
   ;
/**
* Put a text on the specified output
* Split lines over 255 characters
*/
   PROCEDURE put (
      p_text IN VARCHAR2
     ,p_new_line IN BOOLEAN := FALSE
     ,p_output IN VARCHAR2 := 'DBMS_OUTPUT' -- or DS_OUTPUT
   )
   ;
   ---
   -- Show a message
   ---
   PROCEDURE show_message (
      p_type IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL, Result/Rowcount
     ,p_text IN VARCHAR2 -- message text
     ,p_new_line IN BOOLEAN := TRUE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Start a new run and returns its id
   ---
   FUNCTION start_run (
      p_routine_name ds_runs.routine_name%TYPE
    , p_params ds_runs.params%TYPE := NULL
    , p_set_id ds_runs.set_id%TYPE := NULL
   )
   RETURN ds_runs.run_id%TYPE
   ;
   ---
   -- Start a new run
   ---
   PROCEDURE start_run (
      p_routine_name ds_runs.routine_name%TYPE
    , p_params ds_runs.params%TYPE := NULL
    , p_set_id ds_runs.set_id%TYPE := NULL
   )
   ;
   ---
   -- Start a new run
   ---
   PROCEDURE stop_run (
      p_routine_name ds_runs.routine_name%TYPE
    , p_exit_code ds_runs.exit_code%TYPE := 0
    , p_error_msg ds_runs.error_msg%TYPE := NULL
    , p_run_id ds_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Execute dynamic SQL statement
   ---
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   )
   RETURN INTEGER
   ;
   ---
   -- Execute dynamic SQL statement
   ---
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   )
   ;
   ---
   -- Load SQL and CSV data sets in cache
   ---
   PROCEDURE load_ds (
      p_set_name ds_data_sets.set_name%TYPE := NULL
    , p_col_name IN VARCHAR2 := NULL
    , p_what IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Check if a value is in a data set
   ---
   FUNCTION is_value_in_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_value IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y for Yes, N for No, NULL if value is NULL
   ;
   ---
   -- Check if a value is in a data set
   ---
   FUNCTION is_value_in_data_set (
      p_set_col_name IN VARCHAR2
    , p_col_value IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y for Yes, N for No, NULL if value is NULL
   ;
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_len  IN sys.user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_col_name IN ds_data_sets.set_name%TYPE
    , p_col_len  IN sys.user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get a column value from a row selected at random from a given table
   -- A filter (where clause) may be specified
   -- A weight column may be specified to follow its distribution
   -- Cursor remains open to cycle through all values except if requested
   -- Cursors that remained opened can be closed by calling the close_cursors() procedure
   -- To get the ROWID instead of a column value, specify ROWID$ for column name
   --
   ---
   FUNCTION random_value_from_table (
      p_tab_name IN user_tables.table_name%TYPE -- table name
    , p_col_name IN user_tab_columns.column_name%TYPE -- column name
    , p_col_len IN user_tab_columns.data_length%TYPE := NULL -- maximum length
    , p_where IN VARCHAR2 := NULL -- filter
    , p_weight IN user_tab_columns.column_name%TYPE := NULL -- name of column holding weight
    , p_cycle IN VARCHAR2 := 'Y' -- cycle through all values by keeping cursor open
    , p_seed IN VARCHAR2 := NULL -- for deterministic result
   )
   RETURN VARCHAR2
   ;
   ---
   -- Close opened cursors
   ---
   PROCEDURE close_cursors
   ;
   ---
   -- Show data sets in cache
   ---
   PROCEDURE show_ds (
      p_set_name ds_data_sets.set_name%TYPE := NULL
    , p_col_name IN VARCHAR2 := NULL
   )
   ;
/**
* Create a new data set definition and return its id.
* Each data set is also identified by a unique name.
* The visible flag permits to show/hide the data set in/from the views used
* to preview data sets as well as security policies used to export them.
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
   ;
/**
* Create a new data set definition.
* Each data set is also identified by a unique name.
* The visible flag permits to show/hide the data set in/from the views used
* to preview data sets as well as security policies used to export them.
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   ;
/**
* Clone an existing data set definition and return its id
* @param p_set_id       id of data set to clone
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE
--     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
   ;
/**
* Clone an existing data set definition.
* @param p_set_id       id of data set to clone
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   ;
/**
* Format a column list to get a proper layout
* @param p_columns_list    array of column names
* @param p_left_tab left   indentation
* @param p_indent_first_line indent first line (Y/N)?
* @param p_columns_per_line number of columns per line
*/
   FUNCTION format_columns_list (
      p_columns_list IN ds_tables.columns_list%TYPE
     ,p_left_tab IN INTEGER := 3
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN ds_tables.columns_list%TYPE
   ;
   ---
   -- Get next value of an in-memory sequence
   ---
   FUNCTION in_mem_seq_nextval (
      p_full_column_name IN VARCHAR2
   )
   RETURN PLS_INTEGER
   ;
/**
* Return the token associated with a given value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_value        value to be tokenized
* @return               token associated with the value
*/
   FUNCTION get_token_from_value (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_value ds_tokens.value%TYPE
   )
   RETURN ds_tokens.token%TYPE
   ;
/**
* Return the token associated with a given value
* @param p_msk_id       mask id
* @param p_value        value to be tokenized
* @return               token associated with the value
*/
   FUNCTION get_token_from_value (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_value ds_tokens.value%TYPE
   )
   RETURN ds_tokens.token%TYPE
   ;
/**
* Return the value associated with a token
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_token        token
* @return               value associated with the token
*/
   FUNCTION get_value_from_token (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_token ds_tokens.token%TYPE
   )
   RETURN ds_tokens.value%TYPE
   ;
/**
* Return the value associated with a token
* @param p_msk_id       mask id
* @param p_token        token
* @return               value associated with the token
*/
   FUNCTION get_value_from_token (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_token ds_tokens.token%TYPE
   )
   RETURN ds_tokens.value%TYPE
   ;
/**
* Set the token associated with a given value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_token        token
* @param p_value        value
*/
   PROCEDURE set_token_for_value (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_value ds_tokens.value%TYPE
    , p_token ds_tokens.token%TYPE
   )
   ;
/**
* Set the token associated with a given value
* @param msk_id         mask id
* @param p_token        token
* @param p_value        value
*/
   PROCEDURE set_token_for_value (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_value ds_tokens.value%TYPE
    , p_token ds_tokens.token%TYPE
   )
   ;
/**
* Return list of columns of a given table
* @param p_table_name table name
* @param p_column_name column name filter
* @param p_nullable nullable property filter
*/
   FUNCTION get_table_columns (
      p_table_name IN sys.all_tab_columns.table_name%TYPE
     ,p_column_name IN sys.all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN sys.all_tab_columns.nullable%TYPE := NULL -- filter
   )
   RETURN ds_tables.columns_list%TYPE
   ;
/**
* Return list of columns of a given constraint
* @param p_constraint_name constraint name
* @param p_sorting_order sorting order: P)osition or N)ame
*/
   FUNCTION get_constraint_columns (
      p_constraint_name IN sys.all_cons_columns.constraint_name%TYPE
    , p_sorting_order IN VARCHAR2 := 'P' -- P)osition or N)ame
    , p_table_alias IN VARCHAR2 := NULL -- table alias prefix
   )
   RETURN ds_tables.columns_list%TYPE
   ;
/**
* Return list of columns of a given index
* @param p_index_name index name
*/
   FUNCTION get_index_columns (
      p_index_name IN sys.all_ind_columns.index_name%TYPE
   )
   RETURN ds_tables.columns_list%TYPE
   ;
/**
* Get pk name of a given table
* @param p_table_name table name
* @return pk name
*/
   FUNCTION get_table_pk (
      p_table_name IN sys.all_constraints.table_name%TYPE
   ) RETURN VARCHAR2
   ;
/**
* Normalise columns list i.e. handle optional BUT keyword
* (extended syntax is: SELECT * BUT <columns_list> FROM <table>)
* wildcards in exclusion list columns are allowed
* @param p_table_name   table name
* @param p_columns_list array of column names
* @return list of columns
*/
   FUNCTION normalise_columns_list (
      p_table_name IN ds_tables.table_name%TYPE
     ,p_columns_list IN ds_tables.columns_list%TYPE
   )
   RETURN ds_tables.columns_list%TYPE
   ;
/**
* Get id of last created data set definition.
* @return               id of last created data set
*/
   FUNCTION get_last_data_set_def
   RETURN ds_data_sets.set_id%TYPE
   ;
/**
* Get id of the data set having a given name.
* @param p_set_name name of data set to search for
* @return               id of data set having given name
*/
   FUNCTION get_data_set_def_by_name (
      p_set_name IN ds_data_sets.set_name%TYPE
   )
   RETURN ds_data_sets.set_id%TYPE
   ;
/**
* Delete data set rowids previously extracted
* @param p_set_id       id of data set to clear, NULL for all
* @param p_table_name   name of table, NULL for all
*/
   PROCEDURE delete_data_set_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- Null for ALL
    , p_table_name IN ds_tables.table_name%TYPE := NULL -- Null for ALL
   )
   ;
/**
* Delete identifiers
* @param p_msk_id       mask id, NULL for all
* @param p_table_name   table name, NULL for all
* @param p_column_name  column name, NULL for all
*/
   PROCEDURE delete_identifiers (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
   )
   ;
/**
* Delete tokens generated for tokenization data masking
* @param p_table_name   name of table, NULL for all
* @param p_column_name  name of column, NULL for all
*/
   PROCEDURE delete_tokens (
      p_table_name  IN ds_utility_var.table_name := NULL
    , p_column_name IN ds_utility_var.column_name := NULL
   )
   ;
/**
* Delete tokens generated for tokenization data masking
* @param p_msk_id   mask id, NULL for all
*/
   PROCEDURE delete_tokens (
      p_msk_id IN ds_tokens.msk_id%TYPE
   )
   ;
/**
* Check if a capture forwarding job exists for the given data set
* @param p_set_id    id of the data set
* @return true if job exists, false otherwize
*/
  FUNCTION capture_forwarding_job_exists (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   RETURN BOOLEAN
   ;
/**
* Create a job for captured operations forwarding
* @param p_set_id    id of the data set
*/
   PROCEDURE create_capture_forwarding_job (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ;
/**
* Drop the job created for captured operations forwarding
* @param p_set_id    id of the data set
*/
   PROCEDURE drop_capture_forwarding_job (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ;
/**
* Clear content of given data set definition. This will delete the data set
* definition (tables and constraints) as well as extracted rowids.
* After this operation, data set definition still exists but is empty.
* @param p_set_id       id of data set to clear, NULL for all
*/
   PROCEDURE clear_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- Null for ALL
   )
   ;
/**
* Create or replace a data set definition and return its id
*/
   FUNCTION create_or_replace_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
   ;
/**
* Create or replace a data set definition
*/
   PROCEDURE create_or_replace_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   ;
/**
* Delete the given data set definition including its content.
* @param p_set_id       id of data set to delete, NULL for all
*/
   PROCEDURE delete_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL
   )
   ;
/**
* Update data set definition properties. Set name and visible flag of given
* data set definition(s). Properties whose supplied value is NULL stay unchanged
* @param p_set_id       data set id, NULL for all
* @param p_set_name     data set name
* @param p_visible_flag visible flag
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE update_data_set_def_properties (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- NULL means all data sets
     ,p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := '~'
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := '~'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := '~'
     ,p_capture_flag IN ds_data_sets.capture_flag%TYPE := '~'
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := '~'
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := '~'
     ,p_params IN ds_data_sets.params%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
   ;
/**
* Count records of all tables of a data set. By default, source row count
* is taken from database statistics that are normally computed on a daily
* basis. When statistics are not available or not up to date, table records
* can be counted by invoking this procedure.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE count_table_records (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
    , p_commit IN BOOLEAN := FALSE
   )
   ;
   ---
   -- Get table alias (from pk)
   ---
   FUNCTION gen_table_alias (
      p_table_name IN sys.all_tables.table_name%TYPE
     ,p_table_id IN ds_tables.table_id%TYPE := NULL
   )
   RETURN VARCHAR2
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Insert a new table
   ---
   PROCEDURE insert_table (
      r_tab IN OUT ds_tables%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Create a new constraint
   ---
   PROCEDURE insert_constraint (
      r_con IN OUT ds_constraints%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Get a table record based on its name
   ---
   PROCEDURE get_table (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE
     ,r_tab OUT ds_tables%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Get alias
   ---
   PROCEDURE get_aliases (
      r_tab_mst IN ds_tables%ROWTYPE
     ,r_tab_det IN ds_tables%ROWTYPE
     ,p_out_master_alias OUT ds_tables.table_alias%TYPE
     ,p_out_detail_alias OUT ds_tables.table_alias%TYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
   ---
   -- Build join clause given fk
   ---
   FUNCTION build_join_clause (
      p_master_table_name IN VARCHAR2
     ,p_detail_table_name IN VARCHAR2
     ,p_fk_name IN sys.all_constraints.constraint_name%TYPE
   )
   RETURN VARCHAR2
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
/**
* Include some tables in the given data set. Add tables whose name matches
* the given pattern to the data set definition and set their properties
* to the values supplied. Properties can also be set at a later time using
* set_table_properties().
* @param p_set_id       data set id
* @param p_table_name   name of tables to include
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filtering condition
* @param p_percentage   percentage of rows to extract
* @param p_row_limit    maximum number of rows to extract
* @param p_recursive_level include detail tables up to the given depth
* @param p_order_by_clause sorting order
* @param p_columns_list list of columns
* @param p_det_table_name   pattern for detail tables to include
* @param p_optimize_flag    optimize details discovery (Y/N)
*/
   PROCEDURE include_tables (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE
     ,p_extract_type IN ds_tables.extract_type%TYPE := NULL
     ,p_where_clause IN ds_tables.where_clause%TYPE := NULL
     ,p_percentage IN ds_tables.percentage%TYPE := NULL
     ,p_row_limit IN ds_tables.row_limit%TYPE := NULL
     ,p_recursive_level IN INTEGER := NULL -- 0=infinite, >0=maximum
     ,p_order_by_clause IN ds_tables.order_by_clause%TYPE := NULL
     ,p_columns_list IN ds_tables.columns_list%TYPE := NULL
     ,p_det_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_optimize_flag IN VARCHAR2 := NULL
   )
   ;
/**
* Exclude some tables from the given data set. Remove tables whose name matches
* the given pattern from the data set definition.
* @param p_set_id       data set id
* @param p_table_name   name of tables to exclude
*/
   PROCEDURE exclude_tables (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
   )
   ;
/**
* Exclude some constraints from the given data set. Remove constraints
* whose name matches the given pattern from the data set definition.
* @param p_set_id       data set id
* @param p_constraint_name   name of constraints to exclude
* @param p_cardinality constraint cardinality
* @param p_md_cardinality_ok master/detail cardinality ok
* @param p_md_optionality_ok master/detail optionality ok
* @param p_md_uid_ok master/detail unique identifier ok
*/
   PROCEDURE exclude_constraints (
      p_set_id IN ds_constraints.set_id%TYPE
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_cardinality IN ds_constraints.CARDINALITY%TYPE := NULL
     ,p_md_cardinality_ok IN ds_constraints.md_cardinality_ok%TYPE := NULL
     ,p_md_optionality_ok IN ds_constraints.md_optionality_ok%TYPE := NULL
     ,p_md_uid_ok IN ds_constraints.md_uid_ok%TYPE := NULL
   )
   ;
/**
* Update table properties. Properties whose supplied value is NULL stay unchanged
* @param p_set_id data set id
* @param p_table_name of table(s)
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filter condition
* @param p_order_by_clause sorting order
* @param p_columns_list list of columns
* @param p_export_mode mode of export (I=Insert, U=Update, M=Upsert)
* @param p_source_schema schema hosting source table
* @param p_source_db_link database link to be used to access source table
* @param p_target_schema schema hosting target table
* @param p_target_db_link database link to be used to access target table
* @param p_target_table_name name of the table in target schema
* @param p_user_column_name name of column used to determine user
*/
   PROCEDURE update_table_properties (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_extract_type IN ds_tables.extract_type%TYPE := '~'
     ,p_where_clause IN ds_tables.where_clause%TYPE := '~'
     ,p_percentage IN ds_tables.percentage%TYPE := -1
     ,p_row_limit IN ds_tables.row_limit%TYPE := -1
     ,p_row_count IN ds_tables.row_count%TYPE := -1
     ,p_order_by_clause IN ds_tables.order_by_clause%TYPE := '~'
     ,p_columns_list IN ds_tables.columns_list%TYPE := '~'
     ,p_export_mode IN ds_tables.export_mode%TYPE := '~'
     ,p_source_schema IN ds_tables.source_schema%TYPE := '~'
     ,p_source_db_link IN ds_tables.source_db_link%TYPE := '~'
     ,p_target_schema IN ds_tables.target_schema%TYPE := '~'
     ,p_target_db_link IN ds_tables.target_db_link%TYPE := '~'
     ,p_target_table_name IN ds_tables.target_table_name%TYPE := '~'
     ,p_user_column_name IN ds_tables.user_column_name%TYPE := '~'
     ,p_batch_size IN ds_tables.batch_size%TYPE := -1
     ,p_tab_seq IN ds_tables.tab_seq%TYPE := -1
     ,p_gen_view_name IN ds_tables.gen_view_name%TYPE := '~'
     ,p_pre_gen_code IN ds_tables.pre_gen_code%TYPE := '~'
     ,p_post_gen_code IN ds_tables.post_gen_code%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
   ;
/**
* Update constraint properties. Properties whose given value is NULL stay
* unchanged.
* @param p_set_id data set id
* @param p_constraint_name name of constraint(s)
* @param p_cardinality constraint cardinality
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filter condition
* @param p_percentage percentage of rows to extract
* @param p_row_limit maximum number of rows to extract
* @param p_order_by_clause sorting order
*/
   PROCEDURE update_constraint_properties (
      p_set_id IN ds_constraints.set_id%TYPE
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_cardinality IN ds_constraints.CARDINALITY%TYPE := NULL
     ,p_extract_type IN ds_constraints.extract_type%TYPE := '~'
     ,p_where_clause IN ds_constraints.CARDINALITY%TYPE := '~'
     ,p_percentage IN ds_constraints.percentage%TYPE := -1
     ,p_row_limit IN ds_constraints.row_limit%TYPE := -1
     ,p_min_rows IN ds_constraints.min_rows%TYPE := -1
     ,p_max_rows IN ds_constraints.max_rows%TYPE := -1
     ,p_level_count IN ds_constraints.level_count%TYPE := -1
     ,p_order_by_clause IN ds_constraints.order_by_clause%TYPE := '~'
     ,p_deferred IN ds_constraints.deferred%TYPE := '~'
     ,p_batch_size IN ds_constraints.batch_size%TYPE := -1
     ,p_con_seq IN ds_constraints.con_seq%TYPE := -1
     ,p_gen_view_name IN ds_constraints.gen_view_name%TYPE := '~'
     ,p_pre_gen_code IN ds_constraints.pre_gen_code%TYPE := '~'
     ,p_post_gen_code IN ds_constraints.post_gen_code%TYPE := '~'
     ,p_src_filter IN ds_constraints.src_filter%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
   ;
/**
* Insert columns for a given table
* @param p_set_id data set id
* @param p_table_name table name
* @param p_gen_type default generation type
* @param p_null_value_pct percentage of NULL value
* @param p_null_value_pct condition to force NULL value
*/
   PROCEDURE insert_table_columns (
      p_set_id IN ds_tables.set_id%TYPE
    , p_table_name IN ds_tables.table_name%TYPE := NULL
    , p_gen_type IN ds_tab_columns.gen_type%TYPE := NULL
    , p_null_value_pct IN ds_tab_columns.null_value_pct%TYPE := NULL
    , p_null_value_condition IN ds_tab_columns.null_value_condition%TYPE := NULL
   )
   ;
/**
* Update table column properties
*/
   PROCEDURE update_table_column_properties (
      p_set_id IN ds_tables.set_id%TYPE
    , p_table_name IN ds_tables.table_name%TYPE
    , p_col_name IN ds_tab_columns.col_name%TYPE := '~'
    , p_col_seq IN ds_tab_columns.col_seq%TYPE := -1
    , p_gen_type IN ds_tab_columns.gen_type%TYPE := '~'
    , p_params IN ds_tab_columns.params%TYPE := '~'
    , p_null_value_pct IN ds_tab_columns.null_value_pct%TYPE := -1
    , p_null_value_condition IN ds_tab_columns.null_value_condition%TYPE := '~'
    , p_raise_error_when_no_update BOOLEAN := TRUE
   )
   ;
/**
* Clone table column properties from one data set to another
*/
   PROCEDURE clone_table_column_properties (
      p_set_id_src ds_data_sets.set_id%TYPE
    , p_set_id_tgt ds_data_sets.set_id%TYPE
    , p_table_name ds_tables.table_name%TYPE := NULL
    , p_col_name ds_tab_columns.col_name%TYPE := NULL
   )
   ;
   PROCEDURE optimize_referential_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
   ;
/**
* Include referential constraints (N-1) in the given data set. Recursively add all
* tables linked via many-to-one relationships to the data set definition.
* This will guarantee that the data set will be consistent (no foreign key violation).
* @param p_set_id       data set id
* @param p_table_name   name of table(s) to consider
* @param p_constraint_name      name of constraint(s) to consider
*/
   PROCEDURE include_referential_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_extract_type IN ds_tables.extract_type%TYPE := NULL
   )
   ;
/**
* Include master/detail relationships (1-N) in the given data set.
* Add tables linked via 1-N relationships to the data set definition.
* @param p_set_id       data set id
* @param p_master_table_name    name of master table(s)
* @param p_detail_table_name     name of detail table(s)
* @param p_constraint_name      name of constraint(s)
* @param p_extract_type type of extract (B=Base, P=Part, N=None)
* @param p_where_clause         filter condition
* @param p_percentage   percentage of rows to extract
* @param p_row_limit    maximum number of rows to extract
*/
   PROCEDURE include_master_detail_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_master_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_detail_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_extract_type IN ds_constraints.extract_type%TYPE := NULL
     ,p_where_clause IN ds_constraints.where_clause%TYPE := NULL
     ,p_percentage IN ds_constraints.percentage%TYPE := NULL
     ,p_row_limit IN ds_constraints.row_limit%TYPE := NULL
   )
   ;
   ---
   -- Insert a pattern
   ---
   PROCEDURE insert_pattern (
      p_pat_name ds_patterns.pat_name%TYPE
    , p_pat_cat ds_patterns.pat_cat%TYPE := NULL
    , p_pat_seq ds_patterns.pat_seq%TYPE := NULL
    , p_col_name_pattern ds_patterns.col_name_pattern%TYPE := NULL
    , p_col_comm_pattern ds_patterns.col_comm_pattern%TYPE := NULL
    , p_col_data_pattern ds_patterns.col_data_pattern%TYPE := NULL
    , p_col_data_set_name ds_patterns.col_data_set_name%TYPE := NULL
    , p_col_data_type ds_patterns.col_data_type%TYPE := NULL
    , p_col_data_min_pct ds_patterns.col_data_min_pct%TYPE := NULL
    , p_col_data_min_cnt ds_patterns.col_data_min_cnt%TYPE := NULL
    , p_logical_operator ds_patterns.logical_operator%TYPE := NULL
    , p_system_flag ds_patterns.system_flag%TYPE := NULL
    , p_disabled_flag ds_patterns.disabled_flag%TYPE := NULL
    , p_msk_type ds_patterns.msk_type%TYPE := NULL
    , p_msk_params ds_patterns.msk_params%TYPE := NULL
    , p_remarks ds_patterns.remarks%TYPE := NULL
   )
   ;
   ---
   -- Update pattern(s) properties
   ---
   PROCEDURE update_pattern_properties (
        p_pat_name ds_patterns.pat_name%TYPE := NULL
      , p_pat_cat ds_patterns.pat_cat%TYPE := '~'
      , p_pat_seq ds_patterns.pat_seq%TYPE := -1
      , p_col_name_pattern ds_patterns.col_name_pattern%TYPE := '~'
      , p_col_comm_pattern ds_patterns.col_comm_pattern%TYPE := '~'
      , p_col_data_pattern ds_patterns.col_data_pattern%TYPE := '~'
      , p_col_data_set_name ds_patterns.col_data_set_name%TYPE := '~'
      , p_col_data_type ds_patterns.col_data_type%TYPE := '~'
      , p_col_data_min_pct ds_patterns.col_data_min_pct%TYPE := -1
      , p_col_data_min_cnt ds_patterns.col_data_min_cnt%TYPE := -1
      , p_logical_operator ds_patterns.logical_operator%TYPE := '~'
      , p_system_flag ds_patterns.system_flag%TYPE := '~'
      , p_disabled_flag ds_patterns.disabled_flag%TYPE := '~'
      , p_msk_type ds_patterns.msk_type%TYPE := '~'
      , p_msk_params ds_patterns.msk_params%TYPE := '~'
      , p_remarks ds_patterns.remarks%TYPE := '~'
      , p_raise_error_when_no_update BOOLEAN := TRUE
)
   ;
   ---
   -- Delete pattern(s)
   ---
   PROCEDURE delete_pattern (
        p_pat_name ds_patterns.pat_name%TYPE := NULL
   )
   ;
   ---
   -- Insert mask(s) for each matching table and column (Oracle wildcard allowed)
   ---
   PROCEDURE insert_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := NULL -- means all
    , p_sensitive_flag ds_masks.sensitive_flag%TYPE := NULL
    , p_disabled_flag ds_masks.disabled_flag%TYPE := NULL
    , p_locked_flag ds_masks.locked_flag%TYPE := NULL
    , p_deleted_flag ds_masks.deleted_flag%TYPE := NULL
    , p_msk_type ds_masks.msk_type%TYPE := NULL
    , p_shuffle_group ds_masks.shuffle_group%TYPE := NULL
    , p_partition_bitmap ds_masks.partition_bitmap%TYPE := NULL
    , p_params ds_masks.params%TYPE := NULL
    , p_options ds_masks.options%TYPE := NULL
    , p_pat_cat ds_masks.pat_cat%TYPE := NULL
    , p_pat_name ds_masks.pat_name%TYPE := NULL
    , p_remarks ds_masks.remarks%TYPE := NULL
    , p_values_sample ds_masks.values_sample%TYPE := NULL
    , p_raise_error_when_no_insert BOOLEAN := TRUE
   )
   ;
   ---
   -- Update mask(s) properties for matching tables and columns (Oracle wildcards allowed)
   ---
   PROCEDURE update_mask_properties (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := '~'
    , p_sensitive_flag ds_masks.sensitive_flag%TYPE := '~'
    , p_disabled_flag ds_masks.disabled_flag%TYPE := '~'
    , p_locked_flag ds_masks.locked_flag%TYPE := '~'
    , p_deleted_flag ds_masks.locked_flag%TYPE := '~'
    , p_msk_type ds_masks.msk_type%TYPE := '~'
    , p_shuffle_group ds_masks.shuffle_group%TYPE := -1
    , p_partition_bitmap ds_masks.partition_bitmap%TYPE := -1
    , p_pat_cat ds_masks.pat_cat%TYPE := '~'
    , p_pat_name ds_masks.pat_name%TYPE := '~'
    , p_params ds_masks.params%TYPE := '~'
    , p_options ds_masks.params%TYPE := '~'
    , p_remarks ds_masks.remarks%TYPE := '~'
    , p_raise_error_when_no_update BOOLEAN := TRUE
   )
   ;
   ---
   -- Reset mask(s) properties to their default NULL value
   ---
   PROCEDURE reset_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := '~'
   )
   ;
   ---
   -- Delete mask(s) for matching tables and columns (Oracle wildcards allowed)
   ---
   PROCEDURE delete_mask (
      p_table_name ds_masks.table_name%TYPE := NULL -- means all
    , p_column_name ds_masks.column_name%TYPE := NULL -- means all
   )
   ;
   ---
   -- Delete mask with given id (NULL for all)
   ---
   PROCEDURE delete_mask (
      p_msk_id ds_masks.msk_id%TYPE
   )
   ;
   ---
   -- Shuffle records for a data set
   ---
   PROCEDURE shuffle_records (
      p_set_id IN ds_data_sets.set_id%TYPE -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Generate a random rowid for a foreign key column
   ---
   FUNCTION random_rowid_from_fk_col (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_fk_name IN ds_utility_var.object_name
    , p_fk_col_name IN ds_utility_var.object_name
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   ;
   ---
   -- Generate a record id using ds_rec_seq.next_val
   ---
   FUNCTION gen_rec_id
   RETURN ds_records.rec_id%TYPE
   ;
   ---
   -- Extract rowids of records of reference tables
   ---
   PROCEDURE extract_ref_tables_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ;
   ---
   -- Define walk-through strategy
   ---
   PROCEDURE define_walk_through_strategy (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ;
   ---
   -- Set remark of records (for debugging purpose)
   ---
   PROCEDURE set_record_remarks (
      p_set_id ds_data_sets.set_id%TYPE
   )
   ;
   ---
   -- Set dependent flag in ds_masks
   ---
   PROCEDURE set_dependent_flag
   ;
   ---
   -- Generate identifiers for SEQUENCE masking (Oracle or in-memory)
   ---
   PROCEDURE generate_identifiers (
      p_set_id IN ds_data_sets.set_id%TYPE -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
   )
   ;
   ---
   -- Get an option value from a list of options
   ---
   FUNCTION get_string_option_value (
      p_list IN VARCHAR2 -- list of options
    , p_option IN VARCHAR2 -- searched option
    , p_default IN VARCHAR2 -- default value if not found
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get an option value from a list of options
   ---
   FUNCTION get_boolean_option_value (
      p_list IN VARCHAR2 -- list of options
    , p_option IN VARCHAR2 -- searched option
    , p_default IN BOOLEAN -- default value if not found
   )
   RETURN BOOLEAN
   ;
   ---
   -- Generate tokens for tokenized columns
   ---
   PROCEDURE generate_tokens (
      p_full_schema IN BOOLEAN := FALSE -- generate token for the whole schema
    , p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
   ;
/**
* Generate fake data set(s) i.e. synthetic data generation
*/
   PROCEDURE generate_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- NULL means all data sets
    , p_middle_commit IN BOOLEAN := FALSE -- commit after each step?
    , p_final_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
/**
* Extract rowids of records of the given data set. For each table that must
* be partially extracted (extract type P), identify records to extract
* and store their rowids. Tables that are fully extracted (extract type F)
* or not extracted at all (extract type N) are not part of this process.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE extract_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_middle_commit IN BOOLEAN := FALSE
    , p_final_commit IN BOOLEAN := FALSE
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
/**
   DEPRECATED, replaced with extract_data_set().
*/
   PROCEDURE extract_data_set_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_middle_commit IN BOOLEAN := FALSE
    , p_final_commit IN BOOLEAN := FALSE
   )
   ;
   ---
   -- Propagate primary key data masking to foreign keys
   ---
   PROCEDURE propagate_masking (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
   )
   ;
   ---
   -- Mask a data set
   ---
   PROCEDURE mask_data_set (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_encrypt_tokenized_values IN BOOLEAN := TRUE -- encrypt tokenized values?
    , p_key IN VARCHAR2 := NULL -- encryption key, NULL for random
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
   ;
/**
* Handle a data set (copy/delete via direct execution or prepare/execution script)
* @param p_set_id       data set id, NULL means all data sets
* @param p_oper         DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
* @param p_mode         I)nsert, U)pdate, R)efresh or UI, D)elete, M)ove
* @param p_db_link      for remote script execution
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE transport_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_method IN VARCHAR2 -- DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
     ,p_mode IN VARCHAR2 := NULL -- I)insert, U)pdate, R)efresh or UI, D)elete, M)ove
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_output IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
     ,p_middle_commit IN BOOLEAN := FALSE -- commit transaction after each table
     ,p_final_commit IN BOOLEAN := FALSE -- commit transaction at the end
     ,p_mask_data IN BOOLEAN :=  TRUE -- mask data?
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
/**
* Handle a data set (DEPRECATED, replaced with transport_data_set())
* @param p_set_id       data set id, NULL means all data sets
* @param p_method       DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
* @param p_mode         I)nsert, U)pdate, R)efresh or UI, D)elete, M)ove
* @param p_db_link      for remote script execution
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE handle_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_oper IN VARCHAR2 -- DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
     ,p_mode IN VARCHAR2 := NULL -- I)insert, U)pdate, R)efresh or UI, D)elete, M)ove
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_output IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
     ,p_commit IN BOOLEAN := FALSE -- commit transaction at the end
     ,p_mask_data IN BOOLEAN :=  TRUE -- mask data?
     ,p_middle_commit IN BOOLEAN := FALSE -- commit transaction after each table
     ,p_log_run IN BOOLEAN := TRUE -- log run
   )
   ;
/**
* Export a data set to XML. XML of fully extracted tables (extract type F)
* is stored in the CLOB of the table itself (i.e. one XML per table). XML of
* partially extracted tables (extract type P) is stored at the record level
* (i.e. one XML per record).
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE export_data_set_to_xml (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
   ;
/**
* Import a data set from XML. Each record of the XML is inserted back to its
* original table. See export procedure for a description of where XML is stored.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE import_data_set_from_xml (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
   ;
/**
* Return true expression (internal usage - for security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION true_expression (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
/**
* Return false expression (internal usage - for security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION false_expression (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
/**
* Return table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   FUNCTION get_table_filter (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_mode IN VARCHAR2 := NULL -- S,D
    , p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
   RETURN VARCHAR2
   ;
/**
* Return static table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION get_table_filter_stat (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
/**
* Return dynamic table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION get_table_filter_dyn (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
/**
* Create views used to preview data sets. One view is created for each table of
* the data sets. View name is derived from the underlying table name. The possibility
* is given to add a prefix or a suffix to the view name as well as to remove a prefix
* from the underlying table name. Only data sets marked as visible will be shown in
* these views.
* @param p_view_suffix view suffix
* @param p_view_prefix view prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_views (
      p_view_suffix IN VARCHAR2 := NULL  -- suffix to add to view name
     ,p_view_prefix IN VARCHAR2 := NULL  -- prefix to add to view name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_mode IN VARCHAR2 := NULL -- (S)tatic or (D)ynamic
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB' -- data set type (null for all)
     ,p_mask_data IN BOOLEAN := TRUE -- mask data?
     ,p_include_rowid IN BOOLEAN := FALSE -- include ROWID?
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
/**
* Drop views used to preview data sets. See create_views() for a description on how
* view names are built.
* @param p_view_suffix view suffix
* @param p_view_prefix view prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_views (
      p_view_suffix IN VARCHAR2 := NULL  -- suffix to add to view name
     ,p_view_prefix IN VARCHAR2 := NULL  -- prefix to add to view name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB' -- data set type (null for all)
   )
   ;
/**
* Create policies used to export data sets. One policy is created for each table
* of the data sets. Policy name is derived from the underlying table name. The possibility
* is given to add a prefix or a suffix to the policy name as well as to remove a prefix
* from the underlying table name. Security policies will only let access records that
* belong to data sets marked as visible.
* @param p_policy_suffix policy suffix
* @param p_policy_prefix policy prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_policies (
      p_policy_suffix IN VARCHAR2 := NULL  -- suffix to add to policy name
     ,p_policy_prefix IN VARCHAR2 := NULL  -- prefix to add to policy name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_mode IN VARCHAR2 := NULL -- (S)tatic or (D)ynamic
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
   ;
/**
* Drop policies used to export data sets. See create_policies() for a description on
* how policy names are built.
* @param p_policy_suffix policy suffix
* @param p_policy_prefix policy prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_policies (
      p_policy_suffix IN VARCHAR2 := NULL  -- suffix to add to policy name
     ,p_policy_prefix IN VARCHAR2 := NULL  -- prefix to add to policy name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
   ;
/**
* Create target tables (when copying data set between tables)
* @param p_target_suffix target table suffix
* @param p_target_prefix target table prefix
* @param p_source_prefix source table prefix
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_tables (
      p_target_suffix IN VARCHAR2 := NULL  -- suffix to add to target table name
     ,p_target_prefix IN VARCHAR2 := NULL  -- prefix to add to target table name
     ,p_source_prefix IN VARCHAR2 := NULL  -- prefix to remove from source table name
     ,p_full_schema IN BOOLEAN := FALSE    -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (NULL means all)
     ,p_table_options IN VARCHAR2 := NULL  -- table options
   )
   ;
/**
* Drop tables
* @param p_target_suffix target table suffix
* @param p_target_prefix target table prefix
* @param p_source_prefix source table prefix
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_tables (
      p_target_suffix IN VARCHAR2 := NULL  -- suffix to add to target table name
     ,p_target_prefix IN VARCHAR2 := NULL  -- prefix to add to target table name
     ,p_source_prefix IN VARCHAR2 := NULL  -- prefix to remove from source table name
     ,p_full_schema IN BOOLEAN := FALSE -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- view only this data set
     ,p_table_options IN VARCHAR2 := NULL  -- table options (not used)
   )
   ;
/**
* Define the new value of an identifier
* @param p_msk_id       mask id
* @param p_old_id       old value of the identifier
* @param p_new_id       new value of the identifier
* @return               new value of the identifier
*/
   FUNCTION set_identifier (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
    , p_new_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
   ;
/**
* Define the new value of an identifier
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_old_id       old value of the identifier
* @param p_new_id       new value of the identifier
* @return               new value of the identifier
*/
   FUNCTION set_identifier (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
    , p_new_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
   ;
/**
* Get the new value of an identifier from its old value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_old_id       old value of the identifier
* @return               new value of the identifier
*/
   FUNCTION get_identifier (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
   ;
/**
* Get the new value of an identifier from its old value
* @param p_msk_id       msk_id
* @param p_old_id       old value of the identifier
* @return               new value of the identifier
*/
   FUNCTION get_identifier (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
   ;
/**
* Get a data set record by id
* @param p_set_id       if of a data set
* @return               data set record
*/
   FUNCTION get_data_set_rec_by_id (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   RETURN ds_data_sets%ROWTYPE
   ;
/**
* Get table record by id
* @param p_table_id     if of data set table
* @return               table record
*/
   FUNCTION get_table_rec_by_id (
      p_table_id ds_tables.table_id%TYPE
   )
   RETURN ds_tables%ROWTYPE
   ;
/**
* Capture an operation performed on a table
* @param p_set_id       data set id
* @param p_table_id     table id
* @param p_record_rowid rowid
* @param p_operation    operation (I=Insert, U=Update, D=Delete)
* @param p_xml_new      xml of record after operation (I,U)
* @param p_xml_old      xml of record before operation (D,U)
* @return               new value of the identifier
*/
   PROCEDURE capture_operation (
      p_set_id IN ds_data_sets.set_id%TYPE -- set id
    , p_table_id IN ds_records.table_id%TYPE -- table id
    , p_record_rowid IN ds_records.record_rowid%TYPE -- rowid
    , p_operation IN ds_records.operation%TYPE -- I)nsert, U)pdate, D)elete
    , p_user_name IN ds_records.user_name%TYPE
    , p_xml_new CLOB -- new record
    , p_xml_old CLOB -- old record
   )
   ;
/**
* Create triggers for capturing operations
* @param p_set_id       data set id
*/
   PROCEDURE create_triggers (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_ignore_errors IN VARCHAR2 := 'N'
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
/**
* Drop triggers created for capture
* @param p_set_id       data set id
*/
   PROCEDURE drop_triggers (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_ignore_errors IN VARCHAR2 := 'Y'
   )
   ;
/**
* Delete captured operations
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_keep count   number of operations to keep
*/
   PROCEDURE delete_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL -- filter on user
    , p_keep_count IN ds_records.seq%TYPE := NULL -- NULL means keep none
   )
   ;
/**
* Undo some operations captured by a given data set
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_count        number of operations to undo
* @param p_delete_flag  delete records after undo (Y/N)?
*/
   PROCEDURE undo_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL
    , p_count IN ds_records.seq%TYPE := NULL
    , p_delete_flag IN VARCHAR2 := 'N'
   )
   ;
/**
* Undo some operations captured by a given data set
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_count        number of operations to redo
* @param p_delete_flag  delete records after redo (Y/N)?
*/
   PROCEDURE redo_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL
    , p_count IN ds_records.seq%TYPE := NULL -- NULL means all
    , p_delete_flag IN VARCHAR2 := 'N'
   )
   ;
/**
* Rollback all operations captured via triggers
* @param p_set_id       data set id
* @param p_delete_flag  delete records after rollback (Y/N)?
*/
   PROCEDURE rollback_captured_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_delete_flag IN VARCHAR2 := 'Y'
   )
   ;
/**
* Rollforward all operations captured via triggers
* @param p_set_id       data set id
* @param p_delete_flag  delete records after rollforward (Y/N)?
*/
   PROCEDURE rollforward_captured_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_delete_flag IN VARCHAR2 := 'Y'
   )
   ;
/**
* Returns a script to redo/undo capture DML operations
* @param p_set_id       data set id
* @param p_undo_flag    generate undo script if Y, redo otherwise
*/
   FUNCTION gen_captured_data_set_script (
      p_set_id    IN ds_data_sets.set_id%TYPE
    , p_undo_flag IN VARCHAR2 := NULL -- Y/N
   )
   RETURN sys.odcivarchar2list pipelined
   ;
/**
* Generates a script (to the specified output) to redo/undo capture DML operations
* @param p_set_id       data set id
* @param p_undo_flag    generate undo script if Y, redo otherwise
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE gen_captured_data_set_script (
      p_set_id    IN ds_data_sets.set_id%TYPE
    , p_undo_flag IN VARCHAR2 := NULL -- Y/N
    , p_output    IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
   )
   ;
/**
* Detect true master detail constraints (identifying relationships)
* By setting md_cardinality_ok, md_optionality_ok and md_uid_ok cols
* @param p_set_id       data set id
*/
   PROCEDURE detect_true_master_detail_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ;
   ---
   -- Discover sensitive data
   --
   ---
   PROCEDURE discover_sensitive_data (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- NULL means all
    , p_full_schema IN BOOLEAN := NULL -- Y/N, N for data sets only
    , p_table_name IN VARCHAR2 := NULL -- only those matching (wildcards allowed)
    , p_column_name IN VARCHAR2 := NULL -- only those matching (wildcards allowed)
    , p_rows_sample_size IN INTEGER := 200 -- 0 means all rows
    , p_col_data_min_pct IN INTEGER := 10 -- minimum hit percentage
    , p_col_data_min_cnt IN INTEGER := 2 -- minimum hit count
    , p_values_sample_size IN INTEGER := 10 -- 0 means all values
    , p_overwrite IN BOOLEAN := FALSE -- ignore locked_flag
    , p_commit IN BOOLEAN := FALSE -- commit at the end
    , p_log_run IN BOOLEAN := TRUE -- log run?
   )
   ;
--#endif 0
END ds_utility_krn;
/