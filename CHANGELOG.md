# [25.6.0](https://sdlc.aws.cloud.tech.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/compare/25.5.1...25.6.0) (2025-09-22)


### Features

* create Tookit 25.6 including DPP 25.0 ([3addda7](https://sdlc.aws.cloud.tech.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/commit/3addda77ddb56878e2984a237852d6a2f5042e3b))
* update Toolkit 25.6 with DPP 25.0 bug fixes ([4fc3b10](https://sdlc.aws.cloud.tech.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/commit/4fc3b100b7b3e7ff6cd799690ea2fee840a3ef61))
* update Toolkit 25.6 with DPP 25.0 bug fixes ([b9a82c5](https://sdlc.aws.cloud.tech.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/commit/b9a82c504ffde152d55ba85f1fb00aab9fce3f66))

## [25.5.1](https://sdlc.webcloud.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/compare/25.5.0...25.5.1) (2025-07-07)


### Bug Fixes

* DS 25.4.1: fix bugs in demo scripts + add transportation scenario 0 ([efaf6bf](https://sdlc.webcloud.ec.europa.eu/dbe-coe/oracle-toolkit/ec-plsql-toolkit/commit/efaf6bf253fc675c0472389da06986cf98b5bafa))

# 25.5 (2025-05-xx)

### Features

* QC 25.0: Adapted SonarQube external issues report to new JSON format.

# 25.4 (2025-04-xx)

### Features

* DS 25.4: Transparent data encryption at rest

# 25.3 (2025-03-xx)

### Features

* DS 25.3: Miscellaneous minor enhancements.

# 25.2 (2025-02-xx)

### Features

* DS 25.2: Added support for MERGE INTO, INSERT IGNORE, and remote DELETE.

# 25.1 (2025-02-xx)

### Features

* DBM 25.1: The integrity of distributed files can now be checked thanks to trusted hashes.
* DS 25.1: Runs of main data set operations are now logged.

# 25.0 (2025-01-xx)

### Bug fixes

* DS 25.0: Bug fixing (tool was not properly working when installed in a central schema).
* DBM 25.0: Bug fixing (see DBM release notes for details).

### Features

* DBM tool now requires SELECT ANY DICTIONARY system privilege to install.
* All tools must always be concealed then exposed again after their migration.

# 24.11 (2024-12-xx)

### Features

* DBM 24.10: New export/import commands.
* DPP/DS/QC: Implemented export/import of configuration data.

# 24.10.1 (2024-11-xx)

### Bug fixes

* DPP 24.3.2: Default email recipient address correctly used.

# 24.10 (2024-11-xx)

### Features

* DBM 24.9: Removed 32k file size limit for scripts and configuration files.

### Bug fixes

* DS 24.2.2: Fixed issue with differed remote sequence masking and regression.

# 24.9 (2024-10-xx)

### Bug fixes

* ALL: Added explicit AUTHID DEFINER to all packages and types to avoid vulnerability warnings.
* ARM 24.0.1: Vulnerability bug fixed.
* DPP 24.2.1: Vulnerability bugs fixed, logging bug fixed.
* DBM 24.8.4: Unable to guess current version when some objects are included conditionally.

### Features

* HTTP 24.0: New utility.
* DPP 24.3: Monitoring post-actions, HTTP/GitLab requests.

# 24.8 (2024-08-xx)

### Features

* DS 24.2: Added support for FF3 Format-Preserving Encryption algorithm.
* DPP 24.2: Logging improvement, data model improvement, reporting mail improvement, methods renaming, increased number of job executions a day, database links check, deployment streamlining, new configuration data management API, new job options.

### Bug fixes

* Fixed vulnerabilities identified by Fortify Static Code Analyzer (in ARM, DS, DPP, GEN, MAIL, QC, and SQL utilities).
* DBM 24.8.2: "migrate-dbm" SQL script was looping in case of 2 consecutive incremental releases.
* GEN 24.0.2: Macros were substituted despite the "#nomacro" directive.
* DPP 24.2: Table space remapping bug fixed, no-drop objects bug fixed, removing the useless client schemas privileges, old file removing bug fixed.

### Features

* DBM 24.8: Added conditional statements execution and recovery from last executed statement.
* DBM 24.8.1: Names of temporary files are now prefixed with a tilde (~).
* DBM 24.8.2: "show-current" command now shows whether current version is old or up to date.

# 24.7 (2024-07-xx)

### Features

* DBM 24.7: Added ability to check privileges required at runtime.
* New technical guide for the developers of the PL/SQL toolkit.
* Converted DS User's Guides from MS Word to MarkDown.
* DBM tool is now installed/upgraded upon first launch of dbm-cli after unzip.

### Bug fixes

* NLS_LANG is now forced to .UTF8 in shell scripts, even when already set at OS level.
* Unit of char column length is now explicitly set to CHAR instead of using DB default.
  Fixed in following utilities:
  . DBM 24.6.1
  . DS 24.1.1
  . LOG 24.0
  . DOC 24.1.1
  . MAIL 24.0.1
  . DPP 24.1.1
  . QC 24.0

# 24.6 (2024-06-xx)

### Features

* DBM Utility 24.6
* DS Utility 24.1
* ZIP Utility 24.1
* DOC Utility 24.1

### Bug fixes

* Setup of QC Utility was crashing (fixed in the toolkit, no new release of QC).
* DBM Utility 24.6

# 24.5 (2024-05-xx)

### Features

* DBM Utility 24.5

# 24.x (x: 4..0)

### Features

* DBM Utility 24.x
