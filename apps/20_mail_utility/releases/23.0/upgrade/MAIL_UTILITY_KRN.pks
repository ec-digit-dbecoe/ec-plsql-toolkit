create or replace PACKAGE mail_utility_krn AS
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
/**************************************************************************************************************
 *													      * 
 * References: http://support.oracle.com 								      *		
 * -----------												      *
 * How To Send Multiple Attachments Of Size Greater Than 32 KB Using UTL_SMTP Package (Doc ID 357385.1)	      *
 * Handling Large Files Using UTL_ENCODE.BASE64_ENCODE / DECODE (Doc ID 469064.1)			      *
 * How to Use DBMS_LOB with UTL_ENCODE to Work With BASE64 Data (Doc ID 605173.1)			      *	
 *												              * 
 **************************************************************************************************************


   /*
      Procedure to raise fatal errors
   */
   PROCEDURE raise_app_error( p_text IN VARCHAR2 )
   ;

   /*
      returns the developer recipient
   */
   FUNCTION get_developer_recipient
   RETURN mail_utility_var.g_big_list_type;

   /*
      sets the developer recipient
   */
   PROCEDURE set_developer_recipient(p_developer_recipient mail_utility_var.g_big_list_type);
   
   /*
      returns the developer cc
   */
   FUNCTION get_developer_cc
   RETURN mail_utility_var.g_big_list_type;

   /*
      sets the developer cc
   */
   PROCEDURE set_developer_cc(p_developer_cc mail_utility_var.g_big_list_type);

   /*
      returns the developer bcc
   */
   FUNCTION get_developer_bcc
   RETURN mail_utility_var.g_big_list_type;

   /*
      sets the developer bcc
   */
   PROCEDURE set_developer_bcc(p_developer_bcc mail_utility_var.g_big_list_type);

   /*
      Procedure to establish to determine if the environment is production
   */
   PROCEDURE set_is_prod (
      p_prod_value IN VARCHAR2 := NULL -- Y/N/NULL=determine
   )
   ;

   /*
      Procedure to set the sender and perform checks on it
   */
   PROCEDURE set_sender(p_sender IN VARCHAR2)
   ;

   /*
      Procedure to set the recipients and perform checks on it
   */
   PROCEDURE set_recipients(p_recipients IN VARCHAR2)
   ;

   /*
      Procedure to set the cc and perform checks on it
   */
   PROCEDURE set_cc(p_cc IN VARCHAR2)
   ;

   /*
      Procedure to set the bcc and perform checks on it
   */
   PROCEDURE set_bcc(p_bcc IN VARCHAR2)
   ;

   /*
      Procedure to set the subject and perform checks on it
   */
   PROCEDURE set_subject(p_subject IN VARCHAR2)
   ;

   /*
      Procedure to set the message and perform checks on it
   */
   PROCEDURE set_message(p_message IN VARCHAR2)
   ;

   /*
      Procedure to set the mime_type and perform checks on it
   */
   PROCEDURE set_mime_type(p_mime_type IN VARCHAR2)
   ;

   /*
      Procedure to set the att_mime_type and perform checks on it
   */
   PROCEDURE set_att_mime_type(p_att_mime_type IN VARCHAR2)
   ;

   /*
      Procedure to set the priority and perform checks on it
   */
   PROCEDURE set_priority(p_priority IN PLS_INTEGER)
   ;

   /*
      Procedure to set if the attachment is added inline or not
   */
   PROCEDURE set_att_inline(p_att_inline IN BOOLEAN)
   ;

   /*
      Procedure to set the file name of the attachment
   */
   PROCEDURE set_att_filename(p_att_filename IN VARCHAR2)
   ;

   /*
      Procedure to set the force send flag and perform checks on it
      The main reason for this variable is to make it harder to send emails outside of production environement
      to avoid sending test mails
   */
   PROCEDURE set_force_send_on_non_prod_env(p_force_send_on_non_prod_env IN BOOLEAN)
   ;

   /*
      Function to check if we are in prod or force send is enabled
   */
   FUNCTION check_prod_or_force_send
   RETURN BOOLEAN;

   /*
      Procedure to send emails, it uses the utl_mail package to send emails
   */
   PROCEDURE send_mail(
      p_sender     IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_recipients IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_cc         IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_bcc        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_subject    IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_message    IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_mime_type  IN VARCHAR2 DEFAULT 'text/plain; charset=us-ascii'
     ,p_priority   IN PLS_INTEGER DEFAULT 3
     ,p_force_send_on_non_prod_env IN   BOOLEAN DEFAULT FALSE
     ,p_mail_id    IN mails.mail_id%TYPE DEFAULT NULL
     ,p_log_mail   IN BOOLEAN DEFAULT FALSE
   );

   /*
      Procedure to send emails with raw attachements, it uses the utl_mail package to send emails
   */
   PROCEDURE send_mail_attach_raw (
      p_sender        IN VARCHAR2 CHARACTER SET ANY_CS
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
   );

   /*
      Procedure to send emails with text attachements, it uses the utl_mail package to send emails, limited in size to 32k
   */
   PROCEDURE send_mail_attach_text (
      p_sender        IN VARCHAR2 CHARACTER SET ANY_CS
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
   );

   /* procedure to send mail without attachment, which uses UTL_SMTP instead of UTL_MAIL which is limited to 32KB mail */
  PROCEDURE send_mail_over32k(
      p_sender     IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_recipients IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_cc         IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_bcc        IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_subject    IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_message    IN CLOB CHARACTER SET ANY_CS
     ,p_priority   IN PLS_INTEGER DEFAULT 3
     ,p_force_send_on_non_prod_env IN   BOOLEAN DEFAULT FALSE
     ,p_mail_id    IN mails.mail_id%TYPE DEFAULT NULL
     ,p_log_mail   IN BOOLEAN DEFAULT FALSE
   );

   /* procedure o send mail with attachment,which uses UTL_SMTP instead of UTL_MAIL which is limited to 32KB mail and attachment */
   PROCEDURE send_mail_attach_text_over32k (
      p_sender       IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_recipients   IN VARCHAR2 CHARACTER SET ANY_CS
     ,p_cc           IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_bcc          IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_subject      IN VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL
     ,p_message      IN CLOB CHARACTER SET ANY_CS
     ,p_priority     IN PLS_INTEGER DEFAULT 3
     ,p_attachment   IN CLOB CHARACTER SET ANY_CS
     ,p_att_filename IN VARCHAR2 DEFAULT NULL
     ,p_force_send_on_non_prod_env IN BOOLEAN DEFAULT FALSE
     ,p_transfer_enc	IN VARCHAR2 DEFAULT NULL
     ,p_mail_id      IN mails.mail_id%TYPE DEFAULT NULL
     ,p_log_mail     IN BOOLEAN DEFAULT FALSE
     );

   /* procedure which retrieves from the database all emails for which the send failed and tries to resend
    * if maximum number of attempts is reached, the email is archived
   */
   PROCEDURE resend_mail;
END mail_utility_krn;
/