CREATE OR REPLACE PACKAGE dbm_utility_var
AUTHID DEFINER
AS
---
-- Copyright (C) 2024 European Commission
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
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
   -- Types and subtypes
   SUBTYPE g_obj_type IS VARCHAR2(61);
   SUBTYPE g_par_name_type IS VARCHAR2(30);
   SUBTYPE g_par_value_type IS VARCHAR2(100);
   SUBTYPE g_checksum_type IS VARCHAR2(32);
   SUBTYPE g_path_type IS VARCHAR2(400);
   SUBTYPE g_sql_type IS VARCHAR2(400);
   SUBTYPE g_priv_type IS VARCHAR2(100);
   TYPE gt_var_type IS TABLE OF dbm_variables%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ga_par_type IS TABLE OF g_par_value_type INDEX BY g_par_name_type;
   TYPE gt_obj_type IS TABLE OF dbm_objects%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ga_obj_type IS TABLE OF dbm_objects%ROWTYPE INDEX BY dbm_objects.name%TYPE;
   TYPE ga_fil_type IS TABLE OF g_sql_type INDEX BY g_path_type;
   TYPE ga_oco_type IS TABLE OF g_sql_type INDEX BY g_obj_type;
   TYPE gt_prv_type IS TABLE OF dbm_privileges%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ga_prv_type IS TABLE OF dbm_privileges%ROWTYPE INDEX BY dbm_privileges.text%TYPE;
   TYPE ga_priv_type IS TABLE OF g_priv_type INDEX BY g_priv_type;
   TYPE r_ver_type IS RECORD (
      r_app dbm_applications%ROWTYPE
    , r_ver dbm_versions%ROWTYPE
    , t_ins_files sys.dbms_sql.varchar2a -- INSTALLATION files
    , t_inr_files sys.dbms_sql.varchar2a -- INSTALLATION ROLLBACK files
    , t_upg_files sys.dbms_sql.varchar2a -- UPGRADE files
    , t_upr_files sys.dbms_sql.varchar2a -- UPGRADE ROLLBACK files
    , t_uni_files sys.dbms_sql.varchar2a -- UNINSTALL files
    , t_val_files sys.dbms_sql.varchar2a -- VALIDATE files
    , t_cfg_files sys.dbms_sql.varchar2a -- CONFIG files
    , t_pre_files sys.dbms_sql.varchar2a -- PRECHECK files
    , t_set_files sys.dbms_sql.varchar2a -- SETUP files
    , t_exp_files sys.dbms_sql.varchar2a -- EXPOSE files
    , t_con_files sys.dbms_sql.varchar2a -- CONCEAL files
    , t_xpo_files sys.dbms_sql.varchar2a -- EXPORT files
    , t_imp_files sys.dbms_sql.varchar2a -- IMPORT files
    , t_ins_prompts sys.dbms_sql.varchar2a -- INSTALLATION prompts
    , t_inr_prompts sys.dbms_sql.varchar2a -- INSTALLATION ROLLBACK prompts
    , t_upg_prompts sys.dbms_sql.varchar2a -- UPGRADE prompts
    , t_upr_prompts sys.dbms_sql.varchar2a -- UPGRADE ROLLBACK prompts
    , t_uni_prompts sys.dbms_sql.varchar2a -- UNINSTALL prompts
    , t_val_prompts sys.dbms_sql.varchar2a -- VALIDATE prompts
    , t_cfg_prompts sys.dbms_sql.varchar2a -- CONFIG prompts
    , t_pre_prompts sys.dbms_sql.varchar2a -- PRECHECK prompts
    , t_set_prompts sys.dbms_sql.varchar2a -- SETUP prompts
    , t_exp_prompts sys.dbms_sql.varchar2a -- EXPOSE prompts
    , t_con_prompts sys.dbms_sql.varchar2a -- CONCEAL prompts
    , t_xpo_prompts sys.dbms_sql.varchar2a -- EXPORT prompts
    , t_imp_prompts sys.dbms_sql.varchar2a -- IMPORT prompts
    , t_var gt_var_type -- variables
    , a_par ga_par_type -- parameters
    , a_obj ga_obj_type -- objects
    , a_fil ga_fil_type -- files
    , t_prv gt_prv_type -- privileges
   );
   TYPE gt_ver_type IS TABLE OF r_ver_type INDEX BY BINARY_INTEGER;
   TYPE ga_app_type IS TABLE OF gt_ver_type INDEX BY dbm_applications.app_code%TYPE;
   TYPE gt_str_type IS TABLE OF dbm_streams%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE gt_cmd_type IS TABLE OF PLS_INTEGER INDEX BY dbm_commands.command_line%TYPE;
   TYPE gr_option_type IS RECORD (
      name  VARCHAR2(30)
    , value VARCHAR2(100)
   );
   TYPE gt_options_type IS TABLE OF gr_option_type INDEX BY BINARY_INTEGER;
   TYPE gt_params_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
   TYPE gr_command_type IS RECORD (
      cmd_id dbm_commands.cmd_id%TYPE
    , command VARCHAR2(100)
    , t_options gt_options_type
    , t_params gt_params_type
    , col_no_from PLS_INTEGER
    , col_no_to PLS_INTEGER
   );
   TYPE gt_command_type IS TABLE OF gr_command_type INDEX BY BINARY_INTEGER;
   -- Parameters
   g_os_name VARCHAR2(30); -- Windows_NT, Linux
   g_debug BOOLEAN := FALSE;
   g_trace BOOLEAN := FALSE;
   g_silent BOOLEAN := FALSE;
   g_splash BOOLEAN := TRUE;
   g_exit BOOLEAN := TRUE;
   g_batch BOOLEAN := FALSE;
   g_first_level BOOLEAN := FALSE;
   g_scan BOOLEAN := TRUE; -- scan file system upon startup?
   g_db_name VARCHAR2(30) := sys_context('USERENV','DB_NAME');
   g_rp_name VARCHAR2(30) := 'DBM_RESTORE_POINT';
   -- Other globals
   ga_app ga_app_type;
   gr_last_str dbm_streams%ROWTYPE;
   gt_str gt_str_type;
   ga_cmd gt_cmd_type;
   ga_any_sys_priv ga_priv_type;
   ga_any_tab_priv ga_priv_type;
   gt_spool sys.dbms_sql.varchar2a;
   CURSOR gc_obj (
      p_object_name_pattern IN VARCHAR2
    , p_object_name_anti_pattern IN VARCHAR2 := NULL
    , p_public IN VARCHAR2 := NULL
    , p_app_code dbm_objects.app_code%TYPE := NULL
    , p_ver_code dbm_objects.ver_code%TYPE := NULL
   )
   IS
      SELECT new.name
          || CASE WHEN new.checksum IS NOT NULL OR old.condition IS NOT NULL THEN ':' END
          || CASE WHEN new.checksum IS NOT NULL THEN ' ' || new.checksum END
          || CASE WHEN old.condition IS NOT NULL THEN ' ' ||old.condition END object
           , new.status
        FROM (
         -- Generic handling for all object types
         SELECT obj.object_type||' '||obj.object_name name, MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(src.text,'\s*$'),1000000000,POWER(2,30))),POWER(2,30)) checksum, obj.status
           FROM all_objects obj
           LEFT OUTER JOIN all_source src
             ON src.owner = obj.owner
            AND src.type = obj.object_type
            AND src.name = obj.object_name
          WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
            AND obj.object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER','JAVA SOURCE')
          GROUP BY obj.object_type, obj.object_name, obj.status
          UNION ALL
         -- Specific handling for pk, uk and fk
         SELECT 'CONSTRAINT '||constraint_name, MOD(sys.dbms_utility.get_hash_value(constraint_type||' ON '||table_name||' ('||columns_list||')',1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
          FROM (
         SELECT con.constraint_name
              , DECODE(con.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY')||' CONSTRAINT' constraint_type
              , con.table_name
              , LISTAGG(col.column_name, ', ') WITHIN GROUP (ORDER BY col.position) columns_list
           FROM all_constraints con
          INNER JOIN all_cons_columns col
             ON col.owner = con.owner
            AND col.constraint_name = con.constraint_name
          WHERE con.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.constraint_type IN ('P','U','R')
            AND REGEXP_LIKE('TABLE '||con.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('TABLE '||con.table_name, p_object_name_anti_pattern)
          GROUP BY con.constraint_name, con.constraint_type, con.table_name
          )
          UNION ALL
         -- Specific handling for check constraints
         SELECT 'CONSTRAINT '||con.constraint_name
              , MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(dbm_utility_ext.get_con_search_condition(con.owner, con.constraint_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), 'VALID'
           FROM all_constraints con
          WHERE con.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.constraint_type IN ('C')
            AND con.constraint_name NOT LIKE 'SYS%'
            AND REGEXP_LIKE('TABLE '||con.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('TABLE '||con.table_name, p_object_name_anti_pattern)
          GROUP BY con.constraint_type, con.table_name, con.constraint_name
         UNION ALL
         -- Specific handling for indexes
         SELECT 'INDEX ' || index_name, MOD(sys.dbms_utility.get_hash_value(uniqueness||' INDEX ON '||table_name||' ('||column_lists||')',1000000000,POWER(2,30)),POWER(2,30)), status
           FROM (
         SELECT ind.uniqueness, ind.table_name, ind.index_name, ind.status
              , LISTAGG(col.column_name, ', ') WITHIN GROUP (ORDER BY col.column_position) AS column_lists
           FROM all_indexes ind
          INNER JOIN all_ind_columns col
             ON col.index_owner = ind.owner
            AND col.index_name = ind.index_name
          WHERE ind.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE('TABLE '||ind.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('TABLE '||ind.table_name, p_object_name_anti_pattern)
          GROUP BY ind.uniqueness, ind.table_name, ind.index_name, ind.status
              )
          UNION ALL
         -- Specific handling for views
         SELECT 'VIEW '||vw.view_name, MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(dbm_utility_ext.get_view_text(USER,vw.view_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), obj.status
           FROM all_views vw
          INNER JOIN all_objects obj
             ON obj.owner = vw.owner
            AND obj.object_name = vw.view_name
          WHERE vw.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
          GROUP BY vw.view_name, obj.status
          UNION ALL
         -- Specific handling for materialized views
         SELECT 'MATERIALIZED VIEW' ||mvw.mview_name
              , MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(dbm_utility_ext.get_mview_query(USER,mvw.mview_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), obj.status
           FROM all_mviews mvw
          INNER JOIN all_objects obj
             ON obj.owner = mvw.owner
            AND obj.object_name = mvw.mview_name
          WHERE mvw.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
          GROUP BY mvw.mview_name, obj.status
          UNION ALL
         -- Specific handling for tables
         SELECT object_type||' '||object_name, MOD(sys.dbms_utility.get_hash_value(columns_list,1000000000,POWER(2,30)),POWER(2,30)), status
           FROM (
            SELECT object_type, object_name, LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_name) AS columns_list, status
            FROM (
               SELECT obj.object_type, obj.object_name, obj.status, col.column_name || ' '
                      || CASE WHEN col.data_type = 'NUMBER' AND col.data_precision IS NULL AND col.data_scale = 0 THEN 'INTEGER' ELSE col.data_type END
                      || CASE WHEN col.data_precision IS NOT NULL THEN --NUMBER()?
                              CASE WHEN NVL(col.data_scale,0) > 0
                                   THEN '('||col.data_precision||','||col.data_scale||')'
                                   ELSE '('||col.data_precision||')'
                               END
                              WHEN col.char_used IS NOT NULL /*CHAR,VARCHAR2*/
                              THEN '('||col.char_length||CASE WHEN col.char_used='C' THEN ' CHAR' END||')'
                         END
                      || CASE WHEN col.nullable = 'N' THEN ' NOT NULL' END column_name
                 FROM all_tab_columns col
                INNER JOIN all_objects obj
                   ON obj.owner = col.owner
                  AND obj.object_type = 'TABLE'
                  AND obj.object_name  = col.table_name
                WHERE col.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
                  AND SUBSTR(col.table_name,1,4) != 'BIN$'
                ORDER BY col.column_name
            )
            GROUP BY object_type, object_name, status
          )
          UNION ALL
         -- Specific handling for sequences
         SELECT 'SEQUENCE '||sequence_name, MOD(sys.dbms_utility.get_hash_value(' INCREMENT BY ' || increment_by
             || CASE WHEN min_value IS NULL THEN ' NOMINVALUE' ELSE ' MINVALUE '||min_value END
             || CASE WHEN max_value IS NULL THEN ' NOMAXVALUE' ELSE ' MAXVALUE '||max_value END
             || CASE WHEN cycle_flag = 'N' THEN ' NOCYCLE' ELSE ' CYCLE' END
             || CASE WHEN cache_size = 0 THEN ' NOCACHE' ELSE ' CACHE '||cache_size END
             || CASE WHEN order_flag = 'N' THEN ' NOORDER' ELSE ' ORDER' END
             || CASE WHEN keep_value = 'N' THEN ' NOKEEP' ELSE ' KEEP' END
             || CASE WHEN scale_flag = 'N' THEN ' NOSCALE' ELSE ' SCALE ' || CASE WHEN extend_flag = 'N' THEN 'NOEXTEND' ELSE 'EXTEND' END END
             || CASE WHEN sharded_flag = 'N' THEN ' NOSHARD' ELSE ' SHARD ' || CASE WHEN extend_flag = 'N' THEN 'NOEXTEND' ELSE 'EXTEND' END END
             || CASE WHEN session_flag = 'N' THEN ' GLOBAL' ELSE ' SESSION' END
             ,1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
           FROM all_sequences
          WHERE sequence_owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE('SEQUENCE '||sequence_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('SEQUENCE '||sequence_name, p_object_name_anti_pattern)
          UNION ALL
         -- Specific handling for synonyms
         SELECT obj.object_type||' '||obj.object_name, MOD(sys.dbms_utility.get_hash_value(syn.table_name,1000000000,POWER(2,30)),POWER(2,30)), obj.status
           FROM all_synonyms syn
          INNER JOIN all_objects obj
             ON obj.owner = syn.owner
            AND obj.object_type = 'SYNONYM'
            AND obj.object_name = syn.synonym_name
          WHERE syn.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
          UNION ALL
         -- Specific handling for public synonyms
         SELECT 'PUBLIC SYNONYM '||synonym_name, MOD(sys.dbms_utility.get_hash_value(table_name,1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
           FROM all_synonyms
          WHERE owner = 'PUBLIC'
            AND table_owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, p_object_name_anti_pattern)
            AND p_public = 'Y'
          UNION ALL
         -- Specific handling for public grants
         SELECT 'PUBLIC GRANT ON '||table_name, MOD(sys.dbms_utility.get_hash_value(LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege),1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
           FROM all_tab_privs
          WHERE grantee = 'PUBLIC'
            AND grantor = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND table_schema = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND REGEXP_LIKE('PUBLIC GRANT ON '||table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE('PUBLIC GRANT ON '||table_name, p_object_name_anti_pattern)
            AND p_public = 'Y'
          GROUP BY table_name
          UNION ALL
         -- Specific handling for other objects
         SELECT obj.object_type||' '||obj.object_name, NULL, obj.status
           FROM all_objects obj
          WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
            AND obj.object_type NOT IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER'
                                       ,'INDEX','VIEW','MATERIALIZED VIEW','TABLE','SEQUENCE','SYNONYM', 'JAVA SOURCE')
            AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, p_object_name_anti_pattern)
       ) new
        LEFT OUTER JOIN dbm_objects old
          ON app_code = p_app_code
         AND ver_code = p_ver_code
         AND old.name = new.name
       ORDER BY 1
   ;
END dbm_utility_var;
/