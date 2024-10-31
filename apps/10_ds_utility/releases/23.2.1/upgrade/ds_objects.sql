PROMPT Upgrading table DS_MASKS...

ALTER TABLE ds_masks ADD (
   deleted_flag VARCHAR2(1) NULL CONSTRAINT ds_msk_deleted_flag_ck CHECK (NVL(deleted_flag,'Y') IN ('Y','N'))
);

COMMENT ON COLUMN ds_masks.deleted_flag IS 'Logically deleted (Y/N)?';
