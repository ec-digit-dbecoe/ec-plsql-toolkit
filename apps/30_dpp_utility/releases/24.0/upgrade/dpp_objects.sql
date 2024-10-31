REM Your DDL and DML statements here!
--copied from 002_dpp_ddl.sql

ALTER TABLE dpp_schemas
DROP CONSTRAINT sma_uk2;

DROP INDEX sma_uk2_i;

CREATE UNIQUE INDEX sma_uk2_i ON
    dpp_schemas(
        functional_name
    ASC)
        TABLESPACE &&idx_ts;
        
ALTER TABLE dpp_schemas ADD CONSTRAINT sma_uk2 UNIQUE(functional_name);
