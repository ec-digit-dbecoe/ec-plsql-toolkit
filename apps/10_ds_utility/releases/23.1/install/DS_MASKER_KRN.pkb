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
   -- Generate a random number between 1 and N
   -- With a linearly decreasing probability
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
   -- Return a random integer between 2 integers
   ---
   FUNCTION random_integer (
      p_min_value IN INTEGER := 1
    , p_max_value IN INTEGER := 99
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN INTEGER
--#end public
   IS
   BEGIN
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      RETURN TRUNC(SYS.DBMS_RANDOM.value(p_min_value, p_max_value+1));
   END random_integer;
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      IF p_max_length IS NOT NULL THEN
         l_random_length := random_integer(p_min_length, p_max_length);
      ELSE
         l_random_length := p_min_length;
      END IF;
      FOR i IN 1..l_random_length LOOP
         l_string := l_string || SUBSTR(l_chars, random_integer(1, l_char_count), 1);
      END LOOP;
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
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
      p_precision IN INTEGER := 5 -- total number of digits
    , p_scale     IN INTEGER := 2 -- number of digits after decimal
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      l_random_value := SYS.DBMS_RANDOM.VALUE(0, POWER(10, l_precision) - 1);
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      l_num_days := TRUNC(p_max_date) - TRUNC(p_min_date);
      l_random_date := TRUNC(p_min_date) + random_integer(0, l_num_days);
      RETURN l_random_date;
   END random_date;
--#begin public
   ---
   -- Return a future random credit card expiry date
   -- within the given months timeframe
   ---
   FUNCTION random_expiry_date(
       p_months_range IN NUMBER := 60
     , p_seed     IN VARCHAR2 := NULL
   )
   RETURN DATE
--#end public
   IS
   BEGIN
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      RETURN TRUNC(ADD_MONTHS(TRUNC(SYSDATE,'MONTH'),random_integer(1,p_months_range)))-1;
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
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
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_len  IN user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
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
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN ds_utility_krn.random_value_from_data_set (
         p_set_col_name=>p_set_col_name
       , p_col_len=>p_col_len
       , p_seed=>p_seed
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
      l_rand := random_integer(1, POWER(10,p_length-1)-1);
      l_num := LPAD(TRIM(TO_CHAR(l_rand)),p_length-1,'0');
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
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
      IF p_seed IS NOT NULL THEN
         SYS.DBMS_RANDOM.seed(p_seed);
      END IF;
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
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011' THEN 4 ELSE 1 END)
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
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011' THEN 4 ELSE 1 END)
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
       , p_prefix => SUBSTR(p_number,1,CASE WHEN p_number LIKE '6011' THEN 4 ELSE 1 END)
       , p_format => p_number
      );
   END;
--#begin public
   ---
   -- Returns dummy text based on Lorem Ipsum (classical Latin literature from 45 BC)
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
      l_text VARCHAR2(4000); 
   BEGIN 
      FOR i IN 1..CEIL(LEAST(NVL(p_length,l_ipsum_length),4000)/l_ipsum_length) LOOP 
         l_text := l_text || k_ipsum; 
      END LOOP; 
      RETURN SUBSTR(l_text, 1, NVL(p_length,l_ipsum_length));
   END;
END ds_masker_krn;
/
