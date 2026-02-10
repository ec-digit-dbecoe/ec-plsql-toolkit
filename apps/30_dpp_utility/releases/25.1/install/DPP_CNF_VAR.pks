CREATE OR REPLACE PACKAGE dpp_cnf_var AUTHID DEFINER ACCESSIBLE BY (package dpp_cnf_krn) IS
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
* This package defines the constants, variables and exceptions used by the
* "dpp_cnf_krn" package that implements API's for the configuration of
* DPP jobs.
*/

   -- exception: insufficient privilege (create any procedure)
   ge_exc_ins_priv_crproc              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_exc_ins_priv_crproc, -01031);
   
   -- exception: insufficient privilege (execute any procedure)
   ge_exc_ins_priv_exproc              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_exc_ins_priv_exproc, -06550);

   -- exception: insufficient privilege (drop any procedure)
   ge_exc_ins_priv_drproc              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_exc_ins_priv_drproc, -01031);

   -- error code: invalid parameter
   gk_errcode_inv_prm               CONSTANT SIMPLE_INTEGER    := -20001;
   
   -- error code: user does not have the right to create a procedure in
   -- another schema
   gk_errcode_cr_proc_priv          CONSTANT SIMPLE_INTEGER    := -20002;

   -- error code: user does not have the right to execute a procedure in
   -- another schema
   gk_errcode_ex_proc_priv          CONSTANT SIMPLE_INTEGER    := -20003;

   -- error code: user does not have the right to drop a procedure in
   -- another schema
   gk_errcode_dr_proc_priv          CONSTANT SIMPLE_INTEGER    := -20004;
   
   -- error code: instance name already exists
   gk_errcode_inst_name_exist       CONSTANT SIMPLE_INTEGER    := -20005;

   -- error code: instance name doest no exist
   gk_errcode_inst_name_nex         CONSTANT SIMPLE_INTEGER    := -20006;
   
   -- error code: instance name referenced
   gk_errcode_inst_name_ref         CONSTANT SIMPLE_INTEGER    := -20007;

   -- error code: schema type name already exists
   gk_errcode_ste_name_ex           CONSTANT SIMPLE_INTEGER    := -20008;

   -- error code: schema type name does not exist
   gk_errcode_ste_name_nex          CONSTANT SIMPLE_INTEGER    := -20009;

   -- error code: schema type referenced by child data
   gk_errorcode_ste_ref             CONSTANT SIMPLE_INTEGER    := -20010;
   
   -- error code: role name already exists
   gk_errcode_role_exists           CONSTANT SIMPLE_INTEGER    := -20011;

   -- error code: role name does no exist
   gk_errcode_role_nex              CONSTANT SIMPLE_INTEGER    := -20012;

   -- error code: role name referenced by some child data
   gk_errcode_role_ref              CONSTANT SIMPLE_INTEGER    := -20013;

   -- error code: schema already exists
   gk_errcode_schema_exists         CONSTANT SIMPLE_INTEGER    := -20014;

   -- error code: schema functional name already exists
   gk_errcode_schema_funcname_ex    CONSTANT SIMPLE_INTEGER    := -20015;
   
   -- error code: schema functional does not exist
   gk_errcode_schema_funcname_nex   CONSTANT SIMPLE_INTEGER    := -20016;
   
   -- error code: schema does not exist
   gk_errcode_schema_nex            CONSTANT SIMPLE_INTEGER    := -20017;
   
   -- error code: schema referenced by some child data
   gk_errcode_schema_ref            CONSTANT SIMPLE_INTEGER    := -20018;
   
   -- error code: no drop object already exists
   gk_errcode_nodropobj_ex          CONSTANT SIMPLE_INTEGER    := -20019;
   
   -- error code: no drop object does not exist
   gk_errcode_nodropobj_nex         CONSTANT SIMPLE_INTEGER    := -20020;
   
   -- error code: action already exists
   gk_errcode_action_exists                 CONSTANT SIMPLE_INTEGER    := -20021;
   
   -- error code: action does not exists
   gk_errcode_action_nex                    CONSTANT SIMPLE_INTEGER    := -20022;
   
   -- error code: parameter already exist
   gk_errcode_param_exists          CONSTANT SIMPLE_INTEGER    := -20023;

   -- error code: parameter does not exist
   gk_errcode_param_nex             CONSTANT SIMPLE_INTEGER    := -20024;
   
   -- error code: recipient already exists
   gk_errcode_recip_exists          CONSTANT SIMPLE_INTEGER    := -20025;
   
   -- error code: recipient does not exist
   gk_errcode_recip_nex             CONSTANT SIMPLE_INTEGER    := -20026;
   
   -- error code: option name does not exist
   gk_errcode_optname_nex           CONSTANT SIMPLE_INTEGER    := -20027;
   
   -- error code: option already exists
   gk_errcode_option_exists         CONSTANT SIMPLE_INTEGER    := -20028;
   
   -- error code: option does not exist
   gk_errcode_option_nex            CONSTANT SIMPLE_INTEGER    := -20029;
   
   -- error code: source and target schemas are the same
   gk_errcode_same_schemas          CONSTANT SIMPLE_INTEGER    := -20030;
   
   -- error code: relationship already exists
   gk_errcode_relation_exists       CONSTANT SIMPLE_INTEGER    := -20031;
   
   -- error code: relationship does not exist
   gk_errcode_relation_nex          CONSTANT SIMPLE_INTEGER    := -20032;

   -- carriage return
   gk_cr                      CONSTANT VARCHAR2(10)      := CHR(13) || CHR(10);

   -- code of a PL/SQL procedure that creates a database link
   gk_db_link_proc            CONSTANT CLOB              :=
         'CREATE OR REPLACE PROCEDURE {target_schema}.dpp_create_db_link (' || gk_cr
      || '   p_db_link_name          IN   VARCHAR2' || gk_cr
      || ' , p_connect_string        IN   VARCHAR2' || gk_cr
      || ' , p_schema                IN   VARCHAR2' || gk_cr
      || ' , p_password              IN   VARCHAR2' || gk_cr
      || ') AS' || gk_cr
      || 'BEGIN' || gk_cr
      || '/**' || gk_cr
      || '* Create a database link.' || gk_cr
      || '*' || gk_cr
      || '* @param p_db_link_name: database link name' || gk_cr
      || '* @param p_connect_string: target database connection string' || gk_cr
      || '* @param p_schema: target database schema' || gk_cr
      || '* @param p_password: target database schema password' || gk_cr
      || '*/' || gk_cr
      || '' || gk_cr
      || '   -- Drop the database link if it already exists.' || gk_cr
      || '   BEGIN' || gk_cr
      || '      EXECUTE IMMEDIATE ''DROP DATABASE LINK '' || p_db_link_name;' || gk_cr
      || '   EXCEPTION' || gk_cr
      || '      WHEN OTHERS THEN' || gk_cr
      || '         NULL;' || gk_cr
      || '   END;' || gk_cr
      || '   ' || gk_cr
      || '   -- Create the database link.' || gk_cr
      || '   EXECUTE IMMEDIATE' || gk_cr
      || '      ''CREATE DATABASE LINK ''' || gk_cr
      || '   || p_db_link_name' || gk_cr
      || '   || '' CONNECT TO "''' || gk_cr
      || '   || p_schema' || gk_cr
      || '   || ''" IDENTIFIED BY "''' || gk_cr
      || '   || p_password' || gk_cr
      || '   || ''" USING ''''''' || gk_cr
      || '   || p_connect_string' || gk_cr
      || '   || '''''''';' || gk_cr
      || '' || gk_cr
      || 'END dpp_create_db_link;' || gk_cr;

   -- code of a PL/SQL procedure that drops a database link
   gk_db_link_drop_proc       CONSTANT CLOB              :=
         'CREATE OR REPLACE PROCEDURE {target_schema}.dpp_drop_db_link (' || gk_cr
      || '   p_db_link_name          IN   VARCHAR2' || gk_cr
      || ') AS' || gk_cr
      || 'BEGIN' || gk_cr
      || '/**' || gk_cr
      || '* Drop a database link.' || gk_cr
      || '*' || gk_cr
      || '* @param p_db_link_name: database link name' || gk_cr
      || '*/' || gk_cr
      || '' || gk_cr
      || '   -- Drop the database link if it already exists.' || gk_cr
      || '   BEGIN' || gk_cr
      || '      EXECUTE IMMEDIATE ''DROP DATABASE LINK '' || p_db_link_name;' || gk_cr
      || '   EXCEPTION' || gk_cr
      || '      WHEN OTHERS THEN' || gk_cr
      || '         NULL;' || gk_cr
      || '   END;' || gk_cr
      || '' || gk_cr
      || 'END dpp_drop_db_link;' || gk_cr;

   -- code of a PL/SQL block that calls the procedure that creates the
   -- database link
   gk_db_link_creation        CONSTANT CLOB              :=
         'BEGIN' || gk_cr
      || '   {target_schema}.dpp_create_db_link(' || gk_cr
      || '      p_db_link_name    => ''{p_db_link_name}''' || gk_cr
      || '    , p_connect_string  => ''{p_db_link_conn_string}''' || gk_cr
      || '    , p_schema          => ''{p_db_link_user}''' || gk_cr
      || '    , p_password        => ''{p_db_link_pwd}''' || gk_cr
      || '   );' || gk_cr
      || 'END;' || gk_cr;


   -- code of a PL/SQL block that calls the procedure that drops the
   -- database link
   gk_db_link_deletion        CONSTANT CLOB              :=
         'BEGIN' || gk_cr
      || '   {target_schema}.dpp_drop_db_link(' || gk_cr
      || '      p_db_link_name    => ''{p_db_link_name}''' || gk_cr
      || '   );' || gk_cr
      || 'END;' || gk_cr;


   -- code of a PL/SQL block that drops the procedure that creates the
   -- database link
   gk_db_link_drop            CONSTANT CLOB              :=
         'DROP PROCEDURE {target_schema}.dpp_create_db_link';

   -- code of a PL/SQL block that drops the procedure that drops the
   -- database link
   gk_db_link_drop_drop       CONSTANT CLOB              :=
         'DROP PROCEDURE {target_schema}.dpp_drop_db_link';

   -- code of a PL/SQL block that sends an HTTP request.
   gk_actcode_http_request    CONSTANT CLOB              :=
         'BEGIN ' || gk_cr
      || '   http_utility_krn.send_http_request( ' || gk_cr
      || '      {url} ' || gk_cr
      || '    , {wallet_path} ' || gk_cr
      || '    , {proxy} ' || gk_cr
      || '   ); ' || gk_cr
      || 'END; '; 

   -- code of a PL/SQL block that sends a GitLab HTTP request.
   gk_actcode_gitlab_http_req CONSTANT CLOB              :=
         'BEGIN ' || gk_cr
      || '   http_utility_krn.send_gitlab_http_request( ' || gk_cr
      || '      {url} ' || gk_cr
      || '    , {token} ' || gk_cr
      || '    , {var_name} ' || gk_cr
      || '    , {var_value} ' || gk_cr
      || '    , {wallet_path} ' || gk_cr
      || '    , {proxy} ' || gk_cr
      || '   ); ' || gk_cr
      || 'END; '; 

END dpp_cnf_var;
/
