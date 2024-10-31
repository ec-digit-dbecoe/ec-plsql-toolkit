set serveroutput on size 99999
set termout on
DECLARE
   CURSOR c_shared IS
      SELECT 'yes'
	    FROM qc_dictionary_entries
	   WHERE app_alias = 'ALL'
	     AND dict_name = 'PARAMETER'
        AND rownum <= 1
   ;
   CURSOR c_app IS
      SELECT *
	    FROM qc_apps
	   WHERE app_alias != 'ALL'
	   ORDER BY app_alias
   ;
   CURSOR c_sch (
      p_app_alias qc_dictionary_entries.app_alias%TYPE
   )
   IS
      SELECT dict_key schema_name
        FROM qc_dictionary_entries
       WHERE app_alias = p_app_alias
         AND dict_name = 'APP SCHEMA'
       ORDER BY dict_key;
   l_app_count INTEGER;
   l_sch_count INTEGER;
   l_yes_no VARCHAR2(3);
   l_print_title BOOLEAN := TRUE;
BEGIN
   OPEN c_shared;
   FETCH c_shared INTO l_yes_no;
   CLOSE c_shared;
   l_app_count := 0;
   FOR r_app IN c_app LOOP
      IF l_print_title THEN
         dbms_output.put_line('The following applications and schemas are registered: ');
         l_print_title := FALSE;
      END IF;
      l_app_count := l_app_count + 1;
      dbms_output.put('- '||r_app.app_alias||': ');
	   l_sch_count := 0;
	   FOR r_sch IN c_sch(r_app.app_alias) LOOP
	     l_sch_count := l_sch_count + 1;
         dbms_output.put(CASE WHEN l_sch_count > 1 THEN ', ' END||r_sch.schema_name);
	   END LOOP;
      IF l_sch_count = 0 THEN
         dbms_output.put_line('no schema registered yet!');
      ELSE
   	   dbms_output.put_line(CASE WHEN l_yes_no = 'yes' THEN ' (shared config)' ELSE ' (private config)' END);
      END IF;
   END LOOP;
   IF l_app_count = 0 THEN
      dbms_output.put_line('No application registered yet!');
   ELSE
      IF l_yes_no = 'yes' THEN
         dbms_output.put_line('Configuration is shared between all applications');
      ELSE
         dbms_output.put_line('Configuration is private to each application');
      END IF;
   END IF;
END;
/
set serveroutput off
set termout off