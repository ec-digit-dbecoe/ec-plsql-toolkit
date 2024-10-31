set verify off

PROMPT Dropping all DBM database objects...
DECLARE
   CURSOR c_obj IS
      SELECT object_type, object_name
           , CASE WHEN object_type = 'TABLE' THEN ' CASCADE CONSTRAINTS' END drop_type
        FROM user_objects
       WHERE SUBSTR(object_name,1,4) = 'DBM_'
         AND object_type IN ('CONSTRAINT',/*'PACKAGE',*/'TABLE','SEQUENCE'/*,'VIEW','TYPE'*/)
       ORDER BY 1, LENGTH(object_name) DESC, 2
      ;
   l_sql VARCHAR2(4000);
BEGIN
   FOR r_obj IN c_obj LOOP
      l_sql := 'DROP '||r_obj.object_type||' '||LOWER(r_obj.object_name)||r_obj.drop_type;
      dbms_output.put_line(l_sql);
      BEGIN
         EXECUTE IMMEDIATE l_sql;
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
      END;
   END LOOP;
END;
/

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
CREATE TABLE dbm_applications (
   app_code VARCHAR2(30) NOT NULL
 , seq NUMBER(3) NULL
 , ver_code VARCHAR2(30) NULL
 , ver_status VARCHAR2(30) NULL -- VALID, INVALID, MIGRATING
 , home_dir VARCHAR2(200) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_applications IS 'Applications';
COMMENT ON COLUMN dbm_applications.app_code IS 'Application code';
COMMENT ON COLUMN dbm_applications.seq IS 'Sequence of migration';
COMMENT ON COLUMN dbm_applications.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_applications.ver_status IS 'Version status';
COMMENT ON COLUMN dbm_applications.home_dir IS 'Home directory';

CREATE UNIQUE INDEX dbm_app_pk ON dbm_applications (app_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_applications ADD CONSTRAINT dbm_app_pk PRIMARY KEY (app_code) USING INDEX
;

PROMPT Creating versions table...
CREATE TABLE dbm_versions (
   app_code VARCHAR2(30) NOT NULL
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
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_versions IS 'Application versions';
COMMENT ON COLUMN dbm_versions.app_code IS 'Application code';
COMMENT ON COLUMN dbm_versions.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_versions.ver_nbr IS 'Version number';
COMMENT ON COLUMN dbm_versions.ver_status IS 'Version status';
COMMENT ON COLUMN dbm_versions.next_op_type IS 'Next expected operation';
COMMENT ON COLUMN dbm_versions.last_op_type IS 'Last executed operation';
COMMENT ON COLUMN dbm_versions.last_op_date IS 'Last operation date and time';
COMMENT ON COLUMN dbm_versions.installable IS 'Are full installation script available (Y/N)?';
COMMENT ON COLUMN dbm_versions.install_rollbackable IS 'Are installation rollback scripts availale (Y/N)?';
COMMENT ON COLUMN dbm_versions.upgradeable IS 'Are incremental upgrade scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions.validable IS 'Are upgrade rollback scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions.precheckable IS 'Are pre-migration scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions.setupable IS 'Are setup scripts available (Y/N)?';

CREATE UNIQUE INDEX dbm_ver_pk ON dbm_versions (app_code, ver_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions ADD CONSTRAINT dbm_ver_pk UNIQUE (app_code, ver_code) USING INDEX
;

CREATE UNIQUE INDEX dbm_ver_uk ON dbm_versions (app_code, ver_nbr)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions ADD CONSTRAINT dbm_ver_uk PRIMARY KEY (app_code, ver_nbr) USING INDEX
;

ALTER TABLE dbm_versions ADD (
   CONSTRAINT dbm_ver_app_fk FOREIGN KEY (app_code)
   REFERENCES dbm_applications (app_code)
)
;

CREATE INDEX dbm_ver_app_fk_i ON dbm_versions (app_code)
TABLESPACE &&idx_ts
;

PROMPT Creating files table...
CREATE TABLE dbm_files (
   app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , path VARCHAR2(4000) NOT NULL
 , type VARCHAR(20) NOT NULL --INSTALL, UPGRADE, ROLLBACK INSTALL, ROLLBACK UPGRADE, VALIDATE, UNINSTALL, FORCE CURRENT
 , run_condition VARCHAR2(4000) NULL
 , seq NUMBER(9) NOT NULL
 , hash VARCHAR2(32) NULL
 , status VARCHAR2(20) NULL -- NORMAL, MISSING, TAMPERED
 , run_status VARCHAR2(20) -- ONGOING, SUCCESS, ERROR, ROLLED BACK
 , run_date DATE NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_files IS 'Version files';
COMMENT ON COLUMN dbm_files.app_code IS 'Application code';
COMMENT ON COLUMN dbm_files.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_files.path IS 'Full path name';
COMMENT ON COLUMN dbm_files.type IS 'Usage type';
COMMENT ON COLUMN dbm_files.run_condition IS 'Run condition';
COMMENT ON COLUMN dbm_files.seq IS 'Sequence of execution';
COMMENT ON COLUMN dbm_files.hash IS 'Hash value';
COMMENT ON COLUMN dbm_files.status IS 'File status';
COMMENT ON COLUMN dbm_files.run_status IS 'Run status';
COMMENT ON COLUMN dbm_files.run_date IS 'Run date/time';

CREATE UNIQUE INDEX dbm_fil_pk ON dbm_files (path)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_files ADD CONSTRAINT dbm_fil_pk PRIMARY KEY (path) USING INDEX
;

ALTER TABLE dbm_files ADD (
   CONSTRAINT dbm_fil_ver_fk FOREIGN KEY (app_code, ver_code)
   REFERENCES dbm_versions (app_code, ver_code)
)
;

CREATE INDEX dbm_fil_ver_fk_i ON dbm_files (app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating objects table...
CREATE TABLE dbm_objects (
   app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , name VARCHAR2(128) NOT NULL
 , checksum VARCHAR2(20) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_objects IS 'Database objects';
COMMENT ON COLUMN dbm_objects.app_code IS 'Application code';
COMMENT ON COLUMN dbm_objects.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_objects.name IS 'Object type and name';
COMMENT ON COLUMN dbm_objects.checksum IS 'Object checksum';

CREATE UNIQUE INDEX dbm_obj_pk ON dbm_objects (app_code, ver_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_objects ADD CONSTRAINT dbm_obj_pk PRIMARY KEY (app_code, ver_code, name) USING INDEX
;

ALTER TABLE dbm_objects ADD (
   CONSTRAINT dbm_obj_ver_fk FOREIGN KEY (app_code, ver_code)
   REFERENCES dbm_versions (app_code, ver_code)
)
;

CREATE INDEX dbm_obj_ver_fk_i ON dbm_objects (app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Creating variables table...
CREATE TABLE dbm_variables (
   app_code VARCHAR2(30) NOT NULL
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
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_variables IS 'Application variables';
COMMENT ON COLUMN dbm_variables.app_code IS 'Application code';
COMMENT ON COLUMN dbm_variables.name IS 'Variable name';
COMMENT ON COLUMN dbm_variables.value IS 'Variable value';
COMMENT ON COLUMN dbm_variables.seq IS 'Sequence of entry';
COMMENT ON COLUMN dbm_variables.descr IS 'Description used as prompt';
COMMENT ON COLUMN dbm_variables.data_type IS 'Data type';
COMMENT ON COLUMN dbm_variables.nullable IS 'Optional (Y/N)?';
COMMENT ON COLUMN dbm_variables.convert_value_sql IS 'SQL to convert value';
COMMENT ON COLUMN dbm_variables.check_value_sql IS 'SQL to check value';
COMMENT ON COLUMN dbm_variables.default_value_sql IS 'SQL for default value ';
COMMENT ON COLUMN dbm_variables.check_error_msg IS 'Error message for bad values';

CREATE UNIQUE INDEX dbm_var_pk ON dbm_variables (app_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_variables ADD CONSTRAINT dbm_var_pk PRIMARY KEY (app_code, name) USING INDEX
;

ALTER TABLE dbm_variables ADD (
   CONSTRAINT dbm_var_app_fk FOREIGN KEY (app_code)
   REFERENCES dbm_applications (app_code)
);

CREATE INDEX dbm_var_app_fk_i ON dbm_variables (app_code)
TABLESPACE &&idx_ts
;

PROMPT Creating commands table...
CREATE SEQUENCE dbm_cmd_seq
;

CREATE TABLE dbm_commands (
   cmd_id NUMBER(9) DEFAULT dbm_cmd_seq.NEXTVAL NOT NULL
 , command_line VARCHAR2(4000) NOT NULL
 , start_date_time DATE NOT NULL
 , end_date_time DATE NULL
 , log_file_name VARCHAR2(500) NULL
 , status VARCHAR2(10) NULL -- ONGOING, SUCCESS, ERROR
 , exit_code NUMBER(5) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_commands IS 'Command';
COMMENT ON COLUMN dbm_commands.cmd_id IS 'Command id';
COMMENT ON COLUMN dbm_commands.command_line IS 'Command line';
COMMENT ON COLUMN dbm_commands.start_date_time IS 'Start date and time';
COMMENT ON COLUMN dbm_commands.end_date_time IS 'End data and time';
COMMENT ON COLUMN dbm_commands.log_file_name IS 'Log file name';
COMMENT ON COLUMN dbm_commands.status IS 'Command status';
COMMENT ON COLUMN dbm_commands.exit_code IS 'Command exit code';


CREATE UNIQUE INDEX dbm_cmd_pk ON dbm_commands (cmd_id)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_commands ADD CONSTRAINT dbm_cmd_pk PRIMARY KEY (cmd_id) USING INDEX
;

PROMPT Creating command streams table...

CREATE TABLE dbm_streams (
   cmd_id NUMBER(9) NOT NULL
 , type VARCHAR2(3) NOT NULL CONSTRAINT dbm_str_type_ck CHECK (type IN ('IN','IN2','IN3','OUT'))
 , line NUMBER(9) NOT NULL
 , text VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_streams IS 'Command streams';
COMMENT ON COLUMN dbm_streams.cmd_id IS 'Command id';
COMMENT ON COLUMN dbm_streams.type IS 'Command type';
COMMENT ON COLUMN dbm_streams.line IS 'Line number';
COMMENT ON COLUMN dbm_streams.text IS 'Text or code';

CREATE UNIQUE INDEX dbm_str_pk ON dbm_streams (cmd_id, type, line)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_streams ADD CONSTRAINT dbm_str_pk PRIMARY KEY (cmd_id, type, line) USING INDEX
;

ALTER TABLE dbm_streams ADD (
   CONSTRAINT dbm_str_cmd_fk FOREIGN KEY (cmd_id)
   REFERENCES dbm_commands (cmd_id)
);

--CREATE INDEX dbm_str_cmd_fk_i ON dbm_streams (cmd_id)
--TABLESPACE &&idx_ts
--;
