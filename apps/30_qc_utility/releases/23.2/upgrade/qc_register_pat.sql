set termout on
set define on
set scan on
set feedback off
set verify off
whenever sqlerror exit
PROMPT Adding pattern for procedure, function and label identifiers...
DECLARE
   CURSOR c_app IS
      SELECT DISTINCT app_alias
        FROM qc_patterns
   ;
BEGIN
   FOR r_app IN c_app LOOP
      qc_utility_krn.insert_pattern(r_app.app_alias,'IDENTIFIER: PROCEDURE', '', '', 'E');
      qc_utility_krn.insert_pattern(r_app.app_alias,'IDENTIFIER: FUNCTION', '', '', 'E');
      qc_utility_krn.insert_pattern(r_app.app_alias,'IDENTIFIER: LABEL', '', '', 'E');
   END LOOP;
   COMMIT;
END;
/
