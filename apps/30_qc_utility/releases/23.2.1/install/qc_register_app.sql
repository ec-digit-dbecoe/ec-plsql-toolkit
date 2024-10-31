set termout on
set define on
set scan on
set feedback off
set verify off
PROMPT Registering application '&&app_alias'...
INSERT INTO qc_apps(app_alias) VALUES ('&&app_alias');
COMMIT;
PROMPT Application '&&app_alias' registered!
