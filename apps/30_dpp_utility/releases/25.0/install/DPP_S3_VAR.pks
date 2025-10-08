CREATE OR REPLACE PACKAGE dpp_s3_var AUTHID DEFINER IS
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
* Define the variables, constants and exception for the S3 bucket service
* package.
*/

   -- Exception: S3 service only available on AWS
   ge_service_not_available                     EXCEPTION;
   gk_errcode_service_not_available    CONSTANT PLS_INTEGER       := -20100;
   PRAGMA EXCEPTION_INIT(
      ge_service_not_available
    , gk_errcode_service_not_available
   );

   -- Exception: invalid parameter
   ge_inv_parameter                             EXCEPTION;
   gk_errcode_inv_parameter            CONSTANT PLS_INTEGER       := -20101;
   PRAGMA EXCEPTION_INIT(ge_inv_parameter, gk_errcode_inv_parameter);

   -- Exception: directory does not exist
   ge_dir_not_exists                            EXCEPTION;
   gk_errcode_dir_not_exists           CONSTANT PLS_INTEGER       := -20102;
   PRAGMA EXCEPTION_INIT(ge_dir_not_exists, gk_errcode_dir_not_exists);

   -- Exception: file does not exist
   ge_file_not_exists                           EXCEPTION;
   gk_errcode_file_not_exists          CONSTANT PLS_INTEGER       := -20103;
   PRAGMA EXCEPTION_INIT(ge_file_not_exists, gk_errcode_file_not_exists);

   -- Exception: S3 operation failure
   ge_s3_operation_failure                      EXCEPTION;
   gk_errcode_s3_operation_failure     CONSTANT PLS_INTEGER       := -20104;
   PRAGMA EXCEPTION_INIT(
      ge_s3_operation_failure
    , gk_errcode_s3_operation_failure
   );

   -- Exception: S3 operation timeout
   ge_s3_operation_timeout                      EXCEPTION;
   gk_errcode_s3_operation_timeout     CONSTANT PLS_INTEGER       := -20105;
   PRAGMA EXCEPTION_INIT(
      ge_s3_operation_timeout
    , gk_errcode_s3_operation_timeout
   );

   -- Exception: S3 folder does not exists
   ge_s3_folder_not_exists                      EXCEPTION;
   gk_errcode_s3_folder_not_exists     CONSTANT PLS_INTEGER       := -29283;
   PRAGMA EXCEPTION_INIT(
      ge_s3_folder_not_exists
    , gk_errcode_s3_folder_not_exists
   );

   -- successful task
   gk_task_status_success              CONSTANT VARCHAR2(500)     :=
         'The task finished successfully.';

   -- failed task
   gk_task_status_failure              CONSTANT VARCHAR2(500)     :=
         'The task failed.';

   -- S3 timeout in seconds
   gk_s3_timeout                       CONSTANT PLS_INTEGER       := 300;

   -- S3 sleep time in seconds
   gk_s3_sleep                         CONSTANT PLS_INTEGER       := 5;

END dpp_s3_var;
/
