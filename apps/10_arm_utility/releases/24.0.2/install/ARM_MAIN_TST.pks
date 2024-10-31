CREATE OR REPLACE PACKAGE arm_main_tst
AUTHID DEFINER
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
* Unit test package of the ARM_MAIN_KRN package.
*
* v24.0; 2023-12-14; malmjea; initial version
*/

   -- default log directory
   gk_tst_directory        CONSTANT VARCHAR2(100)  := 'DATA_PUMP_DIR';
   
   -- default test log file
   gk_tst_log_file         CONSTANT VARCHAR2(100)  := 'arm_main_tst.log';
   
   -- default source directory
   gk_tst_src_directory    CONSTANT VARCHAR2(100)  := 'DATA_PUMP_DIR';
   
   -- default destination directory
   gk_tst_dst_directory    CONSTANT VARCHAR2(100)  := 'DATA_PUMP_DIR';
   
   -- default source file
   gk_tst_src_file_name    CONSTANT VARCHAR2(100)  := 'arm_main_tst_src.txt';
   
   -- default destination file
   gk_tst_dst_file_name    CONSTANT VARCHAR2(100)  := 'arm_main_tst_dst.txt';
   
   PROCEDURE open_tst_log_file;
   PROCEDURE create_source_file;
   PROCEDURE delete_source_file;
   PROCEDURE delete_dest_file;
   PROCEDURE create_files;
   PROCEDURE clear_files;
   PROCEDURE reset_dir;
   
   --%suite(Archive Manager main)
   
   --%suitepath(arm_main)

   --%afterall(close file)
   PROCEDURE close_tst_log_file;
   
   --%test(00010 - raise error with message)
   PROCEDURE raise_error_message;
   
   --%test(00020 - raise error without message)
   PROCEDURE raise_error_no_message;

   --%test(00030 - set invalid directory)
   PROCEDURE set_directory_invalid;

   --%test(00040 - set valid directory)
   PROCEDURE set_directory_valid;
   
   --%test(00050 - init log file with invalid directory and file)
   PROCEDURE init_log_file_invalid;
   
   --%test(00060 - init log file with valid directory and file)
   PROCEDURE init_log_file_valid;
   
   --%test(00070 - close log file)
   --%beforetest(open_tst_log_file)
   PROCEDURE close_log_file;
   
   --%test(00080 - compress file with invalid source directory)
   --%throws(-20001)
   PROCEDURE compress_file_inv_src_dir;
   
   --%test(00090 - compress file with invalid source file)
   --%throws(-20003)
   PROCEDURE compress_file_inv_src_file;
   
   --%test(00100 - compress file with invalid destination directory)
   --%throws(-20002)
   PROCEDURE compress_file_inv_dst_dir;
   
   --%test(00110 - compress file with invalid destination file)
   --%throws(-20004)
   PROCEDURE compress_file_inv_dst_file;

   --%test(00120 - uncompress file with invalid source directory)
   --%throws(-20001)
   PROCEDURE uncompress_file_inv_src_dir;
   
   --%test(00130 - uncompress file with invalid source file)
   --%throws(-20003)
   PROCEDURE uncompress_file_inv_src_file;
   
   --%test(00140 - uncompress file with invalid destination directory)
   --%throws(-20002)
   PROCEDURE uncompress_file_inv_dst_dir;
   
   --%test(00150 - uncompress file with invalid destination file)
   --%throws(-20004)
   PROCEDURE uncompress_file_inv_dst_file;
   
   --%test(00160 - compress file with non existing source directory)
   --%throws(-20016)
   PROCEDURE compress_file_non_exist_src_dir;

   --%test(00170 - compress file with non existing source file)
   --%throws(-20017)
   PROCEDURE compress_file_non_exist_src_file;
   
   --%test(00180 - compress file with non existing destination directory)
   --%beforetest(create_source_file)
   --%aftertest(delete_source_file)
   --%throws(-20018)
   PROCEDURE compress_file_non_exist_dst_dir;

   --%test(00190 - compress file with valid parameters)
   --%beforetest(create_source_file)
   --%aftertest(delete_source_file)
   --%aftertest(delete_dest_file)
   PROCEDURE compress_file_all_valid;
   
   --%test(00200 - uncompress file with non existing source directory)
   --%throws(-20016)
   PROCEDURE uncompress_file_non_exist_src_dir;

   --%test(00210 - uncompress file with non existing source file)
   --%throws(-20017)
   PROCEDURE uncompress_file_non_exist_src_file;

   --%test(00220 - uncompres with valid parameters)
   --%beforetest(create_source_file)
   --%aftertest(delete_source_file)
   PROCEDURE uncompress_file_all_valid;

   --%test(00230 - reset files)
   --%beforetest(create_files)
   PROCEDURE reset_files;

   --%test(00240 - add file with invalid file name)
   --%beforetest(create_files)
   --%aftertest(clear_files)
   --%throws(-20005)
   PROCEDURE add_file_inv_file_name;

   --%test(00250 - add valid file)
   --%beforetest(create_files)
   --%aftertest(clear_files)
   PROCEDURE add_file;

   --%test(00260 - build file list no directory)
   --%beforetest(reset_dir)
   --%throws(-20006)
   PROCEDURE build_file_list_no_dir;

   --%test(00270 - build file list no prefix)
   --%beforetest(reset_dir)
   --%throws(-20007)
   PROCEDURE build_file_list_no_prefix;

   --%test(00280 - concat file with invalid directory)
   --%throws(-20006)
   PROCEDURE concat_file_inv_dir;

   --%test(00290 - concat file with invalid file name)
   --%throws(-20005)
   PROCEDURE concat_file_inv_file;
   
   --%test(00300 - extract file with invalid directory)
   --%throws(-20006)
   PROCEDURE extract_file_inv_dir;

   --%test(00310 - extract file with invalid file name)
   --%throws(-20005)
   PROCEDURE extract_file_inv_file;

   --%test(00320 - extract file with invalid file size)
   --%throws(-20011)
   PROCEDURE extract_file_inv_size;
   
END arm_main_tst;
/
