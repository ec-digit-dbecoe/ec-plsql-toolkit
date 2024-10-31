CREATE OR REPLACE PACKAGE DPP_MONITORING_KRN AUTHID DEFINER IS
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
   * DPP_Utility timeout monitoring package.
   *
   * v1.00; 2024-04-08; malmjea; initial version
   */
   
      /**
   * Execute the monitoring.
   *
   * @param p_debug: whether debug mode is activated
   */
   PROCEDURE exec_monitoring(p_debug IN BOOLEAN := FALSE);

END DPP_MONITORING_KRN;
/
