REM 
REM Data Set Utility Demo - Data Set Transportation
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

REM
REM Scenario 1: Transport data via DMLs executed through a database link
REM (uncomment commented lines for debugging)
REM
PAUSE Start of scenario 1
CLEAR SCREEN
set serveroutput on size 999999

--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'DIRECT-EXECUTE',p_mode=>'I',p_db_link=>'DBCC_DIGIT_01_A.CC.CEC.EU.INT',p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
PAUSE End of scenario 1
select * from demo_persons@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by per_id;
select * from demo_org_entities@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by oen_cd;

REM Scenario 2: Transport data as script (to be executed manually in the target schema)
PAUSE Start of scenario 2
CLEAR SCREEN
delete ds_output;
commit;
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'PREPARE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I');
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
PAUSE End of scenario 2
select text from ds_output order by line;

REM
REM Scenario 3: Transport data via a script executed through a db link
PAUSE Start of scenario 3
CLEAR SCREEN
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'EXECUTE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I',p_db_link=>'DBCC_DIGIT_01_A.CC.CEC.EU.INT',p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
PAUSE End of scenario 3
select * from demo_persons@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by per_id;

REM
REM Scenario 4: Transport data as XML stored into internal tables
REM (internal tables must be transported e.g., via data pump)
REM
PAUSE Start of scenario 4
CLEAR SCREEN
--exec ds_utility_krn.set_message_filter('EWIS');
exec ds_utility_krn.export_data_set_to_xml(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'));
--exec ds_utility_krn.set_message_filter('EWI');
commit;
PAUSE End of scenario 4
select * from ds_records where record_data IS NOT NULL;