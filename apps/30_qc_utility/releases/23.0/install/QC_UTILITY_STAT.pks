CREATE OR REPLACE PACKAGE qc_utility_stat AS
--
-- WARNING
-- This package implements the abstraction layer that hide the complexity of record versioning to above layers.
-- It is the result of a code generator and should therefore not been changed in any way.
-- Any change should rather be made to the template that is used to generate this package.
--
   TYPE stat_table IS TABLE OF qc_run_stats%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE stat_ivid_table IS TABLE OF qc_run_stats.stat_ivid%TYPE INDEX BY BINARY_INTEGER;
   TYPE stat_irid_table IS TABLE OF qc_run_stats.stat_irid%TYPE INDEX BY BINARY_INTEGER;
   --
   -- Load a set of records into memory
   -- Take the specified version of these records (last version if none specified)
   -- Limit records to those matching search criteria (filter)
   --
   PROCEDURE load_stat (
      t_stat OUT stat_table
     ,p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_date IN DATE := NULL
     ,p_run_id_to IN qc_run_stats.run_id_to%TYPE := NULL
     ,p_run_id_from IN qc_run_stats.run_id_to%TYPE := NULL
   )
   ;
   --
   -- Save a set of records into database
   -- Records are always saved as part of the last version
   -- Search criteria (filter) must be identical to the ones used for loading
   --
   PROCEDURE save_stat (
      t_stat IN stat_table
     ,p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
   )
   ;
   --
   -- Insert a non-existing record into database table
   --
   PROCEDURE insert_stat (
      r_stat IN qc_run_stats%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   ;
   --
   -- Update an existing record in database table
   -- (create new record version)
   --
   PROCEDURE update_stat (
      r_stat IN qc_run_stats%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   ;
   --
   -- Delete an existing record from database table
   -- (close record version)
   --
   PROCEDURE delete_stat (
      r_stat IN qc_run_stats%ROWTYPE
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
   PROCEDURE print_stat (
      r_stat IN qc_run_stats%ROWTYPE
   )
   ;
   ---
   -- Restore records from a previous version
   ---
   PROCEDURE restore_stat (
      p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Restore all records from a previous version
   ---
   PROCEDURE restore_all_stat (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Undo changes made by an event
   ---
   PROCEDURE undo_stat (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   ;
   ---
   -- Get record based on its record number
   ---
   FUNCTION get_stat (
      p_stat_irid IN qc_run_stats.stat_irid%TYPE
     ,p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_run_stats%ROWTYPE
   ;
   ---
   -- Compare versions
   ---
   FUNCTION compare_versions (
      p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id_1 IN qc_runs.run_id%TYPE := NULL
     ,p_run_id_2 IN qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER -- 0=same, <>=different
   ;
   ---
   -- Sort table of records
   ---
   PROCEDURE sort_stat (
      t_stat IN OUT stat_table
   )
   ;
END;
/

