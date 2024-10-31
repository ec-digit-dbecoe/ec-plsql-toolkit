CREATE OR REPLACE PACKAGE DPP_MONITORING_VAR AUTHID DEFINER ACCESSIBLE BY (package DPP_MONITORING_KRN) IS
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
   * Define the constants and variables for the DPP_Utility timeout monitoring package.
   *
   * v1.00; 2024-04-08; malmjea; initial version
   */
   
   -- job status: busy
   gk_job_status_busy         CONSTANT dpp_job_runs.status%TYPE            :=
      'BSY';
      
   -- job status: error
   gk_job_status_error        CONSTANT dpp_job_runs.status%TYPE            :=
      'ERR';

   -- schema option: monitoring flag
   gk_schopt_monitoring       CONSTANT dpp_schema_options.otn_name%TYPE    :=
      'TIMEOUT_MONITORING';

   -- schema option: monitoring delay
   gk_schopt_delay            CONSTANT dpp_schema_options.otn_name%TYPE    :=
      'TIMEOUT_DELAY';

   -- schema option value: true
   gk_schoptval_monitoring    CONSTANT dpp_schema_options.stn_value%TYPE   :=
      'YES';

   -- default monitoring delay in minutes
   gk_default_delay           CONSTANT SIMPLE_INTEGER                      :=
      300;

   -- mail subject: timeout
   gk_mailsubj_timeout        CONSTANT VARCHAR2(500)                       :=
      'DPP_Utility job timeout - [jte_cd] - [env_name] - [sma_name]@[ite_name]';

   -- mail message: timeout
   gk_mailmsg_timeout         CONSTANT CLOB                                :=
      'The following DPP_Utility job seems to be in timeout:'
   || CHR(13) || CHR(10)
   || '- job run identifier: [jrn_id]'
   || CHR(13) || CHR(10)
   || '- batch code: [jte_cd]'
   || CHR(13) || CHR(10)
   || '- environment: [env_name]'
   || CHR(13) || CHR(10)
   || '- schema name: [sma_name]'
   || CHR(13) || CHR(10)
   || '- instance name: [ite_name]'
   || CHR(13) || CHR(10)
   || '- status: [status]'
   || CHR(13) || CHR(10)
   || '- start date: [date_started]';

   -- job log text: timeout
   gk_logtxt_timeout          CONSTANT dpp_job_logs.text%TYPE              :=
      'timeout';
      
   -- whether debug mode is activated
   g_debug_mode               BOOLEAN     := FALSE;
   
END DPP_MONITORING_VAR;
/
