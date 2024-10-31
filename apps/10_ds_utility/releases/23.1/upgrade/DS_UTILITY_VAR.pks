CREATE OR REPLACE PACKAGE ds_utility_var AS
---
-- Copyright (C) 2023 European Commission
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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
   ---
   -- Global types
   ---
   SUBTYPE object_name IS VARCHAR2(30);
   SUBTYPE table_name IS object_name;
   SUBTYPE column_name IS object_name;
   SUBTYPE full_column_name IS VARCHAR2(61); -- table.column
   SUBTYPE largest_string IS VARCHAR2(32567);
   TYPE column_name_table IS TABLE OF object_name INDEX BY BINARY_INTEGER;
   TYPE column_type_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE seq_record_type IS RECORD (
      table_id ds_tables.table_id%TYPE
    , set_id ds_tables.set_id%TYPE
    , sequence_name ds_tables.sequence_name%TYPE
    , in_mem_seq_flag VARCHAR2(1)
    , in_mem_seq_start_number NUMBER
    , in_mem_seq_increment_by NUMBER
    , table_name ds_tables.table_name%TYPE
    , column_name user_tab_columns.column_name%TYPE
    , id_shift_value ds_tables.id_shift_value%TYPE
    , pk_name sys.all_constraints.constraint_name%TYPE
   );
   TYPE shift_value_table IS TABLE OF seq_record_type INDEX BY full_column_name;
   TYPE pk_table IS TABLE OF sys.all_constraints.constraint_name%TYPE INDEX BY table_name;
   TYPE ccol_table IS TABLE OF ds_tables.columns_list%TYPE INDEX BY table_name;
   TYPE replacement_table IS TABLE OF VARCHAR2(200) INDEX BY VARCHAR(100); -- table.name#X
   TYPE mask_rec_table IS TABLE OF ds_masks%ROWTYPE INDEX BY column_name;
   TYPE mask_table IS TABLE OF mask_rec_table INDEX BY table_name;
   TYPE col_record IS RECORD (
      table_name user_tab_columns.table_name%TYPE
    , column_name user_tab_columns.column_name%TYPE
    , data_type user_tab_columns.data_type%TYPE
    , data_length user_tab_columns.data_length%TYPE
    , data_precision user_tab_columns.data_precision%TYPE
    , data_scale user_tab_columns.data_scale%TYPE
    , col_val VARCHAR2(32567)
    , is_masked BOOLEAN
   );
   TYPE col_table IS TABLE OF col_record INDEX BY BINARY_INTEGER;
   TYPE pos_table IS TABLE OF PLS_INTEGER INDEX BY column_name; -- position of each column in col_table
   TYPE ds_rows IS TABLE OF largest_string INDEX BY BINARY_INTEGER; -- index by row number
   TYPE ds_table IS TABLE OF ds_rows INDEX BY ds_data_sets.set_name%TYPE; -- index by data set name
   TYPE ds_rows2 IS TABLE OF BINARY_INTEGER INDEX BY largest_string; -- index by column value
   TYPE ds_table2 IS TABLE OF ds_rows2 INDEX BY largest_string; -- index by data set name + column name
   TYPE in_mem_seq_table IS TABLE OF PLS_INTEGER INDEX BY full_column_name;
   TYPE fk_record_type IS RECORD (
      pk_name object_name
    , pk_tab_name table_name
    , pk_col_name column_name
    , pk_tab_alias object_name
    , table_alias object_name
    , fk_name object_name
    , fk_tab_name table_name
    , fk_col_name column_name
    , join_clause VARCHAR2(400)
    , col_val VARCHAR2(4000)
   );
   TYPE fk_table IS TABLE OF fk_record_type INDEX BY VARCHAR2(100);
   ---
   -- Global variables
   ---
   g_user      VARCHAR2(30) := NULL;     -- Current user
   g_test_mode BOOLEAN := FALSE;     -- Display DDLs instead of executing them?
   g_mask_data BOOLEAN := TRUE;      -- Enable/disable masking
   g_show_time BOOLEAN := FALSE;     -- Display time information?
   g_time_mask VARCHAR2(40) := 'DD/MM/YYYY HH24:MI:SS';  -- Display date/time in this format
   g_timestamp_mask VARCHAR2(40) := 'DD/MM/YYYY HH24:MI:SS.FF'; -- Display timestamp in this format
   g_msg_mask  VARCHAR2(10) := 'WE'; -- Message filter
   g_owner sys.all_objects.owner%TYPE := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'); -- Object owner
   g_table_name VARCHAR2(60) := NULL;
   g_col_names column_name_table;
   g_col_types column_type_table;
   g_seq shift_value_table;
   g_map shift_value_table;
   g_out_line INTEGER;
   g_pk pk_table; -- primary keys
   g_ccol ccol_table; -- constraint columns
   g_rep replacement_table;
   g_alias_like_pattern VARCHAR2(100) := '([A-Z]*_|^)([A-Z]*)((_PK)|(_UK\d*))$'; -- {app_alias}_{table_alias}_PK|UKx
   g_alias_replace_pattern VARCHAR2(100) := '\2'; -- {table_alias}
   g_alias_max_length INTEGER := 5;
   g_alias_constraint_type VARCHAR2(20) := 'PU'; -- consider PK and UKs
   g_capture_job_name VARCHAR2(23) := 'DS:1_CAPTURE_FORWARDING';
   g_capture_job_delta NUMBER := 10 / 86400; -- 10 seconds
   g_xml_batchsize NUMBER := NULL; -- NULL means don't set, default is 1 i.e. no batch
   g_xml_commitbatch NUMBER := NULL; -- NULL means don't set, default is 0 i.e. no commit
   --http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
   g_xml_dateformat VARCHAR2(30) := 'dd/MM/yyyy HH:mm:ss'; -- NULL means don't set, default is MM/dd/yyyy HH:mm:ss
   g_msk mask_table;
   g_col_tab col_table;
   g_pos_tab pos_table;
   g_ds_tab ds_table;   -- CSV data sets, indexed by row number
   g_ds_tab2 ds_table2; -- CSV data sets, indexed by row value
   g_in_mem_seq_tab in_mem_seq_table;
   g_pk_tab fk_table; -- PK columns whose masking must be propagated
   g_fk_tab fk_table; -- FK columns that must inherit PK masking
END;
/
