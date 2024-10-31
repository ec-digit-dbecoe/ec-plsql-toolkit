REM 
REM Data Set Utility Demo - Grant read/write access to demo data model
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM Script used when demo and tool tables are not in the same schema
REM 

GRANT SELECT, INSERT, UPDATE, DELETE ON demo_per_clockings TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_per_transactions TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_per_credit_cards TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_per_assignments TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_org_entities TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_order_items TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_orders TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_persons TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_stores TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_products TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_org_entity_types TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_credit_card_types TO &&grantee;
GRANT SELECT, INSERT, UPDATE, DELETE ON demo_countries TO &&grantee;
GRANT SELECT ON demo_oen_seq TO &&grantee;
GRANT SELECT ON demo_per_seq TO &&grantee;
GRANT SELECT ON demo_sto_seq TO &&grantee;
GRANT SELECT ON demo_ord_seq TO &&grantee;
GRANT SELECT ON demo_prd_seq TO &&grantee;
GRANT SELECT ON demo_random_date_history TO &&grantee;
GRANT SELECT ON demo_random_time_clockings TO &&grantee;
