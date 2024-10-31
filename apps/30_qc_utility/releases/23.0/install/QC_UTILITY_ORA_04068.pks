CREATE OR REPLACE PACKAGE qc_utility_ora_04068 IS
   -- Check whether global variables/cursors are defined in a package spec/body
   -- (to avoid ORA-04068: existing state of packages has been discarded)
   -- Return a negative value in case of problem and a positive value otherwise
   -- The return value is the line of code where search stopped on error/success
   FUNCTION check_global_variables (
      p_type IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN INTEGER
   ;
END;
/
