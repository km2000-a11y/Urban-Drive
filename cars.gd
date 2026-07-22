extends Node

var selected_car: String = ""          # scene path
var selected_car_name: String = ""     # car name string

var selected_ai_car: String = ""       # scene path
var selected_ai_car_name: String = ""  # car name string

var selected_color: Color = Color.WHITE
var selected_class: String = ""

var class_lists := {
	"suv": [
		"Schroder Colosso",
		"Colossus Behemoth",
		"Mir Cars Nightwolf",
		"Colossus Titan Max"
	],

	"compact": [
		"Zenith Horizon",
		"Schroder Atrix Q32",
		"Straeda B32",
		"Kuro Zephyr",
		"Eisenach Compaque"
	],
	"track_cars": [
	"Mir Cars Athletic C70",
	"Bartoli Track Cruiser",
	"Brutus Thunderbolt"
],


	"muscle": [
		"Mir Cars Hutch",
		"Brutus Viper"
	],

	"urban": [
		"Brutus Stingray",
		"Kestrel Speedster",
		"Kestrel Seabird",
		"Kuro Zephyr V6",
		"Eisenach Bengal",
		"Eisenach Prince"
	],

	"sedans": [
		"Eisenach Monarch",
		"Mir Cars Transporter",
		"Kuro Vault",
		"Strandberg Turbo",
		"Kuro Persian"
	],

	"sport": [
		"Bartoli Cruiser",
		"Berkshire V12-S",
		"Berkshire Tempest",
		"Schroder Atrix Sport",
		"Berkshire Blunt"
	],

	"sport_racing": [
		"Mir Cars Precision",
		"Kestrel Battleaxe",
		"Linetti Shepherd",
		"Brutus Venom"
	],

	"supercars": [
		"Linetti Terror",
		"Linetti Firestorm",
		"Kestrel Guillotine",
		"Mir Cars Raptor"
	],

	"torque_monsters": [
		"Eisenach Suppressor",
		"Eisenach Black Panda",
		"Schroder Fastback"
	],
	"sports_crossovers": [
	"Straeda Pitbull",
	"Mir Cars Crawler",
	"Eisenach Escorter"
],

	"special": [
		"Bartoli Cruiser Interceptor"
	]
}


var car_scene_paths := {
	"Colossus Titan Max":"res://Scenes/hummer_h1.tscn",
	"Colossus Behemoth":"res://Scenes/hummer_h2.tscn",
	"Mir Cars Nightwolf":"res://Scenes/lexus_lx470.tscn",
	"Straeda Pitbull":"res://Scenes/vw_touareg_v10.tscn",
	"Schroder Colosso":"res://Scenes/audi_q7.tscn",

	"Schroder Atrix Q32":"res://Scenes/audi_tt.tscn",
	"Straeda B32":"res://Scenes/new_beetle.tscn",
	"Zenith Horizon":"res://Scenes/nissan_350z.tscn",
	"Kuro Zephyr":"res://Scenes/lexus_is250.tscn",

	"Kestrel Seabird":"res://Scenes/lotus_exige_s.tscn",
	"Kestrel Speedster":"res://Scenes/morgan_aero_8.tscn",
	"Berkshire Blunt":"res://Scenes/jaguar_xkr.tscn",
	"Brutus Stingray":"res://Scenes/chevrolet_corvette_c5.tscn",
	"Kuro Zephyr V6":"res://Scenes/lexus_is350.tscn",
	"Eisenach Bengal":"res://Scenes/bmw_135.tscn",
	"Strandberg Turbo":"res://Scenes/volvo_s60r.tscn",
	"Eisenach Prince":"res://Scenes/bmw_m5_e39.tscn",

	"Brutus Viper":"res://Scenes/gt500.tscn",
	"Mir Cars Hutch":"res://Scenes/chevelle_ss.tscn",
	"Mir Cars Crawler":"res://Scenes/volvo_xc90.tscn",
	"Eisenach Escorter":"res://Scenes/bmw_x5.tscn",

	"Eisenach Monarch":"res://Scenes/bmw_745.tscn",
	"Mir Cars Transporter":"res://Scenes/audi_a8.tscn",
	"Kuro Vault":"res://Scenes/lexus_ls430.tscn",
	"Eisenach Suppressor":"res://Scenes/bmw_535d.tscn",
	"Eisenach Compaque":"res://Scenes/bmw_125.tscn",

	"Schroder Atrix Sport":"res://Scenes/audi_tt_rs.tscn",
	"Bartoli Cruiser":"res://Scenes/granturismo.tscn",
	"Berkshire V12-S":"res://Scenes/aston_db9.tscn",
	"Berkshire Tempest":"res://Scenes/vanquish.tscn",
	"Eisenach Black Panda":"res://Scenes/bmw_330d.tscn",
	"Kuro Persian":"res://Scenes/lexus_gs430.tscn",


	"Mir Cars Precision":"res://Scenes/bmw_m6.tscn",
	"Kestrel Battleaxe":"res://Scenes/sagaris.tscn",
	"Linetti Shepherd":"res://Scenes/gallardo.tscn",
	"Brutus Venom":"res://Scenes/dodge_viper.tscn",

	"Linetti Terror":"res://Scenes/murcielago.tscn",
	"Linetti Firestorm":"res://Scenes/diablo_road.tscn",
	"Kestrel Guillotine":"res://Scenes/tvr t 440r.tscn",
	"Mir Cars Raptor":"res://Scenes/saleen_s7.tscn",
	"Schroder Fastback":"res://Scenes/audi_a5_tdi.tscn",
	"Mir Cars Athletic C70":"res://Scenes/zonda.tscn",
	"Bartoli Track Cruiser":"res://Scenes/mc12.tscn",
	"Brutus Thunderbolt":"res://Scenes/ford_cobra.tscn",


	"Bartoli Cruiser Interceptor": "res://Scenes/granturismo_police.tscn"
}
var radar_target_speeds := {
	"suv": 170,
	"compact": 185,
	"track_cars": 300,
	"muscle": 200,
	"urban": 190,
	"sedans": 195,
	"sport": 210,
	"sport_racing": 250,
	"supercars": 270,
	"torque_monsters": 200,
	"sports_crossovers": 185,
	"special": 230
}

var car_colors := {
	"Straeda Pitbull":[Color8(128,128,0), Color8(90,90,90), Color8(180,150,80), Color8(0,70,40)],
	"Colossus Behemoth":[Color8(215,255,1), Color8(255,255,255), Color8(200,180,120), Color8(160,0,0)],
	"Mir Cars Nightwolf":[Color8(40,40,40), Color8(200,180,120), Color8(0,60,120), Color8(160,0,0)],
	"Colossus Titan Max":[Color8(255,0,0), Color8(180,180,180), Color8(210,180,90), Color8(120,40,40)],

	"Zenith Horizon":[Color8(255,116,49), Color8(255,255,255), Color8(0,90,180), Color8(180,180,180)],
	"Schroder Atrix Q32":[Color8(192,192,192), Color8(255,255,255), Color8(140,0,255), Color8(0,120,160)],
	"Straeda B32":[Color8(132,132,132), Color8(255,255,255), Color8(255,140,0), Color8(0,120,200)],

	"Kuro Zephyr":[
		Color8(240,240,240),
		Color8(120,20,20),
		Color8(0,110,130),
		Color8(70,70,70)
	],
	"Eisenach Suppressor":[
	Color8(75,78,71),     # ⭐ Default — Graphite (boring executive)
	Color8(180,180,180),  # Silver
	Color8(60,60,60),     # Dark Grey
	Color8(0,70,120)      # Deep Blue
],
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

	"Mir Cars Hutch":[Color8(180,20,20), Color8(255,255,255), Color8(60,60,60), Color8(0,40,80)],
	"Brutus Viper":[Color8(0,0,128), Color8(255,255,255), Color8(200,200,200), Color8(160,0,0)],

	"Brutus Stingray":[Color8(255,255,0), Color8(255,255,255), Color8(255,0,0), Color8(160,160,160)],
	"Kestrel Speedster":[Color8(192,192,192), Color8(255,255,255), Color8(0,120,180), Color8(180,180,180)],
	"Berkshire Blunt":[Color8(0,66,37), Color8(255,255,255), Color8(180,180,180), Color8(0,120,80)],
	"Kestrel Seabird":[Color8(50,205,50), Color8(255,255,255), Color8(255,200,0), Color8(0,120,200)],
	"Kuro Zephyr V6":[Color8(255,255,255), Color8(64,64,64), Color8(0,90,180), Color8(180,180,180)],
	"Strandberg Turbo":[Color8(133,82,141), Color8(255,255,255), Color8(60,60,60), Color8(0,80,160)],

		"Eisenach Monarch":[
	Color8(0,40,80),     # Deep Executive Blue (default)
	Color8(255,255,255), # White
	Color8(180,180,180), # Silver
	Color8(60,60,60)     # Graphite Grey
],
"Kuro Persian":[
	Color8(0,110,130),   # Teal Torque (same as Mammoth)
	Color8(255,255,255), # White
	Color8(60,60,60),    # Dark Grey
	Color8(180,20,20)    # Deep Muscle Red
],

	"Mir Cars Transporter":[Color8(0,90,160), Color8(255,255,255), Color8(160,160,160), Color8(0,40,80)],
	"Kuro Vault":[Color8(123,3,35), Color8(255,255,255), Color8(60,60,60), Color8(0,70,120)],
	"Eisenach Compaque":[
	Color8(240,240,240),
	Color8(0,60,120),
	Color8(180,180,180),
	Color8(120,0,0)
],
"Schroder Fastback":[
	Color8(180,180,180),   # Silver (default, executive)
	Color8(0,120,200),     # ⭐ Sepang Blue (bright Audi sport color)
	Color8(200,40,40),     # ⭐ Misano Red (deep sporty red)
	Color8(255,140,0)      # ⭐ Samoa Orange (rare Audi exclusive)
],
"Schroder Colosso":[
	Color8(180,180,180),   # Silver (default Audi SUV vibe)
	Color8(255,255,255),   # White
	Color8(60,60,60),      # Executive Graphite
	Color8(0,70,120)       # Deep Blue (Audi signature)
],

"Eisenach Prince":[
	Color8(255,99,71),    # ⭐ Tomato Red (default)
	Color8(185,155,185),  # White
	Color8(60,60,60),     # Dark Grey
	Color8(0,0,0)         # Black
],
	"Berkshire Tempest":[Color8(192,192,192), Color8(255,255,255), Color8(0,80,120), Color8(160,160,160)],
	"Berkshire V12-S":[Color8(46,54,64), Color8(255,255,255), Color8(80,120,160), Color8(160,160,160)],
	"Bartoli Cruiser":[Color8(0,157,192), Color8(255,255,255), Color8(180,180,180), Color8(0,90,160)],
	"Schroder Atrix Sport":[Color8(0,192,192), Color8(255,255,255), Color8(60,60,60), Color8(0,120,160)],
	"Eisenach Bengal":[Color8(217,90,43), Color8(255,255,255), Color8(0,90,180), Color8(180,180,180)],

	"Mir Cars Precision":[Color8(255,80,0), Color8(255,255,255), Color8(60,60,60), Color8(0,120,160)],
	"Kestrel Battleaxe":[Color8(180,20,35), Color8(255,255,255), Color8(255,140,0), Color8(200,40,80)],
	"Linetti Shepherd":[Color8(50,220,40), Color8(255,255,255), Color8(255,200,0), Color8(0,160,80)],
	"Brutus Venom":[Color8(255,0,0), Color8(255,255,255), Color8(180,180,180), Color8(0,0,0)],

	"Linetti Terror":[Color8(65,66,76), Color8(255,255,255), Color8(255,200,0), Color8(160,160,160)],
	"Linetti Firestorm":[Color8(225,220,40), Color8(255,255,255), Color8(255,80,0), Color8(200,160,0)],
	"Kestrel Guillotine":[Color8(120,0,180), Color8(255,255,255), Color8(200,160,255), Color8(60,0,90)],
	"Mir Cars Raptor":[Color8(225,20,40), Color8(255,255,255), Color8(160,160,160), Color8(0,40,80)]
}

func save_color():
	var f = FileAccess.open("user://car_color.save", FileAccess.WRITE)
	if f:
		f.store_line(str(selected_color.r) + "," + str(selected_color.g) + "," + str(selected_color.b) + "," + str(selected_color.a))
		f.close()

func load_color():
	if FileAccess.file_exists("user://car_color.save"):
		var f = FileAccess.open("user://car_color.save", FileAccess.READ)
		if f:
			var line = f.get_line()
			var parts = line.split(",")
			if parts.size() == 4:
				selected_color = Color(parts[0].to_float(), parts[1].to_float(), parts[2].to_float(), parts[3].to_float())
			f.close()

func pick_ai_car_path() -> String:
	if selected_class == "":
		return selected_car

	var list: Array = class_lists.get(selected_class, [])
	if list.is_empty():
		return selected_car

	var chosen_name: String = list[randi() % list.size()]
	selected_ai_car_name = chosen_name

	return car_scene_paths.get(chosen_name, selected_car)

func get_ai_paths_for_class(_unused):
	var result = []

	var list = class_lists.get(selected_class, [])

	if list.is_empty():
		for i in range(7):
			result.append(selected_car)
		return result

	for i in range(7):
		var car_name = list[randi() % list.size()]
		var path = car_scene_paths.get(car_name, selected_car)
		result.append(path)

	return result

func get_radar_target_speed() -> int:
	return radar_target_speeds.get(selected_class, 180)
