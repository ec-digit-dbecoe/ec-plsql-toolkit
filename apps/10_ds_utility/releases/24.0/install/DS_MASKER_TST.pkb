create or replace PACKAGE BODY ds_masker_tst AS
--To generate this package body, execute: : gen_utility.generate('package body ds_anonym_tst', '-f');
--@--#pragma reversible
--@--#nomacro
/*
--@#begin mask_string-dataset
seq;name;p_string;p_mask_pattern;p_mask_char;res
1;empty string;'';'999-#####99-99';'';''
2;empty pattern;'001-2715803-73';'';'';'##############'
3;no matching;'001-2715803-73';'XXX';'';'##############'
4;bank account #;'001-2715803-73';'999-#####99-99';'';'001-#####03-73'
5;bank account X;'001-2715803-73';'999-XXXXX99-99';'X';'001-XXXXX03-73'
6;iban #;'BE38 0012 7158 0373';'AAXX XXXX XXXX 9999';'X';'BEXX XXXX XXXX 0373'
7;ip address #;'192.168.001.001';'XXX.XXX.999.999';'X';'XXX.XXX.001.001'
8;mac address 1 #;'80-3F-5D-02-E9-91';'XX-XX-XX-??-??-??';'X';'XX-XX-XX-02-E9-91'
9;lower case#;'abcdefghi';'aaaXXXaaa';'X';'abcXXXghi'
--@#end mask_string-dataset
*/
/*
--@#begin substitute_string-dataset
seq;name;p_string;p_vowel;p_deterministic;res
1;empty string;'';'';'';''
2;name 1 vowel;'Philippe DEBOIS';'N';'Y';'Pepygpvg SPHLWM'
3;name 2 no vowel;'Philippe DEBOIS';'Y';'Y';'Ndowente QOGIUL'
4;bank account 1;'001-2715803-73';'N';'Y';'438-8265253-47'
5;iban;'BE38 0012 7158 0373';'N';'Y';'ZY54 6613 7122 0162'
--@#end substitute_string-dataset
*/
/*
--@#begin regexp_replace_string-dataset
seq;name;p_string;p_pattern;p_replace;p_mask_char;res
1;empty string;'';'';'';'';''
2;bank account;'001-2715803-73';'(\d+)-(\d+)-(\d+)';'\1-*******-\3';'*';'001-*******-73'
--@#end regexp_replace_string-dataset
*/
--@/*--#delete
--@#begin mask_string-for-loop
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''mask_string-dataset''))')))
--@#end mask_string-for-loop
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_mask_string_tst.seq IS
--@   BEGIN
--@     ut.expect(ds_masker_krn.mask_string(p_string=>tst.p_string, p_mask_pattern=>tst.p_mask_pattern, p_mask_char=>tst.p_mask_char)).to_equal(tst.res);
--@   END;
--@#endfor
--#if 0
   -- Test #1 - empty string
   PROCEDURE test_mask_string_1 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'', p_mask_pattern=>'999-#####99-99', p_mask_char=>'')).to_equal('');
   END;
   -- Test #2 - empty pattern
   PROCEDURE test_mask_string_2 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'', p_mask_char=>'')).to_equal('##############');
   END;
   -- Test #3 - no matching
   PROCEDURE test_mask_string_3 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'XXX', p_mask_char=>'')).to_equal('##############');
   END;
   -- Test #4 - bank account #
   PROCEDURE test_mask_string_4 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'999-#####99-99', p_mask_char=>'')).to_equal('001-#####03-73');
   END;
   -- Test #5 - bank account X
   PROCEDURE test_mask_string_5 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'999-XXXXX99-99', p_mask_char=>'X')).to_equal('001-XXXXX03-73');
   END;
   -- Test #6 - iban #
   PROCEDURE test_mask_string_6 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'BE38 0012 7158 0373', p_mask_pattern=>'AAXX XXXX XXXX 9999', p_mask_char=>'X')).to_equal('BEXX XXXX XXXX 0373');
   END;
   -- Test #7 - ip address #
   PROCEDURE test_mask_string_7 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'192.168.001.001', p_mask_pattern=>'XXX.XXX.999.999', p_mask_char=>'X')).to_equal('XXX.XXX.001.001');
   END;
   -- Test #8 - mac address 1 #
   PROCEDURE test_mask_string_8 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'80-3F-5D-02-E9-91', p_mask_pattern=>'XX-XX-XX-??-??-??', p_mask_char=>'X')).to_equal('XX-XX-XX-02-E9-91');
   END;
   -- Test #9 - lower case#
   PROCEDURE test_mask_string_9 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'abcdefghi', p_mask_pattern=>'aaaXXXaaa', p_mask_char=>'X')).to_equal('abcXXXghi');
   END;
--#endif 0
--@#begin substitute_string-for-loop
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''substitute_string-dataset''))')))
--@#end substitute_string-for-loop
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_substitute_string_tst.seq IS
--@   BEGIN
--@     ut.expect(ds_masker_krn.substitute_string(p_string=>tst.p_string, p_vowel=>tst.p_vowel, p_deterministic=>tst.p_deterministic)).to_equal(tst.res);
--@   END;
--@#endfor
--#if 0
   -- Test #1 - empty string
   PROCEDURE test_substitute_string_1 IS
   BEGIN
     ut.expect(ds_masker_krn.substitute_string(p_string=>'', p_vowel=>'', p_deterministic=>'')).to_equal('');
   END;
   -- Test #2 - name 1 vowel
   PROCEDURE test_substitute_string_2 IS
   BEGIN
     ut.expect(ds_masker_krn.substitute_string(p_string=>'Philippe DEBOIS', p_vowel=>'N', p_deterministic=>'Y')).to_equal('Pepygpvg SPHLWM');
   END;
   -- Test #3 - name 2 no vowel
   PROCEDURE test_substitute_string_3 IS
   BEGIN
     ut.expect(ds_masker_krn.substitute_string(p_string=>'Philippe DEBOIS', p_vowel=>'Y', p_deterministic=>'Y')).to_equal('Ndowente QOGIUL');
   END;
   -- Test #4 - bank account 1
   PROCEDURE test_substitute_string_4 IS
   BEGIN
     ut.expect(ds_masker_krn.substitute_string(p_string=>'001-2715803-73', p_vowel=>'N', p_deterministic=>'Y')).to_equal('438-8265253-47');
   END;
   -- Test #5 - iban
   PROCEDURE test_substitute_string_5 IS
   BEGIN
     ut.expect(ds_masker_krn.substitute_string(p_string=>'BE38 0012 7158 0373', p_vowel=>'N', p_deterministic=>'Y')).to_equal('ZY54 6613 7122 0162');
   END;
--#endif 0
--@#begin regexp_replace_string-for-loop
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''regexp_replace_string-dataset''))')))
--@#end regexp_replace_string-for-loop
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_regexp_replace_string_tst.seq IS
--@   BEGIN
--@     ut.expect(ds_masker_krn.regexp_replace_string(p_string=>tst.p_string, p_pattern=>tst.p_pattern, p_replace=>tst.p_replace, p_mask_char=>tst.p_mask_char)).to_equal(tst.res);
--@   END;
--@#endfor
--#if 0
   -- Test #1 - empty string
   PROCEDURE test_regexp_replace_string_1 IS
   BEGIN
     ut.expect(ds_masker_krn.regexp_replace_string(p_string=>'', p_pattern=>'', p_replace=>'', p_mask_char=>'')).to_equal('');
   END;
   -- Test #2 - bank account
   PROCEDURE test_regexp_replace_string_2 IS
   BEGIN
     ut.expect(ds_masker_krn.regexp_replace_string(p_string=>'001-2715803-73', p_pattern=>'(\d+)-(\d+)-(\d+)', p_replace=>'\1-*******-\3', p_mask_char=>'*')).to_equal('001-*******-73');
   END;
--#endif 0
--@*/--#delete
END ds_masker_tst;
/