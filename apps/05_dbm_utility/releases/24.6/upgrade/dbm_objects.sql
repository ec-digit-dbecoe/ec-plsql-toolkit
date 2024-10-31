PROMPT Creating privileges$ table...
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

PROMPT Creating privileges view...
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