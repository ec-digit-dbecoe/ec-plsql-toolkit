CREATE OR REPLACE PACKAGE arm_util_krn 
AUTHID DEFINER
ACCESSIBLE BY (PACKAGE arm_main_krn)
IS
---
-- Copyright (C) 2023 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
--
/**
* Archive manager utility.
*
* v24.0; 2023-12-11; malmjea; initial version
*/

   /**
   * Return the names of files in a directory.
   *
   * @param p_directory: directory name
   * @param p_file_name_filter: file names filter
   * @return list of the file names
   * @throws arm_main_var.ge_inv_orcl_dir_name: invalid directory name
   * @throws arm_main_var.ge_orcl_dir_not_exist: directory does no exist
   */
   FUNCTION get_file_names(
        p_directory        IN VARCHAR2
      , p_file_name_filter IN VARCHAR2
   ) RETURN arm_main_var.arm_file_names_set;

END arm_util_krn;
/
