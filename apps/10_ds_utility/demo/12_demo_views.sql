REM 
REM Data Set Utility Demo - Data Model Creation
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM Script to create CSV data set and data generation views
REM 

REM Create view to populate demo_countries
exec ds_utility_krn.create_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('EU_COUNTRIES_27'),p_set_type=>'CSV',p_view_prefix=>'DS_',p_view_suffix=>'_V');
--INSERT INTO demo_countries (cnt_cd, cnt_name, population) select  code_a3, name, population;

REM Create view to generate random date intervals (for historic tables)

CREATE OR REPLACE VIEW demo_random_date_history AS
SELECT *
FROM (
SELECT row#, date_from, lead(date_from,1,TO_DATE('31129999','DDMMYYYY')) OVER (ORDER BY date_from) AS date_to, duration months FROM (
SELECT row#, add_months(TO_DATE('01012000','DDMMYYYY'),SUM(duration) OVER (ORDER BY row# ROWS UNBOUNDED PRECEDING)) date_from, duration FROM (
SELECT row#, ds_masker_krn.random_integer(1,12) duration
  FROM (SELECT LEVEL row# FROM sys.dual CONNECT BY LEVEL<=ds_masker_krn.random_integer(3,5))
)))
;

REM Check
--SELECT * FROM demo_random_date_history;

REM Create view to generate random time clockings (IN/OUT, 4 per working day) for 5 weeks before today

CREATE OR REPLACE VIEW demo_random_time_clockings AS
SELECT rownum row#, thedate, thetime, thetype FROM (
SELECT thedate, thetime, thetype
  FROM sys.dual
 INNER JOIN (SELECT row#, TRUNC(SYSDATE)+row#-35-1 thedate FROM (SELECT LEVEL row# FROM sys.dual CONNECT BY LEVEL<=35) WHERE TO_CHAR(SYSDATE+row#-50,'DY') NOT IN ('SAT','SUN')) ON 1=1
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
--SELECT * FROM demo_random_time_clockings order by row# desc;
