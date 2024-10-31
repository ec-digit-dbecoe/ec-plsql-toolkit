REM 
REM Data Set Utility Demo - Synthetic Data Generation
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM Script for:
REM - Configuration based on DEGPL language
REM - Tool installed in a dedicated/central schema
REM - Data model in another schema of the same db
REM 

REM Create a data set to generate synthetic/fake data 
PAUSE Configure data set?
CLEAR SCREEN
exec ds_utility_krn.set_message_filter('EWI');
exec ds_utility_krn.set_test_mode(FALSE);

BEGIN
ds_utility_krn.set_source_schema('APP_DBCC_D');
ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_GEN', p_set_type=>'GEN');
ds_utility_ext.include_path(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_path=>q'£
table[target_schema=APP_DBCC_D];
demo*>-demo*/*include all demo tables and their fks, isolated tables excluded*/;
sto/b[row_count=10];oen/b[row_count=1];prd/b[row_count=50];per/b[row_count=50];
oet/r;cct/r;cnt/r;
oit[tab_seq=1];ptr[tab_seq=2];
per=>[min_rows=0,max_rows=5]ord;
per>-[where_clause="manager_flag='Y'",src_filter="manager_flag IS NULL"]per;
per≠<per;
per=>[gen_view_name="demo_random_date_history"]pas;
per=>[gen_view_name="demo_random_time_clockings"]pcl;
per=>[min_rows=2,max_rows=4]pcc;
ptr->[where_clause="per_id=PARENT per_id"]pcc+>ptr;
ord=>[min_rows=1,max_rows=5]oit;
ord~>[post_gen_code="UPDATE app_dbcc_d.demo_orders ord SET total_price = (SELECT NVL(SUM(oit.price),0) FROM app_dbcc_d.demo_order_items oit WHERE oit.ord_id = ord.ord_id)"]oit;
ord=>[min_rows=0,max_rows=2]ptr;
pas->[where_clause="oet_cd != 'INST'"]oen+>pas;
oen=<[min_rows=4,max_rows=6,level_count=5]oen>≠oen;
oen>-[where_clause="oet_level=LEVEL"]oet;
∃*∄>-0*/*Add recursively missing N-1 constraints for included tables (to ensure referential integrity)*/;
column[gen_type=SEQ];
per.per_id[params="APP_DBCC_D.DEMO_PER_SEQ"];
oen.oen_id[params="APP_DBCC_D.DEMO_OEN_SEQ"];
ord.ord_id[params="APP_DBCC_D.DEMO_ORD_SEQ"];
sto.sto_id[params="APP_DBCC_D.DEMO_STO_SEQ"];
prd.prd_id[params="APP_DBCC_D.DEMO_PRD_SEQ"];
column[gen_type=SQL];
oen.oen_name[params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'FOOD.NAME',p_col_len=>20)"];
oen.oen_cd[params="CASE LEVEL WHEN 1 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 2 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 3 THEN PRIOR oen_cd||'.'||CHR(ASCII('A')+ROWNUM-1)
             WHEN 4 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM)
             WHEN 5 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM,'FM099')
END"];
per.first_name[params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',p_col_len=>30,p_seed=>SEED)"];
per.last_name[params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',p_col_len=>30,p_seed=>SEED)"];
per.full_name[params=":first_name||' '||:last_name"];
per.gender[params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GENDER',p_col_len=>1,p_seed=>SEED)"];
per.birth_date[params="ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12))"];
per.title[null_value_pct=20, params="CASE WHEN :gender = 'M' THEN 'Mr' ELSE ds_masker_krn.random_value_from_list(p_values=>'Ms, Mrs, Miss') END"];
per.manager_flag[params="CASE WHEN MOD(ROWNUM,10)=0 THEN 'Y' END"].per_id_manager[null_value_condition=":manager_flag='Y'"];
per.nationality[gen_type=SQL/*replaces FK*/, params="ds_masker_krn.random_value_from_data_set(p_set_name=>'EU_COUNTRIES_27',p_col_name=>'CODE_A3',p_col_len=>30,p_seed=>SEED,p_weight=>'POPULATION')"];
pas.date_from[params="RECORD gen.date_from"].date_to[params="RECORD gen.date_to"];
pcl.clocking_type[params="RECORD gen.thetype"].clocking_date[params="RECORD gen.thedate"].clocking_time[params="RECORD gen.thetime"];
pcc.credit_card_number[params="ds_masker_krn.random_credit_card_number(p_prefix=>:cct_cd)"].expiry_date[params="ds_masker_krn.random_expiry_date"];
ptr.transaction_timestamp[params="ds_masker_krn.random_time(p_min_date=>PARENT order_date+ROWNUM-1,p_max_date=>PARENT order_date+CASE ROWNUM WHEN 1 THEN 0 ELSE ds_masker_krn.random_integer(1,7) END)"];
ptr.transaction_amount[params="CASE ROWNUM WHEN 1 THEN PARENT total_price * (CASE ROWCOUNT WHEN 1 THEN 100 ELSE 30 END) / 100 ELSE PARENT total_price - LAG transaction_amount END"];
ord.order_date[params="ds_masker_krn.obfuscate_date(sysdate,'YY')"].total_price[params="0/*computed with post_gen_code*/"];
sto.store_name[params="ds_masker_krn.random_company_name"];
prd.unit_price[params="ds_masker_krn.random_integer(10,100)"];
prd.product_name[params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'OBJECTS.NAME',p_col_len=>20)"];
oit.order_line[params=ROWNUM].quantity[params="ds_masker_krn.random_integer(1,8,SEED)"].price[params="RECORD demo_oit_prd_fk.unit_price * :quantity"];
£');
COMMIT;
END;
/

PAUSE Generate data set?
CLEAR SCREEN
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.generate_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');

REM Check statistics
PAUSE Synthetic data generated; please check!
CLEAR SCREEN

select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'), p_table_name=>'DEMO_', p_full_schema=>'Y', p_show_legend=>'Y', p_show_aliases=>'Y', p_show_conf_columns=>'Y'));
