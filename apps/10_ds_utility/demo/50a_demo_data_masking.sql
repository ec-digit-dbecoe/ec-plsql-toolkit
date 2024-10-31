REM 
REM Data Set Utility Demo - Data masking
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

-- Set set_id
PAUSE Configure masks?
CLEAR SCREEN
REM
REM Scenario 1: mask a few fields but not the per_id (pk)
REM Update those resulting from the sensitive data discovery
REM
REM Customize some masks
declare
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB');
begin
   ds_utility_krn.set_message_filter('EWI');
   ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_raise_error_when_no_insert=>FALSE);
   ds_utility_krn.insert_mask(p_table_name=>'DEMO_PER_CREDIT_CARDS', p_raise_error_when_no_insert=>FALSE);
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'GENDER', p_msk_type=>'SHUFFLE', p_shuffle_group=>1, p_partition_bitmap=>1, p_params=>NULL, p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'FIRST_NAME', p_msk_type=>'SHUFFLE', p_shuffle_group=>1, p_params=>NULL, p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'LAST_NAME', p_msk_type=>'TOKENIZE', p_params=>q'#ds_utility_krn.random_value_from_table(p_tab_name=>'DEMO_PERSONS',p_col_name=>'LAST_NAME',p_cycle=>'Y')#', p_options=>'enforce_uniqueness=true, encrypt_tokenized_values=true', p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'FULL_NAME', p_msk_type=>'SQL', p_params=>q'#:first_name||' '||:last_name#', p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'NATIONALITY', p_msk_type=>'SQL', p_params=>q'#ds_utility_krn.random_value_from_table(p_tab_name=>'DEMO_COUNTRIES',p_col_name=>'CNT_CD',p_seed=>rowid)#', p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'TITLE', p_msk_type=>'SQL', p_params=>q'#'XXXX'#', p_options=>'mask_null_values=true', p_locked_flag=>'Y');
   ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PER_CREDIT_CARDS', p_column_name=>'CREDIT_CARD_NUMBER', p_msk_type=>'SQL', p_params=>'ds_masker_krn.encrypt_credit_card_number(credit_card_number)', p_locked_flag=>'Y');
   ds_utility_krn.delete_mask(p_table_name=>'DEMO_COUNTRIES', p_column_name=>'CNT_CD');
   commit;
end;
/

PAUSE Mask updated, please check them!
CLEAR SCREEN
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_table_name=>'DEMO_', p_full_schema=>'Y', p_show_legend=>'Y', p_show_aliases=>'Y', p_show_conf_columns=>'Y', p_show_stats=>'Y', p_show_config=>'Y'));

CLEAR SCREEN
PAUSE Mask data set?
truncate table ds_identifiers;
truncate table ds_tokens;
exec ds_utility_krn.mask_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'),p_key=>'This is the private key',p_commit=>TRUE,p_seed=>'This is a seed');
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK', p_mask_data=>TRUE, p_include_rowid=>TRUE);
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI', p_mask_data=>FALSE, p_include_rowid=>TRUE);

CLEAR SCREEN
PAUSE View created; please check data!
select * from ds_masks where table_name in (select table_name from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')) and msk_type IS NOT NULL;
select msk_id, token, ds_masker_krn.decrypt_string(value) original_value, value crypted_value  from ds_tokens order by token;
select 'ORIGIN', ori.* from demo_persons_ori ori union select 'MASKED', msk.* from demo_persons_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_per_credit_cards_ori ori union select 'MASKED', msk.* from demo_per_credit_cards_msk msk ORDER BY 2, 1 DESC;
select 'ORIGIN', ori.* from demo_orders_ori ori union select 'MASKED', msk.* from demo_orders_msk msk ORDER BY 2, 1 DESC;
exec ds_masker_krn.set_encryption_key('This is the private key');
select ds_masker_krn.decrypt_credit_card_number('4839620696432370') from dual; --4804509169350857

REM
REM Scenario 2: generate new per_id's based on an in-memory sequence (reset other masks)
PAUSE Start of scenario 2
CLEAR SCREEN
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SEQUENCE', p_params=>'START WITH 10 INCREMENT BY 10', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SEQUENCE', p_params=>'demo_per_seq', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SEQUENCE', p_params=>'demo_per_seq@DBCC_DIGIT_01_T.CC.CEC.EU.INT', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SHUFFLE', p_shuffle_group=>1, p_partition_bitmap=>NULL, p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS',p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SQL', p_params=>'ds_masker_krn.encrypt_number(per_id)', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS',p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'TOKENIZE', p_params=>'ds_masker_krn.random_number(p_precision=>2,p_seed=>NULL)', p_options=>'enforce_uniqueness=true, allow_equal_value=false, encrypt_tokenized_values=true', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS',p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'TOKENIZE', p_params=>'ds_masker_krn.encrypt_number(per_id)', p_options=>'enforce_uniqueness=true, allow_equal_value=true, encrypt_tokenized_values=true', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SEQUENCE', p_params=>'DEMO_PER_SEQ', p_locked_flag=>'Y', p_options=>'differ_masking=true');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID');
exec ds_utility_krn.update_mask_properties(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_sensitive_flag=>'Y', p_msk_type=>'SQL', p_params=>'per_id+100', p_locked_flag=>'Y');
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
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK');
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI');
PAUSE End of clean-up
