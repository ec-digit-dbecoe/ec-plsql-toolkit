PROMPT Altering DBM_APPLICATIONS table...
ALTER TABLE dbm_applications$ ADD (
   app_alias VARCHAR2(30) NULL
);

COMMENT ON COLUMN dbm_applications$.app_alias IS 'Application alias';

UPDATE dbm_applications$ SET app_alias = app_code
;

ALTER TABLE dbm_applications$ MODIFY (
   app_alias NOT NULL
);

CREATE UNIQUE INDEX dbm_app_uk ON dbm_applications$ (owner, app_alias)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_applications$ ADD CONSTRAINT dbm_app_uk UNIQUE (owner, app_alias) USING INDEX
;

ALTER TABLE dbm_applications$ ADD (
   exposed_flag VARCHAR2(1) NULL -- Y/N
);

COMMENT ON COLUMN dbm_applications$.exposed_flag IS 'Exposed (Y/N)?';

PROMPT Re-creating view dbm_applications...
CREATE OR REPLACE VIEW dbm_applications(
  app_code
, app_alias
, seq
, ver_code
, ver_status
, home_dir
, exposed_flag
, deleted_flag
)
AS
SELECT app_code
     , app_alias
     , seq
     , ver_code
     , ver_status
     , home_dir
     , exposed_flag
     , deleted_flag
  FROM dbm_applications$
 WHERE owner = SYS_CONTEXT('USERENV', 'SESSION_USER')
WITH CHECK OPTION
;

PROMPT Re-creating view dbm_all_applications...
CREATE OR REPLACE VIEW dbm_all_applications(
  owner
, app_code
, app_alias
, seq
, ver_code
, ver_status
, home_dir
, exposed_flag
, deleted_flag
)
AS
SELECT DISTINCT app.owner
     , app.app_code
     , app.app_alias
     , app.seq
     , app.ver_code
     , app.ver_status
     , app.home_dir
     , app.exposed_flag
     , app.deleted_flag
  FROM dbm_applications$ app
 WHERE (app.owner = USER OR app.ver_code IS NOT NULL)
;

PROMPT Dropping some constraints and indexes...
ALTER TABLE dbm_files$ DROP CONSTRAINT dbm_fil_ver_fk
;

ALTER TABLE dbm_objects$ DROP CONSTRAINT dbm_obj_ver_fk
;

ALTER TABLE dbm_parameters$ DROP CONSTRAINT dbm_par_ver_fk
;

BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE dbm_versions$ DROP CONSTRAINT dbm_ver_pk';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE dbm_versions$ DROP CONSTRAINT dbm_ver_uk';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX dbm_ver_pk';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP INDEX dbm_ver_uk';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

PROMPT Re-creating dropped constraints and indexes...

CREATE UNIQUE INDEX dbm_ver_pk ON dbm_versions$ (owner, app_code, ver_code)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_pk PRIMARY KEY (owner, app_code, ver_code) USING INDEX
;

CREATE UNIQUE INDEX dbm_ver_uk ON dbm_versions$ (owner, app_code, ver_nbr)
TABLESPACE &&idx_ts
;

ALTER TABLE dbm_versions$ ADD CONSTRAINT dbm_ver_uk UNIQUE (owner, app_code, ver_nbr) USING INDEX
;

ALTER TABLE dbm_files$ ADD (
   CONSTRAINT dbm_fil_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
)
;

ALTER TABLE dbm_objects$ ADD (
   CONSTRAINT dbm_obj_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
)
;

ALTER TABLE dbm_parameters$ ADD (
   CONSTRAINT dbm_par_ver_fk FOREIGN KEY (owner, app_code, ver_code)
   REFERENCES dbm_versions$ (owner, app_code, ver_code)
);
