CREATE OR REPLACE PACKAGE BODY mail_utility_tst AS
   /*
      Procedure to print out result
   */
   PROCEDURE printMessage(p_message IN VARCHAR2) IS
   BEGIN
     sys.DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY/MM/DD HH24:MI:SS:FF3') || ': ' || p_message);
   END printMessage;

   /*
      Procedure to test set_is_prod
   */
   PROCEDURE test_set_is_prod
   IS
   BEGIN
      printMessage('Test set_is_prod:');
   END test_set_is_prod;

   /*
      Procedure to test set_sender
   */
   PROCEDURE test_set_sender
   IS
   BEGIN
      printMessage('Test set_sender:');
      -- Check default behavior when no value is given
      mail_utility_krn.set_sender(NULL);
      IF mail_utility_var.g_sender = mail_utility_var.k_default_sender THEN
         printMessage('Test "Default sender" => OK');
      ELSE
         printMessage('Test "Default sender" FAILED : wrong sender. Expected ' || mail_utility_var.k_default_sender || ' but was ' || mail_utility_var.g_sender || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_sender('test_sender@test.com');
      IF mail_utility_var.g_sender = 'test_sender@test.com' THEN
         printMessage('Test "sender" => OK');
      ELSE
         printMessage('Test "sender" FAILED : wrong sender. Expected "test_sender@test.com" but was ' || mail_utility_var.g_sender);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_sender;

   /*
      Procedure to test set_recipients
   */
   PROCEDURE test_set_recipients
   IS
   BEGIN
      printMessage('Test set_recipients:');
      mail_utility_var.g_developer_recipient := 'developer@test.com';
      -- Check when no value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_recipients(NULL);
      IF mail_utility_var.g_recipients = mail_utility_var.g_developer_recipient THEN
         printMessage('Test "Empty recipients + not in Prod" => OK');
      ELSE
         printMessage('Test "Empty recipients + not in Prod" FAILED : wrong recipient. Expected developer recipient(s) ' || mail_utility_var.g_developer_recipient || ' but was ' || mail_utility_var.g_recipients || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_recipients('test_recipient@test.com');
      IF mail_utility_var.g_recipients = mail_utility_var.g_developer_recipient THEN
         printMessage('Test "Recipients + not in Prod" => OK');
      ELSE
         printMessage('Test "Recipients + not in Prod" FAILED : wrong recipient. Expected developer recipient(s) ' || mail_utility_var.g_developer_recipient || ' but was ' || mail_utility_var.g_recipients || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when no value is given and we are in production
      BEGIN
         mail_utility_var.g_is_prod := TRUE;
         mail_utility_krn.set_recipients(NULL);
         printMessage('Test "Empty recipients + in Prod" FAILED : wrong recipient. Expected no recipient(s) but was ' || mail_utility_var.g_recipients || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      EXCEPTION
         WHEN OTHERS THEN
            printMessage('Test "Empty recipients + in Prod" => OK');
      END;

      -- Check if given value is set correctly when in production
      mail_utility_var.g_is_prod := TRUE;
      mail_utility_krn.set_recipients('test_recipient@test.com');
      IF mail_utility_var.g_recipients = 'test_recipient@test.com' THEN
         printMessage('Test "recipients + in Prod" => OK');
      ELSE
         printMessage('Test "recipients" FAILED : wrong sender. Expected "test_recipient@test.com" but was ' || mail_utility_var.g_recipients);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_recipients;

   /*
      Procedure to test set_cc
   */
   PROCEDURE test_set_cc
   IS
   BEGIN
      printMessage('Test set_cc:');
      -- Check when no value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_cc(NULL);
      IF NVL(mail_utility_var.g_cc, -999999) = NVL(mail_utility_var.g_developer_cc, -999999) THEN
         printMessage('Test "Empty cc + not in Prod" => OK');
      ELSE
         printMessage('Test "Empty cc + not in Prod" FAILED : wrong cc. Expected developer cc ' || mail_utility_var.g_developer_cc || ' but was ' || mail_utility_var.g_cc || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_cc('test_cc@test.com');
      IF NVL(mail_utility_var.g_cc, -999999) = NVL(mail_utility_var.g_developer_cc, -999999) THEN
         printMessage('Test "cc + not in Prod" => OK');
      ELSE
         printMessage('Test "cc + not in Prod" FAILED : wrong cc. Expected developer cc ' || mail_utility_var.g_developer_cc || ' but was ' || mail_utility_var.g_cc || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when no value is given and we are in production
      mail_utility_var.g_is_prod := TRUE;
      mail_utility_var.g_cc := 'should.be.reset@next.call';
      mail_utility_krn.set_cc(NULL);
      IF mail_utility_var.g_cc IS NULL THEN
         printMessage('Test "Empty cc + in Prod" => OK');
      ELSE
         printMessage('Test "Empty cc + in Prod" FAILED : wrong cc. Expected empty cc but was ' || mail_utility_var.g_cc || '.');
      END IF;

      -- Check if given value is set correctly when in production
      mail_utility_var.g_is_prod := TRUE;
      mail_utility_krn.set_cc('test_cc@test.com');
      IF mail_utility_var.g_cc = 'test_cc@test.com' THEN
         printMessage('Test "cc + in Prod" => OK');
      ELSE
         printMessage('Test "cc + in Prod" FAILED : wrong sender. Expected "test_cc@test.com" but was ' || mail_utility_var.g_cc);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_cc;

   /*
      Procedure to test set_bcc
   */
   PROCEDURE test_set_bcc
   IS
   BEGIN
      printMessage('Test set_bcc:');
      -- Check when no value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_bcc(NULL);
      IF NVL(mail_utility_var.g_bcc, -999999) = NVL(mail_utility_var.g_developer_bcc, -999999) THEN
         printMessage('Test "Empty bcc + not in Prod" => OK');
      ELSE
         printMessage('Test "Empty bcc + not in Prod" FAILED : wrong bcc. Expected developer bcc ' || mail_utility_var.g_developer_bcc || ' but was ' || mail_utility_var.g_bcc || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when value is given and we are not in production
      mail_utility_var.g_is_prod := FALSE;
      mail_utility_krn.set_bcc('test_bcc@test.com');
      IF NVL(mail_utility_var.g_bcc, -999999) = NVL(mail_utility_var.g_developer_bcc, -999999) THEN
         printMessage('Test "bcc + not in Prod" => OK');
      ELSE
         printMessage('Test "bcc + not in Prod" FAILED : wrong bcc. Expected developer bcc ' || mail_utility_var.g_developer_bcc || ' but was ' || mail_utility_var.g_bcc || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check when no value is given and we are in production
      mail_utility_var.g_is_prod := TRUE;
      mail_utility_var.g_bcc := 'should.be.reset@next.call';
      mail_utility_krn.set_bcc(NULL);
      IF mail_utility_var.g_bcc IS NULL THEN
         printMessage('Test "Empty bcc + in Prod" => OK');
      ELSE
         printMessage('Test "Empty bcc + in Prod" FAILED : wrong bcc. Expected empty bcc but was ' || mail_utility_var.g_bcc || '.');
      END IF;

      -- Check if given value is set correctly when in production
      mail_utility_var.g_is_prod := TRUE;
      mail_utility_krn.set_bcc('test_bcc@test.com');
      IF mail_utility_var.g_bcc = 'test_bcc@test.com' THEN
         printMessage('Test "bcc + in Prod" => OK');
      ELSE
         printMessage('Test "bcc + in Prod" FAILED : wrong sender. Expected "test_bcc@test.com" but was ' || mail_utility_var.g_bcc);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_bcc;

   /*
      Procedure to test set_subject
   */
   PROCEDURE test_set_subject
   IS
   BEGIN
      printMessage('Test set_subject:');
      -- Check default behavior when no value is given
      BEGIN
         mail_utility_krn.set_subject(NULL);
         printMessage('Test "Empty subject" FAILED : wrong subject. Expected no subject but was ' || mail_utility_var.g_subject);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      EXCEPTION
         WHEN OTHERS THEN
            printMessage('Test "Empty subject" => OK');
      END;

      -- Check if given value is set correctly
      mail_utility_krn.set_subject('This is a test subject');
      IF mail_utility_var.g_subject = 'This is a test subject' THEN
         printMessage('Test "Subject" => OK');
      ELSE
         printMessage('Test "Subject" FAILED : wrong subject. Expected "This is a test subject" but was ' || mail_utility_var.g_subject);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_subject;

   /*
      Procedure to test set_message
   */
   PROCEDURE test_set_message
   IS
   BEGIN
      printMessage('Test set_message:');
      -- Check default behavior when no value is given
      BEGIN
         mail_utility_krn.set_message(NULL);
         printMessage('Test "Empty message" FAILED : wrong message. Expected no message but was ' || mail_utility_var.g_message);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      EXCEPTION
         WHEN OTHERS THEN
            printMessage('Test "Empty message" => OK');
      END;

      -- Check if given value is set correctly
      mail_utility_krn.set_message('This is a test message');
      IF mail_utility_var.g_message = 'This is a test message' THEN
         printMessage('Test "Message" => OK');
      ELSE
         printMessage('Test "Message" FAILED : wrong message. Expected "This is a test message" but was ' || mail_utility_var.g_message);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_message;

   /*
      Procedure to test set_mime_type
   */
   PROCEDURE test_set_mime_type
   IS
   BEGIN
      printMessage('Test set_mime_type:');

      -- Check if given value is set correctly
      mail_utility_krn.set_mime_type('test_mime_type');
      IF mail_utility_var.g_mime_type = 'test_mime_type' THEN
         printMessage('Test "mime type" => OK');
      ELSE
         printMessage('Test "mime type" FAILED : wrong mime type. Expected "test_mime_type" but was ' || mail_utility_var.g_mime_type);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_mime_type;

   /*
      Procedure to test set_att_mime_type
   */
   PROCEDURE test_set_att_mime_type
   IS
   BEGIN
      printMessage('Test set_att_mime_type:');

      -- Check if given value is set correctly
      mail_utility_krn.set_att_mime_type('test_att_mime_type');
      IF mail_utility_var.g_att_mime_type = 'test_att_mime_type' THEN
         printMessage('Test "att mime type" => OK');
      ELSE
         printMessage('Test "att mime type" FAILED : wrong mime type. Expected "test_att_mime_type" but was ' || mail_utility_var.g_att_mime_type);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_att_mime_type;

   /*
      Procedure to test set_priority
   */
   PROCEDURE test_set_priority
   IS
   BEGIN
      printMessage('Test set_priority:');
      -- Check default behavior when no value is given
      mail_utility_krn.set_priority(NULL);
      IF mail_utility_var.g_priority = 3 THEN
         printMessage('Test "Default priority" => OK');
      ELSE
         printMessage('Test "Default priority" FAILED : wrong priority. Expected 3 but was ' || mail_utility_var.g_priority || '.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_priority(1);
      IF mail_utility_var.g_priority = 1 THEN
         printMessage('Test "priority" => OK');
      ELSE
         printMessage('Test "priority" FAILED : wrong priority. Expected "1" but was ' || mail_utility_var.g_priority);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if wrong value is catched correctly
      mail_utility_krn.set_priority(10);
      IF mail_utility_var.g_priority = 3 THEN
         printMessage('Test "priority with wrong value" => OK');
      ELSE
         printMessage('Test "priority with wrong value" FAILED : wrong priority. Expected 3 but was ' || mail_utility_var.g_priority);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_priority;

   /*
      Procedure to test set_force_send_on_non_prod_env
   */
   PROCEDURE test_set_att_inline
   IS
   BEGIN
      printMessage('Test set_att_inline:');
      -- Check default behavior when no value is given
      mail_utility_krn.set_att_inline(NULL);
      IF NOT mail_utility_var.g_att_inline THEN
         printMessage('Test "Default att inline" => OK');
      ELSE
         printMessage('Test "Default att inline" FAILED : wrong att inline. Expected FALSE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_att_inline(TRUE);
      IF mail_utility_var.g_att_inline THEN
         printMessage('Test "att inline TRUE" => OK');
      ELSE
         printMessage('Test "att inline TRUE" FAILED : wrong att inline. Expected TRUE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_att_inline(FALSE);
      IF NOT mail_utility_var.g_att_inline THEN
         printMessage('Test "att inline FALSE" => OK');
      ELSE
         printMessage('Test "att inline FALSE" FAILED : wrong att inline. Expected FALSE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_att_inline;

   /*
      Procedure to test set_att_filename
   */
   PROCEDURE test_set_att_filename
   IS
   BEGIN
      printMessage('Test set_att_filename:');
      -- Check default behavior when no value is given
      mail_utility_krn.set_att_filename(NULL);
      IF LENGTH(mail_utility_var.g_att_filename) = 31 THEN
         printMessage('Test "Empty message" => OK');
      ELSE
         printMessage('Test "Empty message" FAILED : wrong message. Expected a 31 character default message but was ' || mail_utility_var.g_att_filename);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_att_filename('thisisthefilename.txt');
      IF mail_utility_var.g_att_filename = 'thisisthefilename.txt' THEN
         printMessage('Test "Filename" => OK');
      ELSE
         printMessage('Test "Filename" FAILED : wrong filename. Expected "thisisthefilename.txt" but was ' || mail_utility_var.g_att_filename);
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_att_filename;

   /*
      Procedure to test set_force_send_on_non_prod_env
   */
   PROCEDURE test_set_force_send
   IS
   BEGIN
      printMessage('Test set_force_send:');
      -- Check default behavior when no value is given
      mail_utility_krn.set_force_send_on_non_prod_env(NULL);
      IF NOT mail_utility_var.g_force_send_on_non_prod_env THEN
         printMessage('Test "Default force send" => OK');
      ELSE
         printMessage('Test "Default force send" FAILED : wrong force send. Expected FALSE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_force_send_on_non_prod_env(TRUE);
      IF mail_utility_var.g_force_send_on_non_prod_env THEN
         printMessage('Test "force send TRUE" => OK');
      ELSE
         printMessage('Test "force send TRUE" FAILED : wrong force send. Expected TRUE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;

      -- Check if given value is set correctly
      mail_utility_krn.set_force_send_on_non_prod_env(FALSE);
      IF NOT mail_utility_var.g_force_send_on_non_prod_env THEN
         printMessage('Test "force send FALSE" => OK');
      ELSE
         printMessage('Test "force send FALSE" FAILED : wrong force send. Expected FALSE.');
         RAISE_APPLICATION_ERROR(-20000, 'Test failed');
      END IF;
   END test_set_force_send;

   /*
      Procedure to test all
   */
   PROCEDURE test_all
   IS
   BEGIN
      test_set_sender;
      printMessage('--------------------------------------------------');
      test_set_recipients;
      printMessage('--------------------------------------------------');
      test_set_cc;
      printMessage('--------------------------------------------------');
      test_set_bcc;
      printMessage('--------------------------------------------------');
      test_set_subject;
      printMessage('--------------------------------------------------');
      test_set_message;
      printMessage('--------------------------------------------------');
      test_set_mime_type;
      printMessage('--------------------------------------------------');
      test_set_att_mime_type;
      printMessage('--------------------------------------------------');
      test_set_priority;
      printMessage('--------------------------------------------------');
      test_set_att_inline;
      printMessage('--------------------------------------------------');
      test_set_att_filename;
      printMessage('--------------------------------------------------');
      test_set_force_send;
   END test_all;
END;
/

