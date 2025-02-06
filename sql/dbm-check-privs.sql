set serveroutput on size 999999
DECLARE
   ---
   -- Check privileges (code extracted from dbm_utility_krn then adapted)
   ---
   PROCEDURE check_privileges (
--      pr_cmd dbm_utility_var.gr_command_type
      p_app_code VARCHAR2
    , p_ver_code VARCHAR2
    , p_usage VARCHAR2
    , p_nostop BOOLEAN := FALSE
   )
   IS
      -- Cursor to fetch required privileges
      CURSOR c_prv (
         p_app_code VARCHAR2
       , p_ver_code VARCHAR2
       , p_usage VARCHAR2
       , p_type VARCHAR2
      )
      IS
         WITH input_data AS (
             -- Configuration extracted from: apps\05_dbm_utility\releases\ALL\config\privileges.dbm
             SELECT 'MIGRATE;ROLEPRIV;CONNECT 
                     MIGRATE;SYSPRIV;CREATE PROCEDURE 
                     MIGRATE;SYSPRIV;CREATE SEQUENCE 
                     MIGRATE;SYSPRIV;CREATE TABLE 
                     MIGRATE;SYSPRIV;CREATE VIEW 
                     MIGRATE;SYSPRIV;CREATE TYPE 
                     MIGRATE;SYSPRIV;SELECT ANY DICTIONARY' AS raw_text 
             FROM DUAL
         )
         SELECT 'dbm_utility' app_code, 'all' ver_code, text, usage, type, text name
              , '' direct_flag, '' object_owner, '' object_type
              , '' object_name, '' delegable, '' condition
              , '' deleted_flag
           FROM (
               SELECT 
                   REGEXP_SUBSTR(TRIM(line), '[^;]+', 1, 1) AS usage,
                   REGEXP_SUBSTR(TRIM(line), '[^;]+', 1, 2) AS type,
                   REGEXP_SUBSTR(TRIM(line), '[^;]+', 1, 3) AS text
               FROM (
                   SELECT TRIM(REGEXP_SUBSTR(raw_text, '[^'||CHR(10)||']+', 1, LEVEL)) AS line
                   FROM input_data
                   CONNECT BY LEVEL <= REGEXP_COUNT(raw_text, CHR(10)) + 1
               )
           )
          WHERE usage = p_usage
            AND type = p_type
          ORDER BY type, text
      ;
      -- Cursor to fetch missing system privileges
      CURSOR c_sys_prv (
         p_privs IN VARCHAR2
      )
      IS
         SELECT REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) AS privilege
           FROM dual
        CONNECT BY REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) IS NOT NULL
          MINUS (
         SELECT privilege || ' WITH ADMIN OPTION' AS privilege
           FROM sys.user_sys_privs
          WHERE username IN (USER, 'PUBLIC')
            AND admin_option = 'YES'
          UNION
         SELECT privilege
           FROM sys.user_sys_privs
          WHERE username IN (USER, 'PUBLIC')
          UNION
         SELECT 'DIRECT ' || privilege || ' WITH ADMIN OPTION' AS privilege
           FROM sys.user_sys_privs
          WHERE username IN (USER, 'PUBLIC')
            AND admin_option = 'YES'
            AND inherited = 'NO'
          UNION
         SELECT 'DIRECT ' || privilege
           FROM sys.user_sys_privs
          WHERE username IN (USER, 'PUBLIC')
            AND inherited = 'NO'
          UNION
         SELECT rsp.privilege || ' WITH ADMIN OPTION' AS privilege
           FROM role_sys_privs rsp
          INNER JOIN user_role_privs urp
             ON username IN (USER, 'PUBLIC')
            AND urp.granted_role = rsp.role
          WHERE rsp.admin_option = 'YES'
          UNION
         SELECT rsp.privilege
           FROM role_sys_privs rsp
          INNER JOIN user_role_privs urp
             ON username IN (USER, 'PUBLIC')
            AND urp.granted_role = rsp.role
         )
          ORDER BY 1;
      -- Cursor to fetch missing role privileges
      CURSOR c_rol_prv (
         p_privs IN VARCHAR2
      )
      IS
         SELECT REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) privilege
           FROM dual
        CONNECT BY REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) IS NOT NULL
          MINUS (
         SELECT granted_role || ' WITH ADMIN OPTION' AS privilege
           FROM sys.user_role_privs
          WHERE username IN (USER, 'PUBLIC')
            AND admin_option = 'YES'
          UNION
         SELECT granted_role AS privilege
           FROM sys.user_role_privs
          WHERE username IN (USER, 'PUBLIC')
          UNION
         SELECT 'DIRECT ' ||granted_role || ' WITH ADMIN OPTION' AS privilege
           FROM sys.user_role_privs
          WHERE username IN (USER, 'PUBLIC')
            AND admin_option = 'YES'
            AND inherited = 'NO'
          UNION
         SELECT 'DIRECT ' ||granted_role AS privilege
           FROM sys.user_role_privs
          WHERE username IN (USER, 'PUBLIC')
            AND inherited = 'NO'
          UNION
         SELECT rrp.granted_role || ' WITH ADMIN OPTION' AS privilege
           FROM role_role_privs rrp
          INNER JOIN user_role_privs urp
             ON urp.username IN (USER, 'PUBLIC')
            AND urp.granted_role = rrp.role
          WHERE rrp.admin_option = 'YES'
          UNION
         SELECT rrp.granted_role
           FROM role_role_privs rrp
          INNER JOIN user_role_privs urp
             ON urp.username IN (USER, 'PUBLIC')
            AND urp.granted_role = rrp.role
         )
          ORDER BY 1;
      -- Cursor to fetch missing table privileges
      CURSOR c_tab_prv(
         p_privs IN VARCHAR2
      )
      IS
         SELECT REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) privilege
           FROM dual
        CONNECT BY REGEXP_SUBSTR(p_privs,'[^,]+', 1, level) IS NOT NULL
          MINUS (
         SELECT privilege || ' ON ' || owner || '.' || table_name || ' WITH GRANT OPTION' AS privilege
           FROM sys.user_tab_privs
          WHERE grantee IN (USER, 'PUBLIC')
            AND grantable = 'YES'
          UNION
         SELECT privilege || ' ON ' || owner || '.' || table_name AS privilege
           FROM sys.user_tab_privs
          WHERE grantee IN (USER, 'PUBLIC')
          UNION
         SELECT 'DIRECT ' || privilege || ' ON ' || owner || '.' || table_name || ' WITH GRANT OPTION' AS privilege
           FROM sys.user_tab_privs
          WHERE grantee IN (USER, 'PUBLIC')
            AND grantable = 'YES'
            AND inherited = 'NO'
          UNION
         SELECT 'DIRECT ' || privilege || ' ON ' || owner || '.' || table_name AS privilege
           FROM sys.user_tab_privs
          WHERE grantee IN (USER, 'PUBLIC')
            AND inherited = 'NO'
          UNION
         SELECT rtp.privilege || ' ON ' || owner || '.' || table_name || ' WITH GRANT OPTION' AS privilege
           FROM sys.role_tab_privs rtp
          INNER JOIN user_role_privs urp
             ON urp.username IN (USER, 'PUBLIC')
            AND urp.granted_role = rtp.role
            AND grantable = 'YES'
          UNION
         SELECT rtp.privilege || ' ON ' || owner || '.' || table_name AS privilege
           FROM sys.role_tab_privs rtp
          INNER JOIN user_role_privs urp
             ON urp.username IN (USER, 'PUBLIC')
            AND urp.granted_role = rtp.role
         )
          ORDER BY 1;
      SUBTYPE g_priv_type IS VARCHAR2(100);
      TYPE gt_prv_type IS TABLE OF c_prv%ROWTYPE INDEX BY BINARY_INTEGER;
      TYPE ga_prv_type IS TABLE OF c_prv%ROWTYPE INDEX BY VARCHAR2(400 CHAR);
      TYPE ga_priv_type IS TABLE OF g_priv_type INDEX BY g_priv_type;
      t_prv gt_prv_type;
      r_prv c_prv%ROWTYPE;
      l_prv_type VARCHAR2(30 CHAR);
      l_prv_desc VARCHAR2(10);
      TYPE la_cond_res_type IS TABLE OF BOOLEAN INDEX BY VARCHAR2(400 CHAR);
      TYPE la_priv_res_type IS TABLE OF BOOLEAN INDEX BY VARCHAR2(400 CHAR);
      la_cond_res la_cond_res_type;
      la_priv_res la_priv_res_type;
      ga_any_sys_priv ga_priv_type;
      ga_any_tab_priv ga_priv_type;
      l_privs VARCHAR2(4000);
      l_prv_idx PLS_INTEGER;
      l_err_count PLS_INTEGER := 0;
      l_err_msg VARCHAR2(80);
      l_verbose BOOLEAN := TRUE;
      l_silent BOOLEAN := FALSE;
      l_text VARCHAR2(400 CHAR);
      l_first BOOLEAN := TRUE;
      la_any_priv ga_priv_type; -- any privileges
      la_any_priv_admin ga_priv_type; -- any privileges with admin option
      la_nan_priv ga_priv_type; -- not any privileges
      l_types VARCHAR2(200);
      l_pos PLS_INTEGER;
      l_missing_privs VARCHAR2(4000 CHAR);
      PROCEDURE print_line (
         p_text IN VARCHAR2 -- message to display
       , p_priv IN VARCHAR2 := NULL -- missing privilege
      )
      IS
      BEGIN
         IF p_priv IS NOT NULL THEN
            l_missing_privs := CASE WHEN l_missing_privs IS NOT NULL THEN l_missing_privs || ', ' END || p_priv;
         END IF;
         IF NOT l_silent THEN
            dbms_output.put_line(p_text);
         END IF;
      END;
      PROCEDURE init_privileges IS
      BEGIN
         -- Initialise ANY system privileges
         ga_any_sys_priv('ALTER ANY TABLE') := '';
         ga_any_sys_priv('ANALYZE ANY') := '';
         ga_any_sys_priv('DELETE ANY TABLE') := '';
         ga_any_sys_priv('INSERT ANY TABLE') := '';
         ga_any_sys_priv('LOCK ANY TABLE') := '';
         ga_any_sys_priv('SELECT ANY TABLE') := '';
         ga_any_sys_priv('UPDATE ANY TABLE') := '';
         ga_any_sys_priv('ALTER ANY INDEX') := '';
         ga_any_sys_priv('DROP ANY INDEX') := '';
         ga_any_sys_priv('CREATE ANY VIEW') := '';
         ga_any_sys_priv('DROP ANY VIEW') := '';
         ga_any_sys_priv('EXECUTE ANY PROCEDURE') := '';
         ga_any_sys_priv('CREATE ANY PROCEDURE') := '';
         ga_any_sys_priv('ALTER ANY PROCEDURE') := '';
         ga_any_sys_priv('DROP ANY PROCEDURE') := '';
         ga_any_sys_priv('CREATE ANY TRIGGER') := '';
         ga_any_sys_priv('ALTER ANY TRIGGER') := '';
         ga_any_sys_priv('DROP ANY TRIGGER') := '';
         ga_any_sys_priv('CREATE ANY SEQUENCE') := '';
         ga_any_sys_priv('ALTER ANY SEQUENCE') := '';
         ga_any_sys_priv('DROP ANY SEQUENCE') := '';
         ga_any_sys_priv('CREATE ANY MATERIALIZED VIEW') := '';
         ga_any_sys_priv('ALTER ANY MATERIALIZED VIEW') := '';
         ga_any_sys_priv('DROP ANY MATERIALIZED VIEW') := '';
         ga_any_sys_priv('CREATE ANY LIBRARY') := '';
         ga_any_sys_priv('ALTER ANY LIBRARY') := '';
         ga_any_sys_priv('DROP ANY LIBRARY') := '';
         ga_any_sys_priv('CREATE ANY DIRECTORY') := '';
         ga_any_sys_priv('DROP ANY DIRECTORY') := '';
         ga_any_sys_priv('CREATE ANY USER') := '';
         ga_any_sys_priv('ALTER ANY USER') := '';
         ga_any_sys_priv('DROP ANY USER') := '';
         ga_any_sys_priv('GRANT ANY ROLE') := '';
         ga_any_sys_priv('COMMENT ANY TABLE') := '';
         ga_any_sys_priv('FLASHBACK ANY TABLE') := '';
         ga_any_sys_priv('AUDIT ANY') := '';
         ga_any_sys_priv('BECOME ANY USER') := '';
         ga_any_sys_priv('CREATE ANY CONTEXT') := '';
         ga_any_sys_priv('CREATE ANY DIMENSION') := '';
         ga_any_sys_priv('ALTER ANY DIMENSION') := '';
         ga_any_sys_priv('DROP ANY DIMENSION') := '';
         ga_any_sys_priv('CREATE ANY OUTLINE') := '';
         ga_any_sys_priv('ALTER ANY OUTLINE') := '';
         ga_any_sys_priv('DROP ANY OUTLINE') := '';
         ga_any_sys_priv('MANAGE ANY QUEUE') := '';
         ga_any_sys_priv('UNDER ANY TABLE') := '';
         ga_any_sys_priv('UNDER ANY TYPE') := '';
         -- Initialise ANY tables privileges
         ga_any_tab_priv('SELECT ANY TABLE') := 'TABLE, VIEW, MVIEW, SEQUENCE';
         ga_any_tab_priv('INSERT ANY TABLE') := 'TABLE, VIEW';
         ga_any_tab_priv('UPDATE ANY TABLE') := 'TABLE, VIEW';
         ga_any_tab_priv('DELETE ANY TABLE') := 'TABLE, VIEW';
         ga_any_tab_priv('ALTER ANY TABLE') := 'TABLE, VIEW';
         ga_any_tab_priv('INDEX ANY TABLE') := 'TABLE';
         ga_any_tab_priv('REFERENCES ANY TABLE') := 'TABLE';
         ga_any_tab_priv('EXECUTE ANY PROCEDURE') := 'PACKAGE, PROCEDURE, FUNCTION, TYPE';
         ga_any_tab_priv('ALTER ANY SEQUENCE') := 'SEQUENCE';
      END;
   BEGIN
      init_privileges;
      FOR k IN 1..3 LOOP
         l_prv_type := CASE k WHEN 1 THEN 'SYSPRIV' WHEN 2 THEN 'ROLEPRIV' ELSE 'TABPRIV' END;
         l_prv_desc := CASE k WHEN 1 THEN 'system' WHEN 2 THEN 'role' ELSE 'table' END;
         -- Fetch all privileges of given type
         OPEN c_prv(p_app_code, p_ver_code, p_usage, l_prv_type);
         FETCH c_prv BULK COLLECT INTO t_prv;
         CLOSE c_prv;
         IF t_prv.COUNT = 0 THEN
            GOTO next_prv_type;
         END IF;
         IF l_first THEN
            l_first := FALSE;
            print_line('Checking required privileges of application "'||p_app_code||'" version "'||p_ver_code||'"...');
         END IF;
         IF l_prv_type IN ('SYSPRIV','TABPRIV') THEN
            -- Make a list of ANY privileges + a list of ANY privileges WITH ADMIN OPTION
            l_privs := NULL;
            la_any_priv := CASE WHEN l_prv_type = 'SYSPRIV' THEN ga_any_sys_priv ELSE ga_any_tab_priv END;
            la_any_priv_admin.DELETE;
            l_text := la_any_priv.FIRST;
            WHILE l_text IS NOT NULL LOOP
               l_privs := l_privs || CASE WHEN l_privs IS NOT NULL THEN ',' END || l_text;
               la_any_priv_admin(l_text||' WITH ADMIN OPTION') := la_any_priv(l_text);
               l_text := la_any_priv.NEXT(l_text);
            END LOOP;
            -- Add list of privileges for WITH ADMIN OPTION
            l_text := la_any_priv_admin.FIRST;
            WHILE l_text IS NOT NULL LOOP
               l_privs := l_privs || CASE WHEN l_privs IS NOT NULL THEN ',' END || l_text;
               la_any_priv(l_text) := la_any_priv_admin(l_text);
               l_text := la_any_priv_admin.NEXT(l_text);
            END LOOP;
            la_any_priv_admin.DELETE;
            -- Delete those not delegated to current user (so remains those delegated to current user)
            FOR r_prv IN c_sys_prv(l_privs) LOOP
               la_any_priv.DELETE(r_prv.privilege);
            END LOOP;
            -- Build list of remaining non-ANY system privileges (not to be checked)
            l_text := la_any_priv.FIRST;
            WHILE l_text IS NOT NULL LOOP
               IF l_prv_type = 'SYSPRIV' THEN
                  la_nan_priv(TRIM(REGEXP_REPLACE(l_text,'\s*ANY\s*',' '))) := l_text;
               ELSE
                  l_types := la_any_priv(l_text)||',';
                  LOOP
                     l_pos := NVL(INSTR(l_types,','),0);
                     EXIT WHEN l_pos = 0;
                     la_nan_priv(TRIM(REGEXP_REPLACE(l_text,'\s*ANY.*',' '))||' '||TRIM(SUBSTR(l_types,1,l_pos-1))) := l_text;
                     l_types := TRIM(SUBSTR(l_types,l_pos+1));
                  END LOOP;
               END IF;
               l_text := la_any_priv.NEXT(l_text);
            END LOOP;
         END IF;
         -- Make a comma separated list of privileges
         l_privs := NULL;
         la_priv_res.DELETE;
         l_prv_idx := t_prv.FIRST;
         WHILE l_prv_idx IS NOT NULL LOOP
            r_prv := t_prv(l_prv_idx);
            la_priv_res(r_prv.text) := FALSE;
            l_text := CASE WHEN l_prv_type='TABPRIV' THEN r_prv.name||' '||r_prv.object_type ELSE r_prv.text END;
            IF l_prv_type IN ('SYSPRIV','TABPRIV') AND la_nan_priv.EXISTS(l_text)
            THEN
               IF l_verbose THEN
                  print_line('Info: '||l_prv_desc||' privilege "'||r_prv.text||'" is granted through "'||la_nan_priv(l_text)||'"');
               END IF;
            ELSE
               l_privs := l_privs || CASE WHEN l_privs IS NOT NULL THEN ',' END || r_prv.text;
            END IF;
            l_prv_idx := t_prv.NEXT(l_prv_idx);
         END LOOP;
         IF l_privs IS NULL THEN
            GOTO next_prv_type;
         END IF;
         -- Fetch missing privileges/roles
         IF l_prv_type = 'SYSPRIV' THEN
            FOR r_prv IN c_sys_prv(l_privs) LOOP
               la_priv_res(r_prv.privilege) := TRUE;
               l_err_count := l_err_count + 1;
            END LOOP;
         ELSIF l_prv_type = 'ROLEPRIV' THEN
            FOR r_prv IN c_rol_prv(l_privs) LOOP
               la_priv_res(r_prv.privilege) := TRUE;
               l_err_count := l_err_count + 1;
            END LOOP;
         ELSIF l_prv_type = 'TABPRIV' THEN
            FOR r_prv IN c_tab_prv(l_privs) LOOP
               la_priv_res(r_prv.privilege) := TRUE;
               l_err_count := l_err_count + 1;
            END LOOP;
         END IF;
         -- Reporting missing privileges
         l_text := la_priv_res.FIRST;
         WHILE l_text IS NOT NULL LOOP
            IF la_priv_res(l_text) THEN
               print_line('ERROR: '||l_prv_desc||' privilege "'||l_text||'" is missing to '||USER||'!', l_text);
            END IF;
            l_text := la_priv_res.NEXT(l_text);
         END LOOP;
         -- Reporting existing privileges
         IF l_verbose THEN
            l_text := la_priv_res.FIRST;
            WHILE l_text IS NOT NULL LOOP
               IF NOT la_priv_res(l_text) THEN
                  print_line('Info: '||l_prv_desc||' privilege "'||l_text||'" is well granted to '||USER);
               END IF;
               l_text := la_priv_res.NEXT(l_text);
            END LOOP;
         END IF;
         <<next_prv_type>>
         NULL;
      END LOOP;
      IF l_err_count > 0 THEN
         IF l_err_count = 1 THEN
            l_err_msg := l_err_count ||' privilege required for application "'||p_app_code||'" is missing!';
         ELSE
            l_err_msg := l_err_count ||' privileges required for application "'||p_app_code||'" are missing!';
         END IF;
         IF p_nostop THEN
            print_line('Error: '|| l_err_msg);
         ELSE
            raise_application_error(-20000, 'Error: Missing runtime privileges: '||l_missing_privs);
         END IF;
      END IF;
   END;
BEGIN
   check_privileges('dbm_utility','all','MIGRATE');
END;
/
