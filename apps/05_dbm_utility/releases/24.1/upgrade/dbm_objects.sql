PROMPT Creating parameters table...
CREATE TABLE dbm_parameters (
   app_code VARCHAR2(30) NOT NULL
 , ver_code VARCHAR2(8) NOT NULL
 , name VARCHAR2(30) NOT NULL
 , value VARCHAR2(4000) NULL
 , deleted_flag VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE dbm_parameters IS 'Application parameters';
COMMENT ON COLUMN dbm_parameters.app_code IS 'Application code';
COMMENT ON COLUMN dbm_parameters.ver_code IS 'Version code';
COMMENT ON COLUMN dbm_parameters.name IS 'Application name';
COMMENT ON COLUMN dbm_parameters.value IS 'Application value';
COMMENT ON COLUMN dbm_parameters.deleted_flag IS 'Logically deleted (Y/N)?';

CREATE UNIQUE INDEX dbm_par_pk ON dbm_parameters (app_code, ver_code, name)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_parameters ADD CONSTRAINT dbm_par_pk PRIMARY KEY (app_code, ver_code, name) USING INDEX
;

ALTER TABLE dbm_parameters ADD (
   CONSTRAINT dbm_par_ver_fk FOREIGN KEY (app_code, ver_code)
   REFERENCES dbm_versions (app_code, ver_code)
);

CREATE INDEX dbm_par_ver_fk_i ON dbm_parameters (app_code, ver_code)
TABLESPACE &&idx_ts
;

PROMPT Altering objects table...
ALTER TABLE dbm_objects ADD (
   condition VARCHAR2(4000) NULL
)
;

COMMENT ON COLUMN dbm_objects.condition IS 'Object condition'
;

PROMPT Altering applications table...
ALTER TABLE dbm_applications ADD (
   deleted_flag VARCHAR2(1) NULL -- Y/N
)
;

COMMENT ON COLUMN dbm_applications.deleted_flag IS 'Logically deleted (Y/N)?'
;

PROMPT Altering versions table...
ALTER TABLE dbm_versions ADD (
   deleted_flag VARCHAR2(1) NULL -- Y/N
)
;

COMMENT ON COLUMN dbm_versions.deleted_flag IS 'Logically deleted (Y/N)?'
;

PROMPT Altering files table...
ALTER TABLE dbm_files ADD (
   deleted_flag VARCHAR2(1) NULL
)
;

COMMENT ON COLUMN dbm_files.deleted_flag IS 'Logically deleted (Y/N)?'
;

PROMPT Altering objects table...
ALTER TABLE dbm_objects ADD (
   deleted_flag VARCHAR2(1) NULL
)
;

COMMENT ON COLUMN dbm_objects.deleted_flag IS 'Logically deleted (Y/N)?'
;

PROMPT Altering variables table...
ALTER TABLE dbm_variables ADD (
   deleted_flag VARCHAR2(1) NULL
)
;

COMMENT ON COLUMN dbm_variables.deleted_flag IS 'Logically deleted (Y/N)?'
;


