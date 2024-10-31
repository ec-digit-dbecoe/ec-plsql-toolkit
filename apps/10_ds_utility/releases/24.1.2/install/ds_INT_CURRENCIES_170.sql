REM Source: https://en.wikipedia.org/wiki/ISO_4217, 2024, licenced under the Creative Commons Attribution-ShareAlike 4.0 License.
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#CCY_CODE	CCY_NUM	CCY_NAME_UTF8	CCY_NAME_ASCII
C(3)	N(3)	C(60)	C(60)
AED	784	United Arab Emirates dirham	United Arab Emirates dirham
AFN	971	Afghan afghani	Afghan afghani
ALL	8	Albanian lek	Albanian lek
AMD	51	Armenian dram	Armenian dram
ANG	532	Netherlands Antillean guilder	Netherlands Antillean guilder
AOA	973	Angolan kwanza	Angolan kwanza
ARS	32	Argentine peso	Argentine peso
AUD	36	Australian dollar	Australian dollar
AWG	533	Aruban florin	Aruban florin
AZN	944	Azerbaijani manat	Azerbaijani manat
BAM	977	Bosnia and Herzegovina convertible mark	Bosnia and Herzegovina convertible mark
BBD	52	Barbados dollar	Barbados dollar
BDT	50	Bangladeshi taka	Bangladeshi taka
BGN	975	Bulgarian lev	Bulgarian lev
BHD	48	Bahraini dinar	Bahraini dinar
BIF	108	Burundian franc	Burundian franc
BMD	60	Bermudian dollar	Bermudian dollar
BND	96	Brunei dollar	Brunei dollar
BOB	68	Boliviano	Boliviano
BOV	984	Bolivian Mvdol (funds code)	Bolivian Mvdol (funds code)
BRL	986	Brazilian real	Brazilian real
BSD	44	Bahamian dollar	Bahamian dollar
BTN	64	Bhutanese ngultrum	Bhutanese ngultrum
BWP	72	Botswana pula	Botswana pula
BYN	933	Belarusian ruble	Belarusian ruble
BZD	84	Belize dollar	Belize dollar
CAD	124	Canadian dollar	Canadian dollar
CDF	976	Congolese franc	Congolese franc
CHE	947	WIR euro (complementary currency)	WIR euro (complementary currency)
CHF	756	Swiss franc	Swiss franc
CHW	948	WIR franc (complementary currency)	WIR franc (complementary currency)
CLF	990	Unidad de Fomento (funds code)	Unidad de Fomento (funds code)
CLP	152	Chilean peso	Chilean peso
COP	170	Colombian peso	Colombian peso
COU	970	Unidad de Valor Real (UVR) (funds code)[6]	Unidad de Valor Real (UVR) (funds code)[6]
CRC	188	Costa Rican colon	Costa Rican colon
CUC	931	Cuban convertible peso	Cuban convertible peso
CUP	192	Cuban peso	Cuban peso
CVE	132	Cape Verdean escudo	Cape Verdean escudo
CZK	203	Czech koruna	Czech koruna
DJF	262	Djiboutian franc	Djiboutian franc
DKK	208	Danish krone	Danish krone
DOP	214	Dominican peso	Dominican peso
DZD	12	Algerian dinar	Algerian dinar
EGP	818	Egyptian pound	Egyptian pound
ERN	232	Eritrean nakfa	Eritrean nakfa
ETB	230	Ethiopian birr	Ethiopian birr
EUR	978	Euro	Euro
FJD	242	Fiji dollar	Fiji dollar
FKP	238	Falkland Islands pound	Falkland Islands pound
GBP	826	Pound sterling	Pound sterling
GEL	981	Georgian lari	Georgian lari
GHS	936	Ghanaian cedi	Ghanaian cedi
GIP	292	Gibraltar pound	Gibraltar pound
GMD	270	Gambian dalasi	Gambian dalasi
GNF	324	Guinean franc	Guinean franc
GTQ	320	Guatemalan quetzal	Guatemalan quetzal
GYD	328	Guyanese dollar	Guyanese dollar
HKD	344	Hong Kong dollar	Hong Kong dollar
HNL	340	Honduran lempira	Honduran lempira
HTG	332	Haitian gourde	Haitian gourde
HUF	348	Hungarian forint	Hungarian forint
IDR	360	Indonesian rupiah	Indonesian rupiah
ILS	376	Israeli new shekel	Israeli new shekel
INR	356	Indian rupee	Indian rupee
IQD	368	Iraqi dinar	Iraqi dinar
IRR	364	Iranian rial	Iranian rial
ISK	352	Icelandic króna (plural: krónur)	Icelandic krona (plural: kronur)
JMD	388	Jamaican dollar	Jamaican dollar
JOD	400	Jordanian dinar	Jordanian dinar
JPY	392	Japanese yen	Japanese yen
KES	404	Kenyan shilling	Kenyan shilling
KGS	417	Kyrgyzstani som	Kyrgyzstani som
KHR	116	Cambodian riel	Cambodian riel
KMF	174	Comoro franc	Comoro franc
KPW	408	North Korean won	North Korean won
KRW	410	South Korean won	South Korean won
KWD	414	Kuwaiti dinar	Kuwaiti dinar
KYD	136	Cayman Islands dollar	Cayman Islands dollar
KZT	398	Kazakhstani tenge	Kazakhstani tenge
LAK	418	Lao kip	Lao kip
LBP	422	Lebanese pound	Lebanese pound
LKR	144	Sri Lankan rupee	Sri Lankan rupee
LRD	430	Liberian dollar	Liberian dollar
LSL	426	Lesotho loti	Lesotho loti
LYD	434	Libyan dinar	Libyan dinar
MAD	504	Moroccan dirham	Moroccan dirham
MDL	498	Moldovan leu	Moldovan leu
MGA	969	Malagasy ariary	Malagasy ariary
MKD	807	Macedonian denar	Macedonian denar
MMK	104	Myanmar kyat	Myanmar kyat
MNT	496	Mongolian tögrög	Mongolian togrog
MOP	446	Macanese pataca	Macanese pataca
MRU	929	Mauritanian ouguiya	Mauritanian ouguiya
MUR	480	Mauritian rupee	Mauritian rupee
MVR	462	Maldivian rufiyaa	Maldivian rufiyaa
MWK	454	Malawian kwacha	Malawian kwacha
MXN	484	Mexican peso	Mexican peso
MXV	979	Mexican Unidad de Inversion (UDI) (funds code)	Mexican Unidad de Inversion (UDI) (funds code)
MYR	458	Malaysian ringgit	Malaysian ringgit
MZN	943	Mozambican metical	Mozambican metical
NAD	516	Namibian dollar	Namibian dollar
NGN	566	Nigerian naira	Nigerian naira
NIO	558	Nicaraguan córdoba	Nicaraguan cordoba
NOK	578	Norwegian krone	Norwegian krone
NPR	524	Nepalese rupee	Nepalese rupee
NZD	554	New Zealand dollar	New Zealand dollar
OMR	512	Omani rial	Omani rial
PAB	590	Panamanian balboa	Panamanian balboa
PEN	604	Peruvian sol	Peruvian sol
PGK	598	Papua New Guinean kina	Papua New Guinean kina
PHP	608	Philippine peso	Philippine peso
PKR	586	Pakistani rupee	Pakistani rupee
PLN	985	Polish złoty	Polish złoty
PYG	600	Paraguayan guaraní	Paraguayan guarani
QAR	634	Qatari riyal	Qatari riyal
RON	946	Romanian leu	Romanian leu
RSD	941	Serbian dinar	Serbian dinar
CNY	156	Renminbi	Renminbi
RUB	643	Russian ruble	Russian ruble
RWF	646	Rwandan franc	Rwandan franc
SAR	682	Saudi riyal	Saudi riyal
SBD	90	Solomon Islands dollar	Solomon Islands dollar
SCR	690	Seychelles rupee	Seychelles rupee
SDG	938	Sudanese pound	Sudanese pound
SEK	752	Swedish krona (plural: kronor)	Swedish krona (plural: kronor)
SGD	702	Singapore dollar	Singapore dollar
SHP	654	Saint Helena pound	Saint Helena pound
SLE	925	Sierra Leonean leone (new leone)	Sierra Leonean leone (new leone)
SLL	694	Sierra Leonean leone (old leone)	Sierra Leonean leone (old leone)
SOS	706	Somali shilling	Somali shilling
SRD	968	Surinamese dollar	Surinamese dollar
SSP	728	South Sudanese pound	South Sudanese pound
STN	930	São Tomé and Príncipe dobra	São Tome and Principe dobra
SVC	222	Salvadoran colón	Salvadoran colon
SYP	760	Syrian pound	Syrian pound
SZL	748	Swazi lilangeni	Swazi lilangeni
THB	764	Thai baht	Thai baht
TJS	972	Tajikistani somoni	Tajikistani somoni
TMT	934	Turkmenistan manat	Turkmenistan manat
TND	788	Tunisian dinar	Tunisian dinar
TOP	776	Tongan paʻanga	Tongan paʻanga
TRY	949	Turkish lira	Turkish lira
TTD	780	Trinidad and Tobago dollar	Trinidad and Tobago dollar
TWD	901	New Taiwan dollar	New Taiwan dollar
TZS	834	Tanzanian shilling	Tanzanian shilling
UAH	980	Ukrainian hryvnia	Ukrainian hryvnia
UGX	800	Ugandan shilling	Ugandan shilling
USD	840	United States dollar	United States dollar
USN	997	United States dollar (next day) (funds code)	United States dollar (next day) (funds code)
UYI	940	Uruguay Peso en Unidades Indexadas (URUIURUI) (funds code)	Uruguay Peso en Unidades Indexadas (URUIURUI) (funds code)
UYU	858	Uruguayan peso	Uruguayan peso
UYW	927	Unidad previsional	Unidad previsional
UZS	860	Uzbekistan sum	Uzbekistan sum
VED	926	Venezuelan digital bolívar	Venezuelan digital bolivar
VES	928	Venezuelan sovereign bolívar	Venezuelan sovereign bolivar
VND	704	Vietnamese đồng	Vietnamese đồng
VUV	548	Vanuatu vatu	Vanuatu vatu
WST	882	Samoan tala	Samoan tala
XAF	950	CFA franc BEAC	CFA franc BEAC
XCD	951	East Caribbean dollar	East Caribbean dollar
XDR	960	Special drawing rights	Special drawing rights
XOF	952	CFA franc BCEAO	CFA franc BCEAO
XPF	953	CFP franc (franc Pacifique)	CFP franc (franc Pacifique)
XSU	994	SUCRE	SUCRE
XUA	965	ADB Unit of Account	ADB Unit of Account
YER	886	Yemeni rial	Yemeni rial
ZAR	710	South African rand	South African rand
ZMW	967	Zambian kwacha	Zambian kwacha
ZWL	932	Zimbabwean dollar (fifth)	Zimbabwean dollar (fifth)#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'INT_CURRENCIES_170', p_set_type=>'CSV', p_params=>my_clob);
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
