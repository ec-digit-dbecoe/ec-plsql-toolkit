set termout on
set scan on
set feedback off
set verify off
whenever sqlerror exit
PROMPT Copying configuration from "&src_app_alias" to "&app_alias"...
DECLARE
   CURSOR c_dict IS
      SELECT *
        FROM qc_dictionary_entries
       WHERE app_alias = '&src_app_alias'
         AND dict_name != 'APP SCHEMA'
   ;
   CURSOR c_pat IS
      SELECT *
        FROM qc_patterns
       WHERE app_alias = '&src_app_alias'
   ;
BEGIN
   <<dict_delete>>
   DELETE qc_dictionary_entries
    WHERE app_alias = '&app_alias'
      AND dict_name != 'APP SCHEMA'
   ;
   <<pat_delete>>
   DELETE qc_patterns
    WHERE app_alias = '&app_alias'
   ;
   <<dict_loop>>
   FOR r_dict IN c_dict LOOP
      r_dict.app_alias := '&app_alias';
      INSERT INTO qc_dictionary_entries VALUES r_dict;
   END LOOP dict_loop;
   <<pat_loop>>
   FOR r_pat IN c_pat LOOP
      r_pat.app_alias := '&app_alias';
      INSERT INTO qc_patterns VALUES r_pat;
   END LOOP pat_loop;
END;
/
COMMIT;
PROMPT Configuration copied successfully!