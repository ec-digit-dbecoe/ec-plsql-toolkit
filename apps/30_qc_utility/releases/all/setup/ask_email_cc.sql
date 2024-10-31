set verify off
set termout off
set feedback off
REM Set a default value
DEFINE email_cc = ''
DEFINE var = ''
set termout on
ACCEPT var PROMPT 'CC email address: '
set termout off
COLUMN var NEW_VAL email_cc
SELECT CASE WHEN '&var' IS NULL THEN UPPER(TRIM('&email_cc')) ELSE TRIM('&var') END var FROM sys.dual;
PROMPT email_cc=&email_cc
VARIABLE v_ask_email_cc_error_msg VARCHAR2(255)
COLUMN :v_ask_email_cc_error_msg NEW_VALUE ask_email_cc_error_msg NOPRINT
REM
REM Check that tablespace exists
REM 
whenever sqlerror exit
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_email_cc_error_msg := NULL;
   IF '&EMAIL_CC' IS NOT NULL THEN
      SELECT 'x' INTO l_dummy FROM dual WHERE regexp_like('&email_cc','.+@.+\..+');
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      :v_ask_email_cc_error_msg := 'Error: ''&email_cc'' does not look like a valid email address!';
END;
/
SELECT :v_ask_email_cc_error_msg FROM sys.dual;
VARIABLE v_ask_email_cc_script1 VARCHAR2(255)
VARIABLE v_ask_email_cc_script2 VARCHAR2(255)
COLUMN :v_ask_email_cc_script1 NEW_VALUE ASK_EMAIL_CC_SCRIPT1 NOPRINT
COLUMN :v_ask_email_cc_script2 NEW_VALUE ASK_EMAIL_CC_SCRIPT2 NOPRINT
BEGIN
   :v_ask_email_cc_script1 := 'noop'; -- Do nothing
   :v_ask_email_cc_script2 := 'noop'; -- Do nothing
   IF :v_ask_email_cc_error_msg IS NOT NULL THEN
      :v_ask_email_cc_script1 := 'display_msg "'||:v_ask_email_cc_error_msg||'"';
	  :v_ask_email_cc_script2 := 'ask_email_cc'; -- reentry
   END IF;
END;
/
SELECT :v_ask_email_cc_script1 FROM sys.dual;
SELECT :v_ask_email_cc_script2 FROM sys.dual;
@@&ASK_EMAIL_CC_SCRIPT1
@@&ASK_EMAIL_CC_SCRIPT2
