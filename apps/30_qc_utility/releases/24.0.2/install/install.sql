set define off
set define on
PROMPT Creating database objects...
@@qc_objects
set define off
PROMPT Creating package spec QC_UTILITY_LIC...
@@QC_UTILITY_LIC.pks
PROMPT Creating package spec QC_UTILITY_STAT...
@@QC_UTILITY_STAT.pks
PROMPT Creating package spec QC_UTILITY_MSG...
@@QC_UTILITY_MSG.pks
PROMPT Creating package spec QC_UTILITY_ORA_04068...
@@QC_UTILITY_ORA_04068.pks
PROMPT Creating package spec QC_UTILITY_VAR...
@@QC_UTILITY_VAR.pks
PROMPT Creating package spec QC_UTILITY_KRN...
@@QC_UTILITY_KRN.pks
PROMPT Creating package body QC_UTILITY_STAT...
@@QC_UTILITY_STAT.pkb
PROMPT Creating package body QC_UTILITY_ORA_04068...
@@QC_UTILITY_ORA_04068.pkb
PROMPT Creating package body QC_UTILITY_MSG...
@@QC_UTILITY_MSG.pkb
PROMPT Creating package body QC_UTILITY_KRN...
@@QC_UTILITY_KRN.pkb
set define on
PROMPT Inserting configuration data...
@@qc_data
set define off
