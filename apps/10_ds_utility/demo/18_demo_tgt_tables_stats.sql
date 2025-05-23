REM 
REM Data Set Utility Demo
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script to count records in the target demo tables
set pagesize 20
PROMPT Statistics on demo tables in target schema
--SELECT CASE WHEN rownum>1 THEN 'UNION ALL 'END || 'SELECT '''|| table_name ||''' tgt_table_name, COUNT(*) cnt FROM ' ||table_name||'@DBCC_DIGIT_01_A.CC.CEC.EU.INT'
--FROM (SELECT * FROM user_tables WHERE table_name LIKE 'DEMO%' AND table_name != 'DEMO_DUAL' ORDER BY table_name)
--UNION ALL SELECT 'ORDER BY 1;' FROM dual;
SELECT 'DEMO_COUNTRIES' tgt_table_name, COUNT(*) cnt FROM DEMO_COUNTRIES@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_CREDIT_CARD_TYPES' tgt_table_name, COUNT(*) cnt FROM DEMO_CREDIT_CARD_TYPES@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_ORDERS' tgt_table_name, COUNT(*) cnt FROM DEMO_ORDERS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_ORDER_ITEMS' tgt_table_name, COUNT(*) cnt FROM DEMO_ORDER_ITEMS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_ORG_ENTITIES' tgt_table_name, COUNT(*) cnt FROM DEMO_ORG_ENTITIES@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_ORG_ENTITY_TYPES' tgt_table_name, COUNT(*) cnt FROM DEMO_ORG_ENTITY_TYPES@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PERSONS' tgt_table_name, COUNT(*) cnt FROM DEMO_PERSONS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PER_ASSIGNMENTS' tgt_table_name, COUNT(*) cnt FROM DEMO_PER_ASSIGNMENTS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PER_CLOCKINGS' tgt_table_name, COUNT(*) cnt FROM DEMO_PER_CLOCKINGS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PER_CREDIT_CARDS' tgt_table_name, COUNT(*) cnt FROM DEMO_PER_CREDIT_CARDS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PER_TRANSACTIONS' tgt_table_name, COUNT(*) cnt FROM DEMO_PER_TRANSACTIONS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_PRODUCTS' tgt_table_name, COUNT(*) cnt FROM DEMO_PRODUCTS@DBCC_DIGIT_01_A.CC.CEC.EU.INT
UNION ALL SELECT 'DEMO_STORES' tgt_table_name, COUNT(*) cnt FROM DEMO_STORES@DBCC_DIGIT_01_A.CC.CEC.EU.INT
ORDER BY 1;