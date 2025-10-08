CREATE OR REPLACE PACKAGE BODY dpp_s3_krn IS
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
* S3 bucket service package.
* For AWS environments only.
*/

   /**
   * Check whether a diretory exists.
   *
   * @param p_directory: directory to be checked
   * @return: whether the directory exists.
   * @throws dpp_s3_var.ge_inv_parameter: invalid parameter
   */
   FUNCTION check_directory_exists(
      p_directory          IN VARCHAR2
   )
   RETURN BOOLEAN IS

      -- directory count
      dir_count               PLS_INTEGER;

      -- directory found flag
      dir_found               BOOLEAN                          := FALSE;

   BEGIN

      -- Check parameters.
      IF TRIM(p_directory) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
            ,    'The directory is invalid ('
              || COALESCE(TRIM(p_directory), '/')
              || ').'
            , TRUE
         );
      END IF;

      -- Check whether the directory exists.
      SELECT COUNT(*)
        INTO dir_count
        FROM all_directories
       WHERE directory_name = TRIM(p_directory);
      IF dir_count <= 0 THEN
         dir_found := FALSE;
      ELSE
         dir_found := TRUE;
      END IF;

      -- Return the found flag.
      RETURN dir_found;

   END check_directory_exists;

   /**
   * Check whether a file exists in a directory.
   *
   * @param p_directory: directory to be checked
   * @param p_file_name: file name to be checked
   * @return: whether the file exists in the directory
   * @throws dpp_s3_var.ge_inv_parameter: invalid parameter
   * @throws dpp_s3_var.ge_dir_not_exists: directory does not exist
   */
   FUNCTION check_file_exists(
      p_directory          IN VARCHAR2
    , p_file_name          IN VARCHAR2
   )
   RETURN BOOLEAN IS

      -- file list
      file_list               t_file_list;

      -- file index
      file_idx                PLS_INTEGER;

      -- found flag
      file_found              BOOLEAN                          := FALSE;

   BEGIN

      -- Check parameters.
      IF TRIM(p_file_name) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          ,    'The file name is invalid ('
            || COALESCE(TRIM(p_file_name), '/')
            || ').'
          , TRUE
         );
      END IF;

      -- Check whether the directory exists.
      IF NOT check_directory_exists(p_directory) THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_dir_not_exists
          , 'The directory does not exists (' || TRIM(p_directory) || ').'
          , TRUE
         );
      END IF;

      -- Load the directory file list.
      file_list := dpp_job_krn.list_aws_files(TRIM(p_directory));

      -- Browse the files.
      <<browse_files>>
      FOR file_idx IN file_list.FIRST..file_list.LAST LOOP
         IF file_list(file_idx) = TRIM(p_file_name) THEN
            file_found := TRUE;
            EXIT;
         END IF;
      END LOOP browse_files;

      -- Return the found flag.
      RETURN file_found;

   END check_file_exists;

   /**
   * Check the execution status of a S3 bucket task.
   *
   * @param p_task_id: S3 bucket task ID
   * @throws dpp_s3_var.ge_inv_parameter: invalid task ID
   * @throws dpp_s3_var.ge_s3_operation_failure: S3 upload failure
   * @throws dpp_s3_var.ge_s3_operation_timeout: S3 upload timeout
   */
   PROCEDURE check_s3_task_status(p_task_id IN VARCHAR2) IS

      -- start time
      start_time              DATE;

      -- success status
      status_success          BOOLEAN           := FALSE;

      -- failure status
      status_failure          BOOLEAN           := FALSE;

   BEGIN

      -- Check whether the task ID is valid.
      IF TRIM(p_task_id) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          , 'Invalid S3 task ID (' || COALESCE(TRIM(p_task_id), '/') || ').'
         );
      END IF;

      -- Check execution status.
      DBMS_LOCK.SLEEP(dpp_s3_var.gk_s3_sleep);
      start_time := SYSDATE;
      <<wait_for_exec>>
      LOOP
         <<browse_status_lines>>
         FOR status_line IN (
            SELECT text
              FROM TABLE(
                      rdsadmin.rds_file_util.read_text_file(
                         'BDUMP'
                       , 'dbtask-' || TRIM(p_task_id) || '.log'
                      )
                   )
         ) LOOP
            IF INSTR(
               status_line.text, dpp_s3_var.gk_task_status_success
            ) > 0 THEN
               status_success := TRUE;
               EXIT;
            ELSIF INSTR(
               status_line.text, dpp_s3_var.gk_task_status_failure
            ) > 0 THEN
               status_failure := TRUE;
               EXIT;
            END IF;
         END LOOP browse_status_lines;
         EXIT WHEN status_success OR status_failure;
         DBMS_LOCK.SLEEP(dpp_s3_var.gk_s3_sleep);
         IF SYSDATE - start_time > dpp_s3_var.gk_s3_timeout / 3600 THEN
            EXIT;
         END IF;
      END LOOP wait_for_exec;

      -- Raise exception if needed.
      IF NOT status_success AND NOT status_failure THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_operation_timeout
          ,    'A timeout occurred during the S3 bucket operation ('
            || COALESCE(p_task_id, '/')
            || ').'
          , TRUE
         );
      ELSIF status_failure THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_operation_failure
          ,    'An error occurred during the S3 bucket operation ('
           || COALESCE(p_task_id, '/')
           || ').'
          , TRUE
         );
      END IF;
      
   END check_s3_task_status;

   /**
   * Upload a file to a S3 bucket.
   *
   * @param p_directory: Oracle directory the file is stored in
   * @param p_file_name: name of the file to be uploaded
   * @param p_s3_bucket: name of the target S3 bucket
   * @param p_s3_prefix: target prefix in the S3 bucket, which is the sub-folder
   * @param p_compression_level: compression level
   * @throws dpp_s3_var.ge_service_not_available: service only available in AWS
   * @throws dpp_s3_var.ge_inv_parameter: invalid parameter
   * @throws dpp_s3_var.ge_dir_not_exists: directory does not exist
   * @throws dpp_s3_var.ge_file_not_exists: file does not exist
   * @throws dpp_s3_var.ge_s3_operation_failure: S3 upload failure
   * @throws dpp_s3_var.ge_s3_operation_timeout: S3 upload timeout
   * @throws dpp_s3_var.ge_s3_folder_not_exists: S3 prefix does not exist
   */
   PROCEDURE upload_file_to_s3(
      p_directory          IN VARCHAR2
    , p_file_name          IN VARCHAR2
    , p_s3_bucket          IN VARCHAR2
    , p_s3_prefix          IN VARCHAR2
    , p_compression_level  IN PLS_INTEGER    := NULL
   ) IS

      -- directory count
      dir_count               PLS_INTEGER;

      -- S3 task ID
      s3_task_id              VARCHAR2(100);

   BEGIN

      -- Check parameters.
      IF TRIM(p_s3_bucket) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          , 'The S3 bucket name is invalid.'
          , TRUE
         );
      ELSIF p_compression_level IS NOT NULL 
            AND (p_compression_level < 0 OR p_compression_level > 9) THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          ,    'The compression level is invalid ('
            || COALESCE(TO_CHAR(p_compression_level), '/')
            || ').'
          , TRUE
         );
      END IF;

      -- Check whether the file exists.
      IF NOT check_file_exists(p_directory, p_file_name) THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_file_not_exists
          , 'The file does not exists (' || TRIM(p_file_name) || ').'
          , TRUE
         );
      END IF;

      -- Upload the file to S3.
      s3_task_id := rdsadmin.rdsadmin_s3_tasks.upload_to_s3(  
         p_bucket_name        => TRIM(p_s3_bucket)
       , p_directory_name     => TRIM(p_directory)
       , p_s3_prefix          => TRIM(p_s3_prefix)
       , p_prefix             => TRIM(p_file_name)
       , p_compression_level  => p_compression_level
      );
      IF s3_task_id IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_operation_failure
          , 'Error occurred when uploading file to the S3 bucket.'
          , TRUE
         );
      END IF;

      -- Check execution status.
      <<check_upload_task>>
      BEGIN
         check_s3_task_status(s3_task_id);
      EXCEPTION
         WHEN dpp_s3_var.ge_s3_operation_timeout THEN
            RAISE_APPLICATION_ERROR(
               dpp_s3_var.gk_errcode_s3_operation_timeout
             , 'A timeout occurred when uploading the file to the S3 bucket.'
             , TRUE
            );
         WHEN dpp_s3_var.ge_s3_operation_failure THEN
            RAISE_APPLICATION_ERROR(
               dpp_s3_var.gk_errcode_s3_operation_failure
             , 'An error occurred when uploading the file to the S3 bucket.'
             , TRUE
            );
      END check_upload_task;

   EXCEPTION
      WHEN dpp_s3_var.ge_s3_folder_not_exists THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_folder_not_exists
          ,    'The S3 folder matching the prefix does not exist ('
            || COALESCE(TRIM(p_s3_prefix), '/')
            || ').'
          , TRUE
         );

   END upload_file_to_s3;

   /**
   * Download a file from a S3 bucket.
   *
   * @param p_directory: Oracle directory the file must be stored in
   * @param p_s3_bucket: S3 bucket the file must be downloaded from
   * @param p_s3_prefix: path of the file to be downloaded in the S3 bucket
   * @throws dpp_s3_var.ge_service_not_available: service only available in AWS
   * @throws dpp_s3_var.ge_inv_parameter: invalid parameter
   * @throws dpp_s3_var.ge_dir_not_exists: directory does not exist
   * @throws dpp_s3_var.ge_s3_operation_failure: S3 upload failure
   * @throws dpp_s3_var.ge_s3_operation_timeout: S3 upload timeout
   * @throws dpp_s3_var.ge_s3_folder_not_exists: S3 prefix does not exist
   */
   PROCEDURE download_file_from_s3(
      p_directory          IN VARCHAR2
    , p_s3_bucket          IN VARCHAR2
    , p_s3_prefix          IN VARCHAR2
   ) IS

      -- task ID
      s3_task_id           VARCHAR2(100);

   BEGIN

      -- Check parameters.
      IF TRIM(p_s3_bucket) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          , 'The S3 bucket name is invalid.'
          , TRUE
         );
      ELSIF TRIM(p_s3_prefix) IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_inv_parameter
          , 'The S3 prefix is invalid.'
          , TRUE
         );
      END IF;

      -- Check if the directory exists.
      IF NOT check_directory_exists(p_directory) THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_dir_not_exists
          ,    'The directory does not exists (' 
            || COALESCE(TRIM(p_directory), '/') || ').'
          , TRUE
         );
      END IF;

      -- Download the file from S3.
      s3_task_id := rdsadmin.rdsadmin_s3_tasks.download_from_s3(
         p_bucket_name        => TRIM(p_s3_bucket)
       , p_directory_name     => TRIM(p_directory)
       , p_s3_prefix          => TRIM(p_s3_prefix)
      );
      IF s3_task_id IS NULL THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_operation_failure
          , 'Error occurred when downloading file from the S3 bucket.'
          , TRUE
         );
      END IF;

      -- Check execution status.
      <<check_download_task>>
      BEGIN
         check_s3_task_status(s3_task_id);
      EXCEPTION
         WHEN dpp_s3_var.ge_s3_operation_timeout THEN
            RAISE_APPLICATION_ERROR(
               dpp_s3_var.gk_errcode_s3_operation_timeout
             , 'A timeout occurred when downloading the file from the S3 bucket.'
             , TRUE
            );
         WHEN dpp_s3_var.ge_s3_operation_failure THEN
            RAISE_APPLICATION_ERROR(
               dpp_s3_var.gk_errcode_s3_operation_failure
             , 'An error occurred when downloading the file from the S3 bucket.'
             , TRUE
            );
      END check_download_task;

   EXCEPTION
      WHEN dpp_s3_var.ge_s3_folder_not_exists THEN
         RAISE_APPLICATION_ERROR(
            dpp_s3_var.gk_errcode_s3_folder_not_exists
          ,    'The S3 folder matching the prefix does not exist ('
            || COALESCE(TRIM(p_s3_prefix), '/')
            || ').'
          , TRUE
         );

   END download_file_from_s3;

END dpp_s3_krn;
/
