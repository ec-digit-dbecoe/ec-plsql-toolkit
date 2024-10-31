create or replace PACKAGE BODY mail_utility_krn AS
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
   /*  global subtypes */
   SUBTYPE g_long_string_type IS VARCHAR2(4096 CHAR);
   SUBTYPE g_single_char_type IS VARCHAR2(1 CHAR);
   SUBTYPE g_raw_type IS RAW(2100);

   /*
      Procedure to raise fatal errors
   */
   PROCEDURE raise_app_error(p_text IN VARCHAR2)
   IS
   BEGIN
      raise_application_error(-20000, p_text);
   END raise_app_error;

   FUNCTION get_prod_value
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE WHEN USER LIKE '%P' THEN 'Y' ELSE 'N' END;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'N';
   END get_prod_value;

   /*
      Procedure to establish to determine if the environment is production
   */
   PROCEDURE set_is_prod (
      p_prod_value IN VARCHAR2 := NULL -- Y/N/NULL=determine
   )
   IS
   BEGIN
      -- Set the value to the one passed in parameter
      -- If no value is passed, keep the previously set value
      -- If no previous value, determine in which environment we are
      IF p_prod_value IS NOT NULL THEN
         mail_utility_var.g_is_prod := p_prod_value = 'Y';
      ELSIF mail_utility_var.g_is_prod IS NULL THEN
         mail_utility_var.g_is_prod := get_prod_value = 'Y'; 
      END IF;
   END set_is_prod;

   FUNCTION get_developer_recipient
   RETURN mail_utility_var.g_big_list_type
   IS
   BEGIN
      RETURN mail_utility_var.g_developer_recipient;
   END get_developer_recipient;

   PROCEDURE set_developer_recipient(p_developer_recipient mail_utility_var.g_big_list_type)
   IS
   BEGIN
      -- Set the value to the one passed in parameter
      -- If no value is passed, keep the previously set value
      IF p_developer_recipient IS NOT NULL THEN
         mail_utility_var.g_developer_recipient := p_developer_recipient;
      END IF;
   END set_developer_recipient;

   FUNCTION get_developer_cc
   RETURN mail_utility_var.g_big_list_type
   IS
   BEGIN
      RETURN mail_utility_var.g_developer_cc;
   END get_developer_cc;

   PROCEDURE set_developer_cc(p_developer_cc mail_utility_var.g_big_list_type)
   IS
   BEGIN
      -- Set the value to the one passed in parameter
      -- If no value is passed, keep the previously set value
      IF p_developer_cc IS NOT NULL THEN
         mail_utility_var.g_developer_cc := p_developer_cc;
      END IF;
   END set_developer_cc;

   FUNCTION get_developer_bcc
   RETURN mail_utility_var.g_big_list_type
   IS
   BEGIN
      RETURN mail_utility_var.g_developer_bcc;
   END get_developer_bcc;

   PROCEDURE set_developer_bcc(p_developer_bcc mail_utility_var.g_big_list_type)
   IS
   BEGIN
      -- Set the value to the one passed in parameter
      -- If no value is passed, keep the previously set value
      IF p_developer_bcc IS NOT NULL THEN
         mail_utility_var.g_developer_bcc := p_developer_bcc;
      END IF;
   END set_developer_bcc;

   /*
      Procedure to set the sender and perform checks on it
   */
   PROCEDURE set_sender(p_sender IN VARCHAR2)
   IS
   BEGIN
      IF TRIM(p_sender) IS NULL THEN
         mail_utility_var.g_sender := mail_utility_var.gk_default_sender;
      ELSE
         mail_utility_var.g_sender := TRIM(p_sender);
      END IF;
   END set_sender;

   /*
      Procedure to set the recipients and perform checks on it
   */
   PROCEDURE set_recipients(p_recipients IN VARCHAR2)
   IS
   BEGIN
      IF NOT mail_utility_var.g_is_prod THEN
         IF NOT TRIM(mail_utility_var.g_developer_recipient) IS NULL THEN
            mail_utility_var.g_recipients := mail_utility_var.g_developer_recipient;
         ELSE
            raise_app_error('NOT in production and g_developer_recipient is empty, terminating.');
         END IF;
      ELSIF TRIM(p_recipients) IS NULL THEN
         raise_app_error('No recipients where given, terminating.');
      ELSE
         mail_utility_var.g_recipients := TRIM(p_recipients);
      END IF;
   END set_recipients;

   /*
      Procedure to set the cc and perform checks on it
   */
   PROCEDURE set_cc(p_cc IN VARCHAR2)
   IS
   BEGIN
      IF NOT mail_utility_var.g_is_prod THEN
         mail_utility_var.g_cc := mail_utility_var.g_developer_cc;
      ELSE
         mail_utility_var.g_cc := TRIM(p_cc);
      END IF;
   END set_cc;

   /*
      Procedure to set the bcc and perform checks on it
   */
   PROCEDURE set_bcc(p_bcc IN VARCHAR2)
   IS
   BEGIN
      IF NOT mail_utility_var.g_is_prod THEN
         mail_utility_var.g_bcc := mail_utility_var.g_developer_bcc;
      ELSE
         mail_utility_var.g_bcc := TRIM(p_bcc);
      END IF;
   END set_bcc;

   /*
      Procedure to set the subject and perform checks on it
   */
   PROCEDURE set_subject(p_subject IN VARCHAR2)
   IS
   BEGIN
      -- Trim is only applied to check if it's empty
      -- not when variable is set because there might be blanks for formatting purposes
      IF TRIM(p_subject) IS NULL THEN
         raise_app_error('The mail subject is empty, terminating.');
      ELSE
         mail_utility_var.g_subject := p_subject;
      END IF;
   END set_subject;

   /*
      Procedure to set the message and perform checks on it
   */
   PROCEDURE set_message(p_message IN VARCHAR2)
   IS
   BEGIN
      -- Trim is only applied to check if it's empty
      -- not when variable is set because there might be blanks for formatting purposes
      IF TRIM(p_message) IS NULL THEN
         raise_app_error('The mail message is empty, terminating.');
      ELSE
         mail_utility_var.g_message := p_message;
      END IF;
   END set_message;

   PROCEDURE set_message_ov32k(p_message IN CLOB)
   IS
   BEGIN
      -- Trim is only applied to check if it's empty
      -- not when variable is set because there might be blanks for formatting purposes
      IF TRIM(p_message) IS NULL THEN
         raise_app_error('The mail message is empty, terminating.');
      ELSE
         mail_utility_var.g_message_ov32k := p_message;
      END IF;
   END set_message_ov32k;

   /*
      Procedure to set the mime_type and perform checks on it
   */
   PROCEDURE set_mime_type(p_mime_type IN VARCHAR2)
   IS
   BEGIN
      mail_utility_var.g_mime_type := p_mime_type;
   END set_mime_type;

   /*
      Procedure to set the att_mime_type and perform checks on it
   */
   PROCEDURE set_att_mime_type(p_att_mime_type IN VARCHAR2)
   IS
   BEGIN
      mail_utility_var.g_att_mime_type := p_att_mime_type;
   END set_att_mime_type;

   /*
      Procedure to set the priority and perform checks on it
   */
   PROCEDURE set_priority(p_priority IN PLS_INTEGER)
   IS
   BEGIN
      -- Specifies message priority.
      -- Valid values are 1 (high), 3 (normal) and 5 (low).
      IF p_priority BETWEEN 1 AND 5 THEN
         mail_utility_var.g_priority := p_priority;
      ELSE
         mail_utility_var.g_priority := 3;
      END IF;
   END set_priority;

   /*
      Procedure to set if the attachment is added inline or not
   */
   PROCEDURE set_att_inline(p_att_inline IN BOOLEAN)
   IS
   BEGIN
      IF p_att_inline
        OR NOT p_att_inline
      THEN
         mail_utility_var.g_att_inline := p_att_inline;
      ELSE
         mail_utility_var.g_att_inline := FALSE;
      END IF;
   END set_att_inline;

   /*
      Procedure to set the file name of the attachment
   */
   PROCEDURE set_att_filename(p_att_filename IN VARCHAR2)
   IS
   BEGIN
      IF TRIM(p_att_filename) IS NULL THEN
         mail_utility_var.g_att_filename := 'filename' || TO_CHAR(systimestamp,'yyyymmddhh24missFF');
      ELSE
         mail_utility_var.g_att_filename := TRIM(p_att_filename);
      END IF;
   END set_att_filename;

   /*
      Procedure to set the force send flag and perform checks on it
      The main reason for this variable is to make it harder to send emails outside of production environement
      to avoid sending test mails
   */
   PROCEDURE set_force_send_on_non_prod_env(p_force_send_on_non_prod_env IN BOOLEAN)
   IS
   BEGIN
      mail_utility_var.g_force_send_on_non_prod_env := NVL(p_force_send_on_non_prod_env, FALSE);
   END set_force_send_on_non_prod_env;

   /*
      Function to check if we are in prod or force send is enabled
   */
   FUNCTION check_prod_or_force_send
   RETURN BOOLEAN
   IS
      l_return BOOLEAN;
   BEGIN
      IF mail_utility_var.g_is_prod THEN
         l_return := TRUE;
      ELSE
         IF mail_utility_var.g_force_send_on_non_prod_env THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
      END IF;
      RETURN l_return;
   END check_prod_or_force_send;

   FUNCTION get_mail(p_mail_id IN mails.mail_id%TYPE)
   RETURN mails%ROWTYPE
   IS
      CURSOR c_mail(p_mail_id IN mails.mail_id%TYPE)
          IS
      SELECT *
        FROM mails
       WHERE mail_id = p_mail_id;

       r_mail c_mail%ROWTYPE; 
   BEGIN
      OPEN c_mail(p_mail_id);
      FETCH c_mail INTO r_mail;
      CLOSE c_mail;
      RETURN r_mail;
   END get_mail;      

   FUNCTION save_mail(p_sender            IN    VARCHAR2 CHARACTER SET ANY_CS
                     ,p_recipients        IN    VARCHAR2 CHARACTER SET ANY_CS
                     ,p_cc                IN    VARCHAR2 CHARACTER SET ANY_CS
                     ,p_bcc               IN    VARCHAR2 CHARACTER SET ANY_CS
                     ,p_subject           IN    VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
                     ,p_message           IN    CLOB CHARACTER SET ANY_CS
                     ,p_mail_mime_type    IN    VARCHAR2
                     ,p_priority          IN    PLS_INTEGER DEFAULT 3
                     ,p_clob_attachment   IN    CLOB CHARACTER SET ANY_CS
                     ,p_raw_attachment    IN    RAW
                     ,p_att_filename      IN    VARCHAR2 DEFAULT NULL
                     ,p_attachment_mime_type       IN VARCHAR2
                     ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
                     ,p_att_inline        IN    BOOLEAN                
                     ,p_transfer_enc		IN    VARCHAR2 DEFAULT NULL
                     ,p_status            IN    mails.status%TYPE
                     ,p_typ_id            IN    mails.typ_id%TYPE
                     )
   RETURN mails.mail_id%TYPE
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_mail_id                mails.mail_id%TYPE;
      l_force_send_flag        mails.force_send_flag%TYPE;
      l_inline_attachment_flag mails.inline_attachment_flag%TYPE;
   BEGIN
      l_mail_id := mail_seq.NEXTVAL;
      l_force_send_flag := CASE WHEN p_force_send_on_non_prod_env THEN 'Y' ELSE 'N' END;
      l_inline_attachment_flag := CASE WHEN p_att_inline THEN 'Y' WHEN NOT p_att_inline THEN 'N' END;
      INSERT INTO mails
      (mail_id
      ,typ_id
      ,subject
      ,mail_from
      ,mail_to
      ,cc
      ,bcc
      ,content
      ,mail_mime_type
      ,clob_attachment
      ,raw_attachment
      ,attachment_mime_type
      ,attachment_file_name
      ,content_transfer_encoding
      ,priority
      ,status
      ,force_send_flag
      ,inline_attachment_flag
      ,date_creat
      ,user_creat
      ,date_modif
      ,user_modif
      )
      VALUES
      (l_mail_id
      ,p_typ_id
      ,p_subject
      ,p_sender
      ,p_recipients
      ,p_cc 
      ,p_bcc
      ,p_message
      ,p_mail_mime_type
      ,p_clob_attachment
      ,p_raw_attachment
      ,p_attachment_mime_type
      ,p_att_filename
      ,p_transfer_enc      
      ,p_priority
      ,p_status
      ,l_force_send_flag
      ,l_inline_attachment_flag
      ,SYSDATE
      ,NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
      ,SYSDATE
      ,NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
      );
      COMMIT;
      RETURN l_mail_id;
   END save_mail;

   PROCEDURE log_mail(p_mail_id         IN mails.mail_id%TYPE
                     ,p_operation       IN mail_logs.operation%TYPE
                     ,p_status          IN mail_logs.status%TYPE
                     ,p_additional_info IN mail_logs.additional_info%TYPE
                     )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO mail_logs
      (mail_id
      ,log_id
      ,log_date
      ,operation
      ,status
      ,additional_info
      ,date_creat
      ,user_creat
      ,date_modif
      ,user_modif
      )
      VALUES
      (p_mail_id
      ,mail_log_seq.NEXTVAL
      ,SYSTIMESTAMP
      ,p_operation
      ,p_status
      ,p_additional_info
      ,SYSDATE
      ,NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
      ,SYSDATE
      ,NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
      );
      COMMIT;
   END log_mail;

   PROCEDURE save_and_log_mail
         (p_sender            IN VARCHAR2 CHARACTER SET ANY_CS
         ,p_recipients        IN VARCHAR2 CHARACTER SET ANY_CS
         ,p_cc                IN VARCHAR2 CHARACTER SET ANY_CS
         ,p_bcc               IN VARCHAR2 CHARACTER SET ANY_CS
         ,p_subject           IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
         ,p_message           IN CLOB CHARACTER SET ANY_CS
         ,p_mail_mime_type    IN VARCHAR2
         ,p_priority          IN PLS_INTEGER DEFAULT 3
         ,p_clob_attachment   IN CLOB CHARACTER SET ANY_CS
         ,p_raw_attachment    IN RAW
         ,p_attachment_mime_type IN VARCHAR2
         ,p_att_filename      IN VARCHAR2 DEFAULT NULL
         ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
         ,p_att_inline        IN BOOLEAN DEFAULT FALSE                    
         ,p_transfer_enc		IN VARCHAR2 DEFAULT NULL
         ,p_mail_status       IN mails.status%TYPE
         ,p_typ_id            IN mails.typ_id%TYPE
         ,p_operation         IN mail_logs.operation%TYPE
         ,p_log_status        IN mail_logs.status%TYPE
         ,p_additional_info   IN mail_logs.additional_info%TYPE
         ,p_mail_id           IN mails.mail_id%TYPE DEFAULT NULL
         ,p_log_mail          IN BOOLEAN DEFAULT FALSE
        )
   IS
      l_mail_id      mails.mail_id%TYPE := p_mail_id;
      l_cnt_attempts INTEGER;
   BEGIN
      IF NOT p_log_mail THEN
         RETURN;
      END IF;
      IF p_log_status = 'SUCCEEDED' THEN  
         IF l_mail_id IS NULL THEN
            l_mail_id := save_mail(p_sender=>p_sender
                                  ,p_recipients=>p_recipients
                                  ,p_cc=>p_cc
                                  ,p_bcc=>p_bcc
                                  ,p_subject=>p_subject
                                  ,p_message=>p_message
                                  ,p_mail_mime_type=>p_mail_mime_type
                                  ,p_priority=>p_priority
                                  ,p_clob_attachment=>p_clob_attachment
                                  ,p_raw_attachment=>p_raw_attachment
                                  ,p_attachment_mime_type=>p_attachment_mime_type
                                  ,p_att_filename=>p_att_filename
                                  ,p_transfer_enc=>p_transfer_enc
                                  ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                                  ,p_att_inline=>p_att_inline
                                  ,p_status=> p_mail_status
                                  ,p_typ_id=>p_typ_id
                                  );
         ELSE -- a previous attempts failed, change the status
            UPDATE mails mail
               SET mail.status = p_mail_status
                 , mail.date_modif = SYSDATE
                 , mail.user_modif = NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
            WHERE mail.mail_id = l_mail_id;                               
         END IF;                            
         log_mail(p_mail_id=>l_mail_id
                 ,p_operation=>p_operation
                 ,p_status=>p_log_status
                 ,p_additional_info=>NULL
                 );
      ELSE -- FAILURE           
         IF l_mail_id IS NULL THEN -- first attempts
            l_mail_id := save_mail(p_sender=>p_sender
                                  ,p_recipients=>p_recipients
                                  ,p_cc=>p_cc
                                  ,p_bcc=>p_bcc
                                  ,p_subject=>p_subject
                                  ,p_message=>p_message
                                  ,p_mail_mime_type=>p_mail_mime_type
                                  ,p_priority=>p_priority
                                  ,p_clob_attachment=>p_clob_attachment
                                  ,p_raw_attachment=>p_raw_attachment
                                  ,p_attachment_mime_type=>p_attachment_mime_type
                                  ,p_att_filename=>p_att_filename
                                  ,p_transfer_enc=>p_transfer_enc
                                  ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                                  ,p_att_inline=>p_att_inline
                                  ,p_status=> CASE WHEN mail_utility_var.g_max_trials = 1 THEN 'ARCHIVED' ELSE p_mail_status END
                                  ,p_typ_id=>p_typ_id
                                  );
         ELSE  -- it's not the first failure, check if we reached maximum                      
            SELECT COUNT(*) 
              INTO l_cnt_attempts
              FROM mail_logs
             WHERE mail_id = l_mail_id;
            IF l_cnt_attempts = mail_utility_var.g_max_trials-1 THEN
               UPDATE mails mail
                  SET mail.status = 'ARCHIVED' -- max trials reached
                    , mail.date_modif = SYSDATE
                    , mail.user_modif = NVL(LOWER(sys_context('USERENV', 'os_user')), USER)
               WHERE mail.mail_id = l_mail_id;
            END IF;     
         END IF;                            
         log_mail(p_mail_id=>l_mail_id
                 ,p_operation=>p_operation
                 ,p_status=>p_log_status
                 ,p_additional_info=>sys.dbms_utility.format_error_backtrace||CHR(10)||sys.dbms_utility.format_error_stack
                 );
      END IF;
   END save_and_log_mail;

   /*
      Procedure to send emails, it uses the sys.utl_mail package to send emails
   */
   PROCEDURE send_mail
      (p_sender     IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_recipients IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_cc         IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_bcc        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_subject    IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_message    IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_mime_type  IN VARCHAR2 DEFAULT 'text/plain; charset=us-ascii'
      ,p_priority   IN PLS_INTEGER DEFAULT 3
      ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
      ,p_mail_id    IN mails.mail_id%TYPE DEFAULT NULL
      ,p_log_mail   IN BOOLEAN DEFAULT FALSE
      )
   IS
   BEGIN
      -- Check if we are in PROD or not
      -- If we get an error while retrieving the value we assume we are not in PROD
      set_is_prod();

      -- Set the parameter values
      set_sender(p_sender);
      set_recipients(p_recipients);
      set_cc(p_cc);
      set_bcc(p_bcc);
      set_subject(p_subject);
      set_message(p_message);
      set_mime_type(p_mime_type);
      set_priority(p_priority);
      set_force_send_on_non_prod_env(p_force_send_on_non_prod_env);

      -- BY default we only want to sent emails on PROD and not on test environements
      -- so if we want to send mail on test environement p_force_send_on_non_prod_env needs to be set by the developer
      IF check_prod_or_force_send THEN
         sys.utl_mail.send(
                        sender => mail_utility_var.g_sender
                      , recipients => mail_utility_var.g_recipients
                      , cc => mail_utility_var.g_cc
                      , bcc => mail_utility_var.g_bcc
                      , subject => mail_utility_var.g_subject
                      , message => mail_utility_var.g_message
                      , mime_type => mail_utility_var.g_mime_type
                      , priority => mail_utility_var.g_priority
                      );
      END IF;
      save_and_log_mail(p_sender=>p_sender
                       ,p_recipients=>p_recipients
                       ,p_cc=>p_cc
                       ,p_bcc=>p_bcc
                       ,p_subject=>p_subject
                       ,p_message=>p_message
                       ,p_mail_mime_type=>p_mime_type
                       ,p_priority=>p_priority
                       ,p_clob_attachment=>NULL
                       ,p_raw_attachment=>NULL
                       ,p_attachment_mime_type=>NULL
                       ,p_att_filename=>NULL
                       ,p_transfer_enc=>NULL
                       ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                       ,p_att_inline=>NULL
                       ,p_mail_status=> 'SENT'
                       ,p_operation=>'SEND'
                       ,p_log_status=>'SUCCEEDED'
                       ,p_additional_info=>NULL
                       ,p_typ_id=>mail_utility_var.gk_typ_basic
                       ,p_mail_id=>p_mail_id
                       ,p_log_mail=>p_log_mail
                       );
   EXCEPTION
      WHEN OTHERS THEN
         save_and_log_mail(p_sender=>p_sender
                          ,p_recipients=>p_recipients
                          ,p_cc=>p_cc
                          ,p_bcc=>p_bcc
                          ,p_subject=>p_subject
                          ,p_message=>p_message
                          ,p_mail_mime_type=>p_mime_type
                          ,p_priority=>p_priority
                          ,p_clob_attachment=>NULL
                          ,p_raw_attachment=>NULL
                          ,p_att_filename=>NULL
                          ,p_attachment_mime_type=>NULL
                          ,p_transfer_enc=>NULL
                          ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                          ,p_mail_status=> 'NOT SENT'
                          ,p_operation=>'SEND'
                          ,p_log_status=>'FAILED'
                          ,p_additional_info=>NULL
                          ,p_typ_id=>mail_utility_var.gk_typ_basic
                          ,p_mail_id=>p_mail_id
                          ,p_log_mail=>p_log_mail
                          );
           raise_app_error(SQLERRM);
   END send_mail;

   /*
      Procedure to send emails with raw attachements, it uses the sys.utl_mail package to send emails
   */
   PROCEDURE send_mail_attach_raw
      (p_sender        IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_recipients    IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_cc            IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_bcc           IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_subject       IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_message       IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_mime_type     IN VARCHAR2 DEFAULT 'text/plain; charset=us-ascii'
      ,p_priority      IN PLS_INTEGER DEFAULT 3
      ,p_attachment    IN RAW
      ,p_att_inline    IN BOOLEAN DEFAULT FALSE
      ,p_att_mime_type IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT 'application/octet'
      ,p_att_filename  IN VARCHAR2 DEFAULT NULL
      ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
      ,p_mail_id       IN mails.mail_id%TYPE DEFAULT NULL
      ,p_log_mail      IN BOOLEAN DEFAULT FALSE
      )
   IS
   BEGIN
      -- Check if we are in PROD or not
      -- If we get an error while retrieving the value we assume we are not in PROD
      set_is_prod();

      -- Set the parameter values
      set_sender(p_sender);
      set_recipients(p_recipients);
      set_cc(p_cc);
      set_bcc(p_bcc);
      set_subject(p_subject);
      set_message(p_message);
      set_mime_type(p_mime_type);
      set_priority(p_priority);
      set_att_inline(p_att_inline);
      set_att_mime_type(p_att_mime_type);
      set_att_filename(p_att_filename);
      set_force_send_on_non_prod_env(p_force_send_on_non_prod_env);

      -- BY default we only want to sent emails on PROD and not on test environements
      -- so if we want to send mail on test environement p_force_send_on_non_prod_env needs to be set by the developer
      IF check_prod_or_force_send THEN
         sys.utl_mail.send_attach_raw( sender => mail_utility_var.g_sender
                                 , recipients => mail_utility_var.g_recipients
                                 , cc => mail_utility_var.g_cc
                                 , bcc => mail_utility_var.g_bcc
                                 , subject => mail_utility_var.g_subject
                                 , message => mail_utility_var.g_message
                                 , mime_type => mail_utility_var.g_mime_type
                                 , priority => mail_utility_var.g_priority
                                 , attachment => p_attachment
                                 , att_inline => mail_utility_var.g_att_inline
                                 , att_mime_type => mail_utility_var.g_att_mime_type
                                 , att_filename => mail_utility_var.g_att_filename
                                 );
      END IF;
      save_and_log_mail(p_sender=>p_sender
                       ,p_recipients=>p_recipients
                       ,p_cc=>p_cc
                       ,p_bcc=>p_bcc
                       ,p_subject=>p_subject
                       ,p_message=>p_message
                       ,p_mail_mime_type=>mail_utility_var.g_mime_type
                       ,p_priority=>p_priority
                       ,p_clob_attachment=>NULL
                       ,p_raw_attachment=>p_attachment
                       ,p_attachment_mime_type=>mail_utility_var.g_att_mime_type
                       ,p_att_filename=>NULL
                       ,p_transfer_enc=>NULL
                       ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                       ,p_att_inline=>p_att_inline
                       ,p_mail_status=> 'SENT'
                       ,p_operation=>'SEND'
                       ,p_log_status=>'SUCCEEDED'
                       ,p_additional_info=>NULL
                       ,p_typ_id=>mail_utility_var.gk_typ_raw_attachment
                       ,p_mail_id=>p_mail_id
                       ,p_log_mail=>p_log_mail
                       );   
   EXCEPTION
      WHEN OTHERS THEN
         save_and_log_mail(p_sender=>p_sender
                          ,p_recipients=>p_recipients
                          ,p_cc=>p_cc
                          ,p_bcc=>p_bcc
                          ,p_subject=>p_subject
                          ,p_message=>p_message
                          ,p_mail_mime_type=>mail_utility_var.g_mime_type
                          ,p_priority=>p_priority
                          ,p_clob_attachment=>NULL
                          ,p_raw_attachment=>p_attachment
                          ,p_att_filename=>NULL
                          ,p_attachment_mime_type=>mail_utility_var.g_att_mime_type
                          ,p_transfer_enc=>NULL
                          ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                          ,p_att_inline=>p_att_inline
                          ,p_mail_status=> 'NOT SENT'
                          ,p_operation=>'SEND'
                          ,p_log_status=>'FAILED'
                          ,p_additional_info=>NULL
                          ,p_typ_id=>mail_utility_var.gk_typ_raw_attachment                          
                          ,p_mail_id=>p_mail_id
                          ,p_log_mail=>p_log_mail
                          );
         raise_app_error(SQLERRM);
   END send_mail_attach_raw;

   /*
      Procedure to send emails with text attachments, it uses the sys.utl_mail package to send emails. Size limited to  32K
   */
   PROCEDURE send_mail_attach_text
      (p_sender        IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_recipients    IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_cc            IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_bcc           IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_subject       IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_message       IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_mime_type     IN VARCHAR2 DEFAULT 'text/plain; charset=us-ascii'
      ,p_priority      IN PLS_INTEGER DEFAULT 3
      ,p_attachment    IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_att_inline    IN BOOLEAN DEFAULT FALSE
      ,p_att_mime_type IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT 'text/plain; charset=us-ascii'
      ,p_att_filename  IN VARCHAR2 DEFAULT NULL
      ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
      ,p_mail_id       IN mails.mail_id%TYPE DEFAULT NULL
      ,p_log_mail      IN BOOLEAN DEFAULT FALSE
      )
   IS
   BEGIN
      -- Check if we are in PROD or not
      -- If we get an error while retrieving the value we assume we are not in PROD
      set_is_prod();

      -- Set the parameter values
      set_sender(p_sender);
      set_recipients(p_recipients);
      set_cc(p_cc);
      set_bcc(p_bcc);
      set_subject(p_subject);
      set_message(p_message);
      set_mime_type(p_mime_type);
      set_priority(p_priority);
      set_att_inline(p_att_inline);
      set_att_mime_type(p_att_mime_type);
      set_att_filename(p_att_filename);
      set_force_send_on_non_prod_env(p_force_send_on_non_prod_env);

      -- BY default we only want to sent emails on PROD and not on test environements
      -- so if we want to send mail on test environement p_force_send_on_non_prod_env needs to be set by the developer
      IF check_prod_or_force_send THEN
         sys.utl_mail.send_attach_varchar2(
                                   sender => mail_utility_var.g_sender
                                 , recipients => mail_utility_var.g_recipients
                                 , cc => mail_utility_var.g_cc
                                 , bcc => mail_utility_var.g_bcc
                                 , subject => mail_utility_var.g_subject
                                 , message => mail_utility_var.g_message
                                 , mime_type => mail_utility_var.g_mime_type
                                 , priority => mail_utility_var.g_priority
                                 , attachment => p_attachment
                                 , att_inline => mail_utility_var.g_att_inline
                                 , att_mime_type => mail_utility_var.g_att_mime_type
                                 , att_filename => mail_utility_var.g_att_filename
                                 );
      END IF;
      save_and_log_mail(p_sender=>p_sender
                       ,p_recipients=>p_recipients
                       ,p_cc=>p_cc
                       ,p_bcc=>p_bcc
                       ,p_subject=>p_subject
                       ,p_message=>p_message
                       ,p_mail_mime_type=>mail_utility_var.g_mime_type
                       ,p_priority=>p_priority
                       ,p_clob_attachment=>p_attachment
                       ,p_raw_attachment=>NULL
                       ,p_attachment_mime_type=>mail_utility_var.g_att_mime_type
                       ,p_att_filename=>mail_utility_var.g_att_filename
                       ,p_transfer_enc=>NULL
                       ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                       ,p_att_inline=>p_att_inline
                       ,p_mail_status=> 'SENT'
                       ,p_operation=>'SEND'
                       ,p_log_status=>'SUCCEEDED'
                       ,p_additional_info=>NULL
                       ,p_typ_id=>mail_utility_var.gk_typ_text_attachment
                       ,p_mail_id=>p_mail_id
                       ,p_log_mail=>p_log_mail
                       );      
   EXCEPTION
      WHEN OTHERS THEN
         save_and_log_mail(p_sender=>p_sender
                          ,p_recipients=>p_recipients
                          ,p_cc=>p_cc
                          ,p_bcc=>p_bcc
                          ,p_subject=>p_subject
                          ,p_message=>p_message
                          ,p_mail_mime_type=>mail_utility_var.g_mime_type
                          ,p_priority=>p_priority
                          ,p_clob_attachment=>p_attachment
                          ,p_raw_attachment=>NULL
                          ,p_att_filename=>mail_utility_var.g_att_filename
                          ,p_attachment_mime_type=>mail_utility_var.g_att_mime_type
                          ,p_transfer_enc=>NULL
                          ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                          ,p_att_inline=>p_att_inline
                          ,p_mail_status=> 'NOT SENT'
                          ,p_operation=>'SEND'
                          ,p_log_status=>'FAILED'
                          ,p_additional_info=>NULL
                          ,p_typ_id=>mail_utility_var.gk_typ_text_attachment                          
                          ,p_mail_id=>p_mail_id
                          ,p_log_mail=>p_log_mail
                          );
         raise_app_error(SQLERRM);
   END send_mail_attach_text;

   /*   
   * ======================================================================
   *  routines below are related to the UTL_SMTP usage instead of UTL_MAIL
   * ======================================================================
   */
   FUNCTION get_address(pio_addr_list IN OUT VARCHAR2) 
   RETURN VARCHAR2 
   IS
      l_addr mail_utility_var.g_short_string_type;
      l_i    PLS_INTEGER;

      FUNCTION lookup_unquoted_char(p_str IN VARCHAR2, p_chrs IN VARCHAR2)
      RETURN PLS_INTEGER 
      IS
         l_char         g_single_char_type;
         l_j            PLS_INTEGER;
         l_len          PLS_INTEGER;
         l_inside_quote BOOLEAN;
      BEGIN
         l_inside_quote := FALSE;
         l_j            := 1;
         l_len          := LENGTH(p_str);
         WHILE (l_j <= l_len) LOOP
            l_char := SUBSTR(p_str, l_j, 1);        
            IF (l_inside_quote) THEN
               IF (l_char = '"') THEN
                  l_inside_quote := FALSE;
               ELSIF (l_char = '\') THEN
                  l_j := l_j + 1; -- Skip the quote character
               END IF;
               GOTO next_char;
            END IF;

            IF (l_char = '"') THEN
               l_inside_quote := TRUE;
               GOTO next_char;
            END IF;

            IF (INSTR(p_chrs, l_char) >= 1) THEN
               RETURN l_j;
            END IF;

            <<next_char>>
            l_j := l_j + 1;
         END LOOP;
         RETURN 0;
      END lookup_unquoted_char;
   BEGIN
      pio_addr_list := LTRIM(pio_addr_list);
      l_i           := lookup_unquoted_char(pio_addr_list, ',;');
      IF (l_i >= 1) THEN
         l_addr        := SUBSTR(pio_addr_list, 1, l_i - 1);
         pio_addr_list := SUBSTR(pio_addr_list, l_i + 1);
      ELSE
         l_addr        := pio_addr_list;
         pio_addr_list := '';
      END IF;

      l_i := lookup_unquoted_char(l_addr, '<');
      IF (l_i >= 1) THEN
         l_addr := SUBSTR(l_addr, l_i + 1);
         l_i    := INSTR(l_addr, '>');
         IF (l_i >= 1) THEN
         l_addr := SUBSTR(l_addr, 1, l_i - 1);
         END IF;
      END IF;        
      RETURN l_addr;
   END get_address;

   -- Write a MIME header
   PROCEDURE write_mime_header(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION
                              ,p_name   IN VARCHAR2
                              ,p_value  IN VARCHAR2
                              )
   IS
   BEGIN
      sys.UTL_SMTP.WRITE_DATA(pio_conn, p_name || ': ' || p_value || sys.UTL_TCP.CRLF);
   END write_mime_header;

   PROCEDURE write_boundary(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION
                           ,p_last IN BOOLEAN DEFAULT FALSE
                           )
   IS
   BEGIN
      IF (p_last) THEN
         sys.UTL_SMTP.WRITE_DATA(pio_conn, mail_utility_var.gk_smtp_last_boundary);
      ELSE
         sys.UTL_SMTP.WRITE_DATA(pio_conn, mail_utility_var.gk_smtp_first_boundary);
      END IF;
   END write_boundary;

   FUNCTION begin_session 
   RETURN sys.UTL_SMTP.CONNECTION 
   IS
      l_conn sys.UTL_SMTP.CONNECTION;
   BEGIN
      -- open SMTP connection
      l_conn := sys.UTL_SMTP.OPEN_CONNECTION(mail_utility_var.g_smtp_host, mail_utility_var.g_smtp_port);
      sys.UTL_SMTP.HELO(l_conn, mail_utility_var.g_smtp_domain);
      RETURN l_conn;
   END begin_session;

   PROCEDURE begin_mail_in_session(pio_conn       IN OUT NOCOPY sys.utl_smtp.connection
                                  ,p_sender     IN VARCHAR2
                                  ,p_recipients IN VARCHAR2
                                  ,p_cc         IN VARCHAR2 
                                  ,p_bcc        IN VARCHAR2                                   
                                  ,p_subject    IN VARCHAR2
                                  ,p_mime_type  IN VARCHAR2 DEFAULT 'text/plain'
                                  ,p_priority   IN PLS_INTEGER DEFAULT NULL
                                  )
   IS
      l_my_recipients mail_utility_var.g_big_list_type := p_recipients;
      l_my_cc         mail_utility_var.g_big_list_type := p_cc;
      l_my_bcc        mail_utility_var.g_big_list_type := p_bcc;
      l_my_sender     mail_utility_var.g_big_list_type := p_sender;
      l_prio_value    mail_utility_var.g_short_code_type;
      lk_mailer_id    CONSTANT mail_utility_var.g_short_string_type := 'Mailer by Oracle UTL_SMTP';      
   BEGIN

      -- Specify sender's address (our server allows bogus address
      -- as long as it is a full email address (xxx@yyy.com).
      sys.UTL_SMTP.MAIL(pio_conn, get_address(l_my_sender));

      -- Specify recipient(s) of the email.
      WHILE (l_my_recipients IS NOT NULL) LOOP
         sys.UTL_SMTP.RCPT(pio_conn, get_address(l_my_recipients));
      END LOOP;

      WHILE (l_my_cc IS NOT NULL) LOOP
         sys.UTL_SMTP.RCPT(pio_conn, get_address(l_my_cc));
      END LOOP;

      WHILE (l_my_bcc IS NOT NULL) LOOP
         sys.UTL_SMTP.RCPT(pio_conn, get_address(l_my_bcc));
      END LOOP;

      -- Start body of email
      sys.UTL_SMTP.OPEN_DATA(pio_conn);             
      -- Set "From" MIME header
      write_mime_header(pio_conn, 'From', p_sender);           
      -- Set "To" MIME header
      write_mime_header(pio_conn, 'To', p_recipients);           

      -- Set "Cc" MIME header
      write_mime_header(pio_conn, 'Cc', p_cc);           

      -- Set "Bcc" MIME header
      write_mime_header(pio_conn, 'Bcc', p_bcc);           

      -- Set "Subject" MIME header
      write_mime_header(pio_conn, 'Subject', p_subject);

      -- Set priority:
      --   High      Normal       Low
      --   1     2     3     4     5
      IF (p_priority IS NOT NULL) THEN
         l_prio_value := CASE WHEN p_priority < 3 THEN 'High' WHEN p_priority > 3 THEN 'Low' ELSE 'Normal' END;
         write_mime_header(pio_conn, 'Importance', l_prio_value);
         write_mime_header(pio_conn, 'X-Priority', p_priority);
      END IF;

      -- Set "Content-Type" MIME header
      write_mime_header(pio_conn, 'Content-Type', p_mime_type);

      -- Set "X-Mailer" MIME header
      write_mime_header(pio_conn, 'X-Mailer', lk_mailer_id);

      -- Send an empty line to denotes end of MIME headers and
      -- beginning of message body.
      sys.UTL_SMTP.WRITE_DATA(pio_conn, sys.utl_tcp.CRLF);

      IF (p_mime_type LIKE 'multipart/mixed%') THEN
         sys.UTL_SMTP.WRITE_DATA(pio_conn,'This is a multi-part message in MIME format.' ||sys.UTL_TCP.CRLF);
      END IF;

   END begin_mail_in_session;

   PROCEDURE begin_attachment(pio_conn       IN OUT NOCOPY sys.utl_smtp.connection
                             ,p_mime_type    IN VARCHAR2 DEFAULT 'text/plain'
                             ,p_att_inline   IN BOOLEAN DEFAULT TRUE
                             ,p_filename     IN VARCHAR2 DEFAULT NULL
                             ,p_transfer_enc IN VARCHAR2 DEFAULT NULL
                             )
   IS
   BEGIN
      write_boundary(pio_conn);
      write_mime_header(pio_conn, 'Content-Type', p_mime_type);
      IF (p_filename IS NOT NULL) THEN
         IF (p_att_inline) THEN
            write_mime_header(pio_conn,'Content-Disposition','inline; filename="' || p_filename || '"');
         ELSE
            write_mime_header(pio_conn,'Content-Disposition','attachment; filename="' || p_filename || '"');
         END IF;
      END IF;
      IF (p_transfer_enc IS NOT NULL) THEN
         write_mime_header(pio_conn, 'Content-Transfer-Encoding', p_transfer_enc);
      END IF;
      sys.UTL_SMTP.WRITE_DATA(pio_conn, sys.UTL_TCP.CRLF);
   END begin_attachment;

  ------------------------------------------------------------------------
   PROCEDURE end_attachment(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION
                           ,p_last   IN BOOLEAN DEFAULT FALSE
                           ) 
   IS
   BEGIN
      sys.UTL_SMTP.WRITE_DATA(pio_conn, sys.UTL_TCP.CRLF);
      IF (p_last) THEN
         write_boundary(pio_conn, p_last);
      END IF;
   END end_attachment;

   PROCEDURE write_mb_text(pio_conn  IN OUT NOCOPY sys.utl_smtp.connection
                          ,p_message IN CLOB
                          )
   IS
    -- transforming CLOB a BLOB
     l_off      NUMBER DEFAULT 1;
     l_amt      NUMBER DEFAULT 1024;
     l_amtWrite NUMBER;
     l_str      g_long_string_type;
   BEGIN
      LOOP
         sys.DBMS_LOB.READ(p_message, l_amt, l_off, l_str);
         l_amtWrite := sys.UTL_RAW.LENGTH(sys.UTL_RAW.CAST_TO_RAW(l_str));
         sys.UTL_SMTP.WRITE_RAW_DATA(pio_conn, sys.UTL_RAW.CAST_TO_RAW(l_str));
         l_off := l_off + l_amt;
         l_amt := 1024;
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END write_mb_text;  

   PROCEDURE end_mail_in_session(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION)
   IS
   BEGIN
      sys.UTL_SMTP.CLOSE_DATA(pio_conn);
   END end_mail_in_session;

   PROCEDURE end_session(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION) 
   IS
   BEGIN
      sys.UTL_SMTP.QUIT(pio_conn);
   END end_session;

   PROCEDURE end_mail(pio_conn IN OUT NOCOPY sys.UTL_SMTP.CONNECTION) 
   IS
   BEGIN
      end_mail_in_session(pio_conn);
      end_session(pio_conn);
   END end_mail;

   PROCEDURE send_mail_over32k
      (p_sender     IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_recipients IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_cc         IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_bcc        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_subject    IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_message    IN CLOB CHARACTER SET ANY_CS
      ,p_priority   IN PLS_INTEGER DEFAULT 3
      ,p_force_send_on_non_prod_env IN   BOOLEAN DEFAULT FALSE
      ,p_mail_id    IN mails.mail_id%TYPE DEFAULT NULL
      ,p_log_mail   IN BOOLEAN DEFAULT FALSE
      )
   IS
      l_conn       sys.UTL_SMTP.CONNECTION;   
      -- transforming CLOB a BLOB
      l_off        NUMBER DEFAULT 1;
      l_amt        NUMBER DEFAULT 1024;
      l_str        g_long_string_type;  
   BEGIN
      -- Check if we are in PROD or not
      -- If we get an error while retrieving the value we assume we are not in PROD
      set_is_prod();

      -- Set the parameter values
      set_sender(p_sender);
      set_recipients(p_recipients);
      set_cc(p_cc);
      set_bcc(p_bcc);      
      set_subject(p_subject);
      set_message_ov32k(p_message);
      set_mime_type('text/plain; charset=utf8'); -- text/plain; charset=us-ascii
      set_priority(p_priority);
      set_force_send_on_non_prod_env(p_force_send_on_non_prod_env);
      sys.dbms_output.put_line ('recipient='||mail_utility_var.g_recipients);
      -- BY default we only want to sent emails on PROD and not on test environements
      -- so if we want to send mail on test environement p_force_send_on_non_prod_env needs to be set by the developer

      IF check_prod_or_force_send THEN
         l_conn := begin_session;
         begin_mail_in_session(l_conn
                              ,mail_utility_var.g_sender
                              ,mail_utility_var.g_recipients
                              ,mail_utility_var.g_cc
                              ,mail_utility_var.g_bcc
                              ,mail_utility_var.g_subject
                              ,mail_utility_var.g_mime_type
                              ,mail_utility_var.g_priority
                              );                       

         write_mb_text(pio_conn=>l_conn, p_message=>p_message/*mail_utility_var.g_message_ov32k*/);

         end_mail(pio_conn=>l_conn);
      END IF;
      save_and_log_mail(p_sender=>p_sender
                       ,p_recipients=>p_recipients
                       ,p_cc=>p_cc
                       ,p_bcc=>p_bcc
                       ,p_subject=>p_subject
                       ,p_message=>p_message
                       ,p_mail_mime_type=>'text/plain; charset=utf8'
                       ,p_priority=>p_priority
                       ,p_clob_attachment=>NULL
                       ,p_raw_attachment=>NULL
                       ,p_attachment_mime_type=>NULL
                       ,p_att_filename=>NULL
                       ,p_transfer_enc=>NULL
                       ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                       ,p_att_inline=>NULL
                       ,p_mail_status=> 'SENT'
                       ,p_operation=>'SEND'
                       ,p_log_status=>'SUCCEEDED'
                       ,p_additional_info=>NULL
                       ,p_typ_id=>mail_utility_var.gk_typ_over_32k
                       ,p_mail_id=>p_mail_id
                       ,p_log_mail=>p_log_mail
                       );
   EXCEPTION
      WHEN OTHERS THEN
         save_and_log_mail(p_sender=>p_sender
                          ,p_recipients=>p_recipients
                          ,p_cc=>p_cc
                          ,p_bcc=>p_bcc
                          ,p_subject=>p_subject
                          ,p_message=>p_message
                          ,p_mail_mime_type=>'text/plain; charset=utf8'
                          ,p_priority=>p_priority
                          ,p_clob_attachment=>NULL
                          ,p_raw_attachment=>NULL
                          ,p_attachment_mime_type=>NULL
                          ,p_att_filename=>NULL
                          ,p_transfer_enc=>NULL
                          ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                          ,p_att_inline=>NULL
                          ,p_mail_status=> 'NOT SENT'
                          ,p_operation=>'SEND'
                          ,p_log_status=>'FAILED'
                          ,p_additional_info=>NULL
                          ,p_typ_id=>mail_utility_var.gk_typ_over_32k
                          ,p_mail_id=>p_mail_id
                          ,p_log_mail=>p_log_mail
                          );
         raise_app_error(SQLERRM);    
   END send_mail_over32k;     

   FUNCTION c2b (p_clob IN CLOB) 
   RETURN BLOB
   IS
      l_blob BLOB; 
      l_lang_context INTEGER := 0;
      l_dest_offset INTEGER := 1;
      l_src_offset INTEGER := 1;
      l_blob_csid INTEGER := 0;
      l_warning INTEGER;
   BEGIN
      sys.dbms_lob.createtemporary(l_blob, FALSE);
      sys.dbms_lob.converttoblob(dest_lob=>l_blob
                                ,src_clob=>p_clob
                                ,amount=>sys.dbms_lob.getlength(p_clob)
                                ,dest_offset=>l_dest_offset
                                ,src_offset=>l_src_offset
                                ,blob_csid=>l_blob_csid
                                ,lang_context=>l_lang_context
                                ,warning=>l_warning);
      RETURN l_blob;
   END c2b;

   ---
   -- Base64 encoding of attachment
   ---       
   -- DOC ID:  How To Send Multiple Attachments Of Size Greater Than 32 KB Using UTL_SMTP Package (Doc ID 357385.1)	 
   -- "... we can use the fact that Base64 encoding creates files with 76 byte fixed length records to get around this. When data is Base64 encoded, the resulting data is larger than the original by a factor of 4/3 
   --.  If we therefore process input data in 57 bytes chunks, then the resulting data will be a series of 76 byte records which will be readable by third party decoders."
   ---

   PROCEDURE attach_base64 (
      pio_conn IN OUT NOCOPY sys.utl_smtp.connection
     ,p_attachment IN BLOB
   )
   IS
      l_amt BINARY_INTEGER := 672 * 3; /* ensures proper format; 2016 */
      l_filepos PLS_INTEGER := 1; /* pointer for the file */
      l_chunks PLS_INTEGER;
      l_modulo PLS_INTEGER;
      l_pieces PLS_INTEGER;
      l_file_len PLS_INTEGER;
      l_data g_raw_type;
      l_buf g_raw_type;
      l_i integer;
      lk_max_line_width CONSTANT PLS_INTEGER := 54;  -- 76 * 3 / 4
   BEGIN
      l_filepos := 1; /* Insures we are pointing to beginning of file. */
      l_amt := 672 * 3; /* Insures amount is re-initialize for each file */
      l_file_len := sys.dbms_lob.getlength(p_attachment);
      l_modulo := MOD(l_file_len, l_amt);
      l_pieces := TRUNC(l_file_len / l_amt);
      IF (l_modulo <> 0) THEN
         l_pieces := l_pieces + 1;
      END IF;
      sys.dbms_lob.read(p_attachment, l_amt, l_filepos, l_buf);
      l_data := NULL;
      FOR l_i IN 1..l_pieces LOOP
         l_filepos := l_i * l_amt + 1;
         l_file_len := l_file_len - l_amt;
         l_data := sys.utl_raw.concat(l_data, l_buf);
         l_chunks := TRUNC(sys.utl_raw.LENGTH(l_data) / lk_max_line_width);
         IF (l_i <> l_pieces) THEN
            l_chunks := l_chunks - 1;
         END IF;
         -- write data
         sys.utl_smtp.write_raw_data(pio_conn, sys.utl_encode.base64_encode(l_data)); 
         l_data := NULL;
         IF (l_file_len < l_amt AND l_file_len > 0) THEN
            l_amt := l_file_len;
         END IF;
         IF l_file_len <> 0 THEN
            sys.dbms_lob.read(p_attachment, l_amt, l_filepos, l_buf);
         END IF;
      END LOOP;
   END attach_base64;

   PROCEDURE send_mail_attach_text_over32k 
      (p_sender       IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_recipients   IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_cc           IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_bcc          IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_subject      IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
      ,p_message      IN CLOB CHARACTER SET ANY_CS
      ,p_priority     IN PLS_INTEGER DEFAULT 3
      ,p_attachment   IN CLOB CHARACTER SET ANY_CS
      ,p_att_filename IN VARCHAR2 DEFAULT NULL
      ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
      ,p_transfer_enc IN VARCHAR2 DEFAULT NULL
      ,p_mail_id      IN mails.mail_id%TYPE DEFAULT NULL
      ,p_log_mail     IN BOOLEAN DEFAULT FALSE
      )
   IS
      l_conn       sys.UTL_SMTP.CONNECTION;   
      -- transforming CLOB a BLOB
      l_off          NUMBER DEFAULT 1;
      l_amt          NUMBER DEFAULT 1024;
      l_amtWrite     NUMBER;
      l_str          g_long_string_type;  
      k_base64_enc   CONSTANT mail_utility_var.g_short_code_type := 'base64';
      l_mail_id      mails.mail_id%TYPE := p_mail_id;
      l_cnt_attempts INTEGER;
   BEGIN
      -- Check if we are in PROD or not
      -- If we get an error while retrieving the value we assume we are not in PROD
      set_is_prod();

      -- Set the parameter values
      set_sender(p_sender);
      set_recipients(p_recipients);
      set_cc(p_cc);
      set_bcc(p_bcc);      
      set_subject(p_subject);
      set_message_ov32k(p_message);
      set_mime_type(mail_utility_var.gk_smtp_multipart_mime_type);
      set_priority(p_priority);
      set_att_inline(FALSE);
      --set_att_mime_type(mail_utility_var.g_smtp_att_mime_type);
      set_att_filename(p_att_filename);
      set_force_send_on_non_prod_env(p_force_send_on_non_prod_env);

      -- BY default we only want to sent emails on PROD and not on test environements
      -- so if we want to send mail on test environement p_force_send_on_non_prod_env needs to be set by the developer      
      IF check_prod_or_force_send THEN
         l_conn := begin_session;
         begin_mail_in_session(l_conn
                              ,mail_utility_var.g_sender
                              ,mail_utility_var.g_recipients
                              ,mail_utility_var.g_cc
                              ,mail_utility_var.g_bcc
                              ,mail_utility_var.g_subject
                              ,mail_utility_var.g_mime_type
                              ,mail_utility_var.g_priority
                              );                       

         sys.UTL_SMTP.WRITE_DATA(l_conn,mail_utility_var.gk_smtp_first_boundary);

         write_mime_header(l_conn, 'Content-type', mail_utility_var.gk_smtp_body_mime_type);
         sys.UTL_SMTP.WRITE_DATA(l_conn, sys.UTL_TCP.CRLF);

         write_mb_text(pio_conn=>l_conn, p_message=>mail_utility_var.g_message_ov32k);
         -- to separate body from attachment
         sys.UTL_SMTP.WRITE_DATA(l_conn, sys.UTL_TCP.CRLF);

         begin_attachment(pio_conn=>l_conn
                         ,p_mime_type=>mail_utility_var.gk_smtp_att_mime_type
                         ,p_att_inline =>mail_utility_var.g_att_inline
                         ,p_filename =>mail_utility_var.g_att_filename
                         ,p_transfer_enc => p_transfer_enc
                         );
         -- base64 encoding if required
         IF p_transfer_enc = k_base64_enc THEN 
            attach_base64(pio_conn=>l_conn, p_attachment=>c2b(p_attachment));
         ELSE
            write_mb_text(pio_conn=>l_conn, p_message=>p_attachment);
         END IF;                      

         end_attachment(l_conn, TRUE);
         end_mail(pio_conn=>l_conn);
      END IF;
      save_and_log_mail(p_sender=>p_sender
                       ,p_recipients=>p_recipients
                       ,p_cc=>p_cc
                       ,p_bcc=>p_bcc
                       ,p_subject=>p_subject
                       ,p_message=>p_message
                       ,p_mail_mime_type=>mail_utility_var.gk_smtp_multipart_mime_type
                       ,p_priority=>p_priority
                       ,p_clob_attachment=>p_attachment
                       ,p_raw_attachment=>NULL
                       ,p_attachment_mime_type=>mail_utility_var.gk_smtp_att_mime_type
                       ,p_att_filename=>p_att_filename
                       ,p_transfer_enc=>p_transfer_enc
                       ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                       ,p_att_inline=>NULL
                       ,p_mail_status=> 'SENT'
                       ,p_operation=>'SEND'
                       ,p_log_status=>'SUCCEEDED'
                       ,p_additional_info=>NULL
                       ,p_typ_id=>mail_utility_var.gk_typ_text_attachment_over_32k
                       ,p_mail_id=>p_mail_id
                       ,p_log_mail=>p_log_mail
                       );
   EXCEPTION
      WHEN OTHERS THEN
         save_and_log_mail(p_sender=>p_sender
                          ,p_recipients=>p_recipients
                          ,p_cc=>p_cc
                          ,p_bcc=>p_bcc
                          ,p_subject=>p_subject
                          ,p_message=>p_message
                          ,p_mail_mime_type=>mail_utility_var.gk_smtp_multipart_mime_type
                          ,p_priority=>p_priority
                          ,p_clob_attachment=>p_attachment
                          ,p_raw_attachment=>NULL
                          ,p_attachment_mime_type=>mail_utility_var.gk_smtp_att_mime_type
                          ,p_att_filename=>p_att_filename
                          ,p_transfer_enc=>p_transfer_enc
                          ,p_force_send_on_non_prod_env=>p_force_send_on_non_prod_env
                          ,p_att_inline=>NULL
                          ,p_mail_status=> 'NOT SENT'
                          ,p_operation=>'SEND'
                          ,p_log_status=>'FAILED'
                          ,p_additional_info=>NULL
                          ,p_typ_id=>mail_utility_var.gk_typ_text_attachment_over_32k
                          ,p_mail_id=>p_mail_id
                          ,p_log_mail=>p_log_mail
                          ); 
         raise_app_error(SQLERRM);    
   END send_mail_attach_text_over32k;     

   PROCEDURE resend_mail
   IS
      CURSOR c_mail
          IS 
      SELECT mail.*
        FROM mails mail
      WHERE mail.status = 'NOT SENT';  
      TYPE t_mail_type IS TABLE OF c_mail%ROWTYPE INDEX BY BINARY_INTEGER;
      t_mails t_mail_type;
   BEGIN
      OPEN c_mail;
      FETCH c_mail BULK COLLECT INTO t_mails;
      CLOSE c_mail;   
      FOR i IN 1..t_mails.COUNT LOOP
         IF t_mails(i).typ_id = mail_utility_var.gk_typ_basic THEN
            send_mail
                (p_sender=>t_mails(i).mail_from
                ,p_recipients=>t_mails(i).mail_to
                ,p_cc=>t_mails(i).cc
                ,p_bcc=>t_mails(i).bcc
                ,p_subject=>t_mails(i).subject
                ,p_message=>t_mails(i).content
                ,p_mime_type=>t_mails(i).mail_mime_type
                ,p_priority=>t_mails(i).priority
                ,p_force_send_on_non_prod_env=>CASE WHEN t_mails(i).force_send_flag = 'Y' THEN TRUE ELSE  FALSE END
                ,p_mail_id=>t_mails(i).mail_id
                ,p_log_mail=>TRUE
                );
         ELSIF t_mails(i).typ_id = mail_utility_var.gk_typ_raw_attachment THEN
            send_mail_attach_raw
                (p_sender=>t_mails(i).mail_from
                ,p_recipients=>t_mails(i).mail_to
                ,p_cc=>t_mails(i).cc
                ,p_bcc=>t_mails(i).bcc
                ,p_subject=>t_mails(i).subject
                ,p_message=>t_mails(i).content
                ,p_mime_type=>t_mails(i).mail_mime_type
                ,p_priority=>t_mails(i).priority
                ,p_attachment=>t_mails(i).raw_attachment
                ,p_att_inline=>CASE WHEN t_mails(i).inline_attachment_flag = 'Y' THEN TRUE WHEN t_mails(i).inline_attachment_flag='N' THEN FALSE END
                ,p_att_mime_type=>t_mails(i).attachment_mime_type
                ,p_att_filename=>t_mails(i).attachment_file_name
                ,p_force_send_on_non_prod_env=>CASE WHEN t_mails(i).force_send_flag = 'Y' THEN TRUE ELSE  FALSE END
                ,p_mail_id=>t_mails(i).mail_id
                ,p_log_mail=>TRUE
                );        
         ELSIF t_mails(i).typ_id = mail_utility_var.gk_typ_text_attachment THEN
            send_mail_attach_text
                (p_sender=>t_mails(i).mail_from
                ,p_recipients=>t_mails(i).mail_to
                ,p_cc=>t_mails(i).cc
                ,p_bcc=>t_mails(i).bcc
                ,p_subject=>t_mails(i).subject
                ,p_message=>t_mails(i).content
                ,p_mime_type=>t_mails(i).mail_mime_type
                ,p_attachment=>t_mails(i).clob_attachment
                ,p_att_inline=>CASE WHEN t_mails(i).inline_attachment_flag = 'Y' THEN TRUE WHEN t_mails(i).inline_attachment_flag='N' THEN FALSE END
                ,p_att_mime_type=>t_mails(i).attachment_mime_type
                ,p_att_filename=>t_mails(i).attachment_file_name
                ,p_priority=>t_mails(i).priority
                ,p_force_send_on_non_prod_env=>CASE WHEN t_mails(i).force_send_flag = 'Y' THEN TRUE ELSE  FALSE END
                ,p_mail_id=>t_mails(i).mail_id
                ,p_log_mail=>TRUE
                );                                                
         ELSIF t_mails(i).typ_id = mail_utility_var.gk_typ_over_32k THEN
            send_mail_over32k
                (p_sender=>t_mails(i).mail_from
                ,p_recipients=>t_mails(i).mail_to
                ,p_cc=>t_mails(i).cc
                ,p_bcc=>t_mails(i).bcc
                ,p_subject=>t_mails(i).subject
                ,p_message=>t_mails(i).content
                ,p_priority=>t_mails(i).priority
                ,p_force_send_on_non_prod_env=>CASE WHEN t_mails(i).force_send_flag = 'Y' THEN TRUE ELSE  FALSE END
                ,p_mail_id=>t_mails(i).mail_id
                ,p_log_mail=>TRUE
                );
         ELSIF t_mails(i).typ_id = mail_utility_var.gk_typ_text_attachment_over_32k THEN
            send_mail_attach_text_over32k
                (p_sender=>t_mails(i).mail_from
                ,p_recipients=>t_mails(i).mail_to
                ,p_cc=>t_mails(i).cc
                ,p_bcc=>t_mails(i).bcc
                ,p_subject=>t_mails(i).subject
                ,p_message=>t_mails(i).content
                ,p_priority=>t_mails(i).priority
                ,p_attachment=>t_mails(i).clob_attachment
                ,p_att_filename=>t_mails(i).attachment_file_name
                ,p_force_send_on_non_prod_env=>CASE WHEN t_mails(i).force_send_flag = 'Y' THEN TRUE ELSE  FALSE END
                ,p_transfer_enc=>t_mails(i).content_transfer_encoding
                ,p_mail_id=>t_mails(i).mail_id
                ,p_log_mail=>TRUE
                );  
         END IF;       
      END LOOP;
   END resend_mail;  
END mail_utility_krn;
/