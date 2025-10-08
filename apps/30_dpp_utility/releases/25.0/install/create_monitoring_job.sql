/**
* Create the job that monitors the DPP_Utility timeouts.
*
* v1.00; 2024-04-08; malmjea; initial version
*/

BEGIN

   -- Drop the job if it already exists.
   BEGIN
      dbms_scheduler.drop_job(
         job_name => 'DPP_MONITORING'
         , defer => FALSE
         , force => FALSE
      );
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   -- Create the job.
   dbms_scheduler.create_job(
        job_name => 'DPP_MONITORING'
      , job_type => 'PLSQL_BLOCK'
      , job_action => 'BEGIN

   -- Execute the DPP_Utility timeout monitoring.
   dpp_monitoring_krn.exec_monitoring();

END;'
      , number_of_arguments => 0
      , start_date => NULL
      , repeat_interval => 'FREQ=MINUTELY;INTERVAL=5'
      , end_date => NULL
      , enabled => TRUE
      , auto_drop => FALSE
      , comments => 'DPP_Utility timeout monitoring'
   );

END;
/
