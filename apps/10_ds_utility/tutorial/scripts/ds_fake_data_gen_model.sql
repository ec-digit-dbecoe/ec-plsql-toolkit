REM 
REM Data Set Utility - Synthetic Data Generation - Tutorial
REM All rights reserved (C)opyright 2023 by Philippe Debois
REM Script for creating the data model
REM 

REM Drop all objects created by a previous run, if any

REM Drop sequences
DECLARE
   TYPE t_obj_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_obj t_obj_type;
BEGIN
   t_obj(t_obj.COUNT+1) := 'tmp_oen_seq';
   t_obj(t_obj.COUNT+1) := 'tmp_per_seq';
   t_obj(t_obj.COUNT+1) := 'tmp_prd_seq';
   t_obj(t_obj.COUNT+1) := 'tmp_ord_seq';
   t_obj(t_obj.COUNT+1) := 'tmp_sto_seq';
   FOR i IN 1..t_obj.COUNT LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP SEQUENCE '||t_obj(i);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;
END;
/

REM Drop tables (in the right order)
DECLARE
   TYPE t_obj_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_obj t_obj_type;
BEGIN
   t_obj(t_obj.COUNT+1) := 'tmp_per_clockings';
   t_obj(t_obj.COUNT+1) := 'tmp_per_transactions';
   t_obj(t_obj.COUNT+1) := 'tmp_per_credit_cards';
   t_obj(t_obj.COUNT+1) := 'tmp_per_assignments';
   t_obj(t_obj.COUNT+1) := 'tmp_org_entities';
   t_obj(t_obj.COUNT+1) := 'tmp_order_items';
   t_obj(t_obj.COUNT+1) := 'tmp_orders';
   t_obj(t_obj.COUNT+1) := 'tmp_persons';
   t_obj(t_obj.COUNT+1) := 'tmp_stores';
   t_obj(t_obj.COUNT+1) := 'tmp_products';
   t_obj(t_obj.COUNT+1) := 'tmp_org_entity_types';
   t_obj(t_obj.COUNT+1) := 'tmp_credit_card_types';
   t_obj(t_obj.COUNT+1) := 'tmp_countries';
   FOR i IN 1..t_obj.COUNT LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE '||t_obj(i);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;
END;
/

REM Drop views
DECLARE
   TYPE t_obj_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_obj t_obj_type;
BEGIN
   t_obj(t_obj.COUNT+1) := 'tmp_random_date_history';
   t_obj(t_obj.COUNT+1) := 'tmp_random_time_clockings';
   t_obj(t_obj.COUNT+1) := 'ds_eu_countries_27_v';
   FOR i IN 1..t_obj.COUNT LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP VIEW '||t_obj(i);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;
END;
/

REM Create tutorial objects

REM Types of organisational entities

CREATE TABLE tmp_org_entity_types (oet_cd VARCHAR2(10) NOT NULL, oet_name VARCHAR2(30) NOT NULL, oet_level NUMBER(2) NOT NULL);

COMMENT ON TABLE tmp_org_entity_types IS 'Types of organisational entities';
COMMENT ON COLUMN tmp_org_entity_types.oet_cd IS 'Entity type code';
COMMENT ON COLUMN tmp_org_entity_types.oet_name IS 'Entity type name';
COMMENT ON COLUMN tmp_org_entity_types.oet_level IS 'Entity type level';

ALTER TABLE tmp_org_entity_types ADD (
   CONSTRAINT tmp_oet_pk PRIMARY KEY (oet_cd) USING INDEX
);

REM Organisational entities (hierarchical, forest i.e. several trees - one per institution)

CREATE TABLE tmp_org_entities (oen_id NUMBER(9) NOT NULL, oen_cd VARCHAR2(30) NOT NULL, oen_name VARCHAR2(60) NOT NULL, oet_cd VARCHAR2(10) NOT NULL, oen_id_parent NUMBER(9) NULL);

COMMENT ON TABLE tmp_org_entities IS 'Organisational entities';
COMMENT ON COLUMN tmp_org_entities.oen_id IS 'Entity id';
COMMENT ON COLUMN tmp_org_entities.oen_cd IS 'Entity code';
COMMENT ON COLUMN tmp_org_entities.oen_name IS 'Entity name';
COMMENT ON COLUMN tmp_org_entities.oet_cd IS 'Entity type';
COMMENT ON COLUMN tmp_org_entities.oen_id_parent IS 'Parent entity id';

CREATE UNIQUE INDEX tmp_oen_pk ON tmp_org_entities(oen_id);

ALTER TABLE tmp_org_entities ADD (
   CONSTRAINT tmp_oen_pk PRIMARY KEY (oen_id) USING INDEX
);

CREATE SEQUENCE tmp_oen_seq;

ALTER TABLE tmp_org_entities ADD (
   CONSTRAINT tmp_oen_oet_fk FOREIGN KEY (oet_cd)
   REFERENCES tmp_org_entity_types (oet_cd)
);

ALTER TABLE tmp_org_entities ADD (
   CONSTRAINT tmp_oen_oen_fk FOREIGN KEY (oen_id_parent)
   REFERENCES tmp_org_entities (oen_id)
);

CREATE INDEX tmp_oen_oen_fk_i ON tmp_org_entities(oen_id_parent);

REM Countries

CREATE TABLE tmp_countries (cnt_cd VARCHAR2(3) NOT NULL, cnt_name VARCHAR2(100) NOT NULL, population NUMBER(9) NULL);

COMMENT ON TABLE tmp_countries IS 'Countries';
COMMENT ON COLUMN tmp_countries.cnt_cd IS 'Country code';
COMMENT ON COLUMN tmp_countries.cnt_name IS 'Country name';
COMMENT ON COLUMN tmp_countries.cnt_name IS 'Population (EUROSTAT 01/01/2023)';

CREATE UNIQUE INDEX tmp_cnt_pk ON tmp_countries (cnt_cd);

ALTER TABLE tmp_countries ADD (
   CONSTRAINT tmp_cnt_pk PRIMARY KEY (cnt_cd) USING INDEX
);

REM Credit card types

CREATE TABLE tmp_credit_card_types (cct_cd VARCHAR2(10) NOT NULL, cct_name VARCHAR(100) NOT NULL);

COMMENT ON TABLE tmp_credit_card_types IS 'Credit card types';
COMMENT ON COLUMN tmp_credit_card_types.cct_cd IS 'Card prefix';
COMMENT ON COLUMN tmp_credit_card_types.cct_name IS 'Card name';

CREATE UNIQUE INDEX tmp_cct_pk ON tmp_credit_card_types (cct_cd);

ALTER TABLE tmp_credit_card_types ADD (
   CONSTRAINT tmp_cct_pk PRIMARY KEY (cct_cd) USING INDEX
);

REM Persons

CREATE TABLE tmp_persons (
   per_id NUMBER(9) NOT NULL, first_name VARCHAR2(30) NOT NULL, last_name VARCHAR2(30) NOT NULL
 , full_name VARCHAR2(61) NOT NULL, gender VARCHAR2(1) NOT NULL, birth_date DATE NOT NULL
 , nationality VARCHAR2(3) NOT NULL, title VARCHAR2(4) NULL
 , manager_flag VARCHAR2(1) NULL, per_id_manager NUMBER(9) NULL
);

COMMENT ON TABLE tmp_persons IS 'Persons';
COMMENT ON COLUMN tmp_persons.per_id IS 'Person id';
COMMENT ON COLUMN tmp_persons.first_name IS 'Given name';
COMMENT ON COLUMN tmp_persons.last_name IS 'Family name';
COMMENT ON COLUMN tmp_persons.last_name IS 'Full person name';
COMMENT ON COLUMN tmp_persons.gender IS 'Gender';
COMMENT ON COLUMN tmp_persons.birth_date IS 'Birth date';
COMMENT ON COLUMN tmp_persons.nationality IS 'Nationality';
COMMENT ON COLUMN tmp_persons.title IS 'Title (Mr, Ms, Mrs, Miss)';
COMMENT ON COLUMN tmp_persons.manager_flag IS 'Is this person a manager (Y/N)?';
COMMENT ON COLUMN tmp_persons.per_id_manager IS 'Person id of the manager';

CREATE SEQUENCE tmp_per_seq;

CREATE UNIQUE INDEX tmp_per_pk ON tmp_persons (per_id);

ALTER TABLE tmp_persons ADD (
   CONSTRAINT tmp_per_pk PRIMARY KEY (per_id) USING INDEX
);

ALTER TABLE tmp_persons ADD (
   CONSTRAINT tmp_per_cnt_fk FOREIGN KEY (nationality)
   REFERENCES tmp_countries (cnt_cd)
);

CREATE INDEX tmp_per_cnt_fk_i ON tmp_persons (nationality);

ALTER TABLE tmp_persons ADD (
   CONSTRAINT tmp_per_per_fk FOREIGN KEY (per_id_manager)
   REFERENCES tmp_persons (per_id)
);

CREATE INDEX tmp_per_per_fk_i ON tmp_persons (per_id_manager);

ALTER TABLE tmp_persons MODIFY (
   manager_flag CONSTRAINT tmp_per_manager_flag_ck CHECK (manager_flag IS NULL OR manager_flag IN ('Y','N'))
);

REM Person's credit cards

CREATE TABLE tmp_per_credit_cards (per_id NUMBER(9) NOT NULL, cct_cd VARCHAR2(40) NOT NULL, credit_card_number VARCHAR2(40) NOT NULL, expiry_date DATE NOT NULL);

COMMENT ON TABLE tmp_per_credit_cards IS q'#Person's credit cards#';
COMMENT ON COLUMN tmp_per_credit_cards.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_credit_cards.credit_card_number IS 'Credit card number';
COMMENT ON COLUMN tmp_per_credit_cards.expiry_date IS 'Credit card expiry date';

CREATE UNIQUE INDEX tmp_pcc_pk ON tmp_per_credit_cards (per_id, credit_card_number);

ALTER TABLE tmp_per_credit_cards ADD (
   CONSTRAINT tmp_pcc_pk PRIMARY KEY (per_id, credit_card_number) USING INDEX
);

ALTER TABLE tmp_per_credit_cards ADD (
   CONSTRAINT tmp_pcc_per_fk FOREIGN KEY (per_id)
   REFERENCES tmp_persons (per_id)
);

ALTER TABLE tmp_per_credit_cards ADD (
   CONSTRAINT tmp_pcc_cct_fk FOREIGN KEY (cct_cd)
   REFERENCES tmp_credit_card_types (cct_cd)
);

CREATE INDEX tmp_pcc_cct_fk_i ON tmp_per_credit_cards (cct_cd);

REM Person's clockings

CREATE TABLE tmp_per_clockings (per_id NUMBER(9) NOT NULL, clocking_date DATE NOT NULL, clocking_time VARCHAR2(8) NOT NULL, clocking_type VARCHAR2(3) NOT NULL);

COMMENT ON TABLE tmp_per_clockings IS q'#Person's clockings#';
COMMENT ON COLUMN tmp_per_clockings.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_clockings.clocking_type IS 'Clocking type (IN/OUT)';
COMMENT ON COLUMN tmp_per_clockings.clocking_date IS 'Clocking date';
COMMENT ON COLUMN tmp_per_clockings.clocking_time IS 'Clocking time';

CREATE UNIQUE INDEX tmp_pcl_pk ON tmp_per_clockings (per_id, clocking_date, clocking_time);

ALTER TABLE tmp_per_clockings ADD (
   CONSTRAINT tmp_pcl_pk PRIMARY KEY (per_id, clocking_date, clocking_time) USING INDEX
);

ALTER TABLE tmp_per_clockings ADD (
   CONSTRAINT tmp_pcl_per_fk FOREIGN KEY (per_id)
   REFERENCES tmp_persons (per_id)
);

ALTER TABLE tmp_per_clockings MODIFY (
   clocking_type CONSTRAINT tmp_pcl_clocking_type_ck CHECK (clocking_type IN ('IN','OUT'))
);

REM Person's assignments to organisational entities (historic table)

CREATE TABLE tmp_per_assignments (per_id NUMBER(9) NOT NULL, date_from DATE NOT NULL, date_to DATE NOT NULL, oen_id NUMBER(9) NOT NULL);

COMMENT ON TABLE tmp_per_assignments IS q'#Person's assignments#';
COMMENT ON COLUMN tmp_per_assignments.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_assignments.date_from IS 'Assigned since';
COMMENT ON COLUMN tmp_per_assignments.date_to IS 'Assigned until (not included)';
COMMENT ON COLUMN tmp_per_assignments.oen_id IS 'Entity id';

CREATE UNIQUE INDEX tmp_pas_pk ON tmp_per_assignments (per_id, date_from);

ALTER TABLE tmp_per_assignments ADD (
   CONSTRAINT tmp_pas_pk PRIMARY KEY (per_id, date_from) USING INDEX
);

ALTER TABLE tmp_per_assignments ADD (
   CONSTRAINT tmp_pas_per_fk FOREIGN KEY (per_id)
   REFERENCES tmp_persons (per_id)
);

ALTER TABLE tmp_per_assignments ADD (
   CONSTRAINT tmp_pas_oen_fk FOREIGN KEY (oen_id)
   REFERENCES tmp_org_entities (oen_id)
);

CREATE INDEX tmp_pas_oen_fk_i ON tmp_per_assignments (oen_id);

REM Stores

CREATE TABLE tmp_stores (sto_id NUMBER(9) NOT NULL, store_name VARCHAR2(100) NOT NULL);

COMMENT ON TABLE tmp_stores IS 'Stores';
COMMENT ON COLUMN tmp_stores.sto_id IS 'Store id';
COMMENT ON COLUMN tmp_stores.store_name IS 'Store name';

CREATE SEQUENCE tmp_sto_seq;

CREATE UNIQUE INDEX tmp_sto_pk ON tmp_stores (sto_id);

ALTER TABLE tmp_stores ADD (
   CONSTRAINT tmp_sto_pk PRIMARY KEY (sto_id) USING INDEX
);

REM Orders

CREATE TABLE tmp_orders (ord_id NUMBER(9) NOT NULL, per_id NUMBER(9) NOT NULL, sto_id NUMBER(9) NOT NULL, order_date DATE NOT NULL, total_price NUMBER(9) NOT NULL);

COMMENT ON TABLE tmp_orders IS 'Orders';
COMMENT ON COLUMN tmp_orders.ord_id IS 'Order id';
COMMENT ON COLUMN tmp_orders.order_date IS 'Order date';
COMMENT ON COLUMN tmp_orders.total_price IS 'Total price';

CREATE SEQUENCE tmp_ord_seq;

CREATE UNIQUE INDEX tmp_ord_pk ON tmp_orders (ord_id);

ALTER TABLE tmp_orders ADD (
   CONSTRAINT tmp_ord_pk PRIMARY KEY (ord_id) USING INDEX
);

ALTER TABLE tmp_orders ADD (
   CONSTRAINT tmp_ord_per_fk FOREIGN KEY (per_id)
   REFERENCES tmp_persons (per_id)
);

CREATE INDEX tmp_ord_per_fk_i ON tmp_orders (per_id);

ALTER TABLE tmp_orders ADD (
   CONSTRAINT tmp_ord_sto_fk FOREIGN KEY (sto_id)
   REFERENCES tmp_stores (sto_id)
);

CREATE INDEX tmp_ord_sto_fk_i ON tmp_orders (sto_id);

REM Products

CREATE TABLE tmp_products (prd_id NUMBER(9) NOT NULL, product_name VARCHAR2(100) NOT NULL, unit_price NUMBER(9) NULL, descr CLOB NULL);

COMMENT ON TABLE tmp_products IS 'Products';
COMMENT ON COLUMN tmp_products.prd_id IS 'Product id';
COMMENT ON COLUMN tmp_products.product_name IS 'Product name';
COMMENT ON COLUMN tmp_products.unit_price IS 'Unit price';

CREATE SEQUENCE tmp_prd_seq;

CREATE UNIQUE INDEX tmp_prd_pk ON tmp_products (prd_id);

ALTER TABLE tmp_products ADD (
   CONSTRAINT tmp_prd_pk PRIMARY KEY (prd_id) USING INDEX
);

REM Order items

CREATE TABLE tmp_order_items (ord_id NUMBER(9) NOT NULL, order_line NUMBER(3) NOT NULL, prd_id NUMBER(9) NOT NULL, quantity NUMBER(9) NOT NULL, price NUMBER(9) NOT NULL);

COMMENT ON TABLE tmp_order_items IS 'Order items';
COMMENT ON COLUMN tmp_order_items.ord_id IS 'Order id';
COMMENT ON COLUMN tmp_order_items.order_line IS 'Order line';
COMMENT ON COLUMN tmp_order_items.prd_id IS 'Product id';
COMMENT ON COLUMN tmp_order_items.quantity IS 'Quantity';
COMMENT ON COLUMN tmp_order_items.price IS 'Price';

CREATE UNIQUE INDEX tmp_oit_pk ON tmp_order_items (ord_id, order_line);

ALTER TABLE tmp_order_items ADD (
   CONSTRAINT tmp_oit_pk PRIMARY KEY (ord_id, order_line) USING INDEX
);

ALTER TABLE tmp_order_items ADD (
   CONSTRAINT tmp_oit_ord_fk FOREIGN KEY (ord_id)
   REFERENCES tmp_orders (ord_id)
);

ALTER TABLE tmp_order_items ADD (
   CONSTRAINT tmp_oit_prd_fk FOREIGN KEY (prd_id)
   REFERENCES tmp_products (prd_id)
);

CREATE INDEX tmp_oit_prd_fk_i ON tmp_order_items (prd_id);

REM Person's transactions with credit cards

CREATE TABLE tmp_per_transactions (per_id NUMBER(9) NOT NULL, ord_id NUMBER(9) NOT NULL, credit_card_nbr VARCHAR2(40) NOT NULL, transaction_timestamp TIMESTAMP NOT NULL, transaction_amount NUMBER NOT NULL);

COMMENT ON TABLE tmp_per_transactions IS q'#Person's credit card transactions#';
COMMENT ON COLUMN tmp_per_transactions.per_id IS 'Person id';
COMMENT ON COLUMN tmp_per_transactions.ord_id IS 'Order id';
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

ALTER TABLE tmp_per_transactions ADD (
   CONSTRAINT tmp_ptr_ord_fk FOREIGN KEY (ord_id)
   REFERENCES tmp_orders (ord_id)
);

CREATE INDEX tmp_ptr_ord_fk_i ON tmp_per_transactions (ord_id);

REM Truncate generated tables (in the right order)

TRUNCATE TABLE tmp_per_clockings;
TRUNCATE TABLE tmp_per_transactions;
TRUNCATE TABLE tmp_per_credit_cards;
TRUNCATE TABLE tmp_per_assignments;
TRUNCATE TABLE tmp_org_entities;
TRUNCATE TABLE tmp_order_items;
TRUNCATE TABLE tmp_orders;
TRUNCATE TABLE tmp_persons;
TRUNCATE TABLE tmp_stores;
TRUNCATE TABLE tmp_products;

REM Truncate reference tables (populated via this script)

TRUNCATE TABLE tmp_org_entity_types;
TRUNCATE TABLE tmp_countries;
TRUNCATE TABLE tmp_credit_card_types;

REM Populate entity types

INSERT INTO tmp_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('INST', 'Institution', 1);
INSERT INTO tmp_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('DG', 'Directorate General', 2);
INSERT INTO tmp_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('DIR', 'Directorate', 3);
INSERT INTO tmp_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('UNIT', 'Unit', 4);
INSERT INTO tmp_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('SECT', 'Sector', 5);
COMMIT;

REM Populate countries (from view created over EU_COUNTRIES_27 data set)

exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('EU_COUNTRIES_27'),p_set_type=>'CSV',p_view_prefix=>'DS_',p_view_suffix=>'_V');
INSERT INTO tmp_countries (cnt_cd, cnt_name, population) SELECT code_a3, name, population FROM ds_eu_countries_27_v;
COMMIT;

REM Populate credit card types (credit card number prefixes)

INSERT INTO tmp_credit_card_types (cct_cd, cct_name) VALUES ('3','American Express');
INSERT INTO tmp_credit_card_types (cct_cd, cct_name) VALUES ('4','Visa');
INSERT INTO tmp_credit_card_types (cct_cd, cct_name) VALUES ('5','Mastercard');
INSERT INTO tmp_credit_card_types (cct_cd, cct_name) VALUES ('6011','Discover');
COMMIT;

REM Create view to generate random date intervals (for historic tables)

CREATE OR REPLACE VIEW tmp_random_date_history AS
SELECT *
FROM (
SELECT row#, date_from, lead(date_from,1,TO_DATE('31129999','DDMMYYYY')) OVER (ORDER BY date_from) AS date_to, duration months FROM (
SELECT row#, add_months(TO_DATE('01012000','DDMMYYYY'),SUM(duration) OVER (ORDER BY row# ROWS UNBOUNDED PRECEDING)) date_from, duration FROM (
SELECT row#, ds_masker_krn.random_integer(1,12) duration
  FROM (SELECT LEVEL row# FROM sys.dual CONNECT BY LEVEL<=ds_masker_krn.random_integer(3,5))
)))
;

REM Check
SELECT * FROM tmp_random_date_history;

REM Create view to generate random time clockings (IN/OUT, 4 per working day) for 5 weeks before today

CREATE OR REPLACE VIEW tmp_random_time_clockings AS
SELECT rownum row#, thedate, thetime, thetype FROM (
SELECT thedate, thetime, thetype
  FROM sys.dual
 INNER JOIN (SELECT row#, SYSDATE+row#-35-1 thedate FROM (SELECT LEVEL row# FROM sys.dual CONNECT BY LEVEL<=35) WHERE TO_CHAR(SYSDATE+row#-50,'DY') NOT IN ('SAT','SUN')) ON 1=1
 INNER JOIN (SELECT row#, TO_CHAR(thetime,'HH24:MI:SS') thetime, thetype
 FROM (
   SELECT row#
        , CASE row# WHEN 1 THEN ds_masker_krn.random_time(SYSDATE,SYSDATE,'07:50:00','09:40:59') -- IN into the office
                    WHEN 2 THEN ds_masker_krn.random_time(SYSDATE,SYSDATE,'11:50:00','13:10:59') -- OUT for lunch time
                    WHEN 3 THEN ds_masker_krn.random_time(SYSDATE,SYSDATE,'13:10:00','14:10:59') -- IN from lunch time
                    WHEN 4 THEN ds_masker_krn.random_time(SYSDATE,SYSDATE,'16:20:00','19:10:59') -- OUT from the office
           END thetime
        , CASE row# WHEN 1 THEN 'IN'
                    WHEN 2 THEN 'OUT'
                    WHEN 3 THEN 'IN'
                    WHEN 4 THEN 'OUT'
           END thetype
   FROM (SELECT LEVEL row# FROM sys.dual CONNECT BY LEVEL<=4)
)) ON 1=1
ORDER BY thedate, thetime
);

REM Check 
SELECT * FROM tmp_random_time_clockings order by row# desc;
