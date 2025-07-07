REM 
REM Data Set Utility Demo - Synthetic Data Generation
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script with configuration based on DEGPL
REM 

REM Used APIs:
REM . execute_degpl()
REM . generate_data_set()
REM . graph_data_set()

REM Create a data set to generate synthetic/fake data 
PAUSE Configure synthetic data generation model?
CLEAR SCREEN
set serveroutput on size 999999
whenever sqlerror exit sqlcode

BEGIN
ds_utility_krn.set_message_filter('EWI');
ds_utility_ext.execute_degpl(p_commit=>TRUE,p_code=>q'£
set demo_data_gen/r[set_type=GEN];
demo*>-demo*/*include all demo tables and their fks, isolated tables excluded*/;
sto/b[row_count=10];oen/b[row_count=1];prd/b[row_count=50];per/b[row_count=50];
oet/r;cct/r;cnt/r;
oit[tab_seq=1];ptr[tab_seq=2];
per=>[min_rows=0,max_rows=5]ord;
per>-[where_clause="manager_flag='Y'",src_filter="manager_flag IS NULL"]per;
per≠<per;
per=>[gen_view_name=demo_random_date_history]pas;
per=>[gen_view_name=demo_random_time_clockings]pcl;
per=>[min_rows=2,max_rows=4]pcc;
ptr->[where_clause="per_id=PARENT per_id"]pcc+>ptr;
ord=>[min_rows=1,max_rows=5]oit;
ord~>[post_gen_code="UPDATE demo_orders ord SET total_price = (SELECT NVL(SUM(oit.price),0) FROM demo_order_items oit WHERE oit.ord_id = ord.ord_id)"]oit;
ord=>[min_rows=0,max_rows=2]ptr;
pas->[where_clause="oet_cd != 'INST'"]oen+>pas;
oen=<[min_rows=4,max_rows=6,level_count=5]oen>≠oen;
oen>-[where_clause="oet_level=LEVEL"]oet;
∃*∄>-0*/*Add recursively missing N-1 constraints for included tables (to ensure referential integrity)*/;
column[gen_type=SEQ];
per.per_id[gen_params=DEMO_PER_SEQ];
oen.oen_id[gen_params=DEMO_OEN_SEQ];
ord.ord_id[gen_params=DEMO_ORD_SEQ];
sto.sto_id[gen_params=DEMO_STO_SEQ];
prd.prd_id[gen_params=DEMO_PRD_SEQ];
column[gen_type=SQL];
oen.oen_name[gen_params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'FOOD.NAME',p_col_len=>20)"];
oen.oen_cd[gen_params="CASE LEVEL WHEN 1 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 2 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 3 THEN PRIOR oen_cd||'.'||CHR(ASCII('A')+ROWNUM-1)
             WHEN 4 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM)
             WHEN 5 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM,'FM099')
END"];
per.first_name[gen_params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',p_col_len=>30,p_seed=>SEED)"];
per.last_name[gen_params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',p_col_len=>30,p_seed=>SEED)"];
per.full_name[gen_params=":first_name||' '||:last_name"];
per.gender[gen_params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GENDER',p_col_len=>1,p_seed=>SEED)"];
per.birth_date[gen_params="ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12))"];
per.title[null_value_pct=20, gen_params="CASE WHEN :gender = 'M' THEN 'Mr' ELSE ds_masker_krn.random_value_from_list(p_values=>'Ms, Mrs, Miss') END"];
per.manager_flag[gen_params="CASE WHEN MOD(ROWNUM,10)=0 THEN 'Y' END"].per_id_manager[null_value_condition=":manager_flag='Y'"];
per.nationality[gen_type=SQL/*replaces FK*/, gen_params="ds_masker_krn.random_value_from_data_set(p_set_name=>'EU_COUNTRIES_27',p_col_name=>'CODE_A3',p_col_len=>30,p_seed=>SEED,p_weight=>'POPULATION')"];
pas.date_from[gen_params="RECORD gen.date_from"].date_to[gen_params="RECORD gen.date_to"];
pcl.clocking_type[gen_params="RECORD gen.thetype"].clocking_date[gen_params="RECORD gen.thedate"].clocking_time[gen_params="RECORD gen.thetime"];
pcc.credit_card_number[gen_params="ds_masker_krn.random_credit_card_number(p_prefix=>:cct_cd)"].expiry_date[gen_params="ds_masker_krn.random_expiry_date"];
ptr.transaction_timestamp[gen_params="ds_masker_krn.random_time(p_min_date=>PARENT order_date+ROWNUM-1,p_max_date=>PARENT order_date+CASE ROWNUM WHEN 1 THEN 0 ELSE ds_masker_krn.random_integer(1,7) END)"];
ptr.transaction_amount[gen_params="CASE ROWNUM WHEN 1 THEN PARENT total_price * (CASE ROWCOUNT WHEN 1 THEN 100 ELSE 30 END) / 100 ELSE PARENT total_price - LAG transaction_amount END"];
ord.order_date[gen_params="ds_masker_krn.obfuscate_date(sysdate,'YY')"].total_price[gen_params="0/*computed with post_gen_code*/"];
sto.store_name[gen_params="ds_masker_krn.random_company_name"];
prd.unit_price[gen_params="ds_masker_krn.random_integer(10,100)"];
prd.product_name[gen_params="ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'OBJECTS.NAME',p_col_len=>20)"];
oit.order_line[gen_params=ROWNUM].quantity[gen_params="ds_masker_krn.random_integer(1,8,SEED)"].price[gen_params="RECORD demo_oit_prd_fk.unit_price * :quantity"];
£');
END;
/

PAUSE Generate diagram showing data generation model?
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') -- data set id
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'N' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'Y' -- show configuration?
  , p_show_stats=>'N' -- show statistics?
  , p_show_conf_columns=>'Y' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'N' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'Y' -- show column types?
  , p_show_constraints=>'N' -- show contraints and their columns?
  , p_show_indexes=>'N' -- show indexes and their columns?
  , p_show_triggers=>'N' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
));

PAUSE Generate synthetic data?
CLEAR SCREEN
@@18_demo_src_tables_stats.sql
--exec ds_utility_krn.set_message_filter('EWIS');
--exec ds_utility_krn.set_test_mode(TRUE);
exec ds_utility_krn.generate_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_final_commit=>TRUE);
--exec ds_utility_krn.set_test_mode(FALSE);
--exec ds_utility_krn.set_message_filter('EWI');

@@18_demo_src_tables_stats.sql

REM Check statistics
PAUSE Generate diagram showing data generation statistics?
CLEAR SCREEN

select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') -- data set id
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'N' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'N' -- show configuration?
  , p_show_stats=>'Y' -- show statistics?
  , p_show_conf_columns=>'Y' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'N' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'Y' -- show column types?
  , p_show_constraints=>'N' -- show contraints and their columns?
  , p_show_indexes=>'N' -- show indexes and their columns?
  , p_show_triggers=>'N' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
));

PAUSE Show generated data?
CLEAR SCREEN
SELECT * FROM demo_persons ORDER BY per_id;
SELECT * FROM demo_stores ORDER BY sto_id;
SELECT * FROM demo_products ORDER BY prd_id;
SELECT * FROM demo_per_credit_cards ORDER BY per_id;

SELECT LPAD(' ',level*3)||oen_cd||': '||oen_name||' ('||oet_cd||')' ORG_CHART
  FROM demo_org_entities
 CONNECT BY oen_id_parent = PRIOR oen_id
 START WITH oet_cd = 'INST'
 ORDER SIBLINGS BY oen_cd
;