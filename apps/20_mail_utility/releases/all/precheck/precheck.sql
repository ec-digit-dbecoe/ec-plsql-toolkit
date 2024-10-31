--check that user has execute on every package needed
DECLARE
   l_packages VARCHAR2(250) := '''UTL_SMTP,UTL_MAIL,UTL_TCP,UTL_RAW''';
   l_dep_no_grants VARCHAR2(1000);
   l_sql_grants VARCHAR2(2000);   
BEGIN
   l_sql_grants := '
          SELECT LISTAGG(xxx.table_name, '', '') WITHIN GROUP(ORDER BY xxx.table_name) AS list_of_obj
            FROM ( 
            select trim(regexp_substr('||l_packages||',''[^,]+'', 1, level)) table_name
              from dual
               connect by regexp_substr('||l_packages||', ''[^,]+'', 1, level) is not null
                 minus 
                 SELECT DISTINCT table_name
                 FROM dba_tab_privs
                WHERE instr('||l_packages||',table_name)>0
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
END;
/