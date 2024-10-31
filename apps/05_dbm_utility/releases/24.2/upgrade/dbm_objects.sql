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

PROMPT Altering applications table...
RENAME dbm_applications TO dbm_applications$;
ALTER TABLE dbm_applications$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;
COMMENT ON COLUMN dbm_applications$.owner IS 'Owner';

ALTER TABLE dbm_applications$ DROP CONSTRAINT dbm_app_pk CASCADE
;

DROP INDEX dbm_app_pk;

CREATE UNIQUE INDEX dbm_app_pk ON dbm_applications$ (owner, app_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_applications$ ADD CONSTRAINT dbm_app_pk PRIMARY KEY (owner, app_code) USING INDEX
;

PROMPT Altering versions table...
RENAME dbm_versions TO dbm_versions$;
ALTER TABLE dbm_versions$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_versions$.owner IS 'Owner';

ALTER TABLE dbm_versions$ DROP CONSTRAINT dbm_ver_pk CASCADE
;

DROP INDEX dbm_ver_pk
;

CREATE UNIQUE INDEX dbm_ver_pk ON dbm_versions$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_pk UNIQUE (owner, app_code, ver_code) USING INDEX
;

ALTER TABLE dbm_versions$ DROP CONSTRAINT dbm_ver_uk
;

DROP INDEX dbm_ver_uk
;

CREATE UNIQUE INDEX dbm_ver_uk ON dbm_versions$ (owner, app_code, ver_nbr)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_uk PRIMARY KEY (owner, app_code, ver_nbr) USING INDEX
;

ALTER TABLE dbm_versions$ ADD (
   CONSTRAINT dbm_ver_app_fk FOREIGN KEY (owner, app_code)
   REFERENCES dbm_applications$ (owner, app_code)
)
;

DROP INDEX dbm_ver_app_fk_i
;

CREATE INDEX dbm_ver_app_fk_i ON dbm_versions$ (owner, app_code)
TABLESPACE &&idx_ts
;

PROMPT Altering files table...
RENAME dbm_files TO dbm_files$;
ALTER TABLE dbm_files$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_files$.owner IS 'Owner';

ALTER TABLE dbm_files$ DROP CONSTRAINT dbm_fil_pk CASCADE
;

DROP INDEX dbm_fil_pk
;

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

DROP INDEX dbm_fil_ver_fk_i
;

CREATE INDEX dbm_fil_ver_fk_i ON dbm_files$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Altering objects table...
RENAME dbm_objects TO dbm_objects$;
ALTER TABLE dbm_objects$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_objects$.owner IS 'Owner';

ALTER TABLE dbm_objects$ DROP CONSTRAINT dbm_obj_pk CASCADE
;

DROP INDEX dbm_obj_pk
;

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

DROP INDEX dbm_obj_ver_fk_i
;

CREATE INDEX dbm_obj_ver_fk_i ON dbm_objects$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Altering variables table...
RENAME dbm_variables TO dbm_variables$;
ALTER TABLE dbm_variables$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_variables$.owner IS 'Owner';

ALTER TABLE dbm_variables$ DROP CONSTRAINT dbm_var_pk CASCADE
;

DROP INDEX dbm_var_pk
;

CREATE UNIQUE INDEX dbm_var_pk ON dbm_variables$ (owner, app_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_variables$ ADD CONSTRAINT dbm_var_pk PRIMARY KEY (owner, app_code, name) USING INDEX
;

ALTER TABLE dbm_variables$ ADD (
   CONSTRAINT dbm_var_app_fk FOREIGN KEY (owner, app_code)
   REFERENCES dbm_applications$ (owner, app_code)
);

DROP INDEX dbm_var_app_fk_i
;

CREATE INDEX dbm_var_app_fk_i ON dbm_variables$ (owner, app_code)
TABLESPACE &&idx_ts
;

PROMPT Altering parameters table...
RENAME dbm_parameters TO dbm_parameters$;
ALTER TABLE dbm_parameters$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_parameters$.owner IS 'Owner';

ALTER TABLE dbm_parameters$ DROP CONSTRAINT dbm_par_pk CASCADE
;

DROP INDEX dbm_par_pk
;

CREATE UNIQUE INDEX dbm_par_pk ON dbm_parameters$ (owner, app_code, ver_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_parameters$ ADD CONSTRAINT dbm_par_pk PRIMARY KEY (owner, app_code, ver_code, name) USING INDEX
;

ALTER TABLE dbm_parameters$ ADD (
   CONSTRAINT dbm_par_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
);

DROP INDEX dbm_par_ver_fk_i
;

CREATE INDEX dbm_par_ver_fk_i ON dbm_parameters$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Altering commands table...
RENAME dbm_commands TO dbm_commands$;
ALTER TABLE dbm_commands$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_commands$.owner IS 'Owner';

ALTER TABLE dbm_commands$ DROP CONSTRAINT dbm_cmd_pk CASCADE
;

DROP INDEX dbm_cmd_pk
;

CREATE UNIQUE INDEX dbm_cmd_pk ON dbm_commands$ (owner, cmd_id)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_commands$ ADD CONSTRAINT dbm_cmd_pk PRIMARY KEY (owner, cmd_id) USING INDEX
;

PROMPT Altering command streams table...
RENAME dbm_streams TO dbm_streams$;
ALTER TABLE dbm_streams$ ADD owner VARCHAR2(30) DEFAULT USER NOT NULL;

COMMENT ON COLUMN dbm_streams$.cmd_id IS 'Owner';

ALTER TABLE dbm_streams$ DROP CONSTRAINT dbm_str_pk CASCADE
;

DROP INDEX dbm_str_pk
;

CREATE UNIQUE INDEX dbm_str_pk ON dbm_streams$ (owner, cmd_id, type, line)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_streams$ ADD CONSTRAINT dbm_str_pk PRIMARY KEY (owner, cmd_id, type, line) USING INDEX
;

ALTER TABLE dbm_streams$ ADD (
   CONSTRAINT dbm_str_cmd_fk FOREIGN KEY (owner, cmd_id)
   REFERENCES dbm_commands$ (owner, cmd_id)
);

PROMPT Altering table dbm_versions$
ALTER TABLE dbm_versions$ ADD (
   exposable VARCHAR2(1) NULL --Y/N
 , concealable VARCHAR2(1) NULL --Y/N
);

CREATE OR REPLACE VIEW dbm_all_applications(
  owner
, app_code
, seq
, ver_code
, ver_status
, home_dir
, deleted_flag
)
AS
SELECT owner
     , app_code
     , seq
     , ver_code
     , ver_status
     , home_dir
     , deleted_flag
  FROM dbm_applications$
 WHERE ver_code IS NOT NULL
;

/*
SELECT 'CREATE OR REPLACE VIEW ' || REPLACE(LOWER(table_name),'$') || '(' || CHR(10)
    || sql_utility.format_columns_list(sql_utility.normalise_columns_list(table_name,'* BUT owner'),2,'Y',1) || CHR(10)
    || ')' || CHR(10)
    || 'AS' || CHR(10)
    || 'SELECT ' || sql_utility.format_columns_list(sql_utility.normalise_columns_list(table_name,'* BUT owner'),7,'N',1) || CHR(10)
    || '  FROM ' || LOWER(table_name) || CHR(10)
    || ' WHERE owner = userenv(''SCHEMAID'')' || CHR(10)
    || 'WITH CHECK OPTION' || CHR(10)
    || ';' || CHR(10) || CHR(10)
 FROM user_tables
WHERE SUBSTR(table_name,1,4) = 'DBM_'
ORDER BY table_name;
*/

CREATE OR REPLACE VIEW dbm_applications(
  app_code
, seq
, ver_code
, ver_status
, home_dir
, deleted_flag
)
AS
SELECT app_code
     , seq
     , ver_code
     , ver_status
     , home_dir
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
