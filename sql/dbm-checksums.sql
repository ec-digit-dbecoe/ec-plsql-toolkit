      WITH
         -- Get constraint search_condition as VARCHAR2(4000 CHAR)
         FUNCTION get_con_search_condition (
            p_owner IN VARCHAR2
          , p_name IN VARCHAR2
         )
         RETURN VARCHAR2
         IS
            CURSOR c_con IS
               SELECT search_condition
                 FROM all_constraints
                WHERE owner = p_owner
                  AND constraint_name = p_name
                  AND constraint_type = 'C'
               ;
            l_search_condition all_constraints.search_condition%TYPE;
         BEGIN
            OPEN c_con;
            FETCH c_con INTO l_search_condition;
            CLOSE c_con;
            RETURN SUBSTR(l_search_condition,1,4000);
         END get_con_search_condition;
         -- Get mview query as VARCHAR2(4000 CHAR)
         FUNCTION get_mview_query (
            p_owner IN VARCHAR2
          , p_name IN VARCHAR2
         )
         RETURN VARCHAR2
         IS
            CURSOR c_mvw IS
               SELECT QUERY
                 FROM all_mviews
                WHERE owner = p_owner
                  AND mview_name = p_name
               ;
            l_query all_mviews.QUERY%TYPE;
         BEGIN
            OPEN c_mvw;
            FETCH c_mvw INTO l_query;
            CLOSE c_mvw;
            RETURN SUBSTR(l_query,1,4000);
         END get_mview_query;
         -- Get view text as VARCHAR2(4000 CHAR)
         FUNCTION get_view_text (
            p_owner IN VARCHAR2
          , p_name IN VARCHAR2
         )
         RETURN VARCHAR2
         IS
            CURSOR c_vw IS
               SELECT text
                 FROM all_views
                WHERE owner = p_owner
                  AND view_name = p_name
               ;
            l_text all_views.text%TYPE;
         BEGIN
            OPEN c_vw;
            FETCH c_vw INTO l_text;
            CLOSE c_vw;
            RETURN SUBSTR(l_text,1,4000);
         END get_view_text;
            SELECT MOD(SUM(CASE WHEN NOT REGEXP_LIKE(name, '^(PACKAGE|PACKAGE BODY)') THEN checksum ELSE 0 END),POWER(2,30)) obj_checksum
                 , MOD(SUM(CASE WHEN REGEXP_LIKE(name, '^(PACKAGE|PACKAGE BODY)') THEN checksum ELSE 0 END),POWER(2,30)) pkg_checksum
              FROM (
               -- Generic handling for all object types
               SELECT obj.object_type||' '||obj.object_name name, MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(src.text,'\s*$'),1000000000,POWER(2,30))),POWER(2,30)) checksum, obj.status
                 FROM all_objects obj
                 LEFT OUTER JOIN all_source src
                   ON src.owner = obj.owner
                  AND src.type = obj.object_type
                  AND src.name = obj.object_name
                WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
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
                  AND REGEXP_LIKE('TABLE '||con.table_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
                GROUP BY con.constraint_name, con.constraint_type, con.table_name
                )
                UNION ALL
               -- Specific handling for check constraints
               SELECT 'CONSTRAINT '||con.constraint_name
                    , MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(get_con_search_condition(con.owner, con.constraint_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), 'VALID'
                 FROM all_constraints con
                WHERE con.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND SUBSTR(con.table_name,1,4) != 'BIN$'
                  AND con.constraint_type IN ('C')
                  AND con.constraint_name NOT LIKE 'SYS%'
                  AND REGEXP_LIKE('TABLE '||con.table_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
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
                  AND REGEXP_LIKE('TABLE '||ind.table_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE('TABLE '||ind.table_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
                GROUP BY ind.uniqueness, ind.table_name, ind.index_name, ind.status
                    )
                UNION ALL
               -- Specific handling for views
               SELECT 'VIEW '||vw.view_name, MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(get_view_text(USER,vw.view_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), obj.status
                 FROM all_views vw
                INNER JOIN all_objects obj
                   ON obj.owner = vw.owner
                  AND obj.object_name = vw.view_name
                WHERE vw.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
                GROUP BY vw.view_name, obj.status
                UNION ALL
               -- Specific handling for materialized views
               SELECT 'MATERIALIZED VIEW' ||mvw.mview_name
                    , MOD(SUM(sys.dbms_utility.get_hash_value(REGEXP_REPLACE(get_mview_query(USER,mvw.mview_name),'\s*$'),1000000000,POWER(2,30))),POWER(2,30)), obj.status
                 FROM all_mviews mvw
                INNER JOIN all_objects obj
                   ON obj.owner = mvw.owner
                  AND obj.object_name = mvw.mview_name
                WHERE mvw.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
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
                        AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                        AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
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
                  AND REGEXP_LIKE('SEQUENCE '||sequence_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE('SEQUENCE '||sequence_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
                UNION ALL
               -- Specific handling for synonyms
               SELECT obj.object_type||' '||obj.object_name, MOD(sys.dbms_utility.get_hash_value(syn.table_name,1000000000,POWER(2,30)),POWER(2,30)), obj.status
                 FROM all_synonyms syn
                INNER JOIN all_objects obj
                   ON obj.owner = syn.owner
                  AND obj.object_type = 'SYNONYM'
                  AND obj.object_name = syn.synonym_name
                WHERE syn.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
                UNION ALL
               -- Specific handling for public synonyms
--               SELECT 'PUBLIC SYNONYM '||synonym_name, MOD(sys.dbms_utility.get_hash_value(table_name,1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
--                 FROM all_synonyms
--                WHERE owner = 'PUBLIC'
--                  AND table_owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
--                  AND REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
--                  AND NOT REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
--                  AND :p_public = 'Y'
--                UNION ALL
               -- Specific handling for public grants
--               SELECT 'PUBLIC GRANT ON '||table_name, MOD(sys.dbms_utility.get_hash_value(LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege),1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
--                 FROM all_tab_privs
--                WHERE grantee = 'PUBLIC'
--                  AND grantor = SYS_CONTEXT('USERENV', 'SESSION_USER')
--                  AND table_schema = SYS_CONTEXT('USERENV', 'SESSION_USER')
--                  AND REGEXP_LIKE('PUBLIC GRANT ON '||table_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
--                  AND NOT REGEXP_LIKE('PUBLIC GRANT ON '||table_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
--                  AND :p_public = 'Y'
--                GROUP BY table_name
--                UNION ALL
               -- Specific handling for other objects
               SELECT obj.object_type||' '||obj.object_name, NULL, obj.status
                 FROM all_objects obj
                WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND obj.object_type NOT IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER'
                                             ,'INDEX','VIEW','MATERIALIZED VIEW','TABLE','SEQUENCE','SYNONYM', 'JAVA SOURCE')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_')
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$')
             ) new
             ORDER BY 1;