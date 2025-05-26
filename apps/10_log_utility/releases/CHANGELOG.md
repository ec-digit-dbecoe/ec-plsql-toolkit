# 24.0.1 (2024-10-xx)

### Bug fixes

* Added explicit AUTHID DEFINER to all packages to avoid warnings during vulnerability scan.

# 24.0 (2024-07-xx)

### Bug fixes

* Table checksum was wrong when default unit for char column length was CHAR. Unit of char column length is now explicitly set to CHAR for all columns.

# 23.0 (23-xx-xx)

### Features

* Initial version
