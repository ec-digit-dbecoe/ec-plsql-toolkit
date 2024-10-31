# EC PL/SQL Toolkit

## Overview

The EC PL/SQL toolkit is a suite of PL/SQL tools or utilities that have been developed within the Commission, by database experts, for database developers. They have been developed over the years to fulfil concrete needs of real information system development projects.

Here follows the list of tools included in the toolkit together with a short description and link(s) to their documentation.

### Core Utilities

| Tool | Name | Short Description | Manual(s) |
| ---- |----- | ----------------- | ------- |
| DBM | Data Base Migration Utility | Database migration tool similar to Liquibase and Flyway but more database developer oriented. | [User's Guide](apps/05_dbm_utility/doc/dbm_utility.md ) |
| DOC | Mail Merge Utility | Produce documents based on templates and access data based on the DAPL language. | [User's Guide](apps/20_doc_utility/doc/doc_utility.md) |
| DPP | Data Pump Utility | Add-on to the Oracle Data Pump utility. | [User's Guide](apps/30_dpp_utility/doc/dpp_utility.md) |
| DS | Data Set Utility | Data sub-setting and transportation, Sensitive data discovery and masking, Synthetic data generator, Change data capture. | [Data Masking](apps/10_ds_utility/doc/ds_utility_data_masking.md) / [Data Subsetting](apps/10_ds_utility/doc/ds_utility_data_subsetting.md) / [Synthetic Data Generation](apps/10_ds_utility/doc/ds_utility_synthetic_data_generation.md) / [Reference Manual](apps/10_ds_utility/doc/ds_utility_ref_manual.md) / [Demo Guide](apps/10_ds_utility/doc/ds_utility_demo.md) |
| GEN | Code Generator | PL/SQL code generator to boost developer's productivity and industrialise solutions. | [User's Guide](apps/10_gen_utility/doc/gen_utility.md) |
| QC | Quality Check Utility | Check database design best practices amongst which naming conventions of database objects. | [User's Guide](apps/30_qc_utility/doc/qc_utility.md) |

### Supporting Utilities

| Tool | Name | Short Description | Manual(s) |
| ---- |----- | ----------------- | ------- |
| ARM | Archive Management Utility | Utility to pack several files into a single one to ease data transportation (used by the DPP). | [User's Guide](apps/10_arm_utility/doc/arm_utility.md) |
| DDL | DDL Utility | Miscellaneous useful DDL routines. | none |
| LOG | Logging Utility | Library to log error, warning, information, and debug messages. | none |
| MAIL | Mailing Utility | Send emails with attachments from within the database. | none |
| SEC | Security Utility | Solution to store password securely into the database. | [User's Guide](apps/10_sec_utility/doc/sec_utility.md) |
| SQL | SQL Utility | Miscellaneous useful  SQL routines. | none |
| ZIP | Zip Utility | Read and write standard zip files. | none |

## Installation

See [Installation guide](doc/ec_plsql_toolkit_installation_guide.md).

## Contribution

See [Contribution guidelines](contributing-guidelines.md).

## License

See [Licence file](LICENCE.txt).

## Notice

See [Notice file](NOTICE.txt).
