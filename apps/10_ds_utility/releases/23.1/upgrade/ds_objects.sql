CREATE SEQUENCE ds_msk_seq
;

CREATE TABLE ds_masks (
   msk_id NUMBER(9) DEFAULT ds_msk_seq.NEXTVAL NOT NULL
  ,table_name VARCHAR2(30) NOT NULL
  ,column_name VARCHAR2(30) NOT NULL
  ,sensitive_flag VARCHAR2(1) NULL CHECK (NVL(sensitive_flag,'Y') IN ('Y','N'))
  ,disabled_flag VARCHAR2(1) NULL CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,locked_flag VARCHAR2(1) NULL CHECK (NVL(locked_flag,'Y') IN ('Y','N'))
  ,msk_type VARCHAR2(30) NULL CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE','INHERIT','SEQUENCE'))
  ,shuffle_group NUMBER(2) NULL CHECK (NVL(shuffle_group,1) >= 1) 
  ,partition_bitmap NUMBER(2) NULL CHECK (NVL(partition_bitmap,1) >= 1)
  ,params VARCHAR2(4000) NULL
  ,pat_cat VARCHAR2(100) NULL
  ,pat_name VARCHAR2(100) NULL
  ,remarks VARCHAR2(4000) NULL
  ,values_sample VARCHAR2(4000) NULL
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
COMMENT ON COLUMN ds_masks.msk_type IS 'Mask type';
COMMENT ON COLUMN ds_masks.shuffle_group IS 'Shuffle group';
COMMENT ON COLUMN ds_masks.partition_bitmap IS 'Partition bitmap';
COMMENT ON COLUMN ds_masks.params IS 'Mask parameters';
COMMENT ON COLUMN ds_masks.pat_cat IS 'Category of the source pattern ';
COMMENT ON COLUMN ds_masks.pat_name IS 'Name of the source pattern ';
COMMENT ON COLUMN ds_masks.remarks IS 'Mask remarks';
COMMENT ON COLUMN ds_masks.values_sample IS 'Sample of values';

CREATE UNIQUE INDEX ds_msk_pk ON ds_masks (msk_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_masks ADD (
   CONSTRAINT ds_msk_pk PRIMARY KEY (msk_id) USING INDEX
);

CREATE UNIQUE INDEX ds_msk_uk ON ds_masks (table_name, column_name)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_masks ADD (
   CONSTRAINT ds_msk_uk UNIQUE (table_name, column_name) USING INDEX
);


PROMPT Creating ds_patterns table...

CREATE SEQUENCE ds_pat_seq
;

CREATE TABLE ds_patterns (
   pat_id NUMBER(9) DEFAULT ds_pat_seq.NEXTVAL NOT NULL
  ,pat_cat VARCHAR2(100) NULL
  ,pat_name VARCHAR2(100) NOT NULL
  ,pat_seq NUMBER(3) NULL
  ,col_name_pattern VARCHAR2(4000) NULL
  ,col_comm_pattern VARCHAR2(4000) NULL
  ,col_data_pattern VARCHAR2(4000) NULL
  ,col_data_set_name VARCHAR2(160) NULL
  ,col_data_type VARCHAR2(30) NULL
  ,col_data_min_pct NUMBER(3,0) NULL CHECK(NVL(col_data_min_pct,0) BETWEEN 0 AND 100)
  ,col_data_min_cnt NUMBER(6,0) NULL CHECK(NVL(col_data_min_cnt,0)>=0)
  ,logical_operator VARCHAR2(3) NULL CHECK(NVL(logical_operator,'OR') IN ('AND','OR'))
  ,system_flag VARCHAR2(1) NULL CHECK (NVL(system_flag,'Y') IN ('Y','N'))
  ,disabled_flag VARCHAR2(1) NULL CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,remarks VARCHAR2(4000) NULL
  ,msk_type VARCHAR2(30) NULL CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE','INHERIT','SEQUENCE'))
  ,msk_params VARCHAR2(4000) NULL
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

CREATE UNIQUE INDEX ds_pat_pk ON ds_patterns (pat_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_patterns ADD (
   CONSTRAINT ds_pat_pk PRIMARY KEY (pat_id) USING INDEX
);

CREATE UNIQUE INDEX ds_pat_uk ON ds_patterns (pat_name)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_patterns ADD (
   CONSTRAINT ds_pat_uk UNIQUE (pat_name) USING INDEX
);

PROMPT Altering table DS_DATA_SETS
ALTER TABLE ds_data_sets ADD (
   params CLOB NULL
)
;

COMMENT ON COLUMN ds_data_sets.params IS 'Parameters'
;

ALTER TABLE ds_data_sets ADD (
   system_flag VARCHAR2(1) NULL CHECK (NVL(system_flag,'Y') IN ('Y','N'))
)
;

COMMENT ON COLUMN ds_data_sets.system_flag IS 'System data set? (Y/N)'
;

ALTER TABLE ds_data_sets ADD (
   set_type VARCHAR2(10) NULL CHECK (set_type IN ('NATIVE','SQL','CSV','JSON','XML'))
)
;

COMMENT ON COLUMN ds_data_sets.set_type IS 'Data set type'
;

UPDATE ds_data_sets
   SET set_type = 'NATIVE'
;

ALTER TABLE ds_data_sets MODIFY set_type NOT NULL
;

ALTER TABLE ds_data_sets MODIFY visible_flag NULL CHECK (NVL(visible_flag,'Y') IN ('Y','N'))
;

UPDATE ds_data_sets
   SET visible_flag = NULL
 WHERE visible_flag = 'Y'
;

ALTER TABLE ds_data_sets MODIFY capture_flag CHECK (NVL(capture_flag,'Y') IN ('Y','N'))
;

UPDATE ds_data_sets
   SET capture_flag = NULL
 WHERE capture_flag = 'Y'
;

COMMIT
;

ALTER TABLE ds_data_sets ADD (
   line_sep_char VARCHAR2(2) NULL	
  ,col_sep_char VARCHAR2(1) NULL
  ,left_sep_char VARCHAR2(1) NULL
  ,right_sep_char VARCHAR2(1) NULL
  ,col_names_row INTEGER NULL
  ,col_types_row INTEGER NULL
  ,data_row INTEGER NULL
)
;

COMMENT ON COLUMN ds_data_sets.line_sep_char IS 'Line terminator character (e.g., LF or CRLF)';
COMMENT ON COLUMN ds_data_sets.col_sep_char IS 'Column delimiter character (e.g., TAB or ;)';
COMMENT ON COLUMN ds_data_sets.left_sep_char IS 'Left enclosure character (e.g., ''"({[)';
COMMENT ON COLUMN ds_data_sets.right_sep_char IS 'Right enclosure character (e.g., ''")}])';
COMMENT ON COLUMN ds_data_sets.col_names_row IS 'Row number of column names header';
COMMENT ON COLUMN ds_data_sets.col_types_row IS 'Row number of column types header';
COMMENT ON COLUMN ds_data_sets.data_row IS 'Row number of first data line';

ALTER TABLE ds_data_sets ADD (
   disabled_flag VARCHAR2(1) NULL CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
);

COMMENT ON COLUMN ds_data_sets.disabled_flag IS 'Disabled? (Y/N)';

PROMPT Altering DS_RECORDS table
ALTER TABLE ds_records ADD (
   shuffled_rowid_1 VARCHAR2(50) NULL
 , shuffled_rowid_2 VARCHAR2(50) NULL
 , shuffled_rowid_3 VARCHAR2(50) NULL
);

COMMENT ON COLUMN ds_records.shuffled_rowid_1 IS 'Rowid of 1st shuffled record';
COMMENT ON COLUMN ds_records.shuffled_rowid_2 IS 'Rowid of 2nd shuffled record';
COMMENT ON COLUMN ds_records.shuffled_rowid_3 IS 'Rowid of 3rd shuffled record';
COMMENT ON COLUMN ds_records.record_data_old IS 'XML extract of the record (old values)';
