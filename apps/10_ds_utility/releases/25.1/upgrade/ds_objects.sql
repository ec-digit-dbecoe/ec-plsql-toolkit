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
