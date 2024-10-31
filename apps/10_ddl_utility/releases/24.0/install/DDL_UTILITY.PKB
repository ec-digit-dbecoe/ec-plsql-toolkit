CREATE OR REPLACE PACKAGE BODY ddl_utility AS
   ---
   -- Same as sys.dbms_output.put_line but with
   -- limit of 255 characters per line removed
   ---
   PROCEDURE put (
      p_text IN VARCHAR2
   ) IS
      l_len INTEGER;
      l_pos INTEGER;
      l_temp VARCHAR2(255);
      l_text VARCHAR2(4000) := p_text;
   BEGIN
      WHILE l_text IS NOT NULL LOOP
         l_len := LENGTH(l_text);
         IF l_len > 255 THEN
            -- Try to break line on LF or space boundary
            l_temp := SUBSTR(l_text,1,255);
            l_pos := INSTR(l_temp,CHR(10),-1);
            IF l_pos <= 0 THEN
               l_pos := INSTR(l_temp,' ',-1);
            END IF;
            IF l_pos > 0 THEN
               sys.dbms_output.put_line(SUBSTR(l_text,1,l_pos-1));
               l_text := SUBSTR(l_text,l_pos+1);
            ELSE
               sys.dbms_output.put_line(l_temp);
               l_text := SUBSTR(l_text,256);
            END IF;
         ELSE
            sys.dbms_output.put_line(l_text);
            l_text := NULL;
         END IF;
      END LOOP;
   END;
   ---
   -- Execute dynamic SQL statement
   ---
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   ) RETURN INTEGER IS
   BEGIN
--log_utility.log_message(-1,'T',p_sql);
      EXECUTE IMMEDIATE p_sql;
      RETURN SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS THEN
         sys.dbms_output.put_line('Exception while executing following SQL statement:');
         put(p_sql);
         IF NOT p_ignore THEN
            RAISE;
         END IF;
   END;
   ---
   -- Execute dynamic SQL statement
   ---
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   )
   IS
      l_ret INTEGER;
   BEGIN
      l_ret := execute_immediate(p_sql,p_ignore);
   END;
   ---
   -- Change the value of a sequence
   -- (without recreating the sequence)
   --
   -- Notes:
   -- 1. When NOCACHE:
   --    * last_number = the next value returned by NEXTVAL 
   --    * current value = last_number - INCREMENT
   --    * user_sequences.last_number is therefore wrongly named!
   -- 2. When CACHE, last_number can no more be used
   -- 3. NOMINVALUE is translated into min_value = 1
   -- 4. NOMAXVALUE is translated into max_value = 1E28
   -- 5. Current value must always be between min_value and max_value
   --
   ---
   PROCEDURE change_sequence_value (
      p_seq_name IN user_sequences.sequence_name%TYPE
     ,p_seq_value IN user_sequences.last_number%TYPE -- NULL for minimum
   ) IS
      r_seq user_sequences%ROWTYPE;
      l_seq_value user_sequences.last_number%TYPE := p_seq_value;
      l_cycle VARCHAR2(10);
      l_cache VARCHAR2(10);
   BEGIN
      -- Check mandatory parameters
      IF p_seq_name IS NULL THEN
         raise_application_error(-20000,'Sequence name parameter cannot be NULL');
      END IF;
      -- Check sequence name and get its properties
      BEGIN
         EXECUTE IMMEDIATE 'SELECT * FROM user_sequences WHERE sequence_name=:1'
                      INTO r_seq USING UPPER(p_seq_name);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            raise_application_error(-20000,'Sequence '||p_seq_name||' does not exist!');
      END;
      -- Set target sequence value to minimum if not supplied
      IF l_seq_value IS NULL THEN
         l_seq_value := r_seq.min_value;
      END IF;
      -- Chech that sequence value is within valid range
      IF l_seq_value < r_seq.min_value THEN
         raise_application_error(-20000,' Sequence value must be >= '||r_seq.min_value);
      END IF;
      IF l_seq_value > r_seq.max_value THEN
         raise_application_error(-20000,' Sequence value must be <= '||r_seq.max_value);
      END IF;
      -- If nocache is used, get sequence value from view
      IF r_seq.cache_size = 0 THEN
         -- Adjust last number as it is set to next value and we need actual value
         r_seq.last_number := r_seq.last_number - r_seq.increment_by;
      ELSE
         -- Get actual sequence value using nextval
         EXECUTE IMMEDIATE 'SELECT '||p_seq_name||'.nextval FROM dual' INTO r_seq.last_number;
      END IF;
      -- Compare actual and target sequence value
      IF    r_seq.last_number < l_seq_value THEN
         -- Actual is lower than target => change increment
         EXECUTE IMMEDIATE 'ALTER SEQUENCE '||p_seq_name
                         ||' INCREMENT BY '||TO_CHAR(l_seq_value-r_seq.last_number);
      ELSIF r_seq.last_number > l_seq_value THEN
         -- Actual is higher than target => prepare sequence to cycle
         EXECUTE IMMEDIATE 'ALTER SEQUENCE '||p_seq_name
                         ||' MINVALUE '||l_seq_value
                         ||' MAXVALUE '||r_seq.last_number
                         ||' NOCACHE ' -- to avoid ORA-04013
                         ||' CYCLE';
      ELSE
         -- Actual and target are identical => nothing to do
         RETURN;
      END IF;
      -- Force sequence to reach target value
      EXECUTE IMMEDIATE 'SELECT '||p_seq_name||'.NEXTVAL FROM dual' INTO r_seq.last_number;
      -- Restore sequence properties
      IF r_seq.cycle_flag = 'N' THEN
         l_cycle := 'NOCYCLE';
      ELSE
         l_cycle := 'CYCLE';
      END IF;
      IF r_seq.cache_size = 0 THEN
         l_cache := 'NOCACHE';
      ELSE
         l_cache := 'CACHE '||r_seq.cache_size;
      END IF;
      EXECUTE IMMEDIATE 'ALTER SEQUENCE '||p_seq_name
                      ||' MINVALUE '||r_seq.min_value
                      ||' MAXVALUE '||r_seq.max_value
                      ||' '||l_cycle
                      ||' '||l_cache
                      ||' INCREMENT BY '||r_seq.increment_by
                      ;
   END;
   ---
   -- Synchronise a sequence with the maximum value of a table column
   ---
   PROCEDURE sync_sequence_with_table (
      p_sequence_name IN user_sequences.sequence_name%TYPE
     ,p_table_name IN user_tab_columns.table_name%TYPE
     ,p_column_name IN user_tab_columns.column_name%TYPE
     ,p_ceiling_value IN INTEGER := NULL
     ,p_floor_value IN INTEGER := NULL
   ) IS
      l_maxval INTEGER;
      l_sql VARCHAR2(4000);
   BEGIN
      -- Check parameters
      IF p_sequence_name IS NULL THEN
         raise_application_error(-20000,'Sequence name is mandatory');
      END IF;
      IF p_table_name IS NULL THEN
         raise_application_error(-20000,'Table name is mandatory');
      END IF;
      IF p_column_name IS NULL THEN
         raise_application_error(-20000,'Column name is mandatory');
      END IF;
      -- Build SQL statement
      l_sql := 'SELECT MAX('||p_column_name||') FROM '||p_table_name||' WHERE 1=1';
      IF p_ceiling_value IS NOT NULL THEN
         l_sql := l_sql || ' AND '||p_column_name||'<'||p_ceiling_value;
      END IF;
      IF p_floor_value IS NOT NULL THEN
         l_sql := l_sql || ' AND '||p_column_name||'>'||p_floor_value;
      END IF;
--      sys.dbms_output.put_line(l_sql);
      -- Get actual maximum value from table column
      EXECUTE IMMEDIATE l_sql INTO l_maxval;
      -- Synchronise sequence with found value (or minimum when not found)
      change_sequence_value(p_sequence_name,l_maxval);
   END;
   ---
   -- Enable/Disable some constraints
   ---
   PROCEDURE enable_disable_constraints (
      p_type IN VARCHAR2
     ,p_constraint_name IN user_constraints.constraint_name%TYPE := '%'
     ,p_constraint_type IN user_constraints.constraint_type%TYPE := 'R'
   ) IS
      CURSOR c_con (
         p_type IN VARCHAR2
        ,p_constraint_name user_constraints.constraint_name%TYPE
        ,p_constraint_type user_constraints.constraint_type%TYPE
      ) IS
         SELECT 'ALTER TABLE '||table_name||' '||p_type
             ||' CONSTRAINT '||constraint_name ddl_stat
           FROM user_constraints
          WHERE constraint_type LIKE p_constraint_type ESCAPE '~'
            AND constraint_name LIKE p_constraint_name ESCAPE '~'
            AND status = DECODE(p_type,'ENABLE','DISABLED','ENABLED')
      ;
      l_count INTEGER;
   BEGIN
      FOR r_con IN c_con(p_type,p_constraint_name,p_constraint_type) LOOP
         put(r_con.ddl_stat);
         l_count := execute_immediate(r_con.ddl_stat);
      END LOOP;
   END;
   ---
   -- Disable some constraints
   -- (all referential constraints by default)
   ---
   PROCEDURE disable_constraints (
      p_constraint_name IN user_constraints.constraint_name%TYPE := '%'
     ,p_constraint_type IN user_constraints.constraint_type%TYPE := 'R'
   ) IS
   BEGIN
      enable_disable_constraints('DISABLE',p_constraint_name,p_constraint_type);
   END;
   ---
   -- Enable some constraints
   -- (all referential constraints by default)
   ---
   PROCEDURE enable_constraints (
      p_constraint_name IN user_constraints.constraint_name%TYPE := '%'
     ,p_constraint_type IN user_constraints.constraint_type%TYPE := 'R'
   ) IS
   BEGIN
      enable_disable_constraints('ENABLE',p_constraint_name,p_constraint_type);
   END;
   ---
   -- Truncate some tables
   -- (all tables by default)
   ---
   PROCEDURE truncate_tables (
      p_table_name IN user_tables.table_name%TYPE := '%'
   ) IS
      CURSOR c_tab (
         p_table_name IN user_tables.table_name%TYPE
      ) IS
         SELECT 'TRUNCATE TABLE '||table_name ddl_stat
           FROM user_tables
          WHERE table_name LIKE p_table_name ESCAPE '~'
            AND partitioned = 'NO'
      ;
      l_count INTEGER;
   BEGIN
      FOR r_tab IN c_tab(p_table_name) LOOP
         put(r_tab.ddl_stat);
         l_count := execute_immediate(r_tab.ddl_stat);
      END LOOP;
   END;
   ---
   -- Drop some tables (all by default)
   ---
   PROCEDURE drop_tables (
      p_table_name IN user_tables.table_name%TYPE := '%'
   ) IS
      CURSOR c_tab (
         p_table_name IN user_tables.table_name%TYPE
      ) IS
         SELECT 'DROP TABLE '||table_name||' CASCADE CONSTRAINTS' ddl_stat
           FROM user_tables
          WHERE table_name LIKE p_table_name ESCAPE '~'
      ;
      l_count INTEGER;
   BEGIN
      FOR r_tab IN c_tab(p_table_name) LOOP
         put(r_tab.ddl_stat);
         l_count := execute_immediate(r_tab.ddl_stat);
      END LOOP;
   END;
END;
/
