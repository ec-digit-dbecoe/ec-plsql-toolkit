CREATE OR REPLACE PACKAGE ds_crypto_var
ACCESSIBLE BY (PACKAGE ds_crypto_krn, PACKAGE ds_crypto_rsr_krn, PACKAGE ds_crypto_ff3_krn)
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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
   TYPE gt_map_table_type IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
   TYPE gt_map_matrix_type IS TABLE OF gt_map_table_type INDEX BY BINARY_INTEGER;
   TYPE gt_numbers IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   gt_map gt_map_matrix_type; -- vector of 8 transposition maps
   gk_dir CONSTANT PLS_INTEGER := 1; -- bit 1 for dir (fwd/rev)
   gk_len CONSTANT PLS_INTEGER := 2; -- bit 2 for length (1ch/2ch)
   gk_typ CONSTANT PLS_INTEGER := 3; -- bit 3 for type (num/str)
   gk_num CONSTANT PLS_INTEGER := 0; -- map for numbers
   gk_str CONSTANT PLS_INTEGER := 4; -- map for strings
   gk_1ch CONSTANT PLS_INTEGER := 0; -- map for 1 character
   gk_2ch CONSTANT PLS_INTEGER := 2; -- map for 2 characters
   gk_fwd CONSTANT PLS_INTEGER := 0; -- map for encrypting/forward
   gk_rev CONSTANT PLS_INTEGER := 1; -- map for decrypting/reverse
   gk_fwd_1ch_num CONSTANT PLS_INTEGER := 0; -- encrypt 1 digit number
   gk_rev_1ch_num CONSTANT PLS_INTEGER := 1; -- decrypt 1 digit number
   gk_fwd_2ch_num CONSTANT PLS_INTEGER := 2; -- encrypt 2 digit number
   gk_rev_2ch_num CONSTANT PLS_INTEGER := 3; -- decrypt 2 digit number
   gk_fwd_1ch_str CONSTANT PLS_INTEGER := 4; -- encrypt 1 char string
   gk_rev_1ch_str CONSTANT PLS_INTEGER := 5; -- decrypt 1 char string
   gk_fwd_2ch_str CONSTANT PLS_INTEGER := 6; -- encrypt 2 char string
   gk_rev_2ch_str CONSTANT PLS_INTEGER := 7; -- decrypt 2 char string
   g_rsr_key VARCHAR2(2000 CHAR) := NULL; -- Global RSR encryption key (home-made Random Substitutions and Rotations FPE algorithm) 
   g_ff3_key VARCHAR2(64 BYTE) := NULL; -- Global FF3 encryption key (3rd version of Feistel Function based FPE algorithms)
   g_ff3_tweak VARCHAR2(16 BYTE) := NULL; -- Global FF3 tweak
   g_ff3_default_tweak VARCHAR2(16 CHAR) := '0000000000000000'; -- Default tweak if tweak not set
   g_ff3_min_len PLS_INTEGER := 2; -- Minimum plaintext length (computed if not set)
   g_algo VARCHAR2(3 CHAR) := 'RSR'; -- RSR (Random Substitutions and Rotations) or FF3
   gk_charset               CONSTANT VARCHAR2(256 CHAR) := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ';
--   gk_ascii_256             CONSTANT VARCHAR2(256 CHAR) := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ';
--   gk_printable_256         CONSTANT VARCHAR2(256 CHAR) := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ';
--   gk_ascii                 CONSTANT VARCHAR2(256 CHAR) := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
--   gk_alnum                 CONSTANT VARCHAR2(128 CHAR) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; --	digits, uppercase and lowercase letters
--   gk_alpha                 CONSTANT VARCHAR2(128 CHAR) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'; --upper- and lowercase letters
--   gk_blank                 CONSTANT VARCHAR2(128 CHAR) := ' 	'; --space and TAB characters only
   gk_digit                 CONSTANT VARCHAR2(128 CHAR) := '0123456789'; --digits
   gk_upper                 CONSTANT VARCHAR2(128 CHAR) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; --uppercase letters
   gk_lower                 CONSTANT VARCHAR2(128 CHAR) := 'abcdefghijklmnopqrstuvwxyz'; --lowercase letters
--   gk_upper_256             CONSTANT VARCHAR2(128 CHAR) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ'; --uppercase letters
--   gk_lower_256             CONSTANT VARCHAR2(128 CHAR) := 'abcdefghijklmnopqrstuvwxyzµàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'; --lowercase letters
   gk_upper_acc             CONSTANT VARCHAR2(256 CHAR) := 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ';
   gk_lower_acc             CONSTANT VARCHAR2(256 CHAR) := 'µàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ';
--   gk_punct                 CONSTANT VARCHAR2(128 CHAR) := '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
--   gk_space                 CONSTANT VARCHAR2(128 CHAR) := ' 	'; --all blank (whitespace) characters, including spaces, tabs, new lines, carriage returns, form feeds, and vertical tabs
--   gk_word                  CONSTANT VARCHAR2(128 CHAR) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_'; --word characters
--   gk_xdigit                CONSTANT VARCHAR2(128 CHAR) := '0123456789ABCDEFabcdef'; -- hexadecimal digits
--   gk_name                  CONSTANT VARCHAR2(256 CHAR) := ' ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'; -- currently used
--   gk_charset               CONSTANT VARCHAR2(256 CHAR) := gk_alnum || gk_punct || gk_space;
   gt_lcg_seed gt_numbers;
   g_lcg_mult NUMBER := 1103515245;
   g_lcg_incr NUMBER := 12345;
   g_lcg_power NUMBER := 2147483647; --2^31-1
   gk_min_jul CONSTANT PLS_INTEGER := 1721424; -- 01/01/0001 AD
   gk_max_jul CONSTANT PLS_INTEGER := 5373484; -- 31/12/9999 AD
   gk_jul_format VARCHAR2(1) := 'J';
   gk_sec_per_min CONSTANT PLS_INTEGER := 60;
   gk_sec_per_hour CONSTANT PLS_INTEGER := 3600;
   gk_sec_per_day CONSTANT PLS_INTEGER := 86400;
   gk_error_assert CONSTANT VARCHAR2(7) := 'Error: ';
   gk_error_key_not_set CONSTANT VARCHAR2(27) := '20001: Encrypt key not set!';
   gk_error_length CONSTANT VARCHAR2(26) := '20002: Invalid length (:1)';
   gk_error_null_value CONSTANT VARCHAR2(17) := '20003: NULL value';
   gk_error_not_in_charset CONSTANT VARCHAR2(43) := '20004: character ":1" not in character set!';
   gk_error_key_length CONSTANT VARCHAR2(58) := '20005: Encryption key must be at least 16 characters long!';
   gk_error_invalid_precision CONSTANT VARCHAR2(51) := '20006: Invalid precision (must be stricly positive)';
   gk_error_invalid_scale CONSTANT VARCHAR2(48) := '20007: Invalid scale (valid range is [-84, 127])';
   gk_error_precision_exceeded CONSTANT VARCHAR2(42) := '20008: Invalid number (precision exceeded)';
   gk_error_scale_exceeded CONSTANT VARCHAR2(38) := '20009: Invalid number (scale exceeded)';
   gk_error_length_exceeded CONSTANT VARCHAR2(39) := '20011: Invalid string (length exceeded)';
   gk_error_charset_format CONSTANT VARCHAR2(56) := '20012: Character set and format cannot be both specified';
   gk_error_invalid_date CONSTANT VARCHAR2(36) := '20013: Invalid date (out of range)';
   gk_error_invalid_date_format CONSTANT VARCHAR2(45) := '20014: Invalid date format (must be BC or AD)';
   gk_error_invalid_length CONSTANT VARCHAR2(51) := '20015: Invalid length (must be strictly positive)';
   gk_error_invalid_character CONSTANT VARCHAR2(57) := '20016: Invalid character in string (not in character set)';
   gk_error_invalid_date_range CONSTANT VARCHAR2(25) := '20017: Invalid date range';
   gk_error_value_not_integer CONSTANT VARCHAR2(37) := '20018: Input value must be an integer';
   gk_error_upper_limit_missing CONSTANT VARCHAR2(31) := '20019: Upper limit is mandatory';
   gk_error_lower_limit_missing CONSTANT VARCHAR2(31) := '20020: Lower limit is mandatory';
   gk_error_upper_limit_not_int CONSTANT VARCHAR2(37) := '20021: Lower limit must be an integer';
   gk_error_lower_limit_not_int CONSTANT VARCHAR2(37) := '20022: Upper limit must be an integer';
   gk_error_invalid_range CONSTANT VARCHAR2(58) := '20023: Upper limit must be greater or equal to lower limit';
   gk_error_value_not_within_range VARCHAR2(39) := '20024: Input value must be within range';
   gk_error_ff3_key_length CONSTANT VARCHAR2(54) := '20025: Encryption key must be 16, 24 or 32 bytes long!';
   gk_error_tweak_length CONSTANT VARCHAR2(39) := '20026: Tweak must be 7 or 8 bytes long!';
   gk_error_invalid_min_length CONSTANT VARCHAR2(44) := '20027: Minimum plaintext length is 2 or more';
   gk_error_invalid_hex_string CONSTANT VARCHAR2(34) := '20028: Invalid hexadecimal string!';
   gk_error_infinite_loop CONSTANT VARCHAR2(30) := '20029: Infinite loop detected!';
   gk_error_invalid_algo CONSTANT VARCHAR2(56) := '20030: Invalid encryption algorithm (must be RSR or FF3)';
   gk_op_encrypt CONSTANT PLS_INTEGER := 1;
   gk_op_decrypt CONSTANT PLS_INTEGER := -1;
END ds_crypto_var;
/