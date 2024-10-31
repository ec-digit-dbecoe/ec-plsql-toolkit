REM 
REM Drop all SYS objects
REM 

DECLARE
   CURSOR c_obj IS
      SELECT 'DROP '||object_type||' '||LOWER(object_name)
            ||DECODE(object_type,'TABLE',' CASCADE CONSTRAINTS','') ddl_stmt
        FROM user_objects
       WHERE object_type IN ('TABLE','SEQUENCE')
         AND object_name LIKE 'SYS~_%' ESCAPE '~'
      ;
BEGIN
   FOR r_obj IN c_obj LOOP
      dbms_output.put_line(r_obj.ddl_stmt||';');
      EXECUTE IMMEDIATE r_obj.ddl_stmt;      
   END LOOP;
END;
/

REM 
REM Create all SYS objects
REM 

CREATE TABLE sys_all_constraints
TABLESPACE &&tab_ts
AS
SELECT owner, table_name, constraint_type
     , constraint_name, r_constraint_name, deferred
     , last_change, 'Y' system
  FROM all_constraints
 WHERE owner = USER
;

CREATE INDEX sac_idx_1 ON sys_all_constraints(owner, table_name, constraint_type)
TABLESPACE &&idx_ts
;

CREATE INDEX sac_idx_2 ON sys_all_constraints(owner, constraint_name, table_name)
TABLESPACE &&idx_ts
;

CREATE INDEX sac_idx_3 ON sys_all_constraints(owner, r_constraint_name, table_name)
TABLESPACE &&idx_ts
;

CREATE INDEX sac_idx_4 ON sys_all_constraints(owner, constraint_type)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_cons_columns
TABLESPACE &&tab_ts
AS
SELECT owner, constraint_name, table_name
     , column_name, position, 'Y' system
  FROM all_cons_columns
 WHERE owner = USER
;

CREATE INDEX sacc_idx_1 ON sys_all_cons_columns(owner, constraint_name, table_name, column_name)
TABLESPACE &&idx_ts
;

CREATE INDEX sacc_idx_2 ON sys_all_cons_columns(owner, constraint_name, position)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_table_descriptors (
   owner VARCHAR2(30 CHAR)
 , table_name VARCHAR2(30 CHAR)
 , column_name VARCHAR2(30 CHAR)
)
TABLESPACE &&tab_ts
;

CREATE INDEX satcd_idx_1 ON sys_all_table_descriptors(owner, table_name, column_name)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_constraint_descriptors (
   owner VARCHAR2(30 CHAR)
 , table_name VARCHAR2(30 CHAR)
 , constraint_name VARCHAR2(30 CHAR)
 , select_statement VARCHAR2(4000 CHAR)
)
TABLESPACE &&tab_ts
;

CREATE INDEX sacd_idx_1 ON sys_all_constraint_descriptors(owner, table_name, constraint_name)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_object_comments (
   owner VARCHAR2(30 CHAR)
 , object_type VARCHAR2(30 CHAR)
 , object_name VARCHAR2(61 CHAR)
 , language_code VARCHAR2(3 CHAR)
 , object_comment VARCHAR2(4000 CHAR)
)
TABLESPACE &&tab_ts
;

CREATE INDEX saoc_idx_1 ON sys_all_object_comments(owner, object_type, object_name, language_code, object_comment)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_sequences (
   owner VARCHAR2(30 CHAR)
 , sequence_name VARCHAR2(30 CHAR)
 , table_name VARCHAR2(30 CHAR)
 , column_name VARCHAR2(30 CHAR)
)
TABLESPACE &&tab_ts
;

CREATE INDEX sas_idx_1 ON sys_all_sequences(owner, sequence_name, table_name, column_name)
TABLESPACE &&idx_ts
;

DECLARE
   CURSOR c_obj IS
      SELECT 'ALTER TABLE '||LOWER(table_name)||' MODIFY '||LOWER(column_name)||' NULL' ddl_stmt
        FROM user_tab_columns
       WHERE table_name LIKE 'SYS_ALL%'
         AND nullable = 'N'
       ORDER BY table_name, column_id
      ;
BEGIN
   FOR r_obj IN c_obj LOOP
      dbms_output.put_line(r_obj.ddl_stmt||';');
      EXECUTE IMMEDIATE r_obj.ddl_stmt;      
   END LOOP;
END;
/

DECLARE
   CURSOR c_col (
      p_pattern VARCHAR2
   )
   IS
      SELECT 'ALTER TABLE '||LOWER(col.table_name)||' MODIFY '||LOWER(col.column_name)||' '||col.data_type||'('||col.data_length||' CHAR)' ddl_statement
        FROM user_tab_columns col
       INNER JOIN user_tables tab
          ON tab.table_name = col.table_name
       WHERE REGEXP_LIKE(col.table_name, p_pattern)
         AND col.data_type LIKE '%CHAR%'
         AND col.char_used = 'B'
       ORDER BY col.table_name
      ;
   l_count PLS_INTEGER := 0;
BEGIN
   dbms_output.put_line('Changing length unit of char columns from BYTE to CHAR...');
   FOR r_col IN c_col('^SYS_ALL_') LOOP
      l_count := l_count + 1;
      dbms_output.put_line(r_col.ddl_statement);
      EXECUTE IMMEDIATE r_col.ddl_statement;
   END LOOP;
   dbms_output.put_line('Done: '||l_count||' column'||CASE WHEN l_count > 1 THEN 's' END||' altered');
END;
/