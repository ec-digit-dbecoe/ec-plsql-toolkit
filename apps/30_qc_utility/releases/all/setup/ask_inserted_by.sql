set verify off
set termout off
set feedback off
REM Set a default value
DEFINE inserted_by = ''
DEFINE var = ''
set termout on
ACCEPT var PROMPT 'Name of the audit column telling who created a record: '
set termout off
COLUMN var NEW_VAL inserted_by
SELECT CASE WHEN '&var' IS NULL THEN UPPER(TRIM('&inserted_by')) ELSE TRIM('&var') END var FROM sys.dual;
PROMPT inserted_by=&inserted_by
VARIABLE v_ask_inserted_by_error_msg VARCHAR2(255)
COLUMN :v_ask_inserted_by_error_msg NEW_VALUE ask_inserted_by_error_msg NOPRINT
REM
REM Check that tablespace exists
REM 
whenever sqlerror exit
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_inserted_by_error_msg := NULL;
   IF '&INSERTED_BY' IS NOT NULL THEN
      SELECT 'x' INTO l_dummy FROM dual WHERE regexp_like('&inserted_by',CHR(94)||'[A-Z][A-Z0-9#_\$]*$');
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      :v_ask_inserted_by_error_msg := 'Error: ''&inserted_by'' does not look like a valid column name!';
END;
/
SELECT :v_ask_inserted_by_error_msg FROM sys.dual;
VARIABLE v_ask_inserted_by_script1 VARCHAR2(255)
VARIABLE v_ask_inserted_by_script2 VARCHAR2(255)
COLUMN :v_ask_inserted_by_script1 NEW_VALUE ASK_INSERTED_BY_SCRIPT1 NOPRINT
COLUMN :v_ask_inserted_by_script2 NEW_VALUE ASK_INSERTED_BY_SCRIPT2 NOPRINT
BEGIN
   :v_ask_inserted_by_script1 := 'noop'; -- Do nothing
   :v_ask_inserted_by_script2 := 'noop'; -- Do nothing
   IF :v_ask_inserted_by_error_msg IS NOT NULL THEN
      :v_ask_inserted_by_script1 := 'display_msg "'||:v_ask_inserted_by_error_msg||'"';
	  :v_ask_inserted_by_script2 := 'ask_inserted_by'; -- reentry
   END IF;
END;
/
SELECT :v_ask_inserted_by_script1 FROM sys.dual;
SELECT :v_ask_inserted_by_script2 FROM sys.dual;
@@&ASK_INSERTED_BY_SCRIPT1
@@&ASK_INSERTED_BY_SCRIPT2
