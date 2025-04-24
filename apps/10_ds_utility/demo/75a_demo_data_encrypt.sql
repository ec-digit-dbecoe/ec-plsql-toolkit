REM 
REM Data Set Utility Demo - Transparent Data Encryption
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM Script based on APIs only (no use of DEGPL)
REM 

set serveroutput on size 999999

REM
REM Create a completely empty data model
REM (So delete reference data)
REM
@@10_demo_data_model
DELETE demo_countries;
DELETE demo_credit_card_types;
DELETE demo_org_entity_types;
COMMIT;
@@18_demo_src_tables_stats

REM
REM Launch a sensitive data discovery
REM This defines default encryption for discovered sensitive data types
REM Encryption of PKs is automatically propagated to FKs after discovery
REM 
delete ds_masks;
commit;
exec ds_utility_krn.discover_sensitive_data(p_rows_sample_size=>200, p_full_schema=>TRUE, p_table_name=>'DEMO%', p_commit=>TRUE);
select table_name, column_name, tde_type, tde_params, remarks from ds_masks where tde_params IS NOT NULL order by 1, 2;

REM Request encryption of some additional columns on top of those detected as sensitive
REM Encryption of PKs is automatically propagated to FKs when TDE parameteres are changed using DEPGL
REM When using APIs only, propagate_encryption() must be invoked after any chante to TDE parameters

BEGIN
   ds_utility_krn.insert_mask(p_table_name=>'DEMO_PERSONS', p_column_name=>'PER_ID', p_tde_type=>'SQL', p_tde_params=>'ds_crypto_krn.encrypt_integer(p_value=>per_id,p_min_value=>1,p_max_value=>99)', p_locked_flag=>'Y');
   ds_utility_krn.propagate_encryption;
   COMMIT;
END;
/
select table_name, column_name, tde_type, tde_params from ds_masks where tde_params IS NOT NULL order by 1, 2;

REM
REM Check encrypted columns visually using a Graphviz diagram
REM

select * from table(ds_utility_ext.graph_data_set(
    p_set_id=>NULL -- show only 
  , p_table_name=>'DEMO%' -- table filter
  , p_full_schema=>'Y' -- show whole schema?
  , p_show_legend=>'N' -- show legend?
  , p_show_aliases=>'Y' -- show table aliases?
  , p_show_config=>'Y' -- show configuration?
  , p_show_stats=>'Y' -- show statistics?
  , p_show_conf_columns=>'Y' -- show configured columns (i.e., masked or generated)?
  , p_show_cons_columns=>'N' -- show constrainted columns (i.e., part of a PK, UK or FK)?
  , p_show_ind_columns=>'N' -- show indexed columns (i.e. part of an index)?
  , p_hide_dis_columns=>'N' -- hide disabled or deleted masked columns?
  , p_show_all_columns=>'Y' -- show all columns (overwrite conf/cons/ind)?
  , p_show_column_keys=>'Y' -- show column keys (Primary, Unique, Foreign, Index)?
  , p_show_column_types=>'Y' -- show column types?
  , p_show_constraints=>'N' -- show contraints and their columns?
  , p_show_indexes=>'N' -- show indexes and their columns?
  , p_show_triggers=>'N' -- show triggers?
  , p_show_all_props=>'N' -- show all properties in tooltips? by default, only those not on diag
  , p_show_prop_regexp=>'' -- show properties matching given regexp in tooltip, NULL=show all
  , p_hide_prop_regexp=>'' -- hide properties matching given regexp in tooltip, NULL=hide none
  , p_graph_att=>'' -- graph attributes e.g., splines=ortho
  , p_node_att=>'' -- node attributes e.g., style=filled
  , p_edge_att=>'' -- edge attributes e.g., arrowsize=2
  , p_main_att=>'' -- main subgraph attributes e.g., label=""
  , p_legend_att=>'' -- legend subgraph attributes e.g., label=""
  , p_set_type=>'TDE' -- data set type
));

REM
REM Create views and instead-of triggers
REM
exec ds_utility_krn.create_views(p_view_suffix=>'_TDE',p_set_type=>'TDE', p_table_name=>'DEMO%', p_include_rowid=>TRUE);
exec ds_utility_krn.create_tde_triggers(p_view_suffix=>'_TDE');
exec ds_crypto_krn.set_encryption_key('This is a private key');

REM
REM Create encrypted data sample through views
REM
@@75z_demo_data_sample
@@18_demo_src_tables_stats
COMMIT;

REM
REM Check encrypted/decrypted values for some table(s)
REM CLEAR records (from views) show plaintext
REM CRYPT records (from tables) show cyphertext
REM
SELECT 'CLEAR' type, tde.* FROM demo_persons_tde tde
UNION ALL
SELECT 'CRYPT' type, rowid, tab.* FROM demo_persons tab
ORDER BY 2, 1;

SELECT 'CLEAR' type, tde.* FROM demo_per_transactions_tde tde
UNION ALL
SELECT 'CRYPT' type, rowid, tab.* FROM demo_per_transactions tab
ORDER BY 2, 1;

SELECT 'CLEAR' type, tde.* FROM demo_orders_tde tde
UNION ALL
SELECT 'CRYPT' type, rowid, tab.* FROM demo_orders tab
ORDER BY 2, 1;

REM
REM Cleanup
REM
exec ds_utility_krn.drop_tde_triggers(p_view_suffix=>'_TDE');
exec ds_utility_krn.drop_views(p_view_suffix=>'_TDE', p_set_type=>'TDE', p_table_name=>'DEMO%');
