# 24.1.2 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan.

# 24.1.1

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR. Unit of char column length is now explicitly set to CHAR for all columns.

# 24.1

### Features

* Code adapted to new version of ZIP_UTIL_PKG.

# 24.0

### Bug fixes

* Restored non-ASCII characters that were lost since version 21.1.

# 23.0

### Features

* New package DOC_UTILITY_LIC that includes licence terms.
* All existing package modified to include a short header with licence terms.

# 21.1

### Features

* Internal refactoring: make code compliant with DBCC naming conventions and Trivadis best coding practices.
