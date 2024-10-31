set verify off
set termout off
set feedback off
whenever sqlerror continue
DEFINE var = ''
set termout on
ACCEPT var PROMPT 'Will your configuration be shared by all applications (yes/no)? '
set termout off
COLUMN var NEW_VAL yes_no
SELECT UPPER(TRIM('&var')) var FROM sys.dual;
VARIABLE v_ask_pat_error_msg VARCHAR2(255)
COLUMN :v_ask_pat_error_msg NEW_VALUE ASK_PAT_ERROR_MSG NOPRINT
REM
REM Check that yes_no is yes or no
REM 
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_pat_error_msg := NULL;
   SELECT 'x' INTO l_dummy FROM dual WHERE '&yes_no' IN (SUBSTR('YES',1,LENGTH('&yes_no')), SUBSTR('NO',1,LENGTH('&yes_no')))
EXCEPTION
   WHEN no_data_found THEN
      :v_ask_pat_error_msg := 'ERROR: answer must be YES or NO!';
END;
/
SELECT :v_ask_pat_error_msg FROM sys.dual;
VARIABLE v_ask_pat_script1 VARCHAR2(255)
VARIABLE v_ask_pat_script2 VARCHAR2(255)
COLUMN :v_ask_pat_script1 NEW_VALUE ASK_PAT_SCRIPT1 NOPRINT
COLUMN :v_ask_pat_script2 NEW_VALUE ASK_PAT_SCRIPT2 NOPRINT
BEGIN
  :v_ask_pat_script1 := 'noop'; -- Do nothing
  :v_ask_pat_script2 := 'noop'; -- Do nothing
   IF :v_ask_pat_error_msg IS NOT NULL THEN
      :v_ask_pat_script1 := 'display_msg "'||:v_ask_pat_error_msg||'"';
	  :v_ask_pat_script2 := 'ask_pat'; -- reentry
   END IF;
END;
/
COLUMN val NEW_VAL pat_alias
SELECT DECODE('&yes_no',SUBSTR('YES',1,LENGTH('&yes_no')),'ALL','&app_alias') val FROM sys.dual;
SELECT :v_ask_pat_script1 FROM sys.dual;
SELECT :v_ask_pat_script2 FROM sys.dual;
@@&ASK_PAT_SCRIPT1
@@&ASK_PAT_SCRIPT2
