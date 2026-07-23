extends CanvasLayer

# -------------------------
# CAR SELECT STATE
# -------------------------

var car_class := ""
var car_name := ""
var car_index := 0
var color_index := 0

# 3D Preview
@onready var preview_holder: Node3D = $SubViewportContainer/SubViewport/CarPreview/CarHolder
var preview_car: Node3D = null
var rotation_speed := 1.0

# -------------------------
# COLOR DATA
# -------------------------

var car_colors := {
	"Straeda Pitbull":[Color8(128,128,0), Color8(90,90,90), Color8(180,150,80), Color8(0,70,40)],
	"Mir Cars Crawler":[
		Color8(200,40,40),   # Deep Red (default)
		Color8(255,255,255), # White
		Color8(60,60,60),    # Graphite
		Color8(0,80,160)     # Deep Blue
	],
	"Eisenach Escorter":[
		Color8(180,180,180), # Silver (default BMW SUV vibe)
		Color8(255,255,255), # White
		Color8(60,60,60),    # Dark Grey
		Color8(0,70,120)     # Deep Blue
	],
	"Colossus Behemoth":[Color8(215,255,1), Color8(255,255,255), Color8(200,180,120), Color8(160,0,0)],
	"Mir Cars Nightwolf":[Color8(0,0,192), Color8(255,255,255), Color8(64,64,64), Color8(0,80,160)],
	"Colossus Titan Max":[Color8(255,0,0), Color8(180,180,180), Color8(210,180,90), Color8(120,40,40)],

	"Zenith Horizon":[Color8(255,116,49), Color8(255,255,255), Color8(0,90,180), Color8(180,180,180)],
	"Schroder Atrix Q32":[Color8(192,192,192), Color8(255,255,255), Color8(140,0,255), Color8(0,120,160)],
	"Straeda B32":[Color8(132,132,132), Color8(255,255,255), Color8(255,140,0), Color8(0,120,200)],
	"Strandberg Turbo":[
	Color8(133,82,141),   # ⭐ Purple Metallic (default)
	Color8(255,255,255),  # White
	Color8(60,60,60),     # Dark Grey
	Color8(0,80,160)      # Deep Blue
],
"Eisenach Black Panda":[
	Color8(40,40,40),     # ⭐ Default — Panda Graphite
	Color8(255,255,255),  # White
	Color8(0,70,120),     # Deep Blue
	Color8(180,180,180)   # Silver
],

"Schroder Fastback":[
	Color8(180,180,180),   # Silver (default, executive)
	Color8(0,120,200),     # ⭐ Sepang Blue (bright Audi sport color)
	Color8(200,40,40),     # ⭐ Misano Red (deep sporty red)
	Color8(255,140,0)      # ⭐ Samoa Orange (rare Audi exclusive)
],

"Eisenach Suppressor":[
	Color8(75,78,71),     # ⭐ Default — Graphite (boring executive)
	Color8(180,180,180),  # Silver
	Color8(60,60,60),     # Dark Grey
	Color8(0,70,120)      # Deep Blue
],
"Eisenach Compaque":[
	Color8(240,240,240),
	Color8(0,60,120),
	Color8(180,180,180),
	Color8(120,0,0)
],
"Kuro Persian":[
	Color8(0,110,130),   # Teal Torque (same as Mammoth)
	Color8(255,255,255), # White
	Color8(60,60,60),    # Dark Grey
	Color8(180,20,20)    # Deep Muscle Red
],


"Mir Cars Athletic C70":[
	Color8(255,80,20),   # Default — American Hyper Orange
	Color8(255,255,255), # White
	Color8(60,60,60),    # Graphite
	Color8(0,90,160)     # Deep Blue
],

"Bartoli Track Cruiser":[
	Color8(0,157,192),   # Default — MC12 Blue
	Color8(255,255,255), # White
	Color8(180,180,180), # Silver
	Color8(0,90,160)     # Deep Blue
],

"Brutus Thunderbolt":[
	Color8(255,0,0),     # Default — Cobra Red
	Color8(255,255,255), # White
	Color8(60,60,60),    # Graphite
	Color8(0,40,120)     # Deep Blue
],



	"Mir Cars Hutch":[Color8(228,31,36), Color8(255,255,255), Color8(160,160,160), Color8(0,40,120)],
	"Brutus Viper":[Color8(0,0,128), Color8(255,255,255), Color8(200,200,200), Color8(160,0,0)],

	"Brutus Stingray":[Color8(255,255,0), Color8(255,255,255), Color8(255,0,0), Color8(160,160,160)],
	"Kestrel Speedster":[Color8(192,192,192), Color8(255,255,255), Color8(0,120,180), Color8(180,180,180)],
	"Berkshire Blunt":[Color8(0,66,37), Color8(255,255,255), Color8(180,180,180), Color8(0,120,80)],
	"Kestrel Seabird":[Color8(50,205,50), Color8(255,255,255), Color8(255,200,0), Color8(0,120,200)],
	"Kuro Zephyr V6":[Color8(255,255,255), Color8(64,64,64), Color8(0,90,180), Color8(180,180,180)],
	

	"Eisenach Monarch":[
	Color8(0,40,80),     # Deep Executive Blue (default)
	Color8(255,255,255), # White
	Color8(180,180,180), # Silver
	Color8(60,60,60)     # Graphite Grey
],
"Eisenach Prince":[
	Color8(255,99,71),    # ⭐ Tomato Red (default)
	Color8(185,155,185),  # White
	Color8(60,60,60),     # Dark Grey
	Color8(0,0,0)         # Black
],

	"Mir Cars Transporter":[Color8(192,192,192), Color8(255,255,255), Color8(0,40,80), Color8(160,160,160)],
	"Kuro Vault":[Color8(123,3,35), Color8(255,255,255), Color8(60,60,60), Color8(0,70,120)],

	"Berkshire Tempest":[Color8(192,192,192), Color8(255,255,255), Color8(0,80,120), Color8(160,160,160)],
	"Berkshire V12-S":[Color8(46,54,64), Color8(255,255,255), Color8(80,120,160), Color8(160,160,160)],
	"Bartoli Cruiser":[Color8(0,157,192), Color8(255,255,255), Color8(180,180,180), Color8(0,90,160)],
	"Eisenach Bengal":[
	Color8(217,90,43),   # Same default as Roadstar
	Color8(255,255,255),
	Color8(0,90,180),
	Color8(180,180,180)
],

   
	"Schroder Atrix Sport":[
	Color8(0,192,192),   # ⭐ Default — Urban Drive Cyan
	Color8(255,255,255), # White
	Color8(60,60,60),    # Dark Grey
	Color8(0,120,160)    # Deep Blue
],

"Schroder Colosso":[
	Color8(180,180,180),   # Silver (default Audi SUV vibe)
	Color8(255,255,255),   # White
	Color8(60,60,60),      # Executive Graphite
	Color8(0,70,120)       # Deep Blue (Audi signature)
],

	"Mir Cars Precision":[
		Color8(255,99,71),    # ⭐ Default — tomato red
		Color8(255,255,255),  # White
		Color8(60,60,60),     # Dark grey
		Color8(0,0,0)         # Black
	],
	"Kuro Zephyr":[
	Color8(240,240,240),   # ⭐ Pearl Cream (starter luxury vibe)
	Color8(120,20,20),     # Crimson Garnet (deep red, unique to IS250)
	Color8(0,110,130),     # Teal Mist (compact-class signature color)
	Color8(70,70,70)       # Graphite Shadow (dark matte grey)
],


	"Linetti Terror":[Color8(65,66,76), Color8(255,255,255), Color8(255,200,0), Color8(160,160,160)],
	"Kestrel Battleaxe":[Color8(180,20,35), Color8(255,255,255), Color8(255,140,0), Color8(200,40,80)],
	"Linetti Firestorm":[Color8(225,220,40), Color8(255,255,255), Color8(255,80,0), Color8(200,160,0)],
	"Linetti Shepherd":[Color8(50,220,40), Color8(255,255,255), Color8(255,200,0), Color8(0,160,80)],
	"Brutus Venom":[Color8(255,0,0), Color8(255,255,255), Color8(180,180,180), Color8(0,0,0)],
	"Kestrel Guillotine":[Color8(120,0,180), Color8(255,255,255), Color8(200,160,255), Color8(60,0,90)],
	"Mir Cars Raptor":[
		Color8(225,20,40),   # Deep red
		Color8(255,255,255), # White
		Color8(160,160,160), # Silver
		Color8(0,40,80)      # Midnight Blue
	]
}

# -------------------------
# CAR LISTS
# -------------------------

var suv_list = [
	"Colossus Titan Max",
	"Schroder Colosso",
	"Colossus Behemoth",
	"Mir Cars Nightwolf",
]

var compact_list = [
	"Schroder Atrix Q32",
	"Zenith Horizon",
	"Straeda B32",
	"Kuro Zephyr",
	"Eisenach Compaque"
]

var muscle_list = [
	"Brutus Viper",
	"Mir Cars Hutch"
]

var urban_list = [
	"Eisenach Prince",   # ⭐ NEW — E39 M5
	"Brutus Stingray",
	"Kestrel Speedster",
	"Kestrel Seabird",
	"Kuro Zephyr V6",
	"Eisenach Bengal"
]


var sedans_list = [
	"Kuro Persian",
	"Eisenach Monarch",
	"Mir Cars Transporter",
	"Kuro Vault",
	"Strandberg Turbo"
]


var sport_list = [
	"Schroder Atrix Sport",
	"Berkshire V12-S",
	"Bartoli Cruiser",
	"Berkshire Tempest",
	"Berkshire Blunt"
]

var sport_racing_list = [
	"Linetti Shepherd",
	"Mir Cars Precision",
	"Kestrel Battleaxe",
	"Brutus Venom"
]

var supercars_list = [
	"Linetti Terror",
	"Linetti Firestorm",
	"Kestrel Guillotine",
	"Mir Cars Raptor"
]
var sports_crossovers_list = [
	"Straeda Pitbull",
	"Mir Cars Crawler",
	"Eisenach Escorter"
]

var torque_monsters_list = [
	"Eisenach Suppressor",
	"Eisenach Black Panda",
	"Schroder Fastback"
]
var track_cars_list = [
	"Mir Cars Athletic C70",
	"Bartoli Track Cruiser",
	"Brutus Thunderbolt"
]


# -------------------------
# CAR STATS (PP omitted)
# -------------------------
var suv = {
	"Colossus Titan Max":[
		"", "Country: USA", "HP: 195", "WEIGHT: 3500 KG",
		"0-100 KM/H: 13.5s", "TOP SPEED: 170 KM/H",
		"ENGINE: V8 6.5L DIESEL", "ASPIRATION: Turbo", "TORQUE: 583 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Colossus Behemoth":[
		"", "Country: USA", "HP: 316", "WEIGHT: 2900 KG",
		"0-100 KM/H: 10.2s", "TOP SPEED: 208 KM/H",
		"ENGINE: V8 6.0L", "ASPIRATION: NA", "TORQUE: 488 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Mir Cars Nightwolf":[
		"", "Country: UAE", "HP: 220", "WEIGHT: 2668 KG",
		"0-100 KM/H: 8.9s", "TOP SPEED: 203 KM/H",
		"ENGINE: V8 6.6L", "ASPIRATION: NA", "TORQUE: 450 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Schroder Colosso":[
		"", "Country: Germany", "HP: 237", "WEIGHT: 2340 KG",
		"0-100 KM/H: 7.8s", "TOP SPEED: 217 KM/H",
		"ENGINE: V6 3.0L DIESEL", "ASPIRATION: Turbo", "TORQUE: 500 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	]
}

var compact = {
	"Schroder Atrix Q32":[
		"", "Country: Germany", "HP: 247", "WEIGHT: 1470 KG",
		"0-100 KM/H: 6.4s", "TOP SPEED: 250 KM/H",
		"ENGINE: V6 3.2L", "ASPIRATION: NA", "TORQUE: 320 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Straeda B32":[
		"", "Country: Germany", "HP: 224", "WEIGHT: 1500 KG",
		"0-100 KM/H: 6.7s", "TOP SPEED: 229 KM/H",
		"ENGINE: V6 3.2L", "ASPIRATION: NA", "TORQUE: 300 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Zenith Horizon":[
		"", "Country: Japan", "HP: 287", "WEIGHT: 1460 KG",
		"0-100 KM/H: 5.9s", "TOP SPEED: 250 KM/H",
		"ENGINE: V6 3.5L", "ASPIRATION: NA", "TORQUE: 340 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kuro Zephyr":[
		"", "Country: Japan", "HP: 204", "WEIGHT: 1600 KG",
		"0-100 KM/H: 7.3s", "TOP SPEED: 234 KM/H",
		"ENGINE: V6 2.5L", "ASPIRATION: NA", "TORQUE: 250 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Eisenach Compaque":[
		"", "Country: Germany", "HP: 215", "WEIGHT: 1450 KG",
		"0-100 KM/H: 6.9s", "TOP SPEED: 238 KM/H",
		"ENGINE: L6 3.0L", "ASPIRATION: NA", "TORQUE: 280 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}

var muscle = {
	"Brutus Viper":[
		"", "Country: USA", "HP: 355", "WEIGHT: 1650 KG",
		"0-100 KM/H: 5.8s", "TOP SPEED: 225 KM/H",
		"ENGINE: V8 7.0L", "ASPIRATION: NA", "TORQUE: 540 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Mir Cars Hutch":[
		"", "Country: UAE", "HP: 372", "WEIGHT: 1780 KG",
		"0-100 KM/H: 5.6s", "TOP SPEED: 232 KM/H",
		"ENGINE: V8 7.1L", "ASPIRATION: NA", "TORQUE: 560 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}
var urban_racers = {
	"Eisenach Prince":[
	"", "Country: Germany", "HP: 390", "WEIGHT: 1740 KG",
	"0-100 KM/H: 4.6s", "TOP SPEED: 250 KM/H",
	"ENGINE: V8 4.9L", "ASPIRATION: NA", "TORQUE: 500 NM",
	"TRANSMISSION: REAR-WHEEL DRIVE"
],
	"Brutus Stingray":[
		"", "Country: USA", "HP: 345", "WEIGHT: 1460 KG",
		"0-100 KM/H: 5.0s", "TOP SPEED: 253 KM/H",
		"ENGINE: V8 5.7L", "ASPIRATION: NA", "TORQUE: 480 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kestrel Speedster":[
		"", "Country: UK", "HP: 286", "WEIGHT: 1145 KG",
		"0-100 KM/H: 4.7s", "TOP SPEED: 243 KM/H",
		"ENGINE: V8 4.4L", "ASPIRATION: NA", "TORQUE: 410 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kestrel Seabird":[
		"", "Country: UK", "HP: 217", "WEIGHT: 935 KG",
		"0-100 KM/H: 4.5s", "TOP SPEED: 238 KM/H",
		"ENGINE: L4 1.8L", "ASPIRATION: Supercharged", "TORQUE: 240 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kuro Zephyr V6":[
		"", "Country: Japan", "HP: 306", "WEIGHT: 1578 KG",
		"0-100 KM/H: 5.6s", "TOP SPEED: 250 KM/H",
		"ENGINE: V6 3.5L", "ASPIRATION: NA", "TORQUE: 370 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Eisenach Bengal":[
	"", "Country: Germany", "HP: 306", "WEIGHT: 1650 KG",
	"0-100 KM/H: 5.5s", "TOP SPEED: 260 KM/H",
	"ENGINE: L6 3.0L", "ASPIRATION: Turbo", "TORQUE: 400 NM",
	"TRANSMISSION: REAR-WHEEL DRIVE"
],
}
var sedans = {
	"Eisenach Monarch":[
		"", "Country: Germany", "HP: 325", "WEIGHT: 1985 KG",
		"0-100 KM/H: 6.4s", "TOP SPEED: 265 KM/H",
		"ENGINE: V8 4.4L", "ASPIRATION: NA", "TORQUE: 440 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Mir Cars Transporter":[
		"", "Country: UAE", "HP: 343", "WEIGHT: 1780 KG",
		"0-100 KM/H: 6.2s", "TOP SPEED: 257 KM/H",
		"ENGINE: V8 5.0L", "ASPIRATION: NA", "TORQUE: 480 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Kuro Vault":[
		"", "Country: Japan", "HP: 290", "WEIGHT: 1760 KG",
		"0-100 KM/H: 6.3s", "TOP SPEED: 248 KM/H",
		"ENGINE: V8 4.3L", "ASPIRATION: NA", "TORQUE: 430 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Strandberg Turbo":[
		"", "Country: Sweden", "HP: 300", "WEIGHT: 1667 KG",
		"0-100 KM/H: 5.8s", "TOP SPEED: 250 KM/H",
		"ENGINE: L5 2.5L", "ASPIRATION: Turbo", "TORQUE: 350 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Kuro Persian":[
	"", "Country: Japan", "HP: 300", "WEIGHT: 1660 KG",
	"0-100 KM/H: 5.7s", "TOP SPEED: 258 KM/H",
	"ENGINE: V8 4.3L", "ASPIRATION: NA", "TORQUE: 430 NM",
	"TRANSMISSION: REAR-WHEEL DRIVE"
]
}

var sport = {
	"Schroder Atrix Sport":[
		"", "Country: Germany", "HP: 340", "WEIGHT: 1470 KG",
		"0-100 KM/H: 4.6s", "TOP SPEED: 266 KM/H",
		"ENGINE: L5 2.5L", "ASPIRATION: Turbo", "TORQUE: 450 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Berkshire V12-S":[
		"", "Country: UK", "HP: 450", "WEIGHT: 1740 KG",
		"0-100 KM/H: 5.1s", "TOP SPEED: 293 KM/H",
		"ENGINE: V12 5.9L", "ASPIRATION: NA", "TORQUE: 570 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Bartoli Cruiser":[
		"", "Country: Italy", "HP: 433", "WEIGHT: 1880 KG",
		"0-100 KM/H: 4.9s", "TOP SPEED: 287 KM/H",
		"ENGINE: V8 4.7L", "ASPIRATION: NA", "TORQUE: 490 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Berkshire Tempest":[
		"", "Country: UK", "HP: 460", "WEIGHT: 1875 KG",
		"0-100 KM/H: 5.4s", "TOP SPEED: 303 KM/H",
		"ENGINE: V12 5.9L", "ASPIRATION: NA", "TORQUE: 580 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Berkshire Blunt":[
		"", "Country: UK", "HP: 406", "WEIGHT: 1832 KG",
		"0-100 KM/H: 5.2s", "TOP SPEED: 286 KM/H",
		"ENGINE: V8 4.2L", "ASPIRATION: Supercharged", "TORQUE: 553 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}

var sport_racing = {
	"Mir Cars Precision":[
		"", "Country: UAE", "HP: 488", "WEIGHT: 1590 KG",
		"0-100 KM/H: 4.5s", "TOP SPEED: 307 KM/H",
		"ENGINE: V10 5.0L", "ASPIRATION: NA", "TORQUE: 520 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kestrel Battleaxe":[
		"", "Country: UK", "HP: 406", "WEIGHT: 1078 KG",
		"0-100 KM/H: 3.8s", "TOP SPEED: 287 KM/H",
		"ENGINE: L6 4.0L", "ASPIRATION: NA", "TORQUE: 390 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Linetti Shepherd":[
		"", "Country: Italy", "HP: 500", "WEIGHT: 1430 KG",
		"0-100 KM/H: 4.2s", "TOP SPEED: 305 KM/H",
		"ENGINE: V10 5.0L", "ASPIRATION: NA", "TORQUE: 510 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Brutus Venom":[
		"", "Country: USA", "HP: 415", "WEIGHT: 1560 KG",
		"0-100 KM/H: 4.1s", "TOP SPEED: 300 KM/H",
		"ENGINE: V10 8.0L", "ASPIRATION: NA", "TORQUE: 630 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}
var sports_crossovers = {
	"Straeda Pitbull":[
		"", "Country: Germany", "HP: 309", "WEIGHT: 2520 KG",
		"0-100 KM/H: 7.1s", "TOP SPEED: 235 KM/H",
		"ENGINE: V10 5.0L DIESEL", "ASPIRATION: Turbo", "TORQUE: 750 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],

	"Mir Cars Crawler":[
		"", "Country: UAE", "HP: 320", "WEIGHT: 2289 KG",
		"0-100 KM/H: 6.9s", "TOP SPEED: 232 KM/H",
		"ENGINE: V8 4.9L", "ASPIRATION: NA", "TORQUE: 480 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],

	"Eisenach Escorter":[
		"", "Country: Germany", "HP: 315", "WEIGHT: 2250 KG",
		"0-100 KM/H: 6.9s", "TOP SPEED: 232 KM/H",
		"ENGINE: V8 4.4L", "ASPIRATION: NA", "TORQUE: 440 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	]
}

var supercars = {
	"Linetti Terror":[
		"", "Country: Italy", "HP: 572", "WEIGHT: 1630 KG",
		"0-100 KM/H: 3.7s", "TOP SPEED: 330 KM/H",
		"ENGINE: V12 6.2L", "ASPIRATION: NA", "TORQUE: 650 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	],
	"Linetti Firestorm":[
		"", "Country: Italy", "HP: 493", "WEIGHT: 1625 KG",
		"0-100 KM/H: 4.2s", "TOP SPEED: 328 KM/H",
		"ENGINE: V12 5.7L", "ASPIRATION: NA", "TORQUE: 580 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Kestrel Guillotine":[
		"", "Country: UK", "HP: 440", "WEIGHT: 1100 KG",
		"0-100 KM/H: 3.6s", "TOP SPEED: 315 KM/H",
		"ENGINE: L6 4.2L", "ASPIRATION: NA", "TORQUE: 420 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],
	"Mir Cars Raptor":[
		"", "Country: USA", "HP: 532", "WEIGHT: 1378 KG",
		"0-100 KM/H: 3.8s", "TOP SPEED: 327 KM/H",
		"ENGINE: V8 7.0L", "ASPIRATION: NA", "TORQUE: 700 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}
var torque_monsters = {

	"Eisenach Suppressor":[
		"", "Country: Germany", "HP: 272", "WEIGHT: 1660 KG",
		"0-100 KM/H: 5.7s", "TOP SPEED: 245 KM/H",
		"ENGINE: L6 3.0L DIESEL", "ASPIRATION: Turbo", "TORQUE: 560 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],

	"Eisenach Black Panda":[
		"", "Country: Germany", "HP: 231", "WEIGHT: 1600 KG",
		"0-100 KM/H: 6.1s", "TOP SPEED: 252 KM/H",
		"ENGINE: L6 3.0L DIESEL", "ASPIRATION: Turbo", "TORQUE: 500 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],

	"Schroder Fastback":[
		"", "Country: Germany", "HP: 313", "WEIGHT: 1695 KG",
		"0-100 KM/H: 5.2s", "TOP SPEED: 265 KM/H",
		"ENGINE: V6 3.0L BITDI", "ASPIRATION: BiTurbo Diesel", "TORQUE: 650 NM",
		"TRANSMISSION: FOUR-WHEEL DRIVE"
	]
}

var track_cars = {
	"Mir Cars Athletic C70":[
		"", "Country: UAE", "HP: 600", "WEIGHT: 1378 KG",
		"0-100 KM/H: 3.65s", "TOP SPEED: 342 KM/H",
		"ENGINE: V12 7.0L", "ASPIRATION: NA", "TORQUE: 650 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],

	"Bartoli Track Cruiser":[
		"", "Country: Italy", "HP: 621", "WEIGHT: 1335 KG",
		"0-100 KM/H: 3.4s", "TOP SPEED: 335 KM/H",
		"ENGINE: V12 6.0L", "ASPIRATION: NA", "TORQUE: 652 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	],

	"Brutus Thunderbolt":[
		"", "Country: USA", "HP: 605", "WEIGHT: 1390 KG",
		"0-100 KM/H: 3.6s", "TOP SPEED: 338 KM/H",
		"ENGINE: V10 6.4L", "ASPIRATION: NA", "TORQUE: 640 NM",
		"TRANSMISSION: REAR-WHEEL DRIVE"
	]
}

# -------------------------
# SCENE PATHS
# -------------------------

func _ready():
	MusicManager.play_menu_music()
	$Control/ColorSelector.visible = false

var car_scene_paths = {
	"Colossus Titan Max":"res://Scenes/hummer_h1.tscn",
	"Colossus Behemoth":"res://Scenes/hummer_h2.tscn",
	"Mir Cars Nightwolf":"res://Scenes/lexus_lx470.tscn",
	"Straeda Pitbull":"res://Scenes/vw_touareg_v10.tscn",

	"Schroder Atrix Q32":"res://Scenes/audi_tt.tscn",
	"Straeda B32":"res://Scenes/new_beetle.tscn",
	"Zenith Horizon":"res://Scenes/nissan_350z.tscn",
	"Straeda G25":"res://Scenes/golf_v_gti.tscn",
	"Eisenach Compaque":"res://Scenes/bmw_125.tscn",
	"Mir Cars Crawler":"res://Scenes/volvo_xc90.tscn",
	"Eisenach Escorter":"res://Scenes/bmw_x5.tscn",


	"Kestrel Seabird":"res://Scenes/lotus_exige_s.tscn",
	"Eisenach Roadstar":"res://Scenes/bmw_z4.tscn",
	"Brutus Stingray":"res://Scenes/chevrolet_corvette_c5.tscn",
	"Kuro Zephyr V6":"res://Scenes/lexus_is350.tscn",
	"Kestrel Speedster":"res://Scenes/morgan_aero_8.tscn",
	"Berkshire Blunt":"res://Scenes/jaguar_xkr.tscn",
	"Brutus Viper":"res://Scenes/gt500.tscn",
	"Mir Cars Hutch":"res://Scenes/chevelle_ss.tscn",
	"Schroder Colosso":"res://Scenes/audi_q7.tscn",
	"Eisenach Black Panda":"res://Scenes/bmw_330d.tscn",
	"Eisenach Bengal":"res://Scenes/bmw_135.tscn",
	"Eisenach Prince":"res://Scenes/bmw_m5_e39.tscn",
	"Mir Cars Athletic C70":"res://Scenes/zonda.tscn",
	"Bartoli Track Cruiser":"res://Scenes/mc12.tscn",
	"Brutus Thunderbolt":"res://Scenes/ford_cobra.tscn",



	"Eisenach Monarch":"res://Scenes/bmw_745.tscn",
	"Mir Cars Transporter":"res://Scenes/audi_a8.tscn",
	"Kuro Vault":"res://Scenes/lexus_ls430.tscn",

	"Schroder Atrix Sport":"res://Scenes/audi_tt_rs.tscn",
	"Bartoli Cruiser":"res://Scenes/granturismo.tscn",
	"Berkshire V12-S":"res://Scenes/aston_db9.tscn",
	"Berkshire Tempest":"res://Scenes/vanquish.tscn",
	"Strandberg Turbo":"res://Scenes/volvo_s60r.tscn",

	"Mir Cars Precision":"res://Scenes/bmw_m6.tscn",
	"Kestrel Battleaxe":"res://Scenes/sagaris.tscn",
	"Linetti Shepherd":"res://Scenes/gallardo.tscn",
	"Brutus Venom":"res://Scenes/dodge_viper.tscn",
	"Kuro Persian":"res://Scenes/lexus_gs430.tscn",

	"Linetti Terror":"res://Scenes/murcielago.tscn",
	"Linetti Firestorm":"res://Scenes/diablo_road.tscn",
	"Kestrel Guillotine":"res://Scenes/tvr t 440r.tscn",
	"Mir Cars Raptor":"res://Scenes/saleen_s7.tscn",
	"Kuro Zephyr":"res://Scenes/lexus_is250.tscn",
	"Eisenach Suppressor":"res://Scenes/bmw_535d.tscn",
	"Schroder Fastback":"res://Scenes/audi_a5_tdi.tscn",
}

# -------------------------
# UI UPDATE
# -------------------------

func update_car_ui(stats: Array, name: String):
	$Control/Cars/CarName.text = name
	$Control/CarStats/PPLabel.text = stats[0]
	$Control/CarStats/CountryLabel.text = stats[1]
	$Control/CarStats/HPLabel.text = stats[2]
	$Control/CarStats/WeightLabel.text = stats[3]
	$Control/CarStats/ZeroToHundredLabel.text = stats[4]
	$Control/CarStats/TopSpeedLabel.text = stats[5]
	$Control/CarStats/EngineLabel.text = stats[6]
	$Control/CarStats/AspirationLabel.text = stats[7]
	$Control/CarStats/TorqueLabel.text = stats[8]
	$Control/CarStats/TransmissionLabel.text = stats[9]


# -------------------------
# 3D PREVIEW LOADING
# -------------------------

func load_preview_car(path: String):
	if preview_car:
		preview_car.queue_free()

	var car_scene = load(path)
	if car_scene == null:
		return

	var car = car_scene.instantiate()
	preview_holder.add_child(car)
	preview_car = car

	var model_root: Node3D = null
	if car.has_node("ModelRoot"):
		model_root = car.get_node("ModelRoot")
	else:
		model_root = car

	model_root.scale = Vector3.ONE * 1.5
	model_root.position = Vector3.ZERO

# -------------------------
# ROTATE PREVIEW EACH FRAME
# -------------------------

func _process(delta):
	if preview_car == null:
		return

	var model_root: Node3D = null
	if preview_car.has_node("ModelRoot"):
		model_root = preview_car.get_node("ModelRoot")
	else:
		model_root = preview_car

	model_root.rotate_y(rotation_speed * delta)

# -------------------------
# CLASS BUTTONS
# -------------------------

func _on_4x4suv_pressed():
	car_class = "suv"
	car_index = 0
	car_name = suv_list[car_index]
	update_car_ui(suv[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_compact_cars_pressed():
	car_class = "compact"
	car_index = 0
	car_name = compact_list[car_index]
	update_car_ui(compact[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_muscle_cars_pressed():
	car_class = "muscle"
	car_index = 0
	car_name = muscle_list[car_index]
	update_car_ui(muscle[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_urban_racers_pressed():
	car_class = "urban"
	car_index = 0
	car_name = urban_list[car_index]
	update_car_ui(urban_racers[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_sedans_pressed():
	car_class = "sedans"
	car_index = 0
	car_name = sedans_list[car_index]
	update_car_ui(sedans[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_sport_coupe_pressed():
	car_class = "sport"
	car_index = 0
	car_name = sport_list[car_index]
	update_car_ui(sport[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_supercars_pressed():
	car_class = "supercars"
	car_index = 0
	car_name = supercars_list[car_index]
	update_car_ui(supercars[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_sport_racing_pressed() -> void:
	car_class = "sport_racing"
	car_index = 0
	car_name = sport_racing_list[car_index]
	update_car_ui(sport_racing[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

# -------------------------
# INPUT
# -------------------------

func _input(event):
	# Ignore color inputs when no car class is selected (main menu)
	if car_class == "":
		if event.is_action_pressed("car_select_left") or event.is_action_pressed("car_select_right"):
			return
		if event.is_action_pressed("color_select_up") or event.is_action_pressed("color_select_down"):
			return

	# Normal behavior inside car select
	if event.is_action_pressed("car_select_left"):
		switch_car(-1)
	if event.is_action_pressed("car_select_right"):
		switch_car(1)

	if event.is_action_pressed("color_select_up"):
		change_color(1)
	if event.is_action_pressed("color_select_down"):
		change_color(-1)

# -------------------------
# LEFT / RIGHT SWITCHING
# -------------------------

func switch_car(direction):
	var list
	var dict

	match car_class:
		"suv":
			list = suv_list
			dict = suv
		"compact":
			list = compact_list
			dict = compact
		"muscle":
			list = muscle_list
			dict = muscle
		"urban":
			list = urban_list
			dict = urban_racers
		"sedans":
			list = sedans_list
			dict = sedans
		"sport":
			list = sport_list
			dict = sport
		"supercars":
			list = supercars_list
			dict = supercars
		"sport_racing":
			list = sport_racing_list
			dict = sport_racing
		"torque_monsters":
			list=torque_monsters_list
			dict=torque_monsters
		"sports_crossovers":
			list = sports_crossovers_list
			dict = sports_crossovers
		"track_cars":
				list = track_cars_list
				dict = track_cars



	car_index = (car_index + direction) % list.size()
	if car_index < 0:
		car_index = list.size() - 1

	car_name = list[car_index]
	update_car_ui(dict[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

# -------------------------
# COLOR SYSTEM
# -------------------------


func _reset_color():
	color_index = 0
	$Control/ColorSelector.visible = true
	apply_color_to_preview(car_colors[car_name][0])
	update_color_ui()

func change_color(direction):
	var colors = car_colors[car_name]
	color_index = (color_index + direction) % colors.size()
	if color_index < 0:
		color_index = colors.size() - 1

	apply_color_to_preview(colors[color_index])
	update_color_ui()

func apply_color_to_preview(color: Color):
	if preview_car == null:
		return

	if preview_car.has_node("ModelRoot/Body"):
		var body: Node3D = preview_car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = color

func update_color_ui():
	var colors = car_colors[car_name]

	$Control/ColorSelector/ColorBox1.color = colors[0]
	$Control/ColorSelector/ColorBox2.color = colors[1]
	$Control/ColorSelector/ColorBox3.color = colors[2]
	$Control/ColorSelector/ColorBox4.color = colors[3]

	for i in range(4):
		var box = $Control/ColorSelector.get_child(i)
		box.modulate = Color(1,1,1,1) if i == color_index else Color(0.6,0.6,0.6,1)

# -------------------------
# SELECT BUTTON
# -------------------------

func _on_select_pressed():
	Cars.selected_car_name = car_name
	Cars.selected_car = car_scene_paths[car_name]
	Cars.selected_color = car_colors[car_name][color_index]
	Cars.save_color()
	Cars.selected_class = car_class
	get_tree().change_scene_to_file("res://Scenes/track_select.tscn")


func _on_torque_monsters_pressed() -> void:
	car_class = "torque_monsters"
	car_index = 0
	car_name = torque_monsters_list[car_index]
	update_car_ui(torque_monsters[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")


func _on_sports_crossovers_pressed() -> void:
	car_class = "sports_crossovers"
	car_index = 0
	car_name = sports_crossovers_list[car_index]
	update_car_ui(sports_crossovers[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()

func _on_track_cars_pressed() -> void:
	car_class = "track_cars"
	car_index = 0
	car_name = track_cars_list[car_index]
	update_car_ui(track_cars[car_name], car_name)
	load_preview_car(car_scene_paths[car_name])
	_reset_color()
