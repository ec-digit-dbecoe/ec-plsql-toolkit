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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
--
--#pragma reversible
/*
#begin eval-dataset
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
#end eval-dataset
*/
/*--#delete
#begin eval-for-loop
#for tst IN (SELECT * FROM TABLE(readcsv(q'{SELECT * FROM TABLE(gen_utility.get_custom_code('PACKAGE BODY','gen_utility_tst','eval-dataset'))}')))
#end eval-for-loop

   -- Test #tst.seq - tst.name: tst.expression vs tst.result 
   PROCEDURE test_eval_tst.seq IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s', p_text=>'#eval tst.expression');
      ut.expect(gen_utility.t_lines_out(1)).to_equal('tst.result');
   END;
#endfor

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
#begin dir-dataset
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
#end dir-dataset
#begin tbd
token concatenation
space between macro name and definition
#end tbd
#begin dummy-dataset
abc
xyz
#end dummy-dataset
*/
/*--#delete
#begin dir-for-loop
#for tst IN (SELECT * FROM TABLE(readcsv(q'{SELECT * FROM TABLE(gen_utility.get_custom_code('PACKAGE BODY','gen_utility_tst','dir-dataset'))}')))
#end dir-for-loop

   -- Test #tst.seq - tst.name 
   PROCEDURE test_dir_tst.seq IS
   BEGIN
      gen_utility.generate(p_source=>NULL, p_options=>'-t -s tst.options', p_text=>REPLACE(q'{tst.input}','\n',CHR(10)));
      ut.expect(array_to_string(gen_utility.t_lines_out)).to_equal(q'{tst.output}');
   END;
#endfor

*/--#delete
END;
/
