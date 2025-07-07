REM 
REM Data Set Utility Demo
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script to count records in the target demo tables
set pagesize 20
PROMPT Statistics on demo tables in target schema (defined via target variable)
          SELECT 'DEMO_COUNTRIES' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_COUNTRIES
UNION ALL SELECT 'DEMO_CREDIT_CARD_TYPES' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_CREDIT_CARD_TYPES
UNION ALL SELECT 'DEMO_ORDERS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_ORDERS
UNION ALL SELECT 'DEMO_ORDER_ITEMS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_ORDER_ITEMS
UNION ALL SELECT 'DEMO_ORG_ENTITIES' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_ORG_ENTITIES
UNION ALL SELECT 'DEMO_ORG_ENTITY_TYPES' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_ORG_ENTITY_TYPES
UNION ALL SELECT 'DEMO_PERSONS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PERSONS
UNION ALL SELECT 'DEMO_PER_ASSIGNMENTS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PER_ASSIGNMENTS
UNION ALL SELECT 'DEMO_PER_CLOCKINGS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PER_CLOCKINGS
UNION ALL SELECT 'DEMO_PER_CREDIT_CARDS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PER_CREDIT_CARDS
UNION ALL SELECT 'DEMO_PER_TRANSACTIONS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PER_TRANSACTIONS
UNION ALL SELECT 'DEMO_PRODUCTS' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_PRODUCTS
UNION ALL SELECT 'DEMO_STORES' tgt_table_name, COUNT(*) cnt FROM &&target..DEMO_STORES
ORDER BY 1;