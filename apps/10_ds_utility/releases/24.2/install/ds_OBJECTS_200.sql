REM Source: Generated with ChatGPT & Gemini
DECLARE
   my_clob CLOB;
   l_set_id ds_data_sets.set_id%TYPE;
BEGIN
   dbms_lob.createtemporary(my_clob, true);
   dbms_lob.append(my_clob,
q'#NAME
C(24)
Air freshener
Alarm clock
Apple
Armchair
Backpack
Bag
Ball
Banana
Bandages
Basket
Batteries
Bed
Bicycle
Binder
Blackboard
Blanket
Blender
Book
Bookshelf
Bottle
Bowl
Bowtie
Box
Bracelet
Briefcase
Broom
Brush
Bucket
Bulletin board
Cabinet
Calculator
Calendar
Camera
Candle
Candle holder
Canvas
Car
Carbon monoxide detector
Carpet
Chair
Chalk
Chalkboard
Chopsticks
Clipboard
Clock
Closet
Coat
Coat rack
Coffee machine
Coffee mug
Coffee table
Comb
Comforter
Computer
Computer mouse
Conditioner
Copier
Couch
Cup
Curtains
Cushion
Cutting board
Desk
Dish soap
Dishwasher
Door
Drawer
Drawing pin
Dress
Dresser
Dryer
Dustpan
Duvet
Earrings
Easel
Egg
End table
Envelope
Envelopes
Eraser
Fan
Fax machine
Filing cabinet
Fire extinguisher
First aid kit
Flashlight
Flowers
Folder
Fork
Freezer
Frying pan
Glass
Glasses
Globe
Glue
Guitar
Hairbrush
Hammer
Hand sanitizer
Hand soap
Hanger
Hat
Headphones
Headset
Highlighter
Ink
Iron
Ironing board
Jacket
Juicer
Key
Keyboard
Knife
Ladder
Lamp
Lampshade
Laptop
Laundry basket
Light bulb
Luggage
Marker
Matches
Mattress
Microphone
Microwave
Mirror
Mobile phone
Mop
Mouse
Nail clippers
Napkin
Necklace
Nightstand
Notebook
Office chair
Ottoman
Oven
Oven mitts
Paint
Paintbrush
Painting
Palette
Pan
Pants
Paper
Paper shredder
Paperclip
Pen
Pencil
Pencil case
Pencil sharpener
Perfume
Phone
Photograph
Piano
Picture frame
Pillow
Planner
Plant
Plate
Plunger
Portfolio
Pot
Printer
Projector
Quill
Quilt
Radio
Razor
Recycling bin
Refrigerator
Remote control
Ring
Rug
Ruler
Scale
Scanner
Scissors
Sculpture
Shampoo
Sheets
Shelf
Shirt
Shoe
Shoe rack
Shoes
Shovel
Side table
Sink
Skateboard
Sketchbook
Sketchpad
Slippers
Smoke detector
Soap
Soap dispenser
Socks
Sofa
Speaker
Sponge
Spoon
Stamps
Stapler
Stationery
Suitcase
Sun hat
Sunglasses
Swimming goggles
Table
Tablet
Tape dispenser
Tea kettle
Television
Thermometer
Throw
Tissue
Tissue box
Toaster
Toilet
Toilet brush
Toilet paper
Toothbrush
Toothpaste
Towel
Trash can
Tweezers
Umbrella
Vacuum cleaner
Vase
Volleyball
Wallet
Wardrobe
Washing machine
Watch
Water bottle
Whiteboard
Window
Window cleaner
Wine glass
Wrench
Wristwatch
Yoga mat
Zipper#');
   l_set_id := ds_utility_krn.create_or_replace_data_set_def(p_set_name=>'OBJECTS', p_set_type=>'CSV', p_params=>my_clob);
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
