REM 
REM Data Set Utility Demo - Grant read/write access to demo data model
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 
REM Drop tables (in the right order)
REM Drop all objects created by a previous run, if any

REM Drop sequences
DECLARE
   TYPE t_obj_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_obj t_obj_type;
BEGIN
   t_obj(t_obj.COUNT+1) := 'demo_oen_seq';
   t_obj(t_obj.COUNT+1) := 'demo_per_seq';
   t_obj(t_obj.COUNT+1) := 'demo_prd_seq';
   t_obj(t_obj.COUNT+1) := 'demo_ord_seq';
   t_obj(t_obj.COUNT+1) := 'demo_sto_seq';
   FOR i IN 1..t_obj.COUNT LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP SEQUENCE '||t_obj(i);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;
END;
/

REM Drop tables
DECLARE
   TYPE t_obj_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_obj t_obj_type;
BEGIN
   t_obj(t_obj.COUNT+1) := 'demo_per_clockings';
   t_obj(t_obj.COUNT+1) := 'demo_per_transactions';
   t_obj(t_obj.COUNT+1) := 'demo_per_credit_cards';
   t_obj(t_obj.COUNT+1) := 'demo_per_assignments';
   t_obj(t_obj.COUNT+1) := 'demo_org_entities';
   t_obj(t_obj.COUNT+1) := 'demo_order_items';
   t_obj(t_obj.COUNT+1) := 'demo_orders';
   t_obj(t_obj.COUNT+1) := 'demo_persons';
   t_obj(t_obj.COUNT+1) := 'demo_stores';
   t_obj(t_obj.COUNT+1) := 'demo_products';
   t_obj(t_obj.COUNT+1) := 'demo_org_entity_types';
   t_obj(t_obj.COUNT+1) := 'demo_credit_card_types';
   t_obj(t_obj.COUNT+1) := 'demo_countries';
   t_obj(t_obj.COUNT+1) := 'demo_dual';
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
   t_obj(t_obj.COUNT+1) := 'demo_random_date_history';
   t_obj(t_obj.COUNT+1) := 'demo_random_time_clockings';
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
