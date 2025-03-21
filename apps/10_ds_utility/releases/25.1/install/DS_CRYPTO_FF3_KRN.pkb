CREATE OR REPLACE PACKAGE BODY ds_crypto_ff3_krn
AS
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
--    exec gen_utility.generate('PACKAGE ds_crypto_ff3_krn', '-f');
--
--#begin public
   ---
   -- Reset encryption
   ---
   PROCEDURE reset_encryption
--#end public
   IS
   BEGIN
      ds_crypto_var.g_ff3_key := NULL;
      ds_crypto_var.g_ff3_tweak := NULL;
      ds_crypto_var.g_ff3_min_len := 2;
   END;
--#begin public
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key(p_key IN VARCHAR2 := NULL)
--#end public
   IS
   BEGIN
      ds_crypto_krn.assert(p_key IS NULL OR (MOD(LENGTH(p_key),2)=0 AND REGEXP_LIKE(p_key, '^[0-9A-Fa-f]+$')), ds_crypto_var.gk_error_invalid_hex_string);
      ds_crypto_krn.assert(p_key IS NULL OR LENGTH(p_key) IN (32, 48, 64), ds_crypto_var.gk_error_ff3_key_length);
      ds_crypto_var.g_ff3_key := p_key;
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
      RETURN ds_crypto_var.g_ff3_key;
   END;
--#begin public
   ---
   -- Set tweak
   ---
   PROCEDURE set_tweak(p_tweak IN VARCHAR2 := NULL)
--#end public
   IS
   BEGIN
      ds_crypto_krn.assert(p_tweak IS NULL OR (MOD(LENGTH(p_tweak),2)=0 AND REGEXP_LIKE(p_tweak, '^[0-9A-Fa-f]+$')), ds_crypto_var.gk_error_invalid_hex_string);
      ds_crypto_krn.assert(p_tweak IS NULL OR LENGTH(p_tweak) IN (14,16), ds_crypto_var.gk_error_tweak_length);
      ds_crypto_var.g_ff3_tweak := p_tweak;
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
      RETURN ds_crypto_var.g_ff3_tweak;
   END;
--#begin public
   ---
   -- Set minimum plaintext length
   ---
   PROCEDURE set_min_len(p_min_len IN PLS_INTEGER)
--#end public
   IS
   BEGIN
      ds_crypto_krn.assert(p_min_len IS NULL OR p_min_len >= 2, ds_crypto_var.gk_error_invalid_min_length);
      ds_crypto_var.g_ff3_min_len := p_min_len;
   END;
--#begin public
   ---
   -- Get minimum plaintext length
   ---
   FUNCTION get_min_len
   RETURN PLS_INTEGER
--#end public
   IS
   BEGIN
      RETURN ds_crypto_var.g_ff3_min_len;
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
   -- Encrypt or decrypt a a number
   ---
   FUNCTION encrypt_decrypt_number (
      p_op IN PLS_INTEGER                -- 1 for encryption, -1 for decryption
    , p_value IN NUMBER                  -- number to encrypt or decrypt
    , p_precision IN PLS_INTEGER := NULL -- encoding precision (default: same as input number)
    , p_scale IN PLS_INTEGER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
    , p_tweak IN VARCHAR2 := NULL        -- tweak (default: global tweak)
   )
   RETURN NUMBER
--#end public
   IS
      l_num_digits PLS_INTEGER;
      l_pow NUMBER;
      l_num NUMBER; -- number without decimals
      l_value NUMBER := ABS(p_value);
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_precision PLS_INTEGER := p_precision;
      l_scale PLS_INTEGER := p_scale;
      l_str VARCHAR2(100);
      l_cnt PLS_INTEGER := 0;
      l_radix PLS_INTEGER;
      l_log NUMBER;
      l_min_len PLS_INTEGER;
      l_max_len PLS_INTEGER;
   BEGIN
      -- Preserve NULL value
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      -- Validate parameters
      ds_crypto_krn.assert(p_precision IS NULL OR p_precision > 0,ds_crypto_var.gk_error_invalid_precision);
      ds_crypto_krn.assert(p_scale IS NULL OR p_scale BETWEEN -84 AND 127, ds_crypto_var.gk_error_invalid_scale);
      -- Set global key
      IF p_key IS NOT NULL THEN
         set_encryption_key(p_key);
      END IF;
      ds_crypto_krn.assert(ds_crypto_var.g_ff3_key IS NOT NULL, ds_crypto_var.gk_error_key_not_set);
      -- Set global tweak
      IF p_tweak IS NOT NULL THEN
         set_tweak(p_tweak);
      END IF;
      -- Determine precision and scale
      ds_crypto_krn.get_number_precision_and_scale(l_value, l_val_precision, l_val_scale, NVL(p_scale,0) < 0);
      l_scale := NVL(l_scale, l_val_scale);
      l_precision := NVL(l_precision, l_val_precision + l_scale - l_val_scale);
      ds_crypto_krn.assert(l_val_precision - l_val_scale <= l_precision - l_scale, ds_crypto_var.gk_error_precision_exceeded);
      ds_crypto_krn.assert(l_val_scale <= l_scale, ds_crypto_var.gk_error_scale_exceeded);
      l_num_digits := l_precision;
      l_pow := POWER(10, l_scale);
      l_num := l_value * l_pow;
      -- Proceed
      -- Minimum length is enforced by left padding with zeros
      -- Maximum length is never exceeded (38 digits in PL/SQL)
      l_log := LOG(10,1000000) / LOG(10,l_radix);
      l_min_len := NVL(ds_crypto_var.g_ff3_min_len, TRUNC(l_log) + CASE WHEN l_log > TRUNC(l_log) THEN 1 ELSE 0 END); -- minimum 6 digits
      l_max_len := TRUNC(2 * TRUNC(LOG(10,POWER(2, 96)) / LOG(10,l_radix))); -- maximum 56 digits
      l_str := LPAD(TO_CHAR(l_num),GREATEST(l_num_digits,l_min_len),'0'); -- left padding with zeros
      LOOP
         IF p_op = 1 THEN
            l_str := ff3encrypt(l_str, ds_crypto_var.g_ff3_key, NVL(ds_crypto_var.g_ff3_tweak,ds_crypto_var.g_ff3_default_tweak), ds_crypto_var.gk_digit);
         ELSE
            l_str := ff3decrypt(l_str, ds_crypto_var.g_ff3_key, NVL(ds_crypto_var.g_ff3_tweak,ds_crypto_var.g_ff3_default_tweak), ds_crypto_var.gk_digit);
         END IF;
         l_cnt := l_cnt + 1;
         ds_crypto_krn.assert(l_cnt<1000000,ds_crypto_var.gk_error_infinite_loop);
         EXIT WHEN LENGTH(NVL(LTRIM(l_str,'0'),'0')) <= l_num_digits;
      END LOOP;
      RETURN TO_NUMBER(l_str) / l_pow * CASE WHEN p_value < 0 THEN -1 ELSE 1 END;
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
   )
   RETURN VARCHAR2
--#end public
   IS
      l_charset VARCHAR2(255 CHAR) := SUBSTR(p_charset,1,255);
      l_str VARCHAR2(4000 CHAR);
      l_tmp VARCHAR2(255 CHAR);
      l_num_chars NUMBER := NVL(p_len,LENGTH(RTRIM(p_value)));
      l_space_allowed BOOLEAN;
      l_padded BOOLEAN;
      l_cnt PLS_INTEGER := 0;
      l_radix PLS_INTEGER;
      l_log NUMBER;
      l_min_len PLS_INTEGER;
      l_max_len PLS_INTEGER;
      l_rounds PLS_INTEGER;
      l_size PLS_INTEGER;
   BEGIN
      -- Preserve NULL value
      IF RTRIM(p_value) IS NULL THEN
         RETURN NULL;
      END IF;
      -- Validate parameters
      ds_crypto_krn.assert(p_len IS NULL OR p_len > 0, ds_crypto_var.gk_error_invalid_length);
      ds_crypto_krn.assert(p_len IS NULL OR p_len >= LENGTH(RTRIM(p_value)), ds_crypto_var.gk_error_length_exceeded);
      ds_crypto_krn.assert(p_format IS NULL OR p_charset IS NULL, ds_crypto_var.gk_error_charset_format);
      -- Set global key
      IF p_key IS NOT NULL THEN
         set_encryption_key(p_key);
      END IF;
      ds_crypto_krn.assert(ds_crypto_var.g_ff3_key IS NOT NULL, ds_crypto_var.gk_error_key_not_set);
      -- Set global tweak
      IF p_tweak IS NOT NULL THEN
         set_tweak(p_tweak);
      END IF;
      -- Proceed
      -- Minimum length is enforced by right padding with spaces
      -- Maximum length is enforced by encrypting by block
      IF l_charset IS NULL THEN
         l_charset := NVL(ds_crypto_krn.get_charset(p_format),ds_crypto_var.gk_charset);
      END IF;
      ds_crypto_krn.assert(ds_crypto_krn.in_charset(RTRIM(p_value), l_charset, l_num_chars) = 'Y', ds_crypto_var.gk_error_invalid_character); -- check charset
      l_radix := LENGTH(l_charset);
      l_log := LOG(10,1000000) / LOG(10,l_radix);
      l_min_len := NVL(ds_crypto_var.g_ff3_min_len, TRUNC(l_log) + CASE WHEN l_log > TRUNC(l_log) THEN 1 ELSE 0 END);
      l_max_len := TRUNC(2 * TRUNC(LOG(10,POWER(2, 96)) / LOG(10,l_radix)));
      l_str := RTRIM(p_value);
      l_rounds := TRUNC((GREATEST(LENGTH(l_str), l_num_chars) + l_max_len - 1) / l_max_len);
      -- For each block of maxLen bytes
      FOR i IN 1..l_rounds LOOP
         l_tmp := SUBSTR(l_str, 1 + l_max_len * (i - 1), l_max_len);
         l_cnt := 0;
         l_padded := FALSE;
         l_size := CASE WHEN i < l_rounds THEN l_max_len ELSE l_num_chars - (l_max_len * (i - 1)) END;
         IF i = l_rounds THEN
            -- Apply padding to last block if necessary
            l_padded := LENGTH(l_tmp) < GREATEST(l_size, l_min_len);
            l_tmp := RPAD(l_tmp, GREATEST(l_size, l_min_len), ' ');
            l_space_allowed := NVL(INSTR(l_charset, ' '),0) > 0;
            IF l_padded AND NOT l_space_allowed THEN
               l_charset := l_charset || ' ';
            END IF;
         END IF;
         LOOP
            IF p_op = 1 THEN
               l_tmp := ff3encrypt(l_tmp, ds_crypto_var.g_ff3_key, NVL(ds_crypto_var.g_ff3_tweak,ds_crypto_var.g_ff3_default_tweak), l_charset);
            ELSE
               l_tmp := ff3decrypt(l_tmp, ds_crypto_var.g_ff3_key, NVL(ds_crypto_var.g_ff3_tweak,ds_crypto_var.g_ff3_default_tweak), l_charset);
            END IF;
            l_cnt := l_cnt + 1;
            ds_crypto_krn.assert(l_cnt<1000000,ds_crypto_var.gk_error_infinite_loop);
            EXIT WHEN i < l_rounds OR (NVL(LENGTH(RTRIM(l_tmp)),0) = l_size AND (l_space_allowed OR NVL(INSTR(RTRIM(l_tmp), ' '),0)=0));
         END LOOP;
         l_str := SUBSTR(l_str, 1, l_max_len * (i - 1))
               || RTRIM(l_tmp)
               || SUBSTR(l_str, 1 + l_max_len * i);
      END LOOP;
      RETURN RTRIM(l_str);
   END;
BEGIN
   reset_encryption;
END ds_crypto_ff3_krn;
/