PROMPT Creating table log_output...
CREATE TABLE LOG_OUTPUT
(
  CONTEXT NUMBER                                NOT NULL,
  LINE  NUMBER                                  NOT NULL,
  TEXT  VARCHAR2(4000 CHAR)                     NULL
)
TABLESPACE &&tab_ts
;

PROMPT Creating indexes on log_output...
CREATE UNIQUE INDEX LOU_PK ON LOG_OUTPUT(context, LINE)
TABLESPACE &&idx_ts
;

PROMPT Creating constraints on log_output...
ALTER TABLE LOG_OUTPUT ADD (
  CONSTRAINT LOU_PK
 PRIMARY KEY
 (context, LINE)
    USING INDEX 
    TABLESPACE &&idx_ts
);
