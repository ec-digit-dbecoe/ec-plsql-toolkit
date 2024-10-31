CREATE OR REPLACE PACKAGE dbm_utility_var AS
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
   g_os_name VARCHAR2(10); -- Windows, Linux
   g_debug BOOLEAN := FALSE;
   g_exit BOOLEAN := TRUE;
   g_conf_path VARCHAR2(200) := 'conf\dbm_utility.conf';
   SUBTYPE g_obj_type IS VARCHAR2(61);
--   SUBTYPE g_obj_name_type IS VARCHAR2(30);
   SUBTYPE g_par_name_type IS VARCHAR2(30);
   SUBTYPE g_par_value_type IS VARCHAR2(100);
   SUBTYPE g_checksum_type IS VARCHAR2(32);
   SUBTYPE g_path_type IS VARCHAR2(400);
   SUBTYPE g_sql_type IS VARCHAR2(400);
   TYPE gt_var_type IS TABLE OF dbm_variables%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ga_par_type IS TABLE OF g_par_value_type INDEX BY g_par_name_type;
   TYPE gt_obj_type IS TABLE OF dbm_objects%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE ga_obj_type IS TABLE OF dbm_objects%ROWTYPE INDEX BY dbm_objects.name%TYPE;
   TYPE ga_fil_type IS TABLE OF g_sql_type INDEX BY g_path_type;
   TYPE r_ver_type IS RECORD (
      r_app dbm_applications%ROWTYPE
    , r_ver dbm_versions%ROWTYPE
    , t_ins_files sys.dbms_sql.varchar2a -- installation files
    , t_inr_files sys.dbms_sql.varchar2a -- installatio rollback files
    , t_upg_files sys.dbms_sql.varchar2a -- upgrade files
    , t_upr_files sys.dbms_sql.varchar2a -- upgrade rollback files
    , t_uni_files sys.dbms_sql.varchar2a -- uninstall files
    , t_val_files sys.dbms_sql.varchar2a -- validate files
    , t_cfg_files sys.dbms_sql.varchar2a -- config files
    , t_pre_files sys.dbms_sql.varchar2a -- precheck files
    , t_set_files sys.dbms_sql.varchar2a -- setup files
    , t_var gt_var_type -- variables
    , a_par ga_par_type -- parameters
    , a_obj ga_obj_type -- objects
    , a_fil ga_fil_type -- files 
   );
   TYPE gt_ver_type IS TABLE OF r_ver_type INDEX BY BINARY_INTEGER;
   TYPE ga_app_type IS TABLE OF gt_ver_type INDEX BY dbm_applications.app_code%TYPE;
   ga_app ga_app_type;
   g_file_extensions VARCHAR2(500) := 'sql, pks, pkb, pls, plb';
   gr_last_str dbm_streams%ROWTYPE;
   TYPE gt_str_type IS TABLE OF dbm_streams%ROWTYPE INDEX BY BINARY_INTEGER;
   gt_str gt_str_type;
   TYPE gt_cmd_type IS TABLE OF PLS_INTEGER INDEX BY dbm_commands.command_line%TYPE;
   ga_cmd gt_cmd_type;
   CURSOR gc_obj (
      p_object_name_pattern IN VARCHAR2
    , p_object_name_anti_pattern IN VARCHAR2 := NULL
   )
   IS
         -- Generic handling for all object types
         SELECT obj.object_type||' '||obj.object_name||': '||MOD(SUM(sys.dbms_utility.get_hash_value(RTRIM(RTRIM(src.text,CHR(10))),1000000000,POWER(2,30))),POWER(2,30)) object, obj.status
           FROM user_objects obj
           LEFT OUTER JOIN user_source src
             ON src.type = obj.object_type
            AND src.name = obj.object_name
          WHERE REGEXP_LIKE(obj.object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(obj.object_name, p_object_name_anti_pattern)
            AND obj.object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER')
          GROUP BY obj.object_type, obj.object_name, obj.status
          UNION ALL
         -- Specific handling for pk, uk and fk
         SELECT 'CONSTRAINT '||constraint_name|| ': ' ||MOD(sys.dbms_utility.get_hash_value(constraint_type||' ON '||table_name||' ('||columns_list||')',1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
          FROM (
         SELECT con.constraint_name
              , DECODE(con.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY')||' CONSTRAINT' constraint_type
              , con.table_name
              , LISTAGG(col.column_name, ', ') WITHIN GROUP (ORDER BY col.position) columns_list
           FROM user_constraints con
          INNER JOIN user_cons_columns col
             ON col.constraint_name = con.constraint_name
          WHERE SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.constraint_type IN ('P','U','R')
            AND REGEXP_LIKE(con.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(con.table_name, p_object_name_anti_pattern)
          GROUP BY con.constraint_name, con.constraint_type, con.table_name
          )
          UNION ALL
         -- Specific handling for check constraints
         SELECT 'CONSTRAINT '||con.constraint_name
             || ': '||MOD(SUM(sys.dbms_utility.get_hash_value(RTRIM(RTRIM(dbm_utility_ext.get_con_search_condition(con.owner, con.constraint_name),CHR(10))),1000000000,POWER(2,30))),POWER(2,30)), 'VALID'
           FROM user_constraints con
          WHERE SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.constraint_type IN ('C')
            AND con.constraint_name NOT LIKE 'SYS%'
            AND REGEXP_LIKE(con.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(con.table_name, p_object_name_anti_pattern)
          GROUP BY con.constraint_type, con.table_name, con.constraint_name
         UNION ALL
         -- Specific handling for indexes
         SELECT 'INDEX ' || index_name || ': ' || MOD(sys.dbms_utility.get_hash_value(uniqueness||' INDEX ON '||table_name||' ('||column_lists||')',1000000000,POWER(2,30)),POWER(2,30)), status
           FROM (
         SELECT ind.uniqueness, ind.table_name, ind.index_name, ind.status
              , LISTAGG(col.column_name, ', ') WITHIN GROUP (ORDER BY col.column_position) AS column_lists
           FROM user_indexes ind
          INNER JOIN user_ind_columns col
             ON col.index_name = ind.index_Name
          WHERE REGEXP_LIKE(ind.table_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(ind.table_name, p_object_name_anti_pattern)
          GROUP BY ind.uniqueness, ind.table_name, ind.index_name, ind.status
              )
          UNION ALL
         -- Specific handling for views
         SELECT 'VIEW '||vw.view_name || ': '||MOD(SUM(sys.dbms_utility.get_hash_value(RTRIM(RTRIM(dbm_utility_ext.get_view_text(USER,vw.view_name),CHR(10))),1000000000,POWER(2,30))),POWER(2,30)), obj.status
           FROM user_views vw
          INNER JOIN user_objects obj
             ON obj.object_name = vw.view_name
          WHERE REGEXP_LIKE(vw.view_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(vw.view_name, p_object_name_anti_pattern)
          GROUP BY vw.view_name, obj.status
          UNION ALL
         -- Specific handling for materialized views
         SELECT 'MATERIALIZED VIEW' ||mvw.mview_name
             || ': '||MOD(SUM(sys.dbms_utility.get_hash_value(RTRIM(RTRIM(dbm_utility_ext.get_mview_query(USER,mvw.mview_name),CHR(10))),1000000000,POWER(2,30))),POWER(2,30)), obj.status
           FROM user_mviews mvw
          INNER JOIN user_objects obj
             ON obj.object_name = mvw.mview_name
          WHERE REGEXP_LIKE(mvw.mview_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(mvw.mview_name, p_object_name_anti_pattern)
          GROUP BY mvw.mview_name, obj.status
          UNION ALL
         -- Specific handling for tables
         SELECT object_type||' '||object_name||': '||MOD(sys.dbms_utility.get_hash_value(columns_list,1000000000,POWER(2,30)),POWER(2,30)), status
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
                 FROM user_tab_columns col
                INNER JOIN user_objects obj
                   ON obj.object_name  = col.table_name
                WHERE REGEXP_LIKE(col.table_name, p_object_name_pattern)
                  AND NOT REGEXP_LIKE(col.table_name, p_object_name_anti_pattern)
                  AND SUBSTR(col.table_name,1,4) != 'BIN$'
                ORDER BY col.column_name
            )
            GROUP BY object_type, object_name, status
          )
          UNION ALL
         -- Specific handling for sequences
         SELECT 'SEQUENCE '||sequence_name||': '||MOD(sys.dbms_utility.get_hash_value(' INCREMENT BY ' || increment_by
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
           FROM user_sequences
          WHERE REGEXP_LIKE(sequence_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(sequence_name, p_object_name_anti_pattern)
          UNION ALL
         -- Specific handling for synonyms
         SELECT obj.object_type||' '||obj.object_name|| ': ' ||MOD(sys.dbms_utility.get_hash_value(syn.table_name,1000000000,POWER(2,30)),POWER(2,30)), obj.status
           FROM user_synonyms syn
          INNER JOIN user_objects obj
             ON obj.object_type = 'SYNONYM'
            AND obj.object_name = syn.synonym_name
          WHERE REGEXP_LIKE(syn.synonym_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(syn.synonym_name, p_object_name_anti_pattern)
          UNION ALL
         -- Specific handling for other objects
         SELECT object_type||' '||object_name, status
           FROM user_objects
          WHERE object_type NOT IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER'
                                   ,'INDEX','VIEW','MATERIALIZED VIEW','TABLE','SEQUENCE','SYNONYM')
            AND REGEXP_LIKE(object_name, p_object_name_pattern)
            AND NOT REGEXP_LIKE(object_name, p_object_name_anti_pattern)
          ORDER BY 1, 2
   ;
END dbm_utility_var;
/
