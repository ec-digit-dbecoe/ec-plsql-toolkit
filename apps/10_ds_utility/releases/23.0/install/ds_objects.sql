REM 
REM Create all DS objects
REM 

PROMPT Creating ds_data_sets table...
CREATE TABLE ds_data_sets (
   set_id NUMBER(9) NOT NULL
  ,set_name VARCHAR2(80) NOT NULL
  ,visible_flag VARCHAR2(1) NOT NULL CHECK (visible_flag IN ('Y','N'))
  ,capture_flag VARCHAR2(1) NULL CHECK (capture_flag IN (NULL,'Y','N'))
  ,capture_mode VARCHAR2(10) NULL
  ,capture_user VARCHAR2(30) NULL
  ,capture_seq  INTEGER NULL
  ,user_created VARCHAR2(30) NOT NULL
  ,date_created DATE NOT NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_data_sets IS 'Data sets';
COMMENT ON COLUMN ds_data_sets.set_id IS 'Data set unique id';
COMMENT ON COLUMN ds_data_sets.set_name IS 'Data set name';
COMMENT ON COLUMN ds_data_sets.visible_flag IS 'Visible by views and policies? (Y/N)';
COMMENT ON COLUMN ds_data_sets.capture_flag IS 'Trigger capture enabled? (Y/N)';
COMMENT ON COLUMN ds_data_sets.capture_mode IS 'Trigger capture mode (XML|EXP)';
COMMENT ON COLUMN ds_data_sets.capture_user IS 'Limit capture to this user (NULL means all)';
COMMENT ON COLUMN ds_data_sets.capture_seq IS 'Capture sequence';
COMMENT ON COLUMN ds_data_sets.user_created IS 'Audit: created by';
COMMENT ON COLUMN ds_data_sets.date_created IS 'Audit: creation date';

CREATE UNIQUE INDEX ds_set_pk ON ds_data_sets (set_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_data_sets ADD (
   CONSTRAINT ds_set_pk PRIMARY KEY (set_id) USING INDEX
);

CREATE UNIQUE INDEX ds_set_uk ON ds_data_sets (set_name)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_data_sets ADD (
   CONSTRAINT ds_set_uk UNIQUE (set_name) USING INDEX
);

CREATE SEQUENCE ds_set_seq;

PROMPT Creating ds_tables table...
CREATE TABLE ds_tables (
   table_id NUMBER(9) NOT NULL
  ,set_id NUMBER(9) NOT NULL
  ,table_name VARCHAR2(30) NOT NULL
  ,table_alias VARCHAR2(30) NULL
  ,extract_type VARCHAR2(1) NOT NULL CHECK (extract_type IN ('B','F','P','N'))
  ,row_limit INTEGER NULL CHECK (row_limit IS NULL OR row_limit >= 0)
  ,percentage NUMBER(4,1) NULL CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
  ,source_count INTEGER NULL
  ,extract_count INTEGER NULL
  ,pass_count INTEGER NULL
  ,group_count INTEGER NULL
  ,seq INTEGER NULL
  ,where_clause VARCHAR2(4000) NULL
  ,order_by_clause VARCHAR2(4000) NULL
  ,columns_list VARCHAR2(4000) NULL
  ,export_mode VARCHAR2(3) NULL
  ,table_data CLOB NULL
  ,source_schema VARCHAR2(30) NULL
  ,source_db_link VARCHAR2(30) NULL
  ,target_schema VARCHAR2(30) NULL
  ,target_db_link VARCHAR2(30) NULL
  ,target_table_name VARCHAR2(30) NULL
  ,user_column_name VARCHAR2(30) NULL
  ,sequence_name VARCHAR2(30) NULL
  ,id_shift_value NUMBER NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_tables IS 'Data set tables';
COMMENT ON COLUMN ds_tables.table_id IS 'Table unique id';
COMMENT ON COLUMN ds_tables.set_id IS 'Id of data set to which table belongs';
COMMENT ON COLUMN ds_tables.table_name IS 'Table name';
COMMENT ON COLUMN ds_tables.table_alias IS 'Table alias - used in queries';
COMMENT ON COLUMN ds_tables.extract_type IS 'Extract type (B=Base, F=Full, P=Partial, N=None)';
COMMENT ON COLUMN ds_tables.row_limit IS 'Maximum number of rows to extract';
COMMENT ON COLUMN ds_tables.percentage IS 'Percentage of rows to extract';
COMMENT ON COLUMN ds_tables.source_count IS 'Number of rows in source table';
COMMENT ON COLUMN ds_tables.extract_count IS 'Number of rows extracted';
COMMENT ON COLUMN ds_tables.pass_count IS 'Pass number - for internal use';
COMMENT ON COLUMN ds_tables.seq IS 'Sequence - for internal use';
COMMENT ON COLUMN ds_tables.group_count IS 'Number of record groups - for internal use';
COMMENT ON COLUMN ds_tables.where_clause IS 'Table filter';
COMMENT ON COLUMN ds_tables.order_by_clause IS 'Order used for sorting rows';
COMMENT ON COLUMN ds_tables.columns_list IS 'List of columns to extract (extended syntax!)';
COMMENT ON COLUMN ds_tables.export_mode IS 'Export mode (I=Insert, U=Update, M|UI=Upsert)';
COMMENT ON COLUMN ds_tables.table_data IS 'XML extract of the table in case of full extract';
COMMENT ON COLUMN ds_tables.source_schema IS 'Schema in which the source table is stored';
COMMENT ON COLUMN ds_tables.source_db_link IS 'Database link used to access source table';
COMMENT ON COLUMN ds_tables.target_schema IS 'Schema in which the target table is stored';
COMMENT ON COLUMN ds_tables.target_db_link IS 'Database link used to access target table';
COMMENT ON COLUMN ds_tables.target_table_name IS 'Name of the target table (if different from source table)';
COMMENT ON COLUMN ds_tables.user_column_name IS 'Name of the audit column used to determine current user';
COMMENT ON COLUMN ds_tables.sequence_name IS 'Name of the sequence used to generate unique id';
COMMENT ON COLUMN ds_tables.id_shift_value IS 'Value by which unique id must be shifted';

CREATE UNIQUE INDEX ds_tab_pk ON ds_tables (table_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_pk PRIMARY KEY (table_id) USING INDEX
);

CREATE UNIQUE INDEX ds_tab_uk ON ds_tables (set_id, table_name)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_uk UNIQUE (set_id, table_name) USING INDEX
);

ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_set_fk FOREIGN KEY (set_id)
   REFERENCES ds_data_sets (set_id)
);

CREATE INDEX ds_tab_set_fk_i ON ds_tables (set_id)
TABLESPACE &&idx_ts
;

CREATE SEQUENCE ds_tab_seq;

PROMPT Creating ds_constraints table...
CREATE TABLE ds_constraints (
   con_id NUMBER(9) NOT NULL
  ,set_id NUMBER(9) NOT NULL
  ,constraint_name VARCHAR2(30) NOT NULL
  ,src_table_name VARCHAR2(30) NOT NULL
  ,dst_table_name VARCHAR2(30) NOT NULL
  ,CARDINALITY VARCHAR2(3) NOT NULL CHECK (CARDINALITY IN ('1-N','N-1'))
  ,extract_type VARCHAR2(1) NOT NULL CHECK (extract_type IN ('B','P','N')) 
  ,DEFERRED VARCHAR2(9) NOT NULL CHECK (DEFERRED IN ('IMMEDIATE','DEFERRED'))
  ,percentage NUMBER(4,1) NULL CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
  ,row_limit INTEGER NULL CHECK (row_limit IS NULL OR row_limit >= 0)
  ,source_count INTEGER NULL
  ,extract_count INTEGER NULL
  ,where_clause VARCHAR2(4000) NULL
  ,order_by_clause VARCHAR2(4000) NULL
  ,join_clause VARCHAR2(4000) NULL
  ,md_cardinality_ok VARCHAR2(1) NULL
  ,md_optionality_ok VARCHAR2(1) NULL
  ,md_uid_ok VARCHAR2(1) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_constraints IS 'Data set constraints';
COMMENT ON COLUMN ds_constraints.con_id IS 'Constraint unique id';
COMMENT ON COLUMN ds_constraints.set_id IS 'Id of data set to which constraint belongs';
COMMENT ON COLUMN ds_constraints.constraint_name IS 'Name of the constraint';
COMMENT ON COLUMN ds_constraints.src_table_name IS 'Name of the source table';
COMMENT ON COLUMN ds_constraints.dst_table_name IS 'Name of the destination table';
COMMENT ON COLUMN ds_constraints.CARDINALITY IS 'Constraint cardinality (1-N,N-1)';
COMMENT ON COLUMN ds_constraints.extract_type IS 'Extraction type (B=Base, P=Partial, N=None)';
COMMENT ON COLUMN ds_constraints.DEFERRED IS 'Deferreable (IMMEDIATE,DEFERRED)';
COMMENT ON COLUMN ds_constraints.percentage IS 'Percentage of rows to extract (by parent)';
COMMENT ON COLUMN ds_constraints.row_limit IS 'Maximum number of rows to extract (by parent)';
COMMENT ON COLUMN ds_constraints.source_count IS 'Number of rows in source tables';
COMMENT ON COLUMN ds_constraints.extract_count IS 'Number of rows extracted via this constraint';
COMMENT ON COLUMN ds_constraints.where_clause IS 'Filter applied when following this constraint';
COMMENT ON COLUMN ds_constraints.order_by_clause IS 'Order used for sorting rows (of same parent)';
COMMENT ON COLUMN ds_constraints.join_clause IS 'Join clause - for internal use';
COMMENT ON COLUMN ds_constraints.md_cardinality_ok IS 'Master/detail: is #rows(detail) > #rows(master)? (Y/N)';
COMMENT ON COLUMN ds_constraints.md_optionality_ok IS 'Master/detail: is the fk mandatory? (Y/N)';
COMMENT ON COLUMN ds_constraints.md_uid_ok IS 'Master/detail: does the pk/uk(detail) contains the fk? (Y/N)';

CREATE UNIQUE INDEX ds_con_pk ON ds_constraints(con_id)
TABLESPACE &&idx_ts
;

CREATE UNIQUE INDEX ds_con_uk ON ds_constraints(set_id, constraint_name, CARDINALITY)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_pk PRIMARY KEY (con_id) USING INDEX
);

ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_uk UNIQUE (set_id, constraint_name, CARDINALITY) USING INDEX
);

ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_set_fk FOREIGN KEY (set_id)
   REFERENCES ds_data_sets (set_id)
);

ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_tab_dst_fk FOREIGN KEY (set_id, dst_table_name)
   REFERENCES ds_tables (set_id, table_name)
);

ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_tab_src_fk FOREIGN KEY (set_id, src_table_name)
   REFERENCES ds_tables (set_id, table_name)
);

CREATE INDEX ds_con_set_fk_i ON ds_constraints(set_id)
TABLESPACE &&idx_ts
;

CREATE INDEX ds_con_tab_src_fk_i ON ds_constraints(set_id, src_table_name)
TABLESPACE &&idx_ts
;

CREATE INDEX ds_con_tab_dst_fk_i ON ds_constraints(set_id, dst_table_name)
TABLESPACE &&idx_ts
;

CREATE SEQUENCE ds_con_seq;

CREATE SEQUENCE ds_rec_seq;

PROMPT Creating ds_records table...
CREATE TABLE ds_records (
   rec_id NUMBER DEFAULT ds_rec_seq.nextval NOT NULL
  ,table_id NUMBER(9) NOT NULL
  ,con_id NUMBER(9) NULL
  ,record_rowid VARCHAR2(50) NULL
  ,source_rowid VARCHAR2(50) NULL
  ,seq INTEGER NULL
  ,pass_count INTEGER NULL
  ,user_name VARCHAR2(30) NULL
  ,undo_timestamp TIMESTAMP NULL
  ,operation VARCHAR2(1) NULL -- I)nsert, U)pdate, D)elete
  ,remark VARCHAR2(200) NULL
  ,deleted_flag VARCHAR2(1) NULL
  ,record_data CLOB NULL
  ,record_data_old CLOB NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_records IS 'Data set records';
COMMENT ON COLUMN ds_records.rec_id IS 'Unique identifier of record';
COMMENT ON COLUMN ds_records.table_id IS 'Id of table to which record belongs';
COMMENT ON COLUMN ds_records.con_id IS 'Id of constraint used to extract this record';
COMMENT ON COLUMN ds_records.record_rowid IS 'Rowid of record';
COMMENT ON COLUMN ds_records.source_rowid IS 'Rowid of source record';
COMMENT ON COLUMN ds_records.seq IS 'Sequence';
COMMENT ON COLUMN ds_records.user_name IS 'Name of user who did the operation';
COMMENT ON COLUMN ds_records.undo_timestamp IS 'Date/time the operation was undone';
COMMENT ON COLUMN ds_records.pass_count IS 'Pass number - for internal use';
COMMENT ON COLUMN ds_records.operation IS 'Operation (I=Insert, U=Update, D=Delete)';
COMMENT ON COLUMN ds_records.remark IS 'Comment';
COMMENT ON COLUMN ds_records.deleted_flag IS 'Logically deleted (Y/N)';
COMMENT ON COLUMN ds_records.record_data IS 'XML extract of the record';
COMMENT ON COLUMN ds_records.record_data IS 'XML extract of the record (old values)';

CREATE INDEX ds_rec_pk ON ds_records (
   rec_id
)
TABLESPACE &&idx_ts
;

CREATE INDEX ds_rec_i ON ds_records (
   table_id, record_rowid, pass_count
)
TABLESPACE &&idx_ts
;

CREATE INDEX ds_rec_i2 ON ds_records (
   table_id, pass_count
)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_pk PRIMARY KEY (rec_id) USING INDEX
   TABLESPACE &&idx_ts
);

ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_tab_fk FOREIGN KEY (table_id)
   REFERENCES ds_tables (table_id)
);

ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_con_fk FOREIGN KEY (con_id)
   REFERENCES ds_constraints (con_id)
);

CREATE INDEX ds_rec_tab_fk_i ON ds_records (table_id)
TABLESPACE &&idx_ts
;

CREATE INDEX ds_rec_con_fk_i ON ds_records (con_id)
TABLESPACE &&idx_ts
;

PROMPT Creating ds_output table...
CREATE TABLE ds_output (
   line NUMBER NOT NULL
  ,text VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

CREATE UNIQUE INDEX ds_out_pk ON ds_output (line)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_output ADD (
   CONSTRAINT ds_out_pk PRIMARY KEY (line) USING INDEX
);

PROMPT Creating ds_identifiers table...
CREATE TABLE ds_identifiers (
   table_id NUMBER(9) NOT NULL
  ,old_id NUMBER NOT NULL
  ,new_id NUMBER NOT NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_identifiers IS 'Data set identifiers';
COMMENT ON COLUMN ds_identifiers.table_id IS 'Table id';
COMMENT ON COLUMN ds_identifiers.old_id IS 'Value of the identifier before relocation';
COMMENT ON COLUMN ds_identifiers.new_id IS 'Value of the identifier after relocation';

CREATE UNIQUE INDEX ds_dsi_pk ON ds_identifiers (table_id, old_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_pk PRIMARY KEY (table_id, old_id) USING INDEX
);

ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_tab_fk FOREIGN KEY (table_id)
   REFERENCES ds_tables (table_id)
);

CREATE INDEX ds_dsi_tab_fk_i ON ds_identifiers(table_id)
TABLESPACE &&idx_ts
;
