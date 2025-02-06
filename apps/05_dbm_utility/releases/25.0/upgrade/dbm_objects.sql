REM DBM-00010: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DBM_ALL_APPLICATIONS' AND column_name='NEXT_VER_CODE')
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
, next_ver_code
, next_ver_op_type
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
     , ver.ver_code next_ver_code
     , ver.next_op_type next_ver_op_type
  FROM dbm_applications$ app
  LEFT OUTER JOIN dbm_versions$ ver
    ON ver.owner = app.owner
   AND ver.app_code = app.app_code
   AND ver.ver_status = 'NEXT'
 WHERE (app.owner = USER OR app.ver_code IS NOT NULL)
;