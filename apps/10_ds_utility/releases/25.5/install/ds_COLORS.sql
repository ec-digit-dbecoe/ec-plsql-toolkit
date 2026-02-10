REM Source: Generated with ChatGPT
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#NAME
C(20)
Almond
Amber
Amethyst
Apricot
Aqua
Aqua Blue
Aquamarine
Ash Grey
Auburn
Avocado
Azure
Baby Blue
Baby Green
Baby Pink
Baby Purple
Beige
Beige White
Black
Blue
Brick
Brick Red
Bronze
Brown
Burgundy
Burgundy Red
Burnt Orange
Burnt Sienna
Burnt Umber
Caramel
Celadon
Charcoal
Charcoal Grey
Chocolate Brown
Cobalt Blue
Coral
Coral Pink
Corn
Corn Yellow
Cornflower Blue
Cream
Cyan
Cyan Blue
Dark Green
Denim
Dusty Rose
Eggplant
Eggshell
Electric Blue
Electric Green
Electric Purple
Emerald
Forest Green
Frost
Gold
Grass Green
Heather
Honey
Ice Blue
Indigo
Ivory
Ivory White
Jade
Khaki
Lavender
Lavender Blue
Lavender Grey
Lavender Purple
Lemon
Lemon Lime
Lemon Yellow
Lilac
Lilac Purple
Lime Green
Magenta
Marigold
Maroon
Maroon Red
Midnight Blue
Mint
Mocha
Moss
Moss Green
Mustard
Navy
Navy Blue
Olive
Olive Green
Orchid
Papaya
Peach
Peacock
Peacock Blue
Peacock Green
Pearl
Periwinkle
Persimmon
Pewter
Pine Green
Pink
Plum
Powder Blue
Powder Pink
Pumpkin
Pumpkin Orange
Raspberry
Red
Rose
Rose Pink
Ruby
Ruby Red
Rust
Sage Green
Salmon
Sand
Sandalwood
Sandstone
Sapphire
Sapphire Blue
Sea Blue
Sea Green
Seafoam Green
Seashell
Sienna
Sienna Brown
Silver
Sky Blue
Slate
Slate Blue
Slate Grey
Slate Grey
Steel Blue
Steel Grey
Strawberry
Sunflower Yellow
Tan
Tan Brown
Tangerine
Teal
Teal Green
Tomato Red
Topaz
Turquoise
Turquoise Blue
Turquoise Green
Violet
Wheat
White
Wine
Wine Red
Yellow#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'COLORS', p_set_type=>'CSV', p_params=>my_clob, p_system_flag=>'Y');
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
