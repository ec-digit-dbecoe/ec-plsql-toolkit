REM 
REM Create all DS objects
REM 

REM DBM-00100: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_DATA_SETS')
PROMPT Creating DS_DATA_SETS table...
CREATE TABLE ds_data_sets (
   set_id NUMBER(9) NOT NULL
  ,set_name VARCHAR2(80 CHAR) NOT NULL
  ,set_type VARCHAR2(10 CHAR) NOT NULL CONSTRAINT ds_set_set_type_ck CHECK (set_type IN ('SUB','SQL','CSV','JSON','XML','GEN','CAP'))
  ,system_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_set_system_flag_ck CHECK (NVL(system_flag,'Y') IN ('Y','N'))
  ,disabled_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_set_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,visible_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_set_visible_flag_ck CHECK (NVL(visible_flag,'Y') IN ('Y','N'))
  ,capture_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_set_capture_flag_ck CHECK (NVL(capture_flag,'Y') IN ('Y','N'))
  ,capture_mode VARCHAR2(10 CHAR) NULL CONSTRAINT ds_set_capture_mode_ck CHECK (NVL(capture_mode,'NONE') IN ('NONE','ASYN','SYNC'))
  ,capture_user VARCHAR2(30 CHAR) NULL
  ,capture_seq  INTEGER NULL
  ,line_sep_char VARCHAR2(2 CHAR) NULL
  ,col_sep_char VARCHAR2(1 CHAR) NULL
  ,left_sep_char VARCHAR2(1 CHAR) NULL
  ,right_sep_char VARCHAR2(1 CHAR) NULL
  ,col_names_row INTEGER NULL
  ,col_types_row INTEGER NULL
  ,data_row INTEGER NULL
  ,params CLOB NULL
  ,user_created VARCHAR2(30 CHAR) NOT NULL
  ,date_created DATE NOT NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_data_sets IS 'Data sets';
COMMENT ON COLUMN ds_data_sets.set_id IS 'Data set unique id';
COMMENT ON COLUMN ds_data_sets.set_name IS 'Data set name';
COMMENT ON COLUMN ds_data_sets.set_type IS 'Data set type';
COMMENT ON COLUMN ds_data_sets.system_flag IS 'System data set? (Y/N)';
COMMENT ON COLUMN ds_data_sets.disabled_flag IS 'Disabled? (Y/N)';
COMMENT ON COLUMN ds_data_sets.visible_flag IS 'Visible by views and policies? (Y/N)';
COMMENT ON COLUMN ds_data_sets.capture_flag IS 'Trigger capture enabled? (Y/N)';
COMMENT ON COLUMN ds_data_sets.capture_mode IS 'Trigger capture mode (NONE|ASYN|SYNC)';
COMMENT ON COLUMN ds_data_sets.capture_user IS 'Limit capture to this user (NULL means all)';
COMMENT ON COLUMN ds_data_sets.capture_seq IS 'Capture sequence';
COMMENT ON COLUMN ds_data_sets.line_sep_char IS 'Line terminator character (e.g., LF or CRLF)';
COMMENT ON COLUMN ds_data_sets.col_sep_char IS 'Column delimiter character (e.g., TAB or ;)';
COMMENT ON COLUMN ds_data_sets.left_sep_char IS 'Left enclosure character (e.g., ''"({[)';
COMMENT ON COLUMN ds_data_sets.right_sep_char IS 'Right enclosure character (e.g., ''")}])';
COMMENT ON COLUMN ds_data_sets.col_names_row IS 'Row number of column names header';
COMMENT ON COLUMN ds_data_sets.col_types_row IS 'Row number of column types header';
COMMENT ON COLUMN ds_data_sets.data_row IS 'Row number of first data line';
COMMENT ON COLUMN ds_data_sets.params IS 'Parameters';
COMMENT ON COLUMN ds_data_sets.user_created IS 'Audit: created by';
COMMENT ON COLUMN ds_data_sets.date_created IS 'Audit: creation date';

REM DBM-00110: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_SET_PK')
PROMPT Creating DS_SET_PK index...
CREATE UNIQUE INDEX ds_set_pk ON ds_data_sets (set_id)
TABLESPACE &&idx_ts
;

REM DBM-00120: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_SET_PK')
PROMPT Creating DS_SET_PK constraint...
ALTER TABLE ds_data_sets ADD (
   CONSTRAINT ds_set_pk PRIMARY KEY (set_id) USING INDEX
);

REM DBM-00130: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_SET_UK')
PROMPT Creating DS_SET_UK index...
CREATE UNIQUE INDEX ds_set_uk ON ds_data_sets (set_name)
TABLESPACE &&idx_ts
;

REM DBM-00140: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_SET_UK')
PROMPT Creating DS_SET_UK constraint...
ALTER TABLE ds_data_sets ADD (
   CONSTRAINT ds_set_uk UNIQUE (set_name) USING INDEX
);

REM DBM-00200: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_SET_SEQ')
PROMPT Creating DS_SET_SEQ sequence...
CREATE SEQUENCE ds_set_seq;

REM DBM-00210: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_TABLES')
PROMPT Creating DS_TABLES table...
CREATE TABLE ds_tables (
   table_id NUMBER(9) NOT NULL
  ,set_id NUMBER(9) NOT NULL
  ,table_name VARCHAR2(30 CHAR) NOT NULL
  ,table_alias VARCHAR2(30 CHAR) NULL
  ,extract_type VARCHAR2(1 CHAR) NOT NULL CONSTRAINT ds_tab_extract_type_ck CHECK (extract_type IN ('B','F','P','N','R'))
  ,row_limit INTEGER NULL CONSTRAINT ds_tab_row_limit_ck CHECK (row_limit IS NULL OR row_limit >= 0)
  ,row_count INTEGER NULL CONSTRAINT ds_tab_row_count_ck CHECK (row_count IS NULL OR row_count >= 0)
  ,percentage NUMBER(4,1) NULL CONSTRAINT ds_tab_percentage_ck CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
  ,source_count INTEGER NULL
  ,extract_count INTEGER NULL
  ,pass_count INTEGER NULL
  ,group_count INTEGER NULL
  ,seq INTEGER NULL
  ,where_clause VARCHAR2(4000 CHAR) NULL
  ,order_by_clause VARCHAR2(4000 CHAR) NULL
  ,columns_list VARCHAR2(4000 CHAR) NULL
  ,export_mode VARCHAR2(3 CHAR) NULL
  ,table_data CLOB NULL
  ,source_schema VARCHAR2(30 CHAR) NULL
  ,source_db_link VARCHAR2(30 CHAR) NULL
  ,target_schema VARCHAR2(30 CHAR) NULL
  ,target_db_link VARCHAR2(30 CHAR) NULL
  ,target_table_name VARCHAR2(30 CHAR) NULL
  ,user_column_name VARCHAR2(30 CHAR) NULL
  ,batch_size NUMBER NULL CONSTRAINT ds_tab_batch_size_ck CHECK (batch_size IS NULL OR batch_size > 0)
  ,tab_seq NUMBER(9) NULL
  ,gen_view_name VARCHAR2(30 CHAR) NULL
  ,pre_gen_code VARCHAR2(4000 CHAR) NULL
  ,post_gen_code VARCHAR2(4000 CHAR) NULL
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
COMMENT ON COLUMN ds_tables.row_count IS 'Number of rows to generate';
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
COMMENT ON COLUMN ds_tables.batch_size IS 'Batch size for bulk operations';
COMMENT ON COLUMN ds_tables.tab_seq IS 'Table sequence/order';
COMMENT ON COLUMN ds_tables.gen_view_name IS 'Name of the view used to generates records';
COMMENT ON COLUMN ds_tables.pre_gen_code IS 'Code to be executed before generation';
COMMENT ON COLUMN ds_tables.post_gen_code IS 'Code to be executed after generation';

REM DBM-00220: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_TAB_PK')
PROMPT Creating DS_TAB_PK index...
CREATE UNIQUE INDEX ds_tab_pk ON ds_tables (table_id)
TABLESPACE &&idx_ts
;

REM DBM-00230: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_TAB_PK')
ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_pk PRIMARY KEY (table_id) USING INDEX
);

REM DBM-00240: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_TAB_UK')
PROMPT Creating DS_TAB_UK index...
CREATE UNIQUE INDEX ds_tab_uk ON ds_tables (set_id, table_name)
TABLESPACE &&idx_ts
;

REM DBM-00250: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_TAB_UK')
ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_uk UNIQUE (set_id, table_name) USING INDEX
);

REM DBM-00260: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_TAB_SET_FK')
ALTER TABLE ds_tables ADD (
   CONSTRAINT ds_tab_set_fk FOREIGN KEY (set_id)
   REFERENCES ds_data_sets (set_id)
);

REM DBM-00270: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_TAB_SET_FK_I')
PROMPT Creating DS_TAB_SET_FK_I index...
CREATE INDEX ds_tab_set_fk_i ON ds_tables (set_id)
TABLESPACE &&idx_ts
;

REM DBM-00300: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_TAB_SEQ')
PROMPT Creating DS_TAB_SEQ sequence...
CREATE SEQUENCE ds_tab_seq;

REM DBM-00310: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_TAB_COLUMNS')
PROMPT Creating DS_TAB_COLUMNS table...
CREATE TABLE ds_tab_columns (
   table_id NUMBER(9) NOT NULL
  ,tab_name VARCHAR2(30 CHAR) NOT NULL
  ,col_name VARCHAR2(30 CHAR) NOT NULL
  ,col_seq NUMBER(9) NOT NULL
  ,gen_type VARCHAR2(10 CHAR) NULL CONSTRAINT ds_col_gen_type_ck CHECK (gen_type IS NULL OR gen_type IN ('SQL','FK','SEQ'))
  ,params VARCHAR2(4000 CHAR) NULL
  ,null_value_pct NUMBER(3) NULL
  ,null_value_condition VARCHAR2(4000 CHAR) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_tab_columns IS 'Data set table columns';
COMMENT ON COLUMN ds_tab_columns.table_id IS 'Id of table to which column belongs';
COMMENT ON COLUMN ds_tab_columns.tab_name IS 'Table name (denormalised)';
COMMENT ON COLUMN ds_tab_columns.col_name IS 'Column name';
COMMENT ON COLUMN ds_tab_columns.col_seq IS 'Sequence number of column within table';
COMMENT ON COLUMN ds_tab_columns.gen_type IS 'Generation type';
COMMENT ON COLUMN ds_tab_columns.params IS 'Generation parameters';
COMMENT ON COLUMN ds_tab_columns.null_value_pct IS 'Percentage of NULL values';
COMMENT ON COLUMN ds_tab_columns.null_value_condition IS 'Condition to force NULL value';

REM DBM-00320: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_COL_PK')
PROMPT Creating DS_COL_PK index...
CREATE UNIQUE INDEX ds_col_pk ON ds_tab_columns (table_id, col_name)
TABLESPACE &&idx_ts
;

REM DBM-00330: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_COL_PK')
PROMPT Creating DS_COL_PK constraint...
ALTER TABLE ds_tab_columns ADD (
   CONSTRAINT ds_col_pk PRIMARY KEY (table_id, col_name) USING INDEX
);

REM DBM-00340: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_COL_TAB_FK')
PROMPT Creating ds_col_tab_fk constraint...
ALTER TABLE ds_tab_columns ADD (
   CONSTRAINT ds_col_tab_fk FOREIGN KEY (table_id)
   REFERENCES ds_tables (table_id)
);

REM DBM-00350: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_COL_TAB_FK_I')
PROMPT Creating DS_COL_TAB_FK_I index...
CREATE INDEX ds_col_tab_fk_i ON ds_tab_columns (table_id)
TABLESPACE &&idx_ts
;

REM DBM-00400: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_CON_SEQ')
PROMPT Creating DS_CON_SEQ sequence...
CREATE SEQUENCE ds_con_seq;

REM DBM-00410: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_CONSTRAINTS')
PROMPT Creating DS_CONSTRAINTS table...
CREATE TABLE ds_constraints (
   con_id NUMBER(9) NOT NULL
  ,set_id NUMBER(9) NOT NULL
  ,constraint_name VARCHAR2(30 CHAR) NOT NULL
  ,src_table_name VARCHAR2(30 CHAR) NOT NULL
  ,dst_table_name VARCHAR2(30 CHAR) NOT NULL
  ,cardinality VARCHAR2(3 CHAR) NOT NULL CONSTRAINT ds_con_cardinality_ck CHECK (CARDINALITY IN ('1-N','N-1'))
  ,extract_type VARCHAR2(1 CHAR) NOT NULL CONSTRAINT ds_con_extract_type_ck CHECK (extract_type IN ('B','P','N')) 
  ,deferred VARCHAR2(9 CHAR) NOT NULL CONSTRAINT ds_con_deferred_ck CHECK (DEFERRED IN ('IMMEDIATE','DEFERRED'))
  ,percentage NUMBER(4,1) NULL CONSTRAINT ds_con_percentage_ck CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
  ,row_limit INTEGER NULL CONSTRAINT ds_con_row_limit_ck CHECK (row_limit IS NULL OR row_limit >= 0)
  ,min_rows INTEGER NULL CONSTRAINT ds_con_min_rows_ck CHECK (min_rows IS NULL OR min_rows >= 0)
  ,max_rows INTEGER NULL CONSTRAINT ds_con_max_rows_ck CHECK (max_rows IS NULL OR max_rows >= 0)
  ,level_count INTEGER NULL CONSTRAINT ds_con_level_count_ck CHECK (level_count IS NULL OR level_count >= 0)
  ,source_count INTEGER NULL
  ,extract_count INTEGER NULL
  ,where_clause VARCHAR2(4000 CHAR) NULL
  ,order_by_clause VARCHAR2(4000 CHAR) NULL
  ,join_clause VARCHAR2(4000 CHAR) NULL
  ,md_cardinality_ok VARCHAR2(1 CHAR) NULL
  ,md_optionality_ok VARCHAR2(1 CHAR) NULL
  ,md_uid_ok VARCHAR2(1 CHAR) NULL
  ,batch_size NUMBER NULL
  ,con_seq NUMBER(9) NULL
  ,gen_view_name VARCHAR2(30 CHAR) NULL
  ,pre_gen_code VARCHAR2(4000 CHAR) NULL
  ,post_gen_code VARCHAR2(4000 CHAR) NULL
  ,src_filter VARCHAR2(4000 CHAR) NULL
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
COMMENT ON COLUMN ds_constraints.min_rows IS 'Minimum number of rows to generate (per parent)';
COMMENT ON COLUMN ds_constraints.max_rows IS 'Maximum number of rows to generate (per parent)';
COMMENT ON COLUMN ds_constraints.level_count IS 'Number of levels to generate in the hierarchy (recursive fks only)';
COMMENT ON COLUMN ds_constraints.source_count IS 'Number of rows in source tables';
COMMENT ON COLUMN ds_constraints.extract_count IS 'Number of rows extracted via this constraint';
COMMENT ON COLUMN ds_constraints.where_clause IS 'Filter applied when following this constraint';
COMMENT ON COLUMN ds_constraints.order_by_clause IS 'Order used for sorting rows (of same parent)';
COMMENT ON COLUMN ds_constraints.join_clause IS 'Join clause - for internal use';
COMMENT ON COLUMN ds_constraints.md_cardinality_ok IS 'Master/detail: is #rows(detail) > #rows(master)? (Y/N)';
COMMENT ON COLUMN ds_constraints.md_optionality_ok IS 'Master/detail: is the fk mandatory? (Y/N)';
COMMENT ON COLUMN ds_constraints.md_uid_ok IS 'Master/detail: is master UID a prefix of detail UID? (Y/N)';
COMMENT ON COLUMN ds_constraints.batch_size IS 'Batch size for bulk operations';
COMMENT ON COLUMN ds_constraints.con_seq IS 'Constraint sequence/order';
COMMENT ON COLUMN ds_constraints.gen_view_name IS 'Name of the view used to generates records';
COMMENT ON COLUMN ds_constraints.pre_gen_code IS 'Code to be executed before generation';
COMMENT ON COLUMN ds_constraints.post_gen_code IS 'Code to be executed after generation';
COMMENT ON COLUMN ds_constraints.src_filter IS 'Source filter (where clause)';

REM DBM-00420: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_CON_PK')
PROMPT Creating DS_CON_PK index...
CREATE UNIQUE INDEX ds_con_pk ON ds_constraints(con_id)
TABLESPACE &&idx_ts
;

REM DBM-00425: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_CON_UK')
PROMPT Creating DS_CON_UK index...
CREATE UNIQUE INDEX ds_con_uk ON ds_constraints(set_id, constraint_name, cardinality)
TABLESPACE &&idx_ts
;

REM DBM-00430: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_CON_PK')
PROMPT Creating DS_CON_PK constraint...
ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_pk PRIMARY KEY (con_id) USING INDEX
);

REM DBM-00435: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_CON_UK')
PROMPT Creating DS_CON_UK constraint...
ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_uk UNIQUE (set_id, constraint_name, cardinality) USING INDEX
);

REM DBM-00440: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_CON_SET_FK')
PROMPT Creating DS_CON_SET_FK constraint...
ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_set_fk FOREIGN KEY (set_id)
   REFERENCES ds_data_sets (set_id)
);

REM DBM-00445: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_CON_TAB_DST_FK')
PROMPT Creating DS_CON_TAB_DST_FK constraint...
ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_tab_dst_fk FOREIGN KEY (set_id, dst_table_name)
   REFERENCES ds_tables (set_id, table_name)
);

REM DBM-00450: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_CON_TAB_SRC_FK')
PROMPT Creating DS_CON_TAB_SRC_FK constraint...
ALTER TABLE ds_constraints ADD (
   CONSTRAINT ds_con_tab_src_fk FOREIGN KEY (set_id, src_table_name)
   REFERENCES ds_tables (set_id, table_name)
);

REM DBM-00455: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_CON_SET_FK_I')
PROMPT Creating DS_CON_SET_FK_I index...
CREATE INDEX ds_con_set_fk_i ON ds_constraints(set_id)
TABLESPACE &&idx_ts
;

REM DBM-00460: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_CON_TAB_SRC_FK_I')
PROMPT Creating DS_CON_TAB_SRC_FK_I index...
CREATE INDEX ds_con_tab_src_fk_i ON ds_constraints(set_id, src_table_name)
TABLESPACE &&idx_ts
;

REM DBM-00465: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_CON_TAB_DST_FK_I')
PROMPT Creating DS_CON_TAB_DST_FK_I index...
CREATE INDEX ds_con_tab_dst_fk_i ON ds_constraints(set_id, dst_table_name)
TABLESPACE &&idx_ts
;

REM DBM-00500: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_REC_SEQ')
PROMPT Creating DS_REC_SEQ sequence...
CREATE SEQUENCE ds_rec_seq;

REM DBM-00510: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_RECORDS')
PROMPT Creating DS_RECORDS table...
CREATE TABLE ds_records (
   rec_id NUMBER DEFAULT ds_rec_seq.nextval NOT NULL
  ,table_id NUMBER(9) NOT NULL
  ,con_id NUMBER(9) NULL
  ,record_rowid VARCHAR2(50 CHAR) NULL
  ,shuffled_rowid_1 VARCHAR2(50 CHAR) NULL
  ,shuffled_rowid_2 VARCHAR2(50 CHAR) NULL
  ,shuffled_rowid_3 VARCHAR2(50 CHAR) NULL
  ,source_rowid VARCHAR2(50 CHAR) NULL
  ,src_rec_id NUMBER NULL
  ,seq INTEGER NULL
  ,distance INTEGER NULL
  ,pass_count INTEGER NULL
  ,user_name VARCHAR2(30 CHAR) NULL
  ,undo_timestamp TIMESTAMP NULL
  ,operation VARCHAR2(1 CHAR) NULL -- I)nsert, U)pdate, D)elete
  ,remark VARCHAR2(200 CHAR) NULL
  ,deleted_flag VARCHAR2(1 CHAR) NULL
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
COMMENT ON COLUMN ds_records.shuffled_rowid_1 IS 'Rowid of 1st shuffled record';
COMMENT ON COLUMN ds_records.shuffled_rowid_2 IS 'Rowid of 2nd shuffled record';
COMMENT ON COLUMN ds_records.shuffled_rowid_3 IS 'Rowid of 3rd shuffled record';
COMMENT ON COLUMN ds_records.source_rowid IS 'Rowid of source record';
COMMENT ON COLUMN ds_records.src_rec_id IS 'Source record id';
COMMENT ON COLUMN ds_records.seq IS 'Sequence';
COMMENT ON COLUMN ds_records.distance IS 'Distance';
COMMENT ON COLUMN ds_records.user_name IS 'Name of user who did the operation';
COMMENT ON COLUMN ds_records.undo_timestamp IS 'Date/time the operation was undone';
COMMENT ON COLUMN ds_records.pass_count IS 'Pass number - for internal use';
COMMENT ON COLUMN ds_records.operation IS 'Operation (I=Insert, U=Update, D=Delete)';
COMMENT ON COLUMN ds_records.remark IS 'Comment';
COMMENT ON COLUMN ds_records.deleted_flag IS 'Logically deleted (Y/N)';
COMMENT ON COLUMN ds_records.record_data IS 'XML extract of the record';
COMMENT ON COLUMN ds_records.record_data_old IS 'XML extract of the record (old values)';

REM DBM-00520: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_PK')
PROMPT Creating DS_REC_PK index...
CREATE INDEX ds_rec_pk ON ds_records (
   rec_id
)
TABLESPACE &&idx_ts
;

REM DBM-00530: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_I')
PROMPT Creating DS_REC_I index...
CREATE INDEX ds_rec_i ON ds_records (
   table_id, record_rowid, pass_count
)
TABLESPACE &&idx_ts
;

REM DBM-00540: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_I2')
PROMPT Creating DS_REC_I2 index...
CREATE INDEX ds_rec_i2 ON ds_records (
   table_id, pass_count
)
TABLESPACE &&idx_ts
;

REM DBM-00550: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_I3')
PROMPT Creating DS_REC_I3 index...
CREATE INDEX ds_rec_i3 ON ds_records (
   table_id, seq
)
TABLESPACE &&idx_ts
;

REM DBM-00560: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_REC_PK')
PROMPT Creating DS_REC_PK constraint...
ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_pk PRIMARY KEY (rec_id) USING INDEX
);

REM DBM-00570: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_REC_TAB_FK')
PROMPT Creating DS_REC_TAB_FK constraint...
ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_tab_fk FOREIGN KEY (table_id)
   REFERENCES ds_tables (table_id)
);

REM DBM-00580: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_REC_CON_FK')
PROMPT Creating DS_REC_CON_FK constraint...
ALTER TABLE ds_records ADD (
   CONSTRAINT ds_rec_con_fk FOREIGN KEY (con_id)
   REFERENCES ds_constraints (con_id)
);

REM DBM-00590: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_TAB_FK_I')
PROMPT Creating DS_REC_TAB_FK_I index...
CREATE INDEX ds_rec_tab_fk_i ON ds_records (table_id)
TABLESPACE &&idx_ts
;

REM DBM-00595: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_CON_FK_I')
PROMPT Creating DS_REC_CON_FK_I index...
CREATE INDEX ds_rec_con_fk_i ON ds_records (con_id)
TABLESPACE &&idx_ts
;

REM DBM-00597: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_REC_FK_I')
PROMPT Creating DS_REC_REC_FK_I index...
CREATE INDEX ds_rec_rec_fk_i ON ds_records (src_rec_id)
TABLESPACE &&idx_ts
;

REM DBM-00600: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_OUTPUT')
PROMPT Creating DS_OUTPUT table...
CREATE TABLE ds_output (
   line NUMBER NOT NULL
  ,text VARCHAR2(4000 CHAR) NULL
)
TABLESPACE &&tab_ts
;

REM DBM-00610: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_OUT_PK')
PROMPT Creating DS_OUT_PK index...
CREATE UNIQUE INDEX ds_out_pk ON ds_output (line)
TABLESPACE &&idx_ts
;

REM DBM-00620: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_OUT_PK')
PROMPT Creating DS_OUT_PK constraint...
ALTER TABLE ds_output ADD (
   CONSTRAINT ds_out_pk PRIMARY KEY (line) USING INDEX
);

REM DBM-00700: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_MSK_SEQ')
PROMPT Creating DS_MSK_SEQ sequence...
CREATE SEQUENCE ds_msk_seq
;

REM DBM-00710: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_MASKS')
PROMPT Creating DS_MASKS table...
CREATE TABLE ds_masks (
   msk_id NUMBER(9) DEFAULT ds_msk_seq.NEXTVAL NOT NULL
  ,table_name VARCHAR2(30 CHAR) NOT NULL
  ,column_name VARCHAR2(30 CHAR) NOT NULL
  ,sensitive_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_msk_sensitive_flag_ck CHECK (NVL(sensitive_flag,'Y') IN ('Y','N'))
  ,disabled_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_msk_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,locked_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_msk_locked_flag_ck CHECK (NVL(locked_flag,'Y') IN ('Y','N'))
  ,deleted_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_msk_deleted_flag_ck CHECK (NVL(deleted_flag,'Y') IN ('Y','N'))
  ,dependent_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_msk_dependent_flag_ck CHECK (NVL(dependent_flag,'Y') IN ('Y','N'))
  ,msk_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_msk_msk_type_ck CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE','INHERIT','SEQUENCE','TOKENIZE'))
  ,shuffle_group NUMBER(2) NULL CONSTRAINT ds_msk_shuffle_group_ck CHECK (NVL(shuffle_group,1) >= 1) 
  ,partition_bitmap NUMBER(2) NULL CONSTRAINT ds_msk_partition_bitmap_ck CHECK (NVL(partition_bitmap,1) >= 1)
  ,params VARCHAR2(4000 CHAR) NULL
  ,options VARCHAR2(200 CHAR) NULL
  ,pat_cat VARCHAR2(100 CHAR) NULL
  ,pat_name VARCHAR2(100 CHAR) NULL
  ,remarks VARCHAR2(4000 CHAR) NULL
  ,values_sample VARCHAR2(4000 CHAR) NULL
  ,gen_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_msk_gen_type_ck CHECK (gen_type IS NULL OR gen_type IN ('SEQ','SQL','FK'))
  ,gen_params VARCHAR2(4000 CHAR) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_masks IS 'Masks';
COMMENT ON COLUMN ds_masks.msk_id IS 'Mask id';
COMMENT ON COLUMN ds_masks.table_name IS 'Table name';
COMMENT ON COLUMN ds_masks.column_name IS 'Column name';
COMMENT ON COLUMN ds_masks.sensitive_flag IS 'Sensitive column (Y/N)?';
COMMENT ON COLUMN ds_masks.disabled_flag IS 'Disabled(Y/N)?';
COMMENT ON COLUMN ds_masks.locked_flag IS 'Locked (Y/N)?';
COMMENT ON COLUMN ds_masks.deleted_flag IS 'Logically deleted (Y/N)?';
COMMENT ON COLUMN ds_masks.dependent_flag IS 'Does this column depend on others (Y/N)?';
COMMENT ON COLUMN ds_masks.msk_type IS 'Mask type';
COMMENT ON COLUMN ds_masks.shuffle_group IS 'Shuffle group';
COMMENT ON COLUMN ds_masks.partition_bitmap IS 'Partition bitmap';
COMMENT ON COLUMN ds_masks.params IS 'Mask parameters';
COMMENT ON COLUMN ds_masks.options IS 'Mask options';
COMMENT ON COLUMN ds_masks.pat_cat IS 'Category of the source pattern ';
COMMENT ON COLUMN ds_masks.pat_name IS 'Name of the source pattern ';
COMMENT ON COLUMN ds_masks.remarks IS 'Mask remarks';
COMMENT ON COLUMN ds_masks.values_sample IS 'Sample of values';
COMMENT ON COLUMN ds_masks.gen_type IS 'Generation type';
COMMENT ON COLUMN ds_masks.gen_params IS 'Generation parameters';

REM DBM-00720: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_MSK_PK')
PROMPT Creating DS_MSK_PK index...
CREATE UNIQUE INDEX ds_msk_pk ON ds_masks (msk_id)
TABLESPACE &&idx_ts
;

REM DBM-00730: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_MSK_PK')
PROMPT Creating DS_MSK_PK constraint...
ALTER TABLE ds_masks ADD (
   CONSTRAINT ds_msk_pk PRIMARY KEY (msk_id) USING INDEX
);

REM DBM-00740: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_MSK_UK')
PROMPT Creating DS_MSK_UK index...
CREATE UNIQUE INDEX ds_msk_uk ON ds_masks (table_name, column_name)
TABLESPACE &&idx_ts
;

REM DBM-00750: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_MSK_UK')
PROMPT Creating DS_MSK_UK constraint...
ALTER TABLE ds_masks ADD (
   CONSTRAINT ds_msk_uk UNIQUE (table_name, column_name) USING INDEX
);

REM DBM-00800: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_IDENTIFIERS')
PROMPT Creating DS_IDENTIFIERS table...
CREATE TABLE ds_identifiers (
   msk_id NUMBER(9) NOT NULL
  ,old_id NUMBER NOT NULL
  ,new_id NUMBER NOT NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_identifiers IS 'Data set identifiers';
COMMENT ON COLUMN ds_identifiers.msk_id IS 'Mask id';
COMMENT ON COLUMN ds_identifiers.old_id IS 'Value of the identifier before relocation';
COMMENT ON COLUMN ds_identifiers.new_id IS 'Value of the identifier after relocation';

REM DBM-00810: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_DSI_PK')
PROMPT Creating DS_DSI_PK index...
CREATE UNIQUE INDEX ds_dsi_pk ON ds_identifiers (msk_id, old_id)
TABLESPACE &&idx_ts
;

REM DBM-00820: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_DSI_PK')
PROMPT Creating DS_DSI_PK constraint...
ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_pk PRIMARY KEY (msk_id, old_id) USING INDEX
);

REM DBM-00830: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_DSI_MSK_FK')
PROMPT Creating DS_DSI_MSK_FK constraint...
ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_msk_fk FOREIGN KEY (msk_id)
   REFERENCES ds_masks (msk_id)
);

REM DBM-00840: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_DSI_MSK_FK_I')
PROMPT Creating DS_DSI_MSK_FK_I index...
CREATE INDEX ds_dsi_msk_fk_i ON ds_identifiers(msk_id)
TABLESPACE &&idx_ts
;

REM DBM-00900: NOT EXISTS (SELECT 'x' FROM user_sequences WHERE sequence_name='DS_PAT_SEQ')
PROMPT Creating DS_PAT_SEQ sequence...
CREATE SEQUENCE ds_pat_seq
;

REM DBM-00910: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_PATTERNS')
PROMPT Creating DS_PATTERNS table...
CREATE TABLE ds_patterns (
   pat_id NUMBER(9) DEFAULT ds_pat_seq.NEXTVAL NOT NULL
  ,pat_cat VARCHAR2(100 CHAR) NULL
  ,pat_name VARCHAR2(100 CHAR) NOT NULL
  ,pat_seq NUMBER(3) NULL
  ,col_name_pattern VARCHAR2(4000 CHAR) NULL
  ,col_comm_pattern VARCHAR2(4000 CHAR) NULL
  ,col_data_pattern VARCHAR2(4000 CHAR) NULL
  ,col_data_set_name VARCHAR2(160 CHAR) NULL
  ,col_data_type VARCHAR2(30 CHAR) NULL
  ,col_data_min_pct NUMBER(3,0) NULL CONSTRAINT ds_pat_col_data_min_pct_ck CHECK(NVL(col_data_min_pct,0) BETWEEN 0 AND 100)
  ,col_data_min_cnt NUMBER(6,0) NULL CONSTRAINT ds_pat_col_data_min_cnt_ck CHECK(NVL(col_data_min_cnt,0)>=0)
  ,logical_operator VARCHAR2(3 CHAR) NULL CONSTRAINT ds_pat_logical_operator_ck CHECK(NVL(logical_operator,'OR') IN ('AND','OR'))
  ,system_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_pat_system_flag_ck CHECK (NVL(system_flag,'Y') IN ('Y','N'))
  ,disabled_flag VARCHAR2(1 CHAR) NULL CONSTRAINT ds_pat_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,remarks VARCHAR2(4000 CHAR) NULL
  ,msk_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_pat_msk_type CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE'))
  ,msk_params VARCHAR2(4000 CHAR) NULL
  ,gen_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_pat_gen_type CHECK (gen_type IS NULL OR gen_type IN ('SQL','SEQ','FK'))
  ,gen_params VARCHAR2(4000 CHAR) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_patterns IS 'Patterns for sensitive data discovery';
COMMENT ON COLUMN ds_patterns.pat_id IS 'Pattern id';
COMMENT ON COLUMN ds_patterns.pat_cat IS 'Pattern category';
COMMENT ON COLUMN ds_patterns.pat_name IS 'Pattern name';
COMMENT ON COLUMN ds_patterns.pat_name IS 'Pattern sequence';
COMMENT ON COLUMN ds_patterns.col_name_pattern IS 'Column name pattern';
COMMENT ON COLUMN ds_patterns.col_comm_pattern IS 'Column comment pattern';
COMMENT ON COLUMN ds_patterns.col_data_pattern IS 'Column data pattern';
COMMENT ON COLUMN ds_patterns.col_data_set_name IS 'Column data set name';
COMMENT ON COLUMN ds_patterns.col_data_type IS 'Column data type';
COMMENT ON COLUMN ds_patterns.col_data_min_pct IS 'Minimum data hit percentage';
COMMENT ON COLUMN ds_patterns.col_data_min_cnt IS 'Minimum data hit count';
COMMENT ON COLUMN ds_patterns.logical_operator IS 'Logical operator for combined search';
COMMENT ON COLUMN ds_patterns.system_flag IS 'System pattern? (Y/N)';
COMMENT ON COLUMN ds_patterns.disabled_flag IS 'Disabled? (Y/N)';
COMMENT ON COLUMN ds_patterns.remarks IS 'Remarks about pattern';
COMMENT ON COLUMN ds_patterns.msk_type IS 'Default mask type';
COMMENT ON COLUMN ds_patterns.msk_params IS 'Default mask parameters';
COMMENT ON COLUMN ds_patterns.gen_type IS 'Default generation type';
COMMENT ON COLUMN ds_patterns.gen_params IS 'Default generation parameters';

REM DBM-00920: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_PAT_PK')
PROMPT Creating DS_PAT_PK index...
CREATE UNIQUE INDEX ds_pat_pk ON ds_patterns (pat_id)
TABLESPACE &&idx_ts
;

REM DBM-00930: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_PAT_PK')
PROMPT Creating DS_PAT_PK constraint...
ALTER TABLE ds_patterns ADD (
   CONSTRAINT ds_pat_pk PRIMARY KEY (pat_id) USING INDEX
);

REM DBM-00940: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_PAT_UK')
PROMPT Creating DS_PAT_UK index...
CREATE UNIQUE INDEX ds_pat_uk ON ds_patterns (pat_name)
TABLESPACE &&idx_ts
;

REM DBM-00950: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_PAT_UK')
PROMPT Creating DS_PAT_UK constraint...
ALTER TABLE ds_patterns ADD (
   CONSTRAINT ds_pat_uk UNIQUE (pat_name) USING INDEX
);

REM DBM-01000: NOT EXISTS (SELECT 'x' FROM user_tables WHERE table_name='DS_TOKENS')
PROMPT Creating DS_TOKENS table...
CREATE TABLE ds_tokens (
   msk_id NUMBER(9) NOT NULL
  ,value VARCHAR2(4000 CHAR) NOT NULL
  ,token VARCHAR2(4000 CHAR) NOT NULL
)
;

COMMENT ON TABLE ds_tokens IS 'Tokens';
COMMENT ON COLUMN ds_tokens.msk_id IS 'Mask id';
COMMENT ON COLUMN ds_tokens.value IS 'Value';
COMMENT ON COLUMN ds_tokens.token IS 'Token';

REM DBM-01010: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_TOK_PK')
PROMPT Creating DS_TOK_PK index...
CREATE UNIQUE INDEX ds_tok_pk ON ds_tokens (msk_id, value)
TABLESPACE &&idx_ts
;

REM DBM-01020: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_TOK_PK')
PROMPT Creating DS_TOK_PK constraint...
ALTER TABLE ds_tokens ADD (
   CONSTRAINT ds_tok_pk PRIMARY KEY (msk_id, value) USING INDEX
);

REM DBM-01030: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_TOK_I')
PROMPT Creating DS_TOK_I index...
CREATE INDEX ds_tok_i ON ds_tokens(msk_id, token)
TABLESPACE &&idx_ts
;

REM DBM-01040: NOT EXISTS (SELECT 'x' FROM user_constraints WHERE constraint_name='DS_TOK_MSK_FK')
PROMPT Creating DS_TOK_MSK_FK constraint...
ALTER TABLE ds_tokens ADD (
   CONSTRAINT ds_tok_msk_fk FOREIGN KEY (msk_id)
   REFERENCES ds_masks (msk_id)
);

REM DBM-01100: NOT EXISTS(SELECT 'x' FROM user_sequences WHERE sequence_name='DS_RUN_SEQ')
PROMPT Creating DS_RUN_SEQ sequence...
CREATE SEQUENCE ds_run_seq
;

REM DBM-01110: NOT EXISTS(SELECT 'x' FROM user_tables WHERE table_name='DS_RUNS')
PROMPT Creating DS_RUNS table...
CREATE TABLE ds_runs (
   run_id NUMBER(9) NOT NULL
 , routine_name VARCHAR2(128) NOT NULL
 , set_id NUMBER(9) NULL -- no fk on purpose
 , set_name VARCHAR2(80) NULL -- denormalisation
 , start_time DATE DEFAULT SYSDATE NOT NULL
 , end_time DATE NULL
 , status VARCHAR2(10) CHECK(status IN ('ONGOING','SUCCESS','FAILURE'))
 , exit_code NUMBER(5) NULL
 , error_msg VARCHAR2(4000) NULL
 , params VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_runs IS 'Runs';
COMMENT ON COLUMN ds_runs.run_id IS 'Run id';
COMMENT ON COLUMN ds_runs.routine_name IS 'Invoked procedure or function';
COMMENT ON COLUMN ds_runs.params IS 'Parameters';
COMMENT ON COLUMN ds_runs.set_id IS 'Data set id';
COMMENT ON COLUMN ds_runs.set_name IS 'Data set name';
COMMENT ON COLUMN ds_runs.start_time IS 'Start date and time';
COMMENT ON COLUMN ds_runs.end_time IS 'End date and time';
COMMENT ON COLUMN ds_runs.status IS 'Run status';
COMMENT ON COLUMN ds_runs.exit_code IS 'Exit code';
COMMENT ON COLUMN ds_runs.error_msg IS 'Error message';

REM DBM-01120: NOT EXISTS(SELECT 'x' FROM user_indexes WHERE index_name='DS_RUN_PK')
PROMPT Creating DS_RUN_PK index...
CREATE UNIQUE INDEX ds_run_pk ON ds_runs (run_id)
TABLESPACE &&idx_ts
;

REM DBM-01130: NOT EXISTS(SELECT 'x' FROM user_constraints WHERE constraint_name='DS_RUN_PK')
PROMPT Creating DS_RUN_PK constraint...
ALTER TABLE ds_runs ADD (
   CONSTRAINT ds_run_pk PRIMARY KEY (run_id) USING INDEX
);

REM DBM-01200: NOT EXISTS(SELECT 'x' FROM user_sequences WHERE sequence_name='DS_LOG_SEQ')
PROMPT Creating DS_LOG_SEQ sequence...
CREATE SEQUENCE ds_log_seq
;

REM DBM-01210: NOT EXISTS(SELECT 'x' FROM user_tables WHERE table_name='DS_RUN_LOGS')
PROMPT Creating DS_RUN_LOGS table...
CREATE TABLE ds_run_logs (
   run_id NUMBER(9) NOT NULL
 , line NUMBER NOT NULL
 , text VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

COMMENT ON TABLE ds_run_logs IS 'Run logs';
COMMENT ON COLUMN ds_run_logs.run_id IS 'Run id';
COMMENT ON COLUMN ds_run_logs.line IS 'Log line';
COMMENT ON COLUMN ds_run_logs.text IS 'Log text';

REM DBM-01220: NOT EXISTS(SELECT 'x' FROM user_indexes WHERE index_name='DS_LOG_PK')
PROMPT Creating DS_LOG_PK index...
CREATE UNIQUE INDEX ds_log_pk ON ds_run_logs (run_id, line)
TABLESPACE &&idx_ts
;

REM DBM-01230: NOT EXISTS(SELECT 'x' FROM user_constraints WHERE constraint_name='DS_LOG_PK')
PROMPT Creating DS_LOG_PK constraint...
ALTER TABLE ds_run_logs ADD (
   CONSTRAINT ds_log_pk PRIMARY KEY (run_id, line) USING INDEX
);

REM DBM-01240: NOT EXISTS(SELECT 'x' FROM user_constraints WHERE constraint_name='DS_LOG_RUN_FK')
PROMPT Creating DS_LOG_RUN_FK constraint...
ALTER TABLE ds_run_logs ADD (
   CONSTRAINT ds_log_run_fk FOREIGN KEY (run_id)
   REFERENCES ds_runs (run_id)
);
