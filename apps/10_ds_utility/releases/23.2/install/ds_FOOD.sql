REM Source: https://copylists.com/
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#NAME	TYPE
C(20)	C(10)
Apple	Fruit
Apricot	Fruit
Avocado	Fruit
Banana	Fruit
Blueberry	Fruit
Cherry	Fruit
Coconut	Fruit
Grape	Fruit
Grapefruit	Fruit
Fig	Fruit
Kiwi	Fruit
Lemon	Fruit
Lime	Fruit
Mandarin	Fruit
Mango	Fruit
Melon	Fruit
Nectarine	Fruit
Orange	Fruit
Papaya	Fruit
Passion fruit	Fruit
Peach	Fruit
Pear	Fruit
Pineapple	Fruit
Plum	Fruit
Pomegranate	Fruit
Raspberry	Fruit
Strawberry	Fruit
Watermelon	Fruit
Blueberry	Fruit
Lychee	Fruit
Pomelo	Fruit
Jackfruit	Fruit
Wax Apples	Fruit
Lychee	Fruit
Rambutan	Fruit
Durian	Fruit
Asian Pear	Fruit
Mangosteen	Fruit
Longan	Fruit
Guava	Fruit
Lotus Fruit	Fruit
Sugar Apple	Fruit
Chinese Bayberry	Fruit
Starfruit	Fruit
Pulasan	Fruit
Kumquat	Fruit
Breadfruit	Fruit
Dragon Fruit	Fruit
Santol	Fruit
Langsat	Fruit
Mango	Fruit
Snake Fruit	Fruit
Japanese Persimmon	Fruit
Passion Fruit 	Fruit
Artichoke	Vegetable
Red onion	Vegetable
Spinach	Vegetable
Sweet potato	Vegetable
Tomato	Vegetable
Yam	Vegetable
Asparagus	Vegetable
Carrot	Vegetable
Cauliflower	Vegetable
Celery	Vegetable
Chayote	Vegetable
Bamboo shoots	Vegetable
Bean sprouts	Vegetable
Green onion	Vegetable
Leek	Vegetable
Lettuce	Vegetable
Mushroom	Vegetable
Onion	Vegetable
Parsnip	Vegetable
Beans	Vegetable
Beetroot	Vegetable
Pepper	Vegetable
Potato	Vegetable
Pumpkin	Vegetable
Radicchio	Vegetable
Radish	Vegetable
Bell pepper	Vegetable
Broccoli	Vegetable
Brussels sprouts	Vegetable
Cabbage	Vegetable
Cactus pear	Vegetable
Collard greens	Vegetable
Corn	Vegetable
Cucumber	Vegetable
Eggplant	Vegetable
Endive	Vegetable
Escarole	Vegetable
Garlic	Vegetable
Green beans	Vegetable
Pea	Vegetable
Red cabbage	Vegetable
Red chili pepper	Vegetable
Yellow squash	Vegetable
Zucchini	Vegetable
Anchovies	Seefood
Barracuda	Seefood
Basa	Seefood
Bass	Seefood
Black cod	Seefood
Blowfish	Seefood
Bluefish	Seefood
Bombay duck	Seefood
Bream	Seefood
Brill	Seefood
Butter fish	Seefood
Catfish	Seefood
Cod	Seefood
Dogfish	Seefood
Dorade	Seefood
Eel	Seefood
Flounder	Seefood
Grouper	Seefood
Haddock	Seefood
Hake	Seefood
Halibut	Seefood
Herring	Seefood
Ilish	Seefood
John Dory	Seefood
Lamprey	Seefood
Lingcod	Seefood
Mackerel	Seefood
Mahi Mahi	Seefood
Monkfish	Seefood
Mullet	Seefood
Orange roughy	Seefood
Parrotfish	Seefood
Patagonian toothfish	Seefood
Perch	Seefood
Pike	Seefood
Pilchard	Seefood
Pollock	Seefood
Pomfret	Seefood
Pompano	Seefood
Sablefish	Seefood
Salmon	Seefood
Sanddab	Seefood
Sardine	Seefood
Sea bass	Seefood
Shad	Seefood
Shark	Seefood
Skate	Seefood
Smelt	Seefood
Snakehead	Seefood
Snapper	Seefood
Sole	Seefood
Sprat	Seefood
Sturgeon	Seefood
Surimi	Seefood
Swordfish	Seefood
Tilapia	Seefood
Tilefish	Seefood
Trout	Seefood
Tuna	Seefood
Turbot	Seefood
Wahoo	Seefood
Whitefish	Seefood
Whiting	Seefood
Witch	Seefood#');
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
