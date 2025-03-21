CREATE OR REPLACE PACKAGE BODY ds_utility_var AS
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
   PROCEDURE show_cache IS
   BEGIN
      dbms_output.put_line('g_user='||ds_utility_var.g_user);
      dbms_output.put_line('g_test_mode='||CASE ds_utility_var.g_test_mode WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      dbms_output.put_line('g_mask_data='||CASE ds_utility_var.g_mask_data WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      dbms_output.put_line('g_encrypt_tokenized_values='||CASE ds_utility_var.g_encrypt_tokenized_values WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      dbms_output.put_line('g_show_time='||CASE ds_utility_var.g_show_time WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
      dbms_output.put_line('g_time_mask='||ds_utility_var.g_time_mask);
      dbms_output.put_line('g_timestamp_mask='||ds_utility_var.g_timestamp_mask);
      dbms_output.put_line('g_msg_mask='||ds_utility_var.g_msg_mask);
      dbms_output.put_line('g_log_mask='||ds_utility_var.g_log_mask);
      dbms_output.put_line('g_owner='||ds_utility_var.g_owner);
      dbms_output.put_line('g_table_name='||ds_utility_var.g_table_name);
      dbms_output.put_line('g_col_names.COUNT='||ds_utility_var.g_col_names.COUNT);
      dbms_output.put_line('g_col_types.COUNT='||ds_utility_var.g_col_types.COUNT);
      dbms_output.put_line('g_seq.COUNT='||ds_utility_var.g_seq.COUNT);
      dbms_output.put_line('g_map.COUNT='||ds_utility_var.g_map.COUNT);
      dbms_output.put_line('g_out_line='||ds_utility_var.g_out_line);
      dbms_output.put_line('g_pk.COUNT='||ds_utility_var.g_pk.COUNT);
      dbms_output.put_line('g_ccol.COUNT='||ds_utility_var.g_ccol.COUNT); -- constraint columns
      dbms_output.put_line('g_alias_like_pattern='||ds_utility_var.g_alias_like_pattern);
      dbms_output.put_line('g_alias_replace_pattern='||ds_utility_var.g_alias_replace_pattern);
      dbms_output.put_line('g_alias_max_length='||ds_utility_var.g_alias_max_length);
      dbms_output.put_line('g_alias_constraint_type='||ds_utility_var.g_alias_constraint_type);
      dbms_output.put_line('g_capture_job_name='||ds_utility_var.g_capture_job_name);
      dbms_output.put_line('g_capture_job_delta='||ds_utility_var.g_capture_job_delta);
      dbms_output.put_line('g_xml_batchsize='||ds_utility_var.g_xml_batchsize);
      dbms_output.put_line('g_xml_commitbatch='||ds_utility_var.g_xml_commitbatch);
      dbms_output.put_line('g_xml_dateformat='||ds_utility_var.g_xml_dateformat);
      dbms_output.put_line('ga_msk.COUNT='||ds_utility_var.ga_msk.COUNT);
      dbms_output.put_line('gt_msk.COUNT='||ds_utility_var.gt_msk.COUNT);
      dbms_output.put_line('g_msk_date_time='||ds_utility_var.g_msk_date_time);
      dbms_output.put_line('g_col_tab.COUNT='||ds_utility_var.g_col_tab.COUNT);
      dbms_output.put_line('g_pos_tab.COUNT='||ds_utility_var.g_pos_tab.COUNT);
      dbms_output.put_line('g_ds_tab.COUNT='||ds_utility_var.g_ds_tab.COUNT);
      dbms_output.put_line('g_ds_tab2.COUNT='||ds_utility_var.g_ds_tab2.COUNT);
      dbms_output.put_line('g_in_mem_seq_tab.COUNT='||ds_utility_var.g_in_mem_seq_tab.COUNT);
      dbms_output.put_line('g_pk_tab.COUNT='||ds_utility_var.g_pk_tab.COUNT);
      dbms_output.put_line('g_fk_tab.COUNT='||ds_utility_var.g_fk_tab.COUNT);
      dbms_output.put_line('g_fk_pk_tab.COUNT='||ds_utility_var.g_fk_pk_tab.COUNT);
      dbms_output.put_line('g_blk_count='||ds_utility_var.g_blk_count);
      dbms_output.put_line('g_cursor_tab.COUNT='||ds_utility_var.g_cursor_tab.COUNT);
      dbms_output.put_line('g_desc_tab.COUNT='||ds_utility_var.g_desc_tab.COUNT);
      dbms_output.put_line('g_default_seed_format='||ds_utility_var.g_default_seed_format);
      dbms_output.put_line('g_run_id='||ds_utility_var.g_run_id);
      dbms_output.put_line('g_routine_name='||ds_utility_var.g_routine_name);
      dbms_output.put_line('g_log_line='||ds_utility_var.g_log_line);
   END;
   PROCEDURE reset_cache IS
   BEGIN
      ds_utility_var.g_user := NULL;     -- Current user
      ds_utility_var.g_test_mode := FALSE;     -- Display DDLs instead of executing them?
      ds_utility_var.g_mask_data := TRUE;      -- Enable/disable masking
      ds_utility_var.g_encrypt_tokenized_values := TRUE; -- Encrypt tokenized values?
      ds_utility_var.g_show_time := FALSE;     -- Display time information?
      ds_utility_var.g_time_mask := 'DD/MM/YYYY HH24:MI:SS';  -- Display date/time in this format
      ds_utility_var.g_timestamp_mask := 'DD/MM/YYYY HH24:MI:SS.FF'; -- Display timestamp in this format
      ds_utility_var.g_msg_mask  := 'WE'; -- Message filter
      ds_utility_var.g_log_mask  := 'IWE'; -- Log filter
      ds_utility_var.g_owner := USER; -- Object owner (session user by default)
      ds_utility_var.g_table_name := NULL;
      ds_utility_var.g_col_names.DELETE;
      ds_utility_var.g_col_types.DELETE;
      ds_utility_var.g_seq.DELETE;
      ds_utility_var.g_map.DELETE;
      ds_utility_var.g_out_line := NULL;
      ds_utility_var.g_pk.DELETE;
      ds_utility_var.g_ccol.DELETE; -- constraint columns
      ds_utility_var.g_alias_like_pattern := '([A-Z]*_|^)([A-Z]*)((_PK)|(_UK\d*))$'; -- {app_alias}_{table_alias}_PK|UKx
      ds_utility_var.g_alias_replace_pattern := '\2'; -- {table_alias}
      ds_utility_var.g_alias_max_length := 5;
      ds_utility_var.g_alias_constraint_type := 'PU'; -- consider PK and UKs
      ds_utility_var.g_capture_job_name := 'DS:1_CAPTURE_FORWARDING';
      ds_utility_var.g_capture_job_delta := 10 / 86400; -- 10 seconds
      ds_utility_var.g_xml_batchsize := NULL; -- NULL means don't set, default is 1 i.e. no batch
      ds_utility_var.g_xml_commitbatch := NULL; -- NULL means don't set, default is 0 i.e. no commit
      ds_utility_var.g_xml_dateformat := 'dd/MM/yyyy HH:mm:ss'; -- NULL means don't set, default is MM/dd/yyyy HH:mm:ss
      ds_utility_var.ga_msk.DELETE;
      ds_utility_var.gt_msk.DELETE;
      ds_utility_var.g_msk_date_time := NULL;
      ds_utility_var.g_col_tab.DELETE;
      ds_utility_var.g_pos_tab.DELETE;
      ds_utility_var.g_ds_tab.DELETE;   -- CSV data sets, indexed by row number
      ds_utility_var.g_ds_tab2.DELETE; -- CSV data sets, indexed by row value
      ds_utility_var.g_in_mem_seq_tab.DELETE;
      ds_utility_var.g_pk_tab.DELETE; -- PK columns whose masking must be propagated
      ds_utility_var.g_fk_tab.DELETE; -- FK columns that must inherit PK masking
      ds_utility_var.g_fk_pk_tab.DELETE;
      ds_utility_var.g_blk_count := 100; -- number of records to fetch by block
      ds_utility_var.g_cursor_tab.DELETE;
      ds_utility_var.g_desc_tab.DELETE;
      ds_utility_var.g_default_seed_format := 'FFSSMMHH24';
      ds_utility_var.g_run_id := NULL;
      ds_utility_var.g_routine_name := NULL;
      ds_utility_var.g_log_line := NULL;
   END;
END ds_utility_var;
/