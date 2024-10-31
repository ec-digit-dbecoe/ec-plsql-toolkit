set scan off
CREATE OR REPLACE PACKAGE BODY gen_utility_tst AS
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
/*
--@#begin eval-dataset
seq;name;expression;result;exception
1;op precedence;1+2*3;7;0
2;parenthesis;(1+2)*3;9;0
3;unary minus;-2*3;-6;0
4;bitwise complement;~1;-2;0
5;modulo;20%3;2;0
6;number equality;1==1;1;0
7;number difference;1!=1;0;0
8;bitwise and;255&3;3;0
9;logical or;1||0;1;0
10;logical and;1&&0;0;0
11;defined function;defined(SYMBOL);0;0
12;logical not;!defined(SYMBOL);1;0
13;capitalization;INITCAP("xyz");"Xyz";0
14;lowercase;LOWER("XYZ");"xyz";0
15;lowercase;STRLWR("XYZ");"xyz";0
16;uppercase;UPPER("xyz");"XYZ";0
17;uppercase;STRUPR("xyz");"XYZ";0
18;string length;LENGTH("xyz");3;0
19;string length;STRLEN("xyz");3;0
20;number to string;TO_CHAR(3);"3";0
21;string to number;TO_NUMBER("3");3;0
22;string like;"XYZ" LIKE "X%";1;0
23;logical not;NOT 1;0;0
24;logical or;1 OR 0;1;0
25;logical and;1 AND 0;0;0
26;logical xor;1 XOR 1;0;0
27;number equality;1=1;1;0
28;string equality;"x"="x";1;0
29;number equality (false);1=0;0;0
30;string equality (false);"x"="y";0;0
31;null string equality;"x"="";0;0
32;null string equality;""="";1;0
33;unbalance quote;";0;-20000
34;unbalanced parenthesis;(;0;-20000
35;unbalanced parenthesis;);0;-20000
36;missing operand;+;0;-20000
37;missing operand;*;0;-20000
38;missing operand;<;0;-20000
39;missing operand;&;0;-20000
40;missing operand;|;0;-20000
41;less then;2<2;0;0
42;less then or equal to;2<=2;1;0
43;greater then;2>2;0;0
44;greater then or equal;2>=2;1;0
45;minus;2-1;1;0
46;concatenation;"x"+"y";"xy";0
47;division;4/2;2;0
48;logical xor;2^2;0;0
49;conversion error;TO_NUMBER("a");;-20000
50;string inequality true;"x"<>"y";1;0
51;string inequality false;"x"<>"x";0;0
52;bitor;1|2;3;0
53;bitxor;1^3;2;0
54;bitand;1&3;1;0
--@#end eval-dataset
*/
--@/*--#delete
--@#begin eval-for-loop
--@#for tst IN (SELECT * FROM TABLE(readcsv(q'{SELECT * FROM TABLE(gen_utility.get_custom_code('PACKAGE BODY','gen_utility_tst','eval-dataset'))}')))
--@#end eval-for-loop
--@
--@   -- Test #tst.seq - tst.name: tst.expression vs tst.result
--@   PROCEDURE test_eval_tst.seq IS
--@   BEGIN
--@      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval tst.expression');
--@      ut.expect(gen_utility.t_lines_out(1)).to_equal('tst.result');
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - op precedence: 1+2*3 vs 7
   PROCEDURE test_eval_1 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1+2*3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('7');
   END;
 
   -- Test #2 - parenthesis: (1+2)*3 vs 9
   PROCEDURE test_eval_2 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval (1+2)*3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('9');
   END;
 
   -- Test #3 - unary minus: -2*3 vs -6
   PROCEDURE test_eval_3 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval -2*3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('-6');
   END;
 
   -- Test #4 - bitwise complement: ~1 vs -2
   PROCEDURE test_eval_4 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval ~1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('-2');
   END;
 
   -- Test #5 - modulo: 20%3 vs 2
   PROCEDURE test_eval_5 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 20%3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('2');
   END;
 
   -- Test #6 - number equality: 1==1 vs 1
   PROCEDURE test_eval_6 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1==1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #7 - number difference: 1!=1 vs 0
   PROCEDURE test_eval_7 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1!=1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #8 - bitwise and: 255&3 vs 3
   PROCEDURE test_eval_8 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 255&3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('3');
   END;
 
   -- Test #9 - logical or: 1||0 vs 1
   PROCEDURE test_eval_9 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1||0');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #10 - logical and: 1&&0 vs 0
   PROCEDURE test_eval_10 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1&&0');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #11 - defined function: defined(SYMBOL) vs 0
   PROCEDURE test_eval_11 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval defined(SYMBOL)');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #12 - logical not: !defined(SYMBOL) vs 1
   PROCEDURE test_eval_12 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval !defined(SYMBOL)');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #13 - capitalization: INITCAP("xyz") vs "Xyz"
   PROCEDURE test_eval_13 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval INITCAP("xyz")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"Xyz"');
   END;
 
   -- Test #14 - lowercase: LOWER("XYZ") vs "xyz"
   PROCEDURE test_eval_14 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval LOWER("XYZ")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"xyz"');
   END;
 
   -- Test #15 - lowercase: STRLWR("XYZ") vs "xyz"
   PROCEDURE test_eval_15 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval STRLWR("XYZ")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"xyz"');
   END;
 
   -- Test #16 - uppercase: UPPER("xyz") vs "XYZ"
   PROCEDURE test_eval_16 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval UPPER("xyz")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"XYZ"');
   END;
 
   -- Test #17 - uppercase: STRUPR("xyz") vs "XYZ"
   PROCEDURE test_eval_17 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval STRUPR("xyz")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"XYZ"');
   END;
 
   -- Test #18 - string length: LENGTH("xyz") vs 3
   PROCEDURE test_eval_18 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval LENGTH("xyz")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('3');
   END;
 
   -- Test #19 - string length: STRLEN("xyz") vs 3
   PROCEDURE test_eval_19 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval STRLEN("xyz")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('3');
   END;
 
   -- Test #20 - number to string: TO_CHAR(3) vs "3"
   PROCEDURE test_eval_20 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval TO_CHAR(3)');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"3"');
   END;
 
   -- Test #21 - string to number: TO_NUMBER("3") vs 3
   PROCEDURE test_eval_21 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval TO_NUMBER("3")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('3');
   END;
 
   -- Test #22 - string like: "XYZ" LIKE "X%" vs 1
   PROCEDURE test_eval_22 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "XYZ" LIKE "X%"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #23 - logical not: NOT 1 vs 0
   PROCEDURE test_eval_23 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval NOT 1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #24 - logical or: 1 OR 0 vs 1
   PROCEDURE test_eval_24 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1 OR 0');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #25 - logical and: 1 AND 0 vs 0
   PROCEDURE test_eval_25 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1 AND 0');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #26 - logical xor: 1 XOR 1 vs 0
   PROCEDURE test_eval_26 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1 XOR 1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #27 - number equality: 1=1 vs 1
   PROCEDURE test_eval_27 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1=1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #28 - string equality: "x"="x" vs 1
   PROCEDURE test_eval_28 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"="x"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #29 - number equality (false): 1=0 vs 0
   PROCEDURE test_eval_29 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1=0');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #30 - string equality (false): "x"="y" vs 0
   PROCEDURE test_eval_30 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"="y"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #31 - null string equality: "x"="" vs 0
   PROCEDURE test_eval_31 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"=""');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #32 - null string equality: ""="" vs 1
   PROCEDURE test_eval_32 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval ""=""');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #33 - unbalance quote: " vs 0
   PROCEDURE test_eval_33 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #34 - unbalanced parenthesis: ( vs 0
   PROCEDURE test_eval_34 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval (');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #35 - unbalanced parenthesis: ) vs 0
   PROCEDURE test_eval_35 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval )');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #36 - missing operand: + vs 0
   PROCEDURE test_eval_36 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval +');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #37 - missing operand: * vs 0
   PROCEDURE test_eval_37 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval *');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #38 - missing operand: < vs 0
   PROCEDURE test_eval_38 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval <');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #39 - missing operand: & vs 0
   PROCEDURE test_eval_39 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval &');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #40 - missing operand: | vs 0
   PROCEDURE test_eval_40 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval |');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #41 - less then: 2<2 vs 0
   PROCEDURE test_eval_41 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2<2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #42 - less then or equal to: 2<=2 vs 1
   PROCEDURE test_eval_42 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2<=2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #43 - greater then: 2>2 vs 0
   PROCEDURE test_eval_43 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2>2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #44 - greater then or equal: 2>=2 vs 1
   PROCEDURE test_eval_44 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2>=2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #45 - minus: 2-1 vs 1
   PROCEDURE test_eval_45 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2-1');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #46 - concatenation: "x"+"y" vs "xy"
   PROCEDURE test_eval_46 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"+"y"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('"xy"');
   END;
 
   -- Test #47 - division: 4/2 vs 2
   PROCEDURE test_eval_47 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 4/2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('2');
   END;
 
   -- Test #48 - logical xor: 2^2 vs 0
   PROCEDURE test_eval_48 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 2^2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #49 - conversion error: TO_NUMBER("a") vs 
   PROCEDURE test_eval_49 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval TO_NUMBER("a")');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('');
   END;
 
   -- Test #50 - string inequality true: "x"<>"y" vs 1
   PROCEDURE test_eval_50 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"<>"y"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
 
   -- Test #51 - string inequality false: "x"<>"x" vs 0
   PROCEDURE test_eval_51 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval "x"<>"x"');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('0');
   END;
 
   -- Test #52 - bitor: 1|2 vs 3
   PROCEDURE test_eval_52 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1|2');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('3');
   END;
 
   -- Test #53 - bitxor: 1^3 vs 2
   PROCEDURE test_eval_53 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1^3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('2');
   END;
 
   -- Test #54 - bitand: 1&3 vs 1
   PROCEDURE test_eval_54 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval 1&3');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('1');
   END;
--#endif 0
 
   FUNCTION array_to_string (
      pa_array IN OUT sys.dbms_sql.varchar2a
   )
   RETURN VARCHAR2
   IS
      l_str VARCHAR2(32767);
      l_idx PLS_INTEGER;
   BEGIN
      l_idx := pa_array.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         l_str := l_str || CASE WHEN l_str IS NOT NULL THEN '\n' END || pa_array(l_idx);
         l_idx := pa_array.NEXT(l_idx);
      END LOOP;
      RETURN l_str;
   END;
 
/*
--@#begin dir-dataset
seq;name;input;options;output;exception
1;#define;#define SYM 1\nSYM;;1;0
2;#undefine;#undefine SYM\nSYM;-dSYM=1;SYM;0
3;#ifdef;#ifdef SYM\ntrue\n#else\nfalse\n#endif;-dSYM;true;0
4;#else ;#ifdef SYM\nfalse\n#else\ntrue\n#endif;-uSYM;true;0
5;#elifdef;#ifndef SYM\nfalse\n#elifdef SYM\ntrue\n#else\nfalse\n#endif;-dSYM;true;0
6;#endif without #if;#endif;;;-20000
7;#for counter loop;#for $i = 1 to 3\n$i\n#next;;1\n2\n3;0
8;#for cursor loop;#for cur IN (SELECT 'x' "dummy" FROM dual UNION SELECT 'y' FROM dual)\ncur.dummy\n#next;;x\ny;0
9;#error;#error error message;;;-20000
10;#include;#include package body gen_utility_tst dummy-dataset;;abc\nxyz;0
11;#execute;#execute gen_utility.get_custom_code('PACKAGE BODY','GEN_UTILITY_TST','dummy-dataset');;abc\nxyz;0
12;macro1;#define is_ws(ch) (ch IN (' ',CHR(9)))\nis_ws(' ');-c;(' ' IN (' ',CHR(9)));0
13;macro2;#define switch(a,b) (z=a,a=b,b=z)\nswitch(x,y);-c;(z=x,x=y,y=z);0
14;symbol redefinition;#define SYM 2\nSYM;-dSYM=1;2;0
15;#pragma reversible;--#pragma reversible;;--@--#pragma reversible;0
16;#pragma noreversible;--#pragma noreversible;;;0
17;#pragma nomacro;#pragma noreversible\n#pragma nomacro\n#define fun(p) p+1\nfun(a);;fun(a);0
18;#if;#if 1\ntrue\n#end if;;true;0
19;#elif;#if 0\nfalse\n#elif 1\ntrue\n#end if;;true;0
20;#elifndef;#if 0\nfalse\n#elifndef SYM\ntrue\n#end if;;true;0
21;#delete;/*--#delete;;;0
--@#end dir-dataset
--@#begin tbd
token concatenation
space between macro name and definition
--@#end tbd
--@#begin dummy-dataset
abc
xyz
--@#end dummy-dataset
*/
--@/*--#delete
--@#begin dir-for-loop
--@#for tst IN (SELECT * FROM TABLE(readcsv(q'{SELECT * FROM TABLE(gen_utility.get_custom_code('PACKAGE BODY','gen_utility_tst','dir-dataset'))}')))
--@#end dir-for-loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_dir_tst.seq IS
--@   BEGIN
--@      gen_utility.generate(p_source=>NULL, p_options=>'-t -s tst.options', p_text=>REPLACE(q'{tst.input}','\n',CHR(10)));
--@      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{tst.output}');
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - #define
   PROCEDURE test_dir_1 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#define SYM 1\nSYM}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{1}');
   END;
 
   -- Test #2 - #undefine
   PROCEDURE test_dir_2 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -dSYM=1', p_text=>REPLACE(q'{#undefine SYM\nSYM}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{SYM}');
   END;
 
   -- Test #3 - #ifdef
   PROCEDURE test_dir_3 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -dSYM', p_text=>REPLACE(q'{#ifdef SYM\ntrue\n#else\nfalse\n#endif}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #4 - #else
   PROCEDURE test_dir_4 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -uSYM', p_text=>REPLACE(q'{#ifdef SYM\nfalse\n#else\ntrue\n#endif}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #5 - #elifdef
   PROCEDURE test_dir_5 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -dSYM', p_text=>REPLACE(q'{#ifndef SYM\nfalse\n#elifdef SYM\ntrue\n#else\nfalse\n#endif}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #6 - #endif without #if
   PROCEDURE test_dir_6 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#endif}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{}');
   END;
 
   -- Test #7 - #for counter loop
   PROCEDURE test_dir_7 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#for $i = 1 to 3\n$i\n#next}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{1\n2\n3}');
   END;
 
   -- Test #8 - #for cursor loop
   PROCEDURE test_dir_8 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#for cur IN (SELECT 'x' "dummy" FROM dual UNION SELECT 'y' FROM dual)\ncur.dummy\n#next}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{x\ny}');
   END;
 
   -- Test #9 - #error
   PROCEDURE test_dir_9 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#error error message}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{}');
   END;
 
   -- Test #10 - #include
   PROCEDURE test_dir_10 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#include package body gen_utility_tst dummy-dataset}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{abc\nxyz}');
   END;
 
   -- Test #11 - #execute
   PROCEDURE test_dir_11 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#execute gen_utility.get_custom_code('PACKAGE BODY','GEN_UTILITY_TST','dummy-dataset')}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{abc\nxyz}');
   END;
 
   -- Test #12 - macro1
   PROCEDURE test_dir_12 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -c', p_text=>REPLACE(q'{#define is_ws(ch) (ch IN (' ',CHR(9)))\nis_ws(' ')}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{(' ' IN (' ',CHR(9)))}');
   END;
 
   -- Test #13 - macro2
   PROCEDURE test_dir_13 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -c', p_text=>REPLACE(q'{#define switch(a,b) (z=a,a=b,b=z)\nswitch(x,y)}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{(z=x,x=y,y=z)}');
   END;
 
   -- Test #14 - symbol redefinition
   PROCEDURE test_dir_14 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s -dSYM=1', p_text=>REPLACE(q'{#define SYM 2\nSYM}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{2}');
   END;
 
   -- Test #15 - #pragma reversible
   PROCEDURE test_dir_15 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{--#pragma reversible}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{--@--#pragma reversible}');
   END;
 
   -- Test #16 - #pragma noreversible
   PROCEDURE test_dir_16 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{--#pragma noreversible}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{}');
   END;
 
   -- Test #17 - #pragma nomacro
   PROCEDURE test_dir_17 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#pragma noreversible\n#pragma nomacro\n#define fun(p) p+1\nfun(a)}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{fun(a)}');
   END;
 
   -- Test #18 - #if
   PROCEDURE test_dir_18 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#if 1\ntrue\n#end if}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #19 - #elif
   PROCEDURE test_dir_19 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#if 0\nfalse\n#elif 1\ntrue\n#end if}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #20 - #elifndef
   PROCEDURE test_dir_20 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{#if 0\nfalse\n#elifndef SYM\ntrue\n#end if}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{true}');
   END;
 
   -- Test #21 - #delete
   PROCEDURE test_dir_21 IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s ', p_text=>REPLACE(q'{/*--#delete}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{}');
   END;
--#endif 0
 
--@*/--#delete
END;
/
