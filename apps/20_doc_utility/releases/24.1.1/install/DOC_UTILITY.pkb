CREATE OR REPLACE PACKAGE BODY doc_utility AS
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
   ----------------------------------------
   -- Global cursors, tabs and variables --
   ----------------------------------------
   -- Defaults, Parameters and Results
   SUBTYPE g_short_name_type IS VARCHAR2(30 CHAR);
   SUBTYPE g_long_name_type  IS VARCHAR2(100 CHAR);
   SUBTYPE g_small_buf_type  IS VARCHAR2(4000 CHAR);
   SUBTYPE g_big_buf_type    IS VARCHAR2(32767 CHAR);
   TYPE gt_str_ass_type IS TABLE OF g_small_buf_type INDEX BY g_long_name_type;
   gt_def_ass gt_str_ass_type; -- defaults
   gt_var_ass gt_str_ass_type; -- results
   -- Table of tables (indexed by table_name)
   CURSOR gc_tab (
      p_table_name IN VARCHAR2 := NULL
   ) IS
      SELECT tab.table_name
           , LOWER(REPLACE(REPLACE(pk.constraint_name,'_PK'),'_UK')) table_alias
           , rownum tab_index
        FROM user_tables tab
       INNER JOIN user_constraints pk
          ON pk.table_name = tab.table_name
         AND pk.constraint_type = 'P'
       WHERE (p_table_name IS NULL OR tab.table_name = UPPER(p_table_name))
   ;
   TYPE gt_tab_ass_type IS TABLE OF gc_tab%ROWTYPE INDEX BY g_long_name_type;
   gt_tab_ass gt_tab_ass_type;
   TYPE gt_tab_idx_type IS TABLE OF gc_tab%ROWTYPE INDEX BY BINARY_INTEGER;
   gt_tab_idx gt_tab_idx_type;
   -- Table of table aliases (indexed by table_name)
   TYPE gt_tal_ass_type IS TABLE OF g_short_name_type INDEX BY g_short_name_type;
   gt_tal_ass gt_tal_ass_type;
   gt_qal_ass gt_tal_ass_type;
   -- Table of table columns (indexed by table_name.column_name)
   CURSOR gc_tcol (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2 := NULL
   )
   IS
      SELECT column_name
        FROM user_tab_columns
       WHERE (p_table_name IS NULL OR table_name = UPPER(p_table_name))
         AND (p_column_name IS NULL OR column_name = UPPER(p_column_name))
       ORDER BY column_id
   ;
   TYPE gt_ass_type IS TABLE OF gc_tcol%ROWTYPE INDEX BY g_long_name_type;
   TYPE gt_idx_type IS TABLE OF gc_tcol%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE gt_tcol_ass_type IS TABLE OF gt_ass_type INDEX BY g_long_name_type;
   gt_tcol_ass gt_tcol_ass_type;
   -- Table of constraints (indexed by constraint_name)
   CURSOR gc_con (
      p_table_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_constraint_type IN VARCHAR2 := NULL
   )
   IS
      SELECT con.*, r_con.table_name r_table_name
        FROM user_constraints con
        LEFT OUTER JOIN all_constraints r_con
          ON r_con.owner = con.r_owner
         AND r_con.constraint_name = con.r_constraint_name
       WHERE (p_table_name IS NULL OR con.table_name = UPPER(p_table_name))
         AND (p_constraint_name IS NULL OR con.constraint_name = UPPER(p_constraint_name))
         AND (p_constraint_type IS NULL OR INSTR(UPPER(p_constraint_type),con.constraint_type)>0)
       ORDER BY con.table_name, r_con.table_name
   ;
   TYPE gt_con_ass_type IS TABLE OF gc_con%ROWTYPE INDEX BY g_long_name_type;
   gt_con_ass gt_con_ass_type;
   TYPE gt_con_idx_type IS TABLE OF gc_con%ROWTYPE INDEX BY BINARY_INTEGER;
   gt_con_idx gt_con_idx_type;
   TYPE gt_tcon_ass_type IS TABLE OF gt_con_ass_type INDEX BY g_long_name_type;
   gt_tcon_ass gt_tcon_ass_type;
   -- Table of constraint columns (indexed by constraint_name.column_name)
   CURSOR gc_ccol (
--      p_table_name IN VARCHAR2
--    , p_constraint_name IN VARCHAR2 := NULL
      p_constraint_name IN VARCHAR2 := NULL
   )
   IS
      SELECT *
        FROM user_cons_columns
--       WHERE (p_table_name IS NULL OR table_name = p_table_name)
--         AND (p_constraint_name IS NULL OR constraint_name = p_constraint_name)
       WHERE constraint_name = UPPER(p_constraint_name)
   ;
   TYPE gt_ccol_ass_type IS TABLE OF gc_ccol%ROWTYPE INDEX BY g_long_name_type;
--   gt_ccol_ass gt_ccol_ass_type; -- G-1030
   TYPE gt_ccol_idx_type IS TABLE OF gc_ccol%ROWTYPE INDEX BY BINARY_INTEGER;
--   gt_ccol_idx gt_ccol_idx_type;  -- G-1030
   TYPE gt_cccol_ass_type IS TABLE OF gt_ccol_ass_type INDEX BY g_long_name_type;
   gt_cccol_ass gt_cccol_ass_type;
   -- Get all foreign keys between source and target tables
   -- If constraint name is given, no other fk is considered
   -- Return order is determined from position of columns
   -- If column name is given, it must be part of the fk
   CURSOR gc_fk (
      p_src_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
    , p_tgt_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2 := NULL
   )
   IS
      SELECT src.*
        FROM user_constraints src
       INNER JOIN user_constraints tgt
          ON tgt.constraint_name = src.r_constraint_name
         AND tgt.table_name = UPPER(p_tgt_table_name)
       INNER JOIN user_cons_columns cco1
          ON cco1.constraint_name = src.constraint_name
         AND cco1.position = 1
       INNER JOIN user_tab_columns tco1
          ON tco1.table_name = cco1.table_name
         AND tco1.column_name = cco1.column_name
        LEFT OUTER JOIN user_cons_columns cco2
          ON cco2.constraint_name = src.constraint_name
         AND cco2.position = 2
        LEFT OUTER JOIN user_tab_columns tco2
          ON tco2.table_name = cco2.table_name
         AND tco2.column_name = cco2.column_name
        LEFT OUTER JOIN user_cons_columns cco3
          ON cco3.constraint_name = src.constraint_name
         AND p_column_name IS NOT NULL
         AND cco3.column_name = UPPER(p_column_name)
       WHERE src.table_name = UPPER(p_src_table_name)
         AND (p_constraint_name IS NULL OR src.constraint_name = UPPER(p_constraint_name))
         AND (p_column_name IS NULL OR cco3.column_name IS NOT NULL)
         AND src.constraint_type = 'R'
       ORDER BY tco1.column_id, tco2.column_id, src.constraint_name
   ;
   TYPE gt_arg_list_idx_type IS TABLE OF g_small_buf_type INDEX BY BINARY_INTEGER;
   -- Dijkstra
   TYPE gr_edge_type IS RECORD (
      fk_name g_short_name_type
    , src_table_name g_short_name_type
    , tgt_table_name g_short_name_type
    , dir g_short_name_type
    , multiple VARCHAR2(1) -- Y if there are multiple fks between source and target table
    , distance BINARY_DOUBLE
   );
   TYPE gt_edge_idx_type IS TABLE OF gr_edge_type INDEX BY BINARY_INTEGER;
   TYPE gt_node_idx_type IS TABLE OF gt_edge_idx_type INDEX BY g_short_name_type;
   gt_node_ass gt_node_idx_type;
   TYPE gt_unchecked_idx_type IS TABLE OF g_short_name_type INDEX BY g_short_name_type;
   gt_unchecked_ass gt_unchecked_idx_type;
   TYPE gt_predecessor_idx_type IS TABLE OF gr_edge_type INDEX BY g_short_name_type;
   gt_predecessor_ass gt_predecessor_idx_type;
   TYPE gt_distance_idx_type IS TABLE OF BINARY_DOUBLE INDEX BY g_short_name_type;
   gt_distance_ass gt_distance_idx_type;
   gk_distance CONSTANT BINARY_DOUBLE := 999;
   -----------------------------------------
   -- Local procedure/function signatures --
   -----------------------------------------
   FUNCTION get_table_alias (
      p_table_name IN all_tables.table_name%TYPE
   )
   RETURN VARCHAR2
   ;
   FUNCTION extract_table_alias (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Return message translation in current user's language
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   FUNCTION t (
      p_msg_fra IN VARCHAR2
     ,p_msg_eng IN VARCHAR2
     ,p_p1 IN VARCHAR2 := NULL
     ,p_p2 IN VARCHAR2 := NULL
     ,p_p3 IN VARCHAR2 := NULL
     ,p_p4 IN VARCHAR2 := NULL
     ,p_p5 IN VARCHAR2 := NULL
     ,p_p6 IN VARCHAR2 := NULL
     ,p_p7 IN VARCHAR2 := NULL
     ,p_p8 IN VARCHAR2 := NULL
     ,p_p9 IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_msg g_small_buf_type := CASE WHEN doc_utility_ext.get_language = 'FRA' THEN p_msg_fra ELSE p_msg_eng END;
      l_pos INTEGER;
   BEGIN
      FOR i IN 1..9 LOOP
         l_pos := NVL(INSTR(l_msg,':'||i),0);
         EXIT WHEN l_pos<=0;
         l_msg := SUBSTR(l_msg,1,l_pos-1)
               || CASE WHEN i = 1 THEN p_p1
                       WHEN i = 2 THEN p_p2
                       WHEN i = 3 THEN p_p3
                       WHEN i = 4 THEN p_p4
                       WHEN i = 5 THEN p_p5
                       WHEN i = 6 THEN p_p6
                       WHEN i = 7 THEN p_p7
                       WHEN i = 8 THEN p_p8
                       WHEN i = 9 THEN p_p9
                  END
               || SUBSTR(l_msg,l_pos+2);
      END LOOP;
      RETURN l_msg;
   END;
   ---
   -- Check assertion and return error message in user's language if false
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_msg_fra IN VARCHAR2
     ,p_err_msg_eng IN VARCHAR2 := NULL
     ,p_where IN VARCHAR2 := NULL
     ,p_p1 IN VARCHAR2 := NULL
     ,p_p2 IN VARCHAR2 := NULL
     ,p_p3 IN VARCHAR2 := NULL
     ,p_p4 IN VARCHAR2 := NULL
     ,p_p5 IN VARCHAR2 := NULL
     ,p_p6 IN VARCHAR2 := NULL
     ,p_p7 IN VARCHAR2 := NULL
     ,p_p8 IN VARCHAR2 := NULL
     ,p_p9 IN VARCHAR2 := NULL
   )
   IS
   BEGIN
      IF p_assertion IS NULL OR NOT p_assertion THEN
         raise_application_error(-20000,p_where||t(p_err_msg_fra,NVL(p_err_msg_eng,p_err_msg_fra),p_p1,p_p2,p_p3,p_p4,p_p5,p_p6,p_p7,p_p8,p_p9));
      END IF;
   END;
   ---
   -- Generate unique query alias
   ---
   FUNCTION generate_query_alias (
      p_table_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_table_alias g_short_name_type;
      l_query_alias g_short_name_type;
      l_alias_count PLS_INTEGER;
   BEGIN
      l_table_alias := get_table_alias(p_table_name);
      l_query_alias := l_table_alias;
      l_alias_count := 1;
      WHILE gt_qal_ass.EXISTS(l_query_alias) LOOP
         l_alias_count := l_alias_count + 1;
         l_query_alias := l_table_alias || '$' || RTRIM(TO_CHAR(l_alias_count));
      END LOOP;
      RETURN l_query_alias;
   END;
   ---
   -- Init dijkstra
   ---
   PROCEDURE init_dijkstra
   IS
      r_tab gc_tab%ROWTYPE;
      r_con gc_con%ROWTYPE;
      r_edge gr_edge_type;
      t_edge gt_edge_idx_type;
   BEGIN
      t_edge.DELETE;
      gt_node_ass.DELETE;
      FOR i IN 1..gt_tab_idx.COUNT LOOP
         r_tab := gt_tab_idx(i);
         gt_node_ass(r_tab.table_name) := t_edge;
      END LOOP;
      FOR i IN 1..gt_con_idx.COUNT LOOP
         r_con := gt_con_idx(i);
         IF r_con.constraint_type = 'R' THEN
            r_edge.fk_name := r_con.constraint_name;
            r_edge.distance := gk_distance;
            r_edge.src_table_name := r_con.table_name;
            r_edge.tgt_table_name := r_con.r_table_name;
            r_edge.dir := '>-'; -- many-to-one
            IF (i > 1 AND r_con.r_table_name=gt_con_idx(i-1).r_table_name)
            OR (i < gt_con_idx.COUNT AND r_con.r_table_name=gt_con_idx(i+1).r_table_name)
            THEN
               r_edge.multiple := 'Y';
            ELSE
               r_edge.multiple := 'N';
            END IF;
            IF gt_node_ass.EXISTS(r_con.table_name) THEN
               gt_node_ass(r_con.table_name)(gt_node_ass(r_con.table_name).COUNT+1) := r_edge;
            ELSE
               gt_node_ass(r_con.table_name)(1) := r_edge;
            END IF;
            r_edge.src_table_name := r_con.r_table_name;
            r_edge.tgt_table_name := r_con.table_name;
            r_edge.dir := '-<'; -- one-to-many
            IF gt_node_ass.EXISTS(r_con.r_table_name) THEN
               gt_node_ass(r_con.r_table_name)(gt_node_ass(r_con.r_table_name).COUNT+1) := r_edge;
            ELSE
               gt_node_ass(r_con.r_table_name)(1) := r_edge;
            END IF;
         END IF;
      END LOOP;
    --sys.dbms_output.put_line(ta_node.COUNT||' nodes loaded');
   END;
   ---
   -- Set edge weight for dijkstra search
   ---
   PROCEDURE set_edge_distance (
      p_fk_name IN VARCHAR2
    , p_distance IN BINARY_DOUBLE
    , p_dir IN VARCHAR2 := NULL -- '>-' or '-<'
   )
   IS
      r_con gc_con%ROWTYPE;
      r_edge gr_edge_type;
      t_edge gt_edge_idx_type;
      l_fk_name g_short_name_type := UPPER(p_fk_name);
   BEGIN
      -- Get source table name for constraint
      assert(p_fk_name IS NOT NULL,'Foreign key name parameter is mandatory!');
      assert(gt_con_ass.EXISTS(p_fk_name),'Constraint '||p_fk_name||' does not exist');
      r_con := gt_con_ass(l_fk_name);
      -- Update nodes for source and destination table
      FOR i IN 1..2 LOOP
         IF i = 1 THEN
            t_edge := gt_node_ass(r_con.table_name);
         ELSE
            t_edge := gt_node_ass(r_con.r_table_name);
         END IF;
         FOR j IN 1..t_edge.COUNT LOOP
            r_edge := t_edge(j);
            IF  r_edge.fk_name = l_fk_name
            AND r_edge.dir = NVL(p_dir,r_edge.dir)
            THEN
               r_edge.distance := NVL(p_distance,gk_distance); -- NULL means reset to default value 999
               t_edge(j) := r_edge;
            END IF;
         END LOOP;
         IF i = 1 THEN
            gt_node_ass(r_con.table_name) := t_edge;
         ELSE
            gt_node_ass(r_con.r_table_name) := t_edge;
         END IF;
      END LOOP;
   END;
   ---
   -- Reset distance of all edges to default value
   ---
   PROCEDURE reset_all_edge_distances
   IS
      r_edge gr_edge_type;
      t_edge gt_edge_idx_type;
      l_table_name g_short_name_type;
   BEGIN
      l_table_name := gt_node_ass.FIRST;
      WHILE l_table_name IS NOT NULL LOOP
         t_edge := gt_node_ass(l_table_name);
         FOR j IN 1..t_edge.COUNT LOOP
            r_edge := t_edge(j);
            r_edge.distance := gk_distance;
            t_edge(j) := r_edge;
         END LOOP;
         gt_node_ass(l_table_name) := t_edge;
         l_table_name := gt_node_ass.NEXT(l_table_name);
      END LOOP;
   END;
   ---
   -- Get road between 2 tables using Dijkstra algorithm
   ---
   FUNCTION do_dijkstra (
      p_source IN VARCHAR2
    , p_target IN VARCHAR2
    , p_dir IN VARCHAR2 := '-->'
   )
   RETURN VARCHAR2
   IS
      l_source VARCHAR2(60) := SUBSTR(UPPER(p_source),1,60);
      l_target VARCHAR2(60) := SUBSTR(UPPER(p_target),1,60);
      l_table_name g_short_name_type;
      l_table_alias g_short_name_type;
      l_query_alias g_short_name_type;
      l_src_table_name VARCHAR2(30);
      l_tgt_table_name g_short_name_type;
      l_src_table_alias g_short_name_type;
      l_tgt_table_alias g_short_name_type;
      l_src_query_alias g_short_name_type;
      l_tgt_query_alias g_short_name_type;
      l_alias_count INTEGER;
      l_nxt_table_name g_short_name_type;
      l_min_table_name g_short_name_type;
      l_distance BINARY_DOUBLE;
      l_path VARCHAR2(32000);
      t_node gt_edge_idx_type;
      r_edge gr_edge_type;
      r_nxt_edge gr_edge_type;
      r_fk gc_con%ROWTYPE;
      l_found BOOLEAN := FALSE;
      l_join_type VARCHAR2(1) := SUBSTR(p_dir,2,1);
      t_qal_new gt_tal_ass_type;
   BEGIN
      -- Check parameters
      assert(p_source IS NOT NULL, 'Source table/alias is mandatory');
      assert(p_target IS NOT NULL, 'Target table/alias is mandatory');
      IF gt_tab_ass.EXISTS(l_source) THEN
         l_src_table_name := l_source;
         l_src_table_alias := gt_tab_ass(l_src_table_name).table_alias;
         l_src_query_alias := l_src_table_alias;
      ELSE
         l_src_query_alias := LOWER(l_source);
         l_src_table_alias := extract_table_alias(l_src_query_alias);
         assert(gt_tal_ass.EXISTS(l_src_table_alias),'Source table alias "'||l_src_table_alias||'" not found!');
         l_src_table_name := gt_tal_ass(l_src_table_alias);
      END IF;
      IF gt_tab_ass.EXISTS(l_target) THEN
         l_tgt_table_name := l_target;
         l_tgt_table_alias := gt_tab_ass(l_tgt_table_name).table_alias;
         l_tgt_query_alias := l_tgt_table_alias;
      ELSE
         l_tgt_query_alias := LOWER(l_target);
         l_tgt_table_alias := extract_table_alias(l_tgt_query_alias);
         assert(gt_tal_ass.EXISTS(l_tgt_table_alias),'Target table alias "'||l_tgt_table_alias||'" not found!');
         l_tgt_table_name := gt_tal_ass(l_tgt_table_alias);
      END IF;
      assert(LENGTH(p_dir)=3,'Invalid direction');
      assert(l_join_type IN ('-','=','~'),'Invalid join type');
      -- Initialize
      gt_unchecked_ass.DELETE;
      gt_predecessor_ass.DELETE;
      gt_distance_ass.DELETE;
      l_table_name := gt_node_ass.FIRST;
      WHILE l_table_name IS NOT NULL LOOP
         gt_unchecked_ass(l_table_name) := NULL;
       --ta_predecessor(l_table_name) := NULL;
         gt_distance_ass(l_table_name) := BINARY_DOUBLE_INFINITY;
         l_table_name := gt_node_ass.NEXT(l_table_name);
      END LOOP;
      gt_distance_ass(l_src_table_name) := 0;
      -- Go
      WHILE gt_unchecked_ass.COUNT > 0 LOOP
         l_min_table_name := NULL;
         l_table_name := gt_unchecked_ass.FIRST;
         WHILE l_table_name IS NOT NULL LOOP
            IF l_min_table_name IS NULL
            OR gt_distance_ass(l_table_name) < gt_distance_ass(l_min_table_name)
            THEN
               l_min_table_name := l_table_name;
            END IF;
            l_table_name := gt_unchecked_ass.NEXT(l_table_name);
         END LOOP;
         gt_unchecked_ass.DELETE(l_min_table_name);
         l_found := l_min_table_name = l_tgt_table_name;
         EXIT WHEN l_found;
         t_node := gt_node_ass(l_min_table_name);
         FOR i IN 1..t_node.COUNT LOOP
            r_edge := t_node(i);
            r_fk := gt_con_ass(r_edge.fk_name);
            IF SUBSTR(p_dir,-1,1) = '>'
            OR SUBSTR(p_dir,1,1) = '>' AND r_edge.dir = '>-'
            OR SUBSTR(p_dir,-1,1) = '<' AND r_edge.dir = '-<'
            THEN
               IF gt_unchecked_ass.exists(r_edge.tgt_table_name) THEN
                  l_distance := gt_distance_ass(l_min_table_name) + r_edge.distance;
                  IF l_distance < gt_distance_ass(r_edge.tgt_table_name) THEN
                     gt_distance_ass(r_edge.tgt_table_name) := l_distance;
                     gt_predecessor_ass(r_edge.tgt_table_name) := r_edge;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END LOOP;
      IF l_found THEN
         IF gt_distance_ass(l_min_table_name) = BINARY_DOUBLE_INFINITY THEN
            l_path := NULL;
         ELSE
            l_path := CASE WHEN l_target != l_tgt_table_name THEN l_tgt_query_alias ELSE l_tgt_table_name END;
         END IF;
         IF gt_predecessor_ass.EXISTS(l_min_table_name) THEN
            r_edge := gt_predecessor_ass(l_min_table_name);
            l_table_name := r_edge.src_table_name;
         ELSE
            l_table_name := NULL;
         END IF;
         WHILE l_table_name IS NOT NULL LOOP
            IF gt_predecessor_ass.EXISTS(l_table_name) THEN
               r_nxt_edge := gt_predecessor_ass(l_table_name);
               l_nxt_table_name := r_nxt_edge.src_table_name;
            ELSE
               l_nxt_table_name := NULL;
            END IF;
            IF l_source != l_src_table_name OR l_target != l_tgt_table_name THEN
               IF l_nxt_table_name IS NULL THEN
                  l_query_alias := l_src_query_alias;
               ELSE
                  l_query_alias := generate_query_alias(l_table_name);
                  gt_qal_ass(l_query_alias) := l_table_name;
                  t_qal_new(l_query_alias) := l_table_name;
               END IF;
               l_path := l_query_alias || REPLACE(r_edge.dir,'-',l_join_type) || CASE WHEN r_edge.multiple='Y' THEN '['||r_edge.fk_name||']' END || l_path;
            ELSE
               l_path := l_table_name || REPLACE(r_edge.dir,'-',l_join_type) || CASE WHEN r_edge.multiple='Y' THEN '['||r_edge.fk_name||']' END || l_path;
            END IF;
            r_edge := r_nxt_edge;
            l_table_name := l_nxt_table_name;
         END LOOP;
         -- Restore ta_qal as it was before calling dijkstra
         l_query_alias := t_qal_new.FIRST;
         WHILE l_query_alias IS NOT NULL LOOP
            gt_qal_ass.DELETE(l_query_alias);
            l_query_alias := t_qal_new.NEXT(l_query_alias);
         END LOOP;
         RETURN l_path;
      END IF;
      RETURN NULL;
   END;
   ---
   -- Get road between 2 tables using Dijkstra algorithm
   ---
   PROCEDURE do_dijkstra (
      p_source IN VARCHAR2
    , p_target IN VARCHAR2
    , p_dir IN VARCHAR2 := '-->'
   )
   IS
   BEGIN
      sys.dbms_output.put_line('path='||do_dijkstra(p_source,p_target,p_dir));
   END;
   ---
   -- Log debug info
   ---
   PROCEDURE debug (
      p_level IN VARCHAR2
    , p_text IN VARCHAR2
   )
   IS
   BEGIN
      IF INSTR(NVL(doc_utility_var.g_debug_level,p_level),p_level) > 0 THEN
         log_utility.log_message('D', p_text);
      END IF;
   END;
   ---
   -- Set debug level
   ---
   PROCEDURE set_debug_level (
      p_level IN VARCHAR2
   )
   IS
   BEGIN
      doc_utility_var.g_debug_level := SUBSTR(p_level,1,10);
   END;
   ---
   -- Set cache entry
   ---
   PROCEDURE set_cache_entry (
      piot_cache IN OUT gt_str_ass_type
    , p_entry_name IN VARCHAR2
    , p_entry_value IN VARCHAR2
   )
   IS
   BEGIN
      piot_cache(p_entry_name) := p_entry_value;
   END;
   ---
   -- Get cache entry
   ---
   FUNCTION get_cache_entry (
      pt_cache_ass IN gt_str_ass_type
    , p_entry_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      IF pt_cache_ass.EXISTS(p_entry_name) THEN
         RETURN pt_cache_ass(p_entry_name);
      END IF;
      RETURN NULL;
   END;
   ---
   -- Set variable
   ---
   PROCEDURE set_variable (
      p_var_name IN VARCHAR2
    , p_var_value IN VARCHAR2
    , p_var_type IN VARCHAR2 := NULL
   )
   IS
   BEGIN
      set_cache_entry(gt_var_ass,REPLACE(p_var_name,':',NULL),REPLACE(p_var_value,'"',''''));
   END;
   ---
   -- Reset all variables
   ---
   PROCEDURE reset_variables
   IS
   BEGIN
      gt_var_ass.DELETE;
   END;
   ---
   -- Get variable value
   ---
   FUNCTION get_variable (
      p_var_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_cache_entry(gt_var_ass,p_var_name);
   END;
   ---
   -- Set default
   ---
   PROCEDURE set_default (
      p_def_name IN VARCHAR2
    , p_def_value IN VARCHAR2
    , p_def_type IN VARCHAR2 := NULL
   )
   IS
   BEGIN
      set_cache_entry(gt_def_ass,p_def_name,REPLACE(p_def_value,'"',''''));
   END;
   ---
   -- Reset all defaults
   ---
   PROCEDURE reset_defaults
   IS
   BEGIN
      gt_def_ass.DELETE;
   END;
   ---
   -- Get default
   ---
   FUNCTION get_default (
      p_def_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_cache_entry(gt_def_ass,p_def_name);
   END;
   ---
   -- Check whether a line starts with a string
   ---
   FUNCTION starts_with (
      p_line IN VARCHAR2
    , p_string IN VARCHAR2
    , p_ignore_case IN BOOLEAN := FALSE
   )
   RETURN BOOLEAN
   IS
      l_len INTEGER := LENGTH(p_string);
   BEGIN
      RETURN l_len > 0 AND (SUBSTR(p_line,1,l_len) = p_string OR (p_ignore_case AND UPPER(SUBSTR(p_line,1,l_len)) = UPPER(p_string)));
   END;
   ---
   -- Check whether a line starts with a string
   ---
   FUNCTION ends_with (
      p_line IN VARCHAR2
    , p_string IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      l_len INTEGER := LENGTH(p_string);
   BEGIN
      RETURN l_len > 0 AND SUBSTR(p_line,0-l_len) = p_string;
   END;
   ---
   -- Consume white spaces
   ---
   PROCEDURE consume_leading_spaces (
      pio_line IN OUT VARCHAR2
   )
   IS
   BEGIN
      -- Skip spaces
      WHILE pio_line IS NOT NULL AND SUBSTR(pio_line,1,1) IN (' ',CHR(9),CHR(10),CHR(13)) LOOP
         pio_line := SUBSTR(pio_line,2);
      END LOOP;
   END;
   ---
   -- Consume white spaces
   ---
   PROCEDURE consume_trailing_spaces (
      pio_line IN OUT VARCHAR2
   )
   IS
   BEGIN
      -- Skip spaces
      WHILE pio_line IS NOT NULL AND SUBSTR(pio_line,1,1) IN (' ',CHR(9),CHR(10),CHR(13)) LOOP
         pio_line := SUBSTR(pio_line,2);
      END LOOP;
   END;
   ---
   -- Is letter?
   ---
   FUNCTION is_letter (
      p_char IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN NVL(p_char BETWEEN 'A' AND 'Z' OR p_char BETWEEN 'a' AND 'z',FALSE);
   END;
   ---
   -- Is digit?
   ---
   FUNCTION is_digit (
      p_char IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN NVL(p_char BETWEEN '0' AND '9',FALSE);
   END;
   ---
   -- Is space?
   ---
   FUNCTION is_space (
      p_char IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN NVL(p_char = ' ',FALSE);
   END;
   ---
   -- Consume word
   ---
   FUNCTION consume_word (
      pio_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_word g_small_buf_type;
      l_char VARCHAR2(1);
   BEGIN
      -- Copy until space found or end of line
      l_char := SUBSTR(pio_line,1,1);
      WHILE is_letter(l_char) OR is_digit(l_char) OR l_char='_' OR l_char='$' LOOP
         l_word := l_word || l_char;
         pio_line := SUBSTR(pio_line,2);
         l_char := SUBSTR(pio_line,1,1);
      END LOOP;
      RETURN l_word;
   END;
   ---
   -- Consume integer
   ---
   FUNCTION consume_integer (
      pio_line IN OUT VARCHAR2
   )
   RETURN INTEGER
   IS
      l_int INTEGER;
      l_char VARCHAR2(1);
   BEGIN
      -- Copy while digit found
      l_char := SUBSTR(pio_line,1,1);
      WHILE is_digit(l_char) LOOP
         l_int := NVL(l_int,0) * 10 + l_char - '0';
         pio_line := SUBSTR(pio_line,2);
         l_char := SUBSTR(pio_line,1,1);
      END LOOP;
      RETURN l_int;
   END;
   ---
   -- Consume keyword
   ---
   PROCEDURE consume_keyword (
      pio_line IN OUT VARCHAR2
    , p_value IN VARCHAR2
    , p_err_msg IN VARCHAR2 := NULL
   )
   IS
      l_len INTEGER := LENGTH(p_value);
   BEGIN
      -- Check keyword
      assert(SUBSTR(pio_line,1,l_len)=p_value,NVL(p_err_msg,'keyword '||p_value||' not found'));
      pio_line := SUBSTR(pio_line,l_len+1);
   END;
   ---
   -- Consume condition
   ---
   FUNCTION consume_condition (
      pio_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_condition g_small_buf_type;
      l_pos INTEGER;
  BEGIN
      assert(SUBSTR(pio_line,1,1)='[','Internal error, expecting [, got '||SUBSTR(pio_line,1,1));
      pio_line := SUBSTR(pio_line,2);
      l_pos := NVL(INSTR(pio_line,']'),0);
      assert(l_pos>0,'Syntax error: [ without ]');
      l_condition := SUBSTR(pio_line,1,l_pos-1);
      pio_line := SUBSTR(pio_line,l_pos+1);
      RETURN l_condition;
   END;
   ---
   -- Right trim digits
   ---
   FUNCTION rtrim_digits (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_idx INTEGER := LENGTH(p_str);
   BEGIN
      WHILE l_idx > 0 LOOP
         EXIT WHEN SUBSTR(p_str,l_idx,1) NOT BETWEEN '0' AND '9';
         l_idx := l_idx - 1;
      END LOOP;
      RETURN SUBSTR(p_str,1,l_idx);
   END;
   ---
   -- Load table related info (columns, constraints columns) in cache
   ---
   PROCEDURE load_table_info (
      p_table_name IN VARCHAR2
   )
   IS
      t_col_idx gt_idx_type;
      r_col gc_tcol%ROWTYPE;
   BEGIN
      assert(gt_tab_ass.EXISTS(p_table_name),'Table "'||p_table_name||'" not found in cache!');
      IF NOT gt_tcol_ass.EXISTS(p_table_name) THEN
         OPEN gc_tcol(p_table_name);
         FETCH gc_tcol BULK COLLECT INTO t_col_idx;
         CLOSE gc_tcol;
         FOR i IN 1..t_col_idx.COUNT LOOP
            r_col := t_col_idx(i);
            gt_tcol_ass(p_table_name)(r_col.column_name) := r_col;
         END LOOP;
      END IF;
   END;
   ---
   -- Load constraint related info (list of columns) in cache
   ---
   PROCEDURE load_constraint_info (
      p_constraint_name IN VARCHAR2
   )
   IS
      t_ccol_idx gt_ccol_idx_type;
      r_ccol gc_ccol%ROWTYPE;
   BEGIN
      assert(gt_con_ass.EXISTS(p_constraint_name),'Constraint "'||p_constraint_name||'" not found in cache!');
      IF NOT gt_cccol_ass.EXISTS(p_constraint_name) THEN
         OPEN gc_ccol(p_constraint_name);
         FETCH gc_ccol BULK COLLECT INTO t_ccol_idx;
         CLOSE gc_ccol;
         FOR i IN 1..t_ccol_idx.COUNT LOOP
            r_ccol := t_ccol_idx(i);
            gt_cccol_ass(p_constraint_name)(r_ccol.column_name) := r_ccol;
         END LOOP;
      END IF;
   END;
   ---
   -- Prefix table columns with table alias
   ---
   FUNCTION prefix_columns (
      p_expression IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_column_name g_short_name_type;
      l_expression g_small_buf_type := p_expression;
      l_expr_upper g_small_buf_type := UPPER(p_expression);
      l_idx INTEGER := 1;
      l_start_idx INTEGER := 1;
      l_char VARCHAR2(1);
      l_found BOOLEAN;
      l_count INTEGER;
   BEGIN
      load_table_info(p_table_name);
      l_column_name := gt_tcol_ass(p_table_name).FIRST;
      WHILE l_column_name IS NOT NULL LOOP
         l_start_idx := 1;
         l_count := 0;
         WHILE l_start_idx > 0 LOOP
            l_count := l_count + 1;
            assert(l_count<=100,'infinite loop detected');
            l_idx := NVL(INSTR(l_expr_upper,l_column_name,l_start_idx),0);
            IF l_idx > 0 THEN
               l_found := TRUE;
               IF l_idx > 2 THEN
                  l_char := SUBSTR(l_expr_upper,l_idx-1,1);
                  l_found := l_char NOT IN ('.',':') AND NOT (l_char BETWEEN 'A' AND 'Z' OR l_char BETWEEN '0' AND '9' OR l_char IN ('_'));
               END IF;
               IF l_found AND l_idx + LENGTH(l_column_name) < LENGTH(l_expression) THEN
                  l_char := SUBSTR(l_expression,l_idx+LENGTH(l_column_name),1);
                  l_found := NOT (l_char BETWEEN 'A' AND 'Z' OR l_char BETWEEN '0' AND '9' OR l_char IN ('_'));
               END IF;
               IF l_found THEN
                  l_expr_upper := SUBSTR(l_expr_upper,1,l_idx-1)
                               || LOWER(p_table_alias)||'.'||LOWER(l_column_name)
                               || SUBSTR(l_expr_upper,l_idx+LENGTH(l_column_name));
                  l_expression := SUBSTR(l_expression,1,l_idx-1)
                               || LOWER(p_table_alias)||'.'||LOWER(l_column_name)
                               || SUBSTR(l_expression,l_idx+LENGTH(l_column_name));
               END IF;
               l_start_idx := l_idx + 1;
            ELSE
               l_start_idx := 0;
            END IF;
         END LOOP;
         l_column_name := gt_tcol_ass(p_table_name).NEXT(l_column_name);
      END LOOP;
      RETURN l_expression;
   END;
   ---
   -- Exists table column?
   ---
   FUNCTION exists_table_column (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      r_tab gc_tab%ROWTYPE;
      r_tcol gc_tcol%ROWTYPE;
      l_found BOOLEAN;
      l_table_name g_long_name_type := UPPER(p_table_name);
      l_column_name g_long_name_type := UPPER(p_column_name);
      l_full_column_name g_long_name_type := UPPER(p_table_name||'.'||p_column_name);
   BEGIN
      load_table_info(p_table_name);
      RETURN gt_tcol_ass(p_table_name).EXISTS(p_column_name);
   END;
   ---
   -- Initialise cache
   ---
   PROCEDURE init_cache
   IS
      r_tab gc_tab%ROWTYPE;
      r_con gc_con%ROWTYPE;
   BEGIN
      -- Load tables
      gt_tab_ass.DELETE;
      gt_tab_idx.DELETE;
      gt_tal_ass.DELETE;
      OPEN gc_tab;
      FETCH gc_tab BULK COLLECT INTO gt_tab_idx;
      CLOSE gc_tab;
      FOR i IN 1..gt_tab_idx.COUNT LOOP
         r_tab := gt_tab_idx(i);
         IF doc_utility_ext.keep_table(r_tab.table_name) THEN
            gt_tab_ass(r_tab.table_name) := r_tab;
            gt_tal_ass(r_tab.table_alias) := r_tab.table_name;
         END IF;
      END LOOP;
      debug('C',gt_tab_ass.COUNT||' tables loaded in cache');
      -- Load constraints
      gt_con_ass.DELETE;
      gt_tcon_ass.DELETE;
      gt_con_idx.DELETE;
      OPEN gc_con(p_constraint_type=>'PUR');
      FETCH gc_con BULK COLLECT INTO gt_con_idx;
      CLOSE gc_con;
      FOR i IN 1..gt_con_idx.COUNT LOOP
         r_con := gt_con_idx(i);
         gt_con_ass(r_con.constraint_name) := r_con;
         gt_tcon_ass(r_con.table_name)(r_con.constraint_name) := r_con;
      END LOOP;
      debug('C',gt_con_idx.COUNT||' constraints loaded');
      -- Init dijkstra
      init_dijkstra;
   END;
   ---
   -- Check whether a fk exists between 2 tables
   ---
   FUNCTION exists_fk_between (
      p_src_table_name IN VARCHAR2
     ,p_tgt_table_name IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      TYPE t_con_ass_type IS TABLE OF gc_fk%ROWTYPE INDEX BY BINARY_INTEGER;
      t_fk t_con_ass_type;
   BEGIN
      -- Get all foreign keys between the 2 tables
      OPEN gc_fk(p_src_table_name,NULL,p_tgt_table_name);
      FETCH gc_fk BULK COLLECT INTO t_fk;
      CLOSE gc_fk;
      RETURN t_fk.COUNT > 0;
   END;
   ---
   -- Add a comment if enabled
   ---
   FUNCTION add_comment (
      p_comment IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      IF INSTR(doc_utility_var.g_debug_level,'N') <= 0 THEN
         RETURN p_comment;
      ELSE
         RETURN NULL;
      END IF;
   END;
   ---
   -- Get table alias (from pk)
   ---
   FUNCTION get_table_alias (
      p_table_name IN all_tables.table_name%TYPE
   )
   RETURN VARCHAR2
   IS
   BEGIN
      IF gt_tab_ass.EXISTS(p_table_name) THEN
         RETURN gt_tab_ass(p_table_name).table_alias;
      ELSE
         RETURN NULL;
      END IF;
   END;
   ---
   -- Extract table alias from query alias
   ---
   FUNCTION extract_table_alias (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_idx INTEGER := 1;
      l_len INTEGER := LENGTH(p_str);
   BEGIN
      WHILE l_idx <= l_len LOOP
         EXIT WHEN NOT is_letter(SUBSTR(p_str,l_idx,1));
         l_idx := l_idx + 1;
      END LOOP;
      RETURN SUBSTR(p_str,1,l_idx-1);
   END;
   ---
   -- Get name of foreign key made up of a single column
   ---
   FUNCTION get_fk_rec_containing_col (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   RETURN user_constraints%ROWTYPE
   IS
      CURSOR c_cons (
         p_table_name IN VARCHAR2
       , p_column_name IN VARCHAR2
      )
      IS
         SELECT cons.*
           FROM user_cons_columns ccol
          INNER JOIN user_constraints cons
             ON cons.constraint_name = ccol.constraint_name
            AND cons.constraint_type = 'R'
          WHERE ccol.table_name = p_table_name
            AND ccol.column_name = p_column_name
          ORDER BY ccol.position
      ;
      l_count INTEGER := 0;
      r_last_cons user_constraints%ROWTYPE;
--      l_constraint_name g_short_name_type;
   BEGIN
      IF p_table_name IS NULL OR p_column_name IS NULL THEN
         RETURN NULL;
      END IF;
--      l_constraint_name := ta_tcol(p_table_name).FIRST;
--      WHILE l_constraint_name IS NOT NULL LOOP
      FOR r_cons IN c_cons(p_table_name,p_column_name) LOOP
         l_count := l_count + 1;
         r_last_cons := CASE l_count WHEN 1 THEN r_cons ELSE NULL END;
         EXIT WHEN l_count >= 2;
--         l_constraint_name := ta_tcol(p_table_name).NEXT(l_constraint_name);
      END LOOP;
      RETURN r_last_cons;
   END;
   ---
   -- Get constraint based on its name
   ---
   FUNCTION get_constraint (
      p_constraint_name IN VARCHAR2
   )
   RETURN gc_con%ROWTYPE
   IS
      r_con gc_con%ROWTYPE;
   BEGIN
      IF p_constraint_name IS NULL
      OR NOT gt_con_ass.EXISTS(p_constraint_name)
      THEN
         RETURN r_con;
      END IF;
      RETURN gt_con_ass(p_constraint_name);
   END;
   ---
   -- Check whether a constraint exists
   ---
   FUNCTION exists_constraint (
      p_constraint_name IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      r_con gc_con%ROWTYPE;
   BEGIN
      IF p_constraint_name IS NULL THEN
         RETURN FALSE;
      END IF;
      r_con := get_constraint(p_constraint_name);
      RETURN NVL(r_con.constraint_name = p_constraint_name,FALSE);
   END;
   ---
   -- Get name of foreign key made up of a single column
   ---
   FUNCTION get_fk_containing_col (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      r_cons user_constraints%ROWTYPE;
   BEGIN
      r_cons := get_fk_rec_containing_col(p_table_name,p_column_name);
      RETURN r_cons.constraint_name;
   END;
   ---
   -- Check if a column is already present in a condition or in output
   ---
   FUNCTION is_column_referenced (
      p_column IN VARCHAR2
    , p_condition IN VARCHAR2
    , pio_out IN sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   IS
      l_idx INTEGER;
      l_line g_small_buf_type;
      l_pos INTEGER;
   BEGIN
      IF INSTR(LOWER(p_condition),LOWER(p_column)) > 0 THEN
         RETURN TRUE;
      END IF;
      l_idx := pio_out.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         l_line := pio_out(l_idx);
         l_pos := INSTR(l_line,'--', 1);
         IF  l_pos > 0 THEN
            -- Ignore comments
            l_line := SUBSTR(l_line, 1, l_pos-1);
         END IF;
         IF INSTR(LOWER(l_line),LOWER(p_column)) > 0 THEN
            RETURN TRUE;
         END IF;
         l_idx := pio_out.NEXT(l_idx);
      END LOOP;
      RETURN FALSE;
   END;
   ---
   -- Get table constraints of given type(s)
   ---
   FUNCTION get_table_constraints (
      p_table_name IN VARCHAR2
    , p_constraint_type IN VARCHAR2
   )
   RETURN gt_con_idx_type
   IS
      r_con gc_con%ROWTYPE;
      t_con_idx gt_con_idx_type;
      l_constraint_name g_short_name_type;
   BEGIN
      assert(gt_tcon_ass.EXISTS(p_table_name),'Table "'||p_table_name||'" not found in cache!');
      l_constraint_name := gt_tcon_ass(p_table_name).FIRST;
      WHILE l_constraint_name IS NOT NULL LOOP
         r_con := gt_tcon_ass(p_table_name)(l_constraint_name);
         IF INSTR(p_constraint_type,r_con.constraint_type)>0 THEN
            t_con_idx(t_con_idx.COUNT+1) := r_con;
         END IF;
         l_constraint_name := gt_tcon_ass(p_table_name).NEXT(l_constraint_name);
      END LOOP;
      RETURN t_con_idx;
   END;
   ---
   -- Get constraint columns
   ---
   FUNCTION get_constraint_columns (
      p_constraint_name IN VARCHAR2
   )
   RETURN gt_ccol_idx_type
   IS
      r_ccol gc_ccol%ROWTYPE;
      t_ccol_idx gt_ccol_idx_type;
      l_column_name g_short_name_type;
   BEGIN
      load_constraint_info(p_constraint_name);
      l_column_name := gt_cccol_ass(p_constraint_name).FIRST;
      WHILE l_column_name IS NOT NULL LOOP
         r_ccol := gt_cccol_ass(p_constraint_name)(l_column_name);
         t_ccol_idx(t_ccol_idx.COUNT+1) := r_ccol;
         l_column_name := gt_cccol_ass(p_constraint_name).NEXT(l_column_name);
      END LOOP;
      RETURN t_ccol_idx;
   END;
   ---
   -- Add filter for columns which are part of pk/uk
   ---
   PROCEDURE add_table_filter (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_condition IN VARCHAR2
    , pio_out IN OUT sys.dbms_sql.varchar2a
   )
   IS
      -- Get constraint columns
      CURSOR c_col (
         p_constraint_name IN VARCHAR2
      )
      IS
         SELECT cco.*
           FROM user_cons_columns cco
          WHERE cco.constraint_name = UPPER(p_constraint_name)
          ORDER BY cco.position
      ;
      t_uk gt_con_idx_type;
      r_uk gc_con%ROWTYPE;
      t_uk_col gt_ccol_idx_type;
      l_found BOOLEAN;
   BEGIN
      -- Get all pk/uk of remote table
      t_uk := get_table_constraints(p_table_name,'PU');
      -- For each pk/uk
      FOR i IN 1..t_uk.COUNT LOOP
         r_uk := t_uk(i);
         -- Get pk/uk columns
         t_uk_col := get_constraint_columns(r_uk.constraint_name);
         assert(t_uk_col.COUNT > 0,'No columns found for constraint '||r_uk.constraint_name);
         -- For each pk/uk column
         FOR j IN t_uk_col.FIRST..t_uk_col.LAST LOOP
            IF NOT is_column_referenced(t_uk_col(j).column_name,p_condition,pio_out) THEN
               IF get_default(p_table_alias||'.'||LOWER(t_uk_col(j).column_name)) IS NOT NULL THEN
                  pio_out(pio_out.COUNT+1) := LPAD(CASE WHEN pio_out.COUNT=0 THEN ' ON ' ELSE ' AND ' END,7,' ')
                                       || p_table_alias || '.' || LOWER(t_uk_col(j).column_name) || ' = ' || get_default(p_table_alias||'.'||LOWER(t_uk_col(j).column_name)) || ' -- default dimension';
                  l_found := TRUE;
               ELSE
                  l_found := doc_utility_ext.add_column_filter(p_table_name,p_table_alias,t_uk_col(j).column_name,p_condition,pio_out);
               END IF;
            END IF;
         END LOOP;
      END LOOP;
      l_found := doc_utility_ext.add_table_filter(p_table_name,p_table_alias,p_condition,pio_out);
   END;
   ---
   -- Generate a join between 2 tables
   ---
   PROCEDURE gen_join (
      p_src_table_name IN VARCHAR2
    , p_src_table_alias IN VARCHAR2
    , p_src_condition IN VARCHAR2
    , p_constraint_name IN VARCHAR2 -- constraint name or name of a column that is part of a N-1 fk
    , p_constraint_dir IN VARCHAR2 -- "->",">-","-<","=>",">=","=<","~>",">~","~<"
    , p_tgt_table_name IN VARCHAR2
    , p_tgt_table_alias IN VARCHAR2
    , p_tgt_condition IN VARCHAR2
    , p_gen_src IN VARCHAR2 -- Y/N
    , pio_out IN OUT sys.dbms_sql.varchar2a
    , po_fk_name OUT VARCHAR2
    , po_dir OUT VARCHAR2
   )
   IS
      -- Get all uk/pk of a table
      CURSOR c_uk (
         p_table_name IN VARCHAR2
      )
      IS
         SELECT con.*
           FROM user_constraints con
          WHERE con.table_name = UPPER(p_table_name)
            AND con.constraint_type IN ('P','U')
          ORDER BY constraint_type, constraint_name
      ;
      -- Type and variable for above cursor
      TYPE t_con_ass_type IS TABLE OF gc_fk%ROWTYPE INDEX BY BINARY_INTEGER;
      t_fk t_con_ass_type;
      r_fk gc_fk%ROWTYPE;
      t_uk t_con_ass_type;
      r_uk c_uk%ROWTYPE;
--      t_fk_tmp t_con_ass_type; -- G-1030
      -- Get constraint columns
      CURSOR c_col (
         p_constraint_name IN VARCHAR2
      )
      IS
         SELECT cco.*
           FROM user_cons_columns cco
          WHERE cco.constraint_name = UPPER(p_constraint_name)
          ORDER BY cco.position
      ;
      -- Type and variable for above cursor
      TYPE t_col_idx_type IS TABLE OF c_col%ROWTYPE INDEX BY BINARY_INTEGER;
      t_fk_col t_col_idx_type;
      t_fk_rcol t_col_idx_type;
      t_uk_col t_col_idx_type;
--      t_tmp_col t_col_idx_type; -- G-1030
      -- other variables
      l_found BOOLEAN;
      t_out sys.dbms_sql.varchar2a;
      t_tmp sys.dbms_sql.varchar2a;
      l_indent VARCHAR2(20);
      l_highest_score NUMBER := 0;
      l_score NUMBER := 0;
      l_join_type VARCHAR2(10);
      l_fk_name g_long_name_type;
      -- Modified parameters
      l_src_table_name g_short_name_type := UPPER(p_src_table_name);
      l_tgt_table_name g_short_name_type := UPPER(p_tgt_table_name);
      l_constraint_name g_short_name_type := UPPER(p_constraint_name);
      l_src_table_alias g_short_name_type := LOWER(p_src_table_alias);
      l_tgt_table_alias g_short_name_type := LOWER(p_tgt_table_alias);
      l_src_alias g_short_name_type; -- without suffix
      l_tgt_alias g_short_name_type; -- without suffix
      l_column_name g_short_name_type;
      -- Variables
--      l_sysdate g_long_name_type := get_variable('sysdate'); -- G-1030
--      l_trunc_sysdate g_long_name_type := CASE WHEN l_sysdate IS NULL THEN 'TRUNC(SYSDATE)'
--                                            WHEN SUBSTR(l_sysdate,1,1) = ':' THEN l_sysdate
--                                            ELSE 'TRUNC(TO_DATE('''||l_sysdate||''',''DD.MM.YYYY''))' END; -- G-1030
   BEGIN
      assert(l_src_table_name IS NULL OR gt_tab_ass.EXISTS(l_src_table_name),'Source table does not exists!');
      assert(l_tgt_table_name IS NULL OR gt_tab_ass.EXISTS(l_tgt_table_name),'Target table does not exists!');
      assert(l_src_table_name IS NOT NULL OR l_src_table_alias IS NOT NULL,'Source table name or alias is mandatory!');
      assert(l_tgt_table_name IS NOT NULL OR l_tgt_table_alias IS NOT NULL,'Target table name or alias is mandatory!');
      assert(p_constraint_dir IN ('->','>-','-<','=>','>=','=<','~>','>~','~<'),'Invalid constraint direction!');
      IF l_src_table_name IS NULL THEN
         l_src_table_name := gt_tal_ass(l_src_table_alias);
      END IF;
      IF l_tgt_table_name IS NULL THEN
         l_tgt_table_name := gt_tal_ass(l_tgt_table_alias);
      END IF;
      IF l_src_table_alias IS NULL THEN
         l_src_table_alias := gt_tab_ass(l_src_table_name).table_alias;
      END IF;
      IF l_tgt_table_alias IS NULL THEN
         l_tgt_table_alias := gt_tab_ass(l_tgt_table_name).table_alias;
      END IF;
      l_src_alias := extract_table_alias(l_src_table_alias);
      l_tgt_alias := extract_table_alias(l_tgt_table_alias);
      IF INSTR(p_constraint_dir,'=') > 0 THEN
         l_join_type := 'INNER';
      ELSE
         l_join_type := 'LEFT OUTER';
      END IF;
      -- Derive constraint name from column name
      IF l_constraint_name IS NOT NULL THEN
         IF NOT exists_constraint(l_constraint_name) THEN
            l_column_name := l_constraint_name;
            l_constraint_name := get_fk_containing_col(l_src_table_name,l_constraint_name);
            IF l_constraint_name IS NOT NULL THEN
               l_column_name := NULL;
            END IF;
         END IF;
      END IF;
      -- Get all foreign keys between the 2 tables
      -- When several fks are found, consider only the 1st one
      OPEN gc_fk(l_src_table_name,l_constraint_name,l_tgt_table_name,l_column_name);
      FETCH gc_fk BULK COLLECT INTO t_fk;
      CLOSE gc_fk;
      l_found := t_fk.COUNT > 0;
    --assert(l_constraint_name IS NULL OR l_found,'Invalid constraint name: '||l_constraint_name||' between '||l_src_table_name||' and '||l_tgt_table_name);
      -- Any fk found?
      IF l_found AND p_constraint_dir IN ('->','>-','=>','>=','~>','>~') THEN
         po_dir := '>-'; -- many to one
         -- Display all fk found for debug
         FOR i IN t_fk.FIRST..t_fk.LAST LOOP
            debug('G',t_fk(i).constraint_name);
         END LOOP;
         -- Select first fk found
         r_fk := t_fk(t_fk.FIRST);
         l_fk_name := LOWER(r_fk.constraint_name) || ' (1st N-1 found out of ' || t_fk.COUNT || ')';
         po_fk_name := r_fk.constraint_name;
         -- Get fk constraint columns
         OPEN c_col(r_fk.constraint_name);
         FETCH c_col BULK COLLECT INTO t_fk_col;
         CLOSE c_col;
         assert(t_fk_col.COUNT > 0,'No columns found for constraint '||r_fk.constraint_name);
         -- Get remote pk/uk constraint columns
         OPEN c_col(r_fk.r_constraint_name);
         FETCH c_col BULK COLLECT INTO t_fk_rcol;
         CLOSE c_col;
         assert(t_fk_rcol.COUNT > 0,'No columns found for constraint '||r_fk.r_constraint_name);
         assert(t_fk_col.COUNT = t_fk_rcol.COUNT, 'Number of columns mismatch between '||r_fk.constraint_name||' and '||r_fk.r_constraint_name);
         -- Generate join condition
         FOR i IN 1..t_fk_col.COUNT LOOP
            debug('G',t_fk_col(i).column_name||' <-> '||t_fk_rcol(i).column_name);
            IF  NVL(INSTR(LOWER(p_tgt_condition),LOWER(l_tgt_table_alias || '.' || t_fk_rcol(i).column_name)),0) <= 0
            AND NVL(INSTR(LOWER(p_tgt_condition),LOWER(l_src_table_alias || '.' || t_fk_col(i).column_name)),0) <= 0
            THEN
               t_out(t_out.COUNT+1) := LPAD(CASE WHEN i=1 THEN ' ON ' ELSE ' AND ' END,7,' ')
                                    || l_tgt_table_alias || '.' || LOWER(t_fk_rcol(i).column_name) || '='
                                    || l_src_table_alias || '.' || LOWER(t_fk_col(i).column_name);
            END IF;
         END LOOP;
      ELSIF p_constraint_dir IN ('->','-<','=>','=<','~>','~<') THEN
       --assert(l_constraint_name IS NULL,'Foreign key '||l_constraint_name||' between '||l_src_table_name||' and '||l_tgt_table_name||' not found!');
         po_dir := '-<'; -- one to many
         -- Look for inverse fk
         OPEN gc_fk(l_tgt_table_name,l_constraint_name,l_src_table_name,l_column_name);
         FETCH gc_fk BULK COLLECT INTO t_fk;
         CLOSE gc_fk;
         l_found := t_fk.COUNT > 0;
         IF NOT l_found AND INSTR(p_constraint_dir,'~')>0 THEN
          --sys.dbms_output.Put_line('SKIP');
            GOTO end_proc;
         END IF;
         assert(l_found,'No foreign key found between '||l_tgt_table_name||' and '||l_src_table_name);
         -- Get all pk/uk of remote table
         OPEN c_uk(l_tgt_table_name);
         FETCH c_uk BULK COLLECT INTO t_uk;
         CLOSE c_uk;
         l_found := t_uk.COUNT > 0;
       --assert(l_found,'No unique/primary key found for '||l_tgt_table_name);
         IF NOT l_found THEN
            debug('G','No uk/pk found!');
         END IF;
         -- Display uk/pk for debug
         FOR i IN 1..t_uk.COUNT LOOP
            r_uk := t_uk(i);
            debug('G',UPPER(r_uk.constraint_type)||'K '||r_uk.constraint_name);
         END LOOP;
         -- For each reverse fk found
         FOR i IN 1..t_fk.COUNT LOOP
            -- Init
            r_fk := t_fk(i);
            -- Get fk columns
            OPEN c_col(r_fk.constraint_name);
            FETCH c_col BULK COLLECT INTO t_fk_col;
            CLOSE c_col;
            assert(t_fk_col.COUNT > 0,'No columns found for constraint '||r_fk.constraint_name);
            FOR j IN 1..t_fk_col.COUNT LOOP
               debug('G',r_fk.constraint_name||': '||t_fk_col(j).column_name);
            END LOOP;
            -- Get remote pk/uk constraint columns
            OPEN c_col(r_fk.r_constraint_name);
            FETCH c_col BULK COLLECT INTO t_fk_rcol;
            CLOSE c_col;
            assert(t_fk_rcol.COUNT > 0,'No columns found for constraint '||r_fk.r_constraint_name);
            assert(t_fk_col.COUNT = t_fk_rcol.COUNT, 'Number of columns mismatch between '||r_fk.constraint_name||' and '||r_fk.r_constraint_name);
            -- For each uk/pk found
            FOR j IN 1..t_uk.COUNT LOOP
               -- Init
               r_uk := t_uk(j);
               t_tmp.DELETE;
               l_score := 0;
               -- Get uk columns
               OPEN c_col(r_uk.constraint_name);
               FETCH c_col BULK COLLECT INTO t_uk_col;
               CLOSE c_col;
               assert(t_uk_col.COUNT > 0,'No columns found for constraint '||r_uk.constraint_name);
               FOR k IN t_uk_col.FIRST..t_uk_col.LAST LOOP
                  debug('G',r_uk.constraint_name||': '||t_uk_col(k).column_name);
               END LOOP;
               -- Check that all fk columns are included in uk/pk columns
               FOR k IN t_fk_col.FIRST..t_fk_col.LAST LOOP
                  FOR l IN t_uk_col.FIRST..t_uk_col.LAST LOOP
                     l_found := t_uk_col(l).column_name = t_fk_col(k).column_name;
                     EXIT WHEN l_found;
                  END LOOP;
                  EXIT WHEN NOT l_found;
               END LOOP;
               IF l_found THEN
                  -- Check columns of uk that are not part of fk
                  debug('G','fk '||r_fk.constraint_name||' is included in uk '||r_uk.constraint_name);
                  FOR k IN t_uk_col.FIRST..t_uk_col.LAST LOOP
                     FOR l IN t_fk_col.FIRST..t_fk_col.LAST LOOP
                        l_found := t_uk_col(k).column_name = t_fk_col(l).column_name;
                        debug('G','column '||t_uk_col(k).column_name||' matches');
                        IF l_found THEN
                          debug('G','column '||t_uk_col(k).column_name||' matches');
                          debug('G','target condition: '||p_tgt_condition);
                           IF  NVL(INSTR(LOWER(p_tgt_condition),LOWER(l_tgt_table_alias || '.' || t_uk_col(k).column_name)),0) <= 0
                           AND NVL(INSTR(LOWER(p_tgt_condition),LOWER(l_src_table_alias || '.' || t_fk_rcol(l).column_name)),0) <= 0
                           THEN
                               t_tmp(t_tmp.COUNT+1) := LPAD(CASE WHEN t_tmp.COUNT=0 THEN ' ON ' ELSE ' AND ' END,7,' ')
                                                    || l_tgt_table_alias || '.' || LOWER(t_uk_col(k).column_name) || '='
                                                    || l_src_table_alias || '.' || LOWER(t_fk_rcol(l).column_name)
                                                    ;
                               EXIT;
                               l_score := l_score + 4;
                           END IF;
                        END IF;
                     END LOOP;
                     -- Column of uk was not found in fk
                     IF NOT l_found THEN
                        IF NVL(INSTR(LOWER(p_tgt_condition),LOWER(t_uk_col(k).column_name)),0) > 0 THEN
                           debug('G','ok, column '||t_uk_col(k).column_name||' found in condition '||p_tgt_condition);
                           l_found := TRUE;
                           l_score := l_score + 3;
                        ELSIF get_default(l_tgt_alias||'.'||LOWER(t_uk_col(k).column_name)) IS NOT NULL THEN
                           debug('G','ok, default found for column '||t_uk_col(k).column_name);
                           l_found := TRUE;
                           l_score := l_score + 3;
                           t_tmp(t_tmp.COUNT+1) := LPAD(CASE WHEN t_tmp.COUNT=0 THEN ' ON ' ELSE ' AND ' END,7,' ')
                                                || l_tgt_table_alias || '.' || LOWER(t_uk_col(k).column_name) || ' = ' || get_default(l_tgt_alias||'.'||LOWER(t_uk_col(k).column_name)) || ' -- default dimension';
                        ELSIF doc_utility_ext.add_column_filter(l_tgt_table_name,l_tgt_table_alias,t_uk_col(k).column_name,p_tgt_condition,t_tmp) THEN
                           l_found := TRUE;
                           l_score := l_score + 2;
                        ELSE
                           l_found := TRUE;
                           l_score := l_score + 1;
                           IF t_tmp.COUNT=0 THEN
                              t_tmp(t_tmp.COUNT+1) := LPAD(' ON ',7,' ') || '1=1';
                           END IF;
                           IF add_comment('--') IS NOT NULL THEN
                              t_tmp(t_tmp.COUNT+1) := LPAD(' --AND ',7,' ')
                                                   || l_tgt_table_alias || '.' || LOWER(t_uk_col(k).column_name) || '=???'||add_comment(' -- not filtered!');
                           END IF;
                           debug('G','ko, column '||t_uk_col(k).column_name||' won''t be filtered!');
                        END IF;
                     END IF;
                     EXIT WHEN NOT l_found;
                  END LOOP; -- for each uk/pk column
               END IF; -- fk included in uk/pk
               IF l_found THEN
                  l_score := (l_score / t_uk_col.COUNT) / 4; -- max is 1
                  l_fk_name := LOWER(r_fk.constraint_name) || ' (prefix of '||LOWER(r_uk.constraint_name)||')';
                  debug('G','fk '||r_fk.constraint_name||', uk '||r_uk.constraint_name||': score='||l_score||', highest='||l_highest_score);
                  IF l_score > l_highest_score THEN
                     l_highest_score := l_score;
                     t_out := t_tmp;
                     po_fk_name := r_fk.constraint_name;
                  END IF;
                  debug('G','BINGO!');
               ELSE
                  debug('G','uk '||r_uk.constraint_name||' is NOT included in fk '||r_fk.constraint_name);
               END IF;
            END LOOP; -- For each uk/pk
         END LOOP; -- For each fk
         -- Take first fk if no join generated so far (e.g. no uk/pk included in fk)
         IF l_highest_score<=0 THEN
            -- Init
            r_fk := t_fk(1);
            l_fk_name := LOWER(r_fk.constraint_name) || ' (1st 1-N found out of ' || t_fk.COUNT || ')';
            po_fk_name := r_fk.constraint_name;
            -- Get fk columns
            OPEN c_col(r_fk.constraint_name);
            FETCH c_col BULK COLLECT INTO t_fk_col;
            CLOSE c_col;
            assert(t_fk_col.COUNT > 0,'No columns found for constraint '||r_fk.constraint_name);
            FOR j IN 1..t_fk_col.COUNT LOOP
               t_out(t_out.COUNT+1) := LPAD(CASE WHEN t_out.COUNT=0 THEN ' ON ' ELSE ' AND ' END,7,' ')
                                    || l_tgt_table_alias || '.' || LOWER(t_fk_col(j).column_name) || '='
                                    || l_src_table_alias || '.' || LOWER(t_fk_rcol(j).column_name);
            END LOOP;
         END IF;
         add_table_filter(l_tgt_table_name,l_tgt_table_alias,p_tgt_condition,t_out);
      ELSE
         RETURN;
      END IF; -- 1-N relation
      <<end_proc>>
      -- Compute indentation
      IF l_join_type = 'INNER' THEN
         l_indent := ' ';
      ELSE
         l_indent := '  ';
      END IF;
      -- Generate join
      IF p_gen_src = 'Y' THEN
         pio_out(pio_out.COUNT+1) := l_indent||l_join_type||' JOIN ' || LOWER(l_src_table_name) || ' ' || l_src_table_alias || add_comment(' -- ' || NVL(l_fk_name,'no foreign key!'));
         IF p_src_condition IS NOT NULL THEN
            pio_out(pio_out.COUNT+1) := LPAD(' ON ',7,' ') || '(' || prefix_columns(p_src_condition,l_src_table_name,l_src_table_alias) || ')' || add_comment(' -- custom filter');
         END IF;
      END IF;
      pio_out(pio_out.COUNT+1) := l_indent||l_join_type||' JOIN ' || LOWER(l_tgt_table_name) || ' ' || l_tgt_table_alias  || add_comment(' -- ' || NVL(l_fk_name,'no foreign key!'));
      FOR i IN 1..t_out.COUNT LOOP
         pio_out(pio_out.COUNT+1) := t_out(i);
      END LOOP;
      IF p_tgt_condition IS NOT NULL THEN
         pio_out(pio_out.COUNT+1) := LPAD(CASE WHEN t_out.COUNT=0 THEN ' ON ' ELSE ' AND ' END,7,' ')
                              || '(' || prefix_columns(p_tgt_condition,l_tgt_table_name,l_tgt_table_alias) || ')' || add_comment(' -- custom filter');
      END IF;
   END;
   ---
   -- Get token
   ---
   FUNCTION get_token (
      p_str IN VARCHAR2
    , p_beg IN INTEGER
    , p_sep IN VARCHAR2
   )
   RETURN INTEGER
   IS
      l_pos INTEGER := p_beg;
      l_chr VARCHAR2(1);
      l_sep VARCHAR2(1);
   BEGIN
      l_chr := SUBSTR(p_str,l_pos,1);
      IF l_chr IS NULL THEN
         RETURN l_pos; -- end already reached!
      END IF;
      l_pos := l_pos + 1;
      l_chr := SUBSTR(p_str,l_pos,1);
      WHILE l_chr IS NOT NULL AND l_chr != p_sep LOOP
         IF l_chr = '(' THEN
            l_sep := ')';
         ELSIF l_chr = '''' THEN
            l_sep := '''';
         ELSIF l_chr = '"' THEN
            l_sep := '"';
         ELSE
            l_sep := NULL;
         END IF;
         IF l_sep IS NOT NULL THEN
            l_pos := get_token(p_str,l_pos,l_sep);
            l_chr := SUBSTR(p_str,l_pos,1);
            assert(l_chr IS NOT NULL AND l_chr = l_sep,'No matching '||l_sep);
         END IF;
         l_pos := l_pos + 1;
         l_chr := SUBSTR(p_str,l_pos,1);
      END LOOP;
      RETURN l_pos;
   END;
   ---
   -- Parse select list
   ---
   PROCEDURE parse_select_list (
      pio_out IN OUT sys.dbms_sql.varchar2a
    , p_select IN VARCHAR2
   )
   IS
      l_beg INTEGER;
      l_end INTEGER;
      l_pos INTEGER;
      l_col g_small_buf_type;
      PROCEDURE add_item (
         p_line IN VARCHAR2
      )
      IS
         l_line g_small_buf_type := p_line;
         l_table_alias g_short_name_type;
         l_query_alias g_short_name_type;
         l_table_name g_short_name_type;
         l_column_name g_short_name_type;
      BEGIN
         consume_leading_spaces(l_line);
         IF NVL(NOT is_letter(SUBSTR(l_line,1,1)),FALSE) THEN
debug('P',p_line||': doesn''t start with a letter');
            GOTO end_proc;
         END IF;
         l_query_alias := LOWER(consume_word(l_line));
         IF NVL(NOT gt_qal_ass.EXISTS(l_query_alias),FALSE) THEN
debug('P',p_line||': query alias not found');
            GOTO end_proc;
         END IF;
         l_table_alias := extract_table_alias(l_query_alias);
         IF NVL(NOT gt_tal_ass.EXISTS(l_table_alias),FALSE) THEN
debug('P',p_line||': table alias not found');
            GOTO end_proc;
         END IF;
         l_table_name := gt_tal_ass(l_table_alias);
         IF NOT NVL(SUBSTR(l_line,1,1) = '.',FALSE) THEN
debug('P',p_line||': dot not found after query alias');
            GOTO end_proc;
         END IF;
         consume_keyword(l_line,'.');
         IF NOT NVL(SUBSTR(l_line,1,1) = '*',FALSE) THEN
debug('P',p_line||': star not found after dot');
            GOTO end_proc;
         END IF;
         consume_keyword(l_line,'*');
         IF l_line IS NOT NULL THEN
debug('P',p_line||': characters found after star');
            GOTO end_proc;
         END IF;
debug('P',p_line||': bingo!');
         FOR r_tcol IN gc_tcol(l_table_name) LOOP
             pio_out(pio_out.COUNT+1) := l_query_alias||'.'||LOWER(r_tcol.column_name);
         END LOOP;
         RETURN;
         <<end_proc>>
         pio_out(pio_out.COUNT+1) := p_line;
      END;
   BEGIN
      pio_out.DELETE;
      l_beg := 0;
      l_pos := get_token(p_select,l_beg,',');
      WHILE l_pos > l_beg LOOP
         IF SUBSTR(p_select,l_pos,1) = ',' THEN
            l_end := l_pos-1;
         ELSE
            l_end := l_pos;
         END IF;
         add_item(TRIM(SUBSTR(p_select,l_beg+1,l_end-l_beg)));
         l_beg := l_pos;
         l_pos := get_token(p_select,l_beg,',');
      END LOOP;
   END;
   ---
   -- Parse command
   ---
   PROCEDURE parse (
      pio_qry IN OUT doc_utility_var.gr_qry_type
    , p_distance IN BINARY_DOUBLE := NULL -- define preferred path when set
   )
   IS
      l_table_alias g_short_name_type;
      l_line g_small_buf_type;
      l_dijkstra g_small_buf_type;
      l_source VARCHAR2(60);
      l_target VARCHAR2(60);
      l_src_query_alias g_short_name_type;
      l_tgt_query_alias g_short_name_type;
      l_src_table_alias g_short_name_type;
      l_tgt_table_alias g_short_name_type;
      l_src_table_name g_short_name_type;
      l_tgt_table_name g_short_name_type;
      l_src_condition g_small_buf_type;
--      l_src_condition_sav g_small_buf_type; -- G-1030
      l_tgt_condition g_small_buf_type;
      l_constraint_name g_short_name_type;
      l_constraint_dir VARCHAR2(3);
      l_join_type VARCHAR2(20);
      l_stat_count INTEGER := 0;
      l_join_count INTEGER := 0;
      l_alias_count INTEGER := 0;
      t_where sys.dbms_sql.varchar2a;
      l_where g_small_buf_type;
      l_sep VARCHAR2(3);
      l_sel VARCHAR2(200);
      t_from sys.dbms_sql.varchar2a;
      t_col gt_str_ass_type; -- column aliases
      t_sel sys.dbms_sql.varchar2a;
      l_count INTEGER;
      l_idx INTEGER;
      l_fk_name g_short_name_type;
      l_dir g_short_name_type;
      r_qry doc_utility_var.gr_qry_type;
      FUNCTION parse_descr (
         p_line IN VARCHAR2
       , p_idx IN INTEGER
      )
      RETURN VARCHAR2
      IS
         l_line g_small_buf_type := p_line;
         l_source VARCHAR2(60);
         l_src_table_name g_short_name_type;
         l_tgt_table_name g_short_name_type;
         l_src_query_alias g_short_name_type;
         l_tgt_query_alias g_short_name_type;
         l_all_query_alias g_short_name_type;
         l_src_table_alias g_short_name_type;
         l_column_name g_short_name_type;
         l_full_column_name VARCHAR2(61);
         l_count INTEGER := 0;
         r_fk user_constraints%ROWTYPE;
         r_rfk gc_con%ROWTYPE;
         l_beg INTEGER;
         l_end INTEGER;
         l_col VARCHAR2(200) := LOWER(p_line);
         l_fk_name g_short_name_type;
         l_dir g_short_name_type;
      BEGIN
         -- Search for column alias (enclosed in double quotes)
         l_beg := get_token(p_line,0,'"');
         IF l_beg > 0 AND SUBSTR(p_line,l_beg,1)='"' THEN
            l_end := get_token(p_line,l_beg+1,'"');
            assert(SUBSTR(p_line,l_end,1) = '"','unmatched double quotes: '||p_line);
            l_col := LOWER(SUBSTR(p_line,l_beg+1,l_end-1-l_beg));
debug('P',p_line||': found column alias from '||l_beg||' to '||l_end||': '||l_col);
            GOTO end_proc;
         END IF;
         consume_leading_spaces(l_line);
         IF NVL(NOT is_letter(SUBSTR(l_line,1,1)),FALSE) THEN
debug('P',p_line||': doesn''t start with a letter');
            GOTO end_proc;
         END IF;
         l_src_query_alias := LOWER(consume_word(l_line));
         IF NVL(NOT gt_qal_ass.EXISTS(l_src_query_alias),FALSE) THEN
debug('P',p_line||': query alias not found');
            GOTO end_proc;
         END IF;
         l_all_query_alias := l_src_query_alias;
         l_src_table_alias := extract_table_alias(l_src_query_alias);
         IF NVL(NOT gt_tal_ass.EXISTS(l_src_table_alias),FALSE) THEN
debug('P',p_line||': table alias not found');
            GOTO end_proc;
         END IF;
         l_src_table_name := gt_tal_ass(l_src_table_alias);
         IF NOT NVL(SUBSTR(l_line,1,1) = '.',FALSE) THEN
debug('P',p_line||': dot not found after query alias');
            GOTO end_proc;
         END IF;
         WHILE SUBSTR(l_line,1,1) = '.' LOOP
            l_count := l_count + 1;
            consume_keyword(l_line,'.');
            l_column_name := UPPER(consume_word(l_line));
            l_full_column_name := l_src_table_name||'.'||l_column_name;
            IF NOT exists_table_column(l_src_table_name,l_column_name) THEN
debug('P',p_line||': invalid column name: '||l_full_column_name);
               GOTO end_proc;
            END IF;
            IF SUBSTR(l_line,1,1) = '.' THEN
               r_fk := get_fk_rec_containing_col(l_src_table_name,l_column_name);
               IF r_fk.constraint_name IS NULL THEN
debug('P',p_line||': no fk constraint found for '||l_full_column_name);
                  GOTO end_proc;
               END IF;
               r_rfk := get_constraint(r_fk.r_constraint_name);
               assert(r_rfk.constraint_name IS NOT NULL,'constraint '||r_fk.r_constraint_name||' not found!');
               l_tgt_table_name := r_rfk.table_name;
               l_tgt_query_alias := get_table_alias(l_tgt_table_name);
               assert(l_tgt_query_alias IS NOT NULL,'alias of '||l_tgt_table_name||' not found!');
               l_all_query_alias := l_all_query_alias||'_'||l_tgt_query_alias;
               l_tgt_query_alias := l_all_query_alias;
               l_alias_count := 1;
               WHILE gt_qal_ass.EXISTS(l_tgt_query_alias) LOOP
                  l_alias_count := l_alias_count + 1;
                  l_tgt_query_alias := l_tgt_query_alias||l_alias_count;
                  assert(l_alias_count<100,'Infinite loop detected while generating alias!');
               END LOOP;
               gt_qal_ass(l_tgt_query_alias) := l_tgt_table_name;
               gen_join(
                  p_src_table_name => l_src_table_name
                , p_src_table_alias => l_src_query_alias
                , p_src_condition => NULL
                , p_constraint_name => l_column_name
                , p_constraint_dir => '->'
                , p_tgt_table_name => l_tgt_table_name
                , p_tgt_table_alias => l_tgt_query_alias
                , p_tgt_condition => NULL
                , p_gen_src => 'N'
                , pio_out => t_from
                , po_fk_name => l_fk_name
                , po_dir => l_dir
               );
               l_src_table_name := l_tgt_table_name;
               l_src_query_alias := l_tgt_query_alias;
            ELSIF l_line IS NOT NULL THEN
debug('P',p_line||': unexpected character found after column_name'||l_full_column_name);
               GOTO end_proc;
            END IF;
         END LOOP;
         IF t_col.EXISTS(l_col) THEN
debug('P',p_line||': already selected => ignored: '||l_col);
            RETURN NULL;
         ELSE
            t_col(l_col) := l_col;
            pio_qry.t_col(pio_qry.t_col.COUNT+1) := l_col;
         END IF;
debug('P',p_line||': bingo!');
         RETURN l_src_query_alias||'.'||LOWER(l_column_name);
         <<end_proc>>
         IF t_col.EXISTS(l_col) THEN
debug('P',p_line||': already selected => ignored: '||l_col);
            RETURN NULL;
         ELSE
            t_col(l_col) := l_col;
            pio_qry.t_col(pio_qry.t_col.COUNT+1) := l_col;
         END IF;
         RETURN p_line;
      END;
      -- Get input variable
      PROCEDURE get_input_var (
         pio_line IN OUT VARCHAR2
      )
      IS
         l_line g_small_buf_type := pio_line;
         l_pos INTEGER;
         l_beg INTEGER;
         l_chr VARCHAR2(1);
         l_var VARCHAR2(200);
      BEGIN
         l_pos := NVL(INSTR(l_line,':'),0);
         WHILE l_pos > 0 LOOP
            l_pos := l_pos + 1; -- skip colon
            l_beg := l_pos;
            l_chr := SUBSTR(l_line,l_pos,1);
            WHILE l_chr BETWEEN 'a' AND 'z'
               OR l_chr BETWEEN 'A' AND 'Z'
               OR l_chr BETWEEN '0' AND '9'
               OR l_chr IN ('_','$','.')
            LOOP
               l_pos := l_pos + 1;
               l_chr := SUBSTR(l_line,l_pos,1);
            END LOOP;
            assert(l_pos>l_beg,'No variable name found after colon!');
            l_var := SUBSTR(l_line,l_beg,l_pos-l_beg);
--TBD: remove duplicate vars!
IF pio_qry.t_var.COUNT=0 OR pio_qry.t_var(pio_qry.t_var.COUNT)!=l_var THEN
            pio_qry.t_var(pio_qry.t_var.COUNT+1) := l_var;
--sys.dbms_output.put_line('VAR: '||l_var);
END IF;
            IF INSTR(l_var,'.') > 0 THEN
               l_pos := INSTR(l_line,':'||l_var);
               assert(l_pos>0,'Variable not found!');
               pio_line := SUBSTR(pio_line,1,l_pos-1)
                      || ':'||SUBSTR(REPLACE(l_var,'.','$'),1,30)
                      || SUBSTR(pio_line,l_pos+LENGTH(l_var)+1);
            END IF;
            l_pos := NVL(INSTR(l_line,':',l_pos+1),0);
         END LOOP;
      END;
      -- Define columns
      PROCEDURE define_columns (
         p_cursor IN INTEGER
      )
      IS
         l_char g_big_buf_type;
         l_number NUMBER;
         l_date DATE;
         l_timestamp TIMESTAMP;
      BEGIN
         FOR i IN 1..pio_qry.t_desc.COUNT LOOP
            debug('P',i||': '||pio_qry.t_desc(i).col_name||' '||pio_qry.t_desc(i).col_type||' '||pio_qry.t_desc(i).col_max_len);
            IF pio_qry.t_desc(i).col_type = 1 /* VARCHAR2 */THEN
               sys.dbms_sql.define_column(p_cursor,i,l_char,pio_qry.t_desc(i).col_max_len);
            ELSIF pio_qry.t_desc(i).col_type = 2 /* NUMBER */ THEN
               sys.dbms_sql.define_column(p_cursor,i,l_number);
            ELSIF pio_qry.t_desc(i).col_type = 12 /* DATE */THEN
               sys.dbms_sql.define_column(p_cursor,i,l_date);
            ELSIF pio_qry.t_desc(i).col_type = 180 /* TIMESTAMP */THEN
               sys.dbms_sql.define_column(p_cursor,i,l_timestamp);
            ELSE
             --raise_application_error(-20000,'Unsupported data type: '||pio_qry.t_desc_tab(i).col_type);
               NULL;
            END IF;
         END LOOP;
      END;
   BEGIN
      debug('E','-> parse('||pio_qry.qry_name||')');
      -- Check if query is alredy in cache
      IF p_distance IS NULL THEN
         l_idx := doc_utility_var.gt_qry_idx.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            r_qry := doc_utility_var.gt_qry_idx(l_idx);
            IF  NVL(r_qry.l_select,'~') = NVL(pio_qry.l_select,'~')
            AND NVL(r_qry.l_from,'~') = NVL(pio_qry.l_from,'~')
            AND NVL(r_qry.l_where,'~') = NVL(pio_qry.l_where,'~')
            AND NVL(r_qry.l_order_by,'~') = NVL(pio_qry.l_order_by,'~')
            AND NVL(r_qry.l_prefix,'~') = NVL(pio_qry.l_prefix,'~')
            AND NVL(r_qry.l_suffix,'~') = NVL(pio_qry.l_suffix,'~')
            THEN
               -- Take parsed query from cache
               pio_qry := r_qry;
         debug('E','query '||pio_qry.qry_name||'found in cache');
               GOTO open_cursor;
            END IF;
            l_idx := doc_utility_var.gt_qry_idx.NEXT(l_idx);
         END LOOP;
         debug('E','query '||pio_qry.qry_name||'not found in cache');
      END IF;
      -- Parse query
      debug('E','parsing DAPL...');
      gt_qal_ass.DELETE;
      pio_qry.t_out.DELETE;
      pio_qry.t_sel.DELETE;
      pio_qry.t_var.DELETE;
      pio_qry.t_col.DELETE;
      pio_qry.l_cursor := NULL;
      pio_qry.t_desc.DELETE;
      pio_qry.l_count := NULL;
      pio_qry.l_tot_count := NULL;
      pio_qry.l_path := NULL;
      -- Parse query
      l_line := REPLACE(REPLACE(REPLACE(pio_qry.l_from,'\"','\$'),'"',''''),'\$','"');
      consume_leading_spaces(l_line);
      WHILE l_stat_count=0 OR SUBSTR(l_line,1,1) = ';' LOOP
         l_join_count := 0;
         l_stat_count := l_stat_count + 1;
         IF l_stat_count > 1 THEN
            consume_keyword(l_line,';');
            consume_leading_spaces(l_line);
            pio_qry.l_path := pio_qry.l_path || ';';
         END IF;
         l_src_table_name := NULL;
         l_src_table_alias := NULL;
         l_src_query_alias := NULL;
         l_src_condition := NULL;
         assert(is_letter(SUBSTR(l_line,1,1)),'Syntax error: table name or alias expected');
         l_source := UPPER(consume_word(l_line));
         consume_leading_spaces(l_line);
         IF gt_tab_ass.EXISTS(l_source) THEN
            -- Table name given
            l_src_table_name := l_source;
            IF is_letter(SUBSTR(l_line,1,1)) THEN
               -- Query alias given, take it!
               l_src_query_alias := LOWER(consume_word(l_line));
               consume_leading_spaces(l_line);
               l_src_table_alias := extract_table_alias(l_src_query_alias);
            ELSE
               -- No query alias found, generate one!
               l_src_table_alias := gt_tab_ass(l_src_table_name).table_alias;
               IF l_stat_count = 1 THEN
                  l_src_query_alias := generate_query_alias(l_src_table_name);
               ELSE
                  l_src_query_alias := l_src_table_alias;
               END IF;
            END IF;
         ELSE
            l_src_query_alias := LOWER(l_source);
            l_src_table_alias := extract_table_alias(l_src_query_alias);
            assert(gt_tal_ass.EXISTS(l_src_table_alias),'Table alias "'||l_src_table_alias||'" does not exist!');
            l_src_table_name := gt_tal_ass(l_src_table_alias);
         END IF;
         IF l_stat_count = 1 THEN
            gt_qal_ass(l_src_query_alias) := l_src_table_name;
         ELSE
            assert(gt_qal_ass.EXISTS(l_src_query_alias),'Query alias "'||l_src_query_alias||'" not defined before!');
         END IF;
         pio_qry.l_path := pio_qry.l_path || l_src_query_alias;
         IF SUBSTR(l_line,1,1) = '[' THEN
            l_src_condition := consume_condition(l_line);
            pio_qry.l_path := pio_qry.l_path || '[...]';
         END IF;
         IF l_stat_count = 1 THEN
            t_from(t_from.COUNT+1) := '  FROM '||LOWER(l_src_table_name)||' '||l_src_query_alias;
            IF l_src_condition IS NOT NULL THEN
               t_where(t_where.COUNT+1) := ' WHERE ('||prefix_columns(l_src_condition,l_src_table_name,l_src_query_alias) || ')' || add_comment(' -- custom filter');
            END IF;
            IF pio_qry.l_where IS NOT NULL THEN
               t_where(t_where.COUNT+1) := CASE WHEN t_where.COUNT=0 THEN ' WHERE ' ELSE '   AND ' END||' (' || pio_qry.l_where || ')';
            END IF;
            IF t_where.COUNT = 0 THEN
               t_where(t_where.COUNT+1) := ' WHERE 1=1';
            END IF;
            -- Add filter for columns which are part of pk/uk
            add_table_filter(l_src_table_name,l_src_query_alias,l_src_condition,t_where);
            -- Delete useless filter
            IF t_where(t_where.COUNT) = ' WHERE 1=1' THEN
               t_where.DELETE;
            END IF;
         END IF;
         consume_leading_spaces(l_line);
         WHILE SUBSTR(l_line,1,1) = ','
            OR SUBSTR(l_line,1,2) IN ('->','>-','-<','=>','>=','=<','~>','>~','~<')
            OR SUBSTR(l_line,1,3) IN ('-->','>--','--<','==>','>==','==<','~~>','>~~','~~<')
         LOOP
            l_join_count := l_join_count + 1;
            IF SUBSTR(l_line,1,1) = ',' THEN
               l_sep := SUBSTR(l_line,1,1);
               consume_keyword(l_line,',');
               assert(l_join_count>1,'Syntax error: "arrow" expected');
            ELSIF SUBSTR(l_line,1,2) IN ('->','>-','-<','=>','>=','=<','~>','>~','~<') THEN
               l_sep := SUBSTR(l_line,1,2);
               l_constraint_dir := l_sep;
               consume_keyword(l_line,l_sep);
            ELSE
               l_sep := SUBSTR(l_line,1,3);
               l_constraint_dir := l_sep;
               consume_keyword(l_line,l_sep);
            END IF;
            IF l_join_count > 1 THEN
               IF l_sep != ',' AND LENGTH(l_sep)!=3 THEN
                  l_src_table_name := l_tgt_table_name;
                  l_src_query_alias := l_tgt_query_alias;
                  l_src_table_alias := l_tgt_table_alias;
               END IF;
               l_src_condition := NULL;
            END IF;
            l_constraint_name := NULL;
            l_tgt_table_name := NULL;
            l_tgt_table_alias := NULL;
            l_tgt_query_alias := NULL;
            l_tgt_condition := NULL;
            consume_leading_spaces(l_line);
            IF SUBSTR(l_line,1,1) = '[' THEN
               l_constraint_name := consume_condition(l_line);
               consume_leading_spaces(l_line);
            END IF;
            assert(is_letter(SUBSTR(l_line,1,1)),'Syntax error: table name or alias expected');
            l_target := UPPER(consume_word(l_line));
            consume_leading_spaces(l_line);
            IF gt_tab_ass.EXISTS(l_target) THEN
               -- Table name given
               l_tgt_table_name := l_target;
               IF is_letter(SUBSTR(l_line,1,1)) THEN
                  -- Query alias given, take it!
                  l_tgt_query_alias := LOWER(consume_word(l_line));
                  consume_leading_spaces(l_line);
                  l_tgt_table_alias := extract_table_alias(l_tgt_query_alias);
               ELSE
                  -- No query alias found, get official one!
                  l_tgt_table_alias := gt_tab_ass(l_tgt_table_name).table_alias;
                  l_tgt_query_alias := l_tgt_table_alias;
               END IF;
            ELSE
               l_tgt_query_alias := LOWER(l_target);
               l_tgt_table_alias := extract_table_alias(l_tgt_query_alias);
            END IF;
            assert(gt_tal_ass.EXISTS(l_tgt_table_alias),'Table alias "'||l_tgt_table_alias||'" does not exist!');
            assert(NOT gt_qal_ass.EXISTS(l_tgt_query_alias),'Query alias "'||l_tgt_query_alias||'" cannot be used twice!');
            gt_qal_ass(l_tgt_table_alias) := l_tgt_table_name;
            l_tgt_table_name := gt_tal_ass(l_tgt_table_alias);
            IF LENGTH(l_sep) = 3 THEN
               l_dijkstra := do_dijkstra(l_src_query_alias,l_tgt_query_alias,l_constraint_dir);
               gt_qal_ass.DELETE(l_tgt_table_alias);
               assert(l_dijkstra IS NOT NULL,'Cannot find a path between "'||l_src_table_name||'" and "'||l_tgt_table_name||'"!');
               l_line := SUBSTR(l_dijkstra,LENGTH(l_src_query_alias)+1)||l_line;
               l_tgt_table_name := l_src_table_name;
               l_tgt_query_alias := l_src_query_alias;
               l_tgt_table_alias := l_src_table_alias;
            ELSE
               pio_qry.l_path := pio_qry.l_path || l_sep || CASE WHEN l_constraint_name IS NOT NULL THEN '['||l_constraint_name||']' END || l_tgt_query_alias;
               IF SUBSTR(l_line,1,1) = '[' THEN
                  l_tgt_condition := consume_condition(l_line);
                  consume_leading_spaces(l_line);
                  pio_qry.l_path := pio_qry.l_path || '[...]';
               END IF;
               gen_join(
                  p_src_table_name => l_src_table_name
                , p_src_table_alias => l_src_query_alias
                , p_src_condition => l_src_condition
                , p_constraint_name => l_constraint_name
                , p_constraint_dir => l_constraint_dir
                , p_tgt_table_name => l_tgt_table_name
                , p_tgt_table_alias => l_tgt_query_alias
                , p_tgt_condition => l_tgt_condition
                , p_gen_src => 'N'
                , pio_out => t_from
                , po_fk_name => l_fk_name
                , po_dir => l_dir
               );
               IF l_fk_name IS NOT NULL AND p_distance IS NOT NULL THEN
                  set_edge_distance(l_fk_name, p_distance); -- both directions
               END IF;
            END IF;
            consume_leading_spaces(l_line);
         END LOOP; -- for each arrow or comma
         consume_leading_spaces(l_line);
      END LOOP; -- for each comma separated statement
      IF p_distance IS NOT NULL THEN
         GOTO end_proc;
      END IF;
      -- Get list of selected columns/expressions
      parse_select_list(t_sel,NVL(REPLACE(REPLACE(REPLACE(pio_qry.l_select,'\"','\$'),'"',''''),'\$','"'),/*'*'*/'''x'' dummy'));
      IF pio_qry.l_prefix IS NOT NULL THEN
         pio_qry.t_out(pio_qry.t_out.COUNT+1) := pio_qry.l_prefix;
      END IF;
      -- Generate final query
      FOR i IN 1..t_sel.COUNT LOOP
         l_sel := parse_descr(t_sel(i),i);
         IF l_sel IS NOT NULL THEN
            pio_qry.t_sel(pio_qry.t_sel.COUNT+1) := l_sel;
            pio_qry.t_out(pio_qry.t_out.COUNT+1) := CASE WHEN i=1 THEN 'SELECT ' ELSE '     , ' END || l_sel;
         END IF;
      END LOOP;
      FOR i IN 1..t_from.COUNT LOOP
         pio_qry.t_out(pio_qry.t_out.COUNT+1) := t_from(i);
      END LOOP;
      FOR i IN 1..t_where.COUNT LOOP
         pio_qry.t_out(pio_qry.t_out.COUNT+1) := t_where(i);
      END LOOP;
      IF pio_qry.l_order_by IS NOT NULL THEN
         pio_qry.t_out(pio_qry.t_out.COUNT+1) := ' ORDER BY '||REPLACE(REPLACE(REPLACE(pio_qry.l_order_by,'\"','\$'),'"',''''),'\$','"');
      END IF;
      IF pio_qry.l_suffix IS NOT NULL THEN
         pio_qry.t_out(pio_qry.t_out.COUNT+1) := pio_qry.l_suffix;
      END IF;
      -- Get list of input variables to bind (e.g. :var)
      FOR i IN 1..pio_qry.t_out.COUNT LOOP
         get_input_var(pio_qry.t_out(i));
      END LOOP;
      -- Display path
      debug('Q','-- path: '||pio_qry.l_path);
      -- Display resulting query
      FOR i IN 1..pio_qry.t_out.COUNT LOOP
         debug('Q',pio_qry.t_out(i));
      END LOOP;
      -- Allow query to be customized
      doc_utility_ext.customize_query(pio_qry.t_out);
      <<open_cursor>>
      -- Prepare for execution
      debug('E','opening cursor...');
      pio_qry.l_cursor := sys.dbms_sql.open_cursor;
      debug('E','parsing...');
      sys.dbms_sql.parse(pio_qry.l_cursor,pio_qry.t_out,pio_qry.t_out.FIRST,pio_qry.t_out.LAST,TRUE,sys.dbms_sql.native);
      debug('E','describing columns...');
      sys.dbms_sql.describe_columns2(pio_qry.l_cursor,l_count,pio_qry.t_desc);
      debug('E','defining columns...');
      define_columns(pio_qry.l_cursor);
      -- Determine name of output variables to stored in the cache
      assert(pio_qry.t_col.COUNT=pio_qry.t_desc.COUNT,'Number of columns mismatch! '||pio_qry.t_col.COUNT||' vs '||pio_qry.t_desc.COUNT);
      -- Add query to cache
      IF l_idx IS NULL THEN
         doc_utility_var.gt_qry_idx(doc_utility_var.gt_qry_idx.COUNT+1) := pio_qry;
      END IF;
      <<end_proc>>
      debug('E','<- parse('||pio_qry.qry_name||')');
   END;
   ---
   -- Bind query variables
   ---
   PROCEDURE bind_variables (
      pio_qry IN OUT doc_utility_var.gr_qry_type
   )
   IS
   BEGIN
      debug('E','-> bind_variables('||pio_qry.qry_name||')');
      -- Bind input variables (with values coming from the cache)
      FOR i IN 1..pio_qry.t_var.COUNT LOOP
         assert(gt_var_ass.EXISTS(LOWER(pio_qry.t_var(i))),'Bind variable :'||LOWER(pio_qry.t_var(i))||' not found in cache!');
         sys.dbms_sql.bind_variable(pio_qry.l_cursor, ':'||SUBSTR(REPLACE(pio_qry.t_var(i),'.','$'),1,30), gt_var_ass(LOWER(pio_qry.t_var(i))));
         debug('E','BINDING '||':'||SUBSTR(REPLACE(pio_qry.t_var(i),'.','$'),1,30)||' with '||gt_var_ass(LOWER(pio_qry.t_var(i))));
      END LOOP;
      debug('E','<- bind_variables('||pio_qry.qry_name||')');
   END;
   ---
   -- Execute a SQL statement
   ---
   PROCEDURE execute (
      pio_qry IN OUT doc_utility_var.gr_qry_type
   )
   IS
   BEGIN
      debug('E','-> execute('||pio_qry.qry_name||')');
      -- Execute query
      pio_qry.l_count := sys.dbms_sql.execute(pio_qry.l_cursor);
      pio_qry.l_tot_count := 0;
      debug('E','<- execute('||pio_qry.qry_name||')');
   END;
   ---
   -- Execute a SQL statement
   ---
   PROCEDURE fetch_rows (
      pio_qry IN OUT doc_utility_var.gr_qry_type
   )
   IS
      l_char g_big_buf_type;
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_descr VARCHAR2(1000);
      l_table_name VARCHAR2(60);
--      l_sel_name VARCHAR2(60); -- G-1030
      l_col_name VARCHAR2(60);
      l_pos INTEGER;
      l_datetime_mask VARCHAR2(40) := 'DD.MM.YYYY HH24:MI:SS';  -- Display date and time in this format
      l_timestamp_mask VARCHAR2(40) := 'DD.MM.YYYY HH24:MI:SS:FF';  -- Display timestamps in this format
   BEGIN
      debug('E','-> fetch_rows('||pio_qry.qry_name||'), '||pio_qry.l_tot_count||' fetched so far');
      -- Fetch the first row
      pio_qry.l_count := sys.dbms_sql.fetch_rows(pio_qry.l_cursor);
      IF pio_qry.l_count > 0 THEN
         pio_qry.l_tot_count := pio_qry.l_tot_count + 1;
         debug('R','********** Record #'||pio_qry.l_tot_count||' **********');
         FOR i IN 1..pio_qry.t_desc.COUNT LOOP
          --l_col_name := pio_qry.t_desc(i).col_name;
            l_col_name := pio_qry.t_col(i);
            IF pio_qry.t_desc(i).col_type = 1 /* CHAR */ THEN
               sys.dbms_sql.column_value(pio_qry.l_cursor,i,l_char);
            ELSIF pio_qry.t_desc(i).col_type = 2 /* NUMBER */ THEN
               sys.dbms_sql.column_value(pio_qry.l_cursor,i,l_number);
               l_char := TO_CHAR(l_number);
            ELSIF pio_qry.t_desc(i).col_type = 12 /* DATE */ THEN
               sys.dbms_sql.column_value(pio_qry.l_cursor,i,l_date);
               l_char := REPLACE(TO_CHAR(l_date,l_datetime_mask),' 00:00:00');
            ELSIF pio_qry.t_desc(i).col_type = 180 /* TIMESTAMP */ THEN
               sys.dbms_sql.column_value(pio_qry.l_cursor,i,l_timestamp);
               l_char := TO_CHAR(l_timestamp,l_timestamp_mask);
            ELSE
             --raise_application_error(-20000,'Unsupported data type for column: '||l_col_name);
               l_char := '<unsupported data type '||pio_qry.t_desc(i).col_type||'>';
            END IF;
            l_char := RTRIM(l_char);
            set_cache_entry(gt_var_ass,l_col_name,l_char);
            l_col_name := pio_qry.t_desc(i).col_name;
          --l_descr := CASE WHEN l_char IS NOT NULL THEN sql_utility.get_column_descr(pio_qry.l_cursor,l_table_name,l_col_name) ELSE NULL END;
            IF l_char IS NOT NULL THEN
               IF l_descr IS NOT NULL THEN
                  debug('R',l_col_name||'='||NVL(l_char,'NULL')||' ('||l_descr||')');
               ELSE
                  debug('R',l_col_name||'='||NVL(l_char,'NULL'));
               END IF;
            END IF;
         END LOOP;
      END IF;
      debug('E','<- fetch_rows('||pio_qry.qry_name||')');
   END;
   ---
   -- Close cursor
   ---
   PROCEDURE close_cursor (
      pio_qry IN OUT doc_utility_var.gr_qry_type
   )
   IS
   BEGIN
      IF sys.dbms_sql.is_open(pio_qry.l_cursor) THEN
         sys.dbms_sql.close_cursor(pio_qry.l_cursor);
      END IF;
      pio_qry.t_out.DELETE;
      pio_qry.t_sel.DELETE;
      pio_qry.t_var.DELETE;
      pio_qry.t_col.DELETE;
      pio_qry.l_cursor := NULL;
      pio_qry.t_desc.DELETE;
      pio_qry.l_count := NULL;
      pio_qry.l_tot_count := NULL;
   END;
   ---
   -- C like sprintf function
   -- Source: http://www.adp-gmbh.ch/blog/2007/04/14.php#test_case
   -- + fixed bug: leading 0 instead of trailing 0 e.g. 09999 instead of 99990!
   ---
   FUNCTION sprintf (p_format IN VARCHAR2, pt_arg_list_idx IN gt_arg_list_idx_type)
      RETURN VARCHAR2
   IS
      l_ret            g_small_buf_type;
      l_cur_pos        NUMBER          := 0;
      l_cur_format     g_small_buf_type;
      l_len_format     NUMBER          := LENGTH (p_format);
      l_left_aligned   BOOLEAN;
      l_print_sign     BOOLEAN;
      l_cur_param      NUMBER          := 0;
   BEGIN
      LOOP
         -- Iterating over each character in the format.
         -- cur_pos points to the character 'being examined'.
         l_cur_pos := l_cur_pos + 1;
         EXIT WHEN l_cur_pos > l_len_format;
         -- The iteration is over when cur_pos is past the last character.
         IF SUBSTR (p_format, l_cur_pos, 1) = '%'
         THEN
            -- A % sign is recognized.
            -- I assume the default: left aligned, sign (+) not printed
            l_left_aligned := FALSE;
            l_print_sign := FALSE;
            -- Advance cur_pos so that it points to the character
            -- right of the %
            l_cur_pos := l_cur_pos + 1;
            --
            IF SUBSTR (p_format, l_cur_pos, 1) = '%'
            THEN
               -- If % is immediately followed by another %, a literal
               -- % is wanted:
               l_ret := l_ret || '%';
               -- No need to further process the format (it is none)
               GOTO PERCENT;
            END IF;
            IF SUBSTR (p_format, l_cur_pos, 1) = '-'
            THEN
               -- Current format will be left aligned
               l_left_aligned := TRUE;
               l_cur_pos := l_cur_pos + 1;
            END IF;
            IF SUBSTR (p_format, l_cur_pos, 1) = '+'
            THEN
               -- Print plus sign explicitely (only number, %d)
               l_print_sign := TRUE;
               l_cur_pos := l_cur_pos + 1;
            END IF;
            -- Now, reading the rest until 'd' or 's' and
            -- store it in cur_format.
            l_cur_format := NULL;
            -- cur_param points to the corresponding entry
            -- in parms
            l_cur_param := l_cur_param + 1;
            LOOP
               -- Make sure, iteration doesn't loop forever
               -- (for example if incorrect format is given)
               EXIT WHEN l_cur_pos > l_len_format;
               IF SUBSTR (p_format, l_cur_pos, 1) = 'd'
               THEN
                  DECLARE
                     -- some 'local' variables, only used for %d
                     l_chars_left_dot   NUMBER;
                     l_chars_rite_dot   NUMBER;
                     l_chars_total      NUMBER;
                     l_dot_pos          NUMBER;
                     l_to_char_format   VARCHAR2 (50);
                     l_buf              VARCHAR2 (50);
                     l_num_left_dot     VARCHAR2 (1)      := '9';
                  BEGIN
                     IF l_cur_format IS NULL
                     THEN
                        -- Format is: %d (maybe %-d, or %+d which SHOULD be
                        -- handled, but isn't)
                        l_ret := l_ret || TO_CHAR (pt_arg_list_idx (l_cur_param));
                        -- current format specification finished, exit the loop
                        EXIT;
                     END IF;
                     -- does the current format contain a dot?
                     -- dot_pos will be the position of the dot
                     -- if it contains one, or will be 0 otherwise.
                     l_dot_pos := INSTR (l_cur_format, '.');
                     IF SUBSTR (l_cur_format, 1, 1) = '0'
                     THEN
                        -- Is the current format something like %0...d?
                        l_num_left_dot := '0';
                     END IF;
                     -- determine how many digits (chars) are to be printed left
                     -- and right of the dot.
                     IF l_dot_pos = 0
                     THEN
                        -- If no dot, there won't be any characters rigth of the dot
                        -- (and no dot will be printed, either)
                        l_chars_rite_dot := 0;
                        l_chars_left_dot := TO_NUMBER (l_cur_format);
                        l_chars_total := l_chars_left_dot;
                     ELSE
                        l_chars_rite_dot :=
                                    TO_NUMBER (SUBSTR (l_cur_format, l_dot_pos + 1));
                        l_chars_left_dot :=
                                 TO_NUMBER (SUBSTR (l_cur_format, 1, l_dot_pos - 1));
                        l_chars_total := l_chars_left_dot + l_chars_rite_dot + 1;
                     END IF;
                     IF pt_arg_list_idx (l_cur_param) IS NULL
                     THEN
                        --  null h
                        l_ret := l_ret || LPAD (' ', l_chars_total);
                        EXIT;
                     END IF;
                     l_to_char_format :=
--Bug: leading 0 instead of trailing 0 e.g. 09999 instead of 99990!
--                               LPAD ('9', chars_left_dot - 1, '9')
--                               || num_left_dot;
                                 l_num_left_dot
                                 || LPAD ('9', l_chars_left_dot - 1, '9');
                     IF l_dot_pos != 0
                     THEN
                        -- There will be a dot
                        l_to_char_format :=
                              l_to_char_format
                           || '.'
                           || LPAD ('9', l_chars_rite_dot, '9');
                     END IF;
                     IF l_print_sign
                     THEN
                        l_to_char_format := 'S' || l_to_char_format;
                        -- The explicit printing of the sign widens the output one character
                        l_chars_total := l_chars_total + 1;
                     END IF;
                     l_buf :=
                          TO_CHAR (TO_NUMBER (pt_arg_list_idx (l_cur_param)), l_to_char_format);
                     IF NOT l_print_sign
                           THEN
                        IF SUBSTR (l_buf, 1, 1) = '-' OR SUBSTR (l_buf, 1, 1) != ' '
                        THEN
                           -- print a bunch of ! if the number doesn't fit the length
                           l_buf := LPAD ('!', l_chars_total, '!');
                        ELSE
                           l_buf := SUBSTR (l_buf, 2);
                        END IF;
                     END IF;
                     IF l_left_aligned
                     THEN
                        l_buf := RPAD (TRIM (l_buf), l_chars_total);
                     ELSE
                        l_buf := LPAD (TRIM (l_buf), l_chars_total);
                     END IF;
                     l_ret := l_ret || l_buf;
                     EXIT;
                  END;
               ELSIF SUBSTR (p_format, l_cur_pos, 1) = 's'
               THEN
                  IF l_cur_format IS NULL
                  THEN
                     l_ret := l_ret || pt_arg_list_idx (l_cur_param);
                     EXIT;
                  END IF;
                  IF l_left_aligned
                  THEN
                     l_ret :=
                           l_ret
                        || RPAD (NVL (pt_arg_list_idx (l_cur_param), ' ')
                               , TO_NUMBER (l_cur_format)
                                );
                  ELSE
                     l_ret :=
                           l_ret
                        || LPAD (NVL (pt_arg_list_idx (l_cur_param), ' ')
                               , TO_NUMBER (l_cur_format)
                                );
                  END IF;
                  EXIT;
               END IF;
               l_cur_format := l_cur_format || SUBSTR (p_format, l_cur_pos, 1);
               l_cur_pos := l_cur_pos + 1;
            END LOOP;
         ELSE
            l_ret := l_ret || SUBSTR (p_format, l_cur_pos, 1);
         END IF;
         <<percent>>
         NULL;
      END LOOP;
      RETURN l_ret;
   END sprintf;
   ---
   -- Format a string
   ---
   FUNCTION format_string (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      t_args gt_arg_list_idx_type;
   BEGIN
      t_args(1) := p_string;
      RETURN sprintf(p_format,t_args);
   END;
   ---
   -- Set preferred path
   ---
   PROCEDURE set_preferred_path (
      p_path IN VARCHAR2
    , p_distance IN BINARY_DOUBLE := 1 -- NULL to reset it to its default value
   )
   IS
      r_qry doc_utility_var.gr_qry_type;
   BEGIN
      r_qry.qry_name := 'path';
      r_qry.l_from := p_path;
      parse(pio_qry=>r_qry,p_distance=>NVL(p_distance,gk_distance));
   END;
   ---
   -- Reset all preferred paths
   ---
   PROCEDURE reset_preferred_paths
   IS
   BEGIN
      reset_all_edge_distances;
   END;
   ---
   -- Merge template with data
   ---
   FUNCTION text_merge_ (
      pio_in IN OUT sys.dbms_sql.varchar2a
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      l_line g_small_buf_type;
      l_idx INTEGER;
      l_found BOOLEAN;
      k_from CONSTANT VARCHAR2(5) := '#from';
      k_where CONSTANT VARCHAR2(6) := '#where';
      k_select CONSTANT VARCHAR2(7) := '#select';
      k_order_by CONSTANT VARCHAR2(9) := '#order_by';
      k_prefix CONSTANT VARCHAR2(7) := '#prefix';
      k_suffix CONSTANT VARCHAR2(7) := '#suffix';
      k_foreach CONSTANT VARCHAR2(8) := '#foreach';
      k_next CONSTANT VARCHAR2(5) := '#next';
      l_name g_long_name_type;
      l_pass INTEGER;
      t_sym gt_str_ass_type;
      t_qry doc_utility_var.gt_qry_cache_ass_type;
      pio_out sys.dbms_sql.varchar2a;
      -- Process text line (substitute variables)
      PROCEDURE process_txt_line (
         p_line IN VARCHAR2
       , p_qry_name IN VARCHAR2
       , p_skip IN BOOLEAN
      )
      IS
         l_line g_small_buf_type := p_line;
         l_beg INTEGER;
         l_mid INTEGER;
         l_end INTEGER;
         l_var g_long_name_type;
         l_msk g_long_name_type;
         l_val g_small_buf_type;
         r_qry doc_utility_var.gr_qry_type;
         l_skip BOOLEAN := NVL(p_skip,FALSE);
      BEGIN
         IF l_skip THEN
            RETURN;
         END IF;
         IF p_qry_name IS NOT NULL THEN
            r_qry := t_qry(p_qry_name);
         END IF;
         WHILE TRUE LOOP
            -- Extract any variable e.g. {name:format}
            l_beg := NVL(INSTR(l_line,'{'),0);
            l_end := NVL(INSTR(l_line,'}'),0);
            assert(NOT (l_beg > 0 AND l_end <=0),'{ without }');
            assert(NOT (l_end > 0 AND l_beg <=0),'} without {');
            assert(l_beg <= l_end,'} without {');
            EXIT WHEN l_beg <= 0;
            l_var := LOWER(REPLACE(SUBSTR(l_line,l_beg+1,l_end-l_beg-1),'"',''''));
            -- Extract optional format
            l_msk := NULL;
            l_mid := NVL(INSTR(l_var,';'),0);
            IF l_mid > 0 THEN
               l_msk := SUBSTR(l_var,l_mid+1);
               l_var := SUBSTR(l_var,1,l_mid-1);
            END IF;
            IF l_pass = 1 THEN
               -- If symbol not already encountered
               IF NOT t_sym.EXISTS(l_var) THEN
                  -- Add it to the select list
                  IF p_qry_name IS NOT NULL THEN
                     r_qry.l_select := r_qry.l_select||CASE WHEN r_qry.l_select IS NULL THEN NULL ELSE ',' END||l_var;
                  END IF;
                  -- Declare it as already seen
                  t_sym(l_var) := l_var;
               END IF;
               l_val := NULL;
            ELSE
               assert(gt_var_ass.EXISTS(l_var),'Variable {'||l_var||'} not found! beg='||l_beg||',end='||l_end);
               l_val := gt_var_ass(l_var);
               IF l_msk IS NOT NULL THEN
                  l_val := format_string(l_val,l_msk);
               END IF;
            END IF;
            l_line := SUBSTR(l_line,1,l_beg-1)
                   || l_val
                   || SUBSTR(l_line,l_end+1);
         END LOOP;
         IF l_pass = 2 THEN
            pio_out(pio_out.COUNT+1) := l_line;
         END IF;
         -- save modified query
         IF p_qry_name IS NOT NULL THEN
            t_qry(r_qry.qry_name) := r_qry;
         END IF;
      END;
      -- Process all lines with indices in given range
      FUNCTION process_all_lines (
         p_beg IN INTEGER
       , p_end IN INTEGER
       , p_sep IN VARCHAR2
       , p_qry_name IN VARCHAR2
       , p_skip IN BOOLEAN := NULL
      )
      RETURN INTEGER
      IS
         l_line g_big_buf_type;
         l_beg_token VARCHAR2(20);
         l_end_token VARCHAR2(20);
         l_qry_name g_short_name_type;
         l_src_table_name g_short_name_type;
         l_src_table_alias g_short_name_type;
         l_src_query_alias g_short_name_type;
--         l_ignore_txt_lines VARCHAR2(1); -- G-1030
         l_found BOOLEAN;
         l_i INTEGER;
--         l_j INTEGER; -- G-1030
         l_idx_sav INTEGER;
         r_qry doc_utility_var.gr_qry_type;
         l_skip BOOLEAN := NVL(p_skip,FALSE);
      BEGIN
         l_i := p_beg;
         WHILE l_i <= p_end LOOP
            assert(l_i<1000,'infinite loop detected');
            l_line := pio_in(l_i);
            WHILE ends_with(l_line,'\') AND l_i <= p_end LOOP
               l_i := l_i + 1;
               l_line := SUBSTR(l_line,1,LENGTH(l_line)-1)||pio_in(l_i);
            END LOOP;
            EXIT WHEN starts_with(l_line,p_sep);
            IF starts_with(l_line,'#') THEN
               l_end_token := NULL;
               IF starts_with(l_line,k_from) THEN
                  consume_keyword(l_line,k_from);
                  consume_leading_spaces(l_line);
                  r_qry := NULL;
                  r_qry.l_from := l_line;
                  l_qry_name := UPPER(consume_word(l_line));
                  consume_leading_spaces(l_line);
                  IF gt_tab_ass.EXISTS(l_qry_name) THEN
                     -- Table name given
                     l_src_table_name := l_qry_name;
                     IF is_letter(SUBSTR(l_line,1,1)) THEN
                        -- Query alias given, take it!
                        l_src_query_alias := LOWER(consume_word(l_line));
                        consume_leading_spaces(l_line);
                        l_src_table_alias := extract_table_alias(l_src_query_alias);
                     ELSE
                        -- No query alias found, generate one!
                        l_src_table_alias := gt_tab_ass(l_src_table_name).table_alias;
                        l_src_query_alias := generate_query_alias(l_src_table_name);
                     END IF;
                  ELSE
                     l_src_query_alias := LOWER(l_qry_name);
                     l_src_table_alias := extract_table_alias(l_src_query_alias);
                     assert(gt_tal_ass.EXISTS(l_src_table_alias),'Table alias "'||l_src_table_alias||'" does not exist!');
                     l_src_table_name := gt_tal_ass(l_src_table_alias);
                  END IF;
                  IF l_pass = 1 THEN
                     gt_qal_ass(l_src_query_alias) := l_src_table_alias;
                  END IF;
                  r_qry.qry_name := l_src_query_alias;
                  assert(r_qry.qry_name IS NOT NULL,'empty query name');
                  IF l_pass = 1 THEN
                     assert(NOT t_qry.EXISTS(l_qry_name),'duplicate query '||l_qry_name);
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
                --i := process_qry_lines(i+1,p_end,l_qry_name);
               ELSIF starts_with(l_line,k_where) THEN
                  assert(r_qry.l_where IS NULL,k_where||' found twice');
                  IF l_pass = 1 THEN
                     r_qry.l_where := TRIM(SUBSTR(l_line,LENGTH(k_where)+1));
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
               ELSIF starts_with(l_line,k_select) THEN
                  assert(r_qry.qry_name IS NOT NULL,k_where||' needed before '||k_select);
                  assert(r_qry.l_select IS NULL,k_select||' found twice');
                  IF l_pass = 1 THEN
                     r_qry.l_select := r_qry.l_select||CASE WHEN r_qry.l_select IS NULL THEN NULL ELSE ',' END||TRIM(SUBSTR(l_line,LENGTH(k_select)+1));
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
               ELSIF starts_with(l_line,k_order_by) THEN
                  assert(r_qry.qry_name IS NOT NULL,k_where||' needed before '||k_order_by);
                  assert(r_qry.l_order_by IS NULL,k_order_by||' found twice');
                  IF l_pass = 1 THEN
                     r_qry.l_order_by := TRIM(SUBSTR(l_line,LENGTH(k_order_by)+1));
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
               ELSIF starts_with(l_line,k_prefix) THEN
                  assert(r_qry.qry_name IS NOT NULL,k_where||' needed before '||k_prefix);
                  assert(r_qry.l_prefix IS NULL,k_prefix||' found twice');
                  IF l_pass = 1 THEN
                     r_qry.l_prefix := TRIM(SUBSTR(l_line,LENGTH(k_prefix)+1));
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
               ELSIF starts_with(l_line,k_suffix) THEN
                  assert(r_qry.qry_name IS NOT NULL,k_where||' needed before '||k_suffix);
                  assert(r_qry.l_suffix IS NULL,k_suffix||' found twice');
                  IF l_pass = 1 THEN
                     r_qry.l_suffix := TRIM(SUBSTR(l_line,LENGTH(k_suffix)+1));
                     t_qry(r_qry.qry_name) := r_qry;
                  END IF;
               ELSIF starts_with(l_line,k_foreach) THEN
                  l_beg_token := k_foreach;
                  l_end_token := k_next;
                  consume_keyword(l_line,k_foreach);
                  consume_leading_spaces(l_line);
                  l_qry_name := consume_word(l_line);
                  assert(t_qry.EXISTS(l_qry_name),'query "'||l_qry_name||'" not found');
                  IF l_pass = 1 THEN
                     t_qry(l_qry_name).l_foreach_count := NVL(t_qry(l_qry_name).l_foreach_count,0) + 1;
                  ELSE
                     IF NOT l_skip THEN
                        IF t_qry(l_qry_name).l_cursor IS NULL THEN
                           parse(t_qry(l_qry_name));
                        END IF;
                        bind_variables(t_qry(l_qry_name));
                        execute(t_qry(l_qry_name));
                     END IF;
                  END IF;
                  l_idx_sav := l_i + 1;
                  WHILE TRUE LOOP
                     -- Warning: Must process all lines at least one to find #next
                     IF l_pass = 2 THEN
                        IF NOT l_skip THEN
                           fetch_rows(t_qry(l_qry_name));
                           l_skip := t_qry(l_qry_name).l_count = 0;
                           EXIT WHEN t_qry(l_qry_name).l_tot_count>0 AND t_qry(l_qry_name).l_count=0;
                        END IF;
                     END IF;
                     l_i := process_all_lines(l_idx_sav,p_end,l_end_token,l_qry_name,l_skip);
                     l_line := pio_in(l_i);
                     l_found := l_i<= p_end AND starts_with(l_line,l_end_token);
                     assert(l_found,l_beg_token||' without '||l_end_token);
                     consume_keyword(l_line,l_end_token);
                     consume_leading_spaces(l_line);
                     l_name := consume_word(l_line);
                     assert(l_name IS NULL OR l_name=l_qry_name,l_end_token||' '||l_name||' doesn''t match '||l_beg_token||' '||l_qry_name);
                     EXIT WHEN l_pass = 1;
                     EXIT WHEN l_pass = 2 AND l_skip;
                  END LOOP;
               END IF;
            ELSE
               IF l_pass = 1 OR p_qry_name IS NULL OR t_qry(p_qry_name).l_tot_count > 0 THEN
                  process_txt_line(l_line,p_qry_name,p_skip);
               END IF;
            END IF;
            l_i := l_i + 1;
         END LOOP;
         RETURN l_i;
      END;
      PROCEDURE finally IS
      BEGIN
         IF t_qry.COUNT > 0 THEN
            l_name := t_qry.FIRST;
            WHILE l_name IS NOT NULL LOOP
               close_cursor(t_qry(l_name));
            l_name := t_qry.NEXT(l_name);
            END LOOP;
         END IF;
      END;
   BEGIN
      t_qry.DELETE;
      gt_qal_ass.DELETE;
      l_pass := 1;
      WHILE l_pass <= 2 LOOP
         l_idx := process_all_lines(1,pio_in.COUNT,NULL,NULL);
         -- Add any missing #foreach ... #next block to force parsing and execution
         l_name := t_qry.FIRST;
         WHILE l_name IS NOT NULL LOOP
            IF NVL(t_qry(l_name).l_foreach_count,0) = 0 THEN
               l_idx := pio_in.COUNT;
               pio_in(pio_in.COUNT+1) := '#foreach ' || t_qry(l_name).qry_name;
               pio_in(pio_in.COUNT+1) := '#next ' || t_qry(l_name).qry_name;
               l_idx := process_all_lines(l_idx+1,pio_in.COUNT,NULL,NULL);
            END IF;
            close_cursor(t_qry(l_name));
         l_name := t_qry.NEXT(l_name);
         END LOOP;
         l_pass := l_pass + 1;
      END LOOP;
      finally;
      RETURN pio_out;
--   EXCEPTION
--      WHEN OTHERS THEN
--         finally;
--         log_utility.log_message('E',SQLERRM);
--         log_utility.log_message('E',sys.dbms_utility.format_error_backtrace);
--         RAISE;
   END;
   ---
   -- Merge template with data
   ---
   FUNCTION text_merge (
      pio_in IN sys.dbms_sql.varchar2a
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      l_line g_big_buf_type;
--      l_html_flag BOOLEAN; -- G-1030
      t_in sys.dbms_sql.varchar2a;
      l_i INTEGER;
      l_pos INTEGER;
      l_in_comment BOOLEAN := FALSE;
   BEGIN
      IF pio_in.COUNT > 0 AND (starts_with(pio_in(pio_in.FIRST),'<!DOCTYPE html') OR starts_with(pio_in(pio_in.FIRST),'<HTML',TRUE)) THEN
         l_i := pio_in.FIRST;
         WHILE l_i IS NOT NULL LOOP
            l_line := pio_in(l_i);
            consume_leading_spaces(l_line);
            IF NOT l_in_comment AND starts_with(l_line,'<!--#') THEN
               consume_keyword(l_line,'<!--');
               l_in_comment := TRUE;
            END IF;
            IF l_in_comment THEN
               consume_trailing_spaces(l_line);
               IF ends_with(l_line,'-->') THEN
                  l_line := SUBSTR(l_line,1,LENGTH(l_line)-LENGTH('-->'));
                  l_in_comment := FALSE;
               END IF;
            END IF;
            t_in(t_in.COUNT+1) := l_line;
            l_i := pio_in.NEXT(l_i);
         END LOOP;
      ELSE
         t_in := pio_in;
      END IF;
      RETURN text_merge_(t_in);
   END;
   ---
   -- Merge template with data
   ---
   PROCEDURE text_merge (
      p_in IN sys.dbms_sql.varchar2a
   )
   IS
      t_out sys.dbms_sql.varchar2a;
   BEGIN
      t_out := text_merge(p_in);
      FOR i IN 1..t_out.COUNT LOOP
         log_utility.log_message('T',t_out(i));
      END LOOP;
   END;
   ---
   -- Merge template with data
   ---
   FUNCTION text_merge_pipelined (
      p_str IN VARCHAR2
   )
   RETURN sys.ODCIVarchar2List PIPELINED
   IS
      pio_in sys.dbms_sql.varchar2a;
      pio_out sys.dbms_sql.varchar2a;
      l_str g_big_buf_type := REPLACE(p_str,'\n',CHR(10));
      l_idx INTEGER;
      l_last INTEGER := 0;
   BEGIN
      -- Search for first LF
      l_idx := INSTR(l_str,CHR(10));
      WHILE l_idx > 0 LOOP
         pio_in(pio_in.COUNT+1) := SUBSTR(l_str,l_last+1,l_idx-l_last-1);
         l_last := l_idx;
         l_idx := INSTR(l_str,CHR(10),l_idx+1);
      END LOOP;
      pio_in(pio_in.COUNT+1) := SUBSTR(l_str,l_last+1);
      pio_out := text_merge(pio_in);
      FOR i IN 1..pio_out.COUNT LOOP
         PIPE ROW(pio_out(i));
      END LOOP;
      RETURN;
   END;
   ---
   -- Merge docx (generate a blob document based on a blob template)
   ---
   FUNCTION docx_merge (
      p_body IN BLOB
    , p_hdfo IN BLOB := NULL
   )
   RETURN BLOB
   IS
      TYPE r_bookmark_type IS RECORD (
         id      INTEGER
       , name    g_long_name_type
       , begpos  INTEGER
       , endpos  INTEGER
       , begpath VARCHAR2(400)
       , endpath VARCHAR2(400)
       , beglvl  INTEGER
       , endlvl  INTEGER
      );
      TYPE t_bookmark_idx_type IS TABLE OF r_bookmark_type INDEX BY BINARY_INTEGER;
      t_bm t_bookmark_idx_type;
      t_bm2 t_bookmark_idx_type;
      TYPE t_property_idx_type IS TABLE OF g_small_buf_type INDEX BY g_long_name_type;
      t_prop t_property_idx_type;
      t_body_doc zip_utility_krn.file_list;
      t_hdfo_doc zip_utility_krn.file_list;
      l_blob BLOB;
      l_clob CLOB;
--      l_clob2 CLOB; -- G-1030
      l_parser       xdb.dbms_xmlparser.parser;
      l_doc          xdb.dbms_xmldom.domdocument;
      l_list         xdb.dbms_xmldom.domnodelist;
      l_node         xdb.dbms_xmldom.domnode;
--      l_child        xdb.dbms_xmldom.domnode; -- G-1030
--      l_parent       xdb.dbms_xmldom.domnode; -- G-1030
--      l_dummy        xdb.dbms_xmldom.domnode; -- G-1030
      l_elem         xdb.dbms_xmldom.domelement;
--      l_child_value  g_small_buf_type; -- G-1030
      l_src_offset   INTEGER := 1;
      l_tgt_offset   INTEGER := 1;
      l_lng_context  INTEGER := sys.dbms_lob.default_lang_ctx;
      l_warning      INTEGER;
--      l_child_name   g_short_name_type; -- G-1030
      l_node_name    g_short_name_type;
--      l_child_type   g_short_name_type; -- G-1030
      l_node_type    g_short_name_type;
      l_cnt          INTEGER;
      l_result       BLOB;
      l_hdfo_cnt     INTEGER := 0;
      -- TBD: check if the following variables are used!
      l_line g_small_buf_type;
      l_idx INTEGER;
      l_found BOOLEAN;
      l_name g_long_name_type;
      l_pass INTEGER;
      t_sym gt_str_ass_type;
      t_qry doc_utility_var.gt_qry_cache_ass_type;
      -- Convert CLOB to BLOB
      FUNCTION clob_to_blob(p_clob IN CLOB)
      RETURN BLOB
      IS
         v_blob BLOB;
         v_offset NUMBER DEFAULT 1;
         v_amount NUMBER DEFAULT 4096;
         v_offsetwrite NUMBER DEFAULT 1;
         v_amountwrite NUMBER;
         v_buffer VARCHAR2(4096 CHAR);
      BEGIN
         sys.dbms_lob.createtemporary(v_blob, TRUE);
         <<copy_lob>>
         BEGIN
            LOOP
               sys.dbms_lob.read(p_clob, v_amount, v_offset, v_buffer);
               v_amountwrite := sys.utl_raw.length(sys.utl_raw.cast_to_raw(v_buffer));
               sys.dbms_lob.write(v_blob, v_amountwrite, v_offsetwrite, sys.utl_raw.cast_to_raw(v_buffer));
               v_offsetwrite := v_offsetwrite + v_amountwrite;
               v_offset := v_offset + v_amount;
               v_amount := 4096;
            END LOOP;
         EXCEPTION
            WHEN no_data_found THEN
               NULL;
         END copy_lob;
         RETURN v_blob;
      END clob_to_blob;
      -- Process node and descendants
      PROCEDURE process_node (
         p_node xdb.dbms_xmldom.domnode
       , p_path VARCHAR2 := NULL
      )
      IS
         l_list xdb.dbms_xmldom.domnodelist;
         l_node xdb.dbms_xmldom.domnode := p_node;
         l_tmp_node xdb.dbms_xmldom.domnode;
         l_elem xdb.dbms_xmldom.domelement;
         l_cnt INTEGER;
         l_node_name g_short_name_type;
         l_node_type g_short_name_type;
         l_node_value g_small_buf_type;
         r_bm r_bookmark_type;
         l_i INTEGER;
--         l_j INTEGER; -- G-1030
         l_idx INTEGER;
         l_found BOOLEAN;
         TYPE t_node_idx_type IS TABLE OF xdb.dbms_xmldom.domnode INDEX BY BINARY_INTEGER;
         t_node t_node_idx_type;
         l_path g_small_buf_type := p_path;
         -- Extract last position from path
         -- e.g. /0/0/1/3 return /0/0/1 and 3
         FUNCTION get_pos_from_path (
            pio_path IN OUT VARCHAR2
          , pio_pos IN OUT INTEGER
         )
         RETURN BOOLEAN
         IS
            l_idx INTEGER;
         BEGIN
            l_idx := NVL(INSTR(pio_path,'/',-1),0);
            IF l_idx <= 0 THEN
               RETURN FALSE;
            END IF;
            pio_pos := TO_NUMBER(SUBSTR(pio_path,l_idx+1));
            pio_path := SUBSTR(pio_path,1,l_idx-1);
            RETURN TRUE;
         END;
         -- Get level
         FUNCTION get_level_from_path (
            p_path IN VARCHAR2
         )
         RETURN INTEGER
         IS
            l_lvl INTEGER := 0;
         BEGIN
            FOR i IN 1..LENGTH(p_path) LOOP
               IF SUBSTR(p_path,i,1) = '/' THEN
                  l_lvl := l_lvl + 1;
               END IF;
            END LOOP;
            RETURN l_lvl;
         END;
      BEGIN
         l_node_name := xdb.dbms_xmldom.getnodename(l_node);
         l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
         IF l_node_type = xdb.dbms_xmldom.text_node THEN
            l_node_value := xdb.dbms_xmldom.getnodevalue(l_node);
--            sys.dbms_output.put_line(l_node_name||' '||l_node_type||' '||l_node_value);
            IF SUBSTR(l_node_value,1,1) = '«' AND SUBSTR(l_node_value,-1,1) = '»' AND t_bm2.COUNT>0 THEN
--               sys.dbms_output.put_line('keyword found '||l_node_value);
               DECLARE
                  l_mid INTEGER;
                  l_var g_small_buf_type;
                  l_msk g_long_name_type;
                  l_val g_small_buf_type;
                  r_qry doc_utility_var.gr_qry_type;
               BEGIN
                  -- Extract variable e.g. {name:format}
                  l_var := LOWER(REPLACE(SUBSTR(l_node_value,2,LENGTH(l_node_value)-2),'"',''''));
                  -- Extract optional format
                  l_msk := NULL;
                  l_mid := NVL(INSTR(l_var,';'),0);
                  IF l_mid > 0 THEN
                     l_msk := SUBSTR(l_var,l_mid+1);
                     l_var := SUBSTR(l_var,1,l_mid-1);
                  END IF;
                  IF l_pass = 1 THEN
                     -- If symbol not already encountered
                     IF NOT t_sym.EXISTS(l_var) THEN
                        -- Get bookmark and query
                        assert(t_bm2.COUNT>0,'Variable «:1» pas dans un bookmark','Variable  «:1» not inside a bookmark','',l_var);
                        r_bm := t_bm2(t_bm2.LAST);
                        r_qry := t_qry(r_bm.name);
                        -- Add it to the select list
                        r_qry.l_select := r_qry.l_select||CASE WHEN r_qry.l_select IS NULL THEN NULL ELSE ',' END||l_var;
                        -- Save modified query
                        t_qry(r_bm.name) := r_qry;
                        -- Declare it as already seen
                        t_sym(l_var) := l_var;
                     END IF;
                     l_val := NULL;
                  ELSE
                     assert(gt_var_ass.EXISTS(l_var),'Variable «:1» non trouvée!','Variable «:1» not found!','',l_var);
                     l_val := gt_var_ass(l_var);
                     IF l_msk IS NOT NULL THEN
                        l_val := format_string(l_val,l_msk);
                     END IF;
                     -- Replace keyword with its value
                     xdb.dbms_xmldom.setnodevalue(l_node, l_val);
                  END IF;
               END;
            END IF;
         ELSE
--            sys.dbms_output.put_line(l_node_name||' '||l_node_type);
            NULL;
         END IF;
         l_list := xdb.dbms_xmldom.getchildnodes(l_node);
         l_cnt := xdb.dbms_xmldom.getlength(l_list);
         IF l_pass = 1 THEN
            FOR i IN 0..l_cnt-1 LOOP
               l_node := xdb.dbms_xmldom.item(l_list, i);
               l_node_name := xdb.dbms_xmldom.getnodename(l_node);
               l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
--sys.dbms_output.put_line(p_path||'/'||l_node_name||'('||l_node_type||')');
               IF l_node_type = xdb.dbms_xmldom.element_node and l_node_name = 'w:bookmarkStart' THEN
                  -- Create bookmark
                  l_elem := xdb.dbms_xmldom.makeelement(l_node);
                  r_bm := NULL;
                  r_bm.id := xdb.dbms_xmldom.getattribute(l_elem,'id');
                  r_bm.name := LOWER(xdb.dbms_xmldom.getattribute(l_elem,'name'));
                  r_bm.begpath := p_path;
                  r_bm.begpos := i;
                  sys.dbms_output.put_line('w:bookmarkStart id='||r_bm.id||', name='||r_bm.name||', path='||r_bm.begpath||', pos='||r_bm.begpos);
                  -- Consider only bookmarks linked to a query
                  IF t_qry.EXISTS(r_bm.name) THEN
                     t_bm(r_bm.id) := r_bm;
                     t_bm2(t_bm2.COUNT+1) := r_bm;
                  END IF;
               ELSIF l_node_type = xdb.dbms_xmldom.element_node and l_node_name = 'w:bookmarkEnd' THEN
                  -- Update bookmark
                  l_elem := xdb.dbms_xmldom.makeelement(l_node);
                  r_bm := NULL;
                  r_bm.id := xdb.dbms_xmldom.getattribute(l_elem,'id');
                  IF t_bm.EXISTS(r_bm.id) THEN
                     r_bm := t_bm(r_bm.id);
                     r_bm.endpath := p_path;
                     r_bm.endpos := i;
                     -- Find parent node common to begin and end tags
                     WHILE NVL(r_bm.begpath,'~') != NVL(r_bm.endpath,'~') LOOP
                        r_bm.beglvl := get_level_from_path(r_bm.begpath);
                        r_bm.endlvl := get_level_from_path(r_bm.endpath);
                        IF r_bm.beglvl >= r_bm.endlvl THEN
                           EXIT WHEN NOT get_pos_from_path(r_bm.begpath,r_bm.begpos);
                           r_bm.begpos := r_bm.begpos - 1;
                        END IF;
                        IF r_bm.endlvl >= r_bm.beglvl THEN
                           EXIT WHEN NOT get_pos_from_path(r_bm.endpath,r_bm.endpos);
                           r_bm.endpos := r_bm.endpos + 1;
                        END IF;
                     END LOOP;
                     assert(NVL(r_bm.begpath,'~')=NVL(r_bm.endpath,'~'),'Impossible de trouver un noeud commun pour le signet :1 !','Cannot find common parent node for bookmark :1!',NULL,r_bm.name);
                     t_bm(r_bm.id) := r_bm;
                     sys.dbms_output.put_line('w:bookmarkEnd id='||r_bm.id||', name='||r_bm.name||', path='||r_bm.endpath||', from='||r_bm.begpos||', to='||r_bm.endpos);
                  ELSE
                     sys.dbms_output.put_line('w:bookmarkEnd id='||r_bm.id||', name=?'||', path='||p_path||', pos='||i);
                  END IF;
               END IF;
               process_node(l_node,l_path||'/'||i);
            END LOOP;
         ELSE
            r_bm := NULL;
            -- Search for bookmarks at this level
            r_bm := NULL;
            l_idx := t_bm.FIRST;
            WHILE l_idx IS NOT NULL LOOP
               r_bm := t_bm(l_idx);
               EXIT WHEN r_bm.begpath = p_path;
               r_bm := NULL;
               l_idx := t_bm.NEXT(l_idx);
            END LOOP;
            -- Bookmark found?
            IF r_bm.id IS NULL THEN
--sys.dbms_output.put_line('no bm for '||p_path);
               FOR i IN 0..l_cnt-1 LOOP
                  l_node := xdb.dbms_xmldom.item(l_list, i);
                  process_node(l_node,l_path||'/'||i);
               END LOOP;
            ELSE
--sys.dbms_output.put_line('bm '||r_bm.name||' for '||p_path||' from '||r_bm.begpos||' to '||r_bm.endpos);
               -- Process nodes before bookmark
               IF r_bm.begpos-1 >= 0 THEN
                  FOR i IN 0..r_bm.begpos-1 LOOP
                     l_node := xdb.dbms_xmldom.item(l_list, i);
                     process_node(l_node,l_path||'/'||i);
                  END LOOP;
               END IF;
               -- Process bookmark region
               IF r_bm.begpos+1<=r_bm.endpos-1 THEN
                  -- Push bookmark on the stack
                  t_bm2(t_bm2.COUNT+1) := r_bm;
                  -- Put bookmark region aside
                  t_node.DELETE;
                  FOR i IN r_bm.begpos+1..r_bm.endpos-1 LOOP
                     -- Clone node tree
                     l_node := xdb.dbms_xmldom.item(l_list, i);
                     t_node(t_node.COUNT+1) := xdb.dbms_xmldom.clonenode(l_node,TRUE);
                     -- Remove template node
                     l_node := xdb.dbms_xmldom.removechild(p_node,l_node);
                  END LOOP;
--sys.dbms_output.put_line(t_node.COUNT||' NODES HAVE BEEN CLONED');
                  -- Prepare query for execution
                  assert(t_qry.EXISTS(r_bm.name),'query "'||r_bm.name||'" not found');
                  IF t_qry(r_bm.name).l_cursor IS NULL THEN
                     parse(t_qry(r_bm.name));
                  END IF;
                  bind_variables(t_qry(r_bm.name));
                  execute(t_qry(r_bm.name));
                  -- For each record
                  WHILE TRUE LOOP
                     fetch_rows(t_qry(r_bm.name));
                     EXIT WHEN t_qry(r_bm.name).l_count = 0;
                     -- For each node within the bookmark region
                     FOR i IN 1..t_node.COUNT LOOP
                        -- Clone node tree from template
                        l_tmp_node := xdb.dbms_xmldom.clonenode(t_node(i),TRUE);
                        -- Determine insert position
                        IF r_bm.endpos < l_cnt THEN
                           -- Insert just before end tag
                           l_node := xdb.dbms_xmldom.item(l_list, r_bm.endpos);
                        ELSE
                           -- insert in last position
                           l_node := NULL;
                        END IF;
                        -- Insert it in the final document
                        l_node := xdb.dbms_xmldom.insertbefore(p_node,l_tmp_node,l_node);
                        -- Process it i.e. replace keywords
                        process_node(l_node,l_path||'/'||TO_NUMBER(r_bm.begpos+i));
                     END LOOP;
                  END LOOP;
                  -- Pop bookmark from the stack
                  t_bm2.DELETE(t_bm2.LAST);
               END IF;
               -- Process nodes after bookmark
               IF r_bm.endpos+1<=l_cnt-1 THEN
                  FOR i IN r_bm.endpos+1..l_cnt-1 LOOP
                     l_node := xdb.dbms_xmldom.item(l_list, i);
                     process_node(l_node,l_path||'/'||i);
                  END LOOP;
               END IF;
            END IF;
         END IF;
      END;
      -- show node and descendants (for debugging purpose)
      PROCEDURE show_node (
         p_node xdb.dbms_xmldom.domnode
       , p_path IN VARCHAR2 := NULL
      )
      IS
         l_list xdb.dbms_xmldom.domnodelist;
         l_node xdb.dbms_xmldom.domnode := p_node;
         l_elem xdb.dbms_xmldom.domelement;
         l_tmp_node xdb.dbms_xmldom.domnode;
         l_cnt INTEGER;
         l_node_name g_short_name_type;
         l_node_type g_short_name_type;
         l_node_value g_small_buf_type;
         r_bm r_bookmark_type;
      BEGIN
         l_node_name := xdb.dbms_xmldom.getnodename(l_node);
         l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
         IF l_node_type = xdb.dbms_xmldom.text_node THEN
            l_node_value := xdb.dbms_xmldom.getnodevalue(l_node);
            sys.dbms_output.put_line(p_path||'/'||l_node_name||' '||l_node_value);
         ELSE
            sys.dbms_output.put_line(p_path||'/'||l_node_name);
         END IF;
         l_list := xdb.dbms_xmldom.getchildnodes(l_node);
         l_cnt := xdb.dbms_xmldom.getlength(l_list);
         FOR i IN 0..l_cnt-1 LOOP
            l_node := xdb.dbms_xmldom.item(l_list, i);
            show_node(l_node,p_path||'/'||l_node_name);
         END LOOP;
      END;
      -- Extract properties
      PROCEDURE extract_prop (
         p_node xdb.dbms_xmldom.domnode
       , p_path VARCHAR2 := NULL
       , p_prop_name VARCHAR2 := NULL
      )
      IS
         l_list xdb.dbms_xmldom.domnodelist;
         l_node xdb.dbms_xmldom.domnode := p_node;
         l_elem xdb.dbms_xmldom.domelement;
         l_tmp_node xdb.dbms_xmldom.domnode;
         l_cnt INTEGER;
         l_node_name g_short_name_type;
         l_node_type g_short_name_type;
         l_node_value g_small_buf_type;
         l_path VARCHAR2(400) := p_path;
         l_prop_name g_long_name_type := p_prop_name;
      BEGIN
         l_node_name := xdb.dbms_xmldom.getnodename(l_node);
         l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
         IF l_node_type = xdb.dbms_xmldom.text_node THEN
--            sys.dbms_output.put_line('path='||l_path);
            IF l_path = '/Properties/property/vt:lpwstr' AND l_prop_name IS NOT NULL THEN
               l_node_value := xdb.dbms_xmldom.getnodevalue(l_node);
--               sys.dbms_output.put_line(l_node_name||' '||l_node_type||' '||l_node_value);
               t_prop(LOWER(l_prop_name)) := l_node_value;
            END IF;
         ELSIF l_node_type = xdb.dbms_xmldom.document_node THEN
            NULL;
         ELSE
            IF l_node_type = xdb.dbms_xmldom.element_node THEN
               l_elem := xdb.dbms_xmldom.makeelement(l_node);
               IF l_node_name = 'property' THEN
                  l_prop_name := xdb.dbms_xmldom.getattribute(l_elem,'name');
               END IF;
            END IF;
--            sys.dbms_output.put_line(l_node_name||' '||l_node_type);
            l_path := l_path || '/' || l_node_name;
         END IF;
         l_list := xdb.dbms_xmldom.getchildnodes(l_node);
         l_cnt := xdb.dbms_xmldom.getlength(l_list);
         FOR i IN 0..l_cnt-1 LOOP
            l_node := xdb.dbms_xmldom.item(l_list, i);
            extract_prop(l_node,l_path,l_prop_name);
         END LOOP;
      END;
      -- Process properties
      PROCEDURE process_prop(
         pio_doc xdb.dbms_xmldom.domdocument
      )
      IS
         k_from CONSTANT VARCHAR2(4) := 'from';
         k_where CONSTANT VARCHAR2(5) := 'where';
         k_select CONSTANT VARCHAR2(6) := 'select';
         k_order_by CONSTANT VARCHAR2(8) := 'order_by';
         k_prefix CONSTANT VARCHAR2(6) := 'prefix';
         k_suffix CONSTANT VARCHAR2(6) := 'suffix';
         l_idx INTEGER;
         l_line g_small_buf_type;
         r_qry doc_utility_var.gr_qry_type;
      BEGIN
         t_qry.DELETE;
         extract_prop(xdb.dbms_xmldom.makenode(pio_doc));
         FOR l_idx IN 1..10 LOOP
            EXIT WHEN NOT t_prop.EXISTS(k_from||l_idx);
            r_qry := NULL;
            l_line := t_prop(k_from||l_idx);
            consume_leading_spaces(l_line);
            r_qry.l_from := l_line;
            r_qry.qry_name := LOWER(consume_word(l_line));
            assert(NOT t_qry.EXISTS(r_qry.qry_name),'duplicate query '||r_qry.qry_name);
            IF t_prop.EXISTS(UPPER(k_where||l_idx)) THEN
               r_qry.l_where := TRIM(t_prop(k_where||l_idx));
            END IF;
            IF t_prop.EXISTS(UPPER(k_select||l_idx)) THEN
               r_qry.l_select := TRIM(t_prop(k_select||l_idx));
            END IF;
            IF t_prop.EXISTS(UPPER(k_order_by||l_idx)) THEN
               r_qry.l_order_by := TRIM(t_prop(k_order_by||l_idx));
            END IF;
            IF t_prop.EXISTS(UPPER(k_prefix||l_idx)) THEN
               r_qry.l_prefix := TRIM(t_prop(k_prefix||l_idx));
            END IF;
            IF t_prop.EXISTS(UPPER(k_suffix||l_idx)) THEN
               r_qry.l_suffix := TRIM(t_prop(k_suffix||l_idx));
            END IF;
            sys.dbms_output.put_line('Query: '||r_qry.qry_name);
            sys.dbms_output.put_line('From: '||r_qry.l_from);
            sys.dbms_output.put_line('Where: '||r_qry.l_where);
            sys.dbms_output.put_line('Order by: '||r_qry.l_order_by);
            sys.dbms_output.put_line('Prefix: '||r_qry.l_prefix);
            sys.dbms_output.put_line('Suffix: '||r_qry.l_suffix);
            t_qry(r_qry.qry_name) := r_qry;
         END LOOP;
      END;
      -- process document
      PROCEDURE process_doc (
         pio_doc IN OUT xdb.dbms_xmldom.domdocument
      )
      IS
         PROCEDURE finally IS
         BEGIN
            IF t_qry.COUNT > 0 THEN
               l_name := t_qry.FIRST;
               WHILE l_name IS NOT NULL LOOP
                  close_cursor(t_qry(l_name));
                  l_name := t_qry.NEXT(l_name);
               END LOOP;
            END IF;
         END;
      BEGIN
         l_pass := 1;
         WHILE l_pass <= 2 LOOP
sys.dbms_output.put_line('*** PASS '||l_pass||' ***');
            process_node(xdb.dbms_xmldom.makenode(pio_doc));
            l_pass := l_pass + 1;
            t_bm2.DELETE;
         END LOOP;
         finally;
         sys.dbms_output.put_line('*** resulting document ***');
--         show_node(xdb.dbms_xmldom.makenode(l_doc));
      EXCEPTION
         WHEN OTHERS THEN
            finally;
            log_utility.log_message('E',SQLERRM);
            log_utility.log_message('E',sys.dbms_utility.format_error_backtrace);
            RAISE;
      END;
      -- Include file
      PROCEDURE include_file (
         p_blob BLOB
       , p_file_in VARCHAR2
       , p_file_out VARCHAR2
      )
      IS
         l_blob BLOB;
      BEGIN
         l_blob := zip_utility_krn.get_file(p_blob,p_file_in,nls_charset_id('UTF8'));
         zip_utility_krn.add_file(l_result,p_file_out,l_blob);
         sys.dbms_output.put_line('File '||p_file_in||' added to zip as '||p_file_out);
      END;
      -- Process rels
      PROCEDURE process_rels (
         p_blob BLOB
       , p_path VARCHAR2
       , p_node xdb.dbms_xmldom.domnode
      )
      IS
         l_list xdb.dbms_xmldom.domnodelist;
         l_node xdb.dbms_xmldom.domnode := p_node;
         l_elem xdb.dbms_xmldom.domelement;
         l_cnt INTEGER;
         l_node_name g_short_name_type;
         l_node_type g_short_name_type;
         l_node_value g_small_buf_type;
         l_target g_small_buf_type;
      BEGIN
         l_node_name := xdb.dbms_xmldom.getnodename(l_node);
         l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
         l_list := xdb.dbms_xmldom.getchildnodes(l_node);
         l_cnt := xdb.dbms_xmldom.getlength(l_list);
         FOR i IN 0..l_cnt-1 LOOP
            l_node := xdb.dbms_xmldom.item(l_list, i);
            l_node_name := xdb.dbms_xmldom.getnodename(l_node);
            l_node_type := xdb.dbms_xmldom.getnodetype(l_node);
            IF l_node_type = xdb.dbms_xmldom.element_node and l_node_name = 'Relationship' THEN
               l_elem := xdb.dbms_xmldom.makeelement(l_node);
               IF xdb.dbms_xmldom.getattribute(l_elem,'TargetMode') = 'External' THEN
                  sys.dbms_output.put_line('external relationships ignored');
               ELSE
                  l_target := xdb.dbms_xmldom.getattribute(l_elem,'Target');
                  l_hdfo_cnt := l_hdfo_cnt + 1;
                  include_file(p_blob,p_path||l_target,p_path||'hdfo'||l_hdfo_cnt||'/'||l_target);
                  xdb.dbms_xmldom.setattribute(l_elem,'Target','hdfo'||l_hdfo_cnt||'/'||l_target);
               END IF;
            END IF;
            process_rels(p_blob,p_path,l_node);
         END LOOP;
      END;
      PROCEDURE include_rels (
         p_blob BLOB
       , p_file VARCHAR2
      )
      IS
         l_blob BLOB;
         l_clob CLOB;
         l_parser       xdb.dbms_xmlparser.parser;
         l_doc          xdb.dbms_xmldom.domdocument;
         l_file VARCHAR2(1000);
      BEGIN
         l_file := SUBSTR(p_file,1,INSTR(p_file,'/',-1))||'_rels/'||SUBSTR(p_file,INSTR(p_file,'/',-1)+1)||'.rels';
         sys.dbms_output.put_line('Opening '||l_file||'...');
         l_blob := zip_utility_krn.get_file(p_blob,l_file,nls_charset_id('UTF8'));
         IF l_blob IS NULL THEN
            sys.dbms_output.put_line(l_file||': not found!');
            RETURN;
         END IF;
         sys.dbms_output.put_line(l_file||': '||sys.dbms_lob.getlength(l_blob)||' bytes');
         sys.dbms_lob.createtemporary(l_clob,true);
         l_src_offset := 1;
         l_tgt_offset := 1;
         l_lng_context := sys.dbms_lob.default_lang_ctx;
         sys.dbms_lob.converttoclob(l_clob,l_blob,sys.dbms_lob.lobmaxsize,l_tgt_offset,l_src_offset,sys.dbms_lob.default_csid,l_lng_context,l_warning);
         l_parser := xdb.dbms_xmlparser.newparser;
         xdb.dbms_xmlparser.parseclob(l_parser, l_clob);
         l_doc := xdb.dbms_xmlparser.getdocument(l_parser);
       --show_node(xdb.dbms_xmldom.makenode(l_doc));
         process_rels(p_blob,SUBSTR(p_file,1,INSTR(p_file,'/',-1)),xdb.dbms_xmldom.makenode(l_doc));
         xdb.dbms_xmldom.writetoclob(l_doc, l_clob, nls_charset_id('UTF8'));
         l_blob := clob_to_blob(l_clob);
         zip_utility_krn.add_file(l_result,l_file,l_blob);
         sys.dbms_lob.freetemporary(l_clob);
         xdb.dbms_xmlparser.freeparser(l_parser);
      END;
   BEGIN
      -- Get files contained in the docx files (~zip)
      t_body_doc := zip_utility_krn.get_file_list(p_body);
      sys.dbms_output.put_line('body template contains '||t_body_doc.COUNT||' files for '||sys.dbms_lob.getlength(p_body)||' bytes');
      IF p_hdfo IS NOT NULL THEN
         t_hdfo_doc := zip_utility_krn.get_file_list(p_hdfo);
         sys.dbms_output.put_line('header/footer template contains '||t_body_doc.COUNT||' files for '||sys.dbms_lob.getlength(p_body)||' bytes');
      END IF;
      -- Handle files
      IF t_body_doc IS NOT NULL AND t_body_doc.count() > 0
      THEN
         sys.dbms_lob.createtemporary(l_result,true);
         -- Process custom properties
         FOR i IN t_body_doc.FIRST .. t_body_doc.LAST
         LOOP
            IF t_body_doc(i) = 'docProps/custom.xml' THEN
               l_blob := zip_utility_krn.get_file(p_body,t_body_doc(i),nls_charset_id('UTF8'));
               sys.dbms_lob.createtemporary(l_clob,true);
               l_src_offset := 1;
               l_tgt_offset := 1;
               l_lng_context := sys.dbms_lob.default_lang_ctx;
               sys.dbms_lob.converttoclob(l_clob,l_blob,sys.dbms_lob.lobmaxsize,l_tgt_offset,l_src_offset,sys.dbms_lob.default_csid,l_lng_context,l_warning);
               l_parser := xdb.dbms_xmlparser.newparser;
               xdb.dbms_xmlparser.parseclob(l_parser, l_clob);
               l_doc := xdb.dbms_xmlparser.getdocument(l_parser);
               process_prop(l_doc);
               sys.dbms_lob.freetemporary(l_clob);
               xdb.dbms_xmlparser.freeparser(l_parser);
            END IF;
         END LOOP;
         -- Process document content
         FOR i IN t_body_doc.FIRST .. t_body_doc.LAST
         LOOP
            IF t_hdfo_doc IS NOT NULL AND t_hdfo_doc.count() > 0 AND (t_body_doc(i) LIKE '%header%' OR t_body_doc(i) LIKE '%footer%') THEN
               -- Ignore headers and footers from body template if header/footer template is used
               l_blob := zip_utility_krn.get_file(p_body,t_body_doc(i),nls_charset_id('UTF8'));
               sys.dbms_output.put_line('body: '||t_body_doc(i)||': '||sys.dbms_lob.getlength(l_blob)|| ' bytes ignored');
            ELSE
               -- Take all other sections from the body template
               l_blob := zip_utility_krn.get_file(p_body,t_body_doc(i),nls_charset_id('UTF8'));
               IF t_body_doc(i) = 'word/document.xml' THEN
                  -- Process the main XML
                  sys.dbms_lob.createtemporary(l_clob,true);
                  l_src_offset := 1;
                  l_tgt_offset := 1;
                  l_lng_context := sys.dbms_lob.default_lang_ctx;
                  sys.dbms_lob.converttoclob(l_clob,l_blob,sys.dbms_lob.lobmaxsize,l_tgt_offset,l_src_offset,sys.dbms_lob.default_csid,l_lng_context,l_warning);
                  l_parser := xdb.dbms_xmlparser.newparser;
                  xdb.dbms_xmlparser.parseclob(l_parser, l_clob);
                  l_doc := xdb.dbms_xmlparser.getdocument(l_parser);
                  process_doc(l_doc);
                  xdb.dbms_xmldom.writetoclob(l_doc, l_clob, nls_charset_id('UTF8'));
                  l_blob := clob_to_blob(l_clob);
                  sys.dbms_lob.freetemporary(l_clob);
                  xdb.dbms_xmlparser.freeparser(l_parser);
                  sys.dbms_output.put_line('body: '||t_body_doc(i)||': '||sys.dbms_lob.getlength(l_blob)|| ' bytes processed');
               ELSE
                  sys.dbms_output.put_line('body: '||t_body_doc(i)||': '||sys.dbms_lob.getlength(l_blob)|| ' bytes copied');
               END IF;
               zip_utility_krn.add_file(l_result,t_body_doc(i),l_blob);
            END IF;
         END LOOP;
         IF t_hdfo_doc IS NOT NULL AND t_hdfo_doc.count() > 0 THEN
            -- Process document content
            FOR i IN t_hdfo_doc.FIRST .. t_hdfo_doc.LAST LOOP
               IF t_hdfo_doc(i) LIKE 'word/header%.xml' OR t_hdfo_doc(i) LIKE 'word/footer%.xml' THEN
                  -- Ignore headers and footers for to be taken from the hdfo template
                  l_blob := zip_utility_krn.get_file(p_hdfo,t_hdfo_doc(i),nls_charset_id('UTF8'));
                 sys.dbms_output.put_line('hdfo: '||t_hdfo_doc(i)||': '||sys.dbms_lob.getlength(l_blob)|| ' bytes copied');
                  zip_utility_krn.add_file(l_result,t_hdfo_doc(i),l_blob);
                  include_rels(p_hdfo,t_hdfo_doc(i));
               END IF;
            END LOOP;
         END IF;
         zip_utility_krn.finish_zip(l_result);
      END IF;
      RETURN l_result;
   END;
   ---
   -- Clear cached queries
   ---
   PROCEDURE clear_query_cache IS
   BEGIN
      doc_utility_var.clear_query_cache;
   END;
BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format=''DD.MM.YYYY''';
   debug('C','Cache init started on '||TO_CHAR(SYSTIMESTAMP,'DD.MM.YYYY HH24:MI:SS.FF'));
   init_cache;
   debug('C','Cache init ended   on '||TO_CHAR(SYSTIMESTAMP,'DD.MM.YYYY HH24:MI:SS.FF'));
END;
/