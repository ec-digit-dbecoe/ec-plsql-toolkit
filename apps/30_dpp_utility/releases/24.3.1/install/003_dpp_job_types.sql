
/* file generated via excel utility */
PROMPT starting modification 3
Prompt Table DPP_JOB_TYPES
DECLARE
BEGIN
   dbms_output.put_line('Prompt Insert of row #1');
   BEGIN
      INSERT INTO dpp_job_types ( 
         JTE_CD, DESCR_FRA, DESCR_ENG, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
      ) VALUES ( 'IMPJB' , 'Job d''importation' , 'Import job' , SYSDATE , SYSDATE , 
         USER , USER
      );
   EXCEPTION when others then
      dbms_output.put_line('Record already present!');
   END;
   dbms_output.put_line('Prompt Insert of row #2');
   BEGIN
      INSERT INTO dpp_job_types ( 
         JTE_CD, DESCR_FRA, DESCR_ENG, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
      ) VALUES ( 'EXPJB' , 'Job d''exportation' , 'Export job' , SYSDATE , SYSDATE , 
         USER , USER
      );
   EXCEPTION when others then
      dbms_output.put_line('Record already present!');
   END;
   dbms_output.put_line('Prompt Insert of row #3');
   BEGIN
      INSERT INTO dpp_job_types ( 
         JTE_CD, DESCR_FRA, DESCR_ENG, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
      ) VALUES ( 'TRFJB' , 'Job de transfert de fichiers' , 'File transfert job' , 
         SYSDATE , SYSDATE , USER , USER
      );
   EXCEPTION when others then
      dbms_output.put_line('Record already present!');
   END;   
END;
/
