CREATE OR REPLACE PACKAGE ds_crypto_ff3_krn
AUTHID DEFINER
ACCESSIBLE BY (PACKAGE ds_crypto_krn)
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
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE ds_crypto_ff3_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_crypto_ff3_krn','public','   ;')
--#if 0
   ---
   -- Reset encryption
   ---
   PROCEDURE reset_encryption
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
   -- Set tweak
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
   -- Set minimum plaintext length
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
   )
   RETURN VARCHAR2
   ;
--#endif 0
END ds_crypto_ff3_krn;
/