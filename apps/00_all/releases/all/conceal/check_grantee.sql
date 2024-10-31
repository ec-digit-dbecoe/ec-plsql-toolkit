PROMPT Checking grantee "&&grantee"...
DECLARE
   CURSOR c_usr IS
      SELECT 'x'
        FROM all_users
       WHERE username = UPPER('&&grantee')
      ;
   l_dummy VARCHAR2(1);
   l_found BOOLEAN := TRUE;
BEGIN
   IF LOWER('&&grantee') = LOWER(USER) THEN
      raise_application_error(-20000, 'Cannot conceal database objects from current schema!');
   END IF;
   IF NOT NVL(LOWER('&&grantee'),'public') IN ('public','all') THEN
      OPEN c_usr;
      FETCH c_usr INTO l_dummy;
      l_found := c_usr%FOUND;
      CLOSE c_usr;
   END IF;
   IF l_found THEN
      dbms_output.put_line('Grantee "&&grantee" is valid');
   ELSE
      raise_application_error(-20000, 'Schema "&&grantee" does not exist!');
   END IF;
END;
/