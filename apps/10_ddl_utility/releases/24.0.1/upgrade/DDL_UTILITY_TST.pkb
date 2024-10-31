CREATE OR REPLACE PACKAGE BODY ddl_utility_tst AS

   -- Global variables
   gk_seq_name VARCHAR2(11) := 'ddl_tst_seq';
   gk_tab_name VARCHAR2(11) := 'ddl_tst_tab';
   gk_col_name VARCHAR2(2)  := 'id';
   gk_debug BOOLEAN := FALSE;  

   -- Execute dynamic SQL statement
   FUNCTION execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   )
   RETURN INTEGER
   IS
      l_ret INTEGER;
   BEGIN
      IF gk_debug THEN sys.dbms_output.put(p_sql||': '); END IF;
      EXECUTE IMMEDIATE p_sql;
      l_ret := SQL%ROWCOUNT;
      IF gk_debug THEN sys.dbms_output.put_line('rowcount='||l_ret); END IF;
      RETURN l_ret;
   EXCEPTION
      WHEN OTHERS THEN
         sys.dbms_output.put_line(SQLERRM);
         sys.dbms_output.put('Statement:');
         sys.dbms_output.put_line(p_sql);
         IF NOT p_ignore THEN
            RAISE;
         END IF;
   END;

   -- Execute dynamic SQL statement
   PROCEDURE execute_immediate (
      p_sql IN VARCHAR2
     ,p_ignore IN BOOLEAN := FALSE
   )
   IS
      l_ret INTEGER;
   BEGIN
      l_ret := execute_immediate(p_sql, p_ignore);
   END;

   -- Get sequence record from dictionary view
   FUNCTION get_seq (
      p_seq_name user_sequences.sequence_name%TYPE
   )
   RETURN user_sequences%ROWTYPE
   IS
      -- Local cursor to check sequence
      CURSOR lc_seq (
         p_seq_name user_sequences.sequence_name%TYPE
      )
      IS
         SELECT *
           FROM user_sequences
          WHERE sequence_name = UPPER(p_seq_name)
         ;
      lr_seq user_sequences%ROWTYPE;
   BEGIN
      OPEN lc_seq(gk_seq_name);
      FETCH lc_seq INTO lr_seq;
      CLOSE lc_seq;
      RETURN lr_seq;
   END;

   -- Check object existence
   FUNCTION object_exists (
      p_object_type user_objects.object_type%TYPE
    , p_object_name user_objects.object_name%TYPE
   )
   RETURN BOOLEAN
   IS
      CURSOR c_obj (
         p_object_type user_objects.object_type%TYPE
       , p_object_name user_objects.object_name%TYPE
      )
      IS
         SELECT 'x'
           FROM user_objects
          WHERE object_name = UPPER(p_object_name)
            AND object_type = UPPER(p_object_type)
      ;
      l_found BOOLEAN;
      l_dummy VARCHAR2(1);
   BEGIN
      OPEN c_obj(p_object_type,p_object_name);
      FETCH c_obj INTO l_dummy;
      l_found := c_obj%FOUND;
      CLOSE c_obj;
      RETURN l_found;
   END;

   -- Drop sequence
   PROCEDURE drop_seq
   IS
   BEGIN
      IF object_exists('SEQUENCE',gk_seq_name) THEN
         execute_immediate('DROP SEQUENCE '||gk_seq_name);
      END IF;
   END;

   -- Create sequence with given properties
   PROCEDURE create_seq (
      p_seq_param IN VARCHAR2
   )
   IS
   BEGIN
      drop_seq;
      execute_immediate('CREATE SEQUENCE '||gk_seq_name||' '||p_seq_param);
   END;

   -- Alter sequence with given properties
   PROCEDURE alter_seq (
      p_seq_param IN VARCHAR2
   )
   IS
   BEGIN
      execute_immediate('ALTER SEQUENCE '||gk_seq_name||' '||p_seq_param);
   END;

   -- Get last sequence number
   FUNCTION get_seq_next_val (
      p_seq_name user_sequences.sequence_name%TYPE
   )
   RETURN user_sequences.last_number%TYPE
   IS
      l_last_number user_sequences.last_number%TYPE;
   BEGIN
      EXECUTE IMMEDIATE 'SELECT '||p_seq_name||'.NEXTVAL FROM dual' INTO l_last_number;
      RETURN l_last_number;  
   END;

   -- Test change_sequence_value() with NULL seq_name
   PROCEDURE csv_seq_name_null IS
   BEGIN
      -- Arrange
      -- Act
      ddl_utility.change_sequence_value(NULL,1);
      -- Assert done by --%throws annotation
   END;

   -- Test change_sequence_value() with invalid sequence name
   PROCEDURE csv_seq_name_invalid IS
   BEGIN
      -- Arrange
      -- Act
      ddl_utility.change_sequence_value('x',1);
      -- Assert done by --%throws annotation
   END;

   -- Test change_sequence_value() with seq_value less than minimum
   PROCEDURE csv_seq_value_lt_min IS
   BEGIN
      -- Arrange
      create_seq('MINVALUE 20');
      -- Act
      ddl_utility.change_sequence_value(gk_seq_name,10);
      -- Assert done by --%throws annotation
   END;

   -- Test change_sequence_value() with seq_value greater than maximum
   PROCEDURE csv_seq_value_gt_max IS
   BEGIN
      -- Arrange
      create_seq('MAXVALUE 20');
      -- Act
      ddl_utility.change_sequence_value(gk_seq_name,30);
      -- Assert done by --%throws annotation
   END;

   -- Test normal behaviour
   PROCEDURE csv_normal_behaviour (
      p_seq_param IN VARCHAR2
    , p_seq_delta IN INTEGER
   )
   IS
      l_last_number user_sequences.last_number%TYPE;
      l_expected_value user_sequences.last_number%TYPE;
      r_seq_before user_sequences%ROWTYPE;
      r_seq_after user_sequences%ROWTYPE;
   BEGIN
      -- Arrange: create sequence and advance it by a random number
      create_seq(p_seq_param);
      FOR i IN 1..GREATEST(0,0-NVL(p_seq_delta,0))+sys.dbms_random.value(1,10) LOOP
         l_last_number := get_seq_next_val(gk_seq_name);
      END LOOP;
      -- Act: add delta to sequence value
      l_expected_value := CASE WHEN p_seq_delta IS NULL THEN NULL ELSE l_last_number + NVL(p_seq_delta,0) END;
      r_seq_before := get_seq(gk_seq_name);
      ddl_utility.change_sequence_value(gk_seq_name,l_expected_value);
      IF p_seq_delta IS NULL THEN
         l_expected_value := r_seq_before.min_value;
      END IF;
      r_seq_after := get_seq(gk_seq_name);
      l_last_number := get_seq_next_val(gk_seq_name) - r_seq_after.increment_by;
      -- Assert: check value and ensure other properties haven'T changed
      ut.expect(l_last_number).to_equal(l_expected_value);
      ut.expect(r_seq_after.increment_by).to_equal(r_seq_before.increment_by);
      ut.expect(r_seq_after.min_value).to_equal(r_seq_before.min_value);
      ut.expect(r_seq_after.max_value).to_equal(r_seq_before.max_value);
      ut.expect(r_seq_after.cycle_flag).to_equal(r_seq_before.cycle_flag);
      ut.expect(r_seq_after.cache_size).to_equal(r_seq_before.cache_size);
      ut.expect(r_seq_after.order_flag).to_equal(r_seq_before.order_flag);
   END;

   -- Test change_sequence_value() with seq_value greater than actual
   PROCEDURE csv_seq_value_eq_null IS
   BEGIN
      csv_normal_behaviour('INCREMENT BY 2 MINVALUE 10 MAXVALUE 90 NOCYCLE NOCACHE',NULL);
   END;

   -- Test change_sequence_value() with seq_value greater than actual
   PROCEDURE csv_seq_value_gt_actual IS
   BEGIN
      csv_normal_behaviour('INCREMENT BY 2 MINVALUE 10 MAXVALUE 90 NOCYCLE NOCACHE',10);
   END;

   -- Test change_sequence_value() with seq_value less than actual
   PROCEDURE csv_seq_value_lt_actual IS
   BEGIN
      csv_normal_behaviour('INCREMENT BY 2 MINVALUE 10 MAXVALUE 90 CYCLE CACHE 5',-10);
      NULL;
   END;

   -- Test change_sequence_value() with seq_value equal to actual
   PROCEDURE csv_seq_value_eq_actual IS
   BEGIN
      csv_normal_behaviour('INCREMENT BY 2 MINVALUE 10 MAXVALUE 90 NOCYCLE NOCACHE',0);
      NULL;
   END;

   -- Test sync_sequence_with_table() with NULL sequence name
   PROCEDURE sswt_seq_name_null
   IS
   BEGIN
      -- Arrange
      -- Act
      -- Assert
      ddl_utility.sync_sequence_with_table(NULL, gk_tab_name, gk_col_name, NULL);
   END;

   -- Test sync_sequence_with_table() with NULL table name
   PROCEDURE sswt_tab_name_null
   IS
   BEGIN
      -- Arrange
      -- Act
      -- Assert
      ddl_utility.sync_sequence_with_table(gk_seq_name, NULL, gk_col_name, NULL);
   END;

   -- Test sync_sequence_with_table() with NULL column name
   PROCEDURE sswt_col_name_null
   IS
   BEGIN
      -- Arrange
      -- Act
      -- Assert
      ddl_utility.sync_sequence_with_table(gk_seq_name, gk_tab_name, NULL, NULL);
   END;

   -- Create test table
   PROCEDURE create_tab
   IS
   BEGIN
      IF NOT object_exists('TABLE',gk_tab_name) THEN
         execute_immediate('CREATE TABLE '||gk_tab_name||' ('||gk_col_name||' NUMBER)');
      END IF;
   END;

   -- Drop test table
   PROCEDURE drop_tab
   IS
   BEGIN
      IF object_exists('TABLE',gk_tab_name) THEN
         execute_immediate('DROP TABLE '||gk_tab_name);
      END IF;
   END;

   -- Drop test table
   PROCEDURE trunc_tab
   IS
   BEGIN
      IF object_exists('TABLE',gk_tab_name) THEN
         execute_immediate('TRUNCATE TABLE '||gk_tab_name);
      END IF;
   END;

   -- Insert test record
   PROCEDURE insert_rec (
      p_min INTEGER
    , p_max INTEGER
   )
   IS
   BEGIN
      FOR i IN p_min..p_max LOOP
         execute_immediate('INSERT INTO '||gk_tab_name||'(id) VALUES ('||i||')');
      END LOOP;
   END;

   -- Test sync_sequence_with_table() with an empty table
   PROCEDURE sswt_empty_table
   IS
      l_last_number user_sequences.last_number%TYPE;
      r_seq_before user_sequences%ROWTYPE;
   BEGIN
      -- Arrange
      create_seq('INCREMENT BY 1 MINVALUE 10 MAXVALUE 90 NOCYCLE NOCACHE');
      r_seq_before := get_seq(gk_seq_name);
      -- Act
      ddl_utility.sync_sequence_with_table(gk_seq_name, gk_tab_name, gk_col_name, NULL);
      -- Assert
      l_last_number := get_seq_next_val(gk_seq_name) - r_seq_before.increment_by;
      ut.expect(l_last_number).to_equal(r_seq_before.min_value);
   END;

   -- Test sync_sequence_with_table() - normal behaviour
   PROCEDURE sswt_normal_behaviour (
      p_min INTEGER
    , p_max INTEGER
    , p_ceil INTEGER
    , p_floor INTEGER
    , p_expected INTEGER
   )
   IS
      l_last_number user_sequences.last_number%TYPE;
      r_seq_before user_sequences%ROWTYPE;
   BEGIN
      -- Arrange
      create_seq('');
      r_seq_before := get_seq(gk_seq_name);
      -- Act
      insert_rec(p_min,p_max);
      ddl_utility.sync_sequence_with_table(gk_seq_name, gk_tab_name, gk_col_name, p_ceil, p_floor);
      -- Assert
      l_last_number := get_seq_next_val(gk_seq_name) - r_seq_before.increment_by;
      ut.expect(l_last_number).to_equal(p_expected);
   END;

   -- Test sync_sequence_with_table() with a non empty table
   PROCEDURE sswt_non_empty_table
   IS
   BEGIN
      sswt_normal_behaviour(3,6,NULL,NULL,6);
   END;

   -- Test sync_sequence_with_table() with a non empty table and a ceiling
   PROCEDURE sswt_non_empty_table_with_ceil
   IS
   BEGIN
      sswt_normal_behaviour(3,6,5,NULL,4);
   END;

   -- Test sync_sequence_with_table() with a non empty table and a floor
   PROCEDURE sswt_non_empty_table_with_flo
   IS
   BEGIN
      sswt_normal_behaviour(-6,-3,NULL,1,1);
   END;

END;
/
