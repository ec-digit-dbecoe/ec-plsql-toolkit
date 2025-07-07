REM 
REM Data Set Utility Demo - Data masking
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script with configuration based on EDGPL
REM 

REM Used APIs
REM . execute_degpl()
REM . mask_data_set
REM . create_views()
REM . drop_views()
REM . graph_data_set()

PAUSE Configure masks?
CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode

REM
REM Scenario 1: mask a few fields but not the per_id (pk)
REM Update those resulting from the sensitive data discovery
REM
REM Customize some masks
CLEAR SCREEN
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>REPLACE(q'£
/*set demo_data_sub;*//*Data set not needed to define masks => commented out*/
!mask[locked=Y]; /*lock all masks updated below */
per.gender[msk_type=SHUFFLE, shuffle_group=1, partition_bitmap=1]
   .first_name[msk_type=SHUFFLE, shuffle_group=1]
   .last_name[msk_type=TOKENIZE, msk_params="ds_utility_krn.random_value_from_table(p_tab_name=>'DEMO_PERSONS',p_col_name=>'LAST_NAME',p_cycle=>'Y')"]
             [options="enforce_uniqueness=true, encrypt_tokenized_values=true"];
mask[msk_type=SQL]; /*default masking type*/
per.full_name[msk_params="::first_name||' '||::last_name"]
   .nationality[msk_params="ds_utility_krn.random_value_from_table(p_tab_name=>'DEMO_COUNTRIES',p_col_name=>'CNT_CD',p_seed=>rowid)"]
   .title[msk_params="'XXXX'", options="mask_null_values=true"];
pcc.credit_card_number[msk_params="ds_masker_krn.encrypt_credit_card_number(credit_card_number)"];
£','::',':'));
end;
/
PAUSE Masking model updated, please check!
CLEAR SCREEN
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_table_name=>'DEMO_', p_full_schema=>'Y', p_show_legend=>'N', p_show_aliases=>'Y', p_show_conf_columns=>'Y', p_show_stats=>'Y', p_show_config=>'Y'));

REM Proceed
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
PAUSE View created; please check data!
CLEAR SCREEN
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
exec ds_masker_krn.set_encryption_key('This is the private key');
select msk_id, token, value encrypted_value from ds_tokens order by token;
select msk_id, token, value encrypted_value, ds_masker_krn.decrypt_string(value) original_value  from ds_tokens order by token;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select ds_masker_krn.is_valid_credit_card_number('375495823795512') from dual; -- Y
select ds_masker_krn.decrypt_credit_card_number('375495823795512') from dual; --366040264962527
select 'ORIGIN', ori.* from demo_per_transactions_ori ori union select 'MASKED', msk.* from demo_per_transactions_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 2: generate new per_id's based on an in-memory sequence (reset other masks)
PAUSE Start of scenario 2
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SEQUENCE, msk_params="START WITH 10 INCREMENT BY 10", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 2
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select * from ds_identifiers where msk_id in (select msk_id from ds_masks where table_name='DEMO_PERSONS' and column_name='PER_ID');
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 2b: generate new per_id's based on a local Oracle sequence (reset other masks)
PAUSE Start of scenario 2b
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SEQUENCE, msk_params="demo_per_seq", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 2b
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select * from ds_identifiers where msk_id in (select msk_id from ds_masks where table_name='DEMO_PERSONS' and column_name='PER_ID');
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 2c: generate new per_id's based on a remote Oracle sequence (reset other masks)
PAUSE Start of scenario 2c
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SEQUENCE, msk_params="demo_per_seq@DBCC_DIGIT_01_T.CC.CEC.EU.INT", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 2c
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select * from ds_identifiers where msk_id in (select msk_id from ds_masks where table_name='DEMO_PERSONS' and column_name='PER_ID');
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 3: shuffle per_id's (reset other masks)
PAUSE Start of scenario 3
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SHUFFLE, shuffle_group=1, partition="", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_seed=>'This is a seed',p_commit=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 3
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 4: encrypt per_ids (reset other masks)
PAUSE Start of scenario 4
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SQL, msk_params="ds_masker_krn.encrypt_number(per_id)", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_seed=>'This is a seed',p_commit=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 4
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 5b: tokenize per_id with token = random number (reset other masks) 
PAUSE Start of scenario 5
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=TOKENIZE, msk_params="ds_masker_krn.random_number(p_precision=>2,p_seed=>NULL)"
         , options="enforce_uniqueness=true, allow_equal_value=false, encrypt_tokenized_values=true", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 5
select msk_id, token, ds_masker_krn.decrypt_string(value) original_value, value crypted_value  from ds_tokens order by token;
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 5b: tokenize per_id with token = encrypted per_id (reset other masks)
PAUSE Start of scenario 5
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=TOKENIZE, msk_params="ds_masker_krn.encrypt_number(per_id)"
         , options="enforce_uniqueness=true, allow_equal_value=true, encrypt_tokenized_values=true", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 5
select msk_id, token, ds_masker_krn.decrypt_string(value) original_value, value crypted_value  from ds_tokens order by token;
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 6: differed masking/relocation of per_id using a non-accessible remote Oracle sequence (ds_identifiers not used)
REM Preview of per_id masking not available! + Works only with scripts to be transported manually (so no via db link)!
REM
PAUSE Start of scenario 6
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SEQUENCE, msk_params="DEMO_PER_SEQ", options="differ_masking=true", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_seed=>'This is a seed',p_commit=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 6
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Scenario 7: masking/relocation of per_id by shifting them by a constant value (ds_identifiers not used)
REM
PAUSE Start of scenario 7
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
begin
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_table_name=>'DEMO%',p_code=>q'£
per.per_id[msk_type=SQL, msk_params="per_id+100", sensitive=Y, locked=Y]
£');
end;
/
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
PAUSE End of scenario 7
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;

REM
REM Clean-up
PAUSE Start of clean-up
CLEAR SCREEN
delete ds_identifiers;
commit;
delete ds_tokens;
commit;
delete ds_masks;
commit;
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK');
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI');
PAUSE End of clean-up
