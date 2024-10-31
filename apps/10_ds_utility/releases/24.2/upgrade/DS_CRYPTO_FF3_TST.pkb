CREATE OR REPLACE PACKAGE BODY ds_crypto_ff3_tst AS
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
--  NIST Test Vectors for 128, 198, and 256 bit modes
--  https:
--
--@--#pragma reversible
 
/*
--@#begin encrypt_string_dataset
name;alphabet;key;tweak;plaintext;ciphertext;exception
 1;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A94';'D8E7920AFA330A73';'890121234567890000';'750918814058654607';0
 2;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A94';'9A768A92F60E12D8';'890121234567890000';'018989839189395384';0
 3;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A94';'D8E7920AFA330A73';'89012123456789000000789000000';'48598367162252569629397416226';0
 4;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A94';'0000000000000000';'89012123456789000000789000000';'34695224821734535122613701434';0
 5;'0123456789abcdefghijklmnop';'EF4359D8D580AA4F7F036D6F04FC6A94';'9A768A92F60E12D8';'0123456789abcdefghi';'g2pk40i992fn20cjakb';0
 6;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6';'D8E7920AFA330A73';'890121234567890000';'646965393875028755';0
 7;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6';'9A768A92F60E12D8';'890121234567890000';'961610514491424446';0
 8;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6';'D8E7920AFA330A73';'89012123456789000000789000000';'53048884065350204541786380807';0
 9;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6';'0000000000000000';'89012123456789000000789000000';'98083802678820389295041483512';0
10;'0123456789abcdefghijklmnop';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6';'9A768A92F60E12D8';'0123456789abcdefghi';'i0ihe2jfj7a9opf9p88';0
11;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C';'D8E7920AFA330A73';'890121234567890000';'922011205562777495';0
12;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C';'9A768A92F60E12D8';'890121234567890000';'504149865578056140';0
13;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C';'D8E7920AFA330A73';'89012123456789000000789000000';'04344343235792599165734622699';0
14;'0123456789';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C';'0000000000000000';'89012123456789000000789000000';'30859239999374053872365555822';0
15;'0123456789abcdefghijklmnop';'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C';'9A768A92F60E12D8';'0123456789abcdefghi';'p0b2godfja9bhb7bk38';0
16;'0123456789';'2DE79D232DF5585D68CE47882AE256D6';'CBD09280979564';'3992520240';'8901801106';0
17;'0123456789';'01C63017111438F7FC8E24EB16C71AB5';'C4E822DCD09F27';'60761757463116869318437658042297305934914824457484538562';'35637144092473838892796702739628394376915177448290847293';0
18;'abcdefghijklmnopqrstuvwxyz';'718385E6542534604419E83CE387A437';'B6F35084FA90E1';'wfmwlrorcd';'ywowehycyd';0
19;'abcdefghijklmnopqrstuvwxyz';'DB602DFF22ED7E84C8D8C865A941A238';'EBEFD63BCC2083';'kkuomenbzqvggfbteqdyanwpmhzdmoicekiihkrm';'belcfahcwwytwrckieymthabgjjfkxtxauipmjja';0
20;'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';'AEE87D0D485B3AFD12BD1E0B9D03D50D';'5F9140601D224B';'ixvuuIHr0e';'GR90R1q838';0
21;'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';'7B6C88324732F7F4AD435DA9AD77F917';'3F42102C0BAB39';'21q1kbbIVSrAFtdFWzdMeIDpRqpo';'cvQ/4aGUV4wRnyO3CHmgEKW5hk8H';0
--@#end encrypt_string_dataset
*/
--@/*--#delete
--@#begin ff3_encrypt_string_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_FF3_TST'',''encrypt_string_dataset''))')) x)
--@#end ff3_encrypt_string_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_ff3_encrypt_string_tst.seq IS
--@   BEGIN
--@      ut.expect(ds_crypto_krn.encrypt_string(p_value=>tst.plaintext,p_charset=>tst.alphabet,p_key=>tst.key,p_tweak=>tst.tweak,p_algo=>'FF3')).to_equal(tst.ciphertext);
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 -  1
   PROCEDURE test_ff3_encrypt_string_1 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A94',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('750918814058654607');
   END;
 
   -- Test #2 -  2
   PROCEDURE test_ff3_encrypt_string_2 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A94',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('018989839189395384');
   END;
 
   -- Test #3 -  3
   PROCEDURE test_ff3_encrypt_string_3 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A94',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('48598367162252569629397416226');
   END;
 
   -- Test #4 -  4
   PROCEDURE test_ff3_encrypt_string_4 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A94',p_tweak=>'0000000000000000',p_algo=>'FF3')).to_equal('34695224821734535122613701434');
   END;
 
   -- Test #5 -  5
   PROCEDURE test_ff3_encrypt_string_5 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'0123456789abcdefghi',p_charset=>'0123456789abcdefghijklmnop',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A94',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('g2pk40i992fn20cjakb');
   END;
 
   -- Test #6 -  6
   PROCEDURE test_ff3_encrypt_string_6 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('646965393875028755');
   END;
 
   -- Test #7 -  7
   PROCEDURE test_ff3_encrypt_string_7 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('961610514491424446');
   END;
 
   -- Test #8 -  8
   PROCEDURE test_ff3_encrypt_string_8 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('53048884065350204541786380807');
   END;
 
   -- Test #9 -  9
   PROCEDURE test_ff3_encrypt_string_9 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6',p_tweak=>'0000000000000000',p_algo=>'FF3')).to_equal('98083802678820389295041483512');
   END;
 
   -- Test #10 - 10
   PROCEDURE test_ff3_encrypt_string_10 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'0123456789abcdefghi',p_charset=>'0123456789abcdefghijklmnop',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('i0ihe2jfj7a9opf9p88');
   END;
 
   -- Test #11 - 11
   PROCEDURE test_ff3_encrypt_string_11 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('922011205562777495');
   END;
 
   -- Test #12 - 12
   PROCEDURE test_ff3_encrypt_string_12 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'890121234567890000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('504149865578056140');
   END;
 
   -- Test #13 - 13
   PROCEDURE test_ff3_encrypt_string_13 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C',p_tweak=>'D8E7920AFA330A73',p_algo=>'FF3')).to_equal('04344343235792599165734622699');
   END;
 
   -- Test #14 - 14
   PROCEDURE test_ff3_encrypt_string_14 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'89012123456789000000789000000',p_charset=>'0123456789',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C',p_tweak=>'0000000000000000',p_algo=>'FF3')).to_equal('30859239999374053872365555822');
   END;
 
   -- Test #15 - 15
   PROCEDURE test_ff3_encrypt_string_15 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'0123456789abcdefghi',p_charset=>'0123456789abcdefghijklmnop',p_key=>'EF4359D8D580AA4F7F036D6F04FC6A942B7E151628AED2A6ABF7158809CF4F3C',p_tweak=>'9A768A92F60E12D8',p_algo=>'FF3')).to_equal('p0b2godfja9bhb7bk38');
   END;
 
   -- Test #16 - 16
   PROCEDURE test_ff3_encrypt_string_16 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'3992520240',p_charset=>'0123456789',p_key=>'2DE79D232DF5585D68CE47882AE256D6',p_tweak=>'CBD09280979564',p_algo=>'FF3')).to_equal('8901801106');
   END;
 
   -- Test #17 - 17
   PROCEDURE test_ff3_encrypt_string_17 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'60761757463116869318437658042297305934914824457484538562',p_charset=>'0123456789',p_key=>'01C63017111438F7FC8E24EB16C71AB5',p_tweak=>'C4E822DCD09F27',p_algo=>'FF3')).to_equal('35637144092473838892796702739628394376915177448290847293');
   END;
 
   -- Test #18 - 18
   PROCEDURE test_ff3_encrypt_string_18 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'wfmwlrorcd',p_charset=>'abcdefghijklmnopqrstuvwxyz',p_key=>'718385E6542534604419E83CE387A437',p_tweak=>'B6F35084FA90E1',p_algo=>'FF3')).to_equal('ywowehycyd');
   END;
 
   -- Test #19 - 19
   PROCEDURE test_ff3_encrypt_string_19 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'kkuomenbzqvggfbteqdyanwpmhzdmoicekiihkrm',p_charset=>'abcdefghijklmnopqrstuvwxyz',p_key=>'DB602DFF22ED7E84C8D8C865A941A238',p_tweak=>'EBEFD63BCC2083',p_algo=>'FF3')).to_equal('belcfahcwwytwrckieymthabgjjfkxtxauipmjja');
   END;
 
   -- Test #20 - 20
   PROCEDURE test_ff3_encrypt_string_20 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'ixvuuIHr0e',p_charset=>'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/',p_key=>'AEE87D0D485B3AFD12BD1E0B9D03D50D',p_tweak=>'5F9140601D224B',p_algo=>'FF3')).to_equal('GR90R1q838');
   END;
 
   -- Test #21 - 21
   PROCEDURE test_ff3_encrypt_string_21 IS
   BEGIN
      ut.expect(ds_crypto_krn.encrypt_string(p_value=>'21q1kbbIVSrAFtdFWzdMeIDpRqpo',p_charset=>'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/',p_key=>'7B6C88324732F7F4AD435DA9AD77F917',p_tweak=>'3F42102C0BAB39',p_algo=>'FF3')).to_equal('cvQ/4aGUV4wRnyO3CHmgEKW5hk8H');
   END;
--#endif 0
--@*/--#delete
 
END ds_crypto_ff3_tst;
/