/* file generated via excel utility */
PROMPT starting modification 3
Prompt Table DPP_JOB_TYPES
DECLARE
BEGIN
   dbms_output.put_line('Prompt Insert of row #4');
   BEGIN
      INSERT INTO dpp_job_types ( 
         JTE_CD, DESCR_FRA, DESCR_ENG, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
      ) VALUES ( 'RMOLD' , 'Suppression d''anciens fichiers' , 'Old files removal' , 
         SYSDATE , SYSDATE , USER , USER
      );
   EXCEPTION when others then
      dbms_output.put_line('Record already present!');
   END;   
END;
/
