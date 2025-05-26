# 25.0 (2025-05-xx)

### Features

* Adapted SonarQube external issues report to new JSON format.

# 24.0.2 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan.

# 24.0.1 (2024-08-xx)

### Bug fixes

* Fixed vulnerabilities identified by Fortify Static Code Analyzer.

# 24.0

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR.
* Unit of char column length is now explicitly set to CHAR for all columns.

# 23.2.1

### Bug fixes

* QC000: Updates to database objects were no more detected (since v1.2) while ok for created/dropped objects

# 23.2

### Bug fixes

* Some identifiers were not detected by QC019 (query was refactored)

### Features

* Added support for PROCEDURE, FUNCTION and LABEL identifiers

# 23.1

### Features

* Included short header with licence terms in each existing package spec and body
* New package QC_UTLITY_LIC containing licence terms

# 23.0

### Features

* QC022: Standalone procedures and functions are not allowed

# 22.1

### Features

* Added support for quality check multiple apps and schemas

# 22.0

### Bug fixes

* Changes related to "app_alias" parameter (optional)
* Correction of performance problem related to QC019 (PLScope compiling)
* Changes of the defaulted routine QC019 depending on the environment involved
* Changes in QC_UTILITY_KRN package to return the version from QC_SCHEMA_VERSION table
* Corrections in the documentation section "3.Quick Start"

# 21.1

### Features

* QC021: Redundant primary/unique key constraints

# 21.0

### Features

* QC020: Object names must not match anti-patterns
* Added APIs to manipulate object type patterns and dictionary entries
* QC008: Added check of not null constraint names (requires Oracle 12c)

# 20.0.2

### Bug fixes

* QC019: Naming conventions were applied to record fields while they should not

# 20.0.1

### Bug fixes

* Replaced "db_unique_name" (returning CDB) with "db_name" (returning PDB)
* Fixed some non-compliances with Trivadis guidelines reported by SonarQube
* Invalid objects were wrongly reported by QC012 as filtering patterns were not used
