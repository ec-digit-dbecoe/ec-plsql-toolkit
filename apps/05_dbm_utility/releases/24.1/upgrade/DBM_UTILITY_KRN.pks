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
     ,p_type IN dbm_streams.type%TYPE -- IN[23], OUT, ERR
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
    , p_deleted_flag IN dbm_applications.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Update or insert a version
   ---
   PROCEDURE upsert_ver (
      p_app_code dbm_versions.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE := -1
    , p_ver_status dbm_versions.ver_status%TYPE := '~'
    , p_next_op_type dbm_versions.next_op_type%TYPE := '~'
    , p_last_op_type dbm_versions.last_op_type%TYPE := '~'
    , p_last_op_status dbm_versions.last_op_status%TYPE := '~'
    , p_last_op_date dbm_versions.last_op_date%TYPE := TO_DATE('01/01/0001','DD/MM/YYYY')
    , p_installable dbm_versions.installable%TYPE := '~'
    , p_install_rollbackable dbm_versions.install_rollbackable%TYPE := '~'
    , p_upgradeable dbm_versions.upgradeable%TYPE := '~'
    , p_upgrade_rollbackable dbm_versions.upgrade_rollbackable%TYPE := '~'
    , p_uninstallable dbm_versions.uninstallable%TYPE := '~'
    , p_validable dbm_versions.validable%TYPE := '~'
    , p_precheckable dbm_versions.precheckable%TYPE := '~'
    , p_setupable dbm_versions.setupable%TYPE := '~'
    , p_deleted_flag dbm_versions.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Update or insert a file
   ---
   PROCEDURE upsert_fil (
      p_app_code dbm_files.app_code%TYPE
    , p_ver_code dbm_files.ver_code%TYPE
    , p_path dbm_files.path%TYPE
    , p_type dbm_files.type%TYPE
    , p_run_condition dbm_files.run_condition%TYPE := '~'
    , p_seq dbm_files.seq%TYPE := 999999999
    , p_hash dbm_files.hash%TYPE := '~'
    , p_status dbm_files.status%TYPE := '~'
    , p_run_status dbm_files.run_status%TYPE := '~'
    , p_run_date dbm_files.run_date%TYPE := TO_DATE('01/01/0001','DD/MM/YYYY')
    , p_deleted_flag dbm_files.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Update or insert a parameter
   ---
   PROCEDURE upsert_par (
      p_app_code dbm_parameters.app_code%TYPE
    , p_ver_code dbm_parameters.ver_code%TYPE
    , p_name dbm_parameters.name%TYPE
    , p_value dbm_parameters.name%TYPE := '~'
    , p_deleted_flag dbm_files.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Update or insert a variable
   ---
   PROCEDURE upsert_var (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
    , p_value dbm_variables.value%TYPE := '~'
    , p_descr dbm_variables.descr%TYPE := '~'
    , p_seq dbm_variables.seq%TYPE := 999
    , p_nullable dbm_variables.nullable%TYPE := '~'
    , p_convert_value_sql dbm_variables.convert_value_sql%TYPE := '~'
    , p_check_value_sql dbm_variables.check_value_sql%TYPE := '~'
    , p_default_value_sql dbm_variables.default_value_sql%TYPE := '~'
    , p_check_error_msg dbm_variables.check_error_msg%TYPE := '~'
    , p_deleted_flag dbm_variables.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Update or insert a database object
   ---
   PROCEDURE upsert_obj (
      p_app_code dbm_objects.app_code%TYPE
    , p_ver_code dbm_objects.ver_code%TYPE
    , p_name dbm_objects.name%TYPE
    , p_checksum dbm_objects.checksum%TYPE := '~'
    , p_condition dbm_objects.condition%TYPE := '~'
    , p_deleted_flag dbm_objects.deleted_flag%TYPE := '~'
   )
   ;
   ---
   -- Set variable value
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
    , p_ver_status dbm_versions.ver_status%TYPE := '~'
    , p_next_op_type dbm_versions.next_op_type%TYPE := '~'
    , p_last_op_type dbm_versions.last_op_type%TYPE := '~'
    , p_last_op_status dbm_versions.last_op_status%TYPE := '~'
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
    , p_run_condition dbm_files.run_condition%TYPE := '~'
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
   -- Make database object inventory
   ---
   PROCEDURE make_inventory (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
   ;
   ---
   -- Set current version of an application
   ---
   PROCEDURE set_current (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE -- no support for all
    , p_ver_code IN dbm_versions.ver_code%TYPE
    , p_guess_curr IN BOOLEAN := FALSE
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
   -- Guess and set current version
   ---
   PROCEDURE guess_set_current (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_versions.app_code%TYPE
    , p_set_curr IN BOOLEAN := FALSE
    , p_best IN BOOLEAN := FALSE
   )
   ;
   ---
   -- Get list of database objects currently installed
   ---
   PROCEDURE list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_checksum IN VARCHAR2 := 'Y'
    , p_condition IN VARCHAR2 := 'Y'
    , p_public IN VARCHAR2 := 'N'
    , p_app_code dbm_objects.app_code%TYPE := NULL
    , p_ver_code dbm_objects.ver_code%TYPE := NULL
   )
   ;
   ---
   -- Get list of database objects currently installed
   ---
   FUNCTION list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_checksum IN VARCHAR2 := 'Y'
    , p_condition IN VARCHAR2 := 'Y'
    , p_public IN VARCHAR2 := 'N'
    , p_app_code dbm_objects.app_code%TYPE := NULL
    , p_ver_code dbm_objects.ver_code%TYPE := NULL
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
    , p_public IN VARCHAR2 := 'N'
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
   -- Reset cache
   ---
   PROCEDURE reset_cache
   ;
   ---
   -- Load cache from DB
   ---
   PROCEDURE load_cache
   ;
   ---
   -- Save cache into DB
   ---
   PROCEDURE save_cache (
      p_app_code dbm_applications.app_code%TYPE := NULL
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
   ---
   -- Do nothing to instantiate package/session
   ---
   PROCEDURE noop
   ;
--#endif 0
END dbm_utility_krn;
/