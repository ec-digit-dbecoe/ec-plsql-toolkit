CREATE OR REPLACE PACKAGE BODY qc_utility_krn AS
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
   ---
   -- Return version number
   ---
--#begin public
   FUNCTION version
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      -- 1.0.0: Initial version
      -- 1.1.0: Added multi-schema support and inventory of objects (QC000)
      -- 1.2.0: Added checking and automated fixing of PL/SQL identifiers naming conventions (QC019)
      -- 1.2.1: Replace USER with sys_context('userenv','current_user')
      -- 21.0: Added check of not null constraint names to QC008 (for Oracle 12c and later)
      -- 21.0: Added APIs to manipulate patterns
      -- 21.1: Added QC021: Redundant primary/unique key constraints
      -- 22.0: Adaptation with DBCCDEV-110 Ticket
      -- 22.1: Added support for multi-apps/schemas
      -- 23.0: Added QC022: Standalone procedures and functions are not allowed
      -- 23.1: Included licence terms in all packages + created QC_UTILITY_LIC package spec
      -- 23.2: Added support for PROCEDURE, FUNCTION and LABEL identifiers in QC019 + bug fixing
      -- 23.2.1: Bug fixing
      RETURN '23.2.1';
   END version;
   ---
   -- Format a message by substituting parameters
   ---
   FUNCTION format_msg (
      p_msg IN VARCHAR2
     ,p_1 IN VARCHAR2 := NULL
     ,p_2 IN VARCHAR2 := NULL
     ,p_3 IN VARCHAR2 := NULL
     ,p_4 IN VARCHAR2 := NULL
     ,p_5 IN VARCHAR2 := NULL
     ,p_6 IN VARCHAR2 := NULL
     ,p_7 IN VARCHAR2 := NULL
     ,p_8 IN VARCHAR2 := NULL
     ,p_9 IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 deterministic
      IS
      l_msg VARCHAR2(4000 CHAR) := p_msg;
      l_pos INTEGER;
   BEGIN
      <<param_loop>>
      FOR i IN 1..9 LOOP
         l_pos := NVL(INSTR(l_msg,':'||i),0);
         EXIT param_loop WHEN l_pos<=0;
         l_msg := SUBSTR(l_msg,1,l_pos-1)
               || CASE WHEN i = 1 THEN p_1
                       WHEN i = 2 THEN p_2
                       WHEN i = 3 THEN p_3
                       WHEN i = 4 THEN p_4
                       WHEN i = 5 THEN p_5
                       WHEN i = 6 THEN p_6
                       WHEN i = 7 THEN p_7
                       WHEN i = 8 THEN p_8
                       WHEN i = 9 THEN p_9
                  END
               || SUBSTR(l_msg,l_pos+2);
      END LOOP param_loop;
      RETURN l_msg;
   END format_msg;
   ---
   -- Return an error message when an assertion is false
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_msg IN VARCHAR2
     ,p_where IN VARCHAR2 := NULL
     ,p_1 IN VARCHAR2 := NULL
     ,p_2 IN VARCHAR2 := NULL
     ,p_3 IN VARCHAR2 := NULL
     ,p_4 IN VARCHAR2 := NULL
     ,p_5 IN VARCHAR2 := NULL
     ,p_6 IN VARCHAR2 := NULL
     ,p_7 IN VARCHAR2 := NULL
     ,p_8 IN VARCHAR2 := NULL
     ,p_9 IN VARCHAR2 := NULL
   )
   IS
   BEGIN
      IF p_assertion IS NULL OR NOT p_assertion THEN
         raise_application_error(-20000,CASE WHEN p_where IS NOT NULL THEN p_where||': ' END || format_msg(p_err_msg,p_1,p_2,p_3,p_4,p_5,p_6,p_7,p_8,p_9));
      END IF;
   END assert;
   ---
   -- Log text
   ---
   PROCEDURE log (
      p_text IN qc_run_logs.text%TYPE
     ,p_new_line IN BOOLEAN := FALSE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- Try to append first
      UPDATE qc_run_logs
         SET text = text || p_text
       WHERE run_id = qc_utility_var.g_run_id
         AND line = qc_utility_var.g_last_line
      ;
      -- Insert if not found
      IF SQL%NOTFOUND THEN
         INSERT INTO qc_run_logs (
            run_id, line, text
         ) VALUES (
            qc_utility_var.g_run_id, qc_utility_var.g_last_line, p_text
         );
      END IF;
      -- Increment line number when new line written
      IF p_new_line THEN
         qc_utility_var.g_last_line := qc_utility_var.g_last_line + 1;
      END IF;
      -- Save work
      COMMIT;
   END log;
   ---
   -- Log message for given context
   ---
   PROCEDURE log_message (
      p_type IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL
     ,p_text IN VARCHAR2 -- message text
     ,p_new_line IN BOOLEAN := TRUE
   )
   IS
      l_type VARCHAR2(1 CHAR);
      l_label VARCHAR2(10 CHAR);
   BEGIN
      l_type := UPPER(SUBSTR(p_type,1,1));
      IF NOT NVL(INSTR(qc_utility_var.g_msg_mask,l_type),0) <= 0 AND l_type != 'T' THEN
          CASE WHEN l_type = 'I' THEN l_label := 'Info';
               WHEN l_type = 'W' THEN l_label := 'Warning';
               WHEN l_type = 'E' THEN l_label := 'Error';
          END CASE;
          log(l_label||': ',FALSE);
          IF l_type = 'D' THEN
            IF qc_utility_var.g_time_mask IS NOT NULL THEN
               IF qc_utility_var.g_time_mask LIKE '%FF%' THEN
                  log(TO_CHAR(SYSTIMESTAMP,qc_utility_var.g_time_mask)||': '||p_text,p_new_line);
               ELSE
                  log(TO_CHAR(SYSDATE,qc_utility_var.g_time_mask)||': '||p_text,p_new_line);
               END IF;
            ELSE
               log(p_text,p_new_line);
            END IF;
          ELSE
             log(p_text,p_new_line);
          END IF;
      END IF;
   END log_message;
   -- Log run message
   PROCEDURE log_run_msg (
      p_qc_code IN qc_run_msgs.qc_code%TYPE
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_fix_name IN qc_run_msgs.fix_name%TYPE := NULL
     ,p_fix_op IN qc_run_msgs.fix_op%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_fix_type IN qc_run_msgs.fix_type%TYPE := NULL
     ,p_fix_ddl IN qc_run_msgs.fix_ddl%TYPE := NULL
     ,p_sort_order IN qc_run_msgs.sort_order%TYPE := NULL
     ,p_msg_hidden IN qc_run_msgs.msg_hidden%TYPE := NULL
     ,p_msg_type IN qc_run_msgs.msg_type%TYPE := NULL
     ,p_msg_text IN qc_run_msgs.msg_text%TYPE := NULL
     ,p_1 IN VARCHAR2 := NULL
     ,p_2 IN VARCHAR2 := NULL
     ,p_3 IN VARCHAR2 := NULL
     ,p_4 IN VARCHAR2 := NULL
     ,p_5 IN VARCHAR2 := NULL
     ,p_6 IN VARCHAR2 := NULL
     ,p_7 IN VARCHAR2 := NULL
     ,p_8 IN VARCHAR2 := NULL
     ,p_9 IN VARCHAR2 := NULL
   )
   IS
      r_msg qc_run_msgs%ROWTYPE;
      l_msg_text qc_run_msgs.msg_text%TYPE;
      l_found BOOLEAN;
      l_diff BOOLEAN;
   BEGIN
      assert(p_object_type IS NOT NULL, 'parameter p_object_type is mandatory for msg :1 ', 'log_run_msg', p_msg_text);
      l_found := qc_utility_var.g_msg.EXISTS(p_qc_code||'#'||p_object_type||'#'||p_object_name);
      IF l_found THEN
         r_msg := qc_utility_var.g_msg(p_qc_code||'#'||p_object_type||'#'||p_object_name);
      END IF;
      r_msg.qc_code := p_qc_code;
      r_msg.app_alias := qc_utility_var.g_app_alias;
      r_msg.object_owner := NVL(qc_utility_var.g_object_owner,USER);
      r_msg.object_type := p_object_type;
      r_msg.object_name := p_object_name;
      r_msg.msg_type := p_msg_type;
      r_msg.msg_hidden := p_msg_hidden;
      l_msg_text := format_msg(p_msg_text,p_1,p_2,p_3,p_4,p_5,p_6,p_7,p_8,p_9);
      IF r_msg.msg_type != 'T' THEN
         log_utility.log_message(p_msg_type, l_msg_text, TRUE);
      END IF;
      l_msg_text := CASE r_msg.msg_type WHEN 'E' THEN 'Error: '
                                        WHEN 'W' THEN 'Warning: '
                                        WHEN 'I' THEN 'Info: '
                                        WHEN 'T' THEN NULL -- Text
                    END
                    ||l_msg_text;
      l_diff := NVL(l_msg_text,'~') != NVL(r_msg.msg_text,'~');
      r_msg.msg_text := l_msg_text;
      r_msg.sort_order := p_sort_order;
      IF NVL(r_msg.fix_locked,'N') != 'Y' THEN
         r_msg.fix_name := p_fix_name;
         r_msg.fix_type := p_fix_type;
         r_msg.fix_op := p_fix_op;
         r_msg.fix_ddl := p_fix_ddl;
      END IF;
      -- other fix fields are preserved
      -- Add to the list of messages whose text needs to be updated
      IF l_found AND l_diff AND p_qc_code != 'QC000' THEN
         qc_utility_var.t_msg_upd(qc_utility_var.t_msg_upd.COUNT+1) := r_msg;
      END IF;
      -- Add to the global list of messages
      qc_utility_var.t_msg(qc_utility_var.t_msg.COUNT+1) := r_msg;
   END log_run_msg;
   -- log run stat
   PROCEDURE log_run_stat (
      p_qc_code IN qc_run_stats.qc_code%TYPE
    , p_object_type IN qc_run_stats.object_type%TYPE
    , p_object_count IN qc_run_stats.object_type%TYPE
   )
   IS
      r_stat qc_run_stats%ROWTYPE;
   BEGIN
      r_stat.qc_code := p_qc_code;
      r_stat.app_alias := qc_utility_var.g_app_alias;
      r_stat.object_owner := NVL(qc_utility_var.g_object_owner,USER);
      r_stat.object_type := p_object_type;
      r_stat.object_count := p_object_count;
      qc_utility_var.t_stat(qc_utility_var.t_stat.COUNT+1) := r_stat;
   END log_run_stat;
   -- Load table constraint in cache
   PROCEDURE load_tab_con IS
      CURSOR c_col IS
         SELECT con.owner, con.table_name, con.constraint_name, con.r_owner, con.r_constraint_name, con.constraint_type, col.column_name
           FROM dual
          INNER JOIN qc_dictionary_entries dict_own
             ON dict_own.dict_name = 'APP SCHEMA'
            AND dict_own.app_alias = qc_utility_var.g_app_alias
          INNER JOIN all_cons_columns col
             ON col.owner = dict_own.dict_key
          INNER JOIN all_constraints con
             ON con.owner = col.owner
            AND con.constraint_name = col.constraint_name
            AND con.constraint_type IN ('P','U','R','C')
--          WHERE 1=1
--            AND (pat_tab.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_tab.object_type,con.owner,con.table_name,pat_tab.include_pattern)=1)
--            AND (pat_tab.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_tab.object_type,con.owner,con.table_name,pat_tab.exclude_pattern)=0)
          ORDER BY col.table_name, DECODE(con.constraint_type,'P',1,'U',2,'R',3,'C',4,5), col.constraint_name, col.position
      ;
      TYPE t_col_type IS TABLE OF c_col%ROWTYPE INDEX BY BINARY_INTEGER;
      t_cols t_col_type;
      l_constraint_name all_constraints.constraint_name%TYPE;
      l_owner all_objects.owner%TYPE;
      r_con qc_utility_var.constraint_record;
      PROCEDURE handle_break IS
      BEGIN
         qc_utility_var.g_cache(l_owner).t_tab_con(r_con.table_name)(l_constraint_name) := r_con;
         qc_utility_var.g_cache(l_owner).t_con(l_constraint_name) := r_con;
         r_con := NULL;
      END handle_break;
   BEGIN
      l_owner := qc_utility_var.g_cache.FIRST;
      <<cache_loop>>
      WHILE l_owner IS NOT NULL LOOP
         qc_utility_var.g_cache(l_owner).t_tab_con.DELETE;
         qc_utility_var.g_cache(l_owner).t_con.DELETE;
         l_owner := qc_utility_var.g_cache.NEXT(l_owner);
      END LOOP cache_loop;
      OPEN c_col;
      FETCH c_col BULK COLLECT INTO t_cols;
      CLOSE c_col;
      <<cols_loop>>
      FOR i IN 1..t_cols.COUNT LOOP
         IF i > 1 AND t_cols(i).constraint_name != t_cols(i-1).constraint_name THEN
            handle_break;
         END IF;
         l_constraint_name := t_cols(i).constraint_name;
         l_owner := t_cols(i).owner;
         r_con.r_constraint_name := t_cols(i).r_constraint_name;
         r_con.table_name := t_cols(i).table_name;
         r_con.constraint_type := t_cols(i).constraint_type;
         r_con.constraint_cols := r_con.constraint_cols || CASE WHEN r_con.constraint_cols IS NULL THEN NULL ELSE ',' END || t_cols(i).column_name;
      END LOOP cols_loop;
      IF t_cols.COUNT > 0 THEN
         handle_break;
      END IF;
$if FALSE $then
      l_owner := qc_utility_var.g_cache.FIRST;
      <<owner_loop>>
      WHILE l_owner IS NOT NULL LOOP
--         sys.dbms_output.put_line('schema: '||l_owner||', con_cols.COUNT='||qc_utility_var.g_cache(l_owner).t_tab_con.COUNT);
         DECLARE
            l_table_name VARCHAR2(100 CHAR);
            l_constraint_name VARCHAR2(30 CHAR);
         BEGIN
            l_table_name := qc_utility_var.g_cache(l_owner).t_tab_con.FIRST;
            <<tab_loop>>
            WHILE l_table_name IS NOT NULL LOOP
               l_constraint_name := qc_utility_var.g_cache(l_owner).t_tab_con(l_table_name).FIRST;
               <<cons_loop>>
               WHILE l_constraint_name IS NOT NULL LOOP
                  r_con := qc_utility_var.g_cache(l_owner).t_tab_con(l_table_name)(l_constraint_name);
--                  sys.dbms_output.put_line(l_table_name||'.'||l_constraint_name||'('||r_con.constraint_cols||'): '||r_con.constraint_type);
                  l_constraint_name := qc_utility_var.g_cache(l_owner).t_tab_con(l_table_name).NEXT(l_constraint_name);
               END LOOP cons_loop;
               l_table_name :=qc_utility_var.g_cache(l_owner).t_tab_con.NEXT(l_table_name);
            END LOOP tab_loop;
         END;
         l_owner := qc_utility_var.g_cache.NEXT(l_owner);
      END LOOP owner_loop;
$end
   END load_tab_con;
   -- Load table indexes in cache
   PROCEDURE load_tab_ind IS
      CURSOR c_col IS
         SELECT ind.owner, ind.table_name, ind.index_name, ind.uniqueness index_type, col.column_name
           FROM all_indexes ind
          INNER JOIN qc_dictionary_entries dict_own
             ON dict_own.dict_name = 'APP SCHEMA'
            AND dict_own.app_alias = qc_utility_var.g_app_alias
--          INNER JOIN qc_patterns pat_tab
--             ON pat_tab.object_type = dict_own.dict_key
           LEFT OUTER JOIN all_ind_columns col -- some LOB indexes have no column!
             ON col.index_owner = ind.owner
            AND col.index_name = ind.index_name
          WHERE ind.owner = dict_own.dict_key
--          WHERE 1=1
--            AND (pat_tab.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_tab.object_type,ind.owner,ind.table_name,pat_tab.include_pattern)=1)
--            AND (pat_tab.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_tab.object_type,ind.owner,ind.table_name,pat_tab.exclude_pattern)=0)
          ORDER BY ind.owner, ind.table_name, ind.index_name, col.column_position
      ;
      TYPE t_col_type IS TABLE OF c_col%ROWTYPE INDEX BY BINARY_INTEGER;
      t_cols t_col_type;
      l_table_name all_tables.table_name%TYPE;
      l_index_name all_indexes.index_name%TYPE;
      l_owner all_objects.owner%TYPE;
      r_ind qc_utility_var.index_record;
      PROCEDURE handle_break IS
      BEGIN
         qc_utility_var.g_cache(l_owner).t_tab_ind(l_table_name)(l_index_name) := r_ind;
         r_ind := NULL;
      END handle_break;
   BEGIN
      l_owner := qc_utility_var.g_cache.FIRST;
      <<cache_loop>>
      WHILE l_owner IS NOT NULL LOOP
         qc_utility_var.g_cache(l_owner).t_tab_ind.DELETE;
         l_owner := qc_utility_var.g_cache.NEXT(l_owner);
      END LOOP cache_loop;
      OPEN c_col;
      FETCH c_col BULK COLLECT INTO t_cols;
      CLOSE c_col;
      <<cols_loop>>
      FOR i IN 1..t_cols.COUNT LOOP
         IF i > 1 AND t_cols(i).index_name != t_cols(i-1).index_name THEN
            handle_break;
         END IF;
         l_table_name := t_cols(i).table_name;
         l_index_name := t_cols(i).index_name;
         l_owner := t_cols(i).owner;
         r_ind.index_type := t_cols(i).index_type;
         r_ind.index_cols := r_ind.index_cols || CASE WHEN r_ind.index_cols IS NULL THEN NULL ELSE ',' END || t_cols(i).column_name;
      END LOOP cols_loop;
      IF t_cols.COUNT > 0 THEN
         handle_break;
      END IF;
-- Uncomment to debug
--      sys.dbms_output.put_line('ind_cols.COUNT='||qc_utility_var.g_ind_cols.COUNT);
--      DECLARE
--         l_table_name VARCHAR2(100 CHAR);
--         l_index_name VARCHAR2(30 CHAR);
--      BEGIN
--         l_table_name := qc_utility_var.g_ind_cols.FIRST;
--         <<tab_loop>>
--         WHILE l_table_name IS NOT NULL LOOP
--            l_index_name := qc_utility_var.g_ind_cols(l_table_name).FIRST;
--            <<idx_loop>>
--            WHILE l_index_name IS NOT NULL LOOP
--               sys.dbms_output.put_line(l_table_name||','||l_index_name||':'||qc_utility_var.g_ind_cols(l_table_name)(l_index_name));
--               l_index_name := qc_utility_var.g_ind_cols(l_table_name).NEXT(l_index_name);
--            END LOOP idx_loop;
--            l_table_name :=qc_utility_var.g_ind_cols.NEXT(l_table_name);
--         END LOOP tab_loop;
--      END;
   END load_tab_ind;
--#begin public
   ---
   -- Get list of columns of a given index
   ---
   FUNCTION get_ind_columns (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_ind_columns(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_ind_columns(): table name is mandatory');
      assert(p_index_name IS NOT NULL,'get_ind_columns(): index name is mandatory');
      assert(qc_utility_var.g_cache(p_owner).t_tab_ind.EXISTS(p_table_name),'Table '||p_table_name||' not found in table indexes cache!');
      assert(qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name).EXISTS(p_index_name),'index '||p_index_name||' not found in table indexes cache!');
      RETURN qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name)(p_index_name).index_cols;
   END get_ind_columns;
--#begin public
   ---
   -- Get trigger body as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_trigger_body (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_trg IS
         SELECT trigger_body
           FROM all_triggers
          WHERE owner = p_owner
            AND trigger_name = p_name
         ;
      l_trigger_body all_triggers.trigger_body%TYPE;
   BEGIN
      OPEN c_trg;
      FETCH c_trg INTO l_trigger_body;
      CLOSE c_trg;
      RETURN SUBSTR(l_trigger_body,1,4000);
   END get_trigger_body;
--#begin public
   ---
   -- Get view text as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_view_text (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_vw IS
         SELECT text
           FROM all_views
          WHERE owner = p_owner
            AND view_name = p_name
         ;
      l_text all_views.text%TYPE;
   BEGIN
      OPEN c_vw;
      FETCH c_vw INTO l_text;
      CLOSE c_vw;
      RETURN SUBSTR(l_text,1,4000);
   END get_view_text;
--#begin public
   ---
   -- Get mview query as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_mview_query (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_mvw IS
         SELECT QUERY
           FROM all_mviews
          WHERE owner = p_owner
            AND mview_name = p_name
         ;
      l_query all_mviews.QUERY%TYPE;
   BEGIN
      OPEN c_mvw;
      FETCH c_mvw INTO l_query;
      CLOSE c_mvw;
      RETURN SUBSTR(l_query,1,4000);
   END get_mview_query;
--#begin public
   ---
   -- Get constraint search_condition as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_con_search_condition (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_con IS
         SELECT search_condition
           FROM all_constraints
          WHERE owner = p_owner
            AND constraint_name = p_name
            AND constraint_type = 'C'
         ;
      l_search_condition all_constraints.search_condition%TYPE;
   BEGIN
      OPEN c_con;
      FETCH c_con INTO l_search_condition;
      CLOSE c_con;
      RETURN SUBSTR(l_search_condition,1,4000);
   END get_con_search_condition;
--#begin public
   ---
   -- Get list of columns of a given constraint
   ---
   FUNCTION get_cons_columns (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_cons_columns(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_cons_columns(): table name is mandatory');
      assert(p_constraint_name IS NOT NULL,'get_cons_columns(): constraint name is mandatory');
      assert(qc_utility_var.g_cache(p_owner).t_tab_con.EXISTS(p_table_name),'Table '||p_table_name||' not found in table constraints cache!');
      assert(qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).EXISTS(p_constraint_name),'Constraint '||p_constraint_name||' not found in table constraints cache!');
      RETURN qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name)(p_constraint_name).constraint_cols;
   END get_cons_columns;
--#begin public
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
--#end public
   IS
      TYPE cols_tab_type IS TABLE OF all_tab_columns.column_name%TYPE INDEX BY all_tab_columns.column_name%TYPE;
      t_cols1 cols_tab_type;
      t_cols2 cols_tab_type;
      l_col_name all_tab_columns.column_name%TYPE;
      l_match BOOLEAN;
      r_con qc_utility_var.constraint_record;
      -- Get constraint columns in an associative array (indexed by column name)
      PROCEDURE get_cols (
         p_owner IN VARCHAR2
       , p_table_name IN VARCHAR2
       , p_constraint_name IN VARCHAR2
       , pt_cols IN OUT cols_tab_type
      )
      IS
         l_cols VARCHAR2(4000);
         l_pos INTEGER;
         l_col_name all_tab_columns.column_name%TYPE;
      BEGIN
         pt_cols.DELETE;
         l_cols := get_cons_columns(p_owner, p_table_name, p_constraint_name);
         WHILE l_cols IS NOT NULL LOOP
            l_pos := NVL(INSTR(l_cols,','),0);
            IF l_pos > 0 THEN
               l_col_name := TRIM(SUBSTR(l_cols,1,l_pos-1));
               l_cols := SUBSTR(l_cols,l_pos+1);
            ELSE
               l_col_name := TRIM(l_cols);
               l_cols := NULL;
            END IF;
            pt_cols(l_col_name) := l_col_name;
         END LOOP;
      END;
   BEGIN
      -- Get column list of both constraints in an associative array
      get_cols(p_owner, p_table_name, p_constraint_name1, t_cols1);
      get_cols(p_owner, p_table_name, p_constraint_name2, t_cols2);
      l_match := TRUE;
      -- Check if all columns of the constraint having the smaller
      -- number of columns are also part of the second constraint
      IF t_cols1.COUNT <= t_cols2.COUNT THEN
         l_col_name := t_cols1.FIRST;
         WHILE l_col_name IS NOT NULL AND l_match LOOP
            IF NOT t_cols2.EXISTS(l_col_name) THEN
               l_match := FALSE;
            END IF;
            l_col_name := t_cols1.NEXT(l_col_name);
         END LOOP;
         IF l_match THEN
            IF t_cols1.COUNT < t_cols2.COUNT THEN
               -- Return constraint having the highest number of columns
               RETURN p_constraint_name2;
            ELSE
               IF qc_utility_var.g_cache(p_owner).t_con.EXISTS(p_constraint_name1) THEN
                  r_con := qc_utility_var.g_cache(p_owner).t_con(p_constraint_name1);
               END IF;
               IF p_constraint_name1 < p_constraint_name2 OR r_con.constraint_type = 'P' THEN
                  -- If there is a PK, the redundant key is the UK
                  -- Otherwise, the second constraint alphabetically
                  RETURN p_constraint_name2; -- return UK
               ELSE
                  RETURN p_constraint_name1;
               END IF;
            END IF;
         END IF;
      ELSE
         l_col_name := t_cols2.FIRST;
         WHILE l_col_name IS NOT NULL AND l_match LOOP
            IF NOT t_cols1.EXISTS(l_col_name) THEN
               l_match := FALSE;
            END IF;
            l_col_name := t_cols2.NEXT(l_col_name);
         END LOOP;
         IF l_match THEN
            RETURN p_constraint_name1;
         END IF;
      END IF;
      RETURN NULL;
   END get_duplicate_cons;
   ---
   -- Get table primary key columns
   ---
   FUNCTION get_tab_pk_cols (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      r_con qc_utility_var.constraint_record;
      l_constraint_name all_constraints.constraint_name%TYPE;
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_tab_pk_cols(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_tab_pk_cols(): table name is mandatory');
      -- Search for pk in constraints
      IF NOT qc_utility_var.g_cache(p_owner).t_tab_con.EXISTS(p_table_name) THEN
         RETURN NULL;
      END IF;
      l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).FIRST;
      <<cons_loop>>
      WHILE l_constraint_name IS NOT NULL LOOP
         r_con := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name)(l_constraint_name);
         IF r_con.constraint_type = 'P' THEN
            RETURN r_con.constraint_cols;
         END IF;
         l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).NEXT(l_constraint_name);
      END LOOP cons_loop;
      RETURN NULL;
   END get_tab_pk_cols;
--#begin public
   ---
   -- Determine index type
   ---
   FUNCTION get_ind_type (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      r_ind qc_utility_var.index_record;
      r_con qc_utility_var.constraint_record;
      l_constraint_name all_constraints.constraint_name%TYPE;
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_ind_type(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_ind_type(): table name is mandatory');
      assert(p_index_name IS NOT NULL,'get_ind_type(): index name is mandatory');
      -- Get index from cache
      <<get_index_from_cache>>
      BEGIN
         assert(qc_utility_var.g_cache(p_owner).t_tab_ind.EXISTS(p_table_name),'Table '||p_table_name||' not found in table indexes cache!');
         assert(qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name).EXISTS(p_index_name),'Index '||p_index_name||' not found in table indexes cache!');
      EXCEPTION
         WHEN OTHERS THEN RETURN 'INDEX';
      END get_index_from_cache;
      r_ind := qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name)(p_index_name);
      -- Search for a matching constraint
      IF qc_utility_var.g_cache(p_owner).t_tab_con.EXISTS(p_table_name) THEN
         l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).FIRST;
         <<cons_loop>>
         WHILE l_constraint_name IS NOT NULL LOOP
            r_con := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name)(l_constraint_name);
            IF r_con.constraint_cols = r_ind.index_cols AND r_con.constraint_type IN ('P','U','R') THEN
               RETURN 'INDEX: '
                   || CASE r_con.constraint_type
                      WHEN 'P' THEN 'PRIMARY KEY'
                      WHEN 'U' THEN 'UNIQUE KEY'
                      WHEN 'R' THEN 'FOREIGN KEY'
                      END;
            END IF;
            l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).NEXT(l_constraint_name);
         END LOOP cons_loop;
      END IF;
      RETURN CASE r_ind.index_type
             WHEN 'UNIQUE' THEN 'INDEX: UNIQUE'
             WHEN 'NONUNIQUE' THEN 'INDEX: NON UNIQUE'
             ELSE 'INDEX'
             END;
   END get_ind_type;
--#begin public
   ---
   -- Get constraint corresponding to an index
   ---
   FUNCTION get_ind_con (
      p_owner IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_index_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      r_ind qc_utility_var.index_record;
      r_con qc_utility_var.constraint_record;
      l_constraint_name all_constraints.constraint_name%TYPE;
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_ind_type(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_ind_type(): table name is mandatory');
      assert(p_index_name IS NOT NULL,'get_ind_type(): index name is mandatory');
      -- Get index from cache
      assert(qc_utility_var.g_cache(p_owner).t_tab_ind.EXISTS(p_table_name),'Table '||p_table_name||' not found in table indexes cache!');
      assert(qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name).EXISTS(p_index_name),'Index '||p_index_name||' not found in table indexes cache!');
      r_ind := qc_utility_var.g_cache(p_owner).t_tab_ind(p_table_name)(p_index_name);
      -- Search for a matching constraint
      IF qc_utility_var.g_cache(p_owner).t_tab_con.EXISTS(p_table_name) THEN
         l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).FIRST;
         <<cons_loop>>
         WHILE l_constraint_name IS NOT NULL LOOP
            r_con := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name)(l_constraint_name);
            IF r_con.constraint_cols = r_ind.index_cols AND r_con.constraint_type IN ('P','U','R') THEN
               RETURN l_constraint_name;
            END IF;
            l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).NEXT(l_constraint_name);
         END LOOP cons_loop;
      END IF;
      RETURN NULL; -- not found
   END get_ind_con;
   ---
   -- Get dictionary entry
   ---
   FUNCTION get_dictionary_entry (
      p_dict_name IN qc_dictionary_entries.dict_name%TYPE
    , p_dict_key IN qc_dictionary_entries.dict_key%TYPE
   )
   RETURN qc_dictionary_entries.dict_value%TYPE
   IS
   BEGIN
      IF qc_utility_var.g_dict.EXISTS(p_dict_name) THEN
         IF qc_utility_var.g_dict(p_dict_name).EXISTS(p_dict_key) THEN
            RETURN qc_utility_var.g_dict(p_dict_name)(p_dict_key);
         END IF;
      END IF;
      RETURN NULL;
   END get_dictionary_entry;
--#begin public
   ---
   -- Get constraint qualifier
   ---
   FUNCTION get_cons_qualifier (
      p_owner IN VARCHAR2
    , p_constraint_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_cons (
         p_owner IN VARCHAR2
       , p_constraint_name IN VARCHAR2
       , p_constraint_type IN VARCHAR2
      ) IS
         SELECT *
           FROM all_constraints
          WHERE owner = p_owner
            AND constraint_name = p_constraint_name
            AND ((p_constraint_type = 'R' AND constraint_type = 'R') OR
                 (p_constraint_type = 'P' AND constraint_type IN ('U','P')))
      ;
      r_fk c_cons%ROWTYPE;
      r_pk c_cons%ROWTYPE;
      l_found BOOLEAN;
      l_pk_cols VARCHAR2(100 CHAR);
      l_fk_cols VARCHAR2(100 CHAR);
      l_pk_alias VARCHAR2(100 CHAR);
      l_len INTEGER;
      l_qualifier VARCHAR2(100 CHAR);
   BEGIN
      OPEN c_cons(p_owner, p_constraint_name, 'R');
      FETCH c_cons INTO r_fk;
      l_found := c_cons%FOUND;
      CLOSE c_cons;
      IF l_found THEN
         l_fk_cols := get_cons_columns(r_fk.owner, r_fk.table_name, r_fk.constraint_name);
         OPEN c_cons(r_fk.r_owner, r_fk.r_constraint_name, 'P');
         FETCH c_cons INTO r_pk;
         l_found := c_cons%FOUND;
         CLOSE c_cons;
         IF l_found THEN
            l_pk_cols := get_cons_columns(r_pk.owner, r_pk.table_name, r_pk.constraint_name);
            l_qualifier := TRIM('_' FROM REPLACE(REPLACE(l_fk_cols,l_pk_cols),'__','_'));
            IF NVL(INSTR(l_qualifier,','),0) > 0 THEN
               l_qualifier := NULL;
            END IF;
            l_pk_alias := get_dictionary_entry('TABLE ALIAS', r_pk.table_name);
            l_len := NVL(LENGTH(l_pk_alias),0);
            IF l_len > 0 THEN
               IF SUBSTR(l_qualifier,1,l_len) = l_pk_alias THEN
                  l_qualifier := LTRIM(SUBSTR(l_qualifier,l_len+1),'_');
               ELSIF SUBSTR(l_qualifier,0-l_len) = l_pk_alias THEN
                  l_qualifier := RTRIM(SUBSTR(l_qualifier,1,NVL(LENGTH(l_qualifier),0)-l_len),'_');
               END IF;
            END IF;
         END IF;
      END IF;
      RETURN l_qualifier;
   END get_cons_qualifier;
--#begin public
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
--#end public
   IS
      r_con qc_utility_var.constraint_record;
      l_constraint_name all_constraints.constraint_name%TYPE;
      l_constraint_type all_constraints.constraint_type%TYPE;
   BEGIN
      -- Check parameters
      assert(p_owner IS NOT NULL,'get_col_con_type(): owner is mandatory');
      assert(p_table_name IS NOT NULL,'get_col_con_type(): table name is mandatory');
      assert(p_column_name IS NOT NULL,'get_col_con_type(): column name is mandatory');
      -- Search for a constraint containing given column
      IF qc_utility_var.g_cache(p_owner).t_tab_con.EXISTS(p_table_name) THEN
         l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).FIRST;
         <<cons_loop>>
         WHILE l_constraint_name IS NOT NULL LOOP
            r_con := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name)(l_constraint_name);
            IF NVL(INSTR(','||UPPER(r_con.constraint_cols)||',',','||p_column_name||','),0)>0 THEN
               IF r_con.constraint_type = 'P' THEN
                  -- P takes precedence
                  l_constraint_type := 'P';
               ELSIF r_con.constraint_type = 'U' THEN
                  -- U does not overwrite P
                  l_constraint_type := CASE WHEN l_constraint_type = 'P' THEN l_constraint_type ELSE r_con.constraint_type END;
               ELSE
                  -- R does not overwrite P or U
                  l_constraint_type := CASE WHEN l_constraint_type IN ('P','U') THEN l_constraint_type ELSE r_con.constraint_type END;
               END IF;
            END IF;
            l_constraint_name := qc_utility_var.g_cache(p_owner).t_tab_con(p_table_name).NEXT(l_constraint_name);
         END LOOP cons_loop;
      END IF;
      RETURN l_constraint_type;
   END get_col_cons_type;
   -- Split a string made up of 2 parts separated by a separator
   -- Ex: <part1><sep><part2>
   PROCEDURE split_string (
      p_string IN VARCHAR2
    , po_part1 OUT NOCOPY VARCHAR2
    , po_part2 OUT NOCOPY VARCHAR2
    , p_sep IN VARCHAR2
    , p_tgt IN VARCHAR2 -- target part if sep not found (1 or 2)
   )
   IS
      l_pos INTEGER;
   BEGIN
      -- Decompose composed names like <table name>.<object name>
      l_pos := NVL(INSTR(p_string,p_sep,-1),0);
      IF l_pos > 0 THEN
         po_part1 := TRIM(SUBSTR(p_string,1,l_pos-1));
         po_part2 := TRIM(SUBSTR(p_string,l_pos+1));
      ELSE
         IF p_tgt = 1 THEN
            po_part1 := p_string;
            po_part2 := NULL;
         ELSE
            po_part1 := NULL;
            po_part2 := p_string;
         END IF;
      END IF;
   END split_string;
   -- Decompose a name like <prefix>.<name>
   PROCEDURE decompose_name (
      p_object_type IN VARCHAR2
    , p_object_name IN VARCHAR2
    , po_table_name_out OUT NOCOPY VARCHAR2
    , po_object_name_out OUT VARCHAR2 /*NOCOPY leads to PLW-05003, please ignore PLW-07203*/
    , p_sep IN VARCHAR2 := '.'
   )
   IS
   BEGIN
      -- Decompose composed names like <table name>.<object name>
      IF NVL(INSTR(p_object_type,'COMMENT'),0)>0 THEN
         po_table_name_out := NULL;
         po_object_name_out := p_object_name;
      ELSE
         IF NVL(INSTR(p_object_name,'@'),0) > 0 THEN
            -- Regexp replace removes any comment if any (@ and following characters)
            -- A comment is added to object names to make msgs unique for a given QC
            split_string(regexp_replace(p_object_name,'([^@]*)@.*','\1'),po_table_name_out, po_object_name_out, p_sep, 2);
         ELSE
            -- For performance reason, regexp replace is not used if not comment was found
            split_string(p_object_name,po_table_name_out, po_object_name_out, p_sep, 2);
         END IF;
      END IF;
   END decompose_name;
   -- Get trigger
   FUNCTION get_trigger (
      p_owner IN VARCHAR2
    , p_trigger_name IN VARCHAR2
   )
   RETURN all_triggers%ROWTYPE
   IS
      CURSOR c_trg (
         p_owner IN VARCHAR2
       , p_trigger_name IN VARCHAR2
      )
      IS
         SELECT *
           FROM all_triggers
          WHERE owner = p_owner
            AND trigger_name = p_trigger_name
         ;
      r_trg all_triggers%ROWTYPE;
   BEGIN
      OPEN c_trg(p_owner, p_trigger_name);
      FETCH c_trg INTO r_trg;
      CLOSE c_trg;
      RETURN r_trg;
   END get_trigger;
   -- Get argument in/out type
   FUNCTION get_argument_in_out (
      p_owner IN all_arguments.owner%TYPE
    , p_package_name IN all_arguments.package_name%TYPE
    , p_object_name IN all_arguments.object_name%TYPE
    , p_argument_name IN all_arguments.argument_name%TYPE
   )
   RETURN all_arguments.in_out%TYPE
   IS
      CURSOR c_arg (
         p_owner IN all_arguments.owner%TYPE
       , p_package_name IN all_arguments.package_name%TYPE
       , p_object_name IN all_arguments.object_name%TYPE
       , p_argument_name IN all_arguments.argument_name%TYPE
      )
      IS
         SELECT in_out
           FROM all_arguments
          WHERE owner = p_owner
            AND package_name = p_package_name
            AND object_name = p_object_name
            AND argument_name = p_argument_name
         ;
      l_arg_in_out all_arguments.in_out%TYPE;
   BEGIN
      OPEN c_arg(p_owner,p_package_name,p_object_name,p_argument_name);
      FETCH c_arg INTO l_arg_in_out;
      CLOSE c_arg;
      RETURN l_arg_in_out;
   END get_argument_in_out;
   -- Function to check whether a string contains a variable or not
   -- Search for {variable}, {_variable}, {variable_}, {_variable_}
   -- i.e. variable potentially prefixed/suffixed with an underscore
   -- Returns the position of the variable in the string or 0 if not found
   FUNCTION varinstr (
      p_str IN VARCHAR2 -- string where to search
    , p_var IN VARCHAR2 -- variable {variable}
   )
   RETURN INTEGER
   IS
      l_ret INTEGER;
      l_len INTEGER;
   BEGIN
      assert(substr(p_var,1,1)='{' AND substr(p_var,-1,1) = '}','varinstr(): internal error: variable name not enclosed with curved brackets!');
      l_len := NVL(LENGTH(p_var),0)-2;
      <<var_loop>>
      FOR i IN 1..4 LOOP
         l_ret := NVL(INSTR(p_str, '{' || CASE WHEN i IN (2,4) THEN '_' END || SUBSTR(p_var,2,l_len) || CASE WHEN i IN (3,4) THEN '_' END || '}'),0);
         EXIT var_loop WHEN l_ret > 0;
      END LOOP var_loop;
      RETURN l_ret;
   END varinstr;
   -- Replace variables within a string
   -- Search for {variable}, {_variable}, {variable_}, {_variable_}
   -- When value is null, replace variable with null i.e. just remove the variable from the input string
   -- When value is not null, replace variable with value prefixed/suffixed/or both with an underscore
   FUNCTION varrep (
      p_str IN VARCHAR2 -- string where to search
    , p_var IN VARCHAR2 -- variable e.g. {variable}
    , p_val IN VARCHAR2 -- value
   )
   RETURN VARCHAR2
   IS
--         l_ret INTEGER;
      l_len INTEGER;
      l_buf VARCHAR2(4000 CHAR) := p_str;
   BEGIN
      assert(substr(p_var,1,1)='{' AND substr(p_var,-1,1) = '}','varrep(): internal error: variable name not enclosed with curved brackets!');
      l_len := NVL(LENGTH(p_var),0)-2;
      <<var_loop>>
      FOR i IN 1..4 LOOP
         l_buf := REPLACE(l_buf
                  , '{' || CASE WHEN i IN (2,4) THEN '_' END || SUBSTR(p_var,2,l_len) || CASE WHEN i IN (3,4) THEN '_' END || '}'
                  , CASE WHEN p_val IS NULL THEN NULL ELSE CASE WHEN i IN (2,4) THEN '_' END || p_val || CASE WHEN i IN (3,4) THEN '_' END END
                  );
      END LOOP var_loop;
      RETURN l_buf;
   END varrep;
--#begin public
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
--#end public
   IS
      -- Note keyword {_x} is replaced by _{x} if x IS NOT NULL, by NULL otherwise
      k_object        CONSTANT VARCHAR2(8 CHAR)  := '{object}';
      k_table         CONSTANT VARCHAR2(7 CHAR)  := '{table}';
      k_table_alias   CONSTANT VARCHAR2(13 CHAR) := '{table alias}';
      k_table_entity  CONSTANT VARCHAR2(14 CHAR) := '{table entity}';
      k_parent_table  CONSTANT VARCHAR2(14 CHAR) := '{parent table}';
      k_parent_alias  CONSTANT VARCHAR2(14 CHAR) := '{parent alias}';
      k_parent_entity CONSTANT VARCHAR2(15 CHAR) := '{parent entity}';
      k_parent_cons   CONSTANT VARCHAR2(13 CHAR) := '{parent cons}';
      k_app_alias     CONSTANT VARCHAR2(12 CHAR) := '{app alias}';
      k_tab_column    CONSTANT VARCHAR2(12 CHAR) := '{tab column}';   -- table column
      k_tab_col_alias CONSTANT VARCHAR2(15 CHAR) := '{tab col alias}';-- table column alias
      k_ind_column    CONSTANT VARCHAR2(12 CHAR) := '{ind column}';   -- index column (if only 1 column, NULL otherwise)
      k_ind_columns   CONSTANT VARCHAR2(13 CHAR) := '{ind columns}';  -- index columns (comma separated list)
      k_pk_column     CONSTANT VARCHAR2(13 CHAR) := '{pk column}';  -- pk column (if only 1 column, NULL otherwise)
      k_pk_columns    CONSTANT VARCHAR2(14 CHAR) := '{pk columns}'; -- pk columns (comma separated list)
      k_cons_column   CONSTANT VARCHAR2(13 CHAR) := '{cons column}';  -- constraint column (if only 1 column, NULL otherwise)
      k_cons_columns  CONSTANT VARCHAR2(14 CHAR) := '{cons columns}'; -- constraint columns (comma separated list)
      k_cons_role     CONSTANT VARCHAR2(11 CHAR) := '{cons role}';    -- constraint role
      k_ind_cons      CONSTANT VARCHAR2(12 CHAR) := '{ind cons}';     -- index constraint
      k_trg_event     CONSTANT VARCHAR2(18 CHAR) := '{triggering event}';
      k_trg_type      CONSTANT VARCHAR2(14 CHAR) := '{trigger type}';
      k_arg_in_out    CONSTANT VARCHAR2(17 CHAR) := '{argument in out}';
      l_tab_column    VARCHAR2(30 CHAR);
      l_tab_col_alias VARCHAR2(30 CHAR);
      l_ind_column    VARCHAR2(30 CHAR);
      l_ind_columns   VARCHAR2(4000 CHAR);
      l_cons_column   VARCHAR2(30 CHAR);
      l_cons_columns  VARCHAR2(4000 CHAR);
      l_pk_column   VARCHAR2(30 CHAR);
      l_pk_columns  VARCHAR2(4000 CHAR);
      l_cons_role     VARCHAR2(30 CHAR);
      l_table_name    VARCHAR2(100 CHAR);
      l_package_name  VARCHAR2(100 CHAR);
      l_object_name   VARCHAR2(4000 CHAR);
      l_cons_name     VARCHAR2(30 CHAR);
      l_table_alias   VARCHAR2(30 CHAR);
      l_table_entity  VARCHAR2(30 CHAR);
      l_parent_alias  VARCHAR2(30 CHAR);
      l_parent_table  VARCHAR2(30 CHAR);
      l_parent_entity VARCHAR2(30 CHAR);
      l_parent_cons   VARCHAR2(30 CHAR);
      l_trg_event     qc_dictionary_entries.dict_value%TYPE;
      l_trg_type      qc_dictionary_entries.dict_value%TYPE;
      l_arg_in_out    qc_dictionary_entries.dict_value%TYPE;
      r_trg           all_triggers%ROWTYPE;
      l_get_parent    BOOLEAN := FALSE;
   BEGIN
--      assert(qc_utility_var.g_app_alias IS NOT NULL,'Application alias is not defined!');
      -- Decompose composed names: <table name>.<object name> OR <package name>.<method name>.<argument name>
      decompose_name(p_object_type,p_object_name,l_table_name,l_object_name);
      IF p_object_type LIKE 'ARGUMENT%' THEN
         decompose_name(p_object_type,l_table_name,l_package_name,l_table_name);
      ELSE
         IF p_object_type = 'TABLE' THEN
            l_table_name := l_object_name;
         END IF;
         IF l_table_name IS NOT NULL THEN
            l_table_alias := get_dictionary_entry('TABLE ALIAS', l_table_name);
            l_table_entity := get_dictionary_entry('TABLE ENTITY', l_table_name);
         END IF;
         IF NVL(INSTR(p_pattern,k_pk_column),0)>0 OR NVL(INSTR(p_pattern,k_pk_columns),0)>0 THEN -- only if keyword found in pattern
            l_pk_columns := get_tab_pk_cols(p_owner, l_table_name); -- in cache so at no cost
            IF NVL(INSTR(l_pk_columns,','),0) = 0 THEN
               l_pk_column := l_pk_columns; -- only 1 column
            END IF;
         END IF;
      END IF;
      IF p_object_type IN ('INDEX','CONSTRAINT') AND l_table_name IS NULL THEN
         RETURN (p_pattern);
      END IF;
      IF p_object_type = 'INDEX' OR p_object_type LIKE 'INDEX:%' THEN
         l_cons_name := get_ind_con(p_owner,l_table_name,l_object_name);
         l_ind_columns := get_ind_columns(p_owner,l_table_name,l_object_name);
         IF NVL(INSTR(l_ind_columns,','),0) <= 0 THEN
            l_ind_column := l_ind_columns; -- only 1 column
         END IF;
         l_get_parent := TRUE;
      ELSIF p_object_type = 'TABLE COLUMN' THEN
         l_tab_column := l_object_name;
         l_tab_col_alias := NVL(get_dictionary_entry('TABLE COLUMN ALIAS', l_table_name||'.'||l_tab_column),l_tab_column);
      ELSIF p_object_type = 'CONSTRAINT' OR p_object_type LIKE 'CONSTRAINT:%' THEN
         l_cons_name := l_object_name;
         l_cons_columns := get_cons_columns(p_owner, l_table_name,l_cons_name); -- in cache so at no cost
         IF NVL(INSTR(l_cons_columns,','),0) = 0 THEN
            l_cons_column := l_cons_columns; -- only 1 column
         END IF;
         IF varinstr(p_pattern,k_cons_role)>0 THEN
            l_cons_role := get_cons_qualifier(p_owner, l_cons_name);
         END IF;
         l_get_parent := TRUE;
      ELSIF p_object_type LIKE 'ARGUMENT%' THEN
         IF varinstr(p_pattern,k_arg_in_out)>0 THEN
            l_arg_in_out := get_dictionary_entry('ARGUMENT IN OUT',get_argument_in_out(p_owner,l_package_name,l_table_name,l_object_name));
         END IF;
      ELSIF p_object_type = 'TRIGGER' THEN
         IF varinstr(p_pattern, k_trg_event)>0 THEN
            IF r_trg.trigger_name IS NULL THEN
               r_trg := get_trigger(p_owner,l_object_name);
            END IF;
            IF r_trg.triggering_event IS NOT NULL AND varinstr(p_pattern, k_trg_event)>0 THEN
               l_trg_event := get_dictionary_entry('TRIGGERING EVENT', r_trg.triggering_event);
            END IF;
         END IF;
         IF varinstr(p_pattern, k_trg_type)>0 THEN
            IF r_trg.trigger_name IS NULL THEN
               r_trg := get_trigger(p_owner,l_object_name);
            END IF;
            IF r_trg.trigger_type IS NOT NULL AND NVL(INSTR(p_pattern, k_trg_type),0)>0 THEN
               l_trg_type := get_dictionary_entry('TRIGGER TYPE', r_trg.trigger_type);
            END IF;
         END IF;
      END IF;
      IF l_get_parent THEN
         DECLARE
            r_con qc_utility_var.constraint_record;
         BEGIN
            IF qc_utility_var.g_cache(p_owner).t_con.EXISTS(l_cons_name) THEN
               r_con := qc_utility_var.g_cache(p_owner).t_con(l_cons_name);
               IF qc_utility_var.g_cache(p_owner).t_con.EXISTS(r_con.r_constraint_name) THEN
                  l_parent_cons := r_con.r_constraint_name;
                  r_con := qc_utility_var.g_cache(p_owner).t_con(r_con.r_constraint_name);
                  l_parent_table := r_con.table_name;
                  l_parent_alias := get_dictionary_entry('TABLE ALIAS', r_con.table_name);
                  l_parent_entity := get_dictionary_entry('TABLE ENTITY', r_con.table_name);
               END IF;
            END IF;
         END;
      END IF;
      RETURN varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(varrep(p_pattern
                    ,k_object,l_object_name)
                    ,k_table,l_table_name)
                    ,k_table_alias,l_table_alias)
                    ,k_table_entity,l_table_entity)
                    ,k_parent_alias,l_parent_alias)
                    ,k_parent_table,l_parent_table)
                    ,k_parent_entity,l_parent_entity)
                    ,k_parent_cons,l_parent_cons)
                    ,k_app_alias,qc_utility_var.g_app_alias)
                    ,k_tab_column,l_tab_column)
                    ,k_tab_col_alias,l_tab_col_alias)
                    ,k_ind_column,l_ind_column)
                    ,k_ind_columns,l_ind_columns)
                    ,k_pk_column,l_pk_column)
                    ,k_pk_columns,l_pk_columns)
                    ,k_cons_column,l_cons_column)
                    ,k_cons_columns,l_cons_columns)
                    ,k_cons_role,l_cons_role)
                    ,k_ind_cons,l_cons_name)
                    ,k_trg_event,l_trg_event)
                    ,k_trg_type,l_trg_type)
                    ,k_arg_in_out,l_arg_in_out)
                    ;
   END replace_vars;
   -- Check if an object exists already
   FUNCTION object_exists (
      p_owner IN VARCHAR2
    , p_object_type IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      CURSOR c_obj (
         p_owner IN VARCHAR2
       , p_object_type IN VARCHAR2
       , p_object_name IN VARCHAR2
      )
      IS
         SELECT 'x'
           FROM all_objects
          WHERE owner = p_owner
            AND object_type = p_object_type
            AND object_name = p_object_name
      ;
      CURSOR c_col (
         p_owner IN VARCHAR2
       , p_table_name IN VARCHAR2
       , p_column_name IN VARCHAR2
      )
      IS
         SELECT 'x'
           FROM all_tab_columns
          WHERE owner = p_owner
            AND table_name = p_table_name
            AND column_name = p_column_name
      ;
      CURSOR c_con (
         p_owner IN VARCHAR2
       , p_constraint_name IN VARCHAR2
      )
      IS
         SELECT 'x'
           FROM all_constraints
          WHERE owner = p_owner
            AND constraint_name = p_constraint_name
            AND constraint_type IN ('P','U','R','C')
      ;
      l_dummy VARCHAR2(1 CHAR);
      l_found BOOLEAN;
      l_fix_name qc_run_msgs.fix_name%TYPE;
      l_object_type VARCHAR2(100 CHAR);
      l_object_subtype VARCHAR2(100 CHAR);
   BEGIN
      -- Remove any object type qualifier (e.g. type: qualifier)
      split_string(p_object_type, l_object_type, l_object_subtype, ':', 1);
      -- Check object name in cache first
      l_fix_name := CASE WHEN p_table_name IS NOT NULL THEN p_table_name||'.' END || p_object_name;
      IF qc_utility_var.t_fix.EXISTS(l_fix_name) THEN
         RETURN 'Y';
      END IF;
      -- If object type is included in all_objects view
      -- (those commented out are not used in this tool)
      IF l_object_type IN (
          NULL
--         ,'DATABASE LINK'
--         ,'EVALUATION CONTEXT'
--         ,'FUNCTION'
         ,'INDEX'
--         ,'JOB'
--         ,'LOB'
         ,'MATERIALIZED VIEW'
--         ,'PACKAGE'
--         ,'PACKAGE BODY'
--         ,'PROCEDURE'
--         ,'QUEUE'
--         ,'RULE SET'
         ,'SEQUENCE'
--         ,'SYNONYM'
         ,'TABLE'
         ,'TRIGGER'
--         ,'TYPE'
--         ,'TYPE BODY'
         ,'VIEW'
         )
      THEN
         OPEN c_obj(p_owner,p_object_type,p_object_name);
         FETCH c_obj INTO l_dummy;
         l_found := c_obj%FOUND;
         CLOSE c_obj;
      ELSIF l_object_type = 'TABLE COLUMN' THEN
         OPEN c_col(p_owner,p_table_name,p_object_name);
         FETCH c_col INTO l_dummy;
         l_found := c_col%FOUND;
         CLOSE c_col;
      ELSIF l_object_type = 'CONSTRAINT' THEN
         OPEN c_con(p_owner,p_object_name);
         FETCH c_con INTO l_dummy;
         l_found := c_con%FOUND;
         CLOSE c_con;
      ELSE
         raise_application_error(-20000,'Unsupported data type in object_exists(): '||l_object_type);
      END IF;
      RETURN CASE WHEN l_found THEN 'Y' ELSE 'N' END;
   END object_exists;
--#begin public
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
--#end public
   IS
      l_fix_name qc_run_msgs.fix_name%TYPE;
      l_tmp_name qc_run_msgs.fix_name%TYPE;
      l_pos INTEGER;
      l_object_name VARCHAR2(100 CHAR);
      l_table_name VARCHAR2(100 CHAR);
      l_found BOOLEAN;
      k_seq_nr CONSTANT VARCHAR2(8 CHAR) := '{seq nr}';
   BEGIN
      -- Quick processing of NULL pattern
      IF p_fix_pattern IS NULL THEN
         RETURN NULL;
      END IF;
      -- Decompose composed names: <table name>.<object name>
      decompose_name(p_object_type,p_object_name,l_table_name,l_object_name);
      -- Replace most keywords
      l_fix_name := replace_vars(p_object_type,p_owner,p_object_name,p_fix_pattern);
      -- Make sure object name is unique + handle {seq no} keyword
      l_pos := NVL(INSTR(l_fix_name,k_seq_nr),0);
      IF l_pos > 0 THEN
         l_tmp_name := REPLACE(l_fix_name,k_seq_nr,NULL);
         l_found := object_exists(p_owner,p_object_type,l_tmp_name,l_table_name) = 'Y';
         IF l_found THEN
            <<gen_loop>>
            FOR i IN 2..50 LOOP
               l_tmp_name := REPLACE(l_fix_name,k_seq_nr,TRIM(TO_CHAR(i)));
               l_found := object_exists(p_owner,p_object_type,l_tmp_name,l_table_name) = 'Y';
               EXIT gen_loop WHEN NOT l_found;
            END LOOP gen_loop;
            assert(NOT l_found,'Cannot generate a unique object name after 50 iterations!');
         END IF;
         IF NOT l_found THEN
            l_fix_name := l_tmp_name;
         ELSE
            l_fix_name := NULL; -- not able to generate a unique object name
         END IF;
      ELSE
         l_found := object_exists(p_owner,p_object_type,l_fix_name,l_table_name) = 'Y';
      END IF;
      --
      IF (NVL(LENGTH(l_fix_name),0) > qc_utility_var.gk_identifier_name) THEN
         -- Oracle identifiers names (exception database and database link names) are limited to 30 chars!
         l_fix_name := NULL; -- not able to generate a unique object name
      END IF;
      -- Add fix name in cache
      IF l_fix_name IS NOT NULL THEN
         qc_utility_var.t_fix(CASE WHEN l_table_name IS NOT NULL THEN l_table_name||'.' END || l_fix_name) := p_object_type;
      END IF;
      RETURN l_fix_name;
   END gen_fix_name;
--#begin public
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
--#end public
   IS
      k_any_pattern CONSTANT VARCHAR2(20 CHAR) := '{_?any [^ ][^{}]*_?}';
      l_any_string VARCHAR2(100 CHAR);
      l_pattern qc_patterns.check_pattern%TYPE;
      l_pattern2 qc_patterns.check_pattern%TYPE;
      l_dict_name qc_dictionary_entries.dict_name%TYPE;
      r_rdict qc_dictionary_entries%ROWTYPE;
      l_match BOOLEAN;
      l_object_name VARCHAR2(4000 CHAR);
      l_table_name VARCHAR2(100 CHAR);
      l_object_type VARCHAR2(100 CHAR);
      l_object_subtype VARCHAR2(100 CHAR);
      l_prefix PLS_INTEGER;
      l_suffix PLS_INTEGER;
   BEGIN
      -- Decompose composed names: <table name>.<object name>
      split_string(p_object_type,l_object_type,l_object_subtype,':',1);
      decompose_name(l_object_type,p_object_name,l_table_name,l_object_name);
      l_pattern := replace_vars(l_object_type, p_owner, p_object_name, p_pattern);
--sys.dbms_output.put_line('any_string='||l_any_string);
      l_any_string := REGEXP_SUBSTR(l_pattern,k_any_pattern); -- result: {any name}
      IF l_any_string IS NOT NULL THEN
         l_prefix := CASE WHEN SUBSTR(l_any_string,2,1) = '_' THEN 1 ELSE 0 END;
         l_suffix := CASE WHEN SUBSTR(l_any_string,-2,1) = '_' THEN 1 ELSE 0 END;
         l_dict_name := UPPER(SUBSTR(l_any_string, 6+l_prefix, NVL(LENGTH(l_any_string),0)-(6+l_prefix+l_suffix)));
         IF qc_utility_var.g_rdict.EXISTS(l_dict_name) THEN
--sys.dbms_output.put_line('looking in DICT('||l_dict_name||')');
            r_rdict := NULL;
            <<rdict_loop>>
            FOR i IN 1..qc_utility_var.g_rdict(l_dict_name).COUNT LOOP
               r_rdict := qc_utility_var.g_rdict(l_dict_name)(i);
               l_pattern2 := REPLACE(l_pattern,l_any_string
                                    ,CASE WHEN l_prefix = 1 THEN '_' END||r_rdict.dict_value||
                                     CASE WHEN l_suffix = 1 THEN '_' END);
               IF NVL(REGEXP_INSTR(l_pattern2,'{_?any '),0) > 0 THEN
                  -- 2 {any <string>} found => the only way is to treat this case recursively
                  l_match := ext_regexp_like(p_object_type,p_owner,p_object_name,l_pattern2) = 1;
               ELSE
                  l_match := REGEXP_LIKE(l_object_name,l_pattern2);
               END IF;
               EXIT rdict_loop WHEN l_match;
            END LOOP rdict_loop;
--         ELSIF l_dict_name IN () -- TBD: object types in cache
         ELSE
--sys.dbms_output.put_line('looking in DB('||l_dict_name||')');
            DECLARE
               CURSOR c_obj (
                  p_object_type IN VARCHAR2
                , p_table_name IN VARCHAR2
               )
               IS
                  SELECT object_name
                    FROM all_objects
                   WHERE owner = p_owner
                     AND p_object_type != 'CONSTRAINT'
                     AND p_object_type NOT LIKE '_K COLUMN'
                     AND object_type = p_object_type
                     AND (object_type != 'TABLE ' OR SUBSTR(object_name,1,4) != 'BIN$')
                   UNION
                  SELECT constraint_name
                    FROM all_constraints
                   WHERE owner = p_owner
                     AND p_object_type = 'CONSTRAINT'
                     AND SUBSTR(table_name,1,4) != 'BIN$'
                     AND constraint_type IN ('P','U','R','C')
                   UNION
                  SELECT ccol.column_name
                    FROM all_cons_columns ccol
                   INNER JOIN all_constraints cons
                      ON cons.owner = ccol.owner
                     AND cons.constraint_name = ccol.constraint_name
                   WHERE ccol.owner = p_owner
                     AND p_object_type LIKE '_K COLUMN'
                     AND cons.constraint_type = REPLACE(SUBSTR(p_object_type,1,1),'F','R')
                     AND ccol.table_name = p_table_name
                  ;
               l_obj_cnt PLS_INTEGER := 0;
            BEGIN
               <<obj_loop>>
               FOR r_obj IN c_obj(l_dict_name,l_table_name) LOOP
                  l_obj_cnt := l_obj_cnt + 1;
                  l_pattern2 := REPLACE(l_pattern,l_any_string
                                       ,CASE WHEN l_prefix = 1 THEN '_' END||r_obj.object_name||
                                        CASE WHEN l_suffix = 1 THEN '_' END);
                  IF NVL(REGEXP_INSTR(l_pattern2,'{_?any '),0) > 0 THEN
                     l_match := ext_regexp_like(p_object_type,p_owner,p_object_name,l_pattern2) = 1;
                  ELSE
--sys.dbms_output.put_line('l_object_name='||l_object_name);
--sys.dbms_output.put_line('l_pattern2='||l_pattern2);
                     l_match := REGEXP_LIKE(l_object_name,l_pattern2);
                  END IF;
                  EXIT obj_loop WHEN l_match;
               END LOOP obj_loop;
--sys.dbms_output.put_line('l_obj_cnt='||l_obj_cnt);
               assert(l_obj_cnt > 0 OR l_table_name IS NOT NULL,'No object of type '||UPPER(l_dict_name)||' found for pattern '||p_pattern);
            END;
         END IF;
--sys.dbms_output.put_line('l_match='||CASE WHEN l_match THEN 'true' ELSE 'false' END);
      ELSE
         -- No {any} keyword found
         l_match := REGEXP_LIKE(l_object_name,l_pattern);
      END IF;
      RETURN CASE WHEN l_match THEN 1 ELSE 0 END;
   END ext_regexp_like;
--#begin public
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
--#end public
   IS
   BEGIN
      INSERT INTO qc_dictionary_entries (
         app_alias
       , dict_name, dict_key
       , dict_value, comments
      )
      VALUES (
         p_app_alias
       , p_dict_name, p_dict_key
       , p_dict_value, p_comments
      )
      ;
   END register_dictionary_entry;
   ---
   -- Load dictionary into cache
   ---
   PROCEDURE load_dictionary_entries (
      p_dict_name IN qc_dictionary_entries.dict_name%TYPE := NULL
   )
   IS
      CURSOR c_dict (
         p_dict_name IN qc_dictionary_entries.dict_name%TYPE := NULL
      )
      IS
         SELECT app_alias, dict_name, dict_key, dict_value
           FROM qc_dictionary_entries
          WHERE (p_dict_name IS NULL OR dict_name = p_dict_name)
            AND app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND dict_value IS NOT NULL
          UNION
         SELECT qc_utility_var.g_app_alias app_alias, 'TABLE' dict_name, tab.table_name dict_key, tab.table_name dict_value
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dict_own
             ON dict_own.dict_name = 'APP OWNER'
            AND dict_own.app_alias = qc_utility_var.g_app_alias
          WHERE tab.owner = dict_own.dict_key
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
            AND (p_dict_name IS NULL OR p_dict_name = 'TABLE')
          ORDER BY 1, 2
      ;
      CURSOR c_rdict (
         p_dict_name IN qc_dictionary_entries.dict_name%TYPE := NULL
      )
      IS
         SELECT *
           FROM (
            SELECT app_alias, dict_name, dict_key, dict_value, NULL comments
              FROM qc_dictionary_entries
             WHERE (p_dict_name IS NULL OR dict_name = p_dict_name)
               AND app_alias IN ('ALL', qc_utility_var.g_app_alias)
               AND dict_value IS NOT NULL
             UNION
            SELECT qc_utility_var.g_app_alias app_alias, 'TABLE' dict_name, tab.table_name dict_key, tab.table_name dict_value, NULL comments
              FROM all_tables tab
             INNER JOIN qc_patterns pat
                ON pat.object_type = 'TABLE'
               AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
             INNER JOIN qc_dictionary_entries dict_own
                ON dict_own.dict_name = 'APP OWNER'
               AND dict_own.app_alias = qc_utility_var.g_app_alias
             WHERE tab.owner = dict_own.dict_key
               AND SUBSTR(tab.table_name,1,4) != 'BIN$'
               AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
               AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
               AND (p_dict_name IS NULL OR p_dict_name = 'TABLE')
           )
          ORDER BY 1, NVL(length(dict_value),0) DESC, 3
      ;
      l_count INTEGER;
   BEGIN
      IF p_dict_name IS NULL THEN
         qc_utility_var.g_dict.DELETE;
         qc_utility_var.g_rdict.DELETE;
      ELSE
         IF qc_utility_var.g_dict.EXISTS(p_dict_name) THEN
            qc_utility_var.g_dict(p_dict_name).DELETE;
         END IF;
         IF qc_utility_var.g_rdict.EXISTS(p_dict_name) THEN
            qc_utility_var.g_rdict(p_dict_name).DELETE;
         END IF;
      END IF;
      <<dict_loop>>
      FOR r_dict IN c_dict(p_dict_name) LOOP
--sys.dbms_output.put_line(r_dict.dict_name||':'||r_dict.dict_key||':'||r_dict.dict_value);
         qc_utility_var.g_dict(r_dict.dict_name)(r_dict.dict_key) := r_dict.dict_value;
      END LOOP dict_loop;
      <<rdict_loop>>
      FOR r_rdict IN c_rdict(p_dict_name) LOOP
--sys.dbms_output.put_line(r_rdict.dict_name||':'||r_rdict.dict_value||':'||r_rdict.dict_key);
         IF qc_utility_var.g_rdict.EXISTS(r_rdict.dict_name) THEN
            l_count := qc_utility_var.g_rdict(r_rdict.dict_name).COUNT;
         ELSE
            l_count := 0;
         END IF;
         qc_utility_var.g_rdict(r_rdict.dict_name)(l_count+1) := r_rdict;
      END LOOP rdict_loop;
   END load_dictionary_entries;
--#begin public
   -- Init
   PROCEDURE init
--#end public
   IS
   BEGIN
      load_dictionary_entries;
--      qc_utility_var.g_app_alias := get_dictionary_entry('PARAMETER','APP ALIAS');
--      assert(qc_utility_var.g_app_alias IS NOT NULL,'Application alias is not defined!');
      qc_utility_var.t_fix.DELETE;
      load_tab_con;
      load_tab_ind;
      qc_utility_var.g_last_line := 1;
   END init;
/*
   ---
   -- Show dictionary into cache
   ---
   PROCEDURE show_dictionary_entries
   IS
      l_dict_name qc_dictionary_entries.dict_name%TYPE;
      l_dict_key qc_dictionary_entries.dict_key%TYPE;
      r_rdict qc_dictionary_entries%ROWTYPE;
   BEGIN
      sys.dbms_output.put_line('*** Dictionary ***');
      l_dict_name := qc_utility_var.g_dict.FIRST;
      <<dict_loop>>
      WHILE l_dict_name IS NOT NULL LOOP
         l_dict_key := qc_utility_var.g_dict(l_dict_name).FIRST;
         <<dict_subloop>>
         WHILE l_dict_key IS NOT NULL LOOP
            sys.dbms_output.put_line(l_dict_name||':'||l_dict_key||':'||qc_utility_var.g_dict(l_dict_name)(l_dict_key));
            l_dict_key := qc_utility_var.g_dict(l_dict_name).NEXT(l_dict_key);
         END LOOP dict_subloop;
         l_dict_name := qc_utility_var.g_dict.NEXT(l_dict_name);
      END LOOP dict_loop;
      sys.dbms_output.put_line('*** Reverse dictionary ***');
      l_dict_name := qc_utility_var.g_rdict.FIRST;
      <<rdict_name_loop>>
      WHILE l_dict_name IS NOT NULL LOOP
         <<rdict_subloop>>
         FOR i IN 1..qc_utility_var.g_rdict(l_dict_name).COUNT LOOP
            r_rdict := qc_utility_var.g_rdict(l_dict_name)(i);
            sys.dbms_output.put_line(r_rdict.dict_name||':'||r_rdict.dict_value||':'||r_rdict.dict_key);
         END LOOP rdict_subloop;
         l_dict_name := qc_utility_var.g_dict.NEXT(l_dict_name);
      END LOOP rdict_loop;
   END show_dictionary_entries;
*/
--#begin public
   ---
   -- Search dictionary value
   ---
   FUNCTION search_dictionary_value (
      p_dict_name IN qc_dictionary_entries.dict_name%TYPE
    , p_dict_value IN qc_dictionary_entries.dict_key%TYPE
   )
   RETURN qc_dictionary_entries.dict_key%TYPE
--#end public
   IS
      r_rdict qc_dictionary_entries%ROWTYPE;
   BEGIN
      IF qc_utility_var.g_rdict.EXISTS(p_dict_name) THEN
         <<rdict_loop>>
         FOR i IN 1..qc_utility_var.g_rdict(p_dict_name).COUNT LOOP
            r_rdict := qc_utility_var.g_rdict(p_dict_name)(i);
            IF r_rdict.dict_value = p_dict_value THEN
               RETURN r_rdict.dict_key;
            END IF;
         END LOOP rdict_loop;
      END IF;
      RETURN NULL;
   END search_dictionary_value;
--#begin public
   ---
   -- Extract table aliases from primary keys
   ---
   PROCEDURE extract_table_aliases_from_pk (
      p_match_pattern  IN VARCHAR2 := '^{app alias_}([A-Z]+)(_*UK|_*PK)([0-9])*$'
    , p_replace_string IN VARCHAR2 := '\1'
    , p_force_update   IN INTEGER := 0
    , p_app_alias      IN VARCHAR2 := NULL -- NULL means ALL
    )
--#end public
   IS
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on tables
      CURSOR c_tab
      IS
         SELECT pk.table_name, REGEXP_REPLACE(pk.constraint_name,qc_utility_krn.replace_vars(NULL,tab.owner,NULL,p_match_pattern),p_replace_string) table_alias
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN all_constraints pk
             ON pk.owner = tab.owner
            AND pk.table_name = tab.table_name
            AND pk.constraint_type IN ('P','U')
            AND REGEXP_LIKE (pk.constraint_name,qc_utility_krn.replace_vars(NULL,tab.owner,NULL,p_match_pattern))
          INNER JOIN qc_dictionary_entries dict_own
             ON dict_own.app_alias = qc_utility_var.g_app_alias
            AND dict_own.dict_name = 'APP SCHEMA'
          WHERE tab.owner = dict_own.dict_value
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          ORDER BY tab.table_name, constraint_type -- PK before UK
      ;
      k_dict_name CONSTANT qc_dictionary_entries.dict_name%TYPE := 'TABLE ALIAS';
   BEGIN
      <<app_loop>>
      FOR r_app IN c_app(p_app_alias) LOOP
      qc_utility_var.g_app_alias := r_app.app_alias;
      -- Load cache
      init;
      -- Extract table aliases and insert/update them in the dictionary
      <<tab_loop>>
      FOR r_tab IN c_tab LOOP
         IF get_dictionary_entry(k_dict_name, r_tab.table_name) IS NOT NULL
         THEN
            UPDATE qc_dictionary_entries
               SET dict_value = r_tab.table_alias
             WHERE dict_name = k_dict_name
               AND dict_key = r_tab.table_name
               AND app_alias = qc_utility_var.g_app_alias
               AND (p_force_update>0 OR dict_value IS NULL)
            ;
         ELSE
            INSERT INTO qc_dictionary_entries (
               app_alias, dict_name, dict_key, dict_value
            ) VALUES (
               qc_utility_var.g_app_alias, k_dict_name, r_tab.table_name, r_tab.table_alias
            );
            qc_utility_var.g_dict(k_dict_name)(r_tab.table_name) := r_tab.table_alias;
         END IF;
      END LOOP tab_loop;
      -- Delete no more needed dictionary entries
      DELETE qc_dictionary_entries
       WHERE dict_name = k_dict_name
         AND app_alias = qc_utility_var.g_app_alias
         AND dict_key NOT IN (
               SELECT tab.table_name
                 FROM all_tables tab
                INNER JOIN qc_patterns pat
                   ON pat.object_type = 'TABLE'
                  AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
                INNER JOIN qc_dictionary_entries dict_own
                   ON dict_own.app_alias = qc_utility_var.g_app_alias
                  AND dict_own.dict_name = 'APP SCHEMA'
                WHERE owner = dict_own.dict_value
                  AND SUBSTR(tab.table_name,1,4) != 'BIN$'
                  AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
                  AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
             )
      ;
      END LOOP app_loop;
      -- Refresh cache again
--      init;
   END extract_table_aliases_from_pk;
--#begin public
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
--#end public
   IS
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on tables
      CURSOR c_tab
      IS
         SELECT tab.table_name, REGEXP_REPLACE(tab.table_name,qc_utility_krn.replace_vars(NULL,tab.owner,NULL,p_match_pattern),p_replace_string) entity_name
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dict_own
             ON dict_own.app_alias = qc_utility_var.g_app_alias
            AND dict_own.dict_name = 'APP SCHEMA'
          WHERE tab.owner = dict_own.dict_value
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND REGEXP_LIKE(tab.table_name,qc_utility_krn.replace_vars(NULL,tab.owner,NULL,p_match_pattern))
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          ORDER BY tab.table_name
      ;
      k_dict_name CONSTANT qc_dictionary_entries.dict_name%TYPE := 'TABLE ENTITY';
      l_entity_name VARCHAR2(30);
   BEGIN
      <<app_loop>>
      FOR r_app IN c_app(p_app_alias) LOOP
      qc_utility_var.g_app_alias := r_app.app_alias;
      -- Load cache
      init;
      -- Extract table aliases and insert/update them in the dictionary
      <<tab_loop>>
      FOR r_tab IN c_tab LOOP
         l_entity_name := CASE WHEN p_singularify = 1
                               THEN CASE WHEN SUBSTR(l_entity_name,-3) = 'IES' THEN SUBSTR(l_entity_name,1,NVL(LENGTH(l_entity_name),0)-3)||'Y' -- CITIES => CITY
                                         WHEN SUBSTR(l_entity_name,-1) = 'S' THEN SUBSTR(l_entity_name,1,NVL(LENGTH(l_entity_name),0)-1) -- CARS => CAR
                                         ELSE l_entity_name
                                    END
                               ELSE r_tab.entity_name
                          END;
         IF get_dictionary_entry(k_dict_name, r_tab.table_name) IS NOT NULL
         THEN
            UPDATE qc_dictionary_entries
               SET dict_value = r_tab.entity_name
             WHERE dict_name = k_dict_name
               AND app_alias = qc_utility_var.g_app_alias
               AND dict_key = r_tab.table_name
               AND (p_force_update>0 OR dict_value IS NULL)
            ;
         ELSE
            INSERT INTO qc_dictionary_entries (
               app_alias, dict_name, dict_key, dict_value
            ) VALUES (
               qc_utility_var.g_app_alias, k_dict_name, r_tab.table_name, r_tab.entity_name
            );
            qc_utility_var.g_dict(k_dict_name)(r_tab.table_name) := r_tab.entity_name;
         END IF;
      END LOOP tab_loop;
      -- Delete no more needed dictionary entries
      DELETE qc_dictionary_entries
       WHERE dict_name = k_dict_name
         AND app_alias = qc_utility_var.g_app_alias
         AND dict_key NOT IN (
               SELECT tab.table_name
                 FROM all_tables tab
--                INNER JOIN qc_dictionary_entries dict_own
--                   ON dict_own.dict_name = 'OBJECT OWNER'
--                  AND dict_own.dict_key = 'TABLE'
                INNER JOIN qc_patterns pat
                   ON pat.object_type = 'TABLE'
                  AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
                INNER JOIN qc_dictionary_entries dict_own
                   ON dict_own.app_alias = qc_utility_var.g_app_alias
                  AND dict_own.dict_name = 'APP SCHEMA'
                WHERE owner = dict_own.dict_value
                  AND SUBSTR(tab.table_name,1,4) != 'BIN$'
                  AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
                  AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
             )
      ;
      END LOOP app_loop;
      -- Refresh cache again
--      init;
   END extract_entities_from_tables;
   -- Generate fix DDL
   FUNCTION gen_fix_ddl (
      p_op IN VARCHAR2
    , p_object_type IN VARCHAR2
    , p_owner IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_fix_type IN VARCHAR2
    , p_fix_name IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_extra_name IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_sql VARCHAR2(200 CHAR);
      l_object_type VARCHAR2(30 CHAR);
      l_fix_type VARCHAR2(30 CHAR);
      l_pos INTEGER;
      l_full_object_name VARCHAR2(61 CHAR);
      k_where CONSTANT VARCHAR2(30 CHAR) := 'gen_fix_ddl()';
   BEGIN
      l_full_object_name := p_owner||'.'||p_object_name;
      -- Remove object type qualifier (after semi-colon)
      -- e.g. INDEX: NON UNIQUE => INDEX
      l_pos := NVL(INSTR(p_object_type,':'),0);
      IF l_pos > 0 THEN
         l_object_type := SUBSTR(p_object_type,1,l_pos-1);
      ELSE
         l_object_type := p_object_type;
      END IF;
      l_pos := NVL(INSTR(p_fix_type,':'),0);
      IF l_pos > 0 THEN
         l_fix_type := SUBSTR(p_fix_type,1,l_pos-1);
      ELSE
         l_fix_type := p_fix_type;
      END IF;
      -- Syntax depends on object type
      IF p_op = 'RENAME' THEN
         IF l_object_type IN ('VIEW','SEQUENCE') THEN
            assert(p_owner=USER,':1 belonging to another schema cannot be renamed!', k_where, INITCAP(l_object_type));
            l_sql := 'RENAME '||p_object_name||' TO '||p_fix_name; --renaming a view in another schema is not supported!
         ELSIF l_object_type IN ('TABLE','INDEX','TRIGGER') THEN
            l_sql := 'ALTER '||l_object_type||' '||p_owner||'.'||p_object_name||' RENAME TO '||p_fix_name;
         ELSIF l_object_type IN ('CONSTRAINT','COLUMN') THEN
            l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' RENAME '||l_object_type||' '||p_object_name||' TO '||p_fix_name;
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_object_type, p_op);
         END IF;
      ELSIF p_op = 'DROP' THEN
         IF l_object_type IN ('TABLE','VIEW','SEQUENCE','INDEX','TRIGGER') THEN
            l_sql := 'DROP '||l_object_type||' '||p_owner||'.'||p_object_name;
         ELSIF l_object_type IN ('CONSTRAINT','COLUMN') THEN
            l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' DROP '||l_object_type||' '||p_object_name;
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_object_type, p_op);
         END IF;
      ELSIF p_op = 'CREATE' THEN
         IF l_object_type = 'CONSTRAINT' AND l_fix_type = 'INDEX' THEN
            l_sql := 'CREATE '||l_fix_type||' '||p_owner||'.'||p_fix_name||' ON '||p_owner||'.'||p_table_name||'('||LOWER(qc_utility_var.g_cache(p_owner).t_con(UPPER(p_object_name)).constraint_cols)||')'
                   ||CASE WHEN get_dictionary_entry('PARAMETER','IDX TS') IS NOT NULL THEN ' TABLESPACE '||get_dictionary_entry('PARAMETER','IDX TS') END;
         ELSIF l_object_type = 'TABLE COLUMN' THEN
            IF p_fix_type = 'CONSTRAINT: FOREIGN KEY' THEN
               l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' ADD (CONSTRAINT '||p_fix_name||' FOREIGN KEY ('||LOWER(qc_utility_var.g_cache(p_owner).t_con(UPPER(p_extra_name)).constraint_cols)||')'
                      ||' REFERENCES '||LOWER(qc_utility_var.g_cache(p_owner).t_con(UPPER(p_extra_name)).table_name)||' ('||LOWER(qc_utility_var.g_cache(p_owner).t_con(UPPER(p_extra_name)).constraint_cols)||')'||' ENABLE VALIDATE)';
            ELSIF p_fix_type = 'TABLE COLUMN' THEN
               l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' ADD '||SUBSTR(p_object_name,NVL(INSTR(p_object_name,'.',-1/*backward search from the end*/),0)+1)||' '||p_extra_name;
            ELSE
               assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_fix_type, p_op);
            END IF;
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_fix_type, p_op);
         END IF;
      ELSIF p_op = 'MODIFY' THEN
         IF l_object_type = 'TABLE COLUMN' THEN
            l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' MODIFY '||SUBSTR(p_object_name,NVL(INSTR(p_object_name,'.'),0)+1)||' '||p_extra_name;
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_fix_type, p_op);
         END IF;
      ELSIF p_op IN ('ENABLE','DISABLE') THEN
         IF l_object_type = 'CONSTRAINT' THEN
            l_sql := 'ALTER TABLE '||p_owner||'.'||p_table_name||' '||p_op||' CONSTRAINT '||p_object_name;
         ELSIF l_object_type = 'TRIGGER' THEN
            l_sql := 'ALTER TRIGGER '||p_owner||'.'||p_object_name||' '||p_op;
         ELSIF l_object_type = 'INDEX' THEN
            l_sql := 'ALTER INDEX '||p_owner||'.'||p_object_name||' '||CASE WHEN p_op='DISABLE' THEN 'UNUSABLE' ELSE 'REBUILD' END;
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_fix_type, p_op);
         END IF;
      ELSIF p_op IN ('COMPILE') THEN
         IF l_object_type IN ('VIEW','PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TRIGGER') THEN
            l_sql := 'ALTER '||p_owner||'.'||p_object_name||' COMPILE';
         ELSIF l_object_type = 'PACKAGE BODY' THEN
            l_sql := 'ALTER '||p_owner||'.'||p_object_name||' COMPILE BODY';
         ELSE
            assert(FALSE,'Unsupported data type (:1) for attempted operation (:2)', k_where, l_fix_type, p_op);
         END IF;
      END IF;
      RETURN l_sql;
   END gen_fix_ddl;
--#begin public
   ---
   -- Get object count from QC000 statistics
   ---
   FUNCTION object_count_from_stat (
      p_qc_code IN qc_run_stats.qc_code%TYPE
    , p_object_type IN qc_run_stats.object_type%TYPE
   )
   RETURN qc_run_stats.object_count%TYPE
--#end public
   IS
      CURSOR c_stat (
         p_qc_code IN qc_run_stats.qc_code%TYPE
       , p_object_type IN qc_run_stats.object_type%TYPE
      )
      IS
         SELECT SUM(object_count) object_count
           FROM qc_run_stats
          WHERE run_id_to IS NULL -- latest run
            AND qc_code = p_qc_code
            AND (object_type = p_object_type OR object_type LIKE p_object_type||': %')
         ;
      l_object_count qc_run_stats.object_count%TYPE;
   BEGIN
      OPEN c_stat(p_qc_code,p_object_type);
      FETCH c_stat INTO l_object_count;
      CLOSE c_stat;
      RETURN NVL(l_object_count,0);
   END object_count_from_stat;
--#begin public
   ---
   -- Return objects sorted by dependencies (= reverse order of compilation)
   ---
   FUNCTION sorted_objects
   RETURN qc_utility_var.gt_sorted_object_type PIPELINED
--#end public
   IS
      SUBTYPE l_name_type IS VARCHAR2(61 CHAR); -- type.name
      TYPE t_obj_type IS TABLE OF l_name_type INDEX BY BINARY_INTEGER;
      TYPE t_rev_type IS TABLE OF PLS_INTEGER INDEX BY l_name_type;
      TYPE t_int_type IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
      TYPE t_dep_type IS TABLE OF t_int_type INDEX BY BINARY_INTEGER;
      t_obj t_obj_type; -- objects table
      t_rev t_rev_type; -- reverse objects table
      t_dep t_dep_type; -- dependency matrix
      CURSOR c_obj IS
         SELECT object_type||'.'||object_name name
           FROM all_objects
          WHERE owner = NVL(qc_utility_var.g_object_owner,USER)
            AND object_type in ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER')
          ORDER BY object_type, object_name
      ;
      CURSOR c_dep IS
         SELECT referenced_type||'.'||referenced_name referencee
              , type||'.'||name referencer
           FROM all_dependencies
          WHERE owner = NVL(qc_utility_var.g_object_owner,USER)
            AND referenced_owner = NVL(qc_utility_var.g_object_owner,USER)
            AND type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER')
            AND referenced_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY')
         ;
      l_idx INTEGER;  -- 1st loop index
      l_nxt INTEGER;  -- next index
      l_idx2 INTEGER; -- 2nd loop index
      l_nxt2 INTEGER; -- next index
      l_max INTEGER;  -- max iteration
      l_del INTEGER;  -- deletions count
      l_ord INTEGER := 0;
      r_res qc_utility_var.gr_sorted_object_type;
   BEGIN
      --  Load objects
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         t_obj(t_obj.COUNT+1) := r_obj.name;
         t_rev(r_obj.name) := t_obj.COUNT;
--         dbms_output.put_line(t_obj.count||': '||r_obj.name);
      END LOOP obj_loop;
      -- Load dependencies
      <<dep_loop>>
      FOR r_dep IN c_dep LOOP
         t_dep(t_rev(r_dep.referencee))(t_rev(r_dep.referencer)) := 1;
      END LOOP dep_loop;
      -- Debug
   --   dbms_output.put_line('----');
   --   l_idx := t_dep.FIRST;
   --   <<idx_loop>>
   --   WHILE l_idx IS NOT NULL LOOP
   --      dbms_output.put(t_obj(l_idx)||':');
   --      l_idx2 := t_dep(l_idx).FIRST;
   --      <<idx2_loop>>
   --      WHILE l_idx2 IS NOT NULL LOOP
   --         dbms_output.put(t_obj(l_idx2)||' ');
   --         l_idx2 := t_dep(l_idx).NEXT(l_idx2);
   --      END LOOP idx2_loop;
   --      dbms_output.put_line(NULL);
   --      l_idx := t_dep.NEXT(l_idx);
   --   END LOOP idx_loop;
      l_del := 1;
      l_max := t_obj.COUNT;
      -- While objects have been found and deleted and no infinite loop
--      dbms_output.put_line('----');
      <<del_loop>>
      WHILE l_del > 0 AND l_max > 0 LOOP
         l_del := 0;
         l_max := l_max - 1;
         -- Browse all remaing objects to find those having no dependency
         l_idx := t_obj.FIRST;
         <<idx_loop>>
         WHILE l_idx IS NOT NULL LOOP
            -- Get next object before possible deletion
            l_nxt := t_obj.NEXT(l_idx);
            -- Has this object dependencies?
            IF NOT t_dep.EXISTS(l_idx) THEN
               -- List object
               l_ord := l_ord + 1;
               r_res.object_type := SUBSTR(t_obj(l_idx),1,NVL(INSTR(t_obj(l_idx),'.'),0)-1);
               r_res.object_name := SUBSTR(t_obj(l_idx),NVL(INSTR(t_obj(l_idx),'.'),0)+1);
               r_res.object_order := l_ord;
               PIPE ROW(r_res);
--               dbms_output.put_line(l_idx||': '||t_obj(l_idx));
               -- Delete object and count it
               t_obj.DELETE(l_idx);
               l_del := l_del + 1;
               -- Remove object from dependencies
               l_idx2 := t_dep.FIRST;
               <<idx2_loop>>
               WHILE l_idx2 IS NOT NULL LOOP
                  l_nxt2 := t_dep.NEXT(l_idx2);
                  IF t_dep(l_idx2).EXISTS(l_idx) THEN
                     t_dep(l_idx2).DELETE(l_idx);
                     IF t_dep(l_idx2).COUNT = 0 THEN
                        t_dep.DELETE(l_idx2);
                     END IF;
                  END IF;
                  l_idx2 := l_nxt2;
               END LOOP idx2_loop;
            END IF;
            l_idx := l_nxt;
         END LOOP idx_loop;
      END LOOP del_loop;
      IF l_max = 0 THEN
         raise_application_error(-20000,'infinite loop detected in sorted_objects');
      END IF;
   END sorted_objects;
--#begin public
   ---
   -- Set PLSCOPE settings
   ---
   PROCEDURE set_plscope (
      p_identifiers      IN VARCHAR2                 -- ALL:NONE:PUBLIC:SQL:PLSQL
    , p_statements       IN VARCHAR2 := NULL         -- ALL:NONE
   )
--#end public
   IS
      l_sql VARCHAR2(4000 CHAR);
   BEGIN
      assert(p_identifiers IS NOT NULL,'Error: mandatory p_identifier" parameter is mandatory');
      assert(p_identifiers IN ('ALL','NONE','PUBLIC','SQL','PLSQL')
            ,'Error: invalid value "'||p_identifiers||'" for "p_identifiers" parameter; allowed values are: ALL, NONE, PUBLIC, SQL, PLSQL');
      -- Change plscope settings as needed
      IF p_statements IS NULL OR sys.dbms_db_version.version <= 11 OR (sys.dbms_db_version.version = 12 AND sys.dbms_db_version.release = 1)
      THEN
         /* PL/Scope identifiers since 11.1 */
         l_sql := 'ALTER SESSION SET plscope_settings=''IDENTIFIERS:'||p_identifiers||'''';
      ELSE
         /* PL/Scope statements since 12.2 */
         assert(p_statements IN ('ALL','NONE')
               ,'Error: invalid value "'||p_statements||'" for "p_statements" parameter; allowed values are: ALL, NONE');
         l_sql := 'ALTER SESSION SET plscope_settings=''IDENTIFIERS:'||p_identifiers||', STATEMENTS:'||p_statements||'''';
      END IF;
      EXECUTE IMMEDIATE l_sql;
   END set_plscope;
--#begin public
   ---
   -- Enable PLSCOPE
   ---
   PROCEDURE enable_plscope
--#end public
   IS
   BEGIN
      set_plscope('ALL','ALL');
   END enable_plscope;
--#begin public
   ---
   -- Disable PLSCOPE
   ---
   PROCEDURE disable_plscope
--#end public
   IS
   BEGIN
      set_plscope('NONE','NONE');
   END disable_plscope;
--#begin public
   ---
   -- Compile PL/SQL code with requested options
   ---
   PROCEDURE compile_for_plscope (
      p_identifiers      IN VARCHAR2 := 'ALL'         -- ALL:NONE:PUBLIC:SQL:PLSQL
    , p_statements       IN VARCHAR2 := 'ALL'         -- ALL:NONE
    , p_compile_code     IN VARCHAR2 := 'INCREMENTAL' -- ALL:INCREMENTAL:NONE
    , p_compile_synonyms IN VARCHAR2 := 'NONE'        -- ALL:NONE
   )
--#end public
   IS
      e_is_not_udt     EXCEPTION;
      e_has_table_deps EXCEPTION;
      e_no_privs       EXCEPTION;
      PRAGMA exception_init(e_is_not_udt, -22307);
      PRAGMA exception_init(e_has_table_deps, -2311);
      PRAGMA exception_init(e_no_privs, -1031);
      l_sql VARCHAR2(4000 CHAR);
   BEGIN
      set_plscope(p_identifiers, p_statements);
      -- Compile synonyms as needed
      IF NOT (sys.dbms_db_version.version = 11 AND sys.dbms_db_version.version = 1) AND UPPER(p_compile_synonyms) = 'ALL' THEN
         /* Compilation of synonyms have been introduced with EBR in 11.2 */
         <<synonyms>>
         FOR r IN (
            SELECT owner, synonym_name
              FROM all_synonyms
             WHERE owner = NVL(qc_utility_var.g_object_owner,USER)
         ) LOOP
            l_sql := 'ALTER SYNONYM "' || r.owner||'.'||r.synonym_name || '" COMPILE';
            EXECUTE IMMEDIATE l_sql;
         END LOOP synonyms;
         <<public_synonyms>>
         FOR R IN (
            SELECT synonym_name
              FROM all_synonyms
             WHERE owner = 'PUBLIC'
               AND table_owner = NVL(qc_utility_var.g_object_owner,USER)
         ) LOOP
            <<compile_public_synonym>>
            BEGIN
               l_sql := 'ALTER PUBLIC SYNONYM "' || r.synonym_name || '" COMPILE';
               EXECUTE IMMEDIATE l_sql;
            EXCEPTION
               WHEN e_no_privs THEN
                  /* ignore when user does not have create public synonym and drop public synonym privileges */
                  NULL;
            END compile_public_synonym;
         END LOOP public_synonyms;
      END IF;
      -- Compile code as needed
      IF UPPER(p_compile_code) = 'ALL' THEN
         /* Compile types */
         <<types>>
         FOR r IN (
            SELECT o.object_type, o.object_name, count(d.name) AS priority
              FROM sys.all_objects o
              LEFT JOIN all_dependencies d
                ON d.owner = o.owner
                   AND d.type = o.object_type
                   AND d.name = o.object_name
             WHERE o.owner = NVL(qc_utility_var.g_object_owner,USER)
               AND o.object_type in ('TYPE', 'TYPE BODY')
             GROUP BY o.object_TYPE, o.object_NAME
             ORDER BY priority
         ) LOOP
            <<compile_type>>
            IF r.object_type = 'TYPE' THEN
               l_sql := 'ALTER TYPE "' || r.object_name || '" COMPILE';
            ELSE
               l_sql := 'ALTER TYPE "' || r.object_name || '" COMPILE BODY';
            END IF;
            BEGIN
                EXECUTE IMMEDIATE l_sql;
            EXCEPTION
                WHEN e_is_not_udt THEN
                   /* ignore errors for non user-defined types */
                   NULL;
                WHEN e_has_table_deps THEN
                   /* ignore when type is used in tables */
                   NULL;
            END compile_type;
         END LOOP types;
         /* Compile schema handles procedures, functions, packages, views and triggers only */
         sys.dbms_utility.compile_schema(
            schema         => NVL(qc_utility_var.g_object_owner,USER),
            compile_all    => TRUE,
            reuse_settings => FALSE
         );
      ELSIF UPPER(p_compile_code) = 'INCREMENTAL' THEN
         <<objects_loop>>
         FOR r_obj IN (
            SELECT ord.object_type, ord.object_name
              FROM (
                  -- All PL/SQL objects
                  SELECT owner, object_type, object_name
                    FROM all_objects
                   WHERE owner = NVL(qc_utility_var.g_object_owner,USER)
                     AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TYPE', 'TYPE BODY')
                     AND (object_type NOT IN ('TYPE','TYPE BODY') OR object_name NOT LIKE 'SYS_PLSQL%') -- exclude SYS Types
                     AND object_name NOT LIKE 'QC_UTILITY%'
                   MINUS
                  -- Except those having plscope identifiers
                  SELECT DISTINCT owner, object_type, object_name
                    FROM all_identifiers
                   WHERE owner = NVL(qc_utility_var.g_object_owner,USER)
             ) obj
             INNER JOIN TABLE(qc_utility_krn.sorted_objects) ord
                ON ord.object_type = obj.object_type
               AND ord.object_name = obj.object_name
             ORDER BY ord.object_order
         )
         LOOP
            <<compile_object>>
            IF r_obj.object_type LIKE '% BODY' THEN
               l_sql := 'ALTER ' || REPLACE(r_obj.object_type,' BODY') || ' ' || r_obj.object_name || ' COMPILE BODY';
            ELSE
               l_sql := 'ALTER ' || r_obj.object_type || ' ' || r_obj.object_name || ' COMPILE';
            END IF;
            BEGIN
               EXECUTE IMMEDIATE l_sql;
            null;
            EXCEPTION
               WHEN OTHERS THEN NULL; -- ignore on purpose any compilation error
            END compile_object;
         END LOOP objects_loop;
      END IF;
   END compile_for_plscope;
   -- QC000: List of objects and statistics T
   PROCEDURE qc000 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         -- Generic handling for all object types
         SELECT 10 sort_order, obj.object_type, obj.owner, obj.object_name
              , CASE WHEN obj.object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TYPE','TYPE BODY','TRIGGER')
                     THEN 'CHECKSUM='||MOD(SUM(sys.dbms_utility.get_hash_value(src.text,1000000000,POWER(2,30))),POWER(2,30))
                     ELSE obj.object_name
                 END msg_text
           FROM all_objects obj
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND pat.object_type NOT IN ('CONSTRAINT','INDEX','VIEW','MATERIALIZED VIEW') -- handled separately below
            AND pat.object_type NOT IN ('SYNONYM','LOB') -- not in the scope of Q000
           LEFT OUTER JOIN all_source src
             ON src.owner = obj.owner
            AND src.TYPE = obj.object_type
            AND src.NAME = obj.object_name
          WHERE obj.owner != 'SYS'
            AND obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (obj.object_type != 'TABLE' OR SUBSTR(obj.object_name,1,4) != 'BIN$')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
          GROUP BY obj.object_type, obj.owner, obj.object_name
          UNION
         -- Specific handling for pk, uk and fk
         SELECT 20 sort_order, pat.object_type, con.owner
              , con.table_name||'.'||con.constraint_name object_name, qc_utility_krn.get_cons_columns(con.owner, con.table_name, con.constraint_name) msg_text
           FROM all_constraints con
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'CONSTRAINT: '||DECODE(con.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY','C','CHECK')
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
         INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.owner != 'SYS' -- workaround for what seems to be an Oracle bug (SYS constraints are returned by this query!)
            AND con.constraint_type IN ('P','U','R')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for check constraints
         SELECT 21 sort_order, pat.object_type, con.owner, con.table_name||'.'||con.constraint_name object_name
              , 'CHECKSUM='||MOD(SUM(sys.dbms_utility.get_hash_value(qc_utility_krn.get_con_search_condition(con.owner, con.constraint_name),1000000000,POWER(2,30))),POWER(2,30)) msg_text
           FROM all_constraints con
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'CONSTRAINT: '||DECODE(con.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY','C','CHECK')
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND con.owner != 'SYS' -- workaround for what seems to be an Oracle bug (SYS constraints are returned by this query!)
            AND con.constraint_type IN ('C')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.exclude_pattern)=0)
          GROUP BY pat.object_type, con.owner, con.table_name||'.'||con.constraint_name
          UNION
         -- Specific handling for indexes
         SELECT 30 sort_order, pat.object_type, ind.owner, ind.table_name||'.'||ind.index_name object_name, qc_utility_krn.get_ind_columns(ind.owner, ind.table_name, ind.index_name) msg_text
           FROM (-- Generation of fix name needs object always returned in the same order
                 SELECT ind.*, qc_utility_krn.get_ind_type(ind.owner,ind.table_name,ind.index_name) idx_type
                   FROM all_indexes ind
--                  INNER JOIN qc_dictionary_entries dict_own
--                     ON dict_own.dict_name = 'OBJECT OWNER'
--                    AND dict_own.dict_key = 'TABLE'
                  WHERE ind.owner = NVL(qc_utility_var.g_object_owner,USER)
                    AND SUBSTR(ind.table_name,1,4) != 'BIN$'
                  ORDER BY table_name, index_name
                ) ind
          INNER JOIN qc_patterns pat
             ON pat.object_type = ind.idx_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE 1=1
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(ind.idx_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(ind.idx_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for views
         SELECT 50 sort_order, pat.object_type, vw.owner, vw.view_name object_name
              , 'CHECKSUM='||MOD(SUM(sys.dbms_utility.get_hash_value(qc_utility_krn.get_view_text(vw.owner,vw.view_name),1000000000,POWER(2,30))),POWER(2,30)) msg_text
           FROM all_views vw
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'VIEW'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE vw.owner != 'SYS' -- workaround for what seems to be an Oracle bug (SYS constraints are returned by this query!)
            AND vw.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,vw.owner,vw.view_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,vw.owner,vw.view_name,pat.exclude_pattern)=0)
          GROUP BY pat.object_type, vw.owner, vw.view_name
          UNION
         -- Specific handling for materialized views
         SELECT 51 sort_order, pat.object_type, mvw.owner, mvw.mview_name object_name
              , 'CHECKSUM='||MOD(SUM(sys.dbms_utility.get_hash_value(qc_utility_krn.get_mview_query(mvw.owner,mvw.mview_name),1000000000,POWER(2,30))),POWER(2,30)) msg_text
           FROM all_mviews mvw
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'MATERIALIZED VIEW'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE mvw.owner != 'SYS' -- workaround for what seems to be an Oracle bug (SYS constraints are returned by this query!)
            AND mvw.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.exclude_pattern)=0)
          GROUP BY pat.object_type, mvw.owner, mvw.mview_name
          UNION
         -- Specific handling for column names
         SELECT 60 sort_order, obj.object_type||' COLUMN', col.owner, col.table_name||'.'||col.column_name object_name
                 , CASE WHEN col.data_type = 'NUMBER' AND col.data_precision IS NULL AND col.data_scale = 0 THEN 'INTEGER' ELSE col.data_type END
                || CASE WHEN col.data_precision IS NOT NULL THEN --NUMBER()?
                        CASE WHEN NVL(col.data_scale,0) > 0
                             THEN '('||col.data_precision||','||col.data_scale||')'
                             ELSE '('||col.data_precision||')'
                         END
                        WHEN col.char_used IS NOT NULL /*CHAR,VARCHAR2*/
                        THEN '('||col.char_length||CASE WHEN col.char_used='C' THEN ' CHAR' END||')'
                   END
                || CASE WHEN col.nullable = 'N' THEN ' NOT'
                   END || ' NULL'
                   msg_type
           FROM all_tab_columns col
          INNER JOIN all_objects obj
             ON obj.owner = col.owner
            AND obj.object_name  = col.table_name
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = obj.object_type
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)

          WHERE col.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(col.table_name,1,4) != 'BIN$'
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,col.owner,col.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,col.owner,col.table_name,pat2.exclude_pattern)=0)
          ORDER BY 3, 1, 2, 4
      ;
      TYPE t_object_type_count_hash_type IS TABLE OF INTEGER INDEX BY qc_run_msgs.object_type%TYPE;
      t_count t_object_type_count_hash_type;
      l_object_type qc_run_msgs.object_type%TYPE;
      l_fix_op qc_run_msgs.fix_op%TYPE;
      l_fix_desc qc_run_msgs.msg_text%TYPE;
      PROCEDURE increment_count (
         p_object_type IN VARCHAR2
      )
      IS
      BEGIN
         IF t_count.EXISTS(p_object_type) THEN
            t_count(p_object_type) := t_count(p_object_type) + 1;
         ELSE
            t_count(p_object_type) := 1;
         END IF;
      END increment_count;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         increment_count(r_obj.object_type);
         log_run_msg('QC000',r_obj.object_name
            ,NULL/*fix name*/, NULL/*fix op*/
            ,r_obj.object_type,NULL,NULL,r_obj.sort_order,'Y'/*hidden*/,p_msg_type
            ,r_obj.msg_text
            ,NULL/*object desc*/, r_obj.object_name, NULL/*check_pattern*/
         );
      END LOOP obj_loop;
      l_object_type := t_count.FIRST;
      <<obj_type_loop>>
      WHILE l_object_type IS NOT NULL LOOP
         log_run_stat('QC000',l_object_type,t_count(l_object_type));
         l_object_type := t_count.NEXT(l_object_type);
      END LOOP obj_type_loop;
   END qc000;
   -- QC001: Each table must have an alias E
   PROCEDURE qc001 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT obj.object_type, obj.object_name
              , INITCAP(obj.object_type) object_desc
              , dict.dict_value
           FROM all_objects obj
           LEFT OUTER JOIN qc_dictionary_entries dict
             ON dict.dict_name = obj.object_type||' ALIAS'
            AND dict.dict_key = obj.object_name
            AND dict.app_alias = qc_utility_var.g_app_alias
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND obj.object_type = 'TABLE'
            AND SUBSTR(obj.object_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      l_count INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_count := l_count + 1;
         IF r_obj.dict_value IS NULL THEN
            log_run_msg('QC001',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type,':1 :2 has no defined alias'
                  ,r_obj.object_desc, r_obj.object_name
                  );
         END IF;
      END LOOP obj_loop;
      log_run_stat('QC001','TABLE',l_count);
   END qc001;
   -- QC002: Table aliases must be unique E
   PROCEDURE qc002 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT a.dict_name object_type, a.dict_key object_name
              , INITCAP(REPLACE(a.dict_name,' ALIAS')) object_desc
              , a.dict_value object_alias
           FROM qc_dictionary_entries a
          WHERE a.dict_value IS NOT NULL
            AND a.app_alias = qc_utility_var.g_app_alias
            AND (a.dict_name, a.dict_value) IN (
                   SELECT b.dict_name, b.dict_value
                     FROM qc_dictionary_entries b
                    WHERE b.dict_name LIKE '%ALIAS'
                      AND b.app_alias = qc_utility_var.g_app_alias
                    GROUP BY b.dict_name, b.dict_value
                   HAVING COUNT(*) > 1
                )
          ORDER BY 1, 2
      ;
      CURSOR c_cnt IS
         SELECT dict_name object_type, COUNT(*) object_count
           FROM qc_dictionary_entries
          WHERE dict_name LIKE '%ALIAS'
            AND app_alias = qc_utility_var.g_app_alias
          GROUP BY dict_name
          ORDER BY 1
      ;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg('QC002',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type,':1 :2 has a duplicate alias :3'
               ,r_obj.object_desc, r_obj.object_name, r_obj.object_alias
               );
      END LOOP obj_loop;
      <<cnt_loop>>
      FOR r_cnt IN c_cnt LOOP
         log_run_stat('QC002',r_cnt.object_type,r_cnt.object_count);
      END LOOP cnt_loop;
   END qc002;
   -- QC004: Each table must have a primary key E
   PROCEDURE qc004 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT pat.object_type, tab.table_name object_name, INITCAP(pat.object_type) object_desc, pk.constraint_name
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN all_constraints pk
             ON pk.owner = tab.owner
            AND pk.table_name = tab.table_name
            AND pk.constraint_type = 'P'
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      l_count INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_count := l_count + 1;
         IF r_obj.constraint_name IS NULL THEN
            log_run_msg('QC004',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
               ,':1 :2 has no primary key',r_obj.object_desc, r_obj.object_name
            );
         END IF;
      END LOOP obj_loop;
      log_run_stat('QC004','TABLE',l_count);
   END qc004;
   -- QC005: Each table should have at least one foreign key to another table W
   PROCEDURE qc005 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT 'TABLE' object_type, tab.table_name object_name, 'Table' object_desc
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type IN ('QC005')
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat2.exclude_pattern)=0)
            AND tab.table_name NOT IN (
                   SELECT fk.table_name
                     FROM all_constraints fk
--                    INNER JOIN qc_dictionary_entries dict_own
--                       ON dict_own.dict_name = 'OBJECT OWNER'
--                      AND dict_own.dict_key = 'TABLE'
                    WHERE fk.owner = NVL(qc_utility_var.g_object_owner,USER)
                      AND fk.constraint_type = 'R'
                    UNION
                   SELECT pk.table_name
                     FROM all_constraints pk
                    INNER JOIN all_constraints fk
                       ON fk.r_owner = pk.owner
                      AND fk.r_constraint_name = pk.constraint_name
                      AND fk.constraint_type = 'R'
--                    INNER JOIN qc_dictionary_entries dict_own
--                       ON dict_own.dict_name = 'OBJECT OWNER'
--                      AND dict_own.dict_key = 'TABLE'
                    WHERE pk.owner = NVL(qc_utility_var.g_object_owner,USER)
                      AND pk.constraint_type IN ('P','U')
                )
         ORDER BY 1, 2
      ;
      CURSOR c_cnt IS
         SELECT COUNT(*)
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
      ;
      l_count INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg('QC005',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
            ,':1 :2 is not linked to any other table', r_obj.object_desc, r_obj.object_name
         );
      END LOOP obj_loop;
      OPEN c_cnt;
      FETCH c_cnt INTO l_count;
      CLOSE c_cnt;
      log_run_stat('QC005','TABLE',l_count);
   END qc005;
   -- QC007: Each table/column/mview must have a comment E
   PROCEDURE qc007 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT pat.object_type, tab.table_name object_name, INITCAP(pat.object_type) object_desc, com.comments
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)

           LEFT OUTER JOIN all_tab_comments com
             ON com.owner = tab.owner
            AND com.table_name = tab.table_name
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          UNION
         SELECT pat.object_type, mvw.mview_name object_name, INITCAP(pat.object_type) object_desc, com.comments
           FROM all_mviews mvw
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'MATERIALIZED VIEW'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN all_mview_comments com
             ON com.owner = mvw.owner
            AND com.mview_name = mvw.mview_name
          WHERE mvw.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.exclude_pattern)=0)
          UNION
         SELECT pat2.object_type, col.table_name||'.'||col.column_name object_name, INITCAP(pat2.object_type) object_desc, com.comments
           FROM all_tables tab
          INNER JOIN all_objects obj
             ON obj.object_name = tab.table_name
          INNER JOIN all_tab_columns col
             ON col.owner = tab.owner
            AND col.table_name = tab.table_name
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = obj.object_type||' COLUMN'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN all_col_comments com
             ON com.owner = col.owner
            AND com.table_name = col.table_name
            AND com.column_name = col.column_name
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (obj.object_type != 'TABLE' OR SUBSTR(obj.object_name,1,4) != 'BIN$')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      TYPE t_object_type_count_hash_type IS TABLE OF INTEGER INDEX BY qc_run_msgs.object_type%TYPE;
      t_count t_object_type_count_hash_type;
      l_object_type qc_run_msgs.object_type%TYPE;
      PROCEDURE increment_count (
         p_object_type IN VARCHAR2
      )
      IS
      BEGIN
         IF t_count.EXISTS(p_object_type) THEN
            t_count(p_object_type) := t_count(p_object_type) + 1;
         ELSE
            t_count(p_object_type) := 1;
         END IF;
      END increment_count;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         increment_count(r_obj.object_type);
         IF r_obj.comments IS NULL THEN
            log_run_msg('QC007',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
               ,':1 :2 has no comment', r_obj.object_desc, r_obj.object_name
            );
         END IF;
      END LOOP obj_loop;
      l_object_type := t_count.FIRST;
      <<obj_type_loop>>
      WHILE l_object_type IS NOT NULL LOOP
         log_run_stat('QC007',l_object_type,t_count(l_object_type));
         l_object_type := t_count.NEXT(l_object_type);
      END LOOP obj_type_loop;
   END qc007;
   -- QC008: Object names must match standard pattern E
   -- QC020: Object names must not match anti-pattern E
   PROCEDURE qc008 (
      p_msg_type IN VARCHAR2
    , p_anti_pattern IN VARCHAR2 := 'N'
   )
   IS
      l_fix_name qc_run_msgs.fix_name%TYPE;
      CURSOR c_obj IS
         -- Generic handling for all object types
         SELECT 10 sort_order, obj.object_type, obj.owner, 'Name of '||LOWER(obj.object_type) object_desc, obj.object_name
              , obj.object_type fix_type,obj.object_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(obj.object_type,obj.owner,object_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_objects obj
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
            AND pat.object_type NOT IN ('TRIGGER','CONSTRAINT','INDEX') -- handled separately below
          WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (obj.object_type != 'TABLE' OR SUBSTR(obj.object_name,1,4) != 'BIN$')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
          UNION
         -- Specific handling for constraints
         SELECT 20 sort_order, pat.object_type, con.owner
              , 'Name of '||DECODE(con.constraint_type,'P','primary key','U','unique key','R','foreign key','C','check','other')||' constraint' object_desc
              , con.table_name||'.'||con.constraint_name object_name
              , 'CONSTRAINT' fix_type,con.table_name||'.'||con.constraint_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars('CONSTRAINT',con.owner,con.table_name||'.'||con.constraint_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like('CONSTRAINT',con.owner,con.table_name||'.'||con.constraint_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_constraints con
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'CONSTRAINT: '||DECODE(con.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY','C','CHECK')
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN all_constraints fk
             ON fk.owner = con.r_owner
            AND fk.constraint_name = con.r_constraint_name
          WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND con.owner != 'SYS' -- workaround for what seems to be an Oracle bug (SYS constraints are returned by this query while they should not!)
            AND con.constraint_type IN ('P','U','R','C')
$IF NOT dbms_db_version.ver_le_11 $THEN
            AND (con.constraint_type != 'C' OR con.search_condition_vc NOT LIKE '"%" IS NOT NULL')
$END
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.exclude_pattern)=0)
          UNION
$IF NOT dbms_db_version.ver_le_11 $THEN
         -- Specific handling for not null constraints (new feature of v21.0)
         -- Only implemented as of Oracle 12c based on the new "search_condition_vc" column
         -- Indeed, the "search_condition" LONG column cannot be filtered (at least easily)
         SELECT 25 sort_order, pat.object_type, con.owner
              , 'Name of not null constraint' object_desc
              , con.table_name||'.'||con.constraint_name object_name
              , 'TABLE COLUMN' fix_type,col.table_name||'.'||col.column_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars('TABLE COLUMN',col.owner,col.table_name||'.'||col.column_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like('CONSTRAINT',con.owner,con.table_name||'.'||con.constraint_name,
                   qc_utility_krn.replace_vars('TABLE COLUMN',col.owner,col.table_name||'.'||col.column_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END)) check_res
              , pat.msg_type
           FROM all_constraints con
          INNER JOIN all_tab_columns col
             ON col.table_name = con.table_name
            AND col.nullable = 'N'
            AND con.search_condition_vc = '"'||col.column_name||'" IS NOT NULL'
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'CONSTRAINT: NOT NULL'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND con.constraint_type = 'C'
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name||'.'||con.constraint_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,con.owner,con.table_name,pat2.exclude_pattern)=0)
$END
          UNION
         -- Specific handling for indexes
         SELECT 30 sort_order, pat.object_type, ind.owner
              , 'Name of '||LOWER(REPLACE(ind.idx_type,'INDEX: ',NULL))||' index' object_desc
              , ind.table_name||'.'||ind.index_name object_name
              , 'INDEX' fix_type,ind.table_name||'.'||ind.index_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars('INDEX',ind.owner,ind.table_name||'.'||ind.index_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like('INDEX',ind.owner,ind.table_name||'.'||ind.index_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM (-- Generation of fix name needs object always returned in the same order
                 SELECT ind.*, qc_utility_krn.get_ind_type(ind.owner,ind.table_name,ind.index_name) idx_type
                   FROM all_indexes ind
--                  INNER JOIN qc_dictionary_entries dict_own
--                     ON dict_own.dict_name = 'OBJECT OWNER'
--                    AND dict_own.dict_key = 'TABLE'
                  WHERE ind.owner = NVL(qc_utility_var.g_object_owner,USER)
                    AND SUBSTR(ind.table_name,1,4) != 'BIN$'
                  ORDER BY table_name, index_name
                ) ind
          INNER JOIN qc_patterns pat
             ON pat.object_type = qc_utility_krn.get_ind_type(ind.owner,ind.table_name,ind.index_name)
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE 1=1
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(ind.idx_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(ind.idx_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for object aliases
         SELECT 5 sort_order, REPLACE(pat.object_type,NULL/*' ALIAS'*/) object_type, NVL(qc_utility_var.g_object_owner,USER)
              , 'Alias of '||LOWER(REPLACE(dict.dict_name,NULL/*' ALIAS'*/)) object_desc
              , dict.dict_key||'.'||dict.dict_value object_name
              , REPLACE(pat.object_type,NULL/*' ALIAS'*/) fix_type,dict.dict_key||'.'||dict.dict_value fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(REPLACE(pat.object_type,NULL/*' ALIAS'*/),NVL(qc_utility_var.g_object_owner,USER),dict.dict_key||'.'||dict.dict_value,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(REPLACE(pat.object_type,NULL/*' ALIAS'*/),NVL(qc_utility_var.g_object_owner,USER),dict.dict_key||'.'||dict.dict_value,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM qc_dictionary_entries dict
          INNER JOIN qc_patterns pat
             ON pat.object_type = dict.dict_name
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          WHERE dict.dict_name = 'TABLE ALIAS'
            AND dict.app_alias = qc_utility_var.g_app_alias
            AND dict.dict_value IS NOT NULL -- checked elsewhere
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(REPLACE(pat.object_type,' ALIAS'),NVL(qc_utility_var.g_object_owner,USER),dict.dict_key||'.'||dict.dict_value,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(REPLACE(pat.object_type,' ALIAS'),NVL(qc_utility_var.g_object_owner,USER),dict.dict_key||'.'||dict.dict_value,pat.exclude_pattern)=0)
          UNION
         -- Specific handling for triggers
         SELECT 50 sort_order, pat.object_type, trg.owner
              , 'Name of '||LOWER(pat.object_type) object_desc
              , trg.table_name||'.'||trg.trigger_name object_name
              , pat.object_type fix_type,trg.table_name||'.'||trg.trigger_name fix_name
              , qc_utility_krn.replace_vars(pat.object_type,trg.owner,trg.table_name||'.'||trg.trigger_name,pat.fix_pattern) fix_pattern
              , CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,trg.owner,trg.table_name||'.'||trg.trigger_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(pat.object_type,trg.owner,trg.table_name||'.'||trg.trigger_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_triggers trg
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TRIGGER'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE trg.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(trg.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,trg.owner,trg.table_name||'.'||trg.trigger_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,trg.owner,trg.table_name||'.'||trg.trigger_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,trg.owner,trg.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,trg.owner,trg.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for column names
         SELECT 60 sort_order, pat.object_type, col.owner, 'Name of '||LOWER(pat.object_type) object_desc, col.table_name||'.'||col.column_name object_name
              , pat.object_type fix_type,col.table_name||'.'||col.column_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,col.owner,col.table_name||'.'||col.column_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(pat.object_type,col.owner,col.table_name||'.'||col.column_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_tab_columns col
          INNER JOIN all_tables tab
             ON tab.owner = col.owner
            AND tab.table_name = col.table_name
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE COLUMN'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
         WHERE col.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(col.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,col.owner,col.table_name||'.'||col.column_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,col.owner,col.table_name||'.'||col.column_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,tab.owner,tab.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,tab.owner,tab.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for table comments
         SELECT 70 sort_order, pat.object_type, com.owner, 'Comment on table' object_desc, com.table_name object_name
              , pat.object_type fix_type,com.table_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,com.owner,com.table_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_tab_comments com
          INNER JOIN all_tables tab
             ON tab.owner = com.owner
            AND tab.table_name = com.table_name
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE COMMENT'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE com.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND com.comments IS NOT NULL
            AND SUBSTR(com.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,tab.owner,tab.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,tab.owner,tab.table_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for materialized view comments
         SELECT 80 sort_order, pat.object_type, com.owner, 'Comment on materialized view' object_desc, mvw.mview_name object_name
              , pat.object_type fix_type,mvw.mview_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,mvw.owner,mvw.mview_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like('MATERIALIZED VIEW',mvw.owner,mvw.mview_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_mview_comments com
          INNER JOIN all_mviews mvw
             ON mvw.owner = com.owner
            AND mvw.mview_name = com.mview_name
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'MVIEW COMMENT'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'MATERIALIZED VIEW'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE com.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND com.comments IS NOT NULL
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,mvw.owner,mvw.mview_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,mvw.owner,mvw.mview_name,pat2.exclude_pattern)=0)
          UNION
         -- Specific handling for table/view/materialized view column comments
         SELECT 90 sort_order, pat.object_type, com.owner, 'Comment on '||LOWER(obj.object_type)||' column' object_desc, col.table_name||'.'||col.column_name object_name
              , pat.object_type fix_type, col.table_name||'.'||col.column_name fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,col.owner,col.table_name||'.'||col.column_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_tab_columns col
          INNER JOIN all_col_comments com
             ON com.owner = col.owner
            AND com.table_name = col.table_name
            AND com.column_name = col.column_name
            AND com.comments IS NOT NULL
          INNER JOIN all_objects obj
             ON obj.owner = col.owner
            AND obj.object_name = col.table_name
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type||' COLUMN COMMENT'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = obj.object_type
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE col.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (obj.object_type != 'TABLE' OR SUBSTR(obj.object_name,1,4) != 'BIN$')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,com.owner,com.comments,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,obj.owner,obj.object_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,obj.owner,obj.object_name,pat2.exclude_pattern)=0)
/*
--Replaced with checking of PL/SQL identifiers via PL/SCOPE
         UNION
         -- Specific handling for arguments
         SELECT 100 sort_order, pat.object_type, arg.owner

          INNER JOIN qc_patterns pat
             ON pat.object_type = RTRIM('ARGUMENT: '||qc_utility_krn.get_dictionary_entry('ARGUMENT DATA TYPE',arg.data_type),': ')
            AND (p_anti_pattern = 'Y' OR pat.check_pattern IS NOT NULL)
            AND (p_anti_pattern = 'N' OR pat.anti_pattern IS NOT NULL)
          WHERE arg.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND arg.argument_name IS NOT NULL
            AND arg.data_level = 0
            AND (pat_pkg.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_pkg.object_type,arg.owner,arg.package_name,pat_pkg.include_pattern)=1)
            AND (pat_pkg.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat_pkg.object_type,arg.owner,arg.package_name,pat_pkg.exclude_pattern)=0)
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,arg.owner,arg.package_name||'.'||arg.object_name||'.'||arg.argument_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,arg.owner,arg.package_name||'.'||arg.object_name||'.'||arg.argument_name,pat.exclude_pattern)=0)         , 'Name of argument' object_desc
              , arg.package_name||'.'||arg.object_name||'.'||arg.argument_name object_name
              , NULL fix_type,NULL fix_name,pat.fix_pattern, CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END check_pattern
              , qc_utility_krn.replace_vars(pat.object_type,arg.owner,arg.package_name||'.'||arg.object_name||'.'||arg.argument_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_pattern2
              , qc_utility_krn.ext_regexp_like(pat.object_type,arg.owner,arg.package_name||'.'||arg.object_name||'.'||arg.argument_name,CASE WHEN p_anti_pattern='Y' THEN pat.anti_pattern ELSE pat.check_pattern END) check_res
              , pat.msg_type
           FROM all_arguments arg
          INNER JOIN qc_patterns pat_pkg
             ON pat_pkg.object_type = 'PACKAGE'
*/
          ORDER BY 1, 2, 4, 3
      ;
      TYPE t_object_type_count_hash_type IS TABLE OF INTEGER INDEX BY qc_run_msgs.object_type%TYPE;
      t_count t_object_type_count_hash_type;
      l_object_type qc_run_msgs.object_type%TYPE;
      l_fix_op qc_run_msgs.fix_op%TYPE;
      l_fix_desc qc_run_msgs.msg_text%TYPE;
      l_unexpected_res INTEGER;
      l_qc_code qc_checks.qc_code%TYPE;
      l_msg VARCHAR2(100);
      PROCEDURE increment_count (
         p_object_type IN VARCHAR2
      )
      IS
      BEGIN
         IF t_count.EXISTS(p_object_type) THEN
            t_count(p_object_type) := t_count(p_object_type) + 1;
         ELSE
            t_count(p_object_type) := 1;
         END IF;
      END increment_count;
   BEGIN
      IF p_anti_pattern = 'Y' THEN
         l_unexpected_res := 1;
         l_qc_code := 'QC020';
         l_msg := ':1 :2 matches anti-pattern :3';
      ELSE
         l_unexpected_res := 0;
         l_qc_code := 'QC008';
         l_msg := ':1 :2 does not match standard pattern :3';
      END IF;
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         increment_count(r_obj.object_type);
         IF r_obj.check_res = l_unexpected_res /*no match*/ THEN
            IF NVL(p_anti_pattern,'N') = 'N' THEN
               -- TBD: check that fix name matches the check pattern; if not, don't store it?
               l_fix_name := qc_utility_krn.gen_fix_name(r_obj.fix_type, r_obj.owner, r_obj.fix_name, r_obj.fix_pattern);
               IF r_obj.object_type = 'SEQUENCE' THEN
                  l_fix_op := 'DROP';
                  l_fix_desc := ', fix: drop';
               ELSE
                  l_fix_op := 'RENAME';
                  IF l_fix_name IS NOT NULL THEN
                     l_fix_desc := ', fix: rename to '||l_fix_name;
                  ELSE
                     l_fix_desc := NULL;
                  END IF;
               END IF;
            END IF;
            log_run_msg(l_qc_code,r_obj.object_name
               ,l_fix_name, l_fix_op
               ,r_obj.object_type,NULL,NULL,r_obj.sort_order,NULL,r_obj.msg_type
               ,l_msg
                ||CASE WHEN r_obj.check_pattern != r_obj.check_pattern2 THEN ' => '||r_obj.check_pattern2 END
                ||l_fix_desc
               ,r_obj.object_desc, r_obj.object_name, r_obj.check_pattern
            );
         END IF;
      END LOOP obj_loop;
      l_object_type := t_count.FIRST;
      <<obj_type_loop>>
      WHILE l_object_type IS NOT NULL LOOP
         log_run_stat(l_qc_code,l_object_type,t_count(l_object_type));
         l_object_type := t_count.NEXT(l_object_type);
      END LOOP obj_type_loop;
   END qc008;
   -- QC009: Potentially missing foreign keys W
   -- This check performed ONLY for tables having an alias or an entity defined
   -- It assumes that check pattern cannot reference alias and entity at the same time
   PROCEDURE qc009 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_fix_name qc_run_msgs.fix_name%TYPE;
      CURSOR c_obj IS
         SELECT x.pk_table_name||'.'||x.pk_column_name pk_col
              , x.fk_table_name||'.'||x.fk_column_name fk_col
              , pat_fk.object_type fix_type,NULL fix_name,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                   pat_fk.fix_pattern,'{parent alias}',dict1.dict_value)
                                     ,'{table alias}',dict2.dict_value)
                                     ,'{child alias}',dict2.dict_value)
                                     ,'{parent entity}',dict1.dict_value)
                                     ,'{table entity}',dict2.dict_value)
                                     ,'{child entity}',dict2.dict_value) fix_pattern
              , x.pk_name
              , x.pk_owner, x.fk_owner
           FROM (
               SELECT con.table_name pk_table_name, ccol.column_name pk_column_name, con.constraint_name pk_name
                    , tcol.table_name fk_table_name, tcol.column_name fk_column_name
                    , con.owner pk_owner, tcol.owner fk_owner
                 FROM dual
                INNER JOIN all_constraints  con
                   ON con.constraint_type = 'P'
                INNER JOIN qc_patterns pat_fk
                   ON pat_fk.object_type = 'CONSTRAINT: FOREIGN KEY'
                  AND pat_fk.app_alias IN ('ALL', qc_utility_var.g_app_alias)
                LEFT OUTER JOIN qc_patterns pat_qc
                   ON pat_qc.object_type = 'QC009'
                  AND pat_qc.app_alias IN ('ALL', qc_utility_var.g_app_alias)
                INNER JOIN qc_dictionary_entries dict
                   ON dict.dict_name = CASE WHEN NVL(INSTR(pat_fk.check_pattern,' alias}'),0)>0 THEN 'TABLE ALIAS'
                                            WHEN NVL(INSTR(pat_fk.check_pattern,' entity}'),0)>0 THEN 'TABLE ENTITY'
                                            ELSE NULL
                                       END
                  AND dict.app_alias = qc_utility_var.g_app_alias
                  AND dict.dict_key = con.table_name
                  AND dict.dict_value IS NOT NULL -- checked elsewhere
                INNER JOIN all_tables tab
                   ON tab.owner = con.owner
                  AND tab.table_name = con.table_name -- to exclude views
                  AND SUBSTR(tab.table_name,1,4) != 'BIN$'
--                INNER JOIN qc_dictionary_entries dict_own
--                   ON dict_own.dict_name = 'OBJECT OWNER'
--                  AND dict_own.dict_key = 'TABLE'
                INNER JOIN all_cons_columns ccol
                   ON ccol.owner = con.owner
                  AND ccol.constraint_name = con.constraint_name
                  AND NVL(INSTR(ccol.column_name,dict.dict_value),0) > 0 -- column name contains table alias or table entity
                  AND ccol.position = 1
                 LEFT OUTER JOIN all_cons_columns ccol2
                   ON ccol2.owner = con.owner
                  AND ccol2.constraint_name = con.constraint_name
                  AND ccol2.position = 2
                INNER JOIN all_tab_columns tcol
                   ON tcol.owner = ccol.owner
                  AND tcol.column_name = ccol.column_name
                  AND tcol.table_name != con.table_name
                INNER JOIN all_tables rtab
                   ON rtab.owner = tcol.owner
                  AND rtab.table_name = tcol.table_name -- to exclude views
                  AND SUBSTR(rtab.table_name,1,4) != 'BIN$'
                 LEFT OUTER JOIN all_constraints rcon
                   ON rcon.owner = tcol.owner
                  AND rcon.table_name = tcol.table_name
                  AND rcon.constraint_type = 'R'
                 LEFT OUTER JOIN all_cons_columns rccol
                   ON rccol.owner = rcon.owner
                  AND rccol.constraint_name = rcon.constraint_name
                  AND rccol.column_name = tcol.column_name
                  AND rccol.position = 1
                WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
                  AND ccol2.column_name IS NULL -- PK/UK has only 1 column
                  AND rcon.constraint_name IS NULL
                  AND rccol.column_name IS NULL
                  AND (pat_qc.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE',tab.owner,tab.table_name,pat_qc.include_pattern)=1)
                  AND (pat_qc.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE',tab.owner,tab.table_name,pat_qc.exclude_pattern)=0)
                  AND (pat_qc.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE',rtab.owner,rtab.table_name,pat_qc.include_pattern)=1)
                  AND (pat_qc.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE',rtab.owner,rtab.table_name,pat_qc.exclude_pattern)=0)
                ) x
          INNER JOIN qc_patterns pat_fk
             ON pat_fk.object_type = 'CONSTRAINT: FOREIGN KEY'
            AND pat_fk.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN qc_dictionary_entries dict1
             ON dict1.dict_name = CASE WHEN NVL(INSTR(pat_fk.check_pattern,'{parent alias}'),0)>0 THEN 'TABLE ALIAS'
                                       WHEN NVL(INSTR(pat_fk.check_pattern,'{parent entity}'),0)>0 THEN 'TABLE ENTITY'
                                       ELSE NULL
                                  END
            AND dict1.app_alias = qc_utility_var.g_app_alias
            AND dict1.dict_key = pk_table_name
            AND dict1.dict_value IS NOT NULL
          INNER JOIN qc_patterns pat1
             ON pat1.object_type = 'TABLE'
            AND pat1.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (pat1.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat1.object_type,pk_owner,pk_table_name,pat1.include_pattern)=1)
            AND (pat1.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat1.object_type,pk_owner,pk_table_name,pat1.exclude_pattern)=0)
           LEFT OUTER JOIN qc_dictionary_entries dict2
             ON dict2.dict_name = CASE WHEN NVL(INSTR(pat_fk.check_pattern,'{table alias}'),0)>0 THEN 'TABLE ALIAS'
                                       WHEN NVL(INSTR(pat_fk.check_pattern,'{child alias}'),0)>0 THEN 'TABLE ALIAS'
                                       WHEN NVL(INSTR(pat_fk.check_pattern,'{table entity}'),0)>0 THEN 'TABLE ENTITY'
                                       WHEN NVL(INSTR(pat_fk.check_pattern,'{child entity}'),0)>0 THEN 'TABLE ENTITY'
                                       ELSE NULL
                                  END
            AND dict2.app_alias = qc_utility_var.g_app_alias
            AND dict2.dict_key = fk_table_name
            AND dict2.dict_value IS NOT NULL
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,fk_owner,fk_table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,fk_owner,fk_table_name,pat2.exclude_pattern)=0)
      ;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_fix_name := qc_utility_krn.gen_fix_name(r_obj.fix_type, r_obj.fk_owner, r_obj.fk_col, r_obj.fix_pattern);
         log_run_msg('QC009',r_obj.fk_col||'#'||r_obj.pk_name,l_fix_name,'CREATE','TABLE COLUMN',r_obj.fix_type,NULL,NULL,NULL,p_msg_type
            ,'Foreign key potentially missing between :1 and :2'
             ||CASE WHEN l_fix_name IS NOT NULL THEN ', fix: create '||l_fix_name END
            , r_obj.fk_col, r_obj.pk_col
         );
      END LOOP obj_loop;
   END qc009;
   -- QC010: Foreign key columns must be indexed E
   -- (unless it is redundant e.g. part of a PK)
   -- (matching index = an index having the same columns in the same order)
   PROCEDURE qc010 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_fix_name qc_run_msgs.fix_name%TYPE;
      CURSOR c_obj IS
         SELECT 'CONSTRAINT: FOREIGN KEY' object_type, tab.owner, tab.table_name||'.'||fk.constraint_name object_name, 'Foreign key' object_desc
              , pat.object_type fix_type,tab.table_name||'.'||fk.constraint_name fix_name
--              , REPLACE(pat2.fix_pattern,'{ind cons}',fk.constraint_name) fix_pattern
              , qc_utility_krn.replace_vars('CONSTRAINT',fk.owner,fk.table_name||'.'||fk.constraint_name,pat2.fix_pattern) fix_pattern
              , pat2.object_type fix_type2
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN qc_patterns pat2
             ON pat2.object_type = 'INDEX: FOREIGN KEY'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN all_constraints fk
             ON fk.owner = tab.owner
            AND fk.table_name = tab.table_name
            AND fk.constraint_type = 'R'
            AND fk.constraint_name NOT IN (
                   SELECT fk.constraint_name
                     FROM all_constraints fk
                    INNER JOIN all_cons_columns fk_col
                       ON fk_col.owner = fk.owner
                      AND fk_col.constraint_name = fk.constraint_name
                    INNER JOIN all_ind_columns ind_col
                       ON ind_col.index_owner = fk.owner
                      AND ind_col.table_name = fk.table_name
                      AND ind_col.column_name = fk_col.column_name
                      AND ind_col.column_position = fk_col.position
--                    INNER JOIN qc_dictionary_entries dict_own
--                       ON dict_own.dict_name = 'OBJECT OWNER'
--                      AND dict_own.dict_key = 'TABLE'
                    WHERE fk.owner = NVL(qc_utility_var.g_object_owner,USER)
                      AND fk.constraint_type = 'R'
                )
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      CURSOR c_cnt IS
         SELECT COUNT(*)
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN all_constraints fk
             ON fk.owner = tab.owner
            AND fk.table_name = tab.table_name
            AND fk.constraint_type = 'R'
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
       ;
       l_count INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_fix_name := qc_utility_krn.gen_fix_name(r_obj.fix_type, r_obj.owner, r_obj.fix_name,r_obj.fix_pattern);
         log_run_msg('QC010',r_obj.object_name,l_fix_name,'CREATE',r_obj.object_type,r_obj.fix_type2,NULL,NULL,NULL,p_msg_type
            ,':1 :2 has no matching index'
             ||CASE WHEN l_fix_name IS NOT NULL THEN ', fix: create '||l_fix_name END
            , r_obj.object_desc, r_obj.object_name
         );
      END LOOP obj_loop;
      OPEN c_cnt;
      FETCH c_cnt INTO l_count;
      CLOSE c_cnt;
      log_run_stat('QC010','CONSTRAINT: FOREIGN KEY',l_count);
   END qc010;
   -- QC011: Disabled database objects W
   PROCEDURE qc011 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT 'CONSTRAINT' object_type, con.table_name||'.'||con.constraint_name object_name, 'Constraint' object_desc, con.status
           FROM all_constraints con
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND con.constraint_type IN ('P','U','R','C')
            AND SUBSTR(con.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,con.owner,con.table_name,pat.exclude_pattern)=0)
          UNION
         SELECT 'TRIGGER' object_type, trg.table_name||'.'||trg.trigger_name object_name, 'Trigger' object_desc, trg.status
           FROM all_triggers trg
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE trg.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(trg.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,trg.owner,trg.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,trg.owner,trg.table_name,pat.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      TYPE t_object_type_count_hash_type IS TABLE OF INTEGER INDEX BY qc_run_msgs.object_type%TYPE;
      t_count t_object_type_count_hash_type;
      l_object_type qc_run_msgs.object_type%TYPE;
      PROCEDURE increment_count (
         p_object_type IN VARCHAR2
      )
      IS
      BEGIN
         IF t_count.EXISTS(p_object_type) THEN
            t_count(p_object_type) := t_count(p_object_type) + 1;
         ELSE
            t_count(p_object_type) := 0;
         END IF;
      END increment_count;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         increment_count(r_obj.object_type);
         IF r_obj.status = 'DISABLED' THEN
            log_run_msg('QC011',r_obj.object_name,NULL,'ENABLE',r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
               ,':1 :2 is disabled', r_obj.object_desc, r_obj.object_name
            );
         END IF;
      END LOOP obj_loop;
      l_object_type := t_count.FIRST;
      <<obj_type_loop>>
      WHILE l_object_type IS NOT NULL LOOP
         log_run_stat('QC011',l_object_type,t_count(l_object_type));
         l_object_type := t_count.NEXT(l_object_type);
      END LOOP obj_type_loop;
   END qc011;
   -- QC012: Invalid database objects W
   PROCEDURE qc012 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj
          IS
      SELECT obj.object_type
           , obj.object_name
           , obj.status
           , INITCAP(obj.object_type) object_desc
        FROM all_objects obj
--       INNER JOIN qc_dictionary_entries dict_own
--          ON dict_own.dict_name = 'OBJECT OWNER'
--         AND dict_own.dict_key = obj.object_type
       INNER JOIN qc_patterns pat
          ON pat.object_type = obj.object_type
         AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
         AND pat.check_pattern IS NOT NULL
         AND pat.object_type NOT IN ('TRIGGER','CONSTRAINT','INDEX') -- handled separately below
       WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
         AND obj.status != 'VALID'
         AND obj.object_type NOT IN ('MATERIALIZED VIEW')
         AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
         AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
       UNION
      SELECT 'INDEX' object_type
           , ind.index_name object_name
           , ind.status
           , 'Index' object_desc
        FROM all_indexes ind
--       INNER JOIN qc_dictionary_entries dict_own
--          ON dict_own.dict_name = 'OBJECT OWNER'
--         AND dict_own.dict_key = 'TABLE'
       INNER JOIN qc_patterns pat
          ON pat.object_type = 'TABLE'
         AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
         AND pat.check_pattern IS NOT NULL
       WHERE ind.owner = NVL(qc_utility_var.g_object_owner,USER)
         AND SUBSTR(ind.table_name,1,4) != 'BIN$'
         AND ind.status = 'UNUSABLE'
         AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.index_name,pat.include_pattern)=1)
         AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.index_name,pat.exclude_pattern)=0)
       UNION
      SELECT 'MATERIALIZED VIEW' object_type
           , mvw.mview_name object_name
           , mvw.compile_state status
           , 'Materialized View' object_desc
        FROM all_mviews mvw
--       INNER JOIN qc_dictionary_entries dict_own
--          ON dict_own.dict_name = 'OBJECT OWNER'
--         AND dict_own.dict_key LIKE 'MATERIALIZED VIEW%'
       INNER JOIN qc_patterns pat
          ON pat.object_type = 'MATERIALIZED VIEW'
         AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
         AND pat.check_pattern IS NOT NULL
       WHERE mvw.owner = NVL(qc_utility_var.g_object_owner,USER)
         AND mvw.compile_state NOT IN ('VALID','NEEDS_COMPILE')
         AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.include_pattern)=1)
         AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,mvw.owner,mvw.mview_name,pat.exclude_pattern)=0)
       ORDER BY 1
           ;
       l_count INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_count := l_count + 1;
         log_run_msg('QC012',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
               ,':1 :2 is invalid'
               , r_obj.object_desc, r_obj.object_name
            );
      END LOOP obj_loop;
      log_run_stat('QC012', 'Object', l_count);
   END qc012;
   -- QC013: Tables and indexes must be stored in their respective tablespace E
   PROCEDURE qc013 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj IS
         SELECT pat.object_type, tab.table_name object_name
             , 'Table '||tab.table_name||' is stored in tablespace '||tab.tablespace_name||' instead of '||UPPER(dict.dict_value) object_desc
             , CASE WHEN tab.tablespace_name != UPPER(dict.dict_value) THEN 1 ELSE 0 END result
           FROM all_tables tab
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dict
             ON dict.dict_name = 'PARAMETER'
            AND dict.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND dict.dict_key = 'TAB TS'
            AND dict.dict_value IS NOT NULL
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
          UNION
         SELECT pat.object_type, ind.table_name||'.'||ind.index_name object_name
             , 'Index '||ind.table_name||'.'||ind.index_name||' is stored in tablespace '||ind.tablespace_name||' instead of '||UPPER(dict.dict_value) object_desc
             , CASE WHEN ind.tablespace_name != UPPER(dict.dict_value) THEN 1 ELSE 0 END result
           FROM all_indexes ind
          INNER JOIN qc_patterns pat
             ON pat.object_type = qc_utility_krn.get_ind_type(ind.owner,ind.table_name, ind.index_name)
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type = 'TABLE'
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dict
             ON dict.dict_name = 'PARAMETER'
            AND dict.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND dict.dict_key = 'IDX TS'
            AND dict.dict_value IS NOT NULL
          WHERE ind.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(ind.table_name,1,4) != 'BIN$'
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.table_name||'.'||ind.index_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat2.object_type,ind.owner,ind.table_name,pat2.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
      TYPE t_object_type_count_hash_type IS TABLE OF INTEGER INDEX BY qc_run_msgs.object_type%TYPE;
      t_count t_object_type_count_hash_type;
      l_object_type qc_run_msgs.object_type%TYPE;
      PROCEDURE increment_count (
         p_object_type IN VARCHAR2
      )
      IS
      BEGIN
         IF t_count.EXISTS(p_object_type) THEN
            t_count(p_object_type) := t_count(p_object_type) + 1;
         ELSE
            t_count(p_object_type) := 1;
         END IF;
      END increment_count;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         increment_count(r_obj.object_type);
         IF r_obj.result = 1 THEN
            log_run_msg('QC013',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type, r_obj.object_desc
            );
         END IF;
      END LOOP obj_loop;
      l_object_type := t_count.FIRST;
      <<obj_type_loop>>
      WHILE l_object_type IS NOT NULL LOOP
         log_run_stat('QC013',l_object_type,t_count(l_object_type));
         l_object_type := t_count.NEXT(l_object_type);
      END LOOP obj_type_loop;
   END qc013;
   -- QC014: Package body/spec should not contain global variables W
   -- (with few exceptions)
   PROCEDURE qc014 (
      p_msg_type IN VARCHAR2
   )
   IS
      CURSOR c_obj (
         p_object_type IN all_objects.object_type%TYPE
      )
      IS
         SELECT obj.object_type, LOWER(obj.object_type) object_desc, obj.object_name
           FROM all_objects obj
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
            AND pat.object_type IN ('PACKAGE','PACKAGE BODY')
          INNER JOIN qc_patterns pat2
             ON pat2.object_type IN ('QC014')
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND obj.object_type = p_object_type
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat2.exclude_pattern)=0)
          ORDER BY 1, 2
      ;
       l_count INTEGER := 0;
       l_object_type all_objects.object_type%TYPE;
   BEGIN
      <<obj_type_loop>>
      FOR i IN 1..2 LOOP
         l_object_type := 'PACKAGE' || CASE WHEN i=2 THEN ' BODY' END;
         l_count := 0;
         <<obj_loop>>
         FOR r_obj IN c_obj(l_object_type) LOOP
            l_count := l_count + 1;
            IF qc_utility_ora_04068.check_global_variables(r_obj.object_type,r_obj.object_name) < 0 THEN
               log_run_msg('QC014',r_obj.object_name,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
                  ,':1 :2 contains global variable(s)/cursor(s)'
                  , r_obj.object_desc, r_obj.object_name
               );
            END IF;
         END LOOP obj_loop;
         log_run_stat('QC014', l_object_type, l_count);
      END LOOP obj_type_loop;
   END qc014;
   -- QC015: Potentially redundant indexes W
   -- (when one index is a prefix of another one)
   PROCEDURE qc015 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code qc_checks.qc_code%TYPE := 'QC015';
      CURSOR c_obj IS
         WITH ind AS (
            SELECT ind.owner, ind.index_name, ind.table_name, ind.index_type, ind.uniqueness
                 , qc_utility_krn.get_ind_columns(ind.owner,ind.table_name,ind.index_name) ind_columns
              FROM all_indexes ind
             INNER JOIN qc_patterns pat
                ON pat.object_type = 'TABLE'
               AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
             WHERE ind.owner = NVL(qc_utility_var.g_object_owner,USER)
               AND SUBSTR(ind.table_name,1,4) != 'BIN$'
               AND ind.status = 'VALID' -- enabled
               AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.table_name,pat.include_pattern)=1)
               AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind.owner,ind.table_name,pat.exclude_pattern)=0)
         )
         SELECT DISTINCT 'INDEX' object_type, 'Index' object_desc, ind1.table_name||'.'||ind1.index_name object_name
              , ind1.table_name
              , ind1.index_name index_name1, ind1.uniqueness uniqueness1, ind1.ind_columns ind_columns1
              , ind2.index_name index_name2, ind2.uniqueness uniqueness2, ind2.ind_columns ind_columns2
           FROM ind ind1
          INNER JOIN qc_patterns pat
             ON pat.object_type = qc_utility_krn.get_ind_type(ind1.owner, ind1.table_name, ind1.index_name)
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type IN ('QC015')
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN ind ind2
             ON ind2.table_name = ind1.table_name
            AND ind2.index_name != ind1.index_name
            AND ind2.index_type = 'NORMAL'
            AND SUBSTR(ind2.ind_columns||',',1,NVL(LENGTH(ind1.ind_columns),0)+1) = ind1.ind_columns||','
          WHERE ind1.index_type = 'NORMAL'
            AND NOT (ind1.uniqueness = 'UNIQUE' AND ind2.uniqueness = 'NONUNIQUE')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind1.owner,ind1.table_name||'.'||ind1.index_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind1.owner,ind1.table_name||'.'||ind1.index_name,pat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind1.owner,ind1.table_name||'.'||ind1.index_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,ind1.owner,ind1.table_name||'.'||ind1.index_name,pat2.exclude_pattern)=0)
          ORDER BY ind1.table_name, ind1.index_name, ind2.index_name
         ;
      r_last_obj c_obj%ROWTYPE;
      l_count INTEGER := 0;
      l_idx_cnt INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         IF l_idx_cnt > 0 AND r_last_obj.object_name != r_obj.object_name THEN
            l_idx_cnt := 0;
         END IF;
         l_idx_cnt := l_idx_cnt + 1;
         -- An given index can be redundant compared to several other indexes
         -- Only the first occurence must lead to a fix
         -- Fix: disable instead of drop to avoid generating missing index on FK anomaly
         IF l_idx_cnt = 1 THEN
            -- Fix is performed for 1st occurence only
            log_run_msg(l_qc_code,r_obj.object_name||'#'||r_obj.index_name2,r_obj.object_name,'DISABLE',r_obj.object_type,r_obj.object_type,NULL,NULL,NULL,p_msg_type
               ,':1 :2(:3) is redundant with :4(:5), fix: disable', r_obj.object_desc
               , r_obj.object_name, r_obj.ind_columns1
               , r_obj.index_name2, r_obj.ind_columns2
            );
         ELSE
            -- No fix as of 2nd occurence of index
            log_run_msg(l_qc_code,r_obj.object_name||'#'||r_obj.index_name2,NULL,NULL,r_obj.object_type,NULL,NULL,NULL,NULL,p_msg_type
               ,':1 :2(:3) is redundant with :4(:5)', r_obj.object_desc
               , r_obj.object_name, r_obj.ind_columns1
               , r_obj.index_name2, r_obj.ind_columns2
            );
         END IF;
         r_last_obj := r_obj;
         l_count := l_count + 1;
      END LOOP obj_loop;
      log_run_stat(l_qc_code, 'INDEX', object_count_from_stat('QC000','INDEX'));
   END qc015;
   -- QC016: Missing audit columns E
   PROCEDURE qc016 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code VARCHAR2(5 CHAR) := 'QC016';
      l_fix_op VARCHAR2(6 CHAR) := 'CREATE';
      l_count INTEGER := 0;
      CURSOR c_obj IS
         SELECT 'TABLE COLUMN' object_type, tab.owner, 'Column' object_desc
              , tab.table_name||'.'||qc_utility_krn.replace_vars('TABLE', tcol.owner, tab.table_name, dic1.dict_value) object_name
              , qc_utility_krn.replace_vars('TABLE', tcol.owner, tab.table_name, REPLACE(dompat.fix_pattern,'NOT NULL','NULL')) fix_pattern -- cannot create mandatory column if table is not empty!
              , qc_utility_krn.replace_vars('TABLE', tcol.owner, tab.table_name, dic1.dict_value) column_name
              , dic1.dict_key domain_name
              , tab.table_name
           FROM all_tables tab
          INNER JOIN qc_patterns tabpat
             ON tabpat.object_type = 'TABLE'
            AND tabpat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type IN ('QC016')
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dic1
             ON dic1.dict_name = 'AUDIT COLUMN'
            AND dic1.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns dompat
             ON dompat.object_type = 'DOMAIN: '||dic1.dict_key
            AND dompat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
           LEFT OUTER JOIN all_tab_columns tcol
             ON tcol.owner = tab.owner
            AND tcol.table_name = tab.table_name
            AND tcol.column_name = qc_utility_krn.replace_vars('TABLE', tcol.owner, tcol.table_name, dic1.dict_value)
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND tcol.column_name IS NULL
            AND (tabpat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.include_pattern)=1)
            AND (tabpat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,pat2.exclude_pattern)=0)
          ORDER BY 4
      ;
      CURSOR c_cnt IS
         SELECT COUNT(tab.table_name) cnt
           FROM all_tables tab
          INNER JOIN qc_patterns tabpat
             ON tabpat.object_type = 'TABLE'
            AND tabpat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns pat2
             ON pat2.object_type IN ('QC016')
            AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_dictionary_entries dic1
             ON dic1.dict_name = 'AUDIT COLUMN'
            AND dic1.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN qc_patterns dompat
             ON dompat.object_type = 'DOMAIN: '||dic1.dict_key
            AND dompat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
            AND (tabpat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.include_pattern)=1)
            AND (tabpat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.exclude_pattern)=0)
            AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,pat2.include_pattern)=1)
            AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,pat2.exclude_pattern)=0)
      ;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg(l_qc_code,r_obj.object_name||'#'||r_obj.domain_name,r_obj.object_name,l_fix_op,r_obj.object_type,r_obj.object_type
            ,CASE WHEN r_obj.fix_pattern IS NOT NULL THEN gen_fix_ddl(l_fix_op, r_obj.object_type, r_obj.owner, r_obj.object_name, r_obj.object_type, r_obj.object_name, r_obj.table_name, r_obj.fix_pattern) END
            ,NULL,NULL,p_msg_type, 'Table :1: audit column :2 is missing' || CASE WHEN r_obj.fix_pattern IS NOT NULL THEN ', fix: create column '||r_obj.column_name||' of type '||r_obj.fix_pattern END
            ,r_obj.table_name, r_obj.column_name
         );
         l_count := l_count + 1;
      END LOOP obj_loop;
      OPEN c_cnt;
      FETCH c_cnt INTO l_count;
      CLOSE c_cnt;
      log_run_stat(l_qc_code, 'TABLE COLUMN', l_count); -- expected number of audit columns (= # tables x # audit cols per table)
   END qc016;
   -- QC017: Incorrect data type/length/optionality for domain-based columns E
   PROCEDURE qc017 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code VARCHAR2(5 CHAR) := 'QC017';
      l_fix_op VARCHAR2(6 CHAR) := 'MODIFY';
      l_object_type VARCHAR2(12 CHAR) := 'TABLE COLUMN';
      l_count INTEGER := 0;
      CURSOR c_obj IS
         SELECT * FROM (
            SELECT tcol.table_name||'.'||tcol.column_name object_name
                 , tcol.table_name, tab.owner
                 , dompat.check_pattern, dompat.object_type domain_name
                 , CASE WHEN tcol.data_type = 'NUMBER' AND tcol.data_precision IS NULL AND tcol.data_scale = 0 THEN 'INTEGER' ELSE tcol.data_type END
                || CASE WHEN NVL(INSTR(dompat.check_pattern,'\('),0)>0 THEN
                        CASE WHEN tcol.data_precision IS NOT NULL THEN --NUMBER()?
                             CASE WHEN NVL(tcol.data_scale,0) > 0
                                  THEN '('||tcol.data_precision||','||tcol.data_scale||')'
                                  ELSE '('||tcol.data_precision||')'
                              END
                             WHEN tcol.char_used IS NOT NULL /*CHAR,VARCHAR2*/
                             THEN '('||tcol.char_length||CASE WHEN tcol.char_used='C' THEN ' CHAR' END||')'
                        END
                   END
                || CASE WHEN NVL(INSTR(dompat.check_pattern,'NULL'),0)>0 THEN
                        CASE WHEN tcol.nullable = 'N' THEN ' NOT'
                         END || ' NULL'
                   END
                   object_datatype
                 , dompat.fix_pattern
              FROM all_tables tab
             INNER JOIN all_tab_columns tcol
                ON tcol.owner = tab.owner
               AND tcol.table_name = tab.table_name
             INNER JOIN qc_patterns tabpat
                ON tabpat.object_type = 'TABLE'
               AND tabpat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
             INNER JOIN qc_patterns dompat
                ON dompat.object_type LIKE 'DOMAIN:%'
               AND dompat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
--             INNER JOIN qc_dictionary_entries dict_own
--                ON dict_own.dict_name = 'OBJECT OWNER'
--               AND dict_own.dict_key = 'TABLE'
             WHERE tab.owner = NVL(qc_utility_var.g_object_owner,USER)
               AND SUBSTR(tab.table_name,1,4) != 'BIN$'
               AND (tabpat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.include_pattern)=1)
               AND (tabpat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.exclude_pattern)=0)
               AND (dompat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE COLUMN',tcol.owner,tcol.table_name||'.'||tcol.column_name,dompat.include_pattern)=1)
               AND (dompat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like('TABLE COLUMN',tcol.owner,tcol.table_name||'.'||tcol.column_name,dompat.exclude_pattern)=0)
         )
         WHERE NOT REGEXP_LIKE(object_datatype,check_pattern)
         ORDER BY object_name
      ;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg(l_qc_code,r_obj.object_name,r_obj.object_name,l_fix_op,l_object_type,l_object_type
            ,CASE WHEN r_obj.fix_pattern IS NOT NULL THEN gen_fix_ddl(l_fix_op, l_object_type, r_obj.owner, r_obj.object_name, l_object_type, r_obj.object_name, r_obj.table_name, r_obj.fix_pattern) END
            ,NULL,NULL,p_msg_type, 'Format of column :1 (:2) is not aligned with :3 (:4)'|| CASE WHEN r_obj.fix_pattern IS NOT NULL THEN ', fix: modify column to '||r_obj.fix_pattern END
            , r_obj.object_name, r_obj.object_datatype, REPLACE(r_obj.domain_name,'DOMAIN: ')||' domain', r_obj.check_pattern
         );
         l_count := l_count + 1;
      END LOOP obj_loop;
      log_run_stat(l_qc_code, l_object_type, l_count);
   END qc017;
   -- QC018: Foreign key and referenced pk/uk columns must have the same format E
   PROCEDURE qc018 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code VARCHAR2(5 CHAR) := 'QC018';
      l_fix_op VARCHAR2(6 CHAR) := 'MODIFY';
      l_object_type VARCHAR2(12 CHAR) := 'TABLE COLUMN';
      l_count INTEGER := 0;
      CURSOR c_obj IS
         SELECT con.table_name||'.'||con.constraint_name||'.'||ccol.column_name object_name
              , con.table_name, tcol.owner
              , tcol.data_type
             || CASE WHEN tcol.data_precision IS NOT NULL THEN --NUMBER()?
                     CASE WHEN tcol.data_scale IS NOT NULL
                          THEN '('||tcol.data_precision||','||tcol.data_scale||')'
                          ELSE '('||tcol.data_precision||')'
                      END
                     WHEN tcol.data_type LIKE '%CHAR%' THEN '('||tcol.data_length||')'
                END object_data_type
              , rcon.table_name||'.'||rcon.constraint_name||'.'||rccol.column_name r_object_name
              , rtcol.data_type
             || CASE WHEN rtcol.data_precision IS NOT NULL THEN --NUMBER()?
                     CASE WHEN rtcol.data_scale IS NOT NULL
                          THEN '('||rtcol.data_precision||','||rtcol.data_scale||')'
                          ELSE '('||rtcol.data_precision||')'
                      END
                     WHEN rtcol.data_type LIKE '%CHAR%' THEN '('||rtcol.data_length||')'
                END r_object_data_type
           FROM dual
          INNER JOIN all_constraints con
             ON con.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND con.constraint_type = 'R'
          INNER JOIN all_tables tab
             ON tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND tab.table_name = con.table_name -- to exclude views
            AND SUBSTR(tab.table_name,1,4) != 'BIN$'
          INNER JOIN qc_patterns pat
             ON pat.object_type = 'TABLE'
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN all_cons_columns ccol
             ON ccol.owner = con.owner
            AND ccol.constraint_name = con.constraint_name
          INNER JOIN all_tab_columns tcol
             ON tcol.owner = con.owner
            AND tcol.table_name = con.table_name
            AND tcol.column_name = ccol.column_name
          INNER JOIN all_constraints rcon
             ON rcon.owner = con.r_owner
            AND rcon.constraint_name = con.r_constraint_name
          INNER JOIN all_tables rtab
             ON rtab.owner = rcon.owner
            AND rtab.table_name = rcon.table_name -- to exclude views
            AND SUBSTR(rtab.table_name,1,4) != 'BIN$'
          INNER JOIN all_cons_columns rccol
             ON rccol.owner = rcon.owner
            AND rccol.constraint_name = rcon.constraint_name
            AND rccol.position = ccol.position
          INNER JOIN all_tab_columns rtcol
             ON rtcol.owner = rcon.owner
            AND rtcol.table_name = rcon.table_name
            AND rtcol.column_name = rccol.column_name
          WHERE 1=1
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,tab.owner,tab.table_name,pat.exclude_pattern)=0)
            AND (tcol.data_type != rtcol.data_type
                OR tcol.data_length != rtcol.data_length
                OR NVL(tcol.data_scale,-1) != NVL(rtcol.data_scale,-1)
                OR NVL(tcol.data_precision,-1) != NVL(rtcol.data_precision,-1)
                )
          ORDER BY con.table_name||'.'||con.constraint_name||'.'||ccol.column_name
      ;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg(l_qc_code,r_obj.object_name,r_obj.object_name,l_fix_op,l_object_type,l_object_type
            ,gen_fix_ddl(l_fix_op, l_object_type, r_obj.owner, r_obj.object_name, l_object_type, r_obj.object_name, r_obj.table_name, r_obj.r_object_data_type)
            ,NULL,NULL,p_msg_type, 'Format of column :1 (:2) is not aligned with :3 (:4), fix: modify column to :5'
            , r_obj.object_name, r_obj.object_data_type, r_obj.r_object_name, r_obj.r_object_data_type, r_obj.r_object_data_type
         );
         l_count := l_count + 1;
      END LOOP obj_loop;
      log_run_stat(l_qc_code, l_object_type, l_count);
   END qc018;
   -- QC019: PL/SQL identifiers must match standard naming patterns E
   PROCEDURE qc019 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_fix_name qc_run_msgs.fix_name%TYPE;
      CURSOR c_obj IS
         WITH
            obj AS (
                SELECT /*+ materialize */
                       obj.owner, obj.object_type, obj.object_name
                  FROM all_objects obj
                 INNER JOIN qc_patterns pat
                    ON pat.object_type = obj.object_type
                   AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
--                   AND pat.app_alias IN ('ALL', 'DS')
                 INNER JOIN qc_patterns pat2
                    ON pat2.object_type IN ('QC019')
                   AND pat2.app_alias IN ('ALL', qc_utility_var.g_app_alias)
--                   AND pat2.app_alias IN ('ALL', 'DS')
                 WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
--                 WHERE obj.owner = USER
                   AND obj.object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TRIGGER','TYPE','TYPE BODY') -- To be checked!
                   AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
                   AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
                   AND (pat2.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat2.include_pattern)=1)
                   AND (pat2.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat2.exclude_pattern)=0)
                   )
--            , src AS (
--               SELECT /*+ materialize */
--                      owner,
--                      type,
--                      name,
--                      line,
--                      text
--                 FROM sys.all_source
--                WHERE (owner, type, name) IN (
--                         SELECT owner, object_type, object_name
--                           FROM obj
--                      )
--            )
--select * from obj;
            , ids AS (
               SELECT owner,
                      name,
                      type,
                      object_name,
                      object_type,
                      usage,
                      usage_id,
                      line,
                      col,
                      usage_context_id
                 FROM all_identifiers
                WHERE (owner, object_type, object_name) IN (
                         SELECT obj.owner, obj.object_type, obj.object_name
                           FROM obj
                      )
                  AND type != 'RECORD FIELD' -- no naming convention for record fields
                  AND object_type NOT IN ('TRIGGER','TYPE')
            )
            , refer AS (
               SELECT owner, object_type, object_name
                    , usage_id leaf_usage_id, name, type
                    , TO_NUMBER(SUBSTR(sys_connect_by_path(usage_id, '/'),2,INSTR(sys_connect_by_path(usage_id, '/'),'/',2)-2)) root_usage_id
                 FROM all_identifiers
                WHERE owner = user
                  AND usage = 'REFERENCE'
                  AND type NOT LIKE '%ITERATOR%'
                  AND CONNECT_BY_ISLEAF = 1
              CONNECT BY usage_context_id = PRIOR usage_id
                  AND owner = PRIOR owner
                  AND object_type = PRIOR object_type
                  AND object_name = PRIOR object_name
                  AND usage = 'REFERENCE'
                  AND type NOT LIKE '%ITERATOR%'
                START WITH 1=1
                  AND usage = 'DECLARATION'
                  AND type NOT LIKE '%ITERATOR%'
                  AND (owner, object_type, object_name) IN (
                     SELECT owner, object_type, object_name
                       FROM obj
                  )
            )
--select * from ids;
            , tree AS (
                SELECT ids.owner,
                       ids.object_type,
                       ids.object_name,
                       ids.line,
                       ids.col,
                       ids.name,
                       level as path_len,
                       ids.type,
                       sys_connect_by_path(ids.type, '/') AS type_path,
                       ids.usage,
                       ids.usage_id,
                       ids.usage_context_id,
                       prior ids.type AS parent_type,
                       prior ids.usage AS parent_usage,
                       prior ids.line AS parent_line,
                       prior ids.col AS parent_col,
                       prior ids.name AS parent_name
                  FROM ids
                 START WITH ids.usage_context_id = 0
               CONNECT BY  PRIOR ids.usage_id    = ids.usage_context_id
                       AND PRIOR ids.owner       = ids.owner
                       AND PRIOR ids.object_type = ids.object_type
                       AND PRIOR ids.object_name = ids.object_name
            )
--select * from tree;
            , prepared AS (
               SELECT tree.usage_id,
                      tree.owner,
                      tree.object_type,
                      tree.object_name,
                      last_value (
                         CASE
                            WHEN tree.type in ('PROCEDURE', 'FUNCTION') AND tree.path_len = 2 THEN
                               tree.name
                         END
                      ) IGNORE NULLS OVER (
                         PARTITION BY tree.owner, tree.object_name, tree.object_type
                         ORDER BY tree.line, tree.col, tree.path_len
                      ) AS procedure_name,
--                      regexp_replace(src.text, chr(10)||'+$', null) text, -- remove trailing new line character
                      tree.usage,
                      tree.type,
                      tree.name,
                      tree.line,
                      tree.col,
                      tree.type_path,
                      tree.usage_context_id parent_usage_id,
                      tree.parent_usage,
                      tree.parent_type,
                      tree.parent_name,
                      tree.parent_line,
                      tree.parent_col
                 FROM tree
--                 LEFT JOIN src
--                   ON src.owner = tree.owner
--                      AND src.type = tree.object_type
--                      AND src.name = tree.object_name
--                      AND src.line = tree.line
                WHERE tree.object_type IN ('FUNCTION', 'PROCEDURE', 'TRIGGER', 'PACKAGE', 'PACKAGE BODY', 'TYPE', 'TYPE BODY')
            )
--select * from prepared;
            , filtered AS (
               -- to determine variable type, we need to look at what they reference
               SELECT refer.type refer_type, refer.name refer_name
                    , prep.*
                 FROM prepared prep
                 LEFT OUTER JOIN refer
                   ON refer.root_usage_id = prep.usage_id
                  AND refer.owner = prep.owner
                  AND refer.object_type = prep.object_type
                  AND refer.object_name = prep.object_name
                WHERE prep.usage = 'DECLARATION'
--                  AND prep.type NOT LIKE '%ITERATOR%'
--                  AND NVL(INSTR(type_path,'RECORD/VARIABLE'),0) = 0
                  AND prep.type NOT IN ('PACKAGE','PACKAGE BODY')
              )
--select * from filtered where refer_type like '%TABLE%';
            , categorized AS (
               SELECT CASE WHEN type LIKE 'FORMAL%' THEN 'Parameter'
                           WHEN type_path NOT LIKE '/PACKAGE/PROCEDURE/%'
                            AND type_path NOT LIKE '/PACKAGE/FUNCTION/%'
                            AND type_path NOT LIKE '/PROCEDURE/PROCEDURE/%'
                            AND type_path NOT LIKE '/PROCEDURE/FUNCTION/%'
                            AND type_path NOT LIKE '/FUNCTION/PROCEDURE/%'
                            AND type_path NOT LIKE '/FUNCTION/FUNCTION/%' 
                            AND type_path NOT LIKE '/OBJECT/PROCEDURE/%'
                            AND type_path NOT LIKE '/OBJECT/FUNCTION/%' 
                           THEN 'Global'
                           ELSE 'Local'
                       END dbcc_scope
                    , CASE WHEN type = 'FORMAL IN' THEN 'In'
                           WHEN type = 'FORMAL OUT' THEN 'Out'
                           WHEN type = 'FORMAL IN OUT' THEN 'In Out'
                           WHEN type = 'CONSTANT' THEN 'Constant'
                           WHEN type = 'FUNCTION' THEN 'Function'
                           WHEN type = 'PROCEDURE' THEN 'Procedure'
                           ELSE 'Variable'
                       END dbcc_modifiability
/*
Possible values for "type":
RECORD ITERATOR,CURSOR,SUBTYPE,VARRAY,FORMAL IN,FORMAL IN OUT,RECORD,OBJECT,INDEX TABLE,TRIGGER,LABEL,
PROCEDURE,VARIABLE,FUNCTION,CONSTANT,OBJECT ATTRIBUTE,EXCEPTION,ASSOCIATIVE ARRAY,FORMAL OUT,NESTED TABLE
Possible values for "refer_type":
CURSOR,RECORD ITERATOR,INTERVAL DATATYPE,DATE DATATYPE,SUBTYPE,RECORD,TIMESTAMP DATATYPE,VARRAY,OBJECT,REFCURSOR
FORMAL IN,FORMAL IN OUT,CLOB DATATYPE,INDEX TABLE,UROWID,BOOLEAN DATATYPE,PACKAGE,LABEL,RECORD FIELD
CHARACTER DATATYPE,NUMBER DATATYPE,VARIABLE,CONSTANT,EXCEPTION,BLOB DATATYPE,BFILE DATATYPE,ASSOCIATIVE ARRAY
TABLE,COLUMN,NESTED TABLE
*/
                    , CASE WHEN (type LIKE '%TABLE%' OR type LIKE '%ARRAY%') THEN 'Table Type'
                           WHEN type = 'SUBTYPE' THEN 'Scalar Type'
                           WHEN type = 'CURSOR' THEN 'Cursor'
                           WHEN type = 'LABEL' THEN 'Label'
                           WHEN type = 'RECORD' THEN 'Record Type'
                           WHEN type = 'EXCEPTION' THEN 'Exception'
                           WHEN type = 'OBJECT' THEN 'Object Type'
                           WHEN type = 'PROCEDURE' THEN 'Void'
                           WHEN type IN ('VARIABLE','CONSTANT','ITERATOR','FUNCTION','FORMAL IN','FORMAL OUT','FORMAL IN OUT') THEN
                              CASE
                                 WHEN (refer_type LIKE '%TABLE%' OR refer_type LIKE '%ARRAY%') THEN 'Table'
                                 WHEN refer_type = 'CURSOR' THEN 'Record'
                                 WHEN refer_type = 'RECORD' THEN 'Record'
                                 WHEN refer_type = 'RECORD ITERATOR' THEN 'Record'
                                 WHEN refer_type = 'OBJECT' THEN 'Object'
                                 ELSE 'Scalar'
                              END
                           ELSE 'Tbd'
                       END dbcc_type
                    , name dbcc_name
                    , line dbcc_line
                    , col dbcc_col
               , f.*
                from filtered f
            )
--select * from categorized;
            , default_patterned AS (
               SELECT
                  CASE WHEN type IN ('PROCEDURE','FUNCTION','LABEL') THEN '' ELSE
                  '^'
                  || CASE WHEN dbcc_scope = 'Global' THEN 'g'
                          WHEN dbcc_scope = 'Local' THEN 'l?'
                          WHEN dbcc_scope = 'Parameter' THEN 'p'
                     END
                  || CASE WHEN dbcc_type LIKE '%Type' THEN NULL -- modifiability not applicable to types
                          WHEN dbcc_modifiability = 'Variable' THEN 'v?'
                          WHEN dbcc_modifiability = 'Constant' THEN 'k'
                          WHEN dbcc_modifiability = 'In' THEN 'i?'
                          WHEN dbcc_modifiability = 'Out' THEN 'o'
                          WHEN dbcc_modifiability = 'In Out' THEN 'io'
                     END
                  || CASE WHEN dbcc_type = 'Cursor' THEN 'c'
                          WHEN dbcc_type LIKE 'Record%' THEN 'r'
                          WHEN dbcc_type = 'Exception' THEN 'e'
                          WHEN dbcc_type LIKE 'Table%' THEN '[ta]'
                          WHEN dbcc_type = 'Object' THEN 'o'
                     END
                  || '_.*'
                  || CASE WHEN dbcc_type LIKE '%Type' THEN '_type'
                     END
                  || '$'
                  END default_check_pattern
                  , CASE WHEN type IN ('PROCEDURE','FUNCTION','LABEL') THEN '' ELSE
                  NULL
                  || CASE WHEN dbcc_scope = 'Global' THEN 'g'
                           WHEN dbcc_scope = 'Local' THEN NULL
                           WHEN dbcc_scope = 'Parameter' THEN 'p'
                     END
                  || CASE WHEN dbcc_modifiability = 'Variable' THEN NULL
                          WHEN dbcc_modifiability = 'Constant' THEN 'k'
                          WHEN dbcc_modifiability = 'In' THEN NULL
                          WHEN dbcc_modifiability = 'Out' THEN 'o'
                          WHEN dbcc_modifiability = 'In Out' THEN 'io'
                     END
                  || CASE WHEN dbcc_type = 'Cursor' THEN 'c'
                          WHEN dbcc_type LIKE 'Record%' THEN 'r'
                          WHEN dbcc_type = 'Exception' THEN 'e'
                          WHEN dbcc_type LIKE 'Table%' THEN 't'
                          WHEN dbcc_type = 'Object' THEN 'o'
                          WHEN dbcc_scope = 'Local' AND dbcc_modifiability = 'Variable' THEN 'l'
                     END
                  || '_{name}'
                  || CASE WHEN dbcc_type LIKE '%Type' THEN '_type'
                     END
                  END default_fix_pattern
                  , UPPER('IDENTIFIER: '
                  || CASE WHEN type IN ('PROCEDURE','FUNCTION','LABEL')
                          THEN type
                          ELSE
                               CASE WHEN dbcc_scope = 'Parameter' THEN dbcc_modifiability||' '||dbcc_type||' '||dbcc_scope
                                    WHEN dbcc_modifiability = 'Variable' THEN dbcc_scope||' '||dbcc_type
                                    ELSE dbcc_scope||' '||dbcc_modifiability||' '||dbcc_type
                                END
                      END) dbcc_object_type
                 , c.*
               FROM categorized c
               WHERE dbcc_type NOT LIKE 'TBD%'
            )
--select * from default_patterned;
            , patterned AS (
               SELECT CASE WHEN pat.object_type IS NULL THEN def.default_check_pattern ELSE pat.check_pattern END check_pattern
                    , CASE WHEN pat.object_type IS NULL THEN def.default_fix_pattern ELSE pat.fix_pattern END fix_pattern
                    , def.*
                 FROM default_patterned def
                 LEFT OUTER JOIN qc_patterns pat
                   ON pat.object_type = def.dbcc_object_type
                  AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
--                  AND pat.app_alias IN ('ALL', 'DS')
            )
--select * from patterned;
            , fixed AS (
               SELECT REPLACE(fix_pattern,'{name}',REGEXP_REPLACE(REGEXP_REPLACE(LOWER(dbcc_name)
                  ,'^([pklvgaetrcio]'||CASE WHEN dbcc_modifiability = 'In Out' THEN '{1,4}' ELSE '{1,3}' END ||'_)(.*)$','\2')
                  ,CASE WHEN p.dbcc_type LIKE '%Type' THEN '^(.*)_type$' ELSE NULL END,'\1')) fix_name
                  , p.*
               FROM patterned p
            )
--select * from fixed;
            , checked AS (
               SELECT CASE WHEN check_pattern IS NULL OR regexp_like(dbcc_name,check_pattern,'i') THEN 'OK' ELSE 'KO' END status
                  , f.*
               FROM fixed f
            )
--select * from checked;
            , final as (
               SELECT c.*
                    ,ids.signature
                    , LOWER(REPLACE(c.dbcc_object_type,'IDENTIFIER: ')) object_desc
                    , SUBSTR(src.text,ids.col,NVL(LENGTH(ids.name),0)) src_name
                 FROM checked c
                INNER JOIN all_identifiers ids
                   ON ids.owner = NVL(qc_utility_var.g_object_owner,USER)
--                   ON ids.owner = USER
                  AND ids.object_type = c.object_type
                  AND ids.object_name = c.object_name
                  AND ids.name = dbcc_name
                  AND ids.usage = 'DECLARATION'
                  AND ids.line = dbcc_line
                  AND ids.col = dbcc_col
                INNER JOIN all_source src
                   ON src.owner = ids.owner
                  AND src.type = ids.object_type
                  AND src.name = ids.object_name
                  AND src.line = ids.line
            )
--select * from final;
          SELECT dbcc_object_type object_type, owner||'.'||dbcc_name||'#'||signature object_name
               , UPPER(SUBSTR(object_desc,1,1))||LOWER(SUBSTR(object_desc,2))
               ||' "'||src_name||'"'
               ||' doesn''t match standard pattern '||check_pattern
               ||' in '||object_type||' '||object_name||' at line '||line||' col '||col msg_text
               , 'RENAME' fix_op, fix_name, status
           FROM final
--          WHERE status = 'KO' -- take them all for statistics purpose
          ORDER BY object_type, object_name, dbcc_line, dbcc_col
      ;
      l_count INTEGER := 0;
   BEGIN
      -- Compile objects not having plscope identifiers yet (could be empty, invalid or not analyzed yet)
      compile_for_plscope(p_compile_code=>'INCREMENTAL');
      -- Check for non-compliances
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         l_count := l_count + 1;
         IF r_obj.status = 'KO' THEN
            log_run_msg(
               'QC019',r_obj.object_name
               ,r_obj.fix_name, 'RENAME'
               ,r_obj.object_type,NULL,NULL,l_count,NULL
               ,p_msg_type,r_obj.msg_text||CASE WHEN r_obj.fix_name IS NOT NULL THEN ', fix: '||LOWER(r_obj.fix_op)||' to "'||r_obj.fix_name||'"' END
            );
         END IF;
      END LOOP obj_loop;
      log_run_stat('QC019','IDENTIFIER',l_count);
   END qc019;
   -- QC021: Redundant primary/unique key constraints E
   -- (when a pk/uk is a subset of another pk/uk)
   PROCEDURE qc021 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code qc_checks.qc_code%TYPE := 'QC021';
      CURSOR c_obj IS
         SELECT conpat.object_type, conx.owner
              , conx.table_name||'.'||conx.constraint_name||'@'||cony.constraint_name object_name
              , INITCAP(DECODE(conx.constraint_type,'P','primary key','U','unique key','R','foreign key','C','check','other')||' constraint ')
             || conx.constraint_name || '('||qc_utility_krn.get_cons_columns(conx.owner, conx.table_name, conx.constraint_name)||') is redundant with '
             || INITCAP(DECODE(cony.constraint_type,'P','primary key','U','unique key','R','foreign key','C','check','other')||' constraint ')
             || cony.constraint_name || '('||qc_utility_krn.get_cons_columns(cony.owner, cony.table_name, cony.constraint_name)||')' object_desc
           FROM all_tables tab
          INNER JOIN qc_patterns tabpat
             ON tabpat.object_type = 'TABLE'
            AND tabpat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          INNER JOIN all_constraints con1
             ON con1.owner = tab.owner
            AND con1.table_name = tab.table_name
            AND con1.constraint_type IN ('P','U')
          INNER JOIN all_constraints con2
             ON con2.owner = con1.owner
            AND con2.table_name = con1.table_name
            AND con2.constraint_name < con1.constraint_name
            AND con2.constraint_type IN ('P','U')
          INNER JOIN all_constraints conx -- the redundant constraint (to drop)
             ON conx.owner = con1.owner
            AND conx.table_name = con1.table_name
            AND conx.constraint_type IN ('P','U')
            AND conx.constraint_name = qc_utility_krn.get_duplicate_cons(con1.owner, con1.table_name, con1.constraint_name, con2.constraint_name)
          INNER JOIN all_constraints cony -- the constraint to keep
             ON cony.owner = con1.owner
            AND cony.table_name = con1.table_name
            AND cony.constraint_type IN ('P','U')
            AND cony.constraint_name IN (con1.constraint_name, con2.constraint_name)
            AND cony.constraint_name != conx.constraint_name
          INNER JOIN qc_patterns conpat
             ON conpat.object_type = 'CONSTRAINT: '||DECODE(conx.constraint_type,'P','PRIMARY KEY','U','UNIQUE KEY','R','FOREIGN KEY','C','CHECK')
            AND conpat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE NOT tab.table_name LIKE 'BIN$%' --necessary?
            AND tab.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (tabpat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.include_pattern)=1)
            AND (tabpat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(tabpat.object_type,tab.owner,tab.table_name,tabpat.exclude_pattern)=0)
          ORDER BY conx.owner, conx.table_name, conx.constraint_name, cony.constraint_name
         ;
      r_last_obj c_obj%ROWTYPE;
      l_count INTEGER := 0;
      l_idx_cnt INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg(p_qc_code=>l_qc_code,p_object_name=>r_obj.object_name,p_object_type=>r_obj.object_type,p_msg_type=>p_msg_type,p_msg_text=>r_obj.object_desc);
      END LOOP obj_loop;
      log_run_stat(l_qc_code, 'CONSTRAINT: PRIMARY KEY', object_count_from_stat('QC000','CONSTRAINT: PRIMARY KEY'));
      log_run_stat(l_qc_code, 'CONSTRAINT: UNIQUE KEY', object_count_from_stat('QC000','CONSTRAINT: UNIQUE KEY'));
   END qc021;
   -- QC022: Standalone procedures and functions are not allowed E
   PROCEDURE qc022 (
      p_msg_type IN VARCHAR2
   )
   IS
      l_qc_code qc_checks.qc_code%TYPE := 'QC022';
      CURSOR c_obj IS
         -- Generic handling for all object types
         SELECT 10 sort_order, obj.object_type, obj.owner
              , 'Standalone ' ||obj.object_type||' '||LOWER(obj.object_name)||' is not allowed!' object_desc, obj.object_name
              , obj.object_type fix_type,obj.object_name fix_name,pat.fix_pattern, pat.check_pattern
              , qc_utility_krn.replace_vars(obj.object_type,obj.owner,object_name,pat.check_pattern) check_pattern2
              , qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.check_pattern) check_res
              , pat.msg_type
           FROM all_objects obj
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND obj.object_type IN ('PROCEDURE','FUNCTION')
            AND (obj.object_type != 'TABLE' OR SUBSTR(obj.object_name,1,4) != 'BIN$')
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(obj.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
         ;
      r_last_obj c_obj%ROWTYPE;
      l_count_proc INTEGER := 0;
      l_count_func INTEGER := 0;
      l_idx_cnt INTEGER := 0;
   BEGIN
      <<obj_loop>>
      FOR r_obj IN c_obj LOOP
         log_run_msg(p_qc_code=>l_qc_code,p_object_name=>r_obj.object_name,p_object_type=>r_obj.object_type,p_msg_type=>p_msg_type,p_msg_text=>r_obj.object_desc);
         IF r_obj.object_type = 'PROCEDURE' THEN
            l_count_proc := l_count_proc + 1;
         ELSIF r_obj.object_type = 'FUNCTION' THEN
            l_count_func := l_count_func + 1;
         END IF;
      END LOOP obj_loop;
      log_run_stat(l_qc_code, 'PROCEDURE', l_count_proc);
      log_run_stat(l_qc_code, 'FUNCTION', l_count_func);
   END qc022;
--#begin public
   ---
   -- Analyse impact
   ---
   PROCEDURE analyse_impact
--#end public
   IS
      CURSOR c_msg IS
         SELECT *
           FROM qc_run_msgs
          WHERE run_id_to IS NULL
            AND (fix_op = 'DROP' OR (fix_op = 'RENAME' AND fix_name IS NOT NULL))
          ORDER BY qc_code, object_type, object_name
      ;
      CURSOR c_src IS
         SELECT src.owner, src.TYPE, src.NAME, UPPER(src.text) text
           FROM all_source src
          WHERE src.owner = NVL(qc_utility_var.g_object_owner,USER)
--          WHERE src.owner IN (
--               SELECT NVL(qc_utility_var.g_object_owner,USER)
--                 FROM qc_dictionary_entries dict_own
--                WHERE dict_own.dict_name = 'OBJECT OWNER'
--                  AND (dict_own.dict_key LIKE 'PACKAGE%'
--                    OR dict_own.dict_key LIKE 'PROCEDURE%'
--                    OR dict_own.dict_key LIKE 'FUNCTION%'
--                      )
--          )
          ORDER BY src.TYPE, src.NAME, src.line
      ;
      t_msg qc_utility_msg.msg_table;
      l_table_name all_tables.table_name%TYPE;
   BEGIN
      -- Update number of references found in all_dependencies view
      UPDATE qc_run_msgs msg
         SET src_ref_cnt = NULL
           , dep_ref_cnt = (
                SELECT DECODE(COUNT(*),0,CAST(NULL AS NUMBER),COUNT(*))
                  FROM all_dependencies dep
--                 INNER JOIN qc_dictionary_entries dict_own
--                    ON dict_own.dict_name = 'OBJECT OWNER'
--                   AND dict_own.dict_key LIKE dep.TYPE||'%'
                 WHERE dep.owner = NVL(qc_utility_var.g_object_owner,USER)
                   AND referenced_type = DECODE(NVL(INSTR(msg.object_type,':'),0),0,msg.object_type,SUBSTR(msg.object_type,1,INSTR(msg.object_type,':')-1))
                   AND referenced_name = DECODE(NVL(INSTR(msg.object_name,'.'),0),0,msg.object_name,SUBSTR(msg.object_name,INSTR(msg.object_name,'.')+1))
                   AND dependency_type = 'HARD'
             )
       WHERE run_id_to IS NULL
         AND (fix_op = 'DROP' OR (fix_op = 'RENAME' AND fix_name IS NOT NULL))
      ;
      -- Update number of references found in all_source view
      OPEN c_msg;
      FETCH c_msg BULK COLLECT INTO t_msg;
      CLOSE c_msg;
      IF t_msg.COUNT > 0 THEN
         <<msg_loop>>
         FOR i IN 1..t_msg.COUNT LOOP
            decompose_name(t_msg(i).object_type, t_msg(i).object_name, l_table_name, t_msg(i).object_name, '.');
         END LOOP msg_loop;
         <<src_loop>>
         FOR r_src IN c_src LOOP
            <<src_subloop>>
            FOR i IN 1..t_msg.COUNT LOOP
               -- Don't check object own source (e.g. for a trigger)
               IF t_msg(i).object_name != r_src.NAME
               OR t_msg(i).object_type != r_src.TYPE
               THEN
                  IF  NVL(INSTR(r_src.text,t_msg(i).object_name),0)>0 /*avoid expensive regexp operation here after*/
                  AND REGEXP_LIKE(r_src.text,'(^|[^A-Z_0-9]+)'||t_msg(i).object_name||'([^A-Z_0-9]+|$)') /*match entire word*/
                  THEN
                     t_msg(i).src_ref_cnt := NVL(t_msg(i).src_ref_cnt,0) + 1;
                  END IF;
               END IF;
            END LOOP src_subloop;
         END LOOP src_loop;
         <<msg_loop2>>
         FOR i IN 1..t_msg.COUNT LOOP
            IF t_msg(i).src_ref_cnt IS NOT NULL THEN
               UPDATE qc_run_msgs
                  SET src_ref_cnt = t_msg(i).src_ref_cnt
                WHERE msg_ivid = t_msg(i).msg_ivid
               ;
            END IF;
         END LOOP msg_loop2;
      END IF;
   END analyse_impact;
   ---
   -- Get the latest run before a given date/time
   ---
   FUNCTION get_latest_run_id (
      p_datetime IN DATE := NULL
   )
   RETURN qc_runs.run_id%TYPE
   IS
      CURSOR c_run (
         p_datetime IN DATE
      )
      IS
         SELECT MAX(run_id)
           FROM qc_runs
          WHERE (p_datetime IS NULL OR nvl(end_time,begin_time) < p_datetime)
      ;
      l_run_id qc_runs.run_id%TYPE;
   BEGIN
      OPEN c_run(p_datetime);
      FETCH c_run INTO l_run_id;
      CLOSE c_run;
      RETURN l_run_id;
   END get_latest_run_id;
   ---
   -- Get first run id
   ---
   FUNCTION get_min_run_id
   RETURN qc_runs.run_id%TYPE
   IS
      CURSOR c_run
      IS
         SELECT MIN(run_id)
           FROM qc_runs
      ;
      l_run_id qc_runs.run_id%TYPE;
   BEGIN
      OPEN c_run;
      FETCH c_run INTO l_run_id;
      CLOSE c_run;
      RETURN l_run_id;
   END get_min_run_id;
   ---
   -- Get last run id
   ---
   FUNCTION get_max_run_id
   RETURN qc_runs.run_id%TYPE
   IS
      CURSOR c_run
      IS
         SELECT MAX(run_id)
           FROM qc_runs
      ;
      l_run_id qc_runs.run_id%TYPE;
   BEGIN
      OPEN c_run;
      FETCH c_run INTO l_run_id;
      CLOSE c_run;
      RETURN l_run_id;
   END get_max_run_id;
   ---
   -- Get a run based on its id
   ---
   FUNCTION get_run(
      p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_runs%ROWTYPE
   IS
      CURSOR c_run (
         p_run_id IN qc_runs.run_id%TYPE
      )
      IS
         SELECT *
           FROM qc_runs
          WHERE run_id = p_run_id
      ;
      r_run qc_runs%ROWTYPE;
   BEGIN
      OPEN c_run(p_run_id);
      FETCH c_run INTO r_run;
      CLOSE c_run;
      RETURN r_run;
   END get_run;
   ---
   -- Check a run id
   ---
   FUNCTION is_valid_run_id (
      p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN BOOLEAN
   IS
      r_run qc_runs%ROWTYPE;
   BEGIN
      r_run := get_run(p_run_id);
      RETURN r_run.run_id = p_run_id;
   END is_valid_run_id;
--#begin public
   ---
   -- Get quality check report
   ---
   FUNCTION get_report (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
   ,  p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL -- NULL for all
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      CURSOR c_app (
         p_run_id IN qc_runs.run_id%TYPE
       , p_app_alias IN qc_run_msgs.app_alias%TYPE
      )
      IS
         SELECT DISTINCT app_alias
           FROM qc_run_msgs
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND (run_id_from = p_run_id /*created by this run*/
              OR run_id_to = p_run_id /*closed by this run*/
              OR run_id_to IS NULL /*still opened despite this run*/
                )
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
          ORDER BY 1
          ;
      CURSOR c_own (
         p_run_id IN qc_runs.run_id%TYPE
       , p_app_alias IN qc_run_msgs.app_alias%TYPE
      )
      IS
         SELECT DISTINCT object_owner
           FROM qc_run_msgs
          WHERE app_alias = p_app_alias
            AND (run_id_from = p_run_id /*created by this run*/
              OR run_id_to = p_run_id /*closed by this run*/
              OR run_id_to IS NULL /*still opened despite this run*/
                )
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
          ORDER BY 1
          ;
      CURSOR c_msg (
         p_run_id IN qc_runs.run_id%TYPE
       , p_run_id_from IN qc_runs.run_id%TYPE
       , p_run_id_to IN qc_runs.run_id%TYPE
       , p_app_alias IN qc_run_msgs.app_alias%TYPE
       , p_object_owner IN qc_run_msgs.object_owner%TYPE
      )
      IS
         SELECT qc_code||'-'||msg_text msg_text
           FROM qc_run_msgs
          WHERE (p_run_id IS NULL OR (run_id_from < p_run_id AND run_id_to IS NULL))
            AND (p_run_id_to IS NULL OR run_id_to = p_run_id_to)
            AND (p_run_id_from IS NULL OR run_id_from = p_run_id_from)
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
            AND app_alias = p_app_alias
            AND object_owner = p_object_owner
          ORDER BY qc_code, sort_order, object_type, object_name
      ;
      l_count INTEGER;
      l_tot_count INTEGER;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_last_app_alias qc_run_msgs.app_alias%TYPE;
      l_last_object_owner qc_run_msgs.object_owner%TYPE;
   BEGIN
      -- Check parameter
      IF p_run_id IS NOT NULL THEN
         assert(is_valid_run_id(p_run_id),'Run #'||p_run_id||' does not exist!');
      ELSE
         l_run_id := get_max_run_id;
         assert(l_run_id IS NOT NULL,'No run found!');
      END IF;
      -- For each application
      <<app_loop>>
      FOR r_app IN c_app(l_run_id,p_app_alias) LOOP
      -- For each schema
      <<own_loop>>
      FOR r_own IN c_own(l_run_id,r_app.app_alias) LOOP
      -- Build report
      pipe ROW('Quality checks for Application "'||r_app.app_alias||'" Schema "'||r_own.object_owner||'" Database "'||sys_context('userenv','db_name')||'"');
      pipe ROW(NULL);
      pipe ROW('*** New anomalies discovered by run #'||l_run_id||' ***');
      pipe ROW(NULL);
      l_tot_count := 0;
      l_count := 0;
      <<msg_loop>>
      FOR r_msg IN c_msg(NULL,l_run_id,NULL,r_app.app_alias,r_own.object_owner) LOOP
         pipe ROW(r_msg.msg_text);
         l_count := l_count + 1;
      END LOOP msg_loop;
      IF l_count = 0 THEN
         pipe ROW('None found.');
      ELSE
         pipe ROW(NULL);
         pipe ROW(l_count||' new anomal'||CASE WHEN l_count>1 THEN 'ies' ELSE 'y' END ||' found.');
      END IF;
      l_tot_count := l_count;
      pipe ROW(NULL);
      pipe ROW('*** Pre-existing anomalies resolved by run #'||l_run_id||' ***');
      pipe ROW(NULL);
      l_count := 0;
      <<msg_loop2>>
      FOR r_msg IN c_msg(NULL,NULL,l_run_id,r_app.app_alias,r_own.object_owner) LOOP
         pipe ROW(r_msg.msg_text);
         l_count := l_count + 1;
      END LOOP msg_loop2;
      IF l_count = 0 THEN
         pipe ROW('None found.');
      ELSE
         pipe ROW(NULL);
         pipe ROW(l_count||' pre-existing anomal'||CASE WHEN l_count>1 THEN 'ies' ELSE 'y' END ||' resolved.');
      END IF;
      pipe ROW(NULL);
      pipe ROW('*** Pre-existing anomalies still NOT resolved by run #'||l_run_id||' ***');
      pipe ROW(NULL);
      l_count := 0;
      <<msg_loop>>
      FOR r_msg IN c_msg(l_run_id,NULL,NULL,r_app.app_alias,r_own.object_owner) LOOP
         pipe ROW(r_msg.msg_text);
         l_count := l_count + 1;
      END LOOP msg_loop;
      IF l_count = 0 THEN
         pipe ROW('None found.');
      ELSE
         pipe ROW(NULL);
         pipe ROW(l_count||' pre-existing anomal'||CASE WHEN l_count>1 THEN 'ies' ELSE 'y' END ||' still NOT resolved.');
      END IF;
      l_tot_count := l_tot_count + l_count;
      IF l_tot_count = 0 THEN
         pipe ROW('No anomaly in the backlog');
      ELSE
         pipe ROW(l_tot_count||' anomal'||CASE WHEN l_tot_count>1 THEN 'ies' ELSE 'y' END ||' in the backlog after this run.');
      END IF;
      pipe ROW(NULL);
      pipe ROW(NULL);
      END LOOP app_loop;
      END LOOP own_loop;
   END get_report;
--#begin public
   ---
   -- Get quality check results as xUnit XML (xUnit test execution format)
   ---
   FUNCTION get_xunit_xml (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
    , p_ver_id IN INTEGER := 2 -- version
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      -- Fetch stat for all
      CURSOR c_all (
         p_run_id IN qc_runs.run_id%TYPE
      )
      IS
         SELECT (run.end_time - run.begin_time) * 86400 TIME, msg.cnt, NVL(stat.tot,msg.cnt) tot
           FROM qc_runs run
           LEFT OUTER JOIN
                (
                  SELECT COUNT(*) cnt
                    FROM qc_run_msgs
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                     AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
                ) msg
             ON 1=1
           LEFT OUTER JOIN
                (
                  SELECT SUM(object_count) tot
                    FROM qc_run_stats
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                ) stat
             ON 1=1
          WHERE run.run_id = p_run_id
      ;
      -- Fetch quality checks
      CURSOR c_qc (
         p_run_id IN qc_runs.run_id%TYPE
      )
      IS
         SELECT msg.qc_code, qc.descr, msg.cnt, NVL(stat.tot,msg.cnt) tot
           FROM (
                  SELECT qc_code, COUNT(*) cnt
                    FROM qc_run_msgs
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                     AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
                   GROUP BY qc_code
                ) msg
             INNER JOIN qc_checks qc
                ON qc.qc_code = msg.qc_code
             LEFT OUTER JOIN
                (
                  SELECT qc_code, SUM(object_count) tot
                    FROM qc_run_stats
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                   GROUP BY qc_code
                ) stat
             ON stat.qc_code = msg.qc_code
          ORDER BY msg.qc_code
      ;
      -- Fetch object types
      CURSOR c_ot (
         p_run_id IN qc_runs.run_id%TYPE
       , p_qc_code IN qc_run_msgs.qc_code%TYPE
      )
      IS
         SELECT msg.object_type, msg.cnt, NVL(stat.object_count,msg.cnt) tot
           FROM (
                  SELECT object_type, COUNT(*) cnt
                    FROM qc_run_msgs
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                     AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
                     AND qc_code = p_qc_code
                   GROUP BY object_type
                ) msg
           LEFT OUTER JOIN qc_run_stats stat
             ON stat.run_id_from <= p_run_id AND p_run_id < NVL(stat.run_id_to,p_run_id+1)
            AND stat.qc_code = p_qc_code
            AND stat.object_type = msg.object_type
          ORDER BY msg.object_type
      ;
      -- Fetch error messages
      CURSOR c_msg (
         p_run_id IN qc_runs.run_id%TYPE
       , p_qc_code IN qc_run_msgs.qc_code%TYPE
       , p_object_type IN qc_run_msgs.object_type%TYPE := NULL
      )
      IS
         SELECT *
           FROM qc_run_msgs
          WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
            AND qc_code = p_qc_code
            AND (p_object_type IS NULL OR object_type = p_object_type)
          ORDER BY sort_order, object_type, object_name
      ;
      l_count INTEGER := 0;
      l_tot_count INTEGER := 0;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
   BEGIN
      -- Check parameter
      IF p_run_id IS NOT NULL THEN
         assert(is_valid_run_id(p_run_id),'Run #'||p_run_id||' does not exist!');
      ELSE
         l_run_id := get_max_run_id;
         assert(l_run_id IS NOT NULL,'No run found!');
      END IF;
      -- Build report
      pipe ROW('<?xml version="1.0" encoding="UTF-8"?>');
      <<all_loop>>
      FOR r_all IN c_all(l_run_id) LOOP
         pipe ROW('<testsuites time="'||r_all.TIME||'" name="'||sys_context('userenv','current_user')||'@'||sys_context('userenv','db_name')||'" failures="0" errors="'||r_all.cnt||'" tests="'||r_all.tot||'">');
         -- For each QC
         <<qc_loop>>
         FOR r_qc IN c_qc(l_run_id) LOOP
            IF p_ver_id = 1 THEN
               pipe ROW('<testsuite time="0" name="'||r_qc.qc_code||'-'||r_qc.descr||'" failures="0" errors="'||r_qc.cnt||'" tests="'||r_qc.tot||'" package="" id="">');
               -- For each object type
               <<ot_loop>>
               FOR r_ot IN c_ot(l_run_id,r_qc.qc_code) LOOP
                  pipe ROW('<testsuite time="0" name="'||r_ot.object_type||'" failures="0" errors="'||r_ot.cnt||'" tests="'||r_ot.tot||'" package="'||r_qc.qc_code||'" id="">');
                  -- For each error message
                  <<msg_loop>>
                  FOR r_msg IN c_msg(l_run_id,r_qc.qc_code,r_ot.object_type) LOOP
                     pipe ROW('<testcase time="0" name="'||r_msg.object_name||'" assertions="0" classname="'||r_ot.object_type||'" status="Error">');
                     pipe ROW('<error>');
                     pipe ROW('<![CDATA[ '||r_msg.msg_text||' ]]>');
                     pipe ROW('</error>');
                     pipe ROW('</testcase>');
                  END LOOP msg_loop;
                  pipe ROW('</testsuite>');
               END LOOP ot_loop;
               pipe ROW('</testsuite>');
            ELSE
               pipe ROW('<testcase time="0" name="'||r_qc.qc_code||'-'||r_qc.descr||'" assertions="0" classname="'||r_qc.qc_code||'" status="Error">');
               pipe ROW('<error>');
               -- For each error message
               <<msg_loop>>
               FOR r_msg IN c_msg(l_run_id,r_qc.qc_code) LOOP
                  pipe ROW('<![CDATA[ '||r_msg.msg_text||' ]]>');
               END LOOP msg_loop;
               pipe ROW('</error>');
               pipe ROW('</testcase>');
            END IF;
         END LOOP qc_loop;
         pipe ROW('</testsuites>');
      END LOOP all_loop;
   END get_xunit_xml;
--#begin public
   ---
   -- Get quality check results as sonar XML (sonar generic test execution format)
   ---
   FUNCTION get_sonar_xml (
      p_run_id qc_runs.run_id%TYPE := NULL -- NULL for latest run
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      -- Fetch quality checks
      CURSOR c_qc (
         p_run_id IN qc_runs.run_id%TYPE
      )
      IS
         SELECT qc.qc_code, qc.descr, NVL(msg.cnt,0) cnt, NVL(stat.tot,msg.cnt) tot
           FROM qc_checks qc
           LEFT OUTER JOIN (
                  SELECT qc_code, COUNT(*) cnt
                    FROM qc_run_msgs
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                     AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
                   GROUP BY qc_code
                ) msg
                ON msg.qc_code = qc.qc_code
           LEFT OUTER JOIN
                (
                  SELECT qc_code, SUM(object_count) tot
                    FROM qc_run_stats
                   WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
                   GROUP BY qc_code
                ) stat
             ON stat.qc_code = msg.qc_code
          ORDER BY qc.qc_code
      ;
      -- Fetch error messages
      CURSOR c_msg (
         p_run_id IN qc_runs.run_id%TYPE
       , p_qc_code IN qc_run_msgs.qc_code%TYPE
       , p_object_type IN qc_run_msgs.object_type%TYPE := NULL
      )
      IS
         SELECT *
           FROM qc_run_msgs
          WHERE run_id_from <= p_run_id AND p_run_id < NVL(run_id_to,p_run_id+1)
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
            AND qc_code = p_qc_code
            AND (p_object_type IS NULL OR object_type = p_object_type)
          ORDER BY sort_order, object_type, object_name
      ;
      l_count INTEGER := 0;
      l_tot_count INTEGER := 0;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
   BEGIN
      -- Check parameter
      IF p_run_id IS NOT NULL THEN
         assert(is_valid_run_id(p_run_id),'Run #'||p_run_id||' does not exist!');
      ELSE
         l_run_id := get_max_run_id;
         assert(l_run_id IS NOT NULL,'No run found!');
      END IF;
      -- Build report
      pipe ROW('<?xml version="1.0"?>');
      pipe ROW('<testExecutions version="1">');
      pipe ROW('<file path="'||sys_context('userenv','current_user')||'@'||sys_context('userenv','db_name')||'">');
      -- For each QC
      <<qc_loop>>
      FOR r_qc IN c_qc(l_run_id) LOOP
         pipe ROW('<testCase name="'||r_qc.qc_code||'-'||r_qc.descr||'" duration="0">');
         IF r_qc.cnt > 0 THEN
            pipe ROW('<error message="'||r_qc.cnt||' error'||CASE WHEN r_qc.cnt>1 THEN 's' END||' out of '||r_qc.tot||' object'||CASE WHEN r_qc.tot>1 THEN 's' END||'">');
            -- For each error message
            <<msg_loop>>
            FOR r_msg IN c_msg(l_run_id,r_qc.qc_code) LOOP
               pipe ROW('<![CDATA[ '||r_msg.msg_text||' ]]>');
            END LOOP msg_loop;
            pipe ROW('</error>');
--         TODO: find a way to identify QC that was not executed during a specific run (e.g. create an info msg for those run)
--         ELSE
--            pipe ROW('<skipped message="'||r_qc.cnt||'/'||r_qc.tot||' error'||CASE WHEN r_qc.cnt>1 THEN 's' END||'">');
--            pipe ROW('</skipped>');
         END IF;
         pipe ROW('</testCase>');
      END LOOP qc_loop;
      pipe ROW('</file>');
      pipe ROW('</testExecutions>');
   END get_sonar_xml;
--#begin public
   ---
   -- Get quality check results as sonar JSON (sonar generic issue format)
   -- (see https://docs.sonarqube.org/latest/analysis/generic-issue)
   ---
   FUNCTION get_sonar_json (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
    , p_file_path IN VARCHAR2 := NULL -- path of the file to which results must be attached
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      -- Fetch checks
      CURSOR c_chk IS
         SELECT *
           FROM qc_checks
          ORDER BY qc_code
      ;
      -- Fetch error messages
      CURSOR c_msg (
         p_run_id IN qc_runs.run_id%TYPE
       , p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
       , p_object_type IN qc_run_msgs.object_type%TYPE := NULL
      )
      IS
         SELECT msg.*--, chk.descr
           FROM qc_run_msgs msg
--          INNER JOIN qc_checks chk
--             ON chk.qc_code = msg.qc_code
          WHERE msg.run_id_from <= p_run_id AND p_run_id < NVL(msg.run_id_to,p_run_id+1)
            AND NVL(msg_hidden,'N') = 'N' -- will also exclude QC000
            AND (p_qc_code IS NULL OR msg.qc_code = p_qc_code)
            AND (p_object_type IS NULL OR msg.object_type = p_object_type)
          ORDER BY msg.sort_order, msg.object_type, msg.object_name
      ;
      l_count INTEGER := 0;
      l_tot_count INTEGER := 0;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
   BEGIN
      -- Check parameter
      IF p_run_id IS NOT NULL THEN
         assert(is_valid_run_id(p_run_id),'Run #'||p_run_id||' does not exist!');
      ELSE
         l_run_id := get_max_run_id;
         assert(l_run_id IS NOT NULL,'No run found!');
      END IF;
      -- Build report
      pipe ROW('{');
      pipe ROW('  "rules": [');
      l_count := 0;
      <<chk_loop>>
      FOR r_chk IN c_chk LOOP
         l_count := l_count + 1;
         pipe ROW('   '|| CASE WHEN l_count > 1 THEN ',' ELSE ' ' END || '{');
         pipe ROW('      "id": "'||r_chk.qc_code||'"');
         pipe ROW('     ,"name": "'||r_chk.qc_code||': '||r_chk.descr||'"');
         pipe ROW('     ,"description": "'||r_chk.qc_code||': '||r_chk.descr||'"');
         pipe ROW('     ,"engineId": "QC_UTILITY"');
         pipe ROW('     ,"cleanCodeAttribute": "CONVENTIONAL"');
         pipe ROW('     ,"type": "'||CASE r_chk.msg_type WHEN 'T' THEN 'CODE_SMELL' ELSE 'BUG' END||'"');
         pipe ROW('     ,"severity": "'||CASE r_chk.msg_type WHEN 'E' THEN 'BLOCKER' ELSE 'MINOR' END||'"');
         pipe ROW('    }');
      END LOOP;
      -- For each error message
      l_count := 0;
      <<msg_loop>>
      FOR r_msg IN c_msg(l_run_id) LOOP
         IF r_msg.msg_type IN ('E','W') THEN
            l_count := l_count + 1;
            IF l_count = 1 THEN
               pipe ROW('  ]');
               pipe ROW(' ,"issues": [');
               pipe ROW('    {');
            ELSE
               pipe ROW('   ,{');
            END IF;
            pipe ROW('      "ruleId": "'||r_msg.qc_code||'"');
            pipe ROW('     ,"primaryLocation": {');
            pipe ROW('        "message": "'||REPLACE(r_msg.msg_text,'\','\\')||'"');
            pipe ROW('       ,"filePath": "'||NVL(p_file_path,LOWER(sys_context('userenv','current_user')||'@'||sys_context('userenv','db_name'))||'.qc')||'"'); -- e.g. opsys_res@opsydigd.qc
            pipe ROW('       ,"textRange": {');
            pipe ROW('          "startLine": 1');
            pipe ROW('         ,"startColumn": 1');
            pipe ROW('         ,"endLine": 2');
            pipe ROW('         ,"endColumn": 1');
            pipe ROW('        }');
            pipe ROW('      }');
            pipe ROW('    }');
         END IF;
      END LOOP msg_loop;
      pipe ROW('  ]');
      pipe ROW('}');
   END get_sonar_json;
   -- Get a dictionary entry for a given application
   FUNCTION get_app_dict_entry (
       p_app_alias qc_dictionary_entries.app_alias%TYPE
     , p_dict_name qc_dictionary_entries.dict_name%TYPE
     , p_dict_key qc_dictionary_entries.dict_key%TYPE
   )
   RETURN qc_dictionary_entries.dict_value%TYPE
   IS
       CURSOR c_par (
           p_app_alias qc_dictionary_entries.app_alias%TYPE
         , p_dict_name qc_dictionary_entries.dict_name%TYPE
         , p_dict_key qc_dictionary_entries.dict_key%TYPE
       )
       IS
           SELECT dict_value
             FROM qc_dictionary_entries
            WHERE app_alias = p_app_alias
              AND dict_name = p_dict_name
              AND dict_key = p_dict_key
       ;
       l_dict_value qc_dictionary_entries.dict_value%TYPE;
   BEGIN
      OPEN c_par(p_app_alias,p_dict_name,p_dict_key);
      FETCH c_par INTO l_dict_value;
      CLOSE c_par;
      RETURN l_dict_value;
   END;
   ---
   -- Send report by email if any difference found compared to previous run
   ---
   FUNCTION send_report (
      p_run_id IN qc_runs.run_id%TYPE := NULL -- NULL for latest run
    , p_to IN VARCHAR2 := NULL -- alternate TO
    , p_cc IN VARCHAR2 := NULL -- alternate CC
    , p_bcc IN VARCHAR2 := NULL -- alternate BCC
    , p_force_send IN VARCHAR2 := 'N' -- Send empty report Y/N
    , p_app_alias qc_apps.app_alias%TYPE := NULL -- NULL means ALL
   )
   RETURN qc_runs.msg_count%TYPE
   IS
      l_server     VARCHAR2(250 CHAR);
      l_sender     VARCHAR2(250 CHAR);
      l_to         VARCHAR2(750 CHAR);
      l_cc         VARCHAR2(750 CHAR);
      l_bcc        VARCHAR2(750 CHAR);
      l_subject    VARCHAR2(250 CHAR);
      l_message    CLOB;
      l_msg_count  qc_runs.msg_count%TYPE;
      l_run_id     qc_runs.run_id%TYPE := p_run_id;
      k_crlf CONSTANT VARCHAR2(2 CHAR) := CHR(13)||CHR(10);
      -- Cursor to count number of issues created/closed by a given run
      CURSOR c_cnt (
         p_run_id IN qc_runs.run_id%TYPE
       , p_app_alias qc_apps.app_alias%TYPE
      )
      IS
         SELECT COUNT(*)
           FROM qc_run_msgs
          WHERE (NVL(p_app_alias,'ALL')='ALL' OR app_alias = p_app_alias)
            AND (run_id_from = p_run_id OR run_id_to = p_run_id)
            AND NVL(msg_hidden,'N') = 'N'
      ;
      -- Cursor to get applications related to a given run
      CURSOR c_app (
         p_run_id IN qc_runs.run_id%TYPE
       , p_app_alias qc_apps.app_alias%TYPE
       , p_force_send IN VARCHAR2
      )
      IS
         SELECT DISTINCT app_alias
           FROM qc_run_msgs
          WHERE (NVL(p_app_alias,'ALL')='ALL' OR app_alias = p_app_alias)
            AND (run_id_from = p_run_id -- new/created
              OR run_id_to = p_run_id -- closed/resolved
              OR (p_force_send='Y' AND run_id_to IS NULL)) -- opened/unresolved
            AND NVL(msg_hidden,'N') = 'N'
          ORDER BY 1
      ;
      -- Cursor to get the messages related to a given run
      CURSOR c_msg (
         p_run_id IN qc_runs.run_id%TYPE
       , p_app_alias qc_apps.app_alias%TYPE
      )
      IS
         SELECT COLUMN_VALUE msg_text
           FROM TABLE(qc_utility_krn.get_report(p_run_id,p_app_alias))
      ;
      -- Send an email of a size potentially >32k
      PROCEDURE send_email IS
      BEGIN
         mail_utility_krn.send_mail_over32k(
            p_sender     => l_sender
          , p_recipients => l_to
          , p_cc         => l_cc
          , p_bcc        => l_bcc
          , p_subject    => l_subject
          , p_message    => l_message
          , p_priority   => 3
          , p_force_send_on_non_prod_env=>TRUE
          );
      EXCEPTION
         -- SMTP problem should not result into an error
         -- Exception is not re-raised (please ignore PLW-06009)
         WHEN OTHERS THEN
            sys.dbms_output.put_line('SMTP problem: '||sys.dbms_utility.format_error_stack);
            sys.dbms_output.put_line('SMTP problem: '||sys.dbms_utility.format_error_backtrace);
      END;
   BEGIN
      -- Check parameter
      IF p_run_id IS NOT NULL THEN
         assert(is_valid_run_id(p_run_id),'Run #'||p_run_id||' does not exist!');
      ELSE
         l_run_id := get_max_run_id;
         assert(l_run_id IS NOT NULL,'No run found!');
      END IF;
      -- Count number of messages (excluding those marked as hidden)
      OPEN c_cnt(l_run_id,p_app_alias);
      FETCH c_cnt INTO l_msg_count;
      CLOSE c_cnt;
      -- Send by email any difference compared to previous run
      -- (or just the backlog when forced to do so)
      IF l_msg_count > 0 OR p_force_send = 'Y'
      THEN
         -- Get email parameters
         l_server := NVL(get_dictionary_entry('PARAMETER','EMAIL SERVER'),'localhost');
         l_sender := NVL(get_dictionary_entry('PARAMETER','EMAIL SENDER'),'AUTOMATED DB QUALITY CHECK <automated-notifications@nomail.ec.europa.eu>');
         l_to := COALESCE(p_to,get_app_dict_entry('ALL','PARAMETER','EMAIL RECIPIENTS'));
         l_cc := COALESCE(p_cc,get_app_dict_entry('ALL','PARAMETER','EMAIL CC'));
         l_bcc := COALESCE(p_bcc,get_app_dict_entry('ALL','PARAMETER','EMAIL BCC'));
         mail_utility_krn.set_is_prod('Y');
         -- If email params are defined for ALL applications...
         -- and not invoked for a specific application
         IF (l_to IS NOT NULL OR l_cc IS NOT NULL OR l_bcc IS NOT NULL)
         AND NVL(p_app_alias,'ALL') = 'ALL'
         THEN
            -- Send a single email for all applications
            <<msg_loop>>
            l_message := NULL;
            FOR r_msg IN c_msg(l_run_id,NULL) LOOP
               l_message := l_message || r_msg.msg_text || k_crlf;
            END LOOP msg_loop;
            l_subject := 'Quality check for Database "'||sys_context('userenv','db_name')||'" - run #'||l_run_id||' executed on '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI');
            send_email;
         ELSE
            -- Send one email per application
            <<app_loop>>
            FOR r_app in c_app(l_run_id,p_app_alias,p_force_send) LOOP
               l_to := COALESCE(l_to,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL RECIPIENTS'));
               l_cc := COALESCE(l_cc,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL CC'));
               l_bcc := COALESCE(l_bcc,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL BCC'));
               IF l_to IS NOT NULL OR l_cc IS NOT NULL OR l_bcc IS NOT NULL THEN
                  l_message := NULL;
                  <<msg_loop>>
                  FOR r_msg IN c_msg(l_run_id,r_app.app_alias) LOOP
                     l_message := l_message || r_msg.msg_text || k_crlf;
                  END LOOP msg_loop;
                  l_subject := 'Quality check for Application "'||r_app.app_alias||'" Database "'||sys_context('userenv','db_name')||'" - run #'||l_run_id||' executed on '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI');
                  send_email;
               END IF;
            END LOOP app_loop;
         END IF;
      END IF;
      RETURN l_msg_count;
   END send_report;
--#begin public
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
--#end public
   IS
      l_msg_count qc_runs.msg_count%TYPE;
   BEGIN
      l_msg_count := send_report(p_run_id,p_to,p_cc,p_bcc,p_force_send,p_app_alias);
   END send_report;
   ---
   -- Get a date/time from a string
   ---
   FUNCTION str_to_datetime (
      p_datetime IN VARCHAR2
    , p_err_msg IN VARCHAR2 := NULL
   )
   RETURN DATE
   IS
      l_datetime DATE;
   BEGIN
      IF SUBSTR(p_datetime,1,1) IN ('-','+') THEN
         l_datetime := TRUNC(SYSDATE) + TO_NUMBER(p_datetime);
      ELSE
         l_datetime := TO_DATE(p_datetime, 'DD/MM/YYYY HH24:MI:SS');
      END IF;
      RETURN l_datetime;
   EXCEPTION
      WHEN OTHERS THEN
         assert(FALSE, NVL(p_err_msg,'Invalid date/time (expected format: -999 or DD/MM/YYYY [HH24:MI:SS]'));
   END str_to_datetime;
--#begin public
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
--#end public
   IS
      l_start_datetime DATE;
      l_end_datetime DATE;
      l_start_run_id qc_runs.run_id%TYPE := p_start_run_id;
      l_end_run_id qc_runs.run_id%TYPE := p_end_run_id;
      r_start_run qc_runs%ROWTYPE;
      r_end_run qc_runs%ROWTYPE;
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on application schemas
      CURSOR c_own (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT dict_value object_owner
           FROM qc_dictionary_entries
          WHERE dict_name = 'APP SCHEMA'
            AND app_alias = p_app_alias
          ORDER BY dict_value
      ;
      -- Cursor to get objects created, dropped or changed between 2 dates (with time) or 2 runs
      -- Created/dropped columns are not reported if corresponding table/view/mv is also created/dropped
      CURSOR c_delta (
--         p_start_datetime IN DATE := NULL
--       , p_end_datetime IN DATE := NULL
         p_start_run_id IN qc_runs.run_id%TYPE := NULL
       , p_end_run_id IN qc_runs.run_id%TYPE := NULL
      )
      IS
         WITH oldrun AS (
            SELECT NVL(MAX(run_id),1) run_id
              FROM qc_runs
             WHERE run_id = p_start_run_id
--             WHERE (p_start_run_id IS NULL AND end_time < p_start_datetime)
--                OR (p_start_run_id IS NOT NULL AND run_id = p_start_run_id)
         ), newrun AS (
            SELECT NVL(MAX(run_id),999999999) run_id
              FROM qc_runs
             WHERE run_id = p_end_run_id
--             WHERE (p_end_run_id IS NULL AND end_time < NVL(p_end_datetime,SYSDATE))
--                OR (p_end_run_id IS NOT NULL AND run_id = p_end_run_id)
         )
         --SELECT oldrun.run_id old_run_id, newrun.run_id new_run_id FROM oldrun INNER JOIN newrun ON 1=1
         -- New objects
         SELECT REPLACE(NEW.object_type, ' COLUMN') object_type2, NEW.object_name, NEW.object_type
              , INITCAP(CASE WHEN NVL(INSTR(NEW.object_type,': '),0)>0 THEN SUBSTR(NEW.object_type,NVL(INSTR(NEW.object_type,': '),0)+2)||' '||SUBSTR(NEW.object_type,1,NVL(INSTR(NEW.object_type,': '),0)-1) ELSE NEW.object_type END)||' '||NEW.object_name
              ||CASE WHEN NEW.object_type LIKE '% COLUMN' THEN ' ('||NEW.msg_text||')' END
              ||' has been added' msg_text
           FROM oldrun
          INNER JOIN newrun
             ON 1=1
          INNER JOIN qc_run_msgs NEW
             ON newrun.run_id >= NEW.run_id_from
            AND (NEW.run_id_to IS NULL OR newrun.run_id < NEW.run_id_to)
            AND NEW.qc_code = 'QC000'
            AND NEW.app_alias = qc_utility_var.g_app_alias
            AND NEW.object_owner = NVL(qc_utility_var.g_object_owner,USER)
           LEFT OUTER JOIN qc_run_msgs OLD
             ON oldrun.run_id >= OLD.run_id_from
            AND (OLD.run_id_to IS NULL OR oldrun.run_id < OLD.run_id_to)
            AND OLD.qc_code = NEW.qc_code
            AND OLD.object_type = NEW.object_type
            AND OLD.object_name = NEW.object_name
            AND OLD.app_alias = qc_utility_var.g_app_alias
            AND OLD.object_owner = NVL(qc_utility_var.g_object_owner,USER)
           LEFT OUTER JOIN qc_run_msgs oldt -- get master object
             ON oldrun.run_id >= oldt.run_id_from
            AND (oldt.run_id_to IS NULL OR oldrun.run_id < oldt.run_id_to)
            AND oldt.qc_code = NEW.qc_code
            AND oldt.app_alias = qc_utility_var.g_app_alias
            AND oldt.object_owner = NVL(qc_utility_var.g_object_owner,USER)
            AND oldt.object_type IN ('TABLE','VIEW','MATERIALIZED VIEW')
            AND NEW.object_name LIKE oldt.object_name||'.%'
          WHERE OLD.msg_ivid IS NULL
           AND ((NEW.object_type NOT IN ('TRIGGER') AND NEW.object_type NOT LIKE '% COLUMN' AND NEW.object_type NOT LIKE 'CONSTRAINT%' AND NEW.object_type NOT LIKE 'INDEX%') OR oldt.msg_ivid IS NOT NULL)
         UNION ALL
         -- Dropped objects
         SELECT REPLACE(OLD.object_type,' COLUMN') object_type2, OLD.object_name, OLD.object_type
              , INITCAP(CASE WHEN NVL(INSTR(OLD.object_type,': '),0)>0 THEN SUBSTR(OLD.object_type,NVL(INSTR(OLD.object_type,': '),0)+2)||' '||SUBSTR(OLD.object_type,1,NVL(INSTR(OLD.object_type,': '),0)-1) ELSE OLD.object_type END)||' '||OLD.object_name
              ||CASE WHEN OLD.object_type LIKE '% COLUMN' THEN ' ('||OLD.msg_text||')' END
              ||' has been removed' msg_text
           FROM oldrun
          INNER JOIN newrun
             ON 1=1
          INNER JOIN qc_run_msgs OLD
             ON oldrun.run_id >= OLD.run_id_from
            AND (OLD.run_id_to IS NULL OR oldrun.run_id < OLD.run_id_to)
            AND OLD.qc_code = 'QC000'
            AND OLD.app_alias = qc_utility_var.g_app_alias
            AND OLD.object_owner = NVL(qc_utility_var.g_object_owner,USER)
           LEFT OUTER JOIN qc_run_msgs NEW
             ON newrun.run_id >= NEW.run_id_from
            AND (NEW.run_id_to IS NULL OR newrun.run_id < NEW.run_id_to)
            AND NEW.qc_code = OLD.qc_code
            AND NEW.app_alias = qc_utility_var.g_app_alias
            AND NEW.object_owner = NVL(qc_utility_var.g_object_owner,USER)
            AND NEW.object_type = OLD.object_type
            AND NEW.object_name = OLD.object_name
           LEFT OUTER JOIN qc_run_msgs newt -- get master object
             ON newrun.run_id >= newt.run_id_from
            AND (newt.run_id_to IS NULL OR newrun.run_id < newt.run_id_to)
            AND newt.qc_code = OLD.qc_code
            AND newt.app_alias = qc_utility_var.g_app_alias
            AND newt.object_owner = NVL(qc_utility_var.g_object_owner,USER)
            AND newt.object_type IN ('TABLE','VIEW','MATERIALIZED VIEW')
            AND OLD.object_name LIKE newt.object_name||'.%'
          WHERE NEW.msg_ivid IS NULL
           AND ((OLD.object_type NOT IN ('TRIGGER') AND OLD.object_type NOT LIKE '% COLUMN' AND OLD.object_type NOT LIKE 'CONSTRAINT%' AND OLD.object_type NOT LIKE 'INDEX%') OR newt.msg_ivid IS NOT NULL)
         UNION ALL
         -- Changed objects
         SELECT REPLACE(OLD.object_type,' COLUMN') object_type2, OLD.object_name, OLD.object_type
              , INITCAP(CASE WHEN NVL(INSTR(OLD.object_type,': '),0)>0 THEN SUBSTR(OLD.object_type,NVL(INSTR(OLD.object_type,': '),0)+2)||' '||SUBSTR(OLD.object_type,1,NVL(INSTR(OLD.object_type,': '),0)-1) ELSE OLD.object_type END)||' '||OLD.object_name
              ||' has changed'
              ||CASE WHEN OLD.object_type LIKE '% COLUMN' THEN ' ('||OLD.msg_text||' -> '||NEW.msg_text||')' END msg_text
           FROM oldrun
          INNER JOIN newrun
             ON 1=1
          INNER JOIN qc_run_msgs OLD
             ON oldrun.run_id >= OLD.run_id_from
            AND (OLD.run_id_to IS NULL OR oldrun.run_id < OLD.run_id_to)
            AND OLD.qc_code = 'QC000'
            AND OLD.app_alias = qc_utility_var.g_app_alias
            AND OLD.object_owner = NVL(qc_utility_var.g_object_owner,USER)
          INNER JOIN qc_run_msgs NEW
             ON newrun.run_id >= NEW.run_id_from
            AND (NEW.run_id_to IS NULL OR newrun.run_id < NEW.run_id_to)
            AND NEW.qc_code = OLD.qc_code
            AND NEW.app_alias = qc_utility_var.g_app_alias
            AND NEW.object_owner = NVL(qc_utility_var.g_object_owner,USER)
            AND NEW.object_type = OLD.object_type
            AND NEW.object_name = OLD.object_name
            AND NEW.msg_ivid != OLD.msg_ivid -- changed
          WHERE NEW.msg_text != OLD.msg_text
          ORDER BY 1, 2, 3
         ;
      l_count INTEGER;
      k_where CONSTANT VARCHAR2(30 CHAR) := 'get_db_changes';
   BEGIN
      -- Determine start run
      IF l_start_run_id IS NULL THEN
         IF p_start_datetime IS NOT NULL THEN
            l_start_datetime := str_to_datetime(p_start_datetime);
            l_start_run_id := get_latest_run_id(l_start_datetime);
         END IF;
         IF l_start_run_id IS NULL THEN
            l_start_run_id := get_min_run_id;
         END IF;
      END IF;
      assert(l_start_run_id IS NOT NULL, 'No start run found!');
      r_start_run := get_run(l_start_run_id);
      assert(r_start_run.run_id=l_start_run_id,'Start run #:1 not found!', k_where, l_start_run_id);
      -- Determine end run
      IF l_end_run_id IS NULL THEN
         IF p_end_datetime IS NOT NULL THEN
            l_end_datetime := str_to_datetime(p_end_datetime);
            l_end_run_id := get_latest_run_id(l_end_datetime);
         END IF;
         IF l_end_run_id IS NULL THEN
            l_end_run_id := get_latest_run_id; -- max(run_id)
         END IF;
      END IF;
      assert(l_end_run_id IS NOT NULL, 'No end run found!');
      r_end_run := get_run(l_end_run_id);
      assert(r_end_run.run_id=l_end_run_id,'End run #:1 not found!', k_where, l_end_run_id);
      -- For each application
      <<app_loop>>
      FOR r_app IN c_app(p_app_alias) LOOP
      qc_utility_var.g_app_alias := r_app.app_alias;
      -- For each application schema (object owner)
      <<own_loop>>
      FOR r_own IN c_own(r_app.app_alias) LOOP
      qc_utility_var.g_object_owner := r_own.object_owner;
      -- Init cache
      init;
      pipe ROW('*** Database changes for Application "'||r_app.app_alias||'" Schema "'||r_own.object_owner||'" Database "'||sys_context('userenv','db_name')
         ||'" made between run #'||r_start_run.run_id||' ('||to_char(NVL(r_start_run.end_time,r_start_run.begin_time),'DD/MM/YYYY HH24:MI:SS')
         ||') and run #'||r_end_run.run_id||' ('||TO_CHAR(NVL(r_end_run.end_time,r_end_run.begin_time),'DD/MM/YYYY HH24:MI:SS')||') ***');
      pipe ROW(NULL);
      <<delta_loop>>
      l_count := 0;
      FOR r_delta IN c_delta(l_start_run_id,l_end_run_id) LOOP
         pipe ROW(r_delta.msg_text);
         l_count := l_count + 1;
      END LOOP delta_loop;
      IF l_count > 0 THEN
         pipe ROW(NULL);
         pipe ROW(l_count||' database change'||CASE WHEN l_count > 1 THEN 's' END||' found.');
      ELSE
         pipe ROW('No database change was found.');
      END IF;
      END LOOP own_loop;
      END LOOP app_loop;
   END get_db_changes;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(30 CHAR) := 'send_db_changes';
      l_start_datetime DATE;
      l_end_datetime DATE;
      l_start_run_id qc_runs.run_id%TYPE := p_start_run_id;
      l_end_run_id qc_runs.run_id%TYPE := p_end_run_id;
      r_start_run qc_runs%ROWTYPE;
      r_end_run qc_runs%ROWTYPE;
      l_server     VARCHAR2(250 CHAR);
      l_sender     VARCHAR2(250 CHAR);
      l_to VARCHAR2(750 CHAR);
      l_cc         VARCHAR2(750 CHAR);
      l_bcc        VARCHAR2(750 CHAR);
      l_subject    VARCHAR2(250 CHAR);
      l_message    CLOB;
      -- Cursor to get applications related to a given run
      CURSOR c_app (
         p_start_run_id IN qc_runs.run_id%TYPE
       , p_end_run_id IN qc_runs.run_id%TYPE
       , p_app_alias qc_apps.app_alias%TYPE
      )
      IS
         SELECT DISTINCT app_alias
           FROM qc_run_msgs
          WHERE qc_code = 'QC000'
            AND (NVL(p_app_alias,'ALL')='ALL' OR app_alias = p_app_alias)
            AND (run_id_from BETWEEN p_start_run_id AND p_end_run_id
              OR run_id_to BETWEEN p_start_run_id AND p_end_run_id)
          ORDER BY 1
      ;
      -- Cusor to get db changes
      CURSOR c_msg (
         p_app_alias qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT COLUMN_VALUE msg_text
           FROM TABLE(qc_utility_krn.get_db_changes(p_start_datetime,p_end_datetime,p_start_run_id,p_end_run_id,p_app_alias))
      ;
      k_crlf CONSTANT VARCHAR2(2 CHAR) := CHR(13)||CHR(10);
      -- Send an email of a size potentially >32k
      PROCEDURE send_email IS
      BEGIN
         mail_utility_krn.send_mail_over32k(
            p_sender     => l_sender
          , p_recipients => l_to
          , p_cc         => l_cc
          , p_bcc        => l_bcc
          , p_subject    => l_subject
          , p_message    => l_message
          , p_priority   => 3
          , p_force_send_on_non_prod_env=>TRUE
          );
      EXCEPTION
         -- SMTP problem should not result into an error
         -- Exception is not re-raised (please ignore PLW-06009)
         WHEN OTHERS THEN
            sys.dbms_output.put_line('SMTP problem: '||sys.dbms_utility.format_error_stack);
            sys.dbms_output.put_line('SMTP problem: '||sys.dbms_utility.format_error_backtrace);
      END;
   BEGIN
      -- Determine start run
      IF l_start_run_id IS NULL THEN
         IF p_start_datetime IS NOT NULL THEN
            l_start_datetime := str_to_datetime(p_start_datetime);
            l_start_run_id := get_latest_run_id(l_start_datetime);
         END IF;
         IF l_start_run_id IS NULL THEN
            l_start_run_id := get_min_run_id;
         END IF;
      END IF;
      assert(l_start_run_id IS NOT NULL, 'No start run found!');
      r_start_run := get_run(l_start_run_id);
      assert(r_start_run.run_id=l_start_run_id,'Start run #:1 not found!', k_where, l_start_run_id);
      -- Determine end run
      IF l_end_run_id IS NULL THEN
         IF p_end_datetime IS NOT NULL THEN
            l_end_datetime := str_to_datetime(p_end_datetime);
            l_end_run_id := get_latest_run_id(l_end_datetime);
         END IF;
         IF l_end_run_id IS NULL THEN
            l_end_run_id := get_latest_run_id; -- max(run_id)
         END IF;
      END IF;
      assert(l_end_run_id IS NOT NULL, 'No end run found!');
      r_end_run := get_run(l_end_run_id);
      assert(r_end_run.run_id=l_end_run_id,'End run #:1 not found!', k_where, l_end_run_id);
      -- Get email parameters
      l_server := NVL(get_dictionary_entry('PARAMETER','EMAIL SERVER'),'localhost');
      l_sender := NVL(get_dictionary_entry('PARAMETER','EMAIL SENDER'),'AUTOMATED DB QUALITY CHECK <automated-notifications@nomail.ec.europa.eu>');
      l_to := COALESCE(p_to,get_app_dict_entry('ALL','PARAMETER','EMAIL RECIPIENTS'));
      l_cc := COALESCE(p_cc,get_app_dict_entry('ALL','PARAMETER','EMAIL CC'));
      l_bcc := COALESCE(p_bcc,get_app_dict_entry('ALL','PARAMETER','EMAIL BCC'));
      mail_utility_krn.set_is_prod('Y');
      -- If email params are defined for ALL applications...
      -- and not invoked for a specific application
      IF (l_to IS NOT NULL OR l_cc IS NOT NULL OR l_bcc IS NOT NULL)
      AND NVL(p_app_alias,'ALL') = 'ALL'
      THEN
         -- Send a single email for all applications
         l_message := NULL;
         <<msg_loop>>
         FOR r_msg IN c_msg LOOP
            IF NVL(p_force_send,'N') = 'N' AND r_msg.msg_text = 'No database change was found.' THEN
               -- Don't send email if no change made!
               RETURN;
            END IF;
            l_message := l_message || r_msg.msg_text || k_crlf;
         END LOOP msg_loop;
         l_subject := 'Database changes for Database "'||sys_context('userenv','db_name')||'"'
         ||CASE WHEN p_start_run_id IS NOT NULL THEN ' since run #'||p_start_run_id
                WHEN p_start_datetime IS NOT NULL THEN ' since '||TO_CHAR(str_to_datetime(p_start_datetime),'DD/MM/YYYY HH24:MI:SS')
                ELSE ' since the dawn of time'
           END
         ||CASE WHEN p_end_run_id IS NOT NULL THEN ' until run #'||p_end_run_id
                WHEN p_end_datetime IS NOT NULL THEN ' until '||TO_CHAR(str_to_datetime(p_end_datetime),'DD/MM/YYYY HH24:MI:SS')
                ELSE ' until now'
           END
         ;
         send_email;
      ELSE
         -- Send one email per application
         <<app_loop>>
         FOR r_app in c_app(l_start_run_id,l_end_run_id,p_app_alias) LOOP
            l_to := COALESCE(l_to,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL RECIPIENTS'));
            l_cc := COALESCE(l_cc,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL CC'));
            l_bcc := COALESCE(l_bcc,get_app_dict_entry(r_app.app_alias,'PARAMETER','EMAIL BCC'));
            IF l_to IS NOT NULL OR l_cc IS NOT NULL OR l_bcc IS NOT NULL THEN
               l_message := NULL;
               <<msg_loop>>
               FOR r_msg IN c_msg(r_app.app_alias) LOOP
                  IF NVL(p_force_send,'N') = 'N' AND r_msg.msg_text = 'No database change was found.' THEN
                     -- Don't send email if no change made!
                     GOTO next_app;
                  END IF;
                  l_message := l_message || r_msg.msg_text || k_crlf;
               END LOOP msg_loop;
               l_subject := 'Database changes for Application "'||r_app.app_alias||' Database"'||sys_context('userenv','db_name')||'"'
               ||CASE WHEN p_start_run_id IS NOT NULL THEN ' since run #'||p_start_run_id
                      WHEN p_start_datetime IS NOT NULL THEN ' since '||TO_CHAR(str_to_datetime(p_start_datetime),'DD/MM/YYYY HH24:MI:SS')
                      ELSE ' since the dawn of time'
                 END
               ||CASE WHEN p_end_run_id IS NOT NULL THEN ' until run #'||p_end_run_id
                      WHEN p_end_datetime IS NOT NULL THEN ' until '||TO_CHAR(str_to_datetime(p_end_datetime),'DD/MM/YYYY HH24:MI:SS')
                      ELSE ' until now'
                 END
               ;
               send_email;
            END IF;
            <<next_app>>
            NULL;
         END LOOP app_loop;
      END IF;
   END send_db_changes;
--#begin public
   PROCEDURE check_all (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
    , p_app_alias IN qc_apps.app_alias%TYPE := NULL
   )
--#end public
   IS
      l_run_id qc_runs.run_id%TYPE;
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on application schemas
      CURSOR c_own (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT dict_value object_owner
           FROM qc_dictionary_entries
          WHERE dict_name = 'APP SCHEMA'
            AND app_alias = p_app_alias
          ORDER BY dict_value
      ;
      -- Cursor to loop on quality checks
      CURSOR c_chk (
         p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
      )
      IS
         SELECT *
           FROM qc_checks
          WHERE (p_qc_code IS NULL OR qc_code = p_qc_code)
          ORDER BY qc_code
      ;
      -- Cursor to determine which quality check to execute
      CURSOR c_pat IS
         SELECT *
           FROM qc_patterns
    --AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE object_type = 'QUALITY CHECK'
      ;
      r_pat c_pat%ROWTYPE;
      l_found BOOLEAN;
      l_msg_count qc_runs.msg_count%TYPE;
      PROCEDURE finally (
         p_status IN qc_runs.status%TYPE
      )
      IS
      BEGIN
         -- Terminate run
         UPDATE qc_runs
            SET end_time = SYSDATE
              , msg_count = l_msg_count
              , status = p_status
          WHERE run_id = l_run_id
         ;
         -- Save
         COMMIT
         ;
      END finally;
   BEGIN
      -- Register run
      INSERT INTO qc_runs (
         run_id, begin_time, status
      ) VALUES (
         qc_run_seq.NEXTVAL, SYSDATE, 'RUNNING'
      )
      RETURN run_id INTO l_run_id
      ;
      qc_utility_var.g_run_id := l_run_id;
      -- Save
      COMMIT;
      -- Lock run to prevent parallel runs
      LOCK TABLE qc_runs IN EXCLUSIVE MODE;
      -- Get quality check pattern
      OPEN c_pat;
      FETCH c_pat INTO r_pat;
      l_found := c_pat%FOUND;
      CLOSE c_pat;
      assert(l_found,'QUALITY CHECK pattern not found!');
      -- For each application
      <<app_loop>>
      FOR r_app IN c_app(p_app_alias) LOOP
      qc_utility_var.g_app_alias := r_app.app_alias;
      -- For each application schema (object owner)
      <<own_loop>>
      FOR r_own IN c_own(r_app.app_alias) LOOP
      qc_utility_var.g_object_owner := r_own.object_owner;
      -- Init cache
      init;
      -- For each quality check
      <<chk_loop>>
      FOR r_chk IN c_chk(p_qc_code) LOOP
         -- If QC is included and not excluded according to the pattern
          IF p_qc_code IS NOT NULL
          OR ((r_pat.include_pattern IS NULL OR ext_regexp_like('QUALITY CHECK',NVL(qc_utility_var.g_object_owner,USER),r_chk.qc_code, r_pat.include_pattern) = 1)
         AND  (r_pat.exclude_pattern IS NULL OR ext_regexp_like('QUALITY CHECK',NVL(qc_utility_var.g_object_owner,USER),r_chk.qc_code, r_pat.exclude_pattern) = 0))
         THEN
            -- Start with an empty list of messages and statistics
            qc_utility_var.t_msg.DELETE;
            qc_utility_var.t_msg_upd.DELETE;
            qc_utility_var.t_stat.DELETE;
            -- Load messages from last run into a hash table
            DECLARE
               t_msg qc_utility_msg.msg_table;
               r_msg qc_run_msgs%ROWTYPE;
            BEGIN
               qc_utility_var.g_msg.DELETE;
               qc_utility_msg.load_msg(t_msg=>t_msg,p_qc_code=>r_chk.qc_code,p_app_alias=>qc_utility_var.g_app_alias,p_object_owner=>NVL(qc_utility_var.g_object_owner,USER),p_run_id=>l_run_id);
               <<msg_loop>>
               FOR i IN 1..t_msg.count LOOP
                  r_msg := t_msg(i);
                  qc_utility_var.g_msg(r_msg.qc_code||'#'||r_msg.object_type||'#'||r_msg.object_name) := r_msg;
               END LOOP msg_loop;
            END;
            -- Run quality check
            CASE r_chk.qc_code
               WHEN 'QC000' THEN qc000(r_chk.msg_type);
               WHEN 'QC001' THEN qc001(r_chk.msg_type);
               WHEN 'QC002' THEN qc002(r_chk.msg_type);
--               WHEN 'QC003' THEN qc003(r_chk.msg_type);
               WHEN 'QC004' THEN qc004(r_chk.msg_type);
               WHEN 'QC005' THEN qc005(r_chk.msg_type);
--               WHEN 'QC006' THEN qc006(r_chk.msg_type);
               WHEN 'QC007' THEN qc007(r_chk.msg_type);
               WHEN 'QC008' THEN qc008(p_msg_type=>r_chk.msg_type,p_anti_pattern=>'N');
               WHEN 'QC009' THEN qc009(r_chk.msg_type);
               WHEN 'QC010' THEN qc010(r_chk.msg_type);
               WHEN 'QC011' THEN qc011(r_chk.msg_type);
               WHEN 'QC012' THEN qc012(r_chk.msg_type);
               WHEN 'QC013' THEN qc013(r_chk.msg_type);
               WHEN 'QC014' THEN qc014(r_chk.msg_type);
               WHEN 'QC015' THEN qc015(r_chk.msg_type);
               WHEN 'QC016' THEN qc016(r_chk.msg_type);
               WHEN 'QC017' THEN qc017(r_chk.msg_type);
               WHEN 'QC018' THEN qc018(r_chk.msg_type);
               WHEN 'QC019' THEN qc019(r_chk.msg_type);
               WHEN 'QC020' THEN qc008(p_msg_type=>r_chk.msg_type,p_anti_pattern=>'Y');
               WHEN 'QC021' THEN qc021(r_chk.msg_type);
               WHEN 'QC022' THEN qc022(r_chk.msg_type);
               ELSE GOTO next_qc;
            END CASE;
            -- Update existing messages
--dbms_output.put_line('messages updated: '||qc_utility_var.t_msg_upd.COUNT);
            <<msg_upd_loop>>
            FOR i IN 1..qc_utility_var.t_msg_upd.COUNT LOOP
               UPDATE qc_run_msgs
                  SET msg_text = qc_utility_var.t_msg_upd(i).msg_text
                    , msg_type = qc_utility_var.t_msg_upd(i).msg_type
                WHERE msg_ivid = qc_utility_var.t_msg_upd(i).msg_ivid
               ;
            END LOOP msg_upd_loop;
            -- Create new messages and delete obsolete ones
            qc_utility_msg.save_msg(t_msg=>qc_utility_var.t_msg,p_qc_code=>r_chk.qc_code,p_app_alias=>qc_utility_var.g_app_alias,p_object_owner=>NVL(qc_utility_var.g_object_owner,USER),p_run_id=>l_run_id);
            -- Save statistics
            qc_utility_stat.save_stat(t_stat=>qc_utility_var.t_stat,p_qc_code=>r_chk.qc_code,p_app_alias=>qc_utility_var.g_app_alias,p_object_owner=>NVL(qc_utility_var.g_object_owner,USER),p_run_id=>l_run_id);
         END IF;
         <<next_qc>>
         NULL;
      END LOOP chk_loop;
      END LOOP own_loop;
      END LOOP app_loop;
      l_msg_count := send_report(p_run_id=>l_run_id,p_app_alias=>p_app_alias);
      finally(qc_utility_var.gk_success);
--   EXCEPTION
--      WHEN OTHERS THEN
--         finally(qc_utility_var.gk_failure);
--         sys.dbms_output.put_line(sys.dbms_utility.format_error_backtrace);
--         sys.dbms_output.put_line(sys.dbms_utility.format_error_stack);
--         RAISE;
   END check_all;
--#begin public
   ---
   -- Perform one check
   ---
   PROCEDURE check_one (
      p_qc_code IN qc_run_msgs.qc_code%TYPE
    , p_app_alias IN qc_apps.app_alias%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      check_all(p_qc_code,p_app_alias);
   END check_one;
--#begin public
   ---
   -- Run quality checks if DDL detected since last run
   ---
   PROCEDURE run_if_ddl_detected
--#end public
   IS
      -- Get time of last run
      CURSOR c_run (
         p_status IN qc_runs.status%TYPE
      )
      IS
         SELECT begin_time
           FROM qc_runs
          WHERE status = p_status
          ORDER BY run_id DESC
      ;
      -- Get time of most recent DDL on monitored objects
      CURSOR c_ddl IS
         SELECT MAX(obj.last_ddl_time) last_ddl_time
           FROM all_objects obj
          INNER JOIN qc_patterns pat
             ON pat.object_type = obj.object_type
            AND pat.app_alias IN ('ALL', qc_utility_var.g_app_alias)
          WHERE obj.owner = NVL(qc_utility_var.g_object_owner,USER)
            AND (pat.check_pattern IS NOT NULL OR pat.include_pattern IS NOT NULL OR pat.exclude_pattern IS NOT NULL)
            AND (pat.include_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.include_pattern)=1)
            AND (pat.exclude_pattern IS NULL OR qc_utility_krn.ext_regexp_like(pat.object_type,obj.owner,obj.object_name,pat.exclude_pattern)=0)
         ;
      l_last_run_time DATE;
      l_last_ddl_time DATE;
   BEGIN
      -- Get time of last run
      OPEN c_run(qc_utility_var.gk_success);
      FETCH c_run INTO l_last_run_time;
      CLOSE c_run;
      sys.dbms_output.put_line('Last run time: '||TO_CHAR(l_last_run_time,'DD/MM/YYYY HH24:MI:SS'));
      -- Get time of most recente DDL (limited to monitored objects)
      OPEN c_ddl;
      FETCH c_ddl INTO l_last_ddl_time;
      CLOSE c_ddl;
      sys.dbms_output.put_line('Last DDL time: '||TO_CHAR(l_last_ddl_time,'DD/MM/YYYY HH24:MI:SS'));
      -- Changes since last run?
      IF l_last_run_time IS NULL OR l_last_ddl_time > l_last_run_time THEN
         sys.dbms_output.put_line('Running...');
         check_all;
      END IF;
   END run_if_ddl_detected;
   -- Fix object
   PROCEDURE fix_object (
      p_op IN VARCHAR2
    , p_object_type IN VARCHAR2
    , p_owner IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_fix_type IN VARCHAR2
    , p_fix_name IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_extra_name IN VARCHAR2 := NULL
    , po_fix_status OUT NOCOPY VARCHAR2
    , po_fix_msg OUT NOCOPY VARCHAR2
    , pio_fix_ddl IN OUT NOCOPY VARCHAR2
   )
   IS
   BEGIN
      -- Generate DDL if not already set
      IF pio_fix_ddl IS NULL THEN
         pio_fix_ddl := gen_fix_ddl(p_op, p_object_type, p_owner, p_object_name
                                 ,p_fix_type, p_fix_name, p_table_name
                                 ,p_extra_name);
      END IF;
      -- Execute DDL if not empty and return outcome and error message if any
      IF pio_fix_ddl IS NOT NULL THEN
         BEGIN
            log_utility.log_message('I',pio_fix_ddl);
            EXECUTE IMMEDIATE pio_fix_ddl ;
            po_fix_msg := NULL;
            po_fix_status := qc_utility_var.gk_success;
         EXCEPTION
            -- Exception is not re-raised (PLW-06009 must be ignored)
            WHEN OTHERS THEN
               po_fix_msg := SQLERRM;
               po_fix_status := qc_utility_var.gk_failure;
         END;
      END IF;
   END fix_object;
--#begin public
   ---
   -- Fix PL/SQL anomalies
   ---
   PROCEDURE fix_plsql_anomalies (
      p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
   )
--#end public
   IS
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on application schemas
      CURSOR c_own (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT dict_value object_owner
           FROM qc_dictionary_entries
          WHERE dict_name = 'APP SCHEMA'
            AND app_alias = p_app_alias
          ORDER BY dict_value
      ;
      -- Cursor to loop on anomalies
      CURSOR c_fix IS
         SELECT ord.object_order, err.*
           FROM (
               SELECT DISTINCT -- distinct because there are 2 possible simultaneous usages: REFERENCE and ASSIGNMENT
                     CASE WHEN usage.object_type IN ('PACKAGE','TYPE') THEN 1 WHEN usage.object_type = 'TRIGGER' THEN 3 ELSE 2 END seq
                    , usage.object_type, usage.object_name
                    , usage.line, usage.col
                    , decl.fix_name
                    , usage.owner, usage.name
                 FROM qc_run_msgs decl
                INNER JOIN all_identifiers usage
                   ON usage.owner = SUBSTR(decl.object_name,1,NVL(INSTR(decl.object_name,'.'),0)-1)
   --               AND usage.name = SUBSTR(decl.object_name,NVL(INSTR(decl.object_name,'.'),0)+1,NVL(INSTR(decl.object_name,'#'),0)-NVL(INSTR(decl.object_name,'.'),0)-1)
                  AND usage.signature = SUBSTR(decl.object_name,NVL(INSTR(decl.object_name,'#'),0)+1)
                WHERE decl.app_alias = qc_utility_var.g_app_alias
                  AND decl.object_owner = NVL(qc_utility_var.g_object_owner,USER)
                  AND decl.qc_code = 'QC019'
                  AND decl.run_id_to IS NULL
                  AND decl.fix_name IS NOT NULL
   --               AND decl.type NOT IN ('PACKAGE', 'PROCEDURE', 'FUNCTION') -- ???
                UNION ALL
               -- Add missing links between named parameters (e.g. p_param => <value>) and referenced parameters
               -- Limitation: parameters located more than 4 lines away from the procedure call will be ignored!
               SELECT CASE WHEN proc_call.object_type IN ('PACKAGE','TYPE') THEN 1 WHEN proc_call.object_type = 'TRIGGER' THEN 3 ELSE 2 END seq
                    , proc_call.object_type, proc_call.object_name
                    , COALESCE(src0.line,src1.line,src2.line,src3.line) line
                    , NVL(regexp_instr(COALESCE(src0.text,src1.text,src2.text,src3.text,src4.text), param.name||'[ '||CHR(9)||']*=>',1,1,0,'i'),0) col
                    , decl.fix_name
                    , proc_call.owner, param.name
                 FROM qc_run_msgs decl -- wrongly named parameters
                INNER JOIN all_identifiers param -- parameter declaration
                   ON param.owner = SUBSTR(decl.object_name,1,NVL(INSTR(decl.object_name,'.'),0)-1)
                  AND param.signature = SUBSTR(decl.object_name,NVL(INSTR(decl.object_name,'#'),0)+1)
                  AND param.usage = 'DECLARATION'
                  AND param.object_type NOT IN ('PACKAGE','TYPE') -- not in specifications
                INNER JOIN all_identifiers proc_def -- procedure definition
                   ON proc_def.owner = param.owner
                  AND proc_def.object_type = param.object_type
                  AND proc_def.object_name = param.object_name
                  AND proc_def.usage_id = param.usage_context_id
                INNER JOIN all_identifiers proc_call -- procedure calls
                   ON proc_call.owner = proc_def.owner
                  AND proc_call.signature = proc_def.signature
                  AND proc_call.name = proc_def.name
                  AND proc_call.usage = 'CALL'
         --       For performance reason, the following inner join was replaced by 5 left outer joins
         --       INNER JOIN all_source src
         --          ON src.owner = proc_call.owner
         --         AND src.type = proc_call.object_type
         --         AND src.name = proc_call.object_name
         --         AND src.line BETWEEN proc_call.line AND proc_call.line + 4
         --         AND regexp_like(src.text,param.name||'[ '||CHR(9)||']*=>','i')
                 LEFT OUTER JOIN all_source src0
                   ON src0.owner = proc_call.owner
                  AND src0.type = proc_call.object_type
                  AND src0.name = proc_call.object_name
                  AND src0.line = proc_call.line -- + 0
                  AND regexp_like(src0.text,param.name||'[ '||CHR(9)||']*=>','i')
                 LEFT OUTER JOIN all_source src1
                   ON src1.owner = proc_call.owner
                  AND src1.type = proc_call.object_type
                  AND src1.name = proc_call.object_name
                  AND src1.line = proc_call.line + 1
                  AND regexp_like(src1.text,param.name||'[ '||CHR(9)||']*=>','i')
                 LEFT OUTER JOIN all_source src2
                   ON src2.owner = proc_call.owner
                  AND src2.type = proc_call.object_type
                  AND src2.name = proc_call.object_name
                  AND src2.line = proc_call.line + 2
                  AND regexp_like(src2.text,param.name||'[ '||CHR(9)||']*=>','i')
                 LEFT OUTER JOIN all_source src3
                   ON src3.owner = proc_call.owner
                  AND src3.type = proc_call.object_type
                  AND src3.name = proc_call.object_name
                  AND src3.line = proc_call.line + 3
                  AND regexp_like(src3.text,param.name||'[ '||CHR(9)||']*=>','i')
                 LEFT OUTER JOIN all_source src4
                   ON src4.owner = proc_call.owner
                  AND src4.type = proc_call.object_type
                  AND src4.name = proc_call.object_name
                  AND src4.line = proc_call.line + 4
                  AND regexp_like(src4.text,param.name||'[ '||CHR(9)||']*=>','i')
                WHERE decl.app_alias = qc_utility_var.g_app_alias
                  AND decl.object_owner = NVL(qc_utility_var.g_object_owner,USER)
                  AND decl.qc_code = 'QC019'
                  AND decl.run_id_to IS NULL
                  AND decl.msg_text LIKE '% parameter %'
                  AND decl.fix_name IS NOT NULL
                  AND COALESCE(src0.line,src1.line,src2.line,src3.line,src4.line) IS NOT NULL
             ) err
          INNER JOIN table(qc_utility_krn.sorted_objects) ord
             ON ord.object_type = err.object_type
            AND ord.object_name = err.object_name
          ORDER BY err.seq, ord.object_order DESC, err.line, err.col
          ;
      t_lines dbms_sql.varchar2a;
      l_owner all_source.owner%TYPE;
      l_type all_source.type%TYPE;
      l_name all_source.name%TYPE;
      l_text VARCHAR2(4000 CHAR);
      l_line INTEGER := 0;
      l_col INTEGER := 0;
      l_len INTEGER;
      ---
      -- Read object source code
      ---
      PROCEDURE read_source (
         p_owner IN VARCHAR2
       , p_type IN VARCHAR2
       , p_name IN VARCHAR2
      )
      IS
         CURSOR c_src (
            p_owner IN VARCHAR2
          , p_type IN VARCHAR2
          , p_name IN VARCHAR2
         )
         IS
            SELECT RTRIM(text,CHR(10)) text
              FROM all_source
             WHERE owner = UPPER(p_owner)
               AND type = UPPER(p_type)
               AND name = UPPER(p_name)
             ORDER BY line
         ;
      BEGIN
         t_lines.DELETE;
         <<src_loop>>
         FOR r_src IN c_src(p_owner, p_type, p_name) LOOP
            t_lines(t_lines.COUNT+1) := r_src.text;
         END LOOP src_loop;
      END read_source;
/*
      PROCEDURE show_source IS
      BEGIN
         <<idx_loop>>
         FOR l_idx IN 1..t_lines.COUNT LOOP
            sys.dbms_output.put_line(t_lines(l_idx));
         END LOOP idx_loop;
      END show_source;
*/
      FUNCTION show_errors (
         p_owner IN VARCHAR2
        ,p_type IN VARCHAR2
        ,p_name IN VARCHAR2
      )
      RETURN INTEGER
      IS
         -- Cursor to get compilation error messages
         CURSOR c_err (
            p_owner IN VARCHAR2
           ,p_type IN VARCHAR2
           ,p_name IN VARCHAR2
         ) IS
            SELECT ATTRIBUTE||' at line '||line||' col '||position||': '||text msg
              FROM all_errors
             WHERE OWNER = UPPER(p_owner)
               AND TYPE=UPPER(p_type)
               AND NAME=UPPER(p_name)
             ORDER BY SEQUENCE
         ;
         l_err_count INTEGER := 0;
      BEGIN
         <<err_loop>>
         FOR r_err IN c_err(p_owner,p_type,p_name) LOOP
   --         IF l_err_count = 0 THEN
   --            log('KO');
   --         END IF;
            l_err_count := l_err_count + 1;
            sys.dbms_output.put_line(r_err.msg);
         END LOOP err_loop;
         RETURN l_err_count;
      END show_errors;
      PROCEDURE compile_source (
         p_owner IN VARCHAR2
        ,p_type IN VARCHAR2
        ,p_name IN VARCHAR2
      )
      IS
         l_count INTEGER;
         l_err INTEGER;
      BEGIN
         IF l_owner IS NOT NULL AND l_type IS NOT NULL AND l_name IS NOT NULL AND t_lines.COUNT>0 THEN
            log_utility.log_message('I','Compiling '||p_owner||'.'||p_type||' '||p_name||'...');
            t_lines(0) := 'CREATE OR REPLACE';
            -- Add owner to procedure/function/package name
            IF t_lines.EXISTS(1) THEN
               IF t_lines(1) LIKE 'PACKAGE BODY%' THEN
                  t_lines(1) := REPLACE(t_lines(1),'PACKAGE BODY ','PACKAGE BODY '||p_owner||'.');
               ELSE
                  t_lines(1) := REPLACE(t_lines(1),'PACKAGE ','PACKAGE '||p_owner||'.');
                  t_lines(1) := REPLACE(t_lines(1),'PROCEDURE ','PROCEDURE '||p_owner||'.');
                  t_lines(1) := REPLACE(t_lines(1),'FUNCTION ','FUNCTION '||p_owner||'.');
               END IF;
            END IF;
            -- Debug
--            FOR i IN t_lines.FIRST..t_lines.LAST LOOP
--               dbms_output.put_line(t_lines(i));
--            END LOOP;
            -- Execute statement
            DECLARE
               l_cursor INTEGER;
            BEGIN
               l_cursor := sys.dbms_sql.open_cursor;
               sys.dbms_sql.parse(l_cursor, t_lines, t_lines.FIRST, t_lines.LAST, TRUE, sys.dbms_sql.native);
               l_count := sys.dbms_sql.execute(l_cursor);
               sys.dbms_sql.close_cursor(l_cursor);
            EXCEPTION
               WHEN OTHERS THEN
                  IF dbms_sql.is_open(l_cursor) THEN
                     sys.dbms_sql.close_cursor(l_cursor);
                  END IF;
                  RAISE;
            END;
            -- Show error messages
            l_err := show_errors(p_owner,p_type,p_name);
            assert(l_err=0,'compile_source','Compilation of :1 :2 :3 failed',NULL,p_owner,p_type,p_name);
            log_utility.log_message('I','Compilation of '||p_owner||'.'||p_type||' '||p_name||' succeeded');
            -- Update fix status
            UPDATE qc_run_msgs
               SET fix_status = qc_utility_var.gk_success
--                 , fix_msg = r_msg.fix_msg
--                 , fix_ddl = r_msg.fix_ddl
                 , fix_time = SYSDATE
                 , fix_locked = 'Y'
             WHERE run_id_to IS NULL
               AND qc_code = 'QC019'
               AND object_type = p_type
               AND object_name LIKE p_owner||'.'||p_name||'%'
            ;
         END IF;
      END compile_source;
      PROCEDURE initially$ IS -- $ suffix added as "initially" is a reserved word
      BEGIN
         -- Prevent subsequent compilations from changing "all_identifiers" view while being queried
         disable_plscope;
      END initially$;
      PROCEDURE finally IS
      BEGIN
         -- Restore plscope settings to what they should be by default
         enable_plscope;
      END finally;
   BEGIN
      initially$;
      -- For each application
      <<app_loop>>
      FOR r_app IN c_app(p_app_alias) LOOP
      qc_utility_var.g_app_alias := r_app.app_alias;
      -- For each application schema (object owner)
      <<own_loop>>
      FOR r_own IN c_own(r_app.app_alias) LOOP
      qc_utility_var.g_object_owner := r_own.object_owner;
      -- Init cache
      init;
      -- For each anomaly
      <<fix_loop>>
      FOR r_fix IN c_fix LOOP
         -- If break detected
         IF r_fix.owner != NVL(l_owner,'~')
         OR r_fix.object_type != NVL(l_type,'~')
         OR r_fix.object_name != NVL(l_name,'~')
         THEN
            compile_source(l_owner,l_type,l_name);
            read_source(r_fix.owner,r_fix.object_type,r_fix.object_name);
            l_line := 0;
            l_col := 0;
         END IF;
         -- Reset column offset if new line
         IF r_fix.line != l_line THEN
            l_col := 0;
         END IF;
         -- Check that line does contain expected variable
         l_len := NVL(LENGTH(r_fix.name),0);
         assert(UPPER(SUBSTR(t_lines(r_fix.line),r_fix.col+l_col,l_len)) = r_fix.name
              ,NULL,'Variable ":1" not found in :2 :3 at line :4 col :5'||CHR(10)||t_lines(r_fix.line),NULL
              , r_fix.name, r_fix.object_type, r_fix.object_name, r_fix.line, r_fix.col+l_col);
         -- Log substitution
         log_utility.log_message('D','Variable "'||r_fix.name||'" substituted with "'||r_fix.fix_name||'" in '
                               ||r_fix.object_type||' '||r_fix.object_name
                               ||' at line '||r_fix.line||' col '||r_fix.col);
         -- Substitute variable to rename
         l_text := t_lines(r_fix.line);
         l_text := SUBSTR(l_text,1,r_fix.col+l_col-1)||r_fix.fix_name||SUBSTR(l_text,r_fix.col+l_col+l_len);
         t_lines(r_fix.line) := l_text;
         -- Save info about last treated record to detect break
         l_owner := r_fix.owner;
         l_type := r_fix.object_type;
         l_name := r_fix.object_name;
         l_line := r_fix.line;
         -- Set column offset (needed when line has more than 1 variable to replace)
         l_col := l_col - l_len + NVL(LENGTH(r_fix.fix_name),0);
         -- Update fix info
      END LOOP fix_loop;
      -- Force last break
      compile_source(l_owner,l_type,l_name);
      END LOOP own_loop;
      END LOOP app_loop;
      -- Terminate properly
      finally;
   EXCEPTION
      WHEN OTHERS THEN
         -- Terminate properly
         finally;
   END fix_plsql_anomalies;
--#begin public
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
--#end public
   IS
      -- Cursor to loop on applications
      CURSOR c_app (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT app_alias
           FROM qc_apps
          WHERE (NVL(p_app_alias,'ALL') = 'ALL' OR app_alias = p_app_alias)
            AND app_alias != 'ALL'
          ORDER BY app_alias
      ;
      -- Cursor to loop on application schemas
      CURSOR c_own (
         p_app_alias IN qc_apps.app_alias%TYPE := NULL
      )
      IS
         SELECT dict_value object_owner
           FROM qc_dictionary_entries
          WHERE dict_name = 'APP SCHEMA'
            AND app_alias = p_app_alias
          ORDER BY dict_value
      ;
      -- Cursor to loop on anomalies
      CURSOR c_msg (
         p_qc_code IN qc_run_msgs.qc_code%TYPE
       , p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
       , p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
       , p_object_type IN qc_run_msgs.object_type%TYPE := NULL
       , p_object_name IN qc_run_msgs.object_name%TYPE := NULL
       , p_fix_op IN qc_run_msgs.fix_op%TYPE := NULL
       , p_msg_type IN qc_run_msgs.msg_type%TYPE := NULL
      )
      IS
         SELECT *
           FROM qc_run_msgs msg
          WHERE msg.qc_code = p_qc_code
            AND app_alias = p_app_alias
            AND object_owner = p_object_owner
            AND (p_object_type IS NULL OR msg.object_type LIKE p_object_type)
            AND (p_object_name IS NULL OR msg.object_name LIKE p_object_name)
            AND (p_msg_type IS NULL OR msg.msg_type LIKE p_msg_type)
            AND (p_fix_op IS NULL OR msg.fix_op LIKE p_fix_op)
            AND msg.run_id_to IS NULL -- latest version
            AND msg.fix_op IS NOT NULL
            AND (msg.fix_name IS NOT NULL OR msg.fix_op IN ('ENABLE','DISABLE','COMPILE'))
            AND msg.fix_status IS NULL -- not processed yet
          ORDER BY qc_code, sort_order, object_type, object_name
      ;
      l_table_name VARCHAR2(100 CHAR);
      l_object_name VARCHAR2(100 CHAR);
      l_extra_name VARCHAR2(100 CHAR);
   BEGIN
      IF p_qc_code = 'QC019' THEN
         fix_plsql_anomalies(p_app_alias);
      ELSE
         -- For each application
         <<app_loop>>
         FOR r_app IN c_app(p_app_alias) LOOP
         qc_utility_var.g_app_alias := r_app.app_alias;
         -- For each application schema (object owner)
         <<own_loop>>
         FOR r_own IN c_own(r_app.app_alias) LOOP
         qc_utility_var.g_object_owner := r_own.object_owner;
         -- Init cache
         init;
         -- For each anomaly
         <<msg_loop>>
         FOR r_msg IN c_msg(p_qc_code,r_app.app_alias,r_own.object_owner,p_object_type,p_object_name,p_fix_op,p_msg_type) LOOP
            split_string(r_msg.object_name, l_object_name, l_extra_name, '#', 1);
            decompose_name(r_msg.object_type, l_object_name, l_table_name, l_object_name, '.');
            -- TBD: check that the fix name matches the check pattern
            fix_object (
                 r_msg.fix_op, r_msg.object_type, r_msg.object_owner, LOWER(l_object_name), NVL(r_msg.fix_type,r_msg.object_type)
               , LOWER(replace_vars(r_msg.object_type, r_msg.object_owner, r_msg.object_name, r_msg.fix_name))
               , LOWER(l_table_name), l_extra_name, r_msg.fix_status, r_msg.fix_msg, r_msg.fix_ddl
            );
            IF r_msg.fix_status IS NOT NULL THEN
               UPDATE qc_run_msgs
                  SET fix_status = r_msg.fix_status
                    , fix_msg = r_msg.fix_msg
                    , fix_ddl = r_msg.fix_ddl
                    , fix_time = SYSDATE
                    , fix_locked = 'Y'
                WHERE run_id_to IS NULL
                  AND qc_code = r_msg.qc_code
                  AND object_type = r_msg.object_type
                  AND object_name = r_msg.object_name
               ;
            END IF;
         END LOOP msg_loop;
         END LOOP own_loop;
         END LOOP app_loop;
      END IF;
   END fix_anomalies;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(18) := 'insert_pattern(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_object_type IS NULL THEN
         raise_application_error(-20000,k_where||'object type cannot be NULL');
      END IF;
      INSERT INTO qc_patterns (
         app_alias
       , object_type, check_pattern, include_pattern
       , exclude_pattern, fix_pattern, anti_pattern
       , msg_type
      ) VALUES (
         p_app_alias
       , p_object_type, p_check_pattern, p_include_pattern
       , p_exclude_pattern, p_fix_pattern, p_anti_pattern
       , p_msg_type
      );
   END insert_pattern;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(18) := 'update_pattern(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_object_type IS NULL THEN
         raise_application_error(-20000,k_where||'object type cannot be NULL');
      END IF;
      UPDATE qc_patterns
         SET check_pattern = DECODE(p_check_pattern,'NULL',NULL,NVL(p_check_pattern,check_pattern))
           , include_pattern = DECODE(p_include_pattern,'NULL',NULL,NVL(p_include_pattern,include_pattern))
           , exclude_pattern = DECODE(p_exclude_pattern,'NULL',NULL,NVL(p_exclude_pattern,exclude_pattern))
           , fix_pattern = DECODE(p_fix_pattern,'NULL',NULL,NVL(p_fix_pattern,fix_pattern))
           , anti_pattern = DECODE(p_anti_pattern,'NULL',NULL,NVL(p_anti_pattern,anti_pattern))
           , msg_type = NVL(p_msg_type,msg_type)
       WHERE app_alias LIKE p_app_alias
         AND object_type LIKE p_object_type
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         raise_application_error(-20000,k_where||'no pattern found for object type "'||p_object_type||'"');
      END IF;
   END update_pattern;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(18) := 'upsert_pattern(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_object_type IS NULL THEN
         raise_application_error(-20000,k_where||'object type cannot be NULL');
      END IF;
      UPDATE qc_patterns
         SET check_pattern = DECODE(p_check_pattern,'NULL',NULL,NVL(p_check_pattern,check_pattern))
           , include_pattern = DECODE(p_include_pattern,'NULL',NULL,NVL(p_include_pattern,include_pattern))
           , exclude_pattern = DECODE(p_exclude_pattern,'NULL',NULL,NVL(p_exclude_pattern,exclude_pattern))
           , fix_pattern = DECODE(p_fix_pattern,'NULL',NULL,NVL(p_fix_pattern,fix_pattern))
           , anti_pattern = DECODE(p_anti_pattern,'NULL',NULL,NVL(p_anti_pattern,anti_pattern))
           , msg_type = NVL(p_msg_type,msg_type)
       WHERE app_alias LIKE p_app_alias
         AND object_type LIKE p_object_type
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         IF NVL(INSTR(p_app_alias,'%'),0)>0 OR NVL(INSTR(p_app_alias,'_'),0)>0 THEN
            raise_application_error(-20000,k_where||'wildcards not allowed in application alias when inserting');
         END IF;
         IF NVL(INSTR(p_object_type,'%'),0)>0 OR NVL(INSTR(p_object_type,'_'),0)>0 THEN
            raise_application_error(-20000,k_where||'wildcards not allowed in object type when inserting');
         END IF;
         INSERT INTO qc_patterns (
            app_alias
          , object_type, check_pattern, include_pattern
          , exclude_pattern, fix_pattern, anti_pattern
          , msg_type
         ) VALUES (
            p_app_alias
          , p_object_type, p_check_pattern, p_include_pattern
          , p_exclude_pattern, p_fix_pattern, p_anti_pattern
          , p_msg_type
         );
      END IF;
   END upsert_pattern;
--#begin public
   ---
   -- Delete one pattern (or several ones if wildecard used)
   ---
   PROCEDURE delete_pattern (
      p_app_alias qc_patterns.app_alias%TYPE
    , p_object_type qc_patterns.object_type%TYPE
   )
--#end public
   IS
      k_where CONSTANT VARCHAR2(18) := 'delete_pattern(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_object_type IS NULL THEN
         raise_application_error(-20000,k_where||'object type cannot be NULL');
      END IF;
      DELETE qc_patterns
       WHERE app_alias LIKE p_app_alias
         AND object_type LIKE p_object_type
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         raise_application_error(-20000,k_where||'no pattern found for object type "'||p_object_type||'"');
      END IF;
   END delete_pattern;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(27) := 'insert_dictionary_entry(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_dict_name IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary name cannot be NULL');
      END IF;
      IF p_dict_key IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary key cannot be NULL');
      END IF;
      INSERT INTO qc_dictionary_entries (
         app_alias
       , dict_name, dict_key
       , dict_value, comments
      )
      VALUES (
         p_app_alias
       , p_dict_name, p_dict_key
       , p_dict_value, p_comments
      )
      ;
   END insert_dictionary_entry;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(27) := 'update_dictionary_entry(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_dict_name IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary name cannot be NULL');
      END IF;
      IF p_dict_key IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary key cannot be NULL');
      END IF;
      UPDATE qc_dictionary_entries
         SET dict_value = DECODE(p_dict_value,'NULL',NULL,NVL(p_dict_value,dict_value))
           , comments = DECODE(p_comments,'NULL',NULL,NVL(p_comments,comments))
       WHERE app_alias LIKE p_app_alias
         AND dict_name LIKE p_dict_name
         AND dict_key  LIKE p_dict_key
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         raise_application_error(-20000,k_where||'no entry found for dictionary name "'||p_dict_name||'" and key "'||p_dict_key||'"');
      END IF;
   END update_dictionary_entry;
--#begin public
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
--#end public
   IS
      k_where CONSTANT VARCHAR2(27) := 'upsert_dictionary_entry(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_dict_name IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary name cannot be NULL');
      END IF;
      IF p_dict_key IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary key cannot be NULL');
      END IF;
      UPDATE qc_dictionary_entries
         SET dict_value = DECODE(dict_value,'NULL',NULL,NVL(p_dict_value,dict_value))
           , comments = DECODE(comments,'NULL',NULL,NVL(p_comments,comments))
       WHERE app_alias LIKE p_app_alias
         AND dict_name LIKE p_dict_name
         AND dict_key  LIKE p_dict_key
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         IF NVL(INSTR(p_app_alias,'%'),0)>0 OR NVL(INSTR(p_app_alias,'_'),0)>0 THEN
            raise_application_error(-20000,k_where||'wildcards not allowed in application alias when inserting');
         END IF;
         IF NVL(INSTR(p_dict_name,'%'),0)>0 OR NVL(INSTR(p_dict_name,'_'),0)>0 THEN
            raise_application_error(-20000,k_where||'wildcards not allowed in dictionary name when inserting');
         END IF;
         IF NVL(INSTR(p_dict_key,'%'),0)>0 THEN -- undercore is a valid character for key
            raise_application_error(-20000,k_where||'wildcard % not allowed in dictionary key when inserting');
         END IF;
         INSERT INTO qc_dictionary_entries (
            app_alias
          , dict_name, dict_key
          , dict_value, comments
         )
         VALUES (
            p_app_alias
          , p_dict_name, p_dict_key
          , p_dict_value, p_comments
         )
         ;
      END IF;
   END upsert_dictionary_entry;
--#begin public
   ---
   -- Delete a dictionary entry
   ---
   PROCEDURE delete_dictionary_entry (
      p_app_alias  IN VARCHAR2
    , p_dict_name  IN VARCHAR2
    , p_dict_key   IN VARCHAR2 := NULL
   )
--#end public
   IS
      k_where CONSTANT VARCHAR2(27) := 'delete_dictionary_entry(): ';
   BEGIN
      IF p_app_alias IS NULL THEN
         raise_application_error(-20000,k_where||'application alias cannot be NULL');
      END IF;
      IF p_dict_name IS NULL THEN
         raise_application_error(-20000,k_where||'dictionary name cannot be NULL');
      END IF;
      DELETE qc_dictionary_entries
       WHERE app_alias LIKE p_app_alias
         AND dict_name LIKE p_dict_name
         AND (p_dict_key IS NULL OR dict_key LIKE p_dict_key)
      ;
      IF SQL%ROWCOUNT <= 0 THEN
         raise_application_error(-20000,k_where||'no entry found for dictionary name "'||p_dict_name||'"'
            ||CASE WHEN p_dict_key IS NOT NULL THEN ' and key "'||p_dict_key||'"' END);
      END IF;
   END delete_dictionary_entry;
BEGIN
   init;
END qc_utility_krn;
/