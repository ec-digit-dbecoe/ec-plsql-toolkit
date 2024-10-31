CREATE TABLE sec_crypto_credentials (
   username VARCHAR2(60 BYTE)
 , password VARCHAR2(256 BYTE)
)
TABLESPACE &&tab_ts
;

CREATE UNIQUE INDEX sec_cre_pk ON sec_crypto_credentials(username)
TABLESPACE &&idx_ts
;

ALTER TABLE sec_crypto_credentials ADD (
  CONSTRAINT sec_cre_pk
  PRIMARY KEY(username)
  USING INDEX sec_cre_pk
  ENABLE VALIDATE
)
;

CREATE TABLE sec_crypto_secrets(
   username VARCHAR2(128 BYTE)
 , secret RAW(128)
)
;

CREATE UNIQUE INDEX sec_sec_pk ON sec_crypto_secrets(username)
TABLESPACE &&idx_ts
;

ALTER TABLE sec_crypto_secrets ADD (
   CONSTRAINT sec_sec_pk
   PRIMARY KEY(username)
   USING INDEX sec_sec_pk
   ENABLE VALIDATE
)
;

ALTER TABLE sec_crypto_secrets ADD (
   CONSTRAINT sec_sec_cre_fk
   FOREIGN KEY (username)
   REFERENCES sec_crypto_credentials (username)
   ENABLE VALIDATE
)
;