CREATE OR REPLACE PACKAGE BODY ds_crypto_rsr_krn
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
--    exec gen_utility.generate('PACKAGE ds_crypto_rsr_krn', '-f');
---
   PROCEDURE reset_seeds;
   ---
   -- Reset encryption maps
   ---
   PROCEDURE reset_encryption_maps IS
   BEGIN
      -- Reset maps
      FOR i IN 0..7 LOOP
         IF ds_crypto_var.gt_map.EXISTS(i) THEN
            ds_crypto_var.gt_map(i).DELETE;
         END IF;
      END LOOP;
   END;
--#begin public
   ---
   -- Reset encryption
   ---
   PROCEDURE reset_encryption
--#end public
   IS
   BEGIN
      reset_seeds;
      reset_encryption_maps;
      ds_crypto_var.g_rsr_key := NULL;
   END;
   ---
   -- Return a random value in the range [0,1[
   ---
   FUNCTION random_value (p_idx IN PLS_INTEGER)
   RETURN NUMBER
   IS
      l_temp NUMBER;
   BEGIN
      -- Manual computation of MOD(n,m) <=> round((n/m - trunc(n/m)) * m) to avoid overflow and rounding errors
--      ds_crypto_var.g_lcg_seed := (ds_crypto_var.g_lcg_seed * ds_crypto_var.g_lcg_mult + ds_crypto_var.g_lcg_incr) MOD ds_crypto_var.g_lcg_power;
      l_temp := (ds_crypto_var.gt_lcg_seed(p_idx) / ds_crypto_var.g_lcg_power * ds_crypto_var.g_lcg_mult)
              + (ds_crypto_var.g_lcg_incr / ds_crypto_var.g_lcg_power);
      ds_crypto_var.gt_lcg_seed(p_idx) := ROUND((l_temp - TRUNC(l_temp)) * ds_crypto_var.g_lcg_power);
      RETURN ds_crypto_var.gt_lcg_seed(p_idx) / ds_crypto_var.g_lcg_power;
   END;
   ---
   -- Return a random value in the range [min,max(
   ---
   FUNCTION random_value (
      p_idx IN PLS_INTEGER
    , p_min IN NUMBER
    , p_max IN NUMBER
   )
   RETURN NUMBER
   IS
   BEGIN
      RETURN p_min + (p_max - p_min) * random_value(p_idx);
   END;
   ---
   -- Set seed
   ---
   PROCEDURE seed (
      p_idx IN PLS_INTEGER
    , p_seed IN VARCHAR2
   )
   IS
      l_hash RAW(256);
      l_seed NUMBER;
      l_format VARCHAR2(32) := RPAD('X',32,'X');
   BEGIN
      IF p_idx = 1 THEN
         l_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_seed), 4); -- DBMS_CRYPTO.HASH_SH256
         l_seed := MOD(TO_NUMBER(SUBSTR(RAWTOHEX(l_hash),1,32), l_format),ds_crypto_var.g_lcg_power);
         ds_crypto_var.gt_lcg_seed(1) := l_seed;
         l_seed := MOD(TO_NUMBER(SUBSTR(RAWTOHEX(l_hash),33), l_format),ds_crypto_var.g_lcg_power);
         ds_crypto_var.gt_lcg_seed(2) := l_seed;
      ELSE
         l_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_seed), 1); -- DBMS_SCRYPTO.HASH_MD4
         l_seed := MOD(TO_NUMBER(RAWTOHEX(l_hash), l_format),ds_crypto_var.g_lcg_power);
         ds_crypto_var.gt_lcg_seed(3) := l_seed;
         l_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_seed), 2); -- DBMS_SCRYPTO.HASH_MD5
         l_seed := MOD(TO_NUMBER(RAWTOHEX(l_hash), l_format),ds_crypto_var.g_lcg_power);
         ds_crypto_var.gt_lcg_seed(4) := l_seed;
      END IF;
   END;
--#begin public
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key(p_key IN VARCHAR2 := NULL)
--#end public
   IS
      l_key VARCHAR2(2000) := SUBSTR(TRIM(p_key),1,2000);
   BEGIN
      ds_crypto_krn.assert(l_key IS NULL OR LENGTH(l_key) >= 16, ds_crypto_var.gk_error_key_length);
      -- Do nothing if key no changed
      IF (l_key IS NULL AND ds_crypto_var.g_rsr_key IS NULL)
      OR (l_key = ds_crypto_var.g_rsr_key)
      THEN
         RETURN;
      END IF;
      -- Set key
      ds_crypto_var.g_rsr_key := l_key;
      -- Reset maps
      reset_encryption_maps;
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
      RETURN ds_crypto_var.g_rsr_key;
   END;
   ---
   -- Dump encryption map
   ---
$IF $$debug_on $THEN
   PROCEDURE dump_encryption_map (p_idx IN VARCHAR2)
   IS
      l_cnt PLS_INTEGER;
   BEGIN
      l_cnt := ds_crypto_var.gt_map(p_idx).COUNT;
      dbms_output.put_line('Mapping table #'||p_idx||' for key "'||ds_crypto_var.g_rsr_key||'" ('||l_cnt||' cells):');
      FOR i IN 0..l_cnt-1 LOOP
         dbms_output.put(TO_CHAR(ds_crypto_var.gt_map(p_idx)(i),'FM0'||RPAD('9',TRUNC(LOG(10, ABS(l_cnt))),'9'))||' ');
         IF MOD(i+1,10)=0 THEN
            dbms_output.put_line('');
         END IF;
      END LOOP;
      dbms_output.put_line('');
   END;
$END
   ---
   -- Initialize encryption map
   ---
   PROCEDURE init_encryption_map (p_seed_idx IN PLS_INTEGER, p_map_idx IN PLS_INTEGER, p_size IN NUMBER)
   IS
      l_max PLS_INTEGER := p_size-1;
      l_idx PLS_INTEGER;
      l_tmp PLS_INTEGER;
      l_str VARCHAR2(4000);
      l_fwd_idx PLS_INTEGER := ds_crypto_krn.bitor(bitand(p_map_idx,ds_crypto_krn.bitnot(ds_crypto_var.gk_dir,3)),ds_crypto_var.gk_fwd);
      l_rev_idx PLS_INTEGER := ds_crypto_krn.bitor(bitand(p_map_idx,ds_crypto_krn.bitnot(ds_crypto_var.gk_dir,3)),ds_crypto_var.gk_rev);
      t_tmp ds_crypto_var.gt_map_table_type;
   BEGIN
      IF ds_crypto_var.gt_map.EXISTS(p_map_idx) AND ds_crypto_var.gt_map(p_map_idx).COUNT = p_size THEN
         RETURN;
      END IF;
      -- Initialize random generator
      ds_crypto_krn.assert(ds_crypto_var.g_rsr_key IS NOT NULL,ds_crypto_var.gk_error_key_not_set);
      seed(1,ds_crypto_var.g_rsr_key);
      -- Initialize the transition table
      FOR i IN 0..l_max LOOP
         t_tmp(i) := i;
      END LOOP;
      -- Generate random permutations
      FOR i IN 1..l_max-1 LOOP
         -- Pick a value to the right at random
         l_idx := TRUNC(random_value(p_seed_idx,i,l_max+1));
         -- Permute values
         IF l_idx > i THEN
            l_tmp := t_tmp(l_idx);
            t_tmp(l_idx) := t_tmp(i);
            t_tmp(i) := l_tmp;
         END IF;
      END LOOP;
      t_tmp(l_max+1) := t_tmp(0); -- cycle
      -- Initialise forward and reverse maps
      FOR i IN 0..l_max LOOP
         ds_crypto_var.gt_map(l_fwd_idx)(t_tmp(i)) := t_tmp(i+1);
         ds_crypto_var.gt_map(l_rev_idx)(t_tmp(i+1)) := t_tmp(i);
      END LOOP;
$IF $$debug_on $THEN
      dump_encryption_map(l_fwd_idx);
      dump_encryption_map(l_rev_idx);
$END
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
   )
   RETURN NUMBER
--#end public
   IS
      l_num_digits PLS_INTEGER;
      l_pow NUMBER;
      l_num NUMBER; -- number without decimals
      l_len PLS_INTEGER;
      l_value NUMBER := ABS(p_value);
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_precision PLS_INTEGER := p_precision;
      l_scale PLS_INTEGER := p_scale;
      l_dirmap PLS_INTEGER;
      l_rounds PLS_INTEGER;
      l_dir PLS_INTEGER;
      l_str VARCHAR2(100);
      l_mid VARCHAR2(100);
      l_op_1ch_num PLS_INTEGER := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ds_crypto_var.gk_fwd_1ch_num
                                            WHEN ds_crypto_var.gk_op_decrypt THEN ds_crypto_var.gk_rev_1ch_num END;
      l_op_2ch_num PLS_INTEGER := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ds_crypto_var.gk_fwd_2ch_num
                                            WHEN ds_crypto_var.gk_op_decrypt THEN ds_crypto_var.gk_rev_2ch_num END;
      i PLS_INTEGER;
      j PLS_INTEGER;
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
      -- Determine precision and scale
      ds_crypto_krn.get_number_precision_and_scale(l_value, l_val_precision, l_val_scale, NVL(p_scale,0) < 0);
      l_scale := NVL(l_scale, l_val_scale);
      l_precision := NVL(l_precision, l_val_precision + l_scale - l_val_scale);
      ds_crypto_krn.assert(l_val_precision - l_val_scale <= l_precision - l_scale, ds_crypto_var.gk_error_precision_exceeded);
      ds_crypto_krn.assert(l_val_scale <= l_scale, ds_crypto_var.gk_error_scale_exceeded);
      l_num_digits := l_precision;
      l_pow := POWER(10, l_scale);
      l_num := l_value * l_pow;
      -- Initialize map tables if not done yet
      init_encryption_map(1, l_op_1ch_num, POWER(10,1));
      init_encryption_map(2, l_op_2ch_num, POWER(10,2));
      -- Proceed
      IF l_num_digits <= 1 THEN
         RETURN ds_crypto_var.gt_map(l_op_1ch_num)(l_num) / l_pow;
      END IF;
      seed(2,ds_crypto_var.g_rsr_key);
      l_rounds := TRUNC(random_value(3,6,9+1));
      l_dirmap := TRUNC(random_value(4,0,POWER(2,l_rounds)));
      l_str := LPAD(TO_CHAR(l_num),l_num_digits,'0');
      FOR ii IN 1..l_rounds LOOP  -- reverse order when decrypting
         i := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ii WHEN ds_crypto_var.gk_op_decrypt THEN l_rounds - ii + 1 END;
         FOR k IN 1..2 LOOP  -- one loop for transposition, one loop for rotation
            IF k * p_op IN (1, -2) THEN -- encryption: transposition before rotation; decryption: the inverse
               FOR jj IN  1..l_num_digits LOOP  -- reverse order when decrypting
                  j := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN jj WHEN ds_crypto_var.gk_op_decrypt THEN l_num_digits - jj + 1 END;
                  l_mid := SUBSTR(l_str,j,2);
                  l_len := LENGTH(l_mid);
                  ds_crypto_krn.assert(l_len BETWEEN 1 AND 2,ds_crypto_var.gk_error_length,l_len);
                  LOOP
                     l_mid := TO_CHAR(ds_crypto_var.gt_map(CASE WHEN l_len = 1 THEN l_op_1ch_num ELSE l_op_2ch_num END)(TO_NUMBER(l_mid)));
                     EXIT WHEN p_precision IS NOT NULL OR (j > 1 OR LENGTH(l_mid) = l_len); -- no leading 0
                  END LOOP;
                  l_str := SUBSTR(l_str,1,j-1) || LPAD(l_mid,l_len,'0') || SUBSTR(l_str,j+2);
               END LOOP; --j
            END IF;
            IF k * p_op IN (2, -1) THEN
               IF i < l_rounds THEN
                  l_dir := CASE WHEN BITAND(l_dirmap,POWER(2,i-1)) = 0 THEN 1 ELSE -1 END * p_op;
                  LOOP
                     l_str := ds_crypto_krn.charrotate(l_str, l_dir, l_num_digits);
                     EXIT WHEN p_precision IS NOT NULL OR SUBSTR(l_str,1,1) != '0'; -- no leading 0
                  END LOOP;
               END IF;
            END IF;
         END LOOP; --k
      END LOOP; --i
      RETURN TO_NUMBER(l_str) / l_pow * CASE WHEN p_value < 0 THEN -1 ELSE 1 END;
   END;
   ---
   -- Reset seeds
   ---
   PROCEDURE reset_seeds IS
   BEGIN
      ds_crypto_var.gt_lcg_seed.DELETE;
      ds_crypto_var.g_lcg_mult := 1103515245;
      ds_crypto_var.g_lcg_incr := 12345;
      ds_crypto_var.g_lcg_power := 2147483647; --2^31-1
      FOR i IN 1..3 LOOP
         ds_crypto_var.gt_lcg_seed(i) := ds_crypto_var.g_lcg_mult;
      END LOOP;
   END;
   ---
   -- Convert a 1 or 2 characters string to a map index
   ---
   FUNCTION str_to_idx (
      p_value IN VARCHAR2
    , p_len IN PLS_INTEGER
   )
   RETURN NUMBER
   IS
      l_chr VARCHAR2(2);
      l_pos PLS_INTEGER;
      l_idx NUMBER := 0;
   BEGIN
      ds_crypto_krn.assert(p_value IS NOT NULL, ds_crypto_var.gk_error_null_value);
      ds_crypto_krn.assert(LENGTH(p_value) = p_len, ds_crypto_var.gk_error_length, p_len);
      FOR i IN 1..2 LOOP
         l_chr := SUBSTR(p_value, i, 1);
         EXIT WHEN l_chr IS NULL;
         l_pos := NVL(INSTR(ds_crypto_var.gk_charset, l_chr),0) - 1;
         ds_crypto_krn.assert(l_pos >= 0, ds_crypto_var.gk_error_not_in_charset, l_chr);
         l_idx := l_idx + l_pos * POWER(LENGTH(ds_crypto_var.gk_charset), i-1);
      END LOOP;
      RETURN l_idx;
   END;
   ---
   -- Convert a map index into a 1 or 2 characters string
   ---
   FUNCTION idx_to_str (
      p_idx IN NUMBER
    , p_len IN PLS_INTEGER
   )
   RETURN VARCHAR2
   IS
      l_pos PLS_INTEGER;
      l_len NUMBER := LENGTH(ds_crypto_var.gk_charset);
      l_str VARCHAR2(10);
   BEGIN
      ds_crypto_krn.assert(p_idx IS NOT NULL, ds_crypto_var.gk_error_null_value);
      l_pos := MOD(p_idx, l_len) + 1;
      l_str := SUBSTR(ds_crypto_var.gk_charset, l_pos, 1);
      IF p_len >= 2 THEN
         l_pos := TRUNC(p_idx / l_len) + 1;
         l_str := l_str || SUBSTR(ds_crypto_var.gk_charset, l_pos, 1);
      END IF;
      ds_crypto_krn.assert(LENGTH(l_str)=p_len, ds_crypto_var.gk_error_length, p_len);
      RETURN l_str;
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
   )
   RETURN VARCHAR2
--#end public
   IS
      l_str VARCHAR2(4000);
      l_mult PLS_INTEGER := 1;
      l_num_chars NUMBER := NVL(p_len,LENGTH(p_value));
      l_mid VARCHAR2(4000);
      l_len PLS_INTEGER;
      l_dirmap PLS_INTEGER;
      l_rounds PLS_INTEGER;
      l_dir PLS_INTEGER;
      l_charset VARCHAR2(255 CHAR) := SUBSTR(p_charset,1,255);
      l_op_1ch_str PLS_INTEGER := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ds_crypto_var.gk_fwd_1ch_str
                                            WHEN ds_crypto_var.gk_op_decrypt THEN ds_crypto_var.gk_rev_1ch_str END;
      l_op_2ch_str PLS_INTEGER := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ds_crypto_var.gk_fwd_2ch_str
                                            WHEN ds_crypto_var.gk_op_decrypt THEN ds_crypto_var.gk_rev_2ch_str END;
      i PLS_INTEGER;
      j PLS_INTEGER;
   BEGIN
      -- Preserve NULL value
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      -- Validate parameters
      ds_crypto_krn.assert(p_len IS NULL OR p_len > 0, ds_crypto_var.gk_error_invalid_length);
      ds_crypto_krn.assert(p_len IS NULL OR p_len >= LENGTH(p_value), ds_crypto_var.gk_error_length_exceeded);
      ds_crypto_krn.assert(p_format IS NULL OR p_charset IS NULL, ds_crypto_var.gk_error_charset_format);
      -- Set global key
      IF p_key IS NOT NULL THEN
         set_encryption_key(p_key);
      END IF;
      -- Initialize map tables if not done yet
      init_encryption_map(1, l_op_1ch_str, POWER(LENGTH(ds_crypto_var.gk_charset),1));
      init_encryption_map(2, l_op_2ch_str, POWER(LENGTH(ds_crypto_var.gk_charset),2));
      -- Proceed
      IF l_charset IS NULL THEN
         l_charset := ds_crypto_krn.get_charset(p_format);
      END IF;
      l_str := RPAD(RTRIM(p_value),l_num_chars, ' ');
      ds_crypto_krn.assert(ds_crypto_krn.in_charset(l_str, l_charset, LENGTH(l_str)) = 'Y', ds_crypto_var.gk_error_invalid_character); -- check charset
      seed(2,ds_crypto_var.g_rsr_key);
      l_rounds := TRUNC(random_value(3,6,9+1));
      l_dirmap := TRUNC(random_value(4,0,POWER(2,l_rounds)));
      FOR ii IN  1..l_rounds LOOP -- reverse order when decrypting
         i := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN ii WHEN ds_crypto_var.gk_op_decrypt THEN l_rounds - ii + 1 END;
         FOR k IN 1..2 LOOP -- one loop for transposition, one loop for rotation
            IF k * p_op IN (1, -2) THEN -- encryption: transposition before rotation; decryption: the inverse
               FOR jj IN  1..l_num_chars LOOP -- reverse order when decrypting
                  j := CASE p_op WHEN ds_crypto_var.gk_op_encrypt THEN jj WHEN ds_crypto_var.gk_op_decrypt THEN l_num_chars - jj + 1 END;
                  l_mid := SUBSTR(l_str,j,2);
                  l_len := LENGTH(l_mid);
                  ds_crypto_krn.assert(l_len BETWEEN 1 AND 2,ds_crypto_var.gk_error_length,l_len);
                  LOOP
                     l_mid := idx_to_str(ds_crypto_var.gt_map(CASE WHEN l_len = 1 THEN l_op_1ch_str ELSE l_op_2ch_str END)(str_to_idx(l_mid,l_len)),l_len);
                     EXIT WHEN ds_crypto_krn.in_charset(l_mid, l_charset, l_len) = 'Y' AND (p_len IS NOT NULL OR j < l_num_chars-1 OR SUBSTR(l_mid,-1,1) != ' '); -- in charset and no trailing space
                  END LOOP;
                  l_str := SUBSTR(l_str,1,j-1) || l_mid || SUBSTR(l_str,j+2);
               END LOOP; --j
            END IF;
            IF k * p_op IN (2, -1) THEN
               IF i < l_rounds THEN
                  l_dir := CASE WHEN BITAND(l_dirmap,POWER(2,i-1)) = 0 THEN 1 ELSE -1 END * p_op;
                  LOOP
                     l_str := ds_crypto_krn.charrotate(l_str, l_dir, l_num_chars);
                     EXIT WHEN p_len IS NOT NULL OR SUBSTR(l_str,-1,1) != ' '; -- no trailing space
                  END LOOP;
               END IF;
            END IF;
         END LOOP; --k
      END LOOP; --i
      RETURN RTRIM(l_str);
   END;
BEGIN
   reset_encryption;
END ds_crypto_rsr_krn;
/
