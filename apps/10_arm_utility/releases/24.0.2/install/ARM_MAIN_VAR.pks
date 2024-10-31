CREATE OR REPLACE PACKAGE arm_main_var
AUTHID DEFINER
ACCESSIBLE BY (PACKAGE arm_util_krn, PACKAGE arm_main_krn)
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
* Archive manager variables.
*
* v24.0; 2023-12-11; maljea; initial version
*/

   -- path subtype
   SUBTYPE path_type IS VARCHAR2(100 CHAR);

   -- file list type
   TYPE arm_file_names_set IS TABLE OF VARCHAR2(200 CHAR);
   
   -- exception: invalid Oracle directory name
   ge_inv_orcl_dir_name          EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_orcl_dir_name, -20000);
   
   -- exception: invalid source directory
   ge_inv_src_dir                EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_src_dir, -20001);

   -- exception: invalid destination directory
   ge_inv_dst_dir                EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_dst_dir, -20002);

   -- exception: invalid source file name
   ge_inv_src_file               EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_src_file, -20003);

   -- exception: invalid destination file name
   ge_inv_dst_file               EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_dst_file, -20004);

   -- exception: invalid file name
   ge_inv_file_name              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_file_name, -20005);

   -- exception: invalid directory name
   ge_inv_dir_name               EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_dir_name, -20006);

   -- exception: invalid file prefix
   ge_inv_file_prefix            EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_file_prefix, -20007);

   -- exception: directory does not exist
   ge_dir_not_exist              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_dir_not_exist, -20008);

   -- exception: file not open
   ge_file_not_open              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_file_not_open, -20009);

   -- exception: no files to to be concatenated
   ge_no_file_to_concat          EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_no_file_to_concat, -20010);

   -- exception: invalid file size
   ge_inv_file_size              EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_file_size, -20011);

   -- exception: no files to be extracted
   ge_no_file_to_extract         EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_no_file_to_extract, -20012);

   -- exception: invalid manifest file name
   ge_inv_manifest_file_name     EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_inv_manifest_file_name, -20013);

   -- exception: manifest file not correctly formatted
   ge_manifest_format            EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_manifest_format, -20014);

   -- exception: file size not mentioned
   ge_dump_file_size_missing     EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_dump_file_size_missing, -20015);

   -- exception: source directory does not exist
   ge_src_dir_not_exist          EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_src_dir_not_exist, -20016);

   -- exception: source file does not exist
   ge_src_file_not_exist         EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_src_file_not_exist, -20017);

   -- exception: destination directory does not exist
   ge_dst_dir_not_exist          EXCEPTION;
   PRAGMA EXCEPTION_INIT(ge_dst_dir_not_exist, -20018);

   -- exception: Oracle directory does not exist
   ge_orcl_dir_not_exist         EXCEPTION;
#ifdef ENVAWS
   PRAGMA EXCEPTION_INIT(ge_orcl_dir_not_exist, -20199);
#endif
#ifdef ENVDC
   PRAGMA EXCEPTION_INIT(ge_orcl_dir_not_exist, -29532);
#endif

   -- timestamp format
   gk_timestamp_format  CONSTANT VARCHAR2(30 CHAR) :=
      'YYYY-MM-DD HH24:MI:SSFF3';
   
END arm_main_var;
/
