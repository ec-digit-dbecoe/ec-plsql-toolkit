CREATE OR REPLACE PACKAGE BODY ds_crypto_krn AS
---
-- Copyright (C) 2024 European Commission
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
-- To generate the package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE ds_crypto_krn', '-f');
--
--#begin public
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_message IN VARCHAR2
     ,p1 IN VARCHAR2 := NULL
     ,p2 IN VARCHAR2 := NULL
     ,p3 IN VARCHAR2 := NULL
   )
--#end public
   IS
      l_errno PLS_INTEGER;
      l_errmsg VARCHAR2(100);
   BEGIN
      IF NOT NVL(p_condition,FALSE) THEN
         IF SUBSTR(p_message,6,1) = ':' THEN
            BEGIN
               l_errno := 0 - TO_NUMBER(SUBSTR(p_message,1,5));
               l_errmsg := TRIM(SUBSTR(p_message,7));
            EXCEPTION
               WHEN OTHERS THEN
               l_errno := -20000;
               l_errmsg := p_message;
            END;
         ELSE
            l_errno := -20000;
            l_errmsg := p_message;
         END IF;
         raise_application_error(l_errno,REPLACE(REPLACE(REPLACE(ds_crypto_var.gk_error_assert||l_errmsg,':1',p1),':2',p2),':3',p3));
      END IF;
   END;
--#begin public
   ---
   -- Bitwise OR operation
   ---
   FUNCTION bitor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
--#end public
   AS
   BEGIN
      RETURN x + y - BITAND(x,y);
   END;
--#begin public
   ---
   -- Bitwise XOR operation
   ---
   FUNCTION bitxor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
--#end public
   AS
   BEGIN
      RETURN bitor(x,y) - bitand(x,y);
   END;
--#begin public
   ---
   -- Bitwise NOT operation
   ---
   FUNCTION bitnot (x IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
--#end public
   AS
   BEGIN
      RETURN POWER(2, num_bits) - 1 - x;
   END;
--#begin public
   ---
   -- Bitwise SHIFT operation
   ---
   FUNCTION bitshift (x IN NUMBER, n IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
--#end public
   AS
   BEGIN
      IF n > 0 THEN
         RETURN CASE
            WHEN n >= num_bits THEN 0
            ELSE MOD(x * POWER(2, n), POWER(2, num_bits))
         END;
      ELSIF n < 0 THEN
         RETURN CASE
            WHEN ABS(n) >= num_bits THEN 0
            ELSE TRUNC(x / POWER(2, ABS(n)))
         END;
      ELSE
         RETURN x;
      END IF;
   END;
--#begin public
   ---
   -- Bitwise ROTATE operation
   ---
   FUNCTION bitrotate (x IN NUMBER, n IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
--#end public
   AS
      m NUMBER := MOD(ABS(n), num_bits);
   BEGIN
      IF m = 0 THEN
         RETURN x;
      ELSIF n > 0 THEN
         m := num_bits - m;
      END IF;
      RETURN bitor(bitshift(x,-m,num_bits),bitshift(x,(num_bits-m),num_bits));
   END;
--#begin public
   ---
   -- Digitwise ROTATE operation
   ---
   FUNCTION digitrotate (x IN NUMBER, n IN NUMBER, num_digits IN NUMBER := 8)
   RETURN NUMBER
--#end public
   AS
      m NUMBER := MOD(ABS(n), num_digits);
      r NUMBER; -- right part to be rotated
   BEGIN
      IF x = 0 THEN
         RETURN 0;
      END IF;
      IF m = 0 THEN
         RETURN x;
      ELSIF n > 0 THEN
         m := num_digits - m;
      END IF;
      r := MOD(x, POWER(10, m));
      RETURN r * POWER(10, num_digits - m) + (x - r) / POWER(10, m);
   END;
--#begin public
   ---
   -- Charwise ROTATE operation
   ---
   FUNCTION charrotate (x IN VARCHAR2, n IN NUMBER, num_chars IN NUMBER := 8)
   RETURN VARCHAR2
--#end public
   AS
      m NUMBER := MOD(ABS(n), num_chars);
   BEGIN
      IF m = 0 THEN
         RETURN x;
      ELSIF n > 0 THEN
         m := num_chars - m;
      END IF;
      RETURN SUBSTR(RPAD(x,num_chars), -m) || SUBSTR(RPAD(x,num_chars), 1, num_chars - m);
   END;
--#begin public
   ---
   -- Reset encryption
   ---
   PROCEDURE reset_encryption
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      IF ds_crypto_var.g_algo = 'RSR' THEN
         ds_crypto_rsr_krn.reset_encryption;
      ELSE
         ds_crypto_ff3_krn.reset_encryption;
      END IF;
   END;
--#begin public
   ---
   -- Generate a character set based on a format template
   ---
   FUNCTION get_charset(p_format IN VARCHAR2)
   RETURN VARCHAR2
--#end public
   IS
      l_str VARCHAR2(256 CHAR);
      l_chr VARCHAR2(2 CHAR);
   BEGIN
      IF p_format IS NULL THEN
         RETURN NULL;
      END IF;
      FOR i IN 1..LENGTH(p_format) LOOP
         l_chr := SUBSTR(p_format,i,1);
         IF NVL(INSTR(l_str,l_chr),0) > 0 THEN
            NULL; -- char already in the set => ignore it
         ELSIF l_chr BETWEEN 'A' AND 'Z' THEN
            l_str := l_str || ds_crypto_var.gk_upper;
         ELSIF l_chr BETWEEN 'a' AND 'z' THEN
            l_str := l_str || ds_crypto_var.gk_lower;
         ELSIF l_chr BETWEEN '0' AND '9' THEN
            l_str := l_str || ds_crypto_var.gk_digit;
         ELSIF INSTR(ds_crypto_var.gk_lower_acc, l_chr) > 0 THEN
            l_str := l_str || ds_crypto_var.gk_lower_acc;
         ELSIF INSTR(ds_crypto_var.gk_upper_acc, l_chr) > 0 THEN
            l_str := l_str || ds_crypto_var.gk_upper_acc;
         ELSE
            l_str := l_str || l_chr;
         END IF;
      END LOOP;
      RETURN l_str;
   END;
--#begin public
   ---
   -- Set encryption algorithm
   ---
   PROCEDURE set_encryption_algo(p_algo IN VARCHAR2)
--#end public
   IS
   BEGIN
      IF p_algo IS NOT NULL THEN
         assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
         ds_crypto_var.g_algo := p_algo;
      END IF;
   END;
--#begin public
   ---
   -- Get encryption algorithm
   ---
   FUNCTION get_encryption_algo
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN ds_crypto_var.g_algo;
   END;
--#begin public
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key(p_key IN VARCHAR2 := NULL)
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      IF ds_crypto_var.g_algo = 'RSR' THEN
         ds_crypto_rsr_krn.set_encryption_key(p_key);
      ELSE
         ds_crypto_ff3_krn.set_encryption_key(p_key);
      END IF;
   END;
--#begin public
   ---
   -- Get encryption key
   ---
   FUNCTION get_encryption_key
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN ds_crypto_rsr_krn.get_encryption_key
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.get_encryption_key
              END;
   END;
--#begin public
   ---
   -- Set tweak (FF3 only)
   ---
   PROCEDURE set_tweak(p_tweak IN VARCHAR2 := NULL)
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      IF ds_crypto_var.g_algo = 'FF3' THEN
         ds_crypto_ff3_krn.set_tweak(p_tweak);
      END IF;
   END;
--#begin public
   ---
   -- Get tweak
   ---
   FUNCTION get_tweak
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN NULL
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.get_tweak
              END;
  END;
--#begin public
   ---
   -- Set minimum plaintext length (FF3 only)
   ---
   PROCEDURE set_min_len(p_min_len IN PLS_INTEGER)
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      IF ds_crypto_var.g_algo = 'FF3' THEN
         ds_crypto_ff3_krn.set_min_len(p_min_len);
      END IF;
   END;
--#begin public
   ---
   -- Get minimum plaintext length (FF3 only)
   ---
   FUNCTION get_min_len
   RETURN PLS_INTEGER
--#end public
   IS
   BEGIN
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN NULL
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.get_min_len
              END;
   END;
--#begin public
   ---
   -- Convert a normal string to a hexadecimal string
   -- Can be used to make a tweak from a normal string
   ---
   FUNCTION string_to_hex (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN RAWTOHEX(UTL_RAW.CAST_TO_RAW(p_str));
   END;
--#begin public
   ---
   -- Convert a hexadecimal string to a normal string
   -- Can be used to convert a tweak back to a string
   ---
   FUNCTION hex_to_string (
      p_hex IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN UTL_RAW.CAST_TO_VARCHAR2(HEXTORAW(p_hex));
   END;
--#begin public
   ---
   -- Get precision and scale of a give number
   ---
   PROCEDURE get_number_precision_and_scale (
      p_num IN NUMBER
    , p_precision OUT PLS_INTEGER
    , p_scale OUT PLS_INTEGER
    , p_negative IN BOOLEAN := FALSE
   )
--#end public
   IS
      l_str VARCHAR2(200);
      l_pos PLS_INTEGER;
      l_len PLS_INTEGER;
   BEGIN
      l_str := RTRIM(TO_CHAR(p_num));
      l_pos := NVL(INSTR(l_str,'.'),0);
      IF l_pos <= 0 THEN
         l_pos := NVL(INSTR(l_str,','),0);
      END IF;
      l_len := LENGTH(l_str);
      IF l_pos > 0 THEN
         p_precision := l_len - 1;
         p_scale := l_len - l_pos;
      ELSIF p_negative THEN
         l_pos := l_len;
         WHILE l_pos > 1 AND SUBSTR(l_str,l_pos,1) = '0' LOOP
            l_pos := l_pos - 1;
         END LOOP;
         p_precision := l_pos;
         p_scale := l_pos - l_len;
      ELSE
         p_precision := l_len;
         p_scale := 0;
      END IF;
   END;
--#begin public
   ---
   -- Check whether all characters of a string belong to a given character set
   ---
   FUNCTION in_charset (
      p_str IN VARCHAR2
    , p_set IN VARCHAR2
    , p_len IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      assert(p_len = LENGTH(p_str), ds_crypto_var.gk_error_length, p_len);
      IF p_set IS NULL OR p_str IS NULL THEN
         RETURN 'Y';
      END IF;
      FOR i IN 1..LENGTH(p_str) LOOP
         IF INSTR(p_set, SUBSTR(p_str,i,1)) <= 0 THEN
            RETURN 'N';
         END IF;
      END LOOP;
      RETURN 'Y';
   END;
--#begin public
   ---
   -- Encrypt or decrypt a a number
   ---
   FUNCTION encrypt_decrypt_number (
      p_op IN PLS_INTEGER                -- 1 for encryption, -1 for decryption
    , p_value IN NUMBER                  -- number to encrypt or decrypt
    , p_precision IN PLS_INTEGER := NULL -- encoding precision (default: same as input number)
    , p_scale IN PLS_INTEGER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL         -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      set_encryption_algo(p_algo);
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN ds_crypto_rsr_krn.encrypt_decrypt_number(p_op, p_value, p_precision, p_scale, p_key)
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.encrypt_decrypt_number(p_op, p_value, p_precision, p_scale, p_key, p_tweak)
              END;
   END;
--#begin public
   ---
   -- Encrypt or decrypt a string
   ---
   FUNCTION encrypt_decrypt_string (
      p_op IN PLS_INTEGER           -- 1 for encryption, -1 for decryption
    , p_value IN VARCHAR2           -- string to encrypt or deecrypt
    , p_len IN PLS_INTEGER := NULL  -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0)
    , p_charset IN VARCHAR2 := NULL -- character set (has priority over format)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      set_encryption_algo(p_algo);
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN ds_crypto_rsr_krn.encrypt_decrypt_string(p_op, p_value, p_len, p_format, p_charset, p_key)
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.encrypt_decrypt_string(p_op, p_value, p_len, p_format, p_charset, p_key, p_tweak)
              END;
   END;
   ---
   -- Encrypt or decrypt a date within a given range
   ---
   FUNCTION encrypt_decrypt_date (
      p_op IN PLS_INTEGER           -- 1 for encryption, -1 for decryption
    , p_value IN DATE               -- date to encrypt or decrypt
    , p_min_date IN DATE := NULL    -- minimum date (01/01/0001 AD by default)
    , p_max_date IN DATE := NULL    -- maximum date (31/12/9999 AD by default)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN DATE
   IS
      l_min_jul PLS_INTEGER := NVL(TO_CHAR(p_min_date,ds_crypto_var.gk_jul_format),ds_crypto_var.gk_min_jul);
      l_max_jul PLS_INTEGER := NVL(TO_CHAR(p_max_date,ds_crypto_var.gk_jul_format),ds_crypto_var.gk_max_jul);
      l_julian PLS_INTEGER := TO_NUMBER(TO_CHAR(p_value,ds_crypto_var.gk_jul_format));
      l_value TIMESTAMP := CAST(p_value AS TIMESTAMP);
      l_precision PLS_INTEGER;
      l_time NUMBER;
      l_result DATE;
   BEGIN
      -- Preserve NULL value
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      ds_crypto_krn.assert(l_min_jul<=l_max_jul,ds_crypto_var.gk_error_invalid_date_range);
      ds_crypto_krn.assert(l_julian BETWEEN l_min_jul AND l_max_jul,ds_crypto_var.gk_error_invalid_date);
      l_julian := l_julian - l_min_jul;
      l_max_jul := l_max_jul - l_min_jul;
      l_precision := CASE WHEN l_max_jul = 0 THEN 1 ELSE FLOOR(LOG(10,l_max_jul)) + 1 END;
      LOOP
         l_julian := encrypt_decrypt_number(p_op=>p_op, p_value=>l_julian, p_precision=>l_precision, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
         EXIT WHEN l_julian BETWEEN 0 AND l_max_jul;
      END LOOP;
      l_time := EXTRACT(HOUR FROM l_value) * ds_crypto_var.gk_sec_per_hour + EXTRACT(MINUTE FROM l_value) * ds_crypto_var.gk_sec_per_min + EXTRACT (SECOND FROM l_value);
      IF l_time > 0 THEN
         LOOP
            l_time := encrypt_decrypt_number(p_op=>p_op, p_value=>l_time, p_precision=>5, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
            EXIT WHEN l_time BETWEEN 0 AND ds_crypto_var.gk_sec_per_day;
         END LOOP;
      END IF;
      l_result := TO_DATE(TO_CHAR(l_julian + l_min_jul),ds_crypto_var.gk_jul_format) + NUMTODSINTERVAL(l_time, 'SECOND');
      RETURN l_result;
   END;
   ---
   -- Encrypt or decrypt an integer within a given range
   ---
   FUNCTION encrypt_decrypt_integer (
      p_op IN PLS_INTEGER           -- 1 for encryption, -1 for decryption
    , p_value IN NUMBER             -- date to encrypt or decrypt
    , p_min_value IN NUMBER         -- minimum integer
    , p_max_value IN NUMBER         -- maximum integer
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
   IS
      l_max_value NUMBER;
      l_result NUMBER;
      l_precision PLS_INTEGER;
   BEGIN
      -- Preserve NULL value
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      ds_crypto_krn.assert(TRUNC(p_value)=p_value,ds_crypto_var.gk_error_value_not_integer);
      ds_crypto_krn.assert(p_min_value IS NOT NULL, ds_crypto_var.gk_error_lower_limit_missing);
      ds_crypto_krn.assert(p_max_value IS NOT NULL, ds_crypto_var.gk_error_upper_limit_missing);
      ds_crypto_krn.assert(TRUNC(p_min_value)=p_min_value,ds_crypto_var.gk_error_lower_limit_not_int);
      ds_crypto_krn.assert(TRUNC(p_max_value)=p_max_value,ds_crypto_var.gk_error_upper_limit_not_int);
      ds_crypto_krn.assert(p_max_value>=p_min_value,ds_crypto_var.gk_error_invalid_range);
      ds_crypto_krn.assert(p_value BETWEEN p_min_value AND p_max_value,ds_crypto_var.gk_error_value_not_within_range);
      l_max_value := p_max_value - p_min_value;
      l_precision := CASE WHEN l_max_value = 0 THEN 1 ELSE FLOOR(LOG(10,l_max_value)) + 1 END;
      l_result := p_value - p_min_value;
      LOOP
         l_result := encrypt_decrypt_number(p_op=>p_op, p_value=>l_result, p_precision=>l_precision, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
         EXIT WHEN l_result BETWEEN 0 AND l_max_value;
      END LOOP;
      l_result := l_result + p_min_value;
      RETURN l_result;
   END;
--#begin public
   ---
   -- Encrypt a number
   ---
   FUNCTION encrypt_number (
      p_value IN NUMBER                  -- number to encrypt
    , p_precision IN PLS_INTEGER := NULL -- encoding precision (default: same as input number)
    , p_scale IN PLS_INTEGER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL         -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_number(ds_crypto_var.gk_op_encrypt, p_value, p_precision, p_scale, p_key, p_tweak, p_algo);
   END;
--#begin public
   ---
   -- Decrypt a number
   ---
   FUNCTION decrypt_number(
      p_value IN NUMBER                  -- number to decrypt
    , p_precision IN PLS_INTEGER := NULL -- encoding precision (default: same as input number)
    , p_scale IN PLS_INTEGER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL         -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_number(ds_crypto_var.gk_op_decrypt, p_value, p_precision, p_scale, p_key, p_tweak, p_algo);
   END;
--#begin public
   ---
   -- Encrypt a string
   ---
   FUNCTION encrypt_string (
      p_value IN VARCHAR2           -- string to encrypt
    , p_len IN PLS_INTEGER := NULL  -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0Éé)
    , p_charset IN VARCHAR2 := NULL -- character set (string of allowed characters)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_string(ds_crypto_var.gk_op_encrypt, p_value, p_len, p_format, p_charset, p_key, p_tweak, p_algo);
   END;
--#begin public
   ---
   -- Decrypt a string
   ---
   FUNCTION decrypt_string (
      p_value IN VARCHAR2           -- string to decrypt
    , p_len IN PLS_INTEGER := NULL  -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0Éé)
    , p_charset IN VARCHAR2 := NULL -- character set (string of allowed character)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      set_encryption_algo(p_algo);
      assert(ds_crypto_var.g_algo IN ('RSR','FF3'), ds_crypto_var.gk_error_invalid_algo);
      RETURN CASE ds_crypto_var.g_algo WHEN 'RSR' THEN ds_crypto_rsr_krn.encrypt_decrypt_string(ds_crypto_var.gk_op_decrypt, p_value, p_len, p_format, p_charset, p_key)
                                       WHEN 'FF3' THEN ds_crypto_ff3_krn.encrypt_decrypt_string(ds_crypto_var.gk_op_decrypt, p_value, p_len, p_format, p_charset, p_key, p_tweak)
              END;
   END;
--#begin public
   ---
   -- Encrypt a date (with time if not 00:00:00) within a given range
   ---
   FUNCTION encrypt_date (
      p_value IN DATE               -- date to encrypt
    , p_min_date IN DATE := NULL    -- minimum date (01/01/0001 AD by default)
    , p_max_date IN DATE := NULL    -- maximum date (31/12/9999 AD by default)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN DATE
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_date(p_op=>ds_crypto_var.gk_op_encrypt, p_value=>p_value, p_min_date=>p_min_date, p_max_date=>p_max_date, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
   END;
--#begin public
   ---
   -- Decrypt a date (with time if not 00:00:00) within a given range
   ---
   FUNCTION decrypt_date (
      p_value IN DATE               -- date to decrypt
    , p_min_date IN DATE := NULL    -- minimum date (01/01/0001 AD by default)
    , p_max_date IN DATE := NULL    -- maximum date (31/12/9999 AD by default)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL   -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL    -- algorithm (default: global algorithm)
   )
   RETURN DATE
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_date(p_op=>ds_crypto_var.gk_op_decrypt, p_value=>p_value, p_min_date=>p_min_date, p_max_date=>p_max_date, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
   END;
--#begin public
   ---
   -- Encrypt an integer within a given range
   ---
   FUNCTION encrypt_integer (
      p_value IN NUMBER                  -- number to encrypt
    , p_min_value IN NUMBER              -- lower limit of valid range
    , p_max_value IN NUMBER              -- upper limit of valid range
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL         -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_integer(p_op=>ds_crypto_var.gk_op_encrypt, p_value=>p_value, p_min_value=>p_min_value, p_max_value=>p_max_value, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
   END;
--#begin public
   ---
   -- Decrypt an integer within a given range
   ---
   FUNCTION decrypt_integer (
      p_value IN NUMBER                  -- number to encrypt
    , p_min_value IN NUMBER              -- lower limit of valid range
    , p_max_value IN NUMBER              -- upper limit of valid range
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
    , p_algo IN VARCHAR2 := NULL         -- algorithm (default: global algorithm)
   )
   RETURN NUMBER
--#end public
   IS
   BEGIN
      RETURN encrypt_decrypt_integer(p_op=>ds_crypto_var.gk_op_decrypt, p_value=>p_value, p_min_value=>p_min_value, p_max_value=>p_max_value, p_key=>p_key, p_tweak=>p_tweak, p_algo=>p_algo);
   END;
BEGIN
   reset_encryption;
END ds_crypto_krn;
/