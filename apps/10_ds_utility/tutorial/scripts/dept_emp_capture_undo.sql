INSERT INTO employees (
   employee_id
  ,first_name
  ,last_name
  ,email
  ,phone_number
  ,hire_date
  ,job_id
  ,salary
  ,commission_pct
  ,manager_id
  ,department_id
) VALUES (
   176
  ,'Jonathon'
  ,'Taylor'
  ,'JTAYLOR'
  ,'011.44.1644.429265'
  ,TO_DATE('24/03/2006 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,'SA_REP'
  ,8600
  ,.2
  ,149
  ,80
)
/

INSERT INTO job_history (
   employee_id
  ,start_date
  ,end_date
  ,job_id
  ,department_id
) VALUES (
   176
  ,TO_DATE('01/01/2007 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,TO_DATE('31/12/2007 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,'SA_MAN'
  ,80
)
/

INSERT INTO job_history (
   employee_id
  ,start_date
  ,end_date
  ,job_id
  ,department_id
) VALUES (
   176
  ,TO_DATE('24/03/2006 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,TO_DATE('31/12/2006 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,'SA_REP'
  ,80
)
/

UPDATE departments
   SET department_name = 'Data technlologies'
     , manager_id = NULL
     , location_id = NULL
 WHERE department_id = 300
/

DELETE employees
 WHERE employee_id = 301
/

DELETE employees
 WHERE employee_id = 300
/

DELETE departments
 WHERE department_id = 300
/
