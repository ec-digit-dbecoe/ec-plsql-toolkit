CREATE OR REPLACE PACKAGE ds_crypto_krn AS
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
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE ds_crypto_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_crypto_krn','public','   ;')
--#if 0
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
   -- Encrypt a number of a given precision and scale based on a private key
   ---
   FUNCTION encrypt_number (
      p_value IN NUMBER             -- number to encrypt
    , p_precision IN NUMBER := NULL -- encoding precision (default: same as input number)
    , p_scale IN NUMBER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN NUMBER
   ;
   ---
   -- Decrypt a number
   ---
   FUNCTION decrypt_number (
      p_value IN NUMBER             -- number to decrypt
    , p_precision IN NUMBER := NULL -- encoding precision (default: same as input number)
    , p_scale IN NUMBER := NULL     -- encoding scale (default: same as input number)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN NUMBER
   ;
   ---
   -- Encrypt a string using global key or passed one
   ---
   FUNCTION encrypt_string (
      p_value IN VARCHAR2           -- string to encrypt
    , p_len IN NUMBER := NULL       -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0)
    , p_charset IN VARCHAR2 := NULL -- character set (has priority over format)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN VARCHAR2
   ;
   ---
   -- Decrypt a string of a given maximum length based on a private key
   ---
   FUNCTION decrypt_string (
      p_value IN VARCHAR2           -- string to decrypt
    , p_len IN NUMBER := NULL       -- encoding length (default = string length)
    , p_format IN VARCHAR2 := NULL  -- format (e.g. Aa0)
    , p_charset IN VARCHAR2 := NULL -- character set (has priority over format)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN VARCHAR2
   ;
   ---
   -- Encrypt a date with an encryption key
   -- When format is AD or BC, range is from 01/01/4712 BC to 31/12/9999 AD
   -- When no format is given, range is from 01/01/0001 AD to 31/12/9999 AD
   -- Input date must be within the range of the specified format
   ---
   FUNCTION encrypt_date (
      p_value IN DATE               -- date to encrypt
    , p_format IN VARCHAR2 := NULL  -- format: BC or AC (default)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN DATE
   ;
   ---
   -- Decrypt a ciphered date with an encryption key
   -- When format is AD or BC, range is from 01/01/4712 BC to 31/12/9999 AD
   -- When no format is given, range is from 01/01/0001 AD to 31/12/9999 AD
   -- Input date must be within the range of the specified format
   ---
   FUNCTION decrypt_date (
      p_value IN DATE               -- date to decrypt
    , p_format IN VARCHAR2 := NULL  -- format: BC or AC (default)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN DATE
   ;
   ---
   -- Encrypt a timestamp with an encryption key
   -- When format is AD or BC, range is from 01/01/4712 BC to 31/12/9999 AD
   -- When no format is given, range is from 01/01/0001 AD to 31/12/9999 AD
   -- Input date must be within the range of the specified format
   ---
   FUNCTION encrypt_timestamp (
      p_value IN TIMESTAMP          -- timestamp to encrypt
    , p_format IN VARCHAR2 := NULL  -- date format: BC or AC (default)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN TIMESTAMP
   ;
   ---
   -- Decrypt a ciphered timestamp with an encryption key
   -- When format is AD or BC, range is from 01/01/4712 BC to 31/12/9999 AD
   -- When no format is given, range is from 01/01/0001 AD to 31/12/9999 AD
   -- Input date must be within the range of the specified format
   ---
   FUNCTION decrypt_timestamp (
      p_value IN TIMESTAMP          -- timestamp to decrypt
    , p_format IN VARCHAR2 := NULL  -- date format: BC or AC (default)
    , p_key IN VARCHAR2 := NULL     -- encryption key
   )
   RETURN TIMESTAMP
   ;
--#endif 0
END ds_crypto_krn;
/
