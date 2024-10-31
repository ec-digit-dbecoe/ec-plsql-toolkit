CREATE OR REPLACE PACKAGE sec_utility_krn
AUTHID DEFINER
AS
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','sec_utility_krn','public','   ;')
--#if 0
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
--#endif 0
END;
/