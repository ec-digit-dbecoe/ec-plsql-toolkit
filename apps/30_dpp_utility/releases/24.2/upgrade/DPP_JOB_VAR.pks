CREATE OR REPLACE PACKAGE DPP_JOB_VAR AUTHID DEFINER ACCESSIBLE BY (package DPP_INJ_KRN, package DPP_JOB_KRN, package DPP_JOB_MEM, package DPP_MONITORING_KRN) IS
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

   gk_default_sender CONSTANT VARCHAR2(256) := 'DIGIT DPP <automated-notifications@nomail.ec.europa.eu>';
   
   ge_missing_hash_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_missing_hash_value, -21015);

   ge_illegal_argument EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_illegal_argument, -21009); -- was 21005!

   ge_selftest_failed EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_selftest_failed, -21007);

   ge_abort_export EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_abort_export, -21002);

   ge_no_imp_file_for_context EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_no_imp_file_for_context, -21004);

   ge_target_schema_doesnt_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_target_schema_doesnt_exist, -21006);

   ge_abort_import EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_abort_import, -21003);

   ge_specfied_multiple_times EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_specfied_multiple_times, -39051);

   ge_success_with_info EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_success_with_info, -31627);

   ge_renaming_failed EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_renaming_failed, -21001);

   ge_injection_failed EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_injection_failed, -21005);

   ge_illegal_arg_exec_sql_action   EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_illegal_arg_exec_sql_action, -21012);
   
   ge_illegal_arg_exec_sql_pre_post EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_illegal_arg_exec_sql_pre_post, -21013);
   
   ge_drop_obj_failed EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_drop_obj_failed, -21011);

   -- exception: no log file defined
   ge_no_log_file                   EXCEPTION;

   -- exception: opening log file failure
   ge_open_log_file_error           EXCEPTION;

   TYPE gt_import_files_type IS TABLE OF VARCHAR2(200);
   TYPE gt_list_names_type IS TABLE OF VARCHAR2(30);

   TYPE gt_prr_table_type IS TABLE OF dpp_parameters%ROWTYPE INDEX BY dpp_parameters.prr_name%TYPE;
   gt_prr_type gt_prr_table_type;

   g_cpu_count    NUMBER;
   g_dpp_dir      VARCHAR2(25) := NULL;        -- original tool version worked on single directory. Still use this one filled with the 2 others below to minimize impact on original code
   --g_dpp_in_dir   VARCHAR2(25) := 'DBCC_DBIN'; -- default value for DBCC, to fill with project dependent IN directory name
   --g_dpp_out_dir  VARCHAR2(25) := 'DBCC_DBOUT';-- default value for DBCC, to fill with project dependent OUT directory name 
   g_context      NUMBER;   

   g_id NUMBER ;  -- ID of instance

   g_start_time         DATE;
   g_stop_time          DATE;
   g_job_number         NUMBER;
   g_diff_cpu_count     NUMBER;
   g_app_run_type       dpp_job_types.jte_cd%TYPE;
   g_logfile            VARCHAR2(100);

   gk_pmp_errno   CONSTANT NUMBER(5) := -20000;
   g_job_run_type         dpp_job_types.jte_cd%TYPE;
   g_there_was_an_error   BOOLEAN := FALSE;

   -- parameter: SMTP host
   gk_prm_smtp_host              CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.host';
      
   -- parameter: SMTP port
   gk_prm_smtp_port              CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.port';

   -- parameter: SMTP domain
   gk_prm_smtp_domain            CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.domain';
      
   -- parameter: SMTP user name
   gk_prm_smtp_username          CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.username';
      
   -- parameter: SMTP wallet path
   gk_prm_smtp_wallet_path       CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.wallet_path';
      
   -- parameter: SMTP sender
   gk_prm_smtp_sender            CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.sender';
      
   -- parameter: SMTP developer recipient
   gk_prm_smtp_dev_recipient     CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.dev_recipient';

   -- parameter: SMTP default recipient
   gk_prm_smtp_default_recipient CONSTANT dpp_parameters.prr_name%TYPE     :=
      'smtp.default_recipient';

   -- number of dump index digitss
   gk_dump_idx_digits            CONSTANT PLS_INTEGER := 3;

   -- SMTP sender
   g_smtp_sender                       VARCHAR2(256);
   
   -- SMTP developer recipient
   g_smtp_dev_recipient                VARCHAR2(256);

   -- SMTP default recipient
   g_smtp_default_recipient            VARCHAR2(256);

END dpp_job_var;
/
--show errors package DPP_JOB_VAR;
