-- https://www.codecrete.net/UnwrapIt/

DECLARE
   a_src dbms_sql.varchar2a;
   a_wrp dbms_sql.varchar2a;
   l_cursor INTEGER;
   CURSOR c_src (
      p_type user_source.type%TYPE
    , p_name user_source.name%TYPE
   )
   IS
      SELECT text
        FROM user_source
       WHERE type = p_type
         AND name = p_name
       ORDER BY line
   ;
   CURSOR c_pkg IS
      SELECT object_type, object_name
        FROM user_objects
       WHERE object_type LIKE 'PACKAGE%'
         AND object_name LIKE 'DPP_SEC_VAR%'
       ORDER BY object_type, object_name
   ;
BEGIN
   <<pkg>>
   FOR r_pkg IN c_pkg LOOP
      <<src>>
      a_src.DELETE;
      FOR r_src IN c_src(r_pkg.object_type,r_pkg.object_name) LOOP
         a_src(a_src.COUNT+1) := CASE WHEN a_src.COUNT = 0 THEN 'CREATE OR REPLACE ' END ||r_src.text;
      END LOOP src;
--      FOR i IN 1..a_src.COUNT LOOP
--         dbms_output.put(i||': '||a_src(i));
--      END LOOP;
--      dbms_output.put_line('');
      SYS.DBMS_DDL.CREATE_WRAPPED(a_src,1,a_src.COUNT);
--  Alternate code
--      a_wrp := sys.dbms_ddl.wrap(a_src,1,a_src.COUNT);
--      FOR i IN 1..a_wrp.COUNT LOOP
--         dbms_output.put(a_wrp(i));
--      END LOOP;
--      dbms_output.put_line('');
--      l_cursor := sys.dbms_sql.open_cursor;
--      sys.dbms_sql.parse(l_cursor,a_wrp,1,a_wrp.COUNT,TRUE,1/*native*/);
--      sys.dbms_sql.close_cursor(l_cursor);
   END LOOP pkg;
END;
/

--SELECT text FROM user_source WHERE type LIKE 'PACKAGE%' and name LIKE 'DPP_SEC_VAR%' ORDER BY type, name, line;
