CREATE OR REPLACE PACKAGE BODY ds_utility_krn AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
-- To generate the package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE ds_utility_krn', '-f');
--
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
   -- 21.0  deboiph  xx/xx/2021  Use PL/SQL installer
   -- 21.1  deboiph  25/08/2021  Better detection of true master/detail relationships
   --                            (identifying relationships)
   -- 23.0  deboiph  08/03/2023  Prefix query aliases with "ds_" to prevent collisions
   -- 23.1  deboiph  08/05/2023  Added sensitive data discovery and masking capabilities
   -- 23.2  deboiph  18/07/2023  Added synthetic/fake data generation capability
   -- 23.2.1deboiph  27/09/2023  Bug fixing (e.g., pk propagation to optional fk)
   -- 23.3  deboiph  10/10/2023  Added tokenization (additional data masking technique)
   --                            Replaced relocation of ids with data masking.
   --                            Replaced mechanism to force values with data masking.
   -- 24.0  deboiph  22/01/2024  Bug fixing and minor changes
   ---
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_description IN VARCHAR2
   ) IS

   BEGIN
      IF NOT NVL(p_condition,FALSE) THEN
         raise_application_error(-20000,'Assertion failed: '||p_description);
      END IF;
   END;
--#begin public
   ---
   -- Similar to Oracle REPLACE but case insensitive and exact words
   ---
   FUNCTION replace_i (
      p_string IN VARCHAR2
    , p_search IN VARCHAR2
    , p_with IN VARCHAR2 := ''
   )
   RETURN VARCHAR2
--#end public
   IS
      l_string_u VARCHAR2(32767) := UPPER(p_string);
      l_search_u VARCHAR2(32767) := UPPER(p_search);
      l_res VARCHAR2(32767);
      l_len PLS_INTEGER := LENGTH(p_search);
      l_pos PLS_INTEGER := 1;
      l_idx PLS_INTEGER := 1;
      l_exact_left BOOLEAN := NOT SUBSTR(p_search,1,1) IN (' ',CHR(9));
      l_exact_right BOOLEAN := NOT SUBSTR(p_search,-1) IN (' ',CHR(9));
      FUNCTION is_not_allowed (p_char IN VARCHAR2)
      RETURN BOOLEAN
      IS
      BEGIN
         IF p_char IS NULL THEN
            RETURN FALSE;
         END IF;
         RETURN p_char BETWEEN 'A' AND 'Z'
             OR p_char BETWEEN '0' AND '9'
             OR p_char = '_';
      END;
   BEGIN
      IF p_search IS NULL THEN
         RETURN p_string;
      END IF;
      LOOP
         l_pos := INSTR(l_string_u, l_search_u, l_pos);
         EXIT WHEN NVL(l_pos,0) <= 0;
         IF ((l_pos > 1 AND l_exact_left AND is_not_allowed(SUBSTR(l_string_u,l_pos-1,1)))
         OR (l_exact_right AND is_not_allowed(SUBSTR(l_string_u,l_pos+l_len,1))))
         THEN
            l_pos := l_pos + 1;
         ELSE
            l_res := l_res || SUBSTR(p_string,l_idx,l_pos-l_idx) || p_with;
            l_pos := l_pos + l_len;
            l_idx := l_pos;
            -- If search string ends with a space...
            IF SUBSTR(p_search,-1) = ' ' THEN
               -- ...skip leading spaces in the string
               WHILE SUBSTR(p_string,l_idx,1) = ' ' LOOP
                  l_idx := l_idx + 1;
               END LOOP;
            END IF;
         END IF;
      END LOOP;
      l_res := l_res || SUBSTR(p_string,l_idx);
      RETURN l_res;
   END;
   ---
   -- Set seed
   -- 
   PROCEDURE set_seed (
      p_seed IN VARCHAR2
   )
   IS
   BEGIN
      -- Set seed
      IF p_seed IS NOT NULL THEN
         -- Convert to US7ASCII to avoid ORA-06502 raised with special chars
         sys.dbms_random.seed(SUBSTR(CONVERT(p_seed,'US7ASCII'),1,2000));
      END IF;
   END;
   ---
   -- Reset seed
   -- 
   PROCEDURE reset_seed (
      p_seed IN VARCHAR2
   )
   IS
      l_seed VARCHAR2(30);
   BEGIN
      -- Set seed
      IF p_seed IS NOT NULL THEN
         l_seed := TO_CHAR(SYSTIMESTAMP,ds_utility_var.g_default_seed_format);
         sys.dbms_random.seed(l_seed);
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
--#begin public
   ---
   -- Set message filter
   ---
   PROCEDURE set_message_filter (
      p_msg_mask IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_msg_mask := UPPER(SUBSTR(p_msg_mask,1,5));
   END;
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
--#begin public
   FUNCTION set_source_schema (
      p_owner IN sys.all_objects.owner%TYPE
   )
   RETURN VARCHAR2
--#end public
   IS
   BEGIN
      set_source_schema(p_owner);
      RETURN p_owner;
   END;
--#begin public
/**
* Turn test mode on/off. In test mode, DDL are displayed instead of being executed.
* @param p_test_mode test mode (TRUE/FALSE, NULL to reset to default/FALSE)
*/
   PROCEDURE set_test_mode (
      p_test_mode IN BOOLEAN := FALSE
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_test_mode := NVL(p_test_mode,FALSE);
   END;
--#begin public
/**
* Enable/disable data masking.
* @param p_mask_data (TRUE/FALSE, NULL to reset to default/TRUE)
*/
   PROCEDURE set_masking_mode (
      p_mask_data IN BOOLEAN := TRUE -- perform data masking?
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_mask_data := NVL(p_mask_data,TRUE);
   END;
--
--#begin public
/**
* Enable/disable encryption of tokenized values (DS_TOKENS.VALUE)
* @param p_encrypt_tokenized_values (TRUE/FALSE, NULL to reset to default/TRUE)
*/
   PROCEDURE set_encrypt_tokenized_values (
      p_encrypt_tokenized_values IN BOOLEAN := TRUE -- perform data masking?
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_encrypt_tokenized_values := NVL(p_encrypt_tokenized_values,TRUE);
   END;
--
--#begin public
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_like_pattern (
      p_alias_regexp_like_pattern IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_alias_like_pattern := UPPER(p_alias_regexp_like_pattern);
   END;
--
--#begin public
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_replace_pattern (
      p_alias_regexp_replace_pattern IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_alias_replace_pattern := UPPER(p_alias_regexp_replace_pattern);
   END;
--
--#begin public
   ---
   -- Set regexp replace pattern for extracting alias
   ---
   PROCEDURE set_alias_constraint_type (
      p_alias_constraint_type IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      ds_utility_var.g_alias_constraint_type := UPPER(p_alias_constraint_type);
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
--#begin public
   ---
   -- Log a message
   ---
   PROCEDURE show_message (
      p_type IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL, Result/Rowcount
     ,p_text IN VARCHAR2 -- message text
     ,p_new_line IN BOOLEAN := TRUE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
      l_type VARCHAR2(1) := UPPER(SUBSTR(p_type,1,1));
   BEGIN
      IF NVL(INSTR(ds_utility_var.g_msg_mask,l_type),0) <= 0 AND l_type != 'T' THEN
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
         IF SUBSTR(RTRIM(p_text,CHR(10)),-1,1) != '/' THEN
            put('/', p_new_line);
         END IF;
         put('', p_new_line);
      END IF;
   END;
--#begin public
   ---
   -- Execute dynamic SQL statement
   ---
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   )
   RETURN INTEGER
--#end public
   IS
      l_count INTEGER;
   BEGIN
      show_message('S',RTRIM(p_sql,CHR(10)));
      IF p_using IS NOT NULL THEN
         show_message('S','--USING'||CHR(10)||p_using);
      END IF;
      IF ds_utility_var.g_test_mode
      THEN
--         show_message('S','/'||CHR(10)||' ',TRUE);
         l_count := 0;
         show_message('R','rowcount=0 (test mode, not executed)');
      ELSE
         IF p_using IS NOT NULL THEN
            EXECUTE IMMEDIATE p_sql USING p_using;
         ELSE
            EXECUTE IMMEDIATE p_sql;
         END IF;
         l_count := SQL%ROWCOUNT;
         show_message('R','rowcount='||l_count);
      END IF;
      RETURN l_count;
   EXCEPTION
      WHEN OTHERS THEN
         IF NOT p_ignore THEN
            IF NVL(INSTR(ds_utility_var.g_msg_mask,'E'),0) > 0 THEN
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
--#begin public
   ---
   -- Execute dynamic SQL statement
   ---
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
     ,p_using IN VARCHAR2:= NULL
   )
--#end public
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
           FROM sys.dual
         ;
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_set_id;
      CLOSE c_seq;
      RETURN l_set_id;
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
         l_pos := NVL(INSTR(p_string,p_sep,l_pos_from),0);
         IF l_pos <= 0 THEN
            RETURN NULL;
         END IF;
         l_pos_from := l_pos + l_len;
      END LOOP;
      l_pos_to := NVL(INSTR(p_string,p_sep,l_pos_from),0);
      IF l_pos_to > 0 THEN
         RETURN SUBSTR(p_string,l_pos_from,l_pos_to-l_pos_from);
      ELSE
         RETURN SUBSTR(p_string,l_pos_from);
      END IF;
   END;
   ---
   -- Put a mask in cache
   ---
   PROCEDURE cache_mask (
      pr_msk ds_masks%ROWTYPE
   )
   IS
   BEGIN
      IF pr_msk.msk_id IS NOT NULL THEN
         ds_utility_var.ga_msk(pr_msk.table_name||'.'||pr_msk.column_name) := pr_msk;
         ds_utility_var.gt_msk(pr_msk.msk_id) := pr_msk;
         ds_utility_var.g_msk_date_time := SYSDATE; -- set last read date/time
      END IF;
   END;
   ---
   -- Reset mask caching
   ---
   PROCEDURE reset_mask_cache
   IS
   BEGIN
      ds_utility_var.ga_msk.DELETE;
      ds_utility_var.gt_msk.DELETE;
      ds_utility_var.g_msk_date_time := SYSDATE; -- set last read date/time
   END;
   ---
   -- Get a mask from cache using its table and column names
   ---
   FUNCTION get_mask_from_cache (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
   )
   RETURN ds_masks%ROWTYPE
   IS
      l_full_column_name ds_utility_var.full_column_name;
   BEGIN
      l_full_column_name := UPPER(p_table_name||'.'||p_column_name);
      IF ds_utility_var.ga_msk.EXISTS(l_full_column_name) THEN
         -- Reset entire cache if last read was more than 10 seconds ago
         IF (SYSDATE - NVL(ds_utility_var.g_msk_date_time,SYSDATE)) * 86400 >= 10 THEN
            reset_mask_cache;
            RETURN NULL;
         END IF;
         ds_utility_var.g_msk_date_time := SYSDATE; -- set last read date/time
         RETURN ds_utility_var.ga_msk(l_full_column_name);
      END IF;
      RETURN NULL;
   END;
   ---
   -- Get a mask from cache using its id
   ---
   FUNCTION get_mask_from_cache (
      p_msk_id ds_masks.msk_id%TYPE
   )
   RETURN ds_masks%ROWTYPE
   IS
   BEGIN
      IF ds_utility_var.gt_msk.EXISTS(p_msk_id) THEN
         -- Reset entire cache if last read was more than 10 seconds ago
         IF (SYSDATE - NVL(ds_utility_var.g_msk_date_time,SYSDATE)) * 86400 >= 10 THEN
            reset_mask_cache;
            RETURN NULL;
         END IF;
         ds_utility_var.g_msk_date_time := SYSDATE; -- set last read date/time
         RETURN ds_utility_var.gt_msk(p_msk_id);
      END IF;
      RETURN NULL;
   END;
   ---
   -- Get a mask from cache or from DB if not found in cache
   ---
   FUNCTION get_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
   )
   RETURN ds_masks%ROWTYPE
   IS
      l_table_name ds_utility_var.table_name := UPPER(p_table_name);
      l_column_name ds_utility_var.column_name := UPPER(p_column_name);
      r_msk ds_masks%ROWTYPE;
      CURSOR c_msk (
         p_table_name ds_masks.table_name%TYPE
       , p_column_name ds_masks.column_name%TYPE
      )
      IS
         SELECT *
           FROM ds_masks
          WHERE table_name = p_table_name
            AND column_name = p_column_name
      ;
   BEGIN
      l_table_name := UPPER(p_table_name);
      l_column_name := UPPER(p_column_name);
      -- Get mask from cache
      r_msk := get_mask_from_cache(l_table_name, l_column_name);
      -- Get if from DB if not found in cache
      IF r_msk.msk_id IS NULL THEN
         OPEN c_msk(l_table_name, l_column_name);
         FETCH c_msk INTO r_msk;
         CLOSE c_msk;
         cache_mask(r_msk);
      END IF;
      RETURN r_msk;
END;
   ---
   -- Get a mask from cache or from DB if not found in cache
   ---
   FUNCTION get_mask (
      p_msk_id ds_masks.msk_id%TYPE
   )
   RETURN ds_masks%ROWTYPE
   IS
      r_msk ds_masks%ROWTYPE;
      CURSOR c_msk (
         p_msk_id ds_masks.msk_id%TYPE
      )
      IS
         SELECT *
           FROM ds_masks
          WHERE msk_id = p_msk_id
      ;
   BEGIN
      -- Get mask from cache
      r_msk := get_mask_from_cache(p_msk_id);
      -- Get it from DB if not found in cache
      IF r_msk.msk_id IS NULL THEN
         OPEN c_msk(p_msk_id);
         FETCH c_msk INTO r_msk;
         CLOSE c_msk;
         cache_mask(r_msk);
      END IF;
      RETURN r_msk;
   END;
   ---
   -- Get a mask for a table column
   -- Create it if not found
   ---
   FUNCTION get_or_create_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
   )
   RETURN ds_masks%ROWTYPE
   IS
      l_table_name ds_utility_var.table_name;
      l_column_name ds_utility_var.column_name;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      l_table_name := UPPER(p_table_name);
      l_column_name := UPPER(p_column_name);
      -- Get mask from cache or DB
      r_msk := get_mask(l_table_name, l_column_name);
      -- If not found, create mask in DB and cache it
      IF r_msk.msk_id IS NULL THEN
         INSERT INTO ds_masks (
            table_name, column_name
         ) VALUES (
            l_table_name, l_column_name
         )
         RETURNING msk_id INTO r_msk.msk_id;
         r_msk.table_name := l_table_name;
         r_msk.column_name := l_column_name;
         cache_mask(r_msk);
      END IF;
      RETURN r_msk;
   END;
   ---
   -- Load masks in cache
   ---
   PROCEDURE load_masks IS
      CURSOR c_msk IS
         SELECT *
           FROM ds_masks
          WHERE msk_type IS NOT NULL
            AND NVL(disabled_flag,'N') = 'N'
            AND NVL(deleted_flag,'N') = 'N'
         ;
   BEGIN
      reset_mask_cache;
      FOR r_msk IN c_msk LOOP
         cache_mask(r_msk);
      END LOOP;
   END;
--#begin public
   ---
   -- Load SQL and CSV data sets in cache
   ---
   PROCEDURE load_ds (
      p_set_name ds_data_sets.set_name%TYPE := NULL
    , p_col_name IN VARCHAR2 := NULL
    , p_what IN VARCHAR2 := NULL
   )
--#end public
   IS
      -- Fetch SQL data sets
      CURSOR c_ds IS
         SELECT set_id, set_type, set_name, params
           FROM ds_data_sets
          WHERE set_type IN ('SQL','CSV')
            AND NVL(disabled_flag,'N') = 'N'
            AND (p_set_name IS NULL OR set_name = p_set_name)
            AND params IS NOT NULL
          ORDER BY set_id
      ;
      l_string ds_utility_var.largest_string;
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_full_col_name VARCHAR2(200);
      l_cursor PLS_INTEGER;
      l_count PLS_INTEGER;
      t_desc sys.dbms_sql.desc_tab2;
      l_col_type VARCHAR2(20);
      l_sql VARCHAR2(32767);
      l_systimestamp VARCHAR2(100) := TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF');
   BEGIN
      FOR r_ds IN c_ds LOOP
         l_cursor := sys.dbms_sql.open_cursor;
         -- Bug: ORA-22922: nonexistent LOB value is raised due to reuse of cached cursor/query while temporary LOB was deleted in read_csv_clob
         -- Fix: make the query each time different by adding a timestamp (YYYYMMDDHH24MISSFF) in it; not pretty but efficient!
         l_sql := CASE WHEN r_ds.set_type='SQL' THEN r_ds.params ELSE 'SELECT * FROM TABLE(ds_utility_krn.read_csv_clob('||r_ds.set_id||')) WHERE '||l_systimestamp||'>=0' END;
         sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
         sys.dbms_sql.describe_columns2(l_cursor,l_count,t_desc);
         FOR i IN 1..t_desc.COUNT LOOP
            IF p_col_name IS NULL OR UPPER(t_desc(i).col_name) = UPPER(p_col_name) THEN
               l_full_col_name := r_ds.set_name||'.'||UPPER(t_desc(i).col_name);
               IF p_what IS NULL OR p_what = 'INDEX' THEN
                  ds_utility_var.g_ds_tab.DELETE(l_full_col_name);
                  ds_utility_var.g_ds_tab(l_full_col_name)(0) := t_desc(i).col_name;
               END IF;
               IF p_what IS NULL OR p_what = 'VALUE' THEN
                  ds_utility_var.g_ds_tab2.DELETE(l_full_col_name);
               END IF;
               IF t_desc(i).col_type IN (8/*LONG*/, sys.dbms_types.TYPECODE_CHAR, sys.dbms_types.TYPECODE_VARCHAR
                                       , sys.dbms_types.TYPECODE_VARCHAR2, sys.dbms_types.TYPECODE_CLOB) THEN
                  l_col_type := 'VARCHAR2';
                  sys.dbms_sql.define_column(l_cursor,i,l_string,32767);
               ELSIF t_desc(i).col_type = sys.dbms_types.TYPECODE_NUMBER THEN
                  l_col_type := 'NUMBER';
                  sys.dbms_sql.define_column(l_cursor,i,l_number);
               ELSIF t_desc(i).col_type = sys.dbms_types.TYPECODE_DATE THEN
                  l_col_type := 'DATE';
                  sys.dbms_sql.define_column(l_cursor,i,l_date);
               ELSIF t_desc(i).col_type IN (180/*TIMESTAMP(6)*/, 181/*TIMESTAMP(6) WITH TIME ZONE*/, sys.dbms_types.TYPECODE_TIMESTAMP
                                          , sys.dbms_types.TYPECODE_TIMESTAMP_TZ, sys.dbms_types.TYPECODE_TIMESTAMP_LTZ) THEN
                  l_col_type := 'TIMESTAMP';
                  sys.dbms_sql.define_column(l_cursor,i,l_timestamp);
               ELSE
                  raise_application_error(-20000,'Unsupported data type ('||t_desc(i).col_type||') for column '||t_desc(i).col_name);
               END IF;
            END IF;
         END LOOP;
         l_count := sys.dbms_sql.execute(l_cursor);
         WHILE sys.dbms_sql.fetch_rows(l_cursor) > 0
         LOOP
            FOR i IN 1..t_desc.COUNT LOOP
               IF p_col_name IS NULL OR UPPER(t_desc(i).col_name) = UPPER(p_col_name) THEN
                  l_full_col_name := r_ds.set_name||'.'||UPPER(t_desc(i).col_name);
                  --t_desc(i).col_name;
                  IF t_desc(i).col_type = 1 /* CHAR */ THEN
                     sys.dbms_sql.column_value(l_cursor,i,l_string);
                  ELSIF t_desc(i).col_type = 2 /* NUMBER */ THEN
                     sys.dbms_sql.column_value(l_cursor,i,l_number);
                     l_string := TO_CHAR(l_number);
                  ELSIF t_desc(i).col_type = 12 /* DATE */ THEN
                     sys.dbms_sql.column_value(l_cursor,i,l_date);
                     l_string := REPLACE(TO_CHAR(l_date,ds_utility_var.g_time_mask),' 00:00:00');
                  ELSIF t_desc(i).col_type = 180 /* TIMESTAMP */ THEN
                     sys.dbms_sql.column_value(l_cursor,i,l_timestamp);
                     l_string := TO_CHAR(l_timestamp,ds_utility_var.g_timestamp_mask);
                  ELSE
                     raise_application_error(-20000,'Unsupported data type ('||t_desc(i).col_type||') for column '||t_desc(i).col_name);
                  END IF;
                     IF p_what IS NULL OR p_what = 'INDEX' THEN
                        ds_utility_var.g_ds_tab(l_full_col_name)(ds_utility_var.g_ds_tab(l_full_col_name).COUNT) := l_string;
                     END IF;
                  IF p_what IS NULL OR p_what = 'VALUE' THEN
                     IF l_string IS NOT NULL THEN
                        ds_utility_var.g_ds_tab2(l_full_col_name)(UPPER(ds_masker_krn.unaccentuate_string(l_string))) := NULL; -- any value
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
         sys.dbms_sql.close_cursor(l_cursor);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         RAISE;
   END;
--#begin public
   ---
   -- Check if a value is in a data set
   ---
   FUNCTION is_value_in_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_value IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y for Yes, N for No, NULL if value is NULL
--#end public
   IS
      l_full_col_name VARCHAR2(200);
   BEGIN
      IF p_col_value IS NULL THEN
         RETURN NULL;
      END IF;
      assert(p_set_name IS NOT NULL, 'Error: Parameter "p_set_name" is mandatory!');
      assert(p_col_name IS NOT NULL, 'Error: Parameter "p_col_name" is mandatory!');
      l_full_col_name := p_set_name||'.'||UPPER(p_col_name);
      IF NOT ds_utility_var.g_ds_tab2.EXISTS(l_full_col_name) THEN
         load_ds(p_set_name,p_col_name,'VALUE');
      END IF;
      assert(ds_utility_var.g_ds_tab2.EXISTS(l_full_col_name),'Error: Data set "'||p_set_name||'" or column "'||p_col_name||'" does not exist!');
      RETURN CASE WHEN ds_utility_var.g_ds_tab2(l_full_col_name).EXISTS(UPPER(p_col_value)) THEN 'Y' ELSE 'N' END;
   END;
--#begin public
   ---
   -- Check if a value is in a data set
   ---
   FUNCTION is_value_in_data_set (
      p_set_col_name IN VARCHAR2
    , p_col_value IN VARCHAR2
   )
   RETURN VARCHAR2 -- Y for Yes, N for No, NULL if value is NULL
--#end public
   IS
      l_pos PLS_INTEGER;
   BEGIN
      IF p_col_value IS NULL THEN
         RETURN NULL;
      END IF;
      assert(p_set_col_name IS NOT NULL, 'Error: Parameter "p_set_col_name" is mandatory!');
      l_pos := NVL(INSTR(p_set_col_name,'.'),0);
      assert(l_pos>0,'Error: Parameter "p_set_col_name" format must be "set-name.col-name"');
      RETURN is_value_in_data_set(SUBSTR(p_set_col_name,1,l_pos-1),SUBSTR(p_set_col_name,l_pos+1),p_col_value);
   END;
--#begin public
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_name IN ds_data_sets.set_name%TYPE
    , p_col_name IN ds_utility_var.column_name
    , p_col_len  IN sys.user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      l_col_name ds_utility_var.column_name := UPPER(p_col_name);
      l_full_col_name VARCHAR2(200);
      l_weight_name VARCHAR2(200);
      l_row_idx PLS_INTEGER;
      l_last PLS_INTEGER;
      l_tot_weight NUMBER;
      l_rand NUMBER;
   BEGIN
      assert(p_set_name IS NOT NULL, 'Error: Parameter "p_set_name" is mandatory!');
      assert(p_col_name IS NOT NULL, 'Error: Parameter "p_col_name" is mandatory!');
      l_full_col_name := p_set_name||'.'||UPPER(p_col_name);
      IF NOT ds_utility_var.g_ds_tab.EXISTS(l_full_col_name) THEN
         load_ds(p_set_name,p_col_name,'INDEX');
      END IF;
      assert(ds_utility_var.g_ds_tab.EXISTS(l_full_col_name),'Error: Data set "'||p_set_name||'" or column "'||p_col_name||'" does not exist!');
      IF p_weight IS NOT NULL THEN
         l_weight_name := p_set_name||'.'||UPPER(p_weight);
         IF NOT ds_utility_var.g_ds_tab.EXISTS(l_weight_name) THEN
            load_ds(p_set_name,p_weight,'INDEX'); -- load WEIGHT column if any
            IF ds_utility_var.g_ds_tab.EXISTS(l_weight_name) THEN
               -- Compute and set cumulated weight
               l_tot_weight := 0;
               FOR i IN 1..ds_utility_var.g_ds_tab(l_weight_name).COUNT-1 LOOP
                  l_tot_weight := l_tot_weight + TO_NUMBER(ds_utility_var.g_ds_tab(l_weight_name)(i));
               END LOOP;
               -- Trick: store sum of weights at index 0 (where column name is stored but not used)
               ds_utility_var.g_ds_tab(l_weight_name)(0) := TO_CHAR(l_tot_weight);
            END IF;
         END IF;
         assert(ds_utility_var.g_ds_tab.EXISTS(l_weight_name),'Error: Data set "'||p_set_name||'" or column "'||p_weight||'" does not exist!');
      END IF;
      set_seed(p_seed);
      -- Generate random index
      IF p_weight IS NOT NULL AND ds_utility_var.g_ds_tab(l_weight_name).COUNT>1 /*index 0 = column name*/ THEN
         -- Using weights
         l_last := ds_utility_var.g_ds_tab(l_weight_name).LAST;
         l_rand := SYS.DBMS_RANDOM.value(0,TO_NUMBER(ds_utility_var.g_ds_tab(l_weight_name)(0)));
         l_tot_weight := 0;
         FOR i IN 1..l_last LOOP
            l_row_idx := i;
            l_tot_weight := l_tot_weight + TO_NUMBER(ds_utility_var.g_ds_tab(l_weight_name)(i));
            EXIT WHEN l_rand < l_tot_weight;
         END LOOP;
      ELSE
         -- Withoug using weights => uniform distribution
         l_row_idx := ds_masker_krn.random_integer(1,ds_utility_var.g_ds_tab(l_full_col_name).LAST);
      END IF;
      -- Return value at random index, truncated if necessary
      IF p_col_len IS NOT NULL THEN
         RETURN SUBSTR(ds_utility_var.g_ds_tab(l_full_col_name)(l_row_idx),1,p_col_len);
      END IF;
      reset_seed(p_seed);
      RETURN ds_utility_var.g_ds_tab(l_full_col_name)(l_row_idx);
   END;
--#begin public
   ---
   -- Get a column value from a random row of a given data set
   ---
   FUNCTION random_value_from_data_set (
      p_set_col_name IN ds_data_sets.set_name%TYPE
    , p_col_len  IN sys.user_tab_columns.data_length%TYPE
    , p_seed IN VARCHAR2 := NULL
    , p_weight IN ds_utility_var.column_name := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      l_pos PLS_INTEGER;
   BEGIN
      assert(p_set_col_name IS NOT NULL, 'Error: Parameter "p_set_col_name" is mandatory!');
      l_pos := NVL(INSTR(p_set_col_name,'.'),0);
      assert(l_pos>0,'Error: Parameter "p_set_col_name" format must be "set-name.col-name"');
      RETURN random_value_from_data_set(SUBSTR(p_set_col_name,1,l_pos-1),SUBSTR(p_set_col_name,l_pos+1),p_col_len,p_seed,p_weight);
   END;
--#begin public
   ---
   -- Get a column value from a row selected at random from a given table
   -- A filter (where clause) may be specified
   -- A weight column may be specified to follow its distribution
   -- Cursor remains open to cycle through all values except if requested
   -- Cursors that remained opened can be closed by calling the close_cursors() procedure
   -- To get the ROWID instead of a column value, specify ROWID$ for column name
   -- 
   ---
   FUNCTION random_value_from_table (
      p_tab_name IN user_tables.table_name%TYPE -- table name
    , p_col_name IN user_tab_columns.column_name%TYPE -- column name
    , p_col_len IN user_tab_columns.data_length%TYPE := NULL -- maximum length
    , p_where IN VARCHAR2 := NULL -- filter
    , p_weight IN user_tab_columns.column_name%TYPE := NULL -- name of column holding weight  
    , p_cycle IN VARCHAR2 := 'Y' -- cycle through all values by keeping cursor open
    , p_seed IN VARCHAR2 := NULL -- for deterministic result
   )
   RETURN VARCHAR2
--#end public
   IS
      l_cycle BOOLEAN := NOT (p_weight IS NOT NULL OR NVL(p_cycle,'Y') = 'N');
      l_string ds_utility_var.largest_string;
      l_number NUMBER;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_cursor PLS_INTEGER;
      l_count PLS_INTEGER;
      t_desc sys.dbms_sql.desc_tab2;
      l_col_type VARCHAR2(20);
      l_sql VARCHAR2(4000);
      l_cursor_just_opened BOOLEAN;
      l_col_expr VARCHAR2(61);
      l_full_table_name ds_utility_var.g_long_name_type;
      PROCEDURE close_cursor IS
      BEGIN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         ds_utility_var.g_desc_tab.DELETE(l_cursor);
         ds_utility_var.g_cursor_tab.DELETE(l_sql);
      END;
   BEGIN
      l_full_table_name := CASE WHEN NVL(ds_utility_var.g_owner,USER) != USER THEN ds_utility_var.g_owner || '.' END || p_tab_name;
      -- Trick to handle ROWID
      IF INSTR(p_col_name,'$')>0 THEN
         l_col_expr := REPLACE(p_col_name,'$')||' '||p_col_name; -- e.g., rowid rowid$
      ELSE
         l_col_expr := p_col_name;
      END IF;
      IF p_weight IS NOT NULL THEN
         l_sql := REPLACE(REPLACE(REPLACE(
'WITH tmp AS (
   SELECT $col_name$, NVL(LAG(cumulative_ratio) OVER(ORDER BY rownum),0) lower_ratio_range, cumulative_ratio upper_ratio_range FROM (
   SELECT '||l_col_expr||', SUM($weight$) OVER (ORDER BY rownum) / SUM($weight$) OVER() AS cumulative_ratio FROM $tab_name$'||CASE WHEN p_where IS NOT NULL THEN ' WHERE '||p_where END||')
), rnd AS (
   SELECT dbms_random.value random_value FROM dual
)
SELECT tmp.$col_name$ FROM rnd INNER JOIN tmp ON rnd.random_value >= tmp.lower_ratio_range AND rnd.random_value < tmp.upper_ratio_range'
         , '$col_name$', LOWER(p_col_name)), '$tab_name$', LOWER(l_full_table_name)), '$weight$', LOWER(p_weight));
      ELSE
         l_sql := 'SELECT '||LOWER(p_col_name)||' FROM '||LOWER(l_full_table_name)||CASE WHEN p_where IS NOT NULL THEN ' WHERE '|| p_where END || ' ORDER BY SYS.DBMS_RANDOM.VALUE';
      END IF;
      -- Get cursor for this SQL query from cache
      <<open_cursor>>
      l_cursor_just_opened := FALSE;
      IF p_weight IS NULL AND ds_utility_var.g_cursor_tab.EXISTS(l_sql) THEN
         l_cursor := ds_utility_var.g_cursor_tab(l_sql);
      END IF;
      -- Close any previously open cursor when not cycling
      IF NOT l_cycle THEN
         close_cursor;
      END IF;
      -- Open cursor and prepare execution if not already done
      IF l_cursor IS NULL OR NOT sys.dbms_sql.is_open(l_cursor) THEN
         set_seed(p_seed);
         l_cursor := sys.dbms_sql.open_cursor;
         l_cursor_just_opened := TRUE;
         IF p_weight IS NULL THEN
            ds_utility_var.g_cursor_tab(l_sql) := l_cursor; -- save cursor in cache
         END IF;
         sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
         sys.dbms_sql.describe_columns2(l_cursor,l_count,t_desc);
         ds_utility_var.g_desc_tab(l_cursor) := t_desc; -- save descriptors in cache
         FOR i IN 1..t_desc.COUNT LOOP
            IF t_desc(i).col_type IN (8/*LONG*/, 11/*ROWID*/, sys.dbms_types.TYPECODE_CHAR, sys.dbms_types.TYPECODE_VARCHAR
                                    , sys.dbms_types.TYPECODE_VARCHAR2, sys.dbms_types.TYPECODE_CLOB) THEN
               l_col_type := 'VARCHAR2';
               sys.dbms_sql.define_column(l_cursor,i,l_string,32767);
            ELSIF t_desc(i).col_type = sys.dbms_types.TYPECODE_NUMBER THEN
               l_col_type := 'NUMBER';
               sys.dbms_sql.define_column(l_cursor,i,l_number);
            ELSIF t_desc(i).col_type = sys.dbms_types.TYPECODE_DATE THEN
               l_col_type := 'DATE';
               sys.dbms_sql.define_column(l_cursor,i,l_date);
            ELSIF t_desc(i).col_type IN (180/*TIMESTAMP(6)*/, 181/*TIMESTAMP(6) WITH TIME ZONE*/, sys.dbms_types.TYPECODE_TIMESTAMP
                                       , sys.dbms_types.TYPECODE_TIMESTAMP_TZ, sys.dbms_types.TYPECODE_TIMESTAMP_LTZ) THEN
               l_col_type := 'TIMESTAMP';
               sys.dbms_sql.define_column(l_cursor,i,l_timestamp);
            ELSE
               raise_application_error(-20000,'Unsupported data type ('||t_desc(i).col_type||') for column '||t_desc(i).col_name);
            END IF;
         END LOOP;
         l_count := sys.dbms_sql.execute(l_cursor);
         reset_seed(p_seed);
      END IF;
      -- Fetch next row
      l_count := dbms_sql.fetch_rows(l_cursor);
      -- Get column value
      IF l_count > 0 THEN
         -- Get column descriptors from cache
         t_desc := ds_utility_var.g_desc_tab(l_cursor);
         FOR i IN 1..t_desc.COUNT LOOP
            --t_desc(i).col_name;
            IF t_desc(i).col_type IN (1,11) /* CHAR */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_string);
            ELSIF t_desc(i).col_type = 2 /* NUMBER */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_number);
               l_string := TO_CHAR(l_number);
            ELSIF t_desc(i).col_type = 12 /* DATE */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_date);
               l_string := REPLACE(TO_CHAR(l_date,ds_utility_var.g_time_mask),' 00:00:00');
            ELSIF t_desc(i).col_type = 180 /* TIMESTAMP */ THEN
               sys.dbms_sql.column_value(l_cursor,i,l_timestamp);
               l_string := TO_CHAR(l_timestamp,ds_utility_var.g_timestamp_mask);
            ELSE
               raise_application_error(-20000,'Unsupported data type ('||t_desc(i).col_type||') for column "'||p_tab_name||'.'||t_desc(i).col_name||'"');
            END IF;
         END LOOP;
      END IF;
      IF l_count = 0 OR NOT l_cycle THEN
         close_cursor;
      END IF;
      IF l_count = 0 THEN
         IF l_cursor_just_opened THEN
            -- Query returned no row upon first execution
            RETURN NULL;
         ELSE
            -- End of records reached => re-open cursor and execute query again
            GOTO open_cursor;
         END IF;
      END IF;
      RETURN CASE WHEN p_col_len IS NULL THEN l_string ELSE SUBSTR(l_string,1,p_col_len) END;
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         RAISE;
   END;
--#begin public
   ---
   -- Close opened cursors
   ---
   PROCEDURE close_cursors
--#end public
   IS
      l_sql VARCHAR2(4000);
      l_cursor PLS_INTEGER;
   BEGIN
      -- Close all opened cursors in cache
      l_sql := ds_utility_var.g_cursor_tab.FIRST;
      WHILE l_sql IS NOT NULL LOOP
         l_cursor := ds_utility_var.g_cursor_tab(l_sql);
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         l_sql := ds_utility_var.g_cursor_tab.NEXT(l_sql);
      END LOOP;
      -- Delete cache
      ds_utility_var.g_cursor_tab.DELETE;
      ds_utility_var.g_desc_tab.DELETE;
   END;
--#begin public
   ---
   -- Show data sets in cache
   ---
   PROCEDURE show_ds (
      p_set_name ds_data_sets.set_name%TYPE := NULL
    , p_col_name IN VARCHAR2 := NULL
   )
--#end public
   IS
      t_ds_rows ds_utility_var.ds_rows;
      l_string ds_utility_var.largest_string;
      l_set_name ds_data_sets.set_name%TYPE;
      l_set_col_name ds_utility_var.largest_string;
      l_row_data ds_utility_var.largest_string;
      l_col_count PLS_INTEGER;
      l_pos PLS_INTEGER;
   BEGIN
      -- 1st cache index by INDEX
      l_set_col_name := ds_utility_var.g_ds_tab.FIRST;
      WHILE l_set_col_name IS NOT NULL LOOP
         IF l_set_col_name LIKE NVL(p_set_name,'%')||'.'||NVL(UPPER(p_col_name),'%') THEN
            dbms_output.put_line('');
            dbms_output.put_line('*** '||l_set_col_name||' ***');
            FOR i IN ds_utility_var.g_ds_tab(l_set_col_name).FIRST..ds_utility_var.g_ds_tab(l_set_col_name).LAST LOOP
               dbms_output.put_line(i||': >'||ds_utility_var.g_ds_tab(l_set_col_name)(i)||'<');
            END LOOP;
            dbms_output.put_line(ds_utility_var.g_ds_tab(l_set_col_name).COUNT||' entries found');
         END IF;
         l_set_col_name := ds_utility_var.g_ds_tab.NEXT(l_set_col_name);
      END LOOP;
      -- 2nd cache index by VALUE
      l_set_col_name := ds_utility_var.g_ds_tab2.FIRST;
      WHILE l_set_col_name IS NOT NULL LOOP
         IF l_set_col_name LIKE NVL(p_set_name,'%')||'.'||NVL(UPPER(p_col_name),'%') THEN
            dbms_output.put_line('');
            dbms_output.put_line('*** '||l_set_col_name||' ***');
            l_row_data := ds_utility_var.g_ds_tab2(l_set_col_name).FIRST;
            WHILE l_row_data IS NOT NULL LOOP
               dbms_output.put_line('>'||l_row_data||'<');
               l_row_data := ds_utility_var.g_ds_tab2(l_set_col_name).NEXT(l_row_data);
            END LOOP;
            dbms_output.put_line(ds_utility_var.g_ds_tab2(l_set_col_name).COUNT||' entries found');
         END IF;
         l_set_col_name := ds_utility_var.g_ds_tab2.NEXT(l_set_col_name);
      END LOOP;
   END;
   ---
   -- Delete data set cache
   ---
   PROCEDURE delete_data_set_cache IS
   BEGIN
      ds_utility_var.g_ds_tab.DELETE;
      ds_utility_var.g_ds_tab2.DELETE;
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
           FROM sys.dual
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
           FROM sys.dual
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
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      r_set ds_data_sets%ROWTYPE;
   BEGIN
      r_set.set_id := gen_set_id;
      r_set.set_name := p_set_name;
      r_set.set_type := NVL(p_set_type,'SUB');
      r_set.system_flag := p_system_flag;
      r_set.disabled_flag := p_disabled_flag;
      r_set.visible_flag := p_visible_flag;
      r_set.capture_flag := p_capture_flag;
      r_set.capture_mode := p_capture_mode;
      r_set.capture_user := p_capture_user;
      r_set.params := p_params;
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
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE create_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
--#end public
   IS
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      assert(p_set_name IS NOT NULL, 'Data set name is mandatory!');
      assert(p_set_type='CAP' OR (p_capture_flag IS NOT NULL AND p_capture_mode IS NOT NULL AND p_capture_user IS NOT NULL)
           , 'Capture properties not allowed for non-capture data set!');
      l_set_id := create_data_set_def(
         p_set_name=>p_set_name
        ,p_set_type=>NVL(p_set_type,'SUB')
        ,p_system_flag=>p_system_flag
        ,p_disabled_flag=>p_disabled_flag
        ,p_visible_flag=>p_visible_flag
        ,p_capture_flag=>p_capture_flag
        ,p_capture_mode=>p_capture_mode
        ,p_capture_user=>p_capture_user
        ,p_params=>p_params
      );
   END;
--
--#begin public
/**
* Clone an existing data set definition and return its id
* @param p_set_id       id of data set to clone
* @param p_set_name     data set name
* @param p_visible_flag visible in views and policies (Y/N)
* @param p_capture_flag trigger capture enabled (Y/N)
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
* @return               data set id
*/
   FUNCTION clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE
--     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
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
      -- Cursor to browse columns of a table
      CURSOR c_col (
         p_table_id IN ds_tab_columns.table_id%TYPE
      )
      IS
         SELECT *
           FROM ds_tab_columns
          WHERE table_id = p_table_id
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
      l_table_id ds_tables.table_id%TYPE;
   BEGIN
      -- Clone data set
      FOR r_set IN c_set(p_set_id) LOOP
         r_set.set_id := gen_set_id;
         r_set.set_name := p_set_name;
         r_set.visible_flag := p_visible_flag;
         r_set.capture_flag := p_capture_flag;
         r_set.capture_mode := p_capture_mode;
         r_set.capture_user := p_capture_user;
         r_set.params := p_params;
         r_set.user_created := USER;
         r_set.date_created := SYSDATE;
         INSERT INTO ds_data_sets VALUES r_set;
         -- Clone tables
         FOR r_tab IN c_tab(p_set_id) LOOP
            l_table_id := r_tab.table_id;
            r_tab.set_id := r_set.set_id;
            r_tab.table_id := gen_table_id;
            r_tab.extract_count := 0;
            r_tab.pass_count := 0;
            r_tab.group_count := 0;
            r_tab.table_data := NULL;
            INSERT INTO ds_tables VALUES r_tab;
            -- Clone table columns
            FOR r_col IN c_col(l_table_id) LOOP
               r_col.table_id := r_tab.table_id;
               INSERT INTO ds_tab_columns VALUES r_col;
            END LOOP;
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
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE clone_data_set_def (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_set_name IN ds_data_sets.set_name%TYPE
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
--#end public
   IS
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      l_set_id := clone_data_set_def(
         p_set_id=>p_set_id
        ,p_set_name=>p_set_name
--        ,p_set_type=>p_set_type
        ,p_visible_flag=>p_visible_flag
        ,p_capture_flag=>p_capture_flag
        ,p_capture_mode=>p_capture_mode
        ,p_capture_user=>p_capture_user
        ,p_params=>p_params
      );
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
         l_pos := NVL(INSTR(l_tmp,','),0);
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
     ,p_left_tab IN INTEGER := 3
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
               l_out := l_out || RPAD(' ',p_left_tab-3);
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
      l_pos := NVL(INSTR(p_table_name,'@'),0);
      IF l_pos>0 THEN
         l_table_name := SUBSTR(p_table_name,1,l_pos-1); -- remove db_link name
      ELSE
         l_table_name := p_table_name;
      END IF;
      -- For each column
      FOR r_col IN c_col(NVL(ds_utility_var.g_owner,USER),l_table_name,p_nullable,p_column_name) LOOP
         -- If columns list is provided, keep only: pk columns + mandatory columns + those listed
         IF NVL(p_columns_list,'*') = '*'
         OR NVL(INSTR(', '||p_columns_list||', ', ', '||r_col.column_name||', '),0) > 0
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
      IF p_column_name = 'rowid' THEN
         RETURN 'ROWID';
      ELSIF p_column_name = 'rownum' THEN
         RETURN 'NUMBER';
      END IF;
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
--#begin public
   ---
   -- Get next value of an in-memory sequence
   ---
   FUNCTION in_mem_seq_nextval (
      p_full_column_name IN VARCHAR2
   )
   RETURN PLS_INTEGER
--#end public
   IS
      l_tab_col ds_utility_var.full_column_name := LOWER(p_full_column_name);
      r_seq ds_utility_var.seq_record_type;
      l_seq PLS_INTEGER;
   BEGIN
      assert(l_tab_col IS NOT NULL,'Parameter "p_full_column_name" is mandatory!');
      assert(ds_utility_var.g_seq.EXISTS(l_tab_col),'No sequence found for "'||l_tab_col||'"!');
      r_seq := ds_utility_var.g_seq(l_tab_col);
      assert(ds_utility_var.g_in_mem_seq_tab.EXISTS(r_seq.sequence_name),'No in-memory sequence found for "'||l_tab_col||'"!');
      l_seq := ds_utility_var.g_in_mem_seq_tab(r_seq.sequence_name);
      ds_utility_var.g_in_mem_seq_tab(r_seq.sequence_name) := l_seq + NVL(r_seq.in_mem_seq_increment_by,1);
      RETURN l_seq;
   END;
   ---
   -- Format a column value based on its type
   -- Called when generating scripts
   -- once values have been fetched already
   ---
   FUNCTION format_column_value (
      p_part IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_col_name IN VARCHAR2
    , p_col_type IN VARCHAR2
    , p_col_val IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_col_val VARCHAR2(32767) := p_col_val;
      l_tab_col ds_utility_var.full_column_name;
      r_seq ds_utility_var.seq_record_type;
      l_seq PLS_INTEGER;
   BEGIN
      IF p_col_val = 'NULL' THEN
         RETURN p_col_val; -- Don't format NULL value
      END IF;
      IF p_col_type IN ('CHAR','VARCHAR2','CLOB') THEN
         l_col_val := '''' || l_col_val || '''';
      ELSIF p_col_type = 'DATE' THEN
         l_col_val := 'TO_DATE('''||l_col_val||''','''||ds_utility_var.g_time_mask||''')';
      ELSIF p_col_type LIKE 'TIMESTAMP%' THEN
         l_col_val := 'TO_TIMESTAMP('''||l_col_val||''','''||ds_utility_var.g_timestamp_mask||''')';
      ELSIF p_col_type = 'ROWID' THEN
         l_col_val := 'CHARTOROWID('''||l_col_val||''')';
      ELSIF p_col_type = 'NUMBER' THEN
         IF NVL(INSTR(l_col_val,','),0)>0 THEN
            l_col_val := 'TO_NUMBER('''||l_col_val||''')';
         END IF;
         l_tab_col := LOWER(p_table_name||'.'||p_col_name);
         IF ds_utility_var.g_seq.EXISTS(l_tab_col) THEN
            r_seq := ds_utility_var.g_seq(l_tab_col);
            IF r_seq.msk_type = 'SEQUENCE' AND r_seq.sequence_name IS NOT NULL AND get_boolean_option_value(r_seq.msk_options,'differ_masking',false)
            THEN
               l_col_val := 'ds_utility_krn.set_identifier(''' || r_seq.pk_tab_name || ''',''' || r_seq.pk_col_name || ''',' || l_col_val || ',' || LOWER(r_seq.sequence_name) || '.nextval' || ')';
            END IF;
         ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) THEN
            r_seq := ds_utility_var.g_map(l_tab_col);
            IF r_seq.msk_type = 'SEQUENCE' AND r_seq.sequence_name IS NOT NULL AND get_boolean_option_value(r_seq.msk_options,'differ_masking',false)
            THEN
               l_col_val := 'ds_utility_krn.get_identifier(''' || r_seq.pk_tab_name || ''',''' || r_seq.pk_col_name || ''',' ||l_col_val || ')';
            END IF;
         END IF;
      ELSIF p_col_type = 'NO-FORMATTING' THEN
         NULL; -- keep l_col_val as is
      ELSE
         assert(FALSE,'Unsupported data type ('||p_col_type||') for column '||p_table_name||'.'||p_col_name);
      END IF;
      RETURN l_col_val;
   END;
   ---
   -- Like INSTR but ignore case
   ---
   FUNCTION instr_ignore_case (
      p_string IN VARCHAR2
    , p_what IN VARCHAR2
   )
   RETURN PLS_INTEGER
   IS
      l_len PLS_INTEGER := LENGTH(p_what);
      l_pos PLS_INTEGER;
   BEGIN
      IF p_string IS NULL THEN
         RETURN NULL;
      END IF;
      l_pos := NVL(INSTR(UPPER(p_string),UPPER(p_what)),0);
      RETURN l_pos;
   END instr_ignore_case;
   ---
   -- Replace string while ignoring case
   ---
   FUNCTION replace_string_ignore_case (
      p_string IN VARCHAR2
    , p_what IN VARCHAR2
    , p_with IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_len PLS_INTEGER := LENGTH(p_what);
      l_pos PLS_INTEGER;
   BEGIN
      l_pos := NVL(INSTR(UPPER(p_string),UPPER(p_what)),0);
      IF l_pos > 0 THEN
         RETURN(SUBSTR(p_string,1,l_pos-1)||p_with||replace_string_ignore_case(SUBSTR(p_string,l_pos+l_len),p_what,p_with));
      END IF;
      RETURN p_string;
   END replace_string_ignore_case;
   --
--#begin public
/**
* Return the token associated with a given value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_value        value to be tokenized
* @return               token associated with the value
*/
   FUNCTION get_token_from_value (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_value ds_tokens.value%TYPE
   )
   RETURN ds_tokens.token%TYPE
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      CURSOR c_tok (
        p_value ds_tokens.value%TYPE
      )
      IS
         SELECT token
           FROM ds_tokens tok
          WHERE value = p_value
         ;
      l_token ds_tokens.token%TYPE;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_table_name IS NOT NULL, 'Table name parameter cannot be NULL');
      assert(p_column_name IS NOT NULL, 'Table name parameter cannot be NULL');
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      r_msk := get_mask(p_table_name, p_column_name);
      OPEN c_tok(CASE WHEN get_boolean_option_value(r_msk.options,'encrypt_tokenized_values',ds_utility_var.g_encrypt_tokenized_values) THEN ds_masker_krn.encrypt_string(p_value) ELSE p_value END);
      FETCH c_tok INTO l_token;
      CLOSE c_tok;
      RETURN l_token;
   END;
--
--#begin public
/**
* Return the token associated with a given value
* @param p_msk_id       mask id
* @param p_value        value to be tokenized
* @return               token associated with the value
*/
   FUNCTION get_token_from_value (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_value ds_tokens.value%TYPE
   )
   RETURN ds_tokens.token%TYPE
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      CURSOR c_tok (
        p_value ds_tokens.value%TYPE
      )
      IS
         SELECT token
           FROM ds_tokens
          WHERE msk_id = p_msk_id
            AND value = p_value
         ;
      l_token ds_tokens.token%TYPE;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_msk_id IS NOT NULL, 'Mask id parameter cannot be NULL');
      IF p_value IS NULL THEN
         RETURN NULL;
      END IF;
      r_msk := get_mask(p_msk_id);
      OPEN c_tok(CASE WHEN get_boolean_option_value(r_msk.options,'encrypt_tokenized_values',ds_utility_var.g_encrypt_tokenized_values) THEN ds_masker_krn.encrypt_string(p_value) ELSE p_value END);
      FETCH c_tok INTO l_token;
      CLOSE c_tok;
      RETURN l_token;
   END;
--
--#begin public
/**
* Return the value associated with a token
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_token        token
* @return               value associated with the token
*/
   FUNCTION get_value_from_token (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_token ds_tokens.token%TYPE
   )
   RETURN ds_tokens.value%TYPE
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      CURSOR c_tok (
         p_msk_id ds_masks.msk_id%TYPE
       , p_token ds_tokens.token%TYPE
      )
      IS
         SELECT tok.value
           FROM ds_tokens tok
          WHERE tok.msk_id = p_msk_id
            AND tok.token = p_token
         ;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_table_name IS NOT NULL, 'Table name parameter cannot be NULL');
      assert(p_column_name IS NOT NULL, 'Table name parameter cannot be NULL');
      IF p_token IS NULL THEN
         RETURN NULL;
      END IF;
      r_msk := get_mask(p_table_name, p_column_name);
      OPEN c_tok(r_msk.msk_id,p_token);
      FETCH c_tok INTO l_value;
      CLOSE c_tok;
      RETURN CASE WHEN get_boolean_option_value(r_msk.options,'encrypt_tokenized_values',ds_utility_var.g_encrypt_tokenized_values) THEN ds_masker_krn.decrypt_string(l_value) ELSE l_value END;
   END;
   --
--#begin public
/**
* Return the value associated with a token
* @param p_msk_id       mask id
* @param p_token        token
* @return               value associated with the token
*/
   FUNCTION get_value_from_token (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_token ds_tokens.token%TYPE
   )
   RETURN ds_tokens.value%TYPE
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      CURSOR c_tok IS
         SELECT value
           FROM ds_tokens
          WHERE msk_id = p_msk_id
            AND token = p_token
         ;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_msk_id IS NOT NULL, 'Mask id parameter cannot be NULL');
      IF p_token IS NULL THEN
         RETURN NULL;
      END IF;
      r_msk := get_mask(p_msk_id);
      OPEN c_tok;
      FETCH c_tok INTO l_value;
      CLOSE c_tok;
      RETURN CASE WHEN get_boolean_option_value(r_msk.options,'encrypt_tokenized_values',ds_utility_var.g_encrypt_tokenized_values) THEN ds_masker_krn.decrypt_string(l_value) ELSE l_value END;
   END;
   --
--#begin public
/**
* Set the token associated with a given value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_token        token
* @param p_value        value
*/
   PROCEDURE set_token_for_value (
      p_table_name ds_utility_var.table_name
    , p_column_name ds_utility_var.column_name
    , p_value ds_tokens.value%TYPE
    , p_token ds_tokens.token%TYPE
   )
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_table_name IS NOT NULL, 'Table name parameter cannot be NULL');
      assert(p_column_name IS NOT NULL, 'Table name parameter cannot be NULL');
      assert(p_value IS NOT NULL, 'Value parameter cannot be NULL');
      assert(p_token IS NOT NULL, 'Token parameter cannot be NULL');
      r_msk := get_mask(p_table_name, p_column_name);
      l_value := CASE WHEN get_boolean_option_value(r_msk.options,'encrypt_tokenized_values',ds_utility_var.g_encrypt_tokenized_values) THEN ds_masker_krn.encrypt_string(p_value) ELSE p_value END;
      UPDATE ds_tokens
         SET token = p_token
       WHERE msk_id = r_msk.msk_id
         AND value = l_value;
      IF SQL%NOTFOUND THEN
         INSERT INTO ds_tokens (
            msk_id, token, value
         ) VALUES (
            r_msk.msk_id, p_token, l_value
         );
      END IF;
   END;
   --
--#begin public
/**
* Set the token associated with a given value
* @param msk_id         mask id
* @param p_token        token
* @param p_value        value
*/
   PROCEDURE set_token_for_value (
      p_msk_id ds_tokens.msk_id%TYPE
    , p_value ds_tokens.value%TYPE
    , p_token ds_tokens.token%TYPE
   )
--#end public
   IS
      l_value ds_tokens.value%TYPE;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      assert(p_msk_id IS NOT NULL, 'Mask id parameter cannot be NULL');
      assert(p_value IS NOT NULL, 'Value parameter cannot be NULL');
      assert(p_token IS NOT NULL, 'Token parameter cannot be NULL');
      l_value := CASE WHEN ds_utility_var.g_encrypt_tokenized_values THEN ds_masker_krn.encrypt_string(p_value) ELSE p_value END;
      UPDATE ds_tokens
         SET token = p_token
       WHERE msk_id = p_msk_id
         AND value = l_value;
      IF SQL%NOTFOUND THEN
         INSERT INTO ds_tokens (
            msk_id, token, value
         ) VALUES (
            p_msk_id, p_token, l_value
         );
      END IF;
   END;
   ---
   -- Check whether a column is relocated or tokenized
   -- i.e. a column whose masking can be done w/o join
   ---
   FUNCTION is_masked (
      p_tab_name IN VARCHAR2 -- table name
    , p_col_name IN VARCHAR2 -- column name
   )
   RETURN BOOLEAN
   IS
      l_tab_col ds_utility_var.full_column_name;
      r_seq ds_utility_var.seq_record_type;
      l_seq PLS_INTEGER;
   BEGIN
      l_tab_col := LOWER(p_tab_name||'.'||p_col_name);
      IF ds_utility_var.g_seq.EXISTS(l_tab_col) THEN
         r_seq := ds_utility_var.g_seq(l_tab_col);
      ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) THEN
         r_seq := ds_utility_var.g_map(l_tab_col);
      END IF;
      RETURN ds_utility_var.g_mask_data AND r_seq.column_name IS NOT NULL
         AND NOT ds_utility_var.g_fk_tab.EXISTS(l_tab_col); -- ignored FKs involved in PK propagation
   END;
   ---
   -- Chech whether a SQL expression masking a column depends on
   -- other columns of the table. Embedded string are not searched.
   ---
   FUNCTION is_dependent (
      p_sql IN VARCHAR2 -- SQL masking expression
    , p_col_name IN VARCHAR2 -- masked column name
    , p_col_names IN ds_utility_var.column_name_table -- table column names
   )
   RETURN BOOLEAN
   IS
      l_found BOOLEAN := FALSE;
      l_beg PLS_INTEGER;
      l_end PLS_INTEGER;
      l_pos PLS_INTEGER := 1;
      l_col_name ds_utility_var.column_name;
   BEGIN
      l_pos := 1;
      <<embedded_string_loop>>
      LOOP
         l_beg := NVL(INSTR(p_sql,'''',l_pos),0); --search start of string (single quote)
         EXIT embedded_string_loop WHEN l_beg <= 0;
         l_end := NVL(INSTR(p_sql,'''',l_beg+1,1),0); -- search for end of string (single quote)
         assert(l_end>0,'Unmatched single quote at column '||l_beg||'  in SQL expression: '||p_sql);
         l_found := is_dependent(SUBSTR(p_sql,l_pos,l_beg-l_pos), p_col_name, p_col_names);
         EXIT WHEN l_found;
         l_pos := l_end + 1;
      END LOOP embedded_string_loop;
      IF NOT l_found THEN
         FOR i IN 1..p_col_names.COUNT LOOP
            l_col_name := p_col_names(i);
            IF l_col_name != LOWER(p_col_name) THEN
               l_found := regexp_like(SUBSTR(p_sql,l_pos),'([^A-Za-z0-9_]|^):?'||l_col_name||'([^A-Za-z0-9_]|$)','i');
            END IF;
            EXIT WHEN l_found;
         END LOOP;
      END IF;
      RETURN l_found;
   END;
   ---
   -- Like REGEX_REPLACE but with no replacement in quoted string
   ---
   FUNCTION sql_regexp_replace (
      p_sql IN VARCHAR2
    , p_regexp IN VARCHAR2
    , p_replace IN VARCHAR2 := NULL
    , p_position IN PLS_INTEGER := NULL
    , p_occurence IN PLS_INTEGER := NULL
    , p_options IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_sql VARCHAR2(4000);
      l_beg PLS_INTEGER;
      l_end PLS_INTEGER;
      l_pos PLS_INTEGER;
      FUNCTION do_replace (
         p_sql IN VARCHAR2
      )
      RETURN VARCHAR2
      IS
         l_sql VARCHAR2(4000);
         l_idx PLS_INTEGER;
      BEGIN
         IF p_sql IS NULL THEN
            RETURN NULL;
         END IF;
         l_sql := regexp_replace(p_sql,p_regexp,p_replace,p_position,p_occurence,p_options);
         RETURN l_sql;
      END;
   BEGIN
      l_pos := 1;
      <<embedded_string_loop>>
      LOOP
         l_beg := NVL(INSTR(p_sql,'''',l_pos),0); --search start of string (single quote)
         EXIT embedded_string_loop WHEN l_beg <= 0;
         l_end := NVL(INSTR(p_sql,'''',l_beg+1,1),0); -- search for end of string (single quote)
         assert(l_end>0,'Unmatched single quote at column '||l_beg||'  in SQL expression: '||p_sql);
         l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos,l_beg-l_pos))
                        || SUBSTR(p_sql,l_beg,l_end-l_beg+1);
         l_pos := l_end + 1;
      END LOOP embedded_string_loop;
      l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos));
      RETURN l_sql;
   END;
   ---
   -- Get replacement value for given table column and operation
   -- Do nothing when masking is disabled or when generating a script
   -- (data was already masked when values were fetched)
   ---
   FUNCTION get_forced_column_value (
      p_part IN VARCHAR2
    , p_tab_name IN VARCHAR2 -- table name
    , p_col_name IN VARCHAR2 -- column name
    , p_col_rec IN OUT ds_utility_var.col_record -- (includes column type)
    , p_oper IN VARCHAR2     -- operation
    , p_data IN VARCHAR2     -- Y/N
   )
   RETURN VARCHAR2
   IS
      l_name VARCHAR2(100);
      l_col_val VARCHAR2(32767);
      l_pos_from PLS_INTEGER;
      l_pos_to PLS_INTEGER;
      l_len PLS_INTEGER;
      l_ch VARCHAR2(1 CHAR);
      r_col_rec ds_utility_var.col_record;
      l_masking BOOLEAN := FALSE;
      l_cnt PLS_INTEGER;
      l_tab_col ds_utility_var.full_column_name;
      r_seq ds_utility_var.seq_record_type;
      l_oper VARCHAR2(20);
      -- Replace operation with an TRUE (1=1) or FALSE (1=0) expression
      PROCEDURE replace_op (
         p_op_short IN VARCHAR2 -- I,U,D,S
       , p_op_long  IN VARCHAR2 -- INSERTING, UPDATING, DELETING, SELECTING
      )
      IS
      BEGIN
         IF INSTR(r_seq.msk_params,p_op_long)>0 THEN
            r_seq.msk_params := sql_regexp_replace(r_seq.msk_params,'([^A-Za-z0-9_]|^)('||p_op_long||')([^A-Za-z0-9_]|$)','\1'||CASE WHEN p_oper = p_op_short THEN '1=1' ELSE '1=0' END ||'\3',1,0,'i');
         END IF;
      END;
   BEGIN
      assert(p_oper IN ('I','U','S'), 'Error: operation must be I)insert, U)pdate or S)elect');
      l_col_val := p_col_rec.col_val;
      IF p_data IS NOT NULL OR NOT ds_utility_var.g_mask_data THEN
         p_col_rec.is_masked := FALSE;
         RETURN l_col_val;
      END IF;
      l_tab_col := LOWER(p_tab_name||'.'||p_col_name);
      -- Get mask if any
      r_seq := NULL;
      IF ds_utility_var.g_seq.EXISTS(l_tab_col) THEN
         r_seq := ds_utility_var.g_seq(l_tab_col);
      ELSIF ds_utility_var.g_map.EXISTS(l_tab_col) THEN
         r_seq := ds_utility_var.g_map(l_tab_col);
      END IF;
      IF r_seq.msk_type = 'SQL'
      AND NOT ds_utility_var.g_fk_tab.EXISTS(LOWER(p_tab_name||'.'||p_col_name)) -- ignored FKs involved in PK propagation
      THEN
         replace_op('I','INSERTING');
         replace_op('U','UPDATING');
         replace_op('D','DELETING');
         replace_op('S','SELECTING');
         l_col_val := r_seq.msk_params;
         IF r_seq.nullable = 'Y' AND NOT get_boolean_option_value(r_seq.msk_options,'mask_null_values',false) THEN
            l_col_val := 'CASE WHEN '||r_seq.column_name||' IS NOT NULL THEN '||l_col_val||' END';
         END IF;
          -- Replace PK column name with FK column name in SQL expression
         IF r_seq.column_name /*fk_col_name*/ != r_seq.pk_col_name THEN
            l_col_val := sql_regexp_replace(l_col_val,'([^A-Za-z0-9_]|^)('||r_seq.pk_col_name||')([^A-Za-z0-9_]|$)','\1'||r_seq.column_name||'\3',1,0,'i');
         END IF;
      ELSIF r_seq.msk_type = 'TOKENIZE' THEN
         l_col_val := 'ds_utility_krn.get_token_from_value('||r_seq.msk_id||','||l_col_val||')';
         IF p_col_rec.data_type = 'NUMBER' THEN
            l_col_val := 'TO_NUMBER('||l_col_val||')';
         ELSIF p_col_rec.data_type = 'DATE' THEN
            l_col_val := 'TO_DATE('||l_col_val||')';
         ELSIF p_col_rec.data_type LIKE 'TIMESTAMP%' THEN
            l_col_val := 'TO_TIMESTAMP('||l_col_val||')';
         END IF;
      ELSIF r_seq.msk_type = 'SEQUENCE' AND r_seq.sequence_name IS NOT NULL THEN
         IF NOT get_boolean_option_value(r_seq.msk_options,'differ_masking',false) THEN
            l_col_val := 'ds_utility_krn.get_identifier(' || r_seq.msk_id || ',' || l_col_val || ')';
         END IF;
      END IF;
      -- Bind variables if any
      IF r_seq.msk_type IS NOT NULL THEN
         l_cnt := 0;
         l_pos_from := 1;
         WHILE TRUE LOOP
            -- Search for bind variable (e.g. :var)
            WHILE TRUE LOOP
               l_ch := SUBSTR(l_col_val,l_pos_from,1);
               EXIT WHEN l_ch IS NULL OR l_ch = ':';
               IF l_ch = '''' THEN
                  WHILE TRUE LOOP
                     l_pos_from := l_pos_from + 1;
                     l_ch := SUBSTR(l_col_val,l_pos_from,1);
                     EXIT WHEN l_ch IS NULL OR l_ch = '''';
                  END LOOP;
                  assert(l_ch = '''','Unterminated string in SQL mask for '||p_col_rec.table_name||'.'||UPPER(p_col_rec.column_name));
               END IF;
               l_pos_from := l_pos_from + 1;
            END LOOP;
            EXIT WHEN l_ch IS NULL OR l_ch != ':';
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
            l_len := l_pos_to - l_pos_from;
            l_name := LOWER(SUBSTR(l_col_val,l_pos_from+1,l_len-1));
            IF l_name IS NOT NULL AND ds_utility_var.g_pos_tab.EXISTS(l_name) THEN
               r_col_rec := ds_utility_var.g_col_tab(ds_utility_var.g_pos_tab(l_name));
               IF r_col_rec.is_masked AND l_name != p_col_rec.column_name THEN
                  -- Do not replace bind variable if not processed yet
                  l_cnt := l_cnt + 1;
                  EXIT;
               ELSE
                  -- Replace bind variable with column value (or column name when no data provided)
                  l_col_val := SUBSTR(l_col_val,1,l_pos_from-1) -- part before :var
                            || r_col_rec.col_val -- :var part
                            || SUBSTR(l_col_val,l_pos_to); -- part after :var
                  l_len := LENGTH(r_col_rec.col_val);
                  END IF;
            END IF;
            l_pos_from := l_pos_from + l_len;
         END LOOP;
         IF l_cnt = 0 THEN
            p_col_rec.is_masked := FALSE;
         ELSE
            -- Rollback changes
            l_col_val := p_col_rec.col_val;
         END IF;
      END IF;
      RETURN l_col_val;
   END;
   ---
   -- Prefix columns with table alias in a given expression
   ---
   FUNCTION add_table_alias (
      p_sql IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_col_names IN ds_utility_var.column_name_table
   )
   RETURN VARCHAR2
   IS
      l_sql VARCHAR2(4000);
      l_beg PLS_INTEGER;
      l_end PLS_INTEGER;
      l_pos PLS_INTEGER;
      FUNCTION do_replace (
         p_sql IN VARCHAR2
      )
      RETURN VARCHAR2
      IS
         l_sql VARCHAR2(4000) := p_sql;
         l_idx PLS_INTEGER;
         l_col_name ds_utility_var.column_name;
      BEGIN
         IF p_sql IS NULL THEN
            RETURN NULL;
         END IF;
         -- Check if rowid is already in the list of columns to avoid processing it twice
         l_idx := 0;
         FOR i IN REVERSE 1..p_col_names.COUNT LOOP
            IF p_col_names(i) = 'rowid' THEN
               l_idx := 1;
               EXIT;
            END IF;
         END LOOP;
         -- Search for each column name and prefix it with alias
         FOR i IN l_idx..p_col_names.COUNT LOOP
            l_col_name := CASE WHEN i = 0 THEN 'rowid' ELSE p_col_names(i) END; -- consider that rowid is at index 0
            IF l_col_name != 'rownum' THEN --rownum is never prefixed with table alias
               l_sql := regexp_replace(l_sql,'([^A-Za-z0-9_]|^)('||l_col_name||')([^A-Za-z0-9_]|$)','\1'||p_table_alias||'.\2\3',1,0,'i');
            END IF;
         END LOOP;
         RETURN l_sql;
      END;
   BEGIN
      IF p_table_alias IS NULL THEN
         RETURN p_sql;
      END IF;
      IF p_sql IS NULL THEN
         RETURN NULL;
      END IF;
      l_pos := 1;
      <<embedded_string_loop>>
      LOOP
         l_beg := NVL(INSTR(p_sql,'''',l_pos),0); --search start of string (single quote)
         EXIT embedded_string_loop WHEN l_beg <= 0;
         l_end := NVL(INSTR(p_sql,'''',l_beg+1,1),0); -- search for end of string (single quote)
         assert(l_end>0,'Unmatched single quote at column '||l_beg||'  in SQL expression: '||p_sql);
         l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos,l_beg-l_pos))
                        || SUBSTR(p_sql,l_beg,l_end-l_beg+1);
         l_pos := l_end + 1;
      END LOOP embedded_string_loop;
      l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos));
      RETURN l_sql;
   END;
   ---
   -- Replace a table alias with another for given columns only (shuffled columns)
   ---
   FUNCTION replace_table_alias (
      p_sql IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_table_alias2 IN VARCHAR2
    , p_col_names IN ds_utility_var.column_name_table
   )
   RETURN VARCHAR2
   IS
      l_sql VARCHAR2(4000);
      l_beg PLS_INTEGER;
      l_end PLS_INTEGER;
      l_pos PLS_INTEGER;
      FUNCTION do_replace (
         p_sql IN VARCHAR2
      )
      RETURN VARCHAR2
      IS
         l_sql VARCHAR2(4000) := p_sql;
         l_idx PLS_INTEGER;
         l_col_name ds_utility_var.column_name;
      BEGIN
         IF p_sql IS NULL THEN
            RETURN NULL;
         END IF;
         -- Check if rowid is already in the list of columns to avoid processing it twice
         l_idx := 0;
         FOR i IN REVERSE 1..p_col_names.COUNT LOOP
            IF p_col_names(i) = 'rowid' THEN
               l_idx := 1;
               EXIT;
            END IF;
         END LOOP;
         -- Search for each column name and prefix it with alias
         FOR i IN l_idx..p_col_names.COUNT LOOP
            l_col_name := CASE WHEN i = 0 THEN 'rowid' ELSE p_col_names(i) END; -- consider that rowid is at index 0
            IF l_col_name != 'rownum' THEN --rownum is never prefixed with table alias
               l_sql := regexp_replace(l_sql,'([^A-Za-z0-9_]|^)('||p_table_alias||'\.'||l_col_name||')([^A-Za-z0-9_]|$)'
                                            ,'\1'||p_table_alias2||'.'||l_col_name||'\3',1,0,'i');
            END IF;
         END LOOP;
         RETURN l_sql;
      END;
   BEGIN
      IF p_sql IS NULL OR p_table_alias IS NULL OR p_table_alias2 IS NULL THEN
         RETURN NULL;
      END IF;
      l_pos := 1;
      <<embedded_string_loop>>
      LOOP
         l_beg := NVL(INSTR(p_sql,'''',l_pos),0); --search start of string (single quote)
         EXIT embedded_string_loop WHEN l_beg <= 0;
         l_end := NVL(INSTR(p_sql,'''',l_beg+1,1),0); -- search for end of string (single quote)
         assert(l_end>0,'Unmatched single quote at column '||l_beg||'  in SQL expression: '||p_sql);
         l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos,l_beg-l_pos))
                        || SUBSTR(p_sql,l_beg,l_end-l_beg+1);
         l_pos := l_end + 1;
      END LOOP embedded_string_loop;
      l_sql := l_sql || do_replace(SUBSTR(p_sql,l_pos));
      RETURN l_sql;
   END;
   ---
   -- Build specified part of a sql statement
   ---
   FUNCTION build_sql_statement_part (
      p_part IN VARCHAR2
     ,p_table_name IN VARCHAR2
     ,p_table_alias IN VARCHAR2
     ,p_op IN VARCHAR2
     ,p_columns_list IN ds_tables.columns_list%TYPE
     ,p_left_tab IN INTEGER := 3
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_data IN VARCHAR2 := NULL
     ,p_pk_size IN INTEGER := 0
     ,p_indent IN INTEGER := 0
   )
   RETURN ds_tables.columns_list%TYPE
   IS
      l_out VARCHAR2(32767);
      l_set VARCHAR2(32767);
      l_where VARCHAR2(32767);
      l_ws VARCHAR2(30);
      l_col_names ds_utility_var.column_name_table;
      l_col_val VARCHAR2(32767);
      l_db_link VARCHAR2(31);
      l_col_rec ds_utility_var.col_record;
      l_col_tab ds_utility_var.col_table;
      l_tab_col ds_utility_var.full_column_name;
      l_idx PLS_INTEGER;
      l_is_masked BOOLEAN;
      l_cnt PLS_INTEGER;
   BEGIN
      assert(p_part IN ('S','I','U','D','X'), 'Error: SQL statement part must be S)elect, I)insert, U)pdate, D)elete');
      assert(p_op IN ('S','I','U'), 'Error: operation must be S)elect, I)insert or U)pdate');
      l_db_link := CASE WHEN p_db_link IS NULL THEN NULL ELSE '@'||p_db_link END;
      assert(p_columns_per_line > 0,'Columns per line must be > 0');
      l_col_names := tokenize_columns_list(p_columns_list);
      ds_utility_var.g_col_tab.DELETE;
      ds_utility_var.g_pos_tab.DELETE;
      l_col_rec.table_name := p_table_name;
      l_is_masked := FALSE;
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_rec.column_name := l_col_names(i);
         l_col_rec.data_type := get_column_type(p_table_name,l_col_rec.column_name);
         l_col_rec.is_masked := l_col_rec.column_name NOT IN ('rowid','rownum')
                            AND is_masked(p_table_name,l_col_rec.column_name);
         l_is_masked := l_is_masked OR l_col_rec.is_masked;
         IF p_data IS NULL THEN
            l_col_rec.col_val := l_col_rec.column_name;
         ELSE
            l_col_rec.col_val := format_column_value(p_part,p_table_name,l_col_rec.column_name,l_col_rec.data_type,NVL(REPLACE(extract_string(p_data,i),'\~','~'),'NULL'));
         END IF;
         ds_utility_var.g_col_tab(i) := l_col_rec;
         ds_utility_var.g_pos_tab(l_col_rec.column_name) := i;
      END LOOP;
      l_cnt := 0;
      -- While there are still columns to be masked
      WHILE l_is_masked LOOP
         l_cnt := l_cnt + 1;
         assert(l_cnt<=100,'Loop detected in masks of '||p_table_name);
         l_is_masked := FALSE;
         FOR i IN 1..l_col_names.COUNT LOOP
            l_col_rec := ds_utility_var.g_col_tab(i);
            IF l_col_rec.is_masked AND l_col_rec.column_name NOT IN ('rowid','rownum') THEN
               l_col_rec.col_val := get_forced_column_value(p_part,p_table_name,l_col_rec.column_name,l_col_rec,p_op,p_data);
               l_is_masked := l_is_masked OR l_col_rec.is_masked;
               ds_utility_var.g_col_tab(i) := l_col_rec;
            END IF;
         END LOOP;
      END LOOP;
      IF p_part IN ('I') THEN
         IF p_indent > 0 THEN
            l_ws := LPAD(' ', p_indent, ' ');
         END IF;
      END IF;
      FOR i IN 1..l_col_names.COUNT LOOP
         l_col_rec := ds_utility_var.g_col_tab(i);
         IF l_col_rec.column_name IN ('rowid','rownum') THEN
            GOTO next_col;
         END IF;
         l_col_val := l_col_rec.col_val;
         l_tab_col := LOWER(p_table_name||'.'||l_col_rec.column_name);
         -- Is the column involved in a PK whose masking must be propagated?
         IF p_data IS NULL AND ds_utility_var.g_pk_tab.EXISTS(l_tab_col) THEN
            -- Save column expression for propagation to FK columns
            ds_utility_var.g_pk_tab(l_tab_col).col_val := l_col_val;
         END IF;
         IF p_part IN ('S','X') THEN
           l_col_val := add_table_alias(l_col_val,p_table_alias,l_col_names);
            -- Add column alias when needed
            IF p_part = 'S' THEN
               IF l_col_val != CASE WHEN p_table_alias IS NOT NULL THEN p_table_alias||'.' END || l_col_rec.column_name THEN
                  l_col_val := l_col_val || ' ' || l_col_rec.column_name;
               END IF;
            END IF;
         END IF;
         IF p_part IN ('U','D') THEN
            -- Generate where clause of an UPDATE or DELETE based on PK columns
            IF i <= p_pk_size THEN
               IF i = 1 THEN
                  l_where := CHR(10) || l_ws || ' WHERE ';
               ELSE
                  l_where := l_where || CHR(10) || l_ws || '   AND ';
               END IF;
               l_where := l_where || l_col_rec.column_name || ' = ' || l_col_val;
            END IF;
         END IF;
         IF p_part = 'U' THEN
            -- Generate SET clause of an UPDATE for non-PK columns
            IF i > p_pk_size THEN
               IF i = p_pk_size + 1 THEN
                  l_set := CHR(10) || l_ws || '   SET ';
               ELSE
                  l_set := l_set || CHR(10) || l_ws || '     , ';
               END IF;
               l_set := l_set || l_col_rec.column_name || ' = ' || l_col_val;
            END IF;
         END IF;
         -- Generate identation and column separator
         IF p_part IN ('S','I','X') THEN
            -- Generate list of columns to SELECT or INSERT
            l_idx := i - p_pk_size;
            IF MOD(l_idx-1,p_columns_per_line) = 0 THEN
               IF l_out IS NOT NULL THEN
                  l_out := l_out || CHR(10);
                  l_out := l_out || RPAD(' ',p_left_tab-3);
               ELSE
                  IF p_indent_first_line = 'Y' THEN
                     l_out := l_out || RPAD(' ',p_left_tab);
                  END IF;
               END IF;
            END IF;
            IF l_idx > 1 THEN
               IF p_part = 'X' THEN
                  l_out := l_out || '||''~~''||';
               ELSE
                  l_out := l_out || ', ';
               END IF;
            END IF;
         END IF;
         -- Generate column value
         IF p_part IN ('S','I') THEN
            l_out := l_out || l_col_val;
         ELSIF p_part = 'X' THEN
            IF l_col_rec.data_type IN ('CHAR','VARCHAR2','CLOB') THEN
               l_out := l_out || 'REPLACE(REPLACE('||l_col_val||','''''''',''''''''''''),''~'',''\~'')';
            ELSIF l_col_rec.data_type = 'DATE' THEN
               l_out := l_out || 'TO_CHAR('||l_col_val||','''||ds_utility_var.g_time_mask||''')';
            ELSIF l_col_rec.data_type LIKE 'TIMESTAMP%' THEN
               l_out := l_out || 'TO_CHAR('||l_col_val||','''||ds_utility_var.g_timestamp_mask||''')';
            ELSIF l_col_rec.data_type = 'ROWID' THEN
               l_out := l_out || 'ROWIDTOCHAR('||l_col_val||')';
            ELSIF l_col_rec.data_type = 'NUMBER' THEN
               l_tab_col := LOWER(p_table_name||'.'||l_col_rec.column_name);
               l_out := l_out || 'TRIM(TO_CHAR(' || l_col_val || '))';
            ELSE
               assert(FALSE,'Unsupported data type ('||l_col_rec.data_type||') for column '||p_table_name||'.'||l_col_rec.column_name);
            END IF;
         END IF;
         <<next_col>>
         NULL;
      END LOOP;
      IF p_part = 'U' THEN
         l_out := l_set || l_where;
      END IF;
      RETURN l_out;
   END;
   ---
   -- Build select clause
   ---
   FUNCTION build_select_clause (
      p_table_name IN VARCHAR2
     ,p_table_alias IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_left_tab IN INTEGER := 3
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
      RETURN build_sql_statement_part('X',p_table_name,p_table_alias,'S',p_columns_list,p_left_tab,p_indent_first_line,p_columns_per_line);
   END;
   ---
   -- Build "values" clause of an insert
   ---
   FUNCTION build_values_clause (
      p_table_name IN VARCHAR2
     ,p_table_alias IN VARCHAR2
     ,p_columns_list IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
     ,p_left_tab IN INTEGER := 3
     ,p_indent_first_line IN VARCHAR2 := 'Y'
     ,p_columns_per_line IN INTEGER := 3
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN build_sql_statement_part('I',p_table_name,p_table_alias,'I',p_columns_list,p_left_tab,p_indent_first_line,p_columns_per_line,p_db_link,p_data,p_pk_size);
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
     ,p_table_alias IN VARCHAR2
     ,p_sel_columns IN VARCHAR2
     ,p_data IN VARCHAR2
     ,p_pk_size IN INTEGER
     ,p_indent IN INTEGER := 0
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN build_sql_statement_part('U',p_table_name,p_table_alias,'U',p_sel_columns,0,'N',1,NULL,p_data,p_pk_size,p_indent);
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
    , p_table_alias IN VARCHAR2 := NULL -- table alias prefix
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
      IF l_sorting_order = 'P' AND p_table_alias IS NULL AND ds_utility_var.g_ccol.EXISTS(l_constraint_name) THEN
         RETURN ds_utility_var.g_ccol(l_constraint_name);
      END IF;
      -- For each column
      FOR r_col IN c_col(NVL(ds_utility_var.g_owner,USER),l_constraint_name,l_sorting_order) LOOP
         IF l_columns_list IS NOT NULL THEN
            l_columns_list := l_columns_list||', ';
         END IF;
         l_columns_list := l_columns_list || CASE WHEN p_table_alias IS NOT NULL THEN p_table_alias||'.' END ||LOWER(r_col.column_name);
         l_count := l_count + 1;
      END LOOP;
      -- Store in cache (only when sorting on position)
      IF l_sorting_order = 'P' AND p_table_alias IS NULL THEN
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
      FOR r_col IN c_col(NVL(ds_utility_var.g_owner,USER),l_index_name) LOOP
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
         SELECT * FROM (
            SELECT constraint_name
              FROM sys.all_constraints
             WHERE owner = p_owner
               AND table_name = p_table_name
               AND constraint_type IN ('P','U')
             ORDER BY constraint_type, constraint_name
         )
          WHERE rownum <= 1
         ;
      l_constraint_name sys.all_constraints.constraint_name%TYPE;
   BEGIN
      IF ds_utility_var.g_pk.EXISTS(l_table_name) THEN
         RETURN ds_utility_var.g_pk(l_table_name);
      END IF;
      OPEN c_con(NVL(ds_utility_var.g_owner,USER),l_table_name);
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
            IF NVL(INSTR(l_inc_tab(i),'%'),0) > 0 THEN
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
   --
--#begin public
/**
* Delete identifiers
* @param p_msk_id       mask id, NULL for all
* @param p_table_name   table name, NULL for all
* @param p_column_name  column name, NULL for all
*/
   PROCEDURE delete_identifiers (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
   )
--#end public
   IS
   BEGIN
      DELETE ds_identifiers
       WHERE msk_id IN (
                SELECT msk_id
                  FROM ds_masks
                 WHERE (p_msk_id IS NULL OR msk_id = p_msk_id)
                   AND (p_table_name IS NULL OR table_name LIKE p_table_name)
                   AND (p_column_name IS NULL OR column_name LIKE p_column_name)
             )
      ;
   END;
--
--#begin public
/**
* Delete tokens generated for tokenization data masking
* @param p_table_name   name of table, NULL for all
* @param p_column_name  name of column, NULL for all
*/
   PROCEDURE delete_tokens (
      p_table_name  IN ds_utility_var.table_name := NULL
    , p_column_name IN ds_utility_var.column_name := NULL
   )
--#end public
   IS
   BEGIN
      DELETE ds_tokens
       WHERE msk_id IN (
                SELECT msk_id
                  FROM ds_masks
                 WHERE (p_table_name IS NULL OR table_name LIKE p_table_name)
                   AND (p_column_name IS NULL OR column_name LIKE p_column_name)
             )
      ;
   END;
--
--#begin public
/**
* Delete tokens generated for tokenization data masking
* @param p_msk_id   mask id, NULL for all
*/
   PROCEDURE delete_tokens (
      p_msk_id IN ds_tokens.msk_id%TYPE
   )
--#end public
   IS
   BEGIN
      DELETE ds_tokens
       WHERE (p_msk_id IS NULL OR msk_id = p_msk_id)
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
           FROM sys.user_scheduler_jobs
          WHERE job_name = REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)
      ;
$else
      -- dbms_job works as the job is not launched before the transaction is committed
      CURSOR c_job IS
         SELECT JOB
           FROM sys.user_jobs
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
          , job_action => 'BEGIN ds_utility_krn.rollforward_captured_data_set('||p_set_id||'); EXCEPTION WHEN OTHERS THEN NULL; END;'
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
          , what =>'--'||REPLACE(ds_utility_var.g_capture_job_name,':1',p_set_id)||CHR(10)||'BEGIN ds_utility_krn.rollforward_captured_data_set('||p_set_id||'); COMMIT; EXCEPTION WHEN OTHERS THEN NULL; END;'
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
           FROM sys.user_jobs
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
      DELETE ds_constraints
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      DELETE ds_tab_columns
       WHERE table_id IN (
                SELECT table_id 
                  FROM ds_tables
                 WHERE (p_set_id IS NULL OR set_id = p_set_id)
             )
      ;
      DELETE ds_tables
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      UPDATE ds_data_sets
         SET disabled_flag = NULL
           , visible_flag = NULL
           , capture_flag = NULL
           , capture_mode = NULL
           , capture_user = NULL
           , capture_seq = NULL
           , line_sep_char = NULL
           , col_sep_char = NULL
           , left_sep_char = NULL
           , right_sep_char = NULL
           , col_names_row = NULL
           , col_types_row = NULL
           , data_row = NULL
           , params = NULL
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
   END;
--
--#begin public
/**
* Create or replace a data set definition and return its id
*/
   FUNCTION create_or_replace_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := NULL
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := NULL
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
   RETURN ds_data_sets.set_id%TYPE
--#end public
   IS
      r_set ds_data_sets%ROWTYPE;
   BEGIN
      r_set.set_id := get_data_set_def_by_name(p_set_name);
      IF r_set.set_id IS NOT NULL THEN
         clear_data_set_def(r_set.set_id);
         update_data_set_def_properties(
            p_set_id=>r_set.set_id
           ,p_system_flag=>p_system_flag
           ,p_disabled_flag=>p_disabled_flag
           ,p_visible_flag=>p_visible_flag
           ,p_capture_flag=>p_capture_flag
           ,p_capture_mode=>p_capture_mode
           ,p_capture_user=>p_capture_user
           ,p_params=>p_params
         );
      ELSE
         r_set.set_id := create_data_set_def(
            p_set_name=>p_set_name
           ,p_set_type=>p_set_type
           ,p_system_flag=>p_system_flag
           ,p_disabled_flag=>p_disabled_flag
           ,p_visible_flag=>p_visible_flag
           ,p_capture_flag=>p_capture_flag
           ,p_capture_mode=>p_capture_mode
           ,p_capture_user=>p_capture_user
           ,p_params=>p_params
         );
      END IF;
      RETURN r_set.set_id;
   END;
--
--#begin public
/**
* Create or replace a data set definition
*/
   PROCEDURE create_or_replace_data_set_def (
      p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_flag IN ds_data_sets.visible_flag%TYPE := NULL
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := NULL
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := NULL
     ,p_params IN ds_data_sets.params%TYPE := NULL
   )
--#end public
   IS
      l_set_id ds_data_sets.set_id%TYPE;
   BEGIN
      l_set_id := create_or_replace_data_set_def(
            p_set_name=>p_set_name
           ,p_set_type=>p_set_type
           ,p_visible_flag=>p_visible_flag
           ,p_capture_flag=>p_capture_flag
           ,p_capture_mode=>p_capture_mode
           ,p_capture_user=>p_capture_user
           ,p_params=>p_params
      );
   END create_or_replace_data_set_def;
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
      l_sql VARCHAR2(100);
   BEGIN
      BEGIN
         l_sql := 'DROP PROCEDURE ds'||TO_CHAR(p_set_id)||' gen';
         show_message('S',RTRIM(l_sql,CHR(10)));
         EXECUTE IMMEDIATE l_sql;
         show_message('R','rowcount='||SQL%ROWCOUNT);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
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
* @param p_capture_mode trigger replication mode (NONE, SYNC, ASYN)
* @param p_capture_user limit capture to this user (NULL means all)
*/
   PROCEDURE update_data_set_def_properties (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- NULL means all data sets
     ,p_set_name IN ds_data_sets.set_name%TYPE := NULL
     ,p_system_flag IN ds_data_sets.system_flag%TYPE := '~'
     ,p_disabled_flag IN ds_data_sets.disabled_flag%TYPE := '~'
     ,p_visible_flag IN ds_data_sets.visible_flag%TYPE := '~'
     ,p_capture_flag IN ds_data_sets.capture_flag%TYPE := '~'
     ,p_capture_mode IN ds_data_sets.capture_mode%TYPE := '~'
     ,p_capture_user IN ds_data_sets.capture_user%TYPE := '~'
     ,p_params IN ds_data_sets.params%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE ds_data_sets
         SET set_name = NVL(p_set_name,set_name)
           , system_flag = CASE WHEN p_system_flag = '~' THEN system_flag ELSE p_system_flag END
           , disabled_flag = CASE WHEN p_disabled_flag = '~' THEN disabled_flag ELSE p_disabled_flag END
           , visible_flag = CASE WHEN p_visible_flag = '~' THEN visible_flag ELSE p_visible_flag END
           , capture_flag = CASE WHEN p_capture_flag = '~' OR set_type != 'CAP' THEN capture_flag ELSE p_capture_flag END
           , capture_mode = CASE WHEN p_capture_mode = '~' OR set_type != 'CAP' THEN capture_mode ELSE p_capture_mode END
           , capture_user = CASE WHEN p_capture_user = '~' OR set_type != 'CAP' THEN capture_user ELSE p_capture_user END
           , params = p_params --CASE WHEN p_params = '~' THEN params ELSE p_params END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No data set definition property updated!');
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
    , p_commit IN BOOLEAN := FALSE
   )
--#end public
   IS
      -- Cursor to browse tables of a data set
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT table_name, source_schema, source_db_link
           FROM ds_tables
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            FOR UPDATE OF source_count
         ;
      l_count INTEGER;
      l_sql VARCHAR2(4000);
   BEGIN
      -- For each table
      FOR r_tab IN c_tab(p_set_id) LOOP
         -- Count records
         l_sql := 'SELECT COUNT(*) FROM '||gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
         show_message('S',l_sql);
         EXECUTE IMMEDIATE l_sql INTO l_count;
         show_message('R','rowcount='||SQL%ROWCOUNT);
         -- Update source count
         UPDATE ds_tables
            SET source_count = l_count
          WHERE CURRENT OF c_tab;
      END LOOP;
      IF p_commit THEN
         COMMIT;
      END IF;
   END;
--#begin public
   ---
   -- Get table alias (from pk)
   ---
   FUNCTION gen_table_alias (
      p_table_name IN sys.all_tables.table_name%TYPE
     ,p_table_id IN ds_tables.table_id%TYPE := NULL
   )
   RETURN VARCHAR2
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
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
            AND NVL(INSTR(p_constraint_type,constraint_type),0)>0
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
      IF ds_utility_var.g_alias_like_pattern IS NOT NULL
      AND ds_utility_var.g_alias_replace_pattern IS NOT NULL
      AND ds_utility_var.g_alias_constraint_type IS NOT NULL THEN
         OPEN c_con(NVL(ds_utility_var.g_owner,USER),p_table_name,ds_utility_var.g_alias_like_pattern,ds_utility_var.g_alias_replace_pattern,ds_utility_var.g_alias_constraint_type);
         FETCH c_con INTO l_alias;
         CLOSE c_con;
      END IF;
      IF  l_alias IS NOT NULL
      AND l_alias NOT IN (
         -- Unfortunatly, dynamic view v$reserved_words cannot be selected from within PL/SQL
         -- To get the list below: select keyword from v$reserved_words where reserved='Y' order by 1
          'ALL','ALTER','AND','ANY','AS','ASC','BETWEEN','BY','CHAR','CHECK'
         ,'CLUSTER','COMPRESS','CONNECT','CREATE','DATE','DECIMAL','DEFAULT','DELETE','DESC','DISTINCT'
         ,'DROP','ELSE','EXCLUSIVE','EXISTS','FLOAT','FOR','FROM','GRANT','GROUP','HAVING'
         ,'IDENTIFIED','IN','INDEX','INSERT','INTEGER','INTERSECT','INTO','IS','LIKE','LOCK'
         ,'LONG','MINUS','MODE','NOCOMPRESS','NOT','NOWAIT','NULL','NUMBER','OF','ON'
         ,'OPTION','OR','ORDER','PCTFREE','PRIOR','PUBLIC','RAW','RENAME','RESOURCE','REVOKE'
         ,'SELECT','SET','SHARE','SIZE','SMALLINT','START','SYNONYM','TABLE','THEN'
         ,'TO','TRIGGER','UNION','UNIQUE','UPDATE','VALUES','VARCHAR','VARCHAR2','VIEW','WHERE'
         ,'WITH' )
      AND LENGTH(l_alias)<=ds_utility_var.g_alias_max_length
      THEN
         -- Extract alias from primary key name
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
   FUNCTION insert_table (
      r_tab IN OUT ds_tables%ROWTYPE
   )
   RETURN BOOLEAN
   IS
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_owner sys.all_tables.owner%TYPE
        ,p_table_name ds_tables.table_name%TYPE
      ) IS
         SELECT ds_tab_seq.NEXTVAL table_id, num_rows
           FROM sys.all_tables
          WHERE owner = p_owner
            AND table_name = p_table_name
            AND table_name NOT IN (
                   SELECT table_name
                     FROM ds_tables
                    WHERE set_id = p_set_id
                )
         ;
      l_found BOOLEAN;
   BEGIN
      -- Validate
      assert(r_tab.percentage IS NULL OR r_tab.extract_type = 'B','Percentage only allowed for Base table');
      assert(r_tab.row_limit IS NULL OR r_tab.extract_type = 'B','Row limit only allowed for Base table');
      -- Generate table id
      OPEN c_tab(r_tab.set_id,NVL(ds_utility_var.g_owner,USER),r_tab.table_name);
      FETCH c_tab INTO r_tab.table_id, r_tab.source_count;
      l_found := c_tab%FOUND;
      CLOSE c_tab;
      IF NOT l_found THEN
         RETURN l_found;
      END IF;
      IF r_tab.table_alias IS NULL THEN
         -- Get table alias from pk name (if exists)
         r_tab.table_alias := gen_table_alias(r_tab.table_name,r_tab.table_id);
      END IF;
      IF r_tab.pass_count IS NULL THEN
         r_tab.pass_count := 0;
      END IF;
      -- Set source schema if not current
      IF NVL(ds_utility_var.g_owner,USER) != USER THEN
         r_tab.source_schema := ds_utility_var.g_owner;
      END IF;
      INSERT INTO ds_tables VALUES r_tab;
      RETURN l_found;
   END;
--#begin public
   ---
   -- Insert a new table
   ---
   PROCEDURE insert_table (
      r_tab IN OUT ds_tables%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
      l_bool BOOLEAN;
   BEGIN
      l_bool := insert_table(r_tab);
   END;
--#begin public
   ---
   -- Create a new constraint
   ---
   PROCEDURE insert_constraint (
      r_con IN OUT ds_constraints%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
   BEGIN
      -- Validate
--      assert(r_con.where_clause IS NULL OR r_con.CARDINALITY='1-N','Filter only allowed for 1-N relationships');
      assert(r_con.percentage IS NULL OR r_con.CARDINALITY='1-N','Percentage only allowed for 1-N relationships');
      assert(r_con.row_limit IS NULL OR r_con.CARDINALITY='1-N','Row limit only allowed for 1-N relationships');
      -- Get next sequence available
      r_con.con_id := gen_con_id;
      -- Insert constraint
      r_con.extract_count := 0;
      INSERT INTO ds_constraints VALUES r_con;
   END;
--#begin public
   ---
   -- Get a table record based on its name
   ---
   PROCEDURE get_table (
      p_set_id IN ds_data_sets.set_id%TYPE
     ,p_table_name IN ds_tables.table_name%TYPE
     ,r_tab OUT ds_tables%ROWTYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
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
--#begin public
   ---
   -- Get alias
   ---
   PROCEDURE get_aliases (
      r_tab_mst IN ds_tables%ROWTYPE
     ,r_tab_det IN ds_tables%ROWTYPE
     ,p_out_master_alias OUT ds_tables.table_alias%TYPE
     ,p_out_detail_alias OUT ds_tables.table_alias%TYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
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
--#begin public
   ---
   -- Build join clause given fk
   ---
   FUNCTION build_join_clause (
      p_master_table_name IN VARCHAR2
     ,p_detail_table_name IN VARCHAR2
     ,p_fk_name IN sys.all_constraints.constraint_name%TYPE
   )
   RETURN VARCHAR2
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
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
      FOR r_col IN c_col(NVL(ds_utility_var.g_owner,USER),p_fk_name)
      LOOP
         IF l_join IS NOT NULL THEN
            l_join := l_join || ' AND ';
         END IF;
         l_join := l_join || p_master_table_name || '.' || r_col.p_col_name || ' = '
                          || p_detail_table_name || '.' || r_col.c_col_name;
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
      FOR r_tab IN c_tab(p_set_id,NVL(ds_utility_var.g_owner,USER)) LOOP
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
            FOR r_fk IN c_fk(NVL(ds_utility_var.g_owner,USER),r_tab_mst.table_name,p_det_table_name) LOOP
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
*/
   PROCEDURE update_table_properties (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_table_name IN ds_tables.table_name%TYPE := NULL
     ,p_extract_type IN ds_tables.extract_type%TYPE := '~'
     ,p_where_clause IN ds_tables.where_clause%TYPE := '~'
     ,p_percentage IN ds_tables.percentage%TYPE := -1
     ,p_row_limit IN ds_tables.row_limit%TYPE := -1
     ,p_row_count IN ds_tables.row_count%TYPE := -1
     ,p_order_by_clause IN ds_tables.order_by_clause%TYPE := '~'
     ,p_columns_list IN ds_tables.columns_list%TYPE := '~'
     ,p_export_mode IN ds_tables.export_mode%TYPE := '~'
     ,p_source_schema IN ds_tables.source_schema%TYPE := '~'
     ,p_source_db_link IN ds_tables.source_db_link%TYPE := '~'
     ,p_target_schema IN ds_tables.target_schema%TYPE := '~'
     ,p_target_db_link IN ds_tables.target_db_link%TYPE := '~'
     ,p_target_table_name IN ds_tables.target_table_name%TYPE := '~'
     ,p_user_column_name IN ds_tables.user_column_name%TYPE := '~'
     ,p_batch_size IN ds_tables.batch_size%TYPE := -1
     ,p_tab_seq IN ds_tables.tab_seq%TYPE := -1
     ,p_gen_view_name IN ds_tables.gen_view_name%TYPE := '~'
     ,p_pre_gen_code IN ds_tables.pre_gen_code%TYPE := '~'
     ,p_post_gen_code IN ds_tables.post_gen_code%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE ds_tables
         SET extract_type = CASE WHEN p_extract_type = '~' THEN extract_type ELSE p_extract_type END
           , where_clause = CASE WHEN p_where_clause = '~' THEN where_clause ELSE p_where_clause END
           , percentage = CASE WHEN p_percentage < 0 THEN percentage ELSE p_percentage END
           , row_limit = CASE WHEN p_row_limit < 0 THEN row_limit ELSE p_row_limit END
           , row_count = CASE WHEN p_row_count < 0 THEN row_count ELSE p_row_count END
           , order_by_clause = CASE WHEN p_order_by_clause = '~' THEN order_by_clause ELSE p_order_by_clause END
           , columns_list = CASE WHEN p_columns_list = '~' THEN columns_list ELSE p_columns_list END
           , export_mode = CASE WHEN p_export_mode = '~' THEN export_mode ELSE p_export_mode END
           , source_schema = CASE WHEN p_source_schema = '~' THEN source_schema ELSE p_source_schema END
           , source_db_link = CASE WHEN p_source_db_link = '~' THEN source_db_link ELSE p_source_db_link END
           , target_schema = CASE WHEN p_target_schema = '~' THEN target_schema ELSE p_target_schema END
           , target_db_link = CASE WHEN p_target_db_link = '~' THEN target_db_link ELSE p_target_db_link END
           , target_table_name = CASE WHEN p_target_table_name = '~' THEN target_table_name ELSE p_target_table_name END
           , user_column_name = CASE WHEN p_user_column_name = '~' THEN user_column_name ELSE p_user_column_name END
           , batch_size = CASE WHEN p_batch_size < 0 THEN batch_size ELSE p_batch_size END
           , tab_seq = CASE WHEN p_tab_seq < 0 THEN tab_seq ELSE p_tab_seq END
           , gen_view_name = CASE WHEN p_gen_view_name = '~' THEN gen_view_name ELSE p_gen_view_name END
           , pre_gen_code = CASE WHEN p_pre_gen_code = '~' THEN pre_gen_code ELSE p_pre_gen_code END
           , post_gen_code = CASE WHEN p_post_gen_code = '~' THEN post_gen_code ELSE p_post_gen_code END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND (p_table_name IS NULL OR table_name LIKE p_table_name ESCAPE '~')
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No table property updated!');
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
     ,p_min_rows IN ds_constraints.min_rows%TYPE := -1
     ,p_max_rows IN ds_constraints.max_rows%TYPE := -1
     ,p_level_count IN ds_constraints.level_count%TYPE := -1
     ,p_order_by_clause IN ds_constraints.order_by_clause%TYPE := '~'
     ,p_deferred IN ds_constraints.deferred%TYPE := '~'
     ,p_batch_size IN ds_constraints.batch_size%TYPE := -1
     ,p_con_seq IN ds_constraints.con_seq%TYPE := -1
     ,p_gen_view_name IN ds_constraints.gen_view_name%TYPE := '~'
     ,p_pre_gen_code IN ds_constraints.pre_gen_code%TYPE := '~'
     ,p_post_gen_code IN ds_constraints.post_gen_code%TYPE := '~'
     ,p_src_filter IN ds_constraints.src_filter%TYPE := '~'
     ,p_raise_error_when_no_update BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE ds_constraints
         SET where_clause = CASE WHEN p_where_clause = '~' THEN where_clause ELSE p_where_clause END
           , percentage = CASE WHEN p_percentage = -1 THEN percentage ELSE p_percentage END
           , row_limit = CASE WHEN p_row_limit = -1 THEN row_limit ELSE p_row_limit END
           , min_rows = CASE WHEN p_min_rows = -1 THEN min_rows ELSE p_min_rows END
           , max_rows = CASE WHEN p_max_rows = -1 THEN max_rows ELSE p_max_rows END
           , level_count = CASE WHEN p_level_count = -1 THEN level_count ELSE p_level_count END
           , extract_type = CASE WHEN p_extract_type = '~' THEN extract_type ELSE p_extract_type END
           , order_by_clause = CASE WHEN p_order_by_clause = '~' THEN order_by_clause ELSE p_order_by_clause END
           , deferred = CASE WHEN p_deferred = '~' THEN deferred ELSE p_deferred END
           , batch_size = CASE WHEN p_batch_size = -1 THEN batch_size ELSE p_batch_size END
           , con_seq = CASE WHEN p_con_seq = -1 THEN con_seq ELSE p_con_seq END
           , gen_view_name = CASE WHEN p_gen_view_name = '~' THEN gen_view_name ELSE p_gen_view_name END
           , pre_gen_code = CASE WHEN p_pre_gen_code = '~' THEN pre_gen_code ELSE p_pre_gen_code END
           , post_gen_code = CASE WHEN p_post_gen_code = '~' THEN post_gen_code ELSE p_post_gen_code END
           , src_filter = CASE WHEN p_src_filter = '~' THEN src_filter ELSE p_src_filter END
       WHERE (p_set_id IS NULL OR set_id = p_set_id)
         AND (p_constraint_name IS NULL OR constraint_name LIKE p_constraint_name ESCAPE '~')
         AND (p_cardinality IS NULL OR cardinality = p_cardinality)
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No constraint property updated!');
   END;
--#begin public
/**
* Insert columns for a given table
* @param p_set_id data set id
* @param p_table_name table name
* @param p_gen_type default generation type
* @param p_null_value_pct percentage of NULL value
* @param p_null_value_pct condition to force NULL value
*/
   PROCEDURE insert_table_columns (
      p_set_id IN ds_tables.set_id%TYPE
    , p_table_name IN ds_tables.table_name%TYPE := NULL
    , p_gen_type IN ds_tab_columns.gen_type%TYPE := NULL
    , p_null_value_pct IN ds_tab_columns.null_value_pct%TYPE := NULL
    , p_null_value_condition IN ds_tab_columns.null_value_condition%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      INSERT INTO ds_tab_columns (
         table_id, tab_name, col_name, col_seq
       , gen_type, params, null_value_pct
       , null_value_condition
      )
      SELECT tab.table_id table_id, tab.table_name tab_name, tcol.column_name col_name, tcol.column_id col_seq
           , CASE WHEN ccol.constraint_name IS NOT NULL THEN 'FK' ELSE NVL(msk.msk_type,p_gen_type) END gen_type
--           , CASE WHEN ccol.constraint_name IS NOT NULL THEN ccol.constraint_name||'.'||ccol.r_table_name||'.'||ccol.r_column_name ELSE msk.params END params
           , CASE WHEN ccol.constraint_name IS NOT NULL THEN ccol.constraint_name ELSE msk.params END params
           , CASE WHEN tcol.nullable = 'N' THEN 0 ELSE p_null_value_pct END null_value_pct
           , CASE WHEN tcol.nullable = 'N' THEN NULL ELSE p_null_value_condition END null_value_condition
        FROM ds_tables tab
       INNER JOIN ds_data_sets ds
          ON ds.set_id = tab.set_id
         AND ds.set_type = 'GEN'
       INNER JOIN sys.all_tab_columns tcol
          ON tcol.owner = NVL(ds_utility_var.g_owner,USER)
         AND tcol.table_name = tab.table_name
        LEFT OUTER JOIN ds_tab_columns dcol
          ON dcol.table_id = tab.table_id
         AND dcol.col_name = tcol.column_name
        LEFT OUTER JOIN (
             SELECT col.owner, col.table_name, col.column_name, col.constraint_name
                  , rcol.table_name r_table_name, rcol.column_name r_column_name
               FROM sys.all_constraints con
--              INNER JOIN ds_constraints ds_con
--                 ON ds_con.set_id = p_set_id
--                AND ds_con.constraint_name = con.constraint_name
--                AND ds_con.cardinality = 'N-1'
--                AND ds_con.extract_type IN ('B','P')
              INNER JOIN sys.all_cons_columns col
                 ON col.owner = con.owner
                AND col.constraint_name = con.constraint_name
              INNER JOIN sys.all_constraints rcon
                 ON rcon.owner = con.owner
                AND rcon.constraint_name = con.r_constraint_name
              INNER JOIN sys.all_cons_columns rcol
                 ON rcol.owner = rcon.owner
                AND rcol.constraint_name = rcon.constraint_name
                AND rcol.position = col.position
              WHERE con.owner = NVL(ds_utility_var.g_owner,USER)
                AND (p_table_name IS NULL OR con.table_name LIKE p_table_name ESCAPE '~')
                AND con.constraint_type = 'R'
           ) ccol
          ON ccol.owner = tcol.owner
         AND ccol.table_name = tcol.table_name
         AND ccol.column_name = tcol.column_name
        LEFT OUTER JOIN ds_masks msk
          ON msk.table_name = tab.table_name
         AND msk.column_name = tcol.column_name
         AND msk.msk_type = 'SQL'
         AND (INSTR(msk.params,'random')>0 OR INSTR(msk.params,':')>0)
       WHERE tab.set_id = p_set_id
         AND tab.extract_type IN ('B','P','F')
         AND (p_table_name IS NULL OR tab.table_name LIKE p_table_name ESCAPE '~')
         AND dcol.col_name IS NULL -- not already inserted
      ;
   END;
--#begin public
/**
* Update table column properties
*/
   PROCEDURE update_table_column_properties (
      p_set_id IN ds_tables.set_id%TYPE
    , p_table_name IN ds_tables.table_name%TYPE
    , p_col_name IN ds_tab_columns.col_name%TYPE := '~'
    , p_col_seq IN ds_tab_columns.col_seq%TYPE := -1
    , p_gen_type IN ds_tab_columns.gen_type%TYPE := '~'
    , p_params IN ds_tab_columns.params%TYPE := '~'
    , p_null_value_pct IN ds_tab_columns.null_value_pct%TYPE := -1
    , p_null_value_condition IN ds_tab_columns.null_value_condition%TYPE := '~'
    , p_raise_error_when_no_update BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE ds_tab_columns
         SET col_seq = CASE WHEN p_col_seq = -1 THEN col_seq ELSE p_col_seq END
           , gen_type = CASE WHEN p_gen_type = '~' THEN gen_type ELSE p_gen_type END
           , params = CASE WHEN p_params = '~' THEN params ELSE p_params END
           , null_value_pct = CASE WHEN p_null_value_pct = -1 THEN null_value_pct ELSE p_null_value_pct END
           , null_value_condition = CASE WHEN p_null_value_condition = '~' THEN null_value_condition ELSE p_null_value_condition END
       WHERE table_id IN (
                SELECT tab.table_id
                  FROM ds_tables tab
                 INNER JOIN ds_data_sets ds
                    ON ds.set_id = tab.set_id
                   AND ds.set_type = 'GEN'
                 WHERE tab.set_id = p_set_id
                   AND tab.extract_type IN ('B','P','F')
                   AND tab.table_name LIKE p_table_name ESCAPE '~'
             )
         AND (p_col_name IS NULL OR col_name LIKE p_col_name ESCAPE '~')
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No column property updated for table "'||p_table_name||'"!');
   END;
--#begin public
/**
* Clone table column properties from one data set to another
*/
   PROCEDURE clone_table_column_properties (
      p_set_id_src ds_data_sets.set_id%TYPE
    , p_set_id_tgt ds_data_sets.set_id%TYPE
    , p_table_name ds_tables.table_name%TYPE := NULL
    , p_col_name ds_tab_columns.col_name%TYPE := NULL
   )
--#end public
   IS
      CURSOR c_tab IS
         SELECT tab_src.table_id table_id_src, tab_tgt.table_id table_id_tgt
           FROM ds_tables tab_src
          INNER JOIN ds_data_sets ds_src
             ON ds_src.set_id = tab_src.set_id
            AND ds_src.set_type = 'GEN'
          INNER JOIN ds_tables tab_tgt
             ON tab_tgt.set_id = p_set_id_tgt
            AND tab_tgt.extract_type IN ('B','P','F')
            AND tab_tgt.table_name = tab_src.table_name
          INNER JOIN ds_data_sets ds_tgt
             ON ds_tgt.set_id = tab_tgt.set_id
            AND ds_tgt.set_type = 'GEN'
          WHERE tab_src.set_id = p_set_id_src
            AND tab_src.extract_type IN ('B','P','F')
            AND (p_table_name IS NULL OR tab_src.table_name LIKE p_table_name ESCAPE '~')
      ;
   BEGIN
      FOR r_tab IN c_tab LOOP
         UPDATE ds_tab_columns col_tgt
            SET (col_seq, gen_type, params, null_value_pct, null_value_condition) = (
                   SELECT col_seq, gen_type, params, null_value_pct, null_value_condition
                     FROM ds_tab_columns col_src
                    WHERE table_id = r_tab.table_id_src
                      AND col_src.col_name = col_tgt.col_name
                )
          WHERE table_id = r_tab.table_id_tgt
            AND (p_col_name IS NULL OR col_name LIKE p_col_name ESCAPE '~')
         ;
      END LOOP;
   END;
--#begin public
   PROCEDURE optimize_referential_cons (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   ACCESSIBLE BY (PACKAGE ds_utility_ext)
--#end public
   IS
      l_row_count PLS_INTEGER;
   BEGIN
      -- Optimization 1:
      -- When a table is the destination of a single constraint
      -- don't include N-1 P-fk if 1-N B-fk exists already
      -- Do not used this optimisation for tables with pig's ears
      -- (1-N is used to find childs and N-1 to find parents)
      UPDATE ds_constraints
         SET extract_type = 'N'
       WHERE set_id = p_set_id
         AND cardinality = 'N-1'
         AND extract_type = 'P'
         AND src_table_name != dst_table_name
         AND src_table_name IN (
                   -- Tables fed from only 1 source
               SELECT ds_con.dst_table_name
                 FROM ds_constraints ds_con
                INNER JOIN ds_data_sets ds_set
                   ON ds_set.set_id = ds_con.set_id
                  AND ds_set.set_type = 'SUB'
                WHERE ds_con.set_id = p_set_id
                  AND ds_con.extract_type IN ('B','P')
                GROUP BY ds_con.dst_table_name
               HAVING COUNT(*) = 1
             )
         AND constraint_name IN (
                    -- Constraints walked-through in both directions
                    -- Once dir for B-records, one dir for P-records.
                SELECT p.constraint_name
                  FROM ds_constraints p
                 INNER JOIN ds_data_sets s
                    ON s.set_id = p.set_id
                   AND s.set_type = 'SUB'
                 INNER JOIN ds_constraints b
                    ON b.set_id = p.set_id
                   AND b.constraint_name = p.constraint_name
                   AND b.cardinality = '1-N'
                   AND b.extract_type = 'B'
                 WHERE p.set_id = p_set_id
                   AND p.cardinality = 'N-1'
                   AND p.extract_type = 'P'
                   AND p.src_table_name != p.dst_table_name
             );
      l_row_count := SQL%ROWCOUNT;
      IF l_row_count > 0 THEN
         show_message('D',l_row_count||' N-1 constraints excluded for optimization 1');
      END IF;
      -- Optimization 2
      UPDATE ds_constraints
         SET extract_type = 'N'
       WHERE set_id = p_set_id
         AND (constraint_name, cardinality) IN (
                   -- N-1 constraint to a F|N-table
               SELECT ds_con.constraint_name, ds_con.cardinality
                 FROM ds_constraints ds_con
                INNER JOIN ds_data_sets ds_set
                   ON ds_set.set_id = ds_con.set_id
                  AND ds_set.set_type IN ('SUB','GEN')
                INNER JOIN ds_tables ds_tab
                   ON ds_tab.set_id = ds_con.set_id
                  AND ds_tab.table_name = ds_con.dst_table_name
                  AND ds_tab.extract_type IN ('F','N')
                WHERE ds_con.set_id = p_set_id
                  AND ds_con.extract_type IN ('B','P')
                  AND (ds_set.set_type = 'SUB' OR ds_con.cardinality='1-N')
             )
         ;
      l_row_count := SQL%ROWCOUNT;
      IF l_row_count > 0 THEN
         show_message('D',l_row_count||' N-1 constraints excluded for optimization 2');
      END IF;
      -- Case 3 (not really an optimisation)
      UPDATE ds_constraints
         SET extract_type = 'B'
       WHERE set_id = p_set_id
         AND set_id IN (
                SELECT set_id
                  FROM ds_data_sets
                 WHERE set_id = p_set_id
                   AND set_type = 'GEN'
             )
         AND extract_type = 'P'
         AND cardinality = '1-N'
         AND (NVL(min_rows,0)>0 OR NVL(max_rows,0)>0 OR gen_view_name IS NOT NULL)
      ;
      l_row_count := SQL%ROWCOUNT;
      IF l_row_count > 0 THEN
         show_message('D',l_row_count||' 1-N constraints updated with extract type "B"');
      END IF;
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
     ,p_extract_type IN ds_tables.extract_type%TYPE := NULL
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
            FOR r_fk IN c_fk(NVL(ds_utility_var.g_owner,USER),r_tab.table_name,p_constraint_name) LOOP
               show_message('D','   FK: '||r_fk.constraint_name);
               -- Check if table already exists
               get_table(p_set_id,r_fk.detail_table_name,r_tab_det);
               IF r_tab_det.table_name IS NULL THEN
                  r_tab_det := NULL;
                  r_tab_det.set_id := p_set_id;
                  r_tab_det.table_name := r_fk.detail_table_name;
                  r_tab_det.extract_type := CASE WHEN p_extract_type = 'R' THEN 'R' ELSE 'P' END; --NVL(p_extract_type,'P');
                  show_message('D','   Addying dst table: '||r_tab_det.table_name);
                  insert_table(r_tab_det);
               END IF;
               get_table(p_set_id,r_fk.master_table_name,r_tab_mst);
               IF r_tab_mst.table_name IS NULL THEN
                  r_tab_mst := NULL;
                  r_tab_mst.set_id := p_set_id;
                  r_tab_mst.table_name := r_fk.master_table_name;
                  r_tab_mst.extract_type := CASE WHEN p_extract_type = 'R' THEN 'R' ELSE 'P' END; --NVL(p_extract_type,'P');
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
                  r_con_new.extract_type := REPLACE(CASE WHEN r_tab_mst.extract_type IN ('N','F') THEN 'N' ELSE NVL(p_extract_type,'P') END, 'R', 'P'); --'P';
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
      optimize_referential_cons(p_set_id=>p_set_id);
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
      FOR r_fk IN c_fk(NVL(ds_utility_var.g_owner,USER),p_master_table_name,p_detail_table_name,p_constraint_name) LOOP
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
--#begin public
   ---
   -- Insert a pattern
   ---
   PROCEDURE insert_pattern (
      p_pat_name ds_patterns.pat_name%TYPE
    , p_pat_cat ds_patterns.pat_cat%TYPE := NULL
    , p_pat_seq ds_patterns.pat_seq%TYPE := NULL
    , p_col_name_pattern ds_patterns.col_name_pattern%TYPE := NULL
    , p_col_comm_pattern ds_patterns.col_comm_pattern%TYPE := NULL
    , p_col_data_pattern ds_patterns.col_data_pattern%TYPE := NULL
    , p_col_data_set_name ds_patterns.col_data_set_name%TYPE := NULL
    , p_col_data_type ds_patterns.col_data_type%TYPE := NULL
    , p_col_data_min_pct ds_patterns.col_data_min_pct%TYPE := NULL
    , p_col_data_min_cnt ds_patterns.col_data_min_cnt%TYPE := NULL
    , p_logical_operator ds_patterns.logical_operator%TYPE := NULL
    , p_system_flag ds_patterns.system_flag%TYPE := NULL
    , p_disabled_flag ds_patterns.disabled_flag%TYPE := NULL
    , p_msk_type ds_patterns.msk_type%TYPE := NULL
    , p_msk_params ds_patterns.msk_params%TYPE := NULL
    , p_remarks ds_patterns.remarks%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      INSERT INTO ds_patterns (
           pat_id, pat_cat, pat_name
         , pat_seq, col_name_pattern, col_comm_pattern
         , col_data_pattern, col_data_set_name, col_data_type
         , col_data_min_pct, col_data_min_cnt, logical_operator
         , system_flag, disabled_flag, msk_type
         , msk_params, remarks
      )
      SELECT ds_pat_seq.nextval, p_pat_cat, p_pat_name
           , p_pat_seq, p_col_name_pattern, p_col_comm_pattern
           , p_col_data_pattern, p_col_data_set_name, p_col_data_type
           , p_col_data_min_pct, p_col_data_min_cnt, p_logical_operator
           , p_system_flag, p_disabled_flag, p_msk_type
           , p_msk_params, p_remarks
        FROM sys.dual
        LEFT OUTER JOIN ds_patterns pat
          ON pat.pat_name = p_pat_name
       WHERE pat.pat_name IS NULL -- not already inserted
      ;
   END;
--#begin public
   ---
   -- Update pattern(s) properties
   ---
   PROCEDURE update_pattern_properties (
        p_pat_name ds_patterns.pat_name%TYPE := NULL
      , p_pat_cat ds_patterns.pat_cat%TYPE := '~'
      , p_pat_seq ds_patterns.pat_seq%TYPE := -1
      , p_col_name_pattern ds_patterns.col_name_pattern%TYPE := '~'
      , p_col_comm_pattern ds_patterns.col_comm_pattern%TYPE := '~'
      , p_col_data_pattern ds_patterns.col_data_pattern%TYPE := '~'
      , p_col_data_set_name ds_patterns.col_data_set_name%TYPE := '~'
      , p_col_data_type ds_patterns.col_data_type%TYPE := '~'
      , p_col_data_min_pct ds_patterns.col_data_min_pct%TYPE := -1
      , p_col_data_min_cnt ds_patterns.col_data_min_cnt%TYPE := -1
      , p_logical_operator ds_patterns.logical_operator%TYPE := '~'
      , p_system_flag ds_patterns.system_flag%TYPE := '~'
      , p_disabled_flag ds_patterns.disabled_flag%TYPE := '~'
      , p_msk_type ds_patterns.msk_type%TYPE := '~'
      , p_msk_params ds_patterns.msk_params%TYPE := '~'
      , p_remarks ds_patterns.remarks%TYPE := '~'
      , p_raise_error_when_no_update BOOLEAN := TRUE
)
--#end public
   IS
   BEGIN
      UPDATE ds_patterns
         SET pat_cat = CASE WHEN p_pat_cat = '~' THEN pat_cat ELSE p_pat_cat END
           , pat_seq = CASE WHEN p_pat_seq < 0  THEN pat_seq ELSE p_pat_seq END
           , col_name_pattern = CASE WHEN p_col_name_pattern = '~' THEN col_name_pattern ELSE p_col_name_pattern END
           , col_comm_pattern = CASE WHEN p_col_comm_pattern = '~' THEN col_comm_pattern ELSE p_col_comm_pattern END
           , col_data_pattern = CASE WHEN p_col_data_pattern = '~' THEN col_data_pattern ELSE p_col_data_pattern END
           , col_data_set_name = CASE WHEN p_col_data_set_name = '~' THEN col_data_set_name ELSE p_col_data_set_name END
           , col_data_type = CASE WHEN p_col_data_type = '~' THEN col_data_type ELSE p_col_data_type END
           , col_data_min_pct = CASE WHEN p_col_data_min_pct < 0  THEN col_data_min_pct ELSE p_col_data_min_pct END
           , col_data_min_cnt = CASE WHEN p_col_data_min_cnt < 0  THEN col_data_min_cnt ELSE p_col_data_min_cnt END
           , logical_operator = CASE WHEN p_logical_operator = '~' THEN logical_operator ELSE p_logical_operator END
           , system_flag = CASE WHEN p_system_flag = '~' THEN system_flag ELSE p_system_flag END
           , disabled_flag = CASE WHEN p_disabled_flag = '~' THEN disabled_flag ELSE p_disabled_flag END
           , msk_type = CASE WHEN p_msk_type = '~' THEN msk_type ELSE p_msk_type END
           , msk_params = CASE WHEN p_msk_params = '~' THEN msk_params ELSE p_msk_params END
           , remarks = CASE WHEN p_remarks = '~' THEN remarks ELSE p_remarks END
       WHERE (p_pat_name IS NULL OR pat_name LIKE p_pat_name)
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No pattern property updated!');
   END;
--#begin public
   ---
   -- Delete pattern(s)
   ---
   PROCEDURE delete_pattern (
        p_pat_name ds_patterns.pat_name%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      DELETE ds_patterns
       WHERE (p_pat_name IS NULL OR pat_name LIKE p_pat_name)
      ;
   END;
--#begin public
   ---
   -- Insert mask(s) for each matching table and column (Oracle wildcard allowed)
   ---
   PROCEDURE insert_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := NULL -- means all
    , p_sensitive_flag ds_masks.sensitive_flag%TYPE := NULL
    , p_disabled_flag ds_masks.disabled_flag%TYPE := NULL
    , p_locked_flag ds_masks.locked_flag%TYPE := NULL
    , p_deleted_flag ds_masks.deleted_flag%TYPE := NULL
    , p_msk_type ds_masks.msk_type%TYPE := NULL
    , p_shuffle_group ds_masks.shuffle_group%TYPE := NULL
    , p_partition_bitmap ds_masks.partition_bitmap%TYPE := NULL
    , p_params ds_masks.params%TYPE := NULL
    , p_options ds_masks.options%TYPE := NULL
    , p_pat_cat ds_masks.pat_cat%TYPE := NULL
    , p_pat_name ds_masks.pat_name%TYPE := NULL
    , p_remarks ds_masks.remarks%TYPE := NULL
    , p_values_sample ds_masks.values_sample%TYPE := NULL
    , p_raise_error_when_no_insert BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      INSERT INTO ds_masks (
         msk_id, table_name, column_name
       , sensitive_flag, disabled_flag, locked_flag
       , deleted_flag
       , msk_type, shuffle_group, partition_bitmap
       , pat_cat, pat_name, params
       , options, remarks, values_sample
      )
      SELECT ds_msk_seq.nextval, col.table_name, col.column_name
           , p_sensitive_flag, p_disabled_flag, p_locked_flag
           , p_deleted_flag
           , p_msk_type, p_shuffle_group, p_partition_bitmap
           , p_pat_cat, p_pat_name, p_params
           , p_options, p_remarks, p_values_sample
        FROM sys.all_tab_columns col
        LEFT OUTER JOIN ds_masks msk
          ON msk.table_name = col.table_name
         AND msk.column_name = col.column_name
       WHERE col.owner = NVL(ds_utility_var.g_owner,USER)
         AND (p_table_name IS NULL OR col.table_name LIKE p_table_name)
         AND (p_column_name IS NULL OR col.column_name LIKE p_column_name)
         AND col.column_name = UPPER(col.column_name) -- avoid non-uppercase columns
         AND msk.table_name IS NULL -- not already inserted
      ;
      assert(NOT p_raise_error_when_no_insert OR SQL%ROWCOUNT>0,'No mask inserted!');
   END;
--#begin public
   ---
   -- Update mask(s) properties for matching tables and columns (Oracle wildcards allowed)
   ---
   PROCEDURE update_mask_properties (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := '~'
    , p_sensitive_flag ds_masks.sensitive_flag%TYPE := '~'
    , p_disabled_flag ds_masks.disabled_flag%TYPE := '~'
    , p_locked_flag ds_masks.locked_flag%TYPE := '~'
    , p_deleted_flag ds_masks.locked_flag%TYPE := '~'
    , p_msk_type ds_masks.msk_type%TYPE := '~'
    , p_shuffle_group ds_masks.shuffle_group%TYPE := -1
    , p_partition_bitmap ds_masks.partition_bitmap%TYPE := -1
    , p_pat_cat ds_masks.pat_cat%TYPE := '~'
    , p_pat_name ds_masks.pat_name%TYPE := '~'
    , p_params ds_masks.params%TYPE := '~'
    , p_options ds_masks.params%TYPE := '~'
    , p_remarks ds_masks.remarks%TYPE := '~'
    , p_raise_error_when_no_update BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE ds_masks
         SET sensitive_flag = CASE WHEN p_sensitive_flag = '~' THEN sensitive_flag ELSE p_sensitive_flag END
           , disabled_flag = CASE WHEN p_disabled_flag = '~' THEN disabled_flag ELSE p_disabled_flag END
           , locked_flag = CASE WHEN p_locked_flag = '~' THEN locked_flag ELSE p_locked_flag END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
           , msk_type = CASE WHEN p_msk_type = '~' THEN msk_type ELSE p_msk_type END
           , shuffle_group = CASE WHEN p_shuffle_group <= 0 THEN shuffle_group ELSE p_shuffle_group END
           , partition_bitmap = CASE WHEN p_partition_bitmap <= 0 THEN partition_bitmap ELSE p_partition_bitmap END
           , pat_name = CASE WHEN p_pat_name = '~' THEN pat_name ELSE p_pat_name END
           , pat_cat = CASE WHEN p_pat_cat = '~' THEN pat_cat ELSE p_pat_cat END
           , params = CASE WHEN p_params = '~' THEN params ELSE p_params END
           , options = CASE WHEN p_options = '~' THEN options ELSE p_options END
           , remarks = CASE WHEN p_remarks = '~' THEN remarks ELSE p_remarks END
       WHERE (p_table_name IS NULL OR table_name = p_table_name)
         AND (p_column_name IS NULL OR column_name = p_column_name)
      ;
      assert(NOT p_raise_error_when_no_update OR SQL%ROWCOUNT>0,'No mask property updated!');
   END;
--#begin public
   ---
   -- Reset mask(s) properties to their default NULL value
   ---
   PROCEDURE reset_mask (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE ds_masks
         SET sensitive_flag = NULL
           , disabled_flag = NULL
           , locked_flag = NULL
           , deleted_flag = NULL
           , msk_type = NULL
           , shuffle_group = NULL
           , partition_bitmap = NULL
           , pat_name = NULL
           , pat_cat = NULL
           , params = NULL
           , remarks = NULL
       WHERE (p_table_name IS NULL OR table_name = p_table_name)
         AND (p_column_name IS NULL OR column_name = p_column_name)
      ;
      assert(SQL%ROWCOUNT>0,'No mask property updated!');
   END;
--#begin public
   ---
   -- Delete mask(s) for matching tables and columns (Oracle wildcards allowed)
   ---
   PROCEDURE delete_mask (
      p_table_name ds_masks.table_name%TYPE := NULL -- means all
    , p_column_name ds_masks.column_name%TYPE := NULL -- means all
   )
--#end public
   IS
   BEGIN
      delete_tokens(p_table_name, p_column_name);
      DELETE ds_masks
       WHERE (p_table_name IS NULL OR table_name LIKE p_table_name)
         AND (p_column_name IS NULL OR column_name LIKE p_column_name)
      ;
   END;
--#begin public
   ---
   -- Delete mask with given id (NULL for all)
   ---
   PROCEDURE delete_mask (
      p_msk_id ds_masks.msk_id%TYPE
   )
--#end public
   IS
   BEGIN
      delete_tokens(p_msk_id);
      DELETE ds_masks
       WHERE (p_msk_id IS NULL OR msk_id = p_msk_id)
      ;
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
         assert(p_source_count IS NOT NULL,'source count IS NULL');
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
   -- Get FK columns linked to propagated PK masks
   --
   PROCEDURE get_pk_fk_columns (
      p_table_name IN VARCHAR2
    , p_pk_cols IN OUT VARCHAR2
    , p_fk_cols IN OUT VARCHAR2
   )
   IS
      l_tab_col ds_utility_var.full_column_name;
      r_fk ds_utility_var.fk_record_type;
   BEGIN
      p_pk_cols := NULL;
      p_fk_cols := NULL;
      l_tab_col := ds_utility_var.g_fk_tab.FIRST;
      WHILE l_tab_col IS NOT NULL LOOP
         r_fk := ds_utility_var.g_fk_tab(l_tab_col);
         IF r_fk.fk_tab_name = p_table_name THEN
            p_pk_cols := CASE WHEN p_pk_cols IS NOT NULL THEN p_pk_cols || ', ' END|| r_fk.pk_col_name;
            p_fk_cols := CASE WHEN p_fk_cols IS NOT NULL THEN p_fk_cols || ', ' END|| r_fk.fk_col_name;
         END IF;
         l_tab_col := ds_utility_var.g_fk_tab.NEXT(l_tab_col);
      END LOOP;
   END;
   ---
   -- Get shuffled columns
   ---
   PROCEDURE get_shuffled_columns (
      p_table_name IN ds_tables.table_name%TYPE
     ,p_table_alias IN ds_tables.table_alias%TYPE
     ,p_shuffle_group IN ds_masks.shuffle_group%TYPE
     ,p_shuffled_cols IN OUT ds_tables.columns_list%TYPE
     ,p_partitioned_cols IN OUT ds_tables.columns_list%TYPE
   )
   IS
      l_table_name VARCHAR2(30);
      l_pos INTEGER;
      -- Cursor to browse table columns
      CURSOR c_col (
         p_table_name IN sys.all_tab_columns.table_name%TYPE
        ,p_table_alias IN ds_tables.table_alias%TYPE
        ,p_shuffle_group IN ds_masks.shuffle_group%TYPE
      ) IS
         SELECT LOWER(CASE WHEN p_table_alias IS NOT NULL THEN p_table_alias||'.' END ||column_name) column_name, msk_type, shuffle_group, partition_bitmap
           FROM ds_masks
          WHERE table_name = UPPER(p_table_name)
            AND NVL(disabled_flag,'N') = 'N'
            AND NVL(deleted_flag,'N') = 'N'
            AND ((msk_type = 'SHUFFLE' AND shuffle_group = p_shuffle_group)
              OR (BITAND(partition_bitmap,POWER(2,p_shuffle_group-1))>0))
      ;
   BEGIN
      p_shuffled_cols := NULL;
      p_partitioned_cols := NULL;
      l_pos := NVL(INSTR(p_table_name,'@'),0);
      IF l_pos>0 THEN
         l_table_name := SUBSTR(p_table_name,1,l_pos-1); -- remove db_link name
      ELSE
         l_table_name := p_table_name;
      END IF;
      -- For each masked column
      FOR r_col IN c_col(l_table_name, p_table_alias, p_shuffle_group) LOOP
         IF r_col.msk_type = 'SHUFFLE' AND r_col.shuffle_group = p_shuffle_group THEN
            p_shuffled_cols := CASE WHEN p_shuffled_cols IS NOT NULL THEN p_shuffled_cols || ', ' END || r_col.column_name;
         END IF;
         IF BITAND(r_col.partition_bitmap,POWER(2,p_shuffle_group-1)) > 0 THEN
            p_partitioned_cols := CASE WHEN p_partitioned_cols IS NOT NULL THEN p_partitioned_cols || ', ' END || r_col.column_name;
         END IF;
      END LOOP;
   END;
--#begin public
   ---
   -- Shuffle records for a data set
   ---
   PROCEDURE shuffle_records (
      p_set_id IN ds_data_sets.set_id%TYPE -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
--#end public
   IS
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT ds_tab.*
           FROM ds_tables ds_tab
          INNER JOIN (
                SELECT DISTINCT table_name
                  FROM ds_masks
                 WHERE NVL(disabled_flag,'N') = 'N'
                   AND NVL(deleted_flag,'N') = 'N'
                   AND msk_type = 'SHUFFLE'
                   AND shuffle_group > 0
              ) ds_msk
             ON ds_msk.table_name = ds_tab.table_name
          INNER JOIN ds_data_sets ds_set
             ON ds_set.set_id = ds_tab.set_id
            AND ds_set.set_type = 'SUB'
            AND NVL(ds_set.disabled_flag,'N') = 'N'
          WHERE (p_set_id IS NULL OR ds_tab.set_id = p_set_id)
            AND ds_tab.extract_type != 'F'
          ORDER BY ds_tab.set_id, ds_tab.seq, ds_tab.table_name
         ;
     l_shuffled_cols ds_tables.columns_list%TYPE;
     l_partitioned_cols ds_tables.columns_list%TYPE;
     l_table_name ds_tables.table_name%TYPE;
     l_full_table_name ds_utility_var.g_long_name_type;
     l_sql VARCHAR2(4000);
     l_plunit VARCHAR2(100) := 'shuffle_records('||NVL(TO_CHAR(p_set_id),'NULL')||')';
   BEGIN
      IF NOT ds_utility_var.g_mask_data THEN
         RETURN;
      END IF;
      show_message('D','->'||l_plunit);
      <<table_loop>>
      FOR r_tab IN c_tab(p_set_id) LOOP
         l_table_name := LOWER(r_tab.table_name);
         l_full_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
         <<group_loop>>
         FOR g IN 1..3 LOOP
            get_shuffled_columns(r_tab.table_name, r_tab.table_alias, g, l_shuffled_cols, l_partitioned_cols);
            EXIT WHEN l_shuffled_cols IS NULL;
            l_partitioned_cols := CASE WHEN l_partitioned_cols IS NULL THEN NULL ELSE l_partitioned_cols||', ' END;
            l_sql :=
'
-- '||'SHUFFLING '||LOWER(r_tab.table_name)||' ON ('||l_shuffled_cols||')'||CASE WHEN l_partitioned_cols IS NOT NULL THEN ' PARTITION BY ('||RTRIM(l_partitioned_cols,', ')||')' END||q'# records
DECLARE
   -- Cursor to get records sorted randomly by partition columns
   CURSOR c_src IS
   SELECT #'||l_partitioned_cols||q'#ds_rec.record_rowid
    FROM ds_records ds_rec, #'||l_full_table_name||q'# #'||r_tab.table_alias||q'#
   WHERE ds_rec.table_id = #'||r_tab.table_id||q'#
     AND NVL(ds_rec.deleted_flag,'N') = 'N'
     AND #'||r_tab.table_alias||q'#.rowid = ds_rec.record_rowid
   ORDER BY #'||l_partitioned_cols||q'#dbms_random.value
   ;
   -- Cursor to get records that must updated with shuffled rowid
   CURSOR c_tgt IS
   SELECT #'||l_partitioned_cols||q'#ds_rec.rec_id
    FROM ds_records ds_rec, #'||l_full_table_name||q'# #'||r_tab.table_alias||q'#
   WHERE ds_rec.table_id = #'||r_tab.table_id||q'#
     AND NVL(ds_rec.deleted_flag,'N') = 'N'
     AND #'||r_tab.table_alias||q'#.rowid = ds_rec.record_rowid
   ORDER BY #'||l_partitioned_cols||q'#ds_rec.rec_id
   ;
   TYPE src_table IS TABLE OF c_src%ROWTYPE;
   TYPE tgt_table IS TABLE OF c_tgt%ROWTYPE;
   t_src src_table;
   t_tgt tgt_table;
BEGIN
   OPEN c_src;
   OPEN c_tgt;
   LOOP
      FETCH c_src BULK COLLECT INTO t_src LIMIT 100;
      FETCH c_tgt BULK COLLECT INTO t_tgt LIMIT 100;
      EXIT WHEN t_src.COUNT = 0;
      EXIT WHEN t_tgt.COUNT = 0;
      FORALL i IN 1..t_tgt.COUNT
         UPDATE ds_records
            SET shuffled_rowid_#'||TO_CHAR(g)||q'# = t_src(i).record_rowid
          WHERE rec_id = t_tgt(i).rec_id
         ;
   END LOOP;
   CLOSE c_src;
   CLOSE c_tgt;
END;#';
            set_seed(p_seed);
            execute_immediate(l_sql);
            reset_seed(p_seed);
         END LOOP group_loop;
      END LOOP table_loop;
      IF p_commit THEN
         COMMIT;
      END IF;
      show_message('D','<-'||l_plunit);
   END;
--#begin public
   ---
   -- Generate a random rowid for a foreign key column
   ---
   FUNCTION random_rowid_from_fk_col (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_fk_name IN ds_utility_var.object_name
    , p_fk_col_name IN ds_utility_var.object_name
    , p_seed IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
--#end public
   IS
      -- Cursor to get pk column linked to fk column
      CURSOR c_pk_col IS
         SELECT pkc.table_name, pkc.column_name, pkt.table_id
           FROM sys.all_constraints fk
          INNER JOIN sys.all_cons_columns fkc
             ON fkc.owner = fk.owner
            AND fkc.constraint_name = fk.constraint_name
            AND fkc.column_name = p_fk_col_name
          INNER JOIN sys.all_cons_columns pkc
             ON pkc.owner = fkc.owner
            AND pkc.constraint_name = fk.r_constraint_name
            AND pkc.position = fkc.position
          INNER JOIN ds_tables pkt
             ON pkt.set_id = p_set_id
            AND pkt.table_name = pkc.table_name
          WHERE fk.owner = NVL(ds_utility_var.g_owner,USER)
            AND fk.constraint_name = p_fk_name
            AND fk.constraint_type = 'R'
      ;
      r_pk_col c_pk_col%ROWTYPE;
      -- Cursor to get maximum weight
      CURSOR c_rec (
         p_table_id ds_records.table_id%TYPE
      )
      IS
         SELECT MAX(seq)
           FROM ds_records
          WHERE table_id = p_table_id
      ;
      CURSOR c_rec2 (
         p_table_id ds_records.table_id%TYPE
       , p_seq ds_records.seq%TYPE
      )
      IS
         SELECT record_rowid
           FROM ds_records
          WHERE table_id = p_table_id
            AND seq >= p_seq
          ORDER BY seq
          FETCH FIRST 1 ROW ONLY
      ;
      l_random_idx PLS_INTEGER;
      l_found BOOLEAN;
      l_record_rowid ds_records.record_rowid%TYPE;
      l_obj_name VARCHAR2(100);
      r_fk_pk ds_utility_var.fk_pk_record_type;
   BEGIN
      set_seed(p_seed);
      -- Look in cache first
      l_obj_name := p_set_id||'|'||p_fk_name||'|'||p_fk_col_name;
      IF ds_utility_var.g_fk_pk_tab.EXISTS(l_obj_name) THEN
         r_fk_pk := ds_utility_var.g_fk_pk_tab(l_obj_name);
      ELSE
         -- Determine target table
         OPEN c_pk_col;
         FETCH c_pk_col INTO r_pk_col;
         l_found := c_pk_col%FOUND;
         CLOSE c_pk_col;
         assert(l_found,'No PK column found for FK column '||p_fk_name||'.'||p_fk_col_name);
         r_fk_pk.pk_table_name := r_pk_col.table_name;
         r_fk_pk.pk_col_name := r_pk_col.column_name;
         r_fk_pk.table_id := r_pk_col.table_id;
         -- Compute max weight
         OPEN c_rec(r_pk_col.table_id);
         FETCH c_rec INTO r_fk_pk.max_weight;
         CLOSE c_rec;
         assert(r_fk_pk.max_weight IS NOT NULL,'No record rowid found for reference table '||r_pk_col.table_name);
         assert(r_fk_pk.max_weight>0,'No positive weight for reference table '||r_pk_col.table_name);
         -- Save in cache
         ds_utility_var.g_fk_pk_tab(l_obj_name) := r_fk_pk;
      END IF;
      -- Generate random index between 1 and max weight
      l_random_idx := ds_masker_krn.random_integer(1,r_fk_pk.max_weight,p_seed);
      -- Get first record whose pass_count >= random index
      OPEN c_rec2(r_fk_pk.table_id,l_random_idx);
      FETCH c_rec2 INTO l_record_rowid;
      CLOSE c_rec2;
      reset_seed(p_seed);
      RETURN l_record_rowid;
   END;
--#begin public
   ---
   -- Extract rowids of records of reference tables
   ---
   PROCEDURE extract_ref_tables_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
      -- Browse reference tables
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND extract_type = 'R' -- Reference
          ORDER BY set_id, seq, table_name
         ;
      l_sql VARCHAR2(4000);
   BEGIN
      FOR r_tab IN c_tab(p_set_id) LOOP
         DELETE ds_records
          WHERE table_id = r_tab.table_id
         ;
         l_sql :=
'INSERT INTO ds_records (
   rec_id, table_id, record_rowid
 , seq, pass_count
)
SELECT ds_rec_seq.nextval, '||r_tab.table_id||', rowid
     , rownum, 1
  FROM '||LOWER(r_tab.table_name);
         IF r_tab.where_clause IS NOT NULL THEN
            l_sql := l_sql || '
 WHERE '||r_tab.where_clause;
         END IF;
         execute_immediate(l_sql);
      END LOOP;
      -- Delete cache
      ds_utility_var.g_fk_pk_tab.DELETE;
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
      l_full_table_name VARCHAR2(100);
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
         l_full_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
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
SELECT '||r_tab.table_id||' table_id, rowid record_rowid, 1 pass_count, 0 seq
  FROM '||l_full_table_name||'
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
            IF NVL(INSTR(ds_utility_var.g_msg_mask,'D'),0) > 0 THEN
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
--#begin public
   ---
   -- Define walk-through strategy
   ---
   PROCEDURE define_walk_through_strategy (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
--#end public
   IS
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
            ORDER BY tab_seq, table_name
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
            show_message('D','table '||r_tab.table_name||' ('||r_tab.extract_type||')');
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
          INNER JOIN sys.all_constraints ds_con
             ON ds_con.owner = NVL(ds_utility_var.g_owner,USER)
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
          WHERE ds_con.owner = NVL(ds_utility_var.g_owner,USER)
            AND ds_con.table_name = p_table_name
            AND ds_con.constraint_type = 'P'
          ORDER BY col.position
      ;
      -- Get constraints
      CURSOR c_con (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT ds_con.*, ds_tab.source_schema, ds_tab.source_db_link
           FROM ds_constraints ds_con
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_con.set_id
            AND ds_tab.table_name = ds_con.src_table_name
          WHERE ds_con.set_id = p_set_id
--            AND ds_con.extract_count > 0
          ORDER BY ds_con.con_id
      ;
      l_sql VARCHAR2(4000);
      l_full_table_name VARCHAR2(100);
   BEGIN
      FOR r_tab IN c_tab(p_set_id) LOOP
         l_full_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
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
            FROM '||l_full_table_name||'
           WHERE rowid = ds_rec.record_rowid
       )
 WHERE source_rowid IS NULL
   AND table_id = '||r_tab.table_id;
         execute_immediate(l_sql);
      END LOOP;
      FOR r_con IN c_con(p_set_id) LOOP
         l_full_table_name := gen_full_table_name(r_con.src_table_name,r_con.source_schema,r_con.source_db_link);
         l_sql :=
'UPDATE ds_records ds_rec
   SET remark = (';
         FOR r_col IN c_col(r_con.src_table_name) LOOP
            l_sql := l_sql || CHR(10)
                  || CASE WHEN r_col.position = 1 THEN '          SELECT ds_rec.remark || '' <= ' ELSE '              || '',' END
                  || r_col.column_name || '=''||' ||r_col.column_name;
         END LOOP;
         l_sql := l_sql ||
'
            FROM '||LOWER(l_full_table_name)||'
           WHERE rowid = ds_rec.source_rowid
       )
 WHERE source_rowid IS NOT NULL
   AND con_id = '||r_con.con_id;
          execute_immediate(l_sql);
      END LOOP;
   END;
   --
/*
   PROCEDURE print_key (
      r_key ds_utility_var.fk_record_type
   )
   IS
   BEGIN
      dbms_output.put_line('pk_name='||r_key.pk_name);
      dbms_output.put_line('pk_tab_name='||r_key.pk_tab_name);
      dbms_output.put_line('pk_col_name='||r_key.pk_col_name);
      dbms_output.put_line('pk_nullable='||r_key.pk_nullable);
      dbms_output.put_line('pk_tab_alias='||r_key.pk_tab_alias);
      dbms_output.put_line('table_alias='||r_key.table_alias);
      dbms_output.put_line('fk_name='||r_key.fk_name);
      dbms_output.put_line('fk_tab_name='||r_key.fk_tab_name);
      dbms_output.put_line('fk_col_name='||r_key.fk_col_name);
      dbms_output.put_line('fk_nullable='||r_key.fk_nullable);
      dbms_output.put_line('fk_tab_alias='||r_key.fk_tab_alias);
      dbms_output.put_line('join_clause='||r_key.join_clause);
      dbms_output.put_line('col_val='||r_key.col_val);
   END;
*/
   ---
   -- Initialise pk masking propagation to FKs
   -- For masking techniques that require to join tables
   -- i.e. SQL and SHUFFLE masking types
   ---
   PROCEDURE init_pk_masking_propagation (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            AND set_type = 'SUB'
            AND NVL(disabled_flag,'N') = 'N'
          ORDER BY set_id
      ;
      -- Cursor to get masked PK columns that must be propagated to FKs via joins
      -- Covers only SHUFFLE and SQL (with column dependencies) masking.
      CURSOR c_fk (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_pk_tab_name IN VARCHAR2
       , p_pk_col_name IN VARCHAR2
      )
      IS
         SELECT ds_pk_con.constraint_name pk_name, LOWER(ds_pk_col.table_name) pk_tab_name, LOWER(ds_pk_col.column_name) pk_col_name
              , ds_pk_col2.nullable pk_nullable
              , LOWER(ds_fk_con.constraint_name||ds_fk_col.position) pk_tab_alias
              , ds_tab.table_alias /*|| CASE WHEN ds_pk_col.table_name = ds_fk_col.table_name THEN '_p' END*/ table_alias
              , ds_fk_con.constraint_name fk_name, LOWER(ds_fk_col.table_name) fk_tab_name, LOWER(ds_fk_col.column_name) fk_col_name
              , ds_fk_col2.nullable fk_nullable
              , ds_tab_fk.table_alias || CASE WHEN ds_pk_col.table_name = ds_fk_col.table_name THEN '_c' END fk_tab_alias
              , CAST ('' AS VARCHAR2(400)) join_clause, CAST ('' AS VARCHAR2(4000)) col_val
           FROM ds_tables ds_tab
           LEFT OUTER JOIN ds_masks ds_msk
             ON ds_msk.table_name = ds_tab.table_name
            AND NVL(ds_msk.disabled_flag,'N') = 'N'
            AND NVL(ds_msk.deleted_flag,'N') = 'N'
            AND ds_msk.msk_type IN ('SQL','SHUFFLE')
            AND (ds_msk.params IS NOT NULL OR ds_msk.msk_type = 'SHUFFLE')
          INNER JOIN sys.all_constraints ds_pk_con
             ON ds_pk_con.owner = NVL(ds_utility_var.g_owner,USER)
            AND ds_pk_con.table_name = ds_tab.table_name
            AND ds_pk_con.constraint_type IN ('P','U')
          INNER JOIN sys.all_cons_columns ds_pk_col
             ON ds_pk_col.owner = ds_pk_con.owner
            AND ds_pk_col.constraint_name = ds_pk_con.constraint_name
            AND ds_pk_col.column_name = NVL(UPPER(p_pk_col_name),ds_msk.column_name)
          INNER JOIN sys.all_tab_columns ds_pk_col2
             ON ds_pk_col2.owner = ds_pk_col.owner
            AND ds_pk_col2.table_name = ds_pk_col.table_name
            AND ds_pk_col2.column_name = ds_pk_col.column_name
          INNER JOIN sys.all_constraints ds_fk_con
             ON ds_fk_con.owner = ds_pk_con.owner
            AND ds_fk_con.constraint_type = 'R'
            AND ds_fk_con.r_constraint_name = ds_pk_con.constraint_name
          INNER JOIN sys.all_cons_columns ds_fk_col
             ON ds_fk_col.owner = ds_fk_col.owner
            AND ds_fk_col.constraint_name = ds_fk_con.constraint_name
            AND ds_fk_col.position = ds_pk_col.position
          INNER JOIN sys.all_tab_columns ds_fk_col2
             ON ds_fk_col2.owner = ds_fk_col.owner
            AND ds_fk_col2.table_name = ds_fk_col.table_name
            AND ds_fk_col2.column_name = ds_fk_col.column_name
          INNER JOIN ds_tables ds_tab_fk -- limit FK to extracted tables
             ON ds_tab_fk.set_id = p_set_id
            AND ds_tab_fk.table_name = ds_fk_con.table_name
            AND ds_tab_fk.extract_type != 'N'
          WHERE ds_tab.set_id = p_set_id
            AND ds_tab.extract_type != 'N'
            AND (ds_pk_con.table_name = UPPER(p_pk_tab_name) OR ds_msk.msk_id IS NOT NULL)
            AND NOT (NVL(ds_msk.msk_type,'XXX') = 'SQL' AND NVL(ds_msk.dependent_flag,'N')='N')
         ORDER BY 1, 2, 3, 4;
         l_fk_col_name ds_utility_var.full_column_name;
         r_fk2 c_fk%ROWTYPE;
         l_found BOOLEAN;
   BEGIN
      ds_utility_var.g_pk_tab.DELETE;
      ds_utility_var.g_fk_tab.DELETE;
      <<set_loop>>
      FOR r_set IN c_set(p_set_id) LOOP
         <<fk_loop>>
         FOR r_fk IN c_fk(r_set.set_id, NULL, NULL) LOOP
            r_fk.join_clause := build_join_clause(r_fk.table_alias, r_fk.fk_tab_alias, r_fk.fk_name);
            ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name) := r_fk;
            ds_utility_var.g_fk_tab(r_fk.fk_tab_name||'.'||r_fk.fk_col_name) := r_fk;
         END LOOP fk_loop;
         l_found := TRUE;
         <<again_loop>>
         WHILE l_found LOOP
            l_found := FALSE;
            l_fk_col_name := ds_utility_var.g_fk_tab.FIRST;
            <<fk2_loop>>
            WHILE l_fk_col_name IS NOT NULL LOOP
               r_fk2 := ds_utility_var.g_fk_tab(l_fk_col_name);
               IF NOT ds_utility_var.g_pk_tab.EXISTS(r_fk2.fk_tab_name||'.'||r_fk2.fk_col_name) THEN
                  <<fk_loop>>
                  FOR r_fk IN c_fk(r_set.set_id, r_fk2.fk_tab_name, r_fk2.fk_col_name) LOOP
                     IF  NOT ds_utility_var.g_pk_tab.EXISTS(r_fk.pk_tab_name||'.'||r_fk.pk_col_name)
                     AND NOT ds_utility_var.g_fk_tab.EXISTS(r_fk.fk_tab_name||'.'||r_fk.fk_col_name)
                     THEN
                        l_found := TRUE;
                        r_fk.join_clause := build_join_clause(r_fk.table_alias, r_fk.fk_tab_alias, r_fk.fk_name);
                        ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name) := r_fk;
                        ds_utility_var.g_fk_tab(r_fk.fk_tab_name||'.'||r_fk.fk_col_name) := r_fk;
                     END IF;
                  END LOOP fk_loop;
               END IF;
               l_fk_col_name := ds_utility_var.g_fk_tab.NEXT(l_fk_col_name);
            END LOOP fk2_loop;
         END LOOP again_loop;
      END LOOP set_loop;
      -- Reset masks of FK columns
      l_fk_col_name := ds_utility_var.g_fk_tab.FIRST;
      <<fk3_loop>>
      WHILE l_fk_col_name IS NOT NULL LOOP
         r_fk2 := ds_utility_var.g_fk_tab(l_fk_col_name);
         r_fk2.fk_tab_name := UPPER(r_fk2.fk_tab_name);
         r_fk2.fk_col_name := UPPER(r_fk2.fk_col_name);
         UPDATE ds_masks
            SET msk_type = 'INHERIT'
              , params = r_fk2.pk_tab_name||'.'||r_fk2.pk_col_name
              , pat_cat = NULL
              , pat_name = NULL
              , values_sample = NULL
              , sensitive_flag = 'Y'
              , remarks = 'Inherited value from '||r_fk2.pk_tab_name||'.'||r_fk2.pk_col_name||' via '||LOWER(r_fk2.fk_name)
              , deleted_flag = NULL
          WHERE table_name = UPPER(r_fk2.fk_tab_name)
            AND column_name = UPPER(r_fk2.fk_col_name)
         ;
         IF SQL%ROWCOUNT = 0 THEN
            insert_mask(p_table_name=>r_fk2.fk_tab_name, p_column_name=>r_fk2.fk_col_name, p_msk_type=>'INHERIT', p_params=>r_fk2.pk_tab_name||'.'||r_fk2.pk_col_name
              ,p_sensitive_flag=>'Y', p_remarks=>'Inherited value from '||r_fk2.pk_tab_name||'.'||r_fk2.pk_col_name||' via '||LOWER(r_fk2.fk_name)
              ,p_deleted_flag=>NULL
            );
         END IF;
         l_fk_col_name := ds_utility_var.g_fk_tab.NEXT(l_fk_col_name);
      END LOOP fk3_loop;
--      dbms_output.put_line('init_pk_masking(): pk_tab.count='||ds_utility_var.g_pk_tab.COUNT);
--      dbms_output.put_line('init_pk_masking(): fk_tab.count='||ds_utility_var.g_fk_tab.COUNT);
      load_masks;
   END;
/*
   ---
   -- Print seq record (for debugging purpose)
   ---
   PROCEDURE print_seq (
      p_title IN VARCHAR2
    , r_seq ds_utility_var.seq_record_type
   )
   IS
   BEGIN
      dbms_output.put_line(p_title);
      dbms_output.put_line('table_id='||r_seq.table_id);
      dbms_output.put_line('set_id='||r_seq.set_id);
      dbms_output.put_line('sequence_name='||r_seq.sequence_name);
      dbms_output.put_line('in_mem_seq_flag='||r_seq.in_mem_seq_flag);
      dbms_output.put_line('in_mem_seq_start_number='||r_seq.in_mem_seq_start_number);
      dbms_output.put_line('in_mem_seq_increment_by='||r_seq.in_mem_seq_increment_by);
      dbms_output.put_line('table_name='||r_seq.table_name);
      dbms_output.put_line('column_name='||r_seq.column_name);
      dbms_output.put_line('msk_type='||r_seq.msk_type);
      dbms_output.put_line('msk_params='||r_seq.msk_params);
      dbms_output.put_line('pk_tab_name='||r_seq.pk_tab_name);
      dbms_output.put_line('pk_col_name='||r_seq.pk_col_name);
      dbms_output.put_line('msk_options='||r_seq.msk_options);
   END;
*/
--#begin public
   ---
   -- Set dependent flag in ds_masks
   ---
   PROCEDURE set_dependent_flag
--#end public
   IS
      CURSOR c_msk IS
         SELECT table_name, column_name, params, dependent_flag
           FROM ds_masks
          WHERE msk_type = 'SQL'
            AND NVL(deleted_flag,'N') = 'N'
            AND NVL(disabled_flag,'N') = 'N'
          ORDER BY table_name, column_name
            FOR UPDATE OF dependent_flag
         ;
      r_prv c_msk%ROWTYPE;
      l_columns ds_utility_var.column_name_table;
      l_dependent_flag ds_masks.dependent_flag%TYPE;
   BEGIN
      FOR r_msk IN c_msk LOOP
         IF r_prv.table_name IS NULL OR r_msk.table_name != r_prv.table_name THEN
            l_columns := get_table_columns2(r_msk.table_name,r_msk.column_name);
         END IF;
         l_dependent_flag := CASE WHEN is_dependent(r_msk.params, r_msk.column_name, l_columns) THEN 'Y' ELSE NULL END;
         IF NVL(r_msk.dependent_flag,'N') != NVL(l_dependent_flag,'N') THEN
            UPDATE ds_masks
               SET dependent_flag = l_dependent_flag
             WHERE CURRENT OF c_msk;
         END IF;
         r_prv := r_msk;
      END LOOP;
   END;
   ---
   -- Initialise relocation of sequences
   ---
   PROCEDURE init_seq (
      p_set_id IN ds_data_sets.set_id%TYPE
   )
   IS
      CURSOR c_set (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            AND set_type = 'SUB'
            AND NVL(disabled_flag,'N') = 'N'
          ORDER BY set_id
      ;
      -- Columns masked with a sequence, a token or a SQL expression
      -- that does not reference other columns (w/o requiring to join)
      -- Sequence type (Oracle vs in-memory) is determined by sequence name
      -- Oracle: sequence name must be valid or contain a db link (@)
      -- In-memory: otherwise
      CURSOR c_seq (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT ds_tab.table_id, ds_tab.set_id
              , CASE WHEN ds_msk.msk_type = 'SEQUENCE' THEN 
                          CASE WHEN NVL(INSTR(ds_msk.params,'@'),0)<=0 AND all_seq.sequence_name IS NULL
                               THEN LOWER(ds_tab.table_alias||'_'||ds_msk.column_name)
                               ELSE ds_msk.params
                           END
                     ELSE NULL
                 END sequence_name
              , CASE WHEN ds_msk.msk_type = 'SEQUENCE' AND NVL(INSTR(ds_msk.params,'@'),0)<=0 AND all_seq.sequence_name IS NULL THEN 'Y' ELSE '' END in_mem_seq_flag
              , CASE WHEN ds_msk.msk_type = 'SEQUENCE'
                     THEN CASE WHEN REGEXP_REPLACE(ds_msk.params, '.*START WITH ([1-9][0-9]*).*', '\1') != ds_msk.params -- replace succeeded
                               THEN TO_NUMBER(REGEXP_REPLACE(ds_msk.params, '.*START WITH ([1-9][0-9]*).*', '\1'))
                               ELSE 1
                           END
                     ELSE NULL
                 END in_mem_seq_start_number
              , CASE WHEN ds_msk.msk_type = 'SEQUENCE' 
                     THEN CASE WHEN REGEXP_REPLACE(ds_msk.params, '.*INCREMENT BY ([1-9][0-9]*).*', '\1') != ds_msk.params -- replace succeeded
                               THEN TO_NUMBER(REGEXP_REPLACE(ds_msk.params, '.*INCREMENT BY ([1-9][0-9]*).*', '\1'))
                               ELSE 1
                           END
                     ELSE NULL
                 END in_mem_seq_increment_by
              , LOWER(ds_tab.table_name) table_name, LOWER(all_col.column_name) column_name
              , all_col.nullable
              , ds_msk.msk_type
              , ds_msk.msk_id
              , ds_msk.params msk_params
              , LOWER(ds_tab.table_name) pk_tab_name
              , LOWER(all_col.column_name) pk_col_name
              , ds_msk.options msk_options
           FROM ds_tables ds_tab
          INNER JOIN ds_masks ds_msk
             ON ds_msk.table_name = ds_tab.table_name
            AND ds_msk.msk_type IN ('SEQUENCE','TOKENIZE','SQL')
            AND NVL(ds_msk.disabled_flag,'N') = 'N'
            AND NVL(ds_msk.deleted_flag,'N') = 'N'
            AND NOT (ds_msk.msk_type = 'SQL' AND NVL(ds_msk.dependent_flag,'N')='Y')
          INNER JOIN all_tab_columns all_col
             ON all_col.owner = NVL(ds_utility_var.g_owner,USER)
            AND all_col.table_name = ds_tab.table_name
            AND all_col.column_name = ds_msk.column_name
           LEFT OUTER JOIN sys.all_sequences all_seq
             ON all_seq.sequence_owner = all_col.owner
            AND all_seq.sequence_name = UPPER(ds_msk.params)
          WHERE ds_tab.set_id = p_set_id
      ;
      -- Cursor to get FK columns linked to a masked PK (whose masking must be propagated)
      CURSOR c_map (
         p_set_id IN ds_data_sets.set_id%TYPE
       , p_table_name IN sys.all_constraints.table_name%TYPE
       , p_column_name IN sys.all_cons_columns.column_name%TYPE
      )
      IS
         SELECT ds_tab.table_id, ds_tab.set_id, NULL sequence_name
              , '' in_mem_seq_flag, 1 in_mem_seq_start_number, 1 in_mem_seq_increment_by
              , LOWER(fk.table_name) table_name, LOWER(fkcol.column_name) column_name
              , fkcol2.nullable
              , CAST(NULL AS VARCHAR2(30)) msk_type
              , CAST(NULL AS NUMBER(9)) msk_id
              , CAST(NULL AS VARCHAR2(4000)) msk_params
              , CAST (NULL AS VARCHAR2(30)) pk_tab_name
              , CAST (NULL AS VARCHAR2(30)) pk_col_name
              , CAST (NULL AS VARCHAR2(200)) msk_options
           FROM ds_tables ds_tab
          INNER JOIN sys.all_constraints pk
             ON pk.owner = NVL(ds_utility_var.g_owner,USER)
            AND pk.table_name = ds_tab.table_name
            AND pk.constraint_type IN ('P','U')
          INNER JOIN sys.all_cons_columns pkcol
             ON pkcol.owner = pk.owner
            AND pkcol.constraint_name = pk.constraint_name
            AND pkcol.column_name = UPPER(p_column_name) --param
          INNER JOIN sys.all_constraints fk
             ON fk.owner = pk.owner
            AND fk.r_constraint_name = pk.constraint_name
            AND fk.constraint_type = 'R'
          INNER JOIN sys.all_cons_columns fkcol
             ON fkcol.owner = fk.owner
            AND fkcol.constraint_name = fk.constraint_name
            AND fkcol.position = pkcol.position
          INNER JOIN sys.all_tab_columns fkcol2
             ON fkcol2.owner = fk.owner
            AND fkcol.table_name = fk.table_name
            AND fkcol.column_name = fkcol.column_name
            AND fkcol.position = pkcol.position
          INNER JOIN ds_tables ds_tab_fk -- limit FK to extracted tables
             ON ds_tab_fk.set_id = p_set_id
            AND ds_tab_fk.table_name = fk.table_name
            AND ds_tab_fk.extract_type != 'N'
          WHERE ds_tab.set_id = p_set_id --param
            AND ds_tab.extract_type != 'N'
            AND ds_tab.table_name = UPPER(p_table_name) -- param
      ;
      t_pk ds_utility_var.shift_value_table;
      l_idx PLS_INTEGER;
      l_col_name ds_utility_var.full_column_name;
      r_seq c_seq%ROWTYPE;
      r_map c_seq%ROWTYPE;
      l_remarks ds_masks.remarks%TYPE;
   BEGIN
      set_dependent_flag;
      ds_utility_var.g_seq.DELETE;
      ds_utility_var.g_map.DELETE;
      ds_utility_var.g_in_mem_seq_tab.DELETE;
      <<set_loop>>
      FOR r_set IN c_set(p_set_id) LOOP
         t_pk.DELETE;
         <<seq_loop>>
         FOR r_seq IN c_seq(r_set.set_id) LOOP
            show_message('D','Using '||CASE WHEN r_seq.msk_type = 'TOKENIZE' THEN 'tokens' 
                                            WHEN r_seq.msk_type = 'TOKENIZE' THEN 'SQL expression'
                                            ELSE CASE WHEN r_seq.in_mem_seq_flag = 'Y' THEN 'in-memory' ELSE 'Oracle' END ||' sequence '||r_seq.sequence_name END
                                                 ||' to generate value for '||r_seq.table_name||'.'||r_seq.column_name);
--            print_seq('*** SEQ ***',r_seq);
            ds_utility_var.g_seq(r_seq.table_name||'.'||r_seq.column_name) := r_seq;
            IF r_seq.sequence_name IS NOT NULL AND r_seq.in_mem_seq_flag = 'Y' THEN
               -- Initialize in-memory sequence if needed
               ds_utility_var.g_in_mem_seq_tab(r_seq.sequence_name) := NVL(r_seq.in_mem_seq_start_number,1);
            END IF;
            t_pk(t_pk.COUNT+1) := r_seq;
            <<pk_loop>>
            WHILE t_pk.COUNT > 0 LOOP
               l_idx := t_pk.FIRST;
               <<map_loop>>
               FOR r_map IN c_map(r_set.set_id, t_pk(l_idx).table_name, t_pk(l_idx).column_name) LOOP
                  IF NOT ds_utility_var.g_map.EXISTS(r_map.table_name||'.'||r_map.column_name) THEN
                     t_pk(t_pk.LAST+1) := r_map;
                     r_seq.table_name := r_map.table_name;
                     r_seq.column_name := r_map.column_name;
                     r_seq.nullable := r_map.nullable;
--                     print_seq('*** MAP ***',r_seq);
                     ds_utility_var.g_map(r_map.table_name||'.'||r_map.column_name) := r_seq;
                  END IF;
               END LOOP map_loop;
               t_pk.DELETE(l_idx);
            END LOOP pk_loop;
         END LOOP seq_loop;
      END LOOP set_loop;
      IF ds_utility_var.g_mask_data THEN
         -- Reset masks of FK columns
         l_col_name := ds_utility_var.g_map.FIRST;
         WHILE l_col_name IS NOT NULL LOOP
            r_map := ds_utility_var.g_map(l_col_name);
            r_map.table_name := UPPER(r_map.table_name);
            r_map.column_name := UPPER(r_map.column_name);
            l_remarks := 'Inherit '
                   || CASE WHEN r_map.msk_type = 'TOKENIZE' THEN 'token from '||r_map.pk_tab_name||'.'||r_map.pk_col_name
                           WHEN r_map.msk_type = 'SQL' THEN 'SQL expression from '||r_map.pk_tab_name||'.'||r_map.pk_col_name
                           ELSE 'sequence value from '||r_map.pk_tab_name||'.'||r_map.pk_col_name
                       END;
            UPDATE ds_masks
               SET msk_type = 'INHERIT'
                 , params = r_map.sequence_name
                 , pat_cat = NULL
                 , pat_name = NULL
                 , values_sample = NULL
                 , sensitive_flag = 'Y'
                 , deleted_flag = NULL
                 , remarks = l_remarks
             WHERE table_name = r_map.table_name
               AND column_name = r_map.column_name
            ;
            IF SQL%ROWCOUNT = 0 THEN
               insert_mask(p_table_name=>r_map.table_name, p_column_name=>r_map.column_name, p_msk_type=>'INHERIT'
                 ,p_params=>r_map.sequence_name, p_remarks=>l_remarks, p_deleted_flag=>NULL
               );
            END IF;
            l_col_name := ds_utility_var.g_map.NEXT(l_col_name);
         END LOOP;
      END IF;
--      dbms_output.put_line('init_seq(): seq.count='||ds_utility_var.g_seq.COUNT);
--      dbms_output.put_line('init_seq(): map.count='||ds_utility_var.g_map.COUNT);
      load_masks;
   END;
   ---
   -- Get pk columns
   ---
   FUNCTION get_pk_columns (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_pk_columns ds_tables.columns_list%TYPE;
      l_pk_name sys.all_constraints.constraint_name%TYPE;
   BEGIN
      l_pk_name := get_table_pk(p_table_name);
      assert(l_pk_name IS NOT NULL,'Table '||p_table_name||' has no primary key');
      l_pk_columns := get_constraint_columns(p_constraint_name=>l_pk_name, p_table_alias=>p_table_alias);
      assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no columns');
      RETURN l_pk_columns;
   END;
   ---
   -- Build join statement for shuffling
   ---
   FUNCTION build_join_statement (
      p_purpose IN VARCHAR2
    , p_op IN VARCHAR2
    , p_extract_type IN VARCHAR2
    , p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_sel_columns IN VARCHAR2
    , p_order_by_clause IN VARCHAR2 := NULL
    , p_table_id ds_tables.table_id%TYPE := NULL
    , p_pass_count ds_tables.pass_count%TYPE := NULL
    , p_set_id ds_data_sets.set_id%TYPE := NULL
    , p_indent PLS_INTEGER := 0
    , p_where VARCHAR2 := NULL
    , p_source_schema VARCHAR2 := NULL
    , p_target_db_link IN VARCHAR2 := NULL
    , p_include_rowid IN BOOLEAN := NULL
   )
   RETURN VARCHAR2
   IS
      l_shuffled_cols ds_tables.columns_list%TYPE;
      t_shuffled_cols ds_utility_var.column_name_table;
      l_pk_cols ds_tables.columns_list%TYPE;
      l_fk_cols ds_tables.columns_list%TYPE;
      t_pk_cols ds_utility_var.column_name_table;
      t_fk_cols ds_utility_var.column_name_table;
      l_partitioned_cols ds_tables.columns_list%TYPE;
      l_all_columns ds_tables.columns_list%TYPE;
      l_col_val VARCHAR2(4000);
      t_all_columns ds_utility_var.column_name_table;
      l_table_name ds_utility_var.table_name := LOWER(p_table_name);
      r_fk ds_utility_var.fk_record_type;
      r_pk ds_utility_var.fk_record_type;
      l_table_alias2 VARCHAR2(30);
      l_table_alias3 VARCHAR2(30);
      l_select VARCHAR2(32767);
      l_order_by VARCHAR2(4000);
      l_where VARCHAR2(4000);
      l_sql VARCHAR2(32767);
      l_ws VARCHAR2(30);
      l_source_schema VARCHAR2(31);
      l_join_type VARCHAR2(20);
   BEGIN
      IF p_source_schema IS NOT NULL THEN
         l_source_schema := LOWER(p_source_schema)||'.';
      END IF;
      l_ws := RPAD(' ', p_indent,' ');
      -- Full or no extraction => no shuffling => no join needed
      IF p_extract_type IN ('F','N') THEN
         IF p_purpose = 'VIEW' THEN
            l_select := CASE WHEN p_include_rowid THEN p_table_alias||'.rowid, ' END ||p_sel_columns;
         ELSIF p_purpose = 'SCRIPT' THEN
            l_select := build_sql_statement_part('X',p_table_name,NULL,p_op,p_sel_columns,7);
         ELSIF p_purpose = 'DIRECT' THEN
            l_select := build_sql_statement_part('S',p_table_name,NULL,p_op,p_sel_columns,7);
         END IF;
         l_sql :=
            l_ws||'SELECT '||l_select||CHR(10)
          ||l_ws||'  FROM '||l_source_schema||p_table_name||' '||p_table_alias||CHR(10);
         IF p_extract_type = 'N' THEN
            l_sql := l_sql
          ||l_ws||' WHERE 1=0'||CHR(10);
         ELSE
            l_sql := l_sql
          ||l_ws||' WHERE 1=1'||CHR(10);
         END IF;
         IF p_where IS NOT NULL THEN
            l_sql := l_sql
          ||l_ws||'   AND '||p_where||CHR(10);
         END IF;
         IF p_order_by_clause IS NOT NULL THEN
            l_sql := l_sql
          ||l_ws||' ORDER BY '||l_order_by||CHR(10);
         END IF;
         RETURN l_sql;
      END IF;
      -- Init
      l_all_columns := normalise_columns_list(p_table_name,'*');
      t_all_columns := tokenize_columns_list(l_all_columns);
      /* Select rows to extract */
      l_select := NULL;
      IF p_sel_columns IS NOT NULL THEN
         l_select := build_sql_statement_part(
            p_part => CASE WHEN p_purpose = 'SCRIPT' THEN 'X' ELSE 'S' END
           ,p_table_name => p_table_name
           ,p_table_alias => p_table_alias
           ,p_op => p_op
           ,p_columns_list => p_sel_columns
           ,p_left_tab => p_indent + 8
           ,p_indent_first_line => 'N'
           ,p_indent => p_indent);
      END IF;
      l_order_by := add_table_alias(p_order_by_clause, p_table_alias, t_all_columns);
      IF ds_utility_var.g_mask_data THEN
         -- Handle shuffling => replace selected columns to reference joined table
         <<group_loop>>
         FOR g IN 1..3 LOOP
            get_shuffled_columns(p_table_name, NULL/*without table alias prefix*/, g, l_shuffled_cols, l_partitioned_cols);
            EXIT WHEN l_shuffled_cols IS NULL;
            l_table_alias2 := p_table_alias||TO_CHAR(g);
            t_shuffled_cols := tokenize_columns_list(l_shuffled_cols);
            IF t_shuffled_cols.COUNT>0 THEN
               l_select := replace_table_alias(l_select,p_table_alias,l_table_alias2,t_shuffled_cols);
               l_order_by := replace_table_alias(l_order_by,p_table_alias,l_table_alias2,t_shuffled_cols);
            END IF;
         END LOOP group_loop;
         -- Handle PK masking propagation to FKs => replace selected columns with mask SQL expression
         get_pk_fk_columns(l_table_name, l_pk_cols, l_fk_cols);
         t_pk_cols := tokenize_columns_list(l_pk_cols);
         t_fk_cols := tokenize_columns_list(l_fk_cols);
         FOR c IN 1..t_pk_cols.COUNT LOOP
            r_fk := ds_utility_var.g_fk_tab(l_table_name||'.'||t_fk_cols(c));
            r_pk := ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
            WHILE ds_utility_var.g_fk_tab.EXISTS(r_fk.pk_tab_name||'.'||r_fk.pk_col_name) LOOP
               r_fk := ds_utility_var.g_fk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
               r_pk := ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
            END LOOP;
            l_col_val := sql_regexp_replace(r_pk.col_val,'([^A-Za-z0-9_]|^)('||r_pk.pk_col_name||')([^A-Za-z0-9_]|$)','\1'||r_pk.pk_tab_alias||'.'||r_pk.pk_col_name||'\3',1,0,'i');
            IF NOT REGEXP_LIKE(l_col_val,'[. ]$'||r_pk.pk_col_name) AND p_purpose != 'SCRIPT' THEN
               l_col_val := l_col_val || ' ' || t_fk_cols(c); -- add column alias
            END IF;
            l_select := sql_regexp_replace(l_select,'([^A-Za-z0-9_]|^)('||p_table_alias||'\.'||t_fk_cols(c)||')([^A-Za-z0-9_]|$)','\1'||l_col_val||'\3',1,0,'i');
            -- Shuffling of PK/UK
            FOR g IN 1..3 LOOP
               get_shuffled_columns(r_pk.pk_tab_name, NULL/*without table alias prefix*/, g, l_shuffled_cols, l_partitioned_cols);
               EXIT WHEN l_shuffled_cols IS NULL;
               l_table_alias3 := r_pk.pk_tab_alias||'_rec'||TO_CHAR(g)||'_'||r_pk.table_alias;
               l_select := sql_regexp_replace(l_select,'([^A-Za-z0-9_]|^)('||r_pk.pk_tab_alias||'\.'||r_pk.pk_col_name||')([^A-Za-z0-9_]|$)','\1'||l_table_alias3||'.'||r_pk.pk_col_name||'\3',1,0,'i');
            END LOOP;
         END LOOP;
      END IF; -- mask mode
      l_sql := '';
      IF l_select IS NOT NULL THEN
         IF p_include_rowid THEN
            l_select := p_table_alias ||'.rowid, ' || l_select;
         END IF;
         l_sql :=
            l_ws||'SELECT '||l_select||CHR(10);
      END IF;
      l_sql := l_sql
       ||l_ws||'  FROM ds_records ds_rec'||CHR(10)
      ;
      IF p_table_id IS NULL THEN
         l_sql := l_sql
       ||l_ws||' INNER JOIN ds_tables ds_tab'||CHR(10)
       ||l_ws||'    ON ds_tab.table_id = ds_rec.table_id'||CHR(10)
       ||l_ws||'   AND ds_tab.table_name = '''||p_table_name||''''||CHR(10)
       ||l_ws||'   AND ds_tab.extract_type IN (''B'',''P'')'||CHR(10);
         IF p_set_id IS NOT NULL THEN
            l_sql := l_sql
       ||l_ws||'   AND ds_tab.set_id = '||p_set_id||CHR(10);
         ELSE
            l_sql := l_sql
       ||l_ws||' INNER JOIN ds_data_sets ds_set'||CHR(10)
       ||l_ws||'    ON ds_set.set_id = ds_tab.set_id'||CHR(10)
       ||l_ws||'   AND NVL(ds_set.visible_flag,''Y'') = ''Y'''||CHR(10);
         END IF;
      END IF;
      l_sql := l_sql
       ||l_ws||' INNER JOIN '||l_source_schema||LOWER(p_table_name)||' '||p_table_alias||CHR(10)
       ||l_ws||'    ON '||p_table_alias||'.rowid = ds_rec.record_rowid'||CHR(10);
      IF p_where IS NOT NULL THEN
         l_sql := l_sql
       ||l_ws||'   AND '||p_where||CHR(10);
      END IF;
      IF ds_utility_var.g_mask_data THEN
         -- Shuffling => need to join source table once more per shuffling group
         FOR g IN 1..3 LOOP
            get_shuffled_columns(p_table_name, NULL/*without table alias prefix*/, g, l_shuffled_cols, l_partitioned_cols);
            EXIT WHEN l_shuffled_cols IS NULL;
            l_table_alias2 := p_table_alias||TO_CHAR(g);
            l_sql := l_sql
          ||l_ws||' INNER JOIN '||l_source_schema||LOWER(p_table_name)||' '||l_table_alias2||CHR(10)
          ||l_ws||'    ON '||l_table_alias2||'.rowid = ds_rec.shuffled_rowid_'||TO_CHAR(g)||CHR(10);
   --         IF p_where IS NOT NULL THEN
   --            l_sql := l_sql
   --       ||l_ws||'   AND '||replace_table_alias(p_where,l_table_alias2,p_table_alias,t_all_columns)||CHR(10);
   --         END IF;
         END LOOP group_loop;
         -- PK masking propagation
         FOR c IN 1..t_pk_cols.COUNT LOOP
            r_fk := ds_utility_var.g_fk_tab(l_table_name||'.'||t_fk_cols(c));
            r_pk := ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
            LOOP
--dbms_output.put_line('=== FOREIGN KEY ===');
--print_key(r_fk);
--dbms_output.put_line('=== PRIMARY KEY ===');
--print_key(r_pk);
               r_fk.join_clause := regexp_replace(r_fk.join_clause,'([^A-Za-z0-9_]|^)('||r_pk.table_alias||')([^A-Za-z0-9_]|$)','\1'||r_pk.pk_tab_alias||'\3',1,0,'i');
               r_fk.join_clause := regexp_replace(r_fk.join_clause,'([^A-Za-z0-9_]|^)('||r_fk.fk_tab_alias||')([^A-Za-z0-9_]|$)','\1'||p_table_alias||'\3',1,0,'i');
               l_join_type := CASE WHEN r_fk.fk_nullable = 'N' THEN ' INNER ' ELSE '  LEFT OUTER ' END;
               l_sql := l_sql
             ||l_ws||l_join_type||'JOIN '||l_source_schema||LOWER(r_pk.pk_tab_name)||' '||r_pk.pk_tab_alias||CHR(10)
             ||l_ws||'    ON ' ||r_fk.join_clause||CHR(10);
               EXIT WHEN NOT ds_utility_var.g_fk_tab.EXISTS(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
               r_fk := ds_utility_var.g_fk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
               r_pk := ds_utility_var.g_pk_tab(r_fk.pk_tab_name||'.'||r_fk.pk_col_name);
            END LOOP;
            -- Shuffling of PK/UK
            FOR g IN 1..3 LOOP
               get_shuffled_columns(r_pk.pk_tab_name, NULL/*without table alias prefix*/, g, l_shuffled_cols, l_partitioned_cols);
               EXIT WHEN l_shuffled_cols IS NULL;
               l_table_alias2 := r_pk.pk_tab_alias||'_rec'||TO_CHAR(g);
               l_table_alias3 := r_pk.pk_tab_alias||'_rec'||TO_CHAR(g)||'_'||r_pk.table_alias;
               l_join_type := CASE WHEN r_fk.fk_nullable = 'N' THEN ' INNER ' ELSE '  LEFT OUTER ' END;
               l_sql := l_sql
             ||l_ws||l_join_type||'JOIN ds_records '||l_table_alias2||CHR(10)
             ||l_ws||'    ON '||r_pk.pk_tab_alias||'.rowid = '||l_table_alias2||'.record_rowid'||CHR(10)
             ||l_ws||l_join_type||'JOIN '||l_source_schema||LOWER(r_pk.pk_tab_name)||' '||l_table_alias3||CHR(10)
             ||l_ws||'    ON '||l_table_alias3||'.rowid = '||l_table_alias2||'.shuffled_rowid_'||TO_CHAR(g)||CHR(10);
               IF r_fk.fk_nullable = 'Y' THEN
                  l_where := l_where
             ||l_ws||'   AND NOT ('||r_fk.table_alias||'.'||r_fk.fk_col_name||' IS NOT NULL AND '||l_table_alias2||'.rowid IS NULL)'||CHR(10)
             ||l_ws||'   AND NOT ('||r_fk.table_alias||'.'||r_fk.fk_col_name||' IS NOT NULL AND '||l_table_alias3||'.rowid IS NULL)'||CHR(10);
               END IF;
            END LOOP;
         END LOOP;
      END IF; -- if masking enabled
      l_sql := l_sql
       ||l_ws||' WHERE 1=1'||CHR(10);
      IF l_where IS NOT NULL THEN
         l_sql := l_sql || l_where;
      END IF;
      IF p_table_id IS NOT NULL THEN
         l_sql := l_sql
       ||l_ws||'   AND ds_rec.table_id='||p_table_id||CHR(10);
      END IF;
      IF p_pass_count IS NOT NULL THEN
         l_sql := l_sql
       ||l_ws||'   AND ds_rec.pass_count='||p_pass_count||CHR(10);
      END IF;
      l_sql := l_sql
       ||l_ws||'   AND NVL(ds_rec.deleted_flag,''N'') = ''N'''||CHR(10);
      -- Global encryption key is not used through dblink (like if it was executed in a separate session) => force it in the SQL
      IF p_target_db_link IS NOT NULL AND ((instr_ignore_case(l_select,'.encrypt')>0 OR instr_ignore_case(l_select,'.decrypt')>0)
      OR (instr_ignore_case(l_select,'.get_token_from_value')>0 AND ds_utility_var.g_encrypt_tokenized_values))
      THEN
         l_sql := l_sql
       ||l_ws||'   AND ds_masker_krn.set_encryption_key('''||ds_crypto_krn.get_encryption_key||''') IS NOT NULL'||CHR(10);
      END IF;
      -- Idem for g_owner global variable
      IF p_target_db_link IS NOT NULL AND NVL(ds_utility_var.g_owner,USER) != USER THEN
         l_sql := l_sql
       ||l_ws||'   AND ds_utility_krn.set_source_schema('''||NVL(ds_utility_var.g_owner,USER)||''') IS NOT NULL'||CHR(10);
      END IF;
      IF p_order_by_clause IS NOT NULL THEN
         l_sql := l_sql
          ||l_ws||' ORDER BY '||l_order_by||CHR(10);
      END IF;
      RETURN l_sql;
   END;
--#begin public
   ---
   -- Generate identifiers for SEQUENCE masking (Oracle or in-memory)
   ---
   PROCEDURE generate_identifiers (
      p_set_id IN ds_data_sets.set_id%TYPE -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
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
            AND NVL(disabled_flag,'N') = 'N'
            AND set_type = 'SUB'
      ;
      l_sql VARCHAR2(4000);
      l_fnc VARCHAR2(100);
      l_pk_name sys.all_constraints.constraint_name%TYPE;
      l_pk_columns ds_tables.columns_list%TYPE;
      l_col_name ds_utility_var.full_column_name;
      r_seq ds_utility_var.seq_record_type;
      l_plunit VARCHAR2(100) := 'generate_identifiers('||NVL(TO_CHAR(p_set_id),'NULL')||')';
      r_tab ds_tables%ROWTYPE;
      FUNCTION get_table (p_table_id ds_tables.table_id%TYPE)
      RETURN ds_tables%ROWTYPE
      IS
         CURSOR c_tab IS
            SELECT *
              FROM ds_tables
             WHERE table_id = p_table_id
         ;
         r_tab ds_tables%ROWTYPE;
      BEGIN
         OPEN c_tab;
         FETCH c_tab INTO r_tab;
         CLOSE c_tab;
         RETURN r_tab;
      END;
   BEGIN
      IF NOT ds_utility_var.g_mask_data THEN
         RETURN;
      END IF;
      show_message('D','->'||l_plunit);
      FOR r_set IN c_set(p_set_id) LOOP
         show_message('D','Processing data set id '||r_set.set_id);
         l_col_name := ds_utility_var.g_seq.FIRST;
         WHILE l_col_name IS NOT NULL LOOP
            r_seq := ds_utility_var.g_seq(l_col_name);
            IF r_seq.msk_type = 'SEQUENCE' AND r_seq.sequence_name IS NOT NULL AND NOT get_boolean_option_value(r_seq.msk_options,'differ_masking',false) THEN
               IF r_seq.in_mem_seq_flag = 'Y' THEN
                  assert(ds_utility_var.g_in_mem_seq_tab.EXISTS(r_seq.sequence_name),'In memory sequence not found: '||r_seq.sequence_name);
                  l_fnc := 'ds_utility_krn.in_mem_seq_nextval('''||r_seq.table_name||'.'||r_seq.column_name||''')';
               ELSE
                  l_fnc := CASE WHEN INSTR(r_seq.sequence_name,'@')>0 THEN REPLACE(r_seq.sequence_name,'@','.nextval@') ELSE r_seq.sequence_name||'.nextval' END;
               END IF;
               r_tab := get_table(r_seq.table_id);
               l_sql :=
                  'INSERT INTO ds_identifiers (msk_id, old_id, new_id)'||CHR(10)
                ||'SELECT '||r_seq.msk_id||', '||r_tab.table_alias||'.'||r_seq.column_name||' old_id, '||l_fnc||' new_id'||CHR(10)
                ||build_join_statement (
                     p_purpose => 'DIRECT'
                   , p_op => 'I' --S???
                   , p_extract_type => r_tab.extract_type
                   , p_table_name => r_tab.table_name
                   , p_table_alias => r_tab.table_alias
                   , p_sel_columns => NULL
                   , p_table_id => r_tab.table_id
                   , p_pass_count => NULL
                   , p_set_id => r_tab.set_id
                   , p_order_by_clause => r_tab.order_by_clause
                   , p_source_schema => r_tab.source_schema
                   , p_target_db_link=>r_tab.target_db_link
                   , p_include_rowid=>FALSE
                  )||CHR(10)
                ||'   AND '||r_tab.table_alias||'.'||r_seq.column_name||' NOT IN ('||CHR(10)
                ||'      SELECT old_id'||CHR(10)
                ||'        FROM ds_identifiers'||CHR(10)
                ||'       WHERE msk_id = '||r_seq.msk_id||CHR(10)
                ||'   )';
               execute_immediate(l_sql);
            END IF;
            l_col_name := ds_utility_var.g_seq.NEXT(l_col_name);
         END LOOP;
      END LOOP;
      IF p_commit THEN
         COMMIT;
      END IF;
      show_message('D','<-'||l_plunit);
   END;
--#begin public
   ---
   -- Get an option value from a list of options
   ---
   FUNCTION get_string_option_value (
      p_list IN VARCHAR2 -- list of options
    , p_option IN VARCHAR2 -- searched option
    , p_default IN VARCHAR2 -- default value if not found
   )
   RETURN VARCHAR2
--#end public
   IS
      l_value VARCHAR2(4000);
   BEGIN
      l_value := REGEXP_REPLACE(p_list,'(.*)([^a-zA-Z0-9_-]+|^)'||p_option||'[ ]*=[ ]*([a-zA-Z0-9_-]+)(.*)','\3',1,0,'i');
      RETURN CASE WHEN p_list IS NULL OR l_value = p_list THEN p_default ELSE l_value END;
   END;
--#begin public
   ---
   -- Get an option value from a list of options
   ---
   FUNCTION get_boolean_option_value (
      p_list IN VARCHAR2 -- list of options
    , p_option IN VARCHAR2 -- searched option
    , p_default IN BOOLEAN -- default value if not found
   )
   RETURN BOOLEAN
--#end public
   IS
   BEGIN
      RETURN LOWER(get_string_option_value(p_list, p_option, CASE WHEN p_default THEN 'true' ELSE 'false' END)) IN ('true','yes','on'); --false, no, off
   END;
--#begin public
   ---
   -- Generate tokens for tokenized columns
   ---
   PROCEDURE generate_tokens (
      p_full_schema IN BOOLEAN := FALSE -- generate token for the whole schema
    , p_set_id IN ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
--#end public
   IS
      l_full_schema VARCHAR2(1) := CASE WHEN p_full_schema THEN 'Y' ELSE 'N' END;
      -- Cursor to browse columns that must be masked with tokenization
      CURSOR c_col IS
         SELECT ds_msk.*, ds_tab.table_id, ds_tab.extract_type
              , ds_tab.source_schema, ds_tab.source_db_link
           FROM ds_masks ds_msk
           LEFT OUTER JOIN ds_tables ds_tab
             ON ds_tab.table_name = ds_msk.table_name
            AND (p_set_id IS NULL OR ds_tab.set_id = p_set_id)
            AND ds_tab.extract_type != 'N'
           LEFT OUTER JOIN ds_data_sets ds_set
             ON ds_set.set_id = ds_tab.set_id
            AND ds_set.set_type = 'SUB'
            AND NVL(ds_set.disabled_flag,'N') = 'N'
          WHERE ds_msk.msk_type = 'TOKENIZE'
            AND ds_msk.params IS NOT NULL -- SQL expression needed
            AND NVL(ds_msk.disabled_flag,'N') = 'N'
            AND NVL(ds_msk.deleted_flag,'N') = 'N'
            AND NOT (ds_tab.set_id IS NOT NULL AND ds_set.set_id IS NULL)
            AND (l_full_schema = 'Y' OR ds_tab.set_id IS NOT NULL)
          ORDER BY ds_msk.table_name, ds_msk.column_name, ds_tab.set_id
         ;
      l_sql VARCHAR2(32767);
      l_join VARCHAR2(4000);
      l_order_by VARCHAR2(200);
      l_full_table_name ds_utility_var.g_long_name_type;
      l_plunit VARCHAR2(100) := 'generate_tokens()';
   BEGIN
      show_message('D','->'||l_plunit);
      IF NOT ds_utility_var.g_mask_data THEN
         show_message('D','<-'||l_plunit);
         RETURN;
      END IF;
      FOR r_col IN c_col LOOP
         l_full_table_name := gen_full_table_name(r_col.table_name,r_col.source_schema,r_col.source_db_link);
         show_message('D','Generating tokens for column '||r_col.table_name||'.'||r_col.column_name||'...');
         close_cursors;
         set_seed(p_seed);
         l_join := NULL;
         IF r_col.table_id IS NOT NULL AND r_col.extract_type != 'F' THEN
            l_join := REPLACE(q'#
       INNER JOIN ds_records rec
          ON rec.table_id = $table_id$
         AND rec.record_rowid = src.rowid
         AND NVL(rec.deleted_flag,'N') = 'N'#','$table_id$',r_col.table_id);
            END IF;
         l_order_by := NULL;
         IF p_seed IS NOT NULL THEN
            l_order_by := '
       ORDER BY ' || get_pk_columns(p_table_name=>r_col.table_name, p_table_alias=>'src');
         END IF;
         l_sql := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(q'#
DECLARE
   CURSOR c_src IS
      SELECT TO_CHAR(src.$column_name_lc$) value, $msk_params$ token
        FROM $table_name_lc$ src$join$
       WHERE src.$column_name_lc$ IS NOT NULL
         AND ds_utility_krn.get_token_from_value($msk_id$,TO_CHAR(src.$column_name_lc$)) IS NULL$order_by$
   ;
   l_value ds_tokens.value%TYPE;
   l_enforce_uniqueness BOOLEAN := ds_utility_krn.get_boolean_option_value(q'µ$msk_options$µ','enforce_uniqueness',true);  -- are tokens unique? default: yes
   l_allow_equal_value  BOOLEAN := ds_utility_krn.get_boolean_option_value(q'µ$msk_options$µ','allow_equal_value', false); -- can token be identical to value? default: no
   l_stop BOOLEAN := FALSE;
   l_count PLS_INTEGER := 0;
   l_ok BOOLEAN;
BEGIN
   WHILE NOT l_stop AND l_count < 100 LOOP
      l_count := l_count + 1;
      l_stop := TRUE;
      FOR r_src IN c_src LOOP
         l_ok := (l_allow_equal_value OR r_src.token != r_src.value)
             AND (NOT l_enforce_uniqueness OR ds_utility_krn.get_value_from_token($msk_id$,r_src.token) IS NULL);
--         dbms_output.put_line('value='||r_src.value||', token='||r_src.token||': '||CASE WHEN l_ok THEN 'ok' ELSE 'ko' END);
         IF l_ok THEN
            IF ds_utility_krn.get_token_from_value($msk_id$,TO_CHAR(r_src.value)) IS NULL THEN
               l_value := CASE WHEN ds_utility_var.g_encrypt_tokenized_values THEN ds_masker_krn.encrypt_string(r_src.value) ELSE r_src.value END;
               INSERT INTO ds_tokens (
                  msk_id, token, value
               ) VALUES (
                  $msk_id$, r_src.token, l_value
               );
            END IF;
         ELSE
            l_stop := FALSE;
         END IF;
      END LOOP;
   END LOOP;
   IF l_count >= 100 THEN
      raise_application_error(-20000,'Error: unable to generate unique tokens for $table_name$.$column_name$ after 100 attempts');
   END IF;
END;#','$msk_params$',replace_i(r_col.params,'SEED','rownum')),'$table_name$',r_col.table_name),'$column_name$',r_col.column_name)
      ,'$msk_id$',r_col.msk_id),'$table_id',r_col.table_id),'$join$',l_join),'$order_by$',l_order_by)
      ,'$msk_options$',r_col.options),'$table_name_lc$',LOWER(l_full_table_name)),'$column_name_lc$',LOWER(r_col.column_name));
         execute_immediate(l_sql);
         reset_seed(p_seed);
      END LOOP;
      IF p_commit THEN
         COMMIT;
      END IF;
      show_message('D','<-'||l_plunit);
   END;
   ---
   -- Generate records
   ---
   FUNCTION generate_table_records (
      r_tab IN ds_tables%ROWTYPE
    , r_con IN ds_constraints%ROWTYPE
    , r_src_tab IN ds_tables%ROWTYPE
    , p_commit IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_sql VARCHAR2(32767);
      l_val VARCHAR2(4000);
      l_table_name VARCHAR2(100);
      l_gen_view_name ds_tables.gen_view_name%TYPE;
      l_full_table_name VARCHAR2(100);
      l_parent_table_name VARCHAR2(100);
      l_ins_columns ds_tables.columns_list%TYPE;
      l_non_final_count PLS_INTEGER;
      l_prev_non_final_count PLS_INTEGER;
      l_level_min ds_constraints.level_count%TYPE;
      l_level_max ds_constraints.level_count%TYPE;
      l_select VARCHAR2(200);
      l_rowcount_init VARCHAR2(200);
      l_sep VARCHAR2(100);
      t_pk_cols ds_utility_var.column_name_table;
--      t_uk_cols ds_utility_var.column_name_table;
--      t_fk_cols ds_utility_var.column_name_table;
      l_proc_name VARCHAR2(20);
      -- Cursor to get fk of a table
      CURSOR c_fk IS
         SELECT con.constraint_name
              , LOWER(con.constraint_name) constraint_name_lc
              , LOWER(con.table_name) table_name
              , ds_tab.target_schema
              , ds_tab.target_db_link
              , LOWER(rcon.table_name) r_table_name
              , ds_rtab.target_schema r_target_schema
              , ds_rtab.target_db_link r_target_db_link
              , ds_con.where_clause
              , ds_con.batch_size
              , ds_rtab.table_id r_table_id
              , ds_rtab.extract_type r_extract_type
              , 'TOP' location
           FROM sys.all_constraints con
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = r_tab.set_id
            AND ds_tab.table_name = r_tab.table_name
            AND ds_tab.extract_type IN ('B','P')
          INNER JOIN sys.all_constraints rcon
             ON rcon.owner = con.owner
            AND rcon.constraint_name = con.r_constraint_name
          INNER JOIN ds_tables ds_rtab
             ON ds_rtab.set_id = r_tab.set_id
            AND ds_rtab.table_name = rcon.table_name
          INNER JOIN ds_constraints ds_con
             ON ds_con.set_id = ds_tab.set_id
            AND ds_con.constraint_name = con.constraint_name
            AND ds_con.cardinality = 'N-1'
            AND ds_con.extract_type IN ('B','P')
          WHERE con.owner = NVL(ds_utility_var.g_owner,USER)
            AND con.table_name = r_tab.table_name
            AND con.constraint_type = 'R'
            AND NOT (NVL(r_con.cardinality,'NULL') = '1-N' AND r_con.constraint_name = con.constraint_name) -- not the parent foreign key
            AND ((r_con.cardinality = 'N-1' AND con.table_name = rcon.table_name) -- update for pig's ear N-1 fk
              OR (NVL(r_con.cardinality,'1-N') = '1-N' AND con.table_name != rcon.table_name)) -- base or master/detail and not pig's ear
          ORDER BY ds_con.con_seq, ds_con.constraint_name
      ;
      -- Cursor to get column properties of a table
      CURSOR c_col IS
         SELECT LOWER(ds_tab.table_name) tab_name
              , LOWER(ds_col.col_name) col_name
              , col.nullable
              , ds_col.null_value_pct
              , ds_col.null_value_condition
              , ds_col.params
              , CASE WHEN ds_col.params = r_con.constraint_name AND r_con.cardinality = '1-N' THEN 'DFK' /*Driving FK*/ ELSE ds_col.gen_type END gen_type
              , con.constraint_name cons_name 
              , LOWER(rcon.table_name) r_tab_name
              , LOWER(rccol.column_name) r_col_name
              , CAST(NULL AS VARCHAR2(4000)) col_val
              , 'N' is_final
           FROM ds_tab_columns ds_col
          INNER JOIN ds_tables ds_tab
             ON ds_tab.table_id = ds_col.table_id
          INNER JOIN sys.all_tab_columns col
             ON col.owner = NVL(ds_utility_var.g_owner,USER)
            AND col.table_name = ds_tab.table_name
            AND col.column_name = ds_col.col_name
           LEFT OUTER JOIN ds_constraints ds_con
             ON ds_col.gen_type = 'FK'
            AND ds_con.set_id = r_tab.set_id
            AND ds_con.constraint_name = ds_col.params
            AND ds_con.cardinality = 'N-1'
           LEFT OUTER JOIN sys.all_constraints con
             ON con.owner = col.owner
            AND con.constraint_name = ds_col.params
            AND ds_col.gen_type = 'FK'
           LEFT OUTER JOIN sys.all_cons_columns ccol
             ON ccol.owner = con.owner
            AND ccol.constraint_name = con.constraint_name
            AND ccol.column_name = col.column_name
           LEFT OUTER JOIN sys.all_constraints rcon
             ON rcon.owner = con.owner
            AND rcon.constraint_name = con.r_constraint_name
           LEFT OUTER JOIN sys.all_cons_columns rccol
             ON rccol.owner = rcon.owner
            AND rccol.constraint_name = rcon.constraint_name
            AND rccol.position = ccol.position
          WHERE ds_col.table_id = r_tab.table_id
          ORDER BY ds_col.col_seq
      ;
      TYPE t_fk_type IS TABLE OF c_fk%ROWTYPE INDEX BY BINARY_INTEGER;
      t_fk t_fk_type;
      r_fk c_fk%ROWTYPE;
      TYPE t_col_type IS TABLE OF c_col%ROWTYPE INDEX BY BINARY_INTEGER;
      t_col t_col_type;
      r_col c_col%ROWTYPE;
      -- Replace keywords
      FUNCTION replace_kw (p_sql IN VARCHAR2)
      RETURN VARCHAR2
      IS
      BEGIN
         RETURN REPLACE(replace_i(replace_i(replace_i(replace_i(replace_i(replace_i(replace_i(replace_i(replace_i(replace_i(p_sql
           ,'LAG ','r_lag.')
           ,'RECORD ','r_')
           ,'SOURCE ','r_src.')
           ,'PARENT ','r_src.')
           ,'MASTER ','r_src.')
           ,'PRIOR ','r_src.')
           ,'LEVEL','l_level')
           ,'ROWNUM','r_gen.row#')
           ,'ROWCOUNT','l_rowcount')
           ,'SEED','l_seed')
           ,CHR(10),CHR(10)||RPAD(' ',17+2));
      END;
      -- Replace vars
      FUNCTION replace_vars (
         p_col_val IN VARCHAR2
       , p_col_rec IN OUT c_col%ROWTYPE -- (includes column type)
      )
      RETURN VARCHAR2
      IS
         l_name VARCHAR2(100);
         l_col_val VARCHAR2(32767);
         l_pos_from PLS_INTEGER := 1;
         l_pos_to PLS_INTEGER;
         l_len PLS_INTEGER;
         l_ch VARCHAR2(1 CHAR);
         r_col_rec c_col%ROWTYPE;
         l_cnt PLS_INTEGER := 0;
      BEGIN
         l_col_val := p_col_val;
         WHILE TRUE LOOP
            -- Search for bind variable (e.g. :var)
            WHILE TRUE LOOP
               l_ch := SUBSTR(l_col_val,l_pos_from,1);
               EXIT WHEN l_ch IS NULL OR l_ch = ':';
               IF l_ch = '''' THEN
                  WHILE TRUE LOOP
                     l_pos_from := l_pos_from + 1;
                     l_ch := SUBSTR(l_col_val,l_pos_from,1);
                     EXIT WHEN l_ch IS NULL OR l_ch = '''';
                  END LOOP;
                  assert(l_ch = '''','Unterminated string in SQL expression for '||UPPER(p_col_rec.tab_name)||'.'||UPPER(p_col_rec.col_name));
               END IF;
               l_pos_from := l_pos_from + 1;
            END LOOP;
            EXIT WHEN l_ch IS NULL OR l_ch != ':';
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
            l_len := l_pos_to - l_pos_from;
            l_name := LOWER(SUBSTR(l_col_val,l_pos_from+1,l_len-1));
            assert(l_name!=p_col_rec.col_name,'Self reference in SQL expression for '||UPPER(p_col_rec.tab_name)||'.'||UPPER(p_col_rec.col_name));
            IF l_name IS NOT NULL THEN
               assert(ds_utility_var.g_pos_tab.EXISTS(l_name),'Invalid bind variable ":'||l_name||'"!');
               r_col_rec := t_col(ds_utility_var.g_pos_tab(l_name));
               IF r_col_rec.is_final = 'N' THEN
                  -- Do not replace bind variable if not processed yet
                  l_cnt := l_cnt + 1;
                  EXIT;
               ELSE
                  -- Replace bind variable with column value
                  l_col_val := SUBSTR(l_col_val,1,l_pos_from-1) -- part before :var
                            || r_col_rec.col_val -- :var part
                            || SUBSTR(l_col_val,l_pos_to); -- part after :var
                  l_len := LENGTH(r_col_rec.col_val);
                  END IF;
            END IF;
         END LOOP;
         IF l_cnt = 0 THEN
            p_col_rec.is_final := 'Y';
         ELSE
            -- Rollback changes
            l_col_val := p_col_rec.col_val;
         END IF;
         RETURN l_col_val;
      END;
      -- Format PRE/POST-GEN code
      FUNCTION format_gen_code (
         p_gen_code IN VARCHAR2
       , p_comment IN VARCHAR2 := NULL
      )
      RETURN VARCHAR2
      IS
         l_ident VARCHAR2(3) := LPAD(' ',3,' ');
      BEGIN
         -- Remove leading/trailing LF
         -- Indent each line by 3 characters
         -- Add missing ";" at the end
         RETURN CHR(10)||CASE WHEN p_comment IS NOT NULL THEN l_ident||'--'||p_comment||CHR(10) END
             || l_ident||TRIM(TRAILING ';' FROM REPLACE(TRIM(CHR(10) FROM p_gen_code),CHR(10),CHR(10)||l_ident))||';';
      END;
      -- Generate code at given location for opening/getting record from/closing foreign key cursor
      FUNCTION gen_fk_cursor_action (p_location IN VARCHAR2, p_action IN VARCHAR2, p_indent IN PLS_INTEGER)
      RETURN VARCHAR2
      IS
         l_sql VARCHAR2(4000);
         l_cnt VARCHAR2(100);
      BEGIN
         FOR l_fk IN 1..t_fk.COUNT LOOP
            r_fk := t_fk(l_fk);
            IF r_fk.location = p_location THEN
               IF p_action = 'open' THEN
                  -- Determine maxiumm number of fk records to fetch
                  IF p_location = 'GEN' THEN
                     l_cnt := 'NVL(l_row_count,k_max_'||r_fk.constraint_name_lc||')';
                  ELSE
                     l_cnt := 'k_max_'||r_fk.constraint_name_lc;
                  END IF;
                  l_sql := l_sql || CHR(10) || RPAD(' ',p_indent,' ') || 'l_max_'||r_fk.constraint_name_lc||' := '||l_cnt||';';
               END IF;
               l_sql := l_sql || CHR(10) || RPAD(' ',p_indent,' ') || p_action ||'_'||r_fk.constraint_name_lc||';';
            END IF;
         END LOOP;
         RETURN l_sql;
      END;
      PROCEDURE gen_batch_vars (
         p_name IN VARCHAR2
       , p_tab_name IN VARCHAR2
       , p_select IN VARCHAR2
       , p_batch_size IN NUMBER
      )
      IS
      BEGIN
         l_sql := l_sql || REPLACE('
   -- Types and variables for $name$
   CURSOR c_$name$ IS '||p_select||';
   TYPE t_$name$_type IS TABLE OF '||p_tab_name||'%ROWTYPE INDEX BY BINARY_INTEGER;
   t_$name$ t_$name$_type; -- memory table cashing fk records
   r_$name$ '||p_tab_name||'%ROWTYPE; -- current fk record
   l_fnd_$name$ BOOLEAN := FALSE; -- was a record found during last get?
   l_tot_$name$ PLS_INTEGER := 0; -- total number of records fetched so far
   l_idx_$name$ PLS_INTEGER := 0; -- index of next record to get from table
   k_max_$name$ CONSTANT PLS_INTEGER := '||p_batch_size||'; -- defautl batch size
   l_max_$name$ PLS_INTEGER := k_max_$name$; -- actual batch size','$name$',p_name);
      END;
      PROCEDURE gen_batch_procs (
         p_name IN VARCHAR2
       , p_cycle IN BOOLEAN
      )
      IS
      BEGIN
         l_sql := l_sql || REPLACE(q'#
   -- Procedures for $name$
   PROCEDURE open_$name$ (p_open BOOLEAN := TRUE) IS
   BEGIN
      t_$name$.DELETE;
      IF p_open THEN
         OPEN c_$name$;
      END IF;
      FETCH c_$name$ BULK COLLECT INTO t_$name$ LIMIT l_max_$name$;
      l_tot_$name$ := l_tot_$name$ + t_$name$.COUNT;
    --dbms_output.put_line('open_$name$: fetched '||t_$name$.COUNT||' records, total is '||l_tot_$name$);
      l_idx_$name$ := 1;
   END;
   PROCEDURE close_$name$ IS
   BEGIN
      CLOSE c_$name$;
      t_$name$.DELETE;
    --dbms_output.put_line('close_$name$: total fetched was '||l_tot_$name$||' records');
      l_tot_$name$ := 0;
   END;
   PROCEDURE fetch_$name$ IS
   BEGIN#'||CASE WHEN NOT p_cycle THEN q'#
      IF t_$name$.COUNT >= l_max_$name$ THEN
         open_$name$(FALSE);
      END IF;#' ELSE q'#
      IF t_$name$.COUNT < l_max_$name$ THEN
         close_$name$;
         open_$name$;
      ELSE
         open_$name$(FALSE);
         IF t_$name$.COUNT = 0 THEN
            close_$name$;
            open_$name$;
         END IF;
      END IF;#' END||q'#
   END;
   PROCEDURE get_$name$ IS
   BEGIN
      r_$name$ := NULL;
      l_fnd_$name$ := FALSE;
      IF l_tot_$name$ > 0 THEN
         IF l_idx_$name$ > t_$name$.COUNT THEN
            IF l_tot_$name$ < l_max_$name$ THEN -- all in memory
               #'||CASE WHEN p_cycle THEN 'l_idx_$name$ := 1' ELSE 'NULL' END||q'#;
            ELSE
               fetch_$name$;
            END IF;
         END IF;
         IF l_idx_$name$ <= t_$name$.COUNT THEN
            r_$name$ := t_$name$(l_idx_$name$);
            l_fnd_$name$ := TRUE;
            l_idx_$name$ := l_idx_$name$ + 1;
         END IF;
      END IF;
   END;#','$name$',p_name);
      END;
   BEGIN
      -- Prepare
      l_full_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,r_tab.target_db_link);
      l_table_name := LOWER(r_tab.table_name);
--      l_parent_table_name := LOWER(r_src_tab.table_name);
      l_parent_table_name := LOWER(gen_full_table_name(NVL(r_src_tab.target_table_name,r_src_tab.table_name),r_src_tab.target_schema,r_src_tab.target_db_link));
      l_ins_columns := normalise_columns_list(r_tab.table_name,'*');
      IF r_con.cardinality = '1-N' AND r_con.src_table_name = r_con.dst_table_name /*pig's ear*/ THEN
         l_level_min := 2;
         l_level_max := r_con.level_count;
      ELSE
         l_level_min := 1;
         l_level_max := 1;
      END IF;
      -- Fetch all table columns
      OPEN c_col;
      FETCH c_col BULK COLLECT INTO t_col;
      CLOSE c_col;
      -- Fetch all foreign keys (N-1 constraints)
      OPEN c_fk;
      FETCH c_fk BULK COLLECT INTO t_fk;
      CLOSE c_fk;
      -- Generate comment
      IF r_con.cardinality IS NULL THEN
         l_sql := '-- Generate records in base/driving table "'||r_tab.table_name||'"';
         l_gen_view_name := r_tab.gen_view_name;
      ELSIF r_con.cardinality = '1-N' THEN
         l_sql := '-- Generate records in detail table "'||r_tab.table_name||'" from master table "'||r_src_tab.table_name||'" via fk "'||r_con.constraint_name||'"';
         l_gen_view_name := r_con.gen_view_name;
      ELSIF r_con.cardinality = 'N-1' THEN
         l_sql := '-- Update records in table "'||r_tab.table_name||'" for recursive fk "'||r_con.constraint_name||'"';
         l_gen_view_name := NULL;
      END IF;
      -- Build PL/SQL block
      l_sql := l_sql || '
DECLARE
   TYPE t_tgt_type IS TABLE OF '||l_full_table_name||'%ROWTYPE INDEX BY BINARY_INTEGER;
   t_tgt t_tgt_type; -- memory table for bulk inserting records in target table
   l_seed VARCHAR2(20); -- seed for random generation (value for SEED keyword)
   l_rowcount PLS_INTEGER; -- number of records to be generated (value for ROWCOUNT keyword)
   l_tot_count PLS_INTEGER := 0; -- number of records inserted or updated so far
   r_tgt '||l_full_table_name||'%ROWTYPE; -- current target record
   r_lag '||l_full_table_name||'%ROWTYPE; -- previsous target record';
      IF l_gen_view_name IS NOT NULL THEN
         l_sql := l_sql || '
   l_gen_view_count PLS_INTEGER; -- number of records in generation view
   l_lst_view_count PLS_INTEGER; -- previous number fo records in gen view';
      END IF;
      l_sql := l_sql || '
   l_level PLS_INTEGER; -- current hierarchic level';
      IF r_con.constraint_name IS NOT NULL THEN
         l_select := 'SELECT src.* FROM '||l_parent_table_name||' src INNER JOIN ds_records rec ON rec.table_id='||r_src_tab.table_id||' AND rec.record_rowid=src.rowid'
                    ||CASE WHEN l_level_min>1 THEN ' AND rec.pass_count=l_level-1' END||CASE WHEN r_con.src_filter IS NOT NULL THEN ' WHERE '||r_con.src_filter END;
         IF r_con.row_limit IS NOT NULL THEN
            l_select := 'SELECT * FROM ('||l_select||') WHERE rownum<='||r_con.row_limit;
         END IF;
         gen_batch_vars(
            p_name=>'src'
          , p_tab_name=>'c_src'
          , p_select=>l_select
          , p_batch_size=>NVL(r_tab.batch_size,101)
         );
      ELSE
         l_sql := l_sql ||'
   r_src '||l_full_table_name||'%ROWTYPE; -- current source/parent record';
      END IF;
      IF l_gen_view_name IS NOT NULL THEN
         l_select := 'SELECT * FROM '||LOWER(l_gen_view_name)||' WHERE l_rowcount IS NULL OR rownum<=l_rowcount'; -- note: view must contain a "row#" column
      ELSE
         l_select := 'SELECT LEVEL row# FROM sys.dual WHERE rownum<=l_rowcount CONNECT BY LEVEL<=l_rowcount';
      END IF;
      IF NVL(r_con.cardinality,'1-N') = '1-N' THEN
         gen_batch_vars(
            p_name=>'gen'
          , p_tab_name=>'c_gen'
          , p_select=>l_select
          , p_batch_size=>101 /*TBD: parameter?*/
         );
      END IF;
      IF r_con.cardinality = 'N-1' THEN
         l_proc_name := 'update_tgt';
         t_pk_cols := tokenize_columns_list(get_pk_columns(r_tab.table_name));
         FOR i IN 1..t_pk_cols.COUNT LOOP
            l_sql := l_sql || '
   TYPE t_'||t_pk_cols(i)||'_type IS TABLE OF '||l_full_table_name||'.'||t_pk_cols(i)||'%TYPE INDEX BY BINARY_INTEGER;
   t_'||t_pk_cols(i)||' t_'||t_pk_cols(i)||'_type; -- memory table of primary keys for bulk update';
         END LOOP;
      END IF;
      -- Initialize index table (by column name)
      ds_utility_var.g_pos_tab.DELETE;
      FOR i IN 1..t_col.COUNT LOOP
         r_col := t_col(i);
         ds_utility_var.g_pos_tab(r_col.col_name) := i;
      END LOOP;
      FOR l_fk IN 1..t_fk.COUNT LOOP
         r_fk := t_fk(l_fk);
--   r_'||r_fk.constraint_name_lc||' '||r_fk.r_table_name||'%ROWTYPE;';
         l_select := 'SELECT fkt.* FROM '||gen_full_table_name(r_fk.r_table_name,r_fk.r_target_schema,r_fk.r_target_db_link) || ' fkt';
         IF r_fk.r_extract_type IN ('B','P') THEN
            -- Select only reference records generated in this data set
            l_select := l_select || ' INNER JOIN ds_records rec ON rec.table_id='||r_fk.r_table_id||' AND rec.record_rowid=fkt.rowid';
         END IF;
         IF r_fk.where_clause IS NOT NULL THEN
            l_select := l_select || ' WHERE '||replace_kw(r_fk.where_clause);
         END IF;
         l_select := l_select || ' ORDER BY sys.dbms_random.value';
         -- Determine location in the code where cursor must be opened/closed depending on where clause (TOP by default)
         IF INSTR(l_select,'r_gen.')>0 OR INSTR(l_select,'r_lag.')>0 THEN
            r_fk.location := 'GEN';
         ELSIF INSTR(l_select,'r_src.')>0 THEN
            r_fk.location := 'SRC';
         ELSIF INSTR(l_select,'l_level')>0 THEN
            r_fk.location := 'LVL';
         END IF;
         IF r_fk.location != 'TOP' THEN
            t_fk(l_fk) := r_fk;
         END IF;
         gen_batch_vars(
            p_name=>r_fk.constraint_name_lc
          , p_tab_name=>gen_full_table_name(r_fk.r_table_name, r_fk.r_target_schema, r_fk.r_target_db_link)
          , p_select=>l_select
          , p_batch_size=>NVL(r_fk.batch_size,101)
         );
      END LOOP;
      IF r_con.constraint_name IS NOT NULL THEN
         gen_batch_procs(p_name=>'src', p_cycle=>FALSE);
      END IF;
      IF NVL(r_con.cardinality,'1-N') = '1-N' THEN
         gen_batch_procs(p_name=>'gen', p_cycle=>FALSE);
      END IF;
      FOR l_fk IN 1..t_fk.COUNT LOOP
         r_fk := t_fk(l_fk);
         gen_batch_procs(p_name=>r_fk.constraint_name_lc, p_cycle=>TRUE);
      END LOOP;
      IF r_con.cardinality = 'N-1' THEN
         l_sql := l_sql || '
   -- Update records by block
   PROCEDURE update_tgt (
      l_pass IN PLS_INTEGER := 1
   )
   IS
      TYPE t_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
      t_rowid t_rowid_type;
   BEGIN
      -- Update records in target table
      FORALL i IN 1..t_tgt.COUNT
         UPDATE '||l_full_table_name||' SET ROW = t_tgt(i)
          WHERE ';
         FOR i IN 1..t_pk_cols.COUNT LOOP
            IF i > 1 THEN
               l_sql := l_sql||'
            AND ';
            END IF;
            l_sql := l_sql || t_pk_cols(i) || ' = t_' ||t_pk_cols(i)||'(i)';
         END LOOP;
         l_sql := l_sql ||'
         RETURNING ROWID BULK COLLECT INTO t_rowid
         ;
      l_tot_count := l_tot_count + t_tgt.COUNT;
      FORALL i IN 1..t_rowid.COUNT
         UPDATE ds_records
            SET con_id = '||NVL(TO_CHAR(r_con.con_id),'NULL')||'
          WHERE record_rowid = t_rowid(i);
      t_rowid.DELETE;
      t_tgt.DELETE;';
      FOR i IN 1..t_pk_cols.COUNT LOOP
         l_sql := l_sql || '
      t_'||t_pk_cols(i)||'.DELETE;';
      END LOOP;
      l_sql := l_sql ||'
   END;';
      ELSE
         l_proc_name := 'insert_tgt';
         l_sql := l_sql || '
   -- Insert records by block
   PROCEDURE insert_tgt (
      l_pass IN PLS_INTEGER := 1
   )
   IS
      TYPE t_rec_type IS TABLE OF ds_records%ROWTYPE INDEX BY BINARY_INTEGER;
      t_rec t_rec_type;
      r_rec ds_records%ROWTYPE;
      TYPE t_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
      t_rowid t_rowid_type;
      l_count PLS_INTEGER := 0;
   BEGIN
      -- Generate records in target table
      FORALL i IN 1..t_tgt.COUNT
         INSERT INTO '||l_full_table_name||' VALUES t_tgt(i)
         RETURNING ROWID BULK COLLECT INTO t_rowid;
      l_tot_count := l_tot_count + t_tgt.COUNT;
      t_tgt.DELETE;
      -- Prepare rowids
      t_rec.DELETE;
      l_count := 0;
      FOR i IN 1..t_rowid.COUNT LOOP
         l_count := l_count + 1;
         r_rec.rec_id := ds_rec_seq.nextval;
         r_rec.table_id := '||r_tab.table_id||';
         r_rec.con_id := '||NVL(TO_CHAR(r_con.con_id),'NULL')||';
         r_rec.seq := l_count;
         r_rec.pass_count := l_pass;
         r_rec.record_rowid := t_rowid(i);
         t_rec(i) := r_rec;
      END LOOP;
      -- Register record rowids
      FORALL i IN 1..t_rec.COUNT
         INSERT INTO ds_records VALUES t_rec(i);
      t_rec.DELETE;
   END;';
      END IF;
      l_sql := l_sql || '
BEGIN';
     -- Generate pre-generation code
      IF r_con.cardinality IS NULL THEN
         IF r_tab.pre_gen_code IS NOT NULL THEN
            l_sql := l_sql || format_gen_code(r_tab.pre_gen_code,'Pre-generation code for table "'||r_tab.table_name||'"');
         END IF;
      ELSE
         IF r_con.pre_gen_code IS NOT NULL THEN
            l_sql := l_sql || format_gen_code(r_con.pre_gen_code,'Pre-generation code for constraint "'||r_con.constraint_name||'"');
         END IF;
      END IF;
      -- Define the (random) number of records to be generated
      l_rowcount_init := NULL;
      IF r_con.cardinality IS NULL THEN
         IF l_gen_view_name IS NULL THEN
            l_rowcount_init := TO_CHAR(NVL(r_tab.row_count,0));
         END IF;
      ELSIF r_con.cardinality = 'N-1' THEN
         l_rowcount_init := 'NULL';
      ELSE
         IF l_gen_view_name IS NULL OR r_con.min_rows IS NOT NULL OR r_con.max_rows IS NOT NULL THEN
            l_rowcount_init := 'ds_masker_krn.random_integer('||TO_CHAR(NVL(r_con.min_rows,0))||','||TO_CHAR(NVL(r_con.max_rows,NVL(r_con.min_rows,0)))||')';
         END IF;
      END IF;
      IF l_gen_view_name IS NOT NULL AND NVL(r_con.cardinality,'1-N') = '1-N' THEN
         IF l_rowcount_init IS NULL THEN
            l_rowcount_init := 'l_gen_view_count';
         ELSE
            l_rowcount_init := 'LEAST(l_gen_view_count,'||l_rowcount_init||')';
         END IF;
      END IF;
      l_rowcount_init := '
         l_rowcount := '||l_rowcount_init||';';
      IF l_gen_view_name IS NOT NULL THEN
         l_sql := l_sql ||'
   -- Count records in the generation view, several times to determine if it is a random view or not
   FOR i IN 1..3 LOOP
      l_lst_view_count := l_gen_view_count;
      SELECT COUNT(*) INTO l_gen_view_count FROM '||LOWER(l_gen_view_name)||';
      IF i > 1 AND l_gen_view_count != l_lst_view_count THEN
         l_gen_view_count := NULL;
         EXIT;
      END IF;
   END LOOP;';
      END IF;
      l_sql := l_sql || gen_fk_cursor_action('TOP', 'open', 3);
      IF r_con.constraint_name IS NULL THEN
         l_sql := l_sql ||'
   -- Base table (generated without needing a parent table)
   l_level := 1;
   WHILE l_level <= 1 LOOP';
         l_sql := l_sql || gen_fk_cursor_action('LVL', 'open', 6); -- here becaue only 1 level
         l_sql := l_sql ||'
    --FOR r_src -- no source for parent table
         r_lag := NULL;';
         l_sql := l_sql || l_rowcount_init;
         l_sql := l_sql || gen_fk_cursor_action('SRC', 'open', 9);
         l_sql := l_sql || '
         open_gen;
         LOOP
            get_gen;
            EXIT WHEN NOT l_fnd_gen;';
         l_sql := l_sql || gen_fk_cursor_action('GEN', 'open', 12);
      ELSE
         l_sql := l_sql ||'
   -- Detail table (linked to parent via fk)
   l_level := '||l_level_min||';
   WHILE l_level <= '||l_level_max||' LOOP -- for recursive FKs only, one iteration per hierarchy level (root level already processed)';
         l_sql := l_sql || gen_fk_cursor_action('LVL', 'open', 6);
         l_sql := l_sql ||'
      open_src;
      LOOP
         get_src;
         EXIT WHEN NOT l_fnd_src;
         r_lag := NULL;';
         l_sql := l_sql || l_rowcount_init;
         l_sql := l_sql || gen_fk_cursor_action('SRC', 'open', 9);
         IF r_con.cardinality = '1-N' THEN
            l_sql := l_sql ||'
         OPEN c_gen;
         LOOP
            r_gen := NULL;
            FETCH c_gen INTO r_gen;
            EXIT WHEN c_gen%NOTFOUND;';
            l_sql := l_sql || gen_fk_cursor_action('GEN', 'open', 12);
         ELSE
            l_sql := l_sql ||'
         --FOR r_gen -- no record generation';
         END IF;
      END IF;
      l_sql := l_sql || q'#
            l_seed := TO_CHAR(SYSTIMESTAMP,ds_utility_var.g_default_seed_format);
            r_tgt := NULL;#';
      FOR l_fk IN 1..t_fk.COUNT LOOP
         r_fk := t_fk(l_fk);
         l_sql := l_sql || '
            r_'||r_fk.constraint_name_lc||' := NULL;';
      END LOOP;
      -- Get random value from FK
      FOR l_fk IN 1..t_fk.COUNT LOOP
         r_fk := t_fk(l_fk);
         l_sql := l_sql || '
            get_'||r_fk.constraint_name_lc||';';
      END LOOP;
      -- Handle pig's ear
      IF r_con.cardinality = 'N-1' THEN
         FOR i IN 1..t_col.COUNT LOOP
            r_col := t_col(i);
            r_col.col_val := CASE WHEN r_col.cons_name = r_con.constraint_name
                             THEN 'r_' || LOWER(r_col.cons_name) || '.' ||r_col.r_col_name
                             ELSE 'r_src.'|| r_col.col_name
                             END;
            r_col.is_final := 'Y';
            t_col(i) := r_col;
         END LOOP;
      ELSE
         -- Generate column values based on their generation type
         l_non_final_count := 0;
         FOR i IN 1..t_col.COUNT LOOP
            r_col := t_col(i);
            r_col.is_final := 'Y';
            IF r_col.gen_type = 'SEQ' THEN
               r_col.col_val := LOWER(r_col.params) || '.nextval';
            ELSIF r_col.gen_type = 'FK' THEN
               r_col.col_val := 'r_' || LOWER(r_col.cons_name) || '.' ||r_col.r_col_name; -- value generated before
            ELSIF r_col.gen_type = 'DFK' THEN
               r_col.col_val := 'r_src.' || r_col.r_col_name; -- value from parent table
            ELSIF r_col.gen_type = 'SQL' THEN
               r_col.col_val := replace_kw(r_col.params);
               r_col.is_final := 'N';
               l_non_final_count := l_non_final_count + 1;
            ELSE
               r_col.col_val := 'NULL';
            END IF;
            IF r_col.cons_name IS NOT NULL AND r_col.tab_name = r_col.r_tab_name AND l_level_max = 1 THEN
               r_col.col_val := 'NULL';
               r_col.null_value_pct := NULL;
               r_col.null_value_condition := NULL;
            END IF;
            t_col(i) := r_col;
         END LOOP;
         -- Replace vars (several passes may be needed to take into account dependencies)
         WHILE l_non_final_count > 0 LOOP
            l_prev_non_final_count := l_non_final_count;
            l_non_final_count := 0;
            FOR i IN 1..t_col.COUNT LOOP
               r_col := t_col(i);
               r_col.col_val := replace_vars(r_col.col_val, r_col);
               IF r_col.is_final = 'N' THEN
                  l_non_final_count := l_non_final_count + 1;
               END IF;
               t_col(i) := r_col;
            END LOOP;
            -- Non final count must decrease at each iteration
            assert(l_non_final_count<l_prev_non_final_count,'Loop detected in variable dependencies');
         END LOOP;
      END IF;
      -- Handle NULL options
      FOR i IN 1..t_col.COUNT LOOP
         r_col := t_col(i);
         IF NVL(r_con.cardinality,'NULL') != 'N-1' OR r_col.cons_name = r_con.constraint_name THEN
            IF r_col.nullable = 'Y' THEN
               IF NVL(r_col.null_value_pct,0) > 0 THEN
                  r_col.col_val := 'CASE WHEN ds_masker_krn.random_integer(1,100) BETWEEN 1 AND '||r_col.null_value_pct||' THEN NULL ELSE '||r_col.col_val||' END';
               END IF;
               IF r_col.null_value_condition IS NOT NULL THEN
                  r_col.col_val := 'CASE WHEN '||replace_vars(replace_kw(r_col.null_value_condition),r_col)||' THEN NULL ELSE '||r_col.col_val||' END';
               END IF;
            END IF;
            t_col(i) := r_col;
         END IF;
      END LOOP;
      l_sep := CHR(10) || RPAD(' ',12,' ');
      FOR i IN 1..t_col.COUNT LOOP
         r_col := t_col(i);
         l_sql := l_sql || l_sep ||'r_tgt.' || r_col.col_name || ' := ' ||r_col.col_val || ';';
      END LOOP;
      FOR i IN 1..t_pk_cols.COUNT LOOP
         l_sql := l_sql || '
            t_'||t_pk_cols(i)||'(t_'||t_pk_cols(i)||'.COUNT+1) := r_tgt.'||t_pk_cols(i)||';';
      END LOOP;
      l_sql := l_sql || '
            r_lag := r_tgt;
            t_tgt(t_tgt.COUNT+1) := r_tgt;
            IF t_tgt.COUNT>='||NVL(r_tab.batch_size,1000)||' THEN
               '||l_proc_name||'(l_level);
            END IF;';
      IF r_con.cardinality = 'N-1' THEN
         l_sql := l_sql || '
       --END LOOP; --gen';
      ELSE
         l_sql := l_sql || '
         END LOOP; --gen
         CLOSE c_gen;';
         l_sql := l_sql || gen_fk_cursor_action('SRC', 'close', 9);
      END IF;
      IF r_con.constraint_name IS NULL THEN
         l_sql := l_sql ||'
    --END LOOP; -- src';
      ELSE
         l_sql := l_sql ||'
      END LOOP; -- src
      close_src;';
      END IF;
      l_sql := l_sql ||'
      '||l_proc_name||'(l_level);
      l_level := l_level + 1;';
      l_sql := l_sql || gen_fk_cursor_action('LVL', 'close', 6);
      l_sql := l_sql ||'
   END LOOP; -- level';
   l_sql := l_sql || gen_fk_cursor_action('TOP', 'close', 3);
     -- Generate post-generation code
      IF r_con.cardinality IS NULL THEN
         IF r_tab.post_gen_code IS NOT NULL THEN
            l_sql := l_sql || format_gen_code(r_tab.post_gen_code,'Post-generation code for table "'||r_tab.table_name||'"');
         END IF;
      ELSE
         IF r_con.post_gen_code IS NOT NULL THEN
            l_sql := l_sql || format_gen_code(r_con.post_gen_code,'Post-generation code for constraint "'||r_con.constraint_name||'"');
         END IF;
      END IF;
      IF r_con.cardinality IS NULL OR r_con.cardinality = '1-N' THEN
         l_sql := l_sql || '
   -- Update table statistics
   UPDATE ds_tables SET extract_count = extract_count + l_tot_count WHERE table_id = '||r_tab.table_id||';';
     END IF;
      IF r_con.cardinality = '1-N' THEN
         l_sql := l_sql || '
   -- Update constraint statistics
   UPDATE ds_constraints SET extract_count = extract_count + l_tot_count WHERE con_id = '||r_con.con_id||';';
      END IF;
      IF p_commit THEN
      l_sql := l_sql || '
   COMMIT;';
      END IF;
      l_sql := l_sql || '
END;';
      RETURN l_sql;
   END;
   ---
   -- Generate table records
   ---
   PROCEDURE generate_table_records (
      r_tab IN ds_tables%ROWTYPE
    , r_con IN ds_constraints%ROWTYPE
    , r_src_tab IN ds_tables%ROWTYPE
    , p_commit IN BOOLEAN := FALSE
   )
   IS
      l_sql VARCHAR2(32767);
      l_row_count PLS_INTEGER;
   BEGIN
      l_sql := generate_table_records(r_tab=>r_tab,r_con=>r_con,r_src_tab=>r_src_tab,p_commit=>p_commit);
      l_row_count := execute_immediate(l_sql);
   END;
--#begin public
/**
* Generate fake data set(s) i.e. synthetic data generation
*/
   PROCEDURE generate_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE := NULL -- NULL means all data sets
    , p_middle_commit IN BOOLEAN := FALSE -- commit after each step?
    , p_final_commit IN BOOLEAN := FALSE -- commit at the end?
   )
--#end public
   IS
      l_fk_cols ds_tables.columns_list%TYPE;
      -- Cursor to browse data sets of type GEN
      CURSOR c_set (
         p_set_id ds_tables.table_id%TYPE
      ) IS
         SELECT *
           FROM ds_data_sets
          WHERE set_type = 'GEN'
            AND (p_set_id IS NULL OR set_id = p_set_id)
          ORDER BY set_id
      ;
      -- Cursor to browse tables of a data set in the right order
      CURSOR c_tab (
         p_set_id ds_data_sets.set_id%TYPE
       , p_extract_type ds_tables.extract_type%TYPE
      ) IS
         SELECT *
           FROM ds_tables
          WHERE set_id = p_set_id
            AND (p_extract_type IS NULL OR extract_type = p_extract_type)
            AND extract_type IN ('B','P')
          ORDER BY seq, tab_seq, table_name
      ;
      -- Cursor to get 1-N constraints incoming to a given table
      CURSOR c_con (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_table_name ds_constraints.src_table_name%TYPE
      ) IS
         SELECT *
           FROM ds_constraints
          WHERE set_id = p_set_id
            AND dst_table_name = UPPER(p_table_name)
            AND cardinality = '1-N'
            AND extract_type IN ('B','P')
            AND (NVL(min_rows,0)>0 OR NVL(max_rows,0)>0 OR gen_view_name IS NOT NULL)
          ORDER BY CASE WHEN src_table_name = dst_table_name THEN 1 ELSE 2 END, con_seq, constraint_name -- pig's ear first
      ;
      -- Cursor to get N-1 recursive constraints
      CURSOR c_con2 (
         p_set_id ds_data_sets.set_id%TYPE
        ,p_table_name ds_constraints.src_table_name%TYPE
      ) IS
         SELECT *
           FROM ds_constraints
          WHERE set_id = p_set_id
            AND dst_table_name = UPPER(p_table_name)
            AND src_table_name = UPPER(p_table_name)
            AND cardinality = 'N-1'
            AND extract_type IN ('B','P')
          ORDER BY constraint_name
      ;
      -- Cursor to get N-1 P-constraints
      CURSOR c_con3 (
         p_set_id ds_data_sets.set_id%TYPE
      ) IS
         SELECT ds_con.con_id, ds_con.constraint_name
              , ds_tab.table_id, ds_tab.table_name, ds_tab.target_table_name
              , ds_tab.target_schema, ds_tab.target_db_link
           FROM ds_constraints ds_con
          INNER JOIN ds_tables ds_tab
             ON ds_tab.set_id = ds_con.set_id
            AND ds_tab.table_name = ds_con.src_table_name
          WHERE ds_con.set_id = p_set_id
            AND ds_con.cardinality = 'N-1'
            AND ds_con.extract_type = 'P'
          ORDER BY constraint_name
      ;
      r_src_tab ds_tables%ROWTYPE;
      l_sql CLOB;
      l_proc_name VARCHAR2(30);
   BEGIN
      <<set_loop>>
      FOR r_set IN c_set(p_set_id) LOOP
         IF r_set.set_type = 'GEN' THEN
            insert_table_columns(p_set_id=>r_set.set_id);
         END IF;
         define_walk_through_strategy(p_set_id=>r_set.set_id);
         l_proc_name := 'ds'||TO_CHAR(r_set.set_id)||'_gen';
         l_sql := 'CREATE OR REPLACE PROCEDURE '||l_proc_name||' IS';
         l_sql := l_sql || CHR(10) || 'BEGIN';
         l_sql := l_sql || REPLACE(q'#
   -- Delete records and rowids generated by any previous run
   ds_utility_krn.handle_data_set(p_set_id=>$set_id$,p_oper=>'DIRECT-EXECUTE',p_mode=>'D',p_mask_data=>FALSE);
   ds_utility_krn.delete_data_set_rowids($set_id$);
   -- Define order in which tables must be walked-through based on their dependencies
   ds_utility_krn.define_walk_through_strategy($set_id$);
   -- Reset statistics
   UPDATE ds_tables
      SET extract_count = 0
    WHERE set_id = $set_id$
      AND NVL(extract_count,-1) != 0
   ;
   UPDATE ds_constraints
      SET extract_count = 0
    WHERE set_id = $set_id$
      AND NVL(extract_count,-1) != 0
   ;#','$set_id$',r_set.set_id);
         -- Generate records for base table(s)
         FOR r_tab IN c_tab(r_set.set_id,'B') LOOP
            show_message('D','Generating code for base table "'||r_tab.table_name||'"');
            l_sql := l_sql || CHR(10) || generate_table_records(r_tab, NULL, NULL, p_middle_commit);
            -- Update records for recursive foreign keys
            FOR r_con IN c_con2(r_set.set_id,r_tab.table_name) LOOP
               show_message('D','Updating code for recursive fk '||r_con.constraint_name||'"');
               l_sql := l_sql || CHR(10) || generate_table_records(r_tab, r_con, r_tab, p_middle_commit);
            END LOOP;
         END LOOP;
         -- Generate records following 1-N for all tables
         FOR r_tab IN c_tab(r_set.set_id,NULL) LOOP
            FOR r_con IN c_con(r_set.set_id,r_tab.table_name) LOOP
               show_message('D','Generating code for table "'||r_con.dst_table_name||'" from "'||r_con.src_table_name||'" via fk "'||r_con.constraint_name||'"');
               get_table(r_set.set_id, r_con.src_table_name, r_src_tab);
               l_sql := l_sql || CHR(10) || generate_table_records(r_tab, r_con, r_src_tab, p_middle_commit);
            END LOOP;
         END LOOP;
         l_sql := l_sql || '
   -- Compute statistics for tables
   ds_utility_krn.count_table_records(p_set_id=>'||TO_CHAR(r_set.set_id)||');
   -- Compute statistics for N-1 P-constraints';
         FOR r_con IN c_con3(r_set.set_id) LOOP
            l_fk_cols := get_constraint_columns(p_constraint_name=>r_con.constraint_name, p_table_alias=>'src');
            l_sql := l_sql || '
   UPDATE ds_constraints
      SET extract_count = (
            SELECT COUNT(COUNT(*))
              FROM '||gen_full_table_name(NVL(r_con.target_table_name,r_con.table_name),r_con.target_schema,r_con.target_db_link)||' src
             INNER JOIN ds_records rec
                ON rec.table_id = '||TO_CHAR(r_con.table_id)||'
               AND rec.record_rowid = src.rowid
             GROUP BY '||l_fk_cols||'
          )
    WHERE con_id = '||TO_CHAR(r_con.con_id)||'
    ;';
         END LOOP;
         l_sql := l_sql || CHR(10) || 'END '||l_proc_name||';';
         EXECUTE IMMEDIATE l_sql;
         show_message('D','Procedure '||l_proc_name||' created');
         execute_immediate('BEGIN '||l_proc_name||'; END;');
         show_message('D','Procedure '||l_proc_name||' executed');
         IF NOT ds_utility_var.g_test_mode AND NOT NVL(INSTR(ds_utility_var.g_msg_mask,'D'),0)>0 THEN
            l_sql := 'DROP PROCEDURE '||l_proc_name;
            EXECUTE IMMEDIATE l_sql;
            show_message('D','Procedure '||l_proc_name||' dropped');
         END IF;
      END LOOP set_loop;
      -- Commit when requested
      IF p_final_commit THEN
         COMMIT;
      END IF;
   END;
--#begin public
/**
* Extract rowids of records of the given data set. For each table that must
* be partially extracted (extract type P), identify records to extract
* and store their rowids. Tables that are fully extracted (extract type F)
* or not extracted at all (extract type N) are not part of this process.
* @param p_set_id       data set id (null for all data sets)
*/
   PROCEDURE extract_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_middle_commit IN BOOLEAN := FALSE
    , p_final_commit IN BOOLEAN := FALSE
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
          ORDER BY seq * p_order, tab_seq * p_order, table_name
--            FOR UPDATE OF pass_count
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
      l_src_table_name VARCHAR2(100);
      l_dst_table_name VARCHAR2(100);
      l_cardinality ds_constraints.CARDINALITY%TYPE;
      l_extract_type ds_constraints.extract_type%TYPE;
      l_distinct VARCHAR2(10);
      l_seq_mult INTEGER;
      l_pass_mult INTEGER;
      l_plunit VARCHAR2(100) := 'extract_data_set_rowids('||NVL(TO_CHAR(p_set_id),'NULL')||')';
   BEGIN
      show_message('D','->'||l_plunit);
      -- Check mandatory parameters
      assert(p_set_id IS NOT NULL,'Missing mandatory parameter: p_set_id');
      -- Check for potential loops in dependencies
      define_walk_through_strategy(p_set_id);
      -- Delete data set
      delete_data_set_rowids(p_set_id);
      -- 2 passes: 1-N (base) then N-1 (referential)
      <<cardinality_loop>>
      FOR i IN 1..2 LOOP
         show_message('D','step='||i);
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
         <<pass_loop>>
         WHILE l_count > 0 LOOP
            l_pass_count := l_pass_count + 1;
            show_message('D','pass='||l_pass_count);
            assert(l_pass_count<=1000,'Infinite loop detected in extract_data_set_rowids()'); -- to avoid infinite loop!
            l_count := 0;
            <<tab_loop>>
            FOR r_tab_src IN c_tab(p_set_id, CASE WHEN i=1 THEN 1/*ASC*/ ELSE -1/*DESC*/ END) LOOP
               l_count := l_count + 1;
               assert(l_count<=1000,'Infinite loop detected in extract_data_set_rowids()'); -- to avoid infinite loop!
               l_src_table_name := gen_full_table_name(r_tab_src.table_name,r_tab_src.source_schema,r_tab_src.source_db_link);
               show_message('D','src_table='||l_src_table_name||', pass='||r_tab_src.pass_count);
               <<con_loop>>
               FOR r_con IN c_con(p_set_id,r_tab_src.table_name,l_cardinality,l_extract_type) LOOP
                  show_message('D','   fk='||r_con.constraint_name||' '||r_con.cardinality);
                  l_row_count := 0;
                  l_seq_mult := CASE WHEN r_con.cardinality = '1-N' THEN -1 ELSE 1 END;
                  l_pass_mult := CASE WHEN r_con.deferred = 'DEFERRED' OR (r_con.dst_table_name = r_con.src_table_name AND r_con.cardinality = '1-N') THEN 1 ELSE -1 END; /*BUG???*/
                  assert(r_con.join_clause IS NOT NULL,'Missing join clause for constraint #'||r_con.con_id);
                  get_table(p_set_id,r_con.dst_table_name,r_tab_dst);
                  l_dst_table_name := gen_full_table_name(NVL(r_tab_dst.target_table_name,r_tab_dst.table_name),r_tab_dst.source_schema,r_tab_dst.source_db_link);
                  show_message('D','   dst_table='||l_dst_table_name||', pass='||r_tab_dst.pass_count);
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
                     <<rec_loop>>
                     FOR r_rec IN c_rec(r_tab_src.table_id,r_tab_src.pass_count+1) LOOP
                        -- Record count is required to compute row limit from percentage
                        IF r_con.percentage IS NOT NULL THEN
                           -- Count nber of records in relationship
                           l_sql := '
SELECT COUNT(*)
  FROM '||l_dst_table_name||' '||l_dst_alias||','||LOWER(l_src_table_name)||' '||l_src_alias||'
 WHERE '||r_con.join_clause||'
   AND '||NVL(r_con.where_clause,'1=1')||'
   AND '||l_src_alias||'.rowid=CHARTOROWID('''||r_rec.record_rowid||''')';
                           show_message('S',RTRIM(l_sql,CHR(10)));
                           EXECUTE IMMEDIATE l_sql INTO l_source_count;
                           show_message('R','rowcount='||SQL%ROWCOUNT);
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
  FROM '||l_dst_table_name||' '||l_dst_alias||','||l_src_table_name||' '||l_src_alias||'
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
                     END LOOP rec_loop;
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
  FROM '||l_dst_table_name||' '||l_dst_alias||'
 INNER JOIN '||l_src_table_name||' '||l_src_alias||'
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
   AND ds_rec2.pass_count * '||l_pass_mult||' < '||TO_CHAR(r_tab_src.pass_count+1)||' * '||l_pass_mult; /*<= or < BUG???*/
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
                        SET extract_count = extract_count + l_row_count - l_tmp_count
                      WHERE CURRENT OF c_con;
                  END IF;
                  <<next_constraint>>
                  NULL;
               END LOOP con_loop;
               -- Increase pass count
               UPDATE ds_tables
                  SET pass_count = pass_count + 1
                WHERE table_id = r_tab_src.table_id
--                WHERE CURRENT OF c_tab
               ;
               IF p_middle_commit THEN
                  COMMIT;
               END IF;
            END LOOP tab_loop;
         END LOOP pass_loop;
      END LOOP cardinality_loop;
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
      IF NVL(INSTR(ds_utility_var.g_msg_mask,'D'),0) > 0 THEN
         set_record_remarks(p_set_id);
      END IF;
      IF p_final_commit THEN
         COMMIT;
      END IF;
      show_message('D','<-'||l_plunit);
   END;
--#begin public
/**
   DEPRECATED, replaced with extract_data_set().
*/
   PROCEDURE extract_data_set_rowids (
      p_set_id IN ds_data_sets.set_id%TYPE
    , p_middle_commit IN BOOLEAN := FALSE
    , p_final_commit IN BOOLEAN := FALSE
   )
--#end public
   IS
   BEGIN
      extract_data_set (
         p_set_id => p_set_id
       , p_middle_commit => p_middle_commit
       , p_final_commit => p_final_commit
      );
   END;
--#begin public
   ---
   -- Propagate primary key data masking to foreign keys
   ---
   PROCEDURE propagate_masking (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
   )
--#end public
   IS
   BEGIN
      -- Re-initialize to update masks for FKs that inherit values from PKs
      UPDATE ds_masks SET deleted_flag = 'Y' WHERE msk_type = 'INHERIT';
      init_seq(p_set_id=>p_set_id);
      init_pk_masking_propagation(p_set_id=>p_set_id);
      DELETE ds_masks WHERE msk_type = 'INHERIT' AND deleted_flag = 'Y';
      IF p_commit THEN
         COMMIT;
      END IF;
   END;
--#begin public
   ---
   -- Mask a data set
   ---
   PROCEDURE mask_data_set (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- data set id, NULL for all
    , p_encrypt_tokenized_values IN BOOLEAN := TRUE -- encrypt tokenized values?
    , p_key IN VARCHAR2 := NULL -- encryption key, NULL for random
    , p_commit IN BOOLEAN := FALSE -- commit at the end?
    , p_seed IN VARCHAR2 := NULL
   )
--#end public
   IS
   BEGIN
      delete_data_set_cache;
      ds_utility_var.g_mask_data := TRUE;
      IF p_key IS NOT NULL THEN
         ds_masker_krn.set_encryption_key(p_key);
      END IF;
      propagate_masking(p_set_id=>p_set_id,p_commit=>p_commit);
      ds_utility_var.g_encrypt_tokenized_values := NVL(p_encrypt_tokenized_values,TRUE);
      shuffle_records(p_set_id=>p_set_id,p_commit=>p_commit,p_seed=>p_seed);
      generate_identifiers(p_set_id=>p_set_id,p_commit=>p_commit);
      generate_tokens(p_set_id=>p_set_id,p_commit=>p_commit,p_seed=>p_seed);
   END;
--#begin public
/**
* Handle a data set (copy/delete via direct execution or prepare/execution script)
* @param p_set_id       data set id, NULL means all data sets
* @param p_oper         DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
* @param p_mode         I)nsert, U)pdate, R)efresh or UI, D)elete, M)ove
* @param p_db_link      for remote script execution
* @param p_output       DBMS_OUTPUT or DS_OUTPUT
*/
   PROCEDURE transport_data_set (
      p_set_id IN ds_data_sets.set_id%TYPE -- NULL means all data sets
     ,p_method IN VARCHAR2 -- DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
     ,p_mode IN VARCHAR2 := NULL -- I)insert, U)pdate, R)efresh or UI, D)elete, M)ove
     ,p_db_link IN VARCHAR2 := NULL -- for remote script execution
     ,p_output IN VARCHAR2 := 'DS_OUTPUT' -- or DBMS_OUTPUT
     ,p_middle_commit IN BOOLEAN := FALSE -- commit transaction after each table
     ,p_final_commit IN BOOLEAN := FALSE -- commit transaction at the end
     ,p_mask_data IN BOOLEAN :=  TRUE -- mask data?
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
            AND NVL(disabled_flag,'N') = 'N'
            AND set_type = 'SUB'
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
          ORDER BY seq * p_order, tab_seq * p_order, table_name
      ;
      l_sql CLOB;
      l_result VARCHAR2(32767);
      l_select VARCHAR2(4000);
      l_order_by VARCHAR2(4000);
      l_row_count INTEGER;
      l_sel_columns ds_tables.columns_list%TYPE;
      l_ins_columns ds_tables.columns_list%TYPE;
      l_upd_columns ds_tables.columns_list%TYPE;
      l_pk_columns ds_tables.columns_list%TYPE;
      t_pk_columns ds_utility_var.column_name_table;
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
      l_shuffled_cols ds_tables.columns_list%TYPE;
      t_shuffled_cols ds_utility_var.column_name_table;
      l_partitioned_cols ds_tables.columns_list%TYPE;
      l_all_columns ds_tables.columns_list%TYPE;
      t_all_columns ds_utility_var.column_name_table;
      l_table_alias2 VARCHAR2(30);
      l_sep VARCHAR2(10);
      l_mask_data BOOLEAN := ds_utility_var.g_mask_data;
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
      assert(NVL(p_method,'~') IN ('DIRECT-EXECUTE','PREPARE-SCRIPT','EXECUTE-SCRIPT'),'Operation must be DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT');
      assert(NVL(p_mode,'~') IN ('~','I','U','R','D','M','UI'),'Mode must be I)nsert, U)pdate, R)efresh, D)elete or M)ove');
      set_masking_mode(p_mask_data); -- set masking mode
      -- UI (Upsert) mode = R)refresh (for backward compatibility)
      IF l_mode = 'UI' THEN
         l_mode := 'R';
      END IF;
      <<set_loop>>
      FOR r_set IN c_set(p_set_id) LOOP
         define_walk_through_strategy(r_set.set_id);
         IF l_mode IN ('D') THEN
            l_order := -1;
         ELSE
            l_order := 1;
         END IF;
         <<table_loop>>
         FOR r_tab IN c_tab(r_set.set_id,l_order) LOOP
            IF r_tab.export_mode = 'UI' THEN
               r_tab.export_mode := 'R';
            END IF;
            get_shuffled_columns(r_tab.table_name, NULL/*without table alias prefix*/, 1, l_shuffled_cols, l_partitioned_cols);
            t_shuffled_cols := tokenize_columns_list(l_shuffled_cols);
            l_all_columns := normalise_columns_list(r_tab.table_name,'*');
            t_all_columns := tokenize_columns_list(l_all_columns);
            l_src_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
            l_tgt_table_name := gen_full_table_name(NVL(r_tab.target_table_name,r_tab.table_name),r_tab.target_schema,NVL(CASE WHEN p_method = 'DIRECT-EXECUTE' THEN p_db_link END,r_tab.target_db_link));
            -- Optimisation: do not process empty tables
            IF (r_tab.extract_type = 'F' OR r_tab.extract_count > 0) AND r_tab.extract_type != 'N'
            THEN
               l_export_mode := UPPER(NVL(l_mode,NVL(r_tab.export_mode,'I')));
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
                  t_pk_columns := tokenize_columns_list(l_pk_columns);
                  l_pk_size := get_columns_list_size(l_pk_columns);
                  assert(l_pk_columns IS NOT NULL,'Primary key '||l_pk_name||' has no column');
               END IF;
               IF l_update_mode THEN
                  l_upd_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*')
                     ||CASE WHEN NVL(INSTR(r_tab.columns_list,' BUT '),0)>0 THEN ', ' ELSE ' BUT ' END||l_pk_columns); -- all columns but pk
                  assert(l_upd_columns IS NOT NULL,'List of columns to update is empty for table '||r_tab.table_name);
                  l_sel_columns := l_pk_columns || ', '|| l_upd_columns;
                  IF l_refresh_mode THEN
                     l_ins_columns := l_sel_columns;
                  END IF;
               END IF;
               IF l_delete_mode THEN
                  l_sel_columns := l_pk_columns;
               END IF;
               <<pass_loop>>
               FOR l_pass_index IN REVERSE 1..NVL(r_tab.group_count,1) LOOP
                  /* For deletion, walk through in reverse order */
                  IF l_delete_mode THEN
                     l_pass_count := r_tab.group_count - l_pass_index + 1;
                  ELSE
                     l_pass_count := l_pass_index;
                  END IF;
                  -- ***** DIRECT method *****
                  IF p_method = 'DIRECT-EXECUTE' THEN
                     IF l_update_mode OR l_refresh_mode THEN
                        /* Update existing records in destination schema */
                        l_sql :=
                           'UPDATE '||l_tgt_table_name||' rem'||CHR(10)
                         ||'   SET ('||format_columns_list(l_upd_columns,8,'N')||CHR(10)
                         ||'       ) = ('||CHR(10)
                         ||build_join_statement (
                              p_purpose => 'DIRECT'
                            , p_op => 'U'
                            , p_extract_type => r_tab.extract_type
                            , p_table_name => r_tab.table_name
                            , p_table_alias => r_tab.table_alias
                            , p_sel_columns => l_upd_columns
                            , p_table_id => r_tab.table_id
                            , p_pass_count => l_pass_count
                            , p_set_id => r_tab.set_id
                            , p_indent => 9
                            , p_where =>build_join_condition(l_pk_columns,r_tab.table_alias,'rem',9,'N')
                            , p_source_schema=>r_tab.source_schema
                            , p_target_db_link=>NVL(p_db_link,r_tab.target_db_link)
                            , p_include_rowid=>FALSE
                           )
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
                         ||build_join_statement (
                              p_purpose => 'DIRECT'
                            , p_op => 'I'
                            , p_extract_type => r_tab.extract_type
                            , p_table_name => r_tab.table_name
                            , p_table_alias => r_tab.table_alias
                            , p_sel_columns => l_ins_columns
                            , p_table_id => r_tab.table_id
                            , p_pass_count => l_pass_count
                            , p_set_id => r_tab.set_id
                            , p_source_schema => r_tab.source_schema
                            , p_target_db_link=>NVL(p_db_link,r_tab.target_db_link)
                            , p_include_rowid=>FALSE
                           );
                        /* In upsert mode, insert only missing records */
                        IF l_refresh_mode THEN
                           l_sql := l_sql ||
                           '   AND ('||add_table_alias(l_pk_columns,r_tab.table_alias,t_pk_columns)||') NOT IN ('||CHR(10)
                         ||'      SELECT '||l_pk_columns||CHR(10)
                         ||'        FROM '||l_tgt_table_name||CHR(10)
                         ||'   )'||CHR(10);
                        END IF;
                        IF r_tab.order_by_clause IS NOT NULL THEN
                           l_sql := l_sql ||
                           'ORDER BY '||r_tab.order_by_clause||CHR(10);
                        END IF;
                        /* overwrite sql with merge version - not tested! + why no update when matched?*/
                        IF l_refresh_mode AND get_context('ds_merge') = 'Y' THEN
                           l_sql :=
                              ' MERGE INTO '||l_tgt_table_name||' rem'||CHR(10)
                            ||' USING ('||CHR(10)
                            ||build_join_statement (
                                 p_purpose => 'DIRECT'
                               , p_op => 'I'
                               , p_extract_type => r_tab.extract_type
                               , p_table_name => r_tab.table_name
                               , p_table_alias => r_tab.table_alias
                               , p_sel_columns => l_ins_columns
                               , p_table_id => r_tab.table_id
                               , p_pass_count => l_pass_count
                               , p_set_id => r_tab.set_id
                               , p_source_schema => r_tab.source_schema
                               , p_target_db_link=>NVL(p_db_link,r_tab.target_db_link)
                               , p_include_rowid=>FALSE
                              )
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
                  ELSIF p_method LIKE '%SCRIPT%' THEN
                     /* Select rows to extract */
                     /* Add ROWID and ROWNUM (needed for masking) as necessary */
                     IF INSTR(l_sel_columns,'rowid')<=0 THEN
                        l_sel_columns := l_sel_columns||',rowid';
                     END IF;
                     IF INSTR(l_sel_columns,'rownum')<=0 THEN
                        l_sel_columns := l_sel_columns||',rownum';
                     END IF;
                     l_sql := build_join_statement (
                        p_purpose => 'SCRIPT'
                      , p_op => 'S'
                      , p_extract_type => r_tab.extract_type
                      , p_table_name => r_tab.table_name
                      , p_table_alias => r_tab.table_alias
                      , p_sel_columns => l_sel_columns
                      , p_order_by_clause => r_tab.order_by_clause
                      , p_table_id => r_tab.table_id
                      , p_pass_count => l_pass_count
                      , p_source_schema => r_tab.source_schema
                      , p_target_db_link=>NVL(p_db_link,r_tab.target_db_link)
                      , p_include_rowid=>FALSE
                     );
                     l_cursor := sys.dbms_sql.open_cursor;
                     show_message('S',RTRIM(l_sql,CHR(10)));
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
                        IF p_method IN ('PREPARE-SCRIPT','EXECUTE-SCRIPT') OR l_refresh_mode THEN
                           l_sep := ';'||CHR(10);
                        ELSE
                           l_sep := NULL;
                        END IF;
                        l_row_count := l_row_count + 1;
                        sys.dbms_sql.column_value(l_cursor,1,l_result);
                        IF l_delete_mode THEN
                           l_sql := l_sql ||
                              l_ws||'DELETE '||LOWER(r_tab.table_name)||build_set_and_where_clauses(l_tgt_table_name,r_tab.table_alias,l_sel_columns,l_result,l_pk_size,l_indent)||l_sep;
                        END IF;
                        IF l_update_mode THEN
                           l_sql := l_sql ||
                              l_ws||'UPDATE '||l_tgt_table_name||build_set_and_where_clauses(l_tgt_table_name,r_tab.table_alias,l_sel_columns,l_result,l_pk_size,l_indent)||l_sep;
                        END IF;
                        IF l_refresh_mode THEN
                           l_sql := l_sql || l_ws || 'IF SQL%NOTFOUND THEN' || CHR(10);
                        END IF;
                        IF l_insert_mode THEN
                           l_sql := l_sql ||
                              l_ws||l_ws||'INSERT INTO '||l_tgt_table_name||' ('||CHR(10)
                            ||format_columns_list(l_ins_columns,3+2*l_indent,'Y')||CHR(10)
                            ||l_ws||l_ws||') VALUES ('||CHR(10)
                            ||build_values_clause(r_tab.table_name,r_tab.table_alias,l_sel_columns,l_result,0/*l_pk_size*/,3+2*l_indent,'Y')||CHR(10)
                            ||l_ws||l_ws||')'||l_sep;
                        END IF;
                        IF l_refresh_mode THEN
                           l_sql := l_sql || l_ws || 'END IF;' || CHR(10)
                                          || 'END;' || CHR(10);
                        END IF;
                        IF p_method = 'EXECUTE-SCRIPT' THEN
                           execute_immediate(p_sql=>'BEGIN ds_utility_krn.execute_immediate'||CASE WHEN p_db_link IS NOT NULL THEN '@'||LOWER(p_db_link) END||'(:1); END;',p_using=>'BEGIN'||CHR(10)||l_sql||'END;');
                        ELSE
                           IF l_refresh_mode THEN
                              l_sql := l_sql || '/' || CHR(10);
                           END IF;
                           put(l_sql,TRUE,p_output);
                        END IF;
                     END LOOP;
                     sys.dbms_sql.close_cursor(l_cursor);
                  END IF; -- p_method'
               END LOOP pass_loop; -- group
            END IF;
            IF p_middle_commit THEN
               COMMIT;
            END IF;
         END LOOP tab_loop;
      END LOOP set_loop;
      -- Move = Insert + Delete
      IF l_mode = 'M' THEN
         l_mode := 'D';
         GOTO set_loop;
      END IF;
      IF p_final_commit THEN
         COMMIT;
      END IF;
      set_masking_mode(l_mask_data); -- restore masking mode
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         RAISE;
   END;
--#begin public
/**
* Handle a data set (DEPRECATED, replaced with transport_data_set())
* @param p_set_id       data set id, NULL means all data sets
* @param p_method       DIRECT-EXECUTE or PREPARE-SCRIPT or EXECUTE-SCRIPT
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
     ,p_commit IN BOOLEAN := FALSE -- commit transaction at the end
     ,p_mask_data IN BOOLEAN :=  TRUE -- mask data?
     ,p_middle_commit IN BOOLEAN := FALSE -- commit transaction after each table
   )
--#end public
   IS
   BEGIN
      transport_data_set (
         p_set_id => p_set_id
        ,p_method => p_oper
        ,p_mode => p_mode
        ,p_db_link => p_db_link
        ,p_output => p_output
        ,p_middle_commit => p_middle_commit
        ,p_final_commit => p_commit
        ,p_mask_data => p_mask_data
      );
   END;
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
            AND set_type = 'SUB'
            AND NVL(disabled_flag,'N') = 'N'
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
      l_full_table_name VARCHAR2(100);
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
            l_full_table_name := gen_full_table_name(r_tab.table_name, r_tab.source_schema, r_tab.source_db_link);
            l_sel_columns := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
            l_sql := build_join_statement (
               p_purpose => 'DIRECT'
             , p_op => 'I'
             , p_extract_type => r_tab.extract_type
             , p_table_name => r_tab.table_name
             , p_table_alias => r_tab.table_alias
             , p_sel_columns => l_sel_columns
             , p_set_id => r_tab.set_id
             , p_order_by_clause => r_tab.order_by_clause
             , p_table_id => r_tab.table_id
             , p_source_schema => r_tab.source_schema
            );
            IF r_tab.extract_type = 'F' THEN
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
               l_sql := l_sql ||'   AND '||r_tab.table_alias||'.rowid=:record_rowid';
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
            AND set_type = 'SUB'
            AND NVL(disabled_flag,'N') = 'N'
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
          ORDER BY seq, tab_seq, table_name
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
         l_set := 'NVL(ds_set.visible_flag,''Y'') = ''Y''';
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
   -- Create, drop or delete tables, views or policies
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
     ,p_set_id IN ds_data_sets.set_id%TYPE := NULL -- only this data set id
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB' -- only this data set type
     ,p_object_options IN VARCHAR2 := NULL -- object options
     ,p_mask_data BOOLEAN := TRUE -- mask data?
     ,p_include_rowid BOOLEAN := FALSE -- include ROWID?
     ,p_db_link IN VARCHAR2 := NULL -- for RPC
   ) IS
      -- Cursor to browse data sets
      CURSOR c_set (
         p_set_id IN ds_data_sets.set_id%TYPE
      )
      IS
         SELECT *
           FROM ds_data_sets
          WHERE (p_set_id IS NULL OR set_id = p_set_id)
            AND set_type = 'SUB'
            AND NVL(disabled_flag,'N') = 'N'
          ORDER BY set_id
      ;
      -- Cursor to browse SQL and CSV data sets
      CURSOR c_ds (
         p_set_type IN ds_data_sets.set_type%TYPE
        ,p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT set_id, set_type, set_name, params
           FROM ds_data_sets
          WHERE set_type IN ('SQL','CSV')
            AND (p_set_type IS NULL OR set_type = p_set_type)
            AND (p_set_id IS NULL OR set_id = p_set_id)
          ORDER BY set_id
         ;
      -- Cursor to browse all tables to extract
      CURSOR c_tab (
         p_owner sys.all_tables.owner%TYPE
        ,p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT usr.table_name, ds_tab.table_alias, ds_tab.target_db_link
              , DECODE(p_set_id,NULL,NULL,ds_tab.columns_list) columns_list
              , DECODE(p_set_id,NULL,NULL,ds_tab.order_by_clause) order_by_clause
              , DECODE(p_set_id,NULL,NULL,ds_tab.table_id) table_id
              , MAX(ds_tab.table_id) max_table_id
              , DECODE(MAX(DECODE(ds_tab.extract_type,'F',2,'P',1,'B',1,0)),2,'F',1,'P',0,'N') extract_type
              , MAX(ds_tab.extract_count) extract_count
           FROM sys.all_tables usr
           LEFT OUTER JOIN ds_tables ds_tab
             ON ds_tab.table_name = usr.table_name
          WHERE usr.owner = p_owner
            AND (p_set_id IS NULL OR ds_tab.set_id = p_set_id)
          GROUP BY usr.table_name, ds_tab.table_alias, ds_tab.target_db_link
              , DECODE(p_set_id,NULL,NULL,ds_tab.columns_list)
              , DECODE(p_set_id,NULL,NULL,ds_tab.order_by_clause)
              , DECODE(p_set_id,NULL,NULL,ds_tab.table_id)
          ORDER BY MIN(ds_tab.seq), usr.table_name
      ;
      l_table_prefix_len INTEGER := NVL(LENGTH(p_table_prefix),0);
      l_object_suffix_len INTEGER;
      l_object_suffix VARCHAR(30);
      l_object_name VARCHAR2(30);
      l_sql VARCHAR2(32767);
      l_filter VARCHAR2(4000);
      l_policy_function VARCHAR2(100);
      l_sel_columns ds_tables.columns_list%TYPE;
      l_view_columns ds_tables.columns_list%TYPE;
      l_op VARCHAR2(30);
      l_shuffled_cols ds_tables.columns_list%TYPE;
      l_partitioned_cols ds_tables.columns_list%TYPE;
      t_shuffled_cols ds_utility_var.column_name_table;
      t_all_columns ds_utility_var.column_name_table;
      l_table_alias2 VARCHAR2(30);
      l_mask_data BOOLEAN := ds_utility_var.g_mask_data; -- save mask mode
      l_source_schema VARCHAR2(30);
   BEGIN
      assert(p_operation IN ('CREATE','DROP'), 'Unsupported operation: '||p_operation);
      assert(p_object_type IN ('TABLE','VIEW','POLICY'), 'Unsupported object type: '||p_object_type);
      set_masking_mode(p_mask_data); -- set masking mode
      -- Define object name
      IF p_object_suffix IS NULL AND p_object_prefix IS NULL AND p_table_prefix IS NULL THEN
         l_object_suffix := '_' || SUBSTR(p_object_type,1,1);
      ELSE
         l_object_suffix := p_object_suffix;
      END IF;
      l_object_suffix_len := NVL(LENGTH(l_object_suffix),0);
      -- For each SQL and CSV data sets
      IF p_object_type = 'VIEW' THEN
         FOR r_ds IN c_ds(p_set_type, p_set_id) LOOP
            l_sql := NULL;
            -- Build object name
            l_object_name := SUBSTR(p_object_prefix||r_ds.set_name,1,30);
            IF l_object_suffix IS NOT NULL THEN
               l_object_name := SUBSTR(l_object_name,1,30-l_object_suffix_len)||l_object_suffix;
            END IF;
            l_object_name := LOWER(l_object_name);
            IF p_operation = 'DROP' THEN
               l_sql := '
DROP '||p_object_type||' '||l_object_name;
            ELSIF p_operation = 'CREATE' THEN
               IF r_ds.set_type = 'SQL' THEN
                  l_sql := r_ds.params;
               ELSIF r_ds.set_type = 'CSV' THEN
                  l_sql := 'SELECT * FROM TABLE(ds_utility_krn.read_csv_clob('||r_ds.set_id||'))';
               END IF;
               l_sql := '
CREATE OR REPLACE '||p_object_type||' '||l_object_name||'
AS
'||l_sql;
            END IF;
            IF l_sql IS NOT NULL THEN
               show_message('D','executing: '||l_sql);
               execute_immediate(l_sql,p_operation='DROP');
            END IF;
         END LOOP;
      END IF;
      <<set_loop>>
      FOR r_set IN c_set(p_set_id) LOOP
         define_walk_through_strategy(p_set_id=>r_set.set_id);
      END LOOP set_loop;
      <<table_loop>>
      FOR r_tab IN c_tab(NVL(ds_utility_var.g_owner,USER),p_set_id) LOOP
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
               l_sql := '
DROP '||p_object_type||' '||l_object_name;
            ELSIF p_operation = 'CREATE' THEN
               IF p_object_type = 'TABLE' AND r_tab.columns_list IS NULL THEN
                  l_sel_columns  := '*';
                  l_view_columns := NULL;
               ELSE
                  l_sel_columns  := normalise_columns_list(r_tab.table_name,NVL(r_tab.columns_list,'*'));
                  l_view_columns := '('||CASE WHEN p_include_rowid THEN 'rowid#, ' END ||l_sel_columns||')';
               END IF;
               IF p_object_type = 'TABLE' THEN
                  l_sql := '
CREATE TABLE '||l_object_name||l_view_columns||' '||p_object_options||'
AS
SELECT '||l_sel_columns||'
  FROM '||LOWER(r_tab.table_name)||' '||r_tab.table_alias||'
 WHERE 1=0';
                  IF r_tab.order_by_clause IS NOT NULL THEN
                     l_sql := l_sql ||CHR(10)||' ORDER BY '||r_tab.order_by_clause;
                  END IF;
               ELSIF p_object_type = 'VIEW' THEN
                  IF NVL(ds_utility_var.g_owner,USER) != USER THEN
                     l_source_schema := LOWER(NVL(ds_utility_var.g_owner,USER));
                  END IF;
                  l_sql := 'CREATE OR REPLACE VIEW '||l_object_name||l_view_columns||CHR(10)
                         ||'AS'||CHR(10)
                         ||build_join_statement (
                              p_purpose => 'VIEW'
                            , p_op => 'S'
                            , p_extract_type => r_tab.extract_type
                            , p_table_name => r_tab.table_name
                            , p_table_alias => r_tab.table_alias
                            , p_sel_columns => l_sel_columns
                            , p_order_by_clause => r_tab.order_by_clause
                            , p_set_id => p_set_id
                            , p_table_id => r_tab.table_id
                            , p_source_schema => l_source_schema
                            , p_target_db_link=>r_tab.target_db_link
                            , p_include_rowid=>p_include_rowid
                           );
               END IF;
            END IF;
         ELSIF p_object_type = 'POLICY'
           AND r_tab.table_name NOT LIKE 'DS~_%' ESCAPE '~' -- records of DS tables cannot be hidden!!!
          THEN
            IF p_operation = 'DROP' THEN
               l_sql := 'BEGIN
   sys.dbms_rls.drop_policy(
      object_name=>'''||LOWER(r_tab.table_name)||'''
     ,policy_name=>'''||l_object_name||'''
   );
END;';
            ELSE
               IF NVL(p_mode,'S') = 'S' THEN
                  IF r_tab.extract_type = 'F' THEN
                     l_policy_function := 'ds_utility_krn.true_expression';
                  ELSIF r_tab.extract_type = 'N' THEN
                     l_policy_function := 'ds_utility_krn.false_expression';
                  ELSE
                     l_policy_function := 'ds_utility_krn.get_table_filter_stat';
                  END IF;
               ELSE
                  l_policy_function := 'ds_utility_krn.get_table_filter_dyn';
               END IF;
               l_sql := 'BEGIN
   sys.dbms_rls.add_policy(
      object_name=>'''||LOWER(r_tab.table_name)||'''
     ,policy_name=>'''||l_object_name||'''
     ,policy_function=>'''||l_policy_function||'''
   );
END;';
            END IF;
         END IF;
         IF l_sql IS NOT NULL THEN
show_message('D','executing: '||l_sql);
            IF p_db_link IS NOT NULL THEN
               execute_immediate(p_sql=>'BEGIN ds_utility_krn.execute_immediate@'||LOWER(p_db_link)||'(:1); END;'
                                ,p_ignore=>p_operation='DROP'
                                ,p_using=>CASE WHEN INSTR(l_sql,';')>0 THEN l_sql ELSE 'BEGIN'||CHR(10)||'   EXECUTE IMMEDIATE '''||l_sql||''';'||CHR(10)||'END;' END);
            ELSE
               execute_immediate(p_sql=>l_sql,p_ignore=>p_operation='DROP');
            END IF;
         END IF;
         <<next_table>>
         NULL;
      END LOOP;
      set_masking_mode(l_mask_data); -- restore masking mode
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
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB' -- data set type (null for all)
     ,p_mask_data IN BOOLEAN := TRUE -- mask data?
     ,p_include_rowid IN BOOLEAN := FALSE -- include ROWID?
   )
--#end public
   IS
   BEGIN
      create_drop_objects(
         p_operation=>'CREATE', p_object_type=>'VIEW', p_object_suffix=>p_view_suffix
        ,p_object_prefix=>p_view_prefix, p_table_prefix=>p_table_prefix, p_full_schema=>p_full_schema
        ,p_non_empty_only=>p_non_empty_only,p_mode=>p_mode,p_set_id=>p_set_id
        ,p_set_type=>p_set_type,p_mask_data=>p_mask_data,p_include_rowid=>p_include_rowid
      );
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
     ,p_set_type IN ds_data_sets.set_type%TYPE := 'SUB' -- data set type (null for all)
   )
--#end public
   IS
   BEGIN
      create_drop_objects(
         p_operation=>'DROP', p_object_type=>'VIEW', p_object_suffix=>p_view_suffix
        ,p_object_prefix=>p_view_prefix, p_table_prefix=>p_table_prefix, p_full_schema=>p_full_schema
        ,p_non_empty_only=>p_non_empty_only,p_set_id=>p_set_id,p_set_type=>p_set_type
      );
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
       , p_mode=>p_mode, p_non_empty_only=>FALSE, p_set_id=>p_set_id,p_set_type=>'SUB'
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
       , p_non_empty_only=>FALSE, p_set_id=>p_set_id,p_set_type=>'SUB'
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
      create_drop_objects(
         p_operation=>'CREATE', p_object_type=>'TABLE', p_object_suffix=>p_target_suffix
       , p_object_prefix=>p_target_prefix, p_table_prefix=>p_source_prefix, p_full_schema=>p_full_schema
       , p_non_empty_only=>p_non_empty_only, p_set_id=>p_set_id,p_object_options=>p_table_options
      );
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
      create_drop_objects(
         p_operation=>'DROP', p_object_type=>'TABLE', p_object_suffix=>p_target_suffix
       , p_object_prefix=>p_target_prefix, p_table_prefix=>p_source_prefix, p_full_schema=>p_full_schema
       , p_non_empty_only=>p_non_empty_only, p_set_id=>p_set_id,p_object_options=>p_table_options
      );
   END;
--
--#begin public
/**
* Define the new value of an identifier
* @param p_msk_id       mask id
* @param p_old_id       old value of the identifier
* @param p_new_id       new value of the identifier
* @return               new value of the identifier
*/
   FUNCTION set_identifier (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
    , p_new_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      CURSOR c_sid (
         p_msk_id ds_identifiers.msk_id%TYPE
       , p_old_id ds_identifiers.old_id%TYPE
      )
      IS
         SELECT new_id
           FROM ds_identifiers
          WHERE msk_id = p_msk_id
            AND old_id = p_old_id
         ;
      l_new_id ds_identifiers.new_id%TYPE;
      l_found BOOLEAN;
   BEGIN
      OPEN c_sid(p_msk_id,p_old_id);
      FETCH c_sid INTO l_new_id;
      l_found := c_sid%FOUND;
      CLOSE c_sid;
      IF l_found THEN
         RETURN l_new_id;
      ELSE
         INSERT INTO ds_identifiers (
            msk_id, old_id, new_id
         ) VALUES (
            p_msk_id, p_old_id, p_new_id
         );
      END IF;
      RETURN p_new_id;
   END;
--
--#begin public
/**
* Define the new value of an identifier
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_old_id       old value of the identifier
* @param p_new_id       new value of the identifier
* @return               new value of the identifier
*/
   FUNCTION set_identifier (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
    , p_new_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      CURSOR c_sid (
         p_msk_id ds_identifiers.msk_id%TYPE
       , p_old_id ds_identifiers.old_id%TYPE
      )
      IS
         SELECT new_id
           FROM ds_identifiers
          WHERE msk_id = p_msk_id
            AND old_id = p_old_id
      ;
      l_new_id ds_identifiers.new_id%TYPE;
      l_found BOOLEAN;
      r_msk ds_masks%ROWTYPE;
   BEGIN
      r_msk := get_or_create_mask(p_table_name,p_column_name);
      OPEN c_sid(r_msk.msk_id,p_old_id);
      FETCH c_sid INTO l_new_id;
      l_found := c_sid%FOUND;
      CLOSE c_sid;
      IF l_found THEN
         RETURN l_new_id;
      ELSE
         INSERT INTO ds_identifiers (
            msk_id, old_id, new_id
         ) VALUES (
            r_msk.msk_id, p_old_id, p_new_id
         );
      END IF;
      RETURN p_new_id;
   END;
--
--#begin public
/**
* Get the new value of an identifier from its old value
* @param p_table_name   table name
* @param p_column_name  column name
* @param p_old_id       old value of the identifier
* @return               new value of the identifier
*/
   FUNCTION get_identifier (
      p_table_name ds_masks.table_name%TYPE
    , p_column_name ds_masks.column_name%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      r_msk ds_masks%ROWTYPE;
   BEGIN
      r_msk := get_or_create_mask(p_table_name, p_column_name);
      assert(r_msk.msk_id is not null,'get_identifier: '||p_table_name||'.'||p_column_name||': mask id is null');
      RETURN CASE WHEN r_msk.msk_id IS NULL THEN NULL ELSE get_identifier(r_msk.msk_id, p_old_id) END;
   END;
--
--#begin public
/**
* Get the new value of an identifier from its old value
* @param p_msk_id       msk_id
* @param p_old_id       old value of the identifier
* @return               new value of the identifier
*/
   FUNCTION get_identifier (
      p_msk_id ds_identifiers.msk_id%TYPE
    , p_old_id ds_identifiers.old_id%TYPE
   )
   RETURN NUMBER
--#end public
   IS
      CURSOR c_sid (
         p_msk_id ds_identifiers.msk_id%TYPE
       , p_old_id ds_identifiers.old_id%TYPE
      )
      IS
         SELECT new_id
           FROM ds_identifiers
          WHERE msk_id = p_msk_id
            AND old_id = p_old_id
         ;
      l_new_id ds_identifiers.new_id%TYPE;
   BEGIN
      OPEN c_sid(p_msk_id,p_old_id);
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
            AND NVL(disabled_flag,'N') = 'N'
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
            AND set_type = 'CAP'
            AND NVL(disabled_flag,'N') = 'N'
            FOR UPDATE OF capture_seq
      ;
      r_set c_set%ROWTYPE;
      l_found BOOLEAN;
      l_capture_bool BOOLEAN := FALSE;
   BEGIN
      OPEN c_set(p_set_id);
      FETCH c_set INTO r_set;
      l_found := c_set%FOUND;
      l_capture_bool := l_found AND NVL(r_set.capture_flag,'Y') = 'Y' AND (r_set.capture_user IS NULL OR r_set.capture_user = p_user_name);
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
--         IF NVL(INSTR(UPPER(NVL(r_set.capture_mode,'XML')),'FWD'),0)>0 THEN
         IF r_set.capture_mode = 'ASYN' THEN
            create_capture_forwarding_job(p_set_id);
         END IF;
      END IF;
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
      l_char VARCHAR2(1 CHAR);
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
            AND NVL(extract_type,'B') IN ('B','P')
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
      l_sync_replication BOOLEAN;
      r_set ds_data_sets%ROWTYPE;
      l_columns_list ds_tables.columns_list%TYPE;
   BEGIN
      r_set := get_data_set_rec_by_id(p_set_id);
      assert(r_set.set_id=p_set_id,'Invalid data set id!');
      assert(r_set.set_type='CAP','Invalid data set type: '||r_set.set_type);
--      l_xml_capture := NVL(INSTR(UPPER(NVL(r_set.capture_mode,'XML')),'XML'),0)>0;
      l_xml_capture := NVL(r_set.capture_mode,'NONE') IN ('NONE','ASYN');
--      l_sync_replication := NVL(INSTR(UPPER(NVL(r_set.capture_mode,'XML')),'EXP'),0)>0;
      l_sync_replication := NVL(r_set.capture_mode,'NONE') = 'SYNC';
      FOR r_tab IN c_tab(p_set_id) LOOP
         show_message('D','Creating trigger for '||r_tab.table_name);
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
   r_set := ds_utility_krn.get_data_set_rec_by_id(l_set_id);
   IF NVL(r_set.capture_flag,''Y'')=''N'' THEN
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
      ds_utility_krn.capture_operation(l_set_id,l_table_id,:new.rowid,''I'',l_user_name,l_xml_new,NULL);
   ELSIF UPDATING THEN';
         l_pk_col := tokenize_columns_list(get_pk_columns(r_tab.table_name));
         FOR i IN 1..l_pk_col.COUNT LOOP
            l_sql := l_sql || CHR(10) || LPAD(' ',6) || CASE WHEN i = 1 THEN 'IF ' ELSE 'OR 'END || ':new.'|| l_pk_col(i) || ' != :old.' || l_pk_col(i);
         END LOOP;
         l_sql := l_sql ||
'
      THEN
         -- A PK update is equivalent to a delete followed by an insert
         ds_utility_krn.capture_operation(l_set_id,l_table_id,:old.rowid,''D'',l_user_name,NULL,l_xml_old);
         ds_utility_krn.capture_operation(l_set_id,l_table_id,:new.rowid,''I'',l_user_name,l_xml_new,NULL);
      ELSE
         ds_utility_krn.capture_operation(l_set_id,l_table_id,:old.rowid,''U'',l_user_name,l_xml_new,l_xml_old);
      END IF;
   ELSIF DELETING THEN
      ds_utility_krn.capture_operation(l_set_id,l_table_id,:old.rowid,''D'',l_user_name,NULL,l_xml_old);
   END IF;';
         END IF; -- if XML mode
         IF l_sync_replication AND (r_tab.target_schema IS NOT NULL OR r_tab.target_table_name IS NOT NULL OR r_tab.target_db_link IS NOT NULL) THEN
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
      IF '||CASE WHEN NVL(INSTR(l_export_mode,'I'),0)>0 OR NVL(INSTR(l_export_mode,'M'),0)>0 THEN '1=1' ELSE '1=0' END||' THEN
         INSERT INTO '||l_tab_name||'
         VALUES r_rec_new;
      END IF;
   ELSIF UPDATING THEN
      IF '||CASE WHEN NVL(INSTR(l_export_mode,'U'),0)>0 OR NVL(INSTR(l_export_mode,'M'),0)>0 THEN '1=1' ELSE '1=0' END||' THEN
         UPDATE '||l_tab_name||'
            SET ROW = r_rec_new
          WHERE '||l_where||';'||'
         IF SQL%ROWCOUNT=0 AND '||CASE WHEN NVL(INSTR(l_export_mode,'M'),0)>0 THEN '1=1' ELSE '1=0' END||' THEN
            INSERT INTO '||l_tab_name||'
            VALUES r_rec_new;
         END IF;
      END IF;
   ELSIF DELETING THEN
      IF '||CASE WHEN NVL(INSTR(l_export_mode,'D'),0)>0 THEN '1=1' ELSE '1=0' END||' THEN
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
       --show_message('D',l_sql);
         BEGIN
            EXECUTE IMMEDIATE l_sql;
         EXCEPTION
            WHEN OTHERS THEN
               show_message('E', 'Error while creating trigger on '||LOWER(r_tab.table_name));
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
            AND NVL(extract_type,'B') IN ('B','P')
         ;
      l_sql VARCHAR2(200);
      l_count INTEGER;
      r_set ds_data_sets%ROWTYPE;
   BEGIN
      r_set := get_data_set_rec_by_id(p_set_id);
      assert(r_set.set_id=p_set_id,'Invalid data set id!');
      assert(r_set.set_type='CAP','Invalid data set type!');
      FOR r_tab IN c_tab(p_set_id) LOOP
         r_tab.table_name := LOWER(r_tab.table_name);
         l_sql := 'DROP TRIGGER post_iud_ds'||p_set_id||'_tab'||r_tab.table_id;
         BEGIN
            l_count := execute_immediate(l_sql);
         EXCEPTION
            WHEN OTHERS THEN
               show_message('E','Error while dropping trigger on '||LOWER(r_tab.table_name));
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
            AND set_type = 'CAP'
            AND NVL(disabled_flag,'N') = 'N'
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
      update_data_set_def_properties(p_set_id=>p_set_id, p_capture_flag=>r_set.capture_flag, p_raise_error_when_no_update=>FALSE);
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
--#end public
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
            AND set_type = 'CAP'
            AND NVL(disabled_flag,'N') = 'N'
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
      l_column_name  sys.user_tab_columns.column_name%TYPE;
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
          WHERE tcol.owner = NVL(ds_utility_var.g_owner,USER)
            AND tcol.table_name = UPPER(p_table_name)
          ORDER BY tcol.column_id
      ;
      TYPE t_col_type IS TABLE OF c_col%ROWTYPE INDEX BY sys.user_tab_columns.column_name%TYPE;
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
           FROM TABLE(ds_utility_krn.gen_captured_data_set_script(p_set_id,p_undo_flag))
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
                WHERE fk.owner = NVL(ds_utility_var.g_owner,USER)
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
                  AND NVL(INSTR('^'||ds_utility_krn.get_constraint_columns(uk.constraint_name),'^'||ds_utility_krn.get_constraint_columns(fk.constraint_name)),0)>0
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
      FOR r_con IN c_con(p_set_id, NVL(ds_utility_var.g_owner,USER)) LOOP
         UPDATE ds_constraints
            SET md_cardinality_ok = r_con.md_cardinality_ok
              , md_optionality_ok = r_con.md_optionality_ok
              , md_uid_ok = r_con.md_uid_ok
          WHERE set_id = p_set_id
            AND constraint_name = r_con.constraint_name
            AND cardinality = '1-N'
         ;
      END LOOP;
   END detect_true_master_detail_cons;
   ---
   -- Get data type, length, precision and scale
   ---
   FUNCTION get_data_type (
      p_col_data_type IN ds_patterns.col_data_type%TYPE
   )
   RETURN ds_utility_var.col_record
   IS
      r_col ds_utility_var.col_record;
      l_beg PLS_INTEGER;
      l_pos PLS_INTEGER;
   BEGIN
      IF p_col_data_type IS NULL THEN
         RETURN r_col;
      END IF;
      l_beg := NVL(INSTR(p_col_data_type, '('),0);
      IF l_beg = 0 THEN
         r_col.data_type := p_col_data_type;
         assert(r_col.data_type IN ('CHAR','NUMBER','DATE','TIMESTAMP','CLOB','BLOB'), 'Unuspported data type: '||p_col_data_type);
      ELSE
         r_col.data_type := SUBSTR(p_col_data_type,1,l_beg-1);
         assert(r_col.data_type IN ('CHAR','NUMBER','DATE','TIMESTAMP'), 'Unuspported data type: '||p_col_data_type);
         assert(r_col.data_type IN ('CHAR','NUMBER'),'Length not allowed in data type: '||p_col_data_type);
         l_pos := INSTR(p_col_data_type, ',', l_beg+1);
         IF l_pos > 0 THEN
            assert(r_col.data_type='NUMBER','Scale not allowed in data type: '||p_col_data_type);
            BEGIN
               r_col.data_precision := TO_NUMBER(SUBSTR(p_col_data_type,l_beg+1,l_pos-l_beg-1));
            EXCEPTION
               WHEN others THEN
                  assert(FALSE,'Invalid number in data type: '||p_col_data_type);
            END;
            assert(r_col.data_precision IS NOT NULL,'Missing precision in: '||p_col_data_type);
            assert(r_col.data_precision BETWEEN 1 AND 38, 'Precision must range from 1 to 38: '||p_col_data_type);
            l_beg := l_pos;
         END IF;
         l_pos := INSTR(p_col_data_type,')',l_beg+1);
         assert(l_pos>0, 'Missing right parenthesis in data type: '||p_col_data_type);
         IF r_col.data_type = 'NUMBER' THEN
            IF r_col.data_precision IS NULL THEN
               BEGIN
                  r_col.data_precision := TO_NUMBER(SUBSTR(p_col_data_type,l_beg+1,l_pos-l_beg-1));
               EXCEPTION
                  WHEN OTHERS THEN
                     assert(FALSE,'Invalid precision in data type: '||p_col_data_type);
               END;
               assert(r_col.data_precision IS NOT NULL, 'Missing precision in: '||p_col_data_type);
               assert(r_col.data_precision BETWEEN 1 AND 38, 'Precision must range from 1 to 38: '||p_col_data_type);
            ELSE
               BEGIN
                  r_col.data_scale := TO_NUMBER(SUBSTR(p_col_data_type,l_beg+1,l_pos-l_beg-1));
               EXCEPTION
                  WHEN OTHERS THEN
                     assert(FALSE,'Invalid scale in data type: '||p_col_data_type);
               END;
               assert(r_col.data_scale IS NOT NULL, 'Missing scale in: '||p_col_data_type);
               assert(r_col.data_scale BETWEEN -84 AND 127, 'Scale must range from -84 to 127: '||p_col_data_type);
               assert(r_col.data_scale <= r_col.data_precision, 'Scale cannot exceed precision in: '||p_col_data_type);
            END IF;
         ELSE
            BEGIN
               r_col.data_length := TO_NUMBER(SUBSTR(p_col_data_type,l_beg+1,l_pos-l_beg-1));
            EXCEPTION
               WHEN OTHERS THEN
                  assert(FALSE,'Invalid lenght in data type: '||p_col_data_type);
            END;
            assert(r_col.data_length IS NOT NULL, 'Missing length in: '||p_col_data_type);
            assert(r_col.data_length > 0, 'Length must be strictly positive in: '||p_col_data_type);
         END IF;
      END IF;
      IF r_col.data_type = 'NUMBER' THEN
         r_col.data_length := 22;
      END IF;
      RETURN r_col;
   END;
   ---
   -- Check compatibility of data type, length, precision and scale
   ---
   FUNCTION compatible_data_types (
      r_pat_col ds_utility_var.col_record -- pattern column
    , r_tab_col ds_utility_var.col_record -- table column
   )
   RETURN BOOLEAN
   IS
   BEGIN
      assert(r_tab_col.data_type IS NOT NULL,'Column data type cannot be NULL');
      IF r_pat_col.data_type IS NULL THEN
         RETURN TRUE;
      END IF;
      IF r_pat_col.data_type != r_tab_col.data_type THEN
         RETURN FALSE;
      END IF;
      IF r_pat_col.data_type = 'NUMBER' THEN
         IF r_pat_col.data_scale IS NOT NULL THEN
            RETURN NVL(r_tab_col.data_precision,38) - NVL(r_tab_col.data_scale,0) >= NVL(r_pat_col.data_precision,38) - r_pat_col.data_scale
               AND r_tab_col.data_scale >= NVL(r_pat_col.data_scale,0);
         ELSIF r_pat_col.data_precision IS NOT NULL THEN
            RETURN NVL(r_tab_col.data_precision,38) >= r_pat_col.data_precision;
         ELSE
            RETURN TRUE;
         END IF;
      ELSE
         IF r_pat_col.data_length IS NOT NULL THEN
            RETURN NVL(r_tab_col.data_length,0) >= r_pat_col.data_length;
         ELSE
            RETURN TRUE;
         END IF;
      END IF;
      RETURN FALSE;
   END;
--#begin public
   ---
   -- Discover sensitive data
   -- 
   ---
   PROCEDURE discover_sensitive_data (
      p_set_id ds_data_sets.set_id%TYPE := NULL -- NULL means all
    , p_full_schema IN BOOLEAN := NULL -- Y/N, N for data sets only
    , p_table_name IN VARCHAR2 := NULL -- only those matching (wildcards allowed)
    , p_column_name IN VARCHAR2 := NULL -- only those matching (wildcards allowed)
    , p_rows_sample_size IN INTEGER := 200 -- 0 means all rows
    , p_col_data_min_pct IN INTEGER := 10 -- minimum hit percentage
    , p_col_data_min_cnt IN INTEGER := 2 -- minimum hit count
    , p_values_sample_size IN INTEGER := 10 -- 0 means all values
    , p_overwrite IN BOOLEAN := FALSE -- ignore locked_flag
    , p_commit IN BOOLEAN := FALSE -- commit at the end
   )
--#end public
   IS
      -- Cursor to browse tables
      CURSOR c_tab (
         p_table_name IN VARCHAR2
       , p_full_schema IN VARCHAR2
      )
      IS
         SELECT table_name, owner source_schema, '' source_db_link
           FROM sys.all_tables
          WHERE owner = NVL(ds_utility_var.g_owner,USER)
            AND NVL(p_full_schema,'N') = 'Y'
            AND table_name LIKE NVL(p_table_name,'%')
          UNION
         SELECT table_name, source_schema, source_db_link
           FROM ds_tables
          WHERE NVL(p_full_schema,'N') <> 'Y'
            AND (p_set_id IS NULL OR set_id = p_set_id)
            AND table_name LIKE NVL(p_table_name,'%')
          ORDER BY 1
      ;
      r_tab c_tab%ROWTYPE;
      -- Cursor to browse columns of a table + their comment
      -- Ignore those having a sensitive flag already set (Y or N)
      CURSOR c_col (
         p_table_name IN VARCHAR2
       , p_overwrite IN VARCHAR2
      )
      IS
         SELECT col.*, com.comments
           FROM sys.all_tables tab -- to exclude views
          INNER JOIN sys.all_tab_columns col
             ON col.owner = tab.owner
            AND col.table_name = tab.table_name
            AND col.column_name = UPPER(col.column_name) -- avoid non-uppercase columns
           LEFT OUTER JOIN sys.all_col_comments com
             ON com.owner = col.owner
            AND com.table_name = col.table_name
            AND com.column_name = col.column_name
           LEFT OUTER JOIN ds_masks ds_msk
             ON ds_msk.table_name = col.table_name
            AND ds_msk.column_name = col.column_name
            AND NVL(ds_msk.disabled_flag,'N') = 'N'
            AND NVL(ds_msk.deleted_flag,'N') = 'N'
          WHERE tab.owner = NVL(ds_utility_var.g_owner,USER)
            AND (p_table_name IS NULL OR col.table_name LIKE p_table_name)
            AND (p_column_name IS NULL OR col.column_name LIKE p_column_name)
            AND (NVL(ds_msk.locked_flag,'N') = 'N' OR NVL(p_overwrite,'N') = 'Y')
          ORDER BY col.column_id
      ;
      TYPE col_table IS TABLE OF c_col%ROWTYPE INDEX BY BINARY_INTEGER;
      t_col col_table;
      r_col c_col%ROWTYPE;
      r_col2 ds_utility_var.col_record;
      -- Cursor to browse sensitive data discovery patterns
      CURSOR c_pat
      IS
         SELECT *
           FROM ds_patterns
          WHERE NVL(disabled_flag,'N') = 'N'
          ORDER BY pat_seq/*ASC=>NULL last*/, pat_id
      ;
      TYPE pat_table IS TABLE OF c_pat%ROWTYPE INDEX BY BINARY_INTEGER;
      t_pat pat_table;
      r_pat c_pat%ROWTYPE;
      r_msk ds_masks%ROWTYPE;
      l_data_type sys.user_tab_columns.data_type%TYPE;
      l_cursor PLS_INTEGER;
      l_count PLS_INTEGER;
      l_row_count PLS_INTEGER;
      l_sql VARCHAR2(4000);
      l_result VARCHAR2(4000);
      t_desc sys.dbms_sql.desc_tab2;
      l_string ds_utility_var.largest_string;
      l_string_search ds_utility_var.largest_string;
      l_number NUMBER;
      l_found BOOLEAN;
      l_date DATE;
      l_timestamp TIMESTAMP;
      l_first_column BOOLEAN;
      l_sel_cols VARCHAR2(4000);
      TYPE hit_record_type IS RECORD (
         name_hit BOOLEAN
       , comm_hit BOOLEAN
       , name_comm_hits PLS_INTEGER
       , compatible_data_types BOOLEAN
       , data_regexp_hits PLS_INTEGER -- number of values matching regular expression
       , data_in_set_hits PLS_INTEGER -- number of values in data set
       , data_total_hits PLS_INTEGER -- total number of value hits
       , data_min_pct_retained BOOLEAN -- retained based on min pct
       , data_min_cnt_retained BOOLEAN -- retained based on min pct
       , data_chk_count PLS_INTEGER -- number of values tested (i.e. not null)
       , retained BOOLEAN -- meet all search criteria?
       , values_sample_regexp VARCHAR2(4000)
       , values_sample_in_set VARCHAR2(4000)
       , values_sample_regexp_count PLS_INTEGER
       , values_sample_in_set_count PLS_INTEGER
      );
      TYPE hit_rec_table IS TABLE OF hit_record_type INDEX BY BINARY_INTEGER;
      TYPE hit_rec_matrix IS TABLE OF hit_rec_table INDEX BY BINARY_INTEGER;
      r_hit hit_record_type;
      t_hit hit_rec_table;
      m_hit hit_rec_matrix;
      l_idx PLS_INTEGER;
      l_msk_remarks ds_masks.remarks%TYPE;
      l_msk_values_sample ds_masks.values_sample%TYPE;
      l_full_table_name VARCHAR2(100);
      -- Create or update mask
      PROCEDURE update_mask (
         p_remarks ds_masks.remarks%TYPE
       , p_values_sample ds_masks.values_sample%TYPE
      )
      IS
         CURSOR c_msk IS
            SELECT *
              FROM ds_masks
             WHERE table_name = r_tab.table_name
               AND column_name = r_col.column_name
              FOR UPDATE OF remarks
         ;
      BEGIN
         -- Get mask
         OPEN c_msk;
         FETCH c_msk INTO r_msk;
         IF c_msk%FOUND THEN
            UPDATE ds_masks
               SET sensitive_flag = 'Y'
                 , msk_type = r_pat.msk_type
                 , params = REPLACE(REPLACE(REPLACE(REPLACE(r_pat.msk_params,':column_name',LOWER(r_col.column_name)),':col_data_length',r_col.data_length),':col_data_precision',r_col.data_precision),':col_data_scale',r_col.data_scale)
                 , pat_cat = r_pat.pat_cat
                 , pat_name = r_pat.pat_name
                 , remarks = p_remarks
                 , values_sample = p_values_sample
                 , deleted_flag = NULL
             WHERE CURRENT OF c_msk
            ;
         ELSE
            INSERT INTO ds_masks (
               table_name, column_name, sensitive_flag
             , msk_type, params, pat_cat
             , pat_name, remarks, values_sample
             , deleted_flag
            ) VALUES (
                 r_tab.table_name,r_col.column_name, 'Y'
               , r_pat.msk_type
               , REPLACE(REPLACE(REPLACE(REPLACE(r_pat.msk_params,':column_name',LOWER(r_col.column_name)),':col_data_length',r_col.data_length),':col_data_precision',r_col.data_precision),':col_data_scale',r_col.data_scale)
               , r_pat.pat_cat, r_pat.pat_name
               , p_remarks, p_values_sample
               , NULL
            );
         END IF;
         CLOSE c_msk;
      END;
      -- Copy one record to another (limited to some data type info)
      FUNCTION get_data_type2 (
         p_col c_col%ROWTYPE
      )
      RETURN ds_utility_var.col_record
      IS
         r_col ds_utility_var.col_record;
      BEGIN
         r_col.data_type := p_col.data_type;
         r_col.data_length := p_col.data_length;
         r_col.data_precision := p_col.data_precision;
         r_col.data_scale := p_col.data_scale;
         RETURN r_col;
      END;
      -- Build remarks
      PROCEDURE build_remarks (
         p_purpose IN VARCHAR2 -- REPORT/STORE
      )
      IS
         l_discarded_msg VARCHAR2(100);
      BEGIN
         l_msk_remarks := NULL;
         l_msk_values_sample := NULL;
         IF r_hit.name_hit THEN
            l_msk_remarks := 'name regexp';
         END IF;
         IF r_hit.comm_hit THEN
            l_msk_remarks := CASE WHEN l_msk_remarks IS NOT NULL THEN l_msk_remarks || ', ' END || 'comm regexp';
         END IF;
         IF r_hit.data_regexp_hits>0 THEN
            l_msk_remarks := CASE WHEN l_msk_remarks IS NOT NULL THEN l_msk_remarks || ', ' END || 'data regexp (' || r_hit.data_regexp_hits||'/'||r_hit.data_chk_count||' rows)';
            IF r_hit.values_sample_regexp_count > 0 THEN
               l_msk_values_sample := 'data regexp sample: ' ||r_hit.values_sample_regexp;
            END IF;
         END IF;
         IF r_hit.data_in_set_hits>0 THEN
            l_msk_remarks := CASE WHEN l_msk_remarks IS NOT NULL THEN l_msk_remarks || ', ' END || 'data set (' || r_hit.data_in_set_hits||'/'||r_hit.data_chk_count||' rows)';
            IF r_hit.values_sample_in_set_count > 0 THEN
               l_msk_values_sample := CASE WHEN l_msk_values_sample IS NOT NULL THEN l_msk_values_sample || CHR(10) END || 'data set sample: ' ||r_hit.values_sample_in_set;
            END IF;
         END IF;
         IF r_pat.col_name_pattern IS NULL
         AND r_pat.col_comm_pattern IS NULL
         AND r_pat.col_data_pattern IS NULL
         AND r_pat.col_data_set_name IS NULL
         AND r_pat.col_data_type IS NOT NULL
         AND r_hit.compatible_data_types
         THEN
            l_msk_remarks := 'data type only';
         END IF;
         IF l_msk_remarks IS NOT NULL THEN
            l_discarded_msg := NULL;
            IF NOT r_hit.compatible_data_types OR NOT r_hit.data_min_pct_retained OR NOT r_hit.data_min_cnt_retained THEN
               IF r_pat.col_data_type IS NOT NULL AND NOT r_hit.compatible_data_types THEN
                  l_discarded_msg := CASE WHEN l_discarded_msg IS NOT NULL THEN l_discarded_msg || ', ' END || 'data type';
               END IF;
               IF r_hit.data_total_hits > 0 AND NOT r_hit.data_min_pct_retained THEN
                  l_discarded_msg := CASE WHEN l_discarded_msg IS NOT NULL THEN l_discarded_msg || ', ' END || 'min pct ('
                     ||ROUND(r_hit.data_total_hits / r_hit.data_chk_count * 100, 0)||'% vs '||NVL(r_pat.col_data_min_pct,p_col_data_min_pct)||'%)';
               END IF;
               IF r_hit.data_total_hits > 0 AND NOT r_hit.data_min_cnt_retained THEN
                  l_discarded_msg := CASE WHEN l_discarded_msg IS NOT NULL THEN l_discarded_msg || ', ' END || 'min cnt ('
                     ||r_hit.data_total_hits ||' vs '||NVL(r_pat.col_data_min_cnt,p_col_data_min_cnt)||')';
               END IF;
            END IF;
            IF l_discarded_msg IS NOT NULL THEN
               l_msk_remarks := CASE WHEN p_purpose = 'REPORT' THEN 'Pattern "'||r_pat.pat_name|| '" ' END || 'DISCARDED on: '||l_discarded_msg||'; matching on: '||l_msk_remarks;
            ELSE
               l_msk_remarks := CASE WHEN p_purpose = 'REPORT' THEN 'Pattern "'||r_pat.pat_name|| '" ' END || 'matching on: '||l_msk_remarks;
            END IF;
         END IF;
      END;
   BEGIN
      delete_data_set_cache;
      -- Fetch all patterns into memory
      t_pat.DELETE;
      OPEN c_pat;
      FETCH c_pat BULK COLLECT INTO t_pat;
      CLOSE c_pat;
      <<pat_loop>>
      FOR p IN 1..t_pat.COUNT LOOP
         r_pat := t_pat(p);
         r_pat.col_name_pattern := ds_masker_krn.unaccentuate_string(r_pat.col_name_pattern);
         r_pat.col_comm_pattern := ds_masker_krn.unaccentuate_string(r_pat.col_comm_pattern);
         r_pat.col_data_pattern := ds_masker_krn.unaccentuate_string(r_pat.col_data_pattern);
         t_pat(p) := r_pat;
      END LOOP pat_loop;
      -- Fetch tables one by one
      OPEN c_tab(p_table_name, CASE WHEN p_full_schema THEN 'Y' ELSE 'N' END);
      FETCH c_tab INTO r_tab;
      <<table_loop>>
      WHILE c_tab%FOUND LOOP
         m_hit.DELETE;
         -- Fetch all table columns into memory
         t_col.DELETE;
         OPEN c_col(r_tab.table_name,CASE WHEN p_overwrite THEN 'Y' ELSE 'N' END);
         FETCH c_col BULK COLLECT INTO t_col;
         CLOSE c_col;
         <<column_loop>>
         l_sel_cols := NULL;
         FOR c IN 1..t_col.COUNT LOOP
            r_col := t_col(c);
            l_sel_cols := CASE WHEN l_sel_cols IS NOT NULL THEN l_sel_cols || ', ' END || r_col.column_name;
            t_hit.DELETE;
            IF r_col.data_type IN ('CHAR','VARCHAR2','NCHAR','NVARCHAR2') THEN
               r_col.data_type := 'CHAR';
            ELSIF r_col.data_type IN ('CLOB','NCLOB') THEN
               r_col.data_type := 'CLOB';
            ELSIF r_col.data_type IN ('NUMBER','INTEGER','BINARY_FLOAT','BINARY_DOUBLE') THEN
               r_col.data_type := 'NUMBER';
            ELSIF r_col.data_type LIKE 'TIMESTAMP%' THEN
               r_col.data_type := 'TIMESTAMP';
            END IF;
            <<pattern_loop>>
            FOR p IN 1..t_pat.COUNT LOOP
               r_pat := t_pat(p);
               r_hit := NULL;
               r_hit.name_hit := FALSE;
               r_hit.comm_hit := FALSE;
               r_hit.name_comm_hits := 0;
               r_hit.data_regexp_hits := 0;
               r_hit.data_in_set_hits := 0;
               r_hit.data_total_hits := 0;
               r_hit.data_chk_count := 0;
               r_hit.retained := NULL;
               r_hit.values_sample_regexp := NULL;
               r_hit.values_sample_in_set := NULL;
               r_hit.values_sample_regexp_count := 0;
               r_hit.values_sample_in_set_count := 0;
               -- Check column name if pattern defined
               r_hit.compatible_data_types := compatible_data_types(get_data_type(r_pat.col_data_type),get_data_type2(r_col));
               r_hit.name_hit := r_pat.col_name_pattern IS NOT NULL AND regexp_like(r_col.column_name,r_pat.col_name_pattern,'i');
               r_hit.comm_hit := r_pat.col_comm_pattern IS NOT NULL AND regexp_like(r_col.comments,r_pat.col_comm_pattern,'i');
               r_hit.name_comm_hits := CASE WHEN r_hit.name_hit THEN 1 ELSE 0 END + CASE WHEN r_hit.comm_hit THEN 1 ELSE 0 END;
               <<next_pattern>>
               t_hit(p) := r_hit;
            END LOOP pattern_loop;
            m_hit(c) := t_hit;
         END LOOP column_loop;
         -- Select data
         l_full_table_name := gen_full_table_name(r_tab.table_name,r_tab.source_schema,r_tab.source_db_link);
         l_sql := 'SELECT '||l_sel_cols||' FROM '||l_full_table_name;
         IF p_rows_sample_size > 0 THEN
            l_sql := l_sql || ' WHERE rownum <= ' || p_rows_sample_size;
         END IF;
         show_message('S', l_sql);
         l_cursor := sys.dbms_sql.open_cursor;
         sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
         sys.dbms_sql.parse(l_cursor,l_sql,sys.dbms_sql.v7);
         sys.dbms_sql.describe_columns2(l_cursor,l_count,t_desc);
         l_string := NULL;
         <<column_loop2>>
         FOR c IN 1..t_desc.COUNT LOOP
            l_data_type := NULL;
            IF t_desc(c).col_type IN (8/*LONG*/, sys.dbms_types.TYPECODE_CHAR, sys.dbms_types.TYPECODE_VARCHAR
                                    , sys.dbms_types.TYPECODE_VARCHAR2, sys.dbms_types.TYPECODE_CLOB) THEN
               l_data_type := 'CHAR';
               sys.dbms_sql.define_column(l_cursor,c,l_string,32767);
            ELSIF t_desc(c).col_type = sys.dbms_types.TYPECODE_NUMBER THEN
               l_data_type := 'NUMBER';
               sys.dbms_sql.define_column(l_cursor,c,l_number);
            ELSIF t_desc(c).col_type = sys.dbms_types.TYPECODE_DATE THEN
               l_data_type := 'DATE';
               sys.dbms_sql.define_column(l_cursor,c,l_date);
            ELSIF t_desc(c).col_type IN (180/*TIMESTAMP(6)*/, 181/*TIMESTAMP(6) WITH TIME ZONE*/, sys.dbms_types.TYPECODE_TIMESTAMP
                                       , sys.dbms_types.TYPECODE_TIMESTAMP_TZ, sys.dbms_types.TYPECODE_TIMESTAMP_LTZ) THEN
               l_data_type := 'TIMESTAMP';
               sys.dbms_sql.define_column(l_cursor,c,l_timestamp);
            ELSE
--               dbms_output.put_line('Unsupported data type ('||t_desc(c).col_type||') for column '||t_desc(c).col_name);
               NULL;
            END IF;
         END LOOP column_loop2;
         l_count := sys.dbms_sql.execute(l_cursor);
         l_row_count := 0;
         <<row_loop>>
         WHILE sys.dbms_sql.fetch_rows(l_cursor) > 0
         LOOP
            l_row_count := l_row_count + 1;
            <<col_loop2>>
            FOR c IN 1..t_desc.COUNT LOOP
               r_col := t_col(c);
               t_hit := m_hit(c);
               l_string := NULL;
               IF t_desc(c).col_type IN (8/*LONG*/, sys.dbms_types.TYPECODE_CHAR, sys.dbms_types.TYPECODE_VARCHAR
                                       , sys.dbms_types.TYPECODE_VARCHAR2, sys.dbms_types.TYPECODE_CLOB) THEN
                  sys.dbms_sql.column_value(l_cursor,c,l_string);
               ELSIF t_desc(c).col_type = sys.dbms_types.TYPECODE_NUMBER THEN
                  sys.dbms_sql.column_value(l_cursor,c,l_number);
                  l_string := TO_CHAR(l_number);
                  IF SUBSTR(l_string,1,1) IN ('.',',') THEN
                     l_string := '0' || l_string; -- add leading zero
                  END IF;
               ELSIF t_desc(c).col_type = sys.dbms_types.TYPECODE_DATE THEN
                  sys.dbms_sql.column_value(l_cursor,c,l_date);
                  DECLARE
                     le_invalid_date EXCEPTION; --ORA-01801: date format is too long for internal buffer
                     PRAGMA EXCEPTION_INIT(le_invalid_date, -1801);
                  BEGIN
                     l_string := REPLACE(TO_CHAR(l_date,ds_utility_var.g_time_mask),' 00:00:00');
                  EXCEPTION
                     WHEN le_invalid_date THEN
                        l_string := NULL;
                  END;
               ELSIF t_desc(c).col_type IN (180/*TIMESTAMP(6)*/, 181/*TIMESTAMP(6) WITH TIME ZONE*/, sys.dbms_types.TYPECODE_TIMESTAMP
                                          , sys.dbms_types.TYPECODE_TIMESTAMP_TZ, sys.dbms_types.TYPECODE_TIMESTAMP_LTZ) THEN
                  sys.dbms_sql.column_value(l_cursor,c,l_timestamp);
                  l_string := TO_CHAR(l_timestamp,ds_utility_var.g_timestamp_mask);
               ELSE
--                  dbms_output.put_line('Unsupported data type ('||t_desc(c).col_type||') for column '||t_desc(c).col_name);
                  NULL;
               END IF;
               -- Remove accentuated characters before searching
               l_string_search := ds_masker_krn.unaccentuate_string(l_string);
               -- For each pattern
               <<pattern_loop2>>
               FOR p IN 1..t_pat.COUNT LOOP
                  r_pat := t_pat(p);
                  r_hit := t_hit(p);
                  -- Check column data if pattern defined, data type matches and column value is not null
                  IF l_string_search IS NOT NULL AND (r_pat.col_data_pattern IS NOT NULL OR r_pat.col_data_set_name IS NOT NULL) AND r_hit.compatible_data_types
                  THEN
                     r_hit.data_chk_count := r_hit.data_chk_count + 1;
                     l_found := FALSE;
                     IF r_pat.col_data_pattern IS NOT NULL THEN
                        IF regexp_like(l_string_search,r_pat.col_data_pattern,'i') THEN
                           l_found := TRUE;
                           r_hit.data_regexp_hits := r_hit.data_regexp_hits + 1;
                           IF r_hit.values_sample_regexp_count < p_values_sample_size 
                           AND (r_hit.values_sample_regexp IS NULL OR INSTR(', '||r_hit.values_sample_regexp||', ', ', '||l_string||', ') <= 0)
                           THEN
                              r_hit.values_sample_regexp_count := r_hit.values_sample_regexp_count + 1;
                              r_hit.values_sample_regexp := CASE WHEN r_hit.values_sample_regexp IS NOT NULL THEN r_hit.values_sample_regexp || ', ' END || l_string;
                           END IF;
                        END IF;
                     END IF;
                     IF r_pat.col_data_set_name IS NOT NULL THEN
                        IF is_value_in_data_set(r_pat.col_data_set_name,l_string_search) = 'Y' THEN
                           l_found := TRUE;
                           r_hit.data_in_set_hits := r_hit.data_in_set_hits + 1;
                           IF r_hit.values_sample_in_set_count < p_values_sample_size
                           AND (r_hit.values_sample_in_set IS NULL OR INSTR(', '||r_hit.values_sample_in_set||', ',', '||l_string||', ') <= 0)
                           THEN
                              r_hit.values_sample_in_set_count := r_hit.values_sample_in_set_count + 1;
                              r_hit.values_sample_in_set := CASE WHEN r_hit.values_sample_in_set IS NOT NULL THEN r_hit.values_sample_in_set || ', ' END || l_string;
                           END IF;
                        END IF;
                     END IF;
                     IF l_found THEN
                        r_hit.data_total_hits := r_hit.data_total_hits + 1;
                     END IF;
                     t_hit(p) := r_hit;
                  END IF;
               END LOOP nextpat_loop2;
               m_hit(c) := t_hit;
            END LOOP col_loop2;
         END LOOP row_loop;
         sys.dbms_sql.close_cursor(l_cursor);
         -- Analysis
         <<column_loop3>>
         FOR c IN 1..t_desc.COUNT LOOP
            r_col := t_col(c);
            t_hit := m_hit(c);
            l_idx := 0;
            <<pattern_loop3>>
            FOR p IN 1..t_pat.COUNT LOOP
               r_pat := t_pat(p);
               r_hit := t_hit(p);
               r_hit.data_min_pct_retained := r_hit.data_chk_count > 0 AND ROUND(r_hit.data_total_hits / r_hit.data_chk_count * 100, 0) >= NVL(r_pat.col_data_min_pct,p_col_data_min_pct);
               r_hit.data_min_cnt_retained := r_hit.data_chk_count > 0 AND r_hit.data_total_hits >= NVL(r_pat.col_data_min_cnt,p_col_data_min_cnt);
               r_hit.retained := NULL;
               IF r_pat.col_name_pattern IS NOT NULL OR r_pat.col_comm_pattern IS NOT NULL THEN
                  r_hit.retained := t_hit(p).name_hit OR t_hit(p).comm_hit;
               END IF;
               IF r_pat.col_data_pattern IS NOT NULL OR r_pat.col_data_set_name IS NOT NULL THEN
                  IF NVL(r_pat.logical_operator,'OR') = 'OR' THEN
                     r_hit.retained := NVL(r_hit.retained,FALSE) OR (r_hit.data_min_pct_retained AND r_hit.data_min_cnt_retained);
                  ELSE
                     r_hit.retained := NVL(r_hit.retained,TRUE) AND (r_hit.data_min_pct_retained AND r_hit.data_min_cnt_retained);
                  END IF;
               END IF;
               IF NOT r_hit.compatible_data_types THEN
                  r_hit.retained := FALSE;
               ELSIF r_hit.retained IS NULL AND r_pat.col_data_type IS NOT NULL THEN
                  r_hit.retained := TRUE; -- no pattern/set but compatible types
               END IF;
               IF r_hit.retained IS NULL THEN
                  r_hit.retained := FALSE;
               END IF;
               IF r_hit.retained THEN
                  IF l_idx = 0
                  OR (t_hit(l_idx).data_total_hits = 0 AND r_hit.name_comm_hits > t_hit(l_idx).name_comm_hits)
                  OR r_hit.data_total_hits > t_hit(l_idx).data_total_hits
                  THEN
                     l_idx := p;
                  END IF;
               END IF;
               t_hit(p) := r_hit;
            END LOOP pattern_loop3;
            <<pattern_loop4>>
            FOR p IN 1..t_pat.COUNT LOOP
               r_pat := t_pat(p);
               r_hit := t_hit(p);
               build_remarks('REPORT');
               IF l_msk_remarks IS NOT NULL THEN
                  IF p = l_idx THEN
                     show_message('I','*'|| r_tab.table_name||'.'||r_col.column_name||': '||REPLACE(l_msk_remarks,'matching','RETAINED; matching')||'; '||l_msk_values_sample);
                  ELSIF INSTR(l_msk_remarks, 'DISCARDED') = 0 THEN
                     show_message('I',' '|| r_tab.table_name||'.'||r_col.column_name||': '||REPLACE(l_msk_remarks,'matching','NOT BEST; matching')||'; '||l_msk_values_sample);
                  ELSE
                     show_message('I',' '|| r_tab.table_name||'.'||r_col.column_name||': '||l_msk_remarks||'; '||l_msk_values_sample);
                  END IF;
               END IF;
            END LOOP pattern_loop4;
            IF l_idx > 0 THEN
               r_pat := t_pat(l_idx);
               r_hit := t_hit(l_idx);
               build_remarks('STORE');
               IF l_msk_remarks IS NOT NULL THEN
                  update_mask(l_msk_remarks, l_msk_values_sample);
               END IF;
            END IF;
            m_hit(c) := t_hit;
         END LOOP column_loop3;
         FETCH c_tab INTO r_tab;
      END LOOP table_loop;
      CLOSE c_tab;
      -- Disabled orphan masks
      UPDATE ds_masks
         SET disabled_flag = 'Y'
       WHERE NVL(disabled_flag,'N') = 'N'
         AND (table_name, column_name) NOT IN (
             SELECT col.table_name, col.column_name
               FROM sys.all_tables tab
              INNER JOIN sys.all_tab_columns col
                 ON col.owner = tab.owner
                AND col.table_name = tab.table_name
              WHERE tab.owner = NVL(ds_utility_var.g_owner,USER)
             )
      ;
      propagate_masking(p_set_id=>p_set_id,p_commit=>p_commit);
      -- Commit if requested
      IF p_commit THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF sys.dbms_sql.is_open(l_cursor) THEN
            sys.dbms_sql.close_cursor(l_cursor);
         END IF;
         RAISE;
   END discover_sensitive_data;
BEGIN
   dbm_utility_krn.check_runtime_privileges('ds_utility','verbose');
/*
   !!! DS_READ_CSV_CLOB doesn't work without altering the session as described below !!!
   Source: https://renenyffenegger.ch/notes/development/databases/Oracle/Data-Cartridge/interfaces/table/index
   Not working if CURSOR_SHARING is set to FORCE
   Update 2020-11-20: it turns out that this example does not work if cursor_sharing is set to force: it throws the error message ORA-29913: error in executing ODCITABLEDESCRIBE callout.
   This is because with this setting, Oracle calls the function with bind variables and odciTableDescribe receives null for the parameters r and c.
   Therefore, in such an environment, the session must be altered in order to make the example run:
   alter session set cursor_sharing = exact;
*/
   EXECUTE IMMEDIATE 'alter session set cursor_sharing = exact';
/*
   To avoid ORA-02069: global_names parameter must be set to TRUE for this operation
   When executing a PL/SQL script remotely via a RPC through a database link
   When set to TRUE, db links must have the same name as their target database
*/
   EXECUTE IMMEDIATE 'alter session set global_names = true';
END ds_utility_krn;
/
