REM 
REM Data Set Utility Demo - Synthetic Data Generation
REM All rights reserved (C)opyright 2023 by Philippe Debois
REM Script based on APIs only (no use of DEGPL)
REM 

REM Create a data set to generate synthetic/fake data 
PAUSE Configure data set?
CLEAR SCREEN
set serveroutput on size 999999
exec ds_utility_krn.set_message_filter('EWI');
exec ds_utility_krn.set_test_mode(FALSE);
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'DEMO_DATA_GEN', p_set_type=>'GEN');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_STORES',p_extract_type=>'B');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_PRODUCTS',p_extract_type=>'B');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_ORG_ENTITIES',p_recursive_level=>1,p_extract_type=>'B');
   ds_utility_krn.include_tables(p_set_id=>l_set_id,p_table_name=>'DEMO_PERSONS', p_recursive_level=>3,p_extract_type=>'B');
   ds_utility_krn.include_referential_cons(p_set_id=>l_set_id,p_extract_type=>'R');
   ds_utility_krn.define_walk_through_strategy(p_set_id=>l_set_id);
--   select * from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') order by seq, table_name;
--   select * from ds_constraints where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN');
   ds_utility_krn.insert_table_columns(p_set_id=>l_set_id);
--   select * from ds_tab_columns where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'));
end;
/

REM Configure table, columns and constraint properties

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN');
BEGIN
   -- Set row count for base tables
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_row_count=>50);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_STORES', p_row_count=>10);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PRODUCTS', p_row_count=>50);
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORG_ENTITIES', p_row_count=>1);   -- 1 institution (root level)
   -- Set order of processing for some tables
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDER_ITEMS', p_tab_seq=>1);      -- order amounts needed to generate...
   ds_utility_krn.update_table_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_TRANSACTIONS', p_tab_seq=>2); -- ...coherent transaction amounts
   -- Set properties of master/detail (1-N) constraints
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PAS_PER_FK', p_cardinality=>'1-N', p_gen_view_name=>'DEMO_RANDOM_DATE_HISTORY'); -- all rows from view
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PCL_PER_FK', p_cardinality=>'1-N', p_gen_view_name=>'DEMO_RANDOM_TIME_CLOCKINGS'); -- all rows from random view
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PCC_PER_FK', p_cardinality=>'1-N', p_min_rows=>2, p_max_rows=>4); -- 2-4 credit cards per person
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_ORD_PER_FK', p_cardinality=>'1-N', p_min_rows=>0, p_max_rows=>5); -- 0-5 orders per person
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_OIT_ORD_FK', p_cardinality=>'1-N', p_min_rows=>1, p_max_rows=>5); -- 1-5 lines per order
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PTR_ORD_FK', p_cardinality=>'1-N', p_min_rows=>0, p_max_rows=>2); -- 0-2 transactions per order
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_OEN_OEN_FK', p_cardinality=>'1-N', p_min_rows=>4, p_max_rows=>6, p_level_count=>5); -- 5 levels, 4-6 siblings
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_OIT_ORD_FK', p_cardinality=>'1-N', p_post_gen_code=>
      q'#UPDATE demo_orders ord SET total_price = (SELECT NVL(SUM(oit.price),0) FROM demo_order_items oit WHERE oit.ord_id = ord.ord_id)#'
   );
   -- Exclude 1-N constraints from base tables not to be used for master/detail generation
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PAS_OEN_FK', p_cardinality=>'1-N', p_extract_type=>'N'); -- assignments not generated from entities
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PTR_PCC_FK', p_cardinality=>'1-N', p_extract_type=>'N'); -- transactions not generated from credit cards
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PER_PER_FK', p_cardinality=>'1-N', p_extract_type=>'N'); -- staff not generated from managers
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_OEN_OEN_FK', p_cardinality=>'N-1', p_extract_type=>'N'); -- N-1 not used as 1-N is used
   -- Set filter for look-up (N-1) constraints
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PAS_OEN_FK', p_cardinality=>'N-1', p_where_clause=>q'#oet_cd != 'INST'#'); -- no assignment to INST
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PTR_PCC_FK', p_cardinality=>'N-1', p_where_clause=>q'#per_id=PARENT per_id#'); -- credit card must belong to the order's person
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_PER_PER_FK', p_cardinality=>'N-1', p_where_clause=>q'#manager_flag='Y'#', p_src_filter=>'manager_flag IS NULL'); -- only managers manage
   ds_utility_krn.update_constraint_properties(p_set_id=>l_set_id, p_constraint_name=>'DEMO_OEN_OET_FK', p_cardinality=>'N-1', p_where_clause=>q'#oet_level=LEVEL#'); -- entity type of the right level
END;
/

DECLARE
   l_set_id ds_data_sets.set_id%TYPE := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN');
BEGIN
   -- Define how to generate ORG_ENTITIES columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORG_ENTITIES', p_col_name=>'OEN_ID', p_gen_type=>'SEQ', p_params=>'DEMO_OEN_SEQ');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORG_ENTITIES', p_col_name=>'OEN_NAME', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'FOOD.NAME',p_col_len=>20)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORG_ENTITIES', p_col_name=>'OEN_CD', p_gen_type=>'SQL', p_params=>
      q'#CASE LEVEL WHEN 1 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 2 THEN ds_masker_krn.random_value_from_regexp('([BCDFGLMNPRSTV][AEIOU]){3}')
             WHEN 3 THEN PRIOR oen_cd||'.'||CHR(ASCII('A')+ROWNUM-1)
             WHEN 4 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM)
             WHEN 5 THEN PRIOR oen_cd||'.'||TO_CHAR(ROWNUM,'FM099')
END#'
   );
   -- Define how to generate PERSONS columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'PER_ID', p_gen_type=>'SEQ', p_params=>'DEMO_PER_SEQ');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'FIRST_NAME', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',p_col_len=>30,p_seed=>SEED)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'LAST_NAME', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_col_name=>'EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',p_col_len=>30,p_seed=>SEED)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'FULL_NAME', p_gen_type=>'SQL', p_params=>
      q'#:first_name||' '||:last_name#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'GENDER', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_col_name=>'INT_GIVEN_NAMES_250.GENDER',p_col_len=>1,p_seed=>SEED)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'BIRTH_DATE', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12))#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'TITLE', p_gen_type=>'SQL', p_null_value_pct=>20, p_params=>
      q'#CASE WHEN :gender = 'M' THEN 'Mr' ELSE ds_masker_krn.random_value_from_list(p_values=>'Ms, Mrs, Miss') END#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'MANAGER_FLAG', p_gen_type=>'SQL', p_null_value_pct=>NULL, p_params=>
      q'#CASE WHEN MOD(ROWNUM,10)=0 THEN 'Y' END#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'PER_ID_MANAGER', p_null_value_condition=>q'#:manager_flag='Y'#');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PERSONS', p_col_name=>'NATIONALITY', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_name=>'EU_COUNTRIES_27',p_col_name=>'CODE_A3',p_col_len=>30,p_seed=>SEED,p_weight=>'POPULATION')#'
   );
   -- Define how to generate ASSIGNMENTS columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_ASSIGNMENTS', p_col_name=>'DATE_FROM', p_gen_type=>'SQL', p_params=>'RECORD gen.date_from');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_ASSIGNMENTS', p_col_name=>'DATE_TO', p_gen_type=>'SQL', p_params=>'RECORD gen.date_to');
   -- Define how to generate CLOCKINGS columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_CLOCKINGS', p_col_name=>'CLOCKING_TYPE', p_gen_type=>'SQL', p_params=>'RECORD gen.thetype');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_CLOCKINGS', p_col_name=>'CLOCKING_DATE', p_gen_type=>'SQL', p_params=>'RECORD gen.thedate');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_CLOCKINGS', p_col_name=>'CLOCKING_TIME', p_gen_type=>'SQL', p_params=>'RECORD gen.thetime');
   -- Define how to generate CREDIT_CARDS columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_CREDIT_CARDS', p_col_name=>'CREDIT_CARD_NUMBER', p_gen_type=>'SQL', p_params=>
      'ds_masker_krn.random_credit_card_number(p_prefix=>:cct_cd)'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_CREDIT_CARDS', p_col_name=>'EXPIRY_DATE', p_gen_type=>'SQL', p_params=>
      'ds_masker_krn.random_expiry_date'
   );
   -- Define how to generate TRANSACTIONS columns
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_TRANSACTIONS', p_col_name=>'TRANSACTION_TIMESTAMP', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_time(p_min_date=>PARENT order_date+ROWNUM-1,p_max_date=>PARENT order_date+CASE ROWNUM WHEN 1 THEN 0 ELSE ds_masker_krn.random_integer(1,7) END)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PER_TRANSACTIONS', p_col_name=>'TRANSACTION_AMOUNT', p_gen_type=>'SQL', p_params=>
      'CASE ROWNUM WHEN 1 THEN PARENT total_price * (CASE ROWCOUNT WHEN 1 THEN 100 ELSE 30 END) / 100 ELSE PARENT total_price - LAG transaction_amount END' --30% on order, remaining on delivery (when 2 payments)
   );
   -- Define how to generate ORDERS
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDERS', p_col_name=>'ORD_ID', p_gen_type=>'SEQ', p_params=>'DEMO_ORD_SEQ');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDERS', p_col_name=>'ORDER_DATE', p_gen_type=>'SQL', p_params=>q'#ds_masker_krn.obfuscate_date(sysdate,'YY')#');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDERS', p_col_name=>'TOTAL_PRICE', p_gen_type=>'SQL', p_params=>'0 /*TBD*/'); -- cannot compute!
   -- Define how to generate STORES
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_STORES', p_col_name=>'STO_ID', p_gen_type=>'SEQ', p_params=>'DEMO_STO_SEQ');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_STORES', p_col_name=>'STORE_NAME', p_gen_type=>'SQL', p_params=>'ds_masker_krn.random_company_name');
   -- Define how to generate PRODUCTS
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PRODUCTS', p_col_name=>'PRD_ID', p_gen_type=>'SEQ', p_params=>'DEMO_PRD_SEQ');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PRODUCTS', p_col_name=>'PRODUCT_NAME', p_gen_type=>'SQL', p_params=>
      q'#ds_masker_krn.random_value_from_data_set(p_set_col_name=>'COLORS.NAME',p_col_len=>20)||' '||ds_masker_krn.random_value_from_data_set(p_set_col_name=>'OBJECTS.NAME',p_col_len=>20)#'
   );
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PRODUCTS', p_col_name=>'UNIT_PRICE', p_gen_type=>'SQL', p_params=>'ds_masker_krn.random_integer(10,100)');
--   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_PRODUCTS', p_col_name=>'DESCR', p_gen_type=>'SQL', p_params=>'ds_masker_krn.lorem_ipsum_clob(5000)');
   -- Define how to generate ORDER_ITEMS
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDER_ITEMS', p_col_name=>'ORDER_LINE', p_gen_type=>'SQL', p_params=>'ROWNUM');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDER_ITEMS', p_col_name=>'QUANTITY', p_gen_type=>'SQL', p_params=>'ds_masker_krn.random_integer(1,8,SEED)');
   ds_utility_krn.update_table_column_properties(p_set_id=>l_set_id, p_table_name=>'DEMO_ORDER_ITEMS', p_col_name=>'PRICE', p_gen_type=>'SQL', p_params=>'RECORD demo_oit_prd_fk.unit_price * :quantity');
   COMMIT;
END;
/

REM Check configuration
--select * from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') order by seq, tab_seq, table_name;
--select * from ds_constraints where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN');
--select * from ds_tab_columns where table_id in (select table_id from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'));

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
--select table_name, extract_type, extract_count gen_count from ds_tables where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN') order by extract_type, table_name;
--select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN')));
--select * from ds_constraints where set_id=ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN');
select * from table(ds_utility_ext.graph_data_set(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'), p_table_name=>'DEMO_', p_full_schema=>'Y', p_show_legend=>'Y', p_show_aliases=>'Y'));
/*

REM CHECK DATA AND THEIR COMPLIANCE WITH BUSINESS RULES

REM Persons
SELECT * FROM demo_persons;
SELECT COUNT(*) FROM demo_persons;
SELECT gender, COUNT(*) cnt FROM demo_persons GROUP BY gender; -- uniform distribution of gender
SELECT nationality, COUNT(*) cnt FROM demo_persons GROUP BY nationality ORDER BY 2 DESC; -- non-uniform distribution of nationality (same distribution as country population)
SELECT manager_flag, COUNT(*) FROM demo_persons GROUP BY manager_flag; -- proportion of managers
SELECT ROUND(SUM(CASE WHEN manager_flag IS NOT NULL THEN 1 ELSE 0 END) / SUM(1) * 100,2) pct_mgr from demo_persons; -- percentage of managers
SELECT * FROM demo_persons WHERE per_id IN (SELECT per_id_manager FROM demo_persons) AND NVL(manager_flag,'N') = 'N'; -- no row: only managers can manage staff
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_persons WHERE per_id_manager IS NOT NULL GROUP BY per_id_manager) GROUP BY cnt ORDER BY 1; -- uniform distribution of managers
SELECT * FROM demo_persons WHERE full_name != first_name||' '||last_name; -- no rows (denormalisation)
SELECT ROUND(SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) / SUM(CASE WHEN title IS NULL THEN 0 ELSE 1 END) *100,2) pct_null from demo_persons; -- percentage of null title
SELECT * FROM demo_persons WHERE months_between(sysdate,birth_date)/12 NOT BETWEEN 18 AND 65; -- check age 

REM Stores
SELECT * FROM demo_stores;
SELECT COUNT(*) FROM demo_stores;

REM Orders
SELECT * FROM demo_orders;
SELECT COUNT(*) FROM demo_orders;
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_orders GROUP BY per_id) GROUP BY cnt ORDER BY 1; -- must be between 1 and 5 orders per person
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_orders GROUP BY sto_id) GROUP BY cnt ORDER BY 1; -- uniform distribution of stores
SELECT * FROM demo_orders ord INNER JOIN (SELECT ord_id, SUM(price) price FROM demo_order_items GROUP BY ord_id) oit on oit.ord_id = ord.ord_id AND oit.price != ord.total_price; -- no row (order price = sum(line price))

REM Products
SELECT * FROM demo_products;
SELECT COUNT(*) FROM demo_products;

REM Order items
SELECT * FROM demo_order_items;
SELECT COUNT(*) FROM demo_order_items;
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_order_items GROUP BY ord_id) GROUP BY cnt ORDER BY 1; -- must be between 1 and 5 items per order
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_order_items GROUP BY prd_id) GROUP BY cnt; -- uniform distribution of products
SELECT * FROM demo_order_items oit INNER JOIN demo_products prd ON prd.prd_id = oit.prd_id WHERE oit.quantity * prd.unit_price != oit.price; -- no row (line price = qty * unit price)

REM Products
SELECT * FROM demo_products;
SELECT COUNT(*) FROM demo_products;

REM Check person's transactions
SELECT * FROM demo_per_transactions order by per_id, ord_id;
SELECT COUNT(*) FROM demo_per_transactions;
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_per_transactions GROUP BY ord_id) GROUP BY cnt; -- must be 1 or 2 transactions per order
SELECT * FROM demo_per_transactions ptr INNER JOIN demo_orders ord ON ord.ord_id = ptr.ord_id WHERE ptr.per_id != ord.per_id; -- no rows: credit card must belong to person's order
SELECT * FROM demo_per_transactions ptr INNER JOIN demo_orders ord ON ord.ord_id = ptr.ord_id WHERE ptr.transaction_timestamp < TRUNC(ord.order_date); -- no rows: transaction on or after order date
SELECT ord_id, SUM(transaction_amount) FROM demo_per_transactions GROUP BY ord_id MINUS SELECT ord_id, total_price FROM demo_orders; -- no rows: order amount = sum(transaction amounts)
SELECT ord_id, total_price FROM demo_orders MINUS SELECT ord_id, SUM(transaction_amount) FROM demo_per_transactions GROUP BY ord_id; -- some orders are not paid at all

REM Organisational entities
SELECT * FROM demo_org_entities;
SELECT COUNT(*) FROM demo_org_entities;
SELECT oet_cd, COUNT(*) FROM demo_org_entities GROUP BY oet_cd ORDER BY 2; -- check number of INST (root)
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_org_entities GROUP BY oen_id_parent) GROUP BY cnt ORDER BY cnt; -- 4, 5 or 6 siblings (childs per parents)
SELECT * FROM demo_org_entities det INNER JOIN demo_org_entities mst ON mst.oen_id = det.oen_id_parent WHERE NOT det.oen_cd LIKE mst.oen_cd||'%' AND mst.oet_cd!='INST'; -- no row (acronym prefix inheritance)

REM Person's assignments
SELECT * FROM demo_per_assignments;
SELECT COUNT(*) FROM demo_per_assignments;
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_per_assignments GROUP BY per_id) GROUP BY cnt; -- must be 3, 4 or 5 assignments per person
SELECT cnt, COUNT(*) FROM (SELECT COUNT(*) cnt FROM demo_per_assignments GROUP BY oen_id) GROUP BY cnt; -- uniform distribution of entities
SELECT * FROM demo_per_assignments a LEFT OUTER JOIN demo_per_assignments b ON b.per_id = a.per_id AND b.date_from = a.date_to WHERE b.date_from IS NULL AND a.date_to != TO_DATE('31/12/9999','DD/MM/YYYY'); -- no rows (consecutive periods)
SELECT a.per_id, a.date_from FROM demo_per_assignments a LEFT OUTER JOIN demo_per_assignments b ON b.per_id = a.per_id AND b.date_to = a.date_from WHERE b.date_from IS NULL
MINUS SELECT per_id, MIN(date_from) FROM demo_per_assignments GROUP BY per_id; -- no rows (consecutive periods)

REM Check person's clockings
SELECT * FROM demo_per_clockings ORDER BY per_id, clocking_date, clocking_time;
SELECT COUNT(*) FROM demo_per_clockings;
SELECT cnt, COUNT(*) FROM (SELECT per_id, COUNT(*) cnt FROM demo_per_clockings GROUP BY per_id) GROUP BY cnt; -- must be 100 clockings per person
SELECT cnt, COUNT(*) FROM (SELECT per_id, clocking_date, COUNT(*) cnt FROM demo_per_clockings GROUP BY per_id, clocking_date) GROUP BY cnt; -- must be 4 clockings per person

REM Create views to look at generated data set

exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_view_suffix=>'_V',p_non_empty_only=>TRUE);

REM Drop views
exec ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'),p_view_suffix=>'_V',p_non_empty_only=>TRUE);

REM Drop data set
--exec ds_utility_krn.delete_data_set_def(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'));
*/
