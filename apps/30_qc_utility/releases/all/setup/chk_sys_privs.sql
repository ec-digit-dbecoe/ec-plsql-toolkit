set serveroutput on size 99999
column object_type format A20
column system_privilege format A30
column status width format A10
set pagesi 999
set termout on
BEGIN
   dbms_output.put_line('===============================================================================');
   dbms_output.put_line('SELECT ANY DICTIONARY privilege is needed to access objects of your app schemas');
   dbms_output.put_line('CREATE/ALTER/DROP ANY <object type> sys privileges are needed to fix anomalies ');
   dbms_output.put_line('Only privileges related to object types used in your applications are required ');
   dbms_output.put_line('None of the above privs is required if the tool is installed in your app schema');
   dbms_output.put_line('===============================================================================');
END;
/
SELECT DISTINCT SUBSTR(x.privilege,INSTR(x.privilege,' ANY ')+5) object_type, x.privilege system_privilege
     , DECODE(y.privilege,NULL,'Missing','Granted') status
  FROM dba_sys_privs x
  LEFT OUTER JOIN user_sys_privs y
    ON y.privilege = x.privilege
 WHERE x.privilege = 'SELECT ANY DICTIONARY'
    OR (x.privilege like '%ANY%'
      AND INSTR(x.privilege,'ANALYTIC VIEW')=0
      AND INSTR(x.privilege,'INDEXTYPE')=0
      AND (
         1=0
      OR INSTR(x.privilege,'TABLE')>0
      OR INSTR(x.privilege,'INDEX')>0
      OR INSTR(x.privilege,'VIEW')>0
      OR INSTR(x.privilege,'SYNONYM')>0
      OR INSTR(x.privilege,'PROCEDURE')>0
      OR INSTR(x.privilege,'TRIGGER')>0
      OR INSTR(x.privilege,'SEQUENCE')>0
      OR INSTR(x.privilege,'TYPE')>0
      )
      AND (
         1=0
      OR INSTR(x.privilege,'ALTER')>0
      OR INSTR(x.privilege,'CREATE')>0
      OR INSTR(x.privilege,'DROP')>0
      --OR instr(x.privilege,'SELECT')>0
      --OR instr(x.privilege,'EXECUTE')>0
      )
)
ORDER BY 1, 2;
set serveroutput off
set termout off