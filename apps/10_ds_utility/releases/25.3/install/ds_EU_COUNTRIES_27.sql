REM Source: Generated with ChatGPT
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#CODE_A2	CODE_A3	NAME	POPULATION
C(2)	C(3)	C(20)	N(8)
AT	AUT	Austria	8932487
BE	BEL	Belgium	11492641
BG	BGR	Bulgaria	6896309
HR	HRV	Croatia	4057995
CY	CYP	Cyprus	1207359
CZ	CZE	Czech Republic	10708981
DK	DNK	Denmark	5834231
EE	EST	Estonia	1328976
FI	FIN	Finland	5546334
FR	FRA	France	67081000
DE	DEU	Germany	83190556
GR	GRC	Greece	10423054
HU	HUN	Hungary	9660351
IE	IRL	Ireland	4904226
IT	ITA	Italy	60367477
LV	LVA	Latvia	1886198
LT	LTU	Lithuania	2722289
LU	LUX	Luxembourg	634730
MT	MLT	Malta	514564
NL	NLD	Netherlands	17474346
PL	POL	Poland	38313133
PT	PRT	Portugal	10295583
RO	ROU	Romania	19237691
SK	SVK	Slovakia	5452138
SI	SVN	Slovenia	2078654
ES	ESP	Spain	47450795
SE	SWE	Sweden	10379295#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'EU_COUNTRIES_27', p_set_type=>'CSV', p_params=>my_clob, p_system_flag=>'Y');
   UPDATE ds_data_sets
      SET col_names_row = 1  -- column names at row 1
        , col_types_row = 2  -- column types at row 2
        , col_sep_char = CHR(9) -- column separator is TAB
    WHERE set_id = l_set_id
   ;
   COMMIT;
   dbms_lob.freetemporary(my_clob);
END;
/
