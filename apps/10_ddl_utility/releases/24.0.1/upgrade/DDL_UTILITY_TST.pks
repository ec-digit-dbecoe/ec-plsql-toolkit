CREATE OR REPLACE PACKAGE ddl_utility_tst
AUTHID DEFINER
AS
   --%suite(Unit test for ddl_utility)
   --%rollback(manual)
   -- Auto rollback is not possible because of executed DDLs

   PROCEDURE drop_seq;

   --%context(change_sequence_value:check_params)
   -- csv prefix in below procedure names stands for change_sequence_value 

   --%test(Raises exception when sequence name is null)
   --%throws(-20000)
   PROCEDURE csv_seq_name_null;

   --%test(Raises exception when sequence name is invalid)
   --%throws(-20000)
   PROCEDURE csv_seq_name_invalid;

   --%endcontext

   --%context(change_sequence_value:check_sequence)
   -- csv prefix in below procedure names stands for change_sequence_value 

   --%aftereach(drop_seq)

   --%test(Raises exception when sequence value less than minimum)
   --%throws(-20000)
   PROCEDURE csv_seq_value_lt_min;

   --%test(Raises exception when sequence value greather than maximum)
   --%throws(-20000)
   PROCEDURE csv_seq_value_gt_max;

   --%test(Reset sequence by passing null value i.e. set it to its minimum) 
   PROCEDURE csv_seq_value_eq_null;

   --%test(Set sequence to a value greater than actual)
   PROCEDURE csv_seq_value_gt_actual;

   --%test(Set sequence to a value less than actual)
   PROCEDURE csv_seq_value_lt_actual;

   --%test(Set sequence to a value equal to actual)
   PROCEDURE csv_seq_value_eq_actual;

   --%endcontext

   --%context(sync_sequence_with_table:check_params)
   -- sswt prefix in below procedure names stands for sync_sequence_with_table

   --%test(Raises exception when sequence name is null)
   --%throws(-20000)
   PROCEDURE sswt_seq_name_null;

   --%test(Raises exception when table name is null)
   --%throws(-20000)
   PROCEDURE sswt_tab_name_null;

   --%test(Raises exception when column name is null)
   --%throws(-20000)
   PROCEDURE sswt_col_name_null;

   --%endcontext

   --%context(sync_sequence_with_table:check_sync)
   -- sswt prefix in below procedure names stands for sync_sequence_with_table

   --%beforeall
   PROCEDURE create_tab;

   --%afterall
   PROCEDURE drop_tab;

   --%beforeeach
   PROCEDURE trunc_tab;

   --%aftereach(drop_seq)

   --%test(Sync sequence with an empty table)
   PROCEDURE sswt_empty_table;

   --%test(Sync sequence with a non empty table)
   PROCEDURE sswt_non_empty_table;

   --%test(Sync sequence with a non empty table and a ceiling)
   PROCEDURE sswt_non_empty_table_with_ceil;

   --%test(Sync sequence with a non empty table and a floor)
   PROCEDURE sswt_non_empty_table_with_flo;

   --%endcontext
END;
/
