set termout on
set define on
set scan on
set feedback off
set verify off
whenever sqlerror exit
PROMPT Configuring application '&&pat_alias'...
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','TAB TS',UPPER('&&tab_ts'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','IDX TS',UPPER('&&idx_ts'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','LOB TS',UPPER('&&lob_ts'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','EMAIL SERVER','localhost');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','EMAIL SENDER','AUTOMATED DB QUALITY CHECK <automated-notifications@nomail.ec.europa.eu>');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','EMAIL RECIPIENTS','&&email_to');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','EMAIL CC','&&email_cc');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','PARAMETER','EMAIL BCC','&&email_bcc');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','AUDIT COLUMN','INSERTED BY',UPPER('&&inserted_by'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','AUDIT COLUMN','INSERTED ON',UPPER('&&inserted_on'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','AUDIT COLUMN','UPDATED BY',UPPER('&&updated_by'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','AUDIT COLUMN','UPDATED ON',UPPER('&&updated_on'));
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGER TYPE','BEFORE EACH ROW','BR');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGER TYPE','AFTER EACH ROW','AR');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGER TYPE','BEFORE STATEMENT','BS');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGER TYPE','AFTER STATEMENT','AS');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGER TYPE','INSTEAD OF','IO');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','INSERT','I');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','UPDATE','U');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','DELETE','D');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','INSERT OR UPDATE','IU');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','INSERT OR DELETE','ID');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','UPDATE OR DELETE','UD');
exec qc_utility_krn.insert_dictionary_entry('&&pat_alias','TRIGGERING EVENT','INSERT OR UPDATE OR DELETE','IUD');

DECLARE
   TYPE my_varchar2_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   t_var my_varchar2_table;
   r_pat qc_patterns%ROWTYPE;
BEGIN
   -- Standard object types
   t_var(t_var.COUNT+1) := 'CHAIN';
   t_var(t_var.COUNT+1) := 'CLUSTERS';
   t_var(t_var.COUNT+1) := 'CONSUMER GROUP';
   t_var(t_var.COUNT+1) := 'DATABASE LINKS';
   t_var(t_var.COUNT+1) := 'DESTINATION';
   t_var(t_var.COUNT+1) := 'DIMENSIONS';
   t_var(t_var.COUNT+1) := 'DIRECTORY';
   t_var(t_var.COUNT+1) := 'EDITION';
   t_var(t_var.COUNT+1) := 'EVALUATION CONTEXT';
   t_var(t_var.COUNT+1) := 'FUNCTION';
   t_var(t_var.COUNT+1) := 'INDEXTYPE';
--   t_var(t_var.COUNT+1) := 'JAVA CLASS';
--   t_var(t_var.COUNT+1) := 'JAVA DATA';
--   t_var(t_var.COUNT+1) := 'JAVA RESOURCE';
--   t_var(t_var.COUNT+1) := 'JAVA SOURCE';
   t_var(t_var.COUNT+1) := 'JOB';
   t_var(t_var.COUNT+1) := 'JOB CLASS';
   t_var(t_var.COUNT+1) := 'LOB';
   t_var(t_var.COUNT+1) := 'MATERIALIZED VIEW LOGS';
   t_var(t_var.COUNT+1) := 'MATERIALIZED VIEWS';
   t_var(t_var.COUNT+1) := 'OPERATOR';
   t_var(t_var.COUNT+1) := 'PACKAGE';   
   t_var(t_var.COUNT+1) := 'PACKAGE BODY';
   t_var(t_var.COUNT+1) := 'PROCEDURE';
   t_var(t_var.COUNT+1) := 'PROGRAM';
   t_var(t_var.COUNT+1) := 'ROLE';
   t_var(t_var.COUNT+1) := 'QUEUE';
   t_var(t_var.COUNT+1) := 'SCHEDULER GROUP';
   t_var(t_var.COUNT+1) := 'SEQUENCE';
   t_var(t_var.COUNT+1) := 'SYNONYM';
   t_var(t_var.COUNT+1) := 'TABLE';
   t_var(t_var.COUNT+1) := 'TABLE PARTITION';
   t_var(t_var.COUNT+1) := 'TRIGGER';
   t_var(t_var.COUNT+1) := 'TYPE';
   t_var(t_var.COUNT+1) := 'TYPE BODY';  
   t_var(t_var.COUNT+1) := 'VIEW';
   t_var(t_var.COUNT+1) := 'WINDOW';
   t_var(t_var.COUNT+1) := 'XML SCHEMA';
   -- Ad-hoc object types
   t_var(t_var.COUNT+1) := 'INDEX: PRIMARY KEY';
   t_var(t_var.COUNT+1) := 'INDEX: UNIQUE KEY';
   t_var(t_var.COUNT+1) := 'INDEX: FOREIGN KEY';
   t_var(t_var.COUNT+1) := 'INDEX: UNIQUE';
   t_var(t_var.COUNT+1) := 'INDEX: NON UNIQUE';
   t_var(t_var.COUNT+1) := 'CONSTRAINT: PRIMARY KEY';
   t_var(t_var.COUNT+1) := 'CONSTRAINT: UNIQUE KEY';
   t_var(t_var.COUNT+1) := 'CONSTRAINT: FOREIGN KEY';
   t_var(t_var.COUNT+1) := 'CONSTRAINT: CHECK';
   t_var(t_var.COUNT+1) := 'CONSTRAINT: NOT NULL';
   t_var(t_var.COUNT+1) := 'TABLE ALIAS';
   t_var(t_var.COUNT+1) := 'TABLE COLUMN';
   t_var(t_var.COUNT+1) := 'TABLE COMMENT';
   t_var(t_var.COUNT+1) := 'TABLE COLUMN COMMENT';
   t_var(t_var.COUNT+1) := 'MVIEW COMMENT';
   t_var(t_var.COUNT+1) := 'MVIEW ALIAS';
   t_var(t_var.COUNT+1) := 'ARGUMENT';
   t_var(t_var.COUNT+1) := 'QUALITY CHECK';
   t_var(t_var.COUNT+1) := 'QC005';
   t_var(t_var.COUNT+1) := 'QC014';
   t_var(t_var.COUNT+1) := 'QC015';
   t_var(t_var.COUNT+1) := 'QC016';
   t_var(t_var.COUNT+1) := 'QC019';
   r_pat.msg_type := 'E';
   r_pat.app_alias := '&&pat_alias';
   FOR i IN 1..t_var.COUNT LOOP
      r_pat.object_type := t_var(i);
      INSERT INTO qc_patterns VALUES r_pat;
   END LOOP;
END;
/

UPDATE qc_patterns
   SET exclude_pattern = '_VAR$'
 WHERE object_type = 'QC014'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET exclude_pattern = '.*'
 WHERE object_type = 'QC019' -- exclude QC019 if Production environment
   AND app_alias = '&&pat_alias'
   AND SUBSTR(sys_context('USERENV','DB_NAME'), length(sys_context('USERENV','DB_NAME'))) = 'P'
;

SELECT 'Be aware that QC019 is excluded from quality checks run as it is Production Environment'
  FROM dual
 WHERE SUBSTR(sys_context('USERENV','DB_NAME'), length(sys_context('USERENV','DB_NAME'))) = 'P'
;

UPDATE qc_patterns
   SET exclude_pattern = '(_MV$)|(_JN$)'
 WHERE object_type = 'TABLE' -- exclude materialized views and journal tables
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET include_pattern = '^{app alias}'
 WHERE object_type IN ('TABLE','PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','VIEW','SEQUENCE','MATERIALIZED VIEW','TRIGGER','TYPE','TYPE BODY')
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}([A-Z]|[0-9]|_)+(S|{any plural word})$'
 WHERE object_type IN ('TABLE')
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}([A-Z]|[0-9]|_)+$'
 WHERE object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION')
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}([A-Z]|[0-9]|_)+_V$'
 WHERE object_type = 'VIEW'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{any table alias}_SEQ$'
 WHERE object_type = 'SEQUENCE'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}([A-Z]|[0-9]|_)+_MV$'
 WHERE object_type = 'MATERIALIZED VIEW'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_{triggering event}{trigger type}_TRG$'
     , fix_pattern='{app alias_}{table alias}_{triggering event}{trigger type}_TRG'
 WHERE object_type = 'TRIGGER'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{ind cons}(_I)?$'
     , exclude_pattern='^SYS_.+$'
     , fix_pattern='{ind cons}_I'
 WHERE object_type IN ('INDEX: PRIMARY KEY','INDEX: UNIQUE KEY','INDEX: FOREIGN KEY')
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_(UK[0-9]*|PK)(_I)?$'
     , exclude_pattern='^SYS_.+$'
     , fix_pattern='{app alias_}{table alias}_UK{seq nr}_I'
 WHERE object_type = 'INDEX: UNIQUE'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}([A-Z]|[0-9]|_)+_I[0-9]*$'
      , exclude_pattern='^SYS_.+$'
     , fix_pattern='{app alias_}{table alias}_I{seq nr}'
 WHERE object_type = 'INDEX: NON UNIQUE'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_PK$'
     , exclude_pattern='^SYS_.+$'
     , fix_pattern='{app alias_}{table alias}_PK'
 WHERE object_type = 'CONSTRAINT: PRIMARY KEY'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_UK[0-9]*$'
     , exclude_pattern='^SYS_.+$'
     , fix_pattern='{app alias_}{table alias}_UK{seq nr}'
 WHERE object_type = 'CONSTRAINT: UNIQUE KEY'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_{parent alias}_([A-Z]|[0-9]|_)*FK[0-9]*(_|[A-Z]|[0-9])*$'
     , fix_pattern='{app alias_}{table alias}_{parent alias}{_cons role}_FK'
 WHERE object_type = 'CONSTRAINT: FOREIGN KEY'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_([A-Z]|[0-9]|_)*CK[0-9]*$'
     , exclude_pattern='^SYS_.+$'
     , fix_pattern='{app alias_}{table alias}_CK{seq nr}'
 WHERE object_type = 'CONSTRAINT: CHECK'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^{app alias_}{table alias}_{tab col alias}_NN$'
     , fix_pattern='{app alias_}{table alias_}{tab col alias_}NN'
 WHERE object_type = 'CONSTRAINT: NOT NULL'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^P_'
 WHERE object_type = 'ARGUMENT'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^[A-Z]([A-Z]|[0-9]){1,3}$'
 WHERE object_type = 'TABLE ALIAS'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET check_pattern='^QC[0-9]{3}$'
     , include_pattern='^QC'
     , exclude_pattern='^QC019$'
 WHERE object_type = 'QUALITY CHECK'
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET exclude_pattern=exclude_pattern ||'|^DR$'
 WHERE object_type IN ('INDEX: PRIMARY KEY','INDEX: UNIQUE KEY','INDEX: FOREIGN KEY', 'INDEX: UNIQUE', 'INDEX: NON UNIQUE')
   AND app_alias = '&&pat_alias'
;

UPDATE qc_patterns
   SET anti_pattern='^{table alias}'
 WHERE object_type='TABLE COLUMN'
   AND app_alias = '&&pat_alias'
;

exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL CONSTANT OBJECT', '^gko_.*$', 'gko_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL CONSTANT RECORD', '^gkr_.*$', 'gkr_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL CONSTANT SCALAR', '^gk_.*$', 'gk_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL CONSTANT TABLE', '^gk[ta]_.*$', 'gkt_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL CURSOR', '^gv?c_.*$', 'gc_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL EXCEPTION', '^gv?e_.*$', 'ge_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL OBJECT', '^gv?o_.*$', 'go_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL RECORD', '^gv?r_.*$', 'gr_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL RECORD TYPE', '^gr_.*_type$', 'gr_{name}_type', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL SCALAR', '^gv?_.*$', 'g_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL TABLE', '^gv?[ta]_.*$', 'gt_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: GLOBAL TABLE TYPE', '^g[ta]_.*_type$', 'gt_{name}_type', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN OBJECT PARAMETER', '^pi?o_.*$', 'po_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN OUT OBJECT PARAMETER', '^pioo_.*$', 'pioo_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN OUT RECORD PARAMETER', '^pior_.*$', 'pior_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN OUT SCALAR PARAMETER', '^pio_.*$', 'pio_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN OUT TABLE PARAMETER', '^pio[ta]_.*$', 'piot_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN RECORD PARAMETER', '^pi?r_.*$', 'pr_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN SCALAR PARAMETER', '^pi?_.*$', 'p_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: IN TABLE PARAMETER', '^pi?[ta]_.*$', 'pt_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL CONSTANT OBJECT', '^l?ko_.*$', 'ko_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL CONSTANT RECORD', '^l?kr_.*$', 'kr_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL CONSTANT SCALAR', '^l?k_.*$', 'k_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL CONSTANT TABLE', '^l?k[ta]_.*$', 'kt_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL CURSOR', '^l?v?c_.*$', 'c_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL EXCEPTION', '^l?v?e_.*$', 'e_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL OBJECT', '^l?v?o_.*$', 'o_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL RECORD', '^l?v?r_.*$', 'r_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL RECORD TYPE', '^l?r_.*_type$', 'r_{name}_type', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL SCALAR', '^l?v?_.*$', 'l_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL TABLE', '^l?v?[ta]_.*$', 't_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LOCAL TABLE TYPE', '^l?[ta]_.*_type$', 't_{name}_type', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: OUT OBJECT PARAMETER', '^poo_.*$', 'poo_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: OUT RECORD PARAMETER', '^por_.*$', 'por_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: OUT SCALAR PARAMETER', '^po_.*$', 'po_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: OUT TABLE PARAMETER', '^po[ta]_.*$', 'pot_{name}', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: PROCEDURE', '', '', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: FUNCTION', '', '', 'E');
exec qc_utility_krn.insert_pattern('&&pat_alias','IDENTIFIER: LABEL', '', '', 'E');

COMMIT;
PROMPT Application '&&pat_alias' configured successfully!