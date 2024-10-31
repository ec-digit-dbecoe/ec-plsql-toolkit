CREATE OR REPLACE PACKAGE http_utility_var
AUTHID DEFINER
ACCESSIBLE BY (PACKAGE http_utility_krn)
IS
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
* Define the constants, variables and exceptions used by the "http_utility_krn"
* package.
*
* v1.00; 2024-09-26; malmjea; initial version
*/

   -- error code: invalid parameter
   gk_errcode_inv_prm         CONSTANT SIMPLE_INTEGER       := -20001;

   -- error code: HTTP request sending failure
   gk_errcode_http_req_fail   CONSTANT SIMPLE_INTEGER       := -20002;

   -- timestamp format
   gk_timestamp_format        CONSTANT VARCHAR2(100)        :=
      'YYYY-MM-DD HH24:MI:SSFF3';

   -- HTTP version
   gk_http_version            CONSTANT VARCHAR2(100)        := 'HTTP/1.1';

   -- verbose flag
   g_verbose                           BOOLEAN              := FALSE;

END http_utility_var;
/
