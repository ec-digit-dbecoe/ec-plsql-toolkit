set verify off
set termout off
set feedback off
whenever sqlerror continue
VARIABLE v_ask_sch_msg VARCHAR2(255)
COLUMN :v_ask_sch_msg NEW_VALUE ASK_SCH_MSG NOPRINT
BEGIN
   IF '&menu_item' IN ('1','2') THEN
      :v_ask_sch_msg := 'Enter the name of the schema to register for application ''&app_alias''';
   ELSIF '&menu_item' IN ('3','4') THEN
      :v_ask_sch_msg := 'Enter the name of the schema to unregister from application ''&app_alias'''
         ||CHR(10)||CHR(13)||'WARNING: all data related to this schema will be deleted/lost!';
   END IF;
END;
/
SELECT :v_ask_sch_msg FROM sys.dual;
set termout on
PROMPT &ask_sch_msg
DEFINE var = ''
ACCEPT var PROMPT 'Schema name or . to terminate: '
set termout off
COLUMN var NEW_VAL schema
SELECT UPPER(TRIM('&var')) var FROM sys.dual;
VARIABLE v_ask_sch_error_msg VARCHAR2(255)
COLUMN :v_ask_sch_error_msg NEW_VALUE ASK_SCH_ERROR_MSG NOPRINT
REM
REM Check that schema is not empty
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_sch_error_msg := NULL;
   SELECT 'x' INTO l_dummy FROM dual WHERE '&schema' IS NULL;
   :v_ask_sch_error_msg := 'ERROR: schema name cannot be empty!';
EXCEPTION
   WHEN no_data_found THEN NULL;
END;
/
REM 
REM Check that at least one schema was registered before leaving
REM
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   IF :v_ask_sch_error_msg IS NULL AND '&schema' = '.' THEN
	   SELECT 'x' INTO l_dummy
	     FROM qc_dictionary_entries
	    WHERE app_alias = '&app_alias'
		  AND dict_name = 'APP SCHEMA';
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      :v_ask_sch_error_msg := 'ERROR: you have to register at least one schema for application ''&app_alias''!';
END;
/
REM 
REM Check the registration of schema (depending on the selected menu item)
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   IF :v_ask_sch_error_msg IS NULL AND '&schema' != '.' THEN
	   SELECT 'x' INTO l_dummy
	     FROM qc_dictionary_entries
	    WHERE app_alias = '&app_alias'
		  AND dict_name = 'APP SCHEMA'
		  AND dict_key = '&schema';
      IF '&menu_item' IN ('1','2') THEN
         :v_ask_sch_error_msg := 'ERROR: schema ''&schema'' is already registered for application ''&app_alias''!';
      END IF;
   END IF;
EXCEPTION
   WHEN no_data_found THEN NULL;
      IF '&menu_item' IN ('3','4') THEN
         :v_ask_app_error_msg := 'ERROR: schema ''&schema'' is not registered!';
      END IF;
END;
/
REM 
REM Check that schema does exists
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   IF :v_ask_sch_error_msg IS NULL AND '&schema' != '.' THEN
	   SELECT 'x' INTO l_dummy
	     FROM all_users
	    WHERE username = '&schema';
   END IF;
EXCEPTION
   WHEN no_data_found THEN 
      :v_ask_sch_error_msg := 'ERROR: schema ''&schema'' does not exist or is not accessible!';
END;
/
SELECT :v_ask_sch_error_msg FROM sys.dual;
VARIABLE v_ask_sch_warning_msg VARCHAR2(255)
COLUMN :v_ask_sch_warning_msg NEW_VALUE setup_warning_msg NOPRINT
COLUMN :v_ask_sch_script NEW_VALUE setup_script NOPRINT
DECLARE
   l_count INTEGER;
BEGIN
   :v_ask_sch_warning_msg := '';
   SELECT COUNT(*) INTO l_count FROM all_objects WHERE owner='&schema';
   IF l_count = 0 THEN
      :v_ask_sch_warning_msg := '>>> WARNING: Schema has no object or its objects are not accessible! <<<';
   END IF;
END;
/
SELECT :v_ask_sch_warning_msg FROM sys.dual;
VARIABLE v_ask_sch_script1 VARCHAR2(255)
VARIABLE v_ask_sch_script2 VARCHAR2(255)
VARIABLE v_ask_sch_script3 VARCHAR2(255)
COLUMN :v_ask_sch_script1 NEW_VALUE ASK_SCH_SCRIPT1 NOPRINT
COLUMN :v_ask_sch_script2 NEW_VALUE ASK_SCH_SCRIPT2 NOPRINT
COLUMN :v_ask_sch_script3 NEW_VALUE ASK_SCH_SCRIPT3 NOPRINT
BEGIN
   :v_ask_sch_script1 := 'noop'; -- Do nothing
   :v_ask_sch_script2 := 'noop'; -- Do nothing
   :v_ask_sch_script3 := 'ask_sch'; -- reentry
   IF :v_ask_sch_error_msg IS NOT NULL THEN
      :v_ask_sch_script1 := 'display_msg "'||:v_ask_sch_error_msg||'"';
   ELSIF '&schema' = '.' THEN
      :v_ask_sch_script3 := 'noop'; -- No reentry
   ELSIF '&schema' IS NOT NULL THEN
      IF '&menu_item' IN ('1','2') /*register app or schema */ THEN
         IF :v_ask_sch_warning_msg IS NOT NULL THEN
            :v_ask_sch_script1 := 'display_msg "'||:v_ask_sch_warning_msg||'"';
         END IF;
         :v_ask_sch_script2 := '&home_dir/releases/&ver_code/install/qc_register_sch'; -- register schema
      ELSIF '&menu_item' IN ('3','4') /*unregister app or schema */ THEN
         :v_ask_sch_script2 := '&home_dir/releases/&ver_code/install/qc_unregister_sch'; -- unregister schema
      END IF;
   END IF;
END;
/
SELECT :v_ask_sch_script1 FROM sys.dual;
SELECT :v_ask_sch_script2 FROM sys.dual;
SELECT :v_ask_sch_script3 FROM sys.dual;
@@&ASK_SCH_SCRIPT1
@@&ASK_SCH_SCRIPT2
@@&ASK_SCH_SCRIPT3
