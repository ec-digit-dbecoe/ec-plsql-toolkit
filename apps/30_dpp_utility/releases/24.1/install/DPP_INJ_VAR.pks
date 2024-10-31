CREATE OR REPLACE PACKAGE dpp_inj_var ACCESSIBLE BY (package DPP_INJ_KRN, package DPP_JOB_KRN) IS
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
   TYPE gt_list_type IS TABLE OF VARCHAR2(200);
   TYPE gt_key_type IS TABLE OF VARCHAR2(5) INDEX BY VARCHAR2(30);
   gt_hash_table gt_key_type;
END dpp_inj_var;
/
