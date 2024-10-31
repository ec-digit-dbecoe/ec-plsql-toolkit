set termout on
set verify off
set termout off
set feedback off
whenever sqlerror continue
VARIABLE v_ask_app_msg VARCHAR2(255)
COLUMN :v_ask_app_msg NEW_VALUE ask_app_msg NOPRINT
BEGIN
   IF '&menu_item' = '1' THEN
      :v_ask_app_msg := 'Enter the alias of the application to register';
   ELSIF '&menu_item' IN ('2','4') THEN
      :v_ask_app_msg := 'Enter the alias of a registered application';
   ELSIF '&menu_item' = '3' THEN
      :v_ask_app_msg := 'Enter the the alias of the application to unregister'
         ||CHR(10)||CHR(13)||'WARNING: all data related to this application will be deleted/lost!';
   ELSIF '&menu_item' = '8' THEN
      :v_ask_app_msg := 'Enter the the alias of the application whose configuration will become the shared one'
         ||CHR(10)||CHR(13)||'WARNING: configuration of all other applications will be deleted/lost!';
   ELSIF '&menu_item' = '9' THEN
      :v_ask_app_msg := 'Enter the the alias of the source application (from which configuration will be copied)';
   ELSIF '&menu_item' = '9b' THEN
      :v_ask_app_msg := 'Enter the the alias of the target application (onto which configuration will be pasted)'
         ||CHR(10)||CHR(13)||'WARNING: existing configuration of this target application will be overwritten!';
   END IF;
END;
/
SELECT :v_ask_app_msg FROM sys.dual;
set termout on
PROMPT &ask_app_msg
DEFINE var = ''
ACCEPT var PROMPT 'Application alias or . to terminate: '
set termout off
COLUMN var NEW_VAL app_alias
SELECT UPPER(TRIM('&var')) var FROM sys.dual;
VARIABLE v_ask_app_error_msg VARCHAR2(255)
COLUMN :v_ask_app_error_msg NEW_VALUE ASK_APP_ERROR_MSG NOPRINT
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_app_error_msg := NULL;
   SELECT 'x' INTO l_dummy FROM dual WHERE '&app_alias' = 'ALL';
   :v_ask_app_error_msg := 'ERROR: application alias ''&app_alias'' is reserved!';
EXCEPTION
   WHEN no_data_found THEN NULL;
END;
/
REM
REM Check that application alias is not empty
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   IF :v_ask_app_error_msg IS NULL THEN
      SELECT 'x' INTO l_dummy FROM dual WHERE '&app_alias' IS NULL;
      :v_ask_app_error_msg := 'ERROR: application alias cannot be empty!';
   END IF;
EXCEPTION
   WHEN no_data_found THEN NULL;
END;
/
REM 
REM Check registration of the application (depending on the selected menu item)
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   IF :v_ask_app_error_msg IS NULL AND '&app_alias' != '.' THEN
	   SELECT 'x' INTO l_dummy FROM qc_apps WHERE app_alias = '&app_alias';
	   IF '&menu_item' = '1' /*Register app*/ THEN
           :v_ask_app_error_msg := 'ERROR: application alias ''&app_alias'' is already registered!';
       END IF;
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      IF '&menu_item' IN ('2','3','4','8','9','9b') THEN
           :v_ask_app_error_msg := 'ERROR: application alias ''&app_alias'' is not registered!';
	  END IF;
END;
/
REM Check that tgt app is different from src app
BEGIN
   IF :v_ask_app_error_msg IS NULL AND '&app_alias' != '.' AND '&menu_item' = '9b' THEN
      IF '&app_alias' = '&src_app_alias' THEN
        :v_ask_app_error_msg := 'ERROR: source and target applications must be different!';
      END IF;
   END IF;
END;
/
SELECT :v_ask_app_error_msg FROM sys.dual;
VARIABLE v_ask_app_script1 VARCHAR2(255)
VARIABLE v_ask_app_script2 VARCHAR2(255)
VARIABLE v_ask_app_script3 VARCHAR2(255)
VARIABLE v_ask_app_script4 VARCHAR2(255)
VARIABLE v_ask_app_script5 VARCHAR2(255)
VARIABLE v_ask_app_pat_alias VARCHAR2(10)
VARIABLE v_src_app_alias VARCHAR2(10)
VARIABLE v_menu_item VARCHAR2(255)
COLUMN :v_ask_app_script1 NEW_VALUE ASK_APP_SCRIPT1 NOPRINT
COLUMN :v_ask_app_script2 NEW_VALUE ASK_APP_SCRIPT2 NOPRINT
COLUMN :v_ask_app_script3 NEW_VALUE ASK_APP_SCRIPT3 NOPRINT
COLUMN :v_ask_app_script4 NEW_VALUE ASK_APP_SCRIPT4 NOPRINT
COLUMN :v_ask_app_script5 NEW_VALUE ASK_APP_SCRIPT5 NOPRINT
COLUMN :v_ask_app_pat_alias NEW_VALUE PAT_ALIAS NOPRINT
COLUMN :v_menu_item NEW_VALUE menu_item NOPRINT
COLUMN :v_src_app_alias NEW_VALUE src_app_alias NOPRINT
DEFINE pat_alias = ''
DECLARE
   CURSOR c_dict IS
      SELECT app_alias
	    FROM qc_dictionary_entries
	   WHERE dict_name = 'PARAMETER'
	   ORDER BY DECODE(app_alias,'ALL',1,2);
   l_app_alias qc_apps.app_alias%TYPE;
BEGIN
   :v_menu_item := '&menu_item';
   :v_src_app_alias := '&src_app_alias';
   :v_ask_app_script1 := 'noop'; -- Do nothing
   :v_ask_app_script2 := 'noop'; -- Do nothing
   :v_ask_app_script3 := 'noop'; -- Do nothing
   :v_ask_app_script4 := 'noop'; -- Do nothing
   :v_ask_app_script5 := 'ask_app'; -- reentry
   IF :v_ask_app_error_msg IS NOT NULL THEN
      :v_ask_app_script1 := 'display_msg "'||:v_ask_app_error_msg||'"';
   ELSIF '&app_alias' = '.' THEN
      :v_ask_app_script5 := 'noop'; -- _No reentry
   ELSE
      IF '&menu_item' = '1' /*register application */ THEN
         OPEN c_dict;
         FETCH c_dict INTO l_app_alias;
         CLOSE c_dict;
         :v_ask_app_script1 := '&home_dir/releases/&ver_code/install/qc_register_app'; -- setup app
         :v_ask_app_script2 := 'ask_sch';
         IF l_app_alias IS NULL THEN
            :v_ask_app_script3 := 'ask_pat';
            :v_ask_app_script4 := 'set_pat';
         ELSIF l_app_alias = 'ALL' THEN
            :v_ask_app_pat_alias := 'ALL';
         ELSE
            :v_ask_app_pat_alias := '&app_alias';
            :v_ask_app_script4 := 'set_pat';
         END IF;
      ELSIF '&menu_item' IN ('2','4') /* register/unregister schema */ THEN
         :v_ask_app_script1 := 'ask_sch';
      ELSIF '&menu_item' = '3' /* Unregister application */ THEN
         :v_ask_app_script1 := '&home_dir//releases/&ver_code/install/qc_unregister_app';
      ELSIF '&menu_item' = '8' /* Share application configuration */ THEN
         :v_ask_app_script1 := '&home_dir/releases/&ver_code/install/qc_share_pat';
         :v_ask_app_script5 := 'noop'; -- _No reentry
      ELSIF '&menu_item' = '9' /* Copy configuration (step 1) */ THEN
         :v_menu_item := '9b';
         :v_src_app_alias := '&app_alias'; /*+ re-entry*/
      ELSIF '&menu_item' = '9b' /* Copy configuration (step 2) */ THEN
         :v_ask_app_script1 := '&home_dir/releases/&ver_code/install/qc_copy_pat';
         :v_ask_app_script5 := 'noop'; -- _No reentry
      END IF;
   END IF;
END;
/
SELECT :v_ask_app_script1 FROM sys.dual;
SELECT :v_ask_app_script2 FROM sys.dual;
SELECT :v_ask_app_script3 FROM sys.dual;
SELECT :v_ask_app_script4 FROM sys.dual;
SELECT :v_ask_app_script5 FROM sys.dual;
SELECT :v_ask_app_pat_alias FROM sys.dual;
SELECT :v_menu_item FROM sys.dual;
SELECT :v_src_app_alias FROM sys.dual;
@@&ASK_APP_SCRIPT1
@@&ASK_APP_SCRIPT2
@@&ASK_APP_SCRIPT3
@@&ASK_APP_SCRIPT4
@@&ASK_APP_SCRIPT5
