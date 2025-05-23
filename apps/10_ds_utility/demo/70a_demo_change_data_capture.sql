REM 
REM Data Set Utility Demo - Change Data Capture
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM 

REM
REM Scenario 1: CDC without replication (NONE)
REM
PAUSE Configure change data capture?
CLEAR SCREEN
whenever sqlerror exit sqlcode
set serveroutput on size 999999

REM Create and configure data set
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_CAP', p_set_type=>'CAP', p_capture_mode=>'NONE');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO%', p_extract_type=>'B');
   commit;
END;
/

PAUSE Empty schema?
CLEAR SCREEN
REM Empty both schema by executing the 10_demo_data_model.sql script
@@10_demo_data_model

PAUSE Create triggers?
CLEAR SCREEN
REM Create triggers
exec ds_utility_krn.create_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));
SELECT * FROM user_triggers WHERE trigger_name LIKE 'POST%DS%';

PAUSE Generate data and capture changes?
CLEAR SCREEN
exec ds_utility_krn.generate_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_final_commit=>TRUE);

PAUSE Check generated data?
CLEAR SCREEN
select * from demo_persons;

PAUSE Check captured changes?
CLEAR SCREEN
REM Check captured operations
SELECT rec.seq, tab.table_name, rec.operation
     , rec.record_data, rec.record_data_old
  FROM ds_records rec
 INNER JOIN ds_tables tab
    ON tab.table_id = rec.table_id
   AND tab.set_id = ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP')
 ORDER BY rec.seq
/

PAUSE Generate REDO script?
CLEAR SCREEN
REM Generate a REDO script (for a manual execution in the target schema, to replicate captured data changes)
SELECT * FROM TABLE(ds_utility_krn.gen_captured_data_set_script(ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP')))
/

PAUSE Generate UNDO script?
CLEAR SCREEN
REM Generate an UNDO script (for a manual exection in the source schema, to undo captured data changes)
SELECT * FROM TABLE(ds_utility_krn.gen_captured_data_set_script(ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'),'Y'))
/

PAUSE Rollforward captured changes?
CLEAR SCREEN
REM Rollforward all captured operations (e.g., in a target schema accessible via a db link)
DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP');
BEGIN
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id,p_target_db_link=>'DBCC_DIGIT_01_T.CC.CEC.EU.INT');
   ds_utility_krn.rollforward_captured_data_set(p_set_id=>l_set_id, p_delete_flag=>'N');
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id,p_target_db_link=>'');
   COMMIT;
END;
/

PAUSE Check roll forwarding?
CLEAR SCREEN
select * from demo_persons@DBCC_DIGIT_01_T.CC.CEC.EU.INT;

PAUSE Rollback captured changes?
CLEAR SCREEN
REM Rollback all captured operations (e.g., in the source schema)
DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP');
BEGIN
   ds_utility_krn.rollback_captured_data_set(p_set_id=>l_set_id);
   COMMIT;
END;
/

PAUSE Check rollback?
CLEAR SCREEN
select * from demo_persons;

PAUSE Drop triggers?
CLEAR SCREEN
exec ds_utility_krn.drop_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));

REM
REM Scenario 2 - CDC with synchronous replication (SYNC)
REM 

REM Create and configure data set
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_CAP', p_set_type=>'CAP', p_capture_mode=>'SYNC');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO%', p_extract_type=>'B');
   ds_utility_krn.exclude_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_DUAL'); -- has no PK
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id,p_target_db_link=>'DBCC_DIGIT_01_T.CC.CEC.EU.INT');
   commit;
END;
/

PAUSE Empty both schemas?
CLEAR SCREEN
REM Empty both schema by executing the 10_demo_data_model.sql script
@@10_demo_data_model -- while connected to source schema
@@10_demo_data_model -- while connected to target schema

PAUSE Create triggers?
CLEAR SCREEN
REM Create triggers
exec ds_utility_krn.create_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));

PAUSE Generate and replicate data?
CLEAR SCREEN
exec ds_utility_krn.generate_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_final_commit=>TRUE);

PAUSE Check generation and replication?
CLEAR SCREEN
SELECT COUNT(*) FROM demo_persons;
SELECT COUNT(*) FROM demo_persons@DBCC_DIGIT_01_T.CC.CEC.EU.INT;

PAUSE Drop triggers?
CLEAR SCREEN
exec ds_utility_krn.drop_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));

REM
REM Scenario 3 - CDC with asynchronous replication (ASYN)
REM 

REM Create and configure data set
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_CAP', p_set_type=>'CAP', p_capture_mode=>'ASYN');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO%', p_extract_type=>'B');
   ds_utility_krn.exclude_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_DUAL'); -- has no PK
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id,p_target_db_link=>'DBCC_DIGIT_01_T.CC.CEC.EU.INT');
   commit;
END;
/

PAUSE Empty both schemas?
CLEAR SCREEN
REM Empty both schema by executing the 10_demo_data_model.sql script
@@10_demo_data_model -- while connected to source schema
@@10_demo_data_model -- while connected to target schema

PAUSE Create triggers?
CLEAR SCREEN
REM Create triggers
exec ds_utility_krn.create_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));

PAUSE Generate and replicate data?
CLEAR SCREEN
exec ds_utility_krn.generate_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_final_commit=>FALSE);

PAUSE Commit and check dbms_job?
select * from user_jobs where what like '--DS%';
COMMIT;
select * from user_jobs where what like '--DS%';

PAUSE Check generation and replication?
CLEAR SCREEN
REM
SELECT COUNT(*) FROM demo_persons;
SELECT COUNT(*) FROM demo_persons@DBCC_DIGIT_01_T.CC.CEC.EU.INT;

PAUSE Drop triggers?
CLEAR SCREEN
exec ds_utility_krn.drop_triggers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));

REM
REM Clean-up
REM

PAUSE Drop data set?
CLEAR SCREEN
exec ds_utility_krn.delete_data_set_def(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'));
