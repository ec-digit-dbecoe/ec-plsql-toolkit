set sqlprompt "DBM-CLI> "
set termout off
set sqlprefix "~"
set linesize 500
set trimspool on
set pagesize 0
set verify off
set head off
set feedback off
define _rc = "0"
column tmp_dir new_value tmp_dir;
select NVL(MAX(value),'tmp') tmp_dir from dbm_parameters where app_code='dbm_utility' and ver_code='all' and name='tmp_dir';
store set &&tmp_dir/~defaultenv.sql replace
column 1 new_value 1
column 2 new_value 2
column 3 new_value 3
column 4 new_value 4
column 5 new_value 5
column 6 new_value 6
column 7 new_value 7
column 8 new_value 8
column 9 new_value 9
select '' "1", '' "2", '' "3", '' "4", '' "5", '' "6", '' "7", '' "8", '' "9" from dual where 1=2;
set serveroutput on size 999999
set termout on
variable cmd_id number
exec :cmd_id := dbm_utility_krn.begin_command(p_command_line=>'&1 &2 &3 &4 &5 &6 &7 &8 &9')
set termout off
undefine 1
undefine 2
undefine 3
undefine 4
undefine 5
undefine 6
undefine 7
undefine 8
undefine 9
column sqlfile new_value sqlfile;
select '&&tmp_dir/~'||:cmd_id sqlfile from dual;
spool &&sqlfile.-step1.sql
select text from dbm_streams where cmd_id=:cmd_id and type='IN' order by line;
spool off
spool &&sqlfile.-step2.sql
select text from dbm_streams where cmd_id=:cmd_id and type='IN2' order by line;
spool off
delete dbm_streams where cmd_id=:cmd_id and type IN ('IN','IN2');
commit;
set termout on
whenever sqlerror continue
rem prompt executing &&sqlfile.-step1.sql
@@&&sqlfile.-step1.sql
rem prompt _rc=&&_rc
BEGIN
   dbm_utility_krn.end_command(p_cmd_id=>:cmd_id, p_exit_code=>'&&_rc' /*OK*/);
EXCEPTION
   WHEN OTHERS THEN
      dbm_utility_krn.end_command(p_cmd_id=>:cmd_id, p_exit_code=>'&&_rc' /*OK*/);
END;
/
rem prompt executing &&sqlfile.-step3.sql
set termout off
spool &&sqlfile.-step3.sql
select text from dbm_streams where cmd_id=:cmd_id and type='IN3' order by line;
spool off
delete dbm_streams where cmd_id=:cmd_id and type IN ('IN3');
commit;
set termout on
@@&&sqlfile.-step3.sql
@@&&tmp_dir/~defaultenv.sql
set termout on