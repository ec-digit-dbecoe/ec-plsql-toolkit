CREATE OR REPLACE procedure               dc_dba_mgmt_kill_sess_dedic_db (session_sid in int, session_serial in int,V_INST_ID NUMBER DEFAULT 0) is
v_username v$session.username%type;
testusertype varchar2(9);
type_of_user varchar2(10);
background_test number;
system_user_test number;
V_INSTANCE_ID NUMBER;
begin

 IF V_INST_ID = 0 THEN
 SELECT INSTANCE_NUMBER INTO V_INSTANCE_ID FROM V$INSTANCE;
 ELSE
 V_INSTANCE_ID := V_INST_ID;
 END IF;

select username into v_username from v$session where sid=session_sid and serial#=session_serial;
select type into type_of_user from v$session where sid=session_sid and serial#=session_serial;

select count(*) into background_test from v$session where sid = session_sid and serial# = session_serial and type = 'BACKGROUND';
select count(*) into system_user_test from v$session where username = v_username and username in
('ANONYMOUS','APEX_040200','APEX_PUBLIC_USER','APPQOSSYS','AUDSYS','C##BMCPTRL','C##DIGIT_LISO','C##OPS$BMCPTRL',
'C##OPS$ORACLE','C##RMAN10_OLRPOC2_AAA121AD','CTXSYS','DBSNMP','DIP','DVF','DVSYS','FLOWS_FILES','GSMADMIN_INTERNAL',
'GSMCATUSER','GSMUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS',
'ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSBACKUP',
'SYSDG','SYSKM','SYSTEM','WMSYS','XDB','XS$NULL');

select background_test + system_user_test into testusertype from dual;

dbms_output.put_line(' USER : '||v_username||' , SID : '||session_sid||' , SERIAL# : '||SESSION_SERIAL||' , TYPE OF USER : '||type_of_user||'');

if testusertype > 0
then
        if background_test > 0
        then
                RAISE_APPLICATION_ERROR(-20001, 'You are NOT allowed to kill BACKGROUND session '||session_sid||','||session_serial||'');
        end if;

        if system_user_test > 0
        then
                RAISE_APPLICATION_ERROR(-20002, 'You are NOT allowed to kill user '||v_username||'');
        end if;
else
        execute immediate 'alter system kill session '''||session_sid||','||session_serial||',@'||V_INSTANCE_ID||''''||' immediate';
        dbms_output.put_line('The session '||session_sid||','||session_serial||' connected as '||v_username||' has been killed.');
end if;
exception
        when no_data_found then
        RAISE_APPLICATION_ERROR(-20003, 'No session matching criteria sid and serial# ');
end dc_dba_mgmt_kill_sess_dedic_db;
/