DECLARE
   CURSOR c_col (
      p_pattern VARCHAR2
   )
   IS
      SELECT 'ALTER TABLE '||LOWER(col.table_name)||' MODIFY '||LOWER(col.column_name)||' '||col.data_type||'('||col.data_length||' CHAR)' ddl_statement
        FROM user_tab_columns col
       INNER JOIN user_tables tab
          ON tab.table_name = col.table_name
       WHERE REGEXP_LIKE(col.table_name, p_pattern)
         AND col.data_type LIKE '%CHAR%'
         AND col.char_used = 'B'
       ORDER BY col.table_name
      ;
   l_count PLS_INTEGER := 0;
BEGIN
   dbms_output.put_line('Changing length unit of char columns from BYTE to CHAR...');
   FOR r_col IN c_col('^DBM_') LOOP
      l_count := l_count + 1;
      dbms_output.put_line(r_col.ddl_statement);
      EXECUTE IMMEDIATE r_col.ddl_statement;
   END LOOP;
   dbms_output.put_line('Done: '||l_count||' column'||CASE WHEN l_count > 1 THEN 's' END||' altered');
END;
/