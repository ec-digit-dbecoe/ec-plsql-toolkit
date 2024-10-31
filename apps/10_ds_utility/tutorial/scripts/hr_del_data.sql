REM Delete live data in the right order i.e. without needing to disable fks

DECLARE
   l_rowcount NUMBER;
BEGIN
   -- *** DELETE LIVE DATA ***
   IF UPPER('&delete_live_data') IN ('Y','O') THEN
      -- Delete job history
      DELETE job_history;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' job history deleted.');
      -- Remove loop in dependencies
      UPDATE departments SET manager_id = NULL;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' departments updated.');
      -- Delete employees (non management first)
      l_rowcount := -1;
      WHILE l_rowcount != 0 LOOP
         DELETE employees WHERE employee_id IN (
            SELECT employee_id FROM employees
             MINUS
            SELECT manager_id FROM employees
         )
         ;
         l_rowcount := SQL%ROWCOUNT;
         dbms_output.put_line(l_rowcount||' employees deleted.');
      END LOOP;
      -- Delete departments
      DELETE departments;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' departments deleted.');
   END IF;
   -- *** DELETE REF DATA ***
   IF UPPER('&delete_ref_data') IN ('Y','O') THEN
      -- Delete jobs
      DELETE jobs;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' jobs deleted.');
      -- Delete locations
      DELETE locations;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' locations deleted.');
      -- Delete countries
      DELETE countries;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' countries deleted.');
      -- Delete regions
      DELETE regions;
      l_rowcount := SQL%ROWCOUNT;
      dbms_output.put_line(l_rowcount||' regions deleted.');
   END IF;
   dbms_output.put_line('please commit!');
END;
/
