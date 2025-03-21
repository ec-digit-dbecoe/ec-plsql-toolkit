CREATE OR REPLACE PACKAGE BODY ds_masker_tst AS
-- To generate this package spec and body, execute the following twice:
-- . exec gen_utility.generate('package ds_masker_tst', '-f');
-- . exec gen_utility.generate('package body ds_masker_tst', '-f');
-- First execution removes generated code
-- Second execution generates code again
--@--#pragma reversible
--@--#nomacro
/*
--@#begin mask_string-dataset
name;string;mask_pattern;mask_char;res
empty string;'';'999-#####99-99';'';''
empty pattern;'001-2715803-73';'';'';'XXXXXXXXXXXXXX'
no matching;'001-2715803-73';'XXX';'';'XXXXXXXXXXXXXX'
bank account #;'001-2715803-73';'999-XXXXX99-99';'';'001-XXXXX03-73'
bank account X;'001-2715803-73';'999-#####99-99';'#';'001-#####03-73'
iban #;'BE38 0012 7158 0373';'AAXX XXXX XXXX 9999';'X';'BEXX XXXX XXXX 0373'
ip address #;'192.168.001.001';'XXX.XXX.999.999';'X';'XXX.XXX.001.001'
mac address 1 #;'80-3F-5D-02-E9-91';'XX-XX-XX-??-??-??';'X';'XX-XX-XX-02-E9-91'
lower case#;'abcdefghi';'aaaXXXaaa';'X';'abcXXXghi'
--@#end mask_string-dataset
*/
--@/*--#delete
--@#begin mask_string-for-loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''mask_string-dataset''))')) x)
--@#end mask_string-for-loop
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_mask_string_tst.seq IS
--@   BEGIN
--@     ut.expect(ds_masker_krn.mask_string(p_string=>tst.string, p_mask_pattern=>tst.mask_pattern, p_mask_char=>tst.mask_char)).to_equal(tst.res);
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
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'', p_mask_char=>'')).to_equal('XXXXXXXXXXXXXX');
   END;
   -- Test #3 - no matching
   PROCEDURE test_mask_string_3 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'XXX', p_mask_char=>'')).to_equal('XXXXXXXXXXXXXX');
   END;
   -- Test #4 - bank account #
   PROCEDURE test_mask_string_4 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'999-XXXXX99-99', p_mask_char=>'')).to_equal('001-XXXXX03-73');
   END;
   -- Test #5 - bank account X
   PROCEDURE test_mask_string_5 IS
   BEGIN
     ut.expect(ds_masker_krn.mask_string(p_string=>'001-2715803-73', p_mask_pattern=>'999-#####99-99', p_mask_char=>'#')).to_equal('001-#####03-73');
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
--@*/--#delete
/*
--@#begin obfuscate_string-dataset
name;string;vowel;seed;res
empty string;'';'';'';''
name 1 vowel;'Philippe DEBOIS';'N';'Y';'Ivjvasdk CPFMUO'
name 2 no vowel;'Philippe DEBOIS';'Y';'Y';'Htitarci BOFIUN'
bank account 1;'001-2715803-73';'N';'Y';'383-8071405-24'
iban;'BE38 0012 7158 0373';'N';'Y';'IV38 0714 0524 7589'
--@#end obfuscate_string-dataset
*/
--@/*--#delete
--@#begin obfuscate_string-for-loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''obfuscate_string-dataset''))')) x)
--@#end obfuscate_string-for-loop
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_obfuscate_string_tst.seq IS
--@   BEGIN
--@     ut.expect(ds_masker_krn.obfuscate_string(p_string=>tst.string, p_vowel=>tst.vowel, p_seed=>tst.seed)).to_equal(tst.res);
--@   END;
--@#endfor
--#if 0
   -- Test #1 - empty string
   PROCEDURE test_obfuscate_string_1 IS
   BEGIN
     ut.expect(ds_masker_krn.obfuscate_string(p_string=>'', p_vowel=>'', p_seed=>'')).to_equal('');
   END;
   -- Test #2 - name 1 vowel
   PROCEDURE test_obfuscate_string_2 IS
   BEGIN
     ut.expect(ds_masker_krn.obfuscate_string(p_string=>'Philippe DEBOIS', p_vowel=>'N', p_seed=>'Y')).to_equal('Ivjvasdk CPFMUO');
   END;
   -- Test #3 - name 2 no vowel
   PROCEDURE test_obfuscate_string_3 IS
   BEGIN
     ut.expect(ds_masker_krn.obfuscate_string(p_string=>'Philippe DEBOIS', p_vowel=>'Y', p_seed=>'Y')).to_equal('Htitarci BOFIUN');
   END;
   -- Test #4 - bank account 1
   PROCEDURE test_obfuscate_string_4 IS
   BEGIN
     ut.expect(ds_masker_krn.obfuscate_string(p_string=>'001-2715803-73', p_vowel=>'N', p_seed=>'Y')).to_equal('383-8071405-24');
   END;
   -- Test #5 - iban
   PROCEDURE test_obfuscate_string_5 IS
   BEGIN
     ut.expect(ds_masker_krn.obfuscate_string(p_string=>'BE38 0012 7158 0373', p_vowel=>'N', p_seed=>'Y')).to_equal('IV38 0714 0524 7589');
   END;
--#endif 0
--@*/--#delete
END ds_masker_tst;
/