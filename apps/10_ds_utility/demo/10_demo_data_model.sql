REM 
REM Data Set Utility Demo - Data Model Creation
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script to create demo data model i.e. db objects
REM 

REM Drop all demo db objects

@16_demo_drop_all.sql

REM Types of organisational entities

CREATE TABLE demo_org_entity_types (oet_cd VARCHAR2(10) NOT NULL, oet_name VARCHAR2(30) NOT NULL, oet_level NUMBER(2) NOT NULL);

COMMENT ON TABLE demo_org_entity_types IS 'Types of organisational entities';
COMMENT ON COLUMN demo_org_entity_types.oet_cd IS 'Entity type code';
COMMENT ON COLUMN demo_org_entity_types.oet_name IS 'Entity type name';
COMMENT ON COLUMN demo_org_entity_types.oet_level IS 'Entity type level';

ALTER TABLE demo_org_entity_types ADD (
   CONSTRAINT demo_oet_pk PRIMARY KEY (oet_cd) USING INDEX
);

REM Organisational entities (hierarchical, forest i.e. several trees - one per institution)

CREATE TABLE demo_org_entities (oen_id NUMBER(9) NOT NULL, oen_cd VARCHAR2(30) NOT NULL, oen_name VARCHAR2(60) NOT NULL, oet_cd VARCHAR2(10) NOT NULL, oen_id_parent NUMBER(9) NULL);

COMMENT ON TABLE demo_org_entities IS 'Organisational entities';
COMMENT ON COLUMN demo_org_entities.oen_id IS 'Entity id';
COMMENT ON COLUMN demo_org_entities.oen_cd IS 'Entity code';
COMMENT ON COLUMN demo_org_entities.oen_name IS 'Entity name';
COMMENT ON COLUMN demo_org_entities.oet_cd IS 'Entity type';
COMMENT ON COLUMN demo_org_entities.oen_id_parent IS 'Parent entity id';

CREATE UNIQUE INDEX demo_oen_pk ON demo_org_entities(oen_id);

ALTER TABLE demo_org_entities ADD (
   CONSTRAINT demo_oen_pk PRIMARY KEY (oen_id) USING INDEX
);

CREATE SEQUENCE demo_oen_seq;

ALTER TABLE demo_org_entities ADD (
   CONSTRAINT demo_oen_oet_fk FOREIGN KEY (oet_cd)
   REFERENCES demo_org_entity_types (oet_cd)
);

ALTER TABLE demo_org_entities ADD (
   CONSTRAINT demo_oen_oen_fk FOREIGN KEY (oen_id_parent)
   REFERENCES demo_org_entities (oen_id)
);

CREATE INDEX demo_oen_oet_fk_i ON demo_org_entities(oet_cd);

CREATE INDEX demo_oen_oen_fk_i ON demo_org_entities(oen_id_parent);

REM Countries

CREATE TABLE demo_countries (cnt_cd VARCHAR2(3) NOT NULL, cnt_name VARCHAR2(100) NOT NULL, population NUMBER(9) NULL);

COMMENT ON TABLE demo_countries IS 'Countries';
COMMENT ON COLUMN demo_countries.cnt_cd IS 'Country code';
COMMENT ON COLUMN demo_countries.cnt_name IS 'Country name';
COMMENT ON COLUMN demo_countries.cnt_name IS 'Population (EUROSTAT 01/01/2023)';

CREATE UNIQUE INDEX demo_cnt_pk ON demo_countries (cnt_cd);

ALTER TABLE demo_countries ADD (
   CONSTRAINT demo_cnt_pk PRIMARY KEY (cnt_cd) USING INDEX
);

REM Credit card types

CREATE TABLE demo_credit_card_types (cct_cd VARCHAR2(10) NOT NULL, cct_name VARCHAR(100) NOT NULL);

COMMENT ON TABLE demo_credit_card_types IS 'Credit card types';
COMMENT ON COLUMN demo_credit_card_types.cct_cd IS 'Card prefix';
COMMENT ON COLUMN demo_credit_card_types.cct_name IS 'Card name';

CREATE UNIQUE INDEX demo_cct_pk ON demo_credit_card_types (cct_cd);

ALTER TABLE demo_credit_card_types ADD (
   CONSTRAINT demo_cct_pk PRIMARY KEY (cct_cd) USING INDEX
);

REM Persons

CREATE TABLE demo_persons (
   per_id NUMBER(9) NOT NULL, first_name VARCHAR2(30) NOT NULL, last_name VARCHAR2(30) NOT NULL
 , full_name VARCHAR2(61) NOT NULL, gender VARCHAR2(1) NOT NULL, birth_date DATE NOT NULL
 , nationality VARCHAR2(3) NOT NULL, title VARCHAR2(4) NULL
 , manager_flag VARCHAR2(1) NULL, per_id_manager NUMBER(9) NULL
);

COMMENT ON TABLE demo_persons IS 'Persons';
COMMENT ON COLUMN demo_persons.per_id IS 'Person id';
COMMENT ON COLUMN demo_persons.first_name IS 'Given name';
COMMENT ON COLUMN demo_persons.last_name IS 'Family name';
COMMENT ON COLUMN demo_persons.last_name IS 'Full person name';
COMMENT ON COLUMN demo_persons.gender IS 'Gender';
COMMENT ON COLUMN demo_persons.birth_date IS 'Birth date';
COMMENT ON COLUMN demo_persons.nationality IS 'Nationality';
COMMENT ON COLUMN demo_persons.title IS 'Title (Mr, Ms, Mrs, Miss)';
COMMENT ON COLUMN demo_persons.manager_flag IS 'Is this person a manager (Y/N)?';
COMMENT ON COLUMN demo_persons.per_id_manager IS 'Person id of the manager';

CREATE SEQUENCE demo_per_seq;

CREATE UNIQUE INDEX demo_per_pk ON demo_persons (per_id);

ALTER TABLE demo_persons ADD (
   CONSTRAINT demo_per_pk PRIMARY KEY (per_id) USING INDEX
);

ALTER TABLE demo_persons ADD (
   CONSTRAINT demo_per_cnt_fk FOREIGN KEY (nationality)
   REFERENCES demo_countries (cnt_cd)
);

CREATE INDEX demo_per_cnt_fk_i ON demo_persons (nationality);

ALTER TABLE demo_persons ADD (
   CONSTRAINT demo_per_per_fk FOREIGN KEY (per_id_manager)
   REFERENCES demo_persons (per_id)
);

CREATE INDEX demo_per_per_fk_i ON demo_persons (per_id_manager);

ALTER TABLE demo_persons MODIFY (
   manager_flag CONSTRAINT demo_per_manager_flag_ck CHECK (manager_flag IS NULL OR manager_flag IN ('Y','N'))
);

REM Person's credit cards

CREATE TABLE demo_per_credit_cards (per_id NUMBER(9) NOT NULL, cct_cd VARCHAR2(40) NOT NULL, credit_card_number VARCHAR2(40) NOT NULL, expiry_date DATE NOT NULL);

COMMENT ON TABLE demo_per_credit_cards IS q'#Person's credit cards#';
COMMENT ON COLUMN demo_per_credit_cards.per_id IS 'Person id';
COMMENT ON COLUMN demo_per_credit_cards.credit_card_number IS 'Credit card number';
COMMENT ON COLUMN demo_per_credit_cards.expiry_date IS 'Credit card expiry date';

CREATE UNIQUE INDEX demo_pcc_pk ON demo_per_credit_cards (per_id, credit_card_number);

ALTER TABLE demo_per_credit_cards ADD (
   CONSTRAINT demo_pcc_pk PRIMARY KEY (per_id, credit_card_number) USING INDEX
);

ALTER TABLE demo_per_credit_cards ADD (
   CONSTRAINT demo_pcc_per_fk FOREIGN KEY (per_id)
   REFERENCES demo_persons (per_id)
);

ALTER TABLE demo_per_credit_cards ADD (
   CONSTRAINT demo_pcc_cct_fk FOREIGN KEY (cct_cd)
   REFERENCES demo_credit_card_types (cct_cd)
);

CREATE INDEX demo_pcc_cct_fk_i ON demo_per_credit_cards (cct_cd);

REM Person's clockings

CREATE TABLE demo_per_clockings (per_id NUMBER(9) NOT NULL, clocking_date DATE NOT NULL, clocking_time VARCHAR2(8) NOT NULL, clocking_type VARCHAR2(3) NOT NULL);

COMMENT ON TABLE demo_per_clockings IS q'#Person's clockings#';
COMMENT ON COLUMN demo_per_clockings.per_id IS 'Person id';
COMMENT ON COLUMN demo_per_clockings.clocking_type IS 'Clocking type (IN/OUT)';
COMMENT ON COLUMN demo_per_clockings.clocking_date IS 'Clocking date';
COMMENT ON COLUMN demo_per_clockings.clocking_time IS 'Clocking time';

CREATE UNIQUE INDEX demo_pcl_pk ON demo_per_clockings (per_id, clocking_date, clocking_time);

ALTER TABLE demo_per_clockings ADD (
   CONSTRAINT demo_pcl_pk PRIMARY KEY (per_id, clocking_date, clocking_time) USING INDEX
);

ALTER TABLE demo_per_clockings ADD (
   CONSTRAINT demo_pcl_per_fk FOREIGN KEY (per_id)
   REFERENCES demo_persons (per_id)
);

ALTER TABLE demo_per_clockings MODIFY (
   clocking_type CONSTRAINT demo_pcl_clocking_type_ck CHECK (clocking_type IN ('IN','OUT'))
);

REM Person's assignments to organisational entities (historic table)

CREATE TABLE demo_per_assignments (per_id NUMBER(9) NOT NULL, date_from DATE NOT NULL, date_to DATE NOT NULL, oen_id NUMBER(9) NOT NULL);

COMMENT ON TABLE demo_per_assignments IS q'#Person's assignments#';
COMMENT ON COLUMN demo_per_assignments.per_id IS 'Person id';
COMMENT ON COLUMN demo_per_assignments.date_from IS 'Assigned since';
COMMENT ON COLUMN demo_per_assignments.date_to IS 'Assigned until (not included)';
COMMENT ON COLUMN demo_per_assignments.oen_id IS 'Entity id';

CREATE UNIQUE INDEX demo_pas_pk ON demo_per_assignments (per_id, date_from);

ALTER TABLE demo_per_assignments ADD (
   CONSTRAINT demo_pas_pk PRIMARY KEY (per_id, date_from) USING INDEX
);

ALTER TABLE demo_per_assignments ADD (
   CONSTRAINT demo_pas_per_fk FOREIGN KEY (per_id)
   REFERENCES demo_persons (per_id)
);

ALTER TABLE demo_per_assignments ADD (
   CONSTRAINT demo_pas_oen_fk FOREIGN KEY (oen_id)
   REFERENCES demo_org_entities (oen_id)
);

CREATE INDEX demo_pas_oen_fk_i ON demo_per_assignments (oen_id);

REM Stores

CREATE TABLE demo_stores (sto_id NUMBER(9) NOT NULL, store_name VARCHAR2(100) NOT NULL);

COMMENT ON TABLE demo_stores IS 'Stores';
COMMENT ON COLUMN demo_stores.sto_id IS 'Store id';
COMMENT ON COLUMN demo_stores.store_name IS 'Store name';

CREATE SEQUENCE demo_sto_seq;

CREATE UNIQUE INDEX demo_sto_pk ON demo_stores (sto_id);

ALTER TABLE demo_stores ADD (
   CONSTRAINT demo_sto_pk PRIMARY KEY (sto_id) USING INDEX
);

REM Orders

CREATE TABLE demo_orders (ord_id NUMBER(9) NOT NULL, per_id NUMBER(9) NOT NULL, sto_id NUMBER(9) NOT NULL, order_date DATE NOT NULL, total_price NUMBER(9) NOT NULL);

COMMENT ON TABLE demo_orders IS 'Orders';
COMMENT ON COLUMN demo_orders.ord_id IS 'Order id';
COMMENT ON COLUMN demo_orders.order_date IS 'Order date';
COMMENT ON COLUMN demo_orders.total_price IS 'Total price';

CREATE SEQUENCE demo_ord_seq;

CREATE UNIQUE INDEX demo_ord_pk ON demo_orders (ord_id);

ALTER TABLE demo_orders ADD (
   CONSTRAINT demo_ord_pk PRIMARY KEY (ord_id) USING INDEX
);

ALTER TABLE demo_orders ADD (
   CONSTRAINT demo_ord_per_fk FOREIGN KEY (per_id)
   REFERENCES demo_persons (per_id)
);

CREATE INDEX demo_ord_per_fk_i ON demo_orders (per_id);

ALTER TABLE demo_orders ADD (
   CONSTRAINT demo_ord_sto_fk FOREIGN KEY (sto_id)
   REFERENCES demo_stores (sto_id)
);

CREATE INDEX demo_ord_sto_fk_i ON demo_orders (sto_id);

REM Products

CREATE TABLE demo_products (prd_id NUMBER(9) NOT NULL, product_name VARCHAR2(100) NOT NULL, unit_price NUMBER(9) NULL
--, descr CLOB NULL
);

COMMENT ON TABLE demo_products IS 'Products';
COMMENT ON COLUMN demo_products.prd_id IS 'Product id';
COMMENT ON COLUMN demo_products.product_name IS 'Product name';
COMMENT ON COLUMN demo_products.unit_price IS 'Unit price';

CREATE SEQUENCE demo_prd_seq;

CREATE UNIQUE INDEX demo_prd_pk ON demo_products (prd_id);

ALTER TABLE demo_products ADD (
   CONSTRAINT demo_prd_pk PRIMARY KEY (prd_id) USING INDEX
);

REM Order items

CREATE TABLE demo_order_items (ord_id NUMBER(9) NOT NULL, order_line NUMBER(3) NOT NULL, prd_id NUMBER(9) NOT NULL, quantity NUMBER(9) NOT NULL, price NUMBER(9) NOT NULL);

COMMENT ON TABLE demo_order_items IS 'Order items';
COMMENT ON COLUMN demo_order_items.ord_id IS 'Order id';
COMMENT ON COLUMN demo_order_items.order_line IS 'Order line';
COMMENT ON COLUMN demo_order_items.prd_id IS 'Product id';
COMMENT ON COLUMN demo_order_items.quantity IS 'Quantity';
COMMENT ON COLUMN demo_order_items.price IS 'Price';

CREATE UNIQUE INDEX demo_oit_pk ON demo_order_items (ord_id, order_line);

ALTER TABLE demo_order_items ADD (
   CONSTRAINT demo_oit_pk PRIMARY KEY (ord_id, order_line) USING INDEX
);

ALTER TABLE demo_order_items ADD (
   CONSTRAINT demo_oit_ord_fk FOREIGN KEY (ord_id)
   REFERENCES demo_orders (ord_id)
);

ALTER TABLE demo_order_items ADD (
   CONSTRAINT demo_oit_prd_fk FOREIGN KEY (prd_id)
   REFERENCES demo_products (prd_id)
);

CREATE INDEX demo_oit_prd_fk_i ON demo_order_items (prd_id);

REM Person's transactions with credit cards

CREATE TABLE demo_per_transactions (per_id NUMBER(9) NOT NULL, ord_id NUMBER(9) NOT NULL, credit_card_nbr VARCHAR2(40) NOT NULL, transaction_timestamp TIMESTAMP NOT NULL, transaction_amount NUMBER NOT NULL);

COMMENT ON TABLE demo_per_transactions IS q'#Person's credit card transactions#';
COMMENT ON COLUMN demo_per_transactions.per_id IS 'Person id';
COMMENT ON COLUMN demo_per_transactions.ord_id IS 'Order id';
COMMENT ON COLUMN demo_per_transactions.credit_card_nbr IS 'Credit card number';
COMMENT ON COLUMN demo_per_transactions.transaction_timestamp IS 'Transaction date and time';
COMMENT ON COLUMN demo_per_transactions.transaction_amount IS 'Transaction amount in euro';

CREATE UNIQUE INDEX demo_ptr_pk ON demo_per_transactions (per_id, credit_card_nbr, transaction_timestamp);

ALTER TABLE demo_per_transactions ADD (
   CONSTRAINT demo_ptr_pk PRIMARY KEY (per_id, credit_card_nbr, transaction_timestamp) USING INDEX
);

ALTER TABLE demo_per_transactions ADD (
   CONSTRAINT demo_ptr_pcc_fk FOREIGN KEY (per_id, credit_card_nbr)
   REFERENCES demo_per_credit_cards (per_id, credit_card_number)
);

ALTER TABLE demo_per_transactions ADD (
   CONSTRAINT demo_ptr_ord_fk FOREIGN KEY (ord_id)
   REFERENCES demo_orders (ord_id)
);

CREATE INDEX demo_ptr_ord_fk_i ON demo_per_transactions (ord_id);

REM Other table

CREATE TABLE demo_dual (dummy VARCHAR2(1) NULL);

COMMENT ON TABLE demo_dual IS q'#Dummy isolated table#';
COMMENT ON COLUMN demo_dual.dummy IS 'Dummy column';

CREATE UNIQUE INDEX demo_dual_pk ON demo_dual (dummy);

ALTER TABLE demo_dual ADD (
   CONSTRAINT demo_dual_pk PRIMARY KEY (dummy) USING INDEX
);

REM Truncate generated tables (in the right order)

TRUNCATE TABLE demo_per_clockings;
TRUNCATE TABLE demo_per_transactions;
TRUNCATE TABLE demo_per_credit_cards;
TRUNCATE TABLE demo_per_assignments;
TRUNCATE TABLE demo_org_entities;
TRUNCATE TABLE demo_order_items;
TRUNCATE TABLE demo_orders;
TRUNCATE TABLE demo_persons;
TRUNCATE TABLE demo_stores;
TRUNCATE TABLE demo_products;

REM Truncate reference tables (populated via this script)

TRUNCATE TABLE demo_org_entity_types;
TRUNCATE TABLE demo_countries;
TRUNCATE TABLE demo_credit_card_types;
TRUNCATE TABLE demo_dual;

REM Populate entity types

INSERT INTO demo_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('INST', 'Institution', 1);
INSERT INTO demo_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('DG', 'Directorate General', 2);
INSERT INTO demo_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('DIR', 'Directorate', 3);
INSERT INTO demo_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('UNIT', 'Unit', 4);
INSERT INTO demo_org_entity_types (oet_cd, oet_name, oet_level) VALUES ('SECT', 'Sector', 5);
COMMIT;

REM Populate countries (from view created over EU_COUNTRIES_27 data set)
--exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('EU_COUNTRIES_27'),p_set_type=>'CSV',p_view_prefix=>'DS_',p_view_suffix=>'_V');
--INSERT INTO demo_countries (cnt_cd, cnt_name, population) select  code_a3, name, population;

INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('AUT', 'Austria', 9104772);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('BEL', 'Belgium', 11754004);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('BGR', 'Bulgaria', 6447710);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('HRV', 'Croatia', 3850894);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('CYP', 'Cyprus', 920701);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('CZE', 'Czechia', 10827529);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('DNK', 'Denmark', 5932654);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('EST', 'Estonia', 1365884);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('FIN', 'Finland', 5563970);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('FRA', 'France', 68070697);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('DEU', 'Germany', 84358845);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('GRC', 'Greece', 10394055);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('HUN', 'Hungary', 9597085);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('IRL', 'Ireland', 5194336);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('ITA', 'Italy', 58850717);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('LVA', 'Latvia', 1883008);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('LTU', 'Lithuania', 2857279);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('LUX', 'Luxembourg', 660809);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('MLT', 'Malta', 542051);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('NLD', 'Netherlands (the)', 17811291);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('POL', 'Poland', 36753736);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('PRT', 'Portugal', 10467366);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('ROU', 'Romania', 19051562);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('SVK', 'Slovakia', 5428792);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('SVN', 'Slovenia', 2116792);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('ESP', 'Spain', 48059777);
INSERT INTO demo_countries (cnt_cd, cnt_name, population) VALUES ('SWE', 'Sweden', 10521556);

REM Populate credit card types (credit card number prefixes)

INSERT INTO demo_credit_card_types (cct_cd, cct_name) VALUES ('3','American Express');
INSERT INTO demo_credit_card_types (cct_cd, cct_name) VALUES ('4','Visa');
INSERT INTO demo_credit_card_types (cct_cd, cct_name) VALUES ('5','Mastercard');
INSERT INTO demo_credit_card_types (cct_cd, cct_name) VALUES ('6011','Discover');
COMMIT;

REM Dual
INSERT INTO demo_dual (dummy) VALUES ('X');
COMMIT;

REM Create demo views

@@12_demo_views.sql

@@18_demo_src_tables_stats.sql