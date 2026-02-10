CREATE OR REPLACE PACKAGE BODY dpp_inj_tst IS
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
#begin inj-dataset
seq;name;schema;result;exception
1;null value should raise exception 21005;NULL;NULL;-21005
2;unknown value should raise exception 21005;'UNKNOWN';NULL;-21005
#end inj-dataset
*/
/*--#delete
#begin inj_drop_checks_for_imp-for-loop
#for tst IN (SELECT * FROM TABLE(readcsv('SELECT * FROM TABLE(gen_utility.get_custom_code(''PACKAGE BODY'',''dpp_inj_tst'',''inj-dataset''))')))
#end inj_drop_checks_for_imp-for-loop
   -- Test #tst.seq - tst.name
   PROCEDURE test_inj_drop_tst.seq IS
   BEGIN     
      dpp_inj_krn.inj_drop_checks_for_imp(tst.schema);
   END;
#endfor

*/--#delete
END dpp_inj_tst;
/
--show errors PACKAGE BODY dpp_inj_tst;