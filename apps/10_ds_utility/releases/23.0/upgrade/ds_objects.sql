ALTER TABLE ds_output DROP CONSTRAINT out_pk
;

CREATE UNIQUE INDEX ds_out_pk ON ds_output (line)
TABLESPACE &&idx_ts
;

ALTER TABLE ds_output ADD (
   CONSTRAINT ds_out_pk PRIMARY KEY (line) USING INDEX
);
