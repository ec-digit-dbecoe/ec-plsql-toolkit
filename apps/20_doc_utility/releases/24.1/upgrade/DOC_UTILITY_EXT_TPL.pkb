CREATE OR REPLACE PACKAGE BODY doc_utility_ext_tpl AS
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
   -- Custom code must always been added within the provided @beging and @end tags
   -- (C)opyright DBCC 2021 All rights reserved
   ---
   --@begin:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','decl')
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
   IS
      CURSOR c_tpl (
         p_body_tpl_id IN doc_templates.tpl_id%TYPE
      ) IS
         SELECT content
           FROM doc_templates
          WHERE tpl_id = p_body_tpl_id
         ;
      l_body   BLOB;
      l_hdfo BLOB;
      l_result BLOB;
      l_found  BOOLEAN;
      l_doc_id doc_documents.doc_id%TYPE;
   BEGIN
      OPEN c_tpl(p_body_tpl_id);
      FETCH c_tpl INTO l_body;
      l_found := c_tpl%FOUND;
      CLOSE c_tpl;
      doc_utility.assert(l_found,'Le modèle #:1 utilisé pour le corps du document n''existe pas !','Template #:1 used for the document body does not exist!',p_body_tpl_id);
      IF p_hdfo_tpl_id IS NOT NULL THEN
         OPEN c_tpl(p_hdfo_tpl_id);
         FETCH c_tpl INTO l_hdfo;
         l_found := c_tpl%FOUND;
         CLOSE c_tpl;
         doc_utility.assert(l_found,'Le modèle #:1 utilisé pour les entêtes et pieds de page n''existe pas !','Template #:1 used for the document header/footer does not exist!',p_hdfo_tpl_id);
      END IF;
      l_result := doc_utility.docx_merge(l_body,l_hdfo);
      IF l_result IS NOT NULL THEN
         SELECT doc_doc_seq.nextval INTO l_doc_id FROM dual;
         INSERT INTO doc_documents (
            doc_id, tpl_id, content
          , date_creat, user_creat
          , date_modif, user_modif
         ) VALUES (
            l_doc_id, p_body_tpl_id, l_result
          , SYSDATE, USER
          , SYSDATE, USER
         );
         sys.dbms_lob.freetemporary(l_result);
      END IF;
      RETURN l_doc_id;
   END;
   ---
   -- Merge docx template with data 
   -- Template is stored in the database 
   -- Generated document is stored in the DB
   ---
   PROCEDURE docx_merge (
      p_body_tpl_id doc_templates.tpl_id%TYPE           -- Id of body template
    , p_hdfo_tpl_id doc_templates.tpl_id%TYPE := NULL   -- Id of header/footer template (optional)
   )
   IS
      l_doc_id doc_documents.doc_id%TYPE;
   BEGIN
      l_doc_id := docx_merge(p_body_tpl_id,p_hdfo_tpl_id);
   END;
   ---
   -- Add column filter
   ---
   FUNCTION add_column_filter (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_column_name IN VARCHAR2
    , p_condition IN VARCHAR2
    , p_out IN OUT sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   IS
      l_found BOOLEAN := FALSE;
      --@begin:add_column_filter:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','add_column_filter:decl')
      --@end:add_column_filter:decl
   BEGIN
      --@begin:add_column_filter:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','add_column_filter:body')
      --@end:add_column_filter:body
      RETURN l_found;
   END;
   ---
   -- Add table filter
   ---
   FUNCTION add_table_filter (
      p_table_name IN VARCHAR2
    , p_table_alias IN VARCHAR2
    , p_condition IN VARCHAR2
    , p_out IN OUT sys.dbms_sql.varchar2a
   )
   RETURN BOOLEAN
   IS
      l_found BOOLEAN := FALSE;
      --@begin:add_table_filter:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','add_table_filter:decl')
      --@end:add_table_filter:decl
   BEGIN
      --@begin:add_table_filter:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','add_table_filter:body')
      --@end:add_table_filter:body
      RETURN l_found;
   END;
   ---
   -- Determine whether table must be kept or no
   ---
   FUNCTION keep_table (
      p_table_name IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      --@begin:keep_table:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','keep_table:decl')
      --@end:keep_table:decl
   BEGIN
      --@begin:keep_table:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','keep_table:body')
      --@end:keep_table:body
      RETURN TRUE;
   END;
   ---
   -- Get user's language
   ---
   FUNCTION get_language
   RETURN VARCHAR2
   IS
      --@begin:get_language:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','get_language:decl')
      --@end:get_language:decl
   BEGIN
      --@begin:get_language:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','get_language:body')
      --@end:get_language:body
      RETURN 'ENG';
   END;
   ---
   -- Customize a query before its execution 
   ---
   PROCEDURE customize_query (
      p_qry IN OUT sys.dbms_sql.varchar2a
   )
   IS
      --@begin:customize_query:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','customize_query:decl')
      --@end:customize_query:decl
   BEGIN
      --@begin:customize_query:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','customize_query:body')
      --@end:customize_query:body
      NULL;
   END;
   ---
   -- Set default for each table
   ---
   PROCEDURE set_defaults
   IS
      --@begin:set_defaults:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','set_defaults:decl')
      --@end:set_defaults:decl
   BEGIN
      doc_utility.reset_defaults;
      --@begin:set_defaults:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','set_defaults:decl')
      --@end:set_defaults:body
   END;
   ---
   -- Set preferred_paths
   ---
   PROCEDURE set_preferred_paths
   IS
      --@begin:set_preferred_paths:decl
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','set_preferred_paths:decl')
      --@end:set_preferred_paths:decl
   BEGIN
      --@begin:set_preferred_paths:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','set_preferred_paths:body')
      --@end:set_preferred_paths:body
      NULL;
   END;
BEGIN
   --@begin:body
--#execute gen_utility.get_custom_code('PACKAGE BODY','DOC_UTILITY_EXT','body')
   --@end:body
   NULL;
END;
/
