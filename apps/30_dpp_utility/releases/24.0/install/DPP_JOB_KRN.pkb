create or replace PACKAGE BODY dpp_job_krn IS
---
-- Copyright (C) 2023 European Commission
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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
--
   --
   FUNCTION list_files(p_path IN VARCHAR2) RETURN t_file_list IS LANGUAGE JAVA NAME 'dpp_toolkit.scanFiles(java.lang.String) return oracle.sql.ARRAY';
      --
   PROCEDURE log_p(p_code   IN PLS_INTEGER
                  ,p_text   IN VARCHAR2
                  ,p_action IN VARCHAR2
                  ,p_desc   IN VARCHAR2 DEFAULT NULL
                  )
   IS
      l_full_text CLOB;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      l_full_text := 'ORA-' || TO_CHAR(p_code, 'FM09999') || ': [' ||
                   NVL(p_desc, '') || '/' || NVL(p_action, '') || '] ' || ': ' ||
                   p_text;
      dpp_itf_krn.log_message(p_type => 'Error', p_text => l_full_text);
      COMMIT;
   END;
   --
   --
   PROCEDURE trace_p(p_text IN VARCHAR2) 
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      dpp_itf_krn.log_message(p_type => 'Info', p_text => p_text);
      COMMIT;
   END;

   PROCEDURE grant_management(p_action      IN VARCHAR2
                             ,p_grantee     IN VARCHAR2 DEFAULT NULL
                             ,p_object_name IN VARCHAR2 DEFAULT NULL
                             ,p_object_type IN VARCHAR2 DEFAULT NULL
                             )
  --AUTHID DEFINER 
  IS
     l_user        DBA_OBJECTS.OWNER%type;
     l_cnt         NUMBER;
     l_object_name DBA_OBJECTS.OBJECT_NAME%type;
     l_object_type DBA_OBJECTS.OBJECT_TYPE%type;
     l_action      VARCHAR2(10);
     l_grantee     DBA_SYS_PRIVS.GRANTEE%type;    
     --
     type lt_hash_table_type IS TABLE of NUMBER INDEX BY VARCHAR2(19);
     type lt_refcursor_type is ref cursor;
     --
     lt_hash_type lt_hash_table_type;
     --
     PRAGMA AUTONOMOUS_TRANSACTION;
     --
   BEGIN

     lt_hash_type('CONTEXT') := 1;
     lt_hash_type('INDEX') := 1;
     lt_hash_type('JOB CLASS') := 1;
     lt_hash_type('INDEXTYPE') := 1;
     lt_hash_type('PROCEDURE') := 1;
     lt_hash_type('JAVA CLASS') := 1;
     lt_hash_type('JAVA RESOURCE') := 1;
     lt_hash_type('SCHEDULE') := 1;
     lt_hash_type('WINDOW') := 1;
     lt_hash_type('WINDOW GROUP') := 1;
     lt_hash_type('TABLE') := 1;
     lt_hash_type('VIEW') := 1;
     lt_hash_type('TYPE') := 1;
     lt_hash_type('FUNCTION') := 1;
     lt_hash_type('LIBRARY') := 1;
     lt_hash_type('TRIGGER') := 1;
     lt_hash_type('SYNONYM') := 1;
     lt_hash_type('CONSUMER GROUP') := 1;
     lt_hash_type('EVALUATION CONTEXT') := 1;
     lt_hash_type('OPERATOR') := 1;
     lt_hash_type('PACKAGE') := 1;
     lt_hash_type('SEQUENCE') := 1;
     lt_hash_type('LOB') := 1;
     lt_hash_type('XML SCHEMA') := 1;
     lt_hash_type('CONSTRAINT') := 1;
     lt_hash_type('CREATE PROCEDURE') := 1;

     l_user        := USER;
     l_action      := UPPER(TRIM(p_action));
     l_object_name := UPPER(TRIM(p_object_name));
     l_object_type := UPPER(TRIM(p_object_type));
     l_grantee     := UPPER(TRIM(p_grantee));

     -- Exit if wrong action
     IF NOT l_action IN ('GRANT', 'REVOKE', 'LIST') THEN
       RAISE_APPLICATION_ERROR(-20001, 'Invalid action. Use ''GRANT'', ''REVOKE'' or ''LIST''.');
     END IF;
     -- Exit if p_object_name is NULL
     IF l_object_name is NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_object_name cannot be NULL for ' || l_action || ' action.');
     END IF;

     -- Exit if p_object_type is NULL
     IF l_object_type is NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_object_type cannot be NULL for ' || l_action || ' action.');
     END IF;

     -- Exit if p_grantee is NULL
     IF l_grantee IS NULL THEN
       RAISE_APPLICATION_ERROR(-20001, 'p_grantee cannot be NULL for ' || l_action || ' action.');
     END IF;

     -- Exit if grantee doesnt exist
     BEGIN
       SELECT count(1) INTO l_cnt FROM DBA_USERS WHERE username = l_grantee;
     END;
     --
     IF l_cnt = 0 THEN
       RAISE_APPLICATION_ERROR(-20001, 'Grantee ' || l_grantee || ' doesn''t exist.');
     END IF;

     -- check if it is a grantable type priviledge
     IF NOT lt_hash_type.EXISTS(l_object_type) THEN
       RAISE_APPLICATION_ERROR(-20001, l_object_type || ' is a incorrect type or is not droppable.');
     END IF;

     -- Exit if object doesnt exist
     IF l_object_name <> '*' THEN
       SELECT COUNT(1)
         INTO l_cnt
         FROM dba_objects
        WHERE owner = l_user
          and object_name = l_object_name
          and object_type = l_object_type;
     END IF;
     --
     IF l_cnt = 0 THEN
       RAISE_APPLICATION_ERROR(-20001, 'The ' || l_object_type || ' ' || l_user || '.' || l_object_name || ' doesn''t exist. Change of privileges allowed only on existing objects.');
     END IF;
     --
   END grant_management;

   -- 
   FUNCTION get_schema_env_name (p_schema IN VARCHAR2) RETURN VARCHAR2
   IS 
      l_env_name dpp_instances.env_name%TYPE;
   BEGIN
      SELECT DISTINCT upper(env_name)
	    INTO l_env_name
	    FROM dpp_instances i
        JOIN dpp_schemas s
          ON i.ite_name = s.ite_name
       WHERE upper(s.sma_name) = TRIM(UPPER(p_schema))
         AND i.ite_name = SYS_CONTEXT('userenv','db_name');

	  RETURN l_env_name;

      EXCEPTION WHEN no_data_found THEN
		RETURN NULL;
   END;

   --
   PROCEDURE lock_kill_unlock(p_schema IN VARCHAR2
                             ,p_lock IN BOOLEAN
                             ,p_debug_trace IN NUMBER := 0
                             )
   IS
      l_sqlStmt VARCHAR2(1000);
      l_schema VARCHAR2(500);
      e_session_id_notexists EXCEPTION;
      e_session_marked_killed EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_session_id_notexists, -30);
      PRAGMA EXCEPTION_INIT (e_session_marked_killed, -31);
	  l_env_name dpp_instances.env_name%TYPE;
   BEGIN
      l_schema := TRIM(UPPER(p_schema));
	  l_env_name := get_schema_env_name(l_schema);

	  IF UPPER(p_schema) LIKE 'APP_DPP!_%' ESCAPE '!' THEN
         trace_p('You are not allowed to lock user ' || upper(p_schema));
         RAISE_APPLICATION_ERROR(-20001, 'You are not allowed to lock user ' || upper(p_schema));
      END IF;

      l_sqlStmt := NULL;
      FOR x in (SELECT sid,
                      serial#,
                      username,
                      schemaname,
                      osuser,
                      process,
                      machine,
                      terminal,
                      program,
                      inst_id
               FROM GV$SESSION
               WHERE l_schema IN (username, schemaname)-- concerned schema is accessing or is being accessed
                 AND username NOT LIKE 'APP_DPP_%')
      LOOP
         IF l_env_name IN ('DC', 'COP') THEN 
            -- we are in DC or COP
            l_sqlStmt := 'BEGIN dc_dba_mgmt_kill_sess_dedic_db (session_sid=> '||x.sid||', session_serial=> '||x.serial#||', v_inst_id=>'||x.inst_id||'); END;';
         ELSE
             -- we are in the cloud
            l_sqlStmt := 'BEGIN rdsadmin.rdsadmin_util.kill(' || X.SId || ',' || X.Serial# || '); END;';
         END IF;

         BEGIN
            EXECUTE IMMEDIATE l_sqlStmt;
         EXCEPTION
            WHEN e_session_id_notexists THEN
               NULL;
            WHEN e_session_marked_killed THEN
               NULL;
         END;
         IF p_debug_trace > 0 THEN
           DBMS_OUTPUT.PUT_LINE(l_sqlStmt);
         END IF;
         -- IM0011584777  catch the ora-30 error and continue
         -- IM0012639115 catch ora-31

      END LOOP;
      l_sqlStmt := 'BEGIN dc_dba_mgmt_lock_user(user=> :p1, b_lock => :p2); END;';  
      BEGIN
         EXECUTE IMMEDIATE l_sqlStmt using p_schema, p_lock;
      END;
   EXCEPTION
      WHEN OTHERS THEN 
         trace_p(DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace);
         RAISE;   
   END lock_kill_unlock;                             

   PROCEDURE remove_files_older(p_sma_name IN dpp_schemas.sma_name%TYPE
                               ,p_date     IN DATE
                               ) 
   IS
      l_schema    VARCHAR2(50);
      l_action    VARCHAR2(80) := 'remove_files_older';
      l_sql_text  VARCHAR2(4000);
      l_sql_error NUMBER;
      l_rc        VARCHAR2(1000);
      l_service_name VARCHAR2(128);
      l_network_name  VARCHAR2(128);
	  l_env_name dpp_instances.env_name%TYPE;
   BEGIN
      l_schema := TRIM(UPPER(p_sma_name));
	  l_env_name := get_schema_env_name(l_schema);
      IF l_env_name in ('DC', 'COP') THEN 
      -- we are in DC     
          FOR irec IN (SELECT COLUMN_VALUE filename
                         FROM TABLE(dpp_job_krn.list_files(dpp_job_var.g_dpp_dir))
                        WHERE INSTR(COLUMN_VALUE, l_schema) = 1
                          AND (REPLACE(REPLACE(COLUMN_VALUE, l_schema, ''),
                                     '.exp',
                                     '') <
                             TO_CHAR(p_date, 'YYYYMMDD') || '00000' OR
                             REPLACE(REPLACE(COLUMN_VALUE, l_schema, ''),
                                     '.bsy',
                                     '') <
                             TO_CHAR(p_date, 'YYYYMMDD') || '00000')                 
                     ) 
          LOOP
             -- remove the file
             BEGIN
                UTL_FILE.FREMOVE(location => dpp_job_var.g_dpp_dir, filename => irec.filename);
             EXCEPTION
                WHEN OTHERS THEN
                   l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
                   l_sql_error := SQLCODE;
                   l_rc        := '[ORA-' || l_sql_error || '] ' || l_sql_text;
                   log_p(l_sql_error, l_sql_text, l_action);
                   RAISE;
             END;
          END LOOP;
      ELSE
          FOR irec IN (SELECT COLUMN_VALUE filename
                         FROM TABLE(dpp_job_krn.list_aws_files(dpp_job_var.g_dpp_dir))
                        WHERE INSTR(COLUMN_VALUE, l_schema) = 1
                          AND (REPLACE(REPLACE(COLUMN_VALUE, l_schema, ''),
                                     '.exp',
                                     '') <
                             TO_CHAR(p_date, 'YYYYMMDD') || '00000' OR
                             REPLACE(REPLACE(COLUMN_VALUE, l_schema, ''),
                                     '.bsy',
                                     '') <
                             TO_CHAR(p_date, 'YYYYMMDD') || '00000')                 
                     ) 
          LOOP
             -- remove the file
             BEGIN
                UTL_FILE.FREMOVE(location => dpp_job_var.g_dpp_dir, filename => irec.filename);
             EXCEPTION
                WHEN OTHERS THEN
                   l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
                   l_sql_error := SQLCODE;
                   l_rc        := '[ORA-' || l_sql_error || '] ' || l_sql_text;
                   log_p(l_sql_error, l_sql_text, l_action);
                   RAISE;
             END;
          END LOOP;
      END IF;      

   END;
   --
   FUNCTION get_cpu_count RETURN NUMBER;
   --
   PROCEDURE blead_pump_status(p_sqlcode    IN NUMBER
                              ,p_job_number IN NUMBER
                              ,p_action     IN VARCHAR2
                              ) 
   IS
      v_job_state VARCHAR2(4000);
      v_status    ku$_Status1010;
      v_logs      ku$_LogEntry1010;
      v_row       PLS_INTEGER;
      --
   BEGIN
      dbms_datapump.get_status(p_job_number, 8, 0, v_job_state, v_status);
      v_logs := v_status.error;
      v_row  := v_logs.FIRST;
      LOOP
         EXIT WHEN v_row IS NULL;
         log_p(p_sqlcode,
               'logLineNumber=' || v_logs(v_row).logLineNumber,
               p_action);
         log_p(p_sqlcode,
               'errorNumber=' || v_logs(v_row).errorNumber,
               p_action);
         log_p(p_sqlcode, 'LogText=' || v_logs(v_row).LogText, p_action);
         v_row := v_logs.NEXT(v_row);
      END LOOP;
   END;
  --
   FUNCTION marshall_list_to_string(p_all_names IN dpp_job_var.gt_list_names_type)
   RETURN VARCHAR2 
   IS
      l_element_name VARCHAR2(30);
      l_rc           VARCHAR2(4000);
   BEGIN
      --
      l_rc := ''' '''; -- empty string
      --
      IF p_all_names.FIRST IS NULL THEN
         RETURN l_rc;
      END IF;
      FOR i IN p_all_names.FIRST .. p_all_names.LAST LOOP
         l_element_name := p_all_names(i);
         IF i = p_all_names.FIRST THEN
            l_rc := '''' || l_element_name || '''';
         ELSE
            l_rc := l_rc || '''' || l_element_name || '''';
         END IF;

         IF i <> p_all_names.LAST THEN
            l_rc := l_rc || ',';
         END IF;
      END LOOP;
      RETURN l_rc;
   END;
   --
   FUNCTION getvalues(p_key IN VARCHAR2
                     ,p_data IN VARCHAR2
                     ) 
   RETURN VARCHAR2 
   IS
      l_rc   VARCHAR2(1000);
      l_key  VARCHAR2(50);
      l_data VARCHAR2(5000);
      l_pos1 PLS_INTEGER;
      l_pos2 PLS_INTEGER;
   BEGIN
      l_data := UPPER(TRIM(p_data));
      l_key  := UPPER(TRIM(p_key));
      l_pos1 := INSTR(l_data, l_key || '=');
      IF l_pos1 IS NULL OR l_pos1 = 0 THEN
         RETURN NULL;
      END IF;
      -- key is defined so we get value
      l_pos1 := l_pos1 + LENGTH(l_key || '=');
      l_pos2 := INSTR(l_data, '#', l_pos1);
      IF l_pos2 IS NULL or l_pos2 = 0 THEN
         l_rc := SUBSTR(l_data, l_pos1);
      ELSE
         l_rc := SUBSTR(l_data, l_pos1, l_pos2 - l_pos1);
      END IF;
      --
      RETURN l_rc;
   END;
   --
   PROCEDURE set_parallelism(p_options IN VARCHAR2)
   IS
      l_cpu_count NUMBER;
      l_sql_text  VARCHAR2(4000);
      l_sql_error NUMBER;
   BEGIN
      BEGIN
         l_cpu_count := TO_NUMBER(getvalues(p_key  => 'PARALLEL',
         p_data => p_options));
         dpp_job_var.g_cpu_count := l_cpu_count;
      EXCEPTION
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,'The options "PARALLEL" is not set to a numeric value');
      END;
      --
      --
      IF dpp_job_var.g_cpu_count IS NULL THEN
         dpp_job_var.g_cpu_count := get_cpu_count;
         trace_p('"PARALLEL" option not set defaulting to:' || dpp_job_var.g_cpu_count);
      END IF;
      --
   END;

   FUNCTION is_object_locked(p_object_type IN VARCHAR2
                            ,p_schema      IN VARCHAR2
                            ) 
   RETURN BOOLEAN 
   IS  
      CURSOR c_lck_obj 
          IS
      SELECT obj.object_name
           , obj.object_type
           , ssn.sid
        FROM v$locked_object vot
           , dba_objects obj
           , v$session ssn
       WHERE vot.object_id = obj.object_id
         AND vot.session_id = ssn.sid
         AND obj.object_type = p_object_type
         AND obj.owner = TRIM(UPPER(p_schema));        
      l_rc       BOOLEAN;
      l_obj_name VARCHAR2(50);
      l_obj_type VARCHAR2(50);
      l_obj_sid  VARCHAR2(50);
   BEGIN
      l_rc := FALSE;
      OPEN c_lck_obj;
      LOOP
         FETCH c_lck_obj
          INTO l_obj_name, l_obj_type, l_obj_sid;
         EXIT WHEN c_lck_obj%NOTFOUND;
         l_rc := TRUE;
         trace_p('Object ' || l_obj_name || ' (' || l_obj_type ||') is Locked by session:' || l_obj_sid);
      END LOOP;
      CLOSE c_lck_obj;
      RETURN l_rc;
   END;
   --
   /*
   DECLARE
   l_sql varchar2(1000);
   l_schema_name varchar2(100);
   l_object_name varchar2(1000);
BEGIN
   l_schema_name := 'APP_DPP_D';
   l_object_name := 'TST_MARIAN';
   l_sql := 'DROP TABLE #schema_user#.#in_table_name#';
   l_object_name := sys.dbms_assert.enquote_name(l_object_name);
   l_schema_name := sys.dbms_assert.enquote_name(l_schema_name);
   l_sql := replace(l_sql, '#in_table_name#', l_object_name);
   l_sql := replace(l_sql, '#schema_user#', l_schema_name);
   execute immediate l_sql;
END;
   */
   PROCEDURE recompile_inv_obj(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'recompile objects';
      l_schema    dpp_schemas.sma_name%TYPE;
      l_sqlStmt   varchar2(500);
   BEGIN  
      dpp_inj_krn.inj_recomp_inv_obj(p_schema);
      l_sqlStmt   := 'BEGIN #p_schema#.dpump_recomp_inv_obj(#p_schema#);  END; ';
      l_schema    := sys.dbms_assert.enquote_name(p_schema);
      l_sqlStmt   := replace(l_sqlStmt, '#p_schema#', l_schema);
      BEGIN
         EXECUTE IMMEDIATE l_sqlStmt;
      EXCEPTION
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,l_action,'RECOMPILING OBJECTS FAILED IN' || p_schema);
            RAISE;
      END;
      dpp_inj_krn.inj_drop_recomp_inv_obj(p_schema);
   END;
  --
   PROCEDURE email_pmp_session(p_action     IN VARCHAR2
                              ,p_src        IN VARCHAR2 -- logical name
                              ,p_trg        IN VARCHAR2 -- logical name
                              ,p_src_schema IN VARCHAR2 -- real name
                              ,p_trg_schema IN VARCHAR2 -- real name
                              ,p_src_inst   IN VARCHAR2 -- src db name
                              ,p_trg_inst   IN VARCHAR2 -- src db name
                              ,p_distribution_list IN VARCHAR2 -- recipients
                              ,p_error      IN NUMBER
                              ) 
   IS
      l_msg_text CLOB;
      --
      l_start_time VARCHAR2(6);
      l_stop_time  VARCHAR2(6);
      l_priority   PLS_INTEGER;
      --
      l_payload VARCHAR2(32000);
      --
      l_subject VARCHAR2(400);
   BEGIN
      l_start_time := TO_CHAR(dpp_job_var.g_start_time, 'HH24:MI');
      l_stop_time  := TO_CHAR(dpp_job_var.g_stop_time, 'HH24:MI');
      l_priority   := CASE WHEN p_error > 0 THEN 1 ELSE 5 END;
      l_payload    := NULL;
      --
      FOR irec IN (SELECT jlg.text
                     FROM dpp_job_logs jlg
                    WHERE jlg.jrn_id = dpp_job_var.g_context
                      AND jlg.jte_cd = dpp_itf_var.g_job_type
                    ORDER BY jlg.line ASC
                  ) 
      LOOP
         l_payload := l_payload || irec.text || UTL_TCP.CRLF;
      END LOOP;
      --
      l_msg_text := 'ACTION: ' || p_action || ' ,' || CASE WHEN p_error > 0 THEN 'FAILURE!!' ELSE 'SUCCESS' END || UTL_TCP.CRLF || 'Session:' || TO_CHAR(dpp_job_var.g_context) || UTL_TCP.CRLF;
      --
      IF p_action = 'IMPORT' THEN
         l_msg_text := l_msg_text || 'Imported to schema: ' ||
         NVL(p_trg_schema, 'SCHEMA NOT SPECIFIED')||'@'||NVL(p_trg_inst,'DB NOT SPECIFIED')|| UTL_TCP.CRLF;
         l_msg_text := l_msg_text || 'Exported from schema: ' ||
         NVL(p_src_schema, 'SCHEMA NOT SPECIFIED')||'@'||NVL(p_src_inst,'DB NOT SPECIFIED')|| UTL_TCP.CRLF;
      ELSIF p_action = 'EXPORT' THEN
         l_msg_text := l_msg_text || 'Exported from schema: ' ||
         NVL(p_src_schema, 'SCHEMA NOT SPECIFIED')||'@'||NVL(p_src_inst,'DB NOT SPECIFIED')|| UTL_TCP.CRLF;
      ELSE
         l_msg_text := l_msg_text || 'Transfer of dump files of schema: ' ||
         NVL(p_src_schema, 'SCHEMA NOT SPECIFIED')||'@'||NVL(p_src_inst,'DB NOT SPECIFIED')|| UTL_TCP.CRLF;         
      END IF;
      --
      l_msg_text := l_msg_text || UTL_TCP.CRLF || 'Start time:'
                 || l_start_time ||UTL_TCP.CRLF || 'Stop time:' 
                 || l_stop_time || UTL_TCP.CRLF || l_payload || UTL_TCP.CRLF 
                 || UTL_TCP.CRLF || UTL_TCP.CRLF;
      -- append logfile if created             
      IF NOT dpp_job_var.g_logfile IS NULL THEN
         l_msg_text := l_msg_text || 'OS LOGFILE:' || UTL_TCP.CRLF 
                    || load_log_file(dpp_job_var.g_logfile);
      END IF;

      l_subject := p_action || ': ' || CASE WHEN p_trg IS NULL THEN LOWER(p_src_schema)||'@'||LOWER(p_src_inst) ELSE LOWER(p_trg_schema)||'@'||LOWER(p_trg_inst) END;
         --
      mail_utility_krn.send_mail_over32k(
                  p_sender     => dpp_job_var.gk_default_sender
                , p_recipients => p_distribution_list 
                , p_cc         => NULL
                , p_bcc        => NULL
                , p_subject    => l_subject
                , p_message    => l_msg_text
                , p_priority   => 3
                , p_force_send_on_non_prod_env=>TRUE
                );
   END;

   PROCEDURE rename_file(p_sma_name IN VARCHAR2) 
   IS
      l_from_filename VARCHAR2(150);
      l_to_filename   VARCHAR2(150);
      l_sql_text      VARCHAR2(4000);
      l_sql_error     PLS_INTEGER;
      l_action        VARCHAR2(25) := 'rename_file';
      l_subfile_idx   CHAR(3);
      l_out_dpp_dir   dpp_parameters.prr_value%TYPE;
   BEGIN
      l_out_dpp_dir := dpp_job_mem.get_prr('g_dpp_out_dir').prr_value;

      FOR i IN 1 .. dpp_job_var.g_cpu_count LOOP
         l_subfile_idx   := LPAD(i, 3, '0');
         l_from_filename := p_sma_name || TO_CHAR(dpp_job_var.g_context) || '.exp.' ||
         l_subfile_idx || '.bsy';
         l_to_filename   := p_sma_name || TO_CHAR(dpp_job_var.g_context) ||
         l_subfile_idx || '.exp';
         UTL_FILE.frename(src_location  => l_out_dpp_dir
                         ,src_filename  => l_from_filename
                         ,dest_location => l_out_dpp_dir
                         ,dest_filename => l_to_filename
                         );
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE dpp_job_var.ge_renaming_failed;
   END;

   FUNCTION remove_dmp_file(p_filename IN VARCHAR2, p_dpp_dir IN VARCHAR2 DEFAULT NULL) 
   RETURN VARCHAR2 
   IS
      l_rc        VARCHAR2(5000);
      l_sql_text  VARCHAR2(4000);
      l_sql_error NUMBER;
   BEGIN
      l_rc := 'NO FILE NAME SPECIFIED';
      IF p_filename IS NULL THEN
         RETURN l_rc;
      END IF;
      l_rc := NULL;
      -- wrap it
      BEGIN
         UTL_FILE.FREMOVE(location => NVL(p_dpp_dir, dpp_job_var.g_dpp_dir), filename => p_filename);
      EXCEPTION
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            l_rc        := '[ORA-' || l_sql_error || '] ' || l_sql_text;
            RAISE;
      END;
      --
      RETURN l_rc;
   END;

   PROCEDURE clean_dmp_dir(p_schema IN VARCHAR2) 
   IS
	  l_env_name dpp_instances.env_name%type;
   BEGIN
      l_env_name := get_schema_env_name(trim(upper(p_schema)));
      IF l_env_name IN ('DC', 'COP') THEN
      -- we are in DC
          FOR irec IN (SELECT COLUMN_VALUE
                         FROM TABLE(dpp_job_krn.list_files(dpp_job_var.g_dpp_dir))
                        WHERE NOT (COLUMN_VALUE = 'postfix' 
                                   OR
                                   LOWER(COLUMN_VALUE) LIKE '%sh'
                                  )
                       )
          LOOP
             DBMS_OUTPUT.put_line(remove_dmp_file(irec.COLUMN_VALUE));
          END LOOP;
       ELSE
          FOR irec IN (SELECT COLUMN_VALUE
                         FROM TABLE(dpp_job_krn.list_aws_files(dpp_job_var.g_dpp_dir))
                        WHERE NOT (COLUMN_VALUE = 'postfix' 
                                   OR
                                   LOWER(COLUMN_VALUE) LIKE '%sh'
                                  )
                       )
          LOOP
             DBMS_OUTPUT.put_line(remove_dmp_file(irec.COLUMN_VALUE));
          END LOOP;

       END IF;

   END;

   PROCEDURE run_job(p_sma_name IN VARCHAR2
                    ,p_job_number  IN NUMBER
                    ,p_simulation  IN BOOLEAN := FALSE
                    ) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(25) := 'run_job';
   BEGIN
      --
      dpp_inj_krn.inj_stop_job_safe(p_sma_name);
      dpp_inj_krn.inj_run_job(p_sma_name);
      --
      dpp_inj_krn.run_injected_job(p_sma_name
                                  ,p_job_number
                                  ,p_simulation => p_simulation
                                  );

      dpp_inj_krn.inj_drop_run_job(p_sma_name);
      dpp_inj_krn.inj_drop_stop_job_safe(p_sma_name);
      --
   EXCEPTION
      WHEN dpp_job_var.ge_success_with_info THEN
         l_sql_error := SQLCODE;
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         blead_pump_status(l_SQL_error, p_job_number, l_action);
         log_p(l_sql_error, l_sql_text, l_action);
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         blead_pump_status(l_SQL_error, p_job_number, l_action);
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
   END;

   FUNCTION load_log_file(p_file_name IN VARCHAR2) 
   RETURN CLOB 
   IS
      l_clob_text  CLOB;
      l_rc         CLOB;
      l_b_file     BFILE;
      l_lang_ctx   NUMBER := DBMS_LOB.default_lang_ctx;
      l_charset_id NUMBER := 0;
      l_src_offset NUMBER := 1;
      l_dst_offset NUMBER := 1;
      l_warning    NUMBER;
      l_isopen     NUMBER;
   BEGIN
       --
       -- load log file 
       --
      DBMS_LOB.createtemporary(lob_loc => l_clob_text, cache => TRUE);
      l_b_file := bfilename(dpp_job_var.g_dpp_dir, p_file_name);
      DBMS_LOB.fileopen(file_loc  => l_b_file
                       ,open_mode => DBMS_LOB.file_readonly
                       );
      l_isopen := DBMS_LOB.isopen(lob_loc => l_clob_text);
       --
      DBMS_LOB.loadclobfromfile(dest_lob     => l_clob_text
                               ,src_bfile    => l_b_file
                               ,amount       => DBMS_LOB.LOBMAXSIZE
                               ,dest_offset  => l_dst_offset
                               ,src_offset   => l_src_offset
                               ,bfile_csid   => l_charset_id
                               ,lang_context => l_lang_ctx
                               ,warning      => l_warning
                               );
      DBMS_LOB.fileclose(file_loc => l_b_file);
      l_isopen := DBMS_LOB.isopen(lob_loc => l_clob_text);
      IF l_isopen <> 0 THEN
         DBMS_LOB.close(lob_loc => l_clob_text);
      END IF;
      --
      l_rc := l_clob_text; -- copy it, i have to free temp log otherwise it will stay resident in temp tablespace
      --
      DBMS_LOB.freetemporary(lob_loc => l_clob_text);
      --
      RETURN l_rc;
   END;

   PROCEDURE cleanup_namespace(p_target_schema IN VARCHAR2) 
   IS
      l_sql_clean_tables   VARCHAR2(4000);
      l_sql_clean_procs    VARCHAR2(4000);
      l_template           VARCHAR2(4000);
      l_schema             dpp_schemas.sma_name%TYPE;
   BEGIN
      l_sql_clean_tables := 'BEGIN FOR IREC IN (SELECT * FROM USER_TABLES S0 WHERE S0.TABLE_NAME LIKE ''DPUMP%'') LOOP ' ||
                            ' BEGIN EXECUTE IMMEDIATE ''DROP TABLE '' || IREC.TABLE_NAME ||'' CASCADE CONSTRAINTS''; EXCEPTION WHEN OTHERS THEN NULL; END; ' ||
                            '  END LOOP;  END; ';
      l_sql_clean_procs := ' BEGIN FOR IREC IN (SELECT * FROM User_Procedures S0 WHERE S0.object_type = ''PROCEDURE'' AND S0.object_name LIKE ''DPUMP%'' ' ||
                           '  AND NOT S0.object_name = ''DPUMP_EXEC_AUTH'') LOOP BEGIN  EXECUTE IMMEDIATE ''DROP PROCEDURE '' || IREC.object_name; ' ||
                           '  EXCEPTION WHEN OTHERS THEN  NULL; END; END LOOP; END; ';
      l_template        := 'BEGIN ${SCHEMA}.dpump_exec_auth(:1); END;'; 
      l_schema          := sys.dbms_assert.enquote_name(p_target_schema);
      l_template        := replace(l_template, '${SCHEMA}', l_schema);   
      dpp_inj_krn.inj_exec_proc(p_target_schema);
      l_sql_clean_tables := REPLACE(l_sql_clean_tables, CHR(13), ' ');
      l_sql_clean_tables := REPLACE(l_sql_clean_tables, CHR(10), ' ');
      EXECUTE IMMEDIATE l_template
        USING IN l_sql_clean_tables; -- do it
      l_sql_clean_procs := REPLACE(l_sql_clean_procs, CHR(13), ' ');
      l_sql_clean_procs := REPLACE(l_sql_clean_procs, CHR(10), ' ');
      EXECUTE IMMEDIATE l_template
        USING IN l_sql_clean_procs; -- do it
      dpp_inj_krn.inj_drop_exec_proc(p_target_schema);
   END;

   PROCEDURE fix_exec_sql(p_action        IN VARCHAR2
                         ,p_target_schema IN VARCHAR2
                         ,p_offset        IN NUMBER := NULL
                         ,p_exp_type      IN VARCHAR2 := NULL
                         )
   IS
      l_template       VARCHAR2(4000);
      l_sql_error_text VARCHAR2(4000);
      l_sql_error      PLS_INTEGER;
      l_action         VARCHAR2(50);
      l_sql_text_vc    CLOB;
      v_prefix_postfix VARCHAR2(8);
      l_lf             CHAR(1) := CHR(10);
      l_cr             CHAR(1) := CHR(13);
      l_export         VARCHAR2(4);
   BEGIN
      l_template       := 'BEGIN ${SCHEMA}.dpump_exec_auth(:1); END;'; 
      l_action         := 'fix_exec_sql';
      v_prefix_postfix := UPPER(TRIM(p_action));
      --
      IF p_action IS NULL THEN
         RAISE dpp_job_var.ge_illegal_arg_exec_sql_action;
      END IF;
      --
      IF v_prefix_postfix NOT IN ('PREFIX', 'POSTFIX') THEN
         RAISE dpp_job_var.ge_illegal_arg_exec_sql_pre_post;
      END IF;
      --
      -- injects routine to allow xxx_DPP_UTL to recompile invalid objects
      dpp_inj_krn.inj_recomp_inv_obj(p_target_schema);
      --    
      dpp_inj_krn.inj_exec_proc(p_target_schema);
      l_template := REPLACE(l_template, '${SCHEMA}', p_target_schema);
      FOR irec IN (SELECT atn.block_text
                        , atn.execution_order
                        , atn.atn_usage
                     FROM dpp_actions atn
                     JOIN dpp_schemas sma 
                       ON sma.sma_id = atn.sma_id 
                      AND UPPER(sma.sma_name) =  p_target_schema
                    WHERE atn.atn_usage = DECODE(p_exp_type,'E','E','I')
                      AND atn.atn_type = v_prefix_postfix
                      AND atn.active_flag = 'Y'
                    ORDER BY atn.execution_order ASC
                  )
      LOOP
         BEGIN

            trace_p('getting block for a schema:' || p_target_schema|| ' no.'||TO_CHAR(irec.execution_order));
            l_sql_text_vc := REPLACE(irec.block_text, l_lf, ' ');
            l_sql_text_vc := REPLACE(l_sql_text_vc, l_cr, ' ');
            trace_p('Block prepared!');

            IF p_offset IS NULL OR p_offset <= irec.execution_order THEN

               l_export := CASE WHEN IREC.atn_usage = 'E' THEN 'EXP' ELSE 'IMP' END;
               DBMS_APPLICATION_INFO.SET_MODULE( l_export||':EXEC BLOCK','SCHEMA:' || p_target_schema);
               trace_p('Running block for the schema:' || p_target_schema || ' no.'||TO_CHAR(irec.execution_order));
               EXECUTE IMMEDIATE l_template
                 USING IN l_sql_text_vc; -- do it
               trace_p('Block for the schema:' || p_target_schema || ' no.'||TO_CHAR(irec.execution_order)|| ' executed!');
            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               l_sql_error_text := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
               l_sql_error      := SQLCODE;
               IF v_prefix_postfix = 'POSTFIX' THEN      
                  log_p(l_sql_error
                       ,l_sql_error_text || CHR(10) || 'code:' || irec.block_text
                       ,l_action
                       ,'COULD NOT EXECUTE BLOCK FOR THE SCHEMA :' || p_target_schema || ' no.'||TO_CHAR(IREC.EXECUTION_ORDER)
                       );
                  RAISE;
               ELSE   -- prefix
                  log_p(l_sql_error
                       ,l_sql_error_text || CHR(10) || 'code:' || irec.block_text
                       ,l_action
                       ,'COULD NOT EXECUTE BLOCK FOR THE SCHEMA : ' || p_target_schema || ' no.'||TO_CHAR(IREC.EXECUTION_ORDER)||'. Process not stopped.'
                       );
                  RAISE;     
               END IF;   
         END;
      END LOOP;
      dpp_inj_krn.inj_drop_exec_proc(p_target_schema);
      -- drop recomp routine needed by post/pre DPP_UTL package in target schem
      dpp_inj_krn.inj_drop_recomp_inv_obj(p_target_schema);    
   END;

   PROCEDURE close_context_id(p_status IN VARCHAR2) IS
      l_cnt PLS_INTEGER := 0;
   BEGIN
      UPDATE dpp_job_runs jrn
         SET jrn.status     = CASE TRIM(SUBSTR(p_status, 1, 1)) WHEN 'E' THEN 'ERR' WHEN 'O' THEN 'OK' END,
             jrn.date_ended = dpp_job_var.g_stop_time,
             jrn.date_modif = dpp_job_var.g_stop_time
       WHERE jrn.jrn_id = dpp_job_var.g_context
         AND jrn.jte_cd = dpp_job_var.g_app_run_type;
      l_cnt := SQL%ROWCOUNT;
      IF l_cnt <> 1 THEN
         dpp_itf_krn.log_message(p_type => 'ERROR',
         p_text => 'MORE THEN ONE ROW UPDATED IN DPP_JOB_RUNS');
      END IF;
   END close_context_id;
   
   FUNCTION get_job_run_status
   RETURN dpp_job_runs.status%TYPE
   IS
      l_job_run_status dpp_job_runs.status%TYPE;
   BEGIN
      SELECT status
        INTO l_job_run_status
        FROM dpp_job_runs jrn
       WHERE jrn.jrn_id = dpp_job_var.g_context
         AND jrn.jte_cd = dpp_job_var.g_app_run_type;
      RETURN l_job_run_status;         
   END get_job_run_status;

   FUNCTION create_import_job(p_sma_name   IN VARCHAR2
                             ,p_simulation IN BOOLEAN := FALSE
                             ,p_db_link    IN VARCHAR2
                             ) 
   RETURN NUMBER 
   IS
      l_job_number NUMBER;
      l_sql_error  PLS_INTEGER;
      l_sql_text   VARCHAR2(4000);
      l_action     VARCHAR2(25) := 'create_import_job';
   BEGIN
      l_job_number := NULL;
      BEGIN
         dpp_inj_krn.inj_attatch_to_job(p_sma_name);
         dpp_inj_krn.inj_create_import_job(p_sma_name,p_db_link);
         IF p_simulation = FALSE THEN
            EXECUTE IMMEDIATE ' BEGIN ' || p_sma_name ||
                 '.dpump_create_import_job(:p_job_number); END;'
            USING OUT l_job_number;
         ELSE
            l_job_number := 1; -- dud warhead
         END IF;
         dpp_inj_krn.inj_drop_create_import_job(p_sma_name);
         dpp_inj_krn.inj_drop_attatch_to_job(p_sma_name);
      EXCEPTION
         WHEN DBMS_DATAPUMP.no_such_job THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,l_action,'typical error generated because of metalink 315488.1');
         WHEN DBMS_DATAPUMP.job_exists THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,l_action,'Job definition has been created in a previous run?');
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            IF l_job_number IS NOT NULL THEN
               blead_pump_status(l_sql_error, l_job_number, l_action);
            END IF;
            log_p(l_sql_error, l_sql_text, l_action);
            RAISE;
      END;
      RETURN l_job_number;
   END;

   FUNCTION create_export_job(p_sma_name IN VARCHAR2) 
   RETURN NUMBER 
   IS
      l_job_number NUMBER;
      l_sql_error  PLS_INTEGER;
      l_sql_text   VARCHAR2(4000);
      l_action     VARCHAR2(25) := 'create_export_job';
   BEGIN
      l_job_number := NULL;
      BEGIN
         dpp_inj_krn.inj_attatch_to_job(p_sma_name);
         dpp_inj_krn.inj_create_export_job(p_target_schema => p_sma_name);

         EXECUTE IMMEDIATE ' BEGIN ' || p_sma_name ||
                           '.dpump_create_export_job(:p_job_number); END;'
           USING OUT l_job_number;
         dpp_inj_krn.inj_drop_create_export_job(p_target_schema => p_sma_name);
         dpp_inj_krn.inj_drop_attatch_to_job(p_sma_name);
      EXCEPTION
         WHEN DBMS_DATAPUMP.no_such_job THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,l_action,'typical error generated because of metalink 315488.1');
         WHEN DBMS_DATAPUMP.job_exists THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error,l_sql_text,l_action,'Job definition has been created in a previous run?');         
      END;
      RETURN l_job_number;
   END;

   FUNCTION initiate_import(p_sma_name   IN VARCHAR2
                           ,p_simulation IN BOOLEAN
                           ,p_db_link    IN VARCHAR2
                           ) 
   RETURN NUMBER 
   IS  
      l_sql_error PLS_INTEGER;
      l_sql_text  VARCHAR2(4000);
      l_action    VARCHAR2(50) := 'INITIATE_IMPORT';
   BEGIN
      dpp_job_var.g_job_number := NULL;
      --
      dpp_job_var.g_job_number := create_import_job(p_sma_name, p_simulation, p_db_link);
      RETURN dpp_job_var.g_job_number;
   EXCEPTION
      WHEN DBMS_DATAPUMP.invalid_argval THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
      WHEN DBMS_DATAPUMP.privilege_error THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RETURN dpp_job_var.g_job_number;
      WHEN DBMS_DATAPUMP.INTERNAL_ERROR THEN
         -- strange error
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
      WHEN DBMS_DATAPUMP.success_with_info THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
   END;

   PROCEDURE drop_all_proc_func(p_schema IN VARCHAR2) 
   IS
      l_sql_text     VARCHAR2(4000);
      l_sql_error    PLS_INTEGER;
      l_action       VARCHAR2(50) := 'drop_all_source';
      l_source_names dpp_job_var.gt_list_names_type;
      l_list         VARCHAR2(4000);
   BEGIN
      --
      SELECT ndt.object_type || ':' || ndt.object_name BULK COLLECT
        INTO l_source_names
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type IN ('PROCEDURE', 'PACKAGE', 'FUNCTION')
         AND ndt.active_flag = 'Y';
      --
      l_list := '''PROCEDURE:DPUMP_DROP_ALL_SOURCE'',' ||
      marshall_list_to_string(l_source_names);
      --
      --
      dpp_inj_krn.inj_drop_source(p_schema, l_list);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_drop_all_source; END; ';
      dpp_inj_krn.inj_drop_drop_source(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'REMOVING PACKAGES/FUNCTIONS/PROCEDURES FOR' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_sequences(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_sequences';
      l_seq_names dpp_job_var.gt_list_names_type;
      l_list      VARCHAR2(4000);
   BEGIN
      SELECT ndt.object_name BULK COLLECT
        INTO l_seq_names
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type IN ('SEQUENCE')
         AND ndt.active_flag = 'Y';
      --
      l_list := marshall_list_to_string(l_seq_names);
      --
      dpp_inj_krn.inj_drop_sequence(p_schema, l_list);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_drop_sequences; END; ';
      dpp_inj_krn.inj_drop_drop_sequence(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING SEQUENCES FAILED IN' || USER);
         RAISE;
   END;
  --
  --
  FUNCTION extract_sma_name(p_schema IN VARCHAR2) 
  RETURN VARCHAR2 
  IS
    l_pos  PLS_INTEGER;
    l_user VARCHAR2(50);

  BEGIN
    l_pos  := REGEXP_INSTR(p_schema, '[0-9]{8}$');
    l_user := p_schema;
    IF l_pos > 0 THEN
      l_user := SUBSTR(p_schema, 1, l_pos - 1);
    END IF;
    RETURN l_user;
  END;
  --
  --
  FUNCTION check_exist_trg_schema(p_sma_name IN VARCHAR2) 
  RETURN BOOLEAN 
  IS
    l_rc   BOOLEAN;
    l_user VARCHAR2(50);
    l_cnt  PLS_INTEGER;
  BEGIN
    l_rc   := TRUE;
    l_user := TRIM(UPPER(p_sma_name));
    SELECT COUNT(1) INTO l_cnt FROM all_users a WHERE a.username = l_user;
    IF l_cnt = 0 THEN
      l_rc := FALSE;
    END IF;
    RETURN l_rc;
  END;

   PROCEDURE drop_all_synonyms(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_synonyms';
      l_list      VARCHAR2(4000);
      l_synonyms  dpp_job_var.gt_list_names_type;
   BEGIN
      SELECT ndt.object_name BULK COLLECT
        INTO l_synonyms
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'SYNONYM'
         AND ndt.active_flag = 'Y';
      --
      l_list := marshall_list_to_string(l_synonyms);
      dpp_inj_krn.inj_drop_synonym(p_schema, l_list);
      EXECUTE IMMEDIATE ' BEGIN ' || p_schema || '.dpump_drop_synonym; END; ';
      dpp_inj_krn.inj_drop_drop_synonym(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING SYNONYMS FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_tables(p_schema IN VARCHAR2) 
   IS
      l_sql_text        VARCHAR2(4000);
      l_sql_error       PLS_INTEGER;
      l_action          VARCHAR2(50) := 'drop_all_tables';
      l_list            VARCHAR2(4000);
      l_tables          dpp_job_var.gt_list_names_type;
      l_remote_err      NUMBER;
      l_remote_table    VARCHAR2(60);
      l_remote_err_text VARCHAR2(2000);
   BEGIN
      --
      SELECT ndt.object_name BULK COLLECT
        INTO l_tables
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'TABLE'
         AND ndt.active_flag = 'Y';
      --
      l_list := marshall_list_to_string(l_tables);
      --
      dpp_inj_krn.inj_drop_table(p_schema, l_list);
      EXECUTE IMMEDIATE ' BEGIN ' || p_schema ||'.dpump_drop_table(:err,:table_name,:err_text); END;  '
        USING OUT l_remote_err, OUT l_remote_table, OUT l_remote_err_text;
      dpp_inj_krn.inj_drop_drop_table(p_schema);
      IF l_remote_err <> 0 THEN
      -- there was an error
      trace_p('ORA-' || TO_CHAR(ABS(l_remote_err)) || l_remote_err_text ||', Could not drop table:' || l_remote_table);

      RAISE dpp_job_var.ge_drop_obj_failed;
      END IF;
      --
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING TABLES FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_mv(p_schema IN VARCHAR2) 
   IS
      l_sql_text        VARCHAR2(4000);
      l_sql_error       PLS_INTEGER;
      l_action          VARCHAR2(50) := 'drop_all_mv';
      l_list            VARCHAR2(4000);
      l_mv              dpp_job_var.gt_list_names_type;
      l_remote_err      NUMBER;
      l_remote_table    VARCHAR2(60);
      l_remote_err_text VARCHAR2(2000);
   BEGIN

      SELECT ndt.object_name BULK COLLECT
        INTO l_mv
        FROM dpp_nodrop_objects  ndt
       INNER JOIN dpp_schemas sma
         ON sma.sma_id = ndt.sma_id
        AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'MV'
         AND ndt.active_flag = 'Y';
       --
       l_list := marshall_list_to_string(l_mv);
       --
       dpp_inj_krn.inj_drop_mv(p_schema, l_list);
       EXECUTE IMMEDIATE ' BEGIN ' || p_schema ||
                         '.dpump_drop_mv(:err,:table_name,:err_text); END;  '
         USING OUT l_remote_err, OUT l_remote_table, OUT l_remote_err_text;
       dpp_inj_krn.inj_drop_drop_mv(p_schema);
       IF l_remote_err <> 0 THEN
          -- there was an error
          trace_p('ORA-' || TO_CHAR(ABS(l_remote_err)) || l_remote_err_text ||', Could not drop table:' || l_remote_table);

          RAISE dpp_job_var.ge_drop_obj_failed;
       END IF;
       --
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING MATERIALIZED VIEWS FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_dblinks(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_db_links';
      l_db_links  dpp_job_var.gt_list_names_type;
      l_list      VARCHAR2(4000);
   BEGIN
    --
      SELECT ndt.object_name BULK COLLECT
        INTO l_db_links
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'DATABASE LINK'
         AND ndt.active_flag = 'Y';
      --
      l_list := marshall_list_to_string(l_db_links);
      --
      dpp_inj_krn.inj_clear_all_db_links(p_schema, l_list);
      EXECUTE IMMEDIATE ' BEGIN ' || p_schema ||'.dpump_clear_all_db_links; END; ';
      dpp_inj_krn.inj_drop_clear_all_db_links(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING DATABASE LINKS FAILED IN' || p_schema);
         RAISE;
  END;

   PROCEDURE drop_all_constraints(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_constraints';
      l_tables    dpp_job_var.gt_list_names_type;
      l_list      VARCHAR2(4000);
   BEGIN
      --
      SELECT ndt.object_name BULK COLLECT
        INTO l_tables
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'CONSTRAINT'
         AND ndt.active_flag = 'Y';
      --
      l_list := marshall_list_to_string(l_tables);
      --

      dpp_inj_krn.inj_drop_ref_constraint(p_schema, l_list);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_drop_constraints; END; ';
      dpp_inj_krn.inj_drop_drop_ref_constraint(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING CONSTRAINTS FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_AQ(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_AQ';
   BEGIN
      --
      dpp_inj_krn.inj_drop_AQ(p_schema);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_drop_AQ(:p_schema); END; ' 
        USING p_schema;
      dpp_inj_krn.inj_drop_drop_AQ(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING ADVANCED QUEUING IN ' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_views(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_views';
      l_list      VARCHAR2(4000);
      --
      l_all_views dpp_job_var.gt_list_names_type;
   BEGIN
      SELECT ndt.object_name BULK COLLECT
        INTO l_all_views
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'VIEW'
         AND ndt.active_flag = 'Y';

      l_list := marshall_list_to_string(l_all_views);
      dpp_inj_krn.inj_drop_view(p_schema, l_list);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_drop_all_views; END; ';
      dpp_inj_krn.inj_drop_drop_view(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'DROPPING VIEWS FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE drop_all_types(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'drop_all_types';
      --
      l_list      VARCHAR2(4000);
      l_all_types dpp_job_var.gt_list_names_type;
   BEGIN
      SELECT ndt.object_name BULK COLLECT
        INTO l_all_types
        FROM dpp_nodrop_objects ndt
       INNER JOIN dpp_schemas sma
          ON sma.sma_id = ndt.sma_id
         AND sma.sma_name = p_schema
       WHERE ndt.object_type = 'TYPE'
         AND ndt.active_flag = 'Y';

      l_list := marshall_list_to_string(l_all_types);
      dpp_inj_krn.inj_drop_types(p_schema, l_list);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema || '.dpump_drop_types; END; ';
      dpp_inj_krn.inj_drop_drop_types(p_schema);
   EXCEPTION
   WHEN OTHERS THEN
      l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
      l_sql_error := SQLCODE;
      log_p(l_sql_error,l_sql_text,l_action,'DROPPING TYPES FAILED IN' || p_schema);
      RAISE;
  END;

   PROCEDURE purge_recycle_bin(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'purge recyclebin';

   BEGIN
      dpp_inj_krn.inj_drop_purge_recyclebin(p_schema);
      EXECUTE IMMEDIATE 'BEGIN ' || p_schema ||'.dpump_purge_recyclebin; END; ';
      dpp_inj_krn.inj_drop_drop_recyclebin(p_schema);
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'PURGING RECYCLEBIN FAILED IN' || p_schema);
         RAISE;
   END;

   PROCEDURE stop_all_jobs(p_schema IN VARCHAR2) 
   IS
      l_sql_text  VARCHAR2(4000);
      l_sql_error PLS_INTEGER;
      l_action    VARCHAR2(50) := 'stop_all_jobs';  
   BEGIN
       EXECUTE IMMEDIATE ' BEGIN ' || p_schema ||'.dpump_stop_all_jobs; END; ';
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'stop_all_jobs FAILED IN' || p_schema);
         RAISE;
   END;

   FUNCTION list_aws_files(p_path IN VARCHAR2) 
   RETURN t_file_list
   IS 
      lt_file_list t_file_list;
   BEGIN
      EXECUTE IMMEDIATE 'SELECT filename 
                           FROM TABLE(RDSADMIN.RDS_FILE_UTIL.LISTDIR(''DATA_PUMP_DIR'')) 
                          ORDER BY mtime DESC' 
      BULK COLLECT INTO lt_file_list;
      RETURN lt_file_list;
   END;

   FUNCTION scan_dir(p_value IN VARCHAR2) RETURN dpp_job_var.gt_import_files_type 
   IS
      l_sql_text     VARCHAR2(4000);
      l_sql_error    PLS_INTEGER;
      l_action       VARCHAR2(25) := 'scan_dir';
      l_import_files dpp_job_var.gt_import_files_type;
      l_env_name VARCHAR2(128);
   BEGIN
      l_env_name := get_schema_env_name(trim(upper(extract_sma_name(p_value)))); 
      IF l_env_name in ('DC', 'COP') THEN 
          -- we are in DC
          SELECT COLUMN_VALUE full_name BULK COLLECT
            INTO l_import_files
            FROM TABLE(dpp_job_krn.list_files(dpp_job_var.g_dpp_dir)) S0
           WHERE REGEXP_INSTR(COLUMN_VALUE, p_value || '[0-9]{5}\.exp$') > 0
             AND SUBSTR(REGEXP_SUBSTR(COLUMN_VALUE, '[0-9]{5}.exp$'), 1, 2) IN
                 (SELECT MAX(SUBSTR(REGEXP_SUBSTR(COLUMN_VALUE, '[0-9]{5}.exp$'),
                                    1,
                                    2))
                    FROM TABLE(dpp_job_krn.list_files(dpp_job_var.g_dpp_dir)) lstfil
                   WHERE REGEXP_INSTR(COLUMN_VALUE, p_value || '[0-9]{5}\.exp$') > 0);
      ELSE
          SELECT COLUMN_VALUE full_name BULK COLLECT
            INTO l_import_files
            FROM TABLE(dpp_job_krn.list_aws_files(dpp_job_var.g_dpp_dir)) S0
           WHERE REGEXP_INSTR(COLUMN_VALUE, p_value || '[0-9]{5}\.exp$') > 0
             AND SUBSTR(REGEXP_SUBSTR(COLUMN_VALUE, '[0-9]{5}.exp$'), 1, 2) IN
                 (SELECT MAX(SUBSTR(REGEXP_SUBSTR(COLUMN_VALUE, '[0-9]{5}.exp$'),
                                    1,
                                    2))
                    FROM TABLE(dpp_job_krn.list_aws_files(dpp_job_var.g_dpp_dir)) lstfil
                   WHERE REGEXP_INSTR(COLUMN_VALUE, p_value || '[0-9]{5}\.exp$') > 0);

      END IF;
      RETURN l_import_files;
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error,l_sql_text,l_action,'SCANNING CONTENT OF DIRECTORY' || dpp_job_var.g_dpp_dir || ' FAILED OR ' || USER);
         RAISE;
   END;

   FUNCTION find_files(p_value   IN VARCHAR2
                      ,p_options IN NUMBER DEFAULT NULL
                      )
   RETURN dpp_job_var.gt_import_files_type 
   IS  
      l_context      VARCHAR2(100);
      l_pos          PLS_INTEGER;
      l_import_files dpp_job_var.gt_import_files_type;
   BEGIN
      --
      -- we can have two kinds of context_id,
      -- 1. is a full context id
      -- 2. partial one with the export schema name , the current date will be added
      --
      dpp_itf_krn.log_message(p_type => 'INFO'
                             ,p_text => 'Find Files called with value '||p_value
                             );
      l_pos     := REGEXP_INSTR(p_value, '[0-9]{8}$');
      l_context := p_value;
      IF l_pos = 0 THEN
         -- NOT an extended name, get the highest context
         l_context := p_value || TO_CHAR(SYSDATE, 'YYYYMMDD');
         l_import_files := scan_dir(l_context);
         IF l_import_files.FIRST IS NULL THEN
            -- try on day before if import running early in the morning
            IF TO_CHAR(SYSDATE,'HH24') BETWEEN '00' AND '04'
            THEN
               dpp_itf_krn.log_message(p_type => 'WARNING'
                                      ,p_text => 'NO IMPORT FILES FOR ' ||l_context||'. Switch to day before'
                                      );
               l_context := p_value || TO_CHAR(SYSDATE-1, 'YYYYMMDD');
               l_import_files := scan_dir(l_context);
            ELSE
               dpp_itf_krn.log_message(p_type => 'ERROR'
                                      ,p_text => 'NO IMPORT FILES FOR ' ||l_context
                                               ||'. Cannot switch to day before for '
                                               ||p_value || TO_CHAR(SYSDATE-1, 'YYYYMMDD')
                                               ||'  because it''s not within the allowed timeframe.'
                                      );
            END IF;
         END IF;
      ELSE  
         -- extended name
         l_import_files := scan_dir(l_context);
         dpp_itf_krn.log_message(p_type => 'INFO'
                                    ,p_text => 'File name suffix= '||REGEXP_SUBSTR(p_value, '[0-9]{8}$')||' vs date='||TO_CHAR(SYSDATE, 'YYYYMMDD')
                                    );
         IF l_import_files.FIRST IS NULL 
         AND REGEXP_SUBSTR(p_value, '[0-9]{8}$') = TO_CHAR(SYSDATE, 'YYYYMMDD') --suffix = today
         THEN
            -- if explicit name, we assume it's done on purpose => no more restrictions
            --IF TO_CHAR(SYSDATE,'HH24') BETWEEN '00' AND '04'
            --THEN
            dpp_itf_krn.log_message(p_type => 'WARNING'
                                       ,p_text => 'NO IMPORT FILES FOR ' ||l_context||'. Switch to day before'
                                       );
            l_context := SUBSTR(p_value, 1, l_pos - 1) || TO_CHAR(SYSDATE-1, 'YYYYMMDD');
            l_import_files := scan_dir(l_context);
         END IF;
      END IF;
      IF l_import_files.FIRST IS NULL THEN
         IF p_options IS NULL THEN
         dpp_itf_krn.log_message(p_type => 'ERROR'
                                    ,p_text => 'NO IMPORT FILES FOR ' ||l_context
                                    );
         END IF;
         RAISE dpp_job_var.ge_no_imp_file_for_context;
      END IF;
      RETURN l_import_files;
   END;

   FUNCTION get_cpu_count 
   RETURN NUMBER 
   IS
      l_cpu_cnt NUMBER;
      l_err varchar2(500);
   BEGIN
      SELECT TO_NUMBER(par.value)
        INTO l_cpu_cnt
        FROM sys.v_$parameter par
       WHERE par.name = 'cpu_count';
      RETURN l_cpu_cnt;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_err := 'No data found for cpu_count';
         trace_p('GET_CPU_COUNT - '||l_err);
      WHEN TOO_MANY_ROWS THEN
         l_err := 'More than one record found for cpu_count';
         trace_p('GET_CPU_COUNT - '||l_err);         
      WHEN OTHERS THEN
         l_err := substr(sqlerrm,1, 500);
         trace_p('GET_CPU_COUNT - '||l_err);
         RETURN NULL;
   END;

   FUNCTION check_running_jobs(p_target_schema IN VARCHAR2) 
   RETURN BOOLEAN 
   IS
      l_rc    BOOLEAN;
      l_cnt NUMBER;
   BEGIN
      EXECUTE IMMEDIATE ' BEGIN ' || p_target_schema ||'.dpump_check_running_jobs(:l_cnt); END; '
        USING OUT l_cnt;
      l_rc := FALSE;
      IF l_cnt = 0 OR l_cnt IS NULL THEN
      -- no running jobs
         l_rc := TRUE;
      END IF;
      RETURN l_rc;
   END;

   FUNCTION check_dir_object(p_target_schema IN VARCHAR2) 
   RETURN BOOLEAN 
   IS
      l_rc    BOOLEAN;
      l_cnt NUMBER;
   BEGIN
      EXECUTE IMMEDIATE 'BEGIN ' || p_target_schema ||'.dpump_chk_dir_object(:l_cnt); END;'
         USING OUT l_cnt;
      l_rc := TRUE;
      IF l_cnt = 0 OR l_cnt IS NULL THEN
         l_rc := FALSE;
      END IF;
      RETURN l_rc;
   END;

   FUNCTION self_test(p_action IN VARCHAR2, p_target_schema IN VARCHAR2)
   RETURN BOOLEAN 
   IS
   BEGIN
      --
      --  BUG: Metalink 315488.1 does this user have the create table privilege explicitly granted (not via a role) to him?
      --
      IF p_action NOT IN ('IMPORT', 'EXPORT') THEN
         dpp_itf_krn.log_message(p_type => 'ERROR',p_text => 'INTERNAL NO ACTION DEFINED MUST BE "IMPORT" OR "EXPORT"');
         RETURN FALSE;
      END IF;

      /*IF check_privs(p_target_schema) = FALSE THEN
         dpp_itf_krn.log_message(p_type => 'ERROR',p_text => 'SEE METALINK NO 315488.1, ASSIGN SYSTEM PRIV "CREATE TABLE" EXPLICITLY');
         RETURN FALSE;
      END IF;
      */
      --
      -- check for directory object, dump files
      --
      IF check_dir_object(p_target_schema) = FALSE THEN
         dpp_itf_krn.log_message(p_type => 'ERROR',p_text => 'Directory object ' ||dpp_job_var.g_dpp_dir || ' doesnt exist!');
         RETURN FALSE;
      END IF;
      --
      RETURN TRUE; -- passed all checks
   END;

   PROCEDURE configure_export(p_sma_id        IN dpp_schemas.sma_id%TYPE
                             ,p_target_schema IN VARCHAR2
                             ,p_options       IN VARCHAR2 DEFAULT NULL
                             ) 
   IS
      l_subfile_idx  CHAR(3);
      l_filename     VARCHAR2(100);
      l_sql_text     VARCHAR2(4000);
      l_sql_error    PLS_INTEGER;
      l_exclude_list dpp_inj_var.gt_list_type;
   BEGIN
      --
      -- RECYCLEBIN=PURGE#RECOMPILE_PL_SQL=NO#EXEC_POSTFIX=YES#EXEC_PREFIX=YES#LOCK_SCHEMA=NO#
      --
      set_parallelism(p_options);
      --
      dpp_inj_krn.inj_config_pump_file(p_target_schema);
      FOR I IN 1 .. dpp_job_var.g_cpu_count LOOP
         l_subfile_idx := LPAD(TO_CHAR(I), 3, '0');
         l_filename    := p_target_schema || TO_CHAR(dpp_job_var.g_context) || '.exp.' ||
                          l_subfile_idx || '.bsy';

         EXECUTE IMMEDIATE ' BEGIN ' || p_target_schema ||
                           '.dpump_config_pump_file(:jobno, :fileName); END; '
           USING IN dpp_job_var.g_job_number, IN l_filename;
      END LOOP;
      -- 
      dpp_inj_krn.inj_drop_config_pump_file(p_target_schema);
      -- 
      dpp_inj_krn.inj_config_set_parallel(p_target_schema);
      EXECUTE IMMEDIATE ' BEGIN  ' || p_target_schema ||'.dpump_conf_set_parallel(:jobno,:cpucount); END; '
        USING IN dpp_job_var.g_job_number, IN dpp_job_var.g_cpu_count;
      dpp_inj_krn.inj_drop_config_set_parallel(p_target_schema);
      -- 
      dpp_inj_krn.inj_exp_logfile(p_target_schema);
      dpp_job_var.g_logfile := TO_CHAR(p_target_schema || dpp_job_var.g_context) || '.exp.log';
      EXECUTE IMMEDIATE ' BEGIN ' || p_target_schema ||'.dpump_conf_exp_logfile(:job_no,:p_context); END; '
        USING IN dpp_job_var.g_job_number, IN dpp_job_var.g_logfile;
      trace_p('OS logfile created:' || dpp_job_var.g_logfile);
      dpp_inj_krn.inj_drop_exp_logfile(p_target_schema);
      --
      dpp_inj_krn.inj_write_start_time(p_target_schema);
      BEGIN
         EXECUTE IMMEDIATE 'BEGIN ' || p_target_schema ||'.dpump_write_start_time(:job_no,:start_time); END; '
           USING IN dpp_job_var.g_job_number, IN dpp_job_var.g_start_time;
      EXCEPTION
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error, l_sql_text, 'write start time');
            RAISE;
      END;
      dpp_inj_krn.inj_drop_write_start_time(p_target_schema);
      --
      dpp_inj_krn.inj_conf_flashbacktime(p_target_schema);
      BEGIN
         EXECUTE IMMEDIATE 'BEGIN ' || p_target_schema ||'.dpump_config_flashbacktime(:job_no); END; '
           USING IN dpp_job_var.g_job_number;
      EXCEPTION
         WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            blead_pump_status(l_sql_error,dpp_job_var.g_job_number,'setting flashback time');
            log_p(l_sql_error, l_sql_text, 'write start time');
            RAISE;
      END;
      dpp_inj_krn.inj_drop_conf_flashbacktime(p_target_schema);
      --
      SELECT list BULK COLLECT
        INTO l_exclude_list
        FROM (SELECT 'GRANT' list
                FROM dual
               UNION
              SELECT 'DB_LINK'
                FROM dual
               UNION
              SELECT 'JOB' 
                FROM dual
             );

      dpp_inj_krn.inj_conf_metadata_filter(p_sma_id,p_target_schema,l_exclude_list);
      EXECUTE IMMEDIATE ' BEGIN ' || p_target_schema ||'.dpump_cfg_METADATA_filter(:job_no); END; '
        USING IN dpp_job_var.g_job_number;
      dpp_inj_krn.inj_drop_conf_metadata_filter(p_target_schema);
   END;

   PROCEDURE configure_import(p_src_schema   IN VARCHAR2
                             ,p_trg_schema   IN VARCHAR2
                             ,p_trg_sma_id   IN dpp_schemas.sma_id%TYPE
                             ,p_job_number   IN NUMBER
                             ,p_start_time   IN DATE
                             ,p_simulation   IN BOOLEAN := FALSE
                             ,p_options      IN VARCHAR2
                             ,p_import_files IN dpp_job_var.gt_import_files_type
                             ) 
   IS
      l_file_name     VARCHAR2(500);
      l_sql_text      VARCHAR2(4000);
      l_sql_error     PLS_INTEGER;
      l_action        VARCHAR2(50) := 'configure_import';
      l_tblspace_list VARCHAR2(2000);
      l_exclude_list dpp_inj_var.gt_list_type;  
      PROCEDURE remap_tablespace(p_tblspace_list IN VARCHAR2) IS
         -- work vars
         l_pos  NUMBER;
         l_rest VARCHAR2(1000);
         l_paid VARCHAR2(1000);
         l_src  VARCHAR2(50);
         l_dst  VARCHAR2(50);
      BEGIN
         l_rest := UPPER(TRIM(p_tblspace_list));
         LOOP
            EXIT WHEN l_rest IS NULL;
            l_pos := INSTR(l_rest, ',');
            --
            IF l_pos = 0 THEN
               -- we are on the last mapping
               l_paid := TRIM(l_rest);
               l_rest := NULL;
            ELSE
               l_paid := SUBSTR(l_rest, 1, l_pos - 1);
               l_rest := SUBSTR(l_rest, l_pos + 1);
            END IF;
            --
            l_pos := INSTR(l_paid, '=>');

            IF l_pos = 0 THEN
               RAISE dpp_job_var.ge_illegal_argument;
            END IF;

            l_src := TRIM(SUBSTR(l_paid, 1, l_pos - 1));
            l_dst := TRIM(SUBSTR(l_paid, l_pos + 2));
            BEGIN
               dpp_inj_krn.inj_cfg_tblspace_map(p_trg_schema, l_src, l_dst);
               EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_tblspace_map(:job_no); END; '
                 USING IN p_job_number; --, IN TO_CHAR(g_context);
               dpp_inj_krn.inj_cfg_tblspace_map(p_trg_schema, l_src, l_dst);
            EXCEPTION
               WHEN OTHERS THEN
                  l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
                  l_sql_error := SQLCODE;
                  blead_pump_status(l_SQL_error, p_job_number, l_action);
                  log_p(l_sql_error, l_sql_text, l_action);
                  RAISE;
            END;
         END LOOP;
      END;

   BEGIN
      --
      dpp_inj_krn.inj_config_pump_file(p_trg_schema);
      IF getvalues(p_key => 'NETWORK_LINK', p_data => p_options) IS NULL THEN
         IF p_simulation = FALSE THEN
            FOR I IN p_import_files.FIRST .. p_import_files.LAST LOOP
              BEGIN
                l_file_name := p_import_files(i);
                EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_config_pump_file(:job_no,:file_name); END; '
                  USING IN p_job_number, IN l_file_name;
              EXCEPTION
                WHEN OTHERS THEN
                  l_sql_error := SQLCODE;
                  blead_pump_status(l_SQL_error, p_job_number, l_action);
                  RAISE;
              END;
            END LOOP;
            trace_p('Datapump files added to configuration.');
         END IF; -- if p_simulation ....
      ELSE
         trace_p('No Datapump files to be added to configuration.');      
      END IF;   
      --
      --
      dpp_inj_krn.inj_drop_config_pump_file(p_trg_schema);
      dpp_inj_krn.inj_config_set_parallel(p_trg_schema);
      IF p_simulation = FALSE THEN      
         EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_conf_set_parallel(:job_no,:cpu_count); END; '
           USING IN p_job_number, IN dpp_job_var.g_cpu_count;
         trace_p('Datapump parallelism set.');
      END IF;
      dpp_inj_krn.inj_drop_config_set_parallel(p_trg_schema);
      --
      --
      dpp_inj_krn.inj_imp_logfile(p_trg_schema);
      IF p_simulation = FALSE THEN
         dpp_job_var.g_logfile := TO_CHAR(p_trg_schema || dpp_job_var.g_context) || '.imp.log';
         EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_conf_imp_logfile(:job_no,:p_logfile_name); END; '
           USING IN p_job_number, IN dpp_job_var.g_logfile;
         trace_p('Datapump OS logfile created:' || dpp_job_var.g_logfile);
      END IF;
      --
      dpp_inj_krn.inj_drop_imp_logfile(p_trg_schema);
      --
      dpp_inj_krn.inj_write_start_time(p_trg_schema);
      IF p_simulation = FALSE THEN
         BEGIN
            EXECUTE IMMEDIATE 'BEGIN ' || p_trg_schema ||'.dpump_write_start_time(:job_no,:start_time); END; '
              USING IN p_job_number, IN p_start_time;
         EXCEPTION
            WHEN OTHERS THEN
               l_sql_error := SQLCODE;
               blead_pump_status(l_SQL_error, p_job_number, l_action);
               RAISE;
         END;
      END IF;
      dpp_inj_krn.inj_drop_write_start_time(p_trg_schema);
      --
      dpp_inj_krn.inj_config_remap(p_trg_schema);
      IF p_simulation = FALSE THEN
         BEGIN
            EXECUTE IMMEDIATE 'BEGIN ' || p_trg_schema ||'.dpump_config_remap(:src_schema,:trg_schema,:job_no); END; '
              USING IN p_src_schema, IN p_trg_schema, IN p_job_number;
         EXCEPTION
            WHEN OTHERS THEN
               l_sql_error := SQLCODE;
               blead_pump_status(l_SQL_error, p_job_number, l_action);
               RAISE;
         END;
      END IF;
      dpp_inj_krn.inj_drop_config_remap(p_trg_schema);
      --
      --
      dpp_inj_krn.inj_config_metadata(p_trg_schema);


      IF p_simulation = FALSE THEN
         BEGIN
            EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_config_metadata(:job_no); END; '
              USING IN p_job_number;
         EXCEPTION
            WHEN OTHERS THEN
               l_sql_error := SQLCODE;
               blead_pump_status(l_SQL_error, p_job_number, l_action);
               RAISE;
         END;
      END IF;
      dpp_inj_krn.inj_drop_config_metadata(p_trg_schema);
      --
      IF getvalues(p_key => 'SEGMENT_ATTRIBUTES', p_data => p_options) = 'IGNORE' 
      THEN

         dpp_inj_krn.inj_cfg_mdata_trans_imp(p_trg_schema); -- no option (default 1) : SEGMENT_ATTRIBUTE
         IF p_simulation = FALSE THEN
            BEGIN
               EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_metadata_trn_imp(:job_no); END; '
                 USING IN p_job_number;
            EXCEPTION
               WHEN OTHERS THEN
                  l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
                  l_sql_error := SQLCODE;
                  log_p(l_sql_error, l_sql_text, l_action);
                  blead_pump_status(l_SQL_error, p_job_number, l_action);
                  RAISE;
            END;
         END IF;
         dpp_inj_krn.inj_drp_cfg_mdata_trans_imp(p_trg_schema);
      END IF;

      dpp_inj_krn.inj_cfg_mdata_trans_imp(p_trg_schema,2); -- option 2; OID
      IF p_simulation = FALSE THEN
         BEGIN
           EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_metadata_trn_imp(:job_no); END; '
             USING IN p_job_number;
         EXCEPTION
            WHEN OTHERS THEN
            l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
            l_sql_error := SQLCODE;
            log_p(l_sql_error, l_sql_text, l_action);
            blead_pump_status(l_SQL_error, p_job_number, l_action);
            RAISE;
         END;
      END IF;
      dpp_inj_krn.inj_drp_cfg_mdata_trans_imp(p_trg_schema);


      IF getvalues(p_key => 'STORAGE', p_data => p_options) = 'IGNORE' 
      THEN
         dpp_inj_krn.inj_cfg_mdata_trans_imp(p_trg_schema, 3); -- option 3, STORAGE
         IF p_simulation = FALSE THEN
            BEGIN
               EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_metadata_trn_imp(:job_no); END; '
                 USING IN p_job_number;
            EXCEPTION
               WHEN OTHERS THEN
                  l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
                  l_sql_error := SQLCODE;
                  log_p(l_sql_error, l_sql_text, l_action);
                  blead_pump_status(l_SQL_error, p_job_number, l_action);
                  RAISE;
            END;
         END IF;
         dpp_inj_krn.inj_drp_cfg_mdata_trans_imp(p_trg_schema);
      END IF;

     --
      dpp_inj_krn.inj_config_set_params_imp(p_trg_schema);
      IF p_simulation = FALSE THEN
         BEGIN
            EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_set_param_imp(:job_no); END; '
              USING IN p_job_number;
         EXCEPTION
            WHEN OTHERS THEN
               l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
               l_sql_error := SQLCODE;
               log_p(l_sql_error, l_sql_text, l_action);
               blead_pump_status(l_SQL_error, p_job_number, l_action);
               RAISE;
         END;
   END IF;
   dpp_inj_krn.inj_drop_config_set_params_imp(p_trg_schema);
    --
   l_tblspace_list := getvalues(p_key  => 'REMAP_TABLESPACE',p_data => p_options);
   IF p_simulation = FALSE THEN
      IF NOT l_tblspace_list IS NULL THEN
         remap_tablespace(l_tblspace_list);
         trace_p('Tablespaces remapped in datapump');
      END IF;
   END IF;

   IF getvalues(p_key  => 'METALINK_429846_1_CORRECTION',
                 p_data => p_options) = 'YES' THEN
     dpp_inj_krn.inj_imp_metalink_429846_1(p_trg_schema);
      BEGIN
        EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||
                          '.dpump_cfg_metalink429846_1(:job_no); END; '
          USING IN p_job_number;
      EXCEPTION
        WHEN OTHERS THEN
          l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
          l_sql_error := SQLCODE;
          log_p(l_sql_error, l_sql_text, l_action);
          blead_pump_status(l_SQL_error, p_job_number, l_action);
          RAISE;
      END;
      trace_p('Metalink 429846_1 correction applied..');
     dpp_inj_krn.inj_drop_imp_metalink_429846_1(p_trg_schema);
    END IF;
   -- Metadata filter 
   IF getvalues(p_key => 'NETWORK_LINK', p_data => p_options) IS NOT NULL THEN
      dpp_inj_krn.inj_conf_metadata_filter(p_trg_sma_id,p_trg_schema,l_exclude_list);
      trace_p('Metadata filter defined for the import into target '||p_trg_sma_id||'-'||p_trg_schema);

      EXECUTE IMMEDIATE ' BEGIN ' || p_trg_schema ||'.dpump_cfg_metadata_filter(:job_no); END; '
      USING IN dpp_job_var.g_job_number;
      dpp_inj_krn.inj_drop_conf_metadata_filter(p_trg_schema);
  END IF;
  END configure_import;

  FUNCTION generate_context_id(p_value IN VARCHAR2,p_sma_id IN dpp_schemas.sma_id%TYPE) 
  RETURN NUMBER IS
    l_rc      NUMBER;
    l_context NUMBER;
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    dpp_job_var.g_start_time := SYSDATE;
    dpp_job_var.g_stop_time  := SYSDATE;
    IF p_value not in ('EXPORT', 'IMPORT', 'TRANSFER') THEN
      RAISE dpp_job_var.ge_illegal_argument;
    END IF;
    --
    dpp_job_var.g_app_run_type             := CASE 
                                              WHEN p_value = 'EXPORT' THEN 'EXPJB' 
                                              WHEN p_value = 'IMPORT' THEN 'IMPJB' 
                                              ELSE 'TRFJB' 
                                              END;
    dpp_itf_var.g_job_type := dpp_job_var.g_app_run_type;
    --
    l_rc := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')); -- the startnumber for todays export
    --
    LOCK TABLE dpp_job_runs IN EXCLUSIVE MODE;

    SELECT NVL(MAX(jrn_id) + 1, l_rc * 100)
      INTO l_context
      FROM dpp_job_runs jrn
     WHERE jrn.jte_cd = dpp_job_var.g_app_run_type
       AND jrn.jrn_id >= l_rc * 100;
    -- we always have a avalue for l_context
    -- INSERT it into
    INSERT INTO dpp_job_runs
      (jrn_id,
       jte_cd,
       sma_id,
       date_started,
       date_ended,
       date_creat,
       user_creat,
       date_modif,
       user_modif,
       status)
    VALUES
      (l_context,
       dpp_job_var.g_app_run_type,
       p_sma_id,
       dpp_job_var.g_start_time,
       dpp_job_var.g_start_time,
       dpp_job_var.g_start_time,
       USER,
       dpp_job_var.g_start_time,
       USER,
       'BSY');

    --
    COMMIT;
    dpp_itf_krn.set_context(l_context);
    dpp_itf_krn.set_time_mask(NULL);
    dpp_itf_var.g_last_line    := 1;
    dpp_itf_var.g_last_context := l_context;
    dpp_itf_krn.log_message(p_type => 'Info',
                                p_text => 'Datapump session start:' ||
                                          l_context);

    RETURN l_context;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK; -- i cannot log here, because the context doesnt exist yet
      RAISE;
  END generate_context_id;

  PROCEDURE set_end_time IS
    l_tick_count NUMBER;
  BEGIN
    dpp_job_var.g_stop_time := NULL;
    --
    l_tick_count := (DBMS_UTILITY.GET_TIME - dpp_job_var.g_diff_cpu_count);
    l_tick_count := l_tick_count / 100; -- number of seconds
    l_tick_count := l_tick_count / 86400; -- fraction of days
    dpp_job_var.g_stop_time  := dpp_job_var.g_start_time + l_tick_count;
  END;

   PROCEDURE set_start_time IS
   BEGIN
      dpp_job_var.g_diff_cpu_count := DBMS_UTILITY.GET_TIME;
      dpp_job_var.g_start_time     := SYSDATE;
   END;

   PROCEDURE stop_scheduled_jobs(p_target_schema IN VARCHAR2) IS
   BEGIN
      dpp_inj_krn.inj_dpump_stop_all_jobs(p_target_schema);
      stop_all_jobs(p_target_schema);
      dpp_inj_krn.inj_drop_dpump_stop_all_jobs(p_target_schema);
      COMMIT;
   END stop_scheduled_jobs;

   FUNCTION exists_AQ(p_target_schema IN VARCHAR2)
   RETURN BOOLEAN
   IS
      CURSOR c_qt (p_target_schema VARCHAR2) 
          IS
      SELECT COUNT(*)
        FROM all_queues
       WHERE owner = p_target_schema;
      l_ret NUMBER;  
   BEGIN
      OPEN c_qt(p_target_schema);
      FETCH c_qt INTO l_ret;
      CLOSE c_qt;

      RETURN l_ret > 0 ;

      EXCEPTION
         WHEN OTHERS THEN
            IF c_qt%ISOPEN THEN
               CLOSE c_qt;
            END IF;
            RAISE;
   END;

  PROCEDURE import_data(p_source_schema IN VARCHAR2,
                        p_target_schema IN VARCHAR2,
                        p_target_sma_id IN dpp_schemas.sma_id%TYPE,
                        p_options       IN VARCHAR2)
  IS
     l_sql_error  PLS_INTEGER;
     l_sql_text   VARCHAR2(4000);
     l_action     VARCHAR2(50) := 'import_data';
     l_src_schema VARCHAR2(30);
     l_db_link    VARCHAR2(128); 
     l_check      BOOLEAN;
     l_sim_import BOOLEAN;
     --
     l_offset_postfix_c VARCHAR2(50);
     l_offset_postfix   NUMBER;
     l_import_files     dpp_job_var.gt_import_files_type;

     l_plsql BOOLEAN ;
     l_view  BOOLEAN ;
     l_seq   BOOLEAN ;       
     l_syn   BOOLEAN ;
     l_type  BOOLEAN ;
     l_cons  BOOLEAN ;
     l_tab   BOOLEAN ;
     l_mv    BOOLEAN ;

   BEGIN
      --
      --
      IF TRIM(p_source_schema) IS NULL OR TRIM(p_target_schema) IS NULL THEN
         RETURN;
      END IF;
      --
      EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_MODE = CHOOSE';
      --
      dpp_job_var.g_dpp_dir := dpp_job_mem.get_prr('g_dpp_in_dir').prr_value;

      --
      -- check if there is already a job running
      --
      dpp_inj_krn.inj_check_running_jobs(p_target_schema);
      l_check := check_running_jobs(p_target_schema);
      dpp_inj_krn.inj_drop_check_running_jobs(p_target_schema);
      --
      trace_p('Checking, Other import jobs are running in target schema? :' || CASE
            l_check WHEN TRUE THEN 'No.' ELSE 'Yes.' END);

      IF l_check = FALSE THEN
         -- running jobs
         dpp_itf_krn.log_message(p_type => 'ERROR'
                                ,p_text => 'A datapump operation is currently busy in schema:' ||p_target_schema);
         RAISE dpp_job_var.ge_selftest_failed;
      END IF;
      --
      l_src_schema := extract_sma_name(p_source_schema);
      --
      IF NOT check_exist_trg_schema(p_target_schema) THEN
         RAISE dpp_job_var.ge_target_schema_doesnt_exist;
      END IF;
      --

      --
      l_db_link := getvalues(p_key => 'NETWORK_LINK', p_data => p_options);
      IF l_db_link IS NULL THEN
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:DISCOVER PUMP FILES'
                                         ,'IMP:DISCOVER PUMP FILES'
                                         );
         l_import_files := find_files(p_source_schema);
         trace_p('Dump files found on disk...');
      ELSE
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:DISCOVER NETWORK LINK'
                                         ,'IMP:DISCOVER NETWORK LINK'
                                         );
         trace_p('No dump files needed. It will be a direct import.');
      END IF;  
      --
      IF getvalues(p_key => 'JOBS', p_data => p_options) = 'STOP' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:STOP JOBS', 'STOP JOBS');
         trace_p('Stopping Jobs owned by ' || p_target_schema);
         stop_scheduled_jobs(p_target_schema);
         trace_p('Jobs stopped!');
      END IF;
      -- check lock objects before going further
      -- evaluate all ; is_object_locked give some details on lock ; still nice to know
      trace_p('Checking for locked objects') ; 
      l_plsql := getvalues(p_key => 'PL_SQL_SOURCE', p_data => p_options) = 'DROP'
                and
               (is_object_locked('PACKAGE', p_target_schema)
                or 
                is_object_locked('FUNCTION', p_target_schema)
                or
                is_object_locked('PROCEDURE', p_target_schema)
               ) ;
      l_view := getvalues(p_key => 'VIEWS', p_data => p_options) = 'DROP'
                 and is_object_locked('VIEW', p_target_schema) ;

      l_seq := getvalues(p_key => 'SEQUENCES', p_data => p_options) = 'DROP'
                 and is_object_locked('SEQUENCE', p_target_schema) ;

      l_syn := getvalues(p_key => 'SYNONYMS', p_data => p_options) = 'DROP'
                 and is_object_locked('SYNONYM', p_target_schema) ;

      l_type := getvalues(p_key => 'TYPES', p_data => p_options) = 'DROP'
                 and is_object_locked('TYPE', p_target_schema) ;

      l_cons := getvalues(p_key => 'CONSTRAINTS', p_data => p_options) = 'DROP'
                 and is_object_locked('CONSTRAINT', p_target_schema) ;               

      l_tab := getvalues(p_key => 'TABLES', p_data => p_options) = 'DROP'
                and is_object_locked('TABLE', p_target_schema) ;

      l_mv := getvalues(p_key => 'MV', p_data => p_options) = 'DROP'
                and is_object_locked('MV', p_target_schema) ;           

      IF l_plsql or l_view or l_seq or l_syn or l_type or l_cons or l_tab or l_mv THEN
         RAISE dpp_job_var.ge_abort_import;
      END IF;

    trace_p('No lock found');

    --
    IF getvalues(p_key => 'EXEC_PREFIX', p_data => p_options) = 'YES' THEN
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:EXEC_PREFIX',
                                       'IMP:EXEC_PREFIX');
      trace_p('Executing prefix scripts!');
--      fix_scan_and_exec_sql('PREFIX', p_target_schema);
        -- Salkovsky, 08-05-2018
      fix_exec_sql('PREFIX', p_target_schema);
      trace_p('All prefix scripts executed!');
    END IF;   

   -- Handle Advanced Queuing if types, views or tables have to be dropped
    -- Otherwise it will cause errors ...      
    IF exists_AQ(p_target_schema) AND 
       (getvalues(p_key => 'TYPES', p_data => p_options) = 'DROP'
        OR getvalues(p_key => 'VIEWS', p_data => p_options) = 'DROP' 
        OR getvalues(p_key => 'TABLES', p_data => p_options) = 'DROP'
       ) THEN 
       DBMS_APPLICATION_INFO.SET_MODULE('IMP:AQ', 'IMP:AQ');
       trace_p('Dropping AQ objects...');
       drop_AQ(p_target_schema);
       trace_p('AQ objects dropped!');
    END IF;
    IF getvalues(p_key => 'RECYCLEBIN', p_data => p_options) = 'PURGE' THEN
      trace_p('Purging recyclebin....');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:FLUSH RECYCLEBIN',
                                       'IMP:FLUSH RECYCLEBIN');
      purge_recycle_bin(p_target_schema); -- always
      trace_p('Recyclebin purged!');
    END IF;  
    IF getvalues(p_key => 'PL_SQL_SOURCE', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping functions, procedures,packages...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ',
                                       'DROP ALL PACKAGES,PROCEDURES, FUNCTIONS');
      drop_all_proc_func(p_target_schema);
      trace_p('Functions, procedures and packages dropped...');
    END IF;

    IF getvalues(p_key => 'VIEWS', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping views...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP VIEWS');
      drop_all_views(p_target_schema);
      trace_p('Views dropped');
    END IF;
    --  
    IF getvalues(p_key => 'SYNONYMS', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping synonyms....');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ',
                                       'DROP PRIVATE SYNONYMS');
      drop_all_synonyms(p_target_schema);
      trace_p('Synonyms dropped!');
    END IF;
    --
    IF getvalues(p_key => 'CONSTRAINTS', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping constraints...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP CONSTRAINTS');
      drop_all_constraints(p_target_schema);
      trace_p('Constraints dropped!');
    END IF;
    --
    IF getvalues(p_key => 'MV', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping materialized views...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP MATERIALIZED VIEWS');
      drop_all_mv(p_target_schema);
      trace_p('Materialized views dropped!');
    END IF;
    --
    IF getvalues(p_key => 'TABLES', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping tables...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP TABLES');
      drop_all_tables(p_target_schema);
      trace_p('Tables dropped!');
      --
      trace_p('Purging recyclebin....');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:FLUSH RECYCLEBIN',
                                       'IMP:FLUSH RECYCLEBIN');
      purge_recycle_bin(p_target_schema); -- always
      trace_p('Recyclebin purged!');      
      --
    END IF;
    --
    IF getvalues(p_key => 'SEQUENCES', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping sequences....');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP SEQUENCES');
      drop_all_sequences(p_target_schema);
      trace_p('Sequences dropped!');
    END IF;    
    --
    IF getvalues(p_key => 'TYPES', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping types...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ', 'DROP TYPES');
      drop_all_types(p_target_schema);
      trace_p('Types dropped!');
    END IF;
    --
    IF getvalues(p_key => 'PRIVATE_DB_LINKS', p_data => p_options) = 'DROP' THEN
      trace_p('Dropping private DB links...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:DROP OBJ',
                                       'DROP PRIVATE DB_LINKS');
      drop_all_dblinks(p_target_schema);
      trace_p('Private DB links dropped!');
    END IF;

    IF getvalues(p_key => 'RECYCLEBIN', p_data => p_options) = 'PURGE' THEN
      trace_p('Purging recyclebin...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:FLUSH RECYCLEBIN',
                                       'IMP:FLUSH RECYCLEBIN');
      purge_recycle_bin(p_target_schema); -- always
      trace_p('Recyclebin purged');
    END IF;
    --
    DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
    --
    -- SET PARALLELISM
    set_parallelism(p_options);

    IF dpp_job_var.g_cpu_count IS NULL THEN
      RAISE dpp_job_var.ge_abort_export;
    END IF;
    trace_p('Degree of parallelism:' || TO_CHAR(dpp_job_var.g_cpu_count));
    --

    l_sim_import := CASE WHEN getvalues(p_key => 'SIMULATION_IMPORT', p_data => p_options) = 'YES' THEN TRUE ELSE FALSE END;
    --
    DBMS_APPLICATION_INFO.SET_MODULE('IMP:INIT IMPORT', 'INITIATE IMPORT');
    --
    IF initiate_import(p_target_schema, l_sim_import, l_db_link) IS NULL THEN
      RAISE dpp_job_var.ge_abort_import;
    END IF;
    trace_p('Datapump process created..');
    --
    DBMS_APPLICATION_INFO.SET_MODULE('IMP:CONFIG IMPORT',
                                     'CONFIGURE IMPORT');
    configure_import(p_src_schema   => l_src_schema,
                     p_trg_schema   => p_target_schema,
                     p_trg_sma_id   => p_target_sma_id,
                     p_job_number   => dpp_job_var.g_job_number,
                     p_start_time   => dpp_job_var.g_start_time,
                     p_simulation   => l_sim_import,
                     p_options      => p_options,
                     p_import_files => l_import_files);
    trace_p('Datapump import configured.');
    --

    DBMS_APPLICATION_INFO.SET_MODULE('IMP:EXECUTE IMPORT',
                                     'EXECUTE IMPORT');
    trace_p('Running Datapump import job.');
    run_job(p_sma_name => p_target_schema,
            p_job_number  => dpp_job_var.g_job_number,
            p_simulation  => l_sim_import);
    trace_p('DONE! Datapump import job finished.');

    -- cleanup possible injection filth
    --
    cleanup_namespace(p_target_schema);
    --
    -- stop all running or scheduled jobs.
    --
    IF getvalues(p_key => 'JOBS', p_data => p_options) = 'STOP' THEN
      trace_p('Stopping Jobs owned by ' || p_target_schema);
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:STOP JOBS [AFTER IMPORT]',
                                       'STOP JOBS');
      stop_scheduled_jobs(p_target_schema);
      trace_p('Jobs stopped!');
    END IF;
    --
    IF getvalues(p_key => 'RECOMPILE_PL_SQL', p_data => p_options) = 'YES' THEN
      trace_p('Recompile invalid PL/SQL code...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:RECOMPILE PL/SQL',
                                       'RECOMPILE PL/SQL');
      recompile_inv_obj(p_target_schema);
      trace_p('Recompilation completed!.');
    END IF;
    --
    l_offset_postfix_c := getvalues(p_key  => 'EXEC_POSTFIX_START',
                                    p_data => p_options);
    --
    l_offset_postfix := NULL;
    --
    --
    IF NOT l_offset_postfix_c IS NULL THEN
      BEGIN
        l_offset_postfix := TO_NUMBER(l_offset_postfix_c);
      EXCEPTION
        WHEN OTHERS THEN
          l_sql_error := SQLCODE;
          l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
          log_p(l_sql_error, l_sql_text, l_action);
          l_sql_error := -1;
          l_sql_text  := 'VALUE OF "EXEC_POSTFIX_START" IS NOT A NUMBER';
          log_p(l_sql_error, l_sql_text, l_action);
          RAISE;
      END;
    END IF;
    --
    --
    IF getvalues(p_key => 'EXEC_POSTFIX', p_data => p_options) = 'YES' THEN
      trace_p('Executing postfix scripts...');
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:POSTFIX', 'POSTFIX');
--      fix_scan_and_exec_sql('POSTFIX', p_target_schema, l_offset_postfix);
        -- Salkovsky, 08-05-2018
      fix_exec_sql('POSTFIX', p_target_schema, l_offset_postfix);
      trace_p('Postfix scripts executed!');
    END IF;
    --
    -- cleanup
    -- cleanup possible injection filth
    --
    cleanup_namespace(p_target_schema);
    --
    --

    set_end_time;
    close_context_id('OK');
    COMMIT;
   EXCEPTION
    WHEN dpp_job_var.ge_selftest_failed THEN
      l_sql_error := SQLCODE;
      l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
      log_p(l_sql_error, l_sql_text, l_action);
      set_end_time;
      close_context_id('ERR');
      dpp_job_var.g_there_was_an_error := TRUE;
      COMMIT;
    WHEN dpp_job_var.ge_abort_import THEN
      l_sql_error := SQLCODE;
      l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
      log_p(l_sql_error, l_sql_text, l_action);
      set_end_time;
      close_context_id('ERR');
      dpp_job_var.g_there_was_an_error := TRUE;
      COMMIT;
    WHEN dpp_job_var.ge_no_imp_file_for_context THEN
      close_context_id('ERR');
      dpp_job_var.g_there_was_an_error := TRUE;
      COMMIT;
    WHEN dpp_job_var.ge_injection_failed THEN
      l_sql_error := SQLCODE;
      l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
      log_p(l_sql_error, l_sql_text, l_action);
      close_context_id('ERR');
      dpp_job_var.g_there_was_an_error := TRUE;
      trace_p('ERROR   :The '||USER||' user has no rights to create or drop objects in target schema:' ||p_target_schema);
      trace_p('Oracle Error is:' ||l_sql_text);
      COMMIT;
    WHEN OTHERS THEN
      l_sql_error := SQLCODE;
      l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
      l_sql_text  := l_sql_text ||
                     ' IMPORT ABORTED, APPLICATION DEFINED EXCEPTION, GENERIC EXIT';
      log_p(l_sql_error, l_sql_text, l_action);
      set_end_time;
      close_context_id('ERR');
      dpp_job_var.g_there_was_an_error := TRUE;
      COMMIT;
   END import_data;
  --
  --
   FUNCTION initiate_export(p_sma_name IN VARCHAR2) 
   RETURN NUMBER 
   IS  
      l_sql_error PLS_INTEGER;
      l_sql_text  VARCHAR2(4000);
      l_action    VARCHAR2(50) := 'INITIATE_EXPORT';
   BEGIN
      --
      dpp_job_var.g_job_number := NULL;
      --
      dpp_job_var.g_job_number := create_export_job(p_sma_name);
      --
      RETURN dpp_job_var.g_job_number;
   EXCEPTION
      WHEN DBMS_DATAPUMP.invalid_argval THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
      WHEN DBMS_DATAPUMP.privilege_error THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RETURN dpp_job_var.g_job_number;
      WHEN DBMS_DATAPUMP.INTERNAL_ERROR THEN
         -- strange error
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
      WHEN DBMS_DATAPUMP.success_with_info THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         RAISE;
   END;

   PROCEDURE export_data(p_sma_id        IN dpp_schemas.sma_id%TYPE
                        ,p_target_schema IN VARCHAR2
                        ,p_options       IN VARCHAR2 DEFAULT NULL
                        ) 
   IS
      l_sql_error PLS_INTEGER;
      l_sql_text  VARCHAR2(4000);
      l_action    VARCHAR2(50) := 'export_data';
      l_check     BOOLEAN;
   BEGIN
      IF TRIM(p_target_schema) IS NULL THEN
         RETURN;
      END IF;
      --
      EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_MODE = CHOOSE';
      --
      set_start_time;
      --
      dpp_inj_krn.inj_check_running_jobs(p_target_schema);
      l_check := check_running_jobs(p_target_schema);
      dpp_inj_krn.inj_drop_check_running_jobs(p_target_schema);

      trace_p('Checking, Other import/export jobs are running in target schema? :' 
             || CASE l_check WHEN TRUE THEN 'No.' ELSE 'Yes.' END);

      IF l_check = FALSE THEN
         -- running_jobs
         trace_p('ERROR: A datapump operation is currently busy in schema:' ||
         p_target_schema);
         RAISE dpp_job_var.ge_selftest_failed;
      END IF;
      --
      dpp_inj_krn.inj_drop_exp_table(p_target_schema);
      EXECUTE IMMEDIATE 'BEGIN ' || p_target_schema ||
                      '.dpump_drop_exp_table; END; ';
      dpp_inj_krn.inj_drop_drop_exp_table(p_target_schema);
      --
      dpp_inj_krn.inj_checks_for_exp(p_target_schema);
      l_check := self_test('EXPORT', p_target_schema);
      dpp_inj_krn.inj_drop_checks_for_exp(p_target_schema);
      --
      IF l_check = FALSE THEN
         trace_p('ERROR: Export selftest failed! Clean up target schema for datapump');
         RAISE dpp_job_var.ge_selftest_failed;
      END IF;
      --
      dpp_job_var.g_cpu_count := get_cpu_count;
      --
      IF dpp_job_var.g_cpu_count IS NULL THEN
         trace_p('ERROR: Could not determine the exact number of cpu''s for use by oracle');
         RAISE dpp_job_var.ge_abort_export;
      END IF;
      --
      trace_p('Purge recyclebin');
      purge_recycle_bin(p_target_schema);

      IF getvalues(p_key => 'EXEC_PREFIX', p_data => p_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:EXEC_PREFIX','EXP:EXEC_PREFIX');
         trace_p('Executing prefix scripts!');
         --      fix_scan_and_exec_sql('PREFIX', p_target_schema, NULL, 'E');
           -- Salkovsky, 08-05-2018
         fix_exec_sql('PREFIX', p_target_schema, NULL, 'E');
         trace_p('All prefix scripts executed!');
      END IF;

      DBMS_APPLICATION_INFO.SET_MODULE('EXP:CREATE JOB', 'CREATE JOB');
      trace_p('Create export job.');
      IF initiate_export(p_target_schema) IS NULL THEN
      trace_p('ERROR:Creation export job');
      RAISE dpp_job_var.ge_abort_export;
      END IF;
      trace_p('...Export job created!');
      --
      trace_p('Configure export job.');
      configure_export(p_sma_id, p_target_schema, p_options);
      --
      trace_p('Running export job.');
      DBMS_APPLICATION_INFO.SET_MODULE('EXP:JOB RUNNING', 'RUNNING');
      run_job(p_sma_name => p_target_schema, p_job_number => dpp_job_var.g_job_number);
      trace_p('DONE!, export job finished!');
      DBMS_APPLICATION_INFO.SET_MODULE('EXP:JOB FINISHED', 'FINISHED');
      --
      trace_p('Renaming OS files');
      rename_file(p_target_schema);
      trace_p('...OS files renamed.');
      --
      set_end_time;
      close_context_id('OK');
      DBMS_APPLICATION_INFO.SET_MODULE('EXP:COMPLETED', 'JOB COMPLETED');
      COMMIT;
   EXCEPTION
      WHEN dpp_job_var.ge_renaming_failed THEN
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         set_end_time;
         close_context_id('ERR');
         dpp_job_var.g_there_was_an_error := TRUE;
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:ERROR', 'RENAMING FAILED');
         COMMIT;
      WHEN dpp_job_var.ge_abort_export THEN
         l_sql_error := -1;
         l_sql_text  := 'EXPORT ABORTED, APPLICATION DEFINED EXCEPTION, GENERIC EXIT';
         log_p(l_sql_error, l_sql_text, l_action);
         set_end_time;
         close_context_id('ERR');
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:ERROR', 'GENERIC EXIT');
         dpp_job_var.g_there_was_an_error := TRUE;
         COMMIT;
      WHEN dpp_job_var.ge_injection_failed THEN
         l_sql_error := SQLCODE;
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         log_p(l_sql_error, l_sql_text, l_action);
         close_context_id('ERR');
         dpp_job_var.g_there_was_an_error := TRUE;
         trace_p('ERROR   :The '||USER||' user has no rights to create or drop objects in target schema:' ||p_target_schema);
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:ERROR', 'INJECTION FAILED');
         COMMIT;
      WHEN OTHERS THEN
         -- sink all
         l_sql_text  := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         l_sql_error := SQLCODE;
         log_p(l_sql_error, l_sql_text, l_action);
         set_end_time;
         close_context_id('ERR');
         dpp_job_var.g_there_was_an_error := TRUE;
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:ERROR', l_sql_error);
         COMMIT;
   END export_data;

   PROCEDURE export_logical_name(p_logical IN dpp_schemas.functional_name%TYPE
                                ,p_options IN VARCHAR2 DEFAULT NULL
                                ) 
   IS
      l_functional_name   dpp_schemas.functional_name%TYPE;
      l_instance_name     dpp_schemas.ite_name%TYPE;
      l_sma_id            dpp_schemas.sma_id%TYPE;
      l_sma_name          dpp_schemas.sma_name%TYPE;
      l_options           VARCHAR2(4000);
      l_distribution_list VARCHAR2(32000); 
   BEGIN
      dpp_job_var.g_dpp_dir := dpp_job_mem.get_prr('g_dpp_out_dir').prr_value;
      dpp_job_var.g_logfile := NULL;             
      dpp_job_var.g_there_was_an_error := FALSE;
      dpp_inj_krn.flush_hash_table; -- flush, to avoid "source offset is beyond the end of the source LOB" on repeated calls
      --
      l_options := TRIM(UPPER(p_options));
      IF l_options = 'NULL' THEN
         l_options := NULL;
      END IF;
      -- the logical name must exist on this database.
      l_functional_name := UPPER(TRIM(p_logical));
      --
      set_start_time;
      --
      BEGIN
         l_instance_name := SYS_CONTEXT('userenv','db_name');
      EXCEPTION
         WHEN OTHERS THEN
            trace_p('unexpected exception with SYS_CONTEXT');
            dpp_job_var.g_there_was_an_error := TRUE;
            --close_context_id('ERR');
            GOTO proc_exit;
      END;
    --
      BEGIN
         SELECT sma.sma_name
              , sma.sma_id
              , LISTAGG(rct.email_addr,';') WITHIN GROUP (ORDER BY rownum) distribution_list 
           INTO l_sma_name
              , l_sma_id
              , l_distribution_list
           FROM dpp_schemas sma
           LEFT OUTER JOIN dpp_recipients rct   
             ON rct.sma_id = sma.sma_id
          WHERE sma.functional_name = l_functional_name
            AND sma.ite_name = l_instance_name
          GROUP BY sma.sma_name
              , sma.sma_id 
         ;
      EXCEPTION
         WHEN OTHERS THEN
            trace_p(DBMS_UTILITY.format_error_stack ||'-' ||DBMS_UTILITY.format_error_backtrace);
            trace_p('No functional name:' || l_functional_name ||' found with instance:' || l_instance_name);
            dpp_job_var.g_there_was_an_error := TRUE;
            --close_context_id('ERR');
            GOTO proc_exit;
      END;      
      dpp_job_var.g_context := generate_context_id('EXPORT',l_sma_id);
      --
      IF dpp_job_var.g_context IS NULL THEN
         -- could not create logging context , abort immediatly
         RETURN; -- abort
      END IF;
    --
      IF l_options IS NULL THEN
         SELECT LISTAGG(stn.otn_name||'='||stn.stn_value,'#') WITHIN GROUP (ORDER BY rownum)
           INTO l_options
           FROM dpp_schema_options stn
          INNER JOIN dpp_schemas sma
             ON sma.sma_id = stn.sma_id
            AND sma.functional_name = l_functional_name
          WHERE stn.stn_usage = 'E';
      END IF;


      IF getvalues(p_key => 'BLOCK', p_data => l_options) = 'YES' THEN
         trace_p('Blocking the export due to BLOCK=YES');
         dpp_job_var.g_there_was_an_error := TRUE;
         set_end_time;
         close_context_id('ERR');
         GOTO proc_exit;
      END IF;

      -- now we have logical name so we export
      export_data(p_sma_id=>l_sma_id, p_target_schema => l_sma_name, p_options => l_options);
      <<proc_exit>>
      IF getvalues(p_key => 'EMAIL_RESULT', p_data => l_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('EXP:EMAIL', 'EMAIL RESULT');
         --email_pmp_session('EXPORT',l_trg_logical,NULL,CASE g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END);
         -- future implementation
         email_pmp_session('EXPORT'
                          ,l_functional_name
                          ,NULL
                          ,l_sma_name
                          ,NULL
                          ,l_instance_name
                          ,NULL
                          ,l_distribution_list
                          ,CASE dpp_job_var.g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END
                          );
      END IF;
      --
      IF dpp_job_var.g_there_was_an_error = FALSE THEN
      -- dont overwrite result if there is an error
      DBMS_APPLICATION_INFO.SET_MODULE('IMP:EXECUTE EXPORT','COMPLETED');
      END IF;
      COMMIT;
   END export_logical_name;

   FUNCTION export_logical_name(p_logical IN dpp_schemas.functional_name%TYPE
                                ,p_options IN VARCHAR2 DEFAULT NULL
                                )
   RETURN dpp_job_runs.status%TYPE
   IS
   BEGIN
      export_logical_name(p_logical, p_options);
      RETURN get_job_run_status;
   END export_logical_name;
   
   --
   PROCEDURE import_logical_name(p_src_logical IN dpp_schemas.functional_name%TYPE
                                ,p_trg_logical IN dpp_schemas.functional_name%TYPE
                                ,p_options     IN VARCHAR2 DEFAULT NULL
                                ) 
   IS
      l_src_logical         dpp_schemas.functional_name%TYPE;
      l_cnt                 NUMBER;
      l_trg_logical         dpp_schemas.functional_name%TYPE;
      l_src_actual          VARCHAR2(100);
      l_trg_actual          VARCHAR2(100);
      l_date                CHAR(8);
      l_logical_name        dpp_schemas.functional_name%TYPE;
      l_options             VARCHAR2(1000);
      l_user_c_info         VARCHAR2(64);
      l_osuser              VARCHAR2(100);
      l_ipaddr              VARCHAR2(100);
      l_src_instance_name   dpp_schemas.ite_name%TYPE; 
      l_trg_instance_name   dpp_schemas.ite_name%TYPE; 
      l_sma_production_flag dpp_schemas.production_flag%TYPE; 
      l_ite_production_flag dpp_instances.production_flag%TYPE;
      l_distribution_list   VARCHAR2(32000); 
      l_sma_id              dpp_schemas.sma_id%TYPE;
      l_src_sma_name        dpp_schemas.sma_name%TYPE;

   BEGIN
      l_osuser             := SYS_CONTEXT('USERENV', 'OS_USER');
      l_ipaddr             := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
      l_user_c_info        := l_osuser || '[' || l_ipaddr || ']';
      dpp_job_var.g_there_was_an_error := FALSE;
      dpp_job_var.g_logfile            := NULL;
      dpp_inj_krn.flush_hash_table; -- flush, to avoid "source offset is beyond the end of the source LOB" on repeated calls
      DBMS_SESSION.set_identifier(l_user_c_info);
      l_options := TRIM(UPPER(p_options));

      IF l_options = 'NULL' THEN
         l_options := NULL;
      END IF;

      l_src_logical := TRIM(UPPER(p_src_logical));
      l_trg_logical := TRIM(UPPER(p_trg_logical));

     -- target must exist on this instance
      BEGIN
         SELECT sma.sma_name
              , UPPER(SYS_CONTEXT('userenv','db_name'))
              , sma.sma_id
              , LISTAGG(rct.email_addr,';') WITHIN GROUP (ORDER BY rownum) distribution_list 
           INTO l_trg_actual
              , l_trg_instance_name
              , l_sma_id
              , l_distribution_list
           FROM dpp_schemas sma
           LEFT OUTER JOIN dpp_recipients rct   
             ON rct.sma_id = sma.sma_id
          WHERE sma.functional_name = l_trg_logical
            AND sma.ite_name = UPPER(SYS_CONTEXT('userenv','db_name'))
          GROUP BY sma.sma_name
              , UPPER(SYS_CONTEXT('userenv','db_name'))
              , sma.sma_id 
              ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            trace_p('TARGET SCHEMA IS NOT MAPPED[' ||l_trg_logical || ']');
            RETURN; -- abort
      END;      
      set_start_time;
      dpp_job_var.g_context := generate_context_id('IMPORT',l_sma_id);
      --
      IF dpp_job_var.g_context IS NULL THEN
         -- could not create logging context , abort immediatly
         RETURN; -- abort
      END IF;

      IF l_src_logical IS NULL OR l_trg_logical IS NULL THEN
         RETURN;
      END IF;

      IF l_options IS NULL THEN
         SELECT LISTAGG(stn.otn_name||'='||stn.stn_value,'#') WITHIN GROUP (ORDER BY rownum)
           INTO l_options
           FROM dpp_schema_options stn
          INNER JOIN dpp_schemas sma
             ON sma.sma_id = stn.sma_id
            AND sma.functional_name = l_trg_logical
          WHERE stn.stn_usage = 'I';
      END IF;
      -- strip date from source schema if applicable
      --l_logical_name := REGEXP_SUBSTR(l_src_logical, '^[^0-9]{1,}'); -- doesn't work for UTV3
      l_date         := REGEXP_SUBSTR(l_src_logical, '[0-9]{8}$');      
      l_logical_name := REPLACE (l_src_logical, l_date);


      -- source must exist somewhere on a database
      BEGIN
         SELECT sma.sma_name
              , sma.ite_name
              , NVL(sma.production_flag, 'N') sma_production_flag
              , NVL(ite.production_flag, 'N') ite_production_flag
           INTO l_src_actual
              , l_src_instance_name
              , l_sma_production_flag
              , l_ite_production_flag
           FROM dpp_schemas sma
          INNER JOIN dpp_instances ite 
             ON ite.ite_name = sma.ite_name
          WHERE sma.functional_name = l_logical_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            trace_p('SOURCE SCHEMA IS NOT MAPPED[' ||l_src_actual || '] for logical = '|| l_logical_name);
            RETURN; -- abort
      END;

      -- OK here we check if we are in production, "PROD",
      -- IF we are then we abort immediately
      IF (l_ite_production_flag = 'Y'
          AND
          l_sma_production_flag = 'Y'
         )
      OR l_trg_instance_name IS NULL 
      THEN
         RAISE dpp_job_var.ge_abort_import;
      END IF;
     --
      IF l_date IS NULL THEN
        l_date := TO_CHAR(SYSDATE, 'YYYYMMDD');
      END IF;
      --
      l_src_sma_name := l_src_actual;
      l_src_actual := l_src_actual || l_date;
      --
      -- IS THERE AN IMPORT BLOCK
      --
      IF getvalues(p_key => 'BLOCK', p_data => l_options) = 'YES' THEN
         trace_p('Blocking the import due to BLOCK=YES');
         dpp_job_var.g_there_was_an_error := TRUE;
         set_end_time;
         close_context_id('ERR');
         goto proc_exit;          
      END IF;

      trace_p('Lock target schema '||l_trg_actual||' when specified');
      IF getvalues(p_key => 'LOCK_SCHEMA', p_data => l_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:LOCK SCHEMA:' || l_trg_actual
                                         ,'IMP:LOCK SCHEMA:' || l_trg_actual
                                         );
         /*dc_dba_mgmt_lock_account(p_schema      => l_trg_actual
                                 ,p_lock        => 1
                                 ,p_debug_trace => 0
                                 );
                                 */
         lock_kill_unlock(p_schema   => l_trg_actual
                         ,p_lock => TRUE
                         ); 
         -- sleep for 15 sec so v$access gets a good update
         DBMS_LOCK.sleep(seconds => 15);                              
      END IF;

      -- Kill sessions of gateway users and lock them
      trace_p(' Kill sessions of gateway users and lock them');
      FOR r_smadep IN (SELECT smadep.functional_name
                            , smadep.sma_name
                         FROM dpp_schemas sma
                        INNER JOIN dpp_schema_relations srn
                           ON sma.sma_id = srn.sma_id_from
                        INNER JOIN dpp_schemas smadep
                           ON smadep.sma_id = srn.sma_id_to    
                          AND smadep.ste_name != 'MAIN'
                        WHERE sma.sma_id = l_sma_id
                      )
      LOOP
         trace_p('Locking gateway user '||r_smadep.sma_name) ;
         BEGIN
            /*dc_dba_mgmt_lock_account(p_schema=> r_smadep.sma_name 
                                    ,p_lock=> 1
                                    ,p_debug_trace => 0
                                    );
                                    */                
            lock_kill_unlock(p_schema   => r_smadep.sma_name 
                            ,p_lock => TRUE
                            ); 
         EXCEPTION
            WHEN OTHERS THEN
               NULL; -- just for testing / must go further
         END;
      END LOOP;                
      trace_p('Import data') ;
      import_data(p_source_schema => l_src_actual
                 ,p_target_schema => l_trg_actual
                 ,p_target_sma_id=>l_sma_id 
                 ,p_options=> l_options
                 );
      -- this day is the context
      trace_p('Unlock target schema '||l_trg_actual||' when specified');
      IF getvalues(p_key => 'LOCK_SCHEMA', p_data => l_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:UNLOCK SCHEMA:' || l_trg_actual
                                         ,'IMP:UNLOCK SCHEMA:' || l_trg_actual
                                         );
      --
         /*dc_dba_mgmt_lock_account(p_schema=> l_trg_actual
                                 ,p_lock=> 0
                                 ,p_debug_trace => 0
                                 );
                                 */
         lock_kill_unlock(p_schema   => l_trg_actual 
                         ,p_lock => FALSE
                         ); 
      --
         l_cnt := 1;
         SELECT SUM(CASE account_status
                    WHEN 'OPEN' THEN
                       1
                    ELSE
                       0
                     END
                    )
           INTO l_cnt
           FROM dba_users
          WHERE username = l_trg_actual;
         IF l_cnt = 0 THEN
            log_p(-1,'unlocking account ' || l_trg_actual || ' failed!','unlocking account');
         END IF;
      END IF;        
      -- Unlock gateway users
      trace_p(' Unlock gateway users');
      FOR r_smadep IN (SELECT smadep.functional_name
                            , smadep.sma_name
                         FROM dpp_schemas sma
                        /*INNER JOIN dpp_schemas smadep
                           ON sma.sma_id = smadep.sma_id_linked
                        WHERE sma.sma_id = l_sma_id 
                          AND smadep.ste_name != 'MAIN'*/
                        INNER JOIN dpp_schema_relations srn
                           ON sma.sma_id = srn.sma_id_from
                        INNER JOIN dpp_schemas smadep
                           ON smadep.sma_id = srn.sma_id_to    
                          AND smadep.ste_name != 'MAIN'
                        WHERE sma.sma_id = l_sma_id                          

                      )
      LOOP
         trace_p('Unlocking gateway user '||r_smadep.sma_name);
         BEGIN
          --  dc_dba_mgmt_lock_account(p_schema=> r_smadep.sma_name,p_lock=> 0,p_debug_trace => 0);               
            lock_kill_unlock(p_schema   => r_smadep.sma_name 
                            ,p_lock => FALSE
                            );  
         EXCEPTION
            WHEN OTHERS THEN
               NULL; -- just for testing
         END;
      END LOOP;   

      <<proc_exit>>
      IF getvalues(p_key => 'EMAIL_RESULT', p_data => l_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('IMP:EMAIL RESULT','IMP:EMAIL RESULT');
         email_pmp_session('IMPORT'
                           ,l_logical_name
                           ,l_trg_logical
                           ,l_src_sma_name
                           ,l_trg_actual
                           ,l_src_instance_name
                           ,l_trg_instance_name
                           ,l_distribution_list
                           ,CASE dpp_job_var.g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END
                           );
      END IF;
      COMMIT;
   END import_logical_name;

   FUNCTION import_logical_name(p_src_logical IN dpp_schemas.functional_name%TYPE
                                ,p_trg_logical IN dpp_schemas.functional_name%TYPE
                                ,p_options     IN VARCHAR2 DEFAULT NULL -- put here NETWORK_LINK for direct
                                )
   RETURN dpp_job_runs.status%TYPE
   IS
   BEGIN
      import_logical_name(p_src_logical, p_trg_logical, p_options);
      RETURN get_job_run_status;
   END import_logical_name;

   PROCEDURE remove_files_old_logical(p_src_logical IN VARCHAR2
                                     ,p_date        IN DATE
                                     )
   IS
      l_src_actual   dpp_schemas.sma_name%type;
      l_logical_name VARCHAR2(100);
   BEGIN
      l_logical_name := UPPER(TRIM(p_src_logical));        
      BEGIN
         SELECT MAX(sma.sma_name)
           INTO l_src_actual
           FROM dpp_schemas sma
          WHERE sma.functional_name = l_logical_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN; -- abort
      END;
      remove_files_older(p_sma_name=> l_src_actual
                        ,p_date=> TRUNC(p_date)
                        );
   END;

   FUNCTION first_execution_time(p_date IN DATE) 
   RETURN DATE 
   IS
      l_schedule     DATE;
      l_totalseconds NUMBER;
   BEGIN
      IF p_date IS NULL THEN
         RETURN NULL;
      END IF;
      l_totalseconds := TO_CHAR(p_date, 'HH24') * 3600 +
      TO_CHAR(p_date, 'MI') * 60;
      l_schedule := TRUNC(SYSDATE) + l_totalseconds / 86400;
      IF SYSDATE > l_schedule then
         -- schedule for next day
         l_schedule := l_schedule + 1;
      END IF;
      RETURN l_schedule;
   END;

   PROCEDURE transfer_dumpfiles(p_schema IN VARCHAR2, p_db_link IN VARCHAR2) 
   IS
      l_src_logical         VARCHAR2(100);
      l_logical_name        VARCHAR2(100);
      l_src_actual          VARCHAR2(100);
      l_import_files        dpp_job_var.gt_import_files_type;
      l_file                VARCHAR2(250);
      l_date                VARCHAR2(10);
      l_instance_name       dpp_schemas.ite_name%TYPE;
      l_sma_id              dpp_schemas.sma_id%TYPE;
      l_sma_name            dpp_schemas.sma_name%TYPE;
      l_sma_production_flag dpp_schemas.production_flag%TYPE; 
      l_ite_production_flag dpp_instances.production_flag%TYPE;
      l_options             VARCHAR2(4000);
      l_line                VARCHAR2(1000);
      l_sql_text            VARCHAR2(4000);
      l_sql_error           NUMBER;
      l_action              VARCHAR2(25) := 'transfer_file';
      l_distribution_list   VARCHAR2(32000); 
   BEGIN
      set_start_time;
      l_instance_name := SYS_CONTEXT('userenv','db_name'); 
      l_src_logical := TRIM(UPPER(p_schema));
      IF l_src_logical IS NULL THEN
         RAISE_APPLICATION_ERROR(dpp_job_var.gk_pmp_errno,'parameter p_schema is NULL',TRUE);
      END IF;
      --
      l_date         := REGEXP_SUBSTR(l_src_logical, '[0-9]{8}$');
      l_logical_name := REPLACE(l_src_logical, l_date);

      --
      IF l_date IS NULL THEN
         l_date := TO_CHAR(SYSDATE, 'YYYYMMDD');
      END IF;
      --
      -- source must exist somewhere on a database
      BEGIN
         SELECT sma.sma_name
              , NVL(sma.production_flag, 'N') sma_production_flag
              , NVL(ite.production_flag, 'N') ite_production_flag
              , LISTAGG(rct.email_addr,';') WITHIN GROUP (ORDER BY rownum) distribution_list
              , sma.sma_id 
           INTO l_sma_name
              , l_sma_production_flag
              , l_ite_production_flag
              , l_distribution_list
              , l_sma_id
           FROM dpp_schemas sma
          INNER JOIN dpp_instances ite 
             ON ite.ite_name = sma.ite_name
           LEFT OUTER JOIN dpp_recipients rct   
             ON rct.sma_id = sma.sma_id
          WHERE sma.functional_name = l_logical_name
            AND sma.ite_name =l_instance_name
          GROUP BY sma.sma_name
              , NVL(sma.production_flag, 'N')
              , NVL(ite.production_flag, 'N')
              , sma.sma_id
          ;
         --IF l_ite_production_flag != 'Y' THEN  
         --   RAISE_APPLICATION_ERROR(dpp_job_var.gk_pmp_errno,'Only the production environment is allowed to use transfer!',TRUE);
         --END IF;  
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            trace_p('SCHEMA IS UNKOWN IN TABLE dpp_schemas [' ||
            l_logical_name || ']');
            RAISE; -- abort
      END;
      dpp_job_var.g_context := generate_context_id('TRANSFER',l_sma_id);
      --
      IF dpp_job_var.g_context IS NULL
      THEN
         -- could not create logging context , abort immediatly
         RETURN;                                                      -- abort
      END IF;

      SELECT LISTAGG(stn.otn_name||'='||stn.stn_value,'#') WITHIN GROUP (ORDER BY rownum)
           INTO l_options
           FROM dpp_schema_options stn
          INNER JOIN dpp_schemas sma
             ON sma.sma_id = stn.sma_id
            AND sma.functional_name = l_logical_name
          WHERE stn.stn_usage = 'T';      --

      l_src_actual := l_sma_name || l_Date;
      --
      dpp_job_var.g_dpp_dir := dpp_job_mem.get_prr('g_dpp_out_dir').prr_value;
      l_import_files := dpp_job_krn.find_files(l_src_actual, 1);
      --
      IF l_import_files.FIRST IS NULL THEN
         trace_p('NO FILES FOUND FOR ' || l_src_actual);
         RAISE_APPLICATION_ERROR(-20000,'NO FILES FOUND FOR ' || l_src_actual);
      END IF;
      --
      FOR i IN l_import_files.FIRST .. l_import_files.LAST LOOP
         l_file := l_import_files(i);
         trace_p('COPYING ' || l_file);
         l_line := 'DECLARE l_rc VARCHAR2(150); '
                || 'BEGIN '
                || 'l_rc := dpp_job_krn.remove_dmp_file@'||p_db_link||/*DPP_TRANSFER.CC.CEC.EU.INT*/'('''||l_file||''',dpp_job_mem.get_prr(''g_dpp_in_dir'').prr_value); '
                || 'EXCEPTION'
                || '   WHEN OTHERS THEN NULL;'
                || 'END;';
         trace_p(l_line);
         EXECUTE IMMEDIATE l_line;
         l_line := 'BEGIN DBMS_FILE_TRANSFER.put_file('''||dpp_job_mem.get_prr('g_dpp_out_dir').prr_value||''','''
                || l_file||''','''||dpp_job_mem.get_prr('g_dpp_in_dir').prr_value||''','''||l_file||''','''||p_db_link/*DPP_TRANSFER.CC.CEC.EU.INT*/||'''); END;';
         trace_p(l_line);
         EXECUTE IMMEDIATE l_line;
         trace_p(l_file || ' copied');
       END LOOP;
       trace_p('TRANSFER FINISHED');
       set_end_time;
       close_context_id ('OK');    
       dpp_job_var.g_there_was_an_error := FALSE;
      IF getvalues(p_key => 'EMAIL_RESULT', p_data => l_options) = 'YES' THEN
         DBMS_APPLICATION_INFO.SET_MODULE('TRF:EMAIL', 'EMAIL RESULT');
         --email_pmp_session('EXPORT',l_trg_logical,NULL,CASE g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END);
         -- future implementation

         email_pmp_session(p_action=>'TRANSFER'
                          ,p_src=>NULL
                          ,p_trg=>NULL
                          ,p_src_schema=>l_sma_name
                          ,p_trg_schema=>NULL
                          ,p_src_inst=>l_instance_name
                          ,p_trg_inst=>NULL
                          ,p_distribution_list=>l_distribution_list
                          ,p_error=>CASE dpp_job_var.g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END
                          );



     END IF;
     COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         l_sql_error := SQLCODE;
         l_sql_text :=
               DBMS_UTILITY.format_error_stack
            || DBMS_UTILITY.format_error_backtrace;
         l_sql_text :=
               l_sql_text
            || ' FILE TRANSFER ABORTED, APPLICATION DEFINED EXCEPTION, GENERIC EXIT';
         log_p (l_sql_error, l_sql_text, l_action);
         set_end_time;
         close_context_id ('ERR');
         dpp_job_var.g_there_was_an_error := TRUE;   
         IF getvalues(p_key => 'EMAIL_RESULT', p_data => l_options) = 'YES' THEN
            DBMS_APPLICATION_INFO.SET_MODULE('TRF:EMAIL', 'EMAIL RESULT');
            email_pmp_session(p_action=>'TRANSFER'
                             ,p_src=>NULL
                             ,p_trg=>NULL
                             ,p_src_schema=>l_sma_name
                             ,p_trg_schema=>NULL
                             ,p_src_inst=>l_instance_name
                             ,p_trg_inst=>NULL
                             ,p_distribution_list=>l_distribution_list
                             ,p_error=>CASE dpp_job_var.g_there_was_an_error WHEN TRUE THEN 2 ELSE 0 END
                             );
         END IF;
         COMMIT;
         RAISE;      
   END transfer_dumpfiles;

   FUNCTION transfer_dumpfiles(p_schema IN VARCHAR2, p_db_link IN VARCHAR2) 
   RETURN dpp_job_runs.status%TYPE
   IS
   BEGIN
      transfer_dumpfiles(p_schema, p_db_link);
      RETURN get_job_run_status;
   END transfer_dumpfiles;

BEGIN
   -- Initialization
   dpp_job_var.g_there_was_an_error := FALSE;
END dpp_job_krn;
/

