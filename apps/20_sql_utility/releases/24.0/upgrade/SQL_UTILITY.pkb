CREATE OR REPLACE PACKAGE BODY sql_utility AS
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
--   ---
   -- Global types
   ---
   TYPE column_name_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE column_type_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE desc_tab_table IS TABLE OF sys.dbms_sql.desc_tab INDEX BY BINARY_INTEGER;
   TYPE hash_record IS RECORD (
      object_type VARCHAR2(30)
    , object_name VARCHAR2(61)
    , object_comment_fra VARCHAR2(4000)
    , object_comment_eng VARCHAR2(4000)
    , table_name VARCHAR2(30)
    , table_alias VARCHAR2(30)
    , column_name VARCHAR2(100)
    , constraint_name VARCHAR2(30)
    , r_constraint_name VARCHAR2(30)
    , columns_list VARCHAR2(4000)
    , pk_name VARCHAR2(30)
    , pk_columns VARCHAR2(1000)
    , descr_select VARCHAR2(4000)
    , next_record NUMBER
    , prepared_flag VARCHAR2(1)
    , CURSOR INTEGER
   );
   TYPE cursor_record IS RECORD (
      CURSOR INTEGER
    , STATEMENT VARCHAR2(4000)
    , desc_tab sys.dbms_sql.desc_tab
   );
   TYPE cursor_table IS TABLE OF cursor_record INDEX BY BINARY_INTEGER;
   TYPE hash_table IS TABLE OF hash_record INDEX BY BINARY_INTEGER;
   ---
   -- Global variables
   ---
   g_owner all_objects.owner%TYPE := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'); -- Object owner
   g_datetime_mask VARCHAR2(40) := 'DD/MM/YYYY HH24:MI:SS';  -- Display date and time in this format
   g_timestamp_mask VARCHAR2(40) := 'DD/MM/YYYY HH24:MI:SS:FF';  -- Display timestamps in this format
   g_table_name VARCHAR2(30) := NULL;
   g_col_names column_name_table;
   g_col_types column_type_table;
   gt_desc_tabs desc_tab_table; -- to be moved into gt_cursors
   gt_cursors cursor_table;
   g_cache hash_table;
   g_hash_size CONSTANT NUMBER := 800;
   g_hash_overflow NUMBER := 0;
   g_language VARCHAR2(3) := 'FRA';
   g_max_descr_len INTEGER := 30;
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_description IN VARCHAR2
   ) IS
   BEGIN
      IF NOT p_condition THEN
         raise_application_error(-20000,'Assertion failed: '||p_description);
      END IF;
   END;
--#begin public
   ---
   -- Set language
   ---
   PROCEDURE set_language (
      p_language IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      assert (NVL(p_language,'XXX') IN ('FRA','ENG','DEU'),'Invalid language: '||NVL(p_language,'NULL'));
      g_language := p_language;
   END;
--#begin public
   ---
   -- Set maximum descriptor length
   ---
   PROCEDURE set_descr_max_len (
      p_max_descr_len IN INTEGER
   )
--#end public
   IS
   BEGIN
      assert (NVL(p_max_descr_len,-1)>0,'Length must be >0');
      g_max_descr_len := p_max_descr_len;
   END;
--#begin public
   ---
   -- Open and parse cursor
   ---
   FUNCTION open_and_parse_cursor (
      p_statement IN VARCHAR2
   )
   RETURN INTEGER
--#end public
   IS
      l_idx INTEGER;
      r_cur cursor_record;
   BEGIN
      -- Search for existing cursor
      l_idx := gt_cursors.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         IF gt_cursors(l_idx).STATEMENT = p_statement THEN
            -- Found
            r_cur := gt_cursors(l_idx);
            EXIT;
         END IF;
         l_idx := gt_cursors.NEXT(l_idx);
      END LOOP;
      -- Open cursor if not found or not already opened
      IF r_cur.CURSOR IS NULL OR NOT sys.dbms_sql.is_open(r_cur.CURSOR) THEN
         r_cur.CURSOR := sys.dbms_sql.open_cursor;
         r_cur.STATEMENT := p_statement;
      END IF;
      sys.dbms_sql.parse(r_cur.CURSOR,r_cur.STATEMENT,sys.dbms_sql.native);
      gt_cursors(r_cur.CURSOR) := r_cur;
      RETURN r_cur.CURSOR;
   END;
   ---
   -- Return position of a named column for a cursor
   ---
   FUNCTION get_col_pos (
      p_cursor IN INTEGER
     ,p_col_name IN user_tab_columns.column_name%TYPE
   )
   RETURN INTEGER
   IS
      t_desc_tab sys.dbms_sql.desc_tab;
      l_count INTEGER;
   BEGIN
      IF NOT gt_desc_tabs.EXISTS(p_cursor) THEN
         sys.dbms_sql.describe_columns(p_cursor,l_count,gt_desc_tabs(p_cursor));
      END IF;
      t_desc_tab := gt_desc_tabs(p_cursor);
      FOR i IN 1..t_desc_tab.COUNT LOOP
         IF LOWER(t_desc_tab(i).col_name) = LOWER(p_col_name) THEN
            RETURN i;
         END IF;
      END LOOP;
      raise_application_error(-20000,'Column '||p_col_name||' not found for cursor '||p_cursor);
      RETURN NULL; -- not found
   END;
   ---
   -- Return value of a named column for a cursor (as varchar2)
   ---
   FUNCTION get_col_val (
      p_cursor IN INTEGER
     ,p_col_name IN user_tab_columns.column_name%TYPE
   )
   RETURN VARCHAR2
   IS
      l_col_pos INTEGER;
      t_desc_tab sys.dbms_sql.desc_tab;
      l_char VARCHAR2(32767);
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_res VARCHAR2(32767);
   BEGIN
      l_col_pos := get_col_pos(p_cursor,p_col_name);
      t_desc_tab := gt_desc_tabs(p_cursor);
      IF t_desc_tab(l_col_pos).col_type = 1 /* CHAR */ THEN
         sys.dbms_sql.column_value(p_cursor,l_col_pos,l_char);
         l_res := l_char;
      ELSIF t_desc_tab(l_col_pos).col_type = 2 /* NUMBER */ THEN
         sys.dbms_sql.column_value(p_cursor,l_col_pos,l_number);
         l_res := TO_CHAR(l_number);
      ELSIF t_desc_tab(l_col_pos).col_type = 12 /* DATE */ THEN
         sys.dbms_sql.column_value(p_cursor,l_col_pos,l_date);
         l_res := TO_CHAR(l_date,g_datetime_mask);
      ELSIF t_desc_tab(l_col_pos).col_type = 180 /* TIMESTAMP */ THEN
         sys.dbms_sql.column_value(p_cursor,l_col_pos,l_timestamp);
         l_res := TO_CHAR(l_timestamp,g_timestamp_mask);
      ELSE
       --raise_application_error(-20000,'Unsupported data type: '||t_desc_tab(l_col_pos).col_type);
         RETURN '<unsupported data type '||t_desc_tab(l_col_pos).col_type||'>';
      END IF;
      RETURN RTRIM(l_res);
   END;
--#begin public
   ---
   -- Describe columns
   ---
   PROCEDURE describe_columns (
      p_cursor IN INTEGER
   )
--#end public
   IS
      l_count INTEGER;
   BEGIN
      IF gt_desc_tabs.EXISTS(p_cursor) THEN
         gt_desc_tabs.DELETE(p_cursor);
      END IF;
      sys.dbms_sql.describe_columns(p_cursor,l_count,gt_desc_tabs(p_cursor));
   END;
--#begin public
   ---
   -- Define columns
   ---
   PROCEDURE define_columns (
      p_cursor IN INTEGER
   )
--#end public
   IS
      l_count INTEGER;
      t_desc_tab sys.dbms_sql.desc_tab;
      l_char VARCHAR2(32767);
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
   BEGIN
      describe_columns(p_cursor);
      t_desc_tab := gt_desc_tabs(p_cursor);
      FOR i IN 1..t_desc_tab.COUNT LOOP
       log_utility.log_message('D',i||': '||t_desc_tab(i).col_name||' '||t_desc_tab(i).col_type||' '||t_desc_tab(i).col_max_len);
         IF t_desc_tab(i).col_type = 1 /* VARCHAR2 */THEN
            sys.dbms_sql.define_column(p_cursor,i,l_char,t_desc_tab(i).col_max_len);
         ELSIF t_desc_tab(i).col_type = 2 /* NUMBER */ THEN
            sys.dbms_sql.define_column(p_cursor,i,l_number);
         ELSIF t_desc_tab(i).col_type = 12 /* DATE */THEN
            sys.dbms_sql.define_column(p_cursor,i,l_date);
         ELSIF t_desc_tab(i).col_type = 180 /* TIMESTAMP */THEN
            sys.dbms_sql.define_column(p_cursor,i,l_timestamp);
         ELSE
          --raise_application_error(-20000,'Unsupported data type: '||t_desc_tab(i).col_type);
            NULL;
         END IF;
      END LOOP;
   END;
--#begin public
   ---
   -- Close cursor
   ---
   PROCEDURE close_cursor (
      p_cursor IN INTEGER
   )
--#end public
   IS
      l_cursor INTEGER := p_cursor;
   BEGIN
      IF gt_cursors.EXISTS(l_cursor) THEN
         gt_cursors.DELETE(l_cursor);
      END IF;
      IF gt_desc_tabs.EXISTS(l_cursor) THEN
         gt_desc_tabs.DELETE(l_cursor);
      END IF;
      sys.dbms_sql.close_cursor(l_cursor);
   END;
   ---
   -- Close all opened cursors
   ---
   PROCEDURE close_cursors
   IS
      l_idx INTEGER;
      r_cur cursor_record;
   BEGIN
      -- Search for existing cursor
      l_idx := gt_cursors.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         r_cur := gt_cursors(l_idx);
         IF sys.dbms_sql.is_open(r_cur.CURSOR) THEN
            sys.dbms_sql.close_cursor(r_cur.CURSOR);
         END IF;
         l_idx := gt_cursors.NEXT(l_idx);
      END LOOP;
      gt_cursors.DELETE;
      gt_desc_tabs.DELETE;
   END;
   ---
   -- Tokenize columns list
   ---
   FUNCTION tokenize_columns_list (
      p_columns_list IN VARCHAR2
   )
   RETURN column_name_table
   IS
      l_tmp VARCHAR2(4000) := RTRIM(LTRIM(REPLACE(REPLACE(p_columns_list,CHR(10),' '),CHR(13),' ')));
      l_tab column_name_table;
      l_pos INTEGER;
   BEGIN
      WHILE l_tmp IS NOT NULL LOOP
         l_pos := INSTR(l_tmp,',');
         IF l_pos > 0 THEN
            l_tab(l_tab.COUNT+1) := LOWER(LTRIM(RTRIM(SUBSTR(l_tmp,1,l_pos-1))));
            l_tmp := SUBSTR(l_tmp,l_pos+1);
         ELSE
            l_tab(l_tab.COUNT+1) := LOWER(LTRIM(RTRIM(l_tmp)));
            l_tmp := NULL;
         END IF;
      END LOOP;
      RETURN l_tab;
   END;
--#begin public
   ---
   -- Format columns list
   ---
   FUNCTION format_columns_list (
      p_columns_list IN VARCHAR2
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
--#end public
   IS
      l_out VARCHAR2(4000);
      l_tab column_name_table;
      l_pos INTEGER;
   BEGIN
      assert(p_columns_per_line > 0,'Columns per line must be > 0');
      l_tab := tokenize_columns_list(p_columns_list);
      FOR i IN 1..l_tab.COUNT LOOP
         IF MOD(i-1,p_columns_per_line) = 0 THEN
            IF l_out IS NOT NULL THEN
               l_out := l_out || CHR(10);
               l_out := l_out || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_out := l_out || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF i > 1 THEN
            l_out := l_out || ', ';
         END IF;
         l_out := l_out || l_tab(i);
      END LOOP;
      RETURN l_out;
   END;
   ---
   -- Get columns names and types of a given table
   ---
   PROCEDURE get_col_names_and_types (
      p_table_name IN all_tab_columns.table_name%TYPE
     ,p_column_name IN all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN all_tab_columns.nullable%TYPE := NULL -- filter
     ,t_col_name OUT column_name_table
     ,t_col_type OUT column_type_table
   )
   IS
      -- Cursor to browse table columns
      CURSOR c_col (
         p_owner IN all_tab_columns.owner%TYPE
        ,p_table_name IN all_tab_columns.table_name%TYPE
        ,p_nullable IN all_tab_columns.nullable%TYPE
        ,p_column_name IN all_tab_columns.column_name%TYPE
      ) IS
         SELECT LOWER(column_name) column_name, data_type column_type
           FROM all_tab_columns
          WHERE owner = UPPER(p_owner)
            AND table_name = UPPER(p_table_name)
            AND (p_nullable IS NULL OR nullable = UPPER(p_nullable))
            AND (p_column_name IS NULL OR column_name LIKE UPPER(p_column_name) ESCAPE '~')
          ORDER BY column_id
      ;
   BEGIN
      -- For each column
      FOR r_col IN c_col(g_owner,p_table_name,p_nullable,p_column_name) LOOP
         t_col_name(t_col_name.COUNT+1) := r_col.column_name;
         t_col_type(t_col_type.COUNT+1) := r_col.column_type;
      END LOOP;
   END;
   ---
   -- Get columns list of a given table
   ---
   FUNCTION get_table_columns2 (
      p_table_name IN all_tab_columns.table_name%TYPE
     ,p_column_name IN all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN all_tab_columns.nullable%TYPE := NULL -- filter
   )
   RETURN column_name_table
   IS
      t_col_name column_name_table;
      t_col_type column_type_table;
   BEGIN
      get_col_names_and_types(p_table_name,p_column_name,p_nullable,t_col_name,t_col_type);
      RETURN t_col_name;
   END;
   ---
   -- Get string
   ---
   FUNCTION extract_string (
      p_string IN VARCHAR2
     ,p_index IN INTEGER := 1
     ,p_sep IN VARCHAR2 := '~~'
   ) RETURN VARCHAR2
   IS
      l_pos_from INTEGER;
      l_pos_to INTEGER;
      l_pos INTEGER;
      l_len INTEGER := LENGTH(p_sep);
   BEGIN
      IF NVL(p_index,0) <= 0 THEN
         RETURN NULL;
      END IF;
      l_pos_from := 1;
      FOR i IN 1..p_index-1 LOOP
         l_pos := INSTR(p_string,p_sep,l_pos_from);
         IF l_pos <= 0 THEN
            RETURN NULL;
         END IF;
         l_pos_from := l_pos + l_len;
      END LOOP;
      l_pos_to := INSTR(p_string,p_sep,l_pos_from);
      IF l_pos_to > 0 THEN
         RETURN SUBSTR(p_string,l_pos_from,l_pos_to-l_pos_from);
      ELSE
         RETURN SUBSTR(p_string,l_pos_from);
      END IF;
   END;
   ---
   -- Get column type
   ---
   FUNCTION get_column_type (
      p_table_name IN VARCHAR2
     ,p_column_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_col_type VARCHAR2(30);
   BEGIN
      IF g_table_name IS NULL OR p_table_name != g_table_name THEN
         -- Load name and type of columns in cache
         g_table_name := p_table_name;
         get_col_names_and_types(p_table_name,NULL,NULL,g_col_names,g_col_types);
      END IF;
      l_col_type := NULL;
      FOR i IN 1..g_col_names.COUNT LOOP
         l_col_type := g_col_types(i);
         EXIT WHEN g_col_names(i) = p_column_name;
         l_col_type := NULL;
      END LOOP;
      assert(l_col_type IS NOT NULL,'Cannot determine type of column '||p_table_name||'.'||p_column_name);
      RETURN l_col_type;
   END;
   ---
   -- Build select clause
   ---
   FUNCTION build_select_clause (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
   IS
      l_col_names column_name_table;
      l_select VARCHAR2(8000);
      l_col_type VARCHAR2(30);
      l_col_name VARCHAR2(30);
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         IF MOD(i-1,p_columns_per_line) = 0 THEN
            IF l_select IS NOT NULL THEN
               l_select := l_select || CHR(10);
               l_select := l_select || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_select := l_select || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF i > 1 THEN
            l_select := l_select || '||''~~''||';
         END IF;
         IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
            l_select := l_select || 'REPLACE(REPLACE('||l_col_name||','''''''',''''''''''''),''~'',''\~'')';
         ELSIF l_col_type = 'DATE' THEN
            l_select := l_select || 'TO_CHAR('||l_col_name||','''||g_datetime_mask||''')';
         ELSIF l_col_type = 'NUMBER' THEN
            l_select := l_select || l_col_name;
         ELSIF l_col_type = 'TIMESTAMP' THEN
            l_select := l_select || 'TO_CHAR('||l_col_name||','''||g_timestamp_mask||''')';
         ELSE
            assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
         END IF;
      END LOOP;
      RETURN l_select;
   END;
   ---
   -- Build "values" clause of an insert
   ---
   FUNCTION build_values_clause (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
   IS
      l_col_names column_name_table;
      l_select VARCHAR2(32000);
      l_col_type VARCHAR2(30);
      l_col_name VARCHAR2(30);
      l_data VARCHAR2(32000) := p_data;
      l_col_val VARCHAR2(32000);
      j INTEGER;
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      /* Browse all columns excepted leading pk columns */
      FOR i IN p_pk_size+1..l_col_names.COUNT LOOP
         j := i - p_pk_size;
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         IF MOD(j-1,p_columns_per_line) = 0 THEN
            IF l_select IS NOT NULL THEN
               l_select := l_select || CHR(10);
               l_select := l_select || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_select := l_select || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF j > 1 THEN
            l_select := l_select || ', ';
         END IF;
         l_col_val := REPLACE(extract_string(l_data,i),'\~','~');
         IF l_col_val IS NULL THEN
            l_select := l_select || 'NULL';
         ELSE
            IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
               l_select := l_select || '''' || l_col_val || '''';
            ELSIF l_col_type = 'DATE' THEN
               l_select := l_select || 'TO_DATE('''||l_col_val||''','''||g_datetime_mask||''')';
            ELSIF l_col_type = 'NUMBER' THEN
               l_select := l_select || l_col_val;
            ELSE
               assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
            END IF;
         END IF;
      END LOOP;
      RETURN l_select;
   END;
   ---
   -- Get column value
   ---
   FUNCTION get_column_value (
      p_table_name IN VARCHAR2
     ,p_column_name IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_index IN INTEGER
   )
   RETURN VARCHAR2
   IS
      l_col_type VARCHAR2(30);
      l_col_val VARCHAR2(32000);
   BEGIN
      l_col_type := get_column_type(p_table_name,p_column_name);
      l_col_val := REPLACE(extract_string(p_data,p_index),'\~','~');
      IF l_col_val IS NULL THEN
         RETURN 'NULL';
      ELSE
         IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
            RETURN '''' || l_col_val || '''';
         ELSIF l_col_type = 'DATE' THEN
            RETURN 'TO_DATE('''||l_col_val||''','''||g_datetime_mask||''')';
         ELSIF l_col_type = 'NUMBER' THEN
            RETURN l_col_val;
         ELSE
            assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||p_column_name);
         END IF;
      END IF;
   END;
   ---
   -- Get number of columns in a list
   ---
   FUNCTION get_columns_list_size (
      p_columns_list IN VARCHAR2
   )
   RETURN INTEGER
   IS
      l_col_names column_name_table;
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      RETURN l_col_names.COUNT;
   END;
   ---
   -- Build "set" and "where" clause of an update
   ---
   FUNCTION build_set_where_clause (
      p_table_name IN VARCHAR2
     ,p_sel_columns IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
/*
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
*/
   )
   RETURN VARCHAR2
   IS
      l_col_names column_name_table;
      l_col_name VARCHAR2(30);
      l_set VARCHAR2(32000);
      l_where VARCHAR2(32000);
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_sel_columns));
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_name := l_col_names(i);
         IF i <= p_pk_size THEN
            IF i = 1 THEN
               l_where := CHR(10) || ' WHERE ';
            ELSE
               l_where := l_where || CHR(10) || '   AND ';
            END IF;
            l_where := l_where || l_col_name || ' = '
                               || get_column_value(p_table_name,l_col_name,p_data,i);
         ELSE
            IF i = p_pk_size + 1 THEN
               l_set := CHR(10) || '   SET ';
            ELSE
               l_set := l_set || CHR(10) || '     , ';
            END IF;
            l_set := l_set || l_col_name || ' = '
                           || get_column_value(p_table_name,l_col_name,p_data,i);
         END IF;
      END LOOP;
      RETURN l_set || l_where;
   END;
   ---
   -- Get columns list of a given table
   ---
   FUNCTION get_table_columns (
      p_table_name IN all_tab_columns.table_name%TYPE
     ,p_column_name IN all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN all_tab_columns.nullable%TYPE := NULL -- filter
   )
   RETURN VARCHAR2
   IS
      l_tab column_name_table;
      l_columns_list VARCHAR2(4000);
   BEGIN
      -- Get columns
      l_tab := get_table_columns2(p_table_name,p_column_name,p_nullable);
      -- For each column
      FOR i IN 1..l_tab.COUNT LOOP
         IF i > 1 THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || l_tab(i);
      END LOOP;
      RETURN l_columns_list;
   END;
   ---
   -- Get columns list of a given constraint
   ---
   FUNCTION get_constraint_columns (
      p_constraint_name IN sys_all_cons_columns.constraint_name%TYPE
   )
   RETURN VARCHAR2
   IS
      -- Cursor to browse constraint columns
      CURSOR c_col (
         p_owner IN sys_all_cons_columns.owner%TYPE
        ,p_constraint_name IN sys_all_cons_columns.constraint_name%TYPE
      ) IS
         SELECT column_name
           FROM sys_all_cons_columns
          WHERE owner = p_owner
            AND constraint_name = p_constraint_name
          ORDER BY position
      ;
      l_columns_list VARCHAR2(4000);
      l_count INTEGER := 0;
   BEGIN
      -- For each column
      FOR r_col IN c_col(g_owner,p_constraint_name) LOOP
         IF l_columns_list IS NOT NULL THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || LOWER(r_col.column_name);
         l_count := l_count + 1;
      END LOOP;
      RETURN l_columns_list;
   END;
   ---
   -- Build where clause based on uk/pk
   ---
   FUNCTION build_cons_where_clause (
      p_constraint_name IN sys_all_cons_columns.constraint_name%TYPE
   )
   RETURN VARCHAR2
   IS
      -- Cursor to browse constraint columns
      CURSOR c_col (
         p_owner IN sys_all_cons_columns.owner%TYPE
        ,p_constraint_name IN sys_all_cons_columns.constraint_name%TYPE
      ) IS
         SELECT LOWER(col.table_name) table_name
              , LOWER(col.column_name) column_name
              , col.data_type
           FROM sys_all_cons_columns acc
          INNER JOIN all_tab_columns col
                  ON col.owner = acc.owner
                 AND col.table_name = acc.table_name
                 AND col.column_name = acc.column_name
          WHERE acc.owner = p_owner
            AND acc.constraint_name = p_constraint_name
          ORDER BY acc.position
      ;
      l_columns_list VARCHAR2(4000);
   BEGIN
      -- For each column
      FOR r_col IN c_col(g_owner,p_constraint_name) LOOP
         IF l_columns_list IS NOT NULL THEN
            l_columns_list := l_columns_list||' AND ';
         END IF;
         l_columns_list := l_columns_list || r_col.column_name || ' = ';
         IF r_col.data_type LIKE '%CHAR%' THEN -- CHAR
            l_columns_list := l_columns_list || ':' || r_col.column_name;
         ELSIF r_col.data_type = 'NUMBER' THEN -- NUMBER
            l_columns_list := l_columns_list || 'TO_NUMBER(:' || r_col.column_name || ')';
         ELSIF r_col.data_type = 'DATE' THEN -- DATE
            l_columns_list := l_columns_list || 'TO_DATE(:' || r_col.column_name || ','''||g_datetime_mask||''')';
         ELSE
            assert(FALSE,'Unsupported data type for '||r_col.table_name||'.'||r_col.column_name);
         END IF;
      END LOOP;
      RETURN l_columns_list;
   END;
   ---
   -- Build join condition
   ---
   FUNCTION build_join_condition (
      p_columns_list IN VARCHAR2
     ,p_alias1 IN VARCHAR2
     ,p_alias2 IN VARCHAR2
     ,p_left_tab IN INTEGER := 0
     ,p_indent_first_line IN VARCHAR2 := 'N'
   )
   RETURN VARCHAR2
   IS
      l_tab column_name_table;
      l_out VARCHAR2(4000);
   BEGIN
      l_tab := tokenize_columns_list(p_columns_list);
      FOR i IN 1..l_tab.COUNT LOOP
         IF i > 1 THEN
            l_out := l_out || CHR(10) || RPAD(' ',p_left_tab-4) || 'AND ';
         ELSE
            IF p_indent_first_line = 'Y' THEN
               l_out := RPAD(' ',p_left_tab);
            END IF;
         END IF;
         l_out := l_out || p_alias1 || '.' || LOWER(l_tab(i)) || ' = ' || p_alias2 || '.' || LOWER(l_tab(i));
      END LOOP;
      RETURN l_out;
   END;
   ---
   -- Get constraint of a given table
   ---
   FUNCTION get_table_constraint (
      p_table_name IN sys_all_constraints.table_name%TYPE
     ,p_constraint_type sys_all_constraints.constraint_type%TYPE := 'P'
   )
   RETURN VARCHAR2
   IS
      CURSOR c_con (
         p_owner sys_all_constraints.owner%TYPE
        ,p_table_name sys_all_constraints.table_name%TYPE
        ,p_constraint_type sys_all_constraints.constraint_type%TYPE
      )
      IS
         SELECT constraint_name
           FROM sys_all_constraints
          WHERE owner = p_owner
            AND table_name = p_table_name
            AND constraint_type = p_constraint_type
         ;
      l_constraint_name sys_all_constraints.constraint_name%TYPE;
   BEGIN
      OPEN c_con(g_owner,p_table_name,p_constraint_type);
      FETCH c_con INTO l_constraint_name;
      CLOSE c_con;
      RETURN l_constraint_name;
   END;
--#begin public
   ---
   -- Normalise columns list i.e. handle optional BUT keyword
   -- (extended syntax is: SELECT * BUT <columns_list> FROM <table>)
   -- wildcards in exclusion list columns are allowed
   ---
   FUNCTION normalise_columns_list (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      l_inc_tab column_name_table;
      l_exc_tab column_name_table;
      l_tmp_tab column_name_table;
      l_inc_str VARCHAR2(4000);
      l_exc_str VARCHAR2(4000);
      l_out_str VARCHAR2(4000);
      l_tmp_str VARCHAR2(4000);
      l_pos INTEGER;
      l_idx INTEGER;
      l_found BOOLEAN;
   BEGIN
      l_pos := NVL(INSTR(p_columns_list,' BUT '),0);
      IF l_pos > 0 THEN
         l_inc_str := LTRIM(RTRIM(SUBSTR(p_columns_list,1,l_pos-1)));
         l_exc_str := LTRIM(RTRIM(SUBSTR(p_columns_list,l_pos+5)));
      ELSE
         l_inc_str := LTRIM(RTRIM(p_columns_list));
         l_exc_str := NULL;
      END IF;
      IF l_inc_str IS NOT NULL THEN
         -- Expand * wildcard
         IF l_inc_str = '*' THEN
            l_inc_tab := get_table_columns2(p_table_name);
         ELSE
            l_inc_tab := tokenize_columns_list(l_inc_str);
         END IF;
         -- Expand % wildcards (~ is used as escape character)
         FOR i IN 1..l_inc_tab.COUNT LOOP
            IF INSTR(l_inc_tab(i),'%') > 0 THEN
               l_tmp_tab := get_table_columns2(p_table_name,l_inc_tab(i));
               FOR j IN 1..l_tmp_tab.COUNT LOOP
                  l_found := FALSE;
                  FOR K IN 1..l_inc_tab.COUNT LOOP
                     l_found := l_tmp_tab(j) = l_inc_tab(K);
                     EXIT WHEN l_found;
                  END LOOP;
                  IF NOT l_found THEN
                     l_inc_tab(l_inc_tab.COUNT+1) := l_tmp_tab(j);
                  END IF;
               END LOOP;
               l_inc_tab(i) := NULL; -- will be deleted later on
            END IF;
         END LOOP;
         -- Perform inclusion list minus exclusion list
         IF l_exc_str IS NOT NULL THEN
            l_exc_tab := tokenize_columns_list(l_exc_str);
            FOR i IN 1..l_inc_tab.COUNT LOOP
               IF l_inc_tab(i) IS NULL THEN
                  l_inc_tab.DELETE(i);
                  GOTO next_i;
               END IF;
               FOR j IN 1..l_exc_tab.COUNT LOOP
                  IF l_inc_tab(i) LIKE l_exc_tab(j) ESCAPE '~' THEN
                     l_inc_tab.DELETE(i);
                     EXIT;
                  END IF;
               END LOOP;
               <<next_i>>
               NULL;
            END LOOP;
         END IF;
         -- Build columns list
         l_idx := l_inc_tab.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            IF l_out_str IS NOT NULL THEN
               l_out_str := l_out_str || ', ';
            END IF;
            l_out_str := l_out_str || l_inc_tab(l_idx);
            l_idx := l_inc_tab.NEXT(l_idx);
         END LOOP;
      ELSE
         l_out_str := l_inc_str;
      END IF;
      RETURN l_out_str;
   END;
--#begin public
   ---
   -- Refresh internal cache
   ---
   PROCEDURE refresh_internal_cache (
      p_owner all_objects.owner%TYPE := NULL
     ,p_force IN BOOLEAN := FALSE -- force refresh
   )
--#end public
   IS
      PRAGMA autonomous_transaction;
      l_owner all_objects.owner%TYPE := NVL(p_owner,g_owner);
      CURSOR c_con (
         p_owner all_objects.owner%TYPE
      ) IS
         SELECT MAX(last_change)
           FROM all_constraints
          WHERE owner = p_owner
         ;
      CURSOR c_tcon (
         p_owner all_objects.owner%TYPE
       , p_system sys_all_constraints.SYSTEM%TYPE
      ) IS
         SELECT MAX(last_change)
           FROM sys_all_constraints
          WHERE SYSTEM = p_system
            AND owner = p_owner
         ;
      l_con_last_change sys_all_constraints.last_change%TYPE;
      l_tmp_last_change sys_all_constraints.last_change%TYPE;
      l_sysdate DATE := SYSDATE;
   BEGIN
      -- Delete cache
      g_cache.DELETE;
      close_cursors;
      g_hash_overflow := 0;
      -- Start refresh
      log_utility.log_message('D','refresh cache requested for '||l_owner);
      IF NOT p_force THEN
         -- Get last change date in Oracle data dictionnary view
         OPEN c_con(l_owner);
         FETCH c_con INTO l_con_last_change;
         CLOSE c_con;
         log_utility.log_message('D','system view: constraints most recently changed on '||TO_CHAR(l_con_last_change,g_datetime_mask));
         -- Get last change date in temporary table
         OPEN c_tcon(l_owner,'Y');
         FETCH c_tcon INTO l_tmp_last_change;
         CLOSE c_tcon;
         log_utility.log_message('D','cache table: constraints most recently changed on '||TO_CHAR(l_tmp_last_change,g_datetime_mask));
      END IF;
      -- Refresh temporary table if needed
      IF p_force
      OR l_tmp_last_change IS NULL
      OR l_tmp_last_change < NVL(l_con_last_change,SYSDATE)
      THEN
         log_utility.log_message('D','refreshing cache...');
         -- Delete all constraint columns
         DELETE sys_all_cons_columns
          WHERE SYSTEM = 'Y'
            AND owner = l_owner
         ;
         -- Delete all constraints
         DELETE sys_all_constraints
          WHERE SYSTEM = 'Y'
            AND owner = l_owner
         ;
         -- Insert all constraints (excepted those redefined)
         INSERT INTO sys_all_constraints (
            owner, table_name, constraint_type
          , constraint_name, r_constraint_name, DEFERRED
          , last_change, SYSTEM
         )
         SELECT owner, table_name, constraint_type
              , constraint_name, r_constraint_name, DEFERRED
              , last_change, 'Y'
           FROM all_constraints
          WHERE owner = l_owner
            AND (owner, constraint_name) NOT IN (
                   SELECT owner, constraint_name
                     FROM sys_all_constraints
                    WHERE owner = l_owner
                      AND SYSTEM = 'N'
                )
         ;
         -- Insert all constraint columns (excepted those redefined)
         INSERT INTO sys_all_cons_columns (
            owner, constraint_name, table_name
          , column_name, position, SYSTEM
         )
         SELECT owner, constraint_name, table_name
              , column_name, position, 'Y'
           FROM all_cons_columns
          WHERE owner = l_owner
            AND (owner, constraint_name) NOT IN (
                   SELECT owner, constraint_name
                     FROM sys_all_constraints
                    WHERE owner = l_owner
                      AND SYSTEM = 'N'
                )
         ;
      ELSE
         log_utility.log_message('D','cache is up to date.');
      END IF;
--#ifdef SYSPER2
      -- Check presence of non-system constraints
      l_tmp_last_change := NULL;
      OPEN c_tcon(l_owner,'N');
      FETCH c_tcon INTO l_tmp_last_change;
      CLOSE c_tcon;
      log_utility.log_message('D','cache table: non-system constraints most recently changed on '||TO_CHAR(l_tmp_last_change,g_datetime_mask));
      -- If not found and not in production, copy them from production schema
      IF l_tmp_last_change IS NULL AND l_owner != 'APP_SP2_P' THEN
         log_utility.log_message('D','Copying non-system constraints from APP_SP2_P into '||l_owner);
         -- Insert all constraints (excepted those redefined)
         INSERT INTO sys_all_constraints (
            owner, table_name, constraint_type
          , constraint_name, r_constraint_name, DEFERRED
          , last_change, SYSTEM
         )
         SELECT l_owner, table_name, constraint_type
              , constraint_name, r_constraint_name, DEFERRED
              , last_change, SYSTEM
           FROM sys_all_constraints
          WHERE owner = 'APP_SP2_P'
            AND SYSTEM = 'N'
         ;
         -- Insert all constraint columns (excepted those redefined)
         INSERT INTO sys_all_cons_columns (
            owner, constraint_name, table_name
          , column_name, position, SYSTEM
         )
         SELECT l_owner, constraint_name, table_name
              , column_name, position, SYSTEM
           FROM sys_all_cons_columns
          WHERE owner = 'APP_SP2_P'
            AND SYSTEM = 'N'
         ;
      END IF;
--#endif
      -- Load other stuff
      load_table_descriptors(l_owner);
      load_constraint_descriptors(l_owner);
      load_object_comments(l_owner);
      -- Save work
      COMMIT
      ;
   END;
   ---
   -- Get hash value
   ---
   FUNCTION get_hash_value (
      p_table_name IN VARCHAR2
   )
   RETURN NUMBER
   IS
   BEGIN
      RETURN sys.dbms_utility.get_hash_value(p_table_name,1,g_hash_size);
   END;
   ---
   -- Build object name
   ---
   FUNCTION build_object_name (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
   BEGIN
      IF p_object_type = 'TABLE' THEN
         RETURN UPPER(p_table_name);
      ELSIF p_object_type = 'COLUMN' THEN
         RETURN UPPER(p_table_name||'.'||p_column_name);
      ELSIF p_object_type = 'CONSTRAINT' THEN
         RETURN UPPER(p_constraint_name);
      ELSE
         assert(FALSE,'Object type '||p_object_type||' not supported by cache');
      END IF;
   END;
   ---
   -- Add an object to cache
   ---
   FUNCTION add_object (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_r_constraint_name IN VARCHAR2 := NULL
    , p_columns_list IN VARCHAR2 := NULL
   )
   RETURN INTEGER
   IS
      l_pos INTEGER;
      l_hv NUMBER;
      r_hr hash_record;
   BEGIN
      r_hr := NULL;
      r_hr.object_type := p_object_type;
      r_hr.object_name := build_object_name(p_object_type,p_table_name,p_column_name,p_constraint_name);
      r_hr.table_name := p_table_name;
      r_hr.column_name := p_column_name;
      r_hr.constraint_name := p_constraint_name;
      r_hr.r_constraint_name := p_r_constraint_name;
      r_hr.columns_list := p_columns_list;
      r_hr.next_record := -1;
      l_hv := get_hash_value(r_hr.object_name);
      l_pos := l_hv;
      IF g_cache.EXISTS(l_hv) THEN
         g_hash_overflow := g_hash_overflow + 1;
         LOOP
            IF g_cache(l_hv).next_record = -1 THEN
               l_pos := g_hash_overflow+g_hash_size;
               g_cache(l_hv).next_record := l_pos;
               EXIT;
            ELSE
               l_hv := g_cache(l_hv).next_record;
            END IF;
         END LOOP;
      END IF;
      IF r_hr.object_type = 'TABLE' THEN
         r_hr.table_alias := 't'||l_pos;
      END IF;
      IF r_hr.object_type = 'CONSTRAINT' THEN
         r_hr.columns_list := get_constraint_columns(p_constraint_name);
         assert(r_hr.columns_list IS NOT NULL,'No column(s) found for constraint '||p_constraint_name);
      END IF;
      g_cache(l_pos) := r_hr;
      RETURN l_pos;
   END;
   ---
   -- Add an object to cache
   ---
   PROCEDURE add_object (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_r_constraint_name IN VARCHAR2 := NULL
    , p_columns_list IN VARCHAR2 := NULL
   )
   IS
      l_pos INTEGER;
   BEGIN
      l_pos := add_object(
         p_object_type
        ,p_table_name
        ,p_column_name
        ,p_constraint_name
        ,p_r_constraint_name
        ,p_columns_list
      );
   END;
   ---
   -- Get object position in cache
   ---
   FUNCTION get_object_pos (
      p_object_type IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN NUMBER
   IS
      l_hv NUMBER;
   BEGIN
      l_hv := get_hash_value(UPPER(p_object_name));
      FOR i IN 1..100 LOOP
         IF NOT g_cache.EXISTS(l_hv) THEN
            RETURN NULL; -- not found
         ELSIF g_cache(l_hv).object_name = UPPER(p_object_name) THEN
            RETURN l_hv;
         ELSIF g_cache(l_hv).next_record = -1 THEN
            RETURN NULL; -- not found
         ELSE
            l_hv := g_cache(l_hv).next_record;
         END IF;
      END LOOP;
      assert(FALSE,'infinite loop detected in get_object_pos()');
   END;
   ---
   -- Get object position in cache
   ---
   FUNCTION get_object_pos (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_r_constraint_name IN VARCHAR2 := NULL
    , p_columns_list IN VARCHAR2 := NULL
   )
   RETURN NUMBER
   IS
      l_hv NUMBER;
      l_object_name VARCHAR2(61);
   BEGIN
      l_object_name := build_object_name(p_object_type,p_table_name,p_column_name,p_constraint_name);
      RETURN get_object_pos(p_object_type=>p_object_type,p_object_name=>l_object_name);
   END;
   ---
   -- Add an object to cache (if not already present)
   ---
   FUNCTION add_object_if_not_found (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_r_constraint_name IN VARCHAR2 := NULL
    , p_columns_list IN VARCHAR2 := NULL
   )
   RETURN INTEGER
   IS
      l_pos INTEGER;
   BEGIN
      l_pos := get_object_pos(
         p_object_type
        ,p_table_name
        ,p_column_name
        ,p_constraint_name
        ,p_columns_list
      );
      IF l_pos IS NULL THEN
         l_pos := add_object(
            p_object_type
           ,p_table_name
           ,p_column_name
           ,p_constraint_name
           ,p_r_constraint_name
           ,p_columns_list
      );
      END IF;
      RETURN l_pos;
   END;
   ---
   -- Add an object to cache (if not already present)
   ---
   PROCEDURE add_object_if_not_found (
      p_object_type IN VARCHAR2
    , p_table_name IN VARCHAR2 := NULL
    , p_column_name IN VARCHAR2 := NULL
    , p_constraint_name IN VARCHAR2 := NULL
    , p_r_constraint_name IN VARCHAR2 := NULL
    , p_columns_list IN VARCHAR2 := NULL
   )
   IS
      l_pos INTEGER;
   BEGIN
      l_pos := add_object_if_not_found (
         p_object_type
        ,p_table_name
        ,p_column_name
        ,p_constraint_name
        , p_r_constraint_name
        ,p_columns_list
      );
   END;
   ---
   -- Return statement that select descriptor column
   ---
   FUNCTION build_descr_select (
      p_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_column_name user_tab_columns.column_name%TYPE;
      l_where VARCHAR2(4000) := NULL;
      l_pos INTEGER;
   BEGIN
      l_pos := get_object_pos(p_object_type=>'TABLE',p_table_name=>p_table_name);
      IF l_pos IS NOT NULL THEN
         l_column_name := g_cache(l_pos).column_name;
      ELSE
         RETURN NULL;
      END IF;
      l_where := build_cons_where_clause(p_constraint_name);
      IF l_column_name IS NULL OR l_where IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN 'SELECT '|| l_column_name ||' FROM '||LOWER(p_table_name)|| ' WHERE ' || l_where;
   END;
--#begin public
   ---
   -- Show cache
   ---
   PROCEDURE show_cache
--#end public
   IS
   BEGIN
      DECLARE
         l_hp NUMBER; -- hash position
         r_hr hash_record; -- hash record
      BEGIN
         log_utility.log_message('T','*** Objects cache ***');
         l_hp := g_cache.FIRST;
         WHILE l_hp IS NOT NULL LOOP
            r_hr := g_cache(l_hp);
            log_utility.log_message('T',l_hp
               ||': '||r_hr.object_type
               ||' '||LOWER(r_hr.object_name)
               ||'; TAB='||LOWER(r_hr.table_name)
               ||'; COL='||LOWER(r_hr.column_name)
               ||'; CON='||LOWER(r_hr.constraint_name)
               ||'; RCON='||LOWER(r_hr.r_constraint_name)
               ||'; COLS='||LOWER(r_hr.columns_list)
               ||'; SEL='||r_hr.descr_select
               ||'; CUR='||r_hr.CURSOR
               ||'; COMFR='||r_hr.object_comment_fra
               ||'; COMEN='||r_hr.object_comment_eng
            );
            l_hp := g_cache.NEXT(l_hp);
         END LOOP;
      END;
      DECLARE
         l_idx INTEGER;
         r_cur cursor_record;
      BEGIN
         log_utility.log_message('T','*** Cursors cache ***');
         l_idx := gt_cursors.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            r_cur := gt_cursors(l_idx);
            log_utility.log_message('T',l_idx||': '||r_cur.CURSOR||' - '||r_cur.STATEMENT);
         END LOOP;
      END;
   END;
   ---
   -- Get loop-up descriptors for a given table
   ---
   PROCEDURE prepare_table (
      p_table_name IN VARCHAR2
   )
   IS
      CURSOR c_con (
         p_owner IN VARCHAR2
       , p_table_name IN VARCHAR2
      )
      IS
         SELECT col.table_name, col.column_name, con.constraint_name
              , con.r_constraint_name, r_con.table_name r_table_name
           FROM sys_all_constraints con
          INNER JOIN sys_all_cons_columns col
             ON col.owner = con.owner
            AND col.constraint_name = con.constraint_name
          INNER JOIN sys_all_constraints r_con
             ON r_con.owner = con.owner
            AND r_con.constraint_name = con.r_constraint_name
          WHERE con.owner = p_owner
            AND con.table_name = p_table_name
            AND con.constraint_type = 'R'
            AND (col.constraint_name, col.position) IN (
                   SELECT con.constraint_name, MAX(position)
                     FROM sys_all_constraints con
                    INNER JOIN sys_all_cons_columns col
                            ON col.owner = con.owner
                           AND col.constraint_name = con.constraint_name
                    WHERE con.owner = p_owner
                      AND con.table_name = p_table_name
                      AND con.constraint_type = 'R'
                    GROUP BY con.constraint_name
                )
      ;
      l_pos INTEGER;
   BEGIN
      -- Get table from cache, add it if not found
      l_pos := add_object_if_not_found(p_object_type=>'TABLE',p_table_name=>p_table_name);
      IF g_cache(l_pos).prepared_flag = 'Y' THEN
         -- Table already prepared
         RETURN;
      END IF;
      g_cache(l_pos).prepared_flag := 'Y';
      -- For each column having a descriptor
      FOR r_con IN c_con(g_owner,p_table_name) LOOP
         -- Add column if not present
         l_pos := add_object_if_not_found(
             p_object_type=>'COLUMN'
            ,p_table_name=>r_con.table_name
            ,p_column_name=>r_con.column_name
            ,p_constraint_name=>r_con.constraint_name
            ,p_r_constraint_name=>r_con.r_constraint_name
         );
         g_cache(l_pos).constraint_name := r_con.constraint_name;
         g_cache(l_pos).r_constraint_name := r_con.r_constraint_name;
         -- Add constraint if not present
         add_object_if_not_found(
             p_object_type=>'CONSTRAINT'
            ,p_table_name=>r_con.table_name
            ,p_constraint_name=>r_con.constraint_name
            ,p_r_constraint_name=>r_con.r_constraint_name
         );
         -- Add remote constraint if not present
         l_pos := get_object_pos(
             p_object_type=>'CONSTRAINT'
            ,p_table_name=>r_con.r_table_name
            ,p_constraint_name=>r_con.r_constraint_name
         );
         IF l_pos IS NULL THEN
            l_pos := add_object(
                p_object_type=>'CONSTRAINT'
               ,p_table_name=>r_con.r_table_name
               ,p_constraint_name=>r_con.r_constraint_name
            );
            g_cache(l_pos).descr_select := build_descr_select(r_con.r_table_name,r_con.r_constraint_name);
         END IF;
      END LOOP;
   END;
--#begin public
   ---
   -- Set select statement to be used for a given constraint
   ---
   PROCEDURE set_descr_select (
      p_table_name IN VARCHAR2
    , p_constraint_name IN VARCHAR2
    , p_descr_select IN VARCHAR2
   )
--#end public
   IS
      l_pos INTEGER;
   BEGIN
      l_pos := add_object_if_not_found('CONSTRAINT',p_table_name=>p_table_name,p_constraint_name=>p_constraint_name);
      g_cache(l_pos).descr_select := REGEXP_REPLACE(LOWER(p_descr_select),'_fra([^a-z]|$)','_'||LOWER(g_language)||'\1');
   END;
--#begin public
   ---
   -- Set descriptor column of a table
   ---
   PROCEDURE set_descr_column (
      p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
   )
--#end public
   IS
      l_pos INTEGER;
   BEGIN
      l_pos := add_object_if_not_found('TABLE',p_table_name=>p_table_name);
      g_cache(l_pos).column_name := REGEXP_REPLACE(LOWER(p_column_name),'_fra([^a-z]|$)','_'||LOWER(g_language)||'\1');
   END;
--#begin public
   ---
   -- Get column descriptor
   ---
   FUNCTION get_column_descr (
      p_cursor IN INTEGER -- context
    , p_table_name IN VARCHAR2
    , p_column_name IN VARCHAR2
    , p_check_only IN VARCHAR2 := 'N' -- only check the existence of a descriptor i.e. no fetch
   )
   RETURN VARCHAR2
--#end public
   IS
      l_col_pos INTEGER;
      l_con_pos INTEGER;
      l_rcon_pos INTEGER;
      l_cursor INTEGER;
      l_count INTEGER;
      l_char VARCHAR2(32767);
      t_col column_name_table;
      t_rcol column_name_table;
      t_desc_tab sys.dbms_sql.desc_tab;
   BEGIN
      -- Prepare table
      prepare_table(p_table_name);
      -- Get column from cache
      l_col_pos := get_object_pos(p_object_type=>'COLUMN',p_table_name=>p_table_name,p_column_name=>p_column_name);
      IF l_col_pos IS NULL
      OR g_cache(l_col_pos).constraint_name IS NULL
      OR g_cache(l_col_pos).r_constraint_name IS NULL
      THEN
         -- Column not in cache or not associated with a FK constraint => no descriptor
         RETURN NULL;
      END IF;
      -- Get constraint from cache
      l_con_pos := get_object_pos(p_object_type=>'CONSTRAINT',p_constraint_name=>g_cache(l_col_pos).constraint_name);
      IF g_cache(l_con_pos).columns_list IS NULL THEN
         RETURN NULL;
      END IF;
      -- Get remote constraint from cache
      l_rcon_pos := get_object_pos(p_object_type=>'CONSTRAINT',p_constraint_name=>g_cache(l_col_pos).r_constraint_name);
      IF g_cache(l_rcon_pos).columns_list IS NULL
      OR g_cache(l_rcon_pos).descr_select IS NULL
      THEN
         -- No select statement found to get descriptor
         RETURN NULL;
      END IF;
      -- Get cursor
      l_cursor := g_cache(l_rcon_pos).CURSOR;
      IF l_cursor IS NULL OR NOT sys.dbms_sql.is_open(l_cursor) THEN
         l_cursor := sys.dbms_sql.open_cursor;
         g_cache(l_rcon_pos).CURSOR := l_cursor;
         sys.dbms_sql.parse(l_cursor,g_cache(l_rcon_pos).descr_select,sys.dbms_sql.native);
         define_columns(l_cursor);
      END IF;
      t_col := tokenize_columns_list(g_cache(l_con_pos).columns_list);
      t_rcol := tokenize_columns_list(g_cache(l_rcon_pos).columns_list);
      assert(t_col.COUNT=t_rcol.COUNT,'Mismatch detected between fk and pk/uk columns');
      IF p_check_only = 'Y' THEN
         t_desc_tab := gt_desc_tabs(l_cursor);
         RETURN t_desc_tab(1).col_name; -- return name of descriptor, do not fetch look-up data
      END IF;
      -- Ensure that context cursor is opened
      assert(sys.dbms_sql.is_open(p_cursor),'Cursor '||p_cursor||' not opened');
      -- Describe columns of cursor if not already $done
      IF NOT gt_desc_tabs.EXISTS(p_cursor) THEN
         sys.dbms_sql.describe_columns(p_cursor,l_count,gt_desc_tabs(p_cursor));
      END IF;
      -- Bind all variable in the fk
      FOR i IN 1..t_col.COUNT LOOP
         sys.dbms_sql.bind_variable(l_cursor, ':'||t_rcol(i), get_col_val(p_cursor,t_col(i)));
      END LOOP;
      l_count := sys.dbms_sql.execute(l_cursor);
      l_count := sys.dbms_sql.fetch_rows(l_cursor);
      sys.dbms_sql.column_value(l_cursor,1,l_char);
      IF LENGTH(l_char) > g_max_descr_len THEN
         RETURN SUBSTR(l_char,1,g_max_descr_len-3)||'...';
      ELSE
         RETURN l_char;
      END IF;
   END;
--#begin public
   ---
   -- Execute a SQL statement
   ---
   PROCEDURE execute (
      p_select IN VARCHAR2
    , p_tab_mode IN VARCHAR2 := NULL -- tabular mode (Y/N)?, default=Y
    , p_sep_char IN VARCHAR2 := NULL -- columns separator, default=tab
   )
--#end public
   IS
      l_cursor INTEGER;
      l_select VARCHAR2(32000) := UPPER(LTRIM(RTRIM(p_select)));
      t_desc sys.dbms_sql.desc_tab;
      l_count INTEGER;
      l_tot_count INTEGER;
      l_char VARCHAR2(32767);
      l_line VARCHAR2(32767);
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_descr VARCHAR2(1000);
      l_table_name VARCHAR2(30);
      l_col_name VARCHAR2(30);
      l_pos INTEGER;
      l_tab_mode VARCHAR2(1) := CASE WHEN UPPER(SUBSTR(p_tab_mode,1,1)) = 'N' THEN 'N' ELSE 'Y' END; -- Y by default
      l_sep_char VARCHAR2(1) := NVL(SUBSTR(p_sep_char,1,1),CHR(9)); -- tab by default
   BEGIN
      assert(p_select IS NOT NULL,'Select statement cannot be empty');
      l_pos := INSTR(l_select,'FROM ');
      assert(l_pos IS NOT NULL,'FROM keyword not found in selet statement');
      l_select := LTRIM(RTRIM(SUBSTR(l_select,l_pos+LENGTH('FROM '))));
      l_pos := INSTR(l_select,' ');
      assert(l_pos IS NOT NULL,'No table name found in select statement');
      l_table_name := UPPER(LTRIM(RTRIM(SUBSTR(l_select,1,l_pos-1))));
      log_utility.log_message('D','table_name='||l_table_name);
      l_cursor := sys.dbms_sql.open_cursor;
      sys.dbms_sql.parse(l_cursor,p_select,sys.dbms_sql.native);
      define_columns(l_cursor);
      t_desc := gt_desc_tabs(l_cursor);
      IF l_tab_mode = 'Y' THEN
         l_line := NULL;
         FOR i IN 1..t_desc.COUNT LOOP
            l_col_name := LOWER(t_desc(i).col_name);
            l_line := CASE WHEN i>1 THEN l_line||l_sep_char END || t_desc(i).col_name;
            l_descr := get_column_descr(l_cursor,l_table_name,l_col_name,'Y');
            l_line := l_line || CASE WHEN l_descr IS NOT NULL THEN l_sep_char||l_descr END;
         END LOOP;
         log_utility.log_message('T',l_line);
      ELSE
         log_utility.log_message('T','#############################################################');
         log_utility.log_message('T',p_select);
         log_utility.log_message('T','#############################################################');
      END IF;
      l_count := sys.dbms_sql.execute(l_cursor);
      l_count := sys.dbms_sql.fetch_rows(l_cursor);
      l_tot_count := 0;
      WHILE l_count > 0 LOOP
         l_tot_count := l_tot_count + 1;
         IF l_tab_mode = 'N' THEN
            log_utility.log_message('T','********** Record #'||l_tot_count||' **********');
         END IF;
         l_line := NULL;
         FOR i IN 1..t_desc.COUNT LOOP
            l_col_name := LOWER(t_desc(i).col_name);
            IF t_desc(i).col_type = 1 /* CHAR */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_char);
            ELSIF t_desc(i).col_type = 2 /* NUMBER */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_number);
               l_char := TO_CHAR(l_number);
            ELSIF t_desc(i).col_type = 12 /* DATE */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_date);
               l_char := REPLACE(TO_CHAR(l_date,g_datetime_mask),' 00:00:00');
            ELSIF t_desc(i).col_type = 180 /* TIMESTAMP */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_timestamp);
               l_char := TO_CHAR(l_timestamp,g_timestamp_mask);
            ELSE
             --raise_application_error(-20000,'Unsupported data type for column: '||l_col_name);
               l_char := '<unsupported data type '||t_desc(i).col_type||'>';
            END IF;
            l_char := RTRIM(l_char);
            l_descr := CASE WHEN l_char IS NOT NULL THEN get_column_descr(l_cursor,l_table_name,l_col_name) ELSE NULL END;
            IF l_tab_mode = 'Y' THEN
               l_line := CASE WHEN i>1 THEN l_line || l_sep_char END || l_char || CASE WHEN l_descr IS NOT NULL THEN l_sep_char || l_descr END;
            ELSE
               IF l_char IS NOT NULL THEN
                  IF l_descr IS NOT NULL THEN
                     log_utility.log_message('T',l_col_name||'='||NVL(l_char,'NULL')||' ('||l_descr||')');
                  ELSE
                     log_utility.log_message('T',l_col_name||'='||NVL(l_char,'NULL'));
                  END IF;
               END IF;
            END IF;
         END LOOP;
         IF l_tab_mode = 'Y' THEN
            log_utility.log_message('T',l_line);
         END IF;
         l_count := sys.dbms_sql.fetch_rows(l_cursor);
      END LOOP;
      close_cursor(l_cursor);
      IF l_tab_mode = 'N' THEN
         log_utility.log_message('T','#############################################################');
         IF l_tot_count = 0 THEN
            log_utility.log_message('T','No records selected');
         ELSIF l_tot_count = 1 THEN
            log_utility.log_message('T','1 record selected');
         ELSE
            log_utility.log_message('T',l_tot_count||' records selected');
         END IF;
         log_utility.log_message('T','#############################################################');
      END IF;
   END;
--#begin public
   ---
   -- Test
   ---
   PROCEDURE test
--#end public
   IS
      l_cursor INTEGER;
      l_select VARCHAR2(32000);
      t_desc sys.dbms_sql.desc_tab;
      l_count INTEGER;
      l_char VARCHAR2(32767);
      l_number NUMBER;
      l_date DATE;
      l_descr VARCHAR2(1000);
   BEGIN
      set_descr_column('sp2_ref_others','descr_fra');
      set_descr_select('sp2_careers','CRR_PK','SELECT descr_fra FROM sp2_ref_statutory_link_groups WHERE skg_id = (SELECT skg_id FROM sp2_careers WHERE per_id=:per_id AND crr_seq_nbr=:crr_seq_nbr)');
      l_cursor := sys.dbms_sql.open_cursor;
      l_select := 'SELECT * FROM sp2_car_grades WHERE per_id=:p_per_id AND oth_id_purpose=8000 ORDER BY crr_seq_nbr, date_from';
      log_utility.log_message('T',l_select);
      sys.dbms_sql.parse(l_cursor,l_select,sys.dbms_sql.native);
      define_columns(l_cursor);
      sys.dbms_sql.bind_variable(l_cursor, ':p_per_id', 48016);
      l_count := sys.dbms_sql.execute(l_cursor);
      l_count := sys.dbms_sql.fetch_rows(l_cursor);
      WHILE l_count > 0 LOOP
--         sys.dbms_output.put('crr_seq_nbr='||get_col_val(l_cursor,'CRR_SEQ_NBR'));
         l_descr := get_column_descr(l_cursor,'sp2_car_grades','CRR_SEQ_NBR');
       --IF l_descr IS NOT NULL THEN
       --   sys.dbms_output.put(' ('||l_descr||')');
       --END IF;
       --log_utility.log_message('T','');
       --log_utility.log_message('T','date_from='||get_col_val(l_cursor,'DATE_FROM'));
       --log_utility.log_message('T','oth_id_purpose='||get_col_val(l_cursor,'OTH_ID_PURPOSE'),FALSE);
         l_descr := get_column_descr(l_cursor,'sp2_car_grades','OTH_ID_PURPOSE');
       --IF l_descr IS NOT NULL THEN
       --   log_utility.log_message('T',' ('||l_descr||')',FALSE);
       --END IF;
       --log_utility.log_message('T','');
         l_count := sys.dbms_sql.fetch_rows(l_cursor);
      END LOOP;
   END;
--#begin public
   ---
   -- Load table descriptors
   ---
   PROCEDURE load_table_descriptors (
      p_owner IN VARCHAR2 := NULL
   )
--#end public
   IS
      CURSOR c_tab (
         p_owner IN VARCHAR2
      ) IS
         SELECT *
           FROM sys_all_table_descriptors
          WHERE owner = p_owner
      ;
      l_owner all_objects.owner%TYPE := NVL(p_owner,g_owner);
      l_count INTEGER := 0;
   BEGIN
      FOR r_tab IN c_tab(l_owner) LOOP
         l_count := l_count + 1;
         set_descr_column(r_tab.table_name, r_tab.column_name);
      END LOOP;
--#ifdef SYSPER2
      -- If not found and not in production, copy them from production schema
      IF l_count = 0 AND l_owner != 'APP_SP2_P' THEN
         log_utility.log_message('D','Copying table descriptors from APP_SP2_P into '||l_owner);
         INSERT INTO sys_all_table_descriptors (
            owner, table_name, column_name
         )
         SELECT l_owner, table_name,column_name
           FROM sys_all_table_descriptors
          WHERE owner = 'APP_SP2_P'
         ;
         load_table_descriptors('APP_SP2_P');
      END IF;
--#endif
   END;
--#begin public
   ---
   -- Load constraint descriptors
   ---
   PROCEDURE load_constraint_descriptors (
      p_owner IN VARCHAR2 := NULL
   )
--#end public
   IS
      CURSOR c_con (
         p_owner IN VARCHAR2
      ) IS
         SELECT *
           FROM sys_all_constraint_descriptors
          WHERE owner = p_owner
      ;
      l_owner all_objects.owner%TYPE := NVL(p_owner,g_owner);
      l_count INTEGER := 0;
   BEGIN
      FOR r_con IN c_con(l_owner) LOOP
         l_count := l_count + 1;
         set_descr_select(r_con.table_name,r_con.constraint_name,r_con.select_statement);
      END LOOP;
--#ifdef SYSPER2
      -- If not found and not in production, copy them from production schema
      IF l_count = 0 AND l_owner != 'APP_SP2_P' THEN
         log_utility.log_message('D','Copying constraint descriptors from APP_SP2_P into '||l_owner);
         INSERT INTO sys_all_constraint_descriptors (
            owner, table_name, constraint_name, select_statement
         )
         SELECT l_owner, table_name, constraint_name, select_statement
           FROM sys_all_constraint_descriptors
          WHERE owner = 'APP_SP2_P'
         ;
         load_constraint_descriptors('APP_SP2_P');
      END IF;
--#endif
   END;
--#begin public
   ---
   -- Load constraint descriptors
   ---
   PROCEDURE load_object_comments (
      p_owner IN VARCHAR2 := NULL
   )
--#end public
   IS
      CURSOR c_aoc (
         p_owner IN VARCHAR2
       , p_language_code IN VARCHAR2
      )
      IS
         SELECT *
           FROM sys_all_object_comments
          WHERE owner = p_owner
            AND language_code = p_language_code
      ;
      l_pos INTEGER;
      l_owner all_objects.owner%TYPE := NVL(p_owner,g_owner);
      l_count INTEGER := 0;
   BEGIN
      FOR i IN 1..2 LOOP
         FOR r_aoc IN c_aoc(l_owner, CASE WHEN i = 1 THEN 'FRA' ELSE 'ENG' END) LOOP
            l_count := l_count + 1;
            -- Check object existence in cache
            l_pos := get_object_pos(
                p_object_type=>r_aoc.object_type
               ,p_object_name=>r_aoc.object_name
            );
            -- Add object if not found
            IF l_pos IS NULL THEN
               IF r_aoc.object_type = 'TABLE' THEN
                  -- Add table
                  l_pos := add_object(
                      p_object_type=>r_aoc.object_type
                     ,p_table_name=>r_aoc.object_name
                  );
               ELSIF r_aoc.object_type = 'COLUMN' THEN
                  -- Add column
                  l_pos := add_object(
                      p_object_type=>r_aoc.object_type
                     ,p_table_name=>SUBSTR(r_aoc.object_name,1,INSTR(r_aoc.object_name,'.')-1)
                     ,p_column_name=>SUBSTR(r_aoc.object_name,INSTR(r_aoc.object_name,'.')+1)
                  );
               END IF;
            END IF;
            -- Set comment according to language
            IF i = 1 THEN
               g_cache(l_pos).object_comment_fra := r_aoc.object_comment;
            ELSE
               g_cache(l_pos).object_comment_eng := r_aoc.object_comment;
            END IF;
         END LOOP;
      END LOOP;
--#ifdef SYSPER2
      -- If not found and not in production, copy them from production schema
      IF l_count = 0 AND l_owner != 'APP_SP2_P' THEN
         log_utility.log_message('D','Copying object comments from APP_SP2_P into '||l_owner);
         INSERT INTO sys_all_object_comments (
            owner, object_type, object_name
          , language_code, object_comment
         )
         SELECT l_owner, object_type, object_name
              , language_code, object_comment
           FROM sys_all_object_comments
          WHERE owner = 'APP_SP2_P'
         ;
         load_object_comments('APP_SP2_P');
      END IF;
--#endif
   END;
--#begin public
   ---
   -- Get object comment from cache in given language
   ---
   FUNCTION get_object_comment (
      p_object_type IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_language_code IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      l_pos INTEGER;
   BEGIN
      assert(p_language_code IN ('FRA','ENG'),'Language must be FRA or ENG');
      -- Check object existence in cache
      l_pos := get_object_pos(
          p_object_type=>p_object_type
         ,p_object_name=>p_object_name
      );
      IF l_pos > 0 THEN
         IF p_language_code = 'FRA' THEN
            RETURN g_cache(l_pos).object_comment_fra;
         ELSIF p_language_code = 'ENG' THEN
            RETURN g_cache(l_pos).object_comment_eng;
         END IF;
      END IF;
      RETURN NULL;
   END;
--#begin public
   ---
   --- Populate a ODCIVarchar2List with a string
   ---
   FUNCTION get_str_array (
      p_str IN VARCHAR2
     ,p_sep IN VARCHAR2 := ','
   )
   RETURN sys.odcivarchar2list
--#end public
   IS
      t_tab sys.odcivarchar2list := sys.odcivarchar2list();
      l_token  VARCHAR2(100);
      i PLS_INTEGER := 1;
   BEGIN
      LOOP
         l_token := extract_string(p_str,i,p_sep);
         EXIT WHEN l_token IS NULL;
         t_tab.EXTEND;
         t_tab(t_tab.COUNT) := l_token;
         i := i + 1;
      END LOOP;
      RETURN t_tab ;
   END;
--#begin public
   ---
   --- Instanciate the package (run package initialisation code)
   ---
   PROCEDURE instanciate
--#end public
   IS
      l_dummy VARCHAR2(1);
   BEGIN
      -- Do nothing (just run package initialisation code)
      NULL;
      l_dummy := 'x';
   END;
BEGIN
   refresh_internal_cache;
END;
/