CREATE OR REPLACE PACKAGE BODY qc_utility_stat AS
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
   FUNCTION t (
      p_stat_fra IN VARCHAR2
     ,p_stat_eng IN VARCHAR2
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
      l_stat VARCHAR2(4000) := p_stat_eng;
      l_pos INTEGER;
   BEGIN
      FOR i IN 1..9 LOOP
         l_pos := INSTR(l_stat,':'||i);
         EXIT WHEN l_pos<=0;
         l_stat := SUBSTR(l_stat,1,l_pos-1)
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
               || SUBSTR(l_stat,l_pos+2);
      END LOOP;
      RETURN l_stat;
   END;
   ---
   -- Raise application error
   ---
   PROCEDURE raise_error (
      p_error_stat IN VARCHAR2
    , p_where IN VARCHAR2 := NULL
   )
   IS
      l_stat VARCHAR2(4000);
   BEGIN
      raise_application_error(-20000,p_error_stat);
   END;
   ---
   -- Check assertion and return error message in user's language if false
   -- Substitute :n parameters if any (n in the range 1-9)
   ---
   PROCEDURE assert (
      p_assertion IN BOOLEAN
     ,p_err_stat_fra IN VARCHAR2
     ,p_err_stat_eng IN VARCHAR2 := NULL
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
         raise_error(t(p_err_stat_fra,NVL(p_err_stat_eng,p_err_stat_fra),p1,p2,p3,p4,p5,p6,p7,p8,p9),p_where);
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
   FUNCTION compare_stat_uk (
      r_stat_new IN qc_run_stats%ROWTYPE
     ,r_stat_old IN qc_run_stats%ROWTYPE
     ,p_ignore_date_from IN BOOLEAN
   )
   RETURN INTEGER
   IS
   BEGIN
      -- Compare uk colums
      IF r_stat_new.qc_code IS NULL AND r_stat_old.qc_code IS NOT NULL THEN RETURN 1; END IF;
      IF r_stat_new.qc_code IS NOT NULL AND r_stat_old.qc_code IS NULL THEN RETURN -1; END IF;
      IF r_stat_new.qc_code > r_stat_old.qc_code THEN RETURN 1; END IF;
      IF r_stat_new.qc_code < r_stat_old.qc_code THEN RETURN -1; END IF;
      IF r_stat_new.app_alias IS NULL AND r_stat_old.app_alias IS NOT NULL THEN RETURN 1; END IF;
      IF r_stat_new.app_alias IS NOT NULL AND r_stat_old.app_alias IS NULL THEN RETURN -1; END IF;
      IF r_stat_new.app_alias > r_stat_old.app_alias THEN RETURN 1; END IF;
      IF r_stat_new.app_alias < r_stat_old.app_alias THEN RETURN -1; END IF;
      IF r_stat_new.object_owner IS NULL AND r_stat_old.object_owner IS NOT NULL THEN RETURN 1; END IF;
      IF r_stat_new.object_owner IS NOT NULL AND r_stat_old.object_owner IS NULL THEN RETURN -1; END IF;
      IF r_stat_new.object_owner > r_stat_old.object_owner THEN RETURN 1; END IF;
      IF r_stat_new.object_owner < r_stat_old.object_owner THEN RETURN -1; END IF;
      IF r_stat_new.object_type IS NULL AND r_stat_old.object_type IS NOT NULL THEN RETURN 1; END IF;
      IF r_stat_new.object_type IS NOT NULL AND r_stat_old.object_type IS NULL THEN RETURN -1; END IF;
      IF r_stat_new.object_type > r_stat_old.object_type THEN RETURN 1; END IF;
      IF r_stat_new.object_type < r_stat_old.object_type THEN RETURN -1; END IF;
      RETURN 0;
   END;
   ---
   -- Compact table (remove holes)
   ---
   PROCEDURE compact_stat (
      t_stat IN OUT stat_table
   )
   IS
      l_idx INTEGER;
      l_nxt INTEGER;
      l_ins INTEGER;
   BEGIN
      l_ins := 1;
      l_idx := t_stat.FIRST;
      WHILE l_idx IS NOT NULL LOOP
         l_nxt := t_stat.NEXT(l_idx);
         IF l_idx > l_ins THEN
            t_stat(l_ins) := t_stat(l_idx);
            t_stat.DELETE(l_idx);
         END IF;
         l_ins := l_ins + 1;
         l_idx := l_nxt;
      END LOOP;
   END;
   ---
   -- Right shift records as of given position
   -- (i.e. make a hole at given pos for insert)
   ---
   PROCEDURE right_shift_stat (
      t_stat IN OUT stat_table
     ,p_pos IN INTEGER
   )
   IS
   BEGIN
      FOR i IN REVERSE p_pos..t_stat.COUNT LOOP
         t_stat(i+1) := t_stat(i);
      END LOOP;
   END;
   ---
   -- Left shift records as of given position
   -- (i.e. delete record at given position)
   ---
   PROCEDURE left_shift_stat (
      t_stat IN OUT stat_table
     ,p_pos IN INTEGER
   )
   IS
   BEGIN
      FOR i IN p_pos..t_stat.COUNT-1 LOOP
         t_stat(i) := t_stat(i+1);
      END LOOP;
      t_stat.DELETE(t_stat.COUNT);
   END;
   ---
   -- Sort table of records
   -- !!! seems bugged !!!
   ---
--   PROCEDURE sort_stat (
--      t_stat IN OUT stat_table
--   )
--   IS
--      t_stat_1 stat_table;
--      t_stat_2 stat_table;
--      PROCEDURE split_stat(
--         t_stat IN stat_table
--        ,t_stat_1 IN OUT stat_table
--        ,t_stat_2 IN OUT stat_table
--      )
--      IS
--         l_idx_midle NUMBER(5);
--      BEGIN
--         l_idx_midle := FLOOR(t_stat.COUNT / 2);
--         t_stat_1.DELETE;
--         t_stat_2.DELETE;
--         FOR l_idx IN 1..l_idx_midle LOOP
--            t_stat_1(t_stat_1.COUNT+1) := t_stat(l_idx);
--         END LOOP;
--         l_idx_midle := l_idx_midle + 1;
--         FOR l_idx IN l_idx_midle..t_stat.COUNT LOOP
--            t_stat_2(t_stat_2.COUNT+1) := t_stat(l_idx);
--         END LOOP;
--      END;
--      PROCEDURE merge_stat(
--         t_stat IN OUT stat_table
--        ,t_stat_1 IN OUT stat_table
--        ,t_stat_2 IN OUT stat_table
--      )
--      IS
--         l_idx NUMBER(5);
--         l_idx_1 NUMBER(5);
--         l_idx_2 NUMBER(5);
--      BEGIN
--         t_stat.DELETE;
--         l_idx_1 := t_stat_1.FIRST;
--         l_idx_2 := t_stat_2.FIRST;
--         WHILE l_idx_1 IS NOT NULL AND l_idx_2 IS NOT NULL
--         LOOP
--            IF compare_stat_uk(t_stat_1(l_idx_1),t_stat_2(l_idx_2),FALSE) < 0
--            THEN
--               t_stat(t_stat.COUNT+1) := t_stat_1(l_idx_1);
--               l_idx_1 := t_stat_1.NEXT(l_idx_1);
--            ELSE
--               t_stat(t_stat.COUNT+1) := t_stat_2(l_idx_2);
--               l_idx_2 := t_stat_2.NEXT(l_idx_2);
--            END IF;
--         END LOOP;
--         IF l_idx_1 IS NOT NULL THEN
--            WHILE l_idx_1 IS NOT NULL LOOP
--               t_stat(t_stat.COUNT+1) := t_stat_1(l_idx_1);
--               l_idx_1 := t_stat_1.NEXT(l_idx_1);
--            END LOOP;
--         ELSIF l_idx_2 IS NOT NULL THEN
--            WHILE l_idx_2 IS NOT NULL LOOP
--               t_stat(t_stat.COUNT+1) := t_stat_2(l_idx_2);
--               l_idx_2 := t_stat_2.NEXT(l_idx_2);
--            END LOOP;
--         END IF;
--      END;
--   BEGIN
--      compact_stat(t_stat);
--      IF t_stat.COUNT > 1 THEN
--         split_stat(t_stat,t_stat_1,t_stat_2);
--         sort_stat(t_stat_1);
--         sort_stat(t_stat_2);
--         merge_stat(t_stat,t_stat_1,t_stat_2);
--      END if;
--   END;
   ---
   -- Sort table of records
   ---
   PROCEDURE sort_stat (
      t_stat IN OUT stat_table
   )
   IS
      r_stat qc_run_stats%ROWTYPE;
   BEGIN
      compact_stat(t_stat);
      FOR i IN 1..t_stat.COUNT-1 LOOP
         FOR j IN i+1..t_stat.COUNT LOOP
            IF compare_stat_uk(t_stat(i),t_stat(j),FALSE) > 0 THEN
               r_stat := t_stat(j);
               t_stat(j) := t_stat(i);
               t_stat(i) := r_stat;
            END IF;
         END LOOP;
      END LOOP;
   END;
   --
   -- Print a record
   --
   PROCEDURE print_stat (
      r_stat IN qc_run_stats%ROWTYPE
   )
   IS
   BEGIN
      NULL;
      sys.dbms_output.put_line('stat_ivid='||r_stat.stat_ivid);
      sys.dbms_output.put_line('stat_irid='||r_stat.stat_irid);
      sys.dbms_output.put_line('run_id_from='||r_stat.run_id_from);
      sys.dbms_output.put_line('run_id_to='||r_stat.run_id_to);
      sys.dbms_output.put_line('qc_code='||r_stat.qc_code);
      sys.dbms_output.put_line('app_alias='||r_stat.app_alias);
      sys.dbms_output.put_line('object_owner='||r_stat.object_owner);
      sys.dbms_output.put_line('object_type='||r_stat.object_type);
      sys.dbms_output.put_line('object_count='||r_stat.object_count);
   END;
   ---
   -- Get next record id
   ---
   FUNCTION get_next_stat_ivid
   RETURN qc_run_stats.stat_ivid%TYPE
   IS
      CURSOR c_seq IS
         SELECT qc_stat_seq.nextval
           FROM dual
         ;
      l_stat_ivid qc_run_stats.stat_ivid%TYPE;
   BEGIN
      OPEN c_seq;
      FETCH c_seq INTO l_stat_ivid;
      CLOSE c_seq;
      RETURN l_stat_ivid;
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
   FUNCTION get_stat (
      p_stat_irid IN qc_run_stats.stat_irid%TYPE
     ,p_run_id IN qc_runs.run_id%TYPE
   )
   RETURN qc_run_stats%ROWTYPE
   IS
      r_stat qc_run_stats%ROWTYPE;
      CURSOR c_stat
      IS
         SELECT *
           FROM qc_run_stats
          WHERE stat_irid = p_stat_irid
            AND p_run_id BETWEEN run_id_from AND NVL(run_id_to-1/**/,p_run_id)
      ;
   BEGIN
      OPEN c_stat;
      FETCH c_stat INTO r_stat;
      CLOSE c_stat;
      RETURN r_stat;
   END;
   ---
   -- Load records from database into memory table
   ---
   PROCEDURE load_stat (
      t_stat OUT stat_table
     ,p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_date IN DATE := NULL
     ,p_run_id_to IN qc_run_stats.run_id_to%TYPE := NULL
     ,p_run_id_from IN qc_run_stats.run_id_to%TYPE := NULL
   )
   IS
      CURSOR c_stat (
         p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
        ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
        ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
        ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
        ,p_run_id IN qc_runs.run_id%TYPE
        ,p_date IN DATE := NULL
        ,p_run_id_to IN qc_run_stats.run_id_to%TYPE := NULL
        ,p_run_id_from IN qc_run_stats.run_id_to%TYPE := NULL
      ) IS
         SELECT *
           FROM qc_run_stats
          WHERE 1=1
            AND (p_qc_code IS NULL OR qc_code = p_qc_code)
            AND (p_app_alias IS NULL OR app_alias = p_app_alias)
            AND (p_object_owner IS NULL OR object_owner = p_object_owner)
            AND (p_object_type IS NULL OR object_type = p_object_type)
            AND (p_run_id_from IS NOT NULL OR p_run_id BETWEEN run_id_from AND NVL(run_id_to-1/**/,p_run_id))
            AND (p_run_id_to IS NULL OR run_id_to = p_run_id_to)
            AND (p_run_id_from IS NULL OR run_id_from >= p_run_id_from)
          ORDER BY
                   qc_code
                 , app_alias
                 , object_owner
                 , object_type
      ;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_where VARCHAR2(100) := 'load_stat(): ';
   BEGIN
      -- No run found means no data exists => return empty table
      IF l_run_id IS NULL AND p_run_id_from IS NULL THEN
         t_stat.DELETE;
         GOTO end_proc;
      END IF;
      -- Do load
      t_stat.DELETE;
      OPEN c_stat(
         p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,l_run_id
        ,p_date
        ,p_run_id_to
        ,p_run_id_from
      );
      FETCH c_stat BULK COLLECT INTO t_stat;
      CLOSE c_stat;
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
   FUNCTION compare_stat_data (
      r_stat_new IN qc_run_stats%ROWTYPE
     ,r_stat_old IN qc_run_stats%ROWTYPE
   )
   RETURN BOOLEAN
   IS
   BEGIN
      -- Compare all fields but pk, uk, audit, versioning columns
      RETURN (
         1=1
--         AND equals(r_stat_old.qc_code,r_stat_new.qc_code)
--         AND equals(r_stat_old.app_alias,r_stat_new.app_alias)
--         AND equals(r_stat_old.object_owner,r_stat_new.object_owner)
--         AND equals(r_stat_old.object_type,r_stat_new.object_type)
         AND equals(r_stat_old.object_count,r_stat_new.object_count)
      );
   END;
   ---
   -- Check record consistency
   ---
   PROCEDURE check_stat (
      r_stat IN OUT qc_run_stats%ROWTYPE
   )
   IS
      l_where VARCHAR2(100) := 'check_stat(): ';
   BEGIN
      assert(r_stat.qc_code IS NOT NULL, 'le champs "qc_code" est obligatoire','filed "qc_code" is mandatory',l_where);
      assert(r_stat.app_alias IS NOT NULL, 'le champs "app_alias" est obligatoire','filed "app_alias" is mandatory',l_where);
      assert(r_stat.object_owner IS NOT NULL, 'le champs "object_owner" est obligatoire','filed "object_owner" is mandatory',l_where);
      assert(r_stat.object_type IS NOT NULL, 'le champs "object_type" est obligatoire','filed "object_type" is mandatory',l_where);
   END;
   ---
   -- Save memory table of records into database
   ---
   PROCEDURE save_stat (
      t_stat IN stat_table
     ,p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
   )
   IS
      l_allow_concurrent_runs VARCHAR2(1) := 'N';
      l_found BOOLEAN;
      l_same BOOLEAN;
      j INTEGER;
      r_stat_old qc_run_stats%ROWTYPE;
      r_stat_new qc_run_stats%ROWTYPE;
      r_stat_tmp qc_run_stats%ROWTYPE;
      r_run qc_runs%ROWTYPE;
      t_stat_ins stat_table;
      t_stat_upd stat_table;
      t_stat_ivid_upd stat_ivid_table;
      t_stat_ivid_del stat_ivid_table;
      t_stat_old stat_table;
      t_stat_prv stat_table;
      t_stat_in1 stat_table;
      t_stat_in2 stat_table;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_last_run_id qc_runs.run_id%TYPE;
      l_where VARCHAR2(100) := 'save_stat(): ';
      -- Delete record
      PROCEDURE delete_stat (
         r_stat IN qc_run_stats%ROWTYPE
      )
      IS
      BEGIN
         t_stat_ivid_del(t_stat_ivid_del.COUNT+1) := r_stat.stat_ivid;
      END;
      -- Update record
      PROCEDURE update_stat (
         r_stat IN OUT qc_run_stats%ROWTYPE
        ,p_run_id_from IN qc_run_stats.run_id_from%TYPE
        ,p_run_id_to IN qc_run_stats.run_id_to%TYPE
        ,p_optimisation IN VARCHAR2 := 'Y'
      )
      IS
         l_idx INTEGER;
         r_stat_old qc_run_stats%ROWTYPE;
         r_stat_new qc_run_stats%ROWTYPE;
      BEGIN
         -- Optimisation: check for identical closed version
         IF p_run_id_from = l_run_id AND p_optimisation = 'Y' THEN
            r_stat_new := r_stat;
            l_idx := t_stat_prv.FIRST;
            WHILE l_idx IS NOT NULL LOOP
               r_stat_old := t_stat_prv(l_idx);
               IF compare_stat_uk(r_stat_new,r_stat_old,FALSE)=0 AND compare_stat_data(r_stat_new,r_stat_old) THEN
                  -- Reopen closed version
                  update_stat(r_stat_old,r_stat_old.run_id_from,p_run_id_to,'N');
                  -- Delete record to update
                  delete_stat(r_stat_new);
                  -- Remove record from memory table
                  t_stat_prv.DELETE(l_idx);
                  RETURN;
               END IF;
               l_idx := t_stat_prv.NEXT(l_idx);
            END LOOP;
         END IF;
         r_stat.run_id_from := p_run_id_from;
         r_stat.run_id_to := p_run_id_to;
         t_stat_upd(t_stat_upd.COUNT+1) := r_stat;
         t_stat_ivid_upd(t_stat_ivid_upd.COUNT+1) := r_stat.stat_ivid;
      END;
      -- Insert record
      PROCEDURE insert_stat (
         r_stat IN OUT qc_run_stats%ROWTYPE
        ,p_stat_irid IN qc_run_stats.stat_irid%TYPE
        ,p_run_id_from IN qc_run_stats.run_id_from%TYPE
        ,p_run_id_to IN qc_run_stats.run_id_to%TYPE
      )
      IS
         l_idx INTEGER;
         r_stat_old qc_run_stats%ROWTYPE;
         r_stat_new qc_run_stats%ROWTYPE;
      BEGIN
         -- Optimisation: check for identical closed version
         IF p_run_id_from = l_run_id THEN
            r_stat_new := r_stat;
            l_idx := t_stat_prv.FIRST;
            WHILE l_idx IS NOT NULL LOOP
               r_stat_old := t_stat_prv(l_idx);
               IF compare_stat_uk(r_stat_new,r_stat_old,FALSE)=0 AND compare_stat_data(r_stat_new,r_stat_old) THEN
                  -- Reopen closed version
                  update_stat(r_stat_old,r_stat_old.run_id_from,p_run_id_to,'N');
                  -- Remove record from memory table
                  t_stat_prv.DELETE(l_idx);
                  RETURN;
               END IF;
               l_idx := t_stat_prv.NEXT(l_idx);
            END LOOP;
         END IF;
         -- Create new version
         r_stat.stat_ivid := get_next_stat_ivid;
         r_stat.stat_irid := NVL(p_stat_irid,r_stat.stat_ivid);
         r_stat.run_id_from := p_run_id_from;
         r_stat.run_id_to := p_run_id_to;
         t_stat_ins(t_stat_ins.COUNT+1) := r_stat;
      END;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_save_stat;
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
      load_stat(
         t_stat=>t_stat_old
        ,p_qc_code=>p_qc_code
        ,p_app_alias=>p_app_alias
        ,p_object_owner=>p_object_owner
        ,p_object_type=>p_object_type
        ,p_run_id=>l_run_id
      );
      -- Load previous version from database
      load_stat(
         t_stat=>t_stat_prv
        ,p_qc_code=>p_qc_code
        ,p_app_alias=>p_app_alias
        ,p_object_owner=>p_object_owner
        ,p_object_type=>p_object_type
        ,p_run_id=>l_run_id-1
        ,p_date=>NULL
        ,p_run_id_to=>l_run_id/*-1*/
      );
      -- Ensure table is properly sorted
      t_stat_in1 := t_stat;
      sort_stat(t_stat_in1);
      -- Check records integrity
      FOR i IN 1..t_stat_in1.COUNT LOOP
         r_stat_new := t_stat_in1(i);
         check_stat(r_stat_new);
         t_stat_in1(i) := r_stat_new;
      END LOOP;
      t_stat_in2 := t_stat_in1;
      -- For each record to save
      FOR i IN 1..t_stat_in2.COUNT LOOP
         r_stat_new := t_stat_in2(i);
         -- Search for record in old table
         l_found := FALSE;
         j := t_stat_old.LAST;
         WHILE j IS NOT NULL AND NOT l_found LOOP
            r_stat_old := t_stat_old(j);
            l_found := compare_stat_uk(r_stat_new,r_stat_old,FALSE)=0;
            IF l_found THEN
               l_same := compare_stat_data(r_stat_new,r_stat_old);
               IF NOT l_same THEN
                  -- Do not delete record of current version
                  IF r_stat_old.run_id_from = l_run_id THEN
                     -- Preserve all version related columns (e.g. stat_ivid)
                     r_stat_new.stat_ivid := r_stat_old.stat_ivid;
                     r_stat_new.stat_irid := r_stat_old.stat_irid;
                     r_stat_new.run_id_from := r_stat_old.run_id_from;
                     -- Update record (instead of delete/insert)
                     update_stat(r_stat_new,r_stat_new.run_id_from,r_stat_old.run_id_to);
                     -- Remove from old to prevent deletion
                     t_stat_old.DELETE(j);
                  ELSE
                     -- Previous version will be closed below
                     -- (as record is not removed from old table)
                     NULL;
                     -- Create new version
                     insert_stat(r_stat_new
                        ,r_stat_old.stat_irid
                        ,l_run_id,r_stat_old.run_id_to);
                     t_stat_in2(i) := r_stat_new;
                  END IF;
               ELSE
                  -- Remove from old to prrun deletion
                  t_stat_old.DELETE(j);
               END IF;
            ELSE
               j := t_stat_old.PRIOR(j);
            END IF;
         END LOOP;
         IF NOT l_found THEN
            -- Create first version
            insert_stat(r_stat_new
               ,NULL
               ,l_run_id,NULL);
            t_stat_in2(i) := r_stat_new;
         END IF;
      END LOOP;
      -- Walk through records to delete
      j := t_stat_old.FIRST;
      WHILE j IS NOT NULL LOOP
         r_stat_old := t_stat_old(j);
         assert(r_stat_old.run_id_from <= l_run_id,'run_id_from invalide','invalid run_id_from',l_where);
         assert(r_stat_old.run_id_to IS NULL,'run_id_to invalide','invalid run_id_to',l_where);
         IF r_stat_old.run_id_to IS NULL THEN
            IF r_stat_old.run_id_from < l_run_id THEN
               update_stat(r_stat_old,r_stat_old.run_id_from,l_run_id/*-1*/);
            ELSE
               delete_stat(r_stat_old);
            END IF;
         ELSE
            IF r_stat_old.run_id_from = l_run_id THEN
               r_stat_old.run_id_from := l_run_id+1;
            ELSIF r_stat_old.run_id_to = l_run_id+1/**/ THEN
               r_stat_old.run_id_to := l_run_id/*-1*/;
            ELSE
               r_stat_tmp := r_stat_old;
               insert_stat(r_stat_tmp
                  ,r_stat_tmp.stat_irid
                  ,l_run_id+1,r_stat_tmp.run_id_to);
               r_stat_old.run_id_to := l_run_id/*-1*/;
            END IF;
            IF r_stat_old.run_id_from <= r_stat_old.run_id_to THEN
               update_stat(r_stat_old,r_stat_old.run_id_from,r_stat_old.run_id_to);
            ELSE
               delete_stat(r_stat_old);
            END IF;
         END IF;
         j := t_stat_old.NEXT(j);
      END LOOP;
      -- Bulk delete records
      IF t_stat_ivid_del.COUNT > 0 THEN
         FORALL i IN 1..t_stat_ivid_del.COUNT
         DELETE qc_run_stats
          WHERE stat_ivid=t_stat_ivid_del(i)
         ;
         assert(SQL%ROWCOUNT=t_stat_ivid_del.COUNT,'la suppression a échoué','delete failed',l_where);
      END IF;
      -- Bulk update records
      IF t_stat_upd.COUNT > 0 THEN
         FORALL i IN 1..t_stat_upd.COUNT
         UPDATE qc_run_stats
            SET ROW=t_stat_upd(i)
          WHERE stat_ivid=t_stat_ivid_upd(i)
         ;
         assert(SQL%ROWCOUNT=t_stat_upd.COUNT,'la mise à jour a échoué','update failed',l_where);
      END IF;
      -- Bulk insert records
      IF t_stat_ins.COUNT > 0 THEN
         FORALL i IN 1..t_stat_ins.COUNT
         INSERT INTO qc_run_stats
         VALUES t_stat_ins(i)
         ;
         assert(SQL%ROWCOUNT=t_stat_ins.COUNT,'la création a échoué','insert failed',l_where);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_save_stat;
         END IF;
         RAISE;
   END;
   ---
   -- Insert a record into database table
   ---
   PROCEDURE insert_stat (
      r_stat IN qc_run_stats%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_stat stat_table;
      l_idx INTEGER;
      l_where VARCHAR2(100) := 'insert_stat(): ';
      r_stat_in qc_run_stats%ROWTYPE := r_stat;
   BEGIN
      load_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_stat.COUNT=0,'L''enregistrement à créer existe déjà !','Record to create already exists!',l_where);
      t_stat(1) := r_stat_in;
      save_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
       , p_run_id => l_run_id
      );
   END;
   ---
   -- Update an existing record in database table
   ---
   PROCEDURE update_stat (
      r_stat IN qc_run_stats%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_stat stat_table;
      l_where VARCHAR2(100) := 'update_stat(): ';
      r_stat_in qc_run_stats%ROWTYPE := r_stat;
   BEGIN
      load_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_stat.COUNT=1,'Enregistrement à mettre à jour non trouvé !','Record to update not found!',l_where);
      t_stat(1) := r_stat_in;
      save_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
       , p_run_id => l_run_id
      );
   END
   ;
   ---
   -- Delete an existing record from database table
   ---
   PROCEDURE delete_stat (
      r_stat IN qc_run_stats%ROWTYPE
     ,p_run_id IN qc_runs.run_id%TYPE := NULL
     ,p_no_check IN VARCHAR2 := 'N'
   )
   IS
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      t_stat stat_table;
      l_where VARCHAR2(100) := 'delete_stat(): ';
      r_stat_in qc_run_stats%ROWTYPE := r_stat;
   BEGIN
      load_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
       , p_run_id => l_run_id
      );
      assert(NVL(p_no_check,'N') = 'Y' OR t_stat.COUNT=1,'Enregistrement à supprimer non trouvé !','Record to delete not found!',l_where);
      t_stat.DELETE;
      save_stat(
         t_stat => t_stat
       , p_qc_code => r_stat_in.qc_code
       , p_app_alias => r_stat_in.app_alias
       , p_object_owner => r_stat_in.object_owner
       , p_object_type => r_stat_in.object_type
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
      CURSOR c_stat (
         p_run_id qc_runs.run_id%TYPE
      )
      IS
         SELECT COUNT(*)
           FROM qc_run_stats
          WHERE 1=1
            AND (run_id_from = p_run_id OR run_id_to = p_run_id/* - 1*/)
      ;
      l_count INTEGER;
      l_run_id qc_runs.run_id%TYPE := p_run_id;
      l_where VARCHAR2(100) := 'count_impacted_records(): ';
   BEGIN
      -- Check parameters
      assert(l_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      OPEN c_stat(l_run_id);
      FETCH c_stat INTO l_count;
      CLOSE c_stat;
      RETURN l_count;
   END;
   ---
   -- Restore records from a previous version
   ---
   PROCEDURE restore_stat (
      p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_stat stat_table;
      l_where VARCHAR2(100) := 'restore_stat(): ';
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_restore_stat;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- Load specified run/version
      load_stat(
         t_stat
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_run_id
      );
      -- Save as last (draft) version
      save_stat(
         t_stat
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,p_run_id_to
      );
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_restore_stat;
         END IF;
         RAISE;
   END;
   ---
   -- Restore all records from a previous version
   ---
   PROCEDURE restore_all_stat (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_stat stat_table;
      t_stat_nxt stat_table;
      l_where VARCHAR2(100) := 'restore_all_stat(): ';
      CURSOR c_stat
      IS
         SELECT DISTINCT
               qc_code
              ,app_alias
              ,object_owner
              ,object_type
           FROM qc_run_stats
          WHERE 1=1
            AND (run_id_from > p_run_id OR run_id_to > p_run_id/* - 1*/)
      ;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_restore_all_stat;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- For each modified dimension
      FOR r_stat IN c_stat
      LOOP
         -- Restore given version into given version
         restore_stat(
            p_qc_code=>r_stat.qc_code
           ,p_app_alias=>r_stat.app_alias
           ,p_object_owner=>r_stat.object_owner
           ,p_object_type=>r_stat.object_type
          , p_run_id=>p_run_id
          , p_run_id_to=>p_run_id_to
         );
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_restore_all_stat;
         END IF;
         RAISE;
   END;
   ---
   -- Undo changes made by an run
   ---
   PROCEDURE undo_stat (
      p_run_id IN qc_runs.run_id%TYPE
     ,p_run_id_to IN qc_runs.run_id%TYPE := NULL
   )
   IS
      t_stat stat_table;
      t_stat_nxt stat_table;
      l_where VARCHAR2(100) := 'undo_stat(): ';
      CURSOR c_stat
      IS
         SELECT DISTINCT
               qc_code
              ,app_alias
              ,object_owner
              ,object_type
           FROM qc_run_stats
          WHERE 1=1
            AND (run_id_from = p_run_id OR run_id_to = p_run_id/* - 1*/)
      ;
   BEGIN
      IF NVL(get_context('disable_savepoints'),'N')='N' THEN
         SAVEPOINT before_undo_stat;
      END IF;
      -- Check parameters
      assert(p_run_id IS NOT NULL, 'le paramètre "p_run_id" est obligatoire', 'parameter "p_run_id" is mandatory',l_where);
      -- For each modified dimension
      FOR r_stat IN c_stat
      LOOP
         -- Restore version just before
         restore_stat(
            p_qc_code=>r_stat.qc_code
           ,p_app_alias=>r_stat.app_alias
           ,p_object_owner=>r_stat.object_owner
           ,p_object_type=>r_stat.object_type
          , p_run_id=>p_run_id-1
          , p_run_id_to=>NVL(p_run_id_to,p_run_id)
         );
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         IF NVL(get_context('disable_savepoints'),'N')='N' THEN
            ROLLBACK TO before_undo_stat;
         END IF;
         RAISE;
   END;
   ---
   -- Compare versions
   ---
   FUNCTION compare_versions (
      p_qc_code IN qc_run_stats.qc_code%TYPE := NULL
     ,p_app_alias IN qc_run_stats.app_alias%TYPE := NULL
     ,p_object_owner IN qc_run_stats.object_owner%TYPE := NULL
     ,p_object_type IN qc_run_stats.object_type%TYPE := NULL
     ,p_run_id_1 IN qc_runs.run_id%TYPE := NULL
     ,p_run_id_2 IN qc_runs.run_id%TYPE := NULL
   )
   RETURN INTEGER -- 0=same, <>=different
   IS
      t_stat_1 stat_table;
      t_stat_2 stat_table;
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
      load_stat(
         t_stat_1
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,l_run_id_1
      );
      -- Load second run/version
      load_stat(
         t_stat_2
        ,p_qc_code
        ,p_app_alias
        ,p_object_owner
        ,p_object_type
        ,l_run_id_2
      );
      -- No need to compare if not same count
      IF t_stat_1.COUNT != t_stat_2.COUNT THEN
         GOTO return_diff;
      END IF;
      -- Compare all records
      FOR i IN 1..t_stat_1.COUNT LOOP
         IF NOT compare_stat_data(t_stat_1(i),t_stat_2(i))
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

