set termout on
set scan on
set feedback off
set verify off
whenever sqlerror exit
PROMPT Unsharing configuration...
DECLARE
   CURSOR c_app IS
      SELECT app_alias
        FROM qc_apps
       WHERE app_alias != 'ALL'
       ORDER BY app_alias
   ;
   CURSOR c_dict IS
      SELECT *
        FROM qc_dictionary_entries
       WHERE app_alias = 'ALL'
         AND SUBSTR(dict_name,-5) != ' WORD'
   ;
   CURSOR c_pat IS
      SELECT *
        FROM qc_patterns
       WHERE app_alias = 'ALL'
   ;
BEGIN
   <<app_loop>>
   FOR r_app IN c_app LOOP
      <<dict_loop>>
      FOR r_dict IN c_dict LOOP
         r_dict.app_alias := r_app.app_alias;
         INSERT INTO qc_dictionary_entries VALUES r_dict;
      END LOOP dict_loop;
      <<pat_loop>>
      FOR r_pat IN c_pat LOOP
         r_pat.app_alias := r_app.app_alias;
         INSERT INTO qc_patterns VALUES r_pat;
      END LOOP pat_loop;
   END LOOP app_loop;
   DELETE qc_dictionary_entries
    WHERE app_alias = 'ALL'
      AND SUBSTR(dict_name,-5) != ' WORD'
    ;
   DELETE qc_patterns
    WHERE app_alias = 'ALL'
   ;
END;
/
COMMIT;
PROMPT Configuration unshared successfully!