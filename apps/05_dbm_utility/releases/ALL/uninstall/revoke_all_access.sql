PROMPT Revoking all access privileges...
DECLARE
   CURSOR c_obj IS
      SELECT obj.object_type, LOWER(obj.object_name) object_name, grt.privilege, grt.grantee
        FROM user_objects obj
       INNER JOIN user_tab_privs grt
          ON grt.owner = USER
         AND grt.grantor = USER
         AND grt.table_name = obj.object_name
       WHERE REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, '^PACKAGE DBM_UTILITY_')
       ORDER BY 1, 2
      ;
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_obj IN c_obj LOOP
      l_sql := 'REVOKE '|| r_obj.privilege ||' ON '|| r_obj.object_name || ' FROM ' || r_obj.grantee;
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