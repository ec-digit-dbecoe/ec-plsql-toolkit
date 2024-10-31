REM Source: https://en.wikipedia.org/wiki/Lists_of_cities_by_country, 2024, licenced under the Creative Commons Attribution-ShareAlike 4.0 License.
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#CTY_NAME_ASCII	CTRY_CODE_A2	CTRY_CODE_A3
C(33)	C(2)	C(3)
London	GB	GBR
Berlin	DE	DEU
Madrid	ES	ESP
Rome	IT	ITA
Paris	FR	FRA
Bucharest	RO	ROU
Hamburg	DE	DEU
Budapest	HU	HUN
Warsaw	PL	POL
Vienna	AT	AUT
Barcelona	ES	ESP
Stockholm	SE	SWE
Milan	IT	ITA
Munich	DE	DEU
Prague	CZ	CZE
Copenhagen	DK	DNK
Sofia	BG	BGR
Birmingham	GB	GBR
Dublin	IE	IRL
Brussels	BE	BEL
Koeln	DE	DEU
Naples	IT	ITA
Marseille	FR	FRA
Liverpool	GB	GBR
Turin	IT	ITA
Valencia	ES	ESP
Lodz	PL	POL
Krakow	PL	POL
Riga	LV	LVA
Amsterdam	NL	NLD
Sevilla	ES	ESP
Zaragoza	ES	ESP
Athens	GR	GRC
Zagreb	HR	HRV
Helsinki	FI	FIN
Frankfurt am Main	DE	DEU
Palermo	IT	ITA
Wroclaw	PL	POL
Stuttgart	DE	DEU
Glasgow	GB	GBR
Duesseldorf	DE	DEU
Rotterdam	NL	NLD
Kleinzschocher	DE	DEU
Grosszschocher	DE	DEU
Essen	DE	DEU
Dortmund	DE	DEU
Goeteborg	SE	SWE
Genoa	IT	ITA
Oslo	NO	NOR
Malaga	ES	ESP
Poznan	PL	POL
Sheffield	GB	GBR
Dresden	DE	DEU
Bremen	DE	DEU
Vilnius	LT	LTU
Antwerpen	BE	BEL
Lyon	FR	FRA
Lisbon	PT	PRT
Leeds	GB	GBR
Nuernberg	DE	DEU
Hannover	DE	DEU
Edinburgh	GB	GBR
Leipzig	DE	DEU
Duisburg	DE	DEU
Toulouse	FR	FRA
The Hague	NL	NLD
Bristol	GB	GBR
Gdansk	PL	POL
Murcia	ES	ESP
Cardiff	GB	GBR
Bratislava	SK	SVK
Wandsbek	DE	DEU
Palma	ES	ESP
Szczecin	PL	POL
Manchester	GB	GBR
Bologna	IT	ITA
Tallinn	EE	EST
Bochum	DE	DEU
Sector 3	RO	ROU
Bochum-Hordel	DE	DEU
Brno	CZ	CZE
Iasi	RO	ROU
Leicester	GB	GBR
Sector 6	RO	ROU
Florence	IT	ITA
Bydgoszcz	PL	POL
Bradford	GB	GBR
Utrecht	NL	NLD
Wuppertal	DE	DEU
Lublin	PL	POL
Malmoe	SE	SWE
Plovdiv	BG	BGR
Bilbao	ES	ESP
Belfast	GB	GBR
Sector 2	RO	ROU
Coventry	GB	GBR
Nice	FR	FRA
Alicante	ES	ESP
Bielefeld	DE	DEU
Bonn	DE	DEU
Brent	GB	GBR
Cordoba	ES	ESP
Birkenhead	GB	GBR
Nottingham	GB	GBR
Islington	GB	GBR
Nantes	FR	FRA
Reading	GB	GBR
Constanta	RO	ROU
Thessaloniki	GR	GRC
Katowice	PL	POL
Cluj-Napoca	RO	ROU
Bari	IT	ITA
Hamburg-Nord	DE	DEU
Timisoara	RO	ROU
Kingston upon Hull	GB	GBR
Preston	GB	GBR
Varna	BG	BGR
Catania	IT	ITA
Mannheim	DE	DEU
Newport	GB	GBR
Craiova	RO	ROU
Hamburg-Mitte	DE	DEU
Swansea	GB	GBR
Newcastle upon Tyne	GB	GBR
Valladolid	ES	ESP
Vigo	ES	ESP
Graz	AT	AUT
Southend-on-Sea	GB	GBR
Galati	RO	ROU
Bialystok	PL	POL
Kaunas	LT	LTU
Sector 4	RO	ROU
Marienthal	DE	DEU
Bergen	NO	NOR
Arhus	DK	DNK
Karlsruhe	DE	DEU
Ostrava	CZ	CZE
South Dublin	IE	IRL
Wiesbaden	DE	DEU
Gijon	ES	ESP
Brighton	GB	GBR
Strasbourg	FR	FRA
Ljubljana	SI	SVN
Sector 5	RO	ROU
Derby	GB	GBR
Muenster	DE	DEU
Gelsenkirchen	DE	DEU
Southampton	GB	GBR
Eimsbuettel	DE	DEU
Eixample	ES	ESP
Aachen	DE	DEU
Gent	BE	BEL
Wolverhampton	GB	GBR
Moenchengladbach	DE	DEU
Bordeaux	FR	FRA
Plymouth	GB	GBR
Augsburg	DE	DEU
Stoke-on-Trent	GB	GBR
Verona	IT	ITA
L'Hospitalet de Llobregat	ES	ESP
Espoo	FI	FIN
Latina	ES	ESP
Milton Keynes	GB	GBR
Carabanchel	ES	ESP
Brasov	RO	ROU
Altona	DE	DEU
Porto	PT	PRT
Gasteiz / Vitoria	ES	ESP
Montpellier	FR	FRA
Czestochowa	PL	POL
City of Westminster	GB	GBR
Chemnitz	DE	DEU
Kiel	DE	DEU
A Coruna	ES	ESP
Northampton	GB	GBR
Gdynia	PL	POL
Braunschweig	DE	DEU
Tampere	FI	FIN
Puente de Vallecas	ES	ESP
Krefeld	DE	DEU
Halle (Saale)	DE	DEU
Oldham	GB	GBR
Magdeburg	DE	DEU
Sant Marti	ES	ESP
Rouen	FR	FRA
Lille	FR	FRA
Granada	ES	ESP
Groningen	NL	NLD
Elche	ES	ESP
Ploiesti	RO	ROU
Kosice	SK	SVK
Ciudad Lineal	ES	ESP
Bexley	GB	GBR
Sosnowiec	PL	POL
Neue Neustadt	DE	DEU
Radom	PL	POL
Sector 1	RO	ROU
Luton	GB	GBR
Rennes	FR	FRA
Fuencarral-El Pardo	ES	ESP
Oviedo	ES	ESP
Messina	IT	ITA
Badalona	ES	ESP
Oberhausen	DE	DEU
Terrassa	ES	ESP
Mokotow	PL	POL
Mainz	DE	DEU
Freiburg	DE	DEU
Archway	GB	GBR
Erfurt	DE	DEU
Braila	RO	ROU
Luebeck	DE	DEU
Cartagena	ES	ESP
Pamplona	ES	ESP
Oulu	FI	FIN
Eindhoven	NL	NLD
Kielce	PL	POL
Portsmouth	GB	GBR
Jerez de la Frontera	ES	ESP
Oradea	RO	ROU
Sabadell	ES	ESP
Mostoles	ES	ESP
Linz	AT	AUT
Alcala de Henares	ES	ESP
Trieste	IT	ITA
Padova	IT	ITA
Debrecen	HU	HUN
Favoriten	AT	AUT
Swindon	GB	GBR
Brescia	IT	ITA
Charleroi	BE	BEL
Tilburg	NL	NLD
Dudley	GB	GBR
Hagen	DE	DEU
Gliwice	PL	POL
Torun	PL	POL
Aberdeen	GB	GBR
Taranto	IT	ITA
Rostock	DE	DEU
Parma	IT	ITA
Fuenlabrada	ES	ESP
Reims	FR	FRA
Burgas	BG	BGR
Turku	FI	FIN
Liege	BE	BEL
Prato	IT	ITA
Kassel	DE	DEU
Zabrze	PL	POL
Cork	IE	IRL
Vantaa	FI	FIN
Bytom	PL	POL
Almeria	ES	ESP
Sutton	GB	GBR
Donaustadt	AT	AUT
Leganes	ES	ESP
Le Havre	FR	FRA
San Sebastian	ES	ESP
Modena	IT	ITA
Cergy-Pontoise	FR	FRA
St Helens	GB	GBR
Sants-Montjuic	ES	ESP
Reggio Calabria	IT	ITA
Potsdam	DE	DEU
Odense	DK	DNK
Crawley	GB	GBR
Castello de la Plana	ES	ESP
Praga Poludnie	PL	POL
Saarbruecken	DE	DEU
Hamm	DE	DEU
Burgos	ES	ESP
Amadora	PT	PRT
Ipswich	GB	GBR
Uppsala	SE	SWE
Bielsko-Biala	PL	POL
Almere Stad	NL	NLD
Saint-Etienne	FR	FRA
Wigan	GB	GBR
Croydon	GB	GBR
Warrington	GB	GBR
Klaipeda	LT	LTU
Walsall	GB	GBR
Herne	DE	DEU
Santander	ES	ESP
Mansfield	GB	GBR
Reggio nell'Emilia	IT	ITA
Olsztyn	PL	POL
Bacau	RO	ROU
Muelheim	DE	DEU
Sunderland	GB	GBR
Albacete	ES	ESP
Harburg	DE	DEU
Arad	RO	ROU
Pilsen	CZ	CZE
Toulon	FR	FRA
Angers	FR	FRA
Ilford	GB	GBR
Horta-Guinardo	ES	ESP
Patra	GR	GRC
Alcorcon	ES	ESP
Breda	NL	NLD
Pitesti	RO	ROU
Getafe	ES	ESP
Osnabrueck	DE	DEU
Nou Barris	ES	ESP
Slough	GB	GBR
Neukoelln	DE	DEU
Solingen	DE	DEU
Piraeus	GR	GRC
Bournemouth	GB	GBR
Peterborough	GB	GBR
Ludwigshafen am Rhein	DE	DEU
Floridsdorf	AT	AUT
Leverkusen	DE	DEU
Oxford	GB	GBR
Hortaleza	ES	ESP
Szeged	HU	HUN
Anderlecht	BE	BEL
Oldenburg	DE	DEU
Nijmegen	NL	NLD
Grenoble	FR	FRA
Rzeszow	PL	POL
Dijon	FR	FRA
San Blas-Canillejas	ES	ESP
Salzburg	AT	AUT
Livorno	IT	ITA
Enfield Town	GB	GBR
York	GB	GBR
OErebro	SE	SWE
Salamanca	ES	ESP
Telford	GB	GBR
Tetuan de las Victorias	ES	ESP
Miskolc	HU	HUN
Enschede	NL	NLD
Kreuzberg	DE	DEU
Logrono	ES	ESP
Neuss	DE	DEU
Sibiu	RO	ROU
Ursynow	PL	POL
Poole	GB	GBR
Split	HR	HRV
Madrid Centro	ES	ESP
Burnley	GB	GBR
Cagliari	IT	ITA
Harrow	GB	GBR
Huddersfield	GB	GBR
Prenzlauer Berg Bezirk	DE	DEU
Arganzuela	ES	ESP
Rimini	IT	ITA
Badajoz	ES	ESP
Nimes	FR	FRA
Dundee	GB	GBR
Sarria-Sant Gervasi	ES	ESP
Clermont-Ferrand	FR	FRA
Sant Andreu	ES	ESP
Salamanca	ES	ESP
Mestre	IT	ITA
Haarlem	NL	NLD
Trondheim	NO	NOR
Larisa	GR	GRC
Targu-Mures	RO	ROU
Aix-en-Provence	FR	FRA
Saint-Quentin-en-Yvelines	FR	FRA
Blackburn	GB	GBR
Ruda Slaska	PL	POL
Chamberi	ES	ESP
Cambridge	GB	GBR
Pecs	HU	HUN
Blackpool	GB	GBR
Brest	FR	FRA
Stavanger	NO	NOR
Basildon	GB	GBR
Le Mans	FR	FRA
Jyvaeskylae	FI	FIN
Huelva	ES	ESP
Stara Zagora	BG	BGR
Ruse	BG	BGR
Heidelberg	DE	DEU
Norwich	GB	GBR
Amiens	FR	FRA
Aalborg	DK	DNK
Middlesbrough	GB	GBR
Rybnik	PL	POL
Paderborn	DE	DEU
Arnhem	NL	NLD
Tours	FR	FRA
Bolton	GB	GBR
Usera	ES	ESP
Limoges	FR	FRA
Wola	PL	POL
Darmstadt	DE	DEU
Zaanstad	NL	NLD
Chamartin	ES	ESP
Peristeri	GR	GRC
Amersfoort	NL	NLD
Sollentuna	SE	SWE
Stockport	GB	GBR
Budapest XI. keruelet	HU	HUN
Lleida	ES	ESP
Irakleion	GR	GRC
Foggia	IT	ITA
Apeldoorn	NL	NLD
Baia Mare	RO	ROU
West Bromwich	GB	GBR
Bielany	PL	POL
Marbella	ES	ESP
's-Hertogenbosch	NL	NLD
Srodmiescie	PL	POL
Leon	ES	ESP
Wuerzburg	DE	DEU
Hastings	GB	GBR
High Wycombe	GB	GBR
Schaerbeek	BE	BEL
Hoofddorp	NL	NLD
Innsbruck	AT	AUT
Gloucester	GB	GBR
Tarragona	ES	ESP
Ferrara	IT	ITA
Villeurbanne	FR	FRA
Buzau	RO	ROU
Exeter	GB	GBR
Umea	SE	SWE
Zuglo	HU	HUN
Tychy	PL	POL
Tottenham	GB	GBR
Salford	GB	GBR
Newcastle under Lyme	GB	GBR
Acilia-Castel Fusano-Ostia Antica	IT	ITA
Charlottenburg	DE	DEU
Gyor	HU	HUN
Regensburg	DE	DEU
Bialoleka	PL	POL
Besancon	FR	FRA
Vaesteras	SE	SWE
Opole	PL	POL
Elblag	PL	POL
Plock	PL	POL
Walbrzych	PL	POL
Soedermalm	SE	SWE
Villaverde	ES	ESP
Cadiz	ES	ESP
Solihull	GB	GBR
Retiro	ES	ESP
Salerno	IT	ITA
Watford	GB	GBR
Saint Peters	GB	GBR
Gorzow Wielkopolski	PL	POL
Monza	IT	ITA
Targowek	PL	POL
Metz	FR	FRA
Budapest III. keruelet	HU	HUN
Wolfsburg	DE	DEU
Dos Hermanas	ES	ESP
Schoeneberg	DE	DEU
Recklinghausen	DE	DEU
Maastricht	NL	NLD
Burton upon Trent	GB	GBR
Goettingen	DE	DEU
Colchester	GB	GBR
Mataro	ES	ESP
Siracusa	IT	ITA
Kuopio	FI	FIN
Gracia	ES	ESP
Braga	PT	PRT
Bergamo	IT	ITA
Heilbronn	DE	DEU
Trento	IT	ITA
Ingolstadt	DE	DEU
Ulm	DE	DEU
Wloclawek	PL	POL
Perugia	IT	ITA
Lahti	FI	FIN
Bottrop	DE	DEU
Leiden	NL	NLD
Bergedorf	DE	DEU
Pescara	IT	ITA
Pforzheim	DE	DEU
Dordrecht	NL	NLD
Offenbach	DE	DEU
Santa Coloma de Gramenet	ES	ESP
Brugge	BE	BEL
Zielona Gora	PL	POL
Dabrowa Gornicza	PL	POL
Eastbourne	GB	GBR
Torrejon de Ardoz	ES	ESP
Friedrichshain Bezirk	DE	DEU
Tarnow	PL	POL
Nyiregyhaza	HU	HUN
Rotherham	GB	GBR
Remscheid	DE	DEU
Setubal	PT	PRT
Forli	IT	ITA
Moncloa-Aravaca	ES	ESP
Cheltenham	GB	GBR
Orleans	FR	FRA
Algeciras	ES	ESP
Zoetermeer	NL	NLD
Parla	ES	ESP
Botosani	RO	ROU
Doncaster	GB	GBR
Bremerhaven	DE	DEU
Budapest XIII. keruelet	HU	HUN
Nippes	DE	DEU
Jaen	ES	ESP
Chorzow	PL	POL
Porz am Rhein	DE	DEU
Chesterfield	GB	GBR
Reutlingen	DE	DEU
Satu Mare	RO	ROU
Furth	DE	DEU
Vicenza	IT	ITA
Zwolle	NL	NLD
Daugavpils	LV	LVA
Chelmsford	GB	GBR
Marzahn	DE	DEU
Mulhouse	FR	FRA
Montreuil	FR	FRA
Terni	IT	ITA
Namur	BE	BEL
Perpignan	FR	FRA
Caen	FR	FRA
Delicias	ES	ESP
Rodenkirchen	DE	DEU
Mendip	GB	GBR
Pisa	IT	ITA
Kecskemet	HU	HUN
Wakefield	GB	GBR
Walthamstow	GB	GBR
Boulogne-Billancourt	FR	FRA
Kalisz	PL	POL
Dagenham	GB	GBR
Rijeka	HR	HRV
Basingstoke	GB	GBR
Maidstone	GB	GBR
Ramnicu Valcea	RO	ROU
Alcobendas	ES	ESP
Koszalin	PL	POL
Bolzano	IT	ITA
Koblenz	DE	DEU
Siegen	DE	DEU
Reus	ES	ESP
Sutton Coldfield	GB	GBR
Bedford	GB	GBR
Coimbra	PT	PRT
Linkoeping	SE	SWE
Bergisch Gladbach	DE	DEU
Legnica	PL	POL
Suceava	RO	ROU
Ourense	ES	ESP
Nancy	FR	FRA
Moratalaz	ES	ESP
Jena	DE	DEU
Gera	DE	DEU
Ottakring	AT	AUT
Helsingborg	SE	SWE
Woking	GB	GBR
Salzgitter	DE	DEU
Lincoln	GB	GBR
Piacenza	IT	ITA
Moers	DE	DEU
Queluz	PT	PRT
Hildesheim	DE	DEU
Drammen	NO	NOR
Liberec	CZ	CZE
Hengelo	NL	NLD
Lyon 03	FR	FRA
Piatra Neamt	RO	ROU
Erlangen	DE	DEU
Bemowo	PL	POL
Ciutat Vella	ES	ESP
Drobeta-Turnu Severin	RO	ROU
Mitte	DE	DEU
Novara	IT	ITA
Wilmersdorf	DE	DEU
Torrevieja	ES	ESP
Worcester	GB	GBR
Venlo	NL	NLD
Szekesfehervar	HU	HUN
Bath	GB	GBR
Argenteuil	FR	FRA
Simmering	AT	AUT
Witten	DE	DEU
Gillingham	GB	GBR
Leuven	BE	BEL
Pleven	BG	BGR
Arezzo	IT	ITA
Kallithea	GR	GRC
Klagenfurt am Woerthersee	AT	AUT
Udine	IT	ITA
Trier	DE	DEU
Becontree	GB	GBR#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'EU_MAJOR_CITIES_590', p_set_type=>'CSV', p_params=>my_clob);
   UPDATE ds_data_sets
      SET col_sep_char = CHR(9) -- column separator is TAB
        , col_names_row = 1  -- column names at row 1
        , col_types_row = 2  -- column types at row 1
    WHERE set_id = l_set_id
   ;
   COMMIT;
   dbms_lob.freetemporary(my_clob);
END;
/
