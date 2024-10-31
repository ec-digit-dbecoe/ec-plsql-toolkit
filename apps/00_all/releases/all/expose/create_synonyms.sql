PROMPT Creating synonyms for "&&grantee"...
DECLARE
   l_expose_pattern dbm_utility_var.g_par_value_type;
   l_expose_anti_pattern dbm_utility_var.g_par_value_type;
   CURSOR c_obj IS
      SELECT obj.object_type, LOWER(obj.object_name) object_name
        FROM user_objects obj
        LEFT OUTER JOIN all_synonyms syn
          ON syn.owner = NVL(UPPER('&&grantee'),'PUBLIC')
         AND syn.synonym_name = obj.object_name
         AND syn.table_owner = USER
       WHERE REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_pattern)
         AND NOT REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, l_expose_anti_pattern)
         AND syn.synonym_name IS NULL -- public synonym not existing
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
   l_raise_exception BOOLEAN := FALSE;
   l_count PLS_INTEGER := 0;
BEGIN
   l_expose_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_pattern');
   IF l_expose_pattern IS NULL THEN
      dbms_output.put_line('No database object to expose.');
      RETURN;
   END IF;
   l_expose_anti_pattern := dbm_utility_krn.get_par_value('&&app_code', '&&ver_nbr', 'expose_anti_pattern', '^$');
   FOR r_obj IN c_obj LOOP
      IF NVL(UPPER('&&grantee'),'PUBLIC') = 'PUBLIC' THEN
         l_sql := 'CREATE PUBLIC SYNONYM '||r_obj.object_name||' FOR '||r_obj.object_name;
      ELSE
         l_sql := 'CREATE SYNONYM '||UPPER('&&grantee')||'.'||r_obj.object_name||' FOR '||r_obj.object_name;
      END IF;
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
   dbms_output.put_line(l_count||' synonyms created');
   IF l_raise_exception THEN
      raise_application_error(-20000,'Error while creating some synonyms!');
   END IF;
END;
/
