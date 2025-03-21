REM 
REM Data Set Utility Demo
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script to count extracted records using ad-hoc views
set pagesize 20
PROMPT Statistics on demo views
--SELECT CASE WHEN rownum>1 THEN 'UNION ALL 'END || 'SELECT '''|| table_name ||''' view_name, COUNT(*) extract_cnt FROM ' ||table_name||'_V'
--FROM (SELECT * FROM user_tables WHERE table_name LIKE 'DEMO%' AND table_name != 'DEMO_DUAL' ORDER BY table_name)
--UNION ALL SELECT 'ORDER BY 1;' FROM dual;
SELECT 'DEMO_COUNTRIES_V' view_name, COUNT(*) extract_cnt FROM DEMO_COUNTRIES_V
UNION ALL SELECT 'DEMO_CREDIT_CARD_TYPES_V' view_name, COUNT(*) extract_cnt FROM DEMO_CREDIT_CARD_TYPES_V
UNION ALL SELECT 'DEMO_ORDERS_V' view_name, COUNT(*) extract_cnt FROM DEMO_ORDERS_V
UNION ALL SELECT 'DEMO_ORDER_ITEMS_V' view_name, COUNT(*) extract_cnt FROM DEMO_ORDER_ITEMS_V
UNION ALL SELECT 'DEMO_ORG_ENTITIES_V' view_name, COUNT(*) extract_cnt FROM DEMO_ORG_ENTITIES_V
UNION ALL SELECT 'DEMO_ORG_ENTITY_TYPES_V' view_name, COUNT(*) extract_cnt FROM DEMO_ORG_ENTITY_TYPES_V
UNION ALL SELECT 'DEMO_PERSONS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PERSONS_V
UNION ALL SELECT 'DEMO_PER_ASSIGNMENTS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PER_ASSIGNMENTS_V
UNION ALL SELECT 'DEMO_PER_CLOCKINGS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PER_CLOCKINGS_V
UNION ALL SELECT 'DEMO_PER_CREDIT_CARDS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PER_CREDIT_CARDS_V
UNION ALL SELECT 'DEMO_PER_TRANSACTIONS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PER_TRANSACTIONS_V
UNION ALL SELECT 'DEMO_PRODUCTS_V' view_name, COUNT(*) extract_cnt FROM DEMO_PRODUCTS_V
UNION ALL SELECT 'DEMO_STORES_V' view_name, COUNT(*) extract_cnt FROM DEMO_STORES_V
ORDER BY 1;