REM @pre-uninstall:beg
REM @pre-uninstall:end

PROMPT Dropping database objects...
DECLARE
   CURSOR c_obj IS
      SELECT object_type, object_name
           , CASE WHEN object_type = 'TABLE' THEN ' CASCADE CONSTRAINTS' END drop_type
        FROM user_objects
       WHERE object_name LIKE UPPER('ARM\_%') ESCAPE '\'
         AND object_type IN ('CONSTRAINT','PACKAGE','TABLE','SEQUENCE','VIEW','TYPE')
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

PROMPT Dropping Java source if needed...
DECLARE
   obj_count         PLS_INTEGER;
BEGIN
   SELECT COUNT(*)
     INTO obj_count
     FROM user_source
    WHERE type = 'JAVA SOURCE'
      AND name = 'ARM_TOOLKIT';
   IF obj_count > 0 THEN
      EXECUTE IMMEDIATE 'DROP JAVA SOURCE arm_toolkit';
   END IF;
END;
/

REM @post-uninstall:beg
REM @post-uninstall:end
