ALTER TABLE dbm_privileges$ ADD usage VARCHAR2(10 CHAR) NULL CONSTRAINT dbm_prv_usage_ck CHECK (usage IN ('MIGRATE','OPERATE'))
;

UPDATE dbm_privileges$ SET usage = 'MIGRATE'
;

ALTER TABLE dbm_privileges$ MODIFY usage NOT NULL
;

COMMENT ON COLUMN dbm_privileges$.usage IS 'Privilege usage (MIGRATE, OPERATE)';

ALTER TABLE dbm_privileges$ DROP CONSTRAINT dbm_prv_pk
;

DROP INDEX dbm_prv_pk
;

CREATE UNIQUE INDEX dbm_prv_pk ON dbm_privileges$ (owner, app_code, ver_code, text, usage)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_privileges$ ADD CONSTRAINT dbm_prv_pk PRIMARY KEY (owner, app_code, ver_code, text, usage) USING INDEX
;

CREATE OR REPLACE VIEW dbm_privileges(
  app_code
, ver_code
, text
, usage
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
     , usage
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

ALTER TABLE dbm_files$ ADD prompts VARCHAR2(4000 CHAR) NULL
;

COMMENT ON COLUMN dbm_files$.prompts IS 'File prompts'
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
, prompts
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
     , prompts
     , deleted_flag
  FROM dbm_files$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;