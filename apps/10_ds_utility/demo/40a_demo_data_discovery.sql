REM 
REM Data Set Utility Demo - Sensitive Data Discovery
REM All rights reserved (C)opyright 2024 by Philippe Debois
REM 

CLEAR SCREEN
PAUSE Discover sensitive data?
exec ds_utility_krn.set_message_filter('EWI');
truncate table ds_identifiers;
truncate table ds_tokens;
truncate table ds_masks;
exec ds_utility_krn.discover_sensitive_data(p_rows_sample_size=>200, p_full_schema=>TRUE, p_table_name=>'DEMO%', p_commit=>TRUE);

PAUSE Check results?
CLEAR SCREEN
select * from table(ds_utility_ext.graph_data_set(p_set_id=>NULL, p_table_name=>'DEMO%', p_full_schema=>'Y', p_show_legend=>'N', p_show_config=>'Y', p_show_stats=>'Y', p_show_conf_columns=>'Y'));
