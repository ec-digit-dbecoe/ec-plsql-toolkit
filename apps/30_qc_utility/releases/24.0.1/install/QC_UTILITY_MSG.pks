CREATE OR REPLACE PACKAGE qc_utility_msg AS
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
--
-- WARNING
-- This package implements the abstraction layer that hide the complexity of record versioning to above layers.
-- It is the result of a code generator and should therefore not been changed in any way.
-- Any change should rather be made to the template that is used to generate this package.
--
   TYPE msg_table IS TABLE OF qc_run_msgs%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE msg_ivid_table IS TABLE OF qc_run_msgs.msg_ivid%TYPE INDEX BY BINARY_INTEGER;
   TYPE msg_irid_table IS TABLE OF qc_run_msgs.msg_irid%TYPE INDEX BY BINARY_INTEGER;
   --
   -- Load a set of records into memory
   -- Take the specified version of these records (last version if none specified)
   -- Limit records to those matching search criteria (filter)
   --
   PROCEDURE load_msg (
      t_msg OUT msg_table
     ,p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_date IN DATE := NULL
     ,p_run_id_to IN qc_run_msgs.run_id_to%TYPE := NULL
     ,p_run_id_from IN qc_run_msgs.run_id_to%TYPE := NULL
   )
   ;
   --
   -- Save a set of records into database
   -- Records are always saved as part of the last version
   -- Search criteria (filter) must be identical to the ones used for loading
   --
   PROCEDURE save_msg (
      t_msg IN msg_table
     ,p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
   )
   ;
   --
   -- Insert a non-existing record into database table
   --
   PROCEDURE insert_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   ;
   --
   -- Update an existing record in database table
   -- (create new record version)
   --
   PROCEDURE update_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   ;
   --
   -- Delete an existing record from database table
   -- (close record version)
   --
   PROCEDURE delete_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   ;
   --
   -- Count number of records impacted by a given event
   --
   FUNCTION count_impacted_records (
      p_run_id qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER
   ;
   --
   -- Print a record
   --
   PROCEDURE print_msg (
      r_msg IN qc_run_msgs%ROWTYPE
   )
   ;
   ---
   -- Restore records from a previous version
   ---
   PROCEDURE restore_msg (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Restore all records from a previous version
   ---
   PROCEDURE restore_all_msg (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Undo changes made by an event
   ---
   PROCEDURE undo_msg (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Get record based on its record number
   ---
   FUNCTION get_msg (
      p_msg_irid IN qc_run_msgs.msg_irid%TYPE
     ,p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_run_msgs%ROWTYPE
   ;
   ---
   -- Compare versions
   ---
   FUNCTION compare_versions (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id_1 IN qc_runs.run_id%TYPE := NULL
     ,p_run_id_2 IN qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER -- 0=same, <>=different
   ;
   ---
   -- Sort table of records
   ---
   PROCEDURE sort_msg (
      t_msg IN OUT msg_table
   )
   ;
END;
/

