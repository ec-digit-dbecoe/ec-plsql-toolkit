PROMPT Populating table QC_APPS...
INSERT INTO qc_apps (
   app_alias
) VALUES (
   'ALL'
);

PROMPT Registering quality checks...
INSERT INTO qc_checks (
   qc_code, descr, msg_type
)
WITH qc AS (
   -- Exact info from code: -- QC000: bla bla bla E
   SELECT TRIM(REPLACE(REPLACE(text,'-- '),CHR(10))) text
     FROM user_source
    WHERE TYPE='PACKAGE BODY' AND NAME='QC_UTILITY_KRN' AND text LIKE '%-- QC0%'
)
SELECT SUBSTR(qc.text,1,5) /*code*/, TRIM(SUBSTR(qc.text,8,length(qc.text)-8)) /*descr*/, SUBSTR(qc.text,-1,1) /*E|W|I*/
  FROM qc
  LEFT OUTER JOIN qc_checks chk
    ON chk.qc_code = SUBSTR(qc.text,1,5)
 WHERE chk.qc_code IS NULL
 ORDER BY 1
;

PROMPT Registering plural words in dictionary...
DECLARE
   TYPE my_varchar2_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_key my_varchar2_table;
   r_dict qc_dictionary_entries%ROWTYPE;
BEGIN
   t_key(t_key.COUNT+1) := 'DATA';
   t_key(t_key.COUNT+1) := 'INFO';
   t_key(t_key.COUNT+1) := 'INFORMATION';
   t_key(t_key.COUNT+1) := 'STAFF';
   t_key(t_key.COUNT+1) := 'CRITERIA';
   r_dict.app_alias := 'ALL';
   r_dict.dict_name := 'PLURAL WORD';
   FOR i IN 1..t_key.COUNT LOOP
      r_dict.dict_key := t_key(i);
      r_dict.dict_value := t_key(i);
      INSERT INTO qc_dictionary_entries VALUES r_dict;
   END LOOP;
END;
/

PROMPT Registering reserved words in dictionary...
INSERT INTO qc_dictionary_entries (
   app_alias, dict_name, dict_key, dict_value
)
SELECT 'ALL', 'RESERVED WORD', keyword, keyword
  FROM v$reserved_words
 WHERE reserved = 'Y'
   AND length > 1
;
COMMIT
;
