CREATE OR REPLACE PACKAGE log_utility
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
/**
* Set default logging context (null context means dbms_output)
* @param p_context   logging context
*/
   PROCEDURE set_context (
      p_context IN INTEGER
   )
   ;
/**
* Log a message for default context (null context means dbms_output)
* @param p_type      message type: I(nfo), W(arning), E(rror), T(ext), D(ebug), S(QL)
* @param p_text      message text
* @param p_new_line  append a new line character after
*/
   PROCEDURE log_message (
      p_type IN VARCHAR2
     ,p_text IN VARCHAR2
     ,p_new_line IN BOOLEAN := TRUE
   )
   ;
/**
* Log a message for given context (null context means dbms_output)
* @param p_context   logging context
* @param p_type      message type: I(nfo), W(arning), E(rror), T(ext), D(ebug), S(QL)
* @param p_text      message text
* @param p_new_line  append a new line character after
*/
   PROCEDURE log_message (
      p_context IN INTEGER
     ,p_type IN VARCHAR2
     ,p_text IN VARCHAR2
     ,p_new_line IN BOOLEAN := TRUE
   )
   ;
/**
* Set message filter (show only messages of types specified by mask)
* @param p_msg_mask   message type mask made up of I(nfo), W(arning), E(rror), D(ebug), S(QL)
*/
   PROCEDURE set_message_filter (
      p_msg_mask IN VARCHAR2
   )
   ;
/**
* Set time mask to prefix debug messages with system date and time
* @param p_time_mask  time mask e.g. DD/MM/YYYY HH24:MI:SS
*/
   PROCEDURE set_time_mask (
      p_time_mask IN VARCHAR2 := NULL
   )
   ;
/**
* Delete output for given context
* @param p_context  logging context (default context used if NULL)
*/
   PROCEDURE delete_output (
      p_context IN INTEGER := NULL
   )
   ;
END;
/