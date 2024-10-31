PROMPT Dropping database objects...
DECLARE
   CURSOR c_obj IS
      SELECT object_type, object_name
           , CASE WHEN object_type = 'TABLE' THEN ' CASCADE CONSTRAINTS' END drop_type
        FROM user_objects
       WHERE REGEXP_LIKE(object_name, '^GEN_')
         AND object_type IN ('CONSTRAINT','PACKAGE','TABLE','SEQUENCE','VIEW')
       ORDER BY 1, LENGTH(object_name) DESC, 2
      ;
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_obj IN c_obj LOOP
      l_sql := 'DROP '||r_obj.object_type||' '||LOWER(r_obj.object_name)||r_obj.drop_type;
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
