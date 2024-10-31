set define off
set define on
PROMPT Upgrading package spec DS_CRYPTO_VAR..
@@DS_CRYPTO_VAR.pks
show error
PROMPT Upgrading package spec DS_CRYPTO_KRN..
@@DS_CRYPTO_KRN.pks
show error
PROMPT Upgrading package body DS_CRYPTO_KRN...
@@DS_CRYPTO_KRN.pkb
show errords_COLORS.sql
PROMPT Re-installing data sets...
@@ds_EU6_FAMILY_NAMES_217.sql
@@ds_EU_COUNTRIES_27.sql
@@ds_EU_MAJOR_CITIES_590.sql
@@ds_FOOD.sql
@@ds_INT_COUNTRIES_250.sql
@@ds_INT_CURRENCIES_170.sql
@@ds_INT_GIVEN_NAMES_250.sql
@@ds_OBJECTS_200.sql