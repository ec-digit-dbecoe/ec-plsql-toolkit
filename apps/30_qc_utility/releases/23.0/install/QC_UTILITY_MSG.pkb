CREATE OR REPLACE PACKAGE BODY qc_utility_msg AS
--
-- WARNING
-- This package implements the abstraction layer that hide the complexity of record versioning to above layers.
-- It is the result of a code generator and should therefore not been changed in any way.
-- Any change should rather be made to the template that is used to generate this package.
--
   ---
   -- Return message translation in current user's language
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   FUNCTION T (
      p_msg_fra IN VARCHAR2
     ,p_msg_eng IN VARCHAR2
     ,p1 IN VARCHAR2 := NULL
     ,p2 IN VARCHAR2 := NULL
     ,p3 IN VARCHAR2 := NULL
     ,p4 IN VARCHAR2 := NULL
     ,p5 IN VARCHAR2 := NULL
     ,p6 IN VARCHAR2 := NULL
     ,p7 IN VARCHAR2 := NULL
     ,p8 IN VARCHAR2 := NULL
     ,p9 IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_msg VARCHAR2(4000) := p_msg_eng;
      l_pos INTEGER;
   BEGIN
      FOR i IN 1..9 LOOP
         l_pos := INSTR(l_msg,':'||i);
         EXIT WHEN l_pos<=0;
         l_msg := SUBSTR(l_msg,1,l_pos-1)
               || CASE WHEN i = 1 THEN p1
                       WHEN i = 2 THEN p2
                       WHEN i = 3 THEN p3
                       WHEN i = 4 THEN p4
                       WHEN i = 5 THEN p5
                       WHEN i = 6 THEN p6
                       WHEN i = 7 THEN p7
                       WHEN i = 8 THEN p8
                       WHEN i = 9 THEN p9
                  END
               || SUBSTR(l_msg,l_pos+2);
      END LOOP;
      RETURN l_msg;
   END;
   ---
   -- Raise application error
   ---
   PROCEDURE raise_error (
      p_error_msg IN VARCHAR2
    , p_where IN VARCHAR2 := NULL
   )
   IS
      l_msg VARCHAR2(4000);
   BEGIN
      raise_application_error(-20000,p_error_msg);
   END;
   ---
   -- Check assertion and return error message in user's language if false
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_msg_fra IN VARCHAR2
     ,p_err_msg_eng IN VARCHAR2 := NULL
     ,p_where IN VARCHAR2 := NULL
     ,p1 IN VARCHAR2 := NULL
     ,p2 IN VARCHAR2 := NULL
     ,p3 IN VARCHAR2 := NULL
     ,p4 IN VARCHAR2 := NULL
     ,p5 IN VARCHAR2 := NULL
     ,p6 IN VARCHAR2 := NULL
     ,p7 IN VARCHAR2 := NULL
     ,p8 IN VARCHAR2 := NULL
     ,p9 IN VARCHAR2 := NULL
   )
   IS
   BEGIN
      IF p_assertion IS NULL OR NOT p_assertion THEN
         raise_error(T(p_err_msg_fra,NVL(p_err_msg_eng,p_err_msg_fra),p1,p2,p3,p4,p5,p6,p7,p8,p9),p_where);
      END IF;
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
   -- Compare records unique key
   ---
   FUNCTION compare_msg_uk (
      r_msg_new IN qc_run_msgs%ROWTYPE
     ,r_msg_old IN qc_run_msgs%ROWTYPE
     ,p_ignore_date_from IN BOOLEAN
   )
   RETURN INTEGER
   IS
   BEGIN
      -- Compare uk colums
      IF r_msg_new.qc_code IS NULL AND r_msg_old.qc_code IS NOT NULL THEN RETURN 1; END IF;
      IF r_msg_new.qc_code IS NOT NULL AND r_msg_old.qc_code IS NULL THEN RETURN -1; END IF;
      IF r_msg_new.qc_code > r_msg_old.qc_code THEN RETURN 1; END IF;
      IF r_msg_new.qc_code < r_msg_old.qc_code THEN RETURN -1; END IF;
      IF r_msg_new.app_alias IS NULL AND r_msg_old.app_alias IS NOT NULL THEN RETURN 1; END IF;
      IF r_msg_new.app_alias IS NOT NULL AND r_msg_old.app_alias IS NULL THEN RETURN -1; END IF;
      IF r_msg_new.app_alias > r_msg_old.app_alias THEN RETURN 1; END IF;
      IF r_msg_new.app_alias < r_msg_old.app_alias THEN RETURN -1; END IF;
      IF r_msg_new.object_owner IS NULL AND r_msg_old.object_owner IS NOT NULL THEN RETURN 1; END IF;
      IF r_msg_new.object_owner IS NOT NULL AND r_msg_old.object_owner IS NULL THEN RETURN -1; END IF;
      IF r_msg_new.object_owner > r_msg_old.object_owner THEN RETURN 1; END IF;
      IF r_msg_new.object_owner < r_msg_old.object_owner THEN RETURN -1; END IF;
      IF r_msg_new.object_type IS NULL AND r_msg_old.object_type IS NOT NULL THEN RETURN 1; END IF;
      IF r_msg_new.object_type IS NOT NULL AND r_msg_old.object_type IS NULL THEN RETURN -1; END IF;
      IF r_msg_new.object_type > r_msg_old.object_type THEN RETURN 1; END IF;
      IF r_msg_new.object_type < r_msg_old.object_type THEN RETURN -1; END IF;
      IF r_msg_new.object_name IS NULL AND r_msg_old.object_name IS NOT NULL THEN RETURN 1; END IF;
      IF r_msg_new.object_name IS NOT NULL AND r_msg_old.object_name IS NULL THEN RETURN -1; END IF;
      IF r_msg_new.object_name > r_msg_old.object_name THEN RETURN 1; END IF;
      IF r_msg_new.object_name < r_msg_old.object_name THEN RETURN -1; END IF;
      RETURN 0;
   END;
   ---
   -- Compact table (remove holes)
   ---
   PROCEDURE compact_msg (
      t_msg IN OUT msg_table
   )
   IS
      l_idx INTEGER;
      l_nxt INTEGER;
      l_ins INTEGER;
   BEGIN
      l_ins := 1;
      l_idx := t_msg.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         l_nxt := t_msg.NEXT(l_idx);
         IF l_idx > l_ins THEN
            t_msg(l_ins) := t_msg(l_idx);
            t_msg.DELETE(l_idx);
         END IF;
         l_ins := l_ins + 1;
         l_idx := l_nxt;
      END LOOP;
   END;
   ---
   -- Right shift records as of given position
   -- (i.e. make a hole at given pos for insert)
   ---
   PROCEDURE right_shift_msg (
      t_msg IN OUT msg_table
     ,p_pos IN INTEGER
   )
   IS
   BEGIN
      FOR i IN REVERSE p_pos..t_msg.COUNT LOOP
         t_msg(i+1) := t_msg(i);
      END LOOP;
   END;
   ---
   -- Left shift records as of given position
   -- (i.e. delete record at given position)
   ---
   PROCEDURE left_shift_msg (
      t_msg IN OUT msg_table
     ,p_pos IN INTEGER
   )
   IS
   BEGIN
      FOR i IN p_pos..t_msg.COUNT-1 LOOP
         t_msg(i) := t_msg(i+1);
      END LOOP;
      t_msg.DELETE(t_msg.COUNT);
   END;
   ---
   -- Sort table of records
   -- !!! seems bugged !!!
   ---
--   PROCEDURE sort_msg (
--      t_msg IN OUT msg_table
--   )
--   IS
--      t_msg_1 msg_table;
--      t_msg_2 msg_table;
--      PROCEDURE split_msg(
--         t_msg IN msg_table
--        ,t_msg_1 IN OUT msg_table
--        ,t_msg_2 IN OUT msg_table
--      )
--      IS
--         l_idx_midle NUMBER(5);
--      BEGIN
--         l_idx_midle := FLOOR(t_msg.COUNT / 2);
--         t_msg_1.DELETE;
--         t_msg_2.DELETE;
--         FOR l_idx IN 1..l_idx_midle LOOP
--            t_msg_1(t_msg_1.COUNT+1) := t_msg(l_idx);
--         END LOOP;
--         l_idx_midle := l_idx_midle + 1;
--         FOR l_idx IN l_idx_midle..t_msg.COUNT LOOP
--            t_msg_2(t_msg_2.COUNT+1) := t_msg(l_idx);
--         END LOOP;
--      END;
--      PROCEDURE merge_msg(
--         t_msg IN OUT msg_table
--        ,t_msg_1 IN OUT msg_table
--        ,t_msg_2 IN OUT msg_table
--      )
--      IS
--         l_idx NUMBER(5);
--         l_idx_1 NUMBER(5);
--         l_idx_2 NUMBER(5);
--      BEGIN
--         t_msg.DELETE;
--         l_idx_1 := t_msg_1.FIRST;
--         l_idx_2 := t_msg_2.FIRST;
--         WHILE l_idx_1 IS NOT NULL AND l_idx_2 IS NOT NULL
--         LOOP
--            IF compare_msg_uk(t_msg_1(l_idx_1),t_msg_2(l_idx_2),FALSE) < 0
--            THEN
--               t_msg(t_msg.COUNT+1) := t_msg_1(l_idx_1);
--               l_idx_1 := t_msg_1.NEXT(l_idx_1);
--            ELSE
--               t_msg(t_msg.COUNT+1) := t_msg_2(l_idx_2);
--               l_idx_2 := t_msg_2.NEXT(l_idx_2);
--            END IF;
--         END LOOP;
--         IF l_idx_1 IS NOT NULL THEN
--            WHILE l_idx_1 IS NOT NULL LOOP
--               t_msg(t_msg.COUNT+1) := t_msg_1(l_idx_1);
--               l_idx_1 := t_msg_1.NEXT(l_idx_1);
--            END LOOP;
--         ELSIF l_idx_2 IS NOT NULL THEN
--            WHILE l_idx_2 IS NOT NULL LOOP
--               t_msg(t_msg.COUNT+1) := t_msg_2(l_idx_2);
--               l_idx_2 := t_msg_2.NEXT(l_idx_2);
--            END LOOP;
--         END IF;
--      END;
--   BEGIN
--      compact_msg(t_msg);
--      IF t_msg.COUNT > 1 THEN
--         split_msg(t_msg,t_msg_1,t_msg_2);
--         sort_msg(t_msg_1);
--         sort_msg(t_msg_2);
--         merge_msg(t_msg,t_msg_1,t_msg_2);
--      END if;
--   END;
   ---
   -- Sort table of records
   ---
   PROCEDURE sort_msg (
      t_msg IN OUT msg_table
   )
   IS
      r_msg qc_run_msgs%ROWTYPE;
   BEGIN
      compact_msg(t_msg);
      FOR i IN 1..t_msg.COUNT-1 LOOP
         FOR j IN i+1..t_msg.COUNT LOOP
            IF compare_msg_uk(t_msg(i),t_msg(j),FALSE) > 0 THEN
               r_msg := t_msg(j);
               t_msg(j) := t_msg(i);
               t_msg(i) := r_msg;
            END IF;
         END LOOP;
      END LOOP;
   END;
   --
   -- Print a record
   --
   PROCEDURE print_msg (
      r_msg IN qc_run_msgs%ROWTYPE
   )
   IS
   BEGIN
      NULL;
      sys.dbms_output.put_line('msg_ivid='||r_msg.msg_ivid);
      sys.dbms_output.put_line('msg_irid='||r_msg.msg_irid);
      sys.dbms_output.put_line('run_id_from='||r_msg.run_id_from);
      sys.dbms_output.put_line('run_id_to='||r_msg.run_id_to);
      sys.dbms_output.put_line('qc_code='||r_msg.qc_code);
      sys.dbms_output.put_line('app_alias='||r_msg.app_alias);
      sys.dbms_output.put_line('object_owner='||r_msg.object_owner);
      sys.dbms_output.put_line('object_type='||r_msg.object_type);
      sys.dbms_output.put_line('object_name='||r_msg.object_name);
      sys.dbms_output.put_line('msg_type='||r_msg.msg_type);
      sys.dbms_output.put_line('msg_text='||r_msg.msg_text);
   END;
   ---
   -- Get next record id
   ---
   FUNCTION get_next_msg_ivid
   RETURN qc_run_msgs.msg_ivid%TYPE
   IS
      CURSOR c_seq IS
         SELECT qc_msg_seq.NEXTVAL
           FROM dual
         ;
      l_msg_ivid qc_run_msgs.msg_ivid%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_msg_ivid;
      CLOSE c_seq;
      RETURN l_msg_ivid;
   END;
   ---
   -- Get last run id
   ---
   FUNCTION get_last_run_id (
      p_date IN DATE := NULL
     ,p_user IN VARCHAR2 := NULL
   )
   RETURN qc_runs.run_id%TYPE
   IS
      CURSOR c_run
      IS
         SELECT MAX(run_id)
           FROM qc_runs
          WHERE 1=1
            AND run_id > 0
         ;
      l_run_id qc_runs.run_id%TYPE;
   BEGIN
      OPEN c_run;
      FETCH c_run INTO l_run_id;
      CLOSE c_run;
      RETURN l_run_id;
   END;
   ---
   -- Get last run
   ---
   FUNCTION get_last_run
   RETURN qc_runs%ROWTYPE
   IS
      CURSOR c_run
      IS
         SELECT *
           FROM qc_runs
          WHERE 1=1
            AND run_id IN (
                   SELECT MAX(run_id)
                     FROM qc_runs
                    WHERE 1=1
                )
         ;
      r_run qc_runs%ROWTYPE;
   BEGIN
      OPEN c_run;
      FETCH c_run INTO r_run;
      CLOSE c_run;
      RETURN r_run;
   END;
   ---
   -- Get run
   ---
   FUNCTION get_run (
      p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_runs%ROWTYPE
   IS
      CURSOR c_run
      IS
         SELECT *
           FROM qc_runs
          WHERE 1=1
            AND run_id = p_run_id
         ;
      r_run qc_runs%ROWTYPE;
   BEGIN
      IF p_run_id IS NULL THEN
         RETURN get_last_run
                ;
      END IF;
      OPEN c_run;
      FETCH c_run INTO r_run;
      CLOSE c_run;
      RETURN r_run;
   END;
   ---
   -- Get record based on its record number
   ---
   FUNCTION get_msg (
      p_msg_irid IN qc_run_msgs.msg_irid%TYPE
     ,p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_run_msgs%ROWTYPE
   IS
      r_msg qc_run_msgs%ROWTYPE;
      CURSOR c_msg
      IS
         SELECT *
           FROM qc_run_msgs
          WHERE msg_irid = p_msg_irid
            AND p_run_id BETWEEN run_id_from AND NVL(run_id_to-1/**/,p_run_id)
      ;
   BEGIN
      OPEN c_msg;
      FETCH c_msg INTO r_msg;
      CLOSE c_msg;
      RETURN r_msg;
   END;
   ---
   -- Load records from database into memory table
   ---
   PROCEDURE load_msg (
      t_msg OUT msg_table
     ,p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_date IN DATE := NULL
     ,p_run_id_to IN qc_run_msgs.run_id_to%TYPE := NULL
     ,p_run_id_from IN qc_run_msgs.run_id_to%TYPE := NULL
   )
   IS
      CURSOR c_msg (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
        ,p_run_id IN qc_runs.run_id%TYPE
        ,p_date IN DATE := NULL
        ,p_run_id_to IN qc_run_msgs.run_id_to%TYPE := NULL
        ,p_run_id_from IN qc_run_msgs.run_id_to%TYPE := NULL
      ) IS
         SELECT *
           FROM qc_run_msgs
          WHERE 1=1
            AND (p_qc_code IS NULL OR qc_code = p_qc_code)
            AND (p_app_alias IS NULL OR app_alias = p_app_alias)
            AND (p_object_owner IS NULL OR object_owner = p_object_owner)
            AND (p_object_type IS NULL OR object_type = p_object_type)
            AND (p_object_name IS NULL OR object_name = p_object_name)
            AND (p_run_id_from IS NOT NULL OR p_run_id BETWEEN run_id_from AND NVL(run_id_to-1/**/,p_run_id))
            AND (p_run_id_to IS NULL OR run_id_to = p_run_id_to)
            AND (p_run_id_from IS NULL OR run_id_from >= p_run_id_from)
          ORDER BY
                   qc_code
                 , app_alias
                 , object_owner
                 , object_type
                 , object_name
      ;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_where VARCHAR2(100) := 'load_msg(): ';
   BEGIN
      -- No run found means no data exists => return empty table
      IF l_run_id IS NULL AND p_run_id_from IS NULL THEN
         t_msg.DELETE;
         GOTO end_proc;
      END IF;
      -- Do load
      t_msg.DELETE;
      OPEN c_msg(
         p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_object_name
        ,l_run_id
        ,p_date
        ,p_run_id_to
        ,p_run_id_from
      );
      FETCH c_msg BULK COLLECT INTO t_msg;
      CLOSE c_msg;
      <<end_proc>>
      NULL;
   END;
   -- Compare 2 strings (avec test sur valeur NULL)
   FUNCTION equals (
      p_str1 IN VARCHAR2
     ,p_str2 IN VARCHAR2
   ) RETURN BOOLEAN IS
   BEGIN
      IF p_str1 IS NULL THEN
         RETURN p_str2 IS NULL;
      ELSIF p_str2 IS NULL THEN
         RETURN p_str1 IS NULL;
      ELSE
         RETURN p_str1 = p_str2;
      END IF;
   END equals;
   -- Compare 2 nombre (avec test sur valeur NULL)
   FUNCTION equals (
      p_nbr1 IN NUMBER
     ,p_nbr2 IN NUMBER
   ) RETURN BOOLEAN IS
   BEGIN
      IF p_nbr1 IS NULL THEN
         RETURN p_nbr2 IS NULL;
      ELSIF p_nbr2 IS NULL THEN
         RETURN p_nbr1 IS NULL;
      ELSE
         RETURN p_nbr1 = p_nbr2;
      END IF;
   END equals;
   -- Compare 2 date (avec test sur valeur NULL)
   FUNCTION equals (
      p_date1 IN DATE
     ,p_date2 IN DATE
   ) RETURN BOOLEAN IS
   BEGIN
      IF p_date1 IS NULL THEN
         RETURN p_date2 IS NULL;
      ELSIF p_date2 IS NULL THEN
         RETURN p_date1 IS NULL;
      ELSE
         RETURN p_date1 = p_date2;
      END IF;
   END equals;
   -- Compare 2 date (avec test sur valeur NULL)
   FUNCTION equals (
      p_timestamp1 IN TIMESTAMP
     ,p_timestamp2 IN TIMESTAMP
   ) RETURN BOOLEAN IS
   BEGIN
      IF p_timestamp1 IS NULL THEN
         RETURN p_timestamp2 IS NULL;
      ELSIF p_timestamp2 IS NULL THEN
         RETURN p_timestamp1 IS NULL;
      ELSE
         RETURN p_timestamp1 = p_timestamp2;
      END IF;
   END equals;
   -- Compare 2 BLOBS (avec test sur valeur NULL)
   FUNCTION equals (
      p_blob1 IN BLOB
     ,p_blob2 IN BLOB
   ) RETURN BOOLEAN IS
   BEGIN
      IF sys.dbms_lob.getlength(p_blob1) = 0 THEN
         RETURN sys.dbms_lob.getlength(p_blob2) = 0;
      ELSIF sys.dbms_lob.getlength(p_blob2) = 0 THEN
         RETURN sys.dbms_lob.getlength(p_blob1) = 0;
      ELSE
         RETURN sys.dbms_lob.compare(p_blob1 , p_blob2) = 0;
      END IF;
   END equals;
   -- Compare 2 CLOBS (avec test sur valeur NULL)
   FUNCTION equals (
      p_clob1 IN CLOB
     ,p_clob2 IN CLOB
   ) RETURN BOOLEAN IS
   BEGIN
      IF sys.dbms_lob.getlength(p_clob1) = 0 THEN
         RETURN sys.dbms_lob.getlength(p_clob2) = 0;
      ELSIF sys.dbms_lob.getlength(p_clob2) = 0 THEN
         RETURN sys.dbms_lob.getlength(p_clob1) = 0;
      ELSE
         RETURN sys.dbms_lob.compare(p_clob1 , p_clob2) = 0;
      END IF;
   END equals;
   ---
   -- Compare records data
   ---
   FUNCTION compare_msg_data (
      r_msg_new IN qc_run_msgs%ROWTYPE
     ,r_msg_old IN qc_run_msgs%ROWTYPE
   )
   RETURN BOOLEAN
   IS
   BEGIN
      -- Compare all fields but pk, uk, audit, versioning columns
      RETURN (
         1=1
--         AND equals(r_msg_old.msg_text,r_msg_new.msg_text)
--         AND qc_util.equals(r_msg_old.qc_code,r_msg_new.qc_code)
--         AND qc_util.equals(r_msg_old.app_alias,r_msg_new.app_alias)
--         AND qc_util.equals(r_msg_old.object_owner,r_msg_new.object_owner)
--         AND qc_util.equals(r_msg_old.object_type,r_msg_new.object_type)
--         AND qc_util.equals(r_msg_old.object_name,r_msg_new.object_name)
/*
Non-PK columns are not versioned i.e.
No new version is created when data change 
         AND equals(r_msg_old.msg_type,r_msg_new.msg_type)
         AND equals(r_msg_old.fix_name,r_msg_new.fix_name)
         AND equals(r_msg_old.fix_op,r_msg_new.fix_op)
         AND equals(r_msg_old.fix_status,r_msg_new.fix_status)
         AND equals(r_msg_old.fix_msg,r_msg_new.fix_msg)
         AND equals(r_msg_old.fix_ddl,r_msg_new.fix_ddl)
         AND equals(r_msg_old.fix_locked,r_msg_new.fix_locked)
         AND equals(r_msg_old.fix_time,r_msg_new.fix_time)
*/
      );
   END;
   ---
   -- Check record consistency
   ---
   PROCEDURE check_msg (
      r_msg IN OUT qc_run_msgs%ROWTYPE
   )
   IS
      l_where VARCHAR2(100) := 'check_msg(): ';
   BEGIN
      assert(r_msg.qc_code IS NOT NULL, 'le champs "qc_code" est obligatoire','filed "qc_code" is mandatory',l_where);
      assert(r_msg.app_alias IS NOT NULL, 'le champs "app_alias" est obligatoire','filed "app_alias" is mandatory',l_where);
      assert(r_msg.object_owner IS NOT NULL, 'le champs "object_owner" est obligatoire','filed "object_owner" is mandatory',l_where);
      assert(r_msg.object_type IS NOT NULL, 'le champs "object_type" est obligatoire','filed "object_type" is mandatory',l_where);
      assert(r_msg.object_name IS NOT NULL, 'le champs "object_name" est obligatoire','filed "object_name" is mandatory',l_where);
      assert(r_msg.qc_code IS NOT NULL, 'la colonne "qc_code" est obligatoire','column "qc_code" is mandatory',l_where);
      assert(r_msg.object_type IS NOT NULL, 'la colonne "object_type" est obligatoire','column "object_type" is mandatory',l_where);
      assert(r_msg.object_name IS NOT NULL, 'la colonne "object_name" est obligatoire','column "object_name" is mandatory',l_where);
   END;
   ---
   -- Save memory table of records into database
   ---
   PROCEDURE save_msg (
      t_msg IN msg_table
     ,p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
   )
   IS
      l_allow_concurrent_runs VARCHAR2(1) := 'N';
      l_found BOOLEAN;
      l_same BOOLEAN;
      j INTEGER;
      r_msg_old qc_run_msgs%ROWTYPE;
      r_msg_new qc_run_msgs%ROWTYPE;
      r_msg_tmp qc_run_msgs%ROWTYPE;
      r_run qc_runs%ROWTYPE;
      t_msg_ins msg_table;
      t_msg_upd msg_table;
      t_msg_ivid_upd msg_ivid_table;
      t_msg_ivid_del msg_ivid_table;
      t_msg_old msg_table;
      t_msg_prv msg_table;
      t_msg_in1 msg_table;
      t_msg_in2 msg_table;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_last_run_id qc_runs.run_id%TYPE;
      l_where VARCHAR2(100) := 'save_msg(): ';
      -- Delete record
      PROCEDURE delete_msg (
         r_msg IN qc_run_msgs%ROWTYPE
      )
      IS
      BEGIN
         t_msg_ivid_del(t_msg_ivid_del.COUNT+1) := r_msg.msg_ivid;
      END;
      -- Update record
      PROCEDURE update_msg (
         r_msg IN OUT qc_run_msgs%ROWTYPE
        ,p_run_id_from IN qc_run_msgs.run_id_from%TYPE
        ,p_run_id_to IN qc_run_msgs.run_id_to%TYPE
        ,p_optimisation IN VARCHAR2 := 'Y'
      )
      IS
         l_idx INTEGER;
         r_msg_old qc_run_msgs%ROWTYPE;
         r_msg_new qc_run_msgs%ROWTYPE;
      BEGIN
         -- Optimisation: check for identical closed version
         IF p_run_id_from = l_run_id AND p_optimisation = 'Y' THEN
            r_msg_new := r_msg;
            l_idx := t_msg_prv.FIRST;
            WHILE l_idx IS NOT NULL LOOP
               r_msg_old := t_msg_prv(l_idx);
               IF compare_msg_uk(r_msg_new,r_msg_old,FALSE)=0 AND compare_msg_data(r_msg_new,r_msg_old) THEN
                  -- Reopen closed version
                  update_msg(r_msg_old,r_msg_old.run_id_from,p_run_id_to,'N');
                  -- Delete record to update
                  delete_msg(r_msg_new);
                  -- Remove record from memory table
                  t_msg_prv.DELETE(l_idx);
                  RETURN;
               END IF;
               l_idx := t_msg_prv.NEXT(l_idx);
            END LOOP;
         END IF;
         r_msg.run_id_from := p_run_id_from;
         r_msg.run_id_to := p_run_id_to;
         t_msg_upd(t_msg_upd.COUNT+1) := r_msg;
         t_msg_ivid_upd(t_msg_ivid_upd.COUNT+1) := r_msg.msg_ivid;
      END;
      -- Insert record
      PROCEDURE insert_msg (
         r_msg IN OUT qc_run_msgs%ROWTYPE
        ,p_msg_irid IN qc_run_msgs.msg_irid%TYPE
        ,p_run_id_from IN qc_run_msgs.run_id_from%TYPE
        ,p_run_id_to IN qc_run_msgs.run_id_to%TYPE
      )
      IS
         l_idx INTEGER;
         r_msg_old qc_run_msgs%ROWTYPE;
         r_msg_new qc_run_msgs%ROWTYPE;
      BEGIN
         -- Optimisation: check for identical closed version
         IF p_run_id_from = l_run_id THEN
            r_msg_new := r_msg;
            l_idx := t_msg_prv.FIRST;
            WHILE l_idx IS NOT NULL LOOP
               r_msg_old := t_msg_prv(l_idx);
               IF compare_msg_uk(r_msg_new,r_msg_old,FALSE)=0 AND compare_msg_data(r_msg_new,r_msg_old) THEN
                  -- Reopen closed version
                  update_msg(r_msg_old,r_msg_old.run_id_from,p_run_id_to,'N');
                  -- Remove record from memory table
                  t_msg_prv.DELETE(l_idx);
                  RETURN;
               END IF;
               l_idx := t_msg_prv.NEXT(l_idx);
            END LOOP;
         END IF;
         -- Create new version
         r_msg.msg_ivid := get_next_msg_ivid;
         r_msg.msg_irid := NVL(p_msg_irid,r_msg.msg_ivid);
         r_msg.run_id_from := p_run_id_from;
         r_msg.run_id_to := p_run_id_to;
         t_msg_ins(t_msg_ins.COUNT+1) := r_msg;
      END;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_save_msg;
      END IF;
      -- Check parameters
      l_last_run_id := get_last_run_id;
      r_run := get_run(
         l_run_id
      );
      IF r_run.run_id IS NOT NULL THEN
         l_run_id := r_run.run_id;
      END IF;
      assert(l_run_id IS NOT NULL, 'run non trouvé','run not found',l_where);
      assert(l_allow_concurrent_runs='Y' OR l_run_id=l_last_run_id
         ,'la sauvegarde n''est autorisée que pour le dernier run','save allowed only for last run',l_where);
      -- Load last version from database
      load_msg(
         t_msg=>t_msg_old
        ,p_qc_code=>p_qc_code
        ,p_app_alias=>p_app_alias
        ,p_object_owner=>p_object_owner
        ,p_object_type=>p_object_type
        ,p_object_name=>p_object_name
        ,p_run_id=>l_run_id
      );
      -- Load previous version from database
      load_msg(
         t_msg=>t_msg_prv
        ,p_qc_code=>p_qc_code
        ,p_app_alias=>p_app_alias
        ,p_object_owner=>p_object_owner
        ,p_object_type=>p_object_type
        ,p_object_name=>p_object_name
        ,p_run_id=>l_run_id-1
        ,p_date=>NULL
        ,p_run_id_to=>l_run_id/*-1*/
      );
      -- Ensure table is properly sorted
      t_msg_in1 := t_msg;
      sort_msg(t_msg_in1);
      -- Check records integrity
      FOR i IN 1..t_msg_in1.COUNT LOOP
         r_msg_new := t_msg_in1(i);
         check_msg(r_msg_new);
         t_msg_in1(i) := r_msg_new;
      END LOOP;
      t_msg_in2 := t_msg_in1;
      -- For each record to save
      FOR i IN 1..t_msg_in2.COUNT LOOP
         r_msg_new := t_msg_in2(i);
         -- Search for record in old table
         l_found := FALSE;
         j := t_msg_old.LAST;
         WHILE j IS NOT NULL AND NOT l_found LOOP
            r_msg_old := t_msg_old(j);
            l_found := compare_msg_uk(r_msg_new,r_msg_old,FALSE)=0;
            IF l_found THEN
               l_same := compare_msg_data(r_msg_new,r_msg_old);
               IF NOT l_same THEN
                  -- Do not delete record of current version
                  IF r_msg_old.run_id_from = l_run_id THEN
                     -- Preserve all version related columns (e.g. msg_ivid)
                     r_msg_new.msg_ivid := r_msg_old.msg_ivid;
                     r_msg_new.msg_irid := r_msg_old.msg_irid;
                     r_msg_new.run_id_from := r_msg_old.run_id_from;
                     -- Update record (instead of delete/insert)
                     update_msg(r_msg_new,r_msg_new.run_id_from,r_msg_old.run_id_to);
                     -- Remove from old to prevent deletion
                     t_msg_old.DELETE(j);
                  ELSE
                     -- Previous version will be closed below
                     -- (as record is not removed from old table)
                     NULL;
                     -- Create new version
                     insert_msg(r_msg_new
                        ,r_msg_old.msg_irid
                        ,l_run_id,r_msg_old.run_id_to);
                     t_msg_in2(i) := r_msg_new;
                  END IF;
               ELSE
                  -- Remove from old to prrun deletion
                  t_msg_old.DELETE(j);
               END IF;
            ELSE
               j := t_msg_old.PRIOR(j);
            END IF;
         END LOOP;
         IF NOT l_found THEN
            -- Create first version
            insert_msg(r_msg_new
               ,NULL
               ,l_run_id,NULL);
            t_msg_in2(i) := r_msg_new;
         END IF;
      END LOOP;
      -- Walk through records to delete
      j := t_msg_old.FIRST;
      WHILE j IS NOT NULL LOOP
         r_msg_old := t_msg_old(j);
         assert(r_msg_old.run_id_from <= l_run_id,'run_id_from invalide','invalid run_id_from',l_where);
         assert(r_msg_old.run_id_to IS NULL,'run_id_to invalide','invalid run_id_to',l_where);
         IF r_msg_old.run_id_to IS NULL THEN
            IF r_msg_old.run_id_from < l_run_id THEN
               update_msg(r_msg_old,r_msg_old.run_id_from,l_run_id/*-1*/);
            ELSE
               delete_msg(r_msg_old);
            END IF;
         ELSE
            IF r_msg_old.run_id_from = l_run_id THEN
               r_msg_old.run_id_from := l_run_id+1;
            ELSIF r_msg_old.run_id_to = l_run_id+1/**/ THEN
               r_msg_old.run_id_to := l_run_id/*-1*/;
            ELSE
               r_msg_tmp := r_msg_old;
               insert_msg(r_msg_tmp
                  ,r_msg_tmp.msg_irid
                  ,l_run_id+1,r_msg_tmp.run_id_to);
               r_msg_old.run_id_to := l_run_id/*-1*/;
            END IF;
            IF r_msg_old.run_id_from <= r_msg_old.run_id_to THEN
               update_msg(r_msg_old,r_msg_old.run_id_from,r_msg_old.run_id_to);
            ELSE
               delete_msg(r_msg_old);
            END IF;
         END IF;
         j := t_msg_old.NEXT(j);
      END LOOP;
      -- Bulk delete records
      IF t_msg_ivid_del.COUNT > 0 THEN
         FORALL i IN 1..t_msg_ivid_del.COUNT
         DELETE qc_run_msgs
          WHERE msg_ivid=t_msg_ivid_del(i)
         ;
         assert(SQL%ROWCOUNT=t_msg_ivid_del.COUNT,'la suppression a échoué','delete failed',l_where);
      END IF;
      -- Bulk update records
      IF t_msg_upd.COUNT > 0 THEN
         FORALL i IN 1..t_msg_upd.COUNT
         UPDATE qc_run_msgs
            SET ROW=t_msg_upd(i)
          WHERE msg_ivid=t_msg_ivid_upd(i)
         ;
         assert(SQL%ROWCOUNT=t_msg_upd.COUNT,'la mise à jour a échoué','update failed',l_where);
      END IF;
      -- Bulk insert records
      IF t_msg_ins.COUNT > 0 THEN
         FORALL i IN 1..t_msg_ins.COUNT
         INSERT INTO qc_run_msgs
         VALUES t_msg_ins(i)
         ;
         assert(SQL%ROWCOUNT=t_msg_ins.COUNT,'la création a échoué','insert failed',l_where);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_save_msg;
         END IF;
         RAISE;
   END;
   ---
   -- Insert a record into database table
   ---
   PROCEDURE insert_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_msg msg_table;
      l_idx INTEGER;
      l_where VARCHAR2(100) := 'insert_msg(): ';
      r_msg_in qc_run_msgs%ROWTYPE := r_msg;
   BEGIN
      load_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_msg.COUNT=0,'L''enregistrement à créer existe déjà !','Record to create already exists!',l_where);
      t_msg(1) := r_msg_in;
      save_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
   END;
   ---
   -- Update an existing record in database table
   ---
   PROCEDURE update_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_msg msg_table;
      l_where VARCHAR2(100) := 'update_msg(): ';
      r_msg_in qc_run_msgs%ROWTYPE := r_msg;
   BEGIN
      load_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_msg.COUNT=1,'Enregistrement à mettre à jour non trouvé !','Record to update not found!',l_where);
      t_msg(1) := r_msg_in;
      save_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
   END
   ;
   ---
   -- Delete an existing record from database table
   ---
   PROCEDURE delete_msg (
      r_msg IN qc_run_msgs%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_msg msg_table;
      l_where VARCHAR2(100) := 'delete_msg(): ';
      r_msg_in qc_run_msgs%ROWTYPE := r_msg;
   BEGIN
      load_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_msg.COUNT=1,'Enregistrement à supprimer non trouvé !','Record to delete not found!',l_where);
      t_msg.DELETE;
      save_msg(
         t_msg => t_msg
       , p_qc_code => r_msg_in.qc_code
       , p_app_alias => r_msg_in.app_alias
       , p_object_owner => r_msg_in.object_owner
       , p_object_type => r_msg_in.object_type
       , p_object_name => r_msg_in.object_name
       , p_run_id => l_run_id
      );
   END
   ;
   ---
   -- Count records impacted by an run
   ---
   FUNCTION count_impacted_records (
      p_run_id qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER
   IS
      CURSOR c_msg (
         p_run_id qc_runs.run_id%TYPE
      )
      IS
         SELECT COUNT(*)
           FROM qc_run_msgs
          WHERE 1=1
            AND (run_id_from = p_run_id OR run_id_to = p_run_id/* - 1*/)
      ;
      l_count INTEGER;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_where VARCHAR2(100) := 'count_impacted_records(): ';
   BEGIN
      -- Check parameters
      assert(l_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      OPEN c_msg(l_run_id);
      FETCH c_msg INTO l_count;
      CLOSE c_msg;
      RETURN l_count;
   END;
   ---
   -- Restore records from a previous version
   ---
   PROCEDURE restore_msg (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_msg msg_table;
      l_where VARCHAR2(100) := 'restore_msg(): ';
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_restore_msg;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- Load specified run/version
      load_msg(
         t_msg
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_object_name
        ,p_run_id
      );
      -- Save as last (draft) version
      save_msg(
         t_msg
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_object_name
        ,p_run_id_to
      );
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_restore_msg;
         END IF;
         RAISE;
   END;
   ---
   -- Restore all records from a previous version
   ---
   PROCEDURE restore_all_msg (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_msg msg_table;
      t_msg_nxt msg_table;
      l_where VARCHAR2(100) := 'restore_all_msg(): ';
      CURSOR c_msg
      IS
         SELECT DISTINCT
               qc_code
              ,app_alias
              ,object_owner
              ,object_type
              ,object_name
           FROM qc_run_msgs
          WHERE 1=1
            AND (run_id_from > p_run_id OR run_id_to > p_run_id/* - 1*/)
      ;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_restore_all_msg;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- For each modified dimension
      FOR r_msg IN c_msg
      LOOP
         -- Restore given version into given version
         restore_msg(
            p_qc_code=>r_msg.qc_code
           ,p_app_alias=>r_msg.app_alias
           ,p_object_owner=>r_msg.object_owner
           ,p_object_type=>r_msg.object_type
           ,p_object_name=>r_msg.object_name
          , p_run_id=>p_run_id
          , p_run_id_to=>p_run_id_to
         );
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_restore_all_msg;
         END IF;
         RAISE;
   END;
   ---
   -- Undo changes made by an run
   ---
   PROCEDURE undo_msg (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_msg msg_table;
      t_msg_nxt msg_table;
      l_where VARCHAR2(100) := 'undo_msg(): ';
      CURSOR c_msg
      IS
         SELECT DISTINCT
               qc_code
              ,app_alias
              ,object_owner
              ,object_type
              ,object_name
           FROM qc_run_msgs
          WHERE 1=1
            AND (run_id_from = p_run_id OR run_id_to = p_run_id/* - 1*/)
      ;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_undo_msg;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- For each modified dimension
      FOR r_msg IN c_msg
      LOOP
         -- Restore version just before
         restore_msg(
            p_qc_code=>r_msg.qc_code
           ,p_app_alias=>r_msg.app_alias
           ,p_object_owner=>r_msg.object_owner
           ,p_object_type=>r_msg.object_type
           ,p_object_name=>r_msg.object_name
          , p_run_id=>p_run_id-1
          , p_run_id_to=>NVL(p_run_id_to,p_run_id)
         );
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_undo_msg;
         END IF;
         RAISE;
   END;
   ---
   -- Compare versions
   ---
   FUNCTION compare_versions (
      p_qc_code IN qc_run_msgs.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_msgs.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_msgs.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_msgs.object_type%TYPE := NULL
     ,p_object_name IN qc_run_msgs.object_name%TYPE := NULL
     ,p_run_id_1 IN qc_runs.run_id%TYPE := NULL
     ,p_run_id_2 IN qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER -- 0=same, <>=different
   IS
      t_msg_1 msg_table;
      t_msg_2 msg_table;
      l_where VARCHAR2(100) := 'compare_versions(): ';
      l_run_id_1 qc_runs.run_id%TYPE := p_run_id_1;
      l_run_id_2 qc_runs.run_id%TYPE;
      l_ret INTEGER;
   BEGIN
      -- Check parameters
      assert(l_run_id_1 IS NOT NULL, 'le paramètre "p_run_id_1" est obligatoire', 'parameter "p_run_id_1" is mandatory',l_where);
      l_run_id_2 := NVL(p_run_id_2,l_run_id_1-1);
      assert(l_run_id_2 IS NOT NULL, 'le paramètre "p_run_id_2" est obligatoire', 'parameter "p_run_id_2" is mandatory',l_where);
      -- No need to compare same runs
      IF l_run_id_1 = l_run_id_2 THEN
         GOTO return_same;
      END IF;
      -- Load first run/version
      load_msg(
         t_msg_1
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_object_name
        ,l_run_id_1
      );
      -- Load second run/version
      load_msg(
         t_msg_2
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_object_name
        ,l_run_id_2
      );
      -- No need to compare if not same count
      IF t_msg_1.COUNT != t_msg_2.COUNT THEN
         GOTO return_diff;
      END IF;
      -- Compare all records
      FOR i IN 1..t_msg_1.COUNT LOOP
         IF NOT compare_msg_data(t_msg_1(i),t_msg_2(i))
         THEN
            GOTO return_diff;
         END IF;
      END LOOP;
      <<return_same>>
      l_ret := 0; -- same
      GOTO end_proc;
      <<return_diff>>
      l_ret := 1; -- diff
      <<end_proc>>
      RETURN l_ret;
   END;
BEGIN
   NULL;
END;
/

