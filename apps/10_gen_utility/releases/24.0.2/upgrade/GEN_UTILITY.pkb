CREATE OR REPLACE PACKAGE BODY gen_utility IS
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
/*
 Author: Philippe Debois - 2008-2019
   Name: GEN_UTILITY - PL/SQL code generator based on database object templates
 Remark: Follow C precompiler syntax (see: https:/ /gcc.gnu.org/onlinedocs/cpp/)
*/
--#pragma macro
   -- Procedure definitions
   PROCEDURE process_lines (
      t_lines_in IN OUT sys.dbms_sql.varchar2a
    , p_object_type IN VARCHAR2 := NULL
    , p_object_name IN VARCHAR2 := NULL
   );
   PROCEDURE process_source (
      p_source IN OUT VARCHAR2
   );
   PROCEDURE include_source (
      p_source IN OUT VARCHAR2
    , t_lines_in IN OUT sys.dbms_sql.varchar2a
   );
   -- Global types
   TYPE args_table IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
   TYPE parameter_table IS TABLE OF varchar2(100) INDEX BY BINARY_INTEGER;
   TYPE symbol_record IS RECORD (
      NAME varchar2(100)
    , value VARCHAR2(4000)
    , param parameter_table
    , param_count INTEGER -- NULL when no parameter
   );
   TYPE loopvar_record IS RECORD (
      NAME VARCHAR2(100)
    , min_val INTEGER
    , max_val INTEGER
    , cur_val INTEGER
    , step INTEGER
    , line_no INTEGER
    , stmt VARCHAR2(4000) -- sql statement
    , l_cursor INTEGER -- cursor number
    , t_desc sys.dbms_sql.desc_tab2 -- descriptors
    , row_count INTEGER
    , last_row_count INTEGER
   );
   TYPE symbol_table IS TABLE OF symbol_record INDEX BY BINARY_INTEGER;
 --TYPE symbol_table IS TABLE OF symbol_record INDEX BY varchar2(100);
   TYPE symbol_index IS TABLE OF symbol_table INDEX BY BINARY_INTEGER;
   TYPE flag_table IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
   TYPE loopvar_table IS TABLE OF loopvar_record INDEX BY BINARY_INTEGER;
   -- Global variables
   t_sym_idx symbol_index;
   t_sym_idx_prev symbol_index;
   t_flags flag_table;
   t_loopvar loopvar_table;
   g_iso_default BOOLEAN := FALSE; -- true ISO implementation
   g_macro_default BOOLEAN := FALSE; -- macro mode
   -- Following globals are set in initialize() at each run
   g_debug BOOLEAN := FALSE;
   g_cnt INTEGER;
   g_flag INTEGER;
   g_reversible BOOLEAN;
   g_force BOOLEAN;
   g_owner VARCHAR2(30);
   g_iso BOOLEAN;
   g_macro BOOLEAN;
   g_sorted BOOLEAN;
   g_silent BOOLEAN;
   g_clone BOOLEAN;
   -- Global constants
   gk_object_type_sym CONSTANT VARCHAR2(15) := '__'||'OBJECT_TYPE'||'__';
   gk_object_name_sym CONSTANT VARCHAR2(15) := '__'||'OBJECT_NAME'||'__';
   gk_file_sym CONSTANT VARCHAR2(8) := '__'||'FILE'||'__';
   -- Optimisation
   TYPE sym_name_table IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
   TYPE sym_value_table IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
   TYPE sym_param_table IS TABLE OF parameter_table INDEX BY BINARY_INTEGER;
   TYPE sym_param_count_table IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
   TYPE index_table IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
   t_sym_name sym_name_table;
   t_sym_value sym_value_table;
   t_sym_param sym_param_table;
   t_sym_param_count sym_param_count_table;
   t_sym_len index_table;
   t_sym_ptr index_table;
   ---
   -- Log message
   ---
   PROCEDURE log (
      p_text IN VARCHAR2
    , p_new_line IN BOOLEAN := TRUE
   )
   IS
   BEGIN
    --log_utility.log_message(NULL,'T',p_text,p_new_line);
      IF p_new_line THEN
         sys.dbms_output.put_line(p_text);
      ELSE
         sys.dbms_output.put(p_text);
      END IF;
   END;
   ---
   -- Check assertion
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_msg IN VARCHAR2
   )
   IS
   BEGIN
      IF NOT NVL(p_assertion,FALSE) THEN
         raise_application_error(-20000,p_err_msg);
      END IF;
   END;
--#if 0
   ---
   -- Check whether a line starts with a string
   ---
   FUNCTION starts_with (
      p_line IN VARCHAR2
    , p_string IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN NVL(SUBSTR(p_line,1,LENGTH(p_string)) = p_string,FALSE);
   END;
--#endif 0
--#define starts_with(p_line,p_string) (SUBSTR(p_line,1,LENGTH(p_string)) = p_string)
--#if 0
   ---
   -- Check whether a line ends with a string
   ---
   FUNCTION ends_with (
      p_line IN VARCHAR2
    , p_string IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN NVL(SUBSTR(p_line,-LENGTH(p_string)) = p_string,FALSE);
   END;
--#endif 0
--#define ends_with(p_line,p_string) (SUBSTR(p_line,-LENGTH(p_string)) = p_string)
--#if 0
   ---
   -- Is letter?
   ---
   FUNCTION is_letter (
      p_char IN CHAR
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_char BETWEEN 'a' AND 'z' OR p_char BETWEEN 'A' AND 'Z';
   END;
--#endif 0
--#define is_letter(p_char) (p_char BETWEEN 'a' AND 'z' OR p_char BETWEEN 'A' AND 'Z')
--#if 0
   ---
   -- Is digit?
   ---
   FUNCTION is_digit (
      p_char IN CHAR
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_char BETWEEN '0' AND '9';
   END;
--#endif 0
--#define is_digit(p_char) (p_char BETWEEN '0' AND '9')
   ---
   -- Compare 2 string taking into account NULL values
   ---
   FUNCTION is_equal (
      p_str1 IN VARCHAR2
    , p_str2 IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      IF p_str1 IS NULL AND p_str2 IS NULL THEN
         RETURN TRUE;
      END IF;
      IF p_str1 IS NOT NULL AND p_str2 IS NULL
      OR p_str2 IS NOT NULL AND p_str1 IS NULL
      THEN
         RETURN FALSE;
      END IF;
      RETURN p_str1 = p_str2;
   END;
--#if 0
   ---
   -- Is white space?
   ---
   FUNCTION is_ws (
      p_char IN CHAR
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_char IN (' ',CHR(9),CHR(10),CHR(13));
   END;
--#endif 0
--#define is_ws(p_char) (p_char IN (' ',CHR(9),CHR(10),CHR(13)))
   ---
   -- Is id?
   ---
--#if 0
   FUNCTION is_id (
      p_char IN CHAR
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN is_letter(p_char) OR p_char='_';
   END;
--#endif 0
--#define is_id(p_char) (is_letter(p_char) OR p_char='_')
   ---
   -- Is string?
   ---
   FUNCTION is_string (
      p_char IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN SUBSTR(p_char,1,1) IN ('''','"');
   END;
   ---
   -- Remove string quotes
   ---
   FUNCTION remove_quotes (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE WHEN is_string(p_str) THEN SUBSTR(p_str,2,LENGTH(p_str)-2) ELSE p_str END;
   END;
   ---
   -- Consume string
   ---
   FUNCTION consume_string (
      l_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_sep VARCHAR2(1 CHAR);
      l_char VARCHAR2(1 CHAR);
      l_buf VARCHAR2(4000);
   BEGIN
      l_char := SUBSTR(l_line,1,1);
      assert(l_char IN ('''','"'),'String must start with a simple or double quote');
      l_sep := l_char;
      WHILE l_line IS NOT NULL LOOP
         l_buf := l_buf || l_char;
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
         EXIT WHEN l_char = l_sep;
      END LOOP;
      assert(l_char IN ('''','"'),'Unterminated string (matching quote not found)');
      l_buf := l_buf || l_char;
      l_line := SUBSTR(l_line,2);
      RETURN l_buf;
   END;
   ---
   -- Consume white spaces
   ---
   FUNCTION consume_white_spaces (
      l_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_char VARCHAR2(1 CHAR);
      l_buf VARCHAR2(4000);
   BEGIN
      -- Skip spaces
      l_char := SUBSTR(l_line,1,1);
      WHILE l_line IS NOT NULL AND is_ws(l_char) LOOP
         l_buf := l_buf || l_char;
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
      END LOOP;
      RETURN l_buf;
   END;
   ---
   -- Consume white spaces
   ---
   PROCEDURE consume_white_spaces (
      l_line IN OUT VARCHAR2
   )
   IS
      l_char VARCHAR2(1 CHAR);
   BEGIN
      -- Skip spaces
      l_char := SUBSTR(l_line,1,1);
      WHILE l_line IS NOT NULL AND is_ws(l_char) LOOP
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
      END LOOP;
   END;
   ---
   -- Extract word
   ---
   FUNCTION consume_word (
      l_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_word VARCHAR2(4000);
      l_char VARCHAR2(1 CHAR);
   BEGIN
      -- Skip leading spaces
      consume_white_spaces(l_line);
      -- Copy until space found or end of line
      l_char := SUBSTR(l_line,1,1);
      WHILE l_line IS NOT NULL AND NOT is_ws(l_char) LOOP
         l_word := l_word || l_char;
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
      END LOOP;
      -- Skip trailing spaces
      consume_white_spaces(l_line);
      RETURN l_word;
   END;
   ---
   -- Consume identifier
   ---
   FUNCTION consume_identifier (
      l_line IN OUT VARCHAR2
    , p_ws IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_word VARCHAR2(4000);
      l_char VARCHAR2(1 CHAR);
   BEGIN
      IF p_ws THEN
         consume_white_spaces(l_line);
      END IF;
      -- Copy until space found or end of line
      l_char := SUBSTR(l_line,1,1);
      WHILE is_id(l_char)
         OR is_digit(l_char)
      LOOP
         l_word := l_word || l_char;
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
      END LOOP;
      IF p_ws THEN
         consume_white_spaces(l_line);
      END IF;
      RETURN l_word;
   END;
   ---
   -- Get identifier
   ---
   FUNCTION get_identifier (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_len INTEGER := NVL(LENGTH(p_str),0);
      l_pos INTEGER := 1;   -- current position
      l_chr VARCHAR2(1 CHAR);    -- current character
   BEGIN
      l_chr := SUBSTR(p_str,l_pos,1);
      WHILE l_pos <= l_len AND (is_id(l_chr) OR (l_pos > 1 AND is_digit(l_chr))) LOOP
         l_pos := l_pos + 1;
         l_chr := SUBSTR(p_str,l_pos,1);
      END LOOP;
      RETURN SUBSTR(p_str,1,l_pos-1);
   END;
   ---
   -- Consume integer
   ---
   FUNCTION consume_integer (
      l_line IN OUT VARCHAR2
    , p_ws IN BOOLEAN := TRUE
   )
   RETURN INTEGER
   IS
      l_int INTEGER;
      l_sign INTEGER := 1;
      l_char VARCHAR2(1 CHAR);
   BEGIN
      -- Skip leading spaces
      IF p_ws THEN
         consume_white_spaces(l_line);
      END IF;
      IF SUBSTR(l_line,1,1) = '-' THEN
         l_sign := -1;
         l_line := SUBSTR(l_line,2);
      END IF;
      -- Copy while digit found
      l_char := SUBSTR(l_line,1,1);
      WHILE l_line IS NOT NULL AND is_digit(l_char) LOOP
         l_int := NVL(l_int,0) * 10 + l_char - '0';
         l_line := SUBSTR(l_line,2);
         l_char := SUBSTR(l_line,1,1);
      END LOOP;
      -- Skip trailing spaces
      IF p_ws THEN
         consume_white_spaces(l_line);
      END IF;
      RETURN l_int * l_sign;
   END;
   ---
   -- Consume keyword
   ---
   PROCEDURE consume_keyword (
      l_line IN OUT VARCHAR2
    , p_value IN VARCHAR2
    , p_err_msg IN VARCHAR2
   )
   IS
      l_len INTEGER := LENGTH(p_value);
   BEGIN
      -- Skip leading spaces
      consume_white_spaces(l_line);
      -- Check keyword
      assert(SUBSTR(l_line,1,l_len)=p_value,p_err_msg);
      l_line := SUBSTR(l_line,l_len+1);
      -- Skip trailing spaces
      consume_white_spaces(l_line);
   END;
   ---
   -- Consume one character
   ---
   FUNCTION consume_one_char (
      l_line IN OUT VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_char VARCHAR2(1 CHAR);
   BEGIN
      -- Check keyword
      l_char := SUBSTR(l_line,1,1);
      l_line := SUBSTR(l_line,2);
      RETURN l_char;
   END;
   ---
   -- Token based replace
   --
   -- Sometimes you may want to convert a macro argument into a string constant.
   -- Parameters are not replaced inside string constants, but you can use the ‘#’ preprocessing operator instead.
   -- When a macro parameter is used with a leading ‘#’, the preprocessor replaces it with the literal text of the
   -- actual argument, converted to a string constant. Unlike normal parameter replacement, the argument is not
   -- macro-expanded first. This is called stringification.
   ---
   ---
   FUNCTION replace_token (
      p_str  IN VARCHAR2 -- string in which to replace
    , p_what IN VARCHAR2 -- string to replace
    , p_with IN VARCHAR2 -- replacement string
    , p_stringify IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_len INTEGER := NVL(LENGTH(p_str),0);
      l_beg INTEGER := 1;   -- beginning of string not copied yet
      l_pos INTEGER := 1;   -- current position
      l_sav INTEGER;        -- saved position
      l_chr VARCHAR2(1 CHAR);    -- current character
      l_res VARCHAR2(4000); -- result string
      l_stringify BOOLEAN;
   BEGIN
      WHILE l_pos <= l_len LOOP
         l_chr := SUBSTR(p_str,l_pos,1);
         IF is_id(l_chr) THEN
            l_sav := l_pos;
            WHILE is_id(l_chr) OR is_digit(l_chr) LOOP
               l_pos := l_pos + 1;
               l_chr := SUBSTR(p_str,l_pos,1);
            END LOOP;
            IF SUBSTR(p_str,l_sav,l_pos-l_sav) = p_what THEN
               l_stringify := p_stringify AND SUBSTR(p_str,l_sav-1,1) = '#';
               IF l_stringify THEN
                  l_sav := l_sav - 1; -- don't copy #
                  l_res := l_res || SUBSTR(p_str,l_beg,l_sav-l_beg) || '"' || p_with || '"';
               ELSE
                  l_res := l_res || SUBSTR(p_str,l_beg,l_sav-l_beg) || p_with;
               END IF;
               l_beg := l_pos;
            END IF;
         ELSE
            WHILE l_chr IS NOT NULL AND NOT is_id(l_chr) LOOP
               l_pos := l_pos + 1;
               l_chr := SUBSTR(p_str,l_pos,1);
            END LOOP;
         END IF;
      END LOOP;
      l_res := l_res || SUBSTR(p_str,l_beg,l_pos-l_beg);
      RETURN l_res;
   END;
   ---
   -- Implement token pasting or concatenation
   -- (it is not checked that the result is a valid token)
   ---
   FUNCTION concatenate_tokens (
      p_str  IN VARCHAR2 -- string containing ##
   )
   RETURN VARCHAR2
   IS
      l_len INTEGER := NVL(LENGTH(p_str),0);
      l_beg INTEGER := 1;   -- beginning of string not copied yet
      l_pos INTEGER := 1;   -- current position
      l_sav INTEGER := 0;   -- saved position
      l_ch1 VARCHAR2(1 CHAR);    -- current character
      l_ch2 VARCHAR2(1 CHAR);    -- next character
      l_res VARCHAR2(4000); -- result string
   BEGIN
      IF NOT g_macro THEN
         RETURN p_str;
      END IF;
      WHILE l_pos <= l_len LOOP
         l_ch1 := SUBSTR(p_str,l_pos,1);
         l_ch2 := SUBSTR(p_str,l_pos+1,1);
         IF l_ch1 = '#' AND l_ch2 = '#' THEN
            assert(l_pos>l_beg,'Missing token to the left of ## operator');
            l_res := l_res || SUBSTR(p_str,l_beg,l_sav-l_beg)
                           || TRIM(SUBSTR(p_str,l_sav,l_pos-l_sav));
            l_pos := l_pos + 2;
            l_ch1 := SUBSTR(p_str,l_pos,1);
            WHILE is_ws(l_ch1) LOOP
               l_pos := l_pos + 1;
               l_ch1 := SUBSTR(p_str,l_pos,1);
            END LOOP;
            l_beg := l_pos;
            l_sav := 0;
         ELSIF is_ws(l_ch1) THEN
            WHILE is_ws(l_ch1) LOOP
               l_pos := l_pos + 1;
               l_ch1 := SUBSTR(p_str,l_pos,1);
            END LOOP;
         ELSE
            l_sav := l_pos;
            WHILE l_ch1 IS NOT NULL AND NOT (is_ws(l_ch1) OR (is_equal(l_ch1,'#') AND is_equal(l_ch2,'#')))
            LOOP
               l_pos := l_pos + 1;
               l_ch1 := SUBSTR(p_str,l_pos,1);
               l_ch2 := SUBSTR(p_str,l_pos+1,1);
            END LOOP;
         END IF;
         WHILE is_ws(l_ch1) LOOP
            l_pos := l_pos + 1;
            l_ch1 := SUBSTR(p_str,l_pos,1);
         END LOOP;
      END LOOP;
      l_res := l_res || SUBSTR(p_str,l_beg,l_pos-l_beg);
      RETURN l_res;
   END;
   ---
   -- Sort symbols
   ---
   PROCEDURE sort_symbols
   IS
      l_ptr INTEGER;
      j INTEGER;
      n INTEGER := t_sym_ptr.COUNT;
      newn INTEGER;
   BEGIN
      IF g_sorted THEN
         RETURN;
      END IF;
      -- Sort array of pointers on symbol length DESC using optimized bubblesort
      WHILE TRUE LOOP
         newn := 0;
         FOR i IN 1..n-1 LOOP
            j := i + 1;
            IF t_sym_len(t_sym_ptr(j)) > t_sym_len(t_sym_ptr(i)) THEN
               -- Swap
               l_ptr := t_sym_ptr(j);
               t_sym_ptr(j) := t_sym_ptr(i);
               t_sym_ptr(i) := l_ptr;
               newn := i;
            END IF;
         END LOOP;
         n := newn;
         EXIT WHEN n = 0;
      END LOOP;
      g_sorted := TRUE;
   END;
   ---
   -- Add a symbol
   ---
   PROCEDURE add_symbol (
      r_sym IN symbol_record
   )
   IS
      l_ptr INTEGER;
      l_len INTEGER := LENGTH(r_sym.NAME);
      l_zero_len BOOLEAN;
   BEGIN
      g_sorted := FALSE;
      -- Search symbol
      FOR i IN 1..t_sym_ptr.COUNT LOOP
         l_ptr := t_sym_ptr(i);
         l_zero_len := t_sym_len(l_ptr)=0;
         IF t_sym_len(l_ptr) = l_len OR l_zero_len THEN
            IF t_sym_name(l_ptr) = r_sym.NAME THEN
               -- found => replace attributes
               t_sym_len(l_ptr) := l_len;
               t_sym_value(l_ptr) := r_sym.value;
               t_sym_param(l_ptr) := r_sym.param;
               t_sym_param_count(l_ptr) := r_sym.param_count;
               RETURN;
            END IF;
         END IF;
      END LOOP;
      -- Add symbol when not found
      l_ptr := t_sym_ptr.COUNT+1;
      t_sym_ptr(l_ptr) := l_ptr;
      t_sym_len(l_ptr) := l_len;
      t_sym_name(l_ptr) := r_sym.NAME;
      t_sym_value(l_ptr) := r_sym.value;
      t_sym_param(l_ptr) := r_sym.param;
      t_sym_param_count(l_ptr) := r_sym.param_count;
   END;
   ---
   -- Delete a symbol
   ---
   PROCEDURE del_symbol (
      p_name IN VARCHAR2
   )
   IS
      l_ptr INTEGER;
      l_len INTEGER := LENGTH(p_name);
   BEGIN
      g_sorted := FALSE;
      -- Search symbol
      FOR i IN 1..t_sym_ptr.COUNT LOOP
         l_ptr := t_sym_ptr(i);
         IF t_sym_len(l_ptr) = l_len THEN
            IF t_sym_name(l_ptr) = p_name THEN
               -- found => set its length to zero (meaning deleted)
               t_sym_len(l_ptr) := 0;
               RETURN;
            END IF;
         END IF;
      END LOOP;
   END;
--#begin public
   ---
   -- Resolve defines
   ---
   FUNCTION replace_symbols (
      p_line IN VARCHAR2
     ,p_recurse IN BOOLEAN
   )
   RETURN VARCHAR2
--#end public
   IS
      l_len INTEGER;
--      r_sym symbol_record;
--      t_sym symbol_table;
--      l_idx INTEGER;
      t_args args_table;
      l_pos INTEGER;
      l_pos2 INTEGER;
      l_line VARCHAR2(4000) := p_line;
      l_buf VARCHAR2(4000);
      l_msg varchar2(100) := 'replace_symbols(): ';
      l_again BOOLEAN := TRUE;
      l_ptr INTEGER;
      FUNCTION replace_parameters (
         l_line IN OUT VARCHAR2
       , p_level IN INTEGER
       , p_param IN OUT args_table
      )
      RETURN VARCHAR2
      IS
         l_res VARCHAR2(4000);
         l_buf VARCHAR2(4000);
         l_name varchar2(100);
         l_len INTEGER;
         l_char VARCHAR2(1 CHAR);
         t_args args_table;
      BEGIN
--sys.dbms_output.put_line(p_level||'->replace_params(): line='||l_line||', #params='||p_param.count);
         l_res := consume_white_spaces(l_line);
         WHILE l_line IS NOT NULL LOOP
--sys.dbms_output.put_line('args='||t_args.count||', res='||l_res||', line='||l_line);
            l_char := SUBSTR(l_line,1,1);
            IF l_char = '(' THEN
--sys.dbms_output.put_line(p_level||' before "(": res='||l_res||', params='||t_args.count);
               l_res := l_res || consume_one_char(l_line);
               DECLARE
                  t_args2 args_table;
               BEGIN
                  l_res := l_res || replace_parameters(l_line,p_level+1,t_args2);
               END;
               l_char := SUBSTR(l_line,1,1);
               assert(l_char=')','missing ")": '||l_line);
               l_res := l_res || consume_one_char(l_line);
--sys.dbms_output.put_line(p_level||' after ")": res='||l_res||', params='||t_args.count);
            ELSIF l_char = ')' THEN
             --assert(p_level>0, 'unexpected ")"');
               IF p_level > 0 THEN
                  GOTO end_proc;
               ELSE
                  l_res := l_res || consume_one_char(l_line);
               END IF;
            ELSIF l_char = ',' THEN
               t_args(t_args.COUNT+1) := l_res;
               l_res := NULL;
               l_line := SUBSTR(l_line,2);
            ELSIF is_id(l_char) THEN
               l_name := consume_identifier(l_line);
--sys.dbms_output.put_line('found identifier: '||l_name);
--               IF l_name = r_sym.name THEN
               IF l_name = t_sym_name(l_ptr) THEN
--sys.dbms_output.put_line('identifier matches, args must be replaced');
                  l_buf := consume_white_spaces(l_line);
                  l_char := SUBSTR(l_line,1,1);
                  IF l_char = '(' THEN
                     l_line := SUBSTR(l_line,2);
                     DECLARE
                        t_args2 args_table;
                     BEGIN
                        l_buf := replace_parameters(l_line,p_level+1,t_args2);
--sys.dbms_output.put_line('t_args2.count='||t_args2.count||', r_sym.param_count='||t_sym_param_count(l_ptr));
                        l_char := SUBSTR(l_line,1,1);
                        assert(l_char=')','missing ")"');
                        l_line := SUBSTR(l_line,2);
--                        assert(t_args2.COUNT=r_sym.param_count,'macro "'||r_sym.name||'" requires '||r_sym.param_count||' arguments, but '||t_args2.COUNT||' given');
                        assert(t_args2.COUNT=t_sym_param_count(l_ptr),'macro "'||t_sym_name(l_ptr)||'" requires '||t_sym_param_count(l_ptr)||' arguments, but '||t_args2.COUNT||' given');
--                        l_buf := r_sym.value;
                        l_buf := t_sym_value(l_ptr);
                        FOR i IN 1..t_args2.COUNT LOOP
--sys.dbms_output.put_line('replacing arg'||i||' '||t_sym_param(l_ptr)(i)||' with '||t_args2(i));
--                           l_buf := replace_token(l_buf,r_sym.param(i),NVL(TRIM(t_args2(i)),' '),TRUE);
                           l_buf := replace_token(l_buf,t_sym_param(l_ptr)(i),NVL(TRIM(t_args2(i)),' '),TRUE);
                        END LOOP;
                        l_res := l_res || l_buf;
                     END;
                  ELSE
                     l_res := l_res || l_name || l_buf;
                  END IF;
               ELSE
                  l_res := l_res || l_name;
               END IF;
            ELSE
               WHILE l_char IS NOT NULL AND NOT l_char IN ('(',')',',') AND NOT is_ws(l_char) LOOP
                  l_res := l_res || consume_one_char(l_line);
                  l_char := SUBSTR(l_line,1,1);
               END LOOP;
            END IF;
            l_res := l_res || consume_white_spaces(l_line);
         END LOOP;
         <<end_proc>>
         t_args(t_args.COUNT+1) := l_res;
         l_res := t_args(1);
         FOR i IN 2..t_args.COUNT LOOP
            l_res := l_res || ',' || t_args(i);
         END LOOP;
         p_param := t_args;
--sys.dbms_output.put_line(p_level||'<-replace_params(): res='||l_res||', params='||t_args.count);
         RETURN l_res;
      END;
   BEGIN
      sort_symbols;
      WHILE l_again LOOP
         l_again := FALSE;
--         l_len := t_sym_idx.LAST;
--         WHILE l_len IS NOT NULL LOOP
--            t_sym := t_sym_idx(l_len);
--            l_idx := t_sym.FIRST;
--            WHILE l_idx IS NOT NULL LOOP
--               r_sym := t_sym(l_idx);
         FOR j IN 1..1 LOOP
            FOR i IN 1..t_sym_ptr.COUNT LOOP
               l_ptr := t_sym_ptr(i);
               l_len := t_sym_len(l_ptr);
               -- Symbols equals to their value are not replaced
               -- e.g. #define _XYZ _XYZ
               IF t_sym_name(l_ptr) = t_sym_value(l_ptr) THEN
                  GOTO next_sym;
               END IF;
               EXIT WHEN l_len = 0; -- deleted symbols (at the end of the table)
               l_pos := INSTR(l_line,t_sym_name(l_ptr));
--               l_pos := INSTR(l_line,r_sym.name);
               -- If macro is found
               WHILE l_pos > 0 LOOP
                  -- Function-like macro?
--                  IF r_sym.param_count IS NOT NULL THEN
                  IF t_sym_param_count(l_ptr) > 0 THEN
                     -- Skip ws to find opening parenthesis
                     l_pos2 := l_pos+l_len;
                     WHILE is_ws(SUBSTR(l_line,l_pos2,1)) LOOP
                        l_pos2 := l_pos2 + 1;
                     END LOOP;
                     IF SUBSTR(l_line,l_pos2,1) = '(' THEN
                        l_buf := SUBSTR(l_line,l_pos);
                        l_line := SUBSTR(l_line,1,l_pos-1) || concatenate_tokens(replace_parameters(l_buf,0,t_args));
                        IF p_recurse OR g_iso THEN
                           l_again := TRUE;
                        END IF;
                        l_pos := INSTR(l_line,t_sym_name(l_ptr),l_pos);
--                        l_pos := INSTR(l_line,r_sym.name,l_pos);
                     ELSE
                        -- A function-like macro is only expanded if its name appears with a pair of parentheses after it.
                        -- If you write just the name, it is left alone. This can be useful when you have a function and
                        -- a macro of the same name, and you wish to use the function sometimes.
                        l_pos := INSTR(l_line,t_sym_name(l_ptr),l_pos+1);
--                        l_pos := INSTR(l_line,r_sym.name,l_pos+1);
                     END IF;
                  ELSE
                     l_line := SUBSTR(l_line,1,l_pos-1)
--                             ||concatenate_tokens(r_sym.value)
                             ||concatenate_tokens(t_sym_value(l_ptr))
                             ||SUBSTR(l_line,l_pos+l_len);
                     IF p_recurse OR g_iso THEN
                        l_again := TRUE;
                     END IF;
--                     l_pos := INSTR(l_line,r_sym.name,l_pos);
                     l_pos := INSTR(l_line,t_sym_name(l_ptr),l_pos);
                  END IF;
               END LOOP;
--               l_idx := t_sym.NEXT(l_idx);
            END LOOP;
            <<next_sym>>
            NULL;
--            l_len := t_sym_idx.PRIOR(l_len);
         END LOOP;
      END LOOP;
      RETURN REPLACE(l_line,'\'||'0x20',' ');
   END;
   ---
   -- Define symbol
   ---
   PROCEDURE define_symbol (
      t_sym_idx IN OUT symbol_index
     ,p_name IN VARCHAR2
     ,p_value IN VARCHAR2
     ,p_replace IN BOOLEAN
   )
   IS
      l_len INTEGER;
      t_sym symbol_table;
      r_sym symbol_record;
      l_idx INTEGER;
      l_name varchar2(100);
      l_msg varchar2(100) := 'define_symbol(): ';
      l_value VARCHAR2(4000);
   BEGIN
      l_name := p_name;
      assert(l_name IS NOT NULL, l_msg||'symbol is missing');
      l_value := CASE WHEN p_replace AND NOT g_iso THEN replace_symbols(p_value,TRUE) ELSE p_value END;
      l_len := LENGTH(l_name);
      IF t_sym_idx.EXISTS(l_len) THEN
         t_sym := t_sym_idx(l_len);
         l_idx := t_sym.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            r_sym := t_sym(l_idx);
            IF r_sym.NAME = l_name THEN
               -- found => replace value
               r_sym.value := l_value;
               t_sym_idx(l_len)(l_idx).value := l_value;
               add_symbol(r_sym);
               RETURN;
            END IF;
            l_idx := t_sym.NEXT(l_idx);
         END LOOP;
      END IF;
      -- not found => add symbol
      r_sym.NAME := l_name;
      r_sym.value := l_value;
      t_sym(NVL(t_sym.LAST,0)+1) := r_sym;
      t_sym_idx(l_len) := t_sym;
      add_symbol(r_sym);
   END;
   ---
   -- Define symbol
   ---
   PROCEDURE define_symbol (
      t_sym_idx IN OUT symbol_index
     ,p_sym IN OUT symbol_record
     ,p_replace IN BOOLEAN
   )
   IS
      l_len INTEGER;
      t_sym symbol_table;
      r_sym symbol_record;
      l_idx INTEGER;
      l_name varchar2(100);
      l_msg varchar2(100) := 'define_symbol(): ';
      l_value VARCHAR2(4000);
   BEGIN
      l_name := p_sym.NAME;
      assert(l_name IS NOT NULL, l_msg||'symbol is missing');
      l_value := CASE WHEN p_replace AND NOT g_iso THEN replace_symbols(p_sym.value,TRUE) ELSE p_sym.value END;
      l_len := LENGTH(l_name);
      IF t_sym_idx.EXISTS(l_len) THEN
         t_sym := t_sym_idx(l_len);
         l_idx := t_sym.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            r_sym := t_sym(l_idx);
            IF r_sym.NAME = l_name THEN
               -- found => replace attributes
               r_sym.value := l_value;
               r_sym.param := p_sym.param;
               r_sym.param_count := p_sym.param_count;
               t_sym_idx(l_len)(l_idx).value := r_sym.value;
               t_sym_idx(l_len)(l_idx).param := r_sym.param;
               t_sym_idx(l_len)(l_idx).param_count := r_sym.param_count;
               add_symbol(r_sym);
               RETURN;
            END IF;
            l_idx := t_sym.NEXT(l_idx);
         END LOOP;
      END IF;
      -- not found => add symbol
      r_sym.NAME := l_name;
      r_sym.value := l_value;
      r_sym.param := p_sym.param;
      r_sym.param_count := p_sym.param_count;
      t_sym(NVL(t_sym.LAST,0)+1) := r_sym;
      t_sym_idx(l_len) := t_sym;
      add_symbol(r_sym);
   END;
   ---
   -- Define symbol
   ---
   PROCEDURE define_symbol (
      p_line IN OUT VARCHAR2
   )
   IS
      r_sym symbol_record;
      l_char VARCHAR2(1 CHAR);
      l_name varchar2(100);
   BEGIN
      IF NOT g_iso THEN
         -- Old code (v1.0)
         r_sym.NAME := consume_word(p_line);
         r_sym.value := p_line;
         define_symbol(t_sym_idx,r_sym,NOT g_iso);
         RETURN;
      END IF;
      consume_white_spaces(p_line);
      r_sym.NAME := consume_identifier(p_line);
      -- Function-like macro?
      l_char := SUBSTR(p_line,1,1);
      -- If you put spaces between the macro name and the parentheses in the macro definition,
      -- that does not define a function-like macro, it defines an object-like macro whose
      -- expansion happens to begin with a pair of parentheses.
      IF l_char = '(' THEN
         p_line := SUBSTR(p_line,2);
         WHILE p_line IS NOT NULL LOOP
            consume_white_spaces(p_line);
            l_char := SUBSTR(p_line,1,1);
            IF l_char=')' THEN
               p_line := SUBSTR(p_line,2);
               EXIT;
            ELSIF is_id(l_char) THEN
               -- Store parameter
               r_sym.param(r_sym.param.COUNT+1) := consume_identifier(p_line);
            ELSIF l_char=',' AND r_sym.param.COUNT>0 THEN
               p_line := SUBSTR(p_line,2);
            ELSE
               assert(FALSE,'unexpected character in parameters of function-like macro "'||r_sym.NAME||'": '||NVL(l_char,'<eol>'));
            END IF;
         END LOOP;
         r_sym.param_count := r_sym.param.COUNT;
      END IF;
      consume_white_spaces(p_line);
      r_sym.value := p_line;
      define_symbol(t_sym_idx,r_sym,NOT g_iso);
   END;
   ---
   -- Exists symbol
   ---
   FUNCTION exists_symbol (
      p_line IN OUT VARCHAR2
   )
   RETURN INTEGER
   IS
      l_len INTEGER;
      l_ptr INTEGER;
--      t_sym symbol_table;
--      r_sym symbol_record;
--      l_idx INTEGER;
      l_name varchar2(100);
      l_msg varchar2(100) := 'exists_symbol(): ';
   BEGIN
      l_name := consume_word(p_line);
      IF INSTR(l_name,'$') > 0 THEN
         l_name := replace_symbols(l_name,FALSE);
      END IF;
      assert(l_name IS NOT NULL, l_msg||'symbol is missing');
      l_len := LENGTH(l_name);
      -- Search symbol
      FOR i IN 1..t_sym_len.COUNT LOOP
         IF  t_sym_len(i) = l_len
         AND t_sym_name(i) = l_name
         THEN
            RETURN 1;
         END IF;
      END LOOP;
      RETURN 0;
      /*Old search*/
--      IF t_sym_idx.EXISTS(l_len) THEN
--         t_sym := t_sym_idx(l_len);
--         l_idx := t_sym.FIRST;
--         WHILE l_idx IS NOT NULL LOOP
--            r_sym := t_sym(l_idx);
--            IF r_sym.name = l_name THEN
--               -- found
--               RETURN 1;
--            END IF;
--            l_idx := t_sym.NEXT(l_idx);
--         END LOOP;
--      END IF;
--      RETURN 0;
   END;
   ---
   -- Get symbol value
   ---
   FUNCTION get_symbol_value (
      p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_len INTEGER;
--      t_sym symbol_table;
--      r_sym symbol_record;
--      l_idx INTEGER;
      l_name varchar2(100);
      l_msg varchar2(100) := 'get_symbol_value(): ';
   BEGIN
      l_name := p_name;
      IF INSTR(l_name,'$') > 0 THEN
         l_name := replace_symbols(l_name,FALSE);
      END IF;
      assert(l_name IS NOT NULL, l_msg||'symbol is missing');
      l_len := LENGTH(l_name);
      -- Search symbol
      FOR i IN 1..t_sym_len.COUNT LOOP
         IF  t_sym_len(i) = l_len
         AND t_sym_name(i) = l_name
         THEN
            RETURN t_sym_value(i);
         END IF;
      END LOOP;
      RETURN NULL;
--      IF t_sym_idx.EXISTS(l_len) THEN
--         t_sym := t_sym_idx(l_len);
--         l_idx := t_sym.FIRST;
--         WHILE l_idx IS NOT NULL LOOP
--            r_sym := t_sym(l_idx);
--            IF r_sym.name = l_name THEN
--               -- found
--               RETURN r_sym.value;
--            END IF;
--            l_idx := t_sym.NEXT(l_idx);
--         END LOOP;
--      END IF;
--      RETURN NULL;
   END;
   ---
   -- Bitwise AND operation is an Oracle native function (BITAND)
   ---
   --
   ---
   -- Bitwise OR operation
   ---
   FUNCTION bitor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
   AS
   BEGIN
      RETURN x + y - BITAND(x,y);
   END;
   ---
   -- Bitwise XOR operation
   ---
   FUNCTION bitxor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
   AS
   BEGIN
      RETURN bitor(x,y) - bitand(x,y);
   END;
   ---
   -- Bitwise NOT operation
   ---
   FUNCTION bitnot (x IN NUMBER)
   RETURN NUMBER
   AS
   BEGIN
      RETURN (0 - x) - 1;
   END;
   ---
   -- Convert character string to number
   -- Raise a message in case of conversion error
   ---
   FUNCTION my_to_number (
      p_str IN VARCHAR2
   )
   RETURN NUMBER
   IS
      e_conversion_error EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_conversion_error, -6512);
   BEGIN
      RETURN remove_quotes(p_str);
   EXCEPTION
      WHEN e_conversion_error THEN -- seems not working...
         assert(FALSE,'Character to number conversion error for: '||p_str);
      WHEN OTHERS THEN
         assert(FALSE,'Character to number conversion error for: '||p_str);
   END;
   ---
   -- Check if 2 strings are equal (or both NULL)
   ---
   FUNCTION string_equal (
      p_str1 IN VARCHAR2
    , p_str2 IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_str1 = p_str2 OR (p_str1 IS NULL AND p_str2 IS NULL);
   END;
   ---
   -- Evaluate macro functions
   ---
   FUNCTION eval_macro_functions (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_len INTEGER := NVL(LENGTH(p_str),0);
      l_pos INTEGER := 1;
      l_beg INTEGER := 1;
      l_sav INTEGER;
      l_sav2 INTEGER;
      l_sav3 INTEGER;
      l_kwd INTEGER;
      l_chr VARCHAR2(1 CHAR);
      l_res VARCHAR2(4000);
      FUNCTION consume_keyword (
         p_what IN VARCHAR2
      )
      RETURN BOOLEAN
      IS
         l_len INTEGER := LENGTH(p_what);
      BEGIN
         IF UPPER(SUBSTR(p_str,l_pos,l_len)) = UPPER(p_what) THEN
            l_pos := l_pos + l_len;
            RETURN TRUE;
         END IF;
         RETURN FALSE;
      END;
      PROCEDURE skip_ws IS
      BEGIN
         WHILE is_ws(SUBSTR(p_str,l_pos,1)) LOOP
            l_pos := l_pos + 1;
         END LOOP;
      END;
      PROCEDURE read_until (
         p_chr IN VARCHAR2
      )
      IS
         l_chr VARCHAR2(1 CHAR);
      BEGIN
         WHILE l_pos <= l_len LOOP
            l_chr := SUBSTR(p_str,l_pos,1);
            IF l_chr = p_chr THEN
               RETURN;
            ELSIF l_chr = '''' THEN
               l_pos := l_pos + 1;
               read_until('''');
               l_pos := l_pos + 1;
            ELSIF l_chr = '(' THEN
               l_pos := l_pos + 1;
               read_until (')');
               l_pos := l_pos + 1;
            ELSE
               l_pos := l_pos + 1;
            END IF;
         END LOOP;
      END;
   BEGIN
      l_pos := NVL(INSTR(p_str,'#'),0);
      WHILE l_pos > 0 LOOP
         l_sav := l_pos;
         l_pos := l_pos + 1;
         l_kwd := NULL;
         IF consume_keyword('UPPER') THEN
            l_kwd := 1;
         ELSIF consume_keyword('LOWER') THEN
            l_kwd := 2;
         END IF;
         IF l_kwd IS NOT NULL THEN
            l_sav2 := l_pos;
            skip_ws;
            IF SUBSTR(p_str,l_pos,1) = '(' THEN
               l_pos := l_pos + 1;
               l_sav3 := l_pos;
               read_until(')');
               assert(SUBSTR(p_str,l_pos,1)=')','Missing ")" after argument of '||SUBSTR(p_str,l_sav,l_sav2-l_sav));
               l_pos := l_pos + 1;
               l_res := l_res || SUBSTR(p_str,l_beg,l_sav-l_beg);
               IF l_kwd = 1 THEN
                  l_res := l_res || UPPER(eval_macro_functions(SUBSTR(p_str,l_sav3,l_pos-l_sav3-1)));
               ELSIF l_kwd = 2 THEN
                  l_res := l_res || LOWER(eval_macro_functions(SUBSTR(p_str,l_sav3,l_pos-l_sav3-1)));
               END IF;
               l_beg := l_pos;
            END IF;
         END IF;
         l_pos := NVL(INSTR(p_str,'#',l_pos),0);
      END LOOP;
      IF l_pos = 0 THEN
         l_pos := l_len + 1;
      END IF;
      l_res := l_res || SUBSTR(p_str,l_beg,l_pos-l_beg);
      RETURN l_res;
   END;
   ---
   -- Evaluate expression
   --
   -- Recursively evaluate an expression. When an operator or a "(" is
   -- encountered, expression to its right is evaluated first until the
   -- end of the expression is reached or a ")" is found or an operator
   -- with a lower priority is found. Operators with the same precedence
   -- are evaluated from left to right.
   -- Expressions can contain integers or simple/double quoted strings.
   -- Existing symbols are replaced with their value and non-existing ones
   -- with 0. For boolean operators, number 1 means true and number 0
   -- means false. Besides usual C and PL/SQL operators, some string
   -- manipulation and conversion functions are also implemented.
   --
   ---
   FUNCTION evaluate_expression (
      p_line IN OUT VARCHAR2  -- line containing expression to evaluate
    , p_level IN INTEGER := 0 -- recursive call level (0=first)
    , p_prec IN INTEGER := 99 -- precedence of previous operator (99=lowest)
   )
   RETURN VARCHAR2
   IS
      l_msg varchar2(100) := 'evaluate_expression(): ';
      l_val VARCHAR2(4000);
      l_res VARCHAR2(4000);
      l_char VARCHAR2(1 CHAR);
      l_char2 VARCHAR2(1 CHAR);
      l_symbol VARCHAR2(4000);
      l_count INTEGER := 0;
      l_prec INTEGER := 99; -- operator precedence
      -- Precedence of C and PL/SQL operators (from highest to lowest)
      -- -1: ( )              (parenthesis)
      -- 00: -                (unary minus)
      -- 01: ! ~              (not, bitwise complement)
      -- 02: * / %            (multiplication division modulo)
      -- 03: + -              (plus minus)
      -- 06: < <= > >=        (less/greater than or equal)
      -- 07: = == != <> LIKE  (equals, not equals, like)
      -- 08: &                (bitwise and)
      -- 09: ^                (bitwize xor)
      -- 10: |                (bitwize or)
      -- 11: NOT              (logical not)
      -- 12: &&, AND          (logical and)
      -- 13: XOR              (logical xor)
      -- 14: ||, OR           (logical or)
      -- 99:                  (default lowest priority)
      l_line VARCHAR2(4000);
      l_pos INTEGER;
      l_parenthesis BOOLEAN;
      l_found BOOLEAN;
      k_defined CONSTANT VARCHAR2(7) := 'defined';
   BEGIN
--sys.dbms_output.put_line('->eval'||p_level||'('||p_prec||','||p_line||')');
      IF p_level = 0 THEN
         -- Handled "defined" function before symbol substitution
         IF INSTR(p_line,k_defined)>0 THEN
            l_line := p_line;
            p_line := consume_white_spaces(l_line);
            l_count := 0;
            WHILE l_line IS NOT NULL LOOP
               l_count := l_count + 1;
               assert(l_count<10000,'Infinite loop detected!');
               l_char := SUBSTR(l_line,1,1);
               IF is_id(l_char) THEN
                  l_symbol := consume_identifier(l_line);
                  IF l_symbol = k_defined THEN
                     consume_white_spaces(l_line);
                     l_char := SUBSTR(l_line,1,1);
                     l_parenthesis := l_char = '(';
                     IF l_parenthesis THEN
                        l_line := SUBSTR(l_line,2);
                     END IF;
                     consume_white_spaces(l_line);
                     l_char := SUBSTR(l_line,1,1);
                     assert(is_id(l_char),'identifier expected after "defined"');
                     l_symbol := consume_identifier(l_line);
                     l_found := CASE WHEN exists_symbol(l_symbol) = 1 THEN TRUE ELSE FALSE END;
                     consume_white_spaces(l_line);
                     l_char := SUBSTR(l_line,1,1);
                     assert(NOT l_parenthesis OR l_char=')','closing ")" expected after "defined"');
                     IF l_parenthesis AND l_char = ')' THEN
                        l_line := SUBSTR(l_line,2);
                     END IF;
                     p_line := p_line || CASE WHEN l_found THEN ' 1 ' ELSE ' 0 ' END;
                  ELSE
                     p_line := p_line || l_symbol;
                  END IF;
               ELSIF is_string(l_char) THEN
                  p_line := p_line || consume_string(l_line);
               ELSE
                  -- Skip all characters until a white space, an identifier or a string is found
                  l_char := SUBSTR(l_line,1,1);
                  WHILE l_line IS NOT NULL AND NOT is_id(l_char) AND NOT is_ws(l_char) AND NOT is_string(l_char) LOOP
                     p_line := p_line || l_char;
                     l_line := SUBSTR(l_line,2);
                     l_char := SUBSTR(l_line,1,1);
                  END LOOP;
               END IF;
               p_line := p_line || consume_white_spaces(l_line);
            END LOOP;
         END IF;
         -- Substitute symbols before evaluating expression
         p_line := replace_symbols(p_line,TRUE);
      END IF;
      l_count := 0;
      consume_white_spaces(p_line);
      WHILE p_line IS NOT NULL LOOP
--sys.dbms_output.put_line('res before='||l_res);
         l_count := l_count + 1;
         assert(l_count<10000,'Infinite loop detected!');
         l_char := SUBSTR(p_line,1,1);
         l_char2 := SUBSTR(p_line,2,1);
         IF l_char = '=' AND l_char2 = '=' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 7;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN string_equal(remove_quotes(l_res),remove_quotes(l_val)) THEN 1 ELSE 0 END;
         ELSIF l_char = '=' THEN -- PL/SQL specific operator equivalent to ==
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 7;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN string_equal(remove_quotes(l_res),remove_quotes(l_val)) THEN 1 ELSE 0 END;
         ELSIF l_char = '<' AND l_char2 = '=' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 6;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF NOT is_string(l_res) OR NOT is_string(l_val) THEN
               l_res := CASE WHEN my_to_number(l_res) <= my_to_number(l_val) THEN 1 ELSE 0 END;
            ELSE
               l_res := CASE WHEN remove_quotes(l_res) <= remove_quotes(l_val) THEN 1 ELSE 0 END;
            END IF;
         ELSIF l_char = '>' AND l_char2 = '=' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 6;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF NOT is_string(l_res) OR NOT is_string(l_val) THEN
               l_res := CASE WHEN my_to_number(l_res) >= my_to_number(l_val) THEN 1 ELSE 0 END;
            ELSE
               l_res := CASE WHEN remove_quotes(l_res) >= remove_quotes(l_val) THEN 1 ELSE 0 END;
            END IF;
         ELSIF l_char = '!' AND l_char2 = '=' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 7;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN string_equal(remove_quotes(l_res),remove_quotes(l_val)) THEN 0 ELSE 1 END;
         ELSIF l_char = '<' AND l_char2 = '>' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 7;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN string_equal(remove_quotes(l_res),remove_quotes(l_val)) THEN 0 ELSE 1 END;
         ELSIF l_char = '&' AND l_char2 = '&' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 12;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN my_to_number(l_res) = 0 OR my_to_number(l_val) = 0 THEN 0 ELSE 1 END;
         ELSIF l_char = '|' AND l_char2 = '|' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||l_char2||'"');
            l_prec := 14;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,3);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF is_string(l_res) AND is_string(l_val) THEN
               l_res := '"'||remove_quotes(l_res)||remove_quotes(l_val)||'"'; -- concatenation
            ELSE
               l_res := CASE WHEN my_to_number(l_res) = 0 AND my_to_number(l_val) = 0 THEN 0 ELSE 1 END; -- or
            END IF;
         ELSIF l_char = '!' THEN
            assert(l_res IS NULL,'unexpected operator "'||l_char||'"');
            l_prec := 1;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := CASE WHEN my_to_number(l_val) = 0 THEN 1 ELSE 0 END;
         ELSIF l_char = '~' THEN
            assert(l_res IS NULL,'unexpected operator "'||l_char||'"');
            l_prec := 1;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := bitnot(my_to_number(l_val));
         ELSIF l_char IN ('+') THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 3;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF is_string(l_res) AND is_string(l_val) THEN
               l_res := '"'||remove_quotes(l_res)||remove_quotes(l_val)||'"'; -- concatenation
            ELSE
               l_res := my_to_number(l_res) + my_to_number(l_val); -- addition
            END IF;
         ELSIF l_char IN ('-') THEN
            IF l_res IS NULL THEN
               l_prec := 0; -- unary operator
               assert(p_prec != 0,'Unexpected argument to unary minus operator');
            ELSE
               l_prec := 3; -- binary operator
            END IF;
          --assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF l_res IS NULL THEN
               l_res := 0 - my_to_number(l_val);
            ELSE
               l_res := my_to_number(l_res) - my_to_number(l_val);
            END IF;
         ELSIF l_char IN ('*') THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 2;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := my_to_number(l_res) * my_to_number(l_val);
         ELSIF l_char IN ('/') THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 2;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := TRUNC(my_to_number(l_res) / my_to_number(l_val));
         ELSIF l_char IN ('%') THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 2;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := MOD(my_to_number(l_res),my_to_number(l_val));
         ELSIF l_char = '>' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 6;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF NOT is_string(l_res) OR NOT is_string(l_val) THEN
               l_res := CASE WHEN my_to_number(l_res) > my_to_number(l_val) THEN 1 ELSE 0 END;
            ELSE
               l_res := CASE WHEN remove_quotes(l_res) > remove_quotes(l_val) THEN 1 ELSE 0 END;
            END IF;
         ELSIF l_char = '&' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 8;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := BITAND(my_to_number(l_res),my_to_number(l_val));
         ELSIF l_char = '^' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 9;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := bitxor(my_to_number(l_res),my_to_number(l_val));
         ELSIF l_char = '|' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 10;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            l_res := bitor(my_to_number(l_res),my_to_number(l_val));
         ELSIF l_char = '<' THEN
            assert(l_res IS NOT NULL,'unexpected operator "'||l_char||'"');
            l_prec := 6;
            EXIT WHEN l_prec >= p_prec;
            p_line := SUBSTR(p_line,2);
            l_val := evaluate_expression(p_line,p_level+1,l_prec);
            IF NOT is_string(l_res) OR NOT is_string(l_val) THEN
               l_res := CASE WHEN my_to_number(l_res) < my_to_number(l_val) THEN 1 ELSE 0 END;
            ELSE
               l_res := CASE WHEN remove_quotes(l_res) < remove_quotes(l_val) THEN 1 ELSE 0 END;
            END IF;
         ELSIF l_char = '(' THEN
            assert(l_res IS NULL,'unexpected "("');
            p_line := SUBSTR(p_line,2);
            l_res := evaluate_expression(p_line,p_level+1);
            consume_white_spaces(p_line);
            assert(SUBSTR(p_line,1,1)=')','"(" without matching ")"!');
            p_line := SUBSTR(p_line,2);
         ELSIF l_char = ')' THEN
            assert(l_res IS NOT NULL AND p_level>0, 'unexpected ")"');
            EXIT; -- do not consume parenthesis (will be done by calling code)
         ELSIF is_digit(l_char) OR (l_char = '-' AND is_digit(l_char2) AND l_res IS NULL) THEN
            -- number
            l_val := consume_integer(p_line);
            assert(l_res IS NULL,'unexpected number: '||l_val);
            l_res := l_val;
         ELSIF is_id(l_char) THEN
            l_symbol := UPPER(get_identifier(p_line)); -- get but do not consume
            IF l_symbol = 'LIKE' THEN
               assert(l_res IS NOT NULL,'unexpected function: "'||l_symbol||'"');
               l_prec := 7;
               EXIT WHEN l_prec >= p_prec;
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               l_val := evaluate_expression(p_line,p_level+1,l_prec);
               l_res := CASE WHEN remove_quotes(l_res) LIKE remove_quotes(l_val) THEN 1 ELSE 0 END;
            ELSIF l_symbol = 'NOT' THEN
               assert(l_res IS NULL,'unexpected function: "'||l_symbol||'"');
               l_prec := 11;
               EXIT WHEN l_prec >= p_prec;
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               l_val := evaluate_expression(p_line,p_level+1,l_prec);
               l_res := CASE WHEN my_to_number(l_val) = 0 THEN 1 ELSE 0 END;
            ELSIF l_symbol = 'AND' THEN
               assert(l_res IS NOT NULL,'unexpected function: "'||l_symbol||'"');
               l_prec := 12;
               EXIT WHEN l_prec >= p_prec;
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               l_val := evaluate_expression(p_line,p_level+1,l_prec);
               l_res := CASE WHEN my_to_number(l_res) = 0 OR my_to_number(l_val) = 0 THEN 0 ELSE 1 END;
            ELSIF l_symbol = 'XOR' THEN
               assert(l_res IS NOT NULL,'unexpected function: "'||l_symbol||'"');
               l_prec := 13;
               EXIT WHEN l_prec >= p_prec;
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               l_val := evaluate_expression(p_line,p_level+1,l_prec);
               l_res := CASE WHEN (my_to_number(l_res) = 0 AND my_to_number(l_val) != 0) OR (my_to_number(l_res) != 0 AND my_to_number(l_val) = 0 ) THEN 1 ELSE 0 END;
            ELSIF l_symbol = 'OR' THEN
               assert(l_res IS NOT NULL,'unexpected function: "'||l_symbol||'"');
               l_prec := 14;
               EXIT WHEN l_prec >= p_prec;
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               l_val := evaluate_expression(p_line,p_level+1,l_prec);
               l_res := CASE WHEN my_to_number(l_res) = 0 AND my_to_number(l_val) = 0 THEN 0 ELSE 1 END;
            ELSIF l_symbol IN ('INITCAP','LOWER','STRLWR','UPPER','STRUPR','LENGTH','STRLEN','TO_CHAR','TO_NUMBER') THEN
               assert(l_res IS NULL,'unexpected call to "'||l_symbol||'" function');
               p_line := SUBSTR(p_line,LENGTH(l_symbol)+1);
               consume_white_spaces(p_line);
               assert(SUBSTR(p_line,1,1)='(','Missing "(" after "'||l_symbol||'" function call');
               p_line := SUBSTR(p_line,2);
               l_val := evaluate_expression(p_line,p_level+1);
               IF l_symbol = 'TO_CHAR' THEN
                  assert(l_val IS NULL OR NOT is_string(l_val),'Number expected as argument of "'||l_symbol||'" function');
               ELSE
                  assert(l_val IS NULL OR is_string(l_val),'String expected as argument of "'||l_symbol||'" function');
               END IF;
               consume_white_spaces(p_line);
               assert(SUBSTR(p_line,1,1)=')','"(" without matching ")"!');
               p_line := SUBSTR(p_line,2);
               IF l_symbol = 'INITCAP' THEN
                  l_res := INITCAP(l_val);
               ELSIF l_symbol IN ('LOWER','STRLWR') THEN
                  l_res := LOWER(l_val);
               ELSIF l_symbol IN ('UPPER','STRUPR') THEN
                  l_res := UPPER(l_val);
               ELSIF l_symbol IN ('LENGTH','STRLEN') THEN
                  l_res := LENGTH(remove_quotes(l_val));
               ELSIF l_symbol = 'TO_CHAR' THEN
                  l_res := '"'||l_val||'"';
               ELSIF l_symbol = 'TO_NUMBER' THEN
                  l_res := my_to_number(l_val);
               ELSE
                  assert(FALSE,'Internal error: "'||l_symbol||'" function is not supported!');
               END IF;
            ELSE
               l_symbol := consume_identifier(p_line);
               assert(l_res IS NULL,'unexpected identifier: '||l_symbol);
               -- identifiers that are not macros are considered to be the number zero
               l_res := 0;
--sys.dbms_output.put_line('symbol '||l_symbol||' evaluated to 0');
            END IF;
         ELSIF is_string(l_char) THEN
            l_symbol := consume_string(p_line);
            assert(l_res IS NULL,'unexpected string: '||l_symbol);
            l_res := l_symbol;
         ELSE
            assert(FALSE, 'unexpected character "'||l_char||'"');
         END IF;
         consume_white_spaces(p_line);
      END LOOP;
--sys.dbms_output.put_line('res after='||l_res);
      consume_white_spaces(p_line);
--sys.dbms_output.put_line('<-eval'||p_level||'('||p_prec||','||p_line||'): '||l_res);
      RETURN NVL(l_res,1);
   END;
   ---
   -- Undefine symbol
   ---
   PROCEDURE undefine_symbol (
      t_sym_idx IN OUT symbol_index
     ,p_name IN VARCHAR2
   )
   IS
      l_len INTEGER;
      t_sym symbol_table;
      r_sym symbol_record;
      l_idx INTEGER;
      l_name varchar2(100);
      l_msg varchar2(100) := 'undefine_symbol(): ';
   BEGIN
      del_symbol(p_name);
      l_name := p_name;
      assert(l_name IS NOT NULL, l_msg||'symbol is missing');
      l_len := LENGTH(l_name);
      IF t_sym_idx.EXISTS(l_len) THEN
         t_sym := t_sym_idx(l_len);
         l_idx := t_sym.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            r_sym := t_sym(l_idx);
            IF r_sym.NAME = l_name THEN
               -- found => drop
               t_sym_idx(l_len).DELETE(l_idx);
               RETURN;
            END IF;
            l_idx := t_sym.NEXT(l_idx);
         END LOOP;
      END IF;
      -- not found, return silently
   END;
   ---
   -- Undefine symbol
   ---
   PROCEDURE undefine_symbol (
      p_line IN OUT VARCHAR2
   )
   IS
      l_name varchar2(100);
   BEGIN
      l_name := consume_word(p_line);
      undefine_symbol(t_sym_idx,l_name);
   END;
   ---
   -- Get symbols (for debug)
   ---
   FUNCTION my_get_symbol_table
   RETURN sys.dbms_sql.varchar2a
   IS
      l_len INTEGER;
      r_sym symbol_record;
      l_name varchar2(100);
      t_lines sys.dbms_sql.varchar2a;
      l_msg varchar2(100) := 'my_get_symbol_table(): ';
   BEGIN
      l_len := t_sym_idx.LAST;
      WHILE l_len IS NOT NULL LOOP
         l_name := t_sym_idx(l_len).FIRST;
         WHILE l_name IS NOT NULL LOOP
            r_sym := t_sym_idx(l_len)(l_name);
            t_lines(t_lines.COUNT+1) := r_sym.NAME||'='||r_sym.value;
            l_name := t_sym_idx(l_len).NEXT(l_name);
         END LOOP;
         l_len := t_sym_idx.PRIOR(l_len);
      END LOOP;
      RETURN t_lines;
   END;
--#begin public
   ---
   -- Get symbols (for debug)
   ---
   FUNCTION get_symbol_table
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
   BEGIN
      t_lines := my_get_symbol_table;
      FOR i IN 1..t_lines.COUNT LOOP
         pipe ROW(t_lines(i));
      END LOOP;
   END;
--#begin public
   ---
   -- Print symbols (for debug)
   ---
   PROCEDURE print_symbol_table
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
   BEGIN
      sys.dbms_output.put_line('***Old***');
      t_lines := my_get_symbol_table;
      FOR i IN 1..t_lines.COUNT LOOP
         log(t_lines(i));
      END LOOP;
      sys.dbms_output.put_line('***New***');
      FOR i IN 1..t_sym_ptr.COUNT LOOP
         sys.dbms_output.put_line(t_sym_name(t_sym_ptr(i))||'='||t_sym_value(t_sym_ptr(i)));
      END LOOP;
      sys.dbms_output.put_line('***End***');
      sys.dbms_output.put('ptr: ');
      FOR i IN 1..t_sym_ptr.COUNT LOOP
         sys.dbms_output.put(CASE WHEN i>0 THEN ', ' END||i||':'||t_sym_ptr(i));
      END LOOP;
      sys.dbms_output.put_line('');
      sys.dbms_output.put('len: ');
      FOR i IN 1..t_sym_len.COUNT LOOP
         sys.dbms_output.put(CASE WHEN i>0 THEN ', ' END||i||':'||t_sym_len(i));
      END LOOP;
      sys.dbms_output.put_line('');
      sys.dbms_output.put('name: ');
      FOR i IN 1..t_sym_name.COUNT LOOP
         sys.dbms_output.put(CASE WHEN i>0 THEN ', ' END||i||':'||t_sym_name(i));
      END LOOP;
      sys.dbms_output.put_line('');
      sys.dbms_output.put('param(count): ');
      FOR i IN 1..t_sym_param.COUNT LOOP
         sys.dbms_output.put(CASE WHEN i>0 THEN ', ' END||i||':'||t_sym_param(i).COUNT);
      END LOOP;
      sys.dbms_output.put_line('');
      RETURN;
   END;
   ---
   -- Print reverse symbols table
   ---
   FUNCTION my_get_reverse_symbol_table (
      t_sym_idx symbol_index
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      t_tmp_idx symbol_index;
      r_sym symbol_record;
      l_len INTEGER;
      l_name varchar2(100);
      t_lines sys.dbms_sql.varchar2a;
      l_msg varchar2(100) := 'print_reverse_symbol_table(): ';
   BEGIN
      -- Build the inverse table
      l_len := t_sym_idx.LAST;
      WHILE l_len IS NOT NULL LOOP
         l_name := t_sym_idx(l_len).FIRST;
         WHILE l_name IS NOT NULL LOOP
            r_sym := t_sym_idx(l_len)(l_name);
            IF r_sym.value IS NOT NULL AND NOT (SUBSTR(r_sym.NAME,1,2) = '__' AND SUBSTR(r_sym.NAME,-1,2) = '__') THEN
               define_symbol(t_tmp_idx,r_sym.value,r_sym.NAME,FALSE);
            END IF;
            l_name := t_sym_idx(l_len).NEXT(l_name);
         END LOOP;
         l_len := t_sym_idx.PRIOR(l_len);
      END LOOP;
      -- Print the inverse table
      l_len := t_tmp_idx.LAST;
      WHILE l_len IS NOT NULL LOOP
         l_name := t_tmp_idx(l_len).FIRST;
         WHILE l_name IS NOT NULL LOOP
            r_sym := t_tmp_idx(l_len)(l_name);
            t_lines(t_lines.COUNT+1) := '#define '||r_sym.NAME||' '||r_sym.value;
            l_name := t_tmp_idx(l_len).NEXT(l_name);
         END LOOP;
         l_len := t_tmp_idx.PRIOR(l_len);
      END LOOP;
      RETURN t_lines;
   END;
--#begin public
   ---
   -- Get reverse symbols (for debug)
   ---
   FUNCTION get_reverse_symbol_table
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
   BEGIN
      t_lines := my_get_reverse_symbol_table(t_sym_idx);
      FOR i IN 1..t_lines.COUNT LOOP
         pipe ROW(t_lines(i));
      END LOOP;
      RETURN;
   END;
--#begin public
   ---
   -- Get reverse symbols (for debug)
   ---
   FUNCTION get_prev_reverse_symbol_table
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
      t_sym_idx_tmp symbol_index;
   BEGIN
      t_sym_idx_tmp := t_sym_idx;
      t_sym_idx := t_sym_idx_prev;
      t_lines := my_get_reverse_symbol_table(t_sym_idx_prev);
      t_sym_idx := t_sym_idx_tmp;
      FOR i IN 1..t_lines.COUNT LOOP
         pipe ROW('--@'||t_lines(i));
      END LOOP;
      RETURN;
   END;
--#begin public
   ---
   -- Print reverse symbols (for debug)
   ---
   PROCEDURE print_reverse_symbol_table
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
   BEGIN
      t_lines := my_get_reverse_symbol_table(t_sym_idx);
      FOR i IN 1..t_lines.COUNT LOOP
         log(t_lines(i));
      END LOOP;
   END;
   ---
   -- Push flag
   ---
   PROCEDURE push_flag (
      p_flag IN INTEGER
   )
   IS
   BEGIN
      t_flags(t_flags.COUNT+1) := p_flag;
   END;
   ---
   -- Pop flag
   ---
   FUNCTION pop_flag
   RETURN INTEGER
   IS
      l_flag INTEGER;
      l_msg varchar2(100) := 'pop_flag(): ';
   BEGIN
      assert(t_flags.COUNT>0,l_msg||'flags stack is empty');
      l_flag := t_flags(t_flags.COUNT);
      t_flags.DELETE(t_flags.COUNT);
      RETURN l_flag;
   END;
   ---
   -- Get top flag
   ---
   FUNCTION get_top_flag
   RETURN INTEGER
   IS
      l_msg varchar2(100) := 'get_top_flag(): ';
   BEGIN
      assert(t_flags.COUNT>0,l_msg||'flags stack is empty');
      RETURN t_flags(t_flags.COUNT);
   END;
   ---
   -- Update top flag
   ---
   PROCEDURE update_top_flag (
      p_flag IN INTEGER
   )
   IS
      l_msg varchar2(100) := 'update_top_flag(): ';
   BEGIN
      assert(t_flags.COUNT>0,l_msg||'flags stack is empty');
      t_flags(t_flags.COUNT) := p_flag;
   END;
   ---
   -- Trim line
   ---
   PROCEDURE trim_line (
      p_line IN OUT VARCHAR2
   )
   IS
   BEGIN
      -- Remove trailing spaces, tabs, CR, LF, ...
      WHILE SUBSTR(p_line,-1,1) IN (' ',CHR(9),CHR(10),CHR(13)) LOOP
         p_line := SUBSTR(p_line,1,LENGTH(p_line)-1);
      END LOOP;
   END;
   ---
   -- Check if we are in first iteration of all existing loops
   ---
   FUNCTION first_loop_iteration
   RETURN BOOLEAN
   IS
      r_var loopvar_record;
      l_msg varchar2(100) := 'first_loop_iteration(): ';
   BEGIN
      FOR i IN 1..t_loopvar.COUNT LOOP
         r_var := t_loopvar(i);
         IF r_var.last_row_count > 0 THEN
            RETURN FALSE;
         END IF;
      END LOOP;
      RETURN TRUE;
   END;
   ---
   -- Check if a loop variable is referenced
   ---
   FUNCTION loopvar_referenced (
      p_line IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      r_var loopvar_record;
      l_msg varchar2(100) := 'loopvar_referenced(): ';
   BEGIN
      FOR i IN 1..t_loopvar.COUNT LOOP
         r_var := t_loopvar(i);
         IF INSTR(p_line,r_var.NAME) > 0 THEN
            RETURN TRUE;
         END IF;
      END LOOP;
      RETURN FALSE;
   END;
   ---
   -- Tell if code for reverse generation must be generated
   ---
   FUNCTION must_generate_reverse
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN (g_reversible OR g_macro) AND first_loop_iteration;
   END;
   ---
   -- Generate given reverse statement
   ---
   PROCEDURE generate_reverse (
      p_statement IN VARCHAR2
   )
   IS
   BEGIN
      IF must_generate_reverse THEN
         t_lines_out(t_lines_out.COUNT+1) := p_statement;
      END IF;
   END;
   ---
   -- Fetch rows
   ---
   PROCEDURE fetch_rows (
      r_var IN OUT loopvar_record
   )
   IS
      l_col_name varchar2(100);
      l_char VARCHAR2(32767);
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      g_datetime_mask VARCHAR2(40) := 'DD.MM.YYYY HH24:MI:SS';  -- Display date and time in this format
      g_timestamp_mask VARCHAR2(40) := 'DD.MM.YYYY HH24:MI:SS:FF';  -- Display timestamps in this format
   BEGIN
--      sys.dbms_output.put_line('-> fetch_rows('||r_var.NAME||'), '||r_var.last_row_count||' fetched so far');
      -- Fetch one row
      r_var.row_count := sys.dbms_sql.fetch_rows(r_var.l_cursor);
      r_var.last_row_count := sys.dbms_sql.last_row_count;
      define_symbol(t_sym_idx,'SQL%ROWCOUNT',TRIM(TO_CHAR(NVL(r_var.row_count,0))),FALSE);
      define_symbol(t_sym_idx,'SQL%LASTROWCOUNT',TRIM(TO_CHAR(NVL(r_var.last_row_count,0))),FALSE);
      IF r_var.row_count > 0 THEN
       --r_var.last_row_count := r_var.last_row_count + 1;
       --sys.dbms_output.put_line('********** Record #'||r_var.last_row_count||' **********');
         FOR i IN 1..r_var.t_desc.COUNT LOOP
            l_col_name := r_var.t_desc(i).col_name;
          --l_col_name := r_var.t_col(i);
            IF r_var.t_desc(i).col_type IN (sys.dbms_sql.varchar2_type,sys.dbms_sql.char_type) THEN
               sys.dbms_sql.column_value(r_var.l_cursor,i,l_char);
            ELSIF r_var.t_desc(i).col_type = sys.dbms_sql.number_type THEN
               sys.dbms_sql.column_value(r_var.l_cursor,i,l_number);
               l_char := TO_CHAR(l_number);
            ELSIF r_var.t_desc(i).col_type =  sys.dbms_sql.date_type THEN
               sys.dbms_sql.column_value(r_var.l_cursor,i,l_date);
               l_char := REPLACE(TO_CHAR(l_date,g_datetime_mask),' 00:00:00');
            ELSIF r_var.t_desc(i).col_type = sys.dbms_sql.timestamp_type THEN
               sys.dbms_sql.column_value(r_var.l_cursor,i,l_timestamp);
               l_char := TO_CHAR(l_timestamp,g_timestamp_mask);
            ELSE
               l_char := '<unsupported data type '||r_var.t_desc(i).col_type||'>';
             --raise_application_error(-20000,'Unsupported data type "'||r_var.t_desc(i).col_type||'" for column "'||l_col_name||'"');
            END IF;
            l_char := RTRIM(l_char);
            define_symbol(t_sym_idx,r_var.NAME||'.'||l_col_name,l_char,FALSE);
          --sys.dbms_output.put_line(l_col_name||'='||NVL(l_char,'NULL'));
            l_col_name := r_var.t_desc(i).col_name;
         END LOOP;
      END IF;
--      sys.dbms_output.put_line('<- fetch_rows('||r_var.NAME||'): '||r_var.row_count||' row fetched, '||r_var.last_row_count||' fetched so far');
   END;
   ---
   -- Handle for loop
   ---
   PROCEDURE handle_for (
      p_line IN VARCHAR
    , l_line_no IN INTEGER
   )
   IS
      l_line VARCHAR2(4000) := p_line;
      r_var loopvar_record;
      l_msg varchar2(100) := 'handle_for(): ';
      l_count INTEGER;
      PROCEDURE define_columns
      IS
         l_char VARCHAR2(32767);
         l_number NUMBER;
         l_date DATE;
         l_timestamp TIMESTAMP;
      BEGIN
         FOR i IN 1..r_var.t_desc.COUNT LOOP
          --sys.dbms_output.put_line(i||': '||r_var.t_desc(i).col_name||' '||r_var.t_desc(i).col_type||' '||r_var.t_desc(i).col_max_len);
            IF r_var.t_desc(i).col_type IN (sys.dbms_sql.varchar2_type,sys.dbms_sql.char_type) THEN
               sys.dbms_sql.define_column(r_var.l_cursor,i,l_char,r_var.t_desc(i).col_max_len);
            ELSIF r_var.t_desc(i).col_type = sys.dbms_sql.number_type THEN
               sys.dbms_sql.define_column(r_var.l_cursor,i,l_number);
            ELSIF r_var.t_desc(i).col_type = sys.dbms_sql.date_type THEN
               sys.dbms_sql.define_column(r_var.l_cursor,i,l_date);
            ELSIF r_var.t_desc(i).col_type = sys.dbms_sql.timestamp_type /*Timestamp_With_TZ_Type,Timestamp_With_Local_TZ_type*/ THEN
               sys.dbms_sql.define_column(r_var.l_cursor,i,l_timestamp);
            ELSE
               NULL;
             --raise_application_error(-20000,'Unsupported data type "'||r_var.t_desc(i).col_type||'" for column "'||l_col_name||'"');
            END IF;
         END LOOP;
      END;
   BEGIN
--      sys.dbms_output.put_line('-> handle_for('||p_line||')');
      l_line := replace_symbols(l_line,FALSE); -- lower/upper limit could be a variable
      r_var.NAME := consume_word(l_line);
      IF SUBSTR(r_var.NAME,1,1)='$' THEN
      -- process statement like: for $i = 1 to 10
         assert(LENGTH(r_var.NAME)>1, l_msg||'missing loop variable name after "$"');
         consume_keyword(l_line,'=',l_msg||'"=" expected');
         r_var.min_val := consume_integer(l_line);
         assert(r_var.min_val IS NOT NULL,l_msg||'integer expected after "="');
         consume_keyword(l_line,'to',l_msg||'"to" expected');
         r_var.max_val := consume_integer(l_line);
         assert(r_var.max_val IS NOT NULL,l_msg||'integer exepected after "to"');
       --assert(r_var.min_val <= r_var.max_val, l_msg||'min value must be <= max value in loop statement');
         r_var.cur_val := r_var.min_val;
         consume_white_spaces(l_line);
         IF SUBSTR(l_line,1,4) = 'step' THEN
            consume_keyword(l_line,'step','');
            consume_white_spaces(l_line);
            r_var.step := consume_integer(l_line);
            assert(r_var.max_val IS NOT NULL,l_msg||'integer exepected after "step"');
         ELSE
            r_var.step := 1;
         END IF;
         assert(r_var.step!=0,l_msg||'step increment cannot be zero');
         -- skip all lines till #next
         g_flag := 0;
         push_flag(g_flag);
         g_cnt := g_cnt + 1;
         r_var.last_row_count := -1; -- loop not started yet
      ELSE
      -- process statement like: for col in (select column_name from user_tab_columns where table_name=...)
         consume_white_spaces(l_line);
         assert(UPPER(SUBSTR(l_line,1,2)) = 'IN','IN expected');
         l_line := SUBSTR(l_line,3);
         consume_keyword(l_line,'(',l_msg||'"(" expected');
         assert(SUBSTR(l_line,-1,1)=')','missing ending ")"');
         r_var.stmt := SUBSTR(l_line,1,LENGTH(l_line)-1);
         r_var.l_cursor := sys.dbms_sql.open_cursor;
         sys.dbms_sql.parse(r_var.l_cursor,r_var.stmt,sys.dbms_sql.native);
         sys.dbms_sql.describe_columns2(r_var.l_cursor,r_var.row_count,r_var.t_desc);
         define_columns;
         l_count := sys.dbms_sql.execute(r_var.l_cursor);
         -- skip all lines till #next
         g_flag := 0;
         push_flag(g_flag);
         g_cnt := g_cnt + 1;
         r_var.last_row_count := -1; -- no row fetched yet
      END IF;
      r_var.line_no := l_line_no;
      -- Push loop variable to the stack
      t_loopvar(t_loopvar.COUNT+1) := r_var;
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(r_var.l_cursor) THEN
            sys.dbms_sql.close_cursor(r_var.l_cursor);
         END IF;
         RAISE;
   END;
   ---
   -- Handle next
   ---
   PROCEDURE handle_next (
      p_line IN OUT VARCHAR
    , l_line_no IN OUT INTEGER
   )
   IS
      l_line VARCHAR2(4000) := p_line;
      l_var VARCHAR2(100);
      r_var loopvar_record;
      l_msg varchar2(100) := 'hanlde_next(): ';
   BEGIN
--      sys.dbms_output.put_line('-> handle_next('||p_line||')');
      -- process statement like: next $i
      l_var := consume_word(l_line);
    --assert(l_var IS NOT NULL,'missing loop variable after #next');
      assert(t_loopvar.COUNT>0,l_msg||'#next found without matching #for');
      -- Pop loop variable from the stack
      r_var := t_loopvar(t_loopvar.LAST);
      t_loopvar.DELETE(t_loopvar.LAST);
      assert(l_var IS NULL OR r_var.NAME=l_var,l_msg||'variable mismatch between #next and #for');
      IF SUBSTR(r_var.NAME,1,1) = '$' THEN
         IF r_var.last_row_count < 0
         THEN
            -- terminate skip of lines since #for
            assert(t_flags.COUNT>0,'#next found without matching #for');
            IF g_cnt>0 THEN
               g_cnt := g_cnt - 1;
            END IF;
            g_flag := pop_flag;
            r_var.last_row_count := 0;
         ELSE
            -- Set next value
            r_var.cur_val := r_var.cur_val + r_var.step;
         END IF;
         -- Check if current value is out of loop range
         IF (r_var.step > 0 AND r_var.cur_val > r_var.max_val)
         OR (r_var.step < 0 AND r_var.cur_val < r_var.min_val)
         THEN
            IF r_var.last_row_count > 0 THEN
               generate_reverse('--#endif 0');
            END IF;
            -- Limit reached => undefine symbol for variable
            undefine_symbol(t_sym_idx,r_var.NAME);
            RETURN;
         ELSE
            -- Update loop counter
            r_var.last_row_count := r_var.last_row_count + 1;
            -- (re)define symbol for variable
            define_symbol(t_sym_idx,r_var.NAME,r_var.cur_val,FALSE);
            IF r_var.last_row_count = 1 THEN
               generate_reverse('--#if 0');
            END IF;
         END IF;
      ELSE
         IF r_var.last_row_count < 0
         THEN
            -- terminate skip of lines since #for
            assert(t_flags.COUNT>0,'#next found without matching #for');
            IF g_cnt>0 THEN
               g_cnt := g_cnt - 1;
            END IF;
            g_flag := pop_flag;
            r_var.last_row_count := 0;
         END IF;
         fetch_rows(r_var);
         IF r_var.last_row_count = 1 AND r_var.row_count = 1 THEN
            generate_reverse('--#if 0');
         END IF;
         -- End reached?
         IF r_var.row_count = 0 THEN
            IF r_var.last_row_count > 0 THEN
               generate_reverse('--#endif 0');
            END IF;
            -- undefine symbols for each fetched column
            FOR i IN 1..r_var.t_desc.COUNT LOOP
               undefine_symbol(t_sym_idx,r_var.NAME||'.'||r_var.t_desc(i).col_name);
            END LOOP;
            sys.dbms_sql.close_cursor(r_var.l_cursor);
            t_loopvar.DELETE(t_loopvar.LAST);
            RETURN;
         END IF;
      END IF;
      -- Push loop variable back to the stack
      t_loopvar(t_loopvar.COUNT+1) := r_var;
      -- Jump back to #for
      l_line_no := r_var.line_no;
   END;
   ---
   -- Execute function
   ---
   PROCEDURE execute_function (
      p_line IN OUT VARCHAR2
   )
   IS
      l_cursor INTEGER;
      l_count INTEGER;
      l_line VARCHAR2(4000) := replace_symbols(p_line,FALSE);
      l_line2 VARCHAR2(4000);
      l_msg varchar2(100) := 'execute_function(): ';
      t_lines_in sys.dbms_sql.varchar2a;
   BEGIN
      assert(l_line IS NOT NULL, l_msg||'no function to execute');
--sys.dbms_output.put_line('-> execute_function('||p_line||')');
      l_cursor := sys.dbms_sql.open_cursor;
      sys.dbms_sql.parse(l_cursor,'SELECT column_value FROM TABLE('||l_line||')',sys.dbms_sql.native);
      sys.dbms_sql.define_column(l_cursor,1,l_line2,4000);
      l_count := sys.dbms_sql.execute(l_cursor);
      l_count := sys.dbms_sql.fetch_rows(l_cursor);
      WHILE l_count > 0 LOOP
         sys.dbms_sql.column_value(l_cursor,1,l_line2);
         t_lines_in(t_lines_in.COUNT+1) := l_line2;
         l_count := sys.dbms_sql.fetch_rows(l_cursor);
      END LOOP;
      sys.dbms_sql.close_cursor(l_cursor);
      process_lines(t_lines_in,'<output execution of>',l_line);
--sys.dbms_output.put_line('<- execute_function('||p_line||')');
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         RAISE;
   END;
   ---
   -- Process lines
   ---
   PROCEDURE process_lines (
      t_lines_in IN OUT sys.dbms_sql.varchar2a
    , p_object_type IN VARCHAR2 := NULL
    , p_object_name IN VARCHAR2 := NULL
   ) IS
      l_line_no INTEGER;
      l_first_line_no INTEGER;
      l_line_no2 INTEGER;
      l_line VARCHAR2(4000);
      l_line_sav VARCHAR2(4000);
      l_name varchar2(100);
      l_pos INTEGER;
      l_msg varchar2(100) := 'process_lines(): ';
      l_old_object_type VARCHAR2(100);
      l_old_object_name VARCHAR2(100);
      l_found BOOLEAN;
      -- Generate reverse statements (for a range of lines)
      PROCEDURE generate_reverse_range (
         p_prefix IN VARCHAR2
       , p_line_no_from IN INTEGER
       , p_line_no_to IN INTEGER
      )
      IS
      BEGIN
         IF must_generate_reverse THEN
            FOR i IN p_line_no_from..p_line_no_to LOOP
               t_lines_out(t_lines_out.COUNT+1) := p_prefix||t_lines_in(i);
            END LOOP;
         END IF;
      END;
   BEGIN
      l_line_no := t_lines_in.FIRST;
      -- Save system symbols
      l_old_object_type := get_symbol_value(gk_object_type_sym);
      l_old_object_name := get_symbol_value(gk_object_name_sym);
      -- Set system symbols
    --define_symbol(t_sym_idx, '__'||'LINE__',TRIM(TO_CHAR(l_line_no)),FALSE);$$$
      define_symbol(t_sym_idx, gk_object_type_sym, UPPER(p_object_type),FALSE);
      define_symbol(t_sym_idx, gk_object_name_sym, UPPER(p_object_name),FALSE);
      define_symbol(t_sym_idx, gk_file_sym,UPPER(p_object_type||' '||p_object_name),FALSE); -- for C precompiler compatibility
      -- While there is a line to process
      WHILE l_line_no IS NOT NULL
      LOOP
         l_first_line_no := l_line_no;
         l_line := t_lines_in(l_line_no);
--sys.dbms_output.put_line(p_object_type||' '||p_object_name||':'||l_line_no||'('||g_cnt||'): '||l_line);
--log(l_line_no||':'||l_line);
         -- Trim line
         trim_line(l_line);
         -- Merge continued lines into long lines (exception those related to reverse generation)
         WHILE SUBSTR(l_line,-1,1) = '\' AND SUBSTR(l_line,1,3) != '--@' LOOP
            -- Remove ending backslash
            l_line := SUBSTR(l_line,1,LENGTH(l_line)-1);
            -- Merge next line if it exists
            IF t_lines_in.NEXT(l_line_no) IS NOT NULL THEN
               l_line_no := t_lines_in.NEXT(l_line_no);
               -- Merge next line with the current one (with no space)
               l_line := l_line || t_lines_in(l_line_no);
               trim_line(l_line);
            END IF;
         END LOOP;
         -- Remove trailing comments
         l_pos := INSTR(l_line,'/'||'/');
         IF l_pos > 0 THEN
            l_line := SUBSTR(l_line,1,l_pos-1);
            trim_line(l_line);
         END IF;
         -- Process macro directives
         IF SUBSTR(l_line,1,3) = '--#' OR SUBSTR(l_line,1,1) = '#' THEN
            -- Generate reverse statement (exception for internal ones)
            IF NOT ends_with(l_line,'#internal') THEN
               generate_reverse_range('--@',l_first_line_no,l_line_no);
            END IF;
            -- Consume # or --#
            IF SUBSTR(l_line,1,3) = '--#' THEN
               l_line := SUBSTR(l_line,4);
            ELSE
               l_line := SUBSTR(l_line,2);
            END IF;
            consume_white_spaces(l_line); -- ws allowed between # and macro name
            IF starts_with(l_line,'for') THEN
               l_name := consume_word(l_line);
--               IF g_cnt = 0 THEN
                  handle_for(l_line,l_line_no);
--               END IF;
            ELSIF starts_with(l_line,'next') OR starts_with(l_line,'endfor') THEN
               l_name := consume_word(l_line);
--               IF g_cnt = 0 THEN
                  handle_next(l_line,l_line_no);
--               END IF;
            ELSIF starts_with(l_line,'execute') THEN
               l_name := consume_word(l_line);
               IF g_cnt = 0 OR must_generate_reverse THEN
                  generate_reverse('--#if 0');
                  execute_function(l_line);
                  generate_reverse('--#endif 0');
               END IF;
            ELSIF starts_with(l_line,'include') THEN
               l_name := consume_word(l_line);
               IF g_cnt = 0 OR must_generate_reverse THEN
--                  generate_reverse('--#if 0');
                  DECLARE
                     t_lines sys.dbms_sql.varchar2a;
                     l_idx INTEGER;
                     l_idx2 INTEGER;
                  BEGIN
                     t_lines(1) := '#pragma noreversible #internal';
                     include_source(l_line, t_lines);
                     t_lines(t_lines.COUNT+1) := '#pragma '||CASE WHEN NOT g_reversible THEN 'no' END ||'reversible #internal'; 
                     l_idx := t_lines_in.NEXT(l_line_no);
                     t_lines_in.DELETE(l_line_no);
                     WHILE l_idx IS NOT NULL LOOP
                        t_lines(t_lines.COUNT+1) := t_lines_in(l_idx);
                        l_idx2 := t_lines_in.NEXT(l_idx);
                        t_lines_in.DELETE(l_idx);
                        l_idx := l_idx2;
                     END LOOP;
                     l_idx := l_line_no;
                     l_idx2 := t_lines.FIRST;
                     WHILE l_idx2 IS NOT NULL LOOP
                        t_lines_in(l_idx) := t_lines(l_idx2);
                        l_idx := l_idx + 1;
                        l_idx2 := t_lines.NEXT(l_idx2);
                     END LOOP;
                     GOTO next_line;
                  END;
--                  generate_reverse('--#endif 0');
               END IF;
            ELSIF starts_with(l_line,'eval') THEN
               l_name := consume_word(l_line);
               IF g_cnt = 0 THEN
                  t_lines_out(t_lines_out.COUNT+1) := evaluate_expression(l_line);
               END IF;
            ELSIF starts_with(l_line,'define') THEN
               l_name := consume_word(l_line);
               IF g_cnt = 0 THEN
                  define_symbol(l_line);
               END IF;
            ELSIF starts_with(l_line,'undefine') OR starts_with(l_line,'undef') THEN
               l_name := consume_word(l_line);
               IF g_cnt = 0 THEN
                  undefine_symbol(l_line);
               END IF;
            ELSIF starts_with(l_line,'ifdef') THEN
               l_name := consume_word(l_line);
               push_flag(1);
               g_flag := exists_symbol(l_line);
               update_top_flag(g_flag);
               IF g_cnt>0 OR g_flag=0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'ifndef') THEN
               l_name := consume_word(l_line);
               push_flag(0);
               g_flag := exists_symbol(l_line);
               update_top_flag(ABS(g_flag-1));
               IF g_cnt>0 OR g_flag!=0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'if') THEN
               l_name := consume_word(l_line);
               push_flag(1);
               g_flag := evaluate_expression(l_line);
               update_top_flag(g_flag);
               IF g_cnt>0 OR g_flag=0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'endif') THEN
               assert(t_flags.COUNT>0,'#endif without #if, #ifdef or #ifndef');
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               g_flag := pop_flag;
            ELSIF starts_with(l_line,'end if') THEN -- take care of space sometimes added by Toad editor
               assert(t_flags.COUNT>0,'#end if without #if, #ifdef or #ifndef');
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               g_flag := pop_flag;
            ELSIF starts_with(l_line,'else') THEN
               assert(t_flags.COUNT>0,'#else without #if, #ifdef or #ifndef');
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               update_top_flag(get_top_flag+1);
               IF g_cnt>0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'elifdef') THEN
               l_name := consume_word(l_line);
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               g_flag := exists_symbol(l_line);
               update_top_flag(get_top_flag+g_flag);
               IF g_cnt>0 OR g_flag=0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'elifndef') THEN
               l_name := consume_word(l_line);
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               g_flag := exists_symbol(l_line);
               update_top_flag(get_top_flag+ABS(g_flag-1));
               IF g_cnt>0 OR g_flag>0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'elif') THEN
               l_name := consume_word(l_line);
               IF g_cnt>0 THEN
                  g_cnt := g_cnt - 1;
               END IF;
               g_flag := evaluate_expression(l_line);
               update_top_flag(get_top_flag+g_flag);
               IF g_cnt>0 OR g_flag=0 OR get_top_flag!=1 THEN
                  g_cnt := g_cnt + 1;
               END IF;
            ELSIF starts_with(l_line,'debug') THEN
--               l_name := consume_word(l_line);
               g_debug := TRUE;
            ELSIF starts_with(l_line,'nodebug') THEN
--               l_name := consume_word(l_line);
               g_debug := FALSE;
            ELSIF starts_with(l_line,'pragma') THEN
               l_name := consume_word(l_line);
               IF starts_with(l_line,'iso') THEN
                  g_iso := TRUE;
               ELSIF starts_with(l_line,'noiso') THEN
                  g_iso := FALSE;
               ELSIF starts_with(l_line,'reversible') THEN
                  IF NOT (g_reversible OR g_macro) THEN
                     g_reversible := TRUE;
                     IF NOT ends_with(l_line,'#internal') THEN
                        generate_reverse_range('--@',l_first_line_no,l_line_no);
                     END IF;
                  END IF;
                  g_reversible := TRUE;
               ELSIF starts_with(l_line,'noreversible') THEN
                  g_reversible := FALSE;
               ELSIF starts_with(l_line,'macro') THEN
                  IF NOT (g_reversible OR g_macro) THEN
                     g_macro := TRUE;
                     generate_reverse_range('--@',l_first_line_no,l_line_no);
                  END IF;
                  g_macro := TRUE;
                  g_iso := TRUE;
               ELSIF starts_with(l_line,'nomacro') THEN
                  g_macro := FALSE;
               ELSE
                  assert(FALSE,'Invalid #pragma: '||l_line);
               END IF;
            ELSIF starts_with(l_line,'warning') THEN
               l_name := consume_word(l_line);
               IF g_cnt=0 THEN
                  l_line := replace_symbols(l_line,FALSE);
                  log(l_line,TRUE);
               END IF;
            ELSIF starts_with(l_line,'error') THEN
               l_name := consume_word(l_line);
               IF g_cnt=0 THEN
                  l_line := replace_symbols(l_line,FALSE);
                  assert(FALSE,l_line);
               END IF;
            END IF;
         ELSIF SUBSTR(l_line,1,3) != '--@' AND SUBSTR(l_line,-9)='--#delete' THEN
            generate_reverse_range('--@',l_first_line_no,l_line_no);
         ELSE
            IF g_cnt=0 THEN
               -- Remove starting keep directive
               IF SUBSTR(l_line,1,3) = '--@' THEN
                  l_line := SUBSTR(l_line,4);
               END IF;
               l_found := loopvar_referenced(l_line);
--               IF l_found THEN
--                  generate_reverse('--@'||l_line);
--                  generate_reverse('--#if 0');
--                  IF g_reversible THEN
--                     t_lines_out(t_lines_out.COUNT+1) := '--#if 0';
--                  END IF;
--               END IF;
               l_line_sav := l_line;
               l_line := eval_macro_functions(replace_symbols(l_line,TRUE));
               IF NOT g_macro OR is_equal(l_line,l_line_sav) THEN
                  t_lines_out(t_lines_out.COUNT+1) := l_line;
               ELSE
                  t_lines_out(t_lines_out.COUNT+1) := '--@'||l_line_sav;
                  t_lines_out(t_lines_out.COUNT+1) := l_line||'--#delete';
               END IF;
--               IF l_found THEN
--                  generate_reverse('--#endif 0');
--                  IF g_reversible THEN
--                     t_lines_out(t_lines_out.COUNT+1) := '--#endif 0';
--                  END IF;
--                 END IF;
            ELSE
               generate_reverse('--@'||l_line);
            END IF;
         END IF;
         IF t_lines_out.COUNT=1 AND t_lines_out(1) IS NULL THEN
            t_lines_out.DELETE(1);
         END IF;
         l_line_no := t_lines_in.NEXT(l_line_no);
         <<next_line>>
         NULL;
       --define_symbol(t_sym_idx, '__LINE__',TRIM(TO_CHAR(l_line_no)),FALSE);
      END LOOP;
      -- Restore system symbols
      define_symbol(t_sym_idx, gk_object_type_sym, l_old_object_type,FALSE);
      define_symbol(t_sym_idx, gk_object_name_sym, l_old_object_name,FALSE);
      define_symbol(t_sym_idx, gk_file_sym,UPPER(p_object_type||' '||p_object_name),FALSE); -- for C precompiler compatibility
   END;
   ---
   -- Process source
   ---
   PROCEDURE process_source (
      p_source IN OUT VARCHAR2
   ) IS
      CURSOR c_src (
         p_type IN VARCHAR2
       , p_name IN VARCHAR2
      )
      IS
         SELECT text
           FROM all_source
          WHERE owner = UPPER(g_owner)
            AND TYPE = UPPER(p_type)
            AND NAME = UPPER(p_name)
          ORDER BY line
      ;
      l_type VARCHAR2(100);
      l_name VARCHAR2(100);
      l_tag VARCHAR2(100);
      l_msg VARCHAR2(100) := 'process_source(): ';
      t_lines_in sys.dbms_sql.varchar2a;
      l_pos INTEGER;
      l_include BOOLEAN;
   BEGIN
      p_source := replace_symbols(p_source,FALSE);
      l_type := UPPER(consume_word(p_source));
      assert(l_type IS NOT NULL,'type of object to process is missing');
      l_name := consume_word(p_source);
      IF l_type = 'PACKAGE' AND UPPER(l_name) = 'BODY' THEN
         l_type := l_type||' '||UPPER(l_name);
         l_name := consume_identifier(p_source,TRUE);
      END IF;
      assert(l_name IS NOT NULL,'name of object to process is missing');
      consume_white_spaces(p_source);
      IF p_source IS NOT NULL AND SUBSTR(p_source,1,1) != '-' THEN
         l_tag := consume_word(p_source);
         l_include := FALSE;
      ELSE
         l_include := TRUE;
      END IF;
      -- Get and store lines
      FOR r_src IN c_src(l_type,l_name) LOOP
         IF l_tag IS NOT NULL AND (INSTR(r_src.text,'#begin '||l_tag)>0 OR INSTR(r_src.text,'@begin:'||l_tag)>0) THEN
            l_include := TRUE;
         ELSIF l_tag IS NOT NULL AND (INSTR(r_src.text,'#end '||l_tag)>0 OR INSTR(r_src.text,'@end:'||l_tag)>0) THEN
            l_include := FALSE;
         ELSIF l_include THEN
            t_lines_in(t_lines_in.COUNT+1) := r_src.text;
         END IF;
      END LOOP;
      IF g_clone THEN
         -- Copy input to output
         IF t_lines_in.COUNT>0 THEN
            FOR i IN t_lines_in.FIRST..t_lines_in.LAST LOOP
               t_lines_out(i) := t_lines_in(i);
            END LOOP;
         END IF;
      ELSE
         -- Workaround for datapump which:
         -- o surrounds package name with double quotes
         -- o converts package name to uppercase
         -- Applied to first line of source code only!
         IF t_lines_in.COUNT > 0 THEN
            l_pos := INSTR(UPPER(t_lines_in(1)),'"'||UPPER(l_name)||'"');
            IF l_pos > 0 THEN
               -- Remove double quotes and restore case
               t_lines_in(1) := SUBSTR(t_lines_in(1),1,l_pos-1)
                              ||l_name --keep original case
                              ||SUBSTR(t_lines_in(1),l_pos+LENGTH(l_name)+2);
            END IF;
         END IF;
         -- Process lines
         process_lines(t_lines_in,l_type,l_name);
      END IF;
   END;
   ---
   -- Include source
   ---
   PROCEDURE include_source (
      p_source IN OUT VARCHAR2
    , t_lines_in IN OUT sys.dbms_sql.varchar2a
   ) IS
      CURSOR c_src (
         p_type IN VARCHAR2
       , p_name IN VARCHAR2
      )
      IS
         SELECT text
           FROM all_source
          WHERE owner = UPPER(g_owner)
            AND TYPE = UPPER(p_type)
            AND NAME = UPPER(p_name)
          ORDER BY line
      ;
      l_type VARCHAR2(100);
      l_name VARCHAR2(100);
      l_tag VARCHAR2(100);
      l_msg VARCHAR2(100) := 'include_source(): ';
      l_pos INTEGER;
      l_include BOOLEAN;
   BEGIN
      p_source := replace_symbols(p_source,FALSE);
      l_type := UPPER(consume_word(p_source));
      assert(l_type IS NOT NULL,'type of object to process is missing');
      l_name := consume_word(p_source);
      IF l_type = 'PACKAGE' AND UPPER(l_name) = 'BODY' THEN
         l_type := l_type||' '||UPPER(l_name);
         l_name := consume_identifier(p_source,TRUE);
      END IF;
      assert(l_name IS NOT NULL,'name of object to process is missing');
      IF p_source IS NOT NULL THEN
         l_tag := consume_word(p_source);
         l_include := FALSE;
      ELSE
         l_include := TRUE;
      END IF;
      -- Get and store lines
      FOR r_src IN c_src(l_type,l_name) LOOP
         IF l_tag IS NOT NULL AND (INSTR(r_src.text,'#begin '||l_tag)>0 OR INSTR(r_src.text,'@begin:'||l_tag)>0) THEN
            l_include := TRUE;
         ELSIF l_tag IS NOT NULL AND (INSTR(r_src.text,'#end '||l_tag)>0 OR INSTR(r_src.text,'@end:'||l_tag)>0) THEN
            l_include := FALSE;
         ELSIF l_include THEN
            t_lines_in(t_lines_in.COUNT+1) := r_src.text;
         END IF;
      END LOOP;
      -- Workaround for datapump which:
      -- o surrounds package name with double quotes
      -- o converts package name to uppercase
      -- Applied to first line of source code only!
      IF t_lines_in.COUNT > 0 THEN
         l_pos := INSTR(UPPER(t_lines_in(1)),'"'||UPPER(l_name)||'"');
         IF l_pos > 0 THEN
            -- Remove double quotes and restore case
            t_lines_in(1) := SUBSTR(t_lines_in(1),1,l_pos-1)
                           ||l_name --keep original case
                           ||SUBSTR(t_lines_in(1),l_pos+LENGTH(l_name)+2);
         END IF;
      END IF;
   END;
   ---
   -- Process text
   ---
   PROCEDURE process_text (
      p_text IN VARCHAR2
   ) IS
      l_pos INTEGER;
      l_text VARCHAR2(32767) := p_text;
      l_msg varchar2(100) := 'process_text(): ';
      t_lines_in sys.dbms_sql.varchar2a;
   BEGIN
      l_pos := INSTR(l_text,CHR(10));
      WHILE l_pos > 0 LOOP
         t_lines_in(t_lines_in.COUNT+1) := SUBSTR(l_text,1,l_pos-1);
         l_text := SUBSTR(l_text,l_pos+1);
         l_pos := INSTR(l_text,CHR(10));
      END LOOP;
      IF l_text IS NOT NULL THEN
         t_lines_in(t_lines_in.COUNT+1) := l_text;
      END IF;
      process_lines(t_lines_in,'<stdin>','');
   END;
   ---
   -- Initialize
   ---
   PROCEDURE initialize
   IS
   BEGIN
      t_sym_idx_prev := t_sym_idx; -- save symbol table from previous run
      t_sym_idx.DELETE;
      t_flags.DELETE;
      t_loopvar.DELETE;
      t_lines_out.DELETE;
      g_debug := FALSE;
      g_cnt := 0;
      g_flag := 0;
      g_reversible := FALSE;
      g_force := FALSE;
      g_owner := USER;
      g_iso := g_iso_default;
      g_macro := g_macro_default;
      g_sorted := FALSE;
      g_silent := FALSE;
      g_clone := FALSE;
      t_sym_name.DELETE;
      t_sym_value.DELETE;
      t_sym_param.DELETE;
      t_sym_param_count.DELETE;
      t_sym_len.DELETE;
      t_sym_ptr.DELETE;
   END;
--#begin public
   ---
   -- Generate from template
   ---
   PROCEDURE generate (
      p_source IN VARCHAR2
     ,p_options IN VARCHAR2 := NULL
     ,p_text IN VARCHAR2 := NULL
     ,p_target IN VARCHAR2 := NULL
   )
--#end public
   IS
      l_line VARCHAR2(4000) := p_options;
      l_source VARCHAR2(4000) := p_source;
      l_option VARCHAR2(4000);
      l_value VARCHAR2(4000);
      l_switch VARCHAR2(1 CHAR);
      l_cursor INTEGER;
      l_count INTEGER;
      l_type VARCHAR2(4000);
      l_name VARCHAR2(4000);
      l_err_count INTEGER := 0;
      l_pos INTEGER;
      l_test_mode BOOLEAN := FALSE;
      -- Cursor to get compilation error messages
      CURSOR c_err (
         p_type IN VARCHAR2
        ,p_name IN VARCHAR2
      ) IS
         SELECT ATTRIBUTE||' at line '||line||' col '||position||': '||text msg
           FROM user_errors
          WHERE TYPE=UPPER(p_type)
            AND NAME=UPPER(p_name)
          ORDER BY SEQUENCE
      ;
   BEGIN
      -- Reset symbols table (amongst others)
      initialize;
      -- Set standard predefined macros
      define_symbol(t_sym_idx, '__'||'DATE__',TO_CHAR(SYSDATE,'DD/MM/YYYY'),FALSE);
      define_symbol(t_sym_idx, '__'||'TIME__',TO_CHAR(SYSDATE,'HH24:MI:SS'),FALSE);
      -- Handle parameters
      WHILE l_line IS NOT NULL LOOP
         l_option := consume_word(l_line);
         IF SUBSTR(l_option,1,1) = '-' THEN
            l_switch := LOWER(SUBSTR(l_option,2,1));
            IF l_switch = 'r' THEN
               g_reversible := TRUE;
            ELSIF l_switch = 't' /* test mode = do not execute */ THEN
               l_test_mode := TRUE;
            ELSIF l_switch = 'd' /* define symbol */ THEN
               l_option := SUBSTR(l_option,3);
               l_pos := INSTR(l_option,'=');
               IF l_pos > 0 THEN
                  -- Replace the first equal sign with a space if any
                  l_option := SUBSTR(l_option,1,l_pos-1)||' '||SUBSTR(l_option,l_pos+1);
               END IF;
               define_symbol(l_option);
            ELSIF l_switch = 'u' /* undefine symbol */ THEN
               l_option := SUBSTR(l_option,3);
               undefine_symbol(l_option);
            ELSIF l_switch = 'i' /* include */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               process_source(l_line);
            ELSIF l_switch = 'o' /* owner */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               g_owner := SUBSTR(consume_word(l_line),30);
            ELSIF l_switch = 'f' /* force template overwrite */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               g_force := TRUE;
            ELSIF l_switch = 'c' /* ISO compatibility */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               g_iso := TRUE;
            ELSIF l_switch = 'm' /* Macro mode */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               g_macro := TRUE;
            ELSIF l_switch = 's' /* Silent mode */ THEN
               l_line := SUBSTR(l_option,3)||' '||l_line;
               g_silent := TRUE;
            ELSIF l_switch = 'k' /* Clone mode */ THEN
               g_clone := TRUE;
            END IF;
         END IF;
      END LOOP;
      -- Generate source code from passed text if any
      IF p_text IS NOT NULL THEN
         process_text(p_text);
      END IF;
      -- Generate source code from template if any
      IF l_source IS NOT NULL THEN
         process_source(l_source);
      END IF;
      -- Replace empty lines with a single space
      -- (those lines are dropped upon DDL execution)
      IF t_lines_out.COUNT > 0 THEN
         FOR i IN t_lines_out.FIRST..t_lines_out.LAST LOOP
            IF t_lines_out(i) IS NULL THEN
               t_lines_out(i) := ' ';
            END IF;
         END LOOP;
      END IF;
      -- Stop here if test mode
      IF l_test_mode THEN
         IF NOT g_silent AND t_lines_out.COUNT > 0 THEN
            FOR i IN t_lines_out.FIRST..t_lines_out.LAST LOOP
               log(i||': '||t_lines_out(i));
            END LOOP;
         END IF;
         RETURN;
      END IF;
      -- If generated source code not empty
      IF t_lines_out.EXISTS(1) THEN
         IF SUBSTR(UPPER(t_lines_out(1)),1,5) = 'BEGIN' THEN
            -- Anonymous block
            l_line := 'Anonymous Block';
            IF p_target IS NOT NULL THEN
               log('Target parameter ignored!');
            END IF;
         ELSIF p_target IS NOT NULL THEN
            -- Get object type and name from parameter
            t_lines_out(1) := 'CREATE OR REPLACE '||p_target||' AS';
            l_line := p_target;
         ELSE
            -- Get object type and name from first line
            IF SUBSTR(UPPER(t_lines_out(1)),1,17) = 'CREATE OR REPLACE' THEN
               l_line := SUBSTR(t_lines_out(1),18);
            ELSIF SUBSTR(UPPER(t_lines_out(1)),1,6) = 'CREATE' THEN
               l_line := SUBSTR(t_lines_out(1),7);
            ELSE
               t_lines_out(0) := 'CREATE OR REPLACE ';
               l_line := t_lines_out(1);
            END IF;
         END IF;
         -- Seperate objet type from name
         l_type := consume_word(l_line);
         l_name := consume_word(l_line);
         IF l_type = 'PACKAGE' AND l_name = 'BODY' THEN
            l_type := l_type||' '||l_name;
            l_name := REPLACE(consume_word(l_line),'"','');
         END IF;
         -- Execute DDL statement
         BEGIN
            -- Remove trailing LF
            FOR i IN t_lines_out.FIRST..t_lines_out.LAST LOOP
               IF SUBSTR(t_lines_out(i),-1,1) = CHR(10) THEN
                  t_lines_out(i) := SUBSTR(t_lines_out(i),1,LENGTH(t_lines_out(i))-1);
               END IF;
            END LOOP;
            -- execute statement
            l_cursor := sys.dbms_sql.open_cursor;
            sys.dbms_sql.parse(l_cursor, t_lines_out, t_lines_out.FIRST, t_lines_out.LAST, TRUE, sys.dbms_sql.native);
            l_count := sys.dbms_sql.execute(l_cursor);
            sys.dbms_sql.close_cursor(l_cursor);
            -- give feedback
            IF l_type = 'Anonymous' THEN
               log('Execution of ' ||l_type||' '||l_name||' ',FALSE);
            ELSE
               log('Compilation of ' ||l_type||' '||l_name||' ',FALSE);
               assert(g_force OR NVL(INSTR(UPPER(p_source),UPPER(l_name)),0)<=0,'Cannot overwrite template!');
            END IF;
            -- Check for compilation errors
            IF l_type != 'Anonymous' THEN
               FOR r_err IN c_err(l_type,l_name) LOOP
                  IF l_err_count = 0 THEN
                     log('KO');
                  END IF;
                  l_err_count := l_err_count + 1;
                  log(r_err.msg);
               END LOOP;
            END IF;
            IF l_err_count = 0 THEN
               log('OK');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               IF sys.dbms_sql.is_open(l_cursor) THEN
                  sys.dbms_sql.close_cursor(l_cursor);
               END IF;
               log('KO');
               FOR i IN t_lines_out.FIRST..t_lines_out.LAST LOOP
                --log(i||': '||t_lines_out(i));
                  log(t_lines_out(i));
               END LOOP;
               RAISE;
         END;
      ELSE
         IF NOT g_silent THEN
            log('No code generated for: '||p_source||' '||p_options||' '||p_target);
         END IF;
      END IF;
   END;
--#begin public
   ---
   -- Get named custom block of code enclosed between #begin and #end directives
   ---
   FUNCTION get_custom_code (
      p_type IN VARCHAR2 -- object type
    , p_name IN VARCHAR2 -- object name
    , p_tag  IN VARCHAR2 -- block name appearing after #begin/#end
    , p_sep  IN VARCHAR2 := NULL -- separator appended to each generated block
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      t_lines sys.dbms_sql.varchar2a;
      CURSOR c_src (
         p_type IN VARCHAR2
       , p_name IN VARCHAR2
      )
      IS
         SELECT text
           FROM user_source
          WHERE TYPE = UPPER(p_type)
            AND NAME = UPPER(p_name)
          ORDER BY line
      ;
      l_include BOOLEAN := FALSE;
   BEGIN
      -- Get lines and include those between tags
      FOR r_src IN c_src(p_type,p_name) LOOP
         IF INSTR(r_src.text,'#begin '||p_tag)>0  OR INSTR(r_src.text,'@begin:'||p_tag)>0 THEN
            l_include := TRUE;
         ELSIF INSTR(r_src.text,'#end '||p_tag)>0 OR INSTR(r_src.text,'@end:'||p_tag)>0 THEN
            l_include := FALSE;
            IF p_sep IS NOT NULL THEN
               pipe ROW(p_sep);
            END IF;
         ELSIF l_include THEN
            pipe ROW(r_src.text);
         END IF;
      END LOOP;
   END;
END;
/