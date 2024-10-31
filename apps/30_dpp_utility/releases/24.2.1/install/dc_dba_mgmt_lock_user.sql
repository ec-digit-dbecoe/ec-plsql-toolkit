CREATE OR REPLACE procedure                             dc_dba_mgmt_lock_user (user in varchar2, b_lock in boolean) is

v_count number :=0;

begin

-- user doesn't exist ?

select count(1) into v_count from dba_users where username = user;

if v_count = 0
then
RAISE_APPLICATION_ERROR(-20001, 'User doesn''t exist.');
end if;

-- system users ?

select count(1) into v_count from dba_users where username = user and (username in ('ANONYMOUS','APEX_040200','APEX_PUBLIC_USER','APPQOSSYS','AUDSYS','C##BMCPTRL','C##DIGIT_LISO','C##OPS$BMCPTRL',
'C##OPS$ORACLE','C##RMAN10_OLRPOC2_AAA121AD','CTXSYS','DBSNMP','DIP','DVF','DVSYS','FLOWS_FILES','GSMADMIN_INTERNAL',
'GSMCATUSER','GSMUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS',
'ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSBACKUP',
'SYSDG','SYSKM','SYSTEM','WMSYS','XDB','XS$NULL') or username like 'RMAN%');

if v_count = 1
then
RAISE_APPLICATION_ERROR(-20001, 'This user cannot be locked/unlocked.');
end if;

/* 
-- restriction removed as requested on IM0019339904 
-- no segments ?

select count(1) into v_count from dba_segments where  owner = user;

if v_count > 0
then
RAISE_APPLICATION_ERROR(-20001, 'This user owns objects. Cannot be lock/unlock by yourself.');
end if;
*/

-- lock/unlock

if b_lock
then
execute immediate 'alter user '||user||' account lock';
else
execute immediate 'alter user '||user||' account unlock';
end if;

end dc_dba_mgmt_lock_user;
/
--show errors procedure dc_dba_mgmt_lock_user;