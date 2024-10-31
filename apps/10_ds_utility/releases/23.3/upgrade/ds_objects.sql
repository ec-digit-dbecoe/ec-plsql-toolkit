PROMPT Creating DS_TOKENS table...

CREATE TABLE ds_tokens (
   msk_id NUMBER(9) NOT NULL
  ,value VARCHAR2(4000) NOT NULL
  ,token VARCHAR2(4000) NOT NULL
)
;

COMMENT ON TABLE ds_tokens IS 'Tokens';
COMMENT ON COLUMN ds_tokens.msk_id IS 'Mask id';
COMMENT ON COLUMN ds_tokens.value IS 'Value';
COMMENT ON COLUMN ds_tokens.token IS 'Token';

CREATE UNIQUE INDEX ds_tok_pk ON ds_tokens (msk_id, value)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tokens ADD (
   CONSTRAINT ds_tok_pk PRIMARY KEY (msk_id, value) USING INDEX
);

CREATE INDEX ds_tok_i ON ds_tokens(msk_id, token)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_tokens ADD (
   CONSTRAINT ds_tok_msk_fk FOREIGN KEY (msk_id)
   REFERENCES ds_masks (msk_id)
);


PROMPT Altering DS_MASKS table...
ALTER TABLE ds_masks DROP CONSTRAINT ds_msk_msk_type_ck
;

ALTER TABLE ds_masks MODIFY (
   msk_type CONSTRAINT ds_msk_msk_type_ck CHECK (msk_type IS NULL OR msk_type IN ('SQL','SHUFFLE','INHERIT','SEQUENCE','TOKENIZE'))
);

ALTER TABLE ds_masks ADD (
   options VARCHAR2(200) NULL
);

COMMENT ON COLUMN ds_masks.options IS 'Mask options';

ALTER TABLE ds_masks ADD (
   dependent_flag VARCHAR2(1) NULL CONSTRAINT ds_msk_dependent_flag_ck CHECK (NVL(dependent_flag,'Y') IN ('Y','N'))
);

COMMENT ON COLUMN ds_masks.dependent_flag IS 'Does this column depend on others (Y/N)?';

PROMPT Altering DS_TABLES table...

ALTER TABLE ds_tables DROP COLUMN sequence_name;

ALTER TABLE ds_tables DROP COLUMN id_shift_value;

PROMPT Re-Creating DS_IDENTIFIERS table...

DROP TABLE ds_identifiers;

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

CREATE UNIQUE INDEX ds_dsi_pk ON ds_identifiers (msk_id, old_id)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_pk PRIMARY KEY (msk_id, old_id) USING INDEX
);

ALTER TABLE ds_identifiers ADD (
   CONSTRAINT ds_dsi_msk_fk FOREIGN KEY (msk_id)
   REFERENCES ds_masks (msk_id)
);

CREATE INDEX ds_dsi_msk_fk_i ON ds_identifiers(msk_id)
TABLESPACE &&idx_ts
;

UPDATE ds_patterns
   SET col_name_pattern = '((tele)?phone|(tele)?fax|gsm|mobile).*(no|nr|number|num|#)'
     , col_comm_pattern = '(tele)?phone|(tele)?fax|gsm|mobile number'
 WHERE pat_name = 'Phone number (sys)'
   AND system_flag = 'Y'
;

COMMIT;
