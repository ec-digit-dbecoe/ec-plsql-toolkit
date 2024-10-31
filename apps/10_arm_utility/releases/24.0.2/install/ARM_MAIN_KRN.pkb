CREATE OR REPLACE PACKAGE BODY arm_main_krn IS
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


   -- buffer size
   gk_buffer_size    CONSTANT    PLS_INTEGER := 32767;

   -- Oracle directory
   g_directory                   arm_main_var.path_type;

   -- log file name
   g_log_file_name               arm_main_var.path_type;

   -- log file handle
   g_log_file                    SYS.UTL_FILE.FILE_TYPE;

   -- file descriptor type
   TYPE gr_file_descriptor IS RECORD (
        file_name arm_main_var.path_type
      , file_size PLS_INTEGER
   );

   -- whether the package must be executed in verbose mode
   g_verbose                     BOOLEAN := FALSE;

   -- table of file descriptors
   TYPE gt_file_descriptors IS TABLE OF gr_file_descriptor;
   gr_file_descriptors gt_file_descriptors := gt_file_descriptors();


   /**
   * Raise application error.
   *
   * @param p_code: error code
   * @param p_message: error message
   */
   PROCEDURE raise_error(
        p_code       IN SIMPLE_INTEGER
      , p_message    IN VARCHAR2
   ) IS
   BEGIN
      IF p_message IS NOT NULL THEN
         log_msg('ERROR:');
         log_msg(p_message);
      END IF;
      RAISE_APPLICATION_ERROR(p_code, NVL(p_message, '/'));
   END raise_error;

   /**
   * Display a log message.
   *
   * @param p_message: message to be displayed
   */
   PROCEDURE log_msg(p_message IN VARCHAR2) IS
   BEGIN

      -- Check whether the package is in verbose mode.
      IF g_verbose THEN

         -- Display message.
         SYS.DBMS_OUTPUT.PUT_LINE(
               TO_CHAR(SYSTIMESTAMP, arm_main_var.gk_timestamp_format)
            || ' - '
            || NVL(TRIM(p_message), ' ')
         );

      END IF;

      -- Add message to the log file.
      <<log_message>>
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(g_log_file) THEN
            SYS.UTL_FILE.PUT_LINE(
               g_log_file
               ,    TO_CHAR(SYSTIMESTAMP, arm_main_var.gk_timestamp_format)
                  || ' - '
                  || NVL(TRIM(p_message), ' ')
               , TRUE
            );
         END IF;
      EXCEPTION
         WHEN OTHERS THEN  
            SYS.DBMS_OUTPUT.PUT_LINE(
                  TO_CHAR(SYSTIMESTAMP, arm_main_var.gk_timestamp_format)
               || ' - '
               || 'ERROR: adding message to log file failure'
            );
      END log_message;

   END log_msg;

   /**
   * Initialize the Oracle directory.
   *
   * @param p_directory: database directory
   */
   PROCEDURE set_directory(p_directory IN arm_main_var.path_type) IS
   BEGIN
      g_directory := TRIM(p_directory);
   END set_directory;

   /**
   * Initialize the log file.
   *
   * @param p_log_file_name: log file name
   */
   PROCEDURE init_log_file(p_log_file_name IN arm_main_var.path_type) IS
   BEGIN

      IF g_directory IS NOT NULL AND TRIM(p_log_file_name) IS NOT NULL THEN
         g_log_file_name := TRIM(p_log_file_name);
         g_log_file := SYS.UTL_FILE.FOPEN(
              g_directory
            , g_log_file_name
            , 'w'
         );
         log_msg(
              'Log file ('
            || NVL(g_log_file_name, 'NULL')
            || ') initialized'
         );
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         log_msg('ERROR: initializing log file failure');

   END init_log_file;

   /**
   * Close the log file.
   */
   PROCEDURE close_log_file IS
   BEGIN
      
      IF SYS.UTL_FILE.IS_OPEN(g_log_file) THEN
         SYS.UTL_FILE.FCLOSE(g_log_file);
         g_log_file := NULL;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         log_msg('ERROR: closing log file failure');

   END close_log_file;
   
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
   * @throws arm_main_var.ge_inv_dst_file: invalid destination file name
   */
   PROCEDURE compress_file(
        p_src_directory       IN arm_main_var.path_type
      , p_src_file            IN arm_main_var.path_type
      , p_dst_directory       IN arm_main_var.path_type
      , p_dst_file            IN arm_main_var.path_type
   ) IS
      
      -- subset size
      l_subset_size           BINARY_INTEGER := gk_buffer_size;
      
      -- source file handle
      l_src_file              BFILE;
      
      -- source file content
      l_src_content           BLOB;
      
      -- source file content size
      l_content_size          PLS_INTEGER;
      
      -- destination file
      l_dst_file              SYS.UTL_FILE.FILE_TYPE;
      
      -- offset
      l_offset                BINARY_INTEGER := 1;
      
      -- buffer
      l_buffer                RAW(gk_buffer_size);

      PROCEDURE compress_file_close_src IS
      BEGIN
         SYS.DBMS_LOB.FILECLOSE(l_src_file);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END compress_file_close_src;

      PROCEDURE compress_file_close_dest IS
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(l_dst_file) THEN
            SYS.UTL_FILE.FCLOSE(l_dst_file);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END compress_file_close_dest;
      
   BEGIN

      -- Log message.
      log_msg('Compressing file (' || NVL(p_src_file, 'NULL') || ')...');
   
      -- Check parameters.
      IF TRIM(p_src_directory) IS NULL THEN
         log_msg('ERROR: invalid source diretory');
         raise_error(
              -20001
            , 'Compressing file error - invalid source directory'
         );
      END IF;
      IF TRIM(p_src_file) IS NULL THEN
      log_msg('ERROR: invalid source file name');
         raise_error(
              -20003
            , 'Compressing file error - invalid source file'
         );
      END IF;
      IF TRIM(p_dst_directory) IS NULL THEN
         log_msg('ERROR: invalid destination directory');
         raise_error(
              -20002
            , 'Compressing file error - invalid destination diretory'
         );
      END IF;
      IF TRIM(p_dst_file) IS NULL THEN
         log_msg('ERROR: invalid destination file name');
         raise_error(
              -20004
            , 'Compressing file errror - invalid destination file'
         );
      END IF;

      -- Open the source file.
      l_src_file := BFILENAME(TRIM(p_src_directory), TRIM(p_src_file));
      SYS.DBMS_LOB.FILEOPEN(l_src_file, SYS.DBMS_LOB.LOB_READONLY);
      
      -- Extract content from source file.
      l_src_content := SYS.UTL_COMPRESS.LZ_COMPRESS(l_src_file);
      
      -- Compute content size.
      l_content_size := SYS.DBMS_LOB.GETLENGTH(l_src_content);
      
      -- Open the destination file.
      l_dst_file := SYS.UTL_FILE.FOPEN(
           TRIM(p_dst_directory)
         , TRIM(p_dst_file)
         , 'wb'
      );
      
      -- Compress content.
      <<compress_subsets>>
      WHILE l_offset < l_content_size LOOP
      
         -- Compress subset.
         SYS.DBMS_LOB.READ(
              l_src_content
            , l_subset_size
            , l_offset
            , l_buffer
         );
         SYS.UTL_FILE.PUT_RAW(l_dst_file, l_buffer, TRUE);
         l_offset := l_offset + l_subset_size;
         
      END LOOP compress_subsets;
      
      -- Close the destination file.
      compress_file_close_dest();
      
      -- Close the source file.
      compress_file_close_src();
   
      -- Release resources.
      SYS.DBMS_LOB.FREETEMPORARY(l_src_content);

      -- Log message.
      log_msg('File compressed');

   EXCEPTION
      WHEN OTHERS THEN
         CASE NVL(SQLCODE, 0)
            WHEN -22285 THEN
               raise_error(-20016, 'ERROR: source directory does not exist');
            WHEN -22288 THEN
               raise_error(-20017, 'ERROR:: source file does not exist');
            WHEN -29280 THEN
               compress_file_close_src();
               raise_error(
                  -20018
                , 'ERROR: destination directory does not exist'
               );
            ELSE
               compress_file_close_src();
               compress_file_close_dest();
               RAISE;
         END CASE;
      
   END compress_file;

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
   ) IS

      -- subset size
      l_subset_size                 BINARY_INTEGER := gk_buffer_size;
      
      -- source file handle
      l_src_file                    BFILE;
      
      -- source file content
      l_src_content BLOB;
      
      -- source file content size
      l_content_size                PLS_INTEGER;
      
      -- destination file
      l_dst_file                    SYS.UTL_FILE.FILE_TYPE;
      
      -- offset
      l_offset                      BINARY_INTEGER := 1;
      
      -- buffer
      l_buffer                      RAW(gk_buffer_size);
      
      PROCEDURE uncompress_file_close_src IS
      BEGIN
         SYS.DBMS_LOB.FILECLOSE(l_src_file);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END uncompress_file_close_src;

      PROCEDURE uncompress_file_close_dest IS
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(l_dst_file) THEN
            SYS.UTL_FILE.FCLOSE(l_dst_file);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END uncompress_file_close_dest;
      
   BEGIN

      -- Log message.
      log_msg('Uncompressing file (' || NVL(p_src_file, 'NULL') || ')...');

      -- Check parameters.
      IF TRIM(p_src_directory) IS NULL THEN
         log_msg('ERROR: invalid source directory');
         raise_error(
              -20001
            , 'Uncompressing file error - invalid source directory'
         );
      END IF;
      IF TRIM(p_src_file) IS NULL THEN
         log_msg('ERROR: invalid source file');
         raise_error(
              -20003
            , 'Uncompressing file error - invalid source file'
         );
      END IF;
      IF TRIM(p_dst_directory) IS NULL THEN
         log_msg('ERROR: invalid destination directory');
         raise_error(
              -20002
            , 'Uncompressing file error - invalid destination diretory'
         );
      END IF;
      IF TRIM(p_dst_file) IS NULL THEN
         log_msg('ERROR: invalid destination file');
         raise_error(
              -20004
            , 'Uncompressing file errror - invalid destination file'
         );
      END IF;

      -- Open the source file.
      l_src_file := BFILENAME(TRIM(p_src_directory), TRIM(p_src_file));
      SYS.DBMS_LOB.FILEOPEN(l_src_file, SYS.DBMS_LOB.LOB_READONLY);

      -- Extract content from source file.
      l_src_content := SYS.UTL_COMPRESS.LZ_UNCOMPRESS(l_src_file);

      -- Compute content size.
      l_content_size := SYS.DBMS_LOB.GETLENGTH(l_src_content);

      -- Open the destination file.
      l_dst_file := SYS.UTL_FILE.FOPEN(
           TRIM(p_dst_directory)
         , TRIM(p_dst_file)
         , 'wb'
      );

      -- Uncompress content.
      <<uncompress_subset>>
      WHILE l_offset < l_content_size LOOP

         -- uncompress subset.
         SYS.DBMS_LOB.READ(
              l_src_content
            , l_subset_size
            , l_offset
            , l_buffer
         );
         SYS.UTL_FILE.PUT_RAW(l_dst_file, l_buffer, TRUE);
         l_offset := l_offset + l_subset_size;

      END LOOP uncompress_subset;

      -- Close the destination file.
      uncompress_file_close_dest();

      -- Close the source file.
      uncompress_file_close_src();

      -- Release resources.
      SYS.DBMS_LOB.FREETEMPORARY(l_src_content);

      -- Log message.
      log_msg('File uncompressed');

   EXCEPTION
      WHEN OTHERS THEN
         CASE NVL(SQLCODE, 0)
            WHEN -22285 THEN
               raise_error(-20016, 'ERROR: source directory does not exist');
            WHEN -22288 THEN
               raise_error(-20017, 'ERROR:: source file does not exist');
            WHEN -29280 THEN
               uncompress_file_close_src();
               raise_error(
                  -20018
                , 'ERROR: destination directory does not exist'
               );
            ELSE
               uncompress_file_close_src();
               uncompress_file_close_dest();
               RAISE;
         END CASE;
      
   END uncompress_file;

   /**
   * Reset the list of files.
   */
   PROCEDURE reset_files IS
   BEGIN
      gr_file_descriptors := gt_file_descriptors();
   END reset_files;

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
   ) IS
   BEGIN

      -- Check file name.
      IF TRIM(p_file_name) IS NULL THEN
         raise_error(
              -20005
            , 'Adding file error - invalid file name.'
         );
      END IF;

      -- Add the file.
      gr_file_descriptors.extend;
      gr_file_descriptors(gr_file_descriptors.LAST) :=
         gr_file_descriptor(TRIM(p_file_name), p_file_size);

   END add_file;

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
      , p_file_extension      IN VARCHAR2 := NULL) IS

      -- file name list
      lr_file_names                 arm_main_var.arm_file_names_set;

      -- file index
      l_file_idx                    PLS_INTEGER;

   BEGIN

      -- Log message.
      log_msg(
            'Building list of files ('
         || 'prefix=' || NVL(p_file_name_prefix, 'NULL')
         || ' / '
         || 'extension=' || NVL(p_file_extension, 'NULL')
         || ')...'
      );

      -- Check directory name and file prefix name.
      IF TRIM(g_directory) IS NULL THEN
         log_msg('ERROR: invalid directory name');
         raise_error(
              -20006
            , 'Building file list error - invalid directory name'
         );
      END IF;
      IF TRIM(p_file_name_prefix) IS NULL THEN
         log_msg('ERROR: invalid file name prefix');
         raise_error(
              -20007
            , 'Building file list error - invalid file name prefix'
         );
      END IF;

      -- Reset the file list.
      reset_files();

      -- Browse the list of files.
      <<fetch_files>>
      BEGIN
         lr_file_names := arm_util_krn.get_file_names(
              p_directory        => g_directory
            , p_file_name_filter => p_file_name_prefix || '%'
         );
      EXCEPTION
         WHEN arm_main_var.ge_inv_orcl_dir_name THEN
            log_msg('ERROR: invalid directory name');
            raise_error(
                 -20006
               , 'Building file list error - invalid directory name'
            );
         WHEN arm_main_var.ge_orcl_dir_not_exist THEN
            log_msg('ERROR: directory does not exist');
            raise_error(
                 -20008
               , 'Building file list error - directory does not exist'
            );
      END fetch_files;
      IF lr_file_names IS NOT NULL AND NVL(lr_file_names.LAST, 0) > 0 THEN
         <<browse_files>>
         FOR l_file_idx IN 1..lr_file_names.COUNT LOOP

            -- Add the file to the list if needed.
            IF TRIM(p_file_extension) IS NULL THEN
               add_file(lr_file_names(l_file_idx), 0);
            ELSE
               IF UPPER(lr_file_names(l_file_idx)) LIKE
                     UPPER(TRIM(p_file_name_prefix)) || '%' || '.' 
                  || UPPER(TRIM(p_file_extension)) THEN
                  add_file(lr_file_names(l_file_idx), 0);
               END IF;
            END IF;

         END LOOP browse_files;
      END IF;

      -- Log message.
      log_msg('List of files built.');

   END build_file_list;

   /**
   * Concatenate a single file into the archive file.
   *
   * @param p_archive: archive file handle
   * @param p_directory: source file directory
   * @param p_file_name: source file name
   * @return file size
   * @throws arm_main_varg.ge_inv_dir_name: invalid directory name
   * @throws arm_main_varg.ge_inv_file_name: invalid file name
   * @throws arm_main_varg.ge_file_not_open: archive file not open
   */
   FUNCTION concat_file(
        p_archive       IN SYS.UTL_FILE.FILE_TYPE
      , p_directory     IN arm_main_var.path_type
      , p_file_name     IN arm_main_var.path_type
   ) RETURN PLS_INTEGER IS

      -- source file handle
      l_src_file           SYS.UTL_FILE.FILE_TYPE;

      -- buffer
      l_buffer             RAW(gk_buffer_size);

      -- buffer size
      l_size               PLS_INTEGER := gk_buffer_size;

      -- source file size
      l_src_size           PLS_INTEGER := 0;

   BEGIN

      -- Log message.
      log_msg('Concatenating file (' || NVL(p_file_name, 'NULL') || ')...');

      -- Check parameters.
      IF TRIM(p_directory) IS NULL THEN
         log_msg('ERROR: invalid directory');
         raise_error(
              -20006
            , 'Concatenating file error - invalid directory'
         );
      END IF;
      IF TRIM(p_file_name) IS NULL THEN
         log_msg('ERROR: invalid file name');
         raise_error(
              -20005
            , 'Concatenating file error - invalid file name'
         );
      END IF;

      -- Check whether the archive file is open.
      IF NOT SYS.UTL_FILE.IS_OPEN(p_archive) THEN
         log_msg('ERROR: archive file not open');
         raise_error(
              -20009
            , 'Concatenating file error - archive file not open.'
         );
      END IF;

      -- Open the source file.
      l_src_file := SYS.UTL_FILE.FOPEN(
           TRIM(p_directory)
         , TRIM(p_file_name)
         , 'rb'
      );

      -- Browse the subsets.
      <<browse_subsets>>
      LOOP
         BEGIN
            SYS.UTL_FILE.GET_RAW(l_src_file, l_buffer, l_size);

            -- Save the subset in the archive file.
            SYS.UTL_FILE.PUT_RAW(p_archive, l_buffer, TRUE);
            l_src_size := l_src_size + SYS.UTL_RAW.LENGTH(l_buffer);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT browse_subsets;
         END;

      END LOOP browse_subsets;

      -- Close the source file.
      SYS.UTL_FILE.FCLOSE(l_src_file);

      -- Log file.
      log_msg('File concatenated.');

      -- Return the source file size.
      RETURN l_src_size;

   END concat_file;

   /**
   * Concatenate a single file into the archive file.
   *
   * @param p_archive: archive file handle
   * @param p_directory: source file directory
   * @param p_file_name: source file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_inv_file_name: invalid file name
   * @throws arm_main_var.ge_file_not_open: archive file not open
   */
   PROCEDURE concat_file(
        p_archive       IN SYS.UTL_FILE.FILE_TYPE
      , p_directory     IN arm_main_var.path_type
      , p_file_name     IN arm_main_var.path_type
   ) IS

      -- file size
      l_file_size       PLS_INTEGER;

   BEGIN

      -- Call the corresponding function.
      l_file_size := concat_file(p_archive, p_directory, p_file_name);

   END concat_file;

   /**
   * Concatenate the files in a single archive file.
   *
   * @param p_file_name: archive file name
   * @throws arm_main_var.ge_inv_file_name: invalid file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_concat: no files to be concatenated
   */
   PROCEDURE concat_files(p_file_name IN arm_main_var.path_type) IS

      -- archive file handle
      l_archive               SYS.UTL_FILE.FILE_TYPE;

      -- file index
      l_file_idx              PLS_INTEGER;

      -- buffer
      l_buffer                RAW(gk_buffer_size);

      -- souce file size
      l_src_size              PLS_INTEGER := 0;

   BEGIN

      -- Log Message.
      log_msg('Concatenating files...');

      -- Check file name and directory.
      IF TRIM(p_file_name) IS NULL THEN
      log_msg('ERROR: invalid archive file name');
         raise_error(
              -20005
            , 'Concatenating files error - invalid archive file name.'
         );
      END IF;
      IF TRIM(g_directory) IS NULL THEN
         log_msg('ERROR: invalid directory name');
         raise_error(
              -20006
            , 'Concatenating files error - invalid directory name'
         );
      END IF;

      -- Check whether some files must be concatenated.
      IF gr_file_descriptors IS NULL OR
         NVL(gr_file_descriptors.LAST, 0) <= 0 THEN
         log_msg('ERROR: no files to be concatenated');
         raise_error(
              -20010
            , 'Concatenating files error - no file to be concatenated.'
         );
      END IF;

      -- Open the archive file.
      l_archive := SYS.UTL_FILE.FOPEN(
           TRIM(g_directory)
         , TRIM(p_file_name)
         , 'wb'
      );

      --Browse the files.
      <<browse_files>>
      FOR l_file_idx IN 1..gr_file_descriptors.COUNT LOOP

         -- Concatenate the source file.
         l_src_size := concat_file(
              l_archive
            , TRIM(g_directory)
            , gr_file_descriptors(l_file_idx).file_name
         );

         -- Store the file size.
         gr_file_descriptors(l_file_idx).file_size := l_src_size;

      END LOOP browse_files;

      -- Close the archive file.
      SYS.UTL_FILE.FCLOSE(l_archive);

      -- Log messages.
      log_msg('Files concatenated.');

   END concat_files;

   /**
   * Extract a file from an archive file.
   *
   * @param p_archive: archive file handle
   * @param p_directory: destination file directory
   * @param p_file_name: destination file name
   * @param p_file_size: destination file size
   * @throws arm_main_var.ge_inv_dir_name: invalid diretory name
   * @throws arm_main_var.ge_inv_file_name: invalid file name
   * @throws arm_main_var.ge_inv_file_size: invalid file size
   * @throws arm_main_var.ge_file_not_open: archive file not open
   */
   PROCEDURE extract_file(
        p_archive       IN SYS.UTL_FILE.FILE_TYPE
      , p_directory     IN arm_main_var.path_type
      , p_file_name     IN arm_main_var.path_type
      , p_file_size     IN PLS_INTEGER
   ) IS

      -- destination file
      l_dst_file        SYS.UTL_FILE.FILE_TYPE;

      -- number of bytes extracted
      l_extracted       PLS_INTEGER := 0;

      -- buffer size
      l_size            PLS_INTEGER := gk_buffer_size;

      -- buffer
      l_buffer          RAW(gk_buffer_size);
      
      -- procedure that closes the destination file
      PROCEDURE close_dest_file IS
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(l_dst_file) THEN
            SYS.UTL_FILE.FCLOSE(l_dst_file);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END close_dest_file;

   BEGIN

      -- Log message.
      log_msg('Extracting file (' || NVL(p_file_name, 'NULL') || ')...');

      -- Check parameters.
      IF TRIM(p_directory) IS NULL THEN
         log_msg('ERROR: invalid directory');
         raise_error(
              -20006
            , 'Extracting file error - invalid directory.'
         );
      END IF;
      IF TRIM(p_file_name) IS NULL THEN
         log_msg('ERROR: invalid file name');
         raise_error(
              -20005
            , 'Extracting file error - invalid file name.'
         );
      END IF;
      IF NVL(p_file_size, 0) <= 0 THEN
         log_msg('ERROR: invalid file size');
         raise_error(
              -20011
            , 'Extracting file error - invalid file size.'
         );
      END IF;

      -- Check whether the archive file is open.
      IF NOT SYS.UTL_FILE.IS_OPEN(p_archive) THEN
         log_msg('ERROR: archive file not open');
         raise_error(
              -20009
            , 'Extracting file error - archive file not open.'
         );
      END IF;

      -- Open the destination file.
      l_dst_file := SYS.UTL_FILE.FOPEN(
           TRIM(p_directory)
         , TRIM(p_file_name)
         , 'wb'
      );

      -- Browse the subsets.
      l_extracted := 0;
      <<browse_subsets>>
      WHILE l_extracted < p_file_size LOOP

         -- Extract next subset.
         IF (p_file_size - l_extracted) < l_size THEN
            SYS.UTL_FILE.GET_RAW(
                 p_archive
               , l_buffer
               , (p_file_size - l_extracted)
            );
         ELSE
            SYS.UTL_FILE.GET_RAW(
                 p_archive
               , l_buffer
               , l_size
            );
         END IF;
         l_extracted := l_extracted + l_size;

         -- Save the subset in the destination file.
         SYS.UTL_FILE.PUT_RAW(
              l_dst_file
            , l_buffer
            , TRUE
         );

      END LOOP browse_subsets;

      -- Close the destination file.
      close_dest_file();

      -- Log message.
      log_msg('File extracted.');
      
   EXCEPTION
      WHEN OTHERS THEN
         close_dest_file();
         RAISE;

   END extract_file;

   /**
   * Extract the files from the archive file.
   *
   * @param p_file_name: archive file name
   * @throws arm_main_var.ge_inv_file_name: invalid archive file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_extract: no file to be extracted
   */
   PROCEDURE extract_files(p_file_name IN arm_main_var.path_type) IS

      -- archive file handle
      l_archive         SYS.UTL_FILE.FILE_TYPE;

      -- file index
      l_file_idx        PLS_INTEGER;
      
      -- procedure that closes the archive file
      PROCEDURE close_archive_file IS
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(l_archive) THEN   
            SYS.UTL_FILE.FCLOSE(l_archive);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END close_archive_file;

   BEGIN

      -- Log message.
      log_msg('Extracting files...');

      -- Check parameters.
      IF TRIM(p_file_name) IS NULL THEN
         log_msg('ERROR: invalid archive file name');
         raise_error(
              -20005
            , 'Extracting files error - invalid archive file name.'
         );
      END IF;
      IF TRIM(g_directory) IS NULL THEN
         log_msg('ERROR: invalid directory');
         raise_error(
              -20006
            , 'Extracting files error - invalid directory.'
         );
      END IF;

      -- Check whether there are some files to be extracted.
      IF gr_file_descriptors IS NULL OR
         NVL(gr_file_descriptors.LAST, 0) <= 0 THEN
         log_msg('ERROR: no files to be extracted');
         raise_error(
              -20012
            , 'Extracting files error - no file to be extracted.'
         );
      END IF;

      -- Open the archive file.
      l_archive := SYS.UTL_FILE.FOPEN(
           TRIM(g_directory)
         , TRIM(p_file_name)
         , 'rb'
      );

      -- Browse the files to be extracted.
      <<browse_files>>
      FOR l_file_idx IN 1..gr_file_descriptors.COUNT LOOP

         -- Extract the file.
         extract_file(
              l_archive
            , g_directory
            , gr_file_descriptors(l_file_idx).file_name
            , gr_file_descriptors(l_file_idx).file_size
         );

      END LOOP browse_files;

      -- Close the archive file.
      close_archive_file();

      -- Log message.
      log_msg('Files extracted.');
      
   EXCEPTION
      WHEN OTHERS THEN
         close_archive_file();
         RAISE;

   END extract_files;

   /**
   * Save the manifest file.
   *
   * @param p_manifest_fname: manifest file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   * @throws arm_main_var.ge_inv_dir_name: invalid directory name
   * @throws arm_main_var.ge_no_file_to_concat: no files to be saved in the manifest
   */
   PROCEDURE save_manifest(p_manifest_fname IN arm_main_var.path_type) IS

      -- manifest file handle
      l_file            SYS.UTL_FILE.FILE_TYPE;

      -- file index
      l_file_idx        PLS_INTEGER;

   BEGIN

      -- Log message.
      log_msg(
            'Saving manifest file ('
         || NVL(p_manifest_fname, 'NULL')
         || ')...'
      );

      -- Check parameters.
      IF TRIM(p_manifest_fname) IS NULL THEN
         log_msg('ERROR: invalid manifest fie name');
         raise_error(
              -20013
            , 'Saving manifest file error - invalid manifest file name.'
         );
      END IF;
      IF TRIM(g_directory) IS NULL THEN
         log_msg('ERROR: invalid directory');
         raise_error(
              -20006
            , 'Saving manifest file error - invalid directory name.'
         );
      END IF;

      -- Check whether there are some files to be stored in the manifest file.
      IF NVL(gr_file_descriptors.LAST, 0) <= 0 THEN
         log_msg('ERROR: no file to be saved in the manifest file');
         raise_error(
              -20010
            ,    'Saving manifest file error - '
              || 'no file to be saved in the manifest.'
         );
      END IF;

      -- Open the manifest file.
      l_file := SYS.UTL_FILE.FOPEN(
           TRIM(g_directory)
         , TRIM(p_manifest_fname)
         , 'w'
      );

      -- Browse the files.
      <<browse_files>>
      FOR l_file_idx IN 1..gr_file_descriptors.COUNT LOOP

         -- Add the current file to the manifest file.
         SYS.UTL_FILE.PUT_LINE(
              l_file
            ,    gr_file_descriptors(l_file_idx).file_name
              || ':'
              || TO_CHAR(NVL(gr_file_descriptors(l_file_idx).file_size, 0))
            , TRUE
         );
         log_msg(
               'File ' || NVL(TO_CHAR(l_file_idx, '999,999'), 'NULL')
            || ':'
            || NVL(gr_file_descriptors(l_file_idx).file_name, 'NULL')
         );

      END LOOP browse_files;

      -- Close the manifest file.
      SYS.UTL_FILE.FCLOSE(l_file);

      -- Log message.
      log_msg('Manifest file saved.');

   END save_manifest;

   /**
   * Load the manifest file.
   *
   * @param p_manifest_fname: manifest file name
   * @throws arm_main_var.ge_inv_manifest_file_name: invalid manifest file name
   * @throws arm_main_var.ge_inv_dir_name: invalid diirectory name
   * @throws arm_main_var.ge_manifest_format: wrong manifest file format
   * @throws arm_main_var.ge_dump_file_size_missing: file size not mentioned
   */
   PROCEDURE load_manifest(p_manifest_fname IN arm_main_var.path_type) IS

      -- manifest file handle
      l_file               SYS.UTL_FILE.FILE_TYPE;

      -- file line
      l_line               VARCHAR2(500 CHAR);

      -- separator position
      l_sep_pos            PLS_INTEGER;

      -- error code
      l_error_code         PLS_INTEGER;

      -- procedure that closes the manifest file
      PROCEDURE close_manifest IS
      BEGIN
         IF SYS.UTL_FILE.IS_OPEN(l_file) THEN
            SYS.UTL_FILE.FCLOSE(l_file);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END close_manifest;

   BEGIN

      -- Log message.
      log_msg(
            'Loading manifest file ('
         || NVL(p_manifest_fname, 'NULL')
         || ')...'
      );

      -- Check parameters.
      IF TRIM(p_manifest_fname) IS NULL THEN
         log_msg('ERROR: invalid manifest file name');
         raise_error(
              -20013
            , 'Loading manifest file error - invalid manifest file name.'
         );
      END IF;
      IF TRIM(g_directory) IS NULL THEN
         log_msg('ERROR: invalid directory name');
         raise_error(
              -20006
            , 'Loading manifest file error - invalid directory name.'
         );
      END IF;

      -- Open the manifest file.
      l_file := SYS.UTL_FILE.FOPEN(
           TRIM(g_directory)
         , TRIM(p_manifest_fname)
         , 'r'
      );

      -- Reset the file descriptors.
      reset_files();

      -- Browse the manifest file lines.
      <<browse_manifest_lines>>
      LOOP
         BEGIN

            --Load the line.
            SYS.UTL_FILE.GET_LINE(l_file, l_line);

            -- Split the line.
            l_sep_pos := INSTR(l_line, ':');
            IF NVL(l_sep_pos, 0) <= 2 THEN
               log_msg('ERROR: invalid manifest file line format');
               raise_error(
                    -20014
                  , 'Loading manifest file error - wrong line format.'
               );
            ELSIF NVL(l_sep_pos, 0) >= LENGTH(l_line) THEN
               log_msg('ERROR: file size not mentioned in manifest file');
               raise_error(
                    -20015
                  , 'Loading manifest file error - file fize not mentioned.'
               );
            END IF;

            -- Adding file descriptor.
            add_file(
               SUBSTR(l_line, 1, l_sep_pos - 1)
               , TO_NUMBER(SUBSTR(
                    l_line, l_sep_pos + 1, LENGTH(l_line) - l_sep_pos))
            );

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT browse_manifest_lines;
         END;
      END LOOP browse_manifest_lines;

      -- Close the manifest file.
      close_manifest();

      -- Log message.
      log_msg('Manifest file loaded.');

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         close_manifest();
         IF SQLCODE = -29283 THEN
            raise_error(
               -20012
             , 'Loading manifest file error - manifest file does not exist'
            );
         ELSIF SQLCODE = -29280 THEN
            raise_error(
               -20008
             , 'Loading manifest file error - directory does not exist'
            );
         END IF;
         RAISE;

   END load_manifest;
   
   /**
   * Create the archive file.
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
   ) IS
      
   BEGIN

      -- Initialize verbose mode.
      g_verbose := p_verbose;

      --Initialize directory.
      set_directory(p_directory);

      -- Initialize log file.
      IF TRIM(p_log_file_name) IS NOT NULL THEN
         init_log_file(p_log_file_name);
      END IF;

      -- Log start.
      log_msg('Archiving files...');
   
      -- Check parameters.
      IF TRIM(p_directory) IS NULL THEN
         log_msg('ERROR: invalid directory name');
         raise_error(
              -20006
            , 'Archiving files error - invalid directory name.'
         );
      ELSIF TRIM(p_file_prefix) IS NULL THEN
         log_msg('ERROR: invalid files prefix');
         raise_error(
              -20007
            , 'Archiving files error - invalid files prefix.'
         );
      ELSIF TRIM(p_concat_file) IS NULL THEN
         log_msg('ERROR: ivnalid concatenated file name');
         raise_error(
              -20005
            , 'Archiving files error - invalid concatenated file name.'
         );
      ELSIF TRIM(p_archive_file) IS NULL THEN
         log_msg('ERROR: invalid archive file name');
         raise_error(
              -20005
            , 'Archving files error - invalid archive file name.'
         );
      ELSIF TRIM(p_manifest_file) IS NULL THEN
         log_msg('ERROR: invalid manifest file name');
         raise_error(
              -20013
            , 'Archving files error - invalid manifest file name.'
         );
      END IF;

      -- Display parameters.
      log_msg('Directory name: ' || TRIM(p_directory));
      log_msg('File prefix: ' || TRIM(p_file_prefix));
      log_msg('File extension: ' || nvl(TRIM(p_file_extension), '/'));
      log_msg('Concatenated file name: ' || TRIM(p_concat_file));
      log_msg('Archive file name: ' || TRIM(p_archive_file));
      log_msg('Manifest filename: ' || TRIM(p_manifest_file));

      -- Build the list of files.
      reset_files();
      build_file_list(TRIM(p_file_prefix), TRIM(p_file_extension));
      log_msg('List of files built.');

      -- Concatenate the files.
      concat_files(p_concat_file);
      log_msg('Files concatenated.');

      -- Create the manifest file.
      save_manifest(TRIM(p_manifest_file));

      -- Compress the concatenated file.
      compress_file(
           g_directory
         , TRIM(p_concat_file)
         , g_directory
         , TRIM(p_archive_file)
      );
      log_msg('Archive file created.');

      -- Delete the concatenated file.
      SYS.UTL_FILE.FREMOVE(g_directory, TRIM(p_concat_file));
      log_msg('Concatenated file deleted.');

      -- Final message.
      log_msg('Files archived.');

      -- Close the log file.
      close_log_file();

   EXCEPTION
      WHEN OTHERS THEN
         close_log_file();
         RAISE;
   
   END create_archive;

   /**
   * Extract the content of the archive file.
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
   ) IS

   BEGIN

      -- Initialize verbose mode.
      g_verbose := p_verbose;

      -- Initialize directory.
      set_directory(p_directory);

      -- Initialize the log file.
      IF TRIM(p_log_file_name) IS NOT NULL THEN
         init_log_file(p_log_file_name);
      END IF;

      -- Log start.
      log_msg('Extracting files...');

      -- Check parameters.
      IF TRIM(p_directory) IS NULL THEN
         log_msg('ERROR: invalid directory name');
         raise_error(
              -20006
            , 'Extracting files error - invalid directory name.'
         );
      ELSIF TRIM(p_archive_file) IS NULL THEN
         log_msg('ERROR: invalid archive file name');
         raise_error(
              -20005
            , 'Extracting files error - invalid archive file name.'
         );
      ELSIF TRIM(p_manifest_file) IS NULL THEN
         log_msg('ERROR: invalid manifest file name');
         raise_error(
              -20013
            , 'Extracting files error - invalid manifest file name.'
         );
      ELSIF TRIM(p_concat_file) IS NULL THEN
         log_msg('ERROR: invalid concatenated file name');
         raise_error(
              -20005
            , 'Extracting files error - invalid concatenated file name.'
         );
      END IF;

      -- Display parameters.
      log_msg('Directory name: ' || trim(p_directory));
      log_msg('Archive file name: ' || trim(p_archive_file));
      log_msg('Manifest file name: ' || trim(p_manifest_file));
      log_msg('Concatenated file name: ' || trim(p_concat_file));

      -- Load the manifest file.
      set_directory(p_directory);
      reset_files();
      load_manifest(TRIM(p_manifest_file));
      log_msg('Manifest file loaded.');

      -- Uncompress the archive file.
      uncompress_file(
           g_directory
         , TRIM(p_archive_file)
         , g_directory
         , TRIM(p_concat_file)
      );
      log_msg('Concatenated file extracted.');

      -- Extract the files.
      extract_files(TRIM(p_concat_file));
      log_msg('Files created.');

      -- Delete the concatenated file.
      SYS.UTL_FILE.FREMOVE(g_directory, TRIM(p_concat_file));
      log_msg('Concatenated file deleted');

      -- Final message.
      log_msg('Files extracted.');

      -- Close the log file.
      close_log_file();

   EXCEPTION
      WHEN OTHERS THEN
         close_log_file();
         RAISE;

   END extract_archive_content;

   /**
   * DEBUG: Display the file list
   */
   PROCEDURE debug_display_files IS
   
      -- file index
      l_file_index      PLS_INTEGER;

   BEGIN

      -- Browse the files.
      IF gr_file_descriptors.LAST > 0 THEN
         <<browse_files>>
         FOR l_file_index IN 1..gr_file_descriptors.COUNT LOOP

            -- Display the file.
            SYS.DBMS_OUTPUT.PUT_LINE(
                  'File ' || TO_CHAR(l_file_index, '999,999') || ' : '
               || 'name = '
               || NVL(gr_file_descriptors(l_file_index).file_name, '/')
               || ' size = '
               || TO_CHAR(
                     NVL(gr_file_descriptors(l_file_index).file_size, 0)
                  )
            );

         END LOOP browse_files;
      END IF;

   END debug_display_files;
   
END arm_main_krn;
/
