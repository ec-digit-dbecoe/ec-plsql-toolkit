CREATE OR REPLACE TYPE ds_read_csv_clob
AUTHID DEFINER
AS
OBJECT (
---
-- Copyright (C) 2023 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License as published by
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
---
  ret_type        anytype            -- The return type of the table function
 ,set_id          NUMBER             -- Data set id holding the CSV clob
 ,line_start      INTEGER            -- Start of next line to read
 ,csv_clob        CLOB               -- CLOB containing the CSV lines
 ,clob_len        INTEGER            -- CLOB length
 ,line_sep_char   VARCHAR2(2)        -- Line terminator (e.g., LF, CRLF)
 ,col_sep_char    VARCHAR2(1)        -- Column delimiter (e.g. semi-colon (default), comma, tab, space, etc.)
 ,left_sep_char   VARCHAR2(1)        -- Left enclosure character (e.g. none (default), simple quote, double quote, etc.)
 ,right_sep_char  VARCHAR2(1)        -- Right enclosure character (e.g. none (default), simple quote, double quote, etc.)
 ,col_names_row    NUMBER            -- Row number of header row containing column names (0 or NULL means none)
 ,col_types_row    NUMBER            -- Row number of header row containing column types (0 or NULL means none)
 ,data_row        NUMBER             -- Row number of first data row (0 or NULL means after headers)
-- ,STATIC PROCEDURE log (p_text IN VARCHAR2)
 ,STATIC PROCEDURE assert(p_assertion IN BOOLEAN, p_msg IN VARCHAR2)
 ,STATIC FUNCTION odcitabledescribe(rtype OUT anytype, p_set_id IN NUMBER)
  RETURN NUMBER
 ,STATIC FUNCTION odcitableprepare(sctx OUT ds_read_csv_clob, ti IN sys.odcitabfuncinfo, p_set_id IN NUMBER)
  RETURN NUMBER
 ,STATIC FUNCTION odcitablestart(sctx IN OUT ds_read_csv_clob, p_set_id IN NUMBER)
  RETURN NUMBER
 ,MEMBER FUNCTION odcitablefetch(self IN OUT ds_read_csv_clob, nrows IN NUMBER, outset OUT anydataset)
  RETURN NUMBER
 ,MEMBER FUNCTION odcitableclose(self IN ds_read_csv_clob)
  RETURN NUMBER
);
/
