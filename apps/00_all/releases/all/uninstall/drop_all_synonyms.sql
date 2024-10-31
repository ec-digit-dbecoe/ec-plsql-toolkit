PROMPT Dropping all synonyms...
DECLARE
   l_expose_pattern dbm_utility_var.g_par_value_type;
   l_expose_anti_pattern dbm_utility_var.g_par_value_type;
   CURSOR c_obj IS
      SELECT obj.object_type, LOWER(obj.object_name) object_name, syn.owner grantee
        FROM user_objects obj
       INNER JOIN all_synonyms syn
          ON syn.synonym_name = obj.object_name
         AND table_owner = USER
       WHERE REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_pattern)
         AND NOT REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_anti_pattern)
       ORDER BY 3, 1, 2
      ;
   l_sql VARCHAR2(4000);
   l_raise_exception BOOLEAN := FALSE;
   l_count PLS_INTEGER := 0;
BEGIN
   l_expose_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_pattern');
   IF l_expose_pattern IS NULL THEN
      RETURN;
   END IF;
   l_expose_anti_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_anti_pattern', '^$');
   FOR r_obj IN c_obj LOOP
      IF r_obj.grantee = 'PUBLIC' THEN
         l_sql := 'DROP PUBLIC SYNONYM '||r_obj.object_name;
      ELSE
         l_sql := 'DROP SYNONYM '||r_obj.grantee || '.' ||r_obj.object_name;
      END IF;
      dbms_output.put_line(l_sql);
      BEGIN
         EXECUTE IMMEDIATE l_sql;
         l_count := l_count + 1;
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
            l_raise_exception := TRUE;
      END;
   END LOOP;
   dbms_output.put_line(l_count||' synonyms dropped');
   IF l_raise_exception THEN
      raise_application_error(-20000,'Error while dropping some synonyms!');
   END IF;
END;
/