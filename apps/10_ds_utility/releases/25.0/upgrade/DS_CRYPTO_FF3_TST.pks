CREATE OR REPLACE PACKAGE ds_crypto_ff3_tst
AUTHID CURRENT_USER
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
--    exec gen_utility.generate('PACKAGE ds_crypto_ff3_tst', '-f');
--    exec gen_utility.generate('PACKAGE BODY ds_crypto_ff3_tst', '-f');
--
--@--#pragma reversible
--@/*--#delete
 
   --%suite(Encryption library)
 
   --%context(encrypt_string)
--@#include PACKAGE BODY ds_crypto_ff3_tst ff3_encrypt_string_for_loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_ff3_encrypt_string_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 -  1)
   PROCEDURE test_ff3_encrypt_string_1;
 
   --%test(case #2 -  2)
   PROCEDURE test_ff3_encrypt_string_2;
 
   --%test(case #3 -  3)
   PROCEDURE test_ff3_encrypt_string_3;
 
   --%test(case #4 -  4)
   PROCEDURE test_ff3_encrypt_string_4;
 
   --%test(case #5 -  5)
   PROCEDURE test_ff3_encrypt_string_5;
 
   --%test(case #6 -  6)
   PROCEDURE test_ff3_encrypt_string_6;
 
   --%test(case #7 -  7)
   PROCEDURE test_ff3_encrypt_string_7;
 
   --%test(case #8 -  8)
   PROCEDURE test_ff3_encrypt_string_8;
 
   --%test(case #9 -  9)
   PROCEDURE test_ff3_encrypt_string_9;
 
   --%test(case #10 - 10)
   PROCEDURE test_ff3_encrypt_string_10;
 
   --%test(case #11 - 11)
   PROCEDURE test_ff3_encrypt_string_11;
 
   --%test(case #12 - 12)
   PROCEDURE test_ff3_encrypt_string_12;
 
   --%test(case #13 - 13)
   PROCEDURE test_ff3_encrypt_string_13;
 
   --%test(case #14 - 14)
   PROCEDURE test_ff3_encrypt_string_14;
 
   --%test(case #15 - 15)
   PROCEDURE test_ff3_encrypt_string_15;
 
   --%test(case #16 - 16)
   PROCEDURE test_ff3_encrypt_string_16;
 
   --%test(case #17 - 17)
   PROCEDURE test_ff3_encrypt_string_17;
 
   --%test(case #18 - 18)
   PROCEDURE test_ff3_encrypt_string_18;
 
   --%test(case #19 - 19)
   PROCEDURE test_ff3_encrypt_string_19;
 
   --%test(case #20 - 20)
   PROCEDURE test_ff3_encrypt_string_20;
 
   --%test(case #21 - 21)
   PROCEDURE test_ff3_encrypt_string_21;
--#endif 0
 
   --%endcontext(encrypt_decrypt_string)
 
--@*/--#delete
 
END ds_crypto_ff3_tst;
/