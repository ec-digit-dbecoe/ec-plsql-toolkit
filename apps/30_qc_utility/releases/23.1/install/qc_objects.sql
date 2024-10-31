PROMPT Create table QC_APPS...
CREATE TABLE qc_apps (
   app_alias VARCHAR2(10) CONSTRAINT qc_app_app_alias_nn NOT NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_APPS...
COMMENT ON TABLE qc_apps IS 'Applications'
;

COMMENT ON COLUMN qc_apps.app_alias IS 'Application Alias'
;

PROMPT Creating unique index QC_APP_PK_I...
CREATE UNIQUE INDEX qc_app_pk_i ON qc_apps(app_alias)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_APP_PK...
ALTER TABLE qc_apps ADD (
  CONSTRAINT qc_app_pk
  PRIMARY KEY(app_alias)
  USING INDEX qc_app_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating table QC_CHECKS...
CREATE TABLE qc_checks (
   qc_code    VARCHAR2(10)  CONSTRAINT qc_chk_qc_code_nn NOT NULL
 , descr      VARCHAR2(250) CONSTRAINT qc_chk_descr_nn NOT NULL
 , msg_type   VARCHAR2(1)   DEFAULT 'E' NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table qc_checks...
COMMENT ON TABLE qc_checks IS 'Quality checks'
;

COMMENT ON COLUMN qc_checks.qc_code IS 'Quality check code'
;

COMMENT ON COLUMN qc_checks.descr IS 'Quality check description'
;

COMMENT ON COLUMN qc_checks.msg_type IS 'Message type: E)rror, W)arning, I)nfo'
;

PROMPT Creating index QC_CHK_PK_I...
CREATE UNIQUE INDEX qc_chk_pk_i ON qc_checks(qc_code)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_CHK_PK...
ALTER TABLE qc_checks ADD (
  CONSTRAINT qc_chk_pk
  PRIMARY KEY(qc_code)
  USING INDEX qc_chk_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating table QC_DICTIONARY_ENTRIES...
CREATE TABLE qc_dictionary_entries (
   app_alias  VARCHAR2(10)  CONSTRAINT qc_dict_app_alias_nn NOT NULL
 , dict_name  VARCHAR2(30)  CONSTRAINT qc_dict_dict_name_nn NOT NULL
 , dict_key   VARCHAR2(100) CONSTRAINT qc_dict_dict_key_nn NOT NULL
 , dict_value VARCHAR2(750) NULL
 , comments   VARCHAR2(250) NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_DICTIONARY_ENTRIES...
COMMENT ON TABLE qc_dictionary_entries IS 'Dictionnary entries'
;

COMMENT ON COLUMN qc_dictionary_entries.app_alias IS 'Application alias'
;

COMMENT ON COLUMN qc_dictionary_entries.dict_name IS 'Dictionary name'
;

COMMENT ON COLUMN qc_dictionary_entries.dict_key IS 'Dictionary key'
;

COMMENT ON COLUMN qc_dictionary_entries.dict_value IS 'Dictionary value'
;

COMMENT ON COLUMN qc_dictionary_entries.comments IS 'Comments about the entry'
;

PROMPT Creating index QC_DICT_PK_I...
CREATE UNIQUE INDEX qc_dict_pk_i ON qc_dictionary_entries(app_alias, dict_name, dict_key)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_DICT_PK...
ALTER TABLE qc_dictionary_entries ADD (
  CONSTRAINT qc_dict_pk
  PRIMARY KEY(app_alias, dict_name, dict_key)
  USING INDEX qc_dict_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_DICT_APP_FK...
ALTER TABLE qc_dictionary_entries ADD (
  CONSTRAINT qc_dict_app_fk
  FOREIGN KEY (app_alias) 
  REFERENCES qc_apps (app_alias)
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_DICT_APP_FK_I...
CREATE INDEX qc_dict_app_fk_i ON qc_dictionary_entries(app_alias)
TABLESPACE &&idx_ts
;

PROMPT Creating table QC_PATTERNS...
CREATE TABLE qc_patterns (
   app_alias VARCHAR2(10) CONSTRAINT qc_pat_app_alias_nn NOT NULL
 , object_type VARCHAR2(35) CONSTRAINT qc_pat_object_type_nn NOT NULL
 , check_pattern VARCHAR2(250) NULL
 , anti_pattern VARCHAR2(250) NULL
 , include_pattern VARCHAR2(250) NULL
 , exclude_pattern VARCHAR2(250) NULL
 , fix_pattern VARCHAR2(250) NULL
 , msg_type VARCHAR2(1) DEFAULT 'E' NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_PATTERNS...
COMMENT ON TABLE qc_patterns IS 'Patterns applied to object types'
;

COMMENT ON COLUMN qc_patterns.app_alias IS 'Application alias'
;

COMMENT ON COLUMN qc_patterns.object_type IS 'Object type'
;

COMMENT ON COLUMN qc_patterns.check_pattern IS 'Pattern that object names must match'
;

COMMENT ON COLUMN qc_patterns.anti_pattern IS 'Pattern that object names must NOT match'
;

COMMENT ON COLUMN qc_patterns.include_pattern IS 'Pattern identifying objects which are included in the QC checks'
;

COMMENT ON COLUMN qc_patterns.exclude_pattern IS 'Pattern identifying objects which are excluded from the QC checks'
;

COMMENT ON COLUMN qc_patterns.fix_pattern IS 'Pattern used to fix invalidate object names'
;

COMMENT ON COLUMN qc_patterns.msg_type IS 'Type of message: I)nformation, W)arning or E)rror'
;

PROMPT Creating index QC_PAT_PK_I...
CREATE UNIQUE INDEX qc_pat_pk_i ON qc_patterns(app_alias, object_type)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_PAT_PK...
ALTER TABLE qc_patterns ADD (
  CONSTRAINT qc_pat_pk
  PRIMARY KEY(app_alias, object_type)
  USING INDEX qc_pat_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating table QC_RUNS...
CREATE TABLE qc_runs (
   run_id NUMBER CONSTRAINT qc_run_run_id_nn NOT NULL
 , begin_time DATE CONSTRAINT qc_run_begin_time_nn NOT NULL
 , end_time DATE NULL
 , status VARCHAR2(10) CONSTRAINT qc_run_status_nn NOT NULL
 , msg_count NUMBER NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating constraint QC_PAT_APP_FK...
ALTER TABLE qc_patterns ADD (
  CONSTRAINT qc_pat_app_fk
  FOREIGN KEY (app_alias) 
  REFERENCES qc_apps (app_alias)
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_PAT_APP_FK_I...
CREATE INDEX qc_pat_app_fk_i ON qc_patterns(app_alias)
TABLESPACE &&idx_ts
;

PROMPT Creating comments on table QC_RUNS...
COMMENT ON TABLE qc_runs IS 'Quality check runs'
;

COMMENT ON COLUMN qc_runs.run_id IS 'QC run unique identifier'
;

COMMENT ON COLUMN qc_runs.begin_time IS 'Start date and time of the run'
;

COMMENT ON COLUMN qc_runs.end_time IS 'End date and time of the run'
;

COMMENT ON COLUMN qc_runs.status IS 'Status of the run: RUNNING, SUCCESS or FAILURE'
;

COMMENT ON COLUMN qc_runs.msg_count IS 'Number of generated messages by the run'
;

PROMPT Creating index QC_RUN_PK_I...
CREATE UNIQUE INDEX qc_run_pk_i ON qc_runs(run_id)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_RUN_PK...
ALTER TABLE qc_runs ADD (
  CONSTRAINT qc_run_pk
  PRIMARY KEY(run_id)
  USING INDEX qc_run_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating sequence QC_RUN_SEQ...
CREATE SEQUENCE qc_run_seq
;

PROMPT Creating table QC_RUN_MSGS...
CREATE TABLE qc_run_msgs (
   msg_ivid     NUMBER         CONSTRAINT qc_msg_msg_ivid_nn NOT NULL
 , msg_irid     NUMBER         CONSTRAINT qc_msg_msg_irid_nn NOT NULL
 , run_id_from  NUMBER         CONSTRAINT qc_msg_run_id_from_nn NOT NULL
 , run_id_to    NUMBER         NULL
 , qc_code      VARCHAR2(10)   CONSTRAINT qc_msg_qc_code_nn NOT NULL
 , app_alias    VARCHAR2(10)   CONSTRAINT qc_msg_app_alias_nn NOT NULL
 , object_owner VARCHAR2(30)   CONSTRAINT qc_msg_object_owner_nn NOT NULL
 , object_type  VARCHAR2(35)   CONSTRAINT qc_msg_object_type_nn NOT NULL
 , object_name  VARCHAR2(100)  CONSTRAINT qc_msg_object_name_nn NOT NULL
 , msg_type     VARCHAR2(1)    CONSTRAINT qc_msg_msg_type_nn NOT NULL
 , msg_text     VARCHAR2(400)  CONSTRAINT qc_msg_msg_text_nn NOT NULL
 , msg_hidden   VARCHAR2(1)    NULL
 , sort_order   NUMBER         NULL
 , fix_type     VARCHAR2(30)   NULL -- object type
 , fix_name     VARCHAR2(100)  NULL -- object name
 , fix_op       VARCHAR2(10)   NULL -- RENAME/DROP
 , fix_status   VARCHAR2(10)   NULL -- SUCCESS/FAILURE
 , fix_msg      VARCHAR2(400)  NULL
 , fix_ddl      VARCHAR2(400)  NULL
 , fix_locked   VARCHAR2(1)    NULL -- Y/N
 , fix_time     DATE           NULL
 , dep_ref_cnt  NUMBER         NULL
 , src_ref_cnt  NUMBER         NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_RUN_MSGS...
COMMENT ON TABLE qc_run_msgs IS 'Quality check run messages'
;

COMMENT ON COLUMN qc_run_msgs.msg_ivid IS 'Internal version id'
;

COMMENT ON COLUMN qc_run_msgs.msg_irid IS 'Internal record id'
;

COMMENT ON COLUMN qc_run_msgs.run_id_from IS 'Id of the run which created the message'
;

COMMENT ON COLUMN qc_run_msgs.run_id_to IS 'Id of the run which closed the message'
;

COMMENT ON COLUMN qc_run_msgs.qc_code IS 'Code of the quality check'
;

COMMENT ON COLUMN qc_run_msgs.app_alias IS 'Application alias'
;

COMMENT ON COLUMN qc_run_msgs.object_owner IS 'Object owner'
;

COMMENT ON COLUMN qc_run_msgs.object_type IS 'Object type'
;

COMMENT ON COLUMN qc_run_msgs.object_name IS 'Object name'
;

COMMENT ON COLUMN qc_run_msgs.msg_type IS 'Type of message: I)nformation, W)arning or E)rror'
;

COMMENT ON COLUMN qc_run_msgs.msg_text IS 'Text of the message'
;

COMMENT ON COLUMN qc_run_msgs.msg_hidden IS 'Message must be hidden (Y/N) i.e. no more reported'
;

COMMENT ON COLUMN qc_run_msgs.sort_order IS 'Sorting order'
;

COMMENT ON COLUMN qc_run_msgs.fix_type IS 'Object type to fix the annomaly'
;

COMMENT ON COLUMN qc_run_msgs.fix_name IS 'Object name to fix the anomaly'
;

COMMENT ON COLUMN qc_run_msgs.fix_op IS 'Operation to fix the anomaly'
;

COMMENT ON COLUMN qc_run_msgs.fix_status IS 'Status of fix operation'
;

COMMENT ON COLUMN qc_run_msgs.fix_msg IS 'Message raised during fix operation'
;

COMMENT ON COLUMN qc_run_msgs.fix_ddl IS 'DDL used to fix anomaly'
;

COMMENT ON COLUMN qc_run_msgs.fix_locked IS 'Fix name is locked (Y/N)'
;

COMMENT ON COLUMN qc_run_msgs.fix_time IS 'Time at which the anomaly was fixed'
;

COMMENT ON COLUMN qc_run_msgs.dep_ref_cnt IS 'Number of references found in user_dependencies'
;

COMMENT ON COLUMN qc_run_msgs.src_ref_cnt IS 'Number of references found in user_source'
;

PROMPT Creating index QC_MSG_PK_I...
CREATE UNIQUE INDEX qc_msg_pk_i ON qc_run_msgs(msg_ivid)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_MSG_PK...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_pk
  PRIMARY KEY(msg_ivid)
  USING INDEX qc_msg_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_MSG_UK1_I...
CREATE UNIQUE INDEX qc_msg_uk1_i ON qc_run_msgs(msg_irid, run_id_from)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_MSG_UK2_I...
CREATE UNIQUE INDEX qc_msg_uk2_i ON qc_run_msgs(run_id_from, qc_code, app_alias, object_owner, object_type, object_name)
TABLESPACE &&idx_ts
;

PROMPT Creating constraints QC_MSG_UK1...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_uk1
  UNIQUE (msg_irid, run_id_from)
  USING INDEX qc_msg_uk1_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraints QC_MSG_UK2...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_uk2
  UNIQUE (run_id_from, qc_code, app_alias, object_owner, object_type, object_name)
  USING INDEX qc_msg_uk2_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_MSG_MSG_FK...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_msg_fk
  FOREIGN KEY (msg_irid) 
  REFERENCES qc_run_msgs (msg_ivid)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_MSG_RUN_FROM_FK ...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_run_from_fk 
  FOREIGN KEY (run_id_from) 
  REFERENCES qc_runs (run_id)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_MSG_RUN_TO_FK...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_run_to_fk 
  FOREIGN KEY (run_id_to) 
  REFERENCES qc_runs (run_id)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_MSG_CHK_FK...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_chk_fk 
  FOREIGN KEY (qc_code) 
  REFERENCES qc_checks (qc_code)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_MSG_APP_FK...
ALTER TABLE qc_run_msgs ADD (
  CONSTRAINT qc_msg_app_fk
  FOREIGN KEY (app_alias) 
  REFERENCES qc_apps (app_alias)
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_MSG_MSG_FK_I...
CREATE INDEX qc_msg_msg_fk_i ON qc_run_msgs(msg_irid)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_MSG_RUN_FROM_FK_I...
CREATE INDEX qc_msg_run_from_fk_i ON qc_run_msgs(run_id_from)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_MSG_RUN_TO_FK_I...
CREATE INDEX qc_msg_run_to_fk_i ON qc_run_msgs(run_id_to)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_MSG_CHK_FK_I...
CREATE INDEX qc_msg_chk_fk_i ON qc_run_msgs(qc_code)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_MSG_APP_FK_I...
CREATE INDEX qc_msg_app_fk_i ON qc_run_msgs(app_alias)
TABLESPACE &&idx_ts
;

PROMPT Creating sequence QC_MSG_SEQ...
CREATE SEQUENCE qc_msg_seq
;

PROMPT Creating table QC_RUN_STATS...
CREATE TABLE qc_run_stats (
   stat_ivid    NUMBER         CONSTRAINT qc_stat_stat_ivid_nn NOT NULL
 , stat_irid    NUMBER         CONSTRAINT qc_stat_stat_irid_nn NOT NULL
 , run_id_from  NUMBER         CONSTRAINT qc_stat_run_id_from_nn NOT NULL
 , run_id_to    NUMBER         NULL
 , qc_code      VARCHAR2(10)   CONSTRAINT qc_stat_qc_code_nn NOT NULL
 , app_alias    VARCHAR2(10)   CONSTRAINT qc_stat_app_alias_nn NOT NULL
 , object_owner VARCHAR2(30)   CONSTRAINT qc_stat_object_owner_nn NOT NULL
 , object_type  VARCHAR2(35)   CONSTRAINT qc_stat_object_type_nn NOT NULL
 , object_count NUMBER         CONSTRAINT qc_stat_object_count_nn NOT NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_RUN_STATS...
COMMENT ON TABLE qc_run_stats IS 'Quality check run statistics'
;

COMMENT ON COLUMN qc_run_stats.stat_ivid IS 'Internal stat version id'
;

COMMENT ON COLUMN qc_run_stats.stat_irid IS 'Internal start record id'
;

COMMENT ON COLUMN qc_run_stats.run_id_from IS 'Id of the run which created the statistic'
;

COMMENT ON COLUMN qc_run_stats.run_id_to IS 'Id of the run which closed the statistic'
;

COMMENT ON COLUMN qc_run_stats.qc_code IS 'Code of the quality check'
;

COMMENT ON COLUMN qc_run_stats.app_alias IS 'Application alias'
;

COMMENT ON COLUMN qc_run_stats.object_owner IS 'Object owner'
;

COMMENT ON COLUMN qc_run_stats.object_type IS 'Object type'
;

COMMENT ON COLUMN qc_run_stats.object_count IS 'Object count'
;

PROMPT Creating index QC_STAT_PK_I...
CREATE UNIQUE INDEX qc_stat_pk_i ON qc_run_stats(stat_ivid)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_STAT_PK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_pk
  PRIMARY KEY(stat_ivid)
  USING INDEX qc_stat_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_STAT_UK1_I...
CREATE UNIQUE INDEX qc_stat_uk1_i ON qc_run_stats(stat_irid, run_id_from)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_STAT_UK2_I...
CREATE UNIQUE INDEX qc_stat_uk2_i ON qc_run_stats(run_id_from, qc_code, app_alias, object_owner, object_type)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_STAT_UK1...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_uk1
  UNIQUE (stat_irid, run_id_from)
  USING INDEX qc_stat_uk1_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_UK2...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_uk2
  UNIQUE (run_id_from, qc_code, app_alias, object_owner, object_type)
  USING INDEX qc_stat_uk2_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_STAT_FK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_stat_fk
  FOREIGN KEY (stat_irid) 
  REFERENCES qc_run_stats (stat_ivid)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_RUN_FROM_FK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_run_from_fk 
  FOREIGN KEY (run_id_from) 
  REFERENCES qc_runs (run_id)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_RUN_TO_FK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_run_to_fk 
  FOREIGN KEY (run_id_to) 
  REFERENCES qc_runs (run_id)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_CHK_FK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_chk_fk 
  FOREIGN KEY (qc_code) 
  REFERENCES qc_checks (qc_code)
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_STAT_APP_FK...
ALTER TABLE qc_run_stats ADD (
  CONSTRAINT qc_stat_app_fk 
  FOREIGN KEY (app_alias) 
  REFERENCES qc_apps (app_alias)
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_STAT_STAT_FK_I...
CREATE INDEX qc_stat_stat_fk_i ON qc_run_stats(stat_irid)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_STAT_RUN_FROM_FK_I...
CREATE INDEX qc_stat_run_from_fk_i ON qc_run_stats(run_id_from)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_STAT_RUN_TO_FK_I...
CREATE INDEX qc_stat_run_to_fk_i ON qc_run_stats(run_id_to)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_STAT_CHK_FK_I...
CREATE INDEX qc_stat_chk_fk_i ON qc_run_stats(qc_code)
TABLESPACE &&idx_ts
;

PROMPT Creating index QC_STAT_APP_FK_I...
CREATE INDEX qc_stat_app_fk_i ON qc_run_stats(app_alias)
TABLESPACE &&idx_ts
;

PROMPT Creating sequence QC_STAT_SEQ...
CREATE SEQUENCE qc_stat_seq
;

PROMPT Creating table QC_RUN_LOGS...
CREATE TABLE qc_run_logs (
   run_id       NUMBER         CONSTRAINT qc_log_run_id_nn NOT NULL
 , line         NUMBER         CONSTRAINT qc_log_line_nn NOT NULL
 , text         VARCHAR2(4000) NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating comments on table QC_RUN_LOGS...
COMMENT ON TABLE qc_run_logs IS 'Quality check run logs'
;

COMMENT ON COLUMN qc_run_logs.run_id IS 'Id of the run for which logs are recorded'
;

COMMENT ON COLUMN qc_run_logs.line IS 'Log line (within run)'
;

COMMENT ON COLUMN qc_run_logs.text IS 'Log text'
;

PROMPT Creating index QC_LOG_PK_I...
CREATE UNIQUE INDEX qc_log_pk_i ON qc_run_logs(run_id, line)
TABLESPACE &&idx_ts
;

PROMPT Creating constraint QC_LOG_PK...
ALTER TABLE qc_run_logs ADD (
  CONSTRAINT qc_log_pk
  PRIMARY KEY(run_id, line)
  USING INDEX qc_log_pk_i
  ENABLE VALIDATE
)
;

PROMPT Creating constraint QC_LOG_RUN_FK...
ALTER TABLE qc_run_logs ADD (
  CONSTRAINT qc_log_run_fk 
  FOREIGN KEY (run_id) 
  REFERENCES qc_runs (run_id)
  ENABLE VALIDATE
)
;

PROMPT Creating index QC_LOG_RUN_FK_I...
CREATE INDEX qc_log_run_fk_i ON qc_run_logs(run_id)
TABLESPACE &&idx_ts
;


