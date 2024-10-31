CREATE OR REPLACE TYPE BODY ds_read_csv_clob
AS
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
-- along with this program.  If not, see <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
---
   -- Log message in a separate transaction
   -- When invoked from a member procedure/function via: ds_read_csv_clob.log()
--   STATIC PROCEDURE log (
--         p_text IN VARCHAR2
--      )
--   IS
--      PRAGMA AUTONOMOUS_TRANSACTION;
--   BEGIN
--      INSERT INTO ds_output (line, text)
--      SELECT NVL(MAX(line),0)+1, p_text FROM ds_output
--      ;
--      COMMIT;
--   END;
   -- Raise an exception if the given assertion is false
   STATIC PROCEDURE assert(p_assertion IN BOOLEAN, p_msg IN VARCHAR2)
   IS
   BEGIN
      IF NOT NVL(p_assertion, FALSE)
      THEN
         raise_application_error(-20000, 'Error: '||p_msg);
      END IF;
   END;
   -- Returns describe information for a table function whose return type is ANYDATASET
   STATIC FUNCTION odcitabledescribe(rtype OUT anytype, p_set_id IN NUMBER)
      RETURN NUMBER
   IS
      atyp anytype;
      l_line_start PLS_INTEGER;
      l_line_end PLS_INTEGER;
      l_line_sep_len PLS_INTEGER;
      l_line_no PLS_INTEGER;
      l_clob_len PLS_INTEGER;
      l_count INTEGER;
      l_line VARCHAR2(32767);
      la_names dbms_sql.varchar2a;
      la_types dbms_sql.varchar2a;
      la_data  dbms_sql.varchar2a;
      k_max_num CONSTANT NUMBER := 32767;
      -- Get csv CLOB from data set
      CURSOR c_ds (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT set_id, set_name, set_type, params
              , NVL(line_sep_char,CHR(10)) line_sep_char
              , NVL(col_sep_char,CHR(9)) col_sep_char
              , left_sep_char, right_sep_char
              , NVL(col_names_row,1) col_names_row
              , NVL(col_types_row,0) col_types_row
              , NVL(data_row,0) data_row
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      r_ds c_ds%ROWTYPE;
      -- Parse a line and extract columns separated by a semi-colon
      PROCEDURE parse_line(p_line IN OUT VARCHAR2, pa_cols IN OUT dbms_sql.varchar2a, p_col_sep_char IN VARCHAR2 := CHR(9), p_left_sep_char IN VARCHAR2 := NULL, p_right_sep_char IN VARCHAR2 := NULL)
      IS
         l_pos INTEGER;
      BEGIN
         pa_cols.DELETE;
         WHILE p_line IS NOT NULL
         LOOP
            pa_cols(pa_cols.COUNT + 1) := '';
            -- Extract text enclosed within text delimters (if any)
            IF SUBSTR(p_line,1,1) = p_left_sep_char THEN
               l_pos := INSTR(p_line, p_right_sep_char, 2);
               IF l_pos > 0 THEN
                  pa_cols(pa_cols.COUNT) := SUBSTR(p_line, 2, l_pos - 2);
                  p_line := SUBSTR(p_line, l_pos + 1);
               END IF;
            END IF;
            -- Extract all characters located before columns delimiter (or till end of line if none was found)  
            l_pos := INSTR(p_line,NVL(r_ds.col_sep_char,CHR(9)));
            IF l_pos > 0
            THEN
               pa_cols(pa_cols.COUNT) := pa_cols(pa_cols.COUNT) || SUBSTR(p_line, 1, l_pos - 1);
               p_line := SUBSTR(p_line, l_pos + 1);
            ELSE
               pa_cols(pa_cols.COUNT) := pa_cols(pa_cols.COUNT) || p_line;
               p_line := NULL;
            END IF;
         END LOOP;
      END;
      -- Check if a string is a prefix of a keyword
      -- Closing parenthesis allows to abbreviate 
      -- E.g. C)HAR pattern means C, CH, CHA and CHAR are accepted
      FUNCTION is_keyword_prefix (
         p_str IN VARCHAR2 -- keyword
       , p_pat IN VARCHAR2 -- pattern
      )
      RETURN BOOLEAN
      IS
         l_pat VARCHAR2(4000); -- pattern with closing parenthesis removed
         l_pos PLS_INTEGER;
         l_min PLS_INTEGER;
         l_len PLS_INTEGER := LENGTH(p_str);
      BEGIN
         l_pos := INSTR(p_pat,')');
         IF l_pos > 0 THEN
            l_min := l_pos-1;
            l_pat := SUBSTR(p_pat,1,l_pos-1)||SUBSTR(p_pat,l_pos+1);
         ELSE
            l_min := LENGTH(p_str);
            l_pat := p_pat;
         END IF; 
         RETURN l_len>=l_min AND p_str = SUBSTR(l_pat,1,l_len); 
      END;
      -- Get one of the values from the list enclosed in parenthesis
      -- e.g. get_value('NUMBER(2,0),x) returns 2 if x=1 or 0 if x=2
      FUNCTION get_value (
         p_str IN VARCHAR2
       , p_pos IN PLS_INTEGER
      )
      RETURN NUMBER
      IS
         l_pos PLS_INTEGER;
      BEGIN
         assert(p_pos IN (1,2),'get_value(): pos parameter must be 1 or 2');
         RETURN REGEXP_SUBSTR(p_str,'\(([0-9]+),*([0-9]*)\)',1,1,'i',p_pos);
      END;
   BEGIN
--dbms_output.put_line(systimestamp||': ->odcitabledescribe('||p_set_id||')');
--log(systimestamp||': ->odcitabledescribe('||p_set_id||')');
      OPEN c_ds(p_set_id);
      FETCH c_ds INTO r_ds;
      CLOSE c_ds;
      assert(r_ds.set_type='CSV','Data set "'||r_ds.set_name||'" is not of type CSV!');
      l_clob_len := NVL(dbms_lob.getlength(lob_loc=>r_ds.params),0);
      assert(l_clob_len>0,'Data set CLOB is empty!');
      l_line_sep_len := LENGTH(r_ds.line_sep_char);
      l_line_start := 1;
      l_line_no := 0;
      WHILE l_line_start <= l_clob_len LOOP
         l_line_no := l_line_no + 1;
         l_line_end := NVL(dbms_lob.INSTR(lob_loc=>r_ds.params,offset=>l_line_start,pattern=>r_ds.line_sep_char),0);
         IF l_line_end = 0 THEN
            l_line := dbms_lob.SUBSTR(lob_loc=>r_ds.params,offset=>l_line_start);
         ELSE
            l_line := dbms_lob.SUBSTR(lob_loc=>r_ds.params,offset=>l_line_start,amount=>l_line_end-l_line_start);
         END IF;
         -- Remove all CR/LF (this otherwise raise ORA-00902: Invalid column name)
         l_line := REPLACE(REPLACE(l_line, CHR(10)), CHR(13));
         -- Extract list of column name and types
         IF l_line_no = NVL(r_ds.col_names_row,0) THEN
            parse_line(l_line, la_names, r_ds.col_sep_char, r_ds.left_sep_char, r_ds.right_sep_char);
         ELSIF l_line_no = NVL(r_ds.col_types_row,0) THEN
            parse_line(l_line, la_types, r_ds.col_sep_char, r_ds.left_sep_char, r_ds.right_sep_char);
         ELSIF l_line_no >= NVL(r_ds.data_row,0) THEN
            parse_line(l_line, la_data, r_ds.col_sep_char, r_ds.left_sep_char, r_ds.right_sep_char);
            EXIT; -- stop after 1 data row
         END IF;
         <<next_line>>
         IF l_line_end = 0 THEN
            l_line_start := l_clob_len + 1;
         ELSE
            l_line_start := l_line_end + l_line_sep_len;
         END IF;
         EXIT WHEN l_line_end = 0;
      END LOOP;
      -- Determine number of columns based on headers
      l_count := GREATEST(NVL(la_names.COUNT,0), NVL(la_types.COUNT,0));
      IF l_count = 0 THEN
         -- Use first data row when no header row was found
         l_count := la_data.COUNT;
      END IF;
      assert(l_count>0,'Cannot determine number of columns!');
      -- Define missing names
      FOR i IN la_names.COUNT+1..l_count LOOP
         la_names(i) := 'COLUMN_'||i;
      END LOOP;
      -- Define missing types
      FOR i IN la_types.COUNT+1..l_count LOOP
         la_types(i) := 'CHAR';
      END LOOP;
      -- Define returned column names and types
      anytype.begincreate(dbms_types.typecode_object, atyp);
      FOR i IN 1..l_count
      LOOP
         DECLARE
            l_type VARCHAR2(4000);
            l_keyword VARCHAR2(4000);
            l_data_type PLS_INTEGER;
            l_data_precision user_tab_columns.data_precision%TYPE;
            l_data_scale user_tab_columns.data_scale%TYPE;
            l_data_length user_tab_columns.data_length%TYPE;
         BEGIN
            l_type := la_types(i);
            l_keyword := UPPER(REGEXP_SUBSTR(l_type,'[A-Za-z]+'));
            l_data_precision := 0;
            l_data_scale := 0;
            l_data_length := 0;
            IF is_keyword_prefix(l_keyword,'C)HAR') OR is_keyword_prefix(l_keyword,'V)ARCHAR2') THEN
               --CHAR(length)
               --VARCHAR2(length)
               l_data_type := dbms_types.typecode_varchar2;
               l_data_length := NVL(get_value(l_type,1),k_max_num);
            ELSIF is_keyword_prefix(l_keyword,'D)ATE') THEN
               --DATE
               l_data_type := dbms_types.typecode_date;
            ELSIF is_keyword_prefix(l_keyword,'N)UMBER') THEN
               --NUMBER(precision,scale)
               l_data_type := dbms_types.typecode_number;
               l_data_precision := get_value(l_type,1);
               l_data_scale := get_value(l_type,2);
            ELSIF is_keyword_prefix(l_keyword,'T)IMESTAMP') THEN
               --TIMESTAMP(scale)
               l_data_type := dbms_types.typecode_timestamp;
               l_data_scale := get_value(l_type,1);
            ELSE
               l_data_type := dbms_types.typecode_varchar2;
               l_data_length := k_max_num;
            END IF;
            atyp.addattr(
               aname=>la_names(i)
             , typecode=>l_data_type
             , prec=>l_data_precision --col_precision
             , SCALE=>l_data_scale --col_scale
             , len=>l_data_length --col_max_len
             , csid=>873 --col_charsetid
             , csfrm=>1 --col_charsetform
            );
         END;
      END LOOP;
      atyp.endcreate;
      anytype.begincreate(dbms_types.typecode_table, rtype);
      rtype.setinfo(
                    NULL
                  ,  NULL
                  ,  NULL
                  ,  NULL
                  ,  NULL
                  ,  atyp
                  ,  dbms_types.typecode_object
                  ,  0
                   );
      rtype.endcreate();
--      dbms_lob.freetemporary(lob_loc=>r_ds.params);
      RETURN odciconst.success;
--   EXCEPTION
--      WHEN OTHERS
--      THEN
--         RETURN odciconst.ERROR;
   END;
   -- Prepares the scan context and other query information at compile time
   STATIC FUNCTION odcitableprepare(sctx OUT ds_read_csv_clob, ti IN sys.odcitabfuncinfo, p_set_id IN NUMBER)
      RETURN NUMBER
   IS
      prec PLS_INTEGER;
      SCALE PLS_INTEGER;
      len PLS_INTEGER;
      csid PLS_INTEGER;
      csfrm PLS_INTEGER;
      elem_typ anytype;
      aname VARCHAR2(30);
      tc PLS_INTEGER;
      l_clob_len PLS_INTEGER;
      l_clob CLOB;
      -- Get csv CLOB from data set
      CURSOR c_ds (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT set_id, set_name, set_type, params
              , NVL(line_sep_char,CHR(10)) line_sep_char
              , NVL(col_sep_char,CHR(9)) col_sep_char
              , left_sep_char, right_sep_char
              , NVL(col_names_row,1) col_names_row
              , NVL(col_types_row,0) col_types_row
              , NVL(data_row,0) data_row
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      r_ds c_ds%ROWTYPE;
   BEGIN
--dbms_output.put_line(systimestamp||': ->odcitableprepare('||p_set_id||')');
--log(systimestamp||': ->odcitableprepare('||p_set_id||')');
      OPEN c_ds(p_set_id);
      FETCH c_ds INTO r_ds;
      CLOSE c_ds;
      assert(r_ds.set_type='CSV','Data set is not of type CSV!');
      l_clob_len := NVL(dbms_lob.getlength(lob_loc=>r_ds.params),0);
      assert(l_clob_len>0,'Data set CLOB is empty!');
      -- Fix for: ORA-01555: snapshot too old: rollback segment number  with name "" too small
      -- URL: http://ksun-oracle.blogspot.com/2019/04/lob-ora-22924-snapshot-too-old-and-fix.html
      -- create temporary lob
      dbms_lob.createtemporary(lob_loc=>l_clob, cache=>true, dur=>dbms_lob.call);
      -- copy content of Permanent LOB Locator to Temporary LOB Locator (pass by value)
      dbms_lob.copy(dest_lob=>l_clob, src_lob=>r_ds.params, amount=>l_clob_len);
      tc :=
         ti.rettype.getattreleminfo(
                                    1
                                  ,  prec
                                  ,  SCALE
                                  ,  len
                                  ,  csid
                                  ,  csfrm
                                  ,  elem_typ
                                  ,  aname
                                   );
      sctx := ds_read_csv_clob(elem_typ, p_set_id, 0, l_clob, l_clob_len, r_ds.line_sep_char, r_ds.col_sep_char, r_ds.left_sep_char, r_ds.right_sep_char, r_ds.col_names_row, r_ds.col_types_row, r_ds.data_row);
      RETURN odciconst.success;
   END;
   -- Initializes the scan of a table function
   STATIC FUNCTION odcitablestart(sctx IN OUT ds_read_csv_clob, p_set_id IN NUMBER)
      RETURN NUMBER
   IS
      l_line_start PLS_INTEGER;
      l_line_end PLS_INTEGER;
      l_line_sep_len PLS_INTEGER;
      l_line_no PLS_INTEGER;
      l_clob_len PLS_INTEGER;
      l_line VARCHAR2(32767);
      -- Get csv CLOB from data set
      CURSOR c_ds (
         p_set_id ds_data_sets.set_id%TYPE
      )
      IS
         SELECT set_id, set_name, set_type, params
              , NVL(line_sep_char,CHR(10)) line_sep_char
              , NVL(col_sep_char,CHR(9)) col_sep_char
              , left_sep_char, right_sep_char
              , NVL(col_names_row,1) col_names_row
              , NVL(col_types_row,0) col_types_row
              , NVL(data_row,0) data_row
           FROM ds_data_sets
          WHERE set_id = p_set_id
      ;
      r_ds c_ds%ROWTYPE;
      -- Raise an exception if the given assertion is false
      PROCEDURE assert(p_assertion IN BOOLEAN, p_msg IN VARCHAR2)
      IS
      BEGIN
         IF NOT NVL(p_assertion, FALSE)
         THEN
            raise_application_error(-20000, 'Error: '||p_msg);
         END IF;
      END;
   BEGIN
--dbms_output.put_line(systimestamp||': ->odcitablestart('||p_set_id||')');
--log(systimestamp||': ->odcitablestart('||p_set_id||')');
      OPEN c_ds(p_set_id);
      FETCH c_ds INTO r_ds;
      CLOSE c_ds;
      assert(r_ds.set_type='CSV','Data set is not of type CSV!');
      l_clob_len := NVL(dbms_lob.getlength(lob_loc=>r_ds.params),0);
      assert(l_clob_len>0,'Data set CLOB is empty!');
      l_line_sep_len := LENGTH(r_ds.line_sep_char);
      l_line_start := 1;
      l_line_no := 0;
      WHILE l_line_start <= l_clob_len LOOP
         l_line_no := l_line_no + 1;
         l_line_end := NVL(dbms_lob.INSTR(lob_loc=>r_ds.params,offset=>l_line_start,pattern=>r_ds.line_sep_char),0);
         IF l_line_end = 0 THEN
            l_line := dbms_lob.SUBSTR(lob_loc=>r_ds.params,offset=>l_line_start);
         ELSE
            l_line := dbms_lob.SUBSTR(lob_loc=>r_ds.params,offset=>l_line_start,amount=>l_line_end-l_line_start);
         END IF;
         -- Remove all CR/LF (this otherwise raise ORA-00902: Invalid column name)
         l_line := REPLACE(REPLACE(l_line, CHR(10)), CHR(13));
         -- Extract list of column name and types
         IF l_line_no = NVL(r_ds.col_names_row,0) THEN
            GOTO next_line;
         ELSIF l_line_no = NVL(r_ds.col_types_row,0) THEN
            GOTO next_line;
         ELSIF l_line_no >= NVL(r_ds.data_row,0) THEN
            EXIT; -- Do not read data row
         END IF;
         <<next_line>>
         IF l_line_end = 0 THEN
            l_line_start := l_clob_len + 1;
         ELSE
            l_line_start := l_line_end + l_line_sep_len;
         END IF;
         EXIT WHEN l_line_end = 0;
      END LOOP;
      sctx.line_start := l_line_start;
      sctx.clob_len := l_clob_len;
      sctx.line_sep_char := r_ds.line_sep_char;
--      dbms_lob.freetemporary(lob_loc=>r_ds.params);
      RETURN odciconst.success;
   END;
   -- Returns the next batch of rows from a table function
   MEMBER FUNCTION odcitablefetch(self IN OUT ds_read_csv_clob, nrows IN NUMBER, outset OUT anydataset)
      RETURN NUMBER
   IS
--      c1_col_type PLS_INTEGER;
      type_code PLS_INTEGER;
      prec PLS_INTEGER;
      SCALE PLS_INTEGER;
      len PLS_INTEGER;
      csid PLS_INTEGER;
      csfrm PLS_INTEGER;
      schema_name VARCHAR2(30);
      type_name VARCHAR2(30);
      VERSION VARCHAR2(30);
      attr_count PLS_INTEGER;
      attr_type anytype;
      attr_name VARCHAR2(100);
      l_line VARCHAR2(32767);
      l_len PLS_INTEGER;
      l_count INTEGER;
      la_cols dbms_sql.varchar2a;
      l_line_start PLS_INTEGER;
      l_line_end PLS_INTEGER;
      l_line_sep_len PLS_INTEGER;
      l_line_no PLS_INTEGER;
      l_clob_len PLS_INTEGER;
      -- Parse a line and extract columns separated by a semi-colon
      PROCEDURE parse_line(p_line IN OUT VARCHAR2, pa_cols IN OUT dbms_sql.varchar2a, p_col_sep_char IN VARCHAR2 := CHR(9), p_left_sep_char IN VARCHAR2 := NULL, p_right_sep_char IN VARCHAR2 := NULL)
      IS
         l_pos INTEGER;
      BEGIN
         pa_cols.DELETE;
         WHILE p_line IS NOT NULL
         LOOP
            pa_cols(pa_cols.COUNT + 1) := '';
            -- Extract text enclosed within text delimters (if any)
            IF SUBSTR(p_line,1,1) = p_left_sep_char THEN
               l_pos := INSTR(p_line, p_right_sep_char, 2);
               IF l_pos > 0 THEN
                  pa_cols(pa_cols.COUNT) := SUBSTR(p_line, 2, l_pos - 2);
                  p_line := SUBSTR(p_line, l_pos + 1);
               END IF;
            END IF;
            -- Extract all characters located before columns delimiter (or till end of line if none was found)  
            l_pos := INSTR(p_line,NVL(p_col_sep_char,CHR(9)));
            IF l_pos > 0
            THEN
               pa_cols(pa_cols.COUNT) := pa_cols(pa_cols.COUNT) || SUBSTR(p_line, 1, l_pos - 1);
               p_line := SUBSTR(p_line, l_pos + 1);
            ELSE
               pa_cols(pa_cols.COUNT) := pa_cols(pa_cols.COUNT) || p_line;
               p_line := NULL;
            END IF;
         END LOOP;
      END;
      -- Raise an exception if the given assertion is false
      PROCEDURE assert(p_assertion IN BOOLEAN, p_msg IN VARCHAR2)
      IS
      BEGIN
         IF NOT NVL(p_assertion, FALSE)
         THEN
            raise_application_error(-20000, 'Error: '||p_msg);
         END IF;
      END;
--      PROCEDURE log (
--            p_text IN VARCHAR2
--         )
--      IS
--         PRAGMA AUTONOMOUS_TRANSACTION;
--      BEGIN
--         INSERT INTO ds_output (line, text)
--         SELECT NVL(MAX(line),0)+1, p_text FROM ds_output
--         ;
--         COMMIT;
--      END;
   BEGIN
--dbms_output.put_line(systimestamp||': ->odcitablefetch('||self.set_id||')');
--log(systimestamp||': ->odcitablefetch('||self.set_id||')');
      outset := NULL;
      IF nrows < 1
      THEN -- is this possible???
         RETURN odciconst.success;
      END IF;
      l_line_sep_len := LENGTH(self.line_sep_char);
      l_clob_len := self.clob_len;
      l_line_start := self.line_start;
      IF l_line_start > l_clob_len
      THEN
         RETURN odciconst.success;
      END IF;
         l_line_end := NVL(dbms_lob.INSTR(lob_loc=>self.csv_clob,offset=>l_line_start,pattern=>self.line_sep_char),0);
         IF l_line_end = 0 THEN
            l_line := dbms_lob.SUBSTR(lob_loc=>self.csv_clob,offset=>l_line_start);
            l_line_start := l_clob_len + 1;
         ELSE
            l_line := dbms_lob.SUBSTR(lob_loc=>self.csv_clob,offset=>l_line_start,amount=>l_line_end-l_line_start);
            l_line_start := l_line_end + l_line_sep_len;
         END IF;
      -- Remove all CR/LF (this otherwise raise ORA-00902: Invalid column name)
      l_line := REPLACE(REPLACE(l_line, CHR(10)), CHR(13));
      self.line_start := l_line_start;
      parse_line(l_line, la_cols, self.col_sep_char, self.left_sep_char, self.right_sep_char);
      type_code :=
         self.ret_type.getinfo(
                               prec
                             ,  SCALE
                             ,  len
                             ,  csid
                             ,  csfrm
                             ,  schema_name
                             ,  type_name
                             ,  VERSION
                             ,  attr_count
                              );
      anydataset.begincreate(dbms_types.typecode_object, self.ret_type, outset);
      outset.addinstance;
      outset.piecewise();
      FOR i IN 1 .. attr_count
      LOOP
         type_code :=
            self.ret_type.getattreleminfo(
                                          i
                                        ,  prec
                                        ,  SCALE
                                        ,  len
                                        ,  csid
                                        ,  csfrm
                                        ,  attr_type
                                        ,  attr_name
                                         );
         IF la_cols.EXISTS(i)
         THEN
            l_line := la_cols(i);
         ELSE
            l_line := NULL;
         END IF;
         l_len := length(l_line);
         CASE type_code
            WHEN dbms_types.typecode_char
            THEN
               IF l_len = 4 AND UPPER(l_line) = 'USER' THEN
                  l_line := USER;
               END IF;
               outset.setchar(l_line);
            WHEN dbms_types.typecode_varchar2
            THEN
               IF l_len = 4 AND UPPER(l_line) = 'USER' THEN
                  l_line := USER;
               END IF;
               outset.setvarchar2(l_line);
            WHEN dbms_types.typecode_number
            THEN
               outset.setnumber(l_line);
            WHEN dbms_types.typecode_date
            THEN
               IF l_len = 7 AND UPPER(l_line) = 'SYSDATE' THEN
                  l_line := SYSDATE;
               END IF;
               outset.setdate(l_line);
            WHEN dbms_types.typecode_interval_ds
            THEN
               outset.setintervalds(l_line);
            WHEN dbms_types.typecode_interval_ym
            THEN
               outset.setintervalym(l_line);
            WHEN dbms_types.typecode_timestamp
            THEN
               IF l_len = 12 AND UPPER(l_line) = 'SYSTIMESTAMP' THEN
                  l_line := SYSTIMESTAMP;
               END IF;
               outset.settimestamp(l_line);
            WHEN dbms_types.typecode_timestamp_tz
            THEN
               IF l_len = 12 AND UPPER(l_line) = 'SYSTIMESTAMP' THEN
                  l_line := SYSTIMESTAMP;
               END IF;
               outset.settimestamptz(l_line);
            WHEN dbms_types.typecode_timestamp_ltz
            THEN
               IF l_len = 12 AND UPPER(l_line) = 'SYSTIMESTAMP' THEN
                  l_line := SYSTIMESTAMP;
               END IF;
               outset.settimestampltz(l_line);
         END CASE;
      END LOOP;
      outset.endcreate;
      RETURN odciconst.success;
   END;
   -- Performs cleanup operations after scanning a table function
   MEMBER FUNCTION odcitableclose(self IN ds_read_csv_clob)
      RETURN NUMBER
   IS
      l_clob CLOB;
--      PROCEDURE log (
--            p_text IN VARCHAR2
--         )
--      IS
--         PRAGMA AUTONOMOUS_TRANSACTION;
--      BEGIN
--         INSERT INTO ds_output (line, text)
--         SELECT NVL(MAX(line),0)+1, p_text FROM ds_output
--         ;
--         COMMIT;
--      END;
   BEGIN
--dbms_output.put_line(systimestamp||': ->odcitableclose('||self.set_id||')');
--log(systimestamp||': ->odcitableclose('||self.set_id||')');
      l_clob := self.csv_clob;
      dbms_lob.freetemporary(lob_loc=>l_clob);
      RETURN odciconst.success;
   END;
END;
/