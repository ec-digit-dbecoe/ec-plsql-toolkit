CREATE OR REPLACE PACKAGE dbm_utility_krn AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License as published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE dbm_utility_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','dbm_utility_krn','public','   ;')
--#if 0
   ---
   -- Output line to the in/out/err stream of a command
   ---
   PROCEDURE output_line (
      p_cmd_id IN dbm_streams.cmd_id%TYPE
     ,p_type IN dbm_streams.type%TYPE -- IN, OUT, ERR
     ,p_text IN VARCHAR2
     ,p_base64 IN BOOLEAN := FALSE
     ,p_line IN dbm_streams.line%TYPE := NULL -- to force line number
   )
   ;
   ---
   -- Output line to the in/out/err stream buffer
   ---
   PROCEDURE buffer_line (
      p_cmd_id IN dbm_streams.cmd_id%TYPE
     ,p_type IN dbm_streams.type%TYPE -- IN, OUT, ERR
     ,p_text IN dbm_streams.text%TYPE
   )
   ;
   ---
   -- Flush stream buffer
   ---
   PROCEDURE flush_buffer
   ;
   ---
   -- Update or insert an application
   ---
   PROCEDURE upsert_app (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_seq IN dbm_applications.seq%TYPE := -1
    , p_ver_code IN dbm_applications.ver_code%TYPE := '~'
    , p_ver_status IN dbm_applications.ver_status%TYPE := '~'
    , p_home_dir IN dbm_applications.home_dir%TYPE := '~'
   )
   ;
   ---
   -- Set parameter value
   ---
   PROCEDURE set_var_value (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
    , p_value dbm_variables.value%TYPE
   )
   ;
   PROCEDURE create_application (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_seq IN dbm_applications.seq%TYPE := NULL
   )
   ;
   ---
   -- Update version time status
   ---
   PROCEDURE recompute_ver_statuses (
      p_app_code IN dbm_applications.app_code%TYPE := NULL
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
   )
   ;
   ---
   -- Update version properties
   ---
   PROCEDURE update_ver (
      p_app_code dbm_versions.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_status dbm_versions.ver_status%TYPE := NULL
    , p_next_op_type dbm_versions.next_op_type%TYPE := NULL
    , p_last_op_type dbm_versions.last_op_type%TYPE := NULL
    , p_last_op_status dbm_versions.last_op_status%TYPE := NULL
   )
   ;
   ---
   -- Update file properties
   ---
   PROCEDURE update_fil (
      p_path dbm_files.ver_code%TYPE
    , p_hash dbm_files.hash%TYPE := '~'
    , p_status dbm_files.status%TYPE := '~'
    , p_run_status dbm_files.run_status%TYPE := '~'
    , p_raise_exception IN BOOLEAN := TRUE
   )
   ;
   ---
   -- Give feedback on file integrity
   ---
   PROCEDURE report_on_files_integrity (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
   ;
   ---
   -- Check app dependency
   ---
   PROCEDURE check_dependency (
      p_app_code dbm_applications.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE
    , p_requires IN VARCHAR2
   )
   ;
   ---
   -- Get list of database objects currently installed
   ---
   PROCEDURE list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_checksum IN VARCHAR2 := 'Y'
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
   )
   ;
   ---
   -- Get list of database objects currently installed
   ---
   FUNCTION list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_checksum IN VARCHAR2 := 'Y'
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
   )
   RETURN sys.odcivarchar2list PIPELINED
   ;
   ---
   -- Check for missing/extra/invalid database objects
   ---
   PROCEDURE check_objects (
      p_app_code IN dbm_versions.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
    , p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_last_op_type IN dbm_versions.last_op_type%TYPE := 'VALIDATE'
   )
   ;
   ---
   -- Parse configuration file
   ---
   PROCEDURE parse_configuration (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
   )
   ;
   ---
   -- Show application properties and files
   ---
   PROCEDURE display_application (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
   )
   ;
   ---
   -- Parse list of files returned by scan-files
   ---
   PROCEDURE parse_files (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
   )
   ;
   ---
   -- Parse hashes returned by get-hashes
   ---
   PROCEDURE parse_hashes (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_op IN VARCHAR2 -- set-hashes / chk-hashes
    , p_apps_dir IN VARCHAR2
   )
   ;
   ---
   -- Execute a command and return its id
   ---
   FUNCTION begin_command (
      p_command_line IN dbm_commands.command_line%TYPE
    , p_cmd_id IN dbm_commands.command_line%TYPE := NULL
   )
   RETURN PLS_INTEGER
   ;
   ---
   -- Execute a command
   ---
   PROCEDURE begin_command (
      p_command_line IN dbm_commands.command_line%TYPE
    , p_cmd_id IN dbm_commands.command_line%TYPE := NULL
   )
   ;
   ---
   -- Terminate a command
   ---
   PROCEDURE end_command (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_exit_code IN dbm_commands.exit_code%TYPE
   )
   ;
   ---
   -- Define operating system
   ---
   PROCEDURE set_os (
      p_os_name IN VARCHAR2
   )
   ;
--#endif 0
END dbm_utility_krn;
/
