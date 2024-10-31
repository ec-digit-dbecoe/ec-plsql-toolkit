PROMPT Dropping database objects...
DECLARE
   CURSOR c_obj IS
      SELECT object_type, object_name
           , CASE WHEN object_type = 'TABLE' THEN ' CASCADE CONSTRAINTS' END drop_type
        FROM user_objects
       WHERE object_name LIKE UPPER('DPP\_%') ESCAPE '\'
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

PROMPT Dropping procedures...
DECLARE
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_prc IN (
      SELECT object_name
        FROM user_objects
       WHERE object_name IN (
                'DC_DBA_MGMT_KILL_SESS_DEDIC_DB'
              , 'DC_DBA_MGMT_LOCK_USER'
             )
       ORDER BY object_name ASC
   ) LOOP
      dbms_output.put_line(l_sql);
      l_sql := 'DROP PROCEDURE ' || r_prc.object_name;
      EXECUTE IMMEDIATE l_sql;
   END LOOP;
END;
/

PROMPT Dropping Java source if needed...
DECLARE
   obj_count         PLS_INTEGER;
   l_sql VARCHAR2(4000);
BEGIN
   SELECT COUNT(*)
     INTO obj_count
     FROM user_source
    WHERE type = 'JAVA SOURCE'
      AND name = 'DPP_TOOLKIT';
   IF obj_count > 0 THEN
      dbms_output.put_line(l_sql);
      l_sql := 'DROP JAVA SOURCE dpp_toolkit';
      EXECUTE IMMEDIATE l_sql;
   END IF;
END;
/

PROMPT Dropping monitoring job if needed...
BEGIN

   -- Drop the job if it already exists.
   BEGIN
      dbms_scheduler.drop_job(
         job_name => 'DPP_MONITORING'
         , defer => FALSE
         , force => FALSE
      );
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

END;
/