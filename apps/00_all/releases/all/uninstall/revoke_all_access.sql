PROMPT Revoking all access privileges...
DECLARE
   l_expose_pattern dbm_utility_var.g_par_value_type;
   l_expose_anti_pattern dbm_utility_var.g_par_value_type;
   CURSOR c_obj IS
      SELECT DISTINCT obj.object_type, LOWER(obj.object_name) object_name, grt.grantee
        FROM user_objects obj
       INNER JOIN user_tab_privs grt
          ON grt.owner = USER
         AND grt.grantor = USER
         AND grt.table_name = obj.object_name
       WHERE REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_pattern)
         AND NOT REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_anti_pattern)
         AND NOT REGEXP_LIKE (obj.object_name, '^DBM_') -- to avoid "ERROR-04068: Existing state of packages has been discarded"
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
   l_raise_exception BOOLEAN := FALSE;
   l_count PLS_INTEGER := 0;
   l_warn BOOLEAN := TRUE;
BEGIN
   l_expose_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_pattern');
   IF l_expose_pattern IS NULL THEN
      RETURN;
   END IF;
   l_expose_anti_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_anti_pattern', '^$');
   FOR r_obj IN c_obj LOOP
      IF '&&app_code' = 'dbm_utility' AND l_warn THEN
         l_warn := FALSE;
         dbms_output.put_line('WARNING: dbm_utility cannot revoke access rights on itself while running!');
      END IF;
      l_sql := 'REVOKE ALL ON '|| r_obj.object_name || ' FROM ' || r_obj.grantee;
      BEGIN
         IF '&&app_code' = 'dbm_utility' THEN
            dbms_output.put_line(l_sql||' /*execute manually!*/;');
         ELSE
            dbms_output.put_line(l_sql||';');
            EXECUTE IMMEDIATE l_sql;
         END IF;
         l_count := l_count + 1;
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
            l_raise_exception := TRUE;
      END;
   END LOOP;
   IF '&&app_code' = 'dbm_utility' THEN
      dbms_output.put_line('WARNING: '||l_count||' access rights NOT revoked!');
   ELSE
      dbms_output.put_line(l_count||' access rights revoked');
   END IF;
   IF l_raise_exception THEN
      raise_application_error(-20000,'Error while revoking some access rights!');
   END IF;
END;
/