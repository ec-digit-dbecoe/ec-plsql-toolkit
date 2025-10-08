CREATE OR REPLACE PACKAGE BODY dpp_itf_krn AS
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
  --- V32
  --- Raise exception when condition is not true
  ---
  PROCEDURE assert(p_condition IN BOOLEAN, p_text IN VARCHAR2) IS
  BEGIN
    IF NOT p_condition THEN
      raise_application_error(-20000, p_text);
    END IF;
  END;
  ---
  -- Set logging context
  ---
  PROCEDURE set_context(p_context IN INTEGER) IS
  BEGIN
    dpp_itf_var.g_context := p_context;
  END;
  ---
  -- Set message filter
  ---
  PROCEDURE set_message_filter(p_msg_mask IN VARCHAR2) IS
  BEGIN
    dpp_itf_var.g_msg_mask := UPPER(SUBSTR(p_msg_mask, 1, 5));
  END;
  ---
  -- Set time mask
  ---
  PROCEDURE set_time_mask(p_time_mask IN VARCHAR2 := NULL) IS
  BEGIN
    dpp_itf_var.g_time_mask := SUBSTR(p_time_mask, 1, 40);
  END;
  ---
  --- Delete output
  ---
  PROCEDURE delete_output(p_context   IN INTEGER := NULL,
                          p_line_from IN INTEGER := NULL,
                          p_line_to   IN INTEGER := NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_context INTEGER := NVL(p_context, dpp_itf_var.g_context);
  BEGIN
    assert(l_context IS NOT NULL, 'No context is defined');
    DELETE dpp_job_logs A
     WHERE jrn_id = l_context
       AND A.jte_cd = dpp_itf_var.g_job_type
       AND line BETWEEN NVL(p_line_from, line) AND NVL(p_line_to, line);
    dpp_itf_var.g_last_context := l_context;
    dpp_itf_var.g_last_line    := NULL;
    COMMIT;
  END;
  ---
  -- Log text
  ---
  PROCEDURE log_p(p_context  IN INTEGER,
                  p_text    IN VARCHAR2,
                  p_new_line BOOLEAN := FALSE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- Cursor to get last line number
    CURSOR c_out IS
      SELECT NVL(MAX(line), 1)
        FROM dpp_job_logs A
       WHERE A.jte_cd = dpp_itf_var.g_job_type
         AND A.jrn_ID = p_context;
    l_p_text VARCHAR2(1000);
  BEGIN
    l_p_text := '[' || TO_CHAR(SYSDATE, 'DD/MM HH24:MI:SS') || ']' ||
                p_text;

    -- Get last line number
    IF dpp_itf_var.g_last_line IS NULL OR
       NVL(dpp_itf_var.g_last_context, -1) != NVL(p_context, -1) THEN
      OPEN c_out;
      FETCH c_out
        INTO dpp_itf_var.g_last_line;
      CLOSE c_out;
      dpp_itf_var.g_last_context := p_context;
    END IF;
    assert(dpp_itf_var.g_last_line IS NOT NULL,
           'Cannot generate line number');
    --
    -- Try to append first
    --
    UPDATE dpp_job_logs A
       SET text = text || p_text
     WHERE jrn_id = p_context
       AND A.jte_cd = dpp_itf_var.g_job_type
       AND line = dpp_itf_var.g_last_line;
    -- Insert if not found
    IF SQL%NOTFOUND THEN
      INSERT INTO dpp_job_logs
        (jrn_id, line, text, jte_cd)
      VALUES
        (p_context,
         dpp_itf_var.g_last_line,
         l_p_text,
         dpp_itf_var.g_job_type);
    END IF;
    -- Increment line number if required
    IF p_new_line THEN
      dpp_itf_var.g_last_line := dpp_itf_var.g_last_line + 1;
    END IF;
    -- Save work
    COMMIT;
  END;
  ---
  -- Same as dbms_output.put_line but with
  -- limit of 255 characters per line removed
  ---
  PROCEDURE put(p_context  IN INTEGER,
                p_text     IN VARCHAR2,
                p_new_line IN BOOLEAN := FALSE) IS
    l_str      VARCHAR2(10);
    l_pos      INTEGER;
    l_len      INTEGER;
    l_max_line INTEGER;
  BEGIN
    IF p_context IS NULL THEN
      l_max_line := 255;
    ELSE
      l_max_line := 3600; -- 10% for UTF8 cs
    END IF;
    l_str := CHR(13) || CHR(10);
    l_pos := NVL(INSTR(p_text, l_str), 0);
    IF l_pos <= 0 THEN
      l_str := CHR(10);
      l_pos := NVL(INSTR(p_text, l_str), 0);
    END IF;
    IF l_pos > 0 THEN
      put(p_context, SUBSTR(p_text, 1, l_pos - 1), TRUE);
      put(p_context, SUBSTR(p_text, l_pos + LENGTH(l_str)), p_new_line);
    ELSE
      l_len := NVL(LENGTH(p_text), 0);
      IF l_len > l_max_line THEN
        put(p_context, SUBSTR(p_text, 1, l_max_line - 1) || '\', TRUE);
        put(p_context, SUBSTR(p_text, l_max_line), p_new_line);
      ELSE
        IF p_context IS NULL THEN
          IF p_new_line THEN
            dbms_output.put_line(p_text);
          ELSE
            dbms_output.put(p_text);
          END IF;
        ELSE
          log_p(p_context, p_text, p_new_line);
        END IF;
      END IF;
    END IF;
  END;
  ---
  -- Log message for given context
  ---
  PROCEDURE log_message(p_context  IN INTEGER -- context
                       ,
                        p_type     IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL
                       ,
                        p_text     IN VARCHAR2 -- message text
                       ,
                        p_new_line IN BOOLEAN := TRUE) IS
    l_type VARCHAR2(1) := UPPER(SUBSTR(p_type, 1, 1));
  BEGIN
    IF INSTR(dpp_itf_var.g_msg_mask, l_type) <= 0 AND l_type != 'T' THEN
      -- Do not display
      RETURN;
    END IF;
    IF l_type = 'I' THEN
      put(p_context, 'Info: ', FALSE);
    ELSIF l_type = 'W' THEN
      put(p_context, 'Warning: ', FALSE);
    ELSIF l_type = 'E' THEN
      put(p_context, 'Error: ', FALSE);
    END IF;
    IF l_type = 'D' THEN
      IF dpp_itf_var.g_time_mask IS NOT NULL THEN
        put(p_context,
            TO_CHAR(SYSDATE, dpp_itf_var.g_time_mask) || ': ' || p_text,
            p_new_line);
      ELSE
        put(p_context, p_text, p_new_line);
      END IF;
    ELSE
      put(p_context, p_text, p_new_line);
    END IF;
  END;
  ---
  -- Log message for default context
  ---
  PROCEDURE log_message(p_type     IN VARCHAR2 -- message type: Info, Warning, Error, Text, Debug, SQL
                       ,
                        p_text     IN VARCHAR2 -- message text
                       ,
                        p_new_line IN BOOLEAN := TRUE) IS
  BEGIN
    log_message(dpp_itf_var.g_context -- default context
               ,
                p_type,
                p_text,
                p_new_line);
  END;
END;
/
--show errors package body DPP_ITF_KRN;