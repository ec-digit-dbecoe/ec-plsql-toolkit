--CREATE OR REPLACE PROCEDURE migrate_dbm AS
set feedback off
whenever sqlerror exit sql.sqlcode rollback;
set echo off
set termout off
set verify off
set trimspool off
set sqlprefix "~"
set linesize 200
set feedback off
set head off
set serveroutput on size 999999
REM Get target version from (optional) passed parameter
column 1 new_value 1
select '' "1" from dual where 1=2;
define tgt_ver_code="&1"
undefine 1
REM Get source version from (optional) passed parameter
column 2 new_value 2
select '' "2" from dual where 1=2;
define src_ver_code="&2"
undefine 2
REM Provide a default value to non-initialised variables
COLUMN tab_ts new_value tab_ts
select '' "tab_ts" from dual where 1=2;
select NVL('&tab_ts',default_tablespace) tab_ts from (select default_tablespace from user_users where username=user);
COLUMN idx_ts new_value idx_ts
select '' "idx_ts" from dual where 1=2;
select NVL('&idx_ts',default_tablespace) idx_ts from (select default_tablespace from user_users where username=user);
REM Proceed
VARIABLE l_script VARCHAR2(255)
VARIABLE l_nxt_ver_code VARCHAR2(10)
VARIABLE l_nxt_ver_nbr NUMBER
VARIABLE l_action VARCHAR2(10)
VARIABLE l_nxt_obj_sum NUMBER;
VARIABLE l_nxt_pkg_sum NUMBER;
set termout on
DECLARE
   -- Local types
   SUBTYPE l_ver_code_type IS VARCHAR2(10);
   SUBTYPE l_ver_nbr_type IS NUMBER(6,0);
   SUBTYPE l_checksum_type IS NUMBER;
   TYPE t_version_type IS TABLE OF l_ver_code_type INDEX BY BINARY_INTEGER; --l_ver_nbr_type;
   TYPE a_version_type IS TABLE OF l_ver_nbr_type INDEX BY l_ver_code_type;
   TYPE t_checksum_type IS TABLE OF l_checksum_type INDEX BY BINARY_INTEGER; --l_ver_nbr_type;
   TYPE a_checksum_type IS TABLE OF l_ver_nbr_type INDEX BY BINARY_INTEGER; --l_checksum_type;
   -- Local cursors
   -- Check the status of any global installation
   CURSOR c_pub IS
      SELECT obj.status, COUNT(*)
        FROM all_synonyms syn
       INNER JOIN all_objects obj
          ON obj.owner = syn.table_owner
         AND obj.object_type LIKE 'PACKAGE%'
         AND obj.object_name = syn.table_name
       WHERE syn.synonym_name LIKE 'DBM~_UTILITY~_%' ESCAPE '~'
         AND syn.table_owner != USER
       GROUP BY obj.status
       ORDER BY DECODE(obj.status,'VALID',2,1)
   ;
   -- Get the status of an object
   CURSOR c_obj (
      p_object_type user_objects.object_type%TYPE
    , p_object_name user_objects.object_name%TYPE
   )
   IS
      SELECT object_type, object_name, status
        FROM user_objects
       WHERE object_type = p_object_type
         AND object_name = p_object_name
   ;
   -- Local variables
   t_all t_version_type;
   t_ins t_version_type;
   t_upg t_version_type;
   a_all a_version_type;
   a_ins a_version_type;
   a_upg a_version_type;
   t_obj_sum t_checksum_type;
   a_obj_sum a_checksum_type;
   t_pkg_sum t_checksum_type;
   a_pkg_sum a_checksum_type;
   l_found BOOLEAN;
   r_pub c_pub%ROWTYPE;
   l_obj_sum l_checksum_type;
   l_pkg_sum l_checksum_type;
   l_src_ver_code l_ver_code_type := '&&src_ver_code';
   l_src_ver_nbr l_ver_nbr_type := 0;
   l_tgt_ver_code l_ver_code_type := '&&tgt_ver_code';
   l_tgt_ver_nbr l_ver_nbr_type := 0;
   l_cur_ver_code l_ver_code_type;
   l_cur_ver_nbr l_ver_nbr_type;
   l_nxt_ver_code l_ver_code_type;
   l_nxt_ver_nbr l_ver_nbr_type;
   l_ver_nbr l_ver_nbr_type;
   l_nxt_action VARCHAR2(10);
   l_script VARCHAR2(255);
   l_ext VARCHAR2(3);
   -- Local procedures
   -- Raise exception when a condition is not true
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_text IN VARCHAR2
   )
   IS
   BEGIN
      IF NOT p_condition THEN
         raise_application_error(CASE WHEN p_text LIKE 'INFO:%' THEN -20735 ELSE -20000 END,p_text);
      END IF;
   END;
   -- Get a version number from code
   FUNCTION get_ver_nbr (
      p_ver_code IN l_ver_code_type
   )
   RETURN NUMBER
   IS
      l_ver_nbr NUMBER;
   BEGIN
      IF p_ver_code IS NOT NULL THEN
         l_ver_nbr :=
            NVL(TO_NUMBER(REGEXP_SUBSTR(p_ver_code, '\d+', 1, 1)),0)*100*100 +
            NVL(TO_NUMBER(REGEXP_SUBSTR(p_ver_code, '\d+', 1, 2)),0)*100 +
            NVL(TO_NUMBER(REGEXP_SUBSTR(p_ver_code, '\d+', 1, 3)),0);
      END IF;
      RETURN l_ver_nbr;
   END;
   -- Get objects and packages checksums
   PROCEDURE get_checksums (
      po_obj_sum OUT NUMBER
    , po_pkg_sum OUT NUMBER
   )
   IS
      k_obj_name_pattern CONSTANT VARCHAR2(100) := '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_';
      k_obj_name_anti_pattern CONSTANT VARCHAR2(100) := '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$';
   BEGIN
      EXECUTE IMMEDIATE q'#
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||ind.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||ind.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                        AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                        AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('SEQUENCE '||sequence_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('SEQUENCE '||sequence_name, :p_object_name_anti_pattern)
                UNION ALL
               -- Specific handling for synonyms
               SELECT obj.object_type||' '||obj.object_name, MOD(sys.dbms_utility.get_hash_value(syn.table_name,1000000000,POWER(2,30)),POWER(2,30)), obj.status
                 FROM all_synonyms syn
                INNER JOIN all_objects obj
                   ON obj.owner = syn.owner
                  AND obj.object_type = 'SYNONYM'
                  AND obj.object_name = syn.synonym_name
                WHERE syn.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
                UNION ALL
               -- Specific handling for public synonyms
               SELECT 'PUBLIC SYNONYM '||synonym_name, MOD(sys.dbms_utility.get_hash_value(table_name,1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
                 FROM all_synonyms
                WHERE owner = 'PUBLIC'
                  AND table_owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, :p_object_name_anti_pattern)
                  AND :p_public = 'Y'
                UNION ALL
               -- Specific handling for public grants
               SELECT 'PUBLIC GRANT ON '||table_name, MOD(sys.dbms_utility.get_hash_value(LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege),1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
                 FROM all_tab_privs
                WHERE grantee = 'PUBLIC'
                  AND grantor = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND table_schema = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE('PUBLIC GRANT ON '||table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('PUBLIC GRANT ON '||table_name, :p_object_name_anti_pattern)
                  AND :p_public = 'Y'
                GROUP BY table_name
                UNION ALL
               -- Specific handling for other objects
               SELECT obj.object_type||' '||obj.object_name, NULL, obj.status
                 FROM all_objects obj
                WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND obj.object_type NOT IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER'
                                             ,'INDEX','VIEW','MATERIALIZED VIEW','TABLE','SEQUENCE','SYNONYM', 'JAVA SOURCE')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
             ) new
      #' INTO po_obj_sum, po_pkg_sum USING 
        k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , 'N'
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , 'N'
      , k_obj_name_pattern, k_obj_name_anti_pattern
      ;
   END;
   -- Init
   PROCEDURE initially IS
      l_ver_nbr l_ver_nbr_type;
   BEGIN
      -- Initialise versions
      t_ins(240000) := '24.0';
      t_ins(240100) := '24.1';   t_upg(240100) := '24.1';
      t_ins(240200) := '24.2';   t_upg(240200) := '24.2';
                                 t_upg(240300) := '24.3';
                                 t_upg(240400) := '24.4';
      t_ins(240500) := '24.5';   t_upg(240500) := '24.5';
      t_ins(240600) := '24.6';   t_upg(240600) := '24.6';
      t_ins(240601) := '24.6.1'; t_upg(240601) := '24.6.1';
      t_ins(240700) := '24.7'  ; t_upg(240700) := '24.7';
      t_ins(240800) := '24.8'  ; t_upg(240800) := '24.8';
                                 t_upg(240801) := '24.8.1';
                                 t_upg(240802) := '24.8.2';
                                 t_upg(240803) := '24.8.3';
                                 t_upg(240804) := '24.8.4';
                                 t_upg(240805) := '24.8.5';
      -- Initialise checksums for objects and packages (computed with "sql/dbm_checksums.sql");
      t_obj_sum(240000) := 671291450;  t_pkg_sum(240000) := 296702143;
      t_obj_sum(240100) := 544776930;  t_pkg_sum(240100) := 1062429868;
      t_obj_sum(240200) := 1010123569; t_pkg_sum(240200) := 153766248;
      t_obj_sum(240300) := 1010123569; t_pkg_sum(240300) := 157529376;
      t_obj_sum(240400) := 805098848;  t_pkg_sum(240400) := 232719888;
      t_obj_sum(240500) := 297221505;  t_pkg_sum(240500) := 979987958;
      t_obj_sum(240600) := 475280864;  t_pkg_sum(240600) := 112516412;
      t_obj_sum(240601) := 787073926;  t_pkg_sum(240601) := 112516412;
      t_obj_sum(240700) := 158945673;  t_pkg_sum(240700) := 585332039;
      t_obj_sum(240800) := 343620986;  t_pkg_sum(240800) := 366640237;
      t_obj_sum(240801) := 343620986;  t_pkg_sum(240801) := 734408192;
      t_obj_sum(240802) := 343620986;  t_pkg_sum(240802) := 1038923034;
      t_obj_sum(240803) := 343620986;  t_pkg_sum(240803) := 237393621;
      t_obj_sum(240804) := 343620986;  t_pkg_sum(240804) := 130171331;
      t_obj_sum(240805) := 343620986;  t_pkg_sum(240805) := 434686173;
      -- Initially lookup arrays
      l_ver_nbr := t_ins.FIRST;
      WHILE l_ver_nbr IS NOT NULL LOOP
         t_all(l_ver_nbr) := t_ins(l_ver_nbr);
         a_ins(t_ins(l_ver_nbr)) := l_ver_nbr;
         l_ver_nbr := t_ins.NEXT(l_ver_nbr);
      END LOOP;
      l_ver_nbr := t_upg.FIRST;
      WHILE l_ver_nbr IS NOT NULL LOOP
         t_all(l_ver_nbr) := t_upg(l_ver_nbr);
         a_upg(t_upg(l_ver_nbr)) := l_ver_nbr;
         l_ver_nbr := t_upg.NEXT(l_ver_nbr);
      END LOOP;
      l_ver_nbr := t_all.FIRST;
      WHILE l_ver_nbr IS NOT NULL LOOP
         a_all(t_all(l_ver_nbr)) := l_ver_nbr;
         l_ver_nbr := t_all.NEXT(l_ver_nbr);
      END LOOP;
      l_ver_nbr := t_obj_sum.FIRST;
      WHILE l_ver_nbr IS NOT NULL LOOP
         IF NOT a_obj_sum.EXISTS(t_obj_sum(l_ver_nbr)) THEN
            a_obj_sum(t_obj_sum(l_ver_nbr)) := l_ver_nbr;
         END IF;
         l_ver_nbr := t_obj_sum.NEXT(l_ver_nbr);
      END LOOP;
      l_ver_nbr := t_pkg_sum.FIRST;
      WHILE l_ver_nbr IS NOT NULL LOOP
         IF NOT a_pkg_sum.EXISTS(t_pkg_sum(l_ver_nbr)) THEN
            a_pkg_sum(t_pkg_sum(l_ver_nbr)) := l_ver_nbr;
         END IF;
         l_ver_nbr := t_pkg_sum.NEXT(l_ver_nbr);
      END LOOP;
   END;
BEGIN
   initially;
   -- Check target version
   l_tgt_ver_nbr := get_ver_nbr(l_tgt_ver_code);
   IF l_tgt_ver_code IS NULL THEN
      dbms_output.put_line('Migrating to latest version of DBM...');
   ELSE
      dbms_output.put_line('Migrating to version "'||l_tgt_ver_code||'" of DBM...');
   END IF;
   assert(l_tgt_ver_code IS NULL OR a_all.EXISTS(l_tgt_ver_code), 'ERROR: Target version "'||l_tgt_ver_code||'" is invalid!');
   -- Get checksum of DBM objects and packages
   get_checksums(l_obj_sum, l_pkg_sum);
   dbms_output.put_line('Checksum of actual objects before migration is "'||l_obj_sum||'"');
   dbms_output.put_line('Checksum of actual packages before migration is "'||l_pkg_sum||'"');
   -- Check if DBM is installed
   IF l_obj_sum IS NULL OR l_pkg_sum IS NULL THEN
      -- DBM must be installed
      IF l_tgt_ver_code IS NULL THEN
         -- No target version specified, take latest full release
         l_tgt_ver_code := a_ins.LAST;
         l_tgt_ver_nbr := a_upg(l_tgt_ver_code);
         dbms_output.put_line('Computed target version is "'||l_tgt_ver_code||'" (latest full release)');
      ELSE
         -- Target version specified, check if installable
         assert(a_ins.EXISTS(l_tgt_ver_code), 'ERROR: Target version "'||l_tgt_ver_code||'" is not installable!');
      END IF;
      dbms_output.put_line('Installing version "'||l_tgt_ver_code||'"...');
      l_nxt_ver_code := l_tgt_ver_code;
      l_nxt_action := 'install';
   ELSE
      -- DBM may need an upgrade
      IF l_tgt_ver_code IS NULL THEN
         l_tgt_ver_code := a_upg.LAST;
         l_tgt_ver_nbr := a_upg(l_tgt_ver_code);
         dbms_output.put_line('Computed target version is "'||l_tgt_ver_code||'" (latest release)');
      END IF;
      IF l_src_ver_code IS NULL THEN
         -- Determine currently installed version
         l_cur_ver_nbr := NULL;
         IF a_obj_sum.EXISTS(l_obj_sum) THEN
            -- Found one version with matching objects checksum
            l_cur_ver_nbr := a_obj_sum(l_obj_sum);
            -- Search for the most recent posterior version matching both checksums
            l_ver_nbr := t_obj_sum.NEXT(l_cur_ver_nbr);
            WHILE l_ver_nbr IS NOT NULL LOOP
               EXIT WHEN t_obj_sum(l_ver_nbr) != l_obj_sum;
               IF t_pkg_sum(l_ver_nbr) = l_pkg_sum THEN
                  l_cur_ver_nbr := l_ver_nbr;
                  EXIT;
               END IF;
               l_ver_nbr := t_obj_sum.NEXT(l_ver_nbr);
            END LOOP;
            IF t_pkg_sum(l_cur_ver_nbr) != l_pkg_sum THEN
               dbms_output.put_line('WARNING: packages checksum diverge!');
            END IF;
         ELSIF a_pkg_sum.EXISTS(l_pkg_sum) THEN
            -- Found one version with matching packages checksum
            l_cur_ver_nbr := a_pkg_sum(l_pkg_sum);
            -- Search for the most recent posterior version matching both checksums
            l_ver_nbr := t_pkg_sum.NEXT(l_cur_ver_nbr);
            WHILE l_ver_nbr IS NOT NULL LOOP
               EXIT WHEN t_pkg_sum(l_ver_nbr) != l_pkg_sum;
               IF t_obj_sum(l_ver_nbr) = l_obj_sum THEN
                  l_cur_ver_nbr := l_ver_nbr;
                  EXIT;
               END IF;
               l_ver_nbr := t_pkg_sum.NEXT(l_ver_nbr);
            END LOOP;
            IF t_obj_sum(l_cur_ver_nbr) != l_obj_sum THEN
               dbms_output.put_line('WARNING: objects checksum diverge!');
            END IF;
         END IF;
         assert(l_cur_ver_nbr IS NOT NULL, 'ERROR: Cannot determine currently installed version!');
         assert(t_all.EXISTS(l_cur_ver_nbr), 'ERROR: Cannot determine code of version "'||l_cur_ver_nbr||'"!');
         l_cur_ver_code := t_all(l_cur_ver_nbr);
         dbms_output.put_line('Version "'||l_cur_ver_code||'" seems currently installed');
      ELSE
         assert(a_all.EXISTS(l_src_ver_code), 'ERROR: Source version does not exist!');
         l_src_ver_nbr := a_all(l_src_ver_code);
         l_cur_ver_code := l_src_ver_code;
         l_cur_ver_nbr := l_src_ver_nbr;
         dbms_output.put_line('Current version forced to "'||l_cur_ver_code||'" by end-user');
      END IF;
      assert(NOT l_tgt_ver_nbr < l_cur_ver_nbr, 'ERROR: Target version "'||l_tgt_ver_code||'" is anterior to current version "'||l_cur_ver_code||'"!');
      assert(NOT l_tgt_ver_nbr = l_cur_ver_nbr, 'INFO: Target version "'||l_tgt_ver_code||'" is already installed (this is not an error)');
      l_nxt_ver_code := t_all(t_all.NEXT(l_cur_ver_nbr));
      dbms_output.put_line('Next version is "'||l_nxt_ver_code||'"');
      assert(a_upg.EXISTS(l_nxt_ver_code), 'ERROR: No script is available to upgrade to version "'||l_nxt_ver_code||'"!');
      dbms_output.put_line('Upgrading to version "'||l_nxt_ver_code||'"...');
      l_nxt_action := 'upgrade';
   END IF;
   l_nxt_ver_nbr := a_all(l_nxt_ver_code);
   l_ext := CASE WHEN l_nxt_ver_nbr >= 240700 THEN 'dbm' ELSE 'sql' END;
   :l_script := 'apps/05_dbm_utility/releases/'||l_nxt_ver_code||'/'||l_nxt_action||'/'||l_nxt_action||'.'||l_ext;
   :l_nxt_ver_code := l_nxt_ver_code;
   :l_action := l_nxt_action;
   :l_nxt_ver_nbr := l_nxt_ver_nbr;
   :l_nxt_ver_code := l_nxt_ver_code;
   :l_nxt_obj_sum := t_obj_sum(l_nxt_ver_nbr);
   :l_nxt_pkg_sum := t_pkg_sum(l_nxt_ver_nbr);
--   dbms_output.put_line('Executing script: '||l_script);
END;
/

set termout off
COLUMN :l_script NEW_VALUE script NOPRINT
select :l_script from sys.dual;
set termout on

PROMPT Executing: @@&&script
@@&&script

DECLARE
   -- Local types
   SUBTYPE l_checksum_type IS NUMBER;
   -- Local variables
   l_obj_sum l_checksum_type;
   l_pkg_sum l_checksum_type;
   -- Local cursors
   -- Get invalid objects
   CURSOR c_obj IS
      SELECT object_type, object_name, status
        FROM user_objects
       WHERE REGEXP_LIKE(object_type||' '||object_name, '^(PACKAGE|PACKAGE BODY) DBM_')
         AND NOT REGEXP_LIKE(object_type||' '||object_name, '^(PACKAGE|PACKAGE BODY) DBM_.*_TST$')
         AND status = 'INVALID'
       ORDER BY CASE WHEN object_type = 'PACKAGE' THEN 1
                     WHEN object_name LIKE '%VAR' THEN 2
                     ELSE 3
                 END
   ;
   -- Local procedures
   -- Raise exception when a condition is not true
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_text IN VARCHAR2
   )
   IS
   BEGIN
      IF NOT p_condition THEN
         raise_application_error(-20000,p_text);
      END IF;
   END;
   -- Get objects and packages checksums
   PROCEDURE get_checksums (
      po_obj_sum OUT NUMBER
    , po_pkg_sum OUT NUMBER
   )
   IS
      k_obj_name_pattern CONSTANT VARCHAR2(100) := '^(PACKAGE BODY|PACKAGE|SEQUENCE|TABLE|VIEW) DBM_';
      k_obj_name_anti_pattern CONSTANT VARCHAR2(100) := '^(PACKAGE BODY|PACKAGE) DBM_.*_TST$';
   BEGIN
      EXECUTE IMMEDIATE q'#
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||con.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('TABLE '||ind.table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('TABLE '||ind.table_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                        AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                        AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
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
                  AND REGEXP_LIKE('SEQUENCE '||sequence_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('SEQUENCE '||sequence_name, :p_object_name_anti_pattern)
                UNION ALL
               -- Specific handling for synonyms
               SELECT obj.object_type||' '||obj.object_name, MOD(sys.dbms_utility.get_hash_value(syn.table_name,1000000000,POWER(2,30)),POWER(2,30)), obj.status
                 FROM all_synonyms syn
                INNER JOIN all_objects obj
                   ON obj.owner = syn.owner
                  AND obj.object_type = 'SYNONYM'
                  AND obj.object_name = syn.synonym_name
                WHERE syn.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
                UNION ALL
               -- Specific handling for public synonyms
               SELECT 'PUBLIC SYNONYM '||synonym_name, MOD(sys.dbms_utility.get_hash_value(table_name,1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
                 FROM all_synonyms
                WHERE owner = 'PUBLIC'
                  AND table_owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('PUBLIC SYNONYM '||synonym_name, :p_object_name_anti_pattern)
                  AND :p_public = 'Y'
                UNION ALL
               -- Specific handling for public grants
               SELECT 'PUBLIC GRANT ON '||table_name, MOD(sys.dbms_utility.get_hash_value(LISTAGG(privilege, ', ') WITHIN GROUP (ORDER BY privilege),1000000000,POWER(2,30)),POWER(2,30)), 'VALID'
                 FROM all_tab_privs
                WHERE grantee = 'PUBLIC'
                  AND grantor = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND table_schema = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND REGEXP_LIKE('PUBLIC GRANT ON '||table_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE('PUBLIC GRANT ON '||table_name, :p_object_name_anti_pattern)
                  AND :p_public = 'Y'
                GROUP BY table_name
                UNION ALL
               -- Specific handling for other objects
               SELECT obj.object_type||' '||obj.object_name, NULL, obj.status
                 FROM all_objects obj
                WHERE obj.owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
                  AND obj.object_type NOT IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER'
                                             ,'INDEX','VIEW','MATERIALIZED VIEW','TABLE','SEQUENCE','SYNONYM', 'JAVA SOURCE')
                  AND REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_pattern)
                  AND NOT REGEXP_LIKE(obj.object_type||' '||obj.object_name, :p_object_name_anti_pattern)
             ) new
      #' INTO po_obj_sum, po_pkg_sum USING 
        k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , 'N'
      , k_obj_name_pattern, k_obj_name_anti_pattern
      , 'N'
      , k_obj_name_pattern, k_obj_name_anti_pattern
      ;
   END;
BEGIN
   -- Recompile invalid objects
   FOR r_obj IN c_obj LOOP
      dbms_output.put_line('Recompiling invalid ' || r_obj.object_type || ' ' || r_obj.object_name || '...');
      EXECUTE IMMEDIATE TRIM('ALTER PACKAGE ' || r_obj.object_name || ' COMPILE ' || TRIM(REPLACE(r_obj.object_type, 'PACKAGE')));
   END LOOP;
   -- Check invalid packages again
   FOR r_obj IN c_obj LOOP
      assert(FALSE, 'ERROR: ' || INITCAP(r_obj.object_type) || ' ' || r_obj.object_name || ' is invalid!');
   END LOOP;
   -- Get checksum of DBM objects and packages
   get_checksums(l_obj_sum, l_pkg_sum);
   dbms_output.put_line('Checksum of actual objects after migration is "'||l_obj_sum||'"');
   dbms_output.put_line('Checksum of actual packages after migration is "'||l_pkg_sum||'"');
   -- Compare to expected checksums
   assert(NVL(l_obj_sum,0) = NVL(:l_nxt_obj_sum,0), 'ERROR: Invalid objects checksum after migration to version "'||:l_nxt_ver_code||'"');
   assert(NVL(l_pkg_sum,0) = NVL(:l_nxt_pkg_sum,0), 'ERROR: Invalid packages checksum after migration to version "'||:l_nxt_ver_code||'"');
   dbms_output.put_line('Migration to version "'||:l_nxt_ver_code||'" ended successfully.');
EXCEPTION
   WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM||CHR(10)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
       dbm_utility_krn.upsert_app(p_app_code=>'dbm_utility', p_ver_status=>'INVALID');
       COMMIT;
       RAISE;
END;
/

BEGIN
   dbm_utility_krn.upsert_app(p_app_code=>'dbm_utility');
   UPDATE dbm_versions SET ver_status = ver_status WHERE app_code = 'dbm_utility' and ver_code = :l_nxt_ver_code;
   IF SQL%NOTFOUND THEN
      INSERT INTO dbm_versions (app_code, ver_code, ver_nbr) VALUES ('dbm_utility', :l_nxt_ver_code, :l_nxt_ver_nbr);
   END IF;
   dbm_utility_krn.update_ver(p_app_code=>'dbm_utility', p_ver_code=>:l_nxt_ver_code, p_last_op_type=>'MIGRATE', p_last_op_status=>'SUCCESS', p_ver_status=>'CURRENT', p_next_op_type=>'');
   dbm_utility_krn.upsert_app(p_app_code=>'dbm_utility', p_ver_code=>:l_nxt_ver_code, p_ver_status=>'VALID');
   dbms_output.put_line('Current version of "dbm_utility" set to "'||:l_nxt_ver_code||'"');
   COMMIT;
END;
/

exit 0