create or replace PACKAGE BODY dpp_inj_krn
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

   SUBTYPE g_long_variable_type  IS VARCHAR2(32000);
   SUBTYPE g_med_variable_type   IS VARCHAR2(1000);
   SUBTYPE g_small_variable_type IS VARCHAR2(5); 

   PROCEDURE trace_p(p_text IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      dpp_itf_krn.log_message(p_type => 'Info', p_text => p_text);
      COMMIT;
   END trace_p;

   PROCEDURE create_procedure(p_schema       IN VARCHAR2
                             ,p_proc_name    IN VARCHAR2
                             ,p_proc_param   IN VARCHAR2 DEFAULT NULL
                             ,p_proc_declare IN VARCHAR2 DEFAULT NULL
                             ,p_proc_body    IN VARCHAR2
                             )
  -- AUTHID DEFINER 
   IS
      --
      l_user   VARCHAR2(50);
      l_schema VARCHAR2(50);
      --
      --  l_allowed PLS_INTEGER;
      --
      l_sql g_long_variable_type;
      --
      l_lfcr CHAR(2);
      --

   BEGIN  --
      l_user := USER;
      l_lfcr := CHR(10) || CHR(13); 
      --      
      l_sql := 'CREATE OR REPLACE PROCEDURE ${user}.${proc_name} ${proc_param} AUTHID DEFINER IS ' ||
                             UTL_TCP.CRLF || '    ${proc_declare} ' ||
                             UTL_TCP.CRLF || 'BEGIN ' || UTL_TCP.CRLF ||
                             '${proc_body}' || UTL_TCP.CRLF || 'END;' ||
                             UTL_TCP.CRLF;
      --
      SELECT MAX(username)
       INTO l_schema
       FROM sys.all_users
      WHERE username = p_schema;
      --
      --
      IF p_schema is NULL THEN
         RAISE_APPLICATION_ERROR(-20001, 'p_schema parameter is NULL.');
      END IF;
      IF l_schema IS NULL THEN
         RAISE_APPLICATION_ERROR(-20001, 'specified shema doesnt exist.');
      END IF;

      IF l_schema IN ('SYS','SYSTEM','CAPSTAT','CTXSYS','DIP','PERFSTAT','OPS$ORACLE','OUTLN','DBSNMP','XDB','TSMSYS')
       OR l_schema LIKE '%RMAN%'
       OR l_schema LIKE 'PATROL%' THEN

         RAISE_APPLICATION_ERROR(-20001, 'This schema is forbidden schema to use for source injecttion.');
      END IF;

      IF p_proc_name IS NULL THEN
         RAISE_APPLICATION_ERROR(-20001, 'p_proc_name parameter is NULL.');
      END IF;

      IF p_proc_body IS NULL THEN
         RAISE_APPLICATION_ERROR(-20001, 'p_proc_body parameter is NULL.');
      END IF;
      --
      -- Is user allowed to create proc_name in said schema;
      --
      l_sql := REPLACE(l_sql, '${user}', l_schema);
      l_sql := REPLACE(l_sql, '${proc_name}', p_proc_name);
      --
      IF p_proc_param is NULL THEN
         l_sql := REPLACE(l_sql, '${proc_param}', ' ');
      ELSE
         l_sql := REPLACE(l_sql, '${proc_param}', '(' || p_proc_param || ')');
      END IF;
      --
      l_sql := REPLACE(l_sql, '${proc_declare}', p_proc_declare);
      --
      l_sql := REPLACE(l_sql, '${proc_body}', p_proc_body);
      -- create procedure
      l_sql := TRANSLATE(l_sql, l_lfcr, '  ');

      BEGIN
         EXECUTE IMMEDIATE l_sql;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(l_sql);
            trace_p(l_sql);
      END;

      -- DONE
      BEGIN
         l_sql := 'GRANT EXECUTE ON ' || l_schema || '.' || p_proc_name || ' TO ' ||
                 l_user;
         l_sql := TRANSLATE(l_sql, l_lfcr, '  ');
         EXECUTE IMMEDIATE l_sql;
      EXCEPTION
         WHEN OTHERS THEN -- will fail when routine installed in APP_DPP (AWS case)
            --NULL;
            trace_p(l_sql);
      END;
      -- DONE
   END create_procedure;

   PROCEDURE drop_object(p_schema      IN VARCHAR2
                        ,p_object_name IN VARCHAR2
                        ,p_object_type IN VARCHAR2
                        )
     --AUTHID DEFINER 
   IS

     TYPE lt_hash_table_type IS TABLE of NUMBER INDEX BY VARCHAR2(19);

     l_user        g_med_variable_type;
     l_schema      g_med_variable_type;
     l_object_name g_med_variable_type;
     lt_hash       lt_hash_table_type;
     l_sql         g_long_variable_type;
    -- l_allowed     PLS_INTEGER;
     l_table_name  g_med_variable_type;
     --

     --
     PRAGMA AUTONOMOUS_TRANSACTION;
     --
   BEGIN
     lt_hash('CONTEXT') := 1;
     lt_hash('INDEX') := 1;
     lt_hash('JOB CLASS') := 1;
     lt_hash('INDEXTYPE') := 1;
     lt_hash('PROCEDURE') := 1;
     lt_hash('JAVA CLASS') := 1;
     lt_hash('JAVA RESOURCE') := 1;
     lt_hash('SCHEDULE') := 1;
     lt_hash('WINDOW') := 1;
     lt_hash('WINDOW GROUP') := 1;
     lt_hash('TABLE') := 1;
     lt_hash('VIEW') := 1;
     lt_hash('TYPE') := 1;
     lt_hash('FUNCTION') := 1;
     lt_hash('LIBRARY') := 1;
     lt_hash('TRIGGER') := 1;
     lt_hash('SYNONYM') := 1;
     lt_hash('CONSUMER GROUP') := 1;
     lt_hash('EVALUATION CONTEXT') := 1;
     lt_hash('OPERATOR') := 1;
     lt_hash('PACKAGE') := 1;
     lt_hash('SEQUENCE') := 1;
     lt_hash('LOB') := 1;
     lt_hash('XML SCHEMA') := 1;
     lt_hash('CONSTRAINT') := 1;
     lt_hash('CREATE PROCEDURE') := 1;
     l_object_name := TRIM(UPPER(p_object_name));
     l_user := USER;
     SELECT MAX(A.USERNAME)
       INTO l_schema
       FROM sys.all_users A
      WHERE A.USERNAME = upper(trim(p_schema));

     IF p_schema is NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_schema parameter is NULL.');
     END IF;
     IF l_schema IS NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'Schema ' || l_schema || ' doesnt exist.');
     END IF;

     IF p_object_type IS NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_object_type is not specified.');
     END IF;

     IF NOT lt_hash.EXISTS(upper(trim(p_object_type))) THEN
       RAISE_APPLICATION_ERROR(-20001, 'Cannot drop ' || upper(trim(p_object_type)) || ' type.');
     END IF;

     IF l_object_name IS NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_object_name not specified.');
     END IF;
     l_sql := NULL;
     --
     IF upper(trim(p_object_type)) = 'INDEX' THEN
       l_sql := 'DROP INDEX ' || p_schema || '.' || p_object_name;
     END IF;
     --
     IF upper(trim(p_object_type)) = 'TABLE' THEN
       l_sql := 'DROP TABLE ' || p_schema || '.' || p_object_name;
     END IF;
     --
     IF upper(trim(p_object_type)) = 'PROCEDURE' THEN
       l_sql := 'DROP PROCEDURE ' || p_schema || '.' || p_object_name;
     END IF;
     --
     IF upper(trim(p_object_type)) = 'FUNCTION' THEN
       l_sql := 'DROP FUNCTION ' || p_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'TYPE' THEN
       l_sql := 'DROP TYPE ' || p_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'CONSTRAINT' THEN
       -- fetch constraint name, must belong to target schema
       SELECT MAX(TABLE_NAME)
         into l_table_name
         FROM sys.ALL_CONSTRAINTS A
        WHERE A.OWNER = l_schema
          AND A.CONSTRAINT_NAME = upper(trim(p_object_name));
       IF l_table_name IS NULL THEN
         RAISE_APPLICATION_ERROR(-20001,
                                 'Constraint doesnt exist in this schema.');
       END IF;
       l_sql := 'ALTER TABLE ' || l_schema || '.' || l_table_name || '  DROP ' ||
                p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'SYNONYM' THEN
       l_sql := 'DROP SYNONYM ' || l_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'SEQUENCE' THEN
       l_sql := 'DROP SEQUENCE ' || l_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'PACKAGE' THEN
       l_sql := 'DROP PACKAGE ' || l_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'TRIGGER' THEN
       l_sql := 'DROP TRIGGER ' || l_schema || '.' || p_object_name;
     END IF;

     IF upper(trim(p_object_type)) = 'VIEW' THEN
       l_sql := 'DROP VIEW ' || l_schema || '.' || p_object_name;
     END IF;
     --
     IF l_sql IS NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'Cannot drop this object type.');
     END IF;
     --
     EXECUTE IMMEDIATE l_sql;
     --
   END drop_object;

   PROCEDURE flush_hash_table
   IS
   BEGIN
      dpp_inj_var.gt_hash_table.DELETE; 
   END flush_hash_table;

   PROCEDURE inj_recomp_inv_obj(p_target_schema IN VARCHAR2) 
   IS

      l_param g_med_variable_type := ' o_owner  IN VARCHAR2, ' ||
                               ' o_name   IN VARCHAR2 := ''%'', ' ||
                               ' o_type   IN VARCHAR2 := ''%'', ' ||
                               ' o_status IN VARCHAR2 := ''INVALID'' ';

      l_declare g_long_variable_type :=' success_with_error EXCEPTION; ' ||
                                 ' PRAGMA EXCEPTION_INIT(success_with_error, -24344); ' ||
                                 '  invalid_type   CONSTANT INTEGER := 1; ' ||
                                 '  invalid_parent CONSTANT INTEGER := 2; ' ||
                                 '  compile_errors CONSTANT INTEGER := 4; ' ||
                                 '  cnt              NUMBER; ' ||
                                 '  dyncur           INTEGER; ' ||
                                 '  type_status      INTEGER := 0; ' ||
                                 '  parent_status    INTEGER := 0; ' ||
                                 '  recompile_status INTEGER := 0; ' ||
                                 '  object_status    VARCHAR2(30); ' ||
                                 '  CURSOR inv_p_curs(oowner VARCHAR2, oname VARCHAR2, otype VARCHAR2, ostatus VARCHAR2, OID NUMBER) IS ' ||
                                 '    SELECT /*+ RULE */ ' ||
                                 '     o.object_id ' ||
                                 '      FROM sys.public_dependency d, all_objects o ' ||
                                 '     WHERE d.object_id = OID ' ||
                                 '       AND o.object_id = d.referenced_object_id ' ||
                                 '       AND o.status != ''VALID''  ' ||
                                 '    MINUS ' || '    SELECT /*+ RULE */  ' ||
                                 '     object_id ' ||
                                 '      FROM all_objects  ' ||
                                 '     WHERE owner LIKE UPPER(oowner) ' ||
                                 '       AND object_name LIKE UPPER(oname) ' ||
                                 '       AND object_type LIKE UPPER(otype) ' ||
                                 '       AND status LIKE UPPER(ostatus); ' ||
                                 '  CURSOR recompile_cursor(OID NUMBER) IS ' ||
                                 '    SELECT /*+ RULE */ ' ||
                                 '     ''ALTER '' || DECODE(object_type, ' ||
                                 '     ''PACKAGE BODY'', ' ||
                                 '     ''PACKAGE'', ' ||
                                 '      ''TYPE BODY'',' ||
                                 '      ''TYPE'', ' ||
                                 '  object_type) || '' '' || owner || ''.'' || object_name || ' ||
                                 '    '' COMPILE '' || DECODE(object_type, ' ||
                                 '    ''PACKAGE BODY'', ' ||
                                 '    '' BODY'',' || '    ''TYPE BODY'',' ||
                                 '    ''BODY'',' || '    ''TYPE'',' ||
                                 '    ''SPECIFICATION'',' ||
                                 '    '''' ) stmt,' ||
                                 '  object_type,  owner,  object_name  FROM all_objects WHERE object_id = OID; ' ||
                                 '    recompile_record recompile_cursor%ROWTYPE; ' ||
                                 '  CURSOR obj_cursor(oowner VARCHAR2, oname VARCHAR2, otype VARCHAR2, ostatus VARCHAR2) IS ' ||
                                 '    SELECT /*+ RULE */ ' ||
                                 '    MAX(LEVEL) dlevel, object_id ' ||
                                 '      FROM sys.public_dependency ' ||
                                 '     START WITH object_id IN ' ||
                                 '                (SELECT object_id ' ||
                                 '                   FROM all_objects ' ||
                                 '                  WHERE owner LIKE UPPER(oowner) ' ||
                                 '                    AND object_name LIKE UPPER(oname) ' ||
                                 '                 AND object_type LIKE UPPER(otype) ' ||
                                 '                AND status LIKE UPPER(ostatus)) ' ||
                                 '    CONNECT BY object_id = PRIOR referenced_object_id ' ||
                                 '     GROUP BY object_id ' ||
                                 '   HAVING MIN(LEVEL) = 1 ' ||
                                 '    UNION ALL ' ||
                                 '    SELECT 1 dlevel, object_id ' ||
                                 '      FROM all_objects o ' ||
                                 '    WHERE owner LIKE UPPER(oowner) ' ||
                                 '       AND object_name LIKE UPPER(oname) ' ||
                                 '      AND object_type LIKE UPPER(otype) ' ||
                                 '       AND status LIKE UPPER(ostatus) ' ||
                                 '       AND NOT EXISTS (SELECT 1 ' ||
                                 ' FROM public_dependency d ' ||
                                 '    WHERE d.object_id = o.object_id) ' ||
                                 '   ORDER BY 1 DESC; ' ||
                                 '   CURSOR status_cursor(OID NUMBER) IS ' ||
                                 '    SELECT /*+ RULE */ ' || '     status ' ||
                                 '      FROM all_objects ' ||
                                 '     WHERE object_id = OID; ';
      l_body   g_long_variable_type := '  dyncur := DBMS_SQL.open_cursor; ' ||
                                 '   FOR obj_record IN obj_cursor(o_owner, o_name, o_type, o_status) LOOP ' ||
                                 '    OPEN recompile_cursor(obj_record.object_id); ' ||
                                 '   FETCH recompile_cursor ' ||
                                 '      INTO recompile_record; ' ||
                                 '   CLOSE recompile_cursor; ' ||
                                 '     IF recompile_record.object_type IN ' ||
                                 '     (''FUNCTION'', ''PACKAGE'', ''PACKAGE BODY'', ''PROCEDURE'', ''TRIGGER'',' ||
                                 '        ''VIEW'', ''TYPE'', ''TYPE BODY'') THEN ' ||
                                 '      OPEN inv_p_curs(o_owner,  o_name, o_type, o_status,  obj_record.object_id);' ||
                                 '   FETCH inv_p_curs ' || '    INTO cnt; ' ||
                                 '   IF inv_p_curs%NOTFOUND THEN ' ||
                                 '     BEGIN ' ||
                                 '      DBMS_SQL.parse(dyncur, recompile_record.stmt, DBMS_SQL.native); ' ||
                                 '     EXCEPTION ' ||
                                 '       WHEN success_with_error THEN ' ||
                                 '        NULL; ' || '    END; ' ||
                                 '    OPEN status_cursor(obj_record.object_id); ' ||
                                 '        FETCH status_cursor ' ||
                                 '      INTO object_status; ' ||
                                 '    CLOSE status_cursor; ' ||
                                 '    IF object_status <> ''VALID'' THEN ' ||
                                 '      recompile_status := compile_errors; ' ||
                                 '        END IF; ' || '      ELSE ' ||
                                 '        parent_status := invalid_parent; ' ||
                                 '      END IF; ' ||
                                 '     CLOSE inv_p_curs; ' || '    ELSE ' ||
                                 '      type_status := invalid_type; ' ||
                                 '  END IF; ' || '  END LOOP; ' ||
                                 '  DBMS_SQL.close_cursor(dyncur); ' ||
                                 ' EXCEPTION ' || '  WHEN OTHERS THEN ' ||
                                 '    IF obj_cursor%ISOPEN THEN ' ||
                                 '      CLOSE obj_cursor; ' ||
                                 '    END IF; ' ||
                                 '    IF recompile_cursor%ISOPEN THEN ' ||
                                 '      CLOSE recompile_cursor; ' ||
                                 '    END IF; ' ||
                                 '    IF inv_p_curs%ISOPEN THEN ' ||
                                 '      CLOSE inv_p_curs; ' ||
                                 '    END IF; ' ||
                                 '    IF status_cursor%ISOPEN THEN ' ||
                                 '      CLOSE status_cursor; ' ||
                                 '    END IF; ' ||
                                 '    IF DBMS_SQL.is_open(dyncur) THEN ' ||
                                 '      DBMS_SQL.close_cursor(dyncur); ' ||
                                 '    END IF; ' || '     RAISE; ';
   BEGIN
      create_procedure(p_schema       => p_target_schema
                      ,p_proc_name    => 'dpump_recomp_inv_obj'
                      ,p_proc_param   => l_param
                      ,p_proc_declare => l_declare
                      ,p_proc_body    => l_body
                      );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE dpp_job_var.ge_injection_failed;  
   END inj_recomp_inv_obj;

   PROCEDURE inj_drop_recomp_inv_obj(p_target_schema IN VARCHAR2) 
   IS
   BEGIN
      drop_object(p_schema      => p_target_schema
                 ,p_object_type => 'PROCEDURE'
                 ,p_object_name => 'dpump_recomp_inv_obj'
                 );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_recomp_inv_obj;

   PROCEDURE inj_drop_triggers(p_target_schema IN VARCHAR2,
                              p_list          IN VARCHAR2) 
   IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(1000); ';
    l_body    g_long_variable_type := 'FOR IREC IN (SELECT TRIGGER_NAME FROM USER_TRIGGERS WHERE TRIGGER_NAME NOT IN (${LIST})) LOOP ' ||
                                '   l_sql := ''DROP TRIGGER "'' || IREC.TRIGGER_NAME || ''"''; ' ||
                                '     EXECUTE IMMEDIATE l_sql; ' ||
                                ' END LOOP; ';
   BEGIN
    l_body := REPLACE(l_body, '${LIST}', p_list);

    create_procedure(p_schema       => p_target_schema
                    ,p_proc_name    => 'dpump_drop_triggers'
                    ,p_proc_param   => NULL
                    ,p_proc_declare => l_declare
                    ,p_proc_body    => l_body
                    );
   EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_triggers;

  PROCEDURE inj_drop_drop_triggers(p_target_schema IN VARCHAR2) IS
  BEGIN
     drop_object(p_schema      => p_target_schema
                ,p_object_type => 'PROCEDURE'
                ,p_object_name => 'dpump_drop_triggers'
                );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_triggers;

  PROCEDURE inj_drop_indexes(p_target_schema IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(1000); ';
    l_body    g_long_variable_type := ' FOR IREC IN (SELECT * FROM USER_INDEXES A ) LOOP ' || -- In SP2 version there was a where clause to exclude some !
                                '    l_sql := ''DROP INDEX '' || IREC.INDEX_NAME; ' ||
                                '    BEGIN ' ||
                                '      EXECUTE IMMEDIATE l_sql; ' ||
                                '    EXCEPTION ' ||
                                '      WHEN OTHERS THEN ' ||
                                '        NULL; ' || '    END; ' ||
                                '  END LOOP; ';
  BEGIN
     create_procedure(p_schema       => p_target_schema
                     ,p_proc_name    => 'dpump_drop_indexes'
                     ,p_proc_param   => NULL
                     ,p_proc_declare => l_declare
                     ,p_proc_body    => l_body
                     );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_indexes;

  PROCEDURE inj_drop_drop_indexes(p_target_schema IN VARCHAR2) IS
  BEGIN
     drop_object(p_schema      => p_target_schema
                ,p_object_type => 'PROCEDURE'
                ,p_object_name => 'dpump_drop_indexes'
                );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_indexes;

  PROCEDURE inj_drop_trunc_table(p_target_schema IN VARCHAR2) IS
  BEGIN
     drop_object(p_schema      => p_target_schema
                ,p_object_type => 'PROCEDURE'
                ,p_object_name => 'dpump_trunc_table'
                );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_trunc_table;

  PROCEDURE inj_trunc_table(p_target_schema IN VARCHAR2) IS
    l_body g_long_variable_type := 'FOR IREC IN (select * FROM user_tables) LOOP ' ||   -- in SP2 version there was a filter to skip some SP2_DWH tables
                             '   BEGIN ' ||
                             '     DBMS_APPLICATION_INFO.SET_MODULE(''IMP:TRUNC TABLE'',' ||
                             '    ''TRUNC '' || IREC.TABLE_NAME); ' ||
                             '     EXECUTE IMMEDIATE ''TRUNCATE TABLE "'' || IREC.TABLE_NAME || ''" REUSE STORAGE''; ' ||
                             '   EXCEPTION ' || '      WHEN OTHERS THEN ' ||
                             '        NULL;  ' || 
                             '   END;  ' ||
                             'END LOOP; ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_trunc_table',
                                p_proc_param   => NULL,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_trunc_table;

  PROCEDURE inj_drop_drop_recyclebin(p_target_schema IN VARCHAR2) IS
  BEGIN
     drop_object(p_schema      => p_target_schema
                ,p_object_type => 'PROCEDURE'
                ,p_object_name => 'dpump_purge_recyclebin'
                );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_recyclebin;

  PROCEDURE inj_drop_purge_recyclebin(p_target_schema IN VARCHAR2) IS
    l_body g_med_variable_type := 'EXECUTE IMMEDIATE ''PURGE RECYCLEBIN''; ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_purge_recyclebin',
                                p_proc_param   => NULL,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_purge_recyclebin;

  PROCEDURE inj_drop_drop_types(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_types');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_types;

   PROCEDURE inj_drop_types(p_target_schema IN VARCHAR2, p_list IN VARCHAR2) IS
      l_body g_long_variable_type := 'FOR IREC IN (SELECT * FROM USER_TYPES A ' ||
                               '   ORDER BY CASE  WHEN A.typecode = ''COLLECTION'' THEN ' ||
                               ' 1 ELSE 2 END) LOOP ' ||
                               '   IF IREC.TYPE_NAME NOT IN (${LIST}) THEN ' ||
                               '     EXECUTE IMMEDIATE ''DROP TYPE "'' || IREC.TYPE_NAME || ''"''; ' ||
                               '   END IF; ' || ' END LOOP; ';
   BEGIN
      l_body := REPLACE(l_body, '${LIST}', p_list);
      create_procedure(p_schema       => p_target_schema
                      ,p_proc_name    => 'dpump_drop_types'
                      ,p_proc_param   => NULL
                      ,p_proc_declare => NULL
                      ,p_proc_body    => l_body
                      );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_types;

  PROCEDURE inj_kill_sessions(p_target_schema IN VARCHAR2) IS
    l_declare g_long_variable_type := 'kill_current_session exception ;
                                 pragma exception_init (kill_current_session,-27) ;
                                ';
    l_body g_long_variable_type := ' FOR IREC IN (SELECT SID, SERIAL# SERID ' ||
                             '    FROM sys.V_$SESSION  ' ||
                             '   WHERE USERNAME = '''||p_target_schema||''') LOOP  ' ||
                             '   begin ' ||
                             '     sys.kill_session(IREC.SID, IREC.SERID); ' ||
                             '   exception '||
                             '   when kill_current_session then'  ||   -- trap ORA-00027 : cannot kill current session
                             '      null ;  ' ||
                             '   end ; ' ||
                             ' END LOOP;';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_kill_sessions',
                                p_proc_param   => NULL,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_kill_sessions;

  PROCEDURE inj_drop_kill_sessions(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_kill_sessions');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_kill_sessions;

  PROCEDURE inj_drop_view(p_target_schema IN VARCHAR2, p_list IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(1000); TYPE t_view_list IS TABLE OF VARCHAR2(30); l_view_list t_view_list; ';
    l_body    g_long_variable_type := '  FOR IREC IN (SELECT A.VIEW_NAME FROM USER_VIEWS A ' ||
                                 '    WHERE NOT NVL(A.VIEW_NAME, ''NULL'') IN (${LIST})) LOOP ' ||
                                 '      l_sql := ''DROP VIEW '' || IREC.VIEW_NAME; ' ||
                                 '      EXECUTE IMMEDIATE l_sql; ' ||
                                 ' END LOOP; ';
    l_body2   g_long_variable_type := ' SELECT VIEW_NAME BULK COLLECT INTO l_view_list FROM USER_VIEWS A ' ||
                                 '  WHERE NOT NVL(A.VIEW_NAME, ''NULL'') IN (${LIST}); ' ||
                                 '     IF l_view_list.FIRST IS NULL THEN ' ||
                                 '  RETURN; ' || '  END IF; ' ||
                                 '   FOR I IN l_view_list.FIRST .. l_view_list.LAST LOOP ' ||
                                 '    l_sql := ''DROP VIEW '' || l_view_list(I); ' ||
                                 '       EXECUTE IMMEDIATE l_sql; ' ||
                                 '   END LOOP; ';
  BEGIN
    l_body2 := REPLACE(l_body2, '${LIST}', p_list);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_all_views',
                                p_proc_param   => NULL,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body2);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_view;

  PROCEDURE inj_drop_drop_view(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_all_views');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_view;

  PROCEDURE inj_drop_source(p_target_schema IN VARCHAR2,
                            p_list          IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(1000); ';

    l_body g_long_variable_type := '  FOR IREC IN (SELECT DISTINCT NAME, TYPE ' ||
                             '   FROM USER_SOURCE A ' ||
                             '    WHERE TYPE != ''TYPE'' AND NOT (TYPE || '':'' || NAME IN  ' ||
                             '     (${LIST}))) LOOP ' ||
                             ' l_sql := ''DROP '' || IREC.TYPE || '' '' || IREC.NAME; ' ||
                             '    BEGIN ' ||
                             '    EXECUTE IMMEDIATE l_sql; ' ||
                             '     EXCEPTION ' || '    WHEN OTHERS THEN ' ||
                             '     NULL; ' || '    END; ' || '  END LOOP; ';

  BEGIN
    l_body := REPLACE(l_body, '${LIST}', p_list);
    create_procedure(p_schema       => p_target_schema
                   , p_proc_name    => 'dpump_drop_all_source'
                   , p_proc_param   => NULL
                   , p_proc_declare => l_declare
                   , p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_source;

  PROCEDURE inj_drop_drop_source(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_all_source');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_source;

  PROCEDURE inj_drop_sequence(p_target_schema IN VARCHAR2,
                              p_list          IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(500); ';
    l_body    g_long_variable_type := ' FOR IREC IN (SELECT SEQUENCE_NAME ' ||
                                '               FROM USER_SEQUENCES A ' ||
                                ' WHERE NOT SEQUENCE_NAME IN (${LIST})) LOOP ' ||
                                '  l_sql := ''DROP SEQUENCE "'' || IREC.SEQUENCE_NAME || ''"''; ' ||
                                '  EXECUTE IMMEDIATE l_sql; ' ||
                                '  END LOOP; ';
    --
  BEGIN
    l_body := REPLACE(l_body, '${LIST}', p_list);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_sequences',
                                p_proc_param   => NULL,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_sequence;

  PROCEDURE inj_drop_drop_sequence(p_target_schema IN VARCHAR2) IS
  BEGIN
     drop_object(p_schema      => p_target_schema
                ,p_object_type => 'PROCEDURE'
                ,p_object_name => 'dpump_drop_sequences'
                );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_sequence;

  PROCEDURE inj_drop_synonym(p_target_schema IN VARCHAR2,
                             p_list          IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_synonym VARCHAR2(100); l_cnt NUMBER; ';
    l_body    g_long_variable_type := ' FOR IREC IN (select * ' ||
                                '                 FROM user_synonyms A ' ||
                                '                WHERE NOT A.SYNONYM_NAME IN (${LIST})) LOOP ' ||
                                '    l_synonym := IREC.SYNONYM_NAME; ' ||
                                '     BEGIN ' ||
                                '      EXECUTE IMMEDIATE ''DROP SYNONYM "'' || l_synonym || ''"'';' ||
                                '    EXCEPTION  WHEN OTHERS THEN   NULL; ' ||
                                '    END; ' || '  END LOOP; ';
    --
  BEGIN
    l_body := REPLACE(l_body, '${LIST}', p_list);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_synonym',
                                p_proc_param   => NULL,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_synonym;

  PROCEDURE inj_drop_drop_synonym(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_synonym');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_synonym;

  PROCEDURE inj_drop_table(p_target_schema IN VARCHAR2, p_list IN VARCHAR2) IS
    l_declare g_med_variable_type := ' v_table VARCHAR2(100); ';
    l_list    g_long_variable_type;
    l_body    g_long_variable_type := ' FOR IREC IN (SELECT A.TABLE_NAME  FROM USER_TABLES A ' ||
                                '  WHERE NOT NVL(A.TABLE_NAME, ''NULL'') IN (${LIST})) LOOP ' ||
                                '  v_table := IREC.TABLE_NAME; ' ||
                                '    BEGIN ' ||
                                '  DBMS_APPLICATION_INFO.SET_MODULE ( ''IMP:DROP TABLE'',''DROP ''||v_table);  ' ||
                                '      EXECUTE IMMEDIATE ''DROP TABLE "'' || IREC.TABLE_NAME || ''"''; ' ||
                                '    EXCEPTION ' || '    WHEN OTHERS THEN ' ||
                                '        NULL; ' || '    END; ' ||
                                '  END LOOP; ';
    l_body2   g_long_variable_type := ' p_rc := 0; ' || ' p_table_name := NULL; ' ||
                                '  FOR IREC IN (SELECT A.TABLE_NAME ' ||
                                '                 FROM USER_TABLES A ' ||
                                '                 LEFT OUTER JOIN USER_MVIEWS UM '||
                                '                   ON A.TABLE_NAME = UM.MVIEW_NAME '||    
                                '                WHERE NOT NVL(A.TABLE_NAME, ''NULL'') IN (${LIST}) '||
                                '                  AND A.TABLE_NAME NOT LIKE ''MLOG$%'' '||
                                '                  AND UM.MVIEW_NAME IS NULL '||
                                '                  AND A.IOT_NAME IS NULL '||
                                '              )'||
                                '  LOOP ' ||
                                '  v_table := IREC.TABLE_NAME; ' ||
                                '  BEGIN ' ||
                                '    DBMS_APPLICATION_INFO.SET_MODULE(''IMP:DROP TABLE'',''DROP '' || v_table); ' ||
                                '    EXECUTE IMMEDIATE ''DROP TABLE "'' || v_table || ''"''; ' ||
                                '  EXCEPTION ' || '    WHEN OTHERS THEN ' ||
                                '        p_rc := SQLCODE;' ||
                                '        p_error_text := DBMS_UTILITY.format_error_backtrace;' ||
                                '      p_rc := CASE ABS(p_rc) WHEN 942 THEN 0 ELSE p_rc END;  ' ||
                                '      IF p_rc <> 0 THEN ' ||
                                '        p_table_name := v_table; ' ||
                                '        EXIT; ' || '      END IF;  ' ||
                                '  END; ' || ' END LOOP; ';

  BEGIN
    l_list := upper(TRIM(p_list));
    IF l_list IS NULL THEN
      l_list := ' '' '' ';
    END IF;
    l_body2 := REPLACE(l_body2, '${LIST}', p_list);
    l_body2 := REGEXP_REPLACE(l_body2, '[ ]+', ' ');
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_table',
                                p_proc_param   => 'p_rc OUT NUMBER,p_table_name OUT VARCHAR2,p_error_text OUT VARCHAR2',
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body2);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_table;

  PROCEDURE inj_drop_drop_table(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_table');
  END inj_drop_drop_table;

  PROCEDURE inj_drop_mv(p_target_schema IN VARCHAR2, p_list IN VARCHAR2) IS
    l_declare g_med_variable_type := ' v_table VARCHAR2(100); ';
    l_list    g_long_variable_type;
    l_body    g_long_variable_type := ' FOR IREC IN (SELECT A.TABLE_NAME  FROM USER_SNAPSHOTS A ' ||
                                '  WHERE NOT NVL(A.TABLE_NAME, ''NULL'') IN (${LIST})) LOOP ' ||
                                '  v_table := IREC.TABLE_NAME; ' ||
                                '    BEGIN ' ||
                                '  DBMS_APPLICATION_INFO.SET_MODULE ( ''IMP:DROP MATERIALIZED VIEW'',''DROP ''||v_table);  ' ||
                                '      EXECUTE IMMEDIATE ''DROP MATERIALIZED VIEW "'' || IREC.TABLE_NAME || ''"''; ' ||
                                '    EXCEPTION ' || '    WHEN OTHERS THEN ' ||
                                '        NULL; ' || '    END; ' ||
                                '  END LOOP; ';
    l_body2   g_long_variable_type := ' p_rc := 0; ' || ' p_table_name := NULL; ' ||
                                '  FOR IREC IN (SELECT A.TABLE_NAME ' ||
                                '                 FROM USER_SNAPSHOTS A ' ||
                                '  WHERE NOT NVL(A.TABLE_NAME, ''NULL'') IN (${LIST})) LOOP ' ||
                                '  v_table := IREC.TABLE_NAME; ' ||
                                '  BEGIN ' ||
                                '    DBMS_APPLICATION_INFO.SET_MODULE(''IMP:DROP MATERIALIZED VIEW'',''DROP '' || v_table); ' ||
                                '    EXECUTE IMMEDIATE ''DROP MATERIALIZED VIEW "'' || v_table || ''"''; ' ||
                                '  EXCEPTION ' || '    WHEN OTHERS THEN ' ||
                                '        p_rc := SQLCODE;' ||
                                '        p_error_text := DBMS_UTILITY.format_error_backtrace;' ||
                                '      p_rc := CASE ABS(p_rc) WHEN 942 THEN 0 ELSE p_rc END;  ' ||
                                '      IF p_rc <> 0 THEN ' ||
                                '        p_table_name := v_table; ' ||
                                '        EXIT; ' || '      END IF;  ' ||
                                '  END; ' || ' END LOOP; ';

  BEGIN
    l_list := upper(TRIM(p_list));
    IF l_list IS NULL THEN
      l_list := ' '' '' ';
    END IF;
    l_body2 := REPLACE(l_body2, '${LIST}', p_list);
    l_body2 := REGEXP_REPLACE(l_body2, '[ ]+', ' ');
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_mv',
                                p_proc_param   => 'p_rc OUT NUMBER,p_table_name OUT VARCHAR2,p_error_text OUT VARCHAR2',
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body2);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_mv;

  PROCEDURE inj_drop_drop_mv(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_mv');
  END inj_drop_drop_mv;

  PROCEDURE inj_drop_ref_constraint(p_target_schema IN VARCHAR2,
                                    p_list          IN VARCHAR2) IS
    l_body g_long_variable_type := '  FOR IREC IN (select t.table_name, t.constraint_name ' ||
                             '              from user_constraints t WHERE NOT t.table_name IN (${LIST}) ' ||
                             ' and  t.constraint_type = ''R'' ) LOOP ' ||
                             '   EXECUTE IMMEDIATE ''ALTER TABLE '' || IREC.TABLE_NAME || ' ||
                             '                      '' DROP CONSTRAINT '' || IREC.CONSTRAINT_NAME; ' ||
                             '               ' || '  END LOOP; ';
  BEGIN
    l_body := REPLACE(l_body, '${LIST}', p_list);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_constraints',
                                p_proc_param   => NULL,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_ref_constraint;

  PROCEDURE inj_drop_drop_ref_constraint(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_constraints');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_ref_constraint;
  --
  PROCEDURE inj_drop_conf_metadata_filter(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_cfg_metadata_filter');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_conf_metadata_filter;

  PROCEDURE inj_drop_imp_metalink_429846_1(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_cfg_metalink429846_1');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_imp_metalink_429846_1;

  PROCEDURE inj_imp_metalink_429846_1(p_target_schema IN VARCHAR2) IS
    l_exclusion_snippet g_long_variable_type := '   DBMS_DATAPUMP.metadata_filter(p_job_number, ' ||
                                           '                                 ''EXCLUDE_PATH_LIST'', ${EXCLUDE_LIST} ); ';

    TYPE lt_exclusion_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
    lt_exclusionlist  lt_exclusion_type;
    l_exclusion_item g_med_variable_type;
    l_encl           CHAR(1) := '''';
    l_encl_double    CHAR(2) := l_encl || l_encl;
    l_par2           g_long_variable_type;
  BEGIN
    --lt_exclusionlist := lt_exclusionlist();
    lt_exclusionlist(1) := 'STATISTICS';
    --lt_exclusionlist(2) := 'SCHEMA_EXPORT/PACKAGE/COMPILE_PACKAGE/PACKAGE_SPEC/ALTER_PACKAGE_SPEC';
    --lt_exclusionlist(3) := 'SCHEMA_EXPORT/FUNCTION/ALTER_FUNCTION';
    -- lt_exclusionlist(4) := 'SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE';

    IF NOT (lt_exclusionlist IS NULL OR lt_exclusionlist.FIRST IS NULL) THEN
      FOR I IN lt_exclusionlist.FIRST .. lt_exclusionlist.LAST LOOP
        l_exclusion_item := lt_exclusionlist(I);
        IF I = lt_exclusionlist.FIRST THEN
          l_par2 := l_encl;
        END IF;

        l_par2 := l_par2 || l_encl_double || l_exclusion_item ||
                  l_encl_double;

        IF I <> lt_exclusionlist.LAST THEN
          l_par2 := l_par2 || ',';
        END IF;
        IF I = lt_exclusionlist.LAST THEN
          l_par2 := l_par2 || l_encl;
        END IF;
      END LOOP;
      l_exclusion_snippet := REPLACE(l_exclusion_snippet,
                                     '${EXCLUDE_LIST}',
                                     l_par2);

    END IF;

       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_cfg_metalink429846_1',
                                p_proc_param   => 'p_job_number IN NUMBER',
                                p_proc_declare => NULL,
                                p_proc_body    => l_exclusion_snippet);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_imp_metalink_429846_1;

  -- used by export to exclude some tables, procedures...based on patterns
   PROCEDURE inj_conf_metadata_filter(p_sma_id        IN dpp_schemas.sma_id%TYPE
                                     ,p_target_schema IN VARCHAR2
                                     ,p_exclusionlist IN dpp_inj_var.gt_list_type
                                     )
   IS
      CURSOR c_stn(p_sma_id dpp_schemas.sma_id%TYPE)
          IS
      SELECT *
        FROM dpp_schema_options stn
       WHERE stn.otn_name = 'METADATA_FILTER'
         AND stn.sma_id = p_sma_id
           ;                                    
      --
      l_pattern_tab1 g_med_variable_type := ' '' NOT LIKE ''''DPUMP_%'''' '' '; -- object generated by the DPP Utility
      l_pattern_tab2 g_med_variable_type := ' '' NOT IN (SELECT NAME FROM sys.OBJ$ WHERE TYPE# IN (47,48,66,67,68,69,71,72,74))'''; -- exclude jobs created by dbms_scheduler

      l_encl              CHAR(1) := '''';
      l_encl_double       CHAR(2) := l_encl || l_encl;
      l_par2              g_long_variable_type := l_encl || l_encl_double ||
                                           'DB_LINK' || l_encl_double || ',' ||
                                           l_encl_double || 'JOB' ||
                                           l_encl_double || ',' ||
                                           l_encl_double || 'GRANT' ||
                                           l_encl_double || l_encl;
      l_body               g_long_variable_type :=
                                           '   DBMS_DATAPUMP.metadata_filter(handle => p_job_number, ' ||
                                           '                                 name   => ''NAME_EXPR'',' ||
                                           '                                 value  => ${pattern1}, '  ||
                                           '                            object_type => ''TABLE''); '   ||
                                           '   DBMS_DATAPUMP.metadata_filter(handle => p_job_number, ' ||
                                           '                                  name => ''NAME_EXPR'','  ||
                                           '                                  value => ${pattern1}, '  ||
                                           '                            object_type => ''PROCEDURE''); ' ||
                                           '   DBMS_DATAPUMP.metadata_filter(handle => p_job_number, ' ||
                                           '                                  name => ''NAME_EXPR'','  ||
                                           '                                  value => ${pattern2}, '  ||
                                           '                            object_type => ''PROCOBJ''); ' 
                                           ;
      l_exclusion_snippet g_long_variable_type := '   DBMS_DATAPUMP.metadata_filter(p_job_number, ' ||
                                           '                                 ''EXCLUDE_PATH_LIST'', ${EXCLUDE_LIST} ); ';
      l_exclusion_item    g_med_variable_type;
   BEGIN
      --
      FOR r_stn IN c_stn(p_sma_id) LOOP
         l_body := l_body||chr(10)||
                '   DBMS_DATAPUMP.metadata_filter(handle => p_job_number, ' ||
                '                                 name   => ''NAME_EXPR'',' ||
                '                                 value  =>'''|| r_stn.stn_value||''', '  ||
                '                            object_type => ''TABLE''); '
                ;
      END LOOP;
      l_body := REPLACE(l_body, '${pattern1}', l_pattern_tab1);
      l_body := REPLACE(l_body, '${pattern2}', l_pattern_tab2);

      --
      l_par2 := '';
      IF NOT (p_exclusionlist IS NULL OR p_exclusionlist.FIRST IS NULL) THEN
         FOR I IN p_exclusionlist.FIRST .. p_exclusionlist.LAST LOOP
            l_exclusion_item := p_exclusionlist(I);
            IF I = p_exclusionlist.FIRST THEN
               l_par2 := l_encl;
            END IF;

           l_par2 := l_par2 || l_encl_double || l_exclusion_item ||
                     l_encl_double;

           IF I <> p_exclusionlist.LAST THEN
             l_par2 := l_par2 || ',';
           END IF;
           IF I = p_exclusionlist.LAST THEN
             l_par2 := l_par2 || l_encl;
           END IF;
         END LOOP;
         l_exclusion_snippet := REPLACE(l_exclusion_snippet,
                                        '${EXCLUDE_LIST}',
                                        l_par2);
         l_body              := l_body || l_exclusion_snippet;

      END IF;
      trace_p('body injected: '||l_body);
         create_procedure(p_schema       => p_target_schema,
                                  p_proc_name    => 'dpump_cfg_metadata_filter',
                                  p_proc_param   => 'p_job_number IN NUMBER',
                                  p_proc_declare => NULL,
                                  p_proc_body    => l_body);
   EXCEPTION
      WHEN OTHERS THEN
         trace_p('medatadata filter error:'|| DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace);
         RAISE dpp_job_var.ge_injection_failed;
         --
   END inj_conf_metadata_filter;

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
   ) RETURN BOOLEAN
   IS
   
      -- cursor that retrieves the data filter options
      CURSOR c_options(
         p_sma_id    dpp_schemas.sma_id%TYPE
       , p_usage     dpp_schema_options.stn_usage%TYPE
      ) IS
      SELECT sch.sma_name
           , sop.stn_value
        FROM dpp_schema_options sop
        JOIN dpp_schemas sch
          ON sch.sma_id = sop.sma_id
       WHERE sop.sma_id = p_sma_id
         AND sop.stn_usage = p_usage
         AND sop.otn_name = 'DATA_FILTER'
       ORDER BY sop.stn_value ASC;
       
      -- filter field
      filter_field     VARCHAR2(1000);
      
      -- first separator position
      sep_pos_1        PLS_INTEGER;
      
      -- second separator position
      sep_pos_2        PLS_INTEGER;
      
      -- table name
      table_name       VARCHAR2(100);
      
      -- filter name
      filter_name      VARCHAR2(100);
      
      -- filter value
      filter_value     VARCHAR2(1000);
      
      --option body
      option_body      g_long_variable_type;
      
      -- procedure body
      proc_body        g_long_variable_type       := NULL;
       
   BEGIN
   
      -- Check parameters.
      IF p_sma_id IS NULL THEN
         trace_p('data filter error: invalid schema ID');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF TRIM(p_target_schema) IS NULL THEN
         trace_p('data filter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_usage IS NULL THEN
         trace_p('data filter error: invalid usage');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;
   
      -- Browse the data filters.
      FOR r_option IN c_options(p_sma_id, p_usage) LOOP
      
         -- Split the value field to extract the table, filter name and filter
         -- value.
         filter_field := r_option.stn_value;
         sep_pos_1 := NVL(INSTR(filter_field, '#'), 0);
         sep_pos_2 := NVL(INSTR(filter_field, '#', sep_pos_1 + 1), 0);
         
         IF sep_pos_1 = 0 OR sep_pos_2 = 0 or sep_pos_2 - sep_pos_1 < 2 OR
            sep_pos_2 >= LENGTH(filter_field) THEN
            trace_p('data filter error: invalid filter field format');
            RAISE dpp_job_var.ge_injection_failed;
         END IF;
         IF sep_pos_1 > 1 THEN
            table_name := SUBSTR(filter_field, 1, sep_pos_1 - 1);
         ELSE
            table_name := NULL;
         END IF;
         filter_name := SUBSTR(
            filter_field
          , sep_pos_1 + 1
          , sep_pos_2 - sep_pos_1 - 1
         );
         filter_value := SUBSTR(
            filter_field
          , sep_pos_2 + 1
          , LENGTH(filter_field) - sep_pos_2
         );
         
         -- Add the option to the body.
         option_body :=
            'DBMS_DATAPUMP.DATA_FILTER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''' || filter_name || ''''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ';
         IF filter_name IN ('INCLUDE_ROWS', 'SAMPLE') THEN
            option_body := option_body || TO_CHAR(filter_value);
         ELSIF filter_name IN ('PARTITION_EXPR', 'PARTITION_LIST', 'SUBQUERY')
            THEN
            option_body := option_body
               || '''' 
               || REPLACE(filter_value, '''', '''''') 
               || '''';
         ELSE
            trace_p(
               'data filter error: invalid filter type ('
            || NVL(filter_name, 'NULL')
            || ')'
            );
            RAISE dpp_job_var.ge_injection_failed;
         END IF;
         option_body := option_body
         || dpp_inj_var.gk_carriage_return
         || ' , table_name    => ';
         IF table_name IS NOT NULL THEN
            option_body := option_body || '''' || table_name || '''';
         ELSE
            option_body := option_body || 'NULL';
         END IF;
         option_body := option_body
         || dpp_inj_var.gk_carriage_return
--         || ' , schema_name   => ''' || r_option.sma_name || ''''
--         || dpp_inj_var.gk_carriage_return
         || ');'
         || dpp_inj_var.gk_carriage_return;
         
         -- Add the option body to the procedure body.
         IF proc_body IS NULL THEN
            proc_body := option_body;
         ELSE
            proc_body := proc_body || option_body;
         END IF;
      
      END LOOP;
      
      -- Create the procedure.
      IF proc_body IS NOT NULL THEN
         create_procedure(
            p_schema          => p_target_schema
          , p_proc_name       => 'dpump_cfg_data_filter'
          , p_proc_param      => 'p_job_number IN NUMBER'
          , p_proc_declare    => NULL
          , p_proc_body       => proc_body
         );
         trace_p('body injected: '|| proc_body);
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   
   EXCEPTION
      WHEN dpp_job_var.ge_injection_failed THEN
         RAISE;
      WHEN OTHERS THEN
         trace_p(
            'data filter error:'
         || DBMS_UTILITY.format_error_stack
         || DBMS_UTILITY.format_error_backtrace
         );
         RAISE dpp_job_var.ge_injection_failed;

   END inj_conf_data_filter;

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
   ) RETURN BOOLEAN
   IS

      -- cursor that retrieves the data remap options
      CURSOR c_options(
         p_sma_id    dpp_schemas.sma_id%TYPE
       , p_usage     dpp_schema_options.stn_usage%TYPE
      ) IS
      SELECT sch.sma_name
           , sop.stn_value
        FROM dpp_schema_options sop
        JOIN dpp_schemas sch
          ON sch.sma_id = sop.sma_id
       WHERE sop.sma_id = p_sma_id
         AND sop.stn_usage = p_usage
         AND sop.otn_name = 'DATA_REMAP'
       ORDER BY sop.stn_value ASC;

      -- first separator position
      sep_pos_1               PLS_INTEGER;

      -- second separator position
      sep_pos_2               PLS_INTEGER;

      -- third separator position
      sep_pos_3               PLS_INTEGER;

      -- filter field
      filter_field            VARCHAR2(4000);

      -- filter name
      filter_name             VARCHAR2(100);

      -- table name
      table_name              VARCHAR2(100);

      -- column name
      column_name             VARCHAR2(100);

      -- remap function
      remap_function          VARCHAR2(2000);

      --option body
      option_body      g_long_variable_type;
      
      -- procedure body
      proc_body        g_long_variable_type       := NULL;
       
   BEGIN

      -- Check parameters.
      IF p_sma_id IS NULL THEN
         trace_p('data remap error: invalid schema ID');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF TRIM(p_target_schema) IS NULL THEN
         trace_p('data remap error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_usage IS NULL THEN
         trace_p('data remap error: invalid usage');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Browse the data remap items.
      <<browse_data_remaps>>
      FOR r_option IN c_options(p_sma_id, p_usage) LOOP

         -- Locator the separator positions.
         filter_field := r_option.stn_value;
         sep_pos_1 := NVL(INSTR(filter_field, '#'), 0);
         sep_pos_2 := NVL(INSTR(filter_field, '#', sep_pos_1 + 1), 0);
         sep_pos_3 := NVL(INSTR(filter_field, '#', sep_pos_2 + 1), 0);
         IF sep_pos_1 < 2 OR sep_pos_2 = 0 OR sep_pos_3 = 0 OR
            sep_pos_2 - sep_pos_1 < 2 OR sep_pos_3 - sep_pos_2 < 2 OR
            sep_pos_3 >= LENGTH(filter_field) THEN
            trace_p('data remap error: invalid data remap format');
            RAISE dpp_job_var.ge_injection_failed;
         END IF;

         -- Extract the fields.
         filter_name := SUBSTR(filter_field, 1, sep_pos_1 - 1);
         table_name := SUBSTR(
            filter_field
          , sep_pos_1 + 1
          , sep_pos_2 - sep_pos_1 - 1
         );
         column_name := SUBSTR(
            filter_field
          , sep_pos_2 + 1
          , sep_pos_3 - sep_pos_2 -1
         );
         remap_function := SUBSTR(
            filter_field
          , sep_pos_3 + 1
          , LENGTH(filter_field) - sep_pos_3
         );

         -- Add the option to the body.
         option_body :=
            'DBMS_DATAPUMP.DATA_REMAP('
         || dpp_inj_var.gk_carriage_return
         || '   handle           => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name             => ''' || filter_name || ''''
         || dpp_inj_var.gk_carriage_return
         || ' , table_name       => ''' || table_name || ''''
         || dpp_inj_var.gk_carriage_return
         || ' , column           => ''' || column_name || ''''
         || dpp_inj_var.gk_carriage_return
         || ' , function   => ''' || REPLACE(remap_function, '''', '''''') || ''''
         || dpp_inj_var.gk_carriage_return
         || ' , schema     => ''' || r_option.sma_name || ''''
         || dpp_inj_var.gk_carriage_return
         || ');'
         || dpp_inj_var.gk_carriage_return;
 
         -- Add the option body to the procedure body.
         IF proc_body IS NULL THEN
            proc_body := option_body;
         ELSE
            proc_body := proc_body || option_body;
         END IF;

      END LOOP browse_data_remap;

      -- Create the procedure.
      IF proc_body IS NOT NULL THEN
         create_procedure(
            p_schema          => p_target_schema
          , p_proc_name       => 'dpump_cfg_data_remap'
          , p_proc_param      => 'p_job_number IN NUMBER'
          , p_proc_declare    => NULL
          , p_proc_body       => proc_body
         );
         trace_p('body injected: ' || proc_body);
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   
   EXCEPTION
      WHEN dpp_job_var.ge_injection_failed THEN
         RAISE;
      WHEN OTHERS THEN
         trace_p(
            'data remap error:'
         || DBMS_UTILITY.format_error_stack
         || DBMS_UTILITY.format_error_backtrace
         );
         RAISE dpp_job_var.ge_injection_failed;

   END inj_create_conf_data_remap;

  PROCEDURE inj_drp_cfg_tblspace_map(p_target_schema IN VARCHAR2) IS
  BEGIN
    --
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_cfg_tblspace_map');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
      --
  END inj_drp_cfg_tblspace_map;

  PROCEDURE inj_cfg_tblspace_map(p_target_schema   IN VARCHAR2,
                                 p_src_tablespace  IN VARCHAR2,
                                 p_dest_tablespace IN VARCHAR2) IS
    l_body g_long_variable_type := ' DBMS_DATAPUMP.metadata_remap(handle      => p_job_number,' ||
                             '  name        => ''REMAP_TABLESPACE'',' ||
                             '  old_value   => ''${SRC}'',' ||
                             '  value       => ''${DST}'');';
  BEGIN
    l_body := REPLACE(l_body, '${SRC}', p_src_tablespace);
    l_body := REPLACE(l_body, '${DST}', p_dest_tablespace);
    create_procedure(p_schema       => p_target_schema
                   , p_proc_name    => 'dpump_cfg_tblspace_map'
                   , p_proc_param   => 'p_job_number IN NUMBER'
                   , p_proc_declare => NULL
                   , p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_cfg_tblspace_map;

  -- check
  PROCEDURE inj_drp_cfg_mdata_trans_imp(p_target_schema IN VARCHAR2) IS
  BEGIN
    --
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_cfg_metadata_trn_imp');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
      --
  END inj_drp_cfg_mdata_trans_imp;

  PROCEDURE inj_cfg_mdata_trans_imp(p_target_schema IN VARCHAR2, 
                                    p_option IN NUMBER := 1) IS
    l_body g_long_variable_type := ' DBMS_DATAPUMP.metadata_TRANSFORM(handle      => p_job_number,' ||
                             '  name        => ''SEGMENT_ATTRIBUTES'',' ||
                             '  value   => 0 );';
    l_body2 g_long_variable_type := ' DBMS_DATAPUMP.metadata_TRANSFORM(handle      => p_job_number,' ||
                             '  name        => ''OID'',' ||
                             '  value   => 0 );';                             
    l_body3 g_long_variable_type := ' DBMS_DATAPUMP.metadata_TRANSFORM(handle      => p_job_number,' ||
                             '  name        => ''STORAGE'',' ||
                             '  value   => 0 );';                             

  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_cfg_metadata_trn_imp',
                                p_proc_param   => 'p_job_number IN NUMBER',
                                p_proc_declare => NULL,
                                p_proc_body    => CASE p_option
                                                     WHEN 1 THEN l_body
                                                     WHEN 2 THEN l_body2
                                                     WHEN 3 THEN l_body3
                                                  END);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_cfg_mdata_trans_imp;
  --
  --
  --
  PROCEDURE inj_config_set_params_imp(p_target_schema IN VARCHAR2) IS
    l_body g_med_variable_type := '  DBMS_DATAPUMP.set_parameter(handle => p_job_number,' ||
                             '                              name   => ''TABLE_EXISTS_ACTION'',' ||
                             '                              value  => ''SKIP''); ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_cfg_set_param_imp',
                                p_proc_param   => 'p_job_number IN NUMBER',
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_config_set_params_imp;
  --
  -- check
  --
  PROCEDURE inj_drop_config_set_params_imp(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_cfg_set_param_imp');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_set_params_imp;

  --
  -- check
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
   ) IS

      -- procedure body
      proc_body         g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('compression parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_compression IS NULL THEN
         trace_p('compression parameter error: invalid compression method');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''COMPRESSION'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_compression || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_compression'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_compression;

   /**
   * Inject the code that drops the procedure that configures the compression
   * method.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_compression(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_compression'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_compression;

  --
  -- check
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
   ) IS

      -- procedure body
      proc_body               g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('encryption parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_encryption IS NULL THEN
         trace_p('encryption parameter error: invalid encryption method');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''ENCRYPTION'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_encryption || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_encryption'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_encryption;

   /**
   * Inject the code that drops the procedure that configures the encryption
   * method.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encryption(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_encryption'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_encryption;

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
   ) IS

      -- procedure body
      proc_body               g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('encryption mode parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_encryption_mode IS NULL THEN
         trace_p('encryption mode parameter error: invalid encryption mode');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''ENCRYPTION_MODE'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_encryption_mode || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_encrypt_mode'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_encrypt_mode;

   /**
   * Inject the code that drops the procedure that configures the encryption
   * mode.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encrypt_mode(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_encrypt_mode'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_encrypt_mode;

  --
  -- check
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
   ) IS

      -- procedure body
      proc_body               g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('encryption password parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_encryption_pwd IS NULL THEN
         trace_p('encryption password parameter error: invalid encryption password');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''ENCRYPTION_PASSWORD'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_encryption_pwd || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_encrypt_pwd'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_encrypt_pwd;

   /**
   * Inject the code that drops the procedure that configures the encryption
   * password.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_encrypt_pwd(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_encrypt_pwd'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_encrypt_pwd;

  --
  -- check
  --

   /**
   * Inject the code that creates the procedure that configures the logtime
   * paramater.
   *
   * @param p_target_schema: target schema
   * @param p_logtime: logtime type
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_create_config_logtime(
      p_target_schema         IN  VARCHAR2
    , p_logtime               IN  VARCHAR2
   ) IS

      -- procedure body
      proc_body               g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('logtime parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_logtime IS NULL THEN
         trace_p('logtime parameter error: invalid logtime');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''LOGTIME'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_logtime || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_logtime'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_logtime;

   /**
   * Inject the code that drops the procedure that configures the logtime
   * parameter.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_logtime(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_logtime'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_logtime;

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
   ) IS

      -- procedure body
      proc_body               g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('logtime parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_metrics IS NULL THEN
         trace_p('metrics parameter error: invalid metrics');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''METRICS'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ' || p_metrics
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_metrics'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_metrics;

   /**
   * Inject the code that drops the procedure that configures the metrics
   * parameter.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_metrics(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_metrics'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_metrics;

  --
  -- check
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
   ) IS

      -- procedure body
      proc_body         g_long_variable_type;

   BEGIN

      -- Check parameters.
      IF p_target_schema IS NULL THEN
         trace_p('compression algorithm parameter error: invalid target schema');
         RAISE dpp_job_var.ge_injection_failed;
      ELSIF p_algorithm IS NULL THEN
         trace_p('compression algorithm parameter error: invalid compression method');
         RAISE dpp_job_var.ge_injection_failed;
      END IF;

      -- Build the procedure body.
      proc_body :=
            'DBMS_DATAPUMP.SET_PARAMETER('
         || dpp_inj_var.gk_carriage_return
         || '   handle        => p_job_number'
         || dpp_inj_var.gk_carriage_return
         || ' , name          => ''COMPRESSION_ALGORITHM'''
         || dpp_inj_var.gk_carriage_return
         || ' , value         => ''' || p_algorithm || ''''
         || dpp_inj_var.gk_carriage_return
         || ');';

      -- Create the procedure.
      create_procedure(
         p_schema       => p_target_schema
       , p_proc_name    => 'dpump_cfg_compression_algo'
       , p_proc_param   => 'p_job_number IN NUMBER'
       , p_proc_declare => NULL
       , p_proc_body    => proc_body
      );
      trace_p('body injected: ' || proc_body);

      EXCEPTION
         WHEN dpp_job_var.ge_injection_failed THEN 
            RAISE;
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;

   END inj_create_config_compression_algo;

   /**
   * Inject the code that drops the procedure that configures the compression
   * algorithm.
   *
   * @param p_target_schema: target schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_config_compression_algo(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_compression_algo'
      );
      EXCEPTION
         WHEN OTHERS THEN
            RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_config_compression_algo;

  --
  -- check
  --

  PROCEDURE inj_drop_conf_flashbacktime(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_config_flashbacktime');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_conf_flashbacktime;

  PROCEDURE inj_conf_flashbacktime(p_target_schema IN VARCHAR2) IS
    l_declare g_med_variable_type := ' SPECFIED_MULTIPLE_TIMES EXCEPTION; PRAGMA EXCEPTION_INIT(SPECFIED_MULTIPLE_TIMES, -39051); ';

    l_body g_med_variable_type := ' DBMS_DATAPUMP.set_parameter(handle => p_job_number, ' ||
                             '    name   => ''FLASHBACK_TIME'', ' ||
                             '    value  => '' TO_TIMESTAMP(TO_CHAR(SYSDATE,''''YYYY-MM-DD HH24:MI:SS''''),''''YYYY-MM-DD HH24:MI:SS'''')''); ' ||
                             ' EXCEPTION  WHEN SPECFIED_MULTIPLE_TIMES THEN  NULL; ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_config_flashbacktime',
                                p_proc_param   => 'p_job_number in NUMBER',
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_conf_flashbacktime;

  PROCEDURE inj_drop_check_running_jobs(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_check_running_jobs');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_check_running_jobs;
  --
  -- check
  --
  PROCEDURE inj_check_running_jobs(p_target_schema IN VARCHAR2) IS
    l_declare g_med_variable_type := '  l_cnt NUMBER;  ';

    l_body g_med_variable_type := '  SELECT COUNT(1) ' || '  INTO l_cnt  ' ||
                             '   FROM USER_DATAPUMP_JOBS A ' ||
                             '     WHERE A.state IN (''EXECUTING'') ' ||
                             '  OR (A.state IN (''DEFINING'', ''UNDEFINED'') AND ' ||
                             '      A.job_name IN (''DPUMP_EXP_TABLE'',''DPUMP_IMP_TABLE'')); ' ||
                             ' p_rc   := l_cnt; ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_check_running_jobs',
                                p_proc_param   => 'p_rc OUT NUMBER',
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_check_running_jobs;
  --
  -- check
  --

  PROCEDURE run_injected_job(p_target_schema IN VARCHAR2,
                             p_job_number    IN NUMBER,
                             p_simulation    IN BOOLEAN := FALSE) IS
    l_ran_hash g_small_variable_type;
  BEGIN
    --
    -- NOTE: check if hash exist, the hash is used to prevent collision detection when the data was exported
    -- there is a local injected procedure run_job that is exported aswell, we dont filter it out yet
    -- filtering out with an EXCLUSION filter doesnt work in datapump, we dont know why yet, but for now
    -- we use a random appended 4-character string to prevent name collision and locks -- waits -- during
    -- import.
    -- check if we already have a hash for this target schema
    --
    IF NOT dpp_inj_var.gt_hash_table.exists(p_target_schema) THEN
      -- must be there from prev injection
      RAISE dpp_job_var.ge_missing_hash_value;
    ELSE
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    END IF;
    IF p_simulation = FALSE THEN
      EXECUTE IMMEDIATE ' BEGIN ' || p_target_schema || '.dpump_run_job_' ||
                        l_ran_hash || '(:job_no); END; '
        USING IN p_job_number;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
      --
  END run_injected_job;

  PROCEDURE inj_drop_run_job(p_target_schema IN VARCHAR2) IS
    l_ran_hash g_small_variable_type;
  BEGIN
    --
    -- NOTE: check if hash exist, the hash is used to prevent collision detection when the data was exported
    -- there is a local injected procedure run_job that is exported aswell, we dont filter it out yet
    -- filtering out with an EXCLUSION filter doesnt work in datapump, we dont know why yet, but for now
    -- we use a random appended 4-character string to prevent name collision and locks -- waits -- during
    -- import.
    -- check if we already have a hash for this target schema
    --
    IF NOT dpp_inj_var.gt_hash_table.exists(p_target_schema) THEN
      -- must be there from prev injection
      RAISE dpp_job_var.ge_missing_hash_value;
    ELSE
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    END IF;

    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_run_job_' || l_ran_hash);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_run_job;
  --
  -- check
  --
  PROCEDURE inj_run_job(p_target_schema IN VARCHAR2) IS
    --
    --
    l_declare g_med_variable_type := ' l_job_state user_datapump_jobs.state%type;  '||
                                ' l_network_name  VARCHAR2(128); '||
                                ' l_service_name VARCHAR2(128) := SYS_CONTEXT(''userenv'',''db_name'')||''_TAF.cc.cec.eu.int''; ' -- 128 in Oracle12G!
                                ;
    --
    --
   /* l_declare2 g_long_variable_type := ' l_job_state user_datapump_jobs.state%type; ' ||
                                 '  pct_done    NUMBER; ' ||
                                 '  job_state   VARCHAR2(30); ' ||
                                 '  le          ku$_LogEntry; ' ||
                                 '  js          ku$_JobStatus; ' ||
                                 '  sts         ku$_Status; ' ||
                                 '  ind         NUMBER; '||
                                 '  l_service_name VARCHAR2(128) := SYS_CONTEXT(''userenv'',''db_name'')||''_TAF.cc.cec.eu.int''; '-- 128 in Oracle12G!
                                 ;
    */                             
    --
    --
    l_body2 g_long_variable_type := ' DBMS_DATAPUMP.start_job(handle       => p_job_number, ' ||
                              '                         skip_current => 0, ' ||
                              '                         abort_step   => 0, ' ||
							  '                         cluster_ok   => 0, ' ||
                              '                         service_name   => l_service_name); ' ||
                              '  DBMS_DATAPUMP.wait_for_job(handle    => p_job_number, ' ||
                              '                          job_state => l_job_state); ' ||
                              '  pct_done  := 0; ' ||
                              '  job_state := ''UNDEFINED''; ' ||
                              '  WHILE (job_state != ''COMPLETED'') AND (job_state != ''STOPPED'') LOOP ' ||
                              '    DBMS_LOCK.sleep(10); ' ||
                              '    dbms_datapump.get_status(p_job_number, ' ||
                              '    dbms_datapump.ku$_status_job_error + ' ||
                              '    dbms_datapump.ku$_status_job_status + ' ||
                              '    dbms_datapump.ku$_status_wip,  -1, job_state, sts); ' ||
                              '    js := sts.job_status; ' ||
                              '    IF js.percent_done != pct_done THEN ' ||
                              '      pct_done := js.percent_done; ' ||
                              '    END IF; ' ||
                              '    IF (BITAND(sts.mask, dbms_datapump.ku$_status_wip) != 0) THEN ' ||
                              '      le := sts.wip; ' || '    ELSE ' ||
                              '      IF (BITAND(sts.mask, dbms_datapump.ku$_status_job_error) != 0) THEN ' ||
                              '         le := sts.error; ' || '      ELSE ' ||
                              '         le := NULL; ' || '      END IF; ' ||
                              '    END IF; ' ||
                              '    IF le IS NOT NULL THEN ' ||
                              '     ind := le.FIRST; ' ||
                              '     WHILE ind IS NOT NULL LOOP ' ||
                              '        dbms_output.put_line(le(ind).LogText); ' ||
                              '          ind := le.NEXT(ind); ' ||
                              '     END LOOP; ' || '   END IF; ' ||
                              ' END LOOP; ' ||
                              '  DBMS_DATAPUMP.detach(handle => p_job_number); ' ||
                              '  IF job_state <> ''COMPLETED'' THEN ' ||
                              '    RAISE DBMS_DATAPUMP.SUCCESS_WITH_INFO; ' ||
                              '  END IF;  ' || '  EXCEPTION ' ||
                              '  WHEN DBMS_DATAPUMP.SUCCESS_WITH_INFO THEN ' ||
                              '    DBMS_OUTPUT.PUT_LINE(''status:'' || l_job_state); ' ||
                              '    RAISE; ' || '  WHEN OTHERS THEN ' ||
                              '    DBMS_OUTPUT.PUT_LINE(''status:'' || l_job_state); ' ||
                              '    dpump_stop_job_safe_${HASH}(p_job_number); ' ||
                              '    RAISE; ';
    --
    --
    l_body     g_med_variable_type := 
                                 '   BEGIN' ||
                                 '      SELECT network_name' ||
                                 '        INTO l_network_name' ||
                                 '        FROM dba_services' ||
                                 '        WHERE UPPER(network_name) = UPPER(l_service_name);' ||
                                 '   EXCEPTION' ||
                                 '      WHEN NO_DATA_FOUND THEN' ||
                                 '         l_service_name := NULL; '||
                                 '      WHEN TOO_MANY_ROWS THEN'||
                                 '         NULL; '||
                                 '   END;    ' ||
                                 '   DBMS_DATAPUMP.start_job(handle => p_job_number, ' ||
                                 '                           skip_current => 0, ' ||
                                 '                           abort_step   => 0,' ||
                                 '                         service_name   => l_service_name); ' ||
                                 '   DBMS_DATAPUMP.wait_for_job(handle    => p_job_number,' ||
                                 '                              job_state => l_job_state);' ||
                                 '   DBMS_DATAPUMP.detach(handle => p_job_number); ' ||
                                 '   DBMS_OUTPUT.PUT_LINE(''status:''||l_job_state); ' ||
                                 '   EXCEPTION ' ||
                                 '   WHEN DBMS_DATAPUMP.SUCCESS_WITH_INFO THEN ' ||
                                 '   DBMS_OUTPUT.PUT_LINE(''status:''||l_job_state); ' ||
                                 '      RAISE; ' || '   WHEN OTHERS THEN  ' ||
                                 '   DBMS_OUTPUT.PUT_LINE(''status:''||l_job_state); ' ||
                                 '      dpump_stop_job_safe_${HASH}(p_job_number); ' ||
                                 '      RAISE; ';
    l_ran_hash g_small_variable_type;
  BEGIN
    --
    -- NOTE: check if hash exist, the hash is used to prevent collision detection when the data was exported
    -- there is a local injected procedure run_job that is exported aswell, we dont filter it out yet
    -- filtering out with an EXCLUSION filter doesnt work in datapump, we dont know why yet, but for now
    -- we use a random appended 4-character string to prevent name collision and locks -- waits -- during
    -- import.
    -- check if we already have a hash for this target schema
    --
    IF dpp_inj_var.gt_hash_table.exists(p_target_schema) THEN
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    ELSE
      dpp_inj_var.gt_hash_table(p_target_schema) := DBMS_RANDOM.string('u', '4');
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    END IF;
    --
    l_body  := REPLACE(l_body, '${HASH}', l_ran_hash);
    l_body2 := REPLACE(l_body2, '${HASH}', l_ran_hash);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_run_job_' ||
                                                  l_ran_hash,
                                p_proc_param   => 'p_job_number IN NUMBER',
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_run_job;
  --
  --   check
  --
  PROCEDURE inj_drop_stop_job_safe(p_target_schema IN VARCHAR2) IS
    l_ran_hash g_small_variable_type;
  BEGIN
    --
    -- NOTE: check if hash exist, the hash is used to prevent collision detection when the data was exported
    -- there is a local injected procedure run_job that is exported aswell, we dont filter it out yet
    -- filtering out with an EXCLUSION filter doesnt work in datapump, we dont know why yet, but for now
    -- we use a random appended 4-character string to prevent name collision and locks -- waits -- during
    -- import.
    -- check if we already have a hash for this target schema
    --
    IF NOT dpp_inj_var.gt_hash_table.exists(p_target_schema) THEN
      -- must be there from prev injection
      RAISE dpp_job_var.ge_missing_hash_value;
    ELSE
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    END IF;

    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_stop_job_safe_' ||
                                             l_ran_hash);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_stop_job_safe;
  --
  --   check
  --
  PROCEDURE inj_stop_job_safe(p_target_schema IN VARCHAR2) IS
    l_body     g_med_variable_type := '  DBMS_DATAPUMP.stop_job(handle => p_job_number);' ||
                                 '    EXCEPTION' ||
                                 '      WHEN OTHERS THEN ' ||
                                 '        NULL; ';
    l_ran_hash g_small_variable_type;
  BEGIN
    --
    -- NOTE: check if hash exist, the hash is used to prevent collision detection when the data was exported
    -- there is a local injected procedure run_job that is exported aswell, we dont filter it out yet
    -- filtering out with an EXCLUSION filter doesnt work in datapump, we dont know why yet, but for now
    -- we use a random appended 4-character string to prevent name collision and locks -- waits -- during
    -- import.
    -- check if we already have a hash for this target schema
    --

    --g_hash_table.delete; -- for testing purpose ; don't set it for common usage

    IF dpp_inj_var.gt_hash_table.exists(p_target_schema) THEN
      -- must NOT be there from prev injection
      RAISE dpp_job_var.ge_missing_hash_value;
    ELSE
      dpp_inj_var.gt_hash_table(p_target_schema) := DBMS_RANDOM.string('u', '4');
      l_ran_hash := dpp_inj_var.gt_hash_table(p_target_schema);
    END IF;
    --
    --
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_stop_job_safe_' ||
                                                  l_ran_hash,
                                p_proc_param   => 'p_job_number IN NUMBER',
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_stop_job_safe;
  --
  --   check
  --
  PROCEDURE inj_drop_attatch_to_job(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_attatch_to_job');
  END inj_drop_attatch_to_job;
  --
  --   check
  --
  PROCEDURE inj_attatch_to_job(p_target_schema IN VARCHAR2) IS
    l_body g_med_variable_type := ' l_job_number := NULL; ' || ' BEGIN ' ||
                             '   l_job_number := DBMS_DATAPUMP.attach(p_table_name, USER); ' ||
                             ' EXCEPTION ' ||
                             '    WHEN DBMS_DATAPUMP.no_such_job THEN NULL; ' ||
                             ' END; ' || ' p_job_number := l_job_number; ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_attatch_to_job',
                                p_proc_param   => 'p_job_number OUT NUMBER,p_table_name IN VARCHAR2',
                                p_proc_declare => '  l_job_number NUMBER; ',
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_attatch_to_job;
  --
  --   check
  --
   PROCEDURE inj_drop_check_privs(p_target_schema IN VARCHAR2) IS
   BEGIN
      drop_object(p_schema      => p_target_schema
                 ,p_object_type => 'PROCEDURE'
                 ,p_object_name => 'dpump_check_privs'
                 );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_check_privs;
  --
  --   check
  --
  PROCEDURE inj_check_privs(p_target_schema IN VARCHAR2) IS
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_check_privs',
                                p_proc_param   => 'p_rc OUT NUMBER',
                                p_proc_declare => '  l_rc NUMBER; ',
                                p_proc_body    => ' SELECT COUNT(1) INTO l_rc FROM USER_SYS_PRIVS A WHERE A.privilege IN (''CREATE TABLE''); p_rc := l_rc;   ');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_check_privs;
  --
  --   check
  --
/*  PROCEDURE inj_drop_check_post_fix_dir(p_target_schema IN VARCHAR2) IS
  BEGIN
    drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_chk_postfix_dir');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END;
*/  --
  --   check
  --
/*  PROCEDURE inj_check_post_fix_dir(p_target_schema IN VARCHAR2) IS
  BEGIN
    create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_chk_postfix_dir',
                                p_proc_param   => 'p_rc OUT NUMBER',
                                p_proc_declare => ' l_cnt NUMBER; ',
                                p_proc_body    => ' SELECT COUNT(1) INTO l_cnt FROM ALL_DIRECTORIES A  WHERE A.DIRECTORY_NAME = ''SP2_POST_FIX'';  p_rc := l_cnt;   ');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END;
*/  
  --
  --  check
  --
  PROCEDURE inj_drop_check_dir_object(p_target_schema IN VARCHAR2) IS

  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_chk_dir_object');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_check_dir_object;
  --
  --   check
  --
  PROCEDURE inj_check_dir_object(p_target_schema IN VARCHAR2) IS
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_chk_dir_object',
                                p_proc_param   => 'p_rc OUT NUMBER',
                                p_proc_declare => ' l_cnt NUMBER; ',
                                p_proc_body    => ' SELECT COUNT(1) INTO l_cnt FROM all_directories a  WHERE a.directory_name = '''||UPPER(dpp_job_var.g_dpp_dir)||''';  p_rc := l_cnt;   ');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_check_dir_object;
  --
  --   check
  --
  PROCEDURE inj_drop_exec_proc(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_exec_auth');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_exec_proc;
  --
  --   check
  --
  PROCEDURE inj_exec_proc(p_target_schema IN VARCHAR2) IS
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_exec_auth',
                                p_proc_param   => 'p_sql IN VARCHAR2',
                                p_proc_declare => NULL,
                                p_proc_body    => ' EXECUTE IMMEDIATE p_sql; ');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_exec_proc;
  --
  --   check
  --
  PROCEDURE inj_drop_clear_all_db_links(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_clear_all_db_links');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_drop_clear_all_db_links;
  --
  --   check
  --
  PROCEDURE inj_clear_all_db_links(p_target_schema IN VARCHAR2,
                                   p_list          IN VARCHAR2) IS
    l_declare g_med_variable_type := ' l_sql VARCHAR2(150);';
    l_body    g_long_variable_type := ' FOR IREC IN (SELECT * FROM USER_DB_LINKS WHERE DB_LINK NOT IN (${LIST})) LOOP ' ||
                                '    l_sql := ''DROP DATABASE LINK ''||IREC.DB_LINK; ' ||
                                '    EXECUTE IMMEDIATE l_sql; ' ||
                                ' END LOOP; ';
  BEGIN
    -- inject code into target schema
    l_body := REPLACE(l_body, '${LIST}', p_list);
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_clear_all_db_links',
                                p_proc_param   => NULL,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_clear_all_db_links;
  --
  -- check
  --
  PROCEDURE inj_drop_exp_logfile(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_conf_exp_logfile');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_exp_logfile;
  --
  -- check
  --
  PROCEDURE inj_exp_logfile(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type;
    l_body       g_med_variable_type;
  BEGIN
    l_parameters  := 'p_job_number IN NUMBER, p_context    IN VARCHAR2';
    l_body        := 'DBMS_DATAPUMP.add_file(handle    => p_job_number,' ||
                     '                       filename  => p_context ,' ||
                     '                       directory => '''||UPPER(dpp_job_var.g_dpp_dir)||''',' ||
                     '                       filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE); ';  
    -- inject code into target schema
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_conf_exp_logfile',
                                p_proc_param   => l_parameters,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_exp_logfile;
  --
  -- check
  --
  PROCEDURE inj_drop_imp_logfile(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_conf_imp_logfile');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_imp_logfile;
  --
  -- check
  --
  PROCEDURE inj_imp_logfile(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type;
    l_body       g_med_variable_type;
  BEGIN
    l_parameters  := 'p_job_number IN NUMBER, p_logfile_name    IN VARCHAR2';
    l_body        := 'DBMS_DATAPUMP.add_file(handle    => p_job_number,' ||
                     '                       filename  => p_logfile_name,' ||
                     '                       directory => '''||UPPER(dpp_job_var.g_dpp_dir)||''',' ||
                     '                       filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE); ';  
    -- inject code into target schema
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_conf_imp_logfile',
                                p_proc_param   => l_parameters,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_imp_logfile;
  --
  -- check
  --
  PROCEDURE inj_drop_config_metadata(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_config_metadata');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_metadata;
  --
  -- check
  --
  PROCEDURE inj_config_metadata(p_target_schema IN VARCHAR2) IS
    l_declare    g_med_variable_type := ' SPECFIED_MULTIPLE_TIMES EXCEPTION; ' ||
                                   ' PRAGMA EXCEPTION_INIT(SPECFIED_MULTIPLE_TIMES, -39051); ';
    l_parameters g_med_variable_type := 'p_job_number IN NUMBER';
    l_body       g_med_variable_type := ' DBMS_DATAPUMP.set_parameter(handle => p_job_number, ' ||
                                   '                             name   => ''INCLUDE_METADATA'',' ||
                                   '                             value  => 1); ' ||
                                   '   EXCEPTION ' ||
                                   '     WHEN SPECFIED_MULTIPLE_TIMES THEN ' ||
                                   '       NULL;';
  BEGIN
    -- inject code into target schema
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_config_metadata',
                                p_proc_param   => l_parameters,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_config_metadata;
  --
  -- check
  --
   /**
   * Drop the procedure that configures the data filters.
   *
   * @throws dpp_job_var.ge_injection_failed: injection failure
   */
   PROCEDURE inj_drop_conf_data_filter(p_target_schema IN VARCHAR2) IS
   BEGIN

      -- Drop the procedure.
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_data_filter'
      );

   EXCEPTION
      WHEN OTHERS THEN
         trace_p('Removing data filter configuration procedure failure.');
         RAISE dpp_job_var.ge_injection_failed;

   END inj_drop_conf_data_filter;
      -- 
   /**
   * Drop the procedure that configures the data remaps.
   *
   * @throws dpp_job_var.ge_injection_failed: injection failure
   */
   PROCEDURE inj_drop_conf_data_remap(p_target_schema IN VARCHAR2) IS
   BEGIN

      -- Drop the procedure.
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_cfg_data_remap'
      );

   EXCEPTION
      WHEN OTHERS THEN
         trace_p('Removing data remap configuration procedure failure.');
         RAISE dpp_job_var.ge_injection_failed;

   END inj_drop_conf_data_remap;
      -- 
  PROCEDURE inj_drop_config_pump_file(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_config_pump_file');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_pump_file;
  --
  -- check
  --
  PROCEDURE inj_config_pump_file(p_target_schema IN VARCHAR2) IS
    l_parameters  g_med_variable_type;
    l_declare     g_med_variable_type;
    l_body        g_med_variable_type;
   BEGIN
      l_parameters   := 'p_job_number IN NUMBER, p_file_name  IN VARCHAR2';
      l_declare      := ' SPECFIED_MULTIPLE_TIMES EXCEPTION; ' ||'  PRAGMA EXCEPTION_INIT(SPECFIED_MULTIPLE_TIMES, -39051); ';
      l_body         := '  DBMS_DATAPUMP.add_file(handle    => p_job_number, ' ||
                        '                         filename  => p_file_name, ' ||
                        '                         directory => '''||UPPER(dpp_job_var.g_dpp_dir)||''',' ||
                        '                         filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE); ' ||
                        '  EXCEPTION ' ||
                        '    WHEN SPECFIED_MULTIPLE_TIMES THEN ' ||
                        '   NULL; ';   
      -- inject code into target schema
      create_procedure( p_schema       => p_target_schema,
                        p_proc_name    => 'dpump_config_pump_file',
                        p_proc_param   => l_parameters,
                        p_proc_declare => l_declare,
                        p_proc_body    => l_body);
   EXCEPTION
      WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

   END inj_config_pump_file;
  --
  -- check
  --
  PROCEDURE inj_drop_config_remap(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_config_remap');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_remap;
  -- check
  PROCEDURE inj_config_remap(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type := 'p_src_schema IN VArCHAR2, p_trg_schema IN VArCHAR2, p_job_number IN NUMBER';
    l_body       g_med_variable_type := '  DBMS_DATAPUMP.METADATA_REMAP(p_job_number, ' ||
                                   '                               ''REMAP_SCHEMA'',' ||
                                   '                               p_src_schema,' ||
                                   '                               p_trg_schema' ||
                                   '                               ); ';
  BEGIN
    -- inject code into target schema
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_config_remap',
                                p_proc_param   => l_parameters,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_config_remap;

  -- check
  PROCEDURE inj_drop_config_set_parallel(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_conf_set_parallel');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_set_parallel;
  -- check
  PROCEDURE inj_config_set_parallel(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type := 'p_job_number IN NUMBER, p_cpu_count IN NUMBER';
    l_body       g_med_variable_type := '  DBMS_DATAPUMP.set_parallel(handle => p_job_number, degree => p_cpu_count); ';
  BEGIN
    -- inject code into target schema
    --
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_conf_set_parallel',
                                p_proc_param   => l_parameters,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_config_set_parallel;
  -- check
  PROCEDURE inj_drop_create_import_job(p_target_shema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_shema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_create_import_job');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_create_import_job;

  -- check
  PROCEDURE inj_create_import_job(p_target_schema IN VARCHAR2
                                 ,p_db_link      IN VARCHAR2
                                 )
  IS
    l_declare    g_med_variable_type := ' l_job_number NUMBER; ';
    l_parameters g_med_variable_type := 'p_job_number OUT NUMBER';
    l_body       g_med_variable_type := '  l_job_number := DBMS_DATAPUMP.open(''IMPORT'', ' ||            --operation=>
                                   '                                     ''SCHEMA'', ' ||            --job_mode=>
                                   '                                     '''||p_db_link||''',' ||    --remote_link=> was NULL
                                   '                            ''DPUMP_IMP_TABLE'', ' ||
                                   '                            ''LATEST'', ' ||
                                   '    DBMS_DATAPUMP.KU$_COMPRESS_METADATA); ' ||
                                   '     p_job_number := l_job_number; ' ||
                                   '      EXCEPTION  ' ||
                                   '   WHEN DBMS_DATAPUMP.no_such_job THEN ' ||
                                   '     dpump_attatch_to_job(l_job_number, ''DPUMP_IMP_TABLE''); ' ||
                                   '     IF l_job_number is NULL THEN ' ||
                                   '       RAISE; ' || '     END IF; ' ||
                                   '     p_job_number := l_job_number; ' ||
                                   '  WHEN DBMS_DATAPUMP.job_exists THEN ' ||
                                   '     dpump_attatch_to_job(l_job_number, ''DPUMP_IMP_TABLE''); ' ||
                                   '     IF l_job_number IS NULL THEN ' ||
                                   '       RAISE; ' || '     END IF; ' ||
                                   '     p_job_number := l_job_number; ';
  BEGIN
    -- inject code into target schema
    --
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_create_import_job',
                                p_proc_param   => l_parameters,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;

  END inj_create_import_job;
  -- check
  PROCEDURE inj_drop_write_start_time(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_write_start_time');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_write_start_time;

  -- check
  PROCEDURE inj_write_start_time(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type := 'p_job_number IN NUMBER, p_start_time DATE';
    l_body       g_med_variable_type := '  DBMS_DATAPUMP.log_entry(handle => p_job_number,' ||
                                   '                          message => ''START TIME:'' ||TO_CHAR(p_start_time, ' ||
                                   '                                                      ''DD-MM-YYYY HH24:MI:SS''),' ||
                                   '                                                          log_file_only => 1);';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_write_start_time',
                                p_proc_param   => l_parameters,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_write_start_time;

  --check
  PROCEDURE inj_drop_create_export_job(p_target_schema IN VARCHAR2) IS
  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_create_export_job');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_create_export_job;

  -- check
  PROCEDURE inj_create_export_job(p_target_schema IN VARCHAR2) IS
    l_declare    g_med_variable_type := ' l_job_number NUMBER; ';
    l_parameters g_med_variable_type := ' p_job_number OUT NUMBER ';
    l_body       g_long_variable_type := ' l_job_number := DBMS_DATAPUMP.open(''EXPORT'',' ||
                                   '                                      ''SCHEMA'',' ||
                                   '                                          NULL,' ||
                                   '                              ''DPUMP_EXP_TABLE'',' ||
                                   '                                    ''LATEST'',' ||
                                   '          DBMS_DATAPUMP.KU$_COMPRESS_METADATA); ' ||
                                   '    p_job_number := l_job_number;  ' ||
                                   '  EXCEPTION ' ||
                                   '   WHEN DBMS_DATAPUMP.no_such_job THEN  ' ||
                                   '      dpump_attatch_to_job(l_job_number,''DPUMP_IMP_TABLE'');  ' ||
                                   '      IF l_job_number IS NULL THEN ' ||
                                   '        RAISE; ' || '      END IF; ' ||
                                   '      p_job_number := l_job_number; ' ||
                                   '   WHEN DBMS_DATAPUMP.job_exists THEN ' ||
                                   '      dpump_attatch_to_job(l_job_number,''DPUMP_IMP_TABLE''); ' ||
                                   '      IF l_job_number IS NULL THEN ' ||
                                   '         RAISE;' || '      END IF; ' ||
                                   '      p_job_number := l_job_number; ';

  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_create_export_job',
                                p_proc_param   => l_parameters,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_create_export_job;

  --check
  PROCEDURE inj_drop_config_estimate_stats(p_target_schema IN VARCHAR2) IS

  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_conf_estimate_stats');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_config_estimate_stats;

  -- check
  PROCEDURE inj_config_estimate_stats(p_target_schema IN VARCHAR2) IS
    l_parameters g_med_variable_type := 'p_job_number IN NUMBER';
    l_declare    g_med_variable_type := ' SPECFIED_MULTIPLE_TIMES EXCEPTION; PRAGMA EXCEPTION_INIT(SPECFIED_MULTIPLE_TIMES, -39051); ';
    l_body       g_long_variable_type := '   DBMS_DATAPUMP.set_parameter(handle => p_job_number, ' ||
                                   '                               name   => ''ESTIMATE'', ' ||
                                   '                               value  => ''STATISTICS''); ' ||
                                   '   EXCEPTION                                           ' ||
                                   '     WHEN SPECFIED_MULTIPLE_TIMES THEN                ' ||
                                   '       NULL;                                           ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_conf_estimate_stats',
                                p_proc_param   => l_parameters,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_config_estimate_stats;

  -- check
  PROCEDURE inj_drop_drop_exp_table(p_target_schema IN VARCHAR2) IS

  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_exp_table');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_exp_table;

  -- check
  PROCEDURE inj_drop_exp_table(p_target_schema IN VARCHAR2) IS

    l_body g_long_variable_type := ' EXECUTE IMMEDIATE ''DROP TABLE DPUMP_EXP_TABLE''; ' ||
                             ' EXCEPTION ' || ' WHEN OTHERS THEN ' ||
                             '   NULL;  ';
  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_exp_table',
                                p_proc_param   => NULL,
                                p_proc_declare => NULL,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_exp_table;

  -- check
  PROCEDURE inj_drop_AQ(p_target_schema IN VARCHAR2) IS

    l_parameters g_med_variable_type := 'p_target_schema IN VARCHAR2';
	l_declare g_med_variable_type := ' CURSOR c_qt(p_target_schema VARCHAR2) ' ||
									 ' IS ' ||
                                     ' SELECT DISTINCT queue_table ' ||
                                     '   FROM all_queues ' ||
                                     '   WHERE owner = p_target_schema; ' ||
                                     ' ' ||
									 ' CURSOR c_qn(p_target_schema VARCHAR2,p_queue_table VARCHAR2) ' ||
                                     ' IS ' ||
                                     ' SELECT name ' ||
                                     '   FROM all_queues ' ||
                                     '   WHERE owner = p_target_schema ' ||
                                     '     AND queue_table = p_queue_table ' ||
                                     '     AND queue_type = ''NORMAL_QUEUE''; ';

    l_body g_long_variable_type := ' FOR r_qt IN c_qt(p_target_schema) ' ||
								   ' LOOP ' ||
								   '	 FOR r_qn IN c_qn(p_target_schema,r_qt.queue_table) ' ||
								   '	 LOOP ' ||
								   '        DBMS_AQADM.STOP_QUEUE(queue_name => p_target_schema||''.''||r_qn.name,enqueue=>TRUE,dequeue=>TRUE); ' ||
								   '        DBMS_AQADM.DROP_QUEUE(queue_name => p_target_schema||''.''||r_qn.name); ' || 
								   '	 END LOOP; ' ||
								   ' DBMS_AQADM.DROP_QUEUE_TABLE(queue_table => p_target_schema||''.''||r_qt.queue_table,force=>FALSE); ' ||
								   ' END LOOP; ';

  BEGIN
       create_procedure(p_schema       => p_target_schema,
                                p_proc_name    => 'dpump_drop_AQ',
                                p_proc_param   => l_parameters,
                                p_proc_declare => l_declare,
                                p_proc_body    => l_body);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_AQ;

  -- check
  PROCEDURE inj_drop_drop_AQ(p_target_schema IN VARCHAR2) IS

  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_drop_AQ');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_drop_AQ;

  PROCEDURE inj_drop_dpump_stop_all_jobs(p_target_schema IN VARCHAR2) IS

  BEGIN
    /*dc_dba_mgmt_drop_object*/drop_object(p_schema      => p_target_schema,
                            p_object_type => 'PROCEDURE',
                            p_object_name => 'dpump_stop_all_jobs');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_drop_dpump_stop_all_jobs;

  PROCEDURE inj_dpump_stop_all_jobs(p_target_schema IN VARCHAR2) IS

    l_body g_long_variable_type := ' FOR IREC IN (SELECT * FROM USER_JOBS) LOOP ' ||
                             '   DBMS_JOB.remove(IREC.JOB); ' ||
                             ' END LOOP; ';
  BEGIN
     create_procedure(p_schema       => p_target_schema
                     ,p_proc_name    => 'dpump_stop_all_jobs'
                     ,p_proc_param   => NULL
                     ,p_proc_declare => NULL
                     ,p_proc_body    => l_body
                     );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE dpp_job_var.ge_injection_failed;
  END inj_dpump_stop_all_jobs;

  PROCEDURE inj_checks_for_imp(p_schema_name IN VARCHAR2) IS
  BEGIN
    inj_check_dir_object(p_schema_name);
    inj_check_privs(p_schema_name);
  END inj_checks_for_imp;

  PROCEDURE inj_drop_checks_for_imp(p_schema_name IN VARCHAR2) IS
  BEGIN
    inj_drop_check_dir_object(p_schema_name);
    inj_drop_check_privs(p_schema_name);

  END inj_drop_checks_for_imp;

  PROCEDURE inj_drop_checks_for_exp(p_schema_name IN VARCHAR2) IS
  BEGIN
    inj_drop_check_dir_object(p_schema_name);
    inj_drop_check_privs(p_schema_name);

  END inj_drop_checks_for_exp;

  PROCEDURE inj_checks_for_exp(p_schema_name IN VARCHAR2) IS
  BEGIN
    inj_check_dir_object(p_schema_name);
    inj_check_privs(p_schema_name);
  END inj_checks_for_exp;

   /**
   * Inject the code that removes the stored procedure that checks whether a
   * database link is valid.
   *
   * @param p_target_schema: target database schema
   * @throws dpp_job_var.ge_injection_failed: code injection failure
   */
   PROCEDURE inj_drop_check_db_link(
      p_target_schema      IN VARCHAR2
   ) IS
   BEGIN
      drop_object(
         p_schema       => p_target_schema
       , p_object_type  => 'PROCEDURE'
       , p_object_name  => 'dpump_conf_check_db_link'
      );
   EXCEPTION   
      WHEN OTHERS THEN
         RAISE dpp_job_var.ge_injection_failed;
   END inj_drop_check_db_link;

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
   ) IS

      -- variable declaration
      l_variables       g_med_variable_type  := 'l_val VARCHAR2(10); ';

      -- stored procedure body
      l_body            g_med_variable_type :=
         'EXECUTE IMMEDIATE '''
      || '   SELECT * FROM DUAL@' || p_db_link_name
      || ''' '
      || 'INTO l_val;';
      
   BEGIN

      create_procedure(
         p_schema             => p_target_schema
       , p_proc_name          => 'dpump_conf_check_db_link'
       , p_proc_declare       => l_variables
       , p_proc_body          => l_body
      );

   EXCEPTION
      WHEN OTHERS THEN  
         RAISE dpp_job_var.ge_injection_failed;

   END;
  
BEGIN
   NULL;
END dpp_inj_krn;
/
