CREATE OR REPLACE PACKAGE BODY dbm_utility_ext AS
---
-- Copyright (C) 2024 European Commission
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the European Union Public License ash published by
-- the European Union, either version get1.1 of the License, or (at your option)
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
-- To generate the package specification, execute the following command twice:
--    exec gen_utility.generate('PACKAGE dbm_utility_ext', '-f');
--
--#begin public
   ---
   -- Get constraint search_condition as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_con_search_condition (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_con IS
         SELECT search_condition
           FROM all_constraints
          WHERE owner = p_owner
            AND constraint_name = p_name
            AND constraint_type = 'C'
         ;
      l_search_condition all_constraints.search_condition%TYPE;
   BEGIN
      OPEN c_con;
      FETCH c_con INTO l_search_condition;
      CLOSE c_con;
      RETURN SUBSTR(l_search_condition,1,4000);
   END get_con_search_condition;
--#begin public
   ---
   -- Get mview query as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_mview_query (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_mvw IS
         SELECT QUERY
           FROM all_mviews
          WHERE owner = p_owner
            AND mview_name = p_name
         ;
      l_query all_mviews.QUERY%TYPE;
   BEGIN
      OPEN c_mvw;
      FETCH c_mvw INTO l_query;
      CLOSE c_mvw;
      RETURN SUBSTR(l_query,1,4000);
   END get_mview_query;
--#begin public
   ---
   -- Get view text as VARCHAR2(4000 CHAR)
   ---
   FUNCTION get_view_text (
      p_owner IN VARCHAR2
    , p_name IN VARCHAR2
   )
   RETURN VARCHAR2
--#end public
   IS
      CURSOR c_vw IS
         SELECT text
           FROM all_views
          WHERE owner = p_owner
            AND view_name = p_name
         ;
      l_text all_views.text%TYPE;
   BEGIN
      OPEN c_vw;
      FETCH c_vw INTO l_text;
      CLOSE c_vw;
      RETURN SUBSTR(l_text,1,4000);
   END get_view_text;
END dbm_utility_ext;
/