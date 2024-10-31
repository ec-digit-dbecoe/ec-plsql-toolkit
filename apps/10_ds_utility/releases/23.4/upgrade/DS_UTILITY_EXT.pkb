CREATE OR REPLACE PACKAGE BODY ds_utility_ext AS
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
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
-- To generate the package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE ds_utility_ext', '-f');
--
   ---
   -- This package is an extension of the DS_UTILITY_KRN package
   --
   -- Revision History
   -- Ver   Who      When        What
   -- 23.4  deboiph  16/11/2023  Initial version with Grphviz and DEGPL
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_description IN VARCHAR2
   ) IS

   BEGIN
      IF NOT NVL(p_condition,FALSE) THEN
         raise_application_error(-20000,'Assertion failed: '||p_description);
      END IF;
   END;
   -- Search a character in a string and returns its position (0 if not found)
   -- Skip characters enclosed between double quotes if searched char is not "
   FUNCTION search_char (
      p_string IN VARCHAR2
    , p_chr IN VARCHAR2
   )
   RETURN PLS_INTEGER
   IS
      l_chr VARCHAR2(1 CHAR);
      l_pos PLS_INTEGER := 1;
      l_len PLS_INTEGER := LENGTH(p_string);
   BEGIN
      <<main_loop>>
      WHILE l_pos <= l_len LOOP
         l_chr := SUBSTR(p_string,l_pos,1);
         IF p_chr != '"' AND l_chr = '"' THEN
            <<string_loop>>
            LOOP
               l_pos := l_pos + 1;
               EXIT string_loop WHEN l_pos > l_len;
               l_chr := SUBSTR(p_string,l_pos,1);
               EXIT string_loop WHEN l_chr = '"';
            END LOOP;
            assert(l_pos<=l_len,'Unterminated double quoted string: '||p_string);
         ELSE
            EXIT main_loop WHEN l_chr = p_chr;
         END IF;
         l_pos := l_pos + 1;
      END LOOP;
      RETURN CASE WHEN l_pos > l_len THEN 0 ELSE l_pos END;
   END;
--#begin public
   ---
   -- Get the graph of a data set (in Graphviz's dot language)
   -- Usage: SELECT * FROM TABLE(ds_utility_krn.data_set_graph(...));
   -- Display: any online GraphViz editor (e.g., https:/ /dreampuf.github.io/GraphvizOnline)
   ---
   FUNCTION graph_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_table_name IN VARCHAR2 := NULL
    , p_full_schema IN VARCHAR2 := 'N'
    , p_aliases IN VARCHAR2 :=  'N'
    , p_legend IN VARCHAR2 := 'Y'
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      -- Cursor to get data set
      CURSOR c_set IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      r_set c_set%ROWTYPE;
      -- Cursor to loop through data set tables
      CURSOR c_tab IS
         SELECT tab.table_name tab_table_name
              , ds_tab.*, ds_set.set_type
           FROM sys.all_tables tab
           LEFT OUTER JOIN ds_tables ds_tab
             ON ds_tab.set_id = p_set_id
            AND ds_tab.table_name = tab.table_name
           LEFT OUTER JOIN ds_data_sets ds_set
             ON ds_set.set_id = p_set_id
          WHERE tab.owner = ds_utility_var.g_owner
            AND (p_table_name IS NULL OR tab.table_name LIKE p_table_name OR REGEXP_LIKE(tab.table_name,p_table_name))
            AND (NVL(p_full_schema,'N') = 'Y' OR ds_tab.table_name IS NOT NULL)
            AND INSTR(tab.table_name,'$')=0
          ORDER BY ds_tab.seq, ds_tab.tab_seq, tab.table_name
      ;
      -- Cursor to loop through data set constraints
      CURSOR c_con (
         p_table_name sys.all_constraints.table_name%TYPE
      )
      IS
         SELECT con.constraint_name con_constraint_name
              , con.table_name con_src_table_name
              , rcon.table_name con_dst_table_name
              , ds_con.*, ds_set.set_type
           FROM sys.all_constraints con
          INNER JOIN sys.all_constraints rcon
             ON rcon.owner = con.owner
            AND rcon.constraint_name = con.r_constraint_name
           LEFT OUTER JOIN ds_constraints ds_con
             ON ds_con.set_id = p_set_id
            AND ds_con.constraint_name = con.constraint_name
           LEFT OUTER JOIN ds_data_sets ds_set
             ON ds_set.set_id = p_set_id
          WHERE con.owner = ds_utility_var.g_owner
            AND con.table_name = p_table_name
            AND con.constraint_type = 'R'
            AND (NVL(p_full_schema,'N') = 'Y' OR ds_con.constraint_name IS NOT NULL)
          ORDER BY con.constraint_name, ds_con.cardinality
      ;
      l_node_att VARCHAR2(1000);
      l_edge_att VARCHAR2(1000);
      l_edge VARCHAR2(100);
      FUNCTION line (
         p_indent IN PLS_INTEGER
       , p_text IN VARCHAR2
       , p_lf IN BOOLEAN := FALSE
      )
      RETURN VARCHAR2
      IS
      BEGIN
         RETURN RPAD(' ',p_indent)||p_text||CASE WHEN p_lf THEN CHR(10) END;
      END;
   BEGIN
      assert(p_set_id IS NOT NULL, 'Data set id must be specified!');
      OPEN c_set;
      FETCH c_set INTO r_set;
      CLOSE c_set;
      assert(r_set.set_id IS NOT NULL, 'Invalid data set id!');
      PIPE ROW(line(0, 'digraph ds'||r_set.set_id||'_graph {'));
      PIPE ROW(line(3, 'node [shape=box, style="rounded, filled"]'));
      PIPE ROW(line(3, 'edge [arrowsize=1.5 label=" "]'));
      PIPE ROW(line(3, 'subgraph cluster_main {'));
      PIPE ROW(line(6, 'label=<<b>Data Set: '||r_set.set_name||' (id: '||r_set.set_id||' - type: '||r_set.set_type||')</b>>'));
      <<tab_loop>>
      FOR r_tab IN c_tab LOOP
         l_node_att := 'label="' ||r_tab.tab_table_name 
                    || CASE WHEN r_tab.extract_type IS NOT NULL THEN '\n'||NVL(r_tab.extract_count,0)
                       || CASE WHEN r_tab.set_type = 'SUB' OR r_tab.source_count != r_tab.extract_count THEN ' / '||NVL(r_tab.source_count,0) END || ' rows'
                       || CASE WHEN r_tab.seq IS NOT NULL THEN ' #' || NVL(TO_CHAR(r_tab.seq),'?') || CASE WHEN r_tab.tab_seq IS NOT NULL THEN ','||r_tab.tab_seq END END END
                       || CASE WHEN NVL(p_aliases,'N')='Y' AND UPPER(r_tab.table_alias) != UPPER(r_tab.table_name) THEN ' @'||UPPER(r_tab.table_alias) END
                    || '"'
                    || CASE WHEN r_tab.extract_type = 'B' THEN ' fillcolor=green fontcolor=black'
                            WHEN r_tab.extract_type = 'P' THEN ' fillcolor=blue fontcolor=white'
                            WHEN r_tab.extract_type = 'F' THEN ' fillcolor=black fontcolor=white'
                            WHEN r_tab.extract_type IN ('N','R') THEN ' fillcolor=red fontcolor=white'
                    END;
         PIPE ROW(line(6, r_tab.tab_table_name||' ['||TRIM(l_node_att)||']'));
         <<con_loop>>
         FOR r_con IN c_con(r_tab.tab_table_name) LOOP
            l_edge := CASE WHEN NVL(r_con.cardinality,'1-N') = '1-N' OR r_con.set_type = 'GEN'
                           THEN r_con.con_dst_table_name||' -> '||r_con.con_src_table_name
                           ELSE r_con.con_src_table_name||' -> '||r_con.con_dst_table_name
                       END;
            l_edge_att := CASE WHEN r_con.set_type = 'GEN' AND r_con.cardinality = 'N-1' THEN 'arrowhead=crow arrowtail=crow'
                               WHEN r_con.extract_type IS NULL THEN ''
                               WHEN r_con.extract_type = 'B' THEN 'fillcolor=green'
                               WHEN r_con.extract_type = 'P' THEN 'fillcolor=blue'
                               WHEN r_con.extract_type = 'N' THEN 'fillcolor=red'
                           END
                       || CASE WHEN r_con.cardinality IS NULL THEN ' arrowhead=crow arrowtail=crow' END
                       || CASE WHEN r_con.extract_type IS NOT NULL THEN ' label=" '||r_con.extract_count||' "' END;
            PIPE ROW(line(6, l_edge||' ['||TRIM(l_edge_att)||'];'));
         END LOOP con_loop;
      END LOOP tab_loop;
      PIPE ROW(line(3, '}'));
      IF NVL(p_legend,'Y') = 'Y' THEN
         IF r_set.set_type = 'SUB' THEN
            PIPE ROW(line(3, 'subgraph cluster_legend {'));
            PIPE ROW(line(6, 'label=<<b>Legend</b>>'));
            PIPE ROW(line(6, 'rankdir=TB'));
            PIPE ROW(line(6, 'BTABLE [label="B-TABLE\nBase/driving table " fillcolor=green fontcolor=black]'));
            PIPE ROW(line(6, 'PTABLE [label="P-TABLE\nPartially extracted" fillcolor=blue fontcolor=white]'));
            PIPE ROW(line(6, 'NTABLE [label="N-TABLE\n   Not extracted   " fillcolor=red fontcolor=white]'));
            PIPE ROW(line(6, 'FTABLE [label="F-TABLE\n  Fully extracted  " fillcolor=black fontcolor=white]'));
            IF NVL(p_full_schema,'N') = 'Y' THEN
               PIPE ROW(line(6, 'XTABLE [label="X-TABLE\n  Not in dataset   "]'));
            END IF;
            PIPE ROW(line(6, 'BTABLE -> PTABLE [label=" B-Cons\n (driving)" fillcolor=green]'));
            PIPE ROW(line(6, 'PTABLE -> NTABLE [label=" P-Cons\n (integrity)" fillcolor=blue]'));
            PIPE ROW(line(6, 'NTABLE -> FTABLE [label= " N-Cons\n (not used)" fillcolor=red]'));
            IF NVL(p_full_schema,'N') = 'Y' THEN
               PIPE ROW(line(6, 'FTABLE -> XTABLE [label=" foreign\n key" arrowhead=crow arrowtail=crow dir=back]'));
            END IF;
            PIPE ROW(line(3, '}'));
         ELSIF r_set.set_type = 'GEN' THEN
            PIPE ROW(line(3, 'subgraph cluster_legend {'));
            PIPE ROW(line(6, 'label=<<b>Legend</b>>'));
            PIPE ROW(line(6, 'rankdir=TB'));
            PIPE ROW(line(6, 'BTABLE [label="B-TABLE\n  Base/driving table " fillcolor=green fontcolor=black]'));
            PIPE ROW(line(6, 'PTABLE [label="P-TABLE\nGenerated from master" fillcolor=blue fontcolor=white]'));
            PIPE ROW(line(6, 'NTABLE [label="N-TABLE\n    Not generated    " fillcolor=red fontcolor=white]'));
            IF NVL(p_full_schema,'N') = 'Y' THEN
               PIPE ROW(line(6, 'XTABLE [label="X-TABLE\n    Not in dataset   "]'));
            END IF;
            PIPE ROW(line(6, 'BTABLE -> PTABLE [label=" B-Cons\n (driving)" fillcolor=green]'));
            PIPE ROW(line(6, 'PTABLE -> NTABLE [label=" P-Cons\n (reference)" arrowhead=crow arrowtail=crow dir=back]'));
            IF NVL(p_full_schema,'N') = 'Y' THEN
               PIPE ROW(line(6, 'NTABLE -> XTABLE [label= " N-Cons\n (not used)" fillcolor=red]'));
            ELSE
               PIPE ROW(line(6, 'NTABLE -> PTABLE [label= " N-Cons\n (not used)" fillcolor=red]'));
            END IF;
            PIPE ROW(line(3, '}'));
         END IF;
      END IF;
      PIPE ROW(line(0,'}'));
   END graph_data_set;
--#begin public
   ---
   -- Set data extraction/generation path
   ---
   PROCEDURE include_path (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_path IN VARCHAR2
   )
--#end public
   IS
      TYPE lr_table_record_type IS RECORD (
         table_name ds_tables.table_name%TYPE
       , table_alias ds_tables.table_alias%TYPE
       , extract_type ds_tables.extract_type%TYPE
       , params ds_utility_var.g_small_buf_type
       , in_data_set VARCHAR2(1)
       , is_processed VARCHAR2(1)
      );
      lr_tab lr_table_record_type;
      lr_src_tab lr_table_record_type;
      lr_tgt_tab lr_table_record_type;
      TYPE lt_table_record_type IS TABLE OF lr_table_record_type INDEX BY BINARY_INTEGER;
      lt_src_tab lt_table_record_type;
      lt_tgt_tab lt_table_record_type;
      TYPE lr_constraint_record_type IS RECORD (
         constraint_name ds_constraints.constraint_name%TYPE
       , cardinality ds_constraints.cardinality%TYPE
       , extract_type ds_tables.extract_type%TYPE
       , params ds_utility_var.g_small_buf_type
       , arrow VARCHAR2(3 CHAR)
       , in_data_set VARCHAR2(1)
       , recursive_level PLS_INTEGER
      );
      lr_con lr_constraint_record_type;
      TYPE lt_constraint_record_type IS TABLE OF lr_constraint_record_type INDEX BY BINARY_INTEGER;
      TYPE la_table_name_type IS TABLE OF ds_utility_var.object_name INDEX BY ds_utility_var.object_name;
      la_tab_names la_table_name_type;
      TYPE lr_column_record_type IS RECORD (
         column_name ds_tab_columns.col_name%TYPE
       , extract_type ds_tables.extract_type%TYPE
       , params ds_utility_var.g_small_buf_type
       , in_data_set VARCHAR2(1)
      );
      lr_col lr_column_record_type;
      l_line ds_utility_var.largest_string := p_path;
      l_source ds_utility_var.g_long_name_type;
      l_target ds_utility_var.g_long_name_type;
      l_stat_count INTEGER := 0;
      r_tab ds_tables%ROWTYPE;
      r_tab_pk ds_tables%ROWTYPE;
      r_tab_fk ds_tables%ROWTYPE;
      l_pk_table_alias ds_utility_var.g_short_name_type;
      l_fk_table_alias ds_utility_var.g_short_name_type;
      TYPE lt_pls_integer_type IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
      lt_tab_param_names ds_utility_var.gt_small_buf_type;
      la_tab_param_names ds_utility_var.ga_small_buf_type;
      lt_tab_param_values ds_utility_var.gt_small_buf_type;
      lt_tab_def_param_values ds_utility_var.gt_small_buf_type;
      lt_tab_param_types ds_utility_var.gt_small_buf_type;
      lt_tab_param_len lt_pls_integer_type;
      lt_con_param_names ds_utility_var.gt_small_buf_type;
      la_con_param_names ds_utility_var.ga_small_buf_type;
      lt_con_param_values ds_utility_var.gt_small_buf_type;
      lt_con_def_param_values ds_utility_var.gt_small_buf_type;
      lt_con_param_types ds_utility_var.gt_small_buf_type;
      lt_con_param_len lt_pls_integer_type;
      lt_col_param_names ds_utility_var.gt_small_buf_type;
      la_col_param_names ds_utility_var.ga_small_buf_type;
      lt_col_param_values ds_utility_var.gt_small_buf_type;
      lt_col_def_param_values ds_utility_var.gt_small_buf_type;
      lt_col_param_types ds_utility_var.gt_small_buf_type;
      lt_col_param_len lt_pls_integer_type;
      lt_msk_param_names ds_utility_var.gt_small_buf_type;
      la_msk_param_names ds_utility_var.ga_small_buf_type;
      lt_msk_param_values ds_utility_var.gt_small_buf_type;
      lt_msk_def_param_values ds_utility_var.gt_small_buf_type;
      lt_msk_param_types ds_utility_var.gt_small_buf_type;
      lt_msk_param_len lt_pls_integer_type;
      l_arrow_count PLS_INTEGER;
      l_row_count PLS_INTEGER;
      l_update BOOLEAN;
      l_ch VARCHAR2(1 CHAR);
      CURSOR c_set (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      r_set c_set%ROWTYPE;
      PROCEDURE count_columns IS
         l_count PLS_INTEGER;
      BEGIN
         SELECT COUNT(*)
           INTO l_count
           FROM ds_tab_columns
          WHERE table_id IN (
             SELECT table_id
               FROM ds_tables
              WHERE set_id = 61
          );
          dbms_output.put_line('COUNT='||l_count);
      END;
      -- Is letter?
      FUNCTION is_letter (
         p_char IN VARCHAR2
      )
      RETURN BOOLEAN
      IS
      BEGIN
         RETURN NVL(p_char BETWEEN 'A' AND 'Z' OR p_char BETWEEN 'a' AND 'z',FALSE);
      END;
      -- Is wildcard?
      FUNCTION is_wildcard (
         p_char IN VARCHAR2
      )
      RETURN BOOLEAN
      IS
      BEGIN
         RETURN NVL(p_char IN ('*','?'),FALSE);
      END;
      -- Contains wildcard?
      FUNCTION contains_wildcard (
         p_string IN VARCHAR2
      )
      RETURN BOOLEAN
      IS
      BEGIN
         RETURN NVL(INSTR(p_string,'*')>0 OR INSTR(p_string,'?')>0,FALSE);
      END;
      -- Is digit?
      FUNCTION is_digit (
         p_char IN VARCHAR2
      )
      RETURN BOOLEAN
      IS
      BEGIN
         RETURN NVL(p_char BETWEEN '0' AND '9',FALSE);
      END;
      -- Consume leading white spaces
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
      -- Consume an identifier
      FUNCTION consume_identifier (
         pio_line IN OUT VARCHAR2
       , p_wildcards IN BOOLEAN := FALSE -- allow wildcards
       , p_ws IN BOOLEAN := TRUE -- consume trailing spaces
      )
      RETURN VARCHAR2
      IS
         l_identifier ds_utility_var.g_small_buf_type;
         l_char VARCHAR2(1 CHAR);
      BEGIN
         l_char := SUBSTR(pio_line,1,1);
         WHILE is_letter(l_char) OR is_digit(l_char) OR l_char='_' OR (p_wildcards AND is_wildcard(l_char)) LOOP
            l_identifier := l_identifier || l_char;
            pio_line := SUBSTR(pio_line,2);
            l_char := SUBSTR(pio_line,1,1);
         END LOOP;
         IF p_ws THEN
            consume_leading_spaces(pio_line);
         END IF;
         RETURN l_identifier;
      END;
      -- Consume an integer
      FUNCTION consume_integer (
         pio_line IN OUT VARCHAR2
       , p_ws IN BOOLEAN := TRUE -- consume trailing spaces
      )
      RETURN VARCHAR2
      IS
         l_number ds_utility_var.g_small_buf_type;
         l_char VARCHAR2(1 CHAR);
      BEGIN
         l_char := SUBSTR(pio_line,1,1);
         WHILE is_digit(l_char) LOOP
            l_number := l_number || l_char;
            pio_line := SUBSTR(pio_line,2);
            l_char := SUBSTR(pio_line,1,1);
         END LOOP;
         IF p_ws THEN
            consume_leading_spaces(pio_line);
         END IF;
         RETURN l_number;
      END;
      -- Consume a number
      FUNCTION consume_number (
         pio_line IN OUT VARCHAR2
       , p_ws IN BOOLEAN := TRUE -- consume trailing spaces
      )
      RETURN VARCHAR2
      IS
         l_number ds_utility_var.g_small_buf_type;
         l_char VARCHAR2(1 CHAR);
         l_dot BOOLEAN := FALSE;
         l_cnt PLS_INTEGER := 0;
      BEGIN
         l_char := SUBSTR(pio_line,1,1);
         WHILE is_digit(l_char) OR (l_cnt=0 AND l_char='-') OR (l_char='.' AND NOT l_dot) LOOP
            l_dot := l_char = '.';
            l_number := l_number || l_char;
            pio_line := SUBSTR(pio_line,2);
            l_char := SUBSTR(pio_line,1,1);
            l_cnt := l_cnt + 1;
         END LOOP;
         IF p_ws THEN
            consume_leading_spaces(pio_line);
         END IF;
         RETURN l_number;
      END;
      -- Consume params
      FUNCTION consume_delimited_content (
         pio_line IN OUT VARCHAR2
       , p_opening_char IN VARCHAR2
       , p_closing_char IN VARCHAR2
       , p_ws IN BOOLEAN := TRUE -- consume trailing spaces
      )
      RETURN VARCHAR2
      IS
         l_params ds_utility_var.g_small_buf_type;
         l_pos INTEGER;
     BEGIN
         assert(SUBSTR(pio_line,1,1)=p_opening_char,'Internal error, expecting "'||p_opening_char||'", got '||SUBSTR(pio_line,1,1));
         pio_line := SUBSTR(pio_line,2);
         l_pos := search_char(pio_line,p_closing_char);
         assert(l_pos>0,'Syntax error: "'||p_opening_char||'" without "'||p_closing_char||'": '||SUBSTR(pio_line,-30));
         l_params := SUBSTR(pio_line,1,l_pos-1);
         pio_line := SUBSTR(pio_line,l_pos+1);
         IF p_ws THEN
            consume_leading_spaces(pio_line);
         END IF;
         RETURN l_params;
      END;
      -- Consume keyword
      PROCEDURE consume_keyword (
         pio_line IN OUT VARCHAR2
       , p_value IN VARCHAR2
       , p_ws IN BOOLEAN := TRUE -- consume trailing spaces
      )
      IS
         l_len INTEGER := LENGTH(p_value);
      BEGIN
         -- Check keyword
         assert(SUBSTR(pio_line,1,l_len)=p_value,'keyword '||p_value||' not found');
         pio_line := SUBSTR(pio_line,l_len+1);
         IF p_ws THEN
            consume_leading_spaces(pio_line);
         END IF;
      END;
      -- Replace comments with spaces
      PROCEDURE remove_comments (
         pio_line IN OUT VARCHAR2
      )
      IS
         l_beg PLS_INTEGER;
         l_end PLS_INTEGER;
      BEGIN
         LOOP
            l_beg := NVL(INSTR(pio_line,'/*'),0);
            EXIT WHEN l_beg <= 0;
            l_end:= NVL(INSTR(pio_line,'*/',l_beg+2),0);
            assert(l_end>0,'Error: unterminated comment');
            pio_line := SUBSTR(pio_line,1,l_beg-1)
                     || RPAD(' ',l_end+2-l_beg)
                     || SUBSTR(pio_line,l_end+2);
                     
         END LOOP;
      END;
      -- Check if a string matches a parameter name
      FUNCTION param_name_matches (
         p_string IN VARCHAR2     -- input string
       , p_param_name IN VARCHAR2 -- parameter name
       , p_min_len IN PLS_INTEGER -- minimum length
      )
      RETURN BOOLEAN
      IS
         -- ABC)DE means ABC, ABCD, ABCDE are matching
         -- while A, AB, ABCDEF are not matching
         l_str_len PLS_INTEGER;
         l_name_len PLS_INTEGER;
      BEGIN
         l_str_len := LENGTH(p_string);
         l_name_len := LENGTh(p_param_name);
         RETURN l_str_len BETWEEN p_min_len AND l_name_len
            AND p_string = SUBSTR(p_param_name,1,l_str_len);
      END;
      -- Parse parameters
      PROCEDURE parse_params (
         piv_params IN VARCHAR2
       , pit_names IN ds_utility_var.gt_small_buf_type
       , pia_names IN ds_utility_var.ga_small_buf_type
       , pit_types IN ds_utility_var.gt_small_buf_type
       , pit_len IN lt_pls_integer_type
       , piot_values IN OUT ds_utility_var.gt_small_buf_type
       , pi_reset IN BOOLEAN := TRUE
      )
      IS
         l_buf ds_utility_var.g_small_buf_type;
         l_params ds_utility_var.g_small_buf_type;
         l_param_name ds_utility_var.g_small_buf_type;
         l_param_type ds_utility_var.g_small_buf_type;
         l_param_value ds_utility_var.g_small_buf_type;
         l_param_len PLS_INTEGER;
         l_type VARCHAR2(1);
         l_case VARCHAR2(1);
         l_len PLS_INTEGER;
         l_num NUMBER;
         l_opt BOOLEAN;
         l_format VARCHAR2(30);
         l_char VARCHAR2(1 CHAR);
         l_index PLS_INTEGER;
      BEGIN
         l_params := piv_params;
         consume_leading_spaces(l_params);
         IF pi_reset THEN
            piot_values.DELETE;
         END IF;
         WHILE l_params IS NOT NULL LOOP
            assert(is_letter(SUBSTR(l_params,1,1)),'Property name expected');
            l_buf := LOWER(consume_identifier(l_params));
            l_param_name := pia_names.FIRST;
            WHILE l_param_name IS NOT NULL LOOP
               l_index := pia_names(l_param_name);
               l_param_len := pit_len(l_index);
               EXIT WHEN param_name_matches(l_buf,l_param_name,l_param_len);
               l_param_name := pia_names.NEXT(l_param_name);
            END LOOP;
            assert(l_param_name IS NOT NULL,'Invalid property name: "'||l_buf||'"');
            assert(pia_names.EXISTS(l_param_name),'Invalid property name: "'||l_param_name||'"');
            l_index := pia_names(l_param_name);
            assert(NOT piot_values.EXISTS(l_index) OR l_param_name IN ('extract_type') OR NOT pi_reset,'Property "'||l_param_name||'" specified twice: '||piv_params);
            assert(SUBSTR(l_params,1,1) = '=','Equal sign (=) expected');
            consume_keyword(l_params,'=');
            l_param_type := pit_types(l_index);
            l_opt := SUBSTR(l_param_type,1,1) = 'O';
            l_case := SUBSTR(l_param_type,2,1);
            l_type := SUBSTR(l_param_type,3,1);
            l_format := SUBSTR(l_param_type,4);
            l_char := SUBSTR(l_params,1,1);
            l_param_value := NULL;
            IF l_char = '"' THEN
               l_param_value := consume_delimited_content(l_params,'"','"');
            ELSIF l_char IN ('-','.') OR is_digit(l_char) THEN
               l_param_value := consume_number(l_params);
            ELSIF is_letter(l_char) OR l_char = '_' THEN
               assert(NOT l_type='N','Number expected for property "'||l_param_name||'"');
               l_param_value := consume_identifier(l_params);
            END IF;
            assert(l_opt OR l_param_value IS NOT NULL,'Value is mandatory for property "'||l_param_name||'"');
            IF l_case = 'L' THEN
               l_param_value := LOWER(l_param_value);
            ELSIF l_case = 'U' THEN
               l_param_value := UPPER(l_param_value);
            END IF;
            IF l_type IN ('C','F') THEN
               l_len := TO_NUMBER(l_format);
               assert(NVL(LENGTH(l_param_value),0)<=l_len,'Value too long (max size is "'||l_len||'") for property "'||l_param_name||'"');
               assert(l_type != 'F' OR NVL(l_param_value,'Y') IN ('Y','N'),'Invalid value for "'||l_param_name||'", flag must be "Y" or "N"');
            ELSIF l_type = 'N' THEN
               BEGIN
                  l_num := TO_NUMBER(l_param_value, l_format);
               EXCEPTION
                  WHEN OTHERS THEN
                     assert(FALSE,'Invalid number (expected format is "'||l_format||'") for property "'||l_param_name||'"');
               END;
            END IF;
            piot_values(l_index) := l_param_value;
            IF SUBSTR(l_params,1,1) IN (',',';') THEN
               consume_keyword(l_params, SUBSTR(l_params,1,1));
            END IF;
         END LOOP;
      END;
      -- Get table parameter value
      FUNCTION get_tab_param_value (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , p_def_param_value IN VARCHAR2 := NULL
      )
      RETURN BOOLEAN
      IS
         l_index PLS_INTEGER;
         l_exists BOOLEAN;
      BEGIN
         l_index := la_tab_param_names(p_param_name);
         l_exists := lt_tab_param_values.EXISTS(l_index);
         IF l_exists THEN
            p_param_value := lt_tab_param_values(l_index);
         ELSIF p_param_value IS NULL THEN
            l_exists := lt_tab_def_param_values.EXISTS(l_index);
            IF l_exists THEN
               p_param_value := lt_tab_def_param_values(l_index);
            END IF;
         END IF;
         p_param_value := NVL(p_param_value, p_def_param_value);
         RETURN l_exists;
      END;
      -- Get constraint parameter value
      FUNCTION get_con_param_value (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , p_def_param_value IN VARCHAR2 := NULL
      )
      RETURN BOOLEAN
      IS
         l_index PLS_INTEGER;
         l_exists BOOLEAN;
      BEGIN
         l_index := la_con_param_names(p_param_name);
         l_exists := lt_con_param_values.EXISTS(l_index);
         IF l_exists THEN
            p_param_value := lt_con_param_values(l_index);
         ELSIF p_param_value IS NULL THEN
            l_exists := lt_con_def_param_values.EXISTS(l_index);
            IF l_exists THEN
               p_param_value := lt_con_def_param_values(l_index);
            END IF;
         END IF;
         p_param_value := NVL(p_param_value, p_def_param_value);
         RETURN l_exists;
      END;
      -- Get column parameter value
      FUNCTION get_col_param_value (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , p_def_param_value IN VARCHAR2 := NULL
      )
      RETURN BOOLEAN
      IS
         l_index PLS_INTEGER;
         l_exists BOOLEAN;
      BEGIN
         l_index := la_col_param_names(p_param_name);
         l_exists := lt_col_param_values.EXISTS(l_index);
         IF l_exists THEN
            p_param_value := lt_col_param_values(l_index);
         ELSIF p_param_value IS NULL THEN
            l_exists := lt_col_def_param_values.EXISTS(l_index);
            IF l_exists THEN
               p_param_value := lt_col_def_param_values(l_index);
            END IF;
         END IF;
         p_param_value := NVL(p_param_value, p_def_param_value);
         RETURN l_exists;
      END;
      -- Get mask parameter value
      FUNCTION get_msk_param_value (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , p_def_param_value IN VARCHAR2 := NULL
      )
      RETURN BOOLEAN
      IS
         l_index PLS_INTEGER;
         l_exists BOOLEAN;
      BEGIN
         l_index := la_msk_param_names(p_param_name);
         l_exists := lt_msk_param_values.EXISTS(l_index);
         IF l_exists THEN
            p_param_value := lt_msk_param_values(l_index);
         ELSIF p_param_value IS NULL THEN
            l_exists := lt_msk_def_param_values.EXISTS(l_index);
            IF l_exists THEN
               p_param_value := lt_msk_def_param_values(l_index);
            END IF;
         END IF;
         p_param_value := NVL(p_param_value, p_def_param_value);
         RETURN l_exists;
      END;
      -- Get table property value from parameter
      PROCEDURE get_tab_value_from_param (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , pio_changed IN OUT BOOLEAN
       , p_def_param_value IN VARCHAR2 := NULL
      )
      IS
         l_param_value ds_utility_var.g_small_buf_type;
         l_changed BOOLEAN;
      BEGIN
         l_param_value := p_param_value;
         IF get_tab_param_value(p_param_name, l_param_value, p_def_param_value) THEN
            l_changed := (p_param_value IS NULL AND l_param_value IS NOT NULL)
                      OR (p_param_value IS NOT NULL AND l_param_value IS NULL)
                      OR (p_param_value != l_param_value);
            IF l_changed THEN
               ds_utility_krn.show_message('I','Table property "'||p_param_name||'" set to "'||l_param_value||'"'||CASE WHEN p_param_value IS NOT NULL THEN ', was "'||p_param_value||'"' END);
               p_param_value := l_param_value;
               pio_changed := TRUE;
            END IF;
         END IF;
      END;
      -- Get constraint property value from parameter
      PROCEDURE get_con_value_from_param (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , pio_changed IN OUT BOOLEAN
       , p_def_param_value IN VARCHAR2 := NULL
      )
      IS
         l_param_value ds_utility_var.g_small_buf_type;
         l_changed BOOLEAN;
      BEGIN
         l_param_value := p_param_value;
         IF get_con_param_value(p_param_name, l_param_value, p_def_param_value) THEN
            l_changed := (p_param_value IS NULL AND l_param_value IS NOT NULL)
                      OR (p_param_value IS NOT NULL AND l_param_value IS NULL)
                      OR (p_param_value != l_param_value);
            IF l_changed THEN
               ds_utility_krn.show_message('I','Constraint property "'||p_param_name||'" set to "'||l_param_value||'"'||CASE WHEN p_param_value IS NOT NULL THEN ', was "'||p_param_value||'"' END);
               p_param_value := l_param_value;
               pio_changed := TRUE;
            END IF;
         END IF;
      END;
      -- Get column property value from parameter
      PROCEDURE get_col_value_from_param (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , pio_changed IN OUT BOOLEAN
       , p_def_param_value IN VARCHAR2 := NULL
      )
      IS
         l_param_value ds_utility_var.g_small_buf_type;
         l_changed BOOLEAN;
      BEGIN
         l_param_value := p_param_value;
         IF get_col_param_value(p_param_name, l_param_value, p_def_param_value) THEN
            l_changed := (p_param_value IS NULL AND l_param_value IS NOT NULL)
                      OR (p_param_value IS NOT NULL AND l_param_value IS NULL)
                      OR (p_param_value != l_param_value);
            IF l_changed THEN
               ds_utility_krn.show_message('I','Column property "'||p_param_name||'" set to "'||l_param_value||'"'||CASE WHEN p_param_value IS NOT NULL THEN ', was "'||p_param_value||'"' END);
               p_param_value := l_param_value;
               pio_changed := TRUE;
            END IF;
         END IF;
      END;
      -- Get mask property value from parameter
      PROCEDURE get_msk_value_from_param (
         p_param_name IN VARCHAR2
       , p_param_value IN OUT VARCHAR2
       , pio_changed IN OUT BOOLEAN
       , p_def_param_value IN VARCHAR2 := NULL
      )
      IS
         l_param_value ds_utility_var.g_small_buf_type;
         l_changed BOOLEAN;
      BEGIN
         l_param_value := p_param_value;
         IF get_msk_param_value(p_param_name, l_param_value, p_def_param_value) THEN
            l_changed := (p_param_value IS NULL AND l_param_value IS NOT NULL)
                      OR (p_param_value IS NOT NULL AND l_param_value IS NULL)
                      OR (p_param_value != l_param_value);
            IF l_changed THEN
               ds_utility_krn.show_message('I','Mask property "'||p_param_name||'" set to "'||l_param_value||'"'||CASE WHEN p_param_value IS NOT NULL THEN ', was "'||p_param_value||'"' END);
               p_param_value := l_param_value;
               pio_changed := TRUE;
            END IF;
         END IF;
      END;
      -- Process table name/alias and returns its name
      PROCEDURE process_table (
         p_table_name IN OUT VARCHAR2
       , p_table_alias IN OUT VARCHAR2
       , p_extract_type IN OUT VARCHAR2
       , p_params IN VARCHAR2
       , p_col_extract_type IN VARCHAR2 := NULL
      )
      IS
         CURSOR c_tab1 (
            p_table_name IN VARCHAR2
         )
         IS
            SELECT *
              FROM sys.all_tables
             WHERE owner = ds_utility_var.g_owner
               AND table_name = UPPER(p_table_name)
         ;
         CURSOR c_tab2 (
            p_table_alias IN VARCHAR2
         )
         IS
            SELECT *
              FROM ds_tables
             WHERE set_id = p_set_id
               AND table_alias = LOWER(p_table_alias)
         ;
         CURSOR c_tab3 (
            p_table_name IN VARCHAR2
         )
         IS
            SELECT *
              FROM ds_tables
             WHERE set_id = p_set_id
               AND table_name = UPPER(p_table_name)
         ;
         r_ora sys.all_tables%ROWTYPE;
         r_tab ds_tables%ROWTYPE;
         l_found BOOLEAN;
         l_update BOOLEAN;
         l_table_alias_param ds_tables.table_alias%TYPE;
         l_table_alias_exists BOOLEAN;
--         l_extract_type_param ds_tables.extract_type%TYPE;
--         l_extract_type_exists BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->process_table('||p_table_name||','||p_table_alias||','||p_extract_type||','||p_params||')');
         -- Fetch table from its name
         OPEN c_tab1(p_table_name);
         FETCH c_tab1 INTO r_ora;
         l_found := c_tab1%FOUND;
         CLOSE c_tab1;
         -- Table must exists if an alias is given
         assert(l_found OR p_table_alias IS NULL, 'No table "'||p_table_name||'" found in data dictionary!');
         -- Get parameters
         parse_params(p_params,lt_tab_param_names,la_tab_param_names,lt_tab_param_types,lt_tab_param_len,lt_tab_param_values);
         l_table_alias_exists := get_tab_param_value('table_alias', l_table_alias_param);
         assert(NOT (p_table_alias IS NOT NULL AND l_table_alias_param IS NOT NULL),'Table alias cannot be specified twice');
         p_table_alias := NVL(p_table_alias,l_table_alias_param);
--         l_extract_type_exists := get_tab_param_value('extract_type', l_extract_type_param);
--         assert(NOT (p_extract_type IS NOT NULL AND l_extract_type_param IS NOT NULL),'Extract type cannot be specified twice');
--         p_extract_type := NVL(p_extract_type,l_extract_type_param);
         -- ...
         IF NOT l_found THEN
            -- Table not found based on its name => fetch tables from its alias
            OPEN c_tab2(p_table_name);
            FETCH c_tab2 INTO r_tab;
            l_found := c_tab2%FOUND;
            CLOSE c_tab2;
            assert(l_found, 'No table "'||p_table_name||'" found in data dictionary!');
            p_table_name := r_tab.table_name;
            IF p_table_alias IS NULL THEN
               p_table_alias := r_tab.table_alias;
            END IF;
         END IF;
         -- Check if table is in the data set
         OPEN c_tab3(p_table_name);
         FETCH c_tab3 INTO r_tab;
         l_found := c_tab3%FOUND;
         CLOSE c_tab3;
         -- Overwrite properties with parameter values
         ds_utility_krn.show_message('I','Processing table "'||p_table_name||'"...');
         l_update := FALSE;
         -- Use cases: rtab/param: NULL/x=>x(set), NULL/NULL=>gen, x/NULL=>x(unchanged), x/x=>(unchanged), x/y=>y(change)
         IF r_tab.table_alias IS NULL OR r_tab.table_alias != NVL(p_table_alias,r_tab.table_alias) THEN
            IF p_table_alias IS NOT NULL THEN
               ds_utility_krn.show_message('I','Table alias set to "'||p_table_alias||'"'||CASE WHEN r_tab.table_alias IS NOT NULL THEN ', was "'||r_tab.table_alias||'"' END);
            END IF;
            r_tab.table_alias := p_table_alias;
            l_update := TRUE;
         END IF;
--         IF (r_tab.extract_type IS NULL OR r_tab.extract_type != NVL(p_extract_type,r_tab.extract_type)) AND NOT NVL(p_extract_type,'P') IN ('X','D') THEN
--            ds_utility_krn.show_message('I','Extract type set to "'||NVL(p_extract_type,'P')||'"'||CASE WHEN r_tab.extract_type IS NOT NULL THEN ', was "'||r_tab.extract_type||'"' END);
--            r_tab.extract_type := p_extract_type;
--            l_update := TRUE;
--         END IF;
         get_tab_value_from_param('extract_type', r_tab.extract_type, l_update, 'P');
         get_tab_value_from_param('where_clause', r_tab.where_clause, l_update);
         get_tab_value_from_param('row_limit', r_tab.row_limit, l_update);
         assert(NVL(r_tab.row_limit,0) >= 0,'Invalid value for "row_limit" property, must be >=0');
         get_tab_value_from_param('row_count', r_tab.row_count, l_update);
         assert(NVL(r_tab.row_count,0) >= 0,'Invalid value for "row_count" property, must be >=0');
         get_tab_value_from_param('percentage', r_tab.percentage, l_update);
         assert(NVL(r_tab.percentage,0) BETWEEN 0 AND 100,'Invalid value for "percentage" property, must be between 0 and 100');
         get_tab_value_from_param('order_by_clause', r_tab.order_by_clause, l_update);
         get_tab_value_from_param('columns_list', r_tab.columns_list, l_update);
         get_tab_value_from_param('export_mode', r_tab.export_mode, l_update);
         get_tab_value_from_param('source_schema', r_tab.source_schema, l_update);
         get_tab_value_from_param('source_db_link', r_tab.source_db_link, l_update);
         get_tab_value_from_param('target_schema', r_tab.target_schema, l_update);
         get_tab_value_from_param('target_db_link', r_tab.target_db_link, l_update);
         get_tab_value_from_param('user_column_name', r_tab.user_column_name, l_update);
         get_tab_value_from_param('batch_size', r_tab.batch_size, l_update);
         assert(NVL(r_tab.batch_size,1) > 0,'Invalid value for "batch_size" property, must be >0');
         get_tab_value_from_param('tab_seq', r_tab.tab_seq, l_update);
         get_tab_value_from_param('gen_view_name', r_tab.gen_view_name, l_update);
         get_tab_value_from_param('pre_gen_code', r_tab.pre_gen_code, l_update);
         get_tab_value_from_param('post_gen_code', r_tab.post_gen_code, l_update);
         IF l_found THEN
            -- Table already in data set
            IF p_extract_type IN ('X','D') THEN
               -- Remove constraints linked to table to remove from data set
               DELETE ds_constraints
                WHERE set_id = p_set_id
                  AND (src_table_name = r_tab.table_name OR dst_table_name = r_tab.table_name)
               ;
               l_row_count := SQL%ROWCOUNT;
               IF l_row_count > 0 THEN
                  ds_utility_krn.show_message('I',l_row_count||' constraints removed from data set for table "'||r_tab.table_name||'"');
               END IF;
               -- Remove table columns from data set
               DELETE ds_tab_columns
                WHERE table_id = r_tab.table_id
               ;
               l_row_count := SQL%ROWCOUNT;
               IF l_row_count > 0 THEN
                  ds_utility_krn.show_message('I',l_row_count||' columns removed from data set for table "'||r_tab.table_name||'"');
               END IF;
               -- Remove table from data set
               DELETE ds_tables
                WHERE table_id = r_tab.table_id
               ;
               assert(SQL%ROWCOUNT=1,'Cannot delete table "'||r_tab.table_name||'"!');
               ds_utility_krn.show_message('I','Table "'||r_tab.table_name||'" removed from data set');
            ELSE
               ds_utility_krn.show_message('I','Table properties '||CASE WHEN NOT l_update THEN 'not ' END||'updated');
               IF l_update THEN
                  -- Update table alias and/or extract type
                  UPDATE ds_tables
                     SET ROW = r_tab
                   WHERE table_id = r_tab.table_id
                  ; 
                  assert(SQL%ROWCOUNT=1,'Cannot update properties of table "'||r_tab.table_name||'"!');
               END IF;
               p_table_alias := NVL(p_table_alias, r_tab.table_alias);
               p_extract_type := NVL(p_extract_type, r_tab.extract_type);
            END IF;
         ELSIF NVL(p_extract_type,'P') IN ('X','D') THEN
            ds_utility_krn.show_message('I','Table not found in data set hence not removed!');
         ELSE
            -- Ensure alias is not already used
            IF p_table_alias IS NOT NULL THEN
               DECLARE
                  r_tab ds_tables%ROWTYPE;
               BEGIN
                  OPEN c_tab2(p_table_alias);
                  FETCH c_tab2 INTO r_tab;
                  l_found := c_tab2%FOUND;
                  CLOSE c_tab2;
                  assert(NOT l_found,'Table alias "'||p_table_alias||'" already used for table "'||r_tab.table_name||'"!');
               END;
            END IF;
            -- Include table in data set
            r_tab.set_id := p_set_id;
            r_tab.table_name := p_table_name;
            r_tab.table_alias := p_table_alias;
            r_tab.source_count := r_ora.num_rows;
            r_tab.extract_type := NVL(p_extract_type,'P');
            ds_utility_krn.insert_table(r_tab);
            IF p_table_alias IS NULL THEN
               ds_utility_krn.show_message('I','Table alias set to "'||r_tab.table_alias||'"');
            END IF;
            p_table_alias := r_tab.table_alias;
            p_extract_type := r_tab.extract_type;
            ds_utility_krn.show_message('I','Table "'||r_tab.table_name||'" added to data set');
            IF r_set.set_type = 'GEN' AND NOT NVL(p_col_extract_type,'Y') IN ('X','D') THEN
               ds_utility_krn.insert_table_columns(p_set_id=>r_set.set_id);
               ds_utility_krn.show_message('I','All columns of table "'||r_tab.table_name||'" added to data set');
            END IF;
         END IF;
         ds_utility_krn.show_message('D','<-process_table('||p_table_name||','||p_table_alias||','||p_extract_type||','||p_params||')');
      END;
      -- Process constraint
      PROCEDURE process_constraint (
         p_src_table_name IN ds_constraints.src_table_name%TYPE
       , p_dst_table_name IN ds_constraints.dst_table_name%TYPE
       , p_cardinality IN ds_constraints.cardinality%TYPE
       , p_extract_type IN ds_constraints.extract_type%TYPE
       , p_arrow IN VARCHAR2
       , p_params IN VARCHAR2
       , p_constraint_name IN VARCHAR2 := NULL
      )
      IS
         -- Find a constraint based on its name
         CURSOR c_con1 (
            p_constraint_name ds_constraints.constraint_name%TYPE
         )
         IS
            SELECT fk.constraint_name
                 , fk.table_name fk_table_name
                 , pk.table_name pk_table_name
                 , fk.deferred
              FROM sys.all_constraints fk
             INNER JOIN sys.all_constraints pk
                ON pk.owner = fk.owner
               AND pk.constraint_name = fk.r_constraint_name
             WHERE fk.owner = ds_utility_var.g_owner
               AND fk.constraint_name = UPPER(p_constraint_name)
               AND fk.constraint_type = 'R'
         ;
         -- Find a constraint based on its name
         -- Note: If A then B <=> NOT (A AND NOT B) <=> NOT A OR B (see below)
         CURSOR c_con2 (
            p_src_table_name IN ds_constraints.src_table_name%TYPE
          , p_dst_table_name IN ds_constraints.dst_table_name%TYPE
          , p_cardinality IN ds_constraints.cardinality%TYPE
         )
         IS
            SELECT fk.constraint_name
                 , fk.table_name fk_table_name
                 , pk.table_name pk_table_name
                 , fk.deferred
              FROM sys.all_constraints fk
             INNER JOIN sys.all_constraints pk
                ON pk.owner = fk.owner
               AND pk.constraint_name = fk.r_constraint_name
               AND (NOT p_cardinality IS NULL OR pk.table_name IN (p_src_table_name, p_dst_table_name))
               AND (NOT NVL(p_cardinality,'XXX') = '1-N' OR pk.table_name = p_src_table_name)
               AND (NOT NVL(p_cardinality,'XXX') = 'N-1' OR pk.table_name = p_dst_table_name)
             WHERE fk.owner = ds_utility_var.g_owner
               AND (NOT p_cardinality IS NULL OR fk.table_name IN (p_src_table_name, p_dst_table_name))
               AND (NOT NVL(p_cardinality,'XXX') = '1-N' OR fk.table_name = p_dst_table_name)
               AND (NOT NVL(p_cardinality,'XXX') = 'N-1' OR fk.table_name = p_src_table_name)
               AND (NOT fk.table_name = pk.table_name OR p_src_table_name = p_dst_table_name)
               AND fk.constraint_type = 'R'
         ;
         CURSOR c_con3 (
             p_constraint_name IN ds_constraints.constraint_name%TYPE
           , p_cardinality IN ds_constraints.cardinality%TYPE
         )
         IS
            SELECT *
              FROM ds_constraints
             WHERE set_id = p_set_id
               AND constraint_name = p_constraint_name
               AND (p_cardinality IS NULL OR cardinality = p_cardinality)
         ;
         r_con c_con1%ROWTYPE;
         r_con_tmp c_con1%ROWTYPE;
         r_con3 c_con3%ROWTYPE;
         l_found BOOLEAN;
         l_multi BOOLEAN;
         l_join_clause ds_constraints.join_clause%TYPE;
         l_constraint_name ds_constraints.constraint_name%TYPE;
         l_cardinality ds_constraints.cardinality%TYPE;
         l_extract_type ds_constraints.extract_type%TYPE;
         l_extract_type_param ds_tables.extract_type%TYPE;
         l_exists BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->process_constraint('||p_src_table_name||','||p_dst_table_name||','||p_cardinality
            ||','||p_extract_type||','||p_arrow||','||p_params||','||p_constraint_name||')');
         l_cardinality := p_cardinality;
         l_extract_type := p_extract_type;
         parse_params(p_params,lt_con_param_names,la_con_param_names,lt_con_param_types,lt_con_param_len,lt_con_param_values);
         l_constraint_name := p_constraint_name;
         IF l_constraint_name IS NULL THEN
            l_exists := get_con_param_value('fk', l_constraint_name);
         END IF;
         IF contains_wildcard(l_constraint_name) THEN
            l_constraint_name := NULL;
         END IF;
         l_exists := get_con_param_value('extract_type', l_extract_type);
         assert(l_extract_type_param IS NULL OR l_extract_type_param IN ('B','P','N','X','D'),'Constraint extract type must be B, P, N, X or D found: '||l_extract_type_param);
         assert(NOT (l_extract_type_param IS NOT NULL AND l_extract_type IS NOT NULL),'Extract type property is redundant with arrow style');
         l_extract_type := NVL(l_extract_type,l_extract_type_param);
         IF l_constraint_name IS NOT NULL THEN
            OPEN c_con1(l_constraint_name);
            FETCH c_con1 INTO r_con;
            l_found := c_con1%FOUND;
            CLOSE c_con1;
            assert(l_found, 'Foreign key "'||l_constraint_name||'" not found in data dictionnary!');
            assert((p_src_table_name=r_con.fk_table_name AND p_dst_table_name=r_con.pk_table_name)
                OR (p_src_table_name=r_con.pk_table_name AND p_dst_table_name=r_con.fk_table_name)
                  ,'Constraint "'||l_constraint_name||'" is not between "'||p_src_table_name||'" and "'||p_dst_table_name||'"');
            assert((NOT NVL(l_cardinality,'XXX') = '1-N' OR (p_src_table_name = r_con.pk_table_name
                                                         AND p_dst_table_name = r_con.fk_table_name))
               AND (NOT NVL(l_cardinality,'XXX') = 'N-1' OR (p_src_table_name = r_con.fk_table_name
                                                         AND p_dst_table_name = r_con.pk_table_name))
                , 'Cardinality of constraint "'||l_constraint_name||'" is not "'||l_cardinality||'"');
         ELSE
            OPEN c_con2(p_src_table_name, p_dst_table_name, l_cardinality);
            FETCH c_con2 INTO r_con;
            l_found := c_con2%FOUND;
            l_multi := FALSE;
            IF l_found THEN
               FETCH c_con2 INTO r_con_tmp;
               l_multi := c_con2%FOUND;
            END IF;
            CLOSE c_con2;
            assert(l_found,'No constraint found between "'||p_src_table_name||'" and "'||p_dst_table_name||'"'
                  || CASE WHEN l_cardinality IS NOT NULL THEN ' with cardinality "'||l_cardinality||'"' END);
            assert(NOT l_multi,'Multiple constraints found between "'||p_src_table_name||'" and "'||p_dst_table_name||'"'
                  || CASE WHEN l_cardinality IS NOT NULL THEN ' with cardinality "'||l_cardinality||'"' END);
            l_constraint_name := r_con.constraint_name;
         END IF;
         assert(NOT l_cardinality IS NULL OR r_con.fk_table_name <> r_con.pk_table_name
             , 'Arrow "'||p_arrow||'" on recursive constraint "'||r_con.constraint_name||' is ambiguous, please precise direction!"');
         IF l_cardinality IS NULL THEN
            l_cardinality := CASE WHEN p_src_table_name = r_con.fk_table_name THEN 'N-1' ELSE '1-N' END;
         END IF;
         ds_utility_krn.get_table(p_set_id,r_con.pk_table_name,r_tab_pk);
         ds_utility_krn.get_table(p_set_id,r_con.fk_table_name,r_tab_fk);
         OPEN c_con3(r_con.constraint_name, l_cardinality);
         FETCH c_con3 INTO r_con3;
         l_found := c_con3%FOUND;
         CLOSE c_con3;
         -- Update constraint properties from parameters
         ds_utility_krn.show_message('I','Processing constraint "'||l_constraint_name||'" with cardinality "'||l_cardinality||'"...');
         l_update := FALSE;
         IF (r_con3.extract_type IS NULL OR l_extract_type != r_con3.extract_type) AND NOT NVL(l_extract_type,'P') IN ('X','D') THEN
            ds_utility_krn.show_message('I','Extract type set to "'||NVL(l_extract_type,'P')||'"'||CASE WHEN r_con3.extract_type IS NOT NULL THEN ', was "'||r_con3.extract_type||'"' END);
            r_con3.extract_type := l_extract_type;
            l_update := TRUE;
         END IF;
         get_con_value_from_param('where_clause', r_con3.where_clause, l_update);
         get_con_value_from_param('percentage', r_con3.percentage, l_update);
         get_con_value_from_param('row_limit', r_con3.row_limit, l_update);
         get_con_value_from_param('min_rows', r_con3.min_rows, l_update);
         get_con_value_from_param('max_rows', r_con3.max_rows, l_update);
         get_con_value_from_param('level_count', r_con3.level_count, l_update);
         get_con_value_from_param('order_by_clause', r_con3.order_by_clause, l_update);
         get_con_value_from_param('deferred', r_con3.deferred, l_update);
         r_con3.deferred := NVL(r_con3.deferred, r_con.deferred);
         get_con_value_from_param('batch_size', r_con3.batch_size, l_update);
         get_con_value_from_param('con_seq', r_con3.con_seq, l_update);
         get_con_value_from_param('gen_view_name', r_con3.gen_view_name, l_update);
         get_con_value_from_param('pre_gen_code', r_con3.pre_gen_code, l_update);
         get_con_value_from_param('post_gen_code', r_con3.post_gen_code, l_update);
         get_con_value_from_param('src_filter', r_con3.src_filter, l_update);
         ds_utility_krn.get_aliases(r_tab_pk, r_tab_fk, l_pk_table_alias, l_fk_table_alias);
         l_join_clause := ds_utility_krn.build_join_clause(
            l_pk_table_alias
           ,l_fk_table_alias
           ,r_con.constraint_name
         );
         IF NOT NVL(l_extract_type,'P') IN ('X','D') AND (r_con3.join_clause IS NULL OR r_con3.join_clause != l_join_clause) THEN
            ds_utility_krn.show_message('I','Join clause set to "'||l_join_clause||'"'||CASE WHEN r_con3.join_clause IS NOT NULL THEN ', was "'||r_con3.join_clause||'"' END);
            r_con3.join_clause := l_join_clause;
            l_update := TRUE;
         END IF;
         IF l_found THEN
            IF l_extract_type IN ('X','D') THEN
               DELETE ds_constraints
                WHERE con_id = r_con3.con_id
               ;
               assert(SQL%ROWCOUNT=1,'Cannot delete constraint "'||r_con3.constraint_name||'" with cardinality "'||r_con3.cardinality||'"!');
               ds_utility_krn.show_message('I','Constraint "'||r_con3.constraint_name||'" with cardinality "'||r_con3.cardinality||'" removed from data set');
            ELSE
               ds_utility_krn.show_message('I','Constraint properties '||CASE WHEN NOT l_update THEN 'not ' END||'updated');
               IF l_update THEN
                  UPDATE ds_constraints
                     SET ROW = r_con3
                   WHERE con_id = r_con3.con_id
                  ;
                  assert(SQL%ROWCOUNT=1,'Cannot update properties of constraint "'||r_con3.constraint_name||'" with cardinality "'||r_con3.cardinality||'"!');
               END IF;
            END IF;
         ELSIF NVL(l_extract_type,'P') IN ('X','D') THEN
            ds_utility_krn.show_message('I','Constraint not found in data set hence not removed!');
         ELSE
            -- Create constraint
            r_con3.set_id := p_set_id;
            r_con3.constraint_name := r_con.constraint_name;
            r_con3.src_table_name := p_src_table_name;
            r_con3.dst_table_name := p_dst_table_name;
            r_con3.cardinality := l_cardinality;
            r_con3.extract_type := NVL(l_extract_type,'P');
            r_con3.source_count := CASE WHEN l_cardinality = '1-N' THEN r_tab_fk.source_count ELSE r_tab_pk.source_count END;
            ds_utility_krn.show_message('I','Constraint "'||r_con3.constraint_name||'" with cardinality "'||l_cardinality||'" added to data set');
            ds_utility_krn.insert_constraint(r_con3);
         END IF;
         l_extract_type := NVL(l_extract_type, r_con3.extract_type);
         ds_utility_krn.show_message('D','<-process_constraint('||p_src_table_name||','||p_dst_table_name||','||p_cardinality
            ||','||p_extract_type||','||p_arrow||','||p_params||','||p_constraint_name||')');
      END;
      -- Process column
      PROCEDURE process_column (
         p_tab_name IN VARCHAR2
       , p_col_name IN VARCHAR2
       , p_extract_type IN VARCHAR2
       , p_params IN VARCHAR2
      )
      IS
         r_col_param ds_tab_columns%ROWTYPE;
         CURSOR c_col (
            p_table_name IN VARCHAR2
          , p_column_name IN VARCHAR2
         )
         IS
            SELECT col.table_name, col.column_name, col.column_id
                 , ds_tab.table_id tab_id
                 , ds_col.*
              FROM sys.all_tab_columns col
             INNER JOIN sys.all_tables tab
                ON tab.owner = col.owner
               AND tab.table_name = col.table_name
             INNER JOIN ds_tables ds_tab
                ON ds_tab.set_id = p_set_id
               AND ds_tab.table_name = UPPER(p_table_name)
              LEFT OUTER JOIN ds_tab_columns ds_col
                ON ds_col.table_id = ds_tab.table_id
               AND ds_col.col_name = col.column_name
             WHERE col.owner = NVL(ds_utility_var.g_owner,USER)
               AND col.table_name = UPPER(p_table_name)
               AND col.column_name = UPPER(p_column_name)
         ;
         r_col c_col%ROWTYPE;
         l_found BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->process_column('||p_tab_name||','||p_col_name||','||p_extract_type||','||p_params||')');
         parse_params(p_params,lt_col_param_names,la_col_param_names,lt_col_param_types,lt_col_param_len,lt_col_param_values);
         -- Fetch column
         OPEN c_col(p_tab_name,p_col_name);
         FETCH c_col INTO r_col;
         l_found := c_col%FOUND;
         CLOSE c_col;
         assert(l_found, 'No column "'||p_col_name||'" found for table "'||p_tab_name||'" in data dictionary!');
         ds_utility_krn.show_message('I','Processing column "'||p_col_name||'" of table "'||p_tab_name||'"');
         -- Delete column if requested
         IF p_extract_type IN ('X','D') THEN
            IF r_col.col_name IS NOT NULL THEN
               DELETE ds_tab_columns
                WHERE table_id = r_col.table_id
                  AND col_name = r_col.col_name
               ;
               assert(SQL%ROWCOUNT=1,'Cannot delete column "'||p_col_name||'" of table "'||p_tab_name||'!');
               ds_utility_krn.show_message('I','Column "'||p_col_name||'" of table "'||p_tab_name||'" deleted');
               count_columns;
            ELSE
               ds_utility_krn.show_message('I','Column "'||p_col_name||'" of table "'||p_tab_name||'" not found in data set hence not deleted');
            END IF;
            RETURN;
         END IF;
         -- Update column properties from parameters
         l_update := FALSE;
         get_col_value_from_param('col_seq', r_col.col_seq, l_update);
         IF r_col.col_seq IS NULL THEN
            r_col.col_seq := r_col.column_id;
            ds_utility_krn.show_message('I','Column property "col_seq" set to "'||r_col.col_seq||'"');
            l_update := TRUE;
         END IF;
         get_col_value_from_param('gen_type', r_col.gen_type, l_update);
         assert(NVL(r_col.gen_type,'SQL') IN ('SQL','FK','SEQ'),'Invalid value for "gen_type" property: '||r_col.gen_type);
         get_col_value_from_param('params', r_col.params, l_update);
         get_col_value_from_param('null_value_pct', r_col.null_value_pct, l_update);
         get_col_value_from_param('null_value_condition', r_col.null_value_condition, l_update);
         IF r_col.table_id IS NULL THEN
            ds_utility_krn.show_message('I','Column "'||r_col.column_name||'" of table "'||r_col.table_name||'" added to data set');
            INSERT INTO ds_tab_columns (
               table_id, tab_name, col_name
             , col_seq, gen_type, params
             , null_value_pct, null_value_condition
            ) VALUES (
               r_col.tab_id, r_col.table_name, r_col.column_name
             , r_col.col_seq, r_col.gen_type, r_col.params
             , r_col.null_value_pct, r_col.null_value_condition
            );
         ELSE
            ds_utility_krn.show_message('I','Column properties '||CASE WHEN NOT l_update THEN 'not ' END||'updated');
            IF l_update THEN
               UPDATE ds_tab_columns
                  SET col_seq = r_col.col_seq
                    , gen_type = r_col.gen_type
                    , params = r_col.params
                    , null_value_pct = r_col.null_value_pct
                    , null_value_condition = r_col.null_value_condition
                WHERE table_id = r_col.table_id
                  AND col_name = r_col.column_name
                ;
                assert(SQL%ROWCOUNT=1,'Cannot update properties of column "'||r_col.column_name||'" for table "'||r_col.table_name||'"!');
            END IF;
         END IF;
         ds_utility_krn.show_message('D','<-process_column('||p_tab_name||','||p_col_name||','||p_extract_type||','||p_params||')');
      END;
      -- Process mask
      PROCEDURE process_mask (
         p_tab_name IN VARCHAR2
       , p_col_name IN VARCHAR2
       , p_extract_type IN VARCHAR2
       , p_params IN VARCHAR2
      )
      IS
         CURSOR c_msk (
            p_table_name IN VARCHAR2
          , p_column_name IN VARCHAR2
         )
         IS
            SELECT ds_msk.*
              FROM sys.all_tab_columns col
              LEFT OUTER JOIN ds_masks ds_msk
                ON ds_msk.table_name = col.table_name
               AND ds_msk.column_name = col.column_name
             WHERE col.owner = NVL(ds_utility_var.g_owner,USER)
               AND col.table_name = UPPER(p_table_name)
               AND col.column_name = UPPER(p_column_name)
         ;
         r_msk c_msk%ROWTYPE;
         r_msk_param ds_masks%ROWTYPE;
         l_found BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->process_mask('||p_tab_name||','||p_col_name||','||p_params||')');
         -- Fetch column and mask
         OPEN c_msk(p_tab_name,p_col_name);
         FETCH c_msk INTO r_msk;
         l_found := c_msk%FOUND;
         CLOSE c_msk;
         assert(l_found, 'No column "'||p_col_name||'" found for table "'||p_tab_name||'" in data dictionary!');
         ds_utility_krn.show_message('I','Processing mask for column "'||p_col_name||'" of table "'||p_tab_name||'"');
         -- Delete mask if requested
         IF p_extract_type IN ('X','D') THEN
            IF r_msk.msk_id IS NOT NULL THEN
               -- Delete identifiers linked to mask to remove from data set
               DELETE ds_identifiers
                WHERE msk_id = r_msk.msk_id
               ;
               l_row_count := SQL%ROWCOUNT;
               IF l_row_count > 0 THEN
                  ds_utility_krn.show_message('I',l_row_count||' identifiers deleted for column "'||p_col_name||'" of table "'||p_tab_name||'"');
               END IF;
               -- Remove mask from data set
               DELETE ds_masks
                WHERE msk_id = r_msk.msk_id
               ;
               assert(SQL%ROWCOUNT=1,'Mask for column "'||r_msk.column_name||'"not deleted!');
               ds_utility_krn.show_message('I','Mask for column "'||p_col_name||'" of table "'||p_tab_name||'" deleted');
            ELSE
               ds_utility_krn.show_message('I','Mask for column "'||p_col_name||'" of table "'||p_tab_name||'" not found hence not deleted');
            END IF;
            RETURN;
         END IF;
         -- Update mask properties from parameters
         l_update := FALSE;
         parse_params(p_params,lt_msk_param_names,la_msk_param_names,lt_msk_param_types,lt_msk_param_len,lt_msk_param_values);
         get_msk_value_from_param('sensitive_flag', r_msk.sensitive_flag, l_update);
         get_msk_value_from_param('disabled_flag', r_msk.disabled_flag, l_update);
         get_msk_value_from_param('locked_flag', r_msk.locked_flag, l_update);
         get_msk_value_from_param('deleted_flag', r_msk.deleted_flag, l_update);
         get_msk_value_from_param('dependent_flag', r_msk.dependent_flag, l_update);
         get_msk_value_from_param('msk_type', r_msk.msk_type, l_update);
         assert(NVL(r_msk.msk_type,'SQL') IN ('SQL','SHUFFLE','INHERIT','SEQUENCE','TOKENIZE'),'Invalid value for "msk_type" property: '||r_msk.msk_type);
         get_msk_value_from_param('shuffle_group', r_msk.shuffle_group, l_update);
         assert(NVL(r_msk.shuffle_group,1) >= 1,'Invalid value for "shuffle_group" property, must be >=1');
         get_msk_value_from_param('partition_bitmap', r_msk.partition_bitmap, l_update);
         assert(NVL(r_msk.partition_bitmap,1) >= 1,'Invalid value for "partition_bitmap" property, must be >=1');
         get_msk_value_from_param('params', r_msk.params, l_update);
         get_msk_value_from_param('options', r_msk.options, l_update);
         get_msk_value_from_param('pat_cat', r_msk.pat_cat, l_update);
         get_msk_value_from_param('pat_name', r_msk.pat_name, l_update);
         get_msk_value_from_param('remarks', r_msk.remarks, l_update);
         get_msk_value_from_param('values_sample', r_msk.values_sample, l_update);
         IF r_msk.msk_id IS NULL THEN
            r_msk.table_name := UPPER(p_tab_name);
            r_msk.column_name := UPPER(p_col_name);
            ds_utility_krn.show_message('I','Mask added for column "'||r_msk.column_name||'" of table "'||r_msk.table_name);
            SELECT ds_msk_seq.NEXTVAL INTO r_msk.msk_id FROM dual;
            INSERT INTO ds_masks VALUES r_msk;
         ELSE
            ds_utility_krn.show_message('I','Mask properties '||CASE WHEN NOT l_update THEN 'not ' END||'updated');
            IF l_update THEN
               UPDATE ds_masks
                  SET ROW = r_msk
                WHERE msk_id = r_msk.msk_id
               ;
               assert(SQL%ROWCOUNT=1,'Cannot update mask properties of column "'||r_msk.column_name||'" for table "'||r_msk.table_name||'"!');
            END IF;
         END IF;
         ds_utility_krn.show_message('D','<-process_mask('||p_tab_name||','||p_col_name||','||p_params||')');
      END;
      -- Get param name and length
      PROCEDURE get_param_name_and_len (
         p_param_info IN VARCHAR2
       , p_param_name OUT VARCHAR2
       , p_param_len OUT VARCHAR2
      )
      IS
         l_pos PLS_INTEGER;
      BEGIN
         l_pos := INSTR(p_param_info,')');
         IF l_pos = 0 THEN
            p_param_len := LENGTH(p_param_info);
            p_param_name := p_param_info;
         ELSE
            p_param_len := l_pos - 1;
            p_param_name := SUBSTR(p_param_info,1,l_pos-1)
                         || SUBSTR(p_param_info,l_pos+1);
         END IF;
      END;
      -- Declare a table parameter, its type and its length
      PROCEDURE add_tab_param (
         p_param_info IN VARCHAR2
       , p_param_type IN VARCHAR2
      )
      IS
         l_param_name ds_utility_var.g_small_buf_type;
         l_param_len PLS_INTEGER;
      BEGIN
         get_param_name_and_len(p_param_info,l_param_name,l_param_len);
         lt_tab_param_names(lt_tab_param_names.COUNT+1) := l_param_name;
         la_tab_param_names(l_param_name) := lt_tab_param_names.COUNT;
         lt_tab_param_types(lt_tab_param_types.COUNT+1) := p_param_type;
         lt_tab_param_len(lt_tab_param_len.COUNT+1) := l_param_len;
      END;
      -- Declare a constraint parameter, its type and its length
      PROCEDURE add_con_param (
         p_param_info IN VARCHAR2
       , p_param_type IN VARCHAR2
      )
      IS
         l_param_name ds_utility_var.g_small_buf_type;
         l_param_len PLS_INTEGER;
      BEGIN
         get_param_name_and_len(p_param_info,l_param_name,l_param_len);
         lt_con_param_names(lt_con_param_names.COUNT+1) := l_param_name;
         la_con_param_names(l_param_name) := lt_con_param_names.COUNT;
         lt_con_param_types(lt_con_param_types.COUNT+1) := p_param_type;
         lt_con_param_len(lt_con_param_len.COUNT+1) := l_param_len;
      END;
      -- Declare a column parameter, its type and its length
      PROCEDURE add_col_param (
         p_param_info IN VARCHAR2
       , p_param_type IN VARCHAR2
      )
      IS
         l_param_name ds_utility_var.g_small_buf_type;
         l_param_len PLS_INTEGER;
      BEGIN
         get_param_name_and_len(p_param_info,l_param_name,l_param_len);
         lt_col_param_names(lt_col_param_names.COUNT+1) := l_param_name;
         la_col_param_names(l_param_name) := lt_col_param_names.COUNT;
         lt_col_param_types(lt_col_param_types.COUNT+1) := p_param_type;
         lt_col_param_len(lt_col_param_len.COUNT+1) := l_param_len;
      END;
      -- Declare a mask parameter, its type and its length
      PROCEDURE add_msk_param (
         p_param_info IN VARCHAR2
       , p_param_type IN VARCHAR2
      )
      IS
         l_param_name ds_utility_var.g_small_buf_type;
         l_param_len PLS_INTEGER;
      BEGIN
         get_param_name_and_len(p_param_info,l_param_name,l_param_len);
         lt_msk_param_names(lt_msk_param_names.COUNT+1) := l_param_name;
         la_msk_param_names(l_param_name) := lt_msk_param_names.COUNT;
         lt_msk_param_types(lt_msk_param_types.COUNT+1) := p_param_type;
         lt_msk_param_len(lt_msk_param_len.COUNT+1) := l_param_len;
      END;
      -- Initialise
      PROCEDURE initially IS
      BEGIN
         -- Declare table parameters
         add_tab_param('b)atch_size', 'OXN999999999');
         add_tab_param('c)olumns_list', 'OLC4000');
         add_tab_param('exp)ort_mode', 'OUC3');
         add_tab_param('ext)ract_type', 'MUC1');
         add_tab_param('g)en_view_name', 'OUC30');
         add_tab_param('o)rder_by_clause', 'OXC4000');
         add_tab_param('pe)rcentage', 'OXN999.9');
         add_tab_param('pr)e_gen_code', 'OXC4000');
         add_tab_param('po)st_gen_code', 'OXC4000');
         add_tab_param('row_l)imit', 'OXN999999999');
         add_tab_param('row_c)ount', 'OXN999999999');
         add_tab_param('source_d)b_link', 'OUC30');
         add_tab_param('source_s)chema', 'OUC30');
         add_tab_param('tabl)e_alias', 'MLC30');
         add_tab_param('tab_)seq', 'OXN999');
         add_tab_param('target_d)b_link', 'OUC30');
         add_tab_param('target_s)chema', 'OUC30');
         add_tab_param('target_t)able_name', 'OUC30');
         add_tab_param('u)ser_column_name', 'OUC30');
         add_tab_param('w)here_clause', 'OXC4000');
         -- Declare constraint parameters
            add_con_param('b)atch_size','OXN999999999');
         add_con_param('ca)rdinality','MUC3');
         add_con_param('cons)traint_name','MUC30');
         add_con_param('con_)seq','OXN999999999');
         add_con_param('d)eferred','OUC9');
         add_con_param('e)xtract_type','MUC1');
         add_con_param('f)k','MUC30'); -- synonym for 'constraint_name'
         add_con_param('g)en_view_name','OUC30');
         add_con_param('l)evel_count','OXN999999999');
         add_con_param('mi)n_rows','OXN999999999');
         add_con_param('ma)x_rows','OXN999999999');
         add_con_param('o)rder_by_clause','OXC4000');
         add_con_param('pe)rcentage','OXN999.9');
         add_con_param('po)st_gen_code','OXC4000');
         add_con_param('pr)e_gen_code','OXC4000');
         add_con_param('r)ow_limit','OXN999999999');
         add_con_param('s)rc_filter','OXC4000');
         add_con_param('w)here_clause', 'OXC4000');
         -- Declare column parameters
         add_col_param('c)ol_seq','OXN999999999');
         add_col_param('e)xtract_type','OUC1');
         add_col_param('g)en_type','OUC3');
         add_col_param('null_value_p)ct','OXN999');
         add_col_param('null_value_c)ondition','OXC4000');
         add_col_param('p)arams','OXC4000');
         -- Declare mask parameters
         add_msk_param('del)eted_flag','OUF1');
         add_msk_param('dep)endent_flag','OUF1');
         add_msk_param('di)sabled_flag','OUF1');
         add_msk_param('e)xtract_type','OUC1');
         add_msk_param('l)ocked_flag','OUF1');
         add_msk_param('m)sk_type','OUC30');
         add_msk_param('o)ptions','OXC200');
         add_msk_param('para)ms','OXC4000');
         add_msk_param('part)ition_bitmap','OXN99');
         add_msk_param('pat_c)at','OXC100');
         add_msk_param('pat_n)ame','OXC100');
         add_msk_param('r)emarks','OXC1000');
         add_msk_param('se)nsitive_flag','OUF1');
         add_msk_param('sh)uffle_group','OXN99');
         add_msk_param('v)alues_sample','OXC1000');
      END;
      -- Manage columns
      PROCEDURE manage_columns (
         pr_tab IN OUT lr_table_record_type
       , pr_col IN lr_column_record_type
      )
      IS
         CURSOR c_col (
            p_tab_name IN VARCHAR2
          , p_col_name IN VARCHAR2
          , p_tab_in_data_set IN VARCHAR2
          , p_col_in_data_set IN VARCHAR2
         )
         IS
            SELECT col.table_name, col.column_name
              FROM sys.all_tab_columns col
             INNER JOIN sys.all_tables tab
                ON tab.owner = col.owner
               AND tab.table_name = col.table_name
              LEFT OUTER JOIN ds_tables ds_tab
                ON ds_tab.set_id = p_set_id
               AND ds_tab.table_name = col.table_name
              LEFT OUTER JOIN ds_tab_columns ds_col
                ON ds_col.table_id = ds_tab.table_id
               AND ds_col.col_name = col.column_name
             WHERE col.owner = NVL(ds_utility_var.g_owner,USER)
               AND col.table_name LIKE TRANSLATE(p_tab_name,'*?','%_')
               AND col.column_name LIKE TRANSLATE(p_col_name,'*?','%_')
               AND (NVL(p_tab_in_data_set,'X') != 'Y' OR ds_tab.table_id IS NOT NULL)
               AND (NVL(p_tab_in_data_set,'X') != 'N' OR ds_tab.table_id IS NULL)
               AND (NVL(p_col_in_data_set,'X') != 'Y' OR ds_col.col_name IS NOT NULL)
               AND (NVL(p_col_in_data_set,'X') != 'N' OR ds_col.col_name IS NULL)
             ORDER BY col.table_name, col.column_name
         ;
         lr_tab lr_table_record_type;
         lr_col lr_column_record_type;
         l_tab_wc BOOLEAN;
         l_col_wc BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->manage_columns('||pr_tab.table_name||','||pr_tab.table_alias||','||pr_col.column_name||')');
         l_tab_wc := contains_wildcard(pr_tab.table_name);
         l_col_wc := contains_wildcard(pr_col.column_name);
         IF l_tab_wc OR l_col_wc THEN
            assert(NOT l_tab_wc OR pr_tab.table_alias IS NULL, 'Table alias not allowed when wildcards are used in table name!');
            FOR i IN 1..2 LOOP
               lr_tab := NULL;
               lr_col := NULL;
               FOR r_col IN c_col(pr_tab.table_name,UPPER(pr_col.column_name),pr_tab.in_data_set,pr_col.in_data_set) LOOP
                  -- Process table first (as columns might be added)
                  IF i = 1 THEN
                     IF lr_tab.table_name IS NULL OR lr_tab.table_name != r_col.table_name THEN
                        ds_utility_krn.show_message('D','*** table '||r_col.table_name||' ***');
                        lr_tab := pr_tab;
                        lr_tab.table_name := r_col.table_name;
                        process_table(lr_tab.table_name, lr_tab.table_alias, lr_tab.extract_type, lr_tab.params, pr_col.extract_type);
                     END IF;
                  -- Process columns second
                  ELSIF i = 2 THEN
                     ds_utility_krn.show_message('D','*** column '||r_col.table_name||'.'||r_col.column_name||' ***');
                     lr_col := pr_col;
                     lr_col.column_name := r_col.column_name;
                     process_column(r_col.table_name, lr_col.column_name, lr_col.extract_type, lr_col.params);
                  END IF;
               END LOOP;
            END LOOP;
         ELSE
            lr_tab := pr_tab;
            process_table(lr_tab.table_name, lr_tab.table_alias, lr_tab.extract_type, lr_tab.params, pr_col.extract_type);
            lr_col := pr_col;
            process_column(lr_tab.table_name, lr_col.column_name, lr_col.extract_type, lr_col.params);
         END IF;
         pr_tab.is_processed := 'Y';
         ds_utility_krn.show_message('D','<-manage_columns('||pr_tab.table_name||','||pr_tab.table_alias||','||pr_col.column_name||')');
      END;
      -- Manage masks
      PROCEDURE manage_masks (
         pr_tab IN OUT lr_table_record_type
       , pr_col IN lr_column_record_type
      )
      IS
         CURSOR c_col (
            p_tab_name IN VARCHAR2
          , p_col_name IN VARCHAR2
          , p_tab_in_data_set IN VARCHAR2
          , p_col_in_data_set IN VARCHAR2
         )
         IS
            SELECT col.table_name, col.column_name
              FROM sys.all_tab_columns col
             INNER JOIN sys.all_tables tab
                ON tab.owner = col.owner
               AND tab.table_name = col.table_name
              LEFT OUTER JOIN ds_tables ds_tab
                ON ds_tab.set_id = p_set_id
               AND ds_tab.table_name = col.table_name
              LEFT OUTER JOIN ds_masks ds_msk
                ON ds_msk.table_name = tab.table_name
               AND ds_msk.column_name = col.column_name
             WHERE col.owner = NVL(ds_utility_var.g_owner,USER)
               AND col.table_name LIKE TRANSLATE(p_tab_name,'*?','%_')
               AND col.column_name LIKE TRANSLATE(p_col_name,'*?','%_')
               AND (NVL(p_tab_in_data_set,'X') != 'Y' OR ds_tab.table_id IS NOT NULL)
               AND (NVL(p_tab_in_data_set,'X') != 'N' OR ds_tab.table_id IS NULL)
               AND (NVL(p_col_in_data_set,'X') != 'Y' OR ds_msk.column_name IS NOT NULL)
               AND (NVL(p_col_in_data_set,'X') != 'N' OR ds_msk.column_name IS NULL)
             ORDER BY col.table_name, col.column_name
         ;
         lr_tab lr_table_record_type;
         lr_col lr_column_record_type;
         l_tab_wc BOOLEAN;
         l_col_wc BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->manage_masks('||pr_tab.table_name||','||pr_tab.table_alias||','||pr_col.column_name||')');
         l_tab_wc := contains_wildcard(pr_tab.table_name);
         l_col_wc := contains_wildcard(pr_col.column_name);
         IF l_tab_wc OR l_col_wc THEN
            assert(NOT l_tab_wc OR pr_tab.table_alias IS NULL, 'Table alias not allowed when wildcards are used in table name!');
            FOR i IN 1..2 LOOP
               lr_tab := NULL;
               lr_col := NULL;
               FOR r_col IN c_col(pr_tab.table_name,UPPER(pr_col.column_name),pr_tab.in_data_set,pr_col.in_data_set) LOOP
                  -- Process table first (as columns might be added)
                  IF i = 1 THEN
                     IF lr_tab.table_name IS NULL OR lr_tab.table_name != r_col.table_name THEN
                        ds_utility_krn.show_message('D','*** table '||r_col.table_name||' ***');
                        lr_tab := pr_tab;
                        lr_tab.table_name := r_col.table_name;
                        process_table(lr_tab.table_name, lr_tab.table_alias, lr_tab.extract_type, lr_tab.params, pr_col.extract_type);
                     END IF;
                  -- Process columns second
                  ELSIF i = 2 THEN
                     ds_utility_krn.show_message('D','*** column '||r_col.table_name||'.'||r_col.column_name||' ***');
                     lr_col := pr_col;
                     lr_col.column_name := r_col.column_name;
                     process_mask(r_col.table_name, lr_col.column_name, lr_col.extract_type, lr_col.params);
                  END IF;
               END LOOP;
            END LOOP;
         ELSE
            lr_tab := pr_tab;
            process_table(lr_tab.table_name, lr_tab.table_alias, lr_tab.extract_type, lr_tab.params, pr_col.extract_type);
            lr_col := pr_col;
            process_mask(lr_tab.table_name, lr_col.column_name, lr_col.extract_type, lr_col.params);
         END IF;
         pr_tab.is_processed := 'Y';
         ds_utility_krn.show_message('D','<-manage_masks('||pr_tab.table_name||','||pr_tab.table_alias||','||pr_col.column_name||')');
      END;
      -- Parse table definition
      PROCEDURE parse_table (
         pr_tab IN OUT lr_table_record_type
       , p_label IN VARCHAR2
      )
      IS
         l_buf ds_utility_var.g_small_buf_type;
         l_no_wc BOOLEAN; -- table name contains wildcards?
         l_ch VARCHAR2(1 CHAR);
         l_scope BOOLEAN;
         lr_tab lr_column_record_type;
      BEGIN
         ds_utility_krn.show_message('D','->parse_table('||pr_tab.table_name||','||pr_tab.table_alias||','||p_label||')');
         -- Process table name
         pr_tab := NULL;
         l_ch := SUBSTR(l_line,1,1);
         IF l_ch IN ('∃','⊆','!','∄','⊈','^') THEN
            pr_tab.in_data_set := TRANSLATE(l_ch,'∃⊆!∄⊈^','YYYNNN');
            consume_keyword(l_line,l_ch);
         END IF;
         l_ch := SUBSTR(l_line,1,1);
         assert(is_letter(l_ch) or is_wildcard(l_ch),'Syntax error: '||p_label||' table name or alias expected, got '||SUBSTR(l_line,1,40)||'...');
         l_buf := UPPER(consume_identifier(l_line,TRUE));
         pr_tab.table_name := l_buf;
         l_no_wc := NOT contains_wildcard(pr_tab.table_name);
         assert(pr_tab.in_data_set IS NULL OR NOT l_no_wc,'"!" or "^" not allowed without wildcards');
         -- Process table alias
         pr_tab.table_alias := NULL;
         IF is_letter(SUBSTR(l_line,1,1)) THEN
            assert(l_no_wc,'Table alias not allowed with wildcards');
            l_buf := LOWER(consume_identifier(l_line));
            pr_tab.table_alias := l_buf;
         END IF;
         -- Process extract type and table properties
         pr_tab.extract_type := NULL;
         pr_tab.params := NULL;
         LOOP
            l_ch := SUBSTR(l_line,1,1);
            IF l_ch = '/' THEN
               consume_keyword(l_line,l_ch,FALSE);
               assert(is_letter(SUBSTR(l_line,1,1)),'Syntax error: "/" must be followed by a letter');
               l_buf := UPPER(consume_identifier(l_line));
               assert(l_buf IN ('B','F','P','N','R','X','D'),p_label||' extract type must be B, F, P, N, R, X or D, found: '||l_buf);
               assert(l_buf != 'R' OR r_set.set_type = 'GEN','"R" extract type is valid only for data set of type GEN');
               pr_tab.extract_type := SUBSTR(l_buf,1,1);
            ELSIF SUBSTR(l_line,1,1) = '[' THEN
               pr_tab.params := pr_tab.params ||CASE WHEN pr_tab.params IS NOT NULL THEN ',' END || consume_delimited_content(l_line,'[',']');
            ELSE
               EXIT;
            END IF;
         END LOOP;
         IF pr_tab.extract_type IS NOT NULL THEN
            pr_tab.params := pr_tab.params || ' extract_type=' || pr_tab.extract_type;
         END IF;
         -- Manage default values
         IF pr_tab.table_name IN ('TABLE','CONSTRAINT','COLUMN','MASK') THEN
            IF pr_tab.table_alias IS NOT NULL THEN
               ds_utility_krn.show_message('W','Table alias "'||pr_tab.table_alias||'" ignored for default '||pr_tab.table_name||' parameters!');
            END IF;
            IF pr_tab.in_data_set IS NOT NULL THEN
               ds_utility_krn.show_message('W','Scope ignored for default '||pr_tab.table_name||' parameters!');
            END IF;
            IF pr_tab.table_name = 'TABLE' THEN
               parse_params(pr_tab.params,lt_tab_param_names,la_tab_param_names,lt_tab_param_types,lt_tab_param_len,lt_tab_def_param_values,FALSE);
               IF pr_tab.extract_type IS NOT NULL THEN
                  IF pr_tab.extract_type IN ('D','X') THEN
                     lt_tab_def_param_values.DELETE;
                  ELSE
                     lt_tab_def_param_values(la_tab_param_names('extract_type')) := pr_tab.extract_type;
                  END IF;
               END IF;
            ELSIF pr_tab.table_name = 'CONSTRAINT' THEN
               parse_params(pr_tab.params,lt_con_param_names,la_con_param_names,lt_con_param_types,lt_con_param_len,lt_con_def_param_values,FALSE);
               IF pr_tab.extract_type IS NOT NULL THEN
                  IF pr_tab.extract_type IN ('D','X') THEN
                     lt_con_def_param_values.DELETE;
                  ELSE
                     lt_con_def_param_values(la_con_param_names('extract_type')) := pr_tab.extract_type;
                  END IF;
               END IF;
            ELSIF r_set.set_type = 'SUB' AND pr_tab.table_name IN ('COLUMN','MASK') THEN
               parse_params(pr_tab.params,lt_msk_param_names,la_msk_param_names,lt_msk_param_types,lt_msk_param_len,lt_msk_def_param_values,FALSE);
               IF pr_tab.extract_type IS NOT NULL THEN
                  IF pr_tab.extract_type IN ('D','X') THEN
                     lt_msk_def_param_values.DELETE;
                  ELSE
                     lt_msk_def_param_values(la_msk_param_names('extract_type')) := pr_tab.extract_type;
                  END IF;
               END IF;
            ELSIF r_set.set_type = 'GEN' AND pr_tab.table_name IN ('COLUMN') THEN
               parse_params(pr_tab.params,lt_col_param_names,la_col_param_names,lt_col_param_types,lt_col_param_len,lt_col_def_param_values,FALSE);
               IF pr_tab.extract_type IS NOT NULL THEN
                  IF pr_tab.extract_type IN ('D','X') THEN
                     lt_col_def_param_values.DELETE;
                  ELSE
                     lt_col_def_param_values(la_col_param_names('extract_type')) := pr_tab.extract_type;
                  END IF;
               END IF;
            ELSE
               assert(FALSE,'Mask default values is not applicable to "GEN" data sets');
            END IF;
            RETURN;
         END IF;
         IF l_no_wc THEN
            process_table(pr_tab.table_name, pr_tab.table_alias, pr_tab.extract_type, pr_tab.params);
            pr_tab.is_processed := 'Y';
         END IF;
         -- Process column or mask properties
         WHILE SUBSTR(l_line,1,1) = '.' LOOP
            consume_keyword(l_line,'.',FALSE);
            lr_col := NULL;
            l_ch := SUBSTR(l_line,1,1);
            IF l_ch IN ('∃','⊆','!','∄','⊈','^') THEN
               lr_col.in_data_set := TRANSLATE(l_ch,'∃⊆!∄⊈^','YYYNNN');
               consume_keyword(l_line,l_ch);
            END IF;
            l_ch := SUBSTR(l_line,1,1);
            assert(is_letter(l_ch) OR is_wildcard(l_ch),'Syntax error: '||p_label||' column name expected');
            l_buf := LOWER(consume_identifier(l_line,TRUE));
            lr_col.column_name := l_buf;
            LOOP
               l_ch := SUBSTR(l_line,1,1);
               IF l_ch = '/' THEN
                  consume_keyword(l_line,l_ch,FALSE);
                  assert(is_letter(SUBSTR(l_line,1,1)),'Syntax error: "/" must be followed by a letter');
                  l_buf := UPPER(consume_identifier(l_line));
                  assert(l_buf IN ('X','D'),'Column extract type can only be X or D, found: "'||l_buf||'"!');
                  lr_col.extract_type := SUBSTR(l_buf,1,1);
               ELSIF l_ch = '[' THEN
                  lr_col.params := lr_col.params || CASE WHEN lr_col.params IS NOT NULL THEN ',' END || consume_delimited_content(l_line,'[',']');
               ELSE
                  EXIT;
               END IF;
            END LOOP;
            IF lr_col.extract_type IS NOT NULL THEN
               lr_col.params := lr_col.params || ' extract_type=' || lr_col.extract_type;
            END IF;
            IF r_set.set_type = 'GEN' THEN
               manage_columns(pr_tab,lr_col);
            ELSIF r_set.set_type = 'SUB' THEN
               manage_masks(pr_tab,lr_col);
            ELSE
               assert(FALSE,'Columns not supported for data set of type "'||r_set.set_type||'"!');
            END IF;
         END LOOP;
         ds_utility_krn.show_message('D','<-parse_table('||pr_tab.table_name||','||p_label||')');
      END;
      -- Manage constraints
      PROCEDURE manage_constraints (
         pr_src_tab IN lr_table_record_type
       , pr_tgt_tab IN lr_table_record_type
       , pr_con IN lr_constraint_record_type
       , p_first_call IN BOOLEAN := TRUE
      )
      IS
         l_constraint_name ds_constraints.constraint_name%TYPE;
         l_cardinality VARCHAR2(3 CHAR);
         l_arrow VARCHAR2(3 CHAR);
         lr_src_tab lr_table_record_type;
         lr_tgt_tab lr_table_record_type;
         lr_con lr_constraint_record_type;
         CURSOR c_con (
            p_src_table_name IN VARCHAR2
          , p_tgt_table_name IN VARCHAR2
          , p_constraint_name IN VARCHAR2
          , p_cardinality IN VARCHAR2
          , p_src_in_data_set IN VARCHAR2
          , p_tgt_in_data_set IN VARCHAR2
          , p_con_in_data_set IN VARCHAR2
         )
         IS
            SELECT ds_con.con_id, con.constraint_name
                 , CASE WHEN p_cardinality = 'N-1' THEN con.table_name ELSE rcon.table_name END table_name
                 , CASE WHEN p_cardinality = 'N-1' THEN ds_tab.table_id ELSE ds_rtab.table_id END table_id
                 , CASE WHEN p_cardinality = 'N-1' THEN rcon.table_name ELSE con.table_name END r_table_name
                 , CASE WHEN p_cardinality = 'N-1' THEN ds_rtab.table_id ELSE ds_tab.table_id END r_table_id
              FROM sys.all_constraints con
             INNER JOIN sys.all_constraints rcon
                ON rcon.owner = con.owner
               AND rcon.constraint_name = con.r_constraint_name
               AND rcon.table_name LIKE TRANSLATE(UPPER(CASE p_cardinality WHEN 'N-1' THEN p_tgt_table_name ELSE p_src_table_name END),'*?','%_')
              LEFT OUTER JOIN ds_constraints ds_con
                ON ds_con.set_id = p_set_id
               AND ds_con.constraint_name = con.constraint_name
               AND ds_con.cardinality = p_cardinality
               AND ds_con.src_table_name = CASE WHEN p_cardinality = 'N-1' THEN con.table_name ELSE rcon.table_name END
               AND ds_con.dst_table_name = CASE WHEN p_cardinality = 'N-1' THEN rcon.table_name ELSE con.table_name END
              LEFT OUTER JOIN ds_tables ds_tab
                ON ds_tab.set_id = p_set_id
               AND ds_tab.table_name = con.table_name
              LEFT OUTER JOIN ds_tables ds_rtab
                ON ds_rtab.set_id = p_set_id
               AND ds_rtab.table_name = rcon.table_name
             WHERE con.owner = NVL(ds_utility_var.g_owner,USER)
               AND con.constraint_type = 'R'
               AND (p_constraint_name IS NULL OR con.constraint_name LIKE TRANSLATE(UPPER(p_constraint_name),'*?','%_'))
               AND con.table_name LIKE TRANSLATE(UPPER(CASE p_cardinality WHEN 'N-1' THEN p_src_table_name ELSE p_tgt_table_name END),'*?','%_')
               AND (NVL(p_src_in_data_set,'X') != 'Y' OR CASE WHEN p_cardinality = 'N-1' THEN ds_tab.table_id ELSE ds_rtab.table_id END IS NOT NULL)
               AND (NVL(p_src_in_data_set,'X') != 'N' OR CASE WHEN p_cardinality = 'N-1' THEN ds_tab.table_id ELSE ds_rtab.table_id END IS NULL)
               AND (NVL(p_tgt_in_data_set,'X') != 'Y' OR CASE WHEN p_cardinality = 'N-1' THEN ds_rtab.table_id ELSE ds_tab.table_id END IS NOT NULL)
               AND (NVL(p_tgt_in_data_set,'X') != 'N' OR CASE WHEN p_cardinality = 'N-1' THEN ds_rtab.table_id ELSE ds_tab.table_id END IS NULL)
               AND (NVL(p_con_in_data_set,'X') != 'Y' OR ds_con.con_id IS NOT NULL)
               AND (NVL(p_con_in_data_set,'X') != 'N' OR ds_con.con_id IS NULL)
             ORDER BY CASE WHEN con.table_name = rcon.table_name THEN 2 ELSE 1 END /*ear's pig in last*/, con.constraint_name
         ;
         lt_src_tab lt_table_record_type;
         lt_tgt_tab lt_table_record_type;
         lt_con lt_constraint_record_type;
         l_exists BOOLEAN;
      BEGIN
         ds_utility_krn.show_message('D','->manage_constraints('||pr_src_tab.table_name||','||pr_src_tab.table_alias||','||pr_tgt_tab.table_name||','||pr_tgt_tab.table_alias||')');
         IF p_first_call THEN
            la_tab_names.DELETE;
         END IF;
         parse_params(pr_con.params,lt_con_param_names,la_con_param_names,lt_con_param_types,lt_con_param_len,lt_con_param_values);
         l_exists := get_con_param_value('fk', l_constraint_name);
         assert(pr_con.in_data_set IS NULL OR l_constraint_name IS NULL OR contains_wildcard(l_constraint_name),'"!" or "^" not allowed without wildcards');
         IF contains_wildcard(pr_src_tab.table_name) OR contains_wildcard(pr_tgt_tab.table_name) OR contains_wildcard(l_constraint_name) THEN
            FOR i IN 1..2 LOOP
               l_cardinality := CASE i WHEN 1 THEN 'N-1' ELSE '1-N' END;
               l_arrow := CASE i WHEN 1 THEN '>' END
                       || CASE pr_con.extract_type WHEN 'B' THEN '=' WHEN 'P' THEN '-' WHEN 'N' THEN '+' WHEN 'X' THEN '#' WHEN 'D' THEN '#' ELSE '~' END
                       || CASE i WHEN 2 THEN '<' END;
               IF pr_con.cardinality IS NULL OR pr_con.cardinality = l_cardinality THEN
                  FOR r_con IN c_con(pr_src_tab.table_name, pr_tgt_tab.table_name, NVL(l_constraint_name,'*'),l_cardinality,pr_src_tab.in_data_set,pr_tgt_tab.in_data_set,pr_con.in_data_set) LOOP
                     ds_utility_krn.show_message('D','*** fk '||r_con.constraint_name||' from '||r_con.table_name||' to '||r_con.r_table_name||' cardinality '||l_cardinality||' arrow '||l_arrow||' level '||pr_con.recursive_level||' ***');
                     lr_src_tab := pr_src_tab;
                     IF contains_wildcard(pr_src_tab.table_name) THEN
                        process_table(r_con.table_name, lr_src_tab.table_alias, lr_src_tab.extract_type, lr_src_tab.params);
                     END IF;
                     la_tab_names(r_con.table_name) := r_con.table_name;
                     lr_tgt_tab := pr_tgt_tab;
                     IF contains_wildcard(pr_tgt_tab.table_name) THEN
                        process_table(r_con.r_table_name, lr_tgt_tab.table_alias, lr_tgt_tab.extract_type, lr_tgt_tab.params);
                     END IF;
                     process_constraint(r_con.table_name, r_con.r_table_name, l_cardinality, pr_con.extract_type, l_arrow, pr_con.params,r_con.constraint_name);
                     IF pr_con.recursive_level != 0 AND pr_con.recursive_level >= -9 /*to avoid inifite loop*/ AND contains_wildcard(pr_tgt_tab.table_name) THEN
                        lr_src_tab := pr_tgt_tab;
                        lr_src_tab.table_name := r_con.r_table_name;
                        lr_tgt_tab := pr_tgt_tab;
                        lr_con := pr_con;
                        lr_con.constraint_name := NULL;
                        lr_con.recursive_level := lr_con.recursive_level - 1;
                        lt_src_tab(lt_src_tab.COUNT+1) := lr_src_tab;
                        lt_tgt_tab(lt_tgt_tab.COUNT+1) := lr_tgt_tab;
                        lt_con(lt_con.COUNT+1) := lr_con;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         ELSE
            lr_src_tab := pr_src_tab;
            IF NOT p_first_call THEN
               process_table(lr_src_tab.table_name, lr_src_tab.table_alias, lr_src_tab.extract_type, lr_src_tab.params);
            END IF;
            lr_tgt_tab := pr_tgt_tab;
            IF NOT p_first_call THEN
               process_table(lr_tgt_tab.table_name, lr_tgt_tab.table_alias, lr_tgt_tab.extract_type, lr_tgt_tab.params);
            END IF;
            process_constraint(lr_src_tab.table_name, lr_tgt_tab.table_name, pr_con.cardinality, pr_con.extract_type, pr_con.arrow, pr_con.params);
         END IF;
         -- Recursion
         FOR i IN 1..lt_con.COUNT LOOP
            lr_src_tab := lt_src_tab(i);
            IF NOT la_tab_names.EXISTS(lr_src_tab.table_name) THEN
               lr_tgt_tab := lt_tgt_tab(i);
               lr_con := lt_con(i);
               manage_constraints(lr_src_tab,lr_tgt_tab,lr_con,FALSE);
            END IF;
         END LOOP;
         ds_utility_krn.show_message('D','<-manage_constraints('||pr_src_tab.table_name||','||pr_src_tab.table_alias||','||pr_tgt_tab.table_name||','||pr_tgt_tab.table_alias||')');
      END;
      -- Manage tables
      PROCEDURE manage_tables (
         pr_tab IN lr_table_record_type
      )
      IS
         CURSOR c_tab (
            p_table_name IN VARCHAR2
          , p_in_data_set IN VARCHAR2
         )
         IS
            SELECT ds_tab.table_id, tab.table_name
              FROM sys.all_tables tab
              LEFT OUTER JOIN ds_tables ds_tab
                ON ds_tab.set_id = p_set_id
               AND ds_tab.table_name = tab.table_name
             WHERE tab.owner = NVL(ds_utility_var.g_owner,USER)
               AND tab.table_name LIKE TRANSLATE(p_table_name,'*?','%_')
               AND (NVL(p_in_data_set,'X') != 'Y' OR ds_tab.table_id IS NOT NULL)
               AND (NVL(p_in_data_set,'X') != 'N' OR ds_tab.table_id IS NULL)
             ORDER BY tab.table_name
         ;
         lr_tab lr_table_record_type;
      BEGIN
         ds_utility_krn.show_message('D','->manage_tables('||pr_tab.table_name||','||pr_tab.table_alias||')');
         IF contains_wildcard(pr_tab.table_name) THEN
            FOR r_tab IN c_tab(pr_tab.table_name,pr_tab.in_data_set) LOOP
               ds_utility_krn.show_message('D','*** table '||r_tab.table_name||' ***');
               lr_tab := pr_tab;
               process_table(r_tab.table_name, lr_tab.table_alias, lr_tab.extract_type, lr_tab.params);
            END LOOP;
         ELSE
            NULL; -- already done in parse_table() when no wildcard used
         END IF;
         ds_utility_krn.show_message('D','<-manage_tables('||pr_tab.table_name||','||pr_tab.table_alias||')');
      END;
   BEGIN
      initially;
      -- Get data set
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      CLOSE c_set;
      assert(r_set.set_id IS NOT NULL,'Invalid data set id: '||p_set_id);
      -- Copy path
      l_line := TRIM(p_path);
      remove_comments(l_line);
      -- Parse query
      consume_leading_spaces(l_line);
      WHILE l_stat_count=0 OR SUBSTR(l_line,1,1) = ';' LOOP
         l_stat_count := l_stat_count + 1;
         -- Process statement separator(s)
         WHILE SUBSTR(l_line,1,1) = ';' LOOP
            consume_keyword(l_line,';');
         END LOOP;
         EXIT WHEN l_line IS NULL;
         -- Process source tables
         lt_src_tab.DELETE;
         LOOP
            parse_table(lr_tab,'Source');
            lt_src_tab(lt_src_tab.COUNT+1) := lr_tab;
            EXIT WHEN NVL(SUBSTR(l_line,1,1),'X') != ',';
            consume_keyword(l_line,',');
         END LOOP;
         -- Process arrow(s)
         l_arrow_count := 0;
         LOOP
            lr_con := NULL;
            l_ch := SUBSTR(l_line,1,1);
            IF l_ch IN ('∃','⊆','!','∄','⊈','^') THEN
               lr_con.in_data_set := TRANSLATE(l_ch,'∃⊆!∄⊈^','YYYNNN');
               consume_keyword(l_line,l_ch);
            END IF;
            IF SUBSTR(l_line,1,3) IN ('<->','<=>','<≠>','<+>','<#>','<~>') THEN
               lr_con.arrow := SUBSTR(l_line,1,3);
            ELSIF (SUBSTR(l_line,1,1) IN ('<','>') AND SUBSTR(l_line,2,1) IN ('-','=','≠','+','#','~'))
               OR (SUBSTR(l_line,2,1) IN ('<','>') AND SUBSTR(l_line,1,1) IN ('-','=','≠','+','#','~'))
            THEN
               lr_con.arrow := SUBSTR(l_line,1,2);
            END IF;
            EXIT WHEN lr_con.arrow IS NULL;
            l_arrow_count := l_arrow_count + 1;
            IF LENGTH(lr_con.arrow) = 2 THEN
               lr_con.cardinality := CASE WHEN SUBSTR(lr_con.arrow,1,1) = '>' THEN 'N-1'
                                     WHEN SUBSTR(lr_con.arrow,2,1) = '<' THEN '1-N'
                                     ELSE NULL
                                END;
               lr_con.extract_type := CASE WHEN INSTR(lr_con.arrow,'-')>0 THEN 'P'
                                      WHEN INSTR(lr_con.arrow,'=')>0 THEN 'B'
                                      WHEN INSTR(lr_con.arrow,'+')>0 THEN 'N'
                                      WHEN INSTR(lr_con.arrow,'≠')>0 THEN 'N'
                                      WHEN INSTR(lr_con.arrow,'#')>0 THEN 'X'
                                      WHEN INSTR(lr_con.arrow,'~')>0 THEN ''
                                 END;
            ELSIF LENGTH(lr_con.arrow) = 3 THEN
               lr_con.extract_type := CASE SUBSTR(lr_con.arrow,2,1) WHEN '-' THEN 'P'
                                                          WHEN '=' THEN 'B'
                                                          WHEN '+' THEN 'N'
                                                          WHEN '≠' THEN 'N'
                                                          WHEN '#' THEN 'X'
                                                          WHEN '~' THEN ''
                                  END;
            END IF;
            consume_keyword(l_line,lr_con.arrow);
            LOOP
               l_ch := SUBSTR(l_line,1,1);
               IF is_digit(l_ch) THEN
                  lr_con.recursive_level := consume_integer(l_line);
                  IF lr_con.recursive_level <= 0 THEN
                     lr_con.recursive_level := -1; -- no recursion limit
                  END IF;
               ELSIF l_ch = '[' THEN
                  lr_con.params := lr_con.params || CASE WHEN lr_con.params IS NOT NULL THEN ',' END || consume_delimited_content(l_line,'[',']');
               ELSE
                  EXIT;
               END IF;
            END LOOP;
            IF lr_con.extract_type IS NOT NULL THEN
               lr_con.params := lr_con.params || ' extract_type=' ||lr_con.extract_type;
            END IF;
            -- Process target tables
            lt_tgt_tab.DELETE;
            LOOP
               parse_table(lr_tab,'Target');
               lt_tgt_tab(lt_tgt_tab.COUNT+1) := lr_tab;
               EXIT WHEN NVL(SUBSTR(l_line,1,1),'X') != ',';
               consume_keyword(l_line,',');
            END LOOP;
            assert(lt_tgt_tab.COUNT>0,'target table(s) expected after arrow');
            FOR l_src_idx IN 1..lt_src_tab.COUNT LOOP
               lr_src_tab := lt_src_tab(l_src_idx);
               FOR l_tgt_idx IN 1..lt_tgt_tab.COUNT LOOP
                  lr_tgt_tab := lt_tgt_tab(l_tgt_idx);
                  IF LENGTH(lr_con.arrow)=3 THEN
                     -- Process constraint in both directions
                     lr_con.cardinality := CASE WHEN lr_src_tab.table_name = lr_tgt_tab.table_name THEN 'N-1' ELSE NULL END;
                     manage_constraints(lr_tgt_tab, lr_src_tab, lr_con);
                     lr_con.cardinality := CASE WHEN lr_src_tab.table_name = lr_tgt_tab.table_name THEN '1-N' ELSE NULL END;
                     manage_constraints(lr_src_tab, lr_tgt_tab, lr_con);
                  ELSE
                     IF SUBSTR(lr_con.arrow,1,1) = '<' THEN
                        -- A<-B: from right to left i.e. from target to source
                        manage_constraints(lr_tgt_tab, lr_src_tab, lr_con);
                     ELSE
                        -- A->B: from left to right i.e. from source to target
                        manage_constraints(lr_src_tab, lr_tgt_tab, lr_con);
                     END IF;
                  END IF;
               END LOOP; -- for each target table
            END LOOP; -- for each source table
            lt_src_tab := lt_tgt_tab;
         END LOOP; -- for each arrow
         IF l_arrow_count = 0 THEN
            FOR l_src_idx IN 1..lt_src_tab.COUNT LOOP
               lr_src_tab := lt_src_tab(l_src_idx);
               IF NVL(lr_src_tab.is_processed,'N')!='Y' THEN
                  manage_tables(lr_src_tab);
               END IF;
            END LOOP;
         END IF;
      END LOOP; -- for each statement (separated by semi-colon)
      assert(l_line IS NULL,'Syntax error: missing ";" or unexpected input: '||SUBSTR(l_line,1,40)||CASE WHEN LENGTH(l_line)>40 THEN '...' END);
      ds_utility_krn.optimize_referential_cons(p_set_id=>p_set_id);
      ds_utility_krn.define_walk_through_strategy(p_set_id=>p_set_id);
   END include_path;
END ds_utility_ext;
/
