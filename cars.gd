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
var car_scene_paths = {
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
