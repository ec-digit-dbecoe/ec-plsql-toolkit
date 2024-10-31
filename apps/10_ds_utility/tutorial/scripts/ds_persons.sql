DROP TABLE tmp_per_transactions;
DROP TABLE tmp_per_credit_cards;
DROP TABLE tmp_persons;

CREATE TABLE tmp_persons (per_id NUMBER(9) NOT NULL, first_name VARCHAR2(30) NULL, last_name VARCHAR2(30) NOT NULL, gender VARCHAR2(1) NOT NULL, birth_date DATE NOT NULL);

COMMENT ON TABLE tmp_persons IS 'Persons';
COMMENT ON COLUMN tmp_persons.per_id IS 'Person id';
COMMENT ON COLUMN tmp_persons.first_name IS 'Given name';
COMMENT ON COLUMN tmp_persons.last_name IS 'Family name';
COMMENT ON COLUMN tmp_persons.gender IS 'Gender';
COMMENT ON COLUMN tmp_persons.birth_date IS 'Birth date';

CREATE UNIQUE INDEX tmp_per_pk ON tmp_persons (per_id);

ALTER TABLE tmp_persons ADD (
   CONSTRAINT tmp_per_pk PRIMARY KEY (per_id) USING INDEX
);

CREATE TABLE tmp_per_credit_cards (per_id NUMBER(9) NOT NULL, credit_card_number VARCHAR2(40) NOT NULL, expiry_date DATE NOT NULL);

COMMENT ON TABLE tmp_per_credit_cards IS q'#Person's credit cards#';
COMMENT ON COLUMN tmp_per_credit_cards.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_credit_cards.credit_card_number IS 'Credit card number';
COMMENT ON COLUMN tmp_per_credit_cards.expiry_date IS 'Credit card expiry date';

CREATE UNIQUE INDEX tmp_pcc_pk ON tmp_per_credit_cards (per_id, credit_card_number);

ALTER TABLE tmp_per_credit_cards ADD (
   CONSTRAINT tmp_pcc_pk PRIMARY KEY (per_id, credit_card_number) USING INDEX
);

ALTER TABLE tmp_per_credit_cards ADD (
   CONSTRAINT tmp_per_pcc_fk FOREIGN KEY (per_id)
   REFERENCES tmp_persons (per_id)
);

CREATE TABLE tmp_per_transactions (per_id NUMBER(9) NOT NULL, credit_card_nbr VARCHAR2(40) NOT NULL, transaction_timestamp TIMESTAMP NOT NULL, transaction_amount NUMBER NOT NULL);

COMMENT ON TABLE tmp_per_transactions IS q'#Person's credit card transactions#';
COMMENT ON COLUMN tmp_per_transactions.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_transactions.credit_card_nbr IS 'Credit card number';
COMMENT ON COLUMN tmp_per_transactions.transaction_timestamp IS 'Transaction date and time';
COMMENT ON COLUMN tmp_per_transactions.transaction_amount IS 'Transaction amount in euro';

CREATE UNIQUE INDEX tmp_ptr_pk ON tmp_per_transactions (per_id, credit_card_nbr, transaction_timestamp);

ALTER TABLE tmp_per_transactions ADD (
   CONSTRAINT tmp_ptr_pk PRIMARY KEY (per_id, credit_card_nbr, transaction_timestamp) USING INDEX
);

ALTER TABLE tmp_per_transactions ADD (
   CONSTRAINT tmp_ptr_pcc_fk FOREIGN KEY (per_id, credit_card_nbr)
   REFERENCES tmp_per_credit_cards (per_id, credit_card_number)
);

REM Reset
TRUNCATE TABLE tmp_per_transactions;
TRUNCATE TABLE tmp_per_credit_cards;
TRUNCATE TABLE tmp_persons;

REM Reset potentially cached data
ALTER PACKAGE ds_utility_var COMPILE;

REM Generate 10 persons at random
INSERT INTO tmp_persons
SELECT ds_masker_krn.random_integer(p_min_value=>1000,p_max_value=>1999,p_seed=>rownum)
     , ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',p_col_len=>30,p_seed=>rownum)
     , ds_masker_krn.random_value_from_data_set(p_set_col_name=>'EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',p_col_len=>30,p_seed=>rownum)
     , ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GENDER',p_col_len=>1,p_seed=>rownum)
     , ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12),p_seed=>rownum)
  FROM dual CONNECT BY rownum <= 10;
COMMIT;
SELECT * FROM tmp_persons ORDER BY per_id;

REM Generate 2 credit cards per person at random (20 in total)
INSERT INTO tmp_per_credit_cards (per_id, credit_card_number, expiry_date)
SELECT per_id, ds_masker_krn.random_credit_card_number(p_seed=>rownum), ds_masker_krn.random_expiry_date(p_seed=>rownum) FROM (SELECT * FROM tmp_persons ORDER BY per_id);
INSERT INTO tmp_per_credit_cards (per_id, credit_card_number, expiry_date)
SELECT per_id, ds_masker_krn.random_credit_card_number(p_seed=>rownum+10), ds_masker_krn.random_expiry_date(p_seed=>rownum+10) FROM (SELECT * FROM tmp_persons ORDER BY per_id);
COMMIT;
SELECT * FROM tmp_per_credit_cards ORDER BY per_id, credit_card_number;

REM Generate 2 transactions per credit card at random (40 in total)
INSERT INTO tmp_per_transactions (per_id, credit_card_nbr, transaction_timestamp, transaction_amount)
SELECT per_id, credit_card_number, SYSTIMESTAMP, ds_masker_krn.random_integer(p_min_value=>90,p_max_value=>990,p_seed=>rownum)
FROM (SELECT * FROM tmp_per_credit_cards ORDER BY per_id, credit_card_number);
INSERT INTO tmp_per_transactions (per_id, credit_card_nbr, transaction_timestamp, transaction_amount)
SELECT per_id, credit_card_number, SYSTIMESTAMP, ds_masker_krn.random_integer(p_min_value=>90,p_max_value=>990,p_seed=>rownum+20)
FROM (SELECT * FROM tmp_per_credit_cards ORDER BY per_id, credit_card_number);
COMMIT;
SELECT * FROM tmp_per_transactions ORDER BY per_id, credit_card_nbr, transaction_timestamp;

REM Define data set
exec ds_utility_krn.set_message_filter('E');
exec ds_utility_krn.set_test_mode(FALSE);
exec ds_utility_krn.create_or_replace_data_set_def('tmp_persons');
select * from ds_data_sets where set_name='tmp_persons';
exec ds_utility_krn.include_tables(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_table_name=>'TMP_PERSONS', p_recursive_level=>3,p_extract_type=>'B',p_percentage=>50);
exec ds_utility_krn.update_table_properties(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_table_name=>'TMP_PERSONS',p_order_by_clause=>'per_id');
select * from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons');
select * from ds_constraints where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons');
REM
REM Count records (as statistics are not available just after table creation)
exec ds_utility_krn.count_table_records(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
commit;
select * from ds_tables where table_name like 'TMP%';
REM
REM Extract rowid's
exec ds_utility_krn.extract_data_set_rowids(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
select * from ds_records where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
REM
REM Discover sensitive data
-- Enable I)formation messages to get report in dbms_output */
truncate table ds_masks;
exec ds_utility_krn.set_message_filter('EI');
exec ds_utility_krn.discover_sensitive_data(p_rows_sample_size=>200, p_full_schema=>FALSE, p_commit=>TRUE, p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'))
exec ds_utility_krn.set_message_filter('E');
select * from ds_masks where table_name like 'TMP_PER%';
REM
REM Execute one scenario at a time then try the next one!
REM Scenario 0: mask a few fields but not the per_id (pk)
REM Customize some masks
exec ds_utility_krn.update_mask_properties(p_table_name=>'TMP_PERSONS', p_column_name=>'FIRST_NAME', p_msk_type=>'SHUFFLE', p_shuffle_group=>1, p_params=>NULL, p_locked_flag=>'Y');
exec ds_utility_krn.update_mask_properties(p_table_name=>'TMP_PERSONS', p_column_name=>'GENDER', p_msk_type=>'SHUFFLE', p_shuffle_group=>1, p_partition_bitmap=>1, p_params=>NULL, p_locked_flag=>'Y');
exec ds_utility_krn.update_mask_properties(p_table_name=>'TMP_PER_CREDIT_CARDS', p_column_name=>'CREDIT_CARD_NUMBER', p_params=>'ds_masker_krn.encrypt_credit_card_number(credit_card_number)', p_locked_flag=>'Y');
select * from ds_masks;
commit;
REM
REM Scenario 1: generate new per_id's based on a sequence
exec ds_utility_krn.delete_mask(p_table_name=>'TMP_PER%', p_column_Name=>'PER_ID');
exec ds_utility_krn.insert_mask(p_table_name=>'TMP_PERSONS', p_column_name=>'PER_ID');
exec ds_utility_krn.update_mask_properties(p_table_name=>'TMP_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SEQUENCE', p_params=>'START WITH 10 INCREMENT BY 10', p_locked_flag=>'Y');
exec ds_utility_krn.propagate_pk_masking;
commit;
REM
REM Scenario 2: shuffle per_id's
exec ds_utility_krn.delete_mask(p_table_name=>'TMP_PER%', p_column_Name=>'PER_ID');
exec ds_utility_krn.insert_mask(p_table_name=>'TMP_PERSONS',p_column_name=>'PER_ID');
exec ds_utility_krn.update_mask_properties(p_table_name=>'TMP_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SHUFFLE', p_shuffle_group=>2, p_partition_bitmap=>NULL, p_locked_flag=>'Y');
exec ds_utility_krn.propagate_pk_masking;
commit;
select * from ds_masks where table_name like 'TMP_PER%';
--update ds_masks set disabled_flag='Y', locked_flag='Y' where table_name LIKE 'ANO_CREDIT_CARD%' and column_name='CREDIT_CARD_NBR';
REM
REM Scenario 3: encrypt per_id
exec ds_utility_krn.delete_mask(p_table_name=>'TMP_PER%', p_column_Name=>'PER_ID');
exec ds_utility_krn.insert_mask(p_table_name=>'TMP_PERSONS',p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SQL', p_params=>'ds_masker_krn.encrypt_number(per_id)', p_locked_flag=>'Y');
exec ds_utility_krn.propagate_pk_masking;
commit;
select * from ds_masks where table_name like 'TMP_PER%';
REM
REM Shuffle records
exec ds_utility_krn.shuffle_records(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_commit=>TRUE);
commit;
select * from ds_records where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
and (shuffled_rowid_1 is not null or shuffled_rowid_2 is not null);
REM
REM Generate identifiers based on a SEQUENCE
exec ds_utility_krn.generate_identifiers(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_commit=>TRUE);
select * from ds_identifiers where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
REM
REM Set encryption key
exec ds_masker_krn.set_encryption_key('This is the key')
REM
REM Create views to preview data masking
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'), p_view_suffix=>'_W', p_mask_data=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'), p_view_suffix=>'_WO', p_mask_data=>FALSE);
REM
REM Drop views when done
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'), p_view_suffix=>'_W');
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'), p_view_suffix=>'_WO');
REM
REM Sample tables must be pre-created in the target schema!
REM Scenario 1: Generate a script (to be executed manually at a later stage)
truncate table ds_output;
exec ds_utility_krn.handle_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_oper=>'PREPARE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I');
select text from ds_output order by line;
REM
REM Scenario 2: Generate a script and execute it via a RPC through a db link
exec ds_utility_krn.handle_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_oper=>'EXECUTE-SCRIPT',p_output=>'DS_OUTPUT',p_mode=>'I',p_db_link=>'DBCC_DIGIT_01_T.CC.CEC.EU.INT');
select count(*) from tmp_persons@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
select count(*) from tmp_per_credit_cards@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
select count(*) from tmp_per_transactions@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
rollback;
REM
REM Scenario 3: Extract and export data via a db link
update ds_tables set target_db_link = 'DBCC_DIGIT_01_T.CC.CEC.EU.INT' where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons');
exec ds_utility_krn.handle_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'),p_oper=>'DIRECT-EXECUTE',p_output=>'DS_OUTPUT',p_mode=>'I');
update ds_tables set target_db_link = '' where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons');
select count(*) from tmp_persons@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
select count(*) from tmp_per_credit_cards@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
select count(*) from tmp_per_transactions@DBCC_DIGIT_01_T.CC.CEC.EU.INT;
rollback;
REM
REM Scenario 3: Extract data into internal tables as XML
exec ds_utility_krn.export_data_set_to_xml(p_set_id=>ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
select * from ds_records where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('tmp_persons'));
rollback;
