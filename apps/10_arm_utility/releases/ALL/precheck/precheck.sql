--check that user has execute on every package needed
DECLARE
   l_packages VARCHAR2(250) := '''RDS_FILE_UTIL''';
   l_dep_no_grants VARCHAR2(1000);
   l_sql_grants VARCHAR2(2000);   
BEGIN
   IF '&&installation_env' = 'AWS' THEN
      l_sql_grants := '
            SELECT LISTAGG(xxx.table_name, '', '') WITHIN GROUP(ORDER BY xxx.table_name) AS list_of_obj
               FROM ( 
                  SELECT DISTINCT table_name
                     FROM dba_tab_privs
                  WHERE table_name IN (' || l_packages || ')
                  MINUS
                  SELECT DISTINCT table_name
                     FROM dba_tab_privs
                  WHERE table_name IN (' || l_packages || ')
                     AND grantee IN ( user, ''PUBLIC'') 
                     AND privilege = ''EXECUTE'' 
               ) xxx'
      ;      
      EXECUTE IMMEDIATE l_sql_grants INTO l_dep_no_grants;
      IF l_dep_no_grants IS NOT NULL THEN
         dbms_output.put_line('User ' || user || ' needs EXECUTE privilege on ' ||l_dep_no_grants);
         raise_application_error(-20000, 'ERROR: ' || 'User ' || user || ' needs EXECUTE privilege on ' ||l_dep_no_grants);
      ELSE
         dbms_output.put_line('User ' || user || ' has all privilege needed ');
      END IF;
   END IF;
END;
/
