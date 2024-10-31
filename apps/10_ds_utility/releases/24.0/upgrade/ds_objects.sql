PROMPT Updating data...
exec ds_utility_krn.update_pattern_properties(p_pat_name=>'SWIFT Code(sys)', p_disabled_flag=>'Y') /*give too many false positive */;
COMMIT;

PROMPT Upgrading tables...
ALTER TABLE ds_data_sets DROP CONSTRAINT ds_set_set_type_ck;

ALTER TABLE ds_data_sets MODIFY (
   set_type CONSTRAINT ds_set_set_type_ck CHECK (set_type IN ('SUB','SQL','CSV','JSON','XML','GEN','CAP'))
);

UPDATE ds_data_sets
   SET capture_mode = CASE UPPER(capture_mode) WHEN 'XML' THEN 'NONE' WHEN 'XML;FWD' THEN 'ASYN' WHEN 'EXP' THEN 'SYNC' ELSE NULL END
     , set_type = 'CAP'
 WHERE capture_mode IS NOT NULL
;

ALTER TABLE ds_data_sets MODIFY (
   capture_mode CONSTRAINT ds_set_capture_mode_ck CHECK (NVL(capture_mode,'NONE') IN ('NONE','ASYN','SYNC'))
);

COMMENT ON COLUMN ds_data_sets.capture_mode IS 'Trigger capture mode (NONE|ASYN|SYNC)'
;
