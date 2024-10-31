create or replace PACKAGE doc_utility_var AS
---
-- Copyright (C) 2023 European Commission
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
-- along with this program.  If not, see <https:
---
--WARNING: do not modify this package specification as it is generated from the body!!!
--Execute the following command twice: gen_utility.generate('PACKAGE ds_utility_krn', '-f');
   -- Queries
   TYPE gr_qry_type IS RECORD (
      qry_name VARCHAR2(60)
    , l_select VARCHAR2(4000)
    , l_from VARCHAR2(4000)
    , l_where VARCHAR2(4000)
    , l_order_by VARCHAR2(4000)
    , l_prefix VARCHAR2(4000)
    , l_suffix VARCHAR2(4000)
    , l_path VARCHAR2(4000)
    , t_out sys.dbms_sql.varchar2a
    , t_sel sys.dbms_sql.varchar2a
    , t_var sys.dbms_sql.varchar2a
    , t_col sys.dbms_sql.varchar2a
    , l_cursor INTEGER
    , t_desc sys.dbms_sql.desc_tab2
    , l_count INTEGER
    , l_tot_count INTEGER
    , l_foreach_count INTEGER
   );
   TYPE gt_qry_cache_ass_type IS TABLE OF gr_qry_type INDEX BY VARCHAR2(100);
   TYPE gt_qry_cache_idx_type IS TABLE OF gr_qry_type INDEX BY BINARY_INTEGER;
   TYPE gr_dim_type IS RECORD (
      col_name1 VARCHAR2(30)
    , col_name2 VARCHAR2(30)
    , tab_name  VARCHAR2(30)
    , filter    VARCHAR2(200)
    , param_val VARCHAR2(100)
    , comment   VARCHAR2(100)
   );
   TYPE gt_dim_idx_type IS TABLE OF gr_dim_type;
   -- Cache
   gt_qry_idx gt_qry_cache_idx_type;
   -- Other globals
   g_debug_level VARCHAR2(10) := 'Q'; -- G)eneration, E)xecution, Q)uery, P)arsing, C)ache, N)o query comment, X)ml
   -- Public methods
   PROCEDURE clear_query_cache;
	 procedure test_update;
END;
/
