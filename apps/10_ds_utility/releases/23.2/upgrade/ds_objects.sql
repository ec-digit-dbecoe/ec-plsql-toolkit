REM Drop all unnamed constraints
DECLARE
   l_sql VARCHAR(4000);
BEGIN
   FOR r_con IN (
      SELECT table_name, constraint_name
        FROM user_constraints
       WHERE table_name LIKE 'DS%'
         AND constraint_type = 'C'
         AND search_condition_vc NOT LIKE '%NOT NULL'
         AND generated = 'GENERATED NAME'
       ORDER BY table_name, constraint_name
   )
   LOOP
      l_sql := 'ALTER TABLE '||r_con.table_name||' DROP CONSTRAINT '||r_con.constraint_name;
      BEGIN
         EXECUTE IMMEDIATE l_sql;
         dbms_output.put_line(l_sql||': OK');
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line(l_sql||': '||SQLERRM);
      END;
  END LOOP;
END;
/

UPDATE ds_data_sets SET set_type = 'SUB' /*Subsetting*/ WHERE set_type = 'NATIVE';

REM Recreate unnamed constraints with a name
ALTER TABLE ds_data_sets MODIFY (
   set_type CONSTRAINT ds_set_set_type_ck CHECK (set_type IN ('SUB','SQL','CSV','JSON','XML','GEN'))
  ,system_flag CONSTRAINT ds_set_system_flag_ck CHECK (NVL(system_flag,'Y') IN ('Y','N'))
  ,disabled_flag CONSTRAINT ds_set_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,visible_flag CONSTRAINT ds_set_visible_flag_ck CHECK (NVL(visible_flag,'Y') IN ('Y','N'))
  ,capture_flag CONSTRAINT ds_set_capture_flag_ck CHECK (NVL(capture_flag,'Y') IN ('Y','N'))
);

ALTER TABLE ds_tables MODIFY (
   extract_type CONSTRAINT ds_tab_extract_type_ck CHECK (extract_type IN ('B','F','P','N'))
  ,row_limit CONSTRAINT ds_tab_row_limit_ck CHECK (row_limit IS NULL OR row_limit >= 0)
  ,percentage CONSTRAINT ds_tab_percentage_ck CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
);

ALTER TABLE ds_constraints MODIFY (
   cardinality CONSTRAINT ds_con_cardinality_ck CHECK (CARDINALITY IN ('1-N','N-1'))
  ,extract_type CONSTRAINT ds_con_extract_type_ck CHECK (extract_type IN ('B','P','N')) 
  ,deferred CONSTRAINT ds_con_deferred_ck CHECK (DEFERRED IN ('IMMEDIATE','DEFERRED'))
  ,percentage CONSTRAINT ds_con_percentage_ck CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100)
  ,row_limit CONSTRAINT ds_con_row_limit_ck CHECK (row_limit IS NULL OR row_limit >= 0)
);

ALTER TABLE ds_masks MODIFY (
   sensitive_flag CONSTRAINT ds_msk_sensitive_flag_ck CHECK (NVL(sensitive_flag,'Y') IN ('Y','N'))
  ,disabled_flag CONSTRAINT ds_msk_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,locked_flag CONSTRAINT ds_msk_locked_flag_ck CHECK (NVL(locked_flag,'Y') IN ('Y','N'))
  ,msk_type CONSTRAINT ds_msk_msk_type_ck CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE','INHERIT','SEQUENCE'))
  ,shuffle_group CONSTRAINT ds_msk_shuffle_group_ck CHECK (NVL(shuffle_group,1) >= 1) 
  ,partition_bitmap CONSTRAINT ds_msk_partition_bitmap_ck CHECK (NVL(partition_bitmap,1) >= 1)
);

ALTER TABLE ds_patterns MODIFY (
   col_data_min_pct CONSTRAINT ds_pat_col_data_min_pct_ck CHECK(NVL(col_data_min_pct,0) BETWEEN 0 AND 100)
  ,col_data_min_cnt CONSTRAINT ds_pat_col_data_min_cnt_ck CHECK(NVL(col_data_min_cnt,0)>=0)
  ,logical_operator CONSTRAINT ds_pat_logical_operator_ck CHECK(NVL(logical_operator,'OR') IN ('AND','OR'))
  ,system_flag CONSTRAINT ds_pat_system_flag_ck CHECK (NVL(system_flag,'Y') IN ('Y','N'))
  ,disabled_flag CONSTRAINT ds_pat_disabled_flag_ck CHECK (NVL(disabled_flag,'Y') IN ('Y','N'))
  ,msk_type CONSTRAINT ds_pat_msk_type CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE'))
);

--DROP TABLE ds_tab_columns;

PROMPT Creating ds_tab_columns table...
CREATE TABLE ds_tab_columns (
   table_id NUMBER(9) NOT NULL
  ,tab_name VARCHAR2(30) NOT NULL
  ,col_name VARCHAR2(30) NOT NULL
  ,col_seq NUMBER(9) NOT NULL
  ,gen_type VARCHAR2(10) NULL CONSTRAINT ds_col_gen_type_ck CHECK (gen_type IS NULL OR gen_type IN ('SQL','FK','SEQ'))
  ,params VARCHAR2(4000) NULL
  ,null_value_pct NUMBER(3) NULL
  ,null_value_condition VARCHAR2(4000) NULL
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

CREATE UNIQUE INDEX ds_col_pk ON ds_tab_columns (table_id, col_name)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tab_columns ADD (
   CONSTRAINT ds_col_pk PRIMARY KEY (table_id, col_name) USING INDEX
);

ALTER TABLE ds_tab_columns ADD (
   CONSTRAINT ds_col_tab_fk FOREIGN KEY (table_id)
   REFERENCES ds_tables (table_id)
);

CREATE INDEX ds_col_tab_fk_i ON ds_tab_columns (table_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_constraints ADD (
   min_rows INTEGER NULL CONSTRAINT ds_con_min_rows_ck CHECK (min_rows IS NULL OR min_rows >= 0)
  ,max_rows INTEGER NULL CONSTRAINT ds_con_max_rows_ck CHECK (max_rows IS NULL OR max_rows >= 0)
);

COMMENT ON COLUMN ds_constraints.min_rows IS 'Minimum number of rows to generate (per parent)';
COMMENT ON COLUMN ds_constraints.max_rows IS 'Maximum number of rows to generate (per parent)';

ALTER TABLE ds_tables ADD (
   row_count INTEGER NULL CONSTRAINT ds_tab_row_count_ck CHECK (row_count IS NULL OR row_count >= 0)
)
;

COMMENT ON COLUMN ds_tables.row_count IS 'Number of rows to generate';

ALTER TABLE ds_tables DROP CONSTRAINT ds_tab_extract_type_ck;
ALTER TABLE ds_tables ADD CONSTRAINT ds_tab_extract_type_ck CHECK (extract_type IN ('B','F','P','N','R'));

CREATE INDEX ds_rec_i3 ON ds_records (
   table_id, seq
)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tables ADD (
   batch_size NUMBER NULL
);

COMMENT ON COLUMN ds_tables.batch_size IS 'Batch size for bulk operations';

ALTER TABLE ds_tables ADD (
   gen_view_name VARCHAR2(30) NULL
);

COMMENT ON COLUMN ds_tables.gen_view_name IS 'Name of the view used to generates records';

ALTER TABLE ds_constraints ADD (
   gen_view_name VARCHAR2(30) NULL
);

COMMENT ON COLUMN ds_constraints.gen_view_name IS 'Name of the view used to generates records';

ALTER TABLE ds_constraints ADD (
   level_count INTEGER NULL CONSTRAINT ds_con_level_count_ck CHECK (level_count IS NULL OR level_count >= 0)
);

COMMENT ON COLUMN ds_constraints.level_count IS 'Number of levels to generate in the hierarchy (recursive fks only)';

ALTER TABLE ds_constraints ADD (
   con_seq NUMBER(9) NULL
);

COMMENT ON COLUMN ds_constraints.md_uid_ok IS 'Master/detail: is master UID a prefix of detail UID? (Y/N)';
COMMENT ON COLUMN ds_constraints.con_seq IS 'Constraint order of processing';

ALTER TABLE ds_tables ADD (
   pre_gen_code VARCHAR2(4000) NULL
  ,post_gen_code VARCHAR2(4000) NULL
);

COMMENT ON COLUMN ds_tables.pre_gen_code IS 'Code to be executed before generation';
COMMENT ON COLUMN ds_tables.post_gen_code IS 'Code to be executed after generation';

ALTER TABLE ds_constraints ADD (
   pre_gen_code VARCHAR2(4000) NULL
  ,post_gen_code VARCHAR2(4000) NULL
);

COMMENT ON COLUMN ds_constraints.pre_gen_code IS 'Code to be executed before generation';
COMMENT ON COLUMN ds_constraints.post_gen_code IS 'Code to be executed after generation';

ALTER TABLE ds_tables ADD (
   tab_seq NUMBER(9) NULL
);

COMMENT ON COLUMN ds_tables.tab_seq IS 'Table sequence/order';

ALTER TABLE ds_constraints ADD (
   batch_size NUMBER NULL
);

COMMENT ON COLUMN ds_constraints.batch_size IS 'Batch size for bulk operations';

ALTER TABLE ds_constraints ADD (
   src_filter VARCHAR2(4000) NULL
);

COMMENT ON COLUMN ds_constraints.src_filter IS 'Source filter (where clause)';
