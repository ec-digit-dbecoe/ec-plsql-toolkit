DECLARE
   -- Cursor to check the existence of a package and its state
   CURSOR c_obj (
      p_object_type IN user_objects.object_type%TYPE
    , p_object_name IN user_objects.object_name%TYPE
    , p_status IN user_objects.status%TYPE
   )
   IS
      SELECT 'x'
        FROM user_objects
       WHERE object_type = UPPER(p_object_type)
         AND object_name = UPPER(p_object_name)
         AND status = UPPER(p_status)
   ;
   -- Cursor to get the source code of a package
   CURSOR c_src (
      p_type IN user_source.type%TYPE
    , p_name IN user_source.name%TYPE
   )
   IS
      SELECT line, text
        FROM user_source
       WHERE type = UPPER(p_type)
         AND name = UPPER(p_name)
         
       ORDER BY line
   ;
   -- Check for abnormal tags in existing source code
   CURSOR c_ano IS
      SELECT 'x'
        FROM user_source
       WHERE type LIKE 'PACKAGE%'
         AND name = 'DOC_UTILITY_EXT'
         AND text like '%@beg:%'
         AND rownum <= 1
   ;
   l_dummy VARCHAR2(1);
   l_gen_found BOOLEAN;
   l_ano_exists BOOLEAN;
   l_ano_found BOOLEAN;
   t_src sys.dbms_sql.varchar2a;
   l_object_type VARCHAR2(30);
   l_object_name VARCHAR2(30);
   l_cursor INTEGER;
   l_count INTEGER;
BEGIN
   -- Init
   l_object_name := 'doc_utility_ext';
   -- Check if code generator package is installed and valid
   OPEN c_obj('PACKAGE BODY','GEN_UTILITY','VALID');
   FETCH c_obj INTO l_dummy;
   l_gen_found := c_obj%FOUND;
   CLOSE c_obj;
   IF l_gen_found THEN
      dbms_output.put_line('Code generator found!');
   ELSE
      dbms_output.put_line('Code generator not found!');
   END IF;
   -- Check for tag anomalies
   OPEN c_ano;
   FETCH c_ano INTO l_dummy;
   l_ano_exists := c_ano%FOUND;
   CLOSE c_ano;
   -- For each object type: 1=package spec, 2=package body
   FOR i IN 1..2 LOOP
      l_object_type := CASE WHEN i=1 THEN 'PACKAGE' ELSE 'PACKAGE BODY' END;
      IF l_gen_found THEN
         -- Code generator is installed
         IF l_ano_exists THEN
            -- Get code of extension package and search for tag anomalies (e.g. @beg: instead of @begin:)
            t_src.DELETE;
            l_ano_found := FALSE;
            FOR r_src IN c_src(l_object_type,l_object_name) LOOP
               IF SUBSTR(r_src.text,-1,1) = CHR(10) THEN
                  t_src(r_src.line) := SUBSTR(r_src.text,1,LENGTH(r_src.text)-1);
               ELSE
                  t_src(r_src.line) := r_src.text;
               END IF;
               -- Fix some tag issues existing in v1.0
               -- @beg should be @begin
               IF INSTR(t_src(r_src.line),'@beg:')>0 THEN
                  l_ano_found := TRUE;
                  t_src(r_src.line) := REPLACE(t_src(r_src.line),'@beg:','@begin:');
               END IF;
               -- :declare should be :decl
               IF t_src(r_src.line) LIKE '%--@%:declare%' THEN
                  l_ano_found := TRUE;
                  t_src(r_src.line) := REPLACE(t_src(r_src.line),':declare',':decl');
               END IF;
               -- docx_merge procedure and function are now standard code (part of the template)
               -- remove surrounding tags to avoid duplicate code when getting custom code
               IF INSTR(t_src(r_src.line),'@begin:decl')>0 THEN
                  l_ano_found := TRUE;
                  t_src(r_src.line) := REPLACE(t_src(r_src.line),'@begin:decl','');
               END IF;
               IF INSTR(t_src(r_src.line),'@end:decl')>0 THEN
                  l_ano_found := TRUE;
                  t_src(r_src.line) := REPLACE(t_src(r_src.line),'@end:decl','');
               END IF;
            END LOOP;
            IF l_ano_found THEN
               -- Fix tag anomalies if any (@beg: instead of @begin:)
               dbms_output.put_line('Fixing wrong tags in '||l_object_type||' '||l_object_name||'...');
               t_src(0) := 'CREATE OR REPLACE ';
--             FOR i IN t_src.FIRST..t_src.LAST LOOP
--                dbms_output.put_line(t_src(i));
--             END LOOP;
               l_cursor := dbms_sql.open_cursor;
               dbms_sql.parse(l_cursor, t_src, t_src.FIRST, t_src.LAST, TRUE, dbms_sql.native);
               l_count := dbms_sql.execute(l_cursor);
               dbms_sql.close_cursor(l_cursor);
            END IF;
         END IF;
         -- Generate extension package from template
         -- This preserves existing custom code if any
         dbms_output.put_line('Generating package '||l_object_type||' '||l_object_name||' from template...');
         gen_utility.generate(p_source=>l_object_type||' '||l_object_name||'_tpl',p_options=>'-f',p_target=>l_object_type||' '||l_object_name);
      ELSE
         -- Code generator is not installed
         -- Get code of the template
         t_src.DELETE;
         FOR r_src IN c_src(l_object_type,l_object_name||'_tpl') LOOP
            IF SUBSTR(r_src.text,-1,1) = CHR(10) THEN
               t_src(r_src.line) := SUBSTR(r_src.text,1,LENGTH(r_src.text)-1);
            ELSE
               t_src(r_src.line) := r_src.text;
            END IF;
         END LOOP;
         IF t_src.COUNT<=0 THEN
            raise_application_error(-20000,'Source code of '||l_object_type||' '||l_object_name||'_tpl not found!');
         END IF;
         -- Generate extension package as a copy of the template
         t_src(0) := 'CREATE OR REPLACE ';
         t_src(1) := REPLACE(REPLACE(t_src(1),'_tpl'),'_TPL');
         dbms_output.put_line('Generating '||l_object_type||' '||l_object_name||' as a copy of the template...');
--         FOR i IN t_src.FIRST..t_src.LAST LOOP
--            dbms_output.put_line(t_src(i));
--         END LOOP;
         l_cursor := dbms_sql.open_cursor;
         dbms_sql.parse(l_cursor, t_src, t_src.FIRST, t_src.LAST, TRUE, dbms_sql.native);
         l_count := dbms_sql.execute(l_cursor);
         dbms_sql.close_cursor(l_cursor);
      END IF;
   END LOOP;
   -- Drop the template which is no more necessary
   EXECUTE IMMEDIATE 'DROP PACKAGE '||l_object_name||'_tpl';
END;
/
