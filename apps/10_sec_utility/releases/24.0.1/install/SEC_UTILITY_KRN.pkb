CREATE OR REPLACE PACKAGE BODY sec_utility_krn AS
--#begin public
-- Source: http://www.dba-oracle.com/t_packages_dbms_storing_encrypted_data.htm
   FUNCTION encrypt (
      p_username    IN VARCHAR2
    , p_password    IN VARCHAR2
    , p_unlock_code IN VARCHAR2 DEFAULT NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      l_swordfish           RAW(256);
      l_swordfish_encrypted RAW(256);
   BEGIN
   IF (p_unlock_code is null or p_unlock_code != SYS.UTL_RAW.CAST_TO_VARCHAR2(SYS.UTL_ENCODE.BASE64_DECODE(SYS.UTL_RAW.CAST_TO_RAW(sec_utility_var.k_free_password))))
   THEN
      RETURN NULL;
   END IF; 
   --We generate the l_swordfish, this random number will be needed to decrypt the password
   l_swordfish := SYS.DBMS_CRYPTO.RANDOMBYTES(16);
   -- This function encrypts raw data using a stream or block cipher with a user supplied key
   -- Notice how easy it is to perform the conversion to raw
   l_swordfish_encrypted := SYS.DBMS_CRYPTO.ENCRYPT(
         l_swordfish
       , sec_utility_var.k_encoding_mode
       , SYS.UTL_I18N.STRING_TO_RAW(SYS.UTL_RAW.CAST_TO_VARCHAR2(SYS.UTL_ENCODE.BASE64_DECODE(SYS.UTL_RAW.CAST_TO_RAW(sec_utility_var.k_main_password))),'al32utf8')
    );
   -- Inserting the account name, and l_swordfish, encrypted using the sec_utility_var.k_main_password as key, in secrets table
   INSERT INTO sec_crypto_secrets (
      username, secret
   ) VALUES (
      p_username, l_swordfish_encrypted
   );
   -- At this point, the password storage on column password is returned as an encrypted password random key.
   RETURN   
      SYS.UTL_ENCODE.BASE64_ENCODE(
         SYS.DBMS_CRYPTO.ENCRYPT(
            SYS.UTL_I18N.STRING_TO_RAW(
               p_password
              ,'al32utf8')
           ,sec_utility_var.k_encoding_mode
           ,l_swordfish));
   END;
--#begin public
   FUNCTION decrypt (
      p_username    IN VARCHAR2
    , p_password    IN VARCHAR2
    , p_unlock_code IN VARCHAR2 DEFAULT NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      l_swordfish RAW(256);
   BEGIN
   IF (p_unlock_code is null or p_unlock_code != SYS.UTL_RAW.CAST_TO_VARCHAR2(SYS.UTL_ENCODE.BASE64_DECODE(SYS.UTL_RAW.CAST_TO_RAW(sec_utility_var.k_free_password))))
      THEN
         RETURN NULL;
      END IF;
      SELECT SYS.DBMS_CRYPTO.DECRYPT(
               secret
              ,sec_utility_var.k_encoding_mode
              ,SYS.UTL_I18N.STRING_TO_RAW(
                  SYS.UTL_RAW.CAST_TO_VARCHAR2(SYS.UTL_ENCODE.BASE64_DECODE(SYS.UTL_RAW.CAST_TO_RAW(sec_utility_var.k_main_password)))
                 ,'al32utf8'))
        INTO l_swordfish
        FROM sec_crypto_secrets
       WHERE username = p_username
      ;
      RETURN SYS.utl_i18n.raw_to_char(
                SYS.DBMS_CRYPTO.DECRYPT(
                   SYS.UTL_ENCODE.BASE64_DECODE(p_password)
                  ,sec_utility_var.k_encoding_mode
                  ,l_swordfish)
               ,'al32utf8');
   END;
END;
/