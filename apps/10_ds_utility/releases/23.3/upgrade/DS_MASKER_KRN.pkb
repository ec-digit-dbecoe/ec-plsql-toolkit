CREATE OR REPLACE PACKAGE BODY ds_masker_krn AS
---
-- Copyright (C) 2023 European Commission
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
-- To generate package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE ds_masker_krn', '-f');
--
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
   ---
   -- Set seed
   -- 
   PROCEDURE set_seed (
      p_seed IN VARCHAR2
   )
   IS
   BEGIN
      -- Set seed
      IF p_seed IS NOT NULL THEN
         -- Convert to US7ASCII to avoid ORA-06502 raised with special chars
         sys.dbms_random.seed(SUBSTR(CONVERT(p_seed,'US7ASCII'),1,2000));
      END IF;
   END;
   ---
   -- Reset seed
   -- 
   PROCEDURE reset_seed (
      p_seed IN VARCHAR2
   )
   IS
      l_seed VARCHAR2(30);
   BEGIN
      -- Set seed
      IF p_seed IS NOT NULL THEN
         l_seed := TO_CHAR(SYSTIMESTAMP,ds_utility_var.g_default_seed_format);
         sys.dbms_random.seed(l_seed);
      END IF;
   END;
   ---
   -- Generate a random number between 1 and N
   -- With a linearly decreasing probability
   ---
   FUNCTION random_integer2(n INTEGER)
   RETURN INTEGER
   IS
      l_high INTEGER := n*(n+1)/2;
      l_rand INTEGER;
      l_cumul INTEGER;
   BEGIN
      l_rand := random_integer(1,l_high);
      l_cumul := 0;
      FOR i IN REVERSE 2..n LOOP
         l_cumul := l_cumul + i;
         IF l_rand <= l_cumul THEN
            RETURN n - i + 1;
         END IF;
      END LOOP;
      RETURN n;
   END;
--#begin public
   ---
   -- Return a random value (like dbms_random.value but with a seed)
   ---
   FUNCTION random_value (
      p_seed IN VARCHAR2 := NULL
   )
   RETURN NUMBER
--#end public
   IS
      l_number NUMBER;
   BEGIN
      set_seed(p_seed);
      RETURN DBMS_RANDOM.value;
   END random_value;
--#begin public
   ---
   -- Return a random integer between 2 integers
   ---
   FUNCTION random_integer (
      p_min_value IN INTEGER := -2147483648
    , p_max_value IN INTEGER :=  2147483647
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN INTEGER
--#end public
   IS
      l_rand NUMBER;
   BEGIN
      set_seed(p_seed);
      l_rand := SYS.DBMS_RANDOM.value(p_min_value, p_max_value+1);
      reset_seed(p_seed);
      RETURN TRUNC(l_rand);
   END random_integer;
   -- Is a character alphanumeric?
   FUNCTION is_alnum (p_char IN CHAR)
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_char BETWEEN 'a' AND 'z'
          OR p_char BETWEEN 'A' and 'Z'
          OR p_char BETWEEN '0' AND '9';
   END;
--#begin public
   ---
   -- Generate a value based on a regular expression
   -- See: https://www.regular-expressions.info/
   -- Note: this is NOT the Oracle implementation!
   --
   FUNCTION random_value_from_regexp (
      p_regexp IN VARCHAR2
    , p_seed IN VARCHAR2 := NULL
    , p_charset IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      lk_charset CONSTANT VARCHAR2(256 CHAR) := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ';
      l_charset VARCHAR2(256 CHAR); -- charset to be used when resolving negated character classes
      l_regexp VARCHAR2(4000);      -- regular expression to evaluate (initial and after 1st pass)
      l_len PLS_INTEGER;            -- length of regular expression
      l_pos PLS_INTEGER;            -- position of current evaluated character
      l_vb_cnt PLS_INTEGER;         -- number of vertical bars ("|") currently processed
      l_max_vb_cnt PLS_INTEGER;     -- maximum number of vertical bars encountered so far
      TYPE l_string_table_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
      t_groups l_string_table_type;
      ---
      -- Recursively evaluate a regular expression. When an operator or a "(" is
      -- encountered, expression to its right is evaluated first until the
      -- end of the expression is reached or a ")" is found or an operator
      -- with a lower priority is found. Operators with the same precedence
      -- are evaluated from left to right.
      -- Operator precedence:
      --      1.  Collation-related bracket symbols: [==] [::] [..] (only valid inside []!)
      --      2.	Escape characters: backslash (\<special character>)
      --      3.  Bracket expression: [] (can be nested)
      --      4.	Grouping: () and back reference \n (from 1 to 9)
      --      5.	Quantifiers:
      --            o	* (asterisk): Matches zero or more occurrences.
      --            o	+ (plus): Matches one or more occurrences.
      --            o	? (question mark): Matches zero or one occurrence.
      --            o	{n} (curly braces): Matches exactly n occurrences.
      --            o	{n,} (curly braces): Matches at least n occurrences.
      --            o	{n,m} (curly braces): Matches between n and m occurrences.
      --      6.	Concatenation: Patterns are concatenated by placing them next to each other.
      --      7.  Anchoring: ^ $
      --      8.	Alternation: pipe (|)
      ---
      FUNCTION parse_regexp (
         p_regexp IN VARCHAR2                -- regular expression to parse
       , p_pass IN PLS_INTEGER               -- pass number: 1 or 2
       , p_level IN PLS_INTEGER := 0         -- recursive level (0=first)
       , p_prec IN PLS_INTEGER := 99         -- precedence of previous operator (99=lowest)
       , p_bracket_level IN PLS_INTEGER := 0 -- brackets level
       , p_grp IN PLS_INTEGER := 1           -- group number
      )
      RETURN VARCHAR2
      IS
         l_char1 VARCHAR2(1);       -- 1st character of the string
         l_char2 VARCHAR2(1);       -- 2nd character of the string
         l_prec INTEGER := 99;      -- operator precedence
         l_res1 VARCHAR2(4000);     -- global result for a call leve
         l_res2 VARCHAR2(4000);     -- intermediate result of a step
         l_class VARCHAR2(10);
         l_non_matching BOOLEAN;
         l_non_capture BOOLEAN;
         l_pos1 PLS_INTEGER;
         l_pos2 PLS_INTEGER;
         l_min PLS_INTEGER;
         l_max PLS_INTEGER;
         l_cnt PLS_INTEGER;
         l_idx PLS_INTEGER;
         l_grp PLS_INTEGER := p_grp;
         -- Is the given character a hexadecimal digit?
         FUNCTION is_xdigit (
            p_char IN VARCHAR2
         )
         RETURN BOOLEAN
         IS
         BEGIN
            RETURN INSTR('ABCDEFabcdef01234567890',p_char) > 0;
         END;
         -- Read a 2 digit hexadecimal number and returns its decimal value
         FUNCTION read_hex
         RETURN PLS_INTEGER
         IS
            l_val PLS_INTEGER := 0;
            l_char1 VARCHAR2(1);
         BEGIN
            FOR i IN 1..2 LOOP
               l_val := l_val * 16;
               l_char1 := SUBSTR(p_regexp,l_pos,1);
               l_pos := l_pos + 1;
               IF l_char1 BETWEEN '0' AND '9' THEN
                  l_val := l_val + ASCII(l_char1) - ASCII('0');
               ELSIF l_char1 BETWEEN 'A' AND 'Z' THEN
                  l_val := l_val + 10 + ASCII(l_char1) - ASCII('A');
               ELSIF l_char1 BETWEEN 'a' AND 'z' THEN
                  l_val := l_val + 10 + ASCII(l_char1) - ASCII('a');
               END IF;
            END LOOP;
            RETURN l_val;
         END;
         -- Return characters of set 1 that are not in set 2 (i.e. set 1 minus set 2)
         FUNCTION charset_minus (
            p_charset1 IN VARCHAR2
          , p_charset2 IN VARCHAR2
         )
         RETURN VARCHAR2 IS
            l_res VARCHAR2(4000);
            l_chr VARCHAR2(1 CHAR);
         BEGIN
            FOR l_pos IN 1..LENGTH(p_charset1) LOOP
               l_chr := SUBSTR(p_charset1,l_pos,1);
               IF INSTR(p_charset2, l_chr) = 0 THEN
                  l_res := l_res || l_chr;
               END IF;
            END LOOP;
            RETURN l_res;
         END;
      BEGIN
         WHILE l_pos <= l_len LOOP
            l_char1 := SUBSTR(p_regexp,l_pos,1);
            l_char2 := SUBSTR(p_regexp,l_pos+1,1);
            l_pos1 := l_pos; -- remember position of very first character
            IF p_bracket_level > 0 AND l_char1 = '[' AND l_char2 IN ('=',':','.') AND INSTR(p_regexp, l_char2||']',l_pos+2) > 0 THEN
               l_prec := 1;
               l_pos := l_pos + 2; -- skip "[%"
               l_pos2 := INSTR(p_regexp, l_char2||']',l_pos);
               l_class := SUBSTR(p_regexp, l_pos, LEAST(l_pos2-l_pos,10));
               l_res2 := '';
               IF l_char2 = ':' THEN
                  l_res2 := CASE WHEN l_class = 'alnum'  THEN 'a-zA-Z0-9'
                                 WHEN l_class = 'alpha'  THEN 'a-zA-Z'
                                 WHEN l_class = 'ascii'  THEN '\x00-\x7F'
                                 WHEN l_class = 'blank'  THEN ' \t'
                                 WHEN l_class = 'cntrl'  THEN '\x00-\x1F\x7F'
                                 WHEN l_class = 'digit'  THEN '0-9'
                                 WHEN l_class = 'graph'  THEN '\x21-\x7E'
                                 WHEN l_class = 'lower'  THEN 'a-z'
                                 WHEN l_class = 'print'  THEN '\x20-\x7E'
                                 WHEN l_class = 'punct'  THEN '!"\#$%&''()*+,\-./:;<=>?@\[\\\]^_‘{|}~'
                                 WHEN l_class = 'space'  THEN ' \t\r\n\v\f'
                                 WHEN l_class = 'upper'  THEN 'A-Z'
                                 WHEN l_class = 'word'   THEN 'A-Za-z0-9_'
                                 WHEN l_class = 'xdigit' THEN 'A-Fa-f0-9'
                                 -- Following classes are an extension specific to this tool!
                                 WHEN l_class = 'vowel'  THEN 'aeiouyAEIOUY' -- mixed case vowels
                                 WHEN l_class = 'lvowel' THEN 'aeiouy' -- lowercase vowels
                                 WHEN l_class = 'uvowel' THEN 'AEIOUY' -- uppercase vowels
                                 WHEN l_class = 'conso'  THEN 'bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ' -- mixed case consonants
                                 WHEN l_class = 'lconso' THEN 'bcdfghjklmnpqrstvwxz' -- lowercase consonants
                                 WHEN l_class = 'uconso' THEN 'BCDFGHJKLMNPQRSTVWXZ' -- uppercase consonants
                             END;
                  assert(l_res2 IS NOT NULL,'invalid character class ("'||l_class||'") at position '||l_pos);
               ELSIF l_char2 = '.' THEN
                  -- Not implemented!
                  l_res2 := l_class; -- return the character itself
               ELSIF l_char2 = '=' THEN
                  l_res2 := l_class; -- by default return the character itself
                  --LOWER: µàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ
                  --UPPER: ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ
                  l_res2 := CASE WHEN l_class = 'a' THEN 'aàáâãäå'
                                 WHEN l_class = 'e' THEN 'eèéêë'
                                 WHEN l_class = 'i' THEN 'iìíîï'
                                 WHEN l_class = 'o' THEN 'oòóôõö'
                                 WHEN l_class = 'u' THEN 'uùúûü'
                                 WHEN l_class = 'y' THEN 'yýÿ'
                                 WHEN l_class = 'c' THEN 'cç'
                                 WHEN l_class = 'n' THEN 'nñ'
                                 WHEN l_class = 'A' THEN 'AÀÁÂÃÄÅ'
                                 WHEN l_class = 'E' THEN 'EÈÉÊË'
                                 WHEN l_class = 'I' THEN 'IÌÍÎÏ'
                                 WHEN l_class = 'O' THEN 'OÒÓÔÕÖ'
                                 WHEN l_class = 'U' THEN 'UÙÚÛÜ'
                                 WHEN l_class = 'Y' THEN 'YÝ'
                                 WHEN l_class = 'C' THEN 'CÇ'
                                 WHEN l_class = 'N' THEN 'NÑ'
                             END;
                  -- generate a random character from the character set
                  l_res2 := SUBSTR(l_res2,random_integer(1,LENGTH(l_res2)),1);
               END IF;
               l_pos := l_pos2 + 2; -- skip "%]"
            ELSIF l_char1 = '\' AND l_char2 BETWEEN '1' AND '9' THEN
               l_prec := 6;
               l_pos := l_pos + 1; -- skip "\"
               l_idx := SUBSTR(p_regexp,l_pos,1) - '0';
               l_pos := l_pos + 1; -- skip "n"
               IF p_pass = 1 THEN
                  l_res2 := SUBSTR(p_regexp,l_pos1,l_pos-l_pos1);
               ELSE
                  l_res2 := '';
                  IF t_groups.EXISTS(l_idx) THEN
                     l_res2 := t_groups(l_idx);
                  END IF;
               END IF;
            ELSIF l_char1 = '\' AND p_pass = 2 AND l_char2 = 'x' AND is_xdigit(SUBSTR(p_regexp,l_pos1+2,1)) AND is_xdigit(SUBSTR(p_regexp,l_pos1+3,1)) THEN
               l_prec := 6;
               l_pos := l_pos + 2; -- skip "\x"
               l_res2 := CHR(read_hex);
            ELSIF l_char1 = '\' AND ((p_pass = 1 AND l_char2 IS NOT NULL) OR (p_pass = 2 AND (p_bracket_level = 0 OR l_char2 IN ('[',']','-')))) THEN
               -- Within brackets, the only escaped characters are "[", "]" and "-"
               l_prec := 2;
               IF p_pass = 1 THEN
                  l_res2 := l_char1||l_char2;
                  LOOP
                     l_res2 := REPLACE(l_res2,'\d','0-9'); -- digit
                     l_res2 := REPLACE(l_res2,'\w','A-Za-z0-9_'); -- word
                     l_res2 := REPLACE(l_res2,'\s',' \t\r\n\f'); -- space
                     l_res2 := REPLACE(l_res2,'\t',CHR(9)); -- tab
                     l_res2 := REPLACE(l_res2,'\n',CHR(10)); -- lf
                     l_res2 := REPLACE(l_res2,'\f',CHR(12)); -- ff
                     l_res2 := REPLACE(l_res2,'\r',CHR(13)); -- cr
                     l_res2 := REPLACE(l_res2,'\A',''); -- anchor (not used)
                     l_res2 := REPLACE(l_res2,'\D','^\d');
                     l_res2 := REPLACE(l_res2,'\W','^\w');
                     l_res2 := REPLACE(l_res2,'\S','^\s');
                     l_res2 := REPLACE(l_res2,'\T','^\t');
                     l_res2 := REPLACE(l_res2,'\N','^\n');
                     l_res2 := REPLACE(l_res2,'\F','^\f');
                     l_res2 := REPLACE(l_res2,'\R','^\r');
                     l_res2 := REPLACE(l_res2,'\Z',''); -- end of string (not used)
                     IF SUBSTR(l_res2,1,1) = '\' THEN
                        l_res2 := NULL;
                     END IF;
                     EXIT WHEN l_res2 IS NULL OR INSTR(l_res2,'\')<=0;
                  END LOOP;
                  IF l_res2 IS NOT NULL THEN
                     l_res2 := '['||l_res2||']';
                  ELSE
                     l_res2 := l_char1||l_char2; -- keep escape character during 1st pass
                  END IF;
               ELSE -- 2nd pass
                  l_res2 := l_char2;
               END IF;
               l_pos := l_pos + 2;
            ELSIF l_char1 = '[' THEN
               l_prec := 3;
               l_pos := l_pos + 1; -- skip "["
               l_non_matching := l_char2 = '^';
               IF l_non_matching THEN
                  l_pos := l_pos + 1; -- skip "^"
               END IF;
               IF p_pass = 1 THEN
                  l_res2 := SUBSTR(p_regexp,l_pos1,l_pos-l_pos1) || parse_regexp(p_regexp,p_pass,p_level+1,l_prec,p_bracket_level+1) || ']';
               ELSE
                  l_res2 := parse_regexp(p_regexp,p_pass,p_level+1,l_prec,p_bracket_level+1);
                  IF l_non_matching THEN
                     l_res2 := charset_minus(l_charset,l_res2);
                  END IF;
                  -- Pick one character from the character set at random
                  IF p_bracket_level = 0 THEN
                     l_res2 := SUBSTR(l_res2,random_integer(1,LENGTH(l_res2)),1);
                  END IF;
               END IF;
               assert(SUBSTR(p_regexp,l_pos,1)=']','unmatched square bracket at position '||l_pos||' in regular expression');
               l_pos := l_pos + 1; -- skip "]"
            ELSIF p_bracket_level > 0  AND l_char1 = ']' THEN
               assert(p_level>0, 'unmatched square bracket at position '||l_pos||' in regular expression');
               RETURN l_res1; -- do not consume bracket (will be done by calling code)
            ELSIF p_bracket_level = 0 AND l_char1 = '(' THEN
               l_prec := 4;
               l_pos := l_pos + 1; -- skip "("
               l_non_capture := NVL(SUBSTR(p_regexp,l_pos,2) = '?:',FALSE);
               IF l_non_capture THEN
                  l_pos := l_pos + 2; -- skip "?:"
                  l_grp := NULL;
               ELSE
                  l_grp := t_groups.COUNT+1;
                  t_groups(l_grp) := NULL;
               END IF;
               IF p_pass = 1 THEN
                  l_res2 := '(' || CASE WHEN l_non_capture THEN '?:' END ||parse_regexp(p_regexp,p_pass,p_level+1,l_prec,p_bracket_level,l_grp) || ')';
               ELSE
                  l_res2 := parse_regexp(p_regexp,p_pass,p_level+1,l_prec,p_bracket_level,l_grp);
                  IF NOT l_non_capture THEN
                     t_groups(l_grp) := l_res2; -- save result for group
                  END IF;
               END IF;
               assert(SUBSTR(p_regexp,l_pos,1)=')','unmatched parenthese at position '||l_pos||' in regular expression');
               l_pos := l_pos + 1; -- skip ")"
            ELSIF p_bracket_level = 0 AND l_char1 = ')' THEN
               assert(p_level>0,'unmatched parenthese at position '||l_pos||' in regular expression');
               RETURN l_res1; -- do not consume parenthesis (will be done by calling code)
            ELSIF p_bracket_level = 0 AND l_char1 IN ('*','+','?') THEN
               l_prec := 5;
               l_pos := l_pos + 1; -- skip symbol
               l_res2 := '';
            ELSIF p_bracket_level = 0 AND l_char1 = '{' AND REGEXP_LIKE(SUBSTR(p_regexp,l_pos),'^\{\d(,\d)?\}') THEN
               l_prec := 5;
               l_pos := INSTR(p_regexp,'}',l_pos) + 1; -- skip "{...}"
               l_res2 := '';
            ELSIF p_bracket_level = 0 AND l_char1 IN ('^','$') THEN
               l_prec := 7;
               l_pos := l_pos + 1; -- skip symbol
               l_res2 := NULL; -- ignore
            ELSIF p_bracket_level = 0 AND l_char1 = '|' THEN
               l_prec := 8;
               l_vb_cnt := l_vb_cnt + 1;
               l_max_vb_cnt := l_max_vb_cnt + 1;
               l_pos := l_pos + 1; -- skip "|"
               IF p_pass = 1 THEN
                  l_res2 := SUBSTR(p_regexp,l_pos1,l_pos-l_pos1);
               ELSE
                  l_res2 := parse_regexp(p_regexp,p_pass,p_level+1,l_prec);
                  IF random_integer(1,l_max_vb_cnt-l_vb_cnt+2) != 1 THEN
                     l_res1 := l_res2;
                  END IF;
                  l_res2 := '';
               END IF;
               l_vb_cnt := l_vb_cnt - 1;
               IF l_vb_cnt = 0 THEN
                  l_max_vb_cnt := 0;
               END IF;
            ELSIF p_bracket_level > 0 AND l_char1 = '-' AND l_char2 = '[' THEN
               l_pos := l_pos + 2; -- skip "-" and "["
               l_res2 := parse_regexp(p_regexp,p_pass,p_level+1,l_prec,p_bracket_level+1);
               assert(SUBSTR(p_regexp,l_pos,1)=']','unmatched square bracket at position '||l_pos||' in regular expression');
               l_pos := l_pos + 1; -- skip "]"
               IF p_pass = 1 THEN
                  l_res2 := SUBSTR(p_regexp,l_pos1,l_pos-l_pos1);
               ELSE
                  l_res1 := charset_minus(l_res1, l_res2);
                  l_res2 := '';
               END IF;
               assert(SUBSTR(p_regexp,l_pos,1)=']','class substraction at position '||l_pos||' must be the last element of a character class');
            ELSE -- any other character
               l_prec := 6;
               l_pos := l_pos + 1; -- skip single character
               l_res2 := SUBSTR(p_regexp,l_pos1,l_pos-l_pos1);
               l_char1 := SUBSTR(p_regexp,l_pos,1);
            END IF;
            l_cnt := 1;
            IF p_pass = 1 THEN
               l_char1 := SUBSTR(p_regexp,l_pos,1);
               IF l_char1 IN ('*','?','+') THEN
                  l_min := CASE WHEN l_char1 = '+' THEN 1 ELSE 0 END;
                  l_max := CASE WHEN l_char1 = '?' THEN 1 ELSE 3 END;
                  l_pos := l_pos + 1; -- skip symbol
                  l_cnt := random_integer(l_min,l_max);
               ELSIF l_char1 = '{' THEN
                  l_min := 0;
                  LOOP
                     l_pos := l_pos + 1;
                     l_char1 := SUBSTR(p_regexp,l_pos,1);
                     EXIT WHEN l_char1 IS NULL OR l_char1 NOT BETWEEN '0' AND '9';
                     l_min := l_min * 10 + l_char1 - '0';
                  END LOOP;
                  l_max := 0;
                  IF l_char1 = ',' THEN
                     LOOP
                        l_pos := l_pos + 1;
                        l_char1 := SUBSTR(p_regexp,l_pos,1);
                        EXIT WHEN l_char1 IS NULL OR l_char1 NOT BETWEEN '0' AND '9';
                        l_max := l_max * 10 + l_char1 - '0';
                     END LOOP;
                  ELSE
                     l_max := l_min;
                  END IF;
                  assert(l_char1 = '}', 'unmatched curly bracket at position '||l_pos||' in regular expression');
                  l_pos := l_pos + 1; -- skip "}"
                  l_cnt := random_integer(l_min,l_max);
               END IF;
            ELSE -- 2nd pass
               l_char1 := SUBSTR(p_regexp,l_pos,1);
               l_char2 := SUBSTR(p_regexp,l_pos+1,1);
               IF l_prec = 6 AND p_bracket_level > 0 AND l_char1 = '-' AND l_char2 != ']'
               AND ((SUBSTR(p_regexp,l_pos1,2) = '\x' AND SUBSTR(p_regexp,l_pos+1,2) = '\x')
                 OR (is_alnum(SUBSTR(p_regexp,l_pos1,1)) AND is_alnum(SUBSTR(p_regexp,l_pos+1,1)))
                   )
               THEN
                  l_pos := l_pos + 1; -- skip "-"
                  l_char1 := SUBSTR(p_regexp,l_pos,1);
                  l_char2 := SUBSTR(p_regexp,l_pos+1,1);
                  IF l_char1 = '\' AND l_char2 = 'x' THEN
                     l_pos := l_pos + 2; -- skip "\x"
                     l_min := ASCII(l_res2)+1;
                     l_max := read_hex;
                     assert(l_min<=l_max,'invalid [\x-\x] range at position '||l_pos||' in regular expression');
                  ELSE
                     IF  l_res2 BETWEEN 'A' AND 'Z' THEN
                        assert(l_char1 BETWEEN l_res2 AND 'Z','invalid [A-Z] range at position '||l_pos||' in regular expression');
                     ELSIF l_res2 BETWEEN 'a' AND 'z' THEN
                        assert(l_char1 BETWEEN l_res2 AND 'z','invalid [a-z] range at position '||l_pos||' in regular expression');
                     ELSIF l_res2 BETWEEN '0' AND '9' THEN
                        assert(l_char1 BETWEEN l_res2 AND '9','invalid [0-9]range at position '||l_pos||' in regular expression');
                     END IF;
                     l_min := ASCII(l_res2)+1;
                     l_max := ASCII(l_char1);
                     l_pos := l_pos + 1; -- skip superior limit
                  END IF;
                  FOR l_char IN l_min..l_max LOOP
                     l_res2 := l_res2 || CHR(l_char);
                  END LOOP;
               END IF;
            END IF;
            FOR i IN 1..l_cnt LOOP
               l_res1 := l_res1 || l_res2;
            END LOOP;
            l_prec := 6; -- looping => concatenation
         END LOOP;
         RETURN l_res1;
      END;
   BEGIN
      set_seed(p_seed);
--      dbms_output.put_line('0: '||p_regexp);
      l_regexp := p_regexp;
      l_charset := NVL(p_charset,lk_charset);
      FOR l_pass IN 1..2 LOOP
         l_len := LENGTH(l_regexp);
         l_pos := 1;
         l_vb_cnt := 0;
         l_max_vb_cnt := 0;
         t_groups.DELETE;
         l_regexp := parse_regexp(l_regexp,l_pass);
--         dbms_output.put_line(l_pass||': '||l_regexp);
      END LOOP;
      reset_seed(p_seed);
      RETURN (l_regexp);
   END;
--#begin public
   ---
   -- Return a random string with a length in a given range
   ---
   FUNCTION random_string (
      p_min_length IN INTEGER -- minimum length
    , p_max_length IN INTEGER := NULL -- maximum length (= minimum if null)
    , p_format     IN VARCHAR2 := 'MIXED' -- type of case UPPER,LOWER,INITCAP,MIXED
    , p_seed       IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      l_chars         CONSTANT VARCHAR2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      l_char_count    PLS_INTEGER := NVL(LENGTH(l_chars),0);
      l_format        VARCHAR2(7):= NVL(UPPER(SUBSTR(p_format,1,7)),'MIXED');
      l_string        VARCHAR2(32767);
      l_random_length INTEGER;
   BEGIN
      IF p_min_length IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length cannot be empty');
      END IF;
      IF p_min_length < 1 THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length is 1');
      END IF;
      IF p_max_length IS NOT NULL AND p_max_length < p_min_length THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length cannot exceed maximum length');
      END IF;
      set_seed(p_seed);
      IF p_max_length IS NOT NULL THEN
         l_random_length := random_integer(p_min_length, p_max_length);
      ELSE
         l_random_length := p_min_length;
      END IF;
      FOR i IN 1..l_random_length LOOP
         l_string := l_string || SUBSTR(l_chars, random_integer(1, l_char_count), 1);
      END LOOP;
      reset_seed(p_seed);
      IF l_format = 'UPPER' THEN
         RETURN UPPER(l_string);
      ELSIF l_format = 'LOWER' THEN
         RETURN LOWER(l_string);
      ELSIF l_format = 'INITCAP' THEN
         RETURN INITCAP(l_string);
      ELSE /*MIXED*/
         RETURN l_string;
      END IF;
   END random_string;
--#begin public
   ---
   -- Return a random name with a length in a given range
   ---
   FUNCTION random_name (
      p_min_length IN INTEGER -- minimum length
    , p_max_length IN INTEGER := NULL -- maximum length (= minimum if null)
    , p_format     IN VARCHAR2 := 'UPPER' -- type of case UPPER,LOWER,INITCAP
    , p_seed       IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      TYPE string_t IS TABLE OF VARCHAR2(26);
      -- Most frequent next letters in names for each alphabet letter
      k_next CONSTANT string_t := string_t(
         'NRLSTUMCIDGEBKVPHZYJOFWAQX' -- A
       , 'EAORIULBHSY' -- B
       , 'HAOKUIEZRLQCS' -- C
       , 'EIAOURDJHYZTL' -- D
       , 'RNLSTIMAVUCYEDBGKOWZPHFJX' -- E
       , 'AEOIRFLU' -- F
       , 'EAOUIRHNLY' -- G
       , 'AEIOURLMNTY' -- H
       , 'NSELCARTOMDGKUVZBHJFPX' -- I
       , 'AEOUIS' -- J
       , 'AOIEURHLXYSM' -- K
       , 'AEILOUSTDMBVCKHYF' -- L
       , 'AEIOUBPMSYCT' -- M
       , 'IEASDOTGNCUKYZHB' -- N
       , 'UNRSLTVPMIECOGBWDZYKFJHA' -- O
       , 'AOEIRPLUSHT' -- P
       , 'UM' -- Q
       , 'AIEOTDSUGRMNCLYBKZHVFP' -- R
       , 'TCSAEIOKHZPMULNBWY' -- S
       , 'EAIOTRHSUZCYMKL' -- T
       , 'RLSTNCEIDBMXYAPGKVFWZHJ' -- U
       , 'AEIORLS' -- V
       , 'AIESO' -- W
       , 'EA' -- X
       , 'ESNACKITLORM' -- Y
       , 'AIEZOYUHKM' -- Z
      );
      l_format VARCHAR2(7):= NVL(UPPER(SUBSTR(p_format,1,7)),'MIXED');
      l_string VARCHAR2(32767);
      l_random_length INTEGER;
      l_char CHAR;
      l_idx INTEGER;
      l_len INTEGER;
      l_rand INTEGER;
   BEGIN
      IF p_min_length IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length cannot be empty');
      END IF;
      IF p_min_length < 1 THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length is 1');
      END IF;
      IF p_max_length IS NOT NULL AND p_max_length < p_min_length THEN
         RAISE_APPLICATION_ERROR(-20000, 'Minimum length cannot exceed maximum length');
      END IF;
      set_seed(p_seed);
      IF p_max_length IS NOT NULL THEN
         l_random_length := random_integer(p_min_length, p_max_length);
      ELSE
         l_random_length := p_min_length;
      END IF;
      l_idx := random_integer(k_next.FIRST,k_next.LAST);
      l_char := CHR(ASCII('A') + l_idx - 1);
      l_string := l_char;
      FOR i IN 2..l_random_length LOOP
         l_len := NVL(LENGTH(k_next(l_idx)),0);
         l_rand := random_integer2(l_len / 2); -- use only first half
         l_char := SUBSTR(k_next(l_idx),l_rand,1);
         l_idx := (ASCII(l_char) - ASCII('A') + 1);
         IF p_format = 'MIXED' AND random_integer(0,1) = 0 THEN
            l_char := LOWER(l_char);
         END IF;
         l_string := l_string || l_char;
      END LOOP;
      reset_seed(p_seed);
      IF l_format = 'UPPER' THEN
         RETURN UPPER(l_string);
      ELSIF l_format = 'LOWER' THEN
         RETURN LOWER(l_string);
      ELSIF l_format = 'INITCAP' THEN
         RETURN INITCAP(l_string);
      ELSE /*MIXED*/
         RETURN l_string;
      END IF;
   END random_name;
--#begin public
   ---
   -- Return a random number with given scale and precision
   ---
   FUNCTION random_number (
      p_precision IN INTEGER := 38 -- total number of digits
    , p_scale     IN INTEGER := 0 -- number of digits after decimal
    , p_seed      IN VARCHAR2 := NULL
   )
   RETURN NUMBER
--#end public
   IS
      l_precision INTEGER := NVL(p_precision,5);
      l_scale INTEGER := NVL(p_scale,2);
      l_random_value NUMBER;
   BEGIN
      IF l_scale > l_precision THEN
         RAISE_APPLICATION_ERROR(-20000, 'Scale cannot exceed precision');
      END IF;
      set_seed(p_seed);
      l_random_value := TRUNC(SYS.DBMS_RANDOM.VALUE(0, POWER(10, l_precision)));
      reset_seed(p_seed);
      RETURN l_random_value / POWER(10, l_scale);
   END random_number;
--#begin public
   ---
   -- Return a random date between 2 dates
   ---
   FUNCTION random_date (
       p_min_date IN DATE := TO_DATE('01/01/1970','DD/MM/YYYY')
     , p_max_date IN DATE := TRUNC(SYSDATE)
     , p_seed     IN VARCHAR2 := NULL
   )
   RETURN DATE
--#end public
   IS
      l_num_days INTEGER;
      l_random_date DATE;
      l_min_date DATE := NVL(p_min_date,TO_DATE('01/01/1970','DD/MM/YYYY'));
      l_max_date DATE := NVL(p_max_date,TRUNC(SYSDATE));
   BEGIN
      IF p_min_date > p_max_date THEN
          RAISE_APPLICATION_ERROR(-20001, 'Minimum date must be less than or equal to maximum date');
      END IF;
      l_num_days := TRUNC(p_max_date) - TRUNC(p_min_date);
      l_random_date := TRUNC(p_min_date) + random_integer(0, l_num_days, p_seed);
      RETURN l_random_date;
   END random_date;
--#begin public
   ---
   -- Obfuscate a date i.e. generate a random date within the same month or year than the given date
   ---
   FUNCTION obfuscate_date (
       p_date IN DATE
     , p_format IN VARCHAR2 -- MM/MON/MONTH or YY/YYYY/RR/RRRR
     , p_seed   IN VARCHAR2 := NULL
   )
   RETURN DATE
--#end public
   IS
      l_min_date DATE;
      l_max_date DATE;
      l_time PLS_INTEGER;
      l_months PLS_INTEGER;
      l_num_days PLS_INTEGER;
   BEGIN
      IF p_date IS NULL THEN
         RETURN NULL;
      END IF;
      IF UPPER(p_format) IN ('YY','YYY','RR','RRRR') THEN
         l_months := 12;
      ELSIF UPPER(p_format) IN ('MM','MON','MONTH') THEN
         l_months := 1;
      ELSE
         RAISE_APPLICATION_ERROR(-20001, 'Invalid obfuscation format: '||p_format);
      END IF;
      l_time := (p_date - TRUNC(p_date)) * 86400;
      l_min_date := TRUNC(p_date, p_format);
      l_max_date := ADD_MONTHS(l_min_date, l_months) - 1;
      l_num_days := l_max_date - l_min_date;
      RETURN l_min_date + random_integer(0, l_num_days, p_seed) + l_time / 86400;
   END obfuscate_date;
--#begin public
   ---
   -- Return a random date and time
   ---
   FUNCTION random_time (
       p_min_date IN DATE := TO_DATE('01/01/1970','DD/MM/YYYY')
     , p_max_date IN DATE := TRUNC(SYSDATE)
     , p_min_time IN VARCHAR2 := '00:00:00'
     , p_max_time IN VARCHAR2 := '23:59:59'
     , p_seed     IN VARCHAR2 := NULL
   )
   RETURN DATE
--#end public
   IS
      l_num_days INTEGER;
      l_random_time DATE;
      l_min_date DATE := NVL(p_min_date,TO_DATE('01/01/1970','DD/MM/YYYY'));
      l_max_date DATE := NVL(p_max_date,TRUNC(SYSDATE));
      l_min_time PLS_INTEGER;
      l_max_time PLS_INTEGER;
   BEGIN
      l_min_time := (TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY')||' '||NVL(p_min_time,'00:00:00'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(SYSDATE))*86400;
      l_max_time := (TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY')||' '||NVL(p_max_time,'23:59:59'),'DD/MM/YYYY HH24:MI:SS') - TRUNC(SYSDATE))*86400;
      IF l_min_time > l_max_time THEN
          RAISE_APPLICATION_ERROR(-20001, 'Minimum time must be less than or equal to maximum time');
      END IF;
      IF p_min_date > p_max_date THEN
          RAISE_APPLICATION_ERROR(-20001, 'Minimum date must be less than or equal to maximum date');
      END IF;
      l_num_days := TRUNC(p_max_date) - TRUNC(p_min_date);
      l_random_time := TRUNC(p_min_date) + random_integer(0, l_num_days, p_seed) + random_integer(l_min_time, l_max_time, p_seed)/86400;
      RETURN l_random_time;
   END random_time;
--#begin public
   ---
   -- Return a future random credit card expiry date
   -- within the given months timeframe
   ---
   FUNCTION random_expiry_date(
       p_months_range IN NUMBER := 60
     , p_seed IN VARCHAR2 := NULL
   )
   RETURN DATE
--#end public
   IS
      l_random DATE;
   BEGIN
      set_seed(p_seed);
      l_random := TRUNC(ADD_MONTHS(TRUNC(SYSDATE,'MONTH'),random_integer(1,p_months_range)))-1;
      reset_seed(p_seed);
      RETURN l_random;
   END random_expiry_date;
--#begin public
   ---
   -- Substitute all alphanumeric characters of a string
   -- and keep non-alphanumeric characters unchanged
   ---
   FUNCTION obfuscate_string (
      p_string IN VARCHAR2
    , p_vowel IN VARCHAR2 := 'N'
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN STRING
--#end public
   IS
      l_vowel VARCHAR2(1) := UPPER(NVL(SUBSTR(p_vowel,1,1),'N'));
      l_string VARCHAR2(32767);
      l_char CHAR;
   BEGIN
      set_seed(p_seed);
      FOR i IN 1..NVL(LENGTH(p_string),0) LOOP
         l_char := SUBSTR(p_string,i,1);
         IF l_char BETWEEN 'a' AND 'z' THEN
            IF p_vowel = 'Y' THEN
               IF l_char IN ('a','e','i','o','u','y') THEN
                  l_char := SUBSTR('aeiouy',random_integer(1,6),1);
               ELSE
                  l_char := SUBSTR('abcdfghjklmnpqrstvwz',random_integer(1,20),1);
               END IF;
            ELSE
               l_char := SUBSTR('abcdefghijklmnopqrstuvwxyz',random_integer(1,26),1);
            END IF;
         ELSIF l_char BETWEEN 'A' AND 'Z' THEN
            IF p_vowel = 'Y' THEN
               IF l_char IN ('A','E','I','O','U','Y') THEN
                  l_char := SUBSTR('AEIOUY',random_integer(1,6),1);
               ELSE
                  l_char := SUBSTR('ABCDFGHJKLMNPQRSTVWZ',random_integer(1,20),1);
               END IF;
            ELSE
               l_char := SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ',random_integer(1,26),1);
            END IF;
         ELSIF l_char BETWEEN '0' AND '9' THEN
            l_char := SUBSTR('0123456789',random_integer(1,10),1);
         END IF;
         l_string := l_string || l_char;
      END LOOP;
      reset_seed(p_seed);
      RETURN l_string;
   END obfuscate_string;
--#begin public
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key (
      p_key IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_crypto_krn.set_encryption_key(p_key);
   END;
--#begin public
   ---
   -- Set encryption key (defined as a function to be callable from SQL)
   ---
   FUNCTION set_encryption_key (
      p_key IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      ds_crypto_krn.set_encryption_key(p_key);
      RETURN p_key;
   END;
--#begin public
   ---
   -- Encrypt a string (ASCII-256 charset)
   ---
   FUNCTION encrypt_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
--#end public
   IS
   BEGIN
      RETURN ds_crypto_krn.encrypt_string(p_string);
   END encrypt_string;
--#begin public
   ---
   -- Decrypt a string (ASCII-256 charset)
   ---
   FUNCTION decrypt_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
--#end public
   IS
   BEGIN
      RETURN ds_crypto_krn.decrypt_string(p_string);
   END decrypt_string;
--#begin public
   ---
   -- Mask some characters of a string according to a pattern
   -- String and pattern must have the same length
   ---
   FUNCTION mask_string (
      p_string IN VARCHAR2
    , p_mask_pattern IN VARCHAR2
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN STRING
--#end public
   IS
      l_mask_char CHAR := NVL(SUBSTR(p_mask_char,1,1),'X');
      l_string VARCHAR2(32767);
      l_mask_len INTEGER;
      l_string_len INTEGER;
      l_mask_ch CHAR;
      l_string_ch CHAR;
   BEGIN
      -- Empty string?
      l_string_len := NVL(LENGTH(p_string),0);
      IF l_string_len = 0 THEN
         RETURN p_string;
      END IF;
      -- String and pattern must have the same length
      l_mask_len := NVL(LENGTH(p_mask_pattern),0);
      IF l_mask_len != l_string_len THEN
         -- Replace all characters with error character
         RETURN RPAD(l_mask_char,l_string_len,l_mask_char);
      END IF;
      -- Browse string and mask in parallel
      FOR i IN 1..l_string_len LOOP
         l_string_ch := SUBSTR(p_string,i,1);
         l_mask_ch := SUBSTR(p_mask_pattern,i,1);
         IF l_mask_ch = l_mask_char THEN
            l_string_ch := l_mask_char;
         ELSIF (l_mask_ch BETWEEN '0' AND '9' OR l_mask_ch = '?')
            AND l_string_ch BETWEEN '0' AND '9' THEN
            NULL;
         ELSIF (l_mask_ch BETWEEN 'a' AND 'z' OR l_mask_ch BETWEEN 'A' AND 'Z' OR l_mask_ch = '?')
           AND (l_string_ch BETWEEN 'a' AND 'z' OR l_string_ch BETWEEN 'A' AND 'Z')
         THEN
            NULL;
         ELSIF l_mask_ch != l_string_ch THEN
            l_string_ch := l_mask_char;
         END IF;
         l_string := l_string || l_string_ch;
      END LOOP;
      RETURN l_string;
   END mask_string;
--#begin public
   ---
   -- Encrypt a number
   ---
   FUNCTION encrypt_number (
      p_number IN NUMBER
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN ds_crypto_krn.encrypt_number(p_number);
   END;
--#begin public
   ---
   -- Decrypt a number
   ---
   FUNCTION decrypt_number (
      p_number IN NUMBER
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN ds_crypto_krn.decrypt_number(p_number);
   END;
--#begin public
   ---
   -- Mask a number
   -- Keep specified number of digits to the left and/or to the right
   ---
   FUNCTION mask_number (
      p_number IN VARCHAR2
    , p_keep_left IN NUMBER := 0
    , p_keep_right IN NUMBER := 0
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
      l_number VARCHAR2(100);
      l_ret VARCHAR2(100);
      l_len PLS_INTEGER;
      l_cnt PLS_INTEGER := 0;
      l_chr VARCHAR2(1 CHAR);
   BEGIN
      IF p_number IS NULL THEN
         RETURN NULL;
      END IF;
      l_number := filter_characters(p_number,'0'); -- keep only digits
      l_len := NVL(LENGTH(l_number),0);
      FOR i IN 1..NVL(LENGTH(p_number),0) LOOP
         l_chr := SUBSTR(p_number,i,1);
         IF  l_chr BETWEEN '0' AND '9' THEN
            l_cnt := l_cnt + 1;
            IF l_cnt > NVL(p_keep_left,0) AND l_cnt < l_len-NVL(p_keep_right,0)+1 THEN
               l_chr := p_mask_char;
            END IF;
         END IF;
         l_ret := l_ret || l_chr;
      END LOOP;
      RETURN l_ret;
   END;
--#begin public
   ---
   -- Remove accentuated characters from a string
   ---
   FUNCTION unaccentuate_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
--#end public
   IS
      l_string VARCHAR2(32767);
   BEGIN
      -- Replace "æ" with "ae", "Æ" with "AE", "œ" with "oe" and "Œ" with "OE"
      l_string := REPLACE(REPLACE(REPLACE(REPLACE(p_string, 'æ', 'ae'), 'Æ', 'AE'), 'œ', 'oe'), 'Œ', 'OE');
      -- Translate accentuated characters and Greek characters
      l_string := TRANSLATE(l_string, 'áéíóúàèìòùâêîôûçäëïöüÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛ'
                                    , 'aeiouaeiouaeioucaeiouAEIOUAEIOUAEIOU');
      RETURN l_string;
   END;
--#begin public
   ---
   -- Get a column value from a random row of a given table
   -- Table must have a sequence column with no hole in its values
   -- A filter (where clause) may also be specified
   ---
   FUNCTION random_value_from_table (
      p_tab_name IN user_tables.table_name%TYPE
    , p_col_name IN user_tab_columns.column_name%TYPE
    , p_col_len  IN user_tab_columns.data_length%TYPE := NULL -- maximum length
    , p_where IN VARCHAR2 := NULL -- filter
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN ds_utility_krn.random_value_from_table (
                p_tab_name=>p_tab_name
              , p_col_name=>p_col_name
              , p_col_len=>p_col_len
              , p_where=>p_where
              , p_seed=>p_seed
             );
   END;
--#begin public
   ---
   -- Get a column value from a random row of a given data set (loaded in memory)
   ---
   FUNCTION random_value_from_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_len  IN user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN ds_utility_krn.random_value_from_data_set (
         p_set_name=>p_set_name
       , p_col_name=>p_col_name
       , p_col_len=>p_col_len
       , p_seed=>p_seed
       , p_weight=>p_weight
      );
   END;
--#begin public
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_col_name IN ds_data_sets.set_name%TYPE
    , p_col_len  IN user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN ds_utility_krn.random_value_from_data_set (
         p_set_col_name=>p_set_col_name
       , p_col_len=>p_col_len
       , p_seed=>p_seed
       , p_weight=>p_weight
      );
   END;
--#begin public
   ---
   -- Compute Luhn sum
   ---
   FUNCTION luhn_sum (
      p_num IN VARCHAR2
   )
   RETURN NUMBER
--#end public
   IS
      l_sum NUMBER := 0;
      l_digit NUMBER;
      l_len PLS_INTEGER;
   BEGIN
      IF p_num IS NULL THEN
         RETURN NULL;
      END IF;
      l_len := NVL(LENGTH(p_num),0);
      FOR i IN 1..NVL(LENGTH(p_num),0) LOOP
         l_digit := ASCII(SUBSTR(p_num, -i, 1)) - ASCII('0');
         IF MOD(i,2) = 0 THEN
            l_digit := l_digit * 2;
            IF l_digit > 9 THEN
               l_digit := l_digit - 9;
            END IF;
         END IF;
         l_sum := l_sum + l_digit;
      END LOOP;
      RETURN MOD(l_sum, 10);
   END;
--#begin public
   ---
   -- Compute Luhn check digit
   ---
   FUNCTION luhn_checkdigit (
      p_num IN NUMBER
   )
   RETURN VARCHAR2
--#end public
   IS
      l_sum NUMBER;
   BEGIN
      RETURN MOD(10 - MOD(luhn_sum(p_num), 10),10);
   END;
--#begin public
   ---
   -- Check if a number is a valid Luhn number
   ---
   FUNCTION is_valid_luhn_number (
      p_num IN VARCHAR2
   )   
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_num IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN CASE WHEN luhn_sum(p_num) = 0 THEN 'Y' ELSE 'N' END;
   END;
--#begin public
   ---
   -- Return a random Luhn number
   ---
   FUNCTION random_luhn_number (
      p_length IN NUMBER
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
      l_num VARCHAR2(100);
      l_rand NUMBER;
   BEGIN
      IF p_length IS NULL THEN
         RETURN NULL;
      END IF;
      set_seed(p_seed);
      l_rand := random_integer(1, POWER(10,p_length-1)-1);
      l_num := LPAD(TRIM(TO_CHAR(l_rand)),p_length-1,'0');
      reset_seed(p_seed);
      RETURN l_num||TO_CHAR(luhn_checkdigit(l_num*10));
   END;
--#begin public
   ---
   -- Filter characters of a string and keep only those specified in the format
   -- De-facto remove all spaces and ponctuation characters
   ---
   FUNCTION filter_characters (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2 := 'Aa0'
   )
   RETURN VARCHAR2
--#end public
   IS
      l_string ds_utility_var.largest_string;
      l_char VARCHAR2(1 CHAR);
      l_keep_lower BOOLEAN := FALSE;
      l_keep_upper BOOLEAN := FALSE;
      l_keep_digit BOOLEAN := FALSE;
   BEGIN
      IF p_string IS NULL THEN
         RETURN p_string;
      END IF;
      FOR i IN 1..NVL(LENGTH(p_format),0) LOOP
         l_char := SUBSTR(p_format,i,1);
         IF INSTR('abcdefghijklmnopqrstuvwxyz',l_char)>0 THEN
            l_keep_lower := TRUE;
         ELSIF INSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ',l_char)>0 THEN
            l_keep_upper := TRUE;
         ELSIF INSTR('0123456789',l_char)>0 THEN
            l_keep_digit := TRUE;
         END IF;
      END LOOP;
      FOR i IN 1..NVL(LENGTH(p_string),0) LOOP
         l_char := SUBSTR(p_string,i,1);
         IF (l_char BETWEEN 'a' AND 'z' AND l_keep_lower)
         OR (l_char BETWEEN 'A' AND 'Z' AND l_keep_upper)
         OR (l_char BETWEEN '0' AND '9' AND l_keep_digit)
         THEN
            l_string := l_string || l_char;
         END IF;
      END LOOP;
      RETURN l_string;
   END;
--#begin public
   ---
   -- Apply a format to a number (for credit card, BBAN, IBAN, etc...)
   ---
   FUNCTION format_number (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      l_string ds_utility_var.largest_string;
      l_char_f VARCHAR2(1);
      l_char_s VARCHAR2(1);
      l_pos PLS_INTEGER := 1;
   BEGIN
      IF p_format IS NULL OR p_string IS NULL THEN
         RETURN p_string;
      END IF;
      FOR i IN 1..NVL(LENGTH(p_format),0) LOOP
         l_char_s := SUBSTR(p_string, l_pos, 1);
         l_char_f := SUBSTR(p_format,i,1);
         IF (l_char_f BETWEEN 'a' AND 'z' AND l_char_s BETWEEN 'a' AND 'z')
         OR (l_char_f BETWEEN 'A' AND 'Z' AND l_char_s BETWEEN 'A' AND 'Z')
         OR (l_char_f BETWEEN '0' AND '9' AND l_char_s BETWEEN '0' AND '9')
         THEN
            l_string := l_string || l_char_s;
            l_pos := l_pos + 1;
         ELSE
            l_string := l_string || l_char_f;
         END IF;
      END LOOP;
      l_string := l_string || SUBSTR(p_string, l_pos);
      RETURN l_string;
   END;
--#begin public
   ---
   -- Check the validity of an IBAN (International Bank Account Number)
   ---
   FUNCTION is_valid_iban (
      p_ctry_code IN VARCHAR2 := NULL
    , p_iban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   AS
      l_modulus NUMBER;
      l_temp VARCHAR2(100);
      l_char VARCHAR2(1);
      l_len PLS_INTEGER;
   BEGIN
      IF p_iban IS NULL THEN
         RETURN 'Y';
      END IF;
      IF p_ctry_code IS NOT NULL AND SUBSTR(p_iban,1,2) != p_ctry_code THEN
         RETURN 'N';
      END IF;
      IF p_ctry_code = 'BE' THEN
         l_len := 16;
      END IF;
      l_temp := UPPER(filter_characters(p_iban,'Aa0')); -- Keep only alphanumeric characters (i.e. ignore spaces, dashes, etc.)
      IF l_len IS NOT NULL AND NVL(LENGTH(l_temp),0) != l_len THEN
         RETURN 'N';
      END IF;
      -- Move the first 4 characters to the end
      l_temp := SUBSTR(l_temp, 5) || SUBSTR(l_temp, 1, 4);
      -- Convert all letters to numbers (A=10, B=11, ..., Z=35)
      FOR i IN 1..NVL(LENGTH(l_temp),0) LOOP
         l_char := SUBSTR(l_temp, i, 1); 
         IF l_char BETWEEN 'A' AND 'Z' THEN
            l_temp := REPLACE(l_temp, l_char, ASCII(l_char)-55);
         END IF;
      END LOOP;
      -- Calculate the modulus of the converted IBAN
      l_modulus := TO_NUMBER(SUBSTR(l_temp, 1, 1));
      FOR i IN 2..NVL(LENGTH(l_temp),0) LOOP
         l_modulus := (l_modulus * 10 + ASCII(SUBSTR(l_temp, i, 1)) - ASCII('0')) MOD 97;
      END LOOP;
      -- If the modulus is 1, the IBAN is valid
      RETURN CASE WHEN l_modulus = 1 THEN 'Y' ELSE 'N' END;
   END;
--#begin public
   ---
   -- Mask some digits of an IBAN (International Bank Account Number)
   -- Keep specified number of digits to the left and/or to the right
   ---
   FUNCTION mask_iban (
      p_ctry_code IN VARCHAR2 := NULL
    , p_iban IN VARCHAR2
    , p_keep_left IN NUMBER := 0
    , p_keep_right IN NUMBER := 4
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
--      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN mask_number (
         p_number => p_iban
       , p_keep_left => p_keep_left
       , p_keep_right => p_keep_right
       , p_mask_char => p_mask_char
      );
   END;
--#begin public
   ---
   -- Check the validity of a number with a modulo 97 checksum
   ---
   FUNCTION is_valid_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
      l_num VARCHAR2(100);
      l_len PLS_INTEGER;
      l_check_number VARCHAR2(2);
   BEGIN
      -- Keep only alphanumeric characters (i.e. ignore spaces, dashes, etc.)
      l_num := filter_characters(p_num,'0');
      -- Check that the num is 12 characters long
      l_len := NVL(LENGTH(l_num),0);
      IF l_len != NVL(p_len,l_len) THEN
         RETURN 'N';
      END IF;      
      -- Extract the check number (the last 2 digits) from the number
      l_check_number := SUBSTR(l_num, -2);
      -- Check that the check number is valid
      IF TO_NUMBER(l_check_number) <> MOD(TO_NUMBER(SUBSTR(l_num, 1, l_len-2)), 97) THEN
         RETURN 'N';
      END IF;
      -- The number is valid
      RETURN 'Y';
   END;
   ---
   -- Randomize, encrypt or decrypt a number with modulo 97 checksum
   ---
   FUNCTION process_number_with_mod97 (
      p_method IN VARCHAR2 -- R)andomize, E)ncrypt, D)ecrypt
    , p_prefix IN VARCHAR2 := NULL
    , p_format IN VARCHAR2 := NULL
    , p_len IN NUMBER := 12
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
   IS
      l_num VARCHAR2(100);
      l_format VARCHAR2(100);
      l_len PLS_INTEGER;
      l_check_number VARCHAR2(2);
      l_rand NUMBER;
      l_nbr NUMBER;
   BEGIN
      set_seed(p_seed);
      l_format := filter_characters(p_format,'0'); -- Keep only digits
      l_len := NVL(LENGTH(l_format),0);
      IF l_len = 0 THEN
         l_len := p_len;
      END IF;
      l_num := SUBSTR(filter_characters(p_prefix,'0'),1,p_len-2); -- Prefix number
      l_len := l_len - NVL(LENGTH(l_num),0) - 2;
      IF p_method = 'R' THEN
         l_rand := TRUNC(SYS.DBMS_RANDOM.VALUE(1,POWER(10,l_len)-1));
      ELSIF p_method = 'E' THEN
         l_rand := ds_crypto_krn.encrypt_number(p_value=>TO_NUMBER(SUBSTR(l_format,NVL(LENGTH(l_num),0)+1,l_len)), p_precision=>l_len);
      ELSIF p_method = 'D' THEN
         l_rand := ds_crypto_krn.decrypt_number(p_value=>TO_NUMBER(SUBSTR(l_format,NVL(LENGTH(l_num),0)+1,l_len)), p_precision=>l_len);
      END IF;
      l_num := l_num || LPAD(TO_CHAR(l_rand),l_len,'0');
      l_nbr := TO_NUMBER(l_num);
      l_num := l_num || LPAD(TO_CHAR(MOD(l_nbr,97)),2,'0');
      reset_seed(p_seed);
      RETURN format_number(l_num, p_format);
   END;
--#begin public
   ---
   -- Generate a random nummber with modulo 97 checksum
   ---
   FUNCTION random_number_with_mod97 (
      p_prefix IN VARCHAR2 := NULL
    , p_format IN VARCHAR2 := NULL
    , p_len IN NUMBER := 12
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      RETURN process_number_with_mod97 (
         p_method => 'R' -- Random
       , p_prefix => p_prefix
       , p_format => p_format
       , p_len => p_len
       , p_seed => p_seed
      );
   END;
--#begin public
   ---
   -- Obfuscate a number with modulo 97 checksum
   ---
   FUNCTION obfuscate_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_num IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_number_with_mod97 (
         p_method => 'R' -- Random
       , p_prefix => NULL
       , p_format => p_num
       , p_len => p_len
       , p_seed => p_seed
      );
   END;
--#begin public
   ---
   -- Encrypt a number with modulo 97 checksum
   ---
   FUNCTION encrypt_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_num IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_number_with_mod97 (
         p_method => 'E' -- Encrypt
       , p_prefix => NULL
       , p_format => p_num
       , p_len => p_len
      );
   END;
--#begin public
   ---
   -- Decrypt a number with modulo 97 checksum
   ---
   FUNCTION decrypt_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_num IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_number_with_mod97 (
         p_method => 'D' -- Decrypt
       , p_prefix => NULL
       , p_format => p_num
       , p_len => p_len
      );
   END;
--#begin public
   ---
   -- Mask a number with modulo 97 checksum
   -- Keep specified number of digits to the left and/or to the right
   ---
   FUNCTION mask_number_with_mod97 (
      p_number IN VARCHAR2
    , p_keep_left IN NUMBER := 0
    , p_keep_right IN NUMBER := 4
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      RETURN mask_number (
         p_number => p_number
       , p_keep_left => p_keep_left
       , p_keep_right => p_keep_right
       , p_mask_char => p_mask_char
      );
   END;
--#begin public
   ---
   -- Check the validity of a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION is_valid_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN is_valid_number_with_mod97(p_num=>p_bban,p_len=>12);
   END;
--#begin public
   ---
   -- Generate a random BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION random_bban (
      p_ctry_code IN VARCHAR2
    , p_prefix IN VARCHAR2 := NULL
    , p_format IN VARCHAR2 := NULL
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN random_number_with_mod97(p_len=>12, p_prefix=>p_prefix, p_format=>p_format, p_seed=>p_seed);
   END;
--#begin public
   ---
   -- Obfuscate a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION obfuscate_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_bban IS NULL THEN
         RETURN NULL;
      END IF;
      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN random_number_with_mod97(p_len=>12, p_prefix=>SUBSTR(filter_characters(p_bban,'0'),1,3), p_format=>p_bban, p_seed=>p_seed);
   END;
--#begin public
   ---
   -- Encrypt a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION encrypt_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_bban IS NULL THEN
         RETURN NULL;
      END IF;
      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN process_number_with_mod97(p_method=>'E', p_prefix=>SUBSTR(filter_characters(p_bban,'0'),1,3), p_format=>p_bban);
   END;
--#begin public
   ---
   -- Decrypt a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION decrypt_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_bban IS NULL THEN
         RETURN NULL;
      END IF;
      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN process_number_with_mod97(p_method=>'D', p_prefix=>SUBSTR(filter_characters(p_bban,'0'),1,3), p_format=>p_bban);
   END;
--#begin public
   ---
   -- Mask some digits of a BBAN (Basic Bank Account Number)
   -- Keep specified number of digits to the left and/or to the right
   ---
   FUNCTION mask_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
    , p_keep_left IN NUMBER := 0
    , p_keep_right IN NUMBER := 4
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
--      assert(p_ctry_code='BE', 'Country "'||p_ctry_code||'" not supported yet!');
      RETURN mask_number (
         p_number => p_bban
       , p_keep_left => p_keep_left
       , p_keep_right => p_keep_right
       , p_mask_char => p_mask_char
      );
   END;
--#begin public
   ---
   -- Check the validity of a credit card number
   ---
   FUNCTION is_valid_credit_card_number (
      p_card_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
      l_card_number VARCHAR2(100);
   BEGIN
      -- Keep only alphanumeric characters (i.e. ignore spaces, dashes, etc.)
      l_card_number := filter_characters(p_card_number,'0');
      -- Check length
      IF NOT NVL(LENGTH(l_card_number),0) BETWEEN 13 AND 16 THEN
         RETURN 'N';
      END IF;
      -- Check Luhn checksum
      RETURN is_valid_luhn_number(l_card_number);
   END;
   ---
   -- Randomize, encrypt or decrypt a credit card number
   ---
   FUNCTION process_credit_card_number (
      p_method IN VARCHAR2 -- R)andomize, E)ncrypt, D)ecrypt
    , p_prefix IN VARCHAR2 := NULL
    , p_format IN VARCHAR2 := NULL
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
   IS
      l_num NUMBER;
      l_mid NUMBER;
      l_len PLS_INTEGER;
      l_format VARCHAR2(100);
      l_card_number VARCHAR2(100);
   BEGIN
      set_seed(p_seed);
      l_format := filter_characters(p_format,'0'); -- Keep only digits
      l_len := NVL(LENGTH(l_format),0); -- number of digits in credit card number
      IF p_prefix IS NOT NULL THEN
         l_card_number := p_prefix;
      ELSIF p_method = 'R' THEN
         l_card_number :=
            CASE random_integer(1,4)
               WHEN 1 THEN '3' -- American Express
               WHEN 2 THEN '4' -- Visa
               WHEN 3 THEN '5' -- MasterCard
               WHEN 4 THEN '6011' -- Discover
            END;
      END IF;
      l_len := CASE WHEN l_len=0 THEN CASE WHEN l_card_number LIKE '3%' THEN 15 ELSE 16 END ELSE l_len END;
      l_len := l_len - NVL(LENGTH(l_card_number),0) - 1; -- length - prefix - check digit
      IF p_method = 'R' THEN
         l_mid := TRUNC(SYS.DBMS_RANDOM.VALUE(1, POWER(10,l_len)-1));
      ELSIF p_method = 'E' THEN
         l_mid := ds_crypto_krn.encrypt_number(p_value=>TO_NUMBER(SUBSTR(l_format,NVL(LENGTH(l_card_number),0)+1,l_len)), p_precision=>l_len);
      ELSIF p_method = 'D' THEN
         l_mid := ds_crypto_krn.decrypt_number(p_value=>TO_NUMBER(SUBSTR(l_format,NVL(LENGTH(l_card_number),0)+1,l_len)), p_precision=>l_len);
      END IF;
      l_card_number := l_card_number || LPAD(TRIM(TO_CHAR(l_mid)),l_len,'0');
      l_card_number := l_card_number || TRIM(TO_CHAR(luhn_checkdigit(l_card_number*10)));
      reset_seed(p_seed);
      RETURN format_number(l_card_number, p_format);
   END;
--#begin public
   ---
   -- Generate a random and valid credit card number
   -- Format it according to the given format/pattern
   ---
   FUNCTION random_credit_card_number (
      p_prefix IN VARCHAR2 := NULL
    , p_format IN VARCHAR2 := NULL
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      RETURN process_credit_card_number (
         p_method => 'R' -- Random
       , p_prefix => p_prefix
       , p_format => p_format
       , p_seed => p_seed
      );
   END;
--#begin public
   ---
   -- Obfuscate a credit card number i.e. generate a random number
   -- Preserve prefix (card issuer) and format (e.g. dashes or spaces)
   -- Recompute check digit to keep it a valid number
   ---
   FUNCTION obfuscate_credit_card_number (
      p_number IN VARCHAR2
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_number IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_credit_card_number (
         p_method => 'R' -- Random
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011%' THEN 4 ELSE 1 END)
       , p_format => p_number
       , p_seed => p_seed
      );
   END;
--#begin public
   ---
   -- Encrypt a credit card number
   -- Preserve prefix (card issuer) and format (e.g. dashes or spaces)
   -- Recompute check digit to keep it a valid number
   ---
   FUNCTION encrypt_credit_card_number (
      p_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_number IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_credit_card_number (
         p_method => 'E' -- Encrypt
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011%' THEN 4 ELSE 1 END)
       , p_format => p_number
      );
   END;
--#begin public
   ---
   -- Mask some digits of a credit card number with X
   -- Keep specified number of digits to the left and/or to the right
   ---
   FUNCTION mask_credit_card_number (
      p_number IN VARCHAR2
    , p_keep_left IN NUMBER := 0
    , p_keep_right IN NUMBER := 4
    , p_mask_char IN VARCHAR2 := 'X'
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      RETURN mask_number (
         p_number => p_number
       , p_keep_left => p_keep_left
       , p_keep_right => p_keep_right
       , p_mask_char => p_mask_char
      );
   END;
--#begin public
   ---
   -- Decrypt a credit card number (previously encrypted with this package)Ah o
   -- Preserve prefix (card issuer) and format (e.g. dashes or spaces)
   -- Recompute check digit to keep it a valid number
   ---
   FUNCTION decrypt_credit_card_number (
      p_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
--#end public
   IS
   BEGIN
      IF p_number IS NULL THEN
         RETURN NULL;
      END IF;
      RETURN process_credit_card_number (
         p_method => 'D' -- Decrypt
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011%' THEN 4 ELSE 1 END)
       , p_format => p_number
      );
   END;
--#begin public
   ---
   -- Returns dummy text based on Lorem Ipsum (classical Latin literature from 45 BC) - maximum 4000 characters
   ---
   FUNCTION lorem_ipsum_text (
      p_length IN NUMBER := NULL
   ) 
   RETURN VARCHAR2 
--#end public
   IS 
      k_ipsum CONSTANT VARCHAR2(446) :=
         'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
       ||'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
       ||'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
       ||'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '; 
      l_ipsum_length PLS_INTEGER := NVL(LENGTH(k_ipsum),0);
      l_text VARCHAR2(32000); 
      l_blk PLS_INTEGER;
      l_len PLS_INTEGER;
   BEGIN
      l_len := LEAST(NVL(p_length,l_ipsum_length),4000);
      l_blk := CEIL(l_len/l_ipsum_length);
      FOR i IN 1..l_blk LOOP
         l_text := l_text || CASE WHEN i = l_blk THEN SUBSTR(k_ipsum,1,MOD(l_len,l_ipsum_length)) ELSE k_ipsum END; 
      END LOOP; 
      RETURN l_text;--SUBSTR(l_text, 1, NVL(p_length,l_ipsum_length));
   END;
--#begin public
   ---
   -- Returns dummy CLOB based on Lorem Ipsum (classical Latin literature from 45 BC)
   ---
      FUNCTION lorem_ipsum_clob (
      p_length IN NUMBER := NULL
   ) 
   RETURN CLOB 
--#end public
   IS 
      k_ipsum CONSTANT VARCHAR2(446) :=
         'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
       ||'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
       ||'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
       ||'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ';
      l_ipsum_length PLS_INTEGER := LENGTH(k_ipsum);
      l_clob CLOB;
      l_blk PLS_INTEGER;
      l_len PLS_INTEGER;
   BEGIN 
      l_len := NVL(p_length,l_ipsum_length);
      l_blk := CEIL(NVL(p_length,l_ipsum_length)/l_ipsum_length);
      dbms_lob.createtemporary(l_clob, true);
      FOR i IN 1..l_blk LOOP
         dbms_lob.append(l_clob,CASE WHEN i = l_blk THEN SUBSTR(k_ipsum,1,MOD(l_len,l_ipsum_length)) ELSE k_ipsum END);
      END LOOP; 
      RETURN l_clob;
   END;
--#begin public
   ---
   -- Generates a random IP v4 address
   ---
   FUNCTION random_ip_v4 (
      p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 
--#end public
   IS
   BEGIN
      RETURN random_value_from_regexp(p_regexp=>'((25[0-5]|2[0-4][0-9]|[1]?[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[1]?[1-9]?[0-9])',p_seed=>p_seed);
   END;
--#begin public
   ---
   -- Generates a random IP v6 address
   ---
   FUNCTION random_ip_v6 (
      p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 
--#end public
   IS
   BEGIN
      RETURN random_value_from_regexp(p_regexp=>'([0-9a-f]{4}:){7}[0-9a-f]{4}',p_seed=>p_seed);
   END;
--#begin public
   ---
   -- Generate a random value from a weighted list of values
   ---
   FUNCTION random_value_from_list (
      p_values IN VARCHAR2 -- list of comma seperated values
    , p_weights IN VARCHAR2 := NULL -- list of comma separated weights
    , p_seed IN VARCHAR2 := NULL -- seed to make generator deterministic
    , p_col_sep_char IN VARCHAR2 := ',' -- column separator character
   )
   RETURN VARCHAR2 -- random value from list
--#end public
   IS
      l_beg PLS_INTEGER;
      l_end PLS_INTEGER;
      l_len PLS_INTEGER := LENGTH(NVL(p_col_sep_char,','));
      l_idx PLS_INTEGER;
      l_rand PLS_INTEGER;
      t_values SYS.DBMS_SQL.VARCHAR2A;
      TYPE t_weights_type IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
      t_weights t_weights_type;
   BEGIN
      IF p_values IS NULL THEN
         RETURN NULL;
      END IF;
      set_seed(p_seed);
      l_beg := 1;
      LOOP
         l_end := NVL(INSTR(p_values,NVL(p_col_sep_char,','),l_beg),0);
         EXIT WHEN l_end <= 0;
         t_values(t_values.COUNT+1) := TRIM(SUBSTR(p_values, l_beg, l_end-l_beg));
         l_beg := l_end + l_len;
      END LOOP;
      t_values(t_values.COUNT+1) := TRIM(SUBSTR(p_values, l_beg));
      IF p_weights IS NULL THEN
         l_rand := random_integer(1,t_values.COUNT);
         l_idx := l_rand;
      ELSE
         l_beg := 1;
         LOOP
            l_end := NVL(INSTR(p_weights,NVL(p_col_sep_char,','),l_beg),0);
            EXIT WHEN l_end <= 0;
            BEGIN
               t_weights(t_weights.COUNT+1) := TO_NUMBER(TRIM(SUBSTR(p_weights, l_beg, l_end-l_beg)));
            EXCEPTION
               WHEN OTHERS THEN
                  t_weights(t_weights.COUNT+1) := 0;
            END;
            IF t_weights.COUNT > 1 THEN
               t_weights(t_weights.COUNT) := t_weights(t_weights.COUNT) + t_weights(t_weights.COUNT-1);
            END IF;
            l_beg := l_end + l_len;
            EXIT WHEN t_weights.COUNT >= t_values.COUNT;
         END LOOP;
         IF t_weights.COUNT < t_values.COUNT THEN
            BEGIN
               t_weights(t_weights.COUNT+1) := TO_NUMBER(TRIM(SUBSTR(p_weights, l_beg)));
            EXCEPTION
               WHEN OTHERS THEN
                  t_weights(t_weights.COUNT+1) := 0;
            END;
            IF t_weights.COUNT > 1 THEN
               t_weights(t_weights.COUNT) := t_weights(t_weights.COUNT) + t_weights(t_weights.COUNT-1);
            END IF;
         END IF;
         l_rand := random_integer(1,t_weights(t_weights.COUNT));
         l_idx := 1;
         WHILE t_weights.EXISTS(l_idx) LOOP
            EXIT WHEN l_rand <= t_weights(l_idx);
            l_idx := l_idx + 1;
         END LOOP;
         IF NOT t_weights.EXISTS(l_idx) THEN
            l_idx := NULL;
         END IF;
      END IF;
      reset_seed(p_seed);
      RETURN CASE WHEN l_idx IS NULL THEN NULL ELSE t_values(l_idx) END;
   END;
--#begin public
   ---
   -- Generates a random company name made up of a prefix, an adjective, a noun and a suffix
   ---
   FUNCTION random_company_name (
      p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN random_value_from_list(p_values=>'Meta, Neo, Opti, Synth, Omni, Nova, Proto, Quanta, Quantum, Tru, Virtu, Alpha, Beta, Sigma, Axi, Hexa, Inno, Cybo, Xero, Zeni, Penta, Exo, Dyna, Andro, Helio',p_seed=>p_seed)
    || ' ' ||random_value_from_list(p_values=>'Innovative, Dynamic, Reliable, Modern, Professional, Advanced, Expert, Sustainable, Quality, Trusted, Leading, Premier, Fresh, Bright, Agile, Bold, Prime, Inspired, Elite, Vivid, Ethereal, Empower, Infinite, Radiant, Lumina, Majestic, Serene, Celestial, Euphoric, Resolute, Tranquil, Elysian, Vibrant, Jubilant, Stellar, Empyreal, Outstanding, Influential, Noble, Prosperous, Soothing, Harmonious, Graceful, Sparkling, Creative, Genuine, Resplendent, Majestic, Jubilant, Exquisite, Serene',p_seed=>p_seed)
    || ' ' ||random_value_from_list(p_values=>'Electronics, Clothing, Food, Software, Goods, Furniture, Automobiles, Appliances, Books, Health, Supplies, Sporting, Jewelry, Toys, Pharmaceuticals, Decor, Office, Accessories, Equipment, Fitness, Pet, Travel, Financial, Real Estate, Entertainment, Beauty, Shoes, Technology, Music, Art, Groceries, Drinks, Tools, Fashion, Phones, Home, Computers, Gadgets, Electronics, Gifts, Watches, Jewelry, Kids, Crafts, Toys, Flowers, Appliances, Cameras, Music, Movies, Games',p_seed=>p_seed)
    || ' ' ||random_value_from_list(p_values=>'Labs, Innovate, Dynamics, Works, Co., Corporation, Innovations, Solutions, Industries, Tech, Group, Enterprises, Systems, Services, Network, Partners, X, AI, Ltd, HQ, Inc, Ltd, Corp, LLC, Ventures',p_seed=>p_seed);
   END;
END ds_masker_krn;
/
