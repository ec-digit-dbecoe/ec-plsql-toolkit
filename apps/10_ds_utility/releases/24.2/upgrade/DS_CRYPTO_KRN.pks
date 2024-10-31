CREATE OR REPLACE PACKAGE ds_crypto_krn AS
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
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE ds_crypto_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_crypto_krn','public','   ;')
--#if 0
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
   ;
   ---
   -- Bitwise OR operation
   ---
   FUNCTION bitor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
   ;
   ---
   -- Bitwise XOR operation
   ---
   FUNCTION bitxor (x IN NUMBER, y IN NUMBER)
   RETURN NUMBER
   ;
   ---
   -- Bitwise NOT operation
   ---
   FUNCTION bitnot (x IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
   ;
   ---
   -- Bitwise SHIFT operation
   ---
   FUNCTION bitshift (x IN NUMBER, n IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
   ;
   ---
   -- Bitwise ROTATE operation
   ---
   FUNCTION bitrotate (x IN NUMBER, n IN NUMBER, num_bits IN NUMBER := 32)
   RETURN NUMBER
   ;
   ---
   -- Digitwise ROTATE operation
   ---
   FUNCTION digitrotate (x IN NUMBER, n IN NUMBER, num_digits IN NUMBER := 8)
   RETURN NUMBER
   ;
   ---
   -- Charwise ROTATE operation
   ---
   FUNCTION charrotate (x IN VARCHAR2, n IN NUMBER, num_chars IN NUMBER := 8)
   RETURN VARCHAR2
   ;
   ---
   -- Reset encryption
   ---
   PROCEDURE reset_encryption
   ;
   ---
   -- Generate a character set based on a format template
   ---
   FUNCTION get_charset(p_format IN VARCHAR2)
   RETURN VARCHAR2
   ;
   ---
   -- Set encryption algorithm
   ---
   PROCEDURE set_encryption_algo(p_algo IN VARCHAR2)
   ;
   ---
   -- Get encryption algorithm
   ---
   FUNCTION get_encryption_algo
   RETURN VARCHAR2
   ;
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key(p_key IN VARCHAR2 := NULL)
   ;
   ---
   -- Get encryption key
   ---
   FUNCTION get_encryption_key
   RETURN VARCHAR2
   ;
   ---
   -- Set tweak (FF3 only)
   ---
   PROCEDURE set_tweak(p_tweak IN VARCHAR2 := NULL)
   ;
   ---
   -- Get tweak
   ---
   FUNCTION get_tweak
   RETURN VARCHAR2
   ;
   ---
   -- Set minimum plaintext length (FF3 only)
   ---
   PROCEDURE set_min_len(p_min_len IN PLS_INTEGER)
   ;
   ---
   -- Get minimum plaintext length
   ---
   FUNCTION get_min_len
   RETURN PLS_INTEGER
   ;
   ---
   -- Convert a normal string to a hexadecimal string
   -- Can be used to make a tweak from a normal string
   ---
   FUNCTION string_to_hex (
      p_str IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Convert a hexadecimal string to a normal string
   -- Can be used to convert a tweak back to a string
   ---
   FUNCTION hex_to_string (
      p_hex IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get precision and scale of a give number
   ---
   PROCEDURE get_number_precision_and_scale (
      p_num IN NUMBER
    , p_precision OUT PLS_INTEGER
    , p_scale OUT PLS_INTEGER
    , p_negative IN BOOLEAN := FALSE
   )
   ;
   ---
   -- Check whether all characters of a string belong to a given character set
   ---
   FUNCTION in_charset (
      p_str IN VARCHAR2
    , p_set IN VARCHAR2
    , p_len IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
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
   ;
--#endif 0
END ds_crypto_krn;
/