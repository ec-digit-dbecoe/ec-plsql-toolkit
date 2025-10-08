
/* file generated via excel utility */
PROMPT starting modification 4
Prompt Table DPP_OPTIONS

Prompt Insert of row #1
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'BLOCK' , 
   'This option blocks any import or export operation, when scheduling background jobs, it is not needed to kill the job to stop a export/import action. Just setting the option will skip any export/import.' , 
   'This option blocks any import or export operation, when scheduling background jobs, it is not needed to kill the job to stop a export/import action. Just setting the option will skip any export/import.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #2
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'CONSTRAINTS' , 
   'Drop all REFERENTIAL integrity constraints in the user''s schema BEFORE the import of objects via data pump.' , 
   'Drop all REFERENTIAL integrity constraints in the user''s schema BEFORE the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #3
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'EMAIL_RESULT' , 
   'Emails the final result to the designated email list. If the job ended in ERROR the log from DPP_JOB_LOGS will be appended to the mail' , 
   'Emails the final result to the designated email list. If the job ended in ERROR the log from DPP_JOB_LOGS will be appended to the mail' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #4
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'EXEC_POSTFIX' , 
   'After the data pump-job have imported database objects into the target schema. It is possible to execute custom SQL scripts.' , 
   'After the data pump-job have imported database objects into the target schema. It is possible to execute custom SQL scripts.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #5
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'EXEC_POSTFIX_START' , 
   'Applies only within a defined scope of EXEC_POSTFIX. If EXEC_POSTFIX is not defined this parameter is ignored.  This option provides for the possibility to skip custom postfix SQL script s that have a lower ordinal sequence number then the one specified with this option' , 
   'Applies only within a defined scope of EXEC_POSTFIX. If EXEC_POSTFIX is not defined this parameter is ignored.  This option provides for the possibility to skip custom postfix SQL script s that have a lower ordinal sequence number then the one specified with this option' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #6
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'EXEC_PREFIX' , 
   'Before the data pump-job executes an import of data, it is possible to execute custom SQL scripts. See section "executing custom scripts".' , 
   'Before the data pump-job executes an import of data, it is possible to execute custom SQL scripts. See section "executing custom scripts".' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #7
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'JOBS' , 
   'Optionally stop all scheduled jobs defined in the target schema, this happens before an import AND right after a data pump import. (See sequence steps).' , 
   'Optionally stop all scheduled jobs defined in the target schema, this happens before an import AND right after a data pump import. (See sequence steps).' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #8
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'LOCK_SCHEMA' , 
   'Locks the target schema and kills all connected sessions.' , 
   'Locks the target schema and kills all connected sessions.' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #9
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'METADATA_FILTER' , 
   'Filter used by export to exclude some tables, procedures...based on patterns' , 
   'Filter used by export to exclude some tables, procedures...based on patterns' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #10
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'METALINK_429846_1_CORRECTION' , 
   'This option is a workaround to  statistics, some versions of 10g freeze while datapump tries to import the element EXPORT/TABLE/STATISTICS/TABLE_STATISTICS' , 
   'This option is a workaround to  statistics, some versions of 10g freeze while datapump tries to import the element EXPORT/TABLE/STATISTICS/TABLE_STATISTICS' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #11
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'MV' , 
   'Drop all materialized views in the user''s schema BEFORE the import of objects via data pump' , 
   'Drop all materialized views in the user''s schema BEFORE the import of objects via data pump' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #12
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'PARALLEL' , 
   'The number of parallel threads used for exporting data to dump files.' , 
   'The number of parallel threads used for exporting data to dump files.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #13
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'PL_SQL_SOURCE' , 
   'Drop all local packages, functions, procedures and triggers in the target schema before the import of objects via data pump' , 
   'Drop all local packages, functions, procedures and triggers in the target schema before the import of objects via data pump' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #14
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'PRIVATE_DB_LINKS' , 
   'Drop all private database links in the target schema BEFORE the import of objects via data pump.' , 
   'Drop all private database links in the target schema BEFORE the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #15
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'RECOMPILE_PL_SQL' , 
   'After a data pump import, optionally recompile possible invalid packages/procedures/functions/triggers.' , 
   'After a data pump import, optionally recompile possible invalid packages/procedures/functions/triggers.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #16
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'RECYCLEBIN' , 
   'Purge the ORACLE RECYCLEBIN after dropping of database objects (specified by options or prefix SQL scripts)' , 
   'Purge the ORACLE RECYCLEBIN after dropping of database objects (specified by options or prefix SQL scripts)' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #17
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'REMAP_TABLESPACE' , 
   'Remaps an object exported in tablespace X to tablespace Y during import.' , 
   'Remaps an object exported in tablespace X to tablespace Y during import.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #18
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'SEGMENT_ATTRIBUTES' , 
   'Ignores the Tablespace +  Oracle storage clause of tables and indexes when importing via data pump.  This is for importing into tablespace NOT under automatic segment space management, ASSM. This mitigates the ORA-01658: unable to create INITIAL extent for segment in …… error.' , 
   'Ignores the Tablespace +  Oracle storage clause of tables and indexes when importing via data pump.  This is for importing into tablespace NOT under automatic segment space management, ASSM. This mitigates the ORA-01658: unable to create INITIAL extent for segment in …… error.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #19
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'SEQUENCES' , 
   'Drop all sequences in the target schema before the import of objects via data pump.' , 
   'Drop all sequences in the target schema before the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #20
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'SIMULATION_IMPORT' , 
   'Simulate the Executing of the import job (including specified options, like dropping objects before import etc.) without actually importing data via data pump.' , 
   'Simulate the Executing of the import job (including specified options, like dropping objects before import etc.) without actually importing data via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #21
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'STORAGE' , 
   'Ignores the Oracle storage clause of tables and indexes when importing via data pump.  This is for importing into tablespace NOT under automatic segment space management, ASSM. This mitigates the ORA-01658: unable to create INITIAL extent for segment in …… error.' , 
   'Ignores the Oracle storage clause of tables and indexes when importing via data pump.  This is for importing into tablespace NOT under automatic segment space management, ASSM. This mitigates the ORA-01658: unable to create INITIAL extent for segment in …… error.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #22
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'SYNONYMS' , 
   'Drop all synonyms in the users schema before the import of objects via data pump' , 
   'Drop all synonyms in the users schema before the import of objects via data pump' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #23
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'TABLES' , 
   'Drop all tables in the user''s schema BEFORE the import of objects via data pump.' , 
   'Drop all tables in the user''s schema BEFORE the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #24
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'TRIGGERS' , 
   'Drop all database triggers in the user''s schema BEFORE the import of objects via data pump' , 
   'Drop all database triggers in the user''s schema BEFORE the import of objects via data pump' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #25
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'TYPES' , 
   'Drop all TYPES in the user''s schema before the import of objects via data pump.' , 
   'Drop all TYPES in the user''s schema before the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #26
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'VIEWS' , 
   'Drop all views in the target schema before the import of objects via data pump.' , 
   'Drop all views in the target schema before the import of objects via data pump.' , 
   SYSDATE , SYSDATE , USER , USER
);

Prompt Insert of row #27
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'NETWORK_LINK' , 
   'Name of a database link to be used for direct export/import' , 
   'Name of a database link to be used for direct export/import' , SYSDATE , 
   SYSDATE , USER , USER
);

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

Prompt Insert of row #30
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'DATA_FILTER' , 
   'Filter to exclude some data of some table)' , 
   'Filtre d''exclusion de certaines données de certaines tables' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #31
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'COMPRESSION' , 
   'Type of compression' , 
   'Type de compression' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #32
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'COMPRESSION_ALGORITHM' , 
   'Compression algorithm' , 
   'Algorithme de compression' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #33
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'ENCRYPTION' , 
   'encryption method' , 
   'méthode d''encryption' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #34
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'ENCRYPTION_MODE' , 
   'encryption mode' , 
   'mode d''encryption' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #35
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'ENCRYPTION_PASSWORD' , 
   'encryption password' , 
   'mot de passe d''encryption' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #36
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'LOGTIME' , 
   'type of log timestamps' , 
   'type de timestamps dans les logs' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #37
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'DATA_REMAP' , 
   'data remap' , 
   'modification de donnée' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #38
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'S3_BUCKET' , 
   'S3 bucket name' , 
   'nom du bucket S3' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #39
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'S3_PREFIX' , 
   'S3 prefix name' , 
   'préfixe S3' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #40
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'S3_COMPR_LEVEL' , 
   'S3 bucket compression level' , 
   'niveau de compression dans le bucket S3' , SYSDATE , 
   SYSDATE , USER , USER
);

Prompt Insert of row #41
INSERT INTO dpp_options ( 
   OTN_NAME, DESCR_ENG, DESCR_FRA, DATE_CREAT, DATE_MODIF, USER_CREAT, USER_MODIF
) VALUES ( 'METRICS' , 
   'additional information in the logs' , 
   'informations additionnelles dans les logs' , SYSDATE , 
   SYSDATE , USER , USER
);
