extends Node

var selected_car: String = ""          # scene path
var selected_car_name: String = ""     # car name string

var selected_ai_car: String = ""       # scene path
var selected_ai_car_name: String = ""  # car name string

var selected_color: Color = Color.WHITE
var selected_class: String = ""

var class_lists := {
	"suv": ["Straeda Pitbull","Colossus Behemoth","Kuro Fortress","Colossus Titan Max"],
	"compact": ["Zenith Horizon","Schroder Atrix Q32","Straeda G25","Straeda B32"],
	"muscle": ["Brutus Mauler","Brutus Viper"],
	"urban": ["Brutus Stingray","Kestrel Speedster","Kestrel Seabird","Kuro Zephyr V6","Eisenach Roadstar","Berkshire Blunt"],
	"sedans": ["Eisenach Monarch","Schroder Kaiser","Kuro Vault","Kronstadt Blade"],
	"sport": ["Gruber Targa","Berkshire Tempest","Berkshire V12-S","Bartoli Cruiser"],
	"sport_racing": ["Kestrel Battleaxe","Linetti Shepherd","Brutus Venom"],
	"supercars": ["Linetti Terror","Linetti Firestorm","Kestrel Guillotine"]
}

var car_scene_paths := {
	"Colossus Titan Max":"res://Scenes/hummer_h1.tscn",
	"Colossus Behemoth":"res://Scenes/hummer_h2.tscn",
	"Kuro Fortress":"res://Scenes/lexus_lx470.tscn",
	"Straeda Pitbull":"res://Scenes/vw_touareg_v10.tscn",
	"Schroder Atrix Q32":"res://Scenes/audi_tt.tscn",
	"Straeda B32":"res://Scenes/new_beetle.tscn",
	"Zenith Horizon":"res://Scenes/nissan_350z.tscn",
	"Straeda G25":"res://Scenes/golf_v_gti.tscn",
	"Kestrel Seabird":"res://Scenes/lotus_exige_s.tscn",
	"Kestrel Speedster":"res://Scenes/morgan_aero_8.tscn",
	"Berkshire Blunt":"res://Scenes/jaguar_xkr.tscn",
	"Brutus Stingray":"res://Scenes/chevrolet_corvette_c5.tscn",
	"Brutus Viper":"res://Scenes/gt500.tscn",
	"Brutus Mauler":"res://Scenes/chevelle_ss.tscn",
	"Eisenach Monarch":"res://Scenes/bmw_750il.tscn",
	"Schroder Kaiser":"res://Scenes/audi_a8.tscn",
	"Kuro Zephyr V6":"res://Scenes/lexus_is350.tscn",
	"Gruber Targa":"res://Scenes/porsche_911_targa_993.tscn",
	"Kuro Vault":"res://Scenes/lexus_ls430.tscn",
	"Berkshire V12-S":"res://Scenes/aston_db9.tscn",
	"Berkshire Tempest":"res://Scenes/vanquish.tscn",
	"Eisenach Roadstar":"res://Scenes/bmw_z4.tscn",
	"Bartoli Cruiser":"res://Scenes/granturismo.tscn",
	"Kestrel Battleaxe":"res://Scenes/sagaris.tscn",
	"Linetti Firestorm":"res://Scenes/diablo_road.tscn",
	"Linetti Shepherd":"res://Scenes/gallardo.tscn",
	"Linetti Terror":"res://Scenes/murcielago.tscn",
	"Brutus Venom":"res://Scenes/dodge_viper.tscn",
	"Kestrel Guillotine":"res://Scenes/tvr t 440r.tscn",
	"Kronstadt Blade":"res://Scenes/cls_350_cdi.tscn"
}

var car_colors := {
	"Straeda Pitbull":[Color8(128,128,0), Color8(90,90,90), Color8(180,150,80), Color8(0,70,40)],
	"Colossus Behemoth":[Color8(215,255,1), Color8(255,255,255), Color8(200,180,120), Color8(160,0,0)],
	"Kuro Fortress":[Color8(0,0,192), Color8(255,255,255), Color8(64,64,64), Color8(0,80,160)],
	"Colossus Titan Max":[Color8(255,0,0), Color8(180,180,180), Color8(210,180,90), Color8(120,40,40)],

	"Zenith Horizon":[Color8(255,116,49), Color8(255,255,255), Color8(0,90,180), Color8(180,180,180)],
	"Schroder Atrix Q32":[Color8(192,192,192), Color8(255,255,255), Color8(140,0,255), Color8(0,120,160)],
	"Straeda G25":[Color8(133,82,141), Color8(255,0,0), Color8(255,255,255), Color8(180,180,180)],
	"Straeda B32":[Color8(132,132,132), Color8(255,255,255), Color8(255,140,0), Color8(0,120,200)],

	"Brutus Mauler":[Color8(228,31,36), Color8(255,255,255), Color8(160,160,160), Color8(0,40,120)],
	"Brutus Viper":[Color8(0,0,128), Color8(255,255,255), Color8(200,200,200), Color8(160,0,0)],

	"Brutus Stingray":[Color8(255,255,0), Color8(255,255,255), Color8(255,0,0), Color8(160,160,160)],
	"Kestrel Speedster":[Color8(192,192,192), Color8(255,255,255), Color8(0,120,180), Color8(180,180,180)],
	"Berkshire Blunt":[Color8(0,66,37), Color8(255,255,255), Color8(180,180,180), Color8(0,120,80)],
	"Kestrel Seabird":[Color8(50,205,50), Color8(255,255,255), Color8(255,200,0), Color8(0,120,200)],
	"Kuro Zephyr V6":[Color8(255,255,255), Color8(64,64,64), Color8(0,90,180), Color8(180,180,180)],

	"Eisenach Monarch":[Color8(0,0,128), Color8(255,255,255), Color8(180,180,180), Color8(0,60,120)],
	"Schroder Kaiser":[Color8(192,192,192), Color8(255,255,255), Color8(0,40,80), Color8(160,160,160)],
	"Kuro Vault":[Color8(123,3,35), Color8(255,255,255), Color8(60,60,60), Color8(0,70,120)],
	"Kronstadt Blade":[Color8(85,85,85), Color8(255,255,255), Color8(160,160,160), Color8(0,40,80)],

	"Berkshire Tempest":[Color8(192,192,192), Color8(255,255,255), Color8(0,80,120), Color8(160,160,160)],
	"Berkshire V12-S":[Color8(46,54,64), Color8(255,255,255), Color8(80,120,160), Color8(160,160,160)],
	"Bartoli Cruiser":[Color8(0,157,192), Color8(255,255,255), Color8(180,180,180), Color8(0,90,160)],
	"Eisenach Roadstar":[Color8(217,90,43), Color8(255,255,255), Color8(0,90,180), Color8(180,180,180)],
	"Gruber Targa":[Color8(192,192,192), Color8(255,255,255), Color8(200,0,0), Color8(0,40,120)],

	"Linetti Terror":[Color8(65,66,76), Color8(255,255,255), Color8(255,200,0), Color8(160,160,160)],
	"Kestrel Battleaxe":[Color8(180,20,35), Color8(255,255,255), Color8(255,140,0), Color8(200,40,80)],
	"Linetti Firestorm":[Color8(225,220,40), Color8(255,255,255), Color8(255,80,0), Color8(200,160,0)],
	"Linetti Shepherd":[Color8(50,220,40), Color8(255,255,255), Color8(255,200,0), Color8(0,160,80)],
	"Brutus Venom":[Color8(255,0,0), Color8(255,255,255), Color8(180,180,180), Color8(0,0,0)],
	"Kestrel Guillotine":[Color8(120,0,180), Color8(255,255,255), Color8(200,160,255), Color8(60,0,90)]
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
