CREATE OR REPLACE PACKAGE sec_utility_var
AUTHID DEFINER
IS
   k_main_password CONSTANT VARCHAR2(25) := 'VGhpc0lzVGhlU3VwZXJTZQ==';
   k_free_password CONSTANT VARCHAR2(16) := 'T3BlblNlc2FtZQ==';
   k_encoding_mode CONSTANT NUMBER := SYS.dbms_crypto.encrypt_aes128 +
                                      SYS.dbms_crypto.chain_cbc      +
                                      SYS.dbms_crypto.pad_pkcs5;
END;
/