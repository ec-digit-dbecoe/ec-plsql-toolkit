REM Source: Generated with ChatGPT
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#NAME	TYPE
C(30)	C(20)
Acai	Brazilian
Adobo	Filipino
Arepas	Colombian
Avocado	Latin American
Baklava	Middle Eastern
Banana Bread	American
Banoffee Pie	British
Baozi	Chinese
Bibimbap	Korean
Birria	Mexican
Borscht	Russian
Bratwurst	German
Brioche	French
Burgers	American
Cannoli	Italian
Cassoulet	French
Ceviche	Peruvian
Chana Masala	Indian
Chilaquiles	Mexican
Chimichurri	Argentinian
Chole Bhature	Indian
Chow Mein	Chinese
Coq au Vin	French
Couscous	Middle Eastern
Crepes	French
Croissant	French
Curry	Indian
Dal Makhani	Indian
Dumplings	Chinese
Empanadas	Latin American
Enchiladas	Mexican
Falafel	Middle Eastern
Fajitas	Mexican
Fufu	African
Goulash	Hungarian
Gyoza	Japanese
Haggis	Scottish
Hainanese Chicken Rice	Singaporean
Hamburger	American
Hot Dog	American
Hummus	Middle Eastern
Jerk Chicken	Jamaican
Jiaozi	Chinese
Kebab	Middle Eastern
Kimchi	Korean
Lasagna	Italian
Lomo Saltado	Peruvian
Maki Roll	Japanese
Mango Sticky Rice	Thai
Moussaka	Greek
Naan	Indian
Nachos	Mexican
Nasi Goreng	Indonesian
Pad Thai	Thai
Paella	Spanish
Pancakes	American
Pasta	Italian
Peking Duck	Chinese
Pho	Vietnamese
Pizza	Italian
Poke Bowl	Hawaiian
Poutine	Canadian
Quesadilla	Mexican
Ramen	Japanese
Ratatouille	French
Ravioli	Italian
Rendang	Indonesian
Risotto	Italian
Samosa	Indian
Sauerbraten	German
Schnitzel	Austrian
Shakshuka	Middle Eastern
Shepherd's Pie	British
Soba	Japanese
Som Tam	Thai
Soto	Indonesian
Sushi	Japanese
Tacos	Mexican
Tempura	Japanese
Tikka Masala	Indian
Tiramisu	Italian
Tofu	Japanese
Tom Yum	Thai
Tortilla de Patata	Spanish
Tortillas	Mexican
Varenyky	Ukrainian
Waffles	Belgian
Wiener Schnitzel	Austrian
Xiao Long Bao	Chinese
Yakisoba	Japanese
Yakitori	Japanese
Yams	African
Yellow Curry	Thai
Yogurt	Greek
Zopf	Swiss
Pad See Ew	Thai
Pani Puri	Indian
Pastel de Choclo	Chilean
Pavlova	Australian
Pierogi	Polish
Pita	Middle Eastern
Poke	Hawaiian
Pozole	Mexican
Pretzel	German
Pulled Pork	American
Pupusa	Salvadoran
Ratatouille	French
Red Curry	Thai
Risotto	Italian
Samosa	Indian
Sarma	Turkish
Sashimi	Japanese
Satay	Indonesian
Scotch Egg	British
Shawarma	Middle Eastern
Shrimp and Grits	American
Smørrebrød	Danish
Soul Food	American
Sourdough Bread	American
Spring Rolls	Vietnamese
Stroganoff	Russian
Surf and Turf	American
Sushi	Japanese
Sushi Burrito	Japanese
Swiss Roll	Swiss
Taco	Mexican
Tajine	Moroccan
Tamales	Mexican
Tandoori Chicken	Indian
Tapenade	French
Tapas	Spanish
Tiramisu	Italian
Tonkatsu	Japanese
Tortilla Soup	Mexican
Truffle	European
Tzatziki	Greek
Udon	Japanese
Vada Pav	Indian
Vanilla Slice	Australian
Vegetable Tempura	Japanese
Vegemite on Toast	Australian
Vietnamese Pho	Vietnamese
Wagyu Beef	Japanese
Walnut Bread	American
Wonton Soup	Chinese
Xiao Long Bao	Chinese
Yakitori	Japanese
Yule Log	French
Yuzu	Japanese
Zabaione	Italian
Zongzi	Chinese#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'FOOD', p_set_type=>'CSV', p_params=>my_clob);
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
