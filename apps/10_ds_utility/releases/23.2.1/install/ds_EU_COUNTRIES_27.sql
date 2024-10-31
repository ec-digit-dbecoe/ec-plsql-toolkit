REM Source: https://www.iban.com/country-codes
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#CODE_A2	CODE_A3	NAME	POPULATION
C(2)	C(3)	C(58)	N(8)
AT	AUT	Austria	9104772
BE	BEL	Belgium	11754004
BG	BGR	Bulgaria	6447710
HR	HRV	Croatia	3850894
CY	CYP	Cyprus	920701
CZ	CZE	Czechia	10827529
DK	DNK	Denmark	5932654
EE	EST	Estonia	1365884
FI	FIN	Finland	5563970
FR	FRA	France	68070697
DE	DEU	Germany	84358845
GR	GRC	Greece	10394055
HU	HUN	Hungary	9597085
IE	IRL	Ireland	5194336
IT	ITA	Italy	58850717
LV	LVA	Latvia	1883008
LT	LTU	Lithuania	2857279
LU	LUX	Luxembourg	660809
MT	MLT	Malta	542051
NL	NLD	Netherlands (the)	17811291
PL	POL	Poland	36753736
PT	PRT	Portugal	10467366
RO	ROU	Romania	19051562
SK	SVK	Slovakia	5428792
SI	SVN	Slovenia	2116792
ES	ESP	Spain	48059777
SE	SWE	Sweden	10521556#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'EU_COUNTRIES_27', p_set_type=>'CSV', p_params=>my_clob);
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
