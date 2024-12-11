update ds_data_sets
   set system_flag='Y'
 where set_name in (
	  'COLORS','EU6_FAMILY_NAMES_217','EU_COUNTRIES_27'
	 ,'EU_MAJOR_CITIES_590','FOOD','INT_COUNTRIES_250'
	 ,'INT_CURRENCIES_170','INT_GIVEN_NAMES_250', 'FOOD'
	);
commit;
