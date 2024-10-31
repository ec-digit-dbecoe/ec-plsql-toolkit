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
PROMPT Upgrading package spec DS_CRYPTO_VAR..
@@DS_CRYPTO_VAR.pks
show error
PROMPT Upgrading package spec DS_CRYPTO_KRN..
@@DS_CRYPTO_KRN.pks
show error
PROMPT Upgrading package spec DS_UTILITY_VAR..
@@DS_UTILITY_VAR.pks
show error
PROMPT Upgrading package spec DS_UTILITY_KRN...
@@DS_UTILITY_KRN.pks
show error
PROMPT Upgrading package spec DS_UTILITY_EXT...
@@DS_UTILITY_EXT.pks
show error
PROMPT Upgrading package/type bodies...
PROMPT Upgrading package body DS_CRYPTO_KRN...
@@DS_CRYPTO_KRN.pkb
show error
PROMPT Upgrading package body DS_UTILITY_KRN...
@@DS_UTILITY_KRN.pkb
show error
PROMPT Upgrading package body DS_UTILITY_EXT...
@@DS_UTILITY_EXT.pkb
show error
rem PROMPT Upgrading data...
rem @@ds_patterns.sql
