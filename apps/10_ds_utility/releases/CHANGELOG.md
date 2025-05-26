# 25.4 (2025-04-xx)

### Features

* Transparent data encryption at rest

# 25.3 (2025-03-xx)

### Features

* Added some demo scripts e.g., to show stats and reset demo.
* Added VAR package body to show and reset internal cache.
* Added default gen type and params to sensitive data types (patterns).
* Added distance from base record in records table.
* Enhanced debug info stored in ds_records.remark column.

# 25.2 (2025-02-xx)

### Features

* Now using MERGE INTO statement for improved performances.
* Added support for INSERT IGNORE (ignore existing records while inserting).
* Added support for remote delete (delete records in target schema).

# 25.1 (2025-02-xx)

### Features

* Runs of main data set operations are now logged.

# 25.0 (2025-01-xx)

### Bug fixes

* Tool was not working properly when installed in a central schema.
* Added missing FF3 Java sources and functions in the db object inventory.
* FF3 Java sources and functions are now dropped upon uninstallation.

### Features

* Replaced truncate table with delete in all demo scripts.
* Added "set serveroutput on size 99999" in all demo scripts.
* Sequences, types, java classes, and functions are now exposed to PUBLIC.

# 24.2.3 (2024-12-xx)

### Bug fixes

* 'NULL' string was wrongly replaced with NULL value when exporting data set as script.
* Constraints and indexes where sometimes displayed several times on Graphviz graphs.

# 24.2.2 (2024-12-xx)

### Bug fixes

* Fixed error "NULL index table key value" when using "differed remote sequence" masking.
* Fixed typo in one p_delete_flag parameter of insert_mask() procedure.
* Fixed error raised when inserting records involed in a recursive foreign key.

### Features

* When no PK is found, use any UK as an alternative.

# 24.2.1 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan.
* Record sequence number representing the extraction generation was not correctly computed.

# 24.2 (2024-08-xx)

### Features

* Added support for FF3 Format-Preserving Encryption algorithm.

# 24.1.2 (2024-08-xx)

### Bug fixes

* Fixed vulnerabilities identified by Fortify Static Code Analyzer.

# 24.1.1 (2024-08-xx)

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR. Unit of char column length is now explicitly set to CHAR for all columns.

### Features

* Required runtime privileges are now checked when main package is invoked.

# 24.1 (2024-06-xx)

### Features

* New encrypt/decrypt_integer() functions to encrypt/decrypt integers within a given range of integer values.

### Bug fixes

* n/a

### Features

* encrypt/decrypt_number() functions now accept negative numbers. Result was previously NULL.
* Data sets have been updated with free to use data + source documented.

# 24.0 (2024-04-xx)

### Features

* The entire data set configuration can now be shown on Graphviz diagrams.
* New option to enable/disable encryption of tokenized values at mask level.

### Bug fixes

* Update statements where sometime incorrectly generated in refresh mode (UI).
* Data generation and data masking were not working when the tool was not installed in the same schema.
* Data set backup demo script was not working properly.

### Features

* Demo scripts changed + new demonstration guide written in markdown language.
* Procedure handle_data_set() has been renamed to transport_data_set().
* Procedure include_path() has been renamed to execute_degpl().
* Data capture mode codes have been renamed.

# 23.4 (2023-12-xx)

### Features

* Added visualisation of data sets using GraphViz graphs (dot language).
* Added data set configuration using DEGPL (Data Extraction and Generation Path Language).

### Bug fixes

* Extract count was sometimes incorrect (records found via different paths were counted several times).
* Extract type parameter passed to include_referential_cons() was used for added tables instead of added constraints.
* Optimisation consisting to transform useless P-constraint to N-constraint was not entirely correct.
* For GEN data sets, number of generated records (extract_count) was incorrect in some cases.

# 23.3

### Features

* Added tokenization as an additional data masking technique

### Features

* Specific implementation of relocation of identifiers was replaced by data masking techniques:
  . Id shifting: replaced with SQL masking; column ds_tables.id_shift_value dropped.
  . Sequence: replaced with SEQUENCE masking; column ds_tables.sequence_name dropped.
  . Table ds_identifiers now linked to ds_masks.msk_id instead of ds_tables.table_id.
  . Procedure delete_data_set_identifiers() replaced with delete_identifiers().
  . Added differ_masking=[true|false] option to perform old/new id mapping in target schema.
* Specific implementation to force a value depending on operation (I/U/D) replaced with SQL masking:
  . Procedure force_column_value() removed.
  . Added support for INSERTING, UPDATING, DELETING and SELECTING keywords in SQL expressions
    These keywords are replaced with 1=1 (TRUE) or 1=0 (FALSE) depending on current operation.
* Improved performance of SQL masking when no other column is referenced in the SQL expression:
  . A join is no more necessary between FK and PK tables; SQL expression is just copied over.
* Removed SYSPER project specific code (obsolete anyway).
* Added "p_raise_error_when_no_update" parameter to all "update_xxx_properties()" procedures.
  . By default, raise an exception when no property was updated.
* Added "p_raise_error_when_no_insert" parameter to some "insert_xxx()" procedures.
  . By default, raise an exception when no record was inserted.
* SQL mask is no more applied to NULL values unless option "mask_null_values=true" is set.
* The following deprecated procedures have been removed: copy_data_set(), move_data_set(),
  handle_data_set_via_script(), export_data_set_via_script(), delete_data_set_via_script(),
  export_data_set_via_db_link().

### Bug fixes

* Encryption and/or decryption was not working properly when performed through database links
* Extraction as XML was not always working properly (Java null pointer exception)
* Extraction as scripts was not always working properly (rowid was prefixed with table alias twice)
* An error was raised when a table alias extracted from uk/pk was an Oracle reserved keyword.
  The full list from v$reserved_words is now checked instead of a few keywords.
* Error ORA-06502 was raised when passing a seed value with special characters.
  The problem was fixed by converting the seed value to the US7ASCII character set.

# 23.2.1

### Bug fixes

* There was a SQL syntax error (double column alias prefix) in generated scripts when masking SQL expression was containing ROWID
* Propagation of PK to optional FKs was not working properly (inner join was generated in the query instead of left outer join)
* An encryption key different from the one defined by end-user was used when transporting encrypted data via database link

### Features

* Added deleted_flag in ds_masks to logically delete records (for internal use)
* Added the possibility to add a ROWID# column in generated views to more easily compare masked and unmasked data (new "p_include_rowid" parameter in create_views())
* Shuffling, encryption and PK masking propagation is now supported when storing data as XML

# 23.2

### Features

* Synthetic data generation

# 23.1

### Features

* Sensitive data discovery and masking

### Features

* Renamed DS_UTILITY to DS_UTILITY_KRN

# 23.0

### Bug fixes

* Rename constraint out_pk to ds_out_pk
* Prefix query aliases with "ds_" to prevent alias collisions

# 22.0

### Bug fixes

* A table extracted partially (e.g. as a child of a parent table) could not be included as a base table afterwards

# 21.1

### Features

* Better detection of true master/detail relationships (identifying relationships)
* Removed dependency towards SYS_ALL% tables and SQL_UTILITY package

# 21.0

### Features

* Make use of the PL/SQL installer
