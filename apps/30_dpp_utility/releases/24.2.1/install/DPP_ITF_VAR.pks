CREATE OR REPLACE PACKAGE dpp_itf_var ACCESSIBLE BY (DPP_ITF_KRN, DPP_JOB_KRN) AS
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
  -- Global variables
  ---
  g_time_mask    VARCHAR2(40) := NULL; -- Display time in this format
  g_msg_mask     VARCHAR2(5) := 'IWE'; -- Message filter
  g_last_line    INTEGER := NULL;
  g_context      INTEGER := NULL;
  g_last_context INTEGER := NULL;
  g_job_type     dpp_job_types.jte_cd%TYPE;
END dpp_itf_var;
/
--show errors package dpp_itf_var;