CREATE OR REPLACE PACKAGE qc_utility_var IS
   g_app_alias VARCHAR2(30);
   g_object_owner VARCHAR2(30);
   TYPE dict_entry_table IS TABLE OF qc_dictionary_entries.dict_value%TYPE INDEX BY qc_dictionary_entries.dict_key%TYPE;
   TYPE dictionary_table IS TABLE OF dict_entry_table INDEX BY qc_dictionary_entries.dict_name%TYPE;
   g_dict dictionary_table;
   TYPE rdict_entry_table IS TABLE OF qc_dictionary_entries%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE rdictionary_table IS TABLE OF rdict_entry_table INDEX BY qc_dictionary_entries.dict_name%TYPE;
   g_rdict rdictionary_table;
   t_msg qc_utility_msg.msg_table;
   t_msg_upd qc_utility_msg.msg_table;
   t_stat qc_utility_stat.stat_table;
   TYPE msg_hash IS TABLE OF qc_run_msgs%ROWTYPE INDEX BY VARCHAR2(142); -- 10+30+100+2(#)=142
   g_msg msg_hash;
   TYPE fix_name_table IS TABLE OF qc_run_msgs.object_type%TYPE INDEX BY qc_run_msgs.fix_name%TYPE;
   t_fix fix_name_table;
   SUBTYPE columns_list IS VARCHAR2(400);
   TYPE constraint_record IS RECORD (
      owner all_constraints.owner%TYPE
    , constraint_type all_constraints.constraint_type%TYPE
    , constraint_cols columns_list
    , table_name all_constraints.table_name%TYPE
    , r_constraint_name all_constraints.r_constraint_name%TYPE
   );
   TYPE constraint_hash IS TABLE OF constraint_record INDEX BY all_constraints.constraint_name%TYPE;
   TYPE table_constraint_hash IS TABLE OF constraint_hash INDEX BY all_tables.table_name%TYPE;
   g_tab_con table_constraint_hash;
   TYPE index_record IS RECORD (
--      owner all_indexes.owner%TYPE
--    , 
      index_type all_indexes.uniqueness%TYPE
    , index_cols columns_list
   );
   TYPE index_hash IS TABLE OF index_record INDEX BY all_indexes.index_name%TYPE;
   TYPE table_index_hash IS TABLE OF index_hash INDEX BY all_tables.table_name%TYPE;
   g_tab_ind table_index_hash;
   TYPE cache_record IS RECORD (
      t_tab_con table_constraint_hash
    , t_con constraint_hash
    , t_tab_ind table_index_hash
   );
   TYPE schema_cache IS TABLE OF cache_record INDEX BY user_users.username%TYPE;
   g_cache schema_cache;
   gk_success CONSTANT qc_runs.status%TYPE := 'SUCCESS';
   gk_failure CONSTANT qc_runs.status%TYPE := 'FAILURE';
   gk_identifier_name CONSTANT PLS_INTEGER := 30;
   TYPE gr_sorted_object_type IS RECORD (
      object_order INTEGER
    , object_type all_objects.object_type%TYPE
    , object_name all_objects.object_name%TYPE
   );
   TYPE gt_sorted_object_type IS TABLE OF gr_sorted_object_type;
   -- Variables for logging into qc_run_logs
   g_run_id qc_runs.run_id%TYPE;
   g_last_line qc_run_logs.line%TYPE;
   g_time_mask VARCHAR2(40) := NULL; -- Display time in this format
   g_msg_mask VARCHAR2(5) := 'WE'; -- Message filter
END;
/