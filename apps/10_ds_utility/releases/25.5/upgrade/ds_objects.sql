ALTER TABLE ds_records RENAME COLUMN remark TO remarks;

ALTER TABLE ds_records MODIFY remarks VARCHAR2(4000 CHAR);
