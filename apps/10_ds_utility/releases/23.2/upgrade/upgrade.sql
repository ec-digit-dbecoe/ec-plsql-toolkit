-- 
-- Description:
--   Apply upgrade scripts of a release
--
-- Note:
--   Do not invoke this script directly.  
--
set define off
set define on
PROMPT Upgrading database objects...
@@ds_objects.sql
PROMPT Upgrading package/type specifications...
@@DS_READ_CSV_CLOB.tps
show error
@@DS_UTILITY_VAR.pks
show error
@@DS_MASKER_KRN.pks
show error
@@DS_UTILITY_KRN.pks
show error
PROMPT Upgrading package/type bodies...
@@DS_READ_CSV_CLOB.tpb
show error
@@DS_MASKER_KRN.pkb
show error
@@DS_UTILITY_KRN.pkb
show error
rem PROMPT Upgrading data...
@@ds_patterns.sql
@@ds_FOOD.sql
@@ds_COLORS.sql
@@ds_OBJECTS_200.sql
@@ds_EU_COUNTRIES_27.sql
