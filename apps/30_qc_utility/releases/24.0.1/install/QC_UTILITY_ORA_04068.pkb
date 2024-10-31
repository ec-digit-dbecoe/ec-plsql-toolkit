CREATE OR REPLACE PACKAGE BODY qc_utility_ora_04068 IS
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
   exec gen_utility.generate('PACKAGE BODY plparse','-f');
*/
--@--#pragma reversible
   k_token_eof CONSTANT INTEGER := 0;
   k_token_id  CONSTANT INTEGER := 1;
   k_token_simple_str CONSTANT INTEGER := 2;
   k_token_double_str CONSTANT INTEGER := 3;
   k_token_semicolon CONSTANT INTEGER := 4;
   k_token_unknown CONSTANT INTEGER := 99;
   TYPE token IS RECORD (
      kind INTEGER
     ,val NUMBER
     ,str VARCHAR2(4000)
   );
   t_source sys.dbms_sql.varchar2a;
   g_type user_source.type%TYPE;
   g_name user_source.name%TYPE;
   k_open_comment_char1 CONSTANT CHAR := '/';
   k_open_comment_char2 CONSTANT CHAR := '*';
   k_close_comment_char1 CONSTANT CHAR := '*';
   k_close_comment_char2 CONSTANT CHAR := '/';
   k_end_of_file CONSTANT VARCHAR2(3) := 'eof';
--@--#execute gen_utility.get_custom_code('PACKAGE BODY','PLCC','parser-decl')
--#if 0
   t_stdin sys.dbms_sql.varchar2a;
   t_stdout sys.dbms_sql.varchar2a;
   t_stderr sys.dbms_sql.varchar2a;
   g_line_no INTEGER;
   g_col_no INTEGER;
   g_max_col INTEGER;
   g_cur_char VARCHAR2(3);
   g_nxt_char VARCHAR2(3);
--#endif 0
--@--#if 0
--@/*
--@--#endif
   PROCEDURE compilation_error (
      p_err_msg IN VARCHAR2
     ,p_line_no IN INTEGER := NULL
     ,p_col_no IN INTEGER := NULL
   )
   IS
      l_line_no INTEGER := NVL(p_line_no,g_line_no);
      l_col_no INTEGER := NVL(p_col_no,g_col_no-1);
   BEGIN
      IF l_line_no IS NULL THEN
         t_stderr(t_stderr.COUNT) := 'Error: '||p_err_msg;
      ELSE
         t_stderr(t_stderr.COUNT) := 'Error at line '||l_line_no||CASE WHEN l_col_no='' THEN '' ELSE ' col '||l_col_no END||': '||p_err_msg;
         t_stderr(t_stderr.COUNT) := t_stdin(l_line_no);
         IF l_col_no IS NOT NULL THEN
            t_stderr(t_stderr.COUNT) := LPAD('^',l_col_no);
         END IF;
      END IF;
      raise_application_error(-20000,t_stderr(0));
   END;
   PROCEDURE raise_error (
      p_errno INTEGER
   )
   IS
      l_errmsg VARCHAR2(100);
   BEGIN
      CASE
      WHEN p_errno = 1 THEN l_errmsg := '''.'' must be followed by decimal part';
      WHEN p_errno = 2 THEN l_errmsg := '''E'' must be followed by exponent part';
      WHEN p_errno = 3 THEN l_errmsg := 'identificator must begin with letter';
      WHEN p_errno = 4 THEN l_errmsg := 'sign must be followed by number';
      WHEN p_errno = 5 THEN l_errmsg := 'illegal character';
      WHEN p_errno = 6 THEN l_errmsg := '''{'' without corresponding ''}''';
      WHEN p_errno = 7 THEN l_errmsg := '''}'' without corresponding ''{''';
      WHEN p_errno = 8 THEN l_errmsg := 'unexpected sequence of syntaxical entity';
      WHEN p_errno = 9 THEN l_errmsg := '';
      WHEN p_errno = 10 THEN l_errmsg := 'syntax error: unexpected symbol: ';--||sym_text(topsym.kind);
      END CASE;
      compilation_error(l_errmsg);
   END;
--@--#if 0
--@*/
--@--#endif
--@--#execute gen_utility.get_custom_code('PACKAGE BODY','PLCC','parser-body')
--#if 0
   PROCEDURE read_char
   IS
   BEGIN
      IF g_cur_char = k_end_of_file THEN
         RETURN;
      END IF;
      g_cur_char := NULL;
      g_nxt_char := NULL;
      IF g_line_no IS NULL THEN
         IF t_stdin.COUNT = 0 THEN
            g_cur_char := k_end_of_file;
            g_nxt_char := k_end_of_file;
            RETURN;
         END IF;
         g_line_no := t_stdin.FIRST;
         g_col_no := 1;
         g_max_col := NVL(LENGTH(t_stdin(g_line_no)),0);
--log_utility.log_message(0,'T','1st: line='||g_line_no||',col_no='||g_col_no||',max='||g_max_col);
      END IF;
      WHILE g_col_no > g_max_col LOOP
         IF t_stdin.NEXT(g_line_no) IS NULL THEN
            g_cur_char := k_end_of_file;
            RETURN;
         END IF;
         g_line_no := t_stdin.NEXT(g_line_no);
         g_col_no := 1;
         g_max_col := NVL(LENGTH(t_stdin(g_line_no)),0);
--log_utility.log_message(0,'T','loop: line='||g_line_no||',col_no='||g_col_no||',max='||g_max_col);
      END LOOP;
      g_cur_char := NVL(SUBSTR(t_stdin(g_line_no),g_col_no,1),k_end_of_file);
      g_col_no := g_col_no + 1;
      g_nxt_char := NVL(SUBSTR(t_stdin(g_line_no),g_col_no,1),k_end_of_file);
--log_utility.log_message(0,'T','char='||g_cur_char);
   END;
   ----------------------------------------------------------------------
   FUNCTION read_id (
      p_word_sep IN VARCHAR2 := '_'
   )
   RETURN VARCHAR2
   IS
      l_str VARCHAR2(100);
   BEGIN
      WHILE g_cur_char BETWEEN 'a' AND 'z'
         OR g_cur_char BETWEEN 'A' AND 'Z'
         OR g_cur_char BETWEEN '0' AND '9'
         OR NVL(INSTR(p_word_sep,g_cur_char),0) > 0
      LOOP
         l_str := l_str || g_cur_char;
         read_char;
         EXIT WHEN g_cur_char = k_end_of_file;
      END LOOP;
      RETURN l_str;
   END;
   --------------------------------------------------------------------------------
   FUNCTION read_quoted_string (
      p_delim IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_str VARCHAR2(4000);
   BEGIN
      read_char; -- skip beg delimiter
      WHILE g_cur_char != p_delim OR (g_cur_char = p_delim AND g_nxt_char = p_delim) LOOP
         IF g_cur_char=k_end_of_file THEN
            compilation_error('Unterminated quoted string!');
         END IF;
         BEGIN
            l_str := l_str || g_cur_char;
         EXCEPTION
            WHEN OTHERS THEN
               l_str := NULL;
         END;
         IF g_cur_char = p_delim AND g_nxt_char = p_delim THEN
            read_char; -- skip doubled delimiter
         END IF;
         read_char;
      END LOOP;
      read_char; -- skip end delimiter
      RETURN l_str;
   END;
   --------------------------------------------------------------------------------
   FUNCTION read_exact_string (
      p_str IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      -- Save input state
      l_line_no INTEGER := g_line_no;
      l_col_no INTEGER := g_col_no;
      l_cur_char VARCHAR2(1) := g_cur_char;
   BEGIN
      FOR i IN 1..LENGTH(p_str) LOOP
         IF g_cur_char != SUBSTR(p_str,i,1) THEN
            -- Restore input state
            g_line_no := l_line_no;
            g_col_no := l_col_no;
            g_cur_char := l_cur_char;
            RETURN FALSE; -- not found
         END IF;
         read_char;
      END LOOP;
      RETURN TRUE; -- found
   END;
   --------------------------------------------------------------------------------
   FUNCTION read_integer
   RETURN INTEGER
   IS
      l_int INTEGER;
   BEGIN
      l_int := g_cur_char - '0';
      read_char;
      WHILE g_cur_char BETWEEN '0' AND '9' LOOP
         l_int := l_int * 10 + g_cur_char - '0';
         read_char;
      END LOOP;
      RETURN l_int;
   END;
   --------------------------------------------------------------------------------
   FUNCTION read_date (
      p_date OUT VARCHAR2
   )
   RETURN BOOLEAN
   IS
      -- Save input state
      l_line_no INTEGER := g_line_no;
      l_col_no INTEGER := g_col_no;
      l_cur_char VARCHAR2(1) := g_cur_char;
      -- Date components
      l_dd INTEGER;
      l_mm INTEGER;
      l_yyyy INTEGER;
      PROCEDURE finally IS
      BEGIN
         -- Restore input state
         g_line_no := l_line_no;
         g_col_no := l_col_no;
         g_cur_char := l_cur_char;
      END;
   BEGIN
      IF g_cur_char BETWEEN '0' AND '3' THEN
         l_dd := read_integer;
         IF l_dd BETWEEN 1 AND 31 THEN
            IF g_cur_char = '/' THEN
               read_char;
               IF g_cur_char BETWEEN '0' AND '1' THEN
                  l_mm := read_integer;
                  IF l_mm BETWEEN 1 AND 12 THEN
                     IF g_cur_char = '/' THEN
                        read_char;
                        IF g_cur_char BETWEEN '0' AND '9' THEN
                           l_yyyy := read_integer;
                           IF l_yyyy BETWEEN 0 AND 9999 THEN
                              BEGIN
                                 p_date := TRIM(TO_CHAR(l_dd,'09'))||'/'||TRIM(TO_CHAR(l_mm,'09'))||'/'||TRIM(TO_CHAR(l_yyyy,'0999'));
                                 RETURN TRUE;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    finally;
                                    RETURN FALSE;
                              END;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
      finally;
      RETURN FALSE; -- not found
   END;
   --------------------------------------------------------------------------------
   FUNCTION read_real
   RETURN NUMBER
   IS
      l_int INTEGER := 0;
      l_dec INTEGER := 0;
      l_exp INTEGER := 0;
      l_sig INTEGER := 1;
      l_val NUMBER;
   BEGIN
      IF g_cur_char BETWEEN '0' AND '9' THEN
         l_int := read_integer;
         IF g_cur_char = '.' THEN
            read_char;
            IF g_cur_char BETWEEN '0' AND '9' THEN
               l_dec := read_integer;
            ELSE
               raise_error(1);
            END IF;
         END IF;
      ELSIF g_cur_char = '.' THEN
         read_char;
         IF g_cur_char BETWEEN '0' AND '9' THEN
            l_dec := read_integer;
         ELSE
            raise_error(1);
         END IF;
      END IF;
      IF g_cur_char = 'E' THEN
         read_char;
         IF g_cur_char IN ('+','-') THEN
            IF g_cur_char = '-' THEN
               l_sig := -1;
            END IF;
            read_char;
         END IF;
         IF g_cur_char BETWEEN '0' AND '9' THEN
            l_exp := read_integer;
         ELSE
            raise_error(2);
         END IF;
      END IF;
      l_val := l_int;
      IF l_dec > 0 THEN
         l_val := l_val + l_dec / POWER(10,TRUNC(LN(l_dec)/LN(10)+1));
      END IF;
      IF l_exp > 0 THEN
         IF l_sig < 0 THEN
            l_val := l_val / POWER(10,TRUNC(l_exp));
         ELSE
            l_val := l_val * POWER(10,TRUNC(l_exp));
         END IF;
      END IF;
      RETURN l_val;
   END;
   --------------------------------------------------------------------------------
--#endif 0
   ---
   -- Get source code of a database object (e.g. package spec or body)
   ---
   PROCEDURE read_stdin (
      p_type IN VARCHAR2
    , p_name IN VARCHAR2
   )
   IS
      CURSOR c_src (
         p_type IN VARCHAR2
       , p_name IN VARCHAR2
      )
      IS
         SELECT text
           FROM user_source
          WHERE type = p_type
            AND name = p_name
          ORDER BY line
      ;
   BEGIN
      t_stdin.DELETE;
      g_line_no := NULL;
      g_col_no := NULL;
      g_max_col := NULL;
      g_cur_char := NULL;
      g_nxt_char := NULL;
      OPEN c_src(p_type,p_name);
      FETCH c_src BULK COLLECT INTO t_stdin;
      CLOSE c_src;
      read_char;
   END;
   ---
   -- Read a commment
   ---
   PROCEDURE read_comment IS
      l_line_no INTEGER;
      l_col_no INTEGER;
   BEGIN
      l_line_no := g_line_no;
      l_col_no := g_col_no;
      WHILE g_cur_char != k_end_of_file AND NOT (g_cur_char = k_close_comment_char1 AND g_nxt_char = k_close_comment_char2) LOOP
         read_char;
      END LOOP;
      IF g_cur_char=k_end_of_file THEN
         compilation_error(k_open_comment_char1||k_open_comment_char2||' without matching '||k_close_comment_char1||k_close_comment_char2,l_line_no,l_col_no);
      END IF;
      read_char; -- skip 2nd char
      read_char; -- read ahead
   END;
   ---
   --  Skip source code till end of line
   ---
   PROCEDURE skip_to_eol IS
   BEGIN
      WHILE g_cur_char != k_end_of_file AND g_cur_char != CHR(10) LOOP
         read_char;
      END LOOP;
   END;
   ---
   -- Read a symbol
   ---
   FUNCTION read_symbol
   RETURN token
   IS
      l_sym token;
   BEGIN
      <<again>>
      WHILE g_cur_char IN (' ',CHR(9),CHR(10),CHR(13)) LOOP
         read_char;
      END LOOP;
      IF g_cur_char = k_end_of_file THEN
         l_sym.kind := k_token_eof;
      ELSIF g_cur_char BETWEEN 'A' AND 'Z'
      OR g_cur_char BETWEEN 'a' AND 'z'
      OR g_cur_char = '_'
      THEN
         l_sym.kind := k_token_id;
         l_sym.str := UPPER(read_id);
      ELSIF g_cur_char = '/' AND g_nxt_char = '*' THEN
         read_char; -- skip 2nd char
         read_comment;
         GOTO again;
      ELSIF g_cur_char = '-' AND g_nxt_char = '-' THEN
         read_char; -- skip 2nd char
         skip_to_eol;
         goto again;
      ELSIF g_cur_char = '''' THEN
         l_sym.kind := k_token_simple_str;
         l_sym.str := read_quoted_string('''');
      ELSIF g_cur_char = '"' THEN
         l_sym.kind := k_token_double_str;
         l_sym.str := read_quoted_string('"');
      ELSIF g_cur_char = ';' THEN
         l_sym.kind := k_token_semicolon;
         l_sym.str := g_cur_char;
         read_char;
      ELSE
         l_sym.kind := k_token_unknown;
         l_sym.str := g_cur_char;
         read_char;
      END IF;
   --sys.dbms_output.put_line(g_line_no||','||g_col_no||': '||l_sym.kind||' '||l_sym.str);
      RETURN l_sym;
   END;
   ---
   -- Check if a package contains global variables
   ---
   FUNCTION check_global_variables (
      p_type IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN INTEGER
   IS
      l_char VARCHAR2(1);
      l_sym token;
      l_state INTEGER := 1;
   BEGIN
      read_stdin(p_type,p_name);
      l_sym := read_symbol;
      WHILE l_sym.kind != k_token_eof LOOP
         IF l_state = 1 THEN
            IF l_sym.kind = k_token_id AND l_sym.str = 'PACKAGE' THEN
               l_sym := read_symbol;
               WHILE l_sym.kind != k_token_eof
                 AND l_sym.kind != k_token_semicolon
                 AND NOT (l_sym.kind = k_token_id AND l_sym.str IN ('AS','IS'))
               LOOP
                  l_sym := read_symbol;
               END LOOP;
               IF NOT (l_sym.kind = k_token_id AND l_sym.str IN ('AS','IS')) THEN
                  RETURN 0 - g_line_no;
               END IF;
               l_state := l_state + 1;
            ELSE
               RETURN 0 - g_line_no;
            END IF;
         ELSIF l_state = 2 THEN
            IF l_sym.kind = k_token_id THEN
               IF l_sym.str IN ('PRAGMA') THEN
                  l_sym := read_symbol;
                  IF l_sym.kind = k_token_id AND l_sym.str = 'SERIALLY_REUSABLE' THEN
                     -- Package is not (or less) subject to ORA-04068
                     -- Stop search here!
                     RETURN g_line_no;
                  END IF;
                  WHILE l_sym.kind != k_token_eof AND l_sym.kind != k_token_semicolon LOOP
                     l_sym := read_symbol;
                  END LOOP;
                  IF l_sym.kind != k_token_semicolon THEN
                     RETURN 0 - g_line_no;
                  END IF;
               ELSIF l_sym.str IN ('TYPE','SUBTYPE') THEN
                  l_sym := read_symbol;
                  WHILE l_sym.kind != k_token_eof AND l_sym.kind != k_token_semicolon LOOP
                     l_sym := read_symbol;
                  END LOOP;
                  IF l_sym.kind != k_token_semicolon THEN
                     RETURN 0 - g_line_no;
                  END IF;
               ELSIF l_sym.str IN ('PROCEDURE','FUNCTION') THEN
                  l_sym := read_symbol;
                  WHILE l_sym.kind != k_token_eof
                    AND l_sym.kind != k_token_semicolon
                    AND NOT (l_sym.kind = k_token_id AND l_sym.str IN ('AS','IS'))
                  LOOP
                     l_sym := read_symbol;
                  END LOOP;
                  IF l_sym.kind = k_token_eof THEN
                     RETURN 0 - g_line_no;
                  END IF;
                  IF l_sym.kind = k_token_id AND l_sym.str IN ('AS','IS') THEN
                     -- This is not a forward declaration as IS or AS was found before semi-colon
                     -- No variable/cursor can be defined after a procedure/function body
                     -- So we can stop parsing here!
                     l_state := l_state + 1;
                     RETURN g_line_no;
                  END IF;
                  -- When this point is reached, a forward declaration has been found
                  -- Search for global variables must continue...
               ELSIF l_sym.str IN ('END') THEN
                  l_state := l_state + 1;
                  l_sym := read_symbol;
                  IF l_sym.kind IN (k_token_id,k_token_double_str) THEN
                     l_sym := read_symbol;
                  END IF;
                  IF l_sym.kind != k_token_semicolon THEN
                     RETURN 0 - g_line_no;
                  END IF;
               ELSE
                  RETURN 0 - g_line_no;
               END IF;
            END IF;
         ELSE
            RETURN 0 - g_line_no;
         END IF;
         l_sym := read_symbol;
      END LOOP;
      RETURN g_line_no;
   END;
END;
/
