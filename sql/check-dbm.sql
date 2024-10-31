set feedback off
whenever sqlerror exit sql.sqlcode rollback;
DECLARE
   -- Check the status of any global installation
   CURSOR c_pub IS
      SELECT obj.status, COUNT(*)
        FROM all_synonyms syn
       INNER JOIN all_objects obj
          ON obj.owner = syn.table_owner
         AND obj.object_type LIKE 'PACKAGE%'
         AND obj.object_name = syn.table_name
       WHERE syn.synonym_name LIKE 'DBM~_UTILITY~_%' ESCAPE '~'
         AND syn.table_owner != USER
       GROUP BY obj.status
       ORDER BY DECODE(obj.status,'VALID',2,1)
   ;
   -- Check the status of a global installation if any
   CURSOR c_ddl IS
      SELECT TRIM('ALTER PACKAGE ' || object_name || ' COMPILE ' || TRIM(REPLACE(object_type, 'PACKAGE'))) statement
        FROM user_objects
       WHERE object_type LIKE 'PACKAGE%'
         AND object_name LIKE 'DBM~_%' ESCAPE '~'
         AND status = 'INVALID'
       ORDER BY DECODE(object_type, 'PACKAGE', 1, 2)
              , DECODE(object_name, 'DBM_UTILITY_VAR', 1, 2)
   ;
   -- Local vars
   l_found BOOLEAN;
   r_pub c_pub%ROWTYPE;
   -- Check the status of local packages
   PROCEDURE check_pkg (
      p_object_type IN user_objects.object_type%TYPE
    , p_object_name IN user_objects.object_name%TYPE
   )
   IS
      CURSOR c_pkg IS
         SELECT status
           FROM user_objects
          WHERE object_type = p_object_type
            AND object_name = p_object_name
         ;
      l_status user_objects.status%TYPE;
   BEGIN
      OPEN c_pkg;
      FETCH c_pkg INTO l_status;
      CLOSE c_pkg;
      IF l_status = 'VALID' THEN
--         dbms_output.put_line(p_object_type||' '||p_object_name||' is VALID!');
         NULL;
      ELSIF l_status = 'INVALID' THEN
         dbms_output.put_line(p_object_type||' '||p_object_name||' is INVALID!');
         raise_application_error(-20736, 'DBM_UTILITY is not installed correctly!'); -- modulo 256 = 0 in unix
      ELSE
         dbms_output.put_line(p_object_type||' '||p_object_name||' is MISSING!');
         raise_application_error(-20735, 'DBM_UTILITY is not installed!'); -- modulo 256 = 255 in unix
      END IF;
   END;
BEGIN
   OPEN c_pub;
   FETCH c_pub INTO r_pub;
   l_found := c_pub%FOUND;
   CLOSE c_pub;
   IF l_found THEN
      IF r_pub.status = 'INVALID' THEN
--         dbms_output.put_line('central installation is invalid');
         raise_application_error(-20736, 'DBM_UTILITY is not installed correctly in central schema!'); -- modulo 256 = 0 in unix
      ELSE
--         dbms_output.put_line('central installation is valid');
         RETURN; -- Exit (central installation is valiid)
      END IF;
   END IF;
   -- Recompile invalid package specs and bodies
--   dbms_output.put_line('Recompiling invalid objects...');
   FOR r_ddl IN c_ddl LOOP
      BEGIN
         dbms_output.put_line(r_ddl.statement);
         EXECUTE IMMEDIATE r_ddl.statement;
      EXCEPTION
         WHEN OTHERS THEN
         raise_application_error(-20736, 'DBM_UTILITY is not installed correctly!'); -- modulo 256 = 0 in unix
      END;
   END LOOP;
   -- Check existence and status of all packages
   check_pkg('PACKAGE','DBM_UTILITY_VAR');
   check_pkg('PACKAGE','DBM_UTILITY_KRN');
   check_pkg('PACKAGE BODY','DBM_UTILITY_KRN');
--   dbms_output.put_line('DBM_UTILITY seems correctly installed!');
END;
/

whenever sqlerror continue;
BEGIN
   -- Make a dummy call to avoid ORA-04068: existing state of packages has been discarded + restart
      dbm_utility_krn.end_command(p_cmd_id=>NULL/*last command*/, p_exit_code=>''/*no known error*/);
EXCEPTION
   WHEN OTHERS THEN
--      dbms_output.put_line(SQLERRM);
      NULL;
END;
/