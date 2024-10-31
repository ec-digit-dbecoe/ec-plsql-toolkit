REM DBM-00010
PROMPT Altering files$ table...
ALTER TABLE dbm_files$ ADD stmt_id NUMBER(5) NULL
;

REM DBM-00020
COMMENT ON COLUMN dbm_files$.stmt_id IS 'Id of last statement executed';

REM DBM-00030
PROMPT Altering files view...
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
, stmt_id
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
     , stmt_id
     , prompts
     , deleted_flag
  FROM dbm_files$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

REM DBM-99999