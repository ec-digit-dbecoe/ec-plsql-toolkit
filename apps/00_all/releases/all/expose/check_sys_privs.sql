PROMPT Checking privileges...
DECLARE
   -- Cursor to check missing privileges
   CURSOR c_prv IS
      SELECT * FROM (
         SELECT LISTAGG(my_privs.privilege, ', ') privilege
           FROM (SELECT DECODE(rownum,1,'CREATE ANY SYNONYM') privilege FROM dual CONNECT BY rownum<=1) my_privs
           LEFT OUTER JOIN user_sys_privs sys_privs
             ON sys_privs.privilege = my_privs.privilege
          WHERE sys_privs.privilege IS NULL
            AND LOWER(NVL('&&grantee','public')) != 'public'
          UNION ALL
         SELECT LISTAGG(my_privs.privilege, ', ') privilege
           FROM (SELECT DECODE(rownum,1,'CREATE PUBLIC SYNONYM') privilege FROM dual CONNECT BY rownum<=1) my_privs
           LEFT OUTER JOIN user_sys_privs sys_privs
             ON sys_privs.privilege = my_privs.privilege
          WHERE sys_privs.privilege IS NULL
            AND LOWER(NVL('&&grantee','public')) IN ('public'/*,'all'*/)
         )
      WHERE privilege IS NOT NULL
   ;
   l_privileges VARCHAR2(4000);
BEGIN
   OPEN c_prv;
   FETCH c_prv INTO l_privileges;
   CLOSE c_prv;
   IF l_privileges IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Missing system privilege(s) required for exposing: '||l_privileges);
   END IF;
   dbms_output.put_line('System privileges required for exposing are ok.');
END;
/