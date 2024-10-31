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
   -- Get encryption version
   ---
   FUNCTION get_version
   RETURN PLS_INTEGER
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
   -- Encrypt a number of a given precision and scale based on a private key
   ---
   FUNCTION encrypt_number (
      p_value IN NUMBER                  -- number to encrypt
    , p_precision IN PLS_INTEGER := NULL -- encoding precision (default: same as input number)
    , p_scale IN PLS_INTEGER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL          -- encryption key (default: global encryption key)
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
   )
   RETURN NUMBER
   ;
   ---
   -- Encrypt a string using global key or passed one
   ---
   FUNCTION encrypt_string (
      p_value IN VARCHAR2           -- string to encrypt
    , p_len IN PLS_INTEGER := NULL  -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0Éé)
    , p_charset IN VARCHAR2 := NULL -- character set (string of allowed characters)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
   )
   RETURN VARCHAR2
   ;
   ---
   -- Decrypt a string of a given maximum length based on a private key
   ---
   FUNCTION decrypt_string (
      p_value IN VARCHAR2           -- string to decrypt
    , p_len IN PLS_INTEGER := NULL  -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0Éé)
    , p_charset IN VARCHAR2 := NULL -- character set (string of allowed character)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
   )
   RETURN VARCHAR2
   ;
   ---
   -- Encrypt a date (with time if not 00:00:00) with an encryption key
   -- Input date must be in the specified range if defined
   ---
   FUNCTION encrypt_date (
      p_value IN DATE               -- date to encrypt
    , p_min_date IN DATE := NULL    -- minimum date (01/01/4712 BC by default)
    , p_max_date IN DATE := NULL    -- maximum date (31/12/9999 AD by default)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
   )
   RETURN DATE
   ;
   ---
   -- Decrypt a date (with time if not 00:00:00) with an encryption key
   -- Input date must be in the specified range if defined
   ---
   FUNCTION decrypt_date (
      p_value IN DATE               -- date to decrypt
    , p_min_date IN DATE := NULL    -- minimum date (01/01/4712 BC by default)
    , p_max_date IN DATE := NULL    -- maximum date (31/12/9999 AD by default)
    , p_key IN VARCHAR2 := NULL     -- encryption key (default: global encryption key)
   )
   RETURN DATE
   ;
--#endif 0
END ds_crypto_krn;
/
