set verify off
set termout off
set feedback off
whenever sqlerror continue
DEFINE var = ''
set termout on
ACCEPT var PROMPT 'WARNING: This is an irreversible operation: are you sure (yes/no)? '
set termout off
COLUMN var NEW_VAL yes_no
SELECT UPPER(TRIM('&var')) var FROM sys.dual;
VARIABLE v_do_with_confirm_error_msg VARCHAR2(255)
COLUMN :v_do_with_confirm_error_msg NEW_VALUE do_with_confirm_error_msg NOPRINT
REM
REM Check that yes_no is yes or no
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_do_with_confirm_error_msg := NULL;
   SELECT 'x' INTO l_dummy FROM dual WHERE '&yes_no' IN ('.', SUBSTR('YES',1,LENGTH('&yes_no')), SUBSTR('NO',1,LENGTH('&yes_no')));
EXCEPTION
   WHEN no_data_found THEN
      :v_do_with_confirm_error_msg := 'ERROR: please answer YES or NO!';
END;
/
SELECT :v_do_with_confirm_error_msg FROM sys.dual;
VARIABLE v_do_with_confirm_script1 VARCHAR2(255)
VARIABLE v_do_with_confirm_script2 VARCHAR2(255)
COLUMN :v_do_with_confirm_script1 NEW_VALUE do_with_confirm_script1 NOPRINT
COLUMN :v_do_with_confirm_script2 NEW_VALUE do_with_confirm_script2 NOPRINT
BEGIN
  :v_do_with_confirm_script1 := 'noop'; -- Do nothing
  :v_do_with_confirm_script2 := 'noop'; -- Do nothing
   IF :v_do_with_confirm_error_msg IS NOT NULL THEN
      :v_do_with_confirm_script1 := 'display_msg "'||:v_do_with_confirm_error_msg||'"';
      :v_do_with_confirm_script2 := 'do_with_confirm'; -- reentry
   ELSIF '&yes_no' = SUBSTR('YES',1,LENGTH('&yes_no')) THEN
      :v_do_with_confirm_script1 := '&1'; -- execute command passed in parameter
   END IF;
END;
/
SELECT :v_do_with_confirm_script1 FROM sys.dual;
SELECT :v_do_with_confirm_script2 FROM sys.dual;
@@&do_with_confirm_script1
@@&do_with_confirm_script2
