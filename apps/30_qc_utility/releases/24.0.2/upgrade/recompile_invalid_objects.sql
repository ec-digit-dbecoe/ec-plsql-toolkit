SET SERVEROUTPUT ON;
DECLARE
   -- Define a cursor for selecting invalid objects with their compile statements
   CURSOR invalid_objects_cursor IS
      WITH Invalid_Objects AS (
         SELECT object_name, object_type
         FROM   user_objects
         WHERE  status = 'INVALID'
         AND    object_type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'VIEW', 'TRIGGER', 'TYPE', 'TYPE BODY')
      ),
      Dependency_Order AS (
         SELECT io.object_name,
                io.object_type,
                NVL(MIN(ud.referenced_name), io.object_name) AS dep_object_name
         FROM   Invalid_Objects io
         LEFT JOIN user_dependencies ud
                ON io.object_name = ud.name
                AND ud.referenced_name IN (SELECT object_name FROM user_objects WHERE status = 'INVALID')
         GROUP BY io.object_name, io.object_type
      )
      SELECT object_name,
             object_type,
             CASE
                WHEN object_type = 'PACKAGE BODY' THEN 'ALTER PACKAGE ' || object_name || ' COMPILE BODY'
                WHEN object_type = 'TYPE BODY' THEN 'ALTER TYPE ' || object_name || ' COMPILE BODY'
                ELSE 'ALTER ' || object_type || ' ' || object_name || ' COMPILE'
             END AS compile_statement
      FROM   Dependency_Order
      ORDER  BY dep_object_name NULLS FIRST, object_name;

BEGIN
   -- Loop through each invalid object
   FOR obj IN invalid_objects_cursor LOOP
      -- Output the compile statement
      DBMS_OUTPUT.PUT_LINE('Executing: ' || obj.compile_statement);
      -- Execute the compile statement
      BEGIN
         EXECUTE IMMEDIATE obj.compile_statement;
         DBMS_OUTPUT.PUT_LINE('Compiled successfully: ' || obj.object_name || ' (' || obj.object_type || ')');
      EXCEPTION
         WHEN OTHERS THEN
            -- Handle errors and display them without stopping the loop
            DBMS_OUTPUT.PUT_LINE('Error compiling ' || obj.object_name || ' (' || obj.object_type || '): ' || SQLERRM);
      END;
   END LOOP;
END;
/
