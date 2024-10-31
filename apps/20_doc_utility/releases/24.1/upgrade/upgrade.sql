set define off
set define on
rem PROMPT Upgrading database objects...
rem @@doc_objects.sql
set define off
PROMPT Re-Creating package specifications...
@@DOC_UTILITY_VAR.pks
@@DOC_UTILITY.pks
@@DOC_UTILITY_EXT_TPL.pks
@@DOC_UTILITY_LIC.pks
PROMPT Re-Creating package bodies...
@@DOC_UTILITY_VAR.pkb
@@DOC_UTILITY.pkb
@@DOC_UTILITY_EXT_TPL.pkb
PROMPT Regenerating extension package...
@@doc_generate.sql
@@doc_recompile.sql