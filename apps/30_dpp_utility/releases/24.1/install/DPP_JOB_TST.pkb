CREATE OR REPLACE PACKAGE BODY dpp_job_tst IS
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
--#pragma reversible
/*
#begin job-dataset
seq;name;object_type;schema;result;exception
1;null object type;NULL;'whatever';NULL;-20000
2;unknown object type;'UNKNOWN';'whatever';NULL;-20001
3;null schema name;'TABLE';NULL;NULL;-20001
4;unknown schema name;'TABLE';'TOTO';NULL;-20001
5;tested schema; 'SCHEMA';'APP_DPP_D';FALSE;0
#end job-dataset
*/
/*--#delete
#begin job-for-loop
#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''dpp_job_tst'',''job-dataset''))')))
#end job-for-loop
   -- Test #tst.seq - tst.name
   PROCEDURE test_job_tst.seq IS

      l_res BOOLEAN := tst.result;

   BEGIN     
     ut.expect(dpp_job_krn.is_object_locked(tst.object_type,tst.schema)).to_equal(l_res);   
   END;

#endfor

*/--#delete
END dpp_job_tst;
/
--show errors package body DPP_JOB_TST;