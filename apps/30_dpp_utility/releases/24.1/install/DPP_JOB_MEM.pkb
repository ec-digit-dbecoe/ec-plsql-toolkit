CREATE OR REPLACE PACKAGE BODY dpp_job_mem
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
   PROCEDURE flush_prr
   IS
   BEGIN
      dpp_job_var.gt_prr_type.DELETE;
   END;

   PROCEDURE load_prr
   IS
      CURSOR c_prr
          IS
      SELECT *
        FROM dpp_parameters
      ;
   BEGIN
      flush_prr;
      FOR r_prr IN c_prr LOOP
         dpp_job_var.gt_prr_type(r_prr.prr_name) := r_prr;
      END LOOP;
   END;

   FUNCTION get_prr(p_prr_name IN dpp_parameters.prr_name%TYPE,
                    p_ite_name IN dpp_parameters.ite_name%TYPE := NULL)
   RETURN dpp_parameters%ROWTYPE
   IS
   BEGIN
      -- already in cache
      IF dpp_job_var.gt_prr_type.EXISTS(p_prr_name) THEN
		 IF p_ite_name IS NOT NULL THEN
            IF dpp_job_var.gt_prr_type(p_prr_name).ite_name = p_ite_name THEN
              RETURN dpp_job_var.gt_prr_type(p_prr_name);
            END IF;		   
		 ELSE
            RETURN dpp_job_var.gt_prr_type(p_prr_name);  		 
		 END IF;
      END IF;
      -- load cache and try again
      load_prr;
      IF dpp_job_var.gt_prr_type.EXISTS(p_prr_name) THEN
		 IF p_ite_name IS NOT NULL THEN
            IF dpp_job_var.gt_prr_type(p_prr_name).ite_name = p_ite_name THEN
              RETURN dpp_job_var.gt_prr_type(p_prr_name);
            END IF;		   
		 ELSE
            RETURN dpp_job_var.gt_prr_type(p_prr_name);  		 
		 END IF;
      END IF;
      RETURN NULL;
   END get_prr;

END dpp_job_mem;

/
--show errors package body DPP_JOB_MEM;