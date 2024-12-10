CREATE OR REPLACE PACKAGE DPP_SEC_VAR AUTHID DEFINER
ACCESSIBLE BY (
   package DPP_JOB_KRN
 , package DPP_MONITORING_KRN
 , package DPP_CNF_KRN
)
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
   * Define the SEC_Utility constants and variables for the DPP_Utility
   * timeout monitoring package.
   *
   * v1.00; 2024-04-18; malmjea; initial version
   * v1.01; 2024-09-27; malmjea; available for the monitoring package
   */
   
   -- SEC_Utility encryption key
   gk_sec_util_key            CONSTANT VARCHAR2(16) := 'OpenSesame';
   
END DPP_SEC_VAR;
/
