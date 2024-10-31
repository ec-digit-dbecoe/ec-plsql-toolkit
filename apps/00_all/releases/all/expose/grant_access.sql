PROMPT Granting access privileges to "&&grantee"...
DECLARE
   l_expose_pattern dbm_utility_var.g_par_value_type;
   l_expose_anti_pattern dbm_utility_var.g_par_value_type;
   l_expose_read_only_pattern dbm_utility_var.g_par_value_type;
   CURSOR c_obj IS
      SELECT DISTINCT obj.object_type, obj.object_name object_name
        FROM user_objects obj
        LEFT OUTER JOIN user_tab_privs grt
          ON grt.owner = USER
         AND grt.grantor = USER
         AND grt.grantee = NVL(UPPER('&&grantee'),'PUBLIC')
         AND grt.table_name = obj.object_name
       WHERE REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_pattern)
         AND NOT REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_anti_pattern)
         AND grt.table_name IS NULL -- privs not granted yet
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
   l_raise_exception BOOLEAN := FALSE;
   l_count PLS_INTEGER := 0;
BEGIN
   l_expose_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_pattern');
   l_expose_read_only_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_read_only_pattern');
   IF l_expose_pattern IS NULL THEN
      dbms_output.put_line('No database object to expose.');
      RETURN;
   END IF;
   l_expose_anti_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_anti_pattern', '^$');
   FOR r_obj IN c_obj LOOP
      l_sql := 'GRANT '
             || CASE 
                WHEN r_obj.object_name LIKE 'DBM_ALL%' AND r_obj.object_type = 'VIEW' THEN 'SELECT'
                WHEN r_obj.object_type IN ('TABLE','VIEW') THEN
                     CASE WHEN REGEXP_LIKE(r_obj.object_type||' '||r_obj.object_name, l_expose_read_only_pattern)
                     THEN 'SELECT'
                     ELSE 'SELECT, INSERT, UPDATE, DELETE'
                      END
                WHEN r_obj.object_type = 'SEQUENCE' THEN 'SELECT'
                WHEN r_obj.object_type IN ('PACKAGE','PROCEDURE','FUNCTION') THEN 'EXECUTE'
                 END
             ||' ON '||LOWER(r_obj.object_name) || ' TO '||NVL(UPPER('&&grantee'),'PUBLIC');
      dbms_output.put_line(l_sql||';');
      BEGIN
         EXECUTE IMMEDIATE l_sql;
         l_count := l_count + 1;
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
            l_raise_exception := TRUE;
      END;
   END LOOP;
   dbms_output.put_line(l_count||' access rights granted');
   IF l_raise_exception THEN
      raise_application_error(-20000,'Error while granting some access rights!');
   END IF;
END;
/