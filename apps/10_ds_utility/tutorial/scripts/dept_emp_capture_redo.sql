INSERT INTO departments (
   department_id
  ,department_name
  ,manager_id
  ,location_id
) VALUES (
   300
  ,'Data technlologies'
  ,NULL
  ,NULL
)
/

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
   300
  ,'Albert'
  ,'Camus'
  ,'acamus@hotmail.com'
  ,NULL
  ,TO_DATE('01/01/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,'IT_PROG'
  ,NULL
  ,NULL
  ,NULL
  ,300
)
/

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
   301
  ,'Alphonse'
  ,'Daudet'
  ,'adaudet@hotmail.com'
  ,NULL
  ,TO_DATE('01/01/2020 00:00:00','DD/MM/YYYY HH24:MI:SS')
  ,'IT_PROG'
  ,NULL
  ,NULL
  ,300
  ,300
)
/

UPDATE departments
   SET department_name = 'Data technlologies'
     , manager_id = 300
     , location_id = NULL
 WHERE department_id = 300
/

DELETE job_history
 WHERE employee_id = 176
  AND start_date = TO_DATE('24/03/2006 00:00:00','DD/MM/YYYY HH24:MI:SS')
/

DELETE job_history
 WHERE employee_id = 176
  AND start_date = TO_DATE('01/01/2007 00:00:00','DD/MM/YYYY HH24:MI:SS')
/

DELETE employees
 WHERE employee_id = 176
/
