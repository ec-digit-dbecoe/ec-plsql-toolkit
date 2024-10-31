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
@@DS_CRYPTO_VAR.pks
show error
@@DS_CRYPTO_KRN.pks
show error
@@DS_UTILITY_VAR.pks
show error
@@DS_MASKER_KRN.pks
show error
@@DS_UTILITY_KRN.pks
show error
@@DS_UTILITY_LIC.pks
show error
PROMPT Upgrading package/type bodies...
@@DS_READ_CSV_CLOB.tpb
show error
@@DS_CRYPTO_KRN.pkb
show error
@@DS_MASKER_KRN.pkb
show error
@@DS_UTILITY_KRN.pkb
show error
PROMPT Upgrading data
@@ds_EU6_FAMILY_NAMES_217.sql
@@ds_EU_MAJOR_CITIES_590.sql
@@ds_INT_COUNTRIES_250.sql
@@ds_INT_CURRENCIES_170.sql
@@ds_INT_GIVEN_NAMES_250.sql
@@ds_patterns.sql
DROP PACKAGE ds_utility;
