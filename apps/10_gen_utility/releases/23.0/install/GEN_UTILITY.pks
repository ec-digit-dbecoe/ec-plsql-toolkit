CREATE OR REPLACE PACKAGE gen_utility IS
/*
 Author: Philippe Debois - 2008-2019
   Name: GEN_UTILITY - PL/SQL code generator based on database object templates
 Remark: Follow C precompiler syntax (see: https:/ /gcc.gnu.org/onlinedocs/cpp/)
*/
--@--#pragma reversible
   t_lines_out sys.dbms_sql.varchar2a;
--@--#execute gen_utility.get_custom_code('package body','gen_utility','public','   ;')
--#if 0
   PROCEDURE generate (
      p_source IN VARCHAR2 -- type and name of source database object (template)
     ,p_options IN VARCHAR2 := NULL -- options like -d for define, -u for undefine, -i for include
     ,p_text IN VARCHAR2 := NULL -- source text to be processed first
     ,p_target IN VARCHAR2 := NULL -- type and name of target database object (to generate)
   )
   ;
   PROCEDURE print_symbol_table
   ;
   FUNCTION get_symbol_table
   RETURN sys.odcivarchar2list pipelined
   ;
   PROCEDURE print_reverse_symbol_table
   ;
   FUNCTION get_reverse_symbol_table
   RETURN sys.odcivarchar2list pipelined
   ;
   FUNCTION get_prev_reverse_symbol_table
   RETURN sys.odcivarchar2list pipelined
   ;
   FUNCTION replace_symbols (
      p_line IN VARCHAR2
     ,p_recurse IN BOOLEAN
   )
   RETURN VARCHAR2
   ;
   ---
   -- Get named custom block of code enclosed between #begin and #end directives
   ---
   FUNCTION get_custom_code (
      p_type IN VARCHAR2 -- object type
    , p_name IN VARCHAR2 -- object name
    , p_tag  IN VARCHAR2 -- block name appearing after #begin/#end
    , p_sep  IN VARCHAR2 := NULL -- separator appended to each generated block
   )
   RETURN sys.odcivarchar2list pipelined
   ;
--#endif
END;
/
