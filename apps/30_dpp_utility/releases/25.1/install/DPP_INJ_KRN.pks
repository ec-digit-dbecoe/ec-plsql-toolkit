create or replace PACKAGE dpp_inj_krn 
AUTHID DEFINER 
ACCESSIBLE BY (package DPP_INJ_TST, package DPP_JOB_KRN) 
IS
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

   -- previously DC routine to create routines and drop objects
   PROCEDURE create_procedure(p_schema       IN VARCHAR2
                             ,p_proc_name    IN VARCHAR2
                             ,p_proc_param   IN VARCHAR2 DEFAULT NULL
                             ,p_proc_declare IN VARCHAR2 DEFAULT NULL
                             ,p_proc_body    IN VARCHAR2
                             );

   PROCEDURE drop_object(p_schema      IN VARCHAR2
                        ,p_object_name IN VARCHAR2
                        ,p_object_type IN VARCHAR2
                        );

   PROCEDURE flush_hash_table;

   -- MAIN services
   PROCEDURE inj_drop_checks_for_imp(p_schema_name IN VARCHAR2);
   PROCEDURE inj_checks_for_imp(p_schema_name IN VARCHAR2);
   -- exp
   PROCEDURE inj_drop_checks_for_exp(p_schema_name IN VARCHAR2);
   PROCEDURE inj_checks_for_exp(p_schema_name IN VARCHAR2);
   -- check
   PROCEDURE inj_cfg_mdata_trans_imp(p_target_schema IN VARCHAR2, 
                                    p_option IN NUMBER := 1);
   PROCEDURE inj_drp_cfg_mdata_trans_imp(p_target_schema IN VARCHAR2);
   -- check
   -- PROCEDURE inj_config_user_metadata2(p_target_schema IN VARCHAR2);
   -- PROCEDURE inj_drop_config_user_metadata(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_check_running_jobs(p_target_schema IN VARCHAR2);
   PROCEDURE inj_check_running_jobs(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_run_job(p_target_schema IN VARCHAR2);
   PROCEDURE inj_run_job(p_target_schema IN VARCHAR2);
   PROCEDURE run_injected_job(p_target_schema IN VARCHAR2,
                             p_job_number    IN NUMBER,
                             p_simulation    IN BOOLEAN := FALSE);
   -- check
   PROCEDURE inj_drop_stop_job_safe(p_target_schema IN VARCHAR2);
   PROCEDURE inj_stop_job_safe(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_attatch_to_job(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_attatch_to_job(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_check_privs(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_check_privs(p_target_schema IN VARCHAR2);
   -- check
   --PROCEDURE inj_check_post_fix_dir(p_target_schema IN VARCHAR2);
   --PROCEDURE inj_drop_check_post_fix_dir(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_check_dir_object(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_check_dir_object(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_exec_proc(p_target_schema IN VARCHAR2);
   PROCEDURE inj_exec_proc(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_clear_all_db_links(p_target_schema IN VARCHAR2,
                                   p_list          IN VARCHAR2);
   PROCEDURE inj_drop_clear_all_db_links(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_exp_logfile(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_exp_logfile(p_target_shema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_imp_logfile(p_target_shema IN VARCHAR2);
   PROCEDURE inj_imp_logfile(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_config_metadata(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_config_metadata(p_target_shema IN VARCHAR2);
   -- check
      /**
   /**
   * Inject the procedure that configure the data filter.
   *
   * @param p_sma_id: schema ID
   * @param p_target_schema: target schema
   * @param p_usage: usage
   * @return: whether a data configuration procedure has been injected
   * @throws dpp_job_var.ge_injection_failed: injection code failure
   */
   FUNCTION inj_conf_data_filter(
      p_sma_id                IN  dpp_schemas.sma_id%TYPE
    , p_target_schema         IN  VARCHAR2
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
   ) RETURN BOOLEAN;
   /**
   * Drop the procedure that configures the data filters.
   *
   * @throws dpp_job_var.ge_injection_failed: injection failure
   */
   PROCEDURE inj_drop_conf_data_filter(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_config_pump_file(p_target_shema IN VARCHAR2);
   PROCEDURE inj_config_pump_file(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_config_remap(p_target_shema IN VARCHAR2);
   PROCEDURE inj_config_remap(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_config_set_parallel(p_target_shema IN VARCHAR2);
   PROCEDURE inj_config_set_parallel(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_create_import_job(p_target_shema IN VARCHAR2);
   PROCEDURE inj_create_import_job(p_target_schema IN VARCHAR2
                                  ,p_db_link       IN VARCHAR2
                                  );
   -- check
   PROCEDURE inj_write_start_time(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_write_start_time(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_create_export_job(p_target_schema IN VARCHAR2);
   PROCEDURE inj_create_export_job(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_config_estimate_stats(p_target_schema IN VARCHAR2);
   PROCEDURE inj_config_estimate_stats(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_drop_exp_table(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_exp_table(p_target_schema IN VARCHAR2);
   -- check
   --PROCEDURE inj_drop_checks_for_exp_safe(p_schema_name IN VARCHAR2);
   --
   PROCEDURE inj_drop_dpump_stop_all_jobs(p_target_schema IN VARCHAR2);
   PROCEDURE inj_dpump_stop_all_jobs(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_ref_constraint(p_target_schema IN VARCHAR2,
                                    p_list          IN VARCHAR2);
   PROCEDURE inj_drop_drop_ref_constraint(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_table(p_target_schema IN VARCHAR2, p_list IN VARCHAR2);
   PROCEDURE inj_drop_drop_table(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_synonym(p_target_schema IN VARCHAR2,
                             p_list          IN VARCHAR2);
   PROCEDURE inj_drop_drop_synonym(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_sequence(p_target_schema IN VARCHAR2,
                              p_list          IN VARCHAR2);
   PROCEDURE inj_drop_drop_sequence(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_source(p_target_schema IN VARCHAR2,
                            p_list          IN VARCHAR2);
   PROCEDURE inj_drop_drop_source(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_view(p_target_schema IN VARCHAR2, p_list IN VARCHAR2);
   PROCEDURE inj_drop_drop_view(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_kill_sessions(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_kill_sessions(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_conf_metadata_filter(p_sma_id        IN dpp_schemas.sma_id%TYPE
                                     ,p_target_schema IN VARCHAR2
                                     ,p_exclusionlist IN dpp_inj_var.gt_list_type
                                     );
   PROCEDURE inj_drop_conf_metadata_filter(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_drop_types(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_types(p_target_schema IN VARCHAR2, p_list IN VARCHAR2);
   --
   PROCEDURE inj_drop_purge_recyclebin(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_drop_recyclebin(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_trunc_table(p_target_schema IN VARCHAR2);
   PROCEDURE inj_trunc_table(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_indexes(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_drop_indexes(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_config_set_params_imp(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_config_set_params_imp(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the compression
   * method.
   *
   * @param p_target_schema: target schema
   * @param p_compression: compression method
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_compression(
      p_target_schema         IN  VARCHAR2
    , p_compression           IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the compression
   * method.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_compression(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the compression
   * algorithm.
   *
   * @param p_target_schema: target schema
   * @param p_algorithm: compression algorithm
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_compression_algo(
      p_target_schema         IN  VARCHAR2
    , p_algorithm             IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the compression
   * algorithm.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_compression_algo(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the encryption
   * method.
   *
   * @param p_target_schema: target schema
   * @param p_encryption: encryption method
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_encryption(
      p_target_schema         IN  VARCHAR2
    , p_encryption            IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the encryption
   * method.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encryption(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the encryption
   * mode.
   *
   * @param p_target_schema: target schema
   * @param p_encryption_mode: encryption mode
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_encrypt_mode(
      p_target_schema         IN  VARCHAR2
    , p_encryption_mode       IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the encryption
   * mode.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encrypt_mode(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the encryption
   * password.
   *
   * @param p_target_schema: target schema
   * @param p_encryption_pwd: encryption password
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_encrypt_pwd(
      p_target_schema         IN  VARCHAR2
    , p_encryption_pwd        IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the encryption
   * password.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encrypt_pwd(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the logtime
   * parameter.
   *
   * @param p_target_schema: target schema
   * @param p_logtime: logtime type
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_logtime(
      p_target_schema         IN  VARCHAR2
    , p_logtime               IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the logtime
   * parameter.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_logtime(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that creates the procedure that configures the metrics
   * parameter.
   *
   * @param p_target_schema: target schema
   * @param p_metrics: metrics flag
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_metrics(
      p_target_schema         IN  VARCHAR2
    , p_metrics               IN  VARCHAR2
   );
   /**
   * Inject the code that drops the procedure that configures the metrics
   * parameter.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_metrics(p_target_schema IN VARCHAR2);
   --
   PROCEDURE inj_drop_triggers(p_target_schema IN VARCHAR2,
                              p_list          IN VARCHAR2);
   PROCEDURE inj_drop_drop_triggers(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drop_recomp_inv_obj(p_target_schema IN VARCHAR2);
   PROCEDURE inj_recomp_inv_obj(p_target_schema IN VARCHAR2);
   -- check
   PROCEDURE inj_drp_cfg_tblspace_map(p_target_schema IN VARCHAR2);
   PROCEDURE inj_cfg_tblspace_map(p_target_schema   IN VARCHAR2,
                                 p_src_tablespace  IN VARCHAR2,
                                 p_dest_tablespace IN VARCHAR2);
   -- check 
   PROCEDURE inj_conf_flashbacktime(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_conf_flashbacktime(p_target_schema IN VARCHAR2);
   -- check  
   PROCEDURE inj_imp_metalink_429846_1(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_imp_metalink_429846_1(p_target_schema IN VARCHAR2);
   -- check
   --PROCEDURE inj_chk_locked_obj(p_target_schema IN VARCHAR2);
   --PROCEDURE inj_drop_chk_locked_obj(p_target_schema IN VARCHAR2);

   --PROCEDURE inj_config_exclusion (p_target_schema IN VARCHAR2, p_process IN VARCHAR2);
   --PROCEDURE inj_drop_config_exclusion (p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_AQ(p_target_schema IN VARCHAR2);
   PROCEDURE inj_drop_drop_AQ(p_target_schema IN VARCHAR2);
    --
   PROCEDURE inj_drop_mv(p_target_schema IN VARCHAR2, p_list IN VARCHAR2);
   PROCEDURE inj_drop_drop_mv(p_target_schema IN VARCHAR2);
   --
   /**
   * Inject the code that removes the stored procedure that checks whether a
   * database link is valid.
   *
   * @param p_target_schema: target database schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_check_db_link(
      p_target_schema      IN VARCHAR2
   );

   /**
   * Inject the code that creates the stored procedure that checks whether a
   * database link is valid.
   *
   * @param p_target_schema: target database schema
   * @param p_db_link_name: database link name
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_check_db_link(
      p_target_schema      IN VARCHAR2
    , p_db_link_name       IN VARCHAR2
   );

   /**
   * Inject the procedure that configure the data remap.
   *
   * @param p_sma_id: schema ID
   * @param p_target_schema: target schema
   * @param p_usage: usage
   * @return: whether a data remap procedure has been injected
   * @throws dpp_job_var.ge_injection_failed: injection code failure
   */
   FUNCTION inj_create_conf_data_remap(
      p_sma_id                IN  dpp_schemas.sma_id%TYPE
    , p_target_schema         IN  VARCHAR2
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
   ) RETURN BOOLEAN;

   /**
   * Drop the procedure that configures the data remaps.
   *
   * @throws dpp_job_var.ge_injection_failed: injection failure
   */
   PROCEDURE inj_drop_conf_data_remap(p_target_schema IN VARCHAR2);

END dpp_inj_krn;
/
