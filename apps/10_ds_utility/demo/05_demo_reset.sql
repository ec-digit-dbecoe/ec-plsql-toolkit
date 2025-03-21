REM 
REM Data Set Utility Demo - Data Model Creation
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script to reset the demo prior to running it again
REM 

REM Reset masking data
DELETE ds_identifiers;
DELETE ds_masks;
DELETE ds_tokens;
COMMIT;

REM Drop all views (and ignore errors when not found)
exec BEGIN ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_MSK'); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_ORI'); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB'), p_view_suffix=>'_V'); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN'), p_view_suffix=>'_V'); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.drop_views(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP'), p_view_suffix=>'_V'); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.delete_data_set_def(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_GEN')); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.delete_data_set_def(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB')); EXCEPTION WHEN OTHERS THEN NULL; END;
exec BEGIN ds_utility_krn.delete_data_set_def(p_set_id=>ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_CAP')); EXCEPTION WHEN OTHERS THEN NULL; END;

REM Reset cache
exec ds_utility_var.reset_cache;
rem exec ds_utility_var.show_cache;

REM Re-create the data model
@@10_demo_data_model.sql