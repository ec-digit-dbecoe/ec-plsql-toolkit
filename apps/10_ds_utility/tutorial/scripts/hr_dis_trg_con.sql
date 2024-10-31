REM Disable constraints towards PER/CAR tables

DECLARE
   CURSOR c_ddl IS
        SELECT 'ALTER TABLE '||LOWER(table_name)||' DISABLE CONSTRAINT '||LOWER(constraint_name) statement
          FROM user_constraints
         WHERE constraint_type = 'R'
           AND table_name IN ('EMPLOYEES','DEPARTMENTS','JOBS','JOB HISTORY','LOCATIONS','COUNTRIES','REGIONS')
           AND status = 'ENABLED';
BEGIN
   FOR r_ddl IN c_ddl LOOP
      dbms_output.put_line(r_ddl.statement);
      BEGIN
         EXECUTE IMMEDIATE r_ddl.statement;
         dbms_output.put_line('OK');
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('KO: '||SQLERRM);
      END;
   END LOOP;
END;
/

REM Disable triggers

DECLARE
   CURSOR c_ddl IS
        SELECT 'ALTER TRIGGER '||LOWER(trigger_name)||' DISABLE' statement
          FROM user_triggers
         WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOBS','JOB HISTORY','LOCATIONS','COUNTRIES','REGIONS')
           AND status = 'ENABLED'
   ;
BEGIN
   FOR r_ddl IN c_ddl LOOP
      dbms_output.put_line(r_ddl.statement);
      BEGIN
         EXECUTE IMMEDIATE r_ddl.statement;
         dbms_output.put_line('OK');
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('KO: '||SQLERRM);
      END;
   END LOOP;
END;
/
