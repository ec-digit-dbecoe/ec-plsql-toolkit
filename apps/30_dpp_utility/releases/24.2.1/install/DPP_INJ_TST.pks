CREATE OR REPLACE PACKAGE dpp_inj_tst IS
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
/*--#delete
   --%suite(DPP utility, dpp_inj_krn)
   --%context(inj_drop_checks_for_imp)
#include PACKAGE BODY dpp_inj_tst inj_drop_checks_for_imp-for-loop
#if "tst.exception" != "0"
   --%test(case #tst.seq - tst.name)
   --%throws(tst.exception)
#else
   --%test(case #tst.seq - tst.name)
#end if
   PROCEDURE test_inj_drop_tst.seq;
   
#endfor
   --%endcontext

*/--#delete
END dpp_inj_tst;
/
--show errors package dpp_inj_tst;