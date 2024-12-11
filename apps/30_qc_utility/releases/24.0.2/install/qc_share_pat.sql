set termout on
set scan on
set feedback off
set verify off
whenever sqlerror exit
PROMPT Sharing configuration of application "&app_alias"...
BEGIN
   UPDATE qc_dictionary_entries
      SET app_alias = 'ALL'
    WHERE app_alias = '&app_alias'
      AND dict_name != 'APP SCHEMA'
   ;
   DELETE qc_dictionary_entries
    WHERE app_alias != 'ALL'
      AND dict_name != 'APP SCHEMA'
   ;
   UPDATE qc_patterns
      SET app_alias = 'ALL'
    WHERE app_alias = '&app_alias'
   ;
   DELETE qc_patterns
    WHERE app_alias != 'ALL'
   ;
END;
/
COMMIT;
PROMPT Configuration shared successfully!