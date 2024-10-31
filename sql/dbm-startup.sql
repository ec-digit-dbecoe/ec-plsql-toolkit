set echo off
set trimspool off
set sqlprefix "~"
set linesize 200
@sql/check-dbm
set termout off
set feedback off
set head off
column 1 new_value 1
column 2 new_value 2
column 3 new_value 3
column 4 new_value 4
column 5 new_value 5
column 6 new_value 6
column 7 new_value 7
column 8 new_value 8
column 9 new_value 9
column 10 new_value 10
column 11 new_value 11
column 12 new_value 12
column 13 new_value 13
column 14 new_value 14
column 15 new_value 15
column 16 new_value 16
column 17 new_value 17
column 18 new_value 18
column 19 new_value 19
column 20 new_value 20
select '' "1", '' "2", '' "3", '' "4", '' "5", '' "6", '' "7", '' "8", '' "9", '' "10"
     , '' "11", '' "12", '' "13", '' "14", '' "15", '' "16", '' "17", '' "18", '' "19", '' "20" from dual where 1=2;
define p1="&1"
define p2="&2"
define p3="&3"
define p4="&4"
define p5="&5"
define p6="&6"
define p7="&7"
define p8="&8"
define p9="&9"
define p10="&10"
define p11="&11"
define p12="&12"
define p13="&13"
define p14="&14"
define p15="&15"
define p16="&16"
define p17="&17"
define p18="&18"
define p19="&19"
define p20="&20"
undefine 1
undefine 2
undefine 3
undefine 4
undefine 5
undefine 6
undefine 7
undefine 8
undefine 9
undefine 10
undefine 11
undefine 12
undefine 13
undefine 14
undefine 15
undefine 16
undefine 17
undefine 18
undefine 19
undefine 20
set serveroutput on size 999999
host set-os >~set-os.sql
@~set-os
exec dbm_utility_krn.end_command(p_cmd_id=>NULL/*last command*/, p_exit_code=>''/*no known error*/)
set termout on
@dbm-cli startup &&p1 &&p2 &&p3 &&p4 &&p5 &&p6 &&p7 &&p8 &&p9 &&p10 &&p11 &&p12 &&p13 &&p14 &&p15 &&p16 &&p17 &&p18 &&p19 &&p20
@dbm-cli scan-files &&p1 &&p2 &&p3 &&p4 &&p5 &&p6 &&p7 &&p8 &&p9 &&p10 &&p11 &&p12 &&p13 &&p14 &&p15 &&p16 &&p17 &&p18 &&p19 &&p20
@dbm-cli read-config all
@dbm-cli execute &&p1 &&p2 &&p3 &&p4 &&p5 &&p6 &&p7 &&p8 &&p9 &&p10 &&p11 &&p12 &&p13 &&p14 &&p15 &&p16 &&p17 &&p18 &&p19 &&p20
undefine p1
undefine p2
undefine p3
undefine p4
undefine p5
undefine p6
undefine p7
undefine p8
undefine p9
undefine p10
undefine p11
undefine p12
undefine p13
undefine p14
undefine p15
undefine p16
undefine p17
undefine p18
undefine p19
undefine p20
set sqlprompt "DBM-CLI> "
