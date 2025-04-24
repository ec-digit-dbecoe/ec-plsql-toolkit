REM 
REM Data Set Utility Demo - Sample data set for TDE demo
REM All rights reserved (C)opyright 2025 by Philippe Debois
REM 

/*
-- Data set extracted using the following code
declare
   l_set_id ds_data_sets.set_id%TYPE;
begin
   ds_utility_krn.set_message_filter('EWI');
   ds_utility_ext.execute_degpl(p_commit=>TRUE,p_code=>q'£
   set demo_data_sub/r[set_type=SUB];
   demo*;sto/f;cnt/f;cct/f;oet/f;per/b[where="manager_flag='Y'"]=<0*;oen/b[where="oet_cd='INST'"]=<0*;!*^>-0*;
   £');
   l_set_id := ds_utility_krn.get_data_set_def_by_name('DEMO_DATA_SUB');
   ds_utility_krn.count_table_records(p_set_id=>l_set_id);
   ds_utility_krn.extract_data_set(l_set_id,p_final_commit=>TRUE);
end;
/
*/

INSERT INTO demo_countries_tde (cnt_cd, cnt_name, population)
SELECT 'AUT' cnt_cd, 'Austria' cnt_name, 9104772 population FROM dual
UNION ALL SELECT 'BEL', 'Belgium', 11754004 FROM dual
UNION ALL SELECT 'BGR', 'Bulgaria', 6447710 FROM dual
UNION ALL SELECT 'HRV', 'Croatia', 3850894 FROM dual
UNION ALL SELECT 'CYP', 'Cyprus', 920701 FROM dual
UNION ALL SELECT 'CZE', 'Czechia', 10827529 FROM dual
UNION ALL SELECT 'DNK', 'Denmark', 5932654 FROM dual
UNION ALL SELECT 'EST', 'Estonia', 1365884 FROM dual
UNION ALL SELECT 'FIN', 'Finland', 5563970 FROM dual
UNION ALL SELECT 'FRA', 'France', 68070697 FROM dual
UNION ALL SELECT 'DEU', 'Germany', 84358845 FROM dual
UNION ALL SELECT 'GRC', 'Greece', 10394055 FROM dual
UNION ALL SELECT 'HUN', 'Hungary', 9597085 FROM dual
UNION ALL SELECT 'IRL', 'Ireland', 5194336 FROM dual
UNION ALL SELECT 'ITA', 'Italy', 58850717 FROM dual
UNION ALL SELECT 'LVA', 'Latvia', 1883008 FROM dual
UNION ALL SELECT 'LTU', 'Lithuania', 2857279 FROM dual
UNION ALL SELECT 'LUX', 'Luxembourg', 660809 FROM dual
UNION ALL SELECT 'MLT', 'Malta', 542051 FROM dual
UNION ALL SELECT 'NLD', 'Netherlands (the)', 17811291 FROM dual
UNION ALL SELECT 'POL', 'Poland', 36753736 FROM dual
UNION ALL SELECT 'PRT', 'Portugal', 10467366 FROM dual
UNION ALL SELECT 'ROU', 'Romania', 19051562 FROM dual
UNION ALL SELECT 'SVK', 'Slovakia', 5428792 FROM dual
UNION ALL SELECT 'SVN', 'Slovenia', 2116792 FROM dual
UNION ALL SELECT 'ESP', 'Spain', 48059777 FROM dual
UNION ALL SELECT 'SWE', 'Sweden', 10521556 FROM dual
;
INSERT INTO demo_credit_card_types_tde (cct_cd, cct_name)
SELECT '3' cct_cd, 'American Express' cct_name FROM dual
UNION ALL SELECT '4', 'Visa' FROM dual
UNION ALL SELECT '5', 'Mastercard' FROM dual
UNION ALL SELECT '6011', 'Discover' FROM dual
;
INSERT INTO demo_org_entity_types_tde (oet_cd, oet_name, oet_level)
SELECT 'INST' oet_cd, 'Institution' oet_name, 1 oet_level FROM dual
UNION ALL SELECT 'DG', 'Directorate General', 2 FROM dual
UNION ALL SELECT 'DIR', 'Directorate', 3 FROM dual
UNION ALL SELECT 'UNIT', 'Unit', 4 FROM dual
UNION ALL SELECT 'SECT', 'Sector', 5 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 1 oen_id, 'LIRILE' oen_cd, 'Amber Pita' oen_name, 'INST' oet_cd, NULL oen_id_parent FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 2 oen_id, 'SONIRI' oen_cd, 'Lavender Purple Vegemite on Toast' oen_name, 'DG' oet_cd, 1 oen_id_parent FROM dual
UNION ALL SELECT 3, 'BODALE', 'Wine Tacos', 'DG', 1 FROM dual
UNION ALL SELECT 4, 'PILEFE', 'Frost Rendang', 'DG', 1 FROM dual
UNION ALL SELECT 5, 'DEPIBU', 'Powder Pink Sashimi', 'DG', 1 FROM dual
UNION ALL SELECT 6, 'BAGETU', 'Electric Green Sauerbraten', 'DG', 1 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 7 oen_id, 'SONIRI.A' oen_cd, 'Pumpkin Fufu' oen_name, 'DIR' oet_cd, 2 oen_id_parent FROM dual
UNION ALL SELECT 8, 'SONIRI.B', 'Indigo Vanilla Slice', 'DIR', 2 FROM dual
UNION ALL SELECT 9, 'SONIRI.C', 'Powder Blue Pupusa', 'DIR', 2 FROM dual
UNION ALL SELECT 10, 'SONIRI.D', 'Violet Tapenade', 'DIR', 2 FROM dual
UNION ALL SELECT 11, 'BODALE.A', 'Blue Dal Makhani', 'DIR', 3 FROM dual
UNION ALL SELECT 12, 'BODALE.B', 'Azure Pastel de Choclo', 'DIR', 3 FROM dual
UNION ALL SELECT 13, 'BODALE.C', 'Wine Jerk Chicken', 'DIR', 3 FROM dual
UNION ALL SELECT 14, 'BODALE.D', 'Tangerine Vietnamese Pho', 'DIR', 3 FROM dual
UNION ALL SELECT 15, 'PILEFE.A', 'Rust Sauerbraten', 'DIR', 4 FROM dual
UNION ALL SELECT 16, 'PILEFE.B', 'Ivory Chana Masala', 'DIR', 4 FROM dual
UNION ALL SELECT 17, 'PILEFE.C', 'Pine Green Pavlova', 'DIR', 4 FROM dual
UNION ALL SELECT 18, 'PILEFE.D', 'Denim Ravioli', 'DIR', 4 FROM dual
UNION ALL SELECT 19, 'PILEFE.E', 'Mustard Zongzi', 'DIR', 4 FROM dual
UNION ALL SELECT 20, 'PILEFE.F', 'Ash Grey Shrimp and Grits', 'DIR', 4 FROM dual
UNION ALL SELECT 21, 'DEPIBU.A', 'Turquoise Green Sushi', 'DIR', 5 FROM dual
UNION ALL SELECT 22, 'DEPIBU.B', 'Rust Pad Thai', 'DIR', 5 FROM dual
UNION ALL SELECT 23, 'DEPIBU.C', 'Caramel Udon', 'DIR', 5 FROM dual
UNION ALL SELECT 24, 'DEPIBU.D', 'Burnt Umber Tofu', 'DIR', 5 FROM dual
UNION ALL SELECT 25, 'DEPIBU.E', 'Peacock Blue Chimichurri', 'DIR', 5 FROM dual
UNION ALL SELECT 26, 'BAGETU.A', 'Salmon Pho', 'DIR', 6 FROM dual
UNION ALL SELECT 27, 'BAGETU.B', 'Charcoal Grey Mango Sticky Rice', 'DIR', 6 FROM dual
UNION ALL SELECT 28, 'BAGETU.C', 'Beige White Jiaozi', 'DIR', 6 FROM dual
UNION ALL SELECT 29, 'BAGETU.D', 'Blue Pierogi', 'DIR', 6 FROM dual
UNION ALL SELECT 30, 'BAGETU.E', 'Frost Risotto', 'DIR', 6 FROM dual
UNION ALL SELECT 31, 'BAGETU.F', 'Olive Green Adobo', 'DIR', 6 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 32 oen_id, 'SONIRI.A.1' oen_cd, 'Pine Green Vietnamese Pho' oen_name, 'UNIT' oet_cd, 7 oen_id_parent FROM dual
UNION ALL SELECT 33, 'SONIRI.A.2', 'Tangerine Risotto', 'UNIT', 7 FROM dual
UNION ALL SELECT 34, 'SONIRI.A.3', 'Lemon Yellow Xiao Long Bao', 'UNIT', 7 FROM dual
UNION ALL SELECT 35, 'SONIRI.A.4', 'Sienna Pavlova', 'UNIT', 7 FROM dual
UNION ALL SELECT 36, 'SONIRI.A.5', 'Slate Grey Tiramisu', 'UNIT', 7 FROM dual
UNION ALL SELECT 37, 'SONIRI.A.6', 'Cream Tortilla de Patata', 'UNIT', 7 FROM dual
UNION ALL SELECT 38, 'SONIRI.B.1', 'Sienna Tempura', 'UNIT', 8 FROM dual
UNION ALL SELECT 39, 'SONIRI.B.2', 'Azure Surf and Turf', 'UNIT', 8 FROM dual
UNION ALL SELECT 40, 'SONIRI.B.3', 'Lime Green Tamales', 'UNIT', 8 FROM dual
UNION ALL SELECT 41, 'SONIRI.B.4', 'Peacock Rendang', 'UNIT', 8 FROM dual
UNION ALL SELECT 42, 'SONIRI.C.1', 'Topaz Quesadilla', 'UNIT', 9 FROM dual
UNION ALL SELECT 43, 'SONIRI.C.2', 'Baby Pink Udon', 'UNIT', 9 FROM dual
UNION ALL SELECT 44, 'SONIRI.C.3', 'Rose Zopf', 'UNIT', 9 FROM dual
UNION ALL SELECT 45, 'SONIRI.C.4', 'Sapphire Yakisoba', 'UNIT', 9 FROM dual
UNION ALL SELECT 46, 'SONIRI.C.5', 'Tomato Red Couscous', 'UNIT', 9 FROM dual
UNION ALL SELECT 47, 'SONIRI.C.6', 'Powder Pink Hot Dog', 'UNIT', 9 FROM dual
UNION ALL SELECT 48, 'SONIRI.D.1', 'Heather Smørrebrød', 'UNIT', 10 FROM dual
UNION ALL SELECT 49, 'SONIRI.D.2', 'Gold Hot Dog', 'UNIT', 10 FROM dual
UNION ALL SELECT 50, 'SONIRI.D.3', 'Wine Tempura', 'UNIT', 10 FROM dual
UNION ALL SELECT 51, 'SONIRI.D.4', 'Amber Vietnamese Pho', 'UNIT', 10 FROM dual
UNION ALL SELECT 52, 'SONIRI.D.5', 'Honey Chow Mein', 'UNIT', 10 FROM dual
UNION ALL SELECT 53, 'SONIRI.D.6', 'Periwinkle Nasi Goreng', 'UNIT', 10 FROM dual
UNION ALL SELECT 54, 'BODALE.A.1', 'Bronze Empanadas', 'UNIT', 11 FROM dual
UNION ALL SELECT 55, 'BODALE.A.2', 'Electric Green Arepas', 'UNIT', 11 FROM dual
UNION ALL SELECT 56, 'BODALE.A.3', 'Sandstone Udon', 'UNIT', 11 FROM dual
UNION ALL SELECT 57, 'BODALE.A.4', 'Ice Blue Sashimi', 'UNIT', 11 FROM dual
UNION ALL SELECT 58, 'BODALE.A.5', 'Slate Yogurt', 'UNIT', 11 FROM dual
UNION ALL SELECT 59, 'BODALE.A.6', 'Forest Green Gyoza', 'UNIT', 11 FROM dual
UNION ALL SELECT 60, 'BODALE.B.1', 'Salmon Sushi', 'UNIT', 12 FROM dual
UNION ALL SELECT 61, 'BODALE.B.2', 'Mocha Spring Rolls', 'UNIT', 12 FROM dual
UNION ALL SELECT 62, 'BODALE.B.3', 'Burnt Orange Vegetable Tempura', 'UNIT', 12 FROM dual
UNION ALL SELECT 63, 'BODALE.B.4', 'Turquoise Curry', 'UNIT', 12 FROM dual
UNION ALL SELECT 64, 'BODALE.C.1', 'Ash Grey Mango Sticky Rice', 'UNIT', 13 FROM dual
UNION ALL SELECT 65, 'BODALE.C.2', 'Marigold Sourdough Bread', 'UNIT', 13 FROM dual
UNION ALL SELECT 66, 'BODALE.C.3', 'Wine Wiener Schnitzel', 'UNIT', 13 FROM dual
UNION ALL SELECT 67, 'BODALE.C.4', 'Indigo Jiaozi', 'UNIT', 13 FROM dual
UNION ALL SELECT 68, 'BODALE.C.5', 'Forest Green Goulash', 'UNIT', 13 FROM dual
UNION ALL SELECT 69, 'BODALE.C.6', 'Baby Purple Banana Bread', 'UNIT', 13 FROM dual
UNION ALL SELECT 70, 'BODALE.D.1', 'Moss Green Som Tam', 'UNIT', 14 FROM dual
UNION ALL SELECT 71, 'BODALE.D.2', 'Electric Blue Tzatziki', 'UNIT', 14 FROM dual
UNION ALL SELECT 72, 'BODALE.D.3', 'Midnight Blue Tonkatsu', 'UNIT', 14 FROM dual
UNION ALL SELECT 73, 'BODALE.D.4', 'Corn Yellow Yakitori', 'UNIT', 14 FROM dual
UNION ALL SELECT 74, 'BODALE.D.5', 'Turquoise Blue Ceviche', 'UNIT', 14 FROM dual
UNION ALL SELECT 75, 'PILEFE.A.1', 'Midnight Blue Lomo Saltado', 'UNIT', 15 FROM dual
UNION ALL SELECT 76, 'PILEFE.A.2', 'Burnt Umber Tapenade', 'UNIT', 15 FROM dual
UNION ALL SELECT 77, 'PILEFE.A.3', 'Electric Blue Maki Roll', 'UNIT', 15 FROM dual
UNION ALL SELECT 78, 'PILEFE.A.4', 'Jade Pizza', 'UNIT', 15 FROM dual
UNION ALL SELECT 79, 'PILEFE.B.1', 'Persimmon Yuzu', 'UNIT', 16 FROM dual
UNION ALL SELECT 80, 'PILEFE.B.2', 'Eggplant Yakitori', 'UNIT', 16 FROM dual
UNION ALL SELECT 81, 'PILEFE.B.3', 'Burgundy Red Dal Makhani', 'UNIT', 16 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 82 oen_id, 'PILEFE.B.4' oen_cd, 'Ruby Yakitori' oen_name, 'UNIT' oet_cd, 16 oen_id_parent FROM dual
UNION ALL SELECT 83, 'PILEFE.C.1', 'Pink Yuzu', 'UNIT', 17 FROM dual
UNION ALL SELECT 84, 'PILEFE.C.2', 'Sapphire Blue Poke', 'UNIT', 17 FROM dual
UNION ALL SELECT 85, 'PILEFE.C.3', 'Azure Red Curry', 'UNIT', 17 FROM dual
UNION ALL SELECT 86, 'PILEFE.C.4', 'Ash Grey Poke', 'UNIT', 17 FROM dual
UNION ALL SELECT 87, 'PILEFE.C.5', 'Lavender Tikka Masala', 'UNIT', 17 FROM dual
UNION ALL SELECT 88, 'PILEFE.C.6', 'Sunflower Yellow Kebab', 'UNIT', 17 FROM dual
UNION ALL SELECT 89, 'PILEFE.D.1', 'Olive Zopf', 'UNIT', 18 FROM dual
UNION ALL SELECT 90, 'PILEFE.D.2', 'Powder Pink Pastel de Choclo', 'UNIT', 18 FROM dual
UNION ALL SELECT 91, 'PILEFE.D.3', 'Eggplant Tzatziki', 'UNIT', 18 FROM dual
UNION ALL SELECT 92, 'PILEFE.D.4', 'Sea Green Pozole', 'UNIT', 18 FROM dual
UNION ALL SELECT 93, 'PILEFE.D.5', 'Papaya Tapas', 'UNIT', 18 FROM dual
UNION ALL SELECT 94, 'PILEFE.D.6', 'Baby Green Nachos', 'UNIT', 18 FROM dual
UNION ALL SELECT 95, 'PILEFE.E.1', 'Rose Poke', 'UNIT', 19 FROM dual
UNION ALL SELECT 96, 'PILEFE.E.2', 'Aquamarine Tiramisu', 'UNIT', 19 FROM dual
UNION ALL SELECT 97, 'PILEFE.E.3', 'Lemon Lime Tiramisu', 'UNIT', 19 FROM dual
UNION ALL SELECT 98, 'PILEFE.E.4', 'Coral Pink Peking Duck', 'UNIT', 19 FROM dual
UNION ALL SELECT 99, 'PILEFE.F.1', 'Burnt Sienna Soul Food', 'UNIT', 20 FROM dual
UNION ALL SELECT 100, 'PILEFE.F.2', 'Navy Blue Yuzu', 'UNIT', 20 FROM dual
UNION ALL SELECT 101, 'PILEFE.F.3', 'Peacock Peking Duck', 'UNIT', 20 FROM dual
UNION ALL SELECT 102, 'PILEFE.F.4', 'Charcoal Grey Yakitori', 'UNIT', 20 FROM dual
UNION ALL SELECT 103, 'PILEFE.F.5', 'Cream Yakitori', 'UNIT', 20 FROM dual
UNION ALL SELECT 104, 'DEPIBU.A.1', 'Eggshell Pad See Ew', 'UNIT', 21 FROM dual
UNION ALL SELECT 105, 'DEPIBU.A.2', 'Peacock Blue Som Tam', 'UNIT', 21 FROM dual
UNION ALL SELECT 106, 'DEPIBU.A.3', 'Violet Tapenade', 'UNIT', 21 FROM dual
UNION ALL SELECT 107, 'DEPIBU.A.4', 'Eggshell Tajine', 'UNIT', 21 FROM dual
UNION ALL SELECT 108, 'DEPIBU.A.5', 'Apricot Zabaione', 'UNIT', 21 FROM dual
UNION ALL SELECT 109, 'DEPIBU.A.6', 'Chocolate Brown Soba', 'UNIT', 21 FROM dual
UNION ALL SELECT 110, 'DEPIBU.B.1', 'Beige White Wiener Schnitzel', 'UNIT', 22 FROM dual
UNION ALL SELECT 111, 'DEPIBU.B.2', 'Maroon Falafel', 'UNIT', 22 FROM dual
UNION ALL SELECT 112, 'DEPIBU.B.3', 'Pink Udon', 'UNIT', 22 FROM dual
UNION ALL SELECT 113, 'DEPIBU.B.4', 'Maroon Red Schnitzel', 'UNIT', 22 FROM dual
UNION ALL SELECT 114, 'DEPIBU.B.5', 'Periwinkle Chole Bhature', 'UNIT', 22 FROM dual
UNION ALL SELECT 115, 'DEPIBU.C.1', 'Cyan Blue Baklava', 'UNIT', 23 FROM dual
UNION ALL SELECT 116, 'DEPIBU.C.2', 'Maroon Red Som Tam', 'UNIT', 23 FROM dual
UNION ALL SELECT 117, 'DEPIBU.C.3', 'Avocado Pastel de Choclo', 'UNIT', 23 FROM dual
UNION ALL SELECT 118, 'DEPIBU.C.4', 'Lemon Yellow Curry', 'UNIT', 23 FROM dual
UNION ALL SELECT 119, 'DEPIBU.C.5', 'Rose Wagyu Beef', 'UNIT', 23 FROM dual
UNION ALL SELECT 120, 'DEPIBU.D.1', 'Powder Blue Tikka Masala', 'UNIT', 24 FROM dual
UNION ALL SELECT 121, 'DEPIBU.D.2', 'Gold Ratatouille', 'UNIT', 24 FROM dual
UNION ALL SELECT 122, 'DEPIBU.D.3', 'Lilac Purple Tikka Masala', 'UNIT', 24 FROM dual
UNION ALL SELECT 123, 'DEPIBU.D.4', 'Lemon Lime Tiramisu', 'UNIT', 24 FROM dual
UNION ALL SELECT 124, 'DEPIBU.D.5', 'Violet Kebab', 'UNIT', 24 FROM dual
UNION ALL SELECT 125, 'DEPIBU.D.6', 'Grass Green Borscht', 'UNIT', 24 FROM dual
UNION ALL SELECT 126, 'DEPIBU.E.1', 'Cream Kebab', 'UNIT', 25 FROM dual
UNION ALL SELECT 127, 'DEPIBU.E.2', 'Rose Pink Birria', 'UNIT', 25 FROM dual
UNION ALL SELECT 128, 'DEPIBU.E.3', 'Sunflower Yellow Cassoulet', 'UNIT', 25 FROM dual
UNION ALL SELECT 129, 'DEPIBU.E.4', 'Lime Green Xiao Long Bao', 'UNIT', 25 FROM dual
UNION ALL SELECT 130, 'BAGETU.A.1', 'Black Yuzu', 'UNIT', 26 FROM dual
UNION ALL SELECT 131, 'BAGETU.A.2', 'Apricot Soto', 'UNIT', 26 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 132 oen_id, 'BAGETU.A.3' oen_cd, 'Sapphire Adobo' oen_name, 'UNIT' oet_cd, 26 oen_id_parent FROM dual
UNION ALL SELECT 133, 'BAGETU.A.4', 'Rust Vietnamese Pho', 'UNIT', 26 FROM dual
UNION ALL SELECT 134, 'BAGETU.A.5', 'Turquoise Crepes', 'UNIT', 26 FROM dual
UNION ALL SELECT 135, 'BAGETU.B.1', 'Lemon Yellow Kebab', 'UNIT', 27 FROM dual
UNION ALL SELECT 136, 'BAGETU.B.2', 'Wine Sashimi', 'UNIT', 27 FROM dual
UNION ALL SELECT 137, 'BAGETU.B.3', 'Beige White Soul Food', 'UNIT', 27 FROM dual
UNION ALL SELECT 138, 'BAGETU.B.4', 'Lilac Scotch Egg', 'UNIT', 27 FROM dual
UNION ALL SELECT 139, 'BAGETU.B.5', 'Wine Red Falafel', 'UNIT', 27 FROM dual
UNION ALL SELECT 140, 'BAGETU.B.6', 'Sea Green Tofu', 'UNIT', 27 FROM dual
UNION ALL SELECT 141, 'BAGETU.C.1', 'Coral Tortillas', 'UNIT', 28 FROM dual
UNION ALL SELECT 142, 'BAGETU.C.2', 'Turquoise Blue Satay', 'UNIT', 28 FROM dual
UNION ALL SELECT 143, 'BAGETU.C.3', 'Turquoise Blue Shrimp and Grits', 'UNIT', 28 FROM dual
UNION ALL SELECT 144, 'BAGETU.C.4', 'Heather Birria', 'UNIT', 28 FROM dual
UNION ALL SELECT 145, 'BAGETU.D.1', 'Raspberry Baklava', 'UNIT', 29 FROM dual
UNION ALL SELECT 146, 'BAGETU.D.2', 'Brick Risotto', 'UNIT', 29 FROM dual
UNION ALL SELECT 147, 'BAGETU.D.3', 'Chocolate Brown Schnitzel', 'UNIT', 29 FROM dual
UNION ALL SELECT 148, 'BAGETU.D.4', 'Ivory White Banana Bread', 'UNIT', 29 FROM dual
UNION ALL SELECT 149, 'BAGETU.D.5', 'Silver Scotch Egg', 'UNIT', 29 FROM dual
UNION ALL SELECT 150, 'BAGETU.D.6', 'Pine Green Bibimbap', 'UNIT', 29 FROM dual
UNION ALL SELECT 151, 'BAGETU.E.1', 'Honey Borscht', 'UNIT', 30 FROM dual
UNION ALL SELECT 152, 'BAGETU.E.2', 'Burnt Umber Sushi Burrito', 'UNIT', 30 FROM dual
UNION ALL SELECT 153, 'BAGETU.E.3', 'Strawberry Maki Roll', 'UNIT', 30 FROM dual
UNION ALL SELECT 154, 'BAGETU.E.4', 'Dark Green Chimichurri', 'UNIT', 30 FROM dual
UNION ALL SELECT 155, 'BAGETU.E.5', 'White Nasi Goreng', 'UNIT', 30 FROM dual
UNION ALL SELECT 156, 'BAGETU.E.6', 'Mustard Yule Log', 'UNIT', 30 FROM dual
UNION ALL SELECT 157, 'BAGETU.F.1', 'Ruby Red Soul Food', 'UNIT', 31 FROM dual
UNION ALL SELECT 158, 'BAGETU.F.2', 'Beige White Acai', 'UNIT', 31 FROM dual
UNION ALL SELECT 159, 'BAGETU.F.3', 'Pink Tapenade', 'UNIT', 31 FROM dual
UNION ALL SELECT 160, 'BAGETU.F.4', 'Tan Yakisoba', 'UNIT', 31 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 301 oen_id, 'SONIRI.C.6.002' oen_cd, 'Burnt Sienna Nasi Goreng' oen_name, 'SECT' oet_cd, 47 oen_id_parent FROM dual
UNION ALL SELECT 302, 'SONIRI.C.6.003', 'Lavender Purple Smørrebrød', 'SECT', 47 FROM dual
UNION ALL SELECT 303, 'SONIRI.C.6.004', 'Navy Blue Paella', 'SECT', 47 FROM dual
UNION ALL SELECT 304, 'SONIRI.C.6.005', 'Cornflower Blue Tiramisu', 'SECT', 47 FROM dual
UNION ALL SELECT 305, 'SONIRI.C.6.006', 'Mint Banoffee Pie', 'SECT', 47 FROM dual
UNION ALL SELECT 306, 'SONIRI.D.1.001', 'Brick Red Baklava', 'SECT', 48 FROM dual
UNION ALL SELECT 307, 'SONIRI.D.1.002', 'Slate Birria', 'SECT', 48 FROM dual
UNION ALL SELECT 308, 'SONIRI.D.1.003', 'Turquoise Green Pasta', 'SECT', 48 FROM dual
UNION ALL SELECT 309, 'SONIRI.D.1.004', 'Rose Nasi Goreng', 'SECT', 48 FROM dual
UNION ALL SELECT 310, 'SONIRI.D.2.001', 'Baby Purple Swiss Roll', 'SECT', 49 FROM dual
UNION ALL SELECT 311, 'SONIRI.D.2.002', 'Sapphire Tzatziki', 'SECT', 49 FROM dual
UNION ALL SELECT 312, 'SONIRI.D.2.003', 'Strawberry Sushi Burrito', 'SECT', 49 FROM dual
UNION ALL SELECT 313, 'SONIRI.D.2.004', 'Sienna Avocado', 'SECT', 49 FROM dual
UNION ALL SELECT 314, 'SONIRI.D.3.001', 'Pewter Soto', 'SECT', 50 FROM dual
UNION ALL SELECT 315, 'SONIRI.D.3.002', 'Ivory Banoffee Pie', 'SECT', 50 FROM dual
UNION ALL SELECT 316, 'SONIRI.D.3.003', 'Sapphire Blue Pierogi', 'SECT', 50 FROM dual
UNION ALL SELECT 317, 'SONIRI.D.3.004', 'Sea Blue Samosa', 'SECT', 50 FROM dual
UNION ALL SELECT 318, 'SONIRI.D.4.001', 'Beige Goulash', 'SECT', 51 FROM dual
UNION ALL SELECT 319, 'SONIRI.D.4.002', 'Lemon Yellow Jerk Chicken', 'SECT', 51 FROM dual
UNION ALL SELECT 320, 'SONIRI.D.4.003', 'Teal Pozole', 'SECT', 51 FROM dual
UNION ALL SELECT 321, 'SONIRI.D.4.004', 'Avocado Wagyu Beef', 'SECT', 51 FROM dual
UNION ALL SELECT 322, 'SONIRI.D.5.001', 'Indigo Ratatouille', 'SECT', 52 FROM dual
UNION ALL SELECT 323, 'SONIRI.D.5.002', 'Rose Pink Adobo', 'SECT', 52 FROM dual
UNION ALL SELECT 324, 'SONIRI.D.5.003', 'Wine Red Yogurt', 'SECT', 52 FROM dual
UNION ALL SELECT 325, 'SONIRI.D.5.004', 'Navy Vietnamese Pho', 'SECT', 52 FROM dual
UNION ALL SELECT 326, 'DEPIBU.E.2.001', 'Burgundy Red Hot Dog', 'SECT', 127 FROM dual
UNION ALL SELECT 327, 'DEPIBU.E.2.002', 'Sea Blue Shrimp and Grits', 'SECT', 127 FROM dual
UNION ALL SELECT 328, 'DEPIBU.E.2.003', 'Almond Shawarma', 'SECT', 127 FROM dual
UNION ALL SELECT 329, 'DEPIBU.E.2.004', 'Tomato Red Varenyky', 'SECT', 127 FROM dual
UNION ALL SELECT 330, 'DEPIBU.E.3.001', 'White Vegetable Tempura', 'SECT', 128 FROM dual
UNION ALL SELECT 331, 'DEPIBU.E.3.002', 'Sand Xiao Long Bao', 'SECT', 128 FROM dual
UNION ALL SELECT 332, 'DEPIBU.E.3.003', 'Burgundy Red Dal Makhani', 'SECT', 128 FROM dual
UNION ALL SELECT 333, 'DEPIBU.E.3.004', 'Sky Blue Yule Log', 'SECT', 128 FROM dual
UNION ALL SELECT 334, 'DEPIBU.E.3.005', 'Cornflower Blue Stroganoff', 'SECT', 128 FROM dual
UNION ALL SELECT 335, 'DEPIBU.E.3.006', 'Burgundy Smørrebrød', 'SECT', 128 FROM dual
UNION ALL SELECT 336, 'DEPIBU.C.3.001', 'Denim Xiao Long Bao', 'SECT', 117 FROM dual
UNION ALL SELECT 337, 'DEPIBU.C.3.002', 'Mocha Taco', 'SECT', 117 FROM dual
UNION ALL SELECT 338, 'DEPIBU.C.3.003', 'Amber Sushi Burrito', 'SECT', 117 FROM dual
UNION ALL SELECT 339, 'DEPIBU.C.3.004', 'Charcoal Rendang', 'SECT', 117 FROM dual
UNION ALL SELECT 340, 'DEPIBU.C.3.005', 'Lemon Enchiladas', 'SECT', 117 FROM dual
UNION ALL SELECT 341, 'DEPIBU.C.3.006', 'Aquamarine Risotto', 'SECT', 117 FROM dual
UNION ALL SELECT 342, 'DEPIBU.C.4.001', 'Ruby Red Tonkatsu', 'SECT', 118 FROM dual
UNION ALL SELECT 343, 'DEPIBU.C.4.002', 'Aqua Spring Rolls', 'SECT', 118 FROM dual
UNION ALL SELECT 344, 'DEPIBU.C.4.003', 'Denim Hainanese Chicken Ri', 'SECT', 118 FROM dual
UNION ALL SELECT 345, 'DEPIBU.C.4.004', 'Sky Blue Ratatouille', 'SECT', 118 FROM dual
UNION ALL SELECT 346, 'DEPIBU.C.4.005', 'Apricot Ceviche', 'SECT', 118 FROM dual
UNION ALL SELECT 347, 'DEPIBU.C.5.001', 'Cobalt Blue Pretzel', 'SECT', 119 FROM dual
UNION ALL SELECT 348, 'DEPIBU.C.5.002', 'White Sushi', 'SECT', 119 FROM dual
UNION ALL SELECT 349, 'DEPIBU.C.5.003', 'Brown Pho', 'SECT', 119 FROM dual
UNION ALL SELECT 350, 'DEPIBU.C.5.004', 'Khaki Fufu', 'SECT', 119 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 351 oen_id, 'DEPIBU.D.1.001' oen_cd, 'Raspberry Burgers' oen_name, 'SECT' oet_cd, 120 oen_id_parent FROM dual
UNION ALL SELECT 352, 'DEPIBU.D.1.002', 'Seafoam Green Wiener Schnitzel', 'SECT', 120 FROM dual
UNION ALL SELECT 353, 'DEPIBU.D.1.003', 'Charcoal Grey Empanadas', 'SECT', 120 FROM dual
UNION ALL SELECT 354, 'DEPIBU.D.1.004', 'Honey Smørrebrød', 'SECT', 120 FROM dual
UNION ALL SELECT 355, 'DEPIBU.D.1.005', 'Steel Blue Ramen', 'SECT', 120 FROM dual
UNION ALL SELECT 356, 'DEPIBU.D.2.001', 'Magenta Tajine', 'SECT', 121 FROM dual
UNION ALL SELECT 357, 'DEPIBU.D.2.002', 'Celadon Yule Log', 'SECT', 121 FROM dual
UNION ALL SELECT 358, 'DEPIBU.D.2.003', 'Brick Goulash', 'SECT', 121 FROM dual
UNION ALL SELECT 359, 'DEPIBU.D.2.004', 'Baby Purple Goulash', 'SECT', 121 FROM dual
UNION ALL SELECT 360, 'DEPIBU.D.2.005', 'Burnt Umber Tonkatsu', 'SECT', 121 FROM dual
UNION ALL SELECT 361, 'DEPIBU.D.3.001', 'Maroon Red Hummus', 'SECT', 122 FROM dual
UNION ALL SELECT 362, 'DEPIBU.D.3.002', 'Maroon Pani Puri', 'SECT', 122 FROM dual
UNION ALL SELECT 363, 'DEPIBU.D.3.003', 'Burgundy Red Enchiladas', 'SECT', 122 FROM dual
UNION ALL SELECT 364, 'DEPIBU.D.3.004', 'Pearl Pierogi', 'SECT', 122 FROM dual
UNION ALL SELECT 365, 'DEPIBU.D.4.001', 'Tan Brown Chimichurri', 'SECT', 123 FROM dual
UNION ALL SELECT 366, 'DEPIBU.D.4.002', 'Corn Yellow Chole Bhature', 'SECT', 123 FROM dual
UNION ALL SELECT 367, 'DEPIBU.D.4.003', 'Turquoise Borscht', 'SECT', 123 FROM dual
UNION ALL SELECT 368, 'DEPIBU.D.4.004', 'Ivory White Varenyky', 'SECT', 123 FROM dual
UNION ALL SELECT 369, 'DEPIBU.D.5.001', 'Powder Blue Mango Sticky Rice', 'SECT', 124 FROM dual
UNION ALL SELECT 370, 'DEPIBU.D.5.002', 'Teal Tapas', 'SECT', 124 FROM dual
UNION ALL SELECT 371, 'DEPIBU.D.5.003', 'Eggplant Hainanese Chicken Ri', 'SECT', 124 FROM dual
UNION ALL SELECT 372, 'DEPIBU.D.5.004', 'Frost Vada Pav', 'SECT', 124 FROM dual
UNION ALL SELECT 373, 'DEPIBU.D.6.001', 'Aqua Blue Moussaka', 'SECT', 125 FROM dual
UNION ALL SELECT 374, 'DEPIBU.D.6.002', 'Cyan Tofu', 'SECT', 125 FROM dual
UNION ALL SELECT 375, 'DEPIBU.D.6.003', 'Rust Vada Pav', 'SECT', 125 FROM dual
UNION ALL SELECT 376, 'DEPIBU.D.6.004', 'Charcoal Samosa', 'SECT', 125 FROM dual
UNION ALL SELECT 377, 'DEPIBU.E.1.001', 'Sapphire Blue Taco', 'SECT', 126 FROM dual
UNION ALL SELECT 378, 'DEPIBU.E.1.002', 'Slate Grey Schnitzel', 'SECT', 126 FROM dual
UNION ALL SELECT 379, 'DEPIBU.E.1.003', 'Powder Blue Acai', 'SECT', 126 FROM dual
UNION ALL SELECT 380, 'DEPIBU.E.1.004', 'Powder Pink Yogurt', 'SECT', 126 FROM dual
UNION ALL SELECT 381, 'DEPIBU.E.1.005', 'Lavender Blue Vada Pav', 'SECT', 126 FROM dual
UNION ALL SELECT 382, 'DEPIBU.E.1.006', 'Peach Tom Yum', 'SECT', 126 FROM dual
UNION ALL SELECT 383, 'BODALE.C.2.001', 'Tan Ramen', 'SECT', 65 FROM dual
UNION ALL SELECT 384, 'BODALE.C.2.002', 'Bronze Baozi', 'SECT', 65 FROM dual
UNION ALL SELECT 385, 'BODALE.C.2.003', 'Burnt Umber Pasta', 'SECT', 65 FROM dual
UNION ALL SELECT 386, 'BODALE.C.2.004', 'Slate Grey Dal Makhani', 'SECT', 65 FROM dual
UNION ALL SELECT 387, 'BODALE.C.3.001', 'Powder Blue Som Tam', 'SECT', 66 FROM dual
UNION ALL SELECT 388, 'BODALE.C.3.002', 'Lilac Crepes', 'SECT', 66 FROM dual
UNION ALL SELECT 389, 'BODALE.C.3.003', 'Ivory Acai', 'SECT', 66 FROM dual
UNION ALL SELECT 390, 'BODALE.C.3.004', 'Beige Tapenade', 'SECT', 66 FROM dual
UNION ALL SELECT 391, 'BODALE.C.3.005', 'Chocolate Brown Vegetable Tempura', 'SECT', 66 FROM dual
UNION ALL SELECT 392, 'BODALE.C.4.001', 'Teal Green Tiramisu', 'SECT', 67 FROM dual
UNION ALL SELECT 393, 'BODALE.C.4.002', 'Coral Pink Croissant', 'SECT', 67 FROM dual
UNION ALL SELECT 394, 'BODALE.C.4.003', 'Forest Green Vietnamese Pho', 'SECT', 67 FROM dual
UNION ALL SELECT 395, 'BODALE.C.4.004', 'Frost Smørrebrød', 'SECT', 67 FROM dual
UNION ALL SELECT 396, 'BODALE.C.4.005', 'Tan Brown Spring Rolls', 'SECT', 67 FROM dual
UNION ALL SELECT 397, 'BODALE.C.4.006', 'Pewter Sushi', 'SECT', 67 FROM dual
UNION ALL SELECT 398, 'BODALE.C.5.001', 'Burnt Sienna Peking Duck', 'SECT', 68 FROM dual
UNION ALL SELECT 399, 'BODALE.C.5.002', 'Lemon Vada Pav', 'SECT', 68 FROM dual
UNION ALL SELECT 400, 'BODALE.C.5.003', 'Peach Cannoli', 'SECT', 68 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 401 oen_id, 'BODALE.C.5.004' oen_cd, 'Sapphire Blue Poke Bowl' oen_name, 'SECT' oet_cd, 68 oen_id_parent FROM dual
UNION ALL SELECT 402, 'BODALE.C.5.005', 'Lemon Lime Hamburger', 'SECT', 68 FROM dual
UNION ALL SELECT 403, 'BODALE.C.6.001', 'Corn Yellow Schnitzel', 'SECT', 69 FROM dual
UNION ALL SELECT 404, 'BODALE.C.6.002', 'Sandstone Tapas', 'SECT', 69 FROM dual
UNION ALL SELECT 405, 'BODALE.C.6.003', 'Sunflower Yellow Tofu', 'SECT', 69 FROM dual
UNION ALL SELECT 406, 'BODALE.C.6.004', 'Charcoal Taco', 'SECT', 69 FROM dual
UNION ALL SELECT 407, 'BODALE.C.6.005', 'Lilac Soul Food', 'SECT', 69 FROM dual
UNION ALL SELECT 408, 'BODALE.C.6.006', 'Lemon Lime Haggis', 'SECT', 69 FROM dual
UNION ALL SELECT 409, 'BODALE.D.1.001', 'Magenta Swiss Roll', 'SECT', 70 FROM dual
UNION ALL SELECT 410, 'BODALE.D.1.002', 'Baby Pink Crepes', 'SECT', 70 FROM dual
UNION ALL SELECT 411, 'BODALE.D.1.003', 'Maroon Zabaione', 'SECT', 70 FROM dual
UNION ALL SELECT 412, 'BODALE.D.1.004', 'Azure Tandoori Chicken', 'SECT', 70 FROM dual
UNION ALL SELECT 413, 'BODALE.D.1.005', 'Steel Blue Vegetable Tempura', 'SECT', 70 FROM dual
UNION ALL SELECT 414, 'BODALE.D.2.001', 'Wine Red Cannoli', 'SECT', 71 FROM dual
UNION ALL SELECT 415, 'BODALE.D.2.002', 'Strawberry Hamburger', 'SECT', 71 FROM dual
UNION ALL SELECT 416, 'BODALE.D.2.003', 'Powder Pink Dal Makhani', 'SECT', 71 FROM dual
UNION ALL SELECT 417, 'BODALE.D.2.004', 'Sandalwood Croissant', 'SECT', 71 FROM dual
UNION ALL SELECT 418, 'BODALE.D.3.001', 'Amber Baklava', 'SECT', 72 FROM dual
UNION ALL SELECT 419, 'BODALE.D.3.002', 'Coral Pink Shepherd''s Pie', 'SECT', 72 FROM dual
UNION ALL SELECT 420, 'BODALE.D.3.003', 'Mustard Yams', 'SECT', 72 FROM dual
UNION ALL SELECT 421, 'BODALE.D.3.004', 'Honey Varenyky', 'SECT', 72 FROM dual
UNION ALL SELECT 422, 'BODALE.D.3.005', 'Baby Purple Baozi', 'SECT', 72 FROM dual
UNION ALL SELECT 423, 'BODALE.D.4.001', 'Powder Blue Enchiladas', 'SECT', 73 FROM dual
UNION ALL SELECT 424, 'BODALE.D.4.002', 'Moss Green Bratwurst', 'SECT', 73 FROM dual
UNION ALL SELECT 425, 'BODALE.D.4.003', 'Beige Burgers', 'SECT', 73 FROM dual
UNION ALL SELECT 426, 'BODALE.D.4.004', 'Slate Blue Hainanese Chicken Ri', 'SECT', 73 FROM dual
UNION ALL SELECT 427, 'BODALE.D.4.005', 'Electric Purple Dal Makhani', 'SECT', 73 FROM dual
UNION ALL SELECT 428, 'BODALE.D.4.006', 'Avocado Haggis', 'SECT', 73 FROM dual
UNION ALL SELECT 429, 'BODALE.D.5.001', 'Pink Chilaquiles', 'SECT', 74 FROM dual
UNION ALL SELECT 430, 'BODALE.D.5.002', 'Olive Risotto', 'SECT', 74 FROM dual
UNION ALL SELECT 431, 'BODALE.D.5.003', 'Wheat Acai', 'SECT', 74 FROM dual
UNION ALL SELECT 432, 'BODALE.D.5.004', 'Sienna Sourdough Bread', 'SECT', 74 FROM dual
UNION ALL SELECT 433, 'BODALE.D.5.005', 'Lime Green Shepherd''s Pie', 'SECT', 74 FROM dual
UNION ALL SELECT 434, 'PILEFE.A.1.001', 'Aquamarine Ratatouille', 'SECT', 75 FROM dual
UNION ALL SELECT 435, 'PILEFE.A.1.002', 'Lemon Yellow Sarma', 'SECT', 75 FROM dual
UNION ALL SELECT 436, 'PILEFE.A.1.003', 'Peacock Banoffee Pie', 'SECT', 75 FROM dual
UNION ALL SELECT 437, 'PILEFE.A.1.004', 'Teal Tempura', 'SECT', 75 FROM dual
UNION ALL SELECT 438, 'PILEFE.A.1.005', 'Azure Schnitzel', 'SECT', 75 FROM dual
UNION ALL SELECT 439, 'PILEFE.A.1.006', 'Brown Cannoli', 'SECT', 75 FROM dual
UNION ALL SELECT 440, 'PILEFE.A.2.001', 'Rust Sushi', 'SECT', 76 FROM dual
UNION ALL SELECT 441, 'PILEFE.A.2.002', 'Amber Paella', 'SECT', 76 FROM dual
UNION ALL SELECT 442, 'PILEFE.A.2.003', 'Silver Quesadilla', 'SECT', 76 FROM dual
UNION ALL SELECT 443, 'PILEFE.A.2.004', 'Tangerine Pita', 'SECT', 76 FROM dual
UNION ALL SELECT 444, 'PILEFE.A.3.001', 'Seashell Enchiladas', 'SECT', 77 FROM dual
UNION ALL SELECT 445, 'PILEFE.A.3.002', 'Mint Yams', 'SECT', 77 FROM dual
UNION ALL SELECT 446, 'PILEFE.A.3.003', 'Caramel Pad Thai', 'SECT', 77 FROM dual
UNION ALL SELECT 447, 'PILEFE.A.3.004', 'Orchid Tiramisu', 'SECT', 77 FROM dual
UNION ALL SELECT 448, 'PILEFE.A.4.001', 'Rose Zopf', 'SECT', 78 FROM dual
UNION ALL SELECT 449, 'PILEFE.A.4.002', 'Amber Surf and Turf', 'SECT', 78 FROM dual
UNION ALL SELECT 450, 'PILEFE.A.4.003', 'Rose Chimichurri', 'SECT', 78 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 451 oen_id, 'PILEFE.A.4.004' oen_cd, 'Sandalwood Smørrebrød' oen_name, 'SECT' oet_cd, 78 oen_id_parent FROM dual
UNION ALL SELECT 452, 'PILEFE.A.4.005', 'Ivory White Pastel de Choclo', 'SECT', 78 FROM dual
UNION ALL SELECT 453, 'PILEFE.A.4.006', 'Chocolate Brown Nachos', 'SECT', 78 FROM dual
UNION ALL SELECT 454, 'PILEFE.B.1.001', 'Indigo Zopf', 'SECT', 79 FROM dual
UNION ALL SELECT 455, 'PILEFE.B.1.002', 'Olive Green Brioche', 'SECT', 79 FROM dual
UNION ALL SELECT 456, 'PILEFE.B.1.003', 'Seafoam Green Quesadilla', 'SECT', 79 FROM dual
UNION ALL SELECT 457, 'PILEFE.B.1.004', 'Ruby Risotto', 'SECT', 79 FROM dual
UNION ALL SELECT 458, 'PILEFE.B.1.005', 'Persimmon Kebab', 'SECT', 79 FROM dual
UNION ALL SELECT 459, 'PILEFE.B.1.006', 'Aqua Blue Varenyky', 'SECT', 79 FROM dual
UNION ALL SELECT 460, 'PILEFE.B.2.001', 'Pink Brioche', 'SECT', 80 FROM dual
UNION ALL SELECT 461, 'PILEFE.B.2.002', 'Caramel Wiener Schnitzel', 'SECT', 80 FROM dual
UNION ALL SELECT 462, 'PILEFE.B.2.003', 'Peacock Goulash', 'SECT', 80 FROM dual
UNION ALL SELECT 463, 'PILEFE.B.2.004', 'Raspberry Shakshuka', 'SECT', 80 FROM dual
UNION ALL SELECT 464, 'PILEFE.B.3.001', 'Seashell Mango Sticky Rice', 'SECT', 81 FROM dual
UNION ALL SELECT 465, 'PILEFE.B.3.002', 'Maroon Jerk Chicken', 'SECT', 81 FROM dual
UNION ALL SELECT 466, 'PILEFE.B.3.003', 'Jade Acai', 'SECT', 81 FROM dual
UNION ALL SELECT 467, 'PILEFE.B.3.004', 'Ash Grey Scotch Egg', 'SECT', 81 FROM dual
UNION ALL SELECT 468, 'PILEFE.B.3.005', 'Plum Bibimbap', 'SECT', 81 FROM dual
UNION ALL SELECT 469, 'PILEFE.B.3.006', 'Sapphire Pho', 'SECT', 81 FROM dual
UNION ALL SELECT 470, 'PILEFE.B.4.001', 'Electric Green Arepas', 'SECT', 82 FROM dual
UNION ALL SELECT 471, 'PILEFE.B.4.002', 'Teal Surf and Turf', 'SECT', 82 FROM dual
UNION ALL SELECT 472, 'PILEFE.B.4.003', 'Cobalt Blue Swiss Roll', 'SECT', 82 FROM dual
UNION ALL SELECT 473, 'PILEFE.B.4.004', 'Ruby Jerk Chicken', 'SECT', 82 FROM dual
UNION ALL SELECT 474, 'PILEFE.C.1.001', 'Plum Truffle', 'SECT', 83 FROM dual
UNION ALL SELECT 475, 'PILEFE.C.1.002', 'Tan Brown Red Curry', 'SECT', 83 FROM dual
UNION ALL SELECT 476, 'PILEFE.C.1.003', 'Heather Acai', 'SECT', 83 FROM dual
UNION ALL SELECT 477, 'PILEFE.C.1.004', 'Beige Chilaquiles', 'SECT', 83 FROM dual
UNION ALL SELECT 478, 'PILEFE.C.1.005', 'Burnt Orange Chow Mein', 'SECT', 83 FROM dual
UNION ALL SELECT 479, 'PILEFE.C.2.001', 'Sunflower Yellow Udon', 'SECT', 84 FROM dual
UNION ALL SELECT 480, 'PILEFE.C.2.002', 'Wine Red Burgers', 'SECT', 84 FROM dual
UNION ALL SELECT 481, 'PILEFE.C.2.003', 'Slate Blue Crepes', 'SECT', 84 FROM dual
UNION ALL SELECT 482, 'PILEFE.C.2.004', 'Indigo Sushi', 'SECT', 84 FROM dual
UNION ALL SELECT 483, 'PILEFE.C.3.001', 'Powder Blue Mango Sticky Rice', 'SECT', 85 FROM dual
UNION ALL SELECT 484, 'PILEFE.C.3.002', 'Sunflower Yellow Baozi', 'SECT', 85 FROM dual
UNION ALL SELECT 485, 'PILEFE.C.3.003', 'Olive Green Truffle', 'SECT', 85 FROM dual
UNION ALL SELECT 486, 'PILEFE.C.3.004', 'Khaki Poke Bowl', 'SECT', 85 FROM dual
UNION ALL SELECT 487, 'PILEFE.C.3.005', 'Electric Green Sushi', 'SECT', 85 FROM dual
UNION ALL SELECT 488, 'PILEFE.C.4.001', 'Brick Red Tandoori Chicken', 'SECT', 86 FROM dual
UNION ALL SELECT 489, 'PILEFE.C.4.002', 'Rose Baklava', 'SECT', 86 FROM dual
UNION ALL SELECT 490, 'PILEFE.C.4.003', 'Steel Blue Jiaozi', 'SECT', 86 FROM dual
UNION ALL SELECT 491, 'PILEFE.C.4.004', 'Maroon Red Chimichurri', 'SECT', 86 FROM dual
UNION ALL SELECT 492, 'PILEFE.C.4.005', 'Chocolate Brown Tzatziki', 'SECT', 86 FROM dual
UNION ALL SELECT 493, 'PILEFE.C.5.001', 'Turquoise Blue Pretzel', 'SECT', 87 FROM dual
UNION ALL SELECT 494, 'PILEFE.C.5.002', 'Heather Pancakes', 'SECT', 87 FROM dual
UNION ALL SELECT 495, 'PILEFE.C.5.003', 'Burnt Sienna Dal Makhani', 'SECT', 87 FROM dual
UNION ALL SELECT 496, 'PILEFE.C.5.004', 'Eggplant Lomo Saltado', 'SECT', 87 FROM dual
UNION ALL SELECT 497, 'PILEFE.C.5.005', 'Persimmon Som Tam', 'SECT', 87 FROM dual
UNION ALL SELECT 498, 'PILEFE.C.5.006', 'Aquamarine Croissant', 'SECT', 87 FROM dual
UNION ALL SELECT 499, 'PILEFE.C.6.001', 'Coral Pink Sourdough Bread', 'SECT', 88 FROM dual
UNION ALL SELECT 500, 'PILEFE.C.6.002', 'Electric Blue Ceviche', 'SECT', 88 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 501 oen_id, 'PILEFE.C.6.003' oen_cd, 'Pumpkin Orange Sushi' oen_name, 'SECT' oet_cd, 88 oen_id_parent FROM dual
UNION ALL SELECT 502, 'PILEFE.C.6.004', 'Lemon Yellow Hot Dog', 'SECT', 88 FROM dual
UNION ALL SELECT 503, 'PILEFE.C.6.005', 'Apricot Tapenade', 'SECT', 88 FROM dual
UNION ALL SELECT 504, 'PILEFE.C.6.006', 'Baby Purple Shawarma', 'SECT', 88 FROM dual
UNION ALL SELECT 505, 'PILEFE.D.1.001', 'Maroon Fajitas', 'SECT', 89 FROM dual
UNION ALL SELECT 506, 'PILEFE.D.1.002', 'Azure Bibimbap', 'SECT', 89 FROM dual
UNION ALL SELECT 507, 'PILEFE.D.1.003', 'Blue Samosa', 'SECT', 89 FROM dual
UNION ALL SELECT 508, 'PILEFE.D.1.004', 'Baby Purple Banoffee Pie', 'SECT', 89 FROM dual
UNION ALL SELECT 509, 'PILEFE.D.2.001', 'Avocado Goulash', 'SECT', 90 FROM dual
UNION ALL SELECT 510, 'PILEFE.D.2.002', 'Steel Grey Empanadas', 'SECT', 90 FROM dual
UNION ALL SELECT 511, 'PILEFE.D.2.003', 'Ash Grey Truffle', 'SECT', 90 FROM dual
UNION ALL SELECT 512, 'PILEFE.D.2.004', 'Grass Green Poke', 'SECT', 90 FROM dual
UNION ALL SELECT 513, 'PILEFE.D.2.005', 'Azure Pasta', 'SECT', 90 FROM dual
UNION ALL SELECT 514, 'PILEFE.D.2.006', 'Periwinkle Avocado', 'SECT', 90 FROM dual
UNION ALL SELECT 515, 'PILEFE.D.3.001', 'Navy Spring Rolls', 'SECT', 91 FROM dual
UNION ALL SELECT 516, 'PILEFE.D.3.002', 'White Pho', 'SECT', 91 FROM dual
UNION ALL SELECT 517, 'PILEFE.D.3.003', 'Corn Scotch Egg', 'SECT', 91 FROM dual
UNION ALL SELECT 518, 'PILEFE.D.3.004', 'Sky Blue Ratatouille', 'SECT', 91 FROM dual
UNION ALL SELECT 519, 'PILEFE.D.4.001', 'Steel Blue Wiener Schnitzel', 'SECT', 92 FROM dual
UNION ALL SELECT 520, 'PILEFE.D.4.002', 'Corn Gyoza', 'SECT', 92 FROM dual
UNION ALL SELECT 521, 'PILEFE.D.4.003', 'Lavender Blue Shawarma', 'SECT', 92 FROM dual
UNION ALL SELECT 522, 'PILEFE.D.4.004', 'Rust Tofu', 'SECT', 92 FROM dual
UNION ALL SELECT 523, 'PILEFE.D.4.005', 'Ruby Red Goulash', 'SECT', 92 FROM dual
UNION ALL SELECT 524, 'PILEFE.D.4.006', 'Topaz Chana Masala', 'SECT', 92 FROM dual
UNION ALL SELECT 525, 'PILEFE.D.5.001', 'Heather Acai', 'SECT', 93 FROM dual
UNION ALL SELECT 526, 'PILEFE.D.5.002', 'Auburn Dal Makhani', 'SECT', 93 FROM dual
UNION ALL SELECT 527, 'PILEFE.D.5.003', 'Mocha Pani Puri', 'SECT', 93 FROM dual
UNION ALL SELECT 528, 'PILEFE.D.5.004', 'Pink Tonkatsu', 'SECT', 93 FROM dual
UNION ALL SELECT 529, 'PILEFE.D.5.005', 'Coral Pink Maki Roll', 'SECT', 93 FROM dual
UNION ALL SELECT 530, 'PILEFE.D.5.006', 'Wheat Shakshuka', 'SECT', 93 FROM dual
UNION ALL SELECT 531, 'PILEFE.D.6.001', 'Eggshell Surf and Turf', 'SECT', 94 FROM dual
UNION ALL SELECT 532, 'PILEFE.D.6.002', 'Turquoise Green Couscous', 'SECT', 94 FROM dual
UNION ALL SELECT 533, 'PILEFE.D.6.003', 'Wheat Vanilla Slice', 'SECT', 94 FROM dual
UNION ALL SELECT 534, 'PILEFE.D.6.004', 'Cyan Lomo Saltado', 'SECT', 94 FROM dual
UNION ALL SELECT 535, 'PILEFE.D.6.005', 'Lemon Yellow Lomo Saltado', 'SECT', 94 FROM dual
UNION ALL SELECT 536, 'PILEFE.E.1.001', 'Sea Blue Ravioli', 'SECT', 95 FROM dual
UNION ALL SELECT 537, 'PILEFE.E.1.002', 'Baby Purple Udon', 'SECT', 95 FROM dual
UNION ALL SELECT 538, 'PILEFE.E.1.003', 'Amber Som Tam', 'SECT', 95 FROM dual
UNION ALL SELECT 539, 'PILEFE.E.1.004', 'Peacock Blue Pizza', 'SECT', 95 FROM dual
UNION ALL SELECT 540, 'PILEFE.E.1.005', 'Brick Red Yellow Curry', 'SECT', 95 FROM dual
UNION ALL SELECT 541, 'PILEFE.E.1.006', 'Wheat Soto', 'SECT', 95 FROM dual
UNION ALL SELECT 542, 'PILEFE.E.2.001', 'Tan Zopf', 'SECT', 96 FROM dual
UNION ALL SELECT 543, 'PILEFE.E.2.002', 'Azure Avocado', 'SECT', 96 FROM dual
UNION ALL SELECT 544, 'PILEFE.E.2.003', 'Slate Nasi Goreng', 'SECT', 96 FROM dual
UNION ALL SELECT 545, 'PILEFE.E.2.004', 'Burnt Umber Tortilla de Patata', 'SECT', 96 FROM dual
UNION ALL SELECT 546, 'PILEFE.E.3.001', 'Ice Blue Vanilla Slice', 'SECT', 97 FROM dual
UNION ALL SELECT 547, 'PILEFE.E.3.002', 'Red Sauerbraten', 'SECT', 97 FROM dual
UNION ALL SELECT 548, 'PILEFE.E.3.003', 'Yellow Tiramisu', 'SECT', 97 FROM dual
UNION ALL SELECT 549, 'PILEFE.E.3.004', 'Ivory White Ramen', 'SECT', 97 FROM dual
UNION ALL SELECT 550, 'PILEFE.E.4.001', 'Burgundy Ravioli', 'SECT', 98 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 551 oen_id, 'PILEFE.E.4.002' oen_cd, 'Brown Burgers' oen_name, 'SECT' oet_cd, 98 oen_id_parent FROM dual
UNION ALL SELECT 552, 'PILEFE.E.4.003', 'Moss Chimichurri', 'SECT', 98 FROM dual
UNION ALL SELECT 553, 'PILEFE.E.4.004', 'Cream Jerk Chicken', 'SECT', 98 FROM dual
UNION ALL SELECT 554, 'PILEFE.E.4.005', 'Heather Vegetable Tempura', 'SECT', 98 FROM dual
UNION ALL SELECT 555, 'PILEFE.E.4.006', 'Turquoise Yule Log', 'SECT', 98 FROM dual
UNION ALL SELECT 556, 'PILEFE.F.1.001', 'Charcoal Ravioli', 'SECT', 99 FROM dual
UNION ALL SELECT 557, 'PILEFE.F.1.002', 'Aqua Dal Makhani', 'SECT', 99 FROM dual
UNION ALL SELECT 558, 'PILEFE.F.1.003', 'Seashell Hot Dog', 'SECT', 99 FROM dual
UNION ALL SELECT 559, 'PILEFE.F.1.004', 'Lemon Tapenade', 'SECT', 99 FROM dual
UNION ALL SELECT 560, 'PILEFE.F.1.005', 'Maroon Pulled Pork', 'SECT', 99 FROM dual
UNION ALL SELECT 561, 'PILEFE.F.2.001', 'Magenta Truffle', 'SECT', 100 FROM dual
UNION ALL SELECT 562, 'PILEFE.F.2.002', 'Baby Purple Rendang', 'SECT', 100 FROM dual
UNION ALL SELECT 563, 'PILEFE.F.2.003', 'Jade Vanilla Slice', 'SECT', 100 FROM dual
UNION ALL SELECT 564, 'PILEFE.F.2.004', 'Mustard Tom Yum', 'SECT', 100 FROM dual
UNION ALL SELECT 565, 'PILEFE.F.2.005', 'Olive Shawarma', 'SECT', 100 FROM dual
UNION ALL SELECT 566, 'PILEFE.F.2.006', 'Auburn Banana Bread', 'SECT', 100 FROM dual
UNION ALL SELECT 567, 'PILEFE.F.3.001', 'Burgundy Red Udon', 'SECT', 101 FROM dual
UNION ALL SELECT 568, 'PILEFE.F.3.002', 'Lavender Purple Wagyu Beef', 'SECT', 101 FROM dual
UNION ALL SELECT 569, 'PILEFE.F.3.003', 'Sea Blue Mango Sticky Rice', 'SECT', 101 FROM dual
UNION ALL SELECT 570, 'PILEFE.F.3.004', 'Seafoam Green Shawarma', 'SECT', 101 FROM dual
UNION ALL SELECT 571, 'PILEFE.F.4.001', 'Jade Cassoulet', 'SECT', 102 FROM dual
UNION ALL SELECT 572, 'PILEFE.F.4.002', 'Midnight Blue Samosa', 'SECT', 102 FROM dual
UNION ALL SELECT 573, 'PILEFE.F.4.003', 'Lemon Pizza', 'SECT', 102 FROM dual
UNION ALL SELECT 574, 'PILEFE.F.4.004', 'Tangerine Ceviche', 'SECT', 102 FROM dual
UNION ALL SELECT 575, 'PILEFE.F.4.005', 'Sienna Pavlova', 'SECT', 102 FROM dual
UNION ALL SELECT 576, 'PILEFE.F.5.001', 'Corn Tikka Masala', 'SECT', 103 FROM dual
UNION ALL SELECT 577, 'PILEFE.F.5.002', 'Turquoise Blue Banoffee Pie', 'SECT', 103 FROM dual
UNION ALL SELECT 578, 'PILEFE.F.5.003', 'Sienna Sushi Burrito', 'SECT', 103 FROM dual
UNION ALL SELECT 579, 'PILEFE.F.5.004', 'Turquoise Pretzel', 'SECT', 103 FROM dual
UNION ALL SELECT 580, 'DEPIBU.A.1.001', 'Amethyst Soul Food', 'SECT', 104 FROM dual
UNION ALL SELECT 581, 'DEPIBU.A.1.002', 'Heather Naan', 'SECT', 104 FROM dual
UNION ALL SELECT 582, 'DEPIBU.A.1.003', 'Lilac Chimichurri', 'SECT', 104 FROM dual
UNION ALL SELECT 583, 'DEPIBU.A.1.004', 'Peach Xiao Long Bao', 'SECT', 104 FROM dual
UNION ALL SELECT 584, 'DEPIBU.A.2.001', 'Peacock Green Yule Log', 'SECT', 105 FROM dual
UNION ALL SELECT 585, 'DEPIBU.A.2.002', 'Beige Yule Log', 'SECT', 105 FROM dual
UNION ALL SELECT 586, 'DEPIBU.A.2.003', 'Amber Yellow Curry', 'SECT', 105 FROM dual
UNION ALL SELECT 587, 'DEPIBU.A.2.004', 'Moss Green Taco', 'SECT', 105 FROM dual
UNION ALL SELECT 588, 'DEPIBU.A.3.001', 'Apricot Pancakes', 'SECT', 106 FROM dual
UNION ALL SELECT 589, 'DEPIBU.A.3.002', 'Celadon Tzatziki', 'SECT', 106 FROM dual
UNION ALL SELECT 590, 'DEPIBU.A.3.003', 'Yellow Xiao Long Bao', 'SECT', 106 FROM dual
UNION ALL SELECT 591, 'DEPIBU.A.3.004', 'Wine Red Empanadas', 'SECT', 106 FROM dual
UNION ALL SELECT 592, 'DEPIBU.A.4.001', 'Ruby Pho', 'SECT', 107 FROM dual
UNION ALL SELECT 593, 'DEPIBU.A.4.002', 'Periwinkle Spring Rolls', 'SECT', 107 FROM dual
UNION ALL SELECT 594, 'DEPIBU.A.4.003', 'Emerald Wiener Schnitzel', 'SECT', 107 FROM dual
UNION ALL SELECT 595, 'DEPIBU.A.4.004', 'Brick Sushi', 'SECT', 107 FROM dual
UNION ALL SELECT 596, 'DEPIBU.A.4.005', 'Strawberry Goulash', 'SECT', 107 FROM dual
UNION ALL SELECT 597, 'DEPIBU.A.4.006', 'Beige White Lomo Saltado', 'SECT', 107 FROM dual
UNION ALL SELECT 598, 'DEPIBU.A.5.001', 'Amethyst Tortilla Soup', 'SECT', 108 FROM dual
UNION ALL SELECT 599, 'DEPIBU.A.5.002', 'Charcoal Grey Stroganoff', 'SECT', 108 FROM dual
UNION ALL SELECT 600, 'DEPIBU.A.5.003', 'Pink Vietnamese Pho', 'SECT', 108 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 601 oen_id, 'DEPIBU.A.5.004' oen_cd, 'Sapphire Blue Paella' oen_name, 'SECT' oet_cd, 108 oen_id_parent FROM dual
UNION ALL SELECT 602, 'DEPIBU.A.5.005', 'Cyan Borscht', 'SECT', 108 FROM dual
UNION ALL SELECT 603, 'DEPIBU.A.5.006', 'Burnt Umber Arepas', 'SECT', 108 FROM dual
UNION ALL SELECT 604, 'DEPIBU.A.6.001', 'Pumpkin Yakisoba', 'SECT', 109 FROM dual
UNION ALL SELECT 605, 'DEPIBU.A.6.002', 'Almond Yakitori', 'SECT', 109 FROM dual
UNION ALL SELECT 606, 'DEPIBU.A.6.003', 'Forest Green Bibimbap', 'SECT', 109 FROM dual
UNION ALL SELECT 607, 'DEPIBU.A.6.004', 'Slate Grey Shawarma', 'SECT', 109 FROM dual
UNION ALL SELECT 608, 'DEPIBU.A.6.005', 'Indigo Vegetable Tempura', 'SECT', 109 FROM dual
UNION ALL SELECT 609, 'DEPIBU.A.6.006', 'Sky Blue Satay', 'SECT', 109 FROM dual
UNION ALL SELECT 610, 'DEPIBU.B.1.001', 'Wine Falafel', 'SECT', 110 FROM dual
UNION ALL SELECT 611, 'DEPIBU.B.1.002', 'Black Vegetable Tempura', 'SECT', 110 FROM dual
UNION ALL SELECT 612, 'DEPIBU.B.1.003', 'Corn Yellow Tamales', 'SECT', 110 FROM dual
UNION ALL SELECT 613, 'DEPIBU.B.1.004', 'Charcoal Grey Gyoza', 'SECT', 110 FROM dual
UNION ALL SELECT 614, 'DEPIBU.B.1.005', 'Burgundy Red Tandoori Chicken', 'SECT', 110 FROM dual
UNION ALL SELECT 615, 'DEPIBU.B.1.006', 'Sky Blue Sourdough Bread', 'SECT', 110 FROM dual
UNION ALL SELECT 616, 'DEPIBU.B.2.001', 'Cornflower Blue Hummus', 'SECT', 111 FROM dual
UNION ALL SELECT 617, 'DEPIBU.B.2.002', 'Burgundy Sashimi', 'SECT', 111 FROM dual
UNION ALL SELECT 618, 'DEPIBU.B.2.003', 'Coral Maki Roll', 'SECT', 111 FROM dual
UNION ALL SELECT 619, 'DEPIBU.B.2.004', 'Ice Blue Nachos', 'SECT', 111 FROM dual
UNION ALL SELECT 620, 'DEPIBU.B.2.005', 'Mustard Shakshuka', 'SECT', 111 FROM dual
UNION ALL SELECT 621, 'DEPIBU.B.2.006', 'Steel Blue Sashimi', 'SECT', 111 FROM dual
UNION ALL SELECT 622, 'DEPIBU.B.3.001', 'Maroon Gyoza', 'SECT', 112 FROM dual
UNION ALL SELECT 623, 'DEPIBU.B.3.002', 'Moss Green Shawarma', 'SECT', 112 FROM dual
UNION ALL SELECT 624, 'DEPIBU.B.3.003', 'Powder Pink Empanadas', 'SECT', 112 FROM dual
UNION ALL SELECT 625, 'DEPIBU.B.3.004', 'Almond Smørrebrød', 'SECT', 112 FROM dual
UNION ALL SELECT 626, 'DEPIBU.B.3.005', 'Slate Grey Banana Bread', 'SECT', 112 FROM dual
UNION ALL SELECT 627, 'DEPIBU.B.3.006', 'Charcoal Shakshuka', 'SECT', 112 FROM dual
UNION ALL SELECT 628, 'DEPIBU.B.4.001', 'Frost Tiramisu', 'SECT', 113 FROM dual
UNION ALL SELECT 629, 'DEPIBU.B.4.002', 'Pumpkin Schnitzel', 'SECT', 113 FROM dual
UNION ALL SELECT 630, 'DEPIBU.B.4.003', 'Moss Hot Dog', 'SECT', 113 FROM dual
UNION ALL SELECT 631, 'DEPIBU.B.4.004', 'Coral Pink Soto', 'SECT', 113 FROM dual
UNION ALL SELECT 632, 'DEPIBU.B.5.001', 'Baby Pink Borscht', 'SECT', 114 FROM dual
UNION ALL SELECT 633, 'DEPIBU.B.5.002', 'Sapphire Hummus', 'SECT', 114 FROM dual
UNION ALL SELECT 634, 'DEPIBU.B.5.003', 'Indigo Fajitas', 'SECT', 114 FROM dual
UNION ALL SELECT 635, 'DEPIBU.B.5.004', 'Pink Risotto', 'SECT', 114 FROM dual
UNION ALL SELECT 636, 'DEPIBU.B.5.005', 'Caramel Yogurt', 'SECT', 114 FROM dual
UNION ALL SELECT 637, 'DEPIBU.B.5.006', 'Burgundy Spring Rolls', 'SECT', 114 FROM dual
UNION ALL SELECT 638, 'DEPIBU.C.1.001', 'Strawberry Ravioli', 'SECT', 115 FROM dual
UNION ALL SELECT 639, 'DEPIBU.C.1.002', 'Burgundy Red Zopf', 'SECT', 115 FROM dual
UNION ALL SELECT 640, 'DEPIBU.C.1.003', 'Red Swiss Roll', 'SECT', 115 FROM dual
UNION ALL SELECT 641, 'DEPIBU.C.1.004', 'Brown Sarma', 'SECT', 115 FROM dual
UNION ALL SELECT 642, 'DEPIBU.C.1.005', 'Olive Green Sushi', 'SECT', 115 FROM dual
UNION ALL SELECT 643, 'DEPIBU.C.2.001', 'Teal Soul Food', 'SECT', 116 FROM dual
UNION ALL SELECT 644, 'DEPIBU.C.2.002', 'Teal Green Yakitori', 'SECT', 116 FROM dual
UNION ALL SELECT 645, 'DEPIBU.C.2.003', 'Sea Blue Yule Log', 'SECT', 116 FROM dual
UNION ALL SELECT 646, 'DEPIBU.C.2.004', 'Powder Blue Swiss Roll', 'SECT', 116 FROM dual
UNION ALL SELECT 647, 'DEPIBU.C.2.005', 'Ash Grey Jiaozi', 'SECT', 116 FROM dual
UNION ALL SELECT 648, 'DEPIBU.E.4.001', 'Tomato Red Yule Log', 'SECT', 129 FROM dual
UNION ALL SELECT 649, 'DEPIBU.E.4.002', 'Electric Purple Vada Pav', 'SECT', 129 FROM dual
UNION ALL SELECT 650, 'DEPIBU.E.4.003', 'Caramel Pizza', 'SECT', 129 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 651 oen_id, 'DEPIBU.E.4.004' oen_cd, 'Amethyst Taco' oen_name, 'SECT' oet_cd, 129 oen_id_parent FROM dual
UNION ALL SELECT 652, 'DEPIBU.E.4.005', 'Seashell Pad Thai', 'SECT', 129 FROM dual
UNION ALL SELECT 653, 'BAGETU.A.1.001', 'Maroon Red Soto', 'SECT', 130 FROM dual
UNION ALL SELECT 654, 'BAGETU.A.1.002', 'Ice Blue Kebab', 'SECT', 130 FROM dual
UNION ALL SELECT 655, 'BAGETU.A.1.003', 'Pumpkin Zabaione', 'SECT', 130 FROM dual
UNION ALL SELECT 656, 'BAGETU.A.1.004', 'Sienna Adobo', 'SECT', 130 FROM dual
UNION ALL SELECT 657, 'BAGETU.A.1.005', 'Khaki Acai', 'SECT', 130 FROM dual
UNION ALL SELECT 658, 'BAGETU.A.1.006', 'Slate Blue Pupusa', 'SECT', 130 FROM dual
UNION ALL SELECT 659, 'BAGETU.A.2.001', 'Burnt Umber Dumplings', 'SECT', 131 FROM dual
UNION ALL SELECT 660, 'BAGETU.A.2.002', 'Electric Green Tom Yum', 'SECT', 131 FROM dual
UNION ALL SELECT 661, 'BAGETU.A.2.003', 'Corn Tzatziki', 'SECT', 131 FROM dual
UNION ALL SELECT 662, 'BAGETU.A.2.004', 'Pink Samosa', 'SECT', 131 FROM dual
UNION ALL SELECT 663, 'BAGETU.A.2.005', 'Orchid Fajitas', 'SECT', 131 FROM dual
UNION ALL SELECT 664, 'BAGETU.A.2.006', 'Forest Green Pad Thai', 'SECT', 131 FROM dual
UNION ALL SELECT 665, 'BAGETU.A.3.001', 'Ruby Pavlova', 'SECT', 132 FROM dual
UNION ALL SELECT 666, 'BAGETU.A.3.002', 'Turquoise Green Burgers', 'SECT', 132 FROM dual
UNION ALL SELECT 667, 'BAGETU.A.3.003', 'Electric Blue Arepas', 'SECT', 132 FROM dual
UNION ALL SELECT 668, 'BAGETU.A.3.004', 'Black Lasagna', 'SECT', 132 FROM dual
UNION ALL SELECT 669, 'BAGETU.A.4.001', 'Peacock Xiao Long Bao', 'SECT', 133 FROM dual
UNION ALL SELECT 670, 'BAGETU.A.4.002', 'Peacock Blue Yuzu', 'SECT', 133 FROM dual
UNION ALL SELECT 671, 'BAGETU.A.4.003', 'Baby Green Taco', 'SECT', 133 FROM dual
UNION ALL SELECT 672, 'BAGETU.A.4.004', 'Tan Brown Yule Log', 'SECT', 133 FROM dual
UNION ALL SELECT 673, 'BAGETU.A.5.001', 'Beige White Croissant', 'SECT', 134 FROM dual
UNION ALL SELECT 674, 'BAGETU.A.5.002', 'Pink Sauerbraten', 'SECT', 134 FROM dual
UNION ALL SELECT 675, 'BAGETU.A.5.003', 'Lavender Blue Kimchi', 'SECT', 134 FROM dual
UNION ALL SELECT 676, 'BAGETU.A.5.004', 'Powder Blue Tortilla de Patata', 'SECT', 134 FROM dual
UNION ALL SELECT 677, 'BAGETU.A.5.005', 'Ivory Waffles', 'SECT', 134 FROM dual
UNION ALL SELECT 678, 'BAGETU.B.1.001', 'Steel Blue Tikka Masala', 'SECT', 135 FROM dual
UNION ALL SELECT 679, 'BAGETU.B.1.002', 'Beige White Vietnamese Pho', 'SECT', 135 FROM dual
UNION ALL SELECT 680, 'BAGETU.B.1.003', 'Persimmon Bratwurst', 'SECT', 135 FROM dual
UNION ALL SELECT 681, 'BAGETU.B.1.004', 'Brick Baklava', 'SECT', 135 FROM dual
UNION ALL SELECT 682, 'BAGETU.B.2.001', 'Eggshell Vegetable Tempura', 'SECT', 136 FROM dual
UNION ALL SELECT 683, 'BAGETU.B.2.002', 'Dusty Rose Samosa', 'SECT', 136 FROM dual
UNION ALL SELECT 684, 'BAGETU.B.2.003', 'Sea Blue Curry', 'SECT', 136 FROM dual
UNION ALL SELECT 685, 'BAGETU.B.2.004', 'Ivory White Pasta', 'SECT', 136 FROM dual
UNION ALL SELECT 686, 'BAGETU.B.2.005', 'Bronze Tonkatsu', 'SECT', 136 FROM dual
UNION ALL SELECT 687, 'BAGETU.B.3.001', 'Sky Blue Scotch Egg', 'SECT', 137 FROM dual
UNION ALL SELECT 688, 'BAGETU.B.3.002', 'Steel Blue Surf and Turf', 'SECT', 137 FROM dual
UNION ALL SELECT 689, 'BAGETU.B.3.003', 'Sea Blue Maki Roll', 'SECT', 137 FROM dual
UNION ALL SELECT 690, 'BAGETU.B.3.004', 'Indigo Enchiladas', 'SECT', 137 FROM dual
UNION ALL SELECT 691, 'BAGETU.B.4.001', 'Pink Poke Bowl', 'SECT', 138 FROM dual
UNION ALL SELECT 692, 'BAGETU.B.4.002', 'Sunflower Yellow Pani Puri', 'SECT', 138 FROM dual
UNION ALL SELECT 693, 'BAGETU.B.4.003', 'Jade Adobo', 'SECT', 138 FROM dual
UNION ALL SELECT 694, 'BAGETU.B.4.004', 'Corn Pita', 'SECT', 138 FROM dual
UNION ALL SELECT 695, 'BAGETU.B.4.005', 'Rust Adobo', 'SECT', 138 FROM dual
UNION ALL SELECT 696, 'BAGETU.B.5.001', 'Bronze Swiss Roll', 'SECT', 139 FROM dual
UNION ALL SELECT 697, 'BAGETU.B.5.002', 'Cyan Blue Sushi Burrito', 'SECT', 139 FROM dual
UNION ALL SELECT 698, 'BAGETU.B.5.003', 'Tan Brown Nachos', 'SECT', 139 FROM dual
UNION ALL SELECT 699, 'BAGETU.B.5.004', 'Auburn Taco', 'SECT', 139 FROM dual
UNION ALL SELECT 700, 'BAGETU.B.5.005', 'Olive Green Croissant', 'SECT', 139 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 701 oen_id, 'BAGETU.B.6.001' oen_cd, 'Indigo Coq au Vin' oen_name, 'SECT' oet_cd, 140 oen_id_parent FROM dual
UNION ALL SELECT 702, 'BAGETU.B.6.002', 'Lavender Purple Truffle', 'SECT', 140 FROM dual
UNION ALL SELECT 703, 'BAGETU.B.6.003', 'Pink Tajine', 'SECT', 140 FROM dual
UNION ALL SELECT 704, 'BAGETU.B.6.004', 'Marigold Chow Mein', 'SECT', 140 FROM dual
UNION ALL SELECT 705, 'BAGETU.B.6.005', 'Wine Red Sashimi', 'SECT', 140 FROM dual
UNION ALL SELECT 706, 'BAGETU.B.6.006', 'Mint Vanilla Slice', 'SECT', 140 FROM dual
UNION ALL SELECT 707, 'BAGETU.C.1.001', 'Rose Pink Vegemite on Toast', 'SECT', 141 FROM dual
UNION ALL SELECT 708, 'BAGETU.C.1.002', 'Moss Green Chilaquiles', 'SECT', 141 FROM dual
UNION ALL SELECT 709, 'BAGETU.C.1.003', 'Mint Dal Makhani', 'SECT', 141 FROM dual
UNION ALL SELECT 710, 'BAGETU.C.1.004', 'Amethyst Tacos', 'SECT', 141 FROM dual
UNION ALL SELECT 711, 'BAGETU.C.2.001', 'Brown Tajine', 'SECT', 142 FROM dual
UNION ALL SELECT 712, 'BAGETU.C.2.002', 'Rust Cannoli', 'SECT', 142 FROM dual
UNION ALL SELECT 713, 'BAGETU.C.2.003', 'Tomato Red Pani Puri', 'SECT', 142 FROM dual
UNION ALL SELECT 714, 'BAGETU.C.2.004', 'Grass Green Soba', 'SECT', 142 FROM dual
UNION ALL SELECT 715, 'BAGETU.C.2.005', 'Baby Green Yakisoba', 'SECT', 142 FROM dual
UNION ALL SELECT 716, 'BAGETU.C.2.006', 'Marigold Cassoulet', 'SECT', 142 FROM dual
UNION ALL SELECT 717, 'BAGETU.C.3.001', 'Moss Green Shepherd''s Pie', 'SECT', 143 FROM dual
UNION ALL SELECT 718, 'BAGETU.C.3.002', 'Tangerine Couscous', 'SECT', 143 FROM dual
UNION ALL SELECT 719, 'BAGETU.C.3.003', 'Coral Poke Bowl', 'SECT', 143 FROM dual
UNION ALL SELECT 720, 'BAGETU.C.3.004', 'Cream Vegetable Tempura', 'SECT', 143 FROM dual
UNION ALL SELECT 721, 'BAGETU.C.4.001', 'Slate Grey Shawarma', 'SECT', 144 FROM dual
UNION ALL SELECT 722, 'BAGETU.C.4.002', 'Sienna Vietnamese Pho', 'SECT', 144 FROM dual
UNION ALL SELECT 723, 'BAGETU.C.4.003', 'Lavender Tikka Masala', 'SECT', 144 FROM dual
UNION ALL SELECT 724, 'BAGETU.C.4.004', 'Baby Blue Nasi Goreng', 'SECT', 144 FROM dual
UNION ALL SELECT 161, 'BODALE.B.4.001', 'Charcoal Tacos', 'SECT', 63 FROM dual
UNION ALL SELECT 162, 'BODALE.B.4.002', 'Seashell Kimchi', 'SECT', 63 FROM dual
UNION ALL SELECT 163, 'BODALE.B.4.003', 'Maroon Pani Puri', 'SECT', 63 FROM dual
UNION ALL SELECT 164, 'BODALE.B.4.004', 'Cream Samosa', 'SECT', 63 FROM dual
UNION ALL SELECT 165, 'BODALE.C.1.001', 'Indigo Poutine', 'SECT', 64 FROM dual
UNION ALL SELECT 166, 'BODALE.C.1.002', 'Honey Tajine', 'SECT', 64 FROM dual
UNION ALL SELECT 167, 'BODALE.C.1.003', 'Avocado Gyoza', 'SECT', 64 FROM dual
UNION ALL SELECT 168, 'BODALE.C.1.004', 'Sunflower Yellow Pad Thai', 'SECT', 64 FROM dual
UNION ALL SELECT 169, 'BODALE.C.1.005', 'Jade Hot Dog', 'SECT', 64 FROM dual
UNION ALL SELECT 170, 'BODALE.C.1.006', 'Powder Blue Jerk Chicken', 'SECT', 64 FROM dual
UNION ALL SELECT 171, 'SONIRI.D.6.001', 'Marigold Mango Sticky Rice', 'SECT', 53 FROM dual
UNION ALL SELECT 172, 'SONIRI.D.6.002', 'Lilac Birria', 'SECT', 53 FROM dual
UNION ALL SELECT 173, 'SONIRI.D.6.003', 'Sunflower Yellow Samosa', 'SECT', 53 FROM dual
UNION ALL SELECT 174, 'SONIRI.D.6.004', 'Forest Green Pierogi', 'SECT', 53 FROM dual
UNION ALL SELECT 175, 'SONIRI.D.6.005', 'Cornflower Blue Chilaquiles', 'SECT', 53 FROM dual
UNION ALL SELECT 176, 'SONIRI.D.6.006', 'Sunflower Yellow Tonkatsu', 'SECT', 53 FROM dual
UNION ALL SELECT 177, 'BODALE.A.1.001', 'Electric Green Tikka Masala', 'SECT', 54 FROM dual
UNION ALL SELECT 178, 'BODALE.A.1.002', 'Olive Green Adobo', 'SECT', 54 FROM dual
UNION ALL SELECT 179, 'BODALE.A.1.003', 'Aqua Blue Pancakes', 'SECT', 54 FROM dual
UNION ALL SELECT 180, 'BODALE.A.1.004', 'Sand Vegetable Tempura', 'SECT', 54 FROM dual
UNION ALL SELECT 181, 'BODALE.A.1.005', 'Seashell Lomo Saltado', 'SECT', 54 FROM dual
UNION ALL SELECT 182, 'BODALE.A.2.001', 'Powder Blue Sauerbraten', 'SECT', 55 FROM dual
UNION ALL SELECT 183, 'BODALE.A.2.002', 'Jade Vanilla Slice', 'SECT', 55 FROM dual
UNION ALL SELECT 184, 'BODALE.A.2.003', 'Mocha Croissant', 'SECT', 55 FROM dual
UNION ALL SELECT 185, 'BODALE.A.2.004', 'Lemon Lime Sushi', 'SECT', 55 FROM dual
UNION ALL SELECT 186, 'BODALE.A.2.005', 'Mint Pita', 'SECT', 55 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 187 oen_id, 'BODALE.A.2.006' oen_cd, 'Olive Green Pupusa' oen_name, 'SECT' oet_cd, 55 oen_id_parent FROM dual
UNION ALL SELECT 188, 'BODALE.A.3.001', 'Slate Blue Lasagna', 'SECT', 56 FROM dual
UNION ALL SELECT 189, 'BODALE.A.3.002', 'Midnight Blue Tandoori Chicken', 'SECT', 56 FROM dual
UNION ALL SELECT 190, 'BODALE.A.3.003', 'Seafoam Green Hummus', 'SECT', 56 FROM dual
UNION ALL SELECT 191, 'BODALE.A.3.004', 'Sunflower Yellow Ratatouille', 'SECT', 56 FROM dual
UNION ALL SELECT 192, 'BODALE.A.4.001', 'Persimmon Haggis', 'SECT', 57 FROM dual
UNION ALL SELECT 193, 'BODALE.A.4.002', 'Tomato Red Risotto', 'SECT', 57 FROM dual
UNION ALL SELECT 194, 'BODALE.A.4.003', 'Burgundy Red Dumplings', 'SECT', 57 FROM dual
UNION ALL SELECT 195, 'BODALE.A.4.004', 'Lime Green Wiener Schnitzel', 'SECT', 57 FROM dual
UNION ALL SELECT 196, 'BODALE.A.4.005', 'Sienna Brown Crepes', 'SECT', 57 FROM dual
UNION ALL SELECT 197, 'BODALE.A.5.001', 'Steel Grey Yule Log', 'SECT', 58 FROM dual
UNION ALL SELECT 198, 'BODALE.A.5.002', 'Khaki Tzatziki', 'SECT', 58 FROM dual
UNION ALL SELECT 199, 'BODALE.A.5.003', 'Sea Green Crepes', 'SECT', 58 FROM dual
UNION ALL SELECT 200, 'BODALE.A.5.004', 'Sapphire Spring Rolls', 'SECT', 58 FROM dual
UNION ALL SELECT 201, 'BODALE.A.5.005', 'Lemon Yellow Wiener Schnitzel', 'SECT', 58 FROM dual
UNION ALL SELECT 202, 'BODALE.A.5.006', 'Maroon Croissant', 'SECT', 58 FROM dual
UNION ALL SELECT 203, 'BODALE.A.6.001', 'Baby Pink Tapenade', 'SECT', 59 FROM dual
UNION ALL SELECT 204, 'BODALE.A.6.002', 'Sky Blue Pad See Ew', 'SECT', 59 FROM dual
UNION ALL SELECT 205, 'BODALE.A.6.003', 'Pewter Pad See Ew', 'SECT', 59 FROM dual
UNION ALL SELECT 206, 'BODALE.A.6.004', 'Burnt Sienna Wagyu Beef', 'SECT', 59 FROM dual
UNION ALL SELECT 207, 'BODALE.A.6.005', 'Charcoal Yakitori', 'SECT', 59 FROM dual
UNION ALL SELECT 208, 'BODALE.A.6.006', 'Burnt Umber Waffles', 'SECT', 59 FROM dual
UNION ALL SELECT 209, 'BODALE.B.1.001', 'Amber Scotch Egg', 'SECT', 60 FROM dual
UNION ALL SELECT 210, 'BODALE.B.1.002', 'Cyan Blue Poke', 'SECT', 60 FROM dual
UNION ALL SELECT 211, 'BODALE.B.1.003', 'Eggshell Tom Yum', 'SECT', 60 FROM dual
UNION ALL SELECT 212, 'BODALE.B.1.004', 'Mustard Chana Masala', 'SECT', 60 FROM dual
UNION ALL SELECT 213, 'BODALE.B.2.001', 'Pine Green Schnitzel', 'SECT', 61 FROM dual
UNION ALL SELECT 214, 'BODALE.B.2.002', 'Denim Pani Puri', 'SECT', 61 FROM dual
UNION ALL SELECT 215, 'BODALE.B.2.003', 'Cream Tandoori Chicken', 'SECT', 61 FROM dual
UNION ALL SELECT 216, 'BODALE.B.2.004', 'Ivory Tiramisu', 'SECT', 61 FROM dual
UNION ALL SELECT 217, 'BODALE.B.2.005', 'Caramel Sarma', 'SECT', 61 FROM dual
UNION ALL SELECT 218, 'BODALE.B.2.006', 'Baby Purple Smørrebrød', 'SECT', 61 FROM dual
UNION ALL SELECT 219, 'BODALE.B.3.001', 'Seashell Sushi Burrito', 'SECT', 62 FROM dual
UNION ALL SELECT 220, 'BODALE.B.3.002', 'Plum Tikka Masala', 'SECT', 62 FROM dual
UNION ALL SELECT 221, 'BODALE.B.3.003', 'Aqua Shrimp and Grits', 'SECT', 62 FROM dual
UNION ALL SELECT 222, 'BODALE.B.3.004', 'Violet Risotto', 'SECT', 62 FROM dual
UNION ALL SELECT 223, 'BODALE.B.3.005', 'Baby Green Ratatouille', 'SECT', 62 FROM dual
UNION ALL SELECT 224, 'SONIRI.A.1.001', 'Baby Blue Tajine', 'SECT', 32 FROM dual
UNION ALL SELECT 225, 'SONIRI.A.1.002', 'Baby Green Nachos', 'SECT', 32 FROM dual
UNION ALL SELECT 226, 'SONIRI.A.1.003', 'Amethyst Pupusa', 'SECT', 32 FROM dual
UNION ALL SELECT 227, 'SONIRI.A.1.004', 'Lavender Blue Sushi Burrito', 'SECT', 32 FROM dual
UNION ALL SELECT 228, 'SONIRI.A.1.005', 'Denim Peking Duck', 'SECT', 32 FROM dual
UNION ALL SELECT 229, 'SONIRI.A.2.001', 'Beige Soba', 'SECT', 33 FROM dual
UNION ALL SELECT 230, 'SONIRI.A.2.002', 'Aquamarine Sushi', 'SECT', 33 FROM dual
UNION ALL SELECT 231, 'SONIRI.A.2.003', 'Grass Green Poke', 'SECT', 33 FROM dual
UNION ALL SELECT 232, 'SONIRI.A.2.004', 'Eggplant Pancakes', 'SECT', 33 FROM dual
UNION ALL SELECT 233, 'SONIRI.A.2.005', 'Moss Peking Duck', 'SECT', 33 FROM dual
UNION ALL SELECT 234, 'SONIRI.A.3.001', 'Powder Blue Jiaozi', 'SECT', 34 FROM dual
UNION ALL SELECT 235, 'SONIRI.A.3.002', 'Eggplant Ravioli', 'SECT', 34 FROM dual
UNION ALL SELECT 236, 'SONIRI.A.3.003', 'Cyan Zabaione', 'SECT', 34 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 237 oen_id, 'SONIRI.A.3.004' oen_cd, 'Persimmon Tom Yum' oen_name, 'SECT' oet_cd, 34 oen_id_parent FROM dual
UNION ALL SELECT 238, 'SONIRI.A.3.005', 'Olive Green Samosa', 'SECT', 34 FROM dual
UNION ALL SELECT 239, 'SONIRI.A.3.006', 'Dusty Rose Pasta', 'SECT', 34 FROM dual
UNION ALL SELECT 240, 'SONIRI.A.4.001', 'Cyan Blue Tom Yum', 'SECT', 35 FROM dual
UNION ALL SELECT 241, 'SONIRI.A.4.002', 'Sienna Brown Pulled Pork', 'SECT', 35 FROM dual
UNION ALL SELECT 242, 'SONIRI.A.4.003', 'Lilac Purple Chana Masala', 'SECT', 35 FROM dual
UNION ALL SELECT 243, 'SONIRI.A.4.004', 'Peach Tiramisu', 'SECT', 35 FROM dual
UNION ALL SELECT 244, 'SONIRI.A.4.005', 'Slate Tandoori Chicken', 'SECT', 35 FROM dual
UNION ALL SELECT 245, 'SONIRI.A.4.006', 'Electric Blue Avocado', 'SECT', 35 FROM dual
UNION ALL SELECT 246, 'SONIRI.A.5.001', 'Emerald Chole Bhature', 'SECT', 36 FROM dual
UNION ALL SELECT 247, 'SONIRI.A.5.002', 'Maroon Taco', 'SECT', 36 FROM dual
UNION ALL SELECT 248, 'SONIRI.A.5.003', 'Almond Cassoulet', 'SECT', 36 FROM dual
UNION ALL SELECT 249, 'SONIRI.A.5.004', 'Topaz Peking Duck', 'SECT', 36 FROM dual
UNION ALL SELECT 250, 'SONIRI.A.6.001', 'Gold Naan', 'SECT', 37 FROM dual
UNION ALL SELECT 251, 'SONIRI.A.6.002', 'Pine Green Hainanese Chicken Ri', 'SECT', 37 FROM dual
UNION ALL SELECT 252, 'SONIRI.A.6.003', 'Almond Tom Yum', 'SECT', 37 FROM dual
UNION ALL SELECT 253, 'SONIRI.A.6.004', 'Papaya Shawarma', 'SECT', 37 FROM dual
UNION ALL SELECT 254, 'SONIRI.B.1.001', 'Ice Blue Banana Bread', 'SECT', 38 FROM dual
UNION ALL SELECT 255, 'SONIRI.B.1.002', 'Steel Blue Empanadas', 'SECT', 38 FROM dual
UNION ALL SELECT 256, 'SONIRI.B.1.003', 'Slate Sourdough Bread', 'SECT', 38 FROM dual
UNION ALL SELECT 257, 'SONIRI.B.1.004', 'Tan Brown Haggis', 'SECT', 38 FROM dual
UNION ALL SELECT 258, 'SONIRI.B.1.005', 'Honey Gyoza', 'SECT', 38 FROM dual
UNION ALL SELECT 259, 'SONIRI.B.2.001', 'Raspberry Soba', 'SECT', 39 FROM dual
UNION ALL SELECT 260, 'SONIRI.B.2.002', 'Persimmon Waffles', 'SECT', 39 FROM dual
UNION ALL SELECT 261, 'SONIRI.B.2.003', 'Sapphire Swiss Roll', 'SECT', 39 FROM dual
UNION ALL SELECT 262, 'SONIRI.B.2.004', 'Persimmon Pavlova', 'SECT', 39 FROM dual
UNION ALL SELECT 263, 'SONIRI.B.3.001', 'Beige Varenyky', 'SECT', 40 FROM dual
UNION ALL SELECT 264, 'SONIRI.B.3.002', 'Rust Maki Roll', 'SECT', 40 FROM dual
UNION ALL SELECT 265, 'SONIRI.B.3.003', 'Tomato Red Stroganoff', 'SECT', 40 FROM dual
UNION ALL SELECT 266, 'SONIRI.B.3.004', 'Silver Gyoza', 'SECT', 40 FROM dual
UNION ALL SELECT 267, 'SONIRI.B.3.005', 'Azure Tiramisu', 'SECT', 40 FROM dual
UNION ALL SELECT 268, 'SONIRI.B.4.001', 'Cornflower Blue Tonkatsu', 'SECT', 41 FROM dual
UNION ALL SELECT 269, 'SONIRI.B.4.002', 'Ruby Tacos', 'SECT', 41 FROM dual
UNION ALL SELECT 270, 'SONIRI.B.4.003', 'Steel Blue Zabaione', 'SECT', 41 FROM dual
UNION ALL SELECT 271, 'SONIRI.B.4.004', 'Coral Pink Peking Duck', 'SECT', 41 FROM dual
UNION ALL SELECT 272, 'SONIRI.C.1.001', 'Avocado Haggis', 'SECT', 42 FROM dual
UNION ALL SELECT 273, 'SONIRI.C.1.002', 'Seafoam Green Ramen', 'SECT', 42 FROM dual
UNION ALL SELECT 274, 'SONIRI.C.1.003', 'Amethyst Tajine', 'SECT', 42 FROM dual
UNION ALL SELECT 275, 'SONIRI.C.1.004', 'Brick Couscous', 'SECT', 42 FROM dual
UNION ALL SELECT 276, 'SONIRI.C.1.005', 'Denim Tzatziki', 'SECT', 42 FROM dual
UNION ALL SELECT 277, 'SONIRI.C.1.006', 'Midnight Blue Pastel de Choclo', 'SECT', 42 FROM dual
UNION ALL SELECT 278, 'SONIRI.C.2.001', 'Marigold Spring Rolls', 'SECT', 43 FROM dual
UNION ALL SELECT 279, 'SONIRI.C.2.002', 'Eggshell Taco', 'SECT', 43 FROM dual
UNION ALL SELECT 280, 'SONIRI.C.2.003', 'Raspberry Ravioli', 'SECT', 43 FROM dual
UNION ALL SELECT 281, 'SONIRI.C.2.004', 'Tangerine Pierogi', 'SECT', 43 FROM dual
UNION ALL SELECT 282, 'SONIRI.C.3.001', 'Marigold Hainanese Chicken Ri', 'SECT', 44 FROM dual
UNION ALL SELECT 283, 'SONIRI.C.3.002', 'Turquoise Blue Shawarma', 'SECT', 44 FROM dual
UNION ALL SELECT 284, 'SONIRI.C.3.003', 'Olive Shakshuka', 'SECT', 44 FROM dual
UNION ALL SELECT 285, 'SONIRI.C.3.004', 'Steel Grey Walnut Bread', 'SECT', 44 FROM dual
UNION ALL SELECT 286, 'SONIRI.C.3.005', 'Pine Green Tortilla Soup', 'SECT', 44 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 287 oen_id, 'SONIRI.C.3.006' oen_cd, 'Strawberry Risotto' oen_name, 'SECT' oet_cd, 44 oen_id_parent FROM dual
UNION ALL SELECT 288, 'SONIRI.C.4.001', 'Blue Poutine', 'SECT', 45 FROM dual
UNION ALL SELECT 289, 'SONIRI.C.4.002', 'Slate Grey Schnitzel', 'SECT', 45 FROM dual
UNION ALL SELECT 290, 'SONIRI.C.4.003', 'Cobalt Blue Pulled Pork', 'SECT', 45 FROM dual
UNION ALL SELECT 291, 'SONIRI.C.4.004', 'Forest Green Tortilla Soup', 'SECT', 45 FROM dual
UNION ALL SELECT 292, 'SONIRI.C.4.005', 'Cobalt Blue Pancakes', 'SECT', 45 FROM dual
UNION ALL SELECT 293, 'SONIRI.C.4.006', 'Slate Grey Varenyky', 'SECT', 45 FROM dual
UNION ALL SELECT 294, 'SONIRI.C.5.001', 'Lavender Walnut Bread', 'SECT', 46 FROM dual
UNION ALL SELECT 295, 'SONIRI.C.5.002', 'Sapphire Pastel de Choclo', 'SECT', 46 FROM dual
UNION ALL SELECT 296, 'SONIRI.C.5.003', 'Chocolate Brown Tonkatsu', 'SECT', 46 FROM dual
UNION ALL SELECT 297, 'SONIRI.C.5.004', 'Blue Arepas', 'SECT', 46 FROM dual
UNION ALL SELECT 298, 'SONIRI.C.5.005', 'Yellow Pancakes', 'SECT', 46 FROM dual
UNION ALL SELECT 299, 'SONIRI.C.5.006', 'Sunflower Yellow Tzatziki', 'SECT', 46 FROM dual
UNION ALL SELECT 300, 'SONIRI.C.6.001', 'Sapphire Blue Banana Bread', 'SECT', 47 FROM dual
UNION ALL SELECT 725, 'BAGETU.C.4.005', 'Mustard Mango Sticky Rice', 'SECT', 144 FROM dual
UNION ALL SELECT 726, 'BAGETU.C.4.006', 'Mint Chilaquiles', 'SECT', 144 FROM dual
UNION ALL SELECT 727, 'BAGETU.D.1.001', 'Heather Tikka Masala', 'SECT', 145 FROM dual
UNION ALL SELECT 728, 'BAGETU.D.1.002', 'Apricot Moussaka', 'SECT', 145 FROM dual
UNION ALL SELECT 729, 'BAGETU.D.1.003', 'Orchid Sarma', 'SECT', 145 FROM dual
UNION ALL SELECT 730, 'BAGETU.D.1.004', 'Lime Green Tajine', 'SECT', 145 FROM dual
UNION ALL SELECT 731, 'BAGETU.D.2.001', 'Lemon Lime Pastel de Choclo', 'SECT', 146 FROM dual
UNION ALL SELECT 732, 'BAGETU.D.2.002', 'Periwinkle Burgers', 'SECT', 146 FROM dual
UNION ALL SELECT 733, 'BAGETU.D.2.003', 'Sandstone Tikka Masala', 'SECT', 146 FROM dual
UNION ALL SELECT 734, 'BAGETU.D.2.004', 'Sapphire Blue Ceviche', 'SECT', 146 FROM dual
UNION ALL SELECT 735, 'BAGETU.D.2.005', 'Sea Green Pasta', 'SECT', 146 FROM dual
UNION ALL SELECT 736, 'BAGETU.D.2.006', 'Ruby Red Yakitori', 'SECT', 146 FROM dual
UNION ALL SELECT 737, 'BAGETU.D.3.001', 'Burgundy Zopf', 'SECT', 147 FROM dual
UNION ALL SELECT 738, 'BAGETU.D.3.002', 'Almond Zabaione', 'SECT', 147 FROM dual
UNION ALL SELECT 739, 'BAGETU.D.3.003', 'Teal Surf and Turf', 'SECT', 147 FROM dual
UNION ALL SELECT 740, 'BAGETU.D.3.004', 'Peacock Blue Red Curry', 'SECT', 147 FROM dual
UNION ALL SELECT 741, 'BAGETU.D.3.005', 'Rust Shakshuka', 'SECT', 147 FROM dual
UNION ALL SELECT 742, 'BAGETU.D.3.006', 'Seashell Varenyky', 'SECT', 147 FROM dual
UNION ALL SELECT 743, 'BAGETU.D.4.001', 'Magenta Truffle', 'SECT', 148 FROM dual
UNION ALL SELECT 744, 'BAGETU.D.4.002', 'Rose Pink Haggis', 'SECT', 148 FROM dual
UNION ALL SELECT 745, 'BAGETU.D.4.003', 'Baby Blue Peking Duck', 'SECT', 148 FROM dual
UNION ALL SELECT 746, 'BAGETU.D.4.004', 'Lavender Blue Soba', 'SECT', 148 FROM dual
UNION ALL SELECT 747, 'BAGETU.D.4.005', 'Slate Blue Xiao Long Bao', 'SECT', 148 FROM dual
UNION ALL SELECT 748, 'BAGETU.D.4.006', 'Lemon Yellow Falafel', 'SECT', 148 FROM dual
UNION ALL SELECT 749, 'BAGETU.D.5.001', 'Steel Blue Samosa', 'SECT', 149 FROM dual
UNION ALL SELECT 750, 'BAGETU.D.5.002', 'Dark Green Kebab', 'SECT', 149 FROM dual
UNION ALL SELECT 751, 'BAGETU.D.5.003', 'Dusty Rose Jiaozi', 'SECT', 149 FROM dual
UNION ALL SELECT 752, 'BAGETU.D.5.004', 'Slate Grey Pasta', 'SECT', 149 FROM dual
UNION ALL SELECT 753, 'BAGETU.D.5.005', 'Maroon Red Vietnamese Pho', 'SECT', 149 FROM dual
UNION ALL SELECT 754, 'BAGETU.D.6.001', 'Caramel Risotto', 'SECT', 150 FROM dual
UNION ALL SELECT 755, 'BAGETU.D.6.002', 'Cobalt Blue Maki Roll', 'SECT', 150 FROM dual
UNION ALL SELECT 756, 'BAGETU.D.6.003', 'Pearl Avocado', 'SECT', 150 FROM dual
UNION ALL SELECT 757, 'BAGETU.D.6.004', 'Lemon Chana Masala', 'SECT', 150 FROM dual
UNION ALL SELECT 758, 'BAGETU.E.1.001', 'Magenta Shrimp and Grits', 'SECT', 151 FROM dual
UNION ALL SELECT 759, 'BAGETU.E.1.002', 'Slate Grey Som Tam', 'SECT', 151 FROM dual
UNION ALL SELECT 760, 'BAGETU.E.1.003', 'Cobalt Blue Tapas', 'SECT', 151 FROM dual
;
INSERT INTO demo_org_entities_tde (oen_id, oen_cd, oen_name, oet_cd, oen_id_parent)
SELECT 761 oen_id, 'BAGETU.E.1.004' oen_cd, 'Orchid Tortilla de Patata' oen_name, 'SECT' oet_cd, 151 oen_id_parent FROM dual
UNION ALL SELECT 762, 'BAGETU.E.1.005', 'Coral Pink Pancakes', 'SECT', 151 FROM dual
UNION ALL SELECT 763, 'BAGETU.E.1.006', 'Cornflower Blue Tonkatsu', 'SECT', 151 FROM dual
UNION ALL SELECT 764, 'BAGETU.E.2.001', 'Celadon Cannoli', 'SECT', 152 FROM dual
UNION ALL SELECT 765, 'BAGETU.E.2.002', 'Tan Brown Zongzi', 'SECT', 152 FROM dual
UNION ALL SELECT 766, 'BAGETU.E.2.003', 'Peacock Tandoori Chicken', 'SECT', 152 FROM dual
UNION ALL SELECT 767, 'BAGETU.E.2.004', 'Electric Green Soto', 'SECT', 152 FROM dual
UNION ALL SELECT 768, 'BAGETU.E.2.005', 'Topaz Pozole', 'SECT', 152 FROM dual
UNION ALL SELECT 769, 'BAGETU.E.2.006', 'Emerald Wagyu Beef', 'SECT', 152 FROM dual
UNION ALL SELECT 770, 'BAGETU.E.3.001', 'Raspberry Poutine', 'SECT', 153 FROM dual
UNION ALL SELECT 771, 'BAGETU.E.3.002', 'Strawberry Yams', 'SECT', 153 FROM dual
UNION ALL SELECT 772, 'BAGETU.E.3.003', 'Sienna Brown Bratwurst', 'SECT', 153 FROM dual
UNION ALL SELECT 773, 'BAGETU.E.3.004', 'Cobalt Blue Borscht', 'SECT', 153 FROM dual
UNION ALL SELECT 774, 'BAGETU.E.3.005', 'Blue Cannoli', 'SECT', 153 FROM dual
UNION ALL SELECT 775, 'BAGETU.E.4.001', 'Slate Grey Tamales', 'SECT', 154 FROM dual
UNION ALL SELECT 776, 'BAGETU.E.4.002', 'Moss Pavlova', 'SECT', 154 FROM dual
UNION ALL SELECT 777, 'BAGETU.E.4.003', 'Blue Hamburger', 'SECT', 154 FROM dual
UNION ALL SELECT 778, 'BAGETU.E.4.004', 'Cobalt Blue Chimichurri', 'SECT', 154 FROM dual
UNION ALL SELECT 779, 'BAGETU.E.4.005', 'Coral Cannoli', 'SECT', 154 FROM dual
UNION ALL SELECT 780, 'BAGETU.E.5.001', 'Silver Crepes', 'SECT', 155 FROM dual
UNION ALL SELECT 781, 'BAGETU.E.5.002', 'Turquoise Blue Tikka Masala', 'SECT', 155 FROM dual
UNION ALL SELECT 782, 'BAGETU.E.5.003', 'Indigo Stroganoff', 'SECT', 155 FROM dual
UNION ALL SELECT 783, 'BAGETU.E.5.004', 'Eggshell Ravioli', 'SECT', 155 FROM dual
UNION ALL SELECT 784, 'BAGETU.E.5.005', 'Electric Blue Tortillas', 'SECT', 155 FROM dual
UNION ALL SELECT 785, 'BAGETU.E.6.001', 'Beige Shakshuka', 'SECT', 156 FROM dual
UNION ALL SELECT 786, 'BAGETU.E.6.002', 'Ivory White Pad See Ew', 'SECT', 156 FROM dual
UNION ALL SELECT 787, 'BAGETU.E.6.003', 'Lemon Yellow Ravioli', 'SECT', 156 FROM dual
UNION ALL SELECT 788, 'BAGETU.E.6.004', 'Ice Blue Yakitori', 'SECT', 156 FROM dual
UNION ALL SELECT 789, 'BAGETU.E.6.005', 'Eggplant Bibimbap', 'SECT', 156 FROM dual
UNION ALL SELECT 790, 'BAGETU.E.6.006', 'Turquoise Rendang', 'SECT', 156 FROM dual
UNION ALL SELECT 791, 'BAGETU.F.1.001', 'Ruby Red Cassoulet', 'SECT', 157 FROM dual
UNION ALL SELECT 792, 'BAGETU.F.1.002', 'Mustard Pad See Ew', 'SECT', 157 FROM dual
UNION ALL SELECT 793, 'BAGETU.F.1.003', 'Burnt Orange Smørrebrød', 'SECT', 157 FROM dual
UNION ALL SELECT 794, 'BAGETU.F.1.004', 'Sapphire Smørrebrød', 'SECT', 157 FROM dual
UNION ALL SELECT 795, 'BAGETU.F.1.005', 'Rose Pink Pastel de Choclo', 'SECT', 157 FROM dual
UNION ALL SELECT 796, 'BAGETU.F.2.001', 'Cyan Poutine', 'SECT', 158 FROM dual
UNION ALL SELECT 797, 'BAGETU.F.2.002', 'Brick Red Tacos', 'SECT', 158 FROM dual
UNION ALL SELECT 798, 'BAGETU.F.2.003', 'Moss Green Zopf', 'SECT', 158 FROM dual
UNION ALL SELECT 799, 'BAGETU.F.2.004', 'Apricot Enchiladas', 'SECT', 158 FROM dual
UNION ALL SELECT 800, 'BAGETU.F.2.005', 'Avocado Hummus', 'SECT', 158 FROM dual
UNION ALL SELECT 801, 'BAGETU.F.2.006', 'Lime Green Zongzi', 'SECT', 158 FROM dual
UNION ALL SELECT 802, 'BAGETU.F.3.001', 'Maroon Red Goulash', 'SECT', 159 FROM dual
UNION ALL SELECT 803, 'BAGETU.F.3.002', 'Mocha Dumplings', 'SECT', 159 FROM dual
UNION ALL SELECT 804, 'BAGETU.F.3.003', 'Burnt Orange Tiramisu', 'SECT', 159 FROM dual
UNION ALL SELECT 805, 'BAGETU.F.3.004', 'Baby Green Tortillas', 'SECT', 159 FROM dual
UNION ALL SELECT 806, 'BAGETU.F.4.001', 'Marigold Crepes', 'SECT', 160 FROM dual
UNION ALL SELECT 807, 'BAGETU.F.4.002', 'Navy Blue Waffles', 'SECT', 160 FROM dual
UNION ALL SELECT 808, 'BAGETU.F.4.003', 'Baby Pink Falafel', 'SECT', 160 FROM dual
UNION ALL SELECT 809, 'BAGETU.F.4.004', 'Aqua Falafel', 'SECT', 160 FROM dual
;
INSERT INTO demo_persons_tde (per_id, first_name, last_name, full_name, gender, birth_date, nationality, title, manager_flag, per_id_manager)
SELECT 10 per_id, 'Kenneth' first_name, 'Lefebvre' last_name, 'Kenneth Lefebvre' full_name, 'M' gender, TO_DATE('16/03/1975 00:00:00','DD/MM/YYYY HH24:MI:SS') birth_date, 'FRA' nationality, 'Mr' title, 'Y' manager_flag, NULL per_id_manager FROM dual
UNION ALL SELECT 20, 'Luis', 'Ramirez', 'Luis Ramirez', 'M', TO_DATE('05/10/1997 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ESP', 'Mr', 'Y', NULL FROM dual
UNION ALL SELECT 30, 'Gary', 'Fontana', 'Gary Fontana', 'M', TO_DATE('24/05/1979 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Mr', 'Y', NULL FROM dual
UNION ALL SELECT 40, 'Pierre', 'Garcia', 'Pierre Garcia', 'M', TO_DATE('27/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', 'Mr', 'Y', NULL FROM dual
UNION ALL SELECT 50, 'Audrey', 'Hoffmann', 'Audrey Hoffmann', 'F', TO_DATE('15/02/1991 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'SWE', 'Miss', 'Y', NULL FROM dual
;

INSERT INTO demo_persons_tde (per_id, first_name, last_name, full_name, gender, birth_date, nationality, title, manager_flag, per_id_manager)
SELECT 1 per_id, 'Walter' first_name, 'Galli' last_name, 'Walter Galli' full_name, 'M' gender, TO_DATE('25/05/1982 00:00:00','DD/MM/YYYY HH24:MI:SS') birth_date, 'DEU' nationality, 'Mr' title, NULL manager_flag, 40 per_id_manager FROM dual
UNION ALL SELECT 2, 'Georges', 'Vos', 'Georges Vos', 'M', TO_DATE('05/08/1967 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'NLD', NULL, NULL, 30 FROM dual
UNION ALL SELECT 3, 'Mary', 'Claes', 'Mary Claes', 'F', TO_DATE('08/08/1962 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'BEL', NULL, NULL, 50 FROM dual
UNION ALL SELECT 4, 'Annie', 'Coppola', 'Annie Coppola', 'F', TO_DATE('01/08/1969 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Ms', NULL, 10 FROM dual
UNION ALL SELECT 5, 'Luc', 'Hendriks', 'Luc Hendriks', 'M', TO_DATE('28/12/1975 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'NLD', 'Mr', NULL, 20 FROM dual
UNION ALL SELECT 6, 'Thomas', 'De Smet', 'Thomas De Smet', 'M', TO_DATE('31/07/1987 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'BEL', 'Mr', NULL, 40 FROM dual
UNION ALL SELECT 7, 'Ashley', 'Martinelli', 'Ashley Martinelli', 'F', TO_DATE('29/04/1987 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Mrs', NULL, 30 FROM dual
UNION ALL SELECT 8, 'Joan', 'Gomez', 'Joan Gomez', 'F', TO_DATE('29/12/1979 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ROU', 'Mrs', NULL, 50 FROM dual
UNION ALL SELECT 9, 'Charlotte', 'Ferraro', 'Charlotte Ferraro', 'F', TO_DATE('03/11/1966 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'HUN', NULL, NULL, 10 FROM dual
UNION ALL SELECT 11, 'Cynthia', 'Schmitz', 'Cynthia Schmitz', 'F', TO_DATE('11/12/1961 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ITA', NULL, NULL, 20 FROM dual
UNION ALL SELECT 12, 'Yvonne', 'Garcia', 'Yvonne Garcia', 'F', TO_DATE('27/09/1981 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'POL', 'Mrs', NULL, 40 FROM dual
UNION ALL SELECT 13, 'Francois', 'Schiltz', 'Francois Schiltz', 'M', TO_DATE('13/06/1984 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ITA', 'Mr', NULL, 30 FROM dual
UNION ALL SELECT 14, 'Jacqueline', 'Bonnet', 'Jacqueline Bonnet', 'F', TO_DATE('22/10/1973 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', 'Ms', NULL, 50 FROM dual
UNION ALL SELECT 15, 'Tyler', 'De Boer', 'Tyler De Boer', 'M', TO_DATE('17/07/1966 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'POL', NULL, NULL, 10 FROM dual
UNION ALL SELECT 16, 'Philippe', 'De Luca', 'Philippe De Luca', 'M', TO_DATE('22/09/1990 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Mr', NULL, 20 FROM dual
UNION ALL SELECT 17, 'Robert', 'Janssens', 'Robert Janssens', 'M', TO_DATE('11/01/1966 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'AUT', NULL, NULL, 40 FROM dual
UNION ALL SELECT 18, 'Rosa', 'Schneider', 'Rosa Schneider', 'F', TO_DATE('21/10/1986 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ESP', 'Mrs', NULL, 30 FROM dual
UNION ALL SELECT 19, 'Catherine', 'Bertrand', 'Catherine Bertrand', 'F', TO_DATE('03/08/1973 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', 'Ms', NULL, 50 FROM dual
UNION ALL SELECT 21, 'Angela', 'Rizzo', 'Angela Rizzo', 'F', TO_DATE('16/08/1961 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', NULL, NULL, 10 FROM dual
UNION ALL SELECT 22, 'Evelyn', 'Jimenez', 'Evelyn Jimenez', 'F', TO_DATE('03/09/1995 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ROU', 'Miss', NULL, 20 FROM dual
UNION ALL SELECT 23, 'Jan', 'Muller', 'Jan Muller', 'M', TO_DATE('07/03/2004 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ITA', 'Mr', NULL, 40 FROM dual
UNION ALL SELECT 24, 'Anna', 'Denis', 'Anna Denis', 'F', TO_DATE('18/03/1974 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'CZE', 'Ms', NULL, 30 FROM dual
UNION ALL SELECT 25, 'Carlos', 'Dekker', 'Carlos Dekker', 'M', TO_DATE('28/02/1984 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'NLD', 'Mr', NULL, 50 FROM dual
UNION ALL SELECT 26, 'Andrew', 'Garcia', 'Andrew Garcia', 'M', TO_DATE('16/10/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', 'Mr', NULL, 10 FROM dual
UNION ALL SELECT 27, 'Maria', 'Wouters', 'Maria Wouters', 'F', TO_DATE('01/02/1990 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'BEL', 'Miss', NULL, 20 FROM dual
UNION ALL SELECT 28, 'Laura', 'Benali', 'Laura Benali', 'F', TO_DATE('11/01/1975 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FIN', 'Mrs', NULL, 40 FROM dual
UNION ALL SELECT 29, 'Luc', 'Hendriks', 'Luc Hendriks', 'M', TO_DATE('20/03/1984 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'NLD', 'Mr', NULL, 30 FROM dual
UNION ALL SELECT 31, 'Brian', 'Girard', 'Brian Girard', 'M', TO_DATE('13/07/1967 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', NULL, NULL, 50 FROM dual
UNION ALL SELECT 32, 'Jeannine', 'Sanz', 'Jeannine Sanz', 'F', TO_DATE('13/01/1993 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ESP', 'Miss', NULL, 10 FROM dual
UNION ALL SELECT 33, 'Amy', 'Wagner', 'Amy Wagner', 'F', TO_DATE('15/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ITA', 'Miss', NULL, 20 FROM dual
UNION ALL SELECT 34, 'Peter', 'Richard', 'Peter Richard', 'M', TO_DATE('11/04/1960 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', NULL, NULL, 40 FROM dual
UNION ALL SELECT 35, 'Hannah', 'Torres', 'Hannah Torres', 'F', TO_DATE('27/02/1966 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'SVN', NULL, NULL, 30 FROM dual
UNION ALL SELECT 36, 'Dominique', 'Sala', 'Dominique Sala', 'F', TO_DATE('07/01/1990 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'HUN', 'Miss', NULL, 50 FROM dual
UNION ALL SELECT 37, 'Cynthia', 'Schroeder', 'Cynthia Schroeder', 'F', TO_DATE('27/11/1983 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ITA', 'Mrs', NULL, 10 FROM dual
UNION ALL SELECT 38, 'Veronique', 'Hoffmann', 'Veronique Hoffmann', 'F', TO_DATE('27/03/1981 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'SWE', 'Mrs', NULL, 20 FROM dual
UNION ALL SELECT 39, 'Emily', 'Lombardi', 'Emily Lombardi', 'F', TO_DATE('26/02/1983 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Mrs', NULL, 40 FROM dual
UNION ALL SELECT 41, 'Debra', 'Ruiz', 'Debra Ruiz', 'F', TO_DATE('02/01/1999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ROU', 'Miss', NULL, 30 FROM dual
UNION ALL SELECT 42, 'James', 'Maes', 'James Maes', 'M', TO_DATE('08/06/1968 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'AUT', NULL, NULL, 50 FROM dual
UNION ALL SELECT 43, 'Michelle', 'Bruno', 'Michelle Bruno', 'F', TO_DATE('30/09/1977 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'DEU', 'Mrs', NULL, 10 FROM dual
UNION ALL SELECT 44, 'Bruno', 'Schulz', 'Bruno Schulz', 'M', TO_DATE('25/09/1987 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'SWE', 'Mr', NULL, 20 FROM dual
UNION ALL SELECT 45, 'Richard', 'Dupont', 'Richard Dupont', 'M', TO_DATE('19/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'BGR', 'Mr', NULL, 40 FROM dual
UNION ALL SELECT 46, 'Susan', 'Martinez', 'Susan Martinez', 'F', TO_DATE('27/11/1962 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', NULL, NULL, 30 FROM dual
UNION ALL SELECT 47, 'Louis', 'Andre', 'Louis Andre', 'M', TO_DATE('01/04/1969 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'FRA', 'Mr', NULL, 50 FROM dual
UNION ALL SELECT 48, 'Alexandre', 'Wagner', 'Alexandre Wagner', 'M', TO_DATE('27/09/1964 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'SWE', NULL, NULL, 10 FROM dual
UNION ALL SELECT 49, 'Simon', 'Morales', 'Simon Morales', 'M', TO_DATE('15/09/1986 00:00:00','DD/MM/YYYY HH24:MI:SS'), 'ESP', 'Mr', NULL, 20 FROM dual
;
INSERT INTO demo_products_tde (prd_id, product_name, unit_price)
SELECT 1 prd_id, 'Maroon Red Bowtie' product_name, 51 unit_price FROM dual
UNION ALL SELECT 2, 'Maroon Easel', 62 FROM dual
UNION ALL SELECT 3, 'Lemon Yellow Shoe', 47 FROM dual
UNION ALL SELECT 4, 'Pink Sink', 30 FROM dual
UNION ALL SELECT 5, 'Cornflower Blue Headphones', 78 FROM dual
UNION ALL SELECT 6, 'Charcoal Grey Banana', 39 FROM dual
UNION ALL SELECT 7, 'Steel Grey Radio', 35 FROM dual
UNION ALL SELECT 8, 'Lemon Planner', 42 FROM dual
UNION ALL SELECT 9, 'Sea Green Computer', 36 FROM dual
UNION ALL SELECT 10, 'Aqua Hanger', 68 FROM dual
UNION ALL SELECT 11, 'Powder Pink Blender', 71 FROM dual
UNION ALL SELECT 12, 'Corn Yellow Car', 45 FROM dual
UNION ALL SELECT 13, 'Cobalt Blue Sculpture', 92 FROM dual
UNION ALL SELECT 14, 'Tomato Red Folder', 85 FROM dual
UNION ALL SELECT 15, 'Wine Shampoo', 44 FROM dual
UNION ALL SELECT 16, 'Moss Green Plate', 44 FROM dual
UNION ALL SELECT 17, 'Charcoal Grey Envelope', 83 FROM dual
UNION ALL SELECT 18, 'Denim Volleyball', 20 FROM dual
UNION ALL SELECT 19, 'Periwinkle Egg', 37 FROM dual
UNION ALL SELECT 20, 'Sage Green Nail clippers', 75 FROM dual
UNION ALL SELECT 21, 'Cobalt Blue Candle holder', 84 FROM dual
UNION ALL SELECT 22, 'Baby Purple Toilet paper', 94 FROM dual
UNION ALL SELECT 23, 'Peacock Green Laundry basket', 24 FROM dual
UNION ALL SELECT 24, 'Plum Candle holder', 45 FROM dual
UNION ALL SELECT 25, 'Burgundy Tablet', 48 FROM dual
UNION ALL SELECT 26, 'Plum Zipper', 37 FROM dual
UNION ALL SELECT 27, 'Rust Apple', 58 FROM dual
UNION ALL SELECT 28, 'Baby Purple Envelopes', 42 FROM dual
UNION ALL SELECT 29, 'Sandalwood Egg', 44 FROM dual
UNION ALL SELECT 30, 'Wine Red Yoga mat', 72 FROM dual
UNION ALL SELECT 31, 'Beige White Juicer', 89 FROM dual
UNION ALL SELECT 32, 'Ruby Red Ball', 34 FROM dual
UNION ALL SELECT 33, 'Sand Paper shredder', 30 FROM dual
UNION ALL SELECT 34, 'Moss Coffee table', 82 FROM dual
UNION ALL SELECT 35, 'Sandstone Fork', 26 FROM dual
UNION ALL SELECT 36, 'Coral Pink Wardrobe', 95 FROM dual
UNION ALL SELECT 37, 'Khaki Freezer', 39 FROM dual
UNION ALL SELECT 38, 'Slate Suitcase', 87 FROM dual
UNION ALL SELECT 39, 'Baby Blue Wrench', 51 FROM dual
UNION ALL SELECT 40, 'Celadon Bowl', 91 FROM dual
UNION ALL SELECT 41, 'Peacock Blue Scale', 94 FROM dual
UNION ALL SELECT 42, 'Aqua Blue Guitar', 25 FROM dual
UNION ALL SELECT 43, 'Plum Toilet paper', 51 FROM dual
UNION ALL SELECT 44, 'Pine Green Coffee machine', 28 FROM dual
UNION ALL SELECT 45, 'Beige Microphone', 43 FROM dual
UNION ALL SELECT 46, 'Rose Pink Fax machine', 35 FROM dual
UNION ALL SELECT 47, 'Eggplant Clock', 71 FROM dual
UNION ALL SELECT 48, 'Raspberry Stapler', 85 FROM dual
UNION ALL SELECT 49, 'Moss Clock', 49 FROM dual
UNION ALL SELECT 50, 'Electric Purple Tweezers', 19 FROM dual
;
INSERT INTO demo_stores_tde (sto_id, store_name)
SELECT 1 sto_id, 'Omni Elite Office Works' store_name FROM dual
UNION ALL SELECT 2, 'Axi Tranquil Movies Group' FROM dual
UNION ALL SELECT 3, 'Proto Vibrant Flowers Works' FROM dual
UNION ALL SELECT 4, 'Synth Serene Toys AI' FROM dual
UNION ALL SELECT 5, 'Axi Trusted Automobiles Tech' FROM dual
UNION ALL SELECT 6, 'Omni Expert Flowers Corp' FROM dual
UNION ALL SELECT 7, 'Xero Sustainable Appliances Tech' FROM dual
UNION ALL SELECT 8, 'Tru Prime Pharmaceuticals Inc' FROM dual
UNION ALL SELECT 9, 'Proto Prosperous Watches HQ' FROM dual
UNION ALL SELECT 10, 'Penta Modern Music X' FROM dual
;
INSERT INTO demo_orders_tde (ord_id, per_id, sto_id, order_date, total_price)
SELECT 1 ord_id, 1 per_id, 6 sto_id, TO_DATE('03/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS') order_date, 665 total_price FROM dual
UNION ALL SELECT 2, 2, 7, TO_DATE('24/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 516 FROM dual
UNION ALL SELECT 3, 2, 5, TO_DATE('28/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 408 FROM dual
UNION ALL SELECT 4, 3, 9, TO_DATE('29/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 264 FROM dual
UNION ALL SELECT 5, 4, 10, TO_DATE('05/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 862 FROM dual
UNION ALL SELECT 6, 4, 2, TO_DATE('23/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 42 FROM dual
UNION ALL SELECT 7, 4, 8, TO_DATE('11/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 964 FROM dual
UNION ALL SELECT 8, 4, 4, TO_DATE('01/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1146 FROM dual
UNION ALL SELECT 9, 5, 1, TO_DATE('22/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 333 FROM dual
UNION ALL SELECT 10, 5, 3, TO_DATE('06/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 494 FROM dual
UNION ALL SELECT 11, 5, 6, TO_DATE('01/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1173 FROM dual
UNION ALL SELECT 12, 5, 7, TO_DATE('23/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 48 FROM dual
UNION ALL SELECT 13, 5, 5, TO_DATE('24/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 354 FROM dual
UNION ALL SELECT 14, 6, 9, TO_DATE('30/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 376 FROM dual
UNION ALL SELECT 15, 6, 10, TO_DATE('01/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 111 FROM dual
UNION ALL SELECT 16, 6, 2, TO_DATE('10/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 889 FROM dual
UNION ALL SELECT 17, 6, 8, TO_DATE('30/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1419 FROM dual
UNION ALL SELECT 18, 7, 4, TO_DATE('22/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1240 FROM dual
UNION ALL SELECT 19, 7, 1, TO_DATE('18/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 84 FROM dual
UNION ALL SELECT 20, 7, 3, TO_DATE('01/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 360 FROM dual
UNION ALL SELECT 21, 7, 6, TO_DATE('24/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1169 FROM dual
UNION ALL SELECT 22, 7, 7, TO_DATE('01/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 126 FROM dual
UNION ALL SELECT 23, 8, 5, TO_DATE('22/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1053 FROM dual
UNION ALL SELECT 24, 8, 9, TO_DATE('06/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 664 FROM dual
UNION ALL SELECT 25, 9, 10, TO_DATE('21/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 28 FROM dual
UNION ALL SELECT 26, 9, 2, TO_DATE('25/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 877 FROM dual
UNION ALL SELECT 27, 9, 8, TO_DATE('17/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1014 FROM dual
UNION ALL SELECT 28, 10, 4, TO_DATE('29/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1938 FROM dual
UNION ALL SELECT 29, 10, 1, TO_DATE('27/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 216 FROM dual
UNION ALL SELECT 30, 10, 3, TO_DATE('26/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 248 FROM dual
UNION ALL SELECT 31, 11, 6, TO_DATE('13/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 640 FROM dual
UNION ALL SELECT 32, 11, 7, TO_DATE('16/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1079 FROM dual
UNION ALL SELECT 33, 11, 5, TO_DATE('03/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1402 FROM dual
UNION ALL SELECT 34, 11, 9, TO_DATE('09/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 194 FROM dual
UNION ALL SELECT 35, 11, 10, TO_DATE('08/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 468 FROM dual
UNION ALL SELECT 36, 12, 2, TO_DATE('08/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 492 FROM dual
UNION ALL SELECT 37, 13, 8, TO_DATE('13/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 252 FROM dual
UNION ALL SELECT 38, 13, 4, TO_DATE('01/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1691 FROM dual
UNION ALL SELECT 39, 13, 1, TO_DATE('24/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1035 FROM dual
UNION ALL SELECT 40, 13, 3, TO_DATE('08/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 380 FROM dual
UNION ALL SELECT 41, 14, 6, TO_DATE('21/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1374 FROM dual
UNION ALL SELECT 42, 14, 7, TO_DATE('17/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 392 FROM dual
UNION ALL SELECT 43, 14, 5, TO_DATE('19/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 653 FROM dual
UNION ALL SELECT 44, 14, 9, TO_DATE('10/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1314 FROM dual
UNION ALL SELECT 45, 15, 10, TO_DATE('25/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 555 FROM dual
UNION ALL SELECT 46, 15, 2, TO_DATE('22/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 94 FROM dual
UNION ALL SELECT 47, 15, 8, TO_DATE('20/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 431 FROM dual
UNION ALL SELECT 48, 15, 4, TO_DATE('03/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 877 FROM dual
UNION ALL SELECT 49, 15, 1, TO_DATE('08/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 120 FROM dual
UNION ALL SELECT 50, 16, 3, TO_DATE('04/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 38 FROM dual
;
INSERT INTO demo_orders_tde (ord_id, per_id, sto_id, order_date, total_price)
SELECT 51 ord_id, 18 per_id, 6 sto_id, TO_DATE('20/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS') order_date, 1388 total_price FROM dual
UNION ALL SELECT 52, 18, 7, TO_DATE('02/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 982 FROM dual
UNION ALL SELECT 53, 18, 5, TO_DATE('27/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1014 FROM dual
UNION ALL SELECT 54, 19, 9, TO_DATE('05/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 105 FROM dual
UNION ALL SELECT 55, 19, 10, TO_DATE('05/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 164 FROM dual
UNION ALL SELECT 56, 19, 2, TO_DATE('01/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 364 FROM dual
UNION ALL SELECT 57, 19, 8, TO_DATE('09/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1187 FROM dual
UNION ALL SELECT 58, 19, 4, TO_DATE('18/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 796 FROM dual
UNION ALL SELECT 59, 20, 1, TO_DATE('16/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 579 FROM dual
UNION ALL SELECT 60, 20, 3, TO_DATE('29/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 506 FROM dual
UNION ALL SELECT 61, 20, 6, TO_DATE('30/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 362 FROM dual
UNION ALL SELECT 62, 20, 7, TO_DATE('02/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 864 FROM dual
UNION ALL SELECT 63, 22, 5, TO_DATE('22/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1165 FROM dual
UNION ALL SELECT 64, 23, 9, TO_DATE('23/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 25 FROM dual
UNION ALL SELECT 65, 24, 10, TO_DATE('31/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 107 FROM dual
UNION ALL SELECT 66, 24, 2, TO_DATE('10/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1168 FROM dual
UNION ALL SELECT 67, 24, 8, TO_DATE('12/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 241 FROM dual
UNION ALL SELECT 68, 25, 4, TO_DATE('18/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 750 FROM dual
UNION ALL SELECT 69, 26, 1, TO_DATE('03/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 258 FROM dual
UNION ALL SELECT 70, 28, 3, TO_DATE('30/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 919 FROM dual
UNION ALL SELECT 71, 28, 6, TO_DATE('29/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1825 FROM dual
UNION ALL SELECT 72, 28, 7, TO_DATE('26/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1277 FROM dual
UNION ALL SELECT 73, 30, 5, TO_DATE('17/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 630 FROM dual
UNION ALL SELECT 74, 30, 9, TO_DATE('10/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 595 FROM dual
UNION ALL SELECT 75, 30, 10, TO_DATE('15/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 44 FROM dual
UNION ALL SELECT 76, 30, 2, TO_DATE('02/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 411 FROM dual
UNION ALL SELECT 77, 30, 8, TO_DATE('31/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 919 FROM dual
UNION ALL SELECT 78, 32, 4, TO_DATE('03/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1224 FROM dual
UNION ALL SELECT 79, 32, 1, TO_DATE('15/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 605 FROM dual
UNION ALL SELECT 80, 32, 3, TO_DATE('18/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 420 FROM dual
UNION ALL SELECT 81, 34, 6, TO_DATE('04/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 913 FROM dual
UNION ALL SELECT 82, 34, 7, TO_DATE('14/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 199 FROM dual
UNION ALL SELECT 83, 34, 5, TO_DATE('01/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 499 FROM dual
UNION ALL SELECT 84, 34, 9, TO_DATE('24/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 404 FROM dual
UNION ALL SELECT 85, 34, 10, TO_DATE('31/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 419 FROM dual
UNION ALL SELECT 86, 35, 2, TO_DATE('15/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1179 FROM dual
UNION ALL SELECT 87, 35, 8, TO_DATE('27/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 958 FROM dual
UNION ALL SELECT 88, 35, 4, TO_DATE('18/11/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 255 FROM dual
UNION ALL SELECT 89, 35, 1, TO_DATE('07/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1199 FROM dual
UNION ALL SELECT 90, 36, 3, TO_DATE('30/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 822 FROM dual
UNION ALL SELECT 91, 36, 6, TO_DATE('08/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 255 FROM dual
UNION ALL SELECT 92, 37, 7, TO_DATE('03/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1304 FROM dual
UNION ALL SELECT 93, 37, 5, TO_DATE('27/02/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 749 FROM dual
UNION ALL SELECT 94, 37, 9, TO_DATE('04/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1099 FROM dual
UNION ALL SELECT 95, 37, 10, TO_DATE('27/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1044 FROM dual
UNION ALL SELECT 96, 38, 2, TO_DATE('03/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1039 FROM dual
UNION ALL SELECT 97, 38, 8, TO_DATE('08/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 679 FROM dual
UNION ALL SELECT 98, 38, 4, TO_DATE('15/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 640 FROM dual
UNION ALL SELECT 99, 38, 1, TO_DATE('02/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 654 FROM dual
UNION ALL SELECT 100, 40, 3, TO_DATE('05/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1119 FROM dual
;
INSERT INTO demo_orders_tde (ord_id, per_id, sto_id, order_date, total_price)
SELECT 101 ord_id, 41 per_id, 6 sto_id, TO_DATE('07/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS') order_date, 1234 total_price FROM dual
UNION ALL SELECT 102, 42, 7, TO_DATE('09/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1977 FROM dual
UNION ALL SELECT 103, 43, 5, TO_DATE('14/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 356 FROM dual
UNION ALL SELECT 104, 43, 9, TO_DATE('09/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 769 FROM dual
UNION ALL SELECT 105, 43, 10, TO_DATE('16/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 306 FROM dual
UNION ALL SELECT 106, 44, 2, TO_DATE('02/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1093 FROM dual
UNION ALL SELECT 107, 45, 8, TO_DATE('30/12/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1273 FROM dual
UNION ALL SELECT 108, 45, 4, TO_DATE('26/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 914 FROM dual
UNION ALL SELECT 109, 45, 1, TO_DATE('15/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 531 FROM dual
UNION ALL SELECT 110, 45, 3, TO_DATE('02/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 774 FROM dual
UNION ALL SELECT 111, 45, 6, TO_DATE('10/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 765 FROM dual
UNION ALL SELECT 112, 46, 7, TO_DATE('25/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1244 FROM dual
UNION ALL SELECT 113, 46, 5, TO_DATE('29/09/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1138 FROM dual
UNION ALL SELECT 114, 46, 9, TO_DATE('17/01/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 44 FROM dual
UNION ALL SELECT 115, 47, 10, TO_DATE('05/05/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 739 FROM dual
UNION ALL SELECT 116, 48, 2, TO_DATE('09/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1368 FROM dual
UNION ALL SELECT 117, 48, 8, TO_DATE('05/08/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1500 FROM dual
UNION ALL SELECT 118, 48, 4, TO_DATE('22/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1280 FROM dual
UNION ALL SELECT 119, 48, 1, TO_DATE('02/03/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1099 FROM dual
UNION ALL SELECT 120, 48, 3, TO_DATE('11/10/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 468 FROM dual
UNION ALL SELECT 121, 50, 6, TO_DATE('20/07/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 422 FROM dual
UNION ALL SELECT 122, 50, 7, TO_DATE('14/06/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 607 FROM dual
UNION ALL SELECT 123, 50, 5, TO_DATE('29/04/2025 14:21:52','DD/MM/YYYY HH24:MI:SS'), 1370 FROM dual
;
INSERT INTO demo_per_assignments_tde (per_id, date_from, date_to, oen_id)
SELECT 1 per_id, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS') date_from, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS') date_to, 508 oen_id FROM dual
UNION ALL SELECT 1, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 669 FROM dual
UNION ALL SELECT 1, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 363 FROM dual
UNION ALL SELECT 1, TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 607 FROM dual
UNION ALL SELECT 1, TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 429 FROM dual
UNION ALL SELECT 2, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 211 FROM dual
UNION ALL SELECT 2, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 532 FROM dual
UNION ALL SELECT 2, TO_DATE('01/06/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 575 FROM dual
UNION ALL SELECT 2, TO_DATE('01/11/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 87 FROM dual
UNION ALL SELECT 2, TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 128 FROM dual
UNION ALL SELECT 3, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 636 FROM dual
UNION ALL SELECT 3, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 713 FROM dual
UNION ALL SELECT 3, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 517 FROM dual
UNION ALL SELECT 3, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 151 FROM dual
UNION ALL SELECT 3, TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 276 FROM dual
UNION ALL SELECT 4, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 598 FROM dual
UNION ALL SELECT 4, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 655 FROM dual
UNION ALL SELECT 4, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 546 FROM dual
UNION ALL SELECT 4, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 417 FROM dual
UNION ALL SELECT 5, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 571 FROM dual
UNION ALL SELECT 5, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 277 FROM dual
UNION ALL SELECT 5, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 572 FROM dual
UNION ALL SELECT 5, TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 95 FROM dual
UNION ALL SELECT 5, TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 230 FROM dual
UNION ALL SELECT 6, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 502 FROM dual
UNION ALL SELECT 6, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 540 FROM dual
UNION ALL SELECT 6, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 468 FROM dual
UNION ALL SELECT 6, TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 622 FROM dual
UNION ALL SELECT 6, TO_DATE('01/06/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 565 FROM dual
UNION ALL SELECT 7, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 556 FROM dual
UNION ALL SELECT 7, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 786 FROM dual
UNION ALL SELECT 7, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 239 FROM dual
UNION ALL SELECT 7, TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 764 FROM dual
UNION ALL SELECT 8, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 587 FROM dual
UNION ALL SELECT 8, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 449 FROM dual
UNION ALL SELECT 8, TO_DATE('01/07/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 89 FROM dual
UNION ALL SELECT 9, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 690 FROM dual
UNION ALL SELECT 9, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 460 FROM dual
UNION ALL SELECT 9, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 731 FROM dual
UNION ALL SELECT 10, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 618 FROM dual
UNION ALL SELECT 10, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 121 FROM dual
UNION ALL SELECT 10, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 165 FROM dual
UNION ALL SELECT 11, TO_DATE('01/05/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 505 FROM dual
UNION ALL SELECT 11, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 767 FROM dual
UNION ALL SELECT 11, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 238 FROM dual
UNION ALL SELECT 12, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 278 FROM dual
UNION ALL SELECT 12, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 139 FROM dual
UNION ALL SELECT 12, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 653 FROM dual
UNION ALL SELECT 12, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 450 FROM dual
UNION ALL SELECT 13, TO_DATE('01/03/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 421 FROM dual
;
INSERT INTO demo_per_assignments_tde (per_id, date_from, date_to, oen_id)
SELECT 13 per_id, TO_DATE('01/05/2000 00:00:00','DD/MM/YYYY HH24:MI:SS') date_from, TO_DATE('01/07/2000 00:00:00','DD/MM/YYYY HH24:MI:SS') date_to, 459 oen_id FROM dual
UNION ALL SELECT 13, TO_DATE('01/07/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 348 FROM dual
UNION ALL SELECT 13, TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 493 FROM dual
UNION ALL SELECT 13, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 270 FROM dual
UNION ALL SELECT 14, TO_DATE('01/09/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 464 FROM dual
UNION ALL SELECT 14, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 741 FROM dual
UNION ALL SELECT 14, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 78 FROM dual
UNION ALL SELECT 14, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 123 FROM dual
UNION ALL SELECT 15, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 744 FROM dual
UNION ALL SELECT 15, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 702 FROM dual
UNION ALL SELECT 15, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 319 FROM dual
UNION ALL SELECT 15, TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 101 FROM dual
UNION ALL SELECT 16, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 269 FROM dual
UNION ALL SELECT 16, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 416 FROM dual
UNION ALL SELECT 16, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 109 FROM dual
UNION ALL SELECT 16, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 548 FROM dual
UNION ALL SELECT 17, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 268 FROM dual
UNION ALL SELECT 17, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 60 FROM dual
UNION ALL SELECT 17, TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 225 FROM dual
UNION ALL SELECT 17, TO_DATE('01/12/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 628 FROM dual
UNION ALL SELECT 18, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 436 FROM dual
UNION ALL SELECT 18, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 694 FROM dual
UNION ALL SELECT 18, TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 783 FROM dual
UNION ALL SELECT 18, TO_DATE('01/10/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 550 FROM dual
UNION ALL SELECT 19, TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 586 FROM dual
UNION ALL SELECT 19, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 781 FROM dual
UNION ALL SELECT 19, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 15 FROM dual
UNION ALL SELECT 20, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 569 FROM dual
UNION ALL SELECT 20, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 425 FROM dual
UNION ALL SELECT 20, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 342 FROM dual
UNION ALL SELECT 20, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 576 FROM dual
UNION ALL SELECT 21, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 192 FROM dual
UNION ALL SELECT 21, TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 471 FROM dual
UNION ALL SELECT 21, TO_DATE('01/03/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 640 FROM dual
UNION ALL SELECT 22, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 224 FROM dual
UNION ALL SELECT 22, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 758 FROM dual
UNION ALL SELECT 22, TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 347 FROM dual
UNION ALL SELECT 23, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 295 FROM dual
UNION ALL SELECT 23, TO_DATE('01/07/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 484 FROM dual
UNION ALL SELECT 23, TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 356 FROM dual
UNION ALL SELECT 23, TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 199 FROM dual
UNION ALL SELECT 24, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 539 FROM dual
UNION ALL SELECT 24, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 507 FROM dual
UNION ALL SELECT 24, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 286 FROM dual
UNION ALL SELECT 24, TO_DATE('01/05/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 594 FROM dual
UNION ALL SELECT 25, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 236 FROM dual
UNION ALL SELECT 25, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 476 FROM dual
UNION ALL SELECT 25, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 382 FROM dual
UNION ALL SELECT 25, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 107 FROM dual
UNION ALL SELECT 26, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 36 FROM dual
;
INSERT INTO demo_per_assignments_tde (per_id, date_from, date_to, oen_id)
SELECT 26 per_id, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS') date_from, TO_DATE('01/04/2002 00:00:00','DD/MM/YYYY HH24:MI:SS') date_to, 654 oen_id FROM dual
UNION ALL SELECT 26, TO_DATE('01/04/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 250 FROM dual
UNION ALL SELECT 26, TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 259 FROM dual
UNION ALL SELECT 26, TO_DATE('01/09/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 595 FROM dual
UNION ALL SELECT 27, TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 47 FROM dual
UNION ALL SELECT 27, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 41 FROM dual
UNION ALL SELECT 27, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 212 FROM dual
UNION ALL SELECT 28, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 623 FROM dual
UNION ALL SELECT 28, TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 385 FROM dual
UNION ALL SELECT 28, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 170 FROM dual
UNION ALL SELECT 28, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 62 FROM dual
UNION ALL SELECT 28, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 510 FROM dual
UNION ALL SELECT 29, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 610 FROM dual
UNION ALL SELECT 29, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 129 FROM dual
UNION ALL SELECT 29, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 630 FROM dual
UNION ALL SELECT 30, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 612 FROM dual
UNION ALL SELECT 30, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 554 FROM dual
UNION ALL SELECT 30, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 635 FROM dual
UNION ALL SELECT 31, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 137 FROM dual
UNION ALL SELECT 31, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 637 FROM dual
UNION ALL SELECT 31, TO_DATE('01/02/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 252 FROM dual
UNION ALL SELECT 31, TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 284 FROM dual
UNION ALL SELECT 31, TO_DATE('01/03/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 589 FROM dual
UNION ALL SELECT 32, TO_DATE('01/08/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 515 FROM dual
UNION ALL SELECT 32, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 25 FROM dual
UNION ALL SELECT 32, TO_DATE('01/07/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 354 FROM dual
UNION ALL SELECT 32, TO_DATE('01/08/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), 433 FROM dual
UNION ALL SELECT 32, TO_DATE('01/04/2003 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 762 FROM dual
UNION ALL SELECT 33, TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 667 FROM dual
UNION ALL SELECT 33, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 395 FROM dual
UNION ALL SELECT 33, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 247 FROM dual
UNION ALL SELECT 33, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 10 FROM dual
UNION ALL SELECT 34, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 146 FROM dual
UNION ALL SELECT 34, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 18 FROM dual
UNION ALL SELECT 34, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 649 FROM dual
UNION ALL SELECT 34, TO_DATE('01/05/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 408 FROM dual
UNION ALL SELECT 34, TO_DATE('01/12/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 495 FROM dual
UNION ALL SELECT 35, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 412 FROM dual
UNION ALL SELECT 35, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 204 FROM dual
UNION ALL SELECT 35, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 153 FROM dual
UNION ALL SELECT 35, TO_DATE('01/08/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 424 FROM dual
UNION ALL SELECT 36, TO_DATE('01/09/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 632 FROM dual
UNION ALL SELECT 36, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 580 FROM dual
UNION ALL SELECT 36, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 399 FROM dual
UNION ALL SELECT 37, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 723 FROM dual
UNION ALL SELECT 37, TO_DATE('01/05/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 732 FROM dual
UNION ALL SELECT 37, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 43 FROM dual
UNION ALL SELECT 37, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 343 FROM dual
UNION ALL SELECT 37, TO_DATE('01/04/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 161 FROM dual
UNION ALL SELECT 38, TO_DATE('01/06/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 122 FROM dual
;
INSERT INTO demo_per_assignments_tde (per_id, date_from, date_to, oen_id)
SELECT 38 per_id, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS') date_from, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS') date_to, 12 oen_id FROM dual
UNION ALL SELECT 38, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 674 FROM dual
UNION ALL SELECT 39, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 526 FROM dual
UNION ALL SELECT 39, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 735 FROM dual
UNION ALL SELECT 39, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 99 FROM dual
UNION ALL SELECT 39, TO_DATE('01/09/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 216 FROM dual
UNION ALL SELECT 39, TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 442 FROM dual
UNION ALL SELECT 40, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 217 FROM dual
UNION ALL SELECT 40, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 141 FROM dual
UNION ALL SELECT 40, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 707 FROM dual
UNION ALL SELECT 40, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 84 FROM dual
UNION ALL SELECT 41, TO_DATE('01/11/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 227 FROM dual
UNION ALL SELECT 41, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 700 FROM dual
UNION ALL SELECT 41, TO_DATE('01/05/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 124 FROM dual
UNION ALL SELECT 41, TO_DATE('01/08/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 323 FROM dual
UNION ALL SELECT 42, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 131 FROM dual
UNION ALL SELECT 42, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 756 FROM dual
UNION ALL SELECT 42, TO_DATE('01/01/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 475 FROM dual
UNION ALL SELECT 42, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 359 FROM dual
UNION ALL SELECT 42, TO_DATE('01/01/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 528 FROM dual
UNION ALL SELECT 43, TO_DATE('01/02/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 197 FROM dual
UNION ALL SELECT 43, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 6 FROM dual
UNION ALL SELECT 43, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 346 FROM dual
UNION ALL SELECT 44, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 647 FROM dual
UNION ALL SELECT 44, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 251 FROM dual
UNION ALL SELECT 44, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 338 FROM dual
UNION ALL SELECT 45, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 657 FROM dual
UNION ALL SELECT 45, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 703 FROM dual
UNION ALL SELECT 45, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/04/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 200 FROM dual
UNION ALL SELECT 45, TO_DATE('01/04/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 719 FROM dual
UNION ALL SELECT 46, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 267 FROM dual
UNION ALL SELECT 46, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), 39 FROM dual
UNION ALL SELECT 46, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 273 FROM dual
UNION ALL SELECT 46, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 511 FROM dual
UNION ALL SELECT 46, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 126 FROM dual
UNION ALL SELECT 47, TO_DATE('01/04/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 738 FROM dual
UNION ALL SELECT 47, TO_DATE('01/02/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 110 FROM dual
UNION ALL SELECT 47, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 57 FROM dual
UNION ALL SELECT 47, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 483 FROM dual
UNION ALL SELECT 48, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 353 FROM dual
UNION ALL SELECT 48, TO_DATE('01/03/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 609 FROM dual
UNION ALL SELECT 48, TO_DATE('01/10/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 405 FROM dual
UNION ALL SELECT 48, TO_DATE('01/09/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 440 FROM dual
UNION ALL SELECT 49, TO_DATE('01/10/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 169 FROM dual
UNION ALL SELECT 49, TO_DATE('01/06/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 466 FROM dual
UNION ALL SELECT 49, TO_DATE('01/11/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/03/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 272 FROM dual
UNION ALL SELECT 49, TO_DATE('01/03/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 374 FROM dual
UNION ALL SELECT 50, TO_DATE('01/12/2000 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), 796 FROM dual
UNION ALL SELECT 50, TO_DATE('01/12/2001 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('01/11/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), 407 FROM dual
UNION ALL SELECT 50, TO_DATE('01/11/2002 00:00:00','DD/MM/YYYY HH24:MI:SS'), TO_DATE('31/12/9999 00:00:00','DD/MM/YYYY HH24:MI:SS'), 631 FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 1 per_id, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:51:23' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 1, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:58', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:51', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:27', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:11', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:32', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:49', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:22', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:48', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:01', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:35', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:42', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:36', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:19', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:32', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:19', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:02', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:25', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:16', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:59', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:28', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:00', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:53', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:17', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:59', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:01', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:24', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:08', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:06', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:54', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:01', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:55:32', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:32', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:00', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:07', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:56:08', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:48', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:47', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:41', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:04', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:04', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:10', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:37', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:35', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:04', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:27', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:37', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:53:17', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:30', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:00', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 1 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:00:49' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 1, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:52', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:48', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:24', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:20', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:54', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:28', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:15', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:20', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:40', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:02', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:27', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:13', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:23', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:19', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:19', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:56', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:05', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:32', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:00', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:39', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:48', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:32', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:43', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:39', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:46', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:37', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:19', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:05', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:52', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:05', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:07', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:00', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:17', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:59', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:15', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:15', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:02', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:01', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:15', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:45', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:41', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:24', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:20', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:48', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:57', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:05', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:51', 'OUT' FROM dual
UNION ALL SELECT 1, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:35', 'IN' FROM dual
UNION ALL SELECT 1, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:36', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 2 per_id, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:57:06' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 2, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:50', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:20', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:43:20', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:16', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:00', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:54', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:57', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:10', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:25', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:17', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:11:51', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:52', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:13', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:26', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:52', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:29:58', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:59', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:48', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:33:25', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:21', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:27', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:42', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:07', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:48', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:09', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:38', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:41', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:01', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:32', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:36', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:42', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:24', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:09', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:05', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:55', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:37', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:53', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:18', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:31', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:16', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:21', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:34', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:16', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:29', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:41', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:20', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:16', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:35', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:17', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 2 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:05:23' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 2, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:38', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:13', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:37', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:02', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:11', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:01', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:47', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:18', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:32', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:22', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:49', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:03', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:47', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:40', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:07', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:20', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:23', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:21', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:49', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:32', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:21', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:24', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:40', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:42', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:28', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:10', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:54', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:24', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:40', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:34', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:48', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:45', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:18:19', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:29', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:19', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:32', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:18', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:31', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:30', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:11', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:26', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:50', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:38', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:09', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:48', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:53', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:16', 'OUT' FROM dual
UNION ALL SELECT 2, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:27', 'IN' FROM dual
UNION ALL SELECT 2, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:41', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 3 per_id, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:03:50' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 3, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:04', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:42', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:40', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:59', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:37', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:36', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:55:04', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:54', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:08', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:49', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:54', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:45', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:36', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:19', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:39', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:59', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:41', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:49', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:53:12', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:05', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:06', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:13', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:44', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:52', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:16', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:54', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:05', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:09', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:19', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:21', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:45', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:05', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:34', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:42', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:55', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:24', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:58', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:54', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:17', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:39', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:22', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:15', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:17', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:47', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:28', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:29', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:22', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:30', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:49', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 3 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:28:57' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 3, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:48', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:48', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:11', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:37', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:09', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:35', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:12', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:16', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:15', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:25', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:10', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:08', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:11', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:32', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:14', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:49', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:32', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:28', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:32:46', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:10', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:26', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:56', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:02', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:30', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:56', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:38', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:17', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:42', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:41', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:08', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:06:09', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:53', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:11', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:12', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:37', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:24', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:18', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:48', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:51', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:04', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:34', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:32', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:14', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:13', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:24', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:17', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:58', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:00', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:23', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 6 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:15:08' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 6, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:54', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:00', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:25', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:33', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:20', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:21', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:14', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:00', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:21', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:45', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:44', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:07', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:45:29', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:45', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:54', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:04', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:32', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:33', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:07', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:25', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:04', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:50', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:26', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:35', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:12', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:58', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:25', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:40', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:51', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:47', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:20', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:04', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:36', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:12', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:07', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:15', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:13', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:32', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:35', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:42', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:19', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:35', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:47', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:07', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:24:29', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:53', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:18', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:41', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:31:36', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 7 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:31:07' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 7, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:02', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:09', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:21', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:10', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:38', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:07', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:02', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:39', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:10', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:01', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:22:04', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:15', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:27', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:41', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:22:32', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:47', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:50', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:01', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:32:43', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:28', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:20', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:28', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:54', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:59', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:03', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:47', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:43', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:35', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:37', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:10', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:31:10', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:41', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:49', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:00', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:32', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:10', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:04', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:10', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:46', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:48', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:08', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:13', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:47:57', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:34', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:42', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:03', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:46', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:08', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:10', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 7 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:38:38' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 7, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:01', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:31', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:23', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:01', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:19', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:06', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:51', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:40', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:26', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:27', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:58', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:31', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:54', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:50', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:46', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:27', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:04', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:57', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:40', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:03', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:01', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:13', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:10', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:05', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:49', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:40', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:31', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:31', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:16:11', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:55', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:47', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:26', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:31', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:06', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:49', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:18', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:05', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:41', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:53', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:36', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:03', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:00', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:24', 'OUT' FROM dual
UNION ALL SELECT 7, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:48', 'IN' FROM dual
UNION ALL SELECT 7, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:25:52', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:01', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:29', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:09', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:44', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 8 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:20:36' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 8, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:47', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:15', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:32:45', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:58:37', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:34', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:09', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:27', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:00', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:53', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:44', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:01:32', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:36', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:33', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:06', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:41', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:32', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:13', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:14', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:13', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:54', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:32', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:03', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:54', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:44', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:04', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:55', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:24', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:48', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:00', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:05', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:56', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:43', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:54', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:11', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:50', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:42', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:30', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:17', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:11', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:51', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:29', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:13', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:51', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:32', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:54', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:32', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:09', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:38', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:36', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 8 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:03:30' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 8, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:08', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:24', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:19', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:31', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:04', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:53', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:10', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:41', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:43', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:30', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:55', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:43', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:38', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:11', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:37', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:43', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:17', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:39', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:56', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:19', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:03', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:03', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:07', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:52', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:47', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:37', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:57', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:50', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:40', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:00', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:21', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:23', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:39', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:14', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:26', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:04', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:42', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:55', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:31', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:34', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:53', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:36', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:52', 'OUT' FROM dual
UNION ALL SELECT 8, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:56', 'IN' FROM dual
UNION ALL SELECT 8, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:01', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:38', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:39', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:16', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:20', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 9 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:34:06' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 9, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:49', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:12', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:32:04', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:10', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:48', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:29', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:26', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:41', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:11', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:59', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:15', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:45', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:44', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:50', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:05', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:23', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:21', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:26', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:28', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:15', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:01', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:49', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:16', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:22', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:52', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:22', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:21', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:34', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:15', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:48', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:18', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:53', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:35', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:19', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:56:09', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:22', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:58', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:59', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:55', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:38', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:25', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:36', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:32:21', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:33', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:06', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:55', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:25:21', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:44', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:24', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 9 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:08:16' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 9, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:06', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:42', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:09', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:24', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:55', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:52', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:25', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:35', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:43', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:39', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:00', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:29', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:24', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:58', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:52', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:42', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:58', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:48', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:22', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:39', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:32:46', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:41', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:07', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:12', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:37', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:49', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:44', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:56', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:19', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:09', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:20', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:39', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:26', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:17', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:15', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:00', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:56', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:48', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:36', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:07', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:50', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:55', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:35', 'OUT' FROM dual
UNION ALL SELECT 9, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:05', 'IN' FROM dual
UNION ALL SELECT 9, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:19', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:54', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:59', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:01', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:15:43', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 10 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:26:23' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 10, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:32', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:51', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:49', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:14', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:30', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:56', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:27', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:29', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:14', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:14', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:07', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:43', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:47', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:07', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:35', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:22', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:01', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:25', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:59', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:36', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:33', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:34', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:32:33', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:50', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:34', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:29', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:28', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:35', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:02', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:55', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:17', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:12', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:25', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:49', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:52', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:49', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:26', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:16', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:22', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:32', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:52', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:41', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:05', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:56', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:57', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:33', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:26', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:14', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:59', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 10 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:23:59' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 10, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:42', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:04', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:58', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:26', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:56', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:19', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:56', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:41', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:56:18', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:38', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:39', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:20', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:37', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:39', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:58', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:22', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:54', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:15', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:20', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:29', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:48', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:20', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:47', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:21', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:00', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:19', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:35', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:32', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:30:27', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:36', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:26', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:14', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:00', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:03', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:28', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:04', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:00:52', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:23', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:09', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:52', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:01', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:48', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:03', 'OUT' FROM dual
UNION ALL SELECT 10, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:11', 'IN' FROM dual
UNION ALL SELECT 10, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:23', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:03', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:16', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:12', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:00', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 11 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:54:39' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 11, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:49', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:04', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:57', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:37', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:58', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:21', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:13', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:24', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:20', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:09', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:32', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:33', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:37', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:04', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:48:29', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:47', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:26', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:11', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:29', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:11', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:56', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:49', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:09', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:38', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:59', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:34', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:54', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:58', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:11', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:47', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:03', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:36', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:58', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:00', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:09', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:00', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:45', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:48', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:58', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:47', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:25', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:40', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:24', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:56', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:46', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:05', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:30', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:32', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:30', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 11 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:39:21' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 11, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:57', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:02', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:34', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:37', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:06', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:01', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:13', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:55', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:18', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:10', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:12', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:14', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:33', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:17', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:21', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:32', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:13', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:04', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:44', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:46', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:15', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:16', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:11', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:58', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:46', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:23', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:25', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:24', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:58:52', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:12', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:55', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:32', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:30', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:24', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:47', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:44', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:18', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:14', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:35', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:28', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:37', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:25', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:48', 'OUT' FROM dual
UNION ALL SELECT 11, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:54', 'IN' FROM dual
UNION ALL SELECT 11, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:49', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:32', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:38', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:24', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:19', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 12 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:18:43' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 12, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:23', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:34', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:43', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:58:24', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:12', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:07', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:11', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:24', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:41', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:00', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:24', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:57', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:47', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:08', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:02', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:10', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:27', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:31', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:24', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:45', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:13', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:00', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:46', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:09', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:20', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:26', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:04:13', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:22', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:08', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:35', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:33', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:35', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:01', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:48', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:58', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:57', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:13', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:08', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:30', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:10', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:56', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:56', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:27:20', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:30', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:55', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:39', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:54', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:05', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:45', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 12 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:28:24' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 12, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:09', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:47', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:51', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:26', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:04', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:58', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:33', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:56', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:41', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:15', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:53', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:25', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:58', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:18', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:18', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:36', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:14', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:39', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:35', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:50', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:12', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:48', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:51', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:32', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:23', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:45', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:28', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:26', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:19', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:43', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:50', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:10', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:05', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:01', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:16', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:12', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:20', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:54', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:20', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:17', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:33', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:09', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:43', 'OUT' FROM dual
UNION ALL SELECT 12, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:40', 'IN' FROM dual
UNION ALL SELECT 12, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:19', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:00', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:44', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:47', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:14', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 13 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:34:45' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 13, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:41', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:16', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:54:36', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:11', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:18', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:05', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:56', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:47', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:47', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:11', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:31', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:14', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:26', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:17', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:44', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:41', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:30', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:54', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:10', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:47', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:08', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:51', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:03', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:40', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:15', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:12', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:46', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:27', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:28', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:40', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:54:28', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:25', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:01', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:28', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:20', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:53', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:50', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:44', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:54', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:03', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:51', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:28', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:13', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:00', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:42', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:16', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:01', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:36', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:03', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 13 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:24:24' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 13, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:09', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:34', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:56', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:26', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:59', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:21', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:59', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:12', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:25', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:34', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:29', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:22', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:22', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:45', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:06', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:37', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:19', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:27', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:03', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:32', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:54', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:35', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:20', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:30', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:02', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:53', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:56', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:01', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:33', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:32', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:52', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:13', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:38:25', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:04', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:46', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:45', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:38', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:00', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:40', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:19', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:28', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:58', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:26', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:37', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:25:13', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:52', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:49', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:15', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:05', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 3 per_id, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:45:37' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 3, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:18', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:29', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:35', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:19', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:43', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:10', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:57', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:16', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:47', 'OUT' FROM dual
UNION ALL SELECT 3, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:50', 'IN' FROM dual
UNION ALL SELECT 3, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:34', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:29', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:09', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:58', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:14', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:20', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:37', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:39', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:19', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:09', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:31', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:45', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:40', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:10', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:18', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:46', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:40', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:11', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:29', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:07', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:37', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:15', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:11', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:13', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:57', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:12', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:33', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:17', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:25', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:25', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:59', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:03', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:28', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:04', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:37', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:13', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:20', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:13', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:03', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 4 per_id, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:44:45' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 4, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:00', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:49', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:52', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:41', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:46', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:09', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:01', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:25', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:07', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:33', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:08', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:21', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:01', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:53', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:39', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:28', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:07', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:43', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:48', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:24', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:38', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:52', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:39', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:43', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:27', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:20', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:26', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:45', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:50', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:16', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:28', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:15', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:29', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:01', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:02', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:21', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:48', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:15', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:49', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:22', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:39', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:38', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:46', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:38', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:42', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:49', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:56', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:49', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:06', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 4 per_id, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:45:30' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 4, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:11', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:19', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:34', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:09', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:20', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:03', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:46', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:39', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:25', 'OUT' FROM dual
UNION ALL SELECT 4, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:06', 'IN' FROM dual
UNION ALL SELECT 4, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:38', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:57', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:44', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:08', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:54', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:59', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:31', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:38', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:15:16', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:40', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:07', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:48', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:41:37', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:33', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:06', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:49', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:43', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:06', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:06', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:08', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:01', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:06', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:16', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:44', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:55', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:54', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:23', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:01', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:20', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:10', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:54', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:05', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:25', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:33', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:11', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:17', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:09', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:50', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:49', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 5 per_id, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:44:26' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 5, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:35:17', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:11', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:28', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:25', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:18', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:24', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:36', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:08', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:54:20', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:03', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:57', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:16', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:04:56', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:23', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:23', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:13', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:47', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:03', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:43', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:16', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:45', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:25', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:25', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:15', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:31', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:15', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:51', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:53', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:08', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:02', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:07', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:03', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:22', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:01', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:10', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:25', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:59', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:39', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:09', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:14', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:15', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:09', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:54', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:48', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:18:30', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:46', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:41', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:55', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:33', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 5 per_id, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:02:30' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 5, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:32', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:19', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:50', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:50', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:29', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:23', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:15', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:49', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:09', 'OUT' FROM dual
UNION ALL SELECT 5, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:47', 'IN' FROM dual
UNION ALL SELECT 5, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:12', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:53', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:22', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:51', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:17', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:03', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:48', 'OUT' FROM dual
UNION ALL SELECT 6, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:08', 'IN' FROM dual
UNION ALL SELECT 6, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:48', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:28', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:04', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:47', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:03', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:41', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:25', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:06', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:39', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:37', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:13', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:21', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:41', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:56', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:35', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:03', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:56:17', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:40', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:18', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:20', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:56:30', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:38', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:47', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:13', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:29', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:30', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:42', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:16', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:48', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:24', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:34', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 16 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:26:41' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 16, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:20', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:34', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:59', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:09', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:45', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:17', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:39', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:02', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:46', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:04', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:23', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:44', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:05', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:59', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:07', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:30', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:07', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:53', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:40', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:44', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:13', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:19', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:37', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:00', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:51', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:07', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:17', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:09', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:59', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:15', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:17', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:56', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:39', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:35', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:44', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:46', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:01', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:14', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:06', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:44', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:49', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:39', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:35', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:38', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:49', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:59', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:56', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:24', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:19', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 17 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:54:00' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 17, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:23', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:50', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:16', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:17', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:06', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:17', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:31', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:51', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:05', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:33', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:06', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:41', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:20', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:24', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:36', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:40', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:18', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:12', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:23', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:40', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:01', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:43', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:30:52', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:19', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:21', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:37', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:29', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:37', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:56', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:16', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:02:40', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:29', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:18', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:04', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:06', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:32', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:47', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:17', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:58', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:16', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:46', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:40', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:01', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:13', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:33', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:48', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:28', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:46', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:25', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 17 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:02:32' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 17, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:28', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:27', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:23', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:27', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:53', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:44', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:54', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:47', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:13', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:53', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:39', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:02', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:46', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:36', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:45', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:38', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:34', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:54', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:34', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:50', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:11', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:33', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:43', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:35', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:45', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:49', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:03', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:54', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:15', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:19', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:11', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:54', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:38', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:59', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:06', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:46', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:22', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:05', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:05', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:58', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:52', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:13', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:29', 'OUT' FROM dual
UNION ALL SELECT 17, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:29', 'IN' FROM dual
UNION ALL SELECT 17, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:30', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:42', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:39', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:04', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:56', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 18 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:59:50' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 18, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:10', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:07', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:26', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:28', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:21', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:43', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:01', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:46', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:14', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:24', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:36', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:20:48', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:12', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:28', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:59', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:40', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:12', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:42', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:41', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:04', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:36', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:02', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:50:32', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:27', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:02', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:18', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:39', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:45', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:58', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:46', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:51', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:17', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:34', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:53', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:55', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:42', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:30', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:05', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:41', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:53', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:29', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:37', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:40', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:42', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:05', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:08', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:46', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:45', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:09', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 18 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:44:41' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 18, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:41', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:27', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:01', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:20', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:49', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:55', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:26', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:20', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:54', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:40', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:29', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:18', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:01', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:20', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:31', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:44', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:47', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:37', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:18', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:17', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:13', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:56', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:26', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:11', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:07', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:25', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:33', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:31', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:55', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:32', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:25', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:49', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:44', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:12', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:05', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:09', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:10', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:12', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:09', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:06', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:27', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:59', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:14', 'OUT' FROM dual
UNION ALL SELECT 18, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:05', 'IN' FROM dual
UNION ALL SELECT 18, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:06', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:47', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:45', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:27', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:07', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 19 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '07:53:06' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 19, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:09', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:03', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:07', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:47', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:11', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:04', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:23', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:02', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:29', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:46', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:11', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:18', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:44', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:35', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:22', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:00', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:59', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:00', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:24', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:09', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:47', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:36', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:53', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:05', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:18', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:10', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:12', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:55', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:19', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:35', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:55', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:52', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:52', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:33', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:03', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:29', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:35', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:05', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:03', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:01', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:44', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:32', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:47', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:20', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:20', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:42', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:54:51', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:37', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:20', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 19 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:47:12' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 19, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:54', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:51', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:51', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:08', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:04', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:59', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:46', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:58', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:24', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:25', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:26', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:45', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:13', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:28', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:42', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:11', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:02', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:32', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:25', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:16', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:00', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:53', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:33', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:48', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:32', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:14', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:22', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:25', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:34', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:20', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:59', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:02', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:18', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:39', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:26', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:48', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:43', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:31', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:06', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:11', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:49', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:21', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:25', 'OUT' FROM dual
UNION ALL SELECT 19, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:53', 'IN' FROM dual
UNION ALL SELECT 19, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:29', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:58:26', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:39', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:46', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:20', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 20 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:33:13' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 20, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:15', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:45', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:22:07', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:57', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:33', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:42', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:35', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:27', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:45', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:43', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:49', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:24', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:06', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:48', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:44', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:05', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:51', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:39', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:23', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:22', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:05', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:01', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:11', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:53', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:28', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:07', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:10', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:11', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:17', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:43', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:49', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:16:06', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:48', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:22', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:06', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:31', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:19', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:39', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:41', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:33', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:23', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:50', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:57', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:37', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:50', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:08', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:14:35', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:39', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:36', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 20 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:48:54' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 20, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:05', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:54', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:27', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:31', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:59', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:49', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:49', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:43', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:11', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:10', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:40', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:18', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:40', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:54', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:29', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:25', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:44', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:00', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:18', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:46', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:37', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:01', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:29', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:20', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:43', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:05', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:37', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:36', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:41', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:50', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:17', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:45', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:52', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:23', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:40', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:00', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:25:04', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:09', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:20', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:42', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:30', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:39', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:03', 'OUT' FROM dual
UNION ALL SELECT 20, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:26', 'IN' FROM dual
UNION ALL SELECT 20, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:19', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:55', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:20', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:56', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:47', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 21 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:54:06' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 21, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:35', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:45', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:23', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:28', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:27', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:06', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:56:52', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:02', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:02', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:11', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:08', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:47', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:34', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:00', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:21', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:57', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:27', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:45', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:27', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:16', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:58', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:23', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:58', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:56', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:04', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:05', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:49', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:44', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:32', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:32', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:41', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:16', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:29', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:48', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:43', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:52', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:13', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:22', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:24', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:10', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:44', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:13', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:22', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:03', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:12', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:13', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:46', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:41', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:48', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 21 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:39:47' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 21, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:42', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:06', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:36', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:13', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:38', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:46', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:04', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:34', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:44', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:29', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:26', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:43', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:14', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:29:02', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:06', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:11', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:47', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:00', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:56', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:04', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:36', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:43', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:28', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:06', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:38', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:06', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:43', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:44', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:59', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:24', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:30', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:41', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:48', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:51', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:46', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:07', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:42', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:09', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:55', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:32', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:59', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:40', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:59', 'OUT' FROM dual
UNION ALL SELECT 21, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:26', 'IN' FROM dual
UNION ALL SELECT 21, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:53', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:43', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:39', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:50', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:32', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 22 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:43:52' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 22, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:44', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:50', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:01', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:46', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:24', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:25', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:48', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:29:06', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:54', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:01', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:00:32', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:41', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:39', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:35', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:58', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:10', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:14', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:14', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:39', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:40', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:30', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:54', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:45', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:36', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:30', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:21', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:31:04', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:39', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:36', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:54', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:01', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:20', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:51', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:39', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:22:31', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:41', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:47', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:56', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:34', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:33', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:00', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:04', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:36', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:53', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:30', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:26', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:42', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:16:22', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:26', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 22 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:04:38' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 22, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:35', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:17', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:35', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:22', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:08', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:32', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:51', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:40', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:05', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:07', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:01', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:57', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:42', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:44', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:16', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:14', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:30:15', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:17', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:26', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:47', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:10', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:36', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:20', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:29', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:20', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:10', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:57', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:12', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:36', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:41', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:43', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:13', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:53', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:29', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:44', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:47', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:00', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:42', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:34', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:04', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:50', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:55', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:56', 'OUT' FROM dual
UNION ALL SELECT 22, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:49', 'IN' FROM dual
UNION ALL SELECT 22, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:07', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:47', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:26', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:03', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:29', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 23 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:33:24' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 23, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:10', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:13', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:43', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:16:06', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:22', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:58', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:18', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:05', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:03', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:16', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:35:15', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:06', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:20', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:43', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:11', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:18', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:49', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:29', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:28', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:19', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:59', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:27', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:09', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:23', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:16', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:21', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:25:24', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:01', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:09', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:32', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:14', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:06', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:41', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:05', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:47:18', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:33', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:31', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:42', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:01', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:44', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:58', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:58', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:43', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:51', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:39', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:55', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:37', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:13', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:57', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 23 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:26:50' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 23, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:07', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:28', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:08', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:30', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:01', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:30', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:53', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:31', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:06', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:53', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:03', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:06', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:51', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:08', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:13', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:59', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:56', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:57', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:43', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:41', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:49', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:55', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:25', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:47', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:05', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:50', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:42', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:16', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:25', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:44', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:09', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:33', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:27', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:11', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:43', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:36', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:02', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:05', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:38', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:19', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:17', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:26', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:22', 'OUT' FROM dual
UNION ALL SELECT 23, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:52', 'IN' FROM dual
UNION ALL SELECT 23, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:24', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:14', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:58', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:28', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:41:27', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 24 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:21:46' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 24, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:21', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:48', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:54', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:58', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:45', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:36', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:45', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:23', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:36', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:57', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:18:54', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:54', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:08', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:05', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:32', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:09', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:58', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:57', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:25', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:51', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:14', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:59', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:04:36', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:46', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:31', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:07', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:28', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:51', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:48', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:55', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:23', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:41', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:19', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:32', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:30:11', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:01', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:09', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:11', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:14', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:10', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:03', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:23', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:03', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:56', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:41', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:04', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:24', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:30', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:30', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 24 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:41:52' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 24, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:00', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:31', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:12', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:36', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:45', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:32', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:12', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:14', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:16', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:00', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:14', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:11', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:02:59', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:09', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:05', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:41', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:20', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:46', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:57', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:01', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:30:56', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:01', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:17', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:09', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:28', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:53', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:13', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:46', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:45', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:31', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:02', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:13', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:50:27', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:30', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:17', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:00', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:08', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:58', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:27', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:34', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:43:20', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:48', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:30', 'OUT' FROM dual
UNION ALL SELECT 24, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:07', 'IN' FROM dual
UNION ALL SELECT 24, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:57', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:18', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:57', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:30', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:54', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 25 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:04:04' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 25, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:33', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:37', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:31', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:24', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:43', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:40', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:32', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:22', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:03', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:33', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:26', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:40', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:08', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:27', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:41', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:29', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:50', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:56', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:52', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:20:26', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:39', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:31', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:05', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:47', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:17', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:32', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:56', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:22', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:25', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:46', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:33:55', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:15', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:42', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:18', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:49', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:24', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:17', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:53', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:38', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:08', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:10', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:12', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:04', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:16', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:16', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:14', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:12', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:48', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:44', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 25 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:00:58' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 25, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:51', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:52', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:13', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:18', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:46', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:29', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:08', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:52', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:37', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:52', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:57', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:39', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:57', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:15', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:45', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:25', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:53', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:16', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:12', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:54', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:02', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:23', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:59', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:08', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:38', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:29', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:10', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:31', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:02:22', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:06', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:10', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:30', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:23', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:53', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:28', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:25', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:34', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:39', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:10', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:22', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:10', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:23', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:24', 'OUT' FROM dual
UNION ALL SELECT 25, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:07', 'IN' FROM dual
UNION ALL SELECT 25, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:44', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:08', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:46', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:16', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:43', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 26 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:06:07' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 26, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:21', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:39', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:02', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:56', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:38', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:54', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:02', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:08', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:09', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:38', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:24:55', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:29', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:30', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:17', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:24', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:38', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:03', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:41', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:16', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:05', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:45', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:18', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:39', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:06', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:27', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:34', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:27', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:49', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:12', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:34', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:56:57', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:14', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:43', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:33', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:57', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:59', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:28', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:10', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:39', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:53', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:00', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:56', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:52', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:01', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:04', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:10', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:47', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:48', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:18', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 26 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:40:42' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 26, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:37', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:21', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:12', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:54', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:48:14', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:03', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:14', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:34', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:46', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:48', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:48', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:06', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:01', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:26', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:00', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:22', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:27', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:15', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:15', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:41', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:35', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:29', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:53', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:08', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:57', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:03', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:19', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:23', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:41', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:45', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:25', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:11', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:11', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:34', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:15', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:50', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:56:02', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:09', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:55', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:24', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:07:02', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:04', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:29', 'OUT' FROM dual
UNION ALL SELECT 26, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:26', 'IN' FROM dual
UNION ALL SELECT 26, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:42', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:48', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:08', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:01', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:17', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 27 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:48:40' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 27, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:14', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:41', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:23', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:46', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:58', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:17', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:02', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:40', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:29', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:46', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:11:20', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:23', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:41', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:53', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:18', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:49', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:44', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:50', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:31:56', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:39', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:30', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:09', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:06:05', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:35', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:10', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:31', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:44', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:17', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:11', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:08', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:28', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:39', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:49', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:56', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:16', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:52', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:59', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:50', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:54', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:02', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:14', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:09', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:51', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:17', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:52', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:24', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:24', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:58', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:17', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 27 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:26:40' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 27, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:12', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:27', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:39', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:46', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:15:37', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:18', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:09', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:57', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:50', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:05', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:37', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:50', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:37', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:46', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:14', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:52', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:00:48', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:20', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:23', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:24', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:12', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:01', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:10', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:39', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:03:42', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:31', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:15', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:42', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:45', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:30', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:39', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:02', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:22:47', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:31', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:31', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:40', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:46', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:58', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:05', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:53', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:52', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:09', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:55', 'OUT' FROM dual
UNION ALL SELECT 27, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:34', 'IN' FROM dual
UNION ALL SELECT 27, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:43', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:49', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:32', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:24', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:16', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 28 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '07:50:48' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 28, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:29', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:46', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:55', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:38', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:35', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:58', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:14:49', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:39', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:46', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:55', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:50', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:24', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:17', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:00', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:42', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:46', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:42', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:16', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:06', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:05', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:40', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:52', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:14', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:48', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:20', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:29', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:06', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:53', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:50', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:26', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:40', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:20', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:11', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:48', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:15', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:23', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:54', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:42', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:52', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:33', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:16', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:54', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:55', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:54', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:34', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:10', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:25', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:46', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:40', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 28 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:58:41' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 28, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:49', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:36', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:13', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:14', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:20', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:26', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:18', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:12', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:22', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:34', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:19', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:43', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:26', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:28', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:38', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:30', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:14', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:37', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:31', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:22', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:35', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:06', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:58', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:55', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:44', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:46', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:22', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:45', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:48', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:51', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:21', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:13', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:15', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:59', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:46', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:57', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:26', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:56', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:26', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:39', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:25', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:49', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:16', 'OUT' FROM dual
UNION ALL SELECT 28, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:05', 'IN' FROM dual
UNION ALL SELECT 28, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:48:15', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:08', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:01', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:39', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:57', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 29 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:56:46' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 29, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:59', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:36', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:46', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:29', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:12', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:57', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:54', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:59', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:50', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:48', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:22:33', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:22', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:49', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:51', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:54', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:14', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:19', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:44', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:30', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:41', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:50', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:20', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:12', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:09', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:30', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:34', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:14:23', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:31', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:47', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:28', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:04', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:29', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:00', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:16', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:24', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:47', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:03', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:38', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:28', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:47', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:51', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:50', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:56', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:23', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:23', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:47', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:38', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:17', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:06', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 29 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:14:50' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 29, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:10:33', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:57', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:41', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:32', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:36', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:01', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:31', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:27', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:28', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:07', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:14', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:13', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:02', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:07', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:50', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:29', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:40', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:39', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:35', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:25', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:29', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:22', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:09', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:15', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:03', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:50', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:23', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:11', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:33', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:41', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:06', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:43', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:12', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:26', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:59', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:01', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:56:04', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:39', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:02', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:37', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:51', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:07', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:37', 'OUT' FROM dual
UNION ALL SELECT 29, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:16', 'IN' FROM dual
UNION ALL SELECT 29, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:16:48', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:59', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:58', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:25', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:23', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 30 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:23:14' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 30, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:35', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:53', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:32', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:13', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:39', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:09', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:26', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:06', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:43', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:21', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:04:48', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:05', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:53', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:44', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:45:11', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:49', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:23', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:39', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:47', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:24', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:28', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:07', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:48', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:33', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:08', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:44', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:17', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:42', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:14', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:19', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:22', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:50', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:49', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:35', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:26', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:25', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:25', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:11', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:23', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:14', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:30', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:46', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:14', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:12', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:33', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:32', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:00', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:11', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:10', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 30 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:02:58' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 30, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:22', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:43', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:01', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:06', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:41', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:43', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:12', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:50', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:48', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:28', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:58', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:43', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:05', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:12', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:27', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:26', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:29', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:16:52', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:57', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:51', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:33', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:43', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:15', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:56', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:12', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:46', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:46', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:52', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:10:13', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:00', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:40', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:43', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:02', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:00', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:29', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:14', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:23', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:48', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:17', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:23', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:09', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:13', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:05', 'OUT' FROM dual
UNION ALL SELECT 30, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:23', 'IN' FROM dual
UNION ALL SELECT 30, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:53:43', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:08', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:35', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:03', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:03', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 31 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:35:09' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 31, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:11', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:12', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:41:31', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:32', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:30', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:08', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:33', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:31', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:52', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:18', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:37', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:24', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:12', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:37', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:15:26', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:35', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:37', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:00', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:42', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:05', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:29', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:38', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:57', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:45', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:37', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:20', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:46', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:51', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:29', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:02', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:48', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:55', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:41', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:29', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:49', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:35', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:07', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:02', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:24', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:12', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:07', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:01', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:53', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:50', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:38', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:11', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:35', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:34', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:41', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 31 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:38:43' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 31, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:25', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:18', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:27', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:47', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:18', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:10', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:18', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:09', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:19', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:12', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:26', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:51', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:16', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:54', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:07', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:13', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:41', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:29', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:09', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:39', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:13', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:34', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:00', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:51', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:50', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:36', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:45', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:20', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:56', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:49', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:57', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:20', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:20', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:18', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:54', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:55', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:58:15', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:51', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:03', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:22', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:47:48', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:30', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:44', 'OUT' FROM dual
UNION ALL SELECT 31, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:48', 'IN' FROM dual
UNION ALL SELECT 31, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:44', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:49', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:20', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:38', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:13', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 32 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:34:24' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 32, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:23', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:49', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:54', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:42', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:07', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:05', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:19', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:09', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:36', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:17', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:06', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:26', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:18', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:14', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:30:18', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:03', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:57', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:44', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:00:13', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:02', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:38', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:39', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:43', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:28', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:23', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:30', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:31', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:53', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:06', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:05', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:16', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:00', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:17', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:55', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:38', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:05', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:55', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:08', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:21', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:45', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:06', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:10', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:01', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:33', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:50', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:39', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:03', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:08', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:18', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 32 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:33:45' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 32, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:56', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:58', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:52', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:50', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:27', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:01', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:50', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:36', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:13', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:56', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:30', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:15', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:28', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:43', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:40', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:41', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:46', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:14', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:21', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:13', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:00', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:15', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:44', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:52', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:01', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:29', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:47', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:14', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:29', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:21', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:01', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:34', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:36', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:43', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:28', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:19', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:26', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:07', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:06', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:06', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:33', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:47', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:28', 'OUT' FROM dual
UNION ALL SELECT 32, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:10', 'IN' FROM dual
UNION ALL SELECT 32, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:44', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:10', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:25', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:52', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:34', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 33 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:54:13' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 33, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:06', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:08', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:36', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:22', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:40', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:24', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:41:30', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:58', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:46', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:05', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:37', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:08', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:03', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:11', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:35', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:25', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:15', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:16', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:16', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:29', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:34', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:09', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:53', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:59', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:33', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:28', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:09', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:27', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:36', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:48', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:47', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:56', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:04', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:26', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:25', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:45', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:21', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:26', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:32', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:58', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:09', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:42', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:56', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:00', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:01', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:04', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:27', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:22', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:03', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 33 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:42:28' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 33, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:52', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:42', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:59', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:39', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:48', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:42', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:36', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:36', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:22:44', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:42', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:04', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:02', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:16:51', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:58', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:56', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:08', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:50', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:53', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:22', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:34', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:18', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:11', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:41', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:00', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:09', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:39', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:12', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:51', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:15', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:41', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:10', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:00', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:31', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:25', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:17', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:31', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:40', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:03', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:24', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:14', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:25', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:22', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:37', 'OUT' FROM dual
UNION ALL SELECT 33, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:15', 'IN' FROM dual
UNION ALL SELECT 33, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:33', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:03', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:18', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:31', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:01', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 13 per_id, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '07:53:49' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 13, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:47', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:50', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:30', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:27', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:43', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:48', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:00', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:50', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:09', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:54', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:05', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:47', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:10', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:54', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:58', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:20:36', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:18', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:35', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:20', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:02', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:59', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:08', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:50', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:04', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:53', 'OUT' FROM dual
UNION ALL SELECT 13, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:44', 'IN' FROM dual
UNION ALL SELECT 13, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:40', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:25', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:05', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:37', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:23', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:07', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:47', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:49', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:08', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:51', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:16', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:35', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:41', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:31', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:03', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:59', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:33:33', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:46', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:50', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:28', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:15', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:19', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:48', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 14 per_id, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:42:21' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 14, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:52', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:59', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:43', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:27', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:55', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:11', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:54', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:39', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:32', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:50', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:01', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:38', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:38', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:47', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:10', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:51', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:02', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:12', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:08', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:24', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:41', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:41:26', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:29', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:17', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:48', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:52', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:57', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:44', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:56', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:31', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:48', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:25', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:33', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:03', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:30', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:28', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:41:30', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:08', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:19', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:22', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:45', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:43', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:02', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:22', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:00:41', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:36', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:06', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:44', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:53:01', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 14 per_id, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:25:39' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 14, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:23', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:19', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:05', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:26', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:47', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:32', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:59', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:21', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:25', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:41', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:56', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:01', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:35', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:24', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:27', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:18', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:06', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:42', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:48:51', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:02', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:28', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:26', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:21:40', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:42', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:47', 'OUT' FROM dual
UNION ALL SELECT 14, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:46', 'IN' FROM dual
UNION ALL SELECT 14, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:18', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:57', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:49', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:24', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:32', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:30', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:12', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:07', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:23', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:57', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:46', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:24', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:11', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:04', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:03', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:41', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:29', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:05', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:03', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:33', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:18:28', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:57', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:00', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 15 per_id, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:12:41' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 15, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:40', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:05', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:23', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:15', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:06', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:52', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:07', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:11', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:02', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:00', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:33', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:55', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:58', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:41', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:49', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:02', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:43', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:00', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:55', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:27', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:07', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:58', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:10', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:23', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:51:07', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:46:06', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:36', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:27', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:01', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:31', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:29', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:49', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:59', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:28', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:22', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:38', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:47:14', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:36', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:29', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:56', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:46', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:14', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:49', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:19', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:45', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:52', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:47', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:47', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:58', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 15 per_id, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '07:58:32' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 15, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:29', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:35', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:34', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:02', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:08', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:08', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:40', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:44', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:37', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:18', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:13', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:42', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:32', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:39', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:53', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:28', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:10', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:47', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:40', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:19', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:10', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:11', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:56:04', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:19', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:44', 'OUT' FROM dual
UNION ALL SELECT 15, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:42', 'IN' FROM dual
UNION ALL SELECT 15, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:11', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:34', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:15', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:29', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:26', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:22', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:54', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:18', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:36', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:12', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:43', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:09', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:16', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:04', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:06', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:58', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:25', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:13', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:54', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:50', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:06', 'OUT' FROM dual
UNION ALL SELECT 16, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:15', 'IN' FROM dual
UNION ALL SELECT 16, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:14', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 16 per_id, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:48:47' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 16, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:02', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:50', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:58', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:42', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:06', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:55', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:12', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:58:04', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:27', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:15', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:15', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:37', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:56', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:25', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:11:07', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:48', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:05', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:35', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:26', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:35', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:00', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:31', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:34', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:57', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:24', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:43', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:22', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:22', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:40', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:18', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:05', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:39', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:35', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:27', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:00:53', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:15', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:52', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:10', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:51', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:51', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:12', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:32', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:05', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:34', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:09', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:52', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:01', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:13', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:38', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 34 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:47:12' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 34, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:08', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:12', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:41', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:42', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:45', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:40', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:38', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:17', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:14', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:29', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:13', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:23', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:47:44', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:12', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:10', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:57', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:57', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:40', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:47', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:26', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:16:12', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:44', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:26', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:53', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:00:53', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:17', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:28', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:58', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:36', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:31', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:06', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:14', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:40', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:29', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:42', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:13', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:41', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:59', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:32', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:08', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:26', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:22', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:45', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:38', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:19', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:19', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:40', 'OUT' FROM dual
UNION ALL SELECT 34, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:31', 'IN' FROM dual
UNION ALL SELECT 34, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:27', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 35 per_id, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:21:51' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 35, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:24', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:12', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:09', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:24:57', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:46', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:37', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:07', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:31', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:36', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:22', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:10', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:12', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:52', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:16:15', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:01', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:11', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:41', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:48', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:38', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:44', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:12', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:58', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:18', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:55', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:07', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:58', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:24', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:05', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:58', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:35', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:50', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:43', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:32:42', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:56', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:05', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:50', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:02', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:04', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:59', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:22', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:52', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:54', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:50', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:43:36', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:09', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:31', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 35 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:19:22' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 35, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:09', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:37', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:22', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:10', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:56', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:08', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:11', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:24:40', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:44', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:03', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:57', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:18', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:19', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:03', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:59', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:57', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:12', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:42', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:29:19', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:09', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:00', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:20', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:12:17', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:17', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:39', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:21', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:47', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:05', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:22', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:45', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:35:11', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:56', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:46', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:21', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:28', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:57', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:24', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:27', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:22', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:56', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:04', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:34', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:58', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:27', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:54', 'OUT' FROM dual
UNION ALL SELECT 35, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:05', 'IN' FROM dual
UNION ALL SELECT 35, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:41', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 36 per_id, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:33:15' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 36, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:16', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:53', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:01', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:08', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:27', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:37', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:26', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:50', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:00', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:21', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:53', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:49', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:38', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:57', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:11', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:37', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:03', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:10', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:21', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:40', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:26', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:44', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:57', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:57', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:05', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:59', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:26', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:06', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:07', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:01', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:53', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:33', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:44', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:54', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:12', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:56', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:56', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:47', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:41', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:35', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:01', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:54', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:29', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:10', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:18', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:52', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:53', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:59', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:51', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 36 per_id, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:27:55' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 36, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:38:12', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:40', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:21', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:03', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:07:43', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:36', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:05', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:11', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:43', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:43', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:41', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:44', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:21', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:25', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:02', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:59', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:08', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:54', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:33', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:02', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:40', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:30', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:39', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:04:29', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:40', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:52', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:22', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:05', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:12', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:25', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:44', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:07', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:28', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:47', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:18', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:12', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:28', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:53', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:27', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:16', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:46', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:13', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:48', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:03', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:10', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:52', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:04', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:22', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:46', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 39 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:55:40' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 39, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:52', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:29', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:56', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:31', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:27', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:38', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:06', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:26', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:18:09', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:23', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:47', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:39', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:38', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:18', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:18', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:13', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:05', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:46', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:21', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:29', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:47', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:43', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:06', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:45', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:10', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:27', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:17', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:31', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:35:51', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:20', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:45', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:53', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:21', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:00', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:05', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:16', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:29', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:41', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:26', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:18', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:33:03', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:25', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:44', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:51', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:20', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:30', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:20', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:48', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:15', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 40 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:09:09' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 40, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:33', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:49', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:56:49', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:23', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:23', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:13', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:36', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:52', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:45', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:23', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:05:29', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:29', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:42', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:59', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:35', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:26', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:21', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:44', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:37', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:05', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:45', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:16', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:57', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:05', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:00', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:03', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:18', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:44', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:41', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:57', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:07', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:27', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:05', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:43', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:43', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:45', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:52', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:12', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:30:42', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:05', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:23', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:53', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:21', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:50', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:47', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:19', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:50:22', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:00', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:12', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 40 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:40:01' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 40, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:36:01', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:31', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:27', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:04', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:00:29', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:19', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:23', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:00', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:37', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:58', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:01', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:37', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:00', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:05', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:43', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:35', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:17', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:52', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:41', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:12', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:32:21', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:29', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:51', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:03', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:22', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:15', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:21', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:35', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:07:15', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:15', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:22', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:16', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:43', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:34', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:51', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:06', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:55', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:08', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:58', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:38', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:45', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:31', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:21', 'OUT' FROM dual
UNION ALL SELECT 40, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:54', 'IN' FROM dual
UNION ALL SELECT 40, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:20', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:05', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:48', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:21', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:30', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 41 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '07:57:13' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 41, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:09', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:44', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:06:59', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:31', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:09', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:53', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:33', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:12:17', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:29', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:12', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:46', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:29:56', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:45', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:43', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:31', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:45', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:17', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:17', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:16', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:20', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:18', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:19', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:03', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:14', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:41', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:35', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:06', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:17', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:04', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:25', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:55', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:40', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:29', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:56', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:58', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:43', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:55', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:24', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:34', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:56', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:06', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:27', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:30:04', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:50', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:52', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:38', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:14:30', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:47', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:39', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 41 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '14:09:50' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 41, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:00:04', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:28', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:58', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:07', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:20', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:53', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:13', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:50', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:28:21', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:57', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:11', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:40', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:51', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:57', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:09', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:20', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:27', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:04', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:14', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:19', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:01', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:32', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:05', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:18', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:14:50', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:43:40', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:02', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:48', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:52', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:08', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:37', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:04', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:08', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:52', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:53', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:01', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:15:55', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:06', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:08', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:13', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:44', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:27:54', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:59', 'OUT' FROM dual
UNION ALL SELECT 41, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:31', 'IN' FROM dual
UNION ALL SELECT 41, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:08', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:24', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:12', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:35', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:27', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 42 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:00:23' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 42, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:42', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:32', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:29', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:48', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:08', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:55', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:23:20', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:27', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:46', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:42', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:11', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:51', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:13', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:35', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:28', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:21', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:35', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:06', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:28:23', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:08', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:01', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:48', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:57', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:53', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:22', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:09', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:32', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:50', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:49', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:12', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:23', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:10', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:01', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:19', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:49', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:32', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:41', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:25', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:22', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:51', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:50', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:45', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:17', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:02', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:27', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:14', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:53:41', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:08', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:04', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 42 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:39:19' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 42, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:40:49', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:10', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:33', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:14', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:33', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:00:36', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:57', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:52', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:17:36', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:50', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:02', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:08', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:23', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:23', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:30', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:56', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:24', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:15', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:51', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:28', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:07:44', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:06:32', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:27', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:12', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:01', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:14', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:04', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:07', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:29', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:16', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:13', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:01', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:16', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:15', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:26', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:09', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:52:16', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:57', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:57', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:31', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:34', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:43', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:02', 'OUT' FROM dual
UNION ALL SELECT 42, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:38', 'IN' FROM dual
UNION ALL SELECT 42, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:54', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:51', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:04', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:15', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:29', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 43 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:24:33' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 43, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:18', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:45', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:34', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:52', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:36', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:19', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:36', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:24', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:54', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:43', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:44', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:26', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:30', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:05', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:52', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:40', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:55', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:14', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:19:54', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:58', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:16', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:39', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:04:02', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:03', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:35', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:49', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:29', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:25', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:08', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:35', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:06', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:59', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:51', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:06', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:50:10', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:26', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:04', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:28', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:54', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:22', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:20', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:15', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:27:07', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:32', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:06', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:36', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:14', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:10', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:30', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 43 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:39:37' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 43, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:13', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:19', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:50', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:29', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:48', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:49', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:54', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:16', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:47:11', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:59:02', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:42', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:10', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:46', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:51', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:39', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:36', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:34:00', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:44', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:20', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:32', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:13', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:55', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:48', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:34', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:56', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:38', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:23', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:52', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:37', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:12', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:09', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:35', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:23', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:47', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:58', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:19', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:33:51', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:59', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:26', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:54', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:43', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:22', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:46', 'OUT' FROM dual
UNION ALL SELECT 43, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:30', 'IN' FROM dual
UNION ALL SELECT 43, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:23', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:53', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:53', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:56', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:21', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 44 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:58:54' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 44, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:04:12', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:55', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:38', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:21', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:40', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:01', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:10', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:16', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:52', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:20', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:12', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:36', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:34', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:12', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:21:12', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:15', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:33', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:43', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:16', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:43', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:52', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:03', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:34', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:20', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:26', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:06', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:54', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:33', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:00', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:53:31', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:17:49', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:11', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:16', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:05', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:53', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:27', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:19', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:03:16', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:38:14', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:47', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:38', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:17', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:37:34', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:40', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:27', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:02', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:00', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:50', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:35', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 44 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:29:58' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 44, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:08', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:54', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:39', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:06', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:51', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:44', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:52', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:23', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:25:20', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:32', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:01', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:22', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:11', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:42', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:43', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:06', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:09', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:54', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:34', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:20', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:59', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:48', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:11', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:41', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:47', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:00', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:14', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:59', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:29', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:05', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:58', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:51', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:17', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:03', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:47', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:56', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:34', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:37', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:44', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:56', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:54', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:07', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:57:11', 'OUT' FROM dual
UNION ALL SELECT 44, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:20', 'IN' FROM dual
UNION ALL SELECT 44, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:52', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:37', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:48', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:42', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:40', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 45 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:25:38' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 45, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:18', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:31', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:58:11', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:09', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:59', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:51', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:20:39', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:22', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:07', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:19', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:56', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:10:52', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:41', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:08', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:17', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:32', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:00', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:28', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:41', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:26', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:58', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:18', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:11:14', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:30', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:26', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:52', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:03:59', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:19', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:05', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:04', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:12', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:46', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:19', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:31', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:12', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:00', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:01', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:40', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:38', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:33:12', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:11', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:52', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:12:03', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:13:20', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:36', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:44', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:03', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:13', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:50', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 45 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:15:39' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 45, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:45', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:10', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:42', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:28', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:34', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:33', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:43', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:23', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:00', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:01', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:24', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:13', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:35', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:23', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:42', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:20', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:03:03', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:10', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:25', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:57', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:22', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:54', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:19', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:11', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:49:57', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:44', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:27', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:32', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:01', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:38', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:14', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:13', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:25', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:51', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:33', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:07', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:38', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:39:42', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:56', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:35', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:47', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:10', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:57', 'OUT' FROM dual
UNION ALL SELECT 45, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:36', 'IN' FROM dual
UNION ALL SELECT 45, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:10:56', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:10:58', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:52', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:16', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:11', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 46 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:21:06' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 46, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:19:51', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:24', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:05:02', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:57:07', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:04', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:04', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:01', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:22', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:58', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:43', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:23', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:24', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:30:34', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:23', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:06', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:08:39', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:45', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:24', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:22:28', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:23', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:10', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:57', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:21:07', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:41', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:36', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:55', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:47', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:49', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:42', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:46', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:08:16', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:18:00', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:10', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:11', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:37:12', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:00', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:05:02', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:26', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:50', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:45:12', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:31', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:14', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:55', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:12', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:49', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:13', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:21:50', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:20:15', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:10', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 46 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:50:07' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 46, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:16', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:39', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:06', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:28', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:57', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:05', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:00', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:48', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:52:46', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:01', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:18', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:00', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:33', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:26', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:47', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:36', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:02:56', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:39:24', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:57:32', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:56:12', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:48:33', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:25', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:32', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:20', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:07:18', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:42', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:29', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:45', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:24:35', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:19', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:54', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:29', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:56:55', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:04:54', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:35', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:15', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:23:57', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:46', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:33', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:09', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:06', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:57', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:07:56', 'OUT' FROM dual
UNION ALL SELECT 46, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:59:12', 'IN' FROM dual
UNION ALL SELECT 46, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:11', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:27', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:12', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:21', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:02:50', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 47 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:11:21' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 47, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:13', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:01', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:45:46', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:43', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:28', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:56', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:35:55', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:04', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:18:30', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:17', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:24', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:54:22', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:11', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:37', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:52:06', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:38', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:41:43', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:20', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:45:47', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:56:13', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:56', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:24', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:32', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:54', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:08', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:44', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:41:05', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:29', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:24', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:36', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:04', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:30:53', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:34', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:38', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:07:41', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:36:56', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:35', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:53', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:30', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:33:29', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:40', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:57:27', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:27:30', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:42', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:45:34', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:39', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:24', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:35', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:27', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 47 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:47:24' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 47, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:09', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:49', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:31', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:31', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:44:50', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:35', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:24', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:31:26', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:47:01', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:32:57', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:20:49', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:06', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:06:57', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:09', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:20', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:28:15', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:47', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:04', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:46', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:07', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:36', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:09', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:04', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:52', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:43', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:06', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:30', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:59', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:45:17', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:33', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:45', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:41', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:26:36', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:09', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:01', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:36', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:30:38', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:33', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:00', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:50', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:55:32', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:22', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:13', 'OUT' FROM dual
UNION ALL SELECT 47, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:13:50', 'IN' FROM dual
UNION ALL SELECT 47, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:13', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:08', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:55', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:34', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:06:20', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 48 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:19:01' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 48, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:57', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:48', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:55', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:08', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:56', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:37', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:02:07', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:28', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:05', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:14', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:40:40', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:18', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:12', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:04', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:39:10', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:04', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:54', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:05', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:50:51', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:31:36', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:23:18', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:06', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:54', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:22:14', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:29', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:45', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:13', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:17', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:14', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:29', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:37:30', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:22:29', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:03:56', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:14', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:13:09', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:08:19', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:18', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:35', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:41:37', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:29', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:50', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:00:38', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:17', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:35:41', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:48', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:25', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:49', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:44', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:46', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 48 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:13:41' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 48, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:31', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:37:10', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:10', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:09', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:15:18', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:29:34', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:39', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:27', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:10:18', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:55', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:11', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:30', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:55:44', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:24:04', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:03', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:27', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:49:28', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:40', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:33', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:59', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:57:17', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:20', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:38', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:42', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:53', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:33', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:38', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:33:12', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:10', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:53', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:58:34', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:15', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:28', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:07:57', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:34', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:21', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:36:06', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:34', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:49:08', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:44', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:42:46', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:35', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:15', 'OUT' FROM dual
UNION ALL SELECT 48, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:03', 'IN' FROM dual
UNION ALL SELECT 48, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:47', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:08', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:12', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:46', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:34:45', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 49 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:15:56' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 49, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:57', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:24', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:29:18', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:42', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:33', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:59', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:12', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:14:35', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:51', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:47', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:39:49', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:15', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:06', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:51', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:45:37', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:20:31', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:15:37', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:42', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:50:30', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:53', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:55', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:05', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:49:25', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:58', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:37:12', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:04', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:46:49', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:17:24', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:58:14', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:45', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:59:33', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:38:06', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:37', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:12', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:56:43', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:34', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:20', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:25', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:55:22', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:01', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:40:02', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:36:33', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:58:03', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:35', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:39:42', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:19', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:07', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:33', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:30', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 49 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:17:23' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 49, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:23', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:42', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:30', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:30', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:42:23', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:25:03', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:26', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:47', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:09:38', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:16', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:20', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:03', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:50', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:38:23', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:21', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:46', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:20', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:55', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:07:51', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:54:06', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:28:17', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:05:15', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:04', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:53', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:24:14', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:48', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:36:15', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:26', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:07:24', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:56', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:55:30', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:15:41', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:00:24', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:50:04', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:21:02', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:27', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:52', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:25', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:10', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:42', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:21:28', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:15:38', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:59:24', 'OUT' FROM dual
UNION ALL SELECT 49, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:20', 'IN' FROM dual
UNION ALL SELECT 49, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:53:48', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:57', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:14:21', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:58', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:23', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 50 per_id, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:25:10' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 50, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:54:02', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:27:43', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:43:40', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:31:46', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:38:20', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:55', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:31:15', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:00:15', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:47', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:08', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:01:32', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:14:31', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:49', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:29:50', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:55:18', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:05', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:45', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:48:35', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:22:18', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:32:50', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:01', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:47', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:11:31', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:07:08', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:27', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:17:27', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:54:37', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:53:28', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:28', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:02:13', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:22:58', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:26:49', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:02:44', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:13', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:27:45', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:03:14', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:08:46', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:33', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:20:23', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:02', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:15', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:03', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:45', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:05:27', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:39', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:01:24', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:34:18', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:31', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:01:26', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 50 per_id, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:34:07' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 50, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:36:03', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:56:47', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:43', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:08:08', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:32:51', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:54:16', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:55:07', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:35', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:36', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:26:04', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:43:34', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:41:20', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:39:50', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:06:08', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:04:16', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:33', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:16', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:55:04', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:44', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:26', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:24:54', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:40', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:44:34', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:10', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:20:01', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:16:32', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:17:23', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:20:49', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:03:32', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:30:37', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:07', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:57', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:26:46', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:18', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:48', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:53', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:06:15', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:21:45', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:10', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:31', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:45', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:34:09', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:17', 'OUT' FROM dual
UNION ALL SELECT 50, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:05', 'IN' FROM dual
UNION ALL SELECT 50, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:38:13', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:23', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:23', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:55:14', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:58', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 36 per_id, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '09:13:10' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 36, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:25:52', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:43', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:09:06', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:37', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:06:55', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:06:43', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:09', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:58:11', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:36', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:43', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:38', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:07', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:28', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:39', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:29:17', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:20:26', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:19', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:11:09', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:26', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:40:46', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:26:32', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:49:58', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:30:54', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:18:08', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:15', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:06', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:46:49', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:25:15', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:31:03', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:13', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:01:44', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:12:57', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:50:14', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:05:00', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:51:49', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:29:34', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:48:04', 'OUT' FROM dual
UNION ALL SELECT 36, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:15', 'IN' FROM dual
UNION ALL SELECT 36, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:57:12', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:01:55', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:27', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:30', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:51', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:56', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:01', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:51', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:27', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:37', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:06', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 37 per_id, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:27:39' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 37, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:41', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:15:10', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:37', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:34', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:40:55', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:56', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:53:55', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:50:08', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:42:45', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:23:46', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:32:50', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:04', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:21:10', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:36', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:03:56', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:31', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:48', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:42:11', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:15', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:44', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:22:54', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:21:42', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:28:41', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:17', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:08:53', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:11', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:06:50', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:42:07', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:19:56', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:16', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:31', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:39:13', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:11:15', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:27:50', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:52:26', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:22:59', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:59:43', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:49:12', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:33:39', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:28', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:38:02', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:17:52', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:45', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:07:42', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:43', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:48:27', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:59:33', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:18:01', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:03:20', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 37 per_id, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:21:42' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 37, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:47', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:26:22', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:26:09', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:19:43', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:30', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:11', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:08:38', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:30', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:46:45', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:25', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:04:13', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:58', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:11', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:28', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:10:54', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:47:05', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:50', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:44:29', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:13', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:28:44', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:53', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:38:47', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:13:19', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:28:47', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:09:46', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:12:54', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:25:57', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:02:47', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:35:31', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:34:51', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:09:49', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:09:05', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:52:58', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:52', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:56:46', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:23:58', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:11:01', 'OUT' FROM dual
UNION ALL SELECT 37, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:14', 'IN' FROM dual
UNION ALL SELECT 37, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '19:05:16', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:37:18', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:00:59', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:16:17', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:31:54', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:01:49', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:10:34', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:24', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:57:48', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:50:52', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:13:21', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 38 per_id, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '13:22:12' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 38, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:23:25', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:13:33', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:22:45', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:21:27', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('20/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:46:58', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:39', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:13', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:27', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('21/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:44:16', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:40:20', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:34', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:09:32', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('24/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:35:36', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:34:52', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:53:49', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:40:33', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('25/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:10:05', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:52:42', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:50:41', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:22', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('26/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:35:33', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:13', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:29:09', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:43:48', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('27/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:10', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:16:56', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:27:06', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:10', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('28/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:01:03', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:55:43', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:01:24', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:10:15', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('03/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:18:30', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:09:52', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:54:55', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:30:54', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('04/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:43:50', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:51:52', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:08:47', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:25:34', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('05/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:00', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:19:11', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:56:38', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:37:22', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('06/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:31:19', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:11:19', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:09:21', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:14:58', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('07/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:04:28', 'OUT' FROM dual
;
INSERT INTO demo_per_clockings_tde (per_id, clocking_date, clocking_time, clocking_type)
SELECT 38 per_id, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') clocking_date, '08:45:47' clocking_time, 'IN' clocking_type FROM dual
UNION ALL SELECT 38, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:42:42', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:52:46', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('10/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:58:19', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:59:24', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:47:13', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:24:55', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('11/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:32:47', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:36:14', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:10:54', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:51:49', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('12/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:55:08', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:35:14', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:51:56', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:35:39', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('13/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:53:21', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:40', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:24:37', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:47:23', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('14/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:50:19', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:11:42', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:02:20', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:58:14', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('17/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:59:12', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:02:32', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:51:26', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '14:04:32', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('18/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:51:16', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:57:21', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:16:02', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:45:25', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('19/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:14:38', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:53:36', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:12:43', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:19:03', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('20/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:54:41', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:44:42', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:00:31', 'OUT' FROM dual
UNION ALL SELECT 38, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:46:43', 'IN' FROM dual
UNION ALL SELECT 38, TO_DATE('21/03/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '16:44:18', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '07:52:08', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:05:31', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:23:09', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('17/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '17:33:29', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '08:51:52', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '11:56:22', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '13:32:07', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('18/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '18:21:13', 'OUT' FROM dual
UNION ALL SELECT 39, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '09:03:36', 'IN' FROM dual
UNION ALL SELECT 39, TO_DATE('19/02/2025 00:00:00','DD/MM/YYYY HH24:MI:SS'), '12:34:36', 'OUT' FROM dual
;
INSERT INTO demo_per_credit_cards_tde (per_id, cct_cd, credit_card_number, expiry_date)
SELECT 1 per_id, '6011' cct_cd, '6011162323611188' credit_card_number, TO_DATE('31/10/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') expiry_date FROM dual
UNION ALL SELECT 1, '5', '5343259488522910', TO_DATE('31/03/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 2, '4', '4140469111791513', TO_DATE('31/10/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 2, '3', '382073592625920', TO_DATE('28/02/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 3, '6011', '6011696799954218', TO_DATE('30/06/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 3, '5', '5878417311752327', TO_DATE('30/09/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 3, '4', '4966755994001850', TO_DATE('31/10/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 4, '3', '344617360665455', TO_DATE('31/03/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 4, '6011', '6011304468146246', TO_DATE('31/03/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 4, '5', '5177991011294440', TO_DATE('30/04/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 4, '4', '4115776781233571', TO_DATE('31/01/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 5, '3', '311772969410776', TO_DATE('30/06/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 5, '6011', '6011527446112761', TO_DATE('31/05/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 5, '5', '5597493789501223', TO_DATE('31/05/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 5, '4', '4837415266685206', TO_DATE('31/03/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 6, '3', '346690274769646', TO_DATE('31/07/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 6, '6011', '6011502685402371', TO_DATE('31/07/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 7, '5', '5790341066009664', TO_DATE('28/02/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 7, '4', '4531615956281203', TO_DATE('31/07/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 7, '3', '357106061023747', TO_DATE('31/10/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 8, '6011', '6011193693878412', TO_DATE('31/07/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 8, '5', '5670458189471574', TO_DATE('28/02/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 8, '4', '4675033059779998', TO_DATE('30/04/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 8, '3', '319642292252132', TO_DATE('28/02/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 9, '6011', '6011968880936580', TO_DATE('30/06/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 9, '5', '5066120749156663', TO_DATE('30/09/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 9, '4', '4785957779768237', TO_DATE('31/10/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 9, '3', '325993111490029', TO_DATE('30/04/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 10, '6011', '6011856473375821', TO_DATE('31/10/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 10, '5', '5353919863430784', TO_DATE('30/04/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 11, '4', '4062677914851144', TO_DATE('31/01/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 11, '3', '363277130339471', TO_DATE('30/11/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 11, '6011', '6011580754496326', TO_DATE('31/01/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 11, '5', '5901342220950021', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 12, '4', '4246099373033230', TO_DATE('31/10/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 12, '3', '391508823931695', TO_DATE('31/10/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 13, '6011', '6011841911590496', TO_DATE('28/02/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 13, '5', '5174408700044526', TO_DATE('31/03/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 14, '4', '4225794170764244', TO_DATE('31/01/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 14, '3', '326146033144674', TO_DATE('30/04/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 15, '6011', '6011959136838571', TO_DATE('30/04/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 15, '5', '5043071072569915', TO_DATE('30/06/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 16, '4', '4389524019804022', TO_DATE('31/01/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 16, '3', '391073142272065', TO_DATE('31/12/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 16, '6011', '6011305980776204', TO_DATE('31/03/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 17, '5', '5452094840173673', TO_DATE('31/10/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 17, '4', '4062216483719570', TO_DATE('31/08/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 17, '3', '398131288443677', TO_DATE('31/08/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 18, '6011', '6011996682698157', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 18, '5', '5627869370266223', TO_DATE('30/09/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
;
INSERT INTO demo_per_credit_cards_tde (per_id, cct_cd, credit_card_number, expiry_date)
SELECT 18 per_id, '4' cct_cd, '4434339814944674' credit_card_number, TO_DATE('30/04/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') expiry_date FROM dual
UNION ALL SELECT 19, '3', '308226754659399', TO_DATE('30/09/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 19, '6011', '6011615380194877', TO_DATE('31/05/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 20, '5', '5021814753438553', TO_DATE('29/02/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 20, '4', '4675842375964724', TO_DATE('31/03/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 20, '3', '321096070983762', TO_DATE('31/12/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 20, '6011', '6011469732611521', TO_DATE('31/01/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 21, '5', '5552080149233325', TO_DATE('30/11/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 21, '4', '4293201280848765', TO_DATE('31/01/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 22, '3', '390412807421743', TO_DATE('31/07/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 22, '6011', '6011155721584486', TO_DATE('31/08/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 22, '5', '5450888954204873', TO_DATE('30/04/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 22, '4', '4031504684316769', TO_DATE('31/08/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 23, '3', '357255411675944', TO_DATE('28/02/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 23, '6011', '6011335891912911', TO_DATE('31/10/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 23, '5', '5772255298603684', TO_DATE('31/05/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 24, '4', '4551643873303319', TO_DATE('31/10/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 24, '3', '336465108841867', TO_DATE('31/01/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 24, '6011', '6011224084984814', TO_DATE('29/02/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 24, '5', '5618680640371375', TO_DATE('28/02/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 25, '4', '4573352095367623', TO_DATE('30/11/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 25, '3', '342072982091213', TO_DATE('31/07/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 25, '6011', '6011379339487359', TO_DATE('31/10/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 25, '5', '5531997444483774', TO_DATE('28/02/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 26, '4', '4723360286020678', TO_DATE('31/12/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 26, '3', '330474441552385', TO_DATE('30/11/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 26, '6011', '6011504709896596', TO_DATE('31/01/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 27, '5', '5410748108793263', TO_DATE('30/11/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 27, '4', '4801180995128504', TO_DATE('31/01/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 27, '3', '345654711823011', TO_DATE('28/02/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 28, '6011', '6011709071160071', TO_DATE('31/05/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 28, '5', '5533903301398145', TO_DATE('31/12/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 29, '4', '4001337429554063', TO_DATE('30/06/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 29, '3', '374286954185610', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 29, '6011', '6011689114618147', TO_DATE('30/09/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 29, '5', '5120167657001195', TO_DATE('31/03/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 30, '4', '4421327146196696', TO_DATE('31/10/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 30, '3', '316261551618553', TO_DATE('30/09/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 30, '6011', '6011096962056703', TO_DATE('30/04/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 31, '5', '5750296304982965', TO_DATE('31/03/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 31, '4', '4107451472794014', TO_DATE('30/11/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 31, '3', '329887696800279', TO_DATE('31/01/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 32, '6011', '6011045620869601', TO_DATE('30/04/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 32, '5', '5013237819342314', TO_DATE('30/11/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 32, '4', '4013790965171617', TO_DATE('31/07/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 32, '3', '357827706066870', TO_DATE('31/12/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 33, '6011', '6011189001285845', TO_DATE('31/07/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 33, '5', '5047909672670151', TO_DATE('31/07/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 33, '4', '4437653876186231', TO_DATE('31/07/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 34, '3', '329765135761494', TO_DATE('31/10/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
;
INSERT INTO demo_per_credit_cards_tde (per_id, cct_cd, credit_card_number, expiry_date)
SELECT 34 per_id, '6011' cct_cd, '6011702433412868' credit_card_number, TO_DATE('31/10/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') expiry_date FROM dual
UNION ALL SELECT 34, '5', '5523041750168669', TO_DATE('30/04/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 34, '4', '4231264029816092', TO_DATE('31/08/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 35, '3', '381068621086327', TO_DATE('31/10/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 35, '6011', '6011052365445035', TO_DATE('30/11/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 36, '5', '5962896882415983', TO_DATE('31/10/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 36, '4', '4619943319670804', TO_DATE('31/07/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 37, '3', '387029481836569', TO_DATE('31/12/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 37, '6011', '6011292570650835', TO_DATE('31/07/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 38, '5', '5747284583676330', TO_DATE('31/08/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 38, '4', '4772921573972804', TO_DATE('31/05/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 38, '3', '354994751756160', TO_DATE('31/01/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 38, '6011', '6011336643806492', TO_DATE('31/03/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 39, '5', '5513194373990902', TO_DATE('30/04/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 39, '4', '4866336035121204', TO_DATE('31/10/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 39, '3', '301426817710950', TO_DATE('31/08/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 39, '6011', '6011252464292813', TO_DATE('30/04/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 40, '5', '5600178072747824', TO_DATE('31/12/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 40, '4', '4384203783759838', TO_DATE('30/11/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 41, '3', '300062023657320', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 41, '6011', '6011565549155915', TO_DATE('31/10/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 41, '5', '5035586970797607', TO_DATE('31/10/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 42, '4', '4889054044982648', TO_DATE('31/05/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 42, '3', '362223117532374', TO_DATE('31/07/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 42, '6011', '6011160214649440', TO_DATE('31/07/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 43, '5', '5567907836305672', TO_DATE('30/09/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 43, '4', '4883176770983163', TO_DATE('31/10/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 44, '3', '391870148015202', TO_DATE('31/07/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 44, '6011', '6011331175625808', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 44, '5', '5180360194630132', TO_DATE('31/05/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 44, '4', '4817526268625224', TO_DATE('31/08/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 45, '3', '314061473697988', TO_DATE('31/05/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 45, '6011', '6011151171028850', TO_DATE('31/01/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 45, '5', '5611746361180217', TO_DATE('30/06/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 46, '4', '4477378504560752', TO_DATE('31/07/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 46, '3', '353115905028311', TO_DATE('30/04/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 46, '6011', '6011854210657288', TO_DATE('31/08/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 46, '5', '5988549360836655', TO_DATE('28/02/2030 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 47, '4', '4339452698045231', TO_DATE('31/01/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 47, '3', '380040039111329', TO_DATE('30/11/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 47, '6011', '6011753172685826', TO_DATE('31/08/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 47, '5', '5518879552899925', TO_DATE('30/04/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 48, '4', '4402308484388353', TO_DATE('30/06/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 48, '3', '304985565722415', TO_DATE('31/07/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 48, '6011', '6011456409398235', TO_DATE('30/11/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 48, '5', '5176201707777380', TO_DATE('31/12/2027 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 49, '4', '4872167554736474', TO_DATE('30/06/2028 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 49, '3', '388397446377337', TO_DATE('31/12/2025 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 49, '6011', '6011637593153995', TO_DATE('31/12/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 49, '5', '5540546844045375', TO_DATE('28/02/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
;
INSERT INTO demo_per_credit_cards_tde (per_id, cct_cd, credit_card_number, expiry_date)
SELECT 50 per_id, '4' cct_cd, '4181741294076965' credit_card_number, TO_DATE('30/09/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') expiry_date FROM dual
UNION ALL SELECT 50, '3', '394079178399901', TO_DATE('30/06/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 50, '6011', '6011408833440133', TO_DATE('30/09/2029 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
UNION ALL SELECT 50, '5', '5661534932416909', TO_DATE('30/09/2026 00:00:00','DD/MM/YYYY HH24:MI:SS') FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 1 ord_id, 1 order_line, 36 prd_id, 7 quantity, 665 price FROM dual
UNION ALL SELECT 2, 1, 8, 7, 294 FROM dual
UNION ALL SELECT 2, 2, 26, 6, 222 FROM dual
UNION ALL SELECT 3, 1, 30, 5, 360 FROM dual
UNION ALL SELECT 3, 2, 25, 1, 48 FROM dual
UNION ALL SELECT 4, 1, 15, 6, 264 FROM dual
UNION ALL SELECT 5, 1, 18, 7, 140 FROM dual
UNION ALL SELECT 5, 2, 17, 6, 498 FROM dual
UNION ALL SELECT 5, 3, 44, 8, 224 FROM dual
UNION ALL SELECT 6, 1, 28, 1, 42 FROM dual
UNION ALL SELECT 7, 1, 11, 2, 142 FROM dual
UNION ALL SELECT 7, 2, 14, 6, 510 FROM dual
UNION ALL SELECT 7, 3, 6, 8, 312 FROM dual
UNION ALL SELECT 8, 1, 47, 3, 213 FROM dual
UNION ALL SELECT 8, 2, 43, 8, 408 FROM dual
UNION ALL SELECT 8, 3, 20, 7, 525 FROM dual
UNION ALL SELECT 9, 1, 9, 3, 108 FROM dual
UNION ALL SELECT 9, 2, 24, 5, 225 FROM dual
UNION ALL SELECT 10, 1, 48, 1, 85 FROM dual
UNION ALL SELECT 10, 2, 22, 1, 94 FROM dual
UNION ALL SELECT 10, 3, 27, 5, 290 FROM dual
UNION ALL SELECT 10, 4, 42, 1, 25 FROM dual
UNION ALL SELECT 11, 1, 3, 1, 47 FROM dual
UNION ALL SELECT 11, 2, 4, 3, 90 FROM dual
UNION ALL SELECT 11, 3, 49, 6, 294 FROM dual
UNION ALL SELECT 11, 4, 16, 5, 220 FROM dual
UNION ALL SELECT 11, 5, 38, 6, 522 FROM dual
UNION ALL SELECT 12, 1, 23, 2, 48 FROM dual
UNION ALL SELECT 13, 1, 50, 6, 114 FROM dual
UNION ALL SELECT 13, 2, 33, 8, 240 FROM dual
UNION ALL SELECT 14, 1, 41, 4, 376 FROM dual
UNION ALL SELECT 15, 1, 19, 3, 111 FROM dual
UNION ALL SELECT 16, 1, 29, 4, 176 FROM dual
UNION ALL SELECT 16, 2, 12, 2, 90 FROM dual
UNION ALL SELECT 16, 3, 10, 6, 408 FROM dual
UNION ALL SELECT 16, 4, 45, 5, 215 FROM dual
UNION ALL SELECT 17, 1, 37, 6, 234 FROM dual
UNION ALL SELECT 17, 2, 1, 4, 204 FROM dual
UNION ALL SELECT 17, 3, 7, 7, 245 FROM dual
UNION ALL SELECT 17, 4, 13, 8, 736 FROM dual
UNION ALL SELECT 18, 1, 32, 8, 272 FROM dual
UNION ALL SELECT 18, 2, 5, 4, 312 FROM dual
UNION ALL SELECT 18, 3, 34, 8, 656 FROM dual
UNION ALL SELECT 19, 1, 21, 1, 84 FROM dual
UNION ALL SELECT 20, 1, 46, 3, 105 FROM dual
UNION ALL SELECT 20, 2, 39, 5, 255 FROM dual
UNION ALL SELECT 21, 1, 2, 1, 62 FROM dual
UNION ALL SELECT 21, 2, 40, 3, 273 FROM dual
UNION ALL SELECT 21, 3, 31, 5, 445 FROM dual
UNION ALL SELECT 21, 4, 35, 4, 104 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 21 ord_id, 5 order_line, 36 prd_id, 3 quantity, 285 price FROM dual
UNION ALL SELECT 22, 1, 8, 3, 126 FROM dual
UNION ALL SELECT 23, 1, 26, 5, 185 FROM dual
UNION ALL SELECT 23, 2, 30, 3, 216 FROM dual
UNION ALL SELECT 23, 3, 25, 5, 240 FROM dual
UNION ALL SELECT 23, 4, 15, 8, 352 FROM dual
UNION ALL SELECT 23, 5, 18, 3, 60 FROM dual
UNION ALL SELECT 24, 1, 17, 8, 664 FROM dual
UNION ALL SELECT 25, 1, 44, 1, 28 FROM dual
UNION ALL SELECT 26, 1, 28, 3, 126 FROM dual
UNION ALL SELECT 26, 2, 11, 1, 71 FROM dual
UNION ALL SELECT 26, 3, 14, 8, 680 FROM dual
UNION ALL SELECT 27, 1, 6, 2, 78 FROM dual
UNION ALL SELECT 27, 2, 47, 3, 213 FROM dual
UNION ALL SELECT 27, 3, 43, 4, 204 FROM dual
UNION ALL SELECT 27, 4, 20, 5, 375 FROM dual
UNION ALL SELECT 27, 5, 9, 4, 144 FROM dual
UNION ALL SELECT 28, 1, 24, 7, 315 FROM dual
UNION ALL SELECT 28, 2, 48, 7, 595 FROM dual
UNION ALL SELECT 28, 3, 22, 6, 564 FROM dual
UNION ALL SELECT 28, 4, 27, 8, 464 FROM dual
UNION ALL SELECT 29, 1, 42, 3, 75 FROM dual
UNION ALL SELECT 29, 2, 3, 3, 141 FROM dual
UNION ALL SELECT 30, 1, 4, 5, 150 FROM dual
UNION ALL SELECT 30, 2, 49, 2, 98 FROM dual
UNION ALL SELECT 31, 1, 16, 5, 220 FROM dual
UNION ALL SELECT 31, 2, 38, 2, 174 FROM dual
UNION ALL SELECT 31, 3, 23, 3, 72 FROM dual
UNION ALL SELECT 31, 4, 50, 6, 114 FROM dual
UNION ALL SELECT 31, 5, 33, 2, 60 FROM dual
UNION ALL SELECT 32, 1, 41, 8, 752 FROM dual
UNION ALL SELECT 32, 2, 19, 4, 148 FROM dual
UNION ALL SELECT 32, 3, 29, 1, 44 FROM dual
UNION ALL SELECT 32, 4, 12, 3, 135 FROM dual
UNION ALL SELECT 33, 1, 10, 7, 476 FROM dual
UNION ALL SELECT 33, 2, 45, 7, 301 FROM dual
UNION ALL SELECT 33, 3, 37, 5, 195 FROM dual
UNION ALL SELECT 33, 4, 1, 5, 255 FROM dual
UNION ALL SELECT 33, 5, 7, 5, 175 FROM dual
UNION ALL SELECT 34, 1, 13, 1, 92 FROM dual
UNION ALL SELECT 34, 2, 32, 3, 102 FROM dual
UNION ALL SELECT 35, 1, 5, 6, 468 FROM dual
UNION ALL SELECT 36, 1, 34, 6, 492 FROM dual
UNION ALL SELECT 37, 1, 21, 3, 252 FROM dual
UNION ALL SELECT 38, 1, 46, 7, 245 FROM dual
UNION ALL SELECT 38, 2, 39, 8, 408 FROM dual
UNION ALL SELECT 38, 3, 2, 5, 310 FROM dual
UNION ALL SELECT 38, 4, 40, 8, 728 FROM dual
UNION ALL SELECT 39, 1, 31, 6, 534 FROM dual
UNION ALL SELECT 39, 2, 35, 1, 26 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 39 ord_id, 3 order_line, 36 prd_id, 5 quantity, 475 price FROM dual
UNION ALL SELECT 40, 1, 8, 2, 84 FROM dual
UNION ALL SELECT 40, 2, 26, 8, 296 FROM dual
UNION ALL SELECT 41, 1, 30, 6, 432 FROM dual
UNION ALL SELECT 41, 2, 25, 7, 336 FROM dual
UNION ALL SELECT 41, 3, 15, 2, 88 FROM dual
UNION ALL SELECT 41, 4, 18, 1, 20 FROM dual
UNION ALL SELECT 41, 5, 17, 6, 498 FROM dual
UNION ALL SELECT 42, 1, 44, 5, 140 FROM dual
UNION ALL SELECT 42, 2, 28, 6, 252 FROM dual
UNION ALL SELECT 43, 1, 11, 8, 568 FROM dual
UNION ALL SELECT 43, 2, 14, 1, 85 FROM dual
UNION ALL SELECT 44, 1, 6, 4, 156 FROM dual
UNION ALL SELECT 44, 2, 47, 6, 426 FROM dual
UNION ALL SELECT 44, 3, 43, 5, 255 FROM dual
UNION ALL SELECT 44, 4, 20, 3, 225 FROM dual
UNION ALL SELECT 44, 5, 9, 7, 252 FROM dual
UNION ALL SELECT 45, 1, 24, 1, 45 FROM dual
UNION ALL SELECT 45, 2, 48, 6, 510 FROM dual
UNION ALL SELECT 46, 1, 22, 1, 94 FROM dual
UNION ALL SELECT 47, 1, 27, 7, 406 FROM dual
UNION ALL SELECT 47, 2, 42, 1, 25 FROM dual
UNION ALL SELECT 48, 1, 3, 7, 329 FROM dual
UNION ALL SELECT 48, 2, 4, 2, 60 FROM dual
UNION ALL SELECT 48, 3, 49, 1, 49 FROM dual
UNION ALL SELECT 48, 4, 16, 8, 352 FROM dual
UNION ALL SELECT 48, 5, 38, 1, 87 FROM dual
UNION ALL SELECT 49, 1, 23, 5, 120 FROM dual
UNION ALL SELECT 50, 1, 50, 2, 38 FROM dual
UNION ALL SELECT 51, 1, 33, 2, 60 FROM dual
UNION ALL SELECT 51, 2, 41, 7, 658 FROM dual
UNION ALL SELECT 51, 3, 19, 6, 222 FROM dual
UNION ALL SELECT 51, 4, 29, 2, 88 FROM dual
UNION ALL SELECT 51, 5, 12, 8, 360 FROM dual
UNION ALL SELECT 52, 1, 10, 3, 204 FROM dual
UNION ALL SELECT 52, 2, 45, 3, 129 FROM dual
UNION ALL SELECT 52, 3, 37, 3, 117 FROM dual
UNION ALL SELECT 52, 4, 1, 7, 357 FROM dual
UNION ALL SELECT 52, 5, 7, 5, 175 FROM dual
UNION ALL SELECT 53, 1, 13, 4, 368 FROM dual
UNION ALL SELECT 53, 2, 32, 2, 68 FROM dual
UNION ALL SELECT 53, 3, 5, 1, 78 FROM dual
UNION ALL SELECT 53, 4, 34, 2, 164 FROM dual
UNION ALL SELECT 53, 5, 21, 4, 336 FROM dual
UNION ALL SELECT 54, 1, 46, 3, 105 FROM dual
UNION ALL SELECT 55, 1, 39, 2, 102 FROM dual
UNION ALL SELECT 55, 2, 2, 1, 62 FROM dual
UNION ALL SELECT 56, 1, 40, 4, 364 FROM dual
UNION ALL SELECT 57, 1, 31, 3, 267 FROM dual
UNION ALL SELECT 57, 2, 35, 7, 182 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 57 ord_id, 3 order_line, 36 prd_id, 6 quantity, 570 price FROM dual
UNION ALL SELECT 57, 4, 8, 4, 168 FROM dual
UNION ALL SELECT 58, 1, 26, 4, 148 FROM dual
UNION ALL SELECT 58, 2, 30, 5, 360 FROM dual
UNION ALL SELECT 58, 3, 25, 6, 288 FROM dual
UNION ALL SELECT 59, 1, 15, 1, 44 FROM dual
UNION ALL SELECT 59, 2, 18, 6, 120 FROM dual
UNION ALL SELECT 59, 3, 17, 5, 415 FROM dual
UNION ALL SELECT 60, 1, 44, 2, 56 FROM dual
UNION ALL SELECT 60, 2, 28, 7, 294 FROM dual
UNION ALL SELECT 60, 3, 11, 1, 71 FROM dual
UNION ALL SELECT 60, 4, 14, 1, 85 FROM dual
UNION ALL SELECT 61, 1, 6, 2, 78 FROM dual
UNION ALL SELECT 61, 2, 47, 4, 284 FROM dual
UNION ALL SELECT 62, 1, 43, 6, 306 FROM dual
UNION ALL SELECT 62, 2, 20, 6, 450 FROM dual
UNION ALL SELECT 62, 3, 9, 3, 108 FROM dual
UNION ALL SELECT 63, 1, 24, 6, 270 FROM dual
UNION ALL SELECT 63, 2, 48, 1, 85 FROM dual
UNION ALL SELECT 63, 3, 22, 8, 752 FROM dual
UNION ALL SELECT 63, 4, 27, 1, 58 FROM dual
UNION ALL SELECT 64, 1, 42, 1, 25 FROM dual
UNION ALL SELECT 65, 1, 3, 1, 47 FROM dual
UNION ALL SELECT 65, 2, 4, 2, 60 FROM dual
UNION ALL SELECT 66, 1, 49, 6, 294 FROM dual
UNION ALL SELECT 66, 2, 16, 8, 352 FROM dual
UNION ALL SELECT 66, 3, 38, 6, 522 FROM dual
UNION ALL SELECT 67, 1, 23, 3, 72 FROM dual
UNION ALL SELECT 67, 2, 50, 1, 19 FROM dual
UNION ALL SELECT 67, 3, 33, 5, 150 FROM dual
UNION ALL SELECT 68, 1, 41, 1, 94 FROM dual
UNION ALL SELECT 68, 2, 19, 5, 185 FROM dual
UNION ALL SELECT 68, 3, 29, 3, 132 FROM dual
UNION ALL SELECT 68, 4, 12, 3, 135 FROM dual
UNION ALL SELECT 68, 5, 10, 3, 204 FROM dual
UNION ALL SELECT 69, 1, 45, 6, 258 FROM dual
UNION ALL SELECT 70, 1, 37, 4, 156 FROM dual
UNION ALL SELECT 70, 2, 1, 5, 255 FROM dual
UNION ALL SELECT 70, 3, 7, 4, 140 FROM dual
UNION ALL SELECT 70, 4, 13, 4, 368 FROM dual
UNION ALL SELECT 71, 1, 32, 7, 238 FROM dual
UNION ALL SELECT 71, 2, 5, 5, 390 FROM dual
UNION ALL SELECT 71, 3, 34, 7, 574 FROM dual
UNION ALL SELECT 71, 4, 21, 7, 588 FROM dual
UNION ALL SELECT 71, 5, 46, 1, 35 FROM dual
UNION ALL SELECT 72, 1, 39, 2, 102 FROM dual
UNION ALL SELECT 72, 2, 2, 6, 372 FROM dual
UNION ALL SELECT 72, 3, 40, 1, 91 FROM dual
UNION ALL SELECT 72, 4, 31, 8, 712 FROM dual
UNION ALL SELECT 73, 1, 35, 4, 104 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 73 ord_id, 2 order_line, 36 prd_id, 2 quantity, 190 price FROM dual
UNION ALL SELECT 73, 3, 8, 8, 336 FROM dual
UNION ALL SELECT 74, 1, 26, 7, 259 FROM dual
UNION ALL SELECT 74, 2, 30, 4, 288 FROM dual
UNION ALL SELECT 74, 3, 25, 1, 48 FROM dual
UNION ALL SELECT 75, 1, 15, 1, 44 FROM dual
UNION ALL SELECT 76, 1, 18, 8, 160 FROM dual
UNION ALL SELECT 76, 2, 17, 1, 83 FROM dual
UNION ALL SELECT 76, 3, 44, 3, 84 FROM dual
UNION ALL SELECT 76, 4, 28, 2, 84 FROM dual
UNION ALL SELECT 77, 1, 11, 3, 213 FROM dual
UNION ALL SELECT 77, 2, 14, 2, 170 FROM dual
UNION ALL SELECT 77, 3, 6, 1, 39 FROM dual
UNION ALL SELECT 77, 4, 47, 7, 497 FROM dual
UNION ALL SELECT 78, 1, 43, 8, 408 FROM dual
UNION ALL SELECT 78, 2, 20, 8, 600 FROM dual
UNION ALL SELECT 78, 3, 9, 6, 216 FROM dual
UNION ALL SELECT 79, 1, 24, 4, 180 FROM dual
UNION ALL SELECT 79, 2, 48, 5, 425 FROM dual
UNION ALL SELECT 80, 1, 22, 2, 188 FROM dual
UNION ALL SELECT 80, 2, 27, 4, 232 FROM dual
UNION ALL SELECT 81, 1, 42, 1, 25 FROM dual
UNION ALL SELECT 81, 2, 3, 8, 376 FROM dual
UNION ALL SELECT 81, 3, 4, 4, 120 FROM dual
UNION ALL SELECT 81, 4, 49, 8, 392 FROM dual
UNION ALL SELECT 82, 1, 16, 2, 88 FROM dual
UNION ALL SELECT 82, 2, 38, 1, 87 FROM dual
UNION ALL SELECT 82, 3, 23, 1, 24 FROM dual
UNION ALL SELECT 83, 1, 50, 1, 19 FROM dual
UNION ALL SELECT 83, 2, 33, 3, 90 FROM dual
UNION ALL SELECT 83, 3, 41, 1, 94 FROM dual
UNION ALL SELECT 83, 4, 19, 8, 296 FROM dual
UNION ALL SELECT 84, 1, 29, 1, 44 FROM dual
UNION ALL SELECT 84, 2, 12, 8, 360 FROM dual
UNION ALL SELECT 85, 1, 10, 3, 204 FROM dual
UNION ALL SELECT 85, 2, 45, 5, 215 FROM dual
UNION ALL SELECT 86, 1, 37, 3, 117 FROM dual
UNION ALL SELECT 86, 2, 1, 3, 153 FROM dual
UNION ALL SELECT 86, 3, 7, 7, 245 FROM dual
UNION ALL SELECT 86, 4, 13, 5, 460 FROM dual
UNION ALL SELECT 86, 5, 32, 6, 204 FROM dual
UNION ALL SELECT 87, 1, 5, 3, 234 FROM dual
UNION ALL SELECT 87, 2, 34, 2, 164 FROM dual
UNION ALL SELECT 87, 3, 21, 5, 420 FROM dual
UNION ALL SELECT 87, 4, 46, 4, 140 FROM dual
UNION ALL SELECT 88, 1, 39, 5, 255 FROM dual
UNION ALL SELECT 89, 1, 2, 8, 496 FROM dual
UNION ALL SELECT 89, 2, 40, 1, 91 FROM dual
UNION ALL SELECT 89, 3, 31, 6, 534 FROM dual
UNION ALL SELECT 89, 4, 35, 3, 78 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 90 ord_id, 1 order_line, 36 prd_id, 6 quantity, 570 price FROM dual
UNION ALL SELECT 90, 2, 8, 6, 252 FROM dual
UNION ALL SELECT 91, 1, 26, 3, 111 FROM dual
UNION ALL SELECT 91, 2, 30, 2, 144 FROM dual
UNION ALL SELECT 92, 1, 25, 6, 288 FROM dual
UNION ALL SELECT 92, 2, 15, 1, 44 FROM dual
UNION ALL SELECT 92, 3, 18, 7, 140 FROM dual
UNION ALL SELECT 92, 4, 17, 8, 664 FROM dual
UNION ALL SELECT 92, 5, 44, 6, 168 FROM dual
UNION ALL SELECT 93, 1, 28, 6, 252 FROM dual
UNION ALL SELECT 93, 2, 11, 7, 497 FROM dual
UNION ALL SELECT 94, 1, 14, 7, 595 FROM dual
UNION ALL SELECT 94, 2, 6, 2, 78 FROM dual
UNION ALL SELECT 94, 3, 47, 6, 426 FROM dual
UNION ALL SELECT 95, 1, 43, 2, 102 FROM dual
UNION ALL SELECT 95, 2, 20, 8, 600 FROM dual
UNION ALL SELECT 95, 3, 9, 2, 72 FROM dual
UNION ALL SELECT 95, 4, 24, 6, 270 FROM dual
UNION ALL SELECT 96, 1, 48, 1, 85 FROM dual
UNION ALL SELECT 96, 2, 22, 5, 470 FROM dual
UNION ALL SELECT 96, 3, 27, 3, 174 FROM dual
UNION ALL SELECT 96, 4, 42, 3, 75 FROM dual
UNION ALL SELECT 96, 5, 3, 5, 235 FROM dual
UNION ALL SELECT 97, 1, 4, 5, 150 FROM dual
UNION ALL SELECT 97, 2, 49, 1, 49 FROM dual
UNION ALL SELECT 97, 3, 16, 3, 132 FROM dual
UNION ALL SELECT 97, 4, 38, 4, 348 FROM dual
UNION ALL SELECT 98, 1, 23, 5, 120 FROM dual
UNION ALL SELECT 98, 2, 50, 6, 114 FROM dual
UNION ALL SELECT 98, 3, 33, 1, 30 FROM dual
UNION ALL SELECT 98, 4, 41, 4, 376 FROM dual
UNION ALL SELECT 99, 1, 19, 2, 74 FROM dual
UNION ALL SELECT 99, 2, 29, 5, 220 FROM dual
UNION ALL SELECT 99, 3, 12, 8, 360 FROM dual
UNION ALL SELECT 100, 1, 10, 8, 544 FROM dual
UNION ALL SELECT 100, 2, 45, 8, 344 FROM dual
UNION ALL SELECT 100, 3, 37, 2, 78 FROM dual
UNION ALL SELECT 100, 4, 1, 3, 153 FROM dual
UNION ALL SELECT 101, 1, 7, 2, 70 FROM dual
UNION ALL SELECT 101, 2, 13, 3, 276 FROM dual
UNION ALL SELECT 101, 3, 32, 5, 170 FROM dual
UNION ALL SELECT 101, 4, 5, 5, 390 FROM dual
UNION ALL SELECT 101, 5, 34, 4, 328 FROM dual
UNION ALL SELECT 102, 1, 21, 7, 588 FROM dual
UNION ALL SELECT 102, 2, 46, 7, 245 FROM dual
UNION ALL SELECT 102, 3, 39, 8, 408 FROM dual
UNION ALL SELECT 102, 4, 2, 6, 372 FROM dual
UNION ALL SELECT 102, 5, 40, 4, 364 FROM dual
UNION ALL SELECT 103, 1, 31, 4, 356 FROM dual
UNION ALL SELECT 104, 1, 35, 4, 104 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 104 ord_id, 2 order_line, 36 prd_id, 7 quantity, 665 price FROM dual
UNION ALL SELECT 105, 1, 8, 2, 84 FROM dual
UNION ALL SELECT 105, 2, 26, 6, 222 FROM dual
UNION ALL SELECT 106, 1, 30, 5, 360 FROM dual
UNION ALL SELECT 106, 2, 25, 3, 144 FROM dual
UNION ALL SELECT 106, 3, 15, 5, 220 FROM dual
UNION ALL SELECT 106, 4, 18, 6, 120 FROM dual
UNION ALL SELECT 106, 5, 17, 3, 249 FROM dual
UNION ALL SELECT 107, 1, 44, 3, 84 FROM dual
UNION ALL SELECT 107, 2, 28, 4, 168 FROM dual
UNION ALL SELECT 107, 3, 11, 6, 426 FROM dual
UNION ALL SELECT 107, 4, 14, 7, 595 FROM dual
UNION ALL SELECT 108, 1, 6, 1, 39 FROM dual
UNION ALL SELECT 108, 2, 47, 7, 497 FROM dual
UNION ALL SELECT 108, 3, 43, 3, 153 FROM dual
UNION ALL SELECT 108, 4, 20, 3, 225 FROM dual
UNION ALL SELECT 109, 1, 9, 6, 216 FROM dual
UNION ALL SELECT 109, 2, 24, 7, 315 FROM dual
UNION ALL SELECT 110, 1, 48, 8, 680 FROM dual
UNION ALL SELECT 110, 2, 22, 1, 94 FROM dual
UNION ALL SELECT 111, 1, 27, 3, 174 FROM dual
UNION ALL SELECT 111, 2, 42, 5, 125 FROM dual
UNION ALL SELECT 111, 3, 3, 8, 376 FROM dual
UNION ALL SELECT 111, 4, 4, 3, 90 FROM dual
UNION ALL SELECT 112, 1, 49, 3, 147 FROM dual
UNION ALL SELECT 112, 2, 16, 5, 220 FROM dual
UNION ALL SELECT 112, 3, 38, 8, 696 FROM dual
UNION ALL SELECT 112, 4, 23, 2, 48 FROM dual
UNION ALL SELECT 112, 5, 50, 7, 133 FROM dual
UNION ALL SELECT 113, 1, 33, 3, 90 FROM dual
UNION ALL SELECT 113, 2, 41, 8, 752 FROM dual
UNION ALL SELECT 113, 3, 19, 8, 296 FROM dual
UNION ALL SELECT 114, 1, 29, 1, 44 FROM dual
UNION ALL SELECT 115, 1, 12, 6, 270 FROM dual
UNION ALL SELECT 115, 2, 10, 5, 340 FROM dual
UNION ALL SELECT 115, 3, 45, 3, 129 FROM dual
UNION ALL SELECT 116, 1, 37, 6, 234 FROM dual
UNION ALL SELECT 116, 2, 1, 1, 51 FROM dual
UNION ALL SELECT 116, 3, 7, 7, 245 FROM dual
UNION ALL SELECT 116, 4, 13, 8, 736 FROM dual
UNION ALL SELECT 116, 5, 32, 3, 102 FROM dual
UNION ALL SELECT 117, 1, 5, 7, 546 FROM dual
UNION ALL SELECT 117, 2, 34, 6, 492 FROM dual
UNION ALL SELECT 117, 3, 21, 3, 252 FROM dual
UNION ALL SELECT 117, 4, 46, 6, 210 FROM dual
UNION ALL SELECT 118, 1, 39, 4, 204 FROM dual
UNION ALL SELECT 118, 2, 2, 5, 310 FROM dual
UNION ALL SELECT 118, 3, 40, 1, 91 FROM dual
UNION ALL SELECT 118, 4, 31, 7, 623 FROM dual
UNION ALL SELECT 118, 5, 35, 2, 52 FROM dual
;
INSERT INTO demo_order_items_tde (ord_id, order_line, prd_id, quantity, price)
SELECT 119 ord_id, 1 order_line, 36 prd_id, 5 quantity, 475 price FROM dual
UNION ALL SELECT 119, 2, 8, 1, 42 FROM dual
UNION ALL SELECT 119, 3, 26, 6, 222 FROM dual
UNION ALL SELECT 119, 4, 30, 5, 360 FROM dual
UNION ALL SELECT 120, 1, 25, 7, 336 FROM dual
UNION ALL SELECT 120, 2, 15, 3, 132 FROM dual
UNION ALL SELECT 121, 1, 18, 3, 60 FROM dual
UNION ALL SELECT 121, 2, 17, 2, 166 FROM dual
UNION ALL SELECT 121, 3, 44, 7, 196 FROM dual
UNION ALL SELECT 122, 1, 28, 5, 210 FROM dual
UNION ALL SELECT 122, 2, 11, 2, 142 FROM dual
UNION ALL SELECT 122, 3, 14, 3, 255 FROM dual
UNION ALL SELECT 123, 1, 6, 6, 234 FROM dual
UNION ALL SELECT 123, 2, 47, 4, 284 FROM dual
UNION ALL SELECT 123, 3, 43, 5, 255 FROM dual
UNION ALL SELECT 123, 4, 20, 7, 525 FROM dual
UNION ALL SELECT 123, 5, 9, 2, 72 FROM dual
;
INSERT INTO demo_per_transactions_tde (per_id, ord_id, credit_card_nbr, transaction_timestamp, transaction_amount)
SELECT 1 per_id, 1 ord_id, '6011162323611188' credit_card_nbr, TO_TIMESTAMP('03/06/2025 11:24:16.000000','DD/MM/YYYY HH24:MI:SS.FF') transaction_timestamp, 665 transaction_amount FROM dual
UNION ALL SELECT 2, 2, '4140469111791513', TO_TIMESTAMP('24/09/2025 06:25:53.000000','DD/MM/YYYY HH24:MI:SS.FF'), 516 FROM dual
UNION ALL SELECT 2, 3, '4140469111791513', TO_TIMESTAMP('28/03/2025 12:28:22.000000','DD/MM/YYYY HH24:MI:SS.FF'), 122.4 FROM dual
UNION ALL SELECT 2, 3, '382073592625920', TO_TIMESTAMP('29/03/2025 05:41:39.000000','DD/MM/YYYY HH24:MI:SS.FF'), 285.6 FROM dual
UNION ALL SELECT 3, 4, '6011696799954218', TO_TIMESTAMP('29/01/2025 15:23:34.000000','DD/MM/YYYY HH24:MI:SS.FF'), 264 FROM dual
UNION ALL SELECT 4, 5, '5177991011294440', TO_TIMESTAMP('05/05/2025 03:17:35.000000','DD/MM/YYYY HH24:MI:SS.FF'), 862 FROM dual
UNION ALL SELECT 4, 7, '5177991011294440', TO_TIMESTAMP('11/11/2025 03:52:11.000000','DD/MM/YYYY HH24:MI:SS.FF'), 289.2 FROM dual
UNION ALL SELECT 4, 7, '4115776781233571', TO_TIMESTAMP('13/11/2025 08:38:27.000000','DD/MM/YYYY HH24:MI:SS.FF'), 674.8 FROM dual
UNION ALL SELECT 4, 8, '4115776781233571', TO_TIMESTAMP('01/05/2025 07:36:17.000000','DD/MM/YYYY HH24:MI:SS.FF'), 343.8 FROM dual
UNION ALL SELECT 4, 8, '6011304468146246', TO_TIMESTAMP('02/05/2025 20:11:32.000000','DD/MM/YYYY HH24:MI:SS.FF'), 802.2 FROM dual
UNION ALL SELECT 5, 9, '5597493789501223', TO_TIMESTAMP('22/02/2025 23:02:59.000000','DD/MM/YYYY HH24:MI:SS.FF'), 333 FROM dual
UNION ALL SELECT 5, 10, '4837415266685206', TO_TIMESTAMP('06/02/2025 08:22:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 148.2 FROM dual
UNION ALL SELECT 5, 10, '5597493789501223', TO_TIMESTAMP('08/02/2025 07:32:51.000000','DD/MM/YYYY HH24:MI:SS.FF'), 345.8 FROM dual
UNION ALL SELECT 5, 11, '5597493789501223', TO_TIMESTAMP('01/11/2025 06:07:06.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1173 FROM dual
UNION ALL SELECT 5, 12, '6011527446112761', TO_TIMESTAMP('23/12/2025 02:39:16.000000','DD/MM/YYYY HH24:MI:SS.FF'), 14.4 FROM dual
UNION ALL SELECT 5, 12, '4837415266685206', TO_TIMESTAMP('27/12/2025 12:00:28.000000','DD/MM/YYYY HH24:MI:SS.FF'), 33.6 FROM dual
UNION ALL SELECT 5, 13, '4837415266685206', TO_TIMESTAMP('24/03/2025 23:27:42.000000','DD/MM/YYYY HH24:MI:SS.FF'), 354 FROM dual
UNION ALL SELECT 6, 14, '346690274769646', TO_TIMESTAMP('30/07/2025 02:47:11.000000','DD/MM/YYYY HH24:MI:SS.FF'), 112.8 FROM dual
UNION ALL SELECT 6, 14, '6011502685402371', TO_TIMESTAMP('31/07/2025 11:42:25.000000','DD/MM/YYYY HH24:MI:SS.FF'), 263.2 FROM dual
UNION ALL SELECT 6, 15, '6011502685402371', TO_TIMESTAMP('01/11/2025 01:07:07.000000','DD/MM/YYYY HH24:MI:SS.FF'), 111 FROM dual
UNION ALL SELECT 6, 17, '346690274769646', TO_TIMESTAMP('30/07/2025 01:42:16.000000','DD/MM/YYYY HH24:MI:SS.FF'), 425.7 FROM dual
UNION ALL SELECT 6, 17, '6011502685402371', TO_TIMESTAMP('03/08/2025 09:36:58.000000','DD/MM/YYYY HH24:MI:SS.FF'), 993.3 FROM dual
UNION ALL SELECT 7, 20, '357106061023747', TO_TIMESTAMP('01/01/2025 08:35:44.000000','DD/MM/YYYY HH24:MI:SS.FF'), 360 FROM dual
UNION ALL SELECT 8, 24, '6011193693878412', TO_TIMESTAMP('06/07/2025 19:20:01.000000','DD/MM/YYYY HH24:MI:SS.FF'), 199.2 FROM dual
UNION ALL SELECT 8, 24, '5670458189471574', TO_TIMESTAMP('09/07/2025 06:25:26.000000','DD/MM/YYYY HH24:MI:SS.FF'), 464.8 FROM dual
UNION ALL SELECT 9, 25, '325993111490029', TO_TIMESTAMP('21/12/2025 08:27:19.000000','DD/MM/YYYY HH24:MI:SS.FF'), 28 FROM dual
UNION ALL SELECT 9, 26, '325993111490029', TO_TIMESTAMP('25/10/2025 16:53:42.000000','DD/MM/YYYY HH24:MI:SS.FF'), 877 FROM dual
UNION ALL SELECT 11, 31, '5901342220950021', TO_TIMESTAMP('13/12/2025 18:51:26.000000','DD/MM/YYYY HH24:MI:SS.FF'), 192 FROM dual
UNION ALL SELECT 11, 31, '363277130339471', TO_TIMESTAMP('15/12/2025 23:53:10.000000','DD/MM/YYYY HH24:MI:SS.FF'), 448 FROM dual
UNION ALL SELECT 11, 32, '5901342220950021', TO_TIMESTAMP('16/07/2025 00:36:17.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1079 FROM dual
UNION ALL SELECT 11, 34, '5901342220950021', TO_TIMESTAMP('09/05/2025 02:07:25.000000','DD/MM/YYYY HH24:MI:SS.FF'), 194 FROM dual
UNION ALL SELECT 13, 37, '6011841911590496', TO_TIMESTAMP('13/11/2025 22:32:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 252 FROM dual
UNION ALL SELECT 13, 38, '6011841911590496', TO_TIMESTAMP('01/08/2025 03:03:20.000000','DD/MM/YYYY HH24:MI:SS.FF'), 507.3 FROM dual
UNION ALL SELECT 13, 38, '5174408700044526', TO_TIMESTAMP('02/08/2025 11:26:12.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1183.7 FROM dual
UNION ALL SELECT 13, 39, '6011841911590496', TO_TIMESTAMP('24/11/2025 00:30:30.000000','DD/MM/YYYY HH24:MI:SS.FF'), 310.5 FROM dual
UNION ALL SELECT 13, 39, '5174408700044526', TO_TIMESTAMP('27/11/2025 16:15:14.000000','DD/MM/YYYY HH24:MI:SS.FF'), 724.5 FROM dual
UNION ALL SELECT 13, 40, '6011841911590496', TO_TIMESTAMP('08/04/2025 15:59:14.000000','DD/MM/YYYY HH24:MI:SS.FF'), 114 FROM dual
UNION ALL SELECT 13, 40, '5174408700044526', TO_TIMESTAMP('12/04/2025 20:51:38.000000','DD/MM/YYYY HH24:MI:SS.FF'), 266 FROM dual
UNION ALL SELECT 14, 41, '326146033144674', TO_TIMESTAMP('21/04/2025 17:20:25.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1374 FROM dual
UNION ALL SELECT 14, 42, '4225794170764244', TO_TIMESTAMP('17/02/2025 17:03:59.000000','DD/MM/YYYY HH24:MI:SS.FF'), 117.6 FROM dual
UNION ALL SELECT 14, 42, '326146033144674', TO_TIMESTAMP('19/02/2025 05:19:50.000000','DD/MM/YYYY HH24:MI:SS.FF'), 274.4 FROM dual
UNION ALL SELECT 14, 43, '4225794170764244', TO_TIMESTAMP('19/01/2025 21:52:33.000000','DD/MM/YYYY HH24:MI:SS.FF'), 195.9 FROM dual
UNION ALL SELECT 14, 43, '326146033144674', TO_TIMESTAMP('21/01/2025 12:02:23.000000','DD/MM/YYYY HH24:MI:SS.FF'), 457.1 FROM dual
UNION ALL SELECT 14, 44, '326146033144674', TO_TIMESTAMP('10/06/2025 06:03:23.000000','DD/MM/YYYY HH24:MI:SS.FF'), 394.2 FROM dual
UNION ALL SELECT 14, 44, '4225794170764244', TO_TIMESTAMP('15/06/2025 04:23:01.000000','DD/MM/YYYY HH24:MI:SS.FF'), 919.8 FROM dual
UNION ALL SELECT 15, 45, '5043071072569915', TO_TIMESTAMP('25/02/2025 11:13:56.000000','DD/MM/YYYY HH24:MI:SS.FF'), 555 FROM dual
UNION ALL SELECT 15, 46, '5043071072569915', TO_TIMESTAMP('22/09/2025 11:06:02.000000','DD/MM/YYYY HH24:MI:SS.FF'), 28.2 FROM dual
UNION ALL SELECT 15, 46, '6011959136838571', TO_TIMESTAMP('24/09/2025 00:59:57.000000','DD/MM/YYYY HH24:MI:SS.FF'), 65.8 FROM dual
UNION ALL SELECT 15, 47, '6011959136838571', TO_TIMESTAMP('20/12/2025 13:45:13.000000','DD/MM/YYYY HH24:MI:SS.FF'), 431 FROM dual
UNION ALL SELECT 15, 48, '5043071072569915', TO_TIMESTAMP('03/05/2025 04:01:37.000000','DD/MM/YYYY HH24:MI:SS.FF'), 877 FROM dual
;
INSERT INTO demo_per_transactions_tde (per_id, ord_id, credit_card_nbr, transaction_timestamp, transaction_amount)
SELECT 15 per_id, 49 ord_id, '6011959136838571' credit_card_nbr, TO_TIMESTAMP('08/12/2025 04:05:48.000000','DD/MM/YYYY HH24:MI:SS.FF') transaction_timestamp, 120 transaction_amount FROM dual
UNION ALL SELECT 16, 50, '4389524019804022', TO_TIMESTAMP('04/09/2025 05:32:16.000000','DD/MM/YYYY HH24:MI:SS.FF'), 38 FROM dual
UNION ALL SELECT 18, 52, '6011996682698157', TO_TIMESTAMP('02/02/2025 22:52:30.000000','DD/MM/YYYY HH24:MI:SS.FF'), 294.6 FROM dual
UNION ALL SELECT 18, 52, '4434339814944674', TO_TIMESTAMP('03/02/2025 00:27:17.000000','DD/MM/YYYY HH24:MI:SS.FF'), 687.4 FROM dual
UNION ALL SELECT 18, 53, '4434339814944674', TO_TIMESTAMP('27/09/2025 16:49:02.000000','DD/MM/YYYY HH24:MI:SS.FF'), 304.2 FROM dual
UNION ALL SELECT 18, 53, '6011996682698157', TO_TIMESTAMP('28/09/2025 03:27:21.000000','DD/MM/YYYY HH24:MI:SS.FF'), 709.8 FROM dual
UNION ALL SELECT 19, 54, '6011615380194877', TO_TIMESTAMP('05/03/2025 00:05:56.000000','DD/MM/YYYY HH24:MI:SS.FF'), 31.5 FROM dual
UNION ALL SELECT 19, 54, '308226754659399', TO_TIMESTAMP('10/03/2025 02:26:48.000000','DD/MM/YYYY HH24:MI:SS.FF'), 73.5 FROM dual
UNION ALL SELECT 19, 55, '6011615380194877', TO_TIMESTAMP('05/04/2025 21:14:20.000000','DD/MM/YYYY HH24:MI:SS.FF'), 49.2 FROM dual
UNION ALL SELECT 19, 55, '308226754659399', TO_TIMESTAMP('11/04/2025 12:03:52.000000','DD/MM/YYYY HH24:MI:SS.FF'), 114.8 FROM dual
UNION ALL SELECT 19, 56, '308226754659399', TO_TIMESTAMP('01/08/2025 12:26:56.000000','DD/MM/YYYY HH24:MI:SS.FF'), 109.2 FROM dual
UNION ALL SELECT 19, 56, '6011615380194877', TO_TIMESTAMP('02/08/2025 16:47:45.000000','DD/MM/YYYY HH24:MI:SS.FF'), 254.8 FROM dual
UNION ALL SELECT 19, 57, '6011615380194877', TO_TIMESTAMP('09/03/2025 03:27:09.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1187 FROM dual
UNION ALL SELECT 19, 58, '6011615380194877', TO_TIMESTAMP('18/10/2025 20:33:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 796 FROM dual
UNION ALL SELECT 20, 59, '5021814753438553', TO_TIMESTAMP('16/10/2025 18:57:13.000000','DD/MM/YYYY HH24:MI:SS.FF'), 173.7 FROM dual
UNION ALL SELECT 20, 59, '4675842375964724', TO_TIMESTAMP('17/10/2025 02:15:19.000000','DD/MM/YYYY HH24:MI:SS.FF'), 405.3 FROM dual
UNION ALL SELECT 20, 62, '4675842375964724', TO_TIMESTAMP('02/08/2025 07:12:18.000000','DD/MM/YYYY HH24:MI:SS.FF'), 259.2 FROM dual
UNION ALL SELECT 20, 62, '5021814753438553', TO_TIMESTAMP('04/08/2025 12:47:03.000000','DD/MM/YYYY HH24:MI:SS.FF'), 604.8 FROM dual
UNION ALL SELECT 22, 63, '6011155721584486', TO_TIMESTAMP('22/02/2025 20:10:37.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1165 FROM dual
UNION ALL SELECT 23, 64, '6011335891912911', TO_TIMESTAMP('23/08/2025 22:09:53.000000','DD/MM/YYYY HH24:MI:SS.FF'), 25 FROM dual
UNION ALL SELECT 24, 65, '5618680640371375', TO_TIMESTAMP('31/05/2025 08:49:59.000000','DD/MM/YYYY HH24:MI:SS.FF'), 107 FROM dual
UNION ALL SELECT 24, 66, '5618680640371375', TO_TIMESTAMP('10/09/2025 06:26:34.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1168 FROM dual
UNION ALL SELECT 24, 67, '5618680640371375', TO_TIMESTAMP('12/12/2025 09:20:57.000000','DD/MM/YYYY HH24:MI:SS.FF'), 241 FROM dual
UNION ALL SELECT 26, 69, '6011504709896596', TO_TIMESTAMP('03/11/2025 07:36:40.000000','DD/MM/YYYY HH24:MI:SS.FF'), 258 FROM dual
UNION ALL SELECT 28, 70, '5533903301398145', TO_TIMESTAMP('30/08/2025 03:21:05.000000','DD/MM/YYYY HH24:MI:SS.FF'), 919 FROM dual
UNION ALL SELECT 28, 71, '5533903301398145', TO_TIMESTAMP('29/07/2025 10:44:07.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1825 FROM dual
UNION ALL SELECT 28, 72, '6011709071160071', TO_TIMESTAMP('26/01/2025 02:29:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1277 FROM dual
UNION ALL SELECT 30, 74, '316261551618553', TO_TIMESTAMP('10/12/2025 09:13:41.000000','DD/MM/YYYY HH24:MI:SS.FF'), 595 FROM dual
UNION ALL SELECT 30, 76, '6011096962056703', TO_TIMESTAMP('02/03/2025 17:15:19.000000','DD/MM/YYYY HH24:MI:SS.FF'), 411 FROM dual
UNION ALL SELECT 32, 78, '6011045620869601', TO_TIMESTAMP('03/02/2025 19:06:26.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1224 FROM dual
UNION ALL SELECT 32, 79, '357827706066870', TO_TIMESTAMP('15/09/2025 14:20:49.000000','DD/MM/YYYY HH24:MI:SS.FF'), 181.5 FROM dual
UNION ALL SELECT 32, 79, '4013790965171617', TO_TIMESTAMP('21/09/2025 22:50:36.000000','DD/MM/YYYY HH24:MI:SS.FF'), 423.5 FROM dual
UNION ALL SELECT 34, 81, '5523041750168669', TO_TIMESTAMP('04/05/2025 07:57:13.000000','DD/MM/YYYY HH24:MI:SS.FF'), 913 FROM dual
UNION ALL SELECT 34, 84, '5523041750168669', TO_TIMESTAMP('24/12/2025 08:15:40.000000','DD/MM/YYYY HH24:MI:SS.FF'), 404 FROM dual
UNION ALL SELECT 34, 85, '5523041750168669', TO_TIMESTAMP('31/07/2025 19:35:30.000000','DD/MM/YYYY HH24:MI:SS.FF'), 419 FROM dual
UNION ALL SELECT 35, 86, '6011052365445035', TO_TIMESTAMP('15/05/2025 21:36:20.000000','DD/MM/YYYY HH24:MI:SS.FF'), 353.7 FROM dual
UNION ALL SELECT 35, 86, '381068621086327', TO_TIMESTAMP('16/05/2025 23:35:53.000000','DD/MM/YYYY HH24:MI:SS.FF'), 825.3 FROM dual
UNION ALL SELECT 35, 88, '381068621086327', TO_TIMESTAMP('18/11/2025 22:18:10.000000','DD/MM/YYYY HH24:MI:SS.FF'), 76.5 FROM dual
UNION ALL SELECT 35, 88, '6011052365445035', TO_TIMESTAMP('19/11/2025 19:06:35.000000','DD/MM/YYYY HH24:MI:SS.FF'), 178.5 FROM dual
UNION ALL SELECT 35, 89, '381068621086327', TO_TIMESTAMP('07/04/2025 09:01:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1199 FROM dual
UNION ALL SELECT 36, 91, '5962896882415983', TO_TIMESTAMP('08/01/2025 16:16:58.000000','DD/MM/YYYY HH24:MI:SS.FF'), 255 FROM dual
UNION ALL SELECT 37, 93, '387029481836569', TO_TIMESTAMP('27/02/2025 13:52:28.000000','DD/MM/YYYY HH24:MI:SS.FF'), 749 FROM dual
UNION ALL SELECT 37, 94, '387029481836569', TO_TIMESTAMP('04/04/2025 17:46:41.000000','DD/MM/YYYY HH24:MI:SS.FF'), 329.7 FROM dual
UNION ALL SELECT 37, 94, '6011292570650835', TO_TIMESTAMP('11/04/2025 15:01:33.000000','DD/MM/YYYY HH24:MI:SS.FF'), 769.3 FROM dual
UNION ALL SELECT 37, 95, '6011292570650835', TO_TIMESTAMP('27/10/2025 04:31:14.000000','DD/MM/YYYY HH24:MI:SS.FF'), 313.2 FROM dual
UNION ALL SELECT 37, 95, '387029481836569', TO_TIMESTAMP('29/10/2025 16:19:46.000000','DD/MM/YYYY HH24:MI:SS.FF'), 730.8 FROM dual
UNION ALL SELECT 38, 97, '6011336643806492', TO_TIMESTAMP('08/07/2025 15:32:08.000000','DD/MM/YYYY HH24:MI:SS.FF'), 679 FROM dual
UNION ALL SELECT 38, 98, '5747284583676330', TO_TIMESTAMP('15/08/2025 10:54:47.000000','DD/MM/YYYY HH24:MI:SS.FF'), 640 FROM dual
UNION ALL SELECT 38, 99, '354994751756160', TO_TIMESTAMP('02/10/2025 12:51:19.000000','DD/MM/YYYY HH24:MI:SS.FF'), 196.2 FROM dual
UNION ALL SELECT 38, 99, '4772921573972804', TO_TIMESTAMP('03/10/2025 18:56:31.000000','DD/MM/YYYY HH24:MI:SS.FF'), 457.8 FROM dual
;
INSERT INTO demo_per_transactions_tde (per_id, ord_id, credit_card_nbr, transaction_timestamp, transaction_amount)
SELECT 40 per_id, 100 ord_id, '5600178072747824' credit_card_nbr, TO_TIMESTAMP('05/09/2025 13:03:51.000000','DD/MM/YYYY HH24:MI:SS.FF') transaction_timestamp, 1119 transaction_amount FROM dual
UNION ALL SELECT 43, 103, '5567907836305672', TO_TIMESTAMP('14/04/2025 14:36:20.000000','DD/MM/YYYY HH24:MI:SS.FF'), 356 FROM dual
UNION ALL SELECT 45, 109, '6011151171028850', TO_TIMESTAMP('15/06/2025 23:15:42.000000','DD/MM/YYYY HH24:MI:SS.FF'), 159.3 FROM dual
UNION ALL SELECT 45, 109, '314061473697988', TO_TIMESTAMP('20/06/2025 21:36:44.000000','DD/MM/YYYY HH24:MI:SS.FF'), 371.7 FROM dual
UNION ALL SELECT 45, 110, '5611746361180217', TO_TIMESTAMP('02/05/2025 12:22:29.000000','DD/MM/YYYY HH24:MI:SS.FF'), 774 FROM dual
UNION ALL SELECT 45, 111, '5611746361180217', TO_TIMESTAMP('10/06/2025 18:08:58.000000','DD/MM/YYYY HH24:MI:SS.FF'), 765 FROM dual
UNION ALL SELECT 46, 112, '6011854210657288', TO_TIMESTAMP('25/09/2025 05:07:54.000000','DD/MM/YYYY HH24:MI:SS.FF'), 373.2 FROM dual
UNION ALL SELECT 46, 112, '353115905028311', TO_TIMESTAMP('26/09/2025 15:41:26.000000','DD/MM/YYYY HH24:MI:SS.FF'), 870.8 FROM dual
UNION ALL SELECT 46, 113, '6011854210657288', TO_TIMESTAMP('29/09/2025 20:45:13.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1138 FROM dual
UNION ALL SELECT 46, 114, '4477378504560752', TO_TIMESTAMP('17/01/2025 10:59:01.000000','DD/MM/YYYY HH24:MI:SS.FF'), 13.2 FROM dual
UNION ALL SELECT 46, 114, '6011854210657288', TO_TIMESTAMP('21/01/2025 19:06:23.000000','DD/MM/YYYY HH24:MI:SS.FF'), 30.8 FROM dual
UNION ALL SELECT 47, 115, '4339452698045231', TO_TIMESTAMP('05/05/2025 23:01:16.000000','DD/MM/YYYY HH24:MI:SS.FF'), 221.7 FROM dual
UNION ALL SELECT 47, 115, '5518879552899925', TO_TIMESTAMP('10/05/2025 20:53:42.000000','DD/MM/YYYY HH24:MI:SS.FF'), 517.3 FROM dual
UNION ALL SELECT 48, 116, '4402308484388353', TO_TIMESTAMP('09/04/2025 01:15:44.000000','DD/MM/YYYY HH24:MI:SS.FF'), 410.4 FROM dual
UNION ALL SELECT 48, 116, '5176201707777380', TO_TIMESTAMP('11/04/2025 10:13:19.000000','DD/MM/YYYY HH24:MI:SS.FF'), 957.6 FROM dual
UNION ALL SELECT 48, 118, '304985565722415', TO_TIMESTAMP('22/03/2025 18:11:16.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1280 FROM dual
UNION ALL SELECT 48, 120, '4402308484388353', TO_TIMESTAMP('11/10/2025 14:19:59.000000','DD/MM/YYYY HH24:MI:SS.FF'), 468 FROM dual
UNION ALL SELECT 50, 123, '5661534932416909', TO_TIMESTAMP('29/04/2025 06:29:56.000000','DD/MM/YYYY HH24:MI:SS.FF'), 1370 FROM dual
;