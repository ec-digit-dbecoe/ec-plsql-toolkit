declare
   v_users varchar2(1000) := UPPER('&&pusers');
   v_sql varchar2(2000) := '';
BEGIN
   for r in (
      select regexp_substr(v_users,'[^,]+', 1, level) users from dual
      connect by regexp_substr(v_users, '[^,]+', 1, level) is not null   
    ) loop
      v_sql := 'GRANT SELECT on dpp_schemas TO '||r.users;   
      dbms_output.put_line(v_sql);
      execute immediate v_sql;
    end loop;
END;
/

declare
   v_users varchar2(1000) := UPPER('&&pusers');
   v_sql varchar2(2000) := '';
BEGIN
   for r in (
      select regexp_substr(v_users,'[^,]+', 1, level) users from dual
      connect by regexp_substr(v_users, '[^,]+', 1, level) is not null   
    ) loop
      v_sql := 'GRANT SELECT on DPP_SCHEMA_RELATIONS TO '||r.users;   
      dbms_output.put_line(v_sql);
      execute immediate v_sql;
    end loop;
END;
/

declare
   v_users varchar2(1000) := UPPER('&&pusers');
   v_sql varchar2(2000) := '';
BEGIN

   for r in (
      select regexp_substr(v_users,'[^,]+', 1, level) users from dual
      connect by regexp_substr(v_users, '[^,]+', 1, level) is not null   
    ) loop
      v_sql := 'GRANT EXECUTE on dpp_job_krn TO '||r.users;   
      dbms_output.put_line(v_sql);
      execute immediate v_sql;
    end loop;
END;
/