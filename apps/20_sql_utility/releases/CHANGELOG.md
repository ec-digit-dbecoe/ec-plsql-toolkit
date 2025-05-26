# 24.0.3 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan

# 24.0.2

### Bug fixes

* Fixed vulnerabilities identified by Fortify Static Code Analyzer

# 24.0.1

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR
* Unit of char column length is now explicitly set to CHAR for all columns

# 24.0

### Features

* Functions normalise_columns_list() and format_columns_list() are now exposed

# 23.0

### Features

* New package SQL_UTILITY_LIC with licence terms
* Added short header to each package spec and body with licence terms

# 1.0

### Features

* Initial version
