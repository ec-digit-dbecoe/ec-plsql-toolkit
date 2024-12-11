REM DBM-00010: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_VERSIONS$' AND column_name='EXPORTABLE')
ALTER TABLE dbm_versions$ ADD (
   exportable VARCHAR2(1 CHAR) NULL --Y/N
 , importable VARCHAR2(1 CHAR) NULL -- Y/N
);

REM DBM-00020
COMMENT ON COLUMN dbm_versions$.exportable IS 'Are export scripts available (Y/N)?';
COMMENT ON COLUMN dbm_versions$.importable IS 'Are import scripts available (Y/N)?';

REM DBM-00030
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
, exportable
, importable
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
     , exportable
     , importable
     , deleted_flag
  FROM dbm_versions$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

REM DBM-00040
COMMENT ON COLUMN dbm_privileges$.delegable IS 'Delegable privilege/role (Y/N)?';
