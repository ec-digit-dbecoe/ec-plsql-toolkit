create or replace PACKAGE BODY ds_utility AS
   ---
   -- Revision History
   -- Ver   Who      When        What
   -- 1.0   deboiph  xx/04/2004  Initial version
   -- 1.1   deboiph  02/09/2004  Add possibility to specify a list of col to extract
   -- 1.2   deboiph  22/09/2004  Miscellaneous changes (see history.txt)
   -- 1.3   deboiph  05/09/2005  Added support for default data set
   --                            Added support for refresh (upsert)
   --                            Added support for views
   -- 1.3.1 deboiph  05/09/2005  Added support for cloning a data set definition
   -- 1.4   deboiph  27/10/2006  Added support for exporting via a script
   -- 1.5   deboiph  19/06/2008  Added support for captured data set
   -- 1.6   deboiph  25/08/2016  Added rowid to records captured via triggers
   --                            Exclude MATERIALIZED VIEWS from data set tables
   --                            Exclude T_GEOMETRY data type for columns
   -- 1.6   deboiph  27/12/2016  Factorise code in a single proc: handle_data_set()
   --                            Isolated global variables into new DS_UTILITY_VAR
   --                            Added support for more data types
   --                            Added possibility to force column value
   -- 1.6.1 jeunibe  05/05/2017  Added merge feature in DIRECT method
   -- 1.6.2 deboiph  20/09/2019  Bug fixing
   -- 1.7.0 deboiph  10/10/2019  Added job for captured operations forwarding
   -- 1.7.1 deboiph  23/10/2019  Bug fixing
   -- 1.7.2 deboiph  24/10/2019  Added support for XMLTYPE
   -- 1.7.3 deboiph  26/03/2020  Set batchsize, commitbatch and dateformat for XML
   -- 1.7.4 deboiph  30/03/2020  Added con_id in ds_records
   --                xx/04/2020  Added regexp pattern matching
   --                xx/04/2020  Fixed optimization in extract rowids
   --                22/04/2020  Columns list is now taken into account in data capture
   --                23/04/2020  Removed ds_sequences table (seq moved to ds_tables)
   --                04/05/2020  Added export of captured DML as scripts
   -- 1.7.5 deboiph  10/06/2020  Bug fixing
   -- 21.0  deboiph  ../../2021  Use PL/SQL installer
   -- 21.1  deboiph  25/08/2021  Better detection of true master/detail relationships
   --                            (identifying relationships)
   -- 23.0  deboiph  08/03/2023  Prefix query aliases with "ds_" to prevent collisions
   ---
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_description IN VARCHAR2
   ) IS
   
   BEGIN
      IF NOT p_condition THEN
         raise_application_error(-20000,'Assertion failed: '||p_description);
      END IF;
   END;
   ---
   -- Set context
   ---
   PROCEDURE set_context (
      p_attribute IN VARCHAR2
     ,p_value IN VARCHAR2
   )
   IS
      -- Context should be created with the following DDL:
      -- EXECUTE IMMEDIATE 'CREATE OR REPLACE CONTEXT '||LOWER(USER)||'_ctx USING sp2_app_krn';
   BEGIN
      sys.dbms_session.set_context(LOWER(USER)||'_ctx',p_attribute,p_value);
   END;
   ---
   -- Get context
   ---
   FUNCTION get_context (
      p_attribute IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN sys_context(LOWER(USER)||'_ctx',p_attribute);
   END;
   ---
   -- Set current user
   ---
   PROCEDURE set_user (
      p_user IN VARCHAR2
   )
   IS
   BEGIN
      ds_utility_var.g_user := p_user;
   END;
   ---
   -- Get current user
   ---
   FUNCTION get_user
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN NVL(ds_utility_var.g_user,USER);
   END;
--
--#begin public
/**
* Define name of schema containing data to extract. This allows the data
* set utility to be installed in a separate schema whilst being able
* to access objects of another schema.
* @param p_owner object owner
*/
   PROCEDURE set_source_schema (
      p_owner IN sys.all_objects.owner%TYPE
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_owner := UPPER(p_owner);
      assert(ds_utility_var.g_owner IS NOT NULL,'Source schema cannot be NULL');
   END;
--
--#begin public
/**
* Define list of message types that can be displayed.
* Message types are (I)nformation, (W)arning, (E)rror, (D)ebug, (S)ql statements
* @param p_msg_mask message mask (default is WE)
*/
   PROCEDURE set_message_mask (
      p_msg_mask IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_msg_mask := UPPER(SUBSTR(p_msg_mask,1,5));
   END;
--
--#begin public
/**
* Turn test mode on/off. In test mode, DDL are displayed instead of being executed.
* @param p_test_mode test mode (TRUE/FALSE, default is FALSE)
*/
   PROCEDURE set_test_mode (
      p_test_mode IN BOOLEAN
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_test_mode := p_test_mode;
   END;
--
--#begin public
/**
* Turn time display on/off. Time is displayed in debug messages only.
* @param p_show_time show time (TRUE/FALSE, default is FALSE)
* @param p_time_mask format mask used to display time (default is DD/MM/YYYY HH24:MI:SS)
*/
   PROCEDURE show_time (
      p_show_time IN BOOLEAN
     ,p_time_mask IN VARCHAR2 := NULL
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_show_time := p_show_time;
      IF p_time_mask IS NOT NULL THEN
         ds_utility_var.g_time_mask := SUBSTR(p_time_mask,1,40);
      END IF;
   END;
--
--#begin public
/**
* Delete output of data set utility
*/
   PROCEDURE delete_output
--#end public
   IS
      PRAGMA autonomous_transaction;
   BEGIN
      DELETE ds_output;
      ds_utility_var.g_out_line := NULL;
      COMMIT;
   END;
   ---
   -- Log text
   ---
   PROCEDURE log (
      p_text IN VARCHAR2
     ,p_new_line BOOLEAN := FALSE
   ) IS
      PRAGMA autonomous_transaction;
      -- Cursor to get last line number
      CURSOR c_out IS
         SELECT NVL(MAX(line),1)
           FROM ds_output
      ;
   BEGIN
      -- Get last line number
      IF ds_utility_var.g_out_line IS NULL THEN
         OPEN c_out;
         FETCH c_out INTO ds_utility_var.g_out_line;
         CLOSE c_out;
      END IF;
      assert(ds_utility_var.g_out_line IS NOT NULL,'Cannot guess line number');
      -- Try to append first
      UPDATE ds_output
         SET text = text || p_text
       WHERE line = ds_utility_var.g_out_line;
      -- Insert if not found
      IF SQL%NOTFOUND THEN
         INSERT INTO ds_output (
            line, text
         ) VALUES (
            ds_utility_var.g_out_line, p_text
         );
      END IF;
      -- Increment line number if required
      IF p_new_line THEN
         ds_utility_var.g_out_line := ds_utility_var.g_out_line + 1;
      END IF;
      -- Save work
      COMMIT;
   END;
--
--#begin public
/**
* Put a text on the specified output
* Split lines over 255 characters
*/
   PROCEDURE put (
      p_text IN VARCHAR2
     ,p_new_line IN BOOLEAN := FALSE
     ,p_output IN VARCHAR2 := 'DBMS_OUTPUT' -- or DS_OUTPUT
   )
--#end public
   IS
      l_str VARCHAR2(10);
      l_pos INTEGER;
      l_len INTEGER;
      l_max_line INTEGER;
   BEGIN
      IF p_output = 'DBMS_OUTPUT' THEN
         l_max_line := 32767; -- 255 before 11g
      ELSIF p_output = 'DS_OUTPUT' THEN
         l_max_line := 3600; -- 10% for UTF8 cs
      ELSE
         assert(FALSE,'Invalid output ('||p_output||')');
      END IF;
      l_str := CHR(13)||CHR(10);
      l_pos := NVL(INSTR(p_text,l_str),0);
      IF l_pos <= 0 THEN
         l_str := CHR(10);
         l_pos := NVL(INSTR(p_text,l_str),0);
      END IF;
      IF l_pos > 0 THEN
         put(SUBSTR(p_text,1,l_pos-1),TRUE,p_output);
         put(SUBSTR(p_text,l_pos+LENGTH(l_str)),p_new_line,p_output);
      ELSE
         l_len := NVL(LENGTH(p_text),0);
         IF l_len > l_max_line THEN
            put(SUBSTR(p_text,1,l_max_line-1)||'\',TRUE,p_output);
            put(SUBSTR(p_text,l_max_line),p_new_line,p_output);
         ELSE
            IF p_output = 'DBMS_OUTPUT' THEN
               IF p_new_line THEN
                  -- !!! no line is output if text is empty !!!
                  sys.dbms_output.put_line(p_text);
               ELSE
                  sys.dbms_output.put(p_text);
               END IF;
            ELSIF p_output = 'DS_OUTPUT' THEN
               log(p_text,p_new_line);
            ELSE
               assert(FALSE,'Invalid output ('||p_output||')');
            END IF;
         END IF;
      END IF;
   END;
   ---
   -- Put a line
   ---
   PROCEDURE put_line (
      p_text IN VARCHAR2
     ,p_output IN VARCHAR2 := 'DBMS_OUTPUT' -- or DS_OUTPUT
   )
   IS
   BEGIN
      put(p_text, TRUE, p_output);
   END;
   ---
   -- Show message
   ---
   PROCEDURE show_message (
      p_type IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL, Result/Rowcount
     ,p_text IN VARCHAR2 -- message text
     ,p_new_line IN BOOLEAN := TRUE
   ) IS
      l_type VARCHAR2(1) := UPPER(SUBSTR(p_type,1,1));
   BEGIN
      IF INSTR(ds_utility_var.g_msg_mask,l_type) <= 0 AND l_type != 'T' THEN
         -- Do not display
         RETURN;
      END IF;
      IF l_type = 'I' THEN
         put('Info: ',FALSE);
      ELSIF l_type = 'W' THEN
         put('Warning: ',FALSE);
      ELSIF l_type = 'E' THEN
         put('Error: ',FALSE);
      END IF;
      IF l_type = 'D' THEN
        IF ds_utility_var.g_show_time AND ds_utility_var.g_time_mask IS NOT NULL THEN
           put(TO_CHAR(SYSDATE,ds_utility_var.g_time_mask)||' '||p_text, p_new_line);
        ELSE
           put(p_text, p_new_line);
        END IF;
      ELSE
         put(p_text, p_new_line);
      END IF;
      IF l_type = 'S' THEN
         put('/', p_new_line);
      END IF;
   END;
   ---
   -- Execute dynamic SQL statement
   ---
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   ) RETURN INTEGER
   IS
      l_count INTEGER;
   BEGIN
      show_message('S',p_sql);
      IF p_using IS NOT NULL THEN
         show_message('S',CHR(10)||'USING'||CHR(10)||p_using);
      END IF;
      IF ds_utility_var.g_test_mode
      THEN
         show_message('S','/'||CHR(10)||' ',TRUE);
         l_count := 0;
         show_message('R',CHR(10)||'rowcount=0 (test mode, not executed)');
      ELSE
         IF p_using IS NOT NULL THEN
            EXECUTE IMMEDIATE p_sql USING p_using;
         ELSE
            EXECUTE IMMEDIATE p_sql;
         END IF;
         l_count := SQL%ROWCOUNT;
         show_message('R',CHR(10)||'rowcount='||l_count);
      END IF;
      RETURN l_count;
   EXCEPTION
      WHEN OTHERS THEN
         IF NOT p_ignore THEN
            IF INSTR(ds_utility_var.g_msg_mask,'E') > 0 THEN
               show_message('T',p_sql);
               IF p_using IS NOT NULL THEN
                  show_message('T',CHR(10)||'USING'||CHR(10)||p_using);
               END IF;
               show_message('E',SQLERRM);
            END IF;
            RAISE;
         END IF;
         RETURN 0;
   END;
   ---
   -- Execute dynamic SQL statement
   ---
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   )
   IS
      l_ret INTEGER;
   BEGIN
      l_ret := execute_immediate(p_sql,p_ignore,p_using);
   END;
   ---
   -- Generate a data set definition id
   ---
   FUNCTION gen_set_id
   RETURN ds_data_sets.set_id%TYPE
   IS
      -- Cursor to generate a data set id
      CURSOR c_seq IS
         SELECT ds_set_seq.NEXTVAL
           FROM dual
         ;
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_set_id;
      CLOSE c_seq;
      RETURN l_set_id;
   END;
   ---
   -- Generate a constraint id
   ---
   FUNCTION gen_con_id
   RETURN ds_constraints.con_id%TYPE
   IS
      -- Cursor to generate a constraint id
      CURSOR c_seq IS
         SELECT ds_con_seq.NEXTVAL
           FROM dual
         ;
      l_con_id ds_constraints.con_id%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_con_id;
      CLOSE c_seq;
      RETURN l_con_id;
   END;
   ---
   -- Generate a table id
   ---
   FUNCTION gen_table_id
   RETURN ds_tables.table_id%TYPE
   IS
      -- Cursor to generate a data set id
      CURSOR c_seq IS
         SELECT ds_tab_seq.NEXTVAL
           FROM dual
         ;
      l_table_id ds_tables.table_id%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_table_id;
      CLOSE c_seq;
      RETURN l_table_id;
   END;
--
--#begin public
/**
* Create a new data set definition and return its id.
* Each data set is also identified by a unique name.
* The visible flag permits to show/hide the data set in/from the views used
* to preview data sets as well as security policies used to export them.
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger capture mode (XML[;FWD]|EXP) - FWD for captured operations forwarding
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      r_set ds_data_sets%ROWTYPE;
   BEGIN
      r_set.set_id := gen_set_id;
      r_set.set_name := p_set_name;
      r_set.visible_flag := NVL(p_visible_flag,'Y');
      r_set.capture_flag := NVL(p_capture_flag,'Y');
      r_set.capture_mode := NVL(p_capture_mode,'XML');
      r_set.capture_user := p_capture_user;
      r_set.user_created := USER;
      r_set.date_created := SYSDATE;
      INSERT INTO ds_data_sets VALUES r_set;
      RETURN r_set.set_id;
   END;
--
--#begin public
/**
* Create a new data set definition.
* Each data set is also identified by a unique name.
* The visible flag permits to show/hide the data set in/from the views used
* to preview data sets as well as security policies used to export them.
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger capture mode (XML[;FWD]|EXP) - FWD for captured operations forwarding
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
   )
--#end public
   IS
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      l_set_id := create_data_set_def(p_set_name,p_visible_flag,p_capture_flag,p_capture_mode,p_capture_user);
   END;
--
--#begin public
/**
* Clone an existing data set definition and return its id
* @param p_set_id       id of data set to clone
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger capture mode (XML[;FWD]|EXP) - FWD for captured operations forwarding
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      -- Cursor to browse tables of a data set
      CURSOR c_tab (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
      ;
      -- Cursor to browse constraints of a data set
      CURSOR c_con (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_constraints
          WHERE set_id = p_set_id
      ;
   BEGIN
      -- Clone data set
      FOR r_set IN c_set(p_set_id) LOOP
         r_set.set_id := gen_set_id;
         r_set.set_name := p_set_name;
         r_set.visible_flag := NVL(p_visible_flag,'Y');
         r_set.capture_flag := NVL(p_capture_flag,'Y');
         r_set.capture_mode := NVL(p_capture_mode,'XML');
         r_set.capture_user := p_capture_user;
         r_set.user_created := USER;
         r_set.date_created := SYSDATE;
         INSERT INTO ds_data_sets VALUES r_set;
         -- Clone tables
         FOR r_tab IN c_tab(p_set_id) LOOP
            r_tab.set_id := r_set.set_id;
            r_tab.table_id := gen_table_id;
            r_tab.extract_count := 0;
            r_tab.pass_count := 0;
            r_tab.group_count := 0;
            r_tab.table_data := NULL;
            INSERT INTO ds_tables VALUES r_tab;
         END LOOP;
         -- Clone constraints
         FOR r_con IN c_con(p_set_id) LOOP
            r_con.set_id := r_set.set_id;
            r_con.con_id := gen_con_id;
            r_con.extract_count := 0;
            INSERT INTO ds_constraints VALUES r_con;
         END LOOP;
         -- Return set id
         RETURN r_set.set_id;
      END LOOP;
      RETURN NULL;
   END;
--
--#begin public
/**
* Clone an existing data set definition.
* @param p_set_id       id of data set to clone
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger capture mode (XML[;FWD]|EXP) - FWD for captured operations forwarding
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
   )
--#end public
   IS
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      l_set_id := clone_data_set_def(p_set_id,p_set_name,p_visible_flag,p_capture_flag,p_capture_mode,p_capture_user);
   END;
   ---
   -- Tokenize columns list
   ---
   FUNCTION tokenize_columns_list (
      p_columns_list IN ds_tables.columns_list%TYPE
   )
   RETURN ds_utility_var.column_name_table
   IS
      l_tmp ds_tables.columns_list%TYPE := RTRIM(LTRIM(REPLACE(REPLACE(p_columns_list,CHR(10),' '),CHR(13),' ')));
      l_tab ds_utility_var.column_name_table;
      l_pos INTEGER;
   BEGIN
      WHILE l_tmp IS NOT NULL LOOP
         l_pos := INSTR(l_tmp,',');
         IF l_pos > 0 THEN
            l_tab(l_tab.COUNT+1) := LOWER(LTRIM(RTRIM(SUBSTR(l_tmp,1,l_pos-1))));
            l_tmp := SUBSTR(l_tmp,l_pos+1);
         ELSE
            l_tab(l_tab.COUNT+1) := LOWER(LTRIM(RTRIM(l_tmp)));
            l_tmp := NULL;
         END IF;
      END LOOP;
      RETURN l_tab;
   END;
--
--#begin public
/**
* Format a column list to get a proper layout
* @param p_columns_list    array of column names
* @param p_left_tab left   indentation
* @param p_indent_first_line indent first line (Y/N)?
* @param p_columns_per_line number of columns per line
*/
   FUNCTION format_columns_list (
      p_columns_list IN ds_tables.columns_list%TYPE
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN ds_tables.columns_list%TYPE
--#end public
   IS
      l_out ds_tables.columns_list%TYPE;
      l_tab ds_utility_var.column_name_table;
      l_pos INTEGER;
   BEGIN
      assert(p_columns_per_line > 0,'Columns per line must be > 0');
      l_tab := tokenize_columns_list(p_columns_list);
      FOR i IN 1..l_tab.COUNT LOOP
         IF MOD(i-1,p_columns_per_line) = 0 THEN
            IF l_out IS NOT NULL THEN
               l_out := l_out || CHR(10);
               l_out := l_out || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_out := l_out || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF i > 1 THEN
            l_out := l_out || ', ';
         END IF;
         l_out := l_out || l_tab(i);
      END LOOP;
      RETURN l_out;
   END;
   ---
   -- Get columns names and types of a given table
   ---
   PROCEDURE get_col_names_and_types (
      p_table_name IN sys.all_tab_columns.table_name%TYPE
     ,p_column_name IN sys.all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN sys.all_tab_columns.nullable%TYPE := NULL -- filter
     ,t_col_name OUT ds_utility_var.column_name_table
     ,t_col_type OUT ds_utility_var.column_type_table
     ,p_columns_list IN ds_tables.columns_list%TYPE := NULL
   )
   IS
      l_table_name VARCHAR2(30);
      l_pos INTEGER;
      -- Cursor to browse table columns
      CURSOR c_col (
         p_owner IN sys.all_tab_columns.owner%TYPE
        ,p_table_name IN sys.all_tab_columns.table_name%TYPE
        ,p_nullable IN sys.all_tab_columns.nullable%TYPE
        ,p_column_name IN sys.all_tab_columns.column_name%TYPE
      ) IS
         SELECT LOWER(col.column_name) column_name, col.data_type column_type
              , col.nullable, pkcol.position pk_position
           FROM sys.all_tab_columns col
           LEFT OUTER JOIN sys.all_constraints pk
             ON pk.owner = col.owner
            AND pk.table_name = col.table_name
            AND pk.constraint_type = 'P'
           LEFT OUTER JOIN sys.all_cons_columns pkcol
             ON pkcol.owner = pk.owner
            AND pkcol.constraint_name = pk.constraint_name
            AND pkcol.table_name = col.table_name
            AND pkcol.column_name = col.column_name
          WHERE col.owner = UPPER(p_owner)
            AND col.table_name = UPPER(p_table_name)
            AND (p_nullable IS NULL OR col.nullable = UPPER(p_nullable))
            AND (p_column_name IS NULL OR col.column_name LIKE UPPER(p_column_name) ESCAPE '~')
          ORDER BY col.column_id
      ;
   BEGIN
      l_pos := INSTR(p_table_name,'@');
      IF l_pos>0 THEN
         l_table_name := SUBSTR(p_table_name,1,l_pos-1); -- remove db_link name
      ELSE
         l_table_name := p_table_name;
      END IF;
      -- For each column
      FOR r_col IN c_col(ds_utility_var.g_owner,l_table_name,p_nullable,p_column_name) LOOP
         -- If columns list is provided, keep only: pk columns + mandatory columns + those listed
         IF NVL(p_columns_list,'*') = '*'
         OR INSTR(', '||p_columns_list||', ', ', '||r_col.column_name||', ') > 0
         OR r_col.nullable = 'N'
         OR r_col.pk_position IS NOT NULL
         THEN
            t_col_name(t_col_name.COUNT+1) := r_col.column_name;
            t_col_type(t_col_type.COUNT+1) := r_col.column_type;
         END IF;
      END LOOP;
   END;
   ---
   -- Get columns list of a given table
   ---
   FUNCTION get_table_columns2 (
      p_table_name IN sys.all_tab_columns.table_name%TYPE
     ,p_column_name IN sys.all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN sys.all_tab_columns.nullable%TYPE := NULL -- filter
   )
   RETURN ds_utility_var.column_name_table
   IS
      t_col_name ds_utility_var.column_name_table;
      t_col_type ds_utility_var.column_type_table;
   BEGIN
      get_col_names_and_types(p_table_name,p_column_name,p_nullable,t_col_name,t_col_type);
      RETURN t_col_name;
   END;
   ---
   -- Get string
   ---
   FUNCTION extract_string (
      p_string IN VARCHAR2
     ,p_index IN INTEGER := 1
     ,p_sep IN VARCHAR2 := '~~'
   ) RETURN VARCHAR2
   IS
      l_pos_from INTEGER;
      l_pos_to INTEGER;
      l_pos INTEGER;
      l_len INTEGER := LENGTH(p_sep);
   BEGIN
      IF NVL(p_index,0) <= 0 THEN
         RETURN NULL;
      END IF;
      l_pos_from := 1;
      FOR i IN 1..p_index-1 LOOP
         l_pos := INSTR(p_string,p_sep,l_pos_from);
         IF l_pos <= 0 THEN
            RETURN NULL;
         END IF;
         l_pos_from := l_pos + l_len;
      END LOOP;
      l_pos_to := INSTR(p_string,p_sep,l_pos_from);
      IF l_pos_to > 0 THEN
         RETURN SUBSTR(p_string,l_pos_from,l_pos_to-l_pos_from);
      ELSE
         RETURN SUBSTR(p_string,l_pos_from);
      END IF;
   END;
   ---
   -- Get column type
   ---
   FUNCTION get_column_type (
      p_table_name IN VARCHAR2
     ,p_column_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_col_type VARCHAR2(30);
   BEGIN
      IF ds_utility_var.g_table_name IS NULL OR p_table_name != ds_utility_var.g_table_name THEN
         -- Load name and type of columns in cache
         ds_utility_var.g_table_name := p_table_name;
         get_col_names_and_types(p_table_name,NULL,NULL,ds_utility_var.g_col_names,ds_utility_var.g_col_types);
      END IF;
      l_col_type := NULL;
      FOR i IN 1..ds_utility_var.g_col_names.COUNT LOOP
         l_col_type := ds_utility_var.g_col_types(i);
         EXIT WHEN ds_utility_var.g_col_names(i) = p_column_name;
         l_col_type := NULL;
      END LOOP;
      assert(l_col_type IS NOT NULL,'Cannot determine type of column '||p_table_name||'.'||p_column_name);
      RETURN l_col_type;
   END;
   ---
   -- Build select clause
   ---
   FUNCTION build_select_clause (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
   IS
      l_col_names ds_utility_var.column_name_table;
      l_select VARCHAR2(8000);
      l_col_type VARCHAR2(30);
      l_col_name VARCHAR2(30);
      l_tab_col VARCHAR2(61);
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         IF MOD(i-1,p_columns_per_line) = 0 THEN
            IF l_select IS NOT NULL THEN
               l_select := l_select || CHR(10);
               l_select := l_select || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_select := l_select || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF i > 1 THEN
            l_select := l_select || '||''~~''||';
         END IF;
         IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
            l_select := l_select || 'REPLACE(REPLACE('||l_col_name||','''''''',''''''''''''),''~'',''\~'')';
         ELSIF l_col_type = 'DATE' THEN
            l_select := l_select || 'TO_CHAR('||l_col_name||','''||ds_utility_var.g_time_mask||''')';
         ELSIF l_col_type LIKE 'TIMESTAMP%' THEN
            l_select := l_select || 'TO_CHAR('||l_col_name||','''||ds_utility_var.g_timestamp_mask||''')';
         ELSIF l_col_type = 'ROWID' THEN
            l_select := l_select || 'ROWIDTOCHAR('||l_col_name||')';
         ELSIF l_col_type = 'NUMBER' THEN
            l_tab_col := LOWER(p_table_name||'.'||l_col_name);
            IF ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NOT NULL THEN
               l_select := l_select || 'TRIM(TO_CHAR(' || l_col_name || '+' || TRIM(TO_CHAR(ds_utility_var.g_seq(l_tab_col).id_shift_value)) || '))';
            ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) AND ds_utility_var.g_map(l_tab_col).id_shift_value IS NOT NULL THEN
               l_select := l_select || 'TRIM(TO_CHAR(' || l_col_name || '+' || TRIM(TO_CHAR(ds_utility_var.g_map(l_tab_col).id_shift_value)) || '))';
            ELSE
               l_select := l_select || 'TRIM(TO_CHAR(' || l_col_name || '))';
            END IF;
         ELSE
            assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
         END IF;
      END LOOP;
      RETURN l_select;
   END;
--
--#begin public
/**
* Force the value of a given column during a certain operation
* @param p_tab_name     table_name
* @param p_col_name     column_name
* @param p_expr         expression
* @param p_op           for operation (I/U)
*/
   PROCEDURE force_column_value (
      p_tab_name IN VARCHAR2 -- table name
    , p_col_name IN VARCHAR2 -- column name
    , p_expr IN VARCHAR2 -- replacement expression
    , p_oper IN VARCHAR2 := NULL -- for operation: I/U
   )
--#end public
   IS
   BEGIN
      assert(NVL(UPPER(p_oper),'%') IN ('I','U','%'), 'Error: operation must be I)insert or U)pdate');
      ds_utility_var.g_rep(NVL(UPPER(p_tab_name),'%')||'.'||NVL(UPPER(p_col_name),'%')||'#'||NVL(UPPER(p_oper),'%')) := NVL(p_expr,'@NULL');
   END;
   ---
   -- Get replacement value for given table column and operation 
   ---
   FUNCTION get_forced_column_value (
      p_tab_name IN VARCHAR2 -- table name
    , p_col_name IN VARCHAR2 -- column name
    , p_oper IN VARCHAR2     -- operation
    , p_data IN VARCHAR2
    , p_pk_size IN INTEGER
    , p_col_names ds_utility_var.column_name_table
   )
   RETURN VARCHAR2
   IS
      l_name VARCHAR2(100);
      l_col_val VARCHAR2(32767);
      l_pos_from INTEGER := 0;
      l_pos_to INTEGER;
      l_ch VARCHAR2(1);
      l_idx INTEGER;
   BEGIN
      assert(NVL(UPPER(p_oper),'%') IN ('I','U','%'), 'Error: operation must be I)insert or U)pdate');
      l_col_val := NULL;
      l_name := ds_utility_var.g_rep.FIRST;
      WHILE l_name IS NOT NULL LOOP
         IF NVL(UPPER(p_tab_name),'%')||'.'||NVL(UPPER(p_col_name),'%')||'#'||NVL(UPPER(p_oper),'%') LIKE l_name THEN
            l_col_val := ds_utility_var.g_rep(l_name);
            EXIT;
         END IF;
         l_name := ds_utility_var.g_rep.NEXT(l_name);
      END LOOP;
      -- Bind variables if any
      IF l_col_val IS NOT NULL THEN
         WHILE TRUE LOOP
            -- Search for bind variable (e.g. :var)
            l_pos_from := INSTR(l_col_val,':',l_pos_from+1);
            EXIT WHEN NVL(l_pos_from,0) <= 0; 
            -- Get bind variable name
            l_pos_to := l_pos_from + 1;
            WHILE TRUE LOOP
               l_ch := SUBSTR(l_col_val,l_pos_to,1);
               EXIT WHEN l_ch IS NULL;
               -- Name of bind variables is made up of characters, digits and underscore
               EXIT WHEN l_ch NOT BETWEEN 'A' AND 'Z'
                     AND l_ch NOT BETWEEN 'a' AND 'z'
                     AND (l_ch NOT BETWEEN '0' AND '9' OR l_pos_to > l_pos_from + 1) -- does not start with a digit
                     AND l_ch NOT IN ('_');
               l_pos_to := l_pos_to + 1;
            END LOOP;
            l_name := SUBSTR(l_col_val,l_pos_from+1,l_pos_to-l_pos_from-1);
            IF l_name IS NOT NULL THEN
               -- Search for column index
               l_idx := NULL;
               FOR K IN p_pk_size+1..p_col_names.COUNT LOOP
                  IF l_name = p_col_names(K - p_pk_size) THEN
                     l_idx := K;
                     EXIT;
                  END IF;
               END LOOP;
               -- Replace bind variable with column value (or column name when no data provided)
               IF l_idx IS NOT NULL THEN
                  l_col_val := SUBSTR(l_col_val,1,l_pos_from-1) -- part before :var
                            || CASE WHEN p_data IS NULL THEN '@'||p_col_names(l_idx) ELSE NVL(REPLACE(extract_string(p_data,l_idx),'\~','~'),'NULL')/*:var*/ END
                            || SUBSTR(l_col_val,l_pos_to); -- part after :var
               END IF;
            END IF;
         END LOOP;
      END IF;
      RETURN l_col_val;
   END;
   ---
   -- Build select statement for subquery of insert/update statement
   ---
   FUNCTION build_select_for_subquery (
      p_table_name IN VARCHAR2
     ,p_op IN VARCHAR2
     ,p_columns_list IN ds_tables.columns_list%TYPE
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_relocate_ids IN VARCHAR2 := 'Y'
   )
   RETURN ds_tables.columns_list%TYPE
   IS
      l_out ds_tables.columns_list%TYPE;
      l_col_names ds_utility_var.column_name_table;
      l_col_val VARCHAR2(32767);
      l_col_name VARCHAR2(30);
      l_col_type VARCHAR2(30);
      l_tab_col VARCHAR2(61);
      l_db_link VARCHAR2(31);
   BEGIN
      l_db_link := CASE WHEN p_db_link IS NULL THEN NULL ELSE '@'||p_db_link END;
      assert(p_columns_per_line > 0,'Columns per line must be > 0');
      l_col_names := tokenize_columns_list(p_columns_list);
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         IF MOD(i-1,p_columns_per_line) = 0 THEN
            IF l_out IS NOT NULL THEN
               l_out := l_out || CHR(10);
               l_out := l_out || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_out := l_out || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF i > 1 THEN
            l_out := l_out || ', ';
         END IF;
         l_col_val := get_forced_column_value(p_table_name,l_col_name,p_op,NULL,0,l_col_names);
         IF SUBSTR(l_col_val,1,1) = '@' THEN
            l_col_val := SUBSTR(l_col_val,2);
            l_col_type := 'NO-FORMATTING';
         END IF;
         IF l_col_val IS NULL THEN
            l_col_val := l_col_name;
         ELSE
            IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
               l_col_val := '''' || l_col_val || '''';
            ELSIF l_col_type = 'DATE' THEN
               l_col_val := 'TO_DATE('''||l_col_val||''','''||ds_utility_var.g_time_mask||''')';
            ELSIF l_col_type LIKE 'TIMESTAMP%' THEN
               l_col_val := 'TO_TIMESTAMP('''||l_col_val||''','''||ds_utility_var.g_timestamp_mask||''')';
            ELSIF l_col_type = 'ROWID' THEN
               l_col_val := 'CHARTOROWID('''||l_col_val||''')';
            ELSIF l_col_type = 'NUMBER' THEN
               NULL; -- keep l_col_val as is
            ELSIF l_col_type = 'NO-FORMATTING' THEN
               NULL; -- keep l_col_val as is
            ELSE
               assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
            END IF;
         END IF;
         l_tab_col := LOWER(p_table_name||'.'||l_col_name);
         IF p_relocate_ids = 'Y' AND l_col_type = 'NUMBER' THEN
            IF ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NULL THEN
               l_col_val := 'ds_utility.set_identifier'||l_db_link||'(' || ds_utility_var.g_seq(l_tab_col).table_id || ',' || l_col_val || ',' || LOWER(ds_utility_var.g_seq(l_tab_col).sequence_name) || '.nextval'||l_db_link||')';
            ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) AND ds_utility_var.g_map(l_tab_col).id_shift_value IS NULL THEN
               l_col_val := 'ds_utility.get_identifier'||l_db_link||'(' || ds_utility_var.g_map(l_tab_col).table_id || ',' || l_col_val || ')';
            END IF;
         END IF;
         l_out := l_out || l_col_val;
      END LOOP;
      RETURN l_out;
   END;
   ---
   -- Build "values" clause of an insert
   ---
   FUNCTION build_values_clause (
      p_table_name IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
     ,p_left_tab IN INTEGER := 2
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
   )
   RETURN VARCHAR2
   IS
      l_col_names ds_utility_var.column_name_table;
      l_select VARCHAR2(32767);
      l_col_type VARCHAR2(30);
      l_col_name VARCHAR2(30);
      l_col_val VARCHAR2(32767);
      l_tab_col VARCHAR2(61);
      j INTEGER;
      l_db_link VARCHAR2(31);
   BEGIN
      l_db_link := CASE WHEN p_db_link IS NULL THEN NULL ELSE '@'||p_db_link END;
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      /* Browse all columns excepted leading pk columns */
      FOR i IN p_pk_size+1..l_col_names.COUNT LOOP
         j := i - p_pk_size;
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         IF MOD(j-1,p_columns_per_line) = 0 THEN
            IF l_select IS NOT NULL THEN
               l_select := l_select || CHR(10);
               l_select := l_select || RPAD(' ',p_left_tab-2);
            ELSE
               IF p_indent_first_line = 'Y' THEN
                  l_select := l_select || RPAD(' ',p_left_tab);
               END IF;
            END IF;
         END IF;
         IF j > 1 THEN
            l_select := l_select || ', ';
         END IF;
         -- Search for replacement value
         l_col_val := get_forced_column_value(p_table_name,l_col_name,'I',p_data,0,l_col_names);
         IF SUBSTR(l_col_val,1,1) = '@' THEN
            l_col_val := SUBSTR(l_col_val,2);
            l_col_type := 'NO-FORMATTING';
         END IF; 
         -- Get value from data if empty
         IF l_col_val IS NULL THEN
            l_col_val := REPLACE(extract_string(p_data,i),'\~','~');
         END IF;
         IF l_col_val IS NULL THEN
            l_select := l_select || 'NULL';
         ELSE
            IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
               l_select := l_select || '''' || l_col_val || '''';
            ELSIF l_col_type = 'DATE' THEN
               l_select := l_select || 'TO_DATE('''||l_col_val||''','''||ds_utility_var.g_time_mask||''')';
            ELSIF l_col_type LIKE 'TIMESTAMP%' THEN
               l_select := l_select || 'TO_TIMESTAMP('''||l_col_val||''','''||ds_utility_var.g_timestamp_mask||''')';
            ELSIF l_col_type = 'ROWID' THEN
               l_select := l_select || 'CHARTOROWID('''||l_col_val||''')';
            ELSIF l_col_type = 'NUMBER' THEN
               l_tab_col := LOWER(p_table_name||'.'||l_col_name);
               IF ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NULL THEN
                  l_select := l_select || 'ds_utility.set_identifier(' || ds_utility_var.g_seq(l_tab_col).table_id || ',' || l_col_val || ',' || LOWER(ds_utility_var.g_seq(l_tab_col).sequence_name) || '.nextval'||l_db_link||')';
               ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) AND ds_utility_var.g_map(l_tab_col).id_shift_value IS NULL THEN
                  l_select := l_select || 'ds_utility.get_identifier(' || ds_utility_var.g_map(l_tab_col).table_id || ',' || l_col_val || ')';
               ELSE
                  l_select := l_select || l_col_val;
               END IF;
            ELSIF l_col_type = 'NO-FORMATTING' THEN
               l_select := l_select || l_col_val;
            ELSE
               assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
            END IF;
         END IF;
      END LOOP;
      RETURN l_select;
   END;
   ---
   -- Get number of columns in a list
   ---
   FUNCTION get_columns_list_size (
      p_columns_list IN VARCHAR2
   )
   RETURN INTEGER
   IS
      l_col_names ds_utility_var.column_name_table;
   BEGIN
      l_col_names := tokenize_columns_list(LOWER(p_columns_list));
      RETURN l_col_names.COUNT;
   END;
   ---
   -- Build "set" and "where" clause of an update
   ---
   FUNCTION build_set_and_where_clauses (
      p_table_name IN VARCHAR2
     ,p_sel_columns IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
     ,p_indent IN INTEGER := 0
   )
   RETURN VARCHAR2
   IS
      l_col_names ds_utility_var.column_name_table;
      l_col_name VARCHAR2(30);
      l_set VARCHAR2(32767);
      l_where VARCHAR2(32767);
      l_tab_col VARCHAR2(61);
      l_ws VARCHAR2(30);
      l_col_val VARCHAR2(32767);
      l_col_type VARCHAR2(30);
   BEGIN
      IF p_indent > 0 THEN
         l_ws := LPAD(' ', p_indent, ' ');
      END IF;
      l_col_names := tokenize_columns_list(LOWER(p_sel_columns));
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_name := l_col_names(i);
         l_col_type := get_column_type(p_table_name,l_col_name);
         l_col_val := NULL;
         -- Search for replacement value
         IF i > p_pk_size THEN
            l_col_val := get_forced_column_value(p_table_name,l_col_name,'U',p_data,0,l_col_names);
            IF SUBSTR(l_col_val,1,1) = '@' THEN
               l_col_val := SUBSTR(l_col_val,2);
               l_col_type := 'NO-FORMATTING';
            END IF; 
         END IF;
         -- Get value from data if empty
         IF l_col_val IS NULL THEN
            l_col_val := REPLACE(extract_string(p_data,i),'\~','~');
         END IF;
         IF l_col_val IS NULL THEN
            l_col_val := 'NULL';
         ELSE
            IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
               l_col_val := '''' || l_col_val || '''';
            ELSIF l_col_type = 'DATE' THEN
               l_col_val := 'TO_DATE('''||l_col_val||''','''||ds_utility_var.g_time_mask||''')';
            ELSIF l_col_type LIKE 'TIMESTAMP%' THEN
               l_col_val := 'TO_TIMESTAMP('''||l_col_val||''','''||ds_utility_var.g_timestamp_mask||''')';
            ELSIF l_col_type = 'ROWID' THEN
               l_col_val := 'CHARTOROWID('''||l_col_val||''')';
            ELSIF l_col_type = 'NUMBER' THEN
--               IF i > p_pk_size THEN
                  l_tab_col := LOWER(p_table_name||'.'||l_col_name);
--                  IF FALSE/*No need to update pk*/ AND ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NULL THEN
                  IF ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NULL THEN
--                     l_col_val := 'ds_utility.set_identifier(' || ds_utility_var.g_seq(l_tab_col).table_id || ',' || l_col_val || ',' || LOWER(ds_utility_var.g_seq(l_tab_col).sequence_name) || '.nextval)';
                     l_col_val := 'ds_utility.get_identifier(' || ds_utility_var.g_seq(l_tab_col).table_id || ',' || l_col_val || ',' || LOWER(ds_utility_var.g_seq(l_tab_col).sequence_name) || '.nextval)';
                  ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) AND ds_utility_var.g_map(l_tab_col).id_shift_value IS NULL THEN
                     l_col_val := 'ds_utility.get_identifier(' || ds_utility_var.g_map(l_tab_col).table_id || ',' || l_col_val || ')';
                  END IF;
--               END IF;
            ELSIF l_col_type = 'NO-FORMATTING' THEN
               NULL;
            ELSE
               assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
            END IF;
         END IF;
         IF i <= p_pk_size THEN
            IF i = 1 THEN
               l_where := CHR(10) || l_ws || ' WHERE ';
            ELSE
               l_where := l_where || CHR(10) || l_ws || '   AND ';
            END IF;
            l_where := l_where || l_col_name || ' = ' || l_col_val;
         ELSE
            IF i = p_pk_size + 1 THEN
               l_set := CHR(10) || l_ws || '   SET ';
            ELSE
               l_set := l_set || CHR(10) || l_ws || '     , ';
            END IF;
            l_set := l_set || l_col_name || ' = ' || l_col_val;
         END IF;
      END LOOP;
      RETURN l_set || l_where;
   END;
--
--#begin public
/**
* Return list of columns of a given table
* @param p_table_name table name
* @param p_column_name column name filter
* @param p_nullable nullable property filter
*/
   FUNCTION get_table_columns (
      p_table_name IN sys.all_tab_columns.table_name%TYPE
     ,p_column_name IN sys.all_tab_columns.column_name%TYPE := NULL -- filter
     ,p_nullable IN sys.all_tab_columns.nullable%TYPE := NULL -- filter
   )
   RETURN ds_tables.columns_list%TYPE
--#end public
   IS
      l_tab ds_utility_var.column_name_table;
      l_columns_list ds_tables.columns_list%TYPE;
   BEGIN
      -- Get columns
      l_tab := get_table_columns2(p_table_name,p_column_name,p_nullable);
      -- For each column
      FOR i IN 1..l_tab.COUNT LOOP
         IF i > 1 THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || l_tab(i);
      END LOOP;
      RETURN l_columns_list;
   END;
--
--#begin public
/**
* Return list of columns of a given constraint
* @param p_constraint_name constraint name
* @param p_sorting_order sorting order: P)osition or N)ame
*/
   FUNCTION get_constraint_columns (
      p_constraint_name IN sys.all_cons_columns.constraint_name%TYPE
    , p_sorting_order IN VARCHAR2 := 'P' -- P)osition or N)ame
   )
   RETURN ds_tables.columns_list%TYPE
--#end public
   IS
      l_constraint_name VARCHAR2(30) := UPPER(p_constraint_name);
      l_sorting_order VARCHAR2(1) := UPPER(SUBSTR(p_sorting_order,1,1));
      -- Cursor to browse constraint columns
      CURSOR c_col (
         p_owner IN sys.all_cons_columns.owner%TYPE
        ,p_constraint_name IN sys.all_cons_columns.constraint_name%TYPE
        ,p_sorting_order IN VARCHAR2
      ) IS
         SELECT column_name
           FROM sys.all_cons_columns
          WHERE owner = p_owner
            AND constraint_name = p_constraint_name
          ORDER BY CASE WHEN p_sorting_order = 'P' THEN position ELSE 0 END
                 , column_name
      ;
      l_columns_list ds_tables.columns_list%TYPE;
      l_count INTEGER := 0;
   BEGIN
      -- Get from cache (only when sorting on position)
      IF l_sorting_order = 'P' AND ds_utility_var.g_ccol.EXISTS(l_constraint_name) THEN
         RETURN ds_utility_var.g_ccol(l_constraint_name);
      END IF;
      -- For each column
      FOR r_col IN c_col(ds_utility_var.g_owner,l_constraint_name,l_sorting_order) LOOP
         IF l_columns_list IS NOT NULL THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || LOWER(r_col.column_name);
         l_count := l_count + 1;
      END LOOP;
      -- Store in cache (only when sorting on position)
      IF l_sorting_order = 'P' THEN
         ds_utility_var.g_ccol(l_constraint_name) := l_columns_list;
      END IF;
      RETURN l_columns_list;
   END;
--
--#begin public
/**
* Return list of columns of a given index
* @param p_index_name index name
*/
   FUNCTION get_index_columns (
      p_index_name IN sys.all_ind_columns.index_name%TYPE
   )
   RETURN ds_tables.columns_list%TYPE
--#end public
   IS
      l_index_name VARCHAR2(30) := UPPER(p_index_name);
      -- Cursor to browse constraint columns
      CURSOR c_col (
         p_owner IN sys.all_cons_columns.owner%TYPE
        ,p_index_name IN sys.all_ind_columns.index_name%TYPE
      ) IS
         SELECT column_name
           FROM sys.all_ind_columns
          WHERE index_owner = p_owner
            AND index_name = p_index_name
          ORDER BY column_position
      ;
      l_columns_list ds_tables.columns_list%TYPE;
      l_count INTEGER := 0;
   BEGIN
      -- Note: index and constraint columns are stored in the same cache
      IF ds_utility_var.g_ccol.EXISTS(l_index_name) THEN
         RETURN ds_utility_var.g_ccol(l_index_name);
      END IF;
      -- For each column
      FOR r_col IN c_col(ds_utility_var.g_owner,l_index_name) LOOP
         IF l_columns_list IS NOT NULL THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || LOWER(r_col.column_name);
         l_count := l_count + 1;
      END LOOP;
      ds_utility_var.g_ccol(l_index_name) := l_columns_list;
      RETURN l_columns_list;
   END;
   ---
   -- Build join condition
   ---
   FUNCTION build_join_condition (
      p_columns_list IN ds_tables.columns_list%TYPE
     ,p_alias1 IN ds_tables.table_alias%TYPE
     ,p_alias2 IN ds_tables.table_alias%TYPE
     ,p_left_tab IN INTEGER := 0
     ,p_indent_first_line IN VARCHAR2 := 'N'
   )
   RETURN VARCHAR2
   IS
      l_tab ds_utility_var.column_name_table;
      l_out VARCHAR2(4000);
   BEGIN
      l_tab := tokenize_columns_list(p_columns_list);
      FOR i IN 1..l_tab.COUNT LOOP
         IF i > 1 THEN
            l_out := l_out || CHR(10) || RPAD(' ',p_left_tab-4) || 'AND ';
         ELSE
            IF p_indent_first_line = 'Y' THEN
               l_out := RPAD(' ',p_left_tab);
            END IF;
         END IF;
         l_out := l_out || p_alias1 || '.' || LOWER(l_tab(i)) || ' = ' || p_alias2 || '.' || LOWER(l_tab(i));
      END LOOP;
      RETURN l_out;
   END;
--
--#begin public
/**
* Get pk name of a given table
* @param p_table_name table name
* @return pk name
*/
   FUNCTION get_table_pk (
      p_table_name IN sys.all_constraints.table_name%TYPE
   ) RETURN VARCHAR2
--#end public
   IS
      l_table_name VARCHAR2(30) := UPPER(p_table_name);
      CURSOR c_con (
         p_owner sys.all_constraints.owner%TYPE
        ,p_table_name sys.all_constraints.table_name%TYPE
      )
      IS
         SELECT constraint_name
           FROM sys.all_constraints
          WHERE owner = p_owner
            AND table_name = p_table_name
            AND constraint_type = 'P'
         ;
      l_constraint_name sys.all_constraints.constraint_name%TYPE;
   BEGIN
      IF ds_utility_var.g_pk.EXISTS(l_table_name) THEN
         RETURN ds_utility_var.g_pk(l_table_name);
      END IF;
      OPEN c_con(ds_utility_var.g_owner,l_table_name);
      FETCH c_con INTO l_constraint_name;
      CLOSE c_con;
      ds_utility_var.g_pk(l_table_name) := l_constraint_name;
      RETURN l_constraint_name;
   END;
--
--#begin public
/**
* Normalise columns list i.e. handle optional BUT keyword
* (extended syntax is: SELECT * BUT <columns_list> FROM <table>)
* wildcards in exclusion list columns are allowed
* @param p_table_name   table name
* @param p_columns_list array of column names
* @return list of columns
*/
   FUNCTION normalise_columns_list (
      p_table_name IN ds_tables.table_name%TYPE
     ,p_columns_list IN ds_tables.columns_list%TYPE
   )
   RETURN ds_tables.columns_list%TYPE
--#end public
   IS
      l_inc_tab ds_utility_var.column_name_table;
      l_exc_tab ds_utility_var.column_name_table;
      l_tmp_tab ds_utility_var.column_name_table;
      l_inc_str VARCHAR2(4000);
      l_exc_str VARCHAR2(4000);
      l_out_str VARCHAR2(4000);
      l_tmp_str VARCHAR2(4000);
      l_pos INTEGER;
      l_idx INTEGER;
      l_found BOOLEAN;
   BEGIN
      l_pos := NVL(INSTR(p_columns_list,' BUT '),0);
      IF l_pos > 0 THEN
         l_inc_str := LTRIM(RTRIM(SUBSTR(p_columns_list,1,l_pos-1)));
         l_exc_str := LTRIM(RTRIM(SUBSTR(p_columns_list,l_pos+5)));
      ELSE
         l_inc_str := LTRIM(RTRIM(p_columns_list));
         l_exc_str := NULL;
      END IF;
      IF l_inc_str IS NOT NULL THEN
         -- Expand * wildcard
         IF l_inc_str = '*' THEN
            l_inc_tab := get_table_columns2(p_table_name);
         ELSE
            l_inc_tab := tokenize_columns_list(l_inc_str);
         END IF;
         -- Expand % wildcards (~ is used as escape character)
         FOR i IN 1..l_inc_tab.COUNT LOOP
            IF INSTR(l_inc_tab(i),'%') > 0 THEN
               l_tmp_tab := get_table_columns2(p_table_name,l_inc_tab(i));
               FOR j IN 1..l_tmp_tab.COUNT LOOP
                  l_found := FALSE;
                  FOR K IN 1..l_inc_tab.COUNT LOOP
                     l_found := l_tmp_tab(j) = l_inc_tab(K);
                     EXIT WHEN l_found;
                  END LOOP;
                  IF NOT l_found THEN
                     l_inc_tab(l_inc_tab.COUNT+1) := l_tmp_tab(j);
                  END IF;
               END LOOP;
               l_inc_tab(i) := NULL; -- will be deleted later on
            END IF;
         END LOOP;
         -- Perform inclusion list minus exclusion list
         IF l_exc_str IS NOT NULL THEN
            l_exc_tab := tokenize_columns_list(l_exc_str);
            FOR i IN 1..l_inc_tab.COUNT LOOP
               IF l_inc_tab(i) IS NULL THEN
                  l_inc_tab.DELETE(i);
                  GOTO next_i;
               END IF;
               FOR j IN 1..l_exc_tab.COUNT LOOP
                  IF l_inc_tab(i) LIKE l_exc_tab(j) ESCAPE '~' THEN
                     l_inc_tab.DELETE(i);
                     EXIT;
                  END IF;
               END LOOP;
               <<next_i>>
               NULL;
            END LOOP;
         END IF;
         -- Build columns list
         l_idx := l_inc_tab.FIRST;
         WHILE l_idx IS NOT NULL LOOP
            IF l_out_str IS NOT NULL THEN
               l_out_str := l_out_str || ', ';
            END IF;
            l_out_str := l_out_str || l_inc_tab(l_idx);
            l_idx := l_inc_tab.NEXT(l_idx);
         END LOOP;
      ELSE
         l_out_str := l_inc_str;
      END IF;
      RETURN l_out_str;
   END;
--
--#begin public
/**
* Get id of last created data set definition.
* @return               id of last created data set
*/
   FUNCTION get_last_data_set_def
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      CURSOR c_set IS
         SELECT MAX(set_id)
           FROM ds_data_sets
      ;
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      OPEN c_set;
      FETCH c_set INTO l_set_id;
      CLOSE c_set;
      RETURN l_set_id;
   END;
--
--#begin public
/**
* Get id of the data set having a given name.
* @param p_set_name name of data set to search for
* @return               id of data set having given name
*/
   FUNCTION get_data_set_def_by_name (
      p_set_name IN ds_data_sets.set_name%TYPE
   )
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      CURSOR c_set (
         p_set_name ds_data_sets.set_name%TYPE
      ) IS
         SELECT set_id
           FROM ds_data_sets
          WHERE set_name = p_set_name
      ;
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      OPEN c_set(p_set_name);
      FETCH c_set INTO l_set_id;
      CLOSE c_set;
      RETURN l_set_id;
   END;
--
--#begin public
/**
* Delete data set rowids previously extracted
* @param p_set_id       id of data set to clear, NULL for all
* @param p_table_name   name of table, NULL for all
*/
   PROCEDURE delete_data_set_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- Null for ALL
    , p_table_name IN ds_tables.table_name%TYPE := NULL -- Null for ALL
   )
--#end public
   IS
   BEGIN
      DELETE ds_records
       WHERE table_id IN (
                SELECT table_id
                  FROM ds_tables
                 WHERE (p_set_id IS NULL OR set_id = p_set_id)
                   AND (p_table_name IS NULL OR table_name = p_table_name)
             )
      ;
   END;
   ---
   -- Delete data set identifiers
   ---
   PROCEDURE delete_data_set_identifiers (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- Null for ALL
   ) IS
   BEGIN
      DELETE ds_identifiers
       WHERE table_id IN (
                SELECT table_id
                  FROM ds_tables
                 WHERE (p_set_id IS NULL OR set_id = p_set_id)
             )
      ;
   END;
--
--#begin public
/**
* Check if a capture forwarding job exists for the given data set
* @param p_set_id    id of the data set
* @return true if job exists, false otherwize
*/
  FUNCTION capture_forwarding_job_exists (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   RETURN BOOLEAN
--#end public
   IS
$if FALSE
$then
      -- Scheduler based solution doesn't work for the time being
      -- as an auto-commit is performed when job is created
      -- Waiting for a "no_commit" parameter in a subsequence release of Oracle
      CURSOR c_job IS
         SELECT job_name
           FROM user_scheduler_jobs
          WHERE job_name = REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)
      ;
$else
      -- dbms_job works as the job is not launched before the transaction is committed
      CURSOR c_job IS
         SELECT JOB
           FROM user_jobs
          WHERE what LIKE '--'||REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)||'%'
      ;
$end  
      r_job c_job%ROWTYPE;
      l_found BOOLEAN;
   BEGIN
      OPEN c_job;
      FETCH c_job INTO r_job;
      l_found := c_job%FOUND;
      CLOSE c_job;
      RETURN l_found;
   END;
--
--#begin public
/**
* Create a job for captured operations forwarding
* @param p_set_id    id of the data set
*/
   PROCEDURE create_capture_forwarding_job (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      l_job_id NUMBER;
   BEGIN
      assert(p_set_id IS NOT NULL,'Set id parameter is mandatory!');
      IF NOT capture_forwarding_job_exists(p_set_id) THEN
$if FALSE
$then
      -- The solution based on dbms_scheduler doesn't work
      -- as an auto-commit is performed when job is created
      -- Waiting for the "commit parameter" requested by the community!
         -- Only one instance of a job is created at a time
         sys.dbms_scheduler.create_job(
            job_name => REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)
          , job_type => 'PLSQL_BLOCK'
          , job_action => 'BEGIN ds_utility.rollforward_captured_data_set('||p_set_id||'); EXCEPTION WHEN OTHERS THEN NULL; END;'
          , start_date => SYSDATE+ds_utility_var.g_capture_job_delta
          , repeat_interval => 'FREQ=MINUTELY' --DAILY,HOURLY,MINUTELY,SECONDLY
          , enabled => TRUE
          , comments => 'Forward captured operations for data set '||p_set_id
         );
      ELSE
         -- Differ job start time by a few seconds to avoid too many runs
         sys.dbms_scheduler.set_attribute(NAME=>REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id), ATTRIBUTE=>'start_date', value=>SYSDATE+ds_utility_var.g_capture_job_delta);
$else
         -- Job is created but will not be launched until the transaction is committed
         sys.dbms_job.submit(
            JOB  => l_job_id
          , what =>'--'||REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)||CHR(10)||'BEGIN ds_utility.rollforward_captured_data_set('||p_set_id||'); COMMIT; EXCEPTION WHEN OTHERS THEN NULL; END;'
         );
$end
      END IF;
   END;
--
--#begin public
/**
* Drop the job created for captured operations forwarding
* @param p_set_id    id of the data set
*/
   PROCEDURE drop_capture_forwarding_job (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      CURSOR c_job IS
         SELECT JOB
           FROM user_jobs
          WHERE what LIKE '--'||REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)||'%'
      ;
      r_job c_job%ROWTYPE;
      l_found BOOLEAN;
   BEGIN
      assert(p_set_id IS NOT NULL,'Set id parameter is mandatory!');
$if FALSE
$then
      IF capture_forwarding_job_exists(p_set_id) THEN
         sys.dbms_scheduler.drop_job(
            job_name => REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)
         );
      END IF;
$else
      OPEN c_job;
      FETCH c_job INTO r_job;
      l_found := c_job%FOUND;
      CLOSE c_job;
      IF l_found THEN
         sys.dbms_job.remove(r_job.JOB);
      END IF;
$end
   END;
--
--#begin public
/**
* Clear content of given data set definition. This will delete the data set
* definition (tables and constraints) as well as extracted rowids.
* After this operation, data set definition still exists but is empty.
* @param p_set_id       id of data set to clear, NULL for all
*/
   PROCEDURE clear_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- Null for ALL
   )
--#end public
   IS
   BEGIN
      delete_data_set_rowids( p_set_id);
      delete_data_set_identifiers(p_set_id);
      DELETE ds_constraints
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      DELETE ds_tables
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      UPDATE ds_data_sets
         SET capture_seq = NULL
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
   END;
--
--#begin public
/**
* Delete the given data set definition including its content.
* @param p_set_id       id of data set to delete, NULL for all
*/
   PROCEDURE delete_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      drop_capture_forwarding_job(p_set_id);
      clear_data_set_def(p_set_id);
      DELETE ds_data_sets
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
   END;
--
--#begin public
/**
* Update data set definition properties. Set name and visible flag of given
* data set definition(s). Properties whose supplied value is NULL stay unchanged
* @param p_set_id       data set id, NULL for all
* @param p_set_name     data set name
* @param p_visible_flag visible flag
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger capture mode (XML|EXP)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE update_data_set_def_properties (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- NULL means all data sets
     ,p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := '~'
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := '~'
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := '~'
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE ds_data_sets
         SET set_name = NVL(p_set_name,set_name)
           , visible_flag = CASE WHEN p_visible_flag = '~' THEN visible_flag ELSE p_visible_flag END
           , capture_flag = CASE WHEN p_capture_flag = '~' THEN capture_flag ELSE p_capture_flag END
           , capture_mode = CASE WHEN p_capture_mode = '~' THEN capture_mode ELSE p_capture_mode END
           , capture_user = CASE WHEN p_capture_user = '~' THEN capture_user ELSE p_capture_user END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
   END;
--
--#begin public
/**
* Count records of all tables of a data set. By default, source row count
* is taken from database statistics that are normally computed on a daily
* basis. When statistics are not available or not up to date, table records
* can be counted by invoking this procedure.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE count_table_records (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
--#end public
   IS
      -- Cursor to browse tables of a data set
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT table_name
           FROM ds_tables
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            FOR UPDATE OF source_count
         ;
      l_count INTEGER;
   BEGIN
      -- For each table
      FOR r_tab IN c_tab(p_set_id) LOOP
         -- Count records
         EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||LOWER(r_tab.table_name)
                 INTO l_count;
         -- Update source count
         UPDATE ds_tables
            SET source_count = l_count
          WHERE CURRENT OF c_tab;
      END LOOP;
   END;
   ---
   -- Get table alias (from pk)
   ---
   FUNCTION get_table_alias (
      p_table_name IN sys.all_tables.table_name%TYPE
     ,p_table_id IN ds_tables.table_id%TYPE
   )
   RETURN VARCHAR2
   IS
      -- Cursor to get primary key
      CURSOR c_con (
         p_owner IN sys.all_tables.owner%TYPE
        ,p_table_name IN sys.all_tables.table_name%TYPE
        ,p_like_pattern IN VARCHAR2
        ,p_replace_pattern IN VARCHAR2
        ,p_constraint_type IN VARCHAR2
      ) IS
         SELECT DISTINCT REGEXP_REPLACE(constraint_name, p_like_pattern, p_replace_pattern) table_alias
           FROM sys.all_constraints
          WHERE owner = p_owner
            AND table_name = p_table_name
            AND INSTR(p_constraint_type,constraint_type)>0
            AND REGEXP_LIKE(constraint_name,p_like_pattern)
            AND REGEXP_REPLACE(constraint_name, p_like_pattern, p_replace_pattern) != constraint_name
          ORDER BY LENGTH(REGEXP_REPLACE(constraint_name, p_like_pattern, p_replace_pattern)) DESC
      ;
      l_alias VARCHAR2(30);
      l_found BOOLEAN;
   BEGIN
      IF p_table_name IS NULL THEN
         RETURN NULL;
      END IF;
      OPEN c_con(ds_utility_var.g_owner,p_table_name,ds_utility_var.g_alias_like_pattern,ds_utility_var.g_alias_replace_pattern,ds_utility_var.g_alias_constraint_type);
      FETCH c_con INTO l_alias;
      CLOSE c_con;
      IF l_alias IS NOT NULL AND l_alias NOT IN ('ALL','SET') AND LENGTH(l_alias)<=ds_utility_var.g_alias_max_length THEN
         -- Extract alias from primary key name
         -- Replace some reserved keywords (e.g. all)
         RETURN LOWER(l_alias);
      ELSIF p_table_id IS NOT NULL THEN
         -- Alias generated from table_id
         RETURN 't'||TO_CHAR(p_table_id);
      ELSE
         RETURN NULL;
      END IF;
   END;
   ---
   -- Insert a new table
   ---
   PROCEDURE insert_table (
      r_tab IN OUT ds_tables%ROWTYPE
   ) IS
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_owner sys.all_tables.owner%TYPE
        ,p_table_name ds_tables.table_name%TYPE
      ) IS
         SELECT ds_tab_seq.NEXTVAL table_id, num_rows
           FROM sys.all_tables
          WHERE owner = p_owner
            AND table_name LIKE p_table_name ESCAPE '~'
            AND table_name NOT IN (
                   SELECT table_name
                     FROM ds_tables
                    WHERE set_id = p_set_id
                )
         ;
   BEGIN
      -- Validate
      assert(r_tab.percentage IS NULL OR r_tab.extract_type = 'B','Percentage only allowed for Base table');
      assert(r_tab.row_limit IS NULL OR r_tab.extract_type = 'B','Row limit only allowed for Base table');
      -- Generate table id
      OPEN c_tab(r_tab.set_id,ds_utility_var.g_owner,r_tab.table_name);
      FETCH c_tab INTO r_tab.table_id, r_tab.source_count;
      CLOSE c_tab;
      -- Get table alias from pk name (if exists)
      r_tab.table_alias := get_table_alias(r_tab.table_name,r_tab.table_id);
      IF r_tab.pass_count IS NULL THEN
         r_tab.pass_count := 0;
      END IF;
      INSERT INTO ds_tables VALUES r_tab;
   END;
   ---
   -- Create a new constraint
   ---
   PROCEDURE insert_constraint (
      r_con IN OUT ds_constraints%ROWTYPE
   ) IS
   BEGIN
      -- Validate
      assert(r_con.where_clause IS NULL OR r_con.CARDINALITY='1-N','Filter only allowed for 1-N relationships');
      assert(r_con.percentage IS NULL OR r_con.CARDINALITY='1-N','Percentage only allowed for 1-N relationships');
      assert(r_con.row_limit IS NULL OR r_con.CARDINALITY='1-N','Row limit only allowed for 1-N relationships');
      -- Get next sequence available
      r_con.con_id := gen_con_id;
      -- Insert constraint
      r_con.extract_count := 0;
      INSERT INTO ds_constraints VALUES r_con;
   END;
   ---
   -- Get a table record based on its 
   ---
   PROCEDURE get_table (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE
     ,r_tab OUT ds_tables%ROWTYPE
   ) IS
      CURSOR c_tab (
         p_set_id IN ds_data_sets.set_id%TYPE
        ,p_table_name IN ds_tables.table_name%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND table_name = p_table_name
         ;
   BEGIN
      OPEN c_tab(p_set_id,p_table_name);
      FETCH c_tab INTO r_tab;
      IF c_tab%NOTFOUND THEN
         r_tab := NULL;
      END IF;
      CLOSE c_tab;
   END;
   ---
   -- Check that a constraint exists
   ---
   FUNCTION exists_constraint (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE
     ,p_cardinality IN ds_constraints.CARDINALITY%TYPE
   ) RETURN BOOLEAN IS
      CURSOR c_con (
         p_set_id IN ds_data_sets.set_id%TYPE
        ,p_constraint_name IN ds_constraints.constraint_name%TYPE
        ,p_cardinality IN ds_constraints.CARDINALITY%TYPE
      ) IS
         SELECT 'x'
           FROM ds_constraints
          WHERE set_id = p_set_id
            AND constraint_name = p_constraint_name
            AND (p_cardinality IS NULL OR CARDINALITY = p_cardinality)
            AND ROWNUM <= 1
      ;
      l_dummy VARCHAR2(1);
      l_found BOOLEAN;
   BEGIN
      OPEN c_con(p_set_id,p_constraint_name,p_cardinality);
      FETCH c_con INTO l_dummy;
      l_found := c_con%FOUND;
      CLOSE c_con;
      RETURN l_found;
   END;
   ---
   -- Get alias
   ---
   PROCEDURE get_aliases (
      r_tab_mst IN ds_tables%ROWTYPE
     ,r_tab_det IN ds_tables%ROWTYPE
     ,p_out_master_alias OUT ds_tables.table_alias%TYPE
     ,p_out_detail_alias OUT ds_tables.table_alias%TYPE
   ) IS
      l_master_alias ds_tables.table_alias%TYPE := NVL(r_tab_mst.table_alias,r_tab_mst.table_name);
      l_detail_alias ds_tables.table_alias%TYPE := NVL(r_tab_det.table_alias,r_tab_det.table_name);
   BEGIN
      IF l_master_alias = l_detail_alias THEN
         p_out_master_alias := SUBSTR(l_master_alias,1,28)||'_p';
         p_out_detail_alias := SUBSTR(l_detail_alias,1,28)||'_c';
      ELSE
         p_out_master_alias := l_master_alias;
         p_out_detail_alias := l_detail_alias;
      END IF;
   END;
   ---
   -- Build join clause given fk
   ---
   FUNCTION build_join_clause (
      p_master_table_name IN VARCHAR2
     ,p_detail_table_name IN VARCHAR2
     ,p_fk_name IN sys.all_constraints.constraint_name%TYPE
   ) RETURN VARCHAR2 IS
      -- Cursor to get constraint columns
      -- Given constraints are supposed to be compatible PK/FK
      CURSOR c_col (
         p_owner IN sys.all_constraints.owner%TYPE
        ,p_fk_name IN sys.all_constraints.constraint_name%TYPE
      ) IS
         SELECT LOWER(P.column_name) p_col_name, LOWER(c.column_name) c_col_name
           FROM sys.all_cons_columns P, sys.all_cons_columns c, sys.all_constraints K
          WHERE P.owner = p_owner
            AND c.owner = p_owner
            AND K.owner = p_owner
            AND K.constraint_name = UPPER(p_fk_name)
            AND P.constraint_name = K.r_constraint_name
            AND c.constraint_name = K.constraint_name
            AND c.position = P.position
      ;
      l_join VARCHAR2(4000) := NULL;
   BEGIN
      -- For each joined constraint column
      FOR r_col IN c_col(ds_utility_var.g_owner,p_fk_name)
      LOOP
         IF l_join IS NOT NULL THEN
            l_join := l_join || ' AND ';
         END IF;
         l_join := l_join || p_detail_table_name  || '.' || r_col.c_col_name || ' = '
                          || p_master_table_name || '.' || r_col.p_col_name;
      END LOOP;
      RETURN l_join;
   END;
--
--#begin public
/**
* Include some tables in the given data set. Add tables whose name matches
* the given pattern to the data set definition and set their properties
* to the values supplied. Properties can also be set at a later time using
* set_table_properties().
* @param p_set_id       data set id
* @param p_table_name   name of tables to include
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filtering condition
* @param p_percentage   percentage of rows to extract
* @param p_row_limit    maximum number of rows to extract
* @param p_recursive_level include detail tables up to the given depth
* @param p_order_by_clause sorting order
* @param p_columns_list list of columns
* @param p_det_table_name   pattern for detail tables to include
* @param p_optimize_flag    optimize details discovery (Y/N)
*/
   PROCEDURE include_tables (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE
     ,p_extract_type IN ds_tables.extract_type%TYPE := NULL
     ,p_where_clause IN ds_tables.where_clause%TYPE := NULL
     ,p_percentage IN ds_tables.percentage%TYPE := NULL
     ,p_row_limit IN ds_tables.row_limit%TYPE := NULL
     ,p_recursive_level IN INTEGER := NULL -- 0=infinite, >0=maximum
     ,p_order_by_clause IN ds_tables.order_by_clause%TYPE := NULL
     ,p_columns_list IN ds_tables.columns_list%TYPE := NULL
     ,p_det_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_optimize_flag IN VARCHAR2 := NULL
   )
--#end public
   IS
      -- Cursor to get tables to include
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_owner sys.all_objects.owner%TYPE
      ) IS
         SELECT /*ds_tab_seq.nextval table_id,*/ table_name, num_rows
              , p_extract_type, p_where_clause
           FROM sys.all_tables
          WHERE owner = p_owner
            AND (p_table_name IS NULL OR REGEXP_INSTR(p_table_name,'[\^\$\(\)\.\[\*\{\}]')>0 OR table_name LIKE p_table_name ESCAPE '~')
            AND (p_table_name IS NULL OR REGEXP_INSTR(p_table_name,'[\^\$\(\)\.\[\*\{\}]')=0 OR REGEXP_LIKE(table_name,p_table_name))
            AND table_name NOT IN (
                   SELECT table_name
                     FROM ds_tables
                    WHERE set_id = p_set_id
                )
            AND table_name NOT IN (
                   SELECT object_name
                     FROM sys.all_objects
                    WHERE object_type = 'MATERIALIZED VIEW'
                )
         ;
      -- Cursor to browse tables not processed yet
      CURSOR c_tab2 (
         p_set_id ds_tables.set_id%TYPE
        ,p_pass_count ds_tables.pass_count%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND pass_count = p_pass_count
      ;
      -- Cursor to browse one-to-many relationships
      CURSOR c_fk (
         p_owner IN sys.all_constraints.owner%TYPE
        ,p_mst_table_name IN sys.all_constraints.table_name%TYPE
        ,p_det_table_name IN sys.all_constraints.table_name%TYPE
      ) IS
         SELECT fk.table_name detail_table_name, fk.constraint_name
              , pk.table_name master_table_name, fk.DEFERRED
              , det.num_rows detail_source_count
           FROM sys.all_constraints fk
          INNER JOIN sys.all_constraints pk
             ON pk.owner = fk.owner
            AND pk.constraint_name = fk.r_constraint_name
            AND pk.table_name = p_mst_table_name
          INNER JOIN sys.all_tables det
             ON det.owner = fk.owner
            AND det.table_name = fk.table_name
          WHERE fk.owner = p_owner
            AND fk.constraint_type = 'R'
            AND (p_det_table_name IS NULL OR REGEXP_INSTR(p_det_table_name,'[\^\$\(\)\.\[\*\{\}]')>0 OR fk.table_name LIKE p_det_table_name ESCAPE '~')
            AND (p_det_table_name IS NULL OR REGEXP_INSTR(p_det_table_name,'[\^\$\(\)\.\[\*\{\}]')=0 OR REGEXP_LIKE(fk.table_name,p_det_table_name))
         ;
      r_tab_new ds_tables%ROWTYPE;
      r_tab_det ds_tables%ROWTYPE;
      r_con_new ds_constraints%ROWTYPE;
      l_master_alias ds_tables.table_alias%TYPE;
      l_detail_alias ds_tables.table_alias%TYPE;
      l_count INTEGER;
      l_pass_count INTEGER := 0;
   BEGIN
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Reset pass count
      UPDATE ds_tables
         SET pass_count = 0
       WHERE set_id = p_set_id
         AND NVL(pass_count,-1) != 0
      ;
      l_count := 0;
      -- For each table to include
      FOR r_tab IN c_tab(p_set_id,ds_utility_var.g_owner) LOOP
         r_tab_new := NULL;
         r_tab_new.set_id := p_set_id;
       --r_tab_new.table_id := r_tab.table_id;
         r_tab_new.table_name := r_tab.table_name;
         r_tab_new.source_count := r_tab.num_rows;
         r_tab_new.extract_type := NVL(p_extract_type,'P');
         r_tab_new.where_clause := p_where_clause;
         r_tab_new.percentage := p_percentage;
         r_tab_new.row_limit := p_row_limit;
         r_tab_new.pass_count := 1;
         r_tab_new.order_by_clause := p_order_by_clause;
         r_tab_new.columns_list := p_columns_list;
         insert_table(r_tab_new);
         l_count := l_count + 1;
      END LOOP;
      IF l_count > 0 THEN
         show_message('I',l_count||' tables created for '||p_table_name);
      END IF;
      -- Include detail tables if required
      IF p_recursive_level IS NOT NULL THEN
         l_count := 1;
      ELSE
         l_count := 0;
      END IF;
      WHILE l_count > 0 AND (p_recursive_level <= 0 OR l_pass_count < p_recursive_level) LOOP
         l_count := 0;
         l_pass_count := l_pass_count + 1;
         assert(l_pass_count<=1000,'Maximum number of iterations exceeded');
         FOR r_tab_mst IN c_tab2(p_set_id,l_pass_count) LOOP
            l_count := l_count + 1;
            FOR r_fk IN c_fk(ds_utility_var.g_owner,r_tab_mst.table_name,p_det_table_name) LOOP
               -- Optimization (if requested): don't include detail tables having less records than master table
               IF NVL(p_optimize_flag,'N')='Y' AND r_fk.detail_source_count < r_tab_mst.source_count THEN
                  show_message('I','Ignoring constraint '||r_fk.constraint_name||' as detail table as less records than master table');
                  GOTO next_fk;
               END IF;
               -- Check if detail table already exists
               get_table(p_set_id,r_fk.detail_table_name,r_tab_det);
               IF r_tab_det.table_name IS NULL THEN
                  r_tab_det := NULL;
                  r_tab_det.set_id := p_set_id;
                  r_tab_det.table_name := r_fk.detail_table_name;
                  r_tab_det.extract_type := 'P';
                  r_tab_det.pass_count := l_pass_count + 1;
                  insert_table(r_tab_det);
               END IF;
               -- Check if constraint already exists
               IF NOT exists_constraint(p_set_id,r_fk.constraint_name,'1-N') THEN
                  -- Create constraint
                  r_con_new := NULL;
                  r_con_new.set_id := p_set_id;
                  r_con_new.dst_table_name := r_fk.detail_table_name;
                  r_con_new.constraint_name := r_fk.constraint_name;
                  r_con_new.DEFERRED := r_fk.DEFERRED;
                  r_con_new.src_table_name := r_fk.master_table_name;
                  r_con_new.CARDINALITY := '1-N';
                  IF p_extract_type = 'B' THEN
                     r_con_new.extract_type := 'B';
                  ELSE
                     r_con_new.extract_type := 'P';
                  END IF;
                  get_aliases(r_tab_mst, r_tab_det, l_master_alias, l_detail_alias);
                  r_con_new.join_clause := build_join_clause(
                     l_master_alias --r_fk.master_table_name
                    ,l_detail_alias  --r_fk.detail_table_name
                    ,r_con_new.constraint_name
                  );
                  r_con_new.source_count := r_tab_det.source_count;
                  insert_constraint(r_con_new);
               END IF;
               <<next_fk>>
               NULL;
            END LOOP;
         END LOOP;
      END LOOP;
   END;
--
--#begin public
/**
* Exclude some tables from the given data set. Remove tables whose name matches
* the given pattern from the data set definition.
* @param p_set_id       data set id
* @param p_table_name   name of tables to exclude
*/
   PROCEDURE exclude_tables (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      DELETE ds_records
       WHERE table_id IN (
                SELECT table_id
                  FROM ds_tables
                 WHERE set_id = p_set_id
                   AND (p_table_name IS NULL OR REGEXP_INSTR(p_table_name,'[\^\$\(\)\.\[\*\{\}]')>0 OR table_name LIKE p_table_name ESCAPE '~')
                   AND (p_table_name IS NULL OR REGEXP_INSTR(p_table_name,'[\^\$\(\)\.\[\*\{\}]')=0 OR REGEXP_LIKE(table_name,p_table_name))
             )
      ;
      IF SQL%ROWCOUNT > 0 THEN
         show_message('I',SQL%ROWCOUNT||' records removed for '||p_table_name);
      END IF;
      DELETE ds_constraints
       WHERE set_id = p_set_id
         AND ((p_table_name IS NULL OR dst_table_name LIKE p_table_name ESCAPE '~') OR
              (p_table_name IS NULL OR src_table_name LIKE p_table_name ESCAPE '~'))
      ;
      IF SQL%ROWCOUNT > 0 THEN
         show_message('I',SQL%ROWCOUNT||' constraints removed for '||p_table_name);
      END IF;
      DELETE ds_tables
       WHERE set_id = p_set_id
         AND (p_table_name IS NULL OR table_name LIKE p_table_name ESCAPE '~')
      ;
      IF SQL%ROWCOUNT > 0 THEN
         show_message('I',SQL%ROWCOUNT||' tables removed for '||p_table_name);
      END IF;
   END;
--
--#begin public
/**
* Exclude some constraints from the given data set. Remove constraints
* whose name matches the given pattern from the data set definition.
* @param p_set_id       data set id
* @param p_constraint_name   name of constraints to exclude
* @param p_cardinality constraint cardinality
* @param p_md_cardinality_ok master/detail cardinality ok
* @param p_md_optionality_ok master/detail optionality ok
* @param p_md_uid_ok master/detail unique identifier ok
*/
   PROCEDURE exclude_constraints (
      p_set_id IN ds_constraints.set_id%TYPE
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_cardinality IN ds_constraints.CARDINALITY%TYPE := NULL
     ,p_md_cardinality_ok IN ds_constraints.md_cardinality_ok%TYPE := NULL
     ,p_md_optionality_ok IN ds_constraints.md_optionality_ok%TYPE := NULL
     ,p_md_uid_ok IN ds_constraints.md_uid_ok%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      -- First cut possible links with records
      UPDATE ds_records
         SET con_id = NULL
       WHERE con_id IN (
                SELECT con_id 
                  FROM ds_constraints
                 WHERE set_id = p_set_id
                   AND (p_constraint_name IS NULL OR constraint_name LIKE p_constraint_name ESCAPE '~')
                   AND (p_cardinality IS NULL OR CARDINALITY = p_cardinality)
                   AND (p_md_cardinality_ok IS NULL OR md_cardinality_ok = p_md_cardinality_ok)
                   AND (p_md_optionality_ok IS NULL OR md_optionality_ok = p_md_optionality_ok)
                   AND (p_md_uid_ok IS NULL OR md_uid_ok = p_md_uid_ok)
             )
      ;
      -- Then delete constraints
      DELETE ds_constraints
       WHERE set_id = p_set_id
         AND (p_constraint_name IS NULL OR constraint_name LIKE p_constraint_name ESCAPE '~')
         AND (p_cardinality IS NULL OR CARDINALITY = p_cardinality)
         AND (p_md_cardinality_ok IS NULL OR md_cardinality_ok = p_md_cardinality_ok)
         AND (p_md_optionality_ok IS NULL OR md_optionality_ok = p_md_optionality_ok)
         AND (p_md_uid_ok IS NULL OR md_uid_ok = p_md_uid_ok)
      ;
      IF SQL%ROWCOUNT > 0 THEN
         show_message('I',SQL%ROWCOUNT||' constraints removed for '||p_constraint_name);
      END IF;
   END;
--
--#begin public
/**
* Update table properties. Properties whose supplied value is NULL stay unchanged
* @param p_set_id data set id
* @param p_table_name of table(s)
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filter condition
* @param p_order_by_clause sorting order
* @param p_columns_list list of columns
* @param p_export_mode mode of export (I=Insert, U=Update, M=Upsert)
* @param p_source_schema schema hosting source table
* @param p_source_db_link database link to be used to access source table
* @param p_target_schema schema hosting target table
* @param p_target_db_link database link to be used to access target table
* @param p_target_table_name name of the table in target schema
* @param p_user_column_name name of column used to determine user
* @param p_sequence_name name of the sequence used to regenerate id
* @param p_id_shift_value value by which id must be shifted
*/
   PROCEDURE update_table_properties (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_extract_type IN ds_tables.extract_type%TYPE := '~'
     ,p_where_clause IN ds_tables.where_clause%TYPE := '~'
     ,p_percentage IN ds_tables.percentage%TYPE := -1
     ,p_row_limit IN ds_tables.row_limit%TYPE := -1
     ,p_order_by_clause IN ds_tables.order_by_clause%TYPE := '~'
     ,p_columns_list IN ds_tables.columns_list%TYPE := '~'
     ,p_export_mode IN ds_tables.export_mode%TYPE := '~'
     ,p_source_schema IN ds_tables.source_schema%TYPE := '~'
     ,p_source_db_link IN ds_tables.source_db_link%TYPE := '~'
     ,p_target_schema IN ds_tables.target_schema%TYPE := '~'
     ,p_target_db_link IN ds_tables.target_db_link%TYPE := '~'
     ,p_target_table_name IN ds_tables.target_table_name%TYPE := '~'
     ,p_user_column_name IN ds_tables.user_column_name%TYPE := '~'
     ,p_sequence_name IN ds_tables.sequence_name%TYPE := '~'
     ,p_id_shift_value IN ds_tables.id_shift_value%TYPE := 0
   )
--#end public
   IS
   BEGIN
      UPDATE ds_tables
         SET extract_type = CASE WHEN p_extract_type = '~' THEN extract_type ELSE p_extract_type END
           , where_clause = CASE WHEN p_where_clause = '~' THEN where_clause ELSE p_where_clause END
           , percentage = CASE WHEN p_percentage = -1 THEN percentage ELSE p_percentage END
           , row_limit = CASE WHEN p_row_limit = -1 THEN row_limit ELSE p_row_limit END
           , order_by_clause = CASE WHEN p_order_by_clause = '~' THEN order_by_clause ELSE p_order_by_clause END
           , columns_list = CASE WHEN p_columns_list = '~' THEN columns_list ELSE p_columns_list END
           , export_mode = CASE WHEN p_export_mode = '~' THEN export_mode ELSE p_export_mode END
           , source_schema = CASE WHEN p_source_schema = '~' THEN source_schema ELSE p_source_schema END
           , source_db_link = CASE WHEN p_source_db_link = '~' THEN source_db_link ELSE p_source_db_link END
           , target_schema = CASE WHEN p_target_schema = '~' THEN target_schema ELSE p_target_schema END
           , target_db_link = CASE WHEN p_target_db_link = '~' THEN target_db_link ELSE p_target_db_link END
           , target_table_name = CASE WHEN p_target_table_name = '~' THEN target_table_name ELSE p_target_table_name END
           , user_column_name = CASE WHEN p_user_column_name = '~' THEN user_column_name ELSE p_user_column_name END
           , sequence_name = CASE WHEN p_sequence_name = '~' THEN sequence_name ELSE p_sequence_name END
           , id_shift_value = CASE WHEN p_id_shift_value = 0 THEN id_shift_value ELSE p_id_shift_value END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND (p_table_name IS NULL OR table_name LIKE p_table_name ESCAPE '~')
      ;
   END;
--
--#begin public
/**
* Update constraint properties. Properties whose given value is NULL stay
* unchanged.
* @param p_set_id data set id
* @param p_constraint_name name of constraint(s)
* @param p_cardinality constraint cardinality
* @param p_extract_type type of extract (F=Full, B=Base, N=None, P=Part)
* @param p_where_clause filter condition
* @param p_percentage percentage of rows to extract
* @param p_row_limit maximum number of rows to extract
* @param p_order_by_clause sorting order
*/
   PROCEDURE update_constraint_properties (
      p_set_id IN ds_constraints.set_id%TYPE
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_cardinality IN ds_constraints.CARDINALITY%TYPE := NULL
     ,p_extract_type IN ds_constraints.extract_type%TYPE := '~'
     ,p_where_clause IN ds_constraints.CARDINALITY%TYPE := '~'
     ,p_percentage IN ds_constraints.percentage%TYPE := -1
     ,p_row_limit IN ds_constraints.row_limit%TYPE := -1
     ,p_order_by_clause IN ds_constraints.order_by_clause%TYPE := '~'
     ,p_deferred IN ds_constraints.deferred%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE ds_constraints
         SET where_clause = CASE WHEN p_where_clause = '~' THEN where_clause ELSE p_where_clause END
           , percentage = CASE WHEN p_percentage = -1 THEN percentage ELSE p_percentage END
           , row_limit = CASE WHEN p_row_limit = -1 THEN row_limit ELSE p_row_limit END
           , extract_type = CASE WHEN p_extract_type = '~' THEN extract_type ELSE p_extract_type END
           , order_by_clause = CASE WHEN p_order_by_clause = '~' THEN order_by_clause ELSE p_order_by_clause END
           , deferred = CASE WHEN p_deferred = '~' THEN deferred ELSE p_deferred END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND (p_constraint_name IS NULL OR constraint_name LIKE p_constraint_name ESCAPE '~')
         AND (p_cardinality IS NULL OR CARDINALITY = p_cardinality)
      ;
   END;
--
--#begin public
/**
* Include referential constraints (N-1) in the given data set. Recursively add all
* tables linked via many-to-one relationships to the data set definition.
* This will guarantee that the data set will be consistent (no foreign key violation).
* @param p_set_id       data set id
* @param p_table_name   name of table(s) to consider
* @param p_constraint_name      name of constraint(s) to consider
*/
   PROCEDURE include_referential_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
   )
--#end public
   IS
      -- Cursor to browse tables not processed yet
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_table_name IN ds_tables.table_name%TYPE := NULL
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND pass_count = 0
            AND (p_table_name IS NULL OR table_name LIKE p_table_name ESCAPE '~')
            FOR UPDATE OF pass_count
      ;
      -- Cursor to browse many-to-one relationships
      CURSOR c_fk (
         p_owner sys.all_constraints.owner%TYPE
        ,p_table_name sys.all_constraints.table_name%TYPE
        ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
      ) IS
         SELECT c.table_name detail_table_name, c.constraint_name
              , P.table_name master_table_name, c.DEFERRED
           FROM sys.all_constraints c, sys.all_constraints P
          WHERE c.owner = p_owner
            AND P.owner = p_owner
            AND c.table_name = p_table_name
            AND c.constraint_type = 'R'
            AND (p_constraint_name IS NULL OR c.constraint_name LIKE p_constraint_name ESCAPE '~')
            AND P.constraint_name = c.r_constraint_name
         ;
      r_con_new ds_constraints%ROWTYPE;
      r_tab_mst ds_tables%ROWTYPE;
      r_tab_det ds_tables%ROWTYPE;
      l_master_alias ds_tables.table_alias%TYPE;
      l_detail_alias ds_tables.table_alias%TYPE;
      l_cardinality ds_constraints.CARDINALITY%TYPE;
      l_count INTEGER := 1;
   BEGIN
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Reset pass count
      UPDATE ds_tables
         SET pass_count = 0
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND NVL(pass_count,-1) != 0
      ;
      -- While there are still tables to process
      WHILE l_count > 0 LOOP
         l_count := 0;
         FOR r_tab IN c_tab(p_set_id,p_table_name) LOOP
            show_message('D','Table: '||r_tab.table_name);
            l_count := l_count + 1;
            FOR r_fk IN c_fk(ds_utility_var.g_owner,r_tab.table_name,p_constraint_name) LOOP
               show_message('D','   FK: '||r_fk.constraint_name);
               -- Check if table already exists
               get_table(p_set_id,r_fk.detail_table_name,r_tab_det);
               IF r_tab_det.table_name IS NULL THEN
                  r_tab_det := NULL;
                  r_tab_det.set_id := p_set_id;
                  r_tab_det.table_name := r_fk.detail_table_name;
                  r_tab_det.extract_type := 'P';
                  show_message('D','   Addying dst table: '||r_tab_det.table_name);
                  insert_table(r_tab_det);
               END IF;
               get_table(p_set_id,r_fk.master_table_name,r_tab_mst);
               IF r_tab_mst.table_name IS NULL THEN
                  r_tab_mst := NULL;
                  r_tab_mst.set_id := p_set_id;
                  r_tab_mst.table_name := r_fk.master_table_name;
                  r_tab_mst.extract_type := 'P';
                  show_message('D','   Addying src table: '||r_tab_mst.table_name);
                  insert_table(r_tab_mst);
               END IF;
               -- Check if constraint already exists for foreign key
               IF NOT exists_constraint(p_set_id,r_fk.constraint_name,'N-1') THEN
                  -- Create constraint
                  r_con_new := NULL;
                  r_con_new.set_id := p_set_id;
                  r_con_new.dst_table_name := r_fk.master_table_name;
                  r_con_new.where_clause := NULL;
                  r_con_new.constraint_name := r_fk.constraint_name;
                  r_con_new.DEFERRED := r_fk.DEFERRED;
                  r_con_new.src_table_name := r_fk.detail_table_name;
                  r_con_new.CARDINALITY := 'N-1';
                  r_con_new.extract_type := 'P';
                  get_aliases(r_tab_mst, r_tab_det, l_master_alias, l_detail_alias);
                  r_con_new.join_clause := build_join_clause(
                     l_master_alias --r_fk.master_table_name
                    ,l_detail_alias  --r_fk.detail_table_name
                    ,r_con_new.constraint_name
                  );
                  r_con_new.source_count := r_tab_mst.source_count;
                  insert_constraint(r_con_new);
                  show_message('D','   Addying N-1 constraint: '||r_con_new.constraint_name);
               END IF;
            END LOOP;
            UPDATE ds_tables
               SET pass_count = pass_count + 1
             WHERE CURRENT OF c_tab;
         END LOOP;
      END LOOP;
      -- Optimisation:
      -- When a table is the destination of a single constraint
      -- don't include N-1 fk if 1-N fk of type B already exists
      -- Do not used this optimisation for tables with pig's ears
      -- (1-N will be used to find childs and N-1 to find parents)
      UPDATE ds_constraints
         SET extract_type = 'N'
       WHERE cardinality = 'N-1'
         AND extract_type != 'N'
         AND src_table_name != dst_table_name
         AND src_table_name IN (
               SELECT dst_table_name
                 FROM ds_constraints
                WHERE (extract_type = 'B' OR cardinality = 'N-1')
                  AND set_id = p_set_id
                GROUP BY dst_table_name
               HAVING COUNT(*) = 1
             )
         AND constraint_name IN (
                SELECT constraint_name
                  FROM ds_constraints
                 WHERE extract_type = 'B'
                   AND set_id = p_set_id
             )
        AND set_id = p_set_id;
      show_message('D',SQL%ROWCOUNT||' N-1 constraints excluded for optimization');
  END;
--
--#begin public
/**
* Include master/detail relationships (1-N) in the given data set.
* Add tables linked via 1-N relationships to the data set definition.
* @param p_set_id       data set id
* @param p_master_table_name    name of master table(s)
* @param p_detail_table_name     name of detail table(s)
* @param p_constraint_name      name of constraint(s)
* @param p_extract_type type of extract (B=Base, P=Part, N=None)
* @param p_where_clause         filter condition
* @param p_percentage   percentage of rows to extract
* @param p_row_limit    maximum number of rows to extract
*/
   PROCEDURE include_master_detail_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_master_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_detail_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_constraint_name IN ds_constraints.constraint_name%TYPE := NULL
     ,p_extract_type IN ds_constraints.extract_type%TYPE := NULL
     ,p_where_clause IN ds_constraints.where_clause%TYPE := NULL
     ,p_percentage IN ds_constraints.percentage%TYPE := NULL
     ,p_row_limit IN ds_constraints.row_limit%TYPE := NULL
   )
--#end public
   IS
      -- Cursor to browse foreign keys
      CURSOR c_fk (
         p_owner sys.all_constraints.owner%TYPE
        ,p_master_table_name sys.all_constraints.table_name%TYPE
        ,p_detail_table_name IN sys.all_constraints.table_name%TYPE
        ,p_constraint_name IN sys.all_constraints.constraint_name%TYPE
      ) IS
         SELECT c.table_name detail_table_name, c.constraint_name
              , P.table_name master_table_name, c.DEFERRED
           FROM sys.all_constraints c, sys.all_constraints P
          WHERE c.owner = p_owner
            AND P.owner = p_owner
            AND (p_master_table_name IS NULL OR P.table_name LIKE p_master_table_name ESCAPE '~')
            AND (p_detail_table_name IS NULL OR c.table_name LIKE p_detail_table_name ESCAPE '~')
            AND (p_constraint_name IS NULL OR c.constraint_name LIKE p_constraint_name ESCAPE '~')
            AND c.constraint_type = 'R'
            AND P.constraint_name = c.r_constraint_name
         ;
      r_tab_det ds_tables%ROWTYPE;
      r_tab_mst ds_tables%ROWTYPE;
      r_con_new ds_constraints%ROWTYPE;
      l_master_alias ds_tables.table_alias%TYPE;
      l_detail_alias ds_tables.table_alias%TYPE;
   BEGIN
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- For each master/detail constraint
      FOR r_fk IN c_fk(ds_utility_var.g_owner,p_master_table_name,p_detail_table_name,p_constraint_name) LOOP
         -- Check if table already exists
         get_table(p_set_id,r_fk.master_table_name,r_tab_mst);
         IF r_tab_mst.table_name IS NULL THEN
            r_tab_mst := NULL;
            r_tab_mst.set_id := p_set_id;
            r_tab_mst.table_name := r_fk.master_table_name;
            r_tab_mst.extract_type := 'P';
            insert_table(r_tab_mst);
         END IF;
         get_table(p_set_id,r_fk.detail_table_name,r_tab_det);
         IF r_tab_det.table_name IS NULL THEN
            r_tab_det := NULL;
            r_tab_det.set_id := p_set_id;
            r_tab_det.table_name := r_fk.detail_table_name;
            r_tab_det.extract_type := 'P';
            insert_table(r_tab_det);
         END IF;
         -- Check if constraint already exists for foreign key
         IF NOT exists_constraint(p_set_id,r_fk.constraint_name,'1-N') THEN
            -- Create constraint
            r_con_new := NULL;
            r_con_new.set_id := p_set_id;
            r_con_new.dst_table_name := r_fk.detail_table_name;
            r_con_new.where_clause := p_where_clause;
            r_con_new.percentage := p_percentage;
            r_con_new.row_limit := p_row_limit;
            r_con_new.constraint_name := r_fk.constraint_name;
            r_con_new.DEFERRED := r_fk.DEFERRED;
            r_con_new.src_table_name := r_fk.master_table_name;
            r_con_new.CARDINALITY := '1-N';
            r_con_new.extract_type := NVL(p_extract_type,'P');
            get_aliases(r_tab_mst, r_tab_det, l_master_alias, l_detail_alias);
            r_con_new.join_clause := build_join_clause(
               l_master_alias --r_fk.master_table_name
              ,l_detail_alias  --r_fk.detail_table_name
              ,r_con_new.constraint_name
            );
            r_con_new.source_count := r_tab_det.source_count;
            insert_constraint(r_con_new);
         END IF;
      END LOOP;
   END;
   ---
   -- Compute row limit
   ---
   FUNCTION compute_row_limit (
      p_row_limit IN INTEGER
     ,p_percentage IN INTEGER
     ,p_source_count IN INTEGER
   ) RETURN INTEGER
   IS
      l_row_limit INTEGER;
   BEGIN
      IF p_percentage IS NOT NULL THEN
         assert(p_source_count IS NOT NULL,'source count IS NOT NULL');
         l_row_limit := ROUND(p_source_count * p_percentage / 100);
         IF p_row_limit IS NOT NULL THEN
            l_row_limit := LEAST(l_row_limit,p_row_limit);
         END IF;
      ELSE
         l_row_limit := p_row_limit;
      END IF;
      RETURN l_row_limit;
   END;
   ---
   -- Extract base table(s)
   ---
   PROCEDURE extract_base_tables (
      p_set_id IN ds_data_sets.set_id%TYPE
   ) IS
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            AND extract_type = 'B'
          ORDER BY set_id, seq, table_name
         ;
      l_row_count INTEGER;
      l_row_limit INTEGER;
      l_sql VARCHAR2(4000);
   BEGIN
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Delete rowids
      DELETE ds_records
       WHERE table_id IN (
                SELECT table_id
                  FROM ds_tables
                 WHERE set_id = p_set_id
             )
      ;
      -- Reset pass count
      UPDATE ds_tables
         SET pass_count = 0
           , extract_count = 0
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND (NVL(pass_count,-1) != 0 OR NVL(extract_count,-1) != 0)
      ;
      -- Reset extract count
      UPDATE ds_constraints
         SET extract_count = 0
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND NVL(extract_count,-1) != 0
      ;
      -- Create records of base tables
      FOR r_tab IN c_tab(p_set_id) LOOP
         l_sql :=
'
INSERT INTO ds_records (
   table_id, record_rowid, pass_count, seq
)';
         l_row_limit := compute_row_limit(r_tab.row_limit,r_tab.percentage,r_tab.source_count);
         IF l_row_limit IS NOT NULL AND r_tab.order_by_clause IS NOT NULL THEN
            l_sql := l_sql ||
'
SELECT *
  FROM (';
         END IF;
         l_sql := l_sql ||
'
SELECT '||r_tab.table_id||', rowid, 1, 0
  FROM '||LOWER(r_tab.table_name)||'
 WHERE '||NVL(r_tab.where_clause,'1=1');
         IF l_row_limit IS NOT NULL THEN
            IF r_tab.order_by_clause IS NOT NULL THEN
               l_sql := l_sql ||
'
 ORDER BY '||r_tab.order_by_clause||'
)
 WHERE rownum <= '||l_row_limit;
            ELSE
               l_sql := l_sql ||
'
   AND rownum <= '||l_row_limit;
            END IF;
         END IF;
         l_row_count := execute_immediate(l_sql);
      END LOOP;
   END;
   ---
   -- Delete duplicate rows
   ---
   FUNCTION delete_duplicate_records (
      p_table_id ds_records.table_id%TYPE
    , p_pass_mult IN INTEGER
   )
   RETURN INTEGER
   IS
      -- Select records of a given table
      CURSOR c_rec (
         p_table_id ds_records.table_id%TYPE
       , p_pass_mult IN INTEGER
      ) IS
         SELECT *
           FROM ds_records
          WHERE table_id = p_table_id
            AND NVL(deleted_flag,'N') = 'N'
            FOR UPDATE OF pass_count
          ORDER BY record_rowid, pass_count * p_pass_mult /* +1 for ASC, -1 for DESC*/
      ;
      r_rec_prv ds_records%ROWTYPE := NULL;
      l_count INTEGER := 0;
   BEGIN
      FOR r_rec IN c_rec(p_table_id, p_pass_mult) LOOP
         -- Keep record with highest sequence if constrainst is immediate, lowest if deferred
         IF  r_rec.record_rowid = r_rec_prv.record_rowid
         THEN
            IF INSTR(ds_utility_var.g_msg_mask,'D') > 0 THEN
               -- Logical deletion (for debug purpose)
               UPDATE ds_records
                  SET deleted_flag = 'Y'
                WHERE CURRENT OF c_rec;
            ELSE
               -- Physical deletion
               DELETE FROM ds_records
                WHERE CURRENT OF c_rec;
            END IF;
            l_count := l_count + 1;
         END IF;
         r_rec_prv := r_rec;
      END LOOP;
      RETURN l_count;
   END;
   ---
   -- Define walk-through strategy
   ---
   PROCEDURE define_walk_through_strategy (
      p_set_id IN ds_data_sets.set_id%TYPE
   ) IS
      -- Cursor to browse tables with no masters
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND seq = 0
            AND (set_id, table_name) NOT IN (
                   SELECT ds_det.set_id, ds_det.table_name
                     FROM ds_constraints ds_con, ds_tables ds_det, ds_tables ds_mst
                    WHERE ds_con.set_id = p_set_id
                      AND ds_con.CARDINALITY = '1-N'
                      AND ds_con.extract_type != 'N'
                      AND ds_det.table_name = ds_con.dst_table_name
                      AND ds_det.set_id = ds_con.set_id
                      AND ds_mst.table_name = ds_con.src_table_name
                      AND ds_mst.set_id = ds_con.set_id
                      AND ds_mst.seq = 0
                      AND ds_con.dst_table_name != ds_con.src_table_name
                      AND ds_con.DEFERRED = 'IMMEDIATE'
                    UNION
                   SELECT ds_det.set_id, ds_det.table_name
                     FROM ds_constraints ds_con, ds_tables ds_det, ds_tables ds_mst
                    WHERE ds_con.set_id = p_set_id
                      AND ds_con.CARDINALITY = 'N-1'
                      AND ds_con.extract_type != 'N'
                      AND ds_det.table_name = ds_con.src_table_name
                      AND ds_det.set_id = ds_con.set_id
                      AND ds_mst.table_name = ds_con.dst_table_name
                      AND ds_mst.set_id = ds_con.set_id
                      AND ds_mst.seq = 0
                      AND ds_con.dst_table_name != ds_con.src_table_name
                      AND ds_con.DEFERRED = 'IMMEDIATE'
                )
            FOR UPDATE OF seq
         ;
      -- Cursor to check loop in table dependencies
      CURSOR c_dep (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT 'x'
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type != 'N'
            AND seq = 0
      ;
      l_table_count INTEGER := 1;
      l_seq INTEGER := 0;
      l_dummy VARCHAR2(1);
      l_found BOOLEAN;
      l_plunit VARCHAR2(30) := 'define_walk_through_strategy';
   BEGIN
      show_message('D','->'||l_plunit||'()');
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Reset pass count
      UPDATE ds_tables
         SET seq = 0
       WHERE set_id = p_set_id
         AND NVL(seq,-1) != 0
      ;
      WHILE l_table_count > 0 LOOP
         l_table_count := 0;
         l_seq := l_seq + 1;
         FOR r_tab IN c_tab(p_set_id) LOOP
            l_table_count := l_table_count + 1;
            show_message('D','table '||r_tab.table_name);
            UPDATE ds_tables
               SET seq = l_seq
             WHERE CURRENT OF c_tab
            ;
         END LOOP;
      END LOOP;
      -- Check loop in table dependencies
      OPEN c_dep(p_set_id);
      FETCH c_dep INTO l_dummy;
      l_found := c_dep%FOUND;
      CLOSE c_dep;
      assert(NOT l_found,'Loop in table dependencies detected');
      show_message('D','<-'||l_plunit||'()');
   END;
--
--#begin public
   ---
   -- Set remark of records (for debugging purpose)
   ---
   PROCEDURE set_record_remarks (
      p_set_id ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      -- Get tables of a data set (limited to those having a PK)
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT ds_tab.*
           FROM ds_tables ds_tab
          INNER JOIN user_constraints ds_con
             ON ds_con.owner = ds_utility_var.g_owner
            AND ds_con.table_name = ds_tab.table_name
            AND ds_con.constraint_type = 'P'
          WHERE set_id = p_set_id
      ;
      -- Get PK columns of a table
      CURSOR c_col (
         p_table_name IN VARCHAR2
      )
      IS
         SELECT LOWER(col.column_name) column_name, position
           FROM sys.all_constraints ds_con
          INNER JOIN sys.all_cons_columns col
             ON col.owner = ds_con.owner
            AND col.constraint_name = ds_con.constraint_name
          WHERE ds_con.owner = ds_utility_var.g_owner
            AND ds_con.table_name = p_table_name
            AND ds_con.constraint_type = 'P'
          ORDER BY col.position
      ;
      l_sql VARCHAR2(4000);
   BEGIN
      FOR r_tab IN c_tab(p_set_id) LOOP
         l_sql := 
'UPDATE ds_records ds_rec
   SET remark = (';
         FOR r_col IN c_col(r_tab.table_name) LOOP
            l_sql := l_sql || CHR(10)
                  || CASE WHEN r_col.position = 1 THEN '          SELECT ''' ELSE '              || '',' END
                  || r_col.column_name || '=''||' ||r_col.column_name;
         END LOOP;
         l_sql := l_sql ||
'
            FROM '||LOWER(r_tab.table_name)||'
           WHERE rowid = ds_rec.record_rowid
       )
 WHERE table_id = '||r_tab.table_id;
         execute_immediate(l_sql);
      END LOOP;
      FOR r_tab IN c_tab(p_set_id) LOOP
         l_sql :=
'UPDATE ds_records ds_rec
   SET remark = (';
         FOR r_col IN c_col(r_tab.table_name) LOOP
            l_sql := l_sql || CHR(10)
                  || CASE WHEN r_col.position = 1 THEN '          SELECT ds_rec.remark || '' <= ' ELSE '              || '',' END
                  || r_col.column_name || '=''||' ||r_col.column_name;
         END LOOP;
         l_sql := l_sql ||
'
            FROM '||LOWER(r_tab.table_name)||'
           WHERE rowid = ds_rec.source_rowid
       )
 WHERE con_id IN (
          SELECT ds_con.con_id
            FROM ds_constraints ds_con
           INNER JOIN ds_tables ds_tab
              ON ds_tab.set_id = ds_con.set_id
             AND ds_tab.table_name = ds_con.src_table_name
             AND ds_tab.table_id = '||r_tab.table_id||'
       )';
          execute_immediate(l_sql);
      END LOOP;
   END;
--
--#begin public
/**
* Extract rowids of records of the given data set. For each table that must
* be partially extracted (extract type P), identify records to extract
* and store their rowids. Tables that are fully extracted (extract type F)
* or not extracted at all (extract type N) are not part of this process.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE extract_data_set_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      -- Select tables having records to be processed
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
       , p_order INTEGER
      ) IS
         SELECT *
           FROM ds_tables ds_tab
          WHERE set_id = p_set_id
            AND extract_type != 'N'
            AND ((extract_type != 'F' AND
                 EXISTS (
                   SELECT 'x'
                     FROM ds_records ds_rec
                    WHERE ds_rec.table_id = ds_tab.table_id
                      AND ds_rec.pass_count = ds_tab.pass_count + 1
                      AND NVL(deleted_flag,'N') = 'N'
                )) OR
                (extract_type = 'F' AND pass_count = 0))
          ORDER BY seq * p_order, table_name
            FOR UPDATE OF pass_count
         ;
      -- Select constraints for a table
      CURSOR c_con (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_table_name ds_constraints.src_table_name%TYPE
        ,p_cardinality ds_constraints.cardinality%TYPE
        ,p_extract_type ds_constraints.extract_type%TYPE
      ) IS
         SELECT ds_con.*
           FROM ds_constraints ds_con
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_con.set_id
            AND ds_tab.table_name = ds_con.dst_table_name
            AND ds_tab.extract_type NOT IN ('N','F')
          WHERE ds_con.set_id = p_set_id
            AND ds_con.src_table_name = p_table_name
            AND (p_cardinality IS NULL OR ds_con.cardinality = p_cardinality)
            AND (p_extract_type IS NULL OR ds_con.extract_type = p_extract_type)
            AND ds_con.extract_type != 'N'
          ORDER BY CASE WHEN ds_con.src_table_name = ds_con.dst_table_name THEN 1 ELSE 2 END -- pig's ear first
            FOR UPDATE OF ds_con.extract_count
      ;
      -- Select records to be processed
      CURSOR c_rec (
         p_table_id ds_records.table_id%TYPE
        ,p_pass_count ds_records.pass_count%TYPE
      ) IS
          SELECT ROWIDTOCHAR(record_rowid) record_rowid
            FROM ds_records
           WHERE table_id = p_table_id
             AND pass_count = p_pass_count
             AND NVL(deleted_flag,'N') = 'N'
      ;
      -- Local vars
      l_sql VARCHAR2(4000);
      l_count INTEGER;
      l_tmp_count INTEGER;
      l_pass_count INTEGER;
      l_row_count INTEGER;
      l_row_limit INTEGER;
      l_source_count INTEGER;
      r_tab_dst ds_tables%ROWTYPE;
      l_src_alias ds_tables.table_alias%TYPE;
      l_dst_alias ds_tables.table_alias%TYPE;
      l_cardinality ds_constraints.CARDINALITY%TYPE;
      l_extract_type ds_constraints.extract_type%TYPE;
      l_distinct VARCHAR2(10);
      l_seq_mult INTEGER;
      l_pass_mult INTEGER;
      l_plunit VARCHAR2(30) := 'extract_data_set_rowids';
   BEGIN
      show_message('D','->'||l_plunit||'()');
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Check for potential loops in dependencies
      define_walk_through_strategy(p_set_id);
      -- Delete data set
      delete_data_set_rowids(p_set_id);
      -- 2 passes: 1-N (base) then N-1 (referential)
      FOR i IN 1..2 LOOP
         show_message('D','iteration='||i);
         IF i = 1
         THEN
            extract_base_tables(p_set_id);
--            l_cardinality := '1-N';
            l_cardinality := '';
            l_extract_type := 'B';
         ELSE
            UPDATE ds_tables
               SET pass_count = 0
             WHERE set_id = p_set_id
               AND NVL(pass_count,-1) != 0
            ;
            UPDATE ds_records
               SET pass_count = 1
             WHERE table_id IN (
                      SELECT table_id
                        FROM ds_tables
                       WHERE set_id = p_set_id
                   )
               AND NVL(pass_count,-1) != 1
               AND NVL(deleted_flag,'N') = 'N'
            ;
--            l_cardinality := NULL;
--            l_extract_type := 'P';
            l_cardinality := 'N-1';
            l_extract_type := '';
         END IF;
         l_pass_count := 0;
         l_count := 1;
         WHILE l_count > 0 LOOP
            l_pass_count := l_pass_count + 1;
            show_message('D','pass='||l_pass_count);
            assert(l_pass_count<=1000,'Infinite loop detected in extract_data_set_rowids()'); -- to avoid infinite loop!
            l_count := 0;
            FOR r_tab_src IN c_tab(p_set_id, CASE WHEN i=1 THEN 1/*ASC*/ ELSE -1/*DESC*/ END) LOOP
               l_count := l_count + 1;
               assert(l_count<=1000,'Infinite loop detected in extract_data_set_rowids()'); -- to avoid infinite loop!
               show_message('D','src_table='||r_tab_src.table_name||', pass='||r_tab_src.pass_count);
               FOR r_con IN c_con(p_set_id,r_tab_src.table_name,l_cardinality,l_extract_type) LOOP
                  show_message('D','   fk='||r_con.constraint_name);
                  l_row_count := 0;
                  l_seq_mult := CASE WHEN r_con.cardinality = '1-N' THEN -1 ELSE 1 END;
                  l_pass_mult := CASE WHEN r_con.deferred = 'DEFERRED' OR r_con.src_table_name = r_con.dst_table_name THEN 1 ELSE -1 END;
                  assert(r_con.join_clause IS NOT NULL,'Missing join clause for constraint #'||r_con.con_id);
                  get_table(p_set_id,r_con.dst_table_name,r_tab_dst);
                  show_message('D','   dst_table='||r_tab_dst.table_name||', pass='||r_tab_dst.pass_count);
                  IF r_tab_dst.extract_type = 'F' THEN
                     GOTO next_constraint;
                  END IF;
                  IF r_con.dst_table_name = r_con.src_table_name
                --AND r_con.cardinality = '1-N'
                  THEN
                     -- Tables with pig ears need to be processed once more
                     r_tab_dst.pass_count := r_tab_dst.pass_count + 1;
                  END IF;
                  IF r_con.CARDINALITY = 'N-1' THEN
                     get_aliases(r_tab_dst, r_tab_src, l_dst_alias, l_src_alias);
                  ELSE
                     get_aliases(r_tab_src, r_tab_dst, l_src_alias, l_dst_alias);
                  END IF;
                  -- No filter allowed for many-to-one relationships
                  IF r_con.CARDINALITY = 'N-1' THEN
                     r_con.where_clause := NULL;
                     r_con.percentage := NULL;
                     r_con.row_limit := NULL;
                  END IF;
                  -- Row limitation is implemented by a nested-loop on source records
                  IF r_con.percentage IS NOT NULL
                  OR r_con.row_limit IS NOT NULL
                  THEN
                     assert(r_tab_src.extract_type!='F','row limit not compatible with full extract');
                     -- For each master record, select detail records limited to given row count
                     FOR r_rec IN c_rec(r_tab_src.table_id,r_tab_src.pass_count+1) LOOP
                        -- Record count is required to compute row limit from percentage
                        IF r_con.percentage IS NOT NULL THEN
                           -- Count nber of records in relationship
                           l_sql := '
SELECT COUNT(*)
  FROM '||LOWER(r_tab_dst.table_name)||' '||l_dst_alias||','||LOWER(r_tab_src.table_name)||' '||l_src_alias||'
 WHERE '||r_con.join_clause||'
   AND '||NVL(r_con.where_clause,'1=1')||'
   AND '||l_src_alias||'.rowid=CHARTOROWID('''||r_rec.record_rowid||''')';
                           EXECUTE IMMEDIATE l_sql INTO l_source_count;
                           l_row_limit := compute_row_limit(r_con.row_limit,r_con.percentage,l_source_count);
                        ELSE
                           l_row_limit := r_con.row_limit;
                        END IF;
                        -- Compute row limit
                        l_sql :=
'
INSERT INTO ds_records (
   table_id, record_rowid, pass_count, con_id
)';
                        IF r_con.order_by_clause IS NOT NULL THEN
                           l_distinct := NULL; -- to prevent ORA-01791: not a SELECTed expression
                           l_sql := l_sql ||
'
SELECT DISTINCT *
  FROM (';
                        ELSE
                           l_distinct := 'DISTINCT ';
                        END IF;
                        l_sql := l_sql ||
'
SELECT '||l_distinct||r_tab_dst.table_id||','||l_dst_alias||'.rowid
               ,'||TO_CHAR(r_tab_dst.pass_count+1)||','||r_con.con_id||'
  FROM '||LOWER(r_tab_dst.table_name)||' '||l_dst_alias||','||LOWER(r_tab_src.table_name)||' '||l_src_alias||'
 WHERE '||r_con.join_clause||'
   AND '||NVL(r_con.where_clause,'1=1')||'
   AND '||l_src_alias||'.rowid=CHARTOROWID('''||r_rec.record_rowid||''')';
                        IF r_con.order_by_clause IS NOT NULL THEN
                           l_sql := l_sql ||
'
 ORDER BY '||r_con.order_by_clause||'
)
 WHERE rownum <= '||l_row_limit;
                        ELSE
                           l_sql := l_sql ||
'
   AND rownum <= '||l_row_limit;
                        END IF;
                        l_row_count := l_row_count + execute_immediate(l_sql);
                     END LOOP;
                  ELSE
                     l_sql :=
'
INSERT INTO ds_records (
   table_id, record_rowid, pass_count, con_id, seq, source_rowid
)
SELECT DISTINCT '||r_tab_dst.table_id||','||l_dst_alias||'.rowid
               ,'||TO_CHAR(r_tab_dst.pass_count+1)||','||r_con.con_id||'
               ,'||CASE WHEN r_tab_src.extract_type != 'F' THEN 'ds_rec.seq + 1 * '||l_seq_mult ELSE '0/*TBD*/' END||'
               ,ds_rec.record_rowid
  FROM '||LOWER(r_tab_dst.table_name)||' '||l_dst_alias||'
 INNER JOIN '||LOWER(r_tab_src.table_name)||' '||l_src_alias||'
    ON '||r_con.join_clause;
                     IF r_tab_src.extract_type != 'F' THEN
                        l_sql := l_sql ||'
 INNER JOIN ds_records ds_rec
    ON ds_rec.record_rowid = '||l_src_alias||'.rowid
   AND ds_rec.table_id = '||r_tab_src.table_id||'
   AND ds_rec.pass_count = '||TO_CHAR(r_tab_src.pass_count+1)||'
   AND NVL(ds_rec.deleted_flag,''N'') = ''N''
  LEFT OUTER JOIN ds_records ds_rec2
    ON ds_rec2.table_id = '||r_tab_dst.table_id||'
   AND ds_rec2.record_rowid = '||l_dst_alias||'.rowid
   AND NVL(ds_rec2.deleted_flag,''N'') = ''N''
   AND ds_rec2.pass_count * '||l_pass_mult||' <= '||TO_CHAR(r_tab_src.pass_count+1)||' * '||l_pass_mult;
                     END IF;
                     l_sql := l_sql ||'
 WHERE '||NVL(r_con.where_clause,'1=1');
                     IF r_tab_src.extract_type != 'F' THEN
                        l_sql := l_sql ||'
   AND ds_rec2.table_id IS NULL';
                     END IF;
                     l_row_count := execute_immediate(l_sql);
                     show_message('D','   row_count='||l_row_count);
                  END IF;
                  -- If rows were inserted
                  IF l_row_count > 0 THEN
                     -- Delete duplicate rows
                     l_tmp_count := delete_duplicate_records(r_tab_dst.table_id,l_pass_mult);
                     IF l_tmp_count > 0 THEN
                        show_message('D','   '|| l_tmp_count||' duplicate records deleted for table '||r_tab_dst.table_name);
                     END IF;
                     -- Update statistics
                     UPDATE ds_constraints
                        SET extract_count = extract_count + l_row_count
                      WHERE CURRENT OF c_con;
                  END IF;
                  <<next_constraint>>
                  NULL;
               END LOOP;
               -- Increase pass count
               UPDATE ds_tables
                  SET pass_count = pass_count + 1
                WHERE CURRENT OF c_tab
               ;
            END LOOP;
         END LOOP;
      END LOOP; -- cardinality
      -- Count extracted rows
      UPDATE ds_tables ds_tab
         SET (extract_count,group_count) = (
                SELECT COUNT(*), NVL(MAX(pass_count),0)
                  FROM ds_records ds_rec
                 WHERE ds_rec.table_id = ds_tab.table_id
                   AND NVL(ds_rec.deleted_flag,'N') = 'N'
             )
       WHERE set_id = p_set_id
         AND extract_type != 'F'
      ;
      UPDATE ds_tables ds_tab
         SET extract_count = source_count
           , group_count = 1
       WHERE set_id = p_set_id
         AND extract_type = 'F'
      ;
      IF INSTR(ds_utility_var.g_msg_mask,'D') > 0 THEN
         set_record_remarks(p_set_id);
      END IF;
      show_message('D','<-'||l_plunit||'()');
   END;
   ---
   -- Generate full table name by addying an owner prefix and db link suffix
   ---
   FUNCTION gen_full_table_name (
      p_table_name IN VARCHAR2
     ,p_schema IN VARCHAR2
     ,p_db_link IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_full_name VARCHAR2(200) := p_table_name;
   BEGIN
      IF p_table_name IS NULL THEN
         RETURN NULL;
      END IF;
      IF p_schema IS NOT NULL THEN
         l_full_name := p_schema || '.' || l_full_name;
      END IF;
      IF p_db_link IS NOT NULL THEN
         l_full_name := l_full_name || '@' || p_db_link;
      END IF;
      RETURN LOWER(l_full_name);
   END;
--
--#begin public
/**
* Copy rows of the given data set into target tables
* @param p_set_id       data set id (null for all data sets)
* DEPRECATED - Replaced with handle_data_set()
*/
   PROCEDURE copy_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      -- Cursor to browse tables of a data set in the right order
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type != 'N'
          ORDER BY seq ASC
      ;
      l_sql VARCHAR2(4000);
      l_row_count INTEGER;
      l_sel_columns ds_tables.columns_list%TYPE;
      l_ins_columns ds_tables.columns_list%TYPE;
      l_upd_columns ds_tables.columns_list%TYPE;
      l_pk_columns ds_tables.columns_list%TYPE;
      l_pk_name sys.all_constraints.constraint_name%TYPE;
      l_export_mode ds_tables.export_mode%TYPE;
      l_src_table_name VARCHAR2(100);
      l_tgt_table_name VARCHAR2(100);
   BEGIN
      FOR r_set IN c_set(p_set_id) LOOP
         define_walk_through_strategy(r_set.set_id);
         FOR r_tab IN c_tab(r_set.set_id) LOOP
            l_src_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
            l_tgt_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,r_tab.target_db_link);
            -- Optimisation: do not process empty tables
            IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N'
            THEN
               l_export_mode := UPPER(NVL(r_tab.export_mode,'I'));
               IF INSTR(l_export_mode,'I') > 0 THEN
                  IF r_tab.columns_list IS NULL THEN
                     l_ins_columns := NULL;
                     l_sel_columns := '*';
                  ELSE
                     l_sel_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
                     l_ins_columns := ' ('||CHR(10)||format_columns_list(l_sel_columns,3,'Y')||CHR(10)||')';
                  END IF;
                  assert(l_sel_columns IS NOT NULL,'List of columns to select is empty for table '||r_tab.table_name);
               END IF;
               IF INSTR(l_export_mode,'U') > 0 THEN
                  l_pk_name := get_table_pk(r_tab.table_name);
                  assert(l_pk_name IS NOT NULL,'Table '||r_tab.table_name||' has no primary key');
                  l_pk_columns := get_constraint_columns(l_pk_name);
                  assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no columns');
                  l_upd_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
                  assert(l_upd_columns IS NOT NULL,'List of columns to update is empty for table '||r_tab.table_name);
               END IF;
               FOR l_pass_count IN REVERSE 1..r_tab.group_count LOOP
                  IF INSTR(l_export_mode,'U') > 0 THEN
                     /* Update existing records in destination schema */
                     l_sql :=
'
UPDATE '||l_tgt_table_name||' rem
   SET ('||format_columns_list(l_upd_columns,8,'N')||') = (
          SELECT '||format_columns_list(l_upd_columns,17,'N')||'
            FROM '||l_src_table_name||' loc
           WHERE '||build_join_condition(l_pk_columns,'loc','rem',17,'N')||'
       )
 WHERE ('||l_pk_columns||') IN (
          SELECT '||l_pk_columns||'
            FROM '||l_src_table_name;
                  IF r_tab.extract_type != 'F' THEN
                     l_sql := l_sql ||
'
           WHERE rowid IN (
                    SELECT record_rowid
                      FROM ds_records
                     WHERE table_id = '||r_tab.table_id||'
                       AND pass_count = '||l_pass_count||'
                       AND NVL(deleted_flag,''N'') = ''N''
                 )';
                  END IF;
                  l_sql := l_sql ||
'
       )';
                     l_row_count := execute_immediate(l_sql);
                  END IF;
                  IF INSTR(l_export_mode,'I') > 0 THEN
                     /* Insert missing records in destination schema */
                     l_sql :=
'
INSERT INTO '||l_tgt_table_name||'
SELECT '||format_columns_list(l_sel_columns,7,'N')||'
  FROM '||l_src_table_name||'
 WHERE 1=1';
                     IF r_tab.extract_type != 'F' THEN
                        l_sql := l_sql ||
'
   AND rowid IN (
          SELECT record_rowid
            FROM ds_records
           WHERE table_id = '||r_tab.table_id||'
             AND pass_count = '||l_pass_count||'
             AND NVL(deleted_flag,''N'') = ''N''
       )';
                     END IF;
                     IF INSTR(l_export_mode,'U') > 0 THEN
                        l_sql := l_sql ||
'
   AND ('||l_pk_columns||') NOT IN (
          SELECT '||l_pk_columns||'
            FROM '||l_tgt_table_name||'
       )';
                     END IF;
                  END IF;
                  l_row_count := execute_immediate(l_sql);
               END LOOP;
            END IF;
         END LOOP;
      END LOOP;
   END;
--
--#begin public
/**
* Copy all tables of a given data through a database link
* Tables and records are copied in the right order so that 
* integrity is guaranteed without needing to disable constraints.
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
* @param p_db_link      database link name
*/
   PROCEDURE export_data_set_via_db_link (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_db_link IN user_db_links.db_link%TYPE
   )
--#end public
   IS
   BEGIN
      update_table_properties(
         p_set_id=>p_set_id
        ,p_target_db_link=>p_db_link
      );
      copy_data_set(p_set_id);
   END;
   ---
   -- Initialise shifting of sequences
   ---
   PROCEDURE init_seq (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   IS
      CURSOR c_seq (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT ds_tab.table_id, ds_tab.set_id, LOWER(seq.sequence_name) sequence_name
              , LOWER(ds_tab.table_name) table_name, LOWER(tcol.column_name) column_name
              , CASE WHEN ds_tab.id_shift_value = 0 THEN NULL ELSE ds_tab.id_shift_value END id_shift_value -- 0 <=> NULL
           FROM ds_tables ds_tab
          INNER JOIN sys.all_constraints ds_con
             ON ds_con.owner = ds_utility_var.g_owner
            AND ds_con.table_name = ds_tab.table_name
            AND ds_con.constraint_type = 'P'
          INNER JOIN sys.all_cons_columns ccol
             ON ccol.owner = ds_con.owner
            AND ccol.constraint_name = ds_con.constraint_name
            AND ccol.position = 1
           LEFT OUTER JOIN sys.all_cons_columns ccol2
             ON ccol2.owner = ds_con.owner
            AND ccol2.constraint_name = ds_con.constraint_name
            AND ccol2.position = 2
          INNER JOIN sys.all_tab_columns tcol
             ON tcol.owner = ds_con.owner
            AND tcol.table_name = ds_con.table_name
            AND tcol.column_name = ccol.column_name
            AND tcol.data_type = 'NUMBER'
           LEFT OUTER JOIN sys.all_sequences seq
             ON seq.sequence_owner = ds_con.owner
            AND seq.sequence_name = ds_tab.sequence_name
          WHERE ds_tab.set_id = p_set_id
            AND ccol2.position IS NULL -- PK must have only one column
            AND (seq.sequence_name IS NOT NULL OR ds_tab.id_shift_value IS NOT NULL)
      ;
      CURSOR c_map (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT ds_tab.table_id, ds_tab.set_id, LOWER(seq.sequence_name) sequence_name
              , LOWER(fk.table_name) table_name, LOWER(fkcol.column_name) column_name
              , CASE WHEN ds_tab.id_shift_value = 0 THEN NULL ELSE ds_tab.id_shift_value END id_shift_value -- 0 <=> NULL
           FROM ds_tables ds_tab
          INNER JOIN sys.all_constraints pk
             ON pk.owner = ds_utility_var.g_owner
            AND pk.table_name = ds_tab.table_name
            AND pk.constraint_type = 'P'
          INNER JOIN sys.all_cons_columns pkcol
             ON pkcol.owner = pk.owner
            AND pkcol.constraint_name = pk.constraint_name
            AND pkcol.position = 1
           LEFT OUTER JOIN sys.all_cons_columns pkcol2
             ON pkcol2.owner = pk.owner
            AND pkcol2.constraint_name = pk.constraint_name
            AND pkcol2.position = 2
          INNER JOIN sys.all_tab_columns tcol
             ON tcol.owner = pkcol.owner
            AND tcol.table_name = pkcol.table_name
            AND tcol.column_name = pkcol.column_name
            AND tcol.data_type = 'NUMBER'
          INNER JOIN sys.all_constraints fk
             ON fk.owner = pk.owner
            AND fk.r_constraint_name = pk.constraint_name
            AND fk.constraint_type = 'R'
          INNER JOIN sys.all_cons_columns fkcol
             ON fkcol.owner = fk.owner
            AND fkcol.constraint_name = fk.constraint_name
            AND fkcol.position = pkcol.position
           LEFT OUTER JOIN sys.all_sequences seq
             ON seq.sequence_owner = pk.owner
            AND seq.sequence_name = ds_tab.sequence_name
          WHERE ds_tab.set_id = p_set_id
            AND pkcol2.position IS NULL -- PK must have only one column
            AND (seq.sequence_name IS NOT NULL OR ds_tab.id_shift_value IS NOT NULL)
      ;
   BEGIN
      ds_utility_var.g_seq.DELETE;
      FOR r_seq IN c_seq(p_set_id) LOOP
         ds_utility_var.g_seq(r_seq.table_name||'.'||r_seq.column_name) := r_seq;
      END LOOP;
      ds_utility_var.g_map.DELETE;
      FOR r_map IN c_map(p_set_id) LOOP
         ds_utility_var.g_map(r_map.table_name||'.'||r_map.column_name) := r_map;
--         sys.dbms_output.put_line(r_map.table_name||'.'||r_map.column_name||' mapped to table_id='||r_map.table_id
--            ||', set_id='||r_map.set_id||', sequence_name='||r_map.sequence_name||', id_shift_value='||r_map.id_shift_value);
      END LOOP;
   END;
--
--#begin public
/**
* Handle a data set (copy/delete via direct execution or prepare/execution script)
* @param p_set_id       data set id, NULL means all data sets
* @param p_oper         DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
* @param p_mode         I)nsert, U)pdate, R)efresh or UI, D)elete, M)ove
* @param p_db_link      for remote script execution
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE handle_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_oper IN VARCHAR2 -- DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
     ,p_mode IN VARCHAR2 := NULL -- I)insert, U)pdate, R)efresh or UI, D)elete, M)ove
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_output IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
   )
--#end public
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      -- Cursor to browse tables of a data set in the right order
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_order INTEGER
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type != 'N'
          ORDER BY seq * p_order ASC
      ;
      l_sql CLOB;
      l_result VARCHAR2(32767);
      l_row_count INTEGER;
      l_sel_columns ds_tables.columns_list%TYPE;
      l_ins_columns ds_tables.columns_list%TYPE;
      l_upd_columns ds_tables.columns_list%TYPE;
      l_pk_columns ds_tables.columns_list%TYPE;
      l_pk_name sys.all_constraints.constraint_name%TYPE;
      l_pk_size INTEGER;
      l_count INTEGER;
      l_cursor INTEGER;
      l_export_mode ds_tables.export_mode%TYPE;
      l_insert_mode BOOLEAN;
      l_update_mode BOOLEAN;
      l_refresh_mode BOOLEAN;
      l_delete_mode BOOLEAN;
      l_move_mode BOOLEAN;
      l_pass_count INTEGER;
      l_order INTEGER;
      l_src_table_name VARCHAR2(100);
      l_tgt_table_name VARCHAR2(100);
      l_ws VARCHAR2(30);
      l_indent INTEGER;
      l_mode VARCHAR2(10) := UPPER(p_mode);
      FUNCTION rowid_subquery (
         p_extract_type IN VARCHAR2
       , p_table_id IN NUMBER
       , p_pass_count IN NUMBER
       , p_indent IN NUMBER := 0
      )
      RETURN VARCHAR2
      IS
         l_spaces VARCHAR2(10);
      BEGIN
         -- No restriction needed for full table extractions
         IF p_extract_type = 'F' THEN
            RETURN '';
         END IF;
         IF p_indent > 0 THEN
            l_spaces := RPAD(' ',p_indent,' ');
         END IF;
         RETURN CHR(10) 
            ||l_spaces||'   AND rowid IN ('||CHR(10)
            ||l_spaces||'          SELECT record_rowid'||CHR(10)
            ||l_spaces||'            FROM ds_records'||CHR(10)
            ||l_spaces||'           WHERE table_id = '||p_table_id||CHR(10)
            ||l_spaces||'             AND pass_count = '||p_pass_count||CHR(10)
            ||l_spaces||'             AND NVL(deleted_flag,''N'') = ''N'''||CHR(10)
            ||l_spaces||'       )';
      END;
   BEGIN
      assert(NVL(p_oper,'~') IN ('DIRECT-EXECUTE','PREPARE-SCRIPT','EXECUTE-SCRIPT'),'Operation must be DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT');
      assert(l_mode IN ('I','U','R','D','M','UI'),'Mode must be I)nsert, U)pdate, R)efresh, D)elete or M)ove');
      -- UI (Upsert) mode = R)refresh (for backward compatibility)
      IF l_mode = 'UI' THEN
         l_mode := 'R';
      END IF;
      <<again>>
      FOR r_set IN c_set(p_set_id) LOOP
         define_walk_through_strategy(r_set.set_id);
         IF l_mode IN ('D') THEN
            l_order := -1;
         ELSE
            init_seq(r_set.set_id);
            l_order := 1;
         END IF;
         FOR r_tab IN c_tab(r_set.set_id,l_order) LOOP
            l_src_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
            l_tgt_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,r_tab.target_db_link);
            -- Optimisation: do not process empty tables
            IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N'
            THEN
               l_export_mode := UPPER(NVL(p_mode,NVL(r_tab.export_mode,'I')));
               l_delete_mode := l_export_mode = 'D';
               l_insert_mode := NOT l_delete_mode AND l_export_mode IN ('I','R','M'); -- Move = Insert + Delete (in 2 passes as order of processing is different)
               l_update_mode := NOT l_delete_mode AND l_export_mode IN ('U','R');
               l_refresh_mode := NOT l_delete_mode AND l_export_mode IN ('R');
               IF l_insert_mode THEN
                  l_ins_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
                  assert(l_ins_columns IS NOT NULL,'List of columns to insert is empty for table '||r_tab.table_name);
                  l_pk_size := 0;
                  l_sel_columns := l_ins_columns;
               END IF;
               IF l_update_mode OR l_delete_mode THEN
                  l_pk_name := get_table_pk(r_tab.table_name);
                  assert(l_pk_name IS NOT NULL,'Table '||r_tab.table_name||' has no primary key');
                  l_pk_columns := get_constraint_columns(l_pk_name);
                  l_pk_size := get_columns_list_size(l_pk_columns);
                  assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no column');
               END IF;
               IF l_update_mode THEN
                  l_upd_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*')
                     ||CASE WHEN INSTR(r_tab.columns_list,' BUT ')>0 THEN ', ' ELSE ' BUT ' END||l_pk_columns); -- all columns but pk
                  assert(l_upd_columns IS NOT NULL,'List of columns to update is empty for table '||r_tab.table_name);
                  l_sel_columns := l_pk_columns || ', '|| l_upd_columns;
               END IF;
               IF l_delete_mode THEN
                  l_sel_columns := l_pk_columns;
               END IF;
               FOR l_pass_index IN REVERSE 1..r_tab.group_count LOOP
                  /* For deletion, walk through in reverse order */
                  IF l_delete_mode THEN
                     l_pass_count := r_tab.group_count - l_pass_index + 1;
                  ELSE
                     l_pass_count := l_pass_index;
                  END IF;
                  -- ***** DIRECT method *****
                  IF p_oper = 'DIRECT-EXECUTE' THEN
                     IF l_update_mode OR l_refresh_mode THEN
                        /* Update existing records in destination schema */
                        l_sql :=
                           'UPDATE '||l_tgt_table_name||' rem'||CHR(10)
                         ||'   SET ('||format_columns_list(l_upd_columns,8,'N')||CHR(10)
                         ||'       ) = ('||CHR(10)
                         ||'          SELECT '||build_select_for_subquery(r_tab.table_name,'U',l_upd_columns,17,'N',3,p_db_link)||CHR(10)
                         ||'            FROM '||l_src_table_name||' loc'||CHR(10)
                         ||'           WHERE '||build_join_condition(l_pk_columns,'loc','rem',17,'N')||CHR(10)
                         ||'       )'||CHR(10)
                         ||' WHERE ('||l_pk_columns||') IN ('||CHR(10)
                         ||'          SELECT '||l_pk_columns||CHR(10)
                         ||'            FROM '||l_src_table_name||CHR(10)
                         ||'           WHERE 1=1'||rowid_subquery(r_tab.extract_type,r_tab.table_id,l_pass_count,10)||CHR(10)
                         ||'       )'||CHR(10);
                        l_row_count := execute_immediate(l_sql);
                     END IF;
                     IF l_insert_mode OR l_refresh_mode THEN
                        l_sql :=
                           'INSERT INTO '||l_tgt_table_name||' ('||CHR(10)
                         ||format_columns_list(l_ins_columns,7,'Y')||CHR(10)
                         ||')'||CHR(10)
                         ||'SELECT '||build_select_for_subquery(r_tab.table_name,'I',l_ins_columns,7,'N',3,p_db_link)||CHR(10)
                         ||'  FROM '||l_src_table_name||CHR(10)
                         ||' WHERE 1=1'||rowid_subquery(r_tab.extract_type,r_tab.table_id,l_pass_count,0)||CHR(10);
                        /* In upsert mode, insert only missing records */
                        IF l_refresh_mode THEN
                           l_sql := l_sql ||
                           '   AND ('||l_pk_columns||') NOT IN ('||CHR(10)
                         ||'      SELECT '||l_pk_columns||CHR(10)
                         ||'        FROM '||l_tgt_table_name||CHR(10)
                         ||'   )'||CHR(10);
                        END IF;
                        IF r_tab.order_by_clause IS NOT NULL THEN
                           l_sql := l_sql ||
                           'ORDER BY '||r_tab.order_by_clause||CHR(10);
                        END IF;
                        /* overwrite sql with merge version */
                        IF l_refresh_mode AND get_context('ds_merge') = 'Y' THEN
                           l_sql := 
                              ' MERGE INTO '||l_tgt_table_name||' rem'||CHR(10)
                            ||' USING ('||CHR(10)
                            ||'          SELECT '||build_select_for_subquery(r_tab.table_name,'I',l_ins_columns,7,'N',3,p_db_link)||CHR(10)
                            ||'            FROM '||l_src_table_name||CHR(10)
                            ||'           WHERE 1=1'||rowid_subquery(r_tab.extract_type,r_tab.table_id,l_pass_count,0)||CHR(10)
                            ||'       ) loc'||CHR(10)
                            ||'    ON ('|| build_join_condition(l_pk_columns,'loc','rem',17,'N')||CHR(10)
                            ||'       )'||CHR(10)
                            ||' WHEN NOT MATCHED THEN '||CHR(10)
                            ||' INSERT (rem.' || REPLACE(normalise_columns_list(r_tab.table_name,'*'),', ',', rem.')||')'||CHR(10)
                            ||' VALUES (loc.' || REPLACE(normalise_columns_list(r_tab.table_name,'*'),', ',', loc.')||')'||CHR(10);
                        END IF;
                        l_row_count := execute_immediate(l_sql);
                     END IF;
                     IF l_delete_mode THEN
                        l_sql :=
                           'DELETE '||LOWER(r_tab.table_name)||CHR(10)
                         ||' WHERE 1=1'||rowid_subquery(r_tab.extract_type,r_tab.table_id,l_pass_count,0)||CHR(10);
                        l_row_count := execute_immediate(l_sql);
                     END IF;
                  -- ***** SCRIPT method *****
                  ELSIF p_oper LIKE '%SCRIPT%' THEN
                     /* Select rows to extract */
                     l_sql :=
                        'SELECT '||build_select_clause(r_tab.table_name,l_sel_columns,7,'N')||CHR(10)
                      ||'  FROM '||l_src_table_name||CHR(10)
                      ||' WHERE 1=1'||rowid_subquery(r_tab.extract_type,r_tab.table_id,l_pass_count,10)||CHR(10);
                     IF r_tab.order_by_clause IS NOT NULL THEN
                        l_sql := l_sql ||
                        'ORDER BY '||r_tab.order_by_clause||CHR(10);
                     END IF;
                     l_cursor := sys.dbms_sql.open_cursor;
                     sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
                     sys.dbms_sql.define_column(l_cursor,1,l_result,32767);
                     l_count := sys.dbms_sql.execute(l_cursor);
                     l_row_count := 0;
                     WHILE sys.dbms_sql.fetch_rows(l_cursor) > 0
                     LOOP
                        IF l_refresh_mode THEN
                           l_sql := 'BEGIN'||CHR(10);
                           l_indent := 3;
                           l_ws := '   ';
                        ELSE
                           l_sql := NULL;
                           l_indent := 0;
                           l_ws := NULL;
                        END IF;
                        l_row_count := l_row_count + 1;
                        sys.dbms_sql.column_value(l_cursor,1,l_result);
                        IF l_delete_mode THEN
                           l_sql := l_sql ||
                              l_ws||'DELETE '||LOWER(r_tab.table_name)||build_set_and_where_clauses(l_tgt_table_name,l_sel_columns,l_result,l_pk_size,l_indent)||';'||CHR(10);
                        END IF;
                        IF l_update_mode THEN
                           l_sql := l_sql ||
                              l_ws||'UPDATE '||l_tgt_table_name||build_set_and_where_clauses(l_tgt_table_name,l_sel_columns,l_result,l_pk_size,l_indent)||';'||CHR(10);
                        END IF;
                        IF l_refresh_mode THEN
                           l_sql := l_sql || l_ws || 'IF SQL%NOTFOUND THEN' || CHR(10);
                        END IF;
                        IF l_insert_mode THEN
                           l_sql := l_sql ||
                              l_ws||l_ws||'INSERT INTO '||l_tgt_table_name||' ('||CHR(10)
                            ||format_columns_list(l_ins_columns,3+2*l_indent,'Y')||CHR(10)
                            ||l_ws||l_ws||') VALUES ('||CHR(10)
                            ||build_values_clause(r_tab.table_name,l_sel_columns,l_result,0/*l_pk_size*/,3+2*l_indent,'Y')||CHR(10)
                            ||l_ws||l_ws||')'||';'||CHR(10);
                        END IF;
                        IF l_refresh_mode THEN
                           l_sql := l_sql || l_ws || 'END IF;' || CHR(10)
                                          || 'END;' || CHR(10);
                        END IF;
                        IF p_oper = 'EXECUTE-SCRIPT' THEN
--                           following statement raises doesn't work as it raises error ORA-02069: global_names parameter must be set to TRUE for this operation
--                           execute_immediate(p_sql=>'BEGIN ddl_utility.execute_immediate'||CASE WHEN p_db_link IS NOT NULL THEN '@'||LOWER(p_db_link) END||'(:1); END;',p_using=>'BEGIN'||CHR(10)||l_sql||CHR(10)||'END;');
                           execute_immediate(l_sql);
                        ELSE
                           IF l_refresh_mode THEN
                              l_sql := l_sql || '/' || CHR(10);
                           END IF;
                           put(l_sql,TRUE,'DS_OUTPUT');
                        END IF;
                     END LOOP;
                     sys.dbms_sql.close_cursor(l_cursor);
                  END IF; -- p_method'
               END LOOP;
            END IF;
         END LOOP;
      END LOOP;
      -- Move = Insert + Delete
      IF l_mode = 'M' THEN
         l_mode := 'D';
         GOTO again;
      END IF;
   END;
   ---
   -- Generate a PL/SQL script that export or delete a data set
   -- DEPRECATED IMPLEMENTATION - Replaced with handle_data_set()
   ---
--   PROCEDURE handle_data_set_via_script (
--      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
--     ,p_delete_mode IN BOOLEAN
--     ,p_db_link IN VARCHAR2
--     ,p_run_script_without_db_link IN BOOLEAN
--   ) IS
--      -- Cursor to browse data sets
--      CURSOR c_set (
--         p_set_id ds_tables.table_id%TYPE
--      ) IS
--         SELECT *
--           FROM ds_data_sets
--          WHERE (p_set_id IS NULL OR set_id = p_set_id)
--      ;
--      -- Cursor to browse tables of a data set in the right order
--      CURSOR c_tab (
--         p_set_id ds_data_sets.set_id%TYPE
--        ,p_order INTEGER
--      ) IS
--         SELECT *
--           FROM ds_tables
--          WHERE set_id = p_set_id
--            AND extract_type != 'N'
--          ORDER BY seq * p_order ASC
--      ;
--      l_sql VARCHAR2(32767);
--      l_result VARCHAR2(32767);
--      l_row_count INTEGER;
--      l_sel_columns ds_tables.columns_list%TYPE;
--      l_ins_columns ds_tables.columns_list%TYPE;
--      l_upd_columns ds_tables.columns_list%TYPE;
--      l_pk_columns ds_tables.columns_list%TYPE;
--      l_pk_name sys.all_constraints.constraint_name%TYPE;
--      l_pk_size INTEGER;
--      l_count INTEGER;
--      l_cursor INTEGER;
--      l_export_mode ds_tables.export_mode%TYPE;
--      l_insert_mode BOOLEAN;
--      l_update_mode BOOLEAN;
--      l_refresh_mode BOOLEAN; -- Upsert = Update first + Insert if not found ( also called merge)
--      l_pass_count INTEGER;
--      l_order INTEGER;
--      l_src_table_name VARCHAR2(100);
--      l_tgt_table_name VARCHAR2(100);
--   BEGIN
--      FOR r_set IN c_set(p_set_id) LOOP
--         define_walk_through_strategy(r_set.set_id);
--         IF NOT p_delete_mode THEN
--            init_seq(r_set.set_id);
--         END IF;
--         IF p_delete_mode THEN
--            l_order := -1;
--         ELSE
--            l_order := 1;
--         END IF;
--         FOR r_tab IN c_tab(r_set.set_id,l_order) LOOP
--            l_src_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
--            l_tgt_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,r_tab.target_db_link);
--            -- Optimisation: do not process empty tables
--            IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N'
--            THEN
--               l_export_mode := UPPER(NVL(r_tab.export_mode,'I'));
--               l_insert_mode := NOT p_delete_mode AND INSTR(l_export_mode,'I')>0;
--               l_update_mode := NOT p_delete_mode AND INSTR(l_export_mode,'U')>0;
--               l_refresh_mode := NOT p_delete_mode AND INSTR(l_export_mode,'M')>0;--l_update_mode AND l_insert_mode;
--               IF l_insert_mode THEN
--                  l_ins_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
--                  assert(l_ins_columns IS NOT NULL,'List of columns to insert is empty for table '||r_tab.table_name);
--                  l_pk_size := 0;
--                  l_sel_columns := l_ins_columns;
--               END IF;
--               IF l_update_mode OR p_delete_mode THEN
--                  l_pk_name := get_table_pk(r_tab.table_name);
--                  assert(l_pk_name IS NOT NULL,'Table '||r_tab.table_name||' has no primary key');
--                  l_pk_columns := get_constraint_columns(l_pk_name);
--                  l_pk_size := get_columns_list_size(l_pk_columns);
--                  assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no column');
--               END IF;
--               IF l_update_mode THEN
--                  l_upd_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
--                  assert(l_upd_columns IS NOT NULL,'List of columns to update is empty for table '||r_tab.table_name);
--                  l_sel_columns := l_pk_columns || ', '|| l_upd_columns;
--               END IF;
--               IF p_delete_mode THEN
--                  l_sel_columns := l_pk_columns;
--               END IF;
--               FOR l_pass_index IN REVERSE 1..r_tab.group_count LOOP
--                  /* For deletion, walk through in reverse order */
--                  IF p_delete_mode THEN
--                     l_pass_count := r_tab.group_count - l_pass_index + 1;
--                  ELSE
--                     l_pass_count := l_pass_index;
--                  END IF;
--                  /* Select rows to extract */
--                  l_sql :=
--'
--SELECT '||build_select_clause(r_tab.table_name,l_sel_columns,7,'N')||'
--  FROM '||l_src_table_name||'
-- WHERE 1=1';
--                  IF r_tab.extract_type != 'F' THEN
--                     l_sql := l_sql ||
--'
--   AND rowid IN (
--          SELECT record_rowid
--            FROM ds_records
--           WHERE table_id = '||r_tab.table_id||'
--             AND pass_count = '||l_pass_count||'
--       )';
--                  END IF;
--                --put(l_sql,TRUE,'DS_OUTPUT');
--                  l_cursor := dbms_sql.open_cursor;
--                  sys.dbms_sql.parse(l_cursor,l_sql,dbms_sql.v7);
--                  sys.dbms_sql.define_column(l_cursor,1,l_result,32767);
--                  l_count := sys.dbms_sql.execute(l_cursor);
--                  l_row_count := 0;
--                  WHILE sys.dbms_sql.fetch_rows(l_cursor) > 0
--                  LOOP
--                     IF l_refresh_mode THEN
--                        l_sql := 'BEGIN';
--                     ELSE
--                        l_sql := NULL;
--                     END IF;
--                     l_row_count := l_row_count + 1;
--                     sys.dbms_sql.column_value(l_cursor,1,l_result);
--                     IF p_delete_mode THEN
--                        l_sql := l_sql ||
--'
--DELETE '||LOWER(r_tab.table_name)||build_set_and_where_clauses(l_tgt_table_name,l_sel_columns,l_result,l_pk_size);
----                        put(l_sql,FALSE,'DS_OUTPUT');
----                        l_sql := NULL;
--                     END IF;
--                     IF l_update_mode THEN
--                        l_sql := l_sql ||
--'
--UPDATE '||LOWER(r_tab.table_name)||build_set_and_where_clauses(l_tgt_table_name,l_sel_columns,l_result,l_pk_size);
----                        put(l_sql,FALSE,'DS_OUTPUT');
----                        l_sql := NULL;
--                     END IF;
--                     IF l_refresh_mode THEN
--                        l_sql := l_sql || CHR(10) || ';'
--                                       || CHR(10) || 'IF SQL%NOTFOUND THEN';
--                     END IF;
--                     IF l_insert_mode THEN
--                        l_sql := l_sql ||
--'
--INSERT INTO '||l_tgt_table_name||' (
--'||format_columns_list(l_ins_columns,3,'Y')||'
--) VALUES (
--'||build_values_clause(r_tab.table_name,l_sel_columns,l_result,l_pk_size,3,'Y')||'
--)';
----                        put(l_sql,FALSE,'DS_OUTPUT');
----                        l_sql := NULL;
--                     END IF;
--                     IF l_refresh_mode THEN
--                        l_sql := l_sql || CHR(10) || ';'
--                                       || CHR(10) || 'END IF;'
--                                       || CHR(10) || 'END;';
--                     END IF;
--                     IF p_db_link IS NOT NULL THEN
--                        IF SUBSTR(l_sql,-1,1) != ';' THEN
--                           l_sql := l_sql || ';';
--                        END IF;
--log_utility.log_message('D','executing: '||l_sql);
--                        EXECUTE IMMEDIATE 'BEGIN ddl_utility.execute_immediate@'||LOWER(p_db_link)||'(:1); END;' USING 'BEGIN '||l_sql||CHR(10)||' END;';
--                     ELSE                         
--                        IF p_run_script_without_db_link IS NOT NULL AND p_run_script_without_db_link THEN
--                           IF SUBSTR(l_sql,-1,1) != ';' THEN
--                              l_sql := l_sql || ';';
--                           END IF;
--                           --log_utility.log_message('Debug','executing: '||l_sql, TRUE);
--                           sys.dbms_output.put_line('executing: '||l_sql); -- TBR
--                           EXECUTE IMMEDIATE 'BEGIN ddl_utility.execute_immediate(:1); END; 'USING 'BEGIN '||l_sql||CHR(10)||' END;';
--                        ELSE 
--                           put(l_sql||CHR(10)||'/'||CHR(10),TRUE,'DS_OUTPUT');
--                        END IF;
--                     END IF;
--                  END LOOP;
--                  sys.dbms_sql.close_cursor(l_cursor);
--               END LOOP;
--            END IF;
--         END LOOP;
--      END LOOP;
--   END;
   ---
   -- Generate a PL/SQL script that export or delete a data set
   -- DEPRECATED - Replaced with handle_data_set()
   ---
   PROCEDURE handle_data_set_via_script (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_delete_mode IN BOOLEAN
     ,p_db_link IN VARCHAR2
     ,p_run_script_without_db_link IN BOOLEAN
   ) IS
   BEGIN
      IF p_db_link IS NOT NULL THEN
         handle_data_set(p_set_id=>p_set_id, p_oper=>'EXECUTE-SCRIPT', p_mode=>CASE WHEN p_delete_mode THEN 'D' ELSE NULL END, p_db_link=>p_db_link);
      ELSIF p_run_script_without_db_link THEN
         handle_data_set(p_set_id=>p_set_id, p_oper=>'EXECUTE-SCRIPT', p_mode=>CASE WHEN p_delete_mode THEN 'D' ELSE NULL END);
      ELSE
         handle_data_set(p_set_id=>p_set_id, p_oper=>'PREPARE-SCRIPT', p_mode=>CASE WHEN p_delete_mode THEN 'D' ELSE NULL END);
      END IF;
   END;
--
--#begin public
/**
* Create a SQL script to export a data set
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE export_data_set_via_script (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
    , p_db_link IN VARCHAR2 := NULL -- execute script via given db_link
   )
--#end public
   IS
   BEGIN
      handle_data_set_via_script(p_set_id,FALSE,p_db_link,FALSE);
   END;
   ---
   -- Build "values" clause of an insert for versionable tables
   -- DEPRECATED *** SYSPER specific ***
   ---
   FUNCTION build_values_clause_for_ver_tb (
     p_table_name IN VARCHAR2
    ,p_columns_list IN VARCHAR2
    ,p_data IN VARCHAR2
    ,p_pk_size IN INTEGER
    ,p_left_tab IN INTEGER := 2
    ,p_indent_first_line IN VARCHAR2 := 'Y'
    ,p_columns_per_line IN INTEGER := 3
   )
   RETURN VARCHAR2
   IS
     l_col_names ds_utility_var.column_name_table;
     l_select VARCHAR2(32767);
     l_col_type VARCHAR2(30);
     l_col_name VARCHAR2(30);
     l_col_val VARCHAR2(32767);
     l_col_val_pk VARCHAR2(32767);
     l_tab_col VARCHAR2(61);     
     l_user VARCHAR2(100) := get_user;
     j INTEGER;
   BEGIN
     l_col_names := tokenize_columns_list(LOWER(p_columns_list));
     /* Browse all columns excepted leading pk columns */
     FOR i IN p_pk_size+1..l_col_names.COUNT LOOP
       j := i - p_pk_size;
       l_col_name := l_col_names(i);
       l_col_type := get_column_type(p_table_name,l_col_name);
       IF MOD(j-1,p_columns_per_line) = 0 THEN
         IF l_select IS NOT NULL THEN
            l_select := l_select || CHR(10);
            l_select := l_select || RPAD(' ',p_left_tab-2);
         ELSE
            IF p_indent_first_line = 'Y' THEN
              l_select := l_select || RPAD(' ',p_left_tab);
            END IF;
         END IF;
       END IF;
       IF j > 1 THEN
         l_select := l_select || ', ';
       END IF;
       l_col_val := REPLACE(extract_string(p_data,i),'\~','~');
       IF l_col_val IS NULL THEN
         l_select := l_select || 'NULL';
       ELSE
         IF l_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
         IF (lower('user_creat') = lower(l_col_name)) OR (lower('user_modif') = lower(l_col_name)) THEN -- SYSPER
               l_select := l_select || '''' || l_user || ''''; -- SYSPER
            ELSE -- SYSPER
               l_select := l_select || '''' || l_col_val || '''';
            END IF; -- SYSPER
         ELSIF l_col_type = 'DATE' THEN
            IF (lower('date_creat') = lower(l_col_name)) OR (lower('date_modif') = lower(l_col_name)) THEN -- SYSPER
              l_select := l_select || 'TO_DATE('''|| to_char(sysdate, ds_utility_var.g_time_mask) ||''','''||ds_utility_var.g_time_mask||''')'; -- SYSPER              
            ELSE -- SYSPER
               l_select := l_select || 'TO_DATE('''||l_col_val||''','''||ds_utility_var.g_time_mask||''')';
            END IF; -- SYSPER
         ELSIF l_col_type LIKE 'TIMESTAMP%' THEN
            l_select := l_select || 'TO_TIMESTAMP('''||l_col_val||''','''||ds_utility_var.g_timestamp_mask||''')';
         ELSIF l_col_type = 'ROWID' THEN
            l_select := l_select || 'CHARTOROWID('''||l_col_val||''')';
         ELSIF l_col_type = 'NUMBER' THEN
            l_tab_col := LOWER(p_table_name||'.'||l_col_name);
            IF ds_utility_var.g_seq.EXISTS(l_tab_col) AND ds_utility_var.g_seq(l_tab_col).id_shift_value IS NULL THEN
              l_col_val_pk := l_col_val;
              l_select := l_select || 'ds_utility.set_identifier(' || ds_utility_var.g_seq(l_tab_col).table_id || ',' || l_col_val || ',' || LOWER(ds_utility_var.g_seq(l_tab_col).sequence_name) || '.nextval)';
            ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) AND ds_utility_var.g_map(l_tab_col).id_shift_value IS NULL THEN
              l_select := l_select || 'ds_utility.get_identifier(' || ds_utility_var.g_map(l_tab_col).table_id || ',' || l_col_val || ')';
            ELSE
              -- for versionable tables : create new record number -- SYSPER
              IF lower(get_table_alias(p_table_name, NULL) || '_rec_nbr') = lower(l_col_name) THEN -- SYSPER
               -- set record number the same as pk -- SYSPER
                 l_select := l_select || 'ds_utility.get_identifier(' || ds_utility_var.g_seq(  LOWER(p_table_name||'.'||get_table_alias(p_table_name, NULL) || '_id') ).table_id  || ',' || l_col_val_pk || ')'; -- SYSPER
              ELSIF lower('pet_seq_nbr_from') = lower(l_col_name) THEN -- SYSPER
                 l_select := l_select || '-999'; -- SYSPER
              ELSE -- SYSPER
                 l_select := l_select || l_col_val;
              END IF; -- SYSPER
            END IF;
         ELSE
            assert(FALSE,'Unsupported data type ('||l_col_type||') for column '||p_table_name||'.'||l_col_name);
         END IF;
       END IF;
     END LOOP;
     RETURN l_select;
   END;
--
--#begin public
/**
* Clone rows of the given data set into target tables
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE clone_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
     -- Cursor to browse data sets
     CURSOR c_set (
       p_set_id ds_tables.table_id%TYPE
     ) IS
       SELECT *
         FROM ds_data_sets
        WHERE (p_set_id IS NULL OR set_id = p_set_id)
     ;
     -- Cursor to browse tables of a data set in the right order
     CURSOR c_tab (
       p_set_id ds_data_sets.set_id%TYPE
      ,p_order INTEGER
     ) IS
       SELECT *
         FROM ds_tables
        WHERE set_id = p_set_id
         AND extract_type != 'N'
        ORDER BY seq * p_order ASC
     ;
     l_sql CLOB;
     l_result VARCHAR2(32767);
     l_row_count INTEGER;
     l_sel_columns ds_tables.columns_list%TYPE;
     l_ins_columns ds_tables.columns_list%TYPE;
     l_count INTEGER;
     l_cursor INTEGER;  
     l_pass_count INTEGER;
     l_order INTEGER;
     l_src_table_name VARCHAR2(100);
     l_tgt_table_name VARCHAR2(100);
   BEGIN
     FOR r_set IN c_set(p_set_id) LOOP
       define_walk_through_strategy(r_set.set_id);
       l_order := 1;
       init_seq(r_set.set_id);
       FOR r_tab IN c_tab(r_set.set_id,l_order) LOOP
         l_src_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
         l_tgt_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,r_tab.target_db_link);
         -- Optimisation: do not process empty tables
         IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N'
         THEN
            l_ins_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
            assert(l_ins_columns IS NOT NULL,'List of columns to insert is empty for table '||r_tab.table_name);         
            l_sel_columns := l_ins_columns;        
            FOR l_pass_index IN REVERSE 1..r_tab.group_count LOOP
              l_pass_count := l_pass_index;
              /* Select rows to extract */
              l_sql :=
   '
   SELECT '||build_select_clause(r_tab.table_name,l_sel_columns,7,'N')||'
   FROM '||l_src_table_name||'
   WHERE 1=1';
              IF r_tab.extract_type != 'F' THEN
                l_sql := l_sql ||
   '
   AND rowid IN (
        SELECT record_rowid
         FROM ds_records
         WHERE table_id = '||r_tab.table_id||'
          AND pass_count = '||l_pass_count||'
          AND NVL(deleted_flag,''N'') = ''N''
      )';
              END IF;
              l_cursor := sys.dbms_sql.open_cursor;
              sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
              sys.dbms_sql.define_column(l_cursor,1,l_result,32767);
              l_count := sys.dbms_sql.execute(l_cursor);
              l_row_count := 0;
              WHILE sys.dbms_sql.fetch_rows(l_cursor) > 0
              LOOP
                l_sql := NULL;
                l_row_count := l_row_count + 1;
                sys.dbms_sql.column_value(l_cursor,1,l_result);             
                l_sql := l_sql ||
   '
   INSERT INTO '||l_tgt_table_name||' (
   '||format_columns_list(l_ins_columns,3,'Y')||'
   ) VALUES (
   '||build_values_clause_for_ver_tb(r_tab.table_name,l_sel_columns,l_result,0,3,'Y')||'
   );'; --SYSPER
                 EXECUTE IMMEDIATE 'BEGIN ddl_utility.execute_immediate(:1); END; 'USING 'BEGIN '||l_sql||CHR(10)||' END;';
                                  
              END LOOP;
              sys.dbms_sql.close_cursor(l_cursor);
            END LOOP;
         END IF;
       END LOOP;
     END LOOP;
   END;
--
--#begin public
/**
* Create a SQL script to delete data set
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE delete_data_set_via_script (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
    , p_db_link IN VARCHAR2 := NULL -- execute script via given db_link
   )
--#end public
   IS
   BEGIN
      handle_data_set_via_script(p_set_id,TRUE,p_db_link, FALSE);
   END;
   ---
   -- Delete a data set
   -- DEPRECATED IMPLEMENTATION - Replaced with handle_data_set()
   ---
--   PROCEDURE delete_data_set (
--      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
--   ) IS
--      -- Cursor to browse data sets
--      CURSOR c_set (
--         p_set_id ds_tables.table_id%TYPE
--      ) IS
--         SELECT *
--           FROM ds_data_sets
--          WHERE (p_set_id IS NULL OR set_id = p_set_id)
--      ;
--      -- Cursor to browse tables of a data set in the right order
--      CURSOR c_tab (
--         p_set_id ds_data_sets.set_id%TYPE
--      ) IS
--         SELECT *
--           FROM ds_tables
--          WHERE set_id = p_set_id
--            AND extract_type != 'N'
--          ORDER BY seq DESC
--      ;
--      l_sql VARCHAR2(4000);
--      l_row_count INTEGER;
--   BEGIN
--      FOR r_set IN c_set(p_set_id) LOOP
--         define_walk_through_strategy(r_set.set_id);
--         FOR r_tab IN c_tab(r_set.set_id) LOOP
--            -- Optimisation: do not process empty tables
--            IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N' THEN
--               -- For each record group
--               FOR l_pass_count IN 1..r_tab.group_count LOOP
--                  l_sql :=
--'
--DELETE '||LOWER(r_tab.table_name);
--                  IF r_tab.extract_type != 'F' THEN
--                     l_sql := l_sql ||
--'
-- WHERE rowid IN (
--          SELECT record_rowid
--            FROM ds_records
--           WHERE table_id = '||r_tab.table_id||'
--             AND pass_count = '||l_pass_count||'
--       )
--';
--                  END IF;
--                  l_row_count := execute_immediate(l_sql);
--               END LOOP;
--            END IF;
--         END LOOP;
--      END LOOP;
--   END;
--
--#begin public
/**
* Delete records that are part of the given data set
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE delete_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
--#end public
   IS
   BEGIN
      handle_data_set(p_set_id=>p_set_id,p_oper=>'DIRECT-EXECUTE',p_mode=>'D');
   END;
   ---
   -- Move a data set
   -- DEPRECATED IMPLEMENTATION - Replaced with hanlde_data_set()
   ---
--   PROCEDURE move_data_set (
--      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
--   ) IS
--   BEGIN
--      copy_data_set(p_set_id);
--      delete_data_set(p_set_id);
--   END;
--
--#begin public
/**
* Move records that are part of the given data set
* DEPRECATED - Replaced with handle_data_set()
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE move_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
--#end public
   IS
   BEGIN
      handle_data_set(p_set_id=>p_set_id,p_oper=>'DIRECT-EXECUTE',p_mode=>'M');
   END;
--/*
--#begin public
/**
* Export a data set to XML. XML of fully extracted tables (extract type F)
* is stored in the CLOB of the table itself (i.e. one XML per table). XML of
* partially extracted tables (extract type P) is stored at the record level
* (i.e. one XML per record).
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE export_data_set_to_xml (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
--#end public
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      -- Cursor to browse tables of a data set
      CURSOR c_tab (
         p_set_id ds_tables.table_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type != 'N'
            FOR UPDATE OF table_data
      ;
      -- Cursor to browse records of a table
      CURSOR c_rec (
         p_table_id IN ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_records
          WHERE table_id = p_table_id
            AND NVL(deleted_flag,'N') = 'N'
            FOR UPDATE OF record_data
      ;
      l_sql VARCHAR2(4000);
      l_ctx dbms_xmlquery.ctxtype;
      l_sel_columns ds_tables.columns_list%TYPE;
   BEGIN
      -- For each data set
      FOR r_set IN c_set(p_set_id) LOOP
         -- Reset XML data stored at table level
         UPDATE ds_tables
            SET table_data = NULL
          WHERE set_id = r_set.set_id
            AND table_data IS NOT NULL
         ;
         -- Reset XML data stored at record level
         UPDATE ds_records
            SET record_data = NULL
          WHERE table_id IN (
                   SELECT table_id
                     FROM ds_tables
                    WHERE set_id = r_set.set_id
                )
            AND record_data IS NOT NULL
         ;
         -- For each table in data set
         FOR r_tab IN c_tab(r_set.set_id) LOOP
            IF r_tab.columns_list IS NULL THEN
               l_sel_columns := '*';
            ELSE
               l_sel_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
            END IF;
            IF r_tab.extract_type = 'F' THEN
               l_sql :=
'
SELECT '||l_sel_columns||'
  FROM '||LOWER(r_tab.table_name);
               show_message('S',l_sql);
               l_ctx := sys.dbms_xmlquery.newcontext(l_sql);
               sys.dbms_xmlquery.setrowtag(l_ctx,r_tab.table_name);
               IF ds_utility_var.g_xml_dateformat IS NOT NULL THEN
                  sys.dbms_xmlquery.setdateformat(l_ctx,ds_utility_var.g_xml_dateformat);
               END IF;
               r_tab.table_data := sys.dbms_xmlquery.getxml(l_ctx);
               UPDATE ds_tables
                  SET table_data = r_tab.table_data
                WHERE CURRENT OF c_tab;
               sys.dbms_xmlquery.closecontext(l_ctx);
            -- Optimisation: do not process empty tables
            ELSIF r_tab.extract_count > 0 THEN
               l_sql :=
'
SELECT '||l_sel_columns||'
  FROM '||LOWER(r_tab.table_name)||'
 WHERE rowid=:record_rowid';
               show_message('S',l_sql);
               l_ctx := sys.dbms_xmlquery.newcontext(l_sql);
               sys.dbms_xmlquery.setrowtag(l_ctx,r_tab.table_name);
               IF ds_utility_var.g_xml_dateformat IS NOT NULL THEN
                  sys.dbms_xmlquery.setdateformat(l_ctx,ds_utility_var.g_xml_dateformat);
               END IF;
               FOR r_rec IN c_rec(r_tab.table_id) LOOP
                  sys.dbms_xmlquery.setbindvalue(l_ctx,'record_rowid',r_rec.record_rowid);
                  r_rec.record_data := sys.dbms_xmlquery.getxml(l_ctx);
                  UPDATE ds_records
                     SET record_data = r_rec.record_data
                   WHERE CURRENT OF c_rec
                  ;
               END LOOP;
               sys.dbms_xmlquery.closecontext(l_ctx);
            END IF;
         END LOOP;
      END LOOP;
   END;
--
--#begin public
/**
* Import a data set from XML. Each record of the XML is inserted back to its
* original table. See export procedure for a description of where XML is stored.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE import_data_set_from_xml (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
   )
--#end public
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      -- Cursor to browse tables of a data set
      CURSOR c_tab (
         p_set_id ds_tables.table_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type != 'N'
          ORDER BY seq ASC
      ;
      -- Cursor to browse records of a table
      CURSOR c_rec (
         p_table_id IN ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_records
          WHERE table_id = p_table_id
            AND NVL(deleted_flag,'N') = 'N'
       ORDER BY pass_count DESC
         ;
      l_ctx dbms_xmlsave.ctxtype;
      l_count INTEGER;
   BEGIN
      FOR r_set IN c_set(p_set_id) LOOP
         define_walk_through_strategy(r_set.set_id);
         FOR r_tab IN c_tab(r_set.set_id) LOOP
            l_ctx := sys.dbms_xmlsave.newcontext(
               CASE WHEN r_tab.target_schema IS NOT NULL THEN r_tab.target_schema||'.' END
             ||NVL(r_tab.target_table_name,r_tab.table_name)
             ||CASE WHEN r_tab.target_db_link IS NOT NULL THEN '@' END||r_tab.target_db_link);
--            l_ctx := sys.dbms_xmlsave.newcontext(r_tab.table_name);
            IF ds_utility_var.g_xml_dateformat IS NOT NULL THEN
               sys.dbms_xmlsave.setdateformat(l_ctx,ds_utility_var.g_xml_dateformat);
            END IF;
            IF ds_utility_var.g_xml_batchsize IS NOT NULL THEN
               sys.dbms_xmlsave.setbatchsize(l_ctx,ds_utility_var.g_xml_batchsize);
            END IF;
            IF ds_utility_var.g_xml_commitbatch IS NOT NULL THEN
               sys.dbms_xmlsave.setcommitbatch(l_ctx,ds_utility_var.g_xml_commitbatch);
            END IF;
            sys.dbms_xmlsave.setrowtag(l_ctx,r_tab.table_name);
            IF r_tab.extract_type = 'F' THEN
               l_count := sys.dbms_xmlsave.insertxml(l_ctx,r_tab.table_data);
            -- Optimisation: do not process empty tables
            ELSIF r_tab.extract_count > 0 THEN
               FOR r_rec IN c_rec(r_tab.table_id) LOOP
                  l_count := sys.dbms_xmlsave.insertxml(l_ctx,r_rec.record_data);
               END LOOP;
            END IF;
            sys.dbms_xmlsave.closecontext(l_ctx);
         END LOOP;
      END LOOP;
   END;
--
--#begin public
/**
* Return true expression (internal usage - for security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION true_expression (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN NULL; -- evaluates to TRUE (equivalent to 1=1)
   END;
--
--#begin public
/**
* Return false expression (internal usage - for security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION false_expression (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN '1=0'; -- evaluates to FALSE
   END;
--
--#begin public
/**
* Return table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   FUNCTION get_table_filter (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
    , p_mode IN VARCHAR2 := NULL -- S,D
    , p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
   RETURN VARCHAR2
--#end public
   IS
      l_sql VARCHAR2(4000);
      l_set VARCHAR2(100);
   BEGIN
      IF p_set_id IS NULL THEN
         l_set := 'ds_set.visible_flag = ''Y''';
      ELSE
         l_set := 'ds_set.set_id = '||p_set_id;
      END IF;
      IF NVL(p_mode,'S') = 'D' THEN
         l_sql :=
'EXISTS (
          SELECT ''x''
            FROM ds_data_sets ds_set, ds_tables ds_tab
           WHERE '||l_set||'
             AND ds_tab.set_id = ds_set.set_id
             AND ds_tab.table_name = '''||p_object_name||'''
             AND ds_tab.extract_type = ''F''
       )
    OR ';
      ELSE
         l_sql := '';
      END IF;
      l_sql := l_sql ||
      'rowid IN (
          SELECT ds_rec.record_rowid
            FROM ds_data_sets ds_set, ds_tables ds_tab, ds_records ds_rec
           WHERE '||l_set||'
             AND ds_tab.set_id = ds_set.set_id
             AND ds_tab.table_name = '''||p_object_name||'''
             AND ds_tab.extract_type IN (''B'',''P'')
             AND ds_rec.table_id = ds_tab.table_id
             AND NVL(ds_rec.deleted_flag,''N'') = ''N''
       )';
      RETURN l_sql;
   END;
--
--#begin public
/**
* Return static table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION get_table_filter_stat (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN get_table_filter(p_object_schema,p_object_name,'S');
   END;
--
--#begin public
/**
* Return dynamic table filter (internal usage - for views and security policies).
* @param p_object_schema schema name
* @param p_object_name table name
*/
   FUNCTION get_table_filter_dyn (
      p_object_schema IN VARCHAR2
    , p_object_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      RETURN get_table_filter(p_object_schema,p_object_name,'D');
   END;
   ---
   -- Create or drop views or policies
   ---
   PROCEDURE create_drop_objects (
      p_operation IN VARCHAR2 -- CREATE or DROP
     ,p_object_type IN VARCHAR2 -- VIEW, TABLE or POLICY
     ,p_object_suffix IN VARCHAR2 := NULL  -- suffix to add to object name
     ,p_object_prefix IN VARCHAR2 := NULL  -- prefix to add to object name
     ,p_table_prefix IN VARCHAR2 := NULL   -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_mode IN VARCHAR2 := NULL -- (S)tatic or (D)ynamic
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- view only this data set
     ,p_object_options IN VARCHAR2 := NULL -- object options
   ) IS
      -- Cursor to browse all tables to extract
      CURSOR c_tab (
         p_owner sys.all_tables.owner%TYPE
        ,p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT usr.table_name
              , DECODE(p_set_id,NULL,'',ds_tab.columns_list) columns_list
              , MAX(ds_tab.table_id) max_table_id
              , DECODE(MAX(DECODE(ds_tab.extract_type,'F',2,'P',1,'B',1,0)),2,'F',1,'P',0,'N') extract_type
              , MAX(ds_tab.extract_count) extract_count
           FROM sys.all_tables usr
           LEFT OUTER JOIN ds_tables ds_tab
             ON ds_tab.table_name = usr.table_name
          WHERE usr.owner = p_owner
            AND (p_set_id IS NULL OR ds_tab.set_id = p_set_id)
          GROUP BY usr.table_name, DECODE(p_set_id,NULL,'',ds_tab.columns_list)
          ORDER BY 1
      ;
      l_table_prefix_len INTEGER := NVL(LENGTH(p_table_prefix),0);
      l_object_suffix_len INTEGER;
      l_object_suffix VARCHAR(30);
      l_object_name VARCHAR2(30);
      l_sql VARCHAR2(4000);
      l_filter VARCHAR2(4000);
      l_policy_function VARCHAR2(100);
      l_sel_columns ds_tables.columns_list%TYPE;
      l_view_columns ds_tables.columns_list%TYPE;
      l_op VARCHAR2(30);
   BEGIN
      -- Define object name
      IF p_object_suffix IS NULL AND p_object_prefix IS NULL AND p_table_prefix IS NULL THEN
         l_object_suffix := '_' || SUBSTR(p_object_type,1,1);
      ELSE
         l_object_suffix := p_object_suffix;
      END IF;
      l_object_suffix_len := NVL(LENGTH(l_object_suffix),0);
      -- For each schema table
      FOR r_tab IN c_tab(ds_utility_var.g_owner,p_set_id) LOOP
         l_sql := NULL;
         -- Filter table
         IF NOT p_full_schema THEN
            -- Ignore tables that are not in any data set
            IF r_tab.max_table_id IS NULL THEN
               GOTO next_table;
            END IF;
            -- If asked so, do not create object when no row to extract
            IF p_non_empty_only AND (r_tab.extract_type = 'N' OR r_tab.extract_count <= 0)
            THEN
               GOTO next_table;
            END IF;
         END IF;
         -- Build object name
         IF  p_table_prefix IS NOT NULL
         AND SUBSTR(r_tab.table_name,1,l_table_prefix_len) = p_table_prefix
         THEN
            l_object_name := SUBSTR(r_tab.table_name,l_table_prefix_len+1);
         ELSE
            l_object_name := r_tab.table_name;
         END IF;
         l_object_name := SUBSTR(p_object_prefix||l_object_name,1,30);
         IF l_object_suffix IS NOT NULL THEN
            l_object_name := SUBSTR(l_object_name,1,30-l_object_suffix_len)||l_object_suffix;
         END IF;
         l_object_name := LOWER(l_object_name);
         IF p_object_type IN ('TABLE','VIEW') THEN
            IF p_operation = 'DROP' THEN
               l_sql :=
'
DROP '||p_object_type||' '||l_object_name;
            ELSE
               IF NVL(p_mode,'S') = 'S' AND r_tab.extract_type IN ('F','N') THEN
                  IF r_tab.extract_type = 'F' THEN
                     l_filter := '1=1'; -- Full extract => true expression
                  ELSE -- 'N'
                     l_filter := '1=0'; -- No extract => false expression
                  END IF;
               ELSE
                  l_filter := get_table_filter(USER,r_tab.table_name,p_mode,p_set_id);
               END IF;
               IF p_object_type = 'TABLE' AND r_tab.columns_list IS NULL THEN
                  l_sel_columns  := '*';
                  l_view_columns := NULL;
               ELSE
                  l_sel_columns  := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
                  l_view_columns := '('||l_sel_columns||')';
               END IF;
               IF p_object_type = 'TABLE' THEN
                  l_filter := '1=0'; -- create empty table
                  l_op := 'CREATE';
               ELSE
                  l_op := 'CREATE OR REPLACE';
               END IF;
               l_sql :=
'
'||l_op||' '||p_object_type||' '||l_object_name||l_view_columns||' '||p_object_options||'
AS
SELECT '||CASE WHEN p_object_type = 'TABLE' THEN l_sel_columns ELSE build_select_for_subquery(r_tab.table_name,NULL,l_sel_columns,7,'N',3,NULL,'N') END||'
  FROM '||LOWER(r_tab.table_name)||'
 WHERE '||l_filter;
            END IF;
         ELSIF p_object_type = 'POLICY'
           AND r_tab.table_name NOT LIKE 'DS~_%' ESCAPE '~' -- records of DS tables cannot be hidden!!!
          THEN
            IF p_operation = 'DROP' THEN
               l_sql :=
'BEGIN
   sys.dbms_rls.drop_policy(
      object_name=>'''||LOWER(r_tab.table_name)||'''
     ,policy_name=>'''||l_object_name||'''
   );
END;';
            ELSE
               IF NVL(p_mode,'S') = 'S' THEN
                  IF r_tab.extract_type = 'F' THEN
                     l_policy_function := 'ds_utility.true_expression';
                  ELSIF r_tab.extract_type = 'N' THEN
                     l_policy_function := 'ds_utility.false_expression';
                  ELSE
                     l_policy_function := 'ds_utility.get_table_filter_stat';
                  END IF;
               ELSE
                  l_policy_function := 'ds_utility.get_table_filter_dyn';
               END IF;
               l_sql :=
'BEGIN
   sys.dbms_rls.add_policy(
      object_name=>'''||LOWER(r_tab.table_name)||'''
     ,policy_name=>'''||l_object_name||'''
     ,policy_function=>'''||l_policy_function||'''
   );
END;';
            END IF;
         END IF;
         IF l_sql IS NOT NULL THEN
log_utility.log_message('D','executing: '||l_sql);
            execute_immediate(l_sql,p_operation='DROP');
         END IF;
         <<next_table>>
         NULL;
      END LOOP;
   END;
--
--#begin public
/**
* Create views used to preview data sets. One view is created for each table of
* the data sets. View name is derived from the underlying table name. The possibility
* is given to add a prefix or a suffix to the view name as well as to remove a prefix
* from the underlying table name. Only data sets marked as visible will be shown in
* these views.
* @param p_view_suffix view suffix
* @param p_view_prefix view prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_views (
      p_view_suffix IN VARCHAR2 := NULL  -- suffix to add to view name
     ,p_view_prefix IN VARCHAR2 := NULL  -- prefix to add to view name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_mode IN VARCHAR2 := NULL -- (S)tatic or (D)ynamic
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
--#end public
   IS
   BEGIN
      create_drop_objects('CREATE','VIEW',p_view_suffix,p_view_prefix,p_table_prefix,p_full_schema,p_non_empty_only,p_mode,p_set_id);
   END;
--
--#begin public
/**
* Drop views used to preview data sets. See create_views() for a description on how
* view names are built.
* @param p_view_suffix view suffix
* @param p_view_prefix view prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_views (
      p_view_suffix IN VARCHAR2 := NULL  -- suffix to add to view name
     ,p_view_prefix IN VARCHAR2 := NULL  -- prefix to add to view name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
--#end public
   IS
   BEGIN
      create_drop_objects('DROP','VIEW',p_view_suffix,p_view_prefix,p_table_prefix,p_full_schema,p_non_empty_only,NULL,p_set_id);
   END;
--
--#begin public
/**
* Create policies used to export data sets. One policy is created for each table
* of the data sets. Policy name is derived from the underlying table name. The possibility
* is given to add a prefix or a suffix to the policy name as well as to remove a prefix
* from the underlying table name. Security policies will only let access records that
* belong to data sets marked as visible.
* @param p_policy_suffix policy suffix
* @param p_policy_prefix policy prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_mode S=Static(quicker), D=Dynamic(slower)
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_policies (
      p_policy_suffix IN VARCHAR2 := NULL  -- suffix to add to policy name
     ,p_policy_prefix IN VARCHAR2 := NULL  -- prefix to add to policy name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_mode IN VARCHAR2 := NULL -- (S)tatic or (D)ynamic
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
--#end public
   IS
   BEGIN
      create_drop_objects(
         p_operation=>'CREATE', p_object_type=>'POLICY', p_object_suffix=>p_policy_suffix
       , p_object_prefix=>p_policy_prefix, p_table_prefix=>p_table_prefix, p_full_schema=>p_full_schema
       , p_non_empty_only=>FALSE, p_mode=>p_mode, p_set_id=>p_set_id
      );
   END;
--
--#begin public
/**
* Drop policies used to export data sets. See create_policies() for a description on
* how policy names are built.
* @param p_policy_suffix policy suffix
* @param p_policy_prefix policy prefix
* @param p_table_prefix removed from view name
* @param p_full_schema include schema tables not in any data set?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_policies (
      p_policy_suffix IN VARCHAR2 := NULL  -- suffix to add to policy name
     ,p_policy_prefix IN VARCHAR2 := NULL  -- prefix to add to policy name
     ,p_table_prefix IN VARCHAR2 := NULL -- prefix to remove from table name
     ,p_full_schema IN BOOLEAN := FALSE -- include all schema tables not in data sets?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (null for all)
   )
--#end public
   IS
   BEGIN
      create_drop_objects(
         p_operation=>'DROP', p_object_type=>'POLICY', p_object_suffix=>p_policy_suffix
       , p_object_prefix=>p_policy_prefix, p_table_prefix=>p_table_prefix, p_full_schema=>p_full_schema
       , p_non_empty_only=>FALSE, p_set_id=>p_set_id
      );
   END;
--
--#begin public
/**
* Create target tables (when copying data set between tables)
* @param p_target_suffix target table suffix
* @param p_target_prefix target table prefix
* @param p_source_prefix source table prefix
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE create_tables (
      p_target_suffix IN VARCHAR2 := NULL  -- suffix to add to target table name
     ,p_target_prefix IN VARCHAR2 := NULL  -- prefix to add to target table name
     ,p_source_prefix IN VARCHAR2 := NULL  -- prefix to remove from source table name
     ,p_full_schema IN BOOLEAN := FALSE    -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id (NULL means all)
     ,p_table_options IN VARCHAR2 := NULL  -- table options
   )
--#end public
   IS
   BEGIN
      create_drop_objects('CREATE','TABLE',p_target_suffix,p_target_prefix,p_source_prefix,p_full_schema,p_non_empty_only,NULL,p_set_id,p_table_options);
   END;
--
--#begin public
/**
* Drop tables
* @param p_target_suffix target table suffix
* @param p_target_prefix target table prefix
* @param p_source_prefix source table prefix
* @param p_full_schema include schema tables not in any data set?
* @param p_non_empty_only include only non empty tables?
* @param p_set_id data set id (null for all)
*/
   PROCEDURE drop_tables (
      p_target_suffix IN VARCHAR2 := NULL  -- suffix to add to target table name
     ,p_target_prefix IN VARCHAR2 := NULL  -- prefix to add to target table name
     ,p_source_prefix IN VARCHAR2 := NULL  -- prefix to remove from source table name
     ,p_full_schema IN BOOLEAN := FALSE -- include schema tables not in data sets?
     ,p_non_empty_only IN BOOLEAN := FALSE -- only non-empty table?
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- view only this data set
     ,p_table_options IN VARCHAR2 := NULL  -- table options (not used)
   )
--#end public
   IS
   BEGIN
      create_drop_objects('DROP','TABLE',p_target_suffix,p_target_prefix,p_source_prefix,p_full_schema,p_non_empty_only,p_set_id);
   END;
--
--#begin public
/**
* Define the new value of an identifier
* @param p_table_id     table id
* @param p_old_id       old value of the identifier
* @param p_new_id       new value of the identifier
* @return               new value of the identifier
*/
   FUNCTION set_identifier (
      p_table_id ds_identifiers.table_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
    , p_new_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      CURSOR c_sid (
         p_table_id ds_identifiers.table_id%TYPE
       , p_old_id ds_identifiers.old_id%TYPE
      )
      IS
         SELECT new_id
           FROM ds_identifiers
          WHERE table_id = p_table_id
            AND old_id = p_old_id
         ;
      l_new_id ds_identifiers.new_id%TYPE;
      l_found BOOLEAN;
   BEGIN
      OPEN c_sid(p_table_id,p_old_id);
      FETCH c_sid INTO l_new_id;
      l_found := c_sid%FOUND;
      CLOSE c_sid;
      IF l_found THEN
         RETURN l_new_id;
      ELSE
         INSERT INTO ds_identifiers (
            table_id, old_id, new_id
         ) VALUES (
            p_table_id, p_old_id, p_new_id
         );
      END IF;
      RETURN p_new_id;
   END;
--
--#begin public
/**
* Get the new value of an identifier from its old value
* @param p_table_id     table_id
* @param p_old_id       old value of the identifier
* @return               new value of the identifier
*/
   FUNCTION get_identifier (
      p_table_id ds_identifiers.table_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      CURSOR c_sid (
         p_table_id ds_identifiers.table_id%TYPE
       , p_old_id ds_identifiers.old_id%TYPE
      )
      IS
         SELECT new_id
           FROM ds_identifiers
          WHERE table_id = p_table_id
            AND old_id = p_old_id
         ;
      l_new_id ds_identifiers.new_id%TYPE;
   BEGIN
      OPEN c_sid(p_table_id,p_old_id);
      FETCH c_sid INTO l_new_id;
      CLOSE c_sid;
      RETURN NVL(l_new_id,p_old_id);
   END;
--
--#begin public
/**
* Get a data set record by id
* @param p_set_id       if of a data set
* @return               data set record
*/
   FUNCTION get_data_set_rec_by_id (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   RETURN ds_data_sets%ROWTYPE
--#end public
   IS
      r_set ds_data_sets%ROWTYPE;
      CURSOR c_set (
         p_set_id IN ds_data_sets.set_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
         ;
   BEGIN
      r_set := NULL;
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      CLOSE c_set;
      RETURN r_set;
   END;
--
--#begin public
/**
* Get table record by id
* @param p_table_id     if of data set table
* @return               table record
*/
   FUNCTION get_table_rec_by_id (
      p_table_id ds_tables.table_id%TYPE
   )
   RETURN ds_tables%ROWTYPE
--#end public
   IS
      CURSOR c_tab (
         p_table_id ds_tables.table_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE table_id = p_table_id
      ;
      r_tab ds_tables%ROWTYPE;
   BEGIN
      r_tab := NULL;
      OPEN c_tab(p_table_id);
      FETCH c_tab INTO r_tab;
      CLOSE c_tab;
      RETURN r_tab;
   END;
--
--#begin public
/**
* Capture an operation performed on a table
* @param p_set_id       data set id
* @param p_table_id     table id
* @param p_record_rowid rowid
* @param p_operation    operation (I=Insert, U=Update, D=Delete)
* @param p_xml_new      xml of record after operation (I,U)
* @param p_xml_old      xml of record before operation (D,U)
* @return               new value of the identifier
*/
   PROCEDURE capture_operation (
      p_set_id IN ds_data_sets.set_id%TYPE -- set id
    , p_table_id IN ds_records.table_id%TYPE -- table id
    , p_record_rowid IN ds_records.record_rowid%TYPE -- rowid
    , p_operation IN ds_records.operation%TYPE -- I)nsert, U)pdate, D)elete
    , p_user_name IN ds_records.user_name%TYPE
    , p_xml_new CLOB -- new record
    , p_xml_old CLOB -- old record
   )
--#end public
   IS
      CURSOR c_set (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
            FOR UPDATE OF capture_seq
      ;
      r_set c_set%ROWTYPE;
      l_found BOOLEAN;
      l_capture_bool BOOLEAN := FALSE;
   BEGIN
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      l_found := c_set%FOUND;
      l_capture_bool := l_found AND r_set.capture_flag = 'Y' AND (r_set.capture_user IS NULL OR r_set.capture_user = p_user_name);
      IF l_capture_bool THEN
         r_set.capture_seq := NVL(r_set.capture_seq,0)+1;
         UPDATE ds_data_sets
            SET capture_seq = r_set.capture_seq
          WHERE CURRENT OF c_set;
      END IF;
      CLOSE c_set;
      assert(l_found,'Data set '||p_set_id||' not found!');
      IF l_capture_bool THEN
         -- Delete all undone operations
         DELETE ds_records
          WHERE table_id IN (
                   SELECT table_id
                     FROM ds_tables
                    WHERE set_id = p_set_id
                )
            AND undo_timestamp IS NOT NULL
            AND (p_user_name IS NULL OR user_name = p_user_name)
         ;
         -- Record current operation
         INSERT INTO ds_records (
            table_id, record_rowid, operation, seq
          , user_name, record_data, record_data_old
         ) VALUES (
            p_table_id, p_record_rowid, p_operation, r_set.capture_seq
          , p_user_name, p_xml_new, p_xml_old
         );
         -- Create a job to roll forward captured operations if FWD mode enabled
         IF INSTR(UPPER(r_set.capture_mode),'FWD')>0 THEN
            create_capture_forwarding_job(p_set_id);
         END IF;
      END IF;
   END;
   ---
   -- Get pk columns
   ---
   FUNCTION get_pk_columns (
      p_table_name IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_pk_columns ds_tables.columns_list%TYPE;
      l_pk_name sys.all_constraints.constraint_name%TYPE;
   BEGIN
      l_pk_name := get_table_pk(p_table_name);
      assert(l_pk_name IS NOT NULL,'Table '||p_table_name||' has no primary key');
      l_pk_columns := get_constraint_columns(l_pk_name);
      assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no columns');
      RETURN l_pk_columns;
   END;
   ---
   -- Prefix table columns with table alias
   ---
   FUNCTION prefix_columns (
      p_expression IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_column_name VARCHAR2(30);
      l_expression VARCHAR2(4000) := p_expression;
      l_expr_upper VARCHAR2(4000) := UPPER(p_expression);
      l_idx INTEGER := 1;
      l_start_idx INTEGER := 1;
      l_char VARCHAR2(1);
      l_found BOOLEAN;
      l_count INTEGER;
      t_col_name ds_utility_var.column_name_table;
   BEGIN
      t_col_name := get_table_columns2(p_table_name);
      FOR i IN 1..t_col_name.COUNT LOOP
         l_column_name := UPPER(t_col_name(i));
         l_start_idx := 1;
         l_count := 0;
         WHILE l_start_idx > 0 LOOP
            l_count := l_count + 1;
            assert(l_count<=100,'Infinite loop detected in prefix_columns()');
            l_idx := NVL(INSTR(l_expr_upper,l_column_name,l_start_idx),0);
            IF l_idx > 0 THEN
               l_found := TRUE;
               IF l_idx > 2 THEN
                  l_char := SUBSTR(l_expr_upper,l_idx-1,1);
                  l_found := l_char NOT IN ('.',':') AND NOT (l_char BETWEEN 'A' AND 'Z' OR l_char BETWEEN '0' AND '9' OR l_char IN ('_'));
               END IF;
               IF l_found AND l_idx + LENGTH(l_column_name) < LENGTH(l_expression) THEN
                  l_char := SUBSTR(l_expression,l_idx+LENGTH(l_column_name),1);
                  l_found := NOT (l_char BETWEEN 'A' AND 'Z' OR l_char BETWEEN '0' AND '9' OR l_char IN ('_'));
               END IF;
               IF l_found THEN
                  l_expr_upper := SUBSTR(l_expr_upper,1,l_idx-1)
                               || LOWER(p_table_alias)||'.'||LOWER(l_column_name)
                               || SUBSTR(l_expr_upper,l_idx+LENGTH(l_column_name));
                  l_expression := SUBSTR(l_expression,1,l_idx-1)
                               || LOWER(p_table_alias)||'.'||LOWER(l_column_name)
                               || SUBSTR(l_expression,l_idx+LENGTH(l_column_name));
               END IF;
               l_start_idx := l_idx + 1;
            ELSE
               l_start_idx := 0;
            END IF;
         END LOOP;
      END LOOP;
      RETURN l_expression;
   END;
--
--#begin public
/**
* Create triggers for capturing operations
* @param p_set_id       data set id
*/
   PROCEDURE create_triggers (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_ignore_errors IN VARCHAR2 := 'N'
   )
--#end public
   IS
      -- Cursor to browse all tables to extract
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
         ;
      l_sql CLOB;
      l_tmp VARCHAR2(4000);
      t_col_name ds_utility_var.column_name_table;
      t_col_type ds_utility_var.column_type_table;
      l_col VARCHAR2(30);
      l_colu VARCHAR2(30);
      l_type VARCHAR2(30);
      l_count INTEGER;
      l_pk_col ds_utility_var.column_name_table;
      l_tab_name VARCHAR2(60);
      l_where VARCHAR2(4000);
      l_export_mode VARCHAR2(10);
      l_xml_capture BOOLEAN;
      l_exp_capture BOOLEAN;
      r_set ds_data_sets%ROWTYPE;
      l_columns_list ds_tables.columns_list%TYPE;
   BEGIN
      r_set := get_data_set_rec_by_id(p_set_id);
      assert(r_set.set_id=p_set_id,'Invalid data set id!');
      l_xml_capture := INSTR(UPPER(NVL(r_set.capture_mode,'XML')),'XML')>0;
      l_exp_capture := INSTR(UPPER(NVL(r_set.capture_mode,'XML')),'EXP')>0;
      FOR r_tab IN c_tab(p_set_id) LOOP
         log_utility.log_message('D','Creating trigger for '||r_tab.table_name);
         l_columns_list := r_tab.columns_list;
         IF NVL(l_columns_list,'*') != '*' THEN
            l_columns_list := normalise_columns_list(r_tab.table_name,l_columns_list);
         END IF;
         -- When some columns are listed, mandatory and pk columns are also included
         get_col_names_and_types(r_tab.table_name,NULL,NULL,t_col_name,t_col_type,l_columns_list);
         r_tab.table_name := LOWER(r_tab.table_name);
         l_sql :=
'CREATE OR REPLACE TRIGGER post_iud_ds'||p_set_id||'_tab'||r_tab.table_id||' 
AFTER INSERT OR UPDATE OR DELETE ON '||LOWER(r_tab.table_name)||'
REFERENCING OLD AS old NEW AS new 
FOR EACH ROW '||/*CASE WHEN r_set.capture_user IS NOT NULL THEN 'WHEN (USER='''||r_set.capture_user||''')' END*/''||'
DECLARE
   l_set_id ds_data_sets.set_id%TYPE := '||p_set_id||';
   l_table_id ds_records.table_id%TYPE := '||r_tab.table_id||';
   l_user_name ds_records.user_name%TYPE;
   r_set ds_data_sets%ROWTYPE;
   r_rec_old '||r_tab.table_name||'%ROWTYPE;
   r_rec_new '||r_tab.table_name||'%ROWTYPE;';
         IF l_xml_capture THEN
            l_sql := l_sql ||
'
   l_xml_old CLOB;
   l_xml_new CLOB;
   ---
   -- Push record
   ---
   FUNCTION push_record (
      r_rec IN '||r_tab.table_name||'%ROWTYPE
   )
   RETURN CLOB
   IS
      l_rec CLOB;
   BEGIN
      sys.dbms_lob.createtemporary(l_rec, TRUE);
      l_rec := ''''';
         FOR i IN 1..t_col_name.COUNT LOOP
            l_col  := LOWER(t_col_name(i));
            l_colu := UPPER(t_col_name(i));
            l_type := UPPER(t_col_type(i));
            IF l_type = 'DATE' THEN --OR l_type LIKE '%TIMESTAMP%' THEN
               l_tmp := '||''<'||l_colu||'>''||TO_CHAR(r_rec.'||l_col||','''||ds_utility_var.g_time_mask||''')||''</'||l_colu||'>''';
            ELSIF l_type LIKE 'TIMESTAMP%' THEN
               l_tmp := '||''<'||l_colu||'>''||TO_CHAR(r_rec.'||l_col||','''||ds_utility_var.g_timestamp_mask||''')||''</'||l_colu||'>''';
            ELSIF l_type LIKE '%CHAR%' OR l_type = 'CLOB' THEN
               l_tmp := '||''<'||l_colu||'>''||sys.dbms_xmlgen.convert(r_rec.'||l_col||',sys.dbms_xmlgen.entity_encode)||''</'||l_colu||'>''';
            ELSIF l_type = 'XMLTYPE'THEN
               l_tmp := '||''<'||l_colu||'>''||CASE WHEN r_rec.'||l_col||' IS NULL THEN NULL ELSE r_rec.'||l_col||'.getclobval END||''</'||l_colu||'>''';
            ELSIF l_type IN ('BLOB','LONG','RAW','LONG RAW','T_GEOMETRY') THEN
               l_tmp := ''; -- unsupported data type
            ELSE
               l_tmp := '||''<'||l_colu||'>''||r_rec.'||l_col||'||''</'||l_colu||'>''';
            END IF;
            IF l_tmp IS NOT NULL THEN
               l_sql := l_sql || CHR(10) || lpad(' ',9)|| l_tmp;
            END IF;
         END LOOP;
         l_sql := l_sql ||
'
      ;
      RETURN l_rec;
   END;
   ---
   -- Convert from XML to record
   ---
   FUNCTION row_to_xml (
      r_rec IN '||r_tab.table_name||'%ROWTYPE
   )
   RETURN CLOB
   IS
      l_rec CLOB;
   BEGIN
      EXECUTE IMMEDIATE ''ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''''.,'''''';
      sys.dbms_lob.createtemporary(l_rec, TRUE);
      l_rec := ''<ROWSET><ROW>''||push_record(r_rec)||''</ROW></ROWSET>''
      ;
      RETURN l_rec;
   END;';
         END IF; -- if XML mode
         l_sql := l_sql ||
'
BEGIN';
         IF r_tab.where_clause IS NOT NULL THEN
            l_sql := l_sql ||
'
   -- Stop if where clause not verified!
   IF (INSERTING OR UPDATING) AND NOT ('||prefix_columns(r_tab.where_clause,r_tab.table_name,':new')||') THEN
      RETURN;
   END IF;
   IF (DELETING OR UPDATING) AND NOT ('||prefix_columns(r_tab.where_clause,r_tab.table_name,':old')||') THEN
      RETURN;
   END IF;';
         END IF; -- where clause not null
         l_sql := l_sql ||
'
   -- Stop if capture is not activated!
   r_set := ds_utility.get_data_set_rec_by_id(l_set_id);
   IF NVL(r_set.capture_flag,''N'')=''N'' THEN
      RETURN;
   END IF;
   -- Build new record
   r_rec_new := NULL;';
         IF r_tab.user_column_name IS NOT NULL THEN
            l_sql := l_sql ||
'
   -- Get user name based on audit column
   IF INSERTING OR UPDATING THEN
      l_user_name := :new.'||r_tab.user_column_name||';
   ELSE
      l_user_name := :old.'||r_tab.user_column_name||';
   END IF;';
         END IF;
         l_sql := l_sql ||
'
   IF INSERTING OR UPDATING THEN';
         FOR i IN 1..t_col_name.COUNT LOOP
            l_col := LOWER(t_col_name(i));
            l_type := UPPER(t_col_type(i));
            IF l_type NOT IN ('BLOB','LONG','RAW','LONG RAW','T_GEOMETRY') THEN
               l_tmp := 'r_rec_new.'||l_col||' := :new.'||l_col||';';
               l_sql := l_sql || CHR(10) || lpad(' ',6) || l_tmp;
            END IF;
         END LOOP;
         l_sql := l_sql ||
'
   END IF;
   -- Build old record
   r_rec_old := NULL;
   IF DELETING OR UPDATING THEN';
         FOR i IN 1..t_col_name.COUNT LOOP
            l_col := LOWER(t_col_name(i));
            l_type := UPPER(t_col_type(i));
            IF l_type NOT IN ('BLOB','LONG','RAW','LONG RAW','T_GEOMETRY') THEN
               l_tmp := 'r_rec_old.'||l_col||' := :old.'||l_col||';';
               l_sql := l_sql || CHR(10) || lpad(' ',6) || l_tmp;
            END IF;
         END LOOP;
         l_sql := l_sql ||
'
   END IF;';
         IF l_xml_capture THEN
            l_sql := l_sql ||
'
   -- XML capture
   IF INSERTING OR UPDATING THEN
      l_xml_new := row_to_xml(r_rec_new);
   END IF;
   IF DELETING OR UPDATING THEN
      l_xml_old := row_to_xml(r_rec_old);
   END IF;
   IF INSERTING THEN
      ds_utility.capture_operation(l_set_id,l_table_id,:new.rowid,''I'',l_user_name,l_xml_new,NULL);
   ELSIF UPDATING THEN';
         l_pk_col := tokenize_columns_list(get_pk_columns(r_tab.table_name));
         FOR i IN 1..l_pk_col.COUNT LOOP
            l_sql := l_sql || CHR(10) || LPAD(' ',6) || CASE WHEN i = 1 THEN 'IF ' ELSE 'OR 'END || ':new.'|| l_pk_col(i) || ' != :old.' || l_pk_col(i);
         END LOOP;
         l_sql := l_sql ||
'
      THEN
         -- A PK update is equivalent to a delete followed by an insert
         ds_utility.capture_operation(l_set_id,l_table_id,:old.rowid,''D'',l_user_name,NULL,l_xml_old);
         ds_utility.capture_operation(l_set_id,l_table_id,:new.rowid,''I'',l_user_name,l_xml_new,NULL);
      ELSE
         ds_utility.capture_operation(l_set_id,l_table_id,:old.rowid,''U'',l_user_name,l_xml_new,l_xml_old);
      END IF;
   ELSIF DELETING THEN
      ds_utility.capture_operation(l_set_id,l_table_id,:old.rowid,''D'',l_user_name,NULL,l_xml_old);
   END IF;';
         END IF; -- if XML mode
         IF l_exp_capture AND (r_tab.target_schema IS NOT NULL OR r_tab.target_table_name IS NOT NULL OR r_tab.target_db_link IS NOT NULL) THEN
            l_tab_name := CASE WHEN r_tab.target_schema IS NOT NULL THEN r_tab.target_schema||'.' END
                       || NVL(r_tab.target_table_name,r_tab.table_name)
                       || CASE WHEN r_tab.target_db_link IS NOT NULL THEN '@'||r_tab.target_db_link END;
            l_where := NULL;
            l_pk_col := tokenize_columns_list(get_pk_columns(r_tab.table_name));
            FOR i IN 1..l_pk_col.COUNT LOOP
               l_where := l_where || CASE WHEN i != 1 THEN CHR(10) || LPAD(' ',9) || 'AND ' END || l_pk_col(i) || ' = r_rec_old.' || l_pk_col(i);
            END LOOP;
            l_export_mode := UPPER(NVL(r_tab.export_mode,'IUD')); --I)nsert,U)pdate,D)elete,M)erge(upsert)
            l_sql := l_sql ||
'
   -- EXPort capture
   IF INSERTING THEN
      IF '||CASE WHEN INSTR(l_export_mode,'I')>0 OR INSTR(l_export_mode,'M')>0 THEN '1=1' ELSE '1=0' END||' THEN
         INSERT INTO '||l_tab_name||'
         VALUES r_rec_new;
      END IF;
   ELSIF UPDATING THEN
      IF '||CASE WHEN INSTR(l_export_mode,'U')>0 OR INSTR(l_export_mode,'M')>0 THEN '1=1' ELSE '1=0' END||' THEN
         UPDATE '||l_tab_name||'
            SET ROW = r_rec_new
          WHERE '||l_where||';'||'
         IF SQL%ROWCOUNT=0 AND '||CASE WHEN INSTR(l_export_mode,'M')>0 THEN '1=1' ELSE '1=0' END||' THEN
            INSERT INTO '||l_tab_name||'
            VALUES r_rec_new;
         END IF;
      END IF;
   ELSIF DELETING THEN
      IF '||CASE WHEN INSTR(l_export_mode,'D')>0 THEN '1=1' ELSE '1=0' END||' THEN
         DELETE FROM '||l_tab_name||'
          WHERE '||l_where||';'||'
      END IF;
   END IF;';
         END IF;
         l_sql := l_sql ||
'
END;
';
       --l_count := execute_immediate(l_sql);
       --log_utility.log_message('D',l_sql);
         BEGIN
            EXECUTE IMMEDIATE l_sql;
         EXCEPTION
            WHEN OTHERS THEN
               sys.dbms_output.put_line('Error while creating trigger on '||LOWER(r_tab.table_name));
               IF NVL(p_ignore_errors,'N') = 'N' THEN
                  RAISE;
               END IF;
         END;
      END LOOP;
-- Uncomment should you want to debug
--   EXCEPTION
--      WHEN OTHERS THEN
--         sys.dbms_output.put_line('sql='||l_sql);
--         RAISE;
   END;
--
--#begin public
/**
* Drop triggers created for capture
* @param p_set_id       data set id
*/
   PROCEDURE drop_triggers (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_ignore_errors IN VARCHAR2 := 'Y'
   )
--#end public
   IS
      -- Cursor to browse all tables to extract
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
         ;
      l_sql VARCHAR2(200);
      l_count INTEGER;
   BEGIN
      FOR r_tab IN c_tab(p_set_id) LOOP
         r_tab.table_name := LOWER(r_tab.table_name);
         l_sql := 'DROP TRIGGER post_iud_ds'||p_set_id||'_tab'||r_tab.table_id;
         BEGIN
            l_count := execute_immediate(l_sql);
         EXCEPTION
            WHEN OTHERS THEN
               sys.dbms_output.put_line('Error while dropping trigger on '||LOWER(r_tab.table_name));
               IF NVL(p_ignore_errors,'Y') != 'Y' THEN
                  RAISE;
               END IF;
         END;
      END LOOP;
   END;
--
--#begin public
/**
* Delete captured operations
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_keep count   number of operations to keep
*/
   PROCEDURE delete_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL -- filter on user
    , p_keep_count IN ds_records.seq%TYPE := NULL -- NULL means keep none
   )
--#end public
   IS
      CURSOR c_rec (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_user_name IN ds_records.user_name%TYPE
      )
      IS
         SELECT ds_tab.table_name, ds_rec.*
           FROM ds_data_sets ds_set
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_set.set_id
          INNER JOIN ds_records ds_rec
             ON ds_rec.table_id = ds_tab.table_id
            AND (p_user_name IS NULL OR ds_rec.user_name = p_user_name)
          WHERE ds_set.set_id = p_set_id
          ORDER BY ds_rec.seq DESC
      ;
      l_rec_count INTEGER := 0;
      l_seq ds_records.seq%TYPE;
   BEGIN
      -- Get operation sequence number of last record to keep
      IF NVL(p_keep_count,0) > 0 THEN
         FOR r_rec IN c_rec(p_set_id,p_user_name) LOOP
            l_rec_count := l_rec_count + 1;
            l_seq := r_rec.seq;
            EXIT WHEN l_rec_count >= p_keep_count;
         END LOOP;
      END IF;
      -- Delete all records anterior to the sequence number found (all if none)
      DELETE ds_records ds_rec
       WHERE table_id IN (
                SELECT table_id
                  FROM ds_tables
                 WHERE set_id = p_set_id
             )
         AND (p_user_name IS NULL OR ds_rec.user_name = p_user_name)
         AND (l_seq IS NULL OR ds_rec.seq < l_seq)
      ;
      -- Reset sequence number if all operations were deleted
      IF p_user_name IS NULL AND l_seq IS NULL THEN
         UPDATE ds_data_sets
            SET capture_seq = NULL
          WHERE set_id = p_set_id
         ;
      END IF;
   END;
--
--#begin public
/**
* Undo some operations captured by a given data set
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_count        number of operations to undo
* @param p_delete_flag  delete records after undo (Y/N)?
*/
   PROCEDURE undo_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL
    , p_count IN ds_records.seq%TYPE := NULL
    , p_delete_flag IN VARCHAR2 := 'N'
   )
--#end public
   IS
      CURSOR c_rec (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_user_name IN ds_records.user_name%TYPE
      )
      IS
         SELECT ds_tab.table_name, ds_tab.target_db_link, ds_rec.*
           FROM ds_data_sets ds_set
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_set.set_id
          INNER JOIN ds_records ds_rec
             ON ds_rec.table_id = ds_tab.table_id
            AND (ds_tab.target_db_link IS NULL OR ds_rec.undo_timestamp IS NULL) -- not undone already unless in another DB
            AND (p_user_name IS NULL OR ds_rec.user_name = p_user_name)
          WHERE ds_set.set_id = p_set_id
          ORDER BY ds_rec.seq DESC
      ;
      l_ctx dbms_xmlsave.ctxtype;
      l_count INTEGER;
      l_rec_count INTEGER := 0;
      CURSOR c_set (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
            FOR UPDATE OF capture_flag
      ;
      r_set c_set%ROWTYPE;
      l_found BOOLEAN;
      -- Identify columns which are part of pk in XML
      PROCEDURE set_key_columns (
         p_sav_ctx dbms_xmlsave.ctxtype
       , p_table_name IN VARCHAR2
      )
      IS
         l_pk_col ds_utility_var.column_name_table;
      BEGIN
         l_pk_col := tokenize_columns_list(get_pk_columns(p_table_name));
         FOR i IN 1..l_pk_col.COUNT LOOP
            sys.dbms_xmlsave.setkeycolumn(p_sav_ctx,UPPER(l_pk_col(i)));         
         END LOOP;
      END;
   BEGIN
      IF p_count <= 0 THEN
         RETURN;
      END IF;
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      l_found := c_set%FOUND;
      IF l_found THEN
         UPDATE ds_data_sets
            SET capture_flag = 'N'
          WHERE CURRENT OF c_set;
      END IF;
      CLOSE c_set;
      assert(l_found,'Data set '||p_set_id||' not found!');
      FOR r_rec IN c_rec(p_set_id,p_user_name) LOOP
         l_rec_count := l_rec_count + 1;
         l_ctx := sys.dbms_xmlsave.newcontext(r_rec.table_name||CASE WHEN r_rec.target_db_link IS NOT NULL THEN '@' END||r_rec.target_db_link);
         --http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
         IF ds_utility_var.g_xml_dateformat IS NOT NULL THEN
            sys.dbms_xmlsave.setdateformat(l_ctx,ds_utility_var.g_xml_dateformat);
         END IF;
         IF ds_utility_var.g_xml_batchsize IS NOT NULL THEN
            sys.dbms_xmlsave.setbatchsize(l_ctx,ds_utility_var.g_xml_batchsize);
         END IF;
         IF ds_utility_var.g_xml_commitbatch IS NOT NULL THEN
            sys.dbms_xmlsave.setcommitbatch(l_ctx,ds_utility_var.g_xml_commitbatch);
         END IF;
         IF r_rec.operation = 'I' THEN
            set_key_columns(l_ctx,r_rec.table_name);         
            l_count := sys.dbms_xmlsave.deletexml(l_ctx,r_rec.record_data);
         ELSIF r_rec.operation = 'U' THEN
            set_key_columns(l_ctx,r_rec.table_name);
            l_count := sys.dbms_xmlsave.updatexml(l_ctx,r_rec.record_data_old);
         ELSIF r_rec.operation = 'D' THEN
            l_count := sys.dbms_xmlsave.insertxml(l_ctx,r_rec.record_data_old);
         END IF;
         sys.dbms_xmlsave.closecontext(l_ctx);
         IF NVL(p_delete_flag,'N') = 'Y' THEN
            DELETE ds_records
             WHERE seq = r_rec.seq
            ;
         ELSE
            UPDATE ds_records
               SET undo_timestamp = SYSTIMESTAMP
             WHERE seq = r_rec.seq
            ;
         END IF;
         EXIT WHEN p_count IS NOT NULL AND l_rec_count >= p_count;
      END LOOP;
      -- Restore properties
      update_data_set_def_properties(p_set_id=>p_set_id, p_capture_flag=>r_set.capture_flag); 
   END;
--
--#begin public
/**
* Undo some operations captured by a given data set
* @param p_set_id       data set id
* @param p_user_name    only for this user
* @param p_count        number of operations to redo
* @param p_delete_flag  delete records after redo (Y/N)?
*/
   PROCEDURE redo_captured_operations (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_user_name IN ds_records.user_name%TYPE := NULL
    , p_count IN ds_records.seq%TYPE := NULL -- NULL means all
    , p_delete_flag IN VARCHAR2 := 'N'
   )
--#end public   PROCEDURE redo_captured_operations (
   IS
      CURSOR c_rec (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_user_name IN ds_records.user_name%TYPE
      )
      IS
         SELECT ds_tab.table_name, ds_tab.target_schema, ds_tab.target_table_name, ds_tab.target_db_link, ds_rec.*
           FROM ds_data_sets ds_set
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_set.set_id
          INNER JOIN ds_records ds_rec
             ON ds_rec.table_id = ds_tab.table_id
            AND (ds_tab.target_schema IS NOT NULL OR ds_tab.target_table_name IS NOT NULL OR ds_tab.target_db_link IS NOT NULL OR ds_rec.undo_timestamp IS NOT NULL) -- undone already unless in another table/schema/db
            AND (p_user_name IS NULL OR ds_rec.user_name = p_user_name)
          WHERE ds_set.set_id = p_set_id
          ORDER BY ds_rec.seq ASC
      ;
      l_ctx dbms_xmlsave.ctxtype;
      l_count INTEGER;
      l_rec_count INTEGER := 0;
      CURSOR c_set (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE set_id = p_set_id
            FOR UPDATE OF capture_flag
      ;
      r_set c_set%ROWTYPE;
      l_found BOOLEAN;
      -- Identify columns which are part of pk in XML
      PROCEDURE set_key_columns (
         p_sav_ctx dbms_xmlsave.ctxtype
       , p_table_name IN VARCHAR2
      )
      IS
         l_pk_col ds_utility_var.column_name_table;
      BEGIN
         l_pk_col := tokenize_columns_list(get_pk_columns(p_table_name));
         FOR i IN 1..l_pk_col.COUNT LOOP
            sys.dbms_xmlsave.setkeycolumn(p_sav_ctx,UPPER(l_pk_col(i)));         
         END LOOP;
      END;
   BEGIN
      IF p_count <= 0 THEN
         RETURN;
      END IF;
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      l_found := c_set%FOUND;
      IF l_found THEN
         UPDATE ds_data_sets
            SET capture_flag = 'N'
          WHERE CURRENT OF c_set;
      END IF;
      CLOSE c_set;
      assert(l_found,'Data set '||p_set_id||' not found!');
      FOR r_rec IN c_rec(p_set_id,p_user_name) LOOP
         l_rec_count := l_rec_count + 1;
         l_ctx := sys.dbms_xmlsave.newcontext(
            CASE WHEN r_rec.target_schema IS NOT NULL THEN r_rec.target_schema||'.' END
          ||NVL(r_rec.target_table_name,r_rec.table_name)
          ||CASE WHEN r_rec.target_db_link IS NOT NULL THEN '@' END||r_rec.target_db_link);
         --http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
         IF ds_utility_var.g_xml_dateformat IS NOT NULL THEN
            sys.dbms_xmlsave.setdateformat(l_ctx,ds_utility_var.g_xml_dateformat);
         END IF;
         IF ds_utility_var.g_xml_batchsize IS NOT NULL THEN
            sys.dbms_xmlsave.setbatchsize(l_ctx,ds_utility_var.g_xml_batchsize);
         END IF;
         IF ds_utility_var.g_xml_commitbatch IS NOT NULL THEN
            sys.dbms_xmlsave.setcommitbatch(l_ctx,ds_utility_var.g_xml_commitbatch);
         END IF;
         IF r_rec.operation = 'I' THEN
            l_count := sys.dbms_xmlsave.insertxml(l_ctx,r_rec.record_data);
         ELSIF r_rec.operation = 'U' THEN
            set_key_columns(l_ctx,r_rec.table_name);
            l_count := sys.dbms_xmlsave.updatexml(l_ctx,r_rec.record_data);
         ELSIF r_rec.operation = 'D' THEN
            set_key_columns(l_ctx,r_rec.table_name);         
            l_count := sys.dbms_xmlsave.deletexml(l_ctx,r_rec.record_data_old);
         END IF;
         sys.dbms_xmlsave.closecontext(l_ctx);
         IF NVL(p_delete_flag,'N') = 'Y' THEN
            DELETE ds_records
             WHERE seq = r_rec.seq
            ;
         ELSE
            UPDATE ds_records
               SET undo_timestamp = NULL
             WHERE seq = r_rec.seq
            ;
         END IF;
         EXIT WHEN p_count IS NOT NULL AND l_rec_count >= p_count;
      END LOOP;
      -- Restore properties
      update_data_set_def_properties(p_set_id=>p_set_id, p_capture_flag=>r_set.capture_flag); 
   END;
--
--#begin public
/**
* Rollback all operations captured via triggers
* @param p_set_id       data set id
* @param p_delete_flag  delete records after rollback (Y/N)?
*/
   PROCEDURE rollback_captured_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_delete_flag IN VARCHAR2 := 'Y'
   )
--#end public
   IS
   BEGIN
      undo_captured_operations(p_set_id,NULL,NULL,p_delete_flag);
   END;
--
--#begin public
/**
* Rollforward all operations captured via triggers
* @param p_set_id       data set id
* @param p_delete_flag  delete records after rollforward (Y/N)?
*/
   PROCEDURE rollforward_captured_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_delete_flag IN VARCHAR2 := 'Y'
   )
--#end public
   IS
   BEGIN
      redo_captured_operations(p_set_id,NULL,NULL,p_delete_flag);
   END;
--#begin public
/**
* Returns a script to redo/undo capture DML operations
* @param p_set_id       data set id
* @param p_undo_flag    generate undo script if Y, redo otherwise
*/
   FUNCTION gen_captured_data_set_script (
      p_set_id    IN ds_data_sets.set_id%TYPE
    , p_undo_flag IN VARCHAR2 := NULL -- Y/N
   )
   RETURN sys.odcivarchar2list pipelined
--#end public
   IS
      l_parser       dbms_xmlparser.parser;
      l_doc          dbms_xmldom.domdocument;
      l_row_list     dbms_xmldom.domnodelist;
      l_col_list     dbms_xmldom.domnodelist;
      l_val_list     dbms_xmldom.domnodelist;
      l_node         dbms_xmldom.domnode;
      l_element      dbms_xmldom.domelement;
      l_node_name    VARCHAR2(30);
      l_column_name  user_tab_columns.column_name%TYPE;
      l_row_cnt      INTEGER;
      l_col_cnt      INTEGER;
      l_val_cnt      INTEGER;
      l_gen_set      BOOLEAN;
      l_use_old      BOOLEAN;
      l_where        VARCHAR2(4000);
      l_val          VARCHAR2(4000);
      l_operation    ds_records.operation%TYPE;
      -- Cursor to get table column names and types + indication of pk membership
      CURSOR c_col (
         p_table_name IN VARCHAR2
      )
      IS
         SELECT tcol.column_name, tcol.data_type
              , CASE WHEN ccol.column_name IS NOT NULL THEN 'Y' ELSE 'N' END pk_flag
           FROM sys.all_tab_columns tcol
           LEFT OUTER JOIN sys.all_constraints ds_con
             ON ds_con.owner = tcol.owner
            AND ds_con.table_name = tcol.table_name
            AND ds_con.constraint_type = 'P'
           LEFT OUTER JOIN sys.all_cons_columns ccol
             ON ccol.owner = ds_con.owner
            AND ccol.constraint_name = ds_con.constraint_name
            AND ccol.column_name = tcol.column_name
          WHERE tcol.owner = ds_utility_var.g_owner
            AND tcol.table_name = UPPER(p_table_name)
          ORDER BY tcol.column_id
      ;
      TYPE t_col_type IS TABLE OF c_col%ROWTYPE INDEX BY user_tab_columns.column_name%TYPE;
      t_cols t_col_type;
      r_col c_col%ROWTYPE;
      -- Cursor to browse captured DML operations of a set
      CURSOR c_rec (
         p_set_id ds_data_sets.set_id%TYPE
       , p_mult INTEGER
      )
      IS
         SELECT ds_tab.table_name, ds_rec.record_data, ds_rec.record_data_old, ds_rec.operation
           FROM ds_records ds_rec
          INNER JOIN ds_tables ds_tab
             ON ds_tab.table_id = ds_rec.table_id
            AND ds_tab.set_id = p_set_id
            AND (ds_rec.operation  = 'D' OR ds_rec.record_data IS NOT NULL) -- non-empty XML
            AND (ds_rec.operation != 'D' OR ds_rec.record_data_old IS NOT NULL) -- non-empty XML
            AND ds_rec.operation IS NOT NULL -- I/U/D
          ORDER BY ds_rec.seq * p_mult
      ;
   BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';
      -- For each captured DML operation of the data set (sorted ASC for redo and DESC for undo)
      FOR r_rec IN c_rec(p_set_id, CASE WHEN p_undo_flag = 'Y' THEN -1 ELSE 1 END) LOOP
         -- Check that the table has a primary key
         assert(get_table_pk(r_rec.table_name) IS NOT NULL, 'Table '||r_rec.table_name||' has no primary key!');
         -- Get table columns and their type
         t_cols.DELETE;
         FOR r_col IN c_col(r_rec.table_name) LOOP
            t_cols(r_col.column_name) := r_col;
         END LOOP;
         -- Process XML
         l_use_old := r_rec.operation = 'D';
         l_operation := r_rec.operation;
         -- Reverse operations if undo
         IF p_undo_flag = 'Y' THEN
            IF l_operation = 'I' THEN
               l_operation := 'D';
            ELSIF l_operation = 'D' THEN
               l_operation := 'I';
            ELSIF l_operation = 'U' THEN
               l_use_old := NOT l_use_old; -- update with old data
            END IF;
         END IF;
         assert(CASE WHEN l_use_old THEN r_rec.record_data_old ELSE r_rec.record_data END IS NOT NULL,'Empty XML!');
         -- get a parser
         l_parser := dbms_xmlparser.newparser;
         -- parse XML
         xdb.dbms_xmlparser.parseclob(l_parser, CASE WHEN l_use_old THEN r_rec.record_data_old ELSE r_rec.record_data END);
         -- generate a document object to access elements and attributes
         l_doc := xdb.dbms_xmlparser.getdocument(l_parser);
         -- get all elements
         assert(NOT xdb.dbms_xmldom.isnull(l_doc),'Empty XML');
         l_row_list := xdb.dbms_xmldom.getelementsbytagname(l_doc, '*');
         l_node := xdb.dbms_xmldom.item(l_row_list, 0);
         l_element := xdb.dbms_xmldom.makeelement(l_node);
         l_node_name := xdb.dbms_xmldom.getnodename(l_node);
         assert(UPPER(l_node_name)=UPPER('ROWSET'),'ROWSET tag not found in XML');
         l_row_list := xdb.dbms_xmldom.getchildrenbytagname(l_element, '*');
         l_row_cnt := xdb.dbms_xmldom.getlength(l_row_list);
         -- for each row in the set
         FOR i IN 0..l_row_cnt-1 LOOP
            -- Row init
            l_where := NULL;
            l_gen_set := TRUE;
            -- Get row
            l_node := xdb.dbms_xmldom.item(l_row_list, i);
            l_node_name := xdb.dbms_xmldom.getnodename(l_node);
            l_element := xdb.dbms_xmldom.makeelement(l_node);
   --         assert(UPPER(l_node_name)=UPPER(r_rec.table_name),UPPER(r_rec.table_name)||' tag not found in XML');
            -- Get list of columns
            l_col_list := xdb.dbms_xmldom.getchildrenbytagname(l_element, '*');
            l_col_cnt := xdb.dbms_xmldom.getlength(l_col_list);
            -- Generate INSERT, UPDATE or DELETE statement
            IF l_operation = 'I' THEN
               PIPE ROW('INSERT INTO '||LOWER(r_rec.table_name)||' (');
               FOR j IN 0..l_col_cnt-1 LOOP
                  l_node := xdb.dbms_xmldom.item(l_col_list, j);
                  l_column_name := xdb.dbms_xmldom.getnodename(l_node);
                  assert(t_cols.EXISTS(l_column_name),'Column "'||l_column_name||'" found IN XML does not exist in table '||r_rec.table_name);
                  PIPE ROW(CASE WHEN j=0 THEN '   ' ELSE '  ,' END || LOWER(l_column_name));
               END LOOP;
               PIPE ROW(') VALUES (');
            ELSIF l_operation = 'U' THEN
               PIPE ROW('UPDATE '||LOWER(r_rec.table_name));
            ELSIF l_operation = 'D' THEN
               PIPE ROW('DELETE '||LOWER(r_rec.table_name));
            END IF;
            -- For each column
            FOR j IN 0..l_col_cnt-1 LOOP
               -- Get column value
               l_node := xdb.dbms_xmldom.item(l_col_list, j);
               l_column_name := xdb.dbms_xmldom.getnodename(l_node);
               assert(t_cols.EXISTS(l_column_name),'Column "'||l_column_name||'" found IN XML does not exist in table '||r_rec.table_name);
               r_col := t_cols(l_column_name);
               l_node := xdb.dbms_xmldom.getfirstchild(l_node);
               -- Format output based on column data type
               IF xdb.dbms_xmldom.getnodevalue(l_node) IS NULL THEN
                  l_val := 'NULL';
               ELSIF r_col.data_type = 'DATE' THEN
                  l_val := 'TO_DATE('''||dbms_xmldom.getnodevalue(l_node)||''','''||ds_utility_var.g_time_mask||''')';
               ELSIF r_col.data_type LIKE '%TIMESTAMP%' THEN
                  l_val := 'TO_TIMESTAMP('''||dbms_xmldom.getnodevalue(l_node)||''','''||ds_utility_var.g_timestamp_mask||''')';
               ELSIF r_col.data_type LIKE '%CHAR%' OR r_col.data_type IN ('CLOB','LONG') THEN
                  l_val := ''''||sys.dbms_xmlgen.convert(dbms_xmldom.getnodevalue(l_node),sys.dbms_xmlgen.entity_decode)||'''';
               ELSE
                  l_val := xdb.dbms_xmldom.getnodevalue(l_node);
               END IF;
               -- Generate column in INSERT, UPDATE or DELETE statement
               IF l_operation = 'I' THEN
                  PIPE ROW(CASE WHEN j=0 THEN '   ' ELSE '  ,' END||l_val);
               ELSIF l_operation IN ('U','D') THEN
                  IF l_operation = 'U' AND r_col.pk_flag = 'N' THEN
                     PIPE ROW(CASE WHEN l_gen_set THEN '   SET ' ELSE '     , ' END||LOWER(l_column_name)||' = '||l_val);
                     l_gen_set := FALSE;
                  END IF;
                  IF r_col.pk_flag = 'Y' THEN
                     l_where := CASE WHEN l_where IS NULL THEN ' WHERE ' ELSE l_where||CHR(10)||'  AND ' END||LOWER(l_column_name)||' = '||l_val;
                  END IF;
               END IF;
            END LOOP;
            -- Properly terminate SQL statement
            IF l_operation = 'I' THEN
               PIPE ROW(')');
            ELSIF l_operation IN ('U','D') THEN
               PIPE ROW(l_where);
            END IF;
            PIPE ROW('/');
            PIPE ROW('');
         END LOOP;
      END LOOP;
   END;
--#begin public
/**
* Generates a script (to the specified output) to redo/undo capture DML operations 
* @param p_set_id       data set id
* @param p_undo_flag    generate undo script if Y, redo otherwise
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE gen_captured_data_set_script (
      p_set_id    IN ds_data_sets.set_id%TYPE
    , p_undo_flag IN VARCHAR2 := NULL -- Y/N
    , p_output    IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
   )
--#end public
   IS
      CURSOR c_row IS
         SELECT *
           FROM TABLE(ds_utility.gen_captured_data_set_script(p_set_id,p_undo_flag))
         ;
   BEGIN
      FOR r_row IN c_row LOOP
         put(r_row.column_value, TRUE, p_output);
      END LOOP;
   END;
--#begin public
/**
* Detect true master detail constraints (identifying relationships)
* By setting md_cardinality_ok, md_optionality_ok and md_uid_ok cols
* @param p_set_id       data set id
*/
   PROCEDURE detect_true_master_detail_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      CURSOR c_con (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_owner IN VARCHAR2
      )
      IS
         WITH fk_ds AS (
            SELECT constraint_name
              FROM ds_constraints
             WHERE set_id = p_set_id
               AND cardinality = '1-N'
         )
         , fk_null AS (
               SELECT fk.constraint_name
                    , CASE WHEN SUM(CASE WHEN fktcol.nullable = pktcol.nullable THEN 0 ELSE 1 END) > 0 THEN 'N' ELSE 'Y' END mandatory
                 FROM sys.all_constraints fk
                INNER JOIN fk_ds
                   ON fk.constraint_name = fk_ds.constraint_name
                INNER JOIN sys.all_constraints pk
                   ON pk.owner = fk.owner
                  AND pk.constraint_name = fk.r_constraint_name
                INNER JOIN sys.all_tables fktab
                   ON fktab.owner = fk.owner
                  AND fktab.table_name = fk.table_name
                INNER JOIN sys.all_tables pktab
                   ON pktab.owner = pk.owner
                  AND pktab.table_name = pk.table_name
                INNER JOIN sys.all_cons_columns pkccol
                   ON pkccol.owner = pk.owner
                  AND pkccol.constraint_name = pk.constraint_name
                INNER JOIN sys.all_cons_columns fkccol
                   ON fkccol.owner = fk.owner
                  AND fkccol.constraint_name = fk.constraint_name
                  AND fkccol.position = pkccol.position
                INNER JOIN sys.all_tab_columns pktcol
                   ON pktcol.owner = pkccol.owner
                  AND pktcol.table_name = pkccol.table_name
                  AND pktcol.column_name = pkccol.column_name
                INNER JOIN sys.all_tab_columns fktcol
                   ON fktcol.owner = fkccol.owner
                  AND fktcol.table_name = fkccol.table_name
                  AND fktcol.column_name = fkccol.column_name
                WHERE fk.owner = ds_utility_var.g_owner
                  AND fk.constraint_type = 'R'
                GROUP BY fk.constraint_name
         )
         , fk_con AS (
               SELECT DISTINCT fk.constraint_name
                    , 'Y' constraint_prefix
                 FROM sys.all_constraints fk
                INNER JOIN fk_ds
                   ON fk.constraint_name = fk_ds.constraint_name
                INNER JOIN sys.all_constraints uk
                   ON uk.owner = fk.owner
                  AND uk.table_name = fk.table_name
                  AND uk.constraint_type IN ('P','U')
                  AND INSTR('^'||ds_utility.get_constraint_columns(uk.constraint_name),'^'||ds_utility.get_constraint_columns(fk.constraint_name))>0
                WHERE fk.owner = USER
                  AND fk.constraint_type = 'R'         
         )
         SELECT fk.constraint_name
              , CASE WHEN ds_det.num_rows > ds_mst.num_rows THEN 'Y' ELSE 'N' END md_cardinality_ok
              , fk_null.mandatory md_optionality_ok
              , NVL(fk_con.constraint_prefix,'N') md_uid_ok
           FROM sys.all_constraints fk
          INNER JOIN fk_ds
             ON fk.constraint_name = fk_ds.constraint_name
           LEFT OUTER JOIN fk_null
             ON fk_null.constraint_name = fk.constraint_name
           LEFT OUTER JOIN fk_con
             ON fk_con.constraint_name = fk.constraint_name
          INNER JOIN sys.all_constraints pk
             ON pk.owner = fk.owner
            AND pk.constraint_name = fk.r_constraint_name
          INNER JOIN sys.all_tables ds_det
             ON ds_det.owner = fk.owner
            AND ds_det.table_name = fk.table_name
          INNER JOIN sys.all_tables ds_mst
             ON ds_mst.owner = pk.owner
            AND ds_mst.table_name = pk.table_name
          WHERE fk.owner = USER
            AND fk.constraint_type = 'R'
         ;
   BEGIN
      assert(p_set_id IS NOT NULL,'p_set_id parameter is mandatory');
      assert(ds_utility_var.g_owner IS NOT NULL,'Source schema (owner) cannot be NULL');
      FOR r_con IN c_con(p_set_id, ds_utility_var.g_owner) LOOP
         UPDATE ds_constraints
            SET md_cardinality_ok = r_con.md_cardinality_ok
              , md_optionality_ok = r_con.md_optionality_ok
              , md_uid_ok = r_con.md_uid_ok
          WHERE set_id = p_set_id
            AND constraint_name = r_con.constraint_name
            AND cardinality = '1-N'
         ;
      END LOOP;
   END;
END;
/
