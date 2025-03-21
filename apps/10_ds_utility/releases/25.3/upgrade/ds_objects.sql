REM DBM-00010: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_RECORDS' AND column_name='DISTANCE')
PROMPT Altering DS_RECORDS table...
ALTER TABLE ds_records ADD distance INTEGER NULL;

COMMENT ON COLUMN ds_records.distance IS 'Distance';

REM DBM-00020: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_RECORDS' AND column_name='SRC_REC_ID')
PROMPT Altering DS_RECORDS table...
ALTER TABLE ds_records ADD src_rec_id NUMBER NULL;

COMMENT ON COLUMN ds_records.src_rec_id IS 'Source record id';

REM DBM-00030: NOT EXISTS (SELECT 'x' FROM user_indexes WHERE index_name='DS_REC_REC_FK_I')
PROMPT Creating DS_REC_REC_FK_I index...
CREATE INDEX ds_rec_rec_fk_i ON ds_records (src_rec_id)
TABLESPACE &&idx_ts
;

REM DBM-00040: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_PATTERNS' AND column_name='GEN_TYPE')
ALTER TABLE ds_patterns ADD gen_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_pat_gen_type CHECK (gen_type IS NULL OR gen_type IN ('SQL','SEQ','FK'))
;
COMMENT ON COLUMN ds_patterns.gen_type IS 'Default generation type';

REM DBM-00050: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_PATTERNS' AND column_name='GEN_PARAMS')
ALTER TABLE ds_patterns ADD gen_params VARCHAR2(4000 CHAR) NULL
;
COMMENT ON COLUMN ds_patterns.gen_params IS 'Default generation parameters';

REM DBM-00060: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_MASKS' AND column_name='GEN_TYPE')
ALTER TABLE ds_masks ADD gen_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_msk_gen_type_ck CHECK (gen_type IS NULL OR gen_type IN ('SEQ','SQL','FK'))
;

COMMENT ON COLUMN ds_masks.gen_type IS 'Generation type';

REM DBM-00070: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_MASKS' AND column_name='GEN_PARAMS')
ALTER TABLE ds_masks ADD gen_params VARCHAR2(4000 CHAR) NULL
;

COMMENT ON COLUMN ds_masks.gen_params IS 'Generation parameters';
