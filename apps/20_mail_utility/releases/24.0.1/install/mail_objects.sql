PROMPT Creating Sequences...
CREATE SEQUENCE mail_log_seq START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE mail_seq START WITH 1 INCREMENT BY 1;

PROMPT Creating table mail_types...
CREATE TABLE mail_types(
    typ_id       NUMBER
        CONSTRAINT mail_typ_typ_id_nn NOT NULL,
    descr        VARCHAR2(2000 CHAR)
        CONSTRAINT mail_typ_descr_nn NOT NULL,
    date_creat   DATE
        CONSTRAINT mail_typ_date_creat_nn NOT NULL,
    user_creat   VARCHAR2(128 CHAR)
        CONSTRAINT mail_typ_user_creat_nn NOT NULL,
    date_modif   DATE
        CONSTRAINT mail_typ_date_modif_nn NOT NULL,
    user_modif   VARCHAR2(128 CHAR)
        CONSTRAINT mail_typ_user_modif_nn NOT NULL
)
TABLESPACE &&tab_ts;

PROMPT Creating comments for table mail_types...
COMMENT ON TABLE mail_types IS
    'ENG: mail types / FRA: types de courriel';


COMMENT ON COLUMN mail_types.typ_id IS
    'ENG: mail type unique identifier (no sequence) / FRA: identifiant unique type courriel (pas de séquence)';

COMMENT ON COLUMN mail_types.descr IS
    'ENG: description / FRA: description';

COMMENT ON COLUMN mail_types.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN mail_types.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN mail_types.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN mail_types.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;


PROMPT Creating constraints on table mail_types...
ALTER TABLE mail_types ADD CONSTRAINT mail_typ_pk PRIMARY KEY(typ_id)
USING INDEX TABLESPACE &&idx_ts LOGGING;

PROMPT Creating table mail_logs...
CREATE TABLE mail_logs(
    mail_id           NUMBER
        CONSTRAINT mail_log_mail_id_nn NOT NULL,
    log_id            NUMBER
        CONSTRAINT mail_log_log_id_nn NOT NULL,
    log_date          TIMESTAMP WITH TIME ZONE
        CONSTRAINT mail_log_log_date_nn NOT NULL,
    operation         VARCHAR2(30 CHAR)
        CONSTRAINT mail_log_operation_nn NOT NULL,
    status            VARCHAR2(30 CHAR)
        CONSTRAINT mail_log_status_nn NOT NULL,
    additional_info   CLOB,
    date_creat        DATE
        CONSTRAINT mail_log_date_creat_nn NOT NULL,
    user_creat        VARCHAR2(128 CHAR)
        CONSTRAINT mail_log_user_creat_nn NOT NULL,
    date_modif        DATE
        CONSTRAINT mail_log_date_modif_nn NOT NULL,
    user_modif        VARCHAR2(128 CHAR)
        CONSTRAINT mail_log_user_modif_nn NOT NULL
)
TABLESPACE &&tab_ts LOGGING;

PROMPT Creating comments for table mail_logs...
COMMENT ON TABLE mail_logs IS
    'ENG: mails logs / FRA: logs des courriels';


COMMENT ON COLUMN mail_logs.mail_id IS
'ENG: mail unique identifier / FRA: identifiant unique courriel';


COMMENT ON COLUMN mail_logs.log_id IS
    'ENG: log unique identifier (sequence mail_log_seq) / FRA: identifiant unique log (séquence mail_log_seq)';

COMMENT ON COLUMN mail_logs.log_date IS
    'ENG: log date / FRA: date log';

COMMENT ON COLUMN mail_logs.operation IS
    'ENG: operation performed / FRA: opération effectuée';

COMMENT ON COLUMN mail_logs.status IS
    'ENG: operation status / FRA: état opération';

COMMENT ON COLUMN mail_logs.additional_info IS
    'ENG: additional info / FRA: info additionnelle';

COMMENT ON COLUMN mail_logs.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN mail_logs.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN mail_logs.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN mail_logs.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

PROMPT Creating constraints on table mail_log...
ALTER TABLE mail_logs
    ADD CONSTRAINT mail_log_pk PRIMARY KEY(log_id)
        USING INDEX TABLESPACE &&idx_ts LOGGING;

PROMPT Creating table mails...
CREATE TABLE mails(
    mail_id                     INTEGER
        CONSTRAINT mail_mail_id_nn NOT NULL,
    typ_id                      INTEGER
        CONSTRAINT mail_typ_id_nn NOT NULL,
    subject                     VARCHAR2(2000 CHAR)
        CONSTRAINT mail_subject_nn NOT NULL,
    mail_from                   VARCHAR2(2000 CHAR)
        CONSTRAINT mail_mail_from_nn NOT NULL,
    mail_to                     VARCHAR2(2000 CHAR)
        CONSTRAINT mail_mail_to_nn NOT NULL,
    cc                          VARCHAR2(2000 CHAR),
    bcc                         VARCHAR2(2000 CHAR),
    content                     CLOB
        CONSTRAINT mail_content_nn NOT NULL,
    mail_mime_type              VARCHAR2(256 CHAR)
        CONSTRAINT mail_mail_mime_type_nn NOT NULL,
    clob_attachment             CLOB,
    raw_attachment              RAW(2000),
    attachment_mime_type        VARCHAR2(256 CHAR),
    attachment_file_name        VARCHAR2(2000 CHAR),
    content_transfer_encoding   VARCHAR2(256 CHAR),
    status                      VARCHAR2(30 CHAR)
        CONSTRAINT mail_status_nn NOT NULL,
    force_send_flag             CHAR(1 CHAR)
        CONSTRAINT mail_force_send_flag_nn NOT NULL,
    inline_attachment_flag      CHAR(1 CHAR),
    priority                    INTEGER
        CONSTRAINT mail_priority_nn NOT NULL,
    date_creat                  DATE
        CONSTRAINT mail_date_creat_nn NOT NULL,
    user_creat                  VARCHAR2(128 CHAR)
        CONSTRAINT mail_user_creat_nn NOT NULL,
    date_modif                  DATE
        CONSTRAINT mail_date_modif_nn NOT NULL,
    user_modif                  VARCHAR2(128 CHAR)
        CONSTRAINT mail_user_modif_nn NOT NULL
)
TABLESPACE &&tab_ts LOGGING;

PROMPT Creating comments for table mails...
COMMENT ON TABLE mails IS
    'ENG: mails generated by the application / FRA: courriels générés par l''application';

COMMENT ON COLUMN mails.mail_id IS
    'ENG: mail unique identifier (sequence mail_seq) / FRA: identifiant unique courriel (séquence mail_seq)';

COMMENT ON COLUMN mails.typ_id IS
    'ENG: mail type unique identifier / FRA: identifiant unique type courriel';

COMMENT ON COLUMN mails.subject IS
    'ENG: mail subject / FRA: sujet courriel';

COMMENT ON COLUMN mails.mail_from IS
    'ENG: sender / FRA: expéditeur';

COMMENT ON COLUMN mails.mail_to IS
    'ENG: recipients / FRA: destinataires';

COMMENT ON COLUMN mails.cc IS
    'ENG: cc / FRA: en copie';

COMMENT ON COLUMN mails.bcc IS
    'ENG: bcc / FRA: en copie cachée';

COMMENT ON COLUMN mails.content IS
    'ENG: content / FRA: contenu';

COMMENT ON COLUMN mails.mail_mime_type IS
    'ENG: mail mime type / FRA: type mime du courriel';

COMMENT ON COLUMN mails.clob_attachment IS
    'ENG: clob attachment / FRA: pièce jointe au format clob';

COMMENT ON COLUMN mails.raw_attachment IS
    'ENG: raw attachment / FRA: pièce jointe au format brut';

COMMENT ON COLUMN mails.attachment_mime_type IS
    'ENG: attachment mime type / FRA: type mime du fichier attaché';

COMMENT ON COLUMN mails.attachment_file_name IS
    'ENG: name of the file to attach / FRA: nom du fichier à attacher';

COMMENT ON COLUMN mails.content_transfer_encoding IS
    'ENG: content transfer encoding / FRA: codage de transfert de contenu';

COMMENT ON COLUMN mails.status IS
    'ENG: mail status / FRA: état courriel';

COMMENT ON COLUMN mails.force_send_flag IS
    'ENG: indicates whether the mail should be send on non prod environment (Y/N) / FRA: indique s''il faut forcer l''envoi dans un environnement qui n''est pas la production (Y/N)'
    ;

COMMENT ON COLUMN mails.inline_attachment_flag IS
    'ENG: indicates whether the attachment is inline or not (Y/N) / FRA: indique si l''attachment est dans le corps du courriel (Y/N)'
    ;

COMMENT ON COLUMN mails.priority IS
    'ENG: priority / FRA: priorité';

COMMENT ON COLUMN mails.date_creat IS
    'ENG: audit column: date and time initially created / FRA: colonne d''audit: date de création de l''enregistrement';

COMMENT ON COLUMN mails.user_creat IS
    'ENG: audit column: user who initially created this record / FRA: colonne d''audit: utilisateur ayant créé l''enregistrement'
    ;

COMMENT ON COLUMN mails.date_modif IS
    'ENG: audit column: date and time last modified / FRA: colonne d''audit: date de la dernière modification de l''enregistrement'
    ;

COMMENT ON COLUMN mails.user_modif IS
    'ENG: audit column: user who last modified this record / FRA: colonne d''audit: dernier utilisateur ayant modifié l''enregistrement'
    ;

PROMPT Creating constraints on table mails...
ALTER TABLE mails
    ADD CONSTRAINT mail_pk PRIMARY KEY(mail_id)
        USING INDEX TABLESPACE &&idx_ts LOGGING;

ALTER TABLE mail_logs
    ADD CONSTRAINT mail_log_mail_fk FOREIGN KEY(mail_id)
        REFERENCES mails(mail_id)
    NOT DEFERRABLE;

ALTER TABLE mails
    ADD CONSTRAINT mail_mail_typ_fk FOREIGN KEY(typ_id)
        REFERENCES mail_types(typ_id);

PROMPT Creating indexes on table mails...
CREATE INDEX mail_log_mail_fk_i ON
    mail_logs(
        mail_id
    ASC)
        TABLESPACE &&idx_ts;


CREATE INDEX mail_mail_typ_fk_i ON
    mails(
        typ_id
    ASC)
        TABLESPACE &&idx_ts;