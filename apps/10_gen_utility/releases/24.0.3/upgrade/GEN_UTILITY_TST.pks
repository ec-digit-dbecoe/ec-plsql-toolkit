set scan off
CREATE OR REPLACE PACKAGE gen_utility_tst
AUTHID DEFINER
AS
---
-- Copyright (C) 2023 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
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
--
-- To generate this package spec and body, execute the following twice:
-- . exec gen_utility.generate('package gen_utility_tst', '-f');
-- . exec gen_utility.generate('package body gen_utility_tst', '-f');
-- First execution removes generated code
-- Second execution generates code again
--
--@--#pragma reversible
--@/*--#delete
 
   --%suite(PL/SQL code generator)
 
   --%context(evaluation of expressions)
 
--@#include PACKAGE BODY gen_utility_tst eval-for-loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name: tst.expression vs tst.result)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name: tst.expression vs tst.result)
--@#endif
--@   PROCEDURE test_eval_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - op precedence: 1+2*3 vs 7)
   PROCEDURE test_eval_1;
 
   --%test(case #2 - parenthesis: (1+2)*3 vs 9)
   PROCEDURE test_eval_2;
 
   --%test(case #3 - unary minus: -2*3 vs -6)
   PROCEDURE test_eval_3;
 
   --%test(case #4 - bitwise complement: ~1 vs -2)
   PROCEDURE test_eval_4;
 
   --%test(case #5 - modulo: 20%3 vs 2)
   PROCEDURE test_eval_5;
 
   --%test(case #6 - number equality: 1==1 vs 1)
   PROCEDURE test_eval_6;
 
   --%test(case #7 - number difference: 1!=1 vs 0)
   PROCEDURE test_eval_7;
 
   --%test(case #8 - bitwise and: 255&3 vs 3)
   PROCEDURE test_eval_8;
 
   --%test(case #9 - logical or: 1||0 vs 1)
   PROCEDURE test_eval_9;
 
   --%test(case #10 - logical and: 1&&0 vs 0)
   PROCEDURE test_eval_10;
 
   --%test(case #11 - defined function: defined(SYMBOL) vs 0)
   PROCEDURE test_eval_11;
 
   --%test(case #12 - logical not: !defined(SYMBOL) vs 1)
   PROCEDURE test_eval_12;
 
   --%test(case #13 - capitalization: INITCAP("xyz") vs "Xyz")
   PROCEDURE test_eval_13;
 
   --%test(case #14 - lowercase: LOWER("XYZ") vs "xyz")
   PROCEDURE test_eval_14;
 
   --%test(case #15 - lowercase: STRLWR("XYZ") vs "xyz")
   PROCEDURE test_eval_15;
 
   --%test(case #16 - uppercase: UPPER("xyz") vs "XYZ")
   PROCEDURE test_eval_16;
 
   --%test(case #17 - uppercase: STRUPR("xyz") vs "XYZ")
   PROCEDURE test_eval_17;
 
   --%test(case #18 - string length: LENGTH("xyz") vs 3)
   PROCEDURE test_eval_18;
 
   --%test(case #19 - string length: STRLEN("xyz") vs 3)
   PROCEDURE test_eval_19;
 
   --%test(case #20 - number to string: TO_CHAR(3) vs "3")
   PROCEDURE test_eval_20;
 
   --%test(case #21 - string to number: TO_NUMBER("3") vs 3)
   PROCEDURE test_eval_21;
 
   --%test(case #22 - string like: "XYZ" LIKE "X%" vs 1)
   PROCEDURE test_eval_22;
 
   --%test(case #23 - logical not: NOT 1 vs 0)
   PROCEDURE test_eval_23;
 
   --%test(case #24 - logical or: 1 OR 0 vs 1)
   PROCEDURE test_eval_24;
 
   --%test(case #25 - logical and: 1 AND 0 vs 0)
   PROCEDURE test_eval_25;
 
   --%test(case #26 - logical xor: 1 XOR 1 vs 0)
   PROCEDURE test_eval_26;
 
   --%test(case #27 - number equality: 1=1 vs 1)
   PROCEDURE test_eval_27;
 
   --%test(case #28 - string equality: "x"="x" vs 1)
   PROCEDURE test_eval_28;
 
   --%test(case #29 - number equality (false): 1=0 vs 0)
   PROCEDURE test_eval_29;
 
   --%test(case #30 - string equality (false): "x"="y" vs 0)
   PROCEDURE test_eval_30;
 
   --%test(case #31 - null string equality: "x"="" vs 0)
   PROCEDURE test_eval_31;
 
   --%test(case #32 - null string equality: ""="" vs 1)
   PROCEDURE test_eval_32;
 
   --%test(case #33 - unbalance quote: " vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_33;
 
   --%test(case #34 - unbalanced parenthesis: ( vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_34;
 
   --%test(case #35 - unbalanced parenthesis: ) vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_35;
 
   --%test(case #36 - missing operand: + vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_36;
 
   --%test(case #37 - missing operand: * vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_37;
 
   --%test(case #38 - missing operand: < vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_38;
 
   --%test(case #39 - missing operand: & vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_39;
 
   --%test(case #40 - missing operand: | vs 0)
   --%throws(-20000)
   PROCEDURE test_eval_40;
 
   --%test(case #41 - less then: 2<2 vs 0)
   PROCEDURE test_eval_41;
 
   --%test(case #42 - less then or equal to: 2<=2 vs 1)
   PROCEDURE test_eval_42;
 
   --%test(case #43 - greater then: 2>2 vs 0)
   PROCEDURE test_eval_43;
 
   --%test(case #44 - greater then or equal: 2>=2 vs 1)
   PROCEDURE test_eval_44;
 
   --%test(case #45 - minus: 2-1 vs 1)
   PROCEDURE test_eval_45;
 
   --%test(case #46 - concatenation: "x"+"y" vs "xy")
   PROCEDURE test_eval_46;
 
   --%test(case #47 - division: 4/2 vs 2)
   PROCEDURE test_eval_47;
 
   --%test(case #48 - logical xor: 2^2 vs 0)
   PROCEDURE test_eval_48;
 
   --%test(case #49 - conversion error: TO_NUMBER("a") vs )
   --%throws(-20000)
   PROCEDURE test_eval_49;
 
   --%test(case #50 - string inequality true: "x"<>"y" vs 1)
   PROCEDURE test_eval_50;
 
   --%test(case #51 - string inequality false: "x"<>"x" vs 0)
   PROCEDURE test_eval_51;
 
   --%test(case #52 - bitor: 1|2 vs 3)
   PROCEDURE test_eval_52;
 
   --%test(case #53 - bitxor: 1^3 vs 2)
   PROCEDURE test_eval_53;
 
   --%test(case #54 - bitand: 1&3 vs 1)
   PROCEDURE test_eval_54;
--#endif 0
 
   --%endcontext
 
   --%context(generator directives)
 
--@#include PACKAGE BODY gen_utility_tst dir-for-loop
--@
--@#if "tst.exception" != "0"
--@   --%test(case #tst.seq - tst.name)
--@   --%throws(tst.exception)
--@#else
--@   --%test(case #tst.seq - tst.name)
--@#endif
--@   PROCEDURE test_dir_tst.seq;
--@#endfor
--#if 0
 
   --%test(case #1 - #define)
   PROCEDURE test_dir_1;
 
   --%test(case #2 - #undefine)
   PROCEDURE test_dir_2;
 
   --%test(case #3 - #ifdef)
   PROCEDURE test_dir_3;
 
   --%test(case #4 - #else)
   PROCEDURE test_dir_4;
 
   --%test(case #5 - #elifdef)
   PROCEDURE test_dir_5;
 
   --%test(case #6 - #endif without #if)
   --%throws(-20000)
   PROCEDURE test_dir_6;
 
   --%test(case #7 - #for counter loop)
   PROCEDURE test_dir_7;
 
   --%test(case #8 - #for cursor loop)
   PROCEDURE test_dir_8;
 
   --%test(case #9 - #error)
   --%throws(-20000)
   PROCEDURE test_dir_9;
 
   --%test(case #10 - #include)
   PROCEDURE test_dir_10;
 
   --%test(case #11 - #execute)
   PROCEDURE test_dir_11;
 
   --%test(case #12 - macro1)
   PROCEDURE test_dir_12;
 
   --%test(case #13 - macro2)
   PROCEDURE test_dir_13;
 
   --%test(case #14 - symbol redefinition)
   PROCEDURE test_dir_14;
 
   --%test(case #15 - #pragma reversible)
   PROCEDURE test_dir_15;
 
   --%test(case #16 - #pragma noreversible)
   PROCEDURE test_dir_16;
 
   --%test(case #17 - #pragma nomacro)
   PROCEDURE test_dir_17;
 
   --%test(case #18 - #if)
   PROCEDURE test_dir_18;
 
   --%test(case #19 - #elif)
   PROCEDURE test_dir_19;
 
   --%test(case #20 - #elifndef)
   PROCEDURE test_dir_20;
 
   --%test(case #21 - #delete)
   PROCEDURE test_dir_21;
--#endif 0
 
   --%endcontext
 
--@*/--#delete
 
END;
/