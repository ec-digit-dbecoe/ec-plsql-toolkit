CREATE OR REPLACE PACKAGE ddl_utility AS
/*
  D D L   U T I L I T Y   P A C K A G E

  ================
  Revision History
  ================
  Ver     Date       Who     What
  ------- ---------- ------- ----------------------------------------------- 
  0.1     01/07/2004 deboiph Initial version
  1.1     02/05/2019 deboiph Fix bugs found thanks to unit tests 
*/
/**
* Disable some constraints (all referential constraints by default)
* @param p_constraint_name name of constraint to disable
* @param p_constraint_type type of constraint to disable
*/
   PROCEDURE disable_constraints (
      p_constraint_name IN user_constraints.constraint_name%TYPE := '%'
     ,p_constraint_type IN user_constraints.constraint_type%TYPE := 'R'
   );
/**
* Enable some constraints (all referential constraints by default)
* @param p_constraint_name name of constraint to enable
* @param p_constraint_type type of constraint to enable
*/
   PROCEDURE enable_constraints (
      p_constraint_name IN user_constraints.constraint_name%TYPE := '%'
     ,p_constraint_type IN user_constraints.constraint_type%TYPE := 'R'
   );
/**
* Change next value of a sequence
* @param p_seq_name sequence name
* @param p_seq_value target value
*/
   PROCEDURE change_sequence_value (
      p_seq_name IN user_sequences.sequence_name%TYPE
     ,p_seq_value IN user_sequences.last_number%TYPE
   );
/**
* Synchronise a sequence with the maximum value of a table column
* @param p_seq_name sequence name
* @param p_table_name table name
* @param p_column_name column name
* @param p_ceiling_value ignore values above this limit
* @param p_floor_value ignore values below this limit
*/
   PROCEDURE sync_sequence_with_table (
      p_sequence_name IN user_sequences.sequence_name%TYPE
     ,p_table_name IN user_tab_columns.table_name%TYPE
     ,p_column_name IN user_tab_columns.column_name%TYPE
     ,p_ceiling_value IN INTEGER := NULL
     ,p_floor_value IN INTEGER := NULL
   );
/**
* Truncate some tables (all by default)
* @param p_table_name name of table to truncate
*/
   PROCEDURE truncate_tables (
      p_table_name IN user_tables.table_name%TYPE := '%'
   );
/**
* Drop some tables (all by default)
* @param p_table_name name of table to truncate
*/
   PROCEDURE drop_tables (
      p_table_name IN user_tables.table_name%TYPE := '%'
   );
   ---
   -- Execute dynamic SQL statement
   ---
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   )
   RETURN INTEGER;
   ---
   -- Execute dynamic SQL statement
   ---
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   );
END;
/
