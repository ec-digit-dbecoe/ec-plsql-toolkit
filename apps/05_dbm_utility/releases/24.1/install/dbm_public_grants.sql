PROMPT Granting privileges to PUBLIC...
DECLARE
   CURSOR c_obj IS
      SELECT obj.object_type, LOWER(obj.object_name) object_name
        FROM user_objects obj
        LEFT OUTER JOIN user_tab_privs grt
          ON grt.owner = USER
         AND grt.grantor = USER
         AND grt.grantee = 'PUBLIC'
         AND grt.table_name = obj.object_name
       WHERE obj.object_type IN ('TABLE','PACKAGE')
         AND SUBSTR(obj.object_name,1,4) = 'DBM_'
         AND grt.table_name IS NULL -- public privs not granted yet
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_obj IN c_obj LOOP
      l_sql := 'GRANT '
             || CASE r_obj.object_type
                WHEN 'TABLE' THEN 'SELECT, INSERT, UPDATE, DELETE'
                WHEN 'PACKAGE' THEN 'EXECUTE'
                 END
             ||' ON '||r_obj.object_name || ' TO PUBLIC';
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
