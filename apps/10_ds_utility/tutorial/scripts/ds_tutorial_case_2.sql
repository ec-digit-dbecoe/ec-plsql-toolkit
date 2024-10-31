REM Create or replace data set definition

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   IF l_set_id IS NOT NULL THEN
      ds_utility_krn.clear_data_set_def(p_set_id=>l_set_id);
   ELSE
      ds_utility_krn.create_data_set_def(p_set_name=>'dept-emp-capture');
   END IF;
   COMMIT;
END;
/

REM Define tables for which DML operations must be captured

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.include_tables(p_set_id=>l_set_id, p_table_name=>'EMPLOYEES');
   ds_utility_krn.include_tables(p_set_id=>l_set_id, p_table_name=>'JOB_HISTORY');
   ds_utility_krn.include_tables(p_set_id=>l_set_id, p_table_name=>'DEPARTMENTS');
   COMMIT;
END;
/

REM Show included tables

SELECT set_id, table_id, table_name
  FROM ds_tables
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')
 ORDER BY table_id
/

REM Create triggers to capture data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.create_triggers(p_set_id=>l_set_id);
END;
/

REM Check created triggers

SELECT table_name, trigger_name FROM user_triggers WHERE trigger_name LIKE '%DS%' ORDER BY 1
/

REM Create a department

INSERT INTO departments (
   department_id, department_name
) VALUES (
   300, 'Data technlologies'
)
/

REM Create 2 employees

INSERT INTO employees (
   employee_id, first_name, last_name
 , email, hire_date, job_id
 , department_id
) VALUES (
   300, 'Albert', 'Camus'
 , 'acamus@hotmail.com', TO_DATE('01/01/2020','DD/MM/YYYY'), 'IT_PROG'
 , 300
)
/

INSERT INTO employees (
   employee_id, first_name, last_name
 , email, hire_date, job_id
 , department_id, manager_id
) VALUES (
   301, 'Alphonse', 'Daudet'
 , 'adaudet@hotmail.com', TO_DATE('01/01/2020','DD/MM/YYYY'), 'IT_PROG'
 , 300, 300
)
/

REM Update department

UPDATE departments
   SET manager_id = 300
 WHERE department_id = 300
/

REM Delete one employee and its job history

DELETE job_history
 WHERE employee_id = 176
/

DELETE employees
 WHERE employee_id = 176
/

REM Commit changes

COMMIT
/

REM Check inserted/updated/deleted data

SELECT * FROM departments WHERE department_id=300
/

SELECT * FROM employees WHERE department_id=300 OR employee_id=176
/

SELECT * FROM job_history WHERE employee_id=176
/

REM Check captured operations

SELECT rec.seq, tab.table_name, rec.operation
     , rec.record_data, rec.record_data_old
  FROM ds_records rec
 INNER JOIN ds_tables tab
    ON tab.table_id = rec.table_id
   AND tab.set_id = ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')
 ORDER BY rec.seq
/

REM Generate a REDO script (output is saved in dept_emp_capture_redo.sql)

SELECT * FROM TABLE(ds_utility_krn.gen_captured_data_set_script(ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')))
/

REM Generate an UNDO script (output is saved in dept_emp_capture_undo.sql)

SELECT * FROM TABLE(ds_utility_krn.gen_captured_data_set_script(ds_utility_krn.get_data_set_def_by_name('dept-emp-capture'),'Y'))
/

REM Rollback all captured operations

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.rollback_captured_data_set(p_set_id=>l_set_id);
   COMMIT;
END;
/

REM Check data

SELECT * FROM departments WHERE department_id=300
/

SELECT * FROM employees WHERE department_id=300 OR employee_id=176
/

SELECT * FROM job_history WHERE employee_id=176
/

REM Drop triggers created to capture data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.drop_triggers(p_set_id=>l_set_id);
END;
/

REM Delete data set definition

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.delete_data_set_def(p_set_id=>l_set_id);
END;
/

REM
REM Variant 1 - Synchronous replication
REM 

REM Set capture mode

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.update_data_set_def_properties(p_set_id=>l_set_id, p_capture_mode=>'EXP');
   COMMIT;
END;
/

REM Check capture mode

SELECT * FROM ds_data_sets WHERE set_id=ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')
/

REM Set target database link

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'EMPLOYEES', p_target_db_link=>'test');
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'JOB_HISTORY', p_target_db_link=>'test');
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEPARTMENTS', p_target_db_link=>'test');
   COMMIT;
END;
/

REM Check target db link

SELECT set_id, table_id, table_name, target_db_link
  FROM ds_tables
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')
 ORDER BY table_id
/

REM
REM Variant 2 - Asynchronous replication
REM 

REM Set capture mode

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.update_data_set_def_properties(p_set_id=>l_set_id, p_capture_mode=>'ASYN');
   COMMIT;
END;
/

REM Check capture mode

SELECT * FROM ds_data_sets WHERE set_id=ds_utility_krn.get_data_set_def_by_name('dept-emp-capture')
/

REM Check created job

SELECT * FROM user_jobs WHERE what LIKE '--DS%'
/

REM Re-launch a job manually

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('dept-emp-capture');
BEGIN
   ds_utility_krn.create_capture_forwarding_job(p_set_id=>l_set_id);
   COMMIT;
END;
/
