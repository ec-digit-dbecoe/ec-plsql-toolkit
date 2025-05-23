CREATE OR REPLACE PACKAGE qc_utility_ora_04068 IS
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
   -- Check whether global variables/cursors are defined in a package spec/body
   -- (to avoid ORA-04068: existing state of packages has been discarded)
   -- Return a negative value in case of problem and a positive value otherwise
   -- The return value is the line of code where search stopped on error/success
   FUNCTION check_global_variables (
      p_type IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN INTEGER
   ;
END;
/
