CREATE OR REPLACE PACKAGE dpp_s3_krn AUTHID DEFINER IS
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
*/

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
   );

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
   );

END dpp_s3_krn;
/
