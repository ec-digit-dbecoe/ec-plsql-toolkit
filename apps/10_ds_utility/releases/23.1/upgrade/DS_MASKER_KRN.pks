CREATE OR REPLACE PACKAGE ds_masker_krn AS
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
--Execute the following command twice: gen_utility.generate('PACKAGE ds_masker_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','ds_masker_krn','public','   ;')
--#if 0
   ---
   -- Return a random integer between 2 integers
   ---
   FUNCTION random_integer (
      p_min_value IN INTEGER := 1
    , p_max_value IN INTEGER := 99
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN INTEGER
   ;
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
   ;
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
   ;
   ---
   -- Return a random number with given scale and precision
   ---
   FUNCTION random_number (
      p_precision IN INTEGER := 5 -- total number of digits
    , p_scale     IN INTEGER := 2 -- number of digits after decimal
    , p_seed      IN VARCHAR2 := NULL
   )
   RETURN NUMBER
   ;
   ---
   -- Return a random date between 2 dates
   ---
   FUNCTION random_date (
       p_min_date IN DATE := TO_DATE('01/01/1970','DD/MM/YYYY')
     , p_max_date IN DATE := TRUNC(SYSDATE)
     , p_seed     IN VARCHAR2 := NULL
   )
   RETURN DATE
   ;
   ---
   -- Return a future random credit card expiry date
   -- within the given months timeframe
   ---
   FUNCTION random_expiry_date(
       p_months_range IN NUMBER := 60
     , p_seed     IN VARCHAR2 := NULL
   )
   RETURN DATE
   ;
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
   ;
   ---
   -- Set encryption key
   ---
   PROCEDURE set_encryption_key (
      p_key IN VARCHAR2
   )
   ;
   ---
   -- Encrypt a string (ASCII-256 charset)
   ---
   FUNCTION encrypt_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
   ;
   ---
   -- Decrypt a string (ASCII-256 charset)
   ---
   FUNCTION decrypt_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
   ;
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
   ;
   ---
   -- Encrypt a number
   ---
   FUNCTION encrypt_number (
      p_number IN NUMBER
   )
   RETURN NUMBER
   ;
   ---
   -- Decrypt a number
   ---
   FUNCTION decrypt_number (
      p_number IN NUMBER
   )
   RETURN NUMBER
   ;
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
   ;
   ---
   -- Remove accentuated characters from a string
   ---
   FUNCTION unaccentuate_string (
      p_string IN VARCHAR2
   )
   RETURN STRING
   ;
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
   ;
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_col_name IN ds_data_sets.set_name%TYPE
    , p_col_len  IN user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   ;
   ---
   -- Compute Luhn sum
   ---
   FUNCTION luhn_sum (
      p_num IN VARCHAR2
   )
   RETURN NUMBER
   ;
   ---
   -- Compute Luhn check digit
   ---
   FUNCTION luhn_checkdigit (
      p_num IN NUMBER
   )
   RETURN VARCHAR2
   ;
   ---
   -- Check if a number is a valid Luhn number
   ---
   FUNCTION is_valid_luhn_number (
      p_num IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Return a random Luhn number
   ---
   FUNCTION random_luhn_number (
      p_length IN NUMBER
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Filter characters of a string and keep only those specified in the format
   -- De-facto remove all spaces and ponctuation characters
   ---
   FUNCTION filter_characters (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2 := 'Aa0'
   )
   RETURN VARCHAR2
   ;
   ---
   -- Apply a format to a number (for credit card, BBAN, IBAN, etc...)
   ---
   FUNCTION format_number (
      p_string IN VARCHAR2
    , p_format IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Check the validity of an IBAN (International Bank Account Number)
   ---
   FUNCTION is_valid_iban (
      p_ctry_code IN VARCHAR2 := NULL
    , p_iban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
   ---
   -- Check the validity of a number with a modulo 97 checksum
   ---
   FUNCTION is_valid_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
   ---
   -- Obfuscate a number with modulo 97 checksum
   ---
   FUNCTION obfuscate_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Encrypt a number with modulo 97 checksum
   ---
   FUNCTION encrypt_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Decrypt a number with modulo 97 checksum
   ---
   FUNCTION decrypt_number_with_mod97 (
      p_num IN VARCHAR2
    , p_len IN NUMBER := NULL
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
   ---
   -- Check the validity of a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION is_valid_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
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
   ;
   ---
   -- Encrypt a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION encrypt_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Decrypt a BBAN (Basic Bank Account Number)
   -- For the given country (only Belgium is currently supported)
   ---
   FUNCTION decrypt_bban (
      p_ctry_code IN VARCHAR2
    , p_bban IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
   ---
   -- Check the validity of a credit card number
   ---
   FUNCTION is_valid_credit_card_number (
      p_card_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
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
   ;
   ---
   -- Encrypt a credit card number
   -- Preserve prefix (card issuer) and format (e.g. dashes or spaces)
   -- Recompute check digit to keep it a valid number
   ---
   FUNCTION encrypt_credit_card_number (
      p_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
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
   ;
   ---
   -- Decrypt a credit card number (previously encrypted with this package)Ah o
   -- Preserve prefix (card issuer) and format (e.g. dashes or spaces)
   -- Recompute check digit to keep it a valid number
   ---
   FUNCTION decrypt_credit_card_number (
      p_number IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y/N
   ;
   ---
   -- Returns dummy text based on Lorem Ipsum (classical Latin literature from 45 BC)
   ---
   FUNCTION lorem_ipsum_text (
      p_length IN NUMBER := NULL
   )
   RETURN VARCHAR2
   ;
--#endif 0
END ds_masker_krn;
/
