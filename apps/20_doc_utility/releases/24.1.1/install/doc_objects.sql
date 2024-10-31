REM 
REM Creating DOC Utility structure
REM 

CREATE TABLE doc_templates (
   tpl_id     NUMBER(10) NOT NULL
 , dir_name   VARCHAR2(100 CHAR)
 , file_name  VARCHAR2(100 CHAR)
 , tpl_name   VARCHAR2(100 CHAR)
 , lang       VARCHAR2(3 CHAR)
 , content    BLOB
 , date_creat DATE
 , user_creat VARCHAR2(30 CHAR)
 , date_modif DATE
 , user_modif VARCHAR2(30 CHAR)
)
TABLESPACE &&tab_ts;

CREATE UNIQUE INDEX doc_tpl_pk ON doc_templates (tpl_id)
TABLESPACE &idx_ts
;

ALTER TABLE doc_templates ADD (
   CONSTRAINT doc_tpl_pk PRIMARY KEY (tpl_id) USING INDEX
);

CREATE SEQUENCE doc_tpl_seq
;

CREATE TABLE doc_documents (
   doc_id     NUMBER(10) NOT NULL
 , tpl_id     NUMBER(10)
 , doc_name   VARCHAR2(100 CHAR)
 , lang       VARCHAR2(3 CHAR)
 , content    BLOB
 , date_creat DATE
 , user_creat VARCHAR2(30 CHAR)
 , date_modif DATE
 , user_modif VARCHAR2(30 CHAR)
)
TABLESPACE &tab_ts
;

CREATE UNIQUE INDEX doc_doc_pk ON doc_documents (doc_id)
TABLESPACE &idx_ts
;

ALTER TABLE doc_documents ADD (
   CONSTRAINT doc_doc_pk PRIMARY KEY (doc_id) USING INDEX
)
;

ALTER TABLE doc_documents ADD (
   CONSTRAINT doc_doc_tpl_fk FOREIGN KEY (tpl_id)
   REFERENCES doc_templates (tpl_id)
)
;

CREATE SEQUENCE doc_doc_seq
;
