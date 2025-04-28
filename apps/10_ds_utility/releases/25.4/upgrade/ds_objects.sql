REM DBM-00010: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_PATTERNS' AND column_name='TDE_TYPE')
ALTER TABLE ds_patterns ADD tde_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_pat_tde_type CHECK (tde_type IS NULL OR tde_type IN ('SQL','INHERIT'))
;

COMMENT ON COLUMN ds_patterns.tde_type IS 'Default encryption type';

REM DBM-00020: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_PATTERNS' AND column_name='TDE_PARAMS')
ALTER TABLE ds_patterns ADD tde_params VARCHAR2(4000 CHAR) NULL
;

COMMENT ON COLUMN ds_patterns.tde_params IS 'Default encryption parameters';

REM DBM-00030: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_MASKS' AND column_name='TDE_TYPE')
ALTER TABLE ds_masks ADD tde_type VARCHAR2(30 CHAR) NULL CONSTRAINT ds_msk_tde_type_ck CHECK (tde_type IS NULL OR tde_type IN ('SQL','INHERIT'))
;

COMMENT ON COLUMN ds_masks.tde_type IS 'Encryption type';

REM DBM-00040: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_MASKS' AND column_name='TDE_PARAMS')
ALTER TABLE ds_masks ADD tde_params VARCHAR2(4000 CHAR) NULL
;

COMMENT ON COLUMN ds_masks.tde_params IS 'Encryption parameters';

REM DBM-00050: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_MASKS' AND column_name='MSK_PARAMS')
ALTER TABLE ds_masks RENAME COLUMN params TO msk_params
;

REM DBM-00060: NOT EXISTS(SELECT 'x' FROM user_tab_columns WHERE table_name='DS_TAB_COLUMNS' AND column_name='GEN_PARAMS')
ALTER TABLE ds_tab_columns RENAME COLUMN params TO gen_params
;
