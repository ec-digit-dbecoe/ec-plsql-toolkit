CREATE OR REPLACE PACKAGE doc_utility_ext_tpl
AUTHID DEFINER
AS
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
   ---
   -- This package is an extension of the DOC_UTILITY package
   -- Its main purpose is to isolate application specific code and behaviour
   -- This package is generated from a template and subsequently customized
   -- In some circumstances, this package must be generated again
   -- This is necessary when new methods and/or params have to be added/changed  
   -- One golden rule has to be followed in order not to lose the custom code 
   -- Custom code must always been added within the provided @begin and @end tags
   -- (C)opyright DBCC 2021 All rights reserved
   ---
   --@begin:decl
--#execute gen_utility.get_custom_code('PACKAGE','DOC_UTILITY_EXT','decl')
   --@end:decl
   ---
   -- Merge docx template with data 
   -- Template is stored in the database 
   -- Generated document is stored in the DB
   -- Returns document id 
   ---
   FUNCTION docx_merge (
      p_body_tpl_id doc_templates.tpl_id%TYPE           -- Id of body template
    , p_hdfo_tpl_id doc_templates.tpl_id%TYPE := NULL   -- Id of header/footer template (optional)
   )
   RETURN doc_documents.doc_id%TYPE
   ;
   ---
   -- Merge docx template with data 
   -- Template is stored in the database 
   -- Generated document is stored in the DB
   ---
   PROCEDURE docx_merge (
      p_body_tpl_id doc_templates.tpl_id%TYPE           -- Id of body template
    , p_hdfo_tpl_id doc_templates.tpl_id%TYPE := NULL   -- Id of header/footer template (optional)
   )
   ;
   ---
   -- Add custom filters
   ---
   FUNCTION add_column_filter (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_column_name IN VARCHAR2
    , p_condition IN VARCHAR2
    , p_out IN OUT sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   ;
   ---
   -- Add table filters
   ---
   FUNCTION add_table_filter (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_condition IN VARCHAR2
    , p_out IN OUT sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   ;
   ---
   -- Determine whether table must be kept or no
   ---
   FUNCTION keep_table (
      p_table_name IN VARCHAR2
   )
   RETURN BOOLEAN
   ;
   ---
   -- Customize a query before its execution 
   ---
   PROCEDURE customize_query (
      p_qry IN OUT sys.dbms_sql.varchar2a
   )
   ;
   ---
   -- Get user's language
   ---
   FUNCTION get_language
   RETURN VARCHAR2
   ;
   ---
   -- Set defaults 
   ---
   PROCEDURE set_defaults
   ;
   ---
   -- Set preferred_paths
   ---
   PROCEDURE set_preferred_paths
   ;
END;
/
