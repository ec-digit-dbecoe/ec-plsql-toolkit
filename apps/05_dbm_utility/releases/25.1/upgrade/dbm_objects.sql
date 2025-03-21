REM DBM-00300: NOT EXISTS (SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_FILES$' AND column_name='TRUSTED_HASH')
ALTER TABLE dbm_files$ ADD trusted_hash VARCHAR2(32 CHAR) NULL;

REM DBM-00302: NOT EXISTS (SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_FILES$' AND column_name='TRUSTED_STATUS')
ALTER TABLE dbm_files$ ADD trusted_status VARCHAR2(20 CHAR) NULL;

REM DBM-00304: NOT EXISTS (SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_FILES$' AND column_name='RUNTIME_HASH')
ALTER TABLE dbm_files$ RENAME COLUMN hash TO runtime_hash;

REM DBM-00306: NOT EXISTS (SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_FILES$' AND column_name='RUNTIME_STATUS')
ALTER TABLE dbm_files$ RENAME COLUMN status TO runtime_status;

REM DBM-00308: NOT EXISTS (SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_FILES$' AND column_name='CURRENT_HASH')
ALTER TABLE dbm_files$ ADD current_hash VARCHAR2(32 CHAR) NULL;

REM DBM-00310
COMMENT ON COLUMN dbm_files$.trusted_hash IS 'Trusted file hash (stored in files.dbm)';
COMMENT ON COLUMN dbm_files$.trusted_status IS 'Outcome of current and trusted hashes comparison';
COMMENT ON COLUMN dbm_files$.runtime_hash IS 'Runtime file hash (taken upon file execution)';
COMMENT ON COLUMN dbm_files$.runtime_status IS 'Outcome of current and runtime hashes comparison';
COMMENT ON COLUMN dbm_files$.current_hash IS 'Current file hash (most recently computed)';

REM DBM-01000
CREATE OR REPLACE VIEW dbm_files(
  app_code
, ver_code
, path
, type
, run_condition
, seq
, trusted_hash
, trusted_status
, runtime_hash
, runtime_status
, current_hash
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
     , trusted_hash
     , trusted_status
     , runtime_hash
     , runtime_status
     , current_hash
     , run_status
     , run_date
     , stmt_id
     , prompts
     , deleted_flag
  FROM dbm_files$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

REM DBM-02000
UPDATE dbm_files$
   SET runtime_status = 'VALID'
 WHERE runtime_status = 'NORMAL'
;

COMMIT
;

REM DBM-02010
DELETE dbm_files
 WHERE path IN (
   SELECT path FROM dbm_files WHERE REPLACE(path,'\','/') IN (
      SELECT REPLACE(path,'\','/') FROM dbm_files GROUP BY REPLACE(path,'\','/') HAVING COUNT(*)>1
   )
   AND run_status IS NULL
 )
;

UPDATE dbm_files$
   SET path = REPLACE(path, '\', '/')
 WHERE INSTR(path, '\') > 0
;

COMMIT
;