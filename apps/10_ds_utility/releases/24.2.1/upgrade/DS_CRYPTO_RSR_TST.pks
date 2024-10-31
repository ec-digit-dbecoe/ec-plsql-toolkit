CREATE OR REPLACE PACKAGE ds_crypto_rsr_tst
AUTHID DEFINER
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
-- along with this program.  If not, see <https:
---
-- To generate package specification and body with test code, execute the following commands:
--    exec gen_utility.generate('PACKAGE ds_crypto_rsr_tst', '-f');
--    exec gen_utility.generate('PACKAGE BODY ds_crypto_rsr_tst', '-f');
--
--@--#pragma reversible
--@/*--#delete
 
   --%suite(Encryption library)
 
   --%context(encrypt_decrypt_string)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_decrypt_string_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_decrypt_string_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt/decrypt string: value)
   PROCEDURE test_encrypt_decrypt_string_1;
 
   --%test(case #2 - encrypt/decrypt string: value+len)
   PROCEDURE test_encrypt_decrypt_string_2;
 
   --%test(case #3 - encrypt/decrypt string: value+format)
   PROCEDURE test_encrypt_decrypt_string_3;
 
   --%test(case #4 - encrypt/decrypt string: value+charset)
   PROCEDURE test_encrypt_decrypt_string_4;
 
   --%test(case #5 - encrypt/decrypt string: value+key)
   PROCEDURE test_encrypt_decrypt_string_5;
 
   --%test(case #6 - encrypt/decrypt string: value+len+format)
   PROCEDURE test_encrypt_decrypt_string_6;
 
   --%test(case #7 - encrypt/decrypt string: value+len+charset)
   PROCEDURE test_encrypt_decrypt_string_7;
 
   --%test(case #8 - encrypt/decrypt string: value+len+key)
   PROCEDURE test_encrypt_decrypt_string_8;
 
   --%test(case #9 - encrypt/decrypt string error: value+format+charset)
   --%throws(-20012)
   PROCEDURE test_encrypt_decrypt_string_9;
 
   --%test(case #10 - encrypt/decrypt string: value+format+key)
   PROCEDURE test_encrypt_decrypt_string_10;
 
   --%test(case #11 - encrypt/decrypt string: value+charset+key)
   PROCEDURE test_encrypt_decrypt_string_11;
 
   --%test(case #12 - encrypt/decrypt string: null value)
   PROCEDURE test_encrypt_decrypt_string_12;
 
   --%test(case #13 - encrypt/decrypt string error: value)
   --%throws(-20011)
   PROCEDURE test_encrypt_decrypt_string_13;
 
   --%test(case #14 - encrypt/decrypt string error: charset)
   --%throws(-20016)
   PROCEDURE test_encrypt_decrypt_string_14;
 
   --%test(case #15 - encrypt/decrypt string error: charset)
   --%throws(-20016)
   PROCEDURE test_encrypt_decrypt_string_15;
--#endif 0
 
   --%endcontext(encrypt_decrypt_string)
 
   --%context(encrypt_string)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_string_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_string_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt string: key too short)
   --%throws(-20005)
   PROCEDURE test_encrypt_string_1;
 
   --%test(case #2 - encrypt string: value only)
   PROCEDURE test_encrypt_string_2;
 
   --%test(case #3 - encrypt string: value+len)
   PROCEDURE test_encrypt_string_3;
 
   --%test(case #4 - encrypt string: value+format)
   PROCEDURE test_encrypt_string_4;
 
   --%test(case #5 - encrypt string error: invalid character)
   --%throws(-20016)
   PROCEDURE test_encrypt_string_5;
 
   --%test(case #6 - encrypt string: value+charset)
   PROCEDURE test_encrypt_string_6;
 
   --%test(case #7 - encrypt string: value+len+format)
   PROCEDURE test_encrypt_string_7;
 
   --%test(case #8 - encrypt string: value+charset)
   PROCEDURE test_encrypt_string_8;
--#endif 0
 
   --%endcontext(encrypt_decrypt_string)
 
   --%context(encrypt_decrypt_number)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_decrypt_number_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_decrypt_number_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt/decrypt number: value)
   PROCEDURE test_encrypt_decrypt_number_1;
 
   --%test(case #2 - encrypt/decrypt number: value+precision)
   PROCEDURE test_encrypt_decrypt_number_2;
 
   --%test(case #3 - encrypt/decrypt number: value+precision+scale)
   PROCEDURE test_encrypt_decrypt_number_3;
 
   --%test(case #4 - encrypt/decrypt number: value+key)
   PROCEDURE test_encrypt_decrypt_number_4;
 
   --%test(case #5 - encrypt/decrypt number: value+precision+scale+key)
   PROCEDURE test_encrypt_decrypt_number_5;
 
   --%test(case #6 - encrypt/decrypt number: null value)
   PROCEDURE test_encrypt_decrypt_number_6;
 
   --%test(case #7 - encrypt/decrypt number: integer with negative scale)
   PROCEDURE test_encrypt_decrypt_number_7;
 
   --%test(case #8 - encrypt/decrypt number error: invalid precision)
   --%throws(-20006)
   PROCEDURE test_encrypt_decrypt_number_8;
 
   --%test(case #9 - encrypt/decrypt number error: invalid precision)
   --%throws(-20006)
   PROCEDURE test_encrypt_decrypt_number_9;
 
   --%test(case #10 - encrypt/decrypt number error: invalid scale)
   --%throws(-20007)
   PROCEDURE test_encrypt_decrypt_number_10;
 
   --%test(case #11 - encrypt/decrypt number error: invalid scale)
   --%throws(-20007)
   PROCEDURE test_encrypt_decrypt_number_11;
 
   --%test(case #12 - encrypt/decrypt number error: invalid number (precision))
   --%throws(-20008)
   PROCEDURE test_encrypt_decrypt_number_12;
 
   --%test(case #13 - encrypt/decrypt number error: invalid number (precision))
   --%throws(-20008)
   PROCEDURE test_encrypt_decrypt_number_13;
 
   --%test(case #14 - encrypt/decrypt number error: invalid number (scale))
   --%throws(-20009)
   PROCEDURE test_encrypt_decrypt_number_14;
 
   --%test(case #15 - encrypt/decrypt number error: invalid number (neg scale))
   --%throws(-20009)
   PROCEDURE test_encrypt_decrypt_number_15;
--#endif 0
 
   --%endcontext(encrypt_decrypt_number)
 
   --%context(encrypt_number)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_number_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_number_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt number: null value)
   PROCEDURE test_encrypt_number_1;
 
   --%test(case #2 - encrypt number: number+precision)
   PROCEDURE test_encrypt_number_2;
 
   --%test(case #3 - encrypt number: number+scale)
   --%throws(-20009)
   PROCEDURE test_encrypt_number_3;
 
   --%test(case #4 - encrypt number: number+scale)
   PROCEDURE test_encrypt_number_4;
 
   --%test(case #5 - encrypt number: number+scale)
   PROCEDURE test_encrypt_number_5;
 
   --%test(case #6 - encrypt number: number+precision+scale)
   --%throws(-20008)
   PROCEDURE test_encrypt_number_6;
 
   --%test(case #7 - encrypt number: number+precision+scale)
   PROCEDURE test_encrypt_number_7;
 
   --%test(case #8 - encrypt number: number+precision+scale)
   PROCEDURE test_encrypt_number_8;
 
   --%test(case #9 - encrypt number: number+precision+scale)
   --%throws(-20009)
   PROCEDURE test_encrypt_number_9;
 
   --%test(case #10 - encrypt number: number+precision+scale)
   PROCEDURE test_encrypt_number_10;
 
   --%test(case #11 - encrypt number: number+precision+scale)
   PROCEDURE test_encrypt_number_11;
 
   --%test(case #12 - encrypt number: integer)
   PROCEDURE test_encrypt_number_12;
 
   --%test(case #13 - encrypt number: integer+negative scale)
   PROCEDURE test_encrypt_number_13;
 
   --%test(case #14 - encrypt number: integer+negative scale)
   PROCEDURE test_encrypt_number_14;
 
   --%test(case #15 - encrypt number: integer+negative scale)
   --%throws(-20009)
   PROCEDURE test_encrypt_number_15;
 
   --%test(case #16 - encrypt number: integer+precision+negative scale)
   PROCEDURE test_encrypt_number_16;
 
   --%test(case #17 - encrypt number: integer+precision+negative scale)
   PROCEDURE test_encrypt_number_17;
 
   --%test(case #18 - encrypt number: integer+precision+negative scale)
   --%throws(-20009)
   PROCEDURE test_encrypt_number_18;
 
   --%test(case #19 - encrypt number: integer+precision+negative scale)
   PROCEDURE test_encrypt_number_19;
 
   --%test(case #20 - encrypt number: integer+precision+negative scale)
   --%throws(-20008)
   PROCEDURE test_encrypt_number_20;
--#endif 0
 
   --%endcontext(encrypt_number)
 
   --%context(encrypt_decrypt_integer)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_decrypt_integer_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_decrypt_integer_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt/decrypt integer: value not int)
   --%throws(-20018)
   PROCEDURE test_encrypt_decrypt_integer_1;
 
   --%test(case #2 - encrypt/decrypt integer: missing upper limit)
   --%throws(-20019)
   PROCEDURE test_encrypt_decrypt_integer_2;
 
   --%test(case #3 - encrypt/decrypt integer: missing lower limit)
   --%throws(-20020)
   PROCEDURE test_encrypt_decrypt_integer_3;
 
   --%test(case #4 - encrypt/decrypt integer: upper limit not int)
   --%throws(-20021)
   PROCEDURE test_encrypt_decrypt_integer_4;
 
   --%test(case #5 - encrypt/decrypt integer: lower limit not int)
   --%throws(-20022)
   PROCEDURE test_encrypt_decrypt_integer_5;
 
   --%test(case #6 - encrypt/decrypt integer: invalid range)
   --%throws(-20023)
   PROCEDURE test_encrypt_decrypt_integer_6;
 
   --%test(case #7 - encrypt/decrypt integer: value not in range)
   --%throws(-20024)
   PROCEDURE test_encrypt_decrypt_integer_7;
 
   --%test(case #8 - encrypt/decrypt integer: null value)
   PROCEDURE test_encrypt_decrypt_integer_8;
 
   --%test(case #9 - encrypt/decrypt integer: positive range)
   PROCEDURE test_encrypt_decrypt_integer_9;
 
   --%test(case #10 - encrypt/decrypt integer: neg/pos range)
   PROCEDURE test_encrypt_decrypt_integer_10;
 
   --%test(case #11 - encrypt/decrypt integer: neg/pos range)
   PROCEDURE test_encrypt_decrypt_integer_11;
 
   --%test(case #12 - encrypt/decrypt integer: negative range)
   PROCEDURE test_encrypt_decrypt_integer_12;
--#endif 0
 
   --%endcontext(encrypt_decrypt_integer)
 
   --%context(encrypt_integer)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_integer_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_integer_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt integer: null value)
   PROCEDURE test_encrypt_integer_1;
 
   --%test(case #2 - encrypt integer: pos range)
   PROCEDURE test_encrypt_integer_2;
 
   --%test(case #3 - encrypt integer: neg range)
   PROCEDURE test_encrypt_integer_3;
 
   --%test(case #4 - encrypt integer: mix range pos val)
   PROCEDURE test_encrypt_integer_4;
 
   --%test(case #5 - encrypt integer: mix range neg val)
   PROCEDURE test_encrypt_integer_5;
--#endif 0
 
   --%endcontext(encrypt_integer)
 
   --%context(encrypt_decrypt_date)
--@#include PACKAGE BODY ds_crypto_rsr_tst encrypt_decrypt_date_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_encrypt_decrypt_date_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - encrypt/decrypt date: null value)
   PROCEDURE test_encrypt_decrypt_date_1;
 
   --%test(case #2 - encrypt/decrypt date: value)
   PROCEDURE test_encrypt_decrypt_date_2;
 
   --%test(case #3 - encrypt/decrypt date: value+key)
   PROCEDURE test_encrypt_decrypt_date_3;
 
   --%test(case #4 - encrypt/decrypt date: value+min)
   PROCEDURE test_encrypt_decrypt_date_4;
 
   --%test(case #5 - encrypt/decrypt date: value+min)
   --%throws(-20013)
   PROCEDURE test_encrypt_decrypt_date_5;
 
   --%test(case #6 - encrypt/decrypt date: value+max)
   PROCEDURE test_encrypt_decrypt_date_6;
 
   --%test(case #7 - encrypt/decrypt date: value+max)
   --%throws(-20013)
   PROCEDURE test_encrypt_decrypt_date_7;
 
   --%test(case #8 - encrypt/decrypt date: value+min+max)
   PROCEDURE test_encrypt_decrypt_date_8;
 
   --%test(case #9 - encrypt/decrypt date: value+min+max)
   PROCEDURE test_encrypt_decrypt_date_9;
 
   --%test(case #10 - encrypt/decrypt date: value+min+max)
   --%throws(-20017)
   PROCEDURE test_encrypt_decrypt_date_10;
--#endif 0
 
   --%endcontext(encrypt_decrypt_date)
 
--@*/--#delete
 
END ds_crypto_rsr_tst;
/