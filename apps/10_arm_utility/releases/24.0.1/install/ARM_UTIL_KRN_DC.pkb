CREATE OR REPLACE PACKAGE BODY arm_util_krn IS
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
* v24.0; 2023-12-12; malmjea; initial version
*/

   /**
   * Return the files of a directory.
   *
   * @param p_directory: directory name
   * @return files of the directory
   */
   FUNCTION get_dir_files(p_directory IN VARCHAR2) RETURN t_file_list IS
   LANGUAGE JAVA NAME
   'arm_toolkit.scanFiles(java.lang.String) return oracle.sql.ARRAY';


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
   ) RETURN arm_main_var.arm_file_names_set IS

      -- file names
      l_file_names arm_main_var.arm_file_names_set;


      -- directory file list
      l_dir_file_names     t_file_list;

      -- directory file index
      l_dir_file_idx       PLS_INTEGER;


  BEGIN

      -- Initialize file name collection.
      l_file_names := arm_main_var.arm_file_names_set();
      l_dir_file_idx    := 0;

      -- check directory name
      IF trim(p_directory) IS NULL THEN
         RAISE arm_main_var.ge_inv_orcl_dir_name;
      END IF;

      -- Browse the directory files.
      l_dir_file_names := get_dir_files(trim(p_directory));
      IF l_dir_file_names IS NOT NULL AND l_dir_file_names.COUNT > 0 THEN

         <<browse_dir_files>>
         FOR l_dir_file_name IN (
            SELECT column_value
              FROM TABLE(l_dir_file_names)
             ORDER BY column_value ASC
         ) LOOP

            -- Check whether the file name matches the filter.
            IF l_dir_file_name.column_value LIKE
               nvl(trim(p_file_name_filter) || '%', '%') THEN

               -- Add the file to the result.
               l_file_names.extend();
               l_file_names(l_file_names.LAST) := l_dir_file_name.column_value;

            END IF;

         END LOOP browse_dir_files;

      END IF;

      -- Return the list of files.
      RETURN l_file_names;

   END get_file_names;

END arm_util_krn;
/
