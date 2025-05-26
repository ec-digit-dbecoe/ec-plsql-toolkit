# 25.1 (2025-02-xx)

### Features

* The integrity of distributed files can now be checked thanks to trusted hashes.
* Most commands now accept a -help or -? option to show their usage (parameters and options).
* Execution of tampered migration files is now blocked unless -nohash-check option is specified.

# 25.0 (2025-01-xx)

### Bug fixes

* An exception was raised when parameter value was exceeding 100 characters.
* Database objects with non-uppercase name was incorrectly reported as missing during validation.
* Version status was sometimes incorrectly reported as VALID while it was INVALID (missing commit).
* DBM status was incorrectly reported as INVALID after upgrade via migrate-dbm shell script.

### Features

* Some messages are now displayed with colors if enabled via options or parameters.
* Privileges required for installation are now checked in migrate-dbm shell script.
* Tool now requires SELECT ANY DICTIONARY system privilege to install.

# 24.10 (2024-12-xx)

### Features

* Added ability to import/export app's configuration data.

# 24.9 (2024-11-xx)

### Features

* Remove 24kb file size limit for files read using base64 encoding (*.sql, *.dbm).
* New "conditional-statement-exec" parameter allowing to disable this functionality.
* File extension ".dbm.sql" that was enabling this feature is no more supported.

# 24.8.4 (2024-10-xx)

### Bug fixes

* Fixed regression (change of 24.8.2 was lost).
* Unable to guess current version when some objects are included conditionally.

# 24.8.3 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan.

# 24.8.2 (2024-08-xx)

### Bug fixes

* "migrate-dbm" SQL script was looping in case of 2 consecutive incremental releases.
* "migrate-dbm" shell script was looping when SQL*Plus could not parse its arguments.

### Features

* "show-current" command now show whether current version is old or up to date and which version is available for install or upgrade.

# 24.8.1 (2024-08-xx)

### Bug fixes

* An error was occuring when executing huge SQL scripts.

### Features

* Names of temporary files are now prefixed with a tilde (~)

# 24.8 (2024-07-xx)

### Features

* Added ability to recover from last executed statement in case of migration failure.
* Added conditional execution of statements in SQL scripts.
* New "-jump-to-statement" option for "migrate" command to jump to given statement.
* New "-skip-file" option for "migrate" command to skip given file name.

# 24.7 (2024-07-xx)

### Features

* Added ability to check privileges required by applications at runtime.
* Added support for PROMPT command in DBM files; other SQL*Plus commands are ignored.
* migrate-dbm shell scripts: current version can be forced instead of being detected. To proceed, pass current version as 2nd argument (1st argument is target version).

# 24.6.1 (2024-06-xx)

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR. Unit of char column length is now explicitly set to CHAR for all columns.

# 24.6 (2024-06-xx)

### Bug fixes

* Name of files reported as not found on the file system were sometimes wrong.

### Features

* Added support for checking privileges and roles required to migrate an app (via a "privileges.dbm" file placed in "apps//releases//config").
* New "-nostop" option for "precheck" command to continue in case of error (i.e., check requirements of all applications even if one fails to comply).

# 24.5 (2024-05-xx)

### Bug fixes

* DBM_ALL_APPLICATIONS view was not showing apps without a defined expose pattern.
* Target version passed as parameter to "migrate-dbm" script was ignored on Windows.
* File system scanning was not working properly on Windows WSL2 Ubuntu.

### Features

* New "-noscan" option for the "dbm-cli" shell script for a quick startup. Skip file system scanning and reading of apps config files and inventories.
* All commands now accept a list of (comma separated) apps instead of just one.
* An application alias can now be defined and used as an alternative to name.
* The "show" command now displays application "all" (the toolkit) and its version.
* Column "granted_flag" of DBM_ALL_APPLICATIONS view renamed to "exposed_flag".

# 24.4 (2024-05-xx)

### Bug fixes

* Uninstall scripts in the "all" folder of the application were executed twice.
* Version of dbm_utility was not set after migration with "migrate-dbm" script.
* Execution of scripts was not aborted upon OS errors (e.g., file not found). "whenever os_error exit failure rollback" has been added to abort execution.
* Exit code was incorrect and returning 0 in case of migration failure.

### Features

* New "-[no]stop-on-warning" option for "migrate" and "rollback" commands (default is -stop). Abort operation in case of recent compilation error (reported by SQL*Plus as a Warning).
* New "-noupgrade" option for "install" command for not doing any upgrade after install.
* New "-debug" option for some commands (will be extended progressively to all commands).
* Several commands (separated with a "/") can now be executed interactively or in batch.
* Command "best-guess" is deprecated and replaced with "guess -best" command and option.
* Grants on the DBM tool that cannot be revoked automatically without causing a deadlock are now shown so that they can be executed manually.
* View DBM_ALL_APPLICATIONS now shows all applications installed centrally plus an indication on those that are accessible by current user (granted_flag).

# 24.3 (2024-05-xx)

### Bug fixes

* The "conf_path" parameter to specify where the configuration file is located was not working properly.
* Typo (undesired extra character) in the "dbm-cli" script.

### Features

* New environment variables have been added to configure the tool:
  . DBM_CONF_PATH: configuration file path (default: conf/dbm_utility.conf)
  . DBM_APPS_DIR: applications directory (default: apps)
  . DBM_LOGS_DIR: logs directory (default: logs)
  . DBM_TMP_DIR: temporary directory (default: tmp)
* New possibility to specify command options: @dbm-cli  [options] [params] where options is "-option" or "-option=value".
* New "-novalidate" option to install/upgrade/migrate an application without validating it.
* New "-force" option to force the execution of uninstall scripts when reported not installed.
* New "migrate-dbm" shell script to migrate (install/upgrade) the DBM tool to its latest version.

# 24.2 (2024-05-xx)

### Features

* The DBM is now multi-schema i.e. it can be installed in a central schema and used by others.
* New "expose" command to create public/private synonyms and grant public/private access privileges.
* New "conceal" command to drop public/private synonyms and revoke public/private access privileges.

# 24.1 (2024-03-xx)

### Bug fixes

* Precheck and application dependency features are now documented.
* Migration of the DBM tool using itself now works smoothly.
* The "validate all" command now ignores apps that are not installed.
* The dependency check now works properly when a version is specified.
* Checksum is now correctly computed on lines ending with a mix of spaces and tabs.

### Features

* An optional condition can now be specified for each database object in the inventory file. A possible use case is to specify that a database object exists only in some environments.
* New "-silent" option to prevent information messages from being displayed.
* New "-nosplash" option to prevent the splash text from being displayed.
* New "best-guess-current" command to guess closest version when no exact match is found.
* New "make-inventory" command to make and save inventory of database objects.
* New "create-restore-point", "drop-restore-point" and "flash-database" to restore db.
* New "precheck" command to check that pre-conditions are fulfilled before any migration.
* Files with a ".java" extension are now executed when method is based on file naming conventions.
* Checksum of "java source" database objects is now computed based on the "user_source" view.
* Conditional execution of files is now implemented for validate and uninstall operations.
* Changed default sqlprefix from "#" to "~" to avoid conflicts with the GEN utility macro prefix.
* Several commands (separated with a slash) can now be passed in parameters of dbm-cli shell.
* Parameters are now persisted in the database (as variables).
* Info on applications, versions, files, db objects, parameters, and variables are now all persisted.
* Lines spooled in files are now trimmed.
* Public synonyms and privileges granted to public are now part of the db objects inventory.
* New "public" variable for enabling/disabling public db objects of the inventory.
* Run conditions can now be specified in all ".dbm" master files, in addition to "files.dbm".
* The "install" command no more perform upgrade of already installed applications.
* The "upgrade" command no more perform install of not installed applications.

# 24.0 (Initial version)

### Features

* Initial version
