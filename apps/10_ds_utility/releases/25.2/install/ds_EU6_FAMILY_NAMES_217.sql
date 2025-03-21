REM Source: https://en.wikipedia.org/wiki/List_of_most_common_surnames_in_Europe , 2024, licenced under the Creative Commons Attribution-ShareAlike 4.0 License.
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#FAMILY_NAME_UTF8	FAMILY_NAME_ASCII	COUNTRY_CODE_A2
C(12)	C(12)	C(2)
Janssens	Janssens	BE
Maes	Maes	BE
Jacobs	Jacobs	BE
Mertens	Mertens	BE
Willems	Willems	BE
Claes	Claes	BE
Goossens	Goossens	BE
Wouters	Wouters	BE
De Smet	De Smet	BE
Dubois	Dubois	BE
Lambert	Lambert	BE
Dupont	Dupont	BE
Martin	Martin	BE
Diallo	Diallo	BE
Simon	Simon	BE
Dumont	Dumont	BE
Leclercq	Leclercq	BE
Laurent	Laurent	BE
Denis	Denis	BE
Lejeune	Lejeune	BE
Bah	Bah	BE
Barry	Barry	BE
Nguyen	Nguyen	BE
Sow	Sow	BE
Benali	Benali	BE
Bernard	Bernard	FR
Dubois	Dubois	FR
Thomas	Thomas	FR
Robert	Robert	FR
Richard	Richard	FR
Petit	Petit	FR
Durand	Durand	FR
Leroy	Leroy	FR
Moreau	Moreau	FR
Simon	Simon	FR
Laurent	Laurent	FR
Lefebvre	Lefebvre	FR
Michel	Michel	FR
Garcia	Garcia	FR
David	David	FR
Bertrand	Bertrand	FR
Roux	Roux	FR
Vincent	Vincent	FR
Fournier	Fournier	FR
Morel	Morel	FR
Girard	Girard	FR
André	Andre	FR
Lefèvre	Lefevre	FR
Mercier	Mercier	FR
Dupont	Dupont	FR
Lambert	Lambert	FR
Bonnet	Bonnet	FR
François	Francois	FR
Martinez	Martinez	FR
Rossi	Rossi	IT
Russo	Russo	IT
Ferrari	Ferrari	IT
Esposito	Esposito	IT
Bianchi	Bianchi	IT
Romano	Romano	IT
Colombo	Colombo	IT
Bruno	Bruno	IT
Ricci	Ricci	IT
Greco	Greco	IT
Marino	Marino	IT
Gallo	Gallo	IT
De Luca	De Luca	IT
Conti	Conti	IT
Costa	Costa	IT
Mancini	Mancini	IT
Giordano	Giordano	IT
Rizzo	Rizzo	IT
Lombardi	Lombardi	IT
Barbieri	Barbieri	IT
Moretti	Moretti	IT
Fontana	Fontana	IT
Caruso	Caruso	IT
Mariani	Mariani	IT
Ferrara	Ferrara	IT
Santoro	Santoro	IT
Rinaldi	Rinaldi	IT
Leone	Leone	IT
D'Angelo	D'Angelo	IT
Longo	Longo	IT
Galli	Galli	IT
Martini	Martini	IT
Martinelli	Martinelli	IT
Serra	Serra	IT
Conte	Conte	IT
Vitale	Vitale	IT
De Santis	De Santis	IT
Marchetti	Marchetti	IT
Messina	Messina	IT
Gentile	Gentile	IT
Villa	Villa	IT
Marini	Marini	IT
Lombardo	Lombardo	IT
Coppola	Coppola	IT
Ferri	Ferri	IT
Parisi	Parisi	IT
De Angelis	De Angelis	IT
Bianco	Bianco	IT
Amato	Amato	IT
Fabbri	Fabbri	IT
Gatti	Gatti	IT
Sala	Sala	IT
Morelli	Morelli	IT
Grasso	Grasso	IT
Pellegrini	Pellegrini	IT
Ferraro	Ferraro	IT
Monti	Monti	IT
Schmit	Schmit	LU
Muller	Muller	LU
Weber	Weber	LU
Hoffmann	Hoffmann	LU
Wagner	Wagner	LU
Thill	Thill	LU
Schmitz	Schmitz	LU
Schroeder	Schroeder	LU
Reuter	Reuter	LU
Klein	Klein	LU
Becker	Becker	LU
Kieffer	Kieffer	LU
Kremer	Kremer	LU
Faber	Faber	LU
Meyer	Meyer	LU
Schneider	Schneider	LU
Weiss	Weiss	LU
Schiltz	Schiltz	LU
Simon	Simon	LU
Welter	Welter	LU
Hansen	Hansen	LU
Majerus	Majerus	LU
Ries	Ries	LU
Meyers	Meyers	LU
Kayser	Kayser	LU
Steffen	Steffen	LU
Krier	Krier	LU
Braun	Braun	LU
Wagener	Wagener	LU
Diederich	Diederich	LU
De Graaf	De Graaf	NL
Van der Meer	Van der Meer	NL
De Wit	De Wit	NL
Dijkstra	Dijkstra	NL
Smits	Smits	NL
Brouwer	Brouwer	NL
Dekker	Dekker	NL
Hendriks	Hendriks	NL
Van Leeuwen	Van Leeuwen	NL
Vos	Vos	NL
Peters	Peters	NL
Bos	Bos	NL
Mulder	Mulder	NL
De Groot	De Groot	NL
De Boer	De Boer	NL
Meijer	Meijer	NL
Meyer	Meyer	NL
Visser	Visser	NL
Janssen	Janssen	NL
Van Dijk	Van Dijk	NL
Van Dyk	Van Dyk	NL
Bakker	Bakker	NL
Van den Berg	Van den Berg	NL
De Vries	De Vries	NL
Jansen	Jansen	NL
De Jong	De Jong	NL
García	Garcia	SP
Fernández	Fernandez	SP
González	Gonzalez	SP
Rodríguez	Rodriguez	SP
López	Lopez	SP
Martínez	Martinez	SP
Sánchez	Sanchez	SP
Pérez	Perez	SP
Martín	Martin	SP
Gómez	Gomez	SP
Ruiz	Ruiz	SP
Hernández	Hernandez	SP
Jiménez	Jimenez	SP
Díaz	Diaz	SP
Álvarez	Alvarez	SP
Moreno	Moreno	SP
Muñoz	Munoz	SP
Alonso	Alonso	SP
Gutiérrez	Gutierrez	SP
Romero	Romero	SP
Navarro	Navarro	SP
Torres	Torres	SP
Domínguez	Dominguez	SP
Gil	Gil	SP
Vázquez	Vazquez	SP
Serrano	Serrano	SP
Ramos	Ramos	SP
Blanco	Blanco	SP
Sanz	Sanz	SP
Castro	Castro	SP
Suárez	Suarez	SP
Ortega	Ortega	SP
Rubio	Rubio	SP
Molina	Molina	SP
Delgado	Delgado	SP
Ramírez	Ramirez	SP
Morales	Morales	SP
Ortiz	Ortiz	SP
Marín	Marin	SP
Iglesias	Iglesias	SP
Müller	Muller	DE
Schmidt	Schmidt	DE
Schneider	Schneider	DE
Fischer	Fischer	DE
Meyer	Meyer	DE
Weber	Weber	DE
Wagner	Wagner	DE
Schulz	Schulz	DE
Becker	Becker	DE
Hoffmann	Hoffmann	DE#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'EU6_FAMILY_NAMES_217', p_set_type=>'CSV', p_params=>my_clob, p_system_flag=>'Y');
   UPDATE ds_data_sets
      SET col_names_row = 1  -- column names at row 1
        , col_types_row = 2  -- column names at row 2
        , col_sep_char = CHR(9) -- column separator is TAB
    WHERE set_id = l_set_id
   ;
   COMMIT;
   dbms_lob.freetemporary(my_clob);
END;
/
