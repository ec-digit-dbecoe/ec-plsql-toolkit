CREATE OR REPLACE PACKAGE dpp_cnf_krn AUTHID DEFINER IS
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
   * Create a database link in the target schema.
   *
   * @param p_target_schema: target schema
   * @param p_db_link_name: database link name
   * @param p_db_link_user: database link connection user ID
   * @param p_db_link_pwd: database link password
   * @param p_db_link_conn_string: database link connection string
   * @throws 
   */
   PROCEDURE create_database_link (
      p_target_schema         IN    VARCHAR2
    , p_db_link_name          IN    VARCHAR2
    , p_db_link_user          IN    VARCHAR2
    , p_db_link_pwd           IN    VARCHAR2
    , p_db_link_conn_string   IN    VARCHAR2
   );

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
      p_target_schema         IN    VARCHAR2
    , p_db_link_name          IN    VARCHAR2
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );

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
   );

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
   );

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
   );
   
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
   );

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
   );
   
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
   RETURN dpp_schemas.sma_id%TYPE;
   
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
   );

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
   );

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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );

   /**
   * Insert a new action.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_url: URL
   * @param p_wallet_path: wallet path
   * @param p_proxy: proxy server
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
   PROCEDURE insert_http_request_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_url                   IN  VARCHAR2
    , p_wallet_path           IN  VARCHAR2                           := NULL
    , p_proxy                 IN  VARCHAR2                           := NULL
    , p_active_flag           IN  dpp_actions.active_flag%TYPE
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   );

   /**
   * Insert a new action and encrypt the URL and wallet path.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_url: URL
   * @param p_wallet_path: wallet path
   * @param p_proxy: proxy server
   * @param p_active_flag: active flag
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @param p_ph_suffix: placeholder suffix
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_exists: action already exists
   */
   PROCEDURE insert_http_request_action_enc(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_url                   IN  VARCHAR2
    , p_wallet_path           IN  VARCHAR2                           := NULL
    , p_proxy                 IN  VARCHAR2                           := NULL
    , p_active_flag           IN  dpp_actions.active_flag%TYPE
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
    , p_ph_suffix             IN  VARCHAR2
   );

   /**
   * Insert a new action.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_url: URL
   * @param p_wallet_path: wallet path
   * @param p_proxy: proxy server
   * @param p_var_name: variable name
   * @param p_var_value: variable value
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
   PROCEDURE insert_http_gitlab_req_action(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_url                   IN  VARCHAR2
    , p_wallet_path           IN  VARCHAR2                           := NULL
    , p_proxy                 IN  VARCHAR2                           := NULL
    , p_token                 IN  VARCHAR2                           := NULL
    , p_var_name              IN  VARCHAR2                           := NULL
    , p_var_value             IN  VARCHAR2                           := NULL
    , p_active_flag           IN  dpp_actions.active_flag%TYPE
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
   );

   /**
   * Insert a new GitLab encrypted action.
   *
   * @param p_schema_id: schema ID
   * @param p_functional_name: schema functional name
   * @param p_atn_usage: ATN usage
   * @param p_atn_type: ATN type
   * @param p_exec_order: execution order
   * @param p_url: URL
   * @param p_wallet_path: wallet path
   * @param p_proxy: proxy server
   * @param p_var_name: variable name
   * @param p_var_value: variable value
   * @param p_active_flag: active flag
   * @param p_date_creat: creation date
   * @param p_user_creat: creation user ID
   * @param p_date_modif: last modification date
   * @param p_user_modif: last modification user ID
   * @param p_ph_suffix: placeholder suffix
   * @throws dpp_cnf_var.dpp_cnf_var.gk_errcode_inv_prm: invalid functional name
   * @throws dpp_cnf_var.gk_errcode_schema_funcname_nex: functional name
   * does not exist
   * @throws dpp_cnf_var.gk_errcode_inv_prm: invalid parameter
   * @throws dpp_cnf_var.gk_errcode_schema_nex: schema does not exist
   * @throws dpp_cnf_var.gk_action_exists: action already exists
   */
   PROCEDURE insert_http_gitlab_req_action_enc(
      p_schema_id             IN  dpp_actions.sma_id%TYPE            := NULL
    , p_functional_name       IN  dpp_schemas.functional_name%TYPE   := NULL
    , p_atn_usage             IN  dpp_actions.atn_usage%TYPE
    , p_atn_type              IN  dpp_actions.atn_type%TYPE
    , p_exec_order            IN  dpp_actions.execution_order%TYPE
    , p_url                   IN  VARCHAR2
    , p_wallet_path           IN  VARCHAR2                           := NULL
    , p_proxy                 IN  VARCHAR2                           := NULL
    , p_token                 IN  VARCHAR2                           := NULL
    , p_var_name              IN  VARCHAR2                           := NULL
    , p_var_value             IN  VARCHAR2                           := NULL
    , p_active_flag           IN  dpp_actions.active_flag%TYPE
    , p_date_creat            IN  dpp_actions.date_creat%TYPE        := NULL
    , p_user_creat            IN  dpp_actions.user_creat%TYPE        := NULL
    , p_date_modif            IN  dpp_actions.date_modif%TYPE        := NULL
    , p_user_modif            IN  dpp_actions.user_modif%TYPE        := NULL
    , p_ph_suffix             IN  VARCHAR2
   );
   
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
   );

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
   );

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
   );

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
   );
   
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
   );

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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   ) RETURN dpp_schemas.sma_id%TYPE;

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
   );
   
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
   );
   
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
   );
   
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
   );
   
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
   ) RETURN dpp_schemas.sma_id%TYPE;
   
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
   );
   
END dpp_cnf_krn;
/
