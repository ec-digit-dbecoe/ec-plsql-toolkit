create or replace PACKAGE ds_masker_tst AS
--To generate this package, execute: gen_utility.generate('package body ds_masker_tst', '-f');
--@--#pragma reversible
--@--#nomacro
--@/*--#delete
   --%suite(maskerization)
   --%context(mask_string)
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''mask_string-dataset''))')))
--@   --%test(case #tst.seq - tst.name)
--@   PROCEDURE test_mask_string_tst.seq;
--@#endfor tst
--#if 0
   --%test(case #1 - empty string)
   PROCEDURE test_mask_string_1;
   --%test(case #2 - empty pattern)
   PROCEDURE test_mask_string_2;
   --%test(case #3 - no matching)
   PROCEDURE test_mask_string_3;
   --%test(case #4 - bank account #)
   PROCEDURE test_mask_string_4;
   --%test(case #5 - bank account X)
   PROCEDURE test_mask_string_5;
   --%test(case #6 - iban #)
   PROCEDURE test_mask_string_6;
   --%test(case #7 - ip address #)
   PROCEDURE test_mask_string_7;
   --%test(case #8 - mac address 1 #)
   PROCEDURE test_mask_string_8;
   --%test(case #9 - lower case#)
   PROCEDURE test_mask_string_9;
--#endif 0
   --%endcontext
   --%context(substitute_string)
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''substitute_string-dataset''))')))
--@   --%test(case #tst.seq - tst.name)
--@   PROCEDURE test_substitute_string_tst.seq;
--@#endfor tst
--#if 0
   --%test(case #1 - empty string)
   PROCEDURE test_substitute_string_1;
   --%test(case #2 - name 1 vowel)
   PROCEDURE test_substitute_string_2;
   --%test(case #3 - name 2 no vowel)
   PROCEDURE test_substitute_string_3;
   --%test(case #4 - bank account 1)
   PROCEDURE test_substitute_string_4;
   --%test(case #5 - iban)
   PROCEDURE test_substitute_string_5;
--#endif 0
   --%endcontext
   --%context(regexp_replace_string)
--@#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''ds_masker_tst'',''regexp_replace_string-dataset''))')))
--@   --%test(case #tst.seq - tst.name)
--@   PROCEDURE test_regexp_replace_string_tst.seq;
--@#endfor tst
--#if 0
   --%test(case #1 - empty string)
   PROCEDURE test_regexp_replace_string_1;
   --%test(case #2 - bank account)
   PROCEDURE test_regexp_replace_string_2;
--#endif 0
   --%endcontext
--@*/--#delete
END ds_masker_tst;
/