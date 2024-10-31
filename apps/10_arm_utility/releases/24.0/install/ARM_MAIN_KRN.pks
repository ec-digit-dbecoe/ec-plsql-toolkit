CREATE OR REPLACE PACKAGE arm_main_krn IS
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
* Archive manager.
*
* v24.0; 2023-12-12; malmjea; initial version
*/


   /**
   * Display a log message.
   *
   * @param p_message: message to be displayed
   */
   PROCEDURE log_msg(p_message IN VARCHAR2);

   /**
   * Initialize the Oracle directory.
   *
   * @param p_directory: database directory
   */
   PROCEDURE set_directory(p_directory IN arm_main_var.path_type);
   
   /**
   * Initialize the log file.
   *
   * @param p_log_file_name: log file name
   */
   PROCEDURE init_log_file(p_log_file_name IN arm_main_var.path_type);

   /**
   * Close the log file.
   */
   PROCEDURE close_log_file;

   /**
   * Compress a file.
   *
   * @param p_src_directory: source file directory
   * @param p_src_file: source file name
   * @param p_dst_directory: destination file directory
   * @param p_dst_file: destination file name
   * @throws arm_main_var.ge_inv_src_dir: invalid source directory
   * @throws arm_main_var.ge_inv_src_file: invalid source file name
   * @throws arm_main_var.ge_inv_dst_dir: invalid destination directory
   * @throws arm_main_var.ge_inv_dst_file; invalid destination file name
   */
   PROCEDURE compress_file(
        p_src_directory    IN arm_main_var.path_type
      , p_src_file         IN arm_main_var.path_type
      , p_dst_directory    IN arm_main_var.path_type
      , p_dst_file         IN arm_main_var.path_type
   );
      
   /**
   * Uncompress a file.
   *
   * @param p_src_directory: source file directory
   * @param p_src_file: source file name
   * @param p_dst_directory: destination file directory
   * @param p_dst_file: destination file name
   * @throws arm_main_var.ge_inv_src_dir: invalid source directory
   * @throws arm_main_var.ge_inv_src_file: invalid source file name
   * @throws arm_main_var.ge_inv_dst_dir: invalid destination directory
   * @throws arm_main_var.ge_inv_dst_file; invalid destination file name
   */
   PROCEDURE uncompress_file(
        p_src_directory    IN arm_main_var.path_type
      , p_src_file         IN arm_main_var.path_type
      , p_dst_directory    IN arm_main_var.path_type
      , p_dst_file         IN arm_main_var.path_type
   );

   /**
   * Reset the list of files.
   */
   PROCEDURE reset_files;

   /**
   * Add a file to the list.
   *
   * @param p_file_name: name of the file to be added
   * @param p_file_size: file size
   * @throws arm_main_var.ge_inv_file_name: invalid file name
   */
   PROCEDURE add_file(
        p_file_name  IN arm_main_var.path_type
      , p_file_size  IN PLS_INTEGER := 0
   );
   
   /**
   * DEBUG: Display the file list
   */
   PROCEDURE debug_display_files;

   /**
   * Build the list of files.
   *
   * @param p_file_name_prefix: file name prefix
   * @param p_file_extension: file extension
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_inv_file_prefix: invalid file name prefix
   * @throws arm_main_var.ge_dir_not_exist: directory does not exist
   */
   PROCEDURE build_file_list(
        p_file_name_prefix    IN VARCHAR2
      , p_file_extension      IN VARCHAR2 := NULL
   );

   /**
   * Concatenate the files in a single archive file.
   *
   * @param ps_file_name: archive file name
   * @throws arm_main_var.ge_inv_file_name: invalid file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_concat: no files to be concatenated
   */
   PROCEDURE concat_files(p_file_name IN arm_main_var.path_type);

   /**
   * Extract the files from the archive file.
   *
   * @param p_file_name: archive file name
   * @throws arm_main_var.ge_inv_file_name: invalid archive file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_extract: no file to be extracted
   */
   PROCEDURE extract_files(p_file_name IN arm_main_var.path_type);
   
   /**
   * Save the manifest file.
   *
   * @param p_manifest_fname: manifest file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_concat: no files to be saved in the manifest
   */
   PROCEDURE save_manifest(p_manifest_fname IN arm_main_var.path_type);

   /**
   * Load the manifest file.
   *
   * @param p_manifest_fname: manifest file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   * @throws arm_main_var.ge_inv_dir_name: invalid diirectory name
   * @throws arm_main_var.ge_manifest_format: wrong manifest file format
   * @throws arm_main_var.ge_dump_file_size_missing: file size not mentioned
   */
   PROCEDURE load_manifest(p_manifest_fname IN arm_main_var.path_type);
   
   /**
   * Archive the files of same set.
   *
   * @param p_directory: directory name
   * @param p_file_prefix: files name prefix
   * @param p_file_extension: files extension
   * @param p_concat_file: concatenated file name
   * @param p_archive_file: archive file name
   * @param p_manifest_file: manifest file name
   * @param p_verbose: verbose mode
   * @param p_log_file_name: log file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_inv_file_prefix: invalid file prefix
   * @throws arm_main_var.ge_inv_file_name: invalid concatenated or archive file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   */
   PROCEDURE create_archive(
        p_directory        IN arm_main_var.path_type
      , p_file_prefix      IN VARCHAR2
      , p_file_extension   IN VARCHAR2
      , p_concat_file      IN arm_main_var.path_type
      , p_archive_file     IN arm_main_var.path_type
      , p_manifest_file    IN arm_main_var.path_type
      , p_verbose          IN BOOLEAN                 := FALSE
      , p_log_file_name    IN arm_main_var.path_type  := NULL
   );

   /**
   * Extract the files of same set.
   *
   * @param p_directory: directory name
   * @param p_archive_file: archive file name
   * @param p_manifest_file: manifest file name
   * @param p_concat_file: concatenated file name
   * @param p_verbose: verbose mode
   * @param p_log_file_name: log file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_inv_file_name: invalid concatenated or archive file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   */
   PROCEDURE extract_archive_content(
        p_directory        IN arm_main_var.path_type
      , p_archive_file     IN arm_main_var.path_type
      , p_manifest_file    IN arm_main_var.path_type
      , p_concat_file      IN arm_main_var.path_type
      , p_verbose          IN BOOLEAN                 := FALSE
      , p_log_file_name    IN arm_main_var.path_type  := NULL
   );

END arm_main_krn;
/
