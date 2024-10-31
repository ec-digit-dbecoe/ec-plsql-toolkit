REM Your DDL and DML statements here!
--copied from 002_dpp_ddl.sql
CREATE OR REPLACE TYPE t_file_list IS
   TABLE OF VARCHAR2(255);
/

CREATE SEQUENCE dpp_jrn_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999999999999999999999999 MINVALUE 0 NOCACHE;

CREATE TABLE dpp_actions(
    sma_id            NUMBER NOT NULL,
    atn_usage         CHAR(1)NOT NULL,
    atn_type          VARCHAR2(8)NOT NULL,
    execution_order   NUMBER(2)NOT NULL,
    block_text        CLOB NOT NULL,
    active_flag       CHAR(1)NOT NULL,
    date_creat        DATE NOT NULL,
    user_creat        VARCHAR2(128)NOT NULL,
    date_modif        DATE NOT NULL,
    user_modif        VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_actions IS
    'ENG: PL/SQL block to be executed before/after automated export/import / FRA: bloc PL/SQL à exécuter avant/après l''exportation/importation automatisée'
    ;

COMMENT ON COLUMN dpp_actions.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_actions.atn_usage IS
    'ENG: import/export use type (I/E)/ FRA: indique s''il s''agit d''une action à exécuter lors de l''importation ou lors de l''exportation (I/E)'
    ;

COMMENT ON COLUMN dpp_actions.atn_type IS
    'ENG: prefix or postfix action / FRA: indique s''il faut exécuter le bloc avant ou après l''opération';

COMMENT ON COLUMN dpp_actions.execution_order IS
    'ENG: order of block execution / FRA: ordre d''exécution du bloc';

COMMENT ON COLUMN dpp_actions.block_text IS
    'ENG: block code / FRA: code du bloque';

COMMENT ON COLUMN dpp_actions.active_flag IS
    'ENG: is the block active flag (Y/N) / FRA: indique si le bloc est activé ou pas (Y/N)';

COMMENT ON COLUMN dpp_actions.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_actions.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_actions.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_actions.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX atn_pk_i ON
    dpp_actions(
        sma_id
    ASC,
        atn_usage
    ASC,
        atn_type
    ASC,
        execution_order
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_actions
    ADD CONSTRAINT atn_pk PRIMARY KEY(sma_id,
                                      atn_usage,
                                      atn_type,
                                      execution_order);
CREATE TABLE dpp_instances(
    ite_name          VARCHAR2(128)NOT NULL,
    descr_eng         VARCHAR2(2000)NOT NULL,
    descr_fra         VARCHAR2(2000)NOT NULL,
    production_flag   CHAR(1),
	env_name          VARCHAR2(128) NOT NULL,
    date_creat        DATE NOT NULL,
    user_creat        VARCHAR2(128)NOT NULL,
    date_modif        DATE NOT NULL,
    user_modif        VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_instances IS
    'ENG: database instance / FRA: instance base de données';

COMMENT ON COLUMN dpp_instances.ite_name IS
    'ENG: database instance name / FRA: nom de l''instance base de données';

COMMENT ON COLUMN dpp_instances.descr_eng IS
    'ENG: english description / FRA: description en anglais';

COMMENT ON COLUMN dpp_instances.descr_fra IS
    'ENG: french description / FRA: description en français';

COMMENT ON COLUMN dpp_instances.production_flag IS
    'ENG: indicates whether this is a production instance (Y/N) / FRA: indique s''il s''agit d''une instance de production';

COMMENT ON COLUMN dpp_instances.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_instances.env_name IS 
    'ENG: environment name / FRA: nom de l''environnement';

COMMENT ON COLUMN dpp_instances.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_instances.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_instances.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX ite_pk_i ON
    dpp_instances(
        ite_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_instances ADD CONSTRAINT ite_pk PRIMARY KEY(ite_name);

CREATE UNIQUE INDEX ite_uk1_i ON DPP_INSTANCES(ite_name, env_name) TABLESPACE &&idx_ts;
alter table DPP_INSTANCES add constraints ite_uk1 UNIQUE (ite_name, env_name) USING INDEX ite_uk1_i;

CREATE TABLE dpp_job_logs(
    jrn_id   NUMBER NOT NULL,
    line     NUMBER(10)NOT NULL,
    jte_cd   VARCHAR2(10)NOT NULL,
    text     VARCHAR2(1000)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_job_logs IS
    'ENG: job detailed logs / FRA: logs détaillés des jobs exécutés';

COMMENT ON COLUMN dpp_job_logs.jrn_id IS
    'ENG: job run identifier / FRA: identifiant d''execution du job';

COMMENT ON COLUMN dpp_job_logs.line IS
    'ENG: log line number / FRA: n° de ligne du log';

COMMENT ON COLUMN dpp_job_logs.jte_cd IS
    'ENG: job code / FRA: code du job';

COMMENT ON COLUMN dpp_job_logs.text IS
    'ENG: log text / FRA: ligne de log';

CREATE UNIQUE INDEX jlg_pk_i ON
    dpp_job_logs(
        jrn_id
    ASC,
        jte_cd
    ASC,
        line
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_job_logs
    ADD CONSTRAINT jlg_pk PRIMARY KEY(jrn_id,
                                      jte_cd,
                                      line);

CREATE TABLE dpp_job_runs(
    jrn_id         NUMBER NOT NULL,
    jte_cd         VARCHAR2(10)NOT NULL,
    sma_id         NUMBER NOT NULL,
    status         VARCHAR2(3)NOT NULL,
    date_started   DATE NOT NULL,
    date_ended     DATE,
    date_creat     DATE NOT NULL,
    user_creat     VARCHAR2(128)NOT NULL,
    date_modif     DATE NOT NULL,
    user_modif     VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_job_runs IS
    'ENG: job execution history, including their status / FRA: historique des job exécutés avec leur statut';

COMMENT ON COLUMN dpp_job_runs.jrn_id IS
    'ENG: job run identifier (sequence dpp_jrn_seq) / FRA: identifiant d''execution du job (séquence dpp_jrn_seq)';

COMMENT ON COLUMN dpp_job_runs.jte_cd IS
    'ENG: batch code / FRA: code du batch';

COMMENT ON COLUMN dpp_job_runs.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_job_runs.status IS
    'ENG: batch run status / FRA: statut d''execution du batch';

COMMENT ON COLUMN dpp_job_runs.date_started IS
    'ENG: date the batch run started / FRA: date de démarrage de l''exécution du batch';

COMMENT ON COLUMN dpp_job_runs.date_ended IS
    'ENG: date the batch run ended / FRA: date de fin de l''exécution du batch';

COMMENT ON COLUMN dpp_job_runs.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_job_runs.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_job_runs.date_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

COMMENT ON COLUMN dpp_job_runs.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX jrn_pk_i ON
    dpp_job_runs(
        jrn_id
    ASC,
        jte_cd
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX jrn_jte_fk_i ON
    dpp_job_runs(
        jte_cd
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX jrn_sma_fk_i ON
    dpp_job_runs(
        sma_id
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_job_runs ADD CONSTRAINT jrn_pk PRIMARY KEY(jrn_id,
                                                           jte_cd);

CREATE TABLE dpp_job_types(
    jte_cd       VARCHAR2(10)NOT NULL,
    descr_eng    VARCHAR2(2000)NOT NULL,
    descr_fra    VARCHAR2(2000)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_job_types IS
    'ENG: job types / FRA: typologie des job';

COMMENT ON COLUMN dpp_job_types.jte_cd IS
    'ENG: job type code / FRA: code typologie du job';

COMMENT ON COLUMN dpp_job_types.descr_eng IS
    'ENG: english description / FRA: description en anglais';

COMMENT ON COLUMN dpp_job_types.descr_fra IS
    'ENG: french description / FRA: description en français';

COMMENT ON COLUMN dpp_job_types.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_job_types.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_job_types.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_job_types.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX jte_pk_i ON
    dpp_job_types(
        jte_cd
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_job_types ADD CONSTRAINT jte_pk PRIMARY KEY(jte_cd);

CREATE TABLE dpp_nodrop_objects(
    sma_id        NUMBER NOT NULL,
    object_name   VARCHAR2(128)NOT NULL,
    object_type   VARCHAR2(20)NOT NULL,
    active_flag   CHAR(1)NOT NULL,
    date_creat    DATE NOT NULL,
    user_creat    VARCHAR2(128)NOT NULL,
    date_modif    DATE NOT NULL,
    user_modif    VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_nodrop_objects IS
    'ENG: object not to be dropped by the datapump / FRA: objet à ne pas supprimer lors du datapump';

COMMENT ON COLUMN dpp_nodrop_objects.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_nodrop_objects.object_name IS
    'ENG: object name / FRA: nom de l''objet';

COMMENT ON COLUMN dpp_nodrop_objects.object_type IS
    'ENG: object type / FRA: type de l''objet';

COMMENT ON COLUMN dpp_nodrop_objects.active_flag IS
    'ENG: active (Y/N) / FRA: active (Y/N)';

COMMENT ON COLUMN dpp_nodrop_objects.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_nodrop_objects.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_nodrop_objects.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_nodrop_objects.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX ndt_pk_i ON
    dpp_nodrop_objects(
        object_name
    ASC,
        object_type
    ASC,
        sma_id
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX ndt_sma_fk_i ON
    dpp_nodrop_objects(
        sma_id
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_nodrop_objects
    ADD CONSTRAINT ndt_pk PRIMARY KEY(object_name,
                                      object_type,
                                      sma_id);

CREATE TABLE dpp_option_allowed_values(
    otn_name     VARCHAR2(30)NOT NULL,
    oav_value    VARCHAR2(1000)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_option_allowed_values IS
    'ENG: option allowed value / FRA: valeur possible pour l''option';

COMMENT ON COLUMN dpp_option_allowed_values.otn_name IS
    'ENG: option key name / FRA: nom de l''option';

COMMENT ON COLUMN dpp_option_allowed_values.oav_value IS
    'ENG: option key value / FRA: valeur de l''option';

COMMENT ON COLUMN dpp_option_allowed_values.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_option_allowed_values.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_option_allowed_values.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_option_allowed_values.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX oav_pk_i ON
    dpp_option_allowed_values(
        oav_value
    ASC,
        otn_name
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX oav_otn_fk_i ON
    dpp_option_allowed_values(
        otn_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_option_allowed_values ADD CONSTRAINT oav_pk PRIMARY KEY(oav_value,
                                                                        otn_name);

CREATE TABLE dpp_options(
    otn_name     VARCHAR2(30)NOT NULL,
    descr_eng    VARCHAR2(2000)NOT NULL,
    descr_fra    VARCHAR2(2000)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_options IS
    'ENG: export and import available option / FRA: option possible pour les exports et imports';

COMMENT ON COLUMN dpp_options.otn_name IS
    'ENG: option key name / FRA: nom de l''option';

COMMENT ON COLUMN dpp_options.descr_eng IS
    'ENG: english description / FRA: description en anglais';

COMMENT ON COLUMN dpp_options.descr_fra IS
    'ENG: french description / FRA: description en français';

COMMENT ON COLUMN dpp_options.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_options.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_options.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_options.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX otn_pk_i ON
    dpp_options(
        otn_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_options ADD CONSTRAINT otn_pk PRIMARY KEY(otn_name);

CREATE TABLE dpp_parameters(
    prr_name     VARCHAR2(30)NOT NULL,
    prr_value    VARCHAR2(1000)NOT NULL,
    descr_eng    VARCHAR2(2000)NOT NULL,
    descr_fra    VARCHAR2(2000)NOT NULL,
	ite_name     VARCHAR2(128),
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL,
    date_creat   DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_parameters IS
    'ENG: utility parameter / FRA: paramètre de l''outil';

COMMENT ON COLUMN dpp_parameters.prr_name IS
    'ENG: parameter name / FRA: nom du paramètre';

COMMENT ON COLUMN dpp_parameters.prr_value IS
    'ENG: parameter value / FRA: valeur du paramètre';

COMMENT ON COLUMN dpp_parameters.descr_eng IS
    'ENG: english description / FRA: description en anglais';

COMMENT ON COLUMN dpp_parameters.descr_fra IS
    'ENG: french description / FRA: description en français';
	
COMMENT ON COLUMN dpp_parameters.ite_name IS 
    'ENG: database instance name / FRA: nom de l''instance base de donnees';	

COMMENT ON COLUMN dpp_parameters.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_parameters.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_parameters.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

COMMENT ON COLUMN dpp_parameters.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

CREATE UNIQUE INDEX prr_uk1_i ON dpp_parameters(prr_name, ITE_NAME) TABLESPACE &&idx_ts;
alter table dpp_parameters add constraints prr_uk1 UNIQUE (prr_name, ITE_NAME) USING INDEX prr_uk1_i;

alter table dpp_parameters add constraints prr_ite_fk foreign key (ite_name) references DPP_INSTANCES(ite_name);
create index prr_ite_fk_i on dpp_parameters(ite_name) TABLESPACE &&idx_ts;

CREATE TABLE dpp_recipients(
    sma_id       NUMBER NOT NULL,
    email_addr   VARCHAR2(100)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_recipients IS
    'ENG: notifications recipient/ FRA: destinataire pour les notifications';

COMMENT ON COLUMN dpp_recipients.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_recipients.email_addr IS
    'ENG: E-mail address to notify/ FRA: Adresse e-mail à notifier';

COMMENT ON COLUMN dpp_recipients.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_recipients.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_recipients.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_recipients.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX rct_pk_i ON
    dpp_recipients(
        sma_id
    ASC,
        email_addr
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_recipients ADD CONSTRAINT rct_pk PRIMARY KEY(sma_id,
                                                             email_addr);

CREATE TABLE dpp_roles(
    rle_name     VARCHAR2(30)NOT NULL,
    descr_eng    VARCHAR2(2000)NOT NULL,
    descr_fra    VARCHAR2(2000)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT);

COMMENT ON TABLE dpp_roles IS
    'ENG: role / FRA: rôle';

COMMENT ON COLUMN dpp_roles.rle_name IS
    'ENG: role name / FRA: nom du rôle';

COMMENT ON COLUMN dpp_roles.descr_eng IS
    'ENG: english description / FRA: description en anglais';

COMMENT ON COLUMN dpp_roles.descr_fra IS
    'ENG: french description / FRA: description en français';

COMMENT ON COLUMN dpp_roles.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_roles.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_roles.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_roles.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX rle_pk_i ON
    dpp_roles(
        rle_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_roles ADD CONSTRAINT rle_pk PRIMARY KEY(rle_name);

CREATE TABLE dpp_schema_options(
    sma_id       NUMBER NOT NULL,
    otn_name     VARCHAR2(30)NOT NULL,
    stn_value    VARCHAR2(1000)NOT NULL,
    stn_usage    CHAR(1)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_schema_options IS
    'ENG: export and import option for each schema / FRA: option pour les exports et imports de chaque schéma';

COMMENT ON COLUMN dpp_schema_options.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_schema_options.otn_name IS
    'ENG: option key name / FRA: nom de l''option';

COMMENT ON COLUMN dpp_schema_options.stn_value IS
    'ENG: option key value / FRA: valeur de l''option';

COMMENT ON COLUMN dpp_schema_options.stn_usage IS
    'ENG: import/export use type (I/E)/ FRA: indique s''il s''agit d''une option à exécuter lors de l''importation ou lors de l''exportation (I/E)'
    ;

COMMENT ON COLUMN dpp_schema_options.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_schema_options.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_options.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_options.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX stn_pk_i ON
    dpp_schema_options(
        sma_id
    ASC,
        otn_name
    ASC,
        stn_value
    ASC,
        stn_usage
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX stn_otn_fk_i ON
    dpp_schema_options(
        otn_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_schema_options
    ADD CONSTRAINT stn_pk PRIMARY KEY(sma_id,
                                      otn_name,
                                      stn_value,
                                      stn_usage)
;

CREATE TABLE dpp_schema_relations(
    sma_id_from   NUMBER NOT NULL,
    sma_id_to     NUMBER NOT NULL,
    date_from     DATE NOT NULL,
    date_to       DATE,
    date_creat    DATE NOT NULL,
    user_creat    VARCHAR2(128)NOT NULL,
    date_modif    DATE NOT NULL,
    user_modif    VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_schema_relations IS
    'ENG: relation between schemas / FRA: relation entre schémas';

COMMENT ON COLUMN dpp_schema_relations.sma_id_from IS
    'ENG: from schema unique identifier / FRA: identifiant unique du schéma de départ';

COMMENT ON COLUMN dpp_schema_relations.sma_id_to IS
    'ENG: to schema unique identifier / FRA: identifiant unique du schéma lié';

COMMENT ON COLUMN dpp_schema_relations.date_from IS
    'ENG: begin of validity / FRA: début de validité';

COMMENT ON COLUMN dpp_schema_relations.date_to IS
    'ENG: end of validity / FRA: fin de validité';

COMMENT ON COLUMN dpp_schema_relations.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_schema_relations.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_relations.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_relations.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX srn_pk_i ON
    dpp_schema_relations(
        sma_id_from
    ASC,
        sma_id_to
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX sma_sma_to_fk_i ON
    dpp_schema_relations(
        sma_id_to
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_schema_relations ADD CONSTRAINT srn_pk PRIMARY KEY(sma_id_from,
                                                                   sma_id_to);

CREATE TABLE dpp_schema_types(
    ste_name     VARCHAR2(128)NOT NULL,
    date_creat   DATE NOT NULL,
    user_creat   VARCHAR2(128)NOT NULL,
    date_modif   DATE NOT NULL,
    user_modif   VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_schema_types IS
    'ENG: schemas typology / FRA: typologie des schémas';

COMMENT ON COLUMN dpp_schema_types.ste_name IS
    'ENG: schema type name / FRA: nom du type de schéma';

COMMENT ON COLUMN dpp_schema_types.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_schema_types.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_types.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schema_types.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX ste_pk_i ON
    dpp_schema_types(
        ste_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_schema_types ADD CONSTRAINT ste_pk PRIMARY KEY(ste_name);

CREATE TABLE dpp_schemas(
    sma_id            NUMBER NOT NULL,
    ite_name          VARCHAR2(128)NOT NULL,
    rle_name          VARCHAR2(30),
    ste_name          VARCHAR2(128)NOT NULL,
    functional_name   VARCHAR2(50)NOT NULL,
    sma_name          VARCHAR2(128)NOT NULL,
    production_flag   CHAR(1),
    date_from         DATE NOT NULL,
    date_to           DATE,
    date_creat        DATE NOT NULL,
    user_creat        VARCHAR2(128)NOT NULL,
    date_modif        DATE NOT NULL,
    user_modif        VARCHAR2(128)NOT NULL
)
PCTFREE 10 PCTUSED 40 TABLESPACE &&tab_ts LOGGING
    STORAGE(INITIAL 65536 NEXT 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL
    DEFAULT);

COMMENT ON TABLE dpp_schemas IS
    'ENG: schemas and dependencies / FRA: schéma avec ses dépendances';

COMMENT ON COLUMN dpp_schemas.sma_id IS
    'ENG: schema unique identifier / FRA: identifiant unique du schéma';

COMMENT ON COLUMN dpp_schemas.ite_name IS
    'ENG: database name / FRA: nom de la base de données';

COMMENT ON COLUMN dpp_schemas.rle_name IS
    'ENG: role name / FRA: nom du rôle';

COMMENT ON COLUMN dpp_schemas.ste_name IS
    'ENG: schema type name / FRA: nom du type de schéma';

COMMENT ON COLUMN dpp_schemas.functional_name IS
    'ENG: functional name / FRA: nom fonctionnel';

COMMENT ON COLUMN dpp_schemas.sma_name IS
    'ENG: schema name / FRA: nom du schéma';

COMMENT ON COLUMN dpp_schemas.production_flag IS
    'ENG: indicates whether this is a production schema (Y/N) / FRA: indique s''il s''agit d''une schema de production';

COMMENT ON COLUMN dpp_schemas.date_from IS
    'ENG: begin of validity / FRA: début de validité';

COMMENT ON COLUMN dpp_schemas.date_to IS
    'ENG: end of validity / FRA: fin de validité';

COMMENT ON COLUMN dpp_schemas.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN dpp_schemas.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schemas.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN dpp_schemas.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

CREATE UNIQUE INDEX sma_pk_i ON
    dpp_schemas(
        sma_id
    ASC)
        TABLESPACE &&idx_ts;

CREATE UNIQUE INDEX sma_uk2_i ON
    dpp_schemas(
        functional_name
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX sma_rle_fk_i ON
    dpp_schemas(
        rle_name
    ASC)
        TABLESPACE &&idx_ts;

CREATE INDEX sma_ste_fk_i ON
    dpp_schemas(
        ste_name
    ASC)
        TABLESPACE &&idx_ts;

ALTER TABLE dpp_schemas ADD CONSTRAINT sma_pk PRIMARY KEY(sma_id);

ALTER TABLE dpp_schemas ADD CONSTRAINT sma_uk2 UNIQUE(functional_name);

ALTER TABLE dpp_actions
    ADD CONSTRAINT atn_sma_fk FOREIGN KEY(sma_id)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_job_logs
    ADD CONSTRAINT jlg_jrn_fk FOREIGN KEY(jrn_id,
                                          jte_cd)
        REFERENCES dpp_job_runs(jrn_id,
                                jte_cd)
    NOT DEFERRABLE;

ALTER TABLE dpp_job_runs
    ADD CONSTRAINT jrn_jte_fk FOREIGN KEY(jte_cd)
        REFERENCES dpp_job_types(jte_cd)
    NOT DEFERRABLE;

ALTER TABLE dpp_job_runs
    ADD CONSTRAINT jrn_sma_fk FOREIGN KEY(sma_id)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_nodrop_objects
    ADD CONSTRAINT ndt_sma_fk FOREIGN KEY(sma_id)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_option_allowed_values
    ADD CONSTRAINT oav_otn_fk FOREIGN KEY(otn_name)
        REFERENCES dpp_options(otn_name)
    NOT DEFERRABLE;

ALTER TABLE dpp_recipients
    ADD CONSTRAINT rct_sma_fk FOREIGN KEY(sma_id)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_schemas
    ADD CONSTRAINT sma_ite_fk FOREIGN KEY(ite_name)
        REFERENCES dpp_instances(ite_name)
    NOT DEFERRABLE;

ALTER TABLE dpp_schemas
    ADD CONSTRAINT sma_rle_fk FOREIGN KEY(rle_name)
        REFERENCES dpp_roles(rle_name)
    NOT DEFERRABLE;

ALTER TABLE dpp_schema_relations
    ADD CONSTRAINT sma_sma_from_fk FOREIGN KEY(sma_id_from)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_schema_relations
    ADD CONSTRAINT sma_sma_to_fk FOREIGN KEY(sma_id_to)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;

ALTER TABLE dpp_schemas
    ADD CONSTRAINT sma_ste_fk FOREIGN KEY(ste_name)
        REFERENCES dpp_schema_types(ste_name)
    NOT DEFERRABLE;

ALTER TABLE dpp_schema_options
    ADD CONSTRAINT stn_otn_fk FOREIGN KEY(otn_name)
        REFERENCES dpp_options(otn_name)
    NOT DEFERRABLE;

ALTER TABLE dpp_schema_options
    ADD CONSTRAINT stn_sma_fk FOREIGN KEY(sma_id)
        REFERENCES dpp_schemas(sma_id)
    NOT DEFERRABLE;
