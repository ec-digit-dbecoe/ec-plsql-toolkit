set verify off
set termout off
set feedback off
REM Set a default value
COLUMN val NEW_VAL tab_ts
select tablespace_name val from (select tablespace_name from dba_segments where owner='&SCHEMA' AND segment_type='TABLE' group by tablespace_name order by COUNT(*) DESC) where rownum<=1;
DEFINE var = ''
set termout on
ACCEPT var PROMPT 'Tablespace for tables [&tab_ts]: '
set termout off
COLUMN var NEW_VAL tab_ts
SELECT CASE WHEN '&var' IS NULL THEN UPPER(TRIM('&tab_ts')) ELSE TRIM('&var') END var FROM sys.dual;
PROMPT tab_ts=&tab_ts
VARIABLE v_ask_tab_ts_error_msg VARCHAR2(255)
COLUMN :v_ask_tab_ts_error_msg NEW_VALUE ask_tab_ts_error_msg NOPRINT
REM
REM Check that tablespace exists
REM 
whenever sqlerror exit
DECLARE
   l_dummy VARCHAR2(1);
BEGIN
   :v_ask_tab_ts_error_msg := NULL;
   IF '&TAB_TS' IS NOT NULL THEN
      SELECT 'x' INTO l_dummy FROM dba_tablespaces WHERE tablespace_name=UPPER('&TAB_TS');
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      :v_ask_tab_ts_error_msg := 'Error: tablespace ''&tab_ts'' does not exists or is not accessible!';
END;
/
SELECT :v_ask_tab_ts_error_msg FROM sys.dual;
VARIABLE v_ask_tab_ts_script1 VARCHAR2(255)
VARIABLE v_ask_tab_ts_script2 VARCHAR2(255)
COLUMN :v_ask_tab_ts_script1 NEW_VALUE ASK_TAB_TS_SCRIPT1 NOPRINT
COLUMN :v_ask_tab_ts_script2 NEW_VALUE ASK_TAB_TS_SCRIPT2 NOPRINT
BEGIN
   :v_ask_tab_ts_script1 := 'noop'; -- Do nothing
   :v_ask_tab_ts_script2 := 'noop'; -- Do nothing
   IF :v_ask_tab_ts_error_msg IS NOT NULL THEN
      :v_ask_tab_ts_script1 := 'display_msg "'||:v_ask_tab_ts_error_msg||'"';
	  :v_ask_tab_ts_script2 := 'ask_tab_ts'; -- reentry
   END IF;
END;
/
SELECT :v_ask_tab_ts_script1 FROM sys.dual;
SELECT :v_ask_tab_ts_script2 FROM sys.dual;
@@&ASK_TAB_TS_SCRIPT1
@@&ASK_TAB_TS_SCRIPT2
