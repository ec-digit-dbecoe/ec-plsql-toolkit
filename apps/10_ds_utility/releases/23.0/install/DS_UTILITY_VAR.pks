CREATE OR REPLACE PACKAGE ds_utility_var AS
   ---
   -- Global types
   ---
   TYPE column_name_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE column_type_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE seq_record_type IS RECORD (
      table_id ds_tables.table_id%TYPE
    , set_id ds_tables.set_id%TYPE
    , sequence_name ds_tables.sequence_name%TYPE
    , table_name ds_tables.table_name%TYPE
    , column_name user_tab_columns.column_name%TYPE
    , id_shift_value ds_tables.id_shift_value%TYPE
   );
   TYPE shift_value_table IS TABLE OF seq_record_type INDEX BY VARCHAR2(61);
   TYPE pk_table IS TABLE OF sys.all_constraints.constraint_name%TYPE INDEX BY VARCHAR2(30);
   TYPE ccol_table IS TABLE OF ds_tables.columns_list%TYPE INDEX BY VARCHAR2(30);
   TYPE replacement_table IS TABLE OF VARCHAR2(200) INDEX BY VARCHAR(100); -- table.name#X
   ---
   -- Global variables
   ---
   g_user      VARCHAR2(30) := NULL;     -- Current user
   g_test_mode BOOLEAN := FALSE;     -- Display DDLs instead of executing them?
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
END;
/