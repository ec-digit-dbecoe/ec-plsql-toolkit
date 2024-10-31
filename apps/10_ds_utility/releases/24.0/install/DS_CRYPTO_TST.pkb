CREATE OR REPLACE PACKAGE BODY ds_crypto_tst AS
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
--    exec gen_utility.generate('PACKAGE ds_crypto_tst', '-f');
--    exec gen_utility.generate('PACKAGE BODY ds_crypto_tst', '-f');
--
--@--#pragma reversible
   gk_key CONSTANT VARCHAR2(30) := 'This is a private key';
   gk_date_format CONSTANT VARCHAR2(10) := 'DD/MM/YYYY';
   gk_timestamp_format CONSTANT VARCHAR2(21) := 'DD/MM/YYYY HH24:MI:SS';
   FUNCTION in_charset (
      p_str IN VARCHAR2
    , p_set IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      IF p_set IS NULL OR p_str IS NULL THEN
         RETURN TRUE;
      END IF;
      FOR i IN 1..LENGTH(p_str) LOOP
         IF INSTR(p_set, NVL(SUBSTR(p_str,i,1),0)) <= 0 THEN
            RETURN FALSE;
         END IF;
      END LOOP;
      RETURN TRUE;
   END;
   ---
   -- Get precision and scale of a give number
   ---
   PROCEDURE get_number_precision_and_scale$ (
      p_num IN NUMBER
    , p_precision OUT PLS_INTEGER
    , p_scale OUT PLS_INTEGER
    , p_negative IN BOOLEAN := FALSE
   )
   IS
      l_str VARCHAR2(200);
      l_pos PLS_INTEGER;
      l_len PLS_INTEGER;
   BEGIN
      l_str := RTRIM(TO_CHAR(p_num));
      l_pos := NVL(INSTR(l_str,'.'),0);
      IF l_pos <= 0 THEN
         l_pos := NVL(INSTR(l_str,','),0);
      END IF;
      l_len := LENGTH(l_str);
      IF l_pos > 0 THEN
         p_precision := l_len - 1;
         p_scale := l_len - l_pos;
      ELSIF NVL(p_negative,FALSE) THEN
         l_pos := l_len;
         WHILE l_pos > 1 AND SUBSTR(l_str,l_pos,1) = '0' LOOP
            l_pos := l_pos - 1;
         END LOOP;
         p_precision := l_pos;
         p_scale := l_pos - l_len;
      ELSE
         p_precision := l_len;
         p_scale := 0;
      END IF;
   END;
/*
--@#begin encrypt_decrypt_string_dataset
name;value;len;format;charset;key;exception
encrypt/decrypt string: value;'This is a string';NULL;NULL;NULL;NULL;0
encrypt/decrypt string: value+len;'This is a string';20;NULL;NULL;NULL;0
encrypt/decrypt string: value+format;'This is a string';NULL;'Aa ';NULL;NULL;0
encrypt/decrypt string: value+charset;'This is a string';NULL;NULL;'This is a string';NULL;0
encrypt/decrypt string: value+key;'This is a string';NULL;NULL;NULL;gk_key;0
encrypt/decrypt string: value+len+format;'This is a string';20;'Aa ';NULL;NULL;0
encrypt/decrypt string: value+len+charset;'This is a string';20;NULL;'This is a string';NULL;0
encrypt/decrypt string: value+len+key;'This is a string';20;NULL;NULL;gk_key;0
encrypt/decrypt string error: value+format+charset;'This is a string';NULL;'Aa ';'This is a string';NULL;-20012
encrypt/decrypt string: value+format+key;'This is a string';NULL;'Aa ';NULL;gk_key;0
encrypt/decrypt string: value+charset+key;'This is a string';NULL;NULL;'This is a string';gk_key;0
encrypt/decrypt string: null value;CAST(NULL AS VARCHAR2);NULL;NULL;NULL;NULL;0
encrypt/decrypt string error: value;'This is a string';10;NULL;NULL;NULL;-20011
encrypt/decrypt string error: charset;'This is a string with';NULL;'A';NULL;NULL;-20016
encrypt/decrypt string error: charset;'This is a string with x';NULL;NULL;'This is a string';NULL;-20016
--@#end encrypt_decrypt_string_dataset
*/
 
--@/*--#delete
--@#begin encrypt_decrypt_string_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_TST'',''encrypt_decrypt_string_dataset''))')) x)
--@#end encrypt_decrypt_string_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_encrypt_decrypt_string_tst.seq IS
--@   BEGIN
--@      IF tst.key IS NULL THEN
--@         ds_crypto_krn.set_encryption_key(gk_key);
--@      END IF;
--@      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>tst.value,p_len=>tst.len,p_format=>tst.format,p_charset=>tst.charset,p_key=>tst.key)
--@               ,p_len=>tst.len,p_format=>tst.format,p_charset=>tst.charset,p_key=>tst.key)).to_equal(tst.value);
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - encrypt/decrypt string: value
   PROCEDURE test_encrypt_decrypt_string_1 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>NULL)
               ,p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #2 - encrypt/decrypt string: value+len
   PROCEDURE test_encrypt_decrypt_string_2 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>NULL,p_charset=>NULL,p_key=>NULL)
               ,p_len=>20,p_format=>NULL,p_charset=>NULL,p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #3 - encrypt/decrypt string: value+format
   PROCEDURE test_encrypt_decrypt_string_3 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>'Aa ',p_charset=>NULL,p_key=>NULL)
               ,p_len=>NULL,p_format=>'Aa ',p_charset=>NULL,p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #4 - encrypt/decrypt string: value+charset
   PROCEDURE test_encrypt_decrypt_string_4 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)
               ,p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #5 - encrypt/decrypt string: value+key
   PROCEDURE test_encrypt_decrypt_string_5 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>gk_key)
               ,p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>gk_key)).to_equal('This is a string');
   END;
 
   -- Test #6 - encrypt/decrypt string: value+len+format
   PROCEDURE test_encrypt_decrypt_string_6 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>'Aa ',p_charset=>NULL,p_key=>NULL)
               ,p_len=>20,p_format=>'Aa ',p_charset=>NULL,p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #7 - encrypt/decrypt string: value+len+charset
   PROCEDURE test_encrypt_decrypt_string_7 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)
               ,p_len=>20,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #8 - encrypt/decrypt string: value+len+key
   PROCEDURE test_encrypt_decrypt_string_8 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>NULL,p_charset=>NULL,p_key=>gk_key)
               ,p_len=>20,p_format=>NULL,p_charset=>NULL,p_key=>gk_key)).to_equal('This is a string');
   END;
 
   -- Test #9 - encrypt/decrypt string error: value+format+charset
   PROCEDURE test_encrypt_decrypt_string_9 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>'Aa ',p_charset=>'This is a string',p_key=>NULL)
               ,p_len=>NULL,p_format=>'Aa ',p_charset=>'This is a string',p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #10 - encrypt/decrypt string: value+format+key
   PROCEDURE test_encrypt_decrypt_string_10 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>'Aa ',p_charset=>NULL,p_key=>gk_key)
               ,p_len=>NULL,p_format=>'Aa ',p_charset=>NULL,p_key=>gk_key)).to_equal('This is a string');
   END;
 
   -- Test #11 - encrypt/decrypt string: value+charset+key
   PROCEDURE test_encrypt_decrypt_string_11 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>gk_key)
               ,p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>gk_key)).to_equal('This is a string');
   END;
 
   -- Test #12 - encrypt/decrypt string: null value
   PROCEDURE test_encrypt_decrypt_string_12 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>CAST(NULL AS VARCHAR2),p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>NULL)
               ,p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>NULL)).to_equal(CAST(NULL AS VARCHAR2));
   END;
 
   -- Test #13 - encrypt/decrypt string error: value
   PROCEDURE test_encrypt_decrypt_string_13 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>10,p_format=>NULL,p_charset=>NULL,p_key=>NULL)
               ,p_len=>10,p_format=>NULL,p_charset=>NULL,p_key=>NULL)).to_equal('This is a string');
   END;
 
   -- Test #14 - encrypt/decrypt string error: charset
   PROCEDURE test_encrypt_decrypt_string_14 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string with',p_len=>NULL,p_format=>'A',p_charset=>NULL,p_key=>NULL)
               ,p_len=>NULL,p_format=>'A',p_charset=>NULL,p_key=>NULL)).to_equal('This is a string with');
   END;
 
   -- Test #15 - encrypt/decrypt string error: charset
   PROCEDURE test_encrypt_decrypt_string_15 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_string(p_value=>ds_crypto_krn.encrypt_string(p_value=>'This is a string with x',p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)
               ,p_len=>NULL,p_format=>NULL,p_charset=>'This is a string',p_key=>NULL)).to_equal('This is a string with x');
   END;
--#endif 0
--@*/--#delete
 
/*
--@#begin encrypt_string_dataset
name;value;len;format;charset;key;result;exception
encrypt string: key too short;'This is a string';'';NULL;NULL;'Short key';'';-20005
encrypt string: value only;'This is a string';NULL;NULL;NULL;'This is another private key';'Ú-2|0ïþKKÓ]àVd6#';0
encrypt string: value+len;'This is a string';20;NULL;NULL;'This is another private key';'|[ÓáðËq,áïÕNùqæ$d?nG';0
encrypt string: value+format;'This is a string';NULL;'Aa ';NULL;'This is another private key';'NMqQyclOTMoJIzJU';0
encrypt string error: invalid character;'This is a string';NULL;'Aa';NULL;'This is another private key';'';-20016
encrypt string: value+charset;'This is a string';NULL;NULL;'This atrng';'This is another private key';' tngan hittTt ga';0
encrypt string: value+len+format;'This is a string';20;'Aa ';NULL;'This is another private key';'QLEEKQKrMFSx gnKiJks';0
encrypt string: value+charset;'This is a string';20;NULL;'This atrng';'This is another private key';'aTrngtna iris tiitaa';0
--@#end encrypt_string_dataset
*/
--@/*--#delete
--@#begin encrypt_string_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_TST'',''encrypt_string_dataset''))')) x)
--@#end encrypt_string_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_encrypt_string_tst.seq IS
--@      l_cypher VARCHAR2(32767);
--@   BEGIN
--@      l_cypher := ds_crypto_krn.encrypt_string(p_value=>tst.value,p_len=>tst.len,p_format=>tst.format,p_charset=>tst.charset,p_key=>tst.key);
--@      ut.expect(l_cypher).to_equal(tst.result); -- expected cypher
--@      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
--@      ut.expect(LENGTH(l_cypher)).to_equal(NVL(tst.len,LENGTH(tst.value))); -- expected length
--@#if "tst.format" != "NULL"
--@      ut.expect(in_charset(l_cypher,ds_crypto_krn.get_charset(tst.format))).to_equal(TRUE);
--@#endif
--@#if "tst.charset" != "NULL"
--@      ut.expect(in_charset(l_cypher,tst.charset)).to_equal(TRUE);
--@#endif
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - encrypt string: key too short
   PROCEDURE test_encrypt_string_1 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>'',p_format=>NULL,p_charset=>NULL,p_key=>'Short key');
      ut.expect(l_cypher).to_equal(''); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL('',LENGTH('This is a string'))); -- expected length
   END;
 
   -- Test #2 - encrypt string: value only
   PROCEDURE test_encrypt_string_2 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>NULL,p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal('Ú-2|0ïþKKÓ]àVd6#'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(NULL,LENGTH('This is a string'))); -- expected length
   END;
 
   -- Test #3 - encrypt string: value+len
   PROCEDURE test_encrypt_string_3 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>NULL,p_charset=>NULL,p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal('|[ÓáðËq,áïÕNùqæ$d?nG'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(20,LENGTH('This is a string'))); -- expected length
   END;
 
   -- Test #4 - encrypt string: value+format
   PROCEDURE test_encrypt_string_4 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>'Aa ',p_charset=>NULL,p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal('NMqQyclOTMoJIzJU'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(NULL,LENGTH('This is a string'))); -- expected length
      ut.expect(in_charset(l_cypher,ds_crypto_krn.get_charset('Aa '))).to_equal(TRUE);
   END;
 
   -- Test #5 - encrypt string error: invalid character
   PROCEDURE test_encrypt_string_5 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>'Aa',p_charset=>NULL,p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal(''); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(NULL,LENGTH('This is a string'))); -- expected length
      ut.expect(in_charset(l_cypher,ds_crypto_krn.get_charset('Aa'))).to_equal(TRUE);
   END;
 
   -- Test #6 - encrypt string: value+charset
   PROCEDURE test_encrypt_string_6 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>NULL,p_format=>NULL,p_charset=>'This atrng',p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal(' tngan hittTt ga'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(NULL,LENGTH('This is a string'))); -- expected length
      ut.expect(in_charset(l_cypher,'This atrng')).to_equal(TRUE);
   END;
 
   -- Test #7 - encrypt string: value+len+format
   PROCEDURE test_encrypt_string_7 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>'Aa ',p_charset=>NULL,p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal('QLEEKQKrMFSx gnKiJks'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(20,LENGTH('This is a string'))); -- expected length
      ut.expect(in_charset(l_cypher,ds_crypto_krn.get_charset('Aa '))).to_equal(TRUE);
   END;
 
   -- Test #8 - encrypt string: value+charset
   PROCEDURE test_encrypt_string_8 IS
      l_cypher VARCHAR2(32767);
   BEGIN
      l_cypher := ds_crypto_krn.encrypt_string(p_value=>'This is a string',p_len=>20,p_format=>NULL,p_charset=>'This atrng',p_key=>'This is another private key');
      ut.expect(l_cypher).to_equal('aTrngtna iris tiitaa'); -- expected cypher
      ut.expect(RTRIM(l_cypher)).to_equal(l_cypher); -- no trailing space (lost when stored)
      ut.expect(LENGTH(l_cypher)).to_equal(NVL(20,LENGTH('This is a string'))); -- expected length
      ut.expect(in_charset(l_cypher,'This atrng')).to_equal(TRUE);
   END;
--#endif 0
--@*/--#delete
 
/*
--@#begin encrypt_decrypt_number_dataset
name;value;precision;scale;key;exception
encrypt/decrypt number: value;12345;NULL;NULL;NULL;0
encrypt/decrypt number: value+precision;12345;10;NULL;NULL;0
encrypt/decrypt number: value+precision+scale;123.45;10;3;NULL;0
encrypt/decrypt number: value+key;123.45;NULL;NULL;gk_key;0
encrypt/decrypt number: value+precision+scale+key;123.45;10;3;gk_key;0
encrypt/decrypt number: null value;CAST(NULL AS NUMBER);NULL;NULL;NULL;0
encrypt/decrypt number: integer with negative scale;12300;3;-2;NULL;0
encrypt/decrypt number error: invalid precision;12345;0;NULL;NULL;-20006
encrypt/decrypt number error: invalid precision;12345;-1;NULL;NULL;-20006
encrypt/decrypt number error: invalid scale;12345;NULL;-85;NULL;-20007
encrypt/decrypt number error: invalid scale;12345;NULL;128;NULL;-20007
encrypt/decrypt number error: invalid number (precision);12345;4;NULL;NULL;-20008
encrypt/decrypt number error: invalid number (precision);123.45;4;NULL;NULL;-20008
encrypt/decrypt number error: invalid number (scale);123.45;5;1;NULL;-20009
encrypt/decrypt number error: invalid number (neg scale);12345;5;-1;NULL;-20009
--@#end encrypt_decrypt_number_dataset
*/
--@/*--#delete
--@#begin encrypt_decrypt_number_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_TST'',''encrypt_decrypt_number_dataset''))')) x)
--@#end encrypt_decrypt_number_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_encrypt_decrypt_number_tst.seq IS
--@   BEGIN
--@      IF tst.key IS NULL THEN
--@         ds_crypto_krn.set_encryption_key(gk_key);
--@      END IF;
--@      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>tst.value,p_precision=>tst.precision,p_scale=>tst.scale,p_key=>tst.key)
--@               ,p_precision=>tst.precision,p_scale=>tst.scale,p_key=>tst.key)).to_equal(tst.value);
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - encrypt/decrypt number: value
   PROCEDURE test_encrypt_decrypt_number_1 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>NULL,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>NULL,p_scale=>NULL,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #2 - encrypt/decrypt number: value+precision
   PROCEDURE test_encrypt_decrypt_number_2 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>10,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>10,p_scale=>NULL,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #3 - encrypt/decrypt number: value+precision+scale
   PROCEDURE test_encrypt_decrypt_number_3 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>10,p_scale=>3,p_key=>NULL)
               ,p_precision=>10,p_scale=>3,p_key=>NULL)).to_equal(123.45);
   END;
 
   -- Test #4 - encrypt/decrypt number: value+key
   PROCEDURE test_encrypt_decrypt_number_4 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>NULL,p_scale=>NULL,p_key=>gk_key)
               ,p_precision=>NULL,p_scale=>NULL,p_key=>gk_key)).to_equal(123.45);
   END;
 
   -- Test #5 - encrypt/decrypt number: value+precision+scale+key
   PROCEDURE test_encrypt_decrypt_number_5 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>10,p_scale=>3,p_key=>gk_key)
               ,p_precision=>10,p_scale=>3,p_key=>gk_key)).to_equal(123.45);
   END;
 
   -- Test #6 - encrypt/decrypt number: null value
   PROCEDURE test_encrypt_decrypt_number_6 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>CAST(NULL AS NUMBER),p_precision=>NULL,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>NULL,p_scale=>NULL,p_key=>NULL)).to_equal(CAST(NULL AS NUMBER));
   END;
 
   -- Test #7 - encrypt/decrypt number: integer with negative scale
   PROCEDURE test_encrypt_decrypt_number_7 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>3,p_scale=>-2,p_key=>NULL)
               ,p_precision=>3,p_scale=>-2,p_key=>NULL)).to_equal(12300);
   END;
 
   -- Test #8 - encrypt/decrypt number error: invalid precision
   PROCEDURE test_encrypt_decrypt_number_8 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>0,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>0,p_scale=>NULL,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #9 - encrypt/decrypt number error: invalid precision
   PROCEDURE test_encrypt_decrypt_number_9 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>-1,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>-1,p_scale=>NULL,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #10 - encrypt/decrypt number error: invalid scale
   PROCEDURE test_encrypt_decrypt_number_10 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>NULL,p_scale=>-85,p_key=>NULL)
               ,p_precision=>NULL,p_scale=>-85,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #11 - encrypt/decrypt number error: invalid scale
   PROCEDURE test_encrypt_decrypt_number_11 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>NULL,p_scale=>128,p_key=>NULL)
               ,p_precision=>NULL,p_scale=>128,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #12 - encrypt/decrypt number error: invalid number (precision)
   PROCEDURE test_encrypt_decrypt_number_12 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>4,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>4,p_scale=>NULL,p_key=>NULL)).to_equal(12345);
   END;
 
   -- Test #13 - encrypt/decrypt number error: invalid number (precision)
   PROCEDURE test_encrypt_decrypt_number_13 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>4,p_scale=>NULL,p_key=>NULL)
               ,p_precision=>4,p_scale=>NULL,p_key=>NULL)).to_equal(123.45);
   END;
 
   -- Test #14 - encrypt/decrypt number error: invalid number (scale)
   PROCEDURE test_encrypt_decrypt_number_14 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>5,p_scale=>1,p_key=>NULL)
               ,p_precision=>5,p_scale=>1,p_key=>NULL)).to_equal(123.45);
   END;
 
   -- Test #15 - encrypt/decrypt number error: invalid number (neg scale)
   PROCEDURE test_encrypt_decrypt_number_15 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_number(p_value=>ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>5,p_scale=>-1,p_key=>NULL)
               ,p_precision=>5,p_scale=>-1,p_key=>NULL)).to_equal(12345);
   END;
--#endif 0
--@*/--#delete
 
/*
--@#begin encrypt_number_dataset
name;value;precision;scale;key;result;exception
encrypt number: null value;CAST(NULL AS NUMBER);NULL;NULL;'This is another private key';CAST(NULL AS NUMBER);0
encrypt number: number+precision;12345;8;NULL;'This is another private key';70580603;0
encrypt number: number+scale;123.45;NULL;1;'This is another private key';0;-20009
encrypt number: number+scale;123.46;NULL;2;'This is another private key';799.18;0
encrypt number: number+scale;123.45;NULL;3;'This is another private key';633.952;0
encrypt number: number+precision+scale;123.45;4;2;'This is another private key';0;-20008
encrypt number: number+precision+scale;123.45;5;2;'This is another private key';876.08;0
encrypt number: number+precision+scale;123.45;6;2;'This is another private key';5692.83;0
encrypt number: number+precision+scale;123.45;4;1;'This is another private key';0;-20009
encrypt number: number+precision+scale;123.45;5;2;'This is another private key';876.08;0
encrypt number: number+precision+scale;123.45;6;3;'This is another private key';456.344;0
encrypt number: integer;12345;NULL;NULL;'This is another private key';31950;0
encrypt number: integer+negative scale;12300;NULL;-1;'This is another private key';35810;0
encrypt number: integer+negative scale;12300;NULL;-2;'This is another private key';70000;0
encrypt number: integer+negative scale;12300;NULL;-3;'This is another private key';0;-20009
encrypt number: integer+precision+negative scale;12300;4;-1;'This is another private key';50430;0
encrypt number: integer+precision+negative scale;12300;4;-2;'This is another private key';624900;0
encrypt number: integer+precision+negative scale;12300;4;-3;'This is another private key';0;-20009
encrypt number: integer+precision+negative scale;12300;3;-2;'This is another private key';14900;0
encrypt number: integer+precision+negative scale;12300;2;-2;'This is another private key';0;-20008
--@#end encrypt_number_dataset
*/
--@/*--#delete
--@#begin encrypt_number_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_TST'',''encrypt_number_dataset''))')) x)
--@#end encrypt_number_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_encrypt_number_tst.seq IS
--@      l_result NUMBER;
--@      l_precision PLS_INTEGER;
--@      l_scale PLS_INTEGER;
--@      l_val_precision PLS_INTEGER;
--@      l_val_scale PLS_INTEGER;
--@      l_res_precision PLS_INTEGER;
--@      l_res_scale PLS_INTEGER;
--@   BEGIN
--@      IF tst.key IS NULL THEN
--@         ds_crypto_krn.set_encryption_key(gk_key);
--@      END IF;
--@      l_result := ds_crypto_krn.encrypt_number(p_value=>tst.value,p_precision=>tst.precision,p_scale=>tst.scale,p_key=>tst.key);
--@      ut.expect(l_result).to_equal(tst.result);
--@#if "tst.value" != "CAST(NULL AS NUMBER)"
--@      get_number_precision_and_scale$(tst.value, l_val_precision, l_val_scale, tst.scale < 0);
--@      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, tst.scale < 0);
--@      l_scale := NVL(tst.scale, l_val_scale);
--@      l_precision := NVL(tst.precision, l_val_precision + l_scale - l_val_scale);
--@      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
--@      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
--@#endif
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - encrypt number: null value
   PROCEDURE test_encrypt_number_1 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>CAST(NULL AS NUMBER),p_precision=>NULL,p_scale=>NULL,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(CAST(NULL AS NUMBER));
   END;
 
   -- Test #2 - encrypt number: number+precision
   PROCEDURE test_encrypt_number_2 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>8,p_scale=>NULL,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(70580603);
      get_number_precision_and_scale$(12345, l_val_precision, l_val_scale, NULL < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, NULL < 0);
      l_scale := NVL(NULL, l_val_scale);
      l_precision := NVL(8, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #3 - encrypt number: number+scale
   PROCEDURE test_encrypt_number_3 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>NULL,p_scale=>1,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 1 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 1 < 0);
      l_scale := NVL(1, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #4 - encrypt number: number+scale
   PROCEDURE test_encrypt_number_4 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.46,p_precision=>NULL,p_scale=>2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(799.18);
      get_number_precision_and_scale$(123.46, l_val_precision, l_val_scale, 2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 2 < 0);
      l_scale := NVL(2, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #5 - encrypt number: number+scale
   PROCEDURE test_encrypt_number_5 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>NULL,p_scale=>3,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(633.952);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 3 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 3 < 0);
      l_scale := NVL(3, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #6 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_6 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>4,p_scale=>2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 2 < 0);
      l_scale := NVL(2, l_val_scale);
      l_precision := NVL(4, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #7 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_7 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>5,p_scale=>2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(876.08);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 2 < 0);
      l_scale := NVL(2, l_val_scale);
      l_precision := NVL(5, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #8 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_8 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>6,p_scale=>2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(5692.83);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 2 < 0);
      l_scale := NVL(2, l_val_scale);
      l_precision := NVL(6, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #9 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_9 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>4,p_scale=>1,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 1 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 1 < 0);
      l_scale := NVL(1, l_val_scale);
      l_precision := NVL(4, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #10 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_10 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>5,p_scale=>2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(876.08);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 2 < 0);
      l_scale := NVL(2, l_val_scale);
      l_precision := NVL(5, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #11 - encrypt number: number+precision+scale
   PROCEDURE test_encrypt_number_11 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>123.45,p_precision=>6,p_scale=>3,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(456.344);
      get_number_precision_and_scale$(123.45, l_val_precision, l_val_scale, 3 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, 3 < 0);
      l_scale := NVL(3, l_val_scale);
      l_precision := NVL(6, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #12 - encrypt number: integer
   PROCEDURE test_encrypt_number_12 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12345,p_precision=>NULL,p_scale=>NULL,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(31950);
      get_number_precision_and_scale$(12345, l_val_precision, l_val_scale, NULL < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, NULL < 0);
      l_scale := NVL(NULL, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #13 - encrypt number: integer+negative scale
   PROCEDURE test_encrypt_number_13 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>NULL,p_scale=>-1,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(35810);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -1 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -1 < 0);
      l_scale := NVL(-1, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #14 - encrypt number: integer+negative scale
   PROCEDURE test_encrypt_number_14 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>NULL,p_scale=>-2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(70000);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -2 < 0);
      l_scale := NVL(-2, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #15 - encrypt number: integer+negative scale
   PROCEDURE test_encrypt_number_15 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>NULL,p_scale=>-3,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -3 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -3 < 0);
      l_scale := NVL(-3, l_val_scale);
      l_precision := NVL(NULL, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #16 - encrypt number: integer+precision+negative scale
   PROCEDURE test_encrypt_number_16 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>4,p_scale=>-1,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(50430);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -1 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -1 < 0);
      l_scale := NVL(-1, l_val_scale);
      l_precision := NVL(4, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #17 - encrypt number: integer+precision+negative scale
   PROCEDURE test_encrypt_number_17 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>4,p_scale=>-2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(624900);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -2 < 0);
      l_scale := NVL(-2, l_val_scale);
      l_precision := NVL(4, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #18 - encrypt number: integer+precision+negative scale
   PROCEDURE test_encrypt_number_18 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>4,p_scale=>-3,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -3 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -3 < 0);
      l_scale := NVL(-3, l_val_scale);
      l_precision := NVL(4, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #19 - encrypt number: integer+precision+negative scale
   PROCEDURE test_encrypt_number_19 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>3,p_scale=>-2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(14900);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -2 < 0);
      l_scale := NVL(-2, l_val_scale);
      l_precision := NVL(3, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
 
   -- Test #20 - encrypt number: integer+precision+negative scale
   PROCEDURE test_encrypt_number_20 IS
      l_result NUMBER;
      l_precision PLS_INTEGER;
      l_scale PLS_INTEGER;
      l_val_precision PLS_INTEGER;
      l_val_scale PLS_INTEGER;
      l_res_precision PLS_INTEGER;
      l_res_scale PLS_INTEGER;
   BEGIN
      IF 'This is another private key' IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      l_result := ds_crypto_krn.encrypt_number(p_value=>12300,p_precision=>2,p_scale=>-2,p_key=>'This is another private key');
      ut.expect(l_result).to_equal(0);
      get_number_precision_and_scale$(12300, l_val_precision, l_val_scale, -2 < 0);
      get_number_precision_and_scale$(l_result, l_res_precision, l_res_scale, -2 < 0);
      l_scale := NVL(-2, l_val_scale);
      l_precision := NVL(2, l_val_precision + l_scale - l_val_scale);
      ut.expect(l_res_precision - l_res_scale).to_be_less_or_equal(l_precision - l_scale);
      ut.expect(l_res_scale).to_be_less_or_equal(l_scale);
   END;
--#endif 0
--@*/--#delete
 
/*
--@#begin encrypt_decrypt_date_dataset
name;value;min_date;max_date;key;exception
encrypt/decrypt date: null value;NULL;NULL;NULL;gk_key;0
encrypt/decrypt date: value;'24/01/2024';NULL;NULL;NULL;0
encrypt/decrypt date: value+key;'24/01/2024';NULL;NULL;gk_key;0
encrypt/decrypt date: value+min;'24/01/2024';'01/01/2024';NULL;NULL;0
encrypt/decrypt date: value+min;'24/01/2024';'01/01/2025';NULL;NULL;-20013
encrypt/decrypt date: value+max;'24/01/2024';NULL;'31/12/2024';NULL;0
encrypt/decrypt date: value+max;'24/01/2024';NULL;'31/12/2023';NULL;-20013
encrypt/decrypt date: value+min+max;'24/01/2024';'01/01/2024';'31/12/2024';NULL;0
encrypt/decrypt date: value+min+max;'24/01/2024';'01/01/2024';'31/12/2024';NULL;0
encrypt/decrypt date: value+min+max;'24/01/2024';'01/01/2024';'31/12/2023';NULL;-20017
--@#end encrypt_decrypt_date_dataset
*/
--@/*--#delete
--@#begin encrypt_decrypt_date_for_loop
--@#for tst IN (SELECT rownum "seq", x.* FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''DS_CRYPTO_TST'',''encrypt_decrypt_date_dataset''))')) x)
--@#end encrypt_decrypt_date_for_loop
--@
--@   -- Test #tst.seq - tst.name
--@   PROCEDURE test_encrypt_decrypt_date_tst.seq IS
--@   BEGIN
--@      IF tst.key IS NULL THEN
--@         ds_crypto_krn.set_encryption_key(gk_key);
--@      END IF;
--@      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
--@                p_value=>TO_DATE(tst.value,gk_date_format),p_min_date=>TO_DATE(tst.min_date,gk_date_format),p_max_date=>TO_DATE(tst.max_date,gk_date_format),p_key=>tst.key)
--@               ,p_min_date=>TO_DATE(tst.min_date,gk_date_format),p_max_date=>TO_DATE(tst.max_date,gk_date_format),p_key=>tst.key)).to_equal(TO_DATE(tst.value,gk_date_format));
--@   END;
--@#endfor
--#if 0
 
   -- Test #1 - encrypt/decrypt date: null value
   PROCEDURE test_encrypt_decrypt_date_1 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE(NULL,gk_date_format),p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>gk_key)
               ,p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>gk_key)).to_equal(TO_DATE(NULL,gk_date_format));
   END;
 
   -- Test #2 - encrypt/decrypt date: value
   PROCEDURE test_encrypt_decrypt_date_2 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #3 - encrypt/decrypt date: value+key
   PROCEDURE test_encrypt_decrypt_date_3 IS
   BEGIN
      IF gk_key IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>gk_key)
               ,p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>gk_key)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #4 - encrypt/decrypt date: value+min
   PROCEDURE test_encrypt_decrypt_date_4 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #5 - encrypt/decrypt date: value+min
   PROCEDURE test_encrypt_decrypt_date_5 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE('01/01/2025',gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE('01/01/2025',gk_date_format),p_max_date=>TO_DATE(NULL,gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #6 - encrypt/decrypt date: value+max
   PROCEDURE test_encrypt_decrypt_date_6 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #7 - encrypt/decrypt date: value+max
   PROCEDURE test_encrypt_decrypt_date_7 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE('31/12/2023',gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE(NULL,gk_date_format),p_max_date=>TO_DATE('31/12/2023',gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #8 - encrypt/decrypt date: value+min+max
   PROCEDURE test_encrypt_decrypt_date_8 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #9 - encrypt/decrypt date: value+min+max
   PROCEDURE test_encrypt_decrypt_date_9 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2024',gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
 
   -- Test #10 - encrypt/decrypt date: value+min+max
   PROCEDURE test_encrypt_decrypt_date_10 IS
   BEGIN
      IF NULL IS NULL THEN
         ds_crypto_krn.set_encryption_key(gk_key);
      END IF;
      ut.expect(ds_crypto_krn.decrypt_date(p_value=>ds_crypto_krn.encrypt_date(
                p_value=>TO_DATE('24/01/2024',gk_date_format),p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2023',gk_date_format),p_key=>NULL)
               ,p_min_date=>TO_DATE('01/01/2024',gk_date_format),p_max_date=>TO_DATE('31/12/2023',gk_date_format),p_key=>NULL)).to_equal(TO_DATE('24/01/2024',gk_date_format));
   END;
--#endif 0
--@*/--#delete
 
END ds_crypto_tst;
/
