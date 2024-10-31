PROMPT Creating public synonyms...
DECLARE
   CURSOR c_obj IS
      SELECT obj.object_type, LOWER(obj.object_name) object_name
        FROM user_objects obj
        LEFT OUTER JOIN all_synonyms syn
          ON syn.owner = 'PUBLIC'
         AND syn.synonym_name = obj.object_name
       WHERE SUBSTR(obj.object_name,1,4) = 'DBM_'
         AND obj.object_type IN ('TABLE','PACKAGE')
         AND syn.synonym_name IS NULL -- public synonym not existing
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_obj IN c_obj LOOP
      l_sql := 'CREATE PUBLIC SYNONYM '||r_obj.object_name||' FOR '||r_obj.object_name;
      dbms_output.put_line(l_sql);
      BEGIN
         EXECUTE IMMEDIATE l_sql;
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
   END LOOP;
END;
/
