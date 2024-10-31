ALTER TABLE dpp_schemas
MODIFY ste_name NULL;

ALTER TABLE dpp_instances
DROP CONSTRAINT ite_uk1;

DROP INDEX ite_uk1_i;
