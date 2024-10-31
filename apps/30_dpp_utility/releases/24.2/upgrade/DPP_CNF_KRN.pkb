CREATE OR REPLACE PACKAGE BODY dpp_cnf_krn IS
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

/**
* This package implements API's for the configuration of DPP jobs.
*/

   /**
   * Raise application error.
   *
   * @param p_error_code: error code
   * @param p_error_message: error message
   */
   PROCEDURE raise_app_error(
      p_error_code            IN  SIMPLE_INTEGER
    , p_error_message         IN  VARCHAR2
   ) IS
   BEGIN
      RAISE_APPLICATION_ERROR(p_error_code, NVL(p_error_message, ' '));
   END raise_app_error;
   
   /**
   * Return the schema ID corresponding to the schema functional name passed as
   * parameter.
   *
   * @param p_functional_name: functional name of the schema whose the ID must
   * be returned
   * @return: the schema ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   */
   FUNCTION get_schema_id(
      p_functional_name       IN  dpp_schemas.functional_name%TYPE
   )
   RETURN dpp_schemas.sma_id%TYPE
   IS
   
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE;
      
   BEGIN
   
      -- Check parameters.
      IF p_functional_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid functional name'
         );
      END IF;
      
      -- Get the schema ID.
      <<get_schema_id>>
      BEGIN
         SELECT sma_id
           INTO schema_id
           FROM dpp_schemas
          WHERE functional_name = p_functional_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_funcname_nex
             , 'this functional name does not exist'
            );
      END get_schema_id;
      
      -- Return the schema ID.
      RETURN schema_id;
   
   END get_schema_id;
   
   /**
   * Create a database link in the target schema.
   *
   * @param p_target_schema: target schema
   * @param p_db_link_name: database link name
   * @param p_db_link_user: database link connection user ID
   * @param p_db_link_pwd: database link password
   * @param p_db_link_conn_string: database link connection string
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_cr_proc_priv: missing privilege (create proc)
   * @throws dpp_cnf_var.gk_errcode_ex_proc_priv: missing privilege (execute proc)
   * @throws dpp_cnf_var.gk_errcode_dr_proc_priv: missing privilege (drop proc)
   */
   PROCEDURE create_database_link (
      p_target_schema         IN  VARCHAR2
    , p_db_link_name          IN  VARCHAR2
    , p_db_link_user          IN  VARCHAR2
    , p_db_link_pwd           IN  VARCHAR2
    , p_db_link_conn_string   IN  VARCHAR2
   ) IS

      -- SQL statement
      sql_stmt          VARCHAR2(4000);

   BEGIN
      
      -- Check parameters.
      IF TRIM(p_target_schema) IS NULL OR 
         NOT REGEXP_LIKE(TRIM(p_target_schema), '^[A-Z,_]+$') THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema'
         );
      ELSIF TRIM(p_db_link_name) IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid database link name'
         );
      ELSIF TRIM(p_db_link_user) IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid database link user ID'
         );
      ELSIF TRIM(p_db_link_pwd) IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid database link password'
         );
      ELSIF TRIM(p_db_link_conn_string) IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid database link connection string'
         );
      END IF;

      -- Create the stored procedure that creates the database link in the
      -- target schema.
      <<create_proc>>
      BEGIN
         EXECUTE IMMEDIATE
         REPLACE(dpp_cnf_var.gk_db_link_proc
               , '{target_schema}'
               , TRIM(p_target_schema));
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_crproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_cr_proc_priv
             ,    'the user does not have the privilege to create a stored '
               || 'procedure in another schema (CREATE ANY PROCEDURE)'
            );
      END create_proc;
      
      -- Create the database link.
      <<create_db_link>>
      BEGIN
         sql_stmt := REPLACE(
            dpp_cnf_var.gk_db_link_creation
          , '{target_schema}'
          , TRIM(p_target_schema)
         );
         sql_stmt := REPLACE(
            sql_stmt, '{p_db_link_name}', TRIM(p_db_link_name));
         sql_stmt := REPLACE(sql_stmt, '{p_db_link_user}', TRIM(p_db_link_user));
         sql_stmt := REPLACE(sql_stmt, '{p_db_link_pwd}', TRIM(p_db_link_pwd));
         sql_stmt := REPLACE(
            sql_stmt
          , '{p_db_link_conn_string}'
          , TRIM(p_db_link_conn_string)
         );
         EXECUTE IMMEDIATE sql_stmt;
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_exproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_ex_proc_priv
             ,    'the user does not have the privilege to execute a stored '
               || 'procedure in another schema (EXECUTE ANY PROCEDURE)'
            );
      END create_db_link;
      
      -- Drop the procedure.
      <<drop_proc>>
      BEGIN
         EXECUTE IMMEDIATE
         REPLACE(
            dpp_cnf_var.gk_db_link_drop
          , '{target_schema}'
          , TRIM(p_target_schema)
         );
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_drproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_dr_proc_priv
             ,    'the user does not have the privilege to drop a stored '
               || 'procedure in another schema (DROP ANY PROCEDURE)'
            );
      END drop_proc;
      
   END create_database_link;

   /**
   * Drop a database link in the target schema.
   *
   * @param p_target_schema: target schema
   * @param p_db_link_name: database link name
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_cr_proc_priv: missing privilege (create proc)
   * @throws dpp_cnf_var.gk_errcode_ex_proc_priv: missing privilege (execute proc)
   * @throws dpp_cnf_var.gk_errcode_dr_proc_priv: missing privilege (drop proc)
   */
   PROCEDURE drop_database_link (
      p_target_schema         IN  VARCHAR2
    , p_db_link_name          IN  VARCHAR2
   ) IS

      -- SQL statement
      sql_stmt          VARCHAR2(4000);

   BEGIN
      
      -- Check parameters.
      IF TRIM(p_target_schema) IS NULL OR 
         NOT REGEXP_LIKE(TRIM(p_target_schema), '^[A-Z,_]+$') THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema'
         );
      ELSIF TRIM(p_db_link_name) IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid database link name'
         );
      END IF;

      -- Create the stored procedure that drops the database link in the
      -- target schema.
      <<create_proc>>
      BEGIN
         EXECUTE IMMEDIATE
         REPLACE(dpp_cnf_var.gk_db_link_drop_proc
               , '{target_schema}'
               , TRIM(p_target_schema));
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_crproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_cr_proc_priv
             ,    'the user does not have the privilege to create a stored '
               || 'procedure in another schema (CREATE ANY PROCEDURE)'
            );
      END create_proc;
      
      -- Drop the database link.
      <<drop_db_link>>
      BEGIN
         sql_stmt := REPLACE(
            dpp_cnf_var.gk_db_link_deletion
          , '{target_schema}'
          , TRIM(p_target_schema)
         );
         sql_stmt := REPLACE(
            sql_stmt, '{p_db_link_name}', TRIM(p_db_link_name));
         EXECUTE IMMEDIATE sql_stmt;
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_exproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_ex_proc_priv
             ,    'the user does not have the privilege to execute a stored '
               || 'procedure in another schema (EXECUTE ANY PROCEDURE)'
            );
      END drop_db_link;
      
      -- Drop the procedure.
      <<drop_proc>>
      BEGIN
         EXECUTE IMMEDIATE
         REPLACE(
            dpp_cnf_var.gk_db_link_drop_drop
          , '{target_schema}'
          , TRIM(p_target_schema)
         );
      EXCEPTION
         WHEN dpp_cnf_var.ge_exc_ins_priv_drproc THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_dr_proc_priv
             ,    'the user does not have the privilege to drop a stored '
               || 'procedure in another schema (DROP ANY PROCEDURE)'
            );
      END drop_proc;
      
   END drop_database_link;
   
   /**
   * Insert a database instance.
   * @param p_instance_name: database instance name
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_production_flag: production flag
   * @param p_env_name: environment name
   * @param p_date_creat: creaton date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_exist: instance name already
   * exists
   */
   PROCEDURE insert_instance(
      p_instance_name         IN  dpp_instances.ite_name%TYPE
    , p_descr_eng             IN  dpp_instances.descr_eng%TYPE
    , p_descr_fra             IN  dpp_instances.descr_fra%TYPE
    , p_production_flag       IN  dpp_instances.production_flag%TYPE := NULL
    , p_env_name              IN  dpp_instances.env_name%TYPE
    , p_date_creat            IN  dpp_instances.date_creat%TYPE      := NULL
    , p_user_creat            IN  dpp_instances.user_creat%TYPE      := NULL
    , p_date_modif            IN  dpp_instances.date_modif%TYPE      := NULL
    , p_user_modif            IN  dpp_instances.user_modif%TYPE      := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_instance_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid instance name'
         );
      ELSIF p_descr_eng IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid english description'
         );
      ELSIF p_descr_fra IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid french description'
         );
      ELSIF p_env_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid environment name'
         );
      END IF;
      
      -- Check whether the instance name does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_instances
          WHERE ite_name = p_instance_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_inst_name_exist
          , 'this instance name already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Insert the instance.
      INSERT INTO dpp_instances(
         ite_name
       , descr_eng
       , descr_fra
       , production_flag
       , env_name
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         p_instance_name
       , p_descr_eng
       , p_descr_fra
       , p_production_flag
       , p_env_name
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
         
   END insert_instance;

   /**
   * Delete a database instance.
   *
   * @param p_instance_name: name of the instance to be deleted
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: insance name does not exist
   * @throws dpp_cnf_var.gk_errcode_inst_name_ref: instance name referenced by
   * child data
   */
   PROCEDURE delete_instance(
      p_instance_name         IN  dpp_instances.ite_name%TYPE
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
      -- Check parameters.
      IF p_instance_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid instance name'
         );
      END IF;

      -- Check whether the instance exists.
      <<check_inst_exist>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_instances
          WHERE ite_name = p_instance_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN 
            raise_app_error(
               dpp_cnf_var.gk_errcode_inst_name_nex
             , 'this instance name does not exist'
            );
      END check_inst_exist;
      
      -- Check whether the instance name is referenced by parameters.
      <<check_ref_params>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_parameters
          WHERE ite_name = p_instance_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_inst_name_ref
          , 'instance name referenced by some parameters'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_params;
      
      -- Check whether the instance name is referenced by schemas.
      <<check_ref_schemas>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schemas
          WHERE ite_name = p_instance_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_inst_name_ref
          , 'instance name referenced by some schemas'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_schemas;
      
      -- Delete the instance.
      DELETE dpp_instances
       WHERE ite_name = p_instance_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inst_name_nex
          , 'this instance name does not exist'
         );
      END IF;
      
   END delete_instance;
   
   /**
   * Update a database instance.
   * @param p_instance_name: name of the database instance to be updated
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_production_flag: production flag
   * @param p_env_name: environment name
   * @param p_date_creat: creaton date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance name does not exist
   */
   PROCEDURE update_instance(
      p_instance_name         IN  dpp_instances.ite_name%TYPE
    , p_descr_eng             IN  dpp_instances.descr_eng%TYPE       := NULL
    , p_descr_fra             IN  dpp_instances.descr_fra%TYPE       := NULL
    , p_production_flag       IN  dpp_instances.production_flag%TYPE := NULL
    , p_env_name              IN  dpp_instances.env_name%TYPE        := NULL
    , p_date_creat            IN  dpp_instances.date_creat%TYPE      := NULL
    , p_user_creat            IN  dpp_instances.user_creat%TYPE      := NULL
    , p_date_modif            IN  dpp_instances.date_modif%TYPE      := NULL
    , p_user_modif            IN  dpp_instances.user_modif%TYPE      := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_instance_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid instance name'
         );
      END IF;
      
      -- Check whether the instance name exists.
      <<check_pk_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_instances
          WHERE ite_name = p_instance_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_inst_name_nex
             , 'this instance name does not exist'
            );
      END check_pk_exists;
      
      -- Update the instance.
      UPDATE dpp_instances
         SET descr_eng = NVL(p_descr_eng, descr_eng)
           , descr_fra = NVL(p_descr_fra, descr_fra)
           , production_flag = NVL(p_production_flag, production_flag)
           , env_name = NVL(p_env_name, env_name)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE ite_name = p_instance_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inst_name_nex
          , 'this instance name does not exist'
         );
      END IF;
         
   END update_instance;

   /**
   * Insert a new schema type.
   *
   * @param p_schema_type_name: schema type name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid schema type name
   * @throws dpp_cnf_var.gk_errcode_ste_name_ex: schema type already exists
   */
   PROCEDURE insert_schema_type(
      p_schema_type_name      IN  dpp_schema_types.ste_name%TYPE
    , p_date_creat            IN  dpp_schema_types.date_creat%TYPE   := NULL
    , p_user_creat            IN  dpp_schema_types.user_creat%TYPE   := NULL
    , p_date_modif            IN  dpp_schema_types.date_modif%TYPE   := NULL
    , p_user_modif            IN dpp_schema_types.user_modif%TYPE    := NULL
   ) IS

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Check parameters.
      IF p_schema_type_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema type name'
         );
      END IF;

      -- Check whether the schema type name is unique.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_types
          WHERE ste_name = p_schema_type_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_ste_name_ex
          , 'this schema type name already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;

      -- Insert the schema type.
      INSERT INTO dpp_schema_types (
         ste_name
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         p_schema_type_name
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );

   END insert_schema_type;

   /**
   * Delete a schema type.
   *
   * @param p_schema_type_name: name of the schema type to be deleted
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid schema type name
   * @throws dpp_cnf_var.gk_errcode_ste_name_nex: schema type name does not
   * exist
   * @throws dpp_cnf_var.gk_errorcode_ste_ref: schema type referenced by
   * child data
   */
   PROCEDURE delete_schema_type(
      p_schema_type_name      IN  dpp_schema_types.ste_name%TYPE
   ) IS

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Check parameters.
      IF p_schema_type_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema type name'
         );
      END IF;

      -- Check whether the schema type name exists.
      <<check_pk_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_types
          WHERE ste_name = p_schema_type_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_ste_name_nex
            , 'this schema type name does not exist'
            );
      END check_pk_exists;

      -- Check whether the schema type is referenced by some schemas
      <<check_ref_schema>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schemas
          WHERE ste_name = p_schema_type_name;
         raise_app_error(
            dpp_cnf_var.gk_errorcode_ste_ref
          , 'this schema type is referenced by some schemas'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_schema;

      -- Delete the schema type.
      DELETE dpp_schema_types
       WHERE ste_name = p_schema_type_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_ste_name_nex
          , 'this schema type name does not exist'
         );
      END IF;

   END delete_schema_type;
   
   /**
   * Update a schema type.
   *
   * @param p_schema_type_name: name of the schema type to be updated
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid schema type name
   * @throws dpp_cnf_var.gk_errcode_ste_name_nex: schema type does not exist
   */
   PROCEDURE update_schema_type(
      p_schema_type_name      IN  dpp_schema_types.ste_name%TYPE
    , p_date_creat            IN  dpp_schema_types.date_creat%TYPE   := NULL
    , p_user_creat            IN  dpp_schema_types.user_creat%TYPE   := NULL
    , p_date_modif            IN  dpp_schema_types.date_modif%TYPE   := NULL
    , p_user_modif            IN  dpp_schema_types.user_modif%TYPE   := NULL
   ) IS

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Check parameters.
      IF p_schema_type_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema type name'
         );
      END IF;

      -- Check whether the schema type exists.
      <<check_pk_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_types
          WHERE ste_name = p_schema_type_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_ste_name_nex
             , 'this schema type name does not exist'
            );
      END check_pk_exists;

      -- Update the schema type.
      UPDATE dpp_schema_types
         SET date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE ste_name = p_schema_type_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_ste_name_nex
          , 'this schema type name does not exist'
         );
      END IF;

   END update_schema_type;
   
   /**
   * Insert a new role.
   *
   * @param p_role_name: role name
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_role_exists: role name already exists
   */
   PROCEDURE insert_role(
      p_role_name             IN  dpp_roles.rle_name%TYPE
    , p_descr_eng             IN  dpp_roles.descr_eng%TYPE
    , p_descr_fra             IN  dpp_roles.descr_fra%TYPE
    , p_date_creat            IN  dpp_roles.date_creat%TYPE       := NULL
    , p_user_creat            IN  dpp_roles.user_creat%TYPE       := NULL
    , p_date_modif            IN  dpp_roles.date_modif%TYPE       := NULL
    , p_user_modif            IN  dpp_roles.user_modif%TYPE       := NULL
   ) IS  
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_role_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid role name'
         );
      ELSIF p_descr_eng IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid english description'
         );
      ELSIF p_descr_fra IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid french description'
         );
      END IF;
      
      -- Check whether the role name does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_roles
          WHERE rle_name = p_role_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_role_exists
          , 'this role name already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Insert the role.
      INSERT INTO dpp_roles (
         rle_name
       , descr_eng
       , descr_fra
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         p_role_name
       , p_descr_eng
       , p_descr_fra
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
   
   END insert_role;

   /**
   * Delete a role.
   *
   * @param p_role_name: name of the role to be deleted
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_role_nex: role name does not exists
   * @throws dpp_cnf_var.gk_errcode_role_ref: role referenced by soem child
   * data
   */
   PROCEDURE delete_role(
      p_role_name             IN  dpp_roles.rle_name%TYPE
   ) IS

      -- flag
      flag                    CHAR(1);

   BEGIN
   
      -- Check parameters.
      IF p_role_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid role name'
         );
      END IF;
      
      -- Check whether the role name exists.
      <<check_pk_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_roles
          WHERE rle_name = p_role_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_role_nex
             , 'this role name does not exist'
            );
      END check_pk_exists;

      -- Check whether the role is referenced by a schema.
      <<check_ref_schema>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schemas
          WHERE rle_name = p_role_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_role_ref
          , 'this role is referenced by some schemas'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_schema;

      -- Delete the role.
      DELETE dpp_roles
       WHERE rle_name = p_role_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_role_nex
          , 'this role name does not exist'
         );
      END IF;
      
   END delete_role;

   /**
   * Update a role.
   *
   * @param p_role_name: nme of the role to be updated
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_role_nex: role name does not exists
   */
   PROCEDURE update_role(
      p_role_name             IN  dpp_roles.rle_name%TYPE
    , p_descr_eng             IN  dpp_roles.descr_eng%TYPE        := NULL
    , p_descr_fra             IN  dpp_roles.descr_fra%TYPE        := NULL
    , p_date_creat            IN  dpp_roles.date_creat%TYPE       := NULL
    , p_user_creat            IN  dpp_roles.user_creat%TYPE       := NULL
    , p_date_modif            IN  dpp_roles.date_modif%TYPE       := NULL
    , p_user_modif            IN  dpp_roles.user_modif%TYPE       := NULL
   ) IS  
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_role_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid role name'
         );
      END IF;
      
      -- Check whether the role name does exists.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_roles
          WHERE rle_name = p_role_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_role_nex
             , 'this role does not exist'
            );
      END check_pk_unique;
      
      -- Update the role.
      UPDATE dpp_roles
         SET descr_eng = NVL(p_descr_eng, descr_eng)
           , descr_fra = NVL(p_descr_fra, descr_fra)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE rle_name = p_role_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_role_nex
          , 'this role does not exist'
         );
      END IF;
   
   END update_role;

   /**
   * Insert a new schema.
   * @param p_schema_id: schema ID
   * @param p_instance_name: instance name
   * @param p_role_name: role name
   * @param p_schema_type_name: schema type name
   * @param p_functional_name: functional name
   * @param p_schema_name: shema name
   * @param p_production_flag: production flag
   * @param p_date_from: date from
   * @param p_date_to: date to
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modificaion user ID
   * @return: schema ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_exists: schema ID already exists
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_ex: functional name already
   * exists
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance name does not
   * exist
   * @throws dpp_cnf_var.gk_errcode_role_nex: role name does not exist
   * @throws dpp_cnf_var.gk_errcode_ste_name_nex: schema type name does not
   * exist
   */
   FUNCTION insert_schema(
      p_schema_id             IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_instance_name         IN  dpp_schemas.ite_name%TYPE
    , p_role_name             IN  dpp_schemas.rle_name%TYPE          := NULL
    , p_schema_type_name      IN  dpp_schemas.ste_name%TYPE          := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE
    , p_schema_name           IN  dpp_schemas.sma_name%TYPE
    , p_production_flag       IN  dpp_schemas.production_flag%TYPE   := NULL
    , p_date_from             IN  dpp_schemas.date_from%TYPE         := NULL
    , p_date_to               IN  dpp_schemas.date_to%TYPE           := NULL
    , p_date_creat            IN  dpp_schemas.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_schemas.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_schemas.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_schemas.user_modif%TYPE        := NULL
   )
   RETURN dpp_schemas.sma_id%TYPE
   IS

      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE;

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Compute the schema ID if needed.
      IF p_schema_id IS NULL THEN
         SELECT MAX(sma_id) + 1
           INTO schema_id
           FROM dpp_schemas;
         IF schema_id IS NULL THEN
            schema_id := 1;
         END IF;
      ELSE
         schema_id := p_schema_id;
      END IF;

      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_instance_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid instance name'
         );
      ELSIF p_schema_name IS NULL THEN 
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema name'
         );
      ELSIF p_functional_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid functional name'
         );
      END IF;

      -- Check whether the schema ID does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_exists
          , 'this schema ID already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;

      -- Check whether the functional name is unique.
      <<check_func_name_unique>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schemas
          WHERE functional_name = p_functional_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_funcname_ex
          , 'this functional name already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_func_name_unique;

      -- Check whether the instance exists.
      <<check_inst_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_instances
          WHERE ite_name = p_instance_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_inst_name_nex
             , 'this instance name does not exist'
            );
      END check_inst_exists;

      -- Check whether the role exists.
      IF p_role_name IS NOT NULL THEN
         <<check_role_exists>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_roles
             WHERE rle_name = p_role_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_role_nex
                , 'this role doew not exist'
               );
         END check_role_exists;
      END IF;

      -- Check whether the schema type exists.
      IF p_schema_type_name IS NOT NULL THEN
         <<check_type_exists>>
         BEGIN 
            SELECT '1'
              INTO flag
              FROM dpp_schema_types
             WHERE ste_name = p_schema_type_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_ste_name_nex
                , 'this schema type does not exist'
               );
         END check_type_exists;
      END IF;

      -- Insert the schema.
      INSERT INTO dpp_schemas (
         sma_id
       , ite_name
       , rle_name
       , ste_name
       , functional_name
       , sma_name
       , production_flag
       , date_from
       , date_to
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id
       , p_instance_name
       , p_role_name
       , p_schema_type_name
       , p_functional_name
       , p_schema_name
       , p_production_flag
       , NVL(p_date_from, SYSDATE)
       , p_date_to
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );

      -- Return the schema ID.
      RETURN schema_id;

   END insert_schema;

   /**
   * Delete a schema.
   *
   * @param p_schema_id: ID of the schema to be deleted
   * @param p_functional_name: functional name of the schema to be deleted
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: schema functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema ID does not exist
   * @throws dpp_cnf_var.gk_errcode_schema_ref: schema referenced by child data
   */
   PROCEDURE delete_schema(
      p_schema_id             IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
   ) IS

      -- flag
      flag                    CHAR(1);

      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE                := NULL;

   BEGIN

      -- Get the schema ID if not provided.
      IF p_schema_id IS NULL THEN   
         IF p_functional_name IS NOT NULL THEN
            <<get_schema_id>>
            BEGIN
               SELECT sma_id
                 INTO schema_id
                 FROM dpp_schemas
                WHERE functional_name = p_functional_name;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  raise_app_error(
                     dpp_cnf_var.gk_errcode_schema_funcname_nex
                   , 'this functional name does not exist'
                  );
            END get_schema_id;
         ELSE
            schema_id := p_schema_id;
         END IF;
      ELSE
         schema_id := p_schema_id;
      END IF;

         -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      END IF;

      -- Check whether the schema ID exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;

      -- Check whether the schema is referenced by actions.
      <<check_ref_actions>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some actions'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_actions;

      -- Check whether the schema is referenced by some job runs.
      <<check_ref_job_runs>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_job_runs
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some job runs'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_job_runs;

      -- Check whether the schema is referenced by some no drop objects.
      <<check_ref_nodrop>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some "no drop" objects'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_nodrop;

      -- Check whether the schema is referenced by some recipients.
      <<check_ref_recip>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_recipients
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some mail recipients'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_recip;

      -- Check whether the schema is referenced by some schema options.
      <<check_ref_options>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_options
          WHERE sma_id = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some schema options'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_options;

      -- Check whether the schema is referenced by some schema relationships.
      <<check_ref_rel>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_relations
          WHERE sma_id_from = schema_id
             OR sma_id_to = schema_id;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_ref
          , 'this schema is referenced by some schema relationships'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_ref_rel;

      -- Delete the schema.
      DELETE dpp_schemas
       WHERE sma_id = schema_id;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_nex
          , 'this schema ID does not exist'
         );
      END IF;

   END delete_schema;

   /**
   * Update a schema.
   * @param p_schema_id: ID of the schema to be updated
   * @param p_instance_name: instance name
   * @param p_role_name: role name
   * @param p_schema_type_name: schema type name
   * @param p_functional_name: functional name
   * @param p_schema_name: shema name
   * @param p_production_flag: production flag
   * @param p_date_from: date from
   * @param p_date_to: date to
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modificaion user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_ex: functional name already
   * exists
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance name does not
   * exist
   * @throws dpp_cnf_var.gk_errcode_role_nex: role name does not exist
   * @throws dpp_cnf_var.gk_errcode_ste_name_nex: schema type name does not
   * exist
   */
   PROCEDURE update_schema(
      p_schema_id             IN  dpp_schemas.sma_id%TYPE
    , p_instance_name         IN  dpp_schemas.ite_name%TYPE          := NULL
    , p_role_name             IN  dpp_schemas.rle_name%TYPE          := NULL
    , p_schema_type_name      IN  dpp_schemas.ste_name%TYPE          := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_schema_name           IN  dpp_schemas.sma_name%TYPE          := NULL
    , p_production_flag       IN  dpp_schemas.production_flag%TYPE   := NULL
    , p_date_from             IN  dpp_schemas.date_from%TYPE         := NULL
    , p_date_to               IN  dpp_schemas.date_to%TYPE           := NULL
    , p_date_creat            IN  dpp_schemas.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_schemas.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_schemas.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_schemas.user_modif%TYPE        := NULL
   ) IS

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Check parameters.
      IF p_schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      END IF;

      -- Check whether the schema ID does not already exist.
      <<check_pk_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = p_schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_pk_unique;

      -- Check whether the functional name is unique.
      IF p_functional_name IS NOT NULL THEN
         <<check_func_name_unique>>
         BEGIN
            SELECT DISTINCT '1'
              INTO flag
              FROM dpp_schemas
             WHERE functional_name = p_functional_name
               AND sma_id != p_schema_id;
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_funcname_ex
             , 'this functional name already exists'
            );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END check_func_name_unique;
      END IF;

      -- Check whether the instance exists.
      IF p_instance_name IS NOT NULL THEN
         <<check_inst_exists>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_instances
             WHERE ite_name = p_instance_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_inst_name_nex
                , 'this instance name does not exist'
               );
         END check_inst_exists;
      END IF;

      -- Check whether the role exists.
      IF p_role_name IS NOT NULL THEN
         <<check_role_exists>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_roles
             WHERE rle_name = p_role_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_role_nex
                , 'this role does not exist'
               );
         END check_role_exists;
      END IF;

      -- Check whether the schema type exists.
      IF p_schema_type_name IS NOT NULL THEN
         <<check_type_exists>>
         BEGIN 
            SELECT '1'
              INTO flag
              FROM dpp_schema_types
             WHERE ste_name = p_schema_type_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_ste_name_nex
                , 'this schema type does not exist'
               );
         END check_type_exists;
      END IF;

      -- Insert the schema.
      UPDATE dpp_schemas
         SET ite_name = NVL(p_instance_name, ite_name)
           , rle_name = NVL(p_role_name, rle_name)
           , ste_name = NVL(p_schema_type_name, ste_name)
           , functional_name = NVL(p_functional_name, functional_name)
           , sma_name = NVL(p_schema_name, sma_name)
           , production_flag = NVL(p_production_flag, production_flag)
           , date_from = NVL(p_date_from, date_from)
           , date_to = NVL(p_date_to, date_to)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id = p_schema_id;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_nex
          , 'this schema ID does not exist'
         );
      END IF;

   END update_schema;
   
   /**
   * Clean up the job runs and job logs.
   *
   * @param p_schema_id: ID of the schema whose job runs must be cleaned up
   * @param p_functional_name: functional name of the schema whose job runs
   * must be cleaned up
   * @param p_date_started: date of the oldest job run to be cleaned up
   * @param p_date_eneded: date of the newest job runs to be cleaned up
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name does
   * not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema ID does not exist
   */
   PROCEDURE clean_up_job_runs(
      p_schema_id             IN  dpp_job_runs.sma_id%TYPE           := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_date_started          IN  dpp_job_runs.date_started%TYPE     := NULL
    , p_date_ended            IN  dpp_job_runs.date_ended%TYPE       := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
   
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE              := NULL;
      
   BEGIN
   

      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      END IF;
      
      -- Check whether the schema ID exist.
      <<check_schema_ex>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_ex;
      
      -- Delete the job logs.
      DELETE dpp_job_logs
       WHERE dpp_job_logs.jrn_id IN (
               SELECT dpp_job_runs.jrn_id
                 FROM dpp_job_runs
                WHERE sma_id = schema_id
                  AND (p_date_started IS NULL OR date_started >= p_date_started)
                  AND (p_date_ended IS NULL OR date_ended <= p_date_ended)
             );
             
      -- Delete the job runs.
      DELETE dpp_job_runs
       WHERE sma_id = schema_id
         AND (p_date_started IS NULL OR date_started >= p_date_started)
         AND (p_date_ended IS NULL OR date_ended <= p_date_ended);

   END clean_up_job_runs;
   
   /**
   * Insert a "no drop" object.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_object_name: object name
   * @param p_object_type: object type
   * @param p_active_flag: active flag
   * @param p_date_creat: creaton date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema ID does no exist
   * @throws dpp_cnf_var.gk_errcode_nodropobj_ex: "no drop" object already
   * exists
   */
   PROCEDURE insert_nodrop_object(
      p_schema_id             IN  dpp_nodrop_objects.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_object_name           IN  dpp_nodrop_objects.object_name%TYPE
    , p_object_type           IN  dpp_nodrop_objects.object_type%TYPE
    , p_active_flag           IN  dpp_nodrop_objects.active_flag%TYPE
    , p_date_creat            IN  dpp_nodrop_objects.date_creat%TYPE    := NULL
    , p_user_creat            IN  dpp_nodrop_objects.user_creat%TYPE    := NULL
    , p_date_modif            IN  dpp_nodrop_objects.date_modif%TYPE    := NULL
    , p_user_modif            IN  dpp_nodrop_objects.user_modif%TYPE    := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE                   := NULL;
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_object_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object name'
         );
      ELSIF p_object_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object type'
         );
      ELSIF p_active_flag IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid active flag'
         );
      END IF;
      
      -- Check whether the schema ID exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Check whether the object does not already exist.
      <<check_object_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id
            AND object_type = p_object_type
            AND object_name = p_object_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_nodropobj_ex
          , 'this "no drop" object already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_object_exists;
      
      -- Insert the object.
      INSERT INTO dpp_nodrop_objects (
         sma_id
       , object_name
       , object_type
       , active_flag
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id
       , p_object_name
       , p_object_type
       , p_active_flag
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
      
   END insert_nodrop_object;
   
   /**
   * Delete a "no drop" object.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_object_name: object name
   * @param p_object_type: object type
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_nodropobj_nex: "no drop" object does not
   * exist
   */
   PROCEDURE delete_nodrop_object(
      p_schema_id             IN  dpp_nodrop_objects.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_object_name           IN  dpp_nodrop_objects.object_name%TYPE
    , p_object_type           IN  dpp_nodrop_objects.object_type%TYPE
   ) IS
   
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE       := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_object_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object name'
         );
      ELSIF p_object_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object type'
         );
      END IF;
      
      -- Delete the object.
      DELETE dpp_nodrop_objects
       WHERE sma_id = schema_id
         AND object_type = p_object_type
         AND object_name = p_object_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_nodropobj_nex
          , 'this "no drop" object does not exist'
         );
      END IF;
      
   END delete_nodrop_object;

   /**
   * Update a "no drop" object.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_object_name: object name
   * @param p_object_type: object type
   * @param p_active_flag: active flag
   * @param p_date_creat: creaton date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema ID does no exist
   * @throws dpp_cnf_var.gk_errcode_nodropobj_nex: "no drop" object does not
   * exist
   */
   PROCEDURE update_nodrop_object(
      p_schema_id             IN  dpp_nodrop_objects.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_object_name           IN  dpp_nodrop_objects.object_name%TYPE
    , p_object_type           IN  dpp_nodrop_objects.object_type%TYPE
    , p_active_flag           IN  dpp_nodrop_objects.active_flag%TYPE   := NULL
    , p_date_creat            IN  dpp_nodrop_objects.date_creat%TYPE    := NULL
    , p_user_creat            IN  dpp_nodrop_objects.user_creat%TYPE    := NULL
    , p_date_modif            IN  dpp_nodrop_objects.date_modif%TYPE    := NULL
    , p_user_modif            IN  dpp_nodrop_objects.user_modif%TYPE    := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE                   := NULL;
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_object_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object name'
         );
      ELSIF p_object_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object type'
         );
      END IF;
      
      -- Check whether the schema ID exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Update the object.
      UPDATE dpp_nodrop_objects
         SET active_flag = NVL(p_active_flag, active_flag)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id = schema_id
         AND object_type = p_object_type
         AND object_name = p_object_name;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_nodropobj_nex
          , 'this "no drop" object does not exist'
         );
      END IF;
            
   END update_nodrop_object;

   /**
   * Insert a new action.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_block_text: block text
   * @param p_active_flag: active flag
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_exists: action already exists
   */
   PROCEDURE insert_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_block_text            IN  dpp_actions.block_text%TYPE
    , p_active_flag           IN  dpp_actions.active_flag%TYPE
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   ) IS

      -- schema ID
      schema_id               dpp_actions.sma_id%TYPE                := NULL;

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_atn_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN usage'
         );
      ELSIF p_atn_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN type'
         );
      ELSIF p_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid execution order'
         );
      ELSIF p_block_text IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid block text'
         );
      ELSIF p_active_flag IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid active flag'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Check whether the action does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_exec_order;
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_exists
          , 'this action already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Insert the action.
      INSERT INTO dpp_actions (
         sma_id
       , atn_usage
       , atn_type
       , execution_order
       , block_text
       , active_flag
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id
       , p_atn_usage
       , p_atn_type
       , p_exec_order
       , p_block_text
       , p_active_flag
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
      
   END insert_action;
   
   /**
   * Delete an action.
   *
   * @param p_schema_id: ID of the schema whose action must be deleted
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_nex: action does not exist
   */
   PROCEDURE delete_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
   ) IS

      -- schema ID
      schema_id               dpp_actions.sma_id%TYPE                := NULL;

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_atn_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN usage'
         );
      ELSIF p_atn_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN type'
         );
      ELSIF p_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid execution order'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Check whether the action exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_exec_order;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_action_nex
             , 'this action does not exist'
            );
      END check_pk;
      
      -- Insert the action.
      DELETE dpp_actions
       WHERE sma_id = schema_id
         AND atn_usage = p_atn_usage
         AND atn_type = p_atn_type
         AND execution_order = p_exec_order;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_nex
          , 'this action does not exist'
         );
      END IF;
      
   END delete_action;
   
   /**
   * Update an action.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_block_text: block text
   * @param p_active_flag: active flag
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_nex: action does not exist
   */
   PROCEDURE update_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_block_text            IN  dpp_actions.block_text%TYPE        := NULL
    , p_active_flag           IN  dpp_actions.active_flag%TYPE       := NULL
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   ) IS

      -- schema ID
      schema_id               dpp_actions.sma_id%TYPE                := NULL;

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_atn_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN usage'
         );
      ELSIF p_atn_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN type'
         );
      ELSIF p_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid execution order'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Check whether the action exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_exec_order;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_action_nex
             , 'this action does not exist'
            );
      END check_pk;
      
      -- Update the action.
      UPDATE dpp_actions
         SET block_text = NVL(p_block_text, block_text)
           , active_flag = NVL(p_active_flag, active_flag)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id = schema_id
         AND atn_usage = p_atn_usage
         AND atn_type = p_atn_type
         AND execution_order = p_exec_order;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_nex
          , 'this action does not exist'
         );
      END IF;
      
   END update_action;
   
   /**
   * Update an action execution order.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_curr_exec_order: current execution order
   * @param p_new_exec_order: new execution order
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_nex: action does not exist
   * @throws dpp_cnf_var.gk_action_exists: new execution order already used
   */
   PROCEDURE update_action_exec_order(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_curr_exec_order       IN  dpp_actions.execution_order%TYPE
    , p_new_exec_order        IN  dpp_actions.execution_order%TYPE
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   ) IS

      -- schema ID
      schema_id               dpp_actions.sma_id%TYPE                := NULL;

      -- flag
      flag                    CHAR(1);

   BEGIN

      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_atn_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN usage'
         );
      ELSIF p_atn_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN type'
         );
      ELSIF p_curr_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid current execution order'
         );
      ELSIF p_new_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid new execution order'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema_exists>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema ID does not exist'
            );
      END check_schema_exists;
      
      -- Check whether the action exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_curr_exec_order;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_action_nex
             , 'this action does not exist'
            );
      END check_pk;
      
      -- Check whether the new execution order is now already used.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_new_exec_order;
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_exists
          , 'the new action execution order is already used'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Update the action.
      UPDATE dpp_actions
         SET execution_order = p_new_exec_order
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id = schema_id
         AND atn_usage = p_atn_usage
         AND atn_type = p_atn_type
         AND execution_order = p_curr_exec_order;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_nex
          , 'this action does not exist'
         );
      END IF;
      
   END update_action_exec_order;
   
   /**
   * Insert a parameter.
   *
   * @param p_param_name: parameter name
   * @param p_param_value: parameter value
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_instance_name: instance name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance does not exist
   * @throws dpp_cnf_var.gk_errcode_param_exists: parameter already exists
   */
   PROCEDURE insert_parameter(
      p_param_name            IN  dpp_parameters.prr_name%TYPE
    , p_param_value           IN  dpp_parameters.prr_value%TYPE
    , p_descr_eng             IN  dpp_parameters.descr_eng%TYPE
    , p_descr_fra             IN  dpp_parameters.descr_fra%TYPE
    , p_instance_name         IN  dpp_parameters.ite_name%TYPE          := NULL
    , p_date_creat            IN  dpp_parameters.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_parameters.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_parameters.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_parameters.user_modif%TYPE        := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_param_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid parameter name'
         );
      ELSIF p_param_value IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid parameter value'
         );
      ELSIF p_descr_eng IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid english description'
         );
      ELSIF p_descr_fra IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid french description'
         );
      END IF;
      
      -- Check whether the instance name exists.
      IF p_instance_name IS NOT NULL THEN
         <<check_inst_name>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_instances
             WHERE ite_name = p_instance_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_inst_name_nex
                , 'this instance name does not exist'
               );
         END check_inst_name;
      END IF;
      
      -- Check whether the parameter does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_parameters
          WHERE prr_name = p_param_name
            AND (
                   (p_instance_name IS NULL AND ite_name IS NULL)
                OR (p_instance_name IS NOT NULL AND ite_name = p_instance_name)
                );
         raise_app_error(
            dpp_cnf_var.gk_errcode_param_exists
          , 'this parameter already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Insert the parameter.
      INSERT INTO dpp_parameters (
         prr_name
       , prr_value
       , descr_eng
       , descr_fra
       , ite_name
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         p_param_name
       , p_param_value
       , p_descr_eng
       , p_descr_fra
       , p_instance_name
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
      
   END insert_parameter;
   
   /**
   * Delete a parameter.
   *
   * @param p_param_name: parameter name
   * @param p_instance_name: instance name
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance does not exist
   * @throws dpp_cnf_var.gk_errcode_param_nex: parameter does not exist
   */
   PROCEDURE delete_parameter(
      p_param_name            IN  dpp_parameters.prr_name%TYPE
    , p_instance_name         IN  dpp_parameters.ite_name%TYPE          := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_param_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid parameter name'
         );
      END IF;
      
      -- Check whether the instance name exists.
      IF p_instance_name IS NOT NULL THEN
         <<check_inst_name>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_instances
             WHERE ite_name = p_instance_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_inst_name_nex
                , 'this instance name does not exist'
               );
         END check_inst_name;
      END IF;
      
      -- Check whether the parameter exists.
      <<check_pk_unique>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_parameters
          WHERE prr_name = p_param_name
            AND (
                   (p_instance_name IS NULL AND ite_name IS NULL)
                OR (p_instance_name IS NOT NULL AND ite_name = p_instance_name)
                );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_param_nex
            , 'this parameter does not exist'
            );
      END check_pk_unique;
      
      -- Delete the parameter.
      DELETE dpp_parameters
       WHERE prr_name = p_param_name
         AND (
                (p_instance_name IS NULL AND ite_name IS NULL)
             OR (p_instance_name IS NOT NULL AND ite_name = p_instance_name)
             );
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_param_nex
         , 'this parameter does not exist'
         );
      END IF;

   END delete_parameter;
   
   /**
   * Update a parameter.
   *
   * @param p_param_name: parameter name
   * @param p_param_value: parameter value
   * @param p_descr_eng: english description
   * @param p_descr_fra: french description
   * @param p_instance_name: instance name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_inst_name_nex: instance does not exist
   * @throws dpp_cnf_var.gk_errcode_param_nex: parameter does not exist
   */
   PROCEDURE update_parameter(
      p_param_name            IN  dpp_parameters.prr_name%TYPE
    , p_param_value           IN  dpp_parameters.prr_value%TYPE         := NULL
    , p_descr_eng             IN  dpp_parameters.descr_eng%TYPE         := NULL
    , p_descr_fra             IN  dpp_parameters.descr_fra%TYPE         := NULL
    , p_instance_name         IN  dpp_parameters.ite_name%TYPE          := NULL
    , p_date_creat            IN  dpp_parameters.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_parameters.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_parameters.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_parameters.user_modif%TYPE        := NULL
   ) IS
   
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Check parameters.
      IF p_param_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid parameter name'
         );
      END IF;
      
      -- Check whether the instance name exists.
      IF p_instance_name IS NOT NULL THEN
         <<check_inst_name>>
         BEGIN
            SELECT '1'
              INTO flag
              FROM dpp_instances
             WHERE ite_name = p_instance_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise_app_error(
                  dpp_cnf_var.gk_errcode_inst_name_nex
                , 'this instance name does not exist'
               );
         END check_inst_name;
      END IF;
      
      -- Check whether the parameter exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_parameters
          WHERE prr_name = p_param_name
            AND (
                   (p_instance_name IS NULL AND ite_name IS NULL)
                OR (p_instance_name IS NOT NULL AND ite_name = p_instance_name)
                );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_param_nex
             , 'this parameter does not exist'
            );
      END check_pk;
      
      -- Update the parameter.
      UPDATE dpp_parameters
         SET prr_value = NVL(p_param_value, prr_value)
           , descr_eng = NVL(p_descr_eng, descr_eng)
           , descr_fra = NVL(p_descr_fra, descr_fra)
           , ite_name = NVL(p_instance_name, ite_name)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE prr_name = p_param_name
         AND (
                (p_instance_name IS NULL AND ite_name IS NULL)
             OR (p_instance_name IS NOT NULL AND ite_name = p_instance_name)
             );
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_param_nex
         , 'this parameter does not exist'
         );
      END IF;
      
   END update_parameter;
   
   /**
   * Add a recipient.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_email_addr: email address
   * @param p_date_creat: creaton date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_schema_nex: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_recip_exists: recipient already exist
   */
   PROCEDURE insert_recipient(
      p_schema_id             IN  dpp_recipients.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_email_addr            IN  dpp_recipients.email_addr%TYPE
    , p_date_creat            IN  dpp_recipients.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_recipients.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_recipients.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_recipients.user_modif%TYPE        := NULL
   ) IS
   
      -- schema ID
      schema_id               dpp_recipients.sma_id%TYPE                := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_email_addr IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid email address'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema does not exist'
            );
      END check_schema;
      
      -- Check whether the email address does not exist.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_recipients
          WHERE sma_id = schema_id
            AND email_addr = p_email_addr;
         raise_app_error(
            dpp_cnf_var.gk_errcode_recip_exists
          , 'this recipient already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk;
      
      -- Insert the recipient.
      INSERT INTO dpp_recipients (
         sma_id
       , email_addr
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id
       , p_email_addr
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
      
   END insert_recipient;
   
   /**
   * Delete a recipient.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_email_addr: email address
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_schema_nex: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_recip_nex: recipient does not exist
   */
   PROCEDURE delete_recipient(
      p_schema_id             IN  dpp_recipients.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_email_addr            IN  dpp_recipients.email_addr%TYPE
   ) IS
   
      -- schema ID
      schema_id               dpp_recipients.sma_id%TYPE                := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_email_addr IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid email address'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema does not exist'
            );
      END check_schema;
      
      -- Check whether the email address exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_recipients
          WHERE sma_id = schema_id
            AND email_addr = p_email_addr;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_recip_nex
             , 'this recipient does not exist'
            );
      END check_pk;
      
      -- Delete the recipient.
      DELETE dpp_recipients
       WHERE sma_id = schema_id
         AND email_addr = p_email_addr;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_recip_nex
          , 'this recipient does not exist'
         );
      END IF;
      
   END delete_recipient;
   
   /**
   * Insert a schema option.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_option_name: option name
   * @param p_option_value: option value
   * @param p_usage: usage
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_optname_nex: option name does not exist
   * @throws dpp_cnf_var.gk_errcode_option_exists: option already exist
   */
   PROCEDURE insert_schema_option(
      p_schema_id             IN  dpp_schema_options.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_option_name           IN  dpp_schema_options.otn_name%TYPE
    , p_option_value          IN  dpp_schema_options.stn_value%TYPE
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
    , p_date_creat            IN  dpp_schema_options.date_creat%TYPE    := NULL
    , p_user_creat            IN  dpp_schema_options.user_creat%TYPE    := NULL
    , p_date_modif            IN  dpp_schema_options.date_modif%TYPE    := NULL
    , p_user_modif            IN  dpp_schema_options.user_modif%TYPE    := NULL
   ) IS
   
      -- schema ID
      schema_id               dpp_schema_options.sma_id%TYPE            := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_option_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option name'
         );
      ELSIF p_option_value IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option value'
         );
      ELSIF p_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid usage'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema does not exist'
            );
      END check_schema;
      
      -- Check whether the option name exists.
      <<check_option_name>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_options
          WHERE otn_name = p_option_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_optname_nex
             , 'this option name does not exist'
            );
      END check_option_name;
      
      -- Check whether this option does not exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_options
          WHERE sma_id = schema_id
            AND otn_name = p_option_name
            AND stn_usage = p_usage
            AND stn_value = p_option_value;
         raise_app_error(
            dpp_cnf_var.gk_errcode_option_exists
          , 'this option already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk;
      
      -- Insert the option.
      INSERT INTO dpp_schema_options (
         sma_id
       , otn_name
       , stn_value
       , stn_usage
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id
       , p_option_name
       , p_option_value
       , p_usage
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
      
   END insert_schema_option;
   
   /**
   * Delete a schema option.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_option_name: option name
   * @param p_usage: usage
   * @param p_option_value: option value
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_option_nex: option does not exist
   */
   PROCEDURE delete_schema_option(
      p_schema_id             IN  dpp_schema_options.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_option_name           IN  dpp_schema_options.otn_name%TYPE
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
    , p_option_value          IN  dpp_schema_options.stn_value%TYPE
   ) IS
   
      -- schema ID
      schema_id               dpp_schema_options.sma_id%TYPE            := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_option_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option name'
         );
      ELSIF p_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid usage'
         );
      ELSIF p_option_value IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option value'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema does not exist'
            );
      END check_schema;
      
      -- Check whether this option exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_options
          WHERE sma_id = schema_id
            AND otn_name = p_option_name
            AND stn_usage = p_usage
            AND stn_value = p_option_value;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_option_nex
             , 'this option does not exist'
            );
      END check_pk;
      
      -- Delete the option.
      DELETE dpp_schema_options
       WHERE sma_id = schema_id
         AND otn_name = p_option_name
         AND stn_usage = p_usage
         AND stn_value = p_option_value;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_option_nex
          , 'this option does not exist'
         );
      END IF;
      
   END delete_schema_option;
   
   /**
   * Update a schema option.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_option_name: option name
   * @param p_option_value: option value
   * @param p_usage: usage
   * @param p_option_new_value: new option value
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_optname_nex: option name does not exist
   * @throws dpp_cnf_var.gk_errcode_option_nex: option does not exist
   */
   PROCEDURE update_schema_option(
      p_schema_id             IN  dpp_schema_options.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_option_name           IN  dpp_schema_options.otn_name%TYPE
    , p_option_value          IN  dpp_schema_options.stn_value%TYPE
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
    , p_option_new_value      IN  dpp_schema_options.stn_value%TYPE     := NULL
    , p_date_creat            IN  dpp_schema_options.date_creat%TYPE    := NULL
    , p_user_creat            IN  dpp_schema_options.user_creat%TYPE    := NULL
    , p_date_modif            IN  dpp_schema_options.date_modif%TYPE    := NULL
    , p_user_modif            IN  dpp_schema_options.user_modif%TYPE    := NULL
   ) IS
   
      -- schema ID
      schema_id               dpp_schema_options.sma_id%TYPE            := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the schema ID if not provided.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      ELSIF p_option_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option name'
         );
      ELSIF p_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid usage'
         );
      ELSIF p_option_value IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option value'
         );
      END IF;
      
      -- Check whether the schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'this schema does not exist'
            );
      END check_schema;
      
      -- Check whether this option exists.
      <<check_pk>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schema_options
          WHERE sma_id = schema_id
            AND otn_name = p_option_name
            AND stn_usage = p_usage
            AND stn_value = p_option_value;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_option_exists
             , 'this option does not exist'
            );
      END check_pk;
      
      -- Update the option.
      UPDATE dpp_schema_options
         SET stn_value = NVL(p_option_new_value, stn_value)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id = schema_id
         AND otn_name = p_option_name
         AND stn_usage = p_usage
         AND stn_value = p_option_value;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_option_nex
          , 'this option does not exist'
         );
      END IF;
      
   END update_schema_option;
   
   /**
   * Insert a new relationship.
   *
   * @param p_schema_id_from: source schema ID
   * @param p_functional_name_from: source schema functional name
   * @param p_schema_id_to: target schema ID
   * @param p_functional_name_to: target schema functional name
   * @param p_date_from: date from
   * @param p_date_to: date to
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_same_schemas: source and target schemas
   * are the same
   * @throws dpp_cnf_var.gk_errcode_relation_exists: relationship already
   * exists
   */
   PROCEDURE insert_schema_relation(
      p_schema_id_from        IN  dpp_schema_relations.sma_id_from%TYPE := NULL
    , p_functional_name_from  IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_schema_id_to          IN  dpp_schema_relations.sma_id_to%TYPE   := NULL
    , p_functional_name_to    IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_date_from             IN  dpp_schema_relations.date_from%TYPE   := NULL
    , p_date_to               IN  dpp_schema_relations.date_to%TYPE     := NULL
    , p_date_creat            IN  dpp_schema_relations.date_creat%TYPE  := NULL
    , p_user_creat            IN  dpp_schema_relations.user_creat%TYPE  := NULL
    , p_date_modif            IN  dpp_schema_relations.date_modif%TYPE  := NULL
    , p_user_modif            IN  dpp_schema_relations.user_modif%TYPE  := NULL
   ) IS
   
      -- schema ID from
      schema_id_from          dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- schema ID to
      schema_id_to            dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get schema ID's if not passed as parameters.
      IF p_schema_id_from IS NOT NULL THEN
         schema_id_from := p_schema_id_from;
      ELSIF p_functional_name_from IS NOT NULL THEN
         schema_id_from := get_schema_id(p_functional_name_from);
      END IF;
      IF p_schema_id_to IS NOT NULL THEN
         schema_id_to := p_schema_id_to;
      ELSIF p_functional_name_to IS NOT NULL THEN
         schema_id_to := get_schema_id(p_functional_name_to);
      END IF;
      
      -- Check parameters.
      IF schema_id_from IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_to IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      END IF;
      
      -- Check whether the source schema exists.
      <<check_schema_from>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_from;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the source schema does not exist'
            );
      END check_schema_from;
   
      -- Check whether the target schema exists.
      <<check_schema_to>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_to;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the target schema does not exist'
            );
      END check_schema_to;
      
      -- Check whether the source and target schemas are different.
      IF schema_id_to = schema_id_from THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_same_schemas
          , 'the source and target schemas are the same'
         );
      END IF;
      
      -- Check whether the relationship does not already exist.
      <<check_pk>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_relations
          WHERE sma_id_from = schema_id_from
            AND sma_id_to = schema_id_to;
         raise_app_error(
            dpp_cnf_var.gk_errcode_relation_exists
          , 'this relationship already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk;
      
      -- Insert the relationship.
      INSERT INTO dpp_schema_relations (
         sma_id_from
       , sma_id_to
       , date_from
       , date_to
       , date_creat
       , user_creat
       , date_modif
       , user_modif
      )
      VALUES (
         schema_id_from
       , schema_id_to
       , NVL(p_date_from, SYSDATE)
       , p_date_to
       , NVL(p_date_creat, SYSDATE)
       , NVL(p_user_creat, USER)
       , NVL(p_date_modif, SYSDATE)
       , NVL(p_user_modif, USER)
      );
   
   END insert_schema_relation;
   
   /**
   * Delete a relationship.
   *
   * @param p_schema_id_from: source schema ID
   * @param p_functional_name_from: source schema functional name
   * @param p_schema_id_to: target schema ID
   * @param p_functional_name_to: target schema functional name
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_errcode_relation_nex: relationship does not exist
   */
   PROCEDURE delete_schema_relation(
      p_schema_id_from        IN  dpp_schema_relations.sma_id_from%TYPE := NULL
    , p_functional_name_from  IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_schema_id_to          IN  dpp_schema_relations.sma_id_to%TYPE   := NULL
    , p_functional_name_to    IN  dpp_schemas.functional_name%TYPE      := NULL
   ) IS
   
      -- schema ID from
      schema_id_from          dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- schema ID to
      schema_id_to            dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get schema ID's if not passed as parameters.
      IF p_schema_id_from IS NOT NULL THEN
         schema_id_from := p_schema_id_from;
      ELSIF p_functional_name_from IS NOT NULL THEN
         schema_id_from := get_schema_id(p_functional_name_from);
      END IF;
      IF p_schema_id_to IS NOT NULL THEN
         schema_id_to := p_schema_id_to;
      ELSIF p_functional_name_to IS NOT NULL THEN
         schema_id_to := get_schema_id(p_functional_name_to);
      END IF;
      
      -- Check parameters.
      IF schema_id_from IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_to IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      END IF;
      
      -- Check whether the relationship exists.
      <<check_pk>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_relations
          WHERE sma_id_from = schema_id_from
            AND sma_id_to = schema_id_to;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_relation_nex
             , 'this relationship does not exist'
            );
      END check_pk;
      
      -- Delete the relationship.
      DELETE dpp_schema_relations
       WHERE sma_id_from = schema_id_from
         AND sma_id_to = schema_id_to;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_relation_nex
          , 'this relationship does not exist'
         );
      END IF;
   
   END delete_schema_relation;
   
   /**
   * Update a new relationship.
   *
   * @param p_schema_id_from: source schema ID
   * @param p_functional_name_from: source schema functional name
   * @param p_schema_id_to: target schema ID
   * @param p_functional_name_to: target schema functional name
   * @param p_date_from: date from
   * @param p_date_to: date to
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_relation_nex: relationship does not exist
   */
   PROCEDURE update_schema_relation(
      p_schema_id_from        IN  dpp_schema_relations.sma_id_from%TYPE := NULL
    , p_functional_name_from  IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_schema_id_to          IN  dpp_schema_relations.sma_id_to%TYPE   := NULL
    , p_functional_name_to    IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_date_from             IN  dpp_schema_relations.date_from%TYPE   := NULL
    , p_date_to               IN  dpp_schema_relations.date_to%TYPE     := NULL
    , p_date_creat            IN  dpp_schema_relations.date_creat%TYPE  := NULL
    , p_user_creat            IN  dpp_schema_relations.user_creat%TYPE  := NULL
    , p_date_modif            IN  dpp_schema_relations.date_modif%TYPE  := NULL
    , p_user_modif            IN  dpp_schema_relations.user_modif%TYPE  := NULL
   ) IS
   
      -- schema ID from
      schema_id_from          dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- schema ID to
      schema_id_to            dpp_schemas.sma_id%TYPE                   := NULL;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get schema ID's if not passed as parameters.
      IF p_schema_id_from IS NOT NULL THEN
         schema_id_from := p_schema_id_from;
      ELSIF p_functional_name_from IS NOT NULL THEN
         schema_id_from := get_schema_id(p_functional_name_from);
      END IF;
      IF p_schema_id_to IS NOT NULL THEN
         schema_id_to := p_schema_id_to;
      ELSIF p_functional_name_to IS NOT NULL THEN
         schema_id_to := get_schema_id(p_functional_name_to);
      END IF;
      
      -- Check parameters.
      IF schema_id_from IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_to IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      END IF;
      
      -- Check whether the relationship already exists.
      <<check_pk>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_relations
          WHERE sma_id_from = schema_id_from
            AND sma_id_to = schema_id_to;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_relation_nex
             , 'this relationship does not exist'
         );
      END check_pk;
      
      -- Update the relationship.
      UPDATE dpp_schema_relations
         SET date_from = NVL(p_date_from, date_from)
           , date_to = NVL(p_date_to, date_to)
           , date_creat = NVL(p_date_creat, date_creat)
           , user_creat = NVL(p_user_creat, user_creat)
           , date_modif = NVL(p_date_modif, SYSDATE)
           , user_modif = NVL(p_user_modif, USER)
       WHERE sma_id_from = schema_id_from
         AND sma_id_to = schema_id_to;
      IF SQL%ROWCOUNT != 1 THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_relation_nex
          , 'this relationship does not exist'
         );
      END IF;
   
   END update_schema_relation;
   
   /**
   * Duplicate a schema.
   *
   * @param p_src_schema_id: source schema ID
   * @param p_src_functional_name: source functional name
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user
   * @return: target schema ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_exists: target schema ID already
   * exists
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_ex: target functional name
   * already exists
   * @throws dpp_cnf_var.gk_errcode_schema_nex: source schema does not exist
   */
   FUNCTION duplicate_schema(
      p_src_schema_id         IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_src_functional_name   IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_trg_schema_id         IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE
    , p_date_creat            IN  dpp_schemas.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_schemas.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_schemas.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_schemas.user_modif%TYPE        := NULL
   ) RETURN dpp_schemas.sma_id%TYPE
   IS
   
      -- source schema ID
      schema_id_src           dpp_schemas.sma_id%TYPE                := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_schemas.sma_id%TYPE                := NULL;
      
      -- schema
      schema_rec              dpp_schemas%ROWTYPE;
      
      -- flag
      flag                    CHAR(1);
      
   BEGIN
   
      -- Get the source schema ID if needed.
      IF p_src_schema_id IS NOT NULL THEN
         schema_id_src := p_src_schema_id;
      ELSIF p_src_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_src_functional_name);
      END IF;
   
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NULL THEN
         SELECT MAX(sma_id) + 1
           INTO schema_id_trg
           FROM dpp_schemas;
         IF schema_id_trg IS NULL THEN
            schema_id_trg := 1;
         END IF;
      ELSE
         schema_id_trg := p_trg_schema_id;
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_trg_functional_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target functional name'
         );
      END IF;
      
      -- Check whether the target schema ID does not already exist.
      <<check_trg_id>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_trg;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_exists
          , 'the target schema ID already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_trg_id;
      
      -- Check whether the target functional name does not already exist.
      <<check_trg_fname>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE functional_name = p_trg_functional_name;
         raise_app_error(
            dpp_cnf_var.gk_errcode_schema_funcname_ex
          , 'the target schema functional name already exists'
         );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_trg_fname;
      
      -- Load the source schema.
      <<load_schema>>
      BEGIN
         SELECT *
           INTO schema_rec
           FROM dpp_schemas
          WHERE sma_id = schema_id_src;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the source schema does not exist'
            );
      END load_schema;
      
      -- Duplicate the schema.
      schema_rec.sma_id := schema_id_trg;
      schema_rec.functional_name := p_trg_functional_name;
      IF p_date_creat IS NOT NULL THEN
         schema_rec.date_creat := p_date_creat;
      END IF;
      IF p_user_creat IS NOT NULL THEN
         schema_rec.user_creat := p_user_creat;
      END IF;
      IF p_date_modif IS NOT NULL THEN
         schema_rec.date_modif := p_date_modif;
      END IF;
      IF p_user_modif IS NOT NULL THEN
         schema_rec.user_modif := p_user_modif;
      END IF;
      INSERT INTO dpp_schemas
      VALUES schema_rec;
      
      -- Return target schema ID.
      RETURN schema_id_trg;

   END duplicate_schema;
   
   /**
   * Duplicate an action.
   *
   * @param p_schema_id: source schema ID
   * @param p_functional_name: source functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: target schema does not exist
   * @throws dpp_cnf_var.gk_errcode_action_exists: target action already exists
   * @throws dpp_cnf_var.gk_errcode_action_nex: source action does not exist
   */
   PROCEDURE duplicate_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_trg_schema_id         IN  dpp_actions.sma_id%TYPE            := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   ) IS
   
      -- source schema ID
      schema_id_src           dpp_actions.sma_id%TYPE                := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_actions.sma_id%TYPE                := NULL;
      
      -- flag
      flag                    CHAR(1);
      
      -- action
      action_rec              dpp_actions%ROWTYPE;
      
   BEGIN
   
      -- Compute the source schema ID if needed.
      IF p_schema_id IS NOT NULL THEN
         schema_id_src := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_functional_name);
      END IF;
      
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NOT NULL THEN
         schema_id_trg := p_trg_schema_id;
      ELSIF p_trg_functional_name IS NOT NULL THEN
         schema_id_trg := get_schema_id(p_trg_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_atn_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          ,'invalid ATN usage'
         );
      ELSIF p_atn_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid ATN type'
         );
      ELSIF p_exec_order IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid execution order'
         );
      END IF;
      
      
      -- Check whether the target schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_trg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the target schema does not exist'
            );
      END check_schema;
      
      -- Check whether the target action does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_actions
          WHERE sma_id = schema_id_trg
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_exec_order;
         raise_app_error(
            dpp_cnf_var.gk_errcode_action_exists
           ,'the target action already exists'
          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Load the source action.
      <<load_action>>
      BEGIN
         SELECT *
           INTO action_rec
           FROM dpp_actions
          WHERE sma_id = schema_id_src
            AND atn_usage = p_atn_usage
            AND atn_type = p_atn_type
            AND execution_order = p_exec_order;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_action_nex
             , 'the source action does not exist'
            );
      END load_action;
      
      -- Duplicate the action.
      action_rec.sma_id := schema_id_trg;
      IF p_date_creat IS NOT NULL THEN
         action_rec.date_creat := p_date_creat;
      END IF;
      IF p_user_creat IS NOT NULL THEN
         action_rec.user_creat := p_user_creat;
      END IF;
      IF p_date_modif IS NOT NULL THEN
         action_rec.date_modif := p_date_modif;
      END IF;
      IF p_user_modif IS NOT NULL THEN
         action_rec.user_modif := p_user_modif;
      END IF;
      INSERT INTO dpp_actions
      VALUES action_rec;

   END duplicate_action;
   
   /**
   * Duplicate a no drop object.
   *
   * @param p_schema_id: source schema ID
   * @param p_functional_name: source functional name
   * @param p_object_name; object name
   * @param p_object_type: object type
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: target schema does not exist
   * @throws dpp_cnf_var.gk_errcode_nodropobj_ex: target no drop object already
   * exists
   * @throws dpp_cnf_var.gk_errcode_nodropobj_nex: source no drop object does
   * not exist
   */
   PROCEDURE duplicate_nodrop_object(
      p_schema_id             IN  dpp_nodrop_objects.sma_id%TYPE     := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_object_name           IN  dpp_nodrop_objects.object_name%TYPE
    , p_object_type           in  dpp_nodrop_objects.object_type%TYPE
    , p_trg_schema_id         IN  dpp_nodrop_objects.sma_id%TYPE     := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_date_creat            IN  dpp_nodrop_objects.date_creat%TYPE := NULL
    , p_user_creat            IN  dpp_nodrop_objects.user_creat%TYPE := NULL
    , p_date_modif            IN  dpp_nodrop_objects.date_modif%TYPE := NULL
    , p_user_modif            IN  dpp_nodrop_objects.user_modif%TYPE := NULL
   ) IS
   
      -- source schema ID
      schema_id_src           dpp_nodrop_objects.sma_id%TYPE         := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_nodrop_objects.sma_id%TYPE         := NULL;
      
      -- flag
      flag                    CHAR(1);
      
      -- no drop object
      nodrop_rec              dpp_nodrop_objects%ROWTYPE;
      
   BEGIN
   
      -- Compute the source schema ID if needed.
      IF p_schema_id IS NOT NULL THEN
         schema_id_src := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_functional_name);
      END IF;
      
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NOT NULL THEN
         schema_id_trg := p_trg_schema_id;
      ELSIF p_trg_functional_name IS NOT NULL THEN
         schema_id_trg := get_schema_id(p_trg_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_object_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object name'
         );
      ELSIF p_object_type IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid object type'
         );
      END IF;
      
      
      -- Check whether the target schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_trg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the target schema does not exist'
            );
      END check_schema;
      
      -- Check whether the target no drop object does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id_trg
            AND object_name = p_object_name
            AND object_type = p_object_type;
         raise_app_error(
            dpp_cnf_var.gk_errcode_nodropobj_ex
           ,'the target "no drop" object already exists'
          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Load the source no drop object.
      <<load_nodrop>>
      BEGIN
         SELECT *
           INTO nodrop_rec
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id_src
            AND object_name = p_object_name
            AND object_type = p_object_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_nodropobj_nex
             , 'the source "no drop" object does not exist'
            );
      END load_nodrop;
      
      -- Duplicate the no drop object.
      nodrop_rec.sma_id := schema_id_trg;
      IF p_date_creat IS NOT NULL THEN
         nodrop_rec.date_creat := p_date_creat;
      END IF;
      IF p_user_creat IS NOT NULL THEN
         nodrop_rec.user_creat := p_user_creat;
      END IF;
      IF p_date_modif IS NOT NULL THEN
         nodrop_rec.date_modif := p_date_modif;
      END IF;
      IF p_user_modif IS NOT NULL THEN
         nodrop_rec.user_modif := p_user_modif;
      END IF;
      INSERT INTO dpp_nodrop_objects
      VALUES nodrop_rec;

   END duplicate_nodrop_object;
   
   /**
   * Duplicate a recpient.
   *
   * @param p_schema_id: source schema ID
   * @param p_functional_name: source functional name
   * @param p_email_addr: email address
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: target schema does not exist
   * @throws dpp_cnf_var.gk_errcode_recip_exists: target recipient already
   * exists
   * @throws dpp_cnf_var.gk_errcode_recip_nex: source recipient does
   * not exist
   */
   PROCEDURE duplicate_recipient(
      p_schema_id             IN  dpp_recipients.sma_id%TYPE         := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_email_addr            IN  dpp_recipients.email_addr%TYPE
    , p_trg_schema_id         IN  dpp_recipients.sma_id%TYPE         := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_date_creat            IN  dpp_recipients.date_creat%TYPE     := NULL
    , p_user_creat            IN  dpp_recipients.user_creat%TYPE     := NULL
    , p_date_modif            IN  dpp_recipients.date_modif%TYPE     := NULL
    , p_user_modif            IN  dpp_recipients.user_modif%TYPE     := NULL
   ) IS
   
      -- source schema ID
      schema_id_src           dpp_recipients.sma_id%TYPE             := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_recipients.sma_id%TYPE             := NULL;
      
      -- flag
      flag                    CHAR(1);
      
      -- recipient
      recipient_rec           dpp_recipients%ROWTYPE;
      
   BEGIN
   
      -- Compute the source schema ID if needed.
      IF p_schema_id IS NOT NULL THEN
         schema_id_src := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_functional_name);
      END IF;
      
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NOT NULL THEN
         schema_id_trg := p_trg_schema_id;
      ELSIF p_trg_functional_name IS NOT NULL THEN
         schema_id_trg := get_schema_id(p_trg_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_email_addr IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid email address'
         );
      END IF;
      
      
      -- Check whether the target schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_trg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the target schema does not exist'
            );
      END check_schema;
      
      -- Check whether the target recipient does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_recipients
          WHERE sma_id = schema_id_trg
            AND email_addr = p_email_addr;
         raise_app_error(
            dpp_cnf_var.gk_errcode_recip_exists
           ,'the target recipient already exists'
          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Load the source recipient.
      <<load_recip>>
      BEGIN
         SELECT *
           INTO recipient_rec
           FROM dpp_recipients
          WHERE sma_id = schema_id_src
            AND email_addr = p_email_addr;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_recip_nex
             , 'the source recipient does not exist'
            );
      END load_recip;
      
      -- Duplicate the recipient.
      recipient_rec.sma_id := schema_id_trg;
      IF p_date_creat IS NOT NULL THEN
         recipient_rec.date_creat := p_date_creat;
      END IF;
      IF p_user_creat IS NOT NULL THEN
         recipient_rec.user_creat := p_user_creat;
      END IF;
      IF p_date_modif IS NOT NULL THEN
         recipient_rec.date_modif := p_date_modif;
      END IF;
      IF p_user_modif IS NOT NULL THEN
         recipient_rec.user_modif := p_user_modif;
      END IF;
      INSERT INTO dpp_recipients
      VALUES recipient_rec;

   END duplicate_recipient;
   
   /**
   * Duplicate a schema option.
   *
   * @param p_schema_id: source schema ID
   * @param p_functional_name: source functional name
   * @param p_option_name: option name
   * @param p_usage: usage
   * @param p_option_value: option value
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: target schema does not exist
   * @throws dpp_cnf_var.gk_errcode_option_exists: target schema option
   * already exists
   * @throws dpp_cnf_var.gk_errcode_option_nex: source schema option does
   * not exist
   */
   PROCEDURE duplicate_schema_option(
      p_schema_id             IN  dpp_schema_options.sma_id%TYPE        := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_option_name           IN  dpp_schema_options.otn_name%TYPE
    , p_usage                 IN  dpp_schema_options.stn_usage%TYPE
    , p_option_value          IN  dpp_schema_options.stn_value%TYPE
    , p_trg_schema_id         IN  dpp_schema_options.sma_id%TYPE        := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE      := NULL
    , p_date_creat            IN  dpp_schema_options.date_creat%TYPE    := NULL
    , p_user_creat            IN  dpp_schema_options.user_creat%TYPE    := NULL
    , p_date_modif            IN  dpp_schema_options.date_modif%TYPE    := NULL
    , p_user_modif            IN  dpp_schema_options.user_modif%TYPE    := NULL
   ) IS
   
      -- source schema ID
      schema_id_src           dpp_schema_options.sma_id%TYPE            := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_schema_options.sma_id%TYPE            := NULL;
      
      -- flag
      flag                    CHAR(1);
      
      -- schema option
      schema_option_rec       dpp_schema_options%ROWTYPE;
      
   BEGIN
   
      -- Compute the source schema ID if needed.
      IF p_schema_id IS NOT NULL THEN
         schema_id_src := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_functional_name);
      END IF;
      
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NOT NULL THEN
         schema_id_trg := p_trg_schema_id;
      ELSIF p_trg_functional_name IS NOT NULL THEN
         schema_id_trg := get_schema_id(p_trg_functional_name);
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_option_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option name'
         );
      ELSIF p_usage IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid usage'
         );
      ELSIF p_option_value IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid option value'
         );
      END IF;
      
      
      -- Check whether the target schema exists.
      <<check_schema>>
      BEGIN
         SELECT '1'
           INTO flag
           FROM dpp_schemas
          WHERE sma_id = schema_id_trg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_schema_nex
             , 'the target schema does not exist'
            );
      END check_schema;
      
      -- Check whether the target schema option does not already exist.
      <<check_pk_unique>>
      BEGIN
         SELECT DISTINCT '1'
           INTO flag
           FROM dpp_schema_options
          WHERE sma_id = schema_id_trg
            AND otn_name = p_option_name
            AND stn_usage = p_usage
            AND stn_value = p_option_value;
         raise_app_error(
            dpp_cnf_var.gk_errcode_option_exists
           ,'the target schema option already exists'
          );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END check_pk_unique;
      
      -- Load the source schema option.
      <<load_schema_option>>
      BEGIN
         SELECT *
           INTO schema_option_rec
           FROM dpp_schema_options
          WHERE sma_id = schema_id_src
            AND otn_name = p_option_name
            AND stn_usage = p_usage
            AND stn_value = p_option_value;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_app_error(
               dpp_cnf_var.gk_errcode_option_nex
             , 'the source schema option does not exist'
            );
      END load_schema_option;
      
      -- Duplicate the schema option.
      schema_option_rec.sma_id := schema_id_trg;
      IF p_date_creat IS NOT NULL THEN
         schema_option_rec.date_creat := p_date_creat;
      END IF;
      IF p_user_creat IS NOT NULL THEN
         schema_option_rec.user_creat := p_user_creat;
      END IF;
      IF p_date_modif IS NOT NULL THEN
         schema_option_rec.date_modif := p_date_modif;
      END IF;
      IF p_user_modif IS NOT NULL THEN
         schema_option_rec.user_modif := p_user_modif;
      END IF;
      INSERT INTO dpp_schema_options
      VALUES schema_option_rec;

   END duplicate_schema_option;
   
   /**
   * Duplicate a schema configuration.
   *
   * @param p_src_schema_id: source schema ID
   * @param p_src_functional_name: source functional name
   * @param p_trg_schema_id: target schema ID
   * @param p_trg_functional_name: target functional name
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user
   * @return: target schema ID
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_exists: target schema ID already
   * exists
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_ex: target functional name
   * already exists
   * @throws dpp_cnf_var.gk_errcode_schema_nex: source schema does not exist
   * @throws dpp_cnf_var.gk_errcode_action_exists: target action already exists
   * @throws dpp_cnf_var.gk_errcode_action_nex: source action does not exist
   * @throws dpp_cnf_var.gk_errcode_nodropobj_ex: target no drop object already
   * exists
   * @throws dpp_cnf_var.gk_errcode_nodropobj_nex: source no drop object does
   * not exist
   * @throws dpp_cnf_var.gk_errcode_recip_exists: target recipient already
   * exists
   * @throws dpp_cnf_var.gk_errcode_recip_nex: source recipient does
   * not exist
   * @throws dpp_cnf_var.gk_errcode_option_exists: target schema option
   * already exists
   * @throws dpp_cnf_var.gk_errcode_option_nex: source schema option does
   * not exist
   */
   FUNCTION duplicate_schema_config(
      p_src_schema_id         IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_src_functional_name   IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_trg_schema_id         IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_trg_functional_name   IN  dpp_schemas.functional_name%TYPE
    , p_date_creat            IN  dpp_schemas.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_schemas.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_schemas.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_schemas.user_modif%TYPE        := NULL
   ) RETURN dpp_schemas.sma_id%TYPE
   IS
   
      -- source schema ID
      schema_id_src           dpp_schemas.sma_id%TYPE                := NULL;
      
      -- target schema ID
      schema_id_trg           dpp_schemas.sma_id%TYPE                := NULL;
      
   BEGIN
   
      -- Get the source schema ID if needed.
      IF p_src_schema_id IS NOT NULL THEN
         schema_id_src := p_src_schema_id;
      ELSIF p_src_functional_name IS NOT NULL THEN
         schema_id_src := get_schema_id(p_src_functional_name);
      END IF;
   
      -- Compute the target schema ID if needed.
      IF p_trg_schema_id IS NULL THEN
         SELECT MAX(sma_id) + 1
           INTO schema_id_trg
           FROM dpp_schemas;
         IF schema_id_trg IS NULL THEN
            schema_id_trg := 1;
         END IF;
      ELSE
         schema_id_trg := p_trg_schema_id;
      END IF;
      
      -- Check parameters.
      IF schema_id_src IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid source schema ID'
         );
      ELSIF schema_id_trg IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target schema ID'
         );
      ELSIF p_trg_functional_name IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid target functional name'
         );
      END IF;
      
      -- Duplicate the schema.
      schema_id_trg := duplicate_schema(
         p_src_schema_id         => schema_id_src
       , p_trg_schema_id         => schema_id_trg
       , p_trg_functional_name   => p_trg_functional_name
       , p_date_creat            => p_date_creat
       , p_user_creat            => p_user_creat
       , p_date_modif            => p_date_modif
       , p_user_modif            => p_user_modif
      );
      
      -- Duplicate the actions.
      FOR action_rec IN (
         SELECT atn_usage
              , atn_type
              , execution_order
           FROM dpp_actions
          WHERE sma_id = schema_id_src
          ORDER BY atn_usage ASC
                 , atn_type ASC
                 , execution_order ASC
      ) LOOP
         duplicate_action(
            p_schema_id          => schema_id_src
          , p_trg_schema_id      => schema_id_trg
          , p_atn_usage          => action_rec.atn_usage
          , p_atn_type           => action_rec.atn_type
          , p_exec_order         => action_rec.execution_order
          , p_date_creat         => p_date_creat
          , p_user_creat         => p_user_creat
          , p_date_modif         => p_date_modif
          , p_user_modif         => p_user_modif
         );
      END LOOP;
      
      -- Duplicate the no drop objects.
      FOR nodrop_rec IN (
         SELECT object_name
              , object_type
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id_src
          ORDER BY object_name ASC
                 , object_type ASC
      ) LOOP
         duplicate_nodrop_object(
            p_schema_id          => schema_id_src
          , p_trg_schema_id      => schema_id_trg
          , p_object_name        => nodrop_rec.object_name
          , p_object_type        => nodrop_rec.object_type
          , p_date_creat         => p_date_creat
          , p_user_creat         => p_user_creat
          , p_date_modif         => p_date_modif
          , p_user_modif         => p_user_modif
         );
      END LOOP;
      
      -- Duplicate the recipients.
      FOR recip_rec IN (
         SELECT email_addr
           FROM dpp_recipients
          WHERE sma_id = schema_id_src
          ORDER BY email_addr ASC
      ) LOOP
         duplicate_recipient(
            p_schema_id          => schema_id_src
          , p_trg_schema_id      => schema_id_trg
          , p_email_addr         => recip_rec.email_addr
          , p_date_creat         => p_date_creat
          , p_user_creat         => p_user_creat
          , p_date_modif         => p_date_modif
          , p_user_modif         => p_user_modif
         );
      END LOOP;
     
      -- Duplicate the schema options.
      FOR schema_option_rec IN (
         SELECT otn_name
              , stn_usage
              , stn_value
           FROM dpp_schema_options
          WHERE sma_id = schema_id_src
          ORDER BY otn_name ASC
                 , stn_usage ASC
      ) LOOP
            duplicate_schema_option(
               p_schema_id          => schema_id_src
             , p_trg_schema_id      => schema_id_trg
             , p_option_name        => schema_option_rec.otn_name
             , p_usage              => schema_option_rec.stn_usage
             , p_option_value       => schema_option_rec.stn_value
             , p_date_creat         => p_date_creat
             , p_user_creat         => p_user_creat
             , p_date_modif         => p_date_modif
             , p_user_modif         => p_user_modif
            );
      END LOOP;

      -- Return the target schema ID.
      RETURN schema_id_trg;
   
   END duplicate_schema_config;
   
   /**
   * Delete a schema configuration.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: functional name
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema ID does not exist
   * @throws dpp_cnf_var.gk_errcode_schema_ref: schema referenced by child data
   * @throws dpp_cnf_var.gk_errcode_nodropobj_nex: "no drop" object does not
   * exist
   * @throws dpp_cnf_var.gk_action_nex: action does not exist
   * @throws dpp_cnf_var.gk_errcode_recip_nex: recipient does not exist
   * @throws dpp_cnf_var.gk_errcode_option_nex: option does not exist
   * @throws dpp_cnf_var.gk_errcode_relation_nex: relationship does not exist
   */
   PROCEDURE delete_schema_config(
      p_schema_id             IN  dpp_schemas.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
   ) IS
   
      -- schema ID
      schema_id               dpp_schemas.sma_id%TYPE                := NULL;
      
   BEGIN
   
      -- Get the schema ID if needed.
      IF p_schema_id IS NOT NULL THEN
         schema_id := p_schema_id;
      ELSIF p_functional_name IS NOT NULL THEN
         schema_id := get_schema_id(p_functional_name);
      END IF;
   
      -- Check parameters.
      IF schema_id IS NULL THEN
         raise_app_error(
            dpp_cnf_var.gk_errcode_inv_prm
          , 'invalid schema ID'
         );
      END IF;
      
      -- Delete the actions.
      FOR action_rec IN (
         SELECT atn_usage
              , atn_type
              , execution_order
           FROM dpp_actions
          WHERE sma_id = schema_id
          ORDER BY atn_usage ASC
                 , atn_type ASC
                 , execution_order ASC
      ) LOOP
         delete_action(
            p_schema_id          => schema_id
          , p_atn_usage          => action_rec.atn_usage
          , p_atn_type           => action_rec.atn_type
          , p_exec_order         => action_rec.execution_order
         );
      END LOOP;
      
      -- Delete the no drop objects.
      FOR nodrop_rec IN (
         SELECT object_name
              , object_type
           FROM dpp_nodrop_objects
          WHERE sma_id = schema_id
          ORDER BY object_name ASC
                 , object_type ASC
      ) LOOP
         delete_nodrop_object(
            p_schema_id          => schema_id
          , p_object_name        => nodrop_rec.object_name
          , p_object_type        => nodrop_rec.object_type
         );
      END LOOP;
      
      -- Delete the recipients.
      FOR recip_rec IN (
         SELECT email_addr
           FROM dpp_recipients
          WHERE sma_id = schema_id
          ORDER BY email_addr ASC
      ) LOOP
         delete_recipient(
            p_schema_id          => schema_id
          , p_email_addr         => recip_rec.email_addr
         );
      END LOOP;
     
      -- Delete the schema options.
      FOR schema_option_rec IN (
         SELECT otn_name
              , stn_usage
              , stn_value
           FROM dpp_schema_options
          WHERE sma_id = schema_id
          ORDER BY otn_name ASC
                 , stn_usage ASC
      ) LOOP
            delete_schema_option(
               p_schema_id          => schema_id
             , p_option_name        => schema_option_rec.otn_name
             , p_usage              => schema_option_rec.stn_usage
             , p_option_value       => schema_option_rec.stn_value
            );
      END LOOP;
      
      -- Delete the schema relationships.
      FOR schema_relation_rec IN (
         SELECT DISTINCT
                sma_id_from
              , sma_id_to
           FROM dpp_schema_relations
          WHERE sma_id_from = schema_id
             OR sma_id_to = schema_id
          ORDER BY sma_id_from ASC
                 , sma_id_to ASC
      ) LOOP
         delete_schema_relation(
            p_schema_id_from     => schema_relation_rec.sma_id_from
          , p_schema_id_to       => schema_relation_rec.sma_id_to
         );
      END LOOP;
      
      -- Clean up teh job runs.
      clean_up_job_runs(schema_id);
      
      -- Delete the schema.
      delete_schema(schema_id);
      
   END delete_schema_config;
   
END dpp_cnf_krn;
/
