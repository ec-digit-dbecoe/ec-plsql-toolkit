REM Show employee to be extracted

SELECT employee_id, first_name, last_name, department_id, manager_id
  FROM employees
 WHERE employee_id = 176
/

REM Delete data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   IF l_set_id IS NOT NULL THEN
      ds_utility_krn.delete_data_set_def(p_set_id=>l_set_id);
   END IF;
   COMMIT;
END;
/

REM Create data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   l_set_id := ds_utility_krn.create_data_set_def('Jonathon Taylor');
   dbms_output.put_line('set_id='||l_set_id);
   COMMIT;
END;
/

REM Show how to get the id of a data set based on its name

DECLARE
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   l_set_id := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
   dbms_output.put_line('set_id='||l_set_id);
END;
/

REM Define base table and its filter + include first level of child tables

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.include_tables(
      p_set_id => l_set_id
    , p_table_name => 'EMPLOYEES'
    , p_extract_type => 'B' -- base table
    , p_where_clause => 'employee_id=176'
    , p_recursive_level => 1
   );
   COMMIT;
END;
/

REM Show included tables

SELECT set_id, table_id, table_name, extract_type, pass_count
  FROM ds_tables
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
 ORDER BY table_id
/

REM Show constraints followed while getting child tables

SELECT con_id, constraint_name, src_table_name
     , dst_table_name, cardinality, extract_type
  FROM ds_constraints
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
/

REM Extract rowids of records identified so far

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
--   ds_utility_var.g_test_mode := FALSE;
   ds_utility_var.g_msg_mask := 'RS'; -- Error & Debug
   ds_utility_krn.extract_data_set_rowids(l_set_id);
   COMMIT;
END;
/

REM Show Data Extraction Flowchart

select * from table(ds_utility_krn.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')));

REM Show records found (+ via which fk)

SELECT tab.table_name, rec.record_rowid, con.constraint_name
  FROM ds_records rec
 INNER JOIN ds_tables tab
    ON tab.table_id = rec.table_id
   AND tab.set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
  LEFT OUTER JOIN ds_constraints con
    ON con.con_id = rec.con_id
 ORDER BY tab.table_name
/

REM Show statistics on tables (extracted vs total)

SELECT table_name, source_count, extract_count
  FROM ds_tables
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
 ORDER BY table_name
/

REM Show constraint statistics
 
SELECT src_table_name, constraint_name, dst_table_name, extract_count
  FROM ds_constraints
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
 ORDER BY 1, 2
/

REM Include referential constraints (N-1)

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.include_referential_cons(l_set_id);
   COMMIT;
END;
/

REM Show referential constraints (N-1) that have been included

SELECT src_table_name, constraint_name, dst_table_name, cardinality
  FROM ds_constraints
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
   AND cardinality = 'N-1'
 ORDER BY 1, 2
/

REM Specify on of the following extract type: N, F, P
REM First scenario - no extraction of reference data 
REM Second scenario - Full extraction of reference data
REM Third scenario - Partial extraction of reference data

DECLARE
   l_set_id ds_data_sets.set_id%TYPE :=
      ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
   l_extract_type ds_tables.extract_type%TYPE := '&extract_type';
BEGIN
   IF l_extract_type IS NULL THEN
      raise_application_error(-20000,'Extract type is mandatory');
   END IF;
   IF l_extract_type NOT IN ('F','P','N') THEN
      raise_application_error(-20000,'Extract type must be F, P or N');
   END IF;
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id
      ,p_table_name=>'REGIONS', p_extract_type=>l_extract_type);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id
      ,p_table_name=>'COUNTRIES', p_extract_type=>l_extract_type);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id
      ,p_table_name=>'LOCATIONS', p_extract_type=>l_extract_type);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id
      ,p_table_name=>'JOBS', p_extract_type=>l_extract_type);
   COMMIT;
END;
/

REM Defer one constraint to avoid loop in dependencies

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id,p_constraint_name=>'DEPT_MGR_FK',p_deferred=>'DEFERRED');
   COMMIT;
END;
/

REM Extract again rowids of records of the so defined data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'E'; -- Error & Debug
   ds_utility_krn.extract_data_set_rowids(l_set_id);
   COMMIT;
END;
/

REM Show statistics on tables (extracted vs total)

SELECT table_name, source_count, extract_count
  FROM ds_tables
 WHERE set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
 ORDER BY table_name
/

REM Show constraint statistics

SELECT tab.table_name dst_tab_name, con.constraint_name, con.src_table_name, con.cardinality, COUNT(*)
  FROM ds_records rec
 INNER JOIN ds_tables tab
    ON tab.table_id = rec.table_id
   AND tab.set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
  LEFT OUTER JOIN ds_constraints con
    ON con.con_id = rec.con_id
 GROUP BY tab.table_name, con.constraint_name, con.src_table_name, con.cardinality
 ORDER BY 1, 2
/

REM Show Data Extraction Flowchart

select * from table(ds_utility_krn.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')));

REM Show records found (+ via which fk)

SELECT tab.table_name, rec.record_rowid, con.constraint_name
  FROM ds_records rec
 INNER JOIN ds_tables tab
    ON tab.table_id = rec.table_id
   AND tab.set_id = ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
  LEFT OUTER JOIN ds_constraints con
    ON con.con_id = rec.con_id
/

REM Create views to pre-view data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'EWIDSR';
   ds_utility_krn.create_views(p_set_id=>l_set_id, p_view_suffix=>'_V');
END;
/

REM Check created views

SELECT view_name FROM user_views WHERE view_name LIKE '%_V' ORDER BY 1
/

REM Generate one query to check data of each view

SELECT 'SELECT * FROM '||LOWER(view_name)||';' FROM user_views WHERE view_name LIKE '%_V' ORDER BY 1
/

SELECT * FROM countries_v
/

SELECT * FROM departments_v
/

SELECT * FROM employees_v
/

SELECT * FROM job_history_v
/

SELECT * FROM jobs_v
/

SELECT * FROM locations_v
/

SELECT * FROM regions_v
/

REM Drop views created to pre-view data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.drop_views(p_set_id=>l_set_id, p_view_suffix=>'_V');
END;
/

REM Define target database link

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id,p_target_db_link=>'test');
   COMMIT;
END;
/

REM Prepare your target schema i.e.:
REM - disable triggers and constraints
REM - (optionally reinject all data - schema must be empty)
REM - delete REF and/or LIVE data (according to the scenario chosen)

REM WARNING !!! SWITCH HERE TO YOUR TARGET SCHEMA !!!

@hr_dis_trg_con
--@human_resources\hr_popul
@hr_del_data
COMMIT;

REM WARNING !!! SWITCH BACK TO YOUR SOURCE SCHEMA !!!

REM Extract and copy data set to target schema via test dblink
REM This fails due to not well supported IOT operations via dblink
REM A ORA-04010 exception is raised (IOT only have logical rowids)
REM (IOT=Index Organized Table)

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'ES'; -- Error & SQL
   ds_utility_krn.handle_data_set(p_set_id=>l_set_id,p_oper=>'DIRECT-EXECUTE',p_mode=>'I');
   COMMIT;
END;
/

REM Rollback after raised error

ROLLBACK;

REM Export data set to XML

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'ES'; -- Error & SQL
   ds_utility_krn.export_data_set_to_xml(p_set_id=>l_set_id);
   COMMIT;
END;
/

REM Import data set from XML (into target schema via dblink)

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.import_data_set_from_xml(p_set_id=>l_set_id);
   COMMIT;
END;
/

REM Finalize your target schema after transportation i.e.:
REM - re-enable triggers and constraints

REM WARNING !!! TO BE EXECUTED IN YOUR TARGET SCHEMA !!!

@hr_ena_trg_con

REM 
REM Variant 1 - Exclude management staff
REM 

REM Change the extract type of the 2 constraints to N)o extraction

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'EMP_MGR_FK', p_extract_type=>'N');
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEPT_MGR_FK', p_extract_type=>'N');
   COMMIT;
END;
/

REM Alternatively, remove these 2 constraints from the data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.exclude_constraints(p_set_id=>l_set_id, p_constraint_name=>'EMP_MANAGER_FK');
   ds_utility_krn.exclude_constraints(p_set_id=>l_set_id, p_constraint_name=>'DEPT_MGR_FK');
   COMMIT;
END;
/

REM Exclude manager_id columns from the extraction

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'EMPLOYEES', p_columns_list=>'* BUT manager_id');
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEPARTMENTS', p_columns_list=>'* BUT manager_id');
   COMMIT;
END;
/

REM Alternatively, force manager_id columns to NULL

BEGIN
   ds_utility_krn.force_column_value('EMPLOYEES','MANAGER_ID','@NULL');
   ds_utility_krn.force_column_value('DEPARTMENTS','MANAGER_ID','@NULL');
END;
/

REM 
REM Variant 2 - Include details of line managers
REM (use case must reset by executing all steps)
REM 

REM Change the extraction type of EMP_MANAGER_FK to B for N-1 direction

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'EMP_MANAGER_FK'
      , p_cardinality=>'N-1', p_extract_type=>'B');
   COMMIT;
END;
/

REM Change the extraction type of EMP_MANAGER_FK to N for 1-N direction

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'EMP_MANAGER_FK'
      , p_cardinality=>'1-N', p_extract_type=>'N');
   COMMIT;
END;
/

REM 
REM Variant 3 - Delete one person and his details
REM Reset the use case by executing the following steps:
REM - Delete data set definition then create it again
REM - Include base table and its childs
REM - Extract data set rowids
REM - Do no include N-1 relationships!
REM 

REM Generate a script to restore data after their deletion

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.delete_output;
   ds_utility_krn.handle_data_set(p_set_id=>l_set_id,p_oper=>'PREPARE-SCRIPT',p_mode=>'I');
   COMMIT;
   -- To check results: SELECT text FROM ds_output ORDER BY line
END;
/

REM Check the script and save it somewhere

SELECT text FROM ds_output ORDER BY line
/

REM Delete data set

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'E';
   ds_utility_krn.delete_data_set(l_set_id);
-- COMMIT; -- no commit to allow you to rolback
END;
/

REM Check deletion

SELECT * FROM employees WHERE employee_id=176
/

REM 
REM Variant 4 - security policies
REM 

REM Create security policy

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_var.g_msg_mask := 'E';
   ds_utility_krn.create_policies(p_set_id=>l_set_id);
END;
/

REM Check policies

SELECT * FROM user_policies
/

REM Check employees (should see 1 row)
/

SELECT * FROM employees
/

REM Drop policies

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.drop_policies(p_set_id=>l_set_id);
END;
/

REM Check employees (should see all rows)

SELECT * FROM employees
/

REM 
REM --- End of tutorial script ---
REM 

REM Please ignore all SQL statements below

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor');
BEGIN
   ds_utility_krn.set_record_remarks(l_set_id);
   COMMIT;
END;
/

select * from ds_records where table_id in (select table_id from ds_tables
where set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
and table_name='EMPLOYEES')
/

SELECT * FROM ds_constraints WHERE constraint_name='EMP_MANAGER_FK'
/

select level, manager_id, employee_id
from employees
connect by employee_id = prior manager_id
start with employee_id = 176
/

select * From ds_records where table_id in (select table_Id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor'))
/

select * from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor') order by pass_count
/

select * from ds_records where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor'))
/

select * From ds_constraints where constraint_name in (
select constraint_name From ds_constraints 
where set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
group by constraint_name
having count(*) > 1)
and set_id=ds_utility_krn.get_data_set_def_by_name('Jonathon Taylor')
/

SELECT DISTINCT fk.table_name, rpk.table_name, lpk.constraint_name, fk.constraint_name, rpk.constraint_name
  FROM user_constraints fk
 INNER JOIN user_constraints rpk
    ON rpk.constraint_name = fk.r_constraint_name
 INNER JOIN user_cons_columns rcol
    ON rcol.constraint_name = rpk.constraint_name
 INNER JOIN user_constraints lpk
    ON lpk.table_name = fk.table_name
   AND lpk.constraint_type IN ('P','U')
INNER JOIN user_cons_columns lcol
    ON lcol.table_name = lpk.table_name
   AND lcol.constraint_name =lpk.constraint_name
   AND lcol.column_name = rcol.column_name
 WHERE fk.constraint_type = 'R'
   AND fk.table_name IN ('EMPLOYEES','JOB_HISTORY','JOBS','DEPARTMENTS','LOCATIONS','COUNTRIES','REGIONS')
/

select rec.seq, tab.table_id, tab.table_name, con.constraint_name, deleted_flag, remark
from ds_records rec
inner join ds_tables tab 
on tab.table_id = rec.table_id
left outer join ds_constraints con
on con.con_id = rec.con_id
order by rec.seq
/

