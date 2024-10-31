CREATE OR REPLACE PACKAGE BODY DPP_MONITORING_KRN IS
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

   /**
   * DPP_Utility timeout monitoring package.
   *
   * v1.00; 2024-04-08; malmjea; initial version
   */
   
   /**
   * Show a debug message.
   *
   * @param p_msg: message to be shown
   */
   PROCEDURE show_debug(p_msg VARCHAR2) IS
   BEGIN
      IF dpp_monitoring_var.g_debug_mode AND p_msg IS NOT NULL THEN
         DBMS_OUTPUT.PUT_LINE(
            '['
         || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SSFF3')
         || ']'
         || p_msg
         );
      END IF;
   END show_debug;
   
   /**
   * Raise application error.
   *
   * @param p_code: error code
   * @param p_message: error message
   */
   PROCEDURE raise_error(
        p_code       IN SIMPLE_INTEGER
      , p_message    IN VARCHAR2
   ) IS
   BEGIN
      RAISE_APPLICATION_ERROR(p_code, NVL(p_message, '/'));
   END raise_error;
   
   /**
   * Send timeout mail.
   *
   * @param p_jrn_id: job run identifier
   * @param p_jte_cd: batch code
   * @param p_sma_id: schema identifier
   * @param p_sma_name: schema name
   * @param p_env_name: environment name
   * @param p_ite_name: instance name
   * @param p_status: job run status
   * @param p_date_started: job run start date
   * @throws -20000: invalid job run ID
   * @throws -20001: invalid schema ID
   * @throws -20002: invalid job run status
   * @throws -20003: invalid start date
   * @throws -20004: mail recipients not found
   * @throws -20007: invalid job type
   * @throws -20009: invalid schema name
   * @throws -20010: invalid environment name
   */
   PROCEDURE send_timeout_mail(
      p_jrn_id       IN dpp_job_runs.jrn_id%TYPE
    , p_jte_cd       IN dpp_job_runs.jte_cd%TYPE
    , p_sma_id       IN dpp_job_runs.sma_id%TYPE
    , p_sma_name     IN dpp_schemas.sma_name%TYPE
    , p_env_name     IN dpp_instances.env_name%TYPE
    , p_ite_name     IN dpp_schemas.ite_name%TYPE
    , p_status       IN dpp_job_runs.status%TYPE
    , p_date_started IN dpp_job_runs.date_started%TYPE
   ) IS

      -- email recipients
      email_recipients        VARCHAR2(32000);

      -- email subject
      email_subject           VARCHAR2(1000);

      -- email message
      email_msg               CLOB;

   BEGIN
   
      -- Check parameters.
      IF p_jrn_id IS NULL THEN
         raise_error(-20000, 'invalid job run identifier');
      END IF;
      IF p_sma_id IS NULL THEN
         raise_error(-20001, 'invalid schema identifier');
      END IF;
      IF p_status IS NULL THEN
         raise_error(-20002, 'invalid job run status');
      END IF;
      IF p_date_started IS NULL THEN
         raise_error(-20003, 'invalid job start date');
      END IF;
      IF p_jte_cd IS NULL THEN
         raise_error(-20007, 'invalid job type');
      END IF;
      IF p_ite_name IS NULL THEN
         raise_error(-20008, 'invalid instance name');
      END IF;
      IF p_sma_name IS NULL THEN
         raise_error(-20009, 'invalid schema name');
      END IF;
      IF p_env_name IS NULL THEN
         raise_error(-20010, 'invalid environment name');
      END IF;

      -- DEBUG
      show_debug(
         'Sending timeout mail: '
      || 'jrn_id=' || p_jrn_id
      || ',jte_cd=' || p_jte_cd
      || ',sma_id=' || TO_CHAR(p_sma_id)
      || ',sma_name=' || p_sma_name
      || ',env_name=' || p_env_name
      || ',ite_name=' || p_ite_name
      || ',status=' || p_status
      || ',date_started='
      || NVL(TO_CHAR(p_date_started, 'YYYY-MM-DD HH24:MI:SS'), '/')
      );
      
      -- Initialize the SMTP server.
      dpp_job_krn.init_smtp(p_ite_name);
   
      -- Load the mail recipients.
      <<load_recipients>>
      BEGIN
         SELECT LISTAGG(email_addr,';') WITHIN GROUP (ORDER BY rownum)
           INTO email_recipients
           FROM dpp_recipients
          WHERE sma_id = p_sma_id;
         IF email_recipients IS NULL THEN
            -- DEBUG
            show_debug('Sending timeout mail error: no mail recipients');
            raise_error(-20004, 'mail recipients not found');
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- DEBUG
            show_debug('Sending timeout mail error: no mail recipients');
            raise_error(-20004, 'mail recipients not found');
      END load_recipients;

      -- Build the email.
      email_subject := dpp_monitoring_var.gk_mailsubj_timeout;
      email_subject := REPLACE(email_subject, '[jte_cd]', p_jte_cd);
      email_subject := REPLACE(email_subject, '[env_name]', p_env_name);
      email_subject := REPLACE(email_subject, '[sma_name]', p_sma_name);
      email_subject := REPLACE(email_subject, '[ite_name]', p_ite_name);
      email_msg := dpp_monitoring_var.gk_mailmsg_timeout;
      email_msg := REPLACE(email_msg, '[jrn_id]', p_jrn_id);
      email_msg := REPLACE(email_msg, '[jte_cd]', p_jte_cd);
      email_msg := REPLACE(email_msg, '[env_name]', p_env_name);
      email_msg := REPLACE(email_msg, '[sma_name]', p_sma_name);
      email_msg := REPLACE(email_msg, '[ite_name]', p_ite_name);
      email_msg := REPLACE(email_msg, '[status]', p_status);
      email_msg := REPLACE(email_msg
                        , '[date_started]'
                        , TO_CHAR(p_date_started, 'YYYY-MM-DD HH24:MI:SS')
                   );

      -- DEBUG
      show_debug(
         'Sending timeout mail: '
      || 'recipients=' || email_recipients
      || ',subject=' || email_subject
      || ',message=' || email_msg
      );

      -- Send the mail.
      <<send_mail>>
      BEGIN
         IF dpp_job_var.g_smtp_dev_recipient IS NOT NULL THEN
            mail_utility_krn.set_developer_recipient(
               dpp_job_var.g_smtp_dev_recipient
            );
         END IF;
         mail_utility_krn.send_mail_over32k(
            p_sender                      => NVL(dpp_job_var.g_smtp_sender
                                               , dpp_job_var.gk_default_sender)
          , p_recipients                  => email_recipients
          , p_subject                     => email_subject
          , p_message                     => email_msg
          , p_force_send_on_non_prod_env  => TRUE
         );
      EXCEPTION
         WHEN OTHERS THEN
            -- DEBUG
            show_debug('Sending timeout mail: ' || NVL(SQLERRM, '/'));
            raise_error(
               -20005
             , 'mail sending failure ('
             || NVL(SQLERRM, '/')
             || ')'
            );
      END send_mail;
      
   END send_timeout_mail;
   
   /**
   * Update the status of the job run.
   *
   * @param p_jrn_id: job run identifier
   * @param p_jte_cd: batch code
   * @param p_sma_id: schema identifier
   * @throws -20000: invalid job run ID
   * @throws -20001: invalid schema ID
   * @throws -20006: job run status update failure
   * @throws -20007: invalid job type
   */
   PROCEDURE update_status(
      p_jrn_id       IN dpp_job_runs.jrn_id%TYPE
    , p_jte_cd       IN dpp_job_runs.jte_cd%TYPE
    , p_sma_id       IN dpp_job_runs.sma_id%TYPE
   ) IS

      -- log line
      log_line    dpp_job_logs.line%TYPE;

   BEGIN
   
      -- Check parameters.
      IF p_jrn_id IS NULL THEN
         raise_error(-20000, 'invalid job run identifier');
      END IF;
      IF p_sma_id IS NULL THEN
         raise_error(-20001, 'invalid schema identifier');
      END IF;
      IF p_jte_cd IS NULL THEN
         raise_error(-20007, 'invalid job type');
      END IF;

      -- DEBUG
      show_debug(
         'Updating job status: '
      || 'jrn_id=' || p_jrn_id
      || ',jte_cd=' || p_jte_cd
      || ',sma_id=' || TO_CHAR(p_sma_id)
      );
      
      -- Update status.
      <<update_status>>
      BEGIN
      
         -- Update the status of the job run.
         UPDATE dpp_job_runs
            SET status     = dpp_monitoring_var.gk_job_status_error
            , date_ended = SYSDATE
            , date_modif = SYSDATE
            , user_modif = USER
         WHERE jrn_id = p_jrn_id
           AND jte_cd = p_jte_cd
           AND sma_id = p_sma_id;
         IF SQL%ROWCOUNT != 1 THEN
            -- DEBUG
            show_debug('Updating job status error: no job run updated');
            raise_error(-20006, 'The job run status could not be updated.');
         END IF;

         -- Compute the log line.
         <<compute_log_line>>
         BEGIN
            SELECT MAX(line) + 1
              INTO log_line
              FROM dpp_job_logs
             WHERE jrn_id = p_jrn_id
               AND jte_cd = p_jte_cd;
            IF log_line IS NULL THEN
               log_line := 1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               log_line := 1;
         END compute_log_line;
         
         -- DEBUG
         show_debug(
            'Inserting log line: '
         || 'jrn_id=' || p_jrn_id
         || ',jte_cd=' || p_jte_cd
         || ',line=' || TO_CHAR(log_line)
         || ',text='
         || '['
         || TO_CHAR(SYSDATE, 'DD/MM HH24:MI:SS')
         || '] '
         || dpp_monitoring_var.gk_logtxt_timeout
         );

         -- Insert the log line.
         INSERT INTO dpp_job_logs (
            jrn_id
          , jte_cd
          , line
          , text
         )
         VALUES (
            p_jrn_id
          , p_jte_cd
          , log_line
          ,    '['
            || TO_CHAR(SYSDATE, 'DD/MM HH24:MI:SS')
            || '] '
            || dpp_monitoring_var.gk_logtxt_timeout
         );

         -- Commit the transaction.
         COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
            -- DEBUG
            show_debug('Updating job status error: ' || NVL(SQLERRM, '/'));
            ROLLBACK;
            RAISE;
      END update_status;
      
   END update_status;
   
   /**
   * Report a timeout.
   *
   * @param p_jrn_id: job run identifier
   * @param p_jte_cd: batch code
   * @param p_sma_id: schema identifier
   * @param p_sma_name: schema name
   * @param p_env_name: environment name
   * @param p_ite_name: instance name
   * @param p_status: job run status
   * @param p_date_started: job run start date
   * @throws -20000: invalid job run ID
   * @throws -20001: invalid schema ID
   * @throws -20002: invalid job run status
   * @throws -20003: invalid start date
   * @throws -20004: mail recipients not found
   * @throws -20007: invalid job type
   * @throws -20009: invalid schema name
   * @throws -20010: invalid environment name
   */
   PROCEDURE report_timeout(
      p_jrn_id       IN dpp_job_runs.jrn_id%TYPE
    , p_jte_cd       IN dpp_job_runs.jte_cd%TYPE
    , p_sma_id       IN dpp_job_runs.sma_id%TYPE
    , p_sma_name     IN dpp_schemas.sma_name%TYPE
    , p_env_name     IN dpp_instances.env_name%TYPE
    , p_ite_name     IN dpp_schemas.ite_name%TYPE
    , p_status       IN dpp_job_runs.status%TYPE
    , p_date_started IN dpp_job_runs.date_started%TYPE
   ) IS
   BEGIN
   
      -- Check parameters.
      IF p_jrn_id IS NULL THEN
         raise_error(-20000, 'invalid job run identifier');
      END IF;
      IF p_sma_id IS NULL THEN
         raise_error(-20001, 'invalid schema identifier');
      END IF;
      IF p_status IS NULL THEN
         raise_error(-20002, 'invalid job run status');
      END IF;
      IF p_date_started IS NULL THEN
         raise_error(-20003, 'invalid job start date');
      END IF;
      IF p_jte_cd IS NULL THEN
         raise_error(-20007, 'invalid job type');
      END IF;
      IF p_ite_name IS NULL THEN
         raise_error(-20008, 'invalid instance name');
      END IF;
      IF p_sma_name IS NULL THEN
         raise_error(-20009, 'invalid schema name');
      END IF;
      IF p_env_name IS NULL THEN
         raise_error(-20010, 'invalid environment name');
      END IF;

      -- DEBUG
      show_debug(
         'Reporting timeout: '
      || 'jrn_id=' || p_jrn_id
      || ',jte_cd=' || p_jte_cd
      || ',sma_id=' || TO_CHAR(p_sma_id)
      || ',sma_name=' || p_sma_name
      || ',env_name=' || p_env_name
      || ',ite_name=' || p_ite_name
      || ',status=' || p_status
      || ',date_started='
      || NVL(TO_CHAR(p_date_started, 'YYYY-MM-DD HH24:MI:SS'), '/')
      );
      
      -- Send timeout mail.
      <<send_mail>>
      BEGIN
         send_timeout_mail(
            p_jrn_id       => p_jrn_id
          , p_jte_cd       => p_jte_cd
          , p_sma_id       => p_sma_id
          , p_sma_name     => p_sma_name
          , p_env_name     => p_env_name
          , p_ite_name     => p_ite_name
          , p_status       => p_status
          , p_date_started => p_date_started
         );
      EXCEPTION
         WHEN OTHERS THEN
            -- Treatment must go on even if the mail could not be sent.
            NULL;
      END send_mail;

      -- Update the job run status.
      <<update_run_status>>
      BEGIN
         update_status(
            p_jrn_id       => p_jrn_id
          , p_jte_cd       => p_jte_cd
          , p_sma_id       => p_sma_id
         );
      EXCEPTION
         WHEN OTHERS THEN
            -- Treatment must go on event if the status could not be uodated.
            NULL;
      END update_run_status;

   END report_timeout;
   
   /**
   * Treat a single job.
   *
   * @param p_jrn_id: job run identifier
   * @param p_jte_cd: batch code
   * @param p_sma_id: schema identifier
   * @param p_sma_name: schema name
   * @param p_env_name: environment name
   * @param p_ite_name: instance name
   * @param p_status: job run status
   * @param p_date_started: job run start date
   * @throws -20000: invalid job run ID
   * @throws -20001: invalid schema ID
   * @throws -20002: invalid job run status
   * @throws -20003: invalid start date
   * @throws -20004: mail recipients not found
   * @throws -20007: invalid job type
   * @throws -20009: invalid schema name
   * @throws -20010: invalid environment name
   */
   PROCEDURE treat_job(
      p_jrn_id       IN dpp_job_runs.jrn_id%TYPE
    , p_jte_cd       IN dpp_job_runs.jte_cd%TYPE
    , p_sma_id       IN dpp_job_runs.sma_id%TYPE
    , p_sma_name     IN dpp_schemas.sma_name%TYPE
    , p_env_name     IN dpp_instances.env_name%TYPE
    , p_ite_name     IN dpp_schemas.ite_name%TYPE
    , p_status       IN dpp_job_runs.status%TYPE
    , p_date_started IN dpp_job_runs.date_started%TYPE
   ) IS
   
      -- timeout delay
      to_delay          SIMPLE_INTEGER := dpp_monitoring_var.gk_default_delay;
      
   BEGIN
   
      -- Check parameters.
      IF p_jrn_id IS NULL THEN
         raise_error(-20000, 'invalid job run identifier');
      END IF;
      IF p_sma_id IS NULL THEN
         raise_error(-20001, 'invalid schema identifier');
      END IF;
      IF p_status IS NULL THEN
         raise_error(-20002, 'invalid job run status');
      END IF;
      IF p_date_started IS NULL THEN
         raise_error(-20003, 'invalid job start date');
      END IF;
      IF p_jte_cd IS NULL THEN
         raise_error(-20007, 'invalid job type');
      END IF;
      IF p_ite_name IS NULL THEN
         raise_error(-20008, 'invalid instance name');
      END IF;
      IF p_sma_name IS NULL THEN
         raise_error(-20009, 'invalid schema name');
      END IF;
      IF p_env_name IS NULL THEN
         raise_error(-20010, 'invalid environment name');
      END IF;

      -- Load the timeout delay.
      <<load_to_delay>>
      BEGIN
         SELECT TO_NUMBER(stn_value)
           INTO to_delay
           FROM dpp_schema_options
          WHERE sma_id = p_sma_id
            AND otn_name = dpp_monitoring_var.gk_schopt_delay
            AND stn_usage = DECODE(p_jte_cd
                                 , 'EXPJB', 'E'
                                 , 'IMPJB', 'I'
                                 , 'TRFJB', 'T'
                                 , 'E');
      EXCEPTION
         WHEN OTHERS THEN
            to_delay := dpp_monitoring_var.gk_default_delay;
      END load_to_delay;
      
      -- DEBUG
      show_debug(
         'Treating busy job: '
      || 'jrn_id=' || p_jrn_id
      || ',jte_cd=' || p_jte_cd
      || ',sma_id=' || TO_CHAR(p_sma_id)
      || ',sma_name=' || p_sma_name
      || ',env_name=' || p_env_name
      || ',ite_name=' || p_ite_name
      || ',status=' || p_status
      || ',date_started='
      || NVL(TO_CHAR(p_date_started, 'YYYY-MM-DD HH24:MI:SS'), '/')
      );
      
      -- Check whether the job is in timeout.
      IF ((SYSDATE - p_date_started) * 1440) > to_delay THEN
      
         -- Report the timeout.
         report_timeout(
            p_jrn_id             => p_jrn_id
          , p_jte_cd             => p_jte_cd
          , p_sma_id             => p_sma_id
          , p_sma_name           => p_sma_name
          , P_env_name           => p_env_name
          , p_ite_name           => p_ite_name
          , p_status             => p_status
          , p_date_started       => p_date_started
         );
         
      END IF;
      
   END treat_job;
   
   /**
   * Treat the jobs.
   */
   PROCEDURE treat_jobs IS
   
      -- cursor that loads the living jobs
      CURSOR c_jobs IS
      SELECT DISTINCT
             jbr.jrn_id
           , jbr.jte_cd
           , jbr.sma_id
           , sma.sma_name
           , jbr.status
           , jbr.date_started
           , sma.ite_name
           , ite.env_name
        FROM dpp_job_runs jbr
        JOIN dpp_schemas sma
          ON sma.sma_id = jbr.sma_id
        JOIN dpp_schema_options sco
          ON sco.sma_id = jbr.sma_id
         AND sco.stn_usage = DECODE(jbr.jte_cd
                                  , 'IMPJB', 'I'
                                  , 'EXPJB', 'E'
                                  , 'TRFJB', 'T'
                                  , NULL)
        JOIN dpp_instances ite
          ON ite.ite_name = sma.ite_name
       WHERE jbr.status = dpp_monitoring_var.gk_job_status_busy
         AND jbr.jte_cd IN ('IMPJB', 'EXPJB', 'TRFJB')
         AND sco.otn_name = dpp_monitoring_var.gk_schopt_monitoring
         AND sco.stn_value = dpp_monitoring_var.gk_schoptval_monitoring
       ORDER BY jbr.jrn_id ASC
              , jbr.jte_cd ASC;
      
   BEGIN
   
      -- Browse the living jobs.
      <<browse_jobs>>
      FOR r_job IN c_jobs LOOP
      
         -- Treat the job.
         treat_job(
            p_jrn_id             => r_job.jrn_id
          , p_jte_cd             => r_job.jte_cd
          , p_sma_id             => r_job.sma_id
          , p_sma_name           => r_job.sma_name
          , p_env_name           => r_job.env_name
          , p_ite_name           => r_job.ite_name
          , p_status             => r_job.status
          , p_date_started       => r_job.date_started
         );
      
      END LOOP browse_jobs;
      
   END treat_jobs;

   /**
   * Execute the monitoring.
   *
   * @param p_debug: whether debug mode is activated
   */
   PROCEDURE exec_monitoring(p_debug IN BOOLEAN := FALSE) IS
   BEGIN
      IF p_debug IS NOT NULL THEN
         dpp_monitoring_var.g_debug_mode := p_debug;
      END IF;
      treat_jobs();
   END exec_monitoring;

END DPP_MONITORING_KRN;
/
