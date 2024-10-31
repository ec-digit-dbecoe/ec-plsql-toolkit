CREATE OR REPLACE PACKAGE sec_utility_krn AS
   FUNCTION encrypt (
      p_username    IN VARCHAR2
    , p_password    IN VARCHAR2
    , p_unlock_code IN VARCHAR2 DEFAULT NULL
   )
   RETURN VARCHAR2
   ;
   FUNCTION decrypt (
      p_username    IN VARCHAR2
    , p_password    IN VARCHAR2
    , p_unlock_code IN VARCHAR2 DEFAULT NULL
   )
   RETURN VARCHAR2
   ;
END;
/