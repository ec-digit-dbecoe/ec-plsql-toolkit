set verify off

REM Provide a default value to non-initialised variables
set termout off
COLUMN tab_ts new_value tab_ts
select '' "tab_ts" from dual where 1=2;
select NVL('&tab_ts',default_tablespace) tab_ts from (select default_tablespace from user_users where username=user);
COLUMN idx_ts new_value idx_ts
select '' "idx_ts" from dual where 1=2;
select NVL('&idx_ts',default_tablespace) idx_ts from (select default_tablespace from user_users where username=user);
set termout on

PROMPT Creating applications table...
CREATE TABLE dbm_applications$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , app_alias VARCHAR2(30) NOT NULL
 , seq NUMBER(3) NULL
 , ver_code VARCHAR2(30) NULL
 , ver_status VARCHAR2(30) NULL -- VALID, INVALID, MIGRATING
 , home_dir VARCHAR2(200) NULL
 , exposed_flag VARCHAR2(1) NULL -- Y/N
 , deleted_flag VARCHAR2(1) NULL -- Y/N
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_applications$ IS 'Applications';
COMMENT ON COLUMN dbm_applications$.owner IS 'Owner';
COMMENT ON COLUMN dbm_applications$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_applications$.app_alias IS 'Application alias';
COMMENT ON COLUMN dbm_applications$.seq IS 'Sequence of migration';
COMMENT ON COLUMN dbm_applications$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_applications$.ver_status IS 'Version status';
COMMENT ON COLUMN dbm_applications$.home_dir IS 'Home directory';
COMMENT ON COLUMN dbm_applications$.exposed_flag IS 'Exposed (Y/N)?';
COMMENT ON COLUMN dbm_applications$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_app_pk ON dbm_applications$ (owner, app_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_applications$ ADD CONSTRAINT dbm_app_pk PRIMARY KEY (owner, app_code) USING INDEX
;

CREATE UNIQUE INDEX dbm_app_uk ON dbm_applications$ (owner, app_alias)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_applications$ ADD CONSTRAINT dbm_app_uk UNIQUE (owner, app_alias) USING INDEX
;

PROMPT Creating versions table...
CREATE TABLE dbm_versions$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL --MM.mm.bb (major/minor/bugfix)
 , ver_nbr NUMBER(9) NULL
 , ver_status VARCHAR2(10) NULL -- PAST, CURRENT, NEXT, LATER, (null)
 , next_op_type VARCHAR2(30) NULL -- INSTALL, UPGRADE
 , last_op_type VARCHAR2(30) NULL -- INSTALL, UPGRADE, UNINSTALL, VALIDATE, ROLLBACK INSTALL, ROLLBACK UPGRADE
 , last_op_status VARCHAR2(10) NULL -- ONGOING, SUCCESS, ERROR
 , last_op_date DATE NULL
 , installable VARCHAR(1) NULL --Y/N
 , install_rollbackable VARCHAR(1) NULL --Y/N
 , upgradeable VARCHAR2(1) NULL --Y/N
 , upgrade_rollbackable VARCHAR2(1) NULL --Y/N
 , uninstallable VARCHAR2(1) NULL --Y/N
 , validable VARCHAR2(1) NULL --Y/N
 , precheckable VARCHAR2(1) NULL --Y/N
 , setupable VARCHAR2(1) NULL --Y/N
 , exposable VARCHAR2(1) NULL --Y/N
 , concealable VARCHAR2(1) NULL --Y/N
 , deleted_flag VARCHAR2(1) NULL -- Y/N
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_versions$ IS 'Application versions';
COMMENT ON COLUMN dbm_versions$.owner IS 'Owner';
COMMENT ON COLUMN dbm_versions$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_versions$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_versions$.ver_nbr IS 'Version number';
COMMENT ON COLUMN dbm_versions$.ver_status IS 'Version status';
COMMENT ON COLUMN dbm_versions$.next_op_type IS 'Next expected operation';
COMMENT ON COLUMN dbm_versions$.last_op_type IS 'Last executed operation';
COMMENT ON COLUMN dbm_versions$.last_op_date IS 'Last operation date and time';
COMMENT ON COLUMN dbm_versions$.installable IS 'Are full installation script available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.install_rollbackable IS 'Are installation rollback scripts availale (Y/N)?';
COMMENT ON COLUMN dbm_versions$.upgradeable IS 'Are incremental upgrade scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.validable IS 'Are upgrade rollback scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.precheckable IS 'Are pre-migration scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.setupable IS 'Are setup scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_ver_pk ON dbm_versions$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_pk PRIMARY KEY (owner, app_code, ver_code) USING INDEX
;

CREATE UNIQUE INDEX dbm_ver_uk ON dbm_versions$ (owner, app_code, ver_nbr)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_uk UNIQUE (owner, app_code, ver_nbr) USING INDEX
;

ALTER TABLE dbm_versions$ ADD (
   CONSTRAINT dbm_ver_app_fk FOREIGN KEY (owner, app_code)
   REFERENCES dbm_applications$ (owner, app_code)
)
;

CREATE INDEX dbm_ver_app_fk_i ON dbm_versions$ (owner, app_code)
TABLESPACE &&idx_ts
;

PROMPT Creating files table...
CREATE TABLE dbm_files$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , path VARCHAR2(4000) NOT NULL
 , type VARCHAR(20) NOT NULL --INSTALL, UPGRADE, ROLLBACK INSTALL, ROLLBACK UPGRADE, VALIDATE, UNINSTALL, FORCE CURRENT, PRECHECK
 , run_condition VARCHAR2(4000) NULL
 , seq NUMBER(9) NOT NULL
 , hash VARCHAR2(32) NULL
 , status VARCHAR2(20) NULL -- NORMAL, MISSING, TAMPERED
 , run_status VARCHAR2(20) -- ONGOING, SUCCESS, ERROR, ROLLED BACK
 , run_date DATE NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_files$ IS 'Version files';
COMMENT ON COLUMN dbm_files$.owner IS 'Owner';
COMMENT ON COLUMN dbm_files$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_files$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_files$.path IS 'Full path name';
COMMENT ON COLUMN dbm_files$.type IS 'Usage type';
COMMENT ON COLUMN dbm_files$.run_condition IS 'Run condition';
COMMENT ON COLUMN dbm_files$.seq IS 'Sequence of execution';
COMMENT ON COLUMN dbm_files$.hash IS 'Hash value';
COMMENT ON COLUMN dbm_files$.status IS 'File status';
COMMENT ON COLUMN dbm_files$.run_status IS 'Run status';
COMMENT ON COLUMN dbm_files$.run_date IS 'Run date/time';
COMMENT ON COLUMN dbm_files$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_fil_pk ON dbm_files$ (owner, path)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_files$ ADD CONSTRAINT dbm_fil_pk PRIMARY KEY (owner, path) USING INDEX
;

ALTER TABLE dbm_files$ ADD (
   CONSTRAINT dbm_fil_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
)
;

CREATE INDEX dbm_fil_ver_fk_i ON dbm_files$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating objects table...
CREATE TABLE dbm_objects$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , name VARCHAR2(128) NOT NULL
 , checksum VARCHAR2(20) NULL
 , condition VARCHAR2(4000) NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_objects$ IS 'Database objects';
COMMENT ON COLUMN dbm_objects$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_objects$.owner IS 'Owner';
COMMENT ON COLUMN dbm_objects$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_objects$.name IS 'Object type and name';
COMMENT ON COLUMN dbm_objects$.checksum IS 'Object checksum';
COMMENT ON COLUMN dbm_objects$.condition IS 'Object condition';
COMMENT ON COLUMN dbm_objects$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_obj_pk ON dbm_objects$ (owner, app_code, ver_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_objects$ ADD CONSTRAINT dbm_obj_pk PRIMARY KEY (owner, app_code, ver_code, name) USING INDEX
;

ALTER TABLE dbm_objects$ ADD (
   CONSTRAINT dbm_obj_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
)
;

CREATE INDEX dbm_obj_ver_fk_i ON dbm_objects$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating variables table...
CREATE TABLE dbm_variables$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , name VARCHAR2(30) NOT NULL
 , value VARCHAR2(4000) NULL
 , seq NUMBER(3) NULL
 , descr VARCHAR2(100) NULL --  label or prompt
 , data_type VARCHAR2(100) NULL -- CHAR/NUMBER
 , nullable VARCHAR2(1) NULL -- Y/N
 , convert_value_sql VARCHAR2(4000) NULL
 , check_value_sql VARCHAR2(4000) NULL
 , default_value_sql VARCHAR2(4000) NULL
 , check_error_msg VARCHAR2(4000) NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_variables$ IS 'Application variables';
COMMENT ON COLUMN dbm_variables$.owner IS 'Owner';
COMMENT ON COLUMN dbm_variables$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_variables$.name IS 'Variable name';
COMMENT ON COLUMN dbm_variables$.value IS 'Variable value';
COMMENT ON COLUMN dbm_variables$.seq IS 'Sequence of entry';
COMMENT ON COLUMN dbm_variables$.descr IS 'Description used as prompt';
COMMENT ON COLUMN dbm_variables$.data_type IS 'Data type';
COMMENT ON COLUMN dbm_variables$.nullable IS 'Optional (Y/N)?';
COMMENT ON COLUMN dbm_variables$.convert_value_sql IS 'SQL to convert value';
COMMENT ON COLUMN dbm_variables$.check_value_sql IS 'SQL to check value';
COMMENT ON COLUMN dbm_variables$.default_value_sql IS 'SQL for default value';
COMMENT ON COLUMN dbm_variables$.check_error_msg IS 'Error message for bad values';
COMMENT ON COLUMN dbm_variables$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_var_pk ON dbm_variables$ (owner, app_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_variables$ ADD CONSTRAINT dbm_var_pk PRIMARY KEY (owner, app_code, name) USING INDEX
;

ALTER TABLE dbm_variables$ ADD (
   CONSTRAINT dbm_var_app_fk FOREIGN KEY (owner, app_code)
   REFERENCES dbm_applications$ (owner, app_code)
);

CREATE INDEX dbm_var_app_fk_i ON dbm_variables$ (owner, app_code)
TABLESPACE &&idx_ts
;

PROMPT Creating parameters table...
CREATE TABLE dbm_parameters$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , name VARCHAR2(30) NOT NULL
 , value VARCHAR2(4000) NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_parameters$ IS 'Application parameters';
COMMENT ON COLUMN dbm_parameters$.owner IS 'Owner';
COMMENT ON COLUMN dbm_parameters$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_parameters$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_parameters$.name IS 'Application name';
COMMENT ON COLUMN dbm_parameters$.value IS 'Application value';
COMMENT ON COLUMN dbm_parameters$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_par_pk ON dbm_parameters$ (owner, app_code, ver_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_parameters$ ADD CONSTRAINT dbm_par_pk PRIMARY KEY (owner, app_code, ver_code, name) USING INDEX
;

ALTER TABLE dbm_parameters$ ADD (
   CONSTRAINT dbm_par_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
);

CREATE INDEX dbm_par_ver_fk_i ON dbm_parameters$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating privileges table...
CREATE TABLE dbm_privileges$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , text VARCHAR2(400) NOT NULL -- name + object owner/name for pk
 , type VARCHAR2(30) NOT NULL CONSTRAINT dbm_prv_type_ck CHECK (type IN ('SYSPRIV','TABPRIV','ROLEPRIV'))
 , name VARCHAR2(400) NOT NULL -- privilege or role
 , direct_flag VARCHAR2(1) NULL -- directly granted privilege (Y/N)?
 , object_owner VARCHAR2(30) NULL -- for TABPRIV only
 , object_type VARCHAR2(30) NULL -- for TABPRIV only
 , object_name VARCHAR2(30) NULL -- for TABPRIV only
 , delegable VARCHAR2(1) NULL -- with admin or grant option
 , condition VARCHAR2(4000) NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_privileges$ IS 'Application privileges';
COMMENT ON COLUMN dbm_privileges$.owner IS 'Owner';
COMMENT ON COLUMN dbm_privileges$.app_code IS 'Application code';
COMMENT ON COLUMN dbm_privileges$.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_privileges$.text IS 'Privilege full text for PK';
COMMENT ON COLUMN dbm_privileges$.type IS 'Privilege type (SYSPRIV, TABPRIV, ROLE)';
COMMENT ON COLUMN dbm_privileges$.name IS 'Privilege/role name';
COMMENT ON COLUMN dbm_privileges$.direct_flag IS 'Is priv/role granted directly(Y/N)?';
COMMENT ON COLUMN dbm_privileges$.object_owner IS 'Object owner (for TABPRIV only)';
COMMENT ON COLUMN dbm_privileges$.object_type IS 'Object type (for TABPRIV only)';
COMMENT ON COLUMN dbm_privileges$.object_name IS 'Object name (for TABPRIV only)';
COMMENT ON COLUMN dbm_privileges$.delegable IS 'delegable privilege/role (Y/N)?';
COMMENT ON COLUMN dbm_privileges$.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_prv_pk ON dbm_privileges$ (owner, app_code, ver_code, text)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_privileges$ ADD CONSTRAINT dbm_prv_pk PRIMARY KEY (owner, app_code, ver_code, text) USING INDEX
;

ALTER TABLE dbm_privileges$ ADD (
   CONSTRAINT dbm_prv_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
);

CREATE INDEX dbm_prv_ver_fk_i ON dbm_privileges$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating commands table...
CREATE SEQUENCE dbm_cmd_seq
;

CREATE TABLE dbm_commands$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , cmd_id NUMBER(9) DEFAULT dbm_cmd_seq.NEXTVAL NOT NULL
 , command_line VARCHAR2(4000) NOT NULL
 , start_date_time DATE NOT NULL
 , end_date_time DATE NULL
 , log_file_name VARCHAR2(500) NULL
 , status VARCHAR2(10) NULL -- ONGOING, SUCCESS, ERROR
 , exit_code NUMBER(5) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_commands$ IS 'Command';
COMMENT ON COLUMN dbm_commands$.owner IS 'Owner';
COMMENT ON COLUMN dbm_commands$.cmd_id IS 'Command id';
COMMENT ON COLUMN dbm_commands$.command_line IS 'Command line';
COMMENT ON COLUMN dbm_commands$.start_date_time IS 'Start date and time';
COMMENT ON COLUMN dbm_commands$.end_date_time IS 'End data and time';
COMMENT ON COLUMN dbm_commands$.log_file_name IS 'Log file name';
COMMENT ON COLUMN dbm_commands$.status IS 'Command status';
COMMENT ON COLUMN dbm_commands$.exit_code IS 'Command exit code';


CREATE UNIQUE INDEX dbm_cmd_pk ON dbm_commands$ (owner, cmd_id)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_commands$ ADD CONSTRAINT dbm_cmd_pk PRIMARY KEY (owner, cmd_id) USING INDEX
;

PROMPT Creating command streams table...

CREATE TABLE dbm_streams$ (
   owner VARCHAR2(30) DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
 , cmd_id NUMBER(9) NOT NULL
 , type VARCHAR2(3) NOT NULL CONSTRAINT dbm_str_type_ck CHECK (type IN ('IN','IN2','IN3','OUT'))
 , line NUMBER(9) NOT NULL
 , text VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_streams$ IS 'Command streams';
COMMENT ON COLUMN dbm_streams$.cmd_id IS 'Owner';
COMMENT ON COLUMN dbm_streams$.cmd_id IS 'Command id';
COMMENT ON COLUMN dbm_streams$.type IS 'Command type';
COMMENT ON COLUMN dbm_streams$.line IS 'Line number';
COMMENT ON COLUMN dbm_streams$.text IS 'Text or code';

CREATE UNIQUE INDEX dbm_str_pk ON dbm_streams$ (owner, cmd_id, type, line)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_streams$ ADD CONSTRAINT dbm_str_pk PRIMARY KEY (owner, cmd_id, type, line) USING INDEX
;

ALTER TABLE dbm_streams$ ADD (
   CONSTRAINT dbm_str_cmd_fk FOREIGN KEY (owner, cmd_id)
   REFERENCES dbm_commands$ (owner, cmd_id)
);

--CREATE INDEX dbm_str_cmd_fk_i ON dbm_streams$ (owner, cmd_id)
--TABLESPACE &&idx_ts
--;

CREATE OR REPLACE VIEW dbm_all_applications(
  owner
, app_code
, app_alias
, seq
, ver_code
, ver_status
, home_dir
, exposed_flag
, deleted_flag
)
AS
SELECT DISTINCT app.owner
     , app.app_code
     , app.app_alias
     , app.seq
     , app.ver_code
     , app.ver_status
     , app.home_dir
     , app.exposed_flag
     , app.deleted_flag
  FROM dbm_applications$ app
 WHERE (app.owner = USER OR app.ver_code IS NOT NULL)
;

/*
SELECT REPLACE('CREATE OR REPLACE VIEW ' || REPLACE(LOWER(table_name),'$') || '(' || CHR(10)
    || sql_utility.format_columns_list(sql_utility.normalise_columns_list(table_name,'* BUT owner'),2,'Y',1) || CHR(10)
    || ')' || CHR(10)
    || 'AS' || CHR(10)
    || 'SELECT ' || sql_utility.format_columns_list(sql_utility.normalise_columns_list(table_name,'* BUT owner'),7,'N',1) || CHR(10)
    || '  FROM ' || LOWER(table_name) || CHR(10)
    || ' WHERE owner = SYS_CONTEXT("USERENV", "SESSION_USER")' || CHR(10)
    || 'WITH CHECK OPTION' || CHR(10)
    || ';' || CHR(10),'"','''')
 FROM user_tables
WHERE SUBSTR(table_name,1,4) = 'DBM_'
ORDER BY table_name;
*/

CREATE OR REPLACE VIEW dbm_applications(
  app_code
, app_alias
, seq
, ver_code
, ver_status
, home_dir
, exposed_flag
, deleted_flag
)
AS
SELECT app_code
     , app_alias
     , seq
     , ver_code
     , ver_status
     , home_dir
     , exposed_flag
     , deleted_flag
  FROM dbm_applications$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_commands(
  cmd_id
, command_line
, start_date_time
, end_date_time
, log_file_name
, status
, exit_code
)
AS
SELECT cmd_id
     , command_line
     , start_date_time
     , end_date_time
     , log_file_name
     , status
     , exit_code
  FROM dbm_commands$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_files(
  app_code
, ver_code
, path
, type
, run_condition
, seq
, hash
, status
, run_status
, run_date
, deleted_flag
)
AS
SELECT app_code
     , ver_code
     , path
     , type
     , run_condition
     , seq
     , hash
     , status
     , run_status
     , run_date
     , deleted_flag
  FROM dbm_files$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_objects(
  app_code
, ver_code
, name
, checksum
, condition
, deleted_flag
)
AS
SELECT app_code
     , ver_code
     , name
     , checksum
     , condition
     , deleted_flag
  FROM dbm_objects$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_parameters(
  app_code
, ver_code
, name
, value
, deleted_flag
)
AS
SELECT app_code
     , ver_code
     , name
     , value
     , deleted_flag
  FROM dbm_parameters$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

CREATE OR REPLACE VIEW dbm_privileges(
  app_code
, ver_code
, text
, type
, name
, direct_flag
, object_owner
, object_type
, object_name
, delegable
, condition
, deleted_flag
)
AS
SELECT app_code
     , ver_code
     , text
     , type
     , name
     , direct_flag
     , object_owner
     , object_type
     , object_name
     , delegable
     , condition
     , deleted_flag
  FROM dbm_privileges$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

CREATE OR REPLACE VIEW dbm_streams(
  cmd_id
, type
, line
, text
)
AS
SELECT cmd_id
     , type
     , line
     , text
  FROM dbm_streams$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_variables(
  app_code
, name
, value
, seq
, descr
, data_type
, nullable
, convert_value_sql
, check_value_sql
, default_value_sql
, check_error_msg
, deleted_flag
)
AS
SELECT app_code
     , name
     , value
     , seq
     , descr
     , data_type
     , nullable
     , convert_value_sql
     , check_value_sql
     , default_value_sql
     , check_error_msg
     , deleted_flag
  FROM dbm_variables$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;


CREATE OR REPLACE VIEW dbm_versions(
  app_code
, ver_code
, ver_nbr
, ver_status
, next_op_type
, last_op_type
, last_op_status
, last_op_date
, installable
, install_rollbackable
, upgradeable
, upgrade_rollbackable
, uninstallable
, validable
, precheckable
, setupable
, exposable
, concealable
, deleted_flag
)
AS
SELECT app_code
     , ver_code
     , ver_nbr
     , ver_status
     , next_op_type
     , last_op_type
     , last_op_status
     , last_op_date
     , installable
     , install_rollbackable
     , upgradeable
     , upgrade_rollbackable
     , uninstallable
     , validable
     , precheckable
     , setupable
     , exposable
     , concealable
     , deleted_flag
  FROM dbm_versions$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;
