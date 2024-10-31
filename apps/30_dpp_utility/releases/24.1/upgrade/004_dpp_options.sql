PROMPT starting modification 4
Prompt Table DPP_OPTIONS

Prompt Insert of row #28
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'TIMEOUT_MONITORING' , 
   'Whether a timeout monitoring must be activated for this job' , 
   'Indique si un monitoring de timeout doit être activé pour ce job' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #29
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'TIMEOUT_DELAY' , 
   'Maximum number of minutes after the start of the job to consider it is in timeout' , 
   'Nombre maximum de minutes depuis le début du job pour le considérer en timeout' , SYSDATE , 
   SYSDATE , USER , USER
);
