set define off
set define on
PROMPT Creating database objects...
@@dpp_objects.sql
@@DPP_UTILITY_LIC.pks
@@DPP_ITF_VAR.pks
@@DPP_INJ_VAR.pks
@@DPP_JOB_VAR.pks
@@DPP_ITF_KRN.pks
@@DPP_INJ_KRN.pks
@@DPP_JOB_MEM.pks
@@DPP_JOB_KRN.pks
@@DPP_ITF_KRN.pkb
@@DPP_INJ_KRN.pkb
@@DPP_JOB_MEM.pkb
@@DPP_JOB_KRN.pkb
SET DEFINE '&'
SET DEFINE OFF
--minimal mandatory configuration which is independent of the project
@@003_dpp_job_types.sql
@@004_dpp_options.sql
@@005_dpp_option_allowed_values.sql
--end minimal mandatory configuration which is independent of the project

-- Below installations that depend on the environment: DC, COP or AWS
SET DEFINE '&'
COLUMN :v_script NEW_VALUE SCRIPT NOPRINT
COLUMN :v_script2 NEW_VALUE SCRIPT2 NOPRINT
COLUMN :v_script3 NEW_VALUE SCRIPT3 NOPRINT
VARIABLE v_script VARCHAR2(255)
VARIABLE v_script2 VARCHAR2(255)
VARIABLE v_script3 VARCHAR2(255)
BEGIN
   :v_script := CASE WHEN UPPER('&&installation_env')='DC' 
                     THEN '@noop.sql'  
                     ELSE '@dc_dba_mgmt_lock_user.sql' /* AWS or COP */
                END;   
   :v_script2 := CASE WHEN UPPER('&&installation_env')='AWS' 
                     THEN '@dpp_toolkit.java'  
                     ELSE '@dpp_toolkit.java' /* DC or COP*/
                END;
   :v_script3 := CASE WHEN UPPER('&&installation_env')='COP' 
                     THEN '@dc_dba_mgmt_kill_sess_dedic_db.sql' /* COP only */
                     ELSE '@noop.sql'  
                END;
END;
/

-- inject bind variable value
select :v_script from sys.dual;

@&&SCRIPT

select :v_script2 from sys.dual;

@&&SCRIPT2

select :v_script3 from sys.dual;

@&&SCRIPT3
