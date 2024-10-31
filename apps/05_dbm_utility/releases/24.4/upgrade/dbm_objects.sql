PROMPT Re-creating view dbm_all_applications...
CREATE OR REPLACE VIEW dbm_all_applications(
  owner
, app_code
, seq
, ver_code
, ver_status
, home_dir
, deleted_flag
, granted_flag
)
AS
SELECT DISTINCT app.owner
     , app.app_code
     , app.seq
     , app.ver_code
     , app.ver_status
     , app.home_dir
     , app.deleted_flag
     , CASE WHEN grt.grantee IS NOT NULL THEN 'Y' ELSE 'N' END granted_flag
  FROM dbm_applications$ app
 INNER JOIN dbm_parameters$ par
    ON par.owner = app.owner
   AND par.app_code = app.app_code
   AND par.name = 'expose_pattern'
  LEFT OUTER JOIN all_objects obj
    ON obj.owner = app.owner
   AND REGEXP_LIKE (obj.object_type || ' ' || obj.object_name, par.value)
   AND obj.object_type||' '||obj.object_name != 'VIEW DBM_ALL_APPLICATIONS'
  LEFT OUTER JOIN all_tab_privs grt
    ON grt.grantor = app.owner
   AND grt.grantee IN (USER, 'PUBLIC')
   AND grt.table_schema = app.owner
   AND grt.table_name = obj.object_name
 WHERE (app.owner = USER OR app.ver_code IS NOT NULL)
;