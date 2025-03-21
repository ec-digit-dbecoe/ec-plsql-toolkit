REM Sources:
REM - https://en.wikipedia.org/wiki/ISO_3166-2, 2024, licenced under the Creative Commons Attribution-ShareAlike 4.0 License.
REM - https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3, 2024, licenced under the Creative Commons Attribution-ShareAlike 4.0 License.
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#CTRY_CODE_A2	CTRY_CODE_A3	CTRY_NAME_UTF8	CTRY_NAME_ASCII
C(2)	C(3)	C(58)	C(58)
AF	AFG	Afghanistan	Afghanistan
AL	ALB	Albania	Albania
DZ	DZA	Algeria	Algeria
AS	ASM	American Samoa	American Samoa
AD	AND	Andorra	Andorra
AO	AGO	Angola	Angola
AI	AIA	Anguilla	Anguilla
AQ	ATA	Antarctica	Antarctica
AG	ATG	Antigua and Barbuda	Antigua and Barbuda
AR	ARG	Argentina	Argentina
AM	ARM	Armenia	Armenia
AW	ABW	Aruba	Aruba
AU	AUS	Australia	Australia
AT	AUT	Austria	Austria
AZ	AZE	Azerbaijan	Azerbaijan
BS	BHS	Bahamas (the)	Bahamas (the)
BH	BHR	Bahrain	Bahrain
BD	BGD	Bangladesh	Bangladesh
BB	BRB	Barbados	Barbados
BY	BLR	Belarus	Belarus
BE	BEL	Belgium	Belgium
BZ	BLZ	Belize	Belize
BJ	BEN	Benin	Benin
BM	BMU	Bermuda	Bermuda
AX	ALA	Åland Islands	Åland Islands
BT	BTN	Bhutan	Bhutan
BO	BOL	Bolivia (Plurinational State of)	Bolivia (Plurinational State of)
BQ	BES	Bonaire, Sint Eustatius and Saba	Bonaire, Sint Eustatius and Saba
BA	BIH	Bosnia and Herzegovina	Bosnia and Herzegovina
BW	BWA	Botswana	Botswana
BV	BVT	Bouvet Island	Bouvet Island
BR	BRA	Brazil	Brazil
IO	IOT	British Indian Ocean Territory (the)	British Indian Ocean Territory (the)
BN	BRN	Brunei Darussalam	Brunei Darussalam
BG	BGR	Bulgaria	Bulgaria
BF	BFA	Burkina Faso	Burkina Faso
BI	BDI	Burundi	Burundi
CV	CPV	Cabo Verde	Cabo Verde
KH	KHM	Cambodia	Cambodia
CM	CMR	Cameroon	Cameroon
CA	CAN	Canada	Canada
KY	CYM	Cayman Islands (the)	Cayman Islands (the)
CF	CAF	Central African Republic (the)	Central African Republic (the)
TD	TCD	Chad	Chad
CL	CHL	Chile	Chile
CN	CHN	China	China
CX	CXR	Christmas Island	Christmas Island
CC	CCK	Cocos (Keeling) Islands (the)	Cocos (Keeling) Islands (the)
CO	COL	Colombia	Colombia
KM	COM	Comoros (the)	Comoros (the)
CD	COD	Congo (the Democratic Republic of the)	Congo (the Democratic Republic of the)
CG	COG	Congo (the)	Congo (the)
CK	COK	Cook Islands (the)	Cook Islands (the)
CR	CRI	Costa Rica	Costa Rica
HR	HRV	Croatia	Croatia
CU	CUB	Cuba	Cuba
CW	CUW	Curaçao	Curacao
CY	CYP	Cyprus	Cyprus
CZ	CZE	Czechia	Czechia
CI	CIV	Côte d'Ivoire	Cote d'Ivoire
DK	DNK	Denmark	Denmark
DJ	DJI	Djibouti	Djibouti
DM	DMA	Dominica	Dominica
DO	DOM	Dominican Republic (the)	Dominican Republic (the)
EC	ECU	Ecuador	Ecuador
EG	EGY	Egypt	Egypt
SV	SLV	El Salvador	El Salvador
GQ	GNQ	Equatorial Guinea	Equatorial Guinea
ER	ERI	Eritrea	Eritrea
EE	EST	Estonia	Estonia
SZ	SWZ	Eswatini	Eswatini
ET	ETH	Ethiopia	Ethiopia
FK	FLK	Falkland Islands (the) [Malvinas]	Falkland Islands (the) [Malvinas]
FO	FRO	Faroe Islands (the)	Faroe Islands (the)
FJ	FJI	Fiji	Fiji
FI	FIN	Finland	Finland
FR	FRA	France	France
GF	GUF	French Guiana	French Guiana
PF	PYF	French Polynesia	French Polynesia
TF	ATF	French Southern Territories (the)	French Southern Territories (the)
GA	GAB	Gabon	Gabon
GM	GMB	Gambia (the)	Gambia (the)
GE	GEO	Georgia	Georgia
DE	DEU	Germany	Germany
GH	GHA	Ghana	Ghana
GI	GIB	Gibraltar	Gibraltar
GR	GRC	Greece	Greece
GL	GRL	Greenland	Greenland
GD	GRD	Grenada	Grenada
GP	GLP	Guadeloupe	Guadeloupe
GU	GUM	Guam	Guam
GT	GTM	Guatemala	Guatemala
GG	GGY	Guernsey	Guernsey
GN	GIN	Guinea	Guinea
GW	GNB	Guinea-Bissau	Guinea-Bissau
GY	GUY	Guyana	Guyana
HT	HTI	Haiti	Haiti
HM	HMD	Heard Island and McDonald Islands	Heard Island and McDonald Islands
VA	VAT	Holy See (the)	Holy See (the)
HN	HND	Honduras	Honduras
HK	HKG	Hong Kong	Hong Kong
HU	HUN	Hungary	Hungary
IS	ISL	Iceland	Iceland
IN	IND	India	India
ID	IDN	Indonesia	Indonesia
IR	IRN	Iran (Islamic Republic of)	Iran (Islamic Republic of)
IQ	IRQ	Iraq	Iraq
IE	IRL	Ireland	Ireland
IM	IMN	Isle of Man	Isle of Man
IL	ISR	Israel	Israel
IT	ITA	Italy	Italy
JM	JAM	Jamaica	Jamaica
JP	JPN	Japan	Japan
JE	JEY	Jersey	Jersey
JO	JOR	Jordan	Jordan
KZ	KAZ	Kazakhstan	Kazakhstan
KE	KEN	Kenya	Kenya
KI	KIR	Kiribati	Kiribati
KP	PRK	Korea (the Democratic People's Republic of)	Korea (the Democratic People's Republic of)
KR	KOR	Korea (the Republic of)	Korea (the Republic of)
KW	KWT	Kuwait	Kuwait
KG	KGZ	Kyrgyzstan	Kyrgyzstan
LA	LAO	Lao People's Democratic Republic (the)	Lao People's Democratic Republic (the)
LV	LVA	Latvia	Latvia
LB	LBN	Lebanon	Lebanon
LS	LSO	Lesotho	Lesotho
LR	LBR	Liberia	Liberia
LY	LBY	Libya	Libya
LI	LIE	Liechtenstein	Liechtenstein
LT	LTU	Lithuania	Lithuania
LU	LUX	Luxembourg	Luxembourg
MO	MAC	Macao	Macao
MG	MDG	Madagascar	Madagascar
MW	MWI	Malawi	Malawi
MY	MYS	Malaysia	Malaysia
MV	MDV	Maldives	Maldives
ML	MLI	Mali	Mali
MT	MLT	Malta	Malta
MH	MHL	Marshall Islands (the)	Marshall Islands (the)
MQ	MTQ	Martinique	Martinique
MR	MRT	Mauritania	Mauritania
MU	MUS	Mauritius	Mauritius
YT	MYT	Mayotte	Mayotte
MX	MEX	Mexico	Mexico
FM	FSM	Micronesia (Federated States of)	Micronesia (Federated States of)
MD	MDA	Moldova (the Republic of)	Moldova (the Republic of)
MC	MCO	Monaco	Monaco
MN	MNG	Mongolia	Mongolia
ME	MNE	Montenegro	Montenegro
MS	MSR	Montserrat	Montserrat
MA	MAR	Morocco	Morocco
MZ	MOZ	Mozambique	Mozambique
MM	MMR	Myanmar	Myanmar
NA	NAM	Namibia	Namibia
NR	NRU	Nauru	Nauru
NP	NPL	Nepal	Nepal
NL	NLD	Netherlands (Kingdom of the)	Netherlands (Kingdom of the)
NC	NCL	New Caledonia	New Caledonia
NZ	NZL	New Zealand	New Zealand
NI	NIC	Nicaragua	Nicaragua
NE	NER	Niger (the)	Niger (the)
NG	NGA	Nigeria	Nigeria
NU	NIU	Niue	Niue
NF	NFK	Norfolk Island	Norfolk Island
MK	MKD	North Macedonia	North Macedonia
MP	MNP	Northern Mariana Islands (the)	Northern Mariana Islands (the)
NO	NOR	Norway	Norway
OM	OMN	Oman	Oman
PK	PAK	Pakistan	Pakistan
PW	PLW	Palau	Palau
PS	PSE	Palestine, State of	Palestine, State of
PA	PAN	Panama	Panama
PG	PNG	Papua New Guinea	Papua New Guinea
PY	PRY	Paraguay	Paraguay
PE	PER	Peru	Peru
PH	PHL	Philippines (the)	Philippines (the)
PN	PCN	Pitcairn	Pitcairn
PL	POL	Poland	Poland
PT	PRT	Portugal	Portugal
PR	PRI	Puerto Rico	Puerto Rico
QA	QAT	Qatar	Qatar
RO	ROU	Romania	Romania
RU	RUS	Russian Federation (the)	Russian Federation (the)
RW	RWA	Rwanda	Rwanda
RE	REU	Réunion	Reunion
BL	BLM	Saint Barthélemy	Saint Barthelemy
SH	SHN	Saint Helena, Ascension and Tristan da Cunha	Saint Helena, Ascension and Tristan da Cunha
KN	KNA	Saint Kitts and Nevis	Saint Kitts and Nevis
LC	LCA	Saint Lucia	Saint Lucia
MF	MAF	Saint Martin (French part)	Saint Martin (French part)
PM	SPM	Saint Pierre and Miquelon	Saint Pierre and Miquelon
VC	VCT	Saint Vincent and the Grenadines	Saint Vincent and the Grenadines
WS	WSM	Samoa	Samoa
SM	SMR	San Marino	San Marino
ST	STP	Sao Tome and Principe	Sao Tome and Principe
SA	SAU	Saudi Arabia	Saudi Arabia
SN	SEN	Senegal	Senegal
RS	SRB	Serbia	Serbia
SC	SYC	Seychelles	Seychelles
SL	SLE	Sierra Leone	Sierra Leone
SG	SGP	Singapore	Singapore
SX	SXM	Sint Maarten (Dutch part)	Sint Maarten (Dutch part)
SK	SVK	Slovakia	Slovakia
SI	SVN	Slovenia	Slovenia
SB	SLB	Solomon Islands	Solomon Islands
SO	SOM	Somalia	Somalia
ZA	ZAF	South Africa	South Africa
GS	SGS	South Georgia and the South Sandwich Islands	South Georgia and the South Sandwich Islands
SS	SSD	South Sudan	South Sudan
ES	ESP	Spain	Spain
LK	LKA	Sri Lanka	Sri Lanka
SD	SDN	Sudan (the)	Sudan (the)
SR	SUR	Suriname	Suriname
SJ	SJM	Svalbard and Jan Mayen	Svalbard and Jan Mayen
SE	SWE	Sweden	Sweden
CH	CHE	Switzerland	Switzerland
SY	SYR	Syrian Arab Republic (the)	Syrian Arab Republic (the)
TW	TWN	Taiwan (Province of China)	Taiwan (Province of China)
TJ	TJK	Tajikistan	Tajikistan
TZ	TZA	Tanzania, the United Republic of	Tanzania, the United Republic of
TH	THA	Thailand	Thailand
TL	TLS	Timor-Leste	Timor-Leste
TG	TGO	Togo	Togo
TK	TKL	Tokelau	Tokelau
TO	TON	Tonga	Tonga
TT	TTO	Trinidad and Tobago	Trinidad and Tobago
TN	TUN	Tunisia	Tunisia
TM	TKM	Turkmenistan	Turkmenistan
TC	TCA	Turks and Caicos Islands (the)	Turks and Caicos Islands (the)
TV	TUV	Tuvalu	Tuvalu
TR	TUR	Türkiye	Turkiye
UG	UGA	Uganda	Uganda
UA	UKR	Ukraine	Ukraine
AE	ARE	United Arab Emirates (the)	United Arab Emirates (the)
GB	GBR	United Kingdom of Great Britain and Northern Ireland (the)	United Kingdom of Great Britain and Northern Ireland (the)
UM	UMI	United States Minor Outlying Islands (the)	United States Minor Outlying Islands (the)
US	USA	United States of America (the)	United States of America (the)
UY	URY	Uruguay	Uruguay
UZ	UZB	Uzbekistan	Uzbekistan
VU	VUT	Vanuatu	Vanuatu
VE	VEN	Venezuela (Bolivarian Republic of)	Venezuela (Bolivarian Republic of)
VN	VNM	Viet Nam	Viet Nam
VG	VGB	Virgin Islands (British)	Virgin Islands (British)
VI	VIR	Virgin Islands (U.S.)	Virgin Islands (U.S.)
WF	WLF	Wallis and Futuna	Wallis and Futuna
EH	ESH	Western Sahara*	Western Sahara*
YE	YEM	Yemen	Yemen
ZM	ZMB	Zambia	Zambia
ZW	ZWE	Zimbabwe	Zimbabwe#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'INT_COUNTRIES_250', p_set_type=>'CSV', p_params=>my_clob, p_system_flag=>'Y');
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
