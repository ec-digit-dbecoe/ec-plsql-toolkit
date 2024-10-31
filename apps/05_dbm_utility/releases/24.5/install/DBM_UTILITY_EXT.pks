CREATE OR REPLACE PACKAGE dbm_utility_ext AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License as published by
-- the European Union, either version 1.1 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- European Union Public License for more details.
--
-- You should have received a copy of the European Union Public License
-- along with this program.  If not, see <https:/ /joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE dbm_utility_krn', '-f');
--@--#pragma reversible
--@--#execute gen_utility.get_custom_code('package body','dbm_utility_ext','public','   ;')
--#if 0
   ---
   -- Get constraint search_condition as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_con_search_condition (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get mview query as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_mview_query (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get view text as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_view_text (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
   ;
--#endif 0
END dbm_utility_ext;
/
