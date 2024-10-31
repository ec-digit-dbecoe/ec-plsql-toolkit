CREATE OR REPLACE PACKAGE mail_utility_var
ACCESSIBLE BY (mail_utility_krn)
AS
   SUBTYPE g_big_list_type IS VARCHAR2(32767);
   SUBTYPE g_short_string_type IS VARCHAR2(256 CHAR);
   SUBTYPE g_short_code_type IS VARCHAR2(15 CHAR);

   --  Main constants
   gk_default_sender  CONSTANT g_short_string_type := 'DBCC <automated-notifications@nomail.ec.europa.eu>'; 
   -- Change this to TRUE and recompile mail_utility_krn to enable debug output.
   gk_debug           CONSTANT BOOLEAN := FALSE;
   --mail types
   gk_typ_basic                    CONSTANT PLS_INTEGER := 1;
   gk_typ_raw_attachment           CONSTANT PLS_INTEGER := 2;
   gk_typ_text_attachment          CONSTANT PLS_INTEGER := 3;
   gk_typ_over_32k                 CONSTANT PLS_INTEGER := 4;
   gk_typ_text_attachment_over_32k CONSTANT PLS_INTEGER := 5;
   
   /*
      Misc global variables
   */
   g_is_prod BOOLEAN DEFAULT FALSE;

   /*  global constants for UTL_SMTP usage
   */
   -- Customize the SMTP host, port and your domain name below.
   g_smtp_host                 g_short_string_type := 'localhost'; --'smtpmail.cec.eu.int'; --'internal-smtp.cec.eu.int';
   g_smtp_port                 PLS_INTEGER := 25;
   g_smtp_domain               g_short_string_type := 'cec.eu.int';
   gk_smtp_boundary            CONSTANT g_short_string_type := '----7D81B75CCC90D2974F7A1CBD';
   gk_smtp_first_boundary      CONSTANT g_short_string_type := '--' || gk_smtp_boundary || sys.UTL_TCP.CRLF;
   gk_smtp_last_boundary       CONSTANT g_short_string_type := '--' || gk_smtp_boundary || '--' ||sys.UTL_TCP.CRLF;
   -- A MIME type that denotes multi-part email (MIME) messages.
   gk_smtp_multipart_mime_type CONSTANT g_short_string_type := 'multipart/mixed; boundary="' || gk_smtp_boundary || '"';
   gk_smtp_att_mime_type       CONSTANT g_short_string_type := 'text/plain';
   gk_smtp_body_mime_type 	    CONSTANT g_short_string_type := 'text/plain; charset="utf8"';
   -- attachment encoding
   gk_smtp_trf_encoding		    CONSTANT g_short_code_type := 'base64';
   
   -- developers related
   g_developer_recipient g_big_list_type;
   g_developer_cc        g_big_list_type;
   g_developer_bcc       g_big_list_type;


   /*
      Mail global variables
   */
   g_sender                             g_short_string_type;
   g_recipients                         g_big_list_type;
   g_cc                                 g_big_list_type;
   g_bcc                                g_big_list_type;
   g_subject                            g_big_list_type;
   g_message                            g_big_list_type;
   g_message_ov32k                      CLOB;
   g_mime_type                          g_short_string_type;
   g_priority                           PLS_INTEGER;
   g_force_send_on_non_prod_env         BOOLEAN;
   g_att_inline                         BOOLEAN;
   g_att_mime_type                      g_short_string_type;
   g_att_filename                       g_short_string_type;

   -- max number of trials, can be overwritten
   g_max_trials PLS_INTEGER := 3;
   --

END mail_utility_var;
/