CREATE OR REPLACE PACKAGE dpp_job_krn AUTHID DEFINER IS
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

   -- routine previously stored in OPS$ORACLE under another name  (dc_dba_mgmt_grant_drop) to
   -- register the grants given by an application to the DPP utility
   -- the same routine allow revoking and listing of the existing privileges
   PROCEDURE check_priv_grantable(
      p_action          IN VARCHAR2
    , p_grantee         IN VARCHAR2 DEFAULT NULL
    , p_object_name     IN VARCHAR2 DEFAULT NULL
    , p_object_type     IN VARCHAR2 DEFAULT NULL
   );

   FUNCTION list_files(p_path IN VARCHAR2) 
   RETURN t_file_list;

   FUNCTION list_aws_files(p_path IN VARCHAR2) 
   RETURN t_file_list;

   PROCEDURE clean_dmp_dir(p_schema IN VARCHAR2);

   PROCEDURE import_schema(
      p_src_functional_name   IN dpp_schemas.functional_name%TYPE
    , p_trg_functional_name   IN dpp_schemas.functional_name%TYPE
    , p_options               IN VARCHAR2 DEFAULT NULL -- put here NETWORK_LINK for direct
   );

   PROCEDURE export_schema(
      p_functional_name       IN dpp_schemas.functional_name%TYPE
    , p_options               IN VARCHAR2 DEFAULT NULL
   );
                               
  FUNCTION import_schema(
     p_src_functional_name   IN dpp_schemas.functional_name%TYPE
   , p_trg_functional_name   IN dpp_schemas.functional_name%TYPE
   , p_options               IN VARCHAR2 DEFAULT NULL -- put here NETWORK_LINK for direct
  )
  RETURN dpp_job_runs.status%TYPE;

  FUNCTION export_schema(
     p_functional_name       IN dpp_schemas.functional_name%TYPE
   , p_options               IN VARCHAR2 DEFAULT NULL
  )
  RETURN dpp_job_runs.status%TYPE;     

   -- p_dpp_dir_useful for remote call otherwhise it uses the global 
   FUNCTION remove_file(p_filename IN VARCHAR2, p_dir IN VARCHAR2 DEFAULT NULL)  
   RETURN VARCHAR2;

   PROCEDURE remove_files_older(p_sma_name IN dpp_schemas.sma_name%TYPE
                               ,p_date     IN DATE
                               );
                              
   PROCEDURE remove_files_old_functional(p_src_functional IN VARCHAR2
                                     ,p_date        IN DATE
                                     );

   FUNCTION find_files(p_value   IN VARCHAR2
                      ,p_options IN NUMBER DEFAULT NULL
                      ) 
   RETURN dpp_job_var.gt_import_files_type;

   FUNCTION load_log_file(p_file_name IN VARCHAR2) 
   RETURN CLOB;
  
   FUNCTION compute_first_exec_time(p_date IN DATE) 
   RETURN DATE;
   
   FUNCTION check_schema_object_locked(p_object_type IN VARCHAR2,
                            p_schema      IN VARCHAR2) RETURN BOOLEAN;

   PROCEDURE transfer_dumpfiles(p_schema IN VARCHAR2, p_db_link IN VARCHAR2);
   
   FUNCTION transfer_dumpfiles(p_schema IN VARCHAR2, p_db_link IN VARCHAR2) 
   RETURN dpp_job_runs.status%TYPE;

   /**
   * Initialize SMTP server parameters.
   *
   * @param p_ite_name: instance name
   * @throws -20008: invalid instance name
   */
   PROCEDURE init_smtp(p_ite_name dpp_schemas.ite_name%TYPE);
   
END dpp_job_krn;
/
--show errors package DPP_JOB_KRN;