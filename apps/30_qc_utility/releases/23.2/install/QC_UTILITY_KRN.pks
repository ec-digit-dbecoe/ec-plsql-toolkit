CREATE OR REPLACE PACKAGE qc_utility_krn AS
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
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','qc_utility_krn','public','   ;')
--#if 0
   FUNCTION version
   RETURN VARCHAR2
   ;
   ---
   -- Get list of columns of a given index
   ---
   FUNCTION get_ind_columns (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get trigger body as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_trigger_body (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get view text as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_view_text (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get mview query as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_mview_query (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get constraint search_condition as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_con_search_condition (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get list of columns of a given constraint
   ---
   FUNCTION get_cons_columns (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Check if 2 constraints are duplicated (one is a subset of the other)
   -- and returns the name of the redondant one (to be dropped)
   -- When they have the same set of columns, return UK before PK, random otherwise
   ---
   FUNCTION get_duplicate_cons (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_constraint_name1 IN VARCHAR2
    , p_constraint_name2 IN VARCHAR2
   )
   RETURN all_constraints.constraint_name%TYPE
   ;
   ---
   -- Determine index type
   ---
   FUNCTION get_ind_type (
      p_owner IN VARCHAR2 --TBD
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get constraint corresponding to an index
   ---
   FUNCTION get_ind_con (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get constraint qualifier
   ---
   FUNCTION get_cons_qualifier (
      p_owner IN VARCHAR2
    , p_constraint_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get the type of constraint a column is involved in
   -- Returns P, U, R or NULL (in that order of priority)
   ---
   FUNCTION get_col_cons_type (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   RETURN all_constraints.constraint_type%TYPE
   ;
   ---
   -- Replace variables
   ---
   FUNCTION replace_vars (
      p_object_type IN VARCHAR2
    , p_owner IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_pattern IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Generate fix name
   ---
   FUNCTION gen_fix_name (
      p_object_type IN VARCHAR2
    , p_owner IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_fix_pattern IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Extended regular expression matching
   ---
   FUNCTION ext_regexp_like (
      p_object_type IN VARCHAR2
    , p_owner IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_pattern IN VARCHAR2
   )
   RETURN INTEGER
   ;
   ---
   -- Register a dictionary entry
   ---
   PROCEDURE register_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2
    , p_dict_value IN VARCHAR2 := NULL
    , p_comments   IN VARCHAR2 := NULL
   )
   ;
   -- Init
   PROCEDURE init
   ;
   ---
   -- Search dictionary value
   ---
   FUNCTION search_dictionary_value (
      p_dict_name IN qc_dictionary_entries.dict_name%TYPE
    , p_dict_value IN qc_dictionary_entries.dict_key%TYPE
   )
   RETURN qc_dictionary_entries.dict_key%TYPE
   ;
   ---
   -- Extract table aliases from primary keys
   ---
   PROCEDURE extract_table_aliases_from_pk (
      p_match_pattern  IN VARCHAR2 := '^{app alias_}([A-Z]+)(_*UK|_*PK)([0-9])*$'
    , p_replace_string IN VARCHAR2 := '\1'
    , p_force_update   IN INTEGER := 0
    , p_app_alias      IN VARCHAR2 := NULL -- NULL means ALL
    )
   ;
   ---
   -- Extract entity names from table names
   -- By default, remove application alias prefix
   ---
   PROCEDURE extract_entities_from_tables (
      p_match_pattern  IN VARCHAR2 := '^{app alias_}(.+)$'
    , p_replace_string IN VARCHAR2 := '\1'
    , p_force_update   IN INTEGER := 0
    , p_app_alias      IN VARCHAR2 := NULL -- NULL means ALL
    , p_singularify    IN INTEGER := 0 -- Make entity name singular
   )
   ;
   ---
   -- Get object count from QC000 statistics
   ---
   FUNCTION object_count_from_stat (
      p_qc_code IN qc_run_stats.qc_code%TYPE
    , p_object_type IN qc_run_stats.object_type%TYPE
   )
   RETURN qc_run_stats.object_count%TYPE
   ;
   ---
   -- Return objects sorted by dependencies (= reverse order of compilation)
   ---
   FUNCTION sorted_objects
   RETURN qc_utility_var.gt_sorted_object_type PIPELINED
   ;
   ---
   -- Set PLSCOPE settings
   ---
   PROCEDURE set_plscope (
      p_identifiers      IN VARCHAR2                 -- ALL:NONE:PUBLIC:SQL:PLSQL
    , p_statements       IN VARCHAR2 := NULL         -- ALL:NONE
   )
   ;
   ---
   -- Enable PLSCOPE
   ---
   PROCEDURE enable_plscope
   ;
   ---
   -- Disable PLSCOPE
   ---
   PROCEDURE disable_plscope
   ;
   ---
   -- Compile PL/SQL code with requested options
   ---
   PROCEDURE compile_for_plscope (
      p_identifiers      IN VARCHAR2 := 'ALL'         -- ALL:NONE:PUBLIC:SQL:PLSQL
    , p_statements       IN VARCHAR2 := 'ALL'         -- ALL:NONE
    , p_compile_code     IN VARCHAR2 := 'INCREMENTAL' -- ALL:INCREMENTAL:NONE
    , p_compile_synonyms IN VARCHAR2 := 'NONE'        -- ALL:NONE
   )
   ;
   ---
   -- Analyse impact
   ---
   PROCEDURE analyse_impact
   ;
   ---
   -- Get quality check report
   ---
   FUNCTION get_report (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
   ,  p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL -- NULL for all
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Get quality check results as xUnit XML (xUnit test execution format)
   ---
   FUNCTION get_xunit_xml (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
    , p_ver_id IN INTEGER := 2 -- version
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Get quality check results as sonar XML (sonar generic test execution format)
   ---
   FUNCTION get_sonar_xml (
      p_run_id qc_runs.run_id%TYPE := NULL -- NULL for latest run
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Get quality check results as sonar JSON (sonar generic issue format)
   -- (see https:
   ---
   FUNCTION get_sonar_json (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
    , p_file_path IN VARCHAR2 := NULL -- path of the file to which results must be attached
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Send report
   ---
   PROCEDURE send_report (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest report
    , p_to IN VARCHAR2 := NULL -- alternate TO
    , p_cc IN VARCHAR2 := NULL -- alternate CC
    , p_bcc IN VARCHAR2 := NULL -- alternate BCC
    , p_force_send IN VARCHAR2 := 'N' -- Send empty report Y/N
    , p_app_alias qc_apps.app_alias%TYPE := NULL -- NULL means ALL
   )
   ;
   ---
   -- Get database changes made between 2 date/time or 2 events
   ---
   FUNCTION get_db_changes (
      p_start_datetime IN VARCHAR2 := NULL
    , p_end_datetime IN VARCHAR2 := NULL
    , p_start_run_id IN qc_runs.run_id%TYPE := NULL
    , p_end_run_id IN qc_runs.run_id%TYPE := NULL
    , p_app_alias qc_apps.app_alias%TYPE := NULL -- NULL means ALL
   )
   RETURN sys.odcivarchar2list pipelined
   ;
   ---
   -- Send db changes by email
   ---
   PROCEDURE send_db_changes (
      p_start_datetime IN VARCHAR2 := NULL
    , p_end_datetime IN VARCHAR2 := NULL
    , p_start_run_id IN qc_runs.run_id%TYPE := NULL
    , p_end_run_id IN qc_runs.run_id%TYPE := NULL
    , p_to IN VARCHAR2 := NULL -- alternate TO
    , p_cc IN VARCHAR2 := NULL -- alternate CC
    , p_bcc IN VARCHAR2 := NULL -- alternate BCC
    , p_force_send IN VARCHAR2 := 'N' -- Send empty report Y/N
    , p_app_alias qc_apps.app_alias%TYPE := NULL -- NULL means ALL
   )
   ;
   PROCEDURE check_all (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
    , p_app_alias IN qc_apps.app_alias%TYPE := NULL
   )
   ;
   ---
   -- Perform one check
   ---
   PROCEDURE check_one (
      p_qc_code IN qc_run_msgs.qc_code%TYPE
    , p_app_alias IN qc_apps.app_alias%TYPE := NULL
   )
   ;
   ---
   -- Run quality checks if DDL detected since last run
   ---
   PROCEDURE run_if_ddl_detected
   ;
   ---
   -- Fix PL/SQL anomalies
   ---
   PROCEDURE fix_plsql_anomalies (
      p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
   )
   ;
   ---
   -- Fix anomalies
   ---
   PROCEDURE fix_anomalies (
      p_qc_code IN qc_run_msgs.qc_code%TYPE
    , p_object_type IN qc_run_msgs.object_type%TYPE := NULL
    , p_object_name IN qc_run_msgs.object_name%TYPE := NULL
    , p_fix_op IN qc_run_msgs.fix_op%TYPE := NULL
    , p_msg_type IN qc_run_msgs.msg_type%TYPE := NULL
    , p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
   )
   ;
   ---
   -- Insert a pattern
   ---
   PROCEDURE insert_pattern (
      p_app_alias qc_patterns.app_alias%TYPE
    , p_object_type qc_patterns.object_type%TYPE
    , p_check_pattern qc_patterns.check_pattern%TYPE := NULL
    , p_include_pattern qc_patterns.include_pattern%TYPE := NULL
    , p_exclude_pattern qc_patterns.exclude_pattern%TYPE := NULL
    , p_fix_pattern qc_patterns.fix_pattern%TYPE := NULL
    , p_anti_pattern qc_patterns.anti_pattern%TYPE := NULL
    , p_msg_type qc_patterns.msg_type%TYPE := NULL
   )
   ;
   ---
   -- Update one pattern (or several ones if wildecard used)
   ---
   PROCEDURE update_pattern (
      p_app_alias qc_patterns.app_alias%TYPE
    , p_object_type qc_patterns.object_type%TYPE
    , p_check_pattern qc_patterns.check_pattern%TYPE := NULL
    , p_include_pattern qc_patterns.include_pattern%TYPE := NULL
    , p_exclude_pattern qc_patterns.exclude_pattern%TYPE := NULL
    , p_fix_pattern qc_patterns.fix_pattern%TYPE := NULL
    , p_anti_pattern qc_patterns.anti_pattern%TYPE := NULL
    , p_msg_type qc_patterns.msg_type%TYPE := NULL
   )
   ;
   ---
   -- Upsert pattern (update or insert if not found)
   ---
   PROCEDURE upsert_pattern (
      p_app_alias qc_patterns.app_alias%TYPE
    , p_object_type qc_patterns.object_type%TYPE
    , p_check_pattern qc_patterns.check_pattern%TYPE := NULL
    , p_include_pattern qc_patterns.include_pattern%TYPE := NULL
    , p_exclude_pattern qc_patterns.exclude_pattern%TYPE := NULL
    , p_fix_pattern qc_patterns.fix_pattern%TYPE := NULL
    , p_anti_pattern qc_patterns.anti_pattern%TYPE := NULL
    , p_msg_type qc_patterns.msg_type%TYPE := NULL
   )
   ;
   ---
   -- Delete one pattern (or several ones if wildecard used)
   ---
   PROCEDURE delete_pattern (
      p_app_alias qc_patterns.app_alias%TYPE
    , p_object_type qc_patterns.object_type%TYPE
   )
   ;
   ---
   -- Insert a dictionary entry
   ---
   PROCEDURE insert_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2
    , p_dict_value IN VARCHAR2 := NULL
    , p_comments   IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Update one dictionary entry (or several ones if wildcard used)
   ---
   PROCEDURE update_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2
    , p_dict_value IN VARCHAR2 := NULL
    , p_comments   IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Upsert one dictionary entry (or several ones if wildcard used)
   ---
   PROCEDURE upsert_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2
    , p_dict_value IN VARCHAR2 := NULL
    , p_comments   IN VARCHAR2 := NULL
   )
   ;
   ---
   -- Delete a dictionary entry
   ---
   PROCEDURE delete_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2 := NULL
   )
   ;
--#endif 0
END qc_utility_krn;
/
