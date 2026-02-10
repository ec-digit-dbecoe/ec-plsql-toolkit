CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "eu/ec/ds/DSFF3Cipher" AS
package eu.ec.ds;
import com.privacylogistics.FF3Cipher;
import java.util.Objects;

public class DSFF3Cipher {

    // Singleton instance of FF3Cipher
    private static FF3Cipher instance;
    private static String key = "";          // Default empty key
    private static String tweak = "";        // Default empty tweak
    private static String alphabet = "";     // Default empty alphabet

    // Public method to encrypt plaintext
    public static String encrypt(String plaintext, String key, String tweak, String alphabet) {
        try {
            FF3Cipher instance = getInstance(key, tweak, alphabet);
            return instance.encrypt(plaintext);
        } catch (Exception e) {
            throw new RuntimeException("Encryption failed: " + e.getMessage(), e);
        }
    }

    // Public method to decrypt ciphertext
    public static String decrypt(String ciphertext, String key, String tweak, String alphabet) {
        try {
            FF3Cipher instance = getInstance(key, tweak, alphabet);
            return instance.decrypt(ciphertext);
        } catch (Exception e) {
            throw new RuntimeException("Decryption failed: " + e.getMessage(), e);
        }
    }

    // Singleton pattern for FF3Cipher
    public static FF3Cipher getInstance(String key, String tweak, String alphabet) {
        if (instance == null || !Objects.equals(key, DSFF3Cipher.key) || !Objects.equals(tweak, DSFF3Cipher.tweak) || !Objects.equals(alphabet, DSFF3Cipher.alphabet)) {
            try {
                instance = new FF3Cipher(key, tweak, alphabet);
            } catch(Exception e) {
                throw new RuntimeException("Instanciation failed: " + e.getMessage(), e);
            }
            DSFF3Cipher.key = key;           // Store the key
            DSFF3Cipher.tweak= tweak;        // Store the tweak
            DSFF3Cipher.alphabet = alphabet; // Store the alphabet
        }
        return instance;
    }
};
/

CREATE OR REPLACE FUNCTION ff3encrypt(plaintext VARCHAR2, key VARCHAR2, tweak VARCHAR2, alphabet VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'eu/ec/ds/DSFF3Cipher.encrypt(java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
/

CREATE OR REPLACE FUNCTION ff3decrypt(ciphertext VARCHAR2, key VARCHAR2, tweak VARCHAR2, alphabet VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'eu/ec/ds/DSFF3Cipher.decrypt(java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';
/
