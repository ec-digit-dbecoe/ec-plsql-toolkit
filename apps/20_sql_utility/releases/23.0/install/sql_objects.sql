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
   owner VARCHAR2(30)
 , table_name VARCHAR2(30)
 , column_name VARCHAR2(30)
)
TABLESPACE &&tab_ts
;

CREATE INDEX satcd_idx_1 ON sys_all_table_descriptors(owner, table_name, column_name)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_constraint_descriptors (
   owner VARCHAR2(30)
 , table_name VARCHAR2(30)
 , constraint_name VARCHAR2(30)
 , select_statement VARCHAR(4000)
)
TABLESPACE &&tab_ts
;

CREATE INDEX sacd_idx_1 ON sys_all_constraint_descriptors(owner, table_name, constraint_name)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_object_comments (
   owner VARCHAR2(30)
 , object_type VARCHAR2(30)
 , object_name VARCHAR2(61)
 , language_code VARCHAR2(3)
 , object_comment VARCHAR2(4000)
)
TABLESPACE &&tab_ts
;

CREATE INDEX saoc_idx_1 ON sys_all_object_comments(owner, object_type, object_name, language_code, object_comment)
TABLESPACE &&idx_ts
;

CREATE TABLE sys_all_sequences (
   owner VARCHAR2(30)
 , sequence_name VARCHAR2(30)
 , table_name VARCHAR2(30)
 , column_name VARCHAR2(30)
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
