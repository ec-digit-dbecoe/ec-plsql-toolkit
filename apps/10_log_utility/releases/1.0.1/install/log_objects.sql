PROMPT Creating table log_output...
CREATE TABLE LOG_OUTPUT
(
  CONTEXT NUMBER                                NOT NULL,
  LINE  NUMBER                                  NOT NULL,
  TEXT  VARCHAR2(4000 BYTE)                     NULL
)
TABLESPACE &&tab_ts
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          56K
            NEXT             64K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
;

PROMPT Creating indexes on log_output...
CREATE UNIQUE INDEX LOU_PK ON LOG_OUTPUT
(context, LINE)
LOGGING
TABLESPACE &&idx_ts
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          56K
            NEXT             64K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
;

PROMPT Creating constraints on log_output...
ALTER TABLE LOG_OUTPUT ADD (
  CONSTRAINT LOU_PK
 PRIMARY KEY
 (context, LINE)
    USING INDEX 
    TABLESPACE &&idx_ts
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          56K
                NEXT             64K
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
               ))
;
