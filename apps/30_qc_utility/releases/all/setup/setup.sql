set verify off
set termout off
set feedback off
set head off
rem column 1 new_value 1
rem column 2 new_value 2
rem select '' "1", '' "2" from dual where 1=2;
rem define home_dir="&1"
rem define ver_code="&2"
rem undefine 1
rem undefine 2
whenever sqlerror continue
rem whenever oserror continue
DEFINE src_app_alias = ""
VARIABLE v_setup_warning_msg VARCHAR2(255)
VARIABLE v_setup_script VARCHAR2(255)
COLUMN :v_setup_warning_msg NEW_VALUE setup_warning_msg NOPRINT
COLUMN :v_setup_script NEW_VALUE setup_script NOPRINT
DECLARE
   l_count INTEGER;
BEGIN
   :v_setup_warning_msg := '';
   :v_setup_script := 'noop';
   SELECT COUNT(*) INTO l_count FROM user_sys_privs WHERE privilege = 'SELECT ANY DICTIONARY';
   IF l_count = 0 THEN
      :v_setup_warning_msg := '>>> WARNING: Current schema does not have the SELECT ANY DICTIONARY privilege!           <<<'||CHR(10)||CHR(13)
                            ||'>>>          Other schema objects won''t be visible unless access is explicitly granted!  <<<';
      :v_setup_script := 'display_msg';
   END IF;
END;
/
SELECT :v_setup_warning_msg, :v_setup_script FROM sys.dual;
set termout on
PROMPT ======================================================================
PROMPT QC UTILITY Setup Wizard - Main menu
PROMPT ======================================================================
PROMPT In case of error SP2-0309 (SQL*Plus limitation), run the setup again
@@&setup_script "&setup_warning_msg"
PROMPT Select one of the following options:
PROMPT 0 Reset setup to factory settings (to start again from scratch)
PROMPT 1 Register one/several application/s and its/their schemas
PROMPT 2 Register additional schemas for one/several application/s
PROMPT 3 Unregister one/several application/s (and its/their schemas)
PROMPT 4 Unregister one/several schemas of an application
PROMPT 5 Check registered applications and their schemas
PROMPT 6 Check system privileges required to operate
PROMPT 7 Convert a shared config into multiple private configs (one per app)
PROMPT 8 Convert the private config of an app into a shared config
PROMPT 9 Copy a configuration from one application to another
PROMPT . Exit
ACCEPT menu_item PROMPT 'Enter your choice (one character + RETURN): '
PROMPT ======================================================================
set termout off
VARIABLE v_setup_error_msg VARCHAR2(255)
COLUMN :v_setup_error_msg NEW_VALUE setup_ERROR_MSG NOPRINT
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_setup_error_msg := NULL;
   SELECT 'x' INTO l_dummy FROM dual WHERE '&menu_item' IN ('0','1','2','3','4','5','6','7','8','9','.');
EXCEPTION
   WHEN no_data_found THEN
      :v_setup_error_msg := 'ERROR: invalid option, please try again!';
END;
/
DECLARE
   l_count NUMBER;
BEGIN
   IF :v_setup_error_msg IS NULL AND '&menu_item' = '9' THEN
      SELECT COUNT(*) INTO l_count FROM qc_apps WHERE app_alias != 'ALL';
      IF l_count = 0 THEN
         :v_setup_error_msg := 'ERROR: no application is registered (while at least 2 are needed)!';
      ELSIF l_count = 1 THEN
         :v_setup_error_msg := 'ERROR: only one application is registered (while at least 2 are needed)!';
      END IF;
   END IF;
   IF :v_setup_error_msg IS NULL AND '&menu_item' IN ('7','8','9') THEN
      SELECT COUNT(*) INTO l_count FROM qc_dictionary_entries WHERE app_alias = 'ALL' AND SUBSTR(dict_name,-5) != ' WORD';
      IF l_count = 0 AND '&menu_item' = '7' THEN
         :v_setup_error_msg := 'ERROR: configuration is already private!';
      ELSIF l_count > 0 THEN
         IF '&menu_item' = '8' THEN
            :v_setup_error_msg := 'ERROR: configuration is already shared!';
         ELSIF '&menu_item' = '9' THEN
            :v_setup_error_msg := 'ERROR: shared configuration cannot be copied!';
         END IF;
      END IF;
   END IF;
END;
/
SELECT :v_setup_error_msg FROM sys.dual;
VARIABLE v_setup_script1 VARCHAR2(255)
VARIABLE v_setup_script2 VARCHAR2(255)
COLUMN :v_setup_script1 NEW_VALUE setup_SCRIPT1 NOPRINT
COLUMN :v_setup_script2 NEW_VALUE setup_SCRIPT2 NOPRINT
BEGIN
   :v_setup_script1 := 'noop'; -- Do nothing
   :v_setup_script2 := 'setup &home_dir &ver_code'; -- reentry
   IF :v_setup_error_msg IS NOT NULL THEN
      :v_setup_script1 := 'display_msg "'||:v_setup_error_msg||'"';
   ELSIF '&menu_item' = '.' THEN
      :v_setup_script2 := 'noop'; -- No reentry
   ELSE
      IF '&menu_item' = '1' THEN
         :v_setup_script1 := 'ask_app';
      ELSIF '&menu_item' = '2' THEN
         :v_setup_script1 := 'ask_app';
      ELSIF '&menu_item' = '3' THEN
         :v_setup_script1 := 'do_with_confirm ask_app';
      ELSIF '&menu_item' = '4' THEN
         :v_setup_script1 := 'do_with_confirm ask_app';
      ELSIF '&menu_item' = '5' THEN
         :v_setup_script1 := 'chk_app';
      ELSIF '&menu_item' = '6' THEN
         :v_setup_script1 := 'chk_sys_privs';
      ELSIF '&menu_item' = '7' THEN
         :v_setup_script1 := 'do_with_confirm &home_dir/releases/&ver_code/install/qc_unshare_pat';
      ELSIF '&menu_item' = '8' THEN
         :v_setup_script1 := 'do_with_confirm ask_app';
      ELSIF '&menu_item' = '9' THEN
         :v_setup_script1 := 'do_with_confirm ask_app';
      ELSIF '&menu_item' = '0' THEN
         :v_setup_script1 := 'do_with_confirm &home_dir/releases/&ver_code/install/qc_unregister_all';
      END IF;
   END IF;
END;
/
SELECT :v_setup_script1 FROM sys.dual;
SELECT :v_setup_script2 FROM sys.dual;
@@&SETUP_SCRIPT1
@@&SETUP_SCRIPT2
