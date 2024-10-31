CREATE OR REPLACE PACKAGE BODY dbm_utility_krn AS
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
--    exec gen_utility.generate('PACKAGE dbm_utility_krn', '-f');
--
   ---
   -- Raise exception when condition is not true
   ---
   PROCEDURE assert (
      p_condition IN BOOLEAN
     ,p_text IN VARCHAR2
   )
   IS
   BEGIN
      IF NOT p_condition THEN
         raise_application_error(-20000,p_text);
      END IF;
   END;
--#begin public
   ---
   -- Output line to the in/out/err stream of a command
   ---
   PROCEDURE output_line (
      p_cmd_id IN dbm_streams.cmd_id%TYPE
     ,p_type IN dbm_streams.type%TYPE -- IN[23], OUT, ERR
     ,p_text IN VARCHAR2
     ,p_base64 IN BOOLEAN := FALSE
     ,p_line IN dbm_streams.line%TYPE := NULL -- to force line number
   )
--#end public
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Cursor to get last line number
      CURSOR c_out IS
      SELECT NVL(MAX(line+1),1) -- if lost then write a new line
        FROM dbm_streams
       WHERE cmd_id = p_cmd_id
         AND type = p_type
      ;
      r_str dbm_streams%ROWTYPE;
      l_text VARCHAR2(32767) := RTRIM(p_text);
      l_beg PLS_INTEGER := 1;
      l_pos PLS_INTEGER := 0;
      l_len PLS_INTEGER;
   BEGIN
      IF dbm_utility_var.g_os_name = 'Linux' THEN
         l_text := REPLACE(l_text, '\', '/');
      END IF;
      IF p_line IS NULL THEN
         r_str := dbm_utility_var.gr_last_str;
         IF  r_str.cmd_id = p_cmd_id
         AND r_str.type = p_type
         THEN
            r_str.line := r_str.line + 1;
         ELSE
            OPEN c_out;
            FETCH c_out INTO r_str.line;
            CLOSE c_out;
            r_str.cmd_id := p_cmd_id;
            r_str.type := p_type;
         END IF;
      ELSE
         r_str.cmd_id := p_cmd_id;
         r_str.type := p_type;
         r_str.line := p_line;
      END IF;
      IF p_base64 THEN
         l_text := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(l_text)));
      END IF;
      l_len := LENGTH(l_text);
      WHILE l_beg < l_len LOOP
         l_pos := NVL(INSTR(l_text,CHR(10),l_beg),0);
         EXIT WHEN l_pos <= 0;
         IF l_pos - l_beg > 0 THEN
            r_str.text := SUBSTR(l_text,l_beg,l_pos-l_beg);
            INSERT INTO dbm_streams VALUES r_str;
            IF p_line IS NULL THEN
               dbm_utility_var.gr_last_str := r_str;
               r_str.line := r_str.line + 1;
            END IF;
         END IF;
         l_beg := l_pos + 1;
      END LOOP;
      IF l_len - l_beg + 1 > 0 THEN
         r_str.text := SUBSTR(l_text,l_beg,l_len-l_beg+1);
         INSERT INTO dbm_streams VALUES r_str;
         IF p_line IS NULL THEN
            dbm_utility_var.gr_last_str := r_str;
         END IF;
      END IF;
      -- Save work
      COMMIT;
   END;
   ---
   -- Output line to the in/out/err stream of a command
   ---
   PROCEDURE output_whenever_sqlerror (
      p_cmd_id IN dbm_streams.cmd_id%TYPE
     ,p_type IN dbm_streams.type%TYPE -- IN, OUT, ERR
   )
   IS
   BEGIN
      output_line(p_cmd_id, p_type, 'whenever sqlerror exit ' || CASE WHEN dbm_utility_var.g_os_name = 'Linux' THEN '1' ELSE 'sql.sqlcode' END || ' rollback;');
   END;
--#begin public
   ---
   -- Output line to the in/out/err stream buffer
   ---
   PROCEDURE buffer_line (
      p_cmd_id IN dbm_streams.cmd_id%TYPE
     ,p_type IN dbm_streams.type%TYPE -- IN, OUT, ERR
     ,p_text IN dbm_streams.text%TYPE
   )
--#end public
   IS
      -- Cursor to get last line number
      CURSOR c_out IS
      SELECT NVL(MAX(line+1),1) -- if lost then write a new line
        FROM dbm_streams
       WHERE cmd_id = p_cmd_id
         AND type = p_type
      ;
      r_str dbm_streams%ROWTYPE;
   BEGIN
      r_str := dbm_utility_var.gr_last_str;
      IF  r_str.cmd_id = p_cmd_id
      AND r_str.type = p_type
      THEN
         r_str.line := r_str.line + 1;
      ELSE
         OPEN c_out;
         FETCH c_out INTO r_str.line;
         CLOSE c_out;
         r_str.cmd_id := p_cmd_id;
         r_str.type := p_type;
      END IF;
      r_str.text := p_text;
      dbm_utility_var.gt_str(dbm_utility_var.gt_str.COUNT+1) := r_str;
      dbm_utility_var.gr_last_str := r_str;
   END;
--#begin public
   ---
   -- Flush stream buffer
   ---
   PROCEDURE flush_buffer
--#end public
   IS
   BEGIN
      FORALL i IN 1..dbm_utility_var.gt_str.COUNT
         INSERT INTO dbm_streams VALUES dbm_utility_var.gt_str(i)
      ;
      COMMIT;
   END;
--#begin public
   ---
   -- Update or insert an application
   ---
   PROCEDURE upsert_app (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_seq IN dbm_applications.seq%TYPE := -1
    , p_ver_code IN dbm_applications.ver_code%TYPE := '~'
    , p_ver_status IN dbm_applications.ver_status%TYPE := '~'
    , p_home_dir IN dbm_applications.home_dir%TYPE := '~'
    , p_deleted_flag IN dbm_applications.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_applications
         SET seq = CASE WHEN p_seq < 0 THEN seq ELSE p_seq END
           , ver_code = CASE WHEN p_ver_code = '~' THEN ver_code ELSE p_ver_code END
           , ver_status = CASE WHEN p_ver_status = '~' THEN ver_status ELSE p_ver_status END
           , home_dir = CASE WHEN p_home_dir = '~' THEN home_dir ELSE p_home_dir END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE app_code = p_app_code
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_applications (
            app_code, seq, ver_code
          , ver_status, home_dir, deleted_flag
         ) VALUES (
            p_app_code
          , CASE WHEN p_seq = -1 THEN NULL ELSE p_seq END
          , CASE WHEN p_ver_code = '~' THEN NULL ELSE p_ver_code END
          , CASE WHEN p_ver_status = '~' THEN NULL ELSE p_ver_status END
          , CASE WHEN p_home_dir = '~' THEN NULL ELSE p_home_dir END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
--#begin public
   ---
   -- Update or insert a version
   ---
   PROCEDURE upsert_ver (
      p_app_code dbm_versions.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE := -1
    , p_ver_status dbm_versions.ver_status%TYPE := '~'
    , p_next_op_type dbm_versions.next_op_type%TYPE := '~'
    , p_last_op_type dbm_versions.last_op_type%TYPE := '~'
    , p_last_op_status dbm_versions.last_op_status%TYPE := '~'
    , p_last_op_date dbm_versions.last_op_date%TYPE := TO_DATE('01/01/0001','DD/MM/YYYY')
    , p_installable dbm_versions.installable%TYPE := '~'
    , p_install_rollbackable dbm_versions.install_rollbackable%TYPE := '~'
    , p_upgradeable dbm_versions.upgradeable%TYPE := '~'
    , p_upgrade_rollbackable dbm_versions.upgrade_rollbackable%TYPE := '~'
    , p_uninstallable dbm_versions.uninstallable%TYPE := '~'
    , p_validable dbm_versions.validable%TYPE := '~'
    , p_precheckable dbm_versions.precheckable%TYPE := '~'
    , p_setupable dbm_versions.setupable%TYPE := '~'
    , p_deleted_flag dbm_versions.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_versions
         SET ver_status = CASE WHEN p_ver_status = '~' THEN ver_status ELSE p_ver_status END
           , next_op_type = CASE WHEN p_next_op_type = '~' THEN next_op_type ELSE p_next_op_type END
           , last_op_type = CASE WHEN p_last_op_type = '~' THEN last_op_type ELSE p_last_op_type END
           , last_op_date = CASE WHEN p_last_op_date = TO_DATE('01/01/0001','DD/MM/YYYY') THEN last_op_date ELSE p_last_op_date END
           , installable = CASE WHEN p_installable = '~' THEN installable ELSE p_installable END
           , install_rollbackable = CASE WHEN p_install_rollbackable = '~' THEN install_rollbackable ELSE p_install_rollbackable END
           , upgradeable = CASE WHEN p_upgradeable = '~' THEN upgradeable ELSE p_upgradeable END
           , upgrade_rollbackable = CASE WHEN p_upgrade_rollbackable = '~' THEN upgrade_rollbackable ELSE p_upgrade_rollbackable END
           , uninstallable = CASE WHEN p_uninstallable = '~' THEN uninstallable ELSE p_uninstallable END
           , validable = CASE WHEN p_validable = '~' THEN validable ELSE p_validable END
           , precheckable = CASE WHEN p_precheckable = '~' THEN precheckable ELSE p_precheckable END
           , setupable = CASE WHEN p_setupable = '~' THEN setupable ELSE p_setupable END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE app_code = p_app_code
         AND ver_code = p_ver_code
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_versions (
            app_code, ver_code, ver_nbr
          , ver_status, next_op_type, last_op_type
          , last_op_date, installable, install_rollbackable
          , upgradeable, upgrade_rollbackable, validable
          , precheckable, setupable, deleted_flag
         ) VALUES (
            p_app_code, p_ver_code, p_ver_nbr
          , CASE WHEN p_ver_status = '~' THEN NULL ELSE p_ver_status END
          , CASE WHEN p_next_op_type = '~' THEN NULL ELSE p_next_op_type END
          , CASE WHEN p_last_op_type = '~' THEN NULL ELSE p_last_op_type END
          , CASE WHEN p_last_op_date =  TO_DATE('01/01/0001','DD/MM/YYYY') THEN NULL ELSE p_last_op_date END
          , CASE WHEN p_installable = '~' THEN NULL ELSE p_installable END
          , CASE WHEN p_install_rollbackable = '~' THEN NULL ELSE p_install_rollbackable END
          , CASE WHEN p_upgradeable = '~' THEN NULL ELSE p_upgradeable END
          , CASE WHEN p_uninstallable = '~' THEN NULL ELSE p_uninstallable END
          , CASE WHEN p_validable = '~' THEN NULL ELSE p_validable END
          , CASE WHEN p_precheckable = '~' THEN NULL ELSE p_precheckable END
          , CASE WHEN p_setupable = '~' THEN NULL ELSE p_setupable END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
   ---
   -- Update or insert a file
   ---
   PROCEDURE upsert_fil (
      pr_fil IN dbm_files%ROWTYPE
   )
   IS
   BEGIN
      UPDATE dbm_files
         SET type = pr_fil.type
           , seq = pr_fil.seq
           , status = NVL(pr_fil.status,status)
           , hash = CASE WHEN pr_fil.hash = 'NULL' THEN NULL ELSE NVL(pr_fil.hash, hash) END
           , run_status = CASE WHEN pr_fil.run_status = 'NULL' THEN NULL ELSE NVL(pr_fil.run_status, run_status) END
           , run_date = CASE WHEN pr_fil.run_status = 'NULL' THEN NULL WHEN NVL(pr_fil.run_status, run_status) != run_status THEN SYSDATE ELSE run_date END
       WHERE path = pr_fil.path
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_files VALUES pr_fil;
      END IF;
   END;
--#begin public
   ---
   -- Update or insert a file
   ---
   PROCEDURE upsert_fil (
      p_app_code dbm_files.app_code%TYPE
    , p_ver_code dbm_files.ver_code%TYPE
    , p_path dbm_files.path%TYPE
    , p_type dbm_files.type%TYPE
    , p_run_condition dbm_files.run_condition%TYPE := '~'
    , p_seq dbm_files.seq%TYPE := 999999999
    , p_hash dbm_files.hash%TYPE := '~'
    , p_status dbm_files.status%TYPE := '~'
    , p_run_status dbm_files.run_status%TYPE := '~'
    , p_run_date dbm_files.run_date%TYPE := TO_DATE('01/01/0001','DD/MM/YYYY')
    , p_deleted_flag dbm_files.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_files
         SET run_condition = CASE WHEN p_run_condition = '~' THEN run_condition ELSE p_run_condition END
           , seq = CASE WHEN p_seq = 999999999 THEN seq ELSE p_seq END
           , hash = CASE WHEN p_hash = '~' THEN hash ELSE p_hash END
           , status = CASE WHEN p_status = '~' THEN status ELSE p_status END
           , run_status = CASE WHEN p_run_status = '~' THEN run_status ELSE p_run_status END
           , run_date = CASE WHEN p_run_date= TO_DATE('01/01/0001','DD/MM/YYYY') THEN run_date ELSE p_run_date END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE path = p_path
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_files (
            app_code, ver_code, path
          , type, run_condition, seq
          , hash, status, run_status
          , run_date, deleted_flag
         ) VALUES (
            p_app_code, p_ver_code, p_path, p_type
          , CASE WHEN p_run_condition = '~' THEN NULL ELSE p_run_condition END
          , CASE WHEN p_seq = 999999999 THEN NULL ELSE p_seq END
          , CASE WHEN p_hash = '~' THEN NULL ELSE p_hash END
          , CASE WHEN p_status = '~' THEN NULL ELSE p_status END
          , CASE WHEN p_run_status = '~' THEN NULL ELSE p_run_status END
          , CASE WHEN p_run_date = TO_DATE('01/01/0001','DD/MM/YYYY') THEN NULL ELSE p_deleted_flag END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
--#begin public
   ---
   -- Update or insert a parameter
   ---
   PROCEDURE upsert_par (
      p_app_code dbm_parameters.app_code%TYPE
    , p_ver_code dbm_parameters.ver_code%TYPE
    , p_name dbm_parameters.name%TYPE
    , p_value dbm_parameters.name%TYPE := '~'
    , p_deleted_flag dbm_files.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_parameters
         SET value = CASE WHEN p_value = '~' THEN value ELSE p_value END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE app_code = p_app_code
         AND ver_code = p_ver_code
         AND name = p_name
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_parameters (
            app_code, ver_code, name
          , value, deleted_flag
         ) VALUES (
            p_app_code, p_ver_code, p_name
          , CASE WHEN p_value = '~' THEN NULL ELSE p_value END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
   ---
   -- Update or insert a variable value
   ---
   PROCEDURE upsert_var (
      pr_var IN dbm_variables%ROWTYPE
   )
   IS
   BEGIN
      UPDATE dbm_variables
         SET value = pr_var.value
           , descr = pr_var.descr
           , seq = pr_var.seq
           , data_type = pr_var.data_type
           , nullable = pr_var.nullable
           , convert_value_sql = pr_var.convert_value_sql
           , check_value_sql = pr_var.check_value_sql
           , default_value_sql = pr_var.default_value_sql
           , check_error_msg = check_error_msg
       WHERE app_code = pr_var.app_code
         AND name = pr_var.name
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_variables VALUES pr_var;
      END IF;
   END;
--#begin public
   ---
   -- Update or insert a variable
   ---
   PROCEDURE upsert_var (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
    , p_value dbm_variables.value%TYPE := '~'
    , p_descr dbm_variables.descr%TYPE := '~'
    , p_seq dbm_variables.seq%TYPE := 999
    , p_nullable dbm_variables.nullable%TYPE := '~'
    , p_convert_value_sql dbm_variables.convert_value_sql%TYPE := '~'
    , p_check_value_sql dbm_variables.check_value_sql%TYPE := '~'
    , p_default_value_sql dbm_variables.default_value_sql%TYPE := '~'
    , p_check_error_msg dbm_variables.check_error_msg%TYPE := '~'
    , p_deleted_flag dbm_variables.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_variables
         SET value = CASE WHEN p_value = '~' THEN value ELSE p_value END
           , descr = CASE WHEN p_descr = '~' THEN descr ELSE p_descr END
           , seq = CASE WHEN p_seq = 999 THEN seq ELSE p_seq END
           , nullable = CASE WHEN p_nullable = '~' THEN nullable ELSE p_nullable END
           , convert_value_sql = CASE WHEN p_convert_value_sql = '~' THEN convert_value_sql ELSE p_convert_value_sql END
           , check_value_sql = CASE WHEN p_check_value_sql = '~' THEN check_value_sql ELSE p_check_value_sql END
           , default_value_sql = CASE WHEN p_default_value_sql = '~' THEN default_value_sql ELSE p_default_value_sql END
           , check_error_msg = CASE WHEN p_check_error_msg = '~' THEN check_error_msg ELSE p_check_error_msg END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE app_code = p_app_code
         AND name = p_name
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_variables (
            app_code, name, value
          , descr, seq, nullable
          , convert_value_sql, check_value_sql, default_value_sql
          , check_error_msg, deleted_flag
         ) VALUES (
            p_app_code, p_name
          , CASE WHEN p_value = '~' THEN NULL ELSE p_value END
          , CASE WHEN p_descr = '~' THEN NULL ELSE p_descr END
          , CASE WHEN p_seq = 999 THEN NULL ELSE p_seq END
          , CASE WHEN p_nullable = '~' THEN NULL ELSE p_nullable END
          , CASE WHEN p_convert_value_sql = '~' THEN NULL ELSE p_convert_value_sql END
          , CASE WHEN p_check_value_sql = '~' THEN NULL ELSE p_check_value_sql END
          , CASE WHEN p_default_value_sql = '~' THEN NULL ELSE p_default_value_sql END
          , CASE WHEN p_check_error_msg = '~' THEN NULL ELSE p_check_error_msg END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
--#begin public
   ---
   -- Update or insert a database object
   ---
   PROCEDURE upsert_obj (
      p_app_code dbm_objects.app_code%TYPE
    , p_ver_code dbm_objects.ver_code%TYPE
    , p_name dbm_objects.name%TYPE
    , p_checksum dbm_objects.checksum%TYPE := '~'
    , p_condition dbm_objects.condition%TYPE := '~'
    , p_deleted_flag dbm_objects.deleted_flag%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_objects
         SET checksum = CASE WHEN p_checksum = '~' THEN checksum ELSE p_checksum END
           , condition = CASE WHEN p_condition = '~' THEN condition ELSE p_condition END
           , deleted_flag = CASE WHEN p_deleted_flag = '~' THEN deleted_flag ELSE p_deleted_flag END
       WHERE app_code = p_app_code
         AND ver_code = p_ver_code
         AND name = p_name
      ;
      IF SQL%NOTFOUND THEN
         INSERT INTO dbm_objects (
            app_code, ver_code, name
          , checksum, condition, deleted_flag
         ) VALUES (
            p_app_code, p_ver_code, p_name
          , CASE WHEN p_checksum = '~' THEN NULL ELSE p_checksum END
          , CASE WHEN p_condition = '~' THEN NULL ELSE p_condition END
          , CASE WHEN p_deleted_flag = '~' THEN NULL ELSE p_deleted_flag END
         );
      END IF;
   END;
   ---
   -- Check variable value and return error message
   ---
   FUNCTION check_var_value (
      r_var IN OUT dbm_variables%ROWTYPE
    , p_raise_exception IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_nbr NUMBER;
      l_err_msg VARCHAR2(256);
      l_value dbm_variables.value%TYPE;
   BEGIN
      IF r_var.convert_value_sql IS NOT NULL AND r_var.value IS NOT NULL THEN
         BEGIN
            EXECUTE IMMEDIATE r_var.convert_value_sql INTO r_var.value USING r_var.value;
         EXCEPTION
            WHEN OTHERS THEN
               l_err_msg := 'Error: cannot convert variable value using SQL statement (actual value="'||r_var.value||'")!';
         END ;
      END IF;
      IF l_err_msg IS NULL AND r_var.nullable='N' AND r_var.value IS NULL THEN
         l_err_msg := 'Error: variable "'||r_var.name||'" is mandatory!';
      END IF;
      IF l_err_msg IS NULL AND r_var.data_type = 'NUMBER' THEN
         BEGIN
            l_nbr := TO_NUMBER(r_var.value);
         EXCEPTION
            WHEN OTHERS THEN
               l_err_msg := 'Error: variable "'||r_var.name||'" must be a number (actual value="'||r_var.value||'") !';
         END;
      END IF;
      IF l_err_msg IS NULL AND r_var.check_value_sql IS NOT NULL THEN
         BEGIN
            EXECUTE IMMEDIATE r_var.check_value_sql INTO l_value USING r_var.value;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_err_msg := NVL('Error: '||r_var.check_error_msg,'Error: invalid value for variable "'||r_var.name||'"')||' (actual value="'||r_var.value||'")';
            WHEN TOO_MANY_ROWS THEN
               l_err_msg := NVL('Error: '||r_var.check_error_msg,'Error: invalid value for variable "'||r_var.name||'"')||' (actual value="'||r_var.value||'")';
            WHEN OTHERS THEN
               l_err_msg := 'Error: SQL statement to check variable "'||r_var.name||'" is invalid!';
         END;
      END IF;
      IF l_err_msg IS NOT NULL THEN
         IF p_raise_exception THEN
            raise_application_error(-20000, l_err_msg);
         ELSE
            dbms_output.put_line(l_err_msg);
         END IF;
      END IF;
      RETURN l_err_msg;
   END;
   ---
   -- Check variable value and raise an excetpion in case of error
   PROCEDURE check_var_value (
      r_var IN OUT dbm_variables%ROWTYPE
   )
   IS
      l_err_msg VARCHAR2(256);
   BEGIN
      l_err_msg := check_var_value(r_var, TRUE);
   END;
--#begin public
   ---
   -- Set variable value
   ---
   PROCEDURE set_var_value (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
    , p_value dbm_variables.value%TYPE
   )
--#end public
   IS
      CURSOR c_var IS
         SELECT *
           FROM dbm_variables
          WHERE app_code = p_app_code
            AND name = p_name
            FOR UPDATE OF value
      ;
      r_var dbm_variables%ROWTYPE;
      l_dummy VARCHAR2(4000);
      l_found BOOLEAN;
      l_valid BOOLEAN := TRUE;--Delete
   BEGIN
      OPEN c_var;
      FETCH c_var INTO r_var;
      l_found := c_var%FOUND;
      IF l_found and p_value IS NOT NULL THEN -- NULL means no update
         r_var.value := TRIM(p_value);
         IF check_var_value(r_var) IS NULL THEN
            UPDATE dbm_variables
               SET value = r_var.value
             WHERE CURRENT OF c_var;
         END IF;
      END IF;
      CLOSE c_var;
      assert(l_found,'Variable "'||p_name||'" not found, hence cannot be set!');
      COMMIT;
   END;
   ---
   -- Get variable
   ---
   FUNCTION get_var (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
   )
   RETURN dbm_variables%ROWTYPE
   IS
      CURSOR c_var IS
         SELECT *
           FROM dbm_variables
          WHERE app_code = p_app_code
            AND name = p_name
      ;
      r_var dbm_variables%ROWTYPE;
   BEGIN
      OPEN c_var;
      FETCH c_var INTO r_var;
      CLOSE c_var;
      RETURN r_var;
   END;
   ---
   -- Get variable value
   ---
   FUNCTION get_var_value (
      p_app_code dbm_variables.app_code%TYPE
    , p_name dbm_variables.name%TYPE
    , p_all IN BOOLEAN := FALSE
   )
   RETURN dbm_variables.value%TYPE
   IS
      r_var dbm_variables%ROWTYPE;
   BEGIN
      r_var := get_var(p_app_code, p_name);
      IF r_var.value IS NULL AND p_all THEN
         r_var := get_var('all', p_name);
      END IF;
      RETURN r_var.value;
   END;
   ---
   -- Create an application
   ---
--#begin public
   PROCEDURE create_application (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_seq IN dbm_applications.seq%TYPE := NULL
   )
--#end public
   IS
   BEGIN
      assert(p_app_code IS NOT NULL, 'Application code is mandatory');
      INSERT INTO dbm_applications (
         app_code, seq
      ) VALUES (
         p_app_code, p_seq
      );
      COMMIT;
   END;
   ---
   -- Consume white spaces
   ---
   PROCEDURE consume_white_spaces (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_ws IN BOOLEAN := TRUE
   )
   IS
      l_chr VARCHAR2(1 CHAR);
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN NOT l_chr IN (' ', CHR(9), CHR(10), CHR(13));
         p_pos := p_pos + 1;
      END LOOP;
   END;
   ---
   -- Consume until separator character
   ---
   FUNCTION consume_until_sep (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_sep IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_chr VARCHAR2(1 CHAR);
      l_beg_pos PLS_INTEGER := p_pos;
      l_end_pos PLS_INTEGER := p_pos;
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN l_chr = p_sep;
         p_pos := p_pos + 1;
      END LOOP;
      l_end_pos := p_pos;
      RETURN SUBSTR(p_str, l_beg_pos, l_end_pos - l_beg_pos);
   END;
   ---
   -- Consume until white space or sep
   ---
   FUNCTION consume_until_ws_or_sep (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_sep IN VARCHAR2 := NULL
   )
   RETURN VARCHAR2
   IS
      l_chr VARCHAR2(1 CHAR);
      l_beg_pos PLS_INTEGER := p_pos;
      l_end_pos PLS_INTEGER := p_pos;
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN l_chr = ' ' OR l_chr = p_sep;
         p_pos := p_pos + 1;
      END LOOP;
      l_end_pos := p_pos;
      RETURN SUBSTR(p_str, l_beg_pos, l_end_pos - l_beg_pos);
   END;
   ---
   -- Consume an identifier
   ---
   FUNCTION consume_identifier (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_ws IN BOOLEAN := TRUE
   )
   RETURN VARCHAR2
   IS
      l_chr VARCHAR2(1 CHAR);
      l_beg_pos PLS_INTEGER := p_pos;
      l_end_pos PLS_INTEGER := p_pos;
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN NOT l_chr BETWEEN 'A' AND 'Z'
               AND NOT l_chr BETWEEN 'a' AND 'z'
               AND NOT l_chr BETWEEN '0' AND '9'
               AND NOT l_chr IN ('_')
               AND NOT l_chr IN ('-')
               ;
         p_pos := p_pos + 1;
      END LOOP;
      l_end_pos := p_pos;
      IF p_ws THEN
         consume_white_spaces(p_str, p_pos, p_len);
      END IF;
      RETURN SUBSTR(p_str, l_beg_pos, l_end_pos - l_beg_pos);
   END;
   ---
   -- Consume a number
   ---
   FUNCTION consume_number (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_ws IN BOOLEAN := TRUE
   )
   RETURN VARCHAR2
   IS
      l_chr VARCHAR2(1 CHAR);
      l_beg_pos PLS_INTEGER := p_pos;
      l_end_pos PLS_INTEGER := p_pos;
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN NOT l_chr BETWEEN '0' AND '9'
               AND NOT l_chr IN ('.');
         p_pos := p_pos + 1;
      END LOOP;
      l_end_pos := p_pos;
      IF p_ws THEN
         consume_white_spaces(p_str, p_pos, p_len);
      END IF;
      RETURN SUBSTR(p_str, l_beg_pos, l_end_pos - l_beg_pos);
   END;
   ---
   -- Consume an integer
   ---
   FUNCTION consume_integer (
      p_str IN VARCHAR2
    , p_pos IN OUT PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_ws IN BOOLEAN := TRUE
   )
   RETURN VARCHAR2
   IS
      l_chr VARCHAR2(1 CHAR);
      l_beg_pos PLS_INTEGER := p_pos;
      l_end_pos PLS_INTEGER := p_pos;
   BEGIN
      LOOP
         EXIT WHEN p_pos > p_len;
         l_chr := SUBSTR(p_str,p_pos,1);
         EXIT WHEN NOT l_chr BETWEEN '0' AND '9';
         p_pos := p_pos + 1;
      END LOOP;
      l_end_pos := p_pos;
      IF p_ws THEN
         consume_white_spaces(p_str, p_pos, p_len);
      END IF;
      RETURN SUBSTR(p_str, l_beg_pos, l_end_pos - l_beg_pos);
   END;
   ---
   -- Check if a version number is valid
   ---
   FUNCTION is_valid_ver_nbr (
      p_ver_code IN dbm_versions.ver_code%TYPE
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN LOWER(p_ver_code)='all' OR regexp_like(p_ver_code,'^[0-9]{1,2}(\.[0-9]{1,2}){0,2}$');
   END;
   ---
   -- Get a version number from code
   ---
   FUNCTION get_version_nbr (
      p_ver_code IN dbm_versions.ver_code%TYPE
   )
   RETURN dbm_versions.ver_nbr%TYPE
   IS
      l_ver_nbr dbm_versions.ver_nbr%TYPE := 0;
      l_pos PLS_INTEGER := 1;
      l_len PLS_INTEGER := LENGTH(p_ver_code);
      l_buf dbm_versions.ver_code%TYPE;
      k_err_msg VARCHAR2(60) := 'Invalid version format (must be "xx.yy.zz", got "'||p_ver_code||'")!';
   BEGIN
      IF p_ver_code IS NULL THEN
         RETURN NULL;
      END IF;
      assert(is_valid_ver_nbr(p_ver_code),k_err_msg);
      IF LOWER(p_ver_code) = 'all' THEN
         RETURN 0;
      END IF;
      FOR i IN 1..3 LOOP
         l_ver_nbr := l_ver_nbr * 100;
         IF l_pos <= l_len THEN
            l_buf := consume_integer(p_ver_code, l_pos, l_len);
            IF l_buf IS NOT NULL THEN
               l_ver_nbr := l_ver_nbr + TO_NUMBER(l_buf);
            END IF;
            IF SUBSTR(p_ver_code, l_pos, 1) = '.' THEN
               l_pos := l_pos + 1;
            END IF;
         END IF;
      END LOOP;
      assert(l_pos > l_len, k_err_msg);
      RETURN l_ver_nbr;
   END;
--#begin public
   ---
   -- Update version time status
   ---
   PROCEDURE recompute_ver_statuses (
      p_app_code IN dbm_applications.app_code%TYPE := NULL
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
   )
--#end public
   IS
      -- Cursor to browse applications
      CURSOR c_app (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
          ORDER BY app_code
      ;
      -- Cursor to browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND ver_nbr > 0
            AND ver_nbr = (
                  SELECT MAX(ver_nbr)
                    FROM dbm_versions
                   WHERE app_code = p_app_code
                     AND ver_nbr > 0
                     AND ver_status = 'CURRENT'
                )
         ;
      -- Cursor to get version of tools already installed via the plsql installer
      CURSOR c_old IS
         SELECT LOWER(SUBSTR(vw.view_name,1,LENGTH(vw.view_name)-23))||'_utility' app_code, vw.view_name
           FROM sys.user_views vw
          INNER JOIN sys.user_tab_columns col
             ON col.table_name = vw.view_name
            AND col.column_name = 'VERSION'
          INNER JOIN sys.user_objects obj
             ON obj.object_type = 'VIEW'
            AND obj.object_name = vw.view_name
          WHERE SUBSTR(view_name,-23) = '_CURRENT_SCHEMA_VERSION'
            AND obj.status = 'VALID'
          MINUS
         SELECT app_code, UPPER(app_code)||'_CURRENT_SCHEMA_VERSION'
           FROM dbm_versions
          WHERE ver_status = 'CURRENT'
         ;
      r_curr_ver dbm_versions%ROWTYPE;
   BEGIN
      <<migrate_plsql_installer>>
      -- Get version number of PL/SQL utilities installed by the former pl/sql installer (replaced with the present dbm_utility) + drop all table and view (w/o reporting errors)
      BEGIN
         FOR r_old IN c_old LOOP
            EXECUTE IMMEDIATE REPLACE('UPDATE dbm_versions SET ver_status="CURRENT" WHERE (app_code, ver_code) IN (SELECT "'||r_old.app_code||'", version FROM '||r_old.view_name||')','"','''');
            EXECUTE IMMEDIATE 'DROP VIEW '||r_old.view_name;
            EXECUTE IMMEDIATE 'DROP TABLE '||REPLACE(r_old.view_name,'_CURRENT');
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
      -- Reset status
      UPDATE dbm_versions
         SET ver_status = NULL
       WHERE ver_status != 'CURRENT'
      ;
      -- Compute new status
      FOR r_app IN c_app(p_app_code) LOOP
         r_curr_ver := NULL;
         OPEN c_ver(r_app.app_code);
         FETCH c_ver INTO r_curr_ver;
         CLOSE c_ver;
         IF r_curr_ver.ver_code IS NULL THEN
            -- No current version => last installable version will be next
            UPDATE dbm_versions
               SET ver_status = 'NEXT'
                 , next_op_type = 'INSTALL'
                 , last_op_type = NULL
                 , last_op_status = NULL
                 , last_op_date = NULL
             WHERE app_code = r_app.app_code
               AND ver_nbr > 0
               AND ver_nbr = (
                      SELECT MAX(ver_nbr)
                        FROM dbm_versions
                       WHERE app_code = r_app.app_code
                         AND (p_ver_code IS NULL OR ver_code = p_ver_code)
                         AND installable = 'Y'
                   )
            ;
--            DELETE dbm_files
--             WHERE app_code = r_app.app_code
--               AND type != 'UNINSTALL'
--            ;            UPDATE dbm_versions
--              SET last_op_type = NULL
--                , last_op_status = NULL
--                , last_op_date = NULL
--            WHERE app_code = r_app.app_code
--              AND last_op_type != 'UNINSTALL'
--              AND last_op_status != 'ONGOING'
--            ;
            UPDATE dbm_applications
               SET ver_code = NULL
                 , ver_status = NULL
             WHERE app_code = r_app.app_code
            ;
         ELSE
            -- Update current
            UPDATE dbm_versions
               SET next_op_type = NULL
             WHERE app_code = r_app.app_code
               AND ver_nbr = r_curr_ver.ver_nbr
            ;
            -- One current version found => next upgradeable version will be next
            UPDATE dbm_versions
               SET ver_status = 'NEXT'
                 , next_op_type = 'UPGRADE'
                 , last_op_type = NULL
                 , last_op_status = NULL
                 , last_op_date = NULL
             WHERE app_code = r_app.app_code
               AND ver_nbr > 0
               AND ver_nbr = (
                      SELECT MIN(ver_nbr)
                        FROM dbm_versions
                       WHERE app_code = r_app.app_code
                         AND ver_nbr > 0
                         AND upgradeable = 'Y'
                         AND ver_nbr > r_curr_ver.ver_nbr
                   )
            ;
--            DELETE dbm_files
--             WHERE app_code = r_app.app_code
--               AND type = 'UNINSTALL'
--            ;
--            UPDATE dbm_versions
--              SET last_op_type = NULL
--                , last_op_status = NULL
--                , last_op_date = NULL
--            WHERE app_code = r_app.app_code
--              AND last_op_type = 'UNINSTALL'
--              AND last_op_status != 'ONGOING'
--            ;
            UPDATE dbm_applications
               SET ver_code = r_curr_ver.ver_code
                 , ver_status = NULL
             WHERE app_code = r_app.app_code
               AND (ver_code IS NULL OR ver_code != r_curr_ver.ver_code)
            ;
         END IF;
         -- Version before LAST CURRENT or NEXT (if no CURRENT) are PAST
         UPDATE dbm_versions
            SET ver_status = 'PAST'
              , next_op_type = NULL
          WHERE app_code = r_app.app_code
            AND ver_nbr > 0
            AND ver_nbr < (
                   SELECT MIN(ver_nbr)
                     FROM dbm_versions
                    WHERE app_code = r_app.app_code
                      AND ver_nbr > 0
                      AND (r_curr_ver.ver_nbr IS NULL OR ver_nbr = r_curr_ver.ver_nbr)
                      AND (r_curr_ver.ver_nbr IS NOT NULL OR ver_status = 'NEXT')
                )
         ;
         -- Versions after CURRENT or NEXT are FUTURE
         UPDATE dbm_versions
            SET ver_status = CASE WHEN upgradeable = 'Y' THEN 'FUTURE' ELSE 'N/A' END
              , next_op_type = CASE WHEN upgradeable = 'Y' THEN 'UPGRADE' END
              , last_op_type = NULL
              , last_op_status = NULL
              , last_op_date = NULL
          WHERE app_code = r_app.app_code
            AND ver_nbr > 0
            AND ver_nbr > (
                   SELECT MAX(ver_nbr)
                     FROM dbm_versions
                    WHERE app_code = r_app.app_code
                      AND ver_nbr > 0
                      AND ver_status IN ('CURRENT','NEXT')
                )
         ;
      END LOOP;
      -- Identify the current version of the present tool if not set
      UPDATE dbm_versions
         SET ver_status = 'CURRENT'
       WHERE app_code = 'dbm_utility'
         AND ver_status = 'NEXT'
         AND next_op_type = 'INSTALL'
         AND NOT EXISTS (
                SELECT 'x'
                  FROM dbm_versions
                 WHERE app_code = 'dbm_utility'
                   AND ver_status = 'CURRENT'
             );
   END;
--#begin public
   ---
   -- Update version properties
   ---
   PROCEDURE update_ver (
      p_app_code dbm_versions.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_status dbm_versions.ver_status%TYPE := '~'
    , p_next_op_type dbm_versions.next_op_type%TYPE := '~'
    , p_last_op_type dbm_versions.last_op_type%TYPE := '~'
    , p_last_op_status dbm_versions.last_op_status%TYPE := '~'
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_versions
         SET ver_status = CASE p_ver_status WHEN '~' THEN ver_status ELSE p_ver_status END
           , next_op_type = CASE p_next_op_type WHEN '~' THEN next_op_type ELSE p_next_op_type END
           , last_op_type = CASE p_last_op_type WHEN '~' THEN last_op_type ELSE p_last_op_type END
           , last_op_date = CASE p_last_op_type WHEN '~' THEN last_op_date ELSE SYSDATE END
           , last_op_status = CASE p_last_op_status WHEN '~' THEN last_op_status ELSE p_last_op_status END
       WHERE app_code = p_app_code
         AND ver_code = p_ver_code
      ;
      assert(SQL%ROWCOUNT=1,'Unable to update version "'||p_ver_code||'" of application "'||p_app_code||'"!');
      recompute_ver_statuses;
      COMMIT;
   END;
--#begin public
   ---
   -- Update file properties
   ---
   PROCEDURE update_fil (
      p_path dbm_files.ver_code%TYPE
    , p_hash dbm_files.hash%TYPE := '~'
    , p_status dbm_files.status%TYPE := '~'
    , p_run_status dbm_files.run_status%TYPE := '~'
    , p_run_condition dbm_files.run_condition%TYPE := '~'
    , p_raise_exception IN BOOLEAN := TRUE
   )
--#end public
   IS
   BEGIN
      UPDATE dbm_files
         SET hash = DECODE(p_hash,'~',hash,p_hash)
           , status = DECODE(p_status,'~',status,p_status)
           , run_status = DECODE(p_run_status,'~',run_status,p_run_status)
           , run_date = CASE WHEN NVL(p_run_status,'~') != '~' THEN SYSDATE ELSE run_date END
           , run_condition = DECODE(p_run_condition,'~',run_condition,p_run_condition)
       WHERE path = p_path
      ;
      IF p_raise_exception THEN
         assert(SQL%ROWCOUNT=1,'Unable to update status of file "'||p_path||'"');
      END IF;
      COMMIT;
   END;
   ---
   -- Define substitution variables before migrating to an application version
   ---
   PROCEDURE define_variables (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , pr_ver dbm_versions%ROWTYPE
    , p_type IN dbm_streams.type%TYPE
   )
   IS
      t_cfg dbm_utility_var.gt_var_type;
      l_app_code dbm_applications.app_code%TYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      r_cfg dbm_variables%ROWTYPE;
      r_var dbm_variables%ROWTYPE;
      l_cnt PLS_INTEGER := 0;
   BEGIN
      -- Define variables for app/ver: app/v, app/0, all/0
      FOR i IN 1..3 LOOP
         l_app_code := CASE WHEN i <= 2 THEN pr_ver.app_code ELSE 'all' END;
         l_ver_nbr := CASE WHEN i = 1 THEN pr_ver.ver_nbr ELSE 0 END;
         IF  dbm_utility_var.ga_app.EXISTS(l_app_code)
         AND dbm_utility_var.ga_app(l_app_code).EXISTS(l_ver_nbr)
         THEN
            t_cfg := dbm_utility_var.ga_app(l_app_code)(l_ver_nbr).t_var;
            FOR i IN 1..t_cfg.COUNT LOOP
               r_cfg := t_cfg(i);
               r_var := get_var(l_app_code, r_cfg.name);
               assert(r_cfg.nullable = 'Y' OR r_var.value IS NOT NULL, 'Variable "'||r_cfg.name||'" not set, please "configure"!');
               output_line(p_cmd_id,'IN','define '||r_cfg.name||'="'||r_var.value||'"');
               l_cnt := l_cnt + 1;
            END LOOP;
         END IF;
      END LOOP;
      IF l_cnt > 0 THEN
         output_line(p_cmd_id,'IN','set scan on');
         output_line(p_cmd_id,'IN','set verify off');
         output_line(p_cmd_id,'IN','set define on');
      END IF;
   END;
   ---
   -- Get a file from its path
   ---
   FUNCTION get_file (
      p_path dbm_files.path%TYPE
   )
   RETURN dbm_files%ROWTYPE
   IS
      CURSOR c_fil IS
         SELECT *
           FROM dbm_files
          WHERE path = p_path
      ;
      r_fil dbm_files%ROWTYPE;
   BEGIN
      OPEN c_fil;
      FETCH c_fil INTO r_fil;
      CLOSE c_fil;
      RETURN r_fil;
   END;
   ---
   -- Get file run status
   ---
   FUNCTION get_file_run_status (
      p_path dbm_files.path%TYPE
   )
   RETURN dbm_files.run_status%TYPE
   IS
      r_fil dbm_files%ROWTYPE;
   BEGIN
      r_fil := get_file(p_path);
      RETURN r_fil.run_status;
   END;
   ---
   -- Split full path name into directory and file
   ---
   PROCEDURE split_path (
      p_path IN VARCHAR2
    , p_dir OUT VARCHAR2
    , p_file OUT VARCHAR2
    , p_keep_sep IN BOOLEAN := FALSE
   )
   IS
      l_pos PLS_INTEGER;
   BEGIN
      l_pos := NVL(INSTR(p_path, '\', -1),0);
      IF l_pos = 0 THEN
         l_pos := NVL(INSTR(p_path, '/', -1),0);
      END IF;
      p_dir := SUBSTR(p_path,1,l_pos - CASE WHEN p_keep_sep THEN 0 ELSE 1 END);
      p_file := SUBSTR(p_path,l_pos + CASE WHEN p_keep_sep THEN 0 ELSE 1 END);
   END;
   ---
   -- Get directory from file path
   ---
   FUNCTION get_dir (
      p_path IN VARCHAR2
    , p_keep_sep IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_dir VARCHAR2(4000);
      l_file VARCHAR2(4000);
   BEGIN
      split_path(p_path, l_dir, l_file, p_keep_sep);
      RETURN l_dir;
   END;
   ---
   -- Get filename from file path
   ---
   FUNCTION get_filename (
      p_path IN VARCHAR2
    , p_keep_sep IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
      l_dir VARCHAR2(4000);
      l_file VARCHAR2(4000);
   BEGIN
      split_path(p_path, l_dir, l_file, p_keep_sep);
      RETURN l_file;
   END;
--#begin public
   ---
   -- Give feedback on file integrity
   ---
   PROCEDURE report_on_files_integrity (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
--#end public
   IS
      CURSOR c_fil (
         p_all_status IN VARCHAR2 -- Y/N
      )
      IS
         SELECT fil.*
           FROM dbm_files fil
          INNER JOIN dbm_versions ver
             ON ver.app_code = fil.app_code
            AND ver.ver_code = fil.ver_code
          INNER JOIN dbm_applications app
             ON app.app_code = fil.app_code
          WHERE (NVL(p_app_code,'all')='all' OR fil.app_code = p_app_code)
            AND (p_ver_code IS NULL OR fil.ver_code = p_ver_code)
            AND fil.type IN ('INSTALL','UPGRADE')
            AND fil.run_status = 'SUCCESS'
            AND (p_all_status = 'Y' OR fil.status != 'NORMAL')
         ORDER BY app.seq, ver.ver_nbr, fil.seq
      ;
      l_file_count PLS_INTEGER := 0;
   BEGIN
      FOR r_fil IN c_fil(CASE WHEN dbm_utility_var.g_debug THEN 'Y' ELSE 'N' END) LOOP
         IF r_fil.status != 'NORMAL' THEN
            l_file_count := l_file_count + 1;
         END IF;
         dbms_output.put_line('File "'||r_fil.path||'" executed for '
            || CASE WHEN r_fil.type = 'INSTALL' THEN 'installing' ELSE 'upgrading to' END
            ||' version "'||r_fil.ver_code||'" of application "'||r_fil.app_code||'" is '||LOWER(r_fil.status));
      END LOOP;
      IF l_file_count = 0 THEN
         dbms_output.put_line('All good, no file already executed is tampered or missing.');
      END IF;
   END;
   ---
   -- Get parameter value for an application version (or all versions if not found)
   ---
   FUNCTION get_par_value (
      p_app_code dbm_applications.app_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE
    , p_par_name dbm_utility_var.g_par_name_type
    , p_par_def dbm_utility_var.g_par_value_type := NULL
   )
   RETURN dbm_utility_var.g_par_value_type
   IS
      l_app_code dbm_applications.app_code%TYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
   BEGIN
      FOR x IN 1..2 LOOP
         l_app_code := CASE x WHEN 1 THEN p_app_code ELSE 'all' END;
         FOR y IN 1..2 LOOP
            l_ver_nbr := CASE y WHEN 1 THEN p_ver_nbr ELSE 0 END;
            IF  dbm_utility_var.ga_app.EXISTS(l_app_code)
            AND dbm_utility_var.ga_app(l_app_code).EXISTS(l_ver_nbr)
            AND dbm_utility_var.ga_app(l_app_code)(l_ver_nbr).a_par.EXISTS(p_par_name)
            THEN
               RETURN dbm_utility_var.ga_app(l_app_code)(l_ver_nbr).a_par(p_par_name);
            END IF;
            EXIT WHEN p_ver_nbr = 0;
         END LOOP;
      END LOOP;
      RETURN p_par_def;
   END;
   ---
   -- Get application
   ---
   FUNCTION get_app (
      p_app_code dbm_applications.app_code%TYPE
   )
   RETURN dbm_applications%ROWTYPE
   IS
      CURSOR c_app IS
         SELECT *
           FROM dbm_applications
          WHERE app_code = p_app_code
      ;
      r_app dbm_applications%ROWTYPE;
   BEGIN
      OPEN c_app;
      FETCH c_app INTO r_app;
      CLOSE c_app;
      RETURN r_app;
   END;
   ---
   -- Get "apps" directory from parameters
   ---
   FUNCTION get_apps_dir (
      p_slash IN BOOLEAN := FALSE
   )
   RETURN VARCHAR2
   IS
   BEGIN
      RETURN get_par_value('dbm_utility', 0, 'apps_dir','apps') || CASE WHEN p_slash THEN CASE dbm_utility_var.g_os_name WHEN 'Linux' THEN '/' ELSE '\' END END;
   END;
   ---
   -- Check integrity of files executed so far
   ---
   PROCEDURE check_files (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
   IS
      CURSOR c_fil IS
         SELECT DISTINCT SUBSTR(path,1,INSTR(REPLACE(path,'/','\'),'\',-1)-1) dir
           FROM dbm_files
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND (p_ver_code IS NULL OR ver_code = p_ver_code)
            AND type IN ('INSTALL','UPGRADE')
            AND run_status = 'SUCCESS'
      ;
      l_apps_dir dbm_utility_var.g_par_value_type := get_apps_dir(TRUE);
   BEGIN
      UPDATE dbm_files
         SET status = 'MISSING'
       WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
         AND (p_ver_code IS NULL OR ver_code = p_ver_code)
         AND run_status = 'SUCCESS'
      ;
      output_line(p_cmd_id, 'IN', 'prompt Checking integrity of executed files...');
      FOR r_fil IN c_fil LOOP
         IF dbm_utility_var.g_debug THEN
            output_line(p_cmd_id, 'IN', 'prompt Checking files in '||l_apps_dir||r_fil.dir||'...');
         END IF;
         output_line(p_cmd_id, 'IN', 'host bin\get-hashes '||l_apps_dir||r_fil.dir||' ' ||p_cmd_id||' chk-hashes '||l_apps_dir||' >tmp\get-hashes.sql');
         output_line(p_cmd_id, 'IN', '@@tmp\get-hashes.sql');
      END LOOP;
      output_line(p_cmd_id, 'IN', REPLACE('exec dbm_utility_krn.report_on_files_integrity(p_cmd_id=>'||p_cmd_id||', p_app_code=>"'||p_app_code||'", p_ver_code=>"'||p_ver_code||'")','"',''''));
      COMMIT;
   END;
   ---
   -- Read configuration file of an application
   ---
   PROCEDURE read_config (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_apps_config IN BOOLEAN := TRUE
    , p_inventories IN BOOLEAN := TRUE
--    , p_app_code IN dbm_applications.app_code%TYPE
   )
   IS
   BEGIN
      IF p_apps_config THEN
         IF dbm_utility_var.g_debug THEN
            output_line(p_cmd_id, 'IN', 'prompt Reading apps configuration (*.conf) under "'||get_apps_dir||'"...');
         ELSE
            output_line(p_cmd_id, 'IN', 'prompt Reading apps configuration...');
         END IF;
         output_line(p_cmd_id, 'IN', 'host bin\read-files '||get_apps_dir||' *.conf '||p_cmd_id||' >tmp\read-files.sql');
         output_line(p_cmd_id, 'IN', '@@tmp\read-files');
   --      output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.parse_configuration('||p_cmd_id||')');
      END IF;
      IF p_inventories THEN
         IF dbm_utility_var.g_debug THEN
            output_line(p_cmd_id, 'IN', 'prompt Reading db objects and files inventories (*.dbm) under "'||get_apps_dir||'"...');
         ELSE
            output_line(p_cmd_id, 'IN', 'prompt Reading db objects and files inventories...');
         END IF;
         output_line(p_cmd_id, 'IN', 'host bin\read-files '||get_apps_dir||' *.dbm '||p_cmd_id||' >tmp\read-files.sql');
         output_line(p_cmd_id, 'IN', '@@tmp\read-files');
      END IF;
      IF p_apps_config OR p_inventories THEN
         IF dbm_utility_var.g_debug THEN
            output_line(p_cmd_id, 'IN', 'prompt Parsing configuration and/or inventories...');
         END IF;
         output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.parse_configuration('||p_cmd_id||')');
      END IF;
   END;
--#begin public
   ---
   -- Make database object inventory
   ---
   PROCEDURE make_inventory (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
--#end public
   IS
      -- Browse applications
      CURSOR c_app IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
       , p_ver_code dbm_versions.ver_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND ((p_ver_code IS NULL AND ver_status = 'CURRENT') OR (p_ver_code IS NOT NULL AND ver_code = p_ver_code))
            AND ver_nbr > 0
      ;
      r_ver dbm_versions%ROWTYPE;
      l_sql VARCHAR2(4000);
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
      l_fil_path dbm_files.path%TYPE;
      l_public dbm_parameters.value%TYPE;
      l_found BOOLEAN;
   BEGIN
      <<app_loop>>
      FOR r_app IN c_app LOOP
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         -- Get current or specified version
         OPEN c_ver(r_app.app_code, p_ver_code);
         FETCH c_ver INTO r_ver;
         l_found := c_ver%FOUND;
         CLOSE c_ver;
         assert(l_found, 'No version found for application "'||r_app.app_code||'"');
         -- Get application patterns
         l_obj_name_pattern := get_par_value(r_app.app_code, 0, 'object_name_pattern');
         l_obj_name_anti_pattern := get_par_value(r_app.app_code, 0, 'object_name_anti_pattern', '^$');
--         l_public := CASE WHEN NVL(LOWER(get_var_value(r_app.app_code, 'public', TRUE)),'false') = 'true' THEN 'Y' ELSE 'N' END;
         l_public := 'Y'; -- always add PUBLIC synonyms and grants to the DB objects inventory
         l_fil_path := get_apps_dir(TRUE)||r_app.home_dir||'\releases\'||r_ver.ver_code||'\config\objects.dbm';
         output_line(p_cmd_id, 'IN', 'prompt Making DB objects inventory of application "'||r_app.app_code||'" version "'||r_ver.ver_code||'...');
         output_line(p_cmd_id, 'IN', 'set termout off');
         output_line(p_cmd_id, 'IN', 'spool '||l_fil_path);
         l_sql := REPLACE('select * from table(dbm_utility_krn.list_db_objects(p_obj_name_pattern=>"'||l_obj_name_pattern||'", p_obj_name_anti_pattern=>"'||l_obj_name_anti_pattern||'", p_checksum=>"Y", p_condition=>"Y", p_public=>"'||l_public||'", p_app_code=>"'||r_app.app_code||'", p_ver_code=>"'||r_ver.ver_code||'"));','"','''');
         output_line(p_cmd_id, 'IN', 'prompt # '||l_sql);
         output_line(p_cmd_id, 'IN', l_sql);
         output_line(p_cmd_id, 'IN', 'spool off');
         output_line(p_cmd_id, 'IN', 'set termout on');
         output_line(p_cmd_id, 'IN', 'prompt DB objects inventory saved into "'||l_fil_path||'".');
         read_config(p_cmd_id=>p_cmd_id, p_apps_config=>FALSE, p_inventories=>TRUE);
         output_line(p_cmd_id, 'IN', REPLACE('exec dbm_utility_krn.save_cache("'||r_app.app_code||'")','"',''''));
      END LOOP app_loop;
   END;
--#begin public
   ---
   -- Set current version of an application
   ---
   PROCEDURE set_current (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE -- no support for all
    , p_ver_code IN dbm_versions.ver_code%TYPE
    , p_guess_curr IN BOOLEAN := FALSE
   )
--#end public
   IS
      l_guess_curr VARCHAR2(1) := CASE WHEN p_guess_curr THEN 'Y' ELSE 'N' END;
   BEGIN
      UPDATE dbm_versions
         SET ver_status = NULL
       WHERE app_code = p_app_code
         AND ver_status = 'CURRENT';
      UPDATE dbm_versions
         SET ver_status = 'CURRENT'
           , next_op_type = NULL
           , last_op_type = CASE WHEN l_guess_curr = 'Y' THEN 'GUESS CURRENT' ELSE 'SET CURRENT' END
           , last_op_status = 'SUCCESS'
           , last_op_date = SYSDATE
       WHERE app_code = p_app_code
         AND ver_code = p_ver_code;
      assert(SQL%ROWCOUNT>=1,'Cannot set version of application "'||p_app_code||'" to "'||p_ver_code||'"');
      dbms_output.put_line('Current version of application "'||p_app_code||'" set to "'||p_ver_code||'"');
      recompute_ver_statuses(p_app_code);
      COMMIT;
   END;
   ---
   -- Get file extension from a path
   ---
   FUNCTION get_file_extension (
      p_path IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_pos PLS_INTEGER;
   BEGIN
      l_pos := NVL(INSTR(p_path, '.', -1),0);
      RETURN CASE WHEN l_pos > 0 THEN SUBSTR(p_path, l_pos+1) ELSE NULL END;
   END;
   ---
   -- Get basename from a file path
   ---
   FUNCTION get_basename (
      p_path IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      l_pos1 PLS_INTEGER;
      l_pos2 PLS_INTEGER;
   BEGIN
      l_pos1 := NVL(INSTR(p_path, '\', -1),0);
      IF l_pos1 = 0 THEN
         l_pos1 := NVL(INSTR(p_path, '/', -1),0);
      END IF;
      l_pos1 := l_pos1 + 1;
      l_pos2 := NVL(INSTR(p_path, '.', -1),0);
      IF l_pos2 < l_pos1 THEN
         l_pos2 := 0;
      END IF;
      RETURN CASE WHEN l_pos2 > 0 THEN SUBSTR(p_path, l_pos1, l_pos2-l_pos1) ELSE SUBSTR(p_path, l_pos1) END;
   END;
   ---
   -- Check whether the run condition of a file is met
   ---
   FUNCTION file_condition_met (
      p_app_code dbm_applications.app_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE
    , p_path dbm_files.path%TYPE
    , p_run_condition dbm_files.run_condition%TYPE
   )
   RETURN BOOLEAN
   IS
      l_exp dbm_files.run_condition%TYPE := p_run_condition;
      l_name dbm_variables.name%TYPE;
      l_value dbm_variables.value%TYPE;
      l_ch VARCHAR2(1 CHAR);
      l_beg PLS_INTEGER;
      l_pos PLS_INTEGER;
   BEGIN
      IF l_exp IS NOT NULL THEN
         LOOP
            l_beg := NVL(INSTR(l_exp,CHR(38)),0); --ampersand
            EXIT WHEN l_beg <= 0;
            l_pos := l_beg + 1;
            IF SUBSTR(l_exp, l_pos, 1) = CHR(38) THEN
               l_pos := l_pos + 1;
            END IF;
            LOOP
               l_ch := SUBSTR(l_exp, l_pos, 1);
               EXIT WHEN NOT l_ch BETWEEN 'A' AND 'Z'
                     AND NOT l_ch BETWEEN 'a' AND 'z'
                     AND NOT l_ch BETWEEN '0' AND '9'
                     AND NOT l_ch = '_';
               l_name := l_name || LOWER(l_ch);
               l_pos := l_pos + 1;
            END LOOP;
            assert(l_name IS NOT NULL, 'Missing variable/parameter name in conditional expression "'||REPLACE(p_run_condition,CHR(38),'$')||'" for file: "'||p_path||'"');
            l_value := get_var_value(p_app_code, l_name, TRUE);
            IF l_value IS NULL THEN
               l_value := get_par_value(p_app_code, p_ver_nbr, l_name);
               IF l_value IS NULL THEN
                  l_value := get_par_value('dbm_utility', 0, l_name);
               END IF;
            END IF;
            l_exp := SUBSTR(l_exp, 1, l_beg-1)
                  || l_value
                  || SUBSTR(l_exp, l_pos);
         END LOOP;
         DECLARE
            l_sql dbm_utility_var.g_sql_type;
            l_dummy VARCHAR2(1);
         BEGIN
            l_sql := 'SELECT ''x'' FROM dual WHERE '||l_exp;
            EXECUTE IMMEDIATE l_sql INTO l_dummy;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF dbm_utility_var.g_debug THEN
                  dbms_output.put_line('Conditional expression "'||REPLACE(p_run_condition,CHR(38),'$')||'" evaluated to "'||REPLACE(l_exp,CHR(38),'$')||'" is false');
               END IF;
               RETURN FALSE;
            WHEN OTHERS THEN
               raise_application_error(-20000,'Invalid conditional expression "'||REPLACE(p_run_condition,CHR(38),'$')||'" for file "'||p_path||'"');
         END;
      END IF;
      RETURN TRUE;
   END;
   ---
   -- Check whether the condition of an object is met
   ---
   FUNCTION object_condition_met (
      p_app_code dbm_applications.app_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE
    , p_name dbm_objects.name%TYPE
    , p_condition dbm_objects.condition%TYPE
   )
   RETURN BOOLEAN
   IS
      l_exp dbm_objects.condition%TYPE := p_condition;
      l_name dbm_variables.name%TYPE;
      l_value dbm_variables.value%TYPE;
      l_ch VARCHAR2(1 CHAR);
      l_beg PLS_INTEGER;
      l_pos PLS_INTEGER;
   BEGIN
      IF l_exp IS NOT NULL THEN
         LOOP
            l_beg := NVL(INSTR(l_exp,CHR(38)),0); --ampersand
            EXIT WHEN l_beg <= 0;
            l_pos := l_beg + 1;
            IF SUBSTR(l_exp, l_pos, 1) = CHR(38) THEN
               l_pos := l_pos + 1;
            END IF;
            LOOP
               l_ch := SUBSTR(l_exp, l_pos, 1);
               EXIT WHEN NOT l_ch BETWEEN 'A' AND 'Z'
                     AND NOT l_ch BETWEEN 'a' AND 'z'
                     AND NOT l_ch BETWEEN '0' AND '9'
                     AND NOT l_ch = '_';
               l_name := l_name || LOWER(l_ch);
               l_pos := l_pos + 1;
            END LOOP;
            assert(l_name IS NOT NULL, 'Missing variable/paramenter name in conditional expression "'||REPLACE(p_condition,CHR(38),'$')||'" for object: "'||p_name||'"');
            l_value := get_var_value(p_app_code, l_name, TRUE);
            IF l_value IS NULL THEN
               l_value := get_par_value(p_app_code, p_ver_nbr, l_name);
               IF l_value IS NULL THEN
                  l_value := get_par_value('dbm_utility', 0, l_name);
               END IF;
            END IF;
            l_exp := SUBSTR(l_exp, 1, l_beg-1)
                  || l_value
                  || SUBSTR(l_exp, l_pos);
         END LOOP;
         DECLARE
            l_sql dbm_utility_var.g_sql_type;
            l_dummy VARCHAR2(1);
         BEGIN
            l_sql := 'SELECT ''x'' FROM dual WHERE '||l_exp;
            EXECUTE IMMEDIATE l_sql INTO l_dummy;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF dbm_utility_var.g_debug THEN
                  dbms_output.put_line('Conditional expression "'||REPLACE(p_condition,CHR(38),'$')||'" evaluated to "'||REPLACE(l_exp,CHR(38),'$')||'" is false');
               END IF;
               RETURN FALSE;
            WHEN OTHERS THEN
               raise_application_error(-20000,'Invalid conditional expression "'||REPLACE(p_condition,CHR(38),'$')||'" for object "'||p_name||'"');
         END;
      END IF;
      RETURN TRUE;
   END;
   ---
   -- Validate one or all applications
   ---
   PROCEDURE validate (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
    , p_from_other_op IN BOOLEAN := FALSE
   )
   IS
      -- Cursor to browse application
      CURSOR c_app (
         p_app_code dbm_applications.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND (NVL(p_app_code,'all')!='all' OR ver_code IS NOT NULL) -- exclude not installed apps
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Cursor to browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND (p_ver_code IS NULL OR ver_code = p_ver_code)
            AND (p_ver_code IS NOT NULL OR ver_status = 'CURRENT')
      ;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_files sys.dbms_sql.varchar2a;
      l_found BOOLEAN;
      r_ver dbm_versions%ROWTYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
      l_recompile BOOLEAN := FALSE;
      l_path dbm_files.path%TYPE;
      l_public dbm_parameters.value%TYPE;
   BEGIN
      l_recompile := LOWER(get_par_value('dbm_utility', 0, 'recompile_invalid_objects', 'yes')) IN ('true','yes','y');
      FOR r_app IN c_app(p_app_code) LOOP
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_app.app_code);
         OPEN c_ver(r_app.app_code);
         FETCH c_ver INTO r_ver;
         l_found := c_ver%FOUND;
         CLOSE c_ver;
         assert(l_found, 'Application "'||r_app.app_code||'" is not installed!');
         assert(lt_ver.EXISTS(r_ver.ver_nbr),'Version "'||r_ver.ver_code||'" of application "'||r_ver.app_code||'" not found on file system!');
         IF l_recompile THEN
            output_line(p_cmd_id,'IN','prompt Recompiling invalid objects in schema...');
            output_line(p_cmd_id,'IN','exec dbms_utility.compile_schema(schema=>USER, compile_all=>FALSE)');
            l_recompile := FALSE;
         END IF;
         output_line(p_cmd_id,'IN','prompt Validating application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'"...');
         define_variables(p_cmd_id, r_ver, 'IN');
         output_whenever_sqlerror(p_cmd_id, 'IN');
         IF NOT p_from_other_op THEN
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"VALIDATE", p_last_op_status=>"ONGOING")','"',''''));
         END IF;
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.upsert_app(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_ver_status=>"INVALID")','"',''''));
         l_obj_name_pattern := get_par_value(r_app.app_code, r_ver.ver_nbr, 'object_name_pattern');
         l_obj_name_anti_pattern := get_par_value(r_app.app_code, r_ver.ver_nbr, 'object_name_anti_pattern', '^$');
         l_public := CASE WHEN NVL(LOWER(get_var_value(r_app.app_code, 'public', TRUE)),'false') = 'true' THEN 'Y' ELSE 'N' END;
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.check_objects(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_obj_name_pattern=>"'||l_obj_name_pattern||'",p_obj_name_anti_pattern=>"'||l_obj_name_anti_pattern||'",p_public=>"'||l_public||'")','"',''''));
         FOR k IN 1..2 LOOP
            l_ver_nbr := CASE k WHEN 1 THEN r_ver.ver_nbr ELSE 0 END;
            IF lt_ver.EXISTS(l_ver_nbr) THEN
               lr_ver := lt_ver(l_ver_nbr);
               lt_files := lr_ver.t_val_files;
               FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
                  l_path := lt_files(i);
                  IF lr_ver.a_fil.EXISTS(l_path) AND NOT file_condition_met(r_ver.app_code, r_ver.ver_nbr, l_path, lr_ver.a_fil(l_path)) THEN
                     output_line(p_cmd_id,'IN','prompt Skipping script "'||get_apps_dir(TRUE)||l_path||'" (condition not met)...');
                  ELSE
                     output_line(p_cmd_id,'IN','prompt Executing script "'||get_apps_dir(TRUE)||l_path||'"...');
                     output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||l_path);
                  END IF;
                  EXIT WHEN lt_files.EXISTS(0);
               END LOOP;
            END IF;
         END LOOP;
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.upsert_app(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_ver_status=>"VALID")','"',''''));
         IF NOT p_from_other_op THEN
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_status=>"SUCCESS")','"',''''));
         END IF;
         output_line(p_cmd_id,'IN','prompt Validation of application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'" was successful');
      END LOOP;
   END;
   ---
   -- Parse a file path
   ---
   FUNCTION parse_path (
      p_path IN VARCHAR2
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      lt_path sys.dbms_sql.varchar2a;
      l_beg PLS_INTEGER := 1;
      l_pos PLS_INTEGER := 0;
      l_len PLS_INTEGER := LENGTH(p_path);
   BEGIN
      WHILE l_beg < l_len LOOP
         l_pos := NVL(INSTR(p_path,'/',l_beg),0);
         IF l_pos <= 0 THEN
            l_pos := NVL(INSTR(p_path,'\',l_beg),0);
         END IF;
         EXIT WHEN l_pos <= 0;
         IF l_pos - l_beg > 0 THEN
            lt_path(lt_path.COUNT+1) := SUBSTR(p_path,l_beg,l_pos-l_beg);
         END IF;
         l_beg := l_pos + 1;
      END LOOP;
      IF l_len - l_beg + 1 > 0 THEN
         lt_path(lt_path.COUNT+1) := SUBSTR(p_path,l_beg,l_len-l_beg+1);
      END IF;
      RETURN lt_path;
   END;
   ---
   -- Setup an application
   ---
   PROCEDURE setup (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
   )
   IS
      -- Cursor to browse application
      CURSOR c_app (
         p_app_code dbm_applications.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Cursor to browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND (p_ver_code IS NULL OR ver_code = p_ver_code)
            AND (p_ver_code IS NOT NULL OR ver_status = 'CURRENT')
      ;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_files sys.dbms_sql.varchar2a;
      l_found BOOLEAN;
      r_ver dbm_versions%ROWTYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      l_files_count PLS_INTEGER := 0;
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
   BEGIN
      FOR r_app IN c_app(p_app_code) LOOP
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_app.app_code);
         OPEN c_ver(r_app.app_code);
         FETCH c_ver INTO r_ver;
         l_found := c_ver%FOUND;
         CLOSE c_ver;
         assert(l_found, 'Application "'||r_app.app_code||'" is not installed!');
         assert(lt_ver.EXISTS(r_ver.ver_nbr),'Version "'||r_ver.ver_code||'" of application "'||r_ver.app_code||'" not found on file system!');
         output_line(p_cmd_id,'IN','prompt Setting up application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'"...');
         output_whenever_sqlerror(p_cmd_id, 'IN');
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"SETUP", p_last_op_status=>"ONGOING")','"',''''));
         output_line(p_cmd_id,'IN','define home_dir="'||get_apps_dir(TRUE)||r_app.home_dir||'"');
         output_line(p_cmd_id,'IN','define ver_code="'||r_ver.ver_code||'"');
         FOR k IN 1..2 LOOP
            l_ver_nbr := CASE k WHEN 1 THEN r_ver.ver_nbr ELSE 0 END;
            IF lt_ver.EXISTS(l_ver_nbr) THEN
               lr_ver := lt_ver(l_ver_nbr);
               lt_files := lr_ver.t_set_files;
               FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
                  output_line(p_cmd_id,'IN','prompt Executing script "'||get_apps_dir(TRUE)||lt_files(i)||'"...');
                  output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||lt_files(i));
                  l_files_count := l_files_count + 1;
                  EXIT WHEN lt_files.EXISTS(0);
               END LOOP;
            END IF;
         END LOOP;
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_status=>"SUCCESS")','"',''''));
         output_line(p_cmd_id,'IN','set termout on');
         IF l_files_count = 0 THEN
            output_line(p_cmd_id, 'IN', 'prompt No file was found to setup application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'"');
         ELSE
            output_line(p_cmd_id,'IN','prompt Setup of application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'" was successful');
         END IF;
      END LOOP;
   END;
   ---
   -- Roll back a failed migration
   ---
   PROCEDURE rollback_migration (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE -- no support for all
    , p_ver_code IN dbm_versions.ver_code%TYPE
   )
   IS
      -- Browse executed files in reverse order of their execution
      -- starting with the one whose run ended in error
      -- Rollback given version or next one (the one which failed)
      CURSOR c_fil IS
         SELECT fil.*, nxt.ver_code next_ver_code, cur.ver_code curr_ver_code
           FROM dbm_files fil
          INNER JOIN dbm_versions nxt
             ON nxt.app_code = fil.app_code
            AND nxt.ver_status = 'NEXT'
            AND nxt.ver_code = fil.ver_code
          INNER JOIN dbm_versions cur
             ON cur.app_code = fil.app_code
            AND cur.ver_status = 'CURRENT'
          WHERE fil.app_code = p_app_code
            AND fil.type IN ('INSTALL','UPGRADE')
            AND fil.run_status IN ('SUCCESS','ERROR','ONGOING')
          ORDER BY seq DESC
      ;
      l_dir VARCHAR2(4000);
      l_file_name VARCHAR2(4000);
      l_file_count PLS_INTEGER := 0;
      l_next_ver_code dbm_versions.ver_code%TYPE;
      l_fil_type dbm_files.type%TYPE;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_files sys.dbms_sql.varchar2a;
      r_fil2 dbm_files%ROWTYPE;
      l_path dbm_files.path%TYPE;
      l_found BOOLEAN;
      l_curr_ver_code dbm_versions.ver_code%TYPE;
   BEGIN
      assert(NVL(p_app_code,'all') != 'all','Rolling back migrations of all applications is not supported!');
      l_file_count := 0;
      FOR r_fil IN c_fil LOOP
         l_curr_ver_code := r_fil.curr_ver_code;
         assert(dbm_utility_var.ga_app.EXISTS(r_fil.app_code), 'Application "'||r_fil.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_fil.app_code);
         IF l_file_count = 0 THEN
--            EXIT WHEN r_fil.run_status != 'ERROR'; -- First file must be in error
            l_next_ver_code := r_fil.ver_code;
            output_line(p_cmd_id,'IN','prompt Rolling back '
               || CASE WHEN r_fil.type = 'INSTALL' THEN 'install of' ELSE 'upgrade to' END
               ||' version "'||r_fil.ver_code||'" of application "'||r_fil.app_code);
            l_fil_type := 'ROLLBACK '||r_fil.type;
            UPDATE dbm_files SET status = 'MISSING' WHERE app_code = r_fil.app_code AND ver_code = r_fil.ver_code AND type = l_fil_type;
         END IF;
         EXIT WHEN r_fil.ver_code != l_next_ver_code;
         split_path(r_fil.path, l_dir, l_file_name, TRUE);
         r_fil2 := NULL;
         r_fil2.app_code := r_fil.app_code;
         r_fil2.ver_code := r_fil.ver_code;
         r_fil2.path := l_dir || 'rollback' || l_file_name;
         r_fil2.type := l_fil_type;
         r_fil2.seq := 0 - r_fil.seq;
         r_fil2.status := 'NORMAL';
         r_fil2.hash := 'NULL';
         r_fil2.run_status := 'NULL';
         lr_ver := lt_ver(get_version_nbr(r_fil2.ver_code));
         IF r_fil2.type = 'ROLLBACK INSTALL' THEN
            lt_files := lr_ver.t_inr_files;
            assert(lr_ver.r_ver.install_rollbackable = 'Y','Install of version "'||r_fil.ver_code||'" of application "'||r_fil.app_code||'" is not rollbackable!');
         ELSE
            lt_files := lr_ver.t_upr_files;
            assert(lr_ver.r_ver.upgrade_rollbackable = 'Y','Upgrade of application "'||r_fil.app_code||'" to version "'||r_fil.ver_code||'" is not rollbackable!');
         END IF;
         l_found := FALSE;
         FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
            l_found := lt_files(i) = r_fil2.path;
            EXIT WHEN l_found;
         END LOOP;
         EXIT WHEN NOT l_found AND r_fil.run_status = 'SUCCESS';
         assert(l_found, 'Rollback file "'||r_fil2.path||'" not found!');
         IF l_file_count = 0 THEN
            output_whenever_sqlerror(p_cmd_id, 'IN');
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_fil2.app_code||'",p_ver_code=>"'||l_next_ver_code||'",p_last_op_type=>"'||l_fil_type||'", p_last_op_status=>"ONGOING", p_ver_status=>"")','"',''''));
         END IF;
         output_line(p_cmd_id,'IN','prompt Executing script "'||r_fil2.path||'"...');
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||r_fil2.path||'", p_status=>"'||r_fil2.status||'", p_run_status=>"ONGOING")','"',''''));
         output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||r_fil2.path);
         IF LOWER(get_file_extension(r_fil2.path)) IN ('pkb','pks','plb','pls') AND LOWER(get_par_value('dbm_utility', 0, 'show_compilation_errors', 'yes')) IN ('true','yes','y') THEN
            output_line(p_cmd_id,'IN','show errors');
         END IF;
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||r_fil2.path||'", p_run_status=>"SUCCESS")','"',''''));
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||r_fil.path||'", p_run_status=>"ROLLED BACK")','"',''''));
         l_file_count := l_file_count + 1;
      END LOOP;
      IF l_file_count = 0 THEN
         output_line(p_cmd_id, 'IN', 'prompt No file was found to rollback application "'||p_app_code||'"'||CASE WHEN p_ver_code IS NOT NULL THEN ' version "'||p_ver_code||'"' END);
      ELSE
         validate(p_cmd_id, p_app_code, l_curr_ver_code, TRUE);
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_fil2.app_code||'",p_ver_code=>"'||l_next_ver_code||'",p_last_op_type=>"'||l_fil_type||'", p_last_op_status=>"SUCCESS", p_ver_status=>"")','"',''''));
         output_line(p_cmd_id,'IN','COMMIT;'); -- all versions
         output_line(p_cmd_id,'IN','prompt Rollback of application "'||p_app_code||'" version "'||l_next_ver_code||'" to version "'||l_curr_ver_code||'" was successful');
      END IF;
   END;
   ---
   -- Parse a list (separator is comma or semi-colon)
   ---
   FUNCTION parse_list (
      p_line IN VARCHAR2
    , p_sep IN VARCHAR2
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      lt_lst sys.dbms_sql.varchar2a;
      l_beg PLS_INTEGER := 1;
      l_pos PLS_INTEGER := 0;
      l_len PLS_INTEGER := LENGTH(p_line);
   BEGIN
      WHILE l_beg < l_len LOOP
         l_pos := NVL(INSTR(p_line,p_sep,l_beg),0);
         EXIT WHEN l_pos < l_beg;
         IF l_pos > l_beg THEN
            lt_lst(lt_lst.COUNT+1) := TRIM(SUBSTR(p_line,l_beg,l_pos-l_beg));
         END IF;
         l_beg := l_pos + 1;
      END LOOP;
      IF l_beg < l_len THEN
         lt_lst(lt_lst.COUNT+1) := TRIM(SUBSTR(p_line,l_beg));
      END IF;
      RETURN lt_lst;
   END;
--#begin public
   ---
   -- Check app dependency
   ---
   PROCEDURE check_dependency (
      p_app_code dbm_applications.app_code%TYPE
    , p_ver_code dbm_versions.ver_code%TYPE
    , p_ver_nbr dbm_versions.ver_nbr%TYPE
    , p_requires IN VARCHAR2
   )
--#end public
   IS
      lt_depcies sys.dbms_sql.varchar2a;
      lt_depcy sys.dbms_sql.varchar2a;
      l_ver_nbr_min dbm_versions.ver_nbr%TYPE;
      l_ver_nbr_cur dbm_versions.ver_nbr%TYPE;
      lr_app dbm_applications%ROWTYPE;
   BEGIN
      -- Check dependencies
      lt_depcies := parse_list(p_requires,',');
      FOR i IN 1..lt_depcies.COUNT LOOP
         lt_depcy := parse_list(lt_depcies(i),' ');
         IF lt_depcy.COUNT >= 1 THEN
            lr_app := get_app(lt_depcy(1));
            assert(lr_app.app_code IS NOT NULL, 'Application "'||lt_depcy(1)||'" referenced in the "requires" parameter does not exist!');
            l_ver_nbr_cur := get_version_nbr(lr_app.ver_code);
            IF lt_depcy.COUNT >= 2 THEN
               l_ver_nbr_min := get_version_nbr(lt_depcy(2));
               assert(NVL(l_ver_nbr_cur,-1) >= l_ver_nbr_min, 'Application "'||p_app_code||'" version "'||p_ver_code
                ||'" requires application "'||lr_app.app_code||'" version "'||lt_depcy(2)
                ||CASE WHEN lr_app.ver_code IS NULL THEN '" which is not installed!' ELSE '" while current version is "'||lr_app.ver_code||'"!' END);
            ELSE
               assert(NVL(l_ver_nbr_cur,-1) > 0, 'Application "'||p_app_code||'" version "'||p_ver_code
                ||'" requires application "'||lr_app.app_code||'" which is not installed!');
            END IF;
         END IF;
      END LOOP;
   END;
   ---
   -- Migrate one or all applications (up to given version if requested)
   ---
   PROCEDURE migrate (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , pr_ver IN dbm_versions%ROWTYPE
    , p_precheck_only IN BOOLEAN := FALSE
    , p_next_op_type dbm_versions.next_op_type%TYPE := NULL
   )
   IS
      -- Cursor to browse application
      CURSOR c_app (
         p_app_code dbm_applications.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Cursor to browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
       , p_ver_status dbm_versions.ver_status%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND ver_status IN ('NEXT','FUTURE')
            AND (p_ver_status IS NULL OR ver_status = p_ver_status)
            AND (p_next_op_type IS NULL OR next_op_type = p_next_op_type OR ver_status = 'FUTURE')
          ORDER BY ver_nbr
      ;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_files sys.dbms_sql.varchar2a;
      l_ver_count PLS_INTEGER;
      l_tot_count PLS_INTEGER;
      r_fil dbm_files%ROWTYPE;
      l_apps_dir dbm_utility_var.g_par_value_type := get_apps_dir(TRUE);
      l_requires dbm_utility_var.g_par_value_type;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      l_path dbm_files.path%TYPE;
   BEGIN
      l_tot_count := 0;
      <<app_loop>>
      FOR r_app IN c_app(pr_ver.app_code) LOOP
--         output_line(p_cmd_id,'IN','prompt Migrating application "'||r_app.app_code||'"...');
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_app.app_code);
         l_ver_count := 0;
         r_fil.app_code := r_app.app_code;
         <<ver_loop>>
         FOR r_ver IN c_ver(r_app.app_code, pr_ver.ver_status) LOOP
            EXIT WHEN pr_ver.ver_nbr IS NOT NULL AND r_ver.ver_nbr > pr_ver.ver_nbr;
            EXIT WHEN l_ver_count = 0 AND r_ver.ver_status != 'NEXT'; -- first migration must be next
            l_ver_count := l_ver_count + 1;
            assert(lt_ver.EXISTS(r_ver.ver_nbr),'Version "'||pr_ver.ver_code||'" of application "'||r_ver.app_code||'" not found on file system!');
            lr_ver := lt_ver(r_ver.ver_nbr);
            -- Check dependencies
            output_whenever_sqlerror(p_cmd_id, 'IN');
            l_requires := get_par_value(r_app.app_code, r_ver.ver_nbr, 'requires');
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.check_dependency(p_app_code=>"'||r_app.app_code||'", p_ver_code=>"'||r_ver.ver_code||'", p_ver_nbr=>'||r_ver.ver_nbr||', p_requires=>"'||l_requires||'")','"',''''));
            -- Check and define substitution variables
            define_variables(p_cmd_id, r_ver, 'IN');
            -- Execute pre-check scripts
            FOR k IN 1..2 LOOP
               l_ver_nbr := CASE k WHEN 1 THEN r_ver.ver_nbr ELSE 0 END;
               EXIT WHEN l_ver_nbr = 0 AND NOT lt_ver.EXISTS(l_ver_nbr);
               lr_ver := lt_ver(l_ver_nbr);
               lt_files := lr_ver.t_pre_files;
               FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
                  l_path := lt_files(i);
                  IF lr_ver.a_fil.EXISTS(l_path) AND NOT file_condition_met(r_ver.app_code, r_ver.ver_nbr, l_path, lr_ver.a_fil(l_path)) THEN
                     output_line(p_cmd_id,'IN','prompt Skipping pre-check script "'||get_apps_dir(TRUE)||l_path||'"(condition not met)...');
                  ELSE
                     output_line(p_cmd_id,'IN','prompt Executing pre-check script "'||get_apps_dir(TRUE)||l_path||'"...');
                     output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||l_path);
                  END IF;
                  EXIT WHEN lt_files.EXISTS(0);
               END LOOP;
            END LOOP;
            IF p_precheck_only THEN
               GOTO next_ver;
            END IF;
            lr_ver := lt_ver(r_ver.ver_nbr);
            -- Register migration files
            r_fil.ver_code := lr_ver.r_ver.ver_code;
            UPDATE dbm_files SET status = 'MISSING' WHERE app_code = r_fil.app_code AND ver_code = r_fil.ver_code AND type = r_ver.next_op_type;
            r_fil.status := 'NORMAL';
            IF r_ver.next_op_type = 'INSTALL' THEN
               output_line(p_cmd_id,'IN','prompt Installing version "'||r_ver.ver_code||'" of application "'||r_app.app_code||'"...');
               lt_files := lr_ver.t_ins_files;
               FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
                  r_fil.path := lt_files(i);
                  r_fil.type := r_ver.next_op_type;
                  r_fil.seq := i;
                  upsert_fil(p_app_code=>r_fil.app_code, p_ver_code=>r_fil.ver_code, p_status => r_fil.status, p_path=>r_fil.path, p_type=>r_fil.type, p_seq=>r_fil.seq);
               END LOOP;
            ELSIF r_ver.next_op_type = 'UPGRADE' THEN
               output_line(p_cmd_id,'IN','prompt Upgrading to version "'||r_ver.ver_code||'" of application "'||r_app.app_code||'"...');
               lt_files := lr_ver.t_upg_files;
               FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
                  r_fil.path := lt_files(i);
                  r_fil.type := r_ver.next_op_type;
                  r_fil.seq := i;
                  upsert_fil(p_app_code=>r_fil.app_code, p_ver_code=>r_fil.ver_code, p_status => r_fil.status, p_path=>r_fil.path, p_type=>r_fil.type, p_seq=>r_fil.seq);
               END LOOP;
            END IF;
            -- Compute and set hash of migration files
            IF lt_files.FIRST IS NOT NULL THEN
               output_line(p_cmd_id, 'IN', 'host bin\get-hashes '||l_apps_dir||get_dir(lt_files(lt_files.FIRST))||' ' ||p_cmd_id||' set-hashes '||l_apps_dir||' >tmp\get-hashes.sql');
               output_line(p_cmd_id, 'IN', '@@tmp\get-hashes.sql');
            END IF;
            -- Execute migration files
            r_ver.last_op_type := r_ver.next_op_type;
            r_ver.last_op_status := 'ONGOING';
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"'||r_ver.last_op_type||'", p_last_op_status=>"'||r_ver.last_op_status||'")','"',''''));
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.upsert_app(p_app_code=>"'||r_ver.app_code||'",p_ver_status=>"MIGRATING")','"',''''));
            FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
               l_path := lt_files(i);
               IF get_file_run_status(l_path) = 'SUCCESS' THEN
                  output_line(p_cmd_id,'IN','prompt Skipping already executed script "'||l_path||'"...');
               ELSE
                  IF lr_ver.a_fil.EXISTS(l_path) AND NOT file_condition_met(r_ver.app_code, r_ver.ver_nbr, l_path, lr_ver.a_fil(l_path)) THEN
                     output_line(p_cmd_id,'IN','prompt Skipping script "'||get_apps_dir(TRUE)||l_path||'" (condition not met)...');
                  ELSE
                     IF r_ver.app_code != 'dbm_utility' THEN
                        output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||l_path||'", p_run_status=>"ONGOING")','"',''''));
                     END IF;
                     output_line(p_cmd_id,'IN','prompt Executing script "'||get_apps_dir(TRUE)||l_path||'"...');
                     output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||l_path);
                     IF LOWER(get_file_extension(l_path)) IN ('pkb','pks','plb','pls') AND LOWER(get_par_value('dbm_utility', 0, 'show_compilation_errors', 'yes')) IN ('true','yes','y') THEN
                        output_line(p_cmd_id,'IN','show errors');
                     END IF;
                     IF r_ver.app_code != 'dbm_utility' THEN
                        output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||l_path||'", p_run_status=>"SUCCESS")','"',''''));
                     END IF;
                  END IF;
               END IF;
               EXIT WHEN lt_files.EXISTS(0);
            END LOOP;
            IF r_ver.app_code = 'dbm_utility' THEN
               -- Reload cache (hide errors + twice for "ERROR-04068: Existing state of packages has been discarded")
               output_line(p_cmd_id, 'IN', 'set termout off');
               output_line(p_cmd_id, 'IN', 'whenever sqlerror continue');
               output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.load_cache');
               output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.load_cache');
               output_whenever_sqlerror(p_cmd_id, 'IN');
               output_line(p_cmd_id, 'IN', 'set termout on');
            END IF;
            -- Validate migration
            validate(p_cmd_id, r_app.app_code, r_ver.ver_code, TRUE);
            -- Terminate
            r_ver.ver_status := 'CURRENT';
            r_ver.last_op_status := 'SUCCESS';
            r_ver.next_op_type := NULL;
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"'||r_ver.next_op_type||'", p_last_op_status=>"'||r_ver.last_op_status||'", p_ver_status=>"'||r_ver.ver_status||'", p_next_op_type=>"'||r_ver.next_op_type||'")','"',''''));
            IF r_ver.last_op_type = 'INSTALL' THEN
               output_line(p_cmd_id,'IN',REPLACE('exec UPDATE dbm_files SET run_status = NULL, run_date = NULL WHERE app_code="'||r_ver.app_code||'" AND type!="INSTALL"','"',''''));
               output_line(p_cmd_id,'IN','COMMIT;');
               output_line(p_cmd_id,'IN','prompt Installation of application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'" was successful');
            ELSIF r_ver.last_op_type = 'UPGRADE' THEN
               output_line(p_cmd_id,'IN',REPLACE('exec UPDATE dbm_files SET run_status = NULL, run_date = NULL WHERE app_code="'||r_ver.app_code||'" AND type NOT IN ("INSTALL","UPGRADE")','"',''''));
               output_line(p_cmd_id,'IN','prompt Upgrade of application "'||r_ver.app_code||'" to version "'||r_ver.ver_code||'" was successful');
            END IF;
            <<next_ver>>
            NULL;
         END LOOP ver_loop;
         l_tot_count := l_tot_count + l_ver_count;
         IF p_precheck_only THEN
            GOTO next_app;
         END IF;
         IF l_ver_count = 0 THEN
            output_line(p_cmd_id,'IN','prompt No '||CASE WHEN p_next_op_type IS NULL THEN 'migration' ELSE LOWER(p_next_op_type) END||' is necessary for application "'||r_app.app_code||'"');
         ELSIF r_app.app_code = 'dbm_utility' THEN
            -- Reload cache (hide errors + twice for "ERROR-04068: Existing state of packages has been discarded")
            output_line(p_cmd_id, 'IN3', 'set termout off');
            output_line(p_cmd_id, 'IN3', 'whenever sqlerror continue');
            output_line(p_cmd_id, 'IN3', 'exec dbm_utility_krn.load_cache');
            output_line(p_cmd_id, 'IN3', 'exec dbm_utility_krn.load_cache');
            output_line(p_cmd_id, 'IN3', 'set termout on');
         END IF;
         <<next_app>>
         NULL;
      END LOOP app_loop;
      IF l_tot_count = 0 AND NVL(pr_ver.app_code,'all')='all' AND p_next_op_type IS NOT NULL THEN
         output_line(p_cmd_id,'IN','prompt No application found to '||LOWER(p_next_op_type)||'.');
      END IF;
   END;
   ---
   -- Uninstall one or all applications
   ---
   PROCEDURE uninstall (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_applications.app_code%TYPE
    , p_force IN BOOLEAN
   )
   IS
      -- Cursor to browse application
      CURSOR c_app (
         p_app_code dbm_applications.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND (NVL(p_app_code,'all')!='all' OR ver_code IS NOT NULL) -- exclude not installed apps
            AND app_code != 'all'
          ORDER BY seq DESC, app_code DESC
      ;
      -- Cursor to fetch current version or version 0 if forced installed
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
       , p_force IN VARCHAR2
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE (NVL(p_app_code,'all') = 'all' OR app_code = p_app_code)
            AND (ver_status = 'CURRENT' OR (p_force = 'Y' AND ver_nbr = 0))
            AND app_code != 'all'
          ORDER BY ver_nbr DESC
      ;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_files sys.dbms_sql.varchar2a;
      l_found BOOLEAN;
      r_ver dbm_versions%ROWTYPE;
      l_files_count PLS_INTEGER := 0;
      r_fil dbm_files%ROWTYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
      l_apps_dir dbm_utility_var.g_par_value_type := get_apps_dir(TRUE);
      l_path dbm_files.path%TYPE;
      l_public dbm_parameters.value%TYPE;
   BEGIN
      FOR r_app IN c_app(p_app_code) LOOP
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_app.app_code);
         OPEN c_ver(r_app.app_code, CASE WHEN p_force THEN 'Y' ELSE 'N' END);
         FETCH c_ver INTO r_ver;
         l_found := c_ver%FOUND;
         CLOSE c_ver;
         IF NOT l_found AND NVL(p_app_code,'all') = 'all' THEN
            GOTO next_app;
         END IF;
         assert(l_found, 'Application "'||r_app.app_code||'" is not installed!');
         assert(lt_ver.EXISTS(r_ver.ver_nbr),'Version "'||r_ver.ver_code||'" of application "'||r_ver.app_code||'" not found on file system!');
         output_whenever_sqlerror(p_cmd_id, 'IN');
         output_line(p_cmd_id,'IN','prompt Uninstalling application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'"...');
         r_ver.last_op_type := 'UNINSTALL';
         r_ver.last_op_status := 'ONGOING';
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"'||r_ver.last_op_type||'", p_last_op_status=>"'||r_ver.last_op_status||'")','"',''''));
         define_variables(p_cmd_id, r_ver, 'IN');
         l_files_count := 0;
         r_fil.app_code := r_app.app_code;
         r_fil.ver_code := r_ver.ver_code;
         UPDATE dbm_files SET status = 'MISSING' WHERE app_code = r_fil.app_code AND ver_code = r_fil.ver_code AND type = 'UNINSTALL';
         r_fil.status := 'NORMAL';
         FOR k IN 1..2 LOOP
            l_ver_nbr := CASE WHEN k = 1 THEN r_ver.ver_nbr ELSE 0 END;
            EXIT WHEN NOT lt_ver.EXISTS(l_ver_nbr);
            lr_ver := lt_ver(l_ver_nbr);
            lt_files := lr_ver.t_uni_files;
            FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
               r_fil.path := lt_files(i);
               r_fil.type := 'UNINSTALL';
               r_fil.seq := l_files_count + i;
               upsert_fil(p_app_code=>r_fil.app_code, p_ver_code=>r_fil.ver_code, p_status => r_fil.status, p_path=>r_fil.path, p_type=>r_fil.type, p_seq=>r_fil.seq);
            END LOOP;
            IF lt_files.FIRST IS NOT NULL THEN
               output_line(p_cmd_id, 'IN', 'host bin\get-hashes '||l_apps_dir||get_dir(lt_files(lt_files.FIRST))||' ' ||p_cmd_id||' set-hashes '||l_apps_dir||' >tmp\get-hashes.sql');
               output_line(p_cmd_id, 'IN', '@@tmp\get-hashes.sql');
            END IF;
            FOR i IN NVL(lt_files.FIRST,1)..NVL(lt_files.LAST,0) LOOP
               l_path := lt_files(i);
               IF lr_ver.a_fil.EXISTS(l_path) AND NOT file_condition_met(r_ver.app_code, r_ver.ver_nbr, l_path, lr_ver.a_fil(l_path)) THEN
                  output_line(p_cmd_id,'IN','prompt Skipping script "'||get_apps_dir(TRUE)||l_path||'" (condition not met)...');
               ELSE
                  output_line(p_cmd_id,'IN','prompt Executing script "'||get_apps_dir(TRUE)||l_path||'"...');
                  IF r_app.app_code != 'dbm_utility' THEN
                     output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||l_path||'", p_run_status=>"ONGOING")','"',''''));
                  END IF;
                  output_line(p_cmd_id,'IN','@@'||get_apps_dir(TRUE)||l_path||' '||r_ver.ver_code);
                  IF r_app.app_code != 'dbm_utility' THEN
                     output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_fil(p_path=>"'||l_path||'", p_run_status=>"SUCCESS")','"',''''));
                  END IF;
               END IF;
               EXIT WHEN lt_files.EXISTS(0);
            END LOOP;
            l_files_count := l_files_count + lt_files.COUNT;
            EXIT WHEN r_ver.ver_nbr = 0;
         END LOOP;
         assert(l_files_count>0, 'No script found to unistall application "'||r_ver.app_code||'"!');
         IF r_ver.app_code != 'dbm_utility' THEN
            l_obj_name_pattern := get_par_value(r_app.app_code, r_ver.ver_nbr, 'object_name_pattern');
            l_obj_name_anti_pattern := get_par_value(r_app.app_code, r_ver.ver_nbr, 'object_name_anti_pattern', '^$');
            l_public := CASE WHEN NVL(LOWER(get_var_value(r_app.app_code, 'public', TRUE)),'false') = 'true' THEN 'Y' ELSE 'N' END;
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.check_objects(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_obj_name_pattern=>"'||l_obj_name_pattern||'",p_obj_name_anti_pattern=>"'||l_obj_name_anti_pattern||'",p_public=>"'||l_public||'",p_last_op_type=>"UNINSTALL")','"',''''));
            r_ver.last_op_status := 'SUCCESS';
            r_ver.ver_status := NULL;
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.update_ver(p_app_code=>"'||r_ver.app_code||'",p_ver_code=>"'||r_ver.ver_code||'",p_last_op_type=>"'||r_ver.last_op_type||'", p_last_op_status=>"'||r_ver.last_op_status||'", p_ver_status=>"")','"',''''));
            output_line(p_cmd_id,'IN',REPLACE('exec UPDATE dbm_files SET run_status = NULL, run_date = NULL WHERE app_code="'||r_ver.app_code||'" AND type!="UNINSTALL"','"','''')); -- all versions
         END IF;
         output_line(p_cmd_id,'IN','COMMIT;'); -- all versions
         output_line(p_cmd_id,'IN','prompt Uninstall of application "'||r_ver.app_code||'" version "'||r_ver.ver_code||'" was successful');
         <<next_app>>
         NULL;
      END LOOP;
   END;
   ---
   -- Show current version
   ---
   PROCEDURE show_current (
      p_app_code IN dbm_versions.app_code%TYPE
   )
   IS
      -- Browse applications
      CURSOR c_app IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Count number of objects matching pattern and anti-pattern
      CURSOR c_obj (
         p_obj_name_pattern IN VARCHAR2
       , p_obj_name_anti_pattern IN VARCHAR2
      )
      IS
         SELECT COUNT(*)
           FROM user_objects
          WHERE REGEXP_LIKE (object_type||' '||object_name, p_obj_name_pattern)
            AND NOT REGEXP_LIKE (object_type||' '||object_name, p_obj_name_anti_pattern)
         ;
      -- Local vars
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
      l_obj_count PLS_INTEGER;
   BEGIN
      FOR r_app IN c_app LOOP
         IF r_app.ver_code IS NOT NULL THEN
            dbms_output.put_line('Current version of application "'||r_app.app_code||'" is "'||r_app.ver_code||'" and its status is "'||NVL(r_app.ver_status,'UNKNOWN')||'".');
         ELSE
            l_obj_name_pattern := get_par_value(r_app.app_code, 0, 'object_name_pattern');
            l_obj_name_anti_pattern := get_par_value(r_app.app_code, 0, 'object_name_anti_pattern', '^$');
            OPEN c_obj(l_obj_name_pattern, l_obj_name_anti_pattern);
            FETCH c_obj INTO l_obj_count;
            CLOSE c_obj;
            IF l_obj_count = 0 THEN
               dbms_output.put_line('Application "'||r_app.app_code||'" is not installed.');
            ELSE
               dbms_output.put_line('Application "'||r_app.app_code||'" has no current version.');
            END IF;
         END IF;
      END LOOP;
   END;
   -- Parse object inventory line (format: <object-name>[: [checksum] [condition]])
   FUNCTION parse_object_inventory_line (
      p_line IN VARCHAR2
   )
   RETURN dbm_objects%ROWTYPE
   IS
      l_pos PLS_INTEGER;
      l_beg PLS_INTEGER;
      r_obj dbm_objects%ROWTYPE;
   BEGIN
      l_pos := NVL(INSTR(p_line,':'),0);
      IF l_pos > 0 THEN
         r_obj.name := TRIM(UPPER(SUBSTR(p_line,1,l_pos-1)));
         l_pos := l_pos + 1;
         WHILE SUBSTR(p_line,l_pos,1) = ' ' LOOP
            l_pos := l_pos + 1;
         END LOOP;
         l_beg := l_pos;
         WHILE SUBSTR(p_line,l_pos,1) BETWEEN '0' AND '9' LOOP
            l_pos := l_pos + 1;
         END LOOP;
         r_obj.checksum := SUBSTR(p_line,l_beg,l_pos-l_beg);
         WHILE SUBSTR(p_line,l_pos,1) = ' ' LOOP
            l_pos := l_pos + 1;
         END LOOP;
         r_obj.condition := TRIM(SUBSTR(p_line,l_pos));
      ELSE
         r_obj.name := TRIM(UPPER(p_line));
         r_obj.checksum := NULL;
         r_obj.condition := NULL;
      END IF;
      RETURN r_obj;
   END;
--#begin public
   ---
   -- Guess and set current version
   ---
   PROCEDURE guess_set_current (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_app_code IN dbm_versions.app_code%TYPE
    , p_set_curr IN BOOLEAN := FALSE
    , p_best IN BOOLEAN := FALSE
   )
--#end public
   IS
      -- Browse application
      CURSOR c_app IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
            AND app_code != 'all'
          ORDER BY seq, app_code
      ;
      -- Browse versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
            AND ver_nbr > 0
          ORDER BY ver_nbr DESC
      ;
      -- Local type
      TYPE lr_stat_type IS RECORD (
         ver_code dbm_versions.ver_code%TYPE
       , ver_status dbm_versions.ver_status%TYPE
       , miss_cnt NUMBER -- number of missing objects
       , xtra_cnt NUMBER -- number of extra objects
       , same_cnt NUMBER -- number of checksum match
       , diff_cnt NUMBER -- number of checksum mismatch
       , tot_cnt NUMBER -- total
      );
      -- Local variables
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      la_db_obj dbm_utility_var.ga_obj_type;
      la_ver_obj dbm_utility_var.ga_obj_type;
      l_par_name dbm_utility_var.g_par_name_type;
      l_obj_name_pattern dbm_utility_var.g_par_value_type;
      l_obj_name_anti_pattern dbm_utility_var.g_par_value_type;
      l_err_count PLS_INTEGER := 0;
      l_pos PLS_INTEGER;
      r_obj dbm_objects%ROWTYPE;
      l_db_obj_name dbm_objects.name%TYPE;
      l_ver_obj_name dbm_objects.name%TYPE;
      l_found BOOLEAN;
      r_curr_stat lr_stat_type; -- statistics of current version
      r_best_stat lr_stat_type; -- statistics of best version so far
      l_public dbm_parameters.value%TYPE;
   BEGIN
      <<app_loop>>
      FOR r_app IN c_app LOOP
         assert(dbm_utility_var.ga_app.EXISTS(r_app.app_code), 'Application "'||r_app.app_code||'" not found on file system!');
         lt_ver := dbm_utility_var.ga_app(r_app.app_code);
         -- Load db objects with their checksum into memory
         l_obj_name_pattern := get_par_value(r_app.app_code, 0, 'object_name_pattern');
         l_obj_name_anti_pattern := get_par_value(r_app.app_code, 0, 'object_name_anti_pattern', '^$');
         l_public := CASE WHEN NVL(LOWER(get_var_value(r_app.app_code, 'public', TRUE)),'false') = 'true' THEN 'Y' ELSE 'N' END;
         la_db_obj.DELETE;
         <<db_obj>>
         FOR r_db_obj IN dbm_utility_var.gc_obj(l_obj_name_pattern,l_obj_name_anti_pattern,l_public) LOOP
            r_obj := parse_object_inventory_line(r_db_obj.object);
            la_db_obj(r_obj.name) := r_obj;
         END LOOP db_obj;
         IF la_db_obj.COUNT = 0
         THEN
            dbms_output.put_line('Application "'||r_app.app_code||'" is not installed.');
         ELSE
            l_found := FALSE;
            r_best_stat := NULL;
            <<ver_loop>>
            FOR r_ver IN c_ver(r_app.app_code) LOOP
               assert(lt_ver.EXISTS(r_ver.ver_nbr),'Version "'||r_ver.ver_code||'" of application "'||r_app.app_code||'" not found on file system!');
               lr_ver := lt_ver(r_ver.ver_nbr);
               la_ver_obj := lr_ver.a_obj;
               r_curr_stat.ver_code := r_ver.ver_code;
               r_curr_stat.ver_status := r_ver.ver_status;
               r_curr_stat.miss_cnt := 0;
               r_curr_stat.xtra_cnt := 0;
               r_curr_stat.diff_cnt := 0;
               r_curr_stat.same_cnt := 0;
               r_curr_stat.tot_cnt := 0;
               l_db_obj_name := la_db_obj.FIRST;
               l_ver_obj_name := la_ver_obj.FIRST;
               <<obj_loop>>
               WHILE l_db_obj_name IS NOT NULL AND l_ver_obj_name IS NOT NULL LOOP
                  r_curr_stat.tot_cnt := r_curr_stat.tot_cnt + 1;
                  IF l_public = 'N' AND l_ver_obj_name LIKE 'PUBLIC%' THEN
                     l_ver_obj_name := la_ver_obj.NEXT(l_ver_obj_name);
                     r_curr_stat.tot_cnt := r_curr_stat.tot_cnt - 1;
                  ELSIF l_db_obj_name IS NULL OR l_db_obj_name > l_ver_obj_name THEN
                     IF dbm_utility_var.g_debug THEN
                        dbms_output.put_line(l_ver_obj_name||' is IN EXCESS in version');
                     END IF;
                     r_curr_stat.xtra_cnt := r_curr_stat.xtra_cnt + 1;
                     l_ver_obj_name := la_ver_obj.NEXT(l_ver_obj_name);
                  ELSIF l_ver_obj_name IS NULL
                     OR l_ver_obj_name > l_db_obj_name 
                     OR NOT object_condition_met(r_ver.app_code, r_ver.ver_nbr, l_ver_obj_name, la_ver_obj(l_ver_obj_name).condition)
                  THEN
                     IF dbm_utility_var.g_debug THEN
                        dbms_output.put_line(l_db_obj_name||' is MISSING in version');
                     END IF;
                     r_curr_stat.miss_cnt := r_curr_stat.miss_cnt + 1;
                     l_db_obj_name := la_db_obj.NEXT(l_db_obj_name);
                  ELSE
                     IF  la_ver_obj(l_ver_obj_name).checksum IS NOT NULL
                     AND la_db_obj(l_db_obj_name).checksum IS NOT NULL
                     AND la_ver_obj(l_ver_obj_name).checksum != la_db_obj(l_db_obj_name).checksum
                     THEN
                        IF dbm_utility_var.g_debug THEN
                           dbms_output.put_line(l_db_obj_name||' has a DIFFERENT checksum');
                        END IF;
                        r_curr_stat.diff_cnt := r_curr_stat.diff_cnt + 1;
                     ELSE
                        r_curr_stat.same_cnt := r_curr_stat.same_cnt + 1;
                     END IF;
                     l_db_obj_name := la_db_obj.NEXT(l_db_obj_name);
                     l_ver_obj_name := la_ver_obj.NEXT(l_ver_obj_name);
                  END IF;
               END LOOP obj_loop;
               IF dbm_utility_var.g_debug THEN
                  dbms_output.put_line('App "'||r_app.app_code||'" Ver "'||r_ver.ver_code||'" Miss '||r_curr_stat.miss_cnt||' Xtra '||r_curr_stat.xtra_cnt||' Diff '||r_curr_stat.diff_cnt||' Same '||r_curr_stat.same_cnt||' Tot '||r_curr_stat.tot_cnt);
               END IF;
               IF r_best_stat.ver_code IS NULL
               OR (r_curr_stat.same_cnt / r_curr_stat.tot_cnt) > (r_best_stat.same_cnt / r_best_stat.tot_cnt)
               THEN
                  r_best_stat := r_curr_stat;
               END IF;
               l_found := r_curr_stat.miss_cnt = 0 AND r_curr_stat.xtra_cnt = 0 AND r_curr_stat.diff_cnt = 0;
               IF l_found THEN
                  dbms_output.put_line('Application "'||r_ver.app_code||'": version "'||r_ver.ver_code||'" detected.');
                  IF p_set_curr AND NVL(r_ver.ver_status,'NULL') != 'CURRENT' THEN
                     set_current(p_cmd_id, r_ver.app_code, r_ver.ver_code, TRUE);
                  END IF;
                  EXIT;
               END IF;
            END LOOP ver_loop;
            IF NOT l_found THEN
               IF p_best THEN
                  dbms_output.put_line('Application "'||r_app.app_code||'": no exact match, closest version is "'||r_best_stat.ver_code||'"');
                  IF p_set_curr AND NVL(r_best_stat.ver_status,'NULL') != 'CURRENT' THEN
                     set_current(p_cmd_id, r_app.app_code, r_best_stat.ver_code, TRUE);
                  END IF;
               ELSE
                  dbms_output.put_line('Application "'||r_app.app_code||'": no exact version found');
               END IF;
            END IF;
         END IF;
      END LOOP app_loop;
   END;
--#begin public
   ---
   -- Get list of database objects currently installed
   ---
   PROCEDURE list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_checksum IN VARCHAR2 := 'Y'
    , p_condition IN VARCHAR2 := 'Y'
    , p_public IN VARCHAR2 := 'N'
    , p_app_code dbm_objects.app_code%TYPE := NULL
    , p_ver_code dbm_objects.ver_code%TYPE := NULL
   )
--#end public
   IS
      r_obj dbm_objects%ROWTYPE;
   BEGIN
      FOR r_db_obj IN dbm_utility_var.gc_obj(p_obj_name_pattern,NVL(p_obj_name_anti_pattern,'^$'),p_public, p_app_code, p_ver_code) LOOP
         r_obj := parse_object_inventory_line(r_db_obj.object);
         dbms_output.put_line(r_obj.name
            || CASE WHEN p_checksum = 'Y' OR p_condition = 'Y' THEN ':' END
            || CASE WHEN p_checksum = 'Y' THEN ' ' || r_obj.checksum END
            || CASE WHEN p_condition = 'Y' THEN ' ' || r_obj.condition END
         );
      END LOOP;
   END;
--#begin public
   ---
   -- Get list of database objects currently installed
   ---
   FUNCTION list_db_objects (
      p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_checksum IN VARCHAR2 := 'Y'
    , p_condition IN VARCHAR2 := 'Y'
    , p_public IN VARCHAR2 := 'N'
    , p_app_code dbm_objects.app_code%TYPE := NULL
    , p_ver_code dbm_objects.ver_code%TYPE := NULL
   )
   RETURN sys.odcivarchar2list PIPELINED
--#end public
   IS
      r_obj dbm_objects%ROWTYPE;
   BEGIN
      FOR r_db_obj IN dbm_utility_var.gc_obj(p_obj_name_pattern,NVL(p_obj_name_anti_pattern,'^$'),p_public, p_app_code, p_ver_code) LOOP
         r_obj := parse_object_inventory_line(r_db_obj.object);
         PIPE ROW(r_obj.name
            || CASE WHEN p_checksum = 'Y' OR p_condition = 'Y' THEN ':' END
            || CASE WHEN p_checksum = 'Y' THEN ' ' || r_obj.checksum END
            || CASE WHEN p_condition = 'Y' THEN ' ' || r_obj.condition END
         );
      END LOOP;
   END;
--#begin public
   ---
   -- Check for missing/extra/invalid database objects
   ---
   PROCEDURE check_objects (
      p_app_code IN dbm_versions.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE
    , p_obj_name_pattern IN VARCHAR2
    , p_obj_name_anti_pattern IN VARCHAR2 := '^$'
    , p_public IN VARCHAR2 := 'N'
    , p_last_op_type IN dbm_versions.last_op_type%TYPE := 'VALIDATE'
   )
--#end public
   IS
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      la_obj dbm_utility_var.ga_obj_type;
      lt_obj dbm_utility_var.gt_obj_type;
      l_obj_name dbm_objects.name%TYPE;
      l_par_name dbm_utility_var.g_par_name_type;
      l_err_count PLS_INTEGER := 0;
      l_pos PLS_INTEGER;
      l_checksum dbm_utility_var.g_checksum_type;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      -- Browse objects inventory
      CURSOR c_obj (
         p_public IN VARCHAR2
      )
      IS
         SELECT *
           FROM dbm_objects
          WHERE app_code = p_app_code
            AND ver_code = p_ver_code
            AND (p_public = 'Y' OR name NOT LIKE 'PUBLIC%')
          ORDER BY name
      ;
   BEGIN
      -- Fetch db objects expected for given app/version
      OPEN c_obj(p_public);
      FETCH c_obj BULK COLLECT INTO lt_obj;
      CLOSE c_obj;
      -- Keep only those whose condition is met
      FOR i IN 1..lt_obj.COUNT LOOP
         l_obj_name := lt_obj(i).name;
         IF object_condition_met(p_app_code, l_ver_nbr, l_obj_name, lt_obj(i).condition) THEN
            la_obj(l_obj_name) := lt_obj(i);
         END IF;
      END LOOP;
      -- Browse db objects
      FOR r_obj IN dbm_utility_var.gc_obj(p_obj_name_pattern,NVL(p_obj_name_anti_pattern,'^$'),p_public) LOOP
         l_pos := NVL(INSTR(r_obj.object,':'),0);
         IF l_pos > 0 THEN
            l_obj_name := SUBSTR(r_obj.object,1,l_pos-1);
            l_checksum := TRIM(SUBSTR(r_obj.object,l_pos+1));
         ELSE
            l_obj_name := r_obj.object;
            l_checksum := NULL;
         END IF;
         IF la_obj.EXISTS(l_obj_name) THEN
            IF p_last_op_type = 'UNINSTALL' THEN
               dbms_output.put_line('ERROR: '||l_obj_name||' was not dropped!');
               l_err_count := l_err_count + 1;
            ELSE
               IF r_obj.status = 'INVALID' THEN
                  dbms_output.put_line('ERROR: '||l_obj_name||' is invalid!');
                  l_err_count := l_err_count + 1;
               END IF;
               IF l_checksum != NVL(la_obj(l_obj_name).checksum,l_checksum) THEN
                  dbms_output.put_line('ERROR: '||l_obj_name||' has a wrong checksum! (got "'||l_checksum||'" while expecting "'||la_obj(l_obj_name).checksum||'"');
                  l_err_count := l_err_count + 1;
               END IF;
            END IF;
            la_obj.DELETE(l_obj_name);
         ELSIF p_last_op_type = 'VALIDATE' AND p_obj_name_pattern IS NOT NULL THEN
            dbms_output.put_line(l_obj_name||' is in excess!');
            l_err_count := l_err_count + 1;
         END IF;
      END LOOP;
      -- Report missing objects (only if object name pattern is defined)
      IF p_last_op_type = 'VALIDATE' THEN
         l_obj_name := la_obj.FIRST;
         WHILE l_obj_name IS NOT NULL LOOP
            dbms_output.put_line('ERROR: '||l_obj_name||' is missing!');
            l_err_count := l_err_count + 1;
            l_obj_name := la_obj.NEXT(l_obj_name);
         END LOOP;
      END IF;
      IF p_last_op_type = 'VALIDATE' THEN
         assert(l_err_count=0,'Some database objects are invalid, missing, in excess, or have a wrong checksum!');
      ELSE
         assert(l_err_count=0,'Some database objects have not been dropped!');
      END IF;
   END;
   ---
   -- Configure one or all applications
   ---
   PROCEDURE configure (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , pr_ver dbm_versions%ROWTYPE
   )
   IS
      -- Cursor to browse application
      CURSOR c_app (
         p_app_code dbm_applications.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_applications
          WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code)
             OR app_code = 'all' -- as all config applies to all apps
          ORDER BY seq, app_code
      ;
      -- Cursor to browse variables
      CURSOR c_var (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_variables
          WHERE app_code = p_app_code
          ORDER BY seq, name
      ;
   BEGIN
      output_line(p_cmd_id,'IN','PROMPT **********************************************************************');
      output_line(p_cmd_id,'IN','PROMPT * Configuration of Application Variables');
      output_line(p_cmd_id,'IN','PROMPT * - Mandatoriness/Optionality is indicated in parentheses');
      output_line(p_cmd_id,'IN','PROMPT * - Default or last entered value is shown in brackets');
      output_line(p_cmd_id,'IN','PROMPT * => Enter value then press RETURN');
      output_line(p_cmd_id,'IN','PROMPT * => Just press RETURN to keep actual value');
      output_line(p_cmd_id,'IN','PROMPT * => Enter a SPACE to reset value to NULL');
      output_line(p_cmd_id,'IN','PROMPT **********************************************************************');
      FOR r_app IN c_app(pr_ver.app_code) LOOP
         FOR r_var IN c_var(r_app.app_code) LOOP
            output_line(p_cmd_id,'IN','ACCEPT var PROMPT "'||REPLACE(NVL(r_var.descr,r_var.name),'"','''')||' ('||CASE WHEN r_var.nullable = 'N' THEN 'mandatory' ELSE 'optional' END||') ['||r_var.value||']: '||'"');
            output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.set_var_value("'||r_var.app_code||'","'||r_var.name||'","'||CHR(38)||'var")','"',''''));
         END LOOP;
      END LOOP;
      output_line(p_cmd_id,'IN','undefine var');
   END;
   ---
   -- Parse a file path
   ---
   FUNCTION parse_cfg (
      p_line IN VARCHAR2
   )
   RETURN sys.dbms_sql.varchar2a
   IS
      la_cfg sys.dbms_sql.varchar2a;
      l_beg PLS_INTEGER := 1;
      l_end PLS_INTEGER := 0;
      l_pos PLS_INTEGER := 0;
      l_len PLS_INTEGER := LENGTH(p_line);
   BEGIN
      l_end := NVL(INSTR(p_line,'='),0);
      IF l_end = 0 THEN
         RETURN la_cfg;
      END IF;
      WHILE l_beg < l_end - 1 LOOP
         l_pos := NVL(INSTR(p_line,'.',l_beg),0);
         EXIT WHEN l_pos < l_beg OR l_pos > l_end;
         IF l_pos > l_beg THEN
            la_cfg(la_cfg.COUNT+1) := LOWER(SUBSTR(p_line,l_beg,l_pos-l_beg));
         END IF;
         l_beg := l_pos + 1;
      END LOOP;
      IF l_end - 1 - l_beg + 1 > 0 THEN
         la_cfg(la_cfg.COUNT+1) := LOWER(SUBSTR(p_line,l_beg,l_end-1-l_beg+1));
      END IF;
      la_cfg(la_cfg.COUNT+1) := SUBSTR(p_line,l_end+1); -- value
      RETURN la_cfg;
   END;
   -- Get application code by removing leading digits
   FUNCTION get_app_code (
      p_app_path IN VARCHAR2
    )
   RETURN VARCHAR2
   IS
      l_pos PLS_INTEGER;
      l_chr VARCHAR2(1 CHAR);
   BEGIN
      l_pos := 1;
      LOOP
         l_chr := SUBSTR(p_app_path, l_pos, 1);
         EXIT WHEN l_chr NOT BETWEEN '0' AND '9';
         l_pos := l_pos + 1;
      END LOOP;
      RETURN LTRIM(LTRIM(SUBSTR(p_app_path,l_pos),'-'),'_');
   END;
   -- Parse application path (99_xxx)
   PROCEDURE parse_app_path (
      p_app_path IN VARCHAR2
    , p_app_code IN OUT dbm_applications.app_code%TYPE
    , p_seq IN OUT dbm_applications.seq%TYPE
    )
   IS
      l_pos PLS_INTEGER;
      l_chr VARCHAR2(1 CHAR);
   BEGIN
      l_pos := 1;
      p_seq := NULL;
      LOOP
         l_chr := SUBSTR(p_app_path, l_pos, 1);
         EXIT WHEN l_chr NOT BETWEEN '0' AND '9';
         p_seq := NVL(p_seq,0) * 10 + ASCII(l_chr) - ASCII('0');
         l_pos := l_pos + 1;
      END LOOP;
      p_app_code := LTRIM(LTRIM(SUBSTR(p_app_path,l_pos),'-'),'_');
   END;
   -- Save version files into DB
   PROCEDURE save_ver_files (
      r_curr_ver dbm_utility_var.r_ver_type
   )
   IS
      r_fil dbm_files%ROWTYPE;
      t_files sys.dbms_sql.varchar2a;
   BEGIN
      r_fil.app_code := r_curr_ver.r_ver.app_code;
      r_fil.ver_code := r_curr_ver.r_ver.ver_code;
      FOR j IN 1..9 LOOP
         t_files := CASE j WHEN 1 THEN r_curr_ver.t_ins_files
                           WHEN 2 THEN r_curr_ver.t_inr_files
                           WHEN 3 THEN r_curr_ver.t_upg_files
                           WHEN 4 THEN r_curr_ver.t_upr_files
                           WHEN 5 THEN r_curr_ver.t_uni_files
                           WHEN 6 THEN r_curr_ver.t_val_files
                           WHEN 7 THEN r_curr_ver.t_cfg_files
                           WHEN 8 THEN r_curr_ver.t_pre_files
                           WHEN 9 THEN r_curr_ver.t_set_files
                     END;
         r_fil.type := CASE j WHEN 1 THEN 'INSTALL'
                              WHEN 2 THEN 'ROLLBACK INSTALL'
                              WHEN 3 THEN 'UPGRADE'
                              WHEN 4 THEN 'ROLLBACK UPGRADE'
                              WHEN 5 THEN 'UNINSTALL'
                              WHEN 6 THEN 'VALIDATE'
                              WHEN 7 THEN 'CONFIG'
                              WHEN 8 THEN 'PRECHECK'
                              WHEN 9 THEN 'SETUP'
                        END;
         FOR i IN NVL(t_files.FIRST,1)..NVL(t_files.last,0) LOOP
            r_fil.path := t_files(i);
            r_fil.seq := i;
            r_fil.run_condition := CASE WHEN r_curr_ver.a_fil.EXISTS(r_fil.path) THEN r_curr_ver.a_fil(r_fil.path) ELSE NULL END;
            upsert_fil(p_app_code=>r_fil.app_code, p_ver_code=>r_fil.ver_code, p_path=>r_fil.path, p_type=>r_fil.type, p_seq=>r_fil.seq, p_run_condition=>r_fil.run_condition, p_deleted_flag=>NULL);
         END LOOP;
      END LOOP;
   END;
--#begin public
   ---
   -- Parse configuration file
   ---
   PROCEDURE parse_configuration (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
   )
--#end public
   IS
      CURSOR c_str IS
         SELECT RTRIM(RTRIM(text,CHR(13))) text
           FROM dbm_streams
          WHERE cmd_id = p_cmd_id
            AND type = 'OUT'
            AND RTRIM(RTRIM(text,CHR(13))) IS NOT NULL
          ORDER BY line
      ;
      l_path dbm_files.path%TYPE;
      l_app_code dbm_applications.app_code%TYPE;
      l_ver_code dbm_versions.ver_code%TYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      r_curr_var dbm_variables%ROWTYPE;
      r_last_var dbm_variables%ROWTYPE;
      r_var dbm_variables%ROWTYPE;
      r_obj dbm_objects%ROWTYPE;
      r_fil dbm_files%ROWTYPE;
      lt_var dbm_utility_var.gt_var_type;
      la_cfg sys.dbms_sql.varchar2a;
      lt_ins sys.dbms_sql.varchar2a;
      lt_upg sys.dbms_sql.varchar2a;
      lt_uni sys.dbms_sql.varchar2a;
      lt_val sys.dbms_sql.varchar2a;
      lt_pre sys.dbms_sql.varchar2a;
      lt_set sys.dbms_sql.varchar2a;
      la_obj dbm_utility_var.ga_obj_type;
      la_fil dbm_utility_var.ga_fil_type;
      la_par dbm_utility_var.ga_par_type;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      lt_path sys.dbms_sql.varchar2a;
      l_file_ext VARCHAR2(100);
      l_pos PLS_INTEGER;
      l_obj_name dbm_objects.name%TYPE;
      -- Check that a file referenced in a config file does exist
      PROCEDURE check_file_list (
         pt_files1 sys.dbms_sql.varchar2a
       , pt_files2 sys.dbms_sql.varchar2a
      )
      IS
         l_found BOOLEAN;
      BEGIN
         FOR i IN NVL(pt_files1.FIRST,1)..NVL(pt_files1.LAST,0) LOOP
            FOR j IN NVL(pt_files2.FIRST,1)..NVL(pt_files2.LAST,0) LOOP
               l_found := pt_files1(i) = pt_files2(j);
               EXIT WHEN l_found;
            END LOOP;
            IF NOT l_found THEN
               raise_application_error(-20888,'File "'||pt_files1(i)||'" referenced in "'||l_path||'" not found on file system!');
            END IF;
         END LOOP;
      END check_file_list;
      -- File break
      PROCEDURE file_break IS
      BEGIN
         IF l_app_code IS NOT NULL AND l_ver_nbr IS NOT NULL THEN
            -- Save files into memory
            IF la_fil.COUNT > 0 THEN
               lr_ver.a_fil := la_fil;
            END IF;
            IF lt_ins.COUNT > 0 THEN
               check_file_list(lt_ins, lr_ver.t_ins_files);
               lr_ver.t_ins_files := lt_ins;
            END IF;
            IF lt_upg.COUNT > 0 THEN
               check_file_list(lt_upg, lr_ver.t_upg_files);
               lr_ver.t_upg_files:= lt_upg;
            END IF;
            IF lt_uni.COUNT > 0 THEN
               check_file_list(lt_uni, lr_ver.t_uni_files);
               lr_ver.t_uni_files := lt_uni;
            END IF;
            IF lt_val.COUNT > 0 THEN
               check_file_list(lt_val, lr_ver.t_val_files);
               lr_ver.t_val_files := lt_val;
            END IF;
            IF lt_pre.COUNT > 0 THEN
               check_file_list(lt_pre, lr_ver.t_pre_files);
               lr_ver.t_pre_files := lt_pre;
            END IF;
            IF lt_set.COUNT > 0 THEN
               check_file_list(lt_set, lr_ver.t_set_files);
               lr_ver.t_set_files := lt_set;
            END IF;
            -- Process last variable
            IF r_last_var.name IS NOT NULL THEN
               lt_var(lt_var.COUNT+1) := r_last_var;
            END IF;
            -- Set variables
            FOR i IN 1..lt_var.COUNT LOOP
               r_var := lt_var(i);
               IF r_var.value IS NULL THEN
                  r_var.value := get_var_value(r_var.app_code, r_var.name);
               END IF;
               IF r_var.value IS NULL AND r_var.default_value_sql IS NOT NULL THEN
                  BEGIN
                     EXECUTE IMMEDIATE r_var.default_value_sql INTO r_var.value;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        dbms_output.put_line('Error: cannot generate default value for parameter "'||r_var.name||'" using SQL statement');
                  END;
               END IF;
               IF r_var.value IS NOT NULL THEN
                  check_var_value(r_var);
               END IF;
               lt_var(i) := r_var;
            END LOOP;
            -- Save variables into memory
            IF lt_var.COUNT > 0 THEN
               lr_ver.t_var := lt_var;
            END IF;
            -- Save parameters into memory
            IF la_par.COUNT > 0 THEN
               lr_ver.a_par:= la_par;
            END IF;
            -- Save db object into memory
            IF la_obj.COUNT > 0 THEN
               lr_ver.a_obj := la_obj;
            END IF;
            -- Save application and its versions into memory
            dbm_utility_var.ga_app(l_app_code)(l_ver_nbr) := lr_ver;
            -- Reset all
            r_curr_var := NULL;
            r_last_var := NULL;
            lt_ins.DELETE;
            lt_upg.DELETE;
            lt_uni.DELETE;
            lt_val.DELETE;
            lt_pre.DELETE;
            lt_set.DELETE;
            la_fil.DELETE;
--            la_obj.DELETE;
--            lt_var.DELETE;
--            la_par.DELETE;
         END IF;
      END file_break;
   BEGIN
      FOR r_str IN c_str LOOP
--         dbms_output.put_line(r_str.text);
         -- Handle comment line
         IF SUBSTR(r_str.text,1,1) = '#' THEN
            -- Handle file header line
            IF SUBSTR(r_str.text,1,2) = '#!' THEN
               file_break;
               l_path := TRIM(SUBSTR(r_str.text,3));
               l_file_ext := LOWER(get_file_extension(l_path));
               lt_path := parse_path(l_path);
               IF dbm_utility_var.g_debug THEN
                  dbms_output.put_line('Parsing file "'||l_path||'"...');
               END IF;
               -- File header is about a dummy "<app>.conf" file (used for command line parameters)
               IF lt_path.COUNT = 1 THEN
                  IF l_file_ext = 'conf' THEN
                     l_app_code := get_app_code(get_basename(lt_path(1)));
                     assert(l_app_code='dbm_utility' OR dbm_utility_var.ga_app.EXISTS(l_app_code),'Application "'||l_app_code||'" not found in memory!');
                     l_ver_code := 'all';
                     l_ver_nbr := 0;
                     IF dbm_utility_var.ga_app.EXISTS(l_app_code) THEN
                        lt_ver := dbm_utility_var.ga_app(l_app_code);
                     ELSE
                        lt_ver.DELETE;
                     END IF;
                     IF lt_ver.EXISTS(l_ver_nbr) THEN
                        lr_ver := lt_ver(l_ver_nbr);
                        lt_ins := lr_ver.t_ins_files;
                        lt_upg := lr_ver.t_upg_files;
                        lt_uni := lr_ver.t_uni_files;
                        lt_val := lr_ver.t_val_files;
                        lt_pre := lr_ver.t_pre_files;
                        lt_set := lr_ver.t_set_files;
                        la_obj := lr_ver.a_obj;
                        la_fil := lr_ver.a_fil;
                        lt_var := lr_ver.t_var;
                        la_par := lr_ver.a_par;
                     ELSE
                        lr_ver := NULL;
                        lr_ver.r_app.app_code := l_app_code;
                        lr_ver.r_ver.app_code := l_app_code;
                        lr_ver.r_ver.ver_code := l_ver_code;
                        lr_ver.r_ver.ver_nbr := l_ver_nbr;
                        lt_ins.DELETE;
                        lt_upg.DELETE;
                        lt_uni.DELETE;
                        lt_val.DELETE;
                        lt_pre.DELETE;
                        lt_set.DELETE;
                        la_obj.DELETE;
                        la_fil.DELETE;
                        lt_var.DELETE;
                        la_par.DELETE;
                     END IF;
                     r_curr_var := NULL;
                     r_last_var := NULL;
                  END IF;
               -- File header is about a real "<app>.conf" file located somewhere in a "config" sub-folder of a release folder
               ELSIF lt_path.COUNT >= 3 AND LOWER(lt_path(2)) = 'releases' THEN
                  l_app_code := get_app_code(lt_path(1));
                  IF LOWER(l_app_code) = 'all' THEN
                     l_app_code := 'all';
                  END IF;
                  assert(dbm_utility_var.ga_app.EXISTS(l_app_code),'Application "'||l_app_code||'" not found in memory!');
                  l_ver_code := lt_path(3);
                  l_ver_nbr := get_version_nbr(l_ver_code);
                  lt_ver := dbm_utility_var.ga_app(l_app_code);
                  assert(lt_ver.EXISTS(l_ver_nbr),'Version "'||l_ver_code||'" of application "'||l_app_code||'" not found in memory!');
                  lr_ver := lt_ver(l_ver_nbr);
                  r_curr_var := NULL;
                  r_last_var := NULL;
                  lt_ins.DELETE;
                  lt_upg.DELETE;
                  lt_uni.DELETE;
                  lt_val.DELETE;
                  lt_pre.DELETE;
                  lt_set.DELETE;
--                  la_fil.DELETE;
--                  la_obj.DELETE;
--                  lt_var.DELETE;
--                  la_par.DELETE;
                  la_fil := lr_ver.a_fil; -- keep existing files
                  la_obj := lr_ver.a_obj; -- keep existing objects
                  lt_var := lr_ver.t_var; -- keep existing variables
                  la_par := lr_ver.a_par; -- keep existing parameters
               END IF;
            END IF;
         -- Handle line of ".conf" file
         ELSIF l_file_ext = 'conf' THEN
            la_cfg := parse_cfg(r_str.text);
            IF la_cfg(1) = LOWER(l_app_code) AND la_cfg(2) = 'var' AND la_cfg.COUNT >= 4 THEN
               IF r_last_var.name IS NULL OR la_cfg(3) != r_last_var.name THEN
                  -- new config variable => save last one
                  IF r_last_var.name IS NOT NULL THEN
                     lt_var(lt_var.COUNT+1) := r_last_var;
                  END IF;
                  r_curr_var := NULL;
                  FOR i IN 1..lt_var.COUNT LOOP
                     IF  lt_var(i).app_code = la_cfg(1)
                     AND lt_var(i).name = la_cfg(3)
                     THEN
                        r_curr_var := lt_var(i);
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;
               r_curr_var.app_code := la_cfg(1);
               r_curr_var.name := la_cfg(3);
               IF    la_cfg(4) = 'name' THEN
                  assert(LOWER(la_cfg(5)) = r_curr_var.name,'Variable property "name" must be "'||r_curr_var.name||'", found: '||la_cfg(5));
                  r_curr_var.name := LOWER(la_cfg(5));
               ELSIF la_cfg(4) = 'descr' THEN
                  r_curr_var.descr := la_cfg(5);
               ELSIF la_cfg(4) = 'seq' THEN
                  BEGIN
                     r_curr_var.seq := TO_NUMBER(la_cfg(5));
                  EXCEPTION
                     WHEN OTHERS THEN
                        assert(FALSE, 'Variable property "seq" must be a number, found: '||la_cfg(5));
                        RAISE;
                  END;
               ELSIF la_cfg(4) = 'data_type' THEN
                  assert(UPPER(la_cfg(5)) IN ('CHAR','NUMBER','DATE'),'Variable property "name" must be CHAR, NUMBER or DATE", found: '||la_cfg(5));
                  r_curr_var.data_type := UPPER(la_cfg(5));
               ELSIF la_cfg(4) = 'nullable' THEN
                  assert(UPPER(la_cfg(5)) IN ('Y','N'), 'Variable property "nullable" must be Y or N, found: '||la_cfg(5));
                  r_curr_var.nullable := UPPER(la_cfg(5));
               ELSIF la_cfg(4) = 'convert_value_sql' THEN
                  r_curr_var.convert_value_sql := la_cfg(5);
               ELSIF la_cfg(4) = 'check_value_sql' THEN
                  r_curr_var.check_value_sql := la_cfg(5);
               ELSIF la_cfg(4) = 'default_value_sql' THEN
                  r_curr_var.default_value_sql := la_cfg(5);
               ELSIF la_cfg(4) = 'check_error_msg' THEN
                  r_curr_var.check_error_msg := la_cfg(5);
               ELSIF la_cfg(4) = 'value' THEN
                  r_curr_var.value := la_cfg(5);
               ELSE
                  assert(FALSE,'Invalid variable property: '||la_cfg(4));
               END IF;
            ELSIF la_cfg(1) = LOWER(l_app_code) AND la_cfg(2) = 'par' AND la_cfg.COUNT >= 3 THEN
               la_par(la_cfg(3)) := CASE WHEN la_cfg.COUNT >= 4 THEN SUBSTR(la_cfg(4),1,100) ELSE NULL END;
            END IF;
            r_last_var := r_curr_var;
         -- Handle line of "objects.dbm" file
         ELSIF LOWER(lt_path(lt_path.COUNT)) = 'objects.dbm' THEN
            r_obj := parse_object_inventory_line(r_str.text);
            r_obj.app_code := l_app_code;
            r_obj.ver_code := l_ver_code;
            la_obj(r_obj.name) := r_obj;
         -- Handle line of "files.dbm" files
         ELSIF LOWER(lt_path(lt_path.COUNT)) = 'files.dbm' THEN
            r_fil := NULL;
            l_pos := NVL(INSTR(r_str.text,':'),0);
            IF l_pos > 0 THEN
               r_fil.path := get_dir(l_path,TRUE)||SUBSTR(r_str.text,1,l_pos-1);
               r_fil.run_condition := TRIM(SUBSTR(r_str.text,l_pos+1));
            ELSE
               r_fil.path := get_dir(l_path,TRUE)||r_str.text;
               r_fil.run_condition := NULL;
            END IF;
            IF r_fil.run_condition IS NOT NULL THEN
               la_fil(r_fil.path) :=r_fil.run_condition;
--               update_fil(p_path=>r_fil.path, p_run_condition=>r_fil.run_condition);
            END IF;
         ELSIF SUBSTR(LOWER(lt_path(lt_path.COUNT)),-4) = '.dbm' THEN
            l_pos := NVL(INSTR(r_str.text, ':'),0);
            IF l_pos > 0 THEN
               l_path := get_dir(l_path,TRUE)||TRIM(SUBSTR(r_str.text, 1, l_pos-1));
               la_fil(l_path) := TRIM(SUBSTR(r_str.text, l_pos+1)); -- run condition
            ELSE
               l_path := get_dir(l_path,TRUE)||TRIM(r_str.text);
            END IF;
            IF LOWER(lt_path(lt_path.COUNT)) = 'install.dbm' THEN
               lt_ins(lt_ins.COUNT+1) := l_path;
            ELSIF LOWER(lt_path(lt_path.COUNT)) = 'upgrade.dbm' THEN
               lt_upg(lt_upg.COUNT+1) := l_path;
            ELSIF LOWER(lt_path(lt_path.COUNT)) = 'uninstall.dbm' THEN
               lt_uni(lt_uni.COUNT+1) := l_path;
            ELSIF LOWER(lt_path(lt_path.COUNT)) = 'validate.dbm' THEN
               lt_val(lt_val.COUNT+1) := l_path;
            ELSIF LOWER(lt_path(lt_path.COUNT)) = 'setup.dbm' THEN
               lt_set(lt_set.COUNT+1) := l_path;
            ELSIF LOWER(lt_path(lt_path.COUNT)) = 'precheck.dbm' THEN
               lt_pre(lt_pre.COUNT+1) := l_path;
            END IF;
         END IF;
      END LOOP;
      file_break;
      -- Delete stream
      DELETE dbm_streams
       WHERE type = 'OUT'
         AND cmd_id = p_cmd_id
      ;
      COMMIT;
   END;
--#begin public
   ---
   -- Show application properties and files
   ---
   PROCEDURE display_application (
      p_app_code IN dbm_applications.app_code%TYPE
    , p_ver_code IN dbm_versions.ver_code%TYPE := NULL
   )
--#end public
   IS
      l_app_code dbm_applications.app_code%TYPE;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      l_obj_name dbm_objects.name%TYPE;
      l_par_name dbm_utility_var.g_par_name_type;
      l_path dbm_utility_var.g_path_type;
      i PLS_INTEGER;
   BEGIN
      l_app_code := dbm_utility_var.ga_app.FIRST;
      WHILE l_app_code IS NOT NULL LOOP
         IF NVL(p_app_code,'all')='all' OR l_app_code = NVL(p_app_code,l_app_code) THEN
            lt_ver := dbm_utility_var.ga_app(l_app_code);
            dbms_output.put_line(l_app_code||' has '||lt_ver.COUNT||' versions');
            i := lt_ver.FIRST;
            WHILE i IS NOT NULL LOOP
               lr_ver := lt_ver(i);
               IF p_ver_code IS NULL OR lr_ver.r_ver.ver_code = p_ver_code THEN
                  dbms_output.put_line(l_app_code||' '||lr_ver.r_ver.ver_code||' ('||lr_ver.r_ver.ver_nbr||')');
                  dbms_output.put_line('- Installable: '||NVL(lr_ver.r_ver.installable,'N'));
                  FOR i IN NVL(lr_ver.t_ins_files.FIRST,1)..NVL(lr_ver.t_ins_files.LAST,0) LOOP
                     l_path := lr_ver.t_ins_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Install rollbackable: '||NVL(lr_ver.r_ver.install_rollbackable,'N'));
                  FOR i IN NVL(lr_ver.t_inr_files.FIRST,1)..NVL(lr_ver.t_inr_files.LAST,0) LOOP
                     l_path := lr_ver.t_inr_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Upgradeable: '||NVL(lr_ver.r_ver.upgradeable,'N'));
                  FOR i IN NVL(lr_ver.t_upg_files.FIRST,1)..NVL(lr_ver.t_upg_files.LAST,0) LOOP
                     l_path := lr_ver.t_upg_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Upgrade rollbackable: '||NVL(lr_ver.r_ver.upgrade_rollbackable,'N'));
                  FOR i IN NVL(lr_ver.t_upr_files.FIRST,1)..NVL(lr_ver.t_upr_files.LAST,0) LOOP
                     l_path := lr_ver.t_upr_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Uninstallable: '||NVL(lr_ver.r_ver.uninstallable,'N'));
                  FOR i IN NVL(lr_ver.t_uni_files.FIRST,1)..NVL(lr_ver.t_uni_files.LAST,0) LOOP
                     l_path := lr_ver.t_uni_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Validable: '||NVL(lr_ver.r_ver.validable,'N'));
                  FOR i IN NVL(lr_ver.t_val_files.FIRST,1)..NVL(lr_ver.t_val_files.LAST,0) LOOP
                     l_path := lr_ver.t_val_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Precheckable: '||NVL(lr_ver.r_ver.precheckable,'N'));
                  FOR i IN NVL(lr_ver.t_pre_files.FIRST,1)..NVL(lr_ver.t_pre_files.LAST,0) LOOP
                     l_path := lr_ver.t_pre_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  dbms_output.put_line('- Setupable: '||NVL(lr_ver.r_ver.setupable,'N'));
                  FOR i IN NVL(lr_ver.t_set_files.FIRST,1)..NVL(lr_ver.t_set_files.LAST,0) LOOP
                     l_path := lr_ver.t_set_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  IF lr_ver.t_cfg_files.COUNT > 0 THEN
                     dbms_output.put_line('- Configuration: ');
                  END IF;
                  FOR i IN NVL(lr_ver.t_cfg_files.FIRST,1)..NVL(lr_ver.t_cfg_files.LAST,0) LOOP
                     l_path := lr_ver.t_cfg_files(i);
                     dbms_output.put_line('.   '||l_path||CASE WHEN lr_ver.a_fil.EXISTS(l_path) THEN ': ' || lr_ver.a_fil(l_path) END);
                  END LOOP;
                  IF lr_ver.t_var.COUNT > 0 THEN
                     dbms_output.put_line('- Variables: ');
                  END IF;
                  FOR i IN NVL(lr_ver.t_var.FIRST,1)..NVL(lr_ver.t_var.LAST,0) LOOP
                     dbms_output.put_line('.   '||lr_ver.t_var(i).name||'='||lr_ver.t_var(i).value);
                  END LOOP;
                  IF lr_ver.a_par.COUNT > 0 THEN
                     dbms_output.put_line('- Parameters: ');
                  END IF;
                  l_par_name := lr_ver.a_par.FIRST;
                  WHILE l_par_name IS NOT NULL LOOP
                     dbms_output.put_line('.   '||l_par_name||'='||lr_ver.a_par(l_par_name));
                     l_par_name := lr_ver.a_par.NEXT(l_par_name);
                  END LOOP;
                  IF lr_ver.a_obj.COUNT > 0 THEN
                     dbms_output.put_line('- Database objects: ');
                  END IF;
                  l_obj_name := lr_ver.a_obj.FIRST;
                  WHILE l_obj_name IS NOT NULL LOOP
                     dbms_output.put_line('.   '||l_obj_name||CASE WHEN lr_ver.a_obj(l_obj_name).checksum IS NOT NULL THEN ': '||lr_ver.a_obj(l_obj_name).checksum END);
                     l_obj_name := lr_ver.a_obj.NEXT(l_obj_name);
                  END LOOP;
               END IF;
               i := lt_ver.NEXT(i);
            END LOOP;
         END IF;
         l_app_code := dbm_utility_var.ga_app.NEXT(l_app_code);
      END LOOP;
   END;
   ---
   -- Execute command line passed as arguments
   ---
   PROCEDURE parse_command_line (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_command IN VARCHAR2
    , p_command_line IN dbm_commands.command_line%TYPE
    , p_col_no IN PLS_INTEGER
    , p_len IN PLS_INTEGER
    , p_process_options IN BOOLEAN := FALSE
    , p_process_params IN BOOLEAN := FALSE
    , p_dbm_params_only IN BOOLEAN := FALSE
    , p_execute_command IN BOOLEAN := FALSE
    , p_save_cache IN BOOLEAN := FALSE
   )
   IS
      l_col_no PLS_INTEGER := p_col_no;
      l_option VARCHAR2(4000);
      l_value VARCHAR2(4000);
      l_cmd VARCHAR2(4000);
      l_cnt PLS_INTEGER := 0;
      l_pos PLS_INTEGER;
      l_save_cache BOOLEAN := p_save_cache;
      PROCEDURE output_exit (p_force IN BOOLEAN := FALSE) IS
      BEGIN
         IF dbm_utility_var.g_exit OR p_force THEN
            output_line(p_cmd_id, 'IN3','exit '||CHR(38)||CHR(38)||'_rc');
         END IF;
      END;
      PROCEDURE save_cache$ IS
      BEGIN
         IF l_save_cache THEN
            l_save_cache := FALSE;
            save_cache;
         END IF;
      END;
   BEGIN
      consume_white_spaces(p_command_line, l_col_no, p_len);
      IF l_col_no > p_len THEN
         save_cache$;
         RETURN;
      END IF;
      WHILE l_col_no <= p_len LOOP
         IF SUBSTR(p_command_line, l_col_no, 1) = '-' THEN
            l_col_no := l_col_no + 1;
            l_option := consume_until_ws_or_sep(p_command_line, l_col_no, p_len, '=');
            IF SUBSTR(p_command_line, l_col_no, 1) = '=' THEN
               l_col_no := l_col_no + 1;
               l_value := consume_until_ws_or_sep(p_command_line, l_col_no, p_len, '');
               IF l_option = 'conf_path' AND p_process_options THEN
                  assert(l_value IS NOT NULL, 'Missing value for "'||l_option||'" option!');
                  dbm_utility_var.g_conf_path := l_value;
               ELSIF l_option = 'file_extensions' AND p_process_options THEN
                  assert(l_value IS NOT NULL, 'Missing value for "'||l_option||'" option!');
                  dbm_utility_var.g_file_extensions := l_value;
               ELSIF p_process_params THEN
                  IF SUBSTR(l_option,1,4) IN ('par.','var.') THEN
                     l_option := 'dbm_utility.'||l_option;
                  ELSIF NVL(INSTR(l_option,'.'),0) = 0 THEN
                     l_option := 'dbm_utility.par.'||l_option;
                  END IF;
                  l_pos := NVL(INSTR(l_option,'.'),0);
                  IF NOT p_dbm_params_only OR l_option LIKE 'dbm_utility.%' THEN
                     output_line(p_cmd_id, 'OUT', '#!'||SUBSTR(l_option, 1, l_pos-1)||'.conf');
                     output_line(p_cmd_id, 'OUT', l_option||'='||l_value);
                     parse_configuration(p_cmd_id);
                  END IF;
               END IF;
            ELSIF p_process_options THEN
               IF l_option = 'noexit' THEN
                  dbm_utility_var.g_exit := FALSE;
               ELSIF l_option = 'exit' THEN
                  dbm_utility_var.g_exit := TRUE;
               ELSIF l_option = 'nodebug' THEN
                  dbm_utility_var.g_debug := FALSE;
               ELSIF l_option = 'debug' THEN
                  dbm_utility_var.g_debug := TRUE;
               ELSIF l_option = 'nosilent' THEN
                  dbm_utility_var.g_silent := FALSE;
               ELSIF l_option = 'silent' THEN
                  dbm_utility_var.g_silent := TRUE;
               ELSIF l_option = 'nosplash' THEN
                  dbm_utility_var.g_splash := FALSE;
               ELSIF l_option = 'splash' THEN
                  dbm_utility_var.g_splash := TRUE;
               ELSE
                  output_exit(TRUE);
                  raise_application_error(-20000,'Invalid option: '||l_option);
               END IF;
            END IF;
         ELSE
--            l_cmd := SUBSTR(p_command_line, l_col_no);
            l_cmd := consume_until_sep(p_command_line, l_col_no, p_len, '/');
            l_col_no := l_col_no + 1; -- skip separator
            IF p_execute_command THEN
               save_cache$;
               output_exit(FALSE);
               begin_command(l_cmd, p_cmd_id);
            END IF;
         END IF;
         consume_white_spaces(p_command_line, l_col_no, p_len);
      END LOOP;
      save_cache$;
      IF l_col_no<=p_len THEN
         output_exit(TRUE);
         raise_application_error(-20000, 'Unexpected input: '||SUBSTR(p_command_line, l_col_no));
      END IF;
   END;
   ---
   -- Startup
   ---
   PROCEDURE startup (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_command IN VARCHAR2
    , p_command_line IN dbm_commands.command_line%TYPE
    , p_col_no IN PLS_INTEGER
    , p_len IN PLS_INTEGER
   )
   IS
   BEGIN
      dbm_utility_var.ga_app.DELETE;
      -- Parse command line for potential config filename
      parse_command_line (
         p_cmd_id=>p_cmd_id
       , p_command=>p_command
       , p_command_line=>p_command_line
       , p_col_no=>p_col_no
       , p_len=>p_len
       , p_process_options=>TRUE
       , p_process_params=>FALSE
       , p_dbm_params_only=>FALSE
       , p_execute_command=>FALSE
      );
      IF dbm_utility_var.g_splash THEN
         -- Art generated using https://www.ascii-art-generator.org/
         output_line(p_cmd_id, 'IN','prompt ');
         output_line(p_cmd_id, 'IN','prompt  ____    ____    __  __           _   _   _____   ___   _       ___   _____  __   __');
         output_line(p_cmd_id, 'IN','prompt |  _ \  | __ )  |  \/  |         | | | | |_   _| |_ _| | |     |_ _| |_   _| \ \ / /');
         output_line(p_cmd_id, 'IN','prompt | | | | |  _ \  | |\/| |  _____  | | | |   | |    | |  | |      | |    | |    \ V / ');
         output_line(p_cmd_id, 'IN','prompt | |_| | | |_) | | |  | | |_____| | |_| |   | |    | |  | |___   | |    | |     | |  ');
         output_line(p_cmd_id, 'IN','prompt |____/  |____/  |_|  |_|          \___/    |_|   |___| |_____| |___|   |_|     |_|  ');
         output_line(p_cmd_id, 'IN','prompt ');
         output_line(p_cmd_id, 'IN','prompt ');
      END IF;
      output_line(p_cmd_id, 'IN','prompt Reading global configuration...');
      output_line(p_cmd_id, 'IN', 'host bin\read-files '||get_dir(dbm_utility_var.g_conf_path)||' '||get_filename(dbm_utility_var.g_conf_path)||' '||p_cmd_id||' >tmp\read-files.sql');
      output_line(p_cmd_id, 'IN', '@@tmp\read-files');
      output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.parse_configuration('||p_cmd_id||')');
--      output_line(p_cmd_id, 'IN', 'exec dbm_utility_krn.save_cache');
   END;
--#begin public
   ---
   -- Reset cache
   ---
   PROCEDURE reset_cache
--#end public
   IS
   BEGIN
      dbm_utility_var.ga_app.DELETE;
   END;
--#begin public
   ---
   -- Load cache from DB
   ---
   PROCEDURE load_cache
--#end public
   IS
      -- Browse all applications
      CURSOR c_app IS
         SELECT *
           FROM dbm_applications
          ORDER BY seq, app_code
      ;
      -- Browse all application versions
      CURSOR c_ver (
         p_app_code dbm_versions.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_versions
          WHERE app_code = p_app_code
          ORDER BY ver_nbr
      ;
      -- Browse all application version files
      CURSOR c_fil (
         p_app_code dbm_files.app_code%TYPE
       , p_ver_code dbm_files.ver_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_files
          WHERE app_code = p_app_code
            AND ver_code = p_ver_code
          ORDER BY type, seq
      ;
      -- Browse all application version files
      CURSOR c_obj (
         p_app_code dbm_files.app_code%TYPE
       , p_ver_code dbm_files.ver_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_objects
          WHERE app_code = p_app_code
            AND ver_code = p_ver_code
          ORDER BY name
      ;
      -- Browse all application variables
      CURSOR c_var (
         p_app_code dbm_variables.app_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_variables
          WHERE app_code = p_app_code
          ORDER BY name
      ;
      -- Browse all version parameters
      CURSOR c_par(
         p_app_code dbm_parameters.app_code%TYPE
       , p_ver_code dbm_parameters.ver_code%TYPE
      )
      IS
         SELECT *
           FROM dbm_parameters
          WHERE app_code = p_app_code
            AND ver_code = p_ver_code
          ORDER BY name
      ;
      -- Local variables
      lr_ver dbm_utility_var.r_ver_type;
      lt_ver dbm_utility_var.gt_ver_type;
   BEGIN
      dbm_utility_var.ga_app.DELETE;
      FOR r_app IN c_app LOOP
         lt_ver.DELETE;
         FOR r_ver IN c_ver(r_app.app_code) LOOP
            lr_ver := NULL;
            lr_ver.r_app := r_app;
            lr_ver.r_ver := r_ver;
            FOR r_fil IN c_fil(r_app.app_code, r_ver.ver_code) LOOP
               IF    r_fil.type = 'INSTALL' THEN
                  lr_ver.t_ins_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'ROLLBACK INSTALL' THEN
                  lr_ver.t_inr_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'UPGRADE' THEN
                  lr_ver.t_upg_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'ROLLBACK UPGRADE' THEN
                  lr_ver.t_upr_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'UNINSTALL' THEN
                  lr_ver.t_uni_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'VALIDATE' THEN
                  lr_ver.t_val_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'CONFIG' THEN
                  lr_ver.t_cfg_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'PRECHECK' THEN
                  lr_ver.t_pre_files(r_fil.seq) := r_fil.path;
               ELSIF r_fil.type = 'SETUP' THEN
                  lr_ver.t_set_files(r_fil.seq) := r_fil.path;
               END IF;
               IF r_fil.run_condition IS NOT NULL THEN
                  lr_ver.a_fil(r_fil.path) := r_fil.run_condition;
               END IF;
            END LOOP;
            FOR r_obj IN c_obj(r_app.app_code, r_ver.ver_code) LOOP
               lr_ver.a_obj(r_obj.name) := r_obj;
            END LOOP;
            FOR r_par IN c_par(r_app.app_code, r_ver.ver_code) LOOP
               IF r_par.name = 'os_name' THEN
                  dbm_utility_var.g_os_name := TRIM(r_par.value);
               ELSIF r_par.name = 'debug' THEN
                  dbm_utility_var.g_debug := UPPER(r_par.value) = 'TRUE';
               ELSIF r_par.name = 'splash' THEN
                  dbm_utility_var.g_splash := UPPER(r_par.value) = 'TRUE';
               ELSIF r_par.name = 'exit' THEN
                  dbm_utility_var.g_exit := UPPER(r_par.value) = 'TRUE';
               ELSIF r_par.name = 'conf_path' THEN
                  dbm_utility_var.g_conf_path := TRIM(r_par.value);
               ELSIF r_par.name = 'file_extensions' THEN
                  dbm_utility_var.g_os_name := TRIM(r_par.value);
               ELSE
                  lr_ver.a_par(r_par.name) := r_par.value;
               END IF;
            END LOOP;
            IF r_ver.ver_nbr = 0 THEN
               FOR r_var IN c_var(r_app.app_code) LOOP
                  lr_ver.t_var(lr_ver.t_var.COUNT+1) := r_var;
               END LOOP;
            END IF;
            lt_ver(lr_ver.r_ver.ver_nbr) := lr_ver;
         END LOOP;
         dbm_utility_var.ga_app(r_app.app_code) := lt_ver;
      END LOOP;
   END;
--#begin public
   ---
   -- Save cache into DB
   ---
   PROCEDURE save_cache (
      p_app_code dbm_applications.app_code%TYPE := NULL
   )
--#end public
   IS
      l_app_code dbm_applications.app_code%TYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      lt_ver dbm_utility_var.gt_ver_type;
      lr_ver dbm_utility_var.r_ver_type;
      l_obj_name dbm_objects.name%TYPE;
      la_obj dbm_utility_var.ga_obj_type;
      lr_obj dbm_objects%ROWTYPE;
      l_par_name dbm_parameters.name%TYPE;
      la_par dbm_utility_var.ga_par_type;
      lt_var dbm_utility_var.gt_var_type;
      lr_var dbm_variables%ROWTYPE;
      r_ver dbm_versions%ROWTYPE;
   BEGIN
      UPDATE dbm_applications SET deleted_flag = 'Y' WHERE app_code != 'all' AND (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      UPDATE dbm_versions SET deleted_flag = 'Y' WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code) ;
      UPDATE dbm_variables SET deleted_flag = 'Y' WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      UPDATE dbm_parameters SET deleted_flag = 'Y' WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      UPDATE dbm_objects SET deleted_flag = 'Y' WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      UPDATE dbm_files SET deleted_flag = 'Y' WHERE (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      l_app_code := dbm_utility_var.ga_app.FIRST;
      <<app_loop>>
      WHILE l_app_code IS NOT NULL LOOP
         IF NOT (NVL(p_app_code,'all')='all' OR l_app_code=p_app_code) THEN
            GOTO next_app;
         END IF;
         -- Save application
         upsert_app(p_app_code=>l_app_code, p_deleted_flag=>NULL);
         lt_ver := dbm_utility_var.ga_app(l_app_code);
         l_ver_nbr := lt_ver.FIRST;
         <<ver_loop>>
         WHILE l_ver_nbr IS NOT NULL LOOP
            lr_ver := lt_ver(l_ver_nbr);
            r_ver := lr_ver.r_ver;
            -- Update app seq and home_dir
            upsert_app(p_app_code=>lr_ver.r_app.app_code, p_seq=>lr_ver.r_app.seq, p_home_dir=>lr_ver.r_app.home_dir);
            -- Save version
            upsert_ver (
               p_app_code=>r_ver.app_code
             , p_ver_code=>r_ver.ver_code
             , p_ver_nbr=>r_ver.ver_nbr
             , p_installable=>r_ver.installable
             , p_install_rollbackable=>r_ver.install_rollbackable
             , p_upgradeable=>r_ver.upgradeable
             , p_upgrade_rollbackable=>r_ver.upgrade_rollbackable
             , p_uninstallable=>r_ver.uninstallable
             , p_validable=>r_ver.validable
             , p_precheckable=>r_ver.precheckable
             , p_setupable=>r_ver.setupable
             , p_deleted_flag=>NULL
            );
            -- Save files
            save_ver_files(lr_ver);
            -- Save variables
            lt_var := lr_ver.t_var;
            <<var_loop>>
            FOR i IN 1..lt_var.COUNT LOOP
               lr_var := lt_var(i);
               upsert_var(p_app_code=>lr_var.app_code, p_name=>lr_var.name, p_value=>lr_var.value
                         ,p_descr=>lr_var.descr, p_seq=>lr_var.seq, p_nullable=>lr_var.nullable
                         ,p_convert_value_sql=>lr_var.convert_value_sql, p_check_value_sql=>lr_var.check_value_sql
                         ,p_default_value_sql=>lr_var.default_value_sql, p_check_error_msg=>lr_var.check_error_msg
                         ,p_deleted_flag=>NULL
                         );
            END LOOP var_loop;
            -- Save parameters
            la_par := lr_ver.a_par;
            l_par_name := la_par.FIRST;
            <<par_loop>>
            WHILE l_par_name IS NOT NULL LOOP
               upsert_par(p_app_code=>lr_ver.r_ver.app_code, p_ver_code=>lr_ver.r_ver.ver_code, p_name=>l_par_name, p_value=>la_par(l_par_name), p_deleted_flag=>NULL);
               l_par_name := la_par.NEXT(l_par_name);
            END LOOP par_loop;
            -- Save objects
            la_obj := lr_ver.a_obj;
            l_obj_name := la_obj.FIRST;
            <<obj_loop>>
            WHILE l_obj_name IS NOT NULL LOOP
               lr_obj := la_obj(l_obj_name);
               upsert_obj(p_app_code=>lr_ver.r_ver.app_code, p_ver_code=>lr_ver.r_ver.ver_code, p_name=>lr_obj.name, p_checksum=>lr_obj.checksum, p_condition=>lr_obj.condition, p_deleted_flag=>NULL);
               l_obj_name := la_obj.NEXT(l_obj_name);
            END LOOP obj_loop;
            -- Next version
            l_ver_nbr := lt_ver.NEXT(l_ver_nbr);
         END LOOP ver_loop;
         -- Next app
         <<next_app>>
         l_app_code := dbm_utility_var.ga_app.NEXT(l_app_code);
      END LOOP app_loop;
      -- Delete unreferenced data
      DELETE dbm_files WHERE deleted_flag = 'Y' AND run_date IS NULL AND (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      DELETE dbm_objects WHERE deleted_flag = 'Y' AND (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      DELETE dbm_parameters WHERE deleted_flag = 'Y' AND (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      DELETE dbm_variables WHERE deleted_flag = 'Y' AND (NVL(p_app_code,'all')='all' OR app_code = p_app_code);
      UPDATE dbm_versions
         SET deleted_flag = NULL
       WHERE (app_code, ver_code) IN (
                SELECT app_code, ver_code FROM dbm_files
                UNION
                SELECT app_code, ver_code FROM dbm_objects
                UNION
                SELECT app_code, ver_code FROM dbm_parameters
             )
      ;
      UPDATE dbm_applications
         SET ver_code = NULL
           , ver_status = NULL
       WHERE (app_code, ver_code) IN (
                SELECT app_code, ver_code
                  FROM dbm_versions
                 WHERE deleted_flag = 'Y'
             )
      ;
      DELETE dbm_versions
       WHERE deleted_flag = 'Y'
      ;
      DELETE dbm_applications
       WHERE deleted_flag = 'Y'
         AND app_code NOT IN (
             SELECT app_code FROM dbm_files
             UNION
             SELECT app_code FROM dbm_objects
             UNION
             SELECT app_code FROM dbm_parameters
             UNION
             SELECT app_code FROM dbm_variables
             UNION
             SELECT app_code FROM dbm_versions
         )
      ;
      -- Save globals
      upsert_app(p_app_code=>'dbm_utility');
      upsert_ver(p_app_code=>'dbm_utility', p_ver_code=>'all', p_ver_nbr=>0);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'os_name', p_value=>dbm_utility_var.g_os_name, p_deleted_flag=>NULL);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'debug', p_value=>CASE WHEN dbm_utility_var.g_debug THEN 'TRUE' ELSE 'FALSE' END, p_deleted_flag=>NULL);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'splash', p_value=>CASE WHEN dbm_utility_var.g_splash THEN 'TRUE' ELSE 'FALSE' END, p_deleted_flag=>NULL);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'exit', p_value=>CASE WHEN dbm_utility_var.g_exit THEN 'TRUE' ELSE 'FALSE' END, p_deleted_flag=>NULL);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'conf_path', p_value=>dbm_utility_var.g_conf_path, p_deleted_flag=>NULL);
      upsert_par(p_app_code=>'dbm_utility', p_ver_code=>'all', p_name=>'file_extensions', p_value=>dbm_utility_var.g_file_extensions, p_deleted_flag=>NULL);
      recompute_ver_statuses;
      COMMIT;
   END;
   ---
   -- Check if a file has a valid extension
   ---
   FUNCTION is_valid_file_extension (
      p_path IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN INSTR(','||LOWER(REPLACE(dbm_utility_var.g_file_extensions, ' '))||',',','||LOWER(get_file_extension(p_path))||',') > 0;
   END;
--#begin public
   ---
   -- Parse list of files returned by scan-files
   ---
   PROCEDURE parse_files (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
   )
--#end public
   IS
      CURSOR c_str IS
         SELECT *
           FROM dbm_streams
          WHERE cmd_id = p_cmd_id
            AND type = 'OUT'
          ORDER BY line
      ;
      l_pos PLS_INTEGER;
      lt_path sys.dbms_sql.varchar2a;
      lt_ver dbm_utility_var.gt_ver_type;
      r_curr_ver dbm_utility_var.r_ver_type;
      r_last_ver dbm_utility_var.r_ver_type;
      l_app_code dbm_applications.app_code%TYPE;
      l_seq dbm_applications.seq%TYPE;
      l_home_dir dbm_applications.home_dir%TYPE;
      r_app dbm_applications%ROWTYPE;
      l_ver_code dbm_versions.ver_code%TYPE;
      l_ver_nbr dbm_versions.ver_nbr%TYPE;
      l_apps_dir dbm_utility_var.g_par_value_type := get_apps_dir;
      t_files sys.dbms_sql.varchar2a;
   BEGIN
      r_curr_ver := NULL;
      r_last_ver := NULL;
      FOR r_str IN c_str LOOP
--         dbms_output.put_line(r_str.line||': '||r_str.text);
         lt_path := parse_path(r_str.text);
         IF lt_path.COUNT >= 3 AND LOWER(lt_path(2)) = 'releases' THEN
            l_home_dir := lt_path(1);
            lt_path(3) := LOWER(lt_path(3)); -- version ALL => all
            parse_app_path(lt_path(1), l_app_code, l_seq);
            IF l_app_code != NVL(r_last_ver.r_ver.app_code, l_app_code) THEN
               -- new application => save last application and its version
               lt_ver(r_last_ver.r_ver.ver_nbr) := r_last_ver;
               dbm_utility_var.ga_app(r_last_ver.r_ver.app_code) := lt_ver;
               r_last_ver := NULL;
               r_curr_ver := NULL;
               lt_ver.DELETE;
            END IF;
            IF lt_path(3) != NVL(r_last_ver.r_ver.ver_code, lt_path(3)) THEN
               -- new version => add last version to application
               lt_ver(r_last_ver.r_ver.ver_nbr) := r_last_ver;
               r_last_ver.r_ver := NULL;
               r_curr_ver := NULL;
            END IF;
            IF is_valid_ver_nbr(lt_path(3)) THEN
               l_ver_nbr := get_version_nbr(lt_path(3));
               l_ver_code := lt_path(3);
            ELSIF LOWER(lt_path(3)) = 'all' THEN
               l_ver_nbr := 0;
               l_ver_code := 'all';
               IF LOWER(l_app_code) = 'all' THEN
                  r_curr_ver.r_ver.ver_status := 'CURRENT';
               END IF;
            ELSE
               l_ver_nbr := NULL;
               l_ver_code := NULL;
               GOTO next_str;
--               dbms_output.put_line('WARNING: invalid version directory "'||lt_path(3)||'" was ignored: ');
            END IF;
            -- Get existing app and ver
            IF dbm_utility_var.ga_app.EXISTS(l_app_code) THEN
               IF r_last_ver.r_app.app_code IS NULL THEN
                  lt_ver := dbm_utility_var.ga_app(l_app_code);
               END IF;
               IF r_last_ver.r_ver.ver_nbr IS NULL AND lt_ver.EXISTS(l_ver_nbr) THEN
                  r_curr_ver := lt_ver(l_ver_nbr);
               END IF;
            END IF;
            r_curr_ver.r_app.app_code := l_app_code;
            r_curr_ver.r_app.seq := l_seq;
            r_curr_ver.r_app.home_dir := l_home_dir;
            r_curr_ver.r_ver.app_code := l_app_code;
            r_curr_ver.r_ver.ver_nbr := l_ver_nbr;
            r_curr_ver.r_ver.ver_code := l_ver_code;
            IF r_curr_ver.r_ver.ver_code IS NOT NULL AND lt_path.COUNT >= 4 THEN
               IF lt_path(4) = 'install' AND lt_path.COUNT >=5 AND lt_path(5) = 'rollback' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF is_valid_file_extension(lt_path(6)) THEN
                        r_curr_ver.t_inr_files(NVL(r_curr_ver.t_inr_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.install_rollbackable := CASE WHEN r_curr_ver.t_inr_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'install' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'install.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'install.sql' THEN
                        r_curr_ver.t_ins_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_ins_files(NVL(r_curr_ver.t_ins_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.installable := CASE WHEN r_curr_ver.t_ins_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'upgrade' AND lt_path.COUNT >=5 AND lt_path(5) = 'rollback' THEN
                  IF lt_path.COUNT >= 6 THEN
                     IF is_valid_file_extension(lt_path(6)) THEN
                        r_curr_ver.t_upr_files(NVL(r_curr_ver.t_upr_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.upgrade_rollbackable := CASE WHEN r_curr_ver.t_upr_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'upgrade' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'upgrade.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'upgrade.sql' THEN
                        r_curr_ver.t_upg_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_upg_files(NVL(r_curr_ver.t_upg_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.upgradeable := CASE WHEN r_curr_ver.t_upg_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'uninstall' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'uninstall.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'uninstall.sql' THEN
                        r_curr_ver.t_uni_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_uni_files(NVL(r_curr_ver.t_uni_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.uninstallable := CASE WHEN r_curr_ver.t_uni_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'validate' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'validate.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'validate.sql' THEN
                        r_curr_ver.t_val_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_val_files(NVL(r_curr_ver.t_val_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.validable := CASE WHEN r_curr_ver.t_val_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'setup' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'setup.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'setup.sql' THEN
                        r_curr_ver.t_set_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_set_files(NVL(r_curr_ver.t_set_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.setupable := CASE WHEN r_curr_ver.t_set_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path(4) = 'precheck' THEN
                  IF lt_path.COUNT >= 5 THEN
                     IF lt_path(5) = 'precheck.dbm' THEN
                        r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
                     ELSIF lt_path(5) = 'precheck.sql' THEN
                        r_curr_ver.t_pre_files(0) := r_str.text;
                     ELSIF is_valid_file_extension(lt_path(5)) THEN
                        r_curr_ver.t_pre_files(NVL(r_curr_ver.t_pre_files.LAST,0)+1) := r_str.text;
                     END IF;
                  END IF;
                  r_curr_ver.r_ver.precheckable:= CASE WHEN r_curr_ver.t_pre_files.COUNT > 0 THEN 'Y' ELSE NULL END;
               ELSIF lt_path.COUNT >= 5 AND ((lt_path(4) = 'config' AND LOWER(get_file_extension(lt_path(5))) = 'conf') OR LOWER(lt_path(5)) = 'objects.dbm') THEN
                  r_curr_ver.t_cfg_files(NVL(r_curr_ver.t_cfg_files.LAST,0)+1) := r_str.text;
               END IF;
            END IF;
         END IF;
         IF r_curr_ver.r_ver.ver_code IS NOT NULL THEN
            r_last_ver := r_curr_ver;
         END IF;
         <<next_str>>
         NULL;
      END LOOP;
      IF r_last_ver.r_ver.app_code IS NOT NULL THEN
         -- save application and its versions
         lt_ver(r_last_ver.r_ver.ver_nbr) := r_last_ver;
         dbm_utility_var.ga_app(r_last_ver.r_ver.app_code) := lt_ver;
      END IF;
      -- Clean-up
      DELETE dbm_streams
       WHERE cmd_id = p_cmd_id
         AND type = 'OUT';
      -- Delete obsolete applications and versions
--      DELETE dbm_versions WHERE deleted_flag = 'Y';
--      DELETE dbm_applications WHERE deleted_flag = 'Y';
--      DELETE dbm_variables WHERE deleted_flag = 'Y';
      COMMIT;
   END;
--#begin public
   ---
   -- Parse hashes returned by get-hashes
   ---
   PROCEDURE parse_hashes (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_op IN VARCHAR2 -- set-hashes / chk-hashes
    , p_apps_dir IN VARCHAR2
   )
--#end public
   IS
      CURSOR c_str IS
         SELECT *
           FROM dbm_streams
          WHERE cmd_id = p_cmd_id
            AND type = 'OUT'
          ORDER BY line
      ;
      l_hash dbm_files.hash%TYPE;
      l_path dbm_files.path%TYPE;
      r_fil dbm_files%ROWTYPE;
   BEGIN
      FOR r_str IN c_str LOOP
         l_hash := SUBSTR(r_str.text,1,32);
         l_path := SUBSTR(r_str.text,34);
         IF l_path LIKE p_apps_dir ||'%' THEN
            l_path := SUBSTR(l_path,LENGTH(p_apps_dir)+1);
         END IF;
         IF p_op = 'set-hashes' THEN
            update_fil(p_path=>l_path, p_hash=>l_hash, p_status=>'NORMAL', p_raise_exception=>FALSE);
         ELSIF p_op = 'chk-hashes' THEN
            r_fil := get_file(l_path);
            IF r_fil.run_status = 'SUCCESS' THEN -- only check files executed successfully
               update_fil(p_path=>l_path, p_status=>CASE WHEN NVL(r_fil.hash,'~') = NVL(l_hash,'~') THEN 'NORMAL' ELSE 'TAMPERED' END, p_raise_exception=>FALSE);
            END IF;
         ELSE
            assert(FALSE,'Invalid op in parse-hashes(): '||p_op);
         END IF;
      END LOOP;
      DELETE dbm_streams WHERE cmd_id = p_cmd_id AND type = 'OUT';
      COMMIT;
   END;
   ---
   -- Scan file system
   ---
   PROCEDURE scan_files (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_command IN VARCHAR2
    , p_command_line IN dbm_commands.command_line%TYPE
    , p_col_no IN PLS_INTEGER
    , p_len IN PLS_INTEGER
   )
   IS
   BEGIN
      parse_command_line (
         p_cmd_id=>p_cmd_id
       , p_command=>p_command
       , p_command_line=>p_command_line
       , p_col_no=>p_col_no
       , p_len=>p_len
       , p_process_options=>FALSE
       , p_process_params=>TRUE
       , p_dbm_params_only=>TRUE
       , p_execute_command=>FALSE
      );
      IF dbm_utility_var.g_debug THEN
         output_line(p_cmd_id, 'IN', 'prompt Scanning file system under "'||get_apps_dir||'"...');
      ELSE
         output_line(p_cmd_id, 'IN', 'prompt Scanning file system...');
      END IF;
      output_line(p_cmd_id, 'IN', 'host bin\scan-files '||get_apps_dir||' '||p_cmd_id||' >tmp\scan-files.sql');
      output_line(p_cmd_id, 'IN', '@@tmp\scan-files.sql');
--    output_line(r_cmd.cmd_id, 'IN', 'host del find-files.sql'); -- TBD, OS dependent
   END;
   ---
   -- Parse operation
   ---
   PROCEDURE parse_op (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_command IN VARCHAR2
    , p_command_line IN dbm_commands.command_line%TYPE
    , p_col_no IN PLS_INTEGER
    , p_len IN PLS_INTEGER
   )
   IS
      l_col_no PLS_INTEGER := p_col_no;
      l_buf VARCHAR2(4000);
      r_ver dbm_versions%ROWTYPE;
      l_force BOOLEAN := FALSE;
   BEGIN
      l_buf := consume_identifier(p_command_line, l_col_no, p_len);
      assert(LENGTH(l_buf)<=30, 'Application code must be 30 characters max!');
      r_ver.app_code := l_buf;
      IF p_command IN ('set-current') THEN
         assert(r_ver.app_code IS NOT NULL, 'Application code is mandatory!');
      END IF;
      assert(NOT (p_command='set-current' AND r_ver.app_code IS NULL),'Application is mandatory for "set-current" command!');
      assert(NOT (p_command='set-current' AND NVL(r_ver.app_code,'all')='all'),'Application "all" not allowed for "set-current" command!');
      assert(NOT (p_command='make-inventory' AND r_ver.app_code IS NULL),'Application is mandatory for "make-inventory" command!');
      assert(NVL(r_ver.app_code,'all')='all' OR dbm_utility_var.ga_app.EXISTS(r_ver.app_code), 'Application "'||r_ver.app_code||'" not found on file system!');
      IF r_ver.app_code IS NOT NULL THEN
         IF p_command IN ('migrate','install','upgrade','precheck','validate','display','set-current','check-files','make-inventory') THEN
            IF p_command IN ('migrate','install','upgrade','precheck') AND UPPER(SUBSTR(p_command_line, l_col_no,4)) = 'NEXT' THEN
               l_buf := UPPER(consume_identifier(p_command_line, l_col_no, p_len));
               r_ver.ver_status := 'NEXT';
            ELSE
               l_buf := consume_number(p_command_line, l_col_no, p_len);
               IF l_buf IS NOT NULL THEN
                  assert(r_ver.app_code!='all','Version not allowed with application "all"!');
                  assert(LENGTH(l_buf)<=8, 'Version must be 8 characters max!');
                  r_ver.ver_code := l_buf;
               END IF;
            END IF;
         ELSIF p_command = 'uninstall' AND LOWER(SUBSTR(p_command_line, l_col_no, 5)) = 'force' THEN
            l_buf := LOWER(consume_identifier(p_command_line, l_col_no, p_len));
            assert(l_buf = 'force', 'Invalid command option: '||l_buf);
            l_force := TRUE;
         END IF;
      END IF;
      assert(l_col_no>p_len, 'Unexpected input: '||SUBSTR(p_command_line, l_col_no));
      assert(NOT (p_command='set-current' AND r_ver.ver_code IS NULL),'Version is mandatory for "set-current" command!');
--      assert(NOT (p_command='make-inventory' AND r_ver.ver_code IS NULL),'Version is mandatory for "make-inventory" command!');
      r_ver.app_code := NVL(r_ver.app_code,'all');
      IF r_ver.ver_code IS NOT NULL THEN
         r_ver.ver_nbr := get_version_nbr(r_ver.ver_code);
         assert(dbm_utility_var.ga_app(r_ver.app_code).EXISTS(r_ver.ver_nbr),'Version "'||r_ver.ver_code||'" of application "'||r_ver.app_code||'" not found on file system!');
      END IF;
      recompute_ver_statuses(p_app_code=>r_ver.app_code,p_ver_code=>r_ver.ver_code);
      IF p_command IN ('migrate') THEN
         migrate(p_cmd_id, r_ver, FALSE);
      ELSIF p_command IN ('install','upgrade') THEN
         migrate(p_cmd_id, r_ver, FALSE, UPPER(p_command));
      ELSIF p_command = 'precheck' THEN
         migrate(p_cmd_id, r_ver, TRUE);
      ELSIF p_command = 'uninstall' THEN
         uninstall(p_cmd_id, r_ver.app_code, l_force);
      ELSIF p_command = 'validate' THEN
         validate(p_cmd_id, r_ver.app_code, r_ver.ver_code);
      ELSIF p_command = 'configure' THEN
         configure(p_cmd_id, r_ver);
      ELSIF p_command = 'setup' THEN
         setup(p_cmd_id, r_ver.app_code);
      ELSIF p_command = 'rollback' THEN
         rollback_migration(p_cmd_id, r_ver.app_code, r_ver.ver_code);
      ELSIF p_command = 'check-files' THEN
         check_files(p_cmd_id, r_ver.app_code, r_ver.ver_code);
      ELSIF p_command = 'display' THEN
         display_application(r_ver.app_code, r_ver.ver_code);
      ELSIF p_command = 'best-guess-current' THEN
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.guess_set_current('||p_cmd_id||', "'||r_ver.app_code||'", TRUE,TRUE);','"',''''));
      ELSIF p_command = 'guess-current' THEN
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.guess_set_current('||p_cmd_id||', "'||r_ver.app_code||'", TRUE,FALSE);','"',''''));
      ELSIF p_command = 'set-current' THEN
         output_line(p_cmd_id,'IN',REPLACE('exec dbm_utility_krn.set_current('||p_cmd_id||', "'||r_ver.app_code||'", "'||r_ver.ver_code||'");','"',''''));
      ELSIF p_command = 'make-inventory' THEN
         make_inventory(p_cmd_id, r_ver.app_code, r_ver.ver_code);
      ELSIF p_command = 'show-current' THEN
         show_current(r_ver.app_code);
      END IF;
   END;
   -- Determine the hosting platform of the DB we are connected to: DC, CoP, AWS
   FUNCTION get_db_hosting_platform
   RETURN VARCHAR2
   IS
      CURSOR c_env IS
         SELECT SUBSTR(env, 2)
           FROM (
                  SELECT DECODE(username , 'C##APPDBA', '1COP' , 'C##DC_DBA', '2DC' , 'RDSADMIN', '3AWS' ) env 
                    FROM all_users
                   WHERE username IN ('C##DC_DBA','RDSADMIN','C##APPDBA')
                   ORDER BY env ASC
                ) 
          WHERE ROWNUM = 1
      ;
      l_env VARCHAR2(3);
   BEGIN
      OPEN c_env;
      FETCH c_env INTO l_env;
      CLOSE c_env;
      RETURN l_env;
   END;
--#begin public
   ---
   -- Execute a command and return its id
   ---
   FUNCTION begin_command (
      p_command_line IN dbm_commands.command_line%TYPE
    , p_cmd_id IN dbm_commands.command_line%TYPE := NULL
   )
   RETURN PLS_INTEGER
--#end public
   IS
      l_command dbm_commands.command_line%TYPE;
      l_cmd dbm_commands.command_line%TYPE;
      l_col_no PLS_INTEGER := 1;
      l_len PLS_INTEGER := LENGTH(p_command_line);
      r_cmd dbm_commands%ROWTYPE;
      l_log BOOLEAN := FALSE;
      PROCEDURE insert_command (
         p_log IN BOOLEAN := FALSE
      )
      IS
         CURSOR c_cmd IS SELECT * FROM dbm_commands WHERE cmd_id = p_cmd_id;
      BEGIN
         l_log := p_log;
         IF p_cmd_id IS NOT NULL THEN
             OPEN c_cmd;
             FETCH c_cmd INTO r_cmd;
             CLOSE c_cmd;
             assert(r_cmd.cmd_id IS NOT NULL, 'Command #'||p_cmd_id||' not found!');
         ELSE
            INSERT INTO dbm_commands (
               command_line, start_date_time, status
            ) VALUES (
               p_command_line, SYSDATE, 'ONGOING'
            )
            RETURNING cmd_id, start_date_time INTO r_cmd.cmd_id, r_cmd.start_date_time
            ;
            COMMIT;
         END IF;
         IF p_log THEN
            r_cmd.log_file_name := 'logs'||'\'||TO_CHAR(r_cmd.start_date_time,'YYYYMMDDHH24MISS')||'-'||r_cmd.cmd_id||'-'||REPLACE(TRIM(p_command_line),' ','-')||'.log';
            UPDATE dbm_commands
               SET log_file_name = r_cmd.log_file_name
             WHERE cmd_id = r_cmd.cmd_id
            ;
            COMMIT;
            output_line(r_cmd.cmd_id, 'IN', 'spool '||r_cmd.log_file_name);
         END IF;
      END;
      -- Expand abbreviated command to full command
      FUNCTION get_full_cmd (
         p_command IN VARCHAR2 -- abbreviated command
      )
      RETURN dbm_commands.command_line%TYPE -- full command
      IS
         -- ABC)DE means ABC, ABCD, ABCDE are matching
         -- while A, AB, ABCDEF are not matching
         l_len PLS_INTEGER;
         l_cmd dbm_commands.command_line%TYPE;
      BEGIN
         l_len := LENGTH(p_command);
         l_cmd := dbm_utility_var.ga_cmd.FIRST;
         WHILE l_cmd IS NOT NULL LOOP
            IF  l_len BETWEEN dbm_utility_var.ga_cmd(l_cmd) AND LENGTH(l_cmd)
            AND p_command = SUBSTR(l_cmd,1,l_len)
            THEN
               RETURN l_cmd;
            END IF;
            l_cmd := dbm_utility_var.ga_cmd.NEXT(l_cmd);
         END LOOP;
         RETURN NULL;
      END;
      -- Use a fork of SQL*Plus to execute command
      PROCEDURE fork_sqlplus (
         p_sqlplus_script IN VARCHAR2 := 'plus'
      )
      IS
      BEGIN
         output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'set termout on', p_line=>-6);
         output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'set serveroutput on size 999999', p_line=>-5);
         output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'set linesize 300', p_line=>-4);
         output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'set feedback off', p_line=>-3);
         output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'set verify off', p_line=>-2);
         IF p_sqlplus_script = 'plus' THEN
            output_line(p_cmd_id=>r_cmd.cmd_id, p_type=>'IN', p_text=>'exec dbm_utility_krn.load_cache', p_line=>-1);
         END IF;
         output_line(r_cmd.cmd_id,'IN','exit 0');
         IF l_log THEN
            output_line(r_cmd.cmd_id, 'IN', 'spool off');
            l_log := NULL;
         END IF;
         UPDATE dbm_streams
            SET type = 'IN2'
          WHERE cmd_id = r_cmd.cmd_id
            AND type = 'IN';
         COMMIT;
         output_line(r_cmd.cmd_id, 'IN', 'host bin\'||p_sqlplus_script||' @tmp\step2');
      END;
      PROCEDURE finally IS
      BEGIN
         IF l_log THEN
            output_line(r_cmd.cmd_id, 'IN', 'spool off');
         END IF;
      END;
   BEGIN
      assert(p_command_line IS NOT NULL, 'Command line must not be empty!');
      l_command := LOWER(consume_identifier(p_command_line, l_col_no, l_len));
      l_command := get_full_cmd(l_command);
      IF l_command IS NULL THEN
         insert_command(FALSE);
         dbms_output.put_line('ERROR - Invalid command: '||p_command_line);
         dbms_output.put_line('Execute @dbm-cli help to get list of valid commands.');
         raise_application_error(-20000, '');
      ELSIF l_command = 'help' THEN
         insert_command(FALSE);
         dbms_output.put_line('----------------------------------------');
         dbms_output.put_line('Database Migration Utility - DBM_UTILITY');
         dbms_output.put_line('Copyright (C) 2024 European Commission');
         dbms_output.put_line('----------------------------------------');
         dbms_output.put_line('Usage: @dbm-cli <command>');
         dbms_output.put_line('where <command> is one of the following:');
         dbms_output.put_line('- conf[igure] [<application>]');
         dbms_output.put_line('- check[-files] [<application>]');
         dbms_output.put_line('- disp[lay] [<application> [<version>]]');
         dbms_output.put_line('- guess[-current] [<application>]');
         dbms_output.put_line('- help');
         dbms_output.put_line('- mig[rate] [<application> [<version>]]');
         dbms_output.put_line('- read[-config]');
         dbms_output.put_line('- roll[back] <application>');
         dbms_output.put_line('- scan[-files]');
         dbms_output.put_line('- set[-current] [<application>]');
         dbms_output.put_line('- setup [<application>]');
         dbms_output.put_line('- show[-current] [<application>]');
         dbms_output.put_line('- uninst[all] [<application>]');
         dbms_output.put_line('- val[idate] [<application>]');
         dbms_output.put_line('----------------------------------------');
      ELSIF l_command = 'load-cache' THEN
         insert_command(FALSE);
         load_cache;
      ELSIF l_command = 'save-cache' THEN
         insert_command(FALSE);
         save_cache;
      ELSIF l_command = 'noop' THEN
         insert_command(FALSE);
         noop;
      ELSIF l_command IN ('migrate','install','upgrade','precheck','uninstall','rollback','validate') THEN
         -- Log and fork
         insert_command(TRUE);
         parse_op(r_cmd.cmd_id, l_command, p_command_line, l_col_no, l_len);
         fork_sqlplus;
      ELSIF l_command IN ('check-files','setup') THEN
         -- Log and no fork
         insert_command(TRUE);
         parse_op(r_cmd.cmd_id, l_command, p_command_line, l_col_no, l_len);
      ELSIF l_command IN ('configure','display','set-current','guess-current','best-guess-current','show-current','make-inventory') THEN
         -- No log and no fork
         insert_command(FALSE);
         parse_op(r_cmd.cmd_id, l_command, p_command_line, l_col_no, l_len);
      ELSIF l_command = 'read-config' THEN
         insert_command(FALSE);
         read_config(p_cmd_id=>r_cmd.cmd_id, p_apps_config=>TRUE, p_inventories=>TRUE);
      ELSIF l_command = 'startup' THEN
         insert_command(FALSE);
         startup(r_cmd.cmd_id, l_command, p_command_line, l_col_no, l_len);
      ELSIF l_command = 'execute' THEN
         -- Log and do not fork
         insert_command(FALSE);
         parse_command_line (
            p_cmd_id=>r_cmd.cmd_id
          , p_command=>l_command
          , p_command_line=>p_command_line
          , p_col_no=>l_col_no
          , p_len=>l_len
          , p_process_options=>TRUE
          , p_process_params=>TRUE
          , p_dbm_params_only=>FALSE
          , p_execute_command=>TRUE
          , p_save_cache=>TRUE
         );
      ELSIF l_command = 'scan-files' THEN
         insert_command(FALSE);
         scan_files(r_cmd.cmd_id, l_command, p_command_line, l_col_no, l_len);
      ELSIF l_command = 'read-file' THEN
         insert_command(FALSE);
         IF TRIM(SUBSTR(p_command_line,l_col_no)) IS NOT NULL THEN
            IF dbm_utility_var.g_debug THEN
               output_line(r_cmd.cmd_id, 'IN', 'prompt Reading file "'||TRIM(SUBSTR(p_command_line,l_col_no))||'"...');
            ELSE
               output_line(r_cmd.cmd_id, 'IN', 'prompt Reading file...');
            END IF;
            output_line(r_cmd.cmd_id, 'IN', 'host bin\read-file '||TRIM(SUBSTR(p_command_line,l_col_no))||' '||r_cmd.cmd_id||' >tmp\read-file.sql');
            output_line(r_cmd.cmd_id, 'IN', '@@tmp\read-file.sql');
--          output_line(r_cmd.cmd_id, 'IN', 'host del read-files.sql'); -- TBD, OS dependent
            output_line(r_cmd.cmd_id, 'IN', 'prompt File read successfully');
         ELSE
            raise_application_error(-20000, 'Missing file name or path!');
         END IF;
      ELSIF l_command = 'create-restore-point' THEN
         insert_command(TRUE);
         assert(get_db_hosting_platform = 'COP', 'This command is supported only on Cloud on Prem infrastructure!');
         output_whenever_sqlerror(r_cmd.cmd_id, 'IN');
         output_line(r_cmd.cmd_id, 'IN', REPLACE('ALTER SESSION SET CONTAINER=CDB$ROOT;','"',''''));
         output_line(r_cmd.cmd_id, 'IN', REPLACE('exec dc_indb_request.pdb_rp(pdb_nm=>"'||dbm_utility_var.g_db_name||'", oper=>"create", rp_name=>"'||dbm_utility_var.g_rp_name||'")','"',''''));
         output_line(r_cmd.cmd_id, 'IN', 'Prompt Restore point created successfully.');
         fork_sqlplus('sqldba');
      ELSIF l_command = 'drop-restore-point' THEN
         insert_command(TRUE);
         assert(get_db_hosting_platform = 'COP', 'This command is supported only on Cloud on Prem infrastructure!');
         output_whenever_sqlerror(r_cmd.cmd_id, 'IN');
         output_line(r_cmd.cmd_id, 'IN', REPLACE('ALTER SESSION SET CONTAINER=CDB$ROOT;','"',''''));
         output_line(r_cmd.cmd_id, 'IN', REPLACE('exec dc_indb_request.pdb_rp(pdb_nm=>"'||dbm_utility_var.g_db_name||'", oper=>"drop", rp_name=>"'||dbm_utility_var.g_rp_name||'")','"',''''));
         output_line(r_cmd.cmd_id, 'IN', 'Prompt Restore point dropped successfully.');
         fork_sqlplus('sqldba');
      ELSIF l_command = 'flashback-database' THEN
         insert_command(TRUE);
         assert(get_db_hosting_platform = 'COP', 'This command is supported only on Cloud on Prem infrastructure!');
         output_whenever_sqlerror(r_cmd.cmd_id, 'IN');
         output_line(r_cmd.cmd_id, 'IN', REPLACE('ALTER SESSION SET CONTAINER=CDB$ROOT;','"',''''));
         output_line(r_cmd.cmd_id, 'IN', REPLACE('exec dc_indb_request.pdb_flashback(pdb_nm=>"'||dbm_utility_var.g_db_name||'", rp_name=>"'||dbm_utility_var.g_rp_name||'")','"',''''));
         output_line(r_cmd.cmd_id, 'IN', 'Prompt Database flashback to restore point request submitted successfully.');
         output_line(r_cmd.cmd_id, 'IN', 'Prompt This asynchronous process can take a while to complete, be patient.');
         fork_sqlplus('sqldba');
      ELSE
         insert_command(FALSE);
         raise_application_error(-20000, 'Unimplemented command: '||l_command);
      END IF;
      IF dbm_utility_var.g_silent THEN
         DELETE dbm_streams WHERE cmd_id = r_cmd.cmd_id AND type LIKE 'IN%' AND LOWER(text) LIKE 'prompt %';
      END IF;
      finally;
      RETURN r_cmd.cmd_id;
   EXCEPTION
      WHEN OTHERS THEN
         DELETE dbm_streams WHERE cmd_id = r_cmd.cmd_id AND type IN ('IN','IN2');
         IF SQLERRM != 'ORA-20000: ' THEN
            output_line(r_cmd.cmd_id, 'IN', 'prompt ERROR: '||REPLACE(SQLERRM,'ORA-20000: '));
         END IF;
         output_line(r_cmd.cmd_id, 'IN', 'define _rc="'||SQLCODE||'"');
         RETURN r_cmd.cmd_id;
   END;
--#begin public
   ---
   -- Execute a command
   ---
   PROCEDURE begin_command (
      p_command_line IN dbm_commands.command_line%TYPE
    , p_cmd_id IN dbm_commands.command_line%TYPE := NULL
   )
--#end public
   IS
      l_cmd_id dbm_commands.cmd_id%TYPE;
   BEGIN
      l_cmd_id := begin_command(p_command_line, p_cmd_id);
   END;
--#begin public
   ---
   -- Terminate a command
   ---
   PROCEDURE end_command (
      p_cmd_id IN dbm_commands.cmd_id%TYPE
    , p_exit_code IN dbm_commands.exit_code%TYPE
   )
--#end public
   IS
      CURSOR c_cmd (
         p_cmd_id IN dbm_commands.cmd_id%TYPE
      ) IS
         SELECT *
           FROM dbm_commands
          WHERE cmd_id = (
                   SELECT MAX(cmd_id)
                     FROM dbm_commands
                    WHERE (p_cmd_id IS NULL OR cmd_id = p_cmd_id)
                      AND end_date_time IS NULL
                )
         ;
      r_cmd dbm_commands%ROWTYPE;
      l_exit_code PLS_INTEGER := - p_exit_code;
   BEGIN
      -- Get given command or last one
      OPEN c_cmd(p_cmd_id);
      FETCH c_cmd INTO r_cmd;
      CLOSE c_cmd;
      IF r_cmd.cmd_id IS NOT NULL THEN
         -- Update exit code
         UPDATE dbm_commands
            SET exit_code = l_exit_code
              , end_date_time = SYSDATE
              , status = CASE WHEN l_exit_code = 0 THEN 'SUCCESS' ELSE 'ERROR' END
          WHERE cmd_id = r_cmd.cmd_id
            AND status = 'ONGOING'
         RETURNING exit_code, status, end_date_time INTO r_cmd.exit_code, r_cmd.status, r_cmd.end_date_time
         ;
         IF r_cmd.status = 'ERROR' THEN
            dbms_output.put_line('Last command #'||r_cmd.cmd_id||' ended on error '||CASE WHEN dbm_utility_var.g_os_name = 'Linux' THEN TO_CHAR(p_exit_code) ELSE SQLERRM(l_exit_code) END);
            dbms_output.put_line('Command line was: '||r_cmd.command_line);
            IF r_cmd.log_file_name IS NOT NULL THEN
               dbms_output.put_line('See error details in log file: '||r_cmd.log_file_name);
            END IF;
            UPDATE dbm_files
               SET run_status = 'ERROR'
             WHERE run_status = 'ONGOING'
            ;
            UPDATE dbm_versions
               SET last_op_status = 'ERROR'
                 , next_op_type = CASE WHEN last_op_type = 'UNINSTALL' THEN last_op_type ELSE 'ROLLBACK '||last_op_type END
             WHERE last_op_status = 'ONGOING'
            ;
            UPDATE dbm_applications
               SET ver_status = 'INVALID'
             WHERE ver_status = 'MIGRATING'
            ;
         END IF;
         -- Clean-up command input/output streams
--         DELETE dbm_streams
--          WHERE cmd_id = p_cmd_id
--         ;
      ELSIF p_exit_code != 0 THEN
         dbms_output.put_line('Last command ended on error '||SQLERRM(l_exit_code));
      END IF;
--      DELETE dbm_streams WHERE cmd_id = p_cmd_id;
      COMMIT;
   END;
--#begin public
   ---
   -- Define operating system
   ---
   PROCEDURE set_os (
      p_os_name IN VARCHAR2
   )
--#end public
   IS
   BEGIN
      assert(p_os_name IS NOT NULL, 'OS name is mandatory!');
      assert(p_os_name LIKE 'Windows%' OR INITCAP(p_os_name) = 'Linux', 'Only Windows and Linux OS are currently supported!');
      dbm_utility_var.g_os_name := p_os_name;
   END;
--#begin public
   ---
   -- Do nothing to instantiate package/session
   ---
   PROCEDURE noop
--#end public
   IS
      l_debug BOOLEAN := dbm_utility_var.g_debug;
   BEGIN
      dbm_utility_var.g_debug := l_debug;
   END;
   -- Initialize
   PROCEDURE init
   IS
   BEGIN
      -- Define all commands and their minimum number of characters when abbreviated
      dbm_utility_var.ga_cmd('best-guess-current') := 4;
      dbm_utility_var.ga_cmd('check-files') := 5;
      dbm_utility_var.ga_cmd('configure') := 4;
      dbm_utility_var.ga_cmd('create-restore-point') := 5;
      dbm_utility_var.ga_cmd('display') := 4;
      dbm_utility_var.ga_cmd('drop-restore-point') := 4;
      dbm_utility_var.ga_cmd('execute') := 4;
      dbm_utility_var.ga_cmd('flashback-database') := 5;
      dbm_utility_var.ga_cmd('guess-current') := 5;
      dbm_utility_var.ga_cmd('help') := 1;
      dbm_utility_var.ga_cmd('install') := 3;
      dbm_utility_var.ga_cmd('load-cache') := 4;
      dbm_utility_var.ga_cmd('make-inventory') := 4;
      dbm_utility_var.ga_cmd('migrate') := 3;
      dbm_utility_var.ga_cmd('noop') := 4;
      dbm_utility_var.ga_cmd('precheck') := 3;
      dbm_utility_var.ga_cmd('read-config') := 4;
      dbm_utility_var.ga_cmd('rollback') := 4;
      dbm_utility_var.ga_cmd('save-cache') := 4;
      dbm_utility_var.ga_cmd('scan-files') := 4;
      dbm_utility_var.ga_cmd('set-current') := 3;
      dbm_utility_var.ga_cmd('setup') := 5;
      dbm_utility_var.ga_cmd('show-current') := 4;
      dbm_utility_var.ga_cmd('startup') := 5;
      dbm_utility_var.ga_cmd('uninstall') := 5;
      dbm_utility_var.ga_cmd('upgrade') := 3;
      dbm_utility_var.ga_cmd('validate') := 3;
   END;
BEGIN
   init;
END dbm_utility_krn;
/