REM 
REM Data Set Utility Demo - Data Set Transportation
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM 

REM Used APIs
REM . transport_data_set()
REM . export_data_set_to_xml()

REM
REM Scenario 0: Transport data via DMLs executed in the target schema of the same db
REM Target schema must grant SIUD on its tables and S on its sequences to source schema
REM (uncomment commented lines for debugging)
REM
PAUSE Start of scenario 0
CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode
define target="APP_DPP2_D"
@@18b_demo_tgt_tables_stats.sql
exec ds_utility_krn.update_table_properties(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_target_schema=>'&&target');
--exec ds_utility_krn.set_message_filter('E');
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'DIRECT-EXECUTE',p_mode=>'I',p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
@@18b_demo_tgt_tables_stats.sql
PAUSE End of scenario 1
select * from &&target..demo_persons order by per_id;
select * from &&target..demo_per_credit_cards order by per_id, credit_card_number;
select * from &&target..demo_per_transactions order by per_id, ord_id, credit_card_nbr;
select * from &&target..demo_org_entities order by oen_cd;

REM
REM Scenario 1: Transport data via DMLs executed through a database link
REM (uncomment commented lines for debugging)
REM
PAUSE Start of scenario 1
CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode
@@18_demo_tgt_tables_stats.sql
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'DIRECT-EXECUTE',p_mode=>'I',p_db_link=>'DBCC_DIGIT_01_A.CC.CEC.EU.INT',p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
@@18_demo_tgt_tables_stats.sql
PAUSE End of scenario 1
select * from demo_persons@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by per_id;
select * from demo_per_credit_cards@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by per_id, credit_card_number;
select * from demo_per_transactions@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by per_id, ord_id, credit_card_nbr;
select * from demo_org_entities@DBCC_DIGIT_01_A.CC.CEC.EU.INT order by oen_cd;

REM Scenario 2: Transport data as script (to be executed manually in the target schema)
PAUSE Start of scenario 2
CLEAR SCREEN
delete ds_output;
commit;
--exec ds_utility_krn.set_message_filter('EWI');
--exec ds_utility_krn.set_test_mode(FALSE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'PREPARE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I');
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
PAUSE End of scenario 2
select text from ds_output order by line;

REM
REM Scenario 3: Transport data via a script executed through a db link
PAUSE Start of scenario 3
CLEAR SCREEN
@@18_demo_tgt_tables_stats.sql
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.transport_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_method=>'EXECUTE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I',p_db_link=>'DBCC_DIGIT_01_A.CC.CEC.EU.INT',p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');
@@18_demo_tgt_tables_stats.sql
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