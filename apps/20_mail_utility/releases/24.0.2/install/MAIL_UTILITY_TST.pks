CREATE OR REPLACE PACKAGE mail_utility_tst
AUTHID DEFINER
AS
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
   PROCEDURE test_set_is_prod
   ;

   /*
      Procedure to test set_sender
   */
   PROCEDURE test_set_sender
   ;

   /*
      Procedure to test set_recipients
   */
   PROCEDURE test_set_recipients
   ;

   /*
      Procedure to test set_cc
   */
   PROCEDURE test_set_cc
   ;

   /*
      Procedure to test set_bcc
   */
   PROCEDURE test_set_bcc
   ;

   /*
      Procedure to test set_subject
   */
   PROCEDURE test_set_subject
   ;

   /*
      Procedure to test set_message
   */
   PROCEDURE test_set_message
   ;

   /*
      Procedure to test set_mime_type
   */
   PROCEDURE test_set_mime_type
   ;

   /*
      Procedure to test set_att_mime_type
   */
   PROCEDURE test_set_att_mime_type
   ;

   /*
      Procedure to test set_priority
   */
   PROCEDURE test_set_priority
   ;

   /*
      Procedure to test set_force_send_on_non_prod_env
   */
   PROCEDURE test_set_att_inline
   ;

   /*
      Procedure to test set_att_filename
   */
   PROCEDURE test_set_att_filename
   ;

   /*
      Procedure to test set_force_send_on_non_prod_env
   */
   PROCEDURE test_set_force_send
   ;

   /*
      Procedure to test all
   */
   PROCEDURE test_all
   ;
END;
/

